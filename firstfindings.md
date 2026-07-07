# First Findings — Pi Configuration Audit

## 1. README.md — Project Overview

The project is a **Pi configuration** that integrates with **llama-swap** for dynamic, hot-swappable local LLM model loading. Key documented features:

- **Dynamic model loading** via llama-swap (models loaded on-demand)
- **Hot-swapping** between models without restart
- **Subagent system** via `@tintinweb/pi-subagents` extension
- Requires 4 Pi extensions: `pi-subagents`, `pi-web-access`, `pi-coding-agent`, and `pi-llama-swap`

The README lists 8 scoped models (`codestral-22b-q8`, `gemma12q5`, `gemma26`, `gemma31q4/q6/q8/qat`, `qwen35-9b-q4`) — **these don't match the actual llama-swap config** (see inconsistency below).

## 2. AGENTS.md — Agentic Workflow

Defines a strict **5-stage pipeline** with Separation of Concerns:

`User Request → Orchestrator → Explore/Researcher → Architect → Plan → Coder → Orchestrator → Completion`

Six custom agents are defined with clear roles and constraints:

| Agent | Role | Model | Constraint |
|---|---|---|---|
| **Orchestrator** | Manager/delegator | `gemma26` | NEVER does tasks itself |
| **Explore** | Fast scout | `gemma31q4` | Read-only, no synthesis |
| **Researcher** | Deep context gatherer | `gemma31q4` | Read-only, no code edits |
| **Architect** | System designer | `gemma31q4` | Advisory only, high thinking |
| **Plan** | Step-by-step strategist | `gemma31q4` | Read-only, must list critical files |
| **Coder** | Pure implementer | `gemma31q4` | Requires a plan, no refactoring |

Plus a `general-purpose` agent (disabled in frontmatter).

## 3. subagents.json — Runtime Settings

- `maxConcurrent: 2` — max 2 agents running simultaneously
- `defaultMaxTurns: 0` — unlimited turns by default
- `schedulingEnabled: true` — cron/scheduled tasks supported
- `scopeModels: false` — models not auto-scoped per-agent
- `disableDefaultAgents: false` — built-in agents still available
- `fleetView: true`, `widgetMode: "background"`

## 4. llama-swap/config.yaml — Model Registry

**Active models** (commented-out ones excluded):

| Alias | Model File | Quant | GPU | Context | Notes |
|---|---|---|---|---|---|
| `gemma31q4` | gemma-4-31B-it | Q4_K_M | GPU 0 | 262K | MTP speculative, thinking modes |
| `gemma26` | gemma-4-26B-A4B-it-QAT | Q4_0 | GPU 1 | 131K | MTP, thinking modes, QAT-trained |
| `codestral-22b-q8` | Codestral-22B-v0.1 | Q8_0 | GPU 0 | 16K | Code model |
| `qwen36-a3b-q4` | Qwen3.6-35B-A3B | Q4_K_M | GPU 0 | 262K | Mixture-of-experts |
| `qwen36-a3b-q6` | Qwen3.6-35B-A3B | Q6_K | GPU 0 | 131K | Thinking modes, preserve_thinking |
| `qwen36-27b-mtp-q3` | Qwen3.6-27B-MTP | Q3_K_S | GPU 0 | 262K | MTP, thinking modes, reasoning_effort |
| `ornith-1.0-9B` | Ornith-1.0-9B | Q6_K | GPU 0 | 262K | Reinforcement-trained |
| `qwen-image-2512-Q4_K_M` | Qwen-Image-2512 (diffusion) | Q4_K_M | — | — | Image generation (sd-server) |

**Routing group**: `"clever"` group keeps `qwen36-27b-mtp-q3` + `gemma26` simultaneously loaded (`swap: false, exclusive: false`).

**Thinking modes**: gemma31q4, gemma26, qwen36-a3b-q6, and qwen36-27b-mtp-q3 support `:thinking` / `:nothinking` suffix variants that toggle reasoning budgets (4096 tokens) and temperature.

## 🔴 Inconsistencies Found

1. **README lists `qwen35-9b-q4` and `gemma12q5`** — these are **commented out** (disabled) in the actual llama-swap config. The README model list is outdated.
2. **README doesn't mention** `qwen36-a3b-q4`, `qwen36-a3b-q6`, `qwen36-27b-mtp-q3`, `ornith-1.0-9B`, or `qwen-image-2512-Q4_K_M` — all active in config.
3. **README shows single-GPU docker run** (`--device /dev/dri:/dev/dri`) but the config assigns models across **two GPUs** (`main-gpu 0` and `main-gpu 1`), implying a dual-GPU setup.
4. **README describes a simpler subagent setup** (just Explore + worker) vs. the actual 6-agent pipeline defined in AGENTS.md.
