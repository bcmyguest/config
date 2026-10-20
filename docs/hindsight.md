# Local Hindsight memory (ansible + personal-memory)

**personal-memory owns setup.** The `./setup` wizard (`scripts/wizard.sh`) configures Docker,
LiteLLM routes (including **`memory-reflect`**), secrets, indexing, and the coding-agent config
link. Per-machine defaults live in **`~/personal-memory/config/machine.env`** (from
`config/machine.env.example`, gitignored).

Ansible only **clones** `~/personal-memory` and runs **`scripts/run-setup.sh`**, which starts
`./setup` on a TTY or prints the command to run by hand.

## Work laptop flow

```bash
ansible-playbook ~/.config/nvim/ansible/work.yml --tags hindsight   # clone + docker check

cd ~/personal-memory
cp config/machine.env.example config/machine.env
$EDITOR config/machine.env    # e.g. PM_BACKEND=custom, Meridian base URL, PM_REFLECT_MODEL
./setup                        # guided wizard
```

After the first run, `~/.config/hindsight/wizard.conf` remembers choices. Re-run `./setup` to
change backend or routes; edit **`~/.config/hindsight/litellm.yaml`** for a quick reflect-only
tweak, then `docker compose up -d litellm`.

## Agent hooks

`work.yml --tags agent-cli` wires the Hindsight coding-agent plugin (Cursor, Claude, Codex).
The wizard can install the plugin too (step 7); either path is fine.

## Reflect / Meridian

Reflect uses the **`memory-reflect`** alias in LiteLLM. The wizard asks for a **separate reflect
model** on lemond/ollama/custom backends. For [Meridian](https://github.com/rynfar/meridian), pick
**custom** backend, set base URL `http://host.docker.internal:3456/v1`, and choose a model from
Meridian’s `/v1/models` — Meridian must be running on the host.

Details: `~/personal-memory/README.md` (Model configuration).

## Verify

```bash
curl -fsS http://127.0.0.1:8888/health
```

Plugin reflect log: `~/.hindsight/coding-agents-logs/diag.jsonl`.
