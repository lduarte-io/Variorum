# Phase 8 — iOS journal capture

## Kickoff message (for a fresh session)

> You are starting **Phase 8 of Variorum** — iOS journal capture: a minimal iPhone app over
> the same `VariorumCore` + sync engine, so the author journals from her phone and the app
> becomes daily-usable. **First, verify Phase 7 is closed** (the master plan pointer says
> Phase 8; `notes/plans/phase-07-editor-core.md` records a two-round cold review with final
> counts) — if it is not, stop and report. Read, in order: `CLAUDE.md`,
> `notes/CoreDescription.md` §"The pillars" item 8 (mobile as a smaller surface — the product
> contract for this phase: add journal entries, edit existing blocks' active text, **no
> variant/fan gestures**; journal restrictions are a UI profile, never a separate data
> model), `notes/AppSpec.md` §1–2 (targets/architecture), §7 `setting` (segmentation is
> synced *because of this phase* — capture must segment identically), §9 (the ops this
> surface calls: `createPost`, `newBlock`, `autosave`, `idleAutoCommit`), `notes/SyncSpec.md`
> in full (§10 names what ships; the engine + `SupabaseTransport` + real-server DDL already
> exist from Phase 5 — you are *wiring*, not building, sync), the master plan's Phase 7
> closeout paragraph, the KnownIssues entry this phase owns (**idle auto-commit
> scheduling**), and this plan in full. Key context: **baselines — core `swift test` = 383
> green in 39 suites; Mac app target = 86 green in 12 suites (Swift 6 mode). Do not re-run
> either at session start.** The Mac editor is Phase 7's finished surface — this phase does
> not touch `App/Variorum/Variorum/Features/Editor/` except where a step explicitly says
> "shared". **Step 1 is an author-assist gate** (iOS target creation + signing is a
> machine-side GUI step, hers; mirror Phase 7's flow — she creates, you verify + fix + commit,
> never redo blind). **Step 6 is a second author-assist point** (her Supabase credentials on
> the phone). Views are functional and unstyled — zero polish until Phase 13. Deployment
> target iOS 26; `SWIFT_VERSION = 6.0` from day one (Phase 7's review caught the template
> defaulting to 5 — check it at Step 1 verification).

**Goal:** the author creates a journal entry on her iPhone in seconds, edits any existing block's active text, scrolls her past entries — offline-tolerant, converging with the Mac through the Phase 5 engine, with the long-idle auto-commit insurance finally scheduled (the app is becoming daily-usable, which is exactly when it matters).

**References:** CoreDescription pillar 8; AppSpec §1–2, §7 (`setting`, `container.profile='journal'`), §9; SyncSpec §2–§5, §10; master plan Phase 8 row; KnownIssues "Idle auto-commit scheduling" (owned here); Phase 7 plan (the shell patterns to reuse: `AppBootstrap`, recoverable open, `AppSession`, `OperationsRunner`, `AutosaveCoordinator`).

---

## Ground rules

