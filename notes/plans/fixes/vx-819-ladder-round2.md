# VX-819 — ladder round 2 (cold review of the ROUND 1 FIXES)

Reviewer: `opus-reviewer` (fresh, zero implementation context), running `notes/REVIEW_PROMPT.md` verbatim in its
round-2 form over the round-1 fix commits named in `notes/plans/fixes/vx-819-ladder-round1.md` § ROUND 1 FIXES
(`24d34c440`/`959d81d41` F2 · `0a66343fd`/`e17a210f1` F1 · `6c38ba2b4`/`bf3b45531` F3 · `439d7f187` plumbing ·
`a0190647b`/`969ff499a` F4 · `662d91845` F5 · `3a328f451` F6 · `5da995e87`/`f39b8307b`/`f86f6f3f7` F7), anchored on
A-819-L1's dispositions. Branch `vx-819-search`, head `e8b1403da` at the round's start.

**Class check.** The fix diffs touch no `Sources/VariorumCore/Sync/`, no custody/keychain/`Protection/` line, no editor
seam (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, the read tier), no schema, no default's meaning. The
Opus-eligible class holds.

**STATUS: IN PROGRESS.**

## Findings (appended as found; severity-ranked at the round's end)

### R2-1 · [NIT] · `App/Variorum/Variorum/Features/Library/SidebarSearchField.swift:24–26`, `:110–111` · `App/Variorum/Variorum/RootView.swift:264–265` · `LibraryCatalogModel.swift:332–333` · docs that say the sidebar rides ⌘K's road, and one that names a dependency that does not exist

**What.** After the plumbing `439d7f187` the sidebar's `ask` no longer calls `RootView.searchLibrary` — it lands through
`LibraryCatalogModel.takeSidebarQuestion` — and after F1 (`e17a210f1`) and F3 (`bf3b45531`) that road DELIBERATELY
differs from ⌘K's (it yields a Timeline Library to List; a new sidebar search resets the order and facets; ⌘K's road
does neither — A-819-L1). Three docs still say otherwise: the file header ("its words go to the Library's one question
through ⌘K's road (`RootView.searchLibrary`)"), `SidebarSearchDoor.ask`'s doc ("… where it is not already showing (⌘K's
road)"), and the `searchDoor:` argument's comment in RootView ("⌘K's road into the Library's one search"). Separately,
`takeSidebarQuestion`'s F1 comment ends "either way the caller's `search()` reads the new mode" — `read()`
(`LibraryCatalogModel.swift:797–849`) reads no mode at all (the listing takes question · scope · sort · direction · day
· wing · depths · order); the mode only decides what the view draws.

**Evidence / degradation.** A later session acting on the QUESTIONS line A-819-L1 opens (does ⌘K's road also yield
Timeline / start new?) would edit `searchLibrary`, trust these docs, and believe the sidebar follows — it would not, and
the two roads would drift silently. Clarity only; no behaviour.

**Proposed.** Reword the three to "the sidebar's own landing door (`takeSidebarQuestion`) — ⌘K's adoption, its own
new-search reset and Timeline yield"; drop the mode sentence or say "the mode only decides what draws; the read is the
same". (A related wording note on F5's guard doc: `SearchOrderTests.theSwiftFoldAndTheStatementsCollationAreOneTruth`
says "a future restated literal on either side fails here" — a restated literal that AGREES passes; what fails is
DRIFT, which is the protection worth having. One-word fix: "a future change on either side that disagrees fails here".)

### R2-2 · [NIT · record] · `notes/plans/fixes/vx-819-ladder-round1.md` F1 row · the red tree's expected count for F1 is one issue per argument, not two

**What.** The F1 row says the red tree shows "2 issues per argument: the mode, and the settle's answer". The shell
suite's `settle` (`App/Variorum/VariorumTests/SidebarSearchFieldTests.swift:131–147`) is `@discardableResult` and
records no issue on a timeout, and `#expect(catalog.isSearching, …)` is GREEN on the red tree: the ask spawns
`catalog.search()` directly, `read()` never reads `mode`, so the answer lands in `searchState` while the Library stands
in Timeline (which is exactly F1's mechanism — the answer exists, nothing draws it). So the red tree shows ONE issue
per argument (`catalog.mode == .list`) — two only if Timeline's mount happens to take the keyboard, which would be a
different fact. The other expected counts check out by the same reading: F3 = 3 (order, archived, commits); F4 = 3 on
the red tree (the field's words under the palette, the query after esc, `isAnswering`) — "≥ 2" holds; F2 = 2 (the
shell's caret left `(0,7)`, and the ONE decoy the walk stops at — the other decoy is never reached).

**Proposed.** Correct the row to "≥ 1 per argument (the mode)" so the staged gate reading a red does not chase a
missing second issue. Record only.

### R2-3 · [NIT · process] · A-819-L1's F8 closeout list omits F4's PROVISIONAL

**What.** F8's disposition lists for the merge moment "P-a…j, P-819-B3a…h as amended, the VX-90 B2 alternative, F1/F3's
lines". F4's fix (`969ff499a`) carries its own PROVISIONAL consequence — the field lets its words go as the palette
comes up, so a palette dismissed WITHOUT its road leaves the sidebar's question standing in the Library and the field
empty (her next word there starts a new search, F3; "harb" ⌘K esc "our" asks "our", not "harbour") — and it is named
only in the fix session's self-assessment, not in the orchestrator's F8 list or the run record's PROVISIONAL list
(`vx-819-search.md` batch 3 amends only P-819-B3d).

**Proposed.** Add "F4's consequence (scoped to the palette, never every sheet)" to the F8 closeout line, beside F1's and
F3's, so the QUESTIONS entry carries it. No code.

### R2-4 · [NIT · pre-existing, outside F6's scope] · `Sources/VariorumCore/Domain/SearchComposer.swift:636–642` vs `:536–541` · the group facts' aggregate is still spelled twice

**What.** F6 made the page ONE statement, but the group facts themselves (`MIN(s.score) AS g_best, COUNT(*) AS g_hits,
SUM(s.kind <> 'title') AS g_lines`) are also spelled in `wornGroupFacts` (batch 2's ladder MINOR-1), whose whole point
is that a worn lead group says what its ranked group "would have said". A future change to `g_lines` in `groupPage`
(F6's own example class) would not reach `wornGroupFacts`, and the lead group's "all N ›" road would disagree with the
page. Not new, not owed this run (the two statements' materialization differs for bm25's sake, so a shared CTE is not
mechanical); a shared column-list constant would close it in two lines. Leave or ticket as Debt at the orchestrator's
call.

## Clean bill
