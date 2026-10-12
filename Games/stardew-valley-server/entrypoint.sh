#!/bin/bash
# =============================================================================
# Entrypoint Pterodactyl para o Stardew Valley Dedicated Server (Junimo Server)
#
# Substitui o docker-compose oficial (server + steam-auth) num unico container
# nao-root. Ordem: persistencia -> display -> downloader Steam -> startapp.sh.
# =============================================================================
set -uo pipefail
sleep 1

TZ=${TZ:-UTC}; export TZ

# IP interno do Docker (varios mods/consultas usam)
INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2); exit}')
export INTERNAL_IP

# -----------------------------------------------------------------------------
# 1) PERSISTENCIA
# No Pterodactyl so /home/container (e /tmp) sao gravaveis. A imagem declara
# VOLUME em /data/game e /config/xdg/config/StardewValley, onde o Docker monta
# volumes anonimos root que o uid de runtime nao grava. Por isso usamos paths
# PROPRIOS sob /home/container (game, Mods, home, xdg, settings) -- fora de
# qualquer VOLUME -- e o startapp.sh foi reescrito no build para /home/container/*.
# -----------------------------------------------------------------------------
mkdir -p /home/container/game /home/container/Mods /home/container/home \
         /home/container/xdg/config/StardewValley /home/container/settings \
         /home/container/diagnostics /home/container/steam-session

# Conteudo baked (mod JunimoServer, smapi-config) sao semeados a cada boot, pois o
# mount do Pterodactyl sobrepoe /home/container.
if [ -d /opt/sdvd-default/data/Mods/JunimoServer ]; then
    rm -rf /home/container/Mods/JunimoServer 2>/dev/null || true
    cp -r /opt/sdvd-default/data/Mods/JunimoServer /home/container/Mods/ 2>/dev/null || true
fi
[ -f /opt/sdvd-default/data/smapi-config.json ] \
    && cp -f /opt/sdvd-default/data/smapi-config.json /home/container/smapi-config.json 2>/dev/null || true

# Xvnc nao cria /tmp/.X11-unix sem ser root; criamos nos (uid de runtime, /tmp gravavel).
mkdir -p /tmp/.X11-unix 2>/dev/null || true
chmod 1777 /tmp/.X11-unix 2>/dev/null || true

# -----------------------------------------------------------------------------
# 2) VARIAVEIS que o stack oficial injetaria via compose
# -----------------------------------------------------------------------------
export HOME=/home/container/home
export DISPLAY=${DISPLAY:-:0}
export XDG_CONFIG_HOME=/home/container/xdg/config
export SMAPI_MODS_PATH=/home/container/Mods
export DISPLAY_WIDTH=${DISPLAY_WIDTH:-1280}
export DISPLAY_HEIGHT=${DISPLAY_HEIGHT:-720}
# A porta do jogo e a alocacao primaria (SERVER_PORT), definida pelo Pterodactyl na
# inicializacao -- nao precisa de variavel/export aqui.
export QUERY_PORT=${QUERY_PORT:-27015}
export API_PORT=${API_PORT:-8080}
export VNC_PORT=${VNC_PORT:-5900}
export STEAM_AUTH_PORT=${STEAM_AUTH_PORT:-3001}
export STEAM_AUTH_URL="http://127.0.0.1:${STEAM_AUTH_PORT}"
export SETTINGS_PATH=${SETTINGS_PATH:-/home/container/settings/server-settings.json}
# startapp.sh aborta se SDVD_COMPOSE_REV nao bater com o esperado da imagem.
export SDVD_COMPOSE_REV=${SDVD_COMPOSE_REV:-4}

# -----------------------------------------------------------------------------
# 2b) IP CONNECTIONS -- ativado por padrao (host). Controlado por ALLOW_IP_CONNECTIONS.
# So vem do server-settings.json (sem env no mod), entao escrevemos/patchamos o JSON.
# -----------------------------------------------------------------------------
case "${ALLOW_IP_CONNECTIONS:-true}" in true|TRUE|1|yes) IPVAL=true;; *) IPVAL=false;; esac
mkdir -p "$(dirname "${SETTINGS_PATH}")"
if [ ! -f "${SETTINGS_PATH}" ]; then
    printf '{"Server":{"AllowIpConnections":%s}}\n' "${IPVAL}" > "${SETTINGS_PATH}"
elif command -v jq >/dev/null 2>&1; then
    _tmp=$(mktemp)
    if jq --argjson v "${IPVAL}" '.Server.AllowIpConnections=$v' "${SETTINGS_PATH}" > "${_tmp}" 2>/dev/null; then
        mv "${_tmp}" "${SETTINGS_PATH}"
    else
        rm -f "${_tmp}"
    fi
