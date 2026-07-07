# Agent Config Inconsistency Fix

## Inconsistency Audit

### 1. Mixed Casing in `display_name` Frontmatter

| File | `display_name` | Issue |
|---|---|---|
| `orchestrator.md` | `orchestrator` (lowercase) | OK |
| `explore.md` | `Explore` (PascalCase) | Mismatch — should be `explore` |
| `plan.md` | `plan` (lowercase) | OK |
| `architect.md` | *(missing)* | Missing — should add `display_name: architect` |
| `researcher.md` | *(missing)* | Missing — should add `display_name: researcher` |
| `coder.md` | *(missing)* | Missing — should add `display_name: coder` |

### 2. AGENTS.md References Wrong Names

AGENTS.md documents agents with **capitalized names** (`Orchestrator`, `Explore`, `Researcher`, `Architect`, `Plan`, `Coder`) that don't match either the lowercase filenames or the mixed `display_name` values.

### 3. README.md References Non-existent Agents

The README example shows `WORKER` (uppercase) as an agent type, but **no `worker.md` file exists** in either directory. The README appears to be aspirational/template content that doesn't match the actual config.

### 4. Model Assignment Mismatch

The AGENTS.md implies the Coder agent should use a dedicated model (implying a code-specialized model), but the coder's frontmatter specifies `qwen36-27b-mtp-q3:thinking` — the same model as Plan and Architect. This defeats the purpose of separating them.

### 5. Orchestrator References Non-existent Agents

The orchestrator's rules say "spawn a reviewer" but **no reviewer agent is defined** anywhere in the config.

---

## Proposed Fix Plan

**Principle**: Adopt lowercase everywhere — filenames, `display_name`, and all documentation references. Pi resolves agents by filename, so everything should align.

### Step 1: Normalize `display_name` in all agent frontmatter

Add `display_name` to the three agents missing it, using lowercase to match filenames:

- `architect.md` → add `display_name: architect`
- `researcher.md` → add `display_name: researcher`
- `coder.md` → add `display_name: coder`
- `explore.md` → change `display_name: Explore` → `display_name: explore`

### Step 2: Fix model assignments

- **Coder**: change from `qwen36-27b-mtp-q3:thinking` → `gemma31q4` (fast, non-thinking model for execution)
- **Plan**: keep `qwen36-27b-mtp-q3:thinking` (strong reasoning for planning)
- **Architect**: keep `qwen36-27b-mtp-q3:thinking` (strong reasoning for design)
- This restores the separation: reasoning models for thinking, fast models for doing.

### Step 3: Fix AGENTS.md

Update all agent references to use lowercase names matching filenames: `orchestrator`, `explore`, `researcher`, `architect`, `plan`, `coder`. Remove the "WORKER" example and replace with `coder`.

### Step 4: Fix README.md

- Replace `WORKER` references with `coder`
- Update the `/agents` example output to use lowercase names
- Update the scoped models list to match actually-enabled models in `config.yaml` (remove `gemma12q5`, `qwen35-9b-q4` which are commented out)

### Step 5: Remove orphan references

Remove "spawn a reviewer" from orchestrator since no reviewer agent exists (or define one if needed).

### Step 6: Sync both directories

After fixing `pi-subagents/agents/`, copy changes to `.pi/agents/` so both stay in sync.

### Step 7: Verify

Run `/agents` in Pi to confirm all agents appear with consistent names and correct models.
