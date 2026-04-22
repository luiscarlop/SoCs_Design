# Lessons Learned

- When ISE reports many cascading undeclared-symbol errors in a module, first check for an early syntax break (generic separators, invalid conditional assignment) in that module.
- After editing shared modules under `modules/`, re-run synthesis in the target lab project to refresh stale `.syr` diagnostics.
