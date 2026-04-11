# Cross-Cutting Review Checklist

These concerns apply to ALL reviews regardless of the specific focus areas.
Every reviewer must check these in addition to their persona's focus.

## Must Check

- **Security**: SQL injection, auth bypass, exposed secrets or hardcoded
  credentials, OWASP Top 10, missing authorization checks.
- **Error handling**: Errors must propagate, not be swallowed. No silently
  ignored errors. No silent `recover()`/`catch` in business logic without
  logging.
- **Data safety**: No destructive operations without confirmation. Migrations
  must be backward compatible. No data loss risk.
- **Input validation**: User input must be validated at trust boundaries. API
  endpoints must validate request payloads before processing.
- **Resource management**: Connections, file handles, goroutines, threads, and
  other resources must be properly closed or bounded.

## Must NOT Flag

- Style issues enforced by linters (follow the project's linter configuration)
- Language choices for UI text or comments (follow project conventions)
- Commit message format (typically enforced by tooling)
