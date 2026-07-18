# Taskflow Pipeline Library

Reusable taskflow pipelines for common workflows. Each pipeline is defined as a fenced JSON block that can be verified (`action: "verify", defineFile: "..."`) and saved (`action: "save"`) into `.pi/taskflows/<name>.json`.

## Model Roles (from `settings.json`)

| Role | Purpose | Default Model |
|---|---|---|
| `fast` | Low-latency, high-throughput tasks (recon, quick edits, verification) | `qwen3-coder-next:nothinking` |
| `strong` | Complex reasoning with moderate latency (planning, general review) | `qwen3-coder-next:thinking` |
| `thinker` | Deep analysis with extended thinking (requirements, adversarial challenge) | `qwen36-27b-q8:thinking` |
| `arbiter` | Decision-making and conflict resolution | `qwen36-27b-q8:thinking` |
| `vision` | Image and design analysis (UI tasks, Figma context) | `qwen3-coder-next:thinking` |
| `reasoner` | Security and risk analysis with structured reasoning | `qwen36-27b-q8:thinking` |

## Built-in Agent Registry

### Discovery

| Agent | Role | Model | Thinking | Tools | When to use |
|---|---|---|---|---|---|
| `scout` | The Recon | `fast` | off | read, grep, find, ls, bash | Fast codebase reconnaissance. Returns compressed context for handoff. "Map the auth module", "List all API routes". |
| `visual-explorer` | The Designer's Eye | `vision` | high | read, grep, find, ls | Analyzes Figma design metadata, extracts tokens from visual context. Frontend/UI tasks with design references or screenshots. |

### Analysis

| Agent | Role | Model | Thinking | Tools | When to use |
|---|---|---|---|---|---|
| `analyst` | The Analyst | `thinker` | high | read, grep, find, ls, bash | Requirements analysis: identifies knowns, unknowns, assumptions, constraints, acceptance criteria. "What needs to change for X?", "What are the risks of Y?". Used before planning. |
| `critic` | The Adversary | `thinker` | xhigh | read, grep, find, ls | Adversarial challenge: disproves weak plans, finds contradictions, challenges hidden assumptions. After a plan is drafted but before execution. "Is this plan actually sound?" |

### Planning

| Agent | Role | Model | Thinking | Tools | When to use |
|---|---|---|---|---|---|
| `planner` | The Strategist | `strong` | high | read, grep, find, ls | Creates concrete implementation plans with ordered steps, affected files, risk analysis, acceptance criteria. "Create a plan to implement feature X." |
| `plan-arbiter` | The Gatekeeper | `arbiter` | high | read, grep, find, ls | Reviews plans before execution: catches bad assumptions, scope creep, missing risks. Outputs VERDICT: PASS or BLOCK. Gate phase after `planner`; prevents executing flawed plans. |

### Execution

| Agent | Role | Model | Thinking | Tools | When to use |
|---|---|---|---|---|---|
| `executor` | The Default Builder | `fast` | high | read, grep, find, ls, bash, edit, write | Default executor for 1–4 file changes with a clear plan. Standard code changes, small-to-medium scope. |
| `executor-code` | The Full-Stack Builder | `strong` | high | read, grep, find, ls, bash, edit, write | Full-capability executor for ≥5 files, cross-module deps, structural refactors, new architectural patterns. Complex multi-file changes. |
| `executor-fast` | The Quick Fixer | `fast` | off | read, grep, find, ls, bash, edit, write | Fast executor for ≤2 files, ≤50 lines, no new files, no cross-module deps. Quick fixes, typo corrections, mechanical cleanup, config changes. |
| `executor-ui` | The Frontend Specialist | `vision` | high | read, grep, find, ls, bash, edit, write | UI-focused executor for frontend components, layouts, styling, animations, responsive design. CSS/styling changes, component layout, visual polish. |
| `test-engineer` | The Test Strategist | `fast` | high | read, grep, find, ls, bash, edit, write | Designs and implements test strategy: chooses test level, adds tests, detects flaky patterns. After implementation; "Add tests for the changes." |
| `doc-writer` | The Documentarian | `fast` | off | read, grep, find, ls, bash, edit, write | Authors and edits documentation files (README, guides, changelogs). Never modifies source code. "Update the README", "Write migration docs." |
| `recover` | The Continuator | `fast` | low | read, grep, find, ls, bash, edit, write | Continues work after context compaction. Finds SESSION_STATE and HANDOFF files, executes "Next Actions". Resuming from checkpoint. |

