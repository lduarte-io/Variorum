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

*(written next — see below)*
