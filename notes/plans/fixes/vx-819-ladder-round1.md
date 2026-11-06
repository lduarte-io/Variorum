# VX-819 — ladder round 1 (cold review)

Reviewer: `opus-reviewer` (fresh, zero implementation context), running `notes/REVIEW_PROMPT.md` verbatim over
`git diff origin/main...HEAD` on branch `vx-819-search` (head `858ecae93` at the round's start). Class check: the diff
touches no `Sources/VariorumCore/Sync/`, no custody/keychain code, no editor seam (`EditorTextView`, `BlockRangeIndex`,
`PaneSurface`, the read tier) — the Opus-eligible class holds.

**STATUS: ROUND 1 COMPLETE (2026-11-06).** No BLOCKER, no MAJOR. Three MINOR (F1–F3: two are product-silent edges for
`notes/QUESTIONS.md`, one a small cross-window hazard), five NIT (F4–F8). Severity order: F1, F2, F3 (MINOR) · F4–F8 (NIT).

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

### F4 · [NIT] · `App/Variorum/Variorum/RootView.swift:1724–1727` · the sidebar field's `end` clears whatever the Library is asking, not only the question it asked

**What.** The field's words are "the Library's question exactly while they are not empty" (`SidebarSearchFieldRule`'s
own doc) — true while every other road that rewrites `catalog.query` also takes the keyboard (or a mouse-down, which
the click monitor hears). One road does neither: ⌘K's palette is a `.sheet` (`RootView.swift:385–394`); while it is
up the main window keeps the sidebar field editor as its first responder, and its "search the Library" row runs
`searchLibrary(paletteWords)`. Back in the window the sidebar field still holds ITS words over the palette's
question: esc → `.end` → `catalog.query = ""` ends the palette's search; ⏎ → hands the Library field the palette's
words, not the field's.

**Evidence.** Traced by read; a narrow edge (she must leave the caret in the sidebar field, ⌘K, pick the road row).
A mounted pin is constructible (type in the sidebar field → `searchLibrary("lamp")` → esc → expect `catalog.query ==
"lamp"`), RED on this head — but the right behaviour is unruled, so it is a NIT, not a bug claim.

**Proposed.** Either guard the door (`end` / the handoff act only while `catalog.query == ` the field's words —
otherwise the field just clears), or record the edge with P-819-B3d/e. One line either way.

### F5 · [NIT] · `Sources/VariorumCore/Domain/SearchOrder.swift:37–40` vs `Sources/VariorumCore/Queries/LibraryPaging.swift:238` · "the title order folds case" is stated twice

`SearchOrder.foldsCase` (`sort == .title`, read by the Swift worn-day merge `precedes`) and `LibrarySort.keyCollation`
(`self == .title ? " COLLATE NOCASE" : ""`, read by the SQL statement and the catalog) are two copies of one fact.
If the catalog's title collation ever changes (or another sort gains one), the statement follows `keyCollation` and
the worn-only merge keeps the old rule — misplacing a worn-only note across a page boundary. Today they agree, and
`theOrdersSwiftComparisonIsSQLitesOwn` pins the comparison, not the coupling (`aNamelessNoteWearingTheDayTakesItsPlaceInTheOrder`
exercises created/date only, never title). Derive one from the other (e.g. `foldsCase` from `keyCollation`, or a
`LibrarySort.foldsCase` both read). Clarity, no bug today.

### F6 · [NIT] · `Sources/VariorumCore/Domain/SearchComposer.swift:493–615` + `Sources/VariorumCore/Queries/SearchQueries.swift:261–436` · two copies of the group page

`homeOrderedGroups` re-spells `groups`' whole CTE (`scored` / `grouped` / `gpage` / `ranked` / `top` / the snippet
stage) with three lines changed, and `homeOrderedPage` re-spells `searchGroups`' row-folding loop and its
`SearchGroup` construction. Keeping relevance's statement byte-identical was a deliberate choice (its EXPLAIN pins),
but the two copies can now drift — e.g. a future change to `ranked`'s `ROW_NUMBER` order, the savepoint stage or
`titleMatched` lands in one order family only. Both plans are pinned (`everyHomeOrderedStatementStaysDrivenByTheIndex`,
`everyFacetsGroupAndCountStatementsStayDrivenByTheIndex`), so the hazard is semantic drift, not P1. A shared builder
parameterized by (key column, ORDER BY, keyset) would leave relevance's text unchanged. Architectural NIT; not
worth reopening this run unless a later round touches the group page.

