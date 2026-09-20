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
| E1 | Empty blocks chain (item 3, R-13u4-2) | `TypedReturn`'s empty-block arm → the chain; canon delta rides the build | pins + walk | NOT-STARTED |
| E2 | ⌘⌫ checkbox-seam defect (item 11) | trace the mechanism first; red-on-old owed | red-on-old + walk on her verbatim repro | NOT-STARTED |
| E3 | Merge keeps the newlines (item 8, R-13u4-3) | the rendering join, every door; ceremony default; canon delta rides | state-transition suite + walk | NOT-STARTED |
| C1 | Capture microsyntax (item 2, R-13u4-1) | shared rule + both Mac doors; `applyTypedPath` hoist; phone face → parity row | pins + capture walk | NOT-STARTED |
| C2 | Selection → take (item 9, R-13u4-4) | the MOVE op + Write door; insurance savepoint load-bearing | state-transition + walk | NOT-STARTED |
| F1 | Index chapter-click lands low (item 10) | trace first — the un-adopted `LandingAuthority` is the recorded hypothesis | red-on-old if confirmed + walk | NOT-STARTED |
| S1 | The Settings shape (items 4/5/6/7 + row 59 + the 2a Settings fork) | tabs · search · fold fix · card grammar · ⌘[/unindent audit · merge-shortcut face; then walk row 53's two re-font occasions once reachable | walk both voices + appearances, captured | NOT-STARTED |
| S2 | Library & masthead faces (item 1 + rows 50/51/54) | click-to-cycle stamp + word-counter condense (word-target offer preserved) · `FlippingStamp` hoist + oracle edges · F-0 residue · Timeline voice | walk, captured | NOT-STARTED |
| S3 | Chrome singles + the conformance sweep (rows 44/45/46/63/67/68/69 + the Trash fork) | 27-site sweep + grep pin · tag sheet voiced · indicator ring · Restore Tutorial confirm · "pools" lesson sweep (re-seed consequence recorded) · seal-blind rename field · `blockNamingDoor` hygiene · Trash cards · closing conformance walk against the reference artifact | walk, captured | NOT-STARTED |

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
