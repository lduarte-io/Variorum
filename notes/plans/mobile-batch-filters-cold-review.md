> # ✅ UNIT CLOSED — 2026-08-31 (the cutover signal, per the seat handoff §6)
>
> Build `19e52d5` → her rulings `5b40049` (#93) → this review `5047ff9` →
> fix wave `8b4d38b` (all nine items + the #93(b) UNION built; M1's ≥44 pt
> speculation FALSIFIED by measurement — the real Menu element is 16.0 pt,
> no layout fix owed; m6 deleted as unbuildable with the probe as reason).
> **Final: mobile 632/96 green, 2 known issues (the one documented
> diagnostic test).** Fence clean end to end. The successor seat starts at
> BATCH 6B per `mobile-round-2-fable-seat-handoff.md` §3.

# Cold review — the Library filter batch (`9be4f1a..19e52d5`)

*Cold Opus reviewer, 2026-08-31. It reproduced the width dump exactly,
verified the model fact independently at the migrations, ran the 16 new
tests green on its own simulator, and ran the FULL suite twice — both
`** TEST FAILED **`, which is MAJOR 2. **2 MAJOR · 4 MINOR · 3 NIT.***

## Findings

**M1 [MAJOR] · `MobileFilterRowGeometryTests.swift:115-131` vs
`MobileLibraryView.swift:280-291` · READ-ONLY + MEASURED.** No geometry
pin ever measures the SHIPPED sort door: the shipped door is
`MobileLibraryView.sortMenu` (a `Menu` labelled by the glyph, private);
the geometry suite hand-builds a stand-in `Image` + label and measures
that. So the record's "RED ON OLD (2)" for the text-door-back revert can
only have been a TEST-FIXTURE revert presented as a production one — a
future session following the record's description gets a green run and
concludes the pin hollow. SPECULATIVE tail with real stakes: a `Menu`'s
accessibility element may report a ≥44 pt hit region where the stand-in
is 13 pt; at 320 pt the remaining slack is ~40 pt after the spacer, so a
44 pt real element would overflow and spend `minimumScaleFactor(0.7)` —
the exact outcome `noFilterDoorIsShrunkToFitEvenAtDisplayZoom` forbids,
and that pin measures the stand-in too. Her #92(b) is a WIDTH ruling; the
proof must not rest on a substitution. *Fix:* one geometry case hosting
the REAL `MobileLibraryView`, reading the sort door's frame by
`MobileSortDoor.label`; correct the record's RED ON OLD (2) to name the
file the revert edited; keep the component cases.

**M2 [MAJOR] · the record §7 + `KnownIssuesAndTechDebt.md` · MEASURED.**
The handover baseline does not reproduce: two full-suite runs both ended
`** TEST FAILED **` at
`MobilePerfWalkTests.typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k`
(13.169 / 12.936 ms vs a 12.0 budget, plus a runner restart) — and
**2/2 green in isolation** (9.4–10.8 ms, 12–22% headroom): the load-flaky
class, NOT this batch's doing (the fence is git-clean; zero editor-path
lines). The defect is the RECORD: §7 says "No other test records an
issue" and quotes `TEST SUCCEEDED` as the next batch's baseline, and the
pin has NO KnownIssues row while its two class-siblings
(`CanvasDragTrackingTests`, the Mac `rewriteStrategyLatencies` pin) both
do, owner 12. *(Second observation of this exact pin under load — §70's
environment note re-ran it isolated green on 2026-08-30.)* *Fix:* amend
§7 with the observed red + isolation result; open the KnownIssues row
beside its siblings, owner 12.

