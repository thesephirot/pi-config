# Shorthand: Chain

Sequential tasks. Each step references the previous via `{previous.output}`.

## Template

```jsonc
{
  "chain": [
    { "task": "FIRST_STEP", "agent": "AGENT_1" },
    { "task": "SECOND_STEP using {previous.output}", "agent": "AGENT_2" }
  ]
}
```

## Examples

```jsonc
// Explore → Document
{
  "chain": [
    { "task": "List the public API of src/lib. For each export: name, signature, one-line purpose.", "agent": "scout" },
    { "task": "Write comprehensive API documentation:\n\n{previous.output}", "agent": "doc-writer" }
  ]
}

// Plan → Execute → Verify
{
  "chain": [
    { "task": "Create a detailed plan for migrating from Express to Fastify. List affected files, steps, rollback.", "agent": "planner" },
    { "task": "Execute the migration:\n\n{previous.output}", "agent": "executor-code" },
    { "task": "Run tests and check the build. Report any failures:\n\n{previous.output}", "agent": "verifier" }
  ]
}

// Reference earlier steps by index
{
  "chain": [
    { "task": "Analyze error handling in src/ and propose improvements.", "agent": "analyst" },
    { "task": "Critique this proposal. Find gaps and contradictions:\n\n{previous.output}", "agent": "critic" },
    { "task": "Refine the proposal:\nOriginal:\n{chain.0.output}\nCritique:\n{previous.output}", "agent": "planner" }
  ]
}
```

## Tips
- Use `{previous.output}` for the immediate predecessor.
- Use `{chain.N.output}` to reference any earlier step by 0-based index.
- For complex DAGs, use full DSL with `dependsOn` instead.
