# Batch 10 — NAVIGATION · COLD REVIEW

*Written 2026-08-31 by a cold reviewer with zero implementation context.
Target: `8c5e8aa..9b07f1f` — the two batch commits **`9a515b7`** and
**`2a579cf`** (the three orchestrator notes commits that interleave on
this branch are excluded, as the implementer's record states). Brief:
`notes/plans/mobile-batch-10-brief.md`. Record:
`notes/plans/mobile-batch-10-record.md`. Both read in full, plus the
entire batch diff, `MobileLivenessAuthority.swift`,
`MobileSurfaceDriver.swift`, `MobileQuickNote.swift`, the core ops and
queries the three deliverables ride (`newPostInReading`,
`assertReadingAcceptsPosts`, `createSection`, `setStarred`,
`Queries.starred`, `Queries.assembleReading`, `Queries.readingSections`,
`Queries.exportReading`), and her verbatim asks in
`notes/author-reports/2026-08-23-device-walk-and-product-asks.md`.*

**Environment:** own fresh simulator `b10-review` — **iPhone 17 Pro /
*[removed for publication]*
runtime; the 18.3 runtime is the INVALID 16-series one),
`ApplicationAccessibilityEnabled` armed and **read back `1`**, private
`-derivedDataPath` at `DerivedData/b10-review` (gitignored, inside the
worktree). Simulator deleted at the end. Pre-revert copies lived in
`.b10-review-prerevert/` inside the worktree and were removed after a
diff-verified restore; nothing was committed.

---

## SEVERITY COUNTS

| | count |
|---|---|
| **BLOCKER** | 0 |
| **MAJOR** | 2 |
| **MINOR** | 4 |
| **NIT** | 2 |

---

## THE SUITE

```
✘ Test run with 725 tests in 103 suites passed after 342.297 seconds with 2 known issues.
```

Exit `0`, **zero restarts**, `^✘ Test .* failed` greps **0**. This is
run 4. **Runs 1–3 all died to the documented under-load runner death**
(load average 35–47 on this box, three other agents live), each at a
DIFFERENT test — `puttingATakeBackClearsTheLensChipsFallbackMarker`,
`theEditTraceIsInertDisarmedAndQuietArmedAt100k`,
`everyFilterDoorLandsWhollyInsideTheSurfaceAtEveryWidth` — and each
with **zero `✘ Test … failed` lines**, i.e. process deaths, never test
failures. Both results reported per the brief. The five suites stranded
by run 3's death were re-run targeted and passed
(`✘ Test run with 26 tests in 2 suites passed after 55.431 seconds with
2 known issues.`, exit 0) before run 4 made that moot. Load had fallen
to 12 by run 4.

**The load-flaky perf pin did NOT red** on any of the four runs; run 3
printed `PERF[sim] keystroke p95 — control 0.843 ms · 100k top 7.369 ms
· 100k end 8.510 ms` against the 12.0 ms budget. No isolated re-run was
owed.

**725/103 against the 712/102 baseline = +13/+1**, exactly
`MobileNavigationTests` and nothing else. Verified by counting the file:
13 `@Test` functions, one `@Suite`.

---

## THE FENCE — re-derived independently

```
=== FILES TOUCHED (9a515b7 + 2a579cf) ===
App/Variorum/VariorumMobile/Features/Shell/MobileBookView.swift
App/Variorum/VariorumMobile/Features/Shell/MobileBookViewModel.swift
App/Variorum/VariorumMobile/Features/Shell/MobileShelfView.swift
App/Variorum/VariorumMobile/Features/Shell/MobileShellBand.swift        (new)
App/Variorum/VariorumMobile/Features/Shell/MobileShellView.swift
App/Variorum/VariorumMobile/Features/Shell/MobileStarredView.swift      (new)
App/Variorum/VariorumMobile/Features/Shell/MobileStars.swift
App/Variorum/VariorumMobileTests/MobileDeletionTests.swift
App/Variorum/VariorumMobileTests/MobileFilterTests.swift
App/Variorum/VariorumMobileTests/MobileNavigationTests.swift            (new)
App/Variorum/VariorumMobileTests/MobileShelfLayoutTests.swift
App/Variorum/VariorumMobileTests/MobileShelfTodayDoorTests.swift
App/Variorum/VariorumMobileTests/MobileStarsTests.swift
notes/plans/mobile-batch-10-record.md
notes/plans/mobile-round-2-status-2026-09-01.md

=== FENCE GREP (Sources/ | App/Variorum/Shared/ | App/Variorum/Variorum/ |
    EditorBrain/ | Package.resolved | *.pbxproj | *.xcconfig | Server/) ===
EMPTY

=== planVisibleTakeEdit in the batch diff, CODE ONLY (App/ + Sources/) ===
0
```

*(A whole-range `grep -c planVisibleTakeEdit` returns **2**, not 0 — both
hits are the record's own prose quoting its fence block. The code-only
count is 0. Recorded so a future reader re-running the raw command is
not surprised.)*

**No `Package.resolved` drift** (`git status` clean on it). **No
`.pbxproj` change despite three new files** — the project uses
`fileSystemSynchronizedGroups`, and the successful build is the proof.
Tree left byte-identical apart from this file.

---

## FINDINGS

### MAJOR 1 — The band tracks the finger and then TELEPORTS: there is no settle animation anywhere in it

**Where:** `App/Variorum/VariorumMobile/Features/Shell/MobileShellView.swift:286-296`
(`page(_:width:content:)`) and `:315-352` (`bandGesture(width:)`), with
`MobileShellBand.offset` at `MobileShellBand.swift:103-107`.

**Label: READ-ONLY traced** (a real pan cannot be synthesized in
process, so this is a reading of the state math and a grep, not a
screen measurement).

**Mechanism, concretely.** `grep -n "animation\|withAnimation"` over
`MobileShellView.swift` and `MobileShellBand.swift` returns **nothing**,
and there is no `.animation` anywhere in the chain above it
(`VariorumMobileApp.swift:51` mounts the shell with `.redacted` and
`.task` only). SwiftUI animates a geometry change only inside a
transaction that carries an animation, and a `Button` action and a
`DragGesture` callback carry none.

So, for a shelf → library swipe on a 393 pt screen:

- **mid-drag**, `bandDrag = -150` and the Library page draws at
  `offset(.library, current: .shelf, drag: -150, width: 393) = +243` —
  it tracks the finger continuously, one point per point;
- **on release**, `onEnded` calls `selectPage(.library)` (which assigns
  `tab`) and its `defer` sets `bandDrag = 0`, both in the same
  synchronous turn, so SwiftUI coalesces them into ONE update in which
  the Library page's offset is `0`.

**243 pt → 0 pt with no interpolation.** The same discontinuity happens
on a snap-back (`293 → 393`), which is the *more* common outcome
because `landingDistance` is 28 % of the screen. The band therefore
follows the finger smoothly and then hard-cuts on every single release
— which reads as a bug, not as a page turn, and this is the one feature
she described as *"killing me"*.

*(The tab-BAR road hard-cut before this batch too, and that was fine: a
tap has no continuous phase to be discontinuous with. A drag does. That
asymmetry is exactly why lifting the tab door's body into `selectPage`
was right for correctness and insufficient for feel.)*

**Fix shape.** Wrap the two writes in `onEnded` — and only those — in
`withAnimation(.interactiveSpring(response: 0.32, dampingFraction: 0.86))`,
leaving `onChanged`'s `bandDrag` write un-animated so the live drag
still tracks 1:1. (Animating `onChanged` would lag the finger; that is
the 13e drag-jitter lesson from the other direction.) The tab-tap road
inherits the same settle for free, which is a bonus rather than a
regression: a tap that glides one screen is the standard iOS grammar.

---

### MAJOR 2 — A refused book door speaks at the TOP of a list whose bottom she is looking at

**Where:** `App/Variorum/VariorumMobile/Features/Shell/MobileBookView.swift:218-220`
(the refusal renders inside `header`) versus `:115` (`bookDoors` is the
LAST child of the contents `LazyVStack`). The writers are
`MobileBookViewModel.swift:180` and `:199`.

**Label: READ-ONLY traced** (the composition is unambiguous; the
scroll-offset consequence is a reading, not a screenshot).

**Mechanism.** `MobileBookView`'s body is one `ScrollView` over a
`LazyVStack` whose children are, in order: `header` → the grouped rows →
the empty line → the truncation marker → **`bookDoors`**. `header` is
the ONLY renderer of `model.lastError`. Both new doors write
`lastError` and nothing else — no alert, no toast, no scroll-to.

So on a curated book with more than a screenful of notes:

1. she scrolls to the bottom, where the doors are;
2. taps `+ New Note` on a **finished** book (or one at `max_posts`);
3. `newPostInReading` refuses; `lastError` is set;
4. the sentence renders **hundreds of points above the viewport**, and
   from where she is standing **nothing happens at all.**

**This is not a cosmetic placement question — it is the whole
justification for the batch's one deliberate divergence from the Mac.**
The Mac's `BookView` HIDES both doors on `locked`. The record keeps them
and refuses instead, reasoning: *"a door that silently vanished when she
finished a book would teach nothing."* Correct — but the replacement
teaches nothing either, because the teaching is off-screen. As shipped,
a finished book gets the worst of both: a door that is present, that
cannot act, and that says so where she cannot read it. Under P-2 (*a
door that cannot act is not rendered*) the divergence is defensible ONLY
if the refusal is visible; it currently is not.

**Why the pins do not catch it.**
`aRefusedBookDoorMintsNothingAndSpeaksTheFamilysVoice`
(`MobileNavigationTests.swift:398-437`) never mounts a surface — it
builds a `MobileBookViewModel` and calls `await model.newNote()`
directly, then asserts `model.lastError`. The MINT-GATE half of that pin
is excellent and I reproduced its red (below); the **"speaks"** half is
green over a model property, and the record's *"Refusals speak the
family's voice"* is therefore a claim about a string, not about a
screen. That is precisely the green-over-nothing class
`MobileSurfaceDriver`'s own header exists to prevent.

**Fix shape.** Render the refusal **beside the doors** — a slot directly
under `bookDoors` reading `model.lastError` — which is the phone's
existing root-slot grammar (`MobileStarredView`'s `stars.error(on:)`
sits immediately above its tab bar for exactly this reason, and this
batch built that). Keep the header slot for the store-read error at
`MobileBookViewModel.swift:92`, or move both; either is fine, one slot
must be where the door is. Pin it on a MOUNTED finished book: activate
the real door through `accessibilityActivate()` and assert the sentence
is in `surface.visibleLabels`.

---

### MINOR 1 — The band's live drag is `@State`, so a CANCELLED gesture can strand the shell mid-page

**Where:** `MobileShellView.swift:85` (`@State private var bandDrag`),
`:90` (`@State private var bandEngaged`), reset only in `onEnded`'s
`defer` at `:339-342`.

**Label: SPECULATIVE** (the failure needs a real cancelled touch, which
this harness cannot produce — stated rather than blurred).

**Mechanism.** `onEnded` is the ONLY place `bandDrag` returns to `0` and
`bandEngaged` returns to `nil`. A `DragGesture` that is cancelled rather
than ended — a system edge gesture taking over, a phone call sheet, an
interruption mid-pan — does not reliably deliver `onEnded`. If that
happens after the latch engaged, `bandDrag` keeps its last value
forever: `page()` offsets every root by it, so the shell sits
permanently part-way between two pages, showing a sliver of each, with
`allowsHitTesting` still bound to `tab` (so the half-visible neighbour
is inert). Only a completed later drag clears it; a tab TAP does not,
because `selectPage` never touches `bandDrag`.

**Fix shape, and it is the canonical one:** make the live drag
`@GestureState` (`@GestureState private var bandDrag: CGFloat = 0` with
`.updating { … }`), which SwiftUI resets to its initial value whenever
the gesture ends *however* it ends — cancellation included. The latch
can ride the same `@GestureState` as a tuple, or keep `@State` and gain
a `selectPage`-side `bandDrag = 0`. The pure brain needs no change.

---

### MINOR 2 — The batch's own NAMED GAP (no assign-to-chapter door) has no home outside a file that closes

**Where:** `notes/plans/mobile-batch-10-record.md`, §"🚩 A NAMED GAP,
for the reviewer and the parity ledger".

**Label: READ-ONLY traced** (grep-verified across the canon).

**Mechanism.** The record names a real and consequential gap: `+ New
Note` lands a note **unsectioned**, and a chapter minted on the phone
can be filled only from the Mac — so the phone can now CREATE a
structure it cannot USE. The record says the gap is *"for the reviewer
and the parity ledger"* and marks it PROVISIONAL. **The ledger row was
never written.** `grep -rn "assignPostToSection\|assign-to-chapter\|
unsectioned"` over `notes/MobileSoul.md`, `notes/QUESTIONS.md`,
`notes/KnownIssuesAndTechDebt.md`, `notes/plans/mobile-round-2.md` and
`notes/plans/mobile-round-2-status-2026-09-01.md` returns **nothing**;
the status file's batch-10 row names the three deliverables and no
residue. So the gap lives in one batch record, which is the class the
KnownIssues owner rule forbids ("no new entry without naming the owner")
and the exact failure this round already caught once — the Fable sweep's
finding 3, whose whole point was that *a discharge recorded only where a
planning session does not look is not recorded.*

**Fix shape.** One row: either a `MobileSoul.md` parity-ledger line
(PL-17, or an addendum to PL-11 which already owns book/chapter faces),
or a question for her bundle if the door's SHAPE is genuinely hers (the
record itself lists three candidate shapes — a per-chapter trailing
`+ new note`, the membership sheet, a drag). `newPostInReading` already
takes `section:`, so the mechanism half is one argument; only the
placement is a design call, and that is what a ledger row is for.

---

### MINOR 3 — `selectPage`'s A5-8 claim is INHERITED, not verified — and a mounted-shell probe does not reproduce "clears"

**Where:** `MobileShellView.swift:354-374` (`selectPage`), and the
record's D1 bullet *"A5-8 (leaving files the quick-note box) … A swipe
that skipped either would have been a quieter second version of the tab
door."*

**Label: MEASURED** (throwaway probe, run 3× on the mounted shell,
since deleted).

**What is solid, and I verified it first.** `selectPage`'s body is
**byte-identical** to the pre-batch `tabDoor` body — the diff at
`MobileShellView.swift` shows the exact lines moving with no semantic
change (guard, `tab = target`, `beginHandoff()` synchronously, then the
`Task { fileOnLeaving(); tabDidBecomeVisible(target, handoff:) }`). So
the ONE-ROAD claim is true by construction, the synchronous handoff
ordering (S3 BLOCKER / MAJOR 2) is preserved exactly, and a swipe cannot
drift from a tap. That half is a clean bill.

**What the probe measured.** I mounted a real `MobileShellView`, set
`router.quickNote.text`, let the mint clock fire and settle (120 turns,
`lastError == nil`), then activated the real `Library` tab door. Result,
reproduced 3/3:

- the page really changed — the `Library` door carried `.isSelected`,
  so `selectPage` ran;
- a note really was minted — `container` count increased;
- **but `router.quickNote.handOffCount == 0` and the box still held
  `"a thought left in the box"`.**

Tracing it: `file()` reached the `guard autosave?.isDirty != true`
branch at `MobileQuickNote.swift:963` and took the deliberate
keep-her-text road (`setFocused(false); return nil`) — not the refusal
road, which `lastError == nil` rules out.

**Scope, stated plainly: this is NOT attributable to batch 10.** The
code path is byte-identical to the pre-batch one, so whatever this is,
a page change files exactly as a tab tap always did. And the probe is
not equivalent to the covered path: every existing leaving pin in
`MobileQuickNoteTests` uses `quietBox(session)` — the mint clock
controlled, `postID == nil` at the leaving — whereas my probe let the
live clock mint first, which is the state no pin covers.

**Why it is a finding at all.** The record ASSERTS A5-8 as a property of
the new road, and pins nothing on the mounted shell; what it actually
inherits is whatever the old road does in states no pin reaches, and in
one such state the box does not clear. **Fix shape:** either pin the
claim where it is claimed (mount the shell, drive the tab door, assert
the box), or soften the record's wording to what is true — *"the road is
byte-identical, so A5-8 behaves exactly as it did"* — and let a
quick-note owner settle the post-clock-mint leaving with the same probe
run against `8c5e8aa` as a control. Nothing typed is at risk either way:
the note existed and `savepointOnLeaving` ran before the keep-arm fired.

---

### MINOR 4 — In a TRUNCATED book, chapters whose notes fell past the window now render as EMPTY

**Where:** `MobileBookViewModel.swift:70-88` (`start()` — `entries =
Array(value.entries.prefix(window))`, `window` default **300** at
`:41`) with `:110-135` (`grouped(_:chapters:)`).

**Label: READ-ONLY traced.**

