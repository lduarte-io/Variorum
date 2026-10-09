# 13n-a — review ladder, round 2 (cold reviewer, `opus-reviewer`)

Diff under review: `git diff ac9b4b99..HEAD` on `vx-117-13n-a` (the fix round, through `d7cdd562`).
Prompt: `notes/REVIEW_PROMPT.md`, verbatim, `{PHASE}` = 13n-a. Anchor: round 1's findings and the
orchestrator's dispositions (`notes/plans/13na-ladder-round1.md`), the plan's LADDER FIX ROUND record
(`notes/plans/phase-13n-a-document-format.md`), and the canon the prompt names.

**Scope check (first, per the brief):** the fix round touches no editor-seam file, no custody or keychain code,
zero `Sources/VariorumCore/Sync/` lines, no schema or migration, and no default's meaning. `ShelfView` changes one
`.onDrop` argument; `CopyForAI` moves files. `opus-reviewer` is the right reviewer; no re-spawn needed.

**How claims were checked:** the four 13n-a core suites and the twelve export/paste suites were run in the
worktree. Every probe and every revert ran in a scratch COPY of the core package, outside the worktree. The worktree
was never edited apart from this record. The app-side changes (F2, F3, F6, F7, F8) were traced by reading. Their pins
are Mac-app tests that need a held stage claim, which a reviewer doesn't take.

STATUS: ROUND 2 COMPLETE — 0 BLOCKER · 0 MAJOR · 1 MINOR · 3 NIT; per-disposition verdicts and the clean bill below.

## Findings (severity-ranked)

### R2-1 · [MINOR] · `Sources/VariorumCore/Operations/Operations+DocumentImport.swift:174-181` + `:269-288` — a retried undo overwrites F1's stamp, so the redo strands a book

**What's wrong.** F1's fix hands the redo the stamp the undo wrote, through a box (`undoneOn`). The inverse
(`revertImportedBook`) returns `DateFormatter.variorumISO8601.string(from: now)` every time it runs, including when
it tombstoned NOTHING because everything was already dead. The closure then stores that value unconditionally
(`undoneOn.setValue(stamp)`, `:179`). A retried inverse therefore replaces the stamp the rows actually died on with a
stamp no row carries.

`UndoStack` promises that a retry is safe. `withCompound`'s inverse runs the collected inverses newest-first
(`UndoStack.swift:224-228`). A compound whose inverse fails partway stays on the stack (`:282`, `:187-189`: "the
inverses it already ran are idempotent … so a retry is safe"). F1's box breaks that promise for the import entry.

**Mechanism (traced, then run).** Consider a two-folder gesture, [Alpha, Beta], folded into one compound.

1. She designates Alpha as THE daily Journal. The plausible case is importing an old journal folder and making it
   her Journal.
2. ⌥⌘Z. Beta's inverse runs first and commits (Beta and its notes die on stamp S, and Beta's box is set to S). Then
   Alpha's inverse throws `dailyJournalCannotBeDeleted`. The compound stays on the undo stack.
3. She moves the designation to another book and presses ⌥⌘Z again. Beta's inverse finds everything dead, writes
   nothing, and returns a fresh stamp S′. Beta's box becomes S′. Alpha's inverse succeeds.
4. ⇧⌥⌘Z. Alpha comes back. Beta's redo looks for rows that died on S′, finds none, and Beta and its notes stay in
   the Trash.

The redo has landed in a state that never existed (Alpha back, Beta not), which breaks AppSpec §9's undo↔redo round
trip, the class F1 was about. The pre-F1 redo keyed on the book's own tombstone (S) and brought Beta back, so the
fix round introduced this regression.

Scratch probe `probeCompoundRetryThenRedoBringsBothBooksBack` (import two books in `withCompound` →
`setDailyJournalBook(Alpha)` → undo throws → `setDailyJournalBook(other)` → undo → redo → expect both books and Beta's
note live):

- **current code:** RED, 2 issues (`deletedAt("reading", Beta) == nil` and `deletedAt("container", Beta's note) == nil`
  both fail);
- **with `reapplyImportedBook` reverted to the pre-F1 book-stamp logic:** GREEN.

**Why MINOR and not MAJOR.** The consequence is the same class as F1, but reaching it takes six deliberate steps,
including a refusal she has to resolve, against F1's four ordinary ones. It needs a multi-folder gesture. Put back
from the Trash returns Beta whole, so nothing is lost.

