//
//  BookArchivedLineTests.swift
//  VariorumTests
//
//  13i-d U4 — ARCHIVED MEMBERS IN BOOKS (her #169(a) ruling; the 13i-d plan
//  item 9). What these hold:
//
//  · the WORDS, pure (`ArchivedLineCopy`; the honest counts — the Index
//    footer with and without the filter, the Bookcase row meta with details
//    on and off; the Arrivals line's archived receipt);
//  · the ARCHIVED LINE mounted in a real hosted book view: ABSENT with
//    nothing set aside, PRESENT as one line on the Arrivals line's three
//    hosts (Index · Outline · Book) and absent on Read, expanding inline to
//    the archived members with Unarchive + Remove (Release on an owned book);
//  · its two ACTS against a real store (Unarchive brings the note back into
//    the book; Remove takes it out and says it stays archived; a finished
//    book's Remove refuses naming the road);
//  · the INDEX never shows an archived member (item 9.5);
//  · an ARCHIVED WAITER at the door: marked, the same doors, Add seats it as
//    an archived member with a receipt that says where it went (item 9.3);
//  · the declarations (the registry walk itself is `CapabilityRegistryTests`').
//
//  Mounted pins read `ArchivedLineProbe` / `ArrivalsLineProbe` (DEBUG — the
//  line records what it drew; a hosted SwiftUI tree exposes no
//  accessibility children here).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// A book of `members` notes (owned / finished on request), the LAST
/// `archive` of them archived.
@MainActor
private func withArchiveBook<T>(
    members: Int, archive: Int, owned: Bool = false, finished: Bool = false,
    _ body: @MainActor (
        AppSession, AppDatabase, _ readingID: String, _ memberIDs: [String]
    ) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 41))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let ops = session.operations
        let book = try ops.createReading(name: "the kept book", kind: .book)
        if owned { try ops.setReadingOwned(book.id, owned: true) }
        var memberIDs: [String] = []
        for m in 0..<members {
            let post = try ops.createPost(title: "member \(m)")
            _ = try ops.newBlock(in: post.id, text: "Member \(m)'s prose, a sentence long.")
            try ops.addPostToReading(post.id, to: book.id)
            memberIDs.append(post.id)
        }
        for id in memberIDs.suffix(archive) { try ops.archiveContainer(id) }
        if finished { try ops.lockReading(book.id) }
        return try await body(session, db, book.id, memberIDs)
    }
}

@MainActor
@Suite("13i-d U4 — a book's archived line, its counts, its archived waiters", .serialized)
struct BookArchivedLineTests {
    // MARK: - Hosting (the `BookArrivalsTests` shape)

    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool = { false }, maxTurns: Int = 8
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private struct Hosted {
        let window: NSWindow
        let hosting: NSHostingView<BookView>
        let arrivals: BookArrivalsModel
        let archived: BookArchivedModel
        let structure: BookStructureModel
        let model: BookViewModel
    }

