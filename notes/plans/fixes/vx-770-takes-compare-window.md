# VX-770 — Run: takes & compare after 1.0

**STATUS: OPEN — kicked off 2026-11-04 (overnight away run).**
Ticket: VX-770 · Branch: `vx-770-takes-compare-window` · Worktree: `~/dev/variorum-vx-770` ·
Machine: the Pro · Stage/walks via **nov3coordinator** (REQUEST → READY → GO; the stage is
VX-500's until ~05:36 — this run's suites slot into seams, short-before-long).
**NO release tonight (her word). The PR may merge when the run is genuinely done.**

**Her kickoff words (2026-11-04, this session, verbatim):** *"there is a flicker when you open
compare and turn 'track paragraphs' on and off sometimes"* · *"i've noticed somewhat severe
jumping around when takes are open and you switch into write, then navigate to a block with
takes, then go back to takes. i want that filed and tracked."* · *"I am keen on trying to track
this moving between modes when takes is open bug, because we merged takes staying open and I
noticed it then, but pushing towards release meant that we didn't ticket it at that point, but I
think it is new from that. **I do want the behavior of takes staying open to stay though.**"* ·
*"there's currently a sync effort, so we can't do anything in that area."* · *"in books, sorting
by creation date doesn't seem to be diong anything unless items have an entry date - it should
use their creation date if they don't have an entry date"* · *"do not release when done, but you
can merge your PR."*

**Cast:** Fable orchestrates (this session) and cold-reviews (`fable-reviewer` — the editor seam
rides this run: VX-739 is `Features/Editor`, VX-756 likely touches `PaneSurface`/landing roads);
`opus-implementer` per batch, fresh session each, xhigh (model alias `opus` = Opus 5.5 tonight).
Cross-model ladder rules apply (the reviewer makes the final call; the implementer applies
confirmed fixes; FINDER-FIXES per her 2026-10-13 ruling). Confirmed at kickoff.

**The members (the SUB-ISSUE LISTING, read live at kickoff 2026-11-04 — the VX-548 lesson;
THIRTEEN):** VX-756 (flagship) · VX-757 · VX-740 · VX-730 · VX-731 · VX-732 · VX-733 · VX-728 ·
VX-758 + riders (her question-tool picks at the kickoff sitting) VX-739 · VX-638 · VX-652 ·
VX-634. Pin-before-fix binds PER MEMBER; the cold review covers the whole diff. Re-list the
sub-issues before the ladder.

**Kickoff rulings (hers, 2026-11-04, this sitting):**
- **R-770-1** — the takes stay-open behavior (VX-428, R-601-2) **STAYS**; VX-756 fixes the
  landing, never the staying. Her words above, bolded sentence.
- **R-770-2** — VX-728 ruled **"Yes, show them"** (the question tool): Compare renders block
  comments in the gutter like other surfaces; the §12 every-surface contract line stands with no
  Compare exception.
- Riders seated by her picks: VX-739 + the trio VX-638/VX-652/VX-634; VX-673 and VX-650/651
  deliberately NOT seated (offered, declined).

**Concurrency (the in-flight table + nov3coordinator, 2026-11-04):** VX-500 holds the ONE
Sync/-custody slot (PR held at her word) — this run touches NO `Sync/`, NO custody, NO schema;
the coordinator verified ZERO file overlap (our faces are Mac-only: `Features/Takes`,
`Features/Editor`, `Surface/` — `PaneSurface.swift`/`PaneTextAuthority.swift` live at
`App/Variorum/Variorum/Surface/`, NOT `Shared/`, so the Shared/→phone-suites rule does not bind
as scoped; the moment a real `Shared/` file enters the diff, tell nov3coordinator). VX-771 (MCP
agent ergonomics) runs alongside — surfaces disjoint; the one shared risk is the capability
registry (`Registry/Capability.swift`, `CapabilityRegistry.swift`): this run's registry delta is
expected ZERO; if a batch declares a capability, flag the orchestrator, who flags the
coordinator; whoever merges second re-runs `CapabilityRegistryTests` + `ShellChromeTests` after
its merge-in. Closeouts serialize (VX-500 first in queue; shared ledgers only at merge moments).

---

## Binding principles — the 13b constitution (P-1…P-9, carried per the architect-phase skill)

The skill's P-1…P-9 block and its application notes bind this run verbatim (the skill file is
`.claude/skills/architect-phase/SKILL.md`). The ones this run leans on hardest:

- **P-3 (one text surface, one liveness authority):** `PaneSurface` is the one pane component,
  `PaneTextAuthority` the one liveness brain. VX-728's Compare comments and VX-730/731's board
  comments extend the EXISTING gutter machinery — never a second comment-rendering mechanism
  beside it.
- **P-7 (find bugs before she does):** red-on-old pins verified by behavioral revert, per member;
  SPECULATIVE findings build the pin FIRST as the confirm.