**Red-on-old pin.** Use the probe above as
`DocumentImportOperationTests.aRetriedCompoundUndoStillRedoesEveryBook`. It is red on the current tree, which is the
"old" this fix replaces.

**Proposed fix (verified in scratch).** `revertImportedBook` returns `String?`: the stamp only when it tombstoned at
least one row, and nil when it wrote nothing. The inverse closure sets the box only on non-nil
(`if let stamp = … { undoneOn.setValue(stamp) }`). In scratch, that change turned the probe green and kept all 20
`DocumentImportOperationTests` green, F1's pin included.

**For VX-119.** Its class sweep will apply F1's template (key the redo on the undo's stamp) to
`revertMintedContainer` and its siblings. It must carry this rule with it: an inverse that tombstones nothing never
overwrites the stamp, or each fixed pair inherits this regression.

### R2-2 · [NIT — clarity ahead of canon, F5's residual] · `Sources/VariorumCore/Domain/VariorumDocument.swift:49-75` + the plan's closeout proposal ("AppSpec §9 … The round-trip sentence")

**What's wrong.** F5's stated domain is now mostly exact, but it still overclaims for BLANK content. It says
export → re-import gives "the same fan MEMBERSHIP" and that "any export re-imports — never refused, every take
arriving". But the export skips blank takes (`serializeBody` / `alternatesSection` filter `!$0.text.isEmpty`;
`Queries.blockTakes`: "live ACTIVE non-blank alternates"), and the import filters them too (`mintDocument`'s
`takes = block.alternates.filter { !$0.text.isEmpty }`). So two things are lost:

