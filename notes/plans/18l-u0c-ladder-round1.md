# 18l U0c — COLD REVIEW, ladder round 1 (Fable, 2026-09-26)

**Reviewer:** `fable-reviewer` (Fable 5, xhigh), zero implementation context, running
`notes/REVIEW_PROMPT.md` verbatim. **Diff under review:** `dee364dc..aa317d99`, code =
`App/`, `Sources/`, `Tests/` (10 files, +778/−28; commits `ac52081d…aa317d99`, notes-only
record commits excluded per the brief). **Anchors read in full, myself:** the phase plan
(`phase-18l-navigation-feel.md` — HER KICKOFF MESSAGE, THE SITTING RECORD R-18l-1/2/4/5,
ENVIRONMENT TRAPS, THE LEDGER, the U0c BRIEF and the U0c RECORD whole, incl. the
orchestrator acceptance), QUESTIONS #149/#150, KnownIssues (the note-open row 93, rows
27/45/76/79), `TEXTKIT2_NOTES.md` whole (§3's 27.0 findings are this diff's era), the
canon (CLAUDE.md auto-set), and the touched code end to end plus its unchanged
surroundings: `CommandRouter.swift` (registerDetail/unregisterDetail whole, the new
OPENING section, `noteFocusedBlock`, `currentBlock(for:)`, `noteMode`),
`CurrentBlockMemory.swift` whole, `EditorRouter.swift` (`scrollPlaces` + the
`scrollAnchors` facade), `EditorViewModel` (`teardown`, `applyProjection(.initialRender)`
incl. the pre-fill `arrivalFact` capture at :849, `applyFocusSeeds` whole,
`revealLanding`/`parkAnchorRestore`/`consumePendingAnchorRestore`/`consumePendingReveal`,
`bareArrivalLanding`/`rememberedArrivalLanding`, `updateCaretContext`,
`topVisibleOffset`/`readingAnchor`/`placeBelowTheLastLine`/`restoreReadingAnchor`,
`keepingReadingPosition`), `EditorSurfaceController.renderFull` (all three restore
branches), `TakesChoreographer.consumeLandings` whole, `ReadModeView` (the seed, `select`,
`openInEdit`, `landIfPending`, `report` — DEBUG oracle only, it writes no fact),
`JumpPrimitive.swift` whole (`ReadingAnchor`, `lineSpan`'s R2-1 end rule, `jump`'s C6
re-assert + C6b live range), `PostDetailView` (onAppear registration, `.task(id:)`
blockless flip, `onChange(of: mode)` → `noteMode`, `jump(to:)`), and
`NoteOpenLandingTests.swift` whole. No "Review foci" section exists in the plan or the
charter (checked; none owed). Zero `Sources/`, `Shared/`, `Sync/`, schema — confirmed by
diff stat, not the seam table; the only test file in the range is the new suite, so every
ruled pin (`LandingOffsetTests`, `TakesArticleScrollTests`, `CurrentBlockContinuityTests`,
`ModeSwitchCarryTests`, `ScrollAnchorTests`, `WriteTopAirTests`) is byte-unmodified by
construction. Commit-trailer check over the range: clean.

