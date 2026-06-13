---
name: add-ansible-role
description: Add a new role to the user's local Ansible setup (the playbook that provisions their machine with dev tools — location is read from this skill's config.json). Use whenever the user invokes /add-ansible-role, asks to "add an ansible role for X", "add X to my ansible setup", "manage/install X with ansible", or wants a CLI tool's installation automated the way their other ansible-managed tools are. Also use when updating or fixing an existing role in that playbook.
---

# Add a role to the user's Ansible setup

## Step 0 — Locate the setup

Read `config.json` next to this SKILL.md:

```json
{
  "ansible_dir": "~/.config/nvim/ansible",
  "playbook": "nvim.yml"
}
```

`ansible_dir` is the directory holding the playbook, `roles/`, and `ansible.cfg`;
`playbook` is the main playbook filename. If `config.json` is missing, ask the user
where their ansible setup lives (or find it: a directory containing both `ansible.cfg`
and a `roles/` dir), then offer to write `config.json` so this step disappears next time.

Before writing anything, skim the playbook and one or two existing roles — match the
repo's conventions (tag naming, FQCN vs short module names, yamllint strictness) rather
than imposing your own. The guidance below describes the common shape of these personal
provisioning repos: a single playbook on `hosts: localhost`, every role listed with a
tag matching the role name, roles under `roles/<name>/` with `tasks/main.yml` and
optionally `vars/main.yml`.

## Step 1 — Pick the archetype

Nearly every role in this kind of repo is one of three shapes. Look at how the tool
ships before writing anything:

1. **GitHub release tarball** (usually the dominant pattern) → use
   `templates/tasks-github-release.yml` from this skill.
2. **System package manager** (apt/dnf/pacman/homebrew) → don't make a new role if the
   repo has a package-list role (commonly `roles/apt` or similar); append to its
   package list instead.
3. **Vendor install script** (`curl | sh`) → last resort; prefer a GitHub-release
   download whenever the project publishes binaries — the script path is hard to make
   idempotent and version-aware.

## Step 2 — Gather facts before writing (GitHub-release archetype)

Roles hardcode the release-asset filename, so get it right from the live API instead of
guessing:

```bash
curl -s https://api.github.com/repos/{owner}/{repo}/releases/latest | \
  python3 -c "import json,sys; d=json.load(sys.stdin); print(d['tag_name']); [print(a['name']) for a in d['assets']]"
```

- Pick the asset matching the **target platform**, not a hardcoded one. Check what the
  playbook runs on (`uname -sm`, or `ansible_system`/`ansible_architecture` facts for
  remote hosts) and watch for naming aliases: `x86_64` ≡ `amd64`, `aarch64` ≡ `arm64`,
  and macOS assets may say `darwin`, `macos`, or `apple-darwin`. On linux x86_64 prefer
  musl/static builds when offered. If the playbook targets more than one platform,
  build the asset name from facts (e.g. an `arch_map` var translating
  `ansible_architecture` to the project's naming) instead of hardcoding it.
- Write the asset name with `{{ version_to_install }}` substituted in — **never a
  hardcoded version**. Hardcoded asset versions are a common bug in existing roles (the
  release lookup then silently installs a stale binary forever); fix them when you find
  them, don't copy them.
- Check whether the tarball has a top-level directory (`tar -tzf` on a downloaded
  copy): bare binaries → `unarchive` straight into `~/.local/bin`; wrapped in a dir →
  extract to a `tempfile` dir, then `copy` the inner dir's contents to the destination
  and fix perms (copying out of a tempdir loses execute bits — that's why the template
  chmods afterwards).
- Destination: `~/.local/bin` for one or two binaries; `~/.local/<tool>/bin` for big
  multi-binary bundles — that also needs a PATH entry, see below.
- Confirm the version command and its output format (`<tool> --version`) — the
  template's regex extracts `x.y.z` and prefixes `v`; adjust when the project's tag
  scheme differs (e.g. llama.cpp tags are `bNNNN`, no semver to extract).

## Step 3 — Write the role

Copy `templates/tasks-github-release.yml` (bundled with this skill) to
`roles/<name>/tasks/main.yml` and fill the placeholders: `<TOOL>`, `<GH_OWNER>`,
`<GH_REPO>`, `<VERSION_CMD>`, `<ASSET_NAME>`. The template's flow — release lookup →
current-version probe → `version_to_install` (respects an optional `pinned_version`
var) → guarded install block — is what makes the roles idempotent and re-runnable;
keep it intact. The `debug` tasks look chatty but are deliberate: the playbook's output
is how the user sees what's installed vs. available.

If the tool needs a PATH addition, use `lineinfile` on the user's actual shell rc file
(`.bashrc`, `.zshrc` — check `ansible_env.SHELL` or ask; macOS defaults to zsh). A
`shell: export PATH=...` task is a silent no-op (each task runs in its own shell) —
another bug to fix on sight rather than copy:

```yaml
- name: add <tool> to PATH
  lineinfile:
    path: "{{ ansible_env.HOME }}/.bashrc"   # or .zshrc — match the user's shell
    line: 'export PATH=$PATH:{{ extra_path }}'
    create: yes
```

`vars/main.yml` holds anything machine-specific like `extra_path`.

## Step 4 — Register and verify

1. Add to the playbook's roles list (tag matches the role name; `become: true` only if
   the role writes outside $HOME — most tool installs don't):

```yaml
    - role: <name>
      tags: [<name>]
```

2. Verify, from the `ansible_dir`:

```bash
ansible-playbook <playbook> --syntax-check
ansible-playbook <playbook> --tags <name> --check   # template guards installs with 'not ansible_check_mode'
ansible-playbook <playbook> --tags <name>           # the real run
```

Runs that need `become` will prompt for a sudo password — hand those to the user to run
themselves (in Claude Code, suggest the `!` prefix) rather than attempting them. After a
successful run, verify with `<tool> --version`, then run the tag once more: a second
pass must report no changes. If it reinstalls every time, the version comparison is
broken (usually the regex or the `v` prefix) — fix that before calling it done. Offer
to commit if the directory is git-tracked, matching the repo's commit-message style.
