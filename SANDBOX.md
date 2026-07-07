# Docker SBX Sandboxes

This document describes the Docker SBX sandbox configuration for the pi coding agent ecosystem. Sandboxes provide isolated environments for running the pi coding agent and supporting services.

## Overview

Docker SBX (Sandbox) uses **Kits** — structured YAML `spec.yaml` files — to define reusable sandbox templates. Each kit can be a:

- **Sandbox kit** (`kind: sandbox`) — defines a full environment from scratch (image, entrypoint, network, commands)
- **Mixin kit** (`kind: mixin`) — extends an existing agent with extra capabilities

## Architecture

```
┌─────────────────────────┐         ┌─────────────────────────┐
│    llama_sbx            │         │       pi_sbx            │
│                         │         │                         │
│  /models (host mount)   │         │  pi-coding-agent        │
│  /config/config.yaml    │         │  └─ pi-taskflow         │
│  GPU: Vulkan            │         │  └─ pi-web-access       │
│  Port: 8080 ◄───────────┼────────►│  └─ pi-llama-swap       │
│                         │         │  LLAMA_SWAP_URL=        │
│  exec llama-swap        │         │  http://127.0.0.1:8080  │
└─────────────────────────┘         └─────────────────────────┘
```

The **llama-swap sandbox** provides local model switching via the llama-swap server on port 8080. The **pi sandbox** runs the pi coding agent and connects to llama-swap for dynamic model discovery and switching.

## Quick Start

### 1. Start the llama-swap sandbox (model server)

```bash
sbx run --kit /home/sephirot/projects/pi-config/llama_sbx/ llama-swap \
  -v /home/sephirot/.lmstudio/models/:/models \
  -v /home/sephirot/projects/pi-config/llama-swap/config.yaml:/config/config.yaml
```

### 2. Start the pi sandbox (coding agent)

```bash
sbx run --kit /home/sephirot/projects/pi-config/pi_sbx/ pi
```

## Sandbox: llama-swap

**Location:** `/home/sephirot/projects/pi-config/llama_sbx/spec.yaml`

### Configuration

| Field | Value |
|-------|-------|
| **Image** | `ghcr.io/mostlygeek/llama-swap:unified-vulkan` |
| **GPU** | Vulkan via `/dev/dri` |
| **Port** | `8080` |
| **Models path** | `/models` (injected at startup) |
| **Config path** | `/config/config.yaml` (injected at startup) |

### Startup Behavior

The sandbox runs the following startup sequence:

1. **Install** (run once at creation):
   - Install `curl` via `apt-get`
   - Create `/config` and `/models` directories

2. **Startup** (run each time the sandbox starts):
   - Log injection points (GPU, models path, config path, port)
   - List mounted directories
   - Execute `llama-swap --config /config/config.yaml`

### Runtime Mounts

| Host Path | Container Path | Purpose |
|-----------|----------------|---------|
| `/home/sephirot/.lmstudio/models/` | `/models` | GGUF model files |
| `/home/sephirot/projects/pi-config/llama-swap/config.yaml` | `/config/config.yaml` | Llama-swap configuration |

### Network Policy

```yaml
caps:
  network:
    allow:
      - "*"
```

All outbound domains are allowed to support model downloads and API calls.

## Sandbox: pi

**Location:** `/home/sephirot/projects/pi-config/pi_sbx/spec.yaml`

### Configuration

| Field | Value |
|-------|-------|
| **Image** | `docker/sandbox-templates:shell` |
| **Entrypoint** | `["pi"]` |
| **AI Filename** | `PI.md` |
| **Llama-Swap URL** | `http://127.0.0.1:8080` |

### Extensions Installed

| Extension | Install Method | Description |
|-----------|---------------|-------------|
| **pi-coding-agent** | `npm install -g` | Core coding harness |
| **pi-taskflow** | `pi install npm:pi-taskflow` | Multi-phase agent workflow orchestrator |
| **pi-web-access** | `pi install npm:pi-web-access` | Web search, URL fetching, GitHub, video analysis |
| **pi-llama-swap** | `git clone` + `npm install` | Dynamic model switching via llama-swap |

### Startup Behavior

