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