**Mechanism.** The chapter branch builds one group per live chapter and
fills it by `entries.filter { $0.sectionID == chapter.id }` — over the
**windowed** entries. `chapters` itself is unwindowed. So in a curated
book with more than 300 notes, every chapter whose notes all sit past
row 300 renders a header with nothing under it — visually identical to
the genuinely-empty chapter this batch deliberately taught the list to
show. The batch made empty-chapter headers MEAN "this chapter is empty";
truncation now makes some of them lie.

Pre-batch this could not happen: run-clustering derived headings from
present entries only, so a cut-off chapter simply did not appear.

**Mitigation, and it is why this is MINOR not MAJOR:** the truncation
marker does render (`"Showing the first 300 notes — the rest of this
book isn't loaded yet."`), so the page is not silent — it just sits
*below* the misleading headers rather than beside them.

**Fix shape.** Either render chapter groups only up to the last chapter
that has a windowed entry, plus genuinely-empty chapters that sit before
it; or, simpler and more honest, suppress the empty-chapter rendering
entirely while `truncated == true` and let the marker carry the whole
story. A one-line pin over a windowed model (`window: 1` in the
initializer makes this cheap to drive).

---

### NIT 1 — `starredRows:` is now a parameter with exactly one constant caller — the record's own "dead guard" argument, applied inconsistently

**Where:** `MobileShelfView.swift:90-100` passes `starredRows: 0`
unconditionally; `MobileShelfLayout.split`'s parameter and its
2,408-state guarantee pin are untouched.

The record justifies NOT adding a render window to the starred page with
the 6c cold review's rule — *"a dead guard reads as a rule and is not
one"* — and then leaves a brain parameter whose only live value is `0`,
justified the other way (removing it would change the pin's
`checked == 43 * 7 * 4 * 2` assertion). Both calls are individually
defensible and the honest-smaller-change reasoning is fine; the
inconsistency is worth one line so the next reader is not left deriving
which principle governs. **Not a defect** — the guarantee pin genuinely
still spans every value, which I confirmed by reading it. Fix shape:
nothing now; when the parameter's last caller value has been `0` for a
few batches, retire it and re-derive the pin's product.

### NIT 2 — `MobileShellBand.offset` has no `width > 0` guard, though `clampedDrag` does

**Where:** `MobileShellBand.swift:89-97` guards `width > 0`;
`:103-107` does not.

On a layout pass where `GeometryReader` proposes `0` width (the first
pass in some hosting contexts), every page's offset collapses to `drag`
(i.e. `0`) and all three roots draw stacked on top of one another for
that frame. `allowsHitTesting(tab == owner)` still holds, so nothing is
mis-tappable, and the batch's mounted pin passes — so this is a
one-frame cosmetic risk at most, and possibly unreachable in a
`UIHostingController` with a sized window. Recorded only because the
sibling function guards the same input and this one does not, which
reads as an oversight rather than a decision. Fix shape: `guard width >
0 else { return 0 }`, or a `.opacity(width > 0 ? 1 : 0)` on the band.

---

## CLEAN BILL — the eight areas, each verified

### CB-1 · D1's band mechanism

**BOTH — now three — stacks stay alive: DRIVEN, not argued.** The
record's structural argument is sound (the `ZStack` constructs all three
`NavigationStack`s unconditionally; `.offset` is a render transform and
removes nothing; no `TabView(.page)`), and I confirmed it by reading.
But the brief called this the batch's in-batch fork, so I drove it: a
throwaway probe mounted the real shell, pushed a note onto the SHELF
stack through the shelf's own Today door, then activated `Library` →
`Starred` → `Shelf`, asserting `MobileNoteActionsSheet.doorLabel` at
every step. **`aPushedScreenSurvivesEveryPageChange` PASSED** — the
pushed screen survives a full round trip through all three pages. The
A2 liveness world's premise holds.

**The tab bar is authoritative and in sync, by ONE road.** Verified by
trace: `selectPage` is byte-identical to the pre-batch `tabDoor` body
(the diff shows the lines moving unchanged), so the synchronous
`beginHandoff()`-in-the-same-turn ordering and the A5-8 call ride BOTH
roads. Verified by pin: `theTabBarCarriesThreeDoorsAndEachOneMovesTheBand`
drives the real doors on the real mounted shell and watches `.isSelected`
move; I reproduced its red under R3 (see below), and my own probe
independently observed the `Library` door taking `.isSelected` after
activation. *(The residual honesty gap is MINOR 3 — the A5-8 half of
that road is claimed, not pinned.)*

**Paging is masked whenever anything is pushed — VERIFIED AT THE ROOT
CHECK.** `pagingAllowed` (`MobileShellView.swift:298-305`) switches on
`tab` and asks that stack's own `NavigationPath.isEmpty`; the gesture's
`including:` drops to `.subviews` when false, which disables the band's
own recognizer and leaves the subtree's gestures untouched. Since the
tab bar renders on ROOTS only, a page change can only be requested from
a root — so an editor's horizontal gestures and the system back-swipe
can never share a screen with the band. **Untestable in process** (a pan
cannot be synthesized), so this is a trace, and I say so.

**ONE named coordinate space — the 13e rider is honoured.**
`MobileShellBand.coordinateSpace` is declared once and read by both
`.coordinateSpace(name:)` (`:304`) and
`DragGesture(coordinateSpace: .named(…))` (`:319-321`). `grep -rn
"DragGesture"` over `VariorumMobile/` returns exactly two hits, both in
this batch's own files; no `.local`/`.global` mixing exists.

