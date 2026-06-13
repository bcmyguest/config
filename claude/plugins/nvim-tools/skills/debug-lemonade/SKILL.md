---
name: debug-lemonade
description: Diagnose lemonade-server (lemond) problems on the user's Strix Halo box "d" — server not responding on port 13305, models missing from Open WebUI, a model failing to load, slow inference, or ROCm/Vulkan/GPU questions. Use whenever the user invokes /debug-lemonade or reports anything broken or weird with lemonade, lemond, Open WebUI models, llama.cpp backends, GPU page faults, or "models gone" on this machine, even if they don't name lemonade explicitly (e.g. "open webui shows no models", "the model won't load", "inference hangs").
---

# Debug lemonade on Strix Halo

This box has a known topology and a few recurring failure modes. Diagnose in this order —
each step is cheap and rules out a whole class before touching anything privileged.
`sudo` needs a password: when a privileged command is required, ask the user to run it
with the `!` prefix instead of attempting it.

## Topology (machine "d")

- AMD Strix Halo (gfx1151) APU, 128 GB unified RAM, Ubuntu 24.04. GPU compute runs on
  **Vulkan** (RADV); ROCm compute has been broken on most kernels (see GPU section).
- `lemond` = lemonade-server **system** service: runs as user `lemonade`, port **13305**,
  config `/var/lib/lemonade/config.json`, models in `/var/lib/lemonade/.cache/lemonade`
  and `/var/lib/lemonade/.cache/huggingface`. Not readable by user b — journal/API only.
- lemond manages its own pinned llama.cpp builds (`<cache>/bin/llamacpp/<backend>`) and
  spawns `llama-server` children on 127.0.0.1:8001+. It cannot see /home (ProtectHome)
  and cannot use the user's pip vllm.
- Open WebUI on :8080 is just a frontend for lemond; ollama is separate on :11434.
- User's own llama.cpp lives at `~/.local/llama-cpp/bin/` — useful as a control to test
  whether a GGUF/architecture works independently of lemond.
- The package ships BOTH a system unit and a user unit. The user unit must stay
  **masked** (`systemctl --user status lemond` → masked) or the two race for port 13305
  at boot; the loser lingers as a portless zombie and Open WebUI shows zero models
  (user instance has an empty cache at `~/.cache/lemonade`).

## Step 1 — Is the right lemond up?

```bash
curl -s -m 5 http://127.0.0.1:13305/api/v1/health   # status, version, loaded models, backend pids/ports
pgrep -a lemond                                      # exactly ONE instance expected
systemctl --user is-enabled lemond 2>&1              # must say "masked"
```

- Health OK but Open WebUI empty / wrong models → suspect the user-unit race came back
  (check which user owns the lemond pid; fix is re-masking the user unit + restart).
- No response → `journalctl -u lemond -n 50` (may need `! sudo journalctl -u lemond -n 50`).
  A failed bind is caught by the ExecStartPost health-check override in
  `/etc/systemd/system/lemond.service.d/override.conf`; Restart=always should retry.

## Step 2 — Model won't load

```bash
curl -s http://127.0.0.1:13305/api/v1/models   # registered? downloaded:true?
curl -s -X POST http://127.0.0.1:13305/api/v1/load -H "Content-Type: application/json" \
  -d '{"model_name":"<id>"}'                   # reproduces the error
```

"llama-server failed to start" usually means the pinned llama.cpp rejects the model, not
a lemond bug. Distinguish by trying the same GGUF (or same architecture) under the user's
own newer build: `~/.local/llama-cpp/bin/llama-server -m <gguf> --port 8099 -ngl 99 --no-warmup`.
- User's build loads it → lemond's pinned build is too old; wait for/force a lemonade update.
- Neither loads it → architecture unsupported upstream (known case: **DiffusionGemma**
  needs a diffusion sampler that llama-server doesn't have — tracked on `/watchlist`;
  do not burn time retrying it).
- Also rule out OOM: a 26B Q4 needs ~17 GB; check `free -g` and what's already loaded
  (`max_models` allows 1 LLM at a time — loading a second unloads the first).

## Step 3 — GPU / performance

ROCm compute on this box page-faults on most kernels (GCVM_L2_PROTECTION_FAULT, client
CPF, on ANY compute — confirmed broken on 6.17.0-35-generic AND mainline 6.18.35, despite
docs claiming 6.18.4+ fixes it). Known-good combo: ROCm 7.2.4 + amdgpu-dkms 6.16.13.
Repro test (hang = broken; never run without timeout):

```bash
timeout 60 python3 -c "import torch; x=torch.ones(1024,1024,device='cuda'); print((x@x).sum().item())"
journalctl -k -n 30   # look for amdgpu GCVM_L2_PROTECTION_FAULT
```

Consequently lemonade gating ROCm llama.cpp → **Vulkan is expected and fine**, not a bug.
Calibration: gemma-4-26B-A4B Q4_K_M does ~51 tok/s gen / ~1100 tok/s pp512 on Vulkan
(`-fa 1`), which is memory-bandwidth parity with a DGX Spark — don't chase "low" tok/s
in that range. Genuinely slow inference → check the model spilled to CPU (llama-server
log device lines), GTT size (`amd-ttm`, BIOS carve-out stays small ~0.5 GB), and thermal
throttling.

## Step 4 — Escalation map

- lemond bug ↔ llama.cpp bug: reproduce with the user's own build to assign blame.
- Architecture/feature gaps upstream: add to `/watchlist` rather than re-investigating.
- Kernel/ROCm changes are system-state changes: summarize evidence and let the user
  decide; the dkms-vs-kernel matrix has burned days before. Refs:
  https://lemonade-server.ai/gfx1151_linux.html and
  https://rocm.docs.amd.com/en/latest/how-to/system-optimization/rdna3-5.html
