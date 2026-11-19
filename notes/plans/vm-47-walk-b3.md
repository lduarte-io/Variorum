# VM-47 — batch 3's stage windows and the walk (the closer's record)

**What this file is.** While batch 5's implementer holds `notes/plans/vm-47-sizes-and-look.md` and every file under
`App/` (the orchestrator's word, 2026-11-19, after the batch-3 phone window), batch 3's closer records here: the
suites' results, the reds and their traces, the walk's captures and findings. Fixes are written down as exact
proposals (file, lines, the change, the pin), NOT applied: a fix batch applies them after batch 5. At the record's
close this file's sections fold into the run record's §6 "Batch 3 — results" and its LIVE STATUS rows 3.12–3.15.

## Batch 3 — the suites

Run by the ORCHESTRATOR under its own stage claim (released 10:09), from a gate snapshot at `54cbcb9e5` (batch 3's
tree with piece 3.10, `4cca58a8e`, and the READY record). Logs: the session scratchpad's `b3-phone.log`,
`b3-nav-alone.log`, `b3-rol3.log` (not in the repo).

- **The whole phone target** (`-only-testing:VariorumMobileTests`, test-without-building from `DerivedData/vm47-b3`,
  the standing suite device): "Test run with 916 tests in 151 suites failed after 515.539 seconds with 12 issues
  (including 8 known issues)". Known issues (8): the four pre-existing (the empty-accessibility-tree diagnosis ×2,
  the fanned-divide lesson ×2) and P-47-7's four filter-row marks. Reds:
  1. VM-24's caret test (`aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep(_:)`, 2 of its 3 cases) —
     main's one known red, not this run's; nothing changed.
  2. `MobileNavigationTests.theTabBarCarriesThreeDoorsAndEachOneMovesTheBand()` — `MobileNavigationTests.swift:221`
     `selection(surface, "Starred").allSelected` and `:229` `selection(surface, "Library").allSelected`, 2 issues.
     Re-run ALONE in the same claim: the same two issues ("15 tests in 1 suite"), so deterministic. Traced below
     ("The navigation red"): a test premise batch 3 changed by design, not a regression.
  Every batch-3 suite ran green inside it, piece 3.10's two new pins included (`theEditorsGroundIsThePaper`,
  `theNoteInWriteIsOnThePaper`), and VM-54's four.
- **VM-54's red-on-old** (the snapshot `~/dev/variorum-vm-47-rol3` at `b395f03e8`, the four sites' fix reverted
  there only, `-only-testing:VariorumMobileTests/MobileBorderTraitTests`): "Test run with 4 tests in 1 suite failed
  after 0.337 seconds with 5 issues" — `aTakeCardsEdgeFollowsTheFlip()` (2), `anArchivedCardsEdgeFollowsTheFlip()`,
  `theTakesPillsEdgeFollowsTheFlip()`, `theCommentDraftsEdgeFollowsTheFlip()`. All four GREEN on the fixed tree in the
  whole-target run. **Red on old, green on new: VM-54 is FIXED with its pin** (the on-screen flip rides the walk,
  part B).