### Review & Verification

| Agent | Role | Model | Thinking | Tools | When to use |
|---|---|---|---|---|---|
| `reviewer` | The Code Reviewer | `strong` | high | read, grep, find, ls, bash | General code review: quality, architecture, test coverage, performance. Routes auth/crypto to `security-reviewer`, backend/data to `risk-reviewer`. First line of defense. |
| `security-reviewer` | The Security Auditor | `reasoner` | high | read, grep, find, ls, bash | Security vulnerability review: injection, auth/authz flaws, secret exposure, XSS, CSRF, OWASP Top 10. Changes touching auth, crypto, secrets, user input, external APIs. |
| `risk-reviewer` | The Risk Analyst | `reasoner` | high | read, grep, find, ls, bash | Engineering risk review: backend core logic, DB migrations, API contracts, cache consistency, concurrency, idempotency. Backend changes, data migrations, distributed systems. |
| `verifier` | The Validator | `fast` | off | read, grep, find, ls, bash | Runs validation commands, reproduces failures, checks logs. Read-only — does not fix issues. After implementation; "Run tests", "Check if the build passes." |
| `final-arbiter` | The Tiebreaker | `arbiter` | xhigh | read, grep, find, ls, bash | Makes definitive decisions when multiple agents disagree (competing plans, conflicting critiques, split reviews). When `critic` and `planner` conflict, or when multiple review agents disagree. |

---

## Pipeline A: Standard Complex Task

`User Request → scout → analyst → planner → plan-arbiter → executor → reviewer → verifier → Final output`

