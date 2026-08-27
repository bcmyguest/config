# Local deployment setup using Ansible

Used to install important config for nvim

## Supported distros

`nvim.yml` runs on **Debian/Ubuntu, Fedora/RHEL and Arch** family distros (the
play asserts this up front and fails fast elsewhere). Per-distro package
management lives in `roles/packages` (`tasks/<family>.yml` +
`vars/<Family>.yml` name maps); every other role is distro-agnostic — static
GitHub release binaries and `$HOME` installs. Third-party apt repos
(spotify, microsoft, kubernetes) and PPAs are Debian-only extras; the other
families install distro packages only.

The opt-in AI stack is narrower: the `lemond` role is Ubuntu-only (Launchpad
PPA) and `llama-cpp` is x86_64-only (upstream tarball); both assert this.

Claude Code plugins for this setup live in `../claude/plugins/`; after cloning run
`../claude/install-plugins.sh` to install them.

## Installation steps

1. Install ansible and validate installation
2. Apply the ansible playbook and validate

Each step needs validation (tools are provided) before moving on.

## Prerequisites

- `pip3` (i.e. `pip` for Python 3). Don't worry about Ubuntu's pip3 not being the latest.
- `sudo` privileges

## 1. Install Ansible

1. pip and pipx are installed `--user`, so binaries ends up in `$HOME/.local/bin`. Be sure to have this prepended to your PATH.

This should be done automatically if the directory exists, only at login time though.

```
python3 -m pip install --upgrade --user pip --break-system-packages
python3 -m pip install --upgrade --user pipx --break-system-packages
```

Logout and login from your desktop environment.

2. You ready to go with ansible installation

```
pipx ensurepath
pipx install --include-deps ansible
pipx inject ansible github3.py
pipx inject ansible python-debian
```

### Ansible validation

```
ansible --version
```

This should outut something like below. Pay attention to `core 2.x.x`, which is the version and `executable location`, which should be `$HOME/.local/bin` as we just setup above.

Require **ansible-core 2.16 or newer**: the roles use `ansible.builtin.deb822_repository` (added in 2.15) and `ansible.builtin.systemd_service` (added in 2.16). Older cores will fail with "no module named ...".

```
ansible [core 2.18.6]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/gabitbol/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/gabitbol/.local/pipx/venvs/ansible/lib/python3.12/site-packages/ansible
  ansible collection location = /home/gabitbol/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/gabitbol/.local/bin/ansible
  python version = 3.12.3 (main, ...) [GCC ...]
  jinja version = 3.1.4
  libyaml = True
```

## Run ansible-playbook

`ansible-playbook` needs to be run in the `ansible/` directory, where the playbook, roles and configuration files are.

`sudo -v` is run before `ansible-playbook`, so `ansible-playbook` will not prompt you for sudo password. `sudo` won't ask for a password for 5 minutes. NEVER run `ansible-playbook` with `sudo` directly.

### Update package repositories

First we ensure that the system package repositories don't produce errors and that all packages are up-to-date. You need to be in the `ansible/` directory to run `ansible-playbook`.

```
# Debian/Ubuntu:
sudo apt-get update  # notice for failing repositories and clean them up
sudo apt-get upgrade
# Fedora/RHEL:  sudo dnf upgrade --refresh
# Arch:         sudo pacman -Syu

```

All three playbooks install their galaxy dependencies themselves — a `pre_tasks` step
runs `ansible-galaxy install -r requirements.yml` (community.general + geerlingguy.docker) —
so there is no separate step to remember. You can still run it by hand if you want to
pre-seed or refresh them:

```
ansible-galaxy install -r requirements.yml
```

One constraint worth knowing before editing the playbooks: Ansible resolves every
`roles:` entry when it *loads* the playbook, before any task runs, so a galaxy role
listed there must already be on disk. That is why `ai-inference.yml` and `coding.yml`
each pull in `geerlingguy.docker` with `include_role` in `pre_tasks` (resolved at task
runtime, after the install) instead of listing it under `roles:`.

