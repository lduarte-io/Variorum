# 13n-a — review ladder, round 1 (cold reviewer, `opus-reviewer`)

Diff under review: `git diff 062e8534..HEAD` on `vx-117-13n-a` (the whole effort, through `a8645284`).
Prompt: `notes/REVIEW_PROMPT.md`, verbatim, `{PHASE}` = 13n-a. Anchor: `notes/plans/phase-13n-a-document-format.md`
(+ the sitting record `notes/plans/phase-13n-sitting-record-2026-10-09.md`). The plan has no "Review foci" section.

**Scope check (first, per the brief):** the diff touches no editor-seam file (`EditorTextView`, `BlockRangeIndex`,
`PaneSurface`, the read tier; `CommitBar` / `TakesBottomBar` change only their `note ▾` menus), no custody or keychain
code, zero `Sources/VariorumCore/Sync/` lines, no schema or migration, and no default's meaning. `opus-reviewer` is the
right reviewer; no re-spawn as `fable-reviewer` is needed.

**How the bug-class findings were checked:** the probes for F1, F4 and F5 ran in a scratch COPY of the core package
(`swift test --filter ReviewerProbes13na`, outside the worktree). The worktree was never edited apart from this
record. The scratch results are quoted under each finding. The app-side findings (F2, F3, F6, F7) are traced by
reading. Their pins are Mac-app tests, and those need a held stage claim, which a reviewer doesn't take.

STATUS: ROUND 1 COMPLETE — 0 BLOCKER · 1 MAJOR · 4 MINOR · 4 NIT; clean bill below.

## Findings (severity-ranked)

### F1 · [MAJOR] · `Sources/VariorumCore/Operations/Operations+DocumentImport.swift:264-280` (`reapplyImportedBook`)

**What's wrong.** The redo of a folder import picks its revival stamp from the BOOK's tombstone
(`let stamp = reading.deletedAt`). It then revives only the notes that died on that stamp, and always revives the book.
Suppose the book died by her own hand before the undo. `deleteReading` registers no undo entry and does not clear the
stack, so the import's entry is still on top. The undo (`revertImportedBook`) skips the dead book and tombstones the
imported notes on a NEW stamp. Then the redo:

- takes the book's OLD stamp,
- matches none of the notes (they died on the new stamp, so they stay in the Trash), and
- calls `restoreReadingRows`, which brings back the book she deleted: an empty book with its chapters on the
  Bookcase.

**Why it matters.** Undo followed by redo lands in a state that never existed. AppSpec §9 requires an undo↔redo
round-trip that returns the same rows ("an exact-row redo built from do-time pre-images"). The reachable sequence is
ordinary:

1. Import a folder.
2. Delete the book (the plain Delete: book only, the notes go to the Pool).
3. Press ⌥⌘Z to get it back. Because the top entry is the import, this removes the notes.
4. Press ⇧⌥⌘Z to undo that surprise. The empty book returns and the notes stay in the Trash.

13n-b will register many more undo entries of this shape for MCP writes (R-13n-6), so this pair should be right before
it becomes the template.

**Evidence (traced, then run).** The probe ran in the scratch copy against the code at `a8645284`: import book →
`deleteReading` → `stack.undo` → `stack.redo`. Result:

```
✘ … Expectation failed: try db.deletedAt("container", postID) == nil   ↳ redo should revive the imported notes   (×2)
✘ … Expectation failed: try db.deletedAt("reading", result.reading.id) != nil   ↳ redo should not resurrect the book she deleted herself
```

**Red-on-old pin.** `DocumentImportOperationTests.redoAfterTheBookWasDeletedByHandReturnsTheNotesNotTheBook` runs the
probe's sequence and asserts two things after the redo:

- every imported note is live, and
- the book's tombstone is still her own.

Both assertions are red at `a8645284`.

**Proposed fix.** Key the redo on the stamp the INVERSE wrote, not the book's:

- Revive the imported notes that died on that stamp.
- Revive the book only when its tombstone equals that stamp. If it died on another stamp, the book half of the redo
  is obsolete and quiet, as the pair's own "already dead ⇒ obsolete" doctrine says.