```json
{
  "name": "pipeline-standard",
  "description": "Standard complex task: discover, analyze, plan, gate, execute, review, verify",
  "phases": [
    {
      "id": "discover",
      "type": "agent",
      "agent": "scout",
      "task": "Perform fast codebase reconnaissance to understand the context for this request. Return compressed context: key files, architecture, relevant patterns.\n\nRequest: {args.request}",
      "output": "json",
      "expect": {
        "type": "object",
        "required": ["files", "summary"]
      },
      "retry": { "max": 2, "backoffMs": 0 }
    },
    {
      "id": "analyze",
      "type": "agent",
      "agent": "analyst",
      "task": "Analyze the requirements from this request. Identify knowns, unknowns, assumptions, constraints, and acceptance criteria.\n\nRequest: {args.request}\nContext: {steps.discover.output}",
      "dependsOn": ["discover"],
      "output": "json",
      "expect": {
        "type": "object",
        "required": ["knowns", "unknowns", "constraints", "acceptanceCriteria"]
      },
      "retry": { "max": 2, "backoffMs": 0 }
    },
    {
      "id": "plan",
      "type": "agent",
      "agent": "planner",
      "task": "Create a concrete implementation plan with ordered steps, affected files, risk analysis, and acceptance criteria.\n\nRequest: {args.request}\nContext: {steps.discover.output}\nAnalysis: {steps.analyze.output}",
      "dependsOn": ["discover", "analyze"],
      "output": "json",
      "expect": {
        "type": "object",
        "required": ["steps", "affectedFiles", "risks", "acceptanceCriteria"]
      },
      "retry": { "max": 2, "backoffMs": 0 }
    },
    {
      "id": "plan-gate",
      "type": "gate",
      "agent": "plan-arbiter",
      "task": "Review this implementation plan. Check for bad assumptions, scope creep, missing risks, weak acceptance criteria, and feasibility.\n\nRequest: {args.request}\nAnalysis: {steps.analyze.output}\nPlan: {steps.plan.output}\n\nOutput JSON only: {\"verdict\":\"pass\"|\"block\",\"reason\":\"...\"}",
      "dependsOn": ["plan"],
      "output": "json",
      "expect": {
        "type": "object",
        "properties": {
          "verdict": { "enum": ["pass", "block"] },
          "reason": { "type": "string" }
        },
        "required": ["verdict", "reason"]
      },
      "retry": { "max": 2, "backoffMs": 0 }
    },
    {
      "id": "execute",
      "type": "agent",
      "agent": "executor",
      "task": "Implement the changes specified in this plan. Do NOT deviate from the plan.\n\nRequest: {args.request}\nPlan: {steps.plan.output}",
      "dependsOn": ["plan-gate"],
      "idempotent": false
    },
    {
      "id": "review",
      "type": "agent",
      "agent": "reviewer",
      "task": "Review the implementation for code quality, architectural consistency, test coverage gaps, and performance issues. Cite specific files and lines.\n\nRequest: {args.request}\nPlan: {steps.plan.output}\nImplementation: {steps.execute.output}",
      "dependsOn": ["execute"]
    },
    {
      "id": "verify",
      "type": "agent",
      "agent": "verifier",
      "task": "Run validation commands to confirm the implementation meets acceptance criteria. Check build, tests, and any other acceptance criteria from the plan.\n\nPlan acceptance criteria: {steps.plan.json.acceptanceCriteria}\nReview findings: {steps.review.output}\nImplementation: {steps.execute.output}",
      "dependsOn": ["execute", "review"],
      "final": true
    }
  ]
}
```

---

## Pipeline B: High-Risk Backend Change

`User Request → scout → analyst → planner → critic → plan-arbiter → executor-code → risk-reviewer + security-reviewer (parallel) → verifier → Final output`

