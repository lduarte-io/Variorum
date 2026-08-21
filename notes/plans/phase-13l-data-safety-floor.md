# Phase 13l — The data-safety floor (EXECUTION PLAN)

**Status: AUTHORED 2026-08-19 at the 13j closeout — HER PICK, same
sitting the 13j window closed (round 13). She launches it at her
word; cast decided at kickoff as always.** Supersedes nothing: the
2026-08-02 brief (`phase-13l-data-safety-brief.md`) remains the
scope's origin and is folded here whole; this plan adds what 13j
changed under it — **the world now contains TRUE DELETE, and the
restore story must be deletion-aware.**

## HER MANDATE (verbatim — the requirement born at the 13j close)

> "I think it would be fitting post trash and deletion for you to
> write the phsae desription for 13l - the data safety floor. we
> have to make sure that items that have been deleted when restored
> from backup are restored or not in the expected way, including
> after a true delete, in addition to the other items that phase
> has."

And the phase's founding why (2026-08-02): *"i feel like on some
level i've still been a little afraid to fully trust in the app /
sync / start REALLY using it and feeling secure that my data isn't
being lost."*

## Kickoff message (paste-ready for the orchestrator she invokes)

> You are running Variorum Phase 13l under the shape the author
> picks at kickoff (confirm the cast, never assume; the brief notes
> this phase is largely autonomous by nature — a low-attention
> window fits it). Read IN FULL first: `CLAUDE.md` + the canon it
> loads (AppSpec §14's 13j delta is the latest state), this plan
> TOP TO BOTTOM, `notes/plans/phase-13l-data-safety-brief.md` (the
> scope's origin — items 1–6, the kickoff decisions, the recorded
> leans), `notes/plans/phase-13j-purge-memo.md` + its addenda (the
> purge design this phase's drill must prove out), and the 13j
> plan's Environment traps section (binding, as every phase — the
> A1 rail, kills-by-PID-only, the real-store container path). Copy
> the P-1…P-9 constitution into this file verbatim if running
> under `/architect-phase`. Verify the baselines with your own
> runs (13j finals: core **1350/141** · Mac **1546/269 FULLY
> GREEN** · spine **63/8** · mobile **314/60**; mirror at lockstep
> marker **7**). **OPEN WITH THE KICKOFF SITTING** (short — the
> decisions below); nothing destructive-adjacent runs before the
> A1 rail, and every restore-drill act happens in SCRATCH
> locations, never against her real store.

## Scope

**The brief's six items, carried whole** (automated scheduled
backups with second-destination-first per the recorded lean ·
the rehearsed restore drill + runbook · the bulk-`.md` plaintext
insurance candidate · the sync-status face candidate · the
passphrase/recovery-phrase sanity check · the ruled-in app-level
lock with honest wording) — **plus the 13j-born seventh:**

### 7. THE DELETION-AWARE RESTORE MATRIX (her round-13 requirement)

What restoring a backup does to deleted things must be DEFINED,
ruled where taste-shaped, TESTED headless, and REHEARSED live.
The matrix, with the design facts 13j established:

| # | Scenario | Expected outcome | Status of the expectation |
|---|---|---|---|
| M1 | Tombstoned (in its Trash window) at backup time; backup restored | Comes back tombstoned, same clock, restorable from the Trash | Design fact — test pins it |
| M2 | Deleted AFTER the backup; store restored to before the deletion — SYNCED account | The old cursor re-pulls everything since, INCLUDING the deletion tombstone: the item re-enters the Trash. Convergent, no user surprise | Design fact (state-based feed) — convergence test pins it |
| M3 | Same as M2 — LOCAL-ONLY install | The deletion is undone: restore is deliberate time travel | Honest by doc (the runbook + restore face SAY it) — kickoff confirms the wording |
| M4 | **PURGED (true-deleted) after the backup; store restored to when it existed — SYNCED account** | **The restored store is exactly a RETURNER: `reconcileLedger` (pre-drain, preflighted — 13j ladder B) re-drops the purged families before anything pushes; a push naming a purged id takes the typed refusal + local drop. "Really deleted" SURVIVES backup restore — by machinery that exists, which this phase must PROVE, not build** | Design fact — the drill's centerpiece scenario + a convergence test against the fake server's ledger |
| M5 | Same as M4 — LOCAL-ONLY install (no ledger exists) | Restore resurrects the purged thing. **TASTE CALL (kickoff): accept-and-say-it (recommended — restore IS time travel, like any file backup; the restore flow's one honest sentence: "things deleted after this backup's date will return — including permanently deleted ones") vs engineering a store-external purge memory (machinery smell; against the phase's floor nature)** | HER RULING at kickoff |
| M6 | Purged content living on INSIDE old backup files until retention expires them | Honest disclosure: the purge memo's "unreachable-but-on-disk" statement EXTENDS to backup retention; the runbook says so, and retention length is named as a privacy parameter (older backups hold what you purged) | Doc deliverable — kickoff confirms the retention default with this framing in view |
| M7 | The device-cursor monotonicity under restore (same device_id, older local cursor) | The server cursor never regresses (`greatest(...)` upsert — 13j); the restored store re-pulls from its old cursor harmlessly; the horizon stays sound | Design fact — one targeted test |

**Sequencing note:** M4/M2/M7 are convergence tests on the
existing fake-server harness (it has the ledger, cursors, and the
typed refusal since 13j batch 6b) — headless first, then ONE live
rehearsal folded into the restore drill (scratch store, scratch
account NEVER hers — or the fake-server road if a scratch account
is disproportionate; the kickoff picks).

### 8. OPENING MINI-ITEM (her post-13j-close reports, 2026-08-19 — RULED same sitting): the note-deletion door set

Her words: "also how do i even delete a note? I'm within a note I
want to delete right now and I don't see how to delete it" → then
her ruling: "make it a note for 13l to include delete note in the
note menu with confirmation, to add a confirmation for the library
door of deletion, and to allow for command clicking to select
multiple items and deleting all of them." Build, opening the phase
(the 13e mini-round precedent):

- **FIRST ACT — the DEAD Delete Now door (her live report,
  2026-08-19 evening):** clicking Delete Now in the Trash produced
  NO confirmation and NO effect (the item still listed after
  leave-and-return — no intent minted, data safe). The confirm was
  ruled (13j round 10) and built with green seam-pins — this is
  the A1 pins-over-dead-wiring class ON the surface the
  screenshot drive couldn't capture. **MECHANISM TRACED (the
  architect, read-only, 2026-08-19 — the fixer confirms red-on-old
  before touching it):** `RecoveryView`'s `.confirmationDialog`
  presents off `isPresented: Binding(get: { model.pendingConfirm
  != nil } …)` — a COMPUTED binding over an `@Observable`
  property that is never read during body evaluation, so setting
  `pendingConfirm` registers NO observation dependency, the view
  never re-renders, the binding's get is never re-asked, and the
  dialog never presents: the click sets state nobody is watching.
  The overlay/sink family's letter ("wiring is the delivery").
  **BOTH purge doors ride this road — Empty Trash's
  `requestEmptyTrash` sets the same `pendingConfirm` — so true
  delete is currently UNREACHABLE from the UI entirely** (the
  30-day clock + janitor road still purges on schedule; nothing
  else is affected). Fix shape: make the presentation state
  observable-in-body (`@Bindable`/a body read), and the pin
  MOUNTS THE REAL TRASH SURFACE and drives the real button —
  never the view-model seam that stayed green over this.

- **"Delete Note…" in the note ▾ menu — WITH CONFIRMATION** (her
  ruling); ordinary move-to-Trash ONLY (the round-3 rider stands:
  Delete Now never appears in note context); the receipt names the
  Trash and its clock; **navigate-away covers EVERY pane/window
  showing the note** (13f workspace — the Library door shares this
  choreography when the deleted note is open somewhere).
- **The Library door gains the same confirmation** (her ruling) —
  one wording, both doors.
- **⌘-click multi-select in the Library + delete-all-selected**
  (her ruling): ONE confirmation naming the count ("Delete 5
  notes?"), ONE receipt; scope = Library note rows first (blocks
  already ⌘-click since 13e; shelf books at her word); registry +
  walk as always.
- **The confirmation-consistency PRINCIPLE, written down** (13j
  audit): notes confirm (container-scale, deliberate); blocks and
  takes do NOT (in-flow acts — ⌥⌘Z + the tray/History cover them;
  J9 exists precisely to unfriction paragraph deletion); Delete
  Now/Empty Trash always confirm (unrecoverable). Future doors
  inherit the rule instead of re-deciding it.

### 8b. 13J-AUDIT ADDITIONS (the architect's close-of-day deletion audit, 2026-08-19 — recorded for this phase)

- **RULED (2026-08-19, her words): "there are no future upgraders
  I'm the only user. and the notes i already deleted are fine to
  be deleted."** → The backlog amnesty is DECLINED (the janitor
  proceeds); the future-upgrader sentence is DROPPED from this
  phase (revisit at the v1-release-readiness row, where strangers
  become real). The item below stands as the record of the
  consideration:
- **The pre-13j deleted backlog (tell-her-first class):** anything
  tombstoned >30 days BEFORE 13j left every surface at the upgrade
  (the read-side fence grandfathers nothing) and becomes
  purge-eligible once the horizon passes — for HER this is the
  feature she asked for ("posts I don't want to have"), but 13l's
  kickoff confirms she wants no last look; if she does, a ONE-TIME
  amnesty listing (tombstoned-past-window, Put back offered) is a
  bounded add here. For future USERS upgrading with old deletions,
  the same moment deserves one honest sentence — kickoff decides
  where.
- **M6 WIDENS to external backups:** Time Machine (the brief's own
  interim advice points it at the container) and any file-level
  backup hold purged content OUTSIDE our retention — the runbook's
  disclosure names external snapshots, not only our own files.
  **AND the flip side, her ask (2026-08-19): a backup stored
  elsewhere and OVERWRITTEN/rotated after a deletion will NOT have
  the deleted thing** — the runbook states both directions: old
  backups retain what you purged (until rotation), and rotated
  backups lack what you deleted before they were taken; the
  retention window is therefore ALSO the oops-recovery horizon
  beyond the Trash's 30 days. Her ruling on the retain side:
  external backups keeping deleted items "is fine and should be
  that way." 
- **Pool/scraps deletion honesty check:** verify a deleted POOL
  reads honestly in the Trash (kind naming, cascade of its
  scraps, Put back) — the story was built container-generic; the
  check is that its FACE never calls a pool a note.
- **Archived-blocks badge watch-item (no change ruled):** the ⌫
  badge counts deleted only (round 5) — ruled before block archive
  existed (round 7). A note with ONLY archived blocks shows no
  badge; the note ▾ tray item is the road. Watch in her real use;
  revisit only if she trips.

### 8c. SUPER-MINOR RIDER (author, 2026-08-21, added post-authoring): remove the left-margin comment ＋

Her words, verbatim: "I need the comment + on the left removed …
it's too crowded and I don't like the look of seeing it there …
the comments + to the left is currently annoying me though so
removing it can be a super minor 13l item." This is the 13e
batch-6 margin-hover ADD-door (the ＋ that appears in the left
margin on hover) — REMOVE the ＋ affordance; the margin-hover
comment DISPLAY and the other add doors are untouched. Removal
only, no redesign — the fuller comments-area rework is 13u's
(item 3 on that row), deliberately NOT this phase's.

### 9. Journal-day deletions TRAVEL to Fragments (her ruling, 2026-08-19)

Today the bridge's sweep reads LIVE days only, so a deleted
Variorum journal day just goes silent Fragments-side — the entry
stays, and a later Fragments edit re-lands the day as a fresh
Variorum note (purged content returning via the co-writer). Her
ruling: fix it. The design shape to size at kickoff: the bridge
already keeps `bridge_day` hash rows, so it KNOWS which days it
bridged — a bridged day that is no longer live pushes its deletion
ONCE (the empty-body road the contract already speaks inbound);
Put back self-heals (the sweep sees the day live again and
re-pushes the body). Timing question for the kickoff: travel at
DELETE time (mirrors her intent fastest; Put back re-lands it) —
recommended — vs only at purge. Any Fragments-side need (how it
renders a pushed deletion) is a contract-file ask
(`notes/fragments-bridge-contract.md`, she carries it); nothing
typed on either side is ever lost — the standing bridge doctrine
binds (insurance commits before any overwrite). If this item
bloats the phase, it becomes its own micro-slot at her word.

## Kickoff decisions (hers — the brief's list, plus this plan's)

1. Backup destination(s) + retention (propose: daily, 14 dailies +
   a few weeklies; second-destination-first per the lean; one
   iCloud Drive copy legitimate). Retention framed WITH M6's
   privacy angle.
2. Candidates 3 and 4 (plaintext insurance; sync-status face) in
   or out.
3. Where visible freshness evidence lives (log vs face).
4. The app lock's fallback story (passphrase-when-enrolled +
   system fallback otherwise, or one uniform story).
5. **M5's ruling** (accept-and-say-it recommended) + M3/M6 wording
   confirmations.
