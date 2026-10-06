# 17y B1 — cold-review ladder ROUND 1 (fresh `fable-reviewer`, 2026-10-05; diff `c9c4d75d..6c8e4f02`, the record-only commit 4144e7ad excluded)

**Verdict: 0 BLOCKER · 1 MAJOR · 1 MINOR · 5 NIT.** The reviewer executed REVIEW_PROMPT.md
verbatim with zero framing; preflight in its own context (canon, the brief, the (j)/(k) cells,
the B1 RECORD, QUESTIONS #187, the KnownIssues rows, TEXTKIT2_NOTES §2–§3); suites re-run in
its own scratch DerivedData (`17y-review6`): core `LibraryPagingTests` 8/8; Mac
`LibraryPagingModelTests` + `LibraryInfiniteScrollTests` + `NoteIndexColumnScrollCostTests` +
`NoteTagsRowHoverTests` + `LibraryDayFilterTests` + `LibraryCardNameTests` — 45 tests / 6
suites green. CROSS-MODEL FLOW (Fable reviews, Opus implements): the findings below went to
the B1 implementer VERBATIM at this commit; its agree/dispute returns to the reviewer, which
makes the final call and implements its confirmed fixes ITSELF; suites green + one implementer
sanity pass close the ladder (round 2 only if the final-call diff warrants a fresh eye per the
standing ladder rules).

## THE FINDINGS (the reviewer's text, verbatim)

- **[MAJOR-1]** · `App/Variorum/Variorum/Features/Library/LibraryBooksRegion.swift:99–110`
  (`LibraryNoteRowHost.==` on `hit` alone; the `.equatable()` hosts at :81–89) with
  `LibraryCatalogView.swift:161–163` (tokens derived from `@Environment` colorScheme) · **An
  appearance (light↔dark) flip leaves every standing Library note row — List AND Cards —
  rendered in the OLD scheme's token colors while all non-gated chrome (headers, book rows,
  section labels, backgrounds) switches: dark room with light-ink rows, i.e. illegible rows on
  the batch's own launch-blocker surface.** Mechanism, traced and EMPIRICALLY VERIFIED: the
  appearance choice is NSApp.appearance / system (AppearanceChoice.swift — local defaults, NOT
  in ThemeStore's observable `settings`), so a flip reaches rows only through the `colorScheme`
  environment; LibraryCatalogView re-evaluates and recomputes scheme-keyed static tokens, but
  the new `LibraryNoteRowHost` values compare equal on `hit` alone, so `.equatable()` skips
  every standing row's body and the rows keep the captured old-scheme `tokens.ink`/`wash`/fonts.
  Voice/palette changes DO heal rows (the row body reads ThemeStore observable state — which is
  exactly why the implementer's two-voice walk could not catch this); the scheme is the one
  untracked channel. Reproduced standalone (scratchpad `eqenv`): parent body re-ran with
  DARK-INK while both equatable hosts' bodies ran 0 times and kept LIGHT-INK — confirmed with a
  parent-body control. Reachable by the Settings appearance row with a Library window open and
  by follow-system day/night; healing is accidental (List rows heal on any selection click via
  the `selectedPosts` read; Cards rows only on a slice change, mode switch, or lazy-column
  release — a fresh `search()` with unchanged hits does NOT heal them). A regression class
  introduced by this batch (pre-fix rows were not equality-gated). PIN (red on this tree): the
  LibraryInfiniteScrollTests mount, rows built, `window.appearance =
  NSAppearance(named: .darkAqua)`, pump, assert `LibraryPagedNotesProbe.rowBodies` grew
  (standing rows re-evaluated). FIX: include the scheme in the host's identity/equality — pass
  `scheme` (or a scheme-stamped token key) into `LibraryNoteRowHost` and compare it in `==`
  (one field + one clause; page-landing skip behavior unchanged since the scheme is constant
  across a landing).
- **[MINOR-1]** · `LibraryCatalogPaging.swift:149–161` (windowMaybeMoved's per-turn Task) +
  `LibraryCatalogModel.swift:721–749` (loadNearExtras) · **A no-op async
  `session.database.read` runs at scroll rate.** Every turn in which any row appears/disappears
  queues the coalesced window Task, which always awaits `loadNearExtras(replacing: false)`;
  when `chipWanted` and `cardWanted` are both empty (the common case — the window moves only at
  page boundaries), the function still dispatches a reader-pool read whose closure does nothing
  and returns ([:], [:]). During a continuous fling that is one pool acquisition per frame
  serving nothing — P1 hygiene on the batch's own P1 surface, off-main and measured-small (the
  8.8 ms 0-row frames absorb it) but free to remove. FIX: early-return in the merge path when
  both wanted sets are empty (the replacing path must still run — its empty assignment is
  meaningful). No pin owed (efficiency cleanliness, no wrong state).
- **[NIT-1]** · `LibraryCatalogView.swift:717` · The moved books-section comment says "17y B1
  item (l)" — item (l) (book-row context menus) is B3's; the pre-move text said B3. One-word
  comment drift from the mechanical move.
- **[NIT-2]** · `LibraryCatalogPaging.swift:262–263` (the landing dedupe comment) · The record
  and comment document only the duplicate half of mid-listing edits ("listed once, never
  twice"); the MISS half is undocumented: under edited-DESC, a note edited (e.g. landed by
  sync) after page 1 was read moves ABOVE the cursor and no later page can reach it — absent
  from the listing until the next question/act. Same one-shot-listing staleness class as the
  shipped 40-row catalog (not a regression); worth one sentence in the B1 RECORD beside the
  dedupe note. Record-only.
- **[NIT-3, SPECULATIVE]** · `LibraryCatalogModel.swift:709–712` (refreshNoteCards) vs read()'s
  own loadNearExtras · At listing birth / mode switch the `.task(id: mode)` refreshNoteCards
  and the search's extras read race on the reader pool; if the trivial empty read resumed LAST
  (requires its no-work read to complete after two heavier reads — effectively unreachable
  under FIFO submission) it would clobber `noteCards` with [:] while `cardPages` stays marked,
  blanking card words until the next question. Pre-existing class (the shipped tree had the
  same task pair); no deterministic red pin exists — labeled honestly, record-only.
- **[NIT-4]** · `LibraryCatalogModel.swift:252, 268–287, 790–796` · `rowSlices` is never
  pruned: it grows monotonically across questions (bounded by corpus), and every
  whole-dictionary `postTags`/`noteCards` assignment loops over every slice ever built — ∝
  notes-ever-listed per act, not per scroll. Cheap per entry and measured-fine at 822; a
  prune-to-listed-ids at each new question would cap it. Cleanliness only.
- **[NIT-5]** · `NoteIndexColumn.swift:561, 597` (accessibilityHidden on the resting hint) ·
  Resting rows expose no ↑ ↓ ⋯ to accessibility — only the selected row (always live) and the
  hovered-at-rest row do. Defensible under the wake design (a VO user selects the row and its
  controls become real) and it rides P-17y-B1-j1's provisional; one sentence beside that
  PROVISIONAL would make it a decided edge rather than an accident. Record-only.

## THE CLEAN BILL (verbatim — what was checked and found solid)

- **(k) keyset read** (`Sources/VariorumCore/Queries/LibraryPaging.swift`): parity pinned
  against `searchCatalog`'s uncapped note arm for every sort × both directions × page sizes
  1/7/40/200 over a corpus containing byte-equal AND NOCASE-equal-byte-different title ties
  (the tie construction verified: "moss 6"/"Moss 6" exist) plus untouched/entry-dated/untitled
  notes; the cursor-collation unity is its own pin (`expression == keyExpression +
  keyCollation`); the two-arm lastTouched UNION partitions cleanly on `last_touched_at IS NULL`
  and both arms' keys equal the COALESCE merge key, so per-arm row-value cursors are globally
  correct; probe-row last-page exactness pinned; never OFFSET, never a raised cap, no new
  index, `INDEXED BY` names only AppSpec §7's existing `idx_container_touched` (prepare-time
  failure if it ever renames — acceptable, it is schema contract); EXPLAIN seek pin + VM-step
  flatness in depth (all sorts) and in corpus (edited) — all 8 re-run green by the reviewer.
  The WHERE/mapping is byte-identical to `catalogPostsSQL`'s (archived/version exclusion via
  `archived_at IS NULL` included).
