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

### The implementer's verdicts (2026-10-05 ~18:15 — ALL SEVEN AGREED, none disputed; no edits made; context ~390k, self-judged not degraded, each cited site re-read before answering)

- **MAJOR-1 AGREE — "this regression is mine"** (the pre-fix tree had no row gate). Mechanism
  independently confirmed leg by leg (the `@Environment(\.colorScheme)` input at :118; the
  captured old `self` in the row closure; voice/palette healing via observed
  `themeStore.settings` — "I flipped voice, never appearance"). The scheme confirmed as the
  ONLY untracked channel (the parent's other non-observed state never reaches row rendering;
  every other row input is tracked by the rows themselves). On the fix, a refinement offered
  for the reviewer's call: `VoiceTokens` is already `Equatable`
  (`Shared/Theme/VoiceTokens.swift:32`) — passing `tokens` and comparing THEM covers every
  token input in one clause, including any added later, at one cheap comparison per row per
  parent render; the reviewer's scheme-field shape also correct. Pin agreed red-on-this-tree.
- **MINOR-1 AGREE**, with a sharper guard: gate on the IDS, not the pages —
  `!replacing && chipIDs.isEmpty && cardIDs.isEmpty` (also covers wanted pages that yield
  nothing, e.g. a List-mode page of all-titled notes). The replacing path stays unguarded (its
  empty assignment clears card words on a mode switch; `eachModeReadsWhatItDraws` pins it).
- **NIT-1 AGREE** (the pre-move text said B3; the move turned it into B1 — one word).
- **NIT-2 AGREE (record-only)**, with the scoping fact for the sentence: the catalog
  re-searches on Library appear and after its own row acts, so the miss window is only while
  the Library stays on screen; an already-listed edited note keeps its old position; same
  one-shot class as the shipped 40-row listing.
- **NIT-3 AGREE (record-only, speculative)** — the generation guard doesn't help when both
  reads share a generation; the shipped tree had the same task pair; no deterministic pin.
- **NIT-4 AGREE (cleanliness)**, with the caveat for whoever prunes: prune at a new question's
  landing to the newly listed ids ONLY, and never drop/replace the slice of a still-listed id
  (a live row whose body is skipped would keep an orphaned slice and go stale).
- **NIT-5 AGREE (record-only, beside P-17y-B1-j1 / #187(a))**, naming the alternative for the
  sentence: custom accessibility actions on every row (not AppKit controls — scroll-free,
  VO-reachable without selection).

### The reviewer's final calls + fixes (the reviewer's own session, 2026-10-05; every call final)

- **MAJOR-1 — CONFIRMED, FIXED.** Pin first, the standing discipline:
  `standingRowsFollowAnAppearanceFlip` (`LibraryInfiniteScrollTests`) mounts the catalog, settles
  a titled/untagged/bookless fixture to a steady state (nothing but the appearance changes between
  the two counts), flips `window.appearance` aqua → darkAqua and counts standing-row bodies — **RED
  on the pre-fix tree exactly as traced ("an appearance flip re-drew 0 standing rows"), committed
  red at 671f2e5e.** The fix (5d26208d): `LibraryNoteRowHost` compares its colour SCHEME beside its
  hit, the scheme read by `LibraryPagedNotes`' own `@Environment(\.colorScheme)` — the live
  hierarchy, never a captured snapshot. **The implementer's `VoiceTokens`-equality alternative was
  tried FIRST and refused by the compiler:** `VoiceTokens`' `Equatable` conformance is
  MainActor-isolated under the app target's default isolation, and the host's `==` must stay
  nonisolated for `.equatable()` ("main actor-isolated conformance of 'VoiceTokens' to 'Equatable'
  cannot be used in nonisolated context") — widening into `Shared/Theme` to de-isolate it was not
  this ladder's call, so the reviewer's scheme-field shape landed, with the future-input contract
  written at the host's doc (any future token input that is not an observable read inside the row's
  body must join the comparison, or it inherits this class). Pin GREEN; the landing pin
  (`aPageLandingReDrawsNoRowAlreadyBuilt`) green beside it — a page landing still skips every
  standing row (the scheme is constant across a landing). **SYNTHETIC REVERT verified:** the `==`
  clause alone reverted → the pin red again ("re-drew 0 standing rows") → restored → suite 5/5
  green.
- **MINOR-1 — CONFIRMED, FIXED (a6bf9b68)** with the implementer's sharper guard, on the IDS:
  `if !replacing, chipIDs.isEmpty, cardIDs.isEmpty { return }` after the pages are marked (a wanted
  page that yields no id — a List page of all-titled notes — now also dispatches nothing); the
  REPLACING path stays unguarded (its empty assignment is the mode switch's clearing;
  `eachModeReadsWhatItDraws` green). Behaviour-identical by construction — no pin owed, said
  honestly (any observable-behaviour pin would be green on both sides); the paging suites are the
  guard.
- **NIT-1 — FIXED (a6bf9b68):** the moved books-section comment's one word back to B3 (item (l) is
  B3's).
- **NIT-2 — record-only as ruled, RECORDED:** the MISS half now stands beside the never-twice half
  at the landing dedupe comment (a6bf9b68) and in the B1 RECORD's listing bullet (this commit),
  carrying the implementer's scoping facts (the catalog re-asks on Library appear and after every
  row act; an already-listed note keeps its old position; the shipped 40-row one-shot class).