No errors should occur on the update command.

### Run ansible-playbook

Remember, you need to be in the `ansible/` directory to run `ansible-playbook`.

```
ansible-playbook nvim.yml --ask-become-pass
```

## Update provided packages or ansible configuration

```
ansible-playbook nvim.yml --check --diff --ask-become-pass  # Facultative, shows what will be done
ansible-playbook nvim.yml --ask-become-pass
```

## Python virtualenvs (mise, not direnv)

The `mise` role turns on mise's uv integration globally, so there is no direnv and no
per-project `.envrc`:

```toml
# ~/.config/mise/config.toml — written by roles/mise
[settings.python]
uv_venv_auto = "source"
```

`cd` into a project that has a `uv.lock` and its `.venv` is activated automatically
(`VIRTUAL_ENV` set, `.venv/bin` prepended to `PATH`); `cd` out and it is deactivated.
`"source"` only activates an existing venv — it never creates one, so entering a
directory has no side effects and `uv sync` / `uv run` still own venv creation.
Directories without a `uv.lock` are left completely alone.

This relies on the `eval "$(mise activate bash)"` line the role adds to `~/.bashrc`;
mise's shims alone do not activate a venv.

## Shell completions

The `shell-completions` role (`--tags shell-completions`) generates a completion
script per tool, per shell, from the installed binaries on every run — so they
track tool upgrades instead of rotting as checked-in copies. It runs last in
`nvim.yml` for that reason. Everything is in `$HOME`, so no `become` is needed.

The shell is data, not structure: `roles/shell-completions/vars/main.yml`
describes each shell and each tool, and the role loops over the (tool × shell)
matrix. **Only shells actually installed are touched**, so this box (bash only)
generates bash and silently skips the rest.

| shell | destination | wiring |
| ----- | ----------- | ------ |
| bash (autoload) | `~/.local/share/bash-completion/completions/<tool>` | none — the loader finds it |
| bash (fallback) | `~/.bashrc.d/<tool>-completion.bash` | source loop added to `~/.bashrc` |
| zsh | `~/.zsh/completions/_<tool>` | dir prepended to `$fpath` in `~/.zshrc` |
| fish | `~/.config/fish/completions/<tool>.fish` | none — fish autoloads it |

bash gets two possible destinations because it is the only one of the three that
does not read a completions directory on its own. Where the bash-completion
package's dynamic loader is available, a script in its XDG dir is read on the
*first Tab for that command* and costs nothing before that. Where it is not, the
scripts have to be sourced at every shell start instead.

Which one is used is probed, not assumed — the loader is only wired up in
interactive shells, so the role asks one:

```
bash -ic 'declare -F _comp_load >/dev/null || declare -F __load_completion >/dev/null'
```

The two names are the same function either side of bash-completion 2.12. Sourcing
at startup is not cheap: the scripts here total ~700 KB and cost ~25–30 ms on
every interactive shell, so autoloading is preferred wherever it works. A box that
switches over is migrated automatically — the old copies are deleted, and once
`~/.bashrc.d` is empty the role retires its own `~/.bashrc` block and removes the
directory. Anything else left in there is respected and the loop stays.

One wrinkle only autoloading has: the loader looks for a file named after the
command being typed, so a script that completes *several* commands needs the extra
names as symlinks beside it. `kitty` is one case — its script also completes
`kitten`, `edit-in-kitty` and `clone-in-kitty`, which the role links (`aliases` in
the vars file). `ansible` and `llama-server` are the others: one generated script
covers each tool's whole family of commands. A sourced script registers every name
by itself and needs no links.

