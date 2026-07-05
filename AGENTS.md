# Agent Registry & Workflow

This project utilizes the `@tintinweb/pi-subagents` framework to implement a highly specialized, autonomous agentic workflow. To ensure quality and prevent "hallucinated" implementations, the system enforces a strict **Separation of Concerns**.

## 🔄 The Agentic Workflow

The standard pipeline for complex tasks follows this sequence:

`User Request` $\rightarrow$ **Orchestrator** $\rightarrow$ **Explore/Researcher** $\rightarrow$ **Architect** $\rightarrow$ **Plan** $\rightarrow$ **Coder** $\rightarrow$ **Orchestrator** $\rightarrow$ `Completion`

1. **Discovery**: `Explore` (fast search) or `Researcher` (deep context) maps the codebase.
2. **Design**: `Architect` proposes a high-level solution and evaluates trade-offs.
3. **Strategy**: `Plan` converts the design into a step-by-step implementation guide.
4. **Execution**: `Coder` implements the plan exactly as written.
5. **Verification**: `Orchestrator` ensures the result meets the original request.

---

## 🤖 Agent Registry

### 👑 Orchestrator
- **Role**: The Manager. Coordinates all other agents.
- **Constraint**: **NEVER** performs tasks itself. It only delegates and verifies.
- **When to use**: The primary entry point for all complex requests.
- **Definition**: `pi-subagents/agents/Orchestrator.md`

### 🔍 Explore
- **Role**: The Scout. Fast, targeted search for symbols, files, and patterns.
- **Constraint**: Read-only. No synthesis or deep analysis.
- **When to use**: "Where is X defined?", "Find all files using Y."
- **Definition**: `pi-subagents/agents/Explore.md`

### 📚 Researcher
- **Role**: The Librarian. Deep context gathering and synthesis.
- **Constraint**: Read-only. Produces reports, not code.
- **When to use**: "Explain how the authentication flow works," "Research the best way to integrate Z."
- **Definition**: `pi-subagents/agents/Researcher.md`

### 🏛️ Architect
- **Role**: The Designer. High-level system design and trade-off analysis.
- **Constraint**: Advisory only. **NEVER** writes or edits code.
- **When to use**: "How should we restructure the API?", "What are the pros/cons of approach A vs B?"
- **Definition**: `pi-subagents/agents/Architect.md`

### 📝 Plan
- **Role**: The Strategist. Creates detailed, step-by-step implementation plans.
- **Constraint**: Read-only. Must provide absolute paths and explicit steps.
- **When to use**: "Create a plan to implement the feature designed by the Architect."
- **Definition**: `pi-subagents/agents/Plan.md`

### 🛠️ Coder
- **Role**: The Builder. Pure implementation.
- **Constraint**: **NEVER** plans or refactors beyond the provided plan. Requires a plan to start.
- **When to use**: "Implement the changes specified in the Plan."
- **Definition**: `pi-subagents/agents/Coder.md`

---

## 🛠️ Guidelines for Interaction

### For the User
When prompting the system, be explicit about the desired outcome. The Orchestrator will handle the delegation, but providing context helps:
- **Bad**: "Fix the bug in the login flow."
- **Good**: "There is a bug in the login flow where the token isn't refreshing. Please have the Researcher investigate, the Architect propose a fix, and the Coder implement it."

### For the Orchestrator
- Always follow the **Launch Protocol**: `TaskUpdate` $\rightarrow$ `TaskExecute` $\rightarrow$ `get_subagent_result`.
- Never attempt "quick fixes" between agent steps.
- If a Coder fails, do not fix it yourself; spawn a Researcher or Architect to diagnose the failure.

---

## ➕ Adding New Agents

To add a new specialized agent:
1. Create a new `.md` file in `pi-subagents/agents/`.
2. Include a YAML frontmatter with `description`, `tools`, and `model`.
3. Define strict **Role & Constraints** to prevent overlap with existing agents.
4. Update this `AGENTS.md` file to include the new role in the registry.