To get that stamp, either capture a reference box shared by the two closures, or derive it from the imported notes'
common tombstone (the inverse writes one stamp for all of them). If no imported note is dead, fall back to the book's
stamp.

### F2 · [MINOR] · `App/Variorum/Variorum/Features/Shelf/ShelfView.swift` (the new `.onDrop`) + `Operations+DocumentImport.swift:95-110` (`importBook` has no `shelfId`)

**What's wrong.** The Bookcase drop is not a context mint, so a dropped folder's book lands where she can't see it.
`ShelfViewModel` opens the board solo'd on her DEFAULT shelf whenever one is set (`ShelfViewModel.swift:219`:
`scope = prefs.defaultShelfID.map(BookcaseScope.shelf) ?? .all`). The Bookcase's own New Book door is a context mint
(`ShelfView.swift:305`, `shelfId: $0` from `model.mintShelfID`). The new drop calls `importBook`, which always mints
the book UNSHELVED. Under a solo, an unshelved book is in no shelf's view (AppSpec §12: unshelved shows at the top of
All only). So the drop's book does not appear on the board she dropped it on. The only signal is the receipt, which is
quiet by default.

This contradicts:

- the drop's own comment in `ShelfView` ("The board stays put: the new book appears on it"),
- IC-14 ("the new book appears on it"), and
- §12's contract line "new books land unshelved, a context mint lands on the solo'd shelf". The sitting record §19.1
  gives the reason: "you're looking at where you're filing".

**Evidence.** Traced:

- `BookcaseImportDrop.performDrop` → `DocumentImporter.importURLs` → `importBook(book, wingId:)`.
- `Reading(... wingId:)` is built with no `shelfId`.
- `BookcaseBoard.mintShelf(for: scope, …)` is never consulted.

**Red-on-old pin.** An app door test: set the board's scope to a solo'd shelf, drop a folder, and expect the minted
book's `shelf_id` to equal the solo'd shelf's id. Red today (nil).

**Proposed fix.** Give `importBook` a `shelfId:` parameter, validated live and same-wing exactly as `createReading`
validates it. Pass `model.mintShelfID` from the drop. File ▸ Import… keeps nil, as the plan's letter says. The plan's
"the book lands unshelved" was written for the op. If the orchestrator reads the plan's letter as also covering the
drop, this is product-flavored: log it to QUESTIONS with (a) the context mint (spec-defensible) and (b) unshelved as
built, plus a receipt that names where the book went.

### F3 · [MINOR] · `App/Variorum/Variorum/Features/Import/DocumentImportCopy.swift` (`receipt(_:)`) + `DocumentImporter.swift:131-135`

**What's wrong.** The receipt can say "to the Pool" about a note that is not in the Pool. Every `.note` landing is
worded "Imported “…” to the Pool", and the multi-item form says "N notes to the Pool". But `importDocument` applies
header tags through the ONE application road. That is IC-8, pinned by `aTagHeardByALivingBookSeatsTheImportedNote`:
a living book whose rule hears the tag SEATS the note as a member under the default join-quietly dial. A seated note is
not bookless, and the Pool is bookless notes only (AppSpec §12; the 13i-c readers count book rows). AppSpec §12 holds
that a receipt says what landed, and this one says something false.

**Evidence.** Traced:

- `importDocument` → `applyDocumentTags` → `insertPostTag` → `intakeAfterTagging` → `materializeIntake(.seat)`.
- `DocumentImportLanded.note` carries only `postID` and `title`, so the copy has no way to know.

**Red-on-old pin.** An app door test imports a lone file with `{#dream}` beside a living book ruled on `dream`. It
expects the receipt not to contain "to the Pool" (or to name the book). Red today.

**Proposed fix.** In the same runner turn, read whether each note is bookless after its op. Carry that on `.note`, and
say "to the Pool" only when it is true. Otherwise say e.g. "…, collected by “dream journal”", in her sentence case.

### F4 · [MINOR — spec silence → QUESTIONS] · `Sources/VariorumCore/Domain/VariorumDocumentFolder.swift:113-123` + `VariorumDocument.swift:361`