**m3 [MINOR]** · `MobileLibraryView.swift:166` — `isNoteListing` and the
`archiveRow` guard are structurally dead (the rendering branch already
enforces the rule; the clause can never be false; the cited pin proves
the branch, not the guard). *Fix:* drop the clause.
**m4 [MINOR]** · books truncation uses the FILTERLESS rooms' sentence
("Showing the first N.") though the books listing holds the exact total —
its same-surface neighbour (scraps) speaks the two-number sentence.
Plus, flagged as PRE-EXISTING: the resting note listing (`listingRows`)
has NO marker at all — the standing "Bounded view windows" KnownIssues
row is its home; name it in the record. *Fix:* books gets
`truncationMarker(shown:of:)`; record the note listing's silence.
**m5 [MINOR]** · PROVISIONAL 3's sharpest form was missing: the batch
deletes doors on P-2 grounds while "Notes" was a visible no-op beside
"All". **PARTLY MOOTED BY HER #93(b) RULING** (All becomes the
books+notes union, so "Notes" stops being a no-op in the Library); what
SURVIVES is the Archive's two same-set doors (forced until 13i's
book-archiving). *Fix:* fold into the record's PROVISIONAL wording; the
Archive residual joins her bundle.
**m6 [MINOR]** · `MobileFilterRow.identifier` is dead and its doc claims
coverage that does not exist; a row-level frame is also what M1's fit law
wants. *Fix:* use it in the new real-surface geometry case, or delete it
with its claim.
**n7 [NIT]** · each book row computes name+meta twice per body eval (a
smart book pays two JSON decodes); hoist to `let`s (the Shelf's own row
computes once). **n8 [NIT]** · the Library book name renders `body` where
the Shelf's is `body.weight(.semibold)` — a chosen look divergence; one
record line so a look round knows. **n9 [NIT]** · "the SAME hosted tree"
overstates the Dynamic Type control's harness (two windows, one helper) —
say "the same harness"; the experiment itself is real and was reproduced.

## Clean bill (headlines)

The model fact verified independently (no `reading.archived_at`;
`poolPosts` excludes archived; `archivedBlocks` per-note;
`archivedPosts` exact) · books-as-rows is ONE observation + ONE row rule,
production-side red-on-old real · P1 on the new listing real (windowed,
marker driven) · the fit law measures the real COMPONENT with a first
`bounds.width == width` assertion and trips on future doors · the
Dynamic Type finding real, correctly classified pre-existing/app-wide ·
`spokenRow` properly pinned red-on-old · all five doors switch the
listing, driven; sort `.all`-only driven; the menu presents and re-orders
· fence git-clean; `TrashScope`/purge guards/6c rooms untouched; no
`Filter` raw value persisted · the Archive absence assertions read the
RENDERED surface (that, not the populated world, is what makes them
non-vacuous — a precision for the record) · phone-local placement argued
correctly (no Mac twin exists; the two rooms guard each other).

---

# ADJUDICATION + FIX-WAVE BRIEF (the Fable orchestrator, 2026-08-31)

**ALL NINE ACCEPTED, ZERO DISPUTES** — with m5 adjudicated as partly
superseded by her #93(b) (recorded above). **The wave also BUILDS #93(b):
the Library's `All` becomes the books + notes UNION.** One Opus session:

1. **M1**: the real-`MobileLibraryView` geometry case, reading the sort
   door's frame by its label — and MEASURE the Menu element's real width
   at 320 pt: if the real trailing element overflows or triggers
   `minimumScaleFactor`, that is a REAL defect — fix the layout (the
   ruling is fit-without-shrink) and pin at the real surface. Correct the
   record's RED ON OLD (2) honestly. Fold m6 here (use `identifier` for a
   row-level frame bound, or delete it).
