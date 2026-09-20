# Phase 13u4 — THE RESTYLE CONTINUATION (EXECUTION PLAN)

**Status: OPEN — kicked off 2026-09-20 at her word. The SIZING-AND-RULINGS SITTING ran at kickoff
(she attended); its record below is BINDING. Nine units, order E1→E2→E3→C1→C2→F1→S1→S2→S3; one
end ladder (`fable-reviewer`); the ledger below is the running record.**
Authored 2026-09-14 at the 13u1 kickoff (the R-cor-12 four-way split); grown at the 13u3 morning
sitting by HER ELEVEN ADDITIONS (the dated section below — two of them her own ruling changes).

## KICKOFF (self-contained — what a fresh orchestrator reads, does first, and verifies)

**Read, in order:** CLAUDE.md + the canonical docs (auto-loaded) · `notes/DetailedPlanForPhases.md`
(the pointer + the `### 13u` section) · `notes/KnownIssuesAndTechDebt.md` (the owner-13u4 rows —
there are NINE now, enumerated in the closeout-refresh section below) · `notes/QUESTIONS.md`'s
open bundle (#117–#125 + carried; what she has ratified by kickoff day governs) ·
`notes/SessionResiliencyProtocol.md` · `notes/PhaseSizingGuidance.md` · THIS FILE IN FULL — the
original restyle roster, **HER ELEVEN ADDITIONS (2026-09-19, verbatim-faithful)**, and the
closeout-refresh block (baselines + what 13u3 changed under you, incl. the seam rider on her
items 3 · 8 · 11).

**Do first — the SIZING-AND-RULINGS SITTING** (she attends or rules async; bundle ≤4 per ask):
(1) items 2 and 9 want their rulings BEFORE any build (the capture microsyntax's exact rule and
the journal question her example implies; selection→take's semantics); (2) item 3's exact arm
(her lean: just allow many empty blocks — confirm, then it supersedes U-1's empty-block arm as a
recorded canon delta with the build); (3) item 8's scope (every merge vs the selected-run shape;
what the ceremony's per-pairing default does — the canon delta lands with the build); (4) the
phase's unit list + order named at plan time (the sizing guidance: one unit per implementer
session; this roster holds roughly a restyle spine + the eleven + nine owner rows — say so out
loud if it wants a split). **P-8's 27-site question is HERS** (narrow the constitution note or
sweep the sites) — bundle it.

**Cast:** her kickoff word governs; the standing default is Fable orchestrator ·
`opus-implementer` per unit · `fable-reviewer` on the ladder — and the SEAM RIDER binds
regardless: any diff reaching `BlockRangeIndex` / `EditorTextView` / `TypedReturn` /
`PaneTextAuthority` (her items 3 · 8 · 11 are the candidates) takes a Fable cold review.

