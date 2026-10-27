# VX-562 — ladder round 3 (cold review, `opus-reviewer`; the FINAL round, hard cap)

**The diff under review:** `git diff 052d39c11..HEAD` in `~/dev/variorum-vx-562` (branch `vx-562-outline-follow`, HEAD `9c3dca052`). That is five files: `BookOutlineViewed.swift` (the behaviour), `BookView.swift` (six comment hunks, no code), the two test files, and the outline-follow record. The last code commit is `fae3312b2`; `git diff --stat fae3312b2..HEAD` touches the record only.
**Prompt:** `notes/REVIEW_PROMPT.md`, run verbatim over the diff, plus the brief's first half: does the fix land R-562-D as ruled. **Anchor:** `vx-562-ladder-round2.md` (N1, the round-2 dispositions, §R-562-D at its foot), `vx-562-outline-follow.md` §WALK 3, the r3 lines of §LIVE STATUS, §IMPLEMENTER SELF-ASSESSMENT r3, §R1 REVERT RECIPES' r3 block (H, H′), and §MORNING BUNDLE's r3 addition.

**What I read myself:**
- CLAUDE.md and the loaded canon; `notes/REVIEW_PROMPT.md`.
- All three ladder/record files, whole (round 1, round 2, the outline-follow record including §WALK 3).
- The whole diff.
- The current `BookOutlineViewed.swift`, whole.
- In `BookView.swift`: the box (`OutlineLandingBox`), `queueViewedPair`, `deriveViewedPair`, `adoptLandingTarget`, `releaseStandingAdoption`, `forgetViewedPair`, `outlineUserScrolled`, `outlineScrolled`, `OutlinePinnedLine`, `OutlineScrollFacts` (`:1540–1700`, `:1810–1851`, `:3039–3160`).
- `BookOutlineRows.swift` (rows, both builders) and `BookStructureModel.grouped` (empty chapters ARE rows; unfiled notes trail).
- The mounted end-scroll pin whole, `ruled`, `scrollPage`, `settle`, and the F-1, CLICK, RELEASE and SCROLL pins' uses of `ruled`.
- The r3 build logs: `DerivedData/vx562-r3-bft1.log` ends `** TEST BUILD SUCCEEDED **`; the only touched-file warnings are the base tree's two at `BookOutlineLandingTests.swift:1296–1297`.

**Not done:** I ran no suite. Every app test needs the test host, which needs the stage, and the stage was not mine. No r3 run log exists yet: H, H′ and the suites are the stage window's. **In their place I wrote my own scratch mirror** of the rows, the edge rule, `isAtTheBottom`, the current `rule`, recipe H's slide and recipe H′. It lives in the session scratchpad and is NOT the real code. I ran it over the pure table's column and over two shapes of my own (below). No subagent. `notes/QUESTIONS.md` untouched.

**Scope check (first): the diff stays inside `opus-reviewer` scope.**
- No editor seam: no `EditorTextView`, `BlockRangeIndex`, `PaneSurface` or read-tier line.
- No custody or keychain code.
- Nothing under `Sources/VariorumCore/Sync/`.
- No default's meaning changes: the follower's answer at the book's bottom is view behaviour, not a setting.

The code is one pure rule app-side (`BookOutlineViewed`), comments in `BookView`, and the pins.

---

## PART 1 — does the fix land R-562-D as ruled?

