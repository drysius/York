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
# O Pterodactyl so persiste o volume montado em /home/container. A imagem oficial
# grava o jogo em /data e os saves em /config -- fora do volume, perderia tudo e
# baixaria o jogo a cada boot. Redirecionamos /data e /config para dentro do
# volume persistente via symlink.
# -----------------------------------------------------------------------------
mkdir -p /home/container/data /home/container/config
if [ ! -L /data ]; then
    [ -d /data ] && cp -an /data/. /home/container/data/ 2>/dev/null || true
    rm -rf /data && ln -s /home/container/data /data
fi
if [ ! -L /config ]; then
    [ -d /config ] && cp -an /config/. /home/container/config/ 2>/dev/null || true
    rm -rf /config && ln -s /home/container/config /config
fi
mkdir -p /data/game /data/Mods /data/settings /data/diagnostics \
         /config/xdg/config/StardewValley

# -----------------------------------------------------------------------------
# 2) VARIAVEIS que o stack oficial injetaria via compose
# -----------------------------------------------------------------------------
export HOME=/config
export DISPLAY=${DISPLAY:-:0}
export XDG_CONFIG_HOME=/config/xdg/config
export SMAPI_MODS_PATH=/data/Mods
export DISPLAY_WIDTH=${DISPLAY_WIDTH:-1280}
export DISPLAY_HEIGHT=${DISPLAY_HEIGHT:-720}
export API_PORT=${API_PORT:-8080}
export STEAM_AUTH_PORT=${STEAM_AUTH_PORT:-3001}
export STEAM_AUTH_URL="http://127.0.0.1:${STEAM_AUTH_PORT}"
export SETTINGS_PATH=${SETTINGS_PATH:-/data/settings/server-settings.json}
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
# serve o endpoint HTTP que o startapp.sh/steam SDK consultam para baixar o jogo.
# TODO(verificar): confirmar o subcomando correto do SteamService.dll ("serve")
# contra a imagem sdvd/steam-service -- ver README.
# -----------------------------------------------------------------------------
if [ -z "${STEAM_USERNAME:-}" ] && [ -z "${STEAM_REFRESH_TOKEN:-}" ]; then
    echo "[ptero] AVISO: STEAM_USERNAME/STEAM_REFRESH_TOKEN nao definidos --"
    echo "[ptero] o download do jogo vai falhar. Configure nas variaveis do egg."
fi
echo "[ptero] iniciando steam-service em 127.0.0.1:${STEAM_AUTH_PORT}..."
(
    cd /opt/steam-service || exit 0
    PORT="${STEAM_AUTH_PORT}" \
    GAME_DIR=/data/game \
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
