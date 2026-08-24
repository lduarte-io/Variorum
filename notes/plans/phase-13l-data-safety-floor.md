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

## Kickoff message (paste-ready — REWRITTEN 2026-08-23)

*The original kickoff was written at the 13j closeout, before this
phase acquired three further strands and before its baselines moved.
This replaces it.*

> You are running **Variorum Phase 13l — the data-safety floor.** Confirm
> the cast at kickoff (never assume); **the Fable cold review below is
> HER ruling and is not a cast question.** The phase is largely
> autonomous by nature — a low-attention window fits it.
>
> **READ IN FULL FIRST:** `CLAUDE.md` and the canon it loads (AppSpec
> §14's 13j delta is the latest state) · **this plan, TOP TO BOTTOM** ·
> `notes/plans/phase-13l-data-safety-brief.md` (the scope's origin —
> items 1–6, the kickoff decisions, the recorded leans) ·
> `notes/plans/phase-13j-purge-memo.md` + its addenda (the purge design
> this phase's drill must PROVE) · the 13j plan's Environment-traps
> section (binding — the A1 rail, kills-by-PID-only, the real-store
> container path). Copy the P-1…P-9 constitution into this file verbatim
> if running under `/architect-phase`.
>
> ### THIS PHASE HAS FOUR STRANDS. THREE OF THEM ARRIVED AFTER IT WAS PLANNED.
>
> **1 · ITS OWN WORK — the data-safety floor, as planned.** The brief's
> six items (automated scheduled backups, second-destination-first per
> the recorded lean · the rehearsed restore drill + runbook · the
> bulk-`.md` plaintext insurance candidate · the sync-status face
> candidate · the passphrase/recovery-phrase sanity check · the ruled-in
> app-level lock with honest wording) **plus the 13j-born seventh, the
> DELETION-AWARE RESTORE MATRIX** (M1–M7 in Scope below — her round-13
> requirement: what a restore does to deleted things must be defined,
> ruled where taste-shaped, tested headless, and rehearsed live).
> **Her founding why, verbatim:** *"i feel like on some level i've still
> been a little afraid to fully trust in the app / sync / start REALLY
> using it and feeling secure that my data isn't being lost."*
>
> **2 · WORK THE DELETION PHASE SHOULD HAVE DELIVERED WORKING.**
> **13j built true delete and its doors do not work.** `Delete Now` and
> `Empty Trash` on the Mac are **UI-unreachable** — she pressed Delete
> Now and nothing happened, and that is a live report, not a theory. The
> clock and the janitor still purge, so no data is at risk, but **true
> delete cannot be reached from the Mac's interface at all.**
> **The mechanism is now DERIVED and waiting for you** (§ below, and
> mobile round 2 §56): the dialog presents fine — it dies at the
> confirm→act edge, because the `isPresented` setter nils the payload
> synchronously inside tap handling while the action only *enqueues* the
> work. **The fix is one line per site.** *This project recorded a
> different cause for weeks and it was wrong; do not start from the old
> one.* **And the mobile round fixed the same defect at four phone doors
> — read what it did before you write yours.**
>
> **3 · COLD REVIEWS SHE ASSIGNED TO THIS PHASE.** Her R20 ruling: **a
> FABLE cold reviewer over every Mac-side change Mobile Round 2 made**,
> running `notes/REVIEW_PROMPT.md` verbatim, cold, no framing. Her
> reason: those hoists were each proved by the Mac suite riding
> unmodified, **but no cold reviewer has ever read the Mac side of that
> work with Mac eyes.** The manifest is in this plan and is complete
> through the round's batch 4.5. **Folded in at her later instruction
> (2026-08-23): batch 4.5b (commit `7fd2cd0`) — the ONE piece of that
> work that reached `Shared/` and the Mac and was never reviewed at all,
> because its reviewer died on an API limit.** *"so it won't stay
> unreviewed."* **Four Mac-visible defects are already recorded, owned by
> 13u, and listed for you** — so your reviewer spends its budget on what
> nobody has looked at rather than re-deriving what is written down.
>
> **4 · MOBILE'S MAC AND `Shared/` BACKLOG — moved here 2026-08-23 by her
> ruling** (*"the mobile session shouldn't have mac / shared work to do
> when I return to it"*, under *"do the mac phases in order so that the
> shared brain is 100% solid and stable"*). **Four items, L-a…L-d**, all
> data-safety-shaped, which is why they came HERE rather than to 13u:
> **L-a** the Mac has no identity-projection audit (the oracle for
> *the totals agree while the content is wrong* — a corruption the mobile
> round REPRODUCED Mac-side) · **L-b** the Mac's `QuickEntryBar`
> **destroys her text on a refusal** · **L-c** `AppBootstrap` runs
> migrations on the main thread before first paint (P2, both platforms) ·
> **L-d** `AppSession`'s autosave map has no removal path. **13u takes
> the editor-seam five (its item 8).** **DEFER OUT LOUD, NEVER SILENTLY:**
> the mobile handoff carries a HANDBACK CHECKLIST with a yes/no command
> per item, so anything skipped lands back on the phone session that was
> told it would not have to do it.
>
> ### BASELINES — CURRENT, and the 13j figures are NOT
>
> core **1350/141** · Mac **1569/272** · Mac spine **63/8** · mobile
> **484/78** · mobile spine **33/7** · mirror at lockstep marker **7**.
> *(mobile moved 475/77 → 484/78 on 2026-08-23: E1's instrumentation added 9 tests. Mac, core and both spines are unchanged.)*
> **Verify with your own runs.** *(The 13j closeout's figures — Mac
> 1546/269, mobile 314/60 — are two rounds stale. The Mac +1 is mobile
> batch 4.5b's single pin; do not read it as drift.)* **AND the Mac suite
> is INTERMITTENTLY RED** at one latency pin, pre-existing and measured
> on both trees, with a KnownIssues row owned by Phase 12 — **re-run it
> isolated before concluding anything.**
>
> ### TWO THINGS THIS PHASE OWES AT ITS CLOSE
>
> - **AUTHOR 13u's EXECUTION PLAN** — she runs it immediately after this
>   one, and it is a **cross-platform phase** (see the closeout section).
> - **REFRESH `/Applications/Variorum.app`** — hers, explicitly; the
>   installed build predates the whole mobile round's Mac work.
>
> **OPEN WITH THE KICKOFF SITTING** (short — the decisions in Scope).
> **Nothing destructive-adjacent runs before the A1 rail**, and every
> restore-drill act happens in SCRATCH locations, never against her real
> store.

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

  **🔴 TWO OBLIGATIONS THIS PHASE INHERITED IN CONVERSATION, WRITTEN DOWN
  2026-08-23 BECAUSE THEY HAD REACHED NO RECORD.** *(The mobile round's
  own §50 lesson, applied to itself: an audit of the records cannot find
  an ask that never reached the records. Both of these were said in chat
  and nowhere else.)*

  **(A) THIS PHASE OWES THE `/Applications/Variorum.app` REFRESH — hers,
  explicitly.** Her words, 2026-08-23: *"I'll wait for 13l to reinstall
  my app."* **The installed build predates the whole of Mobile Round 2's
  Mac-side work**, which reached `main` on 2026-08-23 and includes: the
  **crash fix** (the `BlockRangeIndex` trap pair became refusals routed
  to `desyncRecovery()` — the Mac was proven *latent-not-prevented*, its
  twin pins red on the pre-fix tree), **a P1 fix worth 23.8 s → 0.003 s**
  on a cross-block keystroke at 20,000 entries, `Put back` **finally
  saying where it landed**, and the shared deletion/undo copy. **She is
  running none of that today.** CLAUDE.md's standing rule already says a
  session that changes the Mac app ends by refreshing it; the mobile
  round could not (it was mid-flight and her app was live), so **it lands
  here**: `xcodebuild -scheme Variorum -configuration Release build`, then
  copy to `/Applications` — **at a zero-instance window, never while her
  real-store app is running** (`pgrep -fl 'Variorum.app/Contents/MacOS'`).

  **(B) IF SHE OFFERS HER IPHONE DURING THIS PHASE, THERE IS A QUEUE
  WAITING FOR IT — and it lives in a file this phase has no reason to
  open.** `notes/plans/mobile-round-2-batch-4.5-briefs.md` **§4b** holds
  **nine device-only rows**, and the standing instruction (mobile round 2
  §50) is that when she makes her device available the queue runs in that
  window, **not just an install** — a previous offer was spent on two
  installs while items sat runnable. **The one that matters most: E1**,
  the instrumented experiment that is *"the only thing that settles where
  the crash's stale verdict comes from"* — **the root cause is still
  PROVEN as of 2026-08-23 — E1 fired on her device** *(see `mobile-round-2.md` §67; the "high confidence, NOT PROVEN" status this plan was written under is retired)*, and **13u item 5 is about to
  build a larger gesture in that exact seam.** *(E1's instrumentation is
  mobile's to build and has not been built, so a device window during
  this phase can run the other eight rows; E1 needs mobile's burst
  first.)*

  **🔴🔴 SCOPE ADDITION — author, 2026-08-23, AND IT IS BUILD WORK, NOT
  JUST REVIEW WORK.** Her correction, verbatim: *"I thought I asked for
  4.5c's mac work to be added to what 13l is supposed to accomplish? so
  the mobile session shouldn't have mac / shared work to do when I return
  to it."* Her principle, from the same day: *"do the mac phases in order
  so that the shared brain is 100% solid and stable… then return to
  mobile work on a steadier base."*

  **THE RULE THIS SETS: mobile round 2's remaining MAC and `Shared/` work
  moves to the MAC PHASES. When she returns to mobile, the phone session
  should have PHONE work only.** *(Her rider, same message: mobile may
  still FIND Mac/shared defects later, and those still get fixed — R8's
  shared-defect authorization is untouched. What moves is the KNOWN
  backlog, not the standing permission.)*

  **THE ARCHITECT'S SPLIT ACROSS THE TWO MAC PHASES — because she said
  "the mac phaseS, in order", and each item has a phase it actually fits.
  Flagged for her to overrule; the default if she does not is what is
  written here.**

  ### 13l TAKES (this phase — all four are data-safety by nature)

  | # | item | why it is THIS phase's |
  |---|---|---|
  | **L-a** | **The Mac has NO identity-projection audit at all.** The DEBUG per-keystroke oracle that catches *the totals agree while the content is wrong* exists only on the phone (`MobileEditorViewModel.swift:1898–1920`); `grep -rn "auditIdentityProjection\|identityAuditFailures" App/Variorum/Variorum` returns **ZERO**. Both platforms share `BlockRangeIndex` and took the same crash fix, **and the mobile round REPRODUCED that corruption Mac-side** — `stored → ["Alpha", "Beta beta", "G"]`, her paragraph written to the store as one character, through the ledger, with the totals agreeing so nothing downstream noticed. **HOIST it to `Shared/EditorBrain/` and wire the Mac; pin it red-on-old ON THE MAC** by reproducing that corruption there. **Carry the empty-entry hole** (the walk's `guard range.length > 0 else { continue }` skips an empty entry's separator, so an empty block's boundary is unaudited) | **It is a silent-prose-corruption detector.** This is the data-safety floor; a Mac with no oracle for the one class its other two oracles are blind to is exactly this phase's subject |
  | **L-b** | **The Mac's `QuickEntryBar` DESTROYS HER TEXT on a refusal.** `Variorum/Features/Shelf/QuickEntryBar.swift` `submit()` does `entryText = ""` **before** the mint, and its catch is a raw `"New note refused: \(error)"` dump — **in the bar she praised by name and uses daily.** `QuickNotePad.take()` clears before filing too (deliberate there, and its copy does speak). **The phone's just-shipped fix is the reference shape** (`MobileQuickNote.file()` resets only on a completed hand-off); route the copy through `OpsRefusalCopy.message(for:)` | **A live data-loss defect on her daily driver.** If "data-safety floor" means anything it means this |
  | **L-c** | **`AppBootstrap.init` opens the store and runs the migration set SYNCHRONOUSLY ON THE MAIN THREAD before first paint** — a **P2 violation** (OverallModel §5) on **both** platforms, on every launch. **MEASURED on the simulator:** 54.0 / 23.4 ms first launch, 5.0 ms reopen, **3.6 ms at the 100k fixture — flat in corpus size**, O(migrations) not O(corpus). **THE SHAPE IS ALREADY RULED** (mobile §58/§62): an `.opening` state; the file work detached, hopping back to MainActor for `install` + the state write (**preserving the once-per-process flag**); `retry()` re-entering; a quiet launch view in **both** app roots. **The not-ready window cannot open by construction** — `AppSession` exists only inside `.ready`, the property `MobileStoreFailureView` already relies on. **A REAL DEVICE NUMBER may exist by the time you read this** (device-walk row D8) — check `notes/plans/mobile-round-2-device-walk.md`'s results table | Launch-path integrity, and it is `Shared/` — both platforms, one fix |
  | **L-d** | **`Shared/AppSession.postAutosaves` has no removal path** (no `removeValue` anywhere), so the phone's quick note adds one coordinator **per capture** and `flushEveryOpenPost()` iterates all of them on every filing and every background flush. **Shape proposed:** `releaseAutosave(forPost:)` called from the box's `reset()`. **The trap, already traced:** the Mac registers a `quitFinalize` closure at *mint* time, so release-then-remint registers a second for the same post — deduped by `closeAutoCommit`, so noise rather than corruption, **but it must be deliberate.** **Plus three FALSE comments in that file** (`:89` "no undo UI yet" — shipped; `:240-245` inverted — the quick note DOES cache a coordinator; `:206-208` "open posts are a handful by construction" — false for this very reason) | `Shared/`, both platforms, and it is unbounded growth in a flush path |


  **⚠️ AND MOBILE WILL CHECK — so DEFER OUT LOUD, never silently.** These
  items did not originate here; **they were moved OUT of mobile round 2
  at her 2026-08-23 ruling**, on the stated understanding that *"the
  mobile session shouldn't have mac / shared work to do when I return to
  it."* The mobile successor handoff carries a **HANDBACK CHECKLIST**
  (§2b) with a yes/no command per item and the value each returns while
  the work is undone — **so a deferral here is not invisible; it lands
  back on the phone session that was told it would not have to do it.**
  **If this phase deliberately does not do one, RECORD THAT AND SAY WHY**
  (in the closeout and in the item's own row), so mobile inherits a
  decision rather than a discovery — and so she learns it from a record
  rather than from a surprise two phases later.

  ### 13u TAKES THE REST (recorded here so this phase does not build them)

  **The editor-seam items go to 13u**, because **13u item 5 rewrites that
  seam and item 7 already owns the Mac's `MarkdownActs` residual** —
  building them here would mean building refusal machinery 13u then
  changes: **the fan fence read from a frozen projection** (its
  *correctness* half — never authorize from stale state — is safe to do
  either place; the *policy* half is item 5's) · **the surviving O(N²)
  twin in `planVisibleTakeEdit`** · **the gap fence's missing Mac face**
  · **the empty-block-in-a-span dead plan** · **`CrossBlockRefusal`'s
  hoist and its wording**. **They are written into the 13u row of
  `notes/DetailedPlanForPhases.md` as item 8.**

  ### WHAT THIS DISSOLVES

  **The "second Mac manifest" problem is GONE.** The mobile handoff's
  §6b and its closeout obligation 13 existed because mobile's *later* Mac
  work would land after 13l's review closed, with no Mac-eyed reviewer.
  **With the Mac backlog moved to the Mac phases, mobile has no known Mac
  work left**, so there is nothing for a second manifest to carry.
  *(Obligation 13 is retained in reduced form only as a tripwire: if
  mobile DISCOVERS new Mac/shared work under R8, it still hands it
  forward.)*

  **🔴 SCOPE ADDITION — author, 2026-08-23. ONE PIECE OF THIS DIFF
  REACHED `Shared/` AND THE MAC WITHOUT EVER BEING COLD-REVIEWED, AND
  THIS REVIEW IS NOW ITS REVIEW.** Her instruction, verbatim: *"If 4.5b
  had code reach shared unreviewed, the fable session at the start of 13l
  should review it as part of its scope, so it won't stay unreviewed."*

  **What it is:** mobile round 2's **sub-batch 4.5b**, commit
  **`7fd2cd0`** — deliberately committed on its own so it is
  identifiable at a glance. Its cold review was dispatched and **died on
  an API limit before reading anything**, and the round merged before it
  could be re-run. **Everything else in the round's Mac-side diff has
  been through at least one ladder; this has not.**

  **The three files, and they are small:**
  - **`App/Variorum/Shared/RecoveryCopy.swift`** — the `TrashPutBack`
    hoist (a read-then-place decision now shared by both platforms) plus
    `DeletionRefusal`, one home for deletion refusal copy.
  - **`App/Variorum/Variorum/Features/Library/RecoveryView.swift`** —
    `RecoveryViewModel.putBack` adopts the hoist, **and now sets a
    receipt it had been discarding** (`_ = try ops.restoreBlock(…)`
    threw the landing away while the view renders a receipt right beside
    `lastError`, so the Mac never answered *"where did it go?"* while the
    phone did). Its generic catch was a raw error dump and now speaks.
  - **`App/Variorum/VariorumTests/TrashSurfaceTests.swift`** — one new
    pin, **the only Mac count move in the entire round** (1568 → 1569).

  **What to attack hardest, in order:**
  1. **Is the hoist an address change or a behaviour change?** The
     repo's parity proof is the other platform's suite riding
     **unmodified** — **but this round established that an unmoved Mac
     count proves only *"no COVERED behaviour changed"***, and it holds
     the counterexample (a hoist that added a real behavioural fence
     which no Mac test covered). **Read it, do not infer it from the
     count.**
  2. **The receipt change** — `putBack` now surfaces where a restored
     block landed. Is the wording true for all five `TrashItem.Kind`s,
     and does it promise nothing the Mac cannot deliver?
  3. **`DeletionRefusal` as one home** — does collapsing several refusal
     vocabularies lose a distinction one of them was carrying? (A sealed
     note refusing a *put back* and refusing a *delete* want different
     words; the type has an `Act` for that.)

  **What it is NOT your job to fix:** the *remaining* decision-layer
  hoist. `MobileTrashModel` is still a near-verbatim copy of
  `RecoveryViewModel` for `PurgeConfirm`, `requestDeleteNow`,
  `requestEmptyTrash`, `confirmPendingPurge`, `startTrash`/`startArchived`
  and `daysLeft`. **The mobile round hoisted the one decision that had
  already DRIFTED and reported the rest as half rather than claiming the
  layer** — deliberately, because finishing it refactors a Mac view model
  and **this phase opens on exactly that surface.** It is listed in the
  manifest below as yours to close **with your own eyes on it**, not as
  something to fix inside a review.

  *(The mobile round's successor handoff still carries its own note to
  re-review 4.5b when mobile resumes. That duplication is deliberate at
  her word — "honestly, it's for the best if we get more eyes on items."
  Two independent reads of the only unreviewed shared code is a feature,
  not a bookkeeping error.)*

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

  > *(STATUS NOTE, 2026-08-23 kickoff — read this block as HISTORY: the
  > re-derivation it demands HAPPENED. The settled mechanism is the
  > "🔴 YOUR FIRST ACT'S DIAGNOSIS IS SETTLED" section further down —
  > the confirm→act edge, §56's derivation — and the kickoff message
  > says not to start from the presentation hypothesis below. This
  > block survives as the record of why that hypothesis fell, and its
  > discipline still binds: the fixer builds the red-on-old pin
  > DRIVING THE REAL BUTTON first, because the settled derivation was
  > also produced by reading, not by execution on macOS.)*
  >
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

### 8d. HER EMPHASIS (2026-08-21): the recovery story must be intuitive from EVERY door

Her words, verbatim: the phase "has to ensure that the trash
recovery story is well built and intuitive as ux from all its
doors - lineage from one block, trash tray, recency of deletion
filtering, etc." The WHY, recorded so the mandate's weight is
understood: she has RULED cross-block select-and-delete open
(13u item 5 — the master plan row has the full sketch; her goal:
"not feel like a headache compared to using a different editor"),
and that liberalization LEANS ON the Trash being a robust,
legible safety net — deleting across blocks is only honest
because everything is one Put back away and findable. So this
phase's recovery-surface work is not polish; it is the
load-bearing half of a ruling that lands later. Walk every door
as a user: the per-note tray, the Trash with its recency
filtering, the lineage door from a successor block, the History
face rows — each must answer "where did my text go and how do I
get it back" without her having to explain it.

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

## The architectural rules (the 13b constitution, P-1…P-9 — copied verbatim per `/architect-phase`, 2026-08-23 kickoff; the skill file's application notes bind beside them)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

## Baselines at open (verify with your own runs)

> **⚠️ CORRECTED 2026-08-23 — THE 13j FINALS BELOW ARE NOT YOUR
> BASELINE.** Mobile Round 2 ran and merged between 13j's close and this
> phase's open. **USE THESE:** core **1350/141** · Mac **1569/272** ·
> Mac spine **63/8** · mobile **484/78** · mobile spine **33/7** ·
> marker **7**. **And "FULLY GREEN" is no longer true of the Mac suite:**
> one latency pin (`EditorWindowSmokeTests/rewriteStrategyLatencies`) is
> **intermittently red** at its own budget — pre-existing, measured on
> both trees, KnownIssues row owned by Phase 12. **Re-run it isolated
> before concluding anything.** The Mac's +1 over 1568 is mobile batch
> 4.5b's single new pin; the mobile figure moved twice (batch 4.5, then
> E1's instrumentation). *The 13j line below is kept as the historical
> origin, which is what CLAUDE.md's "the previous closeout is the
> baseline" rule points at — it is simply no longer the previous
> closeout.*

The 13j finals: core **1350/141** · Mac **1546/269 FULLY GREEN** ·
spine **63/8** · mobile **314/60**. Mirror at lockstep marker
**7**; the purge machinery live end-to-end (both devices cursored;
the janitor's first sweeps no-op until the horizon passes her
pre-13j tombstones — expected).

> **⚠️ THE MAC AND MOBILE FIGURES ABOVE ARE HISTORY, NOT THE
> BASELINE.** They are 13j's finals, kept because that is what the
> closeout handed over. The current numbers — and the reason they
> moved — are in the section immediately below: **Mac 1568/272**
> *(SUPERSEDED — the current figure is **1569/272**; see the correction
> at the counts paragraph below)*,
> mobile **484/78** *(corrected twice on 2026-08-23: 449/75 was batch 4's figure, batch 4.5 took it to 475/77, and E1's instrumentation added 9 more)*. Core (1350/141)
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

**🔴 YOUR FIRST ACT'S DIAGNOSIS IS SETTLED — READ THIS BEFORE THE DEAD
DELETE-NOW DOOR (derived 2026-08-22, Mobile Round 2 §56).**

**The Mac's Delete Now / Empty Trash doors are dead, and the recorded
cause was wrong.** This project recorded for weeks that they fail because
a `confirmationDialog`'s `isPresented` is a computed `Binding(get:set:)`
over an `@Observable` property that `body` never reads, so no observation
dependency registers. **§46 partially retracted that** (batch 4
reproduced the pattern and it *presented*) and concluded *"the cause needs
re-deriving on macOS."* **It has been re-derived, from the code, and it
is a different mechanism one step later:**

`RecoveryView.swift:299-309` and `:528-539`. The dialog **presents
fine** — `titleVisibility: .visible` plus `model.pendingConfirm?.message`
in the title argument *does* register the dependency. It dies at the
**confirm→act edge**: the binding's setter
(`set: { if !presented { model.cancelPendingPurge() } }`) **nils the
payload synchronously inside tap handling**, while the action closure only
*enqueues* `Task { await model.confirmPendingPurge() }` — which cannot
resume until that turn yields. By then `pendingConfirm` is `nil` and the
method's own `guard` returns. **Nothing is purged, no intent, no
receipt.** Apple's contract is explicit: *"When the user presses or taps
one of the alert's actions, the system sets this value to `false` and
dismisses."*

**Her live report is fully explained** — *"pressed Delete Now on my Mac,
nothing happened."*

**The fix is one line per site:** capture the payload synchronously inside
the action closure (`let confirm = model.pendingConfirm` before the
`Task`), or use `confirmationDialog(…, presenting:)` / `alert(_:isPresented:presenting:)`,
which captures the value into the closure. **Every other value-carrying
confirm in both codebases already uses `presenting:`.**

**Why no test caught it, and what your pin must do:** every existing pin
(including `VariorumTests/TrashPurgeDoorsTests.swift:79, 114, 157, 237`)
calls the confirm method **directly while the pending value is still
set**. Presentation is pinned end to end; **the confirm→act edge is the
only edge with no coverage.** A red-on-old here has to drive the live
`NSAlert` handler, not the model.

**And the lesson that matters more than the fix:** the mobile round
shipped **four more copies of this defect** while citing a rule — *never
a computed `Binding(get:set:)`* — that names a **SYNTAX** rather than the
property that matters. Its four phone sites obey that rule to the letter
and are dead anyway. Mobile batch 4.5b is fixing all four; **the Mac's
fifth is yours.**

---

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

**🔴 FOUR MAC-VISIBLE DEFECTS ARE RECORDED, ACCEPTED, AND NOT YET FIXED —
READ THIS BEFORE YOU START (added 2026-08-23; the full account is
`notes/plans/mobile-round-2.md` §65).** The mobile sub-batch that owns
all four (4.5c, "the editor & the shared brain") **never ran** — the
round's Opus budget ran out first. So this Mac code carries four
findings that are already traced and already owned. **They are listed
here so your review spends its budget on what nobody has looked at,
rather than re-deriving what is written down:**

1. **The merge-then-edit fan fence is read from a deliberately FROZEN
   projection** — a block that gained a take during a dirty window can be
   merged away by a keystroke, against the #11a ruling.
   `BlockRangeIndex.wholeBlockDeletion`'s own doc states the law forty
   lines away, and the sibling seam road obeys it.
2. **The O(N²) twin SURVIVES in `planVisibleTakeEdit`**, one `else if`
   after the one that was fixed, **on a road that runs** —
   `index.range(ofEntryAt:)` inside a collection loop. The fixed twin
   measured **23.8 s → 0.003 s at 20,000 entries**; this is a live P1
   violation on the Mac.
3. **The gap fence's REFUSAL reached the Mac; its FACE did not** — a span
   covering an interior gap block dies as a raw
   `blocksNotAdjacent(first:second:)` enum dump, because
   `EditorViewModel.operationMessage` has no case for it. **This one the
   mobile round CREATED Mac-side**, and it is the reason you may meet
   that dump.
4. **The Mac has no identity-projection audit at all** — the DEBUG oracle
   for the corruption class both other oracles are blind to (*the totals
   agree while the content is wrong*) exists only on the phone, though
   both platforms share the brain and the mobile round **reproduced that
   corruption Mac-side**.

**⚠️ OWNERSHIP CORRECTED 2026-08-23 — this block was written when all four
belonged to mobile's 4.5c, and her ruling has since moved them to the Mac
phases. They are no longer "recorded but unowned":**

| defect above | owner NOW |
|---|---|
| 1 · the frozen-projection fan fence | **13u item 8** |
| 2 · the surviving O(N²) twin | **13u item 8** *(and a `KnownIssuesAndTechDebt.md` row points at 13u)* |
| 3 · the gap fence's missing Mac face | **13u item 8** |
| **4 · the missing identity-projection audit** | **🔴 THIS PHASE — it is L-a above.** It came here rather than to 13u because it is a **silent-prose-corruption detector**, which is this phase's own subject |

**So three of the four are 13u's and your reviewer should not spend
budget on them — but the fourth is YOURS TO BUILD.** *(If you meet the
four listed as "not yet fixed" anywhere else, this table is the current
answer.)*

**AND ONE NON-DEFECT, for calibration:** the Mac suite is intermittently
red at `EditorWindowSmokeTests/rewriteStrategyLatencies(paragraphs: 250)`
— a latency budget this machine clears by a few percent. **Measured on
both trees: the PRE-ROUND tree failed 1 of 4 isolated runs; the
post-round tree passed 4 of 4.** Pre-existing, KnownIssues row owned by
Phase 12. **Re-run it isolated before concluding anything.**

**A THIRD MAC RESIDUAL + A MAC FIX, added 2026-08-22 from Mobile Round 2's
batch 4.5b (§63):**

3. **`RecoveryView.swift` (39 ±) — the Mac's Put back was landing
   SILENTLY, and now does not.** `RecoveryViewModel.putBack` did
   `_ = try ops.restoreBlock(…)`, discarding the landing, while the view
   renders a `receipt` right beside `lastError` — so the Mac never
   answered *"where did it go?"* while the phone did. It now adopts the
   hoisted `TrashPutBack` in `Shared/RecoveryCopy.swift` (both platforms,
   one decision) and sets the receipt; its generic catch was a **raw
   error dump** and now uses `DeletionRefusal.fallback`. `TrayRefusalCopy`
   voice unchanged. One new pin in `VariorumTests/TrashSurfaceTests.swift`
   (**Mac 1568/272 → 1569/272 — the only Mac count move this round, and
   it is this pin**).
4. **THE REMAINING DECISION-LAYER HOIST IS YOURS, and it was stopped
   deliberately at half.** `MobileTrashModel` is still a near-verbatim
   copy of `RecoveryViewModel` for `PurgeConfirm`, `requestDeleteNow`,
   `requestEmptyTrash`, `confirmPendingPurge` (identical including the
   synced/familySynced reads and `sweepLocalPurge`),
   `startTrash`/`startArchived` and `daysLeft`. **The mobile round hoisted
   the one decision that had already DRIFTED and reported the rest as
   half rather than claiming the layer** — because finishing it refactors
   a Mac view model **whose parity proof is weak** (the "Mac suite
   unmoved ⇒ nothing changed" claim is falsified — see the note below)
   **and because 13l opens on exactly this surface.** M-C forbids the
   fork standing; it is yours to close with your own eyes on it.

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

**Mac counts: 1546/269 (13j) → 1563/272 (batch 1) → 1568/272 → **1569/272
(CURRENT, and this is the number to expect from your own run)**.**
*(Corrected 2026-08-23. The +1 is batch 4.5b's single new pin in
`VariorumTests/TrashSurfaceTests.swift`, covering the `putBack` receipt
fix — **the only Mac count move in the entire round**, which is itself
the parity evidence. Do NOT read 1569 as "something changed
unexpectedly".)* **They had stood EXACTLY at 1568/272 since batch 1's
ladder fixes** — through the
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
Review shape: the author sets it at kickoff. The closeout writes the
MobileSoul parity line (~~the lock's Face ID twin +~~ any status-face
twin is the obvious candidate — *the lock moved to 13p 2026-08-24,
whose own Batch 4 builds the Face ID twin inside the phase*) and runs
the full closeout ritual.

### 🔴 AND THIS CLOSEOUT AUTHORS **13u**'s EXECUTION PLAN — her pick is already made

Her 2026-08-23 ruling: **`13l → 13u → mobile catch-up → 13p`**, and
*"my highest priority should be 13l -> 13u"* — **she runs them back to
back**, so this closeout authors 13u's plan and its kickoff message per
the standing ritual. **13u is not an ordinary 13 row and the plan must
say so:**

- **IT IS A CROSS-PLATFORM PHASE — MobileSoul §6's "design together"
  class, and its ledger row PL-12 is ALREADY WRITTEN** (at design time,
  as §6 requires). **At least seven of its THIRTEEN items are inherently
  both-platform** *(the row grew 8 → 13 on 2026-08-23 — items 9–13:
  quick-capture ownership incl. shift-⏎ · starred scroll · paste
  without newlines · multi-block drag · the title cut-off; the
  `### 13u` master-plan section is authoritative, and 9/11/12 are
  cross-platform calls too)*: the eager space-eater (**she reported it on BOTH
  apps**) · the derived display-name snippet (*"ONE brain… serving the
  Mac library, MOBILE'S LISTS, and capture alike"*) · cross-block edits
  (*"the semantics are ruled HERE, once, for BOTH platforms"*) · dark
  mode (**the PHONE's shipped dark mode is her named look reference** —
  a Mac face catching up to a mobile one). **So mobile is IN its design
  sitting, and the phase names mobile's deliverable INSIDE itself
  rather than leaving parity rows behind.**
- **IT INHERITS MOBILE'S EDITOR-SEAM BACKLOG as its item 8** — the
  frozen-projection fan fence · **the surviving O(N²) violation in
  `planVisibleTakeEdit`** (a live P1 breach on a keystroke road, whose
  sibling measured 23.8 s → 0.003 s) · the gap fence's missing Mac face
  · the empty-block dead plan · `CrossBlockRefusal`'s hoist. **Plus item
  7**, the Mac's `MarkdownActs` arming residual — **the MAC half of
  mobile's M1 root question** (the iOS half is E1 and needs her device).
  **Two of these have KnownIssues rows pointing at 13u**, so if 13u
  closes without them those rows are orphaned.
- **ITS ITEM 5 SETTLES SEMANTICS MOBILE IS WAITING ON** — her
  cross-block ruling (edits stop refusing; the edge-join merges
  mid-paragraph and not at a paragraph break; **the fanned case is
  OPEN**), and her own coordination flag says *the mobile session should
  know the direction before hardening any refusal.*
- **DARK MODE MOVED HERE FROM 13s** at her word, and its acceptance
  clause moved with it.
- **After 13u, mobile must have NO known Mac or `Shared/` work left** —
  that is the stated point of the two-phase order, and the mobile
  handoff's §2b will check it item by item.

---

## RUN RECORD

### Kickoff (2026-08-23) — the opening sitting, author-attended

Orchestrator: **Fable under `/architect-phase`**, at her invocation.
Mandatory reading done IN FULL before anything else: CLAUDE.md + the
canon it loads (AppSpec §14's 13j delta current) · this plan TOP TO
BOTTOM · the 13l brief · the purge memo + both addenda ·
the 13j plan's Environment-traps section (binding by reference) ·
`notes/REVIEW_PROMPT.md` · the mobile round-2 orchestrator handoff
BOTH halves (the §2b handback checklist, §4 the 4.5b review scope,
§5 the coordination flag, §5b M1's split) · the device-walk results.
Constitution copied in verbatim (section above). QUESTIONS.md next
free number: **#74**.

**Cast (her kickoff message, to be confirmed at the sitting):**
architect/orchestrator **Fable** · implementers **Opus for the most
part** · cold reviewers **Fable**. The first-act Fable cold review is
HER RULING (R20 + the 2026-08-23 4.5b fold-in), not a cast question.
Reviewer-Fable over implementer-Opus batches ⇒ CLAUDE.md's
cross-model review flow governs those ladders.

**Environment facts at kickoff:** NO Variorum instance live (`pgrep`
empty — re-check before any Release/install act, never assume it
stays true). Working tree clean at `609ae38`, `main` in sync with
`origin/main` (0 ahead).

**State verification (own commands, not inherited):**

- `46ffa0c` (the mobile round's pre-round tree) **IS an ancestor of
  `main`** — the merge through batch 4.5 landed as recorded. The
  first-act reviewer's diff scope is
  `git diff 46ffa0c..HEAD -- App/Variorum/Shared App/Variorum/Variorum
  App/Variorum/VariorumTests`: **14 files, 1,899 insertions / 321
  deletions.** One correction to the manifest's tally: it says "three
  `VariorumTests/` files"; there are FOUR — `TrashSurfaceTests.swift`
  joined at 4.5b (`7fd2cd0`), carrying the round's single Mac count
  move. Not drift; recorded so the reviewer isn't surprised.
- **Handback checklist greps (mobile handoff §2b) all read their
  "not done" values**, as expected at open: L-a `0` · L-b `1` (and
  `entryText = ""` present) · L-c `0` · L-d `0` · U-3 `0` (13u's,
  listed for calibration only).
- `7fd2cd0` confirmed in history, its own commit message marking the
  cold review owed.
- The Fragments bridge engine lives in `Sources/VariorumCore/Bridge/`
  — its own module, NOT `Sync/`, so scope item 9 is not hard-bound to
  Fable by the standing Sync/ rider (cast for it is the sitting's).
- **The device-window queue (obligation B in §8) is DISCHARGED**: the
  walk ran 2026-08-23 on her phone, all nine rows — E1 POSITIVE (M1's
  root PROVEN), D8's launch "almost imperceptible" (L-c stays
  worth-doing, not urgent — the shape is ruled, the urgency demoted).
- Suite baselines: to verify by own runs at the first batch boundary
  (expectations: core 1350/141 · Mac 1569/272 · spine 63/8; the
  latency pin's isolation rule noted — intermittent red is Phase 12's
  row, re-run isolated before concluding anything).

**Mid-kickoff concurrency, recorded:** three commits from another
session landed on `origin/main` during the kickoff (`ddf04e8`
corrected this plan's stale baselines + the identity-audit
double-ownership; `00bb376` traced her Fragments-bridge-on-the-phone
question, §68; `f0eb9c5` created **13v** — the journal bridge on the
phone — at her word). Merged cleanly (`02d1c45`); 13v changed the
shape of scope item 9's sizing question, offered below.

**Five kickoff flags raised at the sitting** (her ask: "if anything
seems off or contradictory, please tell me"): (1) the concurrent
commits above — resolved by merge; (2) **13u's "EIGHT items" wording
is stale in three places** (the master-plan row, the running order's
row 5, this plan's closeout section) — the `### 13u` section now
carries THIRTEEN items; housekeeping fix executed this sitting, and
the 13u plan will be authored from the full section; (3) the
dead-door mechanism has two generations in this plan (the ⛔️
re-derive block and the §56 SETTLED derivation) — consistent read in
order, but the settled one was also derived by reading, so the fixer
builds the red-on-old pin DRIVING THE REAL BUTTON first, confirms
red, then fixes; (4) the manifest's "three `VariorumTests/` files"
is four (`TrashSurfaceTests.swift`, 4.5b); (5) the device-window
queue (item B) is already discharged — the walk ran all nine rows
2026-08-23. None contested.

### The kickoff sitting's rulings (2026-08-23, question-tool batches 1–2 — verbatim-faithful)

1. **Backup second destination: a USER-PICKED LOCAL FOLDER.** Her
   words: *"people should pick a local folder - they can always pick
   a folder that's in icloud drive (like desktop is for me)."* No
   dedicated cloud machinery — the folder picker is the door, and an
   iCloud-synced folder gets off-site coverage for free. Retention at
   the second destination: the proposed default stood unobjected —
   daily copy, keep **14 dailies + 4 weeklies** (≈6 weeks; M6's
   both-directions framing rode the question) — hers to adjust in
   use.
2. **Both candidates IN**: the bulk-`.md` plaintext insurance
   (automated, to the backup destination; the runbook names the
   plaintext-in-cloud trade where the picked folder is cloud-synced)
   AND the sync-status face.
3. **Freshness evidence: the small face + log** — a Data Safety
   section in Settings (last backup time + destination + last
   integrity result + last `.md` export + sync status), "Back Up
   Now…" as adjunct never load-bearing, the full log behind it.
4. **App lock: the fallback story is a USER SETTING — not
   biometric-only.** *(⚠️ SUPERSEDED 2026-08-24 — the lock MOVED to
   13p and the system-password fallback was RETIRED with the move;
   see the post-sitting record below. The verbatim record here stands
   as history and as the input knot 9 carried to 13p's sitting.)*
   Her words: *"can we just make this a user
   setting? I just don't think we should only have biometric - but
   in the long run, we might add two factor auth or other options
   like that to login. it's true that on the disk it's still open,
   but for most non technical people they'd never look at the disk
   but might know the computer password."* Build shape: Touch ID
   leads; a setting chooses the allowed fallback(s) — system
   password and/or the encryption passphrase (when enrolled) —
   **defaulting to both allowed** (the architect's default under her
   setting ruling; hers to flip). **The honest-wording mandate,
   sharpened in her words:** *"I do think that the app settings
   should make it clear what level of protection this is - it's
   against casual snooping, not full encryption of everything on the
   disk. maybe we even name it anti snoop or something like that."*
   (The name is FLOATED, not ruled — copy drafts honest; the naming
   candidate goes to the checkpoint and 13s's voice pass.)
   - **Her curiosity question, recorded NOT built**, verbatim: *"as
     a question (not building it now), what's the lift on encrypting
     everything on disk and decrypting it when the app is opened, so
     it's unencrypted while the app is in use? i'm curious what the
     natural extension would lead to - though then it would be
     another level to the forgotten passphrase risk and we certainly
     aren't implementing it right now."* Answered at the sitting
     (the natural extension IS 13p's subject) and routed VERBATIM
     into `notes/plans/note-protection-design-note.md` with the
     honest lift assessment, so 13p's design sitting inherits it.
5. **M5: ACCEPT-AND-SAY-IT.** Restore is time travel on a local-only
   install; the restore flow's one honest sentence ships ("things
   deleted after this backup's date will return — including
   permanently deleted ones"), M3/M6's wording as presented (final
   copy at build, same meaning; M6 carries BOTH directions plus the
   external-snapshots widening from 8b).
6. **Item 9: THIS PHASE, at DELETE time.** (Routing to the new 13v
   was offered and declined; purge-time offered and declined.) A
   bridged day no longer live pushes its deletion once; Put back
   self-heals. `Bridge/` module — the Sync/ rider is not triggered.
7. **Review shape: ONE end-of-phase Fable ladder over the phase's
   combined diff** (the 13k precedent). The first-act review is
   separate and settled (hers).
8. **Standing, no re-ask:** multi-select delete scope = Library note
   rows first (shelf books at her word — the plan's own ruling); the
   pre-13j amnesty stays DECLINED; **M4's rehearsal road = the
   fake-server harness** (the architect's proportionality pick,
   flagged and unopposed — a scratch Supabase account is
   disproportionate; the live half of the drill proves local restore
   mechanics in scratch locations).
9. **Cast confirmed** (her kickoff message): implementers **Opus for
   the most part** · cold reviewers **Fable** · orchestrator
   **Fable**. Reviewer-Fable over implementer-Opus ⇒ CLAUDE.md's
   cross-model review flow governs disputes; anything firming toward
   `Sources/VariorumCore/Sync/` STOPS per the binding constraints
   regardless of cast.

### Post-sitting confirmations (her next message, same sitting)

- **The housekeeping fixes are blessed** (*"yeah, you can go ahead and
  fix the things that seem off"*) — the 13u counts were already fixed;
  this message adds the status note on the old dead-door hypothesis
  block (marked HISTORY, the settled derivation pointed at).
- **The M4 rehearsal-road pick is CONFIRMED hers** (*"it's fine to
  change m4"*) — the deletion-aware matrix's synced-restore scenario
  rehearses on the fake-server road, not a scratch Supabase account.
- **M5 explained at her ask** (*"what's the deal with m5? I don't know
  what that is exactly"*) — the plain-language explanation given in
  the same reply; her accept-and-say-it ruling STANDS unless she
  revises on the explanation (the ruling was made through the
  question tool's short description, so the door was left open
  explicitly).
- **M5 CONFIRMED INFORMED after the explanation** (her words:
  *"accept it and say it is fine"*).
- **NEW RULING — the SYNCED-restore warning, M2/M4's user-facing
  twin** (her words: *"I also think we need to warn the user that if
  they deleted something, it will auto re-delete from their backup …
  we need to tell the user it clearly either way"*): the restore
  flow warns BOTH populations, not only M5's local-only one. The
  synced sentence carries the machinery's real nuance: ordinary
  deletions re-apply INTO THE TRASH (M2 — the re-pulled tombstone;
  recoverable for the window's remainder), while permanently deleted
  things STAY permanently deleted (M4 — the ledger). Rides ledger
  items 13–15 (runbook + restore face + the matrix's sentences).
- **RULED — the REGRET ROAD: "Runbook recipe now, door later"** (her
  question, verbatim: *"do we need some kind of road where it doesn't
  [re-delete]? or does it make sense to offer that? what if the
  entire issue is that they permanently deleted something and wish
  they hadn't? I'm conflicted on what 'backup' should mean here. we
  need to tell the user it clearly either way."* — answered with the
  three-nets framing: the Trash is the protection against deletion
  regret, backups are protection against LOSS, purge is the
  deliberate exit; and the **recovery-as-copy doctrine** — any road
  back from a backup mints FRESH identity, never resurrects ids, so
  "really deleted" holds to the sync system in every option). Her
  pick, the recommendation: **this phase ships the warnings (both
  populations) + a runbook recipe** — open a backup in a scratch
  copy of the app (the drill's own mechanism), read, copy out as
  new — and **a friendly in-app door ("browse a backup, copy
  something out as a new note") is recorded as a FUTURE-ROW
  CANDIDATE at her word**, not built here. The candidate is carried
  to the closeout/handoff for her slotting (natural homes: a Phase 12
  assessment item or its own small row; the copy-out-as-new doctrine
  above is its one-paragraph design memo).
- **HER CLARITY MANDATE on deletion semantics (next message, same
  sitting — verbatim):** *"I feel like we need to be extremely clear
  with users about : permanently deleted things stay permanently
  deleted if you restore from a backup where they weren't deleted,
  BUT they aren't deleted from the backup. the phrasing feels a bit
  awkward but that's what's happening and I think clarity on what
  exactly deletion means is paramount."* → The warning copy carries
  the BOTH-SIDED truth as its own clause, and the runbook gains a
  **"What deletion means"** section (ledger 13). **Draft copy
  (final at build, meaning fixed):** *"Permanent deletion removes
  writing from your library and your synced devices — not from
  backup files. If you restore a backup made before a permanent
  delete, the deleted writing does not come back into your library;
  but it is still inside that backup file, and stays there until
  the backup is rotated away or you delete the file."* The purge
  definition given to her the same turn (the timeline, the horizon,
  the content-free ledger as what makes the promise survive
  restores, the on-disk-until-the-janitor honesty, and the
  outside-the-system boundary: backups/Time Machine/exports) is the
  runbook section's outline.
- **RULED 2026-08-24 — THE APP LOCK MOVES TO 13p, and the
  system-password fallback is RETIRED.** Her words: *"honestly, maybe
  the lock should just be moved into 13p's plan. it was always an add
  on to 13l"* → the architect's assessment agreed (13p's R13p-5
  at-open modes ARE the lock made real — building it here would be
  building what 13p immediately rebuilds; moving it means the interim
  "adds no encryption" caveat never ships and the mobile Face ID twin
  lands inside 13p's own Batch 4) → her ruling: *"I agree, and we
  don't need system password allowed anymore - we have a better story
  and a more cohesive approach now."* **Consequences:** ledger item
  19 → MOVED to 13p (the deferral rule satisfied — 13p's plan IS the
  authored design, R13p-5/R13p-7); **the 2026-08-23 sitting ruling #4
  (fallback as a user setting, both fallbacks allowed by default) is
  SUPERSEDED — the system login password is OUT of the gate's chain
  entirely** (R13p-5's rule stands as THE story: biometric, passphrase
  fallback, never the device password); knot 9 in the 13p plan
  largely dissolves (one gate, subsumption — annotated there). **The
  passphrase/recovery sanity check STAYS in 13l** (her same message)
  — it is independent of the lock and the forget-risk is live today.
  Her 13p planning agent reviews the change and tweaks as needed
  (her stated next step).
- **CAST INCIDENT + CORRECTION (2026-08-24): Act 2's seat 1 ran as
  FABLE after its resume — against the ruled Opus-implementer cast.**
  Mechanism: the Act 2 implementer was SPAWNED with the explicit Opus
  override, died mid-run on a 529, and was RESUMED by message — and
  the resume continued it on the ORCHESTRATOR'S inherited model
  (Fable), silently dropping the spawn-time override. Confirmed by
  the author's own observation of the running agent (*"the model says
  that it is currently Fable"*); her ruling re-affirmed: *"in the
  future, the implementers should be Opus."* Correction: the seat was
  ordered to WRAP AT THE NEAREST CLEAN SEAM (finish only the
  in-progress item to a coherent committed state, honest partial
  record, no new items); a FRESH explicit-Opus session takes the
  remainder of Act 2 from that record. **The standing lesson, for
  every future seat: a resumed background agent does NOT reliably
  keep its model override — after any resume of a model-critical
  seat, re-verify the model; when in doubt, wrap and re-dispatch
  fresh with the model named.** (Also mirrored to session memory.)
  **⚠️ FALSIFIED 2026-08-24, hours later, by transcript evidence —
  read this half, not the half above.** When SEAT 2 (spawned
  explicitly Opus) ALSO showed as Fable in her view, the serving
  models were extracted from all four agents' own transcripts
  (`grep '"model"'` on the task output files — the authoritative
  per-turn record): the reviewer 90/90 turns `claude-fable-5`; the
  fix round 144/144 `claude-opus-5`; **seat 1 — the "incident"
  agent — 247/247 real turns `claude-opus-5`, INCLUDING every
  post-resume turn**; seat 2 65/65 `claude-opus-5`. **The resume
  never dropped the override; the cast was never violated; zero
  Fable was ever spent on implementation.** The observation was a
  DISPLAY ARTIFACT: the terminal's agent view shows the PARENT
  session's model (this Fable orchestrator) — proven by her
  `/context` sent "to the agent" rendering in the orchestrator's
  own output. **The real lessons, replacing the false one:** (1) a
  terminal's agent-frame model label is NOT evidence — the
  transcript's per-turn `"model"` field is, and it costs one grep;
  (2) the machinery rule the record above violated is §5's own —
  *a mechanism that explains the symptom is not one that was
  tested* — and the orchestrator was the culprit this time,
  writing an untested mechanism into a binding record. Seat 1's
  stop was therefore unnecessary (modest cost: one wrap record +
  one redispatch; no work lost). The memory note is rewritten to
  the true lesson.
- **The suite-simulator question (her ask: why iPhone 16e, not 17):**
  answered — an iPhone 17 Pro sim EXISTS locally (iOS 26.2); 16e is
  the repo's standing convention since mobile v1, and every measured
  perf/geometry pin baseline was taken on it. Architect's
  recommendation given: stay on 16e mid-phase; switch the fleet to
  iPhone 17 Pro (matching her hardware) as a deliberate one-commit
  re-baselining act at a clean boundary — 13u's kickoff offered —
  at her word. Her ruling pending; no change made.

### ACT 1 — THE FIRST-ACT FABLE COLD REVIEW: FINDINGS (returned 2026-08-23; recorded repo-first before any fix session)

**Reviewer:** fresh Fable session, `REVIEW_PROMPT.md` verbatim, zero
framing, over `git diff 46ffa0c..HEAD -- App/Variorum/Shared
App/Variorum/Variorum App/Variorum/VariorumTests` (14 files) with 4.5b
(`7fd2cd0`) explicitly in scope. **Verdict shape: 1 MAJOR · 2 MINOR ·
2 NIT + a substantial clean bill** (all three plan foci answered; 53
tests across the five touched/new suites green on HEAD; the
calibration table honored — the four already-owned defects confirmed
present exactly as recorded, zero budget re-derived; the intermittent
latency pin not run, nothing concluded from it).

**A1-MAJOR-1 · `App/Variorum/Shared/RecoveryCopy.swift:295` (with
`:223`, `:280-302`) — the hoisted Trash put-back DISCARDS
`restoreVariant`'s returned status, so an archived take's put-back
issues a receipt that misdirects her** ("Take put back." while the
take revives into the ARCHIVED listing, not the fan). Traced end to
end: `TrashPutBack.run` writes `case .take: _ = try
ops.restoreVariant(item.id)` and falls to the generic
`putBackReceipt(.take)`; `restoreVariant`'s own contract
(`Operations+Deletion.swift:94-99`) says a take archived-when-deleted
comes back archived and "a receipt that assumed 'the fan' was lying
for that row. The door reads the op's own answer instead of assuming
one." The Mac's sibling door obeys it (`BlockPastModel.putBackTake`
reads the status and speaks `BlockPastCopy.restored(status)`, incl.
the archived edition). Reachable from the Trash: `deleteVariant`
accepts an archived, unlocked, non-chosen take (no I10 refusal); the
Trash query lists deleted variants with NO status filter
(`Queries/Trash.swift:185-215`); put-back revives it `.archived`. Two
doors onto one act answer "where did it go?" two different ways — the
M-C drift class 4.5b's hoist exists to kill, re-shipped on the new
door (13j ladder A's A3 fixed this class once on the tray already).
Pre-4.5b the Mac showed NO receipt here — the misdirecting
affirmative sentence is new, i.e. squarely the never-reviewed code.
**Fix:** `case .take:` returns a status-aware receipt — read `try
ops.restoreVariant(item.id)`, add an archived-edition receipt pair to
`RecoveryCopy` (the `BlockPastCopy.restored` shape); both platforms
inherit through the shared road. **Red-on-old pin:** archive a take,
delete it, `RecoveryViewModel.putBack` from the REAL Trash rows,
assert the receipt names the archived landing — fails on today's
code. → **DISPOSITION: FIX NOW (the Act-1 fix round).**

**A1-MINOR-1 · `Shared/EditorBrain/BlockRangeIndex.swift:355` (gap
fence), `:412` (caret landing) vs `VariorumTests/WholeBlockDeleteTests.swift`
— the two Mac-visible behavior changes in the shared brain are pinned
ONLY in the mobile suite.** The gap fence (a recorded narrowing of the
Mac's shipped J9 gesture) has no Mac-side pin (no `variantID == nil`
fixture); the nearest-surviving caret-landing correction changes the
answer of a MAC-ONLY door (⌘-click non-contiguous multi-delete,
`EditorSurfaceController.swift:839`) while its `[b0, b2] → b1` pin
lives in `MobileWholeBlockDeleteTests.swift`; the O(N²)-fix
equivalence pin is likewise mobile-only. A Mac-suite-only regression
run stays green over a regression in either. **Fix:** two cheap Mac
pins (a gap-run `planWholeBlockDeletion` returns nil; the
non-contiguous landing through the Mac door or brain). →
**DISPOSITION: FIX NOW (the Act-1 fix round) — the architect's call
over the offered fold-into-13u:** the gap fence's REFUSAL is
tombstone-wins correctness (not 13u's refusal-policy territory), the
caret landing is pure mechanics, and both pins make a Mac-only
regression run honest. These are COVERAGE pins over existing correct
behavior — green on HEAD by design, no red-on-old owed (the
parity-pin class), and they must not touch 13u's semantics.

**A1-MINOR-2 · `Variorum/Features/Library/RecoveryView.swift:212,
229, 295, 366` — 4.5b taught exactly ONE of this surface's five
generic catches to speak; the other four still dump raw errors**
(`lastError = String(describing: error)`) — the two observation
starters, `requestEmptyTrash`, and `confirmPendingPurge`: the PURGE
half, the most consequence-laden acts on the surface. →
**DISPOSITION: ROUTED to ledger item 4** (the decision-layer hoist —
its scope now EXPLICITLY includes routing these four through
`DeletionRefusal.fallback`), per the reviewer's own framing.

**A1-NIT-1 · `Shared/RecoveryCopy.swift:334-355` —
`DeletionRefusal.words` covers the "already gone" family but not the
"already back" family** (`variantNotDeleted` / the other
`*NotDeleted` refusals — the ordinary double-click-Put-back race,
foreseeable, falls to the technical-name fallback). Mac exposure
limited today (`putBack` routes `OperationError` through
`TrayRefusalCopy`). → **DISPOSITION: ROUTED to ledger item 4** (add
the family to the shared home when the layer is hoisted).

**A1-NIT-2 · `Shared/RecoveryCopy.swift` (file shape) — a
`…Copy.swift` file now carries two `@MainActor` act compositions +
the purge-table mapping beside the sentences.** Defensible at this
size, acknowledged in its header. → **DISPOSITION: ROUTED to ledger
item 4** — when that item grows the decision layer, the compositions
split into their own shared file so "Copy" stays copy.

**Clean bill highlights (the full list is the reviewer's report;
load-bearing for later acts):** the batch-4 copy hoist is
byte-identical string-for-string and `CrossBlockEditPlanner`
reproduces the old Mac planner condition-for-condition with only the
recorded O(N²)→O(N) deviation · the trap→refusal conversion leaves NO
silent road (all four mutator sites guard the Bool → `desyncRecovery()`)
· `ArmedEdit.describes` is correct for AppKit's exact reporting incl.
Replace All · structural disarm coverage complete · `apply`'s
failure story rolls back via `UndoStack.withCompound` · the gap
fence's predicate is exactly `variantID == nil` (never push state,
never fan count) · zero `Sources/` lines in the round's whole diff ·
the task-local assertion seam is parallel-safe · 4.5b's receipt pin
is a real end-to-end pin.

### ACT 1 FIX ROUND — the brief (fresh Opus session; self-contained with the findings above)

**Scope: EXACTLY A1-MAJOR-1 + A1-MINOR-1. Nothing else** — the other
three findings are routed to ledger item 4 and are NOT this round's.

1. **A1-MAJOR-1:** re-trace the mechanism yourself (read
   `TrashPutBack.run`, `restoreVariant`'s contract, and
   `BlockPastModel.putBackTake` — the shape to follow). Build the
   red-on-old pin FIRST and confirm it fails on the pre-fix code
   (behavioral revert verification), then fix: the take case reads
   the op's returned status and speaks a status-aware receipt; the
   archived edition joins `RecoveryCopy` beside the existing
   receipts (both platforms inherit through the shared road — check
   the phone's Trash face renders the new sentence sensibly; a
   mobile twin pin is welcome if natural).
2. **A1-MINOR-1:** two Mac-side coverage pins, green on HEAD by
   design (the parity-pin class, no red-on-old owed): (a) a gap-run
   (`variantID == nil` fixture) `planWholeBlockDeletion` returns
   nil, in the Mac suite; (b) the non-contiguous `[b0, b2] → b1`
   nearest-surviving caret landing through the Mac door or the brain
   from the Mac suite. Do NOT touch refusal wording or widen/narrow
   any case — 13u owns that seam's semantics.

**Discipline:** the 13j Environment traps bind by reference
(`notes/plans/phase-13j-deletion-and-trash.md`, "Environment traps") —
Mac tests via the `-project` invocation, suite-level `-only-testing`,
never address a live Variorum instance, no custom build config, no
push (the orchestrator pushes). `Shared/` is touched ⇒ run core + Mac
full + Mac spine + mobile full; quote every count. Expected starting
counts: core 1350/141 · Mac 1569/272 · spine 63/8 · mobile 484/78;
the one intermittently-red Mac latency pin
(`EditorWindowSmokeTests/rewriteStrategyLatencies`) is Phase 12's —
re-run isolated before concluding anything. Record your result as a
short report; the round-2 re-review (fresh Fable) follows per the
ladder.

### ACT 1 FIX ROUND — RECORD (fresh Opus implementer session, 2026-08-23)

**Scope held exactly: A1-MAJOR-1 + A1-MINOR-1.** A1-MINOR-2 and both NITs
untouched (they are ledger item 4's). Zero `Sources/` lines, zero
`Sync/` lines, zero schema. Five files, all under `App/Variorum/`.

**A1-MAJOR-1 — TRACE CONFIRMED, in my own reading of the four sites.**
The finding holds exactly as written, and every step of its
reachability claim is now pinned rather than argued:

1. **An archived take can be DELETED.** `deleteVariant`'s I10 guard is
   `ensureNotLastActive`, whose first line is `guard variant.status ==
   .active else { return }` — an archived take is never "the last
   active" one, so the guard returns early. Unlocked and non-chosen, it
   tombstones.
2. **The Trash LISTS it.** `Queries.trash`'s take arm
   (`Queries/Trash.swift`) filters on `v.deleted_at IS NOT NULL`, the
   cutoff, a live block, and no purge intent — **there is no `status`
   predicate anywhere in it.** So the row is a `.take` row on the
   surface like any other.
3. **`restoreVariant` returns it ARCHIVED.** The op is the ruled exact
   flip (#68(b)) and `@discardableResult ... -> VariantStatus`; its own
   doc says a receipt that assumed "the fan" *"was lying for that row"*.
4. **The door threw that answer away.** `TrashPutBack.run` wrote
   `case .take: _ = try ops.restoreVariant(item.id)` and fell through to
   `RecoveryCopy.putBackReceipt(item.kind)` → **"Take put back."** — an
   affirmative sentence pointing her at the fan for something that
   landed in the archived listing.

The shape is the SAME discard the 4.5b hoist fixed one line up for
`restoreBlock`'s landing: the hoist corrected the block half and left
the take half beside it. Two other Mac doors onto this same act already
read the op's answer — `BlockPastModel.putBackTake` →
`BlockPastCopy.restored(status)`, and the lens board's
`LensFallbackCopy.restoredDeletedButArchived` — both corrected at 13j
ladder A's A3, which makes this door the odd one out rather than a new
question.

**THE FIX (`App/Variorum/Shared/RecoveryCopy.swift`):** the road now
carries **every** op's own answer out of the write, and the words are
chosen after it. `TrashPutBack.Outcome` (`.block(landing)` /
`.take(status)` / `.plain`) replaces the `BlockRestoreLanding?` the
closure used to return — deliberately an enum and not a second optional,
because a kind that answers something must now be forced to declare it
rather than falling silently through to the generic sentence, which is
how BOTH halves of this drift happened. Copy: `RecoveryCopy
.takeRestoredReceipt(_ status:)` + `takeRestoredArchived`. **The ACTIVE
road is byte-unchanged** — it still returns `putBackReceipt(.take)`; the
fix reads the answer, it does not reword the common case. Both platforms
inherit through the shared road (the decision lives in `Shared/`).

**RED-ON-OLD EVIDENCE — observed on BOTH platforms, not argued.** The
copy was added FIRST as inert text (no road read it), so the pins
compiled against the un-fixed decision and failed BEHAVIORALLY:

- `VariorumTests/TrashSurfaceTests.putBackOfAnArchivedTakeFromTheTrashDoesNotClaimTheFan`
  — pre-fix: `Expectation failed: (model.receipt → "Take put back.") ==
  (RecoveryCopy.takeRestoredArchived → "Take put back — it was archived
  when it was deleted, …")`, plus the `!=` guard failing on the same
  value. Post-fix green.
- `VariorumMobileTests/MobileTrashTests.puttingBackAnArchivedTakeSaysItCameBackArchived`
  — verified by an explicit behavioral revert of the take case (restore
  `_ = try ops.restoreVariant(…); return .plain`, run, restore the fix):
  pre-fix `Expectation failed: (trash.receipt → "Take put back.")`.
  Post-fix green. **One fix, two surfaces — which is the hoist's whole
  claim, now pinned rather than asserted.**

Both pins also assert the store side (`status == .archived` after the
put-back: the exact flip stands, nothing was quietly un-archived) and
the Mac pin carries the ACTIVE control in the same test.

**The phone's face renders the new sentence sensibly** (checked as the
brief asked): `MobileTrashView.reportLine` is `Text(tokens
.chromeLabel(receipt))` at `tokens.small` in a leading `VStack` with
`frame(maxWidth: .infinity)` — **no `lineLimit`, no `fixedSize`** — so
the longer sentence wraps in the growing bottom report line rather than
truncating. `RecoveryView`'s Mac receipt is the same shape
(`Text(receipt).font(.caption)`, no limit). P-8's rule is not engaged:
neither is a `fixedSize` chrome text.

**A1-MINOR-1 — two Mac coverage pins, green on HEAD by design** (the
parity-pin class; no red-on-old owed, none claimed). **Neither touches
refusal wording, and neither widens or narrows a case — 13u owns that
seam's semantics.** Both assert the SHIPPED rule:

- `VariorumTests/WholeBlockDeleteTests.aRunContainingANotYetArrivedBlockHasNoPlanOnTheMacToo`
  — the gap fence, with a Mac-side `indexWithGap` fixture mirroring the
  phone's. It pins that the geometry IS a whole-block run (`0...2`) so
  the FENCE is what declines, that `wholeBlockDeletion` returns nil and
  `wholeBlockRunAwaitsSync` is true, that the arrived blocks still
  delete, that a non-run reports no gap, and — the guard against the
  fence quietly growing — that a LOCKED take still plans (#33(a)). The
  predicate is `variantID == nil` and nothing else.
- `VariorumTests/BlockManagementTests` (suite `WriteBlockSelectionTests`)
  `aNonContiguousPickLandsTheCaretOnTheBlockThatSurvivedBetweenThem` —
  through the MAC DOOR (⌘-click pick `[b0, b2]` → `deleteSelectedBlocks`
  → `caretBlockID == b1`), beside the two contiguous cases already
  pinned there. Those two agree under either reading, which is exactly
  why a Mac-only run could not see this one; ⌘-click is the only
  non-contiguous picker in either app.

**FILES TOUCHED (5):** `App/Variorum/Shared/RecoveryCopy.swift` ·
`App/Variorum/VariorumTests/TrashSurfaceTests.swift` (+ `import GRDB`
for the store-side assert) · `App/Variorum/VariorumTests/WholeBlockDeleteTests.swift`
· `App/Variorum/VariorumTests/BlockManagementTests.swift` ·
`App/Variorum/VariorumMobileTests/MobileTrashTests.swift`.

**SUITE COUNTS AT CLOSE (all four gates, `Shared/` was touched):**
core **1350/141 green** (the baseline exactly — no core lines changed) ·
Mac **1572/272 GREEN** (1569 + the 3 new Mac pins; suite count unchanged
— the pins joined existing suites) · Mac spine **63/8 green** (run
separately by TYPE name) · mobile **485/78 passed** (484 + the twin; the
2 recorded issues are the suite's own `withKnownIssue`, and the run
passed).

**ONE INTERMITTENT RED, EXPLAINED AND NOT MINE — and it is NOT the
known latency pin.** The FIRST full Mac run failed
`CanvasDragTrackingTests.aCardFollowsThePointerOneToOneInsteadOfHalfOfIt`
(4 issues: the mid-drag offset read `(80, 40)` instead of `(100, 50)`,
and no `canvas_layout` row was written). Handled per the traps'
"explain any red": re-run **isolated → green (2/2 tests)**; full Mac
suite **re-run → 1572/272 fully green**, the failure not reproducing.
The diff cannot reach it (nothing here touches canvas, drag, or layout
persistence); it is a gesture-timing-sensitive pin in the recorded flake
family (`PoolDragTests`' physical-⌥ read, the Phase-12-owned
`rewriteStrategyLatencies`). **The known latency pin was GREEN in both
full runs** — it never appeared in a failure list, so nothing is
concluded from it either way. Recorded here rather than filed:
whether it earns a `KnownIssues` row (owner 12, beside the latency-pin
calibration row it resembles) is the orchestrator's call, not this
scope-fenced fix round's.

### ACT 1 ROUND 2 (fresh Fable, 2026-08-23) — CLEAN; THE ACT-1 LADDER IS CLOSED

**Zero findings at any severity.** The round-2 reviewer independently
re-traced A1-MAJOR-1's mechanism at all four sites, verified the fix
correct and complete (the `Outcome` enum carries every op's answer
out of the write transaction; the ACTIVE road byte-identical — same
string, same op call, same transaction shape), confirmed BOTH
platforms genuinely inherit (a repo-wide sweep found NO remaining
`restoreVariant` call site discarding the status — the door set is
now uniform with the two 13j-corrected siblings), verified the
receipt is actionable on the phone (an archived-takes listing + an
unarchive door exist), hand-verified both Mac coverage pins'
geometry/algorithms (the gap-fence pin's brain-level target verified
equivalent to the brief's named method — both Mac consumers are
one-line delegates; the caret pin exceeds the brief, pinning brain
AND the real ⌘-click door), and ran the suites itself: touched Mac
suites 42/3 green, **the full Mac suite "1572 tests in 272 suites
passed"** (latency pin and `CanvasDragTrackingTests` both green in
that run), mobile `MobileTrashTests` passed with the suite's 2
recorded known issues exactly as stated. Two honesty observations
deliberately not filed (no traceable degradation): an unused
`Equatable` on `Outcome`; the unreachable-by-construction
`.preservedOriginal` arm (pre-existing shape, commented).
**Verdict: no round 3. Ladder closed at round 2.**

### ACT 2 — THE TRASH-SURFACE MINI-ROUND: the brief (fresh Opus session; dispatches only after the Act-1 ladder closes — same files)

**Scope: ledger items 2–6 + the grown item 4.** Read this brief, the
findings/dispositions above (A1-MINOR-2, A1-NIT-1, A1-NIT-2 are YOURS
via item 4), §8/§8b/§8c of this plan (her rulings — the letter), and
the 13j Environment traps by reference. The registry discipline (P-1)
and the tutorial spine (63/8 green) bind; `Shared/` is touched ⇒ all
four gates run, counts quoted.

1. **Item 2 — the dead Delete Now / Empty Trash doors.** The settled
   mechanism is this plan's "🔴 YOUR FIRST ACT'S DIAGNOSIS IS
   SETTLED" section (the confirm→act edge: the `isPresented` setter
   nils `pendingConfirm` synchronously inside tap handling; the
   action closure only enqueues, and resumes after the nil; sites
   `RecoveryView.swift:299-309`/`:528-539` as of the derivation —
   re-locate). **Discipline: build the pin FIRST, driving the REAL
   dialog action — never the view-model seam** (every existing pin
   in `TrashPurgeDoorsTests` calls the confirm method while the
   value is still set; the confirm→act edge is the only uncovered
   edge) — confirm it fails on today's code, THEN fix. Preferred fix
   shape: `confirmationDialog(…, presenting:)` — "every other
   value-carrying confirm in both codebases already uses
   `presenting:`". **Read mobile 4.5b's four-door fix first**
   (commit `7fd2cd0`: the `presenting:` moves, the A12 seam fix, and
   its honestly-named one-step `tapAlertAction` driver).
2. **Item 3 — the note-deletion door set** (her rulings, §8, the
   letter): "Delete Note…" in the note ▾ menu WITH confirmation —
   ordinary move-to-Trash ONLY (the round-3 rider: Delete Now never
   appears in note context); the receipt names the Trash and its
   clock; navigate-away covers EVERY pane/window showing the note
   (the 13f workspace choreography — the Library door shares it).
   The Library door gains the SAME confirmation, one wording, both
   doors. ⌘-click multi-select in the Library + delete-all-selected:
   ONE confirmation naming the count ("Delete 5 notes?"), ONE
   receipt; scope = Library note rows FIRST (shelf books at her
   word — do not build them). All three doors registry-declared
   (P-1); the walk asserts them. **Write down the
   confirmation-consistency principle** (§8's last bullet: notes
   confirm; blocks/takes do not; Delete Now/Empty Trash always
   confirm) as a doc comment at the registry's deletion acts, so
   future doors inherit it.
3. **Item 4 — the remaining decision-layer hoist, WITH its grown
   scope.** Hoist the near-verbatim `RecoveryViewModel` ↔
   `MobileTrashModel` decision layer (`PurgeConfirm`,
   `requestDeleteNow`, `requestEmptyTrash`, `confirmPendingPurge`
   incl. the synced/familySynced reads and `sweepLocalPurge`,
   `startTrash`/`startArchived`, `daysLeft`) into `Shared/` — one
   decision layer, both platforms' pins riding unmodified where the
   move is pure (the 3C zero-test-edit parity proof). PLUS:
   A1-MINOR-2 (the four raw-error catches route through
   `DeletionRefusal.fallback`) · A1-NIT-1 (the `*NotDeleted`
   "already back" family joins `DeletionRefusal`) · A1-NIT-2 (the
   act compositions split OUT of `RecoveryCopy.swift` into their own
   shared file — this hoist is exactly "when the layer grows").
   Sequence item 2's fix BEFORE or WITH the hoist so the door fix
   and the hoist don't fight over the same lines; your call, stated
   in the record.
4. **Item 5 — the pool/scraps honesty check** (§8b): verify a
   deleted POOL reads honestly in the Trash (kind naming, cascade of
   its scraps, Put back) — the check is that its FACE never calls a
   pool a note. Fix with a pin if wrong; record clean if right.
5. **Item 6 — remove the left-margin comment ＋** (§8c, her words in
   the section): the 13e batch-6 margin-hover ADD-door's ＋
   affordance goes; the margin-hover comment DISPLAY and the other
   add doors are untouched. Removal only, no redesign (the fuller
   comments rework is 13u's).

**Out of scope, explicitly:** 13u's editor seam (refusal wording,
`planVisibleTakeEdit`, the gap-fence face) · shelf-book multi-select ·
anything in `Sources/VariorumCore/Sync/` · schema. Commit per
convention (schema-free), append your batch record to this plan, never
push. Expected starting counts: core 1350/141 · Mac 1572/272 · spine
63/8 · mobile 485/78; the known flakes (the Phase-12 latency pin;
`CanvasDragTrackingTests` once) — isolate before concluding.

### ACT 2 — PARTIAL RECORD (seat 1) — Opus implementer, 2026-08-23/24

**Why this record is partial, and it is NOT a scope judgment.** Two
interruptions, neither about the work:

1. **A transient server error (529 Overloaded) killed the session
   mid-item-2**, between edits — it left the tree in a
   *described-but-not-applied* state (the fix's doc comment written, the
   behaviour still shipped-broken). The orchestrator caught it, the tree
   was verified BY EYE on resume rather than from memory, and that state
   turned out to be exactly the red-on-old baseline item 2 needed.
2. **A CAST CORRECTION stopped the seat**: the author's cast for this
   phase is Opus implementers, and the post-529 resume continued on the
   wrong model. A fresh Opus session takes the remainder **from this
   record**. The stop was taken at the nearest clean seam — item 3 had
   made **zero edits** and stops as genuinely NOT STARTED, not as a
   half-applied change.

**Everything below is committed. The working tree is CLEAN, no probe or
scratch files remain.** Four commits, in order: `b527b72` (item 2) ·
`b0d35fa` (items 5 + 6) · `68cd28c` (item 4). *(`e2e6c6c`, `7d3a230`,
`b862a5c` and `e5c6ceb` interleaved from the concurrent 13p planning
session and are not this act's.)*

---

#### Item 2 — the dead Delete Now / Empty Trash doors · **DONE** (`b527b72`)

**The settled diagnosis was RIGHT, and it was re-derived RUNNING rather
than accepted from the page.** Three temporary probes (deleted before
the commit; what they proved lives in the code's doc) measured on macOS
26:

- SwiftUI's `confirmationDialog` presents a real `_NSAlertPanel` sheet
  with real `NSButton`s, reachable in process — **including from inside
  a `List` row**, which is where `RecoveryView` applies it. **The
  presentation hypothesis this project carried for weeks is dead**: a
  computed `Binding(get:set:)` over an `@Observable` is immune here
  because the title argument reads `pendingConfirm` during `body`.
- `performClick(nil)` runs SwiftUI's action closure **and** SwiftUI's own
  dismissal write-back in ONE turn — a faithful real press.
- The action's `Task` resumes only after that turn yields. That is the
  defect: `cancelPendingPurge()` had nilled the payload, and
  `confirmPendingPurge()`'s `guard` returned. **No intent, no receipt,
  the row still listed** — and both doors ride one host, so true delete
  was unreachable from the UI entirely.

**THE MAC PIN NEEDS NO SIMULATED STEP** — unlike the phone's
`tapAlertAction(_:writeBack:)`, which must supply the write-back by
hand, AppKit performs it. New suite
**`VariorumTests/TrashConfirmEdgeTests`** (3 pins), mounting the
SHIPPING modifier inside a `List` row:
`pressingDeleteForGoodInTheRealDialogActuallyPurges` ·
`pressingDeleteForGoodEmptiesTheWholeTrash` ·
`pressingCancelInTheRealDialogWritesNothing`.

**RED-ON-OLD, verified TWICE by behavioural revert — the second time
against the FINAL pin** (the first draft lacked the bounded settle
loop, so it was re-verified after that changed): both purge presses fail
on the shipped shape (`receipt → nil`, `intents → 0`, the row still
listed) while **`presented` stays TRUE** — proving the presentation half
was never broken — and **Cancel passes on both sides**, which is the
guard against a hollow finding.

**The fix:** `View.purgeConfirmDialog(_:)` — the host extracted to a
modifier so the RULE has somewhere to be written down and so the pin can
drive the shipping wiring (the surface builds its own `@State` model,
unreachable from a test). It rides `presenting:`;
`confirmPendingPurge(_:)` takes the confirm as a parameter. The rule as
written names **the property that matters, not a syntax**: *a binding
setter must never clear state that an action's continuation will read
back.*

**Files:** `Variorum/Features/Library/RecoveryView.swift` ·
`VariorumTests/TrashPurgeDoorsTests.swift`. **One recorded test edit:**
the four existing pins now pass the confirm they had been leaving on the
model — a no-arg road would have preserved the very read-back the defect
lived in.

#### Item 3 — the note-deletion door set · **NOT STARTED**

**Zero edits. Read-only reconnaissance only**, and its findings are
written here so the successor does not repeat them:

- **The Library's delete door is `LibraryCatalogView.postRowMenu`'s
  `Button("Delete", role: .destructive)`** → `library.delete(postID:)`
  → `ops.deleteContainer`. No confirm, no receipt.
- **The Pool's note rows carry the SAME door**
  (`PoolPostsView.swift:239`), and both — plus the sidebar's Open strip —
  render ONE grammar declared at
  **`SidebarView.contextMenuCapabilities`**. So "one wording, both
  doors" naturally reaches three renderers through one declaration.
- **⌘-CLICK MULTI-SELECT ALREADY EXISTS**: `listBody` is
  `List(selection: $selectedPosts)` and the note rows are `.tag(hit.id)`
  — the bulk TAG menu already uses it (`selectedPosts.count > 1`). The
  multi-delete needs the act and its confirm, **not** a selection
  mechanism.
- **The note ▾ menu is `CommitBar.noteMenu` AND
  `TakesBottomBar`'s twin** — both bars declare `.showNoteTray`, so
  `.deleteNote` wants both for R118 parity.
- **The phone already owns the wording** —
  `MobileEditorViewModel.deleteNoteTitle` / `.deleteNoteConfirmTitle` /
  `.deleteNoteConfirmDetail` (`RecoveryCopy.moveToTrashDetail(.note)`)
  and `RecoveryCopy.movedToTrashReceipt(.note)`. `RecoveryCopy`'s own
  comment already says these were *"born shared because the phone built
  the doors first and the Mac's 13l work will want the same words"*.
  **The Mac cannot import a `VariorumMobile` file**, so the two title
  constants need hoisting into `Shared/RecoveryCopy.swift` with the
  phone forwarding (MobileSoul §3: a Mac phase touching a brain hoists
  it then). The plural forms (count-naming confirm + one receipt) are
  new copy.
- **Registry shape considered, not built:** `.deleteNote` (scope
  `.post`, doors `[.bottomBar, .contextMenu]`, availability
  `noteScoped` — the row doors carry their own target, the standing
  `.toggleStar` split); `.deleteSelectedNotes` (scope `.app`, door
  `[.surface]`) **needs a new `CapabilityContext` field** (a
  `selectedNoteCount`, the `openNoteCount`/`canOpenBeside` family) **and
  a matching sampled context in `CapabilityRegistryTests`**, or
  `noActIsUnavailableInEveryContext` cannot see it act.
- **`MobileEditorViewModel.deleteNoteRefusal` is the FOURTH private
  refusal table** A1-18 named, still falling to a raw
  `String(describing:)`. Out of item 4's named scope (a mobile file);
  **deferred out loud** — it is a two-line forward to
  `DeletionRefusal.words` whenever a session is legitimately in that
  file.

#### Item 4 — the decision-layer hoist (+ its grown scope) · **DONE** (`68cd28c`)

**New `App/Variorum/Shared/RecoveryActs.swift`.** What is shared is the
DECISION, not the state or the voice — `@MainActor` statics over
`AppSession`, the shape `TrashPutBack` established:

- **`TrashPurge`** — `Confirm` (ONE type now; each model keeps a
  `typealias PurgeConfirm` so both suites ride unmodified — the 3C
  pattern; the phone's copy had grown `title`/`confirmVerb` the Mac's
  had not) · `deleteNowConfirm(for:)` (the originals-ride-their-family
  belt, round 8b) · `emptyTrashConfirm(session:)` (the unwindowed
  ask-time read; `nil` = nothing to purge) · `confirm(session:_:)` (the
  act: the three receipt populations read BEFORE the intent lands, the
  intent write, then the local sweep).
- **`TrashListing.windowed(_:window:)`** — the +1 probe rule both
  listings ran privately, and whose bug (forgetting to DROP the probe
  row) is silent.
- **A1-NIT-2:** `TrashPutBack`, `PreservedOriginPutBack`,
  `RecoveryRefusal` and `DeletionRefusal` moved OUT of
  `RecoveryCopy.swift` — its disposition said *"when that item grows the
  decision layer"*, and this was that item. The Copy file is sentences
  again.
- **A1-MINOR-2:** the four raw `String(describing:)` catches (both
  observation starters, `requestEmptyTrash`, `confirmPendingPurge`) now
  route through `DeletionRefusal`.
- **A1-NIT-1:** the "already BACK" family
  (`containerNotDeleted`/`readingNotDeleted`/`blockNotDeleted`/`variantNotDeleted`,
  plus `purgeTargetNotDeleted`) joins `DeletionRefusal.words` — the
  ordinary double-press race.

**Pins:** new suite **`VariorumTests/TrashPurgeSharedLayerTests`** (4):
`bothSurfacesConfirmTypeIsTheSharedOne` ·
`theWindowDropsItsProbeRowAndSaysSo` ·
`theAlreadyBackFamilySpeaksInsteadOfNamingItsEnumCase` ·
`theSurfacesErrorSlotNeverCarriesARawDump`.
**RED-ON-OLD** for A1-NIT-1 verified by behavioural revert: *"That
couldn't be done — containerNotDeleted(id: "x")."* The other three are
coverage/parity pins, green on HEAD by design and stated as such. **The
hoist's parity proof:** no mobile test file was touched and both targets
build — the honest half of that claim ("no COVERED behaviour changed")
is why the pins assert the rules where they now live.

**`daysLeft` deliberately NOT hoisted** and it is not an omission: both
models' bodies are already a one-line forward to the shared
`TrashWindow.daysLeft`, so a hoist would add a layer and remove nothing.

#### Item 5 — the pool/scraps honesty check · **DONE, AND IT WAS NOT CLEAN** (`b0d35fa`)

**What the check found:**

- **A deleted POOL CONTAINER is unreachable, so it cannot be
  mis-named** — `Queries.trash`'s note arm is fenced to `kind = 'post'`,
  and **no door in either app deletes a pool** (`deleteContainer`'s only
  Mac caller is `LibraryViewModel.delete(postID:)`, reached from the
  Library's and the Pool's rows, both of which list `kind='post'` hits —
  the surface named "Pool" holds BOOKLESS NOTES, R29). Now a pin rather
  than an assumption.
- **A deleted SCRAP is reachable, and the face called its pool a note
  three ways** — all three fixed: the row named the home through
  `DisplayTitle.note`, so a nameless pool read **"Untitled"** where
  every other surface shows its created day (13k K2, *her own ruling*);
  the row's door said **"Open note"**; and it routed `.post`, opening a
  pool as a note pane. `putBackHelp`'s *"in its note"* went with them.

**Pins:** new suite **`VariorumTests/TrashPoolHonestyTests`** (2) —
`aDeletedScrapNamesItsScrapsAreaAndOpensThere` ·
`noDoorPutsAPoolContainerInTheTrash`. **RED-ON-OLD** by behavioural
revert of the two pool arms: `"Untitled"`, as shipped.

**How, without touching `Sources/`:** the live pools are read on the
FACE, riding the Trash's own observation — pools are structurally few
(the Blocks area creates ONE and reuses it), the read is
`deleted_at IS NULL`-bounded, and the Trash is a summoned surface, never
a keystroke road. `RecoveryView` gained an optional `openPool` route
(`RootView` passes `.pool(id)`; nil falls back to the pre-13l
behaviour).

> **🔴 RECORDED, NOT FIXED — and it needs `Sources/`, which this batch
> is fenced out of.** The SHARED put-back receipts still say *"note"*
> for a scrap: `RecoveryCopy.putBackAtEnd` (*"Put back at the end of
> this note."*) and `.putBackUnplaced` (*"…its note is gone…"*).
> Making them kind-aware requires `restoreBlock`'s landing (or the Trash
> query) to report its container's KIND. **Rewording them
> kind-agnostically would be worse**, not better: virtually every block
> IS in a note, and *"at the end of this note"* is the better sentence
> for that case. **Owner: this phase** (a later act may take it with a
> `Sources/Queries` change at the orchestrator's word) **or 13u**, whose
> item 5 is already the both-platform copy family.

#### Item 6 — remove the left-margin comment ＋ · **DONE** (`b0d35fa`)

13e E7's hover invitation is gone from `BlockDecor`
(`renderAddChip`, `addChip`, `addChipBlockID`, `addChipSize`,
`leftAddChipRect`, both call sites, the uninstall lines). **Removal
only, per her wording:** the margin CARD and its narrow-gutter badge
stay (a block with comments shows them, and they are the same door), so
do the inline strip, the block menu, ⌘⇧', and the panel.

**One deliberate extra, recorded rather than silent:** E7 had WIDENED
the hover-tracking install condition from *"a drop door"* to *"a drop
door or a comments door"* solely for this chip. With the chip gone that
arm had no consumer, so it narrows back to `onMoveBlock != nil` —
production-identical, which **E7's own comment recorded** (*"every
production controller has both or neither"*), and the drag handle's
reveal is asserted in the new pin so the shared tracking is proven
intact.

**Pin:** `MarginHoverCommentTests
.hoveringAnUncommentedBlockOffersNoMarginPlus` (the suite renamed —
*"The margin's comment faces (13e E7 · 13l 8c)"*). **RED-ON-OLD by
construction**: E7's three pins asserted the exact opposite of every
line in it, and they are gone with the door. Two other pins had their
chip sections removed with an in-place note (`everyMarginCommentFaceSitsLeftOfTheText`'s
third face; `CalmPageHoverTests`' invitation assertions — its drag-handle
half, which is the bug that pin was written for, is untouched).

---

#### Verification at the stop

**Targeted suites for everything touched — ALL GREEN.** Mac:
`TrashConfirmEdgeTests` · `TrashPurgeDoorsTests` ·
`TrashPurgeSharedLayerTests` · `TrashSurfaceTests` ·
`TrashPoolHonestyTests` · `MarginHoverCommentTests` ·
`CalmPageHoverTests` · `LibraryTagFaceTests` · `RecoveryDoorsTests` ·
`CapabilityRegistryTests` — **79 tests in 10 suites passed**. Mobile:
`MobileTrashTests` + `MobileDeletionTests` — **25 tests in 2 suites
passed** (the 2 recorded issues are that suite's own `withKnownIssue`,
exactly as the Act-1 record describes). Both targets
`build-for-testing` clean.

**THE FULL GATES ARE THE SUCCESSOR'S** (`Shared/` was touched, so all
four are owed at batch end: core · Mac full · Mac spine · mobile full).
**Expected movement to reconcile against:** Mac **1572 → 1581**
(+3 `TrashConfirmEdgeTests`, +4 `TrashPurgeSharedLayerTests`,
+2 `TrashPoolHonestyTests`; the margin work is net-neutral in count —
three E7 pins removed, one added, and two more edited in place — so
1581 is the number to expect **before** item 3 adds any). Suite count
**272 → 275** (three new suites). Core **1350/141** and the spine
**63/8** are untouched by construction (zero `Sources/` lines). Mobile
**485/78** unchanged (no mobile test file touched — the hoist's parity
proof).

**Known flakes: neither appeared.** The Phase-12 latency pin
(`EditorWindowSmokeTests/rewriteStrategyLatencies`) and
`CanvasDragTrackingTests` were not in any run here; the recorded
disposition stands — a second `CanvasDragTrackingTests` red anywhere in
this phase promotes it to a `KnownIssues` row (owner 12).

**Sequencing note the brief asked for:** item 2's fix landed BEFORE the
item-4 hoist, deliberately. The hoist rewrites `confirmPendingPurge`'s
body, so fixing the confirm→act edge first meant the hoist inherited a
correct method instead of relocating a broken one — and it keeps the
red-on-old evidence attached to a small, readable diff.

**Fences held:** zero `Sources/` lines · zero
`Sources/VariorumCore/Sync/` lines · zero schema · 13u's editor seam
untouched (no refusal wording, no `planVisibleTakeEdit`, no gap-fence
face) · no shelf-book multi-select · nothing pushed · every commit
staged by explicit path.

### OVERNIGHT AUTHORIZATION (author, 2026-08-24 evening — recorded for any successor seat)

Her word before leaving: display stays on, login session unlocked
(suite runs may proceed; the orchestrator caffeinates around them),
**Variorum is QUIT — the `/Applications` refresh window is OPEN
tonight** (A1 backup first, per the standing rail; re-check
`pgrep -fl 'Variorum.app/Contents/MacOS'` immediately before the
act anyway). She returns in the morning to: her checklist, any
Fragments contract carry-items, and — hopefully — the authored 13u
plan. Overnight discipline: PROVISIONAL-and-continue; author-only
hard stops pause their single item and report; everything else
proceeds.

### THE LEDGER (every row owned; statuses updated as they move)

| # | item | strand | status |
|---|---|---|---|
| 1 | The first-act Fable cold review (mobile round's Mac diff + 4.5b) | 3 | **review returned (1 MAJOR · 2 MINOR · 2 NIT + clean bill); FIX ROUND LANDED 2026-08-23 — A1-MAJOR-1 fixed with red-on-old pins on BOTH platforms, A1-MINOR-1's two Mac coverage pins in (record above); all four gates green; the other three findings sit in item 4; **ROUND 2 CLEAN — LADDER CLOSED** (zero findings; full Mac suite independently confirmed 1572/272). Orchestrator verification of the dead session's claims: commit `64ffd1a` exists, six files exactly (zero `Sources/`), all four claimed pin names present in the tree. **The one-off `CanvasDragTrackingTests` first-run red — architect's disposition: plan-record only, NO KnownIssues row yet** (isolated 2/2 green + full re-run fully green, diff cannot reach canvas; the gesture-timing flake family). **If it reds again anywhere in this phase it earns the row** (owner 12, beside the latency-pin calibration) — recorded so the next red is a promotion, not a re-derivation** |
| 2 | The dead Delete Now / Empty Trash doors (pin-first at the real surface) | 2 | **DONE (Act 2 seat 1, `b527b72`)** — the confirm→act edge fixed with `presenting:`; the diagnosis re-derived RUNNING (the presentation hypothesis is dead — it presents fine, incl. inside a `List`); `TrashConfirmEdgeTests` presses the REAL `_NSAlertPanel` button with **no simulated step**; red-on-old verified twice by behavioural revert, the second time against the final pin |
| 3 | The note-deletion door set: Delete Note… (note ▾, confirm) · Library door confirm · ⌘-click multi-select + delete-all | 1 (§8) | **NOT STARTED — zero edits** (Act 2 seat 1 stopped at the cast correction). Its reconnaissance IS recorded in the partial record above: the three renderers share ONE declaration (`SidebarView.contextMenuCapabilities`), ⌘-click multi-select ALREADY EXISTS (`List(selection:)` — the bulk tag menu uses it), the phone owns the wording and it needs hoisting into `Shared/RecoveryCopy.swift`, and `.deleteSelectedNotes` needs a new `CapabilityContext` field + a sampled context or the walk cannot see it act |
| 4 | The remaining decision-layer hoist (`RecoveryViewModel` ↔ `MobileTrashModel`) — **scope grew at Act 1: + the four raw-error catches through `DeletionRefusal.fallback` (A1-MINOR-2) · + the `*NotDeleted` family in the shared home (A1-NIT-1) · + split the act compositions out of `RecoveryCopy` when the layer grows (A1-NIT-2)** | 2 | **DONE (Act 2 seat 1, `68cd28c`)** — `Shared/RecoveryActs.swift` born: `TrashPurge` (ONE `Confirm` type behind a typealias on each model) + `TrashListing.windowed`; all three routed findings landed; `TrashPurgeSharedLayerTests` (4 pins), A1-NIT-1 red-on-old by revert. `daysLeft` deliberately NOT hoisted (already a one-line forward to core) |
| 5 | Pool/scraps deletion honesty check (§8b) | 1 | **DONE — AND IT WAS NOT CLEAN (Act 2 seat 1, `b0d35fa`)**. A pool CONTAINER is unreachable (pinned), but a deleted SCRAP's face called its pool a note three ways — the home's display brain, the "Open note" label, and `.post` routing — all fixed on the face, `TrashPoolHonestyTests`, red-on-old by revert ("Untitled"). **ONE RESIDUAL RECORDED, NOT FIXED:** the shared put-back receipts still say "note" for a scrap — it needs the landing to report its container's kind, i.e. `Sources/`, which Act 2 is fenced out of |
| 6 | Remove the left-margin comment ＋ (§8c, removal only) | 1 | **DONE (Act 2 seat 1, `b0d35fa`)** — 13e E7's hover ＋ gone from both margins; card, badge, inline strip, block menu, ⌘⇧' and the panel untouched; E7's now-consumerless hover-tracking widening narrowed back with the drag handle's reveal pinned intact. Red-on-old by construction (E7's three pins asserted the opposite) |
| 7 | **L-a** identity-projection audit: hoist + Mac wiring + Mac red-on-old + the empty-entry hole | 4 | open |
| 8 | **L-b** `QuickEntryBar` text destruction on refusal | 4 | open |
| 9 | **L-c** `AppBootstrap` off-main migrations (`.opening` state, both roots) | 4 | open |
| 10 | **L-d** `AppSession.postAutosaves` removal path + the three false comments | 4 | open |
| 11 | Backup second destination (picked folder) + retention + per-run integrity | 1 | open |
| 12 | The Data Safety face + log (freshness evidence) | 1 | open |
| 13 | The restore runbook (incl. M3/M6 sentences, external-snapshots widening) — **scope grew at her post-sitting rulings: + the SYNCED-restore warning pair (ordinary deletions return to the Trash; purged stays purged) in runbook AND restore face · + the backup-archaeology recipe (open a backup in a scratch copy, copy out AS NEW — the recovery-as-copy doctrine) · + the "WHAT DELETION MEANS" section (her clarity mandate below): the three stages defined plainly (delete → Trash 30 days → permanent delete/purge), the BOTH-SIDED backup truth, and the purge definition · + THE MIRROR SECTION (her 2026-08-24 overnight questions): why the mirror is a PEER, not a backup (it replicates mistakes at sync speed; frozen copies protect where converging ones can't), what it DOES cover (device loss — re-onboard + passphrase), and the TWO PROVEN mirror-recovery roads named with their artifacts (mirror lost → repush from local truth, run live at 14b twice + 14c; device lost → re-onboard from mirror, exercised live at the phone's onboarding)** | 1 | open |
| 14 | The rehearsed restore drill, end-to-end in SCRATCH | 1 | open |
| 15 | The deletion-aware restore matrix M1–M7, headless on the fake server | 1 | open |
| 16 | Bulk-`.md` plaintext insurance, automated | 1 | open |
| 17 | The sync-status face | 1 | open |
| 18 | The passphrase / recovery-phrase sanity check (read-only unwrap) | 1 | open |
| 19 | ~~The app lock + its fallback SETTING + honest wording~~ | 1 | **MOVED to 13p** (her ruling 2026-08-24 — the post-sitting record above; R13p-5's at-open modes are the lock born real; the system-password fallback retired with the move; the mobile Face ID twin rides 13p Batch 4) |
| 20 | Item 9: journal-day deletions travel to Fragments at delete time | 1 (§9) | open |
| 21 | The 8d recovery-story walk (every door, as a user) | 1 | open |
| 22 | The end-of-phase Fable ladder (combined diff) | — | open |
| 23 | Closeout: author 13u's execution plan + kickoff | — | open |
| 24 | Closeout: refresh `/Applications/Variorum.app` (zero-instance window) | — | open |
| 25 | Housekeeping: the 13u "EIGHT items" count fix (3 places) + her disk-encryption question → the 13p note | — | **done this sitting** |
| 26 | **The scrap put-back receipt names the wrong kind** (seat 1's row-5 residual: the shared put-back receipts say "note" for a scrap — the put-back LANDING must report its container's KIND, a small `Sources/` change Act 2's per-batch fence excluded) | 2 | **open — seat 2's; the architect exercises seat 1's named option IN-PHASE** (the recovery story must be honest from every door, §8d — this is that mandate's letter; core Operations/Queries only, a pin rides it, zero schema, zero `Sync/`) |

### The batch plan (the architect's, within the mandate — acts may merge at dispatch; the ledger is the truth)

**Act 1** (Fable, running): the first-act cold review. Findings land
here repo-first; fixes via an Opus fix session with traced mechanisms
+ red-on-old pins; a fresh Fable round-2 re-review per the ladder
rules. **Act 2** (Opus): the trash-surface mini-round — ledger 2–6
(+ any Act-1 findings in those files, so `RecoveryView` is touched
once). **Act 3** (Opus): the L-items, 7–10. **Act 4** (Opus): backups
+ drill + matrix, 11–15. **Act 5** (Opus): the faces, 16–18 (19 moved
to 13p). **Act 6** (Opus): item 9, ledger 20. **Act 7**: the 8d walk
(21), then the end-of-phase ladder (22), then closeout (23–24 + the
full ritual).

### ACT 3 — THE L-ITEMS: the brief (fresh Opus session; dispatches after Act 2 closes)

**Scope: ledger rows 7–10 — mobile round 2's Mac/`Shared/` backlog,
moved here at her 2026-08-23 ruling. The mobile handoff's §2b
handback checklist will verify each; DEFER OUT LOUD, NEVER SILENTLY.**
Read: CLAUDE.md · this plan's §"13l TAKES" table (L-a…L-d — the
traced detail per item) · the 13j Environment traps by reference ·
`notes/plans/mobile-round-2-orchestrator-handoff.md` §2b (the
handback rows for L-a…L-d) and its §4/§5 where cited.

1. **L-a (row 7) — the identity-projection audit reaches the Mac.**
   HOIST `auditIdentityProjection` + the separator check
   (`MobileEditorViewModel.swift:1898–1920`) into
   `Shared/EditorBrain/`; wire the Mac's editor view model to it
   (the DEBUG per-keystroke oracle for *the totals agree while the
   content is wrong*); **carry the empty-entry hole's fix** (the
   walk's `guard range.length > 0 else { continue }` skips an empty
   entry's separator, leaving that boundary unaudited); pin
   **red-on-old ON THE MAC** by reproducing the traced corruption
   there (`stored → ["Alpha", "Beta beta", "G"]` — mobile round 2
   §20 reproduced it Mac-side; drive the same road). The phone's
   audit becomes a consumer of the hoisted brain (zero-test-edit on
   the phone where the move is pure).
2. **L-b (row 8) — `QuickEntryBar` stops destroying her text.**
   `Variorum/Features/Shelf/QuickEntryBar.swift` `submit()` does
   `entryText = ""` BEFORE the mint and its catch is a raw
   `"New note refused: \(error)"` dump — in the bar she uses daily.
   The phone's shipped fix is the reference shape
   (`MobileQuickNote.file()` — reset ONLY on a completed hand-off);
   route the copy through `OpsRefusalCopy.message(for:)`. Red-on-old:
   a refused mint keeps the text AND speaks. (`QuickNotePad.take()`
   clears deliberately and its copy speaks — leave it.)
3. **L-c (row 9) — `AppBootstrap` off the main thread.** The init
   opens the store and runs migrations SYNCHRONOUSLY on the main
   thread before first paint (P2, both platforms). **The shape is
   RULED** (mobile §58/§62): an `.opening` state; the file work
   detached, hopping back to MainActor for `install` + the state
   write (preserving the once-per-process flag); `retry()`
   re-entering; a quiet launch view in BOTH app roots; the not-ready
   window cannot open by construction (`AppSession` exists only
   inside `.ready`). Context: D8's device number came back "almost
   imperceptible" — worth-doing-not-urgent; re-measure after (the
   sim numbers: 54.0/23.4 ms first, 5.0 reopen, 3.6 at 100k — flat).
4. **L-d (row 10) — `AppSession.postAutosaves` gains its removal
   path.** `releaseAutosave(forPost:)` called from the quick-note
   box's `reset()`; **the traced trap must be handled deliberately**:
   the Mac registers a `quitFinalize` closure at MINT time, so
   release-then-remint registers a second for the same post (deduped
   by `closeAutoCommit` — noise not corruption, but make it
   deliberate and documented). Fix the THREE FALSE comments in that
   file (`:89` "no undo UI yet" — shipped; `:240-245` inverted — the
   quick note DOES cache a coordinator; `:206-208` "open posts are a
   handful by construction" — false for exactly this reason).

**Close of act:** run the §2b handback greps for L-a…L-d and QUOTE
the flipped values in your record (they must all read "done" now);
full four gates (this act is `Shared/`-heavy), counts quoted; the
standing hard rules (no live-instance contact, explicit paths, no
push, no schema, no `Sync/`, 13u's seam untouched — L-a's hoist is
the AUDIT, never the refusal semantics); append "ACT 3 — RECORD" to
this plan; the known flakes' isolation rule as always.
