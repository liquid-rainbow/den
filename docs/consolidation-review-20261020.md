# DEN checkout consolidation — 20 October 2026

## Scope and safety

Destination: `/Users/tejbirsingh/Library/Mobile Documents/com~apple~CloudDocs/den` (the workspace for this chat).
Source of deployment changes: `/Users/tejbirsingh/projects/den`.
`/Users/tejbirsingh/Documents/GitHub/den` contains documents and an iOS workspace, not a full Git/code checkout in this environment.

At inspection the destination HEAD was `48d1487` on `service-dev`, with the chat work still modified/untracked. The source HEAD was `bf4e976` with additional uncommitted deployment changes. A branch name alone does not mean the folders contain the same files.

No commit, push, image upload, ECS update, or AWS database change was performed. Source checkout and secrets were not modified/copied. A backup of the pre-transfer files selected for replacement is in `/tmp/den-before-consolidation-20261020` (temporary, not a permanent backup).

## Differences and decisions

| Area | Before in destination | Source difference | Result |
|---|---|---|---|
| Chat | Real mutual-like chat and tests, locally edited | Static chat screens; no chat module | Destination chat preserved, including server routes and migration 003 |
| Docker | No Dockerfile or ignore file | Existing nonroot runtime, port 5001, Mumbai RDS CA certificate | Imported existing Dockerfile and ignore rules |
| Database TLS | TLS disabled in code | `DB_SSL_MODE=verify-full`, configurable CA path | Imported; image includes `/app/certs/ap-south-1-bundle.pem` |
| Backend port | Default 5000 | Default 5001 | Imported 5001 to agree with app and source image |
| Migration connection | TLS disabled; database-name SQL interpolation | TLS-aware migration connection | Imported TLS and added validated/quoted database identifier plus parameterized lookup |
| Local PostgreSQL | Port 5434 on all host interfaces | Binds `127.0.0.1:5434` | Imported; same database volume retained |
| Dart database package | Locked postgres 3.5.12 | Locked postgres 3.5.20 | Imported constraint and lock; no major-version upgrade |
| OTP resend | Decrements a counter | Deadline-based timer, timer recovery and repeated-submit guard | Imported behavior with a mounted check on the screen callback |
| Native plugin | Hosted face_liveness_detector 0.2.11 | Local compatibility patch of the same plugin version | Imported runtime/native files and path override; omitted examples, fixtures, build files and Xcode user settings |
| Native logging | Hosted package implementation | Source patch included session-ID/debug/error logging | Removed session/debug logs and raw native error details in imported runtime |
| Backend auth logs | Existing generic error response | Raw exception/stack printing | Excluded raw logging change |
| Face services and most UI | Already present | Same contents | No replacement needed |
| iOS storyboard | Existing version | Xcode formatting/device preview changes | Excluded cosmetic-only difference |

Flutter may add `android.builtInKotlin=false` and `android.newDsl=false` during a build. Those generated compatibility flags are visible in the review diff; Gradle itself was not upgraded.

## Dependency review

PostgreSQL 3.5.20 includes fixes relevant to custom TLS contexts in pools and SCRAM/transaction handling. Primary source: https://pub.dev/packages/postgres/changelog .

The local plugin pins native Swift dependencies; see `third_party/face_liveness_detector/DEN_PATCH.md` and https://github.com/smithy-lang/smithy-swift/issues/1146 . This is a workaround inherited from the source checkout, not a new face-verification feature. It misses later signing fixes; real biometric verification needs separate device validation. Advisory service requests were unavailable, so no clean-CVE claim is made.

## Validation

