# Agent Registry & Workflow

This project uses **pi-taskflow** for workflow orchestration. The complete agent registry, pipeline definitions, and usage guide are in [`agents.tf`](./agents.tf).

## Quick Reference

### Pipelines (saved flows)

| Pipeline | Command | Use when |
|---|---|---|
| Standard Complex | `/tf:pipeline-standard` | Multi-step feature implementation requiring full discover→plan→execute→review→verify |
| High-Risk Backend | `/tf:pipeline-high-risk` | Backend changes with adversarial critique + parallel risk/security review |
| Quick Fix | `/tf:pipeline-quick-fix` | ≤2 files, ≤50 lines, no new files — typo corrections, config changes, mechanical cleanup |
| UI/Frontend | `/tf:pipeline-ui` | Design-driven UI changes using vision model for visual fidelity |

### Running a Pipeline

```
/taskflow run name:pipeline-standard args:{request:"implement feature X"}
```

### Agent Overview

18 built-in taskflow agents grouped by function:

- **Discovery**: `scout`, `visual-explorer`
- **Analysis**: `analyst`, `critic`
- **Planning**: `planner`, `plan-arbiter`
- **Execution**: `executor`, `executor-code`, `executor-fast`, `executor-ui`, `test-engineer`, `doc-writer`, `recover`
- **Review**: `reviewer`, `security-reviewer`, `risk-reviewer`, `verifier`, `final-arbiter`

See [`agents.tf`](./agents.tf) for full descriptions, model assignments, tools, and pipeline definitions.

## Model Roles

Defined in `.pi/agent/settings.json` — edit to tune which model each agent class uses:

| Role | Purpose | Default Model |
|---|---|---|
| `fast` | Low-latency tasks (recon, quick edits, verification) | `llama-swap/qwen3-coder-next:nothinking` |
| `strong` | Complex reasoning (planning, general review) | `llama-swap/qwen3-coder-next:thinking` |
| `thinker` | Deep analysis (requirements, adversarial challenge) | `llama-swap/qwen36-27b-q8:thinking` |
| `arbiter` | Decision-making, conflict resolution | `llama-swap/qwen36-27b-q8:thinking` |
| `vision` | Image and design analysis (UI tasks) | `llama-swap/qwen3-coder-next:thinking` |
| `reasoner` | Security and risk analysis | `llama-swap/qwen36-27b-q8:thinking` |

## Guidelines

### Choosing a Pipeline

- **Quick fix** (≤2 files, ≤50 lines, no architectural impact): `pipeline-quick-fix`
- **Standard feature** (1–4 files, clear scope): `pipeline-standard`
- **Complex refactor** (≥5 files, cross-module): `pipeline-high-risk`
- **UI/styling changes**: `pipeline-ui`
- **Custom workflow**: use taskflow DSL (`chain`, `parallel`, `map`, `gate`) to compose agents

### Adding Custom Agents

1. Create a Markdown file in `.pi/agents/` (project-local) or `~/.pi/agent/agents/` (global).
2. Include YAML frontmatter: `name`, `description`, `model` (a `modelRoles` key), `tools` (array).
3. Define clear **Role & Constraints** in the body to prevent overlap.
4. Reference by name in taskflow phases: `"agent": "my-agent"`.

### Evidence-First Mandate

All reviewer agents must:
1. Ground analysis in files/code/context already passed between phases
2. Read minimally — only when a specific claim can't be verified
3. Cite specific files and lines for every finding
4. State what's missing rather than guessing
