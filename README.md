# pi-config

Personal [Pi](https://github.com/nicepkg/pi) AI assistant configuration repository. Project-level settings, model provider configuration, agent overrides, custom chains, and extension packages.

## Overview

This repo manages the configuration for Pi's subagent framework and model routing. All LLM traffic flows through a local Llama Swap gateway (`http://127.0.0.1:8080/v1`) — no external API calls. Three model families are in use:

- **qwen36-27b-mtp-q6** — primary model for most roles
- **gpt-oss-120b** — thinker and reasoner roles for deep analysis
- **qwen-image-2512-Q4_K_M** — vision role for image/design analysis

Gateway config: `.pi/agent/pi-llama-swap.json`

## Configuration

### Structure

| Level | Path | Scope |
|---|---|---|
| Project | `.pi/settings.json` | This repo only |
| User | `.pi/agent/settings.json` | All pi sessions |

### Model Roles

| Role | Model | Purpose |
|---|---|---|
| `fast` | `qwen36-27b-mtp-q6:nothinking` | Low-latency tasks |
| `strong` | `qwen36-27b-mtp-q6:thinking` | Complex reasoning |
| `thinker` | `gpt-oss-120b:thinking` | Deep analysis |
| `arbiter` | `qwen36-27b-mtp-q6:thinking` | Decision-making |
| `vision` | `qwen-image-2512-Q4_K_M` | Image/design analysis |
| `reasoner` | `gpt-oss-120b:thinking` | Security/risk analysis |

### Packages

**Project-level** (7): `pi-web-access`, `@danielmeneses/pi-llama-swap`, `@xynogen/pix-display`, `@firstpick/pi-themes-bundle` (dracula), `@firstpick/pi-package-remote-webui`, `@firstpick/pi-package-webui`, `pi-subagents`

**User-level** (3): `pi-web-access`, `@danielmeneses/pi-llama-swap`, `pi-subagents`

## Subagents

Built on [`pi-subagents`](https://github.com/nicobailon/pi-subagents) with 8 builtin agents. All use `qwen36-27b-mtp-q6` with role-specific thinking levels.

| Agent | Thinking | Purpose |
|---|---|---|
| `scout` | low/no | Codebase reconnaissance |
| `planner` | high | Implementation planning |
| `worker` | high | Sole-writer implementation |
| `reviewer` | high (read-only) | Code/plan/diff review |
| `oracle` | high | Decision-consistency advisory |
| `researcher` | — | Web research briefs |
| `context-builder` | — | Requirements-to-context handoff |
| `delegate` | inherited | Lightweight generic tasks |

## Chains

| Chain | Path | Steps |
|---|---|---|
| `update-readme` | `.pi/chains/update-readme.chain.md` | scout → worker → reviewer |

Run with `/run-chain update-readme`.

## Docs

- [`AGENTS.md`](AGENTS.md) — Full agent registry, fine-tuning strategies, and workflow patterns
