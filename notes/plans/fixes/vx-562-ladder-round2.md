# VX-562 — ladder round 2 (cold review, `opus-reviewer`)

**The fix diff under review:** `git diff 9339943f4..HEAD` in `~/dev/variorum-vx-562` (branch `vx-562-outline-follow`, HEAD `05b426d92`; the last code commit is `1f23d7855`, and everything after it touches `notes/` only). That is six files: `BookOutlineViewed.swift`, `BookView.swift`, the two test files and the two records.
**Prompt:** `notes/REVIEW_PROMPT.md`, run verbatim over the fix diff. **Anchor:** `notes/plans/fixes/vx-562-ladder-round1.md` (findings 1–12, the orchestrator's dispositions, R-562-B, R-562-C, the walk addenda and the fix session's as-built dispositions) and `notes/plans/fixes/vx-562-outline-follow.md` (§DESIGN, R-562-A, §LIVE STATUS r1, §R1 REVERT RECIPES, the self-assessment, §WALK 2, the window-tests2 lines at its foot).

**What I read myself:**
- CLAUDE.md and the loaded canon.
- Both records, whole.
- The whole fix diff.
- The current `BookOutlineViewed.swift`, whole.
- The current `BookView.swift` follower wiring: the box, `deriveViewedPair`, `adoptLandingTarget`, `releaseStandingAdoption`, `forgetViewedPair`, `landOutline`, `outlineAnchorMoved`, `outlineUserScrolled`, `outlineScrolled`, and the Outline's geometry, phase, `onAppear`/`onDisappear` and `onChange` handlers (`:1538–1850`, `:2161–2281`).
- In `BookView.swift`, also: the navigator labels (`:2920–3000`), `OutlinePinnedLine` (`:3060–3115`), `OutlineScrollFacts` (`:3133`), `BookNavigatorDoor` (`:3736–3766`) and `BookViewCopy.metaLine` (`:3782`).
- `Surface/LandingAuthority.swift` `:545–806`, which covers `land`, `begin`, `userTookOver`, `end`, `look` and `finish`, and confirms that `onFinish` is called last.
- `BookOutlineRows.swift` (rows and segments).
- `BookViewModel`'s window and `truncated` logic (`:27–44`, `:79–118`, `:167–168`).
- `BookAnchor.landing` (finding 12).
- `BookIndexView.swift` around `:1222`, `:1245` and `:1789` (finding 10).
- The navigator's room token (`BookView.swift:998`, `tokens.room`).
- The window's logs, read directly: `vx562-r1-full.log`, `vx562-revB/C/E/G-run.log` and `vx562-final-run.log`, including their failure lines and the pins' print lines.

**Not done:** I ran no suite. Every app test needs the test host, which needs the stage, and the stage was not mine to take. The pins' outcomes below come from the window's logs, read line by line. I used no subagent. `notes/QUESTIONS.md` is untouched.

**Scope check (first): the diff stays inside `opus-reviewer` scope.**
- No editor seam: no `EditorTextView`, `BlockRangeIndex`, `PaneSurface`, `ReadPostView` or read-tier line changes.
- No custody or keychain code.
- Nothing under `Sources/VariorumCore/Sync/`.
- No default's meaning changes.