```json
{
  "name": "pipeline-high-risk",
  "description": "High-risk backend change: adversarial plan review, parallel risk+security review, complex executor",
  "phases": [
    {
      "id": "discover",
      "type": "agent",
      "agent": "scout",
      "task": "Perform fast codebase reconnaissance to understand the context for this request. Return compressed context: key files, architecture, relevant patterns.\n\nRequest: {args.request}",
      "output": "json",
      "expect": {
        "type": "object",
        "required": ["files", "summary"]
      },
      "retry": { "max": 2, "backoffMs": 0 }
    },
    {
      "id": "analyze",
      "type": "agent",
      "agent": "analyst",
      "task": "Analyze the requirements from this request. Identify knowns, unknowns, assumptions, constraints, and acceptance criteria.\n\nRequest: {args.request}\nContext: {steps.discover.output}",
      "dependsOn": ["discover"],
      "output": "json",
      "expect": {
        "type": "object",
        "required": ["knowns", "unknowns", "constraints", "acceptanceCriteria"]
      },
      "retry": { "max": 2, "backoffMs": 0 }
    },
    {
      "id": "plan",
      "type": "agent",
      "agent": "planner",
      "task": "Create a concrete implementation plan with ordered steps, affected files, risk analysis, and acceptance criteria.\n\nRequest: {args.request}\nContext: {steps.discover.output}\nAnalysis: {steps.analyze.output}",
      "dependsOn": ["discover", "analyze"],
      "output": "json",
      "expect": {
        "type": "object",
        "required": ["steps", "affectedFiles", "risks", "acceptanceCriteria"]
      },
      "retry": { "max": 2, "backoffMs": 0 }
    },
    {
      "id": "critique",
      "type": "agent",
      "agent": "critic",
      "task": "Adversarially challenge this plan. Find contradictions, hidden assumptions, weak reasoning, and overlooked risks. Be aggressive — your job is to break the plan.\n\nRequest: {args.request}\nAnalysis: {steps.analyze.output}\nPlan: {steps.plan.output}",
      "dependsOn": ["plan"]
    },
    {
      "id": "plan-gate",
      "type": "gate",
      "agent": "plan-arbiter",
      "task": "Review this implementation plan considering the adversarial critique. Check for bad assumptions, scope creep, missing risks, weak acceptance criteria, and feasibility.\n\nRequest: {args.request}\nAnalysis: {steps.analyze.output}\nPlan: {steps.plan.output}\nCritique: {steps.critique.output}\n\nOutput JSON only: {\"verdict\":\"pass\"|\"block\",\"reason\":\"...\"}",
      "dependsOn": ["plan", "critique"],
      "output": "json",
      "expect": {
        "type": "object",
        "properties": {
          "verdict": { "enum": ["pass", "block"] },
          "reason": { "type": "string" }
        },
        "required": ["verdict", "reason"]
      },
      "retry": { "max": 2, "backoffMs": 0 }
    },
    {
      "id": "execute",
      "type": "agent",
      "agent": "executor-code",
      "task": "Implement the changes specified in this plan. Do NOT deviate from the plan.\n\nRequest: {args.request}\nPlan: {steps.plan.output}\nCritique considerations: {steps.critique.output}",
      "dependsOn": ["plan-gate"],
      "idempotent": false
    },
    {
      "id": "reviews",
      "type": "parallel",
      "branches": [
        {
          "agent": "risk-reviewer",
          "task": "Review for engineering risks: backend core logic, DB migrations, API contracts, cache consistency, concurrency, idempotency, data integrity.\n\nRequest: {args.request}\nImplementation: {steps.execute.output}\n\nCite specific files and lines for every finding."
        },
        {
          "agent": "security-reviewer",
          "task": "Review for security vulnerabilities: injection, auth/authz flaws, secret exposure, XSS, CSRF, OWASP Top 10 patterns.\n\nRequest: {args.request}\nImplementation: {steps.execute.output}\n\nCite specific files and lines for every finding."
        }
      ],
      "dependsOn": ["execute"]
    },
    {
      "id": "verify",
      "type": "agent",
      "agent": "verifier",
      "task": "Run validation commands to confirm the implementation meets acceptance criteria. Check build, tests, and any other acceptance criteria from the plan.\n\nPlan acceptance criteria: {steps.plan.json.acceptanceCriteria}\nImplementation: {steps.execute.output}\nReviews: {steps.reviews.output}",
      "dependsOn": ["execute", "reviews"],
      "final": true
    }
  ]
}
```

---

## Pipeline C: Quick Fix

`User Request → executor-fast → verifier → Final output`

```json
{
  "name": "pipeline-quick-fix",
  "description": "Quick fix for low-risk changes: ≤2 files, ≤50 lines, no new files, no cross-module deps",
  "phases": [
    {
      "id": "execute",
      "type": "agent",
      "agent": "executor-fast",
      "task": "Implement this quick fix. Keep changes minimal — ≤2 files, ≤50 lines, no new files, no cross-module dependencies.\n\nRequest: {args.request}",
      "idempotent": false
    },
    {
      "id": "verify",
      "type": "agent",
      "agent": "verifier",
      "task": "Run targeted validation to confirm the fix works. Check the specific acceptance criteria.\n\nRequest: {args.request}\nImplementation: {steps.execute.output}",
      "dependsOn": ["execute"],
      "final": true
    }
  ]
}
```

---

## Pipeline D: UI/Frontend Change

`User Request → visual-explorer → planner → executor-ui → reviewer → verifier → Final output`

