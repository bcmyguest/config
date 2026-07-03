# Manual machine setup notes (non-nvim)

Legacy manual notes moved out of the main README — the supported path for all of
this is now the ansible playbooks (see [ansible/README.md](../ansible/README.md)):
`nvim.yml` for the editor toolchain, `ai-inference.yml` for docker + llama.cpp +
lemond + Open WebUI. Service docs live in [ansible/docs/lemond.md](../ansible/docs/lemond.md)
and [ansible/docs/rocm-strix-halo.md](../ansible/docs/rocm-strix-halo.md).

Kept here: the manual commands that predate the roles, for reference/debugging.

## open-webui (manual docker run)

Needs ollama running (`docker run --restart always`).

- https://docs.ollama.com/faq#how-can-i-allow-additional-web-origins-to-access-ollama
- https://github.com/open-webui/open-webui

```bash
docker run -d -p 8080:8080 -e HOST='0.0.0.0' -e OLLAMA_BASE_URL=http://0.0.0.0:11434 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
```

This one with network mode host seems to work better:

```bash
docker run -d -p 8080:8080 --network=host -e HOST='0.0.0.0' -e OLLAMA_BASE_URL=http://0.0.0.0:11434 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
```

To update the docker image:

```bash
docker pull ghcr.io/open-webui/open-webui:main
```

## llama.cpp

- https://github.com/ggml-org/llama.cpp/blob/master/docs/docker.md
- https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/3rd-party/previous-versions/llama-cpp-install-v25.9.html#using-docker-with-llama-cpp-pre-installed

```bash
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

My command:

```bash
docker run -v /home/b/.cache/llama.cpp/:/models --privileged --network=host --cap-add=SYS_PTRACE --group-add video --device=/dev/kfd --device=/dev/dri -p 8000:8000 ghcr.io/ggml-org/llama.cpp:server-vulkan --port 8000 --host 0.0.0.0 -n 512 -ngl 999 -m "/models/ggml-org_Qwen2.5-Coder-7B-Q8_0-GGUF_qwen2.5-coder-7b-q8_0.gguf" -ub 1024 -b 1024 --ctx-size 0 --cache-reuse 256
```

From the docs:

```bash
# Use a local model file
llama-cli -m my_model.gguf

# Or download and run a model directly from Hugging Face
llama-cli -hf ggml-org/gemma-3-1b-it-GGUF

# Launch OpenAI-compatible API server
llama-server -hf ggml-org/gemma-3-1b-it-GGUF
```

```bash
llama-server -m /home/b/.cache/llama.cpp/ggml-org_Qwen3-Coder-30B-A3B-Instruct-Q8_0-GGUF_qwen3-coder-30b-a3b-instruct-q8_0.gguf -ngl 99 -ub 1024 -b 1024 --ctx-size 0 --cache-reuse 256 --port 8012 --host 127.0.0.1
```

## docker

Manually installed: https://docs.docker.com/engine/install/ubuntu/
(now also available via the `geerlingguy.docker` role in `ai-inference.yml`)

## amd gpu drivers

https://rocm.docs.amd.com/projects/install-on-linux/en/latest/install/quick-start.html
(see also [ansible/docs/rocm-strix-halo.md](../ansible/docs/rocm-strix-halo.md))

```bash
wget https://repo.radeon.com/amdgpu-install/7.1/ubuntu/noble/amdgpu-install_7.1.70100-1_all.deb
sudo apt install ./amdgpu-install_7.1.70100-1_all.deb
sudo apt update
sudo apt install python3-setuptools python3-wheel
sudo usermod -a -G render,video $LOGNAME # Add the current user to the render and video groups
sudo apt install rocm

sudo apt install "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)"
sudo apt install amdgpu-dkms
```

Then: https://rocm.docs.amd.com/projects/amdsmi/en/latest/install/install.html

Then:

```bash
python3 -m pip install argcomplete
activate-global-python-argcomplete --user
```