The code is book-view chrome (the navigator's labels and the pinned line), the Outline scroll's existing geometry observer (widened, with no new observer), and a pure, app-side geometry rule with its follower value.

---

## PART 1 — round 1's dispositions, verified one by one

| # | Round-1 finding → disposition | Verdict | Evidence (file:line, the run) |
|---|---|---|---|
| 1 | [MAJOR] the last screenful is never viewed by scroll → **R-562-B, the sliding probe** | **VERIFIED FIXED** | `BookOutlineViewed.swift:167–174`: `probe(_:)` uses the edge probe until `remaining < min(viewport, travel)`, then slides linearly to the viewport's foot. `follow` asks the rule over `probe(page.scroll)` (`:288`). The scroll facts come from the existing observer, widened (`BookView.swift:2191–2195` → `outlineScrolled` `:1837–1850`, offset and travel inset-aware, `OutlineScrollFacts` `:3133`). Pins: pure `theProbeSlidesToThePagesFootOverTheLastViewportOfScroll` (`BookOutlineViewedTests.swift:245`) and `scrollingToTheEndViewsEveryNoteOfTheLastScreenfulAndTheLastAtTheBottom` (`:275`); mounted `herScrollToTheVeryEndOfTheBookViewsEveryLastNoteAndEndsOnTheLast` (`BookOutlineLandingTests.swift:1830`). **Red-on-old confirmed from the log:** `vx562-revB-run.log` is RED on exactly those three (the mounted pin fails at `:1897/1899/1900/1902/1905/1920`, its `#require` premises held). Green on the restored tree: `vx562-final-run.log`, END line `seen [20 … 30]`, monotonic, at the end `offset=3465 travel=3465`, pair = the last note. Live evidence of the fix is still owed (walk 3; walk 2 preceded it). The `min(viewport, travel)` slide departs from R-562-B's literal text for books shorter than two pages. It is PROVISIONAL and bundled, which is correct handling, but the orchestrator has to accept it explicitly (see N1 for the slide's reach). |
| 2 | [MINOR] the hold released only by the `.interacting` phase → **R-562-C, the offset release** | **VERIFIED FIXED** | `BookOutlineFollower.look` (`BookOutlineViewed.swift:456–470`) keys on the offset at the first look after the landing (`:464`). That look is the landing's own `onFinish`, which `LandingAuthority.finish` calls last with the authority idle (`LandingAuthority.swift:798–804`). The follower lets go at `> 8` pt (`:462`, `offsetRelease` `:414`). The phase road is kept (`BookView.swift:1826` before `userTookOver`). Pins: pure `thePageMovingMoreThanEightPointsLetsTheTargetGo` (`:620`; boundaries 8 keeps, 8.5 releases; no key mid-travel; a fresh key per landing) and mounted `aScrollThatKeepsTheLandedTargetOnThePageReturnsTheFollowerToTheRule` (`:1938`). **Red-on-old confirmed:** `vx562-revC-run.log` is RED on exactly those two. In the mounted pin, the host premise (`heard < -300`) and the "still on the page" premise held: the RELEASE print shows the target at top 396 of 734 and pair = rule. |
| 3 | [MINOR] "300 notes · note 12 of 300+" → **one total** | **VERIFIED FIXED** | `NoteTotal` (`:313`) feeds both halves through `pinLine` (`:362–371`, `notesAreAtLeast: total.isAtLeast` `:368`). `OutlinePinnedLine` builds it from `entries.count` and `truncated` (`BookView.swift:3076`). `metaLine` says "N+ notes" (`:3788`). The window mechanism checks out by reading: the model observes `window + 1` rows and `truncated = new.count > window` (`BookViewModel.swift:105`, `:167–168`). The row builders put each entry in exactly one `.note` row (`BookOutlineRows.swift` `rows(grouped:)`/`rows(flat:)`), so the column's note count is `entries.count`. `metaLine`'s only other callers are `VocabularySweepTests`' three lines, and their output is byte-unchanged (the default is `false`). Pin: `thePinnedLineSaysOneTotalForBothHalves` (`:505`). Revert D was not run. By reading, the windowed lines would compose "300 notes · note 3 of 300+" under the recipe, so the pin is not hollow. |
| 4 | [MINOR] the navigator click door is never driven; the `isPending` guard is unpinned → **pin added; record the revert's direction** | **VERIFIED FIXED** | The mounted `aNavigatorClickOnAShortNoteInTheLastScreenfulEndsOnThatNote` (`:2033`) drives the real door `BookNavigatorDoor.noteRowClicked` (`BookView.swift:3737` → `openTheNote` = `focus` + `requestReveal`, `:3760–3766`; the navigator's two buttons call the same door, `:759`, `:835`). The `#require` confirms the click unfolded the note. Pure `theClicksOwnExpansionNeverReleasesItsTargetInEitherOrder` (`:557`) covers both delivery orders. **The order question is answered:** `vx562-revE-run.log` is RED on BOTH the pure order-A line and the mounted pin (`:2100/2102/2103/2106`; the travelling-turn check stayed green, so the target held through travel and fell to the rule at `DONE`). On this host the reveal's `onChange` arrives before the expansion's, and the guard carries the real click road. |
| 5 | [MINOR] `viewedIndex` is a test-only twin → **deleted; monotonicity over `pair`** | **VERIFIED FIXED** | `grep viewedIndex` finds only a doc comment (`BookOutlineViewedTests.swift:211`). `theRuleIsMonotonicInTheProbe` (`:216`) runs `pair` over a flat column and pins `≤` at a row's exact top (`place(-400) == 2 && place(-401) == 1`), so the `<`-for-`<=` mutation the finding named now fails. Cleanliness only, so no pin was owed. |
| 6 | [MINOR, architecture] the follower spread across eight sites → **PARTIAL: one decision value; the full restructure ticketed at the merge** | **RECORD-ONLY-CONFIRMED (partial fix landed)** | `BookOutlineFollower` (`BookOutlineViewed.swift:398–476`) holds adopt, axis, scroll, forget, look and the offset key. Each view act is one call (`BookView.swift:1638`, `:1660`, `:1677`, `:1688`, `:1826`). Finding 4's red order-A line shows the headless table reaches the ordering the finding called unreachable. One ordering stays in the view: `outlineUserScrolled` calls `userScrolled()` before `userTookOver()` (`:1826–1827`). A swap there would show the target for one turn before the queued derivation corrects it, which is harmless. **The Debt/Low ticket for the remaining restructure is owed at the merge (the orchestrator's); not yet filed. Verify at closeout.** |
| 7 | [NIT] Outline labels read `focusedPostID` → **fix if trivial** | **VERIFIED FIXED** | `NavigatorNoteLabel` (`BookView.swift:2933–2934`) and `NavigatorChapterLabel` (`:2968`, `:2972`) read the focus only outside the Outline and the viewed pair only inside it. Every mark is unchanged because `BookNavigatorMark` (`BookOutlineViewed.swift:492–515`) already ignored each fact outside its own mode. The 60-suite run is green. |
| 8 | [NIT → FIX] the Study-dark wash is invisible → **a token-only mark that reads in both voices** | **VERIFIED FIXED (in code and by token maths). The visual check is owed to walk 3** | `viewedChapterFill` = `tokens.accent.opacity(0.22)`, and `chapterNameInk` = ink when viewed (`BookView.swift:2850–2860`, drawn at `:2987`, `:2997`). The test's backdrop is the navigator's real room (`.background(tokens.room)`, `:998`). Pin: `theViewedChaptersMarkReadsInBothVoicesAndBothAppearances` (`:691`). **Red-on-old confirmed:** `vx562-revG-run.log` is RED on it with 65 issues (the ≥ 1.3, ≥ 1.25 and ink ≥ 4.5 lines). Study light and Terminal (both appearances) are covered only by token maths. Walk 3 should capture them. |
| 9 | [NIT, SPECULATIVE] the pin's edge with legacy scrollers → **record-only** | **RECORD-ONLY-CONFIRMED** | The diff leaves `OutlinePinnedLine`'s layout untouched (only its content composition moved to `pinLine`). Walk 2 never showed a legacy scroller. |
| 10 | [walk] "Modifying state during view update" ×2 + "OnScrollGeometryChange … multiple times per frame" at Outline → Index → **trace; not ours** | **RECORD-ONLY-CONFIRMED (static trace; not re-run)** | The trace holds as far as reading goes. The batch added `onGeometryChange` (the page height), not an `onScrollGeometryChange`; `onScrollGeometryChange` existed on base at `BookView.swift:1985` (pre-batch), and the Index has two (`BookIndexView.swift:1222`, `:1245`). The Index composes `PaneSurfaceView` (`:1789`), which is 18k C3's one measured shape. `OwnedRegistrations` is a plain struct (`DebugOracleOwnership.swift:72`), so the DEBUG oracle writes are not observed state. **Still owed:** a base-tree comparison was never run, and r1 widened the Outline's observer to change on every scroll frame. Walk 3 should count "multiple times per frame" lines over an Outline scroll and a landing, as the record's own r1 risk says. |
| 11 | [walk] the pin blinks at every heading → **P-562-7: a heading names the note it introduces** | **VERIFIED FIXED** | `named(at:in:)` (`BookOutlineViewed.swift:210–236`): the heading in force is walked back (`:213`); a heading names `rows[index+1]` when that is a note (`:229`), else its chapter alone. `adoptedPair` names the same way (`:248–251`). Pins: `aChapterHeadingAtTheTopNamesTheNoteItIntroduces` (`:88`), `aHeadingWithNoNoteUnderItNamesItsChapterAlone` (`:109`), plus the restated unfiled, flat and adoption lines. Recipe F was not run. By reading, deleting the three-line block makes `:88`'s first `#expect` compare `Pair(sectionID: "s2")` with `c`, so it is red and not hollow. |
| 12 | [walk] the round trip moved the caret block 2 → 1 → **read-trace; likely not ours** | **RECORD-ONLY-CONFIRMED (not ours)** | `BookAnchor.landing`'s `.spread, .read, .index` arm returns `LandingTarget(postID:)` alone; only `.outline` carries `liveBlockID` (`BookAnchor.swift:110–118`). The effort's whole diff leaves `BookAnchor.swift` untouched and writes no caret seed. **The ticket is owed at the merge (the orchestrator's).** |
| A×B | the R-562-A × R-562-B step-down named by the fix session | **RECORDED, BUT ITS REACH IS UNDERSTATED → N1 below** | See N1. |

**Part 1 verdict:** every disposition landed as written. All the bug-class pins (1, 2, 4, 8) are confirmed red-on-old by the window's behavioral reverts, read from the logs, and green on the restored tree: `vx562-final-run.log` "47 tests in 2 suites passed", and `vx562-r1-full.log` "324 tests in 60 suites passed … 4 known issues", the standing `IndexTierMetricsTests` four. The tested tree is the HEAD code: `git diff --stat 1f23d7855..HEAD` touches only the record.

---

## PART 2 — the fix diff itself, through `REVIEW_PROMPT.md` (anything NEW the fixes introduced), severity-ranked

### N1. [MINOR — rises to MAJOR if walk 3 reads the lead as the wrong note] · `BookOutlineViewed.swift:167–174` (`probe(_:)`) × `:456–470` (`BookOutlineFollower.look`) · R-562-B's slide runs the highlight up to a page ahead of the page's top across the whole last viewport of scroll, and the R-562-A × R-562-B "step-down" reaches every landing whose target settles there, not only last-screenful clicks

**What is new.** Over the last `min(viewport, travel)` of scroll, the shipped probe slides from the edge (10 pt) to the page's foot. Rows also move up 1 pt per point scrolled, so in that zone the probe crosses the content at about twice the scroll's speed. The viewed note therefore leads the row that owns the page's top, and the lead grows to a full viewport at the bottom.

The fix session's bundle line names only one consequence: "after a click in the last screenful, her first small scroll UP steps the highlight DOWN to the last note". The real reach is wider:
- **(i) Any landing.** This covers any landing whose target lands at the TOP but whose settled offset is inside the last viewport of scroll. That is an ordinary settled landing, not F-1. The first scroll of more than 8 pt, in EITHER direction, releases the hold (R-562-C) to a rule that names a note several rows below the target.
- **(ii) Her own scroll.** Inside the last viewport, the highlight names a note well below the one at the top of the page.

**Traced mechanism, from the window's own geometry plus the shipped formula.** The harness page is `viewport 734`, `travel 3465` (SCROLL 1 and F-1 print lines in `vx562-final-run.log`). The fixes those lines give:
- Note 28 stops at top 293 at the maximum offset (F-1: "gave up at top=293.0").
- The END pin's samples, at `2721 + 30·i`, first view note 30 at offset ≈ 3381 (remaining 84) and note 29 at ≈ 3351 (remaining 114).
- With `probe(r) = 10 + (1 − r/734)·724`, those samples bound the last note's top at the bottom to L ∈ (508, 567]. That gives a row pitch of ≈ 120 pt per note and 61 pt per heading, which reproduces `seen[0] = 20` at offset 2721.

Under those (derived, ±10 pt) pitches:
1. A landing on note 25 settles it at top 0 at offset ≈ 3337 (remaining ≈ 128). That is inside the slide, and the hold names note 25.
2. A 9-pt nudge UP (offset 3328, remaining 137) gives probe ≈ 599. The tops are then 25@9, 26@129, 27@249, ch9@369, 28@430, 29@550, 30@670.
3. The rule names **note 29**, so the highlight jumps four notes DOWN while note 25 still sits at the very top of the page. A 9-pt nudge DOWN gives the same note 29.
4. Without any landing, her own scroll to that offset shows note 25 at the top and highlights note 29. At the bottom the edge rule's top row is note 26 and the slid probe names 30.

On the folded Sherlock (13 one-note chapters), the end of walk 2's A addition becomes "note 13" at the bottom (the fix). In the last viewport before it, though, the highlight runs up to three stories ahead of the card at the top.

**Why it matters.** Her ask is "the note that you're currently on". In the journal-trait shape round 1 named (short entries, newest last), the last page is where she lives. There the navigator and "note N of M" now name an entry up to a page below the one she is reading at the top. Round 1's MAJOR was the highlight stopping short of the end. This is the opposite overshoot across the same region, and it is milder: it resolves at the bottom and is monotonic.

**This is product silence (R-562-B is PROVISIONAL), so it goes to the bundle and `notes/QUESTIONS.md` and is not fixed here.** Options:
- **(a) Accept as ruled.** Correct the bundle's line to the true reach: any landing settling in the last viewport of scroll, either scroll direction; and her own scroll leads the top row by up to the last screenful's height.
- **(b) Narrow the slide to what the last screenful needs.** Slide from the edge to the last row's top at the bottom, `L = lastRowTop − remaining`. The page already holds that fact; L stays constant as she scrolls, so the probe stays monotonic. The slide runs over the last `min(L − edge, travel)` points of scroll instead of a full viewport. The bottom still views the last note, every last-screenful note is still reached, and the lead shrinks by `viewport − L` everywhere in the zone (≈ 170–225 pt, 1½–2 notes on the harness page). It does not remove the release-jump for a target settling inside the narrower zone (note 25 → 28 instead of → 29 above); some jump is inherent to any slide combined with a hold.

**Pin (born-red for (b); a documenting table for (a)).** A pure `BookOutlineFollower` table over a column with the harness pitches (cards 110 + gap 10, headings 51 + 10, viewport 734, travel 3465):
1. `landingStarted(note 25)`, then a settled `look` at offset 3337 gives note 25.
2. A `look` at offset 3328 gives (a) note 29, green on HEAD, or (b) note 28, red on HEAD.

**Walk 3 should look at it:**
- the own-scroll lead over the last page of the folded Sherlock;
- the release-jump, which needs a short target (Sherlock's note doors unfold their story, so use the harness, or a chapter heading of a multi-note book).

### N2. [NIT] · stale docs left behind by P-562-7 and finding 8
- `BookOutlineViewed.swift:75–79`: `Pair`'s doc still reads *"A chapter heading names the chapter alone; … (nil under the unfiled heading or a tag-path heading)"*. Since P-562-7, a heading names the note it introduces. The `named(at:in:)` doc (`:198–209`) is right; the type's doc contradicts it.
- `BookOutlineViewed.swift:483–485`: `BookNavigatorMark`'s doc still says the chapter row *"wears the quieter viewed-chapter wash"*. Since finding 8 the mark is the accent fill with the name in ink. The test name `onlyOutlineWashesTheViewedChapter` (`BookOutlineViewedTests.swift:756`) has the same staleness.
- `BookOutlineLandingTests.swift:2025–2032`: the CLICK pin's doc still frames its red-on-old as an open order question ("the stage window records which way it lands"). The window answered it: `vx562-revE-run.log`, RED, because on this host the reveal's `onChange` arrives first. Say so in the doc, so a later reader never takes the pin for a possibly-hollow one.
- `BookOutlineLandingTests.swift:1824–1826`: the END pin's doc spells its revert as "`return probe` as its first line". The record's recipe B is `slide = 0`. They are behaviourally equivalent; pick one spelling.
- `BookView.swift:2169–2173`: the page-height observer's comment names only R-562-A's on-screen test. Since r1 it is also R-562-B's slide input.

No pin applies (docs only).

### N3. [NIT] · record hygiene: the window's outcomes are recorded only at the outline-follow record's foot, so three earlier lines still read PENDING
- `vx-562-outline-follow.md:120–123`: ledger rows 1, 2 and 4 still read "r1 fixes BUILT-PENDING-SUITES" and "runs, reverts and round 2 the orchestrator's".
- `vx-562-outline-follow.md:150`: still "PENDING the orchestrator's window: every run … and recipes B, C, E".
- `vx-562-ladder-round1.md:176`, `:177`, `:179`: the as-built dispositions for 1, 2 and 4 still say "Red-on-old: PENDING" / "PENDING the stage window".

The outcomes themselves (`vx-562-outline-follow.md:343`) are correct, and I confirmed each against its log. A fresh session that reads the ladder file alone would still believe the reverts are owed. **Fix (the orchestrator's, repo-first):** flip those lines to the logs' verdicts, naming `vx562-revB/C/E/G-run.log`, `vx562-r1-full.log` and `vx562-final-run.log`.

---

## Process note (not a code finding): r1's use-shaped evidence is owed

CLAUDE.md: "a batch closes only on use-shaped evidence, never a pin or mount smoke alone". Walk 2 PRECEDED every r1 fix. What r1 changed on screen has been seen only by the test host and token maths: the sliding probe, the offset release, the heading naming its note, the one total and the viewed chapter's new fill. Walk 3 should cover:
1. Wheel to the very end of the folded Sherlock. Expect "note 13 of 13 · The Adventure of the Copper Beeches" with the fill on its row. Watch N1's lead on the way down.
2. The viewed chapter's fill in Study light and dark, and Terminal light and dark (finding 8; Study light and Terminal are token maths only).
3. A chapter heading at the top: the number stays (P-562-7).
4. R-562-C's motivating inputs after a mid-book click: keyboard paging (no editor focused) and a scroller-knob drag. Both should release the hold.
5. Finding 10's watch, now with the widened observer: count "OnScrollGeometryChange … multiple times per frame" and "Modifying state during view update" over an Outline scroll, a landing, and the Outline → Index departure.
6. If a short-note book is staged, N1's release-jump (one wheel notch each way after a click about a page from the end).

The two merge-time tickets the dispositions owe (finding 6's Debt/Low restructure and finding 12's Index → Outline caret block) are not yet filed. They belong to the closeout.

---

## Clean bill (load-bearing things in the FIX DIFF I checked and found solid)

- **R-562-C's key is taken at the right moment, every time.**
  - `land` always leaves a landing pending (`begin` sets the anchor, then `aim`, then `armAfterEvent`; `LandingAuthority.swift:560–568`). Nothing finishes synchronously, so no key can be taken before the landing's own scroll.
  - The target's row reports re-arm the quiet interval (`noteTop`, `:622–627`), so the offset the box holds at `onFinish` is the settled one.
  - `begin` supersedes without `onFinish`, and `landingStarted` resets the key (`BookOutlineViewed.swift:423–428`).
  - `end()` is silent, and `forget()` clears both fields.
  - Her phase still lets go before `userTookOver` (`BookView.swift:1826–1827`), so a landing she ends delivers the rule.
- **The widened observer keeps the landing's contract byte for byte.** Only a content-height change reaches `outlineContentResized` (`BookView.swift:1842–1844`), which is exactly what the old `CGFloat` transform fired on. Offsets write only the reference box (never render state) and queue the one-per-turn derivation. The 60-suite set, landing suites included, is green (`vx562-r1-full.log`).
- **`OutlineScrollFacts`' arithmetic is right whatever the insets.** `offset = contentOffset.y + insets.top` is 0 at rest. `travel = contentSize + insets.top + insets.bottom − container` is the maximum offset. These are read in the same frame as the rows' `outlineSpace` tops and the page-height viewport. The END print line confirms it: at the bottom `offset 3465 = travel 3465`, matching `doc 4199 − visible 734`.
- **`probe(_:)`'s edges are each a table line and correct:** an unmeasured page, a column that fits, overscroll at both ends, the exact one-viewport boundary (`remaining < slide`, so the edge holds there), and a short book. At fixed travel, the probe is monotone in the offset.
- **P-562-7's control flow is right.** `named(at:in:)`'s labelled `break inForce` leaves the loop (an unlabelled one would only leave the `switch`), and `continue` inside the `switch` continues the loop. In `positionLine` (`:337–345`), the unlabelled `break` inside an `if` exits its `for`. `adoptedPair` and the rule name through the same function, so a click's pair and the settled rule cannot disagree (pinned at `:319`).
- **Finding 7 changes no mark.** `BookNavigatorMark` (`:492–515`) already ignored the focus in Outline and the viewed pair elsewhere, so withholding them changes dependencies and nothing else.
- **Finding 3 says "N+" only when the window is truncated.** A truncated window is at least 300, so the plural is always right. `metaLine`'s defaulted parameter leaves `VocabularySweepTests`' three lines byte-unchanged.
- **The new DEBUG oracle (`outlineScrollStore`) is hygienic.** It is released by owner (`release(owner:)`) and forgotten with the pins (`forgetOutlinePins`). Every write is `#if DEBUG`. It is a static on a plain struct (`OwnedRegistrations`, `DebugOracleOwnership.swift:72`), so nothing is observed.
- **The fences hold.** Nothing in the fix diff writes `focus`/`focusedPostID`, the caret seeds, `pendingReveal`, `pendingChapterReveal` or a landing's aim. There is no new observer, dependency, schema or literal colour (the accent token × an opacity, the `MastheadPopover.rest` precedent). `notes/QUESTIONS.md` and the shared ledgers are untouched. P1 cost is unchanged: one O(rows) derivation per run-loop turn, with rows bounded by the 300-note window.
- **The new mounted pins are not hollow.** Each bug-class revert (B, C, E, G) went red on exactly its named `#expect`s, with every `#require` premise holding. The reds are verdicts, not harness gaps (`vx562-revB/C/E/G-run.log`, failure lines read).

## Verdict

**No new BLOCKER or MAJOR. This round does not earn a round 3.** Every round-1 disposition landed as written, and the bug-class ones are revert-verified. New from the fixes:
- **N1 (MINOR):** the reach of R-562-B's slide and its seam with the hold. It is a design consequence for the bundle and `notes/QUESTIONS.md`, and for walk 3 to judge.
- **N2, N3 (NIT):** stale docs and stale PENDING lines in the records.

The batch still owes walk 3's use-shaped evidence before ledger rows 1–2 close.