**No horizontal scroller can fight the band.** `grep -rn
"ScrollView(.horizontal"` over `VariorumMobile/` returns ONE hit —
`MobileTrashView.swift:178` — which is a PUSHED room, where
`pagingAllowed` is already false. `grep -rn "swipeActions"` returns
nothing. So the latch's ratio rule never has to arbitrate against
another horizontal recognizer at a root. *(One residual worth stating,
not a finding: a horizontal text-selection drag inside the shelf's
quick-note box is decisively horizontal and would satisfy `engages`;
whether SwiftUI's `simultaneousGesture` actually recognizes alongside
`UITextView`'s selection gestures is a device question this harness
cannot answer, and the record's "the gesture recognition rides the
device queue" already covers it honestly.)*

**P1/P3 — the offscreen roots cost nothing new.** The two pre-existing
roots were `opacity(0)`, which lays out exactly as an offset view does,
so nothing about their cost changed. The THIRD root is genuinely new,
and it observes NOTHING of its own: `MobileStarredView` has no `.task`
and reads only the shell's single `starsModel`, whose observation was
already started at `MobileShellView`'s own `.task` before this batch.
Its listing is a `ScrollView`/`LazyVStack` over ≤5 rows. Net cost is
roughly a wash, since those same ≤5 rows previously rendered inside the
shelf's books region.

### CB-2 · D2's starred page

**A face over the existing star, no new core read.** Confirmed:
`MobileStarredView` reads `stars.items`, i.e. `Queries.starred` through
the same `MobileStarsModel` the retired shelf section used. No new query
kind, nothing book-shaped — her *"don't build it yourself"* fence is
kept (`grep` finds no reading/smart-book construction anywhere in the
new file).

**The rows MOVED, not copied.** The shelf's `starredSection` /
`starredRow` are deleted, not duplicated (the diff removes 74 lines and
the new file's `row(_:)` is their successor), and
`MobileStarsModel.sectionHeader` is gone — `grep -rn "sectionHeader"`
across the repo shows the remaining hits are the Mac's own
`StarCopy.sectionHeader` and unrelated symbols. `MobileShelfView`'s
`onOpenNote` went with its only caller, and the four construction sites
were updated mechanically.

**The old placement is RETIRED and the cap sentence follows it — no
other sentence still names the retired road.** Grep-verified: the only
mobile string mentioning the shelf-top starred list was
`MobileStarsModel.capRefusal`, and it now composes `pageName`. The Mac's
`OpsRefusalCopy.swift:396` still names *"the sidebar"* — correct, that
is the Mac's own surface. `MobileStarsTests`' own pin was re-pointed and
**strengthened** (see CB-4).

**"No render window because the data caps at 5" — the CAP IS REAL, and
I checked it at the write door rather than taking the claim.** It is not
enforced at the query: `Queries.starred`
(`AppearanceQueries.swift:111-148`) has no `LIMIT`, and
`starredTargets` decodes the whole stored JSON array. It is enforced by
the fact that there is exactly ONE writer —
`Operations.setStarred` (`Operations+Appearance.swift:171-199`) — and
that writer (a) refuses past `starLimit` **inside its own write
transaction**, and (b) rewrites the stored value to exactly
`Queries.starred(db).map(\.target)`, i.e. the pruned LIVE list, so the
stored array can never exceed 5 live entries and dead ghosts cannot
inflate it. Under sync, `setting.value` is plain metadata CAS
(server-version-wins on the whole row), so a converged value is some
device's own capped list — never a union. The bound is therefore a real
system invariant, not an assumption, and it IS pinned:
`aStarRefusalFromTheStarredPageSpeaksOnlyThere` asserts
`stars.items.count == Operations.starLimit` across a refused add. **The
record's call to omit a dead window is correct.**

**`DoorHome.starred` is the right shape** — the D2 defect it closes
(a refusal waiting on a root that did not fire it) is real, and the pin
asserts all three roots.

### CB-3 · D3's two doors

**The gate is INSIDE the mint's transaction — read at the core op, not
assumed.** `Operations+Reading.swift:237-268`: `database.write` opens,
then `liveReading` → curated check → locked check → capacity count →
section check, and only then `insertPost` + the `ReadingPost` insert. A
refusal throws before any row exists, and it is not a pre-check that
could race. The record's note that `assertReadingAcceptsPosts` would be
a second read of the same facts is correct — that op
(`:279-…`) exists for doors that mint separately, which this one does
not. **R8's strand assertion reproduced** (below): the alternative
mint-then-add shape leaves `containers 1` vs `0` on a refused add.

**`+ New Chapter` rides `createSection`, curated-only and
locked-refusing by the op's own guards**, with the Mac's exact words —
`"New Chapter"` / `"Name"` / `"Create"` / `"Cancel"` — pinned literally
in `theBookDoorsSpeakThePhonesOwnWords`, and the note door taken from
`MobileNewNoteDoor.doorTitle` so a third spelling cannot appear. The
blank-name face gate is belt-and-braces (the model guards too).

**Absence on smart books, over a POPULATED surface.**
`aSmartBooksContentsCarriesNeitherDoor` mounts a real smart book that
really renders its collected note; under R7 the revert output shows
`labels → ["everything essays", "Collected", "+ New Note", "+ New
Chapter"]`, which proves in one line both that the tree is alive and
that the doors would be there if the rule let them. P-2 satisfied.

**Empty chapters render, and the chapter listing's P1 discipline is the
Mac's own.** `Queries.readingSections`
(`SectionQueries.swift:9-14`) is a per-book ordered fetch with no
window — exactly what the Mac's `BookStructureModel.swift:93` already
holds, so this is not a new class; it is book-scoped, not corpus-scoped,
and it rides the SAME observation closure as the entries, so the list
and its chapters are read in one transaction and can never disagree.
*(The truncation interaction is MINOR 4.)*

**The dangling-`section_id` hazard I went looking for does NOT exist.**
`grouped`'s chapter branch drops any entry whose `sectionID` matches no
live chapter and whose `sectionID` is not `nil` — which would make a
note with a tombstoned chapter pointer VANISH from the contents list,
against AppSpec §7's ruled dangle rule. It cannot happen, because the
assembly closes it upstream: `ReadingAssembly.swift:271-299`'s
`.curated where hasChapters` branch `LEFT JOIN`s `reading_section` on
`deleted_at IS NULL` and selects `s.id AS section_id`, so a dangling
pointer arrives as `NULL` and files as unfiled. Resolution **by id, not
by name** is also correct and matches `Queries.exportReading`'s own
shape (`Export.swift:206-216`) — same-named chapters stay two groups,
which the pin asserts.

**Structural undo: nothing re-registered, verified at the ops.**
`newPostInReading` registers no entry (the `createPost` class);
`Operations+Sections.swift` registers nothing (the tags/locks class,
where `restoreSection` IS the inverse). The doors add none.

**The finished-book divergence is a real, recorded choice** — and its
justification is what MAJOR 2 undermines, not the choice itself.

### CB-4 · The two moved pre-existing pins — NEITHER weakens an assertion

- **`MobileStarsTests.theCapRefusalSpeaksPhoneWords`** replaced
  `refusal.contains("top of the shelf")` with
  `refusal.contains(MobileStarsModel.pageName)` **and ADDED**
  `!refusal.contains("shelf")`. That is strictly **stronger**: a literal
  became a symbol, and a new negative clause was added. The two
  never-the-Mac clauses (`sidebar`, `Mac`) are untouched. The rule the
  pin protects — the refusal names a road that exists ON THE PHONE — is
  unchanged; only which road it is changed, and it changed because the
  batch retired the old one at her word.
- **`MobileFilterTests.theShellGivesTheLibraryTheShelfsOwnBooks`**
  changed `activate("library")` → `activate("Library")`. Same act, same
  door, same subsequent assertions. It follows the door's new explicit
  `accessibilityLabel(label)` (`MobileShellView.swift:519`), which is
  itself an improvement — an assistive reader now hears the same proper
  noun in both voices instead of one voice's casing. Not weakened.
- The four `onOpenNote:` removals in `MobileDeletionTests`,
  `MobileShelfLayoutTests` and `MobileShelfTodayDoorTests` are
  construction-site updates only; no assertion in any of them changed.

### CB-5 · The harness finding — CONFIRMED, WIDENED, and blast radius ZERO today

**Confirmed at the code.** `HostedSurface.walk`
(`MobileSurfaceDriver.swift`) recurses `view.subviews` unconditionally
and never consults `accessibilityElementsHidden`. **Confirmed
empirically too:** under my R3 revert the driver reported
`selection(surface, "Shelf") → (copies: 3, …)` — three copies of one tab
door, i.e. all three roots present in one walk.

**Widened, and this is the part that changes its reading.** The walk
also ignores `isHidden`, `alpha`, and frames outside the ancestor's
bounds. So the PRE-BATCH shell — whose offscreen root sat at
`opacity(0)` and `accessibilityHidden(true)` — was **already fully
walked**. This is therefore a **pre-existing property of the driver,
not something batch 10 created**; the batch changed the count from two
roots to three. That matters because it means no existing pin's verdict
could have been FLIPPED by the offset change.

**Blast radius, enumerated.** Exactly three tests mount
`MobileShellView`:

| pin | assertions | verdict |
|---|---|---|
| `MobileFilterTests.swift:677` `theShellGivesTheLibraryTheShelfsOwnBooks` | presence only (`activate` ×2, `hasPrefix("Aster")`) | **SOUND** |
| `MobileVersionsTests.swift:597` `theVersionsRowOpensTheRoomThroughTheWholeShell` | presence only (`activate` ×3, `contains(noVersions)`) | **SOUND** |
| `MobileNavigationTests.swift:189` (this batch) | selection traits + presence | **SOUND** |

**No shell-mounted pin anywhere asserts an ABSENCE** — I swept every
`!…contains` in the whole test target and each one lives in a test that
mounts an INDIVIDUAL root view, where no other page exists. So the
false-red direction is empty and the false-green direction is empty.

**Two presence-shaped risks checked rather than waved off:**

1. Could `theShellGivesTheLibraryTheShelfsOwnBooks`'s
   `hasPrefix("Aster")` be satisfied by the SHELF's own book row rather
   than the Library's? **No.** The shelf's `bookRow`
   (`MobileShelfView.swift`) carries no explicit `accessibilityLabel`
   and renders through `tokens.chromeLabel`, which the Terminal voice
   (fixed by `withEditorWorld`) lowercases to `"aster …"`; the
   Library's row carries `.accessibilityLabel(MobileShelfFaces.spokenRow(
   name:meta:))` with the raw name. The capital `A` is load-bearing and
   discriminates correctly. (This batch's own pin at
   `MobileNavigationTests.swift:293` uses `.lowercased()` for the shelf
   for exactly this reason — the two are consistent.)
2. Do the third root's NEW labels collide with any existing assertion?
   The labels it injects into every shell walk are `"Starred"` and
   `MobileStarsModel.emptyLine`. Neither appears in any assertion
   outside `MobileNavigationTests.swift`. No collision.

**Verdict: the finding is real, correctly recorded, correctly left
unfixed** (the driver is shared infrastructure; changing its walk could
flip other batches' pins in either direction). Its live consequence is
FORWARD only — any future shell-mounted absence pin would measure the
walker. **One correction owed to the record:** it reads as though the
batch discovered a property the batch's own change exposed; it is older
than that, and the honest statement is *"the driver has never honoured
visibility of any kind, so a shell-mounted walk has always seen every
root."* Worth carrying into whichever row eventually owns the driver.

### CB-6 · The crash-recovery claim — VERIFIED, independently

The record says R9 (the flick's direction-agreement clause) was still
applied when the process restarted and was restored **by hand** from the
known original, diff-verified against the pushed tree.

**Three independent confirmations:**

1. The clause is present in the committed file —
   `MobileShellBand.swift:132-133`: `abs(predictedEnd) >= width * 0.5 &&
   (predictedEnd < 0) == (drag < 0) && drag != 0`.
2. `git status` is clean and `git diff` empty against `9b07f1f`, so the
   working tree and the commit agree byte for byte.
3. **The decisive one.** The implementer's pre-revert snapshots survive
   on disk (`…/scratchpad/b10-prerevert/`, all six files stamped
   `Aug 31 20:08:52` — 45 s after the deliverables commit `9a515b7`
   at 20:08:07 and **22 minutes before** the red-on-old commit `f7c4937`
   at 20:30:02, so they genuinely predate every revert). All six are
   **byte-identical** to the committed tree (`diff -q`, zero
   differences), and the `MobileShellBand.swift` snapshot **contains the
   clause** — which it could not if it had been taken from an
   R9-applied tree. **No half-restored residue anywhere.**

I re-verified byte-exactness again after my own revert wave: SHA-1s of
all six production files match their pre-revert snapshots exactly, and
`git diff` is empty.

### CB-7 · Pin quality — a meaningful sample reproduced, no green-over-nothing found

I applied **eight production reverts in one wave** (R1, R2, R3, R4, R5,
R6, R7, R8) and ran `MobileNavigationTests`. **Every revert is
PRODUCTION code, never a fixture edit** — and I re-derived which is
which myself; the record's own attributions are correct.

Result: `✘ Test run with 13 tests in 1 suite failed after 8.937 seconds
with 19 issues.` Each red landed on exactly the test the record names,
with matching text:

| revert (production file) | test that went red | my observed red |
|---|---|---|
| **R1** `MobileShellBand.engages` — drop the ratio clause | `aVerticalScrollNeverEngagesTheBand` | `Expectation failed: !(MobileShellBand.engages(CGSize(width: 20, height: 200) → (20.0, 200.0)) → true)` (+2) |
| **R2** `MobileShellBand.clampedDrag` — return `raw` | `theBandsEndsAreWallsNotRubber` | `(MobileShellBand.clampedDrag(120, current: .starred, width: width) → 120.0) == (0 → 0.0)` (+2) |
| **R3** `MobileShellView.tabBar` — pre-batch two doors | `theTabBarCarriesThreeDoorsAndEachOneMovesTheBand` | `(surface.element(labeled: door) → nil) != nil` · `.activate("Starred")` · `(copies: 0, …).allSelected` (+1) |
| **R4** `MobileStarsModel.capRefusal` — old sentence | `theCapRefusalNamesTheListThatActuallyExists` | `!("…un-star one in the starred list at the top of the shelf…").contains("shelf") → true` (+1) |
| **R5** `MobileShelfView` — starred rows back above the books | `theStarredListLivesOnItsOwnPageAndNotAboveTheShelf` | `!(labels.contains { $0.lowercased().contains("harbor") })` |
| **R6** `MobileBookViewModel.grouped` — run-clustering only | `aNewChapterShowsInTheContentsEvenBeforeItHoldsAnything` | `(groups.map(\.section) → [Optional("Openings")]) == [… "Openings", "Openings", "Endings"]` (+1) |
| **R7** `MobileBookViewModel.showsBookDoors` → `true` | `aSmartBooksContentsCarriesNeitherDoor` | `!((labels → ["everything essays", "Collected", "+ New Note", "+ New Chapter"]).contains("+ New Note"))` (+1) |
| **R8** `MobileBookViewModel.newNote` — mint FIRST, then add | `aRefusedBookDoorMintsNothingAndSpeaksTheFamilysVoice` | `(after.containers → 1) == (before.containers → 0)` |

**R8 is the brief's own required assert and it fires exactly as
claimed** — the mint-then-add shape (`createPost` then
`addPostToReading`) strands one container behind a refused add on a
finished book, and `newPostInReading`'s in-transaction gate is precisely
what stops it. **And the record's subtle claim checks out too:**
`theBooksNewNoteDoorMintsInsideItAndOpensForWriting` stayed **GREEN**
under R8 (it passed in my run), which is right — an unlocked curated
book mints either way — so R8's red isolates the gate and nothing else.

**Green-over-nothing hunt.** Three pins pass on both sides, and all
three are **declared as such** in the record rather than dressed as
guards, which is the honest posture:
`theBandPutsTheShelfAtHomeBetweenStarredAndLibrary` (the arrangement is
definitional), `theBookDoorsSpeakThePhonesOwnWords` (word pins),
`aStarRefusalFromTheStarredPageSpeaksOnlyThere` and
`theBooksNewNoteDoorMintsInsideItAndOpensForWriting` (new-capability
pins whose pre-batch red is the feature's absence). I found **one**
undeclared soft spot, and it is MAJOR 2: the "speaks" half of
`aRefusedBookDoorMintsNothingAndSpeaksTheFamilysVoice` is green over a
model property while the sentence's on-screen placement is wrong.

**Restore:** all six production files copied back from
`.b10-review-prerevert/` and verified — SHA-1 match on all six, `git
diff --stat` empty. Backup directory and the throwaway probe file
removed. Nothing committed.

### CB-8 · Fence — re-derived above, clean

Fenced-path grep EMPTY; `planVisibleTakeEdit` **0** in code; no
`Package.resolved` drift; no schema, build-config, `Sources/`,
`Shared/`, Mac, or `EditorBrain/` line anywhere in the batch range. The
Mac's `BookView.swift` / `BookStructureModel.swift` were plainly read
for wording and op parity and not written — the diff confirms it.

---

## THE RECORD ITSELF

Accurate throughout on the things I could check independently: the
revert attributions, the quoted reds, the counts, the fence, the op
semantics, the byte-exact restores, and the harness finding. Three
corrections are owed and are named in the findings above — the harness
finding is older than the batch (CB-5), the A5-8 claim is inherited
rather than verified (MINOR 3), and the named chapter gap was never
written anywhere durable (MINOR 2).

---

# ADJUDICATION + FIX-WAVE BRIEF (the Fable orchestrator, 2026-09-01)

**ALL EIGHT ACCEPTED, ZERO DISPUTES.** One fix wave; the orchestrator's
verification closes the unit (face fixes, not seam surgery). This is the
seat's LAST unit — its close is followed by the Release build + install
to her phone, so the wave keeps to the eight items exactly. Shapes:

1. **MAJOR 1 — the band animates its release.** `withAnimation(.interactiveSpring(…))`
   (or the closest honest spring) around `onEnded`'s two writes ONLY —
   the mid-drag tracking stays un-animated (finger-locked). Pin what the
   harness can honestly observe: if SwiftUI's animation presence cannot
   be asserted in-process, DECLARE it (the feel rides the DEVICE QUEUE —
   the swipe is already there) and pin the state-level contract instead
   (release from past-threshold lands the target page; release short of
   it lands home) — red-on-old where a revert changes the landing, and
   an honest "animation not pinnable" line in the record where it does
   not.
2. **MAJOR 2 — a refused door speaks WHERE THE TAP WAS.** Render the
   refusal sentence adjacent to `bookDoors` (the doors' own row/footer),
   not only in the header — so a finished/at-capacity book longer than a
   screen shows its sentence beside the door that refused. Pin on a
   POPULATED long book: activate the real `+ New Note` door, assert the
   sentence is in the rendered tree near the doors (red-on-old against
   the header-only shape). This restores the divergence's justification
   (doors stay SO THEY CAN EXPLAIN — now they can).
3. **MINOR 1 — `@GestureState`** for `bandDrag`/`bandEngaged` so a
   cancelled gesture resets by construction.
4. **MINOR 2 — the assign-to-chapter gap gets a HOME:** her bundle (it is
   a where-does-the-door-live design call) — one line in
   `mobile-round-2-status-2026-09-01.md` §C's "YOUR RULINGS" row and in
   the batch record's PROVISIONALs, plus the mechanism note
   (`newPostInReading(section:)` is one argument away).
5. **MINOR 3 — land the reviewer's mounted-shell A5-8 probe as NEW
   COVERAGE** (a swipe-leaving files the quick-note box; `handOffCount`
   and the box's text as measured), labelled honestly as inherited
   behaviour now pinned, not batch 10's fix.
6. **MINOR 4 — chapters beyond the window:** distinguish a chapter with
   ZERO members anywhere (must render — that is D3's New Chapter) from a
   chapter whose members lie past the 300 cut (render it with the
   standing truncation sentence, or fold it under the listing's marker —
   pick the minimal honest shape, say which, pin it).
7. **NIT 1 — delete the dead `starredRows: 0` parameter.** **NIT 2 — the
   `width > 0` guard on `offset`.**

Environment and rules exactly as the batch brief PLUS the Session
Resiliency Protocol (commit per piece + push each; record status in the
same commit; foreground waits; pre-revert state COMMITTED before any
revert — `git checkout --` is then the safe restore — or copies INSIDE
the worktree under a gitignored unique dir; the scratchpad is not
durable). Full suite at the end — baseline 725/103 + 2 known issues —
final line quoted; fence grep + planVisibleTakeEdit zero. Reds quoted,
production or fixture named. Append a FIX WAVE RESULTS section to THIS
file (incrementally) before the final message.

---

# FIX WAVE RESULTS (the fix-wave session, 2026-09-01)

*Written incrementally, per item, as the work lands. The brief above is
the whole scope: seven numbered items, nothing beyond them.*

**Environment:** own fresh simulator `b10-fix` — **iPhone 17 Pro /
*[removed for publication]*
runtime; the 18.3 runtime is the INVALID 16-series one),
`ApplicationAccessibilityEnabled` armed and **read back `1`**, private
`-derivedDataPath` in the session scratchpad. Simulator deleted at the
end.

---

## Item 2 · MAJOR 2 — a refused door speaks WHERE THE TAP WAS · **FIXED**

**What changed, and it is one slot, not a rewrite.** The book model held
ONE error string for two different speakers — the screen's own store-read
failure and a door's refusal — and the view rendered it in the header
only. The two are now held apart:

- `MobileBookViewModel.lastError` keeps its meaning: the **store read**
  failed (`start()`'s catch), which belongs to the header where the
  book's identity is.
- `MobileBookViewModel.doorRefusal` is new and is written by the two
  doors only (`newNote()`, `newChapter(named:)`, cleared on success).
- `MobileBookView` renders `doorRefusal` **immediately beneath
  `bookDoors`**, which is the phone's own root-slot grammar
  (`MobileStarredView` puts `stars.error(on:)` beside the door that
  fired it for exactly this reason). The header slot is untouched and
  still carries the store-read error.

**Why this shape rather than moving the one slot down:** a store-read
error has no door to sit beside — on a smart book `bookDoors` renders
nothing at all — so moving the single slot would have left that class
homeless at the bottom of a list. One slot per speaker.

**The Read flow is deliberately untouched:** `MobileReadView` has no
doors, so `lastError` in its header remains exactly right.

**New pin (PRODUCTION-driven, mounted):**
`aRefusedBookDoorSpeaksBesideTheDoorSheTapped` builds a CURATED book with
**twelve** notes and then finishes it, mounts the real `MobileBookView`,
activates the real `+ New Note` door through `accessibilityActivate()`,
and measures the refusal's `accessibilityFrame` **against the door's**:
beneath it, and within 80 pt of it. Proof-of-life first (`Note 11` is on
screen), so an empty tree cannot read as a pass.

**Pins updated (this batch's own, not weakened):**
`aRefusedBookDoorMintsNothingAndSpeaksTheFamilysVoice` now reads
`model.doorRefusal` for both doors **and gained a clause** —
`#expect(model.lastError == nil, "the screen read fine; only the door
refused")` — which is a new assertion the old shape could not make;
`aNewChapterShowsInTheContentsEvenBeforeItHoldsAnything`'s success
assertion follows the same property.

