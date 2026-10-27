# VX-562 — ladder round 1 (cold review, `opus-reviewer`)

**Diff:** `git diff e2b1349899c8eee7d623ec721bc25adaec32bd0e..HEAD` in `~/dev/variorum-vx-562` (branch `vx-562-outline-follow`, HEAD `d08908e60`).
**Prompt:** `notes/REVIEW_PROMPT.md`, run verbatim. **Anchor:** `notes/plans/fixes/vx-562-outline-follow.md` (§DESIGN, R-562-A, the self-assessment, §SUITE RUNS, §WALK).
**Read by me:** CLAUDE.md and the loaded canon; SurfaceContracts §The app and §The Bookcase and books; the record whole; every changed source and test file; `Surface/LandingAuthority.swift` lines 500–806; `BookOutlineRows.swift` (rows, segments); `BookViewModel` (focus, expand, collapse, spread, window); the navigator's body and foot; `VoiceTokens` (chromeLabel, wash, selectionMarker); `MastheadPopover.rest`. No suite was run: the claims checked against tests were checked by reading them and the record's §SUITE RUNS logs lines. One Sonnet lookup (external facts only) on macOS `ScrollPhase` behaviour; its result is quoted under finding 2.

**Scope check (first): the diff is inside `opus-reviewer` scope.** No editor seam: no `EditorTextView`, `BlockRangeIndex`, `PaneSurface`, `ReadPostView` internals or read-tier change. No custody or keychain code. Nothing under `Sources/VariorumCore/Sync/`. No default's meaning changes. `Surface/LandingAuthority.swift` changes one doc comment only (lines 670–676); its behaviour is untouched. The code changes are book-view chrome plus a read-only geometry consumer.

---

## Findings (severity-ranked)

### 1. [MAJOR] · `BookOutlineViewed.swift:111` (`pair`) + `BookView.swift:1635` (`deriveViewedPair`) · scrolling to the end of a book never reaches the last screenful's notes: the highlight and "note N of M" stop short of the end

**What's wrong.** The rule is "the last row whose top ≤ the 10-pt probe". The rows in the book's last screenful can never bring their top within 10 pt of the viewport's top, because the column's foot follows them (the end drop zone, the window line, "+ new note", the 22-pt padding; the record measures ≈120 pt). So when she scrolls to the very end of a book herself, `follow` has no adoption and returns the rule (`BookOutlineViewed.swift:181–190`). The rule names the row at the TOP of the page. The last several notes, which are all on screen, are never highlighted and never counted in the pin. R-562-A fixed this shape for LANDINGS only (the adopted target); her own scroll to the end gets no such fix.

**Evidence: the traced mechanism, and the suite's own measurement.** The F-1 pin's premises (`BookOutlineLandingTests.swift`, `aLandingOnTheLastScreenfulEndsOnItsTargetNeverTheTopRow`) measure this exact page. The last card stops at `top=519.0` (§SUITE RUNS run 1: "gave up at top=519.0"), and `try #require(ruled != target, "the premise: the rule names the top row")` holds. The F-1 page is the maximum-scroll page, because the landing cannot move the page any further. When the same page is reached by her own scroll, nothing is adopted, so `deriveViewedPair` publishes `ruled`, which is the top row. Rough arithmetic for the reach: with a ~850-pt page, ~100-pt cards and a ~120-pt foot, roughly the last 6–7 cards can never be "viewed" by scrolling. The record estimates "the last 3–4 stories" on Sherlock.

**Why it matters.** Her ask is *"make the note that you're currently on highlight on the left bar"* and *"show during scroll what # note you're in"*. In a journal-trait book, which sorts by `entry_date` ascending, the last screenful holds the NEWEST entries. That is where she most often is, and there the highlight and the pin always name an older entry. The top edge has the mirror shape by design (§DESIGN 1: at rest nothing is viewed, although the first notes sit on screen under the title block). That half is the architect's explicit design, so it is not a finding here; I mention it because one product answer could cover both edges.

