# The Fragments bridge — RETIREMENT (pre-13x batch 0b, run as its OWN session before the key work)

**Status: IMPLEMENTED 2026-09-04 — §6 says DONE (seven steps, seven commits, every suite green on the final tree); the cold review (§7) is next.** *(Was:)* **KICKED OFF 2026-09-04 by the author under `/architect-phase` (a fresh Fable orchestrator session; her kickoff words and expanded scope are recorded in §2b); the implementer runs from the KICKOFF PROMPT below.** *(Was: PLANNED 2026-09-04 at the pre-13x kickoff sitting; NOT RUN.)* Her ruling (pre-13x design §1
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
> *(The two trailer lines that stood here were RETIRED by her 2026-09-04 rule — CLAUDE.md's Environment notes: commit messages carry NO attribution trailer. Left as the record of what this unit's first commits carried; never copy them.)*
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
    skipped at every baseline) — `ee09c50`
  - step 3 — DONE — migration **`v1_16_drop_bridge_tables`** (`DROP TABLE IF EXISTS bridge_day; … bridge_state;` —
    local-only, no §12 event, marker stays 7; the v1_4 block's comment re-headed as history, the migration itself
    untouched); **the ONE `Sync/` touch: `SyncSchema.localOnlyTables` loses the two names and its four-line doc
    re-words** (the deleted `BridgeStateTests` reference had to go with them — same block, recorded);
    `MigrationTests.expectedTables` loses them; new pin `theRetirementMigrationDropsTheBridgeTablesFromAnOlderStore`
    (migrate `upTo: v1_15_note_version_index` → both tables present, a row inserted → full migrate → both gone and
    the table set == `expectedTables`; red on the old tree by construction). Filtered walk (`MigrationTests` ·
    `SyncSchemaTests` · `SerializerCompletenessTests` · `SupabaseTransportTests`) 46/6 green; **`swift test`:
    `Test run with 1391 tests in 152 suites passed`** — `80f88bc`
  - step 4 — DONE (Mac; the iOS build passed at this step — recorded at step 5) — deleted `Shared/BridgeSession` · `Shared/BridgeStatusViews` ·
    `Shared/SignInFlow` (bridge-only: its one production caller was the delegated Fragments-project door) ·
    `VariorumTests/Phase9bBridgeWiringTests`. `AppServices`: the second auth session, the bridge composition, the
    `makeBridgeTransport`/`makeBridgeKeyProvider` seams, `bridgeEnabled`/`bridgeMinimumRoundInterval`, the
    `onRoundCompleted → bridge.trigger()` hook, the whole Fragments-session section, `AccountState.fragments`;
    `triggerLifecycleRound` kept as the ONE became-active door (one sync trigger now). `SyncSession`:
    `onRoundCompleted` KEPT as an unsubscribed seam, doc re-worded (recorded; a future follower's home).
    `AuthSession`: PKCE · `authorizeURL`/`handleCallback`/`exchangeCode` · `callbackWithoutCode` ·
    `KeychainAuthStorage.fragmentsService` removed; **`LegacyPasteInCleanup.clear()` now also deletes the retired
    Fragments-session Keychain item on the same occasion (first real sign-in) — PROVISIONAL P1 below.** `AuthViews`:
    the "Journal bridge (Fragments)" section + its divider gone. `ProjectConfig`: every Fragments constant gone.
    `EncryptionKeychain`: `DeviceBridgeKeyProvider` gone. `ErrorPresentation`: the `SignInFlow.FlowError` and both
    `.callbackWithoutCode` arms gone. `RootView`: the bridge row AND the account sheet it alone opened
    (`accountSheetShown` + its `.sheet`; the sync row hosts its own `AccountView`). `VariorumApp`: the composition
    caller's two bridge arguments (B1). A1 the Savepoints help (three occasions) + A2 the two Takes notices (the S5
    half only — PROVISIONAL, §2b's wording). Tests: `Phase8ServicesTests`' provider (B2); `Phase9cAuthWiringTests`
    trimmed to the sync half — the bridge cadence/ordering pins, the 14d liveness pin, the `SignInFlow` message pins
    and the transport's park/gate machinery gone, the retirement walk RE-POINTED (`SignInFlow.swift` absent,
    no `ASWebAuthentication`/`custom:stargazing` anywhere under `Shared/` — red on old) and the paste-in walk
    extended to the Fragments-session service string; `AuthSessionTests`' delegated-door + PKCE cases (the deleted
    bridge cases; the direct sign-in cases UNMODIFIED); `EncryptionFlowTests`/`TierAndOnboardingTests` lose the two
    arguments, the re-key test its staged-day leg (B3); `NoteVersionsPaneTests`' source-reading bridge-row test (D3);
    `SavepointOnLeaveTests`' pin flipped to `!contains("Fragments")` (D4, red on old). Touched suites
    (`AuthSessionTests` · `Phase9cAuthWiringTests` · `TierAndOnboardingTests` · `EncryptionFlowTests` ·
    `NoteVersionsPaneTests`): **`Test run with 50 tests in 5 suites passed`** — `6188d52` (the
    `TierAndOnboardingTests` name did not match a suite type — its cases ride the full Mac run at step 7).
    **iOS: `xcodebuild build -scheme VariorumMobile -destination 'generic/platform=iOS Simulator'` → `** BUILD
    SUCCEEDED **`; `MobileStarterJournalTests` on iPhone 17 Pro / OS 26.2 → `Test run with 14 tests in 1 suite
    passed`** (the mobile tutorial suites are seven TYPES in `MobileTutorialWalkTests.swift` — run at step 7).
  - step 5 — DONE — the comment sweep, 44 files (19 core · 13 app/mobile · 12 test): present-tense claims that the
    bridge reads/pushes/sweeps re-worded (`renderedText`/export lists, the join-brain notes, the insurance-occasion
    lists, the R57 rationale in both tutorial seeders + both `nothingSeededIsJournalShaped` pins — the RULE and the
    `journalShaped == 0` expectations unchanged, the message now names the daily Journal — A4; the V3 must-pin's
    rationale re-based on the notebook rule; `KeyVaultFormat`'s class marked DORMANT; `SidebarView`/
    `ProtectionStatusRow` per A5); history left as history where it reads as such (`OwnerIdentity`'s 9c keying
    note, `CommitBar`'s "SignInFlow lesson", `ChromeMinHeightTests`' fixture provenance, her verbatim #37 quotes in
    `Operations+Container`/`BookStructureModel:654`, `HelperView`/`TutorialSeeder:1684`'s "promote is the bridge",
    the English "bridge"/"bridges" in `AccountLifecycle`/`IdentityProjectionAudit`/`OriginBlockDoorTests`/
    `RecoveryDoorsTests`/`EditorTypography`/`EditorUndoHint`/`MobileEditorViewModel`). **UNTOUCHED, recorded:**
    `Sync/` docs naming the bridge (`SyncEncryption.swift:19` "the journal-bridge key is the bridge's… never enters
    the engine" — still true; `SupabaseTransport.swift:49/174` "the bridge transport's fakes" / "mirrored from the
    9b bridge transport" — history; `Repairs.swift:191` "⌘J / the bridge / the phone's capture MINTED"; the
    `SampleLibraryDedupe.swift:21` `BridgeHash` reference — still true) and `Spikes/DesignCorpusSeeder` (no target).
    `swift build` clean — `66e68bf`
  - step 6 — DONE — canon: AppSpec §9 (`applyBridgeLanding`'s row struck to a RETIRED one-liner naming the tag; the
    `resolveSyncConflict` bridge sentence past-tensed, the `label` parameter kept generic; `shelveInDailyJournalBook`'s
    door list + "all four doors (three since…)"); SyncSpec §3's wire paragraph (the `journal_entries.body` sentence
    past-tensed, the class key dormant); OverallModel §3 (six → FIVE quiet occasions, the Fragments landing named as
    the retired sixth); the master plan (the 9b row's RETIRED note with tag/branch/revival shape; the not-in-this-order
    list's 13v struck; the 13y row's rationale re-based — C7); `FuturePhases` 13v RETIRED with the revival shape;
    MobileSoul PL-9's dated retirement note (the row's status cell → dissolved); KnownIssues: the bridge-push-sweep
    row REMOVED (resolved by retirement), the daily-Journal row's rationale re-based (C7). Briefs: C1 the privacy
    brief's dated DELTA (the journal-bridge tier drops from Variorum's disclosure; the ONE account unchanged; she
    carries it); C2 the website brief's bullet struck RETIRED; C3 dated banners under both Fragments briefs; C4 two
    dated SUPERSESSION notes in the release strategy (§1's SUITE bullet, §4's rider); C5 QUESTIONS **#89** appended
    (the tag, the archive note, PROVISIONALs (a) the Takes notice + (b) the C7 re-base, the briefs she carries, the
    dissolutions) and #86(d) marked dissolved-as-a-bridge-question in place; C6 the mobile handoff's item 16 DISSOLVED
    with the MERGE NOTE for the mobile seat (`main`'s deletions win; drop the phone's `bridgeEnabled: false`; the
    `BridgeHash` new home); C7 the identity memo's rationale note. **The §5 CARRY ITEM appended verbatim to
    `notes/fragments-bridge-contract.md`.** C8 untouched as instructed (`pre-13x-postures-design.md` §10/§17b are the
    architect's). — `a2704c4`
  - step 7 — DONE — the §4 residue grep read whole and classified (below); EIGHT more present-tense comment lines
    it surfaced fixed before the final runs (`PostRenderQueryTests:442` · `Phase13SurfaceQueryTests:10/110` ·
    `JournalEntryTests:259` · `ExportProjectionTests:13` · `NoteVersionsTests:100` — it named the DELETED
    `BridgeVersionTests` · `Migrations.swift:189`'s lens comment · `OperationError.swift:24`; and MobileSoul PL-13's
    "bridge deletion-travel engine" parity phrase marked retired). Then, on the FINAL tree, in this order and never
    two at once on the shared DerivedData: `swift test` → **`Test run with 1391 tests in 152 suites passed`**; the
    full Mac suite (`-only-testing:VariorumTests`) → **`Test run with 2094 tests in 378 suites passed`**, `** TEST
    SUCCEEDED **`, 2 skipped = batch 0's env-gated iCloud-Keychain probes (skipped by default, as batch 0 recorded);
    the tutorial spine (the TEN suite types in `TutorialWalkTests.swift`) → **`Test run with 72 tests in 10 suites
    passed`**, 0 skipped; the phone (iPhone 17 Pro / OS 26.2): the seven `MobileTutorialWalkTests.swift` types +
    `MobileStarterJournalTests` → **`Test run with 41 tests in 8 suites passed`**, 0 skipped (the iOS BUILD passed
    at step 4). Her app PID 79767 ran beside every suite, untouched; no Release build; no `/Applications`; no real
    store — commit `d17fe45`
- **Counts (final tree):** core **1391/152** (baseline 1525/165 − 13 deleted suites; 136 bridge tests gone, 2 pins
  added: the `BridgeHash` vectors, the v1_16 migration) · Mac **2094/378** (baseline 2106/378 − 15 deleted bridge
  cases [`Phase9bBridgeWiringTests` 5/1 · `Phase9cAuthWiringTests` 5 · `AuthSessionTests` 4 · `NoteVersionsPaneTests`
  1] + batch 0's +3 tests / +1 suite — the arithmetic closes exactly) · spine **72/10** · iOS **build green;
  41/8** on the simulator
- **The §4 residue grep, classified (every surviving "fragments"/"bridge" in `Sources App Tests Tools`, DerivedData
  and TextKit's layout "fragments" excluded — 260 lines):** 61 the vault-format `journalBridge` family
  (`KeyVaultFormat` · `DeviceKeyMaterial` · `VaultEnrollment` · `KeyVaultClient` · `AccountRekey` · `VaultBootstrap`
  · `EncryptionSession:588` · the custody fixtures — KEPT by design, the class marked DORMANT); 22 `BridgeHash` (the
  manifest recipe, fork F1); 62 dated history notes this session wrote ("retired 2026-09-04"); 10 in `Sync/`
  (UNTOUCHED: `SyncEncryption:19` still true; `SupabaseTransport:49/174` history; `Repairs:191` a door list;
  `SampleLibraryDedupe:21` still true; `SyncSchema:248-250` the ONE touch; `SyncScheduler:55-56` the English verb);
  the remaining 105 are the English word ("bridges to", "a bridge across", "the storage delegate bridge",
  "`NSPanel` bridge", "bridged ObjC factory", "promote is the bridge" — her tutorial/help copy), her verbatim
  rulings (#37's "the fragments entries should arrive as part of Journal"), the v1_4 migration's own DDL and
  history block, the v1_16 migration and its pin, and history notes that read as history (`OwnerIdentity`'s 9c
  keying, `ChromeMinHeightTests`' fixture provenance, `VisibilitySkewTests`/`SerializerCompletenessTests`' "Fragments
  post-mortem"). No present-tense claim that the bridge runs survives.
- **Inventory deltas, final:** D1–D7 above, all handled; plus the eight late comment lines (step 7) and the
  `TierAndOnboardingTests`/`MobileTutorialWalkTests` file-vs-type naming notes (steps 4/7).
- **UNIT CLOSED 2026-09-04 (the orchestrator).** Commits: the plan `32d3fdf` (the archive tag/branch point) · the implementer's seven `4c1d443` `ee09c50` `80f88bc` `6188d52` `66e68bf` `a2704c4` `d17fe45` · the orchestrator's `566cb93` (round-1 findings) `5a49fc78` (round-1 fix pass) `a7797b0`/`d640761` (13i-e rulings) `72b0acb` (13i-e second message) `152fe37` (WalkKit) `65af5e4d` (round-2 fix pass — the first no-trailer commit) · the close commit (this one). Review ladder: three rounds, closed at the cap (§8). The install refresh: see the close commit's §8 line.
- **Open items for the orchestrator (the implementer's list, kept as the record — every one dispositioned in §8):**
  1. **The walk (§4, hers/the orchestrator's, dev store):** no bridge row in the sidebar's status family; the Account
     sheet (opened from the sync row) shows only the Variorum sign-in/create/delete faces; ⌘J still mints and shelves
     today's entry; a sync round completes; Settings ▸ Savepoints' help names three occasions; the Takes-mode journal
     notice reads its S5 half. Not walked by this session (headless).
  2. **QUESTIONS #89 for her:** PROVISIONAL (a) the Takes notice's wording · (b) the C7 rationale re-base; the briefs
     she carries (privacy DELTA + website bullet → the stargazing.tech agent; the CARRY ITEM → the Fragments agent).
  3. **Fork F1 / P1 for the architect:** `BridgeHash`'s kept name (a `Sync/`-rider rename later if wanted); the
     retired Fragments-session Keychain item cleared at her next real sign-in only, never logged out server-side.
  4. **C8, the architect's own edits:** `pre-13x-postures-design.md` §10 → "DONE (tag …)", §17b — not touched here.
  5. **The mobile seat's merge note** (item 16 of its handoff) — the `mobile` branch meets delete/modify conflicts on
     every bridge file at its next merge; `main`'s deletions win.
  6. **`SyncSession.onRoundCompleted`** kept as an unsubscribed seam (recorded at step 4) — remove at a later `Shared/`
     touch if no follower appears.
  7. **The cold review (§7):** the combined diff is `git diff archive/fragments-bridge-2026-09-04..HEAD`; the
     orchestrator's after-pass foci from §7 apply (the 14a direct sign-in byte-identical in behaviour — its
     `AuthSessionTests` cases ran UNMODIFIED; `resyncReinitialize`/`AccountRekeyMarker` semantics without step 6 —
     `AccountLifecycleTests` + `EncryptionFlowTests`' re-key test green; no bridge door renders — the walk's).
- **Machinery honesty:** one session, no deaths, no resumes; every step's commit pushed before the next began; the
  eight late comment fixes ride this step-7 commit (recorded above).
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
  - **P1 · the retired Fragments-session Keychain item — PROVISIONAL: cleared locally at the next real sign-in.**
    Her Keychain holds `io.lduarte.Variorum.fragments-auth` (the bridge's Fragments-project session). Options:
    (a) leave it (harmless, her machine, nothing reads it); (b) clear it on the `LegacyPasteInCleanup` occasion —
    the first real sign-in — precedent-shaped, no launch-path Keychain hop (the 13e windowless-launch class);
    (c) clear it at every launch off-main. **(b) chosen** (one enum, one occasion); until she signs in again the
    item simply sits. The Fragments project's refresh token is NOT logged out server-side (no client remains to
    present it; it expires unused) — recorded for the orchestrator. **RULED at round 1 (MINOR-1): (b) AND (c) —
    the sweep runs at every `start()` off-main as well; and the premise was false: a Supabase refresh token never
    expires unused, so the carry item asks Fragments to revoke the sessions server-side.**
  - **F1 · `BridgeHash` — PROVISIONAL: move verbatim, keep the name.** Options: (a) move the enum unchanged to
    `Sources/VariorumCore/Domain/BridgeHash.swift` with a doc comment saying the name is history and the recipe is the
    manifest's; (b) rename to e.g. `ContentHash` — touches `Sync/SampleLibraryDedupe.swift`'s comment (inside the
    fence) and the shipped-manifest tests for no behavioral gain; (c) leave a typealias. **(a) chosen:** zero `Sync/`
    touches, zero behavioral change, the manifest's hashes stay valid; the three `bodyHashIsStableSHA256Hex` pins from
    the deleted `FragmentsContractTests` move into `SampleLibraryDedupeRepairTests` so the recipe stays pinned. A
    rename is a later touch under the `Sync/` rider (18a/13y) if she wants the word gone.

## 7. THE COLD REVIEW (after §6 says DONE)
A FRESH Fable reviewer runs `notes/REVIEW_PROMPT.md` verbatim over the combined diff (`git diff
<archive-tag>..HEAD`), zero framing. Findings land in this file's §8 before any fix. Round 2 only if a
BLOCKER/MAJOR appears. Foci the orchestrator may append AFTER the cold pass (never before): the 14a direct
sign-in is behaviorally byte-identical; `resyncReinitialize` and `AccountRekeyMarker` semantics unchanged
without step 6; no bridge door renders in either app.

## 8. FINDINGS + DISPOSITIONS
### Round 1 — the cold review (a FRESH Fable reviewer, `notes/REVIEW_PROMPT.md` verbatim over `git diff archive/fragments-bridge-2026-09-04..HEAD` at `d17fe45`; recorded 2026-09-04 by the orchestrator BEFORE any fix session; the reviewer's own words, its incremental findings file copied whole; dispositions follow in the round's adjudication block below)

# Cold review — the Fragments bridge retirement (pre-13x batch 0b)

Diff under review: `git diff archive/fragments-bridge-2026-09-04..HEAD` (7 commits 4c1d443..d17fe457, 122 files, +711/−8331).
Reviewer: fresh Fable, zero implementation context. Verification: every load-bearing claim located in code/tests; the touched core suites RE-RUN here (`swift test --filter 'MigrationTests|SampleLibraryDedupeRepairTests|SyncSchemaTests|SerializerCompletenessTests|AccountLifecycleTests'` → `Test run with 58 tests in 6 suites passed`). Mac suites NOT re-run by me: the orchestrator's hands-on walk is in flight on the shared `pre13x-b0` DerivedData (a Debug app, PID 4626) and the record forbids two users of it at once — the Mac claims are verified by reading (the count arithmetic closes: 2106 − 15 + 3 = 2094 / 378 − 1 + 1 = 378; core 1525 − 136 + 2 = 1391 / 165 − 13 = 152).

## Findings (severity-ranked)

### MAJOR-1 · SEQUENCING HAZARD — the CARRY ITEM invites Fragments to "drop" journal bodies while her INSTALLED Mac build still runs the live bridge, and that bridge lands a Fragments tombstone as a BLANK entry
- Where: `notes/fragments-bridge-contract.md` (the 2026-09-04 CARRY ITEM: "the journal-class E2EE bodies already in `journal_entries` are yours to keep, migrate or drop"); `notes/plans/pre-13x-bridge-retirement.md` §6 open items 1–2 and `notes/QUESTIONS.md` #89 ("Briefs you carry" with no ordering against the `/Applications` refresh).
- Mechanism, traced in the archived engine (`archive/fragments-bridge-2026-09-04:Sources/VariorumCore/Bridge/BridgeEngine.swift:384-517`): an incoming Fragments tombstone → `effectiveBody = ""`; for an agreed day whose Variorum text is unchanged since the agreement (`onlyFragmentsChanged`) the engine calls `applyBridgeLanding(firstVariantID, in:, body: "")` — the entry's block is BLANKED (one insurance auto-commit of the pre-image), and the blank then syncs to the mirror and the phone. `/Applications/Variorum.app` is dated 2026-09-02 03:48 (the Act 10 close), it IS her running app (PID 79767), and it carries the 14d-live bridge wired with `DeviceBridgeKeyProvider`. Nothing in the record, the archive note or #89 says "refresh the install (or press Disconnect on the old build) BEFORE handing the carry item over".
- Not a defect in the diff's code; a hole in the phase's own deliverables. Recoverable per entry through Block History, but it is exactly the "silent stale projection" class 9b was hardened against, now reachable through the retirement's own hand-off order.
- Fix (record + docs, no code): (a) amend the CARRY ITEM — Fragments must NOT tombstone/delete `journal_entries` rows on their sync-visible road until Variorum confirms the installed build no longer runs the bridge (or drop the "or drop" clause); (b) in #89 and the open items, ORDER her acts: refresh `/Applications` from this tree (or, the zero-build mitigation, Settings ▸ Account ▸ Disconnect on the installed build — which stops the bridge) BEFORE carrying the brief; (c) one line in the record noting the installed build keeps running the bridge until the refresh. No pin possible (process); disposition by record.

### MINOR-1 · the P1 disposition rests on a FALSE premise: the retired Fragments-project refresh token does NOT "expire unused"
- `App/Variorum/Shared/AuthSession.swift:157-163` (+ §6 P1, #89): the retired Fragments session item is cleared LOCALLY only on the `LegacyPasteInCleanup` occasion — `AppServices.variorumSignInChanged` (`AppServices.swift:352`) — which `start()` never routes through when it adopts a persisted session (`AppServices.swift:247-251`). A user who never signs out again keeps a live cross-project refresh token in the file-based login keychain (`kSecAttrAccessibleAfterFirstUnlock`) indefinitely.
- The premise: Supabase docs — "refresh tokens never expire but can only be used once"; time-box / inactivity timeouts are "only available on Pro Plans and up" and are enforced only at the next refresh (https://supabase.com/docs/guides/auth/sessions). So the token is valid until revoked, and `POST /auth/v1/logout` (scope `local`) is the only thing that destroys it server-side (https://supabase.com/docs/guides/auth/signout).
- Fix: clear the item from `start()` off-main (that path is already async; a `SecItemDelete` in a detached task is not the 13e main-thread class), and — since `ProjectConfig`'s Fragments coordinates are gone — record honestly that the server-side session is NOT revoked and stays valid until she signs out of Fragments globally from the Fragments app (or ask the Fragments agent, in the carry item, to revoke her Variorum-bridge sessions). Correct the "expires unused" wording in §6 P1 / #89 either way. Pin: a wiring test that `start()` with a persisted Variorum session and a seeded Fragments item leaves the item absent (red on old).

### MINOR-2 · `notes/OverallModel.md` §3 line 34 contradicts itself inside the sentence the phase edited: "five quiet automatic exceptions" … "the other FOUR are insurance"
- Five total − the two cadence occasions = THREE insurance occasions (sealing, locking, structural undo). `SavepointCadenceCopy.swift`'s header says "three others" correctly; the canon sentence still says four. (NIT beside it: AppSpec §9 and the archive note call the bridge landing "the sixth quiet occasion" while the deleted `Operations+Sync` doc and the archived engine call it "the fifth" — an ordinal of history, harmless.)
- Fix: "the other three are insurance".

### MINOR-3 · 17d's P30 is now an OPEN standing-fix item on a DELETED file
- `notes/plans/phase-17-standing-fixes.md:561-580, 627-642`: 17d is "open, unstarted, 5 items" and P30 (`Sources/VariorumCore/Bridge/BridgeEngine.swift:240` · MINOR · CONFIRMED — the bridge's shelving-failure note) is hollow since step 2 deleted the file; the entry header still says "P30 is `Bridge/`, not `Sync/`". The plan's §2 "any other bridge row likewise" reached KnownIssues but not the standing-fixes ledger, and CLAUDE.md makes a 17-entry a first-class owner exactly like a phase — so this is an owned item pointing at nothing.
- Fix: mark P30 DISSOLVED (2026-09-04, the bridge retired; the trace lives at the tag), drop "bridge" from 17d's title line or mark it, 5 items → 4.

### MINOR-4 · dead seams kept "for a future follower", and a source-walk pin that enforces one of them
- `SyncSession.onRoundCompleted` (`SyncSession.swift:47`, fired at `:131`) is a `var` no production code sets; `AppServices.triggerLifecycleRound()` (`AppServices.swift:273-280`) is a one-line wrapper over `sync.triggerSync()`; `Phase9cAuthWiringTests.theBecomeActiveHookRoutesThroughTheLifecycleCadence` FORBIDS the direct `services?.sync.triggerSync()` in `VariorumApp.swift` to protect the wrapper. The plan's own §1 argument (archive; never leave machinery that "still compiles, still claims…") cuts against speculative seams, and the pin now guards an indirection with no observable behaviour. Recorded as open item 6 — filed so it gets a decision rather than drifting.
- Fix: remove `onRoundCompleted` (and the now-orphaned rationale at `SampleLibrarySeeder.swift:578-581`), inline the hook, retire the source-walk test; or keep all three and name the follower in the doc.

### MINOR-5 · `App/Variorum/Shared/SampleLibrary/SampleLibrarySeeder.swift:317` — a present-tense claim the step-5 sweep missed in a file it touched (`:578`)
- "`BridgeHash.body` … is already the bridge's own change-detection recipe" — the bridge has no change detection any more. Fix: "was the retired bridge's change-detection recipe; kept as the manifest recipe (`Domain/BridgeHash.swift`)".

### NIT-1 · `App/Variorum/Shared/AuthSession.swift:41` — `import CryptoKit` is unused now (SHA256 left with PKCE).
### NIT-2 · `LegacyPasteInCleanup.clear()` hard-codes the account `"session"` beside the private `KeychainAuthStorage.account = "session"` — two copies of one identity string; make the constant internal and reference it (a drift here silently turns the delete into a no-op).
### NIT-3 · `Sources/VariorumCore/Sync/Repairs.swift:191` — "⌘J / the bridge / the phone's capture MINTED" names a door that no longer exists (inside the `Sync/` fence; recorded as untouched — a one-word touch whenever `Sync/` is next open under the rider).
### NIT-4 · the record (`pre-13x-bridge-retirement.md` §6) carries two leftover placeholders: step 7 "commit PENDING(hash)" (it is `d17fe45`) and a second, stale "**Open items for the orchestrator:** PENDING" line at :464 below the filled list.

## Clean bill (load-bearing things checked and found solid)

- The archive: tag `archive/fragments-bridge-2026-09-04` and branch `archive/fragments-bridge` both at `32d3fdf` (the amended plan's commit — the intended "last `main` before removal"), the tag present on `origin` (`git ls-remote`); HEAD == origin/main (d17fe45), working tree clean; `notes/archive/fragments-bridge.md` is a complete, greppable map (what left, what stays and why, the revival shape verbatim).
- `BridgeHash.body` moved VERBATIM (byte-compared against the tag's `FragmentsContract.swift:82-86`); the manifest recipe pinned to independently computed SHA-256 vectors in `SampleLibraryDedupeRepairTests.theManifestHashRecipeIsStableSHA256Hex`; `Sync/SampleLibraryDedupe`'s reference untouched; zero `Sync/` behaviour change.
- `v1_16_drop_bridge_tables`: `DROP TABLE IF EXISTS` on two LOCAL-ONLY tables (no `sync_version`, no triggers, no FKs, never in the registry) → no §12 lockstep event, marker 7 correct; `v1_4` kept (append-only); the pin migrates `upTo: v1_15_note_version_index`, inserts a row, migrates fully, asserts EXACT-set equality with `expectedTables` — red on old by construction. `SyncSchemaTests.registryMatchesLiveSchemaExactly` asserts `localOnlyTables == allTables − synced`, so the de-listing is pinned from both sides. Re-run here: green.
- `AccountRekey`: steps 1–5 byte-unchanged; the marker (`AccountRekeyMarker`) still set after authorization and cleared only after the whole (now shorter) road; the doc's crash windows 2→3 / 3→4 / 4→5 still describe the code; `resyncReinitialize` untouched; `AccountLifecycleTests.theRekeyRoadReSealsTheCorpusAndFencesStaleWriters` keeps the re-seal + stale-writer-fence assertions (re-run here: green); `EncryptionFlowTests.theRekeyWiringRunsTheBrainAdoptsCustodyAndReEnqueues` keeps the marker-clear assertion.
- `applyBridgeLanding` had zero surviving callers (grep); `autoCommitDirtyVariants` keeps four callers (lock family, versions); `resolveSyncConflict`'s `label` stays generic with its default; `OperationError.blockNotPlaced` keeps seven throwers; the `journalBridge` vault class is still minted at enrollment/re-key and compared in the custody check (kept by design, marked DORMANT).
- The 14a direct sign-in is behaviourally byte-identical: `AuthSession`'s password grant / refresh / adopt / signOut / signUp untouched; `AuthSessionTests`' direct-sign-in cases unmodified (only the four delegated/PKCE cases deleted); `Phase9cAuthWiringTests`' adoption / fence / sign-out pins unmodified in substance; the retirement walk now forbids `custom:stargazing` and `ASWebAuthentication` anywhere under `Shared/` and asserts `SignInFlow.swift` is absent (red on old).
- `LegacyPasteInCleanup.clear()`'s delete query mirrors `KeychainAuthStorage.baseQuery` exactly (class / service / account; file-based keychain, no data-protection flag) → the delete matches the item the old code wrote.
- The Account sheet stays reachable: `SyncStatusViews.swift:178` hosts `AccountView` from the sync row; `RootView`'s removed sheet was the bridge row's alone. The mobile composition (`VariorumMobileApp.swift:67-70`) never passed bridge arguments on `main` → the iOS-build claim is consistent.
- The tutorial's R57 rule (`journalShaped == 0`) survives in both seeders and both pins; only its stated reason changed. `SavepointOnLeaveTests`' pin flipped to `!contains("Fragments")` (red on old); `SavepointCadenceCopy.insuranceNote` names three occasions.
- Canon: AppSpec §9 (`applyBridgeLanding` struck with the tag; `resolveSyncConflict` past-tensed; `shelveInDailyJournalBook`'s door list), SyncSpec §3, the master plan's 9b/13v/13y lines, FuturePhases 13v, MobileSoul PL-9/PL-13, KnownIssues (the bridge-push-sweep row removed — resolved by retirement; the daily-Journal rationale re-based PROVISIONAL), the privacy/website/Fragments briefs and the release strategy all carry dated notes naming the tag; CoreDescription carries no bridge mention; CLAUDE.md untouched; `Server/`, `.gitignore`, the 9b–14d plans/handoffs untouched as history.
- The residue grep (274 lines) read whole: every surviving "bridge"/"fragments" in `Sources App Tests Tools` is the vault-format `journalBridge` family, `BridgeHash`, TextKit layout fragments, the English word, her verbatim rulings, the v1_4/v1_16 DDL, or a dated history note — except MINOR-5 and NIT-3.
- Nothing in the diff copies text across entities, tracks word-level change, or makes cost scale with corpus size (the diff removes the one corpus-shaped sweep the bridge had).
- The §7 after-pass foci: (1) 14a direct sign-in byte-identical — verified above; (2) `resyncReinitialize`/`AccountRekeyMarker` semantics without step 6 — verified above; (3) no bridge door renders — the orchestrator's walk (in flight), not verifiable headless here; by reading, `BridgeStatusRow`, the "Journal bridge (Fragments)" section and the Fragments Savepoints/Takes copy have no surviving call sites.

### Round 1 — THE ORCHESTRATOR'S WALK (2026-09-04, the §4 walk on the dev store, the Debug build at `d17fe45`'s tree — a finding the cold pass could not reach by reading)
- **W-1 · BLOCKER (use-shaped, reproduced twice) · the LIBRARY CATALOG IS EMPTY on the retired build — "Nothing matches." under `all` with an empty query — while the SHELF renders the same store's four books with their note counts; the CONTROL build (the archive tag's tree, built in a throwaway worktree and launched on the SAME dev store) lists every book and note.** Evidence: captures `walk/library`, `walk/library2`, `walk/retired-library-2` (retired) vs `walk/control-library` (control); the dev store's WAL untouched since 11:35 (no writes from any door); `sample` of the retired process shows an idle main thread and no GRDB frames (no wedged read); no `lastError` renders (`LibraryCatalogView.swift:651` shows one when set). `Queries.searchCatalog` is byte-identical across the diff and is a plain SELECT over `reading` + `container` that cannot be empty where `observeBookshelf` shows four books — so the mechanism is app-side and not yet traced. MECHANISM: PENDING (bisect in flight: the tree at `80f88bc`, before step 4's app removal). Nothing lands until it is traced and pinned red-on-old.
- **W-2 · recorded, not a finding · ⌘J / ⌘N and typed text did NOT reach the app under the walk's synthetic events** (the search field never received "sherlock"; the AX menu click on File ▸ Today's Entry, enabled, changed nothing; no WAL write followed) — the walk harness, not the diff, is the first suspect for these three; W-1 is independent of it (a real sidebar click, a pure read).
- **W-3 · verified on the dev store:** no bridge row in the sidebar's bottom rows ("protection" + "Sync off (dev store)" only; the control build shows the retired "Bridge off" row beneath them); Settings ▸ Appearance's Savepoints help names three insurance occasions and no Fragments; Settings' six tabs carry no bridge text; the menus carry no bridge item. NOT walkable on the dev store: the Account sheet (its only door is the sync row's, which the dev store's fence renders doorless — verified by the diff + `TierAndOnboardingTests`/`AuthSessionTests`), a sync round (fenced off), the Takes-mode journal notice (blocked behind W-2).

### Round 1 — ADJUDICATION + THE FIX PASS (the orchestrator, as the architect's adjudication edits — 2026-09-04)
Every finding traced by the orchestrator against the code before its disposition; the spec outranks both agents.
- **MAJOR-1 — CONFIRMED (process, docs-only).** The mechanism holds at the tag (`BridgeEngine.swift:384-517`: an incoming tombstone on an agreed, locally-unchanged day lands `applyBridgeLanding(body: "")`), and her installed build is the Act 10 close's. FIXED by record: the carry item loses "or drop" and gains TWO ASKS (no deletions until Variorum's word; revoke the bridge's sessions server-side); QUESTIONS #89 carries THE ORDER OF HER ACTS (refresh or Disconnect FIRST, the carry item ONLY THEN); the handoff repeats it. No pin (process).
- **MINOR-1 — CONFIRMED; FIXED with a pin.** The sweep now also runs at every `AppServices.start()`, off-main (`Task.detached`), through an injected `legacyCleanup` seam (default `LegacyPasteInCleanup.clear`); the sign-in occasion routes through the same seam. The false premise corrected in the code doc, §6 P1 and #89; the carry item asks Fragments to revoke. **Pin:** `Phase9cAuthWiringTests.startRunsTheRetiredCredentialSweep` — a spy through the seam (never the real Keychain: the retired item's identity on this machine IS her installed build's live bridge session — a real-Keychain pin would have disconnected her running app). Red-on-old form: step 1 landed the INERT seam + the pin and ran RED (`start()` did not call the sweep); step 2 added the call and ran GREEN. Result lines: RED run `Test run with 11 tests in 1 suite failed after 3.010 seconds with 1 issue` — `startRunsTheRetiredCredentialSweep … (sweeps.count → 0) >= 1`, the other ten green; GREEN run below.
- **MINOR-2 — CONFIRMED; FIXED** (`OverallModel.md` §3: "the other three").
- **MINOR-3 — CONFIRMED; FIXED** (17d: P30 DISSOLVED with the tag named; 5 → 4 items; the header's `Bridge/` sentence marked moot).
- **MINOR-4 — CONFIRMED; RULED: REMOVE, not name a follower.** The plan's own §1 argument governs (no dormant machinery): `SyncSession.onRoundCompleted` and its `seenRounds` firing are gone (the status stream is the seam); `AppServices.triggerLifecycleRound()` is gone and the became-active hook calls `services?.sync.triggerSync()`; the source-walk pin is rewritten to assert the direct door and the wrapper's absence (`theBecomeActiveHookRunsOneSyncRound`); `SampleLibrarySeeder`'s orphaned rationale re-worded. Neither the phone nor `Sync/` referenced either symbol (grep-verified).
- **MINOR-5 — CONFIRMED; FIXED** (past tense, points at `Domain/BridgeHash.swift`).
- **NIT-1 — FIXED** (`import CryptoKit` dropped; nothing in the file used it). **NIT-2 — FIXED** (`KeychainAuthStorage.account` internal, referenced by the sweep). **NIT-3 — FIXED by the orchestrator under the `Sync/` rider** (a comment inside `Repairs.swift` — the ONE additional `Sync/` touch of this unit, comment-only, recorded). **NIT-4 — FIXED** (the record's placeholders).
- **The orchestrator's own find — FIXED:** two KnownIssues rows still pointed at "the bridge-push-sweep row above" after it was removed; re-worded as history.
- **W-1 — DOWNGRADED to OBSERVED-ONCE, no mechanism, no fix.** Not reproduced in three further launches of the same build: one replaying the Settings-tabs excursion, one replaying the Today's-Entry attempts (which then SUCCEEDED end to end: ⌘J minted + shelved the day, Takes mode opened with the trimmed notice, the Library listed the new Journal book + the entry) and one plain. The diff carries no non-comment change on any read path (`git diff -w` over `Queries/`, `Persistence/`, `Domain/`, `Models/`, `Auth/` and the app tree outside the intended files: only `BridgeHash` and `v1_16`); the control tree ran the same query code. First place to look if it ever recurs: `LibraryCatalogView`'s `search()` generation guard / a cancelled `.task` on first appearance (SPECULATIVE). W-2's dead keystrokes belong to the same first launch and are the walk harness's.
- **Verification of the fix pass (2026-09-04, her app PID 79767 beside it, untouched):** Mac — the eight touched files' 33 suite types (`Phase9cAuthWiringTests` · `AuthSessionTests` · the tier/onboarding suites · `EncryptionFlowTests` · the Phase 8 services suites · the Keychain-off-main suites · `SampleLibraryDedupeFactsTests` · the TEN tutorial-spine suites) → **`Test run with 176 tests in 33 suites passed after 55.909 seconds`**, 0 skipped, `** TEST SUCCEEDED **`; iOS — `xcodebuild build -scheme VariorumMobile` → `** BUILD SUCCEEDED **`; core — `swift build` clean (the only core touch is one comment in `Sync/Repairs.swift`; the core suite stood at 1391/152 on `d17fe45` and no core code changed). **Machinery lesson, repeated the hard way:** the first green attempt passed the spine's ten names as ONE unquoted `$SPINE` and three files' suite names by FILE name — 32/4 ran and the spine did not; zsh does not word-split, and `-only-testing` wants the `@Suite` TYPE names (`TierAndOnboardingTests.swift` holds `HostedSyncTierFaceTests` …). The re-run grepped every `struct …Tests` per file into a proper array. The fix pass is ONE commit — `5a49fc78`.
- **Round 2:** REQUIRED by §7 (a MAJOR appeared) — a FRESH Fable reviewer over the fix diff.

### Round 2 — the cold review (a FRESH Fable reviewer over `git diff d17fe45..5a49fc78`, anchored on this §8; recorded verbatim 2026-09-04 BEFORE any fix — its incremental findings file copied whole)

# Cold review ROUND 2 — the Fragments bridge retirement (pre-13x batch 0b)

Fix diff under review: `git diff d17fe45..5a49fc78` (the round-1 fix pass). Context diff: `git diff archive/fragments-bridge-2026-09-04..5a49fc78`.
Anchor: §8's round-1 findings + the ADJUDICATION + FIX PASS block. Reviewer: fresh Fable, round 2, zero implementation context.

## Status log (incremental)
- [start] plan read (§1–§8). Reading the fix diff next.

## Round-1 dispositions — HOLD / NOT (filled as verified)

## New findings (severity-ranked)

## Clean bill
- [read] fix diff (13 files) read whole; AppServices.start()/init, AuthSession KeychainAuthStorage+LegacyPasteInCleanup, SyncSession status stream, VariorumApp hook, Phase9cAuthWiringTests (helpers + both pins + retirement walk), EncryptionFlowTests.withDoorWorld, TierAndOnboardingTests world, the archived AuthSession.signOut + AppServices.disconnectFragmentsJournal, the carry item, #89, OverallModel §3, 17d/P30, KnownIssues rows, Repairs.swift comment.
- [facts] Debug bundle id = io.lduarte.Variorum.debug (pbxproj); installed /Applications DR = identifier "io.lduarte.Variorum"; Debug DR = "io.lduarte.Variorum.debug". The AppServices A4 comment "Debug and release builds share a bundle identity and Keychain" is STALE.
- [facts] withWiredServices (Phase9cAuthWiringTests, 7 uses) and withDoorWorld (EncryptionFlowTests, 4 uses) construct AppServices with the DEFAULT legacyCleanup and call start() → the REAL LegacyPasteInCleanup.clear() (SecItemDelete on io.lduarte.Variorum.fragments-auth/session and io.lduarte.Variorum.sync/supabase) runs inside the test host at every start(). Only the new pin injects a spy.
- [facts] archived disconnectFragmentsJournal → fragmentsAuth.signOut() → best-effort POST auth/v1/logout on the FRAGMENTS project (server-side revocation) then local clear. So "Disconnect on the installed build" (MAJOR-1's zero-build mitigation) is ALSO a revocation road — #89/the carry item do not say so.
- [facts] "the handoff repeats it" (MAJOR-1 disposition): no handoff file for this batch exists; the ORDER text appears only in the plan file and #89 (grep).
- [facts] W-1 downgrade reasoning verified: git diff over Queries/ Models/ Auth/ MarkdownSyntax + the app files outside the intended set → comment-only (non-comment grep empty). searchCatalog("") → LIKE %% (non-empty); refreshNoteCards does not bump searchGeneration. Mechanism still untraced — observed-once stands.
- [run] pins: first attempt with method-level -only-testing matched 0 tests in the suite (Swift Testing wants `name()`); re-run in flight. The sibling tests of Phase9cAuthWiringTests / EncryptionFlowTests were deliberately NOT run: they sweep the real Keychain item this review is forbidden to touch (that is itself the evidence for N1).
- [lookup] Sonnet lookup on legacy-keychain SecItemDelete vs ACL in flight.
- [run] pins re-run with `name()` identifiers: `Test run with 2 tests in 1 suite passed` (startRunsTheRetiredCredentialSweep, theBecomeActiveHookRunsOneSyncRound) — log r2-pin-run2.log.

## DRAFT dispositions (pending the lookup's answer for N1's severity)
- MAJOR-1: HOLDS WITH GAPS — carry item amended (no "or drop"; two asks), #89 carries the order; BUT (a) "the handoff repeats it" is untrue at HEAD (no handoff exists for this batch; grep finds the order only in the plan + #89); (b) the order omits that Disconnect on the RUNNING installed build is ALSO the server-side revocation road (archived signOut POSTs auth/v1/logout) and that the "install refresh" does not stop the running old process until it is quit → N2.
- MINOR-1: HOLDS (pin real, green here; red-on-old by construction — nothing else calls the seam in the pin's world) — but the fix's REACH is unrecorded: the default seam runs the real sweep in the test host (two helpers, 11 uses) and on dev-store launches → N1.
- MINOR-2/-5, NIT-1/-2/-3/-4: HOLD (diff verified).
- MINOR-3: HOLDS in substance; residual: 17d's title "Purge, sync & bridge honesty" + the master plan's 17 row "17d (purge/sync/bridge honesty…)" still carry the word (NIT).
- MINOR-4: HOLDS (both symbols gone repo-wide; pin rewritten and green); residual: SyncSession.swift:116-117 still says "(+ the round-completion hook: roundsCompleted increments…)" directly above the parenthetical saying the hook left (NIT).
- W-1: downgrade's reasoning VERIFIED (comment-only read paths); mechanism untraced; observed-once stands.
- [facts] pbxproj: Debug config (block 606–638) PRODUCT_BUNDLE_IDENTIFIER = io.lduarte.Variorum.debug; Release (641–672) = io.lduarte.Variorum. The test host (xcodebuild test = Debug) and Xcode Run both carry the `.debug` identity; only the Release install carries the installed item's identity.

## New findings — DRAFT
### N1 · [MAJOR if legacy-keychain deletion is not ACL-gated; MINOR otherwise] · AppServices.swift:259 + Phase9cAuthWiringTests.swift:60-95 (withWiredServices) + EncryptionFlowTests.swift:1033-1053 (withDoorWorld) · the round-1 fix's sweep runs the REAL Keychain delete from every test world that calls start() with the default seam, and from every dev-store (Xcode Run) launch
- Mechanism: `AppServices.init` defaults `legacyCleanup` to `{ LegacyPasteInCleanup.clear() }`; `start()` fires it detached unconditionally (no `storeVariant` gate). `withWiredServices` (7 uses) and `withDoorWorld` (4 uses) construct AppServices WITHOUT `legacyCleanup:` and call `start()` → 11 tests issue `SecItemDelete(kSecClassGenericPassword, service io.lduarte.Variorum.fragments-auth, account "session")` in the test host at every run; the sign-in occasion (`variorumSignInChanged`, pre-fix since step 4) reaches the same delete from the tests that sign in. The fix-pass verification run (176/33, both suites inside) therefore executed this delete against the login keychain — the item the pin was carefully NOT allowed to touch ("a real-Keychain pin would have disconnected her running app").
- Whether the delete LANDS depends on the legacy keychain's ACL semantics for deletion (the test host's DR is `io.lduarte.Variorum.debug`, the item's creator `io.lduarte.Variorum`): [LOOKUP RESULT HERE].
- Either way: the record's "never the real Keychain" claim and the helper's own "(never the real Keychain in tests)" contract are false for the suite as a whole; a dev-store launch reaches the real account's retired credential (the A4 fence's spirit); and if the delete lands, the running installed build is silently disconnected at its next relaunch WITHOUT the server-side logout its Disconnect door performs, which forecloses N2's road and changes the state #89's ordering advice describes.
- Fix: (a) gate the launch sweep on `storeVariant == .real` (the fence's own seam — the pin already builds a `.real` world, so it stays green); (b) both test helpers inject an inert `legacyCleanup: {}` (the wiring helper's comment already promises this for the key provider); (c) one line in §8 recording that the fix-pass run swept the real item (or could have). Pins: `.dev` start() → `sweeps.count == 0` after settle (RED on the current tree), and the existing `.real` pin stays.

### N2 · MINOR · notes/QUESTIONS.md #89 + notes/fragments-bridge-contract.md carry item ask (2) + §8 MAJOR-1 disposition · the ordering advice omits the one act that BOTH stops the old engine AND revokes the server session, and mis-describes the refresh road
- Archived `AppServices.disconnectFragmentsJournal` → `fragmentsAuth.signOut()` → best-effort `POST auth/v1/logout` on the Fragments project, then the local clear — i.e. Disconnect on the RUNNING installed build (tokens in memory, refreshed proactively) is the server-side revocation ask (2) exists for, and needs no build, no agent, no coordination. #89 lists it as the "zero-build" alternative to the refresh and says revocation needs the Fragments agent or a global Fragments sign-out.
- The "install refresh FIRST" road: copying the Release product over `/Applications` does not stop PID 79767 (the old code keeps running until she QUITS it — and sessions never quit it); the new build's first `start()` then deletes the item with NO logout (the ProjectConfig coordinates are gone by design) — so the refresh road forecloses the revocation road once the old app is quit.
- Also: the disposition says "the handoff repeats it" — no handoff exists for this batch (no `notes/handoffs/*bridge*`; grep for the order finds only the plan + #89).
- Fix (docs): #89's order becomes "1. press Settings ▸ Account ▸ Disconnect (journal bridge) on the running installed build NOW — it logs the bridge's Fragments session out server-side (best-effort) and stops the engine; 2. the install refresh at the window (quit + relaunch); 3. the carry item" — and ask (2) becomes "verify/revoke any leftover"; drop or fulfil the "handoff repeats it" claim. No pin (process/docs).

### N3 · NIT · App/Variorum/Shared/AppServices.swift:158-163 (the A4 fence comment) · "Debug and release builds share a bundle identity and Keychain" is false on this tree (Debug = `io.lduarte.Variorum.debug`) — the premise round 1 and the orchestrator reasoned from about which builds reach which Keychain items; fix the words (pre-existing, but it sits in the file this fix touched and it governs N1's severity reasoning).

### N4 · NIT · App/Variorum/Shared/SyncSession.swift:116-117 · the comment "Status → the observable surface (+ the round-completion hook: roundsCompleted increments exactly once per finished round)" survives directly above the parenthetical saying the hook left — one stale clause; drop "(+ the round-completion hook…)".

### N5 · NIT · notes/plans/phase-17-standing-fixes.md:576 ("## 17d — Purge, sync & bridge honesty") + notes/DetailedPlanForPhases.md:207 ("17d (purge/sync/bridge honesty…)") · MINOR-3's fix said "drop 'bridge' from 17d's title line or mark it"; the status line and the Bridge/ sentence were marked, the title and the master plan's row were not.
- [facts] archived AuthSession refreshes LAZILY (on currentSession() near expiry, expiryMargin 60 s), not by timer → Disconnect's logout presents the in-memory access token; revocation lands when a bridge round ran within the token's lifetime (~1 h). `refresh` → `store.save` (add-or-update) re-creates the Keychain item after any sweep while the old app runs.

## Clean bill (round 2)
- The two round-1 pins are real and green when run alone here: `Test run with 2 tests in 1 suite passed` (r2-pin-run2.log); `startRunsTheRetiredCredentialSweep`'s red-on-old holds by construction (no sign-in in its world, no other caller of the seam).
- `triggerLifecycleRound` / `onRoundCompleted` gone repo-wide (App + Sources + Tests grep; the phone never referenced them); `VariorumApp`'s hook calls `services?.sync.triggerSync()`; `roundsCompleted` still counted by the scheduler and consumed by EncryptionFlowTests:1264-1268.
- `LegacyPasteInCleanup.clear()`'s query == `KeychainAuthStorage.baseQuery` (class/service/account, legacy keychain, no DP flag) with the account now the shared constant; `save` is add-or-update so a swept item is re-created by a still-running old build's refresh.
- The carry item: "or drop" gone; ask (1) no deletions until Variorum's word, ask (2) revoke — present verbatim; #89 carries the order and the corrected token premise; OverallModel §3 "the other three"; 17d 4 items + P30 DISSOLVED with the tag; KnownIssues' two dangling "row above" references re-worded; Repairs.swift:191 one comment line (the ONE extra Sync/ touch, comment-only); SampleLibrarySeeder :317/:578 past-tensed; `import CryptoKit` gone (no CryptoKit symbol left in AuthSession.swift).
- W-1's downgrade: read paths comment-only across the whole retirement diff (Queries/, Models/, Auth/, MarkdownSyntax; the app files outside the intended set) — verified by a non-comment-line grep; `searchCatalog("")` is a `%%` LIKE (never empty on a populated store); `refreshNoteCards` never bumps `searchGeneration`. Untraced remains untraced; observed-once is the honest label.
- Nothing in the fix diff copies text across entities, tracks word-level change, or scales with corpus size.
- NOT re-run here, deliberately: the full `Phase9cAuthWiringTests` / `EncryptionFlowTests` suites — their default-seam worlds run the real sweep (N1); this review is forbidden to touch that item.

## LOOKUP RESULT (Sonnet, external facts) → N1 FINALIZED at MAJOR
- Apple DTS (Quinn), forums thread 724013, verbatim: "Without it [kSecUseDataProtectionKeychain], the call will delete items in file-based keychains as well. This is very dangerous because those items might belong to other apps, or the system." and "Deleting a keychain item, using SecItemDelete, doesn't require its key material, and thus a delete will succeed when the item is otherwise unavailable."
- Ownership is by designated requirement (thread 738571) → `io.lduarte.Variorum.debug` is a DIFFERENT owner from the installed `io.lduarte.Variorum`.
- No source pins the exact outcome (silent success / prompt / OSStatus) for a same-team different-identifier caller; the fix pass's 176/33 run passed in 55.9 s with no hang → no consent prompt blocked it, so the delete either landed silently or failed silently. `LegacyPasteInCleanup.clear()` carries no `kSecUseDataProtectionKeychain` — it is exactly the unscoped-on-macOS shape Apple's engineer warns about.
- Verdict: MAJOR — the mechanism is traced and Apple's own guidance says the delete reaches other apps' items; the landing is unobserved only because this review may not read that item. The fix (gate on `.real` + inert seams in the two helpers + the `.dev` red pin) is the same either way.

### Round 2 — ADJUDICATION + THE FIX PASS (the orchestrator, 2026-09-04)
- **THE FACT FIRST (checked by attribute lookup only — `security find-generic-password -s io.lduarte.Variorum.fragments-auth -a session`, no secret read): the retired Fragments-session item is ABSENT from her login keychain; the Variorum-project session item beside it is intact (mdat 2026-09-04 18:06Z).** The round-1 fix pass's verification run issued the `SecItemDelete` eleven times from the test host with the file-based-keychain shape; Apple's guidance (the reviewer's lookup) says that shape reaches other apps' items. Whether the item was present before that run cannot be proven from here, so the honest statement is: **my verification run most likely removed the installed build's bridge session item.** Consequence: her RUNNING installed build (PID 79767) holds its bridge tokens in memory and keeps running until she quits it; at its next relaunch the journal bridge will show DISCONNECTED, without the server-side logout its Disconnect door performs. Nothing of her writing is touched; the Fragments-project session stays valid server-side until revoked (the carry item asks) or she signs out of Fragments globally. This is the retirement's intended end state reached by the wrong road, and it is recorded here as the orchestrator's own miss.
- **N1 — CONFIRMED (MAJOR, mine); FIXED with a pin.** (a) the launch sweep is gated on `storeVariant == .real` (the A4 fence's own seam); (b) both helpers (`withWiredServices`, `withDoorWorld`) inject `legacyCleanup: {}` — their "never the real Keychain in tests" contract is true again; (c) the fact above recorded. **Pin:** `startOnTheDevStoreNeverRunsTheSweep` — a `.dev` world with the spy seam, RED on the round-1 tree (the sweep fired on every start), GREEN with the gate; the `.real` pin stays green. Result lines: RED run `Test run with 12 tests in 1 suite failed after 0.865 seconds with 1 issue` — `startOnTheDevStoreNeverRunsTheSweep … (sweeps.count → 1) == 0`, the other eleven green; GREEN run (the five touched files' 28 suite types incl. the TEN spine suites) `Test run with 149 tests in 28 suites passed after 55.908 seconds`, 0 skipped, `** TEST SUCCEEDED **`; iOS `** BUILD SUCCEEDED **`. The gate reads `sync.allowsSync` (the A4 fence's own seam, `storeVariant == .real` — the variant is an init parameter, not stored). The round-2 fix pass is ONE commit — `65af5e4d` — the FIRST of this repo under her no-trailer rule.
- **N2 — CONFIRMED; FIXED by record.** #89's order is now: (1) Settings ▸ Account ▸ Disconnect (journal bridge) on the RUNNING installed build — it stops the engine AND logs the bridge's Fragments session out server-side (best-effort; needs no build); (2) the install refresh at the window — QUIT + relaunch, since copying over `/Applications` does not stop the running process; (3) the carry item. The carry item's ask (2) becomes "verify/revoke any leftover". The false "the handoff repeats it" claim is replaced: the order lives in #89 and in the closing message to her; the pre-13x orchestrator handoff's PENDING slot names it.
- **N3, N4, N5 — FIXED** (the A4 comment's identity wording; the stale hook clause; 17d's title and the master plan's 17 row mark the bridge half dissolved).
- **Round 3:** REQUIRED (a NEW MAJOR in round 2) — a FRESH Fable reviewer, a full pass focused on N1's fix and what it touched; the hard cap.
- **HER WORD on the fact above (2026-09-04, verbatim):** *"it's fine if you delete my installed build's live bridge session. I'm having fragments delete the bridge as well. the bridge is dying + I have my passphrase so my work won't be deleted - I didn't expect the bridge to survive + I expect that you will install a new version of the app that doesn't have the bridge at all when your work is done. I have quit my app so it's ready to be installed"* — so: the swept item is ACCEPTED (the fix still lands — a dev-store launch must never reach the login keychain); MAJOR-1's sequencing hazard is MOOT by her acts (the old engine is quit and will be replaced before it runs again; Fragments is deleting its side at her hand); and **the `/Applications` refresh is AUTHORIZED for this unit's close** — after round 3, behind a WAL-safe backup of her real store (the new build's first launch runs `v1_16` on it), at the zero-instance window she opened.


### Round 3 — the cold review (a FRESH Fable reviewer over `git diff 5a49fc78..65af5e4d`, the hard cap; recorded verbatim 2026-09-04 — its findings file copied whole)

# Cold review ROUND 3 — the Fragments bridge retirement (pre-13x batch 0b) — the hard cap

Fix diff under review: `git diff 5a49fc78..65af5e4d` (the round-2 fix pass — five commits: the 13i-e re-scope ×3, Tools/WalkKit, the fix commit `65af5e4d` itself). Context: `git diff d17fe45..5a49fc78` (round-1 fix), `git diff archive/fragments-bridge-2026-09-04..65af5e4d` (the whole retirement: 130 files, +1176/−8372).
Anchor: §8's round-2 ADJUDICATION + FIX PASS block. Reviewer: fresh Fable, round 3, zero implementation context. Read-only; nothing edited, nothing committed; her keychain items never queried.

## Status log (incremental)
- [start] plan read whole (§1–§8). The context snapshot in this session's preamble predates the unit (its git status ends at `ea47861`) — every canon-doc claim was therefore verified ON DISK at HEAD, never from the preamble.
- [read] round-2 fix diff (17 files) read whole; round-1 fix diff read for context; AppServices, AuthSession (KeychainAuthStorage + LegacyPasteInCleanup), SyncSession, Phase9cAuthWiringTests whole, EncryptionFlowTests.withDoorWorld, TierAndOnboardingTests.withServices, VariorumApp/VariorumMobileApp compositions, SyncStatusViews' dev-store doors, the archive note, memo §0, #89, the carry item, 17d, the master-plan 17/13i rows, KI row 37, the orchestrator handoff's PENDING slot.
- [facts] AppServices construction sites at HEAD: VariorumApp, VariorumMobileApp, Phase9cAuthWiringTests ×3 (inert / spy / spy), EncryptionFlowTests.withDoorWorld (inert), TierAndOnboardingTests.withServices (DEFAULT seam on `.real` — inert only because it never calls `start()` and adopts before wiring).
- [facts] `variorumSignInChanged` (AppServices:360-374) calls `legacyCleanup()` UNGATED by `sync.allowsSync`, synchronously on the MainActor. Dev-store production reach: none — `AccountView` is presented only from the sync row's sheet (SyncStatusViews:178) and `SyncRowFace.face` returns `doors: []` when `!allowsSync`.
- [facts] SyncSession.swift:16-17 still says "Debug and release builds share a bundle identity and therefore a Keychain" (N3's twin, uncorrected).
- [facts] `notes/plans/pre-13x-orchestrator-handoff.md:51` PENDING slot = "The bridge retirement's landing: PENDING(tag · final commit · review verdict)" — it does NOT name the order of her acts (the round-2 N2 disposition says it does). No `notes/handoffs/*` names it either.
- [facts] The record's "the hash in §6's close" (round-1 AND round-2 fix passes): §6 carries neither `5a49fc78` nor `65af5e4d`; `65af5e4d` appears nowhere in the plan file.
- [facts] pbxproj: Debug `io.lduarte.Variorum.debug`, Release `io.lduarte.Variorum` (N3's fact holds). `cliclick 5.1` at `/opt/homebrew/bin/cliclick` (the README's claim holds). Both WalkKit helpers compile with `swiftc` (built to the scratchpad).
- [facts] Sync/ footprint of the whole retirement: `SyncSchema.swift` (9 lines) + `Repairs.swift` (1 comment) — exactly as recorded. `BridgeHash` code identical to the tag's modulo doc comments.
- [facts] memo §0's code claims verified: `createOrOpenJournalEntry` create-or-opens through `Queries.canonicalJournalEntry` (unarchived first, then earliest; an archived entry opens when it is all the day has); no uniqueness on `container.entry_date` in Migrations.
- [run] on HEAD, `pre13x-b0`, her app quit, no other xcodebuild: `Phase9cAuthWiringTests` + `AccountDoorWiringTests` (the two helpers the fix touched) → `Test run with 15 tests in 2 suites passed after 5.667 seconds`, `** TEST SUCCEEDED **`; `startOnTheDevStoreNeverRunsTheSweep` ✔ 0.417 s, `startRunsTheRetiredCredentialSweep` ✔, `theBecomeActiveHookRunsOneSyncRound` ✔, `theDelegatedBrowserFlowAndBothIssuerDirectionsStayOut` ✔. The tutorial spine (the ten `TutorialWalkTests.swift` types) → `Test run with 72 tests in 10 suites passed after 27.439 seconds`, `** TEST SUCCEEDED **`.
- [red-on-old] `startOnTheDevStoreNeverRunsTheSweep`: not re-run on the old tree here; RED by traced construction — the round-1 diff (`d17fe45..5a49fc78`, AppServices:253) shows the detached sweep UNCONDITIONAL, so a `.dev` world's spy counted 1 (the record's `(sweeps.count → 1) == 0` line matches that mechanism exactly).

## Round-2 dispositions — HOLD / NOT
- **N1 (MAJOR) — HOLDS.** The launch sweep is gated `if sync.allowsSync` (AppServices:268; `allowsSync` is set once at :162 from `storeVariant == .real` — the A4 fence's own seam); `withWiredServices` and `withDoorWorld` inject `legacyCleanup: {}`; the `.dev` pin exists and is green here, red-on-old by construction; the Keychain fact and her word are recorded verbatim. Residuals: the SIGN-IN occasion is not gated (finding 1) and one test world still carries the default seam (finding 2).
- **N2 (MINOR) — HOLDS in substance (MOOT by her word, recorded).** #89 carries the corrected three-step order and the carry item's ask (2) is "verify/revoke any leftover"; her acts (app quit, Fragments deleting its side, refresh authorized) supersede it. Residual: the disposition's replacement claim "the pre-13x orchestrator handoff's PENDING slot names it" is FALSE at HEAD (finding 5) — the second round in a row a "handoff says it" claim was written without the file saying so.
- **N3 (NIT) — HOLDS in `AppServices`;** the same stale sentence survives in `SyncSession.swift:16-17` (finding 3).
- **N4 (NIT) — HOLDS** (SyncSession:116-117 re-worded; verified).
- **N5 (NIT) — HOLDS** (17d's title + the master plan's 17 row mark the bridge half dissolved); residual at `phase-17-standing-fixes.md:578` (finding 7).

## New findings (severity-ranked)

### 1 · [MINOR] · `App/Variorum/Shared/AppServices.swift:360-374` (`variorumSignInChanged`) + the seam docs at `:97-99` and `AuthSession.swift:160-175` · the retired-credential sweep's SIGN-IN occasion is neither gated on `sync.allowsSync` nor off-main — the round-2 gate closed one of the seam's two occasions
- Mechanism: the seam has two callers. The launch one (`:268-270`) is now `if sync.allowsSync { Task.detached … }`. The sign-in one (`:368`) is a bare `legacyCleanup()` inside `Task { @MainActor … }` (`:252-256`): (a) on a `.dev` session a sign-in still reaches the login keychain's `io.lduarte.Variorum.fragments-auth` / `io.lduarte.Variorum.sync` items — the exact reach N1's gate exists to forbid ("a dev-store session must never reach the login keychain"); (b) it runs two `SecItemDelete`s synchronously on the MainActor — the class `KeychainOffMainTests.swift:7` forbids ("no synchronous Keychain hop ever runs on the main thread") and the reason the launch occasion was deliberately detached (`:257-258`). The seam's own docs (`AppServices.swift:97-99` "runs at every `start()` off-main"; `AuthSession.swift:160-165` "every `AppServices.start()`") now overstate the launch half (it is every REAL-store start) and understate the sign-in half.
- Reach today: production NONE on a dev store (the only sign-in door is `AccountView`, presented solely from the sync row's sheet, `SyncStatusViews.swift:178`, and `SyncRowFace.face` returns `doors: []` when `!allowsSync`); test host NONE at HEAD (every world that signs in after wiring injects an inert seam). The main-thread half is pre-existing (the 9c-era call site); the gate asymmetry is the round-2 fix's own. A future sign-in door reachable before/without the sync row (13s's first-run onboarding, a lobby sign-in) on a Debug build re-opens N1's reach through this occasion.
- Fix: one private `runRetiredCredentialSweep()` that checks `sync.allowsSync` and detaches, called from BOTH occasions; correct the two docs to "every real-store `start()` and every real-store sign-in, off-main". Pins (red-on-old, both against the spy seam, never the real Keychain): (i) a `.dev` world → `start()` → `auth.adopt(tokens)` after wiring → settle → `sweeps.count == 0` (RED today: the sign-in occasion fires); (ii) a `.real` world whose spy records `Thread.isMainThread` at the sign-in occasion → `false` (RED today: it fires on main).

### 2 · [MINOR] · `App/Variorum/VariorumTests/TierAndOnboardingTests.swift:215-223` (`withServices`) · the third `AppServices` test world keeps the DEFAULT seam — the real login-keychain `SecItemDelete` — on a `.real` variant; it is inert by accident, not by declaration
- Mechanism: `withServices` constructs `AppServices(… storeVariant: .real …)` without `legacyCleanup:` (grep: only the two round-2 helpers and the two spy pins pass it). Neither occasion fires today ONLY because the helper never calls `services.start()` and adopts its tokens (`:196`) BEFORE `AppServices` wires `setOnChange`. The round-2 comment in `withWiredServices` ("INERT in every test world") is true at HEAD by that accident; the natural future edit — `await services.start()` in this helper, e.g. for a tier test that needs the persisted-session path — is N1's mechanism verbatim, from the test host, against the installed build's items.
- Fix, the structural one (precedent in this very file: `makeSyncKeyProvider`'s doc — "REQUIRED at this seam so every composition site decides"): make `legacyCleanup` a REQUIRED init parameter (no default). The two production sites (`VariorumApp.swift:57`, `VariorumMobileApp.swift:67`) pass `LegacyPasteInCleanup.clear`; the five test sites pass `{}` or a spy — compile-time enforcement, no source-walk pin needed. Minimal alternative: `legacyCleanup: {}` in `withServices` + extend `thePasteInIsFullyRetiredInTheSharedSources`'s walk with an assertion that every `AppServices(` in `VariorumTests/` passes `legacyCleanup:` (red today on this file).

### 3 · [NIT] · `App/Variorum/Shared/SyncSession.swift:16-17` · "Debug and release builds share a bundle identity and therefore a Keychain" — N3's exact stale premise, in the header of a file the round-2 fix touched (`:116`); the corrected wording lives only in `AppServices.swift:157-161`. Fix: "share the machine's LOGIN KEYCHAIN under different bundle identities (`io.lduarte.Variorum.debug` / `io.lduarte.Variorum`)".

### 4 · [NIT] · `notes/plans/pre-13x-bridge-retirement.md` §8 (round-1 fix-pass verification, round-2 N1 disposition) · two forward references to "the hash in §6's close" with no such line — §6 records neither fix-pass commit; `5a49fc78` appears only in the round-2 header and `65af5e4d` nowhere in the file (the round-1 NIT-4 placeholder class recurring). Fix: one line in §6 — "round-1 fix pass `5a49fc78` · round-2 fix pass `65af5e4d` (the first commit under the no-trailer rule)".

### 5 · [NIT] · `notes/plans/pre-13x-orchestrator-handoff.md:51` + §8's N2 disposition · the slot reads "The bridge retirement's landing: PENDING(tag · final commit · review verdict)" and names neither the order of her acts nor their MOOT status; the disposition says it "names it". MOOT in substance (her acts supersede the order), but the claim is the second false "the handoff says it" in two rounds. Fix: fill the slot at the seam (tag · `65af5e4d` · the round-3 verdict · "her acts: app quit, Fragments deleting its side, the `/Applications` refresh authorized behind a WAL-safe backup") — or strike the claim from the disposition.

### 6 · [NIT] · `notes/plans/pre-13u-memo-daily-journal-identity.md:74` · "**Owner: 13y**" in the provenance line contradicts the file's own header/§0 and her ruling (owner 13i-e since R-cor-13, re-affirmed 2026-09-04 in §0's third message). One-line fix: "Owner: 13i-e (was 13y until R-cor-13)".

### 7 · [NIT] · `notes/plans/phase-17-standing-fixes.md:578` · "P31 and P30 are the honesty half…" still treats the dissolved P30 as a live item (N5's residual class; the header and status line were marked, this sentence was not). Fix: "(P30 dissolved 2026-09-04)".

### 8 · [NIT] · `App/Variorum/VariorumTests/Phase9cAuthWiringTests.swift:349-377` (`startOnTheDevStoreNeverRunsTheSweep`) · a NEGATIVE pin with a fixed 400 ms sleep. Deterministic on the fixed tree (the gate spawns no task at all), but on a REGRESSED tree the `.utility` detached task may land after 400 ms on this loaded box (the KnownIssues latency-pin row documents 2× spreads), letting a broken gate pass green. Strengthen: after `start()`, await a barrier `Task.detached(priority: .utility) {}.value` (plus the sleep) before asserting — any earlier-scheduled utility task has overwhelmingly run; or have the seam call site record a synchronous "scheduled" mark the spy can read. Also its doc states as fact ("the fix pass's own test run swept the real item") what §8 records as "most likely" — align the wording.

### 9 · [NIT] · `Tools/WalkKit/capture-windows.swift`, `scroll.swift` · force-unwrapped argv / `try!` on `Process.run` — a bad argument crashes instead of printing usage. Tooling only, off every target (verified: `Tools/` is referenced by `Package.swift` for `VaultBootstrap` alone; both helpers compile clean). Optional: a three-line usage guard.

## Review foci (§7's three, checked)
1. **The 14a direct sign-in byte-identical:** the round-2 fix touches no auth path (AppServices' gate + comments, SyncSession comment, tests, docs); `Phase9cAuthWiringTests`' direct-sign-in cases green here (12/1 inside 15/2). Holds.
2. **`resyncReinitialize` / `AccountRekeyMarker` semantics without step 6:** untouched by rounds 1–2; `AccountDoorWiringTests` (the re-key wiring through the app seam, 3 tests) green here. Holds.
3. **No bridge door renders:** the round-2 fix changes no view; the round-1 walk (W-3) verified the sidebar/Settings on the dev store; by reading, `AccountView` is the only sign-in face and carries no bridge section. Holds.

## Clean bill (load-bearing things checked and found solid)
- The N1 fix is the right shape and lands where the fence lives: `sync.allowsSync` is set once from `storeVariant == .real` (AppServices:162) and the gate reads that one truth; `LegacyPasteInCleanup.clear()`'s delete query still mirrors `KeychainAuthStorage.baseQuery` with the shared `account` constant; the two spy pins and the `.dev` pin are real and green on HEAD (run here), the `.dev` pin red-on-old by the traced unconditional sweep in the round-1 diff.
- Every `AppServices` construction site enumerated (7: two production, five test); no test world can reach the login keychain at HEAD (two by injection, two by spy, one by never starting — finding 2 names the fragility, not a reach).
- `SyncSession.onRoundCompleted` / `triggerLifecycleRound` remain gone repo-wide; the became-active hook is `services?.sync.triggerSync()`; the source-walk pin asserts it and is green.
- HEAD == origin/main (`65af5e4d`), tree clean; the fix commit carries NO trailer (the new CLAUDE.md rule honored on its first commit; the four preceding commits in the range predate the rule, as the commit message says). The run-phase skill's stale "never push" was also aligned to CLAUDE.md's 2026-08-03 push rule in the same edit — correct, though unmentioned in the commit message.
- Canon on disk at HEAD (verified directly, the preamble snapshot being pre-unit): AppSpec §9 `applyBridgeLanding` struck with the tag; OverallModel §3 "five … the other three are insurance"; SyncSpec §3 past-tensed; the master plan's 9b RETIRED note; KnownIssues' bridge-sweep row gone; CoreDescription carries no bridge mention; the archive note complete and greppable.
- The whole retirement's `Sync/` footprint is exactly the recorded two touches (SyncSchema's local-table list; one Repairs comment); `BridgeHash` byte-identical to the tag modulo doc comments; the marker stays 7.
- The carry item's asks (1) no deletions until Variorum's word, (2) verify/revoke any leftover — present verbatim; #89 carries the corrected order AND its MOOT status with her words.
- Memo §0: her rulings verbatim; its "what the code does today" paragraph is TRUE at HEAD (create-or-open via `canonicalJournalEntry`, archived-opens-when-alone, no `entry_date` uniqueness); nothing built from it here; owner 13i-e in KnownIssues row 37 and the 13i row (only the memo's provenance line lags — finding 6).
- 17d: 4 items, P30 DISSOLVED with the tag; title + the master plan's 17 row marked.
- Tools/WalkKit: compiles; the README's `cliclick 5.1` claim true; scoped to the Debug build by path, never `/Applications`.
- The residue grep re-run at HEAD (App/Sources/Tests/Tools): every surviving "bridge" is dated history, the vault-format `journalBridge` family, `BridgeHash`, or the English word; no present-tense claim that the bridge runs.
- The tutorial spine 72/10 green on HEAD (run here). Nothing in the fix diff copies text across entities, tracks word-level change, or scales with corpus size.
- Not done, deliberately: no query of her login keychain (forbidden — the round-2 fact stands as recorded); no old-tree rebuild for the `.dev` pin's RED half (traced instead); no full-suite run (the record's 149/28 stands; the two touched helpers' suites + the spine re-run here).

### Round 3 — ADJUDICATION (the orchestrator, 2026-09-04) — THE LADDER CLOSES AT THE CAP
- **Verdict accepted: 0 BLOCKER · 0 MAJOR · 2 MINOR · 7 NIT.** Per the ladder's rule, nothing open after round 3 is looped on; it is recorded for her.
- **Findings 1–2 (MINOR) — RECORDED with an owner, not fixed here:** ONE KnownIssues row, owner **pre-13x batch 1a** (its brief owns the `AuthSession`/custody seam — device-bound tokens — so the sweep's two occasions and the required-seam shape land where that seam is next open): (1) the sign-in occasion of the retired-credential sweep runs on the MainActor and ungated — one private `runRetiredCredentialSweep()` (gate on `allowsSync`, detach) for both occasions, pinned as the reviewer says; (2) `legacyCleanup` becomes a REQUIRED init parameter (the `makeSyncKeyProvider` precedent) so no future test world can reach the login keychain by default. Production reach today: none (a dev store's Account sheet has no door; every test world at HEAD injects an inert seam).
- **NITs 3–8 — FIXED at close** (record hygiene and one test barrier, within the architect's latitude; no production code changed): the `SyncSession.swift` header's stale identity sentence; the §6 hashes and the UNIT CLOSED banner; the pre-13x orchestrator handoff's slot filled; the memo's "Owner: 13y" line → 13i-e; 17d's "P31 and P30" line; the `.dev` pin gains a detached-task barrier before its negative assertion and its doc says "most likely". **NIT 9 — LEFT** (tooling off every target; a usage guard is a nicety).
*[removed for publication]*
- **The unit's evidence, final:** core `swift test` 1391/152 (`d17fe45`; one comment line in core since, `swift build` clean); Mac — the full suite 2094/378 at `d17fe45`, then 176/33 (round-1 fixes) and 149/28 (round-2 fixes) over every touched suite type incl. the TEN spine suites (72/10), 0 skipped; iOS build green on every fix tree; the walk (§8 W-3 + the successful ⌘J · Takes · Library leg); the install refresh below.

- **AUTHOR RULING at the unit's tail (2026-09-04, while round 2 ran):** 13i-e re-scoped — the journal book's bridge shape is unneeded, nothing against same-day entries, "a 'journal book' is dead as a concept". Recorded verbatim in `notes/plans/pre-13u-memo-daily-journal-identity.md` §0, the 13i row, QUESTIONS #89(c), KnownIssues row 37. Nothing built from it here (13i-e's sitting).
