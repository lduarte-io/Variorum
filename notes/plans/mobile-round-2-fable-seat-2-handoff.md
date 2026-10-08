# Mobile Round 2 — THE SECOND FABLE SEAT'S HANDOFF (written 2026-09-01; the seat closes batch 10's unit and INSTALLS the build to her phone, then the round PAUSES at her word until 13u is done on the Mac — this file governs the resume)

> **⚠️ THE ROUND IS PAUSED (her 2026-09-01 ruling, verbatim in `mobile-round-2-status-2026-09-01.md` §H):** *"I probably won't finish this round before just finishing the mac side of things … I'll resume mobile development when 13u is done on the mac side."* So the successor's FIRST acts are not batch 8 — they are the careful `main` → `mobile` MERGE (13u1 rewrote the editor seam this round composes with), the handback checklist (§2b of the standing successor handoff), and the #94 hoist batch; THEN the road in §2 resumes. **PL-13's data-safety faces WAIT** for the Mac's revised story (her words: "mac is going to have some changes still to that story that I've just decided").

## 0. PASTE-READY KICKOFF

> You are the architect/orchestrator for **Mobile Round 2** of the Variorum
> iPhone app — the THIRD Fable seat. Work in `~/dev/variorum-mobile` on
> branch `mobile`, under `/architect-phase`.
>
> **READ IN FULL, YOURSELF, IN THIS ORDER:** `CLAUDE.md` ·
> `notes/MobileSoul.md` · `.claude/skills/architect-phase/SKILL.md` ·
> **`~/dev/variorum/notes/SessionResiliencyProtocol.md`** (in the MAIN
> checkout until the post-13u merge carries it here — it BINDS every
> session) · **this file** · `notes/plans/mobile-round-2-fable-seat-handoff.md`
> (the first seat's — §3 was the road; §4 her #94 ruling; §6 the cutover
> signal) · `notes/plans/mobile-round-2-handoff-2026-08-30.md` §7 (the
> whole-round status table; every closed unit is struck there with its
> hashes) · the SEVEN unit records this seat produced, each `-record.md` +
> `-cold-review.md`: `mobile-batch-6b`, `mobile-batch-9`,
> `mobile-batch-45c-phone`, `mobile-batch-7`, `mobile-batch-10` (read their
> UNIT CLOSED sections first, then in full) · the committed briefs for what
> is NEXT: `mobile-batch-8-brief.md` · `notes/QUESTIONS.md` #84–#94 · the
> standing `mobile-round-2-orchestrator-handoff.md` §4–§8 (rulings index,
> machinery, closeout obligations).
>
> **CAST (her 2026-08-30 ruling, unchanged):** Fable orchestrates; Opus
> implements and cold-reviews; ONE dev subagent at a time; reviews may run
> in parallel (in practice: strictly sequential in ONE worktree — a build
> and a review never overlap). **R28 binds:** BUILD → COLD REVIEW → FIX as
> one unit; the review dispatches from the build's report. **The ladder:**
> 0B/0M at round 1 ⇒ one fix wave + the orchestrator's verification closes;
> MAJORs in a SEAM (liveness, editor, structural) ⇒ a fresh focused round-2
> re-review of the wave's diff (4.5c-phone's precedent); MAJORs in
> faces/records ⇒ one wave + verification (batch 9's and 7's precedent).
>
> **THE FENCES (unchanged):** never touch `App/Variorum/Shared/EditorBrain/`,
> the cross-block planner, 13u1/13u2's items, the shared core (`Sources/`,
> `App/Variorum/Shared/` — committed changes; reading fine), or the Mac
> target. Her #94: the four Shared hoists + (added this seat)
> `Queries.exportMapped` → `public` ride the post-13u merge. B1's residual
> is hers. **VERIFY, DO NOT TRUST** — merge-base diffs, re-derived counts,
> fence-grep before trusting any green.

## 1. STATE AT CUTOVER — re-derive, don't inherit

