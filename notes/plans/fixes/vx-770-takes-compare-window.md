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
| 2 | VX-730 stack comments whole | Batch 2 | FIXED — red-on-old (window b2) + green (b3r consolidated) |
| 3 | VX-731 slot split + carousel comments | Batch 2 | FIXED — red-on-old (window b2; carousel = the empty-chip mechanism) + green (b3r) |
| 4 | VX-728 Compare comments (R-770-2) | Batch 2 | FIXED — red-on-old (window b2) + green (b3r); P-770-3 lane, taste cost in her bundle |
| 5 | VX-732 undo leaves comments drawn | Batch 3 | FIXED — red-on-old ×4 styles (window b3r) + green |
| 6 | VX-733 undo leaves the fan wash | Batch 3 | FIXED — red-on-old ×4 + across-mode-switch (window b3r) + green; B3-P1/B3-P2 in her bundle |
| 7 | VX-757 track-paragraphs flicker | Batch 4 | FIXED — red-on-old both toggle pins (window b3r) + green; toggle-name confirm in her bundle; walk W15 |
| 8 | VX-740 double outline column (P-770-1) | Batch 4 | FIXED — red-on-old (window b3r: two columns on old) + green; walk W16 |
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

### THE RED RUN FLIPPED (the orchestrator, window `vx-770-tests-b2`, 03:25; the green run pending)

**The red run (vx770-b2-rev, log `App/Variorum/DerivedData/logs/vx770-b2-red-run.log`): "Test run
with 11 tests in 3 suites failed … with 27 issues (including 4 warnings)" — red-on-old VERIFIED
for all three members, one resolution and one honest prediction miss:**
- **VX-730:** `stackShowsEveryCommentWhole` red both arms (entries ≠ all comments, a line cap
  present, no card) — the first-comment/lineLimit-4 mechanism confirmed on the old tree.
