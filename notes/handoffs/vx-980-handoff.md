# VX-980 — search fixes and small improvements: your morning handoff

**STATUS: DRAFT — written before the last test window and the merge. Every `PENDING(…)` below is a fact not yet known when this was written; the orchestrator fills each one at gate 3 and at the merge, then flips this line to FINAL.**

*How to read the ids in this file:* **VX-NNN** is a ticket on the board. **R-980-N** is one of the rulings you gave at tonight's kickoff sitting (your words are kept verbatim in `notes/plans/fixes/vx-980-her-rulings.md`). **P-980-…** is a provisional call built in your absence and waiting for you. A **gate** is a test window on the shared Mac, run through **nov18** (tonight's stage coordinator session). The **ladder** is the cold-review rounds. The **dev store** is the Debug app's own library, never yours.

---

## What happened tonight, in plain words

You asked for this run to go overnight beside the MCP run (vx-981): four search tickets, built, reviewed, tested and merged one after the other, with nothing published. The four tickets were built in three batches, each by a fresh builder: the two search bugs together, then the index, then the Trash. Everything you had not ruled was built at its most defensible option, marked provisional, and listed below for you. Nothing was published, and `/Applications` was not touched.

Here is each item, in plain words:

1. **A symbol beside real words no longer empties a search (VX-955, a real bug).** Searching `red +` found nothing, while `red` found the note. The reason: search reads a word index, and the app asked that index about the `+` as if it were a word. The index keeps no entry for `+`, and "red AND +" matched nothing at all. Now the app asks the index only about words the index actually keeps. That rule was measured straight from the index's own word-splitter, all 1,112,064 possible characters, one by one. A test re-measures it on every run, so if a future update of the database library ever changes how text is split, a test turns red instead of searches quietly coming back empty. `red +`, `red $`, `red ©` and `1 + 1` now find what their words find. **Proven:** the tests were written first and failed on the old code (822,140 characters disagreed with the index); they pass now; and in the app, `red +` listed its note.

2. **A dash beside a tag now answers what the tag answers (VX-954, a real bug).** `— #flora` showed only the book, while `#flora` showed the book, two notes and a block. The dash counted as "words typed", so the app went looking for words, found none, and never took the tag's road. Now one shared rule decides whether a search has words the index can use, and every place reads it: the Library, a book's 🔍, ⌘K, the counts and the tag suggestions. `— #flora` is `#flora` everywhere. **Your ruling R-980-5 ("Say why")** is built too: a field holding only punctuation or symbols (`—` alone, `+` alone) now says "Search looks for words and numbers, so punctuation on its own can't be found." where it used to say "Nothing matches." A real search that finds nothing still says "Nothing matches." **Proven:** six search shapes failed on the old code and pass now; the app's routing tests went red (65 problems) when the change was taken back out, then green again; and in the app, `— #vx980walk` listed both tagged notes, and `—` alone showed your sentence in the Library and in a gathering's 🔍.

3. **The search index has a check and a rebuild button (VX-79).** A new section, **Search index**, sits in Settings ▸ Data Safety after "Restoring a copy", with two buttons. **Check Index** compares the index with your notes and changes nothing. **Rebuild Index** rebuilds the index from your notes. Each says what state the index is in afterwards, never just "done". Nothing runs them on its own: no ⌘K command, no menu item, no check at launch. You also asked for the restore question to be traced first and handed to you whole, with options. The answer is that no road a library arrives by can leave its index out of step with its notes. The whole trace is in its own section below. **Proven:** a test checks that Check changes nothing, down to every stored row of a real library file; seven tests run each road a library arrives by and then check the index; and in the app, Check said "The search index is in step with your notes — 4,857 entries." and Rebuild said "Rebuilt from your notes. The search index is in step with them — 4,857 entries."

