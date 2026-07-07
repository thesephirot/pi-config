# Pi Configuration

A professional configuration setup for [Pi](https://pi.dev/), an AI-powered development environment that integrates with [llama-swap](https://github.com/mostlygeek/llama-swap) for dynamic model loading.

---

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites: Llama-Swap](#prerequisites-llama-swap)
- [Installing Pi](#installing-pi)
- [Pi Extensions](#pi-extensions)
- [Subagents Configuration](#subagents-configuration)

---

## Introduction

Pi is an AI-powered development environment that enables you to work with multiple LLM models seamlessly. This configuration integrates Pi with llama-swap for dynamic model loading and hot-swapping capabilities.

### Key Features

- **Dynamic Model Loading**: Models are loaded on-demand using llama-swap
- **Hot-Swapping**: Seamlessly switch between different models without restarting
- **Multi-Model Support**: Configure and use multiple models simultaneously
- **Subagent System**: Customize your development environment with specialized agents

---

## Prerequisites: Llama-Swap

Before setting up Pi, ensure you have [llama-swap](https://github.com/mostlygeek/llama-swap) configured and running. Llama-swap provides the foundation for dynamic model loading.

### Setup Llama-Swap

1. **Clone and configure llama-swap**:

   ```bash
   git clone https://github.com/mostlygeek/llama-swap.git
   cd llama-swap
   ```

2. **Configure your models**:

   Edit the llama-swap configuration to align model locations and startup parameters:

   ```yaml
   # ./llama-swap/config.yaml
    models:
      gemma31q4:
        cmd: llama-server --port ${PORT} --model /models/lmstudio-community/gemma-4-31B-it-GGUF/gemma-4-31B-it-Q4_K_M.gguf --n-gpu-layers 999 --ctx-size 262144 --host 0.0.0.0  --temp 0.1 --top-p 0.95 --top-k 64 --split-mode none --main-gpu 0
   ```

3. **Configure model groups** (optional):

   Groups define concurrency settings for multiple models. If not configured, llama-swap defaults to 1:1 model swapping.

### Start Llama-Swap Server

Use Docker to run the llama-swap server with your configuration:

```bash
export ARCH=vulkan
docker run -it --rm \
  -p 8080:8080 \
  --device /dev/dri:/dev/dri \
  -v ${HOME}/.lmstudio/models/:/models \
  -v $(pwd)/llama-swap/config.yaml:/etc/llama-swap/config/config.yaml \
  ghcr.io/mostlygeek/llama-swap:unified-${ARCH}
```

### Verify Installation

Connect to the web interface at [localhost:8080](http://localhost:8080) to ensure llama-swap is running correctly.

### Test Multiple Models

You can test multiple models—they should hot-swap as configured in `config.yaml`.

---

## Installing Pi

Once llama-swap is running, install Pi using the official installer:

```bash
curl -fsSL https://pi.dev/install.sh | bash
```

For more information, visit the [Pi documentation](https://pi.dev/).

---

## Pi Extensions

Install the necessary Pi extensions to enable subagents and coding capabilities:

```bash
pi install npm:@tintinweb/pi-subagents
pi install npm:pi-web-access
pi install npm:@earendil-works/pi-coding-agent
pi install npm:@danielmeneses/pi-llama-swap
```

### Llama-Swap Integration

Once the `pi-llama-swap` extension is loaded, no additional configuration is needed. The integration is automatic.

### Start Pi

Ensure llama-swap is running, then start Pi:

```bash
pi
```

### Configure Scoped Models

Select the models you want to automatically enable in Pi:

```bash
/scoped-models
```

Available models (from llama-swap):

```
Model Configuration
Session-only. ctrl+s to save to settings.

  codestral-22b-q8 [llama-swap]
  gemma26 [llama-swap]
  gemma31q4 [llama-swap]
  ornith-1.0-9B [llama-swap]
  qwen36-a3b-q4 [llama-swap]
  qwen36-a3b-q6 [llama-swap]
  qwen36-27b-mtp-q3 [llama-swap]
  qwen-image-2512-Q4_K_M [llama-swap]
```

### Select Your Model

Choose the actual model you want to use:

```bash
/model
```

---

## Subagents Configuration

Configure your local `.pi` directory with subagent definitions.

### Setup Subagents

Copy the subagent configuration to your `.pi` directory:

```bash
mkdir -p .pi
cp -r ./pi-subagents/* .pi
```

Directory structure:

```
.pi/
├── agents/
│   ├── orchestrator.md
│   ├── explore.md
│   ├── researcher.md
│   ├── architect.md
│   ├── plan.md
│   ├── coder.md
│   └── general-purpose.md
└── subagents.json
```

### Agent Descriptions

Put a description of every agent in its own markdown file. For example, the coder agent:

```markdown
# Coder Agent

The coder agent handles code implementation, file editing, and task execution.
```

### Configure Subagents

Reload Pi or restart it, then configure your subagents:

```bash
/agents
```

Available agent types:

- **Project**: Local to your current project
- **Global**: Available across all projects
- **Disabled**: Turned off

Agent hierarchy:

```
Agent types
• = project  ◦ = global  ✕ = disabled

→    general-purpose  inherit
  ✕• explore          inherit
  •  architect        qwen36-27b-mtp-q3:thinking
  •  plan             qwen36-27b-mtp-q3:thinking
  •  researcher       gemma26:thinking
  •  coder            gemma31q4
  •  orchestrator     gemma26:thinking
```

### Test Your Configuration

Test the subagent system:

```bash
hey, please review the readme and format it pretty. use coder to do the actual work.
```

This tests the orchestrator→coder delegation chain. Success = the readme gets formatted by the coder agent (not done directly by Pi). Check the fleet view (`/agents`) to confirm the orchestrator spawned the coder.

---

## Troubleshooting

### Llama-Swap Not Responding
- Verify the container is running: `docker ps | grep llama-swap`
- Check port mapping: the Docker `-p 8080:8080` flag must match the port in Pi's model configuration
- Check logs: `docker logs <container-name>` for model loading errors
- Ensure `${PORT}` in llama-swap's `config.yaml` matches the port Pi expects (default `8080`)

### Agent Not Spawning
- Verify the agent `.md` file exists in `.pi/agents/` and has valid YAML frontmatter
- Check `/agents` output — disabled agents show as `✕` and won't be selected
- Ensure `scopeModels` is set correctly in `subagents.json` (see [CONFIG.md](./CONFIG.md))
- If the agent specifies a model that doesn't exist in llama-swap, spawning will fail

### Model Loading Errors
- Verify the model `.gguf` file exists at the path specified in llama-swap's `config.yaml`
- Check GPU memory: large models (31B+) need sufficient VRAM — reduce `--n-gpu-layers` if OOM
- For Vulkan: ensure `/dev/dri` device is accessible inside the container
- For CUDA: ensure the correct NVIDIA drivers are installed on the host

### Subagent Workflow Hangs
- Check `graceTurns` setting in `subagents.json` — if too low, agents get terminated before finishing
- Check `maxConcurrent` — if set to `1`, parallel tasks queue up sequentially
- Use `/agents` to see if subagents are stuck in `in_progress` state
- Increase `defaultMaxTurns` if agents are running out of turns before completing their work

### `${PORT}` Variable

The llama-swap `config.yaml` uses `${PORT}` as a placeholder for the server port. When running Docker, ensure the port in your config matches the `-p` mapping. To avoid confusion, you can replace `${PORT}` with the literal port number (e.g., `8080`):

```yaml
models:
  gemma31q4:
    cmd: llama-server --port 8080 --model /models/... --n-gpu-layers 999 --ctx-size 262144
```

---

## Quick Reference

### Common Commands

| Command | Description |
|---------|-------------|
| `pi` | Start Pi |
| `/scoped-models` | List available models |
| `/model` | Select active model |
| `/agents` | Configure subagents |
| `pi install npm:<package>` | Install a Pi extension |

### Architecture Notes

- **GPU Acceleration**: Use `--device /dev/dri:/dev/dri` for GPU support
- **Model Paths**: Point to your model directory (e.g., `~/.lmstudio/models/`)
- **Config Path**: Mount your llama-swap config to `/etc/llama-swap/config/config.yaml`

---

## License

This configuration is provided as-is for use with Pi and llama-swap.
