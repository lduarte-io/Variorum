# VX-1082 — ladder round 1 (cold review, Fable, 2026-11-25)

**Scope reviewed:** the whole run diff, `git diff main...HEAD` on `vx-1082-nov-24-fixes` at `182e36788`
(75 commits; 50 files, +5,040/−158). Read in full: the run record (`vx-1082-nov-24-fixes.md`, all 411
lines), every changed product file, the editor-seam class line by line (`WordDelete.swift`,
`EditorTextView.swift`, `EditorViewModel.swift`, `PaneSurface.swift`, plus the untouched
`BlockRangeIndex.interEntrySeparatorPair` and `OrdinaryInputEdit.apply` they lean on), the core diff
(`SearchComposer.swift`, `SearchQueries.swift`), both new core test suites (run green by this reviewer:
5 tests in 2 suites), the TEXTKIT2_NOTES §3 addition, the relevant SurfaceContracts bullets (the
Library search bullet, the controls-row law, the badge family, the Delete/Trash bullets, the Open-list
bullet), and the key pins' harnesses (WordDeleteKeyTests' real-key rig, WordDeleteRuleTests' property,
TrashListingRestartTests' gate, NoteDeleteUndoTests' toast press, BookMastheadTitleLineRuleTests,
SharedMarkDoorTests, the rewritten CommandDeleteLineTests and LibrarySearchFaceTests edits).

**Verdict: no BLOCKER, no MAJOR, no MINOR. Three NITs.** The run's eleven members are built to their
rulings, every bug-class fix carries a red-on-old pin whose mechanism I re-traced independently in the
product code (not from the transcripts), and the judgment calls are recorded with reversible options.

---

## Findings

- **NIT · App/Variorum/Variorum/Features/BookView/BookView.swift:779 ·** the VX-1014 masthead
  title-line oracle attaches `.onGeometryChange` unconditionally and gates only the ACTION body in
  `#if DEBUG`, so a Release build carries a live geometry observation with an empty action. ·
  Evidence: the hunk at 779–783; the same run's ShelfView probes (hintBar, VX-409) gate the WHOLE
  modifier. Mitigation: BookView's own pre-existing navigator probe (line 1197,
  `recordNavigator`) uses the identical half-gated shape, so this follows the file's local precedent —
  cost is one observation on one view. · Fix (optional, one line): lift the `#if DEBUG` around the
  modifier as ShelfView does; or leave as the file's precedent and sweep all three together someday.
  No pin (no behavior).

- **NIT · App/Variorum/Variorum/Core/Views/SearchAnswerFaces.swift:277 (CatalogChapterLine) +
  Features/Library/LibraryCatalogView.swift:1670 (CatalogBookLine) ·** the chapter row's title-column
  alignment depends on its hidden glyph staying byte-identical to the book line's
  (`Image(systemName: "book")` + `tokens.body`), spelled as a literal in two files. If the book row's
  glyph ever changes, chapter rows drift silently off the titles' column. · Evidence: both literals
  read today; nothing couples them. · Fix: one shared named constant (or the book line exposing its
  glyph) read by both. No pin owed (clarity).

- **NIT · App/Variorum/Variorum/Features/Library/NoteDeletion.swift:201 ·**
  `let versions = single ? try notes.reduce(0) { … } : 0` sums versions over `notes` as if plural,
  but `single` guarantees the one-note case — a later reader may take the sum as meaningful on the
  multi-note road (it is always 0 there by the ternary). · Fix: read the one note's count directly,
  e.g. `notes.first.map { try Queries.noteVersionIDs(db, of: $0).count } ?? 0` under the `single`
  guard. No pin owed (clarity; behavior identical).