4. **The Trash can search itself (VX-93).** A quiet field, "Search the Trash…", stands first in the Trash's row of controls, beside the kind filter. It is shaped exactly to your four rulings (R-980-9 to R-980-12). It searches names and deleted text. Every word you type must be found, capitals and accents are ignored, and part of a word matches. A row found by text it doesn't show gets one muted line under it, with the words around the match. The field is empty every time you open the Trash, and esc clears it. Empty Trash still empties the whole Trash. The main search is untouched, so the Trash stays out of it. **Proven so far:** 23 core tests pass, and four deliberate breakages of the code each turned them red. The app's own tests and the walk through the Trash run at gate 3: PENDING(gate 3).

**The review story.** You picked Fable as the reviewer (R-980-3), and two fresh Fable reviewers read the whole run's code cold. **Round 1** found no blockers and no majors. It found one minor problem in the new Trash search, a timing gap: if you pressed esc while a search's answer was still on its way, the Trash could say "The Trash is empty." for a moment over a Trash that held things. It also found two small comments that described the code wrongly. All three were agreed and fixed. The timing fix is one line, and a new test fails on the old code. That test's run is part of gate 3: PENDING(gate 3). **Round 2** confirmed the fixes and found only one stale line in the run record, now corrected. Your rule (R-980-4) adds a round only while the one before found a major, so the ladder is closed. Round 1 also saw an older relative of the same timing gap: the Trash can say it is empty for one frame when you change the kind filter or the order. It is older than this run and untouched by it, so it is ticketed (VX-1016) rather than fixed here.

**The walks.** The four batch-1 checks passed in the Debug app, in the Library and in a gathering's 🔍. The six batch-2 checks passed in Settings: the section, Check, Rebuild, the answer clearing when you leave the pane, the Settings search finding "search index", and nothing in ⌘K or the menus. macOS 27.0.1 withheld screenshots of Settings, so that walk was read and pressed through Accessibility. The Trash walk runs at gate 3: PENDING(gate 3).

**What the walks found that is not this run's (each ticketed, none fixed here):**
- **The slow first launch (VX-1013).** At gate 1 the Debug app sat on a blank window for about nine minutes. It was reading the key files in the dev store's second backup folder (an iCloud-synced Documents folder, 155 files), one slow read at a time, before drawing anything. The same files read at once from a shell. At gate 2 the app opened in about ten seconds, so it is a cold-folder cost. Your real library walks the same road over a smaller folder.
- **The "different library" notice (VX-1015).** At gate 1's launch the lobby said "This is a different library than the one this Mac last had open". The first guess was the test runs, which open other libraries. But gate 2's launch came right after a 31-suite test run and showed no notice, so that guess is doubtful and the cause is untraced.
- **A book's search field overflows a narrow column (VX-1014).** In a narrow navigator, a book's search field spills over the sidebar's edge. This run changed only that surface's empty sentence.

---

## Your checklist