- **The narrow surface is the product design, not a v1 compromise** (CoreDescription pillar 8): create entries, edit active text, list/scroll. No fan UI, no structural ops, no readings, no pool. An entry can graduate to a full post later with zero migration — because there is nothing mobile-specific in the rows it writes.
- **Same store, same operations, same sync engine.** The iOS app is a second client of `VariorumCore` — every write flows through Operations onto the trigger-fed outbox exactly like the Mac. No iOS-only persistence, no direct row writes, no "lightweight" bypasses.
- **The editing control is NOT the Mac editor.** Phase 7's TK2 stack is macOS AppKit; the TK2 mandate and its discipline apply to the *Mac editor core* (AppSpec §4). The iOS capture surface edits entry-scale text — see the flagged interpretation below.
- **Reuse the Phase 7 shell layer by sharing, never duplicating:** `AppBootstrap`-style recoverable open, `AppSession`, `OperationsRunner`, and the platform-neutral parts of `AutosaveCoordinator` should compile into both targets (shared folder/target membership — mechanics are the implementer's call; a fork of the autosave logic is not acceptable).
- **Sync wiring uses what Phase 5 shipped:** `SyncEngine` + `SupabaseTransport` + the deployed DDL. Auth stays the single-user token (hardening is Phase 14, KnownIssues). Credentials are the author's — never committed; the Mac uses untracked `.env.supabase.local`, and the iOS equivalent is decided WITH her at Step 6.
- **Flagged interpretation (decide at Step 3, record in closeout):** the capture editing control. Options: (a) **SwiftUI `TextEditor`** — simplest true-to-scale choice for one-block journal entries; the AppSpec §4 ban targets the Mac editor core, not a phone capture field; (b) a `UITextView` wrapper — closer to the Mac editor's shape, more control, more code for no current requirement; (c) share nothing and treat each entry as a plain text field — too little (multi-paragraph entries are normal). Provisional reading: **(a)**, PROVISIONAL, logged to QUESTIONS — with the explicit note that Phase 15 (full iOS surface) revisits the control choice when block identity must live on the phone.

## Steps

### Step 1 — iOS app target (AUTHOR-ASSIST GATE)
**Files:** the Xcode project gains an iOS app target (`VariorumMobile` or the author's preferred name) wrapping the `VariorumCore` package; `App/Variorum/VariorumMobile/` sources.
**Work:** the author creates the target in Xcode (GUI + signing, hers): iOS app, SwiftUI lifecycle, storage None, local package dependency on the repo root, automatic signing with her team, deployment target iOS 26. **Verification duties (yours, before the first commit — Phase 7's lesson list):** `IPHONEOS_DEPLOYMENT_TARGET = 26.0` in every configuration; `SWIFT_VERSION = 6.0` in every configuration (the template still writes 5.0); the VariorumCore *product link* actually present (her Phase 7 target had the package reference but no product dependency); a shared scheme so `xcodebuild` works without her xcuserdata; unit-test bundle included. Commit the verified target as its own first act.
**Tests:** `xcodebuild -project App/Variorum/Variorum.xcodeproj -scheme <MobileScheme> -destination 'generic/platform=iOS Simulator' build` green; the core suite untouched.

### Step 2 — Bootstrap + store on iOS
**Files:** `VariorumMobile/MobileApp.swift`, shared bootstrap pieces (see ground rule).
**Work:** the recoverable-open path on iOS (Application Support inside the app container; same `StoreOpenError` → a functional failure screen with retry/quit); `AppSession` construction; `@Dependency(\.database)` installed before any view. WAL + off-main I/O hold as on macOS (P2 — GRDB is unchanged).
**Tests:** shared-code compilation into both targets (the Mac suite still 86 green); a simulator-run smoke: launch, store opens, empty state renders.

### Step 3 — Capture: create + edit journal entries
**Files:** `VariorumMobile/Features/Capture/` (entry list VM + views, entry editor VM + view).
**Work:** "New entry" = `createPost(profile: .journal)` (seeds `one_block` segmentation + `entry_date` today per schema/§7) and the first keystroke mints THE block (`newBlock`) — same one-block semantics the Mac editor ships; editing an existing entry (or any post's block) edits the **rendered variant's** `working_text` via the shared autosave coordinator (debounced, churn-fed, keep-pending on refusal — the Phase 7 posture comes along by sharing the code). Blocks with fans render the chosen/default take's text and edit exactly that variant — the fan itself is invisible here (pillar 8). Sealed posts render read-only with the refusal surfaced. The editing control per the flagged interpretation.
**Tests:** VM-level: create-entry writes exactly the `container`+`block`+`variant`+`container_block` rows (state-transition style, in-memory store); edit-then-flush lands the buffer text on the right variant; a locked/sealed target surfaces the refusal and keeps the buffer (shared coordinator's tests already prove keep-pending — add the iOS VM's surface assertion).

### Step 4 — List + scroll past entries
**Files:** `VariorumMobile/Features/Capture/` (list).
**Work:** bounded `observeLibrary` (journal-profile filter via the existing query vocabulary), newest-first by `entry_date`, opening an entry loads its rendered text (`Queries.renderPost`). Reading is cheap and virtualized by SwiftUI's list machinery — no live editor except the entry being edited (P3 at phone scale).
**Tests:** observation delivers on entry creation/edit (reuse the Phase 4 observation test pattern against the mobile VM); list stays bounded.

### Step 5 — Idle auto-commit scheduling (KnownIssues, owned here)
**Files:** shared scheduler (both app targets), e.g. `App/…/Shared/IdleCommitScheduler.swift`.
**Work:** the app-side detection AppSpec §9 assigns to the app: on launch and periodically while running (injectable clock), sweep dirty posts whose buffers have been idle past `idle_commit_hours` (setting, default 24) and run `Operations.idleAutoCommit` — at most one auto commit per idle period per variant (the op already enforces its own rules; the scheduler only decides *when to ask*). Runs on Mac AND iOS — the entry is resolved for the product, not one platform.
**Tests:** deterministic-clock tests: a dirty-then-idle post gets exactly one auto commit; an untouched post gets none; a clean post gets none; the sweep's cost is bounded by dirty posts, not corpus (P1).

### Step 6 — Sync wiring on the phone (AUTHOR-ASSIST: credentials)
**Files:** `VariorumMobile/Features/Sync/` (engine lifecycle + status row).
**Work:** `SyncEngine` over `SupabaseTransport` with a foreground-simple schedule: pull+push on app-foreground and after local writes settle (debounced), push on background transition; offline is free (the outbox queues; capture never blocks on the network). A one-row functional sync status surface (last sync, pending count, error) — SyncSpec §10's "sync status indicator" scope, nothing more. **With the author:** how her URL + token reach the device (untracked config in the app sandbox, a paste-in settings field, or her call) — never committed, and note her standing key-rotation practice.
**Tests:** engine tests already prove convergence (Phase 5); this step's tests are lifecycle: a foreground trigger runs one engine round (fake transport); writes while "offline" accumulate in the outbox and drain on the next round; the status VM reflects pending/error states.

### Step 7 — Phase verification
**Work:** (i) both suites + the new mobile tests green (`swift test`, Mac app suite, iOS simulator suite); (ii) **the two-store convergence scenario run at editor-rate from the *mobile* op stream** (create entries offline, edit a Mac-authored block, sync, byte-identical tables, empty outboxes — the Phase 5 harness with this phase's write pattern); (iii) **real-device round-trip with the author**: she journals on the iPhone, it appears on the Mac; she edits the same entry's text on both sides across an offline window and the conflict lands as a variant on the Mac fan (S5 — verify the phone shows the winner and *nothing is lost*); (iv) offline capture on the phone (airplane mode), then sync. Record counts + the real-device observations in the closeout.
**Author calls due at this checkpoint:** ratify the capture-control interpretation; anything Step 6 surfaced about credential handling.

## Explicitly out of scope
Fan/variant gestures, structural ops, readings/views beyond the entry list, the pool, references, and export on iOS (Phase 15 revisits the mobile surface); sync auth hardening (Phase 14, KnownIssues); any styling (Phase 13); widgets/share-sheet capture (nice ideas — QUESTIONS if the author wants them owned).

## Risks / things to watch
- **Signing/provisioning friction is real machine-side work** — budget the author-assist gates; nothing here is workaroundable without her.
- **Two app targets sharing sources** is where builds rot: shared files must belong to both targets deliberately (folder-level membership), and the Mac suite must stay green after every share.
- **Don't let capture grow an editor.** The moment a mobile view wants block boundaries, fan chrome, or structural gestures, stop — that is Phase 15 (or the author's explicit call), not this phase.
- **Background execution on iOS is deliberately not solved here** — foreground-triggered sync is enough for journaling; a background-task scheduler is complexity the phase doesn't need (revisit with real usage evidence).
- **The `sync_state.device_id` already distinguishes clients** — verify the phone mints its own on first launch (Phase 5's machinery; a shared/cloned store would poison per-row seq bookkeeping).