- a blank NON-chosen take (New Blank Take's own product, before she types) does not arrive, so the fan shrinks;
- an empty fanless block (the Return key's abandoned empty block, which AppSpec §7 says "stays") is not re-minted at
  all, so the block count changes.

**Evidence (run).** Scratch probe `probeBlankTakesAndEmptyBlocksDoNotRoundTrip`. A note shaped
[["A", ""], [""], ["C"]] (texts per block, in fan order) copied as `{t:"N"}\n\nA\n\nC` and re-imported as
[["A"], ["C"]].

**Degradation.** This is the same as F5's: the closeout writes the AppSpec §9 sentence from this text, and "every take
arriving" / "the same fan membership" would land in canon as false for blank content.

**Proposed fix (wording only, no pin).** A wording fix has no behavior to pin. Qualify both sentences, for example:

- "the same NON-BLANK fan membership (blank takes and empty blocks carry no text and are not exported)";
- "every non-blank take arriving".

Change the doc comment and the closeout proposal to match.

### R2-3 · [NIT — a known-limits line F9 made stale] · `VariorumDocument.swift:305` (F9's tokens-alone header) vs the plan's "Known limits" (`phase-13n-a-document-format.md` ~line 459: "a title containing `"}` or a tag path containing `}` cannot ride the header line")

**What's wrong.** Tag names may hold braces: `insertTag` refuses only empty names and `/`. Copy for AI writes such a
tag as `{#a}b}`. The capture grammar reads `{#a}` and leaves `b}` behind. Before F9, the header still applied: the
title survived, every other tag survived, and the fragment became a stray block. Since F9, the leftover `b}` means the
line is not tokens-alone, so the WHOLE header line becomes body text, and the title and every other tag go with it.
The same happens for a title containing `"}`, or a tag holding `{`.

The known-limits line still describes only the one token that "cannot ride", not the whole header dropping.

**Evidence (run, both sides).** Scratch probe `probeBraceInTagNameLosesTheWholeHeader` used a note titled
"My title", tagged `plain` and `a}b`, with body "Body.".

- **current tree:** title nil (named "file" by its file), 0 tags, blocks
  `[["{t:\"My title\"} {#a}b} {#plain}"], ["Body."]]`;
- **F9's line reverted:** title "My title", 2 tags (`a` truncated, `plain`), blocks `[["b}"], ["Body."]]`.

**Why only a NIT.** F9's rule is the orchestrator's ruling, and the outcome is arguably more honest: no wrong tag `a`
is minted, and her header stays visible as text. But the record should say what now happens.

**Proposed fix.** Pick one (an orchestrator call):

- (a) Record it: amend the known-limits line to "… cannot ride; since F9 one such token turns the whole header line
  into body text (the title and every tag with it)".
- (b) Have the serializer omit tokens that cannot ride (a tag path holding `{` or `}`, a title holding `"}`), so the
  header stays tokens-alone and the title and other tags survive. The probe becomes the pin, red today.

### R2-4 · [NIT — record precision; input for VX-120] · the plan's added known-limits line ("a PACKAGE inside an imported folder (`.rtfd`, `.textbundle`) is passed over")

**What's wrong.** Whether a directory is a package depends on the Mac. The code comment at `DocumentImporter.swift:212`
says it correctly ("a `.textbundle` where an app declares one"), but the record line does not.

**Evidence (run on this Pro, a headless `FileManager` enumerator probe with F7's options and keys):**

| Directory | `isPackage` | What F7's walk does |
|---|---|---|
| `a.rtfd` | true | skipped |
| `x.textbundle` | false (no app on this machine declares it) | walks as a chapter "x.textbundle", its `text.md` imported as a note |
| `percy.v2` | false | walks as a plain folder, so a chapter |

**Proposed fix.** One word in the record: "a PACKAGE (an `.rtfd`; a `.textbundle` where an app declares one) …". The
`percy.v2` row is VX-120's first probe answered on this machine. The false-refusal and silent-skip worry does not
arise for an unregistered extension here, though the ticket should still probe the Air.

## Per-disposition verdicts (round 1's dispositions, against the fix-round diff)

| # | Disposition | Verdict | Evidence |
|---|---|---|---|
| F1 | Key the redo on the undo's own stamp; revive the book only on a stamp match | **Implemented as worded.** It introduced R2-1, a retry regression. | Pin `redoAfterTheBookWasDeletedByHandReturnsTheNotesNotTheBook`: green in the worktree. In scratch, red on the reverted pre-F1 redo with exactly the record's 10 issues. |
| F2 | `importBook(shelfId:)`; the drop passes the solo'd shelf; All gives unshelved; PROVISIONAL | **Implemented as worded.** | Validation is byte-identical to `createReading`'s (`Operations+Reading.swift:66-71`). The drop reads `model.mintShelfID`, the New Book door's own rule, so the virtual starred shelf lands unshelved like New Book (P-17y-B3-s4). File ▸ Import… passes nil. P-13na-6 is recorded. The door pin was traced by reading (stage-gated). |
| F3 | The receipt says "to the Pool" only for a still-bookless note, otherwise names the book | **Implemented as worded.** | `Queries.noteMemberships` (live BOOK rows, `status='member'`) is the Pool's own membership truth, read in the same runner turn after the op's write committed. It is not nested in a write, and it runs off-main on the runner actor. The copy is exhaustive over the landing cases. The door pin was traced by reading. |
| F4 | A stub mints an EMPTY note (option (b)), PROVISIONAL, plus a QUESTIONS line | **Implemented as worded.** Option (b)'s own carve-out is kept: a lone blank file still refuses. FR-1 (zero blocks) follows ⌘N's real shape: `LibraryViewModel.createPost` and `ShellActions.newPost` both call `ops.createPost`, which mints no block. | In scratch, the 5 pins went red on the reverted parse/folder/op guards, 1 issue each, matching the record. |
| F5 | State the round-trip domain everywhere it appears, plus a QUESTIONS line | **Implemented, with a residual** (R2-2: blank takes and empty blocks are still overclaimed). | The type doc comment and the closeout proposal were both rewritten, and the QUESTIONS line is proposed in the closeout list. |
| F6 | The planner refuses a blank chapter name; the class is recorded | **Implemented as worded.** | Core pin: in scratch, red on the removed check (2 issues). The door pin was traced: `[a.md, "spaced book"]` refuses at the plan, with no container and no undo entry. The class is in the known-limits line. |
| F7 | `readFolder` passes a package over; a known-limits line | **Implemented as worded.** The record line is imprecise (R2-4). | `.isPackageKey` is read before `.isDirectoryKey`. Probe on this Mac: `.rtfd` is a package, so it is skipped. |
| F8 | `CopyForAI` moves to the shared home now | **Implemented as worded.** | The body diff against `ac9b4b99` is the two string references only, and the statics moved with it. Callers (`CommitBar`, `TakesBottomBar`, `ShellActions`, the door test) need no edit. The project uses synchronized groups, so no pbxproj change is needed. `Core/Views` is Mac-only, so its `import AppKit` is legal there. |
| F9 | The header is a header only when it is tokens alone; retires the known limit | **Implemented as worded.** It widened a different recorded limit (R2-3). | In scratch, red on the reverted header rule: 2 tests, 8 issues, matching the record. |

Adjuncts VX-119 and VX-120 are ticketed with probe-first instructions. They are not in this diff and are not reviewed
here, except for the R2-1 note for VX-119 and the R2-4 probe answer for VX-120.

## Clean bill (checked and found solid)

- **Suites, run here at the end-state tree:**
  - the four 13n-a core suites (`VariorumDocumentTests|DocumentFormatRoundTripTests|DocumentImportOperationTests|SampleBookDrillTests`):
    50 tests in 4 suites, all passed, matching the record's 50/4;
  - the twelve export/paste suites (anchored filter): 143 tests in 12 suites, all passed, matching 143/12.

  The Mac focused set (record: 48/3) is stage-gated and was not re-run. It is a claim on the record.
- **Red-on-old was spot-checked for every core pin, by revert in a scratch copy** (not trusted from the record):
  - F1: 10 issues;
  - F4: 5 tests, 1 issue each;
  - F6: 2 issues;
  - F9: 2 tests, 8 issues.

  Each count matches the record. One drill test (`SampleBookDrillTests`) fails in scratch on the CURRENT code too,
  because its fixture lives under `notes/`, which the scratch copy omits. That is a scratch artifact, and the test is
  green in the worktree.
- **F1's stamp comparison is sound.** `variorumISO8601` is the record-encoding strategy (`VariorumRecord.swift:16-21`),
  so the stored string equals `format(now)`. Comparing `format(readBack)` with it is the same comparison every exact-stamp
  restore already makes (`restoreContainerRows`, `restoreReadingRows`). A test clock ticking one second per read keeps
  her hand-delete stamp and the undo stamp distinct, so the pin genuinely separates them.
- **Other F1 interleavings traced and found right:**
  - Put back of one imported note between undo and redo: its membership revives through the book's pass.
  - A note she deleted by hand after Put back stays dead.
  - Put back of the book from the Trash: `restoreReadingRows`' return-whole pass brings back the notes that died on
    its stamp, so the redo passes over everything (obsolete and quiet, as before).
  - The daily-Journal refusal leaves the box untouched, because it throws before returning.
  - Inside a compound, every leg calls the same closures, so each book has its own box.
- **F4's shapes.** A header-only document is a stub only when the header is tokens-alone, which is consistent with F9.
  A malformed file in a folder still refuses, naming its line (pinned). `.empty` can no longer reach the folder door's
  copy. The stub carries its tags through the one application road.
- **F2's door is the New Book door's twin.** It uses the same `mintShelfID`, the same wing source
  (`session.wing.currentID` on both), and the same validation. `shelf_position` stays nil, so the book appends (pinned).
  The undo/redo pair carries `shelf_id` through the tombstone flip, and a shelf deleted in between reads as unshelved
  (the dangling rule).
- **Record honesty.** The fix-round record:
  - states first what it did NOT do: the walk held, the full suites not re-run, the phone not rebuilt, no QUESTIONS
    edit;
  - names the two things seen and returned (the single-container pair, the door-level package walk);
  - logs its two fix-round calls (FR-1 zero blocks, FR-2 copy edges).

  The closeout proposals carry F1/F2/F3/F4/F5's updated wording for AppSpec §9/§12, and P-13na-6/7 are added to the
  PROVISIONALs. No canon, QUESTIONS or master-plan file is touched, as the merge-moment rule requires.
- **Invariants and discipline.** There are zero `Sync/` lines, no schema, and no migration. The one new read
  (`noteMemberships` per imported note) is indexed and costs as much as the import, so P1 holds. The F3 read runs on
  the runner actor, so P2 holds. No literal colour or new UI surface appears. The rendered copy is sentence case
  (her standing rule).

STATUS: ROUND 2 COMPLETE — 0 BLOCKER · 0 MAJOR · 1 MINOR (R2-1, a regression the F1 fix introduced, probe red with a
verified fix shape) · 3 NIT (R2-2, R2-3, R2-4: record and wording). No new BLOCKER or MAJOR, so per the ladder rule no
round 3 is earned. R2-1's fix and pin are the orchestrator's to disposition.
