# Mobile Round 2 — THE FABLE SEAT'S HANDOFF (written 2026-08-31, at ~650k context by her offer; the outgoing seat closes the in-flight filter unit, then this governs)

## 0. PASTE-READY KICKOFF

> You are the architect/orchestrator for **Mobile Round 2** of the Variorum
> iPhone app — the second Fable seat. Work in `~/dev/variorum-mobile` on
> branch `mobile`, under `/architect-phase`.
>
> **READ IN FULL, YOURSELF, IN THIS ORDER:** `CLAUDE.md` ·
> `notes/MobileSoul.md` · `.claude/skills/architect-phase/SKILL.md` ·
> **this file** · `notes/plans/mobile-round-2-handoff-2026-08-30.md` (§7
> is the whole-round status table; its 6c row is DONE) ·
> `notes/plans/mobile-fable-sweep-review.md` (the pre-batch mandate's full
> arc — findings, adjudications, both fix waves) · the three batch records
> this seat produced (`mobile-batch-6c-record.md` + `-cold-review.md` ·
> `mobile-batch-filters-record.md` + its review/fix records) ·
> `notes/plans/mobile-batch-6b-brief.md` (your FIRST dispatch) ·
> `notes/QUESTIONS.md` #84–#94 · the standing
> `mobile-round-2-orchestrator-handoff.md` §4–§7 (rulings index, machinery,
> closeout obligations — unchanged and binding).
>
> **CAST (her resumption ruling, 2026-08-30):** Fable orchestrates; Opus
> implements and cold-reviews for the most part; **rare Fable cold reviews
> allowed** mid-phase; **ONE dev subagent at a time**; reviews may run in
> parallel. **R28 binds:** BUILD → COLD REVIEW → FIX as one unit — the
> review dispatches from the build's report, never later.
>
> **THE FENCES:** never touch `App/Variorum/Shared/EditorBrain/`, the
> cross-block planner, 13u1/13u2's items (batch 4.6 · 4.5c's cross-block
> SEMANTICS · arch MINORs 1–2 · U-1…U-5/U-7), **or the shared core**
> (`Sources/` and `App/Variorum/Shared/` — her seat fence while 13u1 is
> live on `main`; READING is fine, temporary red-on-old reverts restored
> byte-identical are fine, COMMITTED changes are not). `App/Variorum/
> Variorum/` (Mac faces) equally not this round's. B1's residual is HERS
> (#88; ruled on main's pre-13u sitting — do not act pre-merge).
> **VERIFY, DO NOT TRUST** — diff against the merge-base with
> `origin/main` (`git merge-base origin/main HEAD`), never origin/main
> itself; re-derive every count you rely on.

## 1. STATE AT CUTOVER — re-derive, don't inherit

| | |
|---|---|
| branch | `mobile`, pushed; merge-base with main was `43a35ef` (re-derive — main moves) |
| mobile suite | **727/103 green** (batch 10's unit close, 2026-09-01 — the second seat's LAST unit; the trail: 632/96 cutover → 661/98 at 6b → 667/99 at 9 → 678/99 at 4.5c-phone → 712/102 at 7 → 727/103 at 10); 2 known issues = the ONE documented diagnostic test (`MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`, two `withKnownIssue` records). A full-suite red at `MobilePerfWalkTests.typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k` is the KNOWN load-flaky pin (KnownIssues row, owner 12) — re-run isolated before concluding anything |
| hygiene | zero committed `Sources/`, `Shared/`, Mac-target, EditorBrain, schema, build-config changes ALL SEAT; marker 7; verify with the fence grep before trusting |
| this seat shipped | the pre-batch sweep ladder (mandate discharged — see §2) · **batch 6c DONE** (Two-rooms + the Versions face; review 0B/0M; fix wave in) · **the filter batch CLOSED** (kind filters both rooms, books-as-rows, the #93(b) All-union, sort glyph; her #92–#94 rulings; the UNIT CLOSED banner tops `mobile-batch-filters-cold-review.md`) |
| her phone | still the 2026-08-21 23:49 build (R30) — running three since-fixed BLOCKERs; the re-offer of an install window is on her list (standing handoff §8 item 15) and nobody owns it yet |

## 2. WHAT THE OPENING MANDATE SETTLED (do not redo)

The sweep + its ladder (`mobile-fable-sweep-review.md`) DISCHARGED: the
five-MAJOR round's owed R28 review · 4.5a's owed ladder round 2 · 4.5d's
new-pins review. NOT discharged: **the dedicated stability pass** (4.5's
exit condition, owns M27 — read-only, so the fence doesn't block it;
consider timing it after the 13u merge so it reviews the final seam, and
route M27's FIX to 13u if it lands there) and **the whole-round pass**
(closeout obligation ZERO). Standing riders: `commitNow` takes the
`MobileWriteLatch` the day any surface gives it a BUTTON (its UIMenu host
is what makes it safe today); sixteen un-traced unlatched doors adopt the
latch as batches touch them; the QUESTIONS end-of-file marker is the only
next-free-number authority (#83 permanently unused).

## 3. THE REMAINING WORK TO MOBILE PARITY (excluding 13u's items), in order

1. **Batch 6b — the per-note tray.** Brief COMMITTED
   (`mobile-batch-6b-brief.md`): §69.3's ruled shape, the door
   (PROVISIONAL Q8 — the blocks chip's segments), PR6 archive doors, the
   PR14 lens-dangles notice, PR22 the guide's deletion chapter (+ its
   stale shelf lesson), and it FLIPS 6c's precondition-pinned
   `purgeRoad: nil` (the tray IS the take's purge road). Closes PL-14.
2. **Batch 9 — the editor's ⋯ vocabulary + 🟠 TEXT SELECTION.** Her list:
   structural undo AND redo doors in ⋯ · take history to the per-take ⋯ ·
   "Takes" out of the main ⋯ · the merge-vocabulary PROPOSAL
   (propose-only, to her) · **the text-selection defect** (*"holding it
   down makes you scroll upwards"* — a daily-use defect; TRACE the
   mechanism first; it is phone input-handling until proven otherwise —
   STOP if the trace leads into `EditorBrain/`).
3. **4.5c's phone-local half:** **B45-2 FIRST** (`displaySlot`/`slots[i]`
   coupling at `MobileEditorViewModel.swift:1146` — batch 7's reorder
   walks into it) · the live-editor-over-a-tombstone fix (the liveness
   seam — phone files) · `MobileLenses.swift:419` settle-or-record · two
   one-liners (`deleteNoteRefusal:958` → `DeletionRefusal.words`; the
   A1-15 test comment). The A7/#34 seam carves: the MECHANISM wiring is
   phone-local but 13u item 5 rules the gesture's semantics — safest is
   defer to post-13u; record the call either way.
4. **Batch 7 — takes & block doors, SPLIT BY THE FENCE:** buildable now —
   reorder takes (PL-10(a), after B45-2) · take→block / takes→blocks
   doors (PL-10(d)) · M23 copy-follows-screen · swatches + emoji ·
   block multi-select. **FENCE-BLOCKED (Shared/ hoists): PR21 replace
   (hoists `FindReplaceGate` WITH it — never build replace without the
   hoist) and copy-all-takes (hoists `TakeClipboard`'s composition).**
   See §4 — her call pending.
5. **Batch 10 — navigation:** swipe shelf↔library (*"it's killing me"*) ·
   the home-screen starred-notes face (a phone FACE — she ruled NOT a
   smart book; 13i owns that) · new-note + new-chapter buttons inside a
   book (doors over core ops).
6. **Batch 8 — settings & judgment, SPLIT BY THE FENCE:** buildable now —
   cadence/pruning settings rows (PL-11(f)) · document settings ·
   PL-9's judgment acts (the bridge door: her floor is honest copy —
   "your journal syncs with Fragments from your Mac"; hide-vs-keep is
   recorded at the standing handoff §8 item 16; whether the phone RUNS
   the bridge is HERS/13v) · M14's unmeasured half (measure only).
   **FENCE-BLOCKED: PR10 tag-chip grammar (hoists `applyTypedPath`) ·
   PR23 the voice fork (hoists `ThemeStore`; arch MINOR 3's structural
   half rides it — its cheap half, un-globaling the test mutation, is
   buildable now).**
7. **The leftover review backlog** (one consolidated batch) — **and since
   2026-08-31 it also owns ONE REAL DEFECT with its fix's shape already
   ruled: 🟠 the STRANDED `isEditable`** (batch 9's cold-review MAJOR 1;
   three overlay sheets each save/force/restore the page's editability,
   so an interleave leaves her note permanently read-only with no sheet
   on screen — text-loss-adjacent). **The fix: ONE nesting-aware
   editability authority on the write surface** replacing the three
   per-sheet pairs, with the two-sheet interleave pinned red-on-old. The
   binding row is `mobile-round-2-handoff-2026-08-30.md` **§7.2**; the
   full record is `mobile-batch-9-record.md` §4.6. The rest: batch-5
   review's 4 MINOR + 5 NIT (the collapsed-box overflow is the sharpest) ·
   6a review's m3/m4/n7/n8/n9 (m5 is a Shared/ cleanup — fence-blocked) ·
   arch MINOR 4 (refusal copy's ten homes → extend `DeletionRefusal`'s
   pattern, phone-local) + NIT 2 · **R24** ("more info" → "info" — STILL
   OWED, verified 2026-08-31: the literal lives at
   `MobileReferences.swift:52`; three sites + two pins written out in
   `mobile-batch-5-record.md`) · **4.5e verification** (the `.opening`
   arm renders on the phone; autosave release at the quick note's
   `reset()` behaves — verification only).
8. **PL-13's faces** (unslotted — slot them): the Data Safety face twin ·
   the sync-status slot · the `SecretCheck` face (Face ID framing) · the
   `.md`-insurance destination story (candidate) · note-level
   multi-select + delete-all (design call).
9. **The dedicated stability pass** (timing note in §2) → **the
   whole-round pass** → **CLOSEOUT** (the standing handoff §7's THIRTEEN
   obligations — numbered 1–8, 10, 11, 13, 12; count them — plus the
   QUESTIONS fuller pass: the still-unnumbered held items are enumerated
   in the sweep review's clean bill, a transcription job).
10. **HER-ONLY residue:** the device queue (Face ID walk · Read-mode
    memory at 100k · arch MAJOR-2's does-it-fire · D9's seen-by-a-human) —
    batch with her next install window, and RE-OFFER the install (§1's
    last row); the PROVISIONAL bundle (#87/#89/#90 + 6c's Q-set + the
    filter batch's set) at her next sitting.

**AFTER 13u lands and she orders the merge:** the merge is the careful
one (13u1 rewrites the editor seam this round composes with); then the
fence-blocked hoist items above unblock, the 13u-owned items (4.6, the
cross-block semantics, U-items, arch MINORs 1–2) get verified
built-or-returned via §2b's handback discipline, and the round can close.

## 4. ~~ONE QUESTION HELD FOR HER~~ — **RULED 2026-08-31 (QUESTIONS #94)**

**The four Shared-hoist parity items are DEFERRED to the post-13u merge.**
Her words: *"i agree that those four hoists should just be deferred to the
post 13u merge - seems cleaner that way."* So: **FindReplaceGate (and with
it PR21 replace, which must never build without it) · TakeClipboard
(copy-all-takes) · applyTypedPath (the tag-chip grammar) · ThemeStore
(PR23, and arch MINOR 3's structural half)** all wait for the merge;
batches 7 and 8 build their phone-local halves only, and the deferral is
recorded on each batch's record so the post-merge session inherits a
decision, not a discovery.

**AND A FIFTH, ONE-WORDER, RIDES WITH THEM** (added at batch 7's fix wave,
cold review MAJOR 1 — it is the same fence and the same conversation, and
it had no owner outside a plan file that closes):

- **`Queries.exportMapped` → `public`** (`Sources/VariorumCore/Queries/Export.swift:59`).
  Zero behaviour change, one keyword. It is the whole of M23's recorded
  corner: `exportMapped` maps a callout block to its blockquote, it is
  `internal` to VariorumCore, and re-implementing it phone-side would fork
  a core brain (MobileSoul §3) — so a note carrying CALLOUT FRAMES takes
  the stored road even while a take is peeked or a lens is active, i.e.
  **the one road on which "copy follows the screen" (R15) is not true.**
  The phone ships an honest sentence for it meanwhile
  (`MobileNoteClipboard.Outcome.copiedSavedTakes`). **When the word lands,
  delete the sentence, the `usedSavedTakesInstead` flag and the fence
  branch in `MobileNoteClipboard.markdown`, and FLIP the pin**
  `aCalloutNoteKeepsTheStoredRoadEvenWhilePeeking` (its docstring names the
  expectation that changes). Record: `mobile-batch-7-record.md` §5 and the
  batch-7 review's FIX WAVE RESULTS §1.

## 5. MACHINERY — the rules this seat re-proved or added

Everything in the standing handoff §5/§6 binds. Added or re-proven here:
- **Reviewers write their findings TO A FILE before their final message**
  (the outgoing seat briefed two reviewers final-message-only and had to
  land the findings itself — fragile if the orchestrator dies mid-flight).
- **Test runs drift `Package.resolved`** (four dependency pins) — revert
  it; never sweep it into a commit. Pathspec-limit every commit.
- One simulator + one private DerivedData per agent; CREATE a fresh
  named simulator per agent and delete it after; arm
  `ApplicationAccessibilityEnabled` on every one; iPhone 16-series sims
  are iOS 18.3 = invalid destinations.
- Records land REPO-FIRST the same turn (findings before any fix session
  sees them; rulings verbatim the turn they arrive; status-table cells
  flip the day a batch closes — three ledger-drift findings this seat
  were exactly this class).
- An implementer's in-batch widening is proposed before built (the
  R2-4/wave-2 post-hoc endorsement is the recorded exception, not the
  rule). A dismissal with evidence is a good outcome; class arguments are
  stated as class arguments, never as coverage (the sweep's MAJOR).
- Her memory file for this seat: `~/.claude/projects/-<home>-
  dev-variorum/memory/mobile-round-2-fable-seat.md` — keep it current.

## 6. THE CUTOVER SIGNAL (added 2026-08-31, ~00:55, for the successor's timed check)

The outgoing seat's LAST act is closing the filter unit. **The unmistakable
signal is a "UNIT CLOSED" banner at the top of
`notes/plans/mobile-batch-filters-cold-review.md`** (beside its FIX WAVE
RESULTS section), plus this file's §1 counts updated, all PUSHED. Until
that banner exists: the fix wave is either STILL RUNNING in the outgoing
session or died — check `git log -1 --format=%ci` freshness and do NOT
touch the tree while a wave may be live; if hours have passed with no
banner and no fresh commit, treat it as died and read the tree for both
corruption AND work (standing handoff §10.5) before anything else.
