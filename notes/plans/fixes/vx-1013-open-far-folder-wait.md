# VX-1013 — Opening a library waits on reading every key file in the second backup folder

**STATUS: OPEN 2026-11-24 (/architect-phase; away run).**
Ticket: VX-1013 (Bug · Confirmed · Castle & sync · High) · Branch: `vx-1013-open-far-folder-wait` · Worktree: `~/dev/variorum-vx-1013` (Pro).
Custody-class effort: Fable cold-reviews the ladder; the one custody-touching effort in flight.
Required reading for every session on this record: `notes/CastleRules.md` IN FULL; AppSpec §12's protection bullet and SurfaceContracts "Doors to the outside ▸ Library protection"; `notes/SessionResiliencyProtocol.md`; this file top to bottom.

## FOR A LATER READER

*(Written at closeout; until then the sections below are the working record.)*

- **The mechanism as settled:** PENDING.
- **The fix as built:** PENDING.
- **Her rulings:** PENDING (away run — PROVISIONALs bundled for her sitting).
- **The evidence lines:** PENDING.
- **Open items:** PENDING.

## THE MECHANISM (traced 2026-11-24, orchestrator's own read; the field evidence is `notes/plans/fixes/vx-980-search-fixes.md` GATE 1 and GATE 2)

Every launch (`AppBootstrap.beginOpening`) renders `StoreOpeningView` — deliberately a bare background color, designed when the open's worst case measured 54 ms (the comment in `StoreFailureView.swift` says so) — and blocks every further frame on `ProtectionOpenRoad.route()`. The route's first act is `lobbyFacts` → `ProtectionFactsGatherer.facts` → `CatalogLister.catalog()`, which lists BOTH catalogue roots and reads **every key file's bytes** (`Data(contentsOf:)` in `CatalogLister.entry`):