**What's wrong.** Fail-honest reaches EMPTY STUB FILES in a folder. A blank, whitespace-only or TITLE-ONLY file
(`{t:"Chapter 3"}`) anywhere in a folder refuses the WHOLE book with "there's nothing in it to import". The plan rules
that "an entirely empty document refuses" for `importDocument`. It is silent on a stub inside a folder. Stubs are
exactly what a writer leaves in an outline, and what an LLM scaffolding a book writes.

The same rule refuses one of her own exports. A TITLED note with no text yet copies (Copy for AI refuses only an empty
string) as the header line alone, and that output re-imports as `.empty`. That cuts against R-ARCH-13na-2's "any
export re-imports whole".

**Evidence (run).** The scratch probe `probeEmptyStubRefusesTheWholeFolder` passed. For each of `""`, `"\n"` and
`{t:"Chapter 3"}`, `VariorumDocumentFolder.plan` threw `.empty` with `file == "ch/b.md"`, refusing the folder. The
parser test `everyMalformedSectionRefusesNamingItsLine` pins `{t:"Only a title"} {#a}` → `.empty`.

**This is not a bug ruling.** Product silence becomes a QUESTIONS entry. Proposed options:

- (a) As built: refuse the folder.
- (b) A stub mints an EMPTY NOTE: one empty block, the title from its header or else its file. This is the store
  shape a fresh New Note has. It makes Copy for AI's output of a titled empty note re-importable, and it keeps the
  single-file door's "nothing to import" refusal for a truly blank file. Spec-defensible: R-13n-8's round trip.
- (c) Skip stubs, with the receipt naming them.

No pin until ruled.

### F5 · [MINOR — clarity, ahead of canon] · `Sources/VariorumCore/Domain/VariorumDocument.swift:36-58`, the operations header comment, and the plan's R-ARCH-13na-1 / "THE DOMAIN" text

**What's wrong.** The round-trip claims go further than the format can carry. The ruling text says "ROWS round-trip
(an export re-imports to the same store shape…)". The source says "Rows therefore round-trip … for every block the join
writes distinguishably" and "Any export re-imports whole … reads as exactly that block". But the export never writes:

- the CHOSEN take's label,
- the chosen take's place in the fan, or
- a chosen ≠ default split.

So any fanned block whose chosen take is labeled, or isn't first in the fan, re-imports changed. The label is dropped,
the fan rotates (the chosen take moves to the front), and chosen and default collapse into one take. That is the
ordinary state of her PT/EN Lenses notes once she has picked a language. Locked and archived state don't ride either.
The recorded "blank-chosen fan after a fanless paragraph" corner is in the plan record but not in the source's
"exactly that block" sentence.

**Degradation.** The closeout writes AppSpec §9/§12 contract lines from these sentences. "Rows round-trip" would land
in canon as a false contract, and 13n-b's tools would lean on it.

**Evidence (run).** In the scratch probe `probeChosenTakeNotFirstRoundTrip`, the original fan was [`A first.`,
`B chosen.` labeled "pt", chosen]. The imported fan was `[("B chosen.", nil), ("A first.", nil)]`. The existing row
pins all keep the chosen take first and unlabeled, so they cannot see this.

**Proposed fix.** State the domain exactly in the source doc comment and in the closeout's §9 proposal:

- the chosen take is first in the fan, unlabeled, and is the default;
- no locked or archived state;
- the fanless-paragraph corner.

Add one QUESTIONS line asking whether the format should carry the chosen take's label (her bilingual notes label both
languages; a Copy for AI → re-import loses the chosen one's).

### F6 · [NIT] · `Sources/VariorumCore/Operations/Operations+DocumentImport.swift:130-134` + `DocumentImporter.swift:128-143`

**What's wrong.** IC-13's "a refused gesture leaves nothing" holds for the NAME refusal only. Any other op refusal on
item 2 or later of a multi-item gesture makes `withCompound`'s rollback run the earlier items' INVERSES, and those
tombstone. Examples: a chapter folder whose name trims to empty (`invalidSectionName`), or the wing dying mid-flight.
Item 1's note or book lands in the Trash beside a refusal that says nothing landed.

