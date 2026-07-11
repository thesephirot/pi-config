# Shorthand: Single Task

One agent, one task. Simplest delegation.

## Template

```jsonc
{
  "task": "YOUR_TASK_DESCRIPTION",
  "agent": "AGENT_NAME"  // optional — defaults to first available
}
```

## Examples

```jsonc
// Codebase recon
{
  "task": "Summarize the architecture of src/. List key modules, responsibilities, and dependencies.",
  "agent": "scout"
}

// Requirements analysis
{
  "task": "Analyze: 'implement user auth with OAuth2'. Identify knowns, unknowns, assumptions, constraints, acceptance criteria.",
  "agent": "analyst"
}

// With context files
{
  "task": "Review src/auth/index.ts for security vulnerabilities.",
  "agent": "security-reviewer",
  "context": ["src/auth/index.ts"],
  "contextLimit": 12000
}
```

## Tips
- Add `context: ["file1"]` to pre-read files before the task.
- Desugars to a full flow automatically (gets tracking/resume/save).
