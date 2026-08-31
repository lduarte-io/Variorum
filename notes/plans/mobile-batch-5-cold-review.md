# Mobile round 2, batch 5 — COLD REVIEW

**Diff under review:** `e5a6316^..05853b9`, restricted to `App/` and its tests
(11 files, ~2093 insertions / ~83 deletions). Reviewed cold, with no
description of the work: everything below is derived from the diff and the
repository.

**Verification I ran myself** (isolated DerivedData `dd-b5`, simulator
*[removed for publication]*

- Full mobile suite: **568 tests in 92 suites passed, 123.7 s, TEST
  SUCCEEDED** — exactly the stated baseline.
- The four new/changed suites re-run alone to harvest their `PERF[sim]`
  lines; every number quoted below with a `measured:` prefix is from that
  run, not from the record.
- Hygiene: zero `Sources/` lines, zero `Sources/VariorumCore/Sync/` lines,
  no build-configuration files, no schema, marker unchanged. Confirmed
  against `git diff --name-only`.

**Severity counts: 1 MAJOR · 4 MINOR · 5 NIT · 0 BLOCKER.**

---

## MAJOR

> **✔ FIXED 2026-08-30**, with the gate this finding proposed and over the
> machinery it named. The seed moved out of the shell into
> `VariorumMobileApp`'s own task, AFTER `services.start()`, and now declines
> until a device that belongs to an account has completed a first CLEAN round
> — declining without consuming the mark, so the next launch asks again.
> **The finding's own script is pinned** (`herCorpusArrivingDuringTheWaitCancelsTheSeed`)
> and proven red at `books.count → 2`. One residual is the AUTHOR'S call and
> is recorded rather than closed: a fresh install where she signs in AFTER the
> shell appears. Record: `notes/plans/mobile-major-fix-round-record.md` (B1).

### [MAJOR] · `App/Variorum/VariorumMobile/Features/Shell/MobileStarterJournal.swift:12-37` + `MobileShellView.swift:167-174` · the starter-Journal seed runs before sign-in is *possible*, so its virgin-store guard cannot do the job its own header claims

**What's wrong.** The file's header states the guard's purpose in terms
this batch does not achieve:

> *"A **virgin-store guard**: the store must hold NO live book and NO live
> note. … which is what protects a phone that syncs an existing account
> down"*

That protection does not exist, because the guard is evaluated strictly
before any sync can have happened — and, on a fresh install, strictly
before the user can even sign in.

**Evidence — traced mechanism (READ-ONLY; not driven against a live
mirror).**

1. `VariorumMobileApp.swift:48-51` renders `MobileShellView` the moment
   `bootstrap.state == .ready(session)`. There is no signed-out gate: the
   `state` cases are `.ready` / `.opening` / `.locked` / `.failed`.
2. `MobileShellView` attaches two sibling `.task` modifiers. One
   (`VariorumMobileApp.swift:60-98`) constructs `AppServices` — which is
   where `SyncSession` lives (`AppServices.swift:183`) — and `await`s
   `fresh.start()`. The other (`MobileShellView.swift:167-174`, new in
   this diff) calls `MobileStarterJournal.seedIfNeeded`. They are
   concurrent and unordered.
3. `storeIsNew` is one local read (`Queries.readings` +
   `Queries.library(limit: 1)`). This batch's own perf pin measures a
   bare-store mint at **4.181 ms**; a first pull is a network round trip.
   The seed wins essentially always.
4. **The sign-in door is inside the shell.** It lives in
   `Shared/AuthViews.swift`, reached through `MobileSettingsView`
   (`MobileShellView.swift:188`). On a brand-new install there is *no
   ordering in which the user has signed in before this task runs* — the
   only surface that offers sign-in is behind the view whose appearance
   triggers the seed. The keychain question is therefore irrelevant: the
   reachable path does not depend on it.

**Consequence.** A phone joining an existing account mints a `Journal`
reading, designates it as `daily_journal_book`, pins it to the shelf, and
mints a `"Your journal"` note — and only then does her real corpus arrive,
carrying her own `Journal`. `reading` is a synced table with a trigger-fed
outbox (SyncSpec §3), so the spurious book and its note are ordinary
inserts that **propagate to every device on the account**, including the
Mac. The designation converges back to hers by CAS (server-version-wins on
`setting`), but the duplicate book does not converge away — nothing in the
merge matrix or §7's repairs touches it, and by design nothing should.

The same shape reaches a *new* user with both apps: the phone seeds a
Journal while the Mac's own `insertDailyJournalBook`
(`Operations+Container.swift:217-229`) mints another on first ⌘J, before
either has synced.

**Why the existing pins do not cover it.** `aStoreWithOnlyBooksIsNeverSeeded`
is annotated *"an account synced down before its notes arrive"* — but it
seeds the book **first** and then asks. It proves the predicate is correct
when content is present; it says nothing about *when the predicate is
asked*, which is the whole of this finding.

**Pinnable red-on-old:** yes. A pin asserting that `seedIfNeeded` refuses
while a configured sync has not completed a first round fails on this tree
and passes after a fix — so this is not a hollow finding under the
hallucination guard.

**Proposed fix (concrete, and the machinery exists).** `SyncSession`
already exposes `isConfigured` (`SyncSession.swift:40`) and
`onRoundCompleted` (`:46`). Gate the seed:

- if sync is **not configured** (nobody is signed in) the store genuinely
  is this device's — seed as today;
- if it **is** configured, wait for the first `onRoundCompleted` (bounded
  by a timeout) and re-run `storeIsNew` before minting.

An alternative worth weighing at the same call: move the seed to an
explicit first-run moment she can see, rather than an unprompted write to
her real store at launch. Note that `MobileTutorialSeeder` — cited as the
precedent — is **user-invoked and DEBUG-only**; it is a precedent for the
quiet facade, not for seeding automatically at launch. This is the app's
first unprompted write to a real store.

---

## MINOR

### [MINOR] · `MobileShelfLayoutTests.swift:373-383` · `theFloorIsSixRealLinesOfWriting` asserts a constant against its own definition

```swift
#expect(floor == CGFloat(MobileShelfLayout.guaranteedWritingLines)
        * MobileShelfLayout.smallLineHeight
        + MobileShelfLayout.writingBoxChromeHeight)
```

That expression is `minimumWritingHeight`'s body verbatim
(`MobileShelfLayout.swift:95-97`). It cannot fail while the definition
stands, and it changes with any change to the definition — so it pins
nothing and it is a line to edit rather than a guard. The review contract
names this class explicitly.

The test's **first** expectation — `writingLineCap(floor) >= guaranteedWritingLines`
— is real and should stay: it cross-checks two independent derivations
(the floor and the line cap) and would fire if either drifted.

**Fix:** delete the second `#expect`; the doc comment's claim ("a floor
expressed in points would drift") is carried by the first one.

**Label: READ-ONLY** (verified by reading both expressions).

---

### [MINOR] · `MobileShelfLayoutTests.swift:704-726` (with `:143`) · the largest-Dynamic-Type pin exercises the one voice whose type does not scale — and my run proves it changed nothing

`theWritingRoomHoldsAtTheLargestTextSize` overrides
`preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge` on a
surface hosted by `shelfSurface`, which hardcodes `tokens: .terminalLight`
(`:143`).

In `Shared/Theme/VoiceTokens.swift`, terminal's fonts are
`body: .system(size: 14, design: .monospaced)` (`:181`) and
`small: .system(size: 11.5, design: .monospaced)` (`:184`) — **neither uses
`relativeTo:`, so neither scales.** Only the Study voice's
`body`/`title`/`heading` are `.custom(…, relativeTo:)` (`:248-250`).

**Measured proof (from my run):**

```
PERF[sim] guarantee at AX5 on a 320×693 screen — books 295.66666666666663 · writing 295.66666666666674
PERF[sim] guarantee at 320×693           — books 295.66666666666663 · writing 295.66666666666674
```

Byte-identical. The trait override had **zero** effect on the surface under
test. The pin's own doc comment states the fact ("the terminal voice's is
fixed") and then measures terminal anyway.

**Honest scope:** I traced the underlying guarantee and it *does* hold in
Study at AX5 — with ≥8 books `wanted` collapses to `min(rowCap, shareCap)`,
which the row-height estimates never enter, and the field's own font is
fixed-size — so this is a hollow pin, not a hidden bug. It is reported
because the batch presents it as the worst-case evidence for a guarantee
the author asked for by name.

**Fix:** host `.studyLight` for this pin (and/or add a Study case to
`theWritingRoomHoldsOnEveryScreen`).

**Label: MEASURED.**

---

### [MINOR] · `MobileShelfLayoutTests.swift:143`, `MobileShelfTodayDoorTests.swift:39` · every absolute figure in this batch is a harness number the device cannot reach — the rendered pins host with no tab bar and no safe areas

`shelfSurface` and `todayShelf` both pass `tabBar: { EmptyView() }`. The
real shell passes a real tab bar (`MobileShellView.swift:113`), and
`tabBar()` is the **last element of the same VStack the GeometryReader
lives in** (`MobileShelfView.swift:135`) — so on device it removes its own
height from `proxy.size.height`. `HostedSurface`
(`MobileSurfaceDriver.swift:215-221`) builds a bare `UIWindow(frame:)` at
sizes that never match the simulator's screen, so its safe-area insets are
zero.

**Measured (my run):**

```
PERF[sim] shelf regions at 932 pt OPEN — books (0.0, 88.0, 430.0, 378.0) · writing (0.0, 466.0, 430.0, 466.0) (50.0% of the screen)
```

**Arithmetic projection from measured constants** (labelled as a
projection, not a device measurement): the tab bar is 12 + 8 padding + one
`small` line (measured 13.72) + a 1 pt rule ≈ 35 pt; a modern iPhone adds
~59 pt top and ~34 pt bottom safe area. Region falls from 844 → ~715, and
with 14 books `shareCap` binds, so writing lands near **~357 pt (≈38 % of
the screen)**, not 466 pt / 50.0 %.

**Why it matters and why it does not.** The *guarantee* survives — the
floor is a hard `max()` clamp in `split` — but the commit message's
"466 pt, 50.0% of a 932 pt phone" and "Worst case 144 against a 140 floor"
read as device facts, and the harness structurally cannot produce them. On
a real small phone with the keyboard up the 140 pt floor becomes the
*binding clamp* rather than a 4 pt cushion, with the books squeezed to
whatever remains.

**Fix:** host the real tab bar (or a spacer of its measured height) in the
rendered pins, or restate the record's numbers as harness-region figures.

**Label: MEASURED harness numbers + READ-ONLY projection to device.**

---

### [MINOR] · `MobileQuickNote.swift:1136-1141` + `MobileShelfView.swift:98` · a collapsed writing region can be overflowed by the box's own optional rows

`MobileQuickNoteBox` is given `.frame(height: split.writingHeight, alignment: .top)`,
and at rest `writingHeight == collapsedWritingHeight == 70`.
`writingBoxChromeHeight` (56) accounts for the field's 10 pt vertical
padding ×2, the 6 pt VStack spacing, the status row and the 8 pt bottom
padding. It does **not** account for the box's two optional rows
(`MobileQuickNote.swift:1032-1050`), each a `lineLimit(3)` `small` `Text`
plus 6 pt of spacing — up to ~48 pt each.

**Reachable sequence:** a refusal sets `lastError` (`MobileQuickNoteCopy.refusal`
— e.g. the `StoreLockedError` re-lock seam the code names), or a
multi-paragraph capture edited inside its frozen prefix sets `boundaryNote`
(`applyingChange` → `heldAtBoundary`); she then taps away, `focused` goes
false, `setFocused(false)` collapses the region to 70 pt — while the box's
content wants ~110 pt (one optional row) to ~160 pt (both). SwiftUI's
`.frame(height:)` does not clip, so the surplus draws over the shelf's
report/error rows and the tab bar below it.

No data is at risk. But it lands on exactly the surface a refusal is trying
to be honest on, and the batch's own P-8 discipline (`lineLimit` beside
growing chrome, added in three places in this very diff) is about the same
class of hazard.

