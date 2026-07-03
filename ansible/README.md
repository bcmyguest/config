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

ansible-galaxy install -r requirements.yml  # installs community.general + geerlingguy.docker
```

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

## lemond (lemonade-server) + Open WebUI

The AI inference stack is **opt-in** and lives in its own playbook,
`ai-inference.yml` — `nvim.yml` installs only the editor + dev toolchain. Run the
whole stack, or one piece by tag:

```
ansible-playbook ai-inference.yml --ask-become-pass               # docker + llama-cpp + lemond + openwebui
ansible-playbook ai-inference.yml --tags lemond --ask-become-pass # just lemond
```

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

## Also not installed in ansible (yet)

- chezmoi
- apt repo "universe" (needed for `libfuse2t64`; enable with
  `sudo add-apt-repository universe`)
