# VX-819 — ladder round 2 (cold review of the ROUND 1 FIXES)

Reviewer: `opus-reviewer` (fresh, zero implementation context), running `notes/REVIEW_PROMPT.md` verbatim in its
round-2 form over the round-1 fix commits named in `notes/plans/fixes/vx-819-ladder-round1.md` § ROUND 1 FIXES
(`24d34c440`/`959d81d41` F2 · `0a66343fd`/`e17a210f1` F1 · `6c38ba2b4`/`bf3b45531` F3 · `439d7f187` plumbing ·
`a0190647b`/`969ff499a` F4 · `662d91845` F5 · `3a328f451` F6 · `5da995e87`/`f39b8307b`/`f86f6f3f7` F7), anchored on
A-819-L1's dispositions. Branch `vx-819-search`, head `e8b1403da` at the round's start.

**Class check.** The fix diffs touch no `Sources/VariorumCore/Sync/`, no custody/keychain/`Protection/` line, no editor
seam (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, the read tier), no schema, no default's meaning. The
Opus-eligible class holds.

**STATUS: ROUND 2 COMPLETE (2026-11-06) — see the end of the clean bill.** Severity order: R2-1, R2-2, R2-3, R2-4 (all NIT).

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

## Clean bill — load-bearing things checked against A-819-L1 and found solid

- **No BLOCKER, no MAJOR; nothing new of that weight introduced.** Every changed file is inside the brief
  (`git diff --stat 82b94bd0e^ e8b1403da`: the Library feature's five files, RootView, the sidebar field and its
  tests, four core files and one core test, the two records); no `Sync/`, schema, custody, MCP, `Registry/` or editor
  seam line; `CommandPalette.swift` and `SearchPassagesTests.swift` untouched.