- [ ] Read the decisions below. They are also the QUESTIONS bundle PENDING(QUESTIONS #).
- [ ] The restore question (VX-79): pick (a), (b) or (c) in its section below.
- [ ] The wording pass: every new sentence the app now says is listed below, all provisional ("provisional wording is fine for now, you can keep them listed though").
- [ ] Say whether "up to 5 review rounds as long as a major is found" was for this run only or is a standing change. The repo records no answer.
- [ ] VX-1009, searching for punctuation and symbols: a design sitting when you want one. Your reaction is on the ticket.
- [ ] PENDING(release): the release. nov18 names which of vx-980 and vx-981 builds it; nothing is published without you.
- [ ] The filed tickets at the bottom.

---

## Decisions waiting on you

Each was built at its most defensible option and marked provisional. "Built" names the one in the app tonight.

### The search fixes (VX-955, VX-954)
- **P-980-B1-1: the band repeats a dash you typed beside a tag.** `— #vx980walk` reads "“—” — 2 notes · #vx980walk" in the band, while `#vx980walk` alone shows no quoted words. (a) The band shows what you typed. **Built.** (b) Words that can't be searched drop out of the band's quote when a tag is there.
- **One reach beyond your words, found while checking the rulings.** R-980-5 named the Library's field. A book's 🔍 shares the same engine, so it also says "Search looks for words and numbers, so punctuation on its own can't be found." where it used to say "Nothing in this book matches." Keep it there, or limit the sentence to the Library.
- **Two readings no door can reach today.** The search field has no OR and no NOT yet, so you can't meet either of these. (1) "Names no tag" is read the way the tag-only listing reads it. A tag under OR or NOT therefore can't start that listing, and only a future power grammar (VX-73) would meet the difference. (2) A word that is itself a tag's name (a tag called `—`) is still offered as a tag suggestion in a field with no other tag, exactly as before, while `— #flora` offers nothing, exactly as `#flora`.
- **The negation row, also unreachable today.** A symbol beside a NOT word now refuses the search the same way a dash there always did. It used to "answer" with an always-empty result. No door reaches this, because the field has no NOT.

### The search index (VX-79)
- **P-980-2: where the row sits, and its words.** (a) Its own section after "Restoring a copy", before the backup log. **Built.** (b) The top of the pane. (c) A pane of its own. The words are listed below.
- **P-980-3: the restore question.** Its own section follows, with the three options.
- **P-980-B2-1: what waits while a check or rebuild runs.** (a) Only the two index buttons wait. **Built.** A backup copies a consistent snapshot, and a rebuild is one all-or-nothing write queued like every other, so the two never race. (b) Every button in the pane waits.
- **P-980-B2-2: how long the answer stays.** (a) The answer under the buttons lasts while the pane is open; open the pane again and the row is quiet. **Built**, matching how a backup's receipt already behaves there. (b) Remember the last check ("Last checked today at 4:10 — in step"), which needs new local storage.
- **P-980-B2-3: Rebuild asks nothing first.** (a) No confirm. **Built.** Nothing of yours lives only in the index; the rebuild is all-or-nothing and took about two-thirds of a second at 55,000 takes. (b) A confirm saying it re-reads every note.

### The Trash's search (VX-93)
- **P-980-B3-1: what counts as deleted text.** (a) Every take that went into the Trash with the note, including archived takes, because Put back brings those back too. **Built.** (b) Active takes only. Not searched either way: commits, comments, take labels and block names. If "any of its text" in R-980-9 meant those too, say so.
- **P-980-B3-2: the folding of capitals and accents.** (a) The Mac's standard folding, the same one the tag suggestions use. **Built.** It finds everything the main search's folding would, plus a little more: ß matches ss, the ﬁ-style ligatures match their letters, and a few Greek and Cyrillic accents fold that the index keeps apart. (b) Copy the index's exact folding character by character: exact, but slower and more machinery.
- **P-980-B3-3: how far it reaches.** (a) The whole Trash of this wing; the 500-row display limit applies to the matches. **Built.** (b) Only the 500 newest rows the plain listing shows.
- **P-980-B3-4: a row's "name".** (a) The name the row shows: an untitled note answers to its created day. **Built.** (b) The stored title only.
- **P-980-B3-5: which match the passage line shows.** (a) The first place, in reading order, of a typed word the row doesn't already show, cut to about 32 characters before and 96 after at word edges, with "…" where cut. **Built.** (b) The first place of any typed word.
- **P-980-B3-6: timing and keys.** (a) The listing answers 180 ms after typing pauses; emptying the field answers at once; ⏎ answers at once; esc on an empty field passes the key on. **Built.** (b) No pause, answering on every keystroke as the Library does.
- **P-980-B3-7: the field's look and reach.** (a) A small rounded field like the Archived page's, 120 to 200 points wide by the row's room, reached by a click only, never by Tab, and never taking the caret when the Trash opens. **Built.** (b) A borderless quiet line like the sidebar's search field.
- **P-980-B3-8: the saved-version counts in the Delete Now confirms.** (a) They count the rows on screen, so under a search a hidden version goes uncounted, the same as the existing display limit. **Built**, unchanged. (b) Count from the whole listing (one more read on the confirm).
- **P-980-B3-9: leaving clears.** (a) Leaving the Trash also clears the field. **Built.** (b) Rely only on the fresh page each visit builds.

### Already ruled by you tonight (settled, nothing re-decided)
- **R-980-1.** Your question "why can we not search for punctuation? what if i wanted to find the one note where i was adding things?" was answered in chat and re-asked as R-980-5; the capability itself is VX-1009.
- **R-980-2.** The restore question is traced first, and the trace is in this handoff whole, with options.
- **R-980-3.** Fable reviews every round.
- **R-980-4.** Up to five review rounds while a major is found; provisional wording, kept listed.
- **R-980-5.** "Say why" for a field of only punctuation or symbols.
- **R-980-6.** Symbol search goes to your design sitting (VX-1009).
- **R-980-7.** No quoted-phrase batch tonight ("Ticket only").
- **R-980-8.** Sequential merges, provisional running; the last merger of vx-980 and vx-981 builds a release that is not published.
- **R-980-9.** The Trash searches names and deleted text.
- **R-980-10.** The simple match; the full grammar is VX-1010, parked.
- **R-980-11.** One passage line.
- **R-980-12.** The field always visible in the header.

---

## The restore question (VX-79): the trace you asked for

*Lifted whole from the run record, as you asked ("make sure what the trace reveals is in my handoff with full description and options"). Batch 2's builder wrote it for you, so "I" in it is that builder. Option (a) is what is in the app tonight.*

**What the question was.** Search reads a local index Variorum builds from your notes — a word list kept on this Mac, beside the library, so a search never has to read every note. The index holds nothing of yours that the notes do not: it can always be rebuilt from them. The ticket (VX-79) asked whether, besides a button to check and rebuild it, the app should also check it AUTOMATICALLY after a "restore-shaped" moment — any time a library arrives from somewhere else. Before building a net, I traced every road a library can arrive by, to see whether any of them can actually land an index that disagrees with its notes.

**The short answer: none of them can.** Every road lands the index one of two ways, and both keep it in step by construction:

- **The index travels inside the copy, from the same instant as the notes.** A backup, a Previous Library and a library sent from another Mac are each one consistent copy of the whole library file, taken in one go — the notes and the index inside it are the same moment's. Making that copy your library re-encrypts the whole file under its new key (the index with it), and the first open brings it up to this version of the app. Every later change is captured as usual: the index's update rules travel inside the file too.
- **Or the index is built fresh, as the notes go in.** A plaintext export brought in, and the first sync into a new library, never take an index from anywhere: every note is written into the new library one row at a time, and the index records each row as it is written — the same mechanism that keeps it current while you type.

I proved each road by running it, the way the app runs it, on real files, and then asking the index's own check whether it agrees with the notes (the same check the new Settings row's Check button runs). All seven pass. To be sure the proofs can fail, I broke each road on purpose (an index missing one kind of entry; a missing update rule on the receiving end) and every one of them failed as it should.

