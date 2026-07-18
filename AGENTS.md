# Pi-Subagents Builtin Agent Registry

This file documents the 8 builtin agents shipped with the `pi-subagents` extension and provides guidance for fine-tuning their capabilities via settings overrides or custom agent files.

## Quick Reference

| Agent | Role | Default Context | Default Output | Thinking |
|---|---|---|---|---|
| `scout` | Fast codebase recon | fork | `context.md` | low |
| `planner` | Implementation plans | fork | `plan.md` | high |
| `worker` | Code implementation | fork | inline summary | high |
| `reviewer` | Code/plan/diff review | inherited | inline findings | high |
| `context-builder` | Requirements-to-context handoff | inherited | `context.md` | medium |
| `researcher` | Web research briefs | inherited | `research.md` | medium |
| `delegate` | Lightweight generic task | inherited | inline | inherits |
| `oracle` | Decision-consistency advisory | fork | inline recommendation | high |

## Agent Details

### `scout`

**Purpose:** Fast, compressed codebase reconnaissance. Maps entry points, key types, data flow, and files likely to need changes.

**Tools:** `read`, `grep`, `find`, `ls`, `bash`, `write`, `intercom`

**When to use:**
- Before planning to gather the minimum context another agent needs
- When you need a quick map of a module, feature area, or architectural boundary
- As the first step in a chain before `planner` or `worker`

**Fine-tuning levers:**
- Lower `thinking` is intentional — speed matters more than deep reasoning for recon
- Override `model` to a faster model if recon is too slow, or a stronger model for complex codebases
- Add `defaultReads` to preload specific architecture docs or config files
- Set `skills` to give scout access to domain-specific analysis skills

**Typical prompt:**
```
"Map the authentication module: entry points, key interfaces, and files that would need changes to add OAuth2."
```

---

### `planner`

**Purpose:** Turns requirements and code context into a concrete, numbered implementation plan. Does not make code changes.

**Tools:** `read`, `grep`, `find`, `ls`, `write`, `intercom`

**Default reads:** `context.md`

**When to use:**
- After `scout` or `context-builder` has gathered code context
- Before `worker` to establish the implementation contract
- When scope needs bounding and risks need surfacing

**Fine-tuning levers:**
- `thinking: high` is default — planning benefits from deeper reasoning
- Override `output` to a different filename if your workflow uses a different convention
- Add `defaultReads` to include design docs, API specs, or requirements files
- The planner has no `bash` or `edit` tools — this is intentional to keep it read-only

**Typical prompt:**
```
"Create an implementation plan to add rate limiting to the API gateway. Use the context from context.md."
```

---

### `worker`

**Purpose:** Single-writer implementation agent. Executes approved tasks with narrow, coherent edits and escalates unapproved decisions.

**Tools:** `read`, `grep`, `find`, `ls`, `bash`, `edit`, `write`, `contact_supervisor`

**Default reads:** `context.md`, `plan.md`

**When to use:**
- After `planner` has produced an approved plan
- After `oracle` has validated direction and approved a path
- As the sole writer in a chain or parallel workflow

**Fine-tuning levers:**
- `thinking: high` is default — implementation needs careful reasoning
- Override `defaultReads` to include additional context files (e.g., `design.md`, `api-spec.md`)
- Set `skills` to give worker access to coding standards or linting skills
- Add `acceptanceRole: "writer"` to make acceptance inference explicit
- Use `subagentOnlyExtensions` to load project-specific tools only for worker children
- Set `timeoutMs` for long-running implementations (e.g., migrations, test suites)

**Typical prompt:**
```
"Implement the approved plan from plan.md. You are the sole writer. Escalate via contact_supervisor if you encounter unapproved decisions."
```

---

### `reviewer`

**Purpose:** Versatile review specialist for code diffs, plans, proposed solutions, codebase health, and PR/issue validation.

**Tools:** `read`, `grep`, `find`, `ls`, `bash`, `edit`, `write`, `intercom`

**Default reads:** `plan.md`, `progress.md`

**When to use:**
- Adversarial code review (launch with `context: "fresh"` for independent perspective)
- Plan validation before implementation
- Post-implementation verification
- Codebase health assessments
- PR or issue reviews