- the **container** (the slot's folder, its `Backups/…` and `Previous Libraries/…`) — local disk, never iCloud; cheap;
- the **far folder** (today's picked second backup destination, security-scoped) — user-picked, commonly iCloud-synced (the dev store's: `~/Documents/Variorum/Backups`, 155 files). A cold, evicted or file-provider-mediated folder blocks each small read inside the sandbox; under load, gate 1 measured ~nine minutes of blank window. Gates 2–3, warm, took seconds — same road.

And the walk is not one walk. One open re-runs the full two-root walk on the order of ten times:

1. `route` → `lobbyFacts` → `facts` → `catalog()`;
2. every `facts` call also runs `leaves.custody.custodyItems()`, whose probe-by-name closure (`ProtectionSystem.touchIDCandidates`) walks `lister.catalog()` AGAIN;
3. `route` → `open()` → `heldKeyFiles(ctx, facts: nil)` → `ctx.system.lister.catalog()` (the facts already in hand are not passed);
4. `open()` → `repairPasses` → up to 4 × `facts` (each a fresh two-root walk + custody probe);
5. `open()` → `logSummary` → `facts` again;
6. `searchIfOwed` → `ProtectionRoadActs:56` → `catalog()` (only when `.offerKeyFile` is owed);
7. `executor.unlock` reaches `FileKeyFileStoreLeaf`, which has its own `lister.catalog()` read.

So the blank window is: first-frame-color → N × (far-folder byte reads of 155 files under sandbox/iCloud latency) → the verdict → the lobby or the Bookcase. Nothing in the route's own DECISIONS needs the far folder on the happy path: `preDesignStore` reads container names only (`Assess.swift` ~112, `$0.place == .container`); the slot hint is the container's live key file; the quiet roads are the silent custody items plus Apple wraps of held key files, which the live file and this Mac's sealed mirror already carry in every healthy state.

## THE DESIGN (the orchestrator's, built PROVISIONAL per the away-run rule; CastleRules stays byte-identical — the fix changes WHEN things are read, never what the rules promise)

**The one sentence: the open never waits on a folder outside the library; the far folder is read once per open, off the launch path, and an unread far folder is an indeterminate fact that no face or verdict may overclaim on.**

- **D-1013-1 — The catalogue says which places it read.** `Catalog` gains `unreadPlaces: Set<CatalogPlace>` (default `[]`, so every existing call site and pin compiles and passes unmodified — the 3C parity pattern). A place in `unreadPlaces` contributed no entries, and nothing may be concluded from their absence.
- **D-1013-2 — The launch route runs on container-only facts.** `CatalogLister` gains a scope (`.everything` — today's, the default everywhere — and `.containerOnly`, which lists the container and marks `.farFolder` unread). `ProtectionFactsGatherer.facts`/`ProtectionSystem.facts` take the catalogue state from the caller with `.everything` the default: the copy doors, copy counts, backup hook/pair, crossing and account acts, Data Safety — every non-launch caller — are byte-identical by default. Only `ProtectionOpenRoad`'s launch-route facts reads (lobbyFacts, open's, repairPasses', logSummary's, openTyped's first leg) run on the per-open far state (D-1013-5).
  - *As built (round 1's F-R1-2):* no listing scope shipped. The catalogue state a facts read takes is `CatalogRead` (`.everything`, the default, or `.thisOpen(FarFolderWalk)`); its `.thisOpen` arm lists the container at the read and marks the far folder unread itself until the open's one walk lands (`FarFolderWalk.catalog(over:)`). Batch 1's `CatalogLister.Scope` / `.containerOnly` had no caller and was deleted in batch 2; `CatalogLister.catalog()` is main's body again.
- **D-1013-3 — Unread-far is indeterminate, by the road's standing idiom** ("could not read ≠ opens nothing", `ProtectionFactsGatherer`; "anything that might still open it says nothing", `AssessRules.lobby`). Concretely:
  - Rule 27 is NEVER claimed on a partial listing: `AssessRules.lobby`'s `mightOpen` treats an unread far place as possibly-holding ⇒ `noKeyFileAnywhere` stays nil until a full listing proves it; the unlocked `noKeyFileAnywhere` fault and `backupHoldsTheCurrentKeyFile` (Assess.repairs ~278/~301) likewise do not fire while far is unread.
  - The no-backup-yet consult: **superseded by R-1013-A1 (the fork's ruling, below)** — the container's copies answer it on a partial listing. The original line here ("its act waits for a full-listing assessment — the backup hook's own moment walks everything anyway") rested on a false parenthetical the implementer traced: no post-open assessment feeds the reminder, so the literal reading would lose rule 3's "always" moment. The fork section carries the full trace and options.
  - **The implementer sweeps EVERY consumer of `facts.catalog` / `catalog.` in `Sources/VariorumCore/Protection/Assess/`** and lands a sweep table in this file: each row UNAFFECTED (container-only fact) · INDETERMINATE-HANDLED (with its pin) · FULL-WALK CALLER (never sees an unread place). The closing form is the 13b sweep-table law.
- **D-1013-4 — Where the far folder IS read:**
  - An `.opened`/`.created` route: not at all during the open. Post-open consumers keep their own fresh `.everything` walks, unchanged.
  - `.roadLobby`: the lobby draws at once from container facts; the route kicks ONE detached low-priority far walk; when it lands, the standing lobby refreshes through the existing refresh seam (`ProtectionLobbyModel.refreshRoad`'s shape) with full facts — extra typed roads, and rule 27's banner where a full listing now proves it, may appear then (**PROVISIONAL P-1013-1**). If the full facts let a QUIET road open the slot (a far-only Apple wrap — a hand-damaged-container rarity), the lobby proceeds through its `opened` continuation exactly as a successful press (**PROVISIONAL P-1013-3**).
  - A lobby press (`openTyped`, the vault road's `files`, Touch ID): container-held files first — the common unlock stays instant; only a press that would otherwise answer `.noneOpens` JOINS the far walk (awaits the shared result), extends its candidates with the far files, and retries once before refusing — so the N5 hand-forward and rule 21's reach are OUTCOME-IDENTICAL to today, and a wait happens only where today's refusal would have been dishonest (**PROVISIONAL P-1013-2**).
  - `searchIfOwed` (rule 21's offer): KEEPS its full walk at its call site. The search is the act of looking in the places the app keeps key files; in the broken-slot state where it is owed, that wait is the point.
  - `touchIDCandidates`: probes container + memory + plan + staged fingerprints while far is unread (the current key's item is always named by those); dispositioned in the sweep table.
- **D-1013-5 — One far walk per open; facts within one open share it.** A small per-open far state (`unread` / `reading(Task)` / `read(entries)`) is created at `beginOpening` and handed through the road's plumbing; every facts read in that open composes fresh container entries (repairs change them) over the shared far state. `open()`'s `heldKeyFiles(ctx, facts: nil)` is replumbed to reuse the facts the route already gathered. No post-open call site changes.
- **D-1013-6 — No rule, face-word, store or schema change.** `StoreOpeningView` stays blank (with the block removed, its 54 ms assumption holds again; an "Opening…" grace line is a taste call held for her). No `Sync/`, no migration, no MCP surface.

## THE EVIDENCE PLAN (hallucination guard: every bug-class pin red-on-old, verified by revert)

1. **The route pin (red-on-old):** a planted lister/places whose far-folder listing RECORDS its reads — a quiet-road open's `route()` completes with ZERO far reads. Old code reads far before the outcome ⇒ red; new ⇒ green; verified by revert.
2. **The walk-count pin (red-on-old):** one open performs at most ONE far walk (the counting instrument), against today's ~ten.
3. **Rule 27 indeterminacy pins (core):** far unread + a far key file that would open ⇒ `noKeyFileAnywhere` nil at the lobby and in repairs; the SAME world with far read ⇒ today's verdicts byte-identical.
4. **The press-equivalence pin:** a typed secret whose descriptor only a far file carries still opens (the press joins the walk) — the preserved-contract pin.
5. **The lobby-refresh pin:** the far landing surfaces the far file's typed roads; with a full listing proving nothing opens, rule 27's banner fires — rule 27 stays reachable.
6. **Every existing Protection suite green** (core `swift test` + the Mac target's Protection suites at the gate).

Use-shaped acceptance: the orchestrator's launch walk on the dev store (its real 155-file far folder) — the window draws promptly, the protection log shows the far walk deferred; suites green per above. Stage acts via the nov24 coordinator.

## BATCH 1 BRIEF (one acceptance unit, one implementer session — opus-implementer, xhigh)

**You are the implementer for VX-1013.** Work ONLY in `~/dev/variorum-vx-1013` on branch `vx-1013-open-far-folder-wait`. Read first, in this order, never delegated: `CLAUDE.md` (auto-canon loads with it), `notes/CastleRules.md` IN FULL, this record top to bottom, `notes/SessionResiliencyProtocol.md`, SurfaceContracts "Doors to the outside ▸ Library protection". Then read the code this record names: `App/Variorum/Shared/Protection/CatalogLister.swift`, `ProtectionFactsGatherer.swift`, `ProtectionOpenRoad.swift`, `ProtectionSystem.swift`, `AppBootstrap.swift` (the open seam), `Sources/VariorumCore/Protection/Assess/Catalog.swift`, `Assess.swift`, `RouteFinder.swift`, `OwnCopies.swift`, `Retention.swift`.

Build D-1013-1 … D-1013-6 exactly as written, with the evidence plan's pins. Rules that bind you:

- The schema-free parity rule: `unreadPlaces` defaults empty and `.everything` is the default scope, so every existing test passes UNMODIFIED — zero test edits outside the new pins is the parity proof.
- The sweep table (D-1013-3) lands in this file under LIVE STATUS before you call the batch done — every `facts.catalog` consumer in Assess dispositioned.
- An in-batch design fork (anything this record does not decide) goes BACK to the orchestrator before you build that half — the implementer proposes, the architect rules.
- Checkpoint protocol (SessionResiliencyProtocol): commit per coherent piece, push after every commit, LIVE STATUS in this file from the first commit, PENDING marks on unverified claims, synchronous foreground waits only, never a subagent.
- Tests: `swift test --filter` for the core pins; `xcodebuild build` from `App/Variorum/` is legal headless; **NO `xcodebuild test` run from your session** — the Mac-target suites run at the orchestrator's gate under a held stage claim (the stage is the nov24 coordinator's; you never claim it). Never touch `/Applications`, any real store, or the dev store's app.
- No `Sync/`, no schema, no new dependency, no canon edit. Commits carry no attribution trailer. Public-repo wording: every commit message and note line is public copy.

Done means: the pins red-on-old by revert (behavioral revert, restored, said in LIVE STATUS with the counts), core suite green, the Mac target BUILDS, the sweep table landed, LIVE STATUS flipped with hashes, pushed.

## LIVE STATUS (the implementer's, from the first commit)

**NOT DONE BY THIS SESSION (first, per the contract):** (1) The use-shaped acceptance — the launch walk on the dev store
and its captures — is the orchestrator's under a stage claim; this session held no claim, launched nothing and walked
nothing (and no Castle posture changed anywhere). (2) The Mac target's suites under `xcodebuild test` — the gate's; this
session ran the planted Protection suites HEADLESS instead (the SwiftPM harness: 210 tests in 35 suites). Nothing else:
the fork is ruled and built (R-1013-A1), the relock's lobby is built (R-1013-A2, piece 6).

*Batch 1, opus-implementer, session 1 (2026-11-24; resumed 2026-11-25 for the two ruled pieces). No behavioural revert is
in flight.*

**RESUMED (R-1013-A1, R-1013-A2):**
- 6a DONE (`9a4f64544`, record `ac6d0ea28`) — core pin `FarFolderUnreadTests.theNoBackupYetMomentIsOwedOnAPartialListing`
  (the suite now 7): GREEN `✔ 7 tests`; a RULING pin, green on both sides by construction — on the pre-fix `Assess.swift`
  (`006072617`) `✔ 1 test passed`; the record's option (b) as a mutation (`passphraseAsks` skipped while
  `!readsEveryPlace`) ⇒ `✘ 1 test failed with 1 issue` (the partial-listing expectation); restored, `git status` clean,
  `✔ 7 tests`. Row 12 flipped to UNAFFECTED-BY-RULING.
- 6b DONE (`c09196e7d`) — piece 6, the relock's lobby, BY PLUMBING REUSE ONLY: `ProtectionRoadLock.lobbyContext(road)` (a
  freshly composed road's context with its OWN `FarFolderWalk`, one per lock), `ProtectionRoadLock.lobby(ctx)` reads the
  container's facts and begins the walk through the route's one helper (`RoadContext.beginTheFarWalkBehindTheLobby`, the
  route now uses it too), `AppBootstrap.lockOnNewRoad` composes through `lobbyContext`, and `finish(.roadLobby)`'s existing
  far landing lands it (P-1013-1 and P-1013-2 apply unchanged). What the lock does is unchanged: its landing NEVER tries the
  quiet roads (`RoadContext.farLandingTriesQuietRoads` false — the lock's own rule, "the quiet roads are NOT tried at a
  lock", so P-1013-3 has nothing to retry there); nothing it says changed. Existing callers of `ProtectionRoadLock.lobby`
  over a plain context read exactly as before (no far walk ⇒ the helper does nothing). Pins (app, in
  `OpenFarFolderWaitTests`, now 10): `aLocksLobbyReadsNoFarFolderAndItsLandingRefreshesItsRoads` (container facts, the walk
  begun, the landing adds the far file's passphrase road, ONE far read in all) and
  `aLocksLobbyNeverTriesTheQuietRoadsWhenItsWalkLands` (a far Apple wrap that opens the launch road's landing leaves a
  lock's lobby standing). Headless harness: GREEN `✔ 10 tests`; RED BEFORE PIECE 6 by behavioural revert (`lobbyContext`
  returning `road.context()` — the lock's lobby as before): `✘ 2 tests failed with 5 issues` (unread places, drawn roads,
  the walk begun, the read count; the no-theater pin opened); MUTATION (the landing's flag ignored, `lobbyContext`
  kept) ⇒ the no-theater pin RED alone; restored, `git status` clean, the harness `✔ 210 tests in 35 suites passed`.

**BATCH 1 STATE — built and verified (commits `006072617` → HEAD, all pushed):**
- Core suite (full `swift test`, after the load window cleared): GREEN — `✔ 746 tests in 139 suites`, `━ 4204 tests in
  579 suites passed … with 5 known issues` (the VX-529 suites' own `withKnownIssue`s, untouched; 4204 = the earlier 4203 +
  R-1013-A1's pin), `✔ 32 tests in 4 suites`; `EXIT 0`. Machinery honesty: the first post-window run, made beside this
  session's own parallel Mac and phone builds, met VX-978 (`PurgeSweepTeardownTests.aLockLandingMidSweepClosesOnlyAfterTheHeldReadEnds`
  failed its `#require` under load and the run then hung on the held read — the ticket's exact shape); this session stopped
  its own hung test helper and re-ran the suite alone — the green line above.
- Mac target (after piece 6): `build-for-testing` → `** TEST BUILD SUCCEEDED **` (app + test bundle), no warning in a
  touched file. Phone target (`VariorumMobile`, `generic/platform=iOS Simulator`, a build — no simulator booted):
  `** BUILD SUCCEEDED **`.
- Headless harness (the VX-306 recipe, piece 4 below), widened for parity: every planted-road Protection suite that
  compiles there without the app's bootstrap — `✔ Test run with 210 tests in 35 suites passed` (the 10 new + 200 existing,
  UNMODIFIED — `RoadLockTests` and `LobbyTouchIDReaskTests`, which read `ProtectionRoadLock.lobby` over plain contexts,
  among them). Zero edits to any existing test file anywhere (`git diff e364f151b -- Tests/ App/Variorum/VariorumTests/`
  shows only the two new files).

**Read first (own context, not delegated):** CLAUDE.md + the auto-canon; `notes/CastleRules.md` in full; this record;
`notes/SessionResiliencyProtocol.md`; SurfaceContracts "Library protection"; the named source files (`CatalogLister`,
`ProtectionFactsGatherer`, `ProtectionOpenRoad`, `ProtectionSystem`, `AppBootstrap`'s open seam, core `Catalog`, `Assess`,
`RouteFinder`, `OwnCopies`, `Retention`) plus what they reach (`KeychainCustodyLeaf`'s probe, `FileKeyFileStoreLeaf`,
`ProtectionRoadActs.searchIfOwed`, `ProtectionLobbyModel`, `ProtectionRoadLock.lobby`, the executor's custody listings).

**Trace corrections (read in the code, for the record's mechanism section at closeout):**
- Trace item 7 is mis-attributed: `executor.unlock` reads only the live key file. The executor reaches the full catalogue
  through `FileKeyFileStoreLeaf.catalogedKeyFiles` only from Castle entry's sweep and `keyFileGoneEverywhere` (acts, not
  the open). What DOES walk the far folder inside an open's executor work is every executor `custodyItems()` listing
  (a repair that lists custody — `remakeOnDeviceItem`, `deleteSilentItem` — and a settle's plan runner): the Keychain
  custody leaf's probe-by-name closure (`ProtectionSystem.touchIDCandidates`) walks both roots per listing.

**Pieces:**
1. DONE (this commit) — core: `Catalog.unreadPlaces` + `readsEveryPlace` + `build(_:unreadPlaces:)` (an unread place's
   entries dropped) (D-1013-1); `assess` (D-1013-3): the lobby's `mightOpen` counts an unread place; the plain fact
   `backupHoldsTheCurrentKeyFile` gains `backupMightHoldTheCurrentKeyFile` (true on a partial listing), read by rule 27's
   two unlocked fault arms and by rule 21's offer owing (the search reads every place and answers). Pins
   `Tests/VariorumCoreTests/Protection/FarFolderUnreadTests.swift` (6 tests) GREEN. RED-ON-OLD by behavioural revert
   (`Assess.swift` set to its pre-fix text `006072617`, `Catalog.swift` kept so the pins compile): `✘ Test run with 6
   tests in 1 suite failed … with 7 issues` — every partial-listing expectation red (the lobby's two, the gone-file's
   fault + offer, the stray's fault + offer, the far-key-file lobby one); green on both sides as designed: the
   catalogue default pin and the healthy-library parity pin. Restored (`git checkout --`), `git diff` clean, `✔ 6 tests
   passed`.
   The no-backup-yet consult (Assess ~551) is NOT changed — see THE FORK below.
2. DONE (this commit) — app (`CatalogLister.swift`): `CatalogLister.Scope` (`.everything` default · `.containerOnly`, the
   far folder marked unread only when one is picked — resolving the bookmark reads no folder); `CatalogRead`
   (`.everything` default · `.thisOpen(FarFolderWalk)`) with its task-local `probing` scope; `FarFolderWalk` (resolves the
   far folder once per open, walks it at most once, detached at `.utility`, joinable; logs begin/landed with the entry
   count and ms). `ProtectionFactsGatherer.facts` / `ProtectionSystem.facts` take `catalog: CatalogRead = .everything`;
   the gatherer's custody listing runs under that scope; `ProtectionSystem.touchIDCandidates` reads the catalogue under
   `CatalogRead.probing`. `ProtectionFarFolder.accessed` — a test's witness at each claim of the far folder (nil in
   production).
3. DONE (this commit; the Mac target BUILDS — `** BUILD SUCCEEDED **`, no warning in a touched file) — the road:
   `RoadContext.far` (nil default — every non-launch context reads as before) with `catalogRead` / `catalog()` /
   `facts(unlocked:)` / `joinTheFarWalk()` / `scoped(_:)`; `route` runs scoped and BEGINS the far walk only when it lands
   in the lobby with the far folder unread; `lobbyFacts`, `open`'s expansion (the route's and `openTyped`'s facts handed
   in — D-1013-5's replumb), `repairPasses`, `logSummary` read through the context; `openTyped` and `pressTouchID` run
   scoped and, on `.noneOpens` only, join the far walk and try once more (the typed road re-derives only the far files'
   new descriptors — `typedCandidatesAndKeys(…, reusing:)`); `landTheFarWalk(ctx)` → `RoadFarLanding` (`.opened` ·
   `.recordMissing` · `.lobby`). `ProtectionLobbyModel`: `farLanding:` (nil default), `farWalkLanded()` serialized against
   the presses (owed to a press's end; once; nothing after the lobby was left), `refresh()` refactored onto the shared
   `take(_:)` seam byte-for-byte. `AppBootstrap`: one `FarFolderWalk` per `beginOpening`, handed to `routeAndOpen`'s
   context; `finish(.roadLobby)` awaits the begun walk and lands it on the lobby still standing. `searchIfOwed` keeps its
   own full walk (D-1013-4).
4. DONE — app pins `App/Variorum/VariorumTests/Protection/OpenFarFolderWaitTests.swift` (8 tests; the Mac test bundle
   compiles — `** TEST BUILD SUCCEEDED **` via `build-for-testing`; nothing run on the stage), over a planted road whose
   picked far folder COUNTS its claims (`ProtectionFarFolder.accessed`). RUN HEADLESS in the VX-306 SwiftPM harness recipe
   (a scratchpad package — not durable — whose `Variorum` target symlinks every `App/Variorum/Shared/Protection/*.swift`
   but `ProtectionBackupHook.swift`, plus `DeviceName`, `BackupDestination`, `LibraryOpenCopy`, `KeychainCustody` and one
   stub file — `ProjectConfig` (unconfigured), `FirstRoundOutcome`, `SyncRowFace`, `SyncStatusRow`, `AuthTokens`,
   `KeychainAuthStorage`, `AuthSession`; the app's concurrency settings; the worktree's core by path; its test target
   symlinks `ProtectionTestSupport`, `ProtectionLobbyModelTests`, `ProtectionOpenRoadPlantedTests`, the new suite, and a
   one-line `RoadWorld.RoadWorldError` stub; `swift test`, never `xcodebuild test`):
   - GREEN: `✔ Test run with 33 tests in 3 suites passed` (the 8 new + the planted road's 9 + the lobby model's 16,
     those two UNMODIFIED — parity).
   - RED-ON-OLD by behavioural revert (R1 `CatalogLister.catalog(_:)` reads both roots for `.thisOpen` — the pre-fix
     launch road; R2 `ProtectionSystem.touchIDCandidates` reads `catalog()`): `✘ Test run with 8 tests in 1 suite failed
     … with 8 issues` — 7 of 8 red: the route pin (the old road read the far folder 3 times on the way to a quiet open,
     planted custody — the production probe adds a walk per listing), the walk-count pin (8 claims, not 1), the press pin's
     count (4 claims; its OPEN stays green — the preserved contract), the rule-27 landing pin (the old lobby claimed rule
     27 before it drew), the typed-roads landing pin (the old lobby already offered the far file's passphrase road), the
     P-1013-3 pin (the old route opened through the far Apple wrap at once), the probe pin (both arms). Green on both
     sides, as designed: the model's landing-waits-for-the-press pin (a new seam, no old behaviour). Restored
     (`git checkout --`), `git diff` clean, `✔ 33 tests passed`.
   - MUTATIONS (each restored, `✔ 33 passed` after): the press's join dropped ⇒ the press pin RED alone (`refused` where
     today opens); the landing's press guard dropped ⇒ the model pin RED alone (`landings == 0` fails).
5. DONE — the sweep table (D-1013-3) below; THE FORK below it (the no-backup-yet consult — not built, awaiting the
   architect's ruling).

**THE SWEEP TABLE (D-1013-3 — every consumer of `facts.catalog` / a `Catalog` in `Sources/VariorumCore/Protection/Assess/`,
the 13b sweep-table law).** UNAFFECTED = reads a container-only fact (the launch road's partial listing answers it exactly);
INDETERMINATE-HANDLED = never concludes "none" from an unread place (its pin); FULL-WALK CALLER = only ever handed a
`.everything` listing (its callers named); FORK = see below.

| # | Consumer (file:line at this commit) | What it reads | Verdict |
|---|---|---|---|
| 1 | `assess` — `opensWith` over `facts.catalog.copies` (`Assess.swift:55`) | each listed copy's sentence | FULL-WALK CALLER — no reader outside the core; the launch road's assessments never read it. Per copy: an unlisted copy gets no sentence, nothing concluded from its absence |
| 2 | `AssessRules.preDesignStore(storeFile:catalog:)` (`Assess.swift:111`) | `liveKeyFile` + `foreign` at the container's root | UNAFFECTED — container names only (`$0.place == .container`) |
| 3 | `AssessRules.routeFinder` (`Assess.swift:186`) | the catalogue into `RouteFinder`; the live key file's id | FULL-WALK CALLER (its sentence is #1's); the live id is the container's |
| 4 | `AssessRules.lobby` — `live` (`Assess.swift:195`) | the live key file's typed locks | UNAFFECTED — the container's |
| 5 | `AssessRules.lobby` — `mightOpen` over `catalog.keyFiles` (`Assess.swift:223`) | every key file | INDETERMINATE-HANDLED — an unread place might hold one ⇒ rule 27 never claimed. Pins: core `FarFolderUnreadTests.ruleTwentySevenIsNeverClaimedAtTheLobbyOnAPartialListing`, `aFarKeyFileThatWouldOpenItSaysNothingReadOrUnread`; app `ruleTwentySevenIsSaidOnceTheFarWalkLandsEmpty` (rule 27 reached once the walk lands) |
| 6 | `AssessRules.liveKeyFile` (`Assess.swift:239`) | `keyFile(id: unlocked.liveKeyFileID)` | UNAFFECTED — the container's |
| 7 | `AssessRules.repairs` — rule 27's first arm (the live file gone) (`Assess.swift:281`) | a backup holding the current key's file | INDETERMINATE-HANDLED — `backupMightHoldTheCurrentKeyFile`. Pin: `theLiveKeyFileGoneClaimsNothingOnAPartialListing` |
| 8 | `AssessRules.repairs` — rule 27's second arm (a stray in the live place) (`Assess.swift:306`) | the same | INDETERMINATE-HANDLED — the same reading. Pin: `aStrayInTheLivePlaceClaimsNothingMoreOnAPartialListing` |
| 9 | `AssessRules.olderKeyFileSweep` (`Assess.swift:343`) | `catalog.foreign` at the container's root | UNAFFECTED — `entry.place == .container, entry.folders.isEmpty` |
| 10 | `AssessRules.acts` — rule 21's `.offerKeyFile` (`Assess.swift:514`) | the same fact | INDETERMINATE-HANDLED — owed on a partial listing; `searchIfOwed` keeps its FULL walk at its call site (D-1013-4) and answers (the offer, or rule 27's refusal, which the standing faces show from the search exactly as from the fault). Healthy opens never reach it (the live file is the current key's). Pins: #7's and #8's (`acts.contains(.offerKeyFile)`) |
| 11 | `AssessRules.backupHoldsTheCurrentKeyFile` (`Assess.swift:548`) | `catalog.keyFiles` (non-live, the current key) | the plain fact — its only readers are #7, #8, #10, each through `backupMightHoldTheCurrentKeyFile` (`Assess.swift:557`) |
| 12 | `AssessRules.passphraseAsks` — `.beforeFirstBackup` (`Assess.swift:570`) | `copies(ofLibrary:)` holds no backup | UNAFFECTED-BY-RULING (R-1013-A1, option (a)) — on a partial listing the container's copies answer it (every backup run lands there first); code untouched. Pin: `FarFolderUnreadTests.theNoBackupYetMomentIsOwedOnAPartialListing` |
| 13 | `AssessRules.useCastleSpec` — copies under a key this Mac can't delete (`Assess.swift:715`) | every copy and its serving files | FULL-WALK CALLER — Use Castle's door words, rendered only from the crossings' / key doors' / account section's facts (`ProtectionCrossingActs:139`, `ProtectionKeyDoorActs`, `ProtectionAccountActs:452` — all `.everything`); the launch road's assessments compute doors and discard them |
| 14 | `RouteFinder` (`RouteFinder.swift:96,109,134`) | the catalogue, the live file, a copy's serving files | FULL-WALK CALLER — reached only through #1/#3 |
| 15 | `OwnCopies` (`OwnCopies.swift:16–113`) | this Mac's copies per place | FULL-WALK CALLER — `ProtectionBackupHook.runPair`, `ProtectionBackupPair` (the far due-check), `ProtectionCopyCounts`, `ProtectionCopyDoors`, `CopyDoorsModel` — each `lister.catalog()` (`.everything`) |
| 16 | `Retention.plan` (`Retention.swift:56`) | this Mac's copies per place | FULL-WALK CALLER — `ProtectionBackupPair`'s `lister.catalog()`; and safe by construction on a partial listing (it prunes only copies the listing holds) |
| 17 | `ProtectionFacts.catalog` (`Facts.swift:204`) | — | the field itself |
| — | `CatalogNames`, `LibraryNotice`, `Assessment` | — | no catalogue read (names, the open's notice, a doc line) |

Counts (final, after R-1013-A1): 17 rows — UNAFFECTED 4 (#2, #4, #6, #9) · UNAFFECTED-BY-RULING 1 (#12) ·
INDETERMINATE-HANDLED 4 (#5, #7, #8, #10; #11 is their shared fact) · FULL-WALK CALLER 6 (#1, #3, #13, #14, #15, #16) ·
definition/plain fact 2 (#11, #17) · FORK 0.

Beside the table (the app's launch-road readers, for the reviewer): `ProtectionFactsGatherer` (live key file → hint and
live id, rule 26's names — container), `ProtectionLobbyFace.derive` (`catalog.liveKeyFile` — container),
`ProtectionOpenRoad.offeredTyped` / `heldKeyFiles` / `quietCandidates` (container + the far walk once landed — the typed
roads may grow when it lands, P-1013-1; a refusing press joins, P-1013-2), `ProtectionSystem.touchIDCandidates` (scoped
by `CatalogRead.probing` — pinned by `theCustodyProbeReadsNoFarFolderInsideTheLaunchRoad`), `searchIfOwed` (its own full
walk, unchanged), `FileKeyFileStoreLeaf.catalogedKeyFiles` (executor acts only — Castle entry's sweep and
`keyFileGoneEverywhere`; never the open's happy path; a settle resuming an entry walks it, as rule 11's belt needs).

**THE FORK (the one half NOT built — the architect rules).** Row 12, the no-backup-yet consult (`passphraseAsks`'
`.askPassphrase(.beforeFirstBackup)`, rule 3: "always right before the first backup"). The record says it "does not
claim 'no backup exists' on a partial listing; its act waits for a full-listing assessment (the backup hook's own moment
walks everything anyway)". The parenthetical does not hold in the code: the moment's ONLY consumer is the open's report →
`RoadStandingFaces.passphraseMoment` → `PassphraseReminderModel` at ready (`ProtectionOpenFaces.swift:228, 401`); no
post-open assessment feeds the reminder, and the backup hook (`ProtectionBackupHook.runPair`) asks nothing — it decides
due-ness only. So the literal reading LOSES the moment wherever the launch road opens a passphrase-less library whose
container holds no backup of it while a far folder is picked: a creation on the launch road (`.startFresh`) on a Mac with a
picked folder, and Make this my library's reopen (`beginOpening(unlockedKey:)`) without a passphrase — after which the
first backup runs and the moment is never owed again. Options:
- (a) **RECOMMENDED — the container answers it on a partial listing** (the code as it stands — NOT changed): the consult
  reads the copies the listing holds; on the launch road's container-only listing that is "no backup of this library in
  this Mac's container", the place every backup run lands first (`runPair`: the container pair, then the picked
  folder's). It never loses the moment; its only miss is the benign direction — a library whose container pairs were
  removed by hand but whose far folder keeps some is reminded once more. And it overclaims nothing a face says: the
  reminder's words are about the passphrase ("your library is only secured through iCloud Keychain right now…"), never
  about backups, and it shows only while no passphrase is set (`!passphraseSet`). A full listing keeps today's reading.
- (b) The record's literal reading: not owed while the far folder is unread — the moment lost in the states above (a
  regression of rule 3's "always").
- (c) Deferred: the report marks the consult undecided and `RoadStandingModel.make` (post-open, off the launch path) runs
  one detached full listing, handing the reminder its moment when it proves no backup exists — new plumbing; the reminder
  may show a beat after the window.
Until the ruling the tree is (a) by construction (row 12 untouched); on (a) the batch adds one pin (a partial listing
with no container backup owes the moment — the creation keeps rule 3's "always"); on (b) or (c) the implementer builds it
with its pin.

**R-1013-A1 (the architect's ruling, 2026-11-25; PROVISIONAL for her bundle as P-1013-4): option (a).** Rule 3's
"always right before the first backup" outranks the design note's parenthetical, which the trace showed false. The
container is the place every backup run lands FIRST (`runPair`), so the container-only listing answers "has this Mac
made a backup of this library" authoritatively in every undamaged state; the one miss — container pairs removed by
hand while far pairs survive — costs one extra calm reminder whose words say nothing about backups. No face overclaims
(D-1013-3's fence was about rule-27-class claims of fact). Row 12's verdict becomes UNAFFECTED-BY-RULING with (a)'s pin.

**R-1013-A2 (the architect's, same sitting): the relock's lobby joins the batch — the class completed in-effort.**
The "noticed, not taken" item is the same class (a lobby blocked on the far walk, reached by Lock Now or the idle/sleep
monitors instead of launch); left as-is, every lock on an evicted far folder lands behind `.opening` for one full walk —
the ticket's blank-window class at every idle lock. Build it as piece 6 BY REUSING the per-open plumbing (the relock's
lobby context gets its own `FarFolderWalk`, container-only facts, the landing's refresh — P-1013-1/2/3 apply unchanged),
with a pin (the relock's lobby facts perform no far read; the landing refreshes). IF it turns out to be more than
plumbing reuse — any new design surface — stop and report instead; it then becomes its own ticket. Evidence stays
headless (the gate's walk covers the launch only; no Castle posture change on the dev store for this).

**Noticed at first, then TAKEN by R-1013-A2 (piece 6 — 6b above):** the relock's lobby (`ProtectionRoadLock.lobby` —
VX-445's Lock Now and the idle/sleep monitors) used to read both roots, so a lock landed behind `.opening` for one full
walk; it now reads the container and lands its own far walk. The lobby vault road's catch-up act (`catchUpThroughTheVault` → `executor.follow`) runs inside the press's scope (its custody
listings probe the container + the walk once landed) — by construction, no separate change.

## MEMBERS

**VX-524 rides (her word, 2026-11-25: "yeah add vx-524").** Data Safety's header says "5 copies" while the restore
list shows six rows, one backup listed twice (Bug · Suspected · Castle & sync · Medium; born at VX-510 unit C3 —
`notes/plans/fixes/vx-510-first-run-sync.md` W-8, where the log's "the picked folder holds this Mac's fresh pair"
suggests the far copy may be the second listing). Closes individually; commits say "Part of VX-524"; its fix rides
this branch and round 2's re-review covers it.

**The member brief (batch 2, with round 1's fixes — one fresh implementer session):**
- The two readers, pre-traced by the orchestrator: the HEADER is `ProtectionCopyCounts.read` → `OwnCopies.summary`
  per place (retention's own "this Mac's pairs of this library" predicate); the LIST rows are
  `ProtectionCopyDoors.listing` → `CopyDoorsListing` over `catalog.copies` with its own fences. Two predicates over
  one catalogue; the suspected shape is the same backup pair standing in BOTH the container and the picked far
  folder, rowed twice while counted once (or counted per place while rowed per copy).
- Evidence is SUSPECTED, so the hallucination guard's speculative arm binds: build the PIN FIRST as the confirm — a
  planted catalogue with the same pair in both places, asserting header and list agree. Red confirms and the fix
  proceeds (with the pin red-on-old, verified by revert); green means record-only — write what the probe showed,
  correct the ticket, no fix.
- If the honest answer is a FACE call (two physical copies ARE two restorable rows — should the header count per
  place, the list dedupe, or the split be said?), that is a design fork: propose, the architect rules (PROVISIONAL
  if word-shaped).
- Same fences as batch 1: headless only, no stage, no canon edit, checkpoint protocol, public-copy wording.

## BATCH 2 LIVE STATUS (the implementer's — round 1's fixes, then the VX-524 rider)

**NOT DONE BY THIS SESSION (first, per the contract):** (1) VX-524's face — the fork below is PROPOSED, not built; the
architect rules (and the board's ticket text is the orchestrator's to correct). (2) The Mac target's suites under
`xcodebuild test` — the gate's, under a stage claim; this session built the test bundle (`build-for-testing`) and ran
the planted Protection suites HEADLESS in the harness instead. (3) No walk, no stage, no store touched, no Castle posture
changed. (4) F-R1-3 has no code here by its final call (DEFERRED to VX-1090).

*Batch 2, opus-implementer, session 1 (2026-11-25). No behavioural revert is in flight. BATCH 2 DONE — every piece
below is committed and pushed; round 2 (a fresh reviewer) reads it.*

- PHASE A — DONE (`8f5f1f538`): the round-1 dispositions, each from this session's own read of the named code, under
  THE LADDER ▸ ROUND 1 DISPOSITIONS below. The reviewer's final calls landed at `30caec3fa` (ROUND 1 FINAL CALLS).
- PHASE B:
  - B1 F-R1-1 — DONE (`d723aa616`; this record line rode the next commit — the record edit was refused at the first
    try because the file had moved under the pull). `ProtectionLobbyModel.take(_:)`: a read whose catalogue does not
    read every place never replaces a standing whose catalogue does; a standing with NO facts takes any read with
    facts, as before (the reviewer's edge). Pins (app, in `OpenFarFolderWaitTests`, now 13):
    `aRefreshReadBeforeTheLandingNeverTakesRuleTwentySevenBackAway`,
    `aRefreshReadBeforeTheLandingNeverTakesTheFarFilesRoadBackAway` (a `refreshRoad` held on a gate after it entered;
    the landing runs and takes the full facts; the gate opens; the face must keep them), and the edge pin
    `aLobbyWithNoFactsTakesAPartialReadAsBefore`. PIN BEFORE FIX, headless harness (the VX-306 recipe — the scratchpad
    package that symlinks the worktree's files, `swift test`), on the batch-1 tree: `✘ Test run with 13 tests in 1
    suite failed … with 2 issues` — exactly the two "never narrows" expectations (414, 444); every expectation before
    the gate opened held (the landing did take the full facts); the edge pin green, as designed. With the guard:
    `✔ Test run with 35 tests in 4 suites passed` (`OpenFarFolderWaitTests` 13, `ProtectionLobbyModelTests`,
    `LobbyTouchIDReaskTests`, `RoadLockTests` — the last three UNMODIFIED). The pre-fix run IS the guard's revert (the
    guard is the only production change in this piece). MUTATION (from the committed state, `0ab517ee6`): the guard's
    edge written as `standing.facts?.catalog.readsEveryPlace ?? true` (a missing standing read as a whole listing) ⇒
    `✘ … 13 tests … failed … with 2 issues` — the edge pin alone (464, 465); restored by `git checkout --`, `git status`
    clean.
  - B2 F-R1-2 — DONE (this commit). `CatalogLister.Scope` and `catalog(scope:)` deleted; `catalog()` is main's body again
    (`Catalog.build(entries())`); the file's VX-1013 header paragraph rewritten to the shipped seam (`CatalogRead` +
    `FarFolderWalk`), and — the same stale claim in the same file — `CatalogRead`'s and `FarFolderWalk`'s doc comments now
    name a lock's lobby among the `.thisOpen` readers (R-1013-A2). The as-built line sits beneath D-1013-2 (the design
    text untouched). `git grep containerOnly\|catalog(scope` over `App Sources Tests Tools`: nothing. Harness (with B3's
    comments, below): `✔ Test run with 42 tests in 4 suites passed` (`OpenFarFolderWaitTests`,
    `ProtectionLobbyModelTests`, `RoadLockTests`, `ProtectionOpenRoadPlantedTests`). No pin (not bug-class).
  - B3 F-R1-4 — DONE (this commit). `AppBootstrap.swift`'s landing comment names both lobbies that carry a walk (the
    launch road's, whose landing tries the quiet roads again; a lock's, which only re-reads) and says no landing is wired
    without a walk; `landTheFarWalk`'s doc says a context with NO walk is not a plain re-read (it takes every place and,
    unless the flag is false, tries the quiet roads over any far key file — hence no landing without a walk). Same stale
    claim, same file: `RoadContext.far`'s doc no longer lists "the relock's lobby" among the contexts with no walk.
    Comments only — the harness run under B2 compiled `ProtectionOpenRoad.swift`; `AppBootstrap.swift` builds at B5.
  - B4 F-R1-3 — DONE (this commit): the closing disposition line under ROUND 1 DISPOSITIONS — DEFERRED to VX-1090; no
    code.
  - B5 — DONE (this commit; the runs at the batch's END, on `71410a6ab`, nothing else running): Mac target
    `xcodebuild -scheme Variorum -destination 'platform=macOS' build-for-testing` ⇒ `** TEST BUILD SUCCEEDED **`, zero
    warnings in a file this batch touched. Phone target (`VariorumMobile`, `generic/platform=iOS Simulator`, a build — no
    simulator booted) ⇒ `** BUILD SUCCEEDED **`. Headless harness, every planted suite it carries (the new
    `CopyCountsAndRestoreListTests` linked in) ⇒ `✔ Test run with 214 tests in 36 suites passed` (batch 1's 210 + this
    batch's 4; every pre-existing suite UNMODIFIED). Core package, full `swift test` (batch 2 changed NO core source —
    `git diff 30caec3fa..HEAD -- Sources/` is empty) ⇒ `✔ 746 tests in 139 suites`, `━ 4204 tests in 579 suites passed …
    with 5 known issues` (the VX-529 suites' own `withKnownIssue`s, untouched), `✔ 32 tests in 4 suites`, `EXIT 0`.
    Parity: `git diff origin/main...HEAD -- Tests/ App/Variorum/VariorumTests/` shows only three NEW files
    (`FarFolderUnreadTests`, `OpenFarFolderWaitTests`, `CopyCountsAndRestoreListTests`) — zero edits to an existing test.
  - VX-524 — DONE AS FAR AS IT GOES WITHOUT A RULING (record-only + the fork). THE CONFIRM, pin first (`d9b91c896`): `App/Variorum/VariorumTests/Protection/
    CopyCountsAndRestoreListTests.swift` (new; 1 test) replays W-8's scene on a planted road through the REAL pair road
    (`takePairReporting` — the day's first pair beside the library AND, the picked folder due, its far copy; a second
    pair the same day beside the library only), the real lister and both real readers (`ProtectionCopyCounts.read`,
    `ProtectionCopyDoors.listing`). It asserts what a counting or listing defect would break — no copy rowed twice,
    every row counted by exactly one place's count, the rows the two counts' sum — and records W-8's shape. RUN on the
    current tree (headless harness): `✔ Test run with 1 test in 1 suite passed` — GREEN: the two predicates agree copy
    for copy (container 2, picked folder 1, three rows); the first pair's stamp IS two rows, one per place, the same
    day, time and kind, and a row names no place. SENSITIVITY (two mutations from the committed state `d9b91c896`, each
    restored by `git checkout --`, `git status` clean after): `CopyDoorsListing.make` rowing a far copy twice ⇒ `✘ … with
    3 issues` (no copy rowed twice; rows = the counts' sum; the first pair's two rows); `ProtectionCopyCounts.read`
    counting the picked folder's row from the container ⇒ `✘ … with 2 issues` (the far count; the sum). So the probe
    WOULD catch either defect the ticket suspected, and there is none.
  - VX-524 OUTCOME — RECORD-ONLY AS A CODE DEFECT (the pin green on the tree it was written against: the row is HOLLOW,
    no fix built) + A FACE FORK PROPOSED (below), STOPPED for the architect's ruling. Nothing in the app's code changed
    for VX-524; the probe stays as the agreement's regression pin.

**VX-524 — what the probe showed (the mechanism, settled).** Data Safety draws, in this order: "Copies of your library"
with ONE count row, "Beside your library" (`DataSafetyModel.primary` ← `RoadCopyCounts.container`); then the Restore list
(`RoadRestoreRows` ← `CopyDoorsListing.thisLibrary` — every catalogued copy of the open library, BOTH places); then the
second-folder section with its own count row (`destination` ← `RoadCopyCounts.far`). The pair road copies the day's FIRST
pair into the picked folder too (one a day there — `ProtectionBackupHook.landFarPair`, due per library per Mac), so that
pair stands as two physical copies: one beside the library, one in the picked folder. The list rows both; a row reads
its day and time and "Backup" (`RoadRestoreRows.rowView`: `asOf` + `ProtectionWords.copyKind`), never its place. W-8's
walk: five pairs beside the library ("5 copies" — the row right above the list), the 9:12 pair's copy in the picked
folder, six rows — the 9:12 backup twice, identically worded. Both predicates are right and agree copy for copy (the
rows = the two count rows' sum); the mismatch is what the face says. *Proposed correction of the ticket (the
orchestrator's to write on the board):* "Not a count defect: the Restore list lists the copies in both places — the
day's first backup stands beside the library and in your backup folder — and a row never says which, under a count
that is the copies beside the library alone."

**VX-524 — THE FORK (a face call; not built — the architect rules, PROVISIONAL where word-shaped):**
- (a) **RECOMMENDED — each Restore row says its place.** The row's second line gains the place: "Backup · beside your
  library" / "Backup · in your backup folder" (a `ProtectionWords` line; Look inside and Make this my library unchanged).
  Two physical copies stay two rows — each is its own thing to restore from (the picked folder's survives losing this
  disk), which is exactly why the far leg exists. Smallest change; word-shaped ⇒ PROVISIONAL for her bundle.
- (b) The list folds a pair standing in both places into ONE row (beside the library first; the picked folder's used
  when that one is gone). New behaviour in the doors (which file Look inside and Make this my library act on), and it
  does not close the gap: retention differs by place (the newest 14 beside the library; 14 days plus 4 weeks in the
  picked folder), so older picked-folder-only pairs still row with no container twin, and the rows again match neither
  count.
- (c) The counts say the split where the list stands — a total line atop the Restore list ("6 copies: 5 beside your
  library, 1 in your backup folder"), or the list drawn below both count rows. The arithmetic then reads, but the two
  same-time rows still do not say which is which.
Pin owed with whichever is ruled: (a)'s — a row's words name its place for both places (the probe's scene); (b)'s — the
fold, and the doors' file choice; (c)'s — the total line's arithmetic.

## THE LADDER

*(round 1: fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim, zero framing — RUNNING 2026-11-25; its findings land below)*

### ROUND 1 FINDINGS (cold reviewer, 2026-11-25)

Reviewed: `git diff origin/main...HEAD` (batch 1 + pieces 6a/6b), the record top to bottom, CastleRules in full,
SurfaceContracts "Library protection", SyncSpec in full (custody-adjacent diff), SessionResiliencyProtocol, and the
post-state of every touched file plus their reach (`Assess.swift`, `Catalog.swift`, `CatalogLister`, `ProtectionPlaces`,
`ProtectionFactsGatherer`, `ProtectionSystem`, `ProtectionOpenRoad` whole, `ProtectionRoadActs.searchIfOwed`,
`KeyFileOffer.searchKeyFiles`, `ProtectionOpenFaces`' faces mapping, `ProtectionLobbyModel`, `ProtectionLobbyFace.derive`,
`ProtectionRoadLock`, `AppBootstrap`'s open and lock seams, `StoreLockView`'s refresh wiring, `BackupDestination.resolve`,
both new test files). Ran `swift test --filter FarFolderUnreadTests` myself: 7/7 green.

**F-R1-1 · MAJOR · `App/Variorum/Shared/Protection/ProtectionLobbyModel.swift:208-229` (`refresh()`/`take(_:)`), with
`AppBootstrap.swift:593-600` and `StoreLockView.swift:71-77`** — a `refresh()` that overlaps the far walk's landing can
REGRESS the lobby to the partial (container-only) facts after the landing took the full ones: rule 27's banner, or the
far key file's typed road, appears and then silently vanishes, and `farLandingTaken` means the landing never re-lands —
the face stays regressed until the next `didBecomeActive` refresh.
*Mechanism (deterministic, no timing luck needed):* `refresh()` guards `!busy` but never SETS busy, so while its
detached `lobbyFacts(ctx)` read is in flight (a `.thisOpen` read — PARTIAL before the walk lands), `farWalkLanded()`
passes its own `!busy` guard, runs the landing and `take(full)`; `refresh()` then resumes and `take(partial)` overwrites
`standing` wholesale (`take` has no notion of listing width). `rederive()` then drops `noKeyFileAnywhere` (partial ⇒
`mightOpen` true) and the landed `offeredTyped`. Reachable in production: `refresh()` fires on every
`NSApplication.didBecomeActive` while the walk may land minutes later on a cold folder — the ticket's own scenario.
*Pin (red on this tree):* a `ProtectionLobbyModel` test with a GATED `refreshRoad` returning the partial standing —
start `refresh()`, hold the gate, call `farWalkLanded()` (lands full facts: `face.passphraseField` true / banner up),
open the gate, assert the face KEPT the landed facts. Today it regresses.
*Fix shape:* `take(_:)` refuses to narrow — a fresh read whose catalogue `!readsEveryPlace` never overwrites a standing
whose catalogue `readsEveryPlace` (one guard in `take`, the "a read that failed keeps the face" idiom extended:
a narrower read never replaces a wider one). Non-launch lobbies are untouched (their reads are always full).

**F-R1-2 · MINOR · `App/Variorum/Shared/Protection/CatalogLister.swift:37-57`** — `CatalogLister.Scope` /
`.containerOnly` / `catalog(scope:)` is DEAD CODE: zero callers anywhere (production or tests; grep `containerOnly`
finds only the declaration and its header sentence). The shipped mechanism is `CatalogRead` + `FarFolderWalk`; the
header comment presents Scope as the design ("a listing has a SCOPE — …"), and D-1013-2 in this record describes it as
built. Custody-adjacent dead code misleads the next reader into wiring the wrong seam (and `.containerOnly`'s own
`places.farFolder()` call re-resolves the bookmark per listing, unlike the walk's cached road). *Evidence:* grep;
compile-level fact, no pin owed (not bug-class). *Fix:* delete the enum and `catalog(scope:)` (keep `catalog()`), or
wire it where it was meant to serve; align the header and D-1013-2's wording.

**F-R1-3 · MINOR · `App/Variorum/Shared/Protection/CatalogLister.swift` (`FarFolderWalk.standing`/`farFolder`) +
`App/Variorum/Shared/BackupDestination.swift:115-128`** — a far folder that is PICKED but UNREACHABLE at resolve time
reads as `.noFarFolder` = "a container listing is a whole listing": `BackupDestination.resolve()` returns nil for
nothing-picked AND for an unplugged volume/stale bookmark alike, so the fence's own idiom ("could not read ≠ none") is
not applied to exactly the state it was coined for — rule 27's refusal and `backupHolds…` "no" stay claimable while her
picked backup folder is merely offline. LARGELY PRE-EXISTING (the pre-fix `if let far = places.farFolder()` had the same
conflation per listing), but the walk's per-open cache (`resolved = .some(nil)`, never retried) now extends one
transient resolution failure across the WHOLE open, where the old road re-resolved ~ten times. *Mechanism:* unplugged
far volume at launch + broken container (live key file gone, no memory/custody) ⇒ partial-listing fence never engages
(`unreadPlaces` empty) ⇒ `mightOpen` false ⇒ rule 27's lobby refusal over a library whose key file sits on the
unplugged disk. *Pin:* needs the input distinguished first (`BackupDestination.isSet` already exists), so the honest
shape is: widen `ProtectionPlaces.farFolder` (or the walk) to know picked-but-unreachable, mark `.farFolder` unread in
that state, pin red-on-old with the widened input defaulted to today's semantics. Scope call is the orchestrator's —
this may be its own ticket rather than this ladder's fix (it is not a regression of this diff).

**F-R1-4 · NIT · `App/Variorum/Shared/AppBootstrap.swift:642`** — the comment "the launch road's lobby only (a relock's
lobby carries no far walk)" is false since piece 6 (R-1013-A2): `ProtectionRoadLock.lobbyContext` sets `ctx.far`, and
the relock's lobby deliberately gets a `farLanding` road (tries-quiet-roads false). The code is right; the comment
contradicts it. Likewise `landTheFarWalk`'s doc line "Over a context with no far walk it is a plain re-read" is
inaccurate for a hypothetical `.everything` context whose catalogue holds far key files (it would try the quiet roads);
unreachable today (`farLanding` is nil when `ctx.far` is nil) but worth one honest clause for the next wirer.

**F-R1-5 · NIT (for the P-1013-2 sitting bundle, not a code change here)** — a press that joins a HUNG far walk has no
bound and no words: `busy` disables every lobby control for as long as the folder blocks (gate 1 measured ~nine
minutes), with no "still looking in your backup folder…" line and no cancel. Strictly better than the pre-fix blank
window, and exactly P-1013-2's ruled wait — but when her sitting reviews P-1013-2, the unbounded silent disable is the
part that may want a face word. No pin owed (the behavior is the ruled design).

**CLEAN BILL (checked, found solid):**
- *Rule 27 indeterminacy (D-1013-3):* all three Assess readings guarded (`lobby.mightOpen` at 223, the two unlocked
  fault arms at 280/305, the offer's owing at 512 via `backupMightHoldTheCurrentKeyFile` 557); the search's
  `.noKeyFileAnywhere` reaches the standing faces (`ProtectionOpenFaces` 223-225), so rule 27 after a quiet-road open
  stays reachable on a partial listing through `searchIfOwed`'s deliberate full walk. Core pins re-run by this reviewer:
  7/7 green; red-on-old mechanically certain from the diff (the pre-fix arms have no `readsEveryPlace` leg at all).
- *The sweep table:* every row re-verified against the post-state — including the rows the table calls FULL-WALK CALLER
  (`opensWith`/`routeFinder`/`useCastleSpec` have no launch-path reader; the launch route reads `assessment.launch`,
  `repairs`, `faults`, `acts` only) and row 12's R-1013-A1 posture (code untouched, the ruling pin labeled honestly as
  green-on-both-sides). Counts match (17 rows).
- *No launch-path far read:* every remaining `.everything` call site enumerated (backup hook/pair, copy counts/doors,
  `searchIfOwed`, `FileKeyFileStoreLeaf:60`) is a non-launch or deliberately-searching caller; the route, lobbyFacts,
  the open's expansion (facts handed through — D-1013-5's replumb at 443/624/1203), repairPasses, logSummary and the
  custody probe all read through the context or `CatalogRead.probing`. The probe's safety reasoning holds: this
  library's fingerprints are always nameable from the container's live file (rule 4 carries the history), the memory
  items, the plan and the staged key; far-only names belong to other libraries or to rule-27-broken states, where the
  launch landing's quiet retry (P-1013-3, pinned) or a press's join covers reachability, and a resumed Castle-entry
  settle keeps its own `.everything` walk.
- *Press equivalence (P-1013-2):* `openTypedOnce`'s join extends files, reuses derived Argon2id keys (`reusing:`), and
  the vault road runs AFTER the join over the extended files — outcome-identical to today on every arm I could
  construct; `pressTouchIDOnce`'s retry likewise. The N5 hand-forward and rule 21's reach preserved.
- *The relock (R-1013-A2):* `lobbyContext` + `beginTheFarWalkBehindTheLobby` + `finish(.roadLobby)` arms the same
  watcher; `farLandingTriesQuietRoads` false keeps "a lock is never theater" (pinned both ways); existing
  `ProtectionRoadLock.lobby` callers over plain contexts unchanged (the helper no-ops without a walk).
- *Serialization:* the landing never runs beside a press (`busy`/`farLandingOwed`/`left`, pinned); `left` set on every
  leaving arm; the bootstrap's watcher identity-checks the standing lobby; one walk per open (double-begin joins).
- *No sync, no schema, no canon:* the diff touches no `Sources/VariorumCore/Sync/`, no migration (Catalog's
  `unreadPlaces` is in-memory only), no canon file; CastleRules stays byte-identical; `StoreOpeningView` untouched
  (D-1013-6).
- *Parity:* `unreadPlaces` defaults empty, `.everything` the default read; zero edits to any existing test file
  (diff-stat verified) — the 3C parity pattern held.
- *Record discipline:* LIVE STATUS leads with what was NOT done; the VX-978 flake disclosed with its re-run; commits
  per piece, pushed; the Mac-target suites correctly left to the orchestrator's gate.

### ROUND 1 ROUTING (the orchestrator, 2026-11-25 — the cross-model flow)

Findings go VERBATIM to the batch-2 implementer for agree/dispute; the round-1 reviewer makes the final call on each;
the implementer then applies the confirmed fixes (red-on-old pins), and round 2's fresh reviewer re-checks them with
the VX-524 rider. The orchestrator's scope call the reviewer asked for, F-R1-3: ATTEMPT IN-LADDER with the one seam the
reviewer named (a far folder PICKED — `BackupDestination.isSet` — that fails to resolve reads as UNREAD far, never as
`.noFarFolder`'s whole listing; the per-open cache keeps whichever it saw); if the trace shows more than that one seam,
it becomes its own ticket instead, and the finding's disposition says so. F-R1-5 asks no code change and lands in the
sitting bundle below.

### ROUND 1 DISPOSITIONS (batch 2 implementer)

*Written 2026-11-25 by a fresh opus-implementer from its own read of the named code at `62347ecef` (no fix built yet —
the cross-model flow: the round-1 reviewer makes the final call on each). F-R1-5 is routed to the sitting bundle and is
not dispositioned here.*

**F-R1-1 (MAJOR) — AGREE, with the reviewer's fix shape.** My trace, `ProtectionLobbyModel.swift` at this commit:
`refresh()` (208–212) checks `!busy` and never sets it, then suspends on `refreshRoad()`. The bootstrap's road
(`AppBootstrap.swift:617–619`) is `Task.detached { ProtectionOpenRoad.lobbyFacts(ctx) }`; `lobbyFacts` → `ctx.facts()` →
the gatherer's FIRST statement `lister.catalog(read)` → `FarFolderWalk.catalog(over:)`, which reads `standing` once:
`.unread` ⇒ `Catalog.build(container, unreadPlaces: [.farFolder])`. So a refresh begun before the walk lands carries a
partial catalogue however long its custody listing then takes. While it is suspended, the bootstrap's watcher
(`awaitTheFarLanding`, 593–600 — `await far.read()`, the identity check, `lobby.farWalkLanded()`) runs on the main
actor: `farWalkLanded` (236–257) passes `!busy`, sets `farLandingTaken`, awaits the landing, and `take(full)`. When the
refresh resumes, `take(partial)` (217–229) replaces `standing` whole — `take` copies Touch ID items forward but has no
notion of listing width — and `rederive()` recomputes from the partial: `AssessRules.lobby`'s `mightOpen` is true on a
partial listing (`Assess.swift:223`), so `noKeyFileAnywhere` goes nil (the banner and `offersStartNew` vanish), and
`offeredTyped` loses any road only a far key file carried (`ProtectionOpenRoad.offeredTyped` reads `heldKeyFiles` →
`facts.catalog`). `farLandingTaken` stops the landing from running again; the face stays regressed until the next
`didBecomeActive` refresh (`StoreLockView.swift:71–77`), which reads the landed walk (`standing` never returns from
`.read`) and heals it. The press roads are NOT affected (a press reads its own facts through the context, full once
landed) — the loss is the face's: a passphrase field or rule 27's door that should be drawn is not.
Two notes for the final call. (1) In production the window is narrow — the refresh's read must straddle the landing AND
finish after the landing's own full read — so it is timing-dependent there; it is deterministic only under the pin's
gate. I do not dispute the severity on that ground: the landing's facts are P-1013-1's whole point, and the loss is
silent. (2) The phone shares the model (`MobileRoadFaces.swift:89–96` refreshes on `scenePhase == .active`) but cannot
reach the race: a far folder is never picked on iOS (`BackupDestination.remember` throws there), so its walk is
`.noFarFolder` and every listing is whole. The fix is shared and inert there.
*Fix (the reviewer's shape, agreed):* `take(_:)` refuses to NARROW — a fresh read whose `facts.catalog.readsEveryPlace`
is false never replaces a standing whose catalogue reads every place. It fires only in this race (a walk never goes
back from landed to unread); non-launch lobbies always read whole, so every existing pin is untouched. (I considered a
generation counter on `refresh()` instead; the width guard is narrower, needs no new state, and is the existing "a read
that failed keeps the face" idiom.) *Pin (app, red on this tree):* a `ProtectionLobbyModel` test whose `refreshRoad`
signals entry and then waits on a gate before answering the partial standing; the test starts `refresh()`, waits for
the entry, runs `farWalkLanded()` (whose road answers `.lobby(full)` with a far key file's passphrase road, or a full
listing proving rule 27), checks the face took the landing, opens the gate, awaits the refresh, and asserts the face
KEPT the landed facts. Run headless in the VX-306 SwiftPM harness recipe, red-on-old by reverting the guard.

**F-R1-2 (MINOR) — AGREE.** `git grep` over `App/`, `Sources/`, `Tests/` and `Tools/`: `containerOnly` and
`catalog(scope:` appear only in their own declaration and in the header's sentence (`CatalogLister.swift:21, 37–55`).
Every read takes `catalog()` (both roots) or `catalog(_ read: CatalogRead)`; the launch road's container-only listing
is `CatalogRead.thisOpen` over `FarFolderWalk.catalog(over:)`, which marks the far folder unread itself. So `Scope` is
dead, and its `.containerOnly` arm would resolve the bookmark at each listing — the opposite of the walk's once-per-open
cache, as the reviewer says. *Fix:* delete `Scope` and `catalog(scope:)`; `catalog()` keeps today's body
(`Catalog.build(entries())`); the header's VX-1013 paragraph rewritten to name the shipped seam (`CatalogRead` +
`FarFolderWalk`); an as-built line beneath D-1013-2 in this record (the design text itself left as written — it is the
orchestrator's). Not bug-class, no pin owed; the proof is the Mac target building and the harness suites green.

**F-R1-3 (MINOR) — AGREE ON THE MECHANISM; the in-ladder fix is NOT one seam ⇒ TICKET INSTEAD (the routing's own
exit).** The mechanism holds as written: production's far folder is `BackupDestination.resolve().map { … }`
(`ProtectionSystem.swift:119–121`), and `resolve()` answers nil both when nothing is picked (no bookmark data) and when
the bookmark no longer resolves (`try?` over `URL(resolvingBookmarkData:)`, `BackupDestination.swift:115–128`).
`FarFolderWalk.farFolder` caches that nil for the open (`resolved = .some(now)`, `CatalogLister.swift:210–218`), so
`standing` is `.noFarFolder`, `catalog(over:)` builds a whole listing, and on a broken container `mightOpen` is false and
rule 27 is claimed — over a key file that may sit on an unplugged drive. Pre-existing in kind (the old road's `entries()`
had the same `places.farFolder().map` conflation per listing); widened in time by the per-open cache.
Why the one seam the routing names does not close it alone — three things the trace shows:
1. **The resolve layer cannot tell "unplugged" from "gone for good."** Both a removed volume and a deleted or renamed
   folder whose bookmark no longer resolves land in the same `try?` nil. Marking every picked-but-unresolvable folder
   UNREAD (`BackupDestination.isSet`) fixes the unplugged case and BREAKS the gone case: with the container broken,
   `mightOpen` would stay true on every launch, so rule 27's face — and its only door, *Start a New Library*
   (`offersStartNew` reads `face.noKeyFileAnywhere`) — would never be offered again. The lobby would draw both typed
   fields (`ProtectionLobbyFace.derive`'s empty-roads arm), every press would refuse ("doesn't open"), the join would
   find nothing (`theWalk()` returns nil without a folder), and nothing in the lobby reaches Settings ▸ Data Safety to
   un-pick the folder. That trades an overclaim for a dead end. Which way the honest answer leans — rule 21's "if none
   opens it, rule 27 says so" against rule 27's "every backup gone" — or whether a face should name the unreachable
   folder ("your backup folder can't be reached…") is a product call, not a mechanical fix.
2. **The listing layer has the same conflation:** a folder that resolves but whose listing errors (a refused scope
   claim, a read error under the file provider) lands `.read([])` — `CatalogLister.list`'s `try?` over
   `contentsOfDirectory` answers `[]` for any error, not only for a `Variorum/` folder that is truly absent — and reads
   as "looked, nothing there." A second seam.
3. **The cache never retries:** a drive plugged in mid-lobby is not seen until the next launch (the old road's refresh
   re-resolved and would have seen it). A third seam, and batch 1's own widening.
*Disposition:* no in-ladder code. Proposed ticket for the orchestrator to mint (Bug · Suspected · Castle & sync · Low —
the harm is bounded: *Start a New Library* sets the unopenable library aside whole into Previous Libraries, never
deleting it), its one-liner: "A picked backup folder that can't be reached at launch reads as holding nothing, so the
lobby may claim no key file exists while one sits on an unplugged drive." Options to carry: (a) unread when picked but
unreachable, plus a face line naming the unreachable folder and rule 27's door still offered beside it; (b) today's
reading kept, rule 27's face saying the backup folder was not reachable; (c) unread for a bounded number of launches,
then today's reading. The listing-failure seam and the cache's no-retry ride the same ticket.
*Closing (batch 2, after the final call):* **DEFERRED to VX-1090** (Bug · Suspected · Castle & sync · Low · Needs
Lillian — minted by the orchestrator with the three face options, the listing-failure seam and the no-retry cache,
pointing here). No code in this effort: today's reading continues — a picked folder that cannot be resolved at an open
reads as none picked, for the whole open.

**F-R1-4 (NIT) — AGREE.** `AppBootstrap.swift:642`'s "(a relock's lobby carries no far walk)" is false since piece 6:
`lockOnNewRoad` (1514–1523) composes through `ProtectionRoadLock.lobbyContext`, which sets `ctx.far` and
`farLandingTriesQuietRoads = false`, and lands through `finish(.roadLobby(…))` → `makeRoadLobby`, so 643's
`ctx.far == nil ? nil : …` hands the relock's lobby a landing road. And `landTheFarWalk`'s "Over a context with no far
walk it is a plain re-read" (`ProtectionOpenRoad.swift:472`) is inaccurate for that hypothetical: with `ctx.far` nil the
read is `.everything`, so a catalogue holding far key files passes the `place == .farFolder` guard (478–481) and, with
the flag's default true, tries the quiet roads. Unreachable today (the bootstrap hands no landing without a walk).
*Fix:* the two comments corrected — 642 names both lobbies (the launch road's tries the quiet roads; a lock's only
re-reads); 472 says a context with no walk reads every place and, unless it is a lock's, tries the quiet roads once
more over any far key file, which is why the bootstrap wires a landing only where a walk exists. Comments only, no pin.

### ROUND 1 FINAL CALLS (the round-1 reviewer, 2026-11-25 — the cross-model flow's final word on each)

*Each disposition re-checked against the code before the call; F-R1-3's three-point trace verified line by line
(`BackupDestination.resolve`'s double-nil, `CatalogLister.list`'s `guard let top = try? contentsOfDirectory else
{ return [] }`, `FarFolderWalk.farFolder`'s `resolved = .some(now)` cache). No FINDER-FIXES: nothing here needs the
reviewer's own hands — no `Sync/` line, and every confirmed fix is small and fully specified. The implementer builds;
round 2 re-checks.*

- **F-R1-1 (MAJOR) — CONFIRMED-AS-PROPOSED.** The width guard in `take(_:)` (a fresh read whose catalogue
  `!readsEveryPlace` never replaces a standing whose catalogue reads every place), exactly as dispositioned — the
  guard must leave the nil-facts standing arm alone (a `standing.facts` of nil takes anything with facts, as today).
  The implementer's two notes accepted: the narrow production window does not soften the severity (the loss is
  silent, in the custody lobby, and the pin is deterministic); the phone's inertness is noted, no phone leg owed.
  Generation counter rejected in favor of the width guard, as dispositioned. Pin as described (the gated
  refreshRoad), red on this tree by the guard's revert, run headless in the VX-306 harness recipe.
- **F-R1-2 (MINOR) — CONFIRMED-AS-PROPOSED.** Delete `Scope` and `catalog(scope:)`; the header rewritten to the
  shipped seam; an as-built line beneath D-1013-2 (the design text itself stays the orchestrator's). No pin owed; the
  build and the harness suites are the proof.
- **F-R1-3 (MINOR) — TICKET-INSTEAD CONFIRMED.** The mechanism stands as found; the fix is genuinely not one seam, and
  the direction of the lean — unread-forever's dead end (rule 27's face and its only door never offerable over a
  gone-for-good folder) against today's bounded overclaim (whose *Start a New Library* sets the library aside WHOLE,
  recoverable) — is a product call the spec is silent on, so it is hers, never this ladder's. Mint the ticket as
  drafted (Bug · Suspected · Castle & sync · Low), carrying all three face options PLUS the listing-failure seam and
  the no-retry cache in the same ticket's body, and the pointer here. One addition: the ticket takes the "Needs
  Lillian" state (the face choice is hers; today's reading continues meanwhile — option (b) minus the face line, the
  status quo, acceptable at Low).
- **F-R1-4 (NIT) — CONFIRMED-AS-PROPOSED.** The two comments corrected as dispositioned; comments only.
- **F-R1-5 (NIT) — already routed:** rides P-1013-2's bundle item, as recorded above. Nothing owed from the
  implementer.

## HELD FOR HER SITTING (the away-run bundle)

- P-1013-1 (the lobby may gain roads/rule 27's banner after it draws, when the deferred far walk lands) — PROVISIONAL, built.
- P-1013-2 (a press that would refuse joins the in-flight far walk before refusing) — PROVISIONAL, built. The round-1 reviewer's F-R1-5 rides this item: the join has no bound and no words — the lobby's controls stay disabled, silent, for as long as the folder blocks (strictly better than the pre-fix blank window, and exactly the ruled wait, but the bundle review should see the unbounded silent disable).
- P-1013-3 (a quiet road the far walk reveals opens the standing lobby as a successful press would) — PROVISIONAL, built.
- Whether the blank `StoreOpeningView` should carry a quiet "Opening your library…" line after a grace delay — NOT built (taste; Settings' `.opening` arm already says those words).
- Rider candidates noticed at kickoff, not taken (single-ticket effort): VX-1015 (the "different library" notice at the vx-980 gate — its suspected cause already doubted in the ticket), VX-524 (copy-count vs restore-list row mismatch — same catalogue family).
