//
//  EncryptionBookDoorTests.swift
//  VariorumTests
//
//  pre-13x ladder round 1, F2 (MINOR-8): the tutorial door seeds *Encryption
//  Explained* when it is absent — Lesson 2's last paragraph points at the
//  book "on this shelf", and a signed-in-never-synced store seeds neither
//  book (ledger 70's arrive-by-sync gate). RED ON OLD: the door opened the
//  tutorial and left the sentence pointing at nothing.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("pre-13x F2 — the tutorial door seeds the encryption book (MINOR-8)")
struct EncryptionBookDoorTests {
    private func withWorld<T>(
        _ body: @MainActor (AppSession, AppDatabase) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_950_400)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 21))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // F3 (MINOR-N3): the door's mark leaf INJECTED — a headless pin
            // never reads the test host's defaults, a domain the real app
            // shares (her real store's own mark must never decide a pin).
            session.seededBookMarkIsSet = { _ in false }
            // RUN A batch A2, row 8: the WRITE leaf is injected for the same
            // reason — a headless run never leaves a mark in the dev store's
            // own defaults domain. A test that cares about the mark wires its
            // own pair (see `aPurgedBookIsNotReMintedByTheTutorialDoor`).
            session.markSeededBook = { _ in }
            return try await body(session, db)
        }
    }

    private func poll(_ condition: @MainActor () -> Bool, turns: Int = 800) async {
        for _ in 0..<turns {
            if condition() { return }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    private func encryptionBook(_ db: AppDatabase) async throws -> (complete: Bool, books: Int) {
        let titles = try SampleLibrarySeeder.loadStories(for: .encryptionExplained).map(\.title)
        let (existing, books) = try await db.read { db in
            (try SampleLibrarySeeder.discover(db, book: .encryptionExplained),
             try Queries.readings(db)
                .filter { $0.name == SampleLibrarySeeder.Book.encryptionExplained.name && $0.deletedAt == nil }.count)
        }
        return (existing.isComplete(for: titles), books)
    }

    /// The door on a store with NO seeded books (the gate never opened):
    /// the tutorial opens AND *Encryption Explained* is minted whole beside
    /// it — once; a second open re-seeds nothing.
    @Test func openingTheTutorialSeedsTheEncryptionBookWhenItIsAbsentAndNeverTwice() async throws {
        try await withWorld { session, db in
            let before = try await encryptionBook(db)
            #expect(!before.complete && before.books == 0, "the gate never opened — no book")

            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)
            actions.openTutorial(confirm: { true })
            await poll { shell.pendingSelection != nil }
            await poll { !session.tutorialDoorInFlight }
            guard case .reading(let openedID)? = shell.pendingSelection else {
                Issue.record("the tutorial opens")
                return
            }
            let tutorialBooks = try await db.read { db in
                try Queries.readings(db).filter { $0.name == TutorialSeeder.bookName && $0.deletedAt == nil }.map(\.id)
            }
            #expect(tutorialBooks == [openedID], "the door opened the tutorial, as before")
            let after = try await encryptionBook(db)
            #expect(after.complete && after.books == 1, "the book Lesson 2 names is on the shelf — whole")
            #expect(session.status.spoken?.text.contains("could not be restored") != true, "silent on success")

            // Again: the existing tutorial opens, the book stays one.
            shell.pendingSelection = nil
            actions.openTutorial(confirm: { true })
            await poll { shell.pendingSelection != nil }
            await poll { !session.tutorialDoorInFlight }
            let again = try await encryptionBook(db)
            #expect(again.complete && again.books == 1, "never a second copy")
        }
    }

    /// pre-13x ladder round 2, F3 (MINOR-N3) — RED ON OLD: the silent
    /// ensure re-minted a book the reader DELIBERATELY DELETED, on every
    /// tutorial open (the seeder's own "deleted ⇒ never re-seeded" rule
    /// bypassed). The tombstone is the reader's word: the tutorial opens,
    /// the book stays gone; the EXPLICIT restore door — an ask — still
    /// brings it back, afresh.
    @Test func theTutorialDoorDoesNotReMintABookTheReaderDeleted() async throws {
        try await withWorld { session, db in
            let first = try await SeededBookRestore.restore(session: session, book: .encryptionExplained)
            guard case .restored(let readingID, _) = first else {
                Issue.record("a fresh store mints the book: \(first)")
                return
            }
            try session.operations.deleteReading(readingID)
            #expect(try await encryptionBook(db).books == 0, "the reader deleted the book")

            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)
            actions.openTutorial(confirm: { true })
            await poll { shell.pendingSelection != nil }
            await poll { !session.tutorialDoorInFlight }
            guard case .reading? = shell.pendingSelection else {
                Issue.record("the tutorial opens")
                return
            }
            let after = try await encryptionBook(db)
            #expect(after.books == 0, "the reader's deletion STANDS — the silent ensure declines on the tombstone")
            #expect(session.status.spoken?.text.contains("could not be restored") != true, "a decline is not a failure — nothing spoken")

            // The explicit door is an ask: it mints afresh (a new reading).
            let again = try await SeededBookRestore.restore(session: session, book: .encryptionExplained)
            guard case .restored(let newID, _) = again else {
                Issue.record("Help ▸ Restore still mints: \(again)")
                return
            }
            #expect(newID != readingID)
            #expect(try await encryptionBook(db).books == 1)
        }
    }

    /// F3 (MINOR-N3): the OTHER evidence — this device's per-book seeded
    /// mark (the launch seeder's rule) — read through the ensure's injected
    /// leaf: marked ⇒ declined, nothing minted; unmarked ⇒ the book.
    @Test func theSilentEnsureDeclinesOnTheSeededMarkAndMintsWithoutIt() async throws {
        try await withWorld { session, db in
            let marked = try await SeededBookRestore.ensure(
                session: session, book: .encryptionExplained, markIsSet: { true })
            #expect(marked == .declined(.markedSeeded))
            #expect(try await encryptionBook(db).books == 0, "nothing minted under the mark")
            let unmarked = try await SeededBookRestore.ensure(
                session: session, book: .encryptionExplained, markIsSet: { false })
            guard case .ensured(.restored(_, let minted)) = unmarked else {
                Issue.record("unmarked, the ensure mints: \(unmarked)")
                return
            }
            #expect(minted == 8)
            // The door reads the SESSION's leaf: marked there, the door declines too.
            session.seededBookMarkIsSet = { _ in true }
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)
            // `Existing` is MainActor-isolated: read it whole, ask it on the actor.
            let existing = try await db.read { db in try SampleLibrarySeeder.discover(db, book: .encryptionExplained) }
            try session.operations.deleteReading(try #require(existing.bookID))
            actions.openTutorial(confirm: { true })
            await poll { shell.pendingSelection != nil }
            await poll { !session.tutorialDoorInFlight }
            #expect(try await encryptionBook(db).books == 0, "the mark declines the door's ensure")
        }
    }

    /// **"… IS ALREADY WHOLE" IS A REFUSAL** (the 18i ladder round 1, MINOR-3
    /// — J33). 18i classed both endings of Help ▸ Restore as receipts, but the
    /// rule it classed by is *"a RECEIPT reports an act that LANDED (the store
    /// changed…)"* and `.alreadyWhole` changes nothing — the same reading the
    /// same table applies to *"already one paragraph"*, which paid a whole
    /// predicate for it. The rule is NOT widened to "or the shell moved":
    /// that would reclassify the daily-entry note and blur every navigating
    /// door. So the two endings split, exactly as undo/redo's already do.
    ///
    /// **Red on old:** under `.off` the second press said nothing at all.
    @Test func theAlreadyWholeLineIsARefusalAndAlwaysShows() async throws {
        try await withWorld { session, _ in
            let actions = ShellActions(session: session, shell: ShellRouter())
            session.status.receiptStyle = .off

            actions.restoreEncryptionBook()
            await poll { session.status.lastDroppedReceipt != nil }
            #expect(session.status.lastDroppedReceipt?.hasPrefix("Restored") == true,
                    "the minting press IS a receipt, and `off` drops it: \(session.status.lastDroppedReceipt ?? "nil")")

            session.status.clear()
            actions.restoreEncryptionBook()
            await poll { session.status.current != nil }
            #expect(session.status.current?.text
                    == "\u{201C}\(SampleLibrarySeeder.Book.encryptionExplained.name)\u{201D} "
                    + "is already whole — it's on your shelf.")
            #expect(session.status.current?.kind == .refusal,
                    "nothing was minted — P-2 says she sees it whatever the setting")
        }
    }

    // MARK: - RUN A batch A2, row 8 (17l item 1 / KnownIssues 38)

    /// **THE LATCH — a tutorial open INSIDE the launch seed's window.**
    /// `seedIfNeeded` and the tutorial door's ensure both DISCOVER and then
    /// MINT, with awaits in between (the resource parse, the database read,
    /// one runner turn per chapter), so two roads that each correctly saw
    /// "no book here" both mint one. Staged deterministically through the
    /// seeder's own `pacing` leaf: the launch seed is parked at its FIRST
    /// pacing point — after discovery, before the skeleton turn — while the
    /// door runs.
    ///
    /// **RED ON OLD: two *Encryption Explained* books on the shelf.**
    @Test func aTutorialOpenInsideTheLaunchSeedsWindowLeavesOneBook() async throws {
        try await withWorld { session, db in
            let released = LockIsolated(false)
            let launch = Task { @MainActor in
                await SampleLibrarySeeder.seedIfNeeded(
                    session: session, book: .encryptionExplained,
                    // The marks are INJECTED: a headless run never reads or
                    // writes the test host's defaults (the row-42 class).
                    loadMark: { false }, saveMark: { _ in },
                    pacing: {
                        while !released.value {
                            await Task.yield()
                            try? await Task.sleep(for: .milliseconds(5))
                        }
                    })
            }
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)
            actions.openTutorial(confirm: { true })
            // The launch seed stays parked until the door has had its whole
            // turn — which is what makes this deterministic rather than a
            // race the test hopes to win. Before the fix the door RUNS to
            // completion here and mints its own copy; after it, the door is
            // waiting on the latch and this poll simply runs out.
            await poll({ !session.tutorialDoorInFlight }, turns: 300)
            released.setValue(true)
            _ = await launch.value
            await poll { !session.tutorialDoorInFlight }

            let after = try await encryptionBook(db)
            #expect(after.books == 1, "one book, not two — the two roads' discover-then-mint is one at a time")
            #expect(after.complete, "and it is whole")
        }
    }

    /// The latch's own contract, without the door's choreography: while one
    /// road holds a book's discover-then-mint, the other WAITS and then
    /// re-discovers — so it finds the book the first minted instead of
    /// minting a twin. (The second road must never be left with a stale
    /// `Existing`: that is what would mint a second book behind the latch.)
    @Test func theSeedLatchHoldsOneDiscoverThenMintPerBookPerStore() async throws {
        try await withWorld { session, db in
            let released = LockIsolated(false)
            let launch = Task { @MainActor in
                await SampleLibrarySeeder.seedIfNeeded(
                    session: session, book: .encryptionExplained,
                    loadMark: { false }, saveMark: { _ in },
                    pacing: {
                        while !released.value {
                            await Task.yield()
                            try? await Task.sleep(for: .milliseconds(5))
                        }
                    })
            }
            try? await Task.sleep(for: .milliseconds(100))
            let second = Task { @MainActor in
                try await SeededBookRestore.restore(session: session, book: .encryptionExplained)
            }
            try? await Task.sleep(for: .milliseconds(100))
            released.setValue(true)
            let launchOutcome = await launch.value
            let secondOutcome = try await second.value

            #expect(try await encryptionBook(db).books == 1, "\(launchOutcome) then \(secondOutcome)")
            if case .alreadyWhole = secondOutcome {} else {
                Issue.record("the waiting road re-discovers and finds the book: \(secondOutcome)")
            }
        }
    }

    /// **A PURGED BOOK STAYS GONE.** F3 (MINOR-N3) made the silent ensure
    /// decline on a tombstoned reading of the book's name — but a tombstone
    /// is the reader's word only while the Trash keeps it: Delete Now /
    /// Empty Trash write a purge intent and the janitor then removes the row
    /// itself, and 13j's ledger is CONTENT-FREE by design (ids, never
    /// names), so nothing that survives the purge can be asked "was a book
    /// called this deleted?". The door therefore RECORDS the reader's
    /// decision on this device the moment it sees it — the seeded book's own
    /// per-book mark, the seeder's "deleted ⇒ never re-seeded" rule.
    ///
    /// **RED ON OLD: the purge erases the evidence and the next tutorial
    /// open mints the book again.**
    @Test func aPurgedBookIsNotReMintedByTheTutorialDoor() async throws {
        try await withWorld { session, db in
            // A NON-SEEDING device: the book arrived (by sync, here by the
            // seeder's own mint with no mark written).
            let stories = try SampleLibrarySeeder.loadStories(for: .encryptionExplained)
            let existing = try await db.read { db in
                try SampleLibrarySeeder.discover(db, book: .encryptionExplained)
            }
            let seeded = try await SampleLibrarySeeder.seed(
                session: session, book: .encryptionExplained, stories: stories, existing: existing)
            #expect(try await encryptionBook(db).books == 1)

            // This device's mark, as the app keeps it — injected on both
            // sides so no headless run touches the shared defaults domain.
            let marks = LockIsolated(Set<String>())
            session.seededBookMarkIsSet = { marks.value.contains($0.name) }
            session.markSeededBook = { book in marks.withValue { _ = $0.insert(book.name) } }

            // The reader deletes the book, and the door sees the tombstone.
            try session.operations.deleteReading(seeded.readingID)
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)
            actions.openTutorial(confirm: { true })
            await poll { shell.pendingSelection != nil }
            await poll { !session.tutorialDoorInFlight }
            #expect(try await encryptionBook(db).books == 0, "the tombstone stands (F3's MINOR-N3)")

            // THE PURGE: Delete Now writes the intent; the janitor removes
            // the row. Both staged here — the intent through the real door,
            // the removal as the janitor performs it.
            _ = try session.operations.requestPurge(
                [SyncPurgeTarget(table: "reading", rowID: seeded.readingID)])
            let readingID = seeded.readingID
            try await db.write { db in
                // The janitor removes the whole expanded family — the book's
                // memberships and chapters go with the row itself.
                try db.execute(sql: "DELETE FROM reading_post WHERE reading_id = ?", arguments: [readingID])
                try db.execute(sql: "DELETE FROM reading_section WHERE reading_id = ?", arguments: [readingID])
                try db.execute(sql: "DELETE FROM reading WHERE id = ?", arguments: [readingID])
            }
            let intentStands = try await db.read { db in
                try Bool.fetchOne(
                    db,
                    sql: "SELECT EXISTS (SELECT 1 FROM purge_intent WHERE table_name = 'reading' AND row_id = ?)",
                    arguments: [readingID]) ?? false
            }
            #expect(intentStands, "the ledger knows the ID — and only the ID")
            #expect(try await db.read { db in
                try Queries.readingTombstoneExists(db, name: SampleLibrarySeeder.Book.encryptionExplained.name)
            } == false, "the tombstone the ensure used to read is GONE")

            // The door again.
            shell.pendingSelection = nil
            actions.openTutorial(confirm: { true })
            await poll { shell.pendingSelection != nil }
            await poll { !session.tutorialDoorInFlight }
            #expect(try await encryptionBook(db).books == 0,
                    "the reader's deletion outlives the tombstone that recorded it")

            // The EXPLICIT door is still an ask — it mints, and marks.
            let again = try await SeededBookRestore.restore(session: session, book: .encryptionExplained)
            guard case .restored = again else {
                Issue.record("Help ▸ Restore still mints: \(again)")
                return
            }
            #expect(try await encryptionBook(db).books == 1)
            #expect(marks.value.contains(SampleLibrarySeeder.Book.encryptionExplained.name))
        }
    }

    /// The shared restore brain (the Mac's Help ▸ Restore and the phone's
    /// row ride it): a partial book is completed, a whole one is reported.
    @Test func theSharedRestoreMintsWhatIsMissingAndReportsAWholeBook() async throws {
        try await withWorld { session, db in
            let first = try await SeededBookRestore.restore(session: session, book: .encryptionExplained)
            guard case .restored(let readingID, let minted) = first else {
                Issue.record("a fresh store mints the book: \(first)")
                return
            }
            #expect(minted == 8, "eight chapters")
            let second = try await SeededBookRestore.restore(session: session, book: .encryptionExplained)
            #expect(second == .alreadyWhole(readingID: readingID))
            // F3 (NIT-N6): the road's failures speak words on every face —
            // never a raw enum description (the Act 10 round's dump class).
            let cases: [(any Error, String)] = [
                (SampleLibrarySeeder.LoadError.resourceMissing, "resourceMissing"),
                (CancellationError(), "CancellationError"),
                (OperationError.readingNotFound(id: "a-book-id"), "readingNotFound"),
                // 18l-c U6 ladder R2-N1: the book-refuses arms, and F12's stopped
                // script history — on BOTH faces (the phone renders these lines too).
                (OperationError.lockedReading(id: "a-book-id"), "lockedReading"),
                (OperationError.readingAtCapacity(id: "a-book-id"), "readingAtCapacity"),
                (Takemania.ScriptError.displayedTakeNotInFan(blockID: "a-block-id"), "displayedTakeNotInFan"),
            ]
            for (error, name) in cases {
                let line = SeededBookRestore.failureLine(for: error)
                #expect(!line.contains(name) && line.hasSuffix("."), "\(name) → \(line)")
            }
            #expect(SeededBookRestore.failureLine(for: OperationError.duplicateBookName(name: "Encryption Explained"))
                    == BookNameCopy.refusal(existing: "Encryption Explained"), "the one home for her duplicate-name ruling")
            // R2-N1: the approved platform-neutral words, exactly.
            #expect(SeededBookRestore.failureLine(for: OperationError.lockedReading(id: "b"))
                    // 13i-d U6 (KnownIssues row 106, a JUSTIFIED EDIT): the
                    // line holds no book, so it names BOTH roads — a sealed
                    // sample book's is Unseal (Reopen refuses there).
                    == "The book is finished \u{2014} reopen it (or unseal it, if it\u{2019}s sealed), "
                        + "then restore again.")
            #expect(SeededBookRestore.failureLine(for: OperationError.readingAtCapacity(id: "b"))
                    == "The book is at its note cap — raise the cap, then restore again.")
            // Delete one chapter: the restore brings that one back.
            let chapterID = try await db.read { db in
                try Queries.assembleReading(db, readingID: readingID).first { $0.title == "Chapter 5 — Backups, and why an old one behaves the way it does" }?.postID
            }
            let victim = try #require(chapterID)
            try session.operations.deleteContainer(victim)
            let third = try await SeededBookRestore.restore(session: session, book: .encryptionExplained)
            #expect(third == .restored(readingID: readingID, minted: 1), "\(third)")
        }
    }
}