### F7 · [NIT] · stale lines and dead code left by the run

- `App/Variorum/Variorum/Features/Library/LibrarySearchModel.swift:102` — `LibrarySearchQuestion.scopeFilter(_:)` has
  no reader left anywhere in the repo (app, tests, core) since the facets moved to core; delete it (its doc still says
  "the scope picker's four answers").
- `App/Variorum/Variorum/Features/Library/LibraryControlsFlow.swift:609` (`sortWidest`'s doc: "…and the search's
  relevance label") and `LibraryCatalogView.swift:710` ("…and the relevance label") still name the retired label; the
  slot's search form is the `order ▾` door (its `sortForms` doc at `:624–628` was updated, these two were not).

### F8 · [NIT · process] · the closeout owes canon lines and QUESTIONS entries the diff already depends on

Not a defect of the diff (ledger row 8 is NOT-STARTED), listed so the closeout does not drop one. SurfaceContracts
(The Library, The app) has no line yet for: (1) a picked facet's band counting what it lists, All the whole question
— superseding P-13o-U2-2's "the counts never move with the scope" (13o plan); (2) the search state's `order ▾` door
(relevance default per search, the four orders with direction, the Books section keeping its own order, the row stamp
speaking the order) — superseding P-13o-U2-7's plain label; (3) the sidebar field (place, the keyboard law, ⏎/esc/
click, door-not-mirror, never a key-view stop); (4) the month grid's keys (← → ↑ ↓ ⏎, the ring, nothing arms on
focus — superseding P-VX83-B3's "no arrow-key day navigation", `vx-83-search-followup.md:509`); (5) the passage
line's quiet block-name mark. The PROVISIONALs P-a…c, P-d…j, P-819-B3a…h and the VX-90 B2 alternative need their
`notes/QUESTIONS.md` lines; F1/F3 above add two more edges if not ruled.

## Clean bill — load-bearing things checked and found solid

- **Class check.** The diff touches no `Sources/VariorumCore/Sync/`, no `Protection/`/custody/keychain line, no editor
  seam (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, the read tier), no schema/migration, no MCP door line
  (`MCPReadTools.encodePassage` maps fields explicitly — the new `blockName` never reaches the wire), no
  `Registry/Capability*.swift`. The opus-reviewer class holds. Read-side only: no operation, no write.
- **VX-734 / R-819-1 (core).** `SearchFacet.blocks` is A-819-B1's set exactly; the savepoint fence stays upstream of
  every facet (`hits`' `d.kind <> 'savepoint'` off the commits facet). Traced the facet filter at every level it is
  composed: `.passage` (residual OR per examined match), `.note` (`docKind` → title-only, so worn days never list under
  Blocks), `.reading` (`family(.scraps)`/`docKind(non-book)` → `0`, so a typed tag's associated books never count under
  Notes or Blocks — the band cannot disagree with a sheet that shows no Books section). `searchCounts(…facet:)` counts
  the narrowed question through the one builder; the tag-alone road keeps one kind + its archive share. Ran
  `SearchFacetTests` 9/9 green.
- **VX-820 / R-819-2 (core).** `homeOrderedGroups`: `home_key` read off the already-joined `c` (never NULL there —
  `d.reading_id IS NULL` forces `c.id IS NOT NULL` by the hits' own condition, and every key COALESCEs to the NOT NULL
  `created_at`, so the non-optional `row["g_key"]` decode is safe); the row-value keyset `(g_key COLLATE NOCASE,
  g_home) >/< (?, ?)` matches the `ORDER BY` collation-for-collation; passages stay best-first (`rn` untouched).
  `homeOrderedPage`'s worn-day merge: worn notes with hits list once at their statement place (`wornGroupFacts` over
  the same builder), worn-only notes are placed inside `(cursor, next]` by a Swift compare that reproduces SQLite
  BINARY/NOCASE (pinned), the last page (`next == nil`) catching every remaining one — every group once across pages,
  traced for both directions incl. the title order's digits-before-letters case. P1: same one walk of the matches;
  `homeKeys` bounded by ids; both plans pinned FTS-driven. The catalog's own listing is the oracle for all eight
  orders at 1/2/25 a page. Ran `SearchOrderTests` 7/7 green.
