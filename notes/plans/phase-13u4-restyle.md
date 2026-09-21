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
| E3 | Merge keeps the newlines (item 8, R-13u4-3) | the rendering join, every door; ceremony default; canon delta rides | state-transition suite + walk | **DONE** — `MergeJoinRule` makes the DOORS-vs-DELETES classification structural (12 door roads flipped, the 2 delete roads byte-unchanged with guard pins); the differential seam arm had to learn the new join or every merge would have cost a full re-render; ~30 door pins rewritten to the ruling across 12 suites + 3 the ruling earns; both tutorials' falsified sentence fixed with their pins; canon delta in AppSpec §9 + OverallModel §7. Walked in both voices AND both appearances — a door merge moves not one byte of the page, the next seam's backspace still collapses to a space. Core 1609/174 · Mac 373/39 · mobile 71/6 · iOS green. Record below |
| C1 | Capture microsyntax (item 2, R-13u4-1) | shared rule + both Mac doors; `applyTypedPath` hoist; phone face → parity row | pins + capture walk | **DONE** — ONE pure `Shared/CaptureMicrosyntax.parse` on the `PlainPaste` pattern, run at the HAND-OFF only, on BOTH Mac doors; the `applyTypedPath` HOIST landed with it (`Shared/TypedTagPath`, four consumers, every pre-move name forwarded, **zero test edits on both platforms** — the KnownIssues row's `applyTypedPath` entry is DISCHARGED). **The walk caught what no pin could**: the capture boxes substitute typed quotes, so a hand-typed `{t:"…"}` arrived CURLY and silently filed as text — measured by hexdump, fixed in the brain, re-walked. ZERO routing machinery (the smart-book pin asserts the note joined with no `reading_post` row). Mac **191/31** · mobile **40/3** · iOS green · 34 captures. PROVISIONALs: **QUESTIONS #127** (a)–(g). Record below |
| C2 | Selection → take (item 9, R-13u4-4) | the MOVE op + Write door; insurance savepoint load-bearing | state-transition + walk | **DONE** — ONE core op (`moveSpanToNewTake`) in the ruled shape: the insurance savepoint · the span leaving EXACTLY as selected · a take at the fan's END branched-not-chosen · ONE undo entry with the exact-row redo, both halves one transaction each. The Write door is registry-declared and rendered ONLY for a single-block selection (P-2, pinned both ways); no chord, the collision sweep recorded. The AppSpec §9 bullet rides the build. **The walk caught the dedupe branch in use** — a move whose take was already saved writes nothing and the receipt drops its saved-first clause, with the four quiet savepoints behind it proving the cover held. Core **1631/175** · Mac **336/38** · iOS green · 24 captures. PROVISIONALs: **QUESTIONS #128** (a)–(e). Record below |
| F1 | Index chapter-click lands low (item 10) | trace first — the un-adopted `LandingAuthority` is the recorded hypothesis | red-on-old if confirmed + walk | **DONE — THE DEFECT IS REAL, THE HYPOTHESIS CONFIRMED BY MEASUREMENT, THE ADOPTION SHIPPED, AND ONE RESIDUAL STOP-AND-REPORTED.** Reproduced first: **11 misses in 20 chapter clicks** on Sherlock and the field guide (five landing in a DIFFERENT story, one on a blank page, none self-correcting in 6 s); the trace found the book Index had never adopted `Surface/LandingAuthority` (13u2b's own *"at their next touch"*) and a six-aim hand experiment proved a watched landing converges. Shipped: the adoption, with a `LandingPolicy.bookIndex` whose every number was measured (two earlier policies retired by measurement — 12 blind hops FLING the page 45k → 95k). Red-on-old **behavioural-revert verified** in a worktree: the reverted tree misses 3 of 4 gestures and both pins are red (8667 pt · 4077 pt · the block never reported) where this tree lands them at 0.04 and 0.24. Walked in both voices AND both appearances: a chapter click lands the heading at the top and HOLDS it (captured at 1.5 s and 6 s). **Row 56 adjudicated by the paired interleaved protocol** (6 runs, RED on both trees, byte-identical) and the row-49 Outline arm too (green on both, isolated and under load). **THE RESIDUAL, reported rather than smoothed over:** a COLD column still climbing can defeat any compensator (its height oscillates 39k → 143k → 80k pt in six seconds; 2 of 5 cold first deep clicks stall, `end=gaveup` in the signpost) — the remedy is 13u2b UNIT 1's manifest half on this surface, which this brief's stop rule makes the architect's. KnownIssues row opened; QUESTIONS **#129**. Record below |
| S1 | The Settings shape (items 4/5/6/7 + row 59 + the 2a Settings fork) | tabs · search · fold fix · card grammar · ⌘[/unindent audit · merge-shortcut face; then walk row 53's two re-font occasions once reachable | walk both voices + appearances, captured | NOT-STARTED |
| S2 | Library & masthead faces (item 1 + rows 50/51/54) | click-to-cycle stamp + word-counter condense (word-target offer preserved) · `FlippingStamp` hoist + oracle edges · F-0 residue · Timeline voice | walk, captured | NOT-STARTED |
| S3 | Chrome singles + the conformance sweep (rows 44/45/46/63/67/68/69 + the Trash fork) | 27-site sweep + grep pin · tag sheet voiced · indicator ring · Restore Tutorial confirm · "pools" lesson sweep (re-seed consequence recorded) · seal-blind rename field · `blockNamingDoor` hygiene · Trash cards · closing conformance walk against the reference artifact | walk, captured | NOT-STARTED |

**CARRIED TO CLOSEOUT (grows as units close; nothing here may be lost):** MOBILE PARITY rows —
(1) the phone's empty-block Return should CHAIN too (E1's report: AppSpec §7 still says the
phone's Return model is unchanged; no mobile code consults `TypedReturn.act`); (2) the phone's
capture-microsyntax face (R-13u4-1) — **FILED BY C1**: the RULE is shared and already compiles
into the iOS target (`Shared/CaptureMicrosyntax`), so the phone owes only the two lines at its own
capture hand-off (`MobileQuickNoteModel` / the phone's shelf capture): parse at the filing act,
mint with the cleaned text + the token's title, then `CaptureMicrosyntax.applyTags(…, wording:
MobileTagsModel.refusal)` and speak the refusals in the phone's own seam. The curly-quote
tolerance the Mac walk earned is in the shared brain, so iOS's own substitution needs nothing
extra. *(C1 also hoisted `applyTypedPath` into `Shared/`, which the phone now consumes — the
KnownIssues forked-brains row records the discharge.)* *(E3 owes NO parity row — the merge
join is core-side, so the phone flipped with the Mac; its tutorial copy moved in the same commit.)*
**OPEN PRODUCT CALLS** — (1) **QUESTIONS #126**
(E2): should ⌥⌫ stop at a line break, and at a block seam? Her report's real chord; nothing was
implemented, by the brief's stop rule. **CLOSEOUT DUTIES from E3** — (a) AppSpec §14's phase delta
(the unit landed §9 + OverallModel §7 only); (b) the tutorial RE-SEED consequence: her seeded
field guide keeps the old merge sentence until Restore Tutorial; (c) tell her, if she cares, the
export consequence: a merged block's internal newline exports as one newline inside a paragraph
where the two blocks exported as a blank line; (d) **the one architect call E3 made rather than
stopping for**: Make Block across blocks is classified a DOOR (the row-10 note in the E3 record),
reversible in one argument. **CLOSEOUT DUTIES from C1** — (e) her ratify bundle gains
**QUESTIONS #127** (a)–(g), the capture microsyntax's seven calls; (f) a WALKER FACT for
`Tools/WalkKit/README.md` at its next touch: the capture boxes substitute typed quotes (U+201D),
so a quoted token read from a screenshot cannot be trusted — read the box's accessibility value
and `xxd` it; (g) nothing in `notes/KnownIssuesAndTechDebt.md` was opened by C1 — one row was
CLOSED (`applyTypedPath`). **CLOSEOUT DUTIES from C2** — (h) her ratify
bundle gains **QUESTIONS #128** (a)–(e), selection→take's five calls (next free: **#129**);
(i) a MOBILE PARITY CANDIDATE — the op is core-side and already compiles into the phone, so what
the phone owes is a DOOR, and its shape is downstream of #128(e) ("where does this act live
besides Write" is the same question on both platforms); (j) AppSpec §14's phase delta gains §9's
new `moveSpanToNewTake` bullet; (k) a WALKER FACT for `Tools/WalkKit/README.md`: a full-screen
`screencapture` is in screen pixels with NO window offset (point = px/2) while `walk-cap`'s window
capture needs the window's Y added back (point = px/2 + 33) — mixing the two puts a click a
bar-height off, silently; (l) nothing in `notes/KnownIssuesAndTechDebt.md` was opened or closed
by C2.

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

### THE BUILD (what moved, and why each line had to)

1. **`Sources/VariorumCore/Domain/MergeJoin.swift`** — `MergeJoin.canon(head:tail:)` is REPLACED by
   **`MergeJoinRule`**, one brain with two members (`.door` · `.deleteKeystroke`) and one resolver
   `join(head:tail:)`. The ruling is made STRUCTURAL rather than conditional: `.door` answers
   `.newline` for any texts, by ruling ("byte-exact, no trimming, no conditionals" — her words), and
   `.deleteKeystroke` holds the pre-ruling space-unless-edged rule VERBATIM. Replacing `canon`
   rather than re-pointing it means a grep for the old name proves no site kept the old rule (it
   returns only doc comments quoting the history).
2. **`Operations.merge(_:_:joining:)`** — the rule arrives as a parameter defaulting to `.door`, and
   is resolved INSIDE the transaction on the store's rendered texts, so no caller can decide the
   join from a projection that only ever lags the store (the R1-2 doctrine). `mergeCeremony` needed
   no change at all: its joins were already explicit per pairing.
3. **The door sites** (all now `MergeJoinRule.door.join(…)`): `CarryAllMerge.compose` (the carry-all
   pairing), `prePairing` + `pairMergeTakes` (the ceremony's default and a hand-placed ＋),
   `MergeCeremonyState.canonJoin` (the sheet's sentence — its former `.space` fallback collapsed
   away, since the rule answers the same for empty texts), `MergeArrangementCopy.sentence`'s default,
   and the phone's `MobileStructural.mergeWithPrevious` pairing.
4. **The delete sites** (`joining: .deleteKeystroke`): `runSeamMerge` → `runInstantMerge`, which
   gained the parameter so the two classes keep SHARING one body (two doors on one act share the
   body or they drift), and `CrossBlockCompound.apply`'s edge-join.
5. **`StructuralSeamEdit.derive`'s `.merge` arm** — the differential road, described above.
6. **The two tutorials' merge lesson** (and the phone's divide lesson) — my own change falsified
   their sentence; lesson and pin moved together, per the standing rule.
7. **The canon delta**: AppSpec §9's merge bullet (the full rule, her words, the DELETE exception,
   the honest new consequence) and OverallModel §7's merge line (one clause + a pointer).

### SEAM FILES THIS DIFF TOUCHES (the ladder's Fable reviewer reads this list)

- `App/Variorum/Shared/EditorBrain/CrossBlockCompound.swift` — **the editor seam's cross-block
  compound**: ONE argument at its `ops.merge` call (`joining: .deleteKeystroke`), plus the comment
  that says why. No road, no guard, no ordering changed.
- `App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift` — the merge roads only
  (`runInstantMerge` gains `joining:`; `runSeamMerge` passes `.deleteKeystroke`; three ceremony
  defaults move to the rule brain; one comment at the Make Block loop). `runStructural` itself,
  the caret arithmetic, the flush-first order, the fan threshold reads and the drift checks are
  untouched.
- `App/Variorum/Variorum/Features/Editor/StructuralSeamEdit.swift` — the `.merge` arm's join
  candidates (two strings → every `MergeJoin` case). The retained-byte checks, the
  `nonSeamAligned` guard and every other arm are untouched.

**NOT touched, deliberately:** `BlockRangeIndex` (no tiling or guard change — the seam pair the
keystroke plans is the same pair) · `TypedReturn` · `PaneTextAuthority` · `runStructural`'s
identity oracle · `MarkdownActs` · `Sources/VariorumCore/Sync/` · schema/migrations.

### JUDGMENT CALLS (each one a reviewer can reverse in a line)

1. **`MergeJoin.canon` was REPLACED, not re-pointed.** A resolver that ignores its inputs is the
   drift class this repo has retired twice by name; a rule ENUM says out loud that there are two
   classes and which one a call site is in. Cost of reversing: one static back on `MergeJoin`.
2. **Make Block across blocks was classified as a DOOR (row 10) rather than returned to the
   orchestrator.** The brief's stop rule is for a road that fits NEITHER class; this one fits the
   doors on her ruling's own sentence (a deliberate gesture behind a confirm; the span she selected
   becomes one block). Two pins now assert it. Reversing: `joining: .deleteKeystroke` at
   `confirmCrossBlockMakeBlock`'s merge loop, and those two pins back to the space join.
3. **The tutorial copy was fixed rather than deferred.** My own change made "a single space at the
   seam — divide a sentence and merge it back and you get exactly the sentence you started with"
   false on both platforms, and copy naming behaviour the app no longer has is the J8 defect class.
   **The re-seed consequence, recorded for the closeout:** an already-seeded tutorial (hers) keeps
   the OLD sentence until `Help ▸ Restore Tutorial…` re-seeds it.
4. **The cross-block compound passes the rule explicitly even though its join never survives.** The
   autosave one line later overwrites the merged buffer with the two cut ends concatenated, so the
   class is satisfied by outcome either way; stating it at the call keeps the classification
   readable instead of resting on that accident. Pinned both ways.
5. **`Queries.joinRenderedTexts`' doc comment was left alone.** It cites the 2026-07-06 merge join
   as the PRECEDENT its own `"\n\n"` export rule was shaped on — which remains true as history.
   The export projection's behaviour is ruled elsewhere (QUESTIONS #12) and is not this unit's.
   Worth knowing: a merged block's internal newline now exports as ONE newline inside a paragraph
   where two blocks exported as `"\n\n"` — the ruling's honest consequence, on the export side.
6. **The phone flipped with the Mac and no MOBILE PARITY row is owed for the RULE** (it is
   core-side — the U-2 keep-on-top precedent), though its tutorial copy and six pins moved here.

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

**WHAT THIS UNIT DID NOT DO (the record's first line):** it changed **nothing outside the merge
join and what the join's own words claim**. `Sources/VariorumCore/Sync/` · schema · migrations ·
`Server/` — **ZERO lines** (verified by name over the whole unit diff). No other unit's work was
touched (E1's Return chain, E2's ⌥⌫ product call, the restyle spine, the Settings shape). The
ceremony sheets were NOT restyled and **not one drift check moved or changed order** (the brief's
explicit fence — `refreshMergeSheetIfDrifted` / `refreshMergeRunIfDrifted` and their tests are
byte-untouched and green). The ceremony's per-pairing control still offers `space` · `newline` ·
`nothing` and its preview brain is unchanged. The DELETE roads' behaviour is byte-unchanged by
construction and by guard pin. `BlockRangeIndex`, `TypedReturn`, `PaneTextAuthority`,
`runStructural` and the editor's identity oracle were not touched at all. **No `QUESTIONS.md`
entry was opened** — R-13u4-3 settles the join, and the one classification call I had to make
(row 10 below) is an architect call recorded here with its one-line reversal, not a product
question for her.

### LIVE STATUS (flipped in the same commit as each piece; unverified claims say PENDING)

| # | Piece | Status |
|---|---|---|
| 1 | The record + the READING + the DOORS-vs-DELETES enumeration (every road traced, not assumed) | DONE (7b60f043 + 000ba056) — the table below |
| 2 | The core rule (`MergeJoinRule` + `Operations.merge`) + the core pins rewritten to the ruling + the canon delta | DONE (000ba056) — core **1609/174 green**, below |
| 3 | The Mac consumers (the seam differential, the carry-all/ceremony defaults, the two DELETE roads' guards) + the Mac pins | DONE (5fdd8703) — the merge family **140/14 green**, below |
| 3b | The two tutorials' merge sentence (my change falsified it) + their pins | DONE (a489a176) |
| 4 | The phone's door (core-side flip) + the mobile pins + the iOS build | DONE (a489a176) — the mobile suites green; the standalone iOS build gate ran at the close, **BUILD SUCCEEDED** |
| 4b | The FULL-suite sweep for stragglers (three found: two on the Make Block road — row 10 — and one door pin) | DONE (96f79045) — 2917/486 with 5 issues, of which 3 were these and 2 are row 58's ONE recorded environment red; the three now green in a 52/5 re-run |
| 5 | The walk on the dev-store Debug build, captured | DONE (8babfbc9) — 13 captures + 25 crops, both voices AND both appearances, the table below |
| 6 | Closing suites + the ledger's E3 row | DONE (1d8d4877 + this commit) — core **1609/174** · Mac **373/39** (incl. the acceptance spine's eleven types) · mobile **71/6** · iOS build green |

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

### EVIDENCE — THE WALK (the unit closes on USE, not on pins)

**Build:** `App/Variorum/DerivedData/13u4e3/Build/Products/Debug/Variorum.app`
(`io.lduarte.Variorum.debug`, the fenced dev store). `pgrep -fl 'Variorum.app/Contents/MacOS'`
was checked at the start (ZERO instances — hers was not running at any point), and each dev
instance was quit **by identity** (`tell application id "io.lduarte.Variorum.debug" to quit`),
never by a keystroke (the 13u3 breach's walker law); zero instances after each quit and at the
end. `/Applications/Variorum.app` was never touched. Captures:
`notes/plans/13u4-screens/e3/` (gitignored) with `e3/crops/` holding the read crops.

| # | Step | What the app did | Capture |
|---|---|---|---|
| 1 | A three-paragraph note staged through the shelf's quick-entry bar (⇧⏎ between paragraphs, ⏎ to file), seams on | three blocks — the bottom bar reads **block 1/3**, `2w block · 6w in note` | `01-before-three-blocks.png`, `crops/01-bar-1of3.png` |
| 2 | Caret at the END of paragraph one, **⌘⇧M** — the everyday merge DOOR | **THE RULING, IN USE: not one byte of the page moved.** The three lines read exactly as before; what changed is the editing ring, which now encloses lines 1 AND 2, and the bar — **block 1/2**, `4w block`. Under the old join the two lines would have collapsed onto one | `02-after-door-merge.png`, `crops/02-after-door-merge-PAGE-IDENTICAL.png`, `crops/02-bar-1of2.png` |
| 3 | Caret at the START of "Paragraph three.", **⌫** — the seam carve (#34), a DELETE | the two lines **joined onto ONE line with a space**: `Paragraph two. Paragraph three.` — the shipped join, byte-unchanged, and visibly different from the door one line above it. Receipt: *"Blocks joined — ⌥⌘Z undoes it."*, bar **block 1/1** | `03-after-seam-backspace.png`, `crops/03-seam-backspace-SPACE-JOIN.png`, `crops/03-bar-receipt.png` |
| 4 | ⌥⌘Z ×2 | back to **block 3/3**, *"Undid: Merge"* | `crops/04-bar.png` |
| 5 | ⌘A (all three blocks selected), **⌘⇧M** — the N-way chain over a RUN | ONE block (**block 1/1**), receipt *"Merged 3 blocks — ⌥⌘Z undoes it."*, and **every newline inside the run survived**: the page still reads three lines. Her sentence, literally — *"all newlines within the selected portion part of a single block"* | `06-after-three-block-chain.png`, `crops/06-chain-PAGE-IDENTICAL.png`, `crops/06-bar.png` |
| 6 | ⌥⌘Z; ⌘T on the last block (a take), caret at the seam, **⌥⌘⇧M** — *Merge choosing takes* | the sheet opens on **Bring every take** and its sentence reads **"The two takes you were looking at join on a new line."** | `09-merge-ceremony-sheet.png`, `crops/09-sentence-JOIN-ON-A-NEW-LINE.png` |
| 7 | **Pair by hand…** | the pairing row's three-way control shows **`new line` SELECTED**, with `space` and `nothing` beside it, and the preview below renders the joined take on TWO lines | `10-pair-by-hand.png`, `crops/10-pairing-NEWLINE-DEFAULT.png` |
| 8 | Click **`space`** | still choosable, as ruled: the preview collapses to one line, `Paragraph two. Paragraph three.` | `11-space-still-choosable.png`, `crops/11-pairing-SPACE-CHOSEN.png` |
| 9 | **STUDY voice** (Settings ▸ Appearance): the ceremony re-opened, then a door merge at the 1\|2 seam | the same sentence, the same byte-identical page in the second voice | `13-study-ceremony.png`, `crops/13-study-sentence-and-row.png`, `14-study-door-merge.png`, `crops/14-study-page-identical.png` |
| 10 | **DARK** (`appearanceChoice dark`, relaunch): the note re-opened, the ceremony re-opened, then the voice flipped back to Terminal | the merged block reads identically on the black room in BOTH voices; the ceremony's sentence is the ruled one there too | `16-dark-note.png`, `crops/16-dark-page.png`, `17-dark-ceremony.png`, `crops/17-dark-ceremony-sentence.png`, `crops/18-restored-terminal.png` |

**Dev-store state left as found:** voice back to **Terminal**, `appearanceChoice` back to **system**
(both verified after the fact), zero instances. The walk's note (`2026-09-20`, in no book) and one
mangled earlier draft are left in the dev store, as every walk's fixtures are.

**A walker fact for the next session (added to the pattern `Tools/WalkKit/README.md` records):**
`cliclick -w <ms> t:"…"` **drops characters in the shelf's quick-entry bar** (a string typed at
70 ms spacing lost the last one or two characters, repeatably), and `⌘A` does not select that
field's contents. `osascript -e 'tell application "System Events" to keystroke "…"'` typed every
string faithfully, and `key code 36 using shift down` is a reliable ⇧⏎ there — that is the road
for staging a multi-paragraph fixture. Every cliclick/keystroke burst must be preceded by an
explicit re-activation: a capture steals focus, and the keystrokes then go to the terminal host.

**One consumer outside the doors, which had to move with the rule:**
`StructuralSeamEdit.derive`'s `.merge` arm decides the differential text edit by BYTE EQUALITY
against the candidate joins (it knew `" "` and `""` only). Left alone, every door merge would have
failed its byte check and fallen back to a full re-render — the ruling would have worked and
silently cost P1. It now tries every `MergeJoin` case, and for the door join the replacement is
the separator that is already there (a zero-byte text edit carrying only the identity run) — which
is the mechanism by which "the page reads byte-identical" is literally true on screen.

### CLOSING RUNS (at the unit's END — never the full suite at the start)

| Run | Command | Result |
|---|---|---|
| **Core** — the Operations diff (`swift test`, the whole core package) | `swift test` from the repo root | **1609 tests in 174 suites passed** (exit 0). Baseline was 1604/174; +5 net from the ruling's new pins |
| **Mac** — every suite this diff touches, the merge/seam/structural neighbourhood, AND the acceptance spine under its ELEVEN REAL TYPE NAMES (the `-only-testing` file-name trap, met by both prior units) | `xcodebuild test -scheme Variorum -destination platform=macOS` with `-only-testing:` for `SeamMergeTests` · the four `SeamEdit*` suites · `StructuralRewriteDoorTests` · `MergeGestureTests` · `MakeBlockGestureTests` · `DivideExtractGestureTests` · `DivideWCeremonyTests` · `MergeArrangementTests` · `MergeCeremonySheetTests` · `FannedDefaultsTests` · `FannedDefaultsBoardTests` · `MergeSelectionTests` · `BlocksWorkbenchTests` · `CrossBlockCompoundTests` · `BoardMergeDiagnosisTests` · `BoundaryFluidityTests` · `PlannerMergeTests` · `EditorSeamCostTests` · `EditorWindowSmokeTests` · `GestureSoakTests` · `ConfirmationsSettingTests` · `BlockHistoryPaneTests` · `NoteTrayTests` · `TrashSurfaceTests` · `WholeBlockDeleteTests` + the eleven `Tutorial*` types | **373 tests in 39 suites passed** (exit 0, no skips) |
| **Mac, the whole suite** — run MID-UNIT as the straggler sweep (not at the start), recorded because it is the honest baseline statement | same, no `-only-testing` | **2917 tests in 486 suites, 5 issues**: three door pins this unit then rewrote (re-run green above) and **row 58's recorded environment red** (`theReadClickLandsInIndexAtThatBlock`, two issues in one test, the warm-DerivedData covariate; this diff does not touch the book Index) |
| **Mobile** — the merge-bearing simulator suites | `xcodebuild test -scheme VariorumMobile -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` with `-only-testing:` for `MobileStructuralTests` · `MobileTutorialStructureWalkTests` · `MobileCrossBlockEditTests` · `MobileBlockHistoryTests` · `MobileTutorialBookShapeTests` · `MobileWholeBlockDeleteTests` | **71 tests in 6 suites PASSED** (exit 0) with the **2 pre-existing known issues** (`theFannedDivideLessonLandsTheDuplicateShape`, the recorded 13u1-ladder row — untouched by this diff) |
| **iOS build gate** — `Shared/EditorBrain/` and `VariorumCore` both compile into the phone | `xcodebuild build -scheme VariorumMobile -destination generic/platform=iOS` | **BUILD SUCCEEDED** |

No full-suite run was made at this unit's START; the plan's closeout-refresh baselines stand as the
baseline (the standing rule).

### CARRIED TO THE PHASE CLOSEOUT (from this unit)

1. **AppSpec §14's phase delta** is the CLOSEOUT's to write (a unit edits the operative sections
   only — E1's precedent): this unit's canon deltas are §9's merge bullet and OverallModel §7's
   merge line, both citing R-13u4-3 (2026-09-20).
2. **The tutorial re-seed consequence** (judgment call 3): her already-seeded field guide keeps the
   old merge sentence until `Help ▸ Restore Tutorial…`.
3. **The export consequence** (judgment call 5), for her if she cares: a merged block's internal
   newline exports as one newline inside a paragraph, where the two blocks exported as `"\n\n"`.
4. **A walker fact** for `Tools/WalkKit/README.md` at the next touch: `cliclick t:` drops
   characters in the shelf's quick-entry bar and `⌘A` does not select there; System Events
   `keystroke` + `key code 36 using shift down` is the reliable staging road, and every burst needs
   an explicit re-activation first.

### WHAT A FRESH SESSION WOULD NEED TO FINISH THIS

Nothing. Everything is committed and pushed: the core rule (`MergeJoinRule`, `Operations.merge`),
the consumers (the differential seam arm, the carry-all and ceremony defaults, the phone's door),
the two DELETE roads' explicit class + guard pins, the rewritten door pins across 12 suites, both
tutorials' copy and their pins, the canon delta, the walk captures (gitignored, listed above), and
this record.

---

**ORCHESTRATOR ADJUDICATION (2026-09-20, post-E3):** E3's Make Block-across-blocks
classification (a DOOR) is **SUSTAINED** — ⌘⇧K over a span is the most literal referent of her
item-8 sentence (*"make all newlines within the selected portion part of a single block"*), and
a deliberate gesture behind a confirm is a door, not a delete. It remains flagged in the
CARRIED block for her, reversible in one argument (`joining: .deleteKeystroke` + two pins).

## UNIT C1 BRIEF — THE CAPTURE MICROSYNTAX (item 2, R-13u4-1; self-contained — read in this order)

**Read first, in full:** (1) this file's Status banner · HER ADDITIONS item 2 (her verbatim
words) · THE SIZING-AND-RULINGS SITTING RECORD (**R-13u4-1 is yours and BINDING**: `{#tag/path}`
applies the tag and STANDING smart-book rules do the rest — no routing machinery, no journal
special case; `{t:"my title"}` sets the title; ONLY the braced forms parse, a bare #hashtag is
never touched, malformed braces pass through as typed text; tokens DISAPPEAR once parsed) ·
THE LEDGER · ENVIRONMENT TRAPS · CAST & DISCIPLINE · the prior UNIT RECORDs (E3's walker fact:
`cliclick t:` drops characters in the shelf's quick-entry bar — use the osascript keystroke
road with re-activation per burst). (2) **QUESTIONS #120** (the Mac's two capture boxes answer
ONE rule — ⏎ files · ⇧⏎ adds a paragraph · the hand-off segments via `importPost`; your parse
composes with that shape, never changes it) and the KnownIssues forked-brains row's
`applyTypedPath` entry (the hoist rule: move to `Shared/`, zero test edits, the 3C parity
pattern — pre-move names forwarded). (3) The code: both Mac capture doors (the shelf
quick-entry bar · the quick-note pad incl. the system-wide hotkey) and their filing road ·
`App/Variorum/Shared/PlainPaste.swift` (the pattern your brain follows: ONE pure function in
`Shared/`, pinned on the Mac, compiled into the iOS target) · `TagAssignmentViewModel.applyTypedPath`
(the brain you HOIST — its validation, hierarchy-depth and refusal rules are the standing tag
law your applications ride) · `importPost`. Do your own reading.

**The build.**
- **ONE pure shared brain** (`Shared/CaptureMicrosyntax.swift` or similar): parse(text) →
  (cleanText, tagPaths, title). Tokens stripped wherever they appear in the capture; every
  `{#…}` applies (several are legal); the FIRST `{t:"…"}` wins (later ones: your call, recorded
  as PROVISIONAL); malformed braces are TEXT and pass through byte-intact; a capture that is
  ONLY tokens still files whatever cleanText remains (even empty → the doors' standing
  empty-capture behaviour, unchanged).
- **Parse at the HAND-OFF (the filing act), never live while typing** — her words were about
  the note once made; the box's text stays exactly what she typed until ⏎ files it.
- **Application AFTER the mint, through the standing ops:** the tag applications ride the
  HOISTED `applyTypedPath` brain (its creation/validation/refusal rules unchanged); the title
  lands through the standing title road. **Filing never blocks on a token:** a tag that fails
  validation must not lose the capture — the note files, the failure speaks on the status seam
  (the `shelveInDailyJournalBook` posture: never throw, report what happened; 18i's kind
  grammar — a receipt for what landed, a refusal only from a door that did nothing).
- **The hoist:** `applyTypedPath` moves to `Shared/` on the 3C parity pattern — every pre-move
  name forwarded, ZERO test edits on both platforms (the zero-test-edit run IS the proof).
  Update the KnownIssues forked-brains row's remaining-list in the same commit.
- **NO routing machinery:** do not touch `shelveInDailyJournalBook`, smart-book assembly, or
  any membership code — smart books pick the note up because a tag applied, full stop.
- The phone's face is NOT yours (the parity row is already carried); but the brain must compile
  into the iOS target (the `PlainPaste` precedent — the build gate proves it).

**Evidence:** the brain's arm pins (each R-13u4-1 clause: braced-only · bare-hashtag-never ·
malformed-pass-through · disappear · multi-tag · title) + the hand-off integration pins on BOTH
Mac doors + the hoist's zero-test-edit proof + a hands-on WALK on the dev-store Debug build:
stage a smart book keyed on a tag, type a capture with `{#that-tag}` and `{t:"…"}` into EACH
door — the note lands titled, tagged, tokens gone, and appears in the smart book by the
standing rules; a malformed brace files as text. Captures to `notes/plans/13u4-screens/c1/`.
Suites your diff touches + the acceptance spine (REAL TYPE NAMES) at the unit's end; iOS build
green. PROVISIONALs to `notes/QUESTIONS.md` from **#127**.

**Your record:** append a `## UNIT C1 RECORD` section to THIS file with LIVE STATUS from the
FIRST commit (PENDING marks), the parse rule's edge table, the hoist's zero-test-edit evidence,
and the seam-file list (expected: NONE — say so explicitly); flip the ledger's C1 row in your
closing commit. The checkpoint protocol in CAST & DISCIPLINE binds you from the first commit.

---

## UNIT C1 RECORD — THE CAPTURE MICROSYNTAX (item 2, R-13u4-1)

**WHAT THIS UNIT DID NOT DO (the record's first line):** it wrote **NO ROUTING MACHINERY OF ANY
KIND** — `shelveInDailyJournalBook`, smart-book assembly and every membership road are untouched
by name; a smart book picks the note up because a tag applied, full stop, and the pin
`aSmartBookKeyedOnTheTagCollectsTheNoteByTheStandingRules` says so in behaviour by asserting the
note joined its book with ZERO `reading_post` rows. **`Sources/` — ZERO FILES**
(verified over the whole unit diff), so core, `Sync/`, schema, migrations and `Server/` are
untouched by construction and no core run was owed. **No editor-seam file** (the seam list below
is empty, deliberately said out loud). No other unit's work (E1's Return chain, E2's ⌥⌫ product
call, E3's merge join, the restyle spine) was touched, and no canonical doc was edited — R-13u4-1
adds a capture FACE, not a rule AppSpec states, and inventing a canon sentence for it would be
the author's call, not mine. The phone's FACE is not this unit's (the parity row is filed at the
phase closeout, with the two lines it owes named); what the phone gets here is the HOISTED brain
underneath its existing face, behaviour-identical and pinned so.

### LIVE STATUS (flipped in the same commit as each piece; unverified claims say PENDING)

| # | Piece | Status |
|---|---|---|
| 1 | The record + the READING (the brief's three reading lists, in order) | DONE (163ec318) |
| 2 | The two shared brains — `Shared/CaptureMicrosyntax.swift` (the parse) + `Shared/TypedTagPath.swift` (the hoist's new home) — and the parse's arm pins, one per R-13u4-1 clause | DONE (72caf8ac) — **17 tests in 1 suite passed** |
| 3 | The `applyTypedPath` HOIST to `Shared/` (the 3C parity pattern — zero test edits, both platforms) + the KnownIssues row | DONE (53c77ec2) — Mac **46/8**, mobile **6/2**, zero test files touched |
| 4 | The hand-off on BOTH Mac capture doors + the integration pins | DONE (fb10af91) — **42 tests in 4 suites passed** (the 25 new door pins + `QuickEntryBarTests` and `QuickNoteMintTests` riding UNMODIFIED) |
| 4b | **THE WALK'S FIRST FINDING, fixed before the walk finished** — the capture boxes substitute typed quotes, so a hand-typed `{t:"…"}` arrived CURLY and never parsed | DONE (d30c4fb0) — measured by hexdump, `isQuote` accepts `"` · `“` · `”`, **31 tests in 2 suites** green |
| 5 | QUESTIONS #127 (the PROVISIONALs — seven lettered calls) | DONE (8582f628) |
| 6 | The walk on the dev-store Debug build, captured | DONE (8fc45f7e) — 34 captures + 23 crops, BOTH doors, both voices and both appearances, the table below |
| 7 | Closing suites + iOS build + the ledger's C1 row | DONE (this commit) — Mac **191/31** · mobile **40/3** · iOS **BUILD SUCCEEDED** · core not owed (zero `Sources/` files) |

### THE PARSE RULE'S EDGE TABLE

*(The rule is `CaptureMicrosyntax.parse` — ONE pure function in `Shared/`, on the `PlainPaste`
pattern, compiled into both targets. Every row below is a pin in `CaptureMicrosyntaxTests`. The
ruled clauses are marked **R**; the rest are the build's calls and are PROVISIONAL in
QUESTIONS #127 under the letters given.)*

| # | Input | Text filed | Tags | Title | Why |
|---|---|---|---|---|---|
| **R** | `Had a weird dream about the ocean {#dream}` | `Had a weird dream about the ocean` | `dream` | — | her own example; the token disappears |
| **R** | `{t:"Ocean dream"} Had a weird dream` | `Had a weird dream` | — | `Ocean dream` | the title form |
| **R** | `#dream about the ocean` | byte-identical | — | — | a BARE hashtag is never touched |
| **R** | `{#dream} again {#sea} {#journal}` | `again` | `dream`,`sea`,`journal` | — | several are legal; every one applies, in order |
| **R** | `leg day {#health/workout}` | `leg day` | `health/workout` | — | a token is a typed PATH — it rides the hoisted brain |
| **R** | `{#}` · `{#dream` · `{ #dream}` · `{t:my title}` · `{t:""}` · `{t:"unterminated}` · `{tag:"x"}` · `a { b } c` · `{#dream⏎and more}` | byte-identical | — | — | malformed braces pass through as typed text (a token lives on ONE line and its value must be non-empty) |
| (a) | `{t:"First"} words {t:"Second"}` | `words` | — | `First` | the FIRST title wins; the later one is still a token and still disappears |
| (b) | `{T:"Ocean dream"} the sea` | `the sea` | — | `Ocean dream` | the `t` is read case-insensitively — iOS capitalizes the first letter of a capture, and this is her phone-first ask |
| (b) | `{t:"she said "hi""} and left` | `and left` | — | `she said "hi"` | the scan runs to the first `"}`, so a title may carry quotes |
| (c) | `Had a dream {#dream}` · `{#dream} Had a dream` · `Had {#dream} a dream` | `Had a dream` (all three) | `dream` | — | a token takes its SEAM whitespace with it — the space before it, or the space after it when it opens the line |
| (c) | `   {#dream} indented` | `   indented` | `dream` | — | her own indentation is not a seam |
| (c) | `{t:"Ocean dream"}⏎Had a weird dream.⏎⏎It was blue.` | `Had a weird dream.⏎⏎It was blue.` | — | `Ocean dream` | a line that held nothing but tokens goes with them, newline included — otherwise `bulkSegments` stores the blank line as content and every capture titled this way opens with a blank paragraph |
| (c) | `One.⏎⏎{#dream} Two.` | `One.⏎⏎Two.` | `dream` | — | a blank line SHE typed is not a token line and never moves |
| (d) | `{#a{#b}` | `{#a` | `b` | — | a malformed opener resumes the scan one character on: the malformed half stays hers byte-for-byte and the good token inside it still parses |
| (f) | `{t:"Title"} {#dream}` | *(empty)* | `dream` | `Title` | a capture of nothing but tokens leaves nothing to file — the doors take their standing empty-capture branch |
| — | `words {#///}` | `words` | `///` | — | a well-formed token whose value is all separators parses and then names NO tag — the one shape that reaches `applyTags`' `nothingTyped` arm (pinned so the arm is known reachable, not defensive) |
| — | any text with no `{` | byte-identical (fast path) | — | — | the capture is hers and the app does not tidy it (`PlainPaste`'s doctrine, one door over) |

### THE HOIST'S ZERO-TEST-EDIT EVIDENCE

**What moved.** `TagAssignmentViewModel.applyTypedPath`'s walk — the segment split, the
deepest-existing-prefix plan, and the creates + the apply inside ONE serialized runner turn with
`alreadyTagged` swallowed — is now `App/Variorum/Shared/TypedTagPath.swift`, once, for both apps.
It was the FIRST of the original six forked brains (the C3 ladder's list), mirrored onto the
phone at the parity round and split there into pure halves; the KnownIssues row's own touch rule
(*"any Mac phase touching one of these brains hoists it THEN"*) fired on this unit, because a
`{#tag}` token IS a typed path and its application had to ride that brain.

**The four consumers after the hoist** — one brain, four doors:

| Consumer | Before | After |
|---|---|---|
| `TagAssignmentViewModel.applyTypedPath` (Mac: the tag sheet, the masthead `#` door, the Library and Pool rows' chip adders) | the whole walk, inline | `TypedTagPath.apply` + this face's own two lines (`load()`, `TagsViewModel.message`) |
| `MobileNoteTagsModel.applyTypedPath` (phone: the note-tags sheet) | the walk, re-composed from `MobileTagsModel`'s pure halves | `TypedTagPath.apply` + `refresh()` + `MobileTagsModel.refusal` |
| `MobileTagsModel.createTypedPath` (phone: the manager's "+ new tag") | its own composition over those halves | unchanged body over the FORWARDED halves (its duplicate-path refusal is its own, deliberately — see the judgment calls) |
| The two Mac capture doors (`{#tag}`) | did not exist | `CaptureMicrosyntax.applyTags` → `TypedTagPath.apply`, one token at a time |

**Every pre-move name is forwarded**, which is what makes the proof possible:
`MobileTagsModel.typedSegments` · `.emptyTypedPathMessage` · `.TypedPathPlan` (a typealias) ·
`.typedPathPlan` · `.createMissing` all still answer, to the shared brain.

**THE PROOF — zero test edits on BOTH platforms** (`git status` over the hoist commit shows three
source files and NOT ONE test file):

| Run | Command (from `App/Variorum/`) | Result |
|---|---|---|
| Mac, every tag-touching suite, all UNMODIFIED | `-only-testing:` `TagAndFolderTests` · `FreeTypedTagTests` · `LibraryTagFaceTests` · `NoteTagDeclarationTests` · `NodSetTests` · `MastheadTagDoorTests` · `TagChipFitTests` (+ the new `CaptureMicrosyntaxTests`) | **46 tests in 8 suites passed** |
| Phone, both tag suites, UNMODIFIED | `-only-testing:VariorumMobileTests/MobileTagManagerTests -only-testing:VariorumMobileTests/MobileNoteTagsTests` | **6 tests in 2 suites passed** |

What deliberately did NOT move: the REFUSAL COPY (`TagsViewModel.message` on the Mac,
`MobileTagsModel.refusal` on the phone). It is its own line in the original six, and MobileSoul
§4.4 read from the other side says why — a shared home must not hold words that name a platform's
own doors. `TypedTagPath.Outcome` therefore carries the ERROR out and each face words it.

### SEAM FILES THIS DIFF TOUCHES (the ladder's Fable reviewer reads this list)

**NONE — said explicitly, as the brief asks.** `BlockRangeIndex`, `EditorTextView`,
`TypedReturn`, `PaneTextAuthority`, `EditorViewModel`, `EditorSurfaceController`, `runStructural`
and its identity oracle, `StructuralSeamEdit`, `MarkdownActs` — not one of them is in the diff.
Neither is `Sources/VariorumCore/` (zero files), so `Sync/`, the schema, the migrations and
`Server/` are untouched by construction. **The whole unit is seven source files**: two new shared
brains, the three faces that consume them (`TagsViewModel`, `QuickEntryBar`, `QuickNoteView`),
and the two phone models the hoist re-pointed (`MobileTagManager`, `MobileNoteTags`) — plus two
new test files and three notes files.

### CLOSING RUNS (at the unit's END — never the full suite at the start)

| Run | Command (from `App/Variorum/`) | Result |
|---|---|---|
| **Mac** — the two new suites, every suite the two capture doors own, every tag-touching suite the hoist passes under, AND the acceptance spine under its ELEVEN REAL TYPE NAMES (the `-only-testing` file-name trap, met by all three prior units) | `xcodebuild test -scheme Variorum -destination platform=macOS` with `-only-testing:` for `CaptureMicrosyntaxTests` · `CaptureMicrosyntaxDoorTests` · `QuickEntryBarTests` · `QuickNoteMintTests` · `QuickNoteDoorTests` · `QuickNoteWindowTests` · `QuickNoteWordTests` · `CaptureKeysTests` · `CaptureTextViewKeyTests` · `CaptureHandOffTests` · `TitleSuggestionChipTests` · `ShelfModelTests` · `PromoteAndPaletteTests` · `TagAndFolderTests` · `FreeTypedTagTests` · `LibraryTagFaceTests` · `NoteTagDeclarationTests` · `NodSetTests` · `MastheadTagDoorTests` · `TagChipFitTests` + the eleven `Tutorial*` types | **191 tests in 31 suites passed** (exit 0, no skips) |
| **Mobile** — the two tag suites the hoist re-pointed, plus the phone's own capture suite, ALL UNMODIFIED | `xcodebuild test -scheme VariorumMobile -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` with `-only-testing:` for `MobileTagManagerTests` · `MobileNoteTagsTests` · `MobileQuickNoteTests` | **40 tests in 3 suites passed** (exit 0) |
| **iOS build gate** — the two new `Shared/` brains must compile into the phone (the `PlainPaste` precedent) | `xcodebuild build -scheme VariorumMobile -destination generic/platform=iOS` | **BUILD SUCCEEDED** |
| **Core** — NOT RUN, and owed nothing: `git diff --name-only` over the whole unit lists **zero files under `Sources/`** | — | n/a |

No full-suite run was made at this unit's start; the plan's closeout-refresh baselines stand as
the baseline (the standing rule).

### JUDGMENT CALLS (each one a reviewer can reverse in a line)

1. **The parse accepts CURLY quotes** (the walk's finding). The alternative was
   `isAutomaticQuoteSubstitutionEnabled = false` on the capture boxes, which fixes one token by
   changing what her prose looks like in every capture she ever types. Reversing costs one
   predicate (`isQuote`) and one pin.
2. **The `{t:` opener is read case-insensitively.** Her ask is phone-first and iOS capitalizes the
   first letter of a capture, which is exactly where a title token goes. Strict spelling is one
   character away and is recorded as #127(b)'s alternative.
3. **A line that held nothing but tokens is removed whole.** Without it, a title token on its own
   line leaves a blank first paragraph in every note captured that way (`bulkSegments` stores the
   blank line as content, by the 2026-07-12 spacing ruling). The alternative — strip only the
   token's own characters — is #127(c).
4. **The empty-capture branch was NOT changed**, per the brief's letter: when the cleaned text is
   blank the door takes its standing empty branch, which CLEARS the box. So a capture of nothing
   but tokens loses the tokens silently. I followed the brief rather than invent a refusal
   sentence, and recorded the alternative as #127(f) — it is one `else` away.
5. **The refusal sentence is new copy, and it is a REFUSAL by 18i's grammar** — the tag door did
   nothing, so it always shows. It names what DID happen first ("The note was filed —") because
   the note is already safe and that is the half she needs. The alternatives (silence; a receipt,
   which `quiet`/`off` would govern) are #127(g).
6. **`MobileNoteTagsModel.applyTypedPath` was re-pointed at the shared act**, not just at the
   shared parts. Leaving it composing the walk itself would have left the ORDER of the walk
   written twice, which is the fork the hoist exists to close; its pins rode unmodified.
   `MobileTagsModel.createTypedPath` keeps its own body deliberately — it has a different
   outcome (a fully-existing path refuses as a duplicate), which is a door's rule and not the
   walk's.
7. **No canonical doc was edited.** R-13u4-1 adds a capture FACE; AppSpec states no capture
   grammar for it to contradict (§7's segmentation note is about what a newline does, untouched
   here). If she wants the microsyntax written into canon, that is a sentence for her, not for me.

### WHAT A FRESH SESSION WOULD NEED TO FINISH THIS

Nothing. Everything is committed and pushed: the two shared brains, the hoist and its four
consumers, both doors' hand-off, the two test files (30 pins), QUESTIONS #127, the KnownIssues
discharge, the walk captures (gitignored, listed above), and this record. What is OPEN is hers:
**#127 (a)–(g)**. What is owed elsewhere: the phone's capture face (the CARRIED block's parity
row (2), with the two lines it needs named there).

### THE HAND-OFF — WHAT EACH DOOR DOES NOW (piece 4)

Both Mac capture doors run the SAME four steps, in this order, and the order is the posture:

1. **Parse at the hand-off** (`CaptureMicrosyntax.parse(submitted)`) — never while she types. The
   box holds exactly what she typed right up to the ⏎ that files it, so a token is ordinary text
   until the note is being made. Her ask was about the note once it exists; this is that, and
   nothing more.
2. **The empty check moves onto the CLEANED text.** A capture of nothing but tokens has no note
   for a tag to go on, so each door takes its own STANDING empty-capture branch, unchanged
   (PROVISIONAL #127(f)).
3. **MINT with the cleaned text and the token's title** — `importPost(title:text:)`, the standing
   title road, byte-unchanged. A `{t:"…"}` outranks the first-words chip; when the chip is the
   only source, its words are read from the CLEANED text so a token can never land inside the
   stored name (#127(e)).
4. **THEN the tags, on the note that now exists** (`CaptureMicrosyntax.applyTags` →
   `TypedTagPath.apply`, one token at a time). This step cannot throw and undoes nothing: every
   token that fails comes back as a sentence the door speaks as a REFUSAL (18i's grammar — the
   tag door did nothing), and the note is already safe. **Filing never blocks on a token.**

**No routing machinery of any kind was written** — no `shelveInDailyJournalBook`, no smart-book
assembly, no membership code. The smart book in the pin
`aSmartBookKeyedOnTheTagCollectsTheNoteByTheStandingRules` collects the note because a tag
applied, and the same pin asserts `reading_post` has ZERO rows for it: collected by a predicate,
never by a row. That pin is how "no routing machinery" is stated in behaviour rather than prose.

| Pin | Door | What it holds |
|---|---|---|
| `theShelfBoxFilesATitledTaggedNoteWithTheTokensGone` | shelf | her own example, end to end through the real ops |
| `aSmartBookKeyedOnTheTagCollectsTheNoteByTheStandingRules` | shelf | R-13u4-1's promise: the book collects it, zero membership rows |
| `aTokenMayNameATagThatDoesNotExistYet` | shelf | the hoisted brain's create walk, reached through a token |
| `severalTokensAllApply` · `aBareHashtagFilesAsTextAndTagsNothing` · `aMalformedBraceFilesAsTypedText` | shelf | the ruled clauses at the door |
| `aTokenThatCannotApplyNeverCostsHerTheNote` | shelf | **the posture** — note filed, tags none, one refusal naming the token |
| `aCaptureOfNothingButTokensFilesNothing` | shelf | the standing empty branch (#127(f)) |
| `aTitleTokenOutranksTheOfferedFirstWords` | shelf | both title sources, and the name never carries a token (#127(e)) |
| `theMintIsAskedForTheCleanedTextAndTheTokensTitle` | shelf | the seam reads what the store was actually asked for |
| `thePadFilesATitledTaggedNoteWithTheTokensGone` | pad | the same rule at the other door — her tag rides BESIDE the pad's standing `quicknote` filing |
| `thePadsCaptureOfNothingButTokensFilesNothing` | pad | the pad's own empty branch |
| `aRefusedPadKeepsTheWholeCaptureTokensIncluded` | pad | a refusal keeps her capture BYTE-INTACT, tokens and all — the parse never touched the box |

### EVIDENCE — THE WALK (the unit closes on USE, not on pins)

**Build:** `App/Variorum/DerivedData/13u4c1/Build/Products/Debug/Variorum.app`
(`io.lduarte.Variorum.debug`, the fenced dev store). `pgrep -fl 'Variorum.app/Contents/MacOS'`
was checked at the start — **ZERO instances; hers was not running at any point** — and each dev
instance was quit **by identity** (`tell application id "io.lduarte.Variorum.debug" to quit`),
never by a keystroke (the 13u3 breach's walker law), with `pgrep` re-checked after every quit and
at the end. `/Applications/Variorum.app` was never touched. Captures:
`notes/plans/13u4-screens/c1/` (gitignored) — 34 window captures plus `c1/crops/` with the 23
read crops named below.

**Staged first, so the book could not be accused of following the capture:** a `dream` tag
(Settings ▸ Tags ▸ New Tag) and a SMART book **dream journal** (Shelf ▸ + new book ▸ Create Smart
Book ▸ Edit Filter… ▸ Tagged any of: dream). The shelf row then read `dream journal  #dream ·
smart` with no notes in it.

| # | Step | What the app did | Capture |
|---|---|---|---|
| 1 | The smart book staged and keyed on `#dream`, empty | the shelf row shows the key it collects by | `crops/11-book-keyed-on-dream.png` |
| 2 | **The shelf's quick-entry bar**, typed: `{t:"Ocean dream"} Had a weird dream about the ocean {#dream}` | the box holds exactly what she typed — **and the title chip offers the RAW opening**, the seam #127(e) records | `crops/20-TYPED-BOTH-TOKENS.png` |
| 3 | **⏎** | **THE UNIT, IN USE**: the note opens **titled "Ocean dream"**, its body reads `Had a weird dream about the ocean` — both tokens gone, no stray space — the tag chip reads `dream ×`, and the masthead's book line reads **`~/dream journal`** | `crops/21-TITLED-TAGGED-TOKENS-GONE.png` |
| 4 | The membership chip | *"This note appears in 1 book: dream journal"* | `22-book-collects.png` |
| 5 | The book itself | **dream journal · smart book · 2 notes** — and this one capture carries the walk's finding AND its fix side by side: the PRE-FIX note (`2026-09-20`, whose body still reads `{t:”Ocean dream”} Had a weird dream about the ocean` — the title token filed as text) beside the POST-FIX one (`Ocean dream`, body clean). Both were collected, because both tags applied | `crops/23-book-listing.png` |
| 6 | **The quick-note pad** (⌘⇧N), typed `{t:"Leg day"} squats and a long walk {#health/workout}`, ⏎ | the pad filed and closed; ⌘K finds the note by the name the token gave it | `24-pad-typed.png`, `crops/26-palette.png` |
| 7 | That note | **Leg day**, `~/quicknotes`, chips **`workout ×`** (the leaf, K3's grammar) **and `quicknote ×`** — her token rides BESIDE the pad's standing filing — body `squats and a long walk` | `crops/27-PAD-NOTE-TITLED-AND-TAGGED.png` |
| 8 | A malformed brace and a bare hashtag: `a thought {#unclosed and a bare #hashtag` | files **byte-intact**, no tag applied, *in no book* | `crops/28-MALFORMED-AND-BARE-HASHTAG-FILE-AS-TEXT.png` |
| 9 | **STUDY voice** (Settings ▸ Appearance), the same capture shape | **Second dream** · in dream journal · `dream ×` · `the sea again` — identical in the second voice | `crops/31-STUDY-VOICE.png`, `crops/32-study-typed.png`, `crops/33-STUDY-VOICE-LANDED.png` |
| 10 | **DARK** (`appearanceChoice dark`, relaunch), Study voice | **Dark dream** · in dream journal · `dream ×` · `the black sea` — the same on the black room | `crops/35-DARK-STUDY-LANDED.png` |
| 11 | **THE POSTURE**: `a thought worth keeping {#///}` | **the note filed** (`a thought worth keeping`, block 1/1, 4w) and the toast reads *"The note was filed — the tag “///” didn't apply. Type a tag name — “/” makes a hierarchy (life/goals)."* — filing never blocked on the token | `crops/36-REFUSAL-NOTE-STILL-FILED.png` |

**THE WALK'S FINDING, which no pin could have caught** (piece 4b, fixed and re-walked above):
step 3 on the FIRST pass landed the note tagged and collected but **untitled**, its body still
carrying `{t:”Ocean dream”}` as visible text. The Mac capture boxes apply AppKit's automatic
quote substitution, so the token she types arrives with U+201D curly quotes — measured, not
inferred: `osascript … get value of text areas …` piped through `xxd` printed
`7b 74 3a e2 80 9d 58 e2 80 9d 7d` for a typed `{t:"X"}`. A pin types the characters it means, so
the suite was green on a rule the door could never satisfy. The brain now accepts `"` · `“` · `”`
(opener and closer independently); the phone will need nothing extra when its face lands, since
iOS substitutes the same way. Turning substitution OFF in the boxes was the alternative and was
rejected: it would change what HER PROSE looks like in every capture to make one token work.

**Dev-store state left as found:** voice back to **Terminal** (verified in Settings ▸ Appearance,
`37-voice-restored.png`), `appearanceChoice` back to **system** (verified by `defaults read`),
zero instances. Left in the dev store as this walk's fixtures, as every walk's are: the `dream`
tag, the **dream journal** smart book, and five notes (`Ocean dream`, `Second dream`,
`Dark dream`, `Leg day`, and two dated `2026-09-20` notes — the pre-fix one and the malformed-brace
one). One accidental edit was made and **undone**: a mis-measured sidebar click in the Study voice
opened her starred fixture note and `{t:"X"} hello` was typed into it; three ⌘Z presses returned
it to `the quick brown foxone line. two line. three.`, verified by reading the block's
accessibility value afterwards. Recorded rather than papered over.

**A walker fact for the next session** (`Tools/WalkKit/README.md` at its next touch): **the
capture boxes substitute typed quotes** (U+201D), so a walk that types a quoted token and reads
the screenshot cannot tell straight from curly — read the box's AX value and `xxd` it. And the
shelf's row heights differ enough between the voices that the quick-entry bar's y moves by ~70
screen points between Terminal and Study: re-read it from a capture after every voice flip (the
13u3 UNIT F fact, met again the hard way).

---

## UNIT C2 BRIEF — SELECTION → A TAKE ON THE SAME BLOCK (item 9, R-13u4-4; self-contained — read in this order)

**Read first, in full:** (1) this file's Status banner · HER ADDITIONS item 9 (her verbatim
words) · THE SIZING-AND-RULINGS SITTING RECORD (**R-13u4-4 is yours and BINDING**: MOVE alone;
the quiet insurance savepoint of the current take is LOAD-BEARING — her stated cover for the
stay case; ONE transaction — savepoint · the span leaves the current take's buffer · a new take
mints at the fan's END holding the span, branched from the current take, NOT chosen · ONE undo
entry) · THE LEDGER · ENVIRONMENT TRAPS · CAST & DISCIPLINE · the four prior UNIT RECORDs
(E3's walker facts bind any walk staging). (2) **OverallModel §3's seventh quiet occasion +
AppSpec §9's cross-block-edit machinery** (`Operations.insureTakes`, 13u1 UNIT 2 — the
insurance shape you compose or mirror) and **§9's structural undo/redo paragraphs** (compound
entries; `redo:` required, never defaulted; exact-row re-applies). (3) The constitution's
**P-1/P-2** (the act declares in the capability registry — verb, scope, availability rule,
doors, refusal copy; a rendered door acts or delivers the real refusal; the registry-walk test
asserts it). (4) The code: `Sources/VariorumCore/Operations/` (the compound infrastructure —
`withCompound`, the 13u1 cross-block compound's registration shape; `branchVariant`; `commit`;
the lock/seal guard conventions) · the Write selection plumbing (`EditorViewModel`'s selection
facts; the block ▾ / context-menu door homes; the capability registry). Do your own reading.

**The build.**
- **A new core operation** (ONE transaction, the R-13u4-4 shape verbatim): refuse under a
  sealed post; refuse on a locked current take NAMING the lock (the buffer is what the lock
  guards, and the span leaving it is a buffer edit). The insurance savepoint is `kind='auto'`,
  deduped against the take's last commit (the standing insurance conventions — reuse
  `insureTakes`' shape if it fits one take, else the lockVariant one-quiet-commit pattern; say
  which in the record). The new take: minted at the fan's END (`fan_position` after the last),
  `parent_variant_id` = the current take, working_text = the span EXACTLY as selected (no
  snapping — `BoundarySnapping` serves CUTS, and this mints no block boundary; no whitespace
  trimming — U-19 (2), never eat what she typed; a doubled space left at the removal seam is
  hers to tidy, recorded as a PROVISIONAL if you think it wants a rule), label nil
  (PROVISIONAL), never chosen, never locked. Registers ONE compound undo entry (inverse:
  tombstone-flip the mint + restore the current take's buffer from the pre-image; redo:
  exact-row re-apply — the do-time-pre-images law).
- **AppSpec §9 gains the op's bullet WITH your build** (the `renameCommitPoint` precedent):
  exactly the ruled shape, citing R-13u4-4 and her words, the seventh-occasion insurance named.
  Nothing else in canon.
- **The Write door, registry-declared (P-1):** available when the selection is non-empty and
  lies within ONE block on the live editor (a cross-block selection is NOT this gesture — the
  door does not render there, P-2; the standing cross-block roads own that population). Homes:
  the selection context menu + the block ▾ row (and the ⌘K palette if the registry gives it
  one for free). The refusal copy through the standing status-seam vocabulary (18i kinds). A
  keybind ONLY if a free, conventional one exists — check the registry/shortcuts helper;
  otherwise no chord, doors suffice (record the check).
- The phone gets nothing (not asked; the op compiles into iOS via core — the build gate).

**Evidence:** the op's state-transition suite (rows read/written; the savepoint present AND
deduped; refusals; undo→redo round-trips to the same rows; I10 untouched — the current take
keeps its remainder, even empty: an empty buffer is legal, the E1 precedent) + the registry
walk covering the new door + a hands-on WALK on the dev-store Debug build: highlight
mid-block, invoke — the span leaves, the fan badge appears, Takes shows the new card at the
fan's end unchosen, Block History shows the insurance savepoint, ⌥⌘Z reverts the whole gesture
and ⇧⌥⌘Z re-applies it. Captures to `notes/plans/13u4-screens/c2/`. Core `swift test` + the
touched Mac suites + the acceptance spine (REAL TYPE NAMES) at the end; iOS build green.
PROVISIONALs from **#128**.

**Your record:** append a `## UNIT C2 RECORD` section to THIS file with LIVE STATUS from the
FIRST commit (PENDING marks), the op's transition table, the door's registry row, and the
seam-file list (the selection facts likely come from `EditorViewModel` — if the diff reaches
`BlockRangeIndex`/`EditorTextView`/`TypedReturn`/`PaneTextAuthority`, say so for the ladder);
flip the ledger's C2 row in your closing commit. The checkpoint protocol binds from the first
commit.

---

## UNIT C2 RECORD — SELECTION → A TAKE ON THE SAME BLOCK (item 9, R-13u4-4)

**WHAT THIS UNIT DID NOT DO (the record's first line):** nothing outside **ONE new core
operation and ONE Write door**. `Sources/VariorumCore/Sync/` · the schema · the migrations ·
`Server/` — **ZERO lines** (verified by name over the whole unit diff: the only file under
`Sources/` is the new `Operations+SpanToTake.swift`). **No editor-seam file** —
`BlockRangeIndex`, `EditorTextView`, `TypedReturn`, `PaneTextAuthority`, `runStructural` itself,
`StructuralSeamEdit`, `StructuralGesturePlanner`, `MarkdownActs` are all untouched (the seam list
below says so by name). No other unit's work (E1's Return chain, E2's ⌥⌫ product call, E3's merge
join, C1's capture microsyntax, the restyle spine) was touched. **The phone gets no face** and no
mobile file is in the diff; **no Takes-side door, no bulk-bar row, no ceremony sheet and no
keybind** was built — the first is a product call (QUESTIONS #128(e)), the last a recorded
collision sweep (#128(d)). No `KnownIssuesAndTechDebt.md` row was opened or closed.

### LIVE STATUS (flipped in the same commit as each piece; unverified claims say PENDING)

| # | Piece | Status |
|---|---|---|
| 1 | The record + the READING (the brief's four reading lists, in order) | DONE (this commit) |
| 2 | The core op + its state-transition suite (rows read/written · the savepoint · the refusals · undo↔redo exact-row) + the AppSpec §9 bullet | DONE (this commit) — **22 tests in 1 suite passed**, below |
| 3 | The Write door + its registry declaration + the registry walk | DONE (this commit) — **42 tests in 3 suites passed** (the two new suites + `CapabilityRegistryTests`) |
| 4 | QUESTIONS #128 (the PROVISIONALs) | DONE (this commit) — (a)–(e); next free moves to #129 |
| 5 | The walk on the dev-store Debug build, captured | DONE (this commit) — 24 captures + 26 crops, both doors, both voices AND both appearances; the table below |
| 6 | Closing suites + iOS build + the ledger's C2 row | DONE (this commit) — core **1631/175** · Mac **336/38** (incl. the acceptance spine's eleven types) · iOS **BUILD SUCCEEDED** |

### THE SHAPE, AS RULED (R-13u4-4 — read before the diff)

Her ruling, verbatim: *"move alone should be fine - the fact that there'll be a savepoint/commit
of the current take right before moving is enough to cover the case that someone wants it to
stay - they can just revert it to that point if they want."*

ONE transaction: **insurance savepoint of the current take** (LOAD-BEARING — her stated cover for
the stay case) · **the span leaves the current take's buffer** exactly as selected · **a new take
mints at the fan's END** holding the span, branched from the current take, never chosen, never
locked · **ONE undo entry** with the exact-row redo.

### EVIDENCE — THE WALK (the unit closes on USE, not on pins)

**Build:** `App/Variorum/DerivedData/13u4c2/Build/Products/Debug/Variorum.app`
(`io.lduarte.Variorum.debug`, the fenced dev store). `pgrep -fl 'Variorum.app/Contents/MacOS'`
was checked at the start — **ZERO instances; hers was not running at any point** — and each dev
instance was quit **by identity** (`tell application id "io.lduarte.Variorum.debug" to quit`),
never by a keystroke (the 13u3 breach's walker law), with `pgrep` re-checked after every quit and
at the end. `/Applications/Variorum.app` was never touched. Captures:
`notes/plans/13u4-screens/c2/` (gitignored) — 24 window captures plus `c2/crops/` with the 26
read crops named below.

| # | Step | What the app did | Capture |
|---|---|---|---|
| 1 | A one-block note staged through the shelf's quick-entry bar: *"The first sentence stays here. The middle piece moves into a take. The last sentence stays too."* | opens in Write, **block 1/1**, `17w block · 17w in note` | `02-note-open.png` |
| 2 | Highlight the MIDDLE sentence (` The middle piece moves into a take.`), **right-click** | the selection menu carries **Move Selection into a New Take**, below Delete Block | `crops/04b-context-menu.png` |
| 3 | Click it — **THE UNIT, IN USE** | the span LEAVES: the page reads *"The first sentence stays here. The last sentence stays too."*, a **⑂2 fan badge** appears on the block, the caret sits at the seam, `10w block` | `crops/05-after-move.png` |
| 4 | The bottom bar's trailing end | the quiet receipt: ***"Moved into a new take — the take it left was saved first. ⌥⌘Z undoes it."*** | `crops/05-bar.png` |
| 5 | **Takes** (⌘2) ▸ expand all | TWO cards: **✓ chosen** holding the remainder, and — at the fan's END — a card headed **`choose`** (i.e. NOT chosen) holding ` The middle piece moves into a take.` | `crops/07-takes-expanded.png` |
| 6 | Write ▸ **history** — her ruled cover for the stay case | Block History ▸ Savepoints ▸ *take 1 of 2 · the take you're in · 1*: the savepoint reads the WHOLE pre-move text, `sep 20, 2026 at 6:40 pm · quiet`, with **Restore** beside it. Take 2 of 2: **0** | `crops/08-history.png` |
| 7 | **⌥⌘Z** | ***"Undid: Move into a New Take"*** — the text is whole again (`17w block · 17w in note`), the badge gone | `crops/09-undone-text.png`, `crops/09-undone-bar.png` |
| 8 | **⇧⌥⌘Z** | ***"Redid: Move into a New Take"*** — back to the post-move page with ⑂2, `10w block` | `crops/10-redone-text.png`, `crops/10-redone-bar.png` |
| 9 | Caret only (no selection), open the bar's **block ▾** | the row is **ABSENT** — Divide · Divide choosing takes · Extract · Make Block · Merge · Merge choosing takes and nothing else (P-2 in use) | `crops/11-blockmenu-caret.png` |
| 10 | Select a span, reopen **block ▾** | the row **APPEARS**, beside the six above | `crops/12-blockmenu-selection.png` |
| 11 | Click it — the SECOND door acts | the span leaves, badge **⑂3**, the same receipt | `crops/13-after-bar-door.png`, `crops/13-bar.png` |
| 12 | **STUDY voice** (Settings ▸ Appearance), block ▾ re-opened on a selection | the row renders in the serif voice too; clicking it lands the act and the receipt (`5w block · 5w in note`) | `crops/16-study-blockmenu.png`, `crops/17-study-bar.png` |
| 13 | **DARK** (`appearanceChoice dark`, relaunch), Study voice, a span selected, right-click | the context row renders on the black room; clicking it lands the act (badge **⑂5**) | `crops/20-dark-contextmenu.png`, `crops/21-dark-after.png` |
| 14 | **THE DEDUPE, CAUGHT IN USE** — the bar after step 13 | ***"Moved into a new take — ⌥⌘Z undoes it."*** — **without** the saved-first clause, because this take's buffer already matched its latest savepoint. The J8 copy-truth rule, visible: the clause appears only when a savepoint was actually written | `crops/21-dark-bar.png` |
| 15 | …and why the cover still held: Block History ▸ show | take 1's FOUR quiet savepoints, newest first — `The first sentence stays here.` (6:44, the QUIT's `closeAutoCommit`), `…here. stays too.` (6:44, step 12), `…here. The last sentence stays too.` (6:43, step 11), and the whole original (6:40, step 3). **Nil never meant "nothing to restore"** | `crops/23-dark-savepoints.png` |

**What step 14 proves, said plainly (it is the one thing a pin could not):** the insurance is
deduped against the take's own last savepoint, so a move can legitimately write nothing — and in
that case the pre-move text is already the top row of that take's history, one Restore away.
The receipt tells the truth in BOTH branches rather than claiming a write that did not happen.

**Dev-store state left as found:** voice back to **Terminal** (verified in Settings ▸ Appearance,
`24-voice-restored.png`), `appearanceChoice` back to **system** (verified by `defaults read`),
**zero instances**. Left in the dev store as this walk's fixture, as every walk's are: the note
`The first sentence stays here.` (dated `2026-09-20`, in no book) carrying five takes — the four
spans this walk moved out of it, plus the remainder.

### THE OPERATION'S TRANSITION TABLE (rows read and written, in one transaction)

`Operations.moveSpanToNewTake(from: variantID, span: Range<Int>, expectedText: String?)`
(`Sources/VariorumCore/Operations/Operations+SpanToTake.swift`) — the whole act, in the order it
runs. Every row below is a pin in `Tests/VariorumCoreTests/SpanToTakeTests.swift` (22 tests).

| # | Reads | Writes | Rule |
|---|---|---|---|
| 0 | `variant` (the source take), `container_block` + `container` via the placement guard, `block` | — | `editableVariant` — the **autosave/edit class**, because the span leaving the buffer IS a buffer edit: live · active · unlocked · unsealed, plus a live BLOCK. Each refusal is the standing convention's and each has shipped words at both refusal switches |
| 1 | the take's buffer | — | the CAS: `expectedText` mismatched ⇒ `bufferChangedSinceGesture`, the whole gesture refuses (the Phase 5 reject-path doctrine the editor's deferred gestures already ride) |
| 2 | the buffer's length + graphemes | — | the span's own validation — bounds, non-empty, grapheme-aligned through the ONE brain (`BoundarySnapping.graphemeRange`). `invalidCut` is the caller-bug answer, not a road she can walk |
| 3 | `commit_point` (the take's latest) | **`commit_point` INSERT** (`kind='auto'`, no message) | **THE INSURANCE SAVEPOINT — her ruled cover for the stay case.** Deduped on the standing `isDirty` rule: nil means the take's last savepoint ALREADY holds the pre-move text, never that there is nothing to restore |
| 4 | — | **`variant` UPDATE** (`working_text` = buffer minus the span, `updated_at`) | the span leaves **EXACTLY as selected** — no snapping, no trimming (U-19 (2); #128(a)) |
| 5 | `container_block` → `container` | **`container` UPDATE** (`last_touched_at`, churn, `updated_at`) | `registerTextChange(charDelta: the span's UTF-16 length)` — a buffer edit touches and churns like any other (§10) |
| 6 | `variant` (`MAX(fan_position)` over the block's live rows) | **`variant` INSERT** | the mint: at the fan's **END**, `parent_variant_id` = the source take, `working_text` = the span verbatim, `label` NULL, `status` active, **`locked` 0**, and **nothing chooses it** — neither `container_block.chosen_variant_id` nor `block.default_variant_id` is written |
| 7 | — | **`sync_outbox`** ×3, by trigger | three ordinary rows on the wire; zero engine lines, no repair class (pinned) |
| 8 | — | ONE `UndoStack` entry, label **"Move into a New Take"** | `inverse` = the buffer's pre-image back + the mint tombstoned (one transaction); `redo` = the exact-row mirror; `insuring:` carries the pre-image so A12's destructive-undo warning can be asked BEFORE the act |

**The entry's two halves** (`revertSpanToNewTake` / `reapplySpanToNewTake`, both exact-row from the
SAME do-time images, both one transaction):

| Direction | What it does | Refusal bucket |
|---|---|---|
| **undo** | restores the source buffer (with the FOURTH occasion's insurance when the buffer diverged since — `wouldInsure`), then tombstones the mint; `reassignDefaultIfNeeded` runs behind it | **resolvable refusals THROW and keep the entry**: a sealed note; a source take since locked, archived or dead; a mint she has since CHOSEN (`variantIsChosen` — `deleteVariant`'s own guard); an I10 violation. **Divergence is quiet**: a mint already deleted stays deleted |
| **redo** | flips the mint's tombstone back (never a fresh mint — that would strand the inverse's captured id), voids any purge intent naming it, then sets the buffer to its post-op text | the same buckets, mirrored |

**I10, by construction:** the source take keeps its remainder — **even when the span is the whole
buffer**, in which case the take is left EMPTY and legal (pinned; #128(c)). Nothing is archived,
nothing is tombstoned, and the block gains a take rather than losing one.

### THE DOOR'S REGISTRY ROW (P-1)

| Field | Value |
|---|---|
| id | `.moveSelectionToTake` |
| verb | **Move Selection into a New Take** |
| scope | `.block` (`.deleteInEveryTake`'s precedent — it addresses a span of a block and changes that block's fan) |
| doors | `[.contextMenu, .bottomBar]` — the selection context menu and the bar's `block ▾` row, **both Write's** |
| shortcut | **none.** The sweep: the take family's keys are all taken (⌘T · ⌥⌘T · ⇧⌥⌘T · ⌘⇧T) and so are the span gestures' (⌘⇧E · ⌘⇧K); the free neighbours left (⌥⌘E) read as *a variant of extract*, which is the collision the ⌥-means-the-deliberate-variant habit exists to avoid. A chord would also owe a `.menuBar` door and a helper row (the walk asserts both) — a third door this unit was not asked to build. Recorded at QUESTIONS #128(d) |
| availability | `writeEditor` — **attachment only**, the `.previousBlock` family's rule: the act calls the attached full-document editor directly and enablement must never outrun it |
| takesAccess | `nil`, with a **NAMED exemption** in the walk's `exempt` set and the reason written there (QUESTIONS #128(e)) |
| unavailableNote | *"Moving a selection into a take happens where you write — open a note first."* |
| per-selection rendering | **`SpanToTakeGesture.plan` — the ONE brain** both doors and the act consult. The row renders only where the selection is non-empty, lies inside ONE block, does not touch the open tail, and the block has a take. Walk-asserted (`theContextRowAppearsOnlyForASelectionInsideOneBlock`, `theBarsAvailabilityFactFollowsTheSelection`) and walked in use (rows 9–10 above) |

**The `.menuBar` and `.palette` doors were deliberately NOT taken.** Both would need a
`RoutedCommand` case, a handler on every post surface and an unhandled note (the walk asserts the
last) — which is the Takes-side reach #128(e) asks her about, arriving by the back door. Two
discoverable menu doors where she writes is exactly what the brief named.

### SEAM FILES THIS DIFF TOUCHES (the ladder's Fable reviewer reads this list)

**NONE — said explicitly, as the brief asks.** `BlockRangeIndex`, `EditorTextView`,
`TypedReturn`, `PaneTextAuthority`, `StructuralGesturePlanner`, `StructuralSeamEdit`,
`runStructural` itself and its identity oracle, `MarkdownActs` — not one of them is in the diff.
`Sources/VariorumCore/` contains exactly ONE new file and no edit to an existing one, so `Sync/`,
the schema, the migrations and `Server/` are untouched by construction.

**The whole unit is six source files** — one new core operation
(`Sources/VariorumCore/Operations/Operations+SpanToTake.swift`), one new pure brain +
copy (`App/Variorum/Variorum/Features/Editor/SpanToTakeGesture.swift`), and four edits:

- `EditorSurfaceController.swift` — **ONE new method** (`moveSelectionToNewTake`), which calls the
  SHIPPED `runStructural` with `seam: nil`. No existing road, guard, order or derivation changed.
- `EditorViewModel.swift` — a forward, one new `GestureAvailability` field and its line in
  `refreshGestureAvailability`, one conditional row in `contextMenuItems()`, and the id in
  `contextMenuCapabilities`.
- `CommitBar.swift` — one conditional row in `blockMenu` and the id in `renderedCapabilities`.
- `Capability.swift` / `CapabilityRegistry.swift` — the new id and its declaration.

### CLOSING RUNS (at the unit's END — never the full suite at the start)

| Run | Command | Result |
|---|---|---|
| **Core** — the new operation (`swift test`, the whole core package) | `swift test` from the repo root | **1631 tests in 175 suites passed** (exit 0). Baseline was E3's 1609/174; +22 tests and +1 suite, exactly this unit's |
| **Mac** — the two new suites, the registry walk, the structural/planner/gesture neighbourhood, the bar's layout suite, the command router and seal doors, the seam and cross-block suites, block selection, the window smoke and gesture soak, Block History, confirmations — AND the acceptance spine under its ELEVEN REAL TYPE NAMES (the `-only-testing` file-name trap, met by all four prior units) | `xcodebuild test -scheme Variorum -destination platform=macOS` with `-only-testing:` for `SpanToTakeGesturePlanTests` · `SpanToTakeDoorTests` · `CapabilityRegistryTests` · `CommitBarLayoutTests` · `StructuralRewriteDoorTests` · `DivideExtractGestureTests` · `MakeBlockGestureTests` · `MergeGestureTests` · `DivideWCeremonyTests` · the six `Planner*` types · `CommandRouterTests` · `StatusCenterTests` · `MoveAndExecuteTests` · `SealDoorTests` · `SeamMergeTests` · `CrossBlockCompoundTests` · `WriteBlockSelectionTests` · `BlockSelectionRegistryTests` · `EditorWindowSmokeTests` · `GestureSoakTests` · `BlockHistoryPaneTests` · `ConfirmationsSettingTests` + the eleven `Tutorial*` types | **336 tests in 38 suites passed** (exit 0, no skips) |
| **iOS build gate** — `VariorumCore` compiles into the phone, so a core op owes it | `xcodebuild build -scheme VariorumMobile -destination generic/platform=iOS` | **BUILD SUCCEEDED** |

No full-suite run was made at this unit's START; the plan's closeout-refresh baselines stand as
the baseline (the standing rule).

### JUDGMENT CALLS (each one a reviewer can reverse in a line)

1. **The act is NOT a `StructuralGesturePlanner.Command`, and it has its own brain.** That
   planner is the ratified contract for acts that move a BLOCK BOUNDARY; this one moves none — a
   block's text shrinks and its fan grows. Adding a case would put a non-structural verdict inside
   the enum every structural switch is exhaustive over, and would OBLIGE a Takes-board door by
   construction (`theBoardsStructuralGroupRendersEveryStructuralAct` is exhaustive over
   `StructuralAct.allCases`) — a second surface this unit was not asked to build. Reversing: a
   `Command`/`Plan` case pair plus that board row.
2. **`seam: nil` — the rewrite re-renders from the store.** No `StructuralSeam` case describes
   "one block's text shrank", and `deleteInEveryTake` / `replaceInEveryTake` take exactly this
   posture for exactly this reason. The honest cost is a full re-render per gesture, which for a
   deliberate, occasional act is the same trade those two doors already make. Reversing: a new
   seam case + its derivation and three guard layers.
3. **The op takes a VARIANT id, not a block id.** `extract` and the divides address a BLOCK and
   resolve the rendered take inside; this one is handed the take the span actually came from, so
   it can never edit a take other than the one on screen. It also makes the `expectedText` CAS
   meaningful. Reversing: a `placedContext` resolve, and the CAS would have to move with it.
4. **The doors render conditionally, which is one deliberate difference from `block ▾`'s
   fire-and-speak posture.** That posture retires per-door DIMMING; it does not ask a menu to
   offer a gesture whose population belongs to another act. A cross-block span is Make Block from
   Selection's, and a row that could only ever refuse there is what P-2 forbids. Reversing: drop
   two `if`s and let the op's refusal speak (the refusal copy already exists and is pinned).
5. **No `.menuBar` / `.palette` door and no chord** (the registry row above says why). Each of the
   three would be a real addition with its own obligations; the brief named two doors and this
   built two.
6. **`invalidCut` was reused rather than minting an `invalidSpan` case.** It is the caller-bug
   answer for a span the door cannot produce (the door plans from the surface's own tiling), and a
   new error case owes copy at two refusal switches for a state she cannot reach. Reversing: one
   enum case and two sentences.
7. **The receipt has two forms, and the difference is a fact the op returns.** The saved-first
   clause appears only when a savepoint was actually written (the J8 copy-truth rule) — and the
   walk's step 14 is that branch happening in use. The alternative (always claim it) would have
   been a sentence that is sometimes false.
8. **Nothing was written into `notes/KnownIssuesAndTechDebt.md`.** There is no deferred WORK here:
   what is open is hers (#128), and a row whose owner is "a ruling" is the drift class (E2's own
   precedent).

### CARRIED TO THE PHASE CLOSEOUT (from this unit)

1. **AppSpec §14's phase delta** is the CLOSEOUT's to write (E1/E3's precedent): this unit's canon
   delta is §9's new `moveSpanToNewTake` bullet, citing R-13u4-4 (2026-09-20) with her words.
2. **QUESTIONS #128 (a)–(e)** joins her ratify bundle; next free moves to **#129**.
3. **A MOBILE PARITY candidate, named rather than assumed:** the operation is core-side and
   already compiles into the phone (the iOS gate), so what the phone owes is a DOOR — and its
   shape is downstream of #128(e), since "where does this act live besides Write" is the same
   question on both platforms. Filed as a candidate for the mobile catch-up, not as an obligation
   this unit ducked.
4. **A walker fact** for `Tools/WalkKit/README.md` at its next touch: a `screencapture -x -o`
   FULL-SCREEN capture is in screen pixels with NO window offset (screen point = px/2), while
   `walk-cap`'s WINDOW capture needs the window's Y added back (point = px/2 + 33). Mixing the two
   conventions puts a click one bar-height away from its target, silently.

### WHAT A FRESH SESSION WOULD NEED TO FINISH THIS

Nothing. Everything is committed and pushed: the core operation and its 22 pins, the pure gesture
brain and its copy, both Write doors, the registry declaration and its walk exemption, the 20 Mac
pins, the AppSpec §9 bullet, QUESTIONS #128, the walk captures (gitignored, listed above), and
this record.

---

## UNIT F1 BRIEF — THE INDEX CHAPTER-CLICK LANDS LOW (item 10; self-contained — read in this order)

**Read first, in full:** (1) this file's Status banner · HER ADDITIONS item 10 (her verbatim
report — *"clicking on the name of a chapter in a book isn't bringing you to the correct
location, but instead a random location in the text a fair amount under it. Only seen in index
mode. Not a huge problem"*) · THE SIZING-AND-RULINGS SITTING RECORD (no ruling pre-decides this
unit — it is a DEFECT, trace-first) · THE LEDGER · ENVIRONMENT TRAPS · CAST & DISCIPLINE · the
five prior UNIT RECORDs (the walker facts bind: E3's osascript staging; C2's capture-offset
fact — a full-screen capture is screen-pixels/2, a `walk-cap` window capture needs the window Y
added back; mixing them puts a click a bar-height off, silently). (2) **The recorded
hypothesis, which you TEST rather than assume:** the book Index has NOT adopted
`Surface/LandingAuthority` — 13u2b's closeout says Takes/Index adopt "at their next touch",
and this unit is that touch IF the trace confirms the mechanism. Read
`notes/plans/phase-13u2b-landing-seam.md` and
`notes/plans/navigation-landing-architecture-trace.md` (the landing architecture and its
vocabulary) before the code. (3) The code: the book Index mode's chapter navigation road
(`LandingTarget`, the Index word-tab's panel, wherever the chapter click aims and scrolls) ·
`Surface/LandingAuthority` and one surface that HAS adopted it, side by side with Index's own
road. (4) **KnownIssues row 56** (`BookIndexEditingTests.theReadClickLandsInIndexAtThatBlock`
is LOAD-FLAKY with a warm-DerivedData covariate) — the baselines say to treat a red there as
environment **unless your diff touches the book Index. YOURS DOES.** So for that test the
paired interleaved protocol is MANDATORY: your tree vs your opening commit, alternating runs,
before you claim either green or environment. Do your own reading.

**Discipline, in order:** (1) REPRODUCE her scenario on the dev-store Debug build first —
Sherlock (the long book), Index mode, click a chapter far down the panel; measure where the
landing arrives vs the chapter's top (her "sometimes" means several trials; record the rate).
(2) If it reproduces: TRACE the concrete mechanism (inputs → wrong scroll target → the landing
below) — candidate axes: the un-adopted `LandingAuthority`, height-estimation drift on
unrealized rows (the 13u2b manifest family), a stale anchor; the trace decides, not the
hypothesis. **Red-on-old is owed** (a pin that fails on the pre-fix tree, behavioural-revert
verified). If the fix IS the LandingAuthority adoption, that is the prescribed next-touch shape
— adopt, don't fork. (3) If it does NOT reproduce after honest staging (several chapters,
several depths, cold and warm mounts), the E2 stop rule applies: record what you measured,
report to the orchestrator, fix nothing. (4) If the trace shows a 13u2b-class architectural
problem bigger than an adoption, STOP and report — that is the architect's to rule.

**Evidence:** the red-on-old pin (if confirmed) + the paired-protocol adjudication of row 56's
test on both trees + a hands-on WALK: chapter clicks at several depths land at the chapter's
top, captured before/after. Captures to `notes/plans/13u4-screens/f1/`. The touched Mac suites
+ the acceptance spine (REAL TYPE NAMES) at the end. No core change expected; if one appears
necessary, stop and report. PROVISIONALs from **#129**.

**Your record:** append a `## UNIT F1 RECORD` section to THIS file with LIVE STATUS from the
FIRST commit (PENDING marks), the reproduction table (trials × landing offset), the traced
mechanism, the row-56 paired-run table, and the seam-file list; flip the ledger's F1 row in
your closing commit. The checkpoint protocol binds from the first commit.

---

## UNIT F1 RECORD — THE INDEX CHAPTER-CLICK LANDS LOW (item 10)

**WHAT THIS UNIT DID NOT DO (the record's first line, written at the open and RE-STATED AT THE
CLOSE against what actually shipped):**

- **It did not build the heights half, and that is the unit's stop-and-report line.** The trace
  found a 13u2b-class problem bigger than the adoption the brief prescribed — the Index pane's
  rows have no honest heights, so a cold column moves under a landing faster than any compensator
  can aim — and the brief's own rule sends that to the architect. What it is, what it costs and
  what it would consume are in the KnownIssues row this unit opened and in the CARRIED block below.
- **It did not adopt Takes' compensator** (13u2b left Takes and Index to their next touch; this is
  INDEX's touch, not Takes').
- **It did not change one line of the shared authority's behaviour.** `LandingAuthority.swift` IS
  in the diff, additively — a `LandingSurface` case and a new `LandingPolicy` — and nothing else in
  that file moved: the pure decision, the runner, the seed, the signpost and BOTH shipped policies
  are byte-identical, and the Outline's and the flow's landing suites ride UNMODIFIED and green.
- **It did not touch `Sources/VariorumCore/` at all** (zero files — so `Sync/`, the schema, the
  migrations and `Server/` are untouched by construction; the marker stays 8), and no `Shared/`
  file moved.
- **It did not touch the editor seam** — `BlockRangeIndex` / `EditorTextView` / `TypedReturn` /
  `PaneTextAuthority` / `runStructural` and its oracle are all absent from the diff.
- **It did not re-open any road 13u2b's "WHAT NOT TO DO" closed**: no lazy-run restructuring, no
  per-row `.task` reads, no `@State` writes on content reports, no `ensureLayout` over full
  documents, and no tuning of a SHIPPED surface's compensator constants (the numbers this unit
  chose are its own surface's, each measured before it was written down).
- **It did not fix row 56**, and did not wave it off either: it adjudicated it by the paired
  interleaved protocol and left it exactly where it found it.
- No other 13u4 unit's work was touched.

### LIVE STATUS (flipped in the same commit as each piece; unverified claims say PENDING)

| # | Piece | Status |
|---|---|---|
| 1 | The record + the READING (the brief's four reading lists, in order) | DONE (8d84ab22) |
| 2 | THE REPRODUCTION — her gesture on the dev-store Debug build, a TRIAL TABLE (rate, not one run) | DONE (feb2d5d0) — **20 trials, 11 MISSES**, the table below |
| 3 | THE MECHANISM, TRACED (inputs → wrong scroll target → the landing below) — the `LandingAuthority` hypothesis TESTED, never assumed | DONE (feb2d5d0) — the two measured experiments below |
| 4 | The red-on-old pin (behavioural-revert verified) + the fix | **THE FIX IS IN** (adc6bfe4, the policy's final shape at ba50ae1c; the pins' red run at feb2d5d0) — the Index adopts `LandingAuthority`; pins red 3/3 pre-fix · the pin's first shape was HOLLOW and is recorded as such · the paired behavioural-revert measurement is piece 4b |
| 4b | The BEHAVIOURAL REVERT — is the improvement the AUTHORITY's, or the probe's? (a worktree at the probe-only commit, the same trials + the same pins) | DONE (acb0b834) — **the authority's**: 3 of 4 trials miss and both pins are RED on the reverted tree |
| 5 | Row 56's PAIRED INTERLEAVED adjudication (`theReadClickLandsInIndexAtThatBlock`, both trees) | DONE (cddf94a6) — **6 runs, 3 rounds, alternating: RED on BOTH trees, byte-identical, every round** |
| 6 | The WALK — chapter clicks at several depths, before/after, captured, both voices AND both appearances | DONE (a5a6de86) — the table below |
| 7 | Closing suites + QUESTIONS #129 + the KnownIssues row + the ledger's F1 row | DONE (7bf628a4) — **148 tests in 24 suites, 2 issues, both row 56's one adjudicated test** |

### THE READING (done in this session's own context, in the brief's order)

1. This file's Status banner · HER ADDITIONS item 10 (her verbatim report) · THE
   SIZING-AND-RULINGS SITTING RECORD · THE LEDGER · ENVIRONMENT TRAPS · CAST & DISCIPLINE · the
   five prior UNIT RECORDs (E1 · E2 · E3 · C1 · C2 — their walker facts bind: E3's osascript
   staging and the quick-entry bar's dropped characters; C1's curly-quote and voice-row-height
   facts; C2's capture-offset arithmetic — a full-screen `screencapture` is px/2 with NO window
   offset, a `walk-cap` window capture needs the window's Y added back).
2. `notes/plans/navigation-landing-architecture-trace.md` IN FULL (the binding design record for
   this class: §2's eight dated engagements, §3's four compensators — **Index is compensator 4**,
   §4's reconciliation, §5's manifest + one-authority recommendation, §7's notes) and
   `notes/plans/phase-13u2b-landing-seam.md` (the phase that built (b) and (c): UNIT 1's manifest
   + the Outline, UNIT 2's `LandingAuthority` + the flow + the signpost, UNIT 3's fraction carry,
   and the ladder's dispositions).
3. The code: `BookIndexView.swift` (the chapter row's tap → `paneTarget` → the pane's single
   `proxy.scrollTo`), `Surface/LandingAuthority.swift`, `Surface/BookHeightManifest.swift`,
   `BookView.swift`'s Outline adoption (`landOutline` / `outlineAnchorMoved` /
   `outlineContentResized` / `outlineUserScrolled`) as the side-by-side example, and
   `BookIndexEditingTests.swift`.
4. `notes/KnownIssuesAndTechDebt.md` row 56 in full (the load-flaky read-click, the
   warm-DerivedData covariate) — **this diff touches the book Index, so the paired interleaved
   protocol is mandatory there** — plus rows 49/64 (the landing/settle family) and row 42 (the
   shared-defaults class, which a landing measurement must not be fooled by).

### THE REPRODUCTION (piece 2) — her gesture, on the dev-store Debug build

**Build:** `App/Variorum/DerivedData/13u4f1/Build/Products/Debug/Variorum.app`
(`io.lduarte.Variorum.debug`, the fenced dev store). `pgrep -fl 'Variorum.app/Contents/MacOS'`
checked at the start — **ZERO instances; hers was not running at any point** — and every dev
instance was quit **by identity** (`tell application id "io.lduarte.Variorum.debug" to quit`),
never by a keystroke (the 13u3 breach's walker law). `/Applications/Variorum.app` was never
touched. Captures: `notes/plans/13u4-screens/f1/` (gitignored), one full window per trial plus a
`-top.png` crop of the pane's first inches, which is what the table reads.

**The protocol.** Her sentence is the protocol: *"clicking on the name of a chapter in a book"* —
so: open the book, Index mode, click a chapter row in the column, wait 2.5 s, read what the pane
shows at its top. The target is the chapter's own heading; a hit shows that heading at the top,
a miss shows whatever the page landed on. **The book is Sherlock** (13 chapters, 13 notes,
105,335 words — one story per chapter, the shape her report was filed against) and, for a second
shape, **the field guide** (9 chapters, 34 short notes). Her *"sometimes"* is a RATE, so the
trials are numbered and every one is in the table, hits included.

| # | book · chapter clicked | where the page actually landed | verdict |
|---|---|---|---|
| 1 | Sherlock · 13 copper beeches (first click of the session) | *"…all those birds that went to the Alpha were town bred"* — **ch8 Blue Carbuncle**, mid-story | **MISS** (5 chapters short) |
| 2 | Sherlock · 13 again | *"'Thank you, Maggie,' says I"* — ch8, a little further | **MISS** |
| 3 | Sherlock · 13 a third time | **the pane is BLANK — not one word on the page** | **MISS** (the worst face) |
| 4 | Sherlock · 2 a scandal in bohemia | the heading at the top | hit |
| 5 | Sherlock · 7 the man with the twisted lip | the heading at the top | hit |
| 6 | Sherlock · 13 (from ch7) | *"'After all, Watson,' said Holmes, reaching up his hand for his clay pipe"* — ch8's end | **MISS** (5 short) |
| 6b | *(no click — 6 s later, the same state re-captured)* | **byte-identical**: the page does not correct itself, ever | — |
| 7 | Sherlock · 9 the speckled band | *"…the lens discloses a large number of hair-ends"* — ch8 | **MISS** (1 short) |
| 8 | Sherlock · 11 the noble bachelor | *"You must lock yourself up from him to-night"* — ch9 Speckled Band | **MISS** (2 short) |
| 9 | Sherlock · 5 the boscombe valley mystery | *"the music at St. James's Hall"* — ch3 Red-Headed League | **MISS** (2 short) |
| 10 | Sherlock · 12 the beryl coronet | the heading at the top | hit |
| 11 | Sherlock · 13 (from ch12's top) | *"…Twice my boy has asked her to marry him"* — ch12, mid-story | **MISS** |
| 12 | Sherlock · 1 about this text | the heading at the top | hit |
| 13 | Sherlock · 10 the engineer's thumb | the heading at the top | hit |
| 14 | Sherlock · 3 the red-headed league | the heading at the top | hit |
| 15 | Sherlock · 8 the blue carbuncle | the heading at the top | hit |
| 16 | **COLD** (quit · relaunch · open the book · Index · FIRST click) Sherlock · 10 the engineer's thumb | *"…the lady, who had stepped from her carriage, was the centre of a little knot of flushed and struggling men"* — **ch2 A Scandal in Bohemia** | **MISS (8 chapters short — the cold case is the worst)** |
| 17 | Sherlock · 13 (second click of the cold session) | *"you can ask the King of Proosia, for all I care"* — ch8 | **MISS** (5 short) |
| 18 | field guide · 9 keeping it private | the heading at the top | hit |
| 19 | field guide · 7 where things go | the heading at the top | hit |
| 20 | field guide · 3 takes (from ch7) | *"The next paragraph can't decide what it wants to be"* — ch2 writing | **MISS** (1 short) |

**THE RATE: 11 misses in 20 clicks.** Her *"sometimes"* is 55% on this store, and the misses are
not subtle — five of them put the page in a DIFFERENT STORY, one put it on a blank page, and the
worst (the cold first click, which is the shape she would meet on opening a book) missed by eight
chapters. **The direction is consistent in every one of the eleven: the page lands SHORT of the
chapter** — showing text that comes BEFORE it, which from the reader's side is *"a random
location in the text"* exactly as she says. *(Her words are "a fair amount under it"; what is
measured here is the mirror — the page comes to rest above the chapter, which puts her cursor's
chapter a long way DOWN the page from where the scroll stopped. Recorded as measured rather than
bent to fit the sentence: both are the one defect — the aim resolves against a column whose
geometry is not yet known — and neither direction is a different bug.)*

### THE MECHANISM, TRACED (piece 3) — measured twice, never assumed

**The road, read end to end** (`App/Variorum/Variorum/Features/BookView/BookIndexView.swift`):
a chapter row's `onTapGesture` sets `paneTarget = "sec-\(groupID)"`; the pane's
`.onChange(of: paneTarget)` calls `proxy.scrollTo("bip-\(target)", anchor: .top)` **once** and
immediately clears the channel. That is the whole landing. No settle, no report, no correction —
the surface the architectural trace calls **compensator 4** (`notes/plans/navigation-landing-architecture-trace.md`
§3), the one the 13u2b phase deliberately left to *"its next touch"*.

**EXPERIMENT 1 — is the page wrong from the first frame, or does it drift?** A capture burst
(five window captures, ~0.6 s apart) around one cold chapter click:

| capture | ~t | what the pane showed |
|---|---|---|
| 1 | 0.4 s | still at the book's top (*About this book*) — the scroll had not run yet |
| 2 | 1.0 s | ch8 Blue Carbuncle, mid-story — **the landing, already wrong** |
| 3 | 1.6 s | **byte-identical to capture 2** |
| 4 · 5 | 2.2 · 2.8 s | byte-identical |
| — | +6 s (trial 6b) | byte-identical |

So the page arrives wrong and STAYS wrong. There is no drift to catch and nothing to wait for:
the single aim is final.

**EXPERIMENT 2 — would a compensator converge?** The decisive one, run with zero code: click the
SAME chapter six times, 1.2 s apart (a hand-run of exactly what a settle loop does — re-aim at
the same anchor after the layout has had a moment), capturing after each.

| aim | where the page came to rest |
|---|---|
| 1 | ch8, *"'Thank you, Maggie,' says I"* |
| 2 | **blank page** |
| 3 | ch8 (further on) |
| 4 | ch8's last paragraphs, *"'After all, Watson,' said Holmes…"* |
| 5 | the seam into ch9 — *the adventure of the speckled band* heading visible mid-page |
| 6 | **the target exactly: *the adventure of the copper beeches* at the top of the page** |

**What that proves, and it is the unit's whole finding:** the column's geometry is discovered
INCREMENTALLY as rows realize, so each aim lands closer than the last and an aim repeated until
the target reports at the top CONVERGES. The Index has everything it needs to land correctly
except the thing that looks again. **The hypothesis the brief told me to test rather than assume
— that the book Index has not adopted `Surface/LandingAuthority` — is CONFIRMED by reading and
by measurement**: `grep -n LandingAuthority` over `BookIndexView.swift` is empty, and the
behaviour is exactly the un-watched aim's. *(And the converse is disproved: this is NOT a stale
anchor — the anchor is right, the aim reaches it, and a sixth aim at the SAME anchor lands it.)*

**Why the estimate is wrong in the first place** (the same reading, stated once so the fix is not
mistaken for a mystery): the pane is a `LazyVStack` of chapter headings and whole NOTES, and a
note row is ~40 pt tall until `observeBlockTOC` returns and then becomes thousands — Sherlock's
stories are eight to ten thousand words each. A lazy container answers *"how tall is a row I have
not realized"* with the average of the ones it has, and that average is taken over rows most of
which have not yet loaded their text. This is the trace's own cause (§1: *"every long lazy column
in the app discovers its row heights AFTER it has aimed"*) on the one surface that never got
either half of 13u2b's answer.

### THE RED-ON-OLD PIN (piece 4a) — written and measured BEFORE a line of the fix

`App/Variorum/VariorumTests/BookIndexLandingTests.swift` — two arms over a book long enough that
one frame cannot know its geometry (8 chapters, one note each, 100 short blocks a note). The
claim is one number: the target row's top in the pane scroll's own space, which is
visible-relative, so a landed row reads ≈ 0. The number comes from a DEBUG oracle this commit
adds beside the pane's existing ones (`BookIndexGeometry.paneAnchorTops`), fed by a geometry
report installed at the LAZY ROW's level — never inside it, which is the Outline's own row-47
lesson (`BookView.outlineAnchor`: an unrealized lazy row's inner views do not exist, so a report
from inside one is silence exactly when a landing needs it).

**THE RED RUN, three times on this tree** (`-only-testing:VariorumTests/BookIndexLandingTests`,
zero instances, nothing else running):

| run | `aLandingOnAFarNoteArrivesAtThatNotesTop` | `aLandingBringsTheChaptersHeadingIntoView` |
|---|---|---|
| 1 | **top = 667.9 pt** (≤ 2 owed) | **never reported at all** |
| 2 | **top = 667.4 pt** | **never reported at all** |
| 3 | **top = 667.4 pt** | **top = −41.2 pt** |

Stable red, both arms, 3/3 — and the second arm's *"never reported"* is the harness saying what
the app said in trial 3: the page is somewhere the target is not even realized.

**This commit contains NO FIX.** What it contains is the probe (DEBUG-only writes; the geometry
report itself is behaviour-free) and the two red pins, so the red is on the record before the fix
exists.

### THE FIX (piece 4) — the book Index adopts the ONE landing authority

**The shape, and it is the prescribed one** (13u2b's own sentence: *"Takes and the book Index adopt
at their next touch"*): the pane's one-shot `scrollTo` becomes a LANDING through
`Surface/LandingAuthority` — aim, hold, watch, correct, give up rather than chase — with a
`LandingPolicy.bookIndex` whose three non-Outline numbers were each measured first (the budget of
12 from the six-aim convergence, the 6-second watchdog from the same, and
`correctsAnUnreportedTarget: true` from the pin's own measurement that a missed target often never
realizes at all). Nothing was invented: the discipline, the seed, the signpost and the story are
the shared authority's, and this surface keeps only its own ACT (the unanimated `scrollTo`) and
its own facts.

**What moved, file by file:**

1. **`App/Variorum/Variorum/Surface/LandingAuthority.swift`** — `LandingSurface.bookIndex` (the
   closed type's third case, which is how the signpost's vocabulary stays closed) and
   `LandingPolicy.bookIndex` with the reasoning at each number that differs.
2. **`App/Variorum/Variorum/Features/BookView/BookIndexView.swift`** — the authority itself (with
   the DEBUG storyboard on the Outline's pattern), the pane's own `PaneLandingBox` (a reference
   box, never `@State`, so a content report cannot re-lay the column out — the Outline's
   `OutlineLandingBox` rule), the per-row geometry report at the LAZY ROW's level, the per-BLOCK
   report gated on the pending anchor, the whole-column listeners
   (`onScrollGeometryChange` → `contentChanged`, `onScrollPhaseChange` → `userTookOver`), the
   landing on `paneTarget`, and `landing.end()` on disappear.
3. **`App/Variorum/VariorumTests/LandingAuthorityTests.swift`** — the surface-count line moves
   2 → 3, which is what its own comment asks a third adopter to do (*"a third adds its case
   here"*).

**ONE PIN SHAPE WAS HOLLOW AND IS RECORDED AS SUCH** (the hallucination guard's rule, applied to
my own pin): the first version asked the LAST story of the book to come to the top of the page.
It measured 667 pt on BOTH trees — because a `scrollTo` CLAMPS at the end of the scroll, so the
last row can only reach the top when a whole viewport stands below it. That is the clamp, not the
landing. The pin now lands a MIDDLE row, where the claim is achievable, and the clamp is recorded
below as a deliberate limitation rather than papered over.

### WHAT THE FIX DOES IN THE APP (the measurement that decided the next piece)

Dev-store Debug build, Sherlock ▸ Index, the same gesture as the reproduction. **Every landing
that ran settled at the top**, and the app now SAYS so in her own Console — the content-free
signpost the authority emits in Release too:

```
landing surface=BookIndex rows=26 target=24 offset=-1 total=36084 derived=26 exact=0 hops=0 content=4 ms=1021 end=settled top=0
landing surface=BookIndex rows=26 target=12 offset=-1 total=69119 derived=26 exact=0 hops=3 content=6 ms=1768 end=settled top=0
landing surface=BookIndex rows=26 target=20 offset=-1 total=135737 derived=26 exact=0 hops=0 content=6 ms=1012 end=settled top=0
```

Twenty-one landings across two sessions, **every one `end=settled top=0`** — including the COLD
first click on the last chapter, which pre-fix missed by eight chapters. (`target=` is the row's
index in the column, so a chapter heading is an even number: ch13 = 24.)

**AND ONE CASE STILL FAILS, measured and recorded rather than smoothed over.** On a COLD column —
the seconds after a book is opened, while the notes' text is still arriving and the column's own
height is climbing (90,859 → 100,490 pt during this one landing) — a landing can stall:

```
landing surface=BookIndex rows=26 target=16 offset=-1 total=216381 derived=26 exact=0 hops=12 content=1 ms=6036 end=gaveup top=-9999
```

`top=-9999` is the authority's word for *the target never reported at all*. The verbose story says
why, and it is worth quoting because it is the residual's whole mechanism:

```
LAND target=16 | content=90859 | offset=36663 | row 72F6 top=-4013 | offset=36727 | row 72F6 top=-4077
| HOP 1 at 306 ms (top was 279.4) | offset=36790 | … | HOP 12 at 3231 ms (top was 279.4)
| DONE: gave up at top=279.4 after 12 hops, 6094 ms
```

The page CREEPS — 60 pt at a time, between the hops and not because of them — as rows above the
viewport finish loading their text and the scroll view keeps its visible content still. The
target's own line never appears: it is never realized, so it never reports, and the hops are
issued blind against a column whose geometry is being discovered faster than the loop can aim.
**This is the architectural trace's §1 exactly** (*"every long lazy column in the app discovers its
row heights AFTER it has aimed"*) — and the trace's own answer to it is not more compensation but
§5(b), heights KNOWN before the aim.

### THE BEHAVIOURAL REVERT (piece 4b) — is the improvement the AUTHORITY's, or my probe's?

**Why this measurement had to be made.** The fix's diff contains TWO things: the landing authority,
and the geometry reports that feed it. Geometry observers on a lazy container's rows can change
how eagerly that container measures — so "the landing got better" could have been the probe's
side effect rather than the authority's work, and a fix nobody can attribute is not a fix. The
brief's own words: *behavioural-revert verified*.

**How.** `git worktree add /tmp/f1-probe-only feb2d5d0` — this unit's own probe-only commit: the
reports and the named coordinate space are IN, the authority is OUT, the pane aims once. Built
into its own DerivedData and run alone (the dev-store instance quit by identity first; one
instance at a time, the 13u3 UNIT E walker law).

| her gesture, same ys, same book | the REVERTED tree (probe only) | this unit's tree |
|---|---|---|
| COLD first click, ch13 copper beeches | *"This gentleman, Mr. Wilson, has been my partner"* — **ch3 Red-Headed League, ten chapters short** | the heading at the top (`hops=0 end=settled top=0`) |
| ch2 a scandal in bohemia | the heading at the top | the heading at the top |
| ch10 the engineer's thumb | *"Hotel Cosmopolitan Jewel Robbery"* — **ch8, two short** | the heading at the top |
| ch12 the beryl coronet | *"…lived in Brixton Road, where she fattened fowls"* — **ch8, four short** | the heading at the top |

**And the pins, run on both trees with the same fixture** (the final shape — a middle row, 8
chapters × 40 blocks):

| run | `aLandingOnAFarNoteArrivesAtThatNotesTop` | `aBlockLandingDeepInTheBookArrivesAtThatBlock` |
|---|---|---|
| REVERTED, run 1 | **8667.5 pt off** | **never reported** |
| REVERTED, run 2 | **4077.5 pt off** | **never reported** |
| this tree, run 1 | **0.04 pt** ✓ | **0.24 pt** ✓ |
| this tree, run 2 | **0.00 pt** ✓ | **0.23 pt** ✓ |

**RED ON OLD, GREEN ON NEW, and the credit goes where the measurement puts it: the authority.**

*(The fixture is 40 blocks a note rather than 100, and the reason is measured and recorded rather
than tuned-until-green: at 100 blocks the harness's column is still CLIMBING while the landing
runs — the cold-column residual named above — and both trees fail, which is not evidence of
anything. At 40 the column settles inside the landing's own hold, which is the state the app is in
whenever she has been reading a book for a few seconds, and the two trees separate cleanly. The
100-block measurements are kept in this record because they are how the residual was found.)*

### ROW 56, ADJUDICATED BY THE PAIRED INTERLEAVED PROTOCOL (piece 5) — not waved off

`BookIndexEditingTests.theReadClickLandsInIndexAtThatBlock` is `KnownIssuesAndTechDebt` row 56's
load-flaky test, and the phase's baselines say to treat a red there as that condition **unless the
diff touches the book Index. THIS ONE DOES** — so the brief makes the paired protocol mandatory,
and it was run before any claim was made about it, in either direction.

**How:** a worktree at this unit's OPENING COMMIT (`79509c57` — the brief's own commit, zero of
this unit's code) beside this tree, each built into its own DerivedData, the suite run ALTERNATING
base → mine → base → mine → base → mine, nothing else running.

| round | the opening commit | this tree |
|---|---|---|
| 1 | **RED** — `(live.count → 0) == 1`, the pane identifier nil | **RED** — byte-identical |
| 2 | **RED** — same | **RED** — same |
| 3 | **RED** — same | **RED** — same |

Six runs, 7 tests each; the OTHER SIX tests of the suite passed in every run on both trees. The
failure signature is byte-identical to the one row 56 records (*"every failure exhausts the budget
with ZERO editable panes"*), and it is identical on a tree that contains not one line of this
unit's work. **VERDICT: row 56's recorded condition, unchanged by this diff — neither caused by it
nor fixed by it.** (Row 56's own warm-DerivedData covariate is consistent with these runs: all six
ran against warm DerivedData, where the row says it fails. The fresh-DerivedData first-run arm was
NOT re-run here — it is row 56's own experiment, measured at 13u3 UNIT G on two trees, and
re-running it costs a full clean build per tree without changing this adjudication.)

### THE POLICY, MEASURED INTO ITS FINAL SHAPE — and the residual's verdict

The first policy this unit wrote was the Outline's numbers with a bigger budget. **Measurement
retired it**, and the record keeps the road because the reasoning is the finding:

| what was tried | what the app did (cold Sherlock, the deepest chapter) |
|---|---|
| budget 12 · `.quiet` · blind corrections allowed | `gave up at top=12191 after 12 hops, 6199 ms` — and the offsets show what those hops DID: 45k → 59k → 63k → 80k → 95k. Twelve visible jumps, ending further out than the first aim |
| budget 8 · `.spacedByTheHold` (the flow's pace) · blind allowed | `gave up at top=12191 after 8 hops, 10168 ms` — slower, no better |
| **budget 3 · `.spacedByTheHold` · NO blind corrections** (shipped) | `gave up at top=10005 after 3 hops, 6128 ms` — **bounded**, and the good cases are untouched: every warm landing still `settled at top=0.0 after 0 hops` |

**Why the third shape is the honest one.** The verbose story of a failing landing says the aim is
not the problem:

```
LAND | content=56497 | offset=39125 | TARGET top=0.19        ← the first aim is EXACT
| content=39273 | offset=38338 | TARGET top=787.69           ← the column SHRANK under it
| HOP 1 | content=51243 | TARGET top=187.69 | content=39273 | TARGET top=787.69   ← and oscillates
| content=61120 | content=143438 | … | TARGET top=12191      ← and then trebles
```

The column's own height moved 39k → 56k → 143k → 80k → 115k inside six seconds, because a row of
this pane is a whole note that stands at ~40 pt until its text arrives from the store and at
thousands afterwards. **No pace and no budget can win that** — which is the architectural trace's
own §1 finding and its own §5(b) answer: *heights known before the aim*. So the policy's job is
narrowed to what a compensator can honestly do: correct a target it can SEE, a few times, from
quiet — and when it cannot see the target, stop and SAY SO rather than fling the page at a guess.

**THE RESIDUAL, STATED PLAINLY (this is the unit's stop-and-report line):** on a COLD column — the
first seconds after a book is opened, while the notes' text is still arriving — a deep chapter
click can still land short, and the signpost says so (`end=gaveup`). Measured rate on the cold
deep click: **2 of 5 stalled**; every warm landing measured (21 of 21) settled at the top. The fix
for the residual is not more compensation: it is the OTHER half of 13u2b's answer — the book
Index's note rows standing at heights derived from their blocks' lengths
(`ProseHeightModel`/`FlowHeightEstimate` over `Queries.blockExtents`, the brains the Outline and
the flow already consume), so the column stops moving under the landing. **That is 13u2b UNIT 1's
shape on a new surface, and per this brief's own stop rule it is the architect's to rule rather
than this unit's to start.**

### EVIDENCE — THE WALK (piece 6; the unit closes on USE, not on pins)

**Build:** `App/Variorum/DerivedData/13u4f1/Build/Products/Debug/Variorum.app`
(`io.lduarte.Variorum.debug`, the fenced dev store). `pgrep -fl 'Variorum.app/Contents/MacOS'` was
checked at the start and after every quit — **ZERO instances of hers at any point; she was not
running** — and every dev instance was quit **by identity**
(`tell application id "io.lduarte.Variorum.debug" to quit`), never by a keystroke (the 13u3 UNIT D
walker law). One moment produced TWO dev instances of my own (a quit refused while the ⌘K palette
was up, then `open -n`); the extra was killed **by PID** on a pid `pgrep` proved was mine (the
13u3 UNIT E rule), never by identity, which cannot tell two instances apart.
`/Applications/Variorum.app` was never touched. Captures: `notes/plans/13u4-screens/f1/`
(gitignored) — 198 files: a full window per step plus a `-top.png` crop of the pane's first inches,
which is what each row below reads.

| # | step | what the app did | capture |
|---|---|---|---|
| 1 | **Before** — the whole reproduction series above, on the pre-fix build | 11 misses in 20 chapter clicks; one blank page | `t01…t20` |
| 2 | **Before, isolated** — the probe-only revert | 3 misses in 4 | `r01…r04` |
| 3 | Terminal voice, light: **ch13 copper beeches** (warm) | **the heading at the top**, `settled at top=0.0 after 0 hops, 1142 ms` | `X01-T-ch13-top.png` |
| 4 | Terminal, light: **ch5 the boscombe valley mystery**, captured at 1.5 s AND at 6 s | **the heading at the top in BOTH** — the landing arrives and HOLDS; nothing drifts afterwards | `Y01-T-ch05-at1.5s-top.png`, `Y01-T-ch05-at6s-top.png` |
| 5 | Terminal, light: **ch13 again**, both captures | the heading at the top in both | `Y02-T-ch13-at1.5s/at6s` |
| 6 | Terminal, light: ch11 · ch2 · ch10 · ch12 · ch3 | every landing `settled at top≈0 after 0 hops` | `W03…W05`, `X03`, `X04`, `p02…p07` |
| 7 | **STUDY voice** (Settings ▸ Appearance), ch13 then ch5 | the serif voice lands identically — the chapter heading at the top, `settled top=0.24` / `top=-0.07`, 0 hops | `Z01-STUDY-ch13-at6s.png`, `Z02-STUDY-ch05-at6s.png` |
| 8 | **DARK** (`appearanceChoice dark`, relaunch) in the Study voice | the black room lands the same way: the note's title at the top, `settled top=0.13 after 0 hops` | `D02-DARK-STUDY-ch05-at6s.png` |
| 9 | **THE RESIDUAL, IN USE** — the COLD first deep click of a session (dark, and again in Terminal) | `gave up at top=10337 after 3 hops, 6233 ms` — the page stops short of the chapter, and the signpost SAYS so | `D01-DARK-STUDY-ch13-at6s.png`, `W01-T-ch13-top.png`, `p01-cold-ch13-conservative-top.png` |

**Dev-store state left as found:** the voice back to **Terminal** (verified in Settings ▸
Appearance, capture `restore`), `appearanceChoice` back to **system** (verified by `defaults
read`), **zero instances**. No note, book, chapter or setting in the dev store was edited by this
walk — every gesture in it is a click on a chapter name.

**A walker fact for `Tools/WalkKit/README.md` at its next touch:** a `cliclick` click into the dev
window is sometimes swallowed even after an explicit System Events activation — the click
ACTIVATES and does not act, so the step silently does nothing and the next capture reads as "the
app ignored it". Clicking TWICE (`cliclick c:x,y w:400 c:x,y`) makes a walk step reliable, and on
a row whose act is idempotent (a chapter click re-aims at the same chapter) the second click costs
nothing. Three of this walk's steps were lost to the single-click form before it was diagnosed.

### SEAM FILES THIS DIFF TOUCHES (the ladder's Fable reviewer reads this list)

**NONE — said explicitly, as the brief asks.** `BlockRangeIndex`, `EditorTextView`,
`TypedReturn`, `PaneTextAuthority`, `EditorViewModel`, `EditorSurfaceController`, `runStructural`
and its identity oracle, `StructuralSeamEdit`, `StructuralGesturePlanner`, `MarkdownActs` — not
one of them is in the diff. **`Sources/VariorumCore/` contains ZERO files of this unit** (verified
by name over the whole diff), so `Sync/`, the schema, the migrations and `Server/` are untouched by
construction, no core run was owed, and **no `Shared/` file moved**, so the iOS build is not owed
either (the standing convention). The marker stays **8**.

**The whole unit is four source files and two notes files:**

- `App/Variorum/Variorum/Surface/LandingAuthority.swift` — **the shared authority**: one new
  `LandingSurface` case and one new `LandingPolicy`. Not one line of the decision, the runner, the
  seed, the signpost or either shipped policy was changed; the Outline's and the flow's numbers
  are byte-identical, and their landing suites ride UNMODIFIED and green (13 + 9 tests).
- `App/Variorum/Variorum/Features/BookView/BookIndexView.swift` — the adoption (the authority, the
  reference-box bookkeeping, the row and block reports, the two column listeners, the landing on
  `paneTarget`, `end()` on disappear) plus the DEBUG oracle and story.
- `App/Variorum/VariorumTests/BookIndexLandingTests.swift` (new, 2 pins) and
  `App/Variorum/VariorumTests/LandingAuthorityTests.swift` (the surface-count line 2 → 3, which is
  what its own comment asks a third adopter to do).
- `notes/QUESTIONS.md` (#129) and `notes/KnownIssuesAndTechDebt.md` (the residual's row).

### CLOSING RUNS (at the unit's END — never the full suite at the start)

| Run | Command (from `App/Variorum/`) | Result |
|---|---|---|
| **Mac** — the two new suites, every landing/Index/Outline/flow suite this diff can reach, the mode-switch carry, the prose column, AND the acceptance spine under its ELEVEN REAL TYPE NAMES (the `-only-testing` file-name trap, met by every prior unit of this phase) | `xcodebuild test -scheme Variorum -destination platform=macOS` with `-only-testing:` for `BookIndexLandingTests` · `LandingAuthorityTests` · `BookIndexColumnTests` · `BookIndexEditingTests` · `BookRedesignMountTests` · `BookOutlineLandingTests` · `BookOutlineRowsTests` · `ReadingFlowLandingTests` · `BookHeightManifestTests` · `BookOutlineCostTests` · `ReadLandingTests` · `ShellLandingTests` · `ModeSwitchCarryTests` · `IndexProseColumnTests` + the eleven `Tutorial*` types | **148 tests in 24 suites, 2 issues — BOTH of them row 56's ONE adjudicated test** (`theReadClickLandsInIndexAtThatBlock`, two expectations). Everything else green, the spine included |
| The same selection WITHOUT that one suite | as above, minus `BookIndexEditingTests` | **141 tests in 23 suites PASSED** (exit 0, no skips) |
| **The row-49 Outline arm**, which appeared once under this unit's 13-suite load (`abs(top) → 3424.0`, the exact value the flake list records) | the paired interleaved protocol: base ↔ mine, isolated ×2 each, then the same multi-suite LOAD on both | **green on both trees, 2/2 isolated; green on both under load** — the recorded load-flaky arm, not this diff |
| **Core** — NOT OWED: `git diff --name-only` over the whole unit lists **zero files under `Sources/`** | — | n/a |
| **iOS** — NOT OWED: no `Shared/` file moved, nothing mobile-visible (this is a Mac surface) | — | n/a |

No full-suite run was made at this unit's start; the plan's closeout-refresh baselines stand as the
baseline (the standing rule).

### JUDGMENT CALLS (each one a reviewer can reverse in a line)

1. **The unit SHIPPED the adoption and STOPPED at the manifest.** The brief prescribes the
   adoption (*"adopt, don't fork"*) and stops the unit at a 13u2b-class problem bigger than one.
   Both clauses fired: the adoption is real and measured, and the residual is the other clause's
   case, with its mechanism, its rate and its named remedy in the KnownIssues row. Reversing means
   ruling the heights half INTO this phase — which is a unit, not a line.
2. **All three pane targets go through ONE landing** — chapter, note and block. A surface with two
   landing roads is the fork the hoist exists to prevent, and the block road (row 38's Read-click
   through-door) has the same one-shot aim the chapter road had. Reversing: route `onLandedBlock`
   back to a bare `proxy.scrollTo`, which is two lines.
3. **A BLOCK's geometry report is gated on the pending anchor; a ROW's is not.** A realized story
   is hundreds of blocks and every one of them reports on every layout pass, so recording them all
   would grow the authority's seed by the corpus rather than by the rows it lands on. The gate
   keeps what is needed (a block landed on once keeps its seed). Reversing: drop one `guard`.
4. **`LandingFacts.derived` is set to the ROW COUNT, not 0.** This pane has no height manifest, so
   not one row's height is known before it is realized; `derived=0` would tell her Console the
   opposite of the truth, and `offset=-1` says the same thing about the arithmetic this surface
   cannot do. Reversing: two literals.
5. **A target that cannot be topped spends its budget and ends at the watchdog** — deliberately NOT
   short-circuited on "the scroll is at its end". During a landing on this surface "at the end" is
   often a LIE told by a column whose rows have not realized (measured: content 12,040 → 7,630 pt
   mid-landing), so ending early there would freeze the page in the wrong place. The honest cost
   is a few invisible corrections when the last row of a short book genuinely cannot reach the top.
6. **The first pin shape was HOLLOW and is recorded as such** rather than quietly rewritten: it
   asked the LAST row to come to the top, which a clamped `scrollTo` can never do, and it measured
   667 pt on both trees.
7. **No `Sources/` change was needed and none was made.** The brief's stop condition on core was
   checked and never came close: this is scroll geometry on one Mac surface.
8. **Old DerivedData caches were deleted to finish the work** (`13u1u2`, `13u2b`, `13u2e`,
   `pre13x-b0` and their siblings — nine closed units' build caches, 18 GB): the volume hit 736 MiB
   free mid-unit and a build failed on it. Pure caches, regenerated on demand, no repo content.

### CARRIED TO THE PHASE CLOSEOUT (from this unit)

1. **THE HANDED-UP ITEM, and it is the reason this record is long:** the book Index pane wants the
   OTHER half of 13u2b's answer — its note rows standing at heights derived from their blocks'
   lengths, so the column stops moving under a landing. The KnownIssues row carries the mechanism,
   the rate, the brains it would use (`ProseHeightModel`/`FlowHeightEstimate` over the cached
   `Queries.blockExtents`) and the precedent (13u2b UNIT 1 did exactly this for the Outline). The
   architect rules whether it runs in this phase.
2. **QUESTIONS #129** joins her ratify bundle — should the app SAY anything when a chapter click
   cannot reach its chapter (shipped: silence; the alternatives are a refusal or a quiet retry).
   Next free moves to **#130**.
3. **A WALKER FACT** for `Tools/WalkKit/README.md` at its next touch: a single `cliclick` click
   into the dev window is sometimes swallowed by the activation, so a walk step should click twice
   (`c:x,y w:400 c:x,y`) on any row whose act is idempotent; three steps of this walk were lost
   before it was diagnosed. And: `/usr/bin/log show --predicate 'eventMessage CONTAINS "landing
   surface"'` is how the shipped signpost is read back, but a script that greps its own command
   line out of the log must filter `end=` — the `log show` process's own arguments appear in it.
4. **Nothing in `notes/KnownIssuesAndTechDebt.md` was CLOSED by this unit**; one row was opened
   (the residual). Row 56 stands, re-measured and unchanged.

### WHAT A FRESH SESSION WOULD NEED TO FINISH THIS

Nothing — the unit is closed on a shipped fix, a walked acceptance and an honest residual.
Everything is committed and pushed: the policy and its measured reasoning, the adoption, the two
pins (red-on-old in a worktree, green here), the DEBUG oracle and story, QUESTIONS #129, the
KnownIssues row, the walk captures (gitignored, listed above) and this record. What is OPEN is
**the architect's**: whether the manifest half runs now, and **hers**: #129.

---

## UNIT S1 BRIEF — THE SETTINGS SHAPE (items 4 · 5 · 6 · 7 + row 59 + the 2a Settings fork + row 53's walk; self-contained — read in this order)

**Read first, in full:** (1) this file's Status banner · HER ADDITIONS items 4, 5, 6 and 7
(verbatim — they are the mandate) · THE SIZING-AND-RULINGS SITTING RECORD (no ruling
pre-decides these — they are face rows; R-13u4-6 is the cast) · THE LEDGER · ENVIRONMENT
TRAPS · CAST & DISCIPLINE · the six prior UNIT RECORDs (every walker fact binds — the
osascript staging, the double-click-on-idempotent-rows fact, the capture-offset arithmetic).
(2) **The restyle mandate:** roster item 1 + the carried 2026-08-31 addendum — every surface
you open conforms to the committed reference artifact
`notes/plans/pre-13u-mockups/blocks-and-snippets.html` (spacing scale, squarish-rounded
controls, calm cards over hairline grids); `Theme/CalmGrammar.swift` is the vocabulary. The 2a
fork you execute here: the Settings panes' card grammar. (3) **KnownIssues rows 59 and 53**
(row 59: the 18j appearance control renders BELOW THE FOLD at the shipped window size — her
own owner assignment; row 53: once your shape makes the inline-comments and paragraph-gap
controls reachable, WALK the full-document editor's two unexercised re-font occasions — if
either reproduces a blank region, REPORT it with the capture, do not build the carve: that
design is 13u2 UNIT D's record's). (4) The constitution's **P-1** (doors render FROM the
registry; the ⌘/ Shortcuts & Dictionary helper and the menus carry the legibility mandate)
and **P-8** (every NEW chrome `fixedSize` text carries a `lineLimit` — the 27 OLD sites are
S3's sweep, not yours). (5) The code: the Settings scene and its panes · the shortcuts
helper + the capability registry (item 7's fix is making the faces SAY the chord the registry
already knows) · the keybind map (item 5's audit). Do your own reading.

**The build, per item:**
- **Item 6 (the restructure):** her sketch verbatim — *"an overall one, then maybe tabs on
  text editing shortcuts, window / reshaping shortcuts, etc."* The exact tab set is yours to
  shape from what the panes actually hold, recorded as PROVISIONAL with the alternatives; the
  card grammar per the reference artifact rides the same pass. Row 59's fold dies here: the
  appearance control must be reachable at the shipped window size WITHOUT scrolling hunts —
  prove it in the walk.
- **Item 4 (settings search):** simple text search within Settings — her acceptance case is
  literal: *"it's too hard to find how to make a callout"* — typing "callout" must surface the
  callout-relevant controls/rows. One pure filter brain, pinned; no new storage.
- **Item 5 (⌘[ + unindent):** an AUDIT first, in the record: what ⌘[ is bound to today (her
  report says note navigation), where 13k's unindent door lives, and what the two Mac
  conventions are (editor outdent vs back-navigation). **A rebind is a product-flavoured
  call:** implement the most spec-defensible answer as PROVISIONAL with the alternatives in
  QUESTIONS (from **#130**) — and whatever you pick, the registry, the menus and the ⌘/
  helper must say it truthfully (the legibility mandate). The discoverability half —
  formatting shortcuts findable — lands in item 6's "text editing shortcuts" tab regardless.
- **Item 7 (the merge chord is nowhere said):** the registry knows ⌘⇧M; make the faces say
  it — the ⌘/ helper's list and the menu rows that carry the act. A truth pin per face (the
  H pattern: prose names a chord ⇒ a pin asserts the surface renders it).
- **ThemeStore stays where it is** — the recorded waiver stands (a hoist is a DESIGN, the
  mobile parity row carries it); touch its chrome, never its home.

**Evidence:** the walk — both voices AND both appearances, captured: the tabs, the search
finding "callout", the appearance control reached without a hunt, the merge chord visible in
the helper and the menu, and row 53's two re-font occasions exercised (result recorded either
way). Pins: the search brain's arms · the chord-truth pins · the registry walk green. The
touched Mac suites + the acceptance spine (REAL TYPE NAMES) at the end. Captures to
`notes/plans/13u4-screens/s1/`. PROVISIONALs from **#130**.

**Your record:** append a `## UNIT S1 RECORD` section to THIS file with LIVE STATUS from the
FIRST commit (PENDING marks), the ⌘[ audit table, the tab-set rationale, row 53's walk result,
and the seam-file list (expected NONE — say so); flip the ledger's S1 row and the rows-59
resolution note in your closing commit (KnownIssues row 59 closes here if the walk proves it;
row 53 closes or narrows per what the walk shows). The checkpoint protocol binds from the
first commit.

## UNIT S1 RECORD — THE SETTINGS SHAPE (items 4 · 5 · 6 · 7 + row 59 + the 2a Settings fork + row 53's walk)

**WHAT THIS UNIT DID NOT DO (the record's first line, written at the open and RE-STATED at the
close against what actually shipped):** *(opening statement — the closing re-statement rides the
last commit)*

- It does not touch `Sources/VariorumCore/` — no core, no `Sync/`, no schema, no migration, no
  `Server/`; the lockstep marker stays **8**. Settings is chrome over settings that already exist.
- It does not touch the EDITOR SEAM — `BlockRangeIndex` · `EditorTextView` · `TypedReturn` ·
  `PaneTextAuthority` · `runStructural` and its identity oracle are all outside this unit.
- It does not move `ThemeStore`'s HOME (the recorded waiver — KnownIssues' forked-brains row, the
  18g ladder's R1-3: a hoist there is a DESIGN, not a move, and the mobile parity row carries it).
  Its CHROME is fair game; its address is not.
- It does not sweep the 27 old chrome `.fixedSize()` sites (R-13u4-5 gave them to **UNIT S3**).
  Every NEW chrome `fixedSize` text this unit writes carries a `lineLimit` (P-8).
- It does not build row 53's re-font carve. The brief's rule is WALK-and-REPORT: the two
  unexercised occasions are exercised once this unit's shape makes their controls reachable, and
  what the walk shows is recorded either way. The carve's design is 13u2 UNIT D's record's.
- It does not do S2's or S3's rows (the Library/masthead faces; the chrome singles).

### LIVE STATUS (flipped in the same commit as each piece; unverified claims say PENDING)

| # | Piece | Status |
|---|---|---|
| 1 | The record + the READING + the two AUDITS (⌘[ · the merge chord), traced in the code rather than assumed | DONE (this commit) — the tables below |
| 2 | The Settings SHAPE: her tab sketch built, the card grammar, **row 59's fold dead** | DONE (this commit) — nine panes beside a search field; the walk's proof of the fold is piece 6 |
| 3 | Item 4 — the SEARCH: one pure brain + the catalog it reads + the results face + pins | DONE (this commit) — **46 tests in 3 suites passed**, her literal "callout" case first among them |
| 4 | Item 7 — the merge chord (and its three hard-coded siblings) SAID on the faces + truth pins | DONE (this commit) — **66 tests in 4 suites passed**; the red-on-old measurement is piece 4b |
| 4b | The BEHAVIOURAL REVERT — are the pins measuring the CHORD or the refactor? (a worktree with the four literals put back) | DONE (this commit) — **5 of 7 RED on the reverted tree, the 2 guards green**; the revert's own dump is the defect, printed |
| 5 | Item 5 — the ⌘[ answer (PROVISIONAL) + QUESTIONS #130 | DONE (commit 4) — the swap, its sweep, and every face that says it |
| 6 | The WALK on the dev-store Debug build, both voices AND both appearances, captured — **including row 53's two re-font occasions** | DONE (this commit) — 48 captures; **row 59 DEAD**, **row 53 REPRODUCES on BOTH occasions**, and the walk caught a word no pin could |
| 7 | Closing suites + the ledger's S1 row + the KnownIssues rows (59 · 53) | NOT-STARTED |

### THE READING (done in this session's own context, in the brief's order)

1. This file's **Status banner** · **HER ADDITIONS items 4, 5, 6 and 7** verbatim · **THE
   SIZING-AND-RULINGS SITTING RECORD** (R-13u4-5 hands the 27 `fixedSize` sites to S3; R-13u4-6 is
   the cast and the order; no ruling pre-decides items 4/5/6/7 — they are face rows) · **THE
   LEDGER** · **ENVIRONMENT TRAPS** · **CAST & DISCIPLINE** · the **six prior UNIT RECORDs**
   (E1 · E2 · E3 · C1 · C2 · F1) in full. The walker facts that bind this unit:
   - `cliclick -w <ms> t:"…"` **drops characters** in the shelf's quick-entry bar, and ⌘A does not
     select there; `osascript … keystroke` + `key code 36 using shift down` is the staging road,
     and **every burst needs an explicit re-activation** because a capture steals focus (E3).
   - The capture boxes **substitute typed quotes** (U+201D) — a quoted string read from a
     screenshot cannot be trusted; read the AX value and `xxd` it (C1).
   - The shelf's row heights differ between the voices, so the quick-entry bar's y moves ~70
     screen points on a voice flip — re-read it from a capture after every flip (C1).
   - A full-screen `screencapture -x -o` is in SCREEN PIXELS with no window offset (point = px/2);
     `walk-cap`'s WINDOW capture needs the window's Y added back (point = px/2 + 33). Mixing the
     two puts a click a bar-height off, silently (C2).
   - A single `cliclick` click into the dev window is **sometimes swallowed by the activation** —
     click TWICE (`c:x,y w:400 c:x,y`) on any row whose act is idempotent (F1).
   - Quit **by identity** (`tell application id "io.lduarte.Variorum.debug" to quit`), never ⌘Q
     (the 13u3 breach's walker law); kill a SECOND dev instance by a `pgrep`-proven PID only.
2. **The restyle mandate:** roster item 1 + the carried 2026-08-31 addendum (her ruling that
   `notes/plans/pre-13u-mockups/blocks-and-snippets.html` is *"an actual guide"*), and
   `Theme/CalmGrammar.swift` — `CalmCard` (radius 10, 14×11 padding, `card` on `line`),
   `CalmSectionHeader` (a quiet small-type header, never a `List` section header, whose fixed
   height is what clipped the tray), `CalmButtonStyle` (radius 7, squarish-rounded, generous).
3. **KnownIssues rows 59 and 53**, in full, with their provenance (59 is her own owner
   assignment: *"you can add the fold issue to 13u4"*; 53 is 13u2 UNIT D's narrowed claim —
   *the voice-switch occasion does not reproduce*, and the inline-comments and paragraph-gap
   occasions were NOT exercised because their controls sit below the fold).
4. The constitution's **P-1** (doors render FROM the registry; gating is data, never per-view
   if-statements; the registry walk asserts declared ⇔ rendered) and **P-8** (every chrome
   `fixedSize` text carries a `lineLimit`), plus P-1's application note (the registry's scope is
   the ROUTED vocabulary, grown incrementally).
5. The code: `Features/Settings/AppSettingsView.swift` (the `TabView` and its five tabs; the
   `AppearancePane` `Form` and its five sections), `AppearanceChoiceRow.swift`,
   `PaletteSettingsRow.swift`, `VariorumApp.swift`'s `Settings` scene,
   `Features/Help/HelperView.swift` (the hand-maintained `groups` + `entries` and their drift
   guard), `Registry/Capability.swift` (`menuTitle()` — the ONE chord formatter),
   `Registry/CapabilityRegistry.swift`, `EditorCommands.swift` (`keyEquivalent(for:)` — the ONE
   key wiring, and the Block menu), `CommitBar.blockMenu`, `EditorViewModel.contextMenuItems()`,
   `TakesBottomBar.structuralBar`.

### AUDIT 1 — WHAT ⌘[ IS BOUND TO TODAY, AND WHERE UNINDENT LIVES (item 5, the brief's AUDIT FIRST)

*(Her report, verbatim: "command [ is moving me between my different open notes ? is that supposed
to do that? I thought it unindented things. related - how are things unindented? that's further
proof that I need a better formatting shortcut menu.")*

| Question | Measured answer (file:line) |
|---|---|
| What is ⌘[ bound to? | **`.navigateBack`** — `EditorCommands.keyEquivalent(for:)` `case .navigateBack: ("[", .command)` (`EditorCommands.swift:223`), wired at the View menu's row (`EditorCommands.swift:728–730`). ⌘] is `.navigateForward`. |
| Is that "moving me between my different open notes"? | **Yes, exactly.** It is the PANE's back/forward trail (13f batch 3, W16), so pressing it while writing walks her back to the note she came from. Her description is accurate, not a misreading. |
| Was the binding swept? | **Yes, and recorded at the line** (`EditorCommands.swift:216–222`): *"⌘[ and ⌘] are FREE — swept across this table, every `.keyboardShortcut(` call site in `Variorum/` and `Shared/`, every `NSMenuItem` keyEquivalent (all empty strings), and the one `performKeyEquivalent` override (⌘S only). No bracket character is bound anywhere in the app, and they are the platform's own back/forward idiom."* |
| Where does unindent live? | **`.formatOutdent`** — `Format ▸ Outdent` (`EditorCommands.swift:711`) and **⇧Tab inside a list** (13k K8). `.formatIndent` is `Format ▸ Indent` and Tab. |
| Does unindent have a chord? | **No, DELIBERATELY** — `Capability.swift:598–604`: *"declared like the keyless five, and deliberately WITHOUT a `shortcutLabel`: Tab is not a menu key equivalent and must never become one (⇥ as a menu chord would steal Tab from every control in the app), so the keys live where ⏎'s does — in the surfaces' own `insertTab`/`insertBacktab` overrides."* |
| Is the pair findable today? | **Only in the ⌘/ helper**, as one prose row in the Formatting group (`HelperView.swift:138–140`): *"Tab / ⇧Tab in a list — indent / outdent the list item you're in (Format ▸ Indent and Format ▸ Outdent do the same); outside a list, Tab is the key it always was."* It is the ONE written line, and the registry's drift guard structurally cannot see it (Tab has no `shortcutLabel`), which is why only prose carries it. |

*(The two Mac conventions, the PROVISIONAL and its alternatives: piece 5's section below.)*

### AUDIT 2 — WHERE THE MERGE CHORD IS SAID, AND WHERE IT IS NOT (item 7)

*(Her report, verbatim: "where is the merge shortcut said ?? I don't see it in the shortcuts list
or in the menu. it only shows up as shift command M if you try merging w takes on blocks that
don't have takes - then the command shortcut shows up & is helpful.")*

**The registry knows it:** `.merge` declares `shortcutLabel "⌘⇧M"`, and
`EditorCommands.keyEquivalent(for:)` wires `("m", [.command, .shift])` — one act, one key, one
place to collide (P-1).

| Face | Says ⌘⇧M today? | Mechanism |
|---|---|---|
| The ⌘/ helper, Structure group | **YES** — `("⌘⇧M", "merge blocks — every take comes along")` (`HelperView.swift:105`), and it has said so since the helper was born (2db2a0b3, Sitting 9). | Hand-maintained prose held to the registry by `everyDeclaredShortcutIsFindableInTheHelper`. |
| Menu bar ▸ Block ▸ Merge | **YES** — `.keyboardShortcut("m", modifiers: [.command, .shift])` (`EditorCommands.swift:475`); AppKit renders "⇧⌘M" on the item. | SwiftUI's own chord rendering. |
| **Write's bottom bar `block ▾` ▸ Merge** | **NO** | `CommitBar.blockMenu` renders the four plain structural rows from **hard-coded literals** — `Button("Divide")`, `Button("Extract")`, `Button("Make Block")`, `Button("Merge")` — while the two ceremony rows beside them are built from `CapabilityRegistry.capability(…).menuTitle()`, which APPENDS the chord. |
| **Write's right-click context menu ▸ Merge Blocks** | **NO** | `EditorViewModel.contextMenuItems()` — same shape: `item("Merge Blocks", .mergeBlocks)` is a literal; `.divideWithCeremony`/`.mergeWithCeremony` beside it use `menuTitle()`. |
| **The Takes bar's `block ▾` ▸ Merge** | **NO** | `TakesBottomBar.structuralBar` — same shape again: `("Merge", .merge, …)` is a literal beside `CapabilityRegistry.capability(.mergeWithCeremony).menuTitle()`. |
| The fanned-merge note | **YES** — `FannedDefaults.ceremonyUnfannedNote`: *"These blocks have one take each — ⌘⇧M joins them."* | **This is her one sighting, named exactly:** *"it only shows up as shift command M if you try merging w takes on blocks that don't have takes."* |

**The mechanism, stated as a defect rather than an absence.** On the three menus she actually
uses while writing, the row that says a chord is the **⌥ variant** and the row that says nothing
is the **plain act** — so those menus read as *"Merge choosing takes… has a key; Merge does
not."* That is worse than silence: it is a face that teaches the opposite of the registry. The
class is exactly P-1's (*doors render FROM the registry*), and the four literals are the whole
of it — `Divide`, `Extract`, `Make Block`, `Merge` — so the fix is the class, not the one row.

### THE FIX FOR ITEM 7 (piece 4) — the class, not the one row

Three files, one shape each; **no new copy, no new act, no registry edit** — every row now asks
the declaration it already had.

1. **`CommitBar.swift`** — the four literals in `blockMenu` are gone. The six structural rows are
   one static, `CommitBar.structuralRows`, built from `CapabilityRegistry.capability(id)
   .menuTitle(words)` — the bar's own short words kept (`"Merge"`, never `"Merge Blocks"`: the
   chord was what was missing, not the wording), the chord appended by the ONE formatter. The
   menu renders them with a `ForEach` and one `run(_:)` switch, so the list a pin reads and the
   doors she presses cannot drift apart. *(A static, and that is deliberate: a private
   `@ViewBuilder` is unreachable from a test, and a claim about a chord being visible has to be
   checkable.)*
2. **`EditorViewModel.contextMenuItems()`** — the same four literals, replaced by
   `menuTitle()` with NO override, because this menu's words already ARE the registry's verbs
   ("Divide Block at Cursor" · "Extract Selection" · "Make Block from Selection" · "Merge
   Blocks"). So the only visible change on this menu is the chord in parentheses.
3. **`TakesBottomBar.structuralBar`** — the same, with the bar's short words (R118's parity: no
   surface is behind another, and that includes what a row is allowed to tell her).

**Why all four and not just Merge.** The defect is that a menu row's chord came from whether
someone typed it, and the two rows where someone had was the ⌥ pair — so every one of these
menus read *"the ⌥ variant has a key and the plain act does not."* Fixing Merge alone would
leave "Divide" silent beside "Divide choosing takes… (⌥⌘⇧D)" — the identical false lesson, one
row over. Reversing is per-row and costs one `menuTitle` call each.

**Not touched:** the bulk bars' **Merge Selected Blocks** rows render `capability.verb`, which is
correct — that act declares `shortcutLabel: nil` (it is a ⌘-click selection act, by design), so
`.verb` and `menuTitle()` are the same string and the row tells no lie. The menu bar and the ⌘/
helper were already truthful (audit 2) and are unchanged; both gained a guard pin.

### THE TRUTH PINS (piece 4) — `App/Variorum/VariorumTests/ChordLegibilityTests.swift`

| Pin | What it holds |
|---|---|
| `theWriteBarsBlockMenuSaysEveryDeclaredChord` | over `CommitBar.structuralRows`: every row's title contains its capability's DECLARED chord — generalized, because the defect was the class |
| `theWriteBarsMergeRowReadsMergeWithTheChord` | her sentence, answered literally: the row reads exactly `Merge (⌘⇧M)` |
| `theTakesBarsBlockMenuSaysEveryDeclaredChord` | the same over `TakesBottomBar.structuralBar` (R118 parity) |
| `theTakesBarsMergeRowReadsMergeWithTheChord` | `Merge (⌘⇧M)` there too |
| `writesContextMenuSaysEveryStructuralChord` | through the REAL model (`withEditor` → `contextMenuItems()`): all six chords present, and `Merge Blocks (⌘⇧M)` exactly |
| `theHelperListSaysTheMergeChord` | **green on both sides** — a guard, not evidence: the ⌘/ list has carried ⌘⇧M since the helper was born |
| `theMenuBarWiresAndRendersTheMergeChord` | **green on both sides** — `.merge` is in `menuRendered` and wired `("m", [.command, .shift])`, so AppKit draws ⇧⌘M on the item |

### THE RED-ON-OLD (piece 4b) — measured in a worktree, not reasoned

The pre-revert state was committed first (the checkpoint rule), then
`git worktree add /tmp/s1revert HEAD` with ONE behavioural change: the four plain rows' titles
put back to the literals on all three menus — the static, the `ForEach`, the `run(_:)` switch and
the test file all kept, so what is measured is the CHORD and not the refactor.

| Pin | On the reverted tree |
|---|---|
| `theWriteBarsBlockMenuSaysEveryDeclaredChord` | **RED, 4 issues** — `"Divide"` lacks ⌘⇧D, `"Extract"` ⌘⇧E, `"Make Block"` ⌘⇧K, `"Merge"` ⌘⇧M |
| `theWriteBarsMergeRowReadsMergeWithTheChord` | **RED** — `"Merge"` ≠ `"Merge (⌘⇧M)"` |
| `theTakesBarsBlockMenuSaysEveryDeclaredChord` | **RED, 4 issues** — the same four |
| `theTakesBarsMergeRowReadsMergeWithTheChord` | **RED** |
| `writesContextMenuSaysEveryStructuralChord` | **RED, 5 issues** |
| `theHelperListSaysTheMergeChord` | GREEN on both — recorded as a guard, not as evidence |
| `theMenuBarWiresAndRendersTheMergeChord` | GREEN on both — same |

**On this tree: 7/7 green** (and 66 tests in 4 suites with the registry walk, the bar's layout
suite and `FannedDefaultsTests` riding beside them).

**A LOOSE PIN THE REVERT CAUGHT, and it is worth its own line.** The context-menu pin first
asked whether each chord appeared *anywhere on the menu*. On the reverted tree that form found
only ⌘⇧E and ⌘⇧K missing and **let ⌘⇧D and ⌘⇧M pass** — because `⌥⌘⇧M` CONTAINS `⌘⇧M`, so the
ceremony row was answering for the plain one. That is *literally the state her report
describes*, and a pin that cannot tell the two apart is no guard at all. It now asks for the
EXACT row (`titles.contains(capability.menuTitle())`), and the revert re-run went 3 issues → 5.

**The revert's own failure dump is the defect, printed** — the menu as it shipped:

```
["Divide Block at Cursor", "Divide choosing takes… (⌥⌘⇧D)", "Extract Selection",
 "Make Block from Selection", "Merge Blocks", "Merge choosing takes… (⌥⌘⇧M)", …]
```

Every ⌥ variant wearing its key; every plain act silent. Her *"where is the merge shortcut
said ??"* has its answer in that line.

### THE TAB-SET RATIONALE (piece 2, item 6) — PROVISIONAL, QUESTIONS #131

**Her sketch, verbatim:** *"the settings menu could probably be broken up a little more - an
overall one, then maybe tabs on text editing shortcuts, window / reshaping shortcuts, etc."*

**Read with items 4 and 5 beside it, her three asks are ONE.** "It's too hard to find how to
make a callout" is not a settings question — a callout is an ACT (Block ▸ Callout, ⌥⌘C) — and
"that's further proof that I need a better formatting shortcut menu" is the same sentence again.
Her own sketch names SHORTCUTS as what the tabs should hold. So the thing she is looking for in
Settings is **what the app can do**, and the shape has to answer that or it answers nothing.

**What was there.** ONE `TabView` of five tabs whose FIRST tab was a single `Form` with five
sections and fifteen controls. That is the whole of row 59: a pane that long has a fold wherever
the window sits, and the 18j appearance control was past it.

**What is there now — a leading pane list beside a detail column, with the search at its head.**
Chosen over more tabs, and every reason is hers: nine panes cannot fit a 720 pt tab bar; the
search field needs a home and this is where macOS puts one; and the reference artifact's grammar
is solid geometric lines and calm cards (W8-3 retired the floating pane), which is a list, a
hairline and a card.

| Pane | Holds | Why it is its own pane |
|---|---|---|
| **General** | voice · colour palette · light/dark · confirmations | her *"overall one"* — the app-wide dials and how it talks back. **FOUR controls**, deliberately: this is where row 59 dies |
| **Editor** | seams · editing indicator · inline comments · paragraph gap · hover handle · spellchecking · long-block layout | her *"text editing"* — the writing surface's look and feel, split into "the page" and "while you write" |
| **Takes** | takes open as · takes follow the scroll | thin ON PURPOSE. Takes are a first-class idea; "where do I change how takes open?" should land on a pane with the word on it, not on row eleven of a long Editor pane. That is item 6's complaint in miniature (the fold-back alternative is #131(b)) |
| **Writing** | segmentation default · savepoint cadence · history pruning | the DOCUMENT's habits — and exactly the three that are SYNCED, which is a real line to draw |
| **Shortcuts** | the whole grouped keyboard map | her *"tabs on text editing shortcuts, window / reshaping shortcuts"*, literally. It renders `HelperView.groups` — **the ⌘/ helper's own list, not a copy** |
| Tags · Protection · Data Safety · Acknowledgments | unchanged panes | composed as they were; each gains ONE catalog row so it is findable by name |

**What the split did NOT do:** not one control's behaviour, wording, help text, binding or
storage changed. Every picker, toggle, observation and setter moved as written. The one new
sentence anywhere is the Takes pane's help line (the two settings had none of their own) and the
panes' own blurbs.

**Two deliberate keeps, each reversible in a line.** (1) The control rows stay in
`Form`/`Section` with `.formStyle(.grouped)`: two sub-rows (`AppearanceChoiceRow`,
`PaletteSettingsRow`) EMIT `Section`, which only renders inside a `Form`, and the system controls
are correct as they are. The calm grammar is applied where the chrome is new — the sidebar, the
search field, the results cards, the Shortcuts pane — plus `.scrollContentBackground(.hidden)`
over `tokens.room` and `.tint(tokens.accent)` so the pickers and toggles wear the voice.
(2) **`ThemeStore` is now injected into the Settings environment** (`.environment(theme)`) —
one line, and it is a fix: every `.alarmVoice()` in Protection and Data Safety reads the store
from the environment and has been falling back to the default voice since it was written, so
those refusals have never worn the voice she chose. Its HOME is untouched (the recorded waiver).

### THE SEARCH (piece 3, item 4) — one pure brain, three sources, no storage

`SettingsShape.swift`, all of it pure and testable without mounting anything:

- **`SettingsCatalog`** — every settings row as data (`pane` · `title` · `blurb` · `keywords`).
  **The pane renders `title` FROM here**, and `AppSettingsView.rowIDsRendered` lists what each
  pane shows, so declared ⇔ rendered is a pin (`everyCatalogRowIsRenderedByItsOwnPane` and its
  mirror) — the registry walk's own shape, one layer down. Without it the search could send her
  to a pane that does not hold what it promised.
- **`SettingsSearch.findings(matching:in:)`** — case- and diacritic-insensitive, terms ANDed
  across the entry, ranked `lead ==` → `lead` prefix → `lead` contains → keyword → detail, so
  the thing she named comes first.
- **The index is the catalog + `HelperView.groups` + `HelperView.entries`** — the ⌘/ helper's
  OWN two lists, read not copied. That is what makes her acceptance case literal: "callout" is
  neither a setting nor a pane, it is a CHORD and a WORD, and both are in the index.
  `everyDeclaredShortcutIsFindableInTheHelper` already holds that list to the registry, so
  `everyDeclaredChordIsFindableInTheSearch` is that guarantee arriving at a second door rather
  than a second promise to keep.

**Typing "callout" (the pin, and the walk's step):** the word *callout — "A block wearing a
colored frame (Block ▸ Callout). Presentation only…"* first, then **⌥⌘C — callout frame on this
block (again to remove it)**. Two answers, one of which is the fastest there is. **No storage:**
nothing is written, read from the store or synced; the query dies with the window.

### EVIDENCE — THE WALK (piece 6; the unit closes on USE, not on pins)

**Build:** `App/Variorum/DerivedData/13u4s1/Build/Products/Debug/Variorum.app`
(`io.lduarte.Variorum.debug`, the fenced dev store). `pgrep -fl 'Variorum.app/Contents/MacOS'`
was checked at the start — **ZERO instances; hers was not running at any point** — and every dev
instance was quit **by identity** (`tell application id "io.lduarte.Variorum.debug" to quit`),
never by a keystroke (the 13u3 UNIT D walker law), with `pgrep` re-checked after every quit and
at the end. `/Applications/Variorum.app` was never touched. Captures:
`notes/plans/13u4-screens/s1/` (gitignored) — **48 window captures**, named by step.

| # | Step | What the app did | Capture |
|---|---|---|---|
| 1 | ⌘, on the first build of the new shape | the nine-pane list beside the detail, the search field at its head — and **row 59 NOT DEAD**: the palette row (five swatch rows + two paragraphs) still stood between the voice and Light & dark, so the appearance control was under the fold on a SHORT pane too | `01-settings-general-T-light.png` |
| 2 | **THE WALK'S FIRST FINDING, fixed and re-walked**: the two short dials moved above the palette | **Light & dark ▸ Appearance (Follow system · Light · Dark) is on screen the moment Settings opens** — no scroll, no hunt. **KnownIssues row 59 is dead** | `02-general-appearance-above-fold-T-light.png` |
| 3 | **Type `callout` — HER ACCEPTANCE CASE, LITERALLY** | two results: **callout** *(the word)* — *"A block wearing a colored frame (Block ▸ Callout). Presentation only…"* — and **⌥⌘C** *(shortcut)* — *"callout frame on this block (again to remove it)"*. Neither is a setting, which is exactly why a settings-only search could never have answered her | `03-search-callout-T-light.png` |
| 4 | Type `dark mode` — a phrase in no label and no blurb | ONE result, **Appearance**, badged **general** — the keyword road, and the badge teaches where the thing lives | `04-search-darkmode-T-light.png` |
| 5 | Click that result | the query clears and the pane lands on **General** with the appearance control in view | `05-result-click-lands-on-general.png` |
| 6 | The **Shortcuts** pane | the whole grouped keyboard map in calm cards, in the voice's type — her *"tabs on text editing shortcuts, window / reshaping shortcuts"* | `06-shortcuts-pane-T-light.png` |
| 7 | **Type `unindent` — HER OWN WORD** | **NOTHING.** *(See the finding below — the app's word is "outdent" and every pin had typed the app's word.)* | `07-search-unindent-T-light.png` |
| 8 | …after the fix, re-walked | **⌘] / ⌘[ — "indent / outdent — unindent, if that's your word for it — the list item you're in; the same act as Tab / ⇧Tab, on keys the Format menu can show you"** — her item 5's question answered, with the new key in the same breath | `08-search-unindent-FIXED-T-light.png` |
| 9 | Type `merge` — **ITEM 7 THROUGH THE SEARCH** | the word *merge* (naming ⌘⇧M in its own prose), ⌥⌘Z, **⌘⇧M — merge blocks — every take comes along**, ⌥⌘⇧M, and the `block ▾` row | `09-search-merge-T-light.png` |
| 10 | A two-block note staged through the shelf's quick-entry bar (`Alpha paragraph.` ⇧⏎ `  - nested item` ⏎) | **block 1/2** | `11-note-staged.png` |
| 11 | **The bar's `block ▾` — ITEM 7'S OWN DOOR** | **Divide (⌘⇧D) · Divide choosing takes… (⌥⌘⇧D) · Extract (⌘⇧E) · Make Block (⌘⇧K) · Merge (⌘⇧M) · Merge choosing takes… (⌥⌘⇧M)**. Her *"where is the merge shortcut said ??"* — it is said, on the door she uses, and so are its three siblings | `crops/12-blockmenu.png` |
| 12 | **Right-click in the text** | **Merge Blocks (⌘⇧M)**, with all four plain acts chorded beside the two ceremony rows | `crops/13-contextmenu.png` |
| 13 | Caret in `  - nested item`, **⌘[** | **the item OUTDENTS** — the two leading spaces go and the bullet aligns with the paragraph above. Her *"I thought it unindented things"* is now true | `crops/14-before-outdent.png`, `crops/15-after-outdent.png` |
| 14 | **⌥⌘[** | **back to the shelf** — the navigation half of the swap, on Apple Notes' own chord | `16-after-opt-cmd-bracket-back.png` |
| 15 | The menu bar, read through the accessibility API rather than a screenshot | `Format ▸ Indent [0|]]` · `Outdent [0|[]` (plain ⌘) and `View ▸ Back [2|[]` · `Forward [2|]]` (⌥⌘) — the real menu, not a claim about it | — |
| 16 | **⌘/** | the helper's *windows & panes* group reads **⌥⌘[ / ⌥⌘]**, its *structure* group **⌘⇧M — merge blocks — every take comes along**, and its *formatting* group carries the new ⌘] / ⌘[ row beside the Tab one | `18-helper-formatting.png`, `19-helper-formatting-group.png` |
| 17 | **STUDY voice** (Settings ▸ General) | the serif pane, Title-Case chrome, the search in serif — and **Light & dark still on screen**: row 59 dead in the second voice | `42-general-STUDY-light.png`, `43-search-callout-STUDY.png` |
| 18 | **DARK** (`appearanceChoice dark`, relaunch), Study then Terminal | the fully black room in both voices, the appearance control on screen in both, the search legible in both | `44-general-STUDY-DARK.png`, `45-search-callout-STUDY-DARK.png`, `46-general-TERMINAL-DARK.png` |
| 19 | The `block ▾` menu **in dark** | every row wearing its chord on the black room — item 7 in the fourth combination | `49-blockmenu-TERMINAL-DARK.png` |

**Dev-store state left as found:** voice back to **Terminal** (set in the UI, verified in capture
19's masthead chrome), `appearanceChoice` back to **system** (verified by `defaults read`), the
paragraph gap back to **Standard** and inline comments back to **OFF** (both verified in
`36`, the Editor pane re-read after the row-53 runs), **zero instances**. Left in the dev store as
this walk's fixtures, as every walk's are: the note `Alpha paragraph.` (dated `2026-09-20`, in no
book) and today's journal entry, which ⌘J minted to reach a Write surface in dark.

### THE WALK'S FINDING THAT NO PIN COULD HAVE CAUGHT (step 7)

Typing **`unindent`** — the word she wrote, twice, in item 5 — found **NOTHING**. The app's word
is "outdent", the helper's row said "outdent", and **my own pin searched "outdent"**, so the
suite was green on a vocabulary the user does not have. This is the C1 curly-quote class exactly
one surface over: *a pin types the vocabulary it is testing, which is the whole trap.*

The fix is one string and it fixes the word EVERYWHERE rather than only in the search: the
helper's new bracket row now reads *"indent / outdent — unindent, if that's your word for it —
…"*, so the ⌘/ window, the Settings ▸ Shortcuts pane and the search all teach both words from
ONE source. The pin was widened to `["unindent", "outdent", "indent"]` with the finding written
at it. **The alternative rejected:** a synonym table inside the search brain, which answers in
one surface and starts a thesaurus nobody owns.

### ROW 53 — WALKED, AND **IT REPRODUCES ON BOTH OCCASIONS** (report, do not build — the brief's rule)

**The precondition the row names is met for the first time:** the inline-comments and
paragraph-gap controls are now reachable without a hunt — both sit on the Editor pane's first
section, on screen at the shipped window size (`22-editor-pane-T-light.png`).

**The fixture:** *The Adventure of the Copper Beeches* (**212 blocks · 9,999 words**), Write,
caret driven to the document END with ⌘↓ (`block 212/212`, the page drawn — `33-gap-before.png`).

| Occasion | Direction | What happened | Capture |
|---|---|---|---|
| **Inline comments** | OFF → **ON** (the document grows) | the page redraws whole; the viewport shifts up, which is the honest consequence of every block getting taller. **No blank region**, stable at +2 s | `23`, `24` |
| **Inline comments** | ON → **OFF** (the document shrinks) | **REPRODUCES.** Only the last line draws — *"Walsall, where I believe that she has met with considerable success."* — and the rest of the page is BLANK | `25-row53-inline-comments-off-again.png` |
| **Paragraph gap** | Standard → **a blank line's worth** (grows) | page whole, no blank region | `37-gap-changed-editor.png` |
| **Paragraph gap** | blank line's worth → **Standard** (shrinks) | **REPRODUCES**, identically | `38-gap-back-to-standard.png` |

**What it is, measured rather than guessed:**

- **The store is untouched throughout.** The bottom bar reads `block 212/212 · 149w block ·
  9,999w in note` in every blank capture. This is a LAYOUT stranding, not a content loss.
- **It does not self-heal**: byte-identical at +3 s and +8 s (`26`, `27`).
- **Scrolling does not heal it** (`28`) — there is nothing to scroll to; the scroller behaves as
  though the document were one line tall.
- **A mode round trip does not heal it** (`30`), and **leaving the note and coming back does
  not** (`31`, via ⌥⌘[ / ⌥⌘]).
- **⌘↑ — a caret move to the document start — heals it completely and instantly** (`32`, `39`:
  block 1/212, the whole page drawn). Any relayout aimed somewhere else recovers it.

**The mechanism this points at** (stated as a hypothesis for whoever builds the carve, not as a
finding): it is the mirror of the 17o measurement in TEXTKIT2_NOTES — `usageBoundsForTextContainer`
is a HIGH-WATER MARK that never shrinks while the document holds text. Here the re-font makes the
document genuinely SHORTER while the scroll offset sits at what used to be the end, and the
viewport comes to rest past the content, so exactly one fragment lays out. The growing direction
cannot produce it, which is precisely what the four rows above show: **both reproducing cases are
shrinks, and neither growing case reproduces.**

**Per the brief, NOTHING WAS BUILT for this** — the carve's design is 13u2 UNIT D's record's, and
this unit's job was to make the occasions reachable and say what they do. **KnownIssues row 53 is
RE-STATED, not closed**: its "NOT exercised" caveat is discharged, and what replaces it is a
reproduction with a rate, a direction, a healing road and a named hypothesis.
