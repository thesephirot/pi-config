# Taskflow Prompt Templates

Copy-paste-ready taskflow definitions for every capability.

## Shorthand (no DSL needed)

| Template | Use when |
|----------|----------|
| [01-single.md](./01-single.md) | One agent, one task |
| [02-parallel.md](./02-parallel.md) | 2–6 independent tasks at once |
| [03-chain.md](./03-chain.md) | Sequential steps, each feeding the next |

## DSL Phase Templates

| Template | Phase Type |
|----------|-----------|
| [10-agent.md](./10-agent.md) | `agent` — single work step |
| [11-parallel.md](./11-parallel.md) | `parallel` — static branches |
| [12-map.md](./12-map.md) | `map` — fan-out over a list |
| [13-gate.md](./13-gate.md) | `gate` — review that can halt |
| [14-reduce.md](./14-reduce.md) | `reduce` — aggregate outputs |
| [15-approval.md](./15-approval.md) | `approval` — human-in-the-loop |
| [16-loop.md](./16-loop.md) | `loop` — iterate until done |
| [17-tournament.md](./17-tournament.md) | `tournament` — N variants, judge picks best |
| [18-script.md](./18-script.md) | `script` — shell command, zero tokens |
| [19-flow.md](./19-flow.md) | `flow` — sub-flow inside a phase |

## Full Archetypes

| Template | Pattern |
|----------|---------|
| [20-discover-audit-report.md](./20-discover-audit-report.md) | discover → map → gate → reduce |
| [21-plan-approve-execute.md](./21-plan-approve-execute.md) | plan → human approval → execute |
| [22-generate-critique-regen.md](./22-generate-critique-regen.md) | self-healing rework loop |
| [23-conditional-routing.md](./23-conditional-routing.md) | triage → branch → merge |

## How to Use

1. Open the template you need.
2. Replace the `...` placeholders with your task, agents, paths.
3. Paste the JSONC block into `taskflow` with `action: "run"` and `define: { ... }`.
4. For anything non-trivial, `action: "verify"` first (zero tokens).