| R-562-D clause | Verdict | Evidence |
|---|---|---|
| **The slide is REMOVED; the probe is the top edge everywhere** | **LANDED** | `probe(_:)` is deleted. `grep "BookOutlineViewed.probe("` over the app and the tests finds nothing; the only `probe:` argument left is `pair`'s batch-1 parameter, defaulted to the 10-pt edge, which production never overrides. `follow` (`BookOutlineViewed.swift:313–323`) asks `rule`, and `rule` (`:216–228`) asks `pair(rows:tops:)` at the edge. No slide wording survives in source or tests except the superseding notes (`grep -i slide`). |
| **AT THE BOTTOM: within the end band (8 pt, the release threshold's named constant reused) of the maximum, the viewed pair is the LAST note and its chapter** | **LANDED** | `isAtTheBottom` (`:174–177`) is `travel > band && travel − offset <= band`, with `band = BookOutlineFollower.offsetRelease`. The band is inclusive, matching the release (which keeps at exactly 8). An overscroll past the bottom is in; one at the top is out. `rule` names `named(at: lastNoteIndex)`, so the pair is that note plus the chapter heading in force above it, through the same naming that every other answer uses. The arithmetic matches `OutlineScrollFacts` (`BookView.swift:3152–3160`): the offset's maximum IS `travel`, whatever the insets. The one implementer addition, `travel > band`, is bundled as a PROVISIONAL (see R3-2 for its true reach). |
| **Everywhere else the plain top-edge rule answers; the pace never changes; no lead** | **LANDED** | Outside the band `rule` returns `pair(rows:tops:)`, byte for byte the batch's rule. The pure table checks every 5-pt offset above the band for equality with the edge rule (`BookOutlineViewedTests.swift:367–369`). My mirror agrees: 0 differences on the current rule, 106 under recipe H. |
| **Monotonic as before** | **LANDED for the ruling's journal/Sherlock shape — but see R3-1** | By NOTE place: the edge rule never moves up, and the clamp's last note is the column's maximum. Pinned (`:372–379`; mirror: no backward step over 0…travel). R3-1 is a narrow column shape (a page or more of EMPTY trailing chapters) where the chapter mark steps back UP on entering the band, onto a note that is off the page. |
| **The pins: at max ⇒ the last note, its chapter, the pin's words** | **LANDED** | Pure: `viewed(travel)`, `travel − 8` and `travel + 30` equal `(s4, n11)`, and the pin reads "note 12 of 12 · chapter four" (`:352–357`). Mounted: the slot, the navigator note mark, the chapter mark, "the row at the top is not marked", and the pin line (`BookOutlineLandingTests.swift:1912–1921`). |
| **The pins: at max − (band + 1) ⇒ the top-edge answer, RED ON THE SLIDE TREE** | **LANDED; red-on-old by reading and mirror, revert NOT yet run** | Pure: `viewed(travel − 9) == edge == (s3, n8)`, with the pin line (`:360–364`). Mirror under H: `(s4, n11)` there, so RED. Mounted END-9 (`:1927–1960`): a 9-pt clip scroll up, with `#require` premises (it moved 9, the page's own facts say it left the band, the edge names another row), then the slot equals the edge answer equals `ruled`, the last note's mark is off, the top row's is on, and the pin line is composed through `pinLine` from `OutlinePinnedLine`'s own inputs (`BookView.swift:3074–3085`; `archived: 0` matches the harness book, as r1's hard-coded line already assumed). Under H the slid probe ≈ 10 + (1 − 9/734)·724 ≈ 725 pt names note 30 (round-2's harness tops put it at ≈ 542), so RED on the four END-9 lines the recipe names. |
| **Never-backwards kept** | **LANDED** | Pure `:372–379`; mounted `:1923–1925`. The mounted loop cannot record a clamp-then-edge sequence: after an in-band sample at the end, a grown end makes the loop step again to the NEW end before it samples (`:1882–1889`). |
| **The r1 end-scroll pin's "every last-screenful note seen" clause SUPERSEDED, rewritten, with the ruling's paragraph as the recorded why** | **LANDED** | The pin is renamed `herScrollToTheVeryEndClampsToTheLastNoteAndNinePointsUpTheTopEdgeAnswers`. Its doc (`:1815–1844`) carries a SUPERSEDED paragraph naming r1's version, the dropped clause, walk 3's film, and `vx-562-ladder-round2.md` §R-562-D as the why. The pure table documents the stated cost as a line (`!seen.contains(10) && !seen.contains(11)`, `:384–385`), which is RED under H (the mirror's slide sees 10 and 11). |
| **The original MAJOR stays red-on-old** | **LANDED (recipe H′, by reading and mirror)** | H′ (`isAtTheBottom` → `false`): the mirror gives the top row `(s3, n8)` at max, max − 8 and the overscroll; `seen` lacks 12. That is exactly the recipe's RED set; END-9 stays green. |
| **R-562-A / R-562-C and everything else untouched** | **LANDED** | `follow`'s adoption branch, `adoptedPair`, `isOnScreen`, `BookOutlineFollower` (every act, the key, `offsetRelease = 8`) and `named(at:in:)` are byte-unchanged; only `follow`'s fallback line and doc lines moved. `BookView.swift`'s six hunks are comments only (each hunk read). `LandingAuthority.swift`, `BookViewModel`, `NoteBox` and the marks are untouched. F-1's and CLICK's premises still hold, because at the bottom the clamp names note 30 and their target is 28. RELEASE and SCROLL compare against `ruled`, which is the same `rule` the follower asks. |
| **Recipes H and H′ staged correctly** | **CORRECT AS WRITTEN** | H's snippet compiles in `rule`'s scope (unqualified `probe` resolves to the static 10). It reproduces `052d39c11`'s `probe(_:)` exactly, including the `viewport > probe` and `slide > 0` guards. Its expected RED/GREEN sets match the mirror line for line: the three nine-up lines, the above-band loop (106 offsets), the stated-cost line, and the unreported-last-note line (the slide names n10); the bottom lines stay green. H′'s RED set matches as well. |

**Part 1 verdict:** R-562-D is landed as ruled. One narrow column shape is the exception to the ruling's own "monotonic" clause (R3-1). The red-on-old evidence for both recipes is by reading plus my mirror only. The runs are owed at the stage window.

---

## PART 2 — the diff through `REVIEW_PROMPT.md` (anything NEW it introduces), severity-ranked

**No new BLOCKER or MAJOR.**

### R3-1. [MINOR] · `BookOutlineViewed.swift:216–228` (`rule`) · in a book whose column ENDS in a page or more of empty chapters, the clamp names a note that is off the page, and the navigator's chapter mark steps back UP as the page scrolls DOWN into the band

**What is new.** `rule` clamps to the last NOTE row (`rows.lastIndex(where: .note)`) whenever the page is in the end band. It does not check whether that note is on the page. The ruling's two clauses assumed it always is: "the end of a book — her journal's newest entry — lands highlighted" and "Monotonic as before". The implementer's risk list names the case of ONE trailing empty heading ("clamps to the last note … while that empty heading sits below it on the page"). It does not name the case where the empty headings fill the page and push the last note off it.

**Mechanism I traced.** `BookStructureModel.grouped` (`:155–176`) emits EVERY section, empty or not, before the unfiled group. So a curated book with chapters planned ahead and no unfiled notes ends in a run of empty `.chapter` rows. Each names its chapter alone (P-562-7's empty-chapter case, `named(at:in:)` `:260–265`).

My scratch mirror used the pure table's own pitches: 100-pt notes, 40-pt headings, 10-pt gaps, a 120-pt title block and a 120-pt foot, on a 600-pt page. The column is chapter one with 3 notes (e0–e2), then 15 empty chapters s2…s16; travel is 760.
- **offset 730** (max − 30): the edge rule names `(s6, –)`, and `rule` agrees.
- **offset 751** (max − 9): `(s7, –)`, and `rule` agrees.
- **offset 752** (max − 8, entering the band): `rule` names `(s1, e2)`. The pin then says "note 3 of 3 · chapter one", while e2's row spans −362 to −262 pt, wholly above the page. The navigator's mark jumps from chapter 7 back up to chapter one, while the page shows only empty headings 7–16.
- **offset 760** (the bottom): the same `(s1, e2)`, the row at −370 to −270.

On the harness page (viewport 734, foot ≈ 120, heading pitch ≈ 61, from round 2's derived numbers), this needs about 11 trailing empty chapters. A shorter window needs fewer. Below that threshold the last note is still on the page at the bottom, and the clamp is right. The two thresholds are the same one: the edge rule names an empty trailing heading at the bottom exactly when the last note's row has left the page.

**Why it matters, and why only MINOR.**
- **Why it matters.** The books profile is one of the app's three modes (CoreDescription: "chapter/scale ordering matters most"). A pre-built outline with ten or more empty chapters ahead of the writing is an ordinary drafting shape. In it the bottom highlights a note she cannot see, and the chapter mark runs backwards on a downward scroll. That breaks the ruling's own "Monotonic as before" in chapter terms.
- **Why only MINOR.** The reach is narrow: a page or more of empty trailing chapters, with no unfiled notes, since unfiled notes trail and would themselves be the last notes. It shows only in the last 8 pt of scroll, and 9 pt up restores the edge answer.

The ruling is silent on trailing empty chapters, so this is product silence: it goes to the bundle and `notes/QUESTIONS.md`, and the architect rules.

**Options:**
- **(a) Accept as ruled.** Add the shape to the R-562-D bundle line.
- **(b) Clamp only to a last note that is ON the page.** That means `isOnScreen(top:height:viewport:)`, the R-562-A test already in the file. `Page` already holds `heights`, so `rule` would take the `Page` (or the heights) as well as the tops. Otherwise the edge rule answers. In the shape above the bottom then shows `(s7, –)`, which is monotonic and on the page. Every other shape is unchanged, because the last note is on the page whenever the edge rule does not already name an empty trailing heading.
- **(c) Clamp to the last ROW** (the scroll-spy convention's literal "last section"). That fixes this shape, but in the ONE-trailing-empty-heading case it names the empty chapter instead of the newest note above it. That is the implementer's "last NOTE, not the last row" reading, reversed.

**Pin (born-red for (b); a documenting table for (a)).** A pure `rule` table over the column above (one chapter of three notes, then fifteen empty chapters, 600-pt page, travel 760):
- at `offset = travel`, (b) expects `(s7, –)`; HEAD gives `(s1, e2)`, so RED;
- at `travel − 9`, both give `(s7, –)`;
- a never-backwards line over the CHAPTER mark (the section's order in the column), stepping 0 → travel, is red on HEAD at the band's edge.

The table is checkable against the real code headlessly, in the stage window's `BookOutlineViewedTests` run.

### R3-2. [NIT] · `BookOutlineViewed.swift:159–177` (`isAtTheBottom`'s doc) and the record's §MORNING BUNDLE r3 line · the short-book PROVISIONAL is framed at "8 pt or less", but the shape its rationale avoids still appears for every book that scrolls less than about its title block

**What the doc and the bundle say.** The `travel > band` guard exists because "clamping there would view its last note with the title block still holding the page". The bundle line offers (a) built, (b) and (c), all about books that move 8 pt or less.

**What the code does.** The guard keeps "at rest nothing is viewed" true for every book; that claim holds. At the BOTTOM, though, the same shape returns for any book whose travel exceeds 8 pt but is less than about its title block plus one probe, where the first row's top never reaches the 10-pt probe above the band.

Mirror: four 100-pt notes under a 120-pt title block on a 600-pt page, travel 70.
- Offsets 0–61 view nothing.
- Offsets 62–70 jump straight to "note 4 of 4", with 50–58 pt of the title block still on the page and notes 1–3 above note 4, never viewed by scrolling.

A new daily Journal in its first week is exactly this shape. It is the ruling's literal behaviour and the scroll-spy convention, so it is not a bug. But she should rule on the true reach, not the 8-pt sliver.

**Fix (words only).**
- The bundle line names the shape. In a book that scrolls less than about its title block, the highlight goes from nothing at rest straight to the last note at the bottom, while the title block is still on the page; every other note is a click's.
- If she wants it gone, the option is "clamp only once the edge rule names a row", i.e. once the title block has left the page's top. Such a book would then never clamp, as the batch's edge rule never highlighted it.
- The doc's sentence narrows to the at-rest claim it actually guarantees.

No pin is owed (taste, documentation). A documenting table line is cheap if (a) stands.

### R3-3. [NIT] · `notes/plans/fixes/vx-562-outline-follow.md` LEDGER rows 1/2/4 and §MORNING BUNDLE · record hygiene

1. **Round 2's N3 is only partly done.** Its disposition was "FIX NOW … the stale PENDING/ledger lines flipped". Commit `72f9e0a79` flipped `:150` and the round-1 file's `:176–179`, but not the LEDGER.
   - Row 1 still reads "**r1 fixes BUILT-PENDING-SUITES** (… runs + reverts at the stage window)", and the r3 clause was appended beside that stale one.
   - Row 2 still reads "**r1 fixes BUILT-PENDING-SUITES**".
   - Row 4 still reads "ROUND 1 DONE … runs, reverts and round 2 the orchestrator's", although round 2 closed, R-562-D was ruled and round 3 is this file.

   Window tests2 (`:380`) settled every r1 claim those rows call pending.
2. **The bundle carries the ruling but not its two felt consequences.** The R-562-D bundle line (`:300`) states the clamp and the middle-notes cost. The two step consequences the fix session lists under its r3 risks (`:217–218`) are absent:
   - the reverse step (9 pt up from the bottom drops the highlight from the last note to the top row, 13 → 10 on folded Sherlock);
   - the hold × clamp step (after a last-screenful click, her first scroll of more than 8 pt steps the highlight UP from the clicked note to the top row).

   She reads the bundle, not the self-assessment. Both are as ruled; she should see them where she rules.

**Fix (the orchestrator's, repo-first, at the merge moment):** flip rows 1, 2 and 4 to their verdicts. Fold the two step lines, plus R3-1's and R3-2's shapes, into the R-562-D bundle entry.

---

## Process note (not a code finding): what is still owed before ledger rows 1–2 close

- **The runs:** the r3 suite list (`BookOutlineViewedTests` 26, `BookOutlineLandingTests` 21, `BookOutlineRowsTests` 5, `NoteBoxCopyTests`), the 56-suite regression set, then recipes H and H′. My red/green verdicts on every pin come from reading the code and from a scratch mirror of the arithmetic. The mirror is not the code: it confirms the TABLE, not the build.
- **Use-shaped evidence for R-562-D.** CLAUDE.md: "a batch closes only on use-shaped evidence". Walk 3 saw the SLIDE; nothing on screen has yet seen the clamp. A walk 4 replay of walk 3's leg 2 on the r3 build should check:
  1. the pace stays steady all the way down (no doubling over the last screenful);
  2. the bottom lands on "note 13 of 13";
  3. one wheel notch up drops to the top row, and how that step reads.

  If a short-note book can be staged, it should also show the hold × clamp step after a last-screenful click. R3-1's shape needs a book with a page of empty trailing chapters; it is cheap to stage with "+ new chapter" in the walk's own throwaway book, if the orchestrator wants live evidence before ruling it.
- **Round 2's two merge-time tickets** are still owed at the closeout: finding 6's Debt/Low restructure and finding 12's Index → Outline caret block.

---

## Clean bill (load-bearing things in the r3 diff I checked and found solid)

- **The clamp is one branch in one pure function, and the follower's ordering is unchanged.** `follow` checks the adoption first. A standing target (F-1, the click) therefore still outranks the clamp, which the ruling's stated cost needs ("a click reaches them"). After an R-562-C release out of the band the answer is always the edge rule: at the F-1 page the key is the maximum offset, and with both thresholds at 8, `Δ > 8` holds exactly when the page has left the band. Nothing new is asked of `BookOutlineFollower`.
- **The band's arithmetic is right whatever the insets and the overscroll.** `OutlineScrollFacts` makes `offset ∈ [0, travel]` at rest, so `travel − offset ≤ 8` is "within 8 pt of the bottom". A rubber-band past the bottom (`offset > travel`) is in the band, and one past the top is not. The pure table pins both. A page whose scroll has not reported (`travel` 0, including the first turn after a return to the Outline, since `forgetViewedPair` zeroes offset and travel) never clamps.
- **The never-guessed law holds.** The clamp names the last note only once its row has reported a top. An unreported last note falls back to the edge rule (pinned; RED under H, so that line is not hollow). A column with no note row falls back to the edge rule (pinned).
- **P1 cost is unchanged.** `isAtTheBottom` short-circuits, so the extra `lastIndex` O(rows) pass runs only inside the 8-pt band. The derivation is still one per run-loop turn over the ≤ 300-note window.
- **The pin's words at the bottom come through the one brain.** `named(at:)` gives the clamped pair its chapter exactly as every other answer gets it. The mounted END-9 line composes the expected words through `pinLine` from `OutlinePinnedLine`'s own inputs, so the comparison is not a second hand-written sentence.
- **The pure table's numbers are right.** I re-derived the column myself (rows at 120, 170, 280, 390 · 500 … 1530; content 1 750; travel 1 150) and ran the mirror. On the current rule every line of both pure tables comes out as written: the band's thirteen lines, the premises (last screenful [10, 11, 12], edge at the bottom `(s3, n8)`), the bottom lines, nine-up, zero above-band differences, monotone, seen = {0…9, 12}, and both clamp edges. Under H, RED exactly where the recipe says (106 above-band offsets, nine-up, the stated cost, the unreported line), with the bottom lines green. Under H′, RED at the five band lines, the three bottom lines, the pin and "seen contains 12", with END-9 green.
- **The mounted pin's premises are honest `#require`s.** It checks that the page moved 9 (`abs(up + 9) < 0.5`), that the page's OWN facts say it left the band (not an assumption from the clip), that the edge names another row, and that the page is back in the band before the last check. A snapping host fails a premise, not a verdict.
- **The superseded r1 clause is recorded where a reader meets it.** The renamed pin's doc names r1's old pin, the clause, walk 3's film, and the ruling's paragraph. The pure table keeps the stated cost as an assertion, so a future re-slide shows up as a red line instead of passing silently.
- **The fences hold.** There is no write to focus, the caret seeds, `pendingReveal` or a landing's aim. There is no new observer, dependency, schema, literal colour or rendered string; the pin's words are composed by the existing brain. `notes/QUESTIONS.md` and the shared ledgers are untouched. No canon file changed (that is closeout work).
- **No stale slide wording survives** in source or tests (`grep -i slide`, `grep "R-562-B"`). Each remaining mention is a superseding note.
- **Not flagged (pre-existing since r1 or ruled):**
  - A width change at the bottom re-lands `topRow` and adopts it, stepping the highlight from the last note to the top row. That is R-562-A's "included, harmlessly", and the slide behaved identically.
  - An expansion at the bottom releases to the clamp. That is R-562-A's axis release, named in the fix session's risks.
  - The empty-chapter heading naming its chapter alone is P-562-7 as built.

## Verdict

**R-562-D lands as ruled. No new BLOCKER or MAJOR, so the cap closes the ladder at three rounds and nothing goes to the orchestrator for a round-4 adjudication.**

New from the r3 diff:
- **R3-1 (MINOR):** a page or more of empty trailing chapters makes the clamp name an off-page note and run the chapter mark backwards. This is product silence for the bundle and QUESTIONS. Option (b) is a cheap on-page guard, and its born-red table is specified above.
- **R3-2 (NIT):** the short-book PROVISIONAL's true reach, for the bundle line.
- **R3-3 (NIT):** the ledger rows still stale from round 2's N3, and the bundle missing the two step consequences.

Still owed before rows 1–2 close: the r3 suites, recipes H and H′, and a walk 4 on the clamp.

## THE ORCHESTRATOR'S ROUND-3 DISPOSITIONS (the capped final round — fixes applied by the orchestrator under the architect mandate's small-fix clause, with this section as the line-by-line record; no round 4 exists to re-read them)

- **Part 1 — accepted in full.** R-562-D stands landed; the H/H′ red/green calls await the combined stage window's runs.
- **R3-1 [MINOR] — AGREE, FIX NOW as R-562-D′ (the ruling's refinement):** the clamp stands only for a last note that is ON the page (`isOnScreen` over the row's own top and height — `rule` now reads the `Page`, which already carries both); a column ending in a page or more of empty chapters keeps the edge rule, so the chapter mark never steps back up and "Monotonic as before" holds in chapter terms too. The reviewer's option (b), exactly; (a) would leave a wrongness my own ruling's clause forbids, (c) re-opens the last-row semantics for no gain. The born-red table `aLastNoteOffThePageKeepsTheEdgeRuleAtTheBottom` (the reviewer's mirror column: 3 notes then 15 empty chapters, travel 760) is RED on the pre-fix r3 tree — staged as recipe I, run at the combined window.
- **R3-2 [NIT] — AGREE, the bundle line re-worded** (the short-scroll book's honest shape: a book that scrolls less than about its title block goes from nothing straight to the last note; a first-week daily Journal has it).
- **R3-3 [NIT] — AGREE, the record hygiene finished** (ledger rows 1/2/4 re-stated once, the r3 clause folded in; the R-562-D bundle line gains the two felt steps the self-assessment names: the 9-pt-up step 13 → ~10, and the step UP to the top row after a last-screenful click's release).