- **VX-90.** `b.name AS block_handle` reads the block row the hits already seek — no join, no plan change
  (`SearchPassagesTests` EXPLAIN pin green); the mark rides inside the snippet's one Text, never on a block-name hit,
  never blank; the find seed reads `passage.snippet`, never the marked line, so the landing needle is untouched.
- **VX-408.** The question token is sound: `search()` bumps `askedQuestion` synchronously before its read; a read
  carrying an unlisted question lands as that question's first page (depths, resets, no expansion reload); the catch
  path leaves `listedQuestion` alone (the next read starts over — conservative). Pin A green-on-both is honestly
  recorded as the hollow half; pin B's interleaving is deterministic (the DEBUG gate is nil outside the pins).
- **App order lifecycle.** The order resets only where the facets reset (`read()`'s `question == nil`), the paging
  continues `listedOrder` with its own cursor (a pick goes through `search()`, which bumps the generation, so
  `canAskForMoreGroups` cannot mix a stale cursor with a new order); `land`'s `sameQuestion` includes the order; the
  door is drawn only while the sheet answers words (`isAnswering`), so the tag-alone listing keeps the Library's
  `sort ▾` (SurfaceContracts: "sort and scope live"); the pick's direction rule mirrors `setSort`'s natural direction.
  The stable-widths count gains the door's relevance form with `voicedMenuChrome`; home forms are the `sort ▾` labels
  already counted; the line-count sweeps gained three order states.
- **VX-374.** R2-4's `single` is read only on the one-line road (traced through `arrange`), behaviour-preserving; the
  caps named, frames byte-identical, the natural ≤ cap guard honestly labelled a guard.
- **VX-822 (composition and keyboard).** The sidebar holds closures only (CLAUDE.md's cross-feature rule; P-4: no
  broadcast decides anything); one engine — the field writes `catalog.query` and calls the catalog's own `search()`,
  wing-scoped by the catalog; `.library` is never deduped by `paneShowing` (notes only), so the ask never meets the
  same-note refusal; the field is `canBecomeKeyView == false` (VX-332's quick-entry caret is safe at a window's
  opening — pinned); ⏎/esc are intercepted at `doCommandBy` and return `true`, so editing never ends on them and the
  follow-on `controlTextDidEndEditing` meets an already-empty rule (`.none`); clearing through the field EDITOR keeps
  the caret; the click monitor never swallows, is scoped to its own window and is released on a nil window; the
  overlay takes no layout (the no-shift pin compares the first section's top with and without the field, both
  Starred states).
- **VX-98.** The rule is pure and pinned (chords, Esc, letters and ⏎ on an untouched grid pass); nothing arms on a
  move (`moveKey`/`followMonth` yield no range; only `press`/`pressKey`); the delivery test reuses
  `CommentPanelKeys.delivers` (a hidden popover window never claims); the release on `willClose` follows the comment
  panel's FIX LEG 3 precedent; the yield reads only text LIVING in the face's window — the measured
  `_NSPopoverWindow.firstResponder` quirk — so her Library field keeps its caret and its letters.
- **Suites run here (headless, no stage):** `swift test --filter 'Search|LibraryDay|TagListing|LibraryPaging'` →
  161 tests / 27 suites passed (matches the record's batch-2 count); the six touched/neighbour search suites → 43/5
  passed. The Mac gate claims (b1 23/4, b2 138/20, b3 228/42 and 29/29, the VX-408 and F1 revert legs) are the
  orchestrator's recorded gate evidence; this round could not re-run them (no `xcodebuild test` by brief) — read the
  pins instead: none found hollow beyond pin A, which the record already names hollow.

## THE ORCHESTRATOR'S DISPOSITIONS (same-model ladder — arbitrated against the rulings, 2026-11-06; A-819-L1)

- **F1 — FIX (the sidebar road only), PROVISIONAL + QUESTIONS.** R-819-4's letter ("the Library appears with the live answer as you type") binds the NEW door; a Timeline face with no answer sheet breaks it. The canonical precedent is the Cards rule ("a non-Notes scope picked inside Cards returns the view to List"): a mode that cannot show the answer yields. Build: on the SIDEBAR road, a Library standing in Timeline moves to List as the search lands; her own mode choice returns when the search ends is NOT built (the mode simply stays List — no hidden memory; flag PROVISIONAL). ⌘K's and the Library field's existing behavior UNTOUCHED — their line goes to QUESTIONS at the merge. Mounted pin red-on-old.
- **F2 — FIX.** Real silent-corruption defect in new code: `CarriedWordsCaret.toEnd` scopes to the Library field's OWN window, never a walk over `NSApp.windows`. Two-window pin red-on-old.
- **F3 — FIX; P-819-B3d AMENDED.** The tension is between the batch brief's "a NEW search starts at relevance" and the built P-819-B3d ("order and facets kept the way refining keeps them"). Arbitration: the sidebar field CLEARS after every handoff, so every question it starts is a fresh hunt from an empty field — a NEW search by R-819-2's own word. The sidebar road therefore resets the order to relevance and clears the facets when its words land (replacing a standing question included). ⌘K's road keeps its current behavior (its own line rides the F1 QUESTIONS entry). P-819-B3d's record entry is amended to say exactly this. Pin red-on-old.
- **F4 — FIX in the smallest honest form.** While ⌘K's palette sheet is presented, the sidebar field does not drive the question (keys pass to the palette; the field stays inert). If the smallest form grows beyond a few lines or touches the palette's own seam, STOP and report — it becomes a ticket instead.
- **F5 — FIX.** One case-folding truth: derive `SearchOrder.foldsCase` from `LibrarySort.keyCollation` (or the reverse) so the database and the Swift merge can never drift.
- **F6 — FIX if mechanical** (share one grouped-page builder); if the dedup grows beyond a mechanical extraction, ticket as Debt and leave the duplication with a one-line comment naming the twin.
- **F7 — FIX.** Delete the dead `LibrarySearchQuestion.scopeFilter`; update the two stale relevance-label comments.
- **F8 — CLOSEOUT ITEM, no code.** The five SurfaceContracts lines and the QUESTIONS entries (P-a…j, P-819-B3a…h as amended, the VX-90 B2 alternative, F1/F3's lines) land at the merge moment in the two-file shape; recorded on the closeout ledger row.

Fixes run in a FRESH session (the ladder's rule); round 2 re-reviews the fixes with a fresh reviewer.

## ROUND 1 FIXES (the fresh fix session, 2026-11-06 — A-819-L1 is the work order)

**NOT DONE BY THE FIX SESSION (first, by the contract):** no Mac test was RUN (no `xcodebuild test` — the staged gate is the
orchestrator's; every Mac pin below is PENDING it, its red-on-old included); no walk or capture; no QUESTIONS.md entry (F8
is the orchestrator's closeout item). The app and its tests only COMPILE (`build-for-testing`).

*Fix session: opus-implementer, seated 2026-11-06. Every claim is PENDING until its suite ran (the line says so when it
did). No revert is in flight.*

**Red-on-old shape for the Mac pins** (the batches' precedent): each behaviour pin lands ALONE first (that commit is a
red-on-old tree), then its fix in its own commit, product files only where possible, so the gate can revert exactly the
fix at head (`git show <fix> -- <files> | git apply -R`) — each road is checked with `git apply -R --check` here, and the
road for all four at once is named so ONE staged run can show every red.

| # | Fix (member) | Status |
|---|---|---|
| 0 | This record | DONE (this commit) |
| F7 | dead `LibrarySearchQuestion.scopeFilter` (VX-734) · the two stale relevance-label comments (VX-820) | DONE (`5da995e87` the dead method — no reader in app, tests or core; `f39b8307b` + `f86f6f3f7` the comments: `sortWidest`'s doc, the catalog's stable-widths comment, and a THIRD of the same class found beside them — `LibraryProbeSlot.sortSlot`'s doc in `LibraryInfoPanel.swift`; `f86f6f3f7` carries the third because the tool refused its edit in the first commit, whose message already named it). No behaviour; compile proof at END |
| F5 | one case-folding truth (VX-820, core) | DONE (`662d91845`) — `Queries.LibrarySort.foldsCase` is the one truth; `keyCollation` (the statements) and `SearchOrder.foldsCase` (the worn-day merge's Swift compare) both derive from it. Behaviour-preserving (the copies agreed — a NIT, no red-on-old owed); GUARD pin `SearchOrderTests.theSwiftFoldAndTheStatementsCollationAreOneTruth` (every sort × direction). RAN: `swift test --filter 'SearchOrderTests\|LibraryPagingTests'` → 16 tests / 2 suites passed |
| F2 | `CarriedWordsCaret` scoped to the Library field's own window — two-window pin alone, then the fix (VX-822) | BUILT — pin ALONE `24d34c440` (`SidebarSearchFieldShellTests.theHandoffsCaretLandsInItsOwnWindowNeverAnotherEditingTheSameWords` — two decoy windows editing "harbour", one built before the shell's window and one ordered in front after it, so a decoy precedes the shell's window whichever order the walk takes; non-vacuity premises: each decoy's field editor shows the words); fix `959d81d41` (`SidebarSearchField.swift` + `LibraryCatalogView.swift` ALONE): `toEnd(of:in:)` reads ONE window, the Library field's own, reported by `CarriedWordsCaret.Probe` (a zero-hit view the field wears) through an `Anchor` the catalog view keeps; `toEndSoon(of:near:)` re-reads it per try. **Expected:** RED at `24d34c440` and with the fix reverted at head (A's caret left select-all `(0,7)`, a decoy's caret moved — ≥ 2 issues); GREEN at head — PENDING the gate. Revert road (checked `git apply -R --check` CLEAN): `git show 959d81d41 -- App/Variorum/Variorum/Features/Library/SidebarSearchField.swift App/Variorum/Variorum/Features/Library/LibraryCatalogView.swift \| git apply -R`. `build-for-testing` → TEST BUILD SUCCEEDED (67 s), no new warnings in touched files |
| F1 | the sidebar road moves a Timeline Library to List as the search lands — pin alone, then the fix (VX-822) | IN-PROGRESS — the pin ALONE (this commit — the red-on-old tree): `SidebarSearchFieldShellTests.aSidebarSearchMovesATimelineLibraryToTheAnswer` (×2: the Library shown, or landed by the first keystroke); then F3's pin alone, a behaviour-preserving plumbing commit (the sidebar road's one landing door), then each fix as ONE line in that door so both revert roads stay clean |
| F3 | the sidebar road starts a new search: relevance, facets cleared — pin alone, then the fix; P-819-B3d amended (VX-822 / VX-820) | IN-PROGRESS — the pin ALONE `6c38ba2b4` (`SidebarSearchFieldShellTests.aSidebarSearchStartsNewAtRelevanceWithNoFacetCarriedOver`); the PLUMBING (this commit, behaviour-preserving — both pins still RED here): the rule says when a search STARTS (`SidebarSearchFieldRule.Act.start` — the field went from empty to typed; `.ask` refines), the door's `ask` carries it (`startsNewSearch`), and the sidebar road lands through ONE catalog door, `LibraryCatalogModel.takeSidebarQuestion(_:startingANewSearch:)` (sets the question only, here), RootView's `ask` = that door + `search()` + the Library adopted where not shown (the old two branches' exact effect). Justified test edits: `SidebarSearchFieldRuleTests` — the first word and the word after a handoff are `.start` (2 lines); `SidebarFieldHost`'s inert door takes two arguments. `build-for-testing` → TEST BUILD SUCCEEDED, no warnings in touched files. The F1 and F3 fixes next, each ONE line in that door |
| F4 | the smallest honest form: the field inert while ⌘K's palette is presented (VX-822) | NOT-STARTED |
| F6 | one grouped-page builder IF mechanical (VX-820, core) — else a Debt ticket for the orchestrator | NOT-STARTED |
| END | core suites + `build-for-testing` + the Mac suite list for the gate | NOT-STARTED |