Covered: `mise`, `fnox`, `uv`, `uvx`, `rustup`, `cargo`, `gh`, `grepai`,
`opencode`, `zed`, `kitty`, `ansible`, plus `docker` from `ai-inference.yml`/`coding.yml`
and `llama-server` from `ai-inference.yml`. Each tool declares which shells its generator genuinely supports,
because three of them do not support all three — `rustup completions fish cargo`
exits 1 (`cargo does not currently support completions for fish`), `opencode`
ignores its shell argument entirely, returning a byte-identical bash script for
all three, and `llama-server` offers only a `--completion-bash` flag. Each is also gated on its required binaries being on PATH, so the role
skips (and cleans up after) anything not installed; a missing tool never fails
the play. `glab` is listed but skipped here because it isn't installed. The vars
file records why `rtk`, `codegraph`, `claude`, `lemonade`/`lemond` and
`open-webui` are absent (no working generator).

`ansible` is the one tool whose completions come from outside the tool: its CLIs
call `argcomplete.autocomplete()`, and argcomplete's `register-python-argcomplete`
emits the script. That needs argcomplete importable *inside the pipx venv ansible
runs from*, not just on PATH — `ansible/cli/__init__.py` wraps the import in a
try/except and skips autocomplete() when it fails, so without it the script
installs cleanly and every Tab returns nothing. The `packages` role installs it
there (`ansible.builtin.pip`), alongside the distro `python3-argcomplete` package
that supplies the generator binary.

`mise` needs two things beyond the generator, both handled:

- the `usage` CLI ([usage.jdx.dev](https://usage.jdx.dev)) at *runtime* — mise's
  script shells out to `usage complete-word` on every Tab press and only prints
  an error without it. The `mise` role pins it globally for this reason.
- `--include-bash-completion-lib`, which bundles the `_comp_initialize` /
  `_comp_compgen` helpers into the bash script. Without it the completion errors
  even when `usage` is present. This stays on under autoloading too, even though
  the loader *is* bash-completion: those two helpers are 2.12 names and Ubuntu
  ships 2.11, which only has `_init_completion`. Dropping the flag there gives a
  function that loads and then dies with `_comp_initialize: command not found`.

`fnox` is jdx's other usage-cli tool and hits the same two problems, but only
has a fix for the first: it needs `usage` at runtime just like mise, and its
generated bash script calls the same 2.12-only helpers — yet `fnox completion
bash` exposes no `--include-bash-completion-lib` of its own. The way out is to
generate through the `usage` CLI instead, which carries the flag generically and
takes the spec from the tool via `--usage-cmd`:

```
usage generate completion bash fnox --usage-cmd "fnox usage" --include-bash-completion-lib
```

That stays pure argv, so it drops into the vars file with no shell pipeline.
`fnox completion zsh|fish` is used unchanged — the helper problem is bash-only.

Note that `usage` is installed as a mise *shim*, which is only on `PATH` after
`mise activate` has run in an interactive shell. Ansible inherits the
non-interactive `PATH`, so the role prepends `~/.local/share/mise/shims`
explicitly — otherwise mise completions get skipped on a machine where they work
fine.

New completions only appear in shells started after the run; `exec bash` picks
them up in an existing one. Under autoloading, `complete -p <tool>` is empty until
the first Tab for that command — that is the mechanism working, not a failure.

## lemond (lemonade-server) + Open WebUI

The AI inference stack is **opt-in** and lives in its own playbook,
`ai-inference.yml` — `nvim.yml` installs only the editor + dev toolchain. Run the
whole stack, or one piece by tag:

```
ansible-playbook ai-inference.yml --ask-become-pass               # docker + llama-cpp + lemond + openwebui + grepai
ansible-playbook ai-inference.yml --tags lemond --ask-become-pass # just lemond
```

Other coding-agent tooling (`codegraph`, `milacoder`) lives in its own opt-in
playbook, `coding.yml`, alongside docker:

```
ansible-playbook coding.yml --ask-become-pass               # docker + codegraph + milacoder
ansible-playbook coding.yml --tags milacoder                # Mila coding CLI (no sudo)
```

`milacoder` is opt-in: private GitHub releases via `gh`, soft-skips when this
machine has no access to `mila-studios/mila-coder`. Needs `gh` + Node/npm from
`nvim.yml` (`--tags gh,mise`). After install run `milacoder setup` by hand.

ollama is not installed by ansible; drop `../ollama.service.d/override.conf` into
the ollama unit by hand if you run it.

lemond is installed by the `lemond` role (`--tags lemond`); full service docs in
[docs/lemond.md](docs/lemond.md), ROCm/GPU notes in
[docs/rocm-strix-halo.md](docs/rocm-strix-halo.md).

Open WebUI is the chat frontend for lemond, managed by the `openwebui` role
(`--tags openwebui`). The role pulls `ghcr.io/open-webui/open-webui:main` and runs it as
a docker container with host networking and a named `open-webui` data volume,
recreating it only when the image updates (the volume survives, so settings persist).
Equivalent manual command:

```
docker run -d --name open-webui --network host --restart always \
  -e OLLAMA_BASE_URL=http://0.0.0.0:11434 \
  -v open-webui:/app/backend/data \
  ghcr.io/open-webui/open-webui:main
```

- UI: `http://<host>:8080`
- The lemond connection is configured **inside the UI**, not via env vars:
  Admin Settings → Connections → OpenAI API → base URL
  `http://localhost:13305/api/v1` (API key can be any non-empty string unless
  `LEMONADE_API_KEY` is set on lemond). This setting lives in the `open-webui`
  docker volume, so it survives container recreation but is NOT in this repo.
- ollama models appear via the `OLLAMA_BASE_URL` env above; lemond models appear via
  the OpenAI connection. If lemond models vanish from the picker, see the port-race
  gotcha in [docs/lemond.md](docs/lemond.md).
- Host networking means the container reaches lemond on plain `localhost:13305`.
- Docker (`geerlingguy.docker` role) must be installed first; the `openwebui` role talks
  to docker as root, so it runs with `become`.

## work.yml (personal workspace)

Opt-in, not run by `nvim.yml`:

```
ansible-playbook work.yml
```

**gitconfig** applies the settings in `roles/gitconfig/vars/main.yml` with
`git config --global` (`community.general.git_config`), not by templating the
whole file — so anything else already in `~/.gitconfig` (credential helpers,
`gh`'s own entries, ...) is left alone. Note `commit.gpgsign = true` in there:
commits fail until a signing key is actually configured
(`user.signingkey`/`gpg.format`).

**work-repos** clones a fixed list of repos into `~/work/<group>/<repo>`
(`group` is the GitHub owner) via the `gh` CLI rather than the git module, so
private repos work off the same gh auth `milacoder` already relies on (`gh
auth login`) — no SSH key setup needed. A repo already on disk is never
pulled or reset, and a repo this gh account can't see is soft-skipped (same
pattern as `milacoder`). The repo list lives in
`roles/work-repos/vars/main.yml`; add an entry there to clone/alias another
one. Aliases (`<repo>` cds into it) are written to `~/.bashrc.d/git`, sourced
from `~/.bashrc` via its own managed block — deliberately not
`shell-completions`' bashrc.d loop, since that one only sources `*.bash` and
is retired entirely on a box where bash autoloads completions.

**obsidian** unpacks the upstream Obsidian Linux tarball into
`~/.local/obsidian` (no sudo), with a `~/.local/bin/obsidian` launcher and a
desktop entry. Two things to know: the version comes from the repo's
`desktop-releases.json` manifest, not from GitHub's "latest release" — Obsidian
cuts Android-only releases (v1.13.8 shipped an `.apk` and nothing else) whose
tag has no Linux tarball — and the launcher passes `--no-sandbox`, because the
bundled `chrome-sandbox` has to be setuid root and a no-sudo install cannot do
that (the raw binary aborts otherwise). The tarball is preferred over the
AppImage so nothing depends on FUSE/`libfuse2t64`. Pin a version with
`-e obsidian_pinned_version=1.13.7`.

## Also not installed in ansible (yet)

- chezmoi
- apt repo "universe" (needed for `libfuse2t64`; enable with
  `sudo add-apt-repository universe`)
