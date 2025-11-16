[[_TOC_]]

## Installing nvim

Install nvim with [ansible](./ansible/README.md) or manually.

Install lua with [ansible](./ansible/README.md) or [manually](https://github.com/luarocks/luarocks/blob/main/docs/installation_instructions_for_unix.md).

## Basic structure

This repo is structured like this

```
├── init.lua
├── lazy-lock.json
├── lua
│   ├── config
│   │   ├── <plugin_config>.lua
│   └── plugins
│       ├── <plugin>.lua
└── README.md

```

- `init.lua` is the main entry point for nvim. It loads all the plugins and configurations.
- `lazy-lock.json` is the lock file for lazy.nvim. It is analogous to `package-lock.json` or `yarn.lock`, and is automatically updated by lazy.nvim.
- `lua/plugins` contains the plugin files. You can add your own plugins here (try to keep this minimal).
- `lua/config` contains the configuration files for the plugins. You can add your own configurations here.

Note: If you nest your plugins in a subdirectory, you need to properly import them in [lazy.nvim config](./lua/config/lazy.lua)

## Plugins

Lazy.nvim is used as the plugin manager. It is installed automatically when you run `nvim` for the first time. You can run it manually with the command (from inside nvim):

```lua
:Lazy
```

## LSP

Language servers are also installed for you by `Mason`. You can download or update them with the command (from inside nvim):

```lua
:Mason
```

Note: if you want them to be persistent or want to configured them, use [lsp config](./lua/config/lsp.lua) to do so.

## Keymaps

Keymaps are defined in [mappings.lua](./lua/config/mappings.lua) and the [mappings subdirectory](./lua/config/mappings/). You can change them there. You can also search for them with `<Space>gl` (which is the same as the `Telescope keymaps` command).

## Colorscheme

Right now the theme is set by `galaxyline` in [here](./lua/config/spec.lua). You can change this, you can also add a theme like the `catpuccin` theme in [here](./lua/config/theme.lua).

## open-webui

need ollama running (docker run --restart always)

https://docs.ollama.com/faq#how-can-i-allow-additional-web-origins-to-access-ollama
https://github.com/open-webui/open-webui

```bash
docker run -d -p 3000:8080 -e OLLAMA_BASE_URL=http://0.0.0.0:11434 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:ollama -e HOST='0.0.0.0'
```


## llama.cpp

https://github.com/ggml-org/llama.cpp/blob/master/docs/docker.md
https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/3rd-party/previous-versions/llama-cpp-install-v25.9.html#using-docker-with-llama-cpp-pre-installed
```
docker run --privileged \
           --network=host \
           --device=/dev/kfd \
           --device=/dev/dri \
           --group-add video \
           --cap-add=SYS_PTRACE \
           --security-opt seccomp=unconfined \
           --ipc=host \
           --shm-size 16G \
           -v $MODEL_PATH:/data \
           rocm/llama.cpp:<TAG>_server \
             -m /data/DeepSeek-V3-Q4_K_M-00001-of-00009.gguf \
             --port 8000 --host 0.0.0.0 -n 512 --n-gpu-layers 999
```
my command:
```
docker run -v /home/b/.cache/llama.cpp/:/models --privileged --network=host --cap-add=SYS_PTRACE --cap-add=SYS_PTRACE --group-add video --device=/dev/kfd --device=/dev/dri  -p 8000:8000 ghcr.io/ggml-org/llama.cpp:server-vulkan --port 8000 --host 0.0.0.0 -n 512 -ngl 999 -m "/models/ggml-org_Qwen2.5-Coder-7B-Q8_0-GGUF_qwen2.5-coder-7b-q8_0.gguf" -ub 1024 -b 1024 --ctx-size 0 --cache-reuse 256
```
from the docs:
```
# Use a local model file
llama-cli -m my_model.gguf

# Or download and run a model directly from Hugging Face
llama-cli -hf ggml-org/gemma-3-1b-it-GGUF

# Launch OpenAI-compatible API server
llama-server -hf ggml-org/gemma-3-1b-it-GGUF
```

```
llama-server -m /home/b/.cache/llama.cpp/ggml-org_Qwen3-Coder-30B-A3B-Instruct-Q8_0-GGUF_qwen3-coder-30b-a3b-instruct-q8_0.gguf -ngl 99 -ub 1024 -b 1024 --ctx-size 0 --cache-reuse 256 --port 8012 --host 127.0.0.1

```
## docker 

manually installed 
https://docs.docker.com/engine/install/ubuntu/

## amd gpu drivers
https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/quick-start.html
```
wget https://repo.radeon.com/amdgpu-install/7.1/ubuntu/noble/amdgpu-install_7.1.70100-1_all.deb
sudo apt install ./amdgpu-install_7.1.70100-1_all.deb
sudo apt update
sudo apt install python3-setuptools python3-wheel
sudo usermod -a -G render,video $LOGNAME # Add the current user to the render and video groups
sudo apt install rocm


wget https://repo.radeon.com/amdgpu-install/7.1/ubuntu/noble/amdgpu-install_7.1.70100-1_all.deb
sudo apt install ./amdgpu-install_7.1.70100-1_all.deb
sudo apt update
sudo apt install "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)"
sudo apt install amdgpu-dkms
```

then 

https://rocm.docs.amd.com/projects/amdsmi/en/latest/install/install.html


then 

```
python3 -m pip install argcomplete
activate-global-python-argcomplete --user
```