2. **M2**: record §7 amended; the KnownIssues row opened beside its two
   siblings (owner 12; note this is the pin's SECOND recorded load-red —
   §70's was the first). Do NOT chase the perf pin itself.
3. **#93(b) — THE UNION**: in the LIBRARY only (the Archive is untouched
   — its coincidence is forced), `.all` lists books + notes interleaved
   under the active sort, each book contributing its NEAREST stamp
   (created sort → `created_at`; touched-class sorts → `updated_at`);
   the mapping is PROVISIONAL — record and pin it. Books rows keep the
   `.books` filter's row rule and window; markers per source as today
   (m4's two-number sentence for books). Drive: `.all` shows both kinds;
   `.notes` shows only notes; a book row opens the book from `.all`.
4. **m3** (drop the dead clause) · **m4** (the two-number books sentence;
   the record names the note listing's pre-existing silence and its
   KnownIssues home) · **m5** (record wording; the Archive residual to
   her bundle) · **n7** (hoist the lets) · **n8** (one record line:
   chosen, not missed) · **n9** ("the same harness").

Rules as every wave: fence (zero `Sources/`/`Shared/`/Mac/EditorBrain/
schema/configs; `KnownIssuesAndTechDebt.md` and record edits are notes
and fine); pins proven red by behavioural revert with quoted output —
and after M1, NO "red-on-old" may be claimed for a fixture revert:
name what was reverted, production or fixture, every time. Own armed
simulator + private DerivedData, deleted after; full mobile suite at the
end (expect the M2 flake possible under load — if it reds, re-run it
isolated and report both, per its new row); quote the final line;
`Package.resolved` never swept; pathspec-limited commit; no pushes.
Append FIX WAVE RESULTS to THIS file before the final message.

---

# FIX WAVE RESULTS (2026-08-31)

**All nine items landed, plus her #93(b) union. +3 tests, 629/96 →
632/96, no suite added. Fence git-clean.** Every revert below is
labelled **PRODUCTION** or **FIXTURE** — the standing rule M1 bought.

| item | verdict | what landed, and the proof |
|---|---|---|
| **M1** | **FIXED — and the record CORRECTED** | New case `theRealLibrarysRowFitsWithoutShrinkingAtDisplayZoom` hosts the REAL `MobileLibraryView` at 402 and 320 pt (`withHostedSurface` gained a `size:`, default unchanged) and reads the real `Menu`'s own frame. **RED ON OLD, PRODUCTION revert** (`sortMenu`'s label → the shipped `Text`): 5 issues, quoted below — while **all three component cases stayed GREEN under that same revert**, which is M1's finding proven from both sides. Record §4's RED ON OLD (2) now carries a dated correction naming the fixture. **The speculative tail is FALSIFIED:** the real Menu reports **16.0 pt**, not ≥44. |
| **M2** | **RECORDED — pin never touched** | Record §7's *"No other test records an issue"* struck and replaced with the observed red + isolation result; **new `KnownIssuesAndTechDebt.md` row**, owner 12, beside `CanvasDragTrackingTests` and the Mac `rewriteStrategyLatencies` pin, naming this as the pin's **second** load-red (`mobile-round-2.md` §70 was the first) and carrying the standing re-run-isolated-and-report-both instruction. *(It passed on this wave's full-suite run: 0.879 s.)* |
| **#93(b)** | **BUILT — the union** | See the two paragraphs below. **RED ON OLD, PRODUCTION revert** ×2. |
| **m3** | **FIXED** | The dead `model.filter.isNoteListing` clause is gone from `archiveRow`, and `MobileListingFilter.isNoteListing` with it — that clause was its ONE reader. The rule is the BRANCH, said so at the branch. **No red available and none claimed** (removing a clause that can never be false is behaviour-preserving by construction); `theArchivedDoorTrailsNoteListingsOnly` still proves the branch and stays green. |
| **m4** | **FIXED + RECORDED** | `MobileRoomListing.truncationMarker(shown:of:)` added beside the one-number form with the reason for both; the books listing speaks it. **RED ON OLD, PRODUCTION revert.** The note listing's PRE-EXISTING silence is recorded in the record (new PROVISIONAL 3b) and routed to the standing *"Bounded view windows show markers, not more"* KnownIssues row, owner 12. |
| **m5** | **FOLDED into the record** | PROVISIONAL 3 struck through and rewritten as OVERTURNED-and-built; the surviving half — the **Archive's two same-set doors** — is named there as hers, already parked by #93(a) at 13i. |
| **m6** | **DELETED with its claim** | `MobileFilterRow.identifier` and its `.accessibilityIdentifier` are gone. Not adopted, because the claim is **unbuildable, not merely unbuilt**: MEASURED on the real surface, `identifiers on the real surface: []` — a container's identifier never reaches the accessibility tree, so a row-level frame bound was never available. The probe stays in the new case as the reason. |
| **n7** | **FIXED** | `bookRow(_:)` extracted (one rule, both doors) with `name`/`meta` hoisted to `let`s — one `MobileShelfFaces` pass per row, so a smart book pays ONE query-spec decode. |
| **n8** | **RECORDED** | New PROVISIONAL 3c: the Library's `body` vs the Shelf's `body.weight(.semibold)` is a chosen divergence with its reason, so a look round sees a choice rather than an oversight. |
| **n9** | **FIXED, both copies** | *"the SAME hosted tree"* → *"through the SAME harness"* in the record's §2 and in the pin's own doc, each naming what it overstated. |

## The union, as built

**The Library's `.all` now interleaves her books with her notes under the
active sort** — one pure brain (`MobileLibraryViewModel.union`) over rows
each kind already had: a book row in the union is `bookRow(_:)`, the same
row the `.books` door renders, with the same Shelf faces, the same
`onOpen(.book(id))` landing, and the same window and (now two-number)
truncation sentence. `.notes` and `.bookless` pass an empty book set and
are byte-unchanged; **the ARCHIVE room is untouched**, its `all`/`notes`
coincidence being forced by the model fact rather than chosen.

**The PROVISIONAL mapping (hers to ratify — the ruling left it
unspecified):** a book contributes `created_at` under **created** and under
**entry date** (a book has no entry date, so it behaves exactly as an
undated note does under core's own COALESCE), and `updated_at` under **last
touched** and **last meaningful edit** (a book has no churn stamp).
Descending, matching the listing's `direction: .desc`; ties break
note-before-book, then source order, so nothing depends on sort stability.
One inherited wart, stated: under entry date a note's stamp may be a bare
day while a book's is a full ISO instant, so a book created on a day sorts
just above a note dated that day — the same lexicographic wart core already
has between dated and undated notes. Pinned by
`theUnionOrdersABookByTheStampTheSortNames`.

## The reds, quoted

**M1 — PRODUCTION revert** (`MobileLibraryView.sortMenu`'s label back to
`Text(tokens.chromeLabel("sort: " + sortWord(model.sort)))`):

```
✘ Test theRealLibrarysRowFitsWithoutShrinkingAtDisplayZoom() recorded an issue
  at MobileFilterRowGeometryTests.swift:511:21: Expectation failed:
  (abs(frame.width - wideWidth) → 22.333333333333343) <= 0.5
↳ Bookless renders 34.66666666666666 pt on the real Library at 320 against its
  57.0 pt ideal — the shipped row is spending its scale factor
✘ … ↳ Scraps renders 39.0 pt … against its 42.66666666666666 pt ideal
✘ … ↳ Sort: last touched renders 44.0 pt … against its 78.33333333333331 pt ideal
✘ … ((ys.max() ?? 0) - (ys.min() ?? 0) → 22.666666666666657) <= (1 → 1.0)
↳ a door left the real row's one baseline band at 320 pt:
  [154.5, 154.5, 154.5, 156.66666666666666, 155.16666666666666, 134.0]
✘ … (sort.width → 44.0) <= (30 → 30.0)
↳ the SHIPPED sort door measures 44.0 pt at 320 pt — #92(b) shrank it to a
  glyph, and the longest stamp word it used to draw is "last meaningful edit"
✘ Test theRealLibrarysRowFitsWithoutShrinkingAtDisplayZoom() failed after 3.196
  seconds with 5 issues.
```

and — **this is the half that proves M1** — under that same PRODUCTION
revert:

```
✔ Test everyFilterDoorLandsWhollyInsideTheSurfaceAtEveryWidth() passed after 2.673 seconds.
✔ Test noFilterDoorIsShrunkToFitEvenAtDisplayZoom() passed after 0.892 seconds.
✔ Test theSortDoorMeasuresAsAGlyphRatherThanASentence() passed after 1.333 seconds.
```

**#93(b) — PRODUCTION revert** (`rows(books:)` → `books: []`, the shipped
note-only listing):

```
✘ Test theLibrarysAllDoorIsTheBooksAndNotesUnion() recorded an issue at
  MobileFilterTests.swift:342:17: Expectation failed:
  labels.contains { $0.hasPrefix("Poems") }
↳ her book does not row under All — labels were ["~/library", "Trash",
  "New Note", "search notes, books…", "All", "Books", "Notes", "Bookless",
  "Scraps", "Sort: last touched", "Newer note", "Older note", "Archived"]
✘ … MobileFilterTests.swift:348:32: Expectation failed:
  labels.firstIndex { $0.hasPrefix("Poems") } → nil
✘ Test theLibrarysAllDoorIsTheBooksAndNotesUnion() failed after 1.823 seconds
  with 2 issues.
```

**The stamp mapping — PRODUCTION revert** (`bookStamp` ignores the sort and
always reads `created_at`):

```
✘ Test theUnionOrdersABookByTheStampTheSortNames() recorded an issue at
  MobileFilterTests.swift:407:9: Expectation failed:
  (MobileLibraryViewModel.union(notes: [note], books: [book],
   sort: .lastTouched).map(\.id) → ["note:note", "book:book"])
  == ["book:book", "note:note"]
✘ … sort: .lastMajorRevision … → ["note:note", "book:book"])
  == ["book:book", "note:note"]
✘ Test theUnionOrdersABookByTheStampTheSortNames() failed after 0.007 seconds
  with 2 issues.
```

**m4 — PRODUCTION revert** (the books line back to the one-number
sentence):

```
✘ Test theBooksListingIsWindowedAndSaysSo() recorded an issue at
  MobileFilterTests.swift:224:17: Expectation failed:
  (labels → [… "Aster, 0 notes", "Basil, 0 notes", "Showing the first 2."])
  .contains(MobileRoomListing.truncationMarker(shown: 2, of: 3)
  → "Showing the first 2 of 3.")
✘ … MobileFilterTests.swift:226:17: Expectation failed:
  !((labels → […]).contains(MobileRoomListing.truncationMarker(shown: 2)
  → "Showing the first 2.") → true)
↳ the books listing still speaks the one-number sentence
✘ Test theBooksListingIsWindowedAndSaysSo() failed after 1.564 seconds with 2
  issues.
```

## The real surface's measurements (M1's dump, re-runnable under `REAL-FILTER-ROW-GEOMETRY`)

```
402 pt · real: All=20…41(w21.3) Books=52…88(w35.7) Notes=99…134(w35.7) Bookless=145…202(w57.0) Scraps=213…256(w42.7) Sort: last touched=366…382(w16.0)
320 pt · real: All=20…41(w21.3) Books=52…88(w35.7) Notes=99…134(w35.7) Bookless=145…202(w57.0) Scraps=213…256(w42.7) Sort: last touched=284…300(w16.0)
identifiers on the real surface: []
```

Every door renders at its 402 pt ideal width at 320 pt — **nothing is
shrunk on the shipped surface**, which is her fit-without-shrink ruling
measured where it lives; the real sort door ends flush at x=300 inside the
280 pt content box (320 − 20 pt padding a side). The component dump's
`sort=285…298` and this `284…300` differ by exactly the stand-in's 13 pt vs
the real Menu's 16 pt — the substitution M1 named, now bounded on both
sides.

## Counts and environment

**Baseline:** the record's own final line — *"Test run with 629 tests in 96
suites passed after 244.000 seconds with 2 known issues."*

**This wave's final line, quoted:**

```
✘ Test run with 632 tests in 96 suites passed after 232.305 seconds with 2 known issues.
** TEST EXECUTE SUCCEEDED **
```

Arithmetic exact: 629 + 3 = 632, no suite added —
`theRealLibrarysRowFitsWithoutShrinkingAtDisplayZoom` (geometry),
`theLibrarysAllDoorIsTheBooksAndNotesUnion` and
`theUnionOrdersABookByTheStampTheSortNames` (behaviour). The 2 known issues
are the same single documented diagnostic
(`anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`, two
issues from one `withKnownIssue` block). **The M2 pin passed on this run**
(0.879 s) — reported per its new row, which asks for both numbers whenever
it reds.

**Environment:** worktree `~/dev/variorum-mobile`, branch `mobile`. Private
simulator `Variorum-filterfix` (iPhone 17 Pro, iOS 26.2,
`ApplicationAccessibilityEnabled` armed and read back `1`), private
`-derivedDataPath` under this session's scratchpad; the simulator was
**deleted at the end**. Fence verified before the commit —
`git diff --name-only -- Sources/ App/Variorum/Shared App/Variorum/Variorum
"*.xcodeproj" "*.pbxproj" EditorBrain Package.resolved Package.swift`
returned empty. No Release build, no install, no push; the real store
untouched, the live Mac app never quit.

## For her bundle

- **The union's stamp mapping is PROVISIONAL** (the table above) — one
  switch if she wants a book ordered otherwise.
- **The Archive's two same-set doors** survive m5, and #93(a) already owns
  the reason: book archiving is 13i's.
- Everything else in the record's PROVISIONAL list stands as it did, with
  3 rewritten, 3b/3c added, and 5 amended.
