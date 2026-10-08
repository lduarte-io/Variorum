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

/// A launch's seeds, marks injected; returns Sherlock's outcome — what the
/// launch occasion decides by. The DEFAULT is `Book.all` — the INSTALLED
/// BASE's shape (stores born before 17y/13s carry Jekyll and *Encryption
/// Explained*), which most of this suite's existing-store pins exercise;
/// the fresh-birth pin passes `Book.launchSet`, the real launch's list
/// (13s-b U1b — `LaunchFurnitureTests` drives the production composition).
@MainActor
@discardableResult
private func launchSeeds(
    _ session: AppSession,
    books: [SampleLibrarySeeder.Book] = SampleLibrarySeeder.Book.all
) async -> SampleLibrarySeeder.Outcome {
    var sherlock: SampleLibrarySeeder.Outcome = .alreadySeeded
    for book in books {
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

/// A book's live MEMBER notes, in book order.
private func memberIDs(_ db: AppDatabase, _ readingID: String) async throws -> [String] {
    try await db.read { db in
        try String.fetchAll(
            db,
            sql: """
                SELECT post_id FROM reading_post
                WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                ORDER BY position, id
                """,
            arguments: [readingID])
    }
}

private let sherlockName = SampleLibrarySeeder.Book.sherlock.name
private let jekyllName = SampleLibrarySeeder.Book.jekyllAndHyde.name
private let encryptionName = SampleLibrarySeeder.Book.encryptionExplained.name

@MainActor
@Suite("The Welcome arrangement — the shelf, the classics, the quicknote (13i-d U7)")
struct SampleLibraryWelcomeTests {

    /// **A FRESH STORE'S BIRTH** — the whole arrangement over the REAL
    /// launch set, §19.3 included. **JUSTIFIED EDIT (13s-b U1b, R-13s-5/
    /// 26/27/37):** the fresh seed is her final set — the arrangement no
    /// longer mints the classics gathering or the seeded quicknote (so no
    /// Quicknotes gathering exists either), and the launch seeds Sherlock
    /// alone of the books (`Book.launchSet`). RED ON OLD per retired fact:
    /// the old arrangement minted both, and the old launch seeded EE.
    @Test func aFreshStoresBirthArrangesTheWholeWelcome() async throws {
        try await withWelcomeWorld { session, db in
            let sherlock = await launchSeeds(session, books: SampleLibrarySeeder.Book.launchSet)
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
            #expect(arranged.taggedClassics > 0, "Sherlock's shipped notes were tagged #classics")

            let f = try await facts(db)
            // THE WELCOME SHELF — one, role'd, named, in Home.
            let welcome = try #require(f.welcomes.first)
            #expect(f.welcomes.count == 1)
            #expect(welcome.name == "Welcome" && welcome.wingId == "")
            // The seeded content ON it (§19, reshaped at R-13s-5): Sherlock.
            // (The field guide is the Mac launch's own birth seed — 17y
            // B-SEED; this pin drives the shared brain without it, and
            // `LaunchFurnitureTests` pins the guide on Welcome through the
            // production launch.)
            #expect(f.shelfOf[sherlockName] == .some(welcome.id), "Sherlock sits on Welcome")
            // §19.3 — her working objects start UNSHELVED.
            #expect(f.shelfOf[Operations.starredNotesGatheringName] == .some(nil),
                    "the starred-notes gathering starts unshelved")
            // Sherlock OWNED; the retired seed absent entirely.
            #expect(f.readingByName[sherlockName]?.owned == true)
            #expect(f.readingByName[jekyllName] == nil, "no Jekyll (R-17y-8)")
            #expect(f.readingByName[encryptionName] == nil, "no Encryption Explained (R-13s-37)")
            #expect(f.readingByName[SampleLibraryWelcome.classicsGatheringName] == nil,
                    "no classics gathering — its door is Help ▸ Restore (R-13s-5)")
            #expect(f.readingByName[Operations.defaultQuicknoteBookName] == nil,
                    "no Quicknotes — created at first mint (R-13s-37)")
            #expect(f.quicknotes.isEmpty, "no seeded quicknote (R-13s-5)")
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

    /// **THE CLASSICS TAGGING, WITHOUT THE GATHERING (13s-b U1b — a
    /// JUSTIFIED EDIT of the U7 continuation's gathering pin; R-13s-5/37):**
    /// the arrangement still tags every shipped note of both classic books
    /// `#classics` (so the gathering, now behind its own Help ▸ Restore
    /// door, shows them the moment it is made — the door's own suite pins
    /// that), but it MINTS NO gathering any more. RED ON OLD: the old
    /// arrangement minted one. Driven over the installed base's shape
    /// (both classic books present — `Book.all`).
    @Test func theArrangementTagsTheClassicsAndMintsNoGathering() async throws {
        try await withWelcomeWorld { session, db in
            let sherlock = await launchSeeds(session)
            let mark = WelcomeMark()
            await SampleLibraryWelcome.arrangeAtLaunch(
                session: session, sherlock: sherlock, guideName: nil,
                loadMark: mark.load, saveMark: mark.save)
            try await db.read { db in
                #expect(try Queries.readings(db).first {
                    $0.name == SampleLibraryWelcome.classicsGatheringName
                } == nil, "no classics gathering mints here — the door is its road (R-13s-5)")
                let classicsTag = try #require(try Queries.allTags(db, wingID: "").first {
                    $0.path == SampleLibrarySeeder.classicsTagPath
                }, "the ONE spelling the dedupe facts declare")
                let sherlockBook = try #require(try Queries.readings(db).first { $0.name == sherlockName })
                let jekyllBook = try #require(try Queries.readings(db).first { $0.name == jekyllName })
                let sherlockNotes = Set(try Queries.assembleReading(db, readingID: sherlockBook.id).map(\.postID))
                let jekyllNotes = Set(try Queries.assembleReading(db, readingID: jekyllBook.id).map(\.postID))
                // THE SEED SHAPE: every shipped note of both books wears it.
                let tagged = Set(try String.fetchAll(
                    db,
                    sql: "SELECT post_id FROM post_tag WHERE tag_id = ? AND deleted_at IS NULL",
                    arguments: [classicsTag.id]))
                #expect(sherlockNotes.union(jekyllNotes) == tagged,
                        "both books' shipped notes wear #classics — and nothing else does")
                let badges = try Queries.ownershipFacts(db, postIDs: Array(tagged))
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

    /// **F-U7-1's two-sided pin, FLIPPED DELIBERATELY to the ruled letter**
    /// (the U7 continuation). It used to pin "one `#classics` application on a
    /// Sherlock story reads EDITED" — the mechanism that STOPPED the tag. The
    /// architect's `Sync/` half (17aa1113) declared `classicsTagPath` a SEED
    /// path the classifier skips, and that old assertion now INVERTS (RED on
    /// the post-17aa1113 tree: `after → .pristine`, `c1-oldpin-red.log`).
    /// Now, through the REAL classifier: the ARRANGED seed — every shipped
    /// Sherlock story wearing `#classics`, the book owned and on Welcome —
    /// reads PRISTINE (both judged books); and the err-toward-EDITED letter
    /// still stands for any path the facts do NOT declare (the control).
    @Test func theClassicsSeedReadsPristineAndAForeignTagStillEdits() async throws {
        try await withWelcomeWorld { session, db in
            let sherlock = await launchSeeds(session)
            let mark = WelcomeMark()
            await SampleLibraryWelcome.arrangeAtLaunch(
                session: session, sherlock: sherlock, guideName: nil,
                loadMark: mark.load, saveMark: mark.save)
            let (story, wearsClassics) = try await db.read { db -> (String, Bool) in
                let id = try #require(try Queries.readings(db).first { $0.name == sherlockName }?.id)
                let story = try #require(try Queries.assembleReading(db, readingID: id).last?.postID)
                let wears = try Bool.fetchOne(
                    db,
                    sql: """
                        SELECT EXISTS (SELECT 1 FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                                       WHERE pt.post_id = ? AND t.path = ? AND pt.deleted_at IS NULL
                                         AND t.deleted_at IS NULL)
                        """,
                    arguments: [story, SampleLibrarySeeder.classicsTagPath]) ?? false
                return (story, wears)
            }
            #expect(wearsClassics, "the arranged seed carries the seed-authored #classics")
            for book in SampleLibrarySeeder.Book.dedupeCovered {
                let verdict = try await db.read { db -> SampleCopyVerdict in
                    let id = try #require(try Queries.readings(db).first { $0.name == book.name }?.id)
                    return try SampleCopyClassifier.classify(
                        db, copyID: id, facts: SampleLibrarySeeder.dedupeFacts(for: book))
                }
                #expect(verdict == .pristine,
                        "\(book.name) reads PRISTINE with the classics seed on it (the ruled letter)")
            }
            // The control: a path the facts do NOT declare is still her hand.
            let foreign = try session.operations.createTag(name: "favourites")
            _ = try session.operations.applyTag(foreign.id, toPost: story)
            let after = try await db.read { db -> SampleCopyVerdict in
                let id = try #require(try Queries.readings(db).first { $0.name == sherlockName }?.id)
                return try SampleCopyClassifier.classify(
                    db, copyID: id, facts: SampleLibrarySeeder.dedupeFacts(for: .sherlock))
            }
            #expect(after == .edited, "a tag outside the declared seed set still protects her copy")
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
            // (13s-b U1b: the classics gathering and the quicknote left the
            // arrangement — an existing store's door shelves and owns, and
            // mints neither.)
            for name in [sherlockName, encryptionName] {
                #expect(f.shelfOf[name] == .some(hers.shelf.id), "\(name) onto her Welcome")
            }
            #expect(f.readingByName[sherlockName]?.owned == true)
            #expect(f.readingByName[SampleLibraryWelcome.classicsGatheringName] == nil)
            #expect(f.quicknotes.isEmpty)
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
            // (13s-b U1b: the seeded quicknote left the arrangement — the
            // old "+ 1" was it.)
            #expect(notesAfter == notesBefore, "no fork copy, and nothing minted")
            #expect(try await facts(db).readingByName[sherlockName]?.owned == false)
        }
    }

    /// **F-U7-3, RULED re-add-as-COPY (the U7 continuation C2).** The restore
    /// road re-members a STRAY story (tagged, live, out of its book) — and an
    /// OWNED Sherlock meets the ownership consult when that story now lives in
    /// another book (`noteMemberedElsewhere`). The ruled answer is the
    /// doctrine's own: it comes back as a COPY (lineage kept); her book keeps
    /// the original; nothing is severed. RED ON OLD: the restore THREW partway
    /// and spoke an impossible "try again".
    @Test func aClaimedElsewhereStoryComesBackIntoAnOwnedBookAsACopy() async throws {
        try await withWelcomeWorld { session, db in
            _ = await launchSeeds(session)
            let ops = session.operations
            let sherlockID = try #require(try await facts(db).readingByName[sherlockName]?.id)
            _ = try ops.setReadingOwned(sherlockID, owned: true)
            let (story, title) = try await db.read { db -> (String, String) in
                let id = try #require(try Queries.assembleReading(db, readingID: sherlockID).last?.postID)
                return (id, try #require(try Queries.containerTitle(db, id: id)))
            }
            #expect(try ops.removePostFromReading(story, from: sherlockID), "released — bookless")
            let favorites = try ops.createReading(name: "favorites", kind: .book)
            _ = try ops.addPostToReading(story, to: favorites.id)

            let restored = try await SeededBookRestore.restore(session: session, book: .sherlock)
            guard case .restored(_, let minted) = restored else {
                Issue.record("the story comes back: \(restored)")
                return
            }
            #expect(minted == 1)
            let back = try await db.read { db -> (copy: String?, sectioned: Bool, lineage: Bool) in
                let members = try Queries.assembleReading(db, readingID: sherlockID)
                let copy = members.first { $0.title == title }?.postID
                let sectioned = try copy.map { id in
                    try String.fetchOne(
                        db, sql: """
                            SELECT section_id FROM reading_post
                            WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL
                            """, arguments: [sherlockID, id]) != nil
                } ?? false
                let lineage = try copy.map { id in
                    try Bool.fetchOne(
                        db,
                        sql: """
                            SELECT EXISTS (SELECT 1 FROM edge e
                              JOIN container_block a ON a.block_id = e.source_block_id AND a.container_id = ?
                              JOIN container_block b ON b.block_id = e.target_block_id AND b.container_id = ?
                              WHERE e.deleted_at IS NULL)
                            """, arguments: [id, story]) ?? false
                } ?? false
                return (copy, sectioned, lineage)
            }
            let copy = try #require(back.copy, "the title is back in the book")
            #expect(copy != story, "…as a COPY — the original stays hers")
            #expect(back.sectioned, "…in its chapter")
            #expect(back.lineage, "…remembering where it came from")
            #expect(try await memberIDs(db, favorites.id) == [story], "her book keeps the original")
            #expect(try await facts(db).readingByName[sherlockName]?.owned == true, "still owned")
        }
    }

    /// F-U7-3's sibling, the consult's OTHER arm: a PLAIN book (Jekyll) whose
    /// released story she put into her own OWNED book (`noteOwnedElsewhere` —
    /// copy only). The same answer: a copy comes back. RED ON OLD: it threw.
    @Test func aStoryOwnedElsewhereComesBackIntoAPlainBookAsACopy() async throws {
        try await withWelcomeWorld { session, db in
            _ = await launchSeeds(session)
            let ops = session.operations
            let jekyllID = try #require(try await facts(db).readingByName[jekyllName]?.id)
            let (story, title) = try await db.read { db -> (String, String) in
                // A STORY (the front matter is never "missing" to a restore —
                // `expectedTitles` lists the stories and the scripted note).
                let entry = try #require(try Queries.assembleReading(db, readingID: jekyllID).first {
                    $0.title != SampleLibraryJekyllBook.frontMatterTitle && $0.title != Takemania.title
                })
                return (entry.postID, try #require(entry.title))
            }
            _ = try ops.removePostFromReading(story, from: jekyllID)
            let mine = try ops.createReading(name: "mine", kind: .book)
            _ = try ops.setReadingOwned(mine.id, owned: true)
            _ = try ops.addPostToReading(story, to: mine.id)

            let restored = try await SeededBookRestore.restore(session: session, book: .jekyllAndHyde)
            guard case .restored = restored else {
                Issue.record("the story comes back: \(restored)")
                return
            }
            let copy = try await db.read { db in
                try Queries.assembleReading(db, readingID: jekyllID).first { $0.title == title }?.postID
            }
            #expect(copy != nil && copy != story, "back in Jekyll as a copy")
            #expect(try await memberIDs(db, mine.id) == [story], "her owned book keeps its note")
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
        // 13s-b U1b: the arrangement no longer makes the gathering or a
        // quick note, so the disclosure must not claim either (the same
        // MINOR-D3/D4 exact-scope rule, pointing the other way).
        #expect(!detail.contains(SampleLibraryWelcome.classicsGatheringName),
                "it no longer claims the gathering")
        #expect(!detail.contains("quick note"), "…nor the quick note")
        #expect(detail.contains("#\(SampleLibrarySeeder.classicsTagPath)"),
                "…and still says the classic books' notes are tagged")
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
