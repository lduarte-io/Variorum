# VX-819 — ladder round 1 (cold review)

Reviewer: `opus-reviewer` (fresh, zero implementation context), running `notes/REVIEW_PROMPT.md` verbatim over
`git diff origin/main...HEAD` on branch `vx-819-search` (head `858ecae93` at the round's start). Class check: the diff
touches no `Sources/VariorumCore/Sync/`, no custody/keychain code, no editor seam (`EditorTextView`, `BlockRangeIndex`,
`PaneSurface`, the read tier) — the Opus-eligible class holds.

**STATUS: IN PROGRESS — findings land below as found; the clean bill closes the round.**

## Findings (severity-ranked at the round's end; appended as found)

### F1 · [MINOR] · `App/Variorum/Variorum/RootView.swift:1714–1734` + `Features/Library/LibraryCatalogView.swift:257–270` · the sidebar door lands a Library in Timeline mode that shows no answer (R-819-4 gap)

**What.** R-819-4: "typing in the sidebar field shows the Library beside it with the live answer as you type". The
catalog's `mode` is per-window session state (`LibraryCatalogModel.swift:67`, not persisted). When she has picked
Timeline in this window's Library earlier in the session, the sidebar's `ask` road (`RootView.sidebarSearchDoor.ask`
→ `catalog.query = words; catalog.search()`, or `searchLibrary` + `adopt(.library…)`) lands the Library in
`.timeline`, where the body's switch draws `TimelineView(session:)` (it takes no query) instead of `searchSheet`
(`LibraryCatalogView.swift:257–270`), and the band is suppressed (`showsBand` requires `showsCatalogControls`,
`:432–434`). Mechanism: `mode == .timeline` → sidebar keystroke → question lands in `searchState` → nothing she can
see changes; ⏎ then hands the keyboard to a Library field whose words still answer nothing on screen.

**Evidence.** Traced by read (no live run — Mac tests are out of this round's reach). Pre-existing for ⌘K's
`searchLibrary` and for the Library's own field in Timeline (13o); the sidebar door is NEW exposure, and unlike the
Library's own field she cannot see why nothing answers (the mode picker sits in a pane she is not looking at).

**Proposed.** Product-silent edge → a `notes/QUESTIONS.md` line, not a ruling here. Options: (a) the sidebar's first
ask moves a Timeline Library to List (the Cards→Notes coupling's precedent, `pickMode`); (b) the same for ⌘K's road
too (one road, `searchLibrary`); (c) accept and record PROVISIONAL. If (a)/(b) is ruled, the pin is a mounted shell
test: `catalog.pickMode(.timeline)`, type in the sidebar field, expect the answer sheet's mode (RED on this head).

### F2 · [MINOR] · `App/Variorum/Variorum/Features/Library/SidebarSearchField.swift:359–385` · `CarriedWordsCaret` places the caret in whichever window it meets first, not the Library field's own

**What.** `toEnd(of:in: NSApp.windows)` walks EVERY app window and stops at the first whose first responder is a
field editor showing the same words (`:363–372`), returning `true`. With two Variorum windows where window B's
Library field (or any field) is being edited with the same words, an ⏎ handoff in window A can set B's caret and
stop — A's Library field, focused by code, keeps AppKit's select-all (the very trap the type exists for, its own
doc `:354–358`), so her next key REPLACES the carried question. `NSApp.windows` order is not the key window
first, so which window wins is incidental.

**Evidence.** Mechanism traced by read; reachable only with two windows holding identical words in an edited field,
so rare. A red-on-old pin is constructible (two `KeyedTestWindow`s, B's Library field editing "harbour", A's
sidebar ⏎ with "harbour" → A's `selectedRange` is the whole word) — the pin would be RED on this head.

**Proposed.** Scope the walk to the Library field's own window (the catalog view can hand its window — e.g. the
key window at the ask, or an `NSViewRepresentable` probe beside the field), or check `window.isKeyWindow` first.
A few lines; MINOR because the failure is rare but silent and destroys her question on the next key.

### F3 · [MINOR] · `App/Variorum/Variorum/RootView.swift:1714–1734` + `Features/Library/LibrarySearchModel.swift:328–337` · a sidebar search inherits the previous search's order and facets (the brief's reset shape is defined per field)

**What.** The batch-2 brief's PROVISIONAL reset shape: "a NEW search (the field going from empty to typed) starts at
relevance; refining keeps; a cleared field discards". The reset lives only in `read()`'s `if question == nil {
searchState.resetFacet() }` (`LibraryCatalogModel.swift:796`). The sidebar field is a SECOND field that opens EMPTY
while the Library searches (P-819-B3d, "a door, never a mirror"); its first keystroke `edit` → `.ask(words)` →
`catalog.query = words` REPLACES the Library's question without ever passing through empty — so the order she picked
for the old, unrelated question (and `+ archived`, `+ commits`, the book-state facet) silently carries onto the new
one. From her side the sidebar field went empty → typed: by the brief's letter that is a new search.

**Evidence.** Traced: `SidebarSearchFieldRule.edit` (`SidebarSearchField.swift:67–72`) → `door.ask` →
`RootView.swift:1720–1722` → `read()` with a non-nil question → no `resetFacet()`. ⌘K's `searchLibrary` has the same
shape for the facets (pre-existing); the ORDER's carry is new with VX-820. Pin (if the reset is ruled): mounted
shell test — Library on "lamp" with `.home(.createdAt, .asc)` and the archived facet on; type "harb" into the
sidebar field; expect `searchState.order == .relevance` (RED on this head).

**Proposed.** Product-silent edge → QUESTIONS (one line beside P-d/P-819-B3d): (a) the sidebar's FIRST ask (the rule
was empty) resets the facets and order before asking — the door starts a new search; (b) keep the carry and say so
in P-d. Not a ruling here.

