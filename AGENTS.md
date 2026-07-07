# Agent Registry & Workflow

This project utilizes the `@tintinweb/pi-subagents` framework to implement a highly specialized, autonomous agentic workflow. To ensure quality and prevent "hallucinated" implementations, the system enforces a strict **Separation of Concerns**.

## 🔄 The Agentic Workflow

The standard pipeline for complex tasks follows this sequence:

`User Request` $\rightarrow$ **orchestrator** $\rightarrow$ **explore/researcher** $\rightarrow$ **architect** $\rightarrow$ **plan** $\rightarrow$ **coder** $\rightarrow$ **orchestrator** $\rightarrow$ `Completion`

1. **Discovery**: `explore` (fast search) or `researcher` (deep context) maps the codebase.
2. **Design**: `architect` proposes a high-level solution and evaluates trade-offs.
3. **Strategy**: `plan` converts the design into a step-by-step implementation guide.
4. **Execution**: `coder` implements the plan exactly as written.
5. **Verification**: `orchestrator` ensures the result meets the original request.

---

## 🤖 Agent Registry

### 👑 orchestrator
- **Role**: The Manager. Coordinates all other agents.
- **Constraint**: **NEVER** performs tasks itself. It only delegates and verifies.
- **When to use**: The primary entry point for all complex requests.
- **Definition**: `pi-subagents/agents/orchestrator.md`

### 🔍 explore
- **Role**: The Scout. Fast, targeted search for symbols, files, and patterns.
- **Constraint**: Read-only. No synthesis or deep analysis.
- **When to use**: "Where is X defined?", "Find all files using Y."
- **Definition**: `pi-subagents/agents/explore.md`

### 📚 researcher
- **Role**: The Librarian. Deep context gathering and synthesis.
- **Constraint**: Read-only. Produces reports, not code.
- **When to use**: "Explain how the authentication flow works," "Research the best way to integrate Z."
- **Definition**: `pi-subagents/agents/researcher.md`

### 🏛️ architect
- **Role**: The Designer. High-level system design and trade-off analysis.
- **Constraint**: Advisory only. **NEVER** writes or edits code.
- **When to use**: "How should we restructure the API?", "What are the pros/cons of approach A vs B?"
- **Definition**: `pi-subagents/agents/architect.md`

### 📝 plan
- **Role**: The Strategist. Creates detailed, step-by-step implementation plans.
- **Constraint**: Read-only. Must provide absolute paths and explicit steps.
- **When to use**: "Create a plan to implement the feature designed by the architect."
- **Definition**: `pi-subagents/agents/plan.md`

### 🛠️ coder
- **Role**: The Builder. Pure implementation.
- **Constraint**: **NEVER** plans or refactors beyond the provided plan. Requires a plan to start.
- **When to use**: "Implement the changes specified in the plan."
- **Definition**: `pi-subagents/agents/coder.md`

---

## 🛠️ Guidelines for Interaction

### For the user
When prompting the system, be explicit about the desired outcome. The orchestrator will handle the delegation, but providing context helps:
- **Bad**: "Fix the bug in the login flow."
- **Good**: "There is a bug in the login flow where the token isn't refreshing. Please have the researcher investigate, the architect propose a fix, and the coder implement it."

### For the orchestrator
- Always follow the **Launch Protocol**: `TaskUpdate` $\rightarrow$ `TaskExecute` $\rightarrow$ `get_subagent_result`.
- Never attempt "quick fixes" between agent steps.
- If a coder fails, do not fix it yourself; spawn a researcher or architect to diagnose the failure.

---

## ➕ Adding New Agents

To add a new specialized agent:
1. Create a new `.md` file in `pi-subagents/agents/`.
2. Include a YAML frontmatter with `description`, `tools`, and `model`.
3. Define strict **Role & Constraints** to prevent overlap with existing agents.
4. Update this `AGENTS.md` file to include the new role in the registry.
