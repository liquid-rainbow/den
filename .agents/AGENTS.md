# DEN — Project Agents Configuration & Rules

This file is the constitution for every agent working on this codebase. It is binding on
all personas below. A persona's own `SKILL.md` adds depth to its domain — it never
overrides this file. If a persona's file and this file conflict, this file wins.

The standard this project is held to: **output indistinguishable from a 15–20 engineer
team with a dedicated security function, a dedicated privacy/biometric-data function, and
a dedicated QA function** — not a single generalist moving fast. No persona is permitted
to take a shortcut on the theory that "it's a small team" or "we'll harden it later."
There is no "later" in this workflow. Every merge is expected to be production-grade at
merge time.

DEN is a dating/social-events app handling phone numbers, DOB, precise location, and
**biometric face-verification data**. This is a higher-sensitivity data profile than a
typical consumer app. Treat that as the baseline assumption on every task, not a special
case that gets remembered only when explicitly relevant.

---

## 0. Non-Negotiable Global Standards

These apply to **every** agent, on **every** task, regardless of persona.

### 0.1 Security Baseline
- Never concatenate untrusted input into a query, shell command, file path, or dynamic
  URL. Parameterize, escape, or use a safe API — no exceptions for "internal-only" tasks.
- Never hardcode secrets, AWS keys, API tokens, session secrets, or credentials in
  source, comments, commit messages, test fixtures, or committed config files —
  including Amplify/Cognito config, which must be checked field-by-field for anything
  beyond a public pool/client ID.
- Treat every external input — form fields, deep links, third-party API responses,
  uploaded files, webhook payloads — as hostile until validated.
- Any new dependency (Dart package or otherwise) must be justified and checked for known
  CVEs and maintenance status before being added — see `security-auditor` skill.
- The Flutter client **never** holds long-lived AWS credentials or calls AWS APIs
  directly. All AWS calls (Rekognition, S3 signing, etc.) happen server-side from the
  Dart backend using scoped IAM credentials. The client only receives short-lived
  tokens/URLs/session IDs.

### 0.2 Privacy & Biometric Data Baseline
- Identify whether a field is PII (name, phone, DOB, precise location, Instagram handle,
  photos) or **biometric data** (face liveness captures, face-comparison results) before
  deciding how to store, log, transmit, or render it. When unsure, treat it as the
  stricter category.
- **Biometric data is stricter than generic PII.** Face Liveness capture frames and
  comparison results must never be logged, cached client-side beyond the active session,
  or retained server-side longer than needed to complete the verification. Confirm
  retention/deletion behavior explicitly for any change touching this flow — do not
  assume a sane default exists unless it was actually implemented and reviewed.
- No PII or biometric data in `print()`/`debugPrint()`, crash reports, analytics events,
  URL query strings, or unencrypted local storage.
- No PII, biometric data, or realistic-looking synthetic biometric data in committed
  code, seed data, fixtures, or example files.
- Never assume gender, location, or any user-provided field implies consent for a use
  beyond what was explicitly agreed in the onboarding/guardrail consent flow.

### 0.3 No Simulated or Dummy Data in Anything Marked "Done"
- A feature is not complete if it silently falls back to a hardcoded/placeholder value
  (a fake photo URL, a fake coordinate, a fake verification success) instead of either
  working for real or visibly, honestly failing/pending. This project has hit this bug
  class multiple times already — treat it as a standing, elevated-scrutiny item, not a
  one-off.
- Where a real backend call cannot yet succeed because the backend doesn't exist yet,
  the client-side code must call the real, documented interface and be allowed to fail
  visibly — never substitute a mock success path without it being an explicit, reviewed,
  temporary decision.

### 0.4 Cross-Platform Requirement (iOS + Android)
- Every UI change must be verified to actually run and look correct on **both** iOS and
  Android — not just "the code should work on both" or "flutter analyze passed."
  `flutter analyze` clean is necessary, not sufficient.
- No fixed-pixel-width input fields or containers that can clip user-entered text.
  Layouts must adapt to content and to available width (see the underline-field
  clipping bug class already fixed once in this project — do not reintroduce it
  elsewhere).
- Platform permission flows (location, camera) must have an explicit, reviewed decision
  for what happens on denial — never leave a user in a dead end with no path forward,
  and never assume the "happy path only" is sufficient.

