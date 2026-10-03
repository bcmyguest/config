# lemond (lemonade-server) setup

Local LLM server on this machine (Strix Halo / gfx1151, 128 GB unified RAM). Installed
and configured by the `lemond` ansible role:
`ansible-playbook nvim.yml --tags lemond --ask-become-pass`

## What runs where

| Thing | Where |
|---|---|
| lemond API (OpenAI-compatible) | `http://<host>:13305/api/v1` — published on **0.0.0.0** (LAN-reachable) |
| Health check | `http://localhost:13305/api/v1/health` |
| Open WebUI (frontend) | `http://<host>:8080` (docker, host network) |
| ollama (separate, unrelated) | `http://localhost:11434` |
| llama.cpp backends lemond spawns | `127.0.0.1:8001+` (managed, don't touch) |

- Package: `lemonade-server` from `ppa:lemonade-team/stable`.
- Runs as the **system** service `lemond.service`, user `lemonade`.
- Server settings (host, port, …) live in `/var/lib/lemonade/config.json` — NOT env
  vars. The role merges `host: 0.0.0.0` into that file; without it lemond binds
  127.0.0.1 only. Env vars in `/etc/lemonade/conf.d/*.conf` are only for `HF_TOKEN`,
  `LEMONADE_API_KEY`, `LEMONADE_ADMIN_API_KEY`.
- **Security note:** binding 0.0.0.0 exposes an unauthenticated LLM API to the LAN.
  If that ever matters, set `LEMONADE_API_KEY` in `/etc/lemonade/conf.d/`.
- Models live in `/var/lib/lemonade/.cache/lemonade` and
  `/var/lib/lemonade/.cache/huggingface`. Not readable by normal users — inspect via
  the API or `journalctl -u lemond`.
- lemond downloads and manages its own pinned llama.cpp builds
  (`<cache>/bin/llamacpp/<backend>`). It runs them on **Vulkan**: ROCm compute is broken
  on most kernels for gfx1151 (see `docs/rocm-strix-halo.md`). Vulkan performance is at
  memory-bandwidth parity — don't chase it.
- The service has `ProtectHome=yes`: it cannot see anything under `/home`.

## The two gotchas the role guards against

1. **Port race / "all my models are gone".** The deb ships both a system unit and an
   enabled-by-default *user* unit — the user unit is what causes the port conflict.
   Both try to bind 13305 at boot; the loser stays alive as a portless zombie. When the
   user instance wins, Open WebUI shows an empty model list because the user instance
   has its own empty cache (`~/.cache/lemonade`). Fix the role applies: the user unit
   is masked per-user (`systemctl --user mask lemond`, i.e.
   `~/.config/systemd/user/lemond.service → /dev/null`). If models ever vanish again,
   first check `pgrep -a lemond` — there must be exactly one.

2. **Silent bind failure.** lemond does not exit when it fails to bind, so systemd would
   consider the unit healthy while nothing serves. The role installs
   `/etc/systemd/system/lemond.service.d/override.conf` with an `ExecStartPost` curl
   probe that polls for up to 60 s: a failed bind now fails the unit and `Restart=always` retries.

## Day-to-day

```bash
curl -s localhost:13305/api/v1/health | jq    # version, loaded model, backend pids
curl -s localhost:13305/api/v1/models | jq '.data[].id'
journalctl -u lemond -f                       # logs (sudo)
sudo systemctl restart lemond
```

Pin a version by setting `lemond_pinned_version` (apt version string, e.g.
`10.7.0~24.04`) when running the role; otherwise the PPA's latest is installed.

For deeper debugging (model won't load, GPU faults, slow inference) there's a Claude
skill: `/debug-lemonade`.

## Suffix Cache Reuse (vllm recipe)

`tasks/vllm_scr.yml` (tag `lemond-scr`, on by default via `lemond_vllm_scr_enabled`)
wires the `vllm_scr` plugin from `~/clm/serving/vllm_scr` into lemond's `vllm` recipe:

- Checks the bundled vLLM (`/var/cache/lemonade/bin/vllm/rocm`): `bin/vllm-server` exists, `import torch, vllm` works, and file sizes match the wheel
  RECORD sizes. A disk-full extraction on 2026-09-07 truncated 8 files (torch could
  not import); on a mismatch the role deletes the bundle and runs
  `lemonade backends install vllm:rocm` (about 9.6 GB).
- Installs the plugin and its wrapper in `/opt/vllm-scr` (root:lemonade). It cannot
  live under `/home`: the unit's `ProtectHome=yes` hides `/home` from lemond whatever
  the file permissions.
- Moves `QuantTrio/Qwen3.6-35B-A3B-AWQ` from `~/.cache/huggingface/hub` into
  lemond's HF cache and chowns it to `lemonade`.
- With lemond stopped (it rewrites `user_models.json` on shutdown): sets
  `vllm.rocm_bin` to the wrapper and registers `user.Qwen3.6-35B-A3B-AWQ-SCR`
  (ctx 131072). `.bak` files are kept beside each JSON file.

`vllm.rocm_bin` applies to every vllm-recipe model. `KVREUSE_ENABLED=0` in lemond's
environment turns SCR off without removing the wrapper. The model needs about 36 GB;
load it only when that much GPU memory is free.

Three traps found on 2026-10-02:
- lemond writes `version.txt` before extracting, so an interrupted install still
  shows as `installed` in `lemonade backends`. Only the role's import check catches it.
- With `vllm.rocm_bin` set, `lemonade backends install vllm:rocm` returns at once
  without downloading. The role unsets it for the reinstall.
- 2026.40.0 moves `/var/lib/lemonade/.cache/lemonade` into `/var/cache/lemonade` on its
  first start. The old `sleep 3` health check killed lemond mid-move and split the vLLM
  bundle in two; the probe now polls for 60 s.

## CLM model with llama.cpp cache reuse

`tasks/models.yml` (tags `lemond-models`, `lemond-scr`) merges `lemond_config_extra`,
`lemond_user_models` and `lemond_recipe_options` from `vars/main.yml` into lemond's JSON
files (with lemond stopped, only when they differ), then `lemonade pull`s
`lemond_pull_models`. It registers `user.Qwen3-Coder-30B-A3B-CLM` for OpenCode's CLM
plugin, with `--cache-reuse 256`: llama.cpp shifts the KV of chunks that survive a
CLM edit instead of re-prefilling them. llama.cpp disables cache reuse for
recurrent/hybrid models (Qwen3.6 `qwen35moe`, Qwen3.8 `qwen4exp`: "cache_reuse is not
supported by this context") and whenever an mmproj is loaded, so the CLM model has to be
pure-attention and text-only. `max_loaded_models: 2` keeps it loaded beside
jev-debugger's Flash-Next.