```json
{
  "name": "pipeline-ui",
  "description": "UI/frontend change: design analysis, planning, vision-model execution, review, verification",
  "phases": [
    {
      "id": "discover",
      "type": "agent",
      "agent": "visual-explorer",
      "task": "Analyze the design context. Extract design tokens (colors, typography, spacing, layout patterns) from any provided Figma metadata, screenshots, or design specs.\n\nRequest: {args.request}",
      "output": "json",
      "expect": {
        "type": "object",
        "required": ["tokens", "summary"]
      },
      "retry": { "max": 2, "backoffMs": 0 }
    },
    {
      "id": "plan",
      "type": "agent",
      "agent": "planner",
      "task": "Create a concrete implementation plan for this UI change. Include affected components, layout changes, styling updates, and responsive behavior.\n\nRequest: {args.request}\nDesign context: {steps.discover.output}",
      "dependsOn": ["discover"],
      "output": "json",
      "expect": {
        "type": "object",
        "required": ["steps", "affectedFiles", "acceptanceCriteria"]
      },
      "retry": { "max": 2, "backoffMs": 0 }
    },
    {
      "id": "execute",
      "type": "agent",
      "agent": "executor-ui",
      "task": "Implement the UI changes specified in this plan. Use the design tokens and context to ensure visual fidelity. Do NOT deviate from the plan.\n\nRequest: {args.request}\nDesign context: {steps.discover.output}\nPlan: {steps.plan.output}",
      "dependsOn": ["discover", "plan"],
      "idempotent": false
    },
    {
      "id": "review",
      "type": "agent",
      "agent": "reviewer",
      "task": "Review the UI implementation for code quality, accessibility, responsive behavior, and visual fidelity to the design.\n\nRequest: {args.request}\nDesign context: {steps.discover.output}\nPlan: {steps.plan.output}\nImplementation: {steps.execute.output}",
      "dependsOn": ["execute"]
    },
    {
      "id": "verify",
      "type": "agent",
      "agent": "verifier",
      "task": "Run validation to confirm the UI implementation meets acceptance criteria. Check build, tests, and responsive behavior.\n\nPlan acceptance criteria: {steps.plan.json.acceptanceCriteria}\nReview findings: {steps.review.output}\nImplementation: {steps.execute.output}",
      "dependsOn": ["execute", "review"],
      "final": true
    }
  ]
}
```

---

## Evidence-First Mandate

All reviewer agents (`reviewer`, `security-reviewer`, `risk-reviewer`, `plan-arbiter`, `critic`, `final-arbiter`) enforce an evidence-first mandate:

1. **Start from provided evidence.** Reviewers must ground their analysis in the files, code, and context already passed between phases.
2. **Read minimally.** Only read additional files when a specific claim cannot be verified from what is already available.
3. **Cite sources.** Every finding must reference a specific file, line, or previously-provided context.
4. **No speculation.** If evidence is insufficient, state what is missing rather than guessing.

---

## Migration from Old AGENTS.md

| Old Agent | New Equivalent | Notes |
|---|---|---|
| `orchestrator` | **Removed** | The taskflow runtime *is* the orchestrator. No subagent needed. |
| `explore` | `scout` | Same purpose, better model assignment (`fast` for speed). |
| `researcher` | `analyst` | Superseded: `analyst` does requirement analysis with explicit acceptance criteria. |
| `architect` | `critic` + `reviewer` + `plan-arbiter` | Split into adversarial challenge, code review, and plan gating. |
| `plan` | `planner` | Same core function, now with explicit risk analysis and acceptance criteria. |
| `coder` | `executor` / `executor-code` / `executor-fast` / `executor-ui` | Four specialized executors chosen by change scope and type. |

---

## Usage

To run a pipeline: `taskflow action:"run" name:"pipeline-standard" args:{request:"..."}`

To verify a pipeline definition before running: `taskflow action:"verify" defineFile:"/home/sephirot/projects/pi-config/agents.tf"`

To save a pipeline into the taskflow library: `taskflow action:"save" defineFile:"/home/sephirot/projects/pi-config/agents.tf"`