**Road by road.**

| Road | How the index arrives | Can it arrive out of step? | Proof |
|---|---|---|---|
| **Make this my library — from a backup** (Settings ▸ Data Safety ▸ Restore list) | Inside the copy. The backup is one consistent copy of the library file (SQLite's own backup feature); making it yours byte-copies it privately, re-encrypts the whole file under the new library's key, swaps it in with one rename, and the ordinary open runs any updates this build has. | No — the notes and the index are one instant's, and the index's update rules come with it. | `aBackupPairMadeMineLandsItsIndexInStep`: in step, the same entries entry for entry, every word answering as before, and a note written after the landing findable at once. |
| **Make this my library — a Previous Library** | The same road. A previous library is the old live file, set aside whole (hard-linked) at the moment it stepped aside. | No — same as a backup. | Same pin (the file road is identical once the copy is picked). |
| **Make this my library — into the empty slot** (no library open) | The same road, minus the step-aside. | No. | Same pin. |
| **A copy from an earlier version of Variorum** | Inside the copy, then the first open runs the newer versions' updates. None of the updates since the index was added (v1_24 → v1_37) rebuilds or rewrites a table the index reads from, and any row an update does change passes through the index's rules. A copy so old that it has NO index (before v1_22 — not reachable on today's restore road, which only lands copies from v1_31 on) gets one built from its notes by the v1_22 update at the first open. | No. | `aCopyFromAnEarlierBuildMigratesForwardWithItsIndexInStep` — two eras: a v1_31 copy (the oldest today's road lands) and a v1_21 copy (no index at all): both in step after the open, every field findable by its own kind. |
| **A plaintext export brought in at File ▸ Open Library…** | Built fresh. The export file does carry its own index (so the file stays searchable without Variorum) — and that index is in step with the file's notes — but Open Library never adopts the export's file: it reads the notes out and writes them into a brand-new library through the ordinary operations, so the new library's index is built row by row as they go in. | No — nothing of the export's index is ever brought across. | `aPlaintextExportBroughtInBuildsItsOwnIndexInStep` (the export's own index checked too); `aPlaintextExportFromAnEarlierBuildBuildsItsOwnIndexInStep` (an export from the oldest export era). |
| **The first sync into a fresh library** | Built fresh. Every row arrives from the server and is written locally; the index's rules deliberately fire for arriving rows exactly as for typed ones. | No. | `theFirstSyncRoundIntoAFreshLibraryLandsItsIndexInStep`: in step on both devices, the SAME entries on both, run in small windows so the first catch-up spans many rounds. |
| **Resume Sync after a restore** (the restored library catching up) | Inside the copy, then the catch-up: later edits arrive as rows, ordinary deletions as tombstones (the delete rules retire the note's entries), and permanent deletions as the purged-ids list removing rows outright (the remove rule retires theirs). | No. | `aRestoreThatResumesSyncStaysInStepThroughTheCatchUp`: in step as it lands and after the catch-up; the later edit findable; neither deleted note's words findable; the same entries as the library it caught up with. |
| **Send Library to Another Mac → Open Library there** | Inside the copy. The send writes the same one-instant copy as a backup; the other Mac files it by a byte copy and then makes it its library by the backup road above. | No. | `aLibrarySentToAnotherMacAndOpenedThereLandsItsIndexInStep`. |

**Two honest edges.** (1) A copy carries its index exactly as it was in the library it was copied from. If that library's index had somehow fallen out of step, the restored one would inherit it — I found no way for that to happen (every write to a note passes through the index's rules), and the new Settings row's Check would say so and Rebuild would fix it. (2) "Look inside" opens a copy read-only and writes nothing, so it has no index question at all.

**The options for your decision.**

- **(a) The Settings row only, with the trace and its seven guard pins — BUILT (PROVISIONAL, my recommendation).** The trace found no road that can land the index out of step, so an automatic check would be a net under a fall nobody can produce. The pins keep it true: a future change that broke any road's index would turn one red before it shipped. If you ever doubt search, Settings ▸ Data Safety ▸ Search index ▸ Check answers in a moment and Rebuild fixes anything it finds.
- **(b) An automatic check after a library lands** (after Make this my library, a plaintext export brought in, and the first sync round), rebuilding quietly if it ever found anything, with a quiet receipt. Cost: one full read of the library at each landing (a rebuild was measured at about two-thirds of a second at 55,000 takes); it would live in the protection and landing code this run is fenced out of, so it would be its own ticket. It guards against no mechanism the trace found. A lighter variant: check only, and say something only if the check finds a problem.
- **(c) A check at every open** — rejected: it would cost a full read of the library on every launch, the slow-with-size behaviour Variorum is built never to have.

**For a later reader, the code (read, never edited — the run's fence):** the backup and send copies `ProtectionLibraryFiles.snapshot` (`Sources/VariorumCore/Protection/Files/ProtectionLibraryFiles.swift:151`, called by `FileBackupsLeaf.writeContainerPair` `App/Variorum/Shared/Protection/FileBackupsLeaf.swift:71` and `.writeSendPair` `:130`); the picked pair's filing `PickedCopy.file` (`App/Variorum/Shared/Protection/PickedCopy.swift:153`, a byte copy); Make this my library's file road `makeMineStage` / `makeMineSwap` (`Sources/VariorumCore/Protection/Executor/Acts/Copies.swift:177`, `:222`) → `SQLCipherLibraryLeaf.stageCopy` (`App/Variorum/Shared/Protection/SQLCipherLibraryLeaf.swift:69` — `ProtectionLibraryFiles.privateCopy` `:185` then `exportReencrypted` `:78`, `sqlcipher_export` with row counts verified) → `swapStaged` (`SQLCipherLibraryLeaf.swift:112`, one rename) → the ordinary open (`AppDatabase.openStore`, `Sources/VariorumCore/Persistence/AppDatabase+Dependency.swift:103`; the migrator runs in `AppDatabase.init`, `AppDatabase.swift:31`); the migrations `Sources/VariorumCore/Persistence/Migrations.swift` (v1_22 `:873` creates and builds the index from the notes, v1_23 `:900`; v1_24–v1_37 touch no indexed table but v1_25's two `ADD COLUMN`s, which keep a table's triggers); the bring-in `ProtectionCopyDoors.landPlaintextExport` (`App/Variorum/Shared/Protection/ProtectionCopyDoors.swift:511`, the import at `:555`) over `PlaintextExportReading.read` / `Operations.importPlaintextExport` (`Sources/VariorumCore/Operations/Operations+PlaintextExportImport.swift:110`, `:211`); the export keeping the derived tables `StorePlaintextExport` (`Sources/VariorumCore/Persistence/StorePlaintextExport.swift:24`, `sqlcipher_export` at `:74`); the capture triggers and their deliberate firing under remote apply `SearchIndex` (`Sources/VariorumCore/Persistence/SearchIndex.swift:30–37`, `createCaptureTriggers` `:226`, the delete arm `:278`); remote apply `SyncRow.apply` (`Sources/VariorumCore/Sync/SyncSchema.swift:921`, UPDATE-then-INSERT, never REPLACE); the purged-ids ledger's physical removal `PurgeJanitor.reconcileLedger` (`Sources/VariorumCore/Sync/PurgeJanitor.swift:297` → `PurgeFamily.swift:461`). The same re-encryption mechanism (`exportReencrypted`) also carries every Castle crossing and Replace All Keys (`SQLCipherLibraryLeaf.stageReencryption`, `:63`), so the make-mine pin covers that road's index too. `LocalMachineryRecreation` (the old road that re-opened an export as a library) has no production caller today — exports are never adopted.

---

## Every new sentence the app now says (all provisional, for your wording pass)

**The Library's search, and a book's 🔍**
- The empty answer for a field of only punctuation or symbols and no tag, in place of "Nothing matches." (the Library) and "Nothing in this book matches." (a book's 🔍): "Search looks for words and numbers, so punctuation on its own can't be found."

**Settings ▸ Data Safety, the Search index section**
1. The section title, also the Settings search result's lead: "Search index"
2. The section's one line: "Search reads an index Variorum keeps on this Mac, built from your notes. Nothing of yours lives only in the index, so checking it or rebuilding it is always safe."
3. The buttons, in the pane's own title-case style: "Check Index" · "Rebuild Index"
4. While one runs, with a small spinner: "Checking the search index against your notes…" · "Rebuilding the search index from your notes…"
5. Check, in step: "The search index is in step with your notes — N entries." (with one: "— 1 entry.")
6. Check, out of step: "The search index is out of step with your notes: ‹what it found›. Rebuild it to fix that."
7. Rebuild, in step: "Rebuilt from your notes. The search index is in step with them — N entries."
8. Rebuild, still out of step (no known way to reach it): "Rebuilt from your notes, but the search index is still out of step with them: ‹what it found›. Your notes themselves are untouched."
9. ‹what it found›, only the parts that apply, joined "a, b and c": "1 piece of writing is missing from it" / "N pieces of writing are missing from it" · "1 entry points at writing that is gone" / "N entries point at writing that is gone" · "1 entry has out-of-date details" / "N entries have out-of-date details" · "the words it holds differ from your notes" · and a fallback that a real problem can't reach: "its entries disagree with your notes"
10. A failure, with the system's own reason: "Couldn't check the search index: ‹reason›." · "Couldn't rebuild the search index: ‹reason›. Nothing was changed."
11. The Settings search result's detail line: "Check that the index search reads matches your notes, or rebuild it from them. Nothing of yours lives only in it."
12. A note the app would show only if a button were ever unavailable (today it never is): "The search index is checked and rebuilt in Settings ▸ Data Safety."

**The Trash**
1. The field's prompt: "Search the Trash…" (in the Terminal voice it reads "search the trash…")
2. The field's hover: "Lists what in the Trash holds every word you type — names and deleted text. Esc clears."
3. The field's accessibility label: "Search the Trash"
4. Words typed and nothing matching: "Nothing in the Trash matches." Under a kind filter: "No notes in the Trash match." · "No books in the Trash match." · "No blocks in the Trash match." · "No snippet groups in the Trash match." · "No originals in the Trash match."
5. The passage line under a row is your own text, with "…" where it is cut.

---

## Evidence and state

- **Branch** `vx-980-search-fixes`, **worktree** `~/dev/variorum-vx-980` (the Pro). **PR** PENDING(PR). **Merge commit** PENDING(merge commit).
- **The run record:** `notes/plans/fixes/vx-980-search-fixes.md`. Its FOR A LATER READER section at the top is the settled summary; everything under it is the night's working record.
- **Core tests (the headless package):** batch 1's search suites 175 tests in 31 suites; batch 2's 196 in 35; batch 3's 359 in 65; both reviewers re-ran the run's eight new core suites themselves, 45 tests, zero problems.
- **Gate 1 (batch 1): PASSED.** 103 tests in 17 suites, the four walk checks, and the check that takes the fix back out and watches the tests fail, red as it should be (5 tests, 65 problems), then restored.
- **Gate 2 (batch 2): the walk PASSED.** 280 tests in 31 suites with one red: a test that matched a line of source text the batch had legitimately moved. It was fixed test-only, and its re-run rides gate 3.
- **Gate 3 (batch 3, the review fix, the re-run): PENDING(gate 3).** Batch 3's app tests (`TrashSearchModelTests` 8, `TrashSearchFieldTests` 3, plus the existing Trash suites), the Trash walk, the `DataSafetyRoadCountsTests` re-run, and round 1's new test, green with the fix and red with the fix taken out.
- **The merge gate** (the whole Mac test target on the merged tree): PENDING(merge gate).
- **The ladder:** round 1, 0 blockers · 0 majors · 1 minor · 2 nits, all fixed; round 2, 0 · 0 · 0 · 1 nit, a record line. Closed.
- **Canon:** three contract lines in `notes/SurfaceContracts.md`: the folded-word rule and the index's one face (The Library), and the Trash's own search (The Bookcase and books). **`Tools/canon-size`: `142894  total (harness limit 150000, headroom 7106)`**, no crossing.
- **The phone:** parity row PL-75 in `notes/MobileSoul.md`. The search fix rides to the phone in shared code, the Search index row is Mac-only, and the Trash's search is owed as a field on the phone's Trash.
- **Nothing published; `/Applications` untouched; your real library untouched.**

---

## Filed tickets (born in this run, by priority)

- [ ] VX-1009 (Medium, Feature, Needs Lillian): searching for punctuation and symbols, for your design sitting; your reaction to the three shapes is on the ticket.
- [ ] VX-1013 (Medium, Bug, Backlog): opening a library waits on reading the second backup folder's key files: nine minutes blank on a cold folder, ten seconds warm.
- [ ] VX-1010 (Low, Feature, Parked at your word): the Library's full search grammar inside the Trash.
- [ ] VX-1014 (Low, Bug, Backlog): a book's search field overflows a narrow navigator column.
- [ ] VX-1015 (Low, Debt, Backlog): the "different library" notice at the dev store's first Debug launch; cause untraced, test runs ruled out by gate 2.
- [ ] VX-1016 (Low, Bug, Backlog): the Trash can claim it is empty for one frame when the kind filter or the order changes.

No next plan is owed by this run; the umbrellas run in the order you set.