| | |
|---|---|
| branch | `mobile`, pushed through **`3694a82`** (batch 10's unit close) + this file's fill; merge-base with main `43a35ef` (re-derive — main moves) |
| mobile suite | **727/103** green (batch 10's unit close, 2026-09-01); 2 known issues = the ONE documented diagnostic test (`MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`). The trail: 632/96 cutover → 661/98 (6b) → 667/99 (9) → 678/99 (4.5c-phone) → 712/102 (7) → 727/103 (10). A full-suite red at `MobilePerfWalkTests.typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k` is the KNOWN load-flaky pin; a runner restart/death mid-suite has been seen FOUR times under load this round — re-run and report both, never conclude from one |
| hygiene | zero committed `Sources/`, `Shared/`, Mac-target, EditorBrain, schema, build-config changes ALL SEAT (fence-grep verified at every unit close); marker 7 |
| this seat shipped | **6b** the per-note tray (PL-14 CLOSED) · **9** the ⋯ vocabulary (the selection defect TRACED, awaiting her device experiment) · **4.5c-phone** (the liveness seam store-confirms every refusal; the FULL ladder) · **7** takes & block doors phone-local (PL-10 (a)/(c)/(d)) · **10** navigation (the Starred‹Shelf›Library band with a settle spring; the starred page as a face; New Note/New Chapter inside a book with refusals spoken beside the doors) — review 0B/2M/4m/2n, wave `8cb9c25`, closed `3694a82` |
*[removed for publication]*

## 2. THE REMAINING ROAD, in order (the first seat's §3, burned down) — AFTER the merge + the #94 hoist batch (see the banner)

1. **Batch 8 — settings & judgment, phone-local** (brief COMMITTED:
   `mobile-batch-8-brief.md`): cadence/pruning settings rows (PL-11(f)) ·
   document settings (PR17) · PL-9's bridge-door honest-copy floor
   (hide-vs-keep and whether the phone RUNS the bridge are HERS) · M14's
   unmeasured half (MEASURE only) · arch MINOR 3's cheap test-side half if
   verified test-side · the #94 deferral section (PR10, PR23).
2. **The leftover-review-backlog batch** — ONE consolidated batch that now
   OWNS THREE ROUTED DEFECTS beside the MINOR/NIT backlog: (a) the
   STRANDED-`isEditable` defect, BOTH variants (batch 9's stranded-false;
   4.5c's tombstone photograph) — the ruled fix: ONE nesting-aware
   editability authority on the write surface that DERIVES editability at
   rest (a depth count alone leaks the tombstone direction), pinned against
   the two-sheet interleave; (b) the SYNC-ROAD SILENT KEYBOARD DROP
   mechanism (how a relinquish tells "this surface deleted it" from
   "someone else did" — the VOICE half is hers); (c) the batch-5 review's
   4 MINOR + 5 NIT (the collapsed-box overflow sharpest) · 6a's
   m3/m4/n7/n8/n9 (m5 is Shared/ — fenced) · arch MINOR 4 (refusal copy's
   ten homes → extend `DeletionRefusal`'s pattern) + NIT 2 · **R24**
   ("more info" → "info", `MobileReferences.swift:52` + two pins) ·
   **4.5e verification** (the `.opening` arm renders; autosave release at
   the quick note's `reset()`). Write its brief from these sources; the
   §7.2 leftover row carries the routed defects' full text.
3. **PL-13's faces** (unslotted — slot them): the Data Safety twin · the
   sync-status slot · the `SecretCheck` face (Face ID framing) · the
   `.md`-insurance destination story (candidate) · note-level multi-select
   + delete-all (design call — batch 7's block multi-select is the
   precedent shape).
4. **The dedicated stability pass** (4.5's exit condition, owns M27;
   read-only — consider timing it after the 13u merge so it reviews the
   final seam) → **the whole-round pass** (closeout obligation ZERO, over
   the round's entire diff) → **CLOSEOUT** (the standing handoff §7's
   THIRTEEN obligations — 1–8, 10, 11, 13, 12; count them — plus the
   QUESTIONS fuller pass, a transcription job from the sweep review's clean
   bill).
5. **After 13u lands and she orders the merge:** the merge (13u1 rewrites
   the editor seam this round composes with — slow and careful); then the
   #94 list unblocks (FindReplaceGate/PR21 · TakeClipboard/copy-all-takes ·
   applyTypedPath/PR10 · ThemeStore/PR23 · `exportMapped`→public for M23's
   callout corner); the 13u-owned items verified built-or-returned via the
   handback discipline (§2b of the standing successor handoff).

## 3. HER BUNDLE — held for her sitting, nothing decided autonomously

- **THE DEVICE QUEUE (needs her phone, one install window):** the
  selection-defect experiment (`mobile-batch-9-record.md` §4.5 — THREE
  observations, one minute: does the loupe appear · plain vs fanned blocks
  · already-selected-before-drag) that collapses four candidates to one ·
  the emoji sheet's keyboard-overlap check (batch 7 record) · the swipe
  band's real pan (batch 10, if the harness could not drive it) · the
  earlier queue (Face ID walk · Read-mode memory at 100k · D9 · M16 ·
  arch MAJOR-2's does-it-fire · the iOS `presentationAnchor` arm) ·
  **AND THE INSTALL RE-OFFER** — her phone runs the 08-21 build.
- **PROPOSALS (propose-only):** the merge vocabulary
  (`mobile-batch-9-record.md` §5 — (A) select-then-merge riding batch 7's
  multi-select + (B) `Merge with Next`; (C) recorded, not recommended;
  the multi-BLOCK vs multi-TAKE reading flagged) — Merge Selected stays
  UNBUILT until she rules.
- **VOICE/PRODUCT questions surfaced:** what the phone should SAY when
  sync deletes the note under her (MobileSoul §5.3's discoverability
  family) · the sync-road silent drop's design question.
- **PROVISIONALs by unit:** 6b's eight (Q8's blocks-chip segments as the
  tray door · segment words · Archive Block with no confirm · PR14's ⚠
  glyph · the tray-naming receipts · the guide chapter's name/placement) ·
  9's (PROVISIONAL 3: a gap block's history unreachable after the door
  move) · 4.5c-phone's (`presenting:` on Rename Lens; the seam-carve
  deferral) · 7's (door placements · the emoji road's owned-sheet chrome ·
  the `Select` entry button · the confirm-on-bulk-delete doctrine reading)
  · 10's (the band arrangement · the tap glide · the old starred region retired · the finished-book doors staying · the assign-to-chapter door's placement — HERS) · the standing #87/#89/#90 + 6c's Q-set + the filter
  batch's set + the union stamp mapping.
- **Informational:** the four session deaths (all Opus-pool session
  limits; zero commits lost) and her plan upgrade; the stale
  `Variorum-batch6a` simulator left on the machine; the shared scratchpad's
  eleven stale `prerevert/` dirs (delete at her word).

## 4. MACHINERY — what this seat re-proved or added (everything in the first seat's §5 and the standing handoff §5/§6 still binds)

- **The Session Resiliency Protocol is now the law** (her instruction,
  2026-08-31 evening): implementers COMMIT PER PIECE + PUSH EACH; LIVE
  STATUS records from the first commit with PENDING marks; foreground
  waits only. **The survival posture proved itself four times this seat**
  — every death's tree was adopted intact, every agent resumed in place
  by `SendMessage` (transcripts survive plain limit deaths and even a
  harness restart), and the ONE time an agent died one step short of its
  record commit, the orchestrator committed it for it.
- **Read the tree before resuming ANY dead agent** (§10.5): `git status`,
  the record file, the sim list, the prerevert dirs — work vs corruption.
  A mid-revert death is the hazard; none occurred, because agents announce
  "no revert in flight" before writing survival records.
- **Unique pre-revert dirs, diff-verified restores** — the shared
  scratchpad accumulates every batch's `prerevert/`; restoring from
  another batch's copy would clobber the current work (batch 7's own
  finding). Every brief now carries it.
