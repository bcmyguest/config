# ROCm on Strix Halo (gfx1151) — setup checklist

Ordered list distilled from the AMD docs (links at each step), plus what this specific
machine has taught us.

> **For agents/automation:** every command in this doc that needs `sudo` — and
> `amd-ttm`, which changes boot-time memory config — is for **Brandon to run himself**.
> Print the command and ask him to run it (in Claude Code: with the `!` prefix); never
> execute it directly.

> **Status on this machine (last verified 2026-06-12):**
> The path taken here: **amdgpu-dkms removed, mainline kernel instead of OEM** (in-tree
> amdgpu driver). The dkms module lacked the CWSR export and shadows the kernel's own
> driver — see the initramfs gotcha below. ROCm 7.2.4 userspace is installed and
> `torch.cuda.is_available()` returns True, but **actual GPU compute still page-faults**
> (`GCVM_L2_PROTECTION_FAULT`, client `CPF`, in dmesg; the process hangs) — observed on
> HWE `6.17.0-35-generic` and mainline `6.18.35`, both newer than AMD's stated minimums.
> Until that resolves, everything GPU runs on Vulkan (RADV), which is fine.
> Quick repro test (hang = broken; never run without timeout):
> `timeout 60 python3 -c "import torch; x=torch.ones(1024,1024,device='cuda'); print((x@x).sum().item())"`

## 1. Prerequisites

<https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/prerequisites.html>

1. Kernel: AMD's stated minimums for gfx1151 — Ubuntu 24.04 HWE `6.17.0-19.19~24.04.2`+,
   OEM `6.14.0-1018`+, other distros `6.18.4`+. This box uses a **mainline** kernel
   (6.18.x) rather than OEM. (See status box: meeting the minimum has not been
   sufficient in practice here.)
2. `sudo apt install python3-setuptools python3-wheel`
3. GPU access for your user: `sudo usermod -a -G video,render $LOGNAME` (re-login after)
4. Secure Boot: disabled, or be prepared to sign kernel modules.

## 2. Install ROCm (userspace)

<https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/quick-start.html#installing>

First **look up the current amdgpu-install version** — don't reuse a version number
from an old doc (this one included). The quick-start page above always shows the
current one, or list <https://repo.radeon.com/amdgpu-install/> for available versions.
Then, substituting the looked-up `<VER>`/`<DEB>`:

```bash
wget https://repo.radeon.com/amdgpu-install/<VER>/ubuntu/noble/<DEB>
sudo apt install ./<DEB>
sudo apt update
sudo apt install rocm
sudo reboot
```

**Skip `amdgpu-dkms` on this machine.** The quick-start lists it as the kernel-driver
step, but here it was deliberately removed in favor of the in-tree driver from a recent
mainline kernel (the dkms build lacked the CWSR export needed for gfx1151 compute).

## 3. Removing the dkms kernel driver (what was actually done here)

<https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/quick-start.html#uninstall-kernel-driver>

```bash
sudo apt autoremove amdgpu-dkms
sudo update-initramfs -u -k all
sudo reboot
```

**The initramfs step is not in AMD's doc and is not optional** — learned the hard way:
a stale dkms module baked into the initrd keeps loading and silently shadows the
in-tree driver even after the package is gone.

## 4. Post-install

<https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/post-install.html>

```bash
# linker paths
sudo tee --append /etc/ld.so.conf.d/rocm.conf <<EOF
/opt/rocm/lib
/opt/rocm/lib64
EOF
sudo ldconfig
# PATH (pick one; update-alternatives is simplest)
sudo update-alternatives --config rocm
# verify (safe to run unprivileged)
rocminfo | grep -i "Marketing Name:"
clinfo | grep -i "Board name:"
amd-smi version
```

`rocminfo` succeeding is **not** proof compute works — run the torch matmul repro from
the status box; that's the real test on this machine.

## 5. Memory tuning for the APU (applies to Vulkan too)

<https://rocm.docs.amd.com/en/latest/how-to/system-optimization/rdna3-5.html>

Unified-memory APU: keep the BIOS VRAM carve-out **small** (ours is 0.5 GB — correct,
leave it) and give user apps memory via the shared GTT limit instead (defaults to ~50%
of RAM; with 128 GB that caps GPU-usable memory at ~64 GB).

```bash
pipx install amd-debug-tools
amd-ttm                 # query current GTT/TTM (read-only, safe)
amd-ttm --set <GB>      # user-run only — changes boot config; e.g. 96–110 on this box
sudo reboot             # required after --set
```

## Related

- lemonade-specific gfx1151 notes: <https://lemonade-server.ai/gfx1151_linux.html>
  (lemonade gates its ROCm llama.cpp backend behind a CWSR kernel check and falls back
  to Vulkan — on this box that fallback is correct and expected).
- Local service docs: `docs/lemond.md`. Debugging runbook: Claude skill `/debug-lemonade`.