**Files:** `App/Variorum/VariorumMobile/Features/Shell/MobileBookViewModel.swift`,
`App/Variorum/VariorumMobile/Features/Shell/MobileBookView.swift`,
`App/Variorum/VariorumMobileTests/MobileNavigationTests.swift`.

**Suite (targeted):** `✔ Test run with 14 tests in 1 suite passed after
8.562 seconds.` — exit 0.

**RED-ON-OLD — production revert `R-M2`, applied after the fix was
committed** (the shipped shape restored exactly: the door slot deleted and
the header rendering `model.doorRefusal ?? model.lastError`):

```
✘ Test aRefusedBookDoorSpeaksBesideTheDoorSheTapped() recorded an issue at MobileNavigationTests.swift:494:17: Expectation failed: (voiceFrame.minY → 89.0) >= (doorFrame.minY → 566.6666666666666)
✘ Test aRefusedBookDoorSpeaksBesideTheDoorSheTapped() failed after 1.160 seconds with 1 issue.
✘ Test run with 14 tests in 1 suite failed after 8.449 seconds with 1 issue.
```

**477 pt above the finger** — the finding's own mechanism, measured on a
mounted twelve-note book rather than argued. Restored with
`git checkout --` (the file was committed first); `git status` clean, `git
diff` empty.