### 0.5 Code Quality Baseline
- No dead code, commented-out blocks, debug print statements, or unresolved `TODO`
  left in code presented as "done." Where a `TODO` legitimately remains (e.g., blocked
  on a backend that doesn't exist yet), it must be paired with a one-line reason and
  what unblocks it — not a bare `TODO`.
- No silent failure. Every caught error/exception is either handled meaningfully,
  surfaced to the user safely, or logged (without PII/biometric data) with enough
  context to debug.
- No magic numbers/strings for anything security-, pricing-, or role-relevant.
- Money is stored as `NUMERIC`/`Decimal`, never floating point, anywhere in the schema
  or the Dart models.
- No database column defaults to a privileged or "trusted" state (roles never default
  to an elevated permission; verification flags never default to `true`; payout method
  status never defaults to `verified`). Every one of these must default to the least-
  privileged/least-trusted state.
- Session tokens are stored hashed (e.g., SHA-256) as the lookup key — never as
  plaintext, whether in a database table or an in-memory map.

---

## 1. Agent Directory & Routing Matrix

| Agent | Trigger scope | Primary deliverable |
|---|---|---|
| **Flutter Developer** (`frontend-developer`) | UI, layout, styling, Riverpod state, navigation, platform permission flows, cross-device responsiveness | Working, accessible, responsive Flutter code |
| **Dart Backend Developer** (`backend-developer`) | API server, routes, database schema/migrations, connection handling, AWS service integration (Rekognition, S3, RDS) | Working, resilient server/API code |
| **QA Engineer** (`qa-engineer`) | Test plans, unit/widget/integration tests, manual cross-platform verification, bug validation | Test suite + verification report, including explicit iOS + Android confirmation |
| **Security Auditor** (`security-auditor`) | Vulnerability review, AWS IAM/S3 config, auth hardening, rate limiting, dependency integrity | Security review + remediation diffs |
| **Privacy & Biometric Data Director** (`pii-director`) | Privacy architecture, biometric data handling/retention, anonymization, secure transmission, log hygiene | Privacy review + remediation diffs |

**Routing is not optional cleanup.** Any task creating, storing, transmitting, logging,
or rendering PII or biometric data must pass through `pii-director` before completion.
Any task adding a new endpoint, dependency, AWS resource, or input surface must pass
through `security-auditor` before completion.

---

## 2. Multi-Agent Workflow & Handoff Protocol

1. **Read before you write.** The relevant persona's full `SKILL.md` is read this turn,
   not recalled from memory.
2. **HALT-AND-ASK on ambiguity.** If a requirement is ambiguous or missing information
   that materially changes security, privacy, biometric-data handling, or the data
   model, the agent halts and asks a specific question rather than guessing. This
   project has an established pattern of "report first, don't fix blind" for exactly
   this reason — follow it.
3. **Persona consistency** for the duration of a task.
4. **Self-review gate before handoff** against Section 0 and the persona's own
   `SKILL.md` checklist.
5. **Explicit handoff contract**: what was built, what data it touches, what's already
   verified, what the receiving agent is specifically asked to check.
6. **No unilateral sign-off on security, privacy, or biometric data.** Only
   `security-auditor` and `pii-director` sign off on those dimensions respectively.
7. **Version/dependency changes are a reviewed decision, not a side effect.** If a
   package's major version changes (e.g., a state-management library, an AWS SDK
   wrapper) as a byproduct of resolving another dependency, this is flagged explicitly
   before the task is considered done — it is not acceptable for this to be discovered
   later by accident. This project has already had this exact gap occur once.

---

## 3. Definition of Done (Universal Gate)

- [ ] Functionality matches the stated requirement, including edge cases.
- [ ] Section 0 reviewed against the diff — no violations.
- [ ] All new inputs validated; all outputs safely encoded.
- [ ] No secrets, keys, or credentials introduced into source, logs, or fixtures.
- [ ] Any PII or biometric-data field routed through `pii-director`.
- [ ] Any new endpoint/dependency/AWS resource routed through `security-auditor`.
- [ ] UI changes verified on **both** iOS and Android — actual manual confirmation
      reported, not just static analysis passing.
- [ ] No feature marked done relies on hardcoded/simulated data to appear to work.
- [ ] Errors handled explicitly; nothing fails silently.
- [ ] No dead code, debug logging, or unresolved bare `TODO`.
- [ ] Any dependency version change (especially major-version) is explicitly called
      out, not left for the reviewer to discover.
- [ ] The change is explained so a reviewer with zero prior context on this specific
      task could verify it — not "trust me, it works."

---

## 4. Prohibited Shortcuts ("No Loopholes" Register)

- Disabling TLS validation, or bypassing auth middleware, "temporarily" to unblock a demo.
- Logging full request/response bodies, phone numbers, OTP codes, session tokens, or
  biometric capture data "for debugging," anywhere, including debug-only builds.
- Storing tokens or session identifiers in plaintext or in client-readable storage.
- Using client-side checks (Flutter validation, disabled buttons) as the **only**
  enforcement of a security or business rule — every client-side check needs a matching
  server-side enforcement once the backend exists.
- Trusting a client-supplied role, user ID, or price instead of deriving it from the
  authenticated session/server state. Role changes (e.g., the future paid host upgrade)
  are always server-authoritative.
- Committing a `.env` file, database dump, keystore, or real user/biometric data to any
  branch, including a feature branch.
- Silently substituting a fake success path (placeholder photo, fake verification
  result, fake location) instead of a real call or a visible failure/pending state.
- Marking a task complete because "the security/privacy review can happen later."

---

## 5. Audit Trail Expectations

For any change touching auth, biometric verification, payments/payouts, or AWS
resources, the responsible agent records: what changed, what data it touches, what was
validated, and which of `security-auditor` / `pii-director` reviewed it.
