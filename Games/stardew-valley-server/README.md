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

## Status

- ✅ **Build** e **boot** verificados (local WSL + CI). O servidor sobe completo: baixa o
  jogo, instala SMAPI, carrega o mod, cria save, conecta na Steam e gera invite code.
- ✅ Tudo grava sob `/home/container` (único path gravável no Pterodactyl).
- ✅ Xvnc (display + VNC), steam-service (:3001) e IP connections funcionando.

## Portas (importante)

| Porta | Env | Editável | Observação |
|-------|-----|----------|------------|
| **24642/udp** | `GAME_PORT` | ❌ fixa | Porta do jogo — **fixa no Stardew** (`const DefaultGamePort`). Clientes conectam nela por IP. **Aloque 24642/udp como porta PRIMÁRIA** (SERVER_PORT) para conexão por IP. |
| 27015/udp | `QUERY_PORT` | ✅ | Query Steam (server browser). Opcional. |
| 8080/tcp | `API_PORT` | ✅ | API HTTP (admin). Use uma alocação separada (≠ 24642). |
| 5900/tcp | `VNC_PORT` | ✅ | Servidor VNC (ver abaixo). |

A porta do jogo **não pode ser trocada** — o Stardew a tem hardcoded em 24642 e os clientes
vanilla sempre conectam nela. Por isso a alocação primária deve ser 24642/udp. As demais
(API, query, VNC) são livres e editáveis no egg.

**Conexão por IP** vem ligada por padrão (`ALLOW_IP_CONNECTIONS=true`), aplicada ao
`server-settings.json` no boot. Players conectam no IP da linha "Network" do banner, porta
24642. Alternativa sem porta: o **invite code** (Steam relay), mostrado no log.

## VNC

A imagem roda **Xvnc** servindo o display `:0` e um servidor VNC na porta `VNC_PORT`
(padrão 5900). Aloque essa porta, defina `VNC_PASSWORD` (máx 8 chars) e conecte com um
cliente VNC (TigerVNC, RealVNC) em `IP:VNC_PORT`. Sem senha o VNC fica aberto.
(Não é a UI web noVNC do projeto original — essa depende do stack root da baseimage-gui.)

### Notas de implementação verificadas

- steam-service: subcomando `serve`, `GAME_DIR`/`SESSION_DIR` sob `/home/container`.
- Runtime .NET copiado de `/usr/share/dotnet` (a base `sdvd/server` não traz `dotnet`).
- `startapp.sh` reescrito no build (`/data/*` → `/home/container/*`) para fugir dos
  VOLUMEs root-owned.
- UID numérico (`USER 0`/`USER 1000`): a baseimage-gui não tem `root`/nomes no passwd.

### A validar conforme uso

- **UID do container**: Wings normalmente roda com uid próprio; os writes vão todos para
  `/home/container` (dono = uid de runtime), então independe do uid.
- **`SDVD_COMPOSE_REV`**: fixado em `4`; se a imagem base atualizar e o `startapp.sh`
  reclamar, bump no `entrypoint.sh`.

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
