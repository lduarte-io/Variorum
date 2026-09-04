# The Fragments bridge — RETIREMENT (pre-13x batch 0b, run as its OWN session before the key work)

**Status: KICKED OFF 2026-09-04 by the author under `/architect-phase` (a fresh Fable orchestrator session; her kickoff words and expanded scope are recorded in §2b); the implementer runs from the KICKOFF PROMPT below.** *(Was: PLANNED 2026-09-04 at the pre-13x kickoff sitting; NOT RUN.)* Her ruling (pre-13x design §1
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
> (`notes/plans/pre-13x-bridge-retirement.md`) — **§2b is BINDING on top of §2 and §3** (the orchestrator's re-run
> greps and the author's expanded user-facing scope). Then do exactly §3's steps in order, each its own commit
> with the trailer below, verifying as §4 says; write the record in §6 as you go. Touch nothing outside
> §2's inventory without recording why. Do not touch `Sources/VariorumCore/Sync/` except the ONE listed line
> in `SyncSchema.swift`. Never touch the real store, never a Release build, never `/Applications`.
> Commit trailer, every commit:
> `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>`
> `Claude-Session: https://claude.ai/code/session_01T5mNsXG5VTb9QKNPZMbWQE`
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

## 2b. THE ORCHESTRATOR'S RE-RUN + HER EXPANDED SCOPE (2026-09-04, at kickoff — BINDING additions to §2/§3)

**Her kickoff words, verbatim:** *"you will be handling removal of the fragments bridge & saving it under a branch +
a tag. … Also remove information about the bridge from wherever it was user facing - tutorial, settings, bridge
button on the homescreen, privacy brief for stargazing.tech agent, etc. At some point, maybe in the collaboration
phase, I'd bring back the fragments bridge under some kind of collaborator shape but this code should just be an
archive to reference."* The archive note (§1) quotes that last sentence verbatim and names 13m (file sharing — the
collaboration pre-requisite) as the era.

The orchestrator re-ran §2's greps on `ea47861` (`grep -rn -i -E 'fragments|bridge' Sources App Tests Tools
Spikes --include='*.swift'`, plus `notes/`, `Server/`, `.gitignore`). §2 holds; these are the DELTAS, each with
its step. "fragments" in `MobileTakesChrome*`, `Phase13DecorationSpike`, `ReadTierSpike`, `TK2Spike` means TextKit
layout fragments — not the bridge; leave. "bridge" in `TutorialSeeder.swift:1684`, `HelperView.swift:285`,
`EditorTypography.swift:99`, `AccountLifecycleTests.swift:19-27`, `AppSettingsView.swift:92`, `VariorumApp.swift:241`
is the ordinary English word — leave.

**A. USER-FACING copy the inventory missed (step 4):**
- **A1 · Settings ▸ Savepoints help** — `Variorum/Features/Settings/SavepointCadenceCopy.swift`: `insuranceNote`
  (line ~45) names "a journal entry arriving from Fragments" as an insurance occasion → drop it (three named
  occasions remain beside the setting's two = five, matching OverallModel §3's edit in step 6); the header comment
  (lines ~8-11) likewise. `SavepointOnLeaveTests` references the copy — check for a string pin and update it.
- **A2 · The Takes-mode notice on journal entries** — `Variorum/Features/Takes/TakesBoardView.swift:138-146` and
  `Variorum/Features/Editor/WriteTakesPanel.swift:83-91` (R84's "Fragments projection note"). **PROVISIONAL
  (orchestrator; bundled for her):** keep the notice's S5 half only, same placement (journal-shaped entries):
  *"Sync conflicts can add takes here; nothing is lost — choose what the entry shows."* The Fragments clause goes.
  Grep `VariorumTests` for the old string before editing (a pin may exist).
- **A3 · Settings ▸ Account** — `Shared/AuthViews.swift:281-306` (already §2's AuthViews): the "Journal bridge
  (Fragments)" section, `connectFragmentsJournalDelegated` / `disconnectFragmentsJournal`, `services.account.fragments`,
  the `ProjectConfig.fragmentsConfigured` gate — all go. The Variorum-project sign-in/out/create faces stay whole.
- **A4 · The tutorial: NO bridge lesson exists.** `TutorialSeeder.swift:21` and `MobileTutorialSeeder.swift:32-33`
  are comments giving R57's rationale (tutorial rows are non-journal because the bridge sweeps journal days). **The
  R57 RULE STAYS** — it still keeps tutorial rows out of the daily Journal's assembly and the phone's journal list —
  only its stated reason changes. Same in the pins' comments: `TutorialWalkTests.swift:176-188` and
  `MobileTutorialWalkTests.swift:218-230` keep their `journalShaped == 0` expectations; re-word the comment and the
  expectation message ("no tutorial row can ever reach the bridge" → "…the daily Journal"). Step 5.
- **A5 · The homescreen button** = `BridgeStatusRow` in `RootView.swift` (already §2). The sidebar comment
  `SidebarView.swift:176` ("protection/sync/bridge status rows") and `ProtectionStatusRow.swift:7` re-word (step 5).

**B. CODE the inventory missed:**
- **B1 (step 4)** · `Variorum/VariorumApp.swift:60-73` — the composition CALLER passing `bridgeEnabled: true` and
  `makeBridgeKeyProvider: { DeviceBridgeKeyProvider() }` (§2 listed `AppServices`' parameters, not this site);
  lines 144-145, the wake/foreground comment naming the bridge round.
- **B2 (step 4)** · `VariorumTests/Phase8ServicesTests.swift:31-40` — `AppTestBridgeKeyProvider: BridgeKeyProviding`
  dies with the protocol; trim every suite that consumed it.
- **B3 (step 4)** · `VariorumTests/EncryptionFlowTests.swift:1033-1052` and `TierAndOnboardingTests.swift:200-224`
  build `AppServices` with `fragmentsAuth:` / `bridgeEnabled:` — drop the arguments (the tests stay);
  `EncryptionFlowTests.swift:1066-1099` asserts the `bridge_day` staged re-push — that assertion rides
  `AccountRekey` step 6 and goes; the test's re-seal / re-enqueue halves stay.
- **B4 (step 2)** · `Tests/VariorumCoreTests/AccountLifecycleTests.swift:226-290`
  (`theRekeyRoadReSealsTheCorpusStagesTheBridgeAndFencesStaleWriters`) uses `BridgeEngine.recordDay` / `dayRow` /
  `restagedHashSentinel` — remove the bridge legs, keep the re-seal + stale-writer-fence assertions, rename the
  test. Lines 179-180 ("a fresh journal-bridge key") STAY — the vault format still mints the class.
- **B5 (keep; step 5 comment)** · `Shared/EncryptionSession.swift:588` compares `journalBridgeKeyID` inside the
  custody-matches-vault check — KEEP (the vault format carries the class; the design's "minted, dormant, one
  comment"); `:192`'s comment re-words. Likewise KEEP every `journalBridgeKey` fixture field in
  `KeychainOffMainTests` · `CustodyHandoverTests` · `KeychainTripwireTests` · `KeyVaultFormatTests` ·
  `VaultEnrollmentTests` · `KeyVaultClientTests` · `EncryptionFlowTests:810/896`, and `DeviceKeyMaterial`,
  `KeyVaultClient`, `VaultEnrollment`, `KeyVaultFormat`, `VaultBootstrap`, `Tools/VaultBootstrap`.
- **B6 (step 5)** · comments only: `Shared/AppSession.swift:306`, `Shared/StoreLaunchGate.swift:8`,
  `Theme/EditorBehaviorSettings.swift:10`, `VariorumMobileTests/MobileStarterJournalTests.swift:154`,
  `Spikes/DesignCorpusSeeder/Sources/main.swift:258` (a throwaway spike, no target — a one-word fix or leave).
- **B7 (leave)** · `.gitignore:11` (`.env.fragments-oauth.local` — a stray local file may exist on her machine; the
  ignore line costs nothing); `Server/supabase/*.sql` (deployed history; the vault's `journal_bridge_key_*` columns
  are the format). UNTOUCHED, recorded.

**C. DOCS beyond §2's list (step 6) — her "privacy brief for stargazing.tech agent, etc.":**
- **C1** · `notes/stargazing-privacy-policy-brief-13p.md` (lines 6, 19, 47-50, 78-80 name the journal bridge / its
  tier): ADD a dated DELTA block directly under the title — the journal bridge is RETIRED 2026-09-04 (tag named);
  Variorum's disclosure DROPS the journal-bridge tier (no user writing crosses to Fragments any more); the ONE
  Stargazing account line is UNCHANGED; the Fragments-side sanity-check ask is moot; **she carries the amended
  brief to the stargazing.tech agent** (list it in the author bundle).
- **C2** · `notes/stargazing-tech-website-brief.md:74-75` — the "Fragments bridge" feature bullet → keep the line,
  strike it with a dated RETIRED note (the site must not advertise it); lines 51/140 (one account) stay.
- **C3** · `notes/fragments-postures-brief-2026-09-01.md` + `notes/fragments-enrollment-brief-2026-08-31.md` — a
  dated banner under each title: the bridge is retired on the Variorum side (the §5 carry item is the authoritative
  word); the enrollment/ceremony spec stands on Fragments' OWN merits (build or not); nothing bridge-motivated is owed.
*[removed for publication]*
  at launch") and §4's rider (~line 186: "KEPT and PROMOTED — public at launch, never retiring") → dated
  SUPERSESSION notes: superseded by the pre-13x ruling 16 (2026-09-03/04, `pre-13x-postures-design.md` §1); the
  ONE account and the ONE sync payment covering both apps are UNCHANGED; revival shape = shared rows in a
  collaboration era.
- **C5** · `notes/QUESTIONS.md` — a new item **#89** (below #88) recording the retirement for her ratify list: the
  tag, the archive note, the two PROVISIONALs (A2's notice; C7's rationale re-base), the briefs she carries (C1, §5),
  and the bridge items it DISSOLVES. Append "(dissolved 2026-09-04 — the bridge is retired; see #89)" ONLY to
  still-open bridge-motivated text — #86(d)'s Fragments-only enrollment road (its spec stands on Fragments' merits;
  the 20.10 ceremony no longer waits on Variorum). Answered/ratified items (#1, #13–#16, #37, #38, #76, #78) are
  history — untouched.
- **C6** · `notes/MobileSoul.md` PL-9 — a dated "the delegated bridge door RETIRED 2026-09-04" note inside the row
  (the row stays as history). `notes/plans/mobile-round-2-orchestrator-handoff.md` item 16 (~line 1078, "THE
  FRAGMENTS BRIDGE DOES NOT RUN ON HER PHONE") — a dated DISSOLVED note; **and a dated MERGE NOTE for the mobile seat
  beside it:** the `mobile` branch (worktree `~/dev/variorum-mobile`, 66 ahead / 422 behind `main` on 2026-09-04)
  still carries every bridge file — its next merge from `main` meets delete/modify conflicts on them; take `main`'s
  deletions, drop the phone composition's `bridgeEnabled: false` argument and the `Phase9cAuthWiringTests` pin on it.
- **C7** · the daily Journal's never-hard-delete rationale — `notes/KnownIssuesAndTechDebt.md:37`,
  `notes/DetailedPlanForPhases.md:125` (the 13y row), `notes/plans/pre-13u-memo-daily-journal-identity.md`: "(the
  Fragments bridge cannot be rebuilt)" → per the design's §10 ("13i-e loses its 'the bridge cannot be rebuilt'
  reason; its identity half stands on its own"): replace with "(rationale re-based 2026-09-04: the bridge is retired;
  whether the daily Journal stays never-hard-deletable on identity grounds alone is 13i-e's sitting call)".
  **PROVISIONAL — bundled for her.**
- **C8 (leave)** · `notes/plans/pre-13x-postures-design.md` §10/§17b — the pre-13x orchestrator (THIS session)
  flips them at close, not the implementer. `notes/sync-postmortem-fragments.md` (her Fragments app's SYNC scars —
  about sync, not the bridge), `fragments-consent-page-spec.md`, `fragments-15_7-…`, every 9b/9c/14a/14b/14c/14d
  plan + handoff, both archives: HISTORY, untouched. `CLAUDE.md`: untouched.

**D. MACHINERY for this run (the environment section, applied):**
- The Xcode project is `PBXFileSystemSynchronizedRootGroup` throughout — file deletions need NO `project.pbxproj`
  edit. Reuse `-derivedDataPath App/Variorum/DerivedData/pre13x-b0` (gitignored, warm) for every `xcodebuild`.
- Her live real-store app (PID 79767, `/Applications/Variorum.app`) runs beside every suite — NEVER touched; the
  instance check before a suite is `pgrep -fl 'Variorum.app/Contents/MacOS'` (only her app is expected; the test
  host appears mid-run). No Release build, no `/Applications`, no real store.
- Waits: FOREGROUND, by poll loop (`until grep -q '<EXIT LINE>' <log>; do sleep 5; done`, repeated past the Bash
  timeout) — never `tail -f | grep -m1` (the protocol's 2026-09-04 addendum). Pass `-only-testing` flags as
  `"${ARGS[@]}"` (zsh does not word-split). The spine = the SIX suites in `TutorialWalkTests.swift` by TYPE name
  (`TutorialBookShapeTests` … `TutorialLookingActsTests`; 72 tests / 10 suites standing).
- Baselines at the Act 10 close: core 1525/165 · Mac 2106/378 · spine 72/10 (batch 0 may have moved the Mac count —
  record actuals; expected = baseline minus the deleted bridge cases). Swift Testing's N counts skipped tests.
- Names per §1: `archive/fragments-bridge` + `archive/fragments-bridge-2026-09-04` (the design §15's
  `fragments-bridge-archive` wording is superseded by this file). Step 1 tags whatever `main` HEAD is when it runs —
  which includes this amended plan; that is the intended "last `main` before removal".
- Sizes for the record: 2,781 lines leave `Sources/…/Bridge` + `BridgeSession` + `BridgeStatusViews` +
  `Phase9bBridgeWiringTests`; 4,319 lines leave the 16 core test files.

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
- `grep -rn -i -E "fragments|bridge" Sources App Tests Tools --include='*.swift'` → only the vault-format
  `journalBridge` symbols, TextKit's layout "fragments", the ordinary English "bridge", and history comments remain —
  each read and recorded in §6.
- Her expanded scope (§2b): Settings ▸ Savepoints' help no longer names Fragments; no Takes-mode notice names
  Fragments; Settings ▸ Account shows only the Variorum sign-in; the tutorial carries no bridge text (it never did —
  recorded); the privacy brief, the website brief and the two outbound Fragments briefs carry their dated deltas.

## 5. THE OUTBOUND CARRY ITEM (appended to `notes/fragments-bridge-contract.md`; she carries it)
> **CARRY ITEM (2026-09-04) — the journal bridge is RETIRED on the Variorum side.** Variorum removed its
> half of the journal bridge from `main` (archived at tag `archive/fragments-bridge-2026-09-04`). Nothing is
> owed by Fragments: the 20.10 passphrase-set ceremony is moot for the bridge's sake (build it or not on
> your own merits); the journal-class E2EE bodies already in `journal_entries` are yours to keep, migrate or
> drop; the `journal_bridge` class key remains in the suite vault format, dormant. UNCHANGED: the ONE
> Stargazing account and the suite issuer (14a/14d) — this retires the bridge, not the account. If the
> bridge ever returns it returns as shared rows on Variorum's own sync in a collaboration era, designed then.

## 6. THE RECORD (the implementer writes; LIVE STATUS first)

**Session: the Fable implementer, 2026-09-04, from the KICKOFF PROMPT; tree at kickoff `32d3fdf` (clean, in sync
with origin); her live app PID 79767 running beside every suite, untouched. No revert is in flight at any point in
this record unless a line below says so.**

- **LIVE STATUS:**
  - step 1 — DONE (branch `archive/fragments-bridge` + tag `archive/fragments-bridge-2026-09-04` both at `32d3fdf`,
    both pushed and verified on `origin`; `notes/archive/fragments-bridge.md` written; this record opened) — `4c1d443`
  - step 2 — DONE — `Sources/VariorumCore/Bridge/` (6 files, 2,226 lines) + the 16 core test files (4,319 lines)
    deleted; `applyBridgeLanding` removed (`Operations+Sync.swift`, the `label` doc re-worded); `AccountRekey` step 6
    removed (doc + code; the marker clears after step 5; "steps 4–5 are idempotent"); `Operations+Container`'s seven
    bridge doc lines re-worded (history kept where it explains a shape — her verbatim #37 ruling stays);
    `AccountLifecycleTests`' B4 legs removed, the test renamed `theRekeyRoadReSealsTheCorpusAndFencesStaleWriters`;
    **`BridgeHash` moved verbatim to `Sources/VariorumCore/Domain/BridgeHash.swift` (name kept, fork F1)** with its
    three SHA-256 vector pins carried into `SampleLibraryDedupeRepairTests.theManifestHashRecipeIsStableSHA256Hex`.
    `swift build` clean; **`swift test`: `Test run with 1390 tests in 152 suites passed`** (1525/165 − 13 deleted
    suites; 136 bridge tests gone, 1 pin added; the ONE skipped test is the standing env-gated real-Supabase pass,
    skipped at every baseline) — commit PENDING(hash)
  - step 3 — NOT-STARTED — settled design: migration **`v1_16_drop_bridge_tables`** (NOT v1_15 — see delta D2);
    `SyncSchema.localOnlyTables` loses the two names; `MigrationTests.expectedTables` loses them + a migrate-from-v1_15
    pin
  - step 4 — NOT-STARTED
  - step 5 — NOT-STARTED
  - step 6 — NOT-STARTED
  - step 7 — NOT-STARTED
- **Counts:** core **1390/152 green (step 2)** · Mac PENDING · iOS build PENDING · spine PENDING
- **Deltas from §2/§2b's inventory found by the re-run greps (on `32d3fdf`):**
  - **D1 · `BridgeHash.body` is NOT bridge-only.** It is the sample library's manifest hash recipe: `SampleLibrarySeeder`
    (`:154`, `:333-334`, `:361` — the bundled manifest's title→hash entries were computed with it), the dedupe facts
    wired at `SyncSession.configure`, `Sync/SampleLibraryDedupe.swift:21`'s doc, and three SURVIVING tests
    (`SampleLibraryDedupeFactsTests`, `SampleLibraryManifestTests`, `SampleLibraryDedupeRepairTests`). Deleting the
    module as listed would break the build and the shipped manifest. → fork F1.
  - **D2 · `v1_15` is taken** (`v1_15_note_version_index`, pre-13u Act 4 / 17c P20). The drop migration is
    `v1_16_drop_bridge_tables`. The archive note names v1_16.
  - **D3 · `NoteVersionsPaneTests.theBridgeRowTakesTheLiveVoiceAndTheMacPassesIt` (`:369`) reads
    `Shared/BridgeStatusViews.swift` and `Variorum/RootView.swift` AS SOURCE TEXT** — it dies with the file. Deleted in
    step 4 (its subject, the bridge row's alarm token, no longer exists).
  - **D4 · `SavepointOnLeaveTests.swift:325`** — `#expect(note.contains("Fragments"))`: the string pin §2b-A1
    anticipated; flipped in step 4 to the surviving wording.
  - **D5 · `BridgeStateTests` carries nothing forward:** its registry/mirror walks are the GENERAL pins in
    `SyncSchemaTests.registryMatchesLiveSchemaExactly` (`localOnlyTables == allTables − synced`, which stays green by
    construction once the tables are dropped and de-listed) and `SerializerCompletenessTests`. Deleted whole.
  - **D6 · `Operations+Container.swift` references `BridgeEngine` in DOCS only** (`:111`) — no code edit, comments only.
  - **D7 · `applyBridgeLanding` has zero surviving callers** outside the deleted module/tests (one doc mention,
    `AppSession.swift:306`, re-worded in step 5).
  - The rest of §2/§2b holds exactly (line counts match: 2,226 in `Bridge/`, 4,319 across the 16 core test files).
- **Forks (the implementer proposes, the architect rules):**
  - **F1 · `BridgeHash` — PROVISIONAL: move verbatim, keep the name.** Options: (a) move the enum unchanged to
    `Sources/VariorumCore/Domain/BridgeHash.swift` with a doc comment saying the name is history and the recipe is the
    manifest's; (b) rename to e.g. `ContentHash` — touches `Sync/SampleLibraryDedupe.swift`'s comment (inside the
    fence) and the shipped-manifest tests for no behavioral gain; (c) leave a typealias. **(a) chosen:** zero `Sync/`
    touches, zero behavioral change, the manifest's hashes stay valid; the three `bodyHashIsStableSHA256Hex` pins from
    the deleted `FragmentsContractTests` move into `SampleLibraryDedupeRepairTests` so the recipe stays pinned. A
    rename is a later touch under the `Sync/` rider (18a/13y) if she wants the word gone.
- **Open items for the orchestrator:** PENDING

## 7. THE COLD REVIEW (after §6 says DONE)
A FRESH Fable reviewer runs `notes/REVIEW_PROMPT.md` verbatim over the combined diff (`git diff
<archive-tag>..HEAD`), zero framing. Findings land in this file's §8 before any fix. Round 2 only if a
BLOCKER/MAJOR appears. Foci the orchestrator may append AFTER the cold pass (never before): the 14a direct
sign-in is behaviorally byte-identical; `resyncReinitialize` and `AccountRekeyMarker` semantics unchanged
without step 6; no bridge door renders in either app.

## 8. FINDINGS + DISPOSITIONS
(empty until the review)
