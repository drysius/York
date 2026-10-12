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

# Xvfb nao cria /tmp/.X11-unix sem ser root; criamos nos (uid de runtime, /tmp gravavel).
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
export API_PORT=${API_PORT:-8080}
export STEAM_AUTH_PORT=${STEAM_AUTH_PORT:-3001}
export STEAM_AUTH_URL="http://127.0.0.1:${STEAM_AUTH_PORT}"
export SETTINGS_PATH=${SETTINGS_PATH:-/home/container/settings/server-settings.json}
# startapp.sh aborta se SDVD_COMPOSE_REV nao bater com o esperado da imagem.
# Mantemos igual ao docker-compose.yml do upstream (bump conforme a imagem muda).
export SDVD_COMPOSE_REV=${SDVD_COMPOSE_REV:-4}

# -----------------------------------------------------------------------------
# 3) DISPLAY VIRTUAL (Xvfb :0) -- o jogo renderiza mesmo headless
# -----------------------------------------------------------------------------
echo "[ptero] iniciando Xvfb em ${DISPLAY} (${DISPLAY_WIDTH}x${DISPLAY_HEIGHT})..."
Xvfb "${DISPLAY}" -screen 0 "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x24" -nolisten tcp &
XVFB_PID=$!
for _ in $(seq 1 40); do
    xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1 && break
    sleep 0.25
done

# -----------------------------------------------------------------------------
# 4) STEAM DOWNLOADER (sidecar oficial, agora em background)
# serve o endpoint HTTP e baixa o jogo em GAME_DIR (subcomando "serve" confirmado).
# -----------------------------------------------------------------------------
if [ -z "${STEAM_USERNAME:-}" ] && [ -z "${STEAM_REFRESH_TOKEN:-}" ]; then
    echo "[ptero] AVISO: STEAM_USERNAME/STEAM_REFRESH_TOKEN nao definidos --"
    echo "[ptero] o download do jogo vai falhar. Configure nas variaveis do egg."
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