**Pin.** A door test with [`a.md`, a folder holding a `" "` subfolder] expects the Trash to be empty. Red.

**Fix.** Refuse a blank chapter name in `VariorumDocumentFolder.plan`, so it fails honest before anything mints like
every other folder refusal.

### F7 · [NIT] · `App/Variorum/Variorum/Features/Import/DocumentImporter.swift:184-195` (`readFolder`)

**What's wrong.** `.skipsPackageDescendants` skips a package's CONTENTS but still yields the package directory itself.
`isDirectory` is true for it, so it is appended to `subfolders` and becomes an EMPTY CHAPTER named after the package.
For example, an `.rtfd` (always a system-declared package) or a `.textbundle` (Bear/Ulysses Markdown export, a
package wherever an app declares it) becomes a chapter "x.rtfd" / "x.textbundle", and its contents are never read.

**Pin.** A door test with `a.rtfd/TXT.rtf` beside `b.md` expects no chapter. Red: one empty chapter named "a.rtfd".

**Fix.** Read `.isPackageKey`, and skip the package or refuse it by name.

### F8 · [NIT — architecture] · `App/Variorum/Variorum/Features/Import/DocumentImporter.swift:302-331` (`CopyForAI`) + `:244-300` (`BookcaseImportDrop`)

**What's wrong.** One file in the Import feature holds four concerns:

- the import act,
- the panel,
- the Bookcase's drop delegate (consumed by Shelf), and
- `CopyForAI`, the EXPORT/push face consumed by Editor (`CommitBar`), Takes (`TakesBottomBar`) and the Registry
  (`ShellActions`).

**Degradation.** A reader looking for the clipboard export won't look in the importer. CLAUDE.md's shared-home rule
(a thing two features consume moves to the shared home at the next touch) points the other way.

**Fix.** Move `CopyForAI` to a shared home (`Core/` or beside the registry actions) at the next touch. No behavior
change.

### F9 · [NIT — a known-limits line, not a fix] · `VariorumDocument.swift:275-282` with `serialize` `:215-219`

**What's wrong.** A document with no header has its FIRST NON-BLANK LINE read by the capture grammar anyway. Copy for
AI writes no header for a note with no stored title and no tags. The plain export (`exportPost`) never writes one.
So such a note whose first line contains a literal `{#…}` or `{t:"…"}` re-imports with those tokens stripped from its
text and applied as a tag or title. A note about the capture syntax is the obvious case. The export→import pins can't
see this: their first lines carry no braces.

**Proposed.** Add it to the unit record's "Known limits" (the format has no escape), next to the `"}`-in-a-title line.
Optionally, Copy for AI could always write a header when the first line holds a `{`. A title token is the only header
it can write, so this is a design call, not a quick fix.

## Proposed QUESTIONS lines (for the merge-moment ledger; not written here)

- **F4:** a blank or title-only file inside an imported folder. Refuse the book (as built), mint an empty note, or skip
  it and name it?
- **F5:** should the format carry the chosen take's label (and so its fan position)? Today a Copy for AI →
  re-import of a picked-language note drops it.
- **F2:** only if the orchestrator reads the plan's "unshelved" as covering the Bookcase drop. Context mint vs
  unshelved.

## Clean bill (checked and found solid)

- **The four 13n-a core suites, run here:** `swift test --filter 'VariorumDocumentTests|DocumentFormatRoundTripTests|DocumentImportOperationTests|SampleBookDrillTests'`
  → 42 tests / 4 suites, all passed. This matches the fix-pass record (42/4). I did not run the full core suite
  (session discipline). The Mac app suites (record: 297/40 + 6/2, 38/38) are stage-gated and were not re-run; they
  are claims on the record, not things verified here.
- **The capture grammar's move is byte-for-byte.** `CaptureTokens.parse` / `readLine` / `token` / `isQuote` /
  `isHorizontal` match the removed `CaptureMicrosyntax` bodies line for line. The app's `parse` only re-wraps into its
  own `Capture`. `TagPath.segments` is exactly the old `TypedTagPath.segments`. One brain.
