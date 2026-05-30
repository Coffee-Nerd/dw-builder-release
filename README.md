# DarkWiz Area Builder

A web-based builder for Dark Wizardry MUD area files. Browser UI plus an
optional MCP server so Claude Code / Codex can drive the build directly.

This repo contains the public install descriptor — the application itself
ships as pre-built Docker images on GitHub Container Registry. **No source
checkout required.**

---

## Install — `docker compose up -d`

Prereqs: Docker Desktop (Windows / macOS) or Docker Engine + Compose
plugin (Linux). Two minutes total.

```bash
# 1. Grab the compose file (~2 KB).
mkdir dw-builder && cd dw-builder
curl -O https://raw.githubusercontent.com/Coffee-Nerd/dw-builder-release/main/docker-compose.yml

# 2. (Optional) override defaults — port, image tag — via .env.
curl -O https://raw.githubusercontent.com/Coffee-Nerd/dw-builder-release/main/.env.example
mv .env.example .env   # edit if you want different ports

# 3. Pull and start.
docker compose up -d

# 4. Open http://localhost
```

That's the whole install. The `docker compose` step pulls two images
(~300MB combined) and stands up the frontend on port 80, backend on
port 8000.

To stop: `docker compose down`. To update later: `docker compose pull && docker compose up -d`.

---

## What you get

- **Browser UI** at `http://localhost` — full area editing: rooms, mobs,
  objects, resets, mobprogs, shops, the lot. Live `look`-style preview
  matching how players see each room in-game. Validate, export to MUD
  JSON, restore from server.
- **Backend API** on port 8000 — FastAPI; the frontend talks to it.
  Areas persist to a Docker volume (`dw_areas`) so a `docker compose
  down/up` cycle doesn't lose your work.
- **Bring-your-own AI keys** — OpenAI, Gemini, or Grok. Keys stay in
  your browser's localStorage; the server never sees them. You pay
  your own provider directly.

The optional **MCP server** (lets Claude Code / Codex build areas via
agent) lives in the source repo and isn't packaged in the Docker
images. Install separately if you want agentic editing — see the MCP
README in the source distribution.

---

## Configuration

All optional. Drop a `.env` next to `docker-compose.yml`:

| Variable | Default | What it does |
|---|---|---|
| `FRONTEND_PORT` | `80` | Where the web UI is served. Change if port 80 is taken. |
| `BACKEND_PORT` | `8000` | API port. Frontend's nginx proxies `/api/` here. |
| `IMAGE_TAG` | `latest` | Pin to a specific release (`v0.1.0`) for reproducible installs. |

---

## Updates

```bash
docker compose pull        # fetch new images
docker compose up -d       # restart with new versions
```

Pinning to a specific tag (`IMAGE_TAG=v0.1.0` in `.env`) is recommended
if you want predictable update points. The default `latest` will track
every release.

Releases: <https://github.com/Coffee-Nerd/Dark-Wizardry-Area-Builder/releases>
(if the source repo is private, releases there will be too — watch this
README for major-version migration notes).

---

## Troubleshooting

**"Port 80 already in use"**
Set `FRONTEND_PORT=8080` in `.env`, run `docker compose up -d`, browse
to `http://localhost:8080`.

**"Containers won't start / health check failing"**
Check logs: `docker compose logs backend` and `docker compose logs frontend`.
Most common cause is a stale image — `docker compose pull` then `up -d`.

**"My area JSON disappeared after `docker compose down`"**
The `dw_areas` volume should survive `down`. It does NOT survive
`docker compose down --volumes`. If you ran that by mistake, the data
is gone — there's no automatic backup. (Future: backup-to-host CLI
command.)

**"Where do I get the source?"**
Source is currently private. Contact the maintainer via GitHub if you
need code access (security audit, integration work, etc.). The public
images are otherwise the complete distribution.

---

## License

See LICENSE in the source repo (visible to source-access holders).
The container images themselves are distributed as-is for the purpose
of running an instance.