fi
echo "[ptero] AllowIpConnections=${IPVAL} (conexao por IP direto em 24642/udp)"

# -----------------------------------------------------------------------------
# 3) DISPLAY + VNC (Xvnc :0) -- serve o display do jogo E o servidor VNC numa porta.
# Com VNC_PASSWORD usa autenticacao; sem senha fica aberto (defina uma senha!).
# -----------------------------------------------------------------------------
VNC_SEC="-SecurityTypes None"
if [ -n "${VNC_PASSWORD:-}" ] && command -v vncpasswd >/dev/null 2>&1; then
    mkdir -p "${HOME}/.vnc"
    if printf '%s\n%s\n' "${VNC_PASSWORD}" "${VNC_PASSWORD}" | vncpasswd -f > "${HOME}/.vnc/passwd" 2>/dev/null; then
        chmod 600 "${HOME}/.vnc/passwd"
        VNC_SEC="-SecurityTypes VncAuth -PasswordFile ${HOME}/.vnc/passwd"
    fi
fi
echo "[ptero] iniciando Xvnc em ${DISPLAY} (${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}, VNC na porta ${VNC_PORT})..."
# BlacklistThreshold alto: evita banir o IP quando o cliente erra o handshake
# (ex.: tentar abrir a porta VNC no navegador). O blacklist tambem some ao reiniciar.
Xvnc "${DISPLAY}" -geometry "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}" -depth 24 \
     -rfbport "${VNC_PORT}" ${VNC_SEC} -AlwaysShared -desktop "Stardew" \
     -BlacklistThreshold=1000000 -BlacklistTimeout=5 &
XVFB_PID=$!
for _ in $(seq 1 40); do
    xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1 && break
    sleep 0.25
done

# -----------------------------------------------------------------------------
# 4) STEAM DOWNLOADER (sidecar oficial, agora em background)
# serve o endpoint HTTP e baixa o jogo em GAME_DIR (subcomando "serve" confirmado).
# -----------------------------------------------------------------------------
# Credenciais Steam: sem login o jogo NAO baixa e o servidor fica preso em
# "Waiting for steam-auth...". Avisamos de forma clara qual variavel falta.
if [ -z "${STEAM_REFRESH_TOKEN:-}" ]; then
    if [ -z "${STEAM_USERNAME:-}" ]; then
        echo "[ptero] ====================================================================="
        echo "[ptero]  ATENCAO: nenhuma credencial Steam definida!"
        echo "[ptero]  Defina STEAM_USERNAME + STEAM_PASSWORD (ou STEAM_REFRESH_TOKEN)"
        echo "[ptero]  nas variaveis do servidor. Sem isso o jogo nao sera baixado e o"
        echo "[ptero]  servidor ficara parado esperando o download."
        echo "[ptero] ====================================================================="
    elif [ -z "${STEAM_PASSWORD:-}" ]; then
        echo "[ptero] ====================================================================="
        echo "[ptero]  ATENCAO: STEAM_USERNAME definido, mas sem STEAM_PASSWORD nem"
        echo "[ptero]  STEAM_REFRESH_TOKEN. Se ainda nao ha sessao salva, o login vai"
        echo "[ptero]  falhar. Preencha STEAM_PASSWORD (ou use STEAM_REFRESH_TOKEN)."
        echo "[ptero] ====================================================================="
    fi
fi
echo "[ptero] iniciando steam-service em 127.0.0.1:${STEAM_AUTH_PORT}..."
(
    cd /opt/steam-service || exit 0
    PORT="${STEAM_AUTH_PORT}" \
    GAME_DIR=/home/container/game \
    SESSION_DIR=/home/container/steam-session \
    STEAM_USERNAME="${STEAM_USERNAME:-}" \
    STEAM_PASSWORD="${STEAM_PASSWORD:-}" \
    STEAM_REFRESH_TOKEN="${STEAM_REFRESH_TOKEN:-}" \
    dotnet SteamService.dll serve
) &
STEAM_PID=$!

# Derruba os processos de apoio quando o servidor sair
cleanup() {
    kill "${STEAM_PID}" "${XVFB_PID}" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

# -----------------------------------------------------------------------------
# 5) SERVIDOR -- entrega para o launcher oficial, que baixa o jogo (1o boot),
# instala o SMAPI e sobe o mod JunimoServer, ficando em foreground.
# -----------------------------------------------------------------------------
echo "[ptero] iniciando Stardew Valley Dedicated Server..."
exec /startapp.sh