**Fine-tuning levers:**
- `thinking: high` is default — review benefits from thorough analysis
- Set `acceptanceRole: "read-only"` to prevent the reviewer from editing files
- Override `tools` to remove `edit` if you want strict read-only review
- Use `context: "fresh"` for adversarial review; `context: "fork"` when inherited decisions matter
- Add `skills` for domain-specific review (e.g., security, accessibility, performance)
- Launch multiple reviewers in parallel with distinct angles (correctness, tests, simplicity)

**Typical prompt:**
```
"Review the current diff for correctness, regressions, and edge cases. Do not edit files. Report evidence-backed findings with file and line references."
```

---

### `context-builder`

**Purpose:** Analyzes requirements against the codebase, gathers high-value context, and produces structured handoff material (context + meta-prompt) for planning and subagent prompts.

**Tools:** `read`, `grep`, `find`, `ls`, `bash`, `write`, `web_search`, `intercom`

**When to use:**
- Before planning when the task needs deeper understanding than `scout` alone provides
- When external research (APIs, libraries, best practices) is needed alongside code context
- As the first step in a `parallel-context-build` or `parallel-handoff-plan` workflow
- When the handoff must be complete enough that the next agent doesn't rediscover the same ground

**Fine-tuning levers:**
- `thinking: medium` is default — balanced between depth and speed
- Override `output` to a specific filename for your workflow
- Add `skills` to inject domain knowledge into context building
- The agent has `web_search` — use it when the task depends on external APIs or libraries
- Run multiple context-builders in parallel with distinct slices (request/scope, codebase/patterns, validation/risks)

**Typical prompt:**
```
"Build context for adding WebSocket support: relevant files, existing patterns, external API requirements, and implementation risks."
```

---

### `researcher`

**Purpose:** Autonomous web researcher. Searches, evaluates, and synthesizes a focused research brief with source citations.

**Tools:** `read`, `write`, `web_search`, `fetch_content`, `get_search_content`, `intercom`

**When to use:**
- When you need evidence-backed answers from official docs, specs, benchmarks, or primary sources
- As part of `parallel-research` alongside `scout` for both external evidence and local code context
- Before planning tasks that depend on external APIs, libraries, or ecosystem conventions
- For competitive analysis, best-practice research, or API documentation review

**Fine-tuning levers:**
- `thinking: medium` is default — enough for source evaluation without excessive latency
- Override `output` to a different filename if needed
- The researcher has no code-editing tools — it's purely a research agent
- Use `workflow: "none"` (default) for non-interactive research; `workflow: "summary-review"` when curator review is needed
- Add `skills` for domain-specific research (e.g., `librarian` for open-source library deep dives)

**Typical prompt:**
```
"Research the current best practices for TypeScript error handling in 2025. Include official docs, benchmarks, and primary sources."
```

---

### `delegate`

**Purpose:** Lightweight, generic subagent that inherits the parent model with minimal constraints. A blank canvas for one-off tasks.

**Tools:** `read`, `grep`, `find`, `ls`, `bash`, `edit`, `write`, `contact_supervisor`

**When to use:**
- Quick one-off tasks that don't fit a specialized role
- When you want the child to use the same model as the parent
- For tasks where the parent model is already well-suited and no role specialization is needed
- As a fallback when no other agent matches the task

**Fine-tuning levers:**
- `systemPromptMode: append` — the system prompt is appended to the parent's instructions, not replaced
- Inherits parent model by default — override `model` if you want a different model
- No default output file — the delegate returns inline results
- Has full tool access including `bash`, `edit`, and `write`
- Set `skills` to give the delegate access to specific skills for the task

**Typical prompt:**
```
"Extract all API endpoints from the route files and write them to api-endpoints.md."
```

---

### `oracle`

**Purpose:** High-context decision-consistency advisory. Protects inherited state, prevents drift, and challenges assumptions.

**Tools:** `read`, `grep`, `find`, `ls`, `bash`, `intercom`

**When to use:**
- After significant work when you need a consistency check against inherited decisions
- When architectural boundaries, model capability routing, or scope tradeoffs are unclear
- Before `worker` implementation to validate the approved direction
- When reviewer agents disagree and a tie-breaking perspective is needed
- After long work sessions to detect context drift

**Fine-tuning levers:**
- `thinking: high` is default — oracle needs deep reasoning to spot drift and contradictions
- `defaultContext: fork` — oracle inherits the full parent session history as its baseline contract
- Oracle has no `edit` or `write` tools — it's purely advisory
- Use `contact_supervisor` for live coordination when the oracle needs clarification from the parent
- Override `model` to a stronger model for complex architectural decisions

