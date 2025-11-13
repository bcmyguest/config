# Local deployment setup using Ansible

Used to install important config for nvim

Note: Most of this is copied from 1511/spectra-apps>

[[_TOC_]]

## Installation steps

The two first these steps are described below

1. Install ansible and validate installation
2. Apply the ansible playbook and validate
3. Create a minikube cluster and validate
4. Install all charts and validate

Each steps needs validation (tools are provided) before jumping on the next steps.

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

```
ansible [core 2.13.9]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/gabitbol/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/gabitbol/.local/pipx/venvs/ansible/lib/python3.8/site-packages/ansible
  ansible collection location = /home/gabitbol/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/gabitbol/.local/bin/ansible
  python version = 3.8.10 (default, May 26 2023, 14:05:08) [GCC 9.4.0]
  jinja version = 3.1.1
  libyaml = True
```

## Run ansible-playbook

`ansible-playbook` needs to be run in the `ansible/` directory, where the playbook, roles and configuration files are.

`sudo -v` is run before `ansible-playbook`, so `ansible-playbook` will not prompt you for sudo password. `sudo` won't ask for a password for 5 minutes. NEVER run `ansible-playbook` with `sudo` directly.

### Update apt repositories

First we ensure that apt repositories don't produce errors and that all packages are up-to-date. You need to be in the `ansible/` directory to run `ansible-playbook`.

```
sudo apt-get update  # notice for failing repositories and clean them up
sudo apt-get upgrade
ansible-galaxy role install geerlingguy.docker
```

No errors should occur on the last `apt-get update` command.

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

