# VX-83 — Run: 13o search follow-up (her first-use report)

**Run ticket: VX-83 · Project: 13o — Search · Branch: `vx-83-search-followup` · Worktree:
`~/dev/variorum-vx-83` (the Pro) · Orchestrator session: `searchfollowup` (her naming) ·
Stage: message the session named `oct7coordinator` — session name, what is needed (GUI walk ·
xcodebuild test · Debug launch · dev-store reset · /Applications refresh), rough duration,
urgency — BEFORE any `Tools/stage` claim; headless `swift build`/`swift test` is free.**

Members (sub-issues of VX-83, each closing individually; commits say `Part of VX-NN`):
**VX-84** tag search reveals the tagged notes · **VX-85** landing under the find bar ·
**VX-86** first-word-only find seed · **VX-87** the when ▾ door redesign (direction 1,
R-VX83-2) · **VX-88** passage-line spacing · **VX-89** the field guide's finder lesson (IN,
R-VX83-3) · **VX-72** savepoint search behind an explicit facet (joined at the sitting,
R-VX83-5). Beside the run, not in it: **VX-90** (passage lines name their block — her
feature idea, Backlog) · **VX-93** (search the Trash — the split's other half, Backlog).

Shape: `/architect-phase` (the RUN form). Pin-before-fix binds PER MEMBER (red-on-old
verified by revert); ONE cold review over the run's whole diff — **fable-reviewer** (the
diff reaches `EditorViewModel`'s landing/reveal machinery, editor-adjacent). Merge order:
**FREED — first-ready merges first, whoever is second rebases** (R-VX83-7, superseding
the kickoff's "13x merges first", both her word). One PR titled `VX-83: …`, merge commit;
the closeout includes the `/Applications` refresh and the author handoff notes.

---

## HER REPORT (2026-10-07 evening, verbatim-faithful; the screenshots are the session's record)

1. *"classics are not showing notes tagged classics, in fact searching a tag is not
   revealing the notes tagged that at all."* — `#classics` typed alone lists only the
   associated gathering + "Type a word to search inside #classics."; the plain word
   `exampletag` answers "nothing found" though a note is tagged `exampletag`. → **VX-84**
2. *"when you click onto a result, it looks like it wasn't working but it's because the
   search bar hides the result, which is at the top of the page."* → **VX-85**
3. *"also only the first word of what you searched is filled in"* — "sherlock holmes"
   lands with the find bar armed as "Sherlock". → **VX-86**
4. *"I think that the date selector is ugly and it's very unclear if there's confirmation.
   the nested drop downs where a new dropdown appears is also a big of an ugly ux
   experience."* → **VX-87**
5. *"when there are many results in a block the spacing between the results is weird. and
   maybe it should say what block they're in? that can be filed as a feature idea rather
   than being done right now depending on difficulty."* → **VX-88** (spacing) + **VX-90**
   (the feature idea, filed beside the run)
6. *"were search details added to the field guide?"* — they were not (TutorialSeeder
   mentions search only in passing). → **VX-89**, pending her word
7. Also hers, informational (answered in the session reply, no member): why "i'd love" is
   generous (she likes it); how search works; ⌘G fine; VX-72/73 lift; the #201 bundle and
   U3-3 explained.

## MECHANISM TRACES (the orchestrator's, 2026-10-07; each member's pin re-proves its own)

- **§M1 (VX-84).** Two halves. (a) `#tag` ALONE: `LibrarySearchModel.listing` reads groups
  only when `question.hasWords` (P-13o-U2-6 as narrowed at U3 — a tag alone answers with
  its ASSOCIATED BOOKS only; the sheet's words-ask line is `LibrarySearchCopy.tagAlone`).
  Her report supersedes the provisional: a tag alone must also reveal the TAGGED NOTES.
  The composer's tag filter already exists and already unions post-level and block-level
  applications subtree-wise (`SearchComposer.tagSubtree` — `post_tag` at note level,
  `∪ block_tag` at passage level, wing-scoped, path-insensitive) — what is missing is a
  TEXT-LESS listing road (P-13o-U1-7: the composer serves no text-less question).
  (b) A PLAIN WORD naming a tag (`exampletag`): nothing in the index carries tag paths
  (deliberate — a tag-application doc would need a cross-table read in a trigger, the
  R-13o-4 fence), so the word finds nothing.
- **§M2 (VX-85).** `EditorViewModel.applyFindSeed` selects the match and parks the reveal
  (`revealLanding`); the settle hop spends it through `consumePendingReveal` →
  `JumpPrimitive.jump(toOffset:)` with DEFAULT `landingInset` (0) — the matched line lands
  FLUSH at the viewport top, exactly the strip the just-shown find bar occupies
  (`performFind(.show)` runs before the hop). The comfort-band road exists and is used by
  mode-switch arrivals only (`restCaretLineInTheBand`, 18l-c U8 (b): top air, never flush,
  two lines of room below) — the find-seed landing never takes it.
- **§M3 (VX-86).** `SearchLanding.findSeed` takes the snippet's FIRST matched run
  (`snippet.first(where: \.isMatch)`). FTS5 marks EACH term's occurrence as its own run,
  so "sherlock holmes" produces [match "Sherlock"][text " "][match "Holmes"] and the
  needle is "Sherlock". The §12 contract line ("the match selected and the find bar
  armed", the U2 brief's "armed with the query") wants the full adjacent span.
- **§M4 (VX-87).** `LibraryWhenDoor`: a `VoicedMenu` whose items ARM silently
  (P-13o-U2-9) and then open a SECOND surface (`.popover`) holding bare
  `.field`-style `DatePicker`s — the menu→popover chain she calls nested; no visible
  confirmation near the hand (the armed chip lands in the band, a row below and left).
- **§M5 (VX-88).** `LibrarySearchLine` renders a passage's snippet as ONE `Text` with
  `lineLimit(2)` and `.padding(.vertical, 2)` per row. A snippet whose window crosses an
  internal newline (I4 — newlines are content; FTS5's snippet copies raw text) renders as
  two TIGHT visual lines inside one row, while neighboring passages carry the 2+2 padding
  between them — the rhythm breaks exactly when one block holds many matches. (Confirm at
  the pin; if the trace is wrong, the pin-first rule decides — red confirms.)
- **§M6 (VX-89).** `TutorialSeeder` carries three glancing uses of the word "search" and
  nothing of the finder (the one field, `#tag`, when ▾, the book 🔍, land-at-match/⌘G).
  13s (VX-7, in flight) owns the user-facing field-guide REWRITE — overlap flagged; her
  word decides whether the finder's functional lines land here (the VR-122 seed-edit
  pattern, currency pins) or ride 13s.

## DESIGN — the provisional calls (PROVISIONAL-and-continue; her sitting confirms or redirects)

- **D-1 (VX-84a) — a `#tag` alone NARROWS THE LIBRARY like a day does.** The tag-alone
  question routes to the catalog's own listing narrowed by the tag (the day filter's
  precedent, `editedOnClause`): notes whose subtree-tag applies (post-level), scraps/blocks
  by block-level tags in the Blocks scope; the band keeps its chips (`#classics ✕`,
  `in: Home`) and honest counts; the Books section (the association join) stays above,
  unchanged; the sort ▾ and scope picker stay LIVE (no fabricated relevance — nothing was
  ranked). The words-ask line dies. The tag-subtree predicate is composed by the ONE
  composer (R-13o-8 — exposed as a fragment, never re-derived SQL). With words typed
  beside the tag, everything stays exactly as shipped (ranked sheet, tag as filter).
  *Alternative recorded for her:* tag-alone opens the ranked sheet with line-less groups —
  rejected provisionally (fabricated rank order; the listing idiom already exists).
- **D-2 (VX-84b) — a plain word that NAMES a tag OFFERS the tag.** When the typed words
  match a live tag's path leaf (case-insensitive; the tail word by prefix, the parser's own
  ≥2 rule) in the wing, the band offers a quiet invitation chip — `tag: #exampletag ›` —
  one press replaces/augments the question with the typed tag (fire-and-DO, P-2), which
  then lists the tagged notes per D-1. The ranked stream itself stays text-honest.
  *Alternative recorded for her:* fold tag-matched notes straight into the results.
- **D-3 (VX-86) — the needle is the snippet's first CONTIGUOUS matched span**: adjacent
  matched runs separated only by whitespace coalesce ("Sherlock Holmes"); scattered terms
  keep the first run (the find bar cannot hold a disjunction). Case preserved as written.
- **D-4 (VX-85) — the find-seed landing rests in the COMFORT BAND** (the mode-switch
  arrival's own rule, `restCaretLineInTheBand`): the matched line in the top air with room
  below, never flush under the bar; the non-stepping (unrendered-take) arm keeps its
  no-scroll behavior. The hop ordering (bar shown before the jump) means the band is
  computed against the bar-adjusted viewport — the walk verifies on 27.0.
- **D-5 (VX-88) — snippet newlines fold at the FACE**: `LibrarySearchFace.snippet` renders
  a newline run as a single visible separator (one space; the line stays one passage, one
  visual rhythm). The index and composer stay byte-untouched.
- **D-6 (VX-87) — mockup round first**: 2–3 directions in
  `notes/plans/mockups/when-door.html` (one surface off the `when ▾` press, the choice +
  date editing + a visible armed sentence together; no menu-then-popover chain). Her pick
  rules; the build follows.

## THE PLAN (two acceptance units, one implementer session each)

### U-A — THE DEFECT MEMBERS: VX-84 · VX-85 · VX-86 · VX-88 (evidence: suites + pins
red-on-old by revert + the orchestrator's walk after close)

### U-A BRIEF (self-contained; the implementer session reads ONLY the repo)

**Who you are:** the U-A implementer (Opus, xhigh), ONE session, ONE acceptance unit — the
13o follow-up defects. Work ONLY in `~/dev/variorum-vx-83` (branch `vx-83-search-followup`);
pull first. **Required reading before anything:** this file WHOLE ·
`notes/plans/phase-13o-search.md` (the sitting/mockup/fork/U3 rulings and the U1–U3
RECORDs — you build ON the 13o machinery, never beside it) · `notes/TEXTKIT2_NOTES.md`
(VX-85 touches the landing/reveal seam) · `notes/SessionResiliencyProtocol.md` (checkpoint
protocol from your FIRST commit; the U-A RECORD below is your LIVE STATUS). At most ONE
Sonnet subagent, external facts only, read-only.

**The pieces (each its own commit, pushed; pin-before-fix PER MEMBER):**
1. **VX-86 (smallest first):** `SearchLanding.findSeed` coalesces the first contiguous
   matched span (D-3). Pin red-on-old: a two-adjacent-runs snippet arms the joined words
   (core-side pure test + the Mac `LibrarySearchLandingTests` arm); verify by revert.
2. **VX-85:** the find-seed reveal lands in the comfort band (D-4): route the find-seed
   park through the banded arm (the `pendingModeSwitchArrival` branch's sibling — a parked
   reveal KIND, never a second reveal mechanism; `restCaretLineInTheBand` is the one rule).
   ZERO lines in `EditorTextView`/`BlockRangeIndex`/`PaneSurface` (the 13o fence,
   verbatim). Pin red-on-old at the feature-API level (the landed line's top ≥ the band's
   air under a shown find bar; `LibrarySearchLandingTests`' idiom); verify by revert.
3. **VX-88:** confirm §M5 by the pin FIRST (a snippet with an embedded newline renders two
   visual lines in one row — red confirms the trace; green means record-only and STOP for
   the orchestrator). Then D-5: fold newline runs in `LibrarySearchFace.snippet`; pin the
   face rule; walk-check the rhythm.
4. **VX-84a (the largest):** D-1 — the tag-alone listing. Core: the one composer grows the
   text-less TAG road (a narrowing fragment the catalog listing composes — PROPOSE the
   exact seam in the U-A RECORD before building if you find a real fork: a
   `Queries.catalogPostsSQL` predicate vs a composer-served id-set; measurement line if it
   matters). Mac: `LibrarySearchModel.listing`/`LibraryCatalogModel` route a tag-alone
   question to the narrowed LISTING (sort ▾ and scope picker live; the band's chips and
   counts honest; the Books association section unchanged above; the words-ask line dies).
   Blocks scope narrows by block-level tags. Pins: core predicate cells (post-level,
   block-level, subtree, wing, tombstones) + Mac state-transition pins (tag-alone lists the
   tagged notes; with words everything reads byte-as-shipped) — each red-on-old.
5. **VX-84b:** D-2 — the band's tag-offer chip for a plain word naming a tag (leaf match,
   tail-prefix ≥2; wing-scoped; live tags only). One press arms the tag (fire-and-DO).
   Pins: the offer rule's cells + the press's routing. PROVISIONAL — she may redirect to
   the fold-in alternative; keep the rule in ONE pure home so the redirect is cheap.
6. **Close:** full core `swift test` + the touched Mac suites + the tutorial spine
   (`TutorialWalkTests`) green at the END under a stage slot (ask `oct7coordinator`
   first — name yourself `searchfollowup U-A implementer`); record final; report.

**Fences, verbatim-binding:** zero `Sources/VariorumCore/Sync/` lines; zero lines inside
`EditorTextView`/`BlockRangeIndex`/`PaneSurface`; every search read through the ONE
composer (R-13o-8); no new trigger may read another table (R-13o-4); the environment-traps
block below byte-binds; commit per piece, push every commit, synchronous foreground waits
only; never `git checkout` over uncommitted work.

### U-A RECORD (LIVE STATUS — the implementer maintains this from its first commit)

**U-A CLOSED (2026-10-07 23:3x) — what U-A did NOT do, first:** no walk and no captures of its own
(the brief's evidence is suites + red-on-old pins + the ORCHESTRATOR'S walk after close — every
face below is a claim until that walk: the band's `tag: #path ›` chip, the tag-alone listing's
Blocks section and archived marks, the landing below the bar on 27.0 in the real app); no
`notes/QUESTIONS.md` entries and no canon deltas (shared ledgers — the merge moment's;
P-VX83-1…6 ride to the ratify bundle); zero `Sources/VariorumCore/Sync/` lines; zero lines in
`EditorTextView`/`BlockRangeIndex`/`PaneSurface`; U-B/U-C members (VX-87, VX-89, VX-72) untouched;
the ⌘K palette's raw-newline passage titles (another surface) observed, not fixed; the master
plan's ledger row 5 is the orchestrator's to flip after its check and walk. **Every member is
DISPOSITIONED FIXED, each with a red-on-old pin verified by revert (the table in THE SLOT, below).**
PENDING flags: none.

**Seat:** the U-A implementer (Opus, xhigh), seated 2026-10-07 in `~/dev/variorum-vx-83` on
`vx-83-search-followup` (pulled at `ce523f3f`). Required reading done in-context, never
delegated: this file WHOLE · `notes/plans/phase-13o-search.md` WHOLE (sitting / mockup / §FORK /
§U3 rulings, the U1–U3 RECORDs, the ladder) · `notes/TEXTKIT2_NOTES.md` ·
`notes/SessionResiliencyProtocol.md` · CLAUDE.md + its canon; and the code the pieces touch
(`Shared/SearchLanding.swift`, `EditorViewModel`'s focus seeds / reveal park / comfort band,
`JumpPrimitive`, `ComfortBand`, `EditorFind`, `Core/Views/SearchAnswerFaces.swift`,
`LibrarySearchSheet`, `LibrarySearch{Model,Routing}`, `LibraryCatalogModel`/`View`,
`Queries.catalogNotesPage`/`catalogPostsSQL`/`editedOnSQL`, `SearchComposer` whole,
`Queries/SearchQueries.swift` whole). Machinery: no deaths so far.

**A MEASURED FACT for VX-85 (headless AppKit probe, no window shown, no store — an external-fact
probe, macOS 27.0):** a shown find bar does NOT shrink the clip. `NSScrollView` lays the
`NSTextFinderBarView` (32 pt) OVER the clip's top edge and says so through the CLIP's own
`contentInsets` (top 32 · bottom 6); the clip frame stays whole and its bounds origin does not
move. So `JumpPrimitive`'s "line at the viewport top" (= `clip.bounds.minY`) is exactly the strip
under the bar — and a match in a note's FIRST line (scroll 0, line top 24 pt) sits under the
32-pt bar with NO scroll at all (the reveal's visibility guard calls it on screen). §M2 holds
and widens: the hidden strip is the bar's, read from `clip.contentInsets`.

**THE PIECE PLAN (each piece its own commit, pushed; flipped here in the same commit):**

| # | Piece | Status |
|---|---|---|
| P0 | This record + piece plan (the first commit) | DONE (`77e6d2ea`) |
| P1 | **VX-86 core** — the needle rule (D-3) as ONE pure core rule beside `SearchSnippetSegment` (the first CONTIGUOUS matched span; whitespace-only gaps coalesce; a gap holding a newline ends the span — the find bar is one line) + core pins (the rule's cells; the mechanism: FTS5 marks "sherlock holmes" as two runs) — headless, revert-probed | DONE (`68508196`) — `SearchSnippetSegment.firstMatchedSpan` (`Domain/SearchComposer.swift`); `SearchFindSeedSpanTests` 4/4 GREEN. **Mechanism confirmed on a REAL snippet:** "sherlock holmes" over "It was Sherlock Holmes who…" marks `["Sherlock", "Holmes"]`, two runs. **REVERT PROBE** (committed first; the body short-circuited to the shipped first-run letter, restored by `git checkout --`, re-run green): **RED — 5 issues in 3 tests** (the three coalescing cells, the first-span-not-a-later-one cell, the real snippet's needle `"Sherlock"`). The newline-ends-the-span cell is a refinement inside D-3 (the find bar is one line), recorded as PROVISIONAL P-VX83-1 |
| P2 | **Mac pins on the PRE-FIX app tree** (red-on-old, the members' own pins): VX-86 `SearchLanding.findSeed` two-runs arm · VX-85 the landed line vs the bar-adjusted band (a far block AND a note's first line) · VX-88 the §M5 confirm (a newline snippet's row height vs a plain one) · VX-84a tag-alone lists the tagged notes (+ the words control) → ONE stage slot (ask `oct7coordinator`), reds recorded | DONE — written + compiled (`197205f5`, `4d9119ba`); RUN RED-ON-OLD in the slot by the announced revert (THE SLOT, below — 12 issues across the 9 member pins, every control green). History: the RUN waited on the stage — at 20:5x the stage is HELD by `oct7coordinator` ("author on the Pro — no walks/app suites until she says open season", ~210 min). Request sent (msg b013808a; replies land in the parent session `searchfollowup`, which relays). Since the slot arrives after the fixes, the red-on-old evidence comes by ANNOUNCED REVERT inside the slot (fixes committed first; production files checked out at `4d9119ba` with the pins kept; run; `git checkout HEAD --` restore) — the protocol's commit-before-revert form |
| P3 | **VX-86 Mac** — `SearchLanding.findSeed` reads the core rule | DONE (this commit) — the seed's needle is `SearchSnippetSegment.firstMatchedSpan`; pins `aTwoWordQueryArmsTheBarWithBothWordsAsWritten` + `theSearchStatesOwnPassageLandsTheWholePhrase` — `6d48e630`; GREEN at HEAD, RED on the pre-fix app (both) |
| P4 | **VX-85** — the find seed's park is a BANDED reveal kind (the mode-switch arm's sibling; `restCaretLineInTheBand` the one rule, computed against the BAR-ADJUSTED viewport); `JumpPrimitive`'s scroll floor follows the bar's top inset so a first-line match can rest below the bar | DONE (`89853310`; pins re-mounted `1d12917c`) — `EditorViewModel`: `RevealKind {plain, banded}` rides the reveal park (`pendingRevealKind`, dies with its park at every spend/abandon); `applyFindSeed`'s stepping arm parks `.banded`; its non-stepping arm bands the caret seed's ALREADY-parked reveal (no reveal of its own — a refinement of D-4's "keeps its no-scroll behavior": that arm's caret reveal also landed the block under the bar it shows, P-VX83-2); `consumePendingReveal` sends `.banded` through `restCaretLineInTheBand`, which now reads the band against the viewport minus `JumpPrimitive.findBarInsets` (ZERO with no bar shown — the 18l-c mode-switch rule byte for byte). `JumpPrimitive`: `findBarInsets(of:)` (the clip's `contentInsets` while `isFindBarVisible`, else 0) and the jump's floor `minScroll = −top inset` (`JumpCorrectionLoop.run` gains `minScroll: Double = 0`; every other caller byte-unchanged) — **MEASURED headlessly: `NSClipView.constrainBoundsRect` floors at exactly −32 under the bar, so the new floor IS AppKit's own** (and `scroll(to:)` itself does not constrain — −80 sticks, hence the explicit floor). `ComfortBand`'s scope sentence names the new caller. **ZERO lines in `EditorTextView`/`BlockRangeIndex`/`PaneSurface`.** Mac `build-for-testing` SUCCEEDED. Pins (`LibrarySearchLandingTests`): the far match in the band below the bar · a FIRST-line match clears the bar · the unrendered arm's block clears the bar · a mid-band control never moves — **RE-MOUNTED at the slot (`1d12917c`) on a real `EditorView`** (the first cut's bare harness never delivered the settle hop — THE SLOT, step 1); GREEN at HEAD (12/12 suite), RED on the pre-fix app (3/3, the control green) |
| P5 | **VX-88** — D-5, newline runs fold at the face (`LibrarySearchFace.snippet`), pinned; CONDITIONAL on the §M5 confirm going RED on the pre-fix face | DONE (`291f9dae`; the confirm RED on the pre-fix face) — **the trace's two premises evidenced headlessly before any fix:** (1) CORE, `SearchSnippetRawTextTests` 1/1 green — the index's snippet over "we walked along⏎⏎the harbor at night⏎and home" IS that raw text, both breaks included (green on both sides by design: the index and composer stay untouched); (2) the FACE, an external-fact SwiftUI probe (headless `NSHostingView`, no window): a `Text(…).lineLimit(2)` at 640 pt stands **15 pt plain · 30 pt with one newline · 30 pt across a blank line** — two tight lines, or a line and a blank one, in one row. The fix: `LibrarySearchFace.foldingNewlines` (a whitespace run holding a line break → ONE space; other whitespace kept) applied per segment in `snippet` — the shared face, so the book's sheet folds too; marks untouched. Pins (`SearchPassageLineRhythmTests`): the §M5 CONFIRM (row heights, both voices) + the face rule. **THE CONFIRM RAN RED on the pre-fix face — §M5 CONFIRMED: 28 pt vs 14 pt for a newline AND a blank line, both voices** — so the fold STANDS (`291f9dae`); GREEN at HEAD. OBSERVATION (not this member — another surface): the ⌘K palette's passage row titles itself with the same raw words (`CommandPalette.passageItem`), so a palette row may show only the snippet's first line; the fold is one call there if the orchestrator wants it |
| P6 | **VX-84a core** — the text-less TAG road in the one composer (the seam measured, below) + `Queries` listing reads + core cells | DONE (this commit) — `SearchComposer.listingNarrowing(_:kind:wingID:environment:)` → `ListingNarrowing {driver, conditions}` (notes by `post_tag`, blocks by `block_tag`; the DRIVER = each typed `#path`'s subtree applications, `SELECT DISTINCT … AS tagged_id`, several tags INTERSECT; the CONDITIONS = the whole question at note/block level through the ONE `composeFilter` + liveness + wing + the archived facet's clauses), `composeFilter` gains a `.block` level (a tag term is the BLOCK's own; home answers starred/day/family; no book, no doc), `SearchComposer.listingCounts` (notes/all_notes/blocks/all_blocks); `noteVisibility` and `appliedTags(join:)` factored out BYTE-IDENTICAL — **proved: 270 shipped statements (passages · groups · counts · worn-day · association × 3 visibilities × 3 scopes × 5 queries) snapshotted on the pre-change commit in a scratch worktree and on this tree: `cmp` IDENTICAL**. `Queries.catalogNotesPage(…, narrowing:)` (nil = the shipped statement, pinned) · `Queries.catalogTaggedBlocks` (`Queries/TagListingQueries.swift` — a SET, newest edit first, first-line handle) · `SearchCounts.Kinds.blocks` (default 0) · `searchCounts`' text-less branch folds the narrowed notes/blocks (Library scope only). Pins `SearchTagListingTests` 10 + `SearchTagListingSeamTests` 2 — **12/12 GREEN** (post-level · subtree · case · wing twins · tombstones · facet + version fence · a note tagged twice in the subtree lists ONCE (found red at the seam, 3 issues, before the DISTINCT) · intersection · sort + keyset · words close the road · blocks by block-level tags, scraps in every wing · the counts). JUSTIFIED EDIT: `SearchTagAssociationTests.theBandCountsTheAssociatedBooksWithWordsAndWithout`'s tag-alone cell `notes: 0 → 1` (P-13o-U2-6 superseded by her report — that cell flipping IS the core-side red-on-old of the behavior change). Families `Search|Catalog|LibraryDay|LibraryPaging|Shelf|Gathering` **247/57 GREEN** |
| P7 | **VX-84a Mac** — a tag-alone question routes to the narrowed LISTING | DONE (`6b73a63a`, `625af236`; `LibraryTagListingTests` GREEN at HEAD; the two pre-fix pins RED on the pre-fix app, the words control green) — `LibraryCatalogModel.listing`: with WORDS the sheet exactly as shipped; a `#tag` ALONE → the Books section unchanged (the association) + the NOTES through `catalogNotesPage(narrowing:)` (scope All/Notes; paged; the sort door's order) + the BLOCKS through `catalogTaggedBlocks` (scope Blocks); `blockHits` + `listedNarrowing` on the model; `loadMoreNotes` asks the same narrowed question (the shipped next-page read passed the FIELD'S text as a title LIKE — under a tag alone page 2 would have been empty); **`canAskForMore` lets a narrowed listing page under an armed day** (it refused every next page while a day was armed — a tag + a day would have capped at 80 with no road, R-13o-9); the view routes ONLY words to the sheet (`isSearching`), so the List/Cards draw the narrowed listing under the band with the sort ▾ and scope picker LIVE; a Blocks section with the pre-U2 block row face (handle · "in <home>", landing at the block, no find seed); the tag-alone archived foot on the listing (the sheet's foot rule); `CatalogArchivedMark` ("archived", the answer sheet's badge word) on a row/card whose note is archived (only reachable under the facet — `CatalogHit.isArchived`, false-defaulted); the band's counts say "N blocks" (`SearchCounts.Kinds.blocks`); the sheet's words-ask branch and `LibrarySearchCopy.tagAlone` DIED. **JUSTIFIED PIN EDITS** (each encoded the superseded P-13o-U2-6): `LibrarySearchJoinTests.aTypedTagAloneListsItsAssociatedBooksSayingWhy` (`noteHits.isEmpty` → the tagged note listed; counts +1 note) · `LibrarySearchStateTests.aTagAloneListsNothingUntilWordsJoinIt` → `aTagAloneNamesOnlyTaggedNotesNeverTitleWords` (same cell, honest under D-1: a title's words are not a tag) · `LibrarySearchFaceTests` (the `tagAlone` copy cell → the counts' blocks words). New pins in `LibraryTagListingTests` (built with the fix): page 2 stays narrowed · a day beside the tag narrows and still pages · the Blocks scope lists the tag's blocks (counts whole-question, D3) · the archived facet brings the tag's archived notes, marked |
| P8 | **VX-84b** — the tag-offer chip (D-2, **RATIFIED R-VX83-1**): one pure rule home + the composer's wing vocabulary read + the band chip + the press routing; pins | CORE DONE (`2559c09e`); MAC BUILT — `Domain/SearchTagOffer.swift` (a typed word/phrase offers a live tag whose LEAF it is; the type-ahead TAIL — the parser's `.prefix`, ≥ 2 — offers by leaf PREFIX; case + diacritics folded, the index's sameness R-13o-11 (P-VX83-6); a typed tag never re-offered; exact before prefix, shallower, then path; at most 3 (P-VX83-6)), `SearchComposer.wingTagVocabulary` (∝ the wing's tags — the class `typedTagPaths` already pays per keystroke), `Queries.searchTagOffers` (Library scope, words only). `SearchTagOfferTests` 4/4 GREEN; **REVERT PROBE** (committed first; the rule short-circuited to `[]` — the pre-fix "no offer" road; restored by `git checkout --`, re-run 4/4 green): **RED — 8 issues in 3 tests**. **MAC DONE (`143cfbab`; GREEN at HEAD in the slot's batch):** `LibrarySearchListing.tagOffers` read by `LibrarySearchModel.listing` (the whole question's, like the counts), `LibrarySearchModel.tagOffers`, the band's dashed invitation chip per offer — `tag: #path ›` (D-2's own words, `LibrarySearchCopy.tagOffer`) — whose press is `LibraryCatalogModel.acceptTagOffer` → `LibrarySearchQuestion.acceptingTagOffer` (the naming word BECOMES `#path`; a word since typed away → the tag joins; always ends in a space) + `search()` (fire-and-DO). A refinement found by reading my own pin: a tag whose PATH holds whitespace is never offered — the v1 field cannot type it (`#old house` = tag `old` + word `house`), so its press could not ask for it (P-2; folded into P-VX83-6). Pins (`LibraryTagListingTests`): her `exampletag` case end-to-end (offered, the stream text-honest, the press lands on the tag's narrowed listing, never re-offered) + the rewrite's cells |
| P9 | Close — full core `swift test` + the touched Mac suites + `TutorialWalkTests` green at the END (stage slot), record final, report | **DONE (this commit)** — **Mac at the END, HEAD `1d12917c`: 384 tests in 57 suites PASSED, `BATCH EXIT 0`, ZERO skipped** (the 56 below + VX-94's `ChromeLineLimitTests` — its green IS VX-94's proof, the coordinator's amendment) **+ `NoteOpenLandingTests` 12/12 alone**; stage claimed 23:05 → RELEASED 23:26, coordinator told. Headless at `625af236`: **core `swift test` EXIT 0 — VariorumCoreTests 2,304 tests in 263 suites PASSED** (the standing honest skips only: the two gated benches' 4 tests, the live-Supabase pass, `writeAScratchLibraryLikeHers`) + StringsWorkbookTests 40/6; **VariorumMobile builds** (`generic/platform=iOS Simulator`); Mac `build-for-testing` SUCCEEDED at HEAD. **THE SLOT PLAN (scripts untracked in `.build/vx83/`):** (a) `run-mac-suites.sh` on HEAD — `test-without-building`, 56 suites: the U-A pins (`LibrarySearchLandingTests` · `SearchPassageLineRhythmTests` · `LibraryTagListingTests`) + the edited pins (`LibrarySearchFace/Join/StateTests`) + the touched Library/search suites (`LibrarySearchArchived` · `LibraryWhenRange` · `LibrarySearchWiring` · `PaletteSearch` · `BookSearch` · `LibraryDayFilter` · `LibraryPagingModel` · `LibraryInfiniteScroll` · `LibraryViewScopeSwitch` · `LibraryListFace` · `LibraryRowAlignment` · `LibraryPanelHost` · `LibraryPreviewBrain` · `NoteRowSelectionRule` · `NoteRowRouting` · `CapabilityRegistry` · `ShellLanding{Rule,Mount,Door}` · `FindAndReplace` · `FocusHandoff` · `BareArrivalFocus`) + every suite on the jump/reveal/band seam (`BookOutlineLanding` · `BookView` · `ComfortBandAndFlash` · `CurrentBlockContinuity` · `EditorWindowSmoke` · `JumpCorrectionLoop` · `FragmentLines` · `JumpViewportLayout` · `LandingOffset` · `ModeSwitchCarry` · `ModeSwitchFeel` · `RefontGapTop` · `RefontViewport` · `TakesEntryBand` · `TypewriterRoomReachability` · `WriteFloatingViewport` · `WriteTopAir`) + the tutorial spine's eleven; then `NoteOpenLandingTests` ALONE (13o's order-sensitivity note, VX-78). (b) the ANNOUNCED RED-ON-OLD REVERT: everything committed; `git checkout 4d9119ba -- App/Variorum` (the app exactly as the pre-fix pins were written against — core stays at HEAD, additive); `run-pins-only.sh` (builds + runs the three member suites) — expected RED: VX-86 two-word seed (2 tests), VX-85 far/first-line/unrendered (3; the mid-band control green), VX-88 the §M5 confirm (2 voices; a GREEN here ⇒ the D-5 fold is reverted and VX-88 closes record-only), VX-84a tag-alone + sort (2; the words control green); then `git checkout HEAD -- App/Variorum` and `git status` clean. |

PENDING flags: none.

**THE SLOT (2026-10-07, the coordinator's GO; claimed `searchfollowup` 23:05):**
1. **Batch run 1 on HEAD `908c8ac0`** (57 suites incl. VX-94's `ChromeLineLimitTests`): **382/384** —
   the two reds were MY OWN VX-85 pins, and the trace is a HARNESS one: they sat on U2's bare
   scroll-view harness (`withLandedEditor`, 6×30 ms pumps), which never drives the display pass that
   delivers the N14 settle hop, so the parked reveal is never spent there — before OR after the fix
   (`scrolled: 0.0` with the far match's line at 1,126 pt; the first expectation passed only because
   1,126 > 55 — the pins were too weak to see that nothing moved). **Fix (test-only, this commit):**
   the four VX-85 pins re-mounted on `LandingOffsetTests`' idiom — a real `EditorView` in a hosting
   view seeded as `PostDetailView.jump(to:find:)` seeds it, settled through layout + DISPLAY passes —
   and every band assertion now requires the line ON SCREEN below the bar (top ≥ bar + air AND bottom
   ≤ the unobscured bottom − room). Re-run: `LibrarySearchLandingTests` **12/12 GREEN**.
2. **ANNOUNCED REVERT — STARTING NOW (everything committed first):** `git checkout 4d9119ba --
   App/Variorum` then `git checkout HEAD -- App/Variorum/VariorumTests/LibrarySearchLandingTests.swift`
   (the re-mounted VX-85 pins use only pre-fix APIs); `run-pins-only.sh`; restore with `git checkout
   HEAD -- App/Variorum` and `git status` clean. A successor finding a dirty `App/Variorum` knows it is
   mid-revert: restore with exactly that command.
   **RAN (23:15–23:17) — RED-ON-OLD, every member, every control green: 16 tests in 3 suites, 12
   issues:**

   | member | pin | on the PRE-FIX app (measured) | at HEAD |
   |---|---|---|---|
   | VX-86 | `aTwoWordQueryArmsTheBarWithBothWordsAsWritten` | RED — the needle `"Sherlock"` | GREEN |
   | VX-86 | `theSearchStatesOwnPassageLandsTheWholePhrase` | RED — the real passage armed `"Sherlock"` | GREEN |
   | VX-85 | `aFarMatchRestsInTheComfortBandBelowTheShownBar` | RED — the line FLUSH at the clip's top (top 1,198 = view top 1,198), wholly UNDER the bar (to 1,230) | GREEN |
   | VX-85 | `aMatchInTheNotesFirstLineIsNotHiddenUnderTheBar` | RED — the first line at 24 under the 32-pt bar, page unmoved | GREEN |
   | VX-85 | `anUnrenderedSeedsBlockRestsBelowTheShownBar` | RED — the block flush at 1,205 under the bar (to 1,237) | GREEN |
   | VX-85 | `aMatchAlreadyRestingMidPageLeavesThePageAlone` (control) | green | GREEN |
   | VX-88 | `aSnippetCrossingANewlineStandsAsTallAsOneThatDoesNot` ×2 voices | RED — **§M5 CONFIRMED: 28 pt vs 14 pt** (a newline and a blank line, Terminal and Study) | GREEN |
   | VX-84a | `aTagAloneListsTheNotesItTagsSubtreeIncluded` | RED — no notes listed | GREEN |
   | VX-84a | `theTagAloneListingFollowsTheSortDoor` | RED (2 issues) — no notes listed | GREEN |
   | VX-84a | `withWordsTheTagFiltersTheAnswerSheetAsShipped` (control) | green | GREEN |

   (VX-84b's red-on-old is the core revert probe — P8: 8 issues in 3 tests; VX-86's core rule's is
   P1's — 5 in 3; VX-84a's core-side is the flipped `SearchTagAssociationTests` cell and the
   seam's DISTINCT pin, red first.)
3. **RESTORED 23:17:** `git checkout HEAD -- App/Variorum` → `git status` CLEAN at `1d12917c`.
4. **THE END RUN on HEAD `1d12917c`** (rebuilt): **384 tests in 57 suites PASSED, ZERO skipped**
   (`ChromeLineLimitTests` green — VX-94's proof) + **`NoteOpenLandingTests` 12/12 ALONE**.
5. **RELEASED 23:26**, `oct7coordinator` messaged (msg 77db7fad); no app instance was running at
   any point (checked by path).

**SELF-ASSESSMENT (the implementer's, before the cold review):** every read on the new roads goes
through the one composer (the text-less narrowing, its counts, the offer's vocabulary); no trigger
was touched; the shipped statements are byte-identical (270 snapshotted); the new tag road is ∝
the tag's applications (measured flat, plans pinned on both edited-sort arms). The editor-seam
change is two narrow things — a reveal KIND on the existing park and a jump floor that is AppKit's
own under a shown bar (zero without one). The evidence I trust least: VX-85 in the REAL app (the
SwiftUI host, the window's chrome) — the mounted pins and the headless probe agree on 27.0, the
walk is the arbiter. **WATCH ITEMS for the ladder:** (1) `JumpPrimitive`'s `minScroll` and
`JumpCorrectionLoop.run(minScroll:)` — every jump reads `findBarInsets`, zero unless a bar is
shown; (2) P-VX83-2 — the non-stepping arm's caret reveal is now banded too; (3) the first cut of
the VX-85 pins was HOLLOW on its harness (found and fixed at the slot, recorded above) — a
reviewer should confirm the re-mounted ones measure a real landing; (4) `canAskForMore` and
`loadMoreNotes` changed for the narrowed listing (a day beside a tag now pages; the next page
never LIKEs the field's text); (5) P-VX83-3/4 — archived rows marked, blocks as a whole set; (6)
`LibrarySearchSheet` lost its tag-alone branch (the sheet is words-only now) — the U3 archived
foot for a typed tag's books moved to the listing (`tagListingArchivedFoot`).

**§SEAM — VX-84a's fork, measured and resolved by P1 (not a real fork: one side breaks an
invariant).** The brief named the choice: a `catalogPostsSQL`-style PREDICATE (the composer's
note-level tag fragment composed into the shipped sort walk, `INDEXED BY idx_container_touched`)
vs a composer-served SET the page is driven from. Measured with the deterministic pager counters
(`SearchTagListingSeamTests`, the P1 suite's idiom), a fixed 10-note tag set — the OLDEST touched,
so a newest-first walk meets them last — over 2,000 → 10,000 notes: **predicate in the sort walk
41 → 132 page requests (×3.2 — ∝ the wing's notes; for a tag that names nothing, every keystroke
of `#cl…` walks the whole wing) · driven page 41 → 51 (flat — ∝ the tag's notes).** So the
narrowing is BOTH: the composer's fragment (R-13o-8), composed so the listing DRIVES from the tag's
applications. **Three plan traps found on the way, each pinned** (`theDrivenPlansStartFromTheTagNeverAWalk`
reads the shipped edited sort's BOTH arms): (1) a flattened driver let the planner search `container`
BY KIND per application in the never-touched arm (697 → 3,317 pages, ∝ N) — fixed by `+c.kind` (the
worn-day arm's precedent); (2) a free join order scanned EVERY live `post_tag` row to satisfy
DISTINCT — fixed by the driver's `CROSS JOIN` order (root → applied → applications by tag id); (3)
a note wearing a tag AND its child came out of the driver twice — fixed by `DISTINCT` (red-first,
`aNoteTaggedTwiceInTheSubtreeListsOnce`). The blocks road's plan: driver → `block` by key →
`uq_cblock_ownership` → `container` by key. Residual class, unchanged from the shipped tag filter:
`root.path = ? COLLATE NOCASE` scans the wing's tag index (∝ the vocabulary, P-13o-U1-9's letter).

**STAGE PROTOCOL (the coordinator's amendment, 2026-10-07 ~21:0x — binding):** first in
`oct7coordinator`'s queue; the stage is held for the author (the 13x closeout). Build every
piece and core pin headless; send a short "ready" ping (as "searchfollowup U-A implementer")
when the Mac slot is actually needed; claim ONLY on an explicit GO with exactly
`Tools/stage claim --who searchfollowup --reason "VX-83 U-A pins + red-on-old + suites"
--minutes 60` (renew if long; release AND message the coordinator when done); never idle for
the GO — if headless work is done first: flip Mac claims to PENDING-on-stage, push, ping ready,
END the session reporting "awaiting GO" (the orchestrator resumes by message).

**PROVISIONALs (the U-A rows — ride to the closeout ratify bundle; QUESTIONS.md is the merge
moment's):**
- **P-VX83-3** (VX-84a, inside D-1): the ARCHIVED facet under a tag alone brings the tag's
  archived notes into the listing, each row/card wearing a quiet "archived" mark (the sheet's
  badge word); the listing carries the sheet's archived foot. (Alternative: the facet governs
  the associated books only — rejected: the chip's own help promises notes.)
- **P-VX83-4** (VX-84a): the Blocks scope's tagged blocks are a SET answered whole (the day's
  precedent), newest edit first, each a block row "handle · in <home>" landing at the block;
  only BLOCK-level tags list a block (a note tagged at note level lists in Notes, never its
  blocks); the band counts them as "N blocks".
- **P-VX83-5** (VX-84a): a tag alone's NOTES are the post-level applications (subtree) only — a
  note whose BLOCK carries the tag is not listed in Notes (it lists in Blocks); with words, the
  shipped passage rule (note OR block tags) is untouched.
- **P-VX83-2** (VX-85, inside D-4): the NON-STEPPING arm (an unrendered take's hit) adds no reveal
  of its own, but the caret seed's reveal it inherits now rests BANDED below the bar too — the
  brief's "keeps its no-scroll behavior" read as "adds no scroll"; left plain, that arm landed
  its block flush under the bar it shows (her exact complaint, one arm over). Redirect = one line.
- **P-VX83-6** (VX-84b, inside the ratified D-2): the offer's sameness is the index's own (case
  AND diacritics — "cafe" offers `#café`), a tag is named by its LEAF (a child `life/goals` by
  "goals"), the tail offers by leaf PREFIX only while still being typed, at most THREE offers
  (exact first, shallower, then the path); the press REPLACES the naming word with `#path`
  (so a lone word becomes a tag alone → D-1's listing; beside other words it narrows the sheet).
- **P-VX83-1** (VX-86, inside D-3): a gap holding a NEWLINE ends the needle's span (the find bar
  holds one line; a newline inside a block is content, I4) — "Sherlock⏎Holmes" arms "Sherlock".

### THE SITTING RECORD — her rulings, 2026-10-07 evening (verbatim-faithful; BINDING)

- **R-VX83-1 (S-1 → VX-84, the question tool):** D-1 RATIFIED — `#tag` alone shows the
  **narrowed listing** (the tagged notes as the Library's own note rows, sort and scope
  pickers live and real, the books-flow section on top; words beside the tag keep the
  ranked sheet). D-2 RATIFIED — a plain word naming a tag **offers the tag**
  (`tag: #exampletag ›`; the click is the explicit act). Her framing on the record:
  *"i do support needing to say it's a tag explicitly"* — the fold-in alternative is
  DEAD, not deferred.
- **R-VX83-2 (S-2 → VX-87):** *"I choose direction 1 on the calendar - but make sure that
  the popover looks good and take screenshots of the app to verify the UI/UX and spacing
  of it."* → the calendar-grid popover builds; U-B's acceptance includes SCREENSHOTS of
  the real popover (both voices, light/dark, one-day and between-days) verified for
  spacing before the member closes.
- **R-VX83-3 (S-3 → VX-89):** *"I'd say add the content to the field guide now, with
  whatever information a user needs for it. It's true that 13s is handling the rewrite but
  that's happening in the background, this will probably be in early enough to be
  useful."* → VX-89 is IN the run (U-B).
- **R-VX83-4 (S-4 → U3-3):** *"I think that's fine, sounds like it's going to be handled
  by VX-73. make a note in the VX-73 plan to bring up the tradeoffs of that decision to
  make and what user choices / mitigations should be offered, given how it was built."*
  → P-13o-U3-3 RATIFIED as built; the tradeoffs note is on VX-73 (done — the ticket
  body's U3-3 rider). Reaches QUESTIONS #201 at the merge moment.
- **R-VX83-5 (VX-72 SPLIT; joins this run as U-C):** *"split VX-72 into savepoints and
  trash. do the savepoints that's easy now - and it's the most important product story
  (anything you've saved), searching stuff that *wasn't* saved and was purposefully
  deleted is a different issue. it might be better to just add a search to trash later
  than add trash to the main search."* → VX-72 re-scoped to SAVEPOINTS and made a member
  (U-C below); the Trash half is **VX-93** (Backlog, shaped as search-INSIDE-the-Trash).
- **R-VX83-6 (VX-73):** stays deferred at her word (*"I'll still defer it for now since it
  sounds like there's a significant UI component"*).
- **R-VX83-8 (2026-10-08):** *"yeah no arrow key day navigation in v1 is fine - make a
  linear ticket for that item."* → the §P1 ruling's condition (2) is RATIFIED and its
  deferral is **VX-98** (Backlog, project 13o) — it leaves the ratify bundle, decided.
- **R-VX83-9 (2026-10-08) — SUPERSEDED BY HER SAME-NIGHT REVERSAL, below:** the facet word
  `+ savepoints` was her-ratified ("accepted", after her "why not + commits?" and the
  verb/noun reading) — then, minutes later, her word: *"hmm. i take it back - do +
  commits."* → **THE FACET WORD IS `+ commits`** (armed `commits ✕`, the archived chip's
  grammar unchanged). The verb/noun and 13s-voice considerations are ON the record and
  were weighed by her; taste is hers and the newest word wins. Help texts re-word to
  match ("Include your commits — every savepoint…" → the implementer re-drafts around the
  chip's word, offered-only-with-words rule unchanged, wording rides the bundle).
- **R-VX83-7 (2026-10-07 late evening — MERGE ORDER FREED; supersedes this record's
  "merges after 13x" header line, which was also her word, earlier):** *"I told 13x to
  release its hold so you and another session can move through. you should be next in the
  queue and the current session is close to done. it's fine for you to merge to main
  before 13x - do your tests when you're granted authorization and move forward freely,
  culminating in a reinstall / handoff notes."* → first-ready merges first (the standing
  serialization rule, no special ordering); the run's closeout INCLUDES the
  `/Applications` refresh (A1 rail, zero-instance window) and the author handoff notes.
  Consequence for U-C's migration claim: if VX-83 merges first, `v1_23_savepoint_search`
  stands clean and 13x claims v1_24+ after its rebase (variorum-da notified).

### U-B — THE DESIGN MEMBERS: VX-87 (direction 1, R-VX83-2) + VX-89 (R-VX83-3); one
implementer session after U-A closes

### U-B BRIEF (self-contained; read with the whole record as ever)

**Who you are:** the U-B implementer (Opus, xhigh), ONE session, ONE acceptance unit — the
when door rebuilt to her direction-1 pick, and the field guide's finder lesson. Work ONLY
in `~/dev/variorum-vx-83` (branch `vx-83-search-followup`); pull first. Required reading:
this file WHOLE · the mockup `notes/plans/mockups/when-door.html` (direction 1 IS the
ruling) · `notes/plans/phase-13o-search.md` (R-13o-13 and the U2 RECORD's D5/P4 — what the
door replaces) · `notes/SessionResiliencyProtocol.md`. Maintain a §U-B RECORD below this
brief as LIVE STATUS from your first commit. Stage via `oct7coordinator` exactly as the
U-A stage-protocol block above says (introduce yourself as "searchfollowup U-B
implementer").

**The pieces:**
1. **VX-87 — the when door, direction 1:** the `when ▾` press opens ONE popover (the
   VoicedMenu dies): a two-mode row (on a day · between days), a real month GRID
   (`.graphical` `DatePicker` restyled through VoiceTokens, or a small custom month view
   if the system control refuses the voice treatment — PROPOSE in the record before
   building a custom grid), the armed SENTENCE at the foot ("Showing notes edited **on
   Oct 6**." / "…edited **Oct 1 – Oct 6**."), `any day` as the clearing word in the card,
   Esc/click-out keeping what the sentence last said. Nothing arms until a date is
   touched (supersedes P-13o-U2-9's arm-at-once FOR THIS DOOR — her "unclear if there's
   confirmation" is the reason; record the supersession). The armed chip in the band
   stays byte-as-shipped. Between-days: first click sets the start, second the end, the
   run washing in as she clicks (the mockup's reading). `LibraryWhenRangeTests` +
   `LibraryDayFilterTests` updated as JUSTIFIED EDITS where the door's own closures
   change; new pins for the sentence, the no-silent-arm rule, and the two-click run.
2. **VX-87 — the SCREENSHOT acceptance (R-VX83-2, binding):** real-app captures of the
   popover — both voices × light/dark, one-day and between-days — into a gitignored
   shots dir, checked for spacing/legibility BEFORE the member closes; needs a stage
   slot (request from `oct7coordinator`). The orchestrator re-walks after your close.
3. **VX-89 — the field guide teaches the finder:** functional words only (the VR-122
   seed-edit class): the Library lesson gains the finder — the one field; words rank an
   answer sheet; `#tag` alone narrows to the tagged notes (U-A's new truth — write the
   behavior as it stands at this run's close, not as 13o shipped); when ▾; the book
   masthead's 🔍; click a result to land in Write with ⌘G stepping; `+ archived`. Where
   the Library lesson lives today, matching its register; currency pins per the VR-122
   pattern (`TutorialCurrencyTests`); the REAL store's seeded field guide re-seed is the
   CLOSEOUT's (behind the A1 rail), never yours.
4. **Close:** touched Mac suites + the tutorial spine green at the END under a stage
   slot; record final; report.

**Fences:** U-A's verbatim (zero `Sync/`, zero editor-core internals, composer-only query
reads, environment traps, commit-per-piece + push, no attribution trailers).

### U-B RECORD (LIVE STATUS — the implementer maintains this from its first commit)

**U-B CLOSED (2026-10-08 00:3x) — what U-B did NOT do, first:** NO real-app captures of the rebuilt
popover (R-VX83-2's screenshots) and no walk — this host holds neither Screen Recording nor
Accessibility, so they are **PENDING-on-grant** and ride the orchestrator's walker road
(`notes/plans/fixes/vx-83-walk-brief.md`, its VX-87 appendix); the walk also owns the two items no test
here can see (Esc closing the popover, and the popover's arrow under `presentationBackground`). The
spacing evidence U-B DOES hold is headless: offscreen renders of the real popover face (see P4 — NOT her
captures). No `notes/QUESTIONS.md` entries and no canon deltas (shared ledgers — the merge moment's;
P-VX83-B1…B4 ride to the ratify bundle); zero `Sources/VariorumCore/Sync/` lines; zero lines in
`EditorTextView`/`BlockRangeIndex`/`PaneSurface`; U-C (VX-72) untouched; the REAL store's field-guide
re-seed is the closeout's (A1 rail). **Both members built and their pins GREEN: VX-87 (direction 1, the
custom grid per the §P1 ruling A) and VX-89 (the "search" lesson).** The slot: **232 tests in 27 suites
PASSED, zero skipped, `BATCH EXIT 0`, first run** (stage claimed 00:19, released 00:22, coordinator told).

**THE ORCHESTRATOR'S HEADS-UP (2026-10-07, mid-P2 — binding):** real-app SCREENSHOTS are impossible from
this host today (ClaudeCode.app holds neither Accessibility nor Screen Recording — cliclick/osascript/
screencapture hang or capture nothing; the WalkKit README's 18k rule: held for the author, never worked
around). So: build everything headless; `xcodebuild test` slots are UNAFFECTED (request a TEST-ONLY slot
from `oct7coordinator`); the R-VX83-2 captures are **PENDING-on-grant** — no capture slot is requested,
and they ride the orchestrator's walk once the grant lands. Mitigation inside U-B's own evidence (no TCC
needed): a test renders the REAL popover face offscreen (`cacheDisplay`, never shown) to PNGs in the
gitignored shots dir — both voices × light/dark × one-day/between-days — which this session checks for
spacing/legibility; they are NOT the real-app captures R-VX83-2 names, and the record will never call
them that.

**Seat:** the U-B implementer (Opus, xhigh), seated 2026-10-07 in `~/dev/variorum-vx-83` on
`vx-83-search-followup` (pulled at `84aa3292`). Required reading done in-context, never delegated:
this file WHOLE · the mockup `notes/plans/mockups/when-door.html` (direction 1 the ruling) ·
`notes/plans/phase-13o-search.md` (R-13o-13; the U2 brief + RECORD's D5/P4 and P-13o-U2-9) ·
`notes/SessionResiliencyProtocol.md` · CLAUDE.md + its canon; the code the pieces touch
(`Features/Library/LibraryDayFilter.swift` whole, `LibraryCatalogView`'s door + band sites,
`LibraryCatalogModel`'s range API, `VoicedMenu`, `VoiceTokens`, `MastheadPopover`/`QuietFill`, the
app's other date popovers) and the tests that drive the door (`LibraryWhenRangeTests`,
`LibraryDayFilterTests`); for VX-89 `TutorialSeeder` (the plan, the welcome + library-of-things +
books chapters), `TutorialCurrencyTests` (the VR-122 pattern) and `TutorialWalkTests`' shape pins.
Machinery: no deaths so far.

**THE PIECE PLAN (each piece its own commit, pushed; flipped here in the same commit):**

| # | Piece | Status |
|---|---|---|
| P0 | This record + piece plan (the first commit) | DONE (`77e6d2ea`) |
| P1 | **VX-87 — the grid FORK, measured:** can the `.graphical` `DatePicker` carry direction 1 (the two-click run washing in; the voice treatment)? Probe + the proposal below; the GRID half is built only on the orchestrator's ruling | DONE (`44a6d6f3`) — **the system control REFUSES both halves** (§P1 FORK below, measured headlessly on 27.0); the proposal (a small custom month grid) AWAITS THE ORCHESTRATOR'S RULING |
| P2 | **VX-87 — the door's brain (grid-agnostic, pure):** the mode row's meaning, the no-silent-arm rule (opening and switching modes arm nothing; only a touched day arms — supersedes P-13o-U2-9 FOR THIS DOOR), the two-click run, the SENTENCE, `any day`; one pure home + new-behavior pins (built, compiled; RUN at the slot) | DONE (`f0b53901`) — `Features/Library/LibraryWhenDoor.swift` (new; the door's file — the face moves in at P3): `LibraryWhenDoorBrain` {`mode` oneDay/between, `runStart`, `waitsForRunEnd`; `opening(range:)` — a run reopens on between days, one day or nothing on a day, NOTHING armed; `ask(_:)` — the mode row, arms nothing, forgets a waiting start; `press(_:)` — the ONE member that yields a range: on a day → that day; between → the first press arms its own day and waits, the second arms the run in order, a third begins afresh}. `LibraryDayFace.sentence(range:…)` → `Sentence {lead, emphasis, tail}` — *Showing notes edited **on Oct 6**.* / ***Oct 1 – Oct 6***, the emphasis built from the chip's own `dayWords`/`rangeWords`; nothing armed → *…**on any day**.* (PROVISIONAL **P-VX83-B1**); the foot hints `escHint` ("esc closes", the mockup's) / `runEndHint` ("now press the last day", while a run waits). The shipped door is UNTOUCHED until P3 (the app's door keeps working at every commit). Pins `LibraryWhenDoorTests` (5 — the sentence in the chip's words incl. another year; nothing arms until a day is pressed; the two-press run incl. backwards + across a month + a third press + a mode switch forgetting the start; on a day; two presses narrow the Library to the run through the model's own `setEditedRange` + `search()`) — Mac `build-for-testing` SUCCEEDED; **RUN GREEN at the slot** (5/5) |
| P3 | **VX-87 — the popover face:** the `when ▾` press opens ONE popover (the `VoicedMenu` dies); the mode row, the grid, the sentence at the foot, `any day` in the card, Esc/click-out keep the sentence; tokens only, both voices, dark; `LibraryWhenRangeTests` + `LibraryDayFilterTests` JUSTIFIED EDITS where the door's own closures change. **Built TOGETHER with P4** | DONE (`29c8c28a`) — the door MOVED to `LibraryWhenDoor.swift` (the old menu + date-field popover + `openOnToday`/`openBetween`/`dayBinding`/`fromBinding`/`toBinding` + `fieldWidth` DELETED from `LibraryDayFilter.swift`): `LibraryWhenDoor` — at rest the 13o `VoicedMenu` label byte-for-byte in face (`when ▾`, the small face, ink, the hover wash); its press runs `openingState(range:today:)` (the brain in the armed state's mode + the month to show — NOTHING reaches `onPick`) and shows ONE `.popover`; the band's chip untouched; `LibraryCatalogView`'s call site untouched (same init). `LibraryWhenPopover` — the acts as members (`press` · `ask` · `step` · `clear`, what its cells / mode row / ‹ › / `any day` run); the face: the mode row (two quiet-fill segments in a hairline box, the chosen one `QuietFill.chosen` + semibold), the grid, a hairline, the SENTENCE (lead muted, armed words ink + strongly-emphasized, glued with no-break spaces + a word joiner after the run's dash so a run never splits; a hidden two-line semibold strut keeps the card's height constant), and `LibraryWhenFoot` (`any day` in the accent while armed, faint + disabled when not — P-2; the hint `esc closes` / `then the last day`); `presentationBackground(tokens.surface)`; one fixed width (the grid + 2 × 14). Words: `LibraryDayFace.onADay`/`betweenDays` lose the retired menu's ellipses (the mode row's words, the mockup's), `onWord`/`fromWord`/`toWord` die, the VoiceOver words join (`previousMonth` … `spokenToday`). **JUSTIFIED EDITS (each labelled in place):** `LibraryDayFilterTests` — `theFieldsValueReachesTheQuery` drives the popover's `press` (a cell, not a field); `openingTheClosedDoorPicksToday` → **`openingTheClosedDoorShowsTodaysMonthAndArmsNothing`** (the shipped pin pinned the arm-at-once P-13o-U2-9 — her report names that as the silent arming, R-VX83-2 supersedes it FOR THIS DOOR: opening shows today's month and arms nothing, today arms when pressed); `theClearDoorReturnsTheWholeLibrary` drives `clear()`. `LibraryWhenRangeTests` — `betweenDaysArmsAndEachEndCarriesTheOtherAlong` → **`betweenDaysTwoPressesMakeTheRunAndNeverAnEmptyOne`** (the subject — the door's own acts make a run, never an empty one — through `ask`/`press`); `aRangeWithNoWordsIsTheWholeSetOfItsDays` arms by two presses; `theChipAndTheEmptyAnswerSayTheRun`'s wording cell reads the mode row's words. Mac `build` + `build-for-testing` SUCCEEDED; **RUN GREEN at the slot** (the six edited pins, in `LibraryDayFilterTests` + `LibraryWhenRangeTests` whole) |
| P4 | **VX-87 — the month GRID** (per the ruling: A, with its four conditions) + the face's geometry pins + the spacing renders | DONE (`29c8c28a`) — `Features/Library/LibraryWhenMonthGrid.swift` (new). **The pure rules (condition 3):** `LibraryWhenMonth` (normalized; `opening(range:today:)` = the armed run's FIRST day's month, else today's), `LibraryWhenGrid.cells(of:firstWeekday:calendar:)` (42 cells, SIX fixed rows, from the week-start on/before the 1st in HER week order, neighbours' days `inMonth: false`, each day stepped from NOON so no DST change doubles/skips one), `weekdayInitials` (the locale's very-short standalone symbols, her order), `monthTitle`, `mark(_:in:)` (single · runStart · runEnd · inRun · none), and **`spoken(...)` — the HAND-WRITTEN VoiceOver words (condition 1, at this landing):** the full date (*Tuesday, October 6, 2026*) + the standing (*chosen day* / *first day of the run* / *last day of the run* / *in the run*, *today*) + the selected trait on every armed day; the month steps say *Previous/Next month*; the weekday row is hidden from VoiceOver (each cell says its weekday). **Keys** are `LibraryDayFace.calendar`'s, the **display week order** `Calendar.current.firstWeekday` (condition 4). **The face:** 32 × 26 cells edge to edge; the armed day / the run's two ends on `QuietFill.chosen` over the card's own paper (so the band never shows through as a two-tone cell); the days BETWEEN on `QuietFill.rest` — the strip's chip-at-rest fill — as one band per row reaching into the ends from the inner side (a REFINEMENT of the proposal's "tokens.wash", measured: Study's wash IS an accent tint, so a wash band read the same tone as the ends); today's digit the accent, semibold; hover = the wash; ‹ › quiet SF chevrons with the `VoicedMenu` hover. **Pins** (`LibraryWhenDoorTests`, now 12): the layout (Oct 2026 Monday-first starts Mon Sep 28 — the mockup's own first row; Sunday-first Sep 27; a bad week start reads Sunday; the initials; the title; February's six rows) · every day once across BOTH 2026 DST changes in America/Denver · month normalization + the opening month · the marks · **every cell's spoken words** · the popover's own road (open → `ask`/`step` arm nothing → two presses arm the day then the run → `clear` clears and forgets the waiting start) · **the face's geometry in all four rooms** (ImageRenderer: ONE width and ONE height across nothing / one day / a run / a run waiting — the six rows + the strut; the foot and each mode word measured on their own against the fixed width, because a fixed-width card CLIPS an overflow rather than growing). **THE SPACING RENDERS (the heads-up's mitigation — NOT the R-VX83-2 captures):** a gitignored scratch package (`.build/vx83-ub/renderpkg`, symlinking the six real source files, building against the repo's own VariorumCore — no stage, no screen) rendered the REAL popover face offscreen, 4 rooms × 4 states = 16 PNGs, copied to the gitignored `App/Variorum/DerivedData/vx83-shots/headless/`. Checked by this session over FOUR rounds, each finding fixed before this commit: r1 — the Terminal sentence split a run across lines ("oct 1 –⏎oct 6") and "on⏎any day"; the waiting hint ("now press the last day", 22 letters) OVERFLOWED Terminal's card and pushed the content off-centre; the run's ends showed a two-tone seam; `reservesSpace` measured 2 pt short (one height 364 vs 366); r2 — no-break spaces still broke after the dash; r3 — Study's ends and band one tone; r4 — CLEAN: all 16 at 276 × 366 pt, the run reads as one stroke with distinct ends in both voices, the sentence wraps whole, the hint fits with air. Mac `build-for-testing` SUCCEEDED; **RUN GREEN at the slot** — `LibraryWhenDoorTests` 12/12 incl. the four-room geometry test (its in-host PNGs land in the sandboxed container's tmp, which this host may not read — TCC — so the scratch package's renders of the SAME source are the spacing evidence) |
| P5 | **VX-89 — the field guide teaches the finder** (functional words, the VR-122 seed-edit class) + currency pins in `TutorialCurrencyTests` | DONE (`767a960a`) — **a NEW lesson "search"** (`TutorialSeeder.searchLessonTitle`) in "the library of things", right after "comments & tags" (the tags it leans on) — PROVISIONAL **P-VX83-B2** (the brief's "the Library lesson" does not exist as such: the Library is introduced in one clause of "getting around", whose welcome-map register would not hold seven paragraphs; a lesson in the chapter named for the Library keeps the guide's one-lesson-per-thing grain, and a self-contained addition is the cheapest seam beside 13s's background rewrite). Seven paragraphs, functional words, the finder AS IT STANDS AT THIS RUN'S CLOSE: the one field (every take, titles, snippets, comments, names, labels; case + accents fold) · the answer sheet (the band's counts, the `in: Home` chip — one wing, snippets from every wing — books first, notes best-first with ≤3 lines, `all N ›`) · land-at-match in Write with ⌘G / ⇧⌘G and the `in another take` arm · `#tag` ALONE narrows to the tagged notes as the Library's own rows (sort ▾ live, the subtree, books it flows into on top — VX-84a), words beside a tag narrow the search, the `tag: #name ›` offer (VX-84b) · `when ▾` per direction 1 (on a day · between days · the run fills in · the sentence is the confirmation · nothing changes until a day is clicked · Esc/click-out keep it · any day / the chip's ✕ clear · the one-stamp caveat) · `+ archived` · the book masthead's 🔍 · ⌘K's passages + `All matches in the Library ›` · a PRACTICE paragraph (the practice word `marginalia`, carried twice; then `#tutorial` alone). Savepoints and the Trash are deliberately NOT mentioned (U-C/VX-72 may change the first — WATCH: if U-C ships the savepoint facet, this lesson gains its sentence). Pins (`TutorialCurrencyTests`, the H pattern — prose plain, each door from its own home): `theSearchLessonFollowsTheTagsItLeansOn` · `theSearchLessonNamesEveryFinderDoorByItsOwnWord` (the field's literal scanned, `allLines`, `wingChip(WingWords.home)`, `inAnotherTake`, the REGISTRY's `findNext`/`findPrevious` chords, `tagOffer`, `when ▾`, the mode words + `anyDay`, `LibraryDayFace.sentence(...)`'s own text, `archivedOff`, the masthead's `magnifyingglass` scanned, `CommandPaletteCopy.allMatches`) · `theSearchLessonsPracticeHoldsOnTheGuideItself` (P-6: `marginalia` answers with this lesson ALONE, its line's find seed is the word STEPPING, the paragraph holds it twice; `#tutorial` alone lists every plan lesson through VX-84a's listing, paged to the end, nothing listed without the tag). RED on the pre-VX-89 seed by construction (no such lesson — `prose` throws). **KNOWN INTERIM RED:** the mode-word cells read `LibraryDayFace.onADay`/`betweenDays`, which still carry the retired menu's ellipses until P3 lands direction 1's mode row — so `theSearchLessonNamesEveryFinderDoorByItsOwnWord` is red at THIS commit by design and goes green with P3 (no slot runs before P3). Mac `build-for-testing` SUCCEEDED; **RUN GREEN at the slot** — all three, the door-words cell (red by design at `767a960a`) GREEN now that P3's mode words landed; the tutorial spine + `TutorialBooksLessonTests`/`RitualTests` + `LaunchFurnitureTests` green with the new lesson in the plan. The REAL store's guide re-seed is the CLOSEOUT's (A1 rail), never U-B's |
| P6 | **The TEST-ONLY stage slot** (via `oct7coordinator`): the batch (`.build/vx83-ub/run-ub-suites.sh`, `test-without-building`, suite-level): `LibraryWhenDoorTests` · `LibraryWhenRangeTests` · `LibraryDayFilterTests` · `TutorialCurrencyTests` · the tutorial spine's eleven (`TutorialBookShapeTests` … `TutorialFannedMatrixTests`) + `TutorialBooksLessonTests` · `TutorialBooksRitualTests` (the books chapter's file) · `TutorialBuildFlavorTests` · `LaunchFurnitureTests` (plan-derived) · the touched Library suites (`LibrarySearchJoinTests` · `LibraryTagListingTests` · `LibrarySearchStateTests` · `LibrarySearchFaceTests` · `LibraryPagingModelTests` · `LibraryViewScopeSwitchTests`) · `ChromeLineLimitTests` (the P-8 scan over the new views) · `CapabilityRegistryTests`. The R-VX83-2 REAL-APP captures (both voices × light/dark × one-day/between-days, `App/Variorum/DerivedData/vx83-shots/`) are **PENDING-on-grant** (the heads-up above) — never requested from this host; Esc-closes and the popover's arrow in `presentationBackground` are WALK items for the same grant | DONE (2026-10-08) — the coordinator's GO; claimed `searchfollowup` 00:19 → RELEASED 00:22, coordinator messaged (msg 5e540ab5); no Variorum instance at any point (checked by path); `/Applications` untouched. **232 tests in 27 suites PASSED, zero skipped, `BATCH EXIT 0`, first run** — every U-B pin by name in the log (the 12 + 3 new, the 6 edited, `theSeededBookMatchesTheLessonPlanExactly`) |
| P7 | Close — record final, self-assessment, report | DONE (this commit) |

PENDING flags: ONE — the R-VX83-2 real-app captures (both voices × light/dark × one-day/between-days)
+ the walk items (Esc closes; the arrow's colour), PENDING-on-grant, the walker road's. Every pin claim
above is RUN and GREEN.

**PROVISIONALs (the U-B rows — ride to the closeout ratify bundle; QUESTIONS.md is the merge moment's):**
- **P-VX83-B1** (VX-87): with nothing armed the sentence reads *Showing notes edited **on any day**.* (the
  clearing word's own state); the foot's hint reads *esc closes* at rest and *then the last day* while a
  run waits.
- **P-VX83-B2** (VX-89): the finder's lesson is a NEW lesson "search" in "the library of things", after
  "comments & tags" (no "Library lesson" exists to extend).
- **P-VX83-B3** (VX-87, the ruling's condition 2): NO arrow-key day navigation in the grid at this
  landing (the system picker had it); a later polish at her word.
- **P-VX83-B4** (VX-87, inside direction 1): between days the FIRST press arms its own day (so Esc right
  after keeps exactly what the sentence says) and a third press begins a fresh run; the popover opens on
  the armed run's FIRST day's month (else today's); a neighbouring month's faint day is pressable and
  arms without flipping the month; the run's band is the strip's at-rest fill (`QuietFill.rest`), its
  ends the chosen fill; today's digit is the accent.
- **The supersession, recorded:** P-13o-U2-9 (choosing a day mode arms today at once) is superseded FOR
  THE WHEN DOOR by R-VX83-2 + her report ("very unclear if there's confirmation") — nothing arms until a
  day is pressed.

**§P1 FORK — the `.graphical` `DatePicker` against direction 1, MEASURED (2026-10-07; two headless
external-fact probes — an offscreen `NSHostingView`/`NSView` rendered to PNG, never shown, no store;
scripts and renders in the gitignored `.build/vx83-ub/`):**
1. **SwiftUI's picker has no range on the Mac.** `DatePicker` binds ONE `Date`; `MultiDatePicker` is
   `@available(macOS, unavailable)` in the 27.0 SDK's SwiftUI interface. So direction 1's
   between-days reading — *first click sets the start, second the end, the run washing in* — cannot be
   drawn by it: after the second click the picker shows the end alone, no start, no run.
2. **It takes NO voice treatment.** The `.graphical` picker rendered with `.font(mono 11.5)` +
   `.foregroundStyle(ink)` + `.tint(accent)` + `.accentColor(accent)` is PIXEL-IDENTICAL to the plain
   one, light and dark: SF 13 with a bold "Oct 2026" header, the ◀ ● ▶ nav, a system-grey selection,
   a system-BLUE today, its own bezel box (a dark-grey box on the fully black room, R51), Sunday-first.
   The `NSDatePicker` underneath reports `font` SF 13 / `textColor` controlTextColor /
   `backgroundColor` controlBackgroundColor.
3. **The AppKit bridge, tried directly** (`NSDatePicker`, `.clockAndCalendar`, `datePickerMode =
   .range`, `timeInterval` = 5 days): range mode DOES draw a run (Oct 1–6 banded), and
   `backgroundColor`/`drawsBackground`/bezel take — but `font` (mono 11.5) and `textColor` are
   IGNORED, the run band is system grey, today stays system blue. Its native gesture is a DRAG, so the
   two-click reading would be an intercept in its action handler.

**THE PROPOSAL (awaiting the orchestrator's ruling — nothing of the grid is built):**
- **(A) RECOMMENDED — a small custom month grid**, `LibraryWhenMonthGrid` (its own file beside
  `LibraryDayFilter.swift`, P-9; ~150 lines), drawn ENTIRELY from `VoiceTokens`: a header `‹ October
  2026 ›` (the voice's small face, ink; the chevrons muted with the `VoicedMenu` hover wash); weekday
  initials in `faint`; a FIXED six-row 7-column grid (the popover never changes height between months);
  day digits in `tokens.small` (monospaced in Terminal by the token itself); outside-month days faint;
  the armed day / the run's two ENDS on `QuietFill.chosen` (the app's one "this one" fill, VR-119),
  the days BETWEEN on `tokens.wash` as one continuous band; today's digit in `accent`, semibold;
  dark = the voice's dark tokens on the popover's own surface (no system box). Day arithmetic in
  `LibraryDayFace.calendar` (Gregorian, her zone — the filter's one calendar); the COLUMN order follows
  her own first weekday (`Calendar.current.firstWeekday`, so Monday-first users get the mockup's row).
  **Every cell's press is ONE member closure (`tap(day:)`)**, so the two-click-run pin drives the door's
  own road (the 18h ladder's R1-9) — no system calendar's cell can be driven by a pin. Costs, said
  plainly: no arrow-key day navigation in v1 (the system picker has it — a later polish if she wants
  it); VoiceOver gets a per-cell label ("Tuesday, October 6, 2026") + the selected trait by hand.
- **(B) the AppKit bridge** — `NSViewRepresentable` over `NSDatePicker` in `.range` mode with a
  two-click intercept: keyboard + VoiceOver for free; but the grid would be the ONE un-voiced surface in
  the popover (system SF 13 + bold header, grey run, blue today, Sunday-first by locale) — exactly the
  "ugly" she reported and the R-VX83-2 screenshot bar ("make sure that the popover looks good") — and the
  pins could drive only the bridge's action handler, never a cell.
- **(C) the SwiftUI `.graphical` picker** — DEAD for direction 1 by measurement (1): no run, no wash.

What builds meanwhile (grid-agnostic, so it holds under A or B): P2 (the door's brain + pins), P3 (the
popover's shell around a grid slot), P5 (VX-89).

> **§P1 FORK — RULED: A, the custom month grid** (the orchestrator, 2026-10-07 — binding; P3/P4
> build to this). The measurement is decisive and the brief anticipated exactly this road ("or a
> small custom month view if the system control refuses the voice treatment"): the SwiftUI picker
> CANNOT draw direction 1's run at all (no range on macOS), and both system controls refuse the
> voice — B would seat a system-grey, system-blue, SF-13 calendar inside the popover she already
> called ugly, failing R-VX83-2's own bar ("make sure that the popover looks good") by
> construction. A's costs are accepted AS CONDITIONS, not waived: (1) VoiceOver per-cell labels
> are MANDATORY at this landing (the full day words + selected/in-range/today traits, hand-written
> — never deferred to VX-59's someday sweep); (2) the no-arrow-key gap is recorded as a named
> PROVISIONAL for the ratify bundle (a later polish at her word, the proposal's own framing);
> (3) the month-layout arithmetic (six fixed rows, her first weekday's column order, outside-month
> days, the run band's membership) is a PURE rule with its own little tests, cells driving
> `tap(day:)` so the two-click pin walks the door's road (R1-9's letter, as proposed); (4) day
> KEYS stay `LibraryDayFace.calendar`'s (Gregorian, her zone) with the DISPLAY week order hers —
> exactly as proposed. P-VX83-B1 (the nothing-armed sentence) and P-VX83-B2 (the lesson's seat)
> stand as provisionals for the bundle; the P2 brain and P5 lesson are accepted as recorded, the
> deliberately-red currency cell legal mid-unit and green by close. — the architect

**SELF-ASSESSMENT (the implementer's, before the cold review):** the door is now one surface whose every
act is a member a pin drives; the only way to arm is a pressed day (structural — `opening`, `ask` and
`step` cannot reach `onPick`), and the sentence reads the model's armed range, so it and the band's chip
cannot disagree. The grid's arithmetic is pure and covered (week order, six rows, both 2026 DST changes,
normalization, marks, spoken words). What I trust least: (1) the REAL popover chrome — `.popover` on
macOS 27 with `presentationBackground`, Esc, focus — no headless render shows the system's arrow or key
handling (the walk is the arbiter); (2) the popover's content refreshing as `range` changes WHILE OPEN
(the door passes `range` into the popover's content closure; SwiftUI re-renders presented content with
its presenter — the walk confirms the band and the sentence update under the hand); (3) the Terminal run
band (`QuietFill.rest`) is faint by the strip's own language — her eyes may want it stronger.
**WATCH ITEMS for the ladder:** (a) the four JUSTIFIED EDITS' subjects, especially
`openingTheClosedDoorShowsTodaysMonthAndArmsNothing` — it reverses the shipped pin's assertion
(P-13o-U2-9 superseded for this door, recorded); (b) `LibraryWhenDoor`'s `month` binding falls back to
the opening month (then a fixed 2026-01) if the `@State` is nil — reached only before the first press of
the door; (c) the sentence's no-break spaces + word joiner are FACE-only (`Sentence.emphasis` stays
plain, so the chip-equality pin holds); (d) the face renders: the in-host test asserts geometry, while
the PNGs a human looked at came from the scratch package (same six source files, symlinked); (e)
`TutorialSeeder.plan` grew one lesson — every plan-derived pin reads it, and the mobile seeder is
independent (no parity rule); (f) if U-C ships the savepoint facet, the "search" lesson needs its
sentence.

### U-C — SEARCH WHAT YOU SAVED: VX-72 (R-VX83-5); one implementer session after U-B

### U-C BRIEF (self-contained)

**Who you are:** the U-C implementer (Opus, xhigh), ONE session, ONE acceptance unit —
savepoint history joins the index behind an explicit facet. Work ONLY in
`~/dev/variorum-vx-83`; pull first. Required reading: this file WHOLE ·
`notes/plans/phase-13o-search.md` (§FORK RULINGS F1–F4, the §R-13o-4 RECORD, U1's
trigger/migration shape — you EXTEND that design, never reshape it) · `notes/SyncSpec.md`
§12 far enough to confirm the local-only class · `notes/SessionResiliencyProtocol.md`.
Maintain a §U-C RECORD below as LIVE STATUS. Stage via `oct7coordinator` ("searchfollowup
U-C implementer").

**The pieces:**
1. **Migration (its own commit, before consumers):** `savepoint` joins `SearchIndex` as
   the NINTH kind — `commit_point.text`, a doc row live iff the commit's VARIANT is live
   (commit_point has no tombstone of its own; the variant's tombstone/delete reach drops
   savepoint docs — doc-family reads only, R-13o-4's letter), backfill via the rebuild
   road. **Migration id: claim `v1_23_savepoint_search`** — 13x's branch carries no
   migration past v1_22 at its closeout (verified 2026-10-07 by the orchestrator); IF
   13x's merge lands a v1_23 first, rename ours to the next free id at the rebase and
   reset the WORKTREE dev store only (the contained collision class, R-13o-5's record).
   Record the outcome here.
2. **Capture:** INSERT-only capture on `commit_point` (savepoints are append-only, I5;
   `renameCommitPoint` edits `message`, which is NOT indexed — only `text` is) + the
   variant-reach drop above. Mechanical only; the §R-13o-4 record's letter holds (no
   reads outside NEW/OLD + the doc family). If honoring it needs a shape the letter
   can't give you, STOP and report (the §9 smell protocol, never a clever trigger).
3. **Visibility:** savepoint docs are OUT of every default answer by composer fence
   (R-13o-6's ruled posture), IN only under the explicit facet. The versions fence and
   wing scoping resolve at query time through variant → block → placement (the take
   docs' own road; a savepoint of a released block never lists — P-13o-U1-8's letter).
4. **The facet face:** the band grows a quiet invitation beside `+ archived` — PROPOSE
   the word in the record (candidates: "+ saved versions" · "+ savepoints" · "+ history")
   before building the chip; a savepoint passage wears its kind word + its savepoint's
   day (`TimeStampFace.day`) and lands at its block with the find bar ARMED NOT STEPPING
   when the text is no longer in the buffer (P-13o-U2-4's arm exactly). ⌘K stays
   savepoint-free (quick-jump is the living corpus; the Library facet is the history
   door) — PROVISIONAL.
5. **Pins:** capture across the write layers (operations commit · the variant-reach
   drop · fake-server remote apply of a commit_point row — red-on-old each, the U1 P6
   pattern); rebuild/integrity cover the ninth kind; the default-answer fence (a
   savepoint NEVER lists without the facet — the unit's most load-bearing pin); facet
   listing + landing; P1: capture cost ∝ the commit, query cost ∝ matches (extend
   `SearchP1Tests`' corpus with savepoint rows).
6. **Close:** full core suite + touched Mac suites + tutorial spine green at the END;
   record final; report.

**Fences:** U-A's verbatim. One addition: the completeness walk must stay green WITHOUT
`Sync/` edits (the derived set reads `SearchIndex.tables` — one source; if the walk goes
red anyway, STOP and report: `Sync/` is the orchestrator's).

### U-C RECORD (LIVE STATUS — the implementer maintains this from its first commit)

**LIVE STATUS (2026-10-08): BUILDING — the rulings landed (§U-C RULINGS below: FORK 1 = A with five
binding conditions; PROPOSAL 2 = `+ savepoints`, then SUPERSEDED by her same-night reversal to
**`+ commits`** — R-VX83-9, the chip is built under that word from the start); P1 (the migration)
DONE; P2 DONE (probes red-on-old, restored); P3 (the composer) next. No revert is in flight.**

**Seat:** the U-C implementer (Opus, xhigh), seated 2026-10-08 in `~/dev/variorum-vx-83` on
`vx-83-search-followup` (pulled at `abe4b192`). Required reading done in-context, never delegated:
this file WHOLE · `notes/plans/phase-13o-search.md` (the sitting record R-13o-1…15, the U1 brief +
RECORD incl. §FORK + §FORK RULINGS F1–F4, SEAM 2, the §R-13o-4 RECORD) · `notes/SyncSpec.md` §3, §6,
§7 and §12 (the LOCAL-ONLY class confirmed: v1_23 adds a column to the DERIVED `search_doc`, a view
arm, and triggers that write only the derived family — no synced column, no mirror, no marker
move; the E2EE classification walk covers synced tables only; the completeness walk is table-level
and the family adds no table) · `notes/SessionResiliencyProtocol.md` · CLAUDE.md + its canon. The
code: `Persistence/SearchIndex.swift` whole, `Domain/SearchComposer.swift` whole,
`Queries/SearchQueries.swift` whole, `Domain/SearchQuery.swift`, `SearchQueryParser`, `v1_22` in
`Migrations.swift`, the janitor's savepoint pruning + `PurgeFamily` (commit_point rows ARE
physically deleted — pruning and family purges), `renameCommitPoint` (a whole-row record update),
`SearchIndexCaptureTests`, `SearchP1Tests`, `SyncSchemaTests`' walk; Mac: `LibrarySearchModel`,
`LibrarySearchBand`, `LibrarySearchCopy`, `SearchAnswerFaces`, `SearchLanding`,
`EditorViewModel.applyFindSeed`. Machinery: no deaths so far.

**Migration id: `v1_23_savepoint_search` is CONFIRMED OURS outright** (the orchestrator's fact,
2026-10-08: 13x mints zero migrations — no rename fallback needed).

**THE PIECE PLAN (each piece its own commit, pushed; flipped here in the same commit):**

| # | Piece | Status |
|---|---|---|
| P0 | This record + the two proposals (the first commit) | DONE (`ec9cbc6f`) — RULED at `d9da0027` (§U-C RULINGS) |
| P1 | **Migration `v1_23_savepoint_search` ALONE** (FORK 1 = A): `search_doc.variant_id` (the savepoint doc's own-row parent fact), the `search_text` view recreated with the NINTH arm, the `savepoint` capture triggers on `commit_point`, the backfill by the rebuild road; `v1_22` FROZEN on its own eight-kind list (its DDL proved byte-identical before/after); MigrationTests + the capture-set pin's justified edits | DONE (this commit) — `Persistence/SearchIndex.swift`: `Source` gains `tombstoned` (default true) with ONE `live(_:)` existence rule and `watchedColumns` (the eight kinds' SQL byte-unchanged); the kind lists split FROZEN — `sourcesV1_22` (the eight, read by `create`/`v1_22` alone) and `sourcesV1_23` (+ `savepoint`: `commit_point.text`, fact `variant_id`, no tombstone — doc ⇔ the physical ROW); `sources` = the current family (the rebuild door, the integrity check); `addSavepoints` (v1_23: `ALTER TABLE search_doc ADD COLUMN variant_id TEXT`, the view dropped + recreated with the ninth arm — FTS5 reads its content by NAME, the virtual table untouched — and the savepoint's three triggers from the ONE generator); `rebuild(_:sources:)`; the integrity check reads each kind's existence rule (condition 3: a dead take's savepoint docs are CORRECT, never drift) and `variant_id` joins the fact-drift columns. `Migrations.swift`: `v1_22` rebuilds over `sourcesV1_22` (frozen), `v1_23_savepoint_search` = `addSavepoints` + `rebuild(sourcesV1_23)`. `SearchDocKind.savepoint` (the stored vocabulary's mirror, its pin `SearchGroupsTests` green). **THE FREEZE, PROVED:** a scratch dump (`sqlite_master`, every object's type/name/table/SQL; the scratch test never committed, dumps in the gitignored `.build/vx83-uc/`) of a store migrated `upTo: v1_22` on the pre-change tree and on this one — **`cmp` IDENTICAL**; at HEAD the diff is EXACTLY the `variant_id` column, the three `search_commit_point_savepoint_*` triggers and the view's ninth arm. The triggers (INSERT · UPDATE OF `text, variant_id` · DELETE) read NEW/OLD and `search_doc` only. **Purge coordination is correct by construction (condition 1):** the janitor's prune/purge physically DELETEs `commit_point` rows, and each row's own DELETE arm retires its doc and its FTS entry in the same statement. Pins: NEW `MigrationTests.theSavepointKindBackfillsAStoreThatAlreadyHoldsSavepoints` (a v1_22 store's savepoints — one under a TOMBSTONED take — all findable after migrating, accents folded, each with its own parent fact only, the eight kinds re-derived, FTS5 integrity-check passes; red on the pre-VX-72 tree by construction); JUSTIFIED EDIT `SearchIndexCaptureTests.theCaptureTriggerSetIsExactlyThreePerSourceField` (24 → 27; the mechanical-only check made SOURCE-AWARE — it refuses every schema table but the trigger's own source and the derived family; its old fixed list named `commit_point`, now a source). **Full core `swift test`: 2,305 tests in 263 suites PASSED** (the standing skips only) + StringsWorkbook 40/6; the completeness walk GREEN with zero `Sync/` lines |
| P2 | Capture pins across the write layers (operations commit · the variant reach · fake-server remote apply · the janitor's physical delete) red-on-old by revert; rebuild + integrity cover the ninth kind | DONE (`5f77a34e`; probes recorded at this commit) — `SearchSavepointCaptureTests` 6/6 GREEN: every savepoint road (⌘S · `closeAutoCommit` · lock-a-dirty-take · restore · a rename writing NOTHING to the index, fingerprinted over `search_fts_data` + `search_doc`), a dead take's savepoints LINGER and read HEALTHY through `deleteVariant` / `deleteBlock` / Put back (condition 3), the fake server (a remote savepoint indexed; a remote RENAME's whole-row UPDATE costs the index nothing; ARRIVAL ORDER — a savepoint landing under a take the phone holds dead is indexed), the janitor (a commit_point PRUNE root and a block FAMILY purge through `PurgeFamily.expand/deleteLocal` — docs + FTS entries retired, healthy), the UPDATE arm (a same-values remote rewrite = 1 change; a text rewrite followed in the same statement), the rebuild + the integrity check's three nets on the ninth kind. **REVERT PROBES (each dropped ONE savepoint trigger right after `addSavepoints` created it, ran `SearchSavepointCaptureTests` + the v1_23 backfill pin, restored by `git checkout --`; tree re-verified 6/6 green, `git status` clean):** no INSERT trigger → **RED 29 issues across all 6 tests** (operations, reach, remote apply incl. arrival order, janitor, UPDATE arm, rebuild/integrity — the backfill pin stays GREEN, rightly: it rides the rebuild road, not a trigger); no DELETE trigger → **RED 6 issues, the janitor pin alone**; no UPDATE trigger → **RED 3 issues, the UPDATE arm's text-rewrite cell alone** (its same-values cell stays green, rightly — the guard's work there is zero either way) |
| P3 | The facet in the AST + the ONE composer + `Queries` (the default-answer FENCE; the facet's road through variant → block → placement); core pins incl. the fence (with a sensitivity probe: a leaking default statement turns it red) | NOT-STARTED |
| P4 | P1 numbers: capture ∝ the commit; queries ∝ matches with savepoint rows in `SearchP1Tests`' corpus; the DEFAULT road's cost with savepoints in the shared index, measured and recorded | NOT-STARTED |
| P5 | Mac: the question/model carry the facet; the band's chip (the PROPOSAL 2 word); the savepoint line (kind word + day); the landing seed; pins | NOT-STARTED — the chip gated on PROPOSAL 2 |
| P6 | U-B's rider: the field guide's "search" lesson gains ONE sentence for the facet + its currency pin | NOT-STARTED |
| P7 | The test-only stage slot (via `oct7coordinator`): touched Mac suites + the tutorial spine | NOT-STARTED |
| P8 | Close: full core suite at the END, record final, report | NOT-STARTED |

PENDING flags: none (nothing claimed yet).

#### §U-C FORK 1 — the variant-reach drop, TRACED and PROBED: the brief's mechanism cannot be built within R-13o-4's letter

The brief (piece 1–2): *"a doc row live iff the commit's VARIANT is live … the variant's
tombstone/delete reach drops savepoint docs — doc-family reads only"* — and *"If honoring it needs
a shape the letter can't give you, STOP and report."* It does need one, in three places:

1. **The DROP direction needs `commit_point.text`.** Under F1 (V — external content over the
   `search_text` view; the doc row holds ids only), retiring an FTS entry means handing FTS5's
   `'delete'` the text AS IT WAS INDEXED (every shipped trigger passes `OLD.<col>` — F1's adopted
   contract). A variant trigger's NEW/OLD are the VARIANT's; the savepoint's text lives only in
   `commit_point`. **Probe** (system sqlite3 3.54.0, the family's own shape — `search_doc` ids-only,
   the view over the source, FTS5 external content, `unicode61 remove_diacritics 2`; scratch in
   `/tmp`, nothing in the repo): a doc-family-only drop (doc deleted, `'delete'` handed NULL) leaves
   "harbor" still MATCHing the dropped rowid, and `integrity-check` answers `database disk image is
   malformed` (SQLITE_CORRUPT). Reading the text through `search_text` instead reads
   `commit_point` inside a variant trigger — the clever trigger the letter exists to refuse.
2. **The REVIVAL direction needs a `commit_point` read.** `restoreBlock`/`restoreContainer` revive
   variants on their exact stamp (and a remote apply revives too); a dropped savepoint must come
   back, which means `SELECT … FROM commit_point WHERE variant_id = NEW.id` inside the variant
   trigger. Without it a Put-back note's savepoints would vanish from search until a rebuild.
3. **Arrival order.** A remote apply can land a `commit_point` row under a variant this device
   already holds dead, or before the variant arrives; the commit_point INSERT trigger cannot see the
   variant without a read — exactly the arrival-order surface F3 refused for S2.

**The options:**

- **(A) RECOMMENDED — the savepoint's liveness resolves at QUERY time: F3's own road.** The doc
  mirrors its `commit_point` ROW only — capture on INSERT (the append, I5); on DELETE (the
  janitor's physical prune/purge — required: an un-retired entry is exactly the probe's corrupt
  index); and an UPDATE arm watching `text`/`variant_id`, inert by I5 (a rename writes the whole
  row, but `message` is unwatched and the WHEN guard holds it at zero work — kept for F1's
  every-text-write contract, the shipped generator's one shape) — carrying the row's OWN parent fact,
  `variant_id` (a new nullable `search_doc` column, the doc's own-row fact exactly as `block_id` is
  a take's). **No variant-side trigger at all.** The composer — ONLY under the facet — seeks the
  savepoint's variant by PK (`deleted_at IS NULL`), reaches the block through `variant.block_id` and
  the I2 placement, and from there it is the take docs' own road: home, wing, the archived facet,
  the versions fence, a released block never listing (P-13o-U1-8). "Live iff the variant is live"
  then holds as a LISTING fact at every arrival order and across Put back with zero machinery; the
  index keeps a dead take's savepoints until the janitor purges them (the released block's
  precedent — indexed, never listed). Cost: one variant PK seek per savepoint MATCH, facet only
  (∝ matches). The integrity check's expected set = every `commit_point` row.
- **(B) the brief as written** — a variant trigger dropping (and, for Put back, re-adding)
  savepoint docs: needs `commit_point` reads in both directions — outside R-13o-4's letter, the §9
  smell, hers to decide. Not recommended.
- **(C) a liveness FACT on the savepoint doc, flipped by the variant trigger** (doc-family-only
  writes) — honors the letter for the flip, but item 3 still births a doc "live" under a dead
  variant, so the composer must check the variant anyway: a redundant second truth to drift. Not
  recommended.

**A consequence to record, not a fork (F2 rules the ninth kind into the SHARED index):** every
DEFAULT question's FTS walk now also meets the savepoint postings and fences them at the doc row —
one rowid seek each, before any home lookup (the fence is evaluated at the doc's loop level) — and
bm25's corpus statistics count them. The cost CLASS is unchanged (∝ the index's matches); the
numbers land at P4. If they show the living road materially slower, I stop and report there.

#### §U-C PROPOSAL 2 — the facet's WORD (before the chip is built)

**Recommended: `+ savepoints`** (armed: `savepoints` with its ✕ — the `+ archived` grammar).
- It is the app's own user-facing noun for exactly these rows: Settings' "Savepoints" pane, the
  commit receipt ("an immutable savepoint of this take"), the day filter's own empty answer ("No
  note's last edit or savepoint falls on …"), Block History, the field guide ("⌘S keeps
  savepoints"). The finder would find what every other surface calls a savepoint.
- **"+ saved versions" COLLIDES with Note ▸ Versions** (`saveNoteVersion` — whole-note saved
  versions, which search FENCES under every facet, the ruled posture): the chip would name the one
  thing it never shows.
- **"+ history" is vague in two directions**: it reaches toward the Trash (VX-93 — deliberately
  out, R-VX83-5: "searching stuff that wasn't saved and was purposefully deleted is a different
  issue") and archived takes (`+ archived` already), and "history" names Block History, which
  holds savepoints AND archived takes.

The face I would build with it (PROVISIONAL, the archived chip's grammar): the dashed invitation
beside `+ archived`, offered only when the question has WORDS (a tag alone or a day alone lists
without the index — the facet could not act there, P-2); help at rest "Include what you saved —
every savepoint of your takes", armed "Back to the living text — leave savepoints out".

**The PROVISIONALs I will build unless the rulings redirect** (each to ride the ratify bundle):
- **P-VX83-C1** the facet composes with `+ archived`, orthogonally: a savepoint whose take, block
  or note is archived lists only with both; saved versions fenced under both.
- **P-VX83-C2** ranking: a savepoint's kind weight 0.9 (just under a live take's 1.0) and never the
  rendered boost — the living words lead, their saved states follow.
- **P-VX83-C3** counts: under the facet the band counts savepoint hits as their own kind ("N
  savepoints"); `passages` stays the living text; no "N more in your savepoints" foot (a foot would
  make every default search pay the savepoints' homes).
- **P-VX83-C4** landing: a savepoint passage lands at its block and STEPS only when its take is the
  one the note shows (P-13o-U2-4's rule for takes); there the editor's own road still ARMS instead
  whenever the words are no longer in the buffer (`applyFindSeed`'s "words the buffer no longer
  holds"); an unrendered take's savepoint arms. Residual: the editor's find reads from the block
  onward, so words gone from the block but present LATER in the note land there (the shipped
  seed's own reach).
- **P-VX83-C5** ⌘K and the book's 🔍 stay savepoint-free (the brief's ⌘K provisional, extended to
  the book's sheet: the Library facet is the history door).
- **P-VX83-C6** the savepoint line's kind word is "savepoint · Oct 6" — the word plus its day
  (`TimeStampFace.day`), faint like every kind word.

> #### §U-C RULINGS (the architect, 2026-10-08 — binding; P1–P8 build to these)
>
> **FORK 1 — RULED: A, liveness at query time.** The trace is accepted as decisive and the
> stop was exactly right: (B) is dead on arrival — R-13o-4's letter is a ruled fence, and
> the probe's SQLITE_CORRUPT result shows the "clever trigger" alternative isn't even
> correct; (C) is dead on the arrival-order fact alone (and would still need the query-time
> check, so it buys nothing). A is F3's own doctrine applied again — own-row facts on the
> doc, every cross-row truth resolved at query time in the ONE composer — and its lingering
> class (a dead take's savepoints indexed but never listed until purge) is the SAME accepted
> class as released blocks (P-13o-U1-8), not a new one. FIVE CONDITIONS, binding:
> (1) the savepoint doc mirrors its `commit_point` row ONLY — INSERT · physical DELETE (the
> janitor's road — purge coordination is thereby correct by construction; say so in the
> record) · the UPDATE arm KEPT (remote apply's generic UPDATE-then-INSERT makes it
> load-bearing insurance, never dead code); (2) the composer resolves the variant's liveness
> by key ONLY under the facet, and the DEFAULT road's savepoint exclusion is the doc-row
> kind fence, pinned by the never-lists-without-the-facet pin; (3) `SearchIndex.integrity` /
> `verifySearchIndex` learns the ninth kind's existence rule — doc ⇔ physical commit_point
> row, NOT variant liveness — so a dead take's lingering savepoint docs read as CORRECT, not
> drift; (4) P4's measurement includes the DEFAULT road's delta with savepoints indexed at
> scale (the recorded bm25-statistics consequence), and a change in the default road's cost
> CLASS is a stop, not a note (the implementer's own offer, made binding); (5) the new
> nullable `search_doc.variant_id` column is approved (local-only derived; the rebuild is
> its backfill).
>
> **PROPOSAL 2 — RULED: `+ savepoints`** (armed `savepoints ✕`, the archived chip's
> grammar). The collision argument is decisive: "+ saved versions" would name the ONE thing
> search fences under every facet — actively false, not merely vague — and "+ history"
> reaches toward two things this facet deliberately is not (the Trash, VX-93; archived,
> its own chip). The app's own noun wins. The proposed help texts and the offered-only-
> with-words rule are accepted as PROVISIONAL wording for the bundle (one constant each if
> she re-words at the walk). **C1–C6 are accepted to build as recorded** — C2's 0.9 weight
> and C4's residual are honestly stated; ride the bundle. — the architect

## LADDER (after U-B, over the run's whole diff)

Fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` VERBATIM, zero framing; findings
repo-first here; cross-model dispositions per CLAUDE.md; hard cap three rounds.

## ENVIRONMENT TRAPS (13o's block, verbatim-binding)

Instance checks via `pgrep -fl 'Variorum.app/Contents/MacOS'` discriminated by PATH;
real-store instances by STORE, never quit/kill one; no Release builds or `/Applications`
refreshes while one lives; every `xcodebuild test`/walk/Debug launch claims `Tools/stage`
first (headless `swift build`/`swift test` free) — **and in this run, a stage need is
REQUESTED from the `oct7coordinator` session first** (name · need · duration · urgency);
Mac tests from `App/Variorum/`, suite-level `-only-testing`, confirm the "Test run with N
tests" line, skipped-count honesty; NEVER a custom build configuration; zsh `pipestatus`;
A1 backups into `Backups/safety-copies/` before any real-store touch; commit per piece,
push after every commit, synchronous foreground waits; never `git checkout` over
uncommitted work. Work ONLY in `~/dev/variorum-vx-83`.

## LEDGER

| # | Item | Status |
|---|---|---|
| 1 | Tickets minted (VX-83 run + VX-84…89 members; VX-90 beside) | DONE 2026-10-07 |
| 2 | Worktree + branch + in-flight row | DONE 2026-10-07 |
| 3 | This record + traces + briefs | DONE (this commit) |
| 4 | The when-door mockup (`notes/plans/mockups/when-door.html`) | DONE (this commit) |
| 5 | U-A (VX-84 · 85 · 86 · 88 + the VX-84b offer chip) | CLOSED 2026-10-07 23:3x (the §U-A RECORD final — every member FIXED with red-on-old; Mac 384/57 zero-skipped + NoteOpenLanding 12/12 alone, core 2,304/263) · **ORCHESTRATOR CHECK DONE**: tree clean + pushed at a15e6dd9, no live PENDING, suites re-run green on the orchestrator's machine, the red-on-old table read against each §M trace (note for the ladder: the first-cut VX-85 pins were HOLLOW on the bare harness — re-mounted on a real EditorView at the slot, 1d12917c) · the ACCEPTANCE WALK ran via the WALKER (her road; §WALK EXECUTION + shots 01–16, commit b5568168) and is **ACCEPTED by the orchestrator's §WALK JUDGMENT** — with findings F-W-1…3 owned by the post-U-C fix pass |
| 6 | The sitting (S-1…S-4 + the VX-72 split) → rulings R-VX83-1…6 | DONE 2026-10-07 (the sitting record above; Linear updated: VX-72 re-scoped + membered, VX-93 minted, VX-73's U3-3 rider, VX-89 in) |
| 7 | U-B (VX-87 direction 1 + screenshots; VX-89) | CLOSED 2026-10-08 00:3x (the §U-B RECORD's close banner; HEAD 40abb3d4) — **ORCHESTRATOR CHECK DONE**: tree clean + pushed, slot batch 232/27 zero-skipped first run, the flipped-subject pin read against her complaint (correct), the 16 headless renders judged by the orchestrator (direction 1 holds in both voices/rooms); the R-VX83-2 captures RAN (W7–W9, §WALK EXECUTION) and are **ACCEPTED** (§WALK JUDGMENT; the taste observations await her eyes at the shots). Closeout carries: the real-store field-guide re-seed (A1 rail) + a MobileSoul line for the new search lesson (no phone parity rule yet) |
| 8 | U-C (VX-72 savepoints) | IN FLIGHT 2026-10-08 — seated; PAUSED at two propose-then-stop points (the §U-C RECORD: FORK 1, PROPOSAL 2) |
| 9 | **VX-94** (joined 2026-10-07, relayed by the 13x closeout session's P-8 sweep): ChromeLineLimitTests red on MAIN over this run's in-flight file — `SearchAnswerFaces.swift`'s chip face stack and kind word, two bare `.fixedSize()` with no line policy in the scan's 4-line window (arrived with 13o's merge; 13x deliberately left the file to this run). Fix: `.lineLimit(1)` at each site, orchestrator's own commit (the small-fix class). The PIN is the existing suite — red on main by 13x's run; GREEN proven in the U-A stage slot (the batch adds ChromeLineLimitTests) | FIXED — pending the slot's green |
| 10 | Ladder → closeout → PR `VX-83: …` (merge order FREED, R-VX83-7 — first-ready merges first; whoever is second rebases) → the `/Applications` refresh (A1 rail, zero-instance window) → the author handoff notes | NOT STARTED |

## §WALK EXECUTION (vx83walker, 2026-10-08)

Grants AX:true SCREEN:true · stage claimed on oct7coordinator's GO · Debug build `DerivedData/vx83-walk` at HEAD abe4b192 · dev store only (her `/Applications` app never running or touched; pgrep showed none before the launch and none after the quit) · dev window 1440×1084 at Y=33 · found state: voice Terminal, `appearanceChoice` dark (restored to both at the end; dark was the FOUND value, so the brief's "restore `system`" was overridden by the README's restore-what-you-found rule).

- **W1 SEEN** — `sherlock holmes`: band `"sherlock holmes" — 1 book · 13 notes · 98 passages · in: home · + book state · + archived`; the books section (the adventures of sherlock holmes); passages grouped under notes with both words marked; "all N ›" per group. → `01-W1-answer-sheet.png`
- **W2 SEEN** — Beryl Coronet "took it up and opened the bureau": Write opens at block 146/222, the line FULLY visible about 30 pt below the find bar, field = `Sherlock Holmes`, the match selected. → `02-…`. ⌘G steps to the next occurrence (block 195, "…said Sherlock Holmes rather sternly."). → `03-…`
- **W3 SEEN, with an anomaly** — this dev store has no outline note. `good-night mister sherlock` hits ONE passage, in A Scandal in Bohemia at **block 215/262, not a first line** (→ `05-…`): the line sits below the bar, readable. BUT **the find field read `Good-night` alone, and only "Good-night" was selected**. For a true first-line case, `always the woman` → "To Sherlock Holmes she is always _the_ woman" (block 2/262, the note's opening paragraph): it lands below the bar with clear air, readable (→ `04-…`), and again **the field read `always` alone**. W2's two-word query filled the field with both words. Here, with non-adjacent words, only the first matched word reaches the field. Reported as seen; judgment is the orchestrator's.
- **W4 SEEN** — `#classics`: books-flow on top (`classics  #classics flows here  gathering`), then the 17 tagged notes as Library rows; the sort door reads `edited · newest first ▾`, the scope picker is live, and NO "Type a word to search inside #classics." line. Oddity verbatim: the band reads `— 1 book · 17 notes  in: home  #classics ×  …`, starting with a bare em-dash where the other bands carry the quoted query. → `06-…`
- **W5 SEEN** — `classics`: honest text results (1 book · 1 note · 1 passage), and the band offers `tag: #classics ›` (→ `07-…`). Pressing the chip makes the field `#classics ` (trailing space, caret after it) and shows W4's listing exactly (→ `08-…`).
- **W6 SEEN** — `sherlock holmes`, scrolled mid-list: every passage line sits on one even ~18 pt step across all groups, with no tight pair beside padded neighbours. Passages are elided to one line each (…), so no multi-line passage row appeared in the scrolled stretch. Band chips render single-line. → `09-…`
- **W7 SEEN** — (a) just opened: the sentence reads `showing notes edited on any day.`, `any day` greyed, NO day chip in the band (→ `10-…`). (b) a press on Oct 15 (future) arms `edited on oct 15 ×` with an honest empty state ("no note's last edit or savepoint falls on oct 15…"). Re-armed on Oct 3: chip `edited on oct 3 ×`, sentence `showing notes edited on oct 3.`, and the listing narrows to notes (the books section drops out) (→ `11-…`). (c) between days, 1 then 14: the run is washed 1→14, chip `edited oct 1 – oct 14 ×`, sentence `showing notes edited oct 1 — oct 14.` (→ `12-…`, Terminal DARK — the found appearance).
- **W8 SEEN** — from a clean state: open, between days → on a day → between days, then Esc with no day pressed. The popover closes, the band is bare (no chip) and the listing never narrowed (books + notes intact). → `14-…`. Dark tone eyeball (zoom `13-…`): the popover body matches the card's wine tone; the arrow is a small notch under `when ▾` in the same tone, barely visible. **In Terminal the popover overhangs the main window's right edge by about 24 pt** (the window capture comes out 1464 pt wide against a 1440 pt window, both rooms). In Study it stays inside (1440).
- **W9 SEEN** — the range repeated in Terminal LIGHT (relaunched with `appearanceChoice light`, → `15-…`) and in **STUDY light** (the voice flipped through Settings ▸ General over Accessibility, `radio group "Design voice" of group 1 of scroll area 2 of group 1`, → `16-…`). Both render the wash, chip and sentence correctly. Eyeball: in Study light the popover's card is a pale panel over the list with only a faint edge. In Study dark: not captured (the brief allows light only there). Restored afterwards: voice Terminal (AX value read back = 1), `appearanceChoice dark`.

Instance quit by bundle id; pgrep clean. Shots: `notes/plans/vx83-screens/01…16` (full-resolution window captures).

## §WALK JUDGMENT (the orchestrator, 2026-10-08 — over the walker's §WALK EXECUTION + shots 01–16; the probe evidence inline)

**U-A ACCEPTED (W1–W6) · U-B's VX-87 captures ACCEPTED (W7–W9).** The orchestrator read the
decisive shots itself (02: the Beryl match in clear air below the bar, both words in the
field, 2w selected — her exact complaint, fixed; 12: the dark-room popover with the Oct 1–14
run washed, the sentence and chip agreeing). Per-member: VX-85 ✓ (far, first-line and
unrendered arms all below the bar) · VX-86 ✓ for adjacent pairs (but see F-W-1) · VX-88 ✓
(one even line step) · VX-84a ✓ (the narrowed listing exactly as ruled) · VX-84b ✓ (the
offer chip road) · VX-94 ✓ visually · VX-87 ✓ (states, no-silent-arm, Esc, rooms).

**FINDINGS (fix pass after U-C closes, BEFORE the ladder — `Domain/SearchComposer.swift` is
in U-C's uncommitted set, so nothing lands until U-C commits; pin-before-fix each):**
- **F-W-1 (DEFECT vs the ruled D-3):** a THREE-run whitespace-separated span arms only its
  first word — "always the woman" armed "always". The orchestrator's FTS5 probe (sqlite
  3.54.0, the composer's own STX/ETX form) shows the snippet carries
  `⟨always⟩ ⟨the⟩ ⟨woman⟩` — three match runs with PURE-SPACE gaps, exactly what the ruled
  coalescing must join; two-run "Sherlock Holmes" works, so the span rule stops early
  somewhere past the first join. Red-on-old pin: a three-run snippet arms all three words.
- **F-W-2 (PROVISIONAL widening of D-3, the bundle's):** short PUNCTUATION gaps should
  coalesce too — the probe shows "good-night mister sherlock" marks
  `⟨Good⟩-⟨night⟩, ⟨Mister⟩ ⟨Sherlock⟩`, and the span rule's whitespace-only letter stops
  at "-"/", " so the field got "Good-night" (her "only the first word" complaint in
  another coat). Widen: a gap coalesces when it is ≤ 2 characters and holds no newline
  (the needle stays the text AS WRITTEN, so the literal find still lands; P-VX83-1's
  newline stop stands). Rides the bundle as P-VX83-W2.
- **F-W-3 (copy):** with a tag alone (no words) the band leads with a bare "— 1 book ·
  17 notes" — an em-dash with no echo in front of it. The separator draws only when the
  echo does.

**OBSERVATIONS for her eyes (taste, not defects — the shots decide):** the Terminal
popover overhangs the window's right edge ~24 pt (AppKit's own edge behavior; shot 15);
Study-light's popover is a pale card with a faint edge (shot 16); Terminal's run band
uses the at-rest fill and may read faint (shots 12/15 — U-B's own flag, P-VX83-B4).