**This is product silence → `notes/QUESTIONS.md`, not a ruling.** Options to bundle:
- (a) **The end clamp.** When the scroll is at its maximum offset (the column's content bottom is on the page), the viewed row is the LAST note whose top is on the page.
- (b) **The sliding probe** (the common scroll-spy shape). The probe moves from the page's top edge toward its foot as the scroll nears its end, so each of the last notes becomes viewed in turn on the way down.
- (c) Accept the gap, and say so in the contract line.

**Pin (born-red for whichever option she picks; red on HEAD for (a)/(b)).** In the `withLandingBook(posts: 30, chapters: true)` harness, `scrollDown` the clip to its maximum offset (the SCROLL pin's own road). Assert the pair is option (a)'s or (b)'s answer: (a) the book's last note; (b) the note the sliding probe names. On HEAD the pair is the top row, which is the F-1 premise's `ruled`.

### 2. [MINOR — rises to MAJOR if the walk shows it on a real input] · `BookView.swift:1828` (`outlineUserScrolled`), `:2168–2173` (`onScrollPhaseChange`) · R-562-A's "she has not scrolled" is detected only by the `.interacting` phase, so a scroll that arrives without that phase leaves the hold on the clicked target while the page shows other notes

**What's wrong.** The ruling: the adopted pair stands *"for as long as the target's row remains within the viewport and she has not scrolled"*. The only scroll signal wired is `phase == .interacting → outlineUserScrolled()`. Any scroll that moves the page without that phase keeps the adoption until the target's row leaves the page entirely (`BookOutlineViewed.follow`, `isOnScreen`).

**Mechanism.**
1. A navigator click on note T lands T at the top, and the adoption stands.
2. She scrolls UP by most of a page without the phase.
3. T's top moves to around +600..+800 pt, so T is still on the page.
4. `follow` therefore keeps T. The pin keeps saying "note 13 of 30", and the navigator keeps marking T, while the top of the page shows notes 9–12.
5. The divergence lasts until T's top passes the page's foot: up to one page of scrolling in either direction. Scrolling DOWN through a short card releases sooner, because the card scrolls off the top quickly.

**Reach (SPECULATIVE: which real inputs produce no `.interacting`).** The Sonnet lookup found no Apple documentation or credible report that settles whether a classic notched mouse wheel, keyboard scrolling (Page Up/Down, space) or a scroller-knob drag produces `.interacting` on macOS. AppKit documents that *"legacy scroll wheel events … have a phase of NSEventPhaseNone"*, so "no `.interacting`" is plausible for a wheel but unconfirmed. The record already lists keyboard paging as unverified (self-assessment risk (5)). The walker noted that `Tools/WalkKit/scroll.swift` posts phaseless line-unit wheel events, so walk leg 6 may not be able to produce the phase either.

**Pin — red on HEAD regardless of the input question.** The SCROLL pin's clip scroll is itself a phaseless scroll (its own doc says so). Extend `herScrollAfterALandingReturnsTheFollowerToTheRule`:
1. After the landing on note 13 has ended and the target stands, `clip.scroll` UP by ~400 pt so the target stays on the page (`#require` T's top is between 0 and the page height).
2. Assert the pair is the rule's: `BookOutlineViewed.pair(rows:tops:)` over the oracle's tops, which is an earlier note.

On HEAD the pair stays the target.

**Proposed fix.** Release on GEOMETRY as well as on the phase.
- At the landing's end, record the adopted row's settled top in the box.
- In `deriveViewedPair`, with no landing pending, drop the adoption once the adopted row's top has moved from that settled top by more than the landing tolerance.

This catches every scroll input, phased or not. It keeps the F-1 hold (a target the page cannot move stays put) and the click-time adoption. The one new consequence to state: a row ABOVE the target growing after the landing (late text loading) also releases. The landing's quiet interval makes that rare. It is arguably right, since the page moved.

### 3. [MINOR] · `BookView.swift:2524–2529` (`bookMetaLine`) + `BookOutlineViewed.swift` `positionLine` · in a book past the 300-note window, the pinned line contradicts itself: "book · 300 notes · note 12 of 300+"

**Mechanism.** `bookMetaLine` hands `notes: model.entries.count`, which is capped at `BookViewModel.entryWindow` = 300, with no at-least marker. `positionLine` hands `totalIsAtLeast: model.truncated`, which says "300+". P-562-3 moved the meta onto the same line as the position, so both numbers now sit side by side. The meta's window-count was already inexact in the scrolling title block before this diff; the juxtaposition is new.

**Reach.** Any book over 300 members. The daily Journal crosses this in under a year of daily use. SurfaceContracts §The Bookcase and books: "Counts are honest".

**Pin.** A pure `BookViewCopy.outlinePinLine` / `metaLine` table test with `notes: 300, truncated: true` asserting one consistent count. Or a mounted assertion on `outlinePinLines` over a 301-note `withLandingBook`. Red on HEAD.

**Fix.** Give `metaLine` the window's at-least flag ("300+ notes"). Or drop the meta's note count from the pin when a position is said. Either is a wording call; bundle it with P-562-3.

### 4. [MINOR] · `BookOutlineLandingTests.swift` (the four new mounted pins) · the feature's main door, the navigator click (`BookNavigatorDoor.openTheNote` = `focus` + `requestReveal`), is never driven, and the `isPending` guard in `releaseStandingAdoption` (`BookView.swift:1681–1684`) has no pin

**What's untested.** All four new mounted pins move the page with `model.requestReveal(_:)` alone. The FOLLOW pin focuses a different note first, by design. None drives the click road the record's own risk (1) says to stare at: `focus(T)` inserts T into `expandedPosts` (an axis change) in the same act as the reveal, and SwiftUI's order between the two `onChange`s is not ours.

**Mechanism the guard exists for.**
1. The `pendingReveal` onChange runs first: `landOutline` adopts T, and the landing becomes pending.
2. The `expandedPosts` onChange runs second.
3. Without the guard, it clears `adoptedAnchor`. The slot still says T, because the freeze holds the slot.
4. At `DONE`, `follow` runs with no adoption and returns the rule.

On a SHORT note in the last screenful (a one-paragraph entry stays short when expanded), that is the F-1 wrong row again, reached through the real click.

Deleting the guard today fails no test. The F-1 pin uses `requestReveal`, so no `expandedPosts` change happens on its road.

**Pin.** The F-1 harness with a short last note, driven through `BookNavigatorDoor.noteRowClicked(entry, model:structure:)` in `.outline` (or `openTheNote`). Assert the pair at `DONE` and 12 turns later is the target.

**Honest label.** Whether this goes red with the guard reverted depends on SwiftUI's delivery order of the two `onChange`s. If `expandedPosts` is delivered first, the guard is moot on this host and the pin is green on both sides; the reviewer of the fix should run the revert and record which. Even then the pin earns its place as coverage of the primary door, which currently has none in the new suites.

### 5. [MINOR] · `BookOutlineViewed.swift:94` (`viewedIndex`) · "THE RULE, on its own" is a test-only twin; the monotonicity pin does not exercise the shipped rule

**What's wrong.** Production never calls `viewedIndex`; I grepped `App/Variorum` and found only the definition and tests. `pair(rows:tops:probe:)` (`:111`) re-implements the same loop inline. So `theRuleIsMonotonicInTheProbe` and two cases in `aRowWithNoReportedTopIsSkipped`/`anEmptyBookViewsNothing` pin a function that ships unused. A future edit to `pair`'s comparison, for example `<` for `<=`, or an early `break`, keeps every `viewedIndex` assertion green.

**Evidence.** Grep: `viewedIndex` appears at its definition and in `BookOutlineViewedTests` only.

**Fix.** Either have `pair` call `viewedIndex` (build the `[CGFloat?]` from `rows.map { tops[$0.id] }`, then resolve the chapter in a second O(rows) pass), or delete `viewedIndex` and restate the monotonic table over `pair` with a flat row list. A cleanliness finding, not a bug: no pin applies.

### 6. [MINOR] · `BookView.swift:1599–1693`, `:1747–1832`, `:2190–2241` · architectural: the follower's state machine is spread across eight call sites in the 3,700-line view, which is why its two ordering-sensitive releases are unpinnable

**What's spread.** The follower's state lives in:
- the box's fields;
- `queueViewedPair`, `deriveViewedPair`, `adoptLandingTarget`, `releaseStandingAdoption`, `forgetViewedPair`;
- three lines in `landOutline`, `outlineAnchorMoved` and `outlineUserScrolled`;
- five `onChange`/`onAppear`/`onDisappear` handlers;
- one `onGeometryChange`.

**What the ruling depends on.** Two ordering rules:
- the phase release clears the adoption BEFORE `userTookOver`, whose `onFinish` derives synchronously;
- the axis release skips a travelling adoption.

Both are reachable only through a mounted view and SwiftUI's event delivery. The phase release is unreachable in the test host (U8), and the walk that was to evidence it is blocked (§WALK). Findings 2 and 4 are this degradation.

**Fix (for a later touch, not a blocker).** Move the box's follower half (`rowTops`, `rowExtents`, `viewportHeight`, `adoptedAnchor`, the turn flag) and its six transitions into a small `@MainActor` reference type beside `BookOutlineViewed`: `report`, `adopt`, `releaseStanding(isPending:)`, `userScrolled`, `derive(isPending:mode:rows:)` and `forget`. Take the landing's `isPending` as an argument, so a headless table test can drive "click → expansion → DONE" and "scroll phase → finish" in both orders. P-9's hygiene rule applies; the view keeps only the wiring.

### 7. [NIT] · `BookView.swift:2870`, `:2905` · in Outline every navigator label still reads `model.focusedPostID`

`BookNavigatorMark.note(... focusedPostID: model.focusedPostID ...)` is evaluated eagerly, so in Outline every focus change re-renders every navigator label, though Outline's mark ignores focus. The cost is O(navigator rows) per focus act, which is not hot. A `mode == .outline ? nil : model.focusedPostID` at the call site drops the dependency. Cleanliness only.

### 8. [NIT — the walk's check] · `BookView.swift:2802`, `:2931` · in Study the viewed-chapter wash may be nearly invisible

Study's `wash` is already translucent: `0x3D6B8E.opacity(0.12)` light and `0x82ABCC.opacity(0.13)` dark (`VoiceTokens.swift:357`, `:394`). `× 0.55` gives an effective alpha of ≈0.066–0.072. Study's `selectionMarker` is `""`, so in Study the note mark is the title's ink change alone. The dev store is Study. The `MastheadPopover.rest` precedent is real, but that chip sits on a known background inside a bordered popover. The walk should capture the chapter wash in Study light and dark and say whether it reads. Taste call; not pinnable.

### 9. [NIT — SPECULATIVE] · `BookView.swift` `OutlinePinnedLine` (`:2990`) · the pin's left edge can drift from the prose column's when legacy scrollers are shown

The prose column centres inside the ScrollView's content width. The pin centres in the full width (both use `.padding(.horizontal, 20)` and a `proseColumn`-capped frame). With "Show scroll bars: Always", the content width loses the scroller's ~15 pt, so the column shifts left by about half of that relative to the pin. With overlay scrollers, the default, they coincide. Walk check only.

---

## Process note (not a code finding)

Ledger rows 1–2 read SUITES GREEN, but the walk (row 3) is BLOCKED at its premise, and it is the only evidence for R-562-A's phase release (leg 6) and for finding 2's real-input reach. CLAUDE.md: "a batch closes only on use-shaped evidence, never a pin or mount smoke alone". The rows cannot close on the suites. The re-walk should also cover findings 1 (scroll to the very end of the book), 8 and 9.

---

## Clean bill (load-bearing things checked and found solid)

- **The fences hold.** The follower writes only `OutlineLandingBox` fields and `BookViewModel.noteOutlineViewed`. `adoptLandingTarget`, `deriveViewedPair`, `releaseStandingAdoption` and `forgetViewedPair` never touch `focus`, `focusedPostID`, the caret seeds, `pendingReveal`, `pendingChapterReveal` or the landing's aim. `viewedOutlinePair` is `private(set)` with one writer. Her ruling is honoured in the mark table: in Outline the caret is ignored.
- **The pinned line is outside the scroll.** It is a sibling in the `.outline` VStack (`BookView.swift:316–322`). Every anchor top is still measured in `outlineSpace`, the ScrollView's own space, so no landing math moved. §SUITE RUNS run 2 (266/56, the 4 standing `IndexTierMetricsTests` known issues only) is the landing suites' guard, and the FOLLOW pin asserts the pin frame unmoved across a long travel.
- **Every other mode's marks are byte-identical.** Spread: `spreadEntries.map(\.postID).contains` is exactly `isOnSpread`'s fact (`BookViewModel.swift:468–470`). Read and Index: `focusedPostID == postID`, unchanged. The one-note chapter row's marker is the note rule, unchanged. The chapter label's frame/contentShape/`navigatorRowFrame` chain is layout-equivalent to the old inline one.
- **`NoteBoxCopy.whereLine` is byte-identical after the factoring.** I traced `placePiece`/`chapterPiece` against the old body: same guards, same strings, same order.
- **The freeze and the adoption, as ruled.** `deriveViewedPair` returns early while `isPending`. `adoptLandingTarget` runs BEFORE `landing.land`, so the slot says the target from the click. `LandingAuthority.begin` supersedes a pending landing without calling `onFinish` (`LandingAuthority.swift:590–616`), so a superseded landing never derives. `finish` calls `onFinish` last, with the authority idle, so the end-of-landing derive is never frozen. `end()` is silent, so `onDisappear` never derives on a dead page.
- **No retain cycle.** `onFinish` captures the authority weakly, plus the box, model and structure; the queued hop is one-shot.
- **P1 / P-8 cost.** O(1) per row report (two dictionary writes and a flag). At most one O(rows) derivation per run-loop turn. Rows are bounded by the 300-note window, never the corpus. Pair changes re-render only the navigator labels and the pin, which are their own views; `BookView.body` never reads `viewedOutlinePair` (grep: readers at `:2871`, `:2906`, `:2911`, `:3038` only).
- **Every row reports, realized or not.** `OutlineRunRow`'s placeholder keeps its anchor's `onGeometryChange`, and expanded rows report through `outlineAnchor`, so `rowTops` is the column's whole geometry, as the box's doc claims.
- **The rule's edges are pinned and correct.** Covered: a tall story spanning the top, a chapter heading alone, unfiled and tag-path headings naming nothing, a stale top for a departed row ignored, the probe = `BookOutlineHeights.rowSpacing` ≥ `landingTolerance` so a landed row is always the viewed one. `adoptedPair` is the rule over `[anchor: 0]`, so the click's pair and the settled rule agree (pinned).
- **The F-1 hold works as ruled R-562-A.** The pin's premises are real `#require`s, and §SUITE RUNS shows them holding ("gave up at top=519.0 after 14 hops, 4061 ms", the pair the target throughout).
- **Copy and tokens.** Every new rendered string is sentence case ("note 5 of 12", "unfiled"). The pin is `lineLimit(1)` with tail truncation. The wash is token × opacity with the `MastheadPopover.rest` precedent (`MastheadPopover.swift:32`); no literal colour. "unfiled" in the pin matches the contract's "the chapterless group reads 'unfiled' everywhere".
- **The navigator's ±6-pt bleed.** The scroll's −6 outset stays inside the navigator's own `.padding(12)` (`BookView.swift:994`), so nothing draws outside the panel.
- **The DEBUG oracles.** The four new stores are released by owner in `release(owner:)` and forgotten in `resetNavigator`/`forgetOutlinePins`. No oracle code is outside `#if DEBUG`.
- **Not flagged (ruled or recorded):** the width change re-landing `topRow` and adopting it; an expansion after a landing returning to the rule; P-562-1…5; the pre-existing watchdog spin (ticketed).

## THE ORCHESTRATOR'S DISPOSITIONS (same-model ladder — arbitrated against the spec, repo-first before any fix session reads them; 2026-10-27)

- **1 [MAJOR] — AGREE, FIX NOW under R-562-B below.** The reviewer is right that R-562-A covers landings only: on her OWN scroll the last screenful's notes can never highlight, which collides head-on with her pre-launch sentence ("make the note that you're currently on highlight on the left bar ABSOLUTELY") in exactly the journal-end shape she lives in. Option (b), the sliding probe, is ruled; (a) clamp-at-end fixes only the very bottom; (c) accept-and-document fails her sentence. Red-on-old pin: clip-scroll to the maximum offset, assert the LAST note is the viewed one — RED on this tree. PROVISIONAL for her; a QUESTIONS entry at the merge.
- **2 [MINOR] — AGREE, FIX NOW under R-562-C below.** The reviewer's own fix shape (release on the adopted row's top moving) is DECLINED for a sturdier equivalent: an above-row async fill can move a row's top without any scroll, while the page's scroll OFFSET moves only when something scrolls the page — so the release keys on the offset, not the row. Red-on-old pin: after a landing, clip-scroll ~400 pt with the target still on screen, assert the rule's pair — RED on this tree (the clip scroll has no phase). The walk's leg 6 stays the real-input evidence either way.
- **3 [MINOR] — AGREE, FIX NOW.** One honest total feeds BOTH pieces of the pinned line; whatever the 300-note window caps, the line never contradicts itself. Verify the window mechanism at fix time; table-test through the pure composition with injected counts.
- **4 [MINOR] — AGREE, ADD THE PIN** on the real navigator-click door (focus + reveal in one act). The fix session runs the `isPending`-guard revert and RECORDS which way the pin lands (order-dependence is the fact to capture); round 2 re-checks.
- **5 [MINOR] — AGREE, FIX.** Delete the `viewedIndex` twin; the monotonicity pin exercises the shipped `pair` directly.
- **6 [MINOR, architecture] — PARTIAL.** The fix session consolidates the ADOPT/RELEASE DECISION into one headless, table-testable function on the box as part of landing R-562-B/C (that is what makes pins 2 and 4 drivable without SwiftUI ordering); the fuller eight-site restructure of `BookView` is DEFERRED — ticketed at the merge (Debt, Low) per the deferred-work rule.
- **7 [NIT] — FIX IF TRIVIAL** in the same pass (Outline labels stop re-rendering on focus changes they no longer read); else record here and move on.
- **8 [NIT] — AWAIT WALK 2's wash-visibility leg** (the store is Study, so the walk answers it directly). Invisible ⇒ fix in this pass with a token-only composition that reads in both voices; visible ⇒ record.
- **9 [NIT] — RECORD-ONLY** unless the walk shows the 7-pt scroll-bar offset; speculative, no mechanism traced.

### R-562-B (the end-of-book probe — finding 1's fix; PROVISIONAL for her)

The probe slides down the page over the LAST viewport of scroll. While `remaining = docHeight − offset − viewportHeight ≥ viewportHeight`, the probe is the top edge + ε exactly as shipped; inside the last viewport it interpolates linearly from the top edge toward the viewport's bottom as `remaining → 0`, so at full bottom the LAST row is the viewed one and every last-screenful row is reachable on the way down. The rule stays pure (its inputs gain offset, document height and viewport height — all already in the box), stays monotonic (table-pinned: scrolling down never decreases the viewed index; at the maximum offset the viewed note is the last), and R-562-A's adoption sits unchanged on top of it.

### R-562-C (the input-independent release — finding 2's fix)

A standing adoption ALSO releases when the page's scroll offset has moved more than a small threshold — 8 pt, a named pinned constant — from its landing-end value. Any input that actually scrolls the page (phased trackpad, phase-less wheel, keyboard paging, a scroller drag) therefore releases; the `.interacting` phase release stays as the immediate road; settle wobble under the threshold (the F-1 give-up page included) never releases.
