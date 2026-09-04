# The Fragments bridge — RETIREMENT (pre-13x batch 0b, run as its OWN session before the key work)

**Status: PLANNED 2026-09-04 at the pre-13x kickoff sitting; NOT RUN.** Her ruling (pre-13x design §1
ruling 16 + 2026-09-04: *"I'll run the removal before this phase — seems like it would be cleaner and there's
no reason not to do it."*). One acceptance unit (kind: operations): the bridge is gone from `main`, every
suite is green, no bridge door renders, its own cold review closes clean. **Cast: ONE Fable implementer
session (this file is its whole brief) + ONE fresh Fable cold reviewer** (the diff touches `AuthSession`
and `Sync/`-adjacent seams — her R-cor-14 rule). The orchestrator (the pre-13x architect session, or she
herself) verifies and closes.

---

## KICKOFF PROMPT (paste-ready for the implementer session)

> You are the implementer for the Fragments bridge RETIREMENT in Variorum (`<home>/dev/variorum`,
> branch `main`). Read, in order, and nothing else first: `CLAUDE.md`; `notes/SessionResiliencyProtocol.md`
> (BINDING — commit per coherent piece, PUSH after every commit, LIVE STATUS written at the start and flipped
> per piece, synchronous foreground waits only, never spawn subagents); then THIS file whole
> (`notes/plans/pre-13x-bridge-retirement.md`). Then do exactly §3's steps in order, each its own commit
> with the trailer below, verifying as §4 says; write the record in §6 as you go. Touch nothing outside
> §2's inventory without recording why. Do not touch `Sources/VariorumCore/Sync/` except the ONE listed line
> in `SyncSchema.swift`. Never touch the real store, never a Release build, never `/Applications`.
> Commit trailer, every commit:
> `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>`
> `Claude-Session: https://claude.ai/code/session_018fVyFuh8MSGtCEbGUmGvZ8`
> When done, reply with the commit hashes, the three suite lines ("Test run with N tests" / `swift test`
> summary), and anything left open.

---

## 1. WHY, AND THE ARCHIVE SHAPE

Her words: the bridge is on the list by history, not by v1 need; keeping it froze the vault format and
would have needed a suite-level posture floor maintained by hand across two repos; if it returns it returns
as shared rows in a collaboration era (a Fragments user as an outside collaborator on a journal book), not
as a second sync engine. So the code is ARCHIVED, not disabled: a disabled bridge would still compile,
still claim a key provider, still carry 14 test files through every future key change.

**The archive (recommended — cheapest, complete, and discoverable):**
1. **A branch AND a tag at the same commit**, the last `main` before removal: `git branch
   archive/fragments-bridge` and `git tag archive/fragments-bridge-2026-09-04`. The branch is for humans
   browsing; the tag is the immutable marker that survives branch cleanups. Both pushed. The branch is
   never rebased or "kept up to date" — it is a photograph, and revival is a re-implementation guided by it.
2. **A short note on `main`** at `notes/archive/fragments-bridge.md`: what was removed, the tag/branch, the
   contract file's location, the one-paragraph revival shape (shared rows), and the date. That note is
   what a future session finds by grep.
*(Considered and declined: an `Archive/` folder excluded from targets — 2,200 lines that still match every
grep and confuse every future reader; a separate repo — overkill for a photograph.)*

## 2. THE INVENTORY (grep-built 2026-09-04; the implementer RE-RUNS the greps first and records any delta)

**Delete whole (bridge-only):**
- `Sources/VariorumCore/Bridge/` — `BridgeEncryption.swift` · `BridgeEngine.swift` · `BridgeScheduler.swift`
  · `FragmentsContract.swift` · `FragmentsSession.swift` · `FragmentsTransport.swift` (6 files, 2,226 lines)
- `App/Variorum/Shared/BridgeSession.swift` · `App/Variorum/Shared/BridgeStatusViews.swift`
- Tests, core (`Tests/VariorumCoreTests/`): `BridgeDailyBookTests` · `BridgeDeletionTravelTests` ·
  `BridgeEncryptionTests` · `BridgeLandingTests` · `BridgePushTests` · `BridgeRestageTests` ·
  `BridgeSchedulerTests` · `BridgeSoakTests` · `BridgeStateTests` · `BridgeVersionTests` ·
  `FakeFragmentsServerTests` · `FragmentsContractTests` · `FragmentsTransportTests`; `Support/BridgeTestHarness`
  · `Support/BridgeTestKeys` · `Support/FakeFragmentsServer`
- Tests, Mac: `App/Variorum/VariorumTests/Phase9bBridgeWiringTests.swift`

**Edit (bridge-touching; remove the bridge's part, keep the rest):**
- `App/Variorum/Shared/AppServices.swift` (49 refs — the bridge composition: `bridge`, `fragmentsSession`,
  `makeBridgeTransport`, `makeBridgeKeyProvider`, `bridgeEnabled`, `bridgeMinimumRoundInterval`, the
  `sync.onRoundCompleted → bridge.trigger()` hook, the subscription note's bridge half)
- `App/Variorum/Shared/SyncSession.swift` (the one bridge-trigger line + its doc)
- `App/Variorum/Shared/AuthSession.swift` + `AuthViews.swift` + `SignInFlow.swift` — the bridge's
  FRAGMENTS-PROJECT delegated session (the `custom:stargazing` browser flow INTO the Fragments project, its
  token store, its sign-in/out faces, `R94`'s bridge-row auth failures). **Keep** the Variorum-project direct
  sign-in (14a) whole. If `SignInFlow.swift` proves bridge-only after reading, delete it.
- `App/Variorum/Shared/ProjectConfig.swift` — `fragmentsProjectURL`, `fragmentsPublishableKey` (+ the
  Fragments paragraph in its header)
- `App/Variorum/Shared/EncryptionKeychain.swift` — `DeviceBridgeKeyProvider` (the `BridgeKeyProviding`
  protocol lives in the deleted module; remove the provider and its liveness pin in `Phase9cAuthWiringTests`)
- `App/Variorum/Shared/ErrorPresentation.swift` — the bridge error wording (1 ref)
- `App/Variorum/Variorum/RootView.swift` — `BridgeStatusRow` (the bridge row; lines ~53, ~324, ~337)
- `Sources/VariorumCore/Operations/Operations+Sync.swift` — `applyBridgeLanding` (bridge-only op; delete it
  and its AppSpec §9 row); `resolveSyncConflict`'s `label` parameter STAYS (generic — the `'fragments'` label
  string goes from docs only)
- `Sources/VariorumCore/Operations/Operations+Container.swift` — doc lines naming `BridgeEngine.pullAndLand`
  in `shelveInDailyJournalBook`'s comment (the op itself stays — ⌘J and the phone use it)
- `Sources/VariorumCore/Crypto/AccountRekey.swift` — step 6 (`BridgeEngine.stageRepushFromTruth`) and its
  doc; the marker clears after step 5 now. `journalBridge` class-key MINTING STAYS (the vault format; one
  comment: dormant)
- `Sources/VariorumCore/Sync/SyncSchema.swift` — the ONE Sync/ touch: `bridge_state`/`bridge_day` leave the
  local-table exclusion list IF the drop migration below lands (else the comment updates)
- `Sources/VariorumCore/Persistence/Migrations.swift` — **NEW migration `v1_15_drop_bridge_tables`** dropping
  `bridge_state` + `bridge_day` (local-only, never synced — no §12 lockstep; its own commit per the
  schema-commit rule). The `v1_4_bridge_state` migration itself STAYS (migrations are append-only).
- Doc-only mentions (comments naming Fragments as the reason for a shape — keep the shape, fix the words):
  `SampleLibrarySeeder.swift:580`, `TutorialSeeder.swift:21`, `MobileTutorialSeeder.swift:32`,
  `Operations+NoteVersions.swift`, `DisplayTitle.swift`, `JournalDay.swift`, `Export.swift`,
  `ReadingAssembly.swift`, `TakesQueries.swift`, `Enums.swift`, `OwnerIdentity.swift`, `UserSession.swift`,
  and the Mac/mobile feature files the grep lists (`BlockDecor`, `EditorTextView`, `EditorViewModel`, …) —
  re-run `grep -rn -i fragments` and judge each: a comment citing history may stay if it reads as history.
- `Tools/VaultBootstrap` — check for bridge references (the runner mints the journal class key: keep).

**Docs to update (canon; exact spots):**
- `notes/AppSpec.md`: §9 `applyBridgeLanding` row → removed (one line saying retired 2026-09-04, tag named);
  §9 `resolveSyncConflict` — the "Fragments bridge lands rescued bodies… labeled 'fragments'" sentence →
  retired; §9 `shelveInDailyJournalBook` — the bridge's landing as a door → retired (⌘J + the phone remain);
  §7 the `setting` block's note if it names the bridge; §14's delta at pre-13x's closeout records it.
- `notes/SyncSpec.md`: §3 THE WIRE IS CIPHERTEXT paragraph's bridge sentence → retired; §2's 14d history
  stays as history.
- `notes/OverallModel.md` §3 — the six quiet auto-commit occasions: the Fragments-landing occasion → retired
  (five remain).
- `notes/DetailedPlanForPhases.md`: the 9b row stays (history) with a "retired 2026-09-04" note; the 13v row
  in `notes/FuturePhases.md` → RETIRED with the revival shape; MobileSoul's bridge parity lines → retired.
- `notes/KnownIssuesAndTechDebt.md`: the "Bridge push sweep is O(journal-days)" row → removed (resolved by
  retirement); any other bridge row likewise.
- `CLAUDE.md`: the 9b/9c casting lines are history — leave; add nothing.
- `notes/fragments-bridge-contract.md`: the OUTBOUND CARRY ITEM (§5 below) appended; the file stays as history.
- `notes/plans/pre-13x-postures-design.md` §10 → "DONE (tag …)" at the pre-13x architect's next touch (not
  this session's — avoid a concurrent edit while batch 0 runs).

## 3. THE STEPS (each its own commit; verify per §4 where marked)
1. **Archive:** `git branch archive/fragments-bridge && git tag archive/fragments-bridge-2026-09-04 && git
   push origin archive/fragments-bridge archive/fragments-bridge-2026-09-04`. Write `notes/archive/
   fragments-bridge.md` (§1's note). Commit + push. Write §6's LIVE STATUS now.
2. **Core removal:** delete `Sources/VariorumCore/Bridge/`; remove `applyBridgeLanding`; remove
   `AccountRekey` step 6; fix `Operations+Container` docs; delete the 16 core test files. `swift build`
   then `swift test` — green (record the summary line). Commit + push.
3. **The drop migration** (own commit): `v1_15_drop_bridge_tables`; `SyncSchema.swift`'s exclusion list
   loses the two names; `MigrationTests` gains the pin (a store at v1_14 migrates to v1_15 and the tables are
   gone; `SerializerCompletenessTests`' local-table walk still passes). `swift test` green. Commit + push.
4. **App removal:** `BridgeSession`, `BridgeStatusViews`, the `RootView` row, `AppServices`' bridge
   composition, `SyncSession`'s trigger, `DeviceBridgeKeyProvider`, `ErrorPresentation`'s line,
   `ProjectConfig`'s Fragments constants, the Fragments-project session in `AuthSession`/`AuthViews`/
   `SignInFlow` (keep 14a's direct sign-in byte-identical in behavior — `AuthSessionTests` and
   `TierAndOnboardingTests` must pass UNMODIFIED except for deleted bridge cases); delete
   `Phase9bBridgeWiringTests`; trim `Phase9cAuthWiringTests`' bridge pins. Build both app targets. Commit +
   push.
5. **Doc-only mentions** in code (the comment sweep) — one commit.
6. **Canon docs** (§2's list) — one commit. **The outbound carry item** (§5) — in the same commit.
7. **Verification (§4)** — flip §6 to DONE with the counts; commit + push.

## 4. VERIFICATION (the unit's evidence)
- `swift build` + `swift test` green from the repo root (record "Executed N tests").
- Mac: from `App/Variorum/`, `xcodebuild test -scheme Variorum -destination 'platform=macOS'` at suite level
  for the touched suites first (`AuthSessionTests`, `Phase9cAuthWiringTests`, `TierAndOnboardingTests`,
  `EncryptionFlowTests`, `TutorialWalkTests`), then the full Mac suite — record the "Test run with N tests"
  line. Expected: the previous baseline (2106/378 at the Act 10 close) MINUS the deleted bridge cases.
- iOS: the mobile target BUILDS (`xcodebuild build-for-testing` for the VariorumMobile scheme) and
  `MobileStarterJournalTests` + `MobileTutorialWalkTests` pass.
- The walk (the orchestrator's, hands-on, dev store): no bridge row in the sidebar/status area; Settings ▸
  Account shows only the Variorum sign-in; ⌘J still mints and shelves today's entry; a sync round completes.
- `grep -rn -i -E "fragments|bridge" Sources App --include='*.swift'` → only history comments remain, each
  read and recorded in §6.

## 5. THE OUTBOUND CARRY ITEM (appended to `notes/fragments-bridge-contract.md`; she carries it)
> **CARRY ITEM (2026-09-04) — the journal bridge is RETIRED on the Variorum side.** Variorum removed its
> half of the journal bridge from `main` (archived at tag `archive/fragments-bridge-2026-09-04`). Nothing is
> owed by Fragments: the 20.10 passphrase-set ceremony is moot for the bridge's sake (build it or not on
> your own merits); the journal-class E2EE bodies already in `journal_entries` are yours to keep, migrate or
> drop; the `journal_bridge` class key remains in the suite vault format, dormant. UNCHANGED: the ONE
> Stargazing account and the suite issuer (14a/14d) — this retires the bridge, not the account. If the
> bridge ever returns it returns as shared rows on Variorum's own sync in a collaboration era, designed then.

## 6. THE RECORD (the implementer writes; LIVE STATUS first)
- LIVE STATUS: step 1 — NOT-STARTED · step 2 — · step 3 — · step 4 — · step 5 — · step 6 — · step 7 —
- Counts: core PENDING · Mac PENDING · iOS build PENDING
- Deltas from §2's inventory found by the re-run greps: PENDING
- Open items for the orchestrator: PENDING

## 7. THE COLD REVIEW (after §6 says DONE)
A FRESH Fable reviewer runs `notes/REVIEW_PROMPT.md` verbatim over the combined diff (`git diff
<archive-tag>..HEAD`), zero framing. Findings land in this file's §8 before any fix. Round 2 only if a
BLOCKER/MAJOR appears. Foci the orchestrator may append AFTER the cold pass (never before): the 14a direct
sign-in is behaviorally byte-identical; `resyncReinitialize` and `AccountRekeyMarker` semantics unchanged
without step 6; no bridge door renders in either app.

## 8. FINDINGS + DISPOSITIONS
(empty until the review)
