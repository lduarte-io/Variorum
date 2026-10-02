//
//  SampleLibraryWelcomeTests.swift
//  VariorumTests
//
//  13i-d U7 — THE WELCOME ARRANGEMENT's acceptance bar, as state tests
//  (the sitting record §7, §17(a)/(b), §19.3; the U7 brief's evidence):
//
//    · a FRESH store's birth arranges it whole — the Welcome shelf with its
//      role, the seeded books on it, Sherlock OWNED with zero forks, Jekyll
//      plain, the classics gathering on Welcome, ONE seeded quicknote — and
//      Journal / Quicknotes / the starred-notes gathering stay UNSHELVED;
//    · an EXISTING store's launch is NEVER retrofitted (the decision is
//      marked, nothing is written);
//    · the RESTORE doors arrange an existing store — her Welcome ADOPTED,
//      never duplicated; a book she filed elsewhere stays filed; a Sherlock
//      story shared with her own book leaves Sherlock plain (no silent fork);
//    · the arranged seed stays PRISTINE to the sync dedupe — and the ruled
//      `#classics` application would not (F-U7-1's mechanism, pinned).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withWelcomeWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1886))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        // The seeded-book marks are INJECTED — a headless run never reads or
        // writes the test host's defaults (the test host IS the dev app).
        session.seededBookMarkIsSet = { _ in false }
        session.markSeededBook = { _ in }
        return try await body(session, db)
    }
}

@MainActor
private func poll(_ condition: @MainActor () -> Bool, turns: Int = 600) async {
    for _ in 0..<turns {
        if condition() { return }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(5))
    }
}

/// A launch's seeds, the Mac's order (`Book.all`), marks injected; returns
/// Sherlock's outcome — what the launch occasion decides by.
@MainActor
@discardableResult
private func launchSeeds(_ session: AppSession) async -> SampleLibrarySeeder.Outcome {
    var sherlock: SampleLibrarySeeder.Outcome = .alreadySeeded
    for book in SampleLibrarySeeder.Book.all {
        let outcome = await SampleLibrarySeeder.seedIfNeeded(
            session: session, book: book, loadMark: { false }, saveMark: { _ in })
        if book == .sherlock { sherlock = outcome }
    }
    _ = await StarredGatheringSeeder.seedIfNeeded(
        session: session, loadMark: { false }, saveMark: { _ in })
    return sherlock
}

/// A defaults-free launch mark.
@MainActor
private final class WelcomeMark {
    var value: String?
    var load: () -> String? { { [self] in value } }
    var save: (String) -> Void { { [self] in value = $0 } }
}

/// The store's facts the arrangement promises, read in one transaction.
private struct WelcomeFacts {
    var welcomes: [Shelf]
    var shelfOf: [String: String?]   // reading name → shelf id
    var readingByName: [String: Reading]
    var quicknotes: [String]          // live posts with the reserved title
}

private func facts(_ db: AppDatabase) async throws -> WelcomeFacts {
    try await db.read { db in
        let welcomes = try Shelf.fetchAll(
            db,
            sql: """
                SELECT * FROM shelf WHERE role = 'welcome' AND deleted_at IS NULL ORDER BY id
                """)
        let readings = try Queries.readings(db)
        var byName: [String: Reading] = [:]
        var shelfOf: [String: String?] = [:]
        for reading in readings {
            byName[reading.name] = reading
            shelfOf[reading.name] = reading.shelfId
        }
        let quicknotes = try String.fetchAll(
            db,
            sql: "SELECT id FROM container WHERE kind = 'post' AND deleted_at IS NULL AND title = ?",
            arguments: [SampleLibraryWelcome.quicknoteTitle])
        return WelcomeFacts(
            welcomes: welcomes, shelfOf: shelfOf, readingByName: byName, quicknotes: quicknotes)
    }
}