- **Name every revert production-or-fixture** (the filter unit's M1 rule)
  and **write findings/results files INCREMENTALLY** — a final message
  dies with its session; a file does not.
- **In-batch deviations from an adjudicated shape are endorsed post-hoc
  ONLY when the adjudicated shape was traced not to work** (6b's onDismiss
  refresh; 7's relinquish-branch decline) and always with a process note.
- **Harness traps learned:** `MobileTakesBrowserTests.swift` declares TWO
  suites (filtering by the first name runs a subset) · a SwiftUI `Menu`'s
  rows are undrivable in-process (drive the model's named method; pin
  the listing and the door) · an explicit `accessibilityLabel` REPLACES
  a row's composed label · `Queries.PreservedOriginal` has no public init
  (mint through the store) · long-press gestures are undrivable (chrome
  buttons as entries).
- Her memory file for this seat:
  `~/.claude/projects/-<home>-dev-variorum/memory/mobile-round-2-fable-seat.md`
  — keep it current at every unit close and every limit warning.

## 5. THE ONE THING NOBODY OWNED — DISCHARGED AT THIS SEAT'S CLOSE (confirmed: §1's phone row)

**Her phone ran the 2026-08-21 build all round;** the install of batch 10's tree is this seat's last act at her explicit word. Five closed units, three
fixed BLOCKERs, the whole recovery story, the tray, the ⋯ vocabulary and
the fan's hands exist only in the tree. The device queue (§3) cannot run
without an install window, and the selection defect — her one daily-use
report — waits on one minute of her finger. **Re-offer the install at the
next sitting; do not wait for the round's end.**

## 6. THE CUTOVER SIGNAL

This seat's LAST act is closing batch 10's unit: its UNIT CLOSED section
atop `mobile-batch-10-cold-review.md`, §1 of this file filled (the
PENDING slots), the §7.2 row struck, all PUSHED. Until that section
exists, treat batch 10's unit as live or died per the protocol's
recovery rules — check `git log -1 --format=%ci`, read the tree, resume
by `SendMessage` before anything else.