No SPECULATIVE findings are carried: every suspicion I raised while reading (a double-fire road for
the single-note auto-confirm across dialog hosts; a dropped archived fact in the chapter-fallback
dedup; a quote/answer predicate mismatch for `#/`-shaped tokens; a stale `searchState.books`
emptiness consumer; `interEntrySeparatorPair` answering for the open tail's separator) was traced to
no mechanism — details under the clean bill.

---

## Clean bill (checked and found solid)

**The editor seam (batch E — read whole, the Fable-mandatory class).**
- `WordDelete.outcome` is correct at every edge I walked: document start/end (the first guard makes
  both `.system`), CRLF and U+2028/U+2029 terminators via `getLineStart` (the break taken whole,
  pinned), the at-line-start/at-line-end arms computing the break from the PREVIOUS/own line's
  `contentsEnd`, mid-line clamps taking exactly `line.start..caret` (backward) / `caret..contentsEnd`
  (forward), and the `.system` arm whenever the system's own boundary stays on the line — so the
  ordinary case is byte-for-byte AppKit's (the GUARD pins assert equality against a bare NSTextView).
- The guards fall to the system exactly where they should: a selection, several selections, marked
  text (IME composition), a non-editable surface, `NSNotFound`.
- The seam predicate is the carves' own geometry: `interEntrySeparatorPair` answers only a deletion
  of exactly one character sitting between two ENTRIES (verified in `BlockRangeIndex.swift:280` —
  the loop runs separators between entries only, so the open tail's separator answers nil and ⌥⌫
  there is the same ordinary edit ⌫ makes, routed through the closeTail verdict). The key and the
  seam carves can never disagree about where a seam is, by construction.
- Both surfaces override both selectors; every `EditorTextView` host reaches
  `EditorViewModel.attach` (both factories → `EditorView.swift:464/596`), so `onLineBreakIsBlockSeam`
  is never unset on a mounted editor; `PaneTextView` correctly answers no-seam (one take's buffer).
- The clamped edit is ONE ordinary edit through `OrdinaryInputEdit.apply` — the gate, the arming,
  the undo registration, churn, a seal's and a locked take's refusals all see an ordinary deletion;
  no TK1 API, no attribute written, cost ∝ the caret's line plus the system's own `nextWord` walk
  (the `view.string as NSString` read is MarkdownActs' established precedent).
- The rewritten 13u4 E2 characterizations are honest ruled changes (red-on-old, the bare-AppKit
  trace pins untouched); P-1076-1's silent `.nothing` at a seam matches the adjudicated option (a)
  with (b)/(c) held for her; the TEXTKIT2_NOTES §3 entry matches the shipped rule and names the
  pass-through posture if a later macOS stops crossing line breaks. I4 holds (a ⇧⏎ line is any
  in-block line; the block seam is never taken by a text chord).

**Core (`Sources/VariorumCore`).** `foldsToNothing` is a pure negation of the one token table;
`searchChapterHits` is json_each-driven (∝ ids, P1), re-checks section and reading liveness at query
time, fences `kind='book'` (a gathering's stray row structurally unanswered), preserves ask order.
No `Sync/`, schema, custody or MCP-wire line anywhere in the diff; the MCP `search` tool's read path
is untouched (verified: no `Sources/VariorumMCP` hunk; `searchPassages` unchanged).

**VX-1074 (both halves).** The Books section assembly keeps each-once for books, chapter rows at
their own rank, and the fallback (dead section / gathering row) reproduces today's book-row road with
the archived fact carried exactly where it changes anything (I traced the one dedup path where the
fallback's archived insert is skipped — the book is already placed — and it has no reachable
mechanism: any reading that makes the chapter passage archived makes the book's own hits archived).
The sheet, place memory (VX-823) and the empty-sentence check all moved to `bookRows`; no stale
`books`-emptiness consumer remains (grepped product-wide). The landing is the existing pinned
chapter road (`ShellRouter.pendingBookChapter` → `takeChapterRequest`/`landChapter`), and the band's
books count stays the composer's distinct-books read, consistent with what the section names in
every divergence case I could construct. The book's own 🔍 narrows the one composer under the book
scope by `.docKind(.chapter)` (the book's own name structurally excluded), and `bandCounts` counts
exactly what the sheet lists — the traced "nothing in this book matches" dishonesty is closed.
⌘K correctly ticketed (VX-1089, D-1082-S2).

**VX-1069.** The quote's beside-a-tag guard is the parser's own `isTag` (a lone `#` or `#/` never
triggers the drop), each remaining word dropped by the index's own `foldsToNothing`; the tagless
field is byte-identical (R-980-5 kept — pinned by the rewritten first line AND the kept-letter second
line of `LibrarySearchFaceTests`); the book band reads the same one rule; the DEBUG echo oracle
records the drawn value.

**VX-1014.** The Layout decides at whole points from measured subviews — never `ViewThatFits` (the
controls-row law honored); the rule's clamps (field floor → name whole → field ceiling → never past
the room → never under the bare 🔍) verified in the pure suite including a sweep property; at rest
the door takes exactly its bare width (the HStack's own look). The re-oracled pins read the title
line's OWN laid-out width against the room the column's other children leave it — the VX-1091 1-pt
Terminal tab confound correctly isolated, measured, and ticketed rather than absorbed; D-1082-S4's
two non-discriminating Terminal cases kept as guards, not swapped — the honest call under the
hallucination guard.

**VX-1077.** The count-keyed confirm lives in the ONE host modifier; all seven doors inherit it, and
each host holds its own `pendingDelete` state (every attachment grepped — no shared binding, so no
double-fire road for the `.onChange` auto-confirm). The offer kind is the only status kind that
toasts under every receipt style (verified in `StatusCenter`: `removal` is receipt-class on the Mac
and its undo door draws on the phone only, so `offer` is the one vehicle that satisfies her "toast
appearing instead" ruling; the phone's own delete line correctly untouched). Undo is
`restoreContainer` — the Trash's Put back, exact-stamp versions riding — with the race refusals the
deletion story's own words; no structural-undo entry (her ruling; the standing pin kept). The
versions count is read in the act's own pre-tombstone read.

**VX-1016.** `questionChanged()` is the one home (answered flag down, question token, restart token)
for words, kind filter and order; the wing rides the answer (`answers(_:in:)` and the computed
`trashListingLoaded` reading the app's current wing), closing both the change-beat render and the
in-flight stale answer, for the wing switch the model never hears included. Confirmed REAL by the
window's revert (all 5 pins red, 13 issues); the two extra tail reds are correctly recorded as a
prediction error, not pin adjustment.

**VX-1070.** The cards band marks itself with the quick entry's own mechanism (`statusToastKeepClear`),
applied at the Bookcase's composition — no Castle face touched; `keepClearTops` is pure and filters
zero-height bands (the retired offer card's empty container asks nothing); the preference applies in
Release too (verified the non-DEBUG branch); the Library traced card-free.

**VX-409.** The yield reads the line's own predicate (`status.lineItem` — receipts and standing
asks, exactly what the line draws); the hint returns in layout at once and fades in after
`QuietReceiptLine.fade` (the one number, now named, read by both sides); removal is `.identity` so
the arriving line never crosses standing words; P-8 holds (the hint keeps `lineLimit(1).fixedSize()`);
the hairline's drop is sound (nothing follows a speaking line on that bar now). The five same-shape
hosts (counts/page lines beside the animating line) are correctly HELD as an observation with a
ticket draft — information is not a hint, and hiding it is a product call; noting for the record
that the one-place class fix (clip the line's words to its frame, or animate opacity only, inside
`QuietReceiptLine`) would retire the mechanism on all six hosts and make the asymmetric-transition
choreography unnecessary, if she ever wants the class closed (D-1082-D1 already names it).

**VX-1075.** The glyph lays out exactly as before (9 pt, same slot — no row or prose moves) with the
hit target grown outward (VX-291's shape, inside every host's spacing); the hover moves to the
innermost interactive control (the mark's own button — the traced rule; its last link is correctly
walk-owed); the archived read rides the same observation and re-fires when those readings change
(∝ the facts' own answer, P1); the `.shared` payload change's test edits are justified and marked;
`ownership_badges` off still draws nothing. The `books.vertical` collision was honestly flagged and
adjudicated KEEP (D-1082-B2) with a one-constant swap held for her.

**VX-1034 / VX-1027.** Each draws from one pure rule (`rowDoors`/`addOption`;
`dailyJournalRow(for:)` on the one table + one renderer, so the Bookcase face and the derived
elsewhere face cannot drift); the gathering's diverge removal is P-2 applied to an operation that
refuses by spec (`divergePostForReading`, AppSpec §9 — curated books only); the Book Panel traced
clean (its reader skips archived gatherings; no diverge door, no add list); the ticked row is a
disabled ticked Toggle (the Private-row precedent, A-1082-4 held for her); D-1082-B1's
marker-over-designation read is sound (the same fact the table's state doors already read, converging
with `dailyJournalBookID` in any converged store, pinned over a real store as the designation moves).

**Process and canon.** Pin-before-fix held per member with the behavioral revert verified per pin by
the stage windows (I re-traced the mechanisms in code rather than trusting the transcripts; every
named red matches the mechanism I traced). No shared ledger touched mid-run; the one in-tree canon
edit (TEXTKIT2_NOTES §3) is the build companion's measured-fact class (the VX-601 precedent), not
loaded canon. The PROVISIONALs are bundled with reversible options; proposed canon lines exist per
batch in the two-file shape for the closeout; the new rendered strings are sentence-case public copy;
commits carry no attribution trailers. The batch briefs' "must check" lists are each addressed
(batch E's seam/⌥⌦/panes/⇧⏎ checks pinned; batch S's trace-first rows done — VX-1014 proven real;
batch D's VX-1016 pin-first honored; batch B's both-faces and Book-Panel checks traced).

**Run by this reviewer:** the two new core suites
(`swift test --filter 'SearchFoldsToNothingTests|SearchChapterHitsTests'` — 5 tests in 2 suites,
green).

**Walk-owed evidence (recorded as pending in the run record, not findings):** the Library chapter
row's click through the shell road; VX-1075's hover rows (the tooltip rule's last link); VX-409's
animated-beat captures plus the five hosts' triage captures; VX-1077's door walk; VX-1070's visual.

## Dispositions

PENDING (the cross-model flow: these findings go to the implementer verbatim; its agree/dispute
returns to this reviewer for the final call). With no BLOCKER or MAJOR found, round 1 does not earn
round 2 by the ladder's own rule — the orchestrator's call.