- **P-8:** P1–P3 perf invariants bind — comment reads ∝ rows drawn, never the corpus; VX-756's
  fix must keep the seeded expansion viewport-proportional (VX-428's own measured bar).
- **The overlay/sink delivery law** (the skill's application notes): every equality-gated sink
  delivers its stored state AT WIRE TIME; overlay geometry refreshes trigger on EVERY input axis.
  VX-732/VX-733 smell like exactly this class — state frozen behind an equality gate or a missed
  refresh axis.

## Preflight (done 2026-11-04, this session — reading never delegated)

CLAUDE.md + auto-loaded canon · the master plan incl. in-flight (+ the kickoff rows pushed,
main 82b225601) · the workflow-transition record · `~/dev/variorum/notes/TICKETS.md` (main's
copy, by absolute path — never regenerated from a worktree) · `notes/QUESTIONS.md` (open items
checked; nothing blocking; this run's bundle lands under a fresh number at closeout) ·
`notes/SessionResiliencyProtocol.md` · **`notes/SurfaceContracts.md` in full** (The note / Takes /
Compare + The Bookcase and books are the touched surfaces) · **`notes/TEXTKIT2_NOTES.md` in
full** (the editor seam; batch briefs name it required reading) · the vx-601 record's VX-428
section + batch B record (the flagship's provenance). SyncSpec / MCPSpec / CastleRules: not
touched by this run.

**The two contract lines this run orbits (SurfaceContracts, The note — Takes):**
1. *"Its article remembers the row at the top per note for the session; an entry landing
   outranks the memory when the note's current block changed."*
2. *"The open-fan set is a per-note session memory too — fans stay open across a mode switch and
   back, the seeded set in place before the board's first geometry report, pruned to the note's
   live blocks"* (R-601-2, R-601-6).
And the comments line (The note — editor language): *"Comments and callouts render in the
whitespace gutter outside the text area on every surface, stacked vertically, and the prose
column's measure and left edge never move for a decoration (pinned per surface)."*

---

## The members — mechanism, plan, acceptance evidence

### VX-756 — takes open: Write ↔ Takes jumps the view (FLAGSHIP · BUG · Confirmed · High · TRACE FIRST)
**Her repro:** takes open → switch into Write → navigate to a block with takes → back to Takes →
the view jumps around, somewhat severely. First noticed at VX-428's merge (the VX-601 run,
PR #200, 0.10.4); reads as new from that change. **R-770-1: the stay-open behavior STAYS.**
**Provenance (the vx-601 record, VX-428's section + batch B record):** the open-fan set lives on
the session's `EditorRouter` (`takesExpandedBlocks: [String: Set<String>]`), seeded into
`board.expandedBlocks` at `TakesViewModel` construction when `landingEnabled`, written back from
the mutators/`teardown()`, pruned to the first projection's live blocks. The board remounts per
mode switch (`PostDetailView.swift` ~430–479). A landing pin with a seeded set EXISTS (batch B's)
— so her repro is outside its scenario: she CHANGES the current block in Write first, which by
contract makes the entry landing outrank the article's remembered top row.
**Hypothesis space (trace, don't assume):** (a) the remembered-row restore and the entry landing
BOTH run — restore to the old row, seed expands fans (heights change), landing re-scrolls — two
or three visible movements = "jumps around"; (b) the seeded expansion lands AFTER the first
geometry report on this road (ordering broken only when a landing is pending), so the landing
computes against pre-expansion heights and corrects; (c) a TK2 amplifier — the mid-document
layout-ahead-of-unlaid-predecessors poisoning (TEXTKIT2, the VX-246 finding) re-basing rows under
the landing. The fix follows the TRACED mechanism; the contract's precedence (landing outranks
memory when the block changed) is the spec to build to.
**Acceptance:** the traced mechanism written here; a red-on-old pin (revert-verified) staging her
exact repro shape (open fans → mode switch → current block changed → return) asserting ONE
settled landing at the right row with no intermediate jumps the harness can observe; the stay-open
memory's own pins stay green; a measured note that seeding stays viewport-proportional (P-8).
The walk re-runs her repro by hand.

### VX-757 — Compare: "track paragraphs" toggle flickers (BUG · Confirmed · Medium · REPRO FIRST)
Her words above. Find the toggle's owner in the Compare board; likely a whole-board re-derivation
on toggle (every column rebuilt → a visible blank/paint pass) where a row-mapping change should
re-layout in place. Repro first (she says "sometimes"); pin per the traced mechanism — the
honest shape may be a state-transition pin on the toggle's path (no full rebuild) plus the walk's
eye.

### VX-740 — Compare: two outline columns after one "make outline note" (BUG · Confirmed · Medium · MECHANISM TRACED)
**Traced at VX-736's ladder round 1** (`notes/plans/fixes/vx-736-ladder-round1.md`):
`makeOutlinePost` awaits the mint; the store observation adopts the new projection first, whose
auto-fill (`!autoFilled`, empty first slot, `versionPeers.first`) seats the fresh outline and
sets `autoFilled`; the resumed `makeOutlinePost` finds no empty slot and APPENDS a second slot
with the same id (`CompareBoardView.swift:974–992`, `:430–434`). Pre-existing in Home; VX-727's
wing fix made it reachable everywhere.
**P-770-1 (PROVISIONAL, orchestrator):** dedupe by `result.post.id` before seating — the
auto-fill's seat STANDS and the resume's append YIELDS (one column, the note seated where the
auto-fill put it). Most spec-defensible (no duplicate columns; no other behavior change); one
line to overturn; logged in the closeout's QUESTIONS bundle.
**Acceptance:** the ladder file's named red-on-old pin — adopt a projection carrying the minted
id between mint and resume, assert one column — revert-verified.

### VX-730 — Takes ▸ stack cuts comments short (BUG · Confirmed · Medium)
### VX-731 — Takes ▸ slot split and carousel show no comments (BUG · Confirmed · Medium)
### VX-728 — Compare shows block comments (ruled YES, R-770-2 · Improvement · Medium)
One family: the gutter contract on the board surfaces. Stack truncates; slot split and carousel
render none; Compare renders none (`CompareBoardView.swift`, `CompareModels.swift`,
`PaneSurface.swift` read no comments today — the ticket's code read). Write's gutter is the
reference rendering. Build on the EXISTING gutter/decoration machinery (P-3); the prose column's
measure and left edge never move (pinned per surface — add the pin where the surface lacks one);
comment reads scale with rows drawn (P1). Adjacent sibling for the walk's eye only: VX-696 (the
Write gutter's own one-comment truncation — NOT a member; don't fix, don't regress).
**Acceptance:** per-surface pins (stack shows whole text; slot split + carousel + Compare render
the gutter) red-on-old by revert; the measure/left-edge pin; the walk sees comments whole on all
four surfaces in both voices.

### VX-732 — ⌥⌘Z on an AI's comments: "Undid" but the comments stay drawn in Takes (BUG · Confirmed · Medium)
### VX-733 — Takes keeps the open-fan wash after ⌥⌘Z removes the extra takes (BUG · Confirmed · Medium)
The post-undo staleness pair on the Takes board (her recordings, 2026-11-01: comments stayed ~7 s
until a mode switch; the wash survived a round trip and cleared only at "close all"). Hypothesis
space: the board's projections/overlays miss the undo road as a refresh axis (the overlay/sink
delivery law), or the open-fan memory (VX-428's) prunes only at construction so a block whose fan
collapsed keeps its id in `expandedBlocks` and the wash derives from it. TRACE each; the two may
share one mechanism. Mind R-770-1: the fix prunes/refreshes honestly, never by closing fans she
opened.
**Acceptance:** red-on-old pins staging the undo while the board is mounted (comments leave the
gutter; the wash leaves when a block's fan collapses to one take), revert-verified; stay-open
pins stay green.

### VX-758 — books: creation-date sort ignores undated notes (BUG · Confirmed · Medium)
Her words above, verbatim in the header. Trace where the book's date sort consults `entry_date`
and leaves undated notes unordered; the expected contract: **a note without an entry date sorts
by its `created_at`** (the fallback), so the sort always orders every note. Reading.sort_field's
'created_at' arm and the book read-side sort are the suspects; state the traced truth here before
fixing (if the bug is actually the 'entry_date' sort's undated pile, say so and fix to her
sentence — the fallback). Headless state-transition pins on the sort (dated + undated mix).

### VX-739 — bottom-bar word count one high after a second take flip (BUG · Confirmed · Medium · EDITOR SEAM · TRACE FIRST)
Bounded at VX-736's ladder: PRE-EXISTING; the count rides `adoptSurfaceTextMap` /
`publishPostWordCount` (`EditorViewModel.swift:995–1005`) and the caret live-count arm
(`:3845–3850`); root SPECULATIVE — likely a live-count vs adopted-count disagreement over the
same shown text (tokenization or a stale live entry). TEXTKIT2_NOTES binds (the frame-constant
display-pass class VX-702/VX-729 is adjacent — the badge road is already fixed; this is the
counter's own listener). Build the pin first (the flip-twice shape); red confirms, green means
record-only (the hallucination guard's SPECULATIVE arm).

### VX-638 — slot split: pager label stale after close all → expand all (BUG · Confirmed · Low)
"2–3 of 3" over cards 1–2; a mode round-trip corrects. Likely a stale per-key page offset in
`TakesBoardLayout` reused across the close/expand cycle (within ONE mount — pre-existing, not
VX-428's). State-transition pin on the layout's page-offset table.

### VX-652 — Lenses "+ column ▾" menu opens past the window's right edge (BUG · Confirmed · Low)
At the old 1240-pt default; the default window is 1270 since VX-737 — re-check the repro at
today's default first, fix the menu's anchoring/edge behavior, pin where the harness can reach
(geometry oracle or source pin), else the walk's eye.

### VX-634 — "Undid: Delete Variant" → the app says "take" (WORDING · Confirmed · Low)
The structural undo receipt's label (the label-fence precedent). One wording fix + the fence pin;
sweep the undo-label table for any sibling "Variant" while in there (report, don't expand scope).

---

## The batches (one acceptance unit per implementer session; strictly sequential)

- **BATCH 1 — THE FLAGSHIP: VX-756** (trace → fix → pins + the landing proof). Required reading
  named in the brief: this file's header + VX-756 section + environment traps;
  `notes/TEXTKIT2_NOTES.md` IN FULL; SurfaceContracts' The note (Takes) bullets; the vx-601
  record's VX-428 section + batch B record (lines ~94–115, ~1315–1530).
- **BATCH 2 — COMMENTS ON THE BOARDS: VX-730 + VX-731 + VX-728.** The gutter family; P-3/P-8.
- **BATCH 3 — THE POST-UNDO STALENESS PAIR: VX-732 + VX-733.** May share one mechanism; trace
  first; R-770-1 guard.
- **BATCH 4 — THE COMPARE PAIR: VX-757 + VX-740.** The flicker repro + the traced dedupe
  (P-770-1).
- **BATCH 5 — SINGLES: VX-758 + VX-739 + VX-638 + VX-652 + VX-634.** Per-member pins; VX-739's
  pin-first SPECULATIVE discipline.

Gates per batch: `swift build`/`swift test` headless freely; Mac suites (stage-gated via
nov3coordinator) cover every suite exercising the batch's changed SOURCE files + the acceptance
spine `TutorialWalkTests`. Then ONE ladder over the whole diff (`fable-reviewer`, fresh per
round, REVIEW_PROMPT verbatim; cap three rounds), the use walk (content-only, both voices, an
OPUS walker under the claim — Fable never drives live pointer walks, her standing safeguard),
closeout. Any member the night can't finish closes out honestly: re-owned at closeout, never
rushed (members are sub-issues; they close one by one).

## The ledger (every row owned; statuses live here)

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | VX-756 flagship trace + fix | Batch 1 | BUILT — traced (994fa8877), pin (9e8955f9b), fix (91554271e); red/green + walk PENDING the window |
| 2 | VX-730 stack comments whole | Batch 2 | BUILT — seam 2dfd4a4a0, shared machinery 20773ef07, pins 1c4c21d8c, fix 9a02527ea; red/green + walk PENDING the window |
| 3 | VX-731 slot split + carousel comments | Batch 2 | BUILT — the face rides the row (slot split); carousel: both roads fixed + pinned, note (a)'s verdict PENDING the red run |
| 4 | VX-728 Compare comments (R-770-2) | Batch 2 | BUILT — P-770-3 (option B, PROVISIONAL): the width-only lane, the live feed, the shared face; red/green + walk PENDING; the taste cost to her bundle |
| 5 | VX-732 undo leaves comments drawn | Batch 3 | NOT STARTED |
| 6 | VX-733 undo leaves the fan wash | Batch 3 | NOT STARTED |
| 7 | VX-757 track-paragraphs flicker | Batch 4 | NOT STARTED |
| 8 | VX-740 double outline column (P-770-1) | Batch 4 | NOT STARTED |
| 9 | VX-758 created-sort fallback | Batch 5 | NOT STARTED |
| 10 | VX-739 word count (pin-first) | Batch 5 | NOT STARTED |
| 11 | VX-638 pager label | Batch 5 | NOT STARTED |
| 12 | VX-652 lenses menu edge | Batch 5 | NOT STARTED |
| 13 | VX-634 "Variant" wording | Batch 5 | NOT STARTED |
| 14 | The ladder (whole diff, fable-reviewer) | Orchestrator | NOT STARTED |
| 15 | The use walk (content-only; Opus walker) | Orchestrator | NOT STARTED |
| 16 | Closeout (canon deltas if any · tickets triaged · QUESTIONS bundle · handoff · merge) | Orchestrator | NOT STARTED |

## Environment traps (every batch brief carries this section verbatim)

- Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test
  host matches mid-run). Real-store instances by STORE, never quit/kill one; no Release builds or
  `/Applications` refreshes (NONE this run — her word, no release; the coordinator owns any
  post-merge refresh).
- Mac tests from `App/Variorum/`: `xcodebuild -scheme Variorum -destination 'platform=macOS' test`
  with suite-level `-only-testing`; confirm the "Test run with N tests" line; Swift Testing's
  count INCLUDES skipped tests — read the `skipped:` lines. `build-for-testing` compiles without
  running. NEVER add a custom build configuration. zsh `pipestatus`.
- **THE STAGE (nov3coordinator's protocol — binding; only the ORCHESTRATOR talks to the
  coordinator; subagents relay through it):** every `xcodebuild test` run, walk, Debug launch and
  dev-store act runs REQUEST → READY → GO; a FREE stage is never an invitation; RELEASE is
  `Tools/stage release --who <claim>` plus one result line giving EXECUTED test counts, dev-store
  posture, instance + sim state. Tell the coordinator BEFORE renewing. Headless
  `swift build`/`swift test`/`build-for-testing` never need the stage. VX-500 holds the stage to
  ~05:36; our suite sets are 30–45 min and slot into its seams at the coordinator's GO.
- **The dev store this run:** CONTENT is ours to manage freely (her standing rule — no as-found
  keep-lists); NO credential or posture change (no Castle, no keys, no reset — decided at
  kickoff); the Debug app NEVER signs into her real account, resting posture signed out, nothing
  presses Resume Sync. After any Debug launch, dismiss a What's New sheet if one shows. If Debug
  prefs are imported, re-export and diff against the pre-window export (`defaults import` MERGES).
- **The defaults domain:** `io.lduarte.Variorum.debug` held ~594 keys at kickoff; past ~2,700
  `TakesEntryBandTests` goes red machine-wide. An unexpected TakesEntryBandTests red ⇒ suspect
  the domain FIRST, tell the coordinator; never chase it as the diff's.
- **Disk:** 61 GiB free at kickoff; per-batch DerivedData runs 9–20 GB — delete a batch's dirs
  once later rebuilds supersede them; under ~40 GiB the coordinator asks for drops.
- Walks: `cliclick` + `Tools/WalkKit/` on the DEV-STORE Debug build only
  (`io.lduarte.Variorum.debug`), under this run's held claim — **pointer-injection walk steps are
  driven by an OPUS walker under the claim** (Fable trips the classifier; her standing
  safeguard); `pbcopy` in walks is allowed (her word); `Tools/WalkKit/README.md`'s driving
  lessons first; screenshots in gitignored dirs.
- Two sibling efforts are in flight (VX-500 — Sync/, stage-primary; VX-771 — MCP): all work from
  THIS worktree only; `~/dev/variorum` stays main; shared ledgers only at merge moments by the
  merging session; the capability registry is the one VX-771 contact point (flag the orchestrator
  before declaring any capability). A `Shared/` file entering the diff is reported to the
  orchestrator the same turn (the phone-suites rule would bind).
- Commit per piece, push after every commit, NO attribution trailers (her rule). LIVE STATUS from
  the first commit; records before final verification carry PENDING. Foreground waits only for
  subagents (poll `grep -q … && break; sleep 5`, never `tail -f | grep -m1`). Never
  `git checkout` over uncommitted work; commit before any behavioral revert.
- TextKit 2: never touch TK1 APIs; attribute stamps clamp to the VERDICT's range; a frame read
  with `options: []` is a position only in `.layoutAvailable`; `usageBoundsForTextContainer` is a
  high-water mark (`PaneMeasurement` is the one measurement brain); a frame-constant storage edit
  never runs the text view's display pass on 27.0.1 (the VX-702 class — make the pass certain);
  never force layout from a mid-document location on a whole-post surface; a `@MainActor` test's
  nested run loop runs NO main-queue hop (await instead). `notes/TEXTKIT2_NOTES.md` is required
  reading for batches 1, 3 and 5 (VX-739), and any batch that touches pane geometry.

---

## BATCH 1 RECORD — VX-756, the takes-open mode-switch landing (implementer: opus-implementer, 2026-11-04)

**NOT DONE (first line, kept current):** every mounted red/green claim below is a PREDICTION until the
orchestrator's suite window (this session is headless — no `xcodebuild test`, no app launch, no
stage); the use walk (her repro by hand, both voices); the cold ladder.

**LIVE STATUS**
| piece | state |
|---|---|
| Reading (this file whole; TEXTKIT2_NOTES in full; SurfaceContracts › The note; the vx-601 VX-428 section + batch B record; the SessionResiliencyProtocol) | DONE |
| Trace (code read + the unified log's measured landing stories) | DONE — written below, before any code |
| Red-on-old pin (`TakesSeededEntryLandingTests/openTakesEnteredOnAnotherBlockLandOnceAndStay` ×4 styles, in `TakesExpansionMemoryTests.swift`) | DONE (this commit) — compiles on the pre-fix tree (`DerivedData/vx756-post` build-for-testing, log `App/Variorum/DerivedData/logs/vx756-pin-build.log`); red PENDING the window |
| Fix (`TakesArticleScroll.reaimWhereTheColumnReEstimated` + its three bookkeeping fields; the report road calls it) | DONE (this commit) — `DerivedData/vx756-post` build-for-testing GREEN (log `App/Variorum/DerivedData/logs/vx756-post-build.log`) |
| Build-for-testing: `App/Variorum/DerivedData/vx756-post` (HEAD, 91554271e) and `vx756-rev` (the behavioural revert, built from an APFS clone in its own path — its rpaths are its own) | DONE — both TEST BUILD SUCCEEDED (logs `DerivedData/logs/vx756-post-build.log`, `vx756-rev-build.log`). (A `vx756-pre` clone of the pin build was made and deleted: its test bundle's rpath pointed into `vx756-post`.) |
| Red/green runs, the P-8 numbers | PENDING (the orchestrator's window) |
| READY-FOR-SUITES, prediction table, P-8 note, residue, walk rows, self-assessment | DONE (this commit) |

**No revert is in flight — the source is HEAD** (the behavioural revert ran 02:27–02:31: `if true { return nil }` atop `reaimWhereTheColumnReEstimated`, built into `DerivedData/vx756-rev`, then restored by `git checkout --`; restore verified: `git diff` empty, sha256 `6219818b…56f2` = the committed fix = the `scratchpad/vx756-b1-prerevert/` copy, no `VX756-REVERT` marker anywhere).

### THE TRACE (written before the fix)

**Her shape, as the code runs it (the app's order: a bare model, the projection from the view's
`.task`).** Showing 1: the entry ring lands on block X and records X as this board's current row
(`TakesViewModel.landAuthorityFocus` → `rememberArticleCurrentBlock`, `TakesViewModel.swift:2876-2880`);
she opens fans (the open set goes to `EditorRouter.takesExpandedBlocks`); the page she leaves is
remembered as a row (`takesArticlePlaces`). Write: her caret moves to block Y, so the note's current
block is Y. Showing 2:
1. `TakesBoardView.init` seeds the open fans before the first body (`TakesBoardView.swift:188-206`,
   `TakesViewModel.openExpansionMemory`) — VX-428's contract, holding: the article's rows are born
   with the fans she left open drawn.
2. The first geometry (empty column) reads the memory (`consumeArticleGeometry`'s `.undecided`
   branch, `TakesArticleScroll.swift:1366-1395`). The projection lands; `consumeLandings` rings Y and
   lands the ENTRY on Y (`TakesChoreographer.swift:196-225`); `landArticle` consults the resolver,
   and because Y ≠ X R-Q20 settles the restore at once (`TakesArticleScroll.swift:345-347, 397-407`,
   `landingOutranks` `:468-474`). **The contract's precedence HOLDS in the code**: the remembered
   page never places this page (the one pre-projection restore aim the first geometry issues is at
   an id the empty column does not hold — the code's own recorded no-op, `TakesArticleScrollTests`
   `theLandingOutranksAMoveToAnotherBlockButNotAPlainRoundTrip` arm (d)). So hypothesis (a) — the
   double move — is NOT this road's mechanism by the code; the new pin records the page's whole
   trajectory, so the window can falsify that reading if it is wrong.
3. The page therefore starts where a fresh mount starts — the TOP — and the entry landing alone must
   carry it to Y. Its FIRST decided step fires at the column's FIRST row report
   (`TakesBoardView.swift:800-808` → `articleLandingReport` → `articleLandingStep`,
   `TakesArticleScroll.swift:716-771`) — with ONE row realized (the signposts' `derived = rows − 1`)
   — and issues ONE `scrollTo(Y, .bottom)` (Y unrealized → the shipped edge; `bandedSecondAim`
   armed for Y's report AT that edge).
4. **The lazy column places an unrealized row by ESTIMATING the rows above it from the rows it has
   realized** — and the seeded fans make those rows bimodal: a closed block is one paragraph, an
   open one is the paragraph plus its fan's cards. So the estimate the first aim rides is wrong by a
   factor, and it SWINGS as the realized window moves between open and closed rows, re-basing the
   page under the landing.
5. From then on the landing has exactly one way to correct: the watch, from QUIET
   (`LandingPolicy.takesArticle`: `.spacedByTheHold`, ≥ 0.25 s up to the 1 s hold, budget 3 —
   `LandingAuthority.swift:287-291, 294-299, 381-417`). Once watched, every report is only a report
   (`articleLandingReport`, `TakesArticleScroll.swift:801-830` — U2's rule), and the band's second
   aim fires only if Y happens to report exactly AT the shipped edge, which a re-based page does not
   give it. So the page comes to rest off home, holds still for the quiet interval, and then HOPS —
   a second visible landing half a second later (and up to three). That is her "jumps around".
6. **Why the plain round trip on the same seeded board is calm, and why the existing pins are
   green.** With the SAME block, the restore runs (R-18l-13's ride-through), and the restore
   re-aims its absolute anchor on EVERY geometry report inside the storm and then HOLDS
   (`restoreStep`, `TakesArticleScroll.swift:1420-1483`, bounded 24, refilled at the hold) — it
   converges inside the layout storm, and the ride-through entry then finds Y home and asks for
   nothing. Her shape is the ONE road where the page must travel from the top through the seeded
   column on the landing's single aim. VX-428's landing pin
   (`anEntryLandingStillReachesAFarBlockWithFansOpenAboveIt`) stages that same road (a fresh
   session: no memory, so the landing "outranks" trivially) but asserts only the END state — the
   block on screen — so the hop never fails it.
7. **Why it is new with VX-428:** before it, a remounted board was always all-closed, the rows
   homogeneous, the first aim's estimate right, and a far entry landed with ZERO hops — the bar
   `TakesEntryBandTests.aFarEntryRestsTwoLinesAboveTheFootNeverAtTheEdge` pins
   (`articleLandingCorrections == 0`).

**Measured evidence (the unified log — the Debug test host's own landing signposts and DEBUG
stories, `/usr/bin/log show … category == "landing"`, pid 82840 = the 2026-11-02 VX-736 suite run;
her real app's lines are not retained, so none of hers).** VX-428's own landing pin, its four arms
(24 blocks, 8 fans open above the far block, the far block last; argument order stack · margin grid
· slot split · carousel), at 07:21:52–57:
- stack — `LAND total=5210 derived=23 | content=5190 | 2121 | 5190 | 5386 | 5984 | 6056 | HOP 1 at
  551 ms (top was -37.0) | content=5244 | settled after 1 hops`
- margin grid — `LAND total=8285 derived=23 | content=8265 | 2786 | 8265 | 8325 | HOP 1 at 607 ms
  (top was -38.5) | content=7411 | settled after 1 hops`
- slot split — `total=3835 | 3815 | 1913 | 3815 | 4095 | 4858 | 4911 | 0 hops`
- carousel — `total=4085 | 4065 | 1958 | 4065 | 4540 | 5670 | 5775 | 0 hops`

The seeded column's height swings by ~60 % and back inside ONE landing in every style (the
estimate re-basing as the realized window crosses open/closed rows), and the default style (stack)
and margin grid land OFF home and hop ~0.55–0.6 s later. The unseeded baseline of the same suite
family, the same night: `aFarEntryRests…` (60 blocks, entered on 41) `content=2714 | 3110 | 3134 |
3811 | settled after 0 hops` — growth only, no swing, no hop. The class is already on record for
UNEVEN columns: U2's 260-block synthetic (40 short lines, long paragraphs below) — `HOP 1 at 477 ms
(unreported)` in the same log; VX-428's seed makes every note with open fans an uneven column at
mount time.

**What the trace does NOT settle (stated, for the window):** the harness cannot show me the
on-screen picture of the swing itself (only the content heights and the hop); the new pin prints
the page's and Y's per-turn trajectory (`VX756-TRACE` lines) so the window's red run shows every
movement of her shape on the pre-fix tree. Hypothesis (c) — a TK2 amplifier — is not this road: the
swing is the SwiftUI lazy column's estimate, and the article's panes never force layout from a
mid-document location (TEXTKIT2 §3, VX-246 — the read panes are per-block text views).

**THE FIX'S SHAPE, decided from the trace (no product decision — the contract already says "one
settled landing", the band, and the outrank):** the entry landing that starts from the mount's top
(it outranked the memory, or there was none — never the ride-through entry, whose page the restore
owns) re-aims INSIDE the storm the way the restore does: each change of the column's content height
— the estimate re-basing — earns at most one re-aim, spent on the first report after that change
that finds Y off home (blind for an unrealized Y, the restore's own road; for a realized Y only on
a frame reported AFTER that change), through the ONE step (`articleLandingStep`), bounded by the
restore's own pocket (24) inside the step's 64-aim fence. That is U8's own principle for the band's
second aim ("the same layout storm, not a quiet interval later, so the landing reads as one
motion"), generalised from "one aim at the edge report" to "the re-based row, re-aimed at the
event". The watch stays the backstop. Nothing about the seed, the prune, the restore, the resolver,
the band or the flash changes; no second mechanism (P-3): the step is the one aim, the watch the one
lifetime. U2's measured failure (per-ROW-report re-aims spent 64 aims in ~70 ms) is excluded by
construction: at most one aim per content-height change.

### AS BUILT

- **The pin** (9e8955f9b) — `TakesSeededEntryLandingTests/openTakesEnteredOnAnotherBlockLandOnceAndStay`
  ×4 fan styles, in `App/Variorum/VariorumTests/TakesExpansionMemoryTests.swift` (it shares VX-428's
  `ExpansionWorld`). Her shape, both showings on the APP's road (bare models: `TakesBoardView.init`
  seeds, the projection arrives on the view's `.task` after the first layout): 40 blocks, the
  note's opening (blocks 1–12) with no takes, then every other block with a second take; showing 1
  entered from Write on block 35, expand all, left on a row; Write moves to block 25 (takes);
  showing 2 recorded from its first turn for up to 6 s (or 0.6 s past the landing's end). Asserts:
  the ring on block 25; the restore settled (R-Q20 — the landing outranked); the landing aimed and
  ENDED; **`articleLandingCorrections == 0`** (no watch hop — the bar `aFarEntryRests…` already pins
  for an unseeded note); **no move of her block after it has held still for 0.25 s**
  (`movesAfterARest` — the observable "intermediate jump"); her block's top on the page at the end;
  DEBUG: the story ends `DONE: settled at top=0.0` (home in the entry band, the brain's own
  residual); **R-770-1: the board is born with the takes open and they are still open at the end**.
  It prints `VX756-TRACE` (per-turn offset · content height · her block's viewport top · aims ·
  hops, on change), `VX756-SUMMARY` (aims, hops, restore aims, later moves) and `VX756-STORY` (the
  landing's DEBUG story) — the window's red run IS the mechanism's on-screen record.
- **The fix** (91554271e) — `App/Variorum/Variorum/Features/Takes/TakesArticleScroll.swift` only:
  `reaimWhereTheColumnReEstimated` (called from the watched branch of `articleLandingReport`, after
  the watch hears the content change) + three per-landing fields (`landingJudgedContent`,
  `landingStormAimsLeft` = `articleRestoreAttempts`, `landingTargetFrameContent`), stamped at the
  step's aim, the band's second aim, `beginWatch`, and the target's own moved-frame report; reset in
  `landArticle`; the report road's doc names its two in-storm exceptions in place. Zero changes to
  the seed, the prune, the restore, the resolver, the band, the flash, the watch/policy, any view,
  any operation, schema, `Sync/`, `Shared/`, `PaneSurface`, `EditorTextView`, `BlockRangeIndex`,
  the capability registry. No TK1 API, no attribute stamp. **MOBILE PARITY: nothing
  mobile-visible** (the Mac Takes board only).

### THE PREDICTION TABLE (the red run FLIPPED 2026-11-04 02:37, the orchestrator's window `vx-770-tests-b1`; post rows pending tier 1)

**THE RED RUN (vx756-rev, log `App/Variorum/DerivedData/logs/vx756-red-run.log`): RED ON ALL FOUR
STYLES — stronger than predicted** (rows 3–4's uncertainty resolved red: her 40-block shape hops in
every style where the old 24-block shape hopped only in two). Executed shape confirmed: "Test run
with 1 test in 1 suite failed … with 4 issues", the expectation `second.articleLandingCorrections == 0`
failing per style. The four summary lines (the on-screen evidence the trace called for):
`VX756-SUMMARY style=stack aims=3 hops=1 restoreAims=2 laterMoves=[]` ·
`style=marginGrid aims=2 hops=1 restoreAims=2 laterMoves=[]` ·
`style=slotSplit aims=3 hops=1 restoreAims=2 laterMoves=[]` ·
`style=carousel aims=3 hops=1 restoreAims=2 laterMoves=[]` — exactly one watch-correction hop per
style, no later motion: the traced mechanism, on her shape, in all four styles. **The finding is
CONFIRMED, not hollow; rows 1–4 red on rev.**

| # | Test | `vx756-rev` (fix reverted) | `vx756-post` |
|---|---|---|---|
| 1 | `TakesSeededEntryLandingTests/openTakesEnteredOnAnotherBlockLandOnceAndStay(style: .stack)` | **RED (ran 02:37)** | **GREEN (tier 1, 02:43)** |
| 2 | `…(style: .marginGrid)` | **RED (ran 02:37)** | **GREEN** |
| 3 | `…(style: .slotSplit)` | **RED (ran 02:37)** — the uncertainty resolved red | **GREEN** |
| 4 | `…(style: .carousel)` | **RED (ran 02:37)** — as #3 | **GREEN** |

**THE WINDOW'S VERDICT (the orchestrator, claim `vx-770-tests-b1`, 02:36–02:45): VX-756 is FIXED
by the red/green standard** — red on all four styles on the revert, green on all four on HEAD,
"Test run with 382 tests in 51 suites passed after 372.819 seconds with 2 warnings and 1 known
issue" (51 of 51 requested suite types executed; log `App/Variorum/DerivedData/logs/vx756-tier1.log`).
Rows 5–7: GREEN (the VX-428 family, the landing/restore family, the board family, the tutorial
spine all passed). The skips: one deliberate capture-harness suite ("Margin grid captures
(VX-136)", trait-gated — the known shape). The 1 known issue: `TakesFindBoardTests.
escWithNoBuiltPaneForTheRingIsANamedBoundary` — the PRE-EXISTING R1-M1 (b) honest boundary
(QUESTIONS #157 (7)), fired as designed; not this diff's. Observations for the record: (a) the
log's find-board landing story shows `hops=1` on a FIND-road landing on post — that is residue
R-756-2's class, deliberately outside this fix's scope (the find step is excluded by design),
observed live; (b) one "[SwiftUI] Modifying state during view update" warning during
`TakesFindBoardTests` ⌘G — provenance unknown (these suites were green at VX-736's gates too),
recorded not chased; the ladder's reviewer can weigh it. P-8: `VX428-MEASURE` seed 1.6–3.4 µs
across the shapes — inside batch B's measured 1.2–4.0 µs bar; open-below-fold realizes what
closed does (article=19 cards=0). Remaining for VX-756: the use walk (W1–W4) and the ladder.
Trees `vx756-rev`/`vx756-post` deleted after this flip (logs kept).
| 5 | the VX-428 family (`TakesExpansionMemoryTests`, `TakesExpansionRemountTests`, `TakesSlotSplitExpandAllTests`) | G | G — the stay-open memory is untouched |
| 6 | `TakesExpansionCostTests` | — | G, with its `VX428-MEASURE` lines (the seed's numbers must match batch B's: seed 1.2–4.0 µs; 25 fans below the fold realize what 0 do) |
| 7 | the landing/restore family (`TakesArticleScrollTests`, `TakesArticleWatchTests`, `TakesEntryBandTests`, …) | G | G — predicted; the risk is named in the self-assessment |

**Reading the runs:** rows 1–2 red on rev and green on post = the row is FIXED. Rows 1–2 GREEN on
rev = the harness does not reproduce her hop on this shape → the row is NOT dismissed (her report
is Confirmed; VX-428's own pin measured the hop) — the trace lines say what the page did, and the
pin is re-shaped from them (e.g. VX-428's own shape: fans above, the far block last), never the fix
widened blind. Any row-7 red on post: read its story first — the fix's only new act is an aim inside
the storm.

### P-8 — the fix stays viewport-proportional (the note the brief asks for)

The seed is untouched, so VX-428's measured bar stands as measured (batch B, an unshared machine:
seed 1.2–4.0 µs in all twelve shapes; 25 fans open below the fold realize exactly what 0 do — 19
article panes, 0 cards — and 25 at the top one viewport's worth); `TakesExpansionCostTests` on post
re-prints it. The fix's own cost, by construction: per report O(1) (two comparisons, one dictionary
read — and nothing at all unless an ENTRY landing with no restore is pending); the slot order (O(N))
is built only when a re-aim is decided — at most once per change of the column's content height,
at most 24 per landing (the restore's own pocket; the step's existing aims already read the order
the same way) — and every aim is a `scrollTo` the lazy column answers by realizing the viewport
(P3), never the note. The pin's `VX756-SUMMARY` prints the aims each landing spent.

### RESIDUE / NOTICED (not fixed — a line each; the orchestrator's to ticket or drop)

- **R-756-1 (pin strength):** VX-428's `anEntryLandingStillReachesAFarBlockWithFansOpenAboveIt`
  asserts only the end state, and its own 2026-11-02 run hopped in stack and margin grid unseen.
  The new pin carries the motion/hop assertion; that pin is left as written.
- **R-756-2 (the ride-through road, same class, not her shape):** a PLAIN round trip whose
  restored page does not hold her block reveals it from quiet by design (18l-c U8 — "a block off
  it: one reveal, after the quiet"); on a seeded board that reveal crosses the same uneven column
  and could hop. Excluded from the fix deliberately (the restore owns that page); worth one walk
  look.
- **R-756-3 (wasted aims, not a mover by the code):** in the app's order the first geometry, read
  before the projection, spends restore aims on an EMPTY column (`order` nil → `scrollToRow` at an
  id the column does not hold — the recorded no-op). `articleRestoreAims` counts them. The pin's
  trace shows whether the page ever visits the remembered row first; if it does, that is
  hypothesis (a) and its own fix.
- **R-756-4 (diagnostics):** her real app's `landing surface=TakesArticle …` signposts are not in
  the unified log days later (only the Debug test host's are) — the signpost's premise "her store
  reproduces what mine cannot" needs her to read Console near the moment, or a retained log.

### THE USE WALK — batch 1 rows (an Opus walker under the orchestrator's claim; DEV-STORE Debug from `DerivedData/vx756-post`; both voices; never Resume Sync)

A walk note of ~40 paragraphs (quick entry / paste), the first ~10 with no takes, then a second
take (⌘T, edited) on every other block; the as-found `fan_style` read first and restored at the end.
- **W1 (her repro, stack):** Takes (⌘2); expand all; scroll so a block deep in the note is mid-page;
  ⌘1 (Write); click into a DIFFERENT block with takes ~10 blocks above; ⌘2 → **the page lands ONCE
  on that block** (one motion, then still — no second movement half a second later), its fan
  still open, the ring in it. Capture as a short screen recording or a 10-frame burst.
- **W2:** the same in margin grid.
- **W3 (R-770-1 + regression):** ⌘1 ⌘2 with nothing clicked → the page she left, every fan still
  open (VX-428's B1/B2 rows).
- **W4 (R-756-2, look only):** scroll her block off the page in Takes, ⌘1 ⌘2 with nothing clicked →
  the page comes back, then her block is revealed — note whether it hops (a line in the record,
  no fix).

## READY-FOR-SUITES — batch 1 (the orchestrator's window; from `App/Variorum/`)

Both trees are built; run `test-without-building` (no rebuild), array args:
`xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/<tree> test-without-building -only-testing:…`.
Confirm each "Test run with N tests in M suites" line and read the `skipped:` lines; keep the
`VX756-TRACE` / `VX756-SUMMARY` / `VX756-STORY` and `VX428-MEASURE` lines for the record.

1. **THE RED RUN** on `vx756-rev` (≈1–2 min):
   `-only-testing:VariorumTests/TakesSeededEntryLandingTests`
   — expect 4 tests, stack + margin grid RED (the prediction table, rows 1–4).
2. **THE GREEN RUN, tier 1** on `vx756-post` — the pin, the VX-428 family, the landing/restore
   family, the Takes board family, the mode-switch suites, and the acceptance spine (every suite
   type in `TutorialWalkTests.swift`):
   `-only-testing:VariorumTests/TakesSeededEntryLandingTests -only-testing:VariorumTests/TakesExpansionMemoryTests -only-testing:VariorumTests/TakesExpansionRemountTests -only-testing:VariorumTests/TakesSlotSplitExpandAllTests -only-testing:VariorumTests/TakesExpansionCostTests -only-testing:VariorumTests/TakesArticleScrollTests -only-testing:VariorumTests/TakesArticleWatchTests -only-testing:VariorumTests/TakesEntryBandTests -only-testing:VariorumTests/ArticleLandingProjectionArmTests -only-testing:VariorumTests/LandingAimTests -only-testing:VariorumTests/ComfortBandAndFlashTests -only-testing:VariorumTests/RestoreLandingTests -only-testing:VariorumTests/TakesLandingTests -only-testing:VariorumTests/TakesBoardSoakTests -only-testing:VariorumTests/TakesBoardTests -only-testing:VariorumTests/TakesPresentationTests -only-testing:VariorumTests/TakesChooseRingTests -only-testing:VariorumTests/TakesFindBoardTests -only-testing:VariorumTests/TakesStepFollowTests -only-testing:VariorumTests/TakesStepFollowModelTests -only-testing:VariorumTests/TakesParkedFollowTests -only-testing:VariorumTests/TakesLensFilterTests -only-testing:VariorumTests/TakesRoomTests -only-testing:VariorumTests/TakesCardHeightTests -only-testing:VariorumTests/TakesRailPagingTests -only-testing:VariorumTests/TakesSlotDragTests -only-testing:VariorumTests/TakesMarginGridAlignmentTests -only-testing:VariorumTests/TakesMarginGridCaptureTests -only-testing:VariorumTests/TakesArticleRenderTests -only-testing:VariorumTests/TakesEmptyStateTests -only-testing:VariorumTests/TakesEmptyBlockFaceTests -only-testing:VariorumTests/TakeCardDoorTests -only-testing:VariorumTests/TakePaneMeasureTests -only-testing:VariorumTests/TakePaneDurabilityTests -only-testing:VariorumTests/PaneRenderRestoreClipTests -only-testing:VariorumTests/OutsideWriteLivePaneTests -only-testing:VariorumTests/ModeSwitchCarryTests -only-testing:VariorumTests/ModeSwitchFeelTests -only-testing:VariorumTests/CurrentBlockContinuityTests -only-testing:VariorumTests/LandingOffsetTests -only-testing:VariorumTests/TutorialBookShapeTests -only-testing:VariorumTests/TutorialDoorTests -only-testing:VariorumTests/TutorialWritingActsTests -only-testing:VariorumTests/TutorialTakesActsTests -only-testing:VariorumTests/TutorialStructureActsTests -only-testing:VariorumTests/TutorialLookingActsTests -only-testing:VariorumTests/TutorialLibraryActsTests -only-testing:VariorumTests/TutorialDeletionActsTests -only-testing:VariorumTests/TutorialWherePlacesActsTests -only-testing:VariorumTests/TutorialPrivacyChapterTests -only-testing:VariorumTests/TutorialFannedMatrixTests`
   — 51 suite types, all green expected. Known load-dependent flakes that are NOT this batch's if
   met: VX-337's two (`TakesArticleScrollTests.aShortRowStraddlingTheFoldComesBackAboveIt` among
   them — run it alone before reading anything into it). An unexpected `TakesEntryBandTests` red:
   suspect the defaults domain first (the environment traps).
3. **Results** land in this record's prediction table (rows flipped from PENDING), with the trace
   lines of the red run copied under THE TRACE as its on-screen evidence. Then the DerivedData
   dirs (`vx756-post` 2.8 GB, `vx756-rev` 3.1 GB) may be deleted once batch 2 supersedes them.

## SELF-ASSESSMENT — batch 1 (the first of the two reviews — the implementer's)

- **What was traced, and how far.** The road is code-traced end to end (the resolver, the first
  decided step, the report road's U2 rule, the watch's pacing, the restore's contrasting cadence)
  and the hop is MEASURED — but on VX-428's own pin's shape (fans above, the far block last, the
  harness order), read from the unified log, not on her exact shape. Her exact shape is what the
  new pin stages; its red is a prediction. The on-screen picture of the storm's swing (what her eye
  sees between the first aim and the hop) is not observable headlessly; the pin's trace is built to
  show it.
- **Why this fix and not another.** It changes the one thing the trace says is wrong — the
  landing's cadence when no restore converges the page for it — and nothing the contract rules: the
  outrank (R-Q20), the band (U8), the ride-through (R-18l-13), the seeded set (R-601-2/R-770-1). The
  alternatives were weighed and refused: re-targeting the RESTORE at the landing's row (it would
  rewrite the restore's byte-preserved half and its top-anchored `ArticlePlace` cannot express the
  band's foot without the row's height); a curtain hiding the board until the landing settles
  (product behaviour nobody ruled); delaying the seed's blooms (breaks the contract line).
- **What could regress, and why I think it does not.** (1) *Extra aims on unseeded entries:* a
  re-aim needs a content-height change since the last judgment AND the row off home on fresh
  evidence; where the old road settled with 0 hops the row is home after the storm, so the new road
  adds at most a re-aim the band's second aim or the watch would have made. (2) *Jitter from a
  transient frame:* a realized row is judged only on a frame reported after the change — but a
  frame can still be a mid-measure transient (placeholder → measured); the next change re-aims it
  home, inside the same storm. If the window shows a page that moves MORE on post, this is where to
  look. (3) *U2's per-report failure:* excluded — at most one aim per content change, pocket 24.
  (4) *The pure-board pins* that drive `articleLandingReport` (`anUnrealizedTargetIsAimed…`,
  `aBloomWaitingOnARestore…`, `aRestoreWithNoLandingWaiting…`) were traced line by line: none
  changes content between judgments, a bloom is excluded by kind, so their answers are unchanged.
- **Risks I see.** (a) The pin is new and unrun: its motion judge (`movesAfterARest`) could
  misfire on a style whose card heights settle late (margin grid, slot split — measured heights on
  deferred turns): a late, real move of her block would read as a second landing on post too —
  which would be honest (she would see it), but the window must say which. (b) Slot split and
  carousel may be green on rev (the old shape did not hop there). (c) If rows 1–2 are green on rev,
  the harness does not reproduce her hop on this shape and the fix is unproven — the record's
  reading rule says what follows.

---

## BATCH 2 RECORD — VX-730 + VX-731 + VX-728, comments on the board surfaces (implementer: opus-implementer, 2026-11-04)

**NOT DONE (first line, kept current):** every mounted red/green claim below is a PREDICTION until the
orchestrator's suite window (this session is headless — no `xcodebuild test`, no app, no stage);
note (a)'s carousel verdict waits on that red run; the use walk (W5–W9, both voices); the cold
ladder; the push (refused from this shell — the commits are local until the orchestrator pushes).
`Shared/` is not in the diff.

**LIVE STATUS**
| piece | state |
|---|---|
| Reading (this file whole; SurfaceContracts in full; TEXTKIT2_NOTES in full; the three tickets + VX-696 read on Linear) | DONE |
| Survey: Write's reference, Takes stack / slot split / carousel, Compare, the feeds' cost bounds | DONE (42a38f9e4) |
| B2-F1, the Compare gutter fork | RULED (ac94d7997): P-770-3 PROVISIONAL, option B |
| Takes build plan (T1–T6) | APPROVED (ac94d7997) |
| The seam (`BoardCommentFaceOracle` + the OLD note reporting what it draws; behaviour-neutral) | DONE (2dfd4a4a0) — compiles (the post tree built over it) |
| A — the shared machinery: T1 `BlockDecor.commentFace` + `roomBelowInOwnRow`, T2 `CommentCardView.presentGutterFace`, the per-row host `CommentGutterFace`, `CompareGutter` (P-770-3's lane), the callout emoji's named offset | DONE (20773ef07) |
| B — the pins (`VariorumTests/BoardCommentGutterTests.swift`: 3 suites, 11 tests) | DONE (1c4c21d8c) — red/green PENDING the window |
| C — the behaviour: the Takes host on the row (T3/T4), Compare's lane + live feed + face | DONE (9a02527ea) — `DerivedData/vx770-b2-post` TEST BUILD SUCCEEDED (log `App/Variorum/DerivedData/logs/vx770-b2-post-build.log`) |
| **Behavioural revert** (announced 5dce40456 before it started; ran 03:12–03:18): `TakesShared.swift`, `TakesBoardView.swift`, `CompareBoardView.swift` restored to 1c4c21d8c (= the seam's versions) by `git checkout 1c4c21d8c --`, built into `DerivedData/vx770-b2-rev` (TEST BUILD SUCCEEDED — the pins compile against the pre-fix behaviour), then restored by `git checkout HEAD --` | DONE — **no revert in flight; the source is HEAD**: `git diff HEAD` empty, `shasum -a 256 -c` OK on all three against `App/Variorum/DerivedData/vx770-b2-prerevert/sha256-head.txt`, byte-identical to the prerevert copies |
| `DerivedData/vx770-b2-post` rebuilt at HEAD (a doc-comment edit landed after its first build) | DONE — TEST BUILD SUCCEEDED (`vx770-b2-post-build2.log`) |
| Red/green runs | PENDING (the orchestrator's window — READY-FOR-SUITES below) |
| READY-FOR-SUITES, prediction table, P-8, walk rows, residue, self-assessment | DONE (this commit) |
| Push | after every commit — REFUSED from this session's shell since 2dfd4a4a0 (`Permission denied (publickey)`: no ssh agent here, `SSH_AUTH_SOCK` unset; one `remote: Internal Server Error`); git config untouched; commits local-only until the orchestrator pushes |

### THE SURVEY (written before any code)

**The reference: Write's gutter (one machinery, three pieces).**
1. *The feed* — `EditorViewModel.observeComments` (`EditorViewModel.swift:634-658`): one live
   observation per note of `Queries.containerComments` (`Sources/VariorumCore/Queries/CommentQueries.swift:48-63`),
   which joins the note's live placements: **cost ∝ the note's own comments**, never the corpus.
   It becomes `[blockID: [BlockDecor.CommentBrief]]` (id + text, panel order `(created_at, id)`).
2. *The decision* — pure, in `BlockDecor` (`Features/Editor/BlockDecor.swift`):
   `commentGutterFaces` (:415-442) picks one `CommentFace` per commented block in the viewport:
   a **card** when the gutter (`textLeft`, the prose container's left edge) is ≥ 150
   (`gutterFitsCards`, :470), width `min(210, textLeft − 28)`, height = the block's text height
   + 24 bounded by the next commented block's face top − 6 (`leftCardRect`, :498-510, R-VX179-2);
   else a **badge** (`commentBadgeRect`, :314-321, ≥ 19 pt of room); else **yields** (nothing
   drawn — 13u3 A1, "the one law's other side"). The face's top is the block's first line, or
   under the callout glyph (`commentFaceTop`, R-13u3-3's stack).
3. *The face* — `CommentCardView` (`Features/Editor/CommentCard.swift`), an AppKit overlay
   subview presented by `BlockDecorOverlayController.renderComments` (BlockDecor.swift:883-954):
   every comment its own wrapping entry (no line cap), hairline separators, an inner scroll when
   the entries outgrow the card, the card one door to the comments panel (R-VX179-1). Hosts: Write
   (`EditorView.swift:502/694`, full doors) and the read tier (`ReadPostView.swift:206`, quiet
   doors) — the read tier is the precedent for "a second HOST of the one machinery".
   The prose column itself is `ProseGutter`'s (`Surface/ProseGutter.swift`): a pure function of
   the surface's width, which no decoration can write.

**Takes (all four fan styles) — a SECOND mechanism, not Write's.** The article draws comments
with its own SwiftUI view, `CommentMarginNote` (`Features/Takes/TakesShared.swift:789-863`, born
Batch 14, db43f48bf), overlaid on the article CELL (`TakesBoardView.swift:1222-1228`, inside
`washedCell`, :1152-1255). Its feed is a one-shot per-row read (`Queries.blockComments` on
`.task(id: blockID)`, re-read only when its own popover closes) — **cost ∝ rows drawn** (the
LazyVStack realizes the viewport), and **never live**: a store change does not re-read it (that
staleness is VX-732's class — batch 3's; this batch must not change it silently).
- **VX-730, stack — CONFIRMED by code read: the truncation.** The note shows ONLY the first
  comment (`comments.first`, :806), capped at **`.lineLimit(4)`** (:823) in a column at most
  150 pt wide (`noteWidth = min(150, max(commentRoom − 16, 24))`, TakesBoardView.swift:1160),
  with "+N more" standing for every other comment (:825-829). Write shows each comment whole as
  its own entry. Under 90 pt of margin (`compactNote`, :1159) it degrades to a chip that prints
  `commentPrefix` + the count — and **in Study the prefix is ""** (`Shared/Theme/VoiceTokens.swift:375/412`),
  so a ONE-comment block's chip prints the empty string: an invisible face (style-independent;
  a second "shows nothing" road, any style, Study, narrow margin).
- **VX-731, slot split — CONFIRMED by code read: the gutter is ABSENT.** A bloomed fanned row in
  slot split REPLACES the article cell with the split cards (`articleRow`, TakesBoardView.swift:
  1053, 1056-1062: `if !splitBloomed { washedCell(…) }`), and the comment note rides the cell —
  so every open fan in slot split (expand-all, or follow-the-scroll) draws no comment at all.
  Unbloomed rows in slot split still draw the (truncating) note.
- **VX-731, carousel — NOT REPRODUCED BY CODE READ.** The carousel bloom keeps the cell
  (`carouselBloom` sits UNDER `washedCell`, :1072-1074), so by the code the note draws exactly as
  in stack, open or closed. No carousel-specific road to "none" was found (the overlay is applied
  after the cell's `clipShape`; nothing clips the margin; `commentRoom` is style-independent
  except for margin grid's engaged rail). The candidates that would make her see nothing in
  carousel are style-independent: the Study empty chip above, or a margin under 24 pt. The pin
  plan below carries a presence oracle so the window's red run SAYS whether the old tree drew a
  face in carousel; a presence-green there means carousel's "none" is hollow in the harness (the
  truncation half stays red, VX-730's mechanism).
- The prose's left edge on Takes is the article column's + `articleTextLeadingInset` (2 cell
  padding + 6 container inset, TakesBoardView.swift:1020-1030), the column centred so the left
  whitespace is `commentRoom = (boardWidth − articleMeasure) / 2` (:746). No pin today asserts
  that a comment face leaves it unmoved (the old note is an overlay, so it does not move it).

**Compare (VX-728) — no comment read anywhere, and NO GUTTER.** Confirmed: `CompareViewModel.read`
(`Features/Takes/CompareBoardView.swift:351-389`) reads renderPost/activeFans/title/header per
column post and nothing about comments; `CompareCellView` (:1966-2088) draws `rail (4) · ⠿ ·
[⑂n] · PaneSurfaceView`, nothing else. The columns are equal-width `maxWidth: .infinity` cells in
an 8-pt-spaced `HStack` inside the board's 12-pt inset (:1688-1753): **the prose fills the
column**; the only room left of a cell's prose is its own chrome strip (rail 4 + 4 + the ⠿ at
11.5 pt ≈ 7–8 + 4 ≈ 19–20 pt) plus the pane's 6-pt container inset, so `textLeft` ≈ 25–26 pt in
cell coordinates. Fed to Write's own ladder that is a BADGE of ~20 pt at x ≈ 2 — standing ON the
lineage rail and the ⠿ handle; there is no whitespace there to stand in. Column widths at the
1270-pt default (1030-pt board): 2 columns ≈ 499 pt each, 3 ≈ 330, 4 ≈ 245.

**VX-696 (Write's own truncation — NOT a member; a line only).** SHARPENED by code read: it is
VX-179 U2's inner-scroll card bounded at the block's text height + 24 (R-VX179-2,
`leftCardRect`), whose overflow is advertised only by an overlay scroller FLASH at first present
(`CommentCard.swift` `layoutCard`, `flashPending`); on a short block the first entry is clipped
by the scroll viewport mid-line (no ellipsis — it is a clip, not a truncation) and the second
entry sits below the viewport (no "+1" — the face has no count when it is a card). Not fixed.
**Consequence for this batch, stated:** if Takes adopts Write's face (the plan below — P-3), Takes
inherits exactly this face on SHORT commented blocks, and inherits VX-696's eventual fix with it.
On her VX-730 sighting's shape (paragraph blocks) Write's card shows the comments whole, which is
what the stack pin stages.

### B2-F1 — THE COMPARE GUTTER FORK (returned to the orchestrator; NOT built)

The contract line: comments render *in the whitespace gutter outside the text area on every
surface, stacked vertically, and the prose column's measure and left edge never move for a
decoration*. The machinery's literal answer for a surface with no gutter is **yields** (nothing
drawn); R-770-2 says **show them**. Compare has no whitespace gutter, so showing them needs either
a face in Compare's existing chrome strip or a gutter Compare does not have today. The options:

- **(A) The badge in the existing strip — zero layout change.** Write's narrow-gutter rung (the
  count badge, a door to the comments panel; `CommentCardLayout.badgeFace` yields "#2" → "2" to
  fit), stacked vertically UNDER the ⠿ handle in the cell's leading strip, never over the rail or
  the prose; the strip, the pane and every column's measure unmoved, comments or not. Compare
  then always sits on the ladder's narrow rung: she sees THAT a block has comments and opens them
  in the panel; she never reads them in place. Nearly free; nothing to rule on taste except the
  badge's exact seat.
- **(B) A Compare gutter as a pure function of the COLUMN's width (ProseGutter's one law,
  applied to a Compare cell).** Every Compare cell gains a leading gutter whose width depends on
  the column's width only — e.g. Write's card lane where the column can afford it and still keep a
  reading measure (≥ ~150 + ~320 + chrome, so 2 columns at the default window), else a badge lane
  (~36 pt = Write's 32-pt badge + 4 air) — and Write's ladder then picks card / badge / yields.
  She READS the AI's notes beside the revised copy (her ticket's "pull request of prose" case) at
  2 columns. Cost: every Compare column's prose narrows by the lane at all times, comments or not
  (≈ 499 → ≈ 340 pt at 2 columns; ≈ −36 pt at 3–4) — a visible change to Compare's face that
  nobody has ruled; the thresholds are taste numbers.
- **(C) A fixed badge lane at every width** — (B)'s narrow arm everywhere: a constant ~36-pt
  leading gutter on every cell, the badge in it, never the card. Cleaner seat than (A), a
  permanent measure cost (−36 pt per column), still count-only.
- *Considered and not pursued:* a lane only on columns whose note HAS comments (the measure would
  move when the first comment lands — the one law broken); inline strips under the block (the
  contract puts them in the gutter, and a strip moves the rows below it — R7's opt-in setting
  stays Write's).

**My recommendation:** (A) as PROVISIONAL — the most spec-defensible: it shows them (R-770-2),
moves no prose (the one law, trivially), and uses only Write's existing rung and face; (B) is the
upgrade if she wants to read notes in place, and is hers to rule because it narrows every
Compare column. **The feed for any option:** add `Queries.containerComments` per shown post to
`CompareViewModel.read` (one indexed pass per column post — ∝ the shown posts' own comments, the
same bound as Write's feed and as the projection's existing per-post reads; live, so Compare does
not inherit the VX-732 staleness class). Pins for any option: a commented block's face present in
its column (red on old — nothing reads comments there), and the measure/left-edge guard (a
commented and an uncommented cell's prose start at the same x; for (B) also "the lane is the same
with and without comments").

### THE TAKES BUILD PLAN (no product fork; proceeding on the orchestrator's word)

- **T1 — one decision.** Move the per-block arm of `BlockDecor.commentGutterFaces` into
  `BlockDecor.commentFace(textLeft:top:blockHeight:roomBelow:) -> CommentFace`, which
  `commentGutterFaces` then calls (byte-identical for Write; its existing pins guard it).
- **T2 — one face.** Move `renderComments`' card and badge arms into one presentation function on
  `CommentCardView` (the entries, the voice's prefix, ink/rule/separator, the tooltip, the badge's
  "#n"), which Write's controller and every new host call (byte-identical for Write).
- **T3 — the Takes host.** `CommentMarginNote` keeps its feed exactly (the per-row
  `Queries.blockComments` read on appear + after its popover closes — ∝ rows drawn; its staleness
  is VX-732's and stays batch 3's) and its door (the same `.popover` with `CommentsPanel`; editing
  and the unsubmitted-comment park rule stay the panel's), but its FACE becomes T2's
  `CommentCardView` through a thin `NSViewRepresentable`, placed by T1 with `textLeft =
  commentRoom + articleTextLeadingInset` (the article prose's container edge, in the board's
  coordinates), `top` = the row's first line (or under the callout emoji, R-13u3-3's stack),
  `blockHeight` = the row's text region, and `roomBelow` = the row's own extent + the article's
  6-pt row spacing — the host cannot see its neighbour's comments (the feed is per row), so it
  assumes the next row may carry a face and never crosses into it (Write's rhythm, conservatively:
  a one-line unbloomed row's card is ~8 pt shorter than Write's; an open fan gives it the fan's
  height).
- **T4 — slot split.** The face rides the row's content column (the article `VStack`), not the
  cell, so a bloomed split row keeps its gutter; every style draws through the one host.
- **T5 — pins (red-on-old by behavioural revert).** A behaviour-neutral DEBUG seam FIRST, in its
  own commit: a session-scoped `TakesCommentFaceOracle` the OLD note writes (the entries it shows,
  its line cap, card vs chip), so the pins read the same oracle on both trees; then per style —
  stack (a long comment + a short one on a tall block: both whole, uncapped, the card not
  overflowing), slot split bloomed (a face present), carousel bloomed (a face present + whole) —
  and the left-edge guard (a commented and an uncommented row's prose at the same window x, the
  face wholly left of it). The revert restores the two source files to the seam commit.
- **T6 — what Takes inherits, stated:** Write's thresholds (card ≥ 150, badge ≥ 19, else yields)
  replace the old note's 90-pt chip rule, and VX-696's short-block clip.

### AS BUILT (after the ruling — P-770-3, T1–T6)

Commits: seam 2dfd4a4a0 · A (shared machinery) 20773ef07 · B (pins) 1c4c21d8c · C (behaviour) 9a02527ea.
- **The seam** — `Features/Takes/BoardCommentFaceOracle.swift` (DEBUG, session-scoped): what each
  board's comment face draws for a block (`BoardCommentFace`: card / badge / chip, its entries, their
  line cap, its label), written on appear and on change, erased on disappear. The pre-fix
  `CommentMarginNote` reports its own face (first comment, cap 4, "+N more"; the chip's words).
- **T1 — one decision.** `BlockDecor.commentFace(textLeft:top:blockHeight:roomBelow:)` is the
  per-block arm of `commentGutterFaces`, moved; Write calls it (byte-identical).
  `BlockDecor.roomBelowInOwnRow` bounds a card for a host that draws ONE row (assumes the next row
  may carry a face; the card never reaches it).
- **T2 — one face.** `CommentCardView.presentGutterFace(_:entries:tokens:)` (in `BlockDecor.swift`):
  `renderComments`' card and badge arms, moved (byte-identical); `CommentCardView.badgeText`.
- **The per-row host** — `Features/Takes/CommentGutterFace.swift`: Write's ladder (`commentFace`) +
  Write's face (`CommentCardView` through an `NSViewRepresentable`, `presentGutterFace`) + the panel
  door (`CommentsPanel` popover — editing and the park rule stay the panel's), placed by the rect the
  ladder returns, reporting to the oracle. No decision, measurement or presentation of its own.
- **T3/T4 — Takes** (`TakesShared.swift`, `TakesBoardView.swift`): `CommentMarginNote` keeps its
  name, feed and door and draws through the host; `TakesCommentGutter` carries the row's ladder
  inputs. The face rides the ROW's content column (an overlay after its `.frame(maxWidth: 680)`), so
  a slot-split bloom keeps it. `TakesBoardView.commentGutter` derives the inputs from geometry only:
  `textLeft` = the article column's leading edge + `articleTextLeadingInset` (8), the callout frame's
  5-pt pad, the face's top under a callout emoji (R-13u3-3; `TakesCalloutFrame.emojiOffset` named).
  `articleColumnLeading(boardWidth:measure:)` replaces the old `(w − measure)/2`, which understated
  the gutter on boards narrower than 728 pt (the face is placed from it). The old compact chip (and
  Study's empty mark) is gone; Write's thresholds rule (card ≥ 150, badge ≥ 19, else yields).
- **Compare (VX-728 — P-770-3, PROVISIONAL)** — `Features/Takes/CompareGutter.swift`: the lane is
  `CompareGutter.lane(columnWidth:)` — 150 (the card lane = Write's card threshold) while the column
  keeps ≥ 300 pt of prose, else 38 (Write's full badge + its air + edge margin) while it keeps ≥ 160,
  else 0 (yields); column width = (board − 2·12 − 8·(n−1)) / n. **Never an input of comments.** At
  the 1270-pt default (1030-pt board): 2 columns (499 pt) → card lane, prose ≈ 313 pt (was ≈ 465);
  3 (330) → badge lane, prose ≈ 256; 4 (245) → badge lane, prose ≈ 171. `CompareBoardView.swift`:
  the rows read the lane from the board's width (a `GeometryReader` around the rows' scroll view),
  each cell leads with a `Color.clear` lane, and the face is the shared host as an overlay on the
  cell's row (`CompareCellView.gutter`: the lane's right edge is `textLeft` — the cell's chrome
  stands where Write's prose would — so a card ends 28 pt and a badge 4 pt short of it, both inside
  the lane). The feed: `PostFace.comments` from `Queries.containerComments` per shown post, read in
  `CompareViewModel.read` (live with the projection).
- Untouched: `Sync/`, schema, `Shared/` (no `App/Variorum/Shared/` file in the diff), `PaneSurface`,
  `EditorTextView`, `BlockRangeIndex`, the capability registry, the Write gutter's numbers. MOBILE
  PARITY: nothing mobile-visible (Mac Takes board and Compare only).

**VX-731's carousel arm — which road (the ruling's note (a)), stated:** the build fixes BOTH roads
(the carousel's face is the shared host, and the empty chip is gone), and pins both:
`carouselKeepsTheGutterOnAnOpenFan` (presence + whole) and
`aOneCommentBlockStillSaysSoInStudyAtANarrowMargin` (the empty-chip road, Study at a 60-pt margin,
one comment). **Which one her sighting was is the window's red run on `vx770-b2-rev`:** if the
carousel pin's PRESENCE line (`the commented block has a comment face on the board`) is GREEN on
rev, the old carousel drew a face, so her "none" was the empty chip — pinned red by the Study test
(record it as the carousel arm's mechanism). If that presence line is RED on rev, carousel had its
own road and the presence pin is its pin. PENDING.

### THE PREDICTION TABLE (PENDING the window)

| # | Test | `vx770-b2-rev` (behaviour files at 1c4c21d8c) | `vx770-b2-post` |
|---|---|---|---|
| 1 | `TakesCommentGutterTests/stackShowsEveryCommentWhole(open: false)` (VX-730) | **R** — entries [long] of 2, cap 4, no `CommentCardView` | G |
| 2 | `…stackShowsEveryCommentWhole(open: true)` (VX-730) | **R** — same | G |
| 3 | `…slotSplitKeepsTheGutterOnAnOpenFan` (VX-731) | **R** — no face at all (presence line red) | G |
| 4 | `…carouselKeepsTheGutterOnAnOpenFan` (VX-731) | **R** on the whole-text lines (VX-730's); presence line predicted **G** by the code read — note (a)'s decider | G |
| 5 | `…aOneCommentBlockStillSaysSoInStudyAtANarrowMargin` (VX-731 carousel arm) | **R** — a chip printing "" | G (badge "#1") |
| 6 | `…aCommentNeverMovesTheTakesProse` (the guard) | G | G |
| 7 | `CompareCommentGutterTests/aCommentedBlockShowsItsCommentsInItsColumn` (VX-728) | **R** — no face | G |
| 8 | `…aNarrowColumnSeatsWritesCountBadge` (VX-728) | **R** — no face | G |
| 9 | `…addingOrDeletingACommentNeverMovesTheCompareProse` (rider 1's guard) | **R on its non-vacuity line only** (the face appeared); its position lines G | G |
| 10 | `BoardCommentGutterRuleTests` (3 functions; one parameterized ×6 — pure) | G | G |
| 11 | the Write decor, Compare, Takes families + the spine (READY-FOR-SUITES) | — | G — predicted; risks in the self-assessment |

### P-8 — how each surface's comment read is bounded

- **Takes:** unchanged — one `Queries.blockComments` read (indexed by `block_id`) per REALIZED row
  on its appear and after her panel closes; the LazyVStack realizes the viewport, so reads ∝ rows
  drawn. Faces: one `CommentCardView` per realized commented row.
- **Compare:** `Queries.containerComments` once per shown post per projection read — an indexed
  join over that post's live placements (Write's own feed), ∝ the shown notes' own comments, beside
  the projection's existing per-post reads (`renderPost`, `activeFans`), never the corpus. Faces:
  one per realized commented cell (the rows' LazyVStack).
- **Write:** unchanged (`observeComments`, ∝ the note's comments).

### THE USE WALK — batch 2 rows (an Opus walker under the orchestrator's claim; DEV-STORE Debug from `DerivedData/vx770-b2-post`; both voices; never Resume Sync)

A walk note of ~8 paragraphs, block 2 a long paragraph with two comments (one ~300 characters), block
5 a one-line block with one comment, block 2 and block 6 with a second take; a twin made by Duplicate
with Tags (Compare's peer).
- **W5 (VX-730, stack):** Takes ▸ stack → block 2's card in the left gutter, BOTH comments whole as
  two entries (as Write shows them); its prose starts where block 3's does; a press opens the
  comments panel; a scroll with the pointer over the card scrolls the page.
- **W6 (VX-731, slot split):** expand all → block 2's card stays in the gutter beside the open
  split.
- **W7 (VX-731, carousel):** expand all → the card stays. Then Study at a narrow window (≈ 800-pt
  board, or the Book Panel open) → block 5 shows a "#1" badge, never an empty mark.
- **W8 (VX-728, Compare):** the note beside its twin → block 2's card in the anchor column's lane;
  "+ note" to three columns → the badge; add a comment from the panel, then delete it → the face
  comes and goes, the prose does not move a point. Both voices.
- **W9 (look only):** block 5 in Takes — the one-line card is short, so a second comment would sit
  below its fold (VX-696's face, inherited — T6); note it if seen, nothing more.

## READY-FOR-SUITES — batch 2 (the orchestrator's window; from `App/Variorum/`)

Both trees are built (`DerivedData/vx770-b2-post` at HEAD — logs `DerivedData/logs/vx770-b2-post-build.log`,
`vx770-b2-post-build2.log` (the HEAD rebuild); `DerivedData/vx770-b2-rev` — log
`vx770-b2-rev-build.log`; both TEST BUILD SUCCEEDED, 2.8 GB each). Run `test-without-building`:
`xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/<tree> test-without-building <args>`.
Confirm the "Test run with N tests" line and read the `skipped:` lines.

1. **THE RED RUN** on `vx770-b2-rev` (≈ 2–3 min): `-only-testing:VariorumTests/TakesCommentGutterTests -only-testing:VariorumTests/CompareCommentGutterTests -only-testing:VariorumTests/BoardCommentGutterRuleTests`
   — expect 11 test functions (one parameterized ×6, one ×2); the prediction table's rev column.
   Read row 4's PRESENCE line for note (a).
2. **THE GREEN RUN** on `vx770-b2-post` — the batch's three suites, the Write decoration/comment
   family (T1/T2 touch `BlockDecor.swift`), the comments panel's hosts, the Compare family, the Takes
   board family (batch 1's list) and the acceptance spine — 87 suite types:
   `-only-testing:VariorumTests/TakesCommentGutterTests -only-testing:VariorumTests/CompareCommentGutterTests -only-testing:VariorumTests/BoardCommentGutterRuleTests -only-testing:VariorumTests/CommentCardLayoutTests -only-testing:VariorumTests/CommentCardViewTests -only-testing:VariorumTests/CommentCardControllerTests -only-testing:VariorumTests/IndicatorGutterTests -only-testing:VariorumTests/EditorDecorTransactionTests -only-testing:VariorumTests/BlockDecorGeometryTests -only-testing:VariorumTests/CommentsAndReorderTests -only-testing:VariorumTests/EditorTypographyTests -only-testing:VariorumTests/MarginHoverCommentTests -only-testing:VariorumTests/CalmPageHoverTests -only-testing:VariorumTests/DecorRegistrationMappingTests -only-testing:VariorumTests/DecorRegistrationWindowTests -only-testing:VariorumTests/BlockHighlightTests -only-testing:VariorumTests/BoardBlockSelectionTests -only-testing:VariorumTests/ProseGutterTests -only-testing:VariorumTests/FormattingSurfacesTests -only-testing:VariorumTests/NoLiteralColourTests -only-testing:VariorumTests/CommentPanelHostSuites -only-testing:VariorumTests/CommentPanelReleaseTests -only-testing:VariorumTests/CommentPanelHostLeavingTests -only-testing:VariorumTests/CompareCompositionTests -only-testing:VariorumTests/CompareViewModelTests -only-testing:VariorumTests/CompareAnchorWholeTests -only-testing:VariorumTests/CompareOnePlacementTests -only-testing:VariorumTests/CompareLensesAlignmentTests -only-testing:VariorumTests/CompareVersionsTests -only-testing:VariorumTests/MCPCompareLandingTests -only-testing:VariorumTests/CompareLeavingSavepointTests -only-testing:VariorumTests/OutsideWriteRingEndTests -only-testing:VariorumTests/ScrubAndOutlineTests -only-testing:VariorumTests/CapabilityRegistryTests -only-testing:VariorumTests/AutosaveRegistryLifecycleTests -only-testing:VariorumTests/AutosaveRegistryReleaseGuardTests -only-testing:VariorumTests/TakesSeededEntryLandingTests -only-testing:VariorumTests/TakesExpansionMemoryTests -only-testing:VariorumTests/TakesExpansionRemountTests -only-testing:VariorumTests/TakesSlotSplitExpandAllTests -only-testing:VariorumTests/TakesExpansionCostTests -only-testing:VariorumTests/TakesArticleScrollTests -only-testing:VariorumTests/TakesArticleWatchTests -only-testing:VariorumTests/TakesEntryBandTests -only-testing:VariorumTests/ArticleLandingProjectionArmTests -only-testing:VariorumTests/LandingAimTests -only-testing:VariorumTests/ComfortBandAndFlashTests -only-testing:VariorumTests/RestoreLandingTests -only-testing:VariorumTests/TakesLandingTests -only-testing:VariorumTests/TakesBoardSoakTests -only-testing:VariorumTests/TakesBoardTests -only-testing:VariorumTests/TakesPresentationTests -only-testing:VariorumTests/TakesChooseRingTests -only-testing:VariorumTests/TakesFindBoardTests -only-testing:VariorumTests/TakesStepFollowTests -only-testing:VariorumTests/TakesStepFollowModelTests -only-testing:VariorumTests/TakesParkedFollowTests -only-testing:VariorumTests/TakesLensFilterTests -only-testing:VariorumTests/TakesRoomTests -only-testing:VariorumTests/TakesCardHeightTests -only-testing:VariorumTests/TakesRailPagingTests -only-testing:VariorumTests/TakesSlotDragTests -only-testing:VariorumTests/TakesMarginGridAlignmentTests -only-testing:VariorumTests/TakesMarginGridCaptureTests -only-testing:VariorumTests/TakesArticleRenderTests -only-testing:VariorumTests/TakesEmptyStateTests -only-testing:VariorumTests/TakesEmptyBlockFaceTests -only-testing:VariorumTests/TakeCardDoorTests -only-testing:VariorumTests/TakePaneMeasureTests -only-testing:VariorumTests/TakePaneDurabilityTests -only-testing:VariorumTests/PaneRenderRestoreClipTests -only-testing:VariorumTests/OutsideWriteLivePaneTests -only-testing:VariorumTests/ModeSwitchCarryTests -only-testing:VariorumTests/ModeSwitchFeelTests -only-testing:VariorumTests/CurrentBlockContinuityTests -only-testing:VariorumTests/LandingOffsetTests -only-testing:VariorumTests/TutorialBookShapeTests -only-testing:VariorumTests/TutorialDoorTests -only-testing:VariorumTests/TutorialWritingActsTests -only-testing:VariorumTests/TutorialTakesActsTests -only-testing:VariorumTests/TutorialStructureActsTests -only-testing:VariorumTests/TutorialLookingActsTests -only-testing:VariorumTests/TutorialLibraryActsTests -only-testing:VariorumTests/TutorialDeletionActsTests -only-testing:VariorumTests/TutorialWherePlacesActsTests -only-testing:VariorumTests/TutorialPrivacyChapterTests -only-testing:VariorumTests/TutorialFannedMatrixTests`
   — all green expected. Known load-dependent flakes that are NOT this batch's if met: VX-337's two
   (`TakesArticleScrollTests.aShortRowStraddlingTheFoldComesBackAboveIt` among them — run alone
   first). An unexpected `TakesEntryBandTests` red: the defaults domain first.
3. Results into the prediction table; then `vx770-b2-rev` may be deleted (post stays for the walk).

### RESIDUE / NOTICED (not fixed — a line each; the orchestrator's to ticket or drop)

- **R-B2-1 (a one-law breach in Takes, callouts):** `TakesCalloutFrame` pads the whole row by
  5 pt (`Features/Takes/TakesCalloutFrame.swift:61-62`), so a callout block's prose starts 5 pt
  right of a plain block's and its measure is 10 pt narrower — a decoration moving the prose's
  left edge on the Takes board. Pre-existing; not a member.
- **R-B2-2:** the Takes callout emoji draws the WHOLE stored emoji (`TakesCalloutFrame.swift:70-74`),
  not the first grapheme Write draws (R-13u3-4, `BlockDecor.leadingGlyph`).
- **R-B2-3:** the Study voice's compact comment chip prints an empty string for a one-comment
  block (`TakesShared.swift:811-818` + `commentPrefix == ""`) — dissolved by T3 if built. **BUILT:
  dissolved (9a02527ea); pinned as VX-731's carousel arm.**
- **R-B2-4 (fixed as a placement input, stated):** the Takes board's `commentRoom` was
  `(w − measure)/2`, which understates the gutter on boards narrower than measure + 48 (the
  composition's 24-pt padding then wins); the face is placed from it, so it is now
  `articleColumnLeading` (identical at ≥ 728 pt). Nothing else reads it.
- **R-B2-5 (the two boards differ in liveness until batch 3):** Compare's comments are live (the
  projection's feed); the Takes row's are still one-shot per appear (VX-732's mechanism, untouched
  here by design — batch 3's).

### B2-F1 — THE RULING (the orchestrator, 2026-11-04, repo-first before the build resumes)

**P-770-3 (PROVISIONAL): OPTION (B) — a Compare gutter whose lane is a pure function of the
column's width, never of comment presence.** Why (B) and not (A)/(C): her R-770-2 selection's own
text was "Compare renders block comments IN THE GUTTER LIKE OTHER SURFACES", and VX-728's framing
is the pull-request-of-prose case — READING an AI's notes beside the revised copy. (A)'s count
badge doesn't show them; (C) never shows them in place at any width. (B) is Write's own
architecture applied per column: a standing lane (so the measure never moves FOR a decoration —
the lane may not appear or size by comment presence; width only), Write's ladder picking the face
(card where the lane is wide, badge where narrow, yields below the floor), the shared face
rendering. Riders binding the build:
1. The lane is geometry-derived ONLY (column width); adding or deleting a comment never moves the
   prose's measure or left edge — the per-surface pin asserts it.
2. One machinery (P-3): T1's shared decision + T2's shared face; Compare grows NO comment code of
   its own beyond the lane's geometry and the feed.
3. The feed is the live `containerComments` per shown post (the implementer's proposal — adopted;
   it also fences Compare out of VX-732's staleness class).
4. THE TASTE COST IS HERS and goes to the morning bundle as its own QUESTIONS line: under (B),
   wide Compare columns always carry the lane (≈499 → 340 pt at two columns on the default
   window), comments or not. One line to overturn: the lane's width table is one function — her
   "too much" flips it to (C)'s 36-pt badge lane or (A)'s strip badge cheaply, faces unchanged.

**T1–T6: APPROVED as planned** (the oracle seam commits first, behaviour-neutral; red-on-old by
restoring the two source files to the seam commit). Two notes: (a) the R-B2-3 empty Study chip
may BE VX-731's carousel sighting (her recording's voice unverified) — if the oracle shows the
old carousel drawing a face, pin the empty-chip road as the carousel arm's mechanism and fix THAT
(the member's words still land true: she saw nothing); say which in the record. (b) T6 accepted:
Takes inherits Write's thresholds and VX-696's short-block clip — VX-696 stays open, one later
fix heals both; the walk notes the clip if seen, nothing more. Residue R-B2-1/2/3 confirmed as
closeout ticket candidates (R-B2-1 and R-B2-2 are contract deviations predating this run).

## SELF-ASSESSMENT — batch 2 (the first of the two reviews — the implementer's)

- **What is proven, and how far.** Headless only: both trees compile (the pins against the pre-fix
  behaviour and against the fix), the behavioural revert is verified restored, and the mechanisms
  are code-traced. Every red/green line is a prediction. Two things the harness cannot show me and
  the walk must: that the AppKit card, hosted by an `NSViewRepresentable` OFFSET outside its SwiftUI
  row, takes her press (the panel opens) and routes a wheel to the page (or to itself when it
  overflows) inside SwiftUI's `ScrollView`; and that its popover anchors on the card.
- **Why this shape (P-3).** The board surfaces had a second comment face (the SwiftUI note); the
  fix retires its FACE and keeps its feed and door, so Takes, Compare and Write now share one
  decision (`commentFace`), one face (`presentGutterFace`) and one door — the per-row host adds no
  rule of its own. T1/T2 are moves, not rewrites: Write's arithmetic and presentation are byte-for-
  byte what they were (the Write decor suites in the green run guard that).
- **What could regress.** (1) *Hit-testing over the row:* the face's overlay is a `GeometryReader`
  over each commented row's content; it holds no hit-testable content beyond the offset card, but a
  regression in click-to-focus on a commented Takes row would show here first (the Takes board
  family's click pins ride the green run). (2) *Compare's measure:* every Compare column's prose is
  narrower by its lane (the ruled cost — 465 → ≈ 313 pt at two columns on the default window); no
  existing pin measures Compare pane widths (searched), so nothing goes red by construction — her
  eye is the judge. (3) *Legacy scrollers:* both hosts take the gutter from a width read outside the
  scroll view; a legacy vertical scroller (≈ 15 pt) narrows the content, which moves the face
  further LEFT of the prose, never onto it. (4) *A one-line unbloomed Takes block's card is the
  row's height (≈ 25 pt Terminal) — shorter than Write's 41 — so a second comment there scrolls
  inside the card (VX-696's face, inherited and accepted — T6).
- **Risks in the pins themselves.** The Study pin starts a `ThemeStore` (it adopts Study's
  typography globally; `TerminalMetricsPin` saves and restores it, the `TakesEntryBandTests`
  precedent). The "no inner scroll" lines depend on the fixture's block being tall enough at the
  test host's metrics; if a green-tree run shows a card that overflows by a few points, the
  fixture's prose (not the fix) is the first suspect. Row 9's non-vacuity line is red on rev by
  design — not a guard failure.
- **Scope kept.** No `Sync/`, schema, `Shared/`, `PaneSurface`, `EditorTextView`, `BlockRangeIndex`
  or registry change; VX-696 not fixed; VX-732's per-row staleness untouched; R-B2-1/2 (Takes
  callout one-law deviations) noticed, not fixed.