- **searchCatalog factoring**: `catalogBooks`/`catalogBlocks`/`catalogLikeEscaped` verified
  byte-for-byte against the removed inline bodies; palette/phone callers behaviorally
  unchanged; the Library's empty-query block arm correctly returns [] via the internal guard.
- **The model's paging discipline**: appended pages never re-read or reorder standing rows
  (pinned, incl. order equality); superseded pages never land (`searchGeneration` +
  `listedGeneration`, both pinned — F-B1-7's guard verified); growth 80→double→1,280 pinned;
  rest-landing + 40-row land-now margin pinned; the rest-watch task provably terminates and
  `listMoving` cannot wedge (rowsMoved always arms the watch); acts re-read in place (pinned)
  and every act door in the view routes refresh() not search() (rename, archive, wing moves,
  tag acts, notes-deleted).
- **P1 bounds**: the held ownership observation covers near-window ids only and its tracked
  region is blind to keystrokes (core region pin re-run green); extras (chips/cards) load per
  near page, marked-before-read with error unwind; the catalog body is insulated from page
  landings via `hasNoteRows` (didSet logic verified) and the landing is one update per
  dictionary.
- **The rider**: `LibraryBooksRegion.capsBooks` pure rule pinned (All-only,
  something-below-only, measured pitch); the mounted forty-books pin proves a note row on
  screen; Books scope and few-books keep one list.
- **(j)**: the trace is recorded before any fix and the pre-fix source confirms both M1 halves
  exactly (old `NoteIndexColumn.swift` lines 253/300/347 call `rowsByID` from row builders; old
  `rowControls` built live controls unconditionally); the five pins green in the reviewer's own
  DerivedData; the wake rule is pure and pinned; the footprint oracle holds hint == live size
  to 0.5 pt; the selected-row guard prevents overshoot; the synthetic revert round (two bites,
  restored, `git diff --quiet`) is the documented red-on-old verification. The diff touches NO
  TK2 surface (`NoteIndexColumn` is SwiftUI; pane, EditorTextView, BlockRangeIndex,
  PaneSurface, PaneTextAuthority untouched — verified against the file list), and the pins
  correctly honor TEXTKIT2 §3's harness fact (unbound scroll position staged through
  NSClipView).
- **The hover-loop fix** (`NoteTagChips`): one frame + one hit shape for both states, pinned;
  the non-reveal (List column) branch byte-equivalent.
- **Fixture + scripts**: DEBUG + env double gate, ops-API only on a quiet Operations,
  marker-guarded once; stage/restore refuse while ANY Variorum instance runs (never kill),
  dev-container-only paths, cmp-verified both ways, WAL removed before restore.
- **Process**: fences EMPTY over the whole range (zero Sync/, Persistence, Server, Shared,
  mobile — verified by diff); no attribution trailer on any of the 23 commits; the three
  `LibraryDayFilterTests` flips are justified edits of the behavior the item itself changed,
  each labeled; KnownIssues — four new rows all owned (12; the List row gated on her #187(i)),
  row 22's Library leg BUILT with the close honestly at her walk; QUESTIONS #187 (a)–(h) match
  the built edges and (i) is a real question; the NOT-DONE list is honest and complete (her
  walk, Release measurement, M2, book-Index menu, status-item redraw, List per-new-row cost).

## THE EXCHANGE (cross-model; appended as it lands)

- Findings sent to the B1 implementer VERBATIM at this commit; agree/dispute pending.