**Typical prompt:**
```
"Review my current direction. What decisions have I inherited, where is the trajectory drifting, and what should I do next?"
```

---

## Fine-Tuning Strategies

### Strategy 1: Settings Overrides (Recommended for Small Tweaks)

For model swaps, thinking level changes, or tool adjustments, use `subagents.agentOverrides` in `.pi/settings.json` or `~/.pi/agent/settings.json`:

```json
{
  "subagents": {
    "agentOverrides": {
      "reviewer": {
        "model": "anthropic/claude-sonnet-4",
        "thinking": "high",
        "acceptanceRole": "read-only"
      },
      "worker": {
        "model": "anthropic/claude-sonnet-4",
        "skills": ["coding-standards"],
        "acceptanceRole": "writer"
      },
      "scout": {
        "model": "openai/gpt-5-nano",
        "thinking": "low"
      }
    }
  }
}
```

Available override fields: `model`, `fallbackModels`, `thinking`, `systemPromptMode`, `inheritProjectContext`, `inheritSkills`, `defaultContext`, `acceptanceRole`, `disabled`, `skills`, `tools`, `systemPrompt`.

### Strategy 2: Model Scope Enforcement

Constrain all subagents to specific model families for cost or compliance:

```json
{
  "subagents": {
    "modelScope": {
      "enforce": true,
      "allow": ["anthropic/*", "openai/gpt-5-*"]
    }
  }
}
```

### Strategy 3: Custom Agent Files (For Substantial Changes)

When a builtin needs a fundamentally different prompt, tool set, or behavior, create a custom agent file:

- **Project scope:** `.pi/agents/<name>.md` (wins over user and builtin)
- **User scope:** `~/.pi/agent/agents/<name>.md` (wins over builtin only)

A custom agent with the same name as a builtin shadows it completely. Use this to redefine an agent's role, not just tweak a model.

### Strategy 4: Eject and Customize

Copy a builtin to user or project scope, then edit the copy:

```
/subagents-eject reviewer          # copies to user scope
/subagents-eject reviewer[project] # copies to project scope
```

Then edit the ejected file in `.pi/agents/` or `~/.pi/agent/agents/`.

### Strategy 5: Per-Run Overrides

For one-off model or behavior changes:

```
/run reviewer[model=anthropic/claude-sonnet-4,thinking=high] "Review the diff"
```

---

## Workflow Patterns

### Standard Plan-Execute-Review Chain

```typescript
subagent({
  chain: [
    { agent: "scout", task: "Map the relevant code area for: {task}" },
    { agent: "planner", task: "Create an implementation plan from {previous}" },
    { agent: "worker", task: "Implement the plan from {previous}" },
    { agent: "reviewer", task: "Review the implementation. Do not edit files." }
  ],
  context: "fresh"
})
```

### Oracle-Guided Implementation

```typescript
// Step 1: Advisory review
subagent({ agent: "oracle", task: "Review direction and challenge assumptions." })

// Step 2: Implementation only after approval
subagent({ agent: "worker", task: "Implement the approved approach: ..." })
```

### Parallel Review Fanout

```typescript
subagent({
  tasks: [
    { agent: "reviewer", task: "Review for correctness and regressions. Do not edit." },
    { agent: "reviewer", task: "Review for test coverage and edge cases. Do not edit." },
    { agent: "reviewer", task: "Review for simplicity and maintainability. Do not edit." }
  ],
  context: "fresh",
  concurrency: 3
})
```

### Parallel Research (external + local)

```typescript
subagent({
  tasks: [
    { agent: "researcher", task: "Research external evidence for: ..." },
    { agent: "scout", task: "Map local code implications for: ..." }
  ],
  context: "fresh",
  concurrency: 2
})
```

---

## Discovery and Precedence

Agent files are discovered recursively from:

1. **Project scope** (highest priority): `.pi/agents/**/*.md`
2. **User scope**: `~/.pi/agent/agents/**/*.md`
3. **Builtin** (lowest priority): shipped with `pi-subagents`

Settings overrides (`subagents.agentOverrides`) apply on top of the discovered agent. Project settings win over user settings.

Inspect the live agent registry with:
```typescript
subagent({ action: "list" })
```

Inspect the live model mapping with:
```typescript
subagent({ action: "models" })
```