**Fix:** include the optional rows in the collapsed height, or clamp them
to one line while `collapsed`.

**Label: READ-ONLY** — I could not add a pin (the tree is shared and I may
not edit `.swift`). The experiment that would settle it: host the shelf,
set `lastError` and `boundaryNote`, leave the box unfocused, and compare
the box's rendered `UIView` height against `split.writingHeight`.

---

## NIT

### [NIT] · `MobileShelfLayout.swift:122` · `minimumWritingLines` can ask for more lines than a below-floor region can draw

`writingLineCap` floors at 3 lines (42 pt of field). With `region == 80`
(`aRegionBelowTheFloorGivesEverythingToWriting`), `fieldMinHeight` is
`80 − 56 = 24` while the cap permits 42 — the same non-clipping overflow as
the MINOR above, smaller. Already acknowledged inside
`theLineCapFitsInsideItsOwnRegion`'s own exception, so recorded rather than
argued.

### [NIT] · `MobileShelfLayoutTests.swift:740` · the row-height constant's tolerance is ±29 %

`#expect(abs(measured - bookRowHeight) <= 12)` against a 42 pt constant.
**Measured: 39.0 vs 42.0** — a real 7 % *over*-estimate, which the file
header's "fails if a constant drifts out of tolerance" oversells: a
restyle to 30 pt or 54 pt would also pass. Note the measured direction is
the opposite of the one `underestimatingTheBooksOnlyEverGivesWritingMore`'s
prose reasons about — that pin's actual assertion (writing is monotone
non-increasing in `bookRows`) is sound and worth keeping; only its doc
comment's framing is off.