The sandbox runs the following startup sequence:

1. **Install** (run once at creation):
   - Install system dependencies: `bash`, `ca-certificates`, `git`, `ripgrep`
   - Install `pi-coding-agent` globally via npm
   - Install `pi-taskflow` and `pi-web-access` via `pi install`

2. **Startup** (run each time the sandbox starts):
   - Clone `@danielmeneses/pi-llama-swap` from GitHub (if not already present)
   - Run `npm install` in the extension directory
   - Log startup status

### Network Policy

```yaml
caps:
  network:
    allow:
      - "registry.npmjs.org"
      - "*.npmjs.org"
      - "github.com"
      - "*.githubusercontent.com"
      - "127.0.0.1"
      - "10.*"
      - "192.168.*"
      - "172.16.*"
```

Allowed domains:
- **npm registries** — for extension installs
- **GitHub** — for cloning `pi-llama-swap` extension
- **localhost** — for connecting to llama-swap
- **private IPs** — for local network access

### Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `LLAMA_SWAP_URL` | `http://127.0.0.1:8080` | Llama-swap server endpoint |
| `LLAMA_SWAP_PORT` | `8080` | Llama-swap server port |

## Kit Specification Reference

### Directory Structure

Each sandbox kit follows this structure:

```
<kit-name>/
└── spec.yaml          # Kit specification (required)
└── files/             # Optional static files to inject
    ├── home/          # Files written to /home/agent/
    └── workspace/     # Files written to the workspace
```

### spec.yaml Schema

```yaml
schemaVersion: "1"        # Required: spec version
kind: sandbox             # Required: "sandbox" or "mixin"
name: <identifier>        # Required: unique, lowercase, hyphens
displayName: <name>       # Optional: human-readable name
description: <text>       # Optional: short description

sandbox:                  # Required for kind: sandbox
  image: <docker-image>   # Base image
  entrypoint:             # Override entrypoint
    run: [cmd, arg1, arg2]
  aiFilename: <filename>  # Agent memory filename

commands:
  install:                # Run once at sandbox creation
    - user: "0"           # "0" = root, "1000" = agent
      command: |
        shell command here
  startup:                # Run each sandbox start
    - user: "1000"
      command:
        - sh
        - -c
        - |
          startup command here

environment:
  variables:
    KEY: "value"

caps:
  network:
    allow:                # Allowed domains (wildcards supported)
      - "*.example.com"
    deny:                 # Denied domains (deny takes precedence)
      - "telemetry.example.com"

agentContext: |             # Agent memory content (markdown)
  Instructions for the agent...
```

## Maintenance

### Rebuilding a Sandbox

```bash
# Recreate the llama-swap sandbox
sbx rm llama-swap && sbx run --kit /home/sephirot/projects/pi-config/llama_sbx/ llama-swap

# Recreate the pi sandbox
sbx rm pi && sbx run --kit /home/sephirot/projects/pi-config/pi_sbx/ pi
```

### Validating a Kit

```bash
sbx kit validate /home/sephirot/projects/pi-config/llama_sbx/
sbx kit validate /home/sephirot/projects/pi-config/pi_sbx/
```

### Updating Extensions

The `pi-llama-swap` extension is cloned at sandbox startup. To update:

```bash
# Recreate the pi sandbox to pull the latest extension
sbx rm pi && sbx run --kit /home/sephirot/projects/pi-config/pi_sbx/ pi
```

### Troubleshooting

| Issue | Solution |
|-------|----------|
| Llama-swap not reachable from pi sandbox | Verify llama-swap sandbox is running; check `LLAMA_SWAP_URL` env var |
| Models not loading | Verify `-v` mount paths are correct; check `/models/` contents inside sandbox |
| Extension install fails | Check network policy allows `github.com` and `registry.npmjs.org` |
| GPU not available | Verify host has Vulkan drivers; check `/dev/dri` is accessible |

## Related Documents

- [AGENTS.md](AGENTS.md) — Agent registry and workflow definitions
- [CONFIG.md](CONFIG.md) — Llama-swap model configuration
- [DOCUMENTATION_STANDARDS.md](DOCUMENTATION_STANDARDS.md) — Documentation guidelines