- **The Mac leg** (the 102 theme-store types + the seven theme types, §6 of the run record): ~~PENDING its window~~ —
  RUN (the orchestrator, 10:38–10:53, the same gate snapshot; the run record's row 3.12): "Test run with 511 tests in 102
  suites passed after 836.278 seconds with 4 known issues", none failed; 10 suites (24 tests) skipped by their own opt-in
  gates; the 4 known issues pre-existing.

## The navigation red

**`theTabBarCarriesThreeDoorsAndEachOneMovesTheBand()` — green on the batch-2 tree (the 06:26 whole-target run), red
on batch 3's (`54cbcb9e5`).** Verdict: **a test premise batch 3 changed by design; NOT a product regression.** The
selected tab is drawn and spoken as selected on every copy of the bar.

*The test, at `54cbcb9e5`* (`App/Variorum/VariorumMobileTests/MobileNavigationTests.swift:186–237`). It mounts the real
shell (`MobileShellView` over a `withEditorWorld` library with a fresh `MobileShellRouter()`), presses the doors
through `accessibilityActivate()`, and judges the selection with a local helper that collects EVERY walked element
whose `accessibilityLabel` equals the door's word (`:192`), then asks whether all of them carry `.selected`:

```swift
let doors = surface.visibleElements.filter { $0.accessibilityLabel == label }
let selected = doors.filter { $0.accessibilityTraits.contains(.selected) }
return (doors.count, !doors.isEmpty && selected.count == doors.count, selected.isEmpty)
```

The file's own header records why it counts copies: the walker descends raw subviews, so all three roots (each
wearing the shell's one `tabBar`) are in the walked tree, and the doors come in threes. Its unstated premise: **no
element other than a tab door is labelled "Starred", "Shelf" or "Library".**

*What the run measured* (`b3-nav-alone.log`, lines 46–60): `selection(surface, "Starred") → (copies: 4,
allSelected: false, noneSelected: false)` and the same for "Library". Four elements, some selected but not all:
three door copies carrying `.isSelected`, and one more element with the same label that is not a door. The Shelf door
passes at home (`:213`) and its copies stay three (`:234` passes).

*The fourth element.* At `54cbcb9e5` exactly two non-door elements in the phone app can carry these words: the
Starred root's path line, `Text(tokens.path([MobileStarsModel.pageName]))` (`MobileStarredView.swift:101`), and the
Library root's, `Text(tokens.path(["Library"]))` (`MobileLibraryView.swift:208`). The Bookcase root's path is
`tokens.path(["Shelf"])` + "  ·  N books" (`MobileShelfView.swift:247`), never the bare word, which is why only
Starred and Library fail. The voice decides what a path line reads: Terminal's idioms are `pathPrefix "~/"`,
`lowercasesChrome true` (`~/starred`, `~/library`); Study's are `pathPrefix ""`, `pathSeparator " · "`,
`lowercasesChrome false` (`VoiceTokens.swift:373–377`): **"Starred", "Library": the door's own word.**

*What batch 3 changed.* Before it (`ea738c49f`), the shell's tokens were `.resolve(voice: router.voice, …)` and a
fresh `MobileShellRouter()` read its voice from the phone's own preference, `MobileVoicePreference.current(.standard)`,
whose absent value is **Terminal** (`MobileVoicePreference.swift:30–32` at `ea738c49f`). So the harness shell wore
Terminal, the path lines read `~/starred` and `~/library`, and the label-only helper found exactly the three doors.
Batch 3 (VM-51, her LK-1: the phone wears the LIBRARY's voice) retired that preference: the shell binds the
library's theme store (`router.bindTheme(session:)` in `MobileShellView.init`), wears its placeholder until the first
landing and then the library's settings, and a fresh library reads **Study** under the sea-glass
(`Queries.ThemeSettings.unsetStoreVoice`, AppSpec §12; `MobileShellRouter.placeholder`, P-47-15, is the same). The
`withEditorWorld` library is fresh, so the mounted shell is in Study, and each root's path line now carries its
door's word. The unbound-router harness road (`5b5d7b9be`: `settings` falls back to the editor face's look) is NOT
involved: the shell binds the router in its initializer, so the store is bound here.

*Why it is not a regression.* The three door copies are rendered from the shell's ONE `tabBar` property reading ONE
`tab` state with `.accessibilityAddTraits(tab == target ? .isSelected : [])` (`MobileShellView.swift:610–624` at
`54cbcb9e5`), and the measured copies say three of four are selected after each press: the doors moved, the band
moved (the previous door's `noneSelected` checks pass at `:223` and `:230`), and every door copy speaks "selected".
An assistive reader on the Starred root hears a "Starred" title (the path line) and a "Starred, selected" tab:
ordinary, and the same as the Mac's sidebar heading beside its area row. The voice is the library's by her ruling, so
the premise is what moved, not the product.

*Batch 4's tree* (the worktree's HEAD; VM-52, `9c76b335c` and `35fc0a461`). Batch 4 replaced the bar with
`Shell/MobileTabBar.swift`: each door is a `Button` with `.accessibilityLabel(word)` (`word`: "Starred",
"Bookcase", "Library") and `.accessibilityAddTraits(chosen ? .isSelected : [])` (`MobileTabBar.swift:130–146`), and
every root still wears the bar (`MobileShellView.swift:208/217/243` at HEAD; pushed lists also wear it, which does
not enter here since nothing is pushed). The roots' path lines are unchanged at HEAD (`MobileStarredView.swift:101`,
`MobileLibraryView.swift:208`, Study: "Starred", "Library"). `theTabBarCarriesThreeDoorsAndEachOneMovesTheBand()`
at HEAD (`MobileNavigationTests.swift:186–240`) only moved its middle word to "Bookcase" and kept the label-only
helper (`:192`). So:
- **There is no defect to survive into batch 4's bar** (none was traced in the old one).
- **The false red DOES survive**: on batch 4's tree the same test is expected red at `:224` (Starred) and `:232`
  (Library) with `copies: 4`, for the same reason. Batch 4's own window should expect those two issues and not read
  them as its bar's.
- **Would batch 4's version catch a real selection defect?** As written, no: it is red whether or not the trait
  moves, so it cannot tell the two apart. Batch 4's OWN pins can: `MobileTabBarTests` already narrows its door
  lookup to buttons (`onScreen`, `MobileTabBarTests.swift:55–61`: label AND `.button` AND on the window) and asserts
  the trait on the on-window door (`:181`), so a selection that failed to move would turn those red.

*Proposed fix — TEST ONLY, for the fix batch after batch 5 (not applied; the worktree is batch 5's).* **APPLIED since**
as `8eb727f2e` (at the coordinator's hand-off, during batch 5: the selection helper counts buttons only, as below) and
VERIFIED: `theTabBarCarriesThreeDoorsAndEachOneMovesTheBand()` green in batch 5's short piece (the run record's row 5.7
(a)).
`App/Variorum/VariorumMobileTests/MobileNavigationTests.swift`, `theTabBarCarriesThreeDoorsAndEachOneMovesTheBand()`'s
`selection` helper, line 192 at HEAD (the same line at `54cbcb9e5`):

```swift
// Buttons only: in Study a root's path line reads its own door's word ("Starred", "Library")
// — the library's voice since VM-51 — and is not a door.
let doors = surface.visibleElements.filter {
    $0.accessibilityLabel == label && $0.accessibilityTraits.contains(.button)
}
```

Why the old form cannot be true: under the library's voice (LK-1) a fresh library is Study (AppSpec §12), and
Study's path grammar has no prefix and no lowercasing, so a root's title carries its door's word by design; a
label-only count is then four, not three. The narrowed helper keeps the pin's teeth: if the selected trait failed
to move, the three BUTTON copies would read unselected and `allSelected` would still fail; `copies == 3`
(`:237` at HEAD, `:234` at `54cbcb9e5`) then holds in both voices. Evidence the fix batch must show: the test green on the fixed tree in Study (the harness's
voice); and, optionally, a mutation check — `.accessibilityAddTraits([])` on the door in a snapshot — turning it red
at `:216/:224/:232`, so the narrowed helper is shown to still catch a selection that does not move. No product file
changes.
