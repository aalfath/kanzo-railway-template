[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/kanzo?utm_medium=integration&utm_source=button&utm_campaign=kanzo)

# Kanzo on Railway

One-click [Kanzo](https://github.com/emanuele-em/kanzo) on Railway: a kanban board for you in the browser and an MCP server for your coding agents, sharing the same tasks.

- **Kanzo v0.4.2**, the upstream release binary (`kanzo-x86_64-unknown-linux-musl.tar.xz`, sha256 checked at build time). Upstream ships no container image, so this repo's `Dockerfile` downloads that pinned release.
- **Caddy 2.11.9** (`caddy:2.11.9-alpine@sha256:003a9780…`) in front of it, because Kanzo has no logins of its own:
  - the board (`/`) asks for HTTP basic auth: user `KANZO_USERNAME` (default `admin`), password `KANZO_PASSWORD` (generated);
  - the MCP endpoint (`/mcp`, streamable HTTP) needs `Authorization: Bearer <KANZO_MCP_TOKEN>` (generated);
  - `/healthz` answers without a login, for Railway's health check;
  - desktop-only actions (self-update, LAN sharing, "open in editor") are refused.
- **One volume** at `/data`: the board's SQLite database, images and `config.toml` live in `/data/kanzo`.

## Variables

| Variable | Default | What it is |
| --- | --- | --- |
| `KANZO_USERNAME` | `admin` | User name for the board's login |
| `KANZO_PASSWORD` | `${{secret(24)}}` | Password for the board (generated; see the service's Variables tab) |
| `KANZO_MCP_TOKEN` | `${{secret(40)}}` | Bearer token for agents on `/mcp` (generated) |
| `PORT` | `8080` | Port Caddy listens on; Kanzo itself stays on 127.0.0.1:4242 |

## After deploy

1. Open the service's public URL and sign in as `admin` with `KANZO_PASSWORD` from the service's **Variables** tab.
2. Create a project, then connect your agents (below). Use the board's URL to share it; Kanzo's LAN share/join and git sync are desktop features and are not needed here.

## Connect an agent

```sh
claude mcp add --transport http kanzo https://YOUR-DOMAIN/mcp --header "Authorization: Bearer YOUR-KANZO_MCP_TOKEN"
```

Other MCP clients: URL `https://YOUR-DOMAIN/mcp`, transport streamable HTTP, header `Authorization: Bearer YOUR-KANZO_MCP_TOKEN`.

## Resources

Kanzo and Caddy together use about 30 MB of RAM at rest, so the template runs on Railway's Free plan (0.5 GB per service).

## Updates

This template builds from this repo. When a new Kanzo release is out, the pin in `Dockerfile` is bumped here and the change is listed in `CHANGELOG.md`; Railway then shows an "update available" notice on your project and you choose when to apply it. Your board stays on the `/data` volume. Kanzo's own in-app updater is turned off on this deploy.

## Licence

Kanzo is AGPL-3.0 (© its authors). This wrapper only packages the unmodified upstream release.