    /// The book view in `mode`, its models loaded by hand (hosted `.task`
    /// callbacks don't fire under the test host).
    private func mounted(
        session: AppSession, db: AppDatabase, readingID: String,
        mode: BookStructureModel.ViewMode
    ) async throws -> Hosted {
        let model = BookViewModel(session: session, readingID: readingID)
        await model.adopt(try await db.read { [readingID] in
            try Queries.assembleReading($0, readingID: readingID)
        })
        let structure = BookStructureModel(session: session, readingID: readingID)
        structure.adopt(.init(
            reading: try await db.read { [readingID] in try Queries.reading($0, id: readingID) },
            sections: try await db.read { [readingID] in
                try Queries.readingSections($0, readingID: readingID)
            },
            deletedSections: [],
            assignments: try await db.read { [readingID] in
                try Queries.sectionAssignments($0, readingID: readingID)
            }))
        structure.mode = mode
        let arrivals = BookArrivalsModel(session: session, readingID: readingID)
        try await refresh(arrivals, db)
        let archived = BookArchivedModel(session: session, readingID: readingID)
        try await refresh(archived, db)
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1300, height: 820),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: BookView(
                session: session, readingID: readingID,
                model: model, structure: structure, arrivals: arrivals, archived: archived))
        hosting.frame = NSRect(x: 0, y: 0, width: 1300, height: 820)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return Hosted(
            window: window, hosting: hosting, arrivals: arrivals, archived: archived,
            structure: structure, model: model)
    }

    /// What the observations would deliver now, adopted by hand.
    private func refresh(_ archived: BookArchivedModel, _ db: AppDatabase) async throws {
        let readingID = archived.readingID
        let limit = archived.listingLimit
        archived.adopt(try await db.read {
            try Queries.bookArchivedMembers($0, readingID: readingID, limit: limit)
        })
    }

    private func refresh(_ arrivals: BookArrivalsModel, _ db: AppDatabase) async throws {
        let readingID = arrivals.readingID
        let limit = arrivals.listingLimit
        arrivals.adopt(try await db.read {
            try Queries.bookArrivals($0, readingID: readingID, limit: limit)
        })
    }

    private func reading(_ db: AppDatabase, _ id: String) async throws -> Reading {
        try #require(try await db.read { try Queries.reading($0, id: id) })
    }

    // MARK: - The words (pure)

    @Test func theWordsAndTheHonestCounts() throws {
        #expect(ArchivedLineCopy.line(count: 2) == "2 archived")
        #expect(ArchivedLineCopy.more(3) == "and 3 more archived")
        #expect(ArchivedLineCopy.unarchived("Ode")
                == "Unarchived \u{201C}Ode\u{201D} \u{2014} it\u{2019}s back in the book.")
        #expect(ArchivedLineCopy.removeWord(owned: false) == "Remove")
        #expect(ArchivedLineCopy.removeWord(owned: true) == "Release")
        let now = Date(timeIntervalSince1970: 1_782_900_000)
        let then = now.addingTimeInterval(-2 * 86_400)
        let iso = DateFormatter.variorumISO8601.string(from: then)
        #expect(ArchivedLineCopy.archived(iso, now: now)
                == "archived " + TimeStampFace.relative(then, now: now))
        #expect(ArchivedLineCopy.archived("not a stamp", now: now) == nil)
        #expect(!ArchivedLineFace.isShown(.none))
        let door = Queries.BookArchivedMembers(
            count: 4, rows: [Queries.ArchivedMember(
                id: "m", postID: "p", title: "t", archivedAt: iso)])
        #expect(ArchivedLineFace.isShown(door))
        #expect(ArchivedLineFace.hidden(door) == 3)

        // The shared remove door's archived receipts — never the Pool.
        #expect(RemoveFromBookCopy.receipt(book: "X", owned: false, bookless: true, archived: true)
                == "Removed from \u{201C}X\u{201D} \u{2014} the note itself is untouched. "
                    + "It stays archived.")
        #expect(RemoveFromBookCopy.receipt(book: "X", owned: true, bookless: true, archived: true)
                == "Released from \u{201C}X\u{201D} \u{2014} it stays archived.")
        // …and an un-archived note's receipts are untouched.
        #expect(RemoveFromBookCopy.receipt(book: "X", owned: false, bookless: true)
                == RemoveFromBookCopy.removed(book: "X", bookless: true))

        // Add on an ARCHIVED waiter says where it went (item 9.3).
        #expect(ArrivalsCopy.added("Ode", chaptered: true, archived: true)
                == "\u{201C}Ode\u{201D} added to the book \u{2014} it\u{2019}s archived, so it "
                    + "waits in the book\u{2019}s archived line.")
        #expect(ArrivalsCopy.added("Ode", chaptered: false)
                == "\u{201C}Ode\u{201D} added at the end of the book.", "the ordinary Add unchanged")

        // THE INDEX FOOTER (item 9.2 × U3's filter count).
        #expect(BookIndexColumn.footerWords(chapters: 0, notes: 5, filtered: false, archived: 2)
                == "5 notes · 2 archived")
        #expect(BookIndexColumn.footerWords(chapters: 3, notes: 5, filtered: false, archived: 2)
                == "3 chapters · 5 notes · 2 archived")
        #expect(BookIndexColumn.footerWords(chapters: 0, notes: 5, filtered: false, archived: 0)
                == "5 notes", "nothing set aside — nothing said")
        #expect(BookIndexColumn.footerWords(chapters: 0, notes: 2, filtered: true, archived: 2)
                == "2 shown", "under the filter the footer speaks the view alone")
    }

    /// THE BOOKCASE ROW (item 9.2): "5 notes · 2 archived" — the held member
    /// count less the archived — and NOTHING with details off (§23).
    @Test func theBookcaseRowSaysTheArchivedAndDetailsOffHidesIt() throws {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        let book = Reading(
            id: "b", name: "Kept", kind: .book, sortField: .manual, sortDir: .asc,
            createdAt: now, updatedAt: now)
        let row = Queries.ShelfBook(reading: book, postCount: 7, sectionCount: 2, arrivalCount: 1)
        let on = try #require(BookcaseRowMeta.drawn(
            row, detailsShown: true, words: nil, progress: nil, gatheringCount: nil, archived: 2))
        #expect(on.facts.hasPrefix("5 notes · 2 archived · 2 ch"), "got: \(on.facts)")
        #expect(on.arrivals == "1 arrival")
        #expect(BookcaseRowMeta.drawn(
            row, detailsShown: false, words: nil, progress: nil, gatheringCount: nil,
            archived: 2) == nil, "details off hides the meta AND the arrivals count (§23)")
        // Nothing archived — the shipped words exactly.
        #expect(BookcaseRowMeta.facts(row, words: nil, progress: nil, gatheringCount: nil)
                .hasPrefix("7 notes · 2 ch"))
        // A gathering holds nothing archived to say.
        let gathering = Reading(
            id: "g", name: "G", kind: .gathering, sortField: .manual, sortDir: .asc,
            createdAt: now, updatedAt: now)
        let gRow = Queries.ShelfBook(reading: gathering, postCount: 0, sectionCount: 0)
        #expect(!BookcaseRowMeta.facts(
            gRow, words: nil, progress: nil, gatheringCount: 3, archived: 2).contains("archived"))
    }

    // MARK: - The line, mounted

    @Test func theLineIsAbsentWhenNothingIsSetAside() async throws {
        ArchivedLineProbe.reset()
        try await withArchiveBook(members: 3, archive: 0) { session, db, readingID, _ in
            for mode: BookStructureModel.ViewMode in [.index, .outline, .spread] {
                let hosted = try await mounted(
                    session: session, db: db, readingID: readingID, mode: mode)
                defer {
                    hosted.window.orderOut(nil)
                    hosted.window.close()
                }
                await settle(hosted.window, hosted.hosting)
                #expect(hosted.archived.door == .none)
                #expect(ArchivedLineProbe.drawn[readingID] == nil,
                        "\(mode): nothing set aside, so nothing draws — not a line, not a hairline")
            }
        }
    }

    @Test func theLineStandsOnTheArrivalsHostsAndNotOnRead() async throws {
        ArchivedLineProbe.reset()
        try await withArchiveBook(members: 4, archive: 2) { session, db, readingID, _ in
            let hosted = try await mounted(
                session: session, db: db, readingID: readingID, mode: .index)
            defer {
                hosted.window.orderOut(nil)
                hosted.window.close()
            }
            await settle(hosted.window, hosted.hosting) {
                ArchivedLineProbe.drawn[readingID]?.line != nil
            }
            let onIndex = try #require(ArchivedLineProbe.drawn[readingID])
            #expect(onIndex.line == "2 archived")
            #expect(onIndex.expanded == false, "collapsed by default — one quiet line")
            #expect(onIndex.rows.isEmpty)

            for mode: BookStructureModel.ViewMode in [.spread, .outline] {
                hosted.structure.mode = mode
                await settle(hosted.window, hosted.hosting, maxTurns: 12)
                #expect(ArchivedLineProbe.drawn[readingID]?.line == "2 archived",
                        "\(mode) carries the line")
            }
            hosted.structure.mode = .read
            await settle(hosted.window, hosted.hosting, maxTurns: 12)
            #expect(ArchivedLineProbe.drawn[readingID] == nil, "Read stays a place to read")
        }
    }

    @Test func theLineExpandsToTheMembersWithTheirTwoDoors() async throws {
        for owned in [false, true] {
            ArchivedLineProbe.reset()
            try await withArchiveBook(members: 3, archive: 2, owned: owned) {
                session, db, readingID, memberIDs in
                let hosted = try await mounted(
                    session: session, db: db, readingID: readingID, mode: .index)
                defer {
                    hosted.window.orderOut(nil)
                    hosted.window.close()
                }
                await settle(hosted.window, hosted.hosting)
                hosted.archived.toggle()
                try await refresh(hosted.archived, db)
                await settle(hosted.window, hosted.hosting) {
                    ArchivedLineProbe.drawn[readingID]?.rows.count == 2
                }
                let drawn = try #require(ArchivedLineProbe.drawn[readingID])
                #expect(drawn.expanded)
                #expect(hosted.archived.door.rows.map(\.postID)
                        == Array(memberIDs.suffix(2).reversed()), "newest-archived first")
                let doors = owned ? ["Unarchive", "Release"] : ["Unarchive", "Remove"]
                #expect(Set(drawn.rows.values.map { $0 }) == [doors],
                        "owned \(owned): every row draws \(doors)")

                hosted.archived.toggle()
                await settle(hosted.window, hosted.hosting) {
                    ArchivedLineProbe.drawn[readingID]?.rows.isEmpty == true
                }
                #expect(ArchivedLineProbe.drawn[readingID]?.expanded == false, "folds back")
            }
        }
    }

    // MARK: - The acts

    /// **Ladder A round 1, MINOR 1 — U4's refinement (GENUINELY RED ON OLD
    /// — run on the pre-guard model first):** a cancelled loop's late
    /// delivery — the COLLAPSED observation's count-only value landing after
    /// the expanded loop's first rows (the `.task(id: expanded)` restart) —
    /// never blanks the expansion. Before the guard it left "▾ N archived"
    /// with ZERO rows, standing until a write touched
    /// reading/reading_post/container or she folded and reopened.
    @Test func aCancelledLoopsLateDeliveryNeverBlanksTheExpandedRows() async throws {
        try await withArchiveBook(members: 1, archive: 1) { session, db, readingID, _ in
            let line = BookArchivedModel(session: session, readingID: readingID)
            try await refresh(line, db)
            line.toggle()
            try await refresh(line, db)
            let rows = line.door.rows
            #expect(rows.count == 1)
            // The collapsed loop's value lands on a CANCELLED task —
            // deterministic: the body cannot run before this MainActor test
            // suspends, and cancel() lands first.
            let late = Task { @MainActor in
                line.adopt(.init(count: 1, rows: []))
            }
            late.cancel()
            _ = await late.value
            #expect(line.door.rows == rows, "the expanded rows stand")
            #expect(line.expanded, "still open")
        }
    }

    @Test func unarchiveBringsTheNoteBackIntoTheBook() async throws {
        try await withArchiveBook(members: 3, archive: 1) { session, db, readingID, memberIDs in
            let line = BookArchivedModel(session: session, readingID: readingID)
            line.toggle()  // no-op while empty
            try await refresh(line, db)
            line.toggle()
            try await refresh(line, db)
            let member = try #require(line.door.rows.first)
            #expect(member.postID == memberIDs[2])

            await line.unarchive(member)

            #expect(session.status.spoken?.text == ArchivedLineCopy.unarchived("member 2"))
            #expect(try await db.read { try Container.fetchOne($0, key: memberIDs[2]) }?
                .archivedAt == nil)
            #expect(try await db.read { try Queries.assembleReading($0, readingID: readingID) }
                .map(\.postID) == memberIDs, "back in the book's order")
            try await refresh(line, db)
            #expect(line.door == .none)
            #expect(line.expanded == false, "the emptied line folds shut")
        }
    }

    @Test func removeTakesItOutAndSaysItStaysArchived() async throws {
        for owned in [false, true] {
            try await withArchiveBook(members: 2, archive: 1, owned: owned) {
                session, db, readingID, memberIDs in
                let line = BookArchivedModel(session: session, readingID: readingID)
                line.toggle()
                try await refresh(line, db)
                line.toggle()
                try await refresh(line, db)
                let member = try #require(line.door.rows.first)

                await line.remove(member, book: try await reading(db, readingID))

                #expect(session.status.spoken?.text == RemoveFromBookCopy.receipt(
                    book: "the kept book", owned: owned, bookless: true, archived: true))
                #expect(try await db.read { db in
                    try Int.fetchOne(
                        db, sql: """
                            SELECT COUNT(*) FROM reading_post
                            WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL
                            """, arguments: [readingID, memberIDs[1]])
                } == 0, "the membership is gone")
                #expect(try await db.read { try Container.fetchOne($0, key: memberIDs[1]) }?
                    .archivedAt != nil, "the note itself stays archived")
                try await refresh(line, db)
                #expect(line.door == .none)
            }
        }
    }

    @Test func aFinishedBooksRemoveRefusesNamingItsRoadAndUnarchiveStillActs() async throws {
        try await withArchiveBook(members: 2, archive: 2, finished: true) {
            session, db, readingID, memberIDs in
            let line = BookArchivedModel(session: session, readingID: readingID)
            line.toggle()
            try await refresh(line, db)
            line.toggle()
            try await refresh(line, db)
            let rows = line.door.rows
            #expect(rows.count == 2)
            let book = try await reading(db, readingID)

            await line.remove(rows[0], book: book)
            #expect(session.status.spoken?.text == BookStateCopy.refusal(
                for: OperationError.lockedReading(id: readingID), name: book.name, sealed: false))
            #expect(try await db.read { try Queries.bookArchivedMembers(
                $0, readingID: readingID, limit: 0) }.count == 2, "nothing left the book")

            // Archive is the NOTE's state, not the assembly's — Unarchive acts.
            await line.unarchive(rows[1])
            #expect(try await db.read { try Container.fetchOne($0, key: rows[1].postID) }?
                .archivedAt == nil)
            _ = memberIDs
        }
    }

    /// Item 9.5 — THE INDEX NEVER SHOWS AN ARCHIVED MEMBER: the mounted Index
    /// holds the working members only; the footer says the set-aside count.
    @Test func theIndexNeverShowsAnArchivedMember() async throws {
        try await withArchiveBook(members: 4, archive: 2) { session, db, readingID, memberIDs in
            let hosted = try await mounted(
                session: session, db: db, readingID: readingID, mode: .index)
            defer {
                hosted.window.orderOut(nil)
                hosted.window.close()
            }
            await settle(hosted.window, hosted.hosting)
            #expect(hosted.model.entries.map(\.postID) == Array(memberIDs.prefix(2)),
                    "the Index lists the working members only")
            #expect(BookIndexColumn.footerWords(
                chapters: 0, notes: hosted.model.entries.count,
                filtered: hosted.model.viewFilter != nil,
                archived: hosted.archived.door.count) == "2 notes · 2 archived")
        }
    }

    // MARK: - An archived waiter (item 9.3 — P-13ib-U2-2 reversed)

    @Test func anArchivedWaiterIsMarkedKeepsItsDoorsAndAddSeatsItArchived() async throws {
        ArrivalsLineProbe.reset()
        ArchivedLineProbe.reset()
        try await withArchiveBook(members: 1, archive: 0) { session, db, readingID, _ in
            let ops = session.operations
            let inbox = try ops.createTag(name: "inbox")
            let inboxRule = try #require(try RuleGrammar.encode(.tag(inbox.id)))
            try ops.setReadingQuerySpec(
                readingID, querySpec: inboxRule)
            try ops.setReadingIntakeSeating(readingID, .arrivals)
            let note = try ops.createPost(title: "set aside")
            _ = try ops.newBlock(in: note.id, text: "A waiting note.")
            _ = try ops.applyTag(inbox.id, toPost: note.id)
            try ops.archiveContainer(note.id)

            let hosted = try await mounted(
                session: session, db: db, readingID: readingID, mode: .index)
            defer {
                hosted.window.orderOut(nil)
                hosted.window.close()
            }
            await settle(hosted.window, hosted.hosting)
            #expect(hosted.arrivals.door.count == 1, "the archived waiter is at Arrivals")
            hosted.arrivals.toggle()
            try await refresh(hosted.arrivals, db)
            // 17y B3 (h) — A JUSTIFIED EDIT: the rows are the masthead door's
            // popover content (`BookArrivalsList`), mounted on their own here
            // (a popover does not render under the test host); the subject —
            // the archived waiter's mark and doors — is unchanged.
            let rowsWindow = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 640, height: 400),
                styleMask: [.titled], backing: .buffered, defer: false)
            rowsWindow.isReleasedWhenClosed = false
            let rowsHost = NSHostingView(rootView: BookArrivalsList(
                model: hosted.arrivals, structure: hosted.structure))
            rowsHost.frame = NSRect(x: 0, y: 0, width: 640, height: 400)
            rowsWindow.contentView = rowsHost
            rowsWindow.makeKeyAndOrderFront(nil)
            defer {
                rowsWindow.orderOut(nil)
                rowsWindow.close()
            }
            await settle(rowsWindow, rowsHost) {
                ArrivalsLineProbe.drawn[readingID]?.rows.isEmpty == false
            }
            let row = try #require(hosted.arrivals.door.rows.first)
            #expect(row.archived)
            let drawn = try #require(ArrivalsLineProbe.drawn[readingID])
            #expect(drawn.archivedRows == [row.id], "the row wears the archived mark")
            #expect(drawn.rows[row.id] == ["Add", "Dismiss"], "the same doors")

            await hosted.arrivals.seat(
                row, book: hosted.structure.reading, chaptered: hosted.structure.chaptersActive)

            #expect(session.status.spoken?.text
                    == ArrivalsCopy.added("set aside", chaptered: false, archived: true))
            #expect(try await db.read { try ReadingPost.fetchOne($0, key: row.id) }?.status
                    == .member)
            try await refresh(hosted.archived, db)
            #expect(hosted.archived.door.count == 1, "it lands in the archived line")
        }
    }

    // MARK: - The declarations

    @Test func theLinesDoorsAreDeclared() {
        let unarchive = CapabilityRegistry.capability(.unarchiveNote)
        #expect(unarchive.verb == ArchivedLineCopy.unarchiveVerb)
        #expect(unarchive.doors == [.surface])
        #expect(unarchive.scope == .post)
        #expect(BookArchivedLine.surfaceCapabilities == [.unarchiveNote, .removeFromBook])
        #expect(CapabilityRegistry.capability(.removeFromBook).doors.contains(.surface))
    }
}