### [NIT] · `Features/Tutorial/MobileTutorialSeeder.swift:258-267` · the pocket guide now describes a shelf that does not exist

The "getting around" lesson names *"✎ Today's Entry opens today's journal
page"* with no hint that it is now a badge on the Journal book's row, and
`grep` finds **no mention of the quick-note box anywhere in the seeder** —
the surface this batch just made the shelf's main area, half the screen.
The box's omission predates this batch (3b); the Today move is this
batch's. The tutorial spine stayed green only because it asserts store
outcomes, not this prose (P-6 is satisfied; the guide's accuracy is not).

### [NIT] · `MobileQuickNote.swift:1080-1088` · a collapsed box silently truncates a multi-line capture to one line

`lineCap == 1` while collapsed, with no truncation affordance beyond
`✓ saved`. Correctly implemented to her sentence and honestly marked
PROVISIONAL; recorded so the consequence is in front of her at the walk
rather than discovered on the device.

### [NIT] · `MobileShelfFaces.swift:127-131` · the Today door's words now have a third home

Consolidating the phone's two doors onto `todayDoorTitle` /
`todayDoorRowTitle` / `todayDoorSpoken` is the right move and exactly the
one-home discipline. The Mac still carries the literal at
`Variorum/Features/Shelf/ShelfView.swift:190` and
`Registry/CapabilityRegistry.swift:1378`. Not a brain, not new, and not
this batch's to fix — enumerated so a future hoist has it named
(`KnownIssuesAndTechDebt.md`'s forked-brains row is the family).

---

## Clean bill — load-bearing things I specifically checked and found solid

- **The split partitions exactly, and the floor is a real clamp.**
  `split` returns `books + writing == region` for every non-negative
  region by construction (`writing ≤ region` on both arms of the `max`),
  and `theWritingFloorIsAGuaranteeInEveryShelfState` asserts the *promise*
  over 2408 states rather than the arithmetic — which is the right shape
  for a guarantee that must survive a later layout change. Verified by
  reading the arithmetic and by the pin's own run.
- **`focusingTheRealFieldOpensTheBox` is a genuine end-to-end pin, not a
  model poke.** It takes focus via `becomeFirstResponder()` on the field's
  real backing text view and measures 70 → 466 → 70. The disclosure that
  `accessibilityActivate()` returns false here — and that the model-driven
  pins are therefore a stated limit rather than a shortcut — is exactly
  the honesty the review contract asks for. Measured in my run:
  `at rest 70.0 pt · focused 466.0 pt`.
- **`aBooklessCaptureDoesNotWakeTheShelfObservation` is a structural
  assertion, not a timing.** The shelf's held observation reads
  `reading`/`reading_post`/`reading_section` + the `setting` row; a
  bookless `importPost` touches `container`/`block`/`variant`, so
  ValueObservation's region tracking cannot notify. Measured ticks
  `1 → 1`. This is the P1 question §53 asked, answered the way it should
  be — a fact about what the store notifies, which cannot pass by being
  fast.
- **The mint really is flat in corpus size.** Measured 4.181 ms bare vs
  4.106 ms against the 100k-word / 300-note / 6-book world (ratio 0.98×);
  the 12-paragraph paste 17.550 → 17.151 ms; keystrokes 0.0043 →
  0.0040 ms. No scan hides in the capture road.
- **The seeded book matches the core's own shape byte for byte.**
  `MobileStarterJournal.mint` builds curated · `profile: "journal"` ·
  `entryDate` ascending · designated · pinned, in one `runner.run` turn —
  identical to `Operations.insertDailyJournalBook`
  (`Operations+Container.swift:217-229`), and it reuses
  `Operations.defaultDailyJournalBookName` rather than a second literal.
  A phone that seeded and a phone that pressed Today's Entry first
  genuinely do converge on the same shape.
- **The starter entry deliberately carries no `entry_date`, and the
  reasoning holds.** A fabricated day would make it a DAY, and the
  Fragments bridge pushes by `entry_date` — so a stamped starter note
  would invent an entry in her other app. `theStarterEntryIsNotTodaysEntry`
  drives this end to end (seed, then press Today) and pins the sort
  consequence rather than leaving it to be discovered.
- **The seed is quiet.** `Operations(undoStack: nil)`, pinned by
  `theSeedIsQuiet` — a first launch leaves no structural-undo entry
  pointing at furniture she never placed. Correct per AppSpec §9's undo
  doctrine.
- **`seedIfNeeded` never throws.** Every road returns an `Outcome`; a
  refused seed cannot block a launch. Matches
  `shelveInDailyJournalBook`'s own "never throws" doctrine (AppSpec §9).
- **The Today door is reachable in every shelf state.**
  `showsTodayFallbackRow` is the negation of "some shelf row is the daily
  book", so the badge and the fallback row are mutually exclusive and
  exactly one door exists — pinned by `theBadgeRidesOnlyTheDailyBooksRow`
  (`doors.count == 1`) and `theDoorSurvivesAnEmptyShelf`. §40's open
  consequence really is answered.
- **The badge is a badge.** Measured frame
  `(344.33, 98.33, 65.67, 20.0)` on a 430 pt shelf — 65.7 pt wide against
  the old door's `.frame(maxWidth: .infinity)`. The red-on-old claim is
  sound: the pre-batch `todayButton` carried `maxWidth: .infinity` +
  20 pt horizontal padding, so it measured ~390 pt and fails the `< 200`
  assertion.
- **`quickNoteSitsBelowTheBooks` really does go red on old.** Verified by
  reading the removed code in the diff: the box was the first element
  under `pathLine`, so `field.minY` sat above every book row. Measured on
  the new tree: `field minY 872 · lowest book maxY 244`.
- **R26.3's non-pin is the right call.** `BlinkingCursorBlock` is
  `accessibilityHidden(true)`, so no harness assertion could see it in
  either direction, and a source grep would be a lint dressed as a test.
  Declining to pin it, and saying why, is the hallucination guard applied
  correctly.
- **`rowMeta(showingDailyMarker:)` changes presentation, not the brain.**
  `MobileShelfFaces.meta` is untouched; the flag only suppresses the
  trailing `"daily"` word on the row that wears the badge. Every other
  caller keeps the default.
- **The `bookRow` restructure is necessary, not cosmetic.** A `Button`
  nested inside another `Button`'s label is swallowed by the outer one, so
  the badge genuinely required the two-door HStack; the padding was moved
  *inside* the label so the row's accessibility frame is the row (the
  17 pt-vs-39 pt measurement recorded in the comment).
- **P3 is not engaged.** No TK2 surface, no `BlockRangeIndex`, no
  `MobileEditorViewModel` is created here; the shelf still hosts no live
  editor, and the new `.animation(_:value:)` is chrome-only.
- **`MobileQuickNoteBox`'s new `writingHeight` is source-compatible.** It
  is an optional `var`, so the memberwise initializer defaults it to nil
  and the two standalone hosts in `MobileQuickNoteTests` keep testing the
  five-line shape they were written for — a deliberate, documented
  divergence rather than a silent behaviour change under existing pins.
- **Hygiene.** Zero `Sources/` lines, zero `Sync/` lines, no
  `.pbxproj`/build-configuration change (the new files land through the
  file-system-synchronized group and demonstrably compile into the test
  target — all four new suites executed in my run), no schema, marker 7.
- **No entry in `KnownIssuesAndTechDebt.md` was owned by this batch and
  left unresolved**, and nothing above duplicates an existing row.