- **The enabling refactors are behavior-identical.** `git diff -w` shows `restoreReading` → `restoreReadingRows`
  and `assertBookNameIsFree` → `requireBookNameFree` move bodies unchanged. `adopt` → `adoptPath` keeps the mint chain
  and returns nil only where `adopt` used to throw `tagNotFound`, which it still throws. `mintFanBlock` changes
  visibility only.
- **The export stays byte-identical through the re-expression.** `exportBlocks` + `serializeBody` reproduce the old
  loop exactly. Text is skipped when blank; a callout maps to a blockquote before the emptiness test, the same order as
  before; the section is appended only for a non-blank alternate. `VariorumDocument.alternatesSection` re-filters
  already-filtered takes, so the numbering is unchanged. `Queries.alternatesSection` forwards.
- **The inverse-join reading is correct within its stated domain.** I traced `joinRenderedTexts`: m = 0 → k = 2;
  m ≥ 1 → k = m + 1. `storedSpacing(b) = b ≥ 2 ? b : 0` inverts it, with m = 1 the join's genuinely undecidable value.
  A fanned block's spacing sits between its text and its section, and the parse's `beforeSection` handles it. A
  section never ends in a newline, so the run after a footer is always the separator. `takeText` drops exactly the
  one serializer blank line per side, so leading or trailing blank lines inside a take survive.
- **Undo for the happy paths and the stated refusals.** One entry per op, folded by the face's `withCompound` into one
  per gesture. The inverse tombstones on one stamp. The redo revives notes through `restoreNoteFamily` BEFORE
  `restoreReadingRows`, so memberships in the imported book revive through the book's exact-stamp pass and
  memberships in other live books through the note's. `enforceOwnershipAfterRevival` is re-run for the revived notes.
  The daily-Journal guard on the inverse matches `deleteReading`'s marker key. Her own note filed into the imported
  book survives the undo (pinned). F1 is the one hole.
- **Invariants.** I10: every minted block has a live take, and a blank-chosen block still has its section's takes.
  I2/I3: one placement, `chosen_variant_id` on the pointer, `default_variant_id` set. S1/S2: ordinary inserts and
  tombstones through the outbox triggers. Zero `Sync/`, zero schema, marker untouched. Touch without churn,
  baseline = rendered length (IC-7). Imported notes can never classify as versions (`archived_at` stays nil).
- **Tags.** Adopted-else-minted by path in the destination wing through `insertTag` (createTag's body, the same
  validation), applied once each, and heard by intake through `insertPostTag`. Intake's ownership conflicts resolve in
  the pure verdict, never a throw, so a tag heard by an OWNED living book can't abort an `importBook` transaction.
- **E13.** The in-transaction `requireBookNameFree` plus the app's name preflight (trimmed, `BookNaming.key`,
  within-gesture duplicates). A name collision refuses before anything is minted (pinned on the door).
- **The registry (P-1/P-2).** `.importFiles` ("Import…", menuBar + palette + surface) and `.copyForAI` (post,
  bottomBar + palette, `noteScoped`) are declared once. The walk's surface union gains `ShelfView.surfaceCapabilities`.
  `CommitBar` hides Copy for AI in the scraps context (a pool is not a note). The palette path refuses with the
  registry's note when no note is active. No stale "Import Files…" string remains in `App/` or `Sources/`.
- **Copy for AI reads only.** It flushes the note's pending typing first, goes through the ONE serializer, and writes
  no row (the outbox pin). Its header uses the STORED title only (IC-11) and the tags by path.
- **The drop.** It lights only for `.fileURL` drags (§12's false-offer rule at the type level), the outline is
  token-coloured with no literal colour, and hit testing is off.
- **P1.** Every new cost scales with what is imported or copied (edit-sized). The only corpus-shaped read is E13's
  existing all-live-books scan, unchanged.
- **Honesty of the record.** The unit record states first that the GUI walk (W1–W7) is HELD, so the acceptance unit
  has not closed on use-shaped evidence. The headless `SampleBookDrillTests` is evidence, not the walk. That is
  recorded correctly, not hidden.