6. **RULED IN DIRECTION (2026-08-19, her words: the Fragments
   callout "was great to surface - I didn't realize it wouldn't
   delete from fragments and that will have to be fixed"):**
   journal-day deletions MUST travel to Fragments — scope item 9
   below; the kickoff SIZES it (in this phase, or its own
   micro-slot if it bloats).

## Binding constraints

- ZERO schema expected; anything firming toward one is a SyncSpec
  §12 lockstep event and a STOP for her explicit go.
- Zero `Sources/VariorumCore/Sync/` lines without the standing
  rider (M4's test may need fake-server harness extensions —
  Tests/, not Sync/; if the proof demands engine changes, STOP
  and report).
- **Every drill act in SCRATCH locations** — the real store is
  touched only by the SHIPPING backup scheduler itself, behind
  the A1 rail; restore rehearsals never point at her container.
- The 13j Environment traps bind verbatim (by reference); the
  standing RPC naming rule (no parameter shadows a column it
  writes — born at 13j round 12) binds any new server-adjacent
  code, though none is expected.
- Every PROVISIONAL → `notes/QUESTIONS.md` (next free number:
  check at kickoff — 13j used through **#73**).
- The tutorial spine (63/8) stays green; if the phase ships a
  user-facing face (the lock, the sanity check, the status face),
  registry discipline (P-1) and honest copy (the J8 bar) bind as
  everywhere.

## Baselines at open (verify with your own runs)

The 13j finals: core **1350/141** · Mac **1546/269 FULLY GREEN** ·
spine **63/8** · mobile **314/60**. Mirror at lockstep marker
**7**; the purge machinery live end-to-end (both devices cursored;
the janitor's first sweeps no-op until the horizon passes her
pre-13j tombstones — expected).

### ⚠️ MAC CODE CHANGED IN THE GAP BETWEEN PHASES (2026-08-21) — her instruction to record it here

**The 13j finals above are NO LONGER the Mac's baseline.** Mobile
Round 2 (`notes/plans/mobile-round-2.md`, running in the
`~/dev/variorum-mobile` worktree on branch `mobile`) fixed a crash
whose brain lives in `App/Variorum/Shared/EditorBrain/` — shared by
BOTH platforms — so the fix necessarily landed Mac-side too. The
author asked for this note explicitly: *"is the normal discipline for
the variorum mac app being handled in regards to phase count since
this cross platform bug is being handled? please make a note in 13l's
plan that changes came through in the gap between phases."*

**What changed on the Mac, and why a mobile round touched it:** her
iPhone crashed deleting a multi-line selection at a note's end
(`BlockRangeIndex`'s mutators trapping on a stale edit verdict). The
trace proved the Mac's `EditorViewModel.storageDidEdit` is the SAME
shape line for line — **latent, not prevented** — and the ladder's
Mac twin pins then went red on the pre-fix tree, upgrading that from
suspicion to proof. Leaving the Mac unfixed would have meant
knowingly shipping a proven crash road, so round-2 principle M-B (a
shared brain changes once, and BOTH suites run) applied.

**Mac-side files touched:** `Shared/EditorBrain/BlockRangeIndex.swift`
(four mutators refuse instead of trapping), the new
`Shared/EditorBrain/EditorEditRouting.swift` (`ArmedEdit` +
`EditorAssertionSeam`), `Features/Editor/EditorViewModel.swift` (the
armed-verdict binding + the desync routing), and
`VariorumTests/{BlockRangeIndexTests,EditRoutingTests,EditRoutingCrashTests}.swift`.

**Mac counts after batch 1: 1546/269 → 1563/272** (+17 tests, +3
suites, all new pins). Green. *(A ladder fix round is in flight as
this note is written and may move the number again — **verify with
your own run**, which this section's own heading already tells you to
do. That instruction is now load-bearing rather than routine.)*

**Where it lives:** branch `mobile` only. It reaches `main` at the
next `mobile` → `main` merge, which happens **at her word** (the
standing rule in `notes/plans/mobile-app-plan.md`). If you are reading
this on `main` and the files above do not carry the change, that merge
has not happened yet — pull it or coordinate before assuming a
baseline.

**No 13l scope is affected** — nothing here touches backups, restore,
deletion or the purge. The only cost to this phase is the count
baseline, which is why the note sits in this section.

## Verification

Per-batch: the standing loop (build → red-on-old pins → the spine
green by TYPE name → full suites with counts quoted; mobile when
`Sources/`/`Shared/` is touched — iPhone 16e). The phase's own
acceptance: **a backup restores end-to-end in rehearsal with the
deletion matrix's expectations holding scenario by scenario; the
runbook exists where she can find it under stress; freshness
evidence is visible without her asking; and the matrix's two
honesty sentences (M3, M6) exist in the product/runbook verbatim.**
Review shape: the author sets it at kickoff. The closeout authors
the next phase's plan at her pick, writes the MobileSoul parity
line (the lock's Face ID twin + any status-face twin are the
obvious candidates), and runs the full closeout ritual.