- **VX-731 slot split:** red at `face != nil` — the old open fan drew NO gutter, as surveyed.
- **VX-731 carousel — NOTE (a) RESOLVED:** the presence line PASSED on rev (the old carousel DID
  draw a face); the red is entries/cap/card. Her carousel "shows nothing" sighting WAS the empty
  Study chip (R-B2-3's road), and `aOneCommentBlockStillSaysSoInStudyAtANarrowMargin` is
  red-on-old (`!words.isEmpty` failed on rev) — the chip pin carries the carousel arm's
  mechanism, exactly as the B2-F1 ruling's note (a) asked the oracle to decide.
- **VX-728:** both Compare pins red (card: `face != nil`; badge: kind/label) — no gutter existed.
- **The Compare add/delete guard:** red on rev ONLY at its non-vacuity line — as predicted.
- **PREDICTION MISS, recorded honestly:** `aCommentNeverMovesTheTakesProse` was predicted green
  on both and went RED on rev at `oracle.face(…) == nil` — the OLD margin note drew a face at a
  geometry where the shared ladder YIELDS. Directionally correct red-on-old (the old road drew
  where the new road deliberately does not), not a hollow pin; the reconciliation is the
  implementer's at the next touch or the ladder's. The pure suites (`writesFacesAreTheOneDecision`
  ×6, `compareLaneTable`, `aRowHostsCardStaysInItsRow`) were GREEN on rev as predicted — the
  byte-identical moves proven.

### THE PREDICTION TABLE (as the implementer wrote it; the observed red column is the section above)

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

### THE GREEN RUN (the orchestrator, window `vx-770-tests-b2`, 03:34): 86 OF 87 SUITES GREEN; ONE
RED, ADJUDICATED ENTANGLED WITH VX-732 (batch 3)

"Test run with 610 tests in 87 suites failed after 452.261 seconds with 15 issues (including 4
warnings and 10 known issues)" (log `App/Variorum/DerivedData/logs/vx770-b2-green.log`; 87 of 87
requested types executed). The 10 known issues are pre-existing annotated guards (the VX-229
comments-host lifecycle suite et al.), the skips the VX-136 capture harness. **The ONE red:**
`aCommentNeverMovesTheTakesProse` at BoardCommentGutterTests.swift:417 — the guard's DELETION arm
(`oracle.face(commented.block) == nil` after the comments are deleted) — **red on BOTH trees.**
Mechanism, adjudicated from the log: the face survives the deletion because the Takes feed is
ONE-SHOT per realized row (the batch's own recorded residue R-B2-5) — the assertion describes the
world VX-732's fix (batch 3, in flight) builds, a batch early. Not hollow (the measure arms of
the guard pass; the deletion arm is honest about a real staleness she reported as VX-732) but
MIS-SEATED: the resolution is owed BEFORE the ladder — after batch 3 lands, batch 2's implementer
reconciles (either the live feed makes the line green as-is, or the deletion arm moves to batch
3's pins and the guard keeps its measure arms) and the batch 2 suites re-run in a short window.
**Observation for the implementer:** the run's 4 "[SwiftUI] Modifying state during view update"
warnings cluster inside the new BoardCommentGutter suites — the DEBUG face oracle (written to
during render?) is the suspect; assess at the reconciliation.


### RECONCILIATION (batch 2's implementer, resumed after batch 3 — written before any code)

**LIVE STATUS**
| piece | state |
|---|---|
| Reading (this record's window sections, the BATCH 3 RECORD whole, the window logs `vx770-b2-red-run.log` / `vx770-b2-green.log` / `vx756-tier1.log`) | DONE |
| Part 1 — line 417's mechanism, concluded by code read (below) | DONE (this commit) |
| Part 2 — the render-write warnings, attributed from the logs (below) | DONE (this commit) — NOT batch 2's; no change |
| Part 1 — the oracle attributes each record to the board that wrote it (`BoardCommentFaceOracle.swift`: scope → block → mount; `reader(_:board:)`; the `boardCommentFaceMount` environment), each board root publishes its token (`TakesBoardView.swift`, `CompareBoardView.swift` — one DEBUG modifier line each, beside `debugProbeScope`), the guard reads each board by name + prints `VX770-RECON` | DONE (this commit) — compile PENDING the recon tree's build |
| Part 3 — `DerivedData/vx770-recon-post` build-for-testing at reconciled HEAD (818b09aa7) | DONE — TEST BUILD SUCCEEDED 04:10–04:17 (log `App/Variorum/DerivedData/logs/vx770-recon-post-build.log`; 2.8G); the only warnings in a touched file are two that predate this run (`CompareBoardView`'s and `TakesBoardView`'s geometry-probe `Sendable` warnings, present in batch 1's build) — the reconciliation's compile is verified |
| READY-FOR-SUITES — RECONCILIATION (at the end of this file) | DONE (this commit) |
| Push | refused at 33c8e2f62 and 818b09aa7 (no ssh agent in this shell); the push at 8a3b3f930 LANDED — origin held HEAD with nothing ahead (every earlier local commit included); git config untouched |

**Part 1 — the mechanism of `aCommentNeverMovesTheTakesProse`'s red at :417, CONCLUDED: R-B3-1 (an
oracle read across a closed window), not the one-shot feed.** The line asks whether the SECOND board
— a fresh `TakesBoardView` and model, mounted AFTER `deleteBlockComment` — draws a face for the block.
By code read it cannot, on either tree: on the fix its note's one read (`.task(id: blockID)`) runs
after the deletion and finds nothing, so `CommentGutterFace` draws nothing and records nothing; on the
pre-fix tree the old note reads the same nothing and takes its `Color.clear` branch, which records
nothing. Nothing else in the session writes that block's key. So the record the line found is the
FIRST board's: written by its face's `onAppear`, and never erased — the oracle's only eraser is
`.onDisappear`, and the test's close (`model.teardown()`, `orderOut`, `close()` on a window with
`isReleasedWhenClosed = false`, its hosting view still the content view and still held by the test)
does not take the face out of a live SwiftUI graph. The oracle was keyed per SESSION, so the second
board's question was answered by the first board's leftover — which is also why the line read the
same on both trees, and why the red run's note ("the old margin note drew a face at a geometry where
the ladder yields") was this same leftover, not a geometry difference. The one-shot-feed reading
needs a board alive across the deletion whose face the line means; the only such board is the closed
one, which she cannot see. Batch 3's live feed might now clear the line by accident (if the closed
window's graph still hears the feed, the face leaves and `.onDisappear` forgets) — which is exactly
why the pin must not lean on it either way.

**The fix (harness — DEBUG-only, no product code):** every record is attributed to the board that
wrote it. Each board root (`TakesBoardView`, `CompareBoardView`) publishes a mount token — its model's
identity — through the environment, beside its probe scope; the oracle keys records
scope → block → mount; `reader(scope, mount:)` reads ONE board, and `reader(scope)` keeps the answer
batch 3's pins rely on (the latest record any board of the session wrote — honest wherever one board
is up). The guard reads its first board and its second board BY NAME, so a stale first-window record
can neither satisfy nor fail the second board's question; it also prints what the first (closed)
board's record says after the deletion (`VX770-RECON`, a diagnostic, never asserted), so the window's
log shows which way the closed window went. **The deletion arm STAYS in the guard** (its home is "deleting
the comments moves the prose not a point"); its face line is the deletion's non-vacuity, now about the
board mounted after it. The staleness of a board alive across a deletion — VX-732 — is batch 3's
`aCommentChangedFromOutsideTheBoardFollowsTheStore`, not duplicated here.

**The reconciled guard's evidence story:** green on both trees by design. Its POSITION assertions
are the guard (a commented block's prose at the plain block's left edge and measure; unmoved after
the deletion). Its two non-vacuity lines say the guard measured what it claims: the first board drew
the comments (that board's record), and the board mounted after the deletion draws none (its own
record). A red there would now be a real fact about the named board.

**Part 2 — the render-write warnings: NOT batch 2's (no change).** Two different things carry the word:
- The Swift Testing summary's **"4 warnings"** are swift-dependencies' "`@Dependency(\.date)` has no
  test implementation" (location `Variorum/AppSession.swift:833`), recorded against «unknown» at
  03:26:13 during the seal-fallback suite (`vx770-b2-green.log` :532–578), before the batch's suites
  began.
- The SwiftUI console line **"Modifying state during view update"** prints 4,623 times in the green
  log and 4,463 times in batch 1's tier-1 log (`vx756-tier1.log`, built before batch 2 existed), with
  IDENTICAL per-suite counts in the suites both runs share (the scroll-memory suite 923, the soak 728,
  the entry band 610, the margin grid 446 → 429…): every mounted Takes board prints it. In this
  batch's own suites the count is identical on the pre-fix tree and on the fix — red run (rev): Takes
  29, Compare 13; green run (post): 29, 13 — so neither the shared face nor the oracle adds one. (The
  oracle writes a static, non-observed table from `onAppear`/`onChange` callbacks, never during a
  body — R-B3-2's reading, confirmed by the counts.) **A candidate ticket for the orchestrator, not
  this batch:** the mounted boards' own state write during update, pre-existing in every Takes and
  Compare mount.

---

## BATCH 3 RECORD — VX-732 + VX-733, the post-undo staleness pair (implementer: opus-implementer, 2026-11-04)

**NOT DONE (first line, kept current):** every mounted red/green claim below is a PREDICTION until the
orchestrator's suite window (this session is headless — no `xcodebuild test`, no app, no stage); the use
walk (W10–W14, both voices); the cold ladder; the push (refused from this shell at every commit — the
commits are local until the orchestrator pushes); the reconciliation of batch 2's one red (a reading
below, not a fix). No `Shared/`, `Sync/`, schema, registry, `PaneSurface`, `EditorTextView` or
`BlockRangeIndex` file is in the diff.

**LIVE STATUS**
| piece | state |
|---|---|
| Reading (this file whole incl. both batch records + window b2; TEXTKIT2_NOTES in full; SurfaceContracts › The note; the vx-601 VX-428 section; VX-732/VX-733 on Linear) | DONE |
| Trace, both members (code read; written below before any code) | DONE (c9c1163df) |
| Pins (`VariorumTests/TakesPostUndoStalenessTests.swift` — pre-existing API only) | DONE (86d3652ec) |
| Fix — VX-732 (the live feed + the panel's seat) | DONE (ca980e24b) |
| Fix — VX-733 (the collapse rule, in-showing + across a mode switch) + the pure-rule pin | DONE (e7f9cefc2) |
| `DerivedData/vx770-b3-post` build-for-testing at e7f9cefc2 | DONE — TEST BUILD SUCCEEDED (log `App/Variorum/DerivedData/logs/vx770-b3-post-build.log`; no new warning in a touched file) |
| **Behavioural revert — ANNOUNCED HERE BEFORE IT STARTS:** the six behaviour files (`TakesShared.swift`, `TakesBoardView.swift`, `CommentGutterFace.swift`, `TakesViewModel.swift`, `TakesBoardLayout.swift`, `EditorRouter.swift`) restored to the pins commit 86d3652ec (= the pre-fix behaviour) by `git checkout 86d3652ec --`; the two new files (`TakesCommentFeed.swift`, `TakesOpenFanRule.swift`) stay, unreferenced except by the pure-rule pin; the tests stay at HEAD. Copies + sha256 first in `App/Variorum/DerivedData/vx770-b3-prerevert/` (gitignored); built into `DerivedData/vx770-b3-rev`; then `git checkout HEAD --` and verified by `git diff` + `shasum -c` | DONE 03:54–03:58 — `vx770-b3-rev` TEST BUILD SUCCEEDED (log `App/Variorum/DerivedData/logs/vx770-b3-rev-build.log` — the pins compile against the pre-fix behaviour); **no revert in flight, the source is HEAD**: `git diff HEAD` empty, `git status` clean, `shasum -a 256 -c …/vx770-b3-prerevert/sha256-head.txt` OK on all six, each byte-identical (`cmp`) to its prerevert copy |
| READY-FOR-SUITES, prediction table, P-8, walk rows, residue, self-assessment | DONE (this commit) |
| Push | REFUSED at every commit so far (c9c1163df, 86d3652ec, ca980e24b, e7f9cefc2): `Permission denied (publickey)` — this shell has no ssh agent (batch 2's finding); unpushed: GitHub incident/auth; git config untouched; one attempt per commit, never thrashed — the orchestrator sweeps |

### THE TRACE (written before any code) — two mechanisms, one class, NOT one mechanism

Both repros are the same night's MCP demo (her recording 2026-11-01): the AI's `add_comments` batch and
its `add_takes` batch (`Operations+MCPBatches.swift` `addComments` :134–168, `addTakes` :65–100 — one
structural-undo entry each, the inverse tombstoning every row of the batch in one transaction), undone
by ⌥⌘Z (`ShellActions.structuralUndo` → `UndoStack.undoReporting`) WITH THE TAKES BOARD MOUNTED. The
store is right in both (her own words: "the comments were really deleted"); the board's drawn state is
not. They share the CLASS the run's binding principles name (the overlay/sink delivery law: state that
no refresh axis reaches) but not a mechanism, a state, or a file: VX-732 is a COPY with no store axis at
all; VX-733 is DERIVED STATE whose one reconciliation never asks the question that changed.

**VX-732 — the gutter keeps drawing comments the store no longer holds.**
1. The Takes row's comment face (`CommentMarginNote`, `Features/Takes/TakesShared.swift:808–834` — on
   her 1.0.1 build the batch-14 SwiftUI note, since batch 2 Write's face through `CommentGutterFace`;
   the FEED is the same in both) keeps its comments in per-row `@State` (:814) filled by ONE read,
   `.task(id: blockID) { await refresh() }` (:826 → `Queries.blockComments`, :829–833), re-read only
   when its own popover closes (:824). Its only key is the block id.
2. The undo's write DOES reach the board: the takes projection reads `comment_count` per slot
   (`Queries.renderPost`, `PostRender.swift:146`), so `observeTakes`'s region holds `block_comment`;
   the delivery lands, `adopt` takes it, and the article re-renders the row with `commentCount` 0.
3. But the row's note keeps its identity (same row, same block) — so its `@State` survives the
   re-render, and `.task(id: blockID)` does not re-fire (the id did not change). Nothing else on the
   undo road (or ANY store road — a comment edited or deleted in another window, by the AI, by a
   sync apply) re-reads it. The face draws the copy it took at the row's realization.
4. A mode switch remounts the board (`PostDetailView`'s per-mode `.id`), the row's state is born
   fresh, the read finds nothing — "gone at the mode switch" (her ~2:07). The ~7 s is simply how
   long she stayed in Takes; a re-realization of the row (scrolled far out of the lazy column and
   back) would also clear it.
   → **No equality gate is involved; the feed has no store axis.** Write (`EditorViewModel.observeComments`,
   `EditorViewModel.swift:634–658`), the read tier and Compare (batch 2's `PostFace.comments`) all draw
   from a LIVE per-note read; the Takes row is the one board host that does not (R-B2-5 said exactly
   this).

**VX-733 — the open-fan wash survives the fan's collapse to one take.**
1. The wash is `washedCell(…, washed: bloomed)` → `.background(washed && markChangingBlock ? tokens.wash : …)`
   (`TakesBoardView.swift:1120`, `:1269`), and `bloomed` is `isBloomed(slot)` =
   `expandedBlocks.contains(blockID) || (followTheScroll && slot.hasFan && visible)`
   (`TakesBoardLayout.swift:333–337`). Membership in the open set IS the wash (and the bloom).
2. The open set is reconciled against the projection in exactly ONE place: `adopt`'s VX-428 prune
   (`TakesViewModel.swift:549–557`) — on the FIRST projection only, and only against block IDS (a
   block the note no longer holds). Inside a showing, nothing ever reconciles it (by design for a
   block that LEAVES: "a ⌥⌘Z that puts it back brings it back open").
3. Her undo tombstones the AI's takes (`revertAddedTakes`); the blocks stay live, `activeVariantCount`
   drops to 1, `hasFan` goes false. The delivery is adopted; the ids are still in `expandedBlocks`;
   nothing asks whether an open block still HAS a fan. So `isBloomed` stays true: in slot split the
   split itself goes (`splitBloomed` requires `hasFan`, :1116 — "the board collapsed to one column"),
   and the cell draws WASHED with the unfanned bloom's growth doors under it (`fanFooter`, :1126–1131 —
   the state the ⑂+ first-take door opens on purpose).
4. The write-back already holds those ids in the session memory (`rememberExpansion`, :2810–2817,
   written when they bloomed); a Write round trip re-seeds them (`openExpansionMemory`, :2795–2808) and
   the first projection's prune keeps them (the blocks are live) — "it stayed through a trip to Write
   and back". Close all (`closeAllFans`) empties the set — "cleared only by close all".
   → **The wash derives from the memory, and the memory never hears a collapse.** By STATE alone the
   board cannot tell "a fan she opened collapsed" from "she opened this block's first-take door"
   (both: open, one take) — R72's door is a deliberate open state the VX-428 pins remember
   (`theBoardsOpenFansAreWrittenToTheSessionAsTheyChange`, the unfanned b[3]). So the honest fix hears
   the TRANSITION: an open block that held more than one take before and holds one now.
5. **The same stale state by a second road (same mechanism, same member):** the collapse can happen
   while the board is DOWN — ⌥⌘Z pressed in Write (the AI's undo entry is global), a take deleted in
   Write's take panel, another device. The seeded set brings the block back washed on an unfanned
   row. The board saw it with a fan; the memory must remember that it did.

**One more road the fix must not break (found while tracing — the archive road, N1/R118):** archiving
a fan's second take also drops `activeVariantCount` to 1, but the archived take stays ON the block and
the bloom's footer shows it ("archived · n", `archivedSection`, `TakesBoardView.swift:1710–1749`) — the
road back the archive receipt names ("“archived · n” under this block's takes brings it back"). A rule
that closed the block there would hide that road behind ⑂+.

### THE FIX'S SHAPE (decided from the trace)

- **VX-732 — make the feed honest (the brief's preferred road; Write's precedent exactly).** The Takes
  board's comments come from ONE live per-note observation of `Queries.containerComments` (Write's own
  query and feed), started by THE takes board's view (`TakesBoardView`'s `.task`, beside
  `model.start()`; Write's panel and the Lenses board draw no comments and never start it), held by a
  small `@Observable` feed the conductor owns; each row's `CommentMarginNote` reads its block's entries
  from it (in its own body — a comment change re-renders the realized notes only). The per-row one-shot
  read and its after-the-panel refresh retire. **P1/P-8:** the region is `block_comment` +
  `container_block`, so it fires on comment and placement writes only — never per keystroke (autosave
  writes `variant` and `container`); each fire reads ∝ the note's own comments (one indexed join over
  its placements) — Write pays exactly this for the same note; a per-ROW re-key on every projection
  delivery (the alternative) would re-read per realized row at autosave rate and still miss an edit that
  keeps the count. **The seat guard:** the Takes face is the comments panel's POPOVER anchor
  (`CommentGutterFace`), so a live feed that empties the face while her panel is open (she deletes the
  block's last comment in it) would tear the panel down mid-act, where today it stays (the one-shot feed
  never updated while it was open). The face keeps its seat — the entries it showed when she opened the
  panel — until the panel closes, then follows the store. It lives in the one shared host, so Compare
  (already live since batch 2) gets the same guard.
- **VX-733 — the open set hears a collapse.** A pure rule (`TakesOpenFanRule`): an open block that held
  MORE THAN ONE take (active or archived — `liveVariantCount`) at the board's last sight and now stands
  in the note holding exactly its one take has collapsed; it leaves the open set through the layout's
  one door for it (reported through the sink, so the memory follows). A block the note no longer holds
  is never "collapsed" (VX-428's in-showing precedent untouched); a gap slot is no evidence; a block
  that still holds two takes stays open (R-770-1); a block opened through its first-take door never held
  two, so it stays open (R72). "Last sight": inside a showing, the outgoing projection; across a mode
  switch, a sibling session memory beside `takesExpandedBlocks` — of the note's remembered open blocks,
  those that held more than one take at the last projection THE board adopted — written with the open
  set, read once at the first projection. Nothing closes a fan she opened that still has takes.
- **PROVISIONAL (for the closeout's QUESTIONS bundle; one predicate each to overturn):**
  - **B3-P1 — what "collapsed to one take" counts.** (a) BUILT: one live take, archived included — so
    archiving the second take keeps the block open with "archived · 1" in place, exactly as today (the
    archive receipt's road); a delete, an undo of an add, or a "Delete forever" of the last archived take
    closes it. (b) Active takes only (the fan's own definition): an archive closes the block too, and
    "archived · n" waits behind ⑂+ (the receipt's "under this block's takes" would then need words).
    (c) Close only on the undo road (her repro), nothing else — rejected: the stale state is the same on
    every road.
  - **B3-P2 — a fan that comes back.** (a) BUILT: a collapsed fan's open state is gone — a ⇧⌥⌘Z that
    re-adds the AI's takes (or a ⌥⌘Z of a take's delete) shows the fan closed, its ⑂n badge the door.
    (b) A per-showing shadow of collapsed fans that reopens one when its takes return (the deleted-block
    precedent's symmetry) — a second set and a ⑂+ rule for shadowed blocks; not built.

### READ OF BATCH 2's ONE GREEN-RUN RED (for the reconciliation the orchestrator scheduled — a reading, not a fix)

`aCommentNeverMovesTheTakesProse`'s deletion arm (`BoardCommentGutterTests.swift:407–417`) CLOSES the
first board's window, deletes the comments, then mounts a SECOND, fresh board. That board's one-shot
read is already fresh (born after the deletion) — so the face it would draw is none, on both trees. The
record the oracle still holds is most likely the FIRST board's: `BoardCommentFaceRecord` forgets on
`.onDisappear`, and closing a window whose hosting view stays alive (`isReleasedWhenClosed = false`)
need not run it. If that reading is right, the arm is a harness trap (an oracle read across a closed
window), not VX-732's staleness; whether batch 3's live feed turns it green depends on whether the closed
window's graph still runs its feed (it might — then the face drops by the live road). The window's run
says which. Batch 3's own pins stage the deletion WHILE the board is up (the arm's honest home) and read
the AppKit card's presence beside the oracle.

### AS BUILT

Commits: trace c9c1163df · pins 86d3652ec · VX-732 ca980e24b · VX-733 e7f9cefc2 · record aa24c5d24 + this one.
- **The pins** (86d3652ec, `App/Variorum/VariorumTests/TakesPostUndoStalenessTests.swift`; pre-existing API
  only, so the revert's red is behavioural) — her acts as the app runs them: the AI's batch through the
  operation the MCP door calls (`addComments` / `addTakes`, one undo entry each, labeled
  "claude-code's …"), then `UndoStack.undo` (the ⌥⌘Z door's own call) with THE takes board MOUNTED, the
  store's change reaching it through its own observations.
  - `TakesCommentFeedLivenessTests`: `anUndoneAIsCommentsLeaveTheGutter` ×4 styles (fan open: the
    face drawn → undo → no face in the oracle AND no `CommentCardView` for the block → redo → back);
    `aCommentChangedFromOutsideTheBoardFollowsTheStore` (edit, delete, delete-last from outside, entry by
    entry); GUARD `herOpenPanelKeepsItsSeatWhenTheLastCommentLeaves` (the face's door pressed, the last
    comment deleted: the face stays seated with what it showed).
  - `TakesCollapsedFanWashTests/anUndoneAIsTakesCloseTheFansTheyCollapsed` ×4 styles: A (her own spare +
    the AI's), B and C (the AI's only) opened by expand all, D's first-take door open; undo → B, C not
    bloomed, out of the open set and the memory; A bloomed (R-770-1); D bloomed (R72); then her Write round
    trip (a fresh, seeded board) → open = {A, D}. The wash is drawn from exactly `isBloomed`
    (`washedCell(washed: bloomed)`) — the pin reads that input; the drawn wash is the walk's (W11).
  - `TakesCollapsedFanRoadsTests` (no mount): `aFanThatCollapsesWhileTheBoardIsAwayComesBackClosed`
    (⌥⌘Z pressed in Write); `deletingAnOpenFansSecondTakeClosesIt` (any road + B3-P2 (a): the take ⌥⌘Z'd
    back returns CLOSED); GUARDs `archivingAnOpenFansSecondTakeKeepsTheArchivedRoadOpen` (B3-P1 (a)) and
    `theFirstTakeDoorStaysOpenThroughProjectionsAndARoundTrip` (R72).
  - `TakesOpenFanRuleTests` (e7f9cefc2, pure): what an open block holds; only a collapsed fan closes
    (still-fanned, archived, first-take door, gap, left-the-note, not-open — all stay).
- **VX-732 — the live feed** (ca980e24b): `Features/Takes/TakesCommentFeed.swift` (new — the board's
  comment projection, plain observable storage, `entries(for:)`, an equality-guarded `adopt`);
  `TakesViewModel.commentFeed` + `observeComments()` (`Queries.containerComments` live — Write's own
  query and `CommentBrief` shape); `TakesBoardView` starts it in its own `.task` beside `start()`
  and hands it to each row; `CommentMarginNote` (`TakesShared.swift`) reads its block's entries in its
  own body — its `@State` copy, `.task(id: blockID)` read and after-the-panel refresh are gone.
  `CommentGutterFace`: the `onPanelClosed` hook retires (no host's feed is one-shot now) and the SEAT
  lands — `shown = panelShown && entries.isEmpty ? seat : entries`, `seat` taken at her press — in the
  one shared host, so Compare's already-live feed gets the same guard (stated: a latent batch-2 edge,
  closed by the same lines, not a separate change).
- **VX-733 — the collapse rule** (e7f9cefc2): `Features/Takes/TakesOpenFanRule.swift` (new, pure:
  `holdingTakes`, `collapsed`); `TakesBoardLayout.closeCollapsedFans` (the open set's one door for it,
  reported through the sink so the memory follows; the layout still never reads the projection);
  `EditorRouter.takesExpandedHeldTakes` (beside `takesExpandedBlocks`, same rules); `TakesViewModel`:
  `adopt` reads `heldBefore` while the outgoing projection is in hand (the session's record at a
  showing's first projection), and after VX-428's prune calls `closeFansThatCollapsed`, which closes what
  the rule names and writes the record; `rememberExpansion` writes the record with every open-set change;
  `openExpansionMemory`'s pin-order arm does the same as `adopt`. The rule runs on every host (it is the
  open set's own meaning), the memory only on THE takes board — Write's panel and the Lenses board bloom
  nothing, so it is inert there.
- Untouched: `Sync/`, schema, `Shared/` (no `App/Variorum/Shared/` file), the capability registry,
  `PaneSurface`, `EditorTextView`, `BlockRangeIndex`, `TakesArticleScroll.swift` (batch 1's), the
  seed/prune/landing roads, the wash's own drawing, `BlockDecor`/`CommentCardView`. No TK1 API, no
  attribute stamp, no display-pass consumer (the VX-702 class is not this road: both stale states were
  model state, not an undrawn frame). **MOBILE PARITY: nothing mobile-visible** (the Mac Takes board only;
  `EditorRouter` is the Mac app's).
- **Canon delta PROPOSED for the closeout** (SurfaceContracts › The note, the Takes bullet's open-fan
  sentence, in place): "…fans stay open across a mode switch and back, the seeded set in place before the
  board's first geometry report, pruned to the note's live blocks; **a fan that collapses to its one take
  closes, by any road and across a mode switch (a first-take door she opened is not a collapse)**…" + the
  VX-733 pointer. VX-732 needs no line (the every-surface comments contract already says it; the board
  now keeps it).

### THE PREDICTION TABLE (PENDING the window)

| # | Test | `vx770-b3-rev` (behaviour at 86d3652ec) | `vx770-b3-post` |
|---|---|---|---|
| 1 | `TakesCommentFeedLivenessTests/anUndoneAIsCommentsLeaveTheGutter` ×4 | **R** ×4 — the face (card, or margin grid's badge) still drawn after the undo, the card still in the hierarchy | G |
| 2 | `…/aCommentChangedFromOutsideTheBoardFollowsTheStore` | **R** — the edit, the delete and the last delete never reach the face | G |
| 3 | `…/herOpenPanelKeepsItsSeatWhenTheLastCommentLeaves` (GUARD) | G (the one-shot feed never moved) | G — **the risk:** if the test host refuses to present the popover and SwiftUI flips `panelShown` back, the face follows the store and this goes red on post; read its lines first, then W14 |
| 4 | `TakesCollapsedFanWashTests/anUndoneAIsTakesCloseTheFansTheyCollapsed` ×4 | **R** ×4 — B/C bloomed, in the open set, in the memory; the round trip seeds all four | G (A and D stay open) |
| 5 | `TakesCollapsedFanRoadsTests/aFanThatCollapsesWhileTheBoardIsAwayComesBackClosed` | **R** — B seeded and kept | G |
| 6 | `…/deletingAnOpenFansSecondTakeClosesIt` | **R** — stays open (and stays open after the ⌥⌘Z, so the B3-P2 line is red too) | G |
| 7 | `…/archivingAnOpenFansSecondTakeKeepsTheArchivedRoadOpen` (GUARD) | G | G |
| 8 | `…/theFirstTakeDoorStaysOpenThroughProjectionsAndARoundTrip` (GUARD) | G | G |
| 9 | `TakesOpenFanRuleTests` (2, pure — the rule's file stays on rev) | G | G |
| 10 | batch 2's `TakesCommentGutterTests/aCommentNeverMovesTheTakesProse` | R (as at window b2) | **uncertain** — green only if the closed first window's graph still runs its feed and drops its face (see the reading above); a red here is the harness's closed-window read, not this fix |
| 11 | the VX-428 family, batch 1's and batch 2's pins, the Takes/Lenses/Write-panel/Compare families, the spine | — | G — predicted; the risks are in the self-assessment |

**Reading the runs:** rows 1, 2, 4, 5, 6 red on rev and green on post = the member is FIXED. Any of them
GREEN on rev = that pin does not reproduce her staleness in the harness → recorded, never "fixed blind"
(row 4 green on rev would mean the observation never re-delivered — read whether `slot.hasFan` flipped
in the fixture line first). A guard red on post: read its own lines before anything else.

### P-8 — the costs, bounded

- **VX-732:** before, one `Queries.blockComments` read per REALIZED row on every realization (every row,
  commented or not, re-read on each re-realization while scrolling) — ∝ rows drawn, never live. Now ONE
  observation per mounted board: `Queries.containerComments` (one indexed join over the note's live
  placements), region `block_comment` + `container_block` — it wakes on comment and placement writes,
  never on a keystroke (`autosave` writes `variant` and `container` only, `Operations+Variant.swift`
  :20–31); each wake reads ∝ the note's own comments; `removeDuplicates` + the feed's equality guard keep
  an unchanged value from touching a face. Exactly Write's cost for the same note (Write runs this same
  observation for its whole lifetime). Faces: one per realized commented row, as before. Never per row,
  never polled.
- **VX-733:** per adopted projection, ZERO work while nothing is open; with fans open, at most three
  single passes over the slots with set lookups (the outgoing projection's held set, the collapse check
  only when something was held, the record's write) and one set comparison — inside the class `adopt`
  already pays per delivery (`pruneMergeSelection`'s `Set(new.slots.map(\.blockID))`, the projection
  read itself ∝ the note). Per open-set change (her gestures): one pass. Nothing realizes a row, lays out
  or reads the store.

## READY-FOR-SUITES — batch 3 (the orchestrator's window; from `App/Variorum/`)

Both trees are built (`DerivedData/vx770-b3-post` at HEAD's source, e7f9cefc2 — log
`DerivedData/logs/vx770-b3-post-build.log`; `DerivedData/vx770-b3-rev` — log `vx770-b3-rev-build.log`;
both TEST BUILD SUCCEEDED, 2.8 GB each). Run `test-without-building`:
`xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/<tree> test-without-building <args>`.
Confirm the "Test run with N tests" line and read the `skipped:` lines.

1. **THE RED RUN** on `vx770-b3-rev` (≈ 2–3 min):
   `-only-testing:VariorumTests/TakesCommentFeedLivenessTests -only-testing:VariorumTests/TakesCollapsedFanWashTests -only-testing:VariorumTests/TakesCollapsedFanRoadsTests -only-testing:VariorumTests/TakesOpenFanRuleTests`
   — expect 10 test functions, 16 cases (two parameterized ×4); the prediction table's rev column.
2. **THE GREEN RUN** on `vx770-b3-post` — every suite type in a test file exercising a changed source
   (`TakesViewModel`, `TakesBoardView`, `TakesBoardLayout`, `TakesShared`, `CommentGutterFace`,
   `EditorRouter`'s Takes memories; so the Takes, Lenses, Write-panel and Compare families, batch 1's and
   batch 2's pins) + batch 1's mode-switch/landing suites + the whole `TutorialWalkTests` spine —
   157 suite types:
   `-only-testing:VariorumTests/ArchivedListingTests -only-testing:VariorumTests/ArticleLandingProjectionArmTests -only-testing:VariorumTests/AutosaveConsolidationTests -only-testing:VariorumTests/AutosaveRegistryLifecycleTests -only-testing:VariorumTests/AutosaveRegistryReleaseGuardTests -only-testing:VariorumTests/BlockHighlightTests -only-testing:VariorumTests/BlockHistoryPaletteDoorTests -only-testing:VariorumTests/BlockHistoryPaneTests -only-testing:VariorumTests/BlockSelectionRegistryTests -only-testing:VariorumTests/BlockSelectionRuleTests -only-testing:VariorumTests/BlockTOCStatusTests -only-testing:VariorumTests/BoardBlockSelectionTests -only-testing:VariorumTests/BoardCommentGutterRuleTests -only-testing:VariorumTests/BoardDeleteRedoSurvivalTests -only-testing:VariorumTests/BoardDeleteRollbackTests -only-testing:VariorumTests/BoardDeliveryPolicyTests -only-testing:VariorumTests/BoardMergeDiagnosisTests -only-testing:VariorumTests/BookLeavingRegistryTests -only-testing:VariorumTests/BookLeavingSavepointTests -only-testing:VariorumTests/BranchDoorFlushTests -only-testing:VariorumTests/CapabilityRegistryTests -only-testing:VariorumTests/ComfortBandAndFlashTests -only-testing:VariorumTests/CommandRouterTests -only-testing:VariorumTests/CommentPanelHostLeavingTests -only-testing:VariorumTests/CommentPanelHostSuites -only-testing:VariorumTests/CommentPanelReleaseTests -only-testing:VariorumTests/CommentsAndReorderTests -only-testing:VariorumTests/CompareAnchorWholeTests -only-testing:VariorumTests/CompareCommentGutterTests -only-testing:VariorumTests/CompareCompositionTests -only-testing:VariorumTests/CompareLeavingSavepointTests -only-testing:VariorumTests/CompareLensesAlignmentTests -only-testing:VariorumTests/CompareOnePlacementTests -only-testing:VariorumTests/CompareVersionsTests -only-testing:VariorumTests/CompareViewModelTests -only-testing:VariorumTests/ConfirmationsSettingTests -only-testing:VariorumTests/CopyAllTakesDoorTests -only-testing:VariorumTests/CopyDoorFlushTests -only-testing:VariorumTests/CurrentBlockContinuityTests -only-testing:VariorumTests/DebugOracleSingletonWindowTests -only-testing:VariorumTests/DuplicateDoorsTests -only-testing:VariorumTests/FannedDefaultsBoardTests -only-testing:VariorumTests/FannedDefaultsTests -only-testing:VariorumTests/FanReorderDoorTests -only-testing:VariorumTests/FormattingSurfacesTests -only-testing:VariorumTests/LandingAimTests -only-testing:VariorumTests/LandingOffsetTests -only-testing:VariorumTests/LensesReorderTests -only-testing:VariorumTests/LifecycleFacesTests -only-testing:VariorumTests/MCPCompareLandingTests -only-testing:VariorumTests/MCPNavigationTests -only-testing:VariorumTests/MergeSelectionTests -only-testing:VariorumTests/ModeSwitchCarryTests -only-testing:VariorumTests/ModeSwitchFeelTests -only-testing:VariorumTests/MoveAndExecuteTests -only-testing:VariorumTests/NavigationDoorsTests -only-testing:VariorumTests/NavigationHistoryTests -only-testing:VariorumTests/NoLiteralColourTests -only-testing:VariorumTests/NoteVersionsPaneTests -only-testing:VariorumTests/OpenNotesTests -only-testing:VariorumTests/OriginBlockDoorTests -only-testing:VariorumTests/OutsideWriteLivePaneTests -only-testing:VariorumTests/OutsideWriteRingEndTests -only-testing:VariorumTests/PaneFindFaceTests -only-testing:VariorumTests/PaneRenderRestoreClipTests -only-testing:VariorumTests/PostDetailModeMemoryTests -only-testing:VariorumTests/PostDetailRoutingTests -only-testing:VariorumTests/QuitFinalizeSurfacesTests -only-testing:VariorumTests/RecoveryDoorsTests -only-testing:VariorumTests/RestoreLandingTests -only-testing:VariorumTests/SavepointCommitDoorTests -only-testing:VariorumTests/SavepointNameAskTests -only-testing:VariorumTests/SavepointNameCopyTests -only-testing:VariorumTests/SavepointNameFaceTests -only-testing:VariorumTests/SavepointRenameDoorTests -only-testing:VariorumTests/SavepointSealedDoorTests -only-testing:VariorumTests/SavepointTakesDoorTests -only-testing:VariorumTests/ScrubAndOutlineTests -only-testing:VariorumTests/SealDoorTests -only-testing:VariorumTests/SealedBookMemberDoorTests -only-testing:VariorumTests/ShowTakeDoorTests -only-testing:VariorumTests/SidebarSmokeTests -only-testing:VariorumTests/SplitAtNewlinesDoorTests -only-testing:VariorumTests/StaleWriteIntentTests -only-testing:VariorumTests/StatusCenterTests -only-testing:VariorumTests/StatusSeamVocabularyTests -only-testing:VariorumTests/TakeCardDoorTests -only-testing:VariorumTests/TakeCardMenuTitleTests -only-testing:VariorumTests/TakeChoiceBadgeTests -only-testing:VariorumTests/TakeLabelFaceTests -only-testing:VariorumTests/TakeMovedReceiptWordingTests -only-testing:VariorumTests/TakePaneDurabilityTests -only-testing:VariorumTests/TakePaneMeasureTests -only-testing:VariorumTests/TakesArticleRenderTests -only-testing:VariorumTests/TakesArticleScrollTests -only-testing:VariorumTests/TakesArticleWatchTests -only-testing:VariorumTests/TakesBarTakeCountTests -only-testing:VariorumTests/TakesBoardSoakTests -only-testing:VariorumTests/TakesBoardTests -only-testing:VariorumTests/TakesBufferConvergenceTests -only-testing:VariorumTests/TakesCardHeightTests -only-testing:VariorumTests/TakesChooseRingTests -only-testing:VariorumTests/TakesCollapsedFanRoadsTests -only-testing:VariorumTests/TakesCollapsedFanWashTests -only-testing:VariorumTests/TakesCommentFeedLivenessTests -only-testing:VariorumTests/TakesCommentGutterTests -only-testing:VariorumTests/TakesDivideTests -only-testing:VariorumTests/TakesEmptyBlockFaceTests -only-testing:VariorumTests/TakesEmptyStateTests -only-testing:VariorumTests/TakesEntryBandTests -only-testing:VariorumTests/TakesExpansionCostTests -only-testing:VariorumTests/TakesExpansionMemoryTests -only-testing:VariorumTests/TakesExpansionRemountTests -only-testing:VariorumTests/TakesFindBoardTests -only-testing:VariorumTests/TakesLandingTests -only-testing:VariorumTests/TakesLensFilterTests -only-testing:VariorumTests/TakesMarginGridAlignmentTests -only-testing:VariorumTests/TakesMarginGridCaptureTests -only-testing:VariorumTests/TakesOpenFanRuleTests -only-testing:VariorumTests/TakesPanelBlockLabelTests -only-testing:VariorumTests/TakesParkedFollowTests -only-testing:VariorumTests/TakesPresentationTests -only-testing:VariorumTests/TakesProseFaceTests -only-testing:VariorumTests/TakesRailPagingTests -only-testing:VariorumTests/TakesRoomTests -only-testing:VariorumTests/TakesSeededEntryLandingTests -only-testing:VariorumTests/TakesSlotDragTests -only-testing:VariorumTests/TakesSlotSplitExpandAllTests -only-testing:VariorumTests/TakesStepFollowModelTests -only-testing:VariorumTests/TakesStepFollowTests -only-testing:VariorumTests/TakesWordCountTests -only-testing:VariorumTests/TakeToBlockDoorTests -only-testing:VariorumTests/TrashPoolHonestyTests -only-testing:VariorumTests/TrashSurfaceTests -only-testing:VariorumTests/TutorialBookShapeTests -only-testing:VariorumTests/TutorialCurrencyTests -only-testing:VariorumTests/TutorialDeletionActsTests -only-testing:VariorumTests/TutorialDoorTests -only-testing:VariorumTests/TutorialFannedMatrixTests -only-testing:VariorumTests/TutorialLibraryActsTests -only-testing:VariorumTests/TutorialLookingActsTests -only-testing:VariorumTests/TutorialPrivacyChapterTests -only-testing:VariorumTests/TutorialStructureActsTests -only-testing:VariorumTests/TutorialTakesActsTests -only-testing:VariorumTests/TutorialWherePlacesActsTests -only-testing:VariorumTests/TutorialWritingActsTests -only-testing:VariorumTests/VX347AskedTakeFilingTests -only-testing:VariorumTests/VX347LeaveRuleTests -only-testing:VariorumTests/VX347LeavingBoxTests -only-testing:VariorumTests/VX347OneCommitPerFieldTests -only-testing:VariorumTests/WorkspaceModelTests -only-testing:VariorumTests/WorkspaceNamingTests -only-testing:VariorumTests/WriteBlockSelectionTests -only-testing:VariorumTests/WriteTakesPanelChooseTests -only-testing:VariorumTests/WriteTakesPanelKeysTests -only-testing:VariorumTests/WriteTakesPanelRoutedCommandTests -only-testing:VariorumTests/WriteTakesPanelTests`
   — all green expected, except row 10's uncertainty. Known load-dependent flakes that are NOT this batch's
   if met: VX-337's two (`TakesArticleScrollTests.aShortRowStraddlingTheFoldComesBackAboveIt` among them —
   run alone first). An unexpected `TakesEntryBandTests` red: the defaults domain first. The one
   deliberate capture-harness skip ("Margin grid captures (VX-136)") is the known shape.
3. Results into the prediction table; then `vx770-b3-rev` may be deleted (post stays for the walk).
   Batch 2's `vx770-b2-rev`/`-post` were left exactly as found (not deleted, not reused).

### THE USE WALK — batch 3 rows (an Opus walker under the orchestrator's claim; DEV-STORE Debug from `DerivedData/vx770-b3-post`; both voices; never Resume Sync)

A walk note of ~6 paragraphs; blocks 2 and 4 get a second take; the as-found `fan_style` read first and
restored at the end. Her undo road is the MCP door's: if a client is approved on the dev app, its
`add_comments` / `add_takes` are the staging; otherwise the any-road stagings below (each names one).
- **W10 (VX-732):** Takes up, block 2 with two comments in the gutter. MCP road: the client's
  `add_comments` on block 2, then ⌥⌘Z in Takes → the card leaves within a beat, no mode switch (her
  recording's 7 s, gone). No-MCP road: the same note in a second window (Write), delete one of block 2's
  comments from its panel → the Takes window's card loses that entry live. Capture before/after.
- **W11 (VX-733, her shape, slot split):** expand all with blocks 2 and 4 fanned; MCP road: `add_takes`
  on 2 and 4, ⌥⌘Z → the split goes AND the green wash goes from both; ⌘1 ⌘2 → still no wash. No-MCP
  road: in block 4's open fan, select a span and Move to New Take (one undo entry), then ⌥⌘Z → the new
  take leaves, block 4's wash goes. Capture the wash before/after, both voices.
- **W12 (R-770-1):** a block with THREE takes open; delete one → it stays open and washed (two remain).
- **W13 (B3-P1, the archive road):** archive the second take of an open fan → the block stays open with
  "archived · 1" under it, as the receipt says. Then Delete forever the archived take → it closes.
- **W14 (the seat):** a Takes card with one comment; press it (the panel opens), delete the comment in the
  panel → the panel STAYS (its deleted fold and Restore visible); close it → the card is gone. Same in
  Compare (the shared host).

### RESIDUE / NOTICED (not fixed — a line each; the orchestrator's to ticket or drop)

- **R-B3-1 (batch 2's one red — the reading above):** `aCommentNeverMovesTheTakesProse`'s deletion arm
  reads the oracle ACROSS A CLOSED WINDOW; `BoardCommentFaceRecord` forgets only on `.onDisappear`, which
  a closed-but-alive window need not run. My reading: the surviving record is the first board's, not a
  staleness of the second (whose read is born after the deletion). Batch 3's pins stage that deletion
  while the board is up and read the card's presence too. Reconciliation is batch 2's (the orchestrator's
  plan), not done here.
- **R-B3-2 (the render-write warnings):** I did not chase the "[SwiftUI] Modifying state during view
  update" lines (batch 2's reconciliation); for its reader: `BoardCommentFaceRecord` writes a static
  table in `onAppear`/`onChange` (not body), so it is not observable state and cannot itself raise that
  warning; batch 1 saw one in `TakesFindBoardTests` before batch 2 existed. Batch 3 removed one
  per-row `@State` write (the old feed's) and added none in a body.
- **R-B3-3 (a sibling stale wash, not this road):** with follow-the-scroll ON, a collapsed fan never
  washed (the rule there requires `hasFan`) — consistent; noted only because W11 should be walked with it
  off (the default).
- **R-B3-4 (B3-P2's consequence, for her):** with (a), a ⇧⌥⌘Z that re-adds an AI's takes after she undid
  them shows those fans closed; the deleted-BLOCK case keeps its open state for a ⌥⌘Z (VX-428's precedent,
  untouched) — an asymmetry she may want to rule.

## SELF-ASSESSMENT — batch 3 (the first of the two reviews — the implementer's)

- **What is proven, and how far.** Headless only: both trees compile (the pins against the pre-fix
  behaviour and against the fix), the revert is verified restored, and both mechanisms are code-traced
  from the operation her undo runs to the line that draws. Every red/green line is a prediction; the
  drawn wash itself is the walk's (the pins read `isBloomed`, the one input `washedCell` draws it
  from).
- **Why these shapes.** VX-732: the feed was the defect (no store axis), so the feed is now the one every
  other comment surface uses — no undo hook, no per-row re-key (which would read at autosave rate and still
  miss a count-preserving edit). VX-733: the open set's derivation was the defect, so the open set now
  hears the one transition that empties it of meaning — no undo hook, no "close unfanned blocks" rule
  (which would break R72's door and VX-428's own pinned memory of an unfanned bloom). Neither closes a fan
  she opened that still holds takes (R-770-1), and the archive road keeps its in-place listing.
- **What could regress, and why I think it does not.** (1) *The comments popover:* the live feed could
  have yanked her open panel; the seat guards it, in the shared host (Compare gains the same). (2) *A
  collapse closing more than she expects:* deleting the second take of a fan she is working in now closes
  the block (its ⑂+ badge reopens it) — that IS the member's rule, but it is a visible change on a road she
  did not report; W12/W13 look at it. (3) *Two windows on one note:* both boards write the same session
  keys (pre-existing for the open set; the held record follows the same last-writer rule). (4) *Hosts
  other than THE board:* the rule runs on Write's panel and the Lenses board too, where nothing blooms —
  inert by construction; no pin there reads the open set after a collapse (searched).
- **Risks in the pins themselves.** The seat guard depends on the test host presenting a SwiftUI popover
  (prediction row 3). The mounted pins wait on two observations (the takes projection and the comments)
  and settle on both before judging. The VX-732 pin's margin-grid case lands on the badge rung (the
  engaged rail leaves ~85 pt of gutter), handled by kind.
- **Scope kept.** Two members only; batch 2's red reconciled by reading, not by edit; `TakesArticleScroll`
  untouched; no product decision taken beyond B3-P1/B3-P2, both PROVISIONAL and one predicate each.

## READY-FOR-SUITES — RECONCILIATION (batch 2's reconciliation; the orchestrator's window; from `App/Variorum/`)

The record of what was reconciled and why is batch 2's "### RECONCILIATION" subsection. Run
`test-without-building`: `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/<tree> test-without-building <args>`;
confirm the "Test run with N tests" line and read the `skipped:` lines.

1. **Batch 3's RED RUN — UNCHANGED** on `vx770-b3-rev`: `-only-testing:VariorumTests/TakesCommentFeedLivenessTests -only-testing:VariorumTests/TakesCollapsedFanWashTests -only-testing:VariorumTests/TakesCollapsedFanRoadsTests -only-testing:VariorumTests/TakesOpenFanRuleTests`
   — exactly batch 3's arguments and prediction column. **Validity, confirmed:** `vx770-b3-rev` is a
   BUILT tree (its `.xctestrun` and build log both 03:57:58, untouched since); the reconciliation's
   edits are at HEAD only and are not in it, so the red run measures exactly what batch 3 built.
   **Stated LOUDLY:** the reconciliation does touch two files on batch 3's path — `TakesBoardView.swift`
   (one of b3-rev's six reverted behaviour files: ONE DEBUG modifier line, `.boardCommentFaceMount(model)`)
   and `BoardCommentFaceOracle.swift` (the oracle batch 3's red-run pins read). Neither alters the
   b3-rev binary. On the reconciled tree batch 3's pins read the per-board oracle through `reader(scope)`,
   which for one mounted board returns that board's one record per block, the same answer as before, so
   batch 3's green expectations stand unchanged.
2. **THE COMBINED GREEN RUN** on `vx770-recon-post` — batch 3's 157 types ∪ batch 2's three suites
   (`TakesCommentGutterTests`, `CompareCommentGutterTests`, `BoardCommentGutterRuleTests` — already in batch
   3's list) = **157 suite types** (deduped):
   `-only-testing:VariorumTests/ArchivedListingTests -only-testing:VariorumTests/ArticleLandingProjectionArmTests -only-testing:VariorumTests/AutosaveConsolidationTests -only-testing:VariorumTests/AutosaveRegistryLifecycleTests -only-testing:VariorumTests/AutosaveRegistryReleaseGuardTests -only-testing:VariorumTests/BlockHighlightTests -only-testing:VariorumTests/BlockHistoryPaletteDoorTests -only-testing:VariorumTests/BlockHistoryPaneTests -only-testing:VariorumTests/BlockSelectionRegistryTests -only-testing:VariorumTests/BlockSelectionRuleTests -only-testing:VariorumTests/BlockTOCStatusTests -only-testing:VariorumTests/BoardBlockSelectionTests -only-testing:VariorumTests/BoardCommentGutterRuleTests -only-testing:VariorumTests/BoardDeleteRedoSurvivalTests -only-testing:VariorumTests/BoardDeleteRollbackTests -only-testing:VariorumTests/BoardDeliveryPolicyTests -only-testing:VariorumTests/BoardMergeDiagnosisTests -only-testing:VariorumTests/BookLeavingRegistryTests -only-testing:VariorumTests/BookLeavingSavepointTests -only-testing:VariorumTests/BranchDoorFlushTests -only-testing:VariorumTests/CapabilityRegistryTests -only-testing:VariorumTests/ComfortBandAndFlashTests -only-testing:VariorumTests/CommandRouterTests -only-testing:VariorumTests/CommentPanelHostLeavingTests -only-testing:VariorumTests/CommentPanelHostSuites -only-testing:VariorumTests/CommentPanelReleaseTests -only-testing:VariorumTests/CommentsAndReorderTests -only-testing:VariorumTests/CompareAnchorWholeTests -only-testing:VariorumTests/CompareCommentGutterTests -only-testing:VariorumTests/CompareCompositionTests -only-testing:VariorumTests/CompareLeavingSavepointTests -only-testing:VariorumTests/CompareLensesAlignmentTests -only-testing:VariorumTests/CompareOnePlacementTests -only-testing:VariorumTests/CompareVersionsTests -only-testing:VariorumTests/CompareViewModelTests -only-testing:VariorumTests/ConfirmationsSettingTests -only-testing:VariorumTests/CopyAllTakesDoorTests -only-testing:VariorumTests/CopyDoorFlushTests -only-testing:VariorumTests/CurrentBlockContinuityTests -only-testing:VariorumTests/DebugOracleSingletonWindowTests -only-testing:VariorumTests/DuplicateDoorsTests -only-testing:VariorumTests/FannedDefaultsBoardTests -only-testing:VariorumTests/FannedDefaultsTests -only-testing:VariorumTests/FanReorderDoorTests -only-testing:VariorumTests/FormattingSurfacesTests -only-testing:VariorumTests/LandingAimTests -only-testing:VariorumTests/LandingOffsetTests -only-testing:VariorumTests/LensesReorderTests -only-testing:VariorumTests/LifecycleFacesTests -only-testing:VariorumTests/MCPCompareLandingTests -only-testing:VariorumTests/MCPNavigationTests -only-testing:VariorumTests/MergeSelectionTests -only-testing:VariorumTests/ModeSwitchCarryTests -only-testing:VariorumTests/ModeSwitchFeelTests -only-testing:VariorumTests/MoveAndExecuteTests -only-testing:VariorumTests/NavigationDoorsTests -only-testing:VariorumTests/NavigationHistoryTests -only-testing:VariorumTests/NoLiteralColourTests -only-testing:VariorumTests/NoteVersionsPaneTests -only-testing:VariorumTests/OpenNotesTests -only-testing:VariorumTests/OriginBlockDoorTests -only-testing:VariorumTests/OutsideWriteLivePaneTests -only-testing:VariorumTests/OutsideWriteRingEndTests -only-testing:VariorumTests/PaneFindFaceTests -only-testing:VariorumTests/PaneRenderRestoreClipTests -only-testing:VariorumTests/PostDetailModeMemoryTests -only-testing:VariorumTests/PostDetailRoutingTests -only-testing:VariorumTests/QuitFinalizeSurfacesTests -only-testing:VariorumTests/RecoveryDoorsTests -only-testing:VariorumTests/RestoreLandingTests -only-testing:VariorumTests/SavepointCommitDoorTests -only-testing:VariorumTests/SavepointNameAskTests -only-testing:VariorumTests/SavepointNameCopyTests -only-testing:VariorumTests/SavepointNameFaceTests -only-testing:VariorumTests/SavepointRenameDoorTests -only-testing:VariorumTests/SavepointSealedDoorTests -only-testing:VariorumTests/SavepointTakesDoorTests -only-testing:VariorumTests/ScrubAndOutlineTests -only-testing:VariorumTests/SealDoorTests -only-testing:VariorumTests/SealedBookMemberDoorTests -only-testing:VariorumTests/ShowTakeDoorTests -only-testing:VariorumTests/SidebarSmokeTests -only-testing:VariorumTests/SplitAtNewlinesDoorTests -only-testing:VariorumTests/StaleWriteIntentTests -only-testing:VariorumTests/StatusCenterTests -only-testing:VariorumTests/StatusSeamVocabularyTests -only-testing:VariorumTests/TakeCardDoorTests -only-testing:VariorumTests/TakeCardMenuTitleTests -only-testing:VariorumTests/TakeChoiceBadgeTests -only-testing:VariorumTests/TakeLabelFaceTests -only-testing:VariorumTests/TakeMovedReceiptWordingTests -only-testing:VariorumTests/TakePaneDurabilityTests -only-testing:VariorumTests/TakePaneMeasureTests -only-testing:VariorumTests/TakesArticleRenderTests -only-testing:VariorumTests/TakesArticleScrollTests -only-testing:VariorumTests/TakesArticleWatchTests -only-testing:VariorumTests/TakesBarTakeCountTests -only-testing:VariorumTests/TakesBoardSoakTests -only-testing:VariorumTests/TakesBoardTests -only-testing:VariorumTests/TakesBufferConvergenceTests -only-testing:VariorumTests/TakesCardHeightTests -only-testing:VariorumTests/TakesChooseRingTests -only-testing:VariorumTests/TakesCollapsedFanRoadsTests -only-testing:VariorumTests/TakesCollapsedFanWashTests -only-testing:VariorumTests/TakesCommentFeedLivenessTests -only-testing:VariorumTests/TakesCommentGutterTests -only-testing:VariorumTests/TakesDivideTests -only-testing:VariorumTests/TakesEmptyBlockFaceTests -only-testing:VariorumTests/TakesEmptyStateTests -only-testing:VariorumTests/TakesEntryBandTests -only-testing:VariorumTests/TakesExpansionCostTests -only-testing:VariorumTests/TakesExpansionMemoryTests -only-testing:VariorumTests/TakesExpansionRemountTests -only-testing:VariorumTests/TakesFindBoardTests -only-testing:VariorumTests/TakesLandingTests -only-testing:VariorumTests/TakesLensFilterTests -only-testing:VariorumTests/TakesMarginGridAlignmentTests -only-testing:VariorumTests/TakesMarginGridCaptureTests -only-testing:VariorumTests/TakesOpenFanRuleTests -only-testing:VariorumTests/TakesPanelBlockLabelTests -only-testing:VariorumTests/TakesParkedFollowTests -only-testing:VariorumTests/TakesPresentationTests -only-testing:VariorumTests/TakesProseFaceTests -only-testing:VariorumTests/TakesRailPagingTests -only-testing:VariorumTests/TakesRoomTests -only-testing:VariorumTests/TakesSeededEntryLandingTests -only-testing:VariorumTests/TakesSlotDragTests -only-testing:VariorumTests/TakesSlotSplitExpandAllTests -only-testing:VariorumTests/TakesStepFollowModelTests -only-testing:VariorumTests/TakesStepFollowTests -only-testing:VariorumTests/TakesWordCountTests -only-testing:VariorumTests/TakeToBlockDoorTests -only-testing:VariorumTests/TrashPoolHonestyTests -only-testing:VariorumTests/TrashSurfaceTests -only-testing:VariorumTests/TutorialBookShapeTests -only-testing:VariorumTests/TutorialCurrencyTests -only-testing:VariorumTests/TutorialDeletionActsTests -only-testing:VariorumTests/TutorialDoorTests -only-testing:VariorumTests/TutorialFannedMatrixTests -only-testing:VariorumTests/TutorialLibraryActsTests -only-testing:VariorumTests/TutorialLookingActsTests -only-testing:VariorumTests/TutorialPrivacyChapterTests -only-testing:VariorumTests/TutorialStructureActsTests -only-testing:VariorumTests/TutorialTakesActsTests -only-testing:VariorumTests/TutorialWherePlacesActsTests -only-testing:VariorumTests/TutorialWritingActsTests -only-testing:VariorumTests/VX347AskedTakeFilingTests -only-testing:VariorumTests/VX347LeaveRuleTests -only-testing:VariorumTests/VX347LeavingBoxTests -only-testing:VariorumTests/VX347OneCommitPerFieldTests -only-testing:VariorumTests/WorkspaceModelTests -only-testing:VariorumTests/WorkspaceNamingTests -only-testing:VariorumTests/WriteBlockSelectionTests -only-testing:VariorumTests/WriteTakesPanelChooseTests -only-testing:VariorumTests/WriteTakesPanelKeysTests -only-testing:VariorumTests/WriteTakesPanelRoutedCommandTests -only-testing:VariorumTests/WriteTakesPanelTests`
   — all green expected. Batch 2's reconciled line to read: `TakesCommentGutterTests/aCommentNeverMovesTheTakesProse`
   GREEN (its deletion-arm assertion now asks the second board by name), and its `VX770-RECON:` print
   — "card 2 entries" confirms the closed first board's leftover record directly (R-B3-1's mechanism);
   "none" means the closed window's graph heard the deletion or the close. Either way the second board's
   own line is the assertion. Batch 3's row 10 (its note of this same red) resolves with it. The Write
   decoration family that batch 2's green run covered (T1/T2 in `BlockDecor.swift`) is untouched by batch 3
   and by the reconciliation, so it is not re-run by design (window b2 already holds its green).
   Known shapes as before: VX-337's two load-dependent flakes; the defaults domain first on an unexpected
   `TakesEntryBandTests` red; the one capture-harness skip.
3. **Superseded, for deletion at the window:** `DerivedData/vx770-b2-post`, `vx770-b2-rev` and
   `vx770-b2-prerevert` (batch 2's trees; window b2 holds their runs). `vx770-b3-rev` stays for the red
   run; `vx770-b3-post` is superseded by `vx770-recon-post` for the green run (it lacks the reconciliation).

---

## BATCH 4 RECORD — VX-740 + VX-757, the Compare pair (implementer: opus-implementer, 2026-11-04)

**NOT DONE (first line, kept current):** every mounted red/green claim below is a PREDICTION until the
orchestrator's suite window (this session is headless — no `xcodebuild test`, no app launch, no stage);
the use walk (W15–W16, both voices); the cold ladder.

**LIVE STATUS**
| piece | state |
|---|---|
| Reading (this file whole; the vx-736 ladder round 1's VX-740 finding; SurfaceContracts › The note — Compare holds Outline, versions in Compare; VX-757 on Linear — no detail beyond her sentence) | DONE |
| Trace, both members (code read at HEAD 7c98fcc5f; written below before any code) | DONE (b268ccf46) |
| VX-740 pin (`VariorumTests/CompareOutlineMintColumnTests.swift`, pre-existing API only) | DONE (b9d0e1b24) — compile PENDING the b4 build |
| VX-740 fix (P-770-1 — `makeOutlinePost` yields to the auto-fill's seat) | DONE (a5718b23e) |
| VX-757 pins (`VariorumTests/CompareToggleIdentityTests.swift`, pre-existing API only) | DONE (8c87bcd0c) — compile PENDING the b4 build |
| VX-757 fix (`CompareRow.spineID` + one row structure in `rowView`/`peerColumn`) | DONE (eefd41c78) |
| Build-for-testing `DerivedData/vx770-b4` at HEAD | DONE — TEST BUILD SUCCEEDED (logs `App/Variorum/DerivedData/logs/vx770-b4-build.log` — the first pass, red on three test-file concurrency errors, fixed in the next commit — and `vx770-b4-build2.log`); no new warning in a touched file |
| **Behavioural revert** (announced 41274886d before it started; ran 04:38–04:42): `Features/Takes/CompareBoardView.swift` — the one behaviour file, carrying BOTH fixes — restored to b9d0e1b24 (the VX-740 pin commit; its copy is byte-equal to the batch's starting HEAD 7c98fcc5f, `git diff 7c98fcc5f` empty) by `git checkout b9d0e1b24 --`, the two pin files at HEAD; built into `DerivedData/vx770-b4-rev` (TEST BUILD SUCCEEDED, log `App/Variorum/DerivedData/logs/vx770-b4-rev-build.log` — the pins compile against the pre-fix behaviour); then `git checkout HEAD --` | DONE — **no revert in flight; the source is HEAD**: `git diff HEAD` empty, `git status` clean, `shasum -a 256 -c …/vx770-b4-prerevert/sha256-head.txt` OK, byte-identical (`cmp`) to the prerevert copy. The two binaries differ as intended: `nm` finds `spineID` 8× in `vx770-b4`'s `Variorum.debug.dylib`, 0× in `vx770-b4-rev`'s |
| READY-FOR-SUITES, prediction table, walk rows, residue, self-assessment | DONE (this commit) |

### THE TRACE — VX-740 (re-located at HEAD; the vx-736 ladder's mechanism, confirmed by code read)

The file moved under batches 2/recon; the two sites are now `CompareBoardView.swift:438–442` (the
auto-fill inside `adopt`) and `:982–1000` (`makeOutlinePost`).
1. A note with no `version_of` peer opens Compare on the offer band: its first projection's
   `versionPeers` is empty, so `adopt`'s auto-fill (`!autoFilled, peerSlots.first?.postID == nil,
   let first = new.versionPeers.first`) does not fire and `autoFilled` stays false.
2. She presses "make outline note" (the offer card or the header door). `makeOutlinePost` suspends on
   `session.runner.run` — the runner is an actor; the mint's body runs on its executor, off main.
3. Inside the body `mintOutlinePost` writes the outline (same wing — VX-727 — and ONE `version_of`
   edge on the first pair, `Operations+Versions.swift:429–430`) and commits; GRDB's observation of the
   board's projection (`restartObservation`, region includes `edge`/`container`) re-fetches on the commit
   and delivers on the main actor. Then `registerMintedContainerEntry` registers the undo entry, the
   body returns, and the continuation of `makeOutlinePost` is enqueued on main.
4. Two main-actor jobs race: the observation's delivery and the resume. When the DELIVERY runs first
   (J5's walk, 2026-11-02): `adopt` sees `versionPeers.first == the outline`, the auto-fill seats it in
   slot 0 and sets `autoFilled`. The resume then finds NO empty slot and, with `peerSlots.count == 1 < 3`,
   APPENDS a second `PeerSlot` holding the same id — two columns, one note, one Library row.
5. When the RESUME runs first, it seats slot 0 and sets `autoFilled`; the later delivery's auto-fill
   cannot fire — one column. Hence "sometimes", and why no pin saw it: no test calls `makeOutlinePost`.

**The pin's staging (the ladder's named shape, made deterministic with no product seam):** the session's
`UndoStack` change observer fires on the runner's thread from `registerMintedContainerEntry` — AFTER the
mint's write has committed and BEFORE `run` returns. The pin installs its own observer that, once, hops
to main SYNCHRONOUSLY (`DispatchQueue.main.sync` — main is idle, the test is awaiting) and adopts a fresh
read of the board's projection — exactly the delivery of step 4, landed before the resume can run. Then
the REAL `makeOutlinePost` resumes. Assert one column holding the outline, in the auto-fill's slot.
**The fix (P-770-1, the orchestrator's PROVISIONAL, binding):** the resume looks for `result.post.id` in
the slots first; found, it yields — the auto-fill's seat stands. No other arm changes (the full board's
words, a different note seated by the auto-fill, the ordinary order).

### THE TRACE — VX-757 (repro-first; code read at HEAD, nothing mounted)

**Which toggle.** No control is called "track paragraphs". Compare's header carries three session-local
chips (`CompareBoardView.swift:1305–1330`): "follow this note's order" (its help: *"the other columns
arrange themselves to sit beside their related blocks, in this note's order"* — the one whose job is
tracking paragraphs across the columns, so her most likely referent), "lineage colors", "related blocks
only". The trace covers all three.

**What one toggle does.** None of the three writes the store or touches the projection: each flips a
model property; `body` re-reads `model.display`, which re-runs the pure composition
(`CompareComposition.segments`, `CompareModels.swift:71–177`) and hands `ForEach(display.rows)`
(`:1708`) a new row list. The rows are keyed by `CompareRow.id` (`:108–115`): an aligned row is
`aligned-<anchor block>`, a free row `free-<index>-<anchor>-<peer blocks>`. And `rowView` (`:1724–1760`)
draws the two kinds through a `switch` — two DIFFERENT view structures (the free arm's peer cells sit
directly in the row's `HStack`; the aligned arm wraps them in a `VStack` with the "moved" line and a
`ForEach` over the kin).
- **"follow this note's order"** — ON composes aligned rows wherever lineage speaks; OFF collapses the
  board to ONE free segment (`segments`' `guard followAnchorOrder … else { return wholeFree() }`). So on a
  pair that SHARES lineage (a duplicate, an outline, a divided copy) every aligned row becomes a free row:
  every row's id changes AND its cells move to the other arm of the `switch`. SwiftUI's identity is
  structural: every realized row is torn down and rebuilt, and with it every `CompareCellView` and its
  `PaneSurfaceView` — `dismantleNSView`, then a fresh `makeNSView` per cell.
- **"related blocks only"** — aligned rows keep their ids (the anchor is exempt from the filter, kin
  survive it), but a free row's id carries its peer blocks and its running index, so a free stretch whose
  peer side the filter hides or shows is re-keyed and rebuilt (e.g. `free-0-b-x` ↔ `free-0-b-·`).
- **"lineage colors"** — changes only `railKin`'s answer; no row id or arm changes; nothing is rebuilt.

**Why a rebuilt pane is a visible flicker.** A made pane is born at `@State height = 24`
(`PaneSurface.swift:1232`), and `makeNSView` measures it at install, BEFORE SwiftUI gives it width
(`install`'s own comment, `:2013–2016`; `PaneTextView(usingTextLayoutManager:)` starts at a zero frame,
`:811–836`), so its first frames carry the 24-pt seed or the zero-width measurement. Its real height
arrives only from the width-gated layout hook (`layout()` → `onWidthChange` → `remeasure`, `:737–747`),
whose `@State` write lands mid-update and is re-made by `PanePublisher`'s deferred heal turn
(`:144–260`) — the "Modifying state during view update" lines the batch-2 reconciliation counted on every
mounted board. A board whose every realized pane is made in one transaction therefore re-lays its whole
column from wrong heights to right ones over the next turn(s): rows collapse/stretch and settle back —
the flicker. The toggle she pressed changes NOTHING she should see on a same-order pair (the twin's
blocks pair 1:1 either way), so the whole picture is a teardown and rebuild of an identical board.

**The conditional arm — her "sometimes":** (1) the rebuild happens only when lineage connects the
columns — a zero-lineage pair composes ONE free segment in both arms, identical ids, nothing rebuilt
(the toggle is inert there); "related blocks only" rebuilds only the free stretches it changes;
"lineage colors" never rebuilds. (2) Whether the wrong-height frame reaches the screen depends on whether
the mid-update height write lands inside the same display cycle — timing the harness does not own.

**What the harness CAN see, and what it cannot.** It can see the mechanism's state transition directly:
the identity of every pane (`PaneTextView`, identifier `pane:compare|<variant>`) before and after the
toggle — re-made objects on the old tree. It cannot see the painted frame; the pin PRINTS each turn's
pane heights against their measurements after the toggle (`VX757-TRACE`) so the window's red run records
whether a wrong-height turn is observable, never asserting a paint. The walk row (W15) is the eye.

**The fix's shape (decided from the trace, no product behaviour):** the toggles stop re-making panes that
stay put. (a) A row's identity is its SPINE — the anchor block it holds (`a:<block>`), else the first peer
block it holds (`p<column>:<block>`) — never its kind or its running index; unique by construction (I2: a
block sits in one column; each column holds a block once). (b) `rowView` draws both kinds through ONE
structure: the anchor cell, then per peer column one `VStack` (the "moved" line when aligned, the column's
blocks in a `ForEach` keyed by block id, the free arm's 1-pt clear spacer when empty) — the same layout
each arm drew before, so a cell's identity is (row spine, column, block) in both arms. On a same-order pair
the toggle then re-makes nothing; on a re-ordered pair only the peer cells that change rows are re-made (a
cell cannot keep its view across parents). Untouched: `CompareCellView`, the comment lane and its gutter
face (batch 2), the DEBUG oracle mount, the composition brain and its pins, the projection, every op.

## ENVIRONMENT HAZARD — the dev store is likely v1_36 (the coordinator, ~04:4x; this branch knows v1_35)

VX-500's test hosts have carried `v1_36_fk_child_indexes` since 03:36 and the shared dev store
was written at 04:32; `VariorumApp` builds the live `AppBootstrap()` at every host launch, so the
store is very likely migrated past this branch's schema and `LibraryClassifier` would refuse it
(`.newerSchema`). Consequences for this run:
1. **The b3r window (and any later gate):** most suites inject stores, but the set includes the
   tutorial spine — an UNEXPECTED red in any suite that mounts the real app shell is suspected as
   the dev store's newer-schema refusal BEFORE the diff, and reported to nov3coordinator. It
   would look like a regression and isn't one.
2. **The walk: ROAD B, decided now** (content-only walk, no Castle — independent of GitHub's
   incident and VX-500's merge): set `Variorum-dev/` aside WHOLE by ONE rename per
   `Tools/WalkKit/README.md` Step-0 traps (never file-by-file — the store-adjacent
   `variorum-restore-hold.json` must ride the rename), md5 the library files + marker first, walk
   the fresh store this build seeds (empty is fine — the walk mints its own repro content), and
   at release restore by the reverse rename with the md5 check. Declared to the coordinator.

### AS BUILT

Commits: traces b268ccf46 · VX-740 pin b9d0e1b24 · VX-740 fix a5718b23e · VX-757 pins 8c87bcd0c · VX-757 fix
eefd41c78 · the pins' compile fix cd65658ea · LIVE STATUS 41274886d + this record.
- **VX-740 — the pin** (`App/Variorum/VariorumTests/CompareOutlineMintColumnTests.swift`, pre-existing API
  only): `anOutlineTheAutoFillSeatsWhileTheMintIsInFlightOpensOneColumn` — a two-block draft with no version
  peer, its first projection adopted (the offer band); `MidMintDelivery` installs the session undo stack's
  change observer, which fires once on the runner's thread inside the mint's registration (after its write
  commits, before `run` returns) and hops to main SYNCHRONOUSLY to adopt a fresh `CompareViewModel.read` —
  the store observation's delivery, landed where her race landed it; then the REAL `makeOutlinePost`
  resumes. Premise lines: the delivery ran mid-act and the auto-fill seated the outline. Assertions: ONE
  column, holding the outline, in the auto-fill's slot (same slot id — P-770-1's "the seat stands"). Guards:
  `theOrdinaryOrderSeatsTheOutlineInTheEmptySlot`; `anOutlineMintedBesideAnOpenNoteStillOpensItsOwnColumn`
  (a board already showing the twin, the same mid-act delivery: the outline still opens beside it — the
  dedupe yields only to the SAME note).
- **VX-740 — the fix** (`Features/Takes/CompareBoardView.swift`, `makeOutlinePost`): after `autoFilled = true`,
  a slot already holding `result.post.id` returns — the auto-fill's seat stands. Nothing else changes
  (the empty-slot seat, the append beside other notes, the full board's words).
- **VX-757 — the pins** (`App/Variorum/VariorumTests/CompareToggleIdentityTests.swift`, pre-existing API only;
  a mounted `CompareBoardView` at 1100 pt, the batch-2 rig's shape): every Compare pane's OBJECT, by its
  identifier `pane:compare|‹take›`, read before and after each toggle — `followingTheNotesOrderOffAndOnRemakesNoPaneOnASameOrderPair`
  (a six-block draft + its duplicate-as-version twin; premise: every row aligned ON, every row free OFF) and
  `relatedBlocksOnlyOffAndOnKeepsThePanesThatStay` (draft [a1 a2 a3 b] + twin [a1' a2' a3' x]; premise: the
  toggle changed the composition's rows; the panes that stay, `b`'s among them, must be the same panes).
  Guards (the trace's inert arms, green on both trees): `lineageColorsOffAndOnRemakesNoPane`,
  `aPairWithNoLineageIsInertUnderTheOrderToggle` (premise: the same rows in both arms). Each flip PRINTS six
  `VX757-TRACE` lines (panes · re-made · panes rendering off their own measurement · height range) —
  diagnostics for the window, never asserted.
- **VX-757 — the fix** (`Features/Takes/CompareBoardView.swift` only): `CompareRow.spineID` (`a:‹anchor block›`,
  else `p‹column›:‹first peer block›`) keys the board's `ForEach`; `CompareRow.anchorBlockID` /
  `peerBlocks(_:)` / `peerMoved(_:)` / `isFree` feed ONE row structure (`rowView` + `peerColumn`): the anchor
  cell, then per peer column a `VStack` — the "moved" line (aligned only, as before), the free arm's 1-pt
  clear space when the column is empty (as `cellOrSpace` drew it), the column's blocks in a `ForEach` keyed
  by block id — the same frames and spacing each arm drew before. `CompareRow.id` stays (the type's
  `Identifiable`; nothing reads its spelling). Untouched: `CompareCellView` (the lane, the gutter face,
  the drop targets), the DEBUG oracle mount, `CompareComposition` and its pins, the projection, every op.
- Untouched by the batch: `Sync/`, schema, `Shared/` (no `App/Variorum/Shared/` file in the diff), the
  capability registry, `PaneSurface`, `EditorTextView`, `BlockRangeIndex`, every Takes file. No TK1 API, no
  attribute stamp. **MOBILE PARITY: nothing mobile-visible** (the Mac Compare board only). **Canon delta: none
  proposed** — one press opening one column, and a display toggle changing only the display, are what the
  contract already says; P-770-1 rides the orchestrator's QUESTIONS bundle as logged. No new PROVISIONAL.

### THE PREDICTION TABLE (PENDING the window)

| # | Test | `vx770-b4-rev` (CompareBoardView.swift at b9d0e1b24) | `vx770-b4` (HEAD) |
|---|---|---|---|
| 1 | `CompareOutlineMintColumnTests/anOutlineTheAutoFillSeatsWhileTheMintIsInFlightOpensOneColumn` | **R** — columns `[outline, outline]`, 2 slots; premise lines G | G |
| 2 | `…/theOrdinaryOrderSeatsTheOutlineInTheEmptySlot` (GUARD) | G | G |
| 3 | `…/anOutlineMintedBesideAnOpenNoteStillOpensItsOwnColumn` (GUARD) | G | G |
| 4 | `CompareToggleIdentityTests/followingTheNotesOrderOffAndOnRemakesNoPaneOnASameOrderPair` | **R** — re-made 12 of 12 on each flip; premise lines G | G |
| 5 | `…/relatedBlocksOnlyOffAndOnKeepsThePanesThatStay` | **R** — re-made: `b`'s pane (its free row's id carried the peer side), on each flip | G |
| 6 | `…/lineageColorsOffAndOnRemakesNoPane` (GUARD) | G | G |
| 7 | `…/aPairWithNoLineageIsInertUnderTheOrderToggle` (GUARD) | G | G |
| 8 | the Compare-exercising families + the spine (READY-FOR-SUITES 2) | — | G — predicted; risks in the self-assessment |

**Reading the runs:** rows 1, 4, 5 red on rev and green on HEAD = the member is FIXED by the red/green
standard. Row 1 GREEN on rev = the staging did not reproduce the race (read its premise lines first — a
premise red means the delivery did not run mid-act); never "fixed blind". Rows 4/5 GREEN on rev = the harness
does not re-make panes on the toggle, so the trace's mechanism is wrong for this harness — VX-757 then falls
to RECORD-ONLY with W15 as its evidence, and the fix is reverted or held at the orchestrator's word. The
`VX757-TRACE` lines on rev are the harness's view of the wrong-height turns (the `diverged` column); they are
evidence, not a gate.

### P-8 — the costs

- **VX-740:** one `contains` over at most three slots, once per press.
- **VX-757:** `spineID` is O(columns) per composed row, computed where SwiftUI diffs the rows the
  composition already produced each pass (the composition itself is unchanged — one pass over the shown
  notes' blocks, P1's class). The win is the other way round: a toggle on a lineage-sharing pair no longer
  dismantles and re-makes every realized pane (each re-make a fresh TK2 view, its install measure and its
  width-hook re-measure) — a toggle now costs a re-diff and a re-layout of the rows on screen.

### THE USE WALK — batch 4 rows (an Opus walker under the orchestrator's claim; DEV-STORE Debug from `DerivedData/vx770-b4`; both voices; never Resume Sync)

- **W15 (VX-757 — her toggle):** a walk note of ~8 paragraphs (several wrapping at a Compare column), and its
  Duplicate with Tags twin; Compare the note with the twin (the auto-fill seats it). Toggle "follow this note's
  order" off and on five times, then "related blocks only" off and on five times — capture a short screen
  recording (or a 10-frame burst per press) at the top of the board AND scrolled to the middle: **no flicker,
  no row collapsing and re-growing, the page does not jump**. Then edit the twin so its tail differs (add a
  paragraph only it has): "related blocks only" off/on → only that paragraph comes and goes. Look-only line:
  re-order one twin paragraph (drag ⠿) and toggle "follow" — the moved paragraph's own cell re-makes (R-B4-1,
  expected), nothing else should.
- **W16 (VX-740):** three fresh notes with no versions, each: Compare → the offer band's "make outline note" →
  exactly ONE "outline of …" column every time (the race is timing — three tries); the Library lists one outline
  per note. Then on a note already beside its twin, the header's "make outline note" → the outline opens as a
  second column beside the twin.

## READY-FOR-SUITES — batch 4 (the orchestrator's window; from `App/Variorum/`)

Both trees are built: `DerivedData/vx770-b4` (HEAD's source — logs `DerivedData/logs/vx770-b4-build.log` (the first
pass, three test-file errors) + `vx770-b4-build2.log` (TEST BUILD SUCCEEDED)) and `DerivedData/vx770-b4-rev`
(log `vx770-b4-rev-build.log`, TEST BUILD SUCCEEDED); 2.8 GB each; 42 GiB free after both. Run
`test-without-building`: `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/<tree> test-without-building <args>`.
Confirm the "Test run with N tests" line and read the `skipped:` lines; keep the `VX757-TRACE` lines.

1. **THE RED RUN** on `vx770-b4-rev` (≈ 1–2 min): `-only-testing:VariorumTests/CompareOutlineMintColumnTests -only-testing:VariorumTests/CompareToggleIdentityTests`
   — expect 7 test functions in 2 suites; the prediction table's rev column (rows 1, 4, 5 red; 2, 3, 6, 7 green).
2. **THE GREEN RUN** on `vx770-b4` — 55 suite types: the two new suites; every suite type in a test file that
   exercises the one changed source, `CompareBoardView.swift` (the Compare model/board/composition, versions,
   gutter, leaving-savepoint, landing, ring-end, outline/scrub, soak, registry, savepoint-door, VX-347, workspace
   navigation and post-detail families, `VersionDoorsTests` and `SealedBookMemberDoorTests` — the two that land
   in Compare mode); and the acceptance spine (every suite type in `TutorialWalkTests.swift` + `TutorialCurrencyTests`):
   `-only-testing:VariorumTests/CompareOutlineMintColumnTests -only-testing:VariorumTests/CompareToggleIdentityTests -only-testing:VariorumTests/VersionDoorsTests -only-testing:VariorumTests/CompareCompositionTests -only-testing:VariorumTests/CompareViewModelTests -only-testing:VariorumTests/CompareVersionsTests -only-testing:VariorumTests/CompareAnchorWholeTests -only-testing:VariorumTests/CompareLensesAlignmentTests -only-testing:VariorumTests/CompareOnePlacementTests -only-testing:VariorumTests/CompareCommentGutterTests -only-testing:VariorumTests/BoardCommentGutterRuleTests -only-testing:VariorumTests/TakesCommentGutterTests -only-testing:VariorumTests/CompareLeavingSavepointTests -only-testing:VariorumTests/BookLeavingRegistryTests -only-testing:VariorumTests/BookLeavingSavepointTests -only-testing:VariorumTests/MCPCompareLandingTests -only-testing:VariorumTests/OutsideWriteRingEndTests -only-testing:VariorumTests/ScrubAndOutlineTests -only-testing:VariorumTests/TakesBoardSoakTests -only-testing:VariorumTests/CapabilityRegistryTests -only-testing:VariorumTests/AutosaveRegistryLifecycleTests -only-testing:VariorumTests/AutosaveRegistryReleaseGuardTests -only-testing:VariorumTests/SavepointCommitDoorTests -only-testing:VariorumTests/SavepointNameAskTests -only-testing:VariorumTests/SavepointNameCopyTests -only-testing:VariorumTests/SavepointNameFaceTests -only-testing:VariorumTests/SavepointRenameDoorTests -only-testing:VariorumTests/SavepointSealedDoorTests -only-testing:VariorumTests/SavepointTakesDoorTests -only-testing:VariorumTests/VX347AskedTakeFilingTests -only-testing:VariorumTests/VX347LeaveRuleTests -only-testing:VariorumTests/VX347LeavingBoxTests -only-testing:VariorumTests/VX347OneCommitPerFieldTests -only-testing:VariorumTests/NavigationDoorsTests -only-testing:VariorumTests/NavigationHistoryTests -only-testing:VariorumTests/OpenNotesTests -only-testing:VariorumTests/WorkspaceModelTests -only-testing:VariorumTests/WorkspaceNamingTests -only-testing:VariorumTests/PostDetailModeMemoryTests -only-testing:VariorumTests/PostDetailRoutingTests -only-testing:VariorumTests/SidebarSmokeTests -only-testing:VariorumTests/WriteTakesPanelTests -only-testing:VariorumTests/SealedBookMemberDoorTests -only-testing:VariorumTests/TutorialBookShapeTests -only-testing:VariorumTests/TutorialCurrencyTests -only-testing:VariorumTests/TutorialDeletionActsTests -only-testing:VariorumTests/TutorialDoorTests -only-testing:VariorumTests/TutorialFannedMatrixTests -only-testing:VariorumTests/TutorialLibraryActsTests -only-testing:VariorumTests/TutorialLookingActsTests -only-testing:VariorumTests/TutorialPrivacyChapterTests -only-testing:VariorumTests/TutorialStructureActsTests -only-testing:VariorumTests/TutorialTakesActsTests -only-testing:VariorumTests/TutorialWherePlacesActsTests -only-testing:VariorumTests/TutorialWritingActsTests`
   **The DELTA, stated honestly:** `CompareOutlineMintColumnTests`, `CompareToggleIdentityTests` and
   `VersionDoorsTests` have run in no window of this run; the other 52 are in batch 3's / the reconciliation's
   157 set but that run's tree (`vx770-recon-post`) lacks batch 4's `CompareBoardView.swift`, so they re-run
   here against it. **Every OTHER suite of the 157 set exercises no file batch 4 touched** (the diff is
   `CompareBoardView.swift` + two new test files), so the 157 run on `vx770-recon-post` covers them. **An
   option, the orchestrator's call:** `vx770-b4` carries batch 3 + the reconciliation + batch 4, so if the 157
   run has NOT yet happened, one run of the 157 set ∪ the three delta suites on `vx770-b4` covers both READY
   lists (batch 3's red run still needs `vx770-b3-rev`).
   Known shapes as before: VX-337's two load-dependent flakes (`TakesArticleScrollTests.aShortRowStraddlingTheFoldComesBackAboveIt`
   — not in this list); the defaults domain first on an unexpected `TakesEntryBandTests` red (not in this list);
   the one capture-harness skip.
3. Results into the prediction table; then `vx770-b4-rev` and `vx770-b4-prerevert` may be deleted (`vx770-b4` stays
   for the walk). `vx770-b3-rev` and `vx770-recon-post` were left exactly as found (not deleted, not reused).

### RESIDUE / NOTICED (not fixed — a line each; the orchestrator's to ticket or drop)

- **R-B4-1 (re-ordered pairs keep a partial rebuild):** on a pair whose kin sit in a different order, "follow this
  note's order" re-pairs peer blocks into other rows, and a SwiftUI view cannot move between parents — those peer
  cells (only those) are still re-made. Inherent to the toggle re-arranging; the walk's look-only line.
- **R-B4-2 (the class under VX-757, every pane surface):** any freshly made `PaneSurfaceView` is born at
  `@State height = 24` and measured at install before it has width; its real height arrives a turn later through
  the width hook and the publisher's heal. Every lazy column that realizes a row (scrolling, any re-key) pays that
  two-pass on each new pane — the Takes article and the lenses included. A seed taken from a width-known
  measurement would close the class at the root, but that is `PaneSurface` (P-3's one component) — not this
  batch's surface. Ticket candidate (Takes & Lenses / Performance), Suspected.
- **R-B4-3 (the header door double-press):** "make outline note" mints on every press — two quick presses make two
  outline notes and open both. By design (each press is an act; ⌥⌘Z undoes one), noted only because W16 should
  press once per note.
- **R-B4-4:** `CompareRow.id` is now read by nothing on screen (the board keys by `spineID`); it stays the type's
  `Identifiable` id. Harmless; retire at a later touch if the reviewer prefers one identity.

## SELF-ASSESSMENT — batch 4 (the first of the two reviews — the implementer's)

- **What is proven, and how far.** Headless only: both trees compile (the pins against the pre-fix behaviour and
  against the fixes), the revert is verified restored, and the binaries differ as intended. VX-740's mechanism is
  the ladder's, re-located and confirmed by code read; its pin stages the race deterministically through the REAL
  act. VX-757's mechanism is code-traced from the chip to the re-made pane; the painted flicker itself is not
  observable headlessly — the pins read the state transition the trace names (the toggle re-making panes), and
  the `VX757-TRACE` prints will show the window whether a wrong-height turn is visible in the harness. Every
  red/green line is a prediction.
- **VX-757 — the honesty question, answered in advance.** Her word is "track paragraphs"; I mapped it to "follow
  this note's order" by its help text and pinned "related blocks only" too, since both re-key rows. If W15 finds
  the flicker on a control the trace says is inert (lineage colors), or on a no-lineage pair, the mechanism is
  wrong or incomplete — the record says so and the member does not close on these pins.
- **Why these shapes.** VX-740: P-770-1 verbatim — one `contains` before seating, nothing else. VX-757: the defect
  is identity, so the fix is identity — no animation suppression, no curtain, no change to `PaneSurface` (R-B4-2
  names the deeper class and leaves it). The composition brain, its pins and `CompareCellView` are byte-unchanged.
- **What could regress, and why I think it does not.** (1) *Duplicate row ids* (undefined `ForEach` behaviour):
  unique by construction — each block sits in one note (I2), each column shows a block once, the anchor is never a
  peer, and even a doubled peer column (VX-740's own bug, now fixed) keys its peer-only rows by the first column.
  (2) *Layout drift:* the uniform structure reproduces each arm's frames (a free peer cell now sits in a one-child
  `VStack` with the same `maxWidth`/alignment; an empty free column keeps its 1-pt clear space); the Compare
  alignment/geometry pins (`CompareLensesAlignmentTests` et al.) and batch 2's gutter pins in the green run guard
  it. (3) *Kept state where a rebuild used to reset it:* a kept cell keeps its pane's measured height (the point),
  its live ring (the authority decides liveness, not view identity), and its comment face (batch 2's oracle now
  sees no disappear/appear on a toggle). (4) *The VX-740 pin's hop:* `DispatchQueue.main.sync` from the runner's
  thread needs main idle — it is (the test awaits the act); a hang there would show as a timeout, not a pass.
- **Scope kept.** Two members, one source file. No gutter-lane or oracle change (the brief's STOP line was never
  reached). No `Shared/`, `Sync/`, schema, registry or `PaneSurface` change.

## THE WINDOW RE-SCOPE (the orchestrator, post-batch-4) + a bundle line

The b3r window CONSOLIDATES per batch 4's offer: `vx770-b4` holds batches 3 + reconciliation + 4,
so ONE green run there (157 ∪ batch 4's delta = 160 types) covers both lists; the red runs stay
per-batch (`vx770-b3-rev` 4 suites; `vx770-b4-rev` 2 suites). `vx770-recon-post` is superseded
and deleted. New window estimate ~30 min; re-READY sent before the seam per the coordinator's
standing rule.

**HER BUNDLE (+1): the toggle-name mapping.** Her report said "track paragraphs"; no control
carries that name — batch 4 mapped it to "follow this note's order" by its help text (and pinned
"related blocks only" beside it). The trace's mechanism (every pane re-made on a lineage-sharing
pair's re-key) fits a flicker on that toggle. CONFIRM with her that "track paragraphs" meant
"follow this note's order"; if she meant something else, VX-757 reopens on the right control
(the fix stands on its own merits either way — it removes a real whole-board pane rebuild).

---

## BATCH 5 RECORD — the singles: VX-758 · VX-739 · VX-638 · VX-652 · VX-634 (implementer: opus-implementer, 2026-11-04)

**NOT DONE (first line, kept current):** every member is in progress; mounted red/green claims are
PREDICTIONS until the orchestrator's suite window (this session is headless — no `xcodebuild test`,
no app launch, no stage); core `swift test` results are REAL where stated; the use walk (W17–W18
and the batch's other rows); the cold ladder.

**LIVE STATUS**
| piece | state |
|---|---|
| Reading (this file whole incl. batches 1–4 + the window re-scope; TEXTKIT2_NOTES in full; SurfaceContracts in full) | DONE |
| A · VX-758 trace (code read, written below before any code) | DONE (this commit) |
| A · VX-758 pins (a6a4ff83a) | DONE — `swift test` on the pre-fix source: **RED, real** — "Test run with 27 tests in 2 suites failed … with 9 issues": every entry-date pin (override ↑/↓, stored ↑/↓, chapter, gathering, Library-agreement ↑/↓, the re-shaped old pin); the Created characterization ↑/↓ GREEN. Old asc order observed: `[d01, d10, u05, u20, u05late]` (the dated notes, then the undated pile in id order) |
| A · VX-758 fix (630631af6) | DONE — `swift test`: the pins **GREEN, real** (27 tests, 2 suites); the WHOLE core package: 3,590 tests in 478 suites passed (5 known issues) + the second product 467 of 468 — the one red `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (connect bounded < 15 s, took 29.4 s under full-package load) passes alone (3 tests, 2.2 s): load, not the diff |
| A · VX-758 behavioural revert (announced 25846caac before it started; ran 05:04–05:06): `ReadingAssembly.swift` restored to a6a4ff83a (= the pre-fix source) by `git checkout a6a4ff83a --`, copy + sha256 first in `scratchpad/vx758-prerevert/` | DONE — **RED on the revert, real**: "Test run with 27 tests in 2 suites failed after 3.086 seconds with 9 issues" (the same nine as the pre-fix run). **THE INDEX-SWEEP INCIDENT (recorded, healed):** the orchestrator's ledger commit a63e88c9f (05:04:50, pushed) swept the revert's STAGED file into its own commit, so HEAD briefly held the pre-fix `ReadingAssembly.swift` and my `git checkout HEAD --` restored that shape (sha mismatch caught it: 0067a228… ≠ bf8aaba8…). **HEALED at 1e295451f** (no history rewritten): the file re-taken from 630631af6, verified three ways — working file = 630631af6's blob = the pre-revert copy, sha256 `bf8aaba8…71ce`, `cmp` identical — the pins GREEN on it (27 tests, 2 suites), committed by PATHSPEC, pushed; HEAD's blob now = the fix's blob. No revert in flight; the source is HEAD. Lesson applied on my side too: every later commit of mine is a pathspec commit, and later reverts run on an APFS clone, never in the shared index |
| B · VX-739 trace (code read + two bare-rig probes, written below before any code) | DONE (this commit) |
| B · VX-739 pin (7b7ab0566) | DONE — `WriteWordCountFlipTests` (2 functions, 3 cases: flip-twice ×{unmounted, mounted} + the typing guard); compile PENDING the b5 build; red/green PENDING the window (PREDICTED red on rev at flip 2: 12 for 11, then 9 for 8) |
| B · VX-739 fix (196fdb145) | DONE — CONDITIONAL on the window's red run (green on rev ⇒ revert this one commit, record-only) |
| C · VX-638 trace + pins (this commit) | DONE — `TakesPagerAfterCloseTests` (6 pure layout transitions); red/green PENDING the window |
| C · VX-638 fix (4f1884d72) | DONE — `TakesBoardLayout.forgetPages(ofClosed:)` from the three close doors; red/green PENDING the window |
| D · VX-652 | **FORK RETURNED — NOT BUILT** (B5-F1 below): the premise HOLDS at every width; the only working fix is a new AppKit-anchored pull-down — the orchestrator's call |
| E · VX-634 sweep + pins (this commit) | DONE — `UndoLabelVocabularyTests` (core): `swift test` on the pre-fix source **RED, real** — "3 tests in 1 suite failed … with 3 issues": the behaviour pin both directions (⌥⌘Z and ⇧⌥⌘Z read "Delete Variant"), the fence's one offender `Operations+Deletion.swift:144 — "Delete Variant"`; the matcher control GREEN |
| E · VX-634 fix (595e7369e) | DONE — `swift test` **GREEN, real** (49 tests, 4 suites: the new pins + `UndoStackTests` + `RedoStackTests` with their four label lines edited). **Behavioural revert, real:** `Operations+Deletion.swift` written back to c3a1d6d4a's bytes by `git show >` (working tree ONLY — the index stayed clean, verified `git diff --cached --quiet`), the pins **RED** ("3 tests in 1 suite failed … with 3 issues"), restored from HEAD, sha256 `0c7c0a0b…3ce8` = the pre-revert copy, `cmp` identical, `git status` clean |
| `DerivedData/vx770-b5` build-for-testing (HEAD) | DONE — TEST BUILD SUCCEEDED at 01f60b52f's source (log `App/Variorum/DerivedData/logs/vx770-b5-build2.log`; the first pass `vx770-b5-build.log` red on ONE test-file isolation error — the VX-739 pin's nested `deliver()` — fixed at 01f60b52f); no warning in a touched file |
| **Behavioural revert tree — ANNOUNCED HERE BEFORE IT STARTS:** built from a CLEAN EXPORT of HEAD (`git archive` into `scratchpad/vx770-b5-rev-src/`, outside the shared worktree — nothing in the worktree or its index moves) with exactly two behaviour files at their pin commits: `Features/Editor/EditorViewModel.swift` at 7b7ab0566 (VX-739's pin commit = its pre-fix source) and `Features/Takes/TakesBoardLayout.swift` at 357a2f970 (VX-638's pin commit = its pre-fix source); every test file at HEAD; core at HEAD (VX-758 and VX-634 are proven red/green by `swift test` already); into `App/Variorum/DerivedData/vx770-b5-rev` | IN FLIGHT |
| C · VX-638 | NOT STARTED |
| D · VX-652 | NOT STARTED |
| E · VX-634 + the sweep | NOT STARTED |
| `DerivedData/vx770-b5` build-for-testing | NOT STARTED |
| READY-FOR-SUITES, walk rows, residue, self-assessment | NOT STARTED |

### A · VX-758 — THE TRACE (written before any code)

**Which sort option is broken — the truth, and it is NOT her sentence's surface reading.** The book's
order ▾ (the navigator's `orderControl`, `BookView.swift:1502–1556`, the ONE list
`BookOrderChoices.all`, `BookOrderAndConversion.swift:45–53`) offers Manual · Entry date ↑/↓ ·
Created ↑/↓ · Last touched ↓ · Major revision ↓. A pick sets `BookViewModel.viewOrder`, the
observation restarts (`observeReading(order:)`, `BookViewModel.swift:104–107`) and the rows are adopted
verbatim; `BookStructureModel.grouped` keeps the query's order inside each chapter. The phone has no
order door (stored order only). So the ONE place the order is decided is
`Queries.assembleReading` → `stampOrder` (`Sources/VariorumCore/Queries/ReadingAssembly.swift:553–564`):
`ORDER BY (col IS NULL), col DIR, c.id DIR`.
- **Created ↑/↓ (`.createdAt` → `c.created_at`) — NOT broken by the code.** `container.created_at` is
  `NOT NULL`, so the `IS NULL` term is always 0 and every note orders by its creation instant; entry
  dates play no part. Pinned as a characterization (green on both trees, below).
- **Entry date ↑/↓ (`.entryDate` → `c.entry_date`) — BROKEN for undated notes.** `entry_date` is NULL
  on every note minted outside a journal door, so the `(c.entry_date IS NULL)` term piles EVERY undated
  note last in both directions, and inside the pile the only key is `c.id` — a random UUID. The
  undated notes therefore sit in an arbitrary order that no pick changes beyond flipping it: exactly
  "doesn't seem to be doing anything unless items have an entry date". The pile was deliberate when
  written (pinned: `ReadingAssemblyQueryTests.entryDateSortOrdersJournalsAndSortsUndatedLast`); her
  sentence (the kickoff header, verbatim) overturns it.
- **Her intent, built:** *"it should use their creation date if they don't have an entry date"* — the
  entry-date arm's key becomes the note's entry date, else its creation stamp. **The precedent is the
  Library's own date sort**, which has done exactly this since 18h: `Queries.LibrarySort.entryDate`'s
  expression is `COALESCE(entry_date, created_at)`, tie broken by `id` in the same direction
  (`Sources/VariorumCore/Queries/Timeline.swift`, `expression` + `library`'s `ORDER BY`). So the fix
  is the Library's rule, reused verbatim in the book's arm — one date rule for both listings, no new
  key. The narrow corner the Library already carries comes with it, named there (18h R1-10): the
  fallback compares a UTC instant with a local day key, so an undated note created inside the
  zone-offset window of midnight sorts by its UTC day while its displayed name is its local day. The
  Library's record weighed `date(created_at, 'localtime')` and declined it (per-row time-zone
  dependence, the `Calendar.current` mismatch); reusing the Library's spelling keeps the two listings
  agreeing, which is the stronger property.
- **What her word "creation date" means for the record:** she was looking through "Entry date" (the
  arm that consults entry dates at all) — or she read the Created arm's result on a book whose notes
  share creation stamps; the code admits only the first reading of "unless items have an entry date".
  Built to the intent (every note always sorts; an undated note takes its created_at). Her bundle gets
  one line (the label question is hers, not this batch's).
- **Scope, kept:** the Last touched / Major revision arms keep `NULL` last (their own deliberate doc:
  "a post that never crossed the churn threshold shouldn't lead a by-revision book") although the
  Library falls back to `created_at` there too — residue line, not built. Read-side only: no
  Operations, schema or `Sync/` change; the stored `sort_field` is untouched.

## WINDOW b3r — THE CONSOLIDATED RUNS (the orchestrator, claim `vx-770-tests-b3r`, 04:52–05:12, at VX-500's seam)

**All three legs verdict-clean; batches 1–4 + the reconciliation are now red/green VERIFIED.**
1. **b3-rev red** (log `App/Variorum/DerivedData/logs/vx770-b3-red.log`): EXECUTED 10 tests / 4
   of 4 suites — RED exactly on the five pinned behaviors: `anUndoneAIsCommentsLeaveTheGutter` ×4
   styles (VX-732), `anUndoneAIsTakesCloseTheFansTheyCollapsed` ×4 (VX-733),
   `aCommentChangedFromOutsideTheBoardFollowsTheStore`,
   `aFanThatCollapsesWhileTheBoardIsAwayComesBackClosed`, `deletingAnOpenFansSecondTakeClosesIt`.
   Every guard GREEN on rev as designed: the archive road (B3-P1), her open panel's seat, the
   first-take door (R72), `onlyACollapsedFanCloses`, the pure rule. Both members red-on-old
   VERIFIED, the across-mode-switch arm included.
2. **b4-rev red** (`vx770-b4-red.log`): EXECUTED 7 tests / 2 of 2 suites — RED on VX-740's mint
   pin (`columns == [outline]` failed: two columns on old; `peerSlots.count == 1` failed) and on
   BOTH VX-757 toggle pins (`remade(...).isEmpty` failed both arms) — **VX-757's reading rule
   resolves to FIXED, not record-only: the pane-remake mechanism is real and red-on-old.**
   Guards green on rev: no-lineage inert, lineage colors, the ordinary order, beside-open-note.
3. **The consolidated green on vx770-b4** (`vx770-green-consolidated.log`): "Test run with 1060
   tests in 156 suites passed after 544.269 seconds with 4 warnings and 10 known issues" — 157
   requested types (the sheet's honest dedupe of the quoted 160), 156 counted (the gap is the
   trait-skipped VX-136 capture harness), ZERO failures; the 4 warnings are the standing
   `@Dependency(\.date)` lines, the 10 known issues the pre-existing annotated guards. Batches
   2/3's seven own suite types verified present and green BY NAME. The v1_36 newer-schema hazard
   did not bite (no shell-mount reds).
Stage released 05:12, the three trees deleted after release, 50 GiB free. Remaining suite story:
batch 5's gate (its delta + anything its diff touches) at the pre-ladder run; then the ladder,
the ROAD-B walk, closeout.

## INCIDENT — the index sweep at a63e88c9f (the orchestrator, 05:04; healed by the implementer's restore commit)

My ledger-flip commit swept in batch 5's STAGED mid-revert `ReadingAssembly.swift` (its
`git checkout <commit> -- <file>` stages as a side effect; my plain `git commit` after a
pathspec `git add` committed the whole index), so HEAD briefly carried the VX-758 fix REVERSED
while the implementer's working tree and prerevert copies stayed correct. No history rewrite:
the implementer was told the same minute and commits the restored file explicitly (sha256
against its prerevert copy AND its fix commit's blob), which heals HEAD. Rev trees built from
the working tree were never affected. **The rule this writes (binding on the orchestrator for
the rest of this run and recorded for every shared-worktree session): record commits beside a
live implementer use PATHSPEC COMMITS (`git commit <file> -m …`), never a bare `git commit` —
a peer's staged state is invisible to a pathspec add and rides a bare commit silently.**

### B · VX-739 — THE TRACE (written before any code; two bare-rig probes, throwaway, never in the PR)

**Her sighting's numbers (the VX-736 J3 walk, `notes/plans/fixes/vx-736-hotfix-101.md` :594–595):** the
note "You, I hope :)" (3 words) / "A second short block of prose." (6) / "A third." (2) = 11. Caret in
block 1; Write's take panel ＋ blank & choose → "0w block · 8w in note" (right); ✓ the original →
**"3w block · 12w in note"** (should be 11); later ✓ the blank → **"0w block · 9w in note"** (should be
8). The block count is right, the TOTAL is one high, from the SECOND flip on, and stays one high.

**The road (code read, HEAD).** The panel's choose is a store write; Write hears it as a delivery →
the fresh re-read → `.differential` → `EditorSurfaceController.applyDifferential`
(`EditorSurfaceController.swift:124–151`): it rewrites each changed slot through
`programmaticReplace` (`EditorViewModel.swift:4449–4483`, inside `suppressEditProcessing`) and only
AFTER the loop adopts the new tiling (`adoptRewrite` → `adoptSurfaceTextMap` → `ledger.adopt`), then
calls `updateCaretContext()` itself. The total is `EditorSurfaceLedger.totalWords(over: slots)` — a sum
of CACHED per-variant counts (`App/Variorum/Shared/EditorBrain/EditorProjectionEngine.swift:28–78`).
Two writers fill that cache: `adopt` (counts a projection's text, REUSING the cached count whenever the
text equals `textByVariant` — :49–51) and the caret's live arm `setLiveWordCount` (`updateCaretContext`,
`EditorViewModel.swift:3845–3850`), which writes a count WITHOUT the text it counted.

**The AppKit fact the trace rests on — MEASURED (macOS 27.0.1, a bare offscreen TK2 `NSTextView`,
`EditorSurfaceStorage.replace`'s exact begin · replace · setAttributes · end):** a programmatic replace
moves the caret AND posts `textViewDidChangeSelection` INSIDE the storage transaction —
- flip 1 shape (block 1's 14 characters → ""), caret at block 1's end / middle / start → `{0, 0}`,
  the delegate fired with `insideWrite=true`, storage already 40 long;
- flip 2 shape ("" → the 14 characters at 0), caret at 0 → **`{14, 0}`** (pushed past the insertion),
  the delegate fired with `insideWrite=true`, storage already 54 long.

**So, step by step:** the delegate (`EditorView.swift:937–945`) runs `updateCaretContext()` INSIDE
`programmaticReplace`, while `index` still tiles the PRE-write text.
1. *Flip 1:* the caret (0) resolves to the old entry 0 (the original take, length 14) and counts the
   new text's `(0, 14)` = "\nA second shor" = 3 words — the original's own count, so the cache does not
   move, and the original leaves the slots at the adopt anyway. Harmless, by luck. Total 8 — right.
2. *Flip 2:* the caret (14) resolves against the OLD tiling `[b1 len 0][b2 len 30][b3 len 8]` to
   **entry 1 — block 2** — and counts the new text's `(1, 30)` = **"ou, I hope :)\nA second short b" =
   7 words** (computed with the app's own `.byWords` enumeration), so `setLiveWordCount(block 2's take, 7)`
   overwrites block 2's true 6. Then `adopt`: block 2's text did not change, so it KEEPS the cached 7;
   the original is re-counted (3). **3 + 7 + 2 = 12** — her number. The executor's trailing
   `updateCaretContext()` fixes the BLOCK figure (3, on the right tiling) and never touches block 2.
3. *Every later flip:* block 2's text still equals the cached text, so its 7 rides every adopt —
   **0 + 7 + 2 = 9** at the next blank, her number. It heals only when block 2's own text changes.

**The mechanism, in one line:** the caret's live word count is a typing fact written from a
selection change AppKit posts in the middle of a programmatic surface rewrite, when the index still
describes the text before it; it lands on a NEIGHBOUR's take, and the ledger's text-keyed cache keeps
it. Not tokenization; not the badge road (VX-729's `refreshBadges` writes no count). The same stale
read also reports the neighbour to `noteFocusedBlock` for that moment, but the executor's trailing
call overwrites it (last write wins) — only the ledger cache OUTLIVES the rewrite.

**The fix's shape (decided from the trace):** the live arm writes only while the index describes the
storage — never from inside a programmatic surface write (`suppressEditProcessing`, the flag every
storage-write primitive already raises: `setSurfaceContent`, `applySeamEdit`, `programmaticReplace`).
The executors' own trailing `updateCaretContext()` (after the adopt) is the authoritative report, and
`adopt` already counts every changed text — so the live arm loses nothing it exists for (keeping the
total current BETWEEN projections while she types: the typing road's selection change arrives after
`storageDidEdit` has applied the edit to the index — outside any suppression). One guard in the Mac's
`updateCaretContext`; the shared ledger (`Shared/EditorBrain`) is NOT touched (no phone-suite trigger).

**The pin-first discipline, given a headless implementer:** the pin (`WriteWordCountFlipTests`) stages
J3 exactly through the panel's own road and Write's delivery road; it cannot run here. Its red is a
PREDICTION backed by the measured AppKit fact and the computed counts; the fix rides it CONDITIONALLY —
**if the window's run of the pin on the revert tree is GREEN, the fix commit is reverted and VX-739
falls to record-only (the pin kept as the characterization, W17 the eye)**; red on rev + green on HEAD
= FIXED.

### C · VX-638 — THE TRACE (written before any code)

**Her sighting (the VX-601 batch B walk, row B3 + O-BW-2):** slot split, expand all, block 1 (3 takes)
"◀ 1–2 of 3 ▶"; **▶ → "2–3 of 3"**; close all; expand all → **"2–3 of 3" over cards 1–2**; ⌘1 ⌘2 →
"1–2 of 3" over the same cards.
- **The caption is a pure function of the layout's page table:** `pagedTakesRow`
  (`TakesBoardView.swift:1639–1675`, slot split's AND carousel's strip, key = the block id) writes
  `"\(offset + 1)–\(min(offset + beneathCount, n)) of \(n)"` from `model.pageOffset(pageKey, limit:)` =
  `TakesBoardLayout.pageOffsets` (`TakesBoardLayout.swift:619–634`); the margin grid's rail
  (`railCards`, key `rail-<block>`) the same way. The CARDS are wherever the strip's own horizontal
  `ScrollView` sits; the two are tied only by the `scrollPosition(id:)` binding (`stripBinding`).
- **Every strip mounts only while its block is bloomed** (`articleRow`, `TakesBoardView.swift:1117–1160`:
  `if splitBloomed { slotSplitBloom }`, `if bloomed … carouselBloom`, `if style == .marginGrid, bloomed`),
  so close all tears the strip down and expand all builds a NEW one — and the new `ScrollView` is born at
  its leading edge (cards 1–2: her capture is the measurement; the binding's stored id is not where a
  freshly built strip comes up, and nothing writes the born position back).
- **Nothing on the close road touches the page table:** `closeAllFans`, `toggleExpanded`'s close and
  `closeCollapsedFans` change only `expandedBlocks` (`TakesBoardLayout.swift:407–412, 533–556`), so the
  re-born strip's caption reads the page its predecessor left: offset 1 → "2–3 of 3". The mode round trip
  builds a fresh layout (the table empty) → "1–2 of 3". Within one mount, pre-existing, not VX-428's.

**The fix's shape:** the layout's own letter is "close-all resets" (its header): a block whose fan CLOSES
forgets its pages (both keys — the block's and the rail's), so a re-opened strip starts at page 1 and its
caption agrees with the cards it is born showing. The three close doors (close all, a fan's own close,
VX-733's collapse) share one helper. **Guard:** a block still bloomed by follow-the-scroll (R25 — on
screen, fanned) keeps its strip mounted, so it keeps its page. Nothing about the scroll machinery, the
binding, the reveal's auto-page (`pageToReveal`) or `expandAll` changes.

**Not covered, by design (residue R-B5-1):** a strip re-born while its block NEVER closed — a lazy row
de-realized and re-realized (scrolled far away and back), or a follow-the-scroll bloom that leaves and
re-enters the screen — meets the same born-at-the-leading-edge fact with a non-zero page. The honest
fix there is the strip honouring its stored page at birth (a SwiftUI scroll on appear — not pinnable
headlessly, and not her road); a walk look (W18's sibling line).

### E · VX-634 — THE TRACE + THE SWEEP (written before the fix)

**Mechanism:** the receipt is `StructuralUndoCopy.undone(label)` = "Undid: \(label)"
(`App/Variorum/Shared/StructuralUndoCopy.swift:40–41`), and the label is the string the operation
registers with the session's `UndoStack`; `deleteVariant` registers **"Delete Variant"**
(`Sources/VariorumCore/Operations/Operations+Deletion.swift:144`). The model word is minted in core,
so the fix is the label there ("Delete Take" — the app's own door is "Delete this take"), plus the
label's four existing pins (`UndoStackTests` :267, :292; `RedoStackTests` :306, :312) edited with it.

**The sweep — every structural-undo label the code registers** (literal `label:` arguments in core
Operations, every `withCompound(label:)` in app/shared/core, the static label constants, and the MCP
door's computed `"\(client)'s \(kind)"`):

| label | where | verdict |
|---|---|---|
| **Delete Variant** | `Operations+Deletion.swift:144` (`deleteVariant`) | **MODEL WORD → FIXED: "Delete Take"** (the member) |
| **Archive Variant** | `Operations+Deletion.swift:18` (`archiveVariant`) | **MODEL WORD — NOT FIXED (brief: report only)** → closeout ticket candidate "Archive Take"; held by the fence's named allow-list |
| Pool Copy | `Operations+Pool.swift:105` (`poolDragCopy`) | wording drift, not a model word in the fence's list: the UI calls that area **Snippets** (AppSpec §7: `kind='pool'` is the model term) → ticket candidate line (her wording) |
| Convert to Book | `Operations+ReadingConversion.swift:221` (the bind) | wording drift: the door is "Bind into a Book…" since 13i-b U3 → ticket candidate line (her wording) |
| Sample Library | `SampleLibrarySeeder.undoLabel` | wording drift: the restore doors are per-book since VX-105 → ticket candidate line |
| Adopt Lens ×3 · Promote Lens · Duplicate lens | Versions / Lens | app words — OK |
| Archive Block · Unarchive Block · Delete Block · New Block · Move Block · Reorder | Block/Placement | app words — OK |
| Divide ×2 · Divide choosing takes · Extract · Merge · Merge Takes · Split at Newlines · Turn Takes into Blocks · Move into a New Take · Move Take into a Block · Reorder Take | Structural / TakeStructure / SpanToTake / Variant | app words — OK |
| Make Outline Note · Make Into a Note · Save a Version · Diverge for This Book · Copy In · Import · Delete Tag · Duplicate with Tags · Duplicate without Tags | Versions / NoteVersions / Diverge / Ownership / Import / Tag | app words — OK |
| Merge Blocks ×3 · Delete Blocks ×3 · Split at Newlines ×2 · Make Block ×2 · Divide ×2 · Order Blocks · Move Blocks · Import | `withCompound` sites (BlockTOC, TakesStructure, Canvas, Import, core) | app words — OK |
| Quick Note · Edit Across Blocks | `QuickNoteView.undoLabel`, `CrossBlockCompound.undoLabel` | app words — OK |
| "‹client›'s take choice / take deletion / note title / book name / chapter move / gathering archiving / …" (all 40 kinds) | `Operations+MCPWrites.swift` `undoLabel(client:)` | app words throughout — OK |

**The fence pin** (`Tests/VariorumCoreTests/UndoLabelVocabularyTests.swift`, runnable headlessly):
every literal undo label scanned from the shipped source; no whole-word variant(s) · post(s) ·
container · reading(s) · section(s) · savepoint(s); a NAMED allow-list (one entry: "Archive Variant",
with its reason) whose entries must still exist — so the day the sibling is fixed, the list must shrink
and the fence closes over it. Non-vacuity: the scan must find > 25 labels and "Delete Block".

### D · VX-652 — THE PREMISE RE-CHECK, and B5-F1 (the fork, returned; NOT built)

**The premise at today's 1270-pt default — STILL REACHABLE, and at EVERY width.** The "+ column ▾" door is
Lenses' header `VoicedMenu` (`LensesBoardView.swift:375–410, 434–440`), placed after a `Spacer()`, so it
is pinned to the board's TRAILING edge (12-pt `boardInset` + the control's own 5-pt padding from the
board's right edge — the window's right edge whenever no inspector or Book Panel stands beside the
board). `VoicedMenu` is a SwiftUI `Menu` (`Theme/VoiceControls.swift:136–170`) — an `NSPopUpButton`
pull-down underneath — which pops its menu with the MENU'S LEFT EDGE AT THE CONTROL'S LEFT EDGE and
constrains it only to the SCREEN, never the window. So the overflow past the window's right edge is
(the menu's width) − (the control's width + ~17 pt): its items ("New lens — arrange existing takes",
"New lens — write new takes", "Open “‹lens›”"…) make a menu of roughly 250–300 pt against a ~70-pt
control — on the order of ~190 pt past the edge — **independent of the window's width**: the 1240 →
1270 growth (VX-737) moves the control with the edge and changes nothing; a user-narrowed window
reaches it exactly the same. (It disappears only where the window's right edge IS the screen's: AppKit
then shifts the menu left onto the screen.) No pin reaches a tracking menu's frame headlessly or in the
mounted harness (a popped menu runs its own tracking loop) — the numbers above are the code's geometry,
not a capture; W18 is the eye.

**The fix needs a mechanism the app does not have (the external facts, one Sonnet lookup — Apple's
`Menu`, `menuStyle`, `NSPopUpButton.preferredEdge`, `NSMenu.popUp(positioning:at:in:)`, `NSMenu.size`
pages and the HIG pull-down page):** there is NO SwiftUI API that aligns a `Menu`'s popped menu on macOS
(through macOS 26; none found); `NSPopUpButton.preferredEdge` is a screen-space FALLBACK for pull-downs,
not an alignment; the HIG says nothing about window edges. The one working road is AppKit's
`NSMenu.popUp(positioning: nil, at: (bounds.maxX − menu.size.width, the control's bottom), in: view)` —
with two facts only a live run settles (the flipped-vs-unflipped y, and whether `menu.size` before the
first display matches the drawn width). Nothing in the app pops a menu that way today (searched).

**B5-F1 — the options (the orchestrator's call; logged for the closeout's QUESTIONS bundle):**
- **(A) A trailing-anchored pull-down for THIS door only.** The header door becomes a SwiftUI button
  styled exactly as `VoicedMenu`'s label, over a zero-size AppKit anchor that pops an `NSMenu` whose
  right edge meets the control's; the add-column items become ONE data list both doors render (the
  dashed stub keeps its SwiftUI `Menu` over the same list — "one body behind both doors" kept, the tour's
  step-9 anchor on the stub untouched). Pins: the pure anchor geometry, the two doors' item parity; W18
  live for the frame. Cost ~100 lines; a second pull-down mechanism beside the chrome's one menu.
- **(B) `VoicedMenu` learns `opensToward: .leading`** (the same AppKit pop inside the shared control) —
  every trailing-pinned `VoicedMenu` in the app could take it; larger blast radius (app-wide chrome).
- **(C) Record-only — AppKit's own behaviour.** The menu is fully on screen and fully usable; macOS
  pull-downs routinely hang past a window's edge; the overflow is cosmetic. Close VX-652 with this
  geometry argument (her taste call).
- **My recommendation:** (A) if she wants it fixed (the narrowest change that answers the ticket, and it
  keeps one item list), built by a session that can walk it the same night — the geometry's two open
  facts make a headless build a blind one, which this batch's discipline rules out; (C) otherwise.
  **Not built here** — the record's honest line, not a deferral by default: the fix needs a mechanism and
  a live check this headless batch cannot give it.