---

## Item 1 · MAJOR 1 — the band's release SETTLES · **FIXED** · animation itself DECLARED unpinnable

**What changed.** `MobileShellView.settle` — one `Animation`
(`.interactiveSpring(response: 0.32, dampingFraction: 0.86)`, the
reviewer's own shape) — is applied in exactly two places, which together
are every road the band's geometry can change:

- **`selectPage`** wraps `tab = target` in `withAnimation(Self.settle)`.
  It is the SINGLE road to a page change (the batch's own doctrine), so a
  tap and a swipe now arrive identically — the reviewer's noted bonus,
  taken deliberately rather than inherited.
- **the drag's reset transaction** (see MINOR 1 below): `@GestureState`'s
  `resetTransaction: Transaction(animation: MobileShellView.settle)`, so
  the SNAP-BACK — the commoner outcome, since `landingDistance` is 28 % of
  the screen — glides back on the same curve rather than cutting.

The live drag is deliberately left un-animated: `updating` writes the
clamped translation raw, so the band still tracks the finger 1:1. An
animated live phase is the 13e drag-jitter lesson from the other side.

**Why the two halves compose rather than fight.** The rendered offset is
`f(tab) + drag`. Both terms change on release, both animate with the same
spring from rest, and both start in the same turn — so the sum
interpolates as one settle. Stated because it is the one thing a reader
would reasonably worry about after MINOR 1's `@GestureState` move.

**PIN — declared honestly, per the brief's own instruction.** The
presence of a SwiftUI animation is not observable through this harness:
`accessibilityActivate()` is UIKit's activation dispatch, there is no
in-process road to a `DragGesture` recognizer, and a transaction's
animation is not exposed to a test. **So no new pin claims it**, and the
record says so rather than dressing a constant comparison as a guard (an
`#expect(settle == .interactiveSpring(…))` would restate the declaration
and prove nothing).

**What IS pinned, and was already green — the state-level contract the
brief names:** where a release LANDS is
`aDragLandsOnlyWhenItCrossesOrIsFlicked` (short of the distance → home;
across it → the next page; a flick lands without travelling; a
contradicted projection lands nothing), with `theBandsEndsAreWallsNotRubber`
and `aVerticalScrollNeverEngagesTheBand` beside it; and the mounted
`theTabBarCarriesThreeDoorsAndEachOneMovesTheBand` now drives the
ANIMATED `selectPage` on the real shell and still observes the selection
move. The fix changes no landing, so there is no red to quote here — and
that is the honest statement rather than a manufactured one.

**The feel rides the DEVICE QUEUE**, exactly as the swipe itself already
did (the batch record's own words). It is one gesture on her phone.

**Files:** `App/Variorum/VariorumMobile/Features/Shell/MobileShellView.swift`.

---

## Item 3 · MINOR 1 — a cancelled gesture can no longer strand the band · **FIXED**

`bandDrag` is now `@GestureState`, so SwiftUI resets it however the
gesture ends — cancellation included. The failure the finding names (a
system edge gesture takes over mid-pan; `onEnded` never fires; the shell
sits permanently part-way between two pages showing a sliver of each)
**cannot occur** rather than being cleaned up afterwards.

**The latch stays `@State`, deliberately, and this is the one judgement
call in the item.** `onEnded` must read the decision THIS drag took —
that is what makes a scroll that curves unable to page — and
`@GestureState` is documented as reset when the gesture ends, with no
guarantee about ordering against `onEnded`. Reading it there would have
been an untestable bet on undocumented ordering, on the seat's last unit
before a device build. So the gesture is now three clauses instead of
two: `onChanged` takes the latch and nothing else, `updating` carries the
drag, `onEnded` reads the latch and clears it in a `defer` on every road
out (including the declined one, exactly as before).

**What a stranded LATCH can still cost, stated rather than hidden:** a
cancelled gesture can leave `bandEngaged` set. Nothing renders from it,
so nothing is visibly stranded — the harmful half is gone by
construction. A stale `false` costs at most one swipe (the next drag
declines and `onEnded`'s `defer` clears it); a stale `true` lets the next
drag page from its first movement, which still has to cross
`landingDistance` to land anything. Both self-clear at the next release.

**PIN — declared, same reason as MAJOR 1:** a cancelled `DragGesture`
cannot be synthesized in process (the batch record's own harness
statement), and gesture-state lifetime is SwiftUI's, not the app's.
The arithmetic the latch feeds is pinned as a pure brain and unchanged.

**Files:** `App/Variorum/VariorumMobile/Features/Shell/MobileShellView.swift`.

**Suite (targeted, both items):** `✔ Test run with 14 tests in 1 suite
passed after 8.549 seconds.` — exit 0.

---

## Item 6 · MINOR 4 — a chapter past the window is no longer shown as EMPTY · **FIXED**

**The shape chosen, said plainly (the brief asked for the minimal honest
one and for it to be named):** the past-the-cut chapter is **FOLDED under
the listing's existing truncation marker**; the genuinely empty chapter
still renders. Nothing gains a second sentence — the marker already says
*"the rest of this book isn't loaded yet"*, and that is the whole story
for a chapter whose notes are among the rest.

**The distinction needs one fact, so the model reads exactly that fact.**
`MobileBookViewModel.populatedChapters` is the set of live chapter ids
holding at least one live, unarchived member ANYWHERE in the book — a
single `SELECT DISTINCT rp.section_id`, book-scoped, riding the SAME held
observation as the entries and the chapters (so the three can never
disagree), and **read only when the probe row says the window actually
cut something**. An untruncated book takes byte-identical work to before:
no extra query, and `populated` empty means `grouped` walks the path it
always did. The join mirrors the assembly's own membership join
(`deleted_at IS NULL AND archived_at IS NULL AND kind = 'post'`) so the
two readings count the same rows.

`grouped(_:chapters:populated:)` gains one clause: a chapter with no
windowed entry **and** a member somewhere is dropped; a chapter with no
windowed entry and no member renders, which is D3's New Chapter and the
reason the batch built empty-chapter rendering at all.

**New pin (PRODUCTION-driven, over a real truncated book):**
`aChapterWhoseNotesFellPastTheWindowIsNotShownAsEmpty` builds three
chapters — one holding the first note, one genuinely empty, one holding a
note that a `window: 1` model cuts off — and asserts the groups are
`["One", "Two"]` with counts `[1, 0]`, plus that the standing truncation
marker is the sentence carrying the folded chapter's story.

**Files:** `App/Variorum/VariorumMobile/Features/Shell/MobileBookViewModel.swift`,
`App/Variorum/VariorumMobileTests/MobileNavigationTests.swift`.

**Suite (targeted):** `✔ Test run with 15 tests in 1 suite passed after
8.321 seconds.` — exit 0.

**RED-ON-OLD — production revert `R-m4`** (the shipped grouping restored:
`chapters.map` with no `populated` clause):

```
✘ Test aChapterWhoseNotesFellPastTheWindowIsNotShownAsEmpty() recorded an issue at MobileNavigationTests.swift:637:13: Expectation failed: (groups.map(\.section) → [Optional("One"), Optional("Two"), Optional("Three")]) == (["One", "Two"] → [Optional("One"), Optional("Two")])
✘ Test aChapterWhoseNotesFellPastTheWindowIsNotShownAsEmpty() recorded an issue at MobileNavigationTests.swift:639:13: Expectation failed: (groups.map { $0.entries.count } → [1, 0, 0]) == [1, 0]
✘ Test run with 15 tests in 1 suite failed after 8.402 seconds with 2 issues.
```

`"Three"` returning as a third group with **zero** entries is the finding's
own lie, reproduced. Restored with `git checkout --`; `git status` clean.

---

## Item 5 · MINOR 3 — the A5-8 claim is now PINNED at the shell · **LANDED, and the probe's reading is explained**

**The pin:** `aPageChangeFilesTheQuickNoteBoxAndThisIsWhatItDoes` mounts
the real shell, types into the quick-note box, lets the **REAL** mint
clock fire (the state no existing pin reaches — every leaving pin in
`MobileQuickNoteTests` uses `quietBox`, clock stilled and `postID == nil`),
then activates the real `Library` tab door and measures the box.

**AND THE MEASUREMENT DIFFERS FROM THE REVIEWER'S — with the reason
measured rather than argued.** The reviewer observed
`handOffCount == 0` with the words still in the box, and traced it to
`file()`'s `guard autosave?.isDirty != true` road. What I measure is that
**both readings are the same run at two different instants**:

```
PROBE[A5-8·t0] handOffCount 0 · box "a thought left in the box"
PROBE[A5-8·t2] handOffCount 1 · box ""
PROBE[A5-8]    handOffCount 1 · box "" · postID false · containers 1
```

`selectPage` files in a `Task` — *navigation must never wait on a write*,
the shipped doctrine — so **in the activation's own turn nothing has filed
yet**, which is exactly the reviewer's reading; ~40 ms later the leaving
has completed. Reproduced **5 runs, 5 the same** (three clean repeats plus
the two instrumented ones). The `isDirty` road cannot be what ran: it
returns without bumping `handOffCount`, and the counter reaches 1.

**So the pin asserts BOTH halves, and they are both deterministic:** the
same-turn half has no `await` between the activation and the assertion, so
the `Task` provably cannot have run; the settled half waits on
`handOffCount` and then reads the box, the ownership, and the store's
container count. A5-8 holds on the shared road — the record's claim was
true, and it is now driven rather than inherited.

**No behaviour changed for this item** (the road is byte-identical to the
pre-batch one, as the reviewer verified), so there is no fix to red. Teeth
proven instead by a revert of the road the pin covers — below.

**Files:** `App/Variorum/VariorumMobileTests/MobileNavigationTests.swift`.

**Suite (targeted):** `✔ Test run with 16 tests in 1 suite passed after
10.514 seconds.` — exit 0.

**PIN-HAS-TEETH REVERT: PENDING** (runs after this commit).

---

## Item 7 · NIT 1 + NIT 2 · **BOTH DONE**

### NIT 1 — the dead `starredRows` parameter is RETIRED

The reviewer's own fix shape was *"nothing now"*; the adjudication ruled
DELETE, and delete is what landed. `MobileShelfLayout.naturalBooksHeight`
and `.split` lose the parameter, `starredRowHeight` / `starredChromeHeight`
go with it (their only readers), and `MobileShelfView`'s `starredRows: 0`
call site and its explanatory comment go with them. The shelf's starred
section moved to its own page at batch 10, so these were not merely a
constant caller — they were a dimension the shelf can no longer enter.

**The guarantee pin was re-derived, not weakened.**
`theWritingFloorIsAGuaranteeInEveryShelfState` keeps every region, every
book count and both extra-row values; it loses the stars loop and its
product becomes `43 * 7 * 2`. Measured: **602 shelf states checked** (was
2,408 — the same states, four times over, three of which the app cannot
produce). `starredRowsRideInsideTheBound` is DELETED: its whole subject —
starred rows pushing the books region — left the shelf, so it asserted a
property of an unreachable input. **Net test count: −1** (accounted for in
the final suite line below).

**Files:** `App/Variorum/VariorumMobile/Features/Shell/MobileShelfLayout.swift`,
`App/Variorum/VariorumMobile/Features/Shell/MobileShelfView.swift`,
`App/Variorum/VariorumMobileTests/MobileShelfLayoutTests.swift`.

**Suite (targeted):** `✔ Test run with 26 tests in 2 suites passed after
22.864 seconds.` — exit 0, and `PERF[sim] writing-floor guarantee — 602
shelf states checked, floor 140.0 pt`.

### NIT 2 — `offset` gains the `width > 0` guard its sibling had

One line in `MobileShellBand.offset`, and **pinned** rather than left as a
comment: two clauses in `theBandPutsTheShelfAtHomeBetweenStarredAndLibrary`
assert that a zero-width pass parks every page at home instead of
collapsing all three roots onto the live drag. The drag is deliberately
non-zero in the pin, because that is the only way the frame can happen:
`bandDrag` holds a value clamped against the PREVIOUS pass's real width.

**Files:** `App/Variorum/VariorumMobile/Features/Shell/MobileShellBand.swift`,
`App/Variorum/VariorumMobileTests/MobileNavigationTests.swift`.

**RED-ON-OLD (NIT 2) — production revert `R-n2`** (the guard line
removed):

```
✘ Test theBandPutsTheShelfAtHomeBetweenStarredAndLibrary() recorded an issue at MobileNavigationTests.swift:74:9: Expectation failed: (MobileShellBand.offset(
            for: .library, current: .shelf, drag: -120, width: 0) → -120.0) == (0 → 0.0)
✘ Test theBandPutsTheShelfAtHomeBetweenStarredAndLibrary() failed after 0.004 seconds with 2 issues.
✘ Test run with 16 tests in 1 suite failed after 10.429 seconds with 2 issues.
```

Restored with `git checkout --`; `git status` clean.

*(NIT 1 carries no revert: it DELETES a parameter, so there is no
behaviour to red — the honest evidence is the re-derived guarantee count,
quoted above, and a green suite with the parameter gone.)*

---

## Item 5b · MINOR 3's pin has TEETH — proven by reverting the road it covers

The item changed no behaviour, so its pin cannot red on a fix. It can
red on the road it exists to protect: with
`await quickNote.fileOnLeaving()` removed from `selectPage`'s task —

```
✘ Test aPageChangeFilesTheQuickNoteBoxAndThisIsWhatItDoes() recorded an issue at MobileNavigationTests.swift:296:17: Expectation failed: (router.quickNote.handOffCount → 0) == 1
✘ Test aPageChangeFilesTheQuickNoteBoxAndThisIsWhatItDoes() recorded an issue at MobileNavigationTests.swift:298:17: Expectation failed: (router.quickNote.text → "a thought left in the box").isEmpty → false
✘ Test aPageChangeFilesTheQuickNoteBoxAndThisIsWhatItDoes() recorded an issue at MobileNavigationTests.swift:299:17: Expectation failed: (router.quickNote.postID → "00000000-0000-0000-0000-000000000000") == nil
✘ Test run with 16 tests in 1 suite failed after 14.915 seconds with 3 issues.
```

A5-8 leaving the shared road is now a red test rather than a silent
regression. Restored with `git checkout --`; `git status` clean.

---

## Item 4 · MINOR 2 — the named chapter gap has a HOME · **DONE (notes only)**

The gap is real and consequential: `+ New Note` inside a book lands the
note **unsectioned**, and a chapter minted on the phone can be filled
only from the Mac — the phone can CREATE a structure it cannot USE. The
reviewer's point was not the gap but its address: recorded only in a
batch record, it lives in a file that CLOSES.

**Where it now lives:** `notes/plans/mobile-round-2-status-2026-09-01.md`
**§C's "YOUR RULINGS"** row — the document the post-13u resume session
reads — carrying the mechanism note (`newPostInReading` already takes
`section:`; the door is one argument away) and the three candidate
placements the record itself named (a per-chapter trailing `+ new note`,
the membership sheet, a drag). **It is filed as HER call**, per the
brief's own reading: the placement is a design question, and the
guardrails forbid inventing one.

**Not a ledger row, deliberately:** MobileSoul's parity ledger tracks
what MOBILE OWES A MAC PHASE. This is a phone-only door on a phone-only
surface with no Mac counterpart pending, so a PL row would have pointed
at nothing. The batch record's own gap section now points forward to the
status row rather than ending in itself.

**Files:** `notes/plans/mobile-round-2-status-2026-09-01.md`,
`notes/plans/mobile-batch-10-record.md`.

---

## THE FIX WAVE'S CLOSE

### The suite — full mobile target, one run, no restarts

```
✘ Test run with 727 tests in 103 suites passed after 348.273 seconds with 2 known issues.
** TEST SUCCEEDED **
```

Exit `0`; `^✘ Test .* failed` greps **0**; the leading glyph is the
runner's for a run carrying known issues and the word is **passed** (the
same two standing known issues as the batch's own run).

**727 against the review's 725 = +2, and the arithmetic is exact:**
**+3** new pins in `MobileNavigationTests`
(`aRefusedBookDoorSpeaksBesideTheDoorSheTapped`,
`aChapterWhoseNotesFellPastTheWindowIsNotShownAsEmpty`,
`aPageChangeFilesTheQuickNoteBoxAndThisIsWhatItDoes`) and **−1** in
`MobileShelfLayoutTests` (`starredRowsRideInsideTheBound`, retired with
the parameter it drove — NIT 1). Suites unchanged at **103**: nothing
declared a new one.

**The load-flaky perf pin did NOT red** (the box was at load ~19–22 for
this run): `PERF[sim] keystroke p95 — control 0.943 ms · 100k top 7.473 ms
· 100k end 8.387 ms` against the 12.0 ms budget. **No runner deaths** —
one run, one result, nothing re-run.

### The fence — re-derived over the whole wave (`3907624..HEAD`)

```
=== FILES TOUCHED ===
App/Variorum/VariorumMobile/Features/Shell/MobileBookView.swift
App/Variorum/VariorumMobile/Features/Shell/MobileBookViewModel.swift
App/Variorum/VariorumMobile/Features/Shell/MobileShelfLayout.swift
App/Variorum/VariorumMobile/Features/Shell/MobileShelfView.swift
App/Variorum/VariorumMobile/Features/Shell/MobileShellBand.swift
App/Variorum/VariorumMobile/Features/Shell/MobileShellView.swift
App/Variorum/VariorumMobileTests/MobileNavigationTests.swift
App/Variorum/VariorumMobileTests/MobileShelfLayoutTests.swift
notes/plans/mobile-batch-10-cold-review.md
notes/plans/mobile-batch-10-record.md
notes/plans/mobile-round-2-status-2026-09-01.md

=== FENCE GREP (Sources/ | App/Variorum/Shared/ | App/Variorum/Variorum/ |
    EditorBrain/ | Package.resolved | *.pbxproj | *.xcconfig | Server/) ===
EMPTY

=== planVisibleTakeEdit in the wave's diff, CODE ONLY ===
0
```

No `Package.resolved` drift; no `.pbxproj` change; `git status` clean at
every commit boundary and at the close. **Every production revert in this
wave was applied to a COMMITTED tree and restored with
`git checkout --`** (the protocol's own rule), so no restore depended on
a scratch copy.

### Every item, and where it landed

| # | item | disposition | evidence |
|---|---|---|---|
| 1 | MAJOR 1 · the band teleports | **FIXED** — one settle spring, both roads | animation DECLARED unpinnable in process; the landing contract's pins stay green |
| 2 | MAJOR 2 · the refusal speaks off-screen | **FIXED** — `doorRefusal` beside the doors | red quoted: refusal at y 89.0 vs door at y 566.7 |
| 3 | MINOR 1 · a cancelled gesture strands the band | **FIXED** — `@GestureState` + settle on its reset | by construction; DECLARED unpinnable (no synthesizable cancel) |
| 4 | MINOR 2 · the chapter gap has no home | **DONE** — §C YOUR RULINGS row, hers to place | notes only |
| 5 | MINOR 3 · the A5-8 claim is inherited | **PINNED**, and the probe's reading explained | `t0 → 0/kept`, `t2 → 1/cleared`, 5 runs; teeth proven by revert |
| 6 | MINOR 4 · chapters past the window read as empty | **FIXED** — folded under the standing marker | red quoted: `["One","Two","Three"]` with counts `[1,0,0]` |
| 7 | NIT 1 · the dead `starredRows` parameter | **RETIRED** — pin re-derived to 602 states | green with it gone |
| 7 | NIT 2 · the missing `width > 0` guard | **FIXED** and PINNED | red quoted: `-120.0` instead of `0` |

**Nothing in this section is PENDING.** The simulator was deleted at the
close.

---

# UNIT CLOSED (the Fable orchestrator, 2026-09-01)

**Batch 10's R28 unit is COMPLETE — and it is the SEAT'S LAST:** build
(four checkpoint commits through `9a515b7`…, surviving the harness
restart + system crash on the resiliency protocol) → cold review
`3907624` (0B · 2M · 4m · 2n — the band that teleported; the refusal
that spoke off-screen) → fix wave `8cb9c25`, all seven items, per-piece
commits pushed. **Final: mobile 727/103 green, 2 known issues.** Fence
clean at every commit, verified by the orchestrator. Shipped: the
Starred ‹ Shelf › Library band with a settle spring on every landing
(taps glide too — her device judges it), the starred page as a face
over the existing star (the above-the-shelf placement retired), New
Note (gate inside the mint's transaction) + New Chapter (curated-only)
inside a book with the refusal spoken beside the doors, empty chapters
rendering, past-the-window chapters folded under the marker.

**Held/owned out of this unit:** the assign-to-chapter door's placement
(HER call — status file §C); the swipe's real pan feel + the tap glide
(device queue); the `MobileSurfaceDriver` harness gap (pre-existing;
blast radius ZERO today, enumerated in the review — forward risk for
any future shell-mounted absence pin; noted for the leftover-backlog
batch's harness half); the finished-book divergence recorded as chosen.

**THE ROUND PAUSES HERE at her word** (status file §H): the Release
build of this tree installs to her phone as the seat's closing act;
batch 8 and the rest resume after 13u + the merge.