- **NIT-3 — record-only, SPECULATIVE as labelled; no code change.** This round record is its
  record; the shipped tree carried the same task pair and no deterministic red form exists.
- **NIT-4 — CONFIRMED as a bounded fix (a6bf9b68):** a NEW question prunes `rowSlices` to its own
  listing, so the dictionary and the per-write loops stay ∝ the listing, never ∝ every note ever
  listed this session. The implementer's caveat honoured by construction: a still-listed id KEEPS
  its slice OBJECT (`filter` keeps instances — a live row whose body the Equatable host skips holds
  its slice, and a replaced one would go stale under it); `refresh` never prunes. Cleanliness; the
  paging suites are the guard.
- **NIT-5 — record-only as ruled, RECORDED:** the sentence beside P-17y-B1-j1 in the B1 RECORD and
  the rider in QUESTIONS #187(a) (this commit), naming the implementer's alternative for her call —
  custom accessibility actions on every row, scroll-free, VO-reachable without selecting.
- **END OF THE FIX PASS, suites green in the reviewer's own DerivedData (`17y-review6`):** the six
  Mac suites — `LibraryInfiniteScrollTests` (6 cases, the new pin among them) ·
  `LibraryPagingModelTests` · `NoteIndexColumnScrollCostTests` · `NoteTagsRowHoverTests` ·
  `LibraryDayFilterTests` · `LibraryCardNameTests` — **46 tests / 6 suites green**, plus core
  `LibraryPagingTests` 8/8. Commits: 671f2e5e (the red pin) · 5d26208d (MAJOR-1's fix + revert
  round) · a6bf9b68 (MINOR-1 + NIT-1/2/4) · this one (the records). The implementer's sanity pass
  over this diff closes the ladder per the standing flow.

### THE SANITY PASS (the implementer, 2026-10-05 ~19:10): ALL SOUND — THE LADDER CLOSES

Verdicts on the reviewer's diff 7f75ac8c..d7951743 (the orchestrator's two notes-only commits
excluded; no edits made; tree clean at d7951743): **all four fixes SOUND, nothing returns to
the reviewer.** The implementer re-ran 58 tests / 8 suites green in its own DerivedData on the
quiet machine (the appearance pin, both landing legs and `eachModeReadsWhatItDraws` included).
Notable verifications beyond the pins: the re-run rows get the NEW ink (LibraryCatalogView
reads the scheme for its `tokens`, so it re-runs in the same top-down pass and the row closure
the hosts call is the new one — checked deliberately, because the pin counts row bodies and
would also pass on a stale-tokens re-run); MINOR-1's guard is behaviour-identical by
construction (the old empty read merged nothing) with page marking unchanged; NIT-4's caveat
holds by construction (`Dictionary.filter` keeps slice OBJECTS for still-listed rows; a
returning id gets a fresh row identity and slice; refresh never prunes). The VoiceTokens
refusal accepted (MainActor-isolated `Equatable` vs the nonisolated `==` that `.equatable()`
needs). ONE OPTIONAL non-blocking note, recorded for next touch: the appearance pin mounts the
List only — Cards shares `LibraryPagedNotes`, so a cards arm would be belt-and-braces.

**THE B1 LADDER CLOSES: round 1 (0 BLOCKER · 1 MAJOR · 1 MINOR · 5 NIT) → the exchange (all
seven agreed, none disputed) → the reviewer's final calls + fixes (pin red-on-old, synthetic
revert verified, suites green) → the sanity pass ALL SOUND (the B3-precedent close; no round 2
owed under the cross-model flow). What remains is HERS: the live scroll walk, the drag
spot-check, and her word.**
