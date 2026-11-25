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
- **D-1013-3 — Unread-far is indeterminate, by the road's standing idiom** ("could not read ≠ opens nothing", `ProtectionFactsGatherer`; "anything that might still open it says nothing", `AssessRules.lobby`). Concretely:
  - Rule 27 is NEVER claimed on a partial listing: `AssessRules.lobby`'s `mightOpen` treats an unread far place as possibly-holding ⇒ `noKeyFileAnywhere` stays nil until a full listing proves it; the unlocked `noKeyFileAnywhere` fault and `backupHoldsTheCurrentKeyFile` (Assess.repairs ~278/~301) likewise do not fire while far is unread.
  - The no-backup-yet consult (Assess ~551) does not claim "no backup exists" on a partial listing; its act waits for a full-listing assessment (the backup hook's own moment walks everything anyway).
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

*Batch 1, opus-implementer, session 1 (2026-11-24). No behavioural revert is in flight.*

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
5. NOT-STARTED — the sweep table (D-1013-3) below.

## THE LADDER

*(after batch 1: fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim, zero framing)*

## HELD FOR HER SITTING (the away-run bundle)

- P-1013-1 (the lobby may gain roads/rule 27's banner after it draws, when the deferred far walk lands) — PROVISIONAL, built.
- P-1013-2 (a press that would refuse joins the in-flight far walk before refusing) — PROVISIONAL, built.
- P-1013-3 (a quiet road the far walk reveals opens the standing lobby as a successful press would) — PROVISIONAL, built.
- Whether the blank `StoreOpeningView` should carry a quiet "Opening your library…" line after a grace delay — NOT built (taste; Settings' `.opening` arm already says those words).
- Rider candidates noticed at kickoff, not taken (single-ticket effort): VX-1015 (the "different library" notice at the vx-980 gate — its suspected cause already doubted in the ticket), VX-524 (copy-count vs restore-list row mismatch — same catalogue family).
