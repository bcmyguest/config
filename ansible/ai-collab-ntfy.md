# ai-collab ntfy server

A Docker Compose service running [ntfy](https://docs.ntfy.sh/) for the ai-collab
plugin. Deployed by `ai-collab.yml` (standalone, localhost, no sudo). It is not
run by `nvim.yml` or `ai-inference.yml`.

## Requirements

- Docker Engine running, with the **Compose v2** plugin (`docker compose version`).
- Your user can run `docker` without sudo (docker group). The play fails early with a clear message otherwise.

## Deploy

```sh
cd ~/.config/nvim/ansible
ansible-playbook ai-collab.yml --check --diff   # dry run
ansible-playbook ai-collab.yml                  # deploy or rerun (idempotent)
```

Upgrade ntfy by pinning another release tag:

```sh
ansible-playbook ai-collab.yml -e ai_collab_ntfy_version=v2.39.0
```

## Endpoint

| Item | Default |
| --- | --- |
| Client URL (`AI_COLLAB_URL`) | `http://127.0.0.1:8794` |
| Host bind | `127.0.0.1:8794` (loopback only) |
| Container | `ai-collab-ntfy`, compose project `ai-collab` |
| Health | `GET /v1/health` (unauthenticated) |

## Authentication (default: on)

- ntfy runs with `auth-file` (SQLite) and `auth-default-access: deny-all`.
- The role creates a service user, `ai-collab`, with read-write on `*` (`ai_collab_ntfy_topic_pattern`).
- It issues one token labelled `ai-collab-local` and writes it to:
  - `~/.config/ai-collab/ntfy/token`: the raw token, mode 0600
  - `~/.config/ai-collab/ntfy/client.env`: mode 0600
- Reruns reuse the token after checking it against `/v1/account`. A new token is issued only if the check fails. The old token is revoked first.
- Data (users, tokens, cache) lives in `~/.local/share/ai-collab/ntfy/`. Deleting that directory resets everything. Rerun the playbook afterward to recreate the user and token.

### Client contract

```sh
set -a; . ~/.config/ai-collab/ntfy/client.env; set +a
curl -H "Authorization: Bearer $AI_COLLAB_TOKEN" -d "hello" "$AI_COLLAB_URL/ai-collab-test"
```

- `AI_COLLAB_URL` is always set.
- `AI_COLLAB_TOKEN` is set when auth is enabled. Send it as `Authorization: Bearer <token>`.

Treat the token as a secret. Do not paste it into logs or commits.

### Turning auth off

Only for loopback. Set `-e ai_collab_ntfy_auth_enabled=false`. The role then
renders no auth config and the client env has no token. The role refuses to
disable auth on any other bind address.

## Exposure options

The default is loopback. Two opt-in routes exist. The role never changes firewall,
Tailscale, or other network settings.

### 1. Tailscale Serve (recommended for tailnet access)

Keeps ntfy on loopback. Tailscale proxies a dedicated HTTPS port to it.

```sh
ansible-playbook ai-collab.yml \
  -e ai_collab_ntfy_tailscale_serve=true \
  -e ai_collab_ntfy_client_url=https://ai-collab.<tailnet>.ts.net
```

The role validates the settings and prints the command. Run it yourself:

```sh
tailscale serve --service=svc:ai-collab --https=443 http://127.0.0.1:8794
tailscale serve status            # verify
tailscale serve --service=svc:ai-collab --https=443 off  # undo
```

Create the named Service in the Tailscale admin console and approve its advertised host. Tailscale Serve requires
auth and loopback bind; the role asserts both.

### 2. Explicit Tailscale IP bind

```sh
ansible-playbook ai-collab.yml -e ai_collab_ntfy_bind_address=100.x.y.z
```

- The address must be a real local interface address. Find it with `tailscale ip -4`.
- Auth is mandatory for any non-loopback bind.
- `0.0.0.0` is rejected.
- Traffic is plain HTTP inside the tailnet (WireGuard-encrypted).
- If Tailscale is down at container start, Docker cannot bind and the start fails.

## Operations

```sh
docker compose -p ai-collab -f ~/.config/ai-collab/ntfy/compose.yml ps
docker compose -p ai-collab -f ~/.config/ai-collab/ntfy/compose.yml logs -f ntfy
curl -s http://127.0.0.1:8794/v1/health
```

Data survives container recreation (bind mounts under `~/.local/share/ai-collab/ntfy/`).
