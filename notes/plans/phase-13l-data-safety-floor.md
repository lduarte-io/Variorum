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

- **FIRST ACT — A FABLE COLD REVIEW OVER EVERY MAC CHANGE MOBILE ROUND 2 MADE (author instruction, 2026-08-21).** Her words:

  > *"i'd also update 13l that its first act will be running a fable
  > cold reviewer over all the changes that happened to the mac app
  > during this phase though - seems like we have several items hoisted
  > out so they can be shared and reused."*

  **Why she asked for it:** Mobile Round 2 fixed a crash whose brain is
  shared, and in doing so it moved real logic OUT of Mac-app-local files
  into `App/Variorum/Shared/EditorBrain/` so both platforms could use
  one rule. Those hoists were each verified by the Mac suite riding
  unmodified — a good proof that behaviour did not change — but **no
  cold reviewer has ever read the Mac side of that work with Mac eyes.**
  The mobile round's own ladders reviewed it as mobile work.

  **Cast: FABLE, her word.** (Mobile Round 2 ran all-Opus because her
  Fable credits were low; she has named Fable for this review
  specifically. Confirm the cast at kickoff as always — if Fable is
  still constrained, that is a kickoff conversation, not an assumption.)

  **The reviewer runs `notes/REVIEW_PROMPT.md` VERBATIM** over the Mac
  half of the round's diff, cold, with no framing.

  **THE MANIFEST OF WHAT CHANGED MAC-SIDE** — *the mobile round's
  closeout COMPLETES this list; it is partial until then, because that
  round was still running when this section was written*.

  > **CAUGHT UP THROUGH BATCH 4 on 2026-08-22** (Mobile Round 2's cold
  > consistency audit, finding 6: this manifest was missing **four**
  > Mac-side changes, including the one behaviour NARROWING in the
  > round). Batches 5–8, a consolidated fix round and two more review
  > passes were still ahead of it at that date, so it is **still
  > partial** — the round's closeout is what closes it. Everything
  > added in that pass is marked at its own line, so what is new is
  > visible rather than blended in.

  - `Shared/EditorBrain/BlockRangeIndex.swift` — the four mutators
    (`applyBlockEdit`, `applyTailEdit`, `openTail`, `closeTail`) now
    REFUSE (return `Bool`) instead of trapping on a `precondition`;
    bounds and overflow folded into the same guards. **Hoisted IN:**
    `wholeBlockDeletion(covering:replacement:)` and
    `caretLandingAfterRemoving(_ blockIDs:)`, lifted out of
    `EditorSurfaceController`.

    **THREE THINGS IN THIS FILE CHANGE MAC BEHAVIOUR, and the manifest
    named none of them until 2026-08-22** (Mobile Round 2's cold
    consistency audit, finding 6):

    1. **THE GAP FENCE — a Mac behaviour NARROWING, and after the O(N²)
       fix the most review-worthy item here.** `wholeBlockDeletion` now
       **declines any run containing a GAP entry** (a block whose
       variant has not arrived — `variantID == nil`, SyncSpec §5). The
       reason is sound and is parity-of-rule, not a new product rule:
       under tombstone-wins (SyncSpec §6) a sweep that takes a gap
       deletes **the peer's paragraph when the variant lands — content
       she has never seen** — one keystroke after the gate promised in
       words that the block *"is read-only for now"*; and J9 was the
       only planner in the Mac's if/else ladder **without** the
       `variantID != nil` guard its two siblings already carry.
       **But it narrows a shipped Mac gesture, and the Mac's half of it
       is BROKEN.** Round 2's §34(a) adjudicated that the Mac would land
       on `CrossBlockRefusal.diagnose` and speak *"A block in this
       selection hasn't arrived yet…"* — **§44's MAJOR 1 falsified
       that on two counts**: merge-then-edit intercepts first (a gap
       renders **zero-length**, so `CrossBlockEditPlanner.plan`'s
       `NSIntersectionRange(...).length > 0` collection can never touch
       it, and the plan is accepted for the two readable blocks), and
       `diagnose`'s own step 3 uses the same intersection test, so the
       gap is invisible to it too. `ops.merge` then throws
       `.blocksNotAdjacent` and `EditorViewModel.operationMessage` has
       **no case for it** — she reads a raw
       `blocksNotAdjacent(first: "…", second: "…")` enum dump. **The
       phone is not exposed** (it got the fence face above
       merge-then-edit and a real sentence); **the Mac got neither
       half.** Three-part fix, each with a red-on-old pin available:
       give the Mac the phone's fence arm · make `diagnose` step 3
       treat a zero-length entry inside the span as touched · give the
       Mac the `.blocksNotAdjacent` sentence its phone sibling has.
       **This is R8 work** (a shared-defect consequence a mobile round
       created Mac-side) and it is the reviewer's to confirm. *Also
       worth checking deliberately: the fence reads ONLY
       `variantID == nil` — never `editable`, never a fan count — so
       **a block carrying takes is never fenced**, which is the author's
       own `planVisibleTakeEdit` boundary and must stay intact.*
    2. **`caretLandingAfterRemoving` was O(N·M) on the MainActor, and
       its hoisted doc asserted a property FALSE for one of its two
       Mac callers.** The linear scan per ID made M = N on a select-all;
       reproduced standalone (`swiftc -O`): N=1,200 → 10 ms · N=5,000 →
       59 ms · **N=20,000 → 913 ms**. Fixed with a dictionary/range
       lookup, and the perf pin **extended to the landing** so both
       halves of the claim are measured (the round's re-review
       differential-tested the rewrite over **200,000 random tilings,
       zero mismatches**, and reproduced the perf claim independently at
       343 ms → 5.2 ms on its host). **The doc-scoping correction rides
       it, and it is the Mac-visible half:** *"Blocks BETWEEN the edges
       are irrelevant"* is true for the phone's contiguous run and
       **false for the Mac's ⌘-click arbitrary pick**, where `[b0,b2]`
       returned `b0` — *a block being deleted* — while `b1` survived and
       was the natural landing. The doc is now scoped to contiguous
       runs **and the rule picks the nearest surviving index**, which
       changes the answer the Mac's own multi-select door gets.
    3. **The Mac's residual arming sites are in `MarkdownActs`, not
       where the crash trace said.** The trace's §9 named the batched
       multi-range gate as a Mac exposure; the round CORRECTED that
       (§17, adopted): `EditorSurfaceDelegate.shouldChangeTextInRanges:`
       (`EditorView.swift:561–574`) **refuses `count != 1` outright**,
       so it never arms a verdict for N ranges. **The Mac's real
       residual is the arm-then-hand-off sites in
       `Features/Formatting/MarkdownActs.swift`** — `apply`,
       `toggleCheckbox`, `insertNewlineContinuingLists` and
       `deleteWithoutNewline` each arm and then immediately
       `replaceCharacters`: **1:1 today, and one refactor away from not
       being.** Nothing was changed there, deliberately; it is recorded
       here so the reviewer reads the residual the round actually
       found rather than the one it first wrote down.
  - `Shared/EditorBrain/EditorEditRouting.swift` — **NEW.** `ArmedEdit`
    (the gate's verdict bound to the range, document length and
    replacement length it was computed for) and `EditorAssertionSeam`.
  - `Variorum/Features/Editor/EditorViewModel.swift` — consumes
    `ArmedEdit`; routes a refused mutation to `desyncRecovery()`;
    structural disarms; `bulkPending` cleared beside each arming clear.
  - `Variorum/Features/Editor/EditorSurfaceController.swift` — its two
    whole-block-delete functions became one-line delegates to the
    hoisted versions. **IT DID GROW, exactly as predicted:** the round's
    M22 hoisted `planCrossBlockEdit` / `runCrossBlockEdit` (the ratified
    2026-07-09 merge-then-edit) into `Shared/` the same way, and those
    two Mac functions are now delegates too (commit `2ebb605`). The Mac
    suite rode unmodified across both hoists.
  - `VariorumTests/` — new suites `EditRoutingTests`,
    `EditRoutingCrashTests`; additions to `BlockRangeIndexTests`.

  - **BATCH 4's MAC-SIDE CHANGES — the deletion story's copy becomes
    shared** (commit `e7e2472`, 2026-08-22; added to this manifest
    2026-08-22, audit finding 6). The phone gained a Trash, so the
    argument each of these files already made in its own comment —
    *copy elsewhere promises the surface by name and would drift* —
    stopped stopping at the platform boundary:
    - **NEW: `Shared/RecoveryCopy.swift`** — the semantic half of the
      Mac's `RecoveryPath` and `TrayPath` vocabularies (`trashSection`,
      `archivedSection`, `putBackVerb`, `windowNote`, `kindLabel`,
      `rowKind`, `daysLeftLabel`, `archivedForever`, `goesWithItsFamily`,
      the three put-back receipts, `deleteNowConfirm`, the count-by-kind
      `emptyTrashConfirm`, and both purge receipts' three honest
      populations). **It also received two things that are not copy:**
      `PreservedOriginPutBack` (the `@MainActor` read-then-place
      composition, moved whole with its doc comment — the Mac's tray and
      the J3 peek still call it, and now so does the phone) and the
      `Queries.TrashItem.Kind → purge-table` mapping, which had been an
      extension in `RecoveryView.swift`.
    - **NEW: `Shared/StructuralUndoCopy.swift`** — the undo/redo door's
      outcome sentences (`undone`/`redone`, `nothingToUndo`/`Redo`,
      `undoCancelled`, `undoFailed`/`redoFailed`, the door titles, the
      destructive-undo QUESTION). The Mac's `discardingUndoDetail`
      deliberately did NOT move: its sentence names ⌘S, and a chord is
      a platform fact.
    - **`Variorum/Features/Library/RecoveryView.swift`**,
      **`Variorum/Features/Tray/TrayPanel.swift`**,
      **`Variorum/Registry/ShellActions.swift`** — the three now read
      from those shared homes. **What the reviewer should check
      deliberately:** that every moved string is byte-identical to what
      the Mac shipped (the round's proof is the Mac suite riding
      unmodified at **1568/272**, which proves no test noticed, not that
      no case exists — her own R20 reasoning), and that the
      chrome/semantic split each file's comment now claims is the split
      it actually made.
    - **No Mac test file was touched by this batch**, which is the same
      zero-test-edit parity proof the earlier hoists lean on.
  - **`Shared/EditorBrain/CrossBlockEditPlanner.swift` — NEW, and it
    carries a MAC PERFORMANCE FIX the reviewer should check
    deliberately.** The mobile round hoisted the Mac's ratified
    2026-07-09 merge-then-edit (`planCrossBlockEdit` /
    `runCrossBlockEdit`) into the shared brain so the phone could use
    it; the Mac's two functions are now delegates and the Mac suite rode
    unmodified. **In the process the hoist revealed that the planner
    called `index.range(ofEntryAt: i)` INSIDE its collection loop, and
    that accessor walks the tiling from zero on every call — an O(N²)
    walk on the MAIN ACTOR, on a keystroke road, with cost proportional
    to document length.** Measured at 20,000 entries: **23.8 s for one
    plan, and 23.3 s for a seam keystroke that plans nothing.** That is
    a **P1 violation** (`notes/OverallModel.md` §5), and it has been
    shipped MAC behaviour since 2026-07-09 — six weeks — unnoticed
    because the author's own documents never hit the shape. Fixed with
    one accumulation pass (`starts[i] = Σ(length+1)` is by definition
    what the accessor computes): **23.8 s → 0.003 s**, with equivalence
    pinned against `range(ofEntryAt:)` itself on an irregular tiling
    including empty entries. **This is the ONE deviation from
    byte-identical in the whole hoist**, it is Mac-visible, and it is
    the single thing in this manifest most worth an independent read.

  **What is worth her reviewer's attention in particular:** whether each
  hoisted rule still means on the Mac exactly what it meant when it was
  Mac-private (the mobile round's proof was "the Mac suite rides
  unmodified", which proves no test noticed, not that no case exists);
  whether the trap→refusal conversion left any Mac road that now
  proceeds silently where it used to stop; and whether the shared
  `EditorEditRouting` binding is correct for AppKit's edit reporting,
  which differs from UIKit's in ways the round MEASURED (iOS widens an
  insertion's reported range; AppKit does not).

- **THEN — the DEAD Delete Now door (her live report,
  2026-08-19 evening):** clicking Delete Now in the Trash produced
  NO confirmation and NO effect (the item still listed after
  leave-and-return — no intent minted, data safe). The confirm was
  ruled (13j round 10) and built with green seam-pins — this is
  the A1 pins-over-dead-wiring class ON the surface the
  screenshot drive couldn't capture.

  > ### ⛔️ DO NOT START FROM THE MECHANISM BELOW — RE-DERIVE IT ON macOS
  >
  > **The traced mechanism is probably WRONG** (Mobile Round 2, §46,
  > 2026-08-22). That round's batch 4 **reproduced the exact pattern the
  > trace blames — a `confirmationDialog` whose `isPresented` is a
  > computed `Binding(get:set:)` over an `@Observable` property — on
  > iOS 26.2, and IT PRESENTS**, because the dialog's **title argument**
  > reads `pendingConfirm` in `body`, which registers the observation
  > dependency the trace says is never registered.
  >
  > **What that does and does not change.** The RULE was still right to
  > follow (the phone uses `@Bindable` throughout and is immune either
  > way), and **the author's live report stands unshaken** — she pressed
  > Delete Now on her Mac and nothing happened, which is a fact about
  > her machine, not a theory. What is in doubt is the *cause*.
  >
  > **So 13l's first act on this door is to REPRODUCE IT RUNNING, on
  > macOS, and trace what is actually happening** — not to write a fix
  > against the reading below. The shape of the error is this round's own
  > lesson turned on prose: it warned five times that *a pin proving a
  > stored value proves nothing about what renders*, and then recorded a
  > **mechanism traced by reading and never executed** — the inventory
  > said "confirmed still present" from the code pattern, and **nobody
  > ran it.** The reading is kept below as a hypothesis to test first,
  > because it may still be right for AppKit's `confirmationDialog`,
  > which is not the same implementation as UIKit's.

  **MECHANISM TRACED — NOW A HYPOTHESIS, per the block above (the
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

> **⚠️ THE MAC AND MOBILE FIGURES ABOVE ARE HISTORY, NOT THE
> BASELINE.** They are 13j's finals, kept because that is what the
> closeout handed over. The current numbers — and the reason they
> moved — are in the section immediately below: **Mac 1568/272**,
> mobile **449/75** as of Mobile Round 2's batch 4. Core (1350/141)
> and the spine (63/8) are unchanged. The same warning is repeated in
> the kickoff message's "verify the baselines with your own runs",
> which is load-bearing here rather than routine.

### THE MAC CHANGES, FROM GIT RATHER THAN MEMORY (author-requested summary, 2026-08-22)

*She asked for this block to live where 13l sees it. It is the
plain-language index to the manifest below.*

**Ten files, 1,151 insertions. CORE IS UNTOUCHED — zero lines.**

**Three shared-brain files** (both apps compile these):
- `BlockRangeIndex.swift` — mutators refuse instead of trapping; the
  whole-block delete and caret landing hoisted IN from Mac code; the gap
  fence added
- `EditorEditRouting.swift` — new; the armed-verdict binding and the
  assertion seam
- `CrossBlockEditPlanner.swift` — new; merge-then-edit hoisted in, plus
  the O(N²) fix

**Two more shared files from batch 4:** `RecoveryCopy.swift` and
`StructuralUndoCopy.swift` — the deletion story's wording, hoisted out
of Mac-local code.

**Five Mac app files:**
- `EditorViewModel.swift` — consumes the armed verdict, routes to
  recovery
- `EditorSurfaceController.swift` — its functions became delegates to
  the hoisted versions (net **−181 lines**)
- `RecoveryView.swift`, `TrayPanel.swift`, `ShellActions.swift` — now
  forward to the hoisted copy

**BEHAVIOUR changes on the Mac, as opposed to relocations:** the crash
fix · the O(N²) fix · **the gap fence** · and the caret landing on
⌘-click multi-delete, which used to name a block being deleted.

**WHAT THE GAP FENCE ACTUALLY FENCES — stated precisely, because a
looser wording misled the author and would mislead a reviewer.** A
"gap" is `variantID == nil`: a block row that exists **with no text row
at all**. That state has exactly ONE origin — **a sync PULL applied a
block row before its variant row arrived** (SyncSpec §5's designed-for
"referenced-but-not-yet-arrived rows across batches; render gaps, never
crash"). It is **NOT** "a block that has not been pushed yet."
- **A locally created block is NEVER a gap**, online or offline:
  `mintBlock` (`Operations+Structural.swift:1069`) inserts the block,
  inserts the `Variant`, and sets `defaultVariantId` **in one write** —
  block and text are born together.
- **The fence never reads push state.** Its predicate is literally
  `entries[$0].variantID == nil`; it does not touch `sync_version`, the
  outbox, or anything upload-related. **Everything written offline stays
  fully deletable.**
The narrowing is therefore: *a span touching a paragraph whose text has
not yet arrived from another device refuses* — a half-received
paragraph, never an un-uploaded one. Its purpose is that nobody deletes
prose they have never been shown, and that the deletion does not
propagate back and take the other device's copy (tombstone-wins,
SyncSpec §6).

**⚠️ THIS MANIFEST IS LIVE, NOT FINAL — MORE MAC CHANGES ARE COMING
(author instruction, 2026-08-22).** The mobile round has not closed.
**Batch 4.5 will make further Mac changes**, at minimum the three-part
fix for the defect named below (a fence arm in `EditorViewModel`, a real
sentence for `.blocksNotAdjacent`, and making `CrossBlockRefusal.diagnose`
see zero-length entries), and its cold reviews may add more. **The
mobile orchestrator writes each one into this manifest AS IT HAPPENS**,
not at closeout — a manifest completed only at the end is how this one
went stale the first time. **If you are 13l's reviewer: check this
section's own git history for edits later than the round's closeout
commit before assuming it is complete.**

**⚠️ HEADS-UP BEFORE YOUR FIRST ACT — the Mac suite is INTERMITTENTLY
RED, and it is NOT this round's doing.**
`VariorumTests/EditorWindowSmokeTests.rewriteStrategyLatencies(paragraphs: 250)`
asserts the differential gesture stays under **50 ms at 50,000 words**,
and this machine clears it by only a few percent — so it **reds under
load and greens when quiet**. Measured on BOTH trees 2026-08-22
(`mobile-round-2.md` §54): the **PRE-ROUND tree `46ffa0c` failed 1 of 4
isolated runs at 51.95 ms**; the post-round tree passed 4 of 4. **It is
pre-existing, it is not a regression, and it now has a
`KnownIssuesAndTechDebt.md` row owned by Phase 12.** Recorded here so
your Fable reviewer does not spend its budget on a red neither this
round nor you caused. **If you meet it: re-run the suite isolated before
concluding anything.**

**TWO MAC RESIDUALS ADDED 2026-08-22 by Mobile Round 2's Act-2 sweep**
(`notes/plans/mobile-round-2.md` §53) — **written here as they were
found, per this section's own rule, not at closeout:**

1. **THE MAC HAS NO IDENTITY-PROJECTION AUDIT AT ALL** (§53 finding 1).
   The DEBUG per-keystroke oracle that catches the corruption class both
   other oracles are blind to — the totals agree while the content is
   wrong — exists **only on the phone**
   (`MobileEditorViewModel.swift:1898–1920`);
   `grep -rn "auditIdentityProjection\|identityAuditFailures" App/Variorum/Variorum`
   returns **zero hits**. This matters to your review specifically:
   round §18's MAJOR 1 was a **silent prose overwrite**, and §20
   **reproduced it Mac-side** (`stored → ["Alpha", "Beta beta", "G"]`).
   The Mac has a **pin** for that traced case and **no runtime oracle
   for the class**. **Batch 4.5c is hoisting the audit into
   `Shared/EditorBrain/` and wiring the Mac to it, with a Mac-side
   red-on-old** — so by the time you read this it may be done; **check
   the tree, not this sentence.**
2. **A SECOND EXPRESSION OF THE CARET RULE SURVIVES, Mac-private**
   (§53 finding 11). `EditorSurfaceController.swift:930` keeps the
   single-index `caretLandingAfterRemoving(_ i: Int)` with three Mac
   callers (`:770, :782, :1608`), beside the hoisted set-based
   `BlockRangeIndex.caretLandingAfterRemoving(_ blockIDs:)` at `:412`.
   Round §23 named this honestly at the time (*"the set-based rule and
   that one now express the same idea in two places, as they did
   before"*) and it never reached this manifest. **No divergence bug
   today** — for one departing block the neighbour is always a survivor,
   so the shipped correction does not change its answer — **but it is a
   duplicate of the very rule you were asked to check**, and you should
   meet it here rather than discover it.

**AND ONE MAC DEFECT THIS ROUND CREATED** (§44's MAJOR): the gap fence
makes the Mac **refuse**, but the Mac never got the fence's **FACE**, so
the span falls through into merge-then-edit and dies as a **raw error
dump**. Fix is in the mobile round's batch 4.5; if 13l's reviewer meets
it first, this is why.

---

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

**Mac-side files touched — REFRESHED 2026-08-22 through Mobile Round
2's batch 4** *(this list named batch 1's files only; the audit's
finding 6 caught it stale. The manifest in §8 above is the detailed
account — this is the file-level index)*:

| File | What changed | Batch |
|---|---|---|
| `Shared/EditorBrain/BlockRangeIndex.swift` | the four mutators refuse instead of trapping; **hoisted IN** `wholeBlockDeletion` + `caretLandingAfterRemoving`; the **gap fence**; the caret rule's O(N·M) fix + its doc scoping | 1, 1b |
| `Shared/EditorBrain/EditorEditRouting.swift` | **NEW** — `ArmedEdit` (the verdict bound to its range, document length and replacement length) + `EditorAssertionSeam` | 1 |
| `Shared/EditorBrain/CrossBlockEditPlanner.swift` | **NEW** — the hoisted merge-then-edit, **carrying the O(N²) → O(N) Mac performance fix** | 3 |
| `Shared/RecoveryCopy.swift` | **NEW** — the deletion story's semantic copy + `PreservedOriginPutBack` + the purge-table mapping | 4 |
| `Shared/StructuralUndoCopy.swift` | **NEW** — the undo/redo door's outcome sentences | 4 |
| `Variorum/Features/Editor/EditorViewModel.swift` | consumes `ArmedEdit`; routes a refused mutation to `desyncRecovery()`; structural disarms; `bulkPending` cleared beside each arming clear | 1 |
| `Variorum/Features/Editor/EditorSurfaceController.swift` | four functions became delegates to the hoisted brains (the two whole-block-delete ones, then `planCrossBlockEdit`/`runCrossBlockEdit`) | 1b, 3 |
| `Variorum/Features/Library/RecoveryView.swift` | reads its copy from `Shared/RecoveryCopy.swift`; the purge-table extension moved out | 4 |
| `Variorum/Features/Tray/TrayPanel.swift` | same, plus `PreservedOriginPutBack` moved out | 4 |
| `Variorum/Registry/ShellActions.swift` | speaks `Shared/StructuralUndoCopy.swift` | 4 |
| `VariorumTests/` | new suites `EditRoutingTests`, `EditRoutingCrashTests`; additions to `BlockRangeIndexTests`. **No Mac test file was touched by batches 1b, 3 or 4** — the zero-test-edit parity proof | 1 |

**Mac counts: 1546/269 (13j) → 1563/272 (batch 1) → 1568/272, where
they have stood EXACTLY since batch 1's ladder fixes** — through the
1b, 3 and 4 hoists, which is precisely the proof those hoists moved
addresses and not behaviour. **Verify with your own run** — the mobile
round is still live as this line is written, and its remaining batches
(5–8, the fix round, and two more review passes) may move it again. If
it has moved, something changed Mac behaviour and the reviewer should
know what.

**Where it lives:** branch `mobile` only. It reaches `main` at the
next `mobile` → `main` merge, which happens **at her word** (the
standing rule in `notes/plans/mobile-app-plan.md`). If you are reading
this on `main` and the files above do not carry the change, that merge
has not happened yet — pull it or coordinate before assuming a
baseline.

**~~No 13l scope is affected~~ — TRUE OF BATCH 1, NO LONGER TRUE OF THE
ROUND** (corrected 2026-08-22, audit finding 6). Nothing in the mobile
round touches **backups, restore or the purge machinery** — that half
stands. But **batch 4 changed the Mac's deletion and recovery
SURFACES**: `RecoveryView.swift` and `TrayPanel.swift` now read their
copy from `Shared/RecoveryCopy.swift`, and `PreservedOriginPutBack` —
the read-then-place composition behind the tray's originals section and
the J3 peek — moved into `Shared/` with them. Those are the very files
§8's opening mini-item works in. **Two consequences for this phase:**
its dead-Delete-Now fix lands in a `RecoveryView` whose copy now lives
somewhere else (rename in the shared home and both platforms move
together — which is the point), and the phone now has a Trash, so any
sentence 13l writes for the Mac's deletion doors should be checked
against the shared home rather than typed fresh. The count baseline is
no longer the only cost.

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
