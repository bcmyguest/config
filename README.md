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

```
docker run -v /home/b/.cache/llama.cpp/:/models -p 8000:8000 ghcr.io/ggml-org/llama.cpp:server-vulkan --port 8000 --host 0.0.0.0 -n 512 -m "/models/ggml-org_gemma-3-1b-it-GGUF_gemma-3-1b-it-Q4_K_M.gguf"

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

## docker 

manually installed 


