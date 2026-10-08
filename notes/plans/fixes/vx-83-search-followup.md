# VX-83 — Run: 13o search follow-up (her first-use report)

**Run ticket: VX-83 · Project: 13o — Search · Branch: `vx-83-search-followup` · Worktree:
`~/dev/variorum-vx-83` (the Pro) · Orchestrator session: `searchfollowup` (her naming) ·
Stage: message the session named `oct7coordinator` — session name, what is needed (GUI walk ·
xcodebuild test · Debug launch · dev-store reset · /Applications refresh), rough duration,
urgency — BEFORE any `Tools/stage` claim; headless `swift build`/`swift test` is free.**

Members (sub-issues of VX-83, each closing individually; commits say `Part of VX-NN`):
**VX-84** tag search reveals the tagged notes · **VX-85** landing under the find bar ·
**VX-86** first-word-only find seed · **VX-87** the when ▾ door redesign · **VX-88**
passage-line spacing · **VX-89** the field guide's finder lesson (PENDING HER WORD — may
route to 13s instead). Beside the run, not in it: **VX-90** (passage lines name their block —
her feature idea, Backlog).

Shape: `/architect-phase` (the RUN form). Pin-before-fix binds PER MEMBER (red-on-old
verified by revert); ONE cold review over the run's whole diff — **fable-reviewer** (the
diff reaches `EditorViewModel`'s landing/reveal machinery, editor-adjacent). Merge order:
**13x merges first; this run rebases onto it** (her word at kickoff). One PR titled
`VX-83: …`, merge commit.

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
| P0 | This record + piece plan (the first commit) | DONE (this commit) |
| P1 | **VX-86 core** — the needle rule (D-3) as ONE pure core rule beside `SearchSnippetSegment` (the first CONTIGUOUS matched span; whitespace-only gaps coalesce; a gap holding a newline ends the span — the find bar is one line) + core pins (the rule's cells; the mechanism: FTS5 marks "sherlock holmes" as two runs) — headless, revert-probed | DONE (`68508196`) — `SearchSnippetSegment.firstMatchedSpan` (`Domain/SearchComposer.swift`); `SearchFindSeedSpanTests` 4/4 GREEN. **Mechanism confirmed on a REAL snippet:** "sherlock holmes" over "It was Sherlock Holmes who…" marks `["Sherlock", "Holmes"]`, two runs. **REVERT PROBE** (committed first; the body short-circuited to the shipped first-run letter, restored by `git checkout --`, re-run green): **RED — 5 issues in 3 tests** (the three coalescing cells, the first-span-not-a-later-one cell, the real snippet's needle `"Sherlock"`). The newline-ends-the-span cell is a refinement inside D-3 (the find bar is one line), recorded as PROVISIONAL P-VX83-1 |
| P2 | **Mac pins on the PRE-FIX app tree** (red-on-old, the members' own pins): VX-86 `SearchLanding.findSeed` two-runs arm · VX-85 the landed line vs the bar-adjusted band (a far block AND a note's first line) · VX-88 the §M5 confirm (a newline snippet's row height vs a plain one) · VX-84a tag-alone lists the tagged notes (+ the words control) → ONE stage slot (ask `oct7coordinator`), reds recorded | WRITTEN + COMPILED (`197205f5`, `4d9119ba`; `build-for-testing` SUCCEEDED) — the RUN is PENDING: at 20:5x the stage is HELD by `oct7coordinator` ("author on the Pro — no walks/app suites until she says open season", ~210 min). Request sent (msg b013808a; replies land in the parent session `searchfollowup`, which relays). Since the slot arrives after the fixes, the red-on-old evidence comes by ANNOUNCED REVERT inside the slot (fixes committed first; production files checked out at `4d9119ba` with the pins kept; run; `git checkout HEAD --` restore) — the protocol's commit-before-revert form |
| P3 | **VX-86 Mac** — `SearchLanding.findSeed` reads the core rule | DONE (this commit) — the seed's needle is `SearchSnippetSegment.firstMatchedSpan`; pins `aTwoWordQueryArmsTheBarWithBothWordsAsWritten` + `theSearchStatesOwnPassageLandsTheWholePhrase` (run PENDING the slot) |
| P4 | **VX-85** — the find seed's park is a BANDED reveal kind (the mode-switch arm's sibling; `restCaretLineInTheBand` the one rule, computed against the BAR-ADJUSTED viewport); `JumpPrimitive`'s scroll floor follows the bar's top inset so a first-line match can rest below the bar | DONE (this commit; Mac pins PENDING-on-stage) — `EditorViewModel`: `RevealKind {plain, banded}` rides the reveal park (`pendingRevealKind`, dies with its park at every spend/abandon); `applyFindSeed`'s stepping arm parks `.banded`; its non-stepping arm bands the caret seed's ALREADY-parked reveal (no reveal of its own — a refinement of D-4's "keeps its no-scroll behavior": that arm's caret reveal also landed the block under the bar it shows, P-VX83-2); `consumePendingReveal` sends `.banded` through `restCaretLineInTheBand`, which now reads the band against the viewport minus `JumpPrimitive.findBarInsets` (ZERO with no bar shown — the 18l-c mode-switch rule byte for byte). `JumpPrimitive`: `findBarInsets(of:)` (the clip's `contentInsets` while `isFindBarVisible`, else 0) and the jump's floor `minScroll = −top inset` (`JumpCorrectionLoop.run` gains `minScroll: Double = 0`; every other caller byte-unchanged) — **MEASURED headlessly: `NSClipView.constrainBoundsRect` floors at exactly −32 under the bar, so the new floor IS AppKit's own** (and `scroll(to:)` itself does not constrain — −80 sticks, hence the explicit floor). `ComfortBand`'s scope sentence names the new caller. **ZERO lines in `EditorTextView`/`BlockRangeIndex`/`PaneSurface`.** Mac `build-for-testing` SUCCEEDED. Pins (`LibrarySearchLandingTests`): the far match in the band below the bar · a FIRST-line match clears the bar · the unrendered arm's block clears the bar · a mid-band control never moves — all PENDING-on-stage (red-on-old by the announced revert) |
| P5 | **VX-88** — D-5, newline runs fold at the face (`LibrarySearchFace.snippet`), pinned; CONDITIONAL on the §M5 confirm going RED on the pre-fix face | BUILT (this commit; the CONFIRM run PENDING-on-stage) — **the trace's two premises evidenced headlessly before any fix:** (1) CORE, `SearchSnippetRawTextTests` 1/1 green — the index's snippet over "we walked along⏎⏎the harbor at night⏎and home" IS that raw text, both breaks included (green on both sides by design: the index and composer stay untouched); (2) the FACE, an external-fact SwiftUI probe (headless `NSHostingView`, no window): a `Text(…).lineLimit(2)` at 640 pt stands **15 pt plain · 30 pt with one newline · 30 pt across a blank line** — two tight lines, or a line and a blank one, in one row. The fix: `LibrarySearchFace.foldingNewlines` (a whitespace run holding a line break → ONE space; other whitespace kept) applied per segment in `snippet` — the shared face, so the book's sheet folds too; marks untouched. Pins (`SearchPassageLineRhythmTests`): the §M5 CONFIRM (row heights, both voices) + the face rule — RUN PENDING-on-stage; **if the confirm runs GREEN on the pre-fix face the fix is reverted and VX-88 closes record-only (the brief's stop rule)**. OBSERVATION (not this member — another surface): the ⌘K palette's passage row titles itself with the same raw words (`CommandPalette.passageItem`), so a palette row may show only the snippet's first line; the fold is one call there if the orchestrator wants it |
| P6 | **VX-84a core** — the text-less TAG road in the one composer (the seam measured, below) + `Queries` listing reads + core cells | DONE (this commit) — `SearchComposer.listingNarrowing(_:kind:wingID:environment:)` → `ListingNarrowing {driver, conditions}` (notes by `post_tag`, blocks by `block_tag`; the DRIVER = each typed `#path`'s subtree applications, `SELECT DISTINCT … AS tagged_id`, several tags INTERSECT; the CONDITIONS = the whole question at note/block level through the ONE `composeFilter` + liveness + wing + the archived facet's clauses), `composeFilter` gains a `.block` level (a tag term is the BLOCK's own; home answers starred/day/family; no book, no doc), `SearchComposer.listingCounts` (notes/all_notes/blocks/all_blocks); `noteVisibility` and `appliedTags(join:)` factored out BYTE-IDENTICAL — **proved: 270 shipped statements (passages · groups · counts · worn-day · association × 3 visibilities × 3 scopes × 5 queries) snapshotted on the pre-change commit in a scratch worktree and on this tree: `cmp` IDENTICAL**. `Queries.catalogNotesPage(…, narrowing:)` (nil = the shipped statement, pinned) · `Queries.catalogTaggedBlocks` (`Queries/TagListingQueries.swift` — a SET, newest edit first, first-line handle) · `SearchCounts.Kinds.blocks` (default 0) · `searchCounts`' text-less branch folds the narrowed notes/blocks (Library scope only). Pins `SearchTagListingTests` 10 + `SearchTagListingSeamTests` 2 — **12/12 GREEN** (post-level · subtree · case · wing twins · tombstones · facet + version fence · a note tagged twice in the subtree lists ONCE (found red at the seam, 3 issues, before the DISTINCT) · intersection · sort + keyset · words close the road · blocks by block-level tags, scraps in every wing · the counts). JUSTIFIED EDIT: `SearchTagAssociationTests.theBandCountsTheAssociatedBooksWithWordsAndWithout`'s tag-alone cell `notes: 0 → 1` (P-13o-U2-6 superseded by her report — that cell flipping IS the core-side red-on-old of the behavior change). Families `Search|Catalog|LibraryDay|LibraryPaging|Shelf|Gathering` **247/57 GREEN** |
| P7 | **VX-84a Mac** — a tag-alone question routes to the narrowed LISTING (sort ▾ + scope picker live; band chips + honest counts; Books section unchanged above; the words-ask line dies; Blocks scope by block-level tags) | NOT STARTED |
| P8 | **VX-84b** — the tag-offer chip (D-2): one pure rule home + the composer's wing-scoped live-tag read + the band chip + the press routing; pins | NOT STARTED |
| P9 | Close — full core `swift test` + the touched Mac suites + `TutorialWalkTests` green at the END (stage slot), record final, report | NOT STARTED |

PENDING flags: every Mac pin RUN (P2–P8) is **PENDING-on-stage**.

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
- **P-VX83-2** (VX-85, inside D-4): the NON-STEPPING arm (an unrendered take's hit) adds no reveal
  of its own, but the caret seed's reveal it inherits now rests BANDED below the bar too — the
  brief's "keeps its no-scroll behavior" read as "adds no scroll"; left plain, that arm landed
  its block flush under the bar it shows (her exact complaint, one arm over). Redirect = one line.
- **P-VX83-1** (VX-86, inside D-3): a gap holding a NEWLINE ends the needle's span (the find bar
  holds one line; a newline inside a block is content, I4) — "Sherlock⏎Holmes" arms "Sherlock".

### U-B — THE DESIGN MEMBERS: VX-87 (gated on her mockup pick) + VX-89 (gated on her word;
may route to 13s). Brief authored after the sitting lands its rulings here.

### THE SITTING BUNDLE (for her next reply; asked in the session, recorded here)

- S-1: D-1/D-2 confirm-or-redirect (tag-alone narrows the listing; plain word offers the
  tag — or fold tagged notes into results directly).
- S-2: the when-door mockup pick (`notes/plans/mockups/when-door.html`).
- S-3: VX-89 — in this run, or 13s's field-guide rewrite?
- S-4: U3-3 (the book-state facet's interplay) — explained in the reply; her ruling lands
  in QUESTIONS #201's walk, not here.

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
| 5 | U-A (VX-84 · 85 · 86 · 88) | NOT STARTED |
| 6 | The sitting (S-1…S-4) → U-B brief | AWAITING HER |
| 7 | U-B (VX-87 + VX-89 as ruled) | GATED on 6 |
| 8 | Ladder → closeout → PR `VX-83: …` (after 13x merges; rebase first) | NOT STARTED |
