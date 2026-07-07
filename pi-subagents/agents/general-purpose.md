---
enabled: false
---

# General-Purpose Agent (Disabled)

This agent is intentionally disabled. It serves as a template for creating custom agents.

**Why disabled:** This project uses a specialized agent registry (orchestrator, explorer, researcher, architect, planner, coder) with strict role separation. A general-purpose agent would bypass these constraints and degrade the quality of delegated work.

**To enable as a fallback:** Set `enabled: true` in the frontmatter if you want a catch-all agent for tasks that don't fit the specialized roles. Assign it a capable model and appropriate tools.
