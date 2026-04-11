# Output Format Examples

## Step 1: Focus Analyzer Output

```markdown
### Step 1/3 — Focus Analysis

Generated **3** review personas from diff analysis.

| #  | Persona          | Focus                              | Boundaries (won't review)           |
|----|------------------|------------------------------------|-------------------------------------|
| R1 | Security Auditor | Auth flows, input validation,      | UI layout, test naming,             |
|    |                  | secrets exposure                   | performance                         |
| R2 | API Design       | REST conventions, request/response | Internal helpers, CSS, auth logic   |
|    |                  | contracts, error shapes            |                                     |
| R3 | Error Handling   | Error propagation, edge cases,     | Happy-path logic, naming style,     |
|    |                  | failure paths, resource cleanup    | API contracts                       |

**Rationale:** Changes touch `src/auth/`, `src/api/handlers/`, and
error-wrapping utilities. No UI or infrastructure changes detected —
skipped frontend and ops personas.
```

With coverage warning:

```markdown
> **Coverage warning:** The diff modifies `src/db/migrations/001_add_index.sql`,
> but no persona covers database migration concerns. Consider re-running with
> an explicit focus hint (e.g. `/reviewers src/db/`).
```

---

## Step 2: Parallel Review Output

### Individual Verdicts Table

```markdown
### Step 2/3 — Parallel Review

#### Individual Verdicts

| Reviewer           | Verdict         | Findings | Top Concern                              |
|--------------------|-----------------|----------|------------------------------------------|
| R1 Security Audit  | REQUEST_CHANGES | 3        | Unsanitized user input in `handleLogin`  |
| R2 API Design      | APPROVE         | 1        | Minor: inconsistent error response shape |
| R3 Error Handling  | REQUEST_CHANGES | 2        | Swallowed error in `retryWithBackoff`    |
```

### With reviewer failure:

```markdown
### Step 2/3 — Parallel Review

#### Individual Verdicts

| Reviewer           | Verdict         | Findings | Top Concern                              |
|--------------------|-----------------|----------|------------------------------------------|
| R1 Security Audit  | REQUEST_CHANGES | 3        | Unsanitized user input in `handleLogin`  |
| R2 API Design      | FAILED          | —        | Agent returned malformed output          |
| R3 Error Handling  | REQUEST_CHANGES | 2        | Swallowed error in `retryWithBackoff`    |

> **Degraded coverage:** R2 (API Design) failed. API design concerns are not
> covered in this review. Results are based on 2/3 successful reviewers.
```

---

## Step 3: Consolidated Review Output

### Standard output (with findings):