**Verification runs made by this review (targeted, per the prompt's rule):**
- `xcodebuild test -only-testing` on **NoteOpenLandingTests + LandingOffsetTests +
  TakesArticleScrollTests + CurrentBlockContinuityTests + ModeSwitchCarryTests** on the
  final tree, zero app instances, HID idle ~18 min: **73 passed / 0 failed / 0 skipped**
  (`Test-Variorum-2026.09.26_10-12-04--0600.xcresult`).
- **Every red-evidence claim verified in the logs on disk**, numbers matched exactly:
  pre-fix `18l-u0c-pin-prefix1.log` = 10 tests / **18 issues**, and the issue text carries
  her three shapes byte-for-byte (Write first opens clip **2904.0 / 2880.0 / 1588.0** with
  carets 8691/8690/4926, Takes **1866.0** with the wrong live pane, Read selected the last
  block + scrolled, re-open-at-top **24.0**, mid-note **1391 → 24.0**); the reverts:
  `R-open2` = **4 issues** (the re-open arm exactly), `R-place` = **3**, `R-room` = **1**,
  `R-letter` = **16** including the t-11 shape in print (`Write clip 2904.0 · caret 8691`);
  the fixed tree `pin-fixed5` = 12/12 green; the closing `18l-u0c-closing1.log` =
  **"Test run with 989 tests in 146 suites passed"**.
- Pin-red-before-fix verified against git: `fe4473bf` committed the pins RED on the
  pre-fix tree; the fixes follow (`5d7c8bb6`, `cf5334cf`); the reverts are named before
  they run (`f7facac8`).
- KnownIssues verified on disk: the note-open row CLOSED with the ladder re-open clause;
  the C6 Takes-born-live residue owned on ledger row 8.

**The mechanism, traced independently (the hallucination guard):** every door into a note
mounts `PostDetailView`, whose `onAppear` is the ONE `registerDetail` call site in the
tree (grep-verified) — so the rule is door-agnostic by construction, not by enumeration.
Pre-fix, `registerDetail` seeded the live fact from the PERSISTED `currentBlock.<id>` and
each mode's entry landing revealed it: Write's bare arrival parked `revealLanding` (the
caret's line at the viewport top — #98(a)'s shape — with the typewriter room below: her
"one line of text on the screen"), Takes' N9 arm asked `landArticle`, Read's seed scrolled
to the selected block. Her trailing-newline correlation is exactly what the record says:
the ⏎ at the end and the tail memory are one gesture's two products. The fix records the
OPENING beside the restored fact: `notesOpenedThisRun` (per-run, in-memory) decides
first-open vs re-open; a first open seeds NOTHING; a re-open seeds `sessionFact` only
(the session dict, never the persisted copy); `openingLanding(postID:fact:)` answers only
while the opening is live AND the asked fact `==` the seeded one — and I verified the
equality cannot be corrupted by the fill's own side effects, because Write captures
`arrivalFact` BEFORE `renderFull` (EditorViewModel:849, rows 39/49's existing rule),
Takes' N9 captures `fact` before `landAuthorityFocus` can report, and Read's `report()`
is a DEBUG oracle that writes no fact. A mode switch ends the opening at `noteMode`
(the detail's own first `onChange` reports the registration's mode and keeps it —
verified at PostDetailView:500–507/579–581), and the P→Q onAppear-before-onDisappear
interleave cannot clear a fresh opening (the stale unregister is token-guarded). The page
half: `teardown` writes `readingAnchor() ?? placeBelowTheLastLine()` into
`EditorRouter.scrollPlaces` for a LOADED full-document editor only; `renderFull`'s cold
branch parks it and the warm branch jumps it, both at `exactLandingInset`, all through
`JumpPrimitive.jump` — which carries 18k C6's 27.0 clip re-assert, so the new restores
inherit the macOS-27 defense rather than bypassing it. The room place's negative inset
clamps at the hop's live `maxScroll` (the last line at the top) — the pin asserts the
clamp honestly, not the exact offset. `EditorTextView`, `BlockRangeIndex`, `PaneSurface`,
`PaneTextAuthority`, `JumpPrimitive` internals: untouched, as the seam table claims; the
one new layout read (`lineSpan` at teardown) is single-fragment (P1); no TK1 API.

---

## FINDINGS (severity-ranked)

**No BLOCKER. No MAJOR. No MINOR.** Three NITs, none behavioral:

- **NIT-1 · `App/Variorum/Variorum/Features/Editor/EditorViewModel.swift:2348` · a
  historical doc line still narrates the RAISE-M1 restore as reading
  `editorRouter.scrollAnchors[postID]`** · evidence: since this diff the live seam is
  `scrollPlaces` (`EditorSurfaceController.renderFull:195`) and `scrollAnchors` is a
  test-only facade whose own doc says "Nothing in the app writes through here" — the
  RAISE-M1 history block is accurate as history but now names a symbol whose role
  changed · fix: one parenthetical ("today `scrollPlaces`; `scrollAnchors` is its
  offset-only pin facade") — cosmetic, no pin, fold into any next touch of the file.
- **NIT-2 · `App/Variorum/VariorumTests/LandingOffsetTests.swift` (header) · the 17o
  "ONE rule: every door into Write lands at the REMEMBERED CARET OFFSET" sentence is now
  false for the note-open door** · evidence: R-18l-1 supersedes it for that one act; the
  implementer deliberately left the ruled pin byte-unmodified and flagged it
  (NOTICED item 3), and the orchestrator's closeout owns the edit · fix: none here —
  recorded so the closeout line does not get lost; the AppSpec §12 contract line drafted
  in OWED AT CLOSE covers the canon half.
- **NIT-3 · the U0c RECORD's NOTICED item 4 (the Library search found no hit for
  "Persian") can be CLOSED with a mechanism rather than left "not investigated"** ·
  evidence: `Queries.searchCatalog` reads titles/names/scrap prefixes only — body-text
  search is deliberately unbuilt, KnownIssues row 27 → owner **13o** (the whole-library
  text search row); a word that lives only in a story's last block is out of the shipped
  search's scope BY DESIGN, so the walk observed the recorded deferral, not a regression ·
  fix: one line in the record (orchestrator's pen); the segmented-control-vs-cliclick
  half stays walk-tooling noise.

**The two #150 PROVISIONALs, weighed independently (the sitting record asks the reviewer
to):**

- **#150(a) — the supersession reading (a first open seeds NO fact) — CONFIRMED.** I
  traced the letter-reading's failure mechanism myself in the shipped code: keeping the
  old caret as the live fact leaves it as the ONE fact every mode enters on
  (`CommandRouter.focusedBlock` — the Act 10 "one current block" rule), and `noteMode`
  ends the opening at the first ⌘1, so the next mode's arrival reveals that caret by the
  standing #98(a) road — her END, one keystroke after a "fixed" first open. That is not a
  corner: a mode switch right after opening is the everyday gesture. The alternative
  (suppress reveals for not-chosen-this-run facts across mode switches) would either leak
  the no-reveal into all round trips (breaking #98(a), a ruled behavior with riding pins)
  or need a parallel "chosen this run" ledger — which is exactly what seeding-nothing
  achieves with less machinery. The R-letter revert (16 issues, the t-11 shape in print)
  is the measured proof. Hers to overturn at the morning bundle, as filed.
- **#150(b) — a re-open's page wins over an off-page caret — CONFIRMED.** "Re-opening a
  note you already visited this session restores where you were" reads as the PAGE (what
  she sees), and `pre-a10` measured the caret-reveal reading producing her exact
  complaint in one session. The trade (a caret off screen until she types or clicks) is
  scoped to note re-opens only — the `aModeRoundTripAfterAReopenStillRevealsTheCaret`
  guard pin holds #98(a) everywhere else, and I verified the scoping mechanism (the
  opening dies at `noteMode`; `openingLanding`'s fact-equality excludes chosen places).

---

## CLEAN BILL (load-bearing things specifically checked and found solid)

1. **Pin-before-fix and red-on-old, the full matrix:** 12 pins; 10 carry red evidence I
   verified in the logs (8 in the pre-fix run, the room pin in R-room, the mode-switch
   pin in R-letter), 2 are declared guards (deep link; mode-round-trip reveal) — green on
   both sides BY DESIGN, guarding the fix's scope, honestly labeled. No hollow pin found.
2. **The `seeded == fact` equality is race-safe where it matters:** Write's
   `arrivalFact` is captured pre-fill (EditorViewModel:849); the fill's
   end-of-document caret report cannot corrupt the opening check (and `noteFocusedBlock`
   drops reports for a non-active post, so a torn-down predecessor cannot either).
3. **The registration interleave:** on a P→Q switch SwiftUI may run Q's onAppear before
   P's onDisappear — Q's `registerDetail` replaces the token, P's `unregisterDetail` is
   token-stale and cannot clear Q's opening; `registerDetail`'s seeding branch is scoped
   to `activePostID != postID`, so a same-note remount (split pane taking focus) never
   fabricates an opening.
4. **The persisted memory machinery is byte-unchanged** (`current`/`remember`/`persist`/
   `forget`, the `blockID|variantID|offset` format, the U-20 nil-means-unknown rule);
   `sessionFact` is a pure addition; the doors that name a place on purpose
   (`BookView.editHere`, `PaneCaretLanding.entering`) still read `currentBlock(for:)` —
   and the book's edit-here classification (an in-book editing door, not a note-open) is
   coherent: books mount `BookView`, never `PostDetailView`, so it structurally cannot be
   an "opening".
5. **The `scrollAnchors` facade preserves the RAISE-M1 pins' semantics exactly:** an
   offset written through it becomes `ReadingAnchor(offset, inset: 0, inPageTopAir:
   false)` — `exactLandingInset` 0 = the line at the top, the old contract; per-key `=
   nil` removes; grep confirms its only writers are `LandingOffsetTests:582/593`. All
   five ruled-pin suites re-run green by this review on the final tree.
6. **TK2/macOS-27 discipline:** every new restore (cold park, warm jump, room clamp)
   routes through `JumpPrimitive.jump`, inheriting the C6 clip re-assert and the C6b
   live-range rule; the teardown's `lineSpan` read is single-fragment `.ensuresLayout`
   (P1); no new `layoutViewport()` caller; no TK1 API; the U3 rider (`PaneSurface`'s
   render restore) is untouched by this diff, as scoped.
7. **Scope containment:** Takes' R-Q20/R-Q21 step machine and the bloom arm untouched
   (the N9 change is an outrank above the landing — `landArticle` simply not asked on an
   opening); Read's carry outranks (opening consulted only when `carried == nil`); deep
   links land via `pendingCaretSeed`/`initialBlockID` and `jump(to:)`, both of which
   claim the arrival or end the opening — the guard pin agrees.
8. **Corners traced and found harmless:** the blockless `.task` mode flip ends the
   opening → blockless notes have no facts to land anyway; a re-open whose seeded block
   was deleted since (Takes slot missing / Read row missing / Write index miss) degrades
   to the start or first row with no reveal; a "glance" visit re-opens at the start
   (#150(e), pinned); teardown's both-nil removal is effectively unreachable (an empty
   document still yields a fragment-frame span) and where reachable removes a place not
   worth keeping — the stated "never left to an older page" intent; `notesOpenedThisRun`
   and `scrollPlaces` are session-only, in-memory, never synced, O(notes-visited).
9. **Two-window exposure unchanged:** `opening` is a single slot, but the router already
   holds a single `detailToken`/`activePostID` — the new bookkeeping rides the existing
   one-detail design and adds no new keying class (the recorded family: KnownIssues
   rows 45/76's session-scoping class, owner 12; the record's NOTICED item 2).
10. **Sync-shape (S1–S5):** nothing synced is touched; no schema; no `Sources/`; the
    persisted `currentBlock.<id>` stays the local scroll-position class. The closing run
    989/146 verified in the log; core/iOS/mobile not owed (zero core code).
11. **Process:** commit per piece, pushed, no trailers (checked over the range);
    LIVE STATUS flipped; the machinery slip (a revert's `git checkout HEAD --` over
    uncommitted edits) was self-caught, repaired, re-verified and recorded — the honest
    shape; the walk residue in the dev store carved back and stated.
12. **The walk is use-shaped evidence, and it did the ladder's job early:** it caught the
    letter-reading's failure (t-11) before any reviewer did, and the build's return to
    the supersession sentence is pinned (`aModeSwitchRightAfterAFirstOpenStaysAtTheStart`)
    with its own revert red. The orchestrator's independent hands-on walk corroborates.

## VERDICT

**PASS — 0 BLOCKER / 0 MAJOR / 0 MINOR / 3 NIT.** The diff builds R-18l-1 as ruled (with
the two #150 PROVISIONALs confirmed by this review independently, hers to overturn), the
mechanism attributions are honest (line-history, disclosed as such), every fix carries
verified red-on-old evidence, the ruled pins ride byte-unmodified, and the ladder needs
no fix round: the three NITs are record/doc lines for the orchestrator's closeout pen
(none warrants a code commit or a pin). The KnownIssues note-open row's close stands.