- Docker image built for `linux/amd64`: `den-backend:review-chat-20261020`.
- Backend analysis: passed.
- Complete backend suite: 7 tests passed on a disposable local PostgreSQL instance, with no `.env` loaded.
- All current migrations applied twice to the disposable database: passed.
- Built image startup and `/health`: passed.
- Built image performed a DB-backed invalid-session lookup and rejected access with 401: passed.
- Runtime UID 10001, RDS CA readability/default TLS startup, and absence of runtime `.env`: checked.
- Flutter analysis: passed again after consolidation (no issues).
- Full Flutter suite exposed an existing Home event test mismatch: Home is static in both checkouts while that test expects a newly published event. HTTP image requests also fail in the widget-test environment. No Home/event implementation was changed for this consolidation.
- Targeted Flutter regression suite: 19 tests passed (chat, authentication routing, navigation, organizer, and startup).
- Invalid migration database identifier was rejected before opening any database connection.
- Android: system Java 25 is incompatible with Gradle 8.14. A temporary verified Corretto 21 fixed the Java selection. A subsequent build hit iCloud dataless Gradle-cache files; a retry used a temporary project cache and advanced further through plugin configuration, but no APK was produced during this validation. No successful Android native build is claimed.
- iOS: the simulator build was attempted, but Swift dependency resolution under the iCloud workspace took several minutes and several GB without completing. That attempt was stopped to reduce resource contention; no successful iOS build or manual verification is claimed.
- Android emulator: existing API 28 emulator failed native graphics startup; a software-rendering attempt remained offline. Full Android/iOS manual flows remain unverified.
- Existing iOS project and scheme files were compared and already match the other checkout. Native resolved package locks differ; manifest pins are imported, but the native build has not verified their complete resolution.

No connection to your live RDS database was made. Default TLS startup proves the CA parses; it does not establish a successful live RDS handshake. Actual ECS task configuration, deployed image, and AWS permissions were not inspected, so zero-risk deployment parity cannot be claimed.

Security and Privacy reviewers found no new integration-specific blockers. Existing development OTP console logging, unfinished production AWS implementations, biometric score retention/concurrency gaps and native signing-version limitations remain outside this scoped approval. Do not treat this as production auth/biometric sign-off.

## Review and reproduce

Review `git status --short`, `git diff`, and new/untracked files before staging. Existing chat changes appear alongside consolidation changes because they were already uncommitted locally.

Build the backend from the project root:

```bash
docker build --platform linux/amd64 -t den-backend:review-chat-20261020 ./backend
```

Startup-only check (does not prove database access):

```bash
docker run --rm --name den-backend-review -p 127.0.0.1:5001:5001 den-backend:review-chat-20261020
```

In a second terminal:

```bash
curl http://127.0.0.1:5001/health
```

For a real database test use the reviewed ECS database host, credentials and verified TLS configuration supplied through environment/secrets. Do not point a container at `127.0.0.1:15432` expecting it to reach the Mac's SSM tunnel: container loopback is the container itself. Local disposable PostgreSQL testing explicitly used `DB_SSL_MODE=disable`; keep verified TLS for RDS.

For emulator testing against ECS:

```bash
flutter run -d YOUR_DEVICE_ID --dart-define=DEN_API_BASE_URL=https://YOUR_BACKEND_HOST
```

Use the reachable API/load-balancer URL without `/api`, not the RDS endpoint. The emulator app and backend are separate builds.

Before deploying chat, apply reviewed migration `backend/migrations/003_chat.sql` to the same development database used by ECS. The runtime image does not automatically execute migrations. Keep the existing ECS configuration and compare its task definition/port before deployment. Use a new image tag and retain the old task revision for rollback. No AWS action is authorized by this document itself.

## Final review state

The consolidation remains uncommitted. The local Docker review image is retained; temporary database/network containers were removed. Native validation is incomplete because of the host JDK/emulator and iCloud cache/file-access issues described above. Rebuild from a fully local checkout with a compatible JDK before treating mobile verification as complete. The backend image was not pushed and the running ECS service was not changed.

## Later iOS verification follow-up

After aligning the iOS package locks and resolving a separate framework-signing metadata error, the full arm64 simulator build succeeded and the app reached the login screen on iPhone 15 Pro Max. See `ios-simulator-signing-workaround.md` for the temporary non-iCloud build output location and its cleanup/reboot limits. Android and end-to-end authenticated flows remain unverified.
