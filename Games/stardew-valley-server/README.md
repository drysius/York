# Stardew Valley Dedicated Server (Junimo Server) — imagem para Pterodactyl

Adapta o projeto [stardew-valley-dedicated-server/server](https://github.com/stardew-valley-dedicated-server/server)
(um stack docker-compose multi-container) para rodar em **um único container
não-root**, como o Pterodactyl exige.

- Imagem publicada: `ghcr.io/drysius/games:stardew-valley-server`
- Egg correspondente: `Eggs/Eggs/egg-stardew-valley-dedicated-server.json`

## Como funciona

A imagem parte de `sdvd/server` (jogo + SMAPI + mod JunimoServer + `startapp.sh`) e
embute o `sdvd/steam-service` (downloader da Steam). O `entrypoint.sh`:

1. **Persistência** — redireciona `/data` e `/config` (onde o jogo/saves vivem) para
   dentro de `/home/container` via symlink, já que o Pterodactyl só persiste esse volume.
2. **Display** — sobe um `Xvfb :0` (o jogo renderiza mesmo headless).
3. **Steam** — roda o `steam-service` em background em `127.0.0.1:3001` (substitui o
   container sidecar); baixa o jogo no primeiro boot.
4. **Servidor** — entrega para o `startapp.sh` oficial, que instala o SMAPI e sobe o mod.

O chown de `/data` e `/config` (feito como root no `cont-init` oficial) é feito **no build**,
porque o Pterodactyl inicia sem root.

## Pré-requisitos

- Conta Steam que **possui** Stardew Valley.
- `STEAM_REFRESH_TOKEN` gerado uma vez localmente (rode o `setup` do projeto oficial).
  Sem ele, o Steam Guard 2FA interativo trava o boot não-interativo do Pterodactyl.

## ⚠️ Premissas a verificar (este scaffold ainda não foi testado em infra real)

Estes pontos dependem de detalhes internos das imagens oficiais e precisam ser
confirmados/ajustados ao construir e rodar na sua stack WSL+Docker+Pterodactyl v2:

1. ~~Subcomando do steam-service~~ — **confirmado**: `serve`, com `GAME_DIR=/data/game`
   e `PORT=3001` (WorkingDir `/app`). Já é o que o `entrypoint.sh` faz.
   ⚠️ Risco de runtime: a imagem `sdvd/server` pode não ter o runtime .NET que o
   steam-service precisa. Se o `dotnet` faltar no 1º boot, copie o runtime da stage
   `steam` no Dockerfile.
2. **Display Xvfb vs. janela/WM** — a imagem oficial usa Xvnc + WM da baseimage-gui. Se o
   SMAPI/jogo exigir um window manager, pode ser necessário subir `openbox` antes do jogo.
3. **UID do container** — assumimos `1000`. Se o seu Wings rodar com outro UID, ajuste o
   `chown` no `dockerfile`.
4. **`SDVD_COMPOSE_REV`** — fixado em `4` (valor do `docker-compose.yml` upstream). Se a
   imagem base atualizar, o `startapp.sh` aborta; bump a variável no `entrypoint.sh`.
5. **String "done" do egg** — `config.startup.done` está em `"context: Loaded save"`.
   Ajuste para a linha real que o SMAPI/mod imprime quando o servidor fica pronto, senão o
   painel não marca como "online".
6. **VNC web UI** — não exposta nesta adaptação. Administre pela API HTTP (porta 8080).

## Build local / teste

```bash
# precisa de acesso às imagens oficiais sdvd/server e sdvd/steam-service
docker build -t ghcr.io/drysius/games:stardew-valley-server \
  -f Games/stardew-valley-server/dockerfile Games/stardew-valley-server

# smoke test (sem Pterodactyl)
docker run --rm -it \
  -e ALLOW_INSECURE_SETUP=true \
  -e STEAM_USERNAME=... -e STEAM_REFRESH_TOKEN=... \
  -p 8080:8080 \
  ghcr.io/drysius/games:stardew-valley-server
```

O CI (`.github/workflows/Games.yaml`) publica a imagem automaticamente ao dar push em
`Games/**` (matriz `stardew-valley-server`, apenas `linux/amd64` — o steam-service é x64).