**Verify at open (never run the full suite at a session's start — these ARE the baselines):**
the closeout-refresh block below carries them; the previous close's recorded result is the
baseline per the standing rule.

---

## THE SIZING-AND-RULINGS SITTING RECORD (2026-09-20 — she attended; rulings verbatim-faithful; BINDING)

**R-13u4-1 (item 2 — the capture microsyntax).** Her ruling, verbatim: *"what i meant by that is
the tag would be applied when within the curly brackets and if there's a smart book based on that
tag, it would go in that smart book based on standard tag rules. so {#dream} may land in a dream
journal and {#workout} might go in a smart workout book if I have one of those, for example."*
So: **`{#tag/path}` APPLIES the tag, and membership follows by the STANDING smart-book tag rules —
no routing machinery of any kind, no journal special case.** `{t:"my title"}` sets the title. Only
the braced forms parse; a bare #hashtag is never touched; malformed braces pass through as typed
text (the syntax as proposed at the sitting, unobjected). **Tokens DISAPPEAR once parsed** (her
pick of the offered pair). The RULE lands SHARED (the `CaptureKeys`/`PlainPaste` pattern); both
Mac capture doors face it this phase; the phone's face is filed as a MOBILE PARITY row at the
closeout. **The `applyTypedPath` hoist rides C1** (the KnownIssues forked-brains row's touch rule —
the tag-application road IS that brain; hoist to `Shared/`, never copy).

**R-13u4-2 (item 3 — EMPTY BLOCKS CHAIN; her ruling change, confirmed at the sitting).**
**Allow many empty blocks** — ⏎ with the caret in an empty block (chip ON) mints a fresh empty
block below through the one structural door and the caret moves into it; chains indefinitely
(*"You should be able to go down the list typing whatever you want in a series of empty
blocks"*). **SUPERSEDES U-1's "nothing in an empty block" arm**; the canon delta (AppSpec §7's
segmentation-trigger paragraph) lands WITH E1's build. Unchanged, stated: chip OFF stays
Return-as-content; abandoned empties STAY (U-19 (2)); ⌥⌘Z removes one mint per press (R-13u-3);
#92(c)'s empty-tail close-and-mint composes AHEAD of the chain.

**R-13u4-3 (item 8 — MERGE KEEPS THE NEWLINES; her ruling change, scope confirmed at the
sitting).** Scope: **EVERY merge door.** The join becomes the RENDERING join — merged text =
top + `"\n"` + bottom, byte-exact, no trimming, no conditionals — so the page reads
byte-identical before and after every merge; N-way chains join each seam the same way; the
ceremony's per-pairing DEFAULT flips to newline (space · nothing stay choosable per pairing).
The cross-block DELETE gesture's mid-paragraph edge-join is a delete, not a merge door — it
keeps its ruled normal-editor join. **SUPERSEDES the 2026-07-06 single-space join.** The traded
cost, stated and accepted at the sitting: a mid-sentence divide-then-merge returns `one⏎two`,
not `one two` (the ceremony's space option remains the road back). The canon delta (AppSpec §9's
merge bullet · OverallModel §7's merge line · the ceremony sentences citing the old join) lands
WITH E3's build. Pins asserting the space join are REWRITTEN to the ruled behaviour (a ruled
change, not a bug — no red-on-old owed; the state-transition suite updates in the same commit).

**R-13u4-4 (item 9 — SELECTION → TAKE).** Her ruling, verbatim: *"move alone should be fine -
the fact that there'll be a savepoint/commit of the current take right before moving is enough
to cover the case that someone wants it to stay - they can just revert it to that point if they
want."* So: **MOVE alone — and the quiet insurance savepoint of the current take is
LOAD-BEARING** (it is her stated cover for the stay case, not optional plumbing). Shape: ONE
transaction — insurance savepoint of the current take · the span leaves the current take's
buffer · a new take mints at the fan's END holding the span (branched from the current take,
NOT chosen) · ONE undo entry.

**R-13u4-5 (P-8's 27 `.fixedSize()` sites).** **Sweep the 27** with a deliberate per-site
`lineLimit` under UNIT S3, plus a grep pin so the class stays closed by construction (the 18j
literal-colour pin's form). The constitution stands as written; the KnownIssues row closes at
the sweep.

**R-13u4-6 (phase shape + cast).** **ONE phase, NINE units**, order E1→E2→E3→C1→C2→F1→S1→S2→S3
(seam surgery before polish — the restyle's closing walks catch seam regressions). ONE end
ladder over the combined diff, `fable-reviewer` (her kickoff word — *"Standard Opus implementer
Fable cold review standards apply"* — and the seam rider on items 3/8/11 regardless); cast
confirmed by her in-session: *"your cast sounds good."* The sizing statement was made out loud
per the guidance (nine units; ONE phase-sized among them — the restyle spine, decomposed
S1–S3; the 13d/13u3 collector shape) and she ruled one phase.

**BINDING PRINCIPLES:** the architect-phase constitution **P-1…P-9** (byte-verbatim in
`.claude/skills/architect-phase/SKILL.md`, preserved from 13b) binds every unit, with its
application notes; deviations are recorded with reasons, never silent. The closeout-refresh
block's seven what-changed items bind every chrome-touching unit (the gutter law · the
transaction-gated decoration refresh · the panel-as-one-surface · the status-seam vocabulary ·
`TakeCardMenu.rows` · the owner rows · lesson-copy pins). PROVISIONALs log to
`notes/QUESTIONS.md` — next free **#126**.

## THE LEDGER (one row per unit; every row owned; statuses flip in the same commit as the work)

| # | Unit | Contents (short) | Evidence | Status |
|---|---|---|---|---|
| E1 | Empty blocks chain (item 3, R-13u4-2) | `TypedReturn`'s empty-block arm → the chain; canon delta rides the build | pins + walk | **DONE** — 9 pins (7 red-first) · walked both voices + dark · AppSpec §7 delta landed · record below |
| E2 | ⌘⌫ checkbox-seam defect (item 11) | trace the mechanism first; red-on-old owed | red-on-old + walk on her verbatim repro | **CLOSED — DISMISSED AS HOLLOW AS STATED** (no product code changed): ⌘⌫ is `deleteToBeginningOfLine:` = the PARAGRAPH on macOS 26, and the block separator IS a newline — the reported gesture is structurally incapable of it. Measured five ways + WALKED. Her observable is real and belongs to **⌥⌫**; the product call is hers — **QUESTIONS #126**. 10 pins + the class sweep in the record below |
| E3 | Merge keeps the newlines (item 8, R-13u4-3) | the rendering join, every door; ceremony default; canon delta rides | state-transition suite + walk | NOT-STARTED |
| C1 | Capture microsyntax (item 2, R-13u4-1) | shared rule + both Mac doors; `applyTypedPath` hoist; phone face → parity row | pins + capture walk | NOT-STARTED |
| C2 | Selection → take (item 9, R-13u4-4) | the MOVE op + Write door; insurance savepoint load-bearing | state-transition + walk | NOT-STARTED |
| F1 | Index chapter-click lands low (item 10) | trace first — the un-adopted `LandingAuthority` is the recorded hypothesis | red-on-old if confirmed + walk | NOT-STARTED |
| S1 | The Settings shape (items 4/5/6/7 + row 59 + the 2a Settings fork) | tabs · search · fold fix · card grammar · ⌘[/unindent audit · merge-shortcut face; then walk row 53's two re-font occasions once reachable | walk both voices + appearances, captured | NOT-STARTED |
| S2 | Library & masthead faces (item 1 + rows 50/51/54) | click-to-cycle stamp + word-counter condense (word-target offer preserved) · `FlippingStamp` hoist + oracle edges · F-0 residue · Timeline voice | walk, captured | NOT-STARTED |
| S3 | Chrome singles + the conformance sweep (rows 44/45/46/63/67/68/69 + the Trash fork) | 27-site sweep + grep pin · tag sheet voiced · indicator ring · Restore Tutorial confirm · "pools" lesson sweep (re-seed consequence recorded) · seal-blind rename field · `blockNamingDoor` hygiene · Trash cards · closing conformance walk against the reference artifact | walk, captured | NOT-STARTED |

**CARRIED TO CLOSEOUT (grows as units close; nothing here may be lost):** MOBILE PARITY rows —
(1) the phone's empty-block Return should CHAIN too (E1's report: AppSpec §7 still says the
phone's Return model is unchanged; no mobile code consults `TypedReturn.act`); (2) the phone's
capture-microsyntax face (R-13u4-1, files when C1 closes). **OPEN PRODUCT CALLS** — (1) **QUESTIONS #126**
(E2): should ⌥⌫ stop at a line break, and at a block seam? Her report's real chord; nothing was
implemented, by the brief's stop rule.

## ENVIRONMENT TRAPS (every unit brief carries this section verbatim — the skill's rule)

- **Instance checks:** `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test
  host matches mid-run). Real-store instances are identified by STORE, not path — **NEVER quit or
  kill one** (quit-by-bundle-identity is walker law since 13u3's breach); no Release builds or
  `/Applications` refreshes while one lives; the install refresh follows the closeout's walk, at a
  sanctioned zero-instance window (her app quit by HER, never by a session).
- **Builds/tests:** Mac tests run from `App/Variorum/`, suite-level `-only-testing` only; confirm
  the "Test run with N tests" line (Swift Testing COUNTS skipped tests — read the `skipped:` lines);
  `xcodebuild build-for-testing` compiles without the runner; **NEVER add a custom build
  configuration** (any configuration not named exactly "Debug" builds SPM dependencies RELEASE and
  silently strips VariorumCore's DEBUG-gated oracles); zsh `pipestatus` for pipeline exit codes.
- **Suites beside a live session flash the test host's windows** — prefer zero-instance windows for
  timing-sensitive measurements. The flake list (adjudicate by the paired interleaved protocol,
  never a single isolated run): the differential-latency pin · `CanvasDragTrackingTests` ·
  `BlocksWorkbenchFaceTests`' single-click · row 58's read-click (warm-DerivedData covariate — it
  passed only on a fresh-DerivedData first run) · the row-49 landing arm (`BookOutlineLandingTests`'
  collapsed-story cell) · `ModeSwitchCarryTests`' top-of-Write arm.
- **Walks:** dev-store Debug build only (`io.lduarte.Variorum.debug`), `Tools/WalkKit/` + `cliclick`;
  screenshots in gitignored dirs (`notes/plans/13u4-screens/`); the Debug domain's `surfaceSize.*`
  keys may be wiped to stage cold runs (they regenerate) — NEVER the real store's.
- **Git:** never `git checkout` over uncommitted work; commit per piece and **PUSH after every
  commit** (CLAUDE.md's 2026-08-03 push rule; the skill's 13b-era "never push" line is superseded —
  CLAUDE.md wins). **No commit trailers** (her 2026-09-04 rule).
- **Backups:** any act near the real store takes the A1 rail first (WAL-safe, UTC-named) — this
  phase should never touch it before the closeout refresh.

## CAST & DISCIPLINE

**Orchestrator: Fable — this session** (her kickoff word; writes no feature code beyond
adjudication/record acts). **Implementer: `opus-implementer`, a FRESH session per unit, strictly
sequential, one at a time, ONE acceptance unit each.** **Cold review: `fable-reviewer`** over the
combined diff at the phase's end (the standing ladder — fresh reviewer per round, the cross-model
flow since the implementers are Opus, cap three rounds; the seam rider makes Fable mandatory —
E1/E2/E3 touch `TypedReturn`/`EditorTextView`/the seam roads). The hallucination guard binds every
fix (trace the mechanism yourself; red-on-old pins, behavioural-revert verified; a pin green on
both sides is DISMISSED as hollow and recorded). RULED BEHAVIOUR CHANGES (R-13u4-2/3) are not
bugs — their pins are rewritten to the ruling, no red-on-old owed; DEFECTS (E2, F1 if confirmed)
owe red-on-old. The acceptance spine (`TutorialWalkTests`) rides every unit's closing run.
PROVISIONALs log to `notes/QUESTIONS.md` (next free **#126**). Author-only calls are hard stops.
**Session resiliency (the checkpoint protocol, RESTATED in every brief):** commit per coherent
piece + push after every commit · the unit record's LIVE STATUS section written at the START and
flipped in the same commit as each piece, unverified claims marked PENDING · synchronous
foreground waits only, via the grep-poll loop (`grep -q '<EXIT LINE>' <log> && break; sleep 5` —
never `tail -f | grep -m1`, never a backgrounded run you end your turn on) · never spawn
subagents · no revert starts until the record names it and the pre-revert state is COMMITTED
(never scratchpad copies) · every death and resume noted in the record.

**The walk vs. her walk.** The IMPLEMENTER walks and captures each unit on the dev-store Debug
build (both voices, both appearances where chrome changes); the ORCHESTRATOR verifies by record
and walks the phase's acceptance before the ladder; HER one walk rides the refreshed install at
the end.

---

**~~+ DARK MODE (item 6)~~ — SHIPPED 2026-09-14 at 18j** (the 2026-09-12 use-report round pulled
it forward at her word; the appearance choice, the every-surface dark walk in both voices, the
dynamic prose ink). What remains of this phase is the RESTYLE CONTINUATION alone — one surface
per session, light and dark in both voices (dark now exists, so the both-appearances half of the
acceptance evidence is REAL, not deferred).

## Roster

1. **The app-wide restyle continuation** to the committed reference artifact
   `notes/plans/pre-13u-mockups/blocks-and-snippets.html` (her ruling: an actual style guide) —
   every surface opened conforms to the reference grammar (spacing scale, squarish-rounded
   controls, calm cards over hairline grids, solid geometric sidebar); `Theme/CalmGrammar.swift`
   is the vocabulary. The carried addendum at this file's end is the mandate's record.
2. **KnownIssues rows re-owned here at the split** (their cells said "13u2 (the restyle
   continuation)" — R-cor-12 made the restyle 13u4's, and the owners now say so): the 27 chrome
   `fixedSize` sites without a `lineLimit` (narrow P-8 — a constitution edit, HERS — or sweep) ·
   the unvoiced `BlockTagAssignmentSheet` · the Library's F-0 residue (`NoteCards`/`TagChips`
   extraction + the model's tag-acts split) · the `FlippingStamp` hoist + the stamp-face oracle
   edges + the midnight-rollover note · the Library TIMELINE's un-voiced type · the shell `park`
   fold's doc + oracle hygiene (rides the restyle's shell touch; the row itself stays 13u2's
   shell family — coordinate, don't duplicate).
3. Wave 2a's forks (Settings panes' card grammar; the Trash's card restyle) — the parent plan's
   restyle addendum enumerates them.

## Cast, evidence, discipline

Cast at its kickoff (expected: `opus-implementer` per surface · `opus-reviewer`; no seam, no
custody, no `Sync/` — Fable review only if that changes). Acceptance is USE: every touched
surface walked in both voices AND both appearances, captured, against the reference artifact;
zero behaviour changes ride a restyle commit (pins ride unmodified). The checkpoint protocol
restated in every brief.

---

# CARRIED VERBATIM AT THE SPLIT (2026-09-14) — from `phase-13u-feel-and-polish.md` (the restyle addendum)

## ADDENDUM 2026-08-31 (the pre-13u round, eighth wave) — the APP-WIDE RESTYLE continuation joins 13u2

At the pre-13u mockup feedback (the W8 rulings in `notes/plans/pre-13u-round.md`), the author ruled
the round's Blocks/Snippets HTML mockups **an actual style guide** for the whole app — her words:
*"it felt like I wanted the whole app restyled in that modern app look… i want to app restyled
liked this during batch 10 & during the 13u batch. I feel like the Takes page and Write page
already basically look like this"* — with the sidebar's liquid-glass floating pane retired for
*"more solid, geometric lines"*, and cohesion the point (*"the app just all has to get more
cohesive"*). The pre-13u round's Act 10 restyles the surfaces it touches; **13u2 inherits the
app-wide continuation** — every surface it opens conforms to the reference grammar (spacing scale,
squarish-rounded controls, calm cards over hairline grids, solid geometric sidebar), judged against
the PRESERVED reference artifact `notes/plans/pre-13u-mockups/blocks-and-snippets.html` (COMMITTED
to the repo at her follow-up ruling — an artifact that needs to survive). Anything the pre-13u
round's item 18 (book Outline glowup + index-like book view) defers lands here with it — and item
18 defers WHOLE if it defers at all (her ruling: one cohesive Book redesign, never split); the
pre-13u closeout will say which.


## HER ADDITIONS AT THE 13u3 MORNING SITTING (2026-09-19 — "some complaints and small fixes and bugs"; verbatim-faithful, one row each; item 12 [multi-block drag] STAYS UNSLOTTED at her same-message word: "hmmm okay we'll still leave it unslotted for now")

1. **The masthead stamp's clock-icon collapse + the word counter's condensed view.** Her words:
   *"clicking on edited date goes to created, then collapses to a little clock icon. remembers
   this on every note, so if you're normally in clock mode a new note would open with only a
   clock icon. Equally, it would be nice if the word counter thing at the bottom could condense
   as well - I like that it offers to set a word count target, so I want to keep that
   functionality, but maybe a little icon meant to represent count or something could be an
   optional condensed view. Or show only note, only block, or only icon. I don't necessarily
   want an appearance setting - I want these to be changed by clicking on them."* Route: the
   masthead/bar faces (the 18h/17q stamp family + `WordTargetFace`); click-to-cycle states,
   never a Settings toggle; the word-target offer PRESERVED.
2. **Quick-capture inline tags & titles (phone-first).** Her words: *"if you put a hashtag
   within curly brackets like {#dream} it would be a journal - I wouldn't want it applied to
   just any hashtag… And maybe a {t:"my title"}? this is more for quicknotes on the phone. I
   could see them disappearing from text or not disappearing once the note is made, either
   one."* Route: a capture MICROSYNTAX design — wants a short ruling first (the exact rule, the
   tag/journal relationship her example implies, disappear-or-stay); the RULE lands shared
   (the `CaptureKeys`/`PlainPaste` pattern), the phone's face becomes a mobile row when ruled
   (uncertainty preserved: her example sentence reads as tagging landing a quicknote as a
   journal entry — confirm at the ruling, do not infer).
3. **EMPTY BLOCKS MUST CHAIN — a RULING CHANGE she is making (supersedes U-1's "nothing in an
   empty block" arm; QUESTIONS #92's neighbourhood).** Her words: *"This is driving me insane -
   on an empty block, you can't keep making new lines and spawning more empty blocks. Direct
   violation of 'works how you'd expect a text editor to work'. Even worse, if you hit enter at
   the beginning of a line with text, that is a way to spawn many empty blocks, so it is
   possible to spawn a bunch of empty blocks but not in the intuitive way. Even when you have
   newline = new block on, need to allow for unlimited newlines. if that brings some kind of
   conflict up with not having a bunch of empty blocks on a work - we'll brainstorm potential
   solutions (having a single space in each block? just allowing many empty blocks?). I think
   just allowing empty blocks is probably the path forward though… You should be able to go
   down the list typing whatever you want in a series of empty blocks."* Her lean recorded AS a
   lean (allow many empty blocks); the build confirms the exact arm at kickoff. **EDITOR SEAM
   (`TypedReturn.act`, `Shared/EditorBrain`) — the Fable review rider applies to this item's
   diff.**
4. **Settings search.** Her words: *"simple text search within the settings menu - it's too
   hard to find how to make a callout."* Route: beside the standing Settings-fold row.
5. **⌘[ collision + how do you unindent?** Her words: *"command [ is moving me between my
   different open notes ? is that supposed to do that? I thought it unindented things. related -
   how are things unindented? that's further proof that I need a better formatting shortcut
   menu."* Route: the keybind audit (⌘[ vs 13k's unindent door) + the formatting-shortcut
   discoverability half of item 6.
6. **Settings menu restructure.** Her words: *"the settings menu could probably be broken up a
   little more - an overall one, then maybe tabs on text editing shortcuts, window / reshaping
   shortcuts, etc."* Route: with item 4 and the fold row — one Settings-shape pass.
7. **The merge shortcut is nowhere said.** Her words: *"where is the merge shortcut said ?? I
   don't see it in the shortcuts list or in the menu. it only shows up as shift command M if you
   try merging w takes on blocks that don't have takes - then the command shortcut shows up &
   is helpful."* Route: the ⌘/ helper + menu discoverability (the registry knows the chord; the
   faces don't say it).
8. **MERGE KEEPS THE NEWLINES — a RULING CHANGE she is making (the join rule; supersedes the
   2026-07-06 single-space-join decision for the selected-run shape).** Her words: *"Merging
   should not remove a newlines in the middle of the merge selected area, it should just make
   all newlines within the selected portion part of a single block."* I4's letter (newlines are
   content) — block seams inside a merged run become internal newlines. Exact scope (every
   merge? the ceremony's per-pairing default?) confirmed at the 13u4 kickoff; the canon delta
   lands with the build, per the standing rule.
9. **Selection → a take on the same block.** Her words: *"Having a command where you could
   highlight part of a block and move it into a take on that block (out of the take it's
   currently in) would be a nice time saver. not sure what complexities that would add."*
   Route: a capability CANDIDATE — wants its semantics ruled (what the current take keeps)
   before any build; her own uncertainty preserved.
10. **The Index-mode chapter click lands below its target.** Her words: *"there is sometimes a
    weird issue where clicking on the name of a chapter in a book isn't bringing you to the
    correct location, but instead a random location in the text a fair amount under it. Only
    seen in index mode. Not a huge problem."* Mechanism hypothesis recorded for the trace:
    Index has NOT yet adopted `Surface/LandingAuthority` (13u2b's "Takes/Index adopt at their
    next touch") — this item is likely that next touch; trace before fixing.
11. **⌘⌫ in a checkbox list deletes across the seam.** Her report verbatim: on the lines
    `- [ ] Create carousel format for blog posts (maybe just screenshots of personal blog to
    start?)` / `- [ ]`, *"Command delete at the end of the second line deletes this content:
    start?) ⏎ - [ ]"* — deleteToBeginningOfLine reaching through the newline into the previous
    line's tail. A DEFECT (red-on-old owed); list-machinery + seam adjacent — if the fix
    touches `BlockRangeIndex`/`EditorTextView`'s seam roads, the Fable review rider applies.

*(Routing note: items 3, 8 and 11 touch the editor seam or its brains — the 13u4 ladder takes a
`fable-reviewer` if any of their diffs land there, per the standing rider. Items 2 and 9 want
short rulings before build; the rest are direct fix/face rows.)*

## REFRESHED AT THE 13u3 CLOSEOUT (2026-09-19 — kickoff-ready)

**BASELINES AT OPEN:** core `swift test` **1604/174** green · the FULL Mac suite **2900/484 — green with ONLY row 58's recorded environment red (both issues one test, the byte-identical condition; the row-49-family arms did not recur in the closing run)**
— green with **1 recorded environment red** (`theReadClickLandsInIndexAtThatBlock`, row 58 —
NOW CARRYING UNIT G's warm-DerivedData covariate: it passed only on a fresh-DerivedData first
run, on two trees, and failed all five warm runs including alone; treat a red there as that
condition unless your diff touches the book Index) · iOS build **green** · the FULL mobile
suite **626/106 PASSED with 4 known issues** · lockstep marker **8** · `/Applications` = the
13u3 Release (hashes in `notes/handoffs/phase-13u3-handoff.md`). **Flake list:** the
differential-latency pin · `CanvasDragTrackingTests` · `BlocksWorkbenchFaceTests`' single-click
· row 58 · the row-49 landing arm (`BookOutlineLandingTests`' collapsed-story cell) ·
`ModeSwitchCarryTests`' top-of-Write arm (joined at 13u3 UNIT H, measured both ways).

**WHAT 13u3 CHANGED UNDER YOU — read before touching chrome, the editor's decorations, or any
lesson copy:**
1. **`Surface/ProseGutter.swift` is THE one horizontal-placement brain** — a surface's prose
   position is a pure function of its own width; `DecorLane` is GONE; decorations render in
   the gutter and STACK vertically at every width (R-13u3-3); `ProseGutterTests` pins the one
   law per surface. A restyle that moves a measure or left edge for a decoration re-opens her
   R-13u-9 reversal — don't.
2. **The editor's decoration refresh is transaction-gated** (`storageEditTransactionDepth`, a
   depth counter with one private writer pair + the deferral-witness oracle;
   `EditorDecorTransactionTests`) — new decoration work routes through the settle hop, never a
   synchronous refresh inside `storageDidEdit` (the R1-1 class, now pinned).
3. **The comments panel is ONE writing surface** (`CommentComposition` + the rebuilt
   `CommentsPanel`); the margin card is a READ face (R-13u3-6). Restyle its chrome freely; the
   drafts live on the MODEL (a lazy pass must carry their survival story — the A2 record).
4. **The status seam gained words:** `OpsRefusalCopy` now carries `variantIsChosen` ·
   `variantNotFound` · `commitNotFound`; the Write ⌘S door deliberately speaks the FILER's
   sentence, not the registry's (the R2-1 equality pin's doc says why and scopes itself to
   that door — do not widen or delete it).
5. **`TakeCardMenu.rows` is THE take-card act list** (Write's panel + the board compose it);
   the ceremony sheets carry drift checks — restyle their chrome, never the check order.
6. **Your rows, grown this phase:** the indicator ring's 8 pt overhang crossing the gutter
   glyphs · the AppKit-modal Restore Tutorial confirm · the "pools" lesson vocabulary · Block
   History's seal-blind rename field — beside the standing set (the Settings fold · the 27
   `fixedSize` sites or P-8's narrowing, hers · the unvoiced tag sheet · Library F-0 +
   Timeline sans · `FlippingStamp` · the re-font road's two unexercised occasions, walkable
   once the fold fix lands) — **and HER ELEVEN ADDITIONS above** (the section before this
   one), two of which are her own RULING CHANGES (empty blocks chain; merge keeps newlines)
   and three of which are seam-adjacent (3 · 8 · 11): **the ladder takes a `fable-reviewer`
   if any of their diffs reach `BlockRangeIndex`/`EditorTextView`/`TypedReturn` — the
   standing rider.**
7. **Lesson copy is pinned to doors now** (the H pattern: prose names a door ⇒ a pin asserts
   the surface renders it). A restyle that renames or moves a door updates the lesson AND its
   pin together, and the re-seed consequence rides every lesson edit (record it for the
   closeout's list).

---

## UNIT E1 BRIEF — EMPTY BLOCKS CHAIN (item 3, R-13u4-2; self-contained — read in this order)

**Read first, in full:** (1) this file's Status banner · HER ADDITIONS item 3 (her verbatim
words — the ruling's motivation) · THE SIZING-AND-RULINGS SITTING RECORD (R-13u4-2 is yours;
R-13u4-6 is the cast) · THE LEDGER · ENVIRONMENT TRAPS · CAST & DISCIPLINE · the closeout-refresh
block's seven what-changed items (item 2 — the transaction-gated decoration refresh — binds any
editor-refresh work; item 1's gutter law binds nothing you should touch, but know it exists).
(2) **AppSpec §7's segmentation-trigger paragraph** (the U-1 ruling this unit supersedes ONE arm
of) and **§9's structural-undo paragraph** (R-13u-3 — `newBlock` registers undo since 13u1;
your mint rides that road). (3) **QUESTIONS #92** — the three built PROVISIONAL Return edges;
(c)'s empty-tail close-and-mint composes AHEAD of your chain (an empty tail's first ⏎ closes the
tail and mints the block; subsequent ⏎ presses are your chain). (4) The code:
`App/Variorum/Shared/EditorBrain/TypedReturn.swift` (the pure decision brain — consulted at the
key, re-derived at the act) and its test suite; `EditorTextView.insertNewline(_:)` (the key
intercept, after the list door). Do your own reading — never from a summary.

**The build.** U-1's "nothing in an empty block" arm is SUPERSEDED (R-13u4-2): with the chip ON,
⏎ with the caret in an EMPTY block mints a fresh empty block below through the one structural
door and the caret lands in it — chains indefinitely. Unchanged, verify each: chip OFF stays
Return-as-content · abandoned empties STAY, never auto-removed (U-19 (2)) · ⌥⌘Z removes one mint
per press (R-13u-3's entry — verify your mint road registers; it should, it is `newBlock`
through the structural door) · ⇧⏎ stays the in-block newline · the #92(c) empty-tail arm
composes ahead. I10 note: an empty block holds one live take with `working_text=''` — legal
since Phase 1; if you find yourself needing an Operations-layer change, STOP and report to the
orchestrator (in-batch design forks are the architect's to rule).

**The canon delta rides YOUR build** (the standing rule — deltas land with the build, exactly as
ruled, never beyond): AppSpec §7's segmentation paragraph — the U-1 sentence's "nothing in an
empty block" arm is replaced by the chain rule, citing R-13u4-2 (2026-09-20). Touch nothing else
in the canonical docs.

**Evidence (the unit closes on this, not on pins alone):** the `TypedReturn` arm pins (the new
chain arm; the chip-OFF guard; the ⌥⌘Z per-press round-trip; the #92(c) composition) + a
hands-on WALK on the dev-store Debug build: in a chip-ON note, ⏎⏎⏎ down a run of empties, type
into several mid-run, ⌥⌘Z back one at a time; capture to `notes/plans/13u4-screens/`. Run the
suites your diff touches + the acceptance spine (`TutorialWalkTests`) at the unit's end — NEVER
the full suite at the start (the closeout-refresh block's baselines are the baseline).

**Your record:** append a `## UNIT E1 RECORD` section to THIS file with a LIVE STATUS table from
your FIRST commit (per-piece lines: DONE (hash) · IN-PROGRESS — exactly what remains ·
NOT-STARTED; unverified claims marked PENDING), flip the ledger's E1 row in your closing commit,
and name every seam file your diff touches (the ladder's Fable reviewer reads that list). The
checkpoint protocol in CAST & DISCIPLINE binds you from the first commit.

---

## UNIT E1 RECORD — EMPTY BLOCKS CHAIN (item 3, R-13u4-2)

**WHAT THIS UNIT DID NOT DO (the record's first line):** nothing outside the typed Return's
empty-block arm. No other unit's work (E2's ⌘⌫ seam defect, E3's merge join, the restyle spine)
was touched; `Sources/VariorumCore/` is untouched (zero operations-layer change — the mint rides
the shipped `newBlock` door); `Sources/VariorumCore/Sync/` is untouched; no schema, no migration;
no lesson copy edited (see "Judgment calls" below for why); the phone's Return model is unchanged
(a MOBILE PARITY candidate, named below for the closeout).

### LIVE STATUS (flipped in the same commit as each piece; unverified claims say PENDING)

| # | Piece | Status |
|---|---|---|
| 1 | The record + the traced mechanism + `.gitignore` for `13u4-screens/` | DONE (bc362f6a) |
| 2 | The pins written to the ruling (RED on the pre-change tree, recorded) | DONE (40e1fc92) — the red run below |
| 3 | The brain change (`TypedReturn`) + the dispatch + the canon delta (AppSpec §7) | DONE (6e111199) — 78/7 green, below |
| 4 | The walk on the dev-store Debug build, captured | DONE (db1e93ea) — 21 crops + the full captures |
| 5 | Closing suites + the ledger's E1 row | DONE (db1e93ea) — 174/20 + 14/2 + iOS, below |

### THE MECHANISM, TRACED (read before the diff — what changes and what cannot)

**The shipped arm.** `TypedReturn.act` (`App/Variorum/Shared/EditorBrain/TypedReturn.swift`)
walks the tiling for the caret's entry and answers `.nothing` at `if entry.length == 0` — U-1's
"nothing in an empty block", which R-13u4-2 supersedes. `.nothing` is consumed silently by
`EditorSurfaceController.runTypedReturnAct`'s `case .content, .nothing:` and no store write
happens. The decision is read TWICE per keystroke (at the key, `EditorViewModel.runTypedReturn`,
to answer "is this key mine?"; and again at the act's own turn, re-derived) — one function, so
the two readings cannot drift.

**The change.** That one arm answers `.emptyBlock(edge: .below, entryIndex: i, blockID:
entry.blockID, closingEmptyTail: false)` instead — the SAME verdict the end-of-a-block caret
already produces, so the act runs through the shipped body `insertEmptyBlock(edge:.below)` →
`ops.newBlock(in: postID, text: "", at: .after(blockID))` → the `.divide` seam. Chaining is free:
the act re-derives at its own turn, so the second ⏎ sees the block the first one made and mints
below THAT one, caret in it.

**Why no Operations-layer change is needed (the brief's STOP condition, checked):** the road is
already live and shipped — ⌘⇧⏎ (`insertBlockBelowCaret`) mints from an empty block today through
exactly this body; an empty block holds one live take with `working_text = ''` (legal since
Phase 1, I10 satisfied); and `StructuralSeamEdit.derive`'s `.divide` arm is arithmetically total
over a zero-length source (`prefixLength 0 <= oldRange.length 0`; the retained-bytes check reads
`"" == ""`), so the differential road lands and `applySeamEdit` skips the zero-length attribute
run (identity for an empty block lives in the index, exactly as for every other empty block the
app already mints). The DEBUG identity oracle re-checks the landed surface either way.

**`.nothing` becomes unreachable** — the only site that returned it is the arm being changed. It
is REMOVED rather than left dead, per this repo's own recorded doctrine ("a case that can never
be returned is the drift class", the `noDailyBook` retirement, AppSpec §9); the switch in
`runTypedReturnAct` loses its arm with it.

### THE PINS, AND THEIR RED RUN (piece 2 — the ruling's shape, before the brain moved)

R-13u4-2 is a RULED BEHAVIOUR CHANGE, so **no red-on-old is owed** (13u4 CAST & DISCIPLINE) — the
pins are rewritten to the ruling. They were nonetheless written and RUN FIRST, against the
unchanged brain, so the record carries what the old shape actually was rather than a claim about
it. Run: `xcodebuild test -scheme Variorum -destination platform=macOS
-only-testing:VariorumTests/TypedReturnTests -only-testing:VariorumTests/TypedReturnKeyTests`
from `App/Variorum/` → **43 tests in 2 suites, 13 issues, TEST FAILED (exit 65)** — the seven
pins below red, every other arm of both suites green (the U-1 family is otherwise untouched).

| Pin | Suite | What the OLD tree answered |
|---|---|---|
| `aReturnInAnEmptyBlockMintsAnotherBelowIt` (was `aReturnInAnEmptyBlockDoesNothing`) | `TypedReturnTests` | `.nothing` |
| `theChainAnswersAtTheCaretsOwnEmptyBlock` (new) | `TypedReturnTests` | `.nothing` at both carets |
| `theChipOffKeepsAnEmptyBlocksReturnAsContent` (new) | `TypedReturnTests` | GREEN on both sides — the chip guard sits ahead of the arm (recorded as such, not as evidence of the change) |
| `theEmptyTailClosesAndMintsAheadOfTheChain` (new) | `TypedReturnTests` | block arm `.nothing`; TAIL arm already green (#92(c) is untouched) |
| `twoQuickReturnsMakeTwoEmptyBlocksTheSecondBelowTheFirst` (was `twoQuickReturnsMakeOneEmptyBlockNotTwo`) | `TypedReturnKeyTests` | `["alpha", "", "gamma"]`, caret in entry 1 |
| `twoFastReturnsThenTypingLandTheTextInTheBlockTheLastOneMade` (was `…InTheOneBlockTheyMade`) | `TypedReturnKeyTests` | `["alpha", "x"]`, 2 entries |
| `aRunOfReturnsMakesARunSheCanTypeDownThrough` (new — her sentence) | `TypedReturnKeyTests` | `["alpha", "", "gamma"]` after ⏎⏎⏎ |
| `eachReturnInTheChainIsItsOwnStructuralUndo` (new — R-13u-3's road) | `TypedReturnKeyTests` | one entry on the stack, not two |
| `herS1ScenarioMakesABlockAndNeverALooseNewline` (re-pointed arm) | `TypedReturnKeyTests` | `["alpha", "beta", ""]` — "no second empty block", the superseded arm |

### THE BUILD (piece 3 — one arm, one retired case, one canon sentence)

1. **`App/Variorum/Shared/EditorBrain/TypedReturn.swift`** — the empty-block arm answers
   `.emptyBlock(edge: .below, …, closingEmptyTail: false)`; `case nothing` retired from `Act`
   (nothing returns it any more — the drift class); the file header carries her ruling and what
   it does NOT change. The arm still sits ahead of `textAt`, so an empty block costs no text read.
2. **`EditorSurfaceController.runTypedReturnAct`** — the switch loses `.nothing`; `case .content`
   keeps its own reason (a re-derivation that is no longer this gesture) and names the retirement.
3. **`EditorViewModel.retractListContinuationNewline`'s doc** — its R2-3 "unreachable today"
   argument cited `.nothing`; re-worded to the same conclusion on the standing reason (the block
   holds the list it just exited; R1-4's line-end rule excludes `.content`).
4. **`notes/AppSpec.md` §7's segmentation-trigger paragraph** — the canon delta, exactly as ruled
   and no further: the U-1 sentence's *"nothing in an empty block"* arm is replaced by the chain,
   citing R-13u4-2 (2026-09-20) with her words, and U-19 (2)'s "the empties STAY" kept beside it.
   Nothing else in the canonical docs is touched.

**ZERO changes to:** `Sources/VariorumCore/` (the mint is the shipped `ops.newBlock` through
`insertEmptyBlock`, the one structural door) · `Sync/` · schema/migrations · the phone.

**Green after the change:** the same command plus the whole Return family —
`TypedReturnTests` · `TypedReturnKeyTests` · `ReturnKeyTraceTests` · `SoftNewlineTests` ·
`ReturnKeyUndoSignTests` · `ListContinuationTests` · `NestedListDoorTests` → **78 tests in 7
suites passed** (exit 0, no skips). The list family (K5/K8) and ⇧⏎ (A15) are in that run on
purpose: they share the key and its intercept order, and none of them moved.

### SEAM FILES THIS DIFF TOUCHES (the ladder's Fable reviewer reads this list)

- `App/Variorum/Shared/EditorBrain/TypedReturn.swift` — **the editor seam's decision brain** (the
  pure rule; consulted at the key AND re-derived at the act). The one arm + the retired case.
- `App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift` — the dispatch's switch
  arm only (`runTypedReturnAct`). No new road: the act routes to the SHIPPED
  `insertEmptyBlock(edge:entryIndex:blockID:)` body, which is also ⌘⇧⏎'s.
- `App/Variorum/Variorum/Features/Editor/EditorViewModel.swift` — a doc comment only (no code).

**NOT touched, deliberately:** `BlockRangeIndex` (no tiling change — consecutive empty entries
already carry distinct offsets by the separator rule) · `runStructural` and its seam derivation
(`StructuralSeamEdit`, unchanged: the `.divide` arm is already total over a zero-length source) ·
`Operations` · `PaneTextAuthority` · every list door (`MarkdownActs`), whose intercept still runs
FIRST.

### EVIDENCE — THE WALK (the unit closes on this, not on pins)

**Build:** `App/Variorum/DerivedData/13u4e1/Build/Products/Debug/Variorum.app`
(`io.lduarte.Variorum.debug`, the fenced dev store; `/Applications/Variorum.app` was never
touched and no instance of hers existed at any point — `pgrep -fl 'Variorum.app/Contents/MacOS'`
checked at the start, before every quit and at the end). Captures:
`notes/plans/13u4-screens/e1/` (gitignored) — the full window per step, plus `e1/crops/` with the
21 read crops named in order. Seams were ON (⌘⇧B) for the whole walk, because an empty block is
otherwise invisible; the bottom bar's `block N/M` is the second witness at every step.

| # | Step | What the app did | Capture |
|---|---|---|---|
| 1 | New note via the shelf's quick-entry bar (`alpha`), Write, caret at the block's end, ⏎ | an empty block below, caret in it — **block 2/2** | `crops/01-*` |
| 2 | **⏎ again, in that EMPTY block** — the unit | **block 3/3**: another empty below, caret in it. *(On the pre-change build this was the ruled no-op and the bar stayed 2/2.)* | `crops/02-bar-block-3of3-THE-CHAIN.png` |
| 3 | ⏎ a third time | a run of three empties under `alpha`, seams drawn for each — her *"a series of empty blocks"* | `crops/03-*` |
| 4 | Click into the MIDDLE empty (**block 3/4**) and type `two` | the words land there; the empties above AND below STAY (U-19 (2)); `1w block · 2w in note` | `crops/04-*`, `crops/05-*` |
| 5 | ⌥⌘Z | receipt **"Undid: New Block"**, **block 3/3** — ONE mint per press (R-13u-3's road) | `crops/06-*` |
| 6 | ⌥⌘Z again | **block 2/2** — the second mint back too; the block she had typed into went to the tray rather than vanishing (the standing insurance behaviour, not this unit's change) | `crops/07-*` |
| 7 | Aa ▸ **newlines make blocks: on → off**, then ⏎ ⏎ in the empty block | **block 2/2, unchanged** — the newlines are content; the chip's own receipt speaks. Chip turned back ON afterwards | `crops/08-*`, `09`, `10`, `11` |
| 8 | **Study voice** (Settings ▸ Appearance), ⏎ at `alpha`'s end then ⏎ in the empty it made | **block 3/4** — identical chain in the second voice; voice restored to Terminal afterwards | `crops/12-*` |
| 9 | **DARK** (`appearanceChoice dark`, relaunch), Terminal voice, ⏎ in an empty block | **block 3/4 → 4/5**, caret in the new one; seams legible on the black room | `crops/13-*`, `crops/14-*` |

**Dev-store state left as found:** voice back to **Terminal**, `appearanceChoice` back to
**system**, the note's chip back **ON**, the app QUIT BY IDENTITY
(`tell application id "io.lduarte.Variorum.debug" to quit`, never a ⌘Q keystroke — the 13u3
breach's walker law). The walk's own note (`2026-09-20`, in no book) is left in the dev store, as
every walk's fixtures are. Block seams (⌘⇧B) were left ON — a per-window toggle, not a stored
setting.

**Both appearances AND both voices were walked**, though this diff contains **zero view or chrome
code** (the change is one arm of a pure decision brain plus a switch arm) — so the appearance is
not a variable for it; the dark pass is recorded because the plan's bar asks for it and it was a
minute's work.

### CLOSING RUNS (at the unit's END — never the full suite at the start)

| Run | Command (from `App/Variorum/`) | Result |
|---|---|---|
| The Return family + the neighbours it shares the key with + **the acceptance spine** | `xcodebuild test -scheme Variorum -destination platform=macOS` with `-only-testing:` for `TypedReturnTests` · `TypedReturnKeyTests` · `ReturnKeyTraceTests` · `SoftNewlineTests` · `ReturnKeyUndoSignTests` · `ListContinuationTests` · `NestedListDoorTests` · `CrossBlockCompoundTests` · `MenuFlightDoorAwaitTests` + the ELEVEN `Tutorial*` types | **174 tests in 20 suites passed** (exit 0, no skips) |
| The edit-routing pair (re-run under their real TYPE names — the `-only-testing` file-name trap: `VariorumTests/EditRoutingTests` matched NOTHING in the run above and was silently ignored, exactly the documented class; the file holds `ArmedEditTests` + `MacEditRoutingTests`) | `-only-testing:VariorumTests/ArmedEditTests -only-testing:VariorumTests/MacEditRoutingTests` | **14 tests in 2 suites passed** |
| **iOS build** — `Shared/EditorBrain/` compiles into `VariorumMobile` too, so a Shared edit owes it | `xcodebuild build -scheme VariorumMobile -destination generic/platform=iOS -derivedDataPath DerivedData/13u4e1-ios` | **BUILD SUCCEEDED** |

No full-suite run was made at this unit's start; the plan's closeout-refresh baselines stand as
the baseline (the standing rule).

### JUDGMENT CALLS (each one a reviewer can reverse in a line)

1. **`case nothing` removed rather than left dead.** Nothing returns it after the ruling. Left in
   place it would be a case citing a superseded ruling that no code path can produce — the drift
   class this repo has retired twice by name (`noDailyBook`; AppSpec §9). Reversing costs one enum
   case and one `case .content, .nothing:`.
2. **A GAP SLOT's empty entry chains like any other empty block.** A gap slot (a missing block or
   no renderable variant — a sync-race state) renders as a zero-length entry, so the new arm
   answers `.emptyBlock` there too and the mint's refusal, if the op refuses, is spoken by the
   door (P-2). Deliberate, and it is exactly what ⌘⇧⏎ has always done from the same caret — the
   two doors share the body precisely so they cannot answer one gesture two ways. No new refusal
   was invented (that would be product invention).
3. **The tutorial's Return lesson was NOT edited.** Its sentence names the two positions it
   teaches (*"at the end of a paragraph, a new empty block below it; in the middle of one, a
   divide at the cursor"*) and never taught the superseded arm, so nothing in it became false.
   Adding "…and in an empty one, another below" would be new copy — and every lesson edit carries
   the re-seed consequence, which is a cost with no correction behind it here. Named for the
   closeout in case the phase wants the sentence widened at S-something.
4. **The phone is untouched.** AppSpec §7 says the phone's Return model is unchanged and no mobile
   code consults `TypedReturn.act`; **a MOBILE PARITY row is owed at the closeout** — the phone's
   empty-block Return should chain too, and that is the mobile catch-up's call, not this unit's.
5. **No `notes/QUESTIONS.md` entry was opened.** R-13u4-2 settles the arm; the three neighbours
   (#92 (a)/(b)/(c)) are untouched and still say what they said — (c) is now pinned as composing
   AHEAD of the chain.

### WHAT A FRESH SESSION WOULD NEED TO FINISH THIS (nothing — but for the record)

Everything is committed and pushed: the pins (`TypedReturnTests`, `ReturnKeyTraceTests`), the
brain (`TypedReturn.swift`), the dispatch (`EditorSurfaceController.runTypedReturnAct`), the
canon delta (AppSpec §7), the walk captures (gitignored, listed above), this record.

---

## UNIT E2 BRIEF — THE ⌘⌫ CHECKBOX-SEAM DEFECT (item 11; self-contained — read in this order)

**Read first, in full:** (1) this file's Status banner · HER ADDITIONS item 11 (her verbatim
repro — it is your fixture) · THE SIZING-AND-RULINGS SITTING RECORD (R-13u4-6 is the cast; no
ruling pre-decides this unit — it is a DEFECT, trace-first) · THE LEDGER · ENVIRONMENT TRAPS ·
CAST & DISCIPLINE · the closeout-refresh block's what-changed items (item 2 — the
transaction-gated decoration refresh — binds any editor-refresh work) · **the UNIT E1 RECORD
above** (the empty-block arm of `TypedReturn.act` changed under you on this branch — know it
before reading traces). (2) The code, tracing rather than assuming: `EditorTextView`'s
delete-family intercepts and their seam roads · `Shared/EditorBrain/BlockRangeIndex.swift` (the
seam guards: `emptyBlockDeletion`, `textedSeamPair`, and the plan/authorize split) ·
`MarkdownActs`' list machinery (the checkbox lead is the bullet shape — 13k K8's law). Do your
own reading — never from a summary.

**The defect, her report verbatim (the fixture):** on the lines
`- [ ] Create carousel format for blog posts (maybe just screenshots of personal blog to start?)`
/ `- [ ]`, *"Command delete at the end of the second line deletes this content: start?) ⏎ - [ ]"*
— deleteToBeginningOfLine reaching through the newline into the previous line's tail. The
expected shape (the pin's assertion): ⌘⌫ at the end of a line deletes to THAT line's beginning
and never through its newline — the previous line's tail survives byte-intact.

**Discipline, in order:** (1) REPRODUCE her exact two lines in a pin FIRST — this is a defect,
so **red-on-old is owed**: the pin must fail on the pre-fix tree (behavioural-revert verified)
and pass after. If the pin runs GREEN on the shipped code, the finding is hollow as stated —
STOP, record what you measured, and report to the orchestrator instead of fixing something else.
(2) TRACE the concrete mechanism (inputs → wrong range → wrong store state) yourself before any
fix — candidate roads above, but the trace decides, not the list; note whether the two lines
live in ONE block (a list stays whole — the newline is content) or two, because it changes which
guard should have caught it. (3) Fix at the traced site, smallest true fix; sweep the CLASS
(the other delete-family chords at the same position — ⌘⌫'s siblings — each verdicted fixed or
provably safe, one line each in the record). (4) If the fix touches `BlockRangeIndex`/
`EditorTextView`'s seam roads, say so in the record's seam-file list — the ladder's Fable
reviewer reads it.

**Evidence:** the red-on-old pin (+ any class-sweep pins) + a hands-on WALK on the dev-store
Debug build reproducing her exact two lines, ⌘⌫ at the second line's end, before/after captures
to `notes/plans/13u4-screens/e2/`. Run the suites your diff touches + the acceptance spine
(`TutorialWalkTests`) at the unit's end — NEVER the full suite at the start.

**Your record:** append a `## UNIT E2 RECORD` section to THIS file with a LIVE STATUS table from
your FIRST commit (unverified claims PENDING), the traced mechanism stated as inputs → wrong
state, the red-run evidence, the class-sweep table, and the seam-file list; flip the ledger's E2
row in your closing commit. The checkpoint protocol in CAST & DISCIPLINE binds you from the
first commit.

---

## UNIT E2 RECORD — THE ⌘⌫ CHECKBOX-SEAM DEFECT (item 11)

**WHAT THIS UNIT DID NOT DO (the record's first line): IT CHANGED NO PRODUCT CODE AT ALL.** No
fix was made, because the finding as stated does not reproduce — the brief's own stop rule
(*"a pin green on both sides … STOP … do not fix something adjacent"*). Untouched, therefore:
`BlockRangeIndex` · `EditorTextView` · `EditorViewModel` · `EditorSurfaceController` ·
`TypedReturn` · `PaneTextAuthority` · `MarkdownActs` · `Sources/VariorumCore/` (and `Sync/`,
schema, migrations) · every view and every lesson string. No other unit's work (E1's Return
chain, E3's merge join, the restyle spine) was touched, and the ⌥⌫ behaviour her report actually
describes was **deliberately not changed** — it is a product call, logged as QUESTIONS #126. The
unit's whole diff is one new test file and this record.

### LIVE STATUS (flipped in the same commit as each piece; unverified claims say PENDING)

| # | Piece | Status |
|---|---|---|
| 1 | The record skeleton + the reading | DONE (572afc70) |
| 2 | THE TRACE — what each delete chord proposes, measured in bare AppKit, on a TK2 view, and through the app's own road | DONE (2ec16d26) — 10 pins, all GREEN on the shipped tree |
| 3 | The brief's stated pin, written and run → **the HOLLOW verdict** (no fix; the stop rule) | DONE (2ec16d26) — the two ⌘⌫ pins are it |
| 4 | The delete-family class sweep, each chord verdicted | DONE (2ec16d26) — the table below |
| 5 | The walk on the dev-store Debug build, captured (her exact two lines, both chords) | DONE (ceaeaabe) — 8 captures + 4 named crops |
| 6 | QUESTIONS #126 (her call, nothing implemented) + closing suites + the ledger's E2 row | DONE (94ffb4cc) — 122/11 + the spine 78/11, below |

### THE VERDICT IN ONE LINE

**The finding AS STATED is HOLLOW — ⌘⌫ cannot reach through a newline, measured five ways —
and her reported OBSERVABLE is REAL and reproduces byte-for-byte under the neighbouring chord
⌥⌫, where it is AppKit's own word-delete rule.** Per the brief's stop rule (*"If the pin runs
GREEN on the shipped code, the finding is hollow as stated — STOP, record what you measured, and
report to the orchestrator instead of fixing something else"*), **no product code was changed by
this unit.** What ⌥⌫ should do at a seam is a product call: logged as QUESTIONS #126, not
implemented.

### THE MECHANISM, TRACED (measured, never assumed — `CommandDeleteLineTests.swift`)

**Inputs → what the KEY proposes.** Her two lines are 95 + 1 + 6 UTF-16 units
(`- [ ] Create carousel … to start?)` · `\n` · `- [ ] ` — the second line is
`MarkdownEditing.continuedCheckboxLead`, which is what 13k K5's ⏎ actually types). With the caret
at the document end (the end of her second line), driven as REAL key events through
`keyDown` → `interpretKeyEvents` → the standard key bindings:

| Chord | Selector dispatched | Range proposed | What it takes |
|---|---|---|---|
| ⌫ | `deleteBackward:` | `{101, 1}` | the trailing space |
| **⌥⌫** | **`deleteWordBackward:`** | **`{88, 14}`** | **`start?)⏎- [ ] ` — HER SENTENCE, byte for byte** |
| **⌘⌫** | **`deleteToBeginningOfLine:`** | **`{96, 6}`** | **exactly the second line; the first survives byte-intact** |
| ⌦ | `deleteForward:` | — | nothing (the caret is at the document end) |
| ⌥⌦ | `deleteWordForward:` | — | nothing |
| ⌘⌦ | `noop:` | — | nothing — **the chord is bound to nothing on this layout** |

**Why ⌘⌫ is STRUCTURALLY incapable of the reported gesture, not merely observed not to do it.**
Two independent facts, both pinned:

1. **`deleteToBeginningOfLine:` means the PARAGRAPH on macOS 26, not the visual line.** Measured
   on a 300 pt-wide view where her first line wraps onto three fragments: ⌘⌫ at its end proposes
   `{0, 95}` — the whole paragraph, not the last fragment
   (`commandDeleteResolvesToTheParagraphNotTheVisualLine`). Its unit therefore *stops* at a
   newline by definition; there is no wrap-related off-by-a-fragment for it to have.
2. **The editor's block separator IS a newline** — `EditorDocumentCore.separator = "\n"`
   (author-confirmed interpretation 2a). So a paragraph-scoped deletion cannot reach through a
   block seam either: the seam is the paragraph's own stopping character.

Measured five ways, all agreeing: bare `NSTextView` · an explicit TEXTKIT 2 view built the way
`EditorTextView` builds its stack (TEXTKIT2_NOTES §3's selection family was the live suspect —
it is not implicated) · the app's real editor in **her own one-block repro shape** · the app's
real editor in the **two-block shape** · a wrapped single paragraph as the control.

**Which shape her note is in — the brief's question, answered by the pin rather than assumed.**
She *typed* the list, and 13k K5's list door claims ⏎ inside a list (`insertNewline` consults
`MarkdownActs.listReturn` BEFORE `claimTypedReturn`), so the newline is CONTENT and **both items
live in ONE block** — asserted in `herNote`, which drives the real ⏎ key and then checks
`index.entries.count == 1`. So in her own repro there is no seam at that newline at all, and no
seam guard (`emptyBlockDeletion`, `textedSeamPair`, the cross-block planners) is even consulted:
the verdict is `.block(0)` and the edit is an ordinary in-block one. **The two-block shape is
real too** (a PASTED or imported checklist segments on entry — one block per item), so both are
pinned; ⌘⌫ is correct in both.

**What DOES reproduce her sentence.** ⌥⌫ takes `start?)⏎- [ ] ` — and it takes it in a bare
`NSTextView` with nothing of Variorum's wired to it
(`optionDeleteIsTheChordThatTakesHerContent`). In her one-block note the app therefore does
byte-for-byte what TextEdit does with that keystroke, across a newline that is content (I4). In
the two-block shape the same span crosses a seam and takes the ruled cross-block road (R-13u-2 /
item 5): the block the span covers WHOLE rides `deleteBlock` (the Trash/tray road, recoverable,
receipt spoken) and the surviving end keeps its cut text.

### THE CLASS SWEEP — every delete-family chord at that caret, verdicted

Each row is measured, not reasoned: the trace suite drives the chord and the editor suite checks
what the store holds afterwards.

| Chord | At the second line's END | At the seam's LEADING side (end of block 1) | Verdict |
|---|---|---|---|
| ⌫ | one character of the caret's own block | the ruled seam keystroke — A7's empty-block carve / #34's texted-seam merge | **provably safe** (its range is ≤ 1 char; the seam carves own that geometry whole) |
| ⌥⌫ | `start?)⏎- [ ] ` — crosses a content newline (one block) or a seam (two blocks) | n/a (backward) | **REAL, and it is the reported observable** — AppKit's own rule in one block; the ruled cross-block road across a seam. **PRODUCT CALL, QUESTIONS #126 — deliberately NOT fixed** |
| ⌘⌫ | the second line only | n/a (backward) | **provably safe** — paragraph-scoped, and the separator is a newline |
| ⌦ | nothing (document end) | joins the two blocks with the ruled merge join (` `) | **ruled behaviour**, and E3 is the unit that changes that join (R-13u4-3) — untouched here |
| ⌥⌦ | nothing | takes block 2's first word; the span covers block 2 whole, so it rides the cross-block road | **same class as ⌥⌫**, same product call |
| ⌘⌦ | nothing — `noop:` | nothing — `noop:` | **provably safe** — unbound on this layout |

**The pane surfaces** (`PaneTextView`, Takes/Lenses) are outside the class by construction: a
pane holds ONE take's buffer with no separators in it, so no delete chord there can reach a seam.
The INLINE (book) editor is the same `EditorTextView` subclass with the same bindings and is
covered by the same pins.

### SEAM FILES THIS DIFF TOUCHES (the ladder's Fable reviewer reads this list)

**NONE.** `BlockRangeIndex`, `EditorTextView`, `TypedReturn`, `PaneTextAuthority`,
`EditorViewModel`, `EditorSurfaceController`, `MarkdownActs`, `Sources/VariorumCore/` — all
untouched. The unit's whole diff is ONE new test file
(`App/Variorum/VariorumTests/CommandDeleteLineTests.swift`) and this record.

### EVIDENCE — THE WALK (the unit closes on USE, not on pins)

**Build:** `App/Variorum/DerivedData/13u4e2/Build/Products/Debug/Variorum.app`
(`io.lduarte.Variorum.debug`, the fenced dev store). `pgrep -fl 'Variorum.app/Contents/MacOS'`
was checked at the start (ZERO instances — hers was not running at any point), and the dev
instance was quit **by identity** at the end (`tell application id "io.lduarte.Variorum.debug" to
quit`; zero instances after — the 13u3 breach's walker law). `/Applications/Variorum.app` was
never touched. Captures: `notes/plans/13u4-screens/e2/` (gitignored), with `e2/crops/` holding
the four read crops below.

| # | Step | What the app did | Capture |
|---|---|---|---|
| 1 | Her first line typed into the shelf's quick-entry bar, ⏎ to file and open | the note opens in Write; the line WRAPS onto two visual lines — her picture exactly | `01-note-opened.png` |
| 2 | Caret to the document end (⌘↓), **⏎** | 13k K5 continues the checklist: `- [ ] ` on a second line, **inside the SAME block** — one editing ring around both lines, the newline content (I4) | `crops/02-her-two-lines.png` |
| 3 | **⌘⌫ at the end of the second line — HER GESTURE** | the `- [ ] ` goes and **NOTHING ELSE**: `start?)` and the whole first line survive byte-intact, the caret on the now-empty second line. **The reported defect does not reproduce in USE either.** | `crops/03-after-cmd-delete-FIRST-LINE-INTACT.png` |
| 4 | ⌫ then ⏎ (the app's own doors) to re-stage her two lines | back to the step-2 picture, byte-exact | `crops/04-restaged-two-lines.png` |
| 5 | **⌥⌫ at the same caret** | `start?)⏎- [ ] ` **GONE** — the note reads `…personal blog to `. **This is her report, reproduced exactly, by the neighbouring chord.** | `crops/05-after-opt-delete-HER-CONTENT-GONE.png` |

**Not walked, stated:** the TWO-BLOCK shape's two chords (⌘⌫ takes only the second block; ⌥⌫
rides the cross-block road and the second block leaves for the Trash). Both are pinned through
the REAL key-event pipeline — `keyDown` → AppKit's bindings → `shouldChangeText` → the planners →
the operations — in `CommandDeleteInEditorTests`, which is the production road end to end; the
walk's own staging roads (the quick-entry bar's ⇧⏎, which makes one block here, and synthetic
typing into the TK2 editor, which drops characters — the standing UNIT B walker fact) could not
lay that fixture down reliably, and a fixture typed wrong is worse evidence than a pin driven
right. Recorded rather than papered over.

**Dev-store state left as found:** voice **Terminal**, appearance **system** (neither was
touched — this unit changed no chrome and no setting). Two walk notes dated `2026-09-20` are
left in the dev store, as every walk's fixtures are; the second one's prose is mangled (the
quick-entry bar dropped characters on that pass) and it is a fixture, not a finding.

**Both voices / both appearances were NOT walked, and the reason is structural:** this unit's
diff contains ZERO product code — no view, no chrome, no brain, no operation. There is nothing
for a voice or an appearance to render differently.

### JUDGMENT CALLS (each one a reviewer can reverse in a line)

1. **The unit STOPPED instead of fixing ⌥⌫.** The brief's stop rule is explicit, and the
   substance backs it: in her own note the two lines are ONE block, the newline between them is
   content (I4), and the app does byte-for-byte what a bare `NSTextView` does with that
   keystroke — so "fixing" it means overriding a system chord's system meaning, which is
   product behaviour the spec does not define. QUESTIONS #126 carries it with three options per
   half. Reversing this costs a ruling, not a re-trace.
2. **The trace pins were KEPT rather than deleted once they came up green.** A green pin here is
   the finding's disposition — and the two ⌘⌫ ones are exactly the shape the brief asked for
   ("⌘⌫ … never through its newline"), which is worth owning as a regression guard now that the
   answer is written down. They cost 0.5 s.
3. **The ⌥⌫ pins are named CHARACTERIZATION in their own doc comments**, not approval: if she
   rules (a)(ii) or (b)(ii) on #126, those two pins are rewritten to the ruling (a ruled change,
   no red-on-old owed — the 13u4 CAST & DISCIPLINE rule), and the ⌘⌫ pins beside them do not
   move. The repo's own precedent for pinning a behaviour you do not endorse is SyncSpec §7's
   documented concurrent-divide outcome.
4. **The TWO-BLOCK shape was pinned but not walked** — the staging roads available to a walker
   could not lay that fixture down faithfully (named in the walk section with the measured
   reason). The pins for it drive REAL key events through the whole production road, which is
   the same pipeline the walk exercises.
5. **No `KnownIssuesAndTechDebt.md` row was opened.** There is no deferred WORK here: there is a
   question for her (#126) and a measured non-defect. A row whose owner is "a ruling" would be
   the drift class.

### CLOSING RUNS (at the unit's END — never the full suite at the start)

| Run | Command (from `App/Variorum/`) | Result |
|---|---|---|
| The new pins + every suite that shares the key, the seam or the delete roads | `xcodebuild test -scheme Variorum -destination platform=macOS` with `-only-testing:` for `CommandDeleteLineTraceTests` · `CommandDeleteInEditorTests` · `TypedReturnTests` · `TypedReturnKeyTests` · `ReturnKeyTraceTests` · `ListContinuationTests` · `NestedListDoorTests` · `WholeBlockDeleteTests` · `CrossBlockCompoundTests` · `ArmedEditTests` · `MacEditRoutingTests` | **122 tests in 11 suites passed** (exit 0, no skips) |
| **The acceptance spine** (`TutorialWalkTests`) — run under its ELEVEN REAL TYPE NAMES: the `-only-testing` FILE-name trap again (`VariorumTests/TutorialWalkTests` matches nothing and is silently ignored — E1 met the same trap on `EditRoutingTests`) | `-only-testing:` for `TutorialBookShapeTests` · `TutorialDoorTests` · `TutorialWritingActsTests` · `TutorialTakesActsTests` · `TutorialStructureActsTests` · `TutorialLookingActsTests` · `TutorialLibraryActsTests` · `TutorialDeletionActsTests` · `TutorialWherePlacesActsTests` · `TutorialPrivacyChapterTests` · `TutorialFannedMatrixTests` | **78 tests in 11 suites passed** (exit 0) |

No full-suite run was made at this unit's start; the plan's closeout-refresh baselines stand as
the baseline (the standing rule). **No iOS build was owed** — nothing under `Shared/` was
touched.

### WHAT A FRESH SESSION WOULD NEED TO FINISH THIS

Nothing. The unit is closed on a verdict, not on a fix. What is OPEN is hers: **QUESTIONS #126**
(should ⌥⌫ stop at a line break · at a block seam), with the options written out and the
measurements behind them in this record. If she rules a clamp, the build is small and its home
is `EditorTextView` (an intercept of `deleteWordBackward:`/`deleteWordForward:` that clamps the
proposed range to the caret's own line, through the ordinary input path — the `MarkdownActs`
shape), and it WOULD be a seam diff, so the Fable rider would apply to it.

---

## UNIT E3 BRIEF — MERGE KEEPS THE NEWLINES (item 8, R-13u4-3; self-contained — read in this order)

**Read first, in full:** (1) this file's Status banner · HER ADDITIONS item 8 (her verbatim
words) · THE SIZING-AND-RULINGS SITTING RECORD (**R-13u4-3 is yours and BINDING** — every merge
door; the rendering join, byte-exact, no trimming, no conditionals; the ceremony default flips;
the cross-block DELETE keeps its join; the traded cost is accepted and recorded) · THE LEDGER ·
ENVIRONMENT TRAPS · CAST & DISCIPLINE · the UNIT E1 and E2 RECORDs above (E2's class-sweep
table names ⌦-at-the-seam as riding the merge join — that finding is why the classification
below exists). (2) **AppSpec §9's merge bullet + the mergeCeremony bullet** (the 2026-07-06
space-join parenthetical you supersede; the ceremony's "defaulting to the canon rule above"
sentence — note it survives verbatim once the canon rule changes) and **OverallModel §7's MERGE
paragraph**. (3) The code: `Sources/VariorumCore/Operations/Operations+Structural.swift` (the
join comment ~line 875 and `merge`; `mergeCeremony`'s per-pairing default; find where the
default join derives) · the 9d N-way merge chain · the bulk bars' `mergeSelectedBlocks`/
`mergePicked` roads · every consumer of the join (grep, don't assume). Do your own reading.

**THE ARCHITECT'S APPLICATION NOTE (flagged to her, reversible in a line — build to it):**
R-13u4-3's own distinction is DOORS vs DELETES. Enumerate EVERY road that reaches the merge
join and classify each in a table in your record:
- **MERGE DOORS** (the menu/context/palette merge, ⌘⇧M, the N-way chain, the bulk bars' two
  run options, the ceremony's per-pairing DEFAULT): the join becomes the RENDERING join —
  merged text = top + `"\n"` + bottom, byte-exact, no trimming, no conditionals. The page reads
  byte-identical before and after the merge.
- **DELETE KEYSTROKES** (the seam ⌦/backspace carves — #34's texted-seam merge — and the
  cross-block compound's mid-paragraph edge-join): a delete that kept the newline would visibly
  do NOTHING; these keep their SHIPPED join byte-unchanged. Pin that they still do.
- A road that fits neither class comes BACK to the orchestrator before you build it (in-batch
  design forks are the architect's to rule).

**The build.** The core join rule + the ceremony default + whatever each door needs so the
classification holds. The ceremony keeps space · nothing choosable per pairing. This is a RULED
BEHAVIOUR CHANGE, not a bug: pins asserting the space join are REWRITTEN to the ruling in the
same commit (no red-on-old owed); the delete-keystroke pins are guards and stay. Check the
ceremony sheets' drift checks still hold once plain merge and the ceremony default flip
together (restyle nothing there; never reorder the checks). The rule is CORE-side, so the phone
flips with the Mac wherever it calls the shared op (the U-2 keep-on-top precedent) — check for
mobile pins on the space join and rewrite them too; the iOS build must stay green.

**The canon delta rides YOUR build, exactly as ruled, never beyond:** AppSpec §9's merge
bullet — the 2026-07-06 space-join parenthetical superseded by R-13u4-3 (2026-09-20), citing
her words; state the new consequence honestly (a PARAGRAPH cut now round-trips divide-then-
merge byte-exactly; a mid-sentence cut comes back with a newline — the recorded trade, the
ceremony's space option the road back); OverallModel §7's merge line if and only if it names
the join. Touch nothing else in canon.

**Evidence:** the rewritten state-transition suite (merge · mergeCeremony · the chain · the
bulk roads · the delete-keystroke guards) + a hands-on WALK on the dev-store Debug build:
merge a two-paragraph pair by a door — the page reads byte-identical; a three-block bulk run;
the ceremony's default pairing shows newline with space still choosable; a seam backspace
still joins exactly as shipped. Captures to `notes/plans/13u4-screens/e3/`. Core `swift test`
for the Operations diff + the Mac suites your diff touches + the acceptance spine
(`TutorialWalkTests` — run under its REAL TYPE NAMES; the file-name `-only-testing` trap is
recorded in both prior unit records) at the unit's end. iOS build green.

**Your record:** append a `## UNIT E3 RECORD` section to THIS file with LIVE STATUS from the
FIRST commit (PENDING marks on unverified claims), the classification table, and the seam-file
list (if your diff reaches `BlockRangeIndex`/`EditorTextView`'s seam roads, say so — the
ladder's Fable reviewer reads it); flip the ledger's E3 row in your closing commit. The
checkpoint protocol in CAST & DISCIPLINE binds you from the first commit.

## UNIT E3 RECORD — MERGE KEEPS THE NEWLINES (item 8, R-13u4-3)

**WHAT THIS UNIT DID NOT DO (the record's first line):** *(filled at close — PENDING while the
unit runs)*. Nothing outside the merge join: no other unit's work (E1's Return chain, E2's ⌥⌫
question, the restyle spine), no `Sync/`, no schema, no migration.

### LIVE STATUS (flipped in the same commit as each piece; unverified claims say PENDING)

| # | Piece | Status |
|---|---|---|
| 1 | The record + the READING + the DOORS-vs-DELETES enumeration (every road traced, not assumed) | DONE (7b60f043 + this commit) — the table below |
| 2 | The core rule (`MergeJoinRule` + `Operations.merge`) + the core pins rewritten to the ruling + the canon delta | DONE (this commit) — core **1609/174 green**, below |
| 3 | The Mac consumers (the seam differential, the carry-all/ceremony defaults, the two DELETE roads' guards) + the Mac pins | DONE (this commit) — the merge family **140/14 green**, below |
| 3b | The two tutorials' merge sentence (my change falsified it) + their pins | DONE (this commit) |
| 4 | The phone's door (core-side flip) + the mobile pins + the iOS build | DONE (this commit) — the four mobile suites **50/4 green** (2 pre-existing known issues); the standalone iOS build line is PENDING until the closing runs |
| 5 | The walk on the dev-store Debug build, captured | NOT-STARTED |
| 6 | Closing suites + the ledger's E3 row | NOT-STARTED |

### THE CLASSIFICATION — EVERY ROAD THAT REACHES THE MERGE JOIN

*(the architect's application note, built to. Every row was traced by reading the road end to end —
door → view model → controller → the op — never inferred from a name. `grep -rn "MergeJoin"` +
`grep -rn "\.merge(\|mergeCeremony\|mergeChain\|mergeSelected\|mergePicked"` over `Sources/` and
`App/` are the enumeration's two sweeps; every hit is in this table.)*

| # | Road (the door she touches) | Reaches the join via | CLASS | What it does after E3 |
|---|---|---|---|---|
| 1 | Write's block ▾ **Merge** / **⌘⇧M** / context menu / ⌘K palette, unfanned pair | `EditorViewModel.mergeBlocks` → `StructuralGesturePlanner.plan(.mergeBlocks)` → `.merge` → `runInstantMerge` → `ops.merge` | **DOOR** | `top + "\n" + bottom` |
| 2 | The same door on a **fanned** pair (J4b's carry-all) | → `runCarryAllMerge` → `CarryAllMerge.compose` → `ops.mergeCeremony` (one pairing + carries) | **DOOR** | the pairing's default join is the door rule |
| 3 | The same door over a **run of 3+** (the N-way chain) | → `.mergeChain` → `runMergeChain` → `MergeChainRun.run` → `ops.merge` per plain link, `ops.mergeCeremony` per carry-all link | **DOOR** | every seam in the run |
| 4 | **Merge choosing takes… / ⌥⌘⇧M** — the ceremony sheet's per-pairing default (and a ＋ placed by hand) | `openMergeCeremony` → `prePairing` / `pairMergeTakes` → `MergePairingDraft.join` → `ops.mergeCeremony` | **DOOR** | default newline; **space · nothing still choosable per pairing** (unchanged control, unchanged preview) |
| 5 | The ceremony sheet's **preset row** (Bring every take · Only the shown ones) at 2 blocks | `confirmMergeCeremony` → `runCarryAllMerge` / `runInstantMerge` | **DOOR** | as rows 1–2 |
| 6 | The **run choice sheet** (U-16, 3+ blocks: Bring every take · Only the shown ones) | `openMergeRunChoice` → `runMergeChain(bringEveryTake:)` | **DOOR** | as row 3 |
| 7 | The **Takes board's** ⌘-click bulk bar | `TakesStructureController.mergeSelectedBlocks` → `MergeChainRun.run` | **DOOR** | as row 3 (one shared body) |
| 8 | The **Blocks workbench's** bulk bar | `BlockTOCView.mergePicked` → `MergeChainRun.run` | **DOOR** | as row 3 (one shared body) |
| 9 | The **phone's** ⋯ **Merge with Previous** | `MobileStructural.mergeWithPrevious` → `ops.merge` / `ops.mergeCeremony` | **DOOR** | flips with the Mac (the rule is core-side — the U-2 keep-on-top precedent) |
| 10 | **Make Block across blocks** (⌘⇧K over a span that crosses seams) | `confirmCrossBlockMakeBlock` → divides at the edges, then `ops.merge` per piece | **DOOR** — *see the note below; this road is NOT in the brief's enumeration and the classification is mine* | the span becomes one block reading byte-identical to what she selected |
| 11 | **The seam carve** — ⌫ at a block's start / ⌦ at the previous block's end / deleting the separator (#34's texted-seam merge) | `planSeamMerge` → `runSeamMerge` → `runInstantMerge(joining: .deleteKeystroke)` → `ops.merge` | **DELETE** | **byte-unchanged**: the shipped space-unless-edged join |
| 12 | **The cross-block compound's edge-join** — a delete/replace whose span crosses seams and joins the surviving ends | `CrossBlockCompound.apply` → `ops.merge(joining: .deleteKeystroke)` → `ops.autosave` overwrites with `leading.newText + trailing.newText` | **DELETE** | **byte-unchanged** — and doubly so: the join character never survives the compound's own autosave (pinned) |

**Row 10, said out loud, because the brief's enumeration did not name it.** Make Block across
blocks is a deliberate gesture behind a confirm — never a keystroke that deletes something — and
its whole promise is that the span she selected becomes one block. Her ruling's own sentence is
literally about that shape: *"it should just make all newlines within the selected portion part of
a single block."* Under the old join a span crossing two paragraphs came back with the paragraph
break replaced by a space; under the door rule it is byte-identical to what she selected. So it
fits the DOORS class on the ruling's own words rather than fitting neither — which is why it was
built rather than returned to the orchestrator. **Reversible in one argument** (`joining:
.deleteKeystroke` at `confirmCrossBlockMakeBlock`'s loop) if the architect reads it the other way.

**Roads that touch the join brain but mint no text** (checked, listed so the sweep is complete):
the ceremony sheet's per-pairing **picker** and **preview** (`MergeCeremonySheet`) read
`MergeJoin` and are unchanged — the preview joins through the same brain the op uses, so it
cannot lie by a byte; `AppSession.mergeJoinMemory` (ruling 3's remembered choice) is unchanged and
still outranks the default when set; `MergeArrangementCopy.sentence` speaks the join's WORD and
already had "join on a new line".

**One consumer outside the doors, which had to move with the rule:**
`StructuralSeamEdit.derive`'s `.merge` arm decides the differential text edit by BYTE EQUALITY
against the candidate joins (it knew `" "` and `""` only). Left alone, every door merge would have
failed its byte check and fallen back to a full re-render — the ruling would have worked and
silently cost P1. It now tries every `MergeJoin` case, and for the door join the replacement is
the separator that is already there (a zero-byte text edit carrying only the identity run) — which
is the mechanism by which "the page reads byte-identical" is literally true on screen.