private let sherlockName = SampleLibrarySeeder.Book.sherlock.name
private let jekyllName = SampleLibrarySeeder.Book.jekyllAndHyde.name
private let encryptionName = SampleLibrarySeeder.Book.encryptionExplained.name

@MainActor
@Suite("The Welcome arrangement — the shelf, the classics, the quicknote (13i-d U7)")
struct SampleLibraryWelcomeTests {

    /// **A FRESH STORE'S BIRTH** — the whole arrangement, §19.3 included.
    @Test func aFreshStoresBirthArrangesTheWholeWelcome() async throws {
        try await withWelcomeWorld { session, db in
            let sherlock = await launchSeeds(session)
            let mark = WelcomeMark()
            let outcome = await SampleLibraryWelcome.arrangeAtLaunch(
                session: session, sherlock: sherlock, guideName: TutorialSeeder.bookName,
                loadMark: mark.load, saveMark: mark.save)
            guard case .arranged(let arranged) = outcome else {
                Issue.record("a fresh store is arranged at birth: \(outcome)")
                return
            }
            #expect(mark.value == "done")
            #expect(arranged.welcome.minted)
            #expect(arranged.sherlock == .owned)
            #expect(arranged.mintedClassics && arranged.mintedQuicknote)

            let f = try await facts(db)
            // THE WELCOME SHELF — one, role'd, named, in Home.
            let welcome = try #require(f.welcomes.first)
            #expect(f.welcomes.count == 1)
            #expect(welcome.name == "Welcome" && welcome.wingId == "")
            // The seeded content ON it (§19): the three books + the classics
            // gathering (the guide is seeded when she first opens it).
            for name in [sherlockName, jekyllName, encryptionName,
                         SampleLibraryWelcome.classicsGatheringName] {
                #expect(f.shelfOf[name] == .some(welcome.id), "\(name) sits on Welcome")
            }
            // §19.3 — her working objects start UNSHELVED.
            #expect(f.shelfOf[Operations.defaultQuicknoteBookName] == .some(nil),
                    "Quicknotes starts unshelved")
            #expect(f.shelfOf[Operations.starredNotesGatheringName] == .some(nil),
                    "the starred-notes gathering too")
            // Sherlock OWNED, Jekyll and the encryption book plain.
            #expect(f.readingByName[sherlockName]?.owned == true)
            #expect(f.readingByName[jekyllName]?.owned == false)
            #expect(f.readingByName[encryptionName]?.owned == false)
            // ONE seeded quicknote, filed the quick note's own way.
            #expect(f.quicknotes.count == 1)
            let quicknoteID = try #require(f.quicknotes.first)
            let (tagged, inQuicknotes, books, starred) = try await db.read { db in
                let tag = try Queries.allTags(db).first { $0.path == Operations.quicknoteTagPath }
                let tagged = try tag.map {
                    try Queries.everythingTagged(db, tagID: $0.id).postIDs.contains(quicknoteID)
                } ?? false
                let quicknotesBook = try #require(try Queries.quicknotesBookID(db))
                let shown = try Queries.assembleReading(db, readingID: quicknotesBook).map(\.postID)
                return (tagged, shown.contains(quicknoteID),
                        try Queries.noteMemberships(db, postID: quicknoteID).count,
                        try Queries.starredReadingIDs(db).contains(quicknotesBook))
            }
            #expect(tagged, "it wears #quicknote")
            #expect(inQuicknotes, "Quicknotes shows it — a live example")
            #expect(books == 0, "a quick note is bookless")
            #expect(starred, "Quicknotes is born starred (R-13id-5)")
            #expect(session.undoStack.depth == 0, "furniture never lands on her ⌥⌘Z")