```markdown
### Step 3/3 — Consolidated Review

**Overall: REQUEST_CHANGES** (2/3 reviewers flagged issues)
Confidence: HIGH

#### Findings

**1. [CRITICAL] Unsanitized user input in auth flow** — Confidence: HIGH (2/3 reviewers)
> File: `src/auth/handleLogin.ts:42`
> Issue: `req.body.email` passed directly to `db.query()` with no sanitization,
> enabling SQL injection.
> Fix: Use parameterized query: `db.query('SELECT * FROM users WHERE email = $1', [email])`
> Source: R1 (Security Audit), R3 (Error Handling)

**2. [WARNING] Swallowed error discards stack trace** — Confidence: MEDIUM (1/3, verified)
> File: `src/utils/retryWithBackoff.ts:18`
> Issue: `catch` block calls `console.log(err)` then returns `null`. Callers
> do not check for null — downstream NPE is likely.
> Fix: Re-throw wrapped error: `throw new Error('retry failed', { cause: err })`
> Source: R3 (Error Handling)

**3. [SUGGESTION] Inconsistent error response shape** — Confidence: LOW (1/3)
> File: `src/api/handlers/users.ts:55`
> Issue: Returns `{ error: string }` while other handlers use `{ message: string, code: string }`.
> Fix: Align with `ErrorResponse` type from `src/api/types.ts`
> Source: R2 (API Design)
> ⚠️ Pre-existing (not introduced by this diff)

### Summary
- Total: 3 (Critical: 1, Warning: 1, Suggestion: 1)
- Confidence: HIGH 1 | MEDIUM 1 | LOW 1
- Reviewers: 3/3 succeeded

<details>
<summary>Defense decisions (adoption/rejection reasoning)</summary>

#### Adopted

**R1#1 + R3#2 → Finding 1 (Unsanitized user input)**
- R1 flagged SQL injection risk, R3 flagged the same line as missing error boundary
- **Defense**: Read `src/auth/handleLogin.ts:38-55`. Confirmed `req.body.email`
  is passed directly to `db.query()` with no sanitization. Checked middleware
  chain in `src/api/middleware/` — no upstream sanitization layer present.
  The injection vector is real and exploitable.
- **Adoption reason**: Verified independently. 2/3 reviewers converged on
  the same root cause from different angles. CRITICAL severity justified —
  direct SQL injection in auth path.

**R3#1 → Finding 2 (Swallowed error)**
- **Defense**: Read `src/utils/retryWithBackoff.ts:15-25`. The catch block
  calls `console.log(err)` but returns `null`. Checked 3 call sites in
  `src/api/handlers/` — none check for null return. TypeScript type allows
  null but callers assume non-null. Downstream NPE confirmed.
- **Adoption reason**: Verified against source. Only 1/3 flagged but the
  evidence is clear and the downstream impact is a production crash path.
  Elevated to MEDIUM confidence.

**R2#1 → Finding 3 (Error response shape)**
- **Defense**: Read `src/api/handlers/users.ts:50-60` and `src/api/types.ts`.
  The `ErrorResponse` type exists and is used in 4 of 6 handlers. This handler
  uses a different shape. The inconsistency is real but pre-dates this diff.
- **Adoption reason**: Real inconsistency, included as SUGGESTION so the
  implementer is aware. Annotated as pre-existing to clarify scope.

#### Rejected

**R1#3 (Test file naming convention)**
- **Defense**: Read `tests/auth/login.test.ts` and 5 adjacent test files.
  All use `describe('handleX', ...)` naming. No documented naming convention
  found in project docs or `.eslintrc`.
- **Rejection reason**: Style preference, not a defect. The existing codebase
  uses this pattern consistently. No correctness or maintainability impact.
  Flagging this would be noise for a downstream implementer.

#### Confidence scoring applied
- HIGH = ≥66% reviewers flagged OR verified critical bug confirmed in source
- MEDIUM = ≥40% OR single reviewer + source verification confirms real issue
- LOW = single reviewer, unverified or style-only

</details>
```

---

## Approve Output (No Findings)

```markdown
### Step 3/3 — Consolidated Review

**Overall: APPROVE**
**Reviewers**: 3/3 succeeded

No actionable issues found across 3 independent reviewers.

<details>
<summary>Defense decisions (adoption/rejection reasoning)</summary>

All reviewer findings were rejected after source verification:

**R2#1 (Variable naming)**
- **Defense**: Read `src/api/handlers/users.ts`. Naming follows project
  conventions established in adjacent files.
- **Rejection reason**: Style preference aligned with existing patterns.
  Not a defect.

#### Confidence scoring applied
- HIGH = ≥66% reviewers flagged OR verified critical bug
- MEDIUM = ≥40% OR single reviewer + source verification confirms real issue
- LOW = single reviewer, unverified or style-only

</details>
```

---

## Partial Failure + Degraded Coverage

```markdown
### Step 3/3 — Consolidated Review

**Overall: COMMENT** (1/2 successful reviewers; 1 failed)
Confidence: MEDIUM

> ⚠️ R2 (API Design) failed. Results may be less comprehensive.
> API design concerns were not reviewed.

#### Findings

**1. [WARNING] ...** — Confidence: MEDIUM (1/2, verified)
...

### Summary
- Total: 1 (Critical: 0, Warning: 1, Suggestion: 0)
- Confidence: HIGH 0 | MEDIUM 1 | LOW 0
- Reviewers: 2/3 succeeded (1 failed — see Step 2)
```