- **F2 (`959d81d41`) does what A-819-L1 ruled.** `toEnd(of:in:)` now reads ONE window — `Anchor.window`, the window of a
  zero-hit `ProbeView` the Library field wears as `.background` — and `toEndSoon` re-reads it per try, so a mount that
  lands the probe late still resolves inside the old 20 × 15 ms budget; no `NSApp.windows` walk remains (grep: the only
  caller is `LibraryCatalogView.takeCarriedWords`; the test host builds no caret). The probe takes no layout (a
  background sizes to its host), no hit (`hitTest` nil), and is no key-view stop (a plain `NSView` does not accept first
  responder), so VX-332's opening pick and the controls row's geometry are untouched. The sidebar's own editor stays
  refused by delegate. **Pin honest:** at `24d34c440` the walk meets a decoy first in either list order (one built
  before the shell's window, one ordered front after it) — its delegate is a plain `NSTextField`, so the old guard
  matches it, moves ITS caret and stops, leaving the shell's `(0,7)`; non-vacuity premises throw by name, so a harness
  miss reds both trees instead of greening the old one.
- **F1 (`e17a210f1`) and F3 (`bf3b45531`) do what A-819-L1 ruled, on the SIDEBAR road only.** The plumbing
  (`439d7f187`) is behaviour-preserving by trace: the old two branches (`searchLibrary` = query + `search()` + adopt;
  or query + `search()`) equal `takeSidebarQuestion` (query) + `search()` + adopt-where-not-shown. F1: `pickMode(.list)`
  on a `.timeline` mode (scope untouched — `scope(afterPicking: .list)` is the identity); on screen the view's
  `onChange(of: mode)` runs `modeChanged()` exactly as for her pick (returns false — Timeline already cleared the day);
  off screen `read()`'s own `holdNearFacts()` and the mount's `onAppear` cover what `modeChanged` would have held. F3:
  `resetFacet()` on `.start` only — exactly the cleared field's reset (order → relevance, archived / commits / book
  state off); the `when` day and the scope stay, as on that road, and the amended P-819-B3d says so (a book-state
  facet that moved the scope to Books leaves Books standing — the scope picker is not a facet; for the QUESTIONS line,
  not a defect). The first-word reading is the defensible one: a keyboard-free order/facet change mid-typing (a menu
  command, which the window's mouse-down monitor does not hear) is then KEPT as refining keeps it, where an
  every-keystroke reset would silently undo it. ⌘K's `searchLibrary` and the Library field's binding are byte-unchanged.
  **Pins honest:** F1 red on the old tree by the mode alone (R2-2 corrects the count); F3 red by three issues — at
  `6c38ba2b4` the first word is `.ask` and `read()` resets only on an empty question; the F1 pin also proves the field
  keeps the keyboard through the mode move (the view swap does not steal it).
- **F4 (`969ff499a`) closes the round-1 mechanism in the smallest honest form.** `inert` = `paletteOpen`, the ONE state
  behind the palette sheet (`RootView.swift:56/385/580` — no other writer); as it turns true the field applies its own
  `leave()` law (the keyboard did leave — to the sheet — though AppKit reports no end of editing because the parent
  window's first responder never changes), so back in the window esc and ⏎ act on an empty field and the palette's
  question is never ended or swapped. The guard sits after the rule's mutation; the only acts it can meet while the
  sheet is key are `.none` / the leave's own `.handOff(false)` (keys go to the sheet; the click monitor ignores the
  sheet's window), so the rule and the Library cannot diverge on a reachable road. Not generalized to other sheets
  (correct: no other road rewrites `catalog.query` — grep: `searchLibrary` and the door's `end` are the only writers).
  The stated consequence (palette dismissed without its road → field empty) is the `leave()` doc's own law; it needs
  its QUESTIONS line (R2-3). **Pin honest:** red on the old tree by three issues.
- **F5 (`662d91845`).** `LibrarySort.foldsCase` is the one truth; `keyCollation` (the catalog's keyset AND the answer
  sheet's statements — `LibraryPaging.swift:211`, `SearchComposer.swift:585`) and `SearchOrder.foldsCase` (the worn
  merge) both derive from it. Behaviour-preserving.
- **F6 (`3a328f451`) is mechanical — verified by reading the two texts side by side against `3a328f451^`:**
  `groupPage`'s template with `keyed: false` and relevance's arguments reproduces the old relevance statement byte for
  byte (the `g_lines` line, the `ranked` select's trailing comma, the blank keyset line, the argument order hits →
  cursor → limit → perGroup → match); with `keyed: true` it reproduces the old home statement. The Swift fold and
  assembly are the two old loops verbatim over one struct; `key` is nil only for relevance groups and worn
  placeholders, never read there. The relevance cursor still requires `best` (`let best = last.best`); the home cursor's
  `last.best ?? 0` is unchanged.
- **F7.** `scopeFilter` has no reader anywhere (grep: app, tests, core); the three comments name the order door.
- **Revert roads.** All four Mac fix roads (`969ff499a`, `bf3b45531`, `e17a210f1`, `959d81d41` with their named files)
  re-checked here: `git apply -R --check` CLEAN at head.
- **Suites run here (headless, no stage):** `swift test --filter 'Search|LibraryDay|TagListing|LibraryPaging'` → **162
  tests / 27 suites passed** at `e8b1403da` (161 + F5's guard — matches the fix record). The Mac pins (F1 ×2, F2, F3,
  F4) and their red-on-old remain PENDING the orchestrator's staged gate; this round read them (no `xcodebuild test`
  by brief) and found none hollow.

**STATUS: ROUND 2 COMPLETE (2026-11-06).** No BLOCKER, no MAJOR — no round 3 is earned. Four NITs (R2-1 stale docs,
R2-2 the F1 row's expected red count, R2-3 F4's PROVISIONAL missing from the F8 closeout list, R2-4 a pre-existing third
spelling of the group facts outside F6's scope).


## THE ORCHESTRATOR'S DISPOSITIONS (round 2 — final round; line-by-line check is the diff itself; A-819-L2)

- **R2-1 — FIXED BY THE ORCHESTRATOR** (doc-only, the small-adjudication lane: five comment corrections fully specified by the finding, no behavior, no design choice): the three "⌘K's road" docs now name `takeSidebarQuestion` and the sidebar road's own resets; `LibraryCatalogModel`'s wrong `search()`-reads-the-mode clause dropped; the F5 guard doc now says drift fails, agreement passes.
- **R2-2 — RECORD CORRECTED** in the round-1 file: F1's expected red is ≥1 issue per argument (the mode), not 2.
- **R2-3 — ACCEPTED**: F4's provisional joins the closeout QUESTIONS list (the F8 entry amended in the round-1 file).
- **R2-4 — DEBT TICKET** (pre-existing, outside F6's scope): `SearchComposer.wornGroupFacts` restates the group-facts columns beside `groupPage`'s template — minted on the board, not fixed in this run.

No round 3 (no new BLOCKER/MAJOR — the cap's condition unmet). THE LADDER CLOSES: round 1 = 0/0/3/5 all dispositioned and fixed; round 2 = 0/0/0/4 dispositioned above.