            // §19.3 again, later: the daily Journal ⌘J mints is unshelved.
            let entry = try session.operations.createPost(title: nil)
            _ = session.operations.shelveInDailyJournalBook(entry.id)
            let journalShelf = try await db.read { db -> String?? in
                guard let id = try Queries.dailyJournalBookID(db) else { return nil }
                return .some(try Queries.reading(db, id: id)?.shelfId)
            }
            #expect(journalShelf == .some(nil), "the daily Journal starts unshelved")
        }
    }

    /// **THE CLASSICS GATHERING — R1's object.** It shows Jekyll's and
    /// Sherlock's notes side by side; Sherlock's wear the owned mark; it is
    /// made from the books' own tags (P-13id-U7-1) and holds nothing.
    @Test func theClassicsGatheringShowsBothBooksAndSherlocksWearTheOwnedMark() async throws {
        try await withWelcomeWorld { session, db in
            let sherlock = await launchSeeds(session)
            let mark = WelcomeMark()
            await SampleLibraryWelcome.arrangeAtLaunch(
                session: session, sherlock: sherlock, guideName: nil,
                loadMark: mark.load, saveMark: mark.save)
            try await db.read { db in
                let classics = try #require(try Queries.readings(db).first {
                    $0.name == SampleLibraryWelcome.classicsGatheringName
                })
                #expect(classics.kind == .gathering)
                let tags = try Queries.allTags(db)
                let sherlockTag = try #require(tags.first { $0.path == SampleLibrarySeeder.Book.sherlock.tagName })
                let jekyllTag = try #require(tags.first { $0.path == SampleLibrarySeeder.Book.jekyllAndHyde.tagName })
                #expect(RuleGrammar.read(classics.querySpec)
                        == .rule(SampleLibraryWelcome.classicsRule(
                            sherlockTagID: sherlockTag.id, jekyllTagID: jekyllTag.id)))
                #expect(try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ?",
                    arguments: [classics.id]) == 0, "a gathering holds nothing")

                let shown = try Queries.assembleReading(db, readingID: classics.id, limit: 300)
                let sherlockBook = try #require(try Queries.readings(db).first { $0.name == sherlockName })
                let jekyllBook = try #require(try Queries.readings(db).first { $0.name == jekyllName })
                let sherlockNotes = Set(try Queries.assembleReading(db, readingID: sherlockBook.id).map(\.postID))
                let jekyllNotes = Set(try Queries.assembleReading(db, readingID: jekyllBook.id).map(\.postID))
                let shownIDs = Set(shown.map(\.postID))
                #expect(sherlockNotes.isSubset(of: shownIDs), "every Sherlock note shows")
                #expect(jekyllNotes.isSubset(of: shownIDs), "…beside every Jekyll note")
                #expect(shownIDs == sherlockNotes.union(jekyllNotes), "and nothing else")
                let badges = try Queries.ownershipFacts(db, postIDs: Array(shownIDs))
                for id in sherlockNotes {
                    #expect(badges[id]?.ownedBy?.id == sherlockBook.id,
                            "a Sherlock note wears “owned by” its book")
                }
                for id in jekyllNotes {
                    #expect(badges[id]?.ownedBy == nil, "Jekyll is plain — no owned mark")
                }
            }
        }
    }

    /// **F-U7-1, pinned both ways.** The arranged seed stays PRISTINE to the
    /// sync dedupe's real classifier (the owned flag and the shelf pointer
    /// are invisible to it) — and the ruled `#classics` application on a
    /// Sherlock note would read EDITED, which is why it is STOPPED.
    @Test func theArrangedSeedStaysPristineAndTheRuledTagWouldNot() async throws {
        try await withWelcomeWorld { session, db in
            let sherlock = await launchSeeds(session)
            let mark = WelcomeMark()
            await SampleLibraryWelcome.arrangeAtLaunch(
                session: session, sherlock: sherlock, guideName: nil,
                loadMark: mark.load, saveMark: mark.save)
            for book in SampleLibrarySeeder.Book.dedupeCovered {
                let verdict = try await db.read { db -> SampleCopyVerdict in
                    let id = try #require(try Queries.readings(db).first { $0.name == book.name }?.id)
                    return try SampleCopyClassifier.classify(
                        db, copyID: id, facts: SampleLibrarySeeder.dedupeFacts(for: book))
                }
                #expect(verdict == .pristine, "\(book.name) stays pristine after the arrangement")
            }
            // The ruled letter's mechanism: one `#classics` on one story.
            let classics = try session.operations.createTag(name: "classics")
            let story = try await db.read { db in
                let id = try #require(try Queries.readings(db).first { $0.name == sherlockName }?.id)
                return try #require(try Queries.assembleReading(db, readingID: id).last?.postID)
            }
            _ = try session.operations.applyTag(classics.id, toPost: story)
            let after = try await db.read { db -> SampleCopyVerdict in
                let id = try #require(try Queries.readings(db).first { $0.name == sherlockName }?.id)
                return try SampleCopyClassifier.classify(
                    db, copyID: id, facts: SampleLibrarySeeder.dedupeFacts(for: .sherlock))
            }
            #expect(after == .edited,
                    "an extra tag reads as her hand — two fresh devices would keep two Sherlocks (F-U7-1)")
        }
    }

    /// **NEVER A SILENT RETROFIT.** A launch on a store that already had the
    /// library marks the decision and writes NOTHING — no Welcome, no owned
    /// flag, no gathering, no quicknote.
    @Test func anExistingStoresLaunchIsNeverRetrofitted() async throws {
        try await withWelcomeWorld { session, db in
            _ = await launchSeeds(session)          // an older build's launch
            let again = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: .sherlock, loadMark: { true }, saveMark: { _ in })
            #expect(again == .alreadySeeded)
            let present = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: .sherlock, loadMark: { false }, saveMark: { _ in })
            #expect(present == .alreadyPresent, "a lost mark finds the library present")
            for outcome in [again, present] {
                let mark = WelcomeMark()
                let decided = await SampleLibraryWelcome.arrangeAtLaunch(
                    session: session, sherlock: outcome, guideName: TutorialSeeder.bookName,
                    loadMark: mark.load, saveMark: mark.save)
                #expect(decided == .declined)
                #expect(mark.value == "declined", "the decision is recorded")
            }
            let f = try await facts(db)
            #expect(f.welcomes.isEmpty, "no Welcome shelf was minted")
            #expect(f.readingByName[sherlockName]?.owned == false, "Sherlock untouched")
            #expect(f.readingByName[SampleLibraryWelcome.classicsGatheringName] == nil)
            #expect(f.quicknotes.isEmpty)
            #expect(f.shelfOf[sherlockName] == .some(nil), "and nothing was shelved")
        }
    }

    /// The marks: `pending` resumes (a window closed mid-arrangement), `done`
    /// and `declined` are settled, an account store awaiting its first round
    /// is UNDECIDED (nothing marked, nothing written), and a resumed PARTIAL
    /// Sherlock seed is not a birth.
    @Test func theLaunchMarksDecideAndResume() async throws {
        try await withWelcomeWorld { session, db in
            let undecided = WelcomeMark()
            #expect(await SampleLibraryWelcome.arrangeAtLaunch(
                session: session, sherlock: .awaitingFirstSync, guideName: nil,
                loadMark: undecided.load, saveMark: undecided.save) == .undecided)
            #expect(undecided.value == nil, "not marked — the next launch asks again")

            let partial = WelcomeMark()
            #expect(await SampleLibraryWelcome.arrangeAtLaunch(
                session: session, sherlock: .seeded(readingID: "x", stories: 5), guideName: nil,
                loadMark: partial.load, saveMark: partial.save) == .declined,
                    "five of twelve stories is a resumed seed in a store that already had some")

            for settled in ["done", "declined"] {
                let mark = WelcomeMark()
                mark.value = settled
                #expect(await SampleLibraryWelcome.arrangeAtLaunch(
                    session: session, sherlock: .alreadySeeded, guideName: nil,
                    loadMark: mark.load, saveMark: mark.save) == .alreadySettled)
            }
            let untouched = try await facts(db)
            #expect(untouched.welcomes.isEmpty, "none of those wrote anything")

            let pending = WelcomeMark()
            pending.value = "pending"
            guard case .arranged = await SampleLibraryWelcome.arrangeAtLaunch(
                session: session, sherlock: .alreadySeeded, guideName: nil,
                loadMark: pending.load, saveMark: pending.save)
            else {
                Issue.record("a pending mark resumes the arrangement")
                return
            }
            #expect(pending.value == "done")
            let resumed = try await facts(db)
            #expect(resumed.welcomes.count == 1)
        }
    }

    /// **THE RESTORE DOORS ON AN EXISTING STORE — Welcome ADOPTED, never
    /// duplicated.** Her store already has a role'd Welcome (renamed "Front
    /// Door") and her own shelf "Essays" holding Jekyll; Help ▸ Restore the
    /// Sample Library arranges: the SAME shelf, Jekyll stays filed, the rest
    /// land on "Front Door", Sherlock owned — and the receipt names her shelf.
    @Test func theRestoreDoorArrangesAnExistingStoreAdoptingHerWelcome() async throws {
        try await withWelcomeWorld { session, db in
            _ = await launchSeeds(session)          // an existing store: no arrangement
            let hers = try session.operations.ensureWelcomeShelf()
            try session.operations.renameShelf(hers.shelf.id, to: "Front Door")
            let essays = try session.operations.createShelf(name: "Essays")
            let jekyllID = try #require(try await facts(db).readingByName[jekyllName]?.id)
            try session.operations.setReadingShelf(jekyllID, shelf: essays.id)

            let actions = ShellActions(session: session, shell: ShellRouter())
            actions.restoreSampleLibrary()
            await poll { session.status.current != nil || session.status.spoken != nil }

            let f = try await facts(db)
            #expect(f.welcomes.map(\.id) == [hers.shelf.id], "ADOPTED — never a second Welcome")
            #expect(f.shelfOf[jekyllName] == .some(essays.id), "a book she filed stays filed")
            for name in [sherlockName, encryptionName, SampleLibraryWelcome.classicsGatheringName] {
                #expect(f.shelfOf[name] == .some(hers.shelf.id), "\(name) onto her Welcome")
            }
            #expect(f.readingByName[sherlockName]?.owned == true)
            #expect(f.quicknotes.count == 1)
            #expect(session.status.spoken?.text == WelcomeDoorCopy.alreadyWholeArranged(
                book: sherlockName, shelf: "Front Door"),
                    "the door acted, so it speaks a receipt naming HER shelf")
            #expect(session.status.spoken?.text.contains("Front Door") == true)

            // Again: nothing new — the standing refusal (P-2: a door that did
            // nothing says so).
            session.status.clear()
            actions.restoreSampleLibrary()
            await poll { session.status.current != nil }
            #expect(session.status.current?.kind == .refusal)
            #expect(try await facts(db).welcomes.count == 1, "and still one Welcome")
        }
    }

    /// **NO SILENT FORK.** A Sherlock story she also put in her own book:
    /// owning Sherlock would copy it, so the arrangement leaves Sherlock
    /// plain — and mints no note.
    @Test func aSharedSherlockStoryLeavesSherlockPlainAndForksNothing() async throws {
        try await withWelcomeWorld { session, db in
            _ = await launchSeeds(session)
            let favorites = try session.operations.createReading(name: "favorites", kind: .book)
            let story = try await db.read { db in
                let id = try #require(try Queries.readings(db).first { $0.name == sherlockName }?.id)
                return try #require(try Queries.assembleReading(db, readingID: id).last?.postID)
            }
            _ = try session.operations.addPostToReading(story, to: favorites.id)
            let notesBefore = try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL") ?? 0
            }
            let arranged = try await SampleLibraryWelcome.arrange(session: session, guideName: nil)
            #expect(arranged.sherlock == .leftPlainShared(1))
            let notesAfter = try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL") ?? 0
            }
            #expect(notesAfter == notesBefore + 1, "only the seeded quicknote — no fork copy")
            #expect(try await facts(db).readingByName[sherlockName]?.owned == false)
        }
    }

    /// Idempotent: a second arrangement writes nothing and says so.
    @Test func aSecondArrangementWritesNothing() async throws {
        try await withWelcomeWorld { session, db in
            _ = await launchSeeds(session)
            let first = try await SampleLibraryWelcome.arrange(session: session, guideName: nil)
            #expect(first.didAnything)
            let outboxBefore = try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0
            }
            let second = try await SampleLibraryWelcome.arrange(session: session, guideName: nil)
            #expect(!second.didAnything)
            #expect(second.sherlock == .alreadyOwned)
            #expect(second.welcome.shelf.id == first.welcome.shelf.id)
            #expect(second.classicsID == first.classicsID)
            #expect(second.quicknoteID == first.quicknoteID)
            let outboxAfter = try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0
            }
            #expect(outboxAfter == outboxBefore, "not one row written")
        }
    }

    /// **THE WALK'S W-1 — the confirm must disclose what the door does.**
    /// Help ▸ Restore Tutorial's confirm promised "Nothing else is touched",
    /// but the door now composes the Welcome arrangement too (it can own
    /// Sherlock and make the classics gathering and a quick note). The
    /// Stage 2 ladder's MINOR-D3/D4 rule — the disclosure is EXACT about
    /// scope — applies to what this unit added. RED ON OLD: the shipped
    /// detail named none of it.
    @Test func theRestoreConfirmDisclosesTheWelcomeArrangement() {
        let detail = TutorialSeeder.replaceDetail
        #expect(detail.contains(Operations.welcomeShelfName), "it names the Welcome shelf")
        #expect(detail.contains(SampleLibrarySeeder.Book.sherlock.name),
                "…the one book whose state the arrangement can change")
        #expect(detail.contains("\u{201C}\(SampleLibraryWelcome.classicsGatheringName)\u{201D}"),
                "…the gathering it can make")
        #expect(detail.contains("quick note"), "…and the quick note")
        #expect(detail.hasSuffix("Nothing else is touched."),
                "and only THEN does it promise the rest is untouched")
    }

    /// **Restore Tutorial puts the fresh guide on Welcome — beside *Encryption
    /// Explained*, which is what makes the privacy lesson's "on this shelf"
    /// literally true (P-13id-U7-6).** The open door on an EXISTING guide
    /// arranges nothing.
    @Test func restoreTutorialPutsTheGuideOnWelcomeBesideTheEncryptionBook() async throws {
        try await withWelcomeWorld { session, db in
            _ = await launchSeeds(session)          // an existing store
            _ = try await TutorialSeeder.restore(session: session)
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)
            actions.openTutorial(confirm: { true })
            await poll { shell.pendingSelection != nil }
            await poll { !session.tutorialDoorInFlight }
            #expect(try await facts(db).welcomes.isEmpty,
                    "opening an existing guide is not a restore — nothing arranged")

            shell.pendingSelection = nil
            actions.restoreTutorial(confirm: { true })
            await poll { shell.pendingSelection != nil }
            await poll { !session.tutorialDoorInFlight }
            let f = try await facts(db)
            let welcome = try #require(f.welcomes.first)
            #expect(f.shelfOf[TutorialSeeder.bookName] == .some(welcome.id), "the guide on Welcome")
            #expect(f.shelfOf[encryptionName] == .some(welcome.id),
                    "…beside the book its privacy lesson names — “on this shelf”, true")
            #expect(session.status.spoken?.text == WelcomeDoorCopy.tutorialRestored(
                guide: TutorialSeeder.bookName, shelf: "Welcome"))
        }
    }
}
