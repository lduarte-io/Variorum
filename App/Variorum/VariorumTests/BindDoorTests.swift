//
//  BindDoorTests.swift
//  VariorumTests
//
//  13i-b U3 — the two strengthening doors (the plan §4 item 2; the sitting
//  record §3, §14.6, §19.6) and F-U2-3's pin.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

@MainActor
private func withBindWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// A gathering on `#door` with `count` tagged notes.
@MainActor
private func gathering(
    _ session: AppSession, name: String = "the door", count: Int
) throws -> (reading: Reading, posts: [Container], tag: VariorumCore.Tag) {
    let ops = session.operations
    let tag = try ops.createTag(name: "door")
    let reading = try ops.createReading(
        name: name, kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
    var posts: [Container] = []
    for i in 0..<count {
        let post = try ops.createPost(title: "door \(i)")
        _ = try ops.applyTag(tag.id, toPost: post.id)
        posts.append(post)
    }
    return (reading, posts, tag)
}

private func pump(_ seconds: TimeInterval = 0.2) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

/// Pump and yield until `condition` holds — bounded, so silence fails
/// rather than hangs.
@MainActor
private func settle(until condition: () -> Bool) async {
    for _ in 0..<40 where !condition() {
        pump(0.05)
        for _ in 0..<10 { await Task.yield() }
    }
}

@MainActor
@Suite("The bind + spawn doors (13i-b U3)", .serialized)
struct BindDoorTests {
    /// **F-U2-3 — the shelf's bind sheet promised "Its current 0 notes" for
    /// a gathering showing 2** (U2's walk, observed live; the conversion then
    /// kept 2). The COUNT was right — `SmartConversionCount.collected` is
    /// pinned at 3 of 3 (`BookOrderConversionTests`) — so the fault was the
    /// door's PLUMBING. The traced mechanism: the door set a separate
    /// `@State` count and then the sheet's item, and the sheet read the count
    /// inside its content closure; nothing in the shelf's body READ that
    /// count, so no re-render captured its new value, and the closure ran on
    /// a view value whose `@State` snapshot still held the old number (0 on
    /// a first open). The fix carries the count IN the sheet's item.
    ///
    /// Driven through the REAL shelf: the door's own function (the one the
    /// menu item calls), reached through a DEBUG hook because the shelf's
    /// `@State` is unreachable from outside, and the sheet's promise read
    /// from what the presented sheet recorded on appear.
    @Test func theShelfsBindSheetPromisesTheCountTheGatheringShows() async throws {
        try await withBindWorld { session, _ in
            let (reading, _, _) = try gathering(session, count: 2)
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 900, height: 600),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.attachedSheet.map { window.endSheet($0) }
                window.orderOut(nil)
                window.close()
            }
            BindDoorProbe.shown = nil
            BindDoorProbe.openShelfDoor = nil
            window.contentView = NSHostingView(rootView: ShelfView(
                session: session,
                model: ShelfViewModel(session: session),
                readings: ReadingsViewModel(session: session),
                onOpen: { _ in }, onTodaysEntry: {}))
            window.orderFrontRegardless()
            await settle(until: { BindDoorProbe.openShelfDoor != nil })
            let open = try #require(BindDoorProbe.openShelfDoor, "the shelf mounted its door")

            open(reading)
            await settle(until: { BindDoorProbe.shown != nil })

            let shown = try #require(BindDoorProbe.shown, "the bind sheet presented")
            #expect(shown.readingID == reading.id)
            #expect(shown.count == 2, "the sheet promises the 2 notes the gathering shows")

            // …and the presented sheet tells the RULED truth (F-1): it keeps
            // collecting; nothing stops arriving; no "(collecting)" sibling.
            #expect(shown.title == "Bind \u{201C}the door\u{201D} into a book?")
            #expect(shown.body.contains(BindCopy.keepsCollecting))
            #expect(shown.body.contains("the 2 notes it shows become members"))
            #expect(!shown.body.contains("stop arriving"), "F-1's false sentence is gone")
            #expect(!shown.body.localizedCaseInsensitiveContains("(collecting)"))
            #expect(shown.confirm == "Bind into a Book")
        }
    }

    // MARK: - The bind sheet's words (pure)

    @Test func theBindWordsSayTheTruthAtEveryCount() {
        let none = BindCopy.explanation(count: 0, followUp: .none)
        #expect(none.contains("it shows no notes right now, so the book starts empty"))
        let one = BindCopy.explanation(count: 1, followUp: .none)
        #expect(one.contains("the 1 note it shows becomes a member"))
        let chapter = BindCopy.explanation(count: 3, followUp: .createChapter)
        #expect(chapter.hasPrefix("Chapters need a book that holds its notes"))
        #expect(chapter.contains("the 3 notes it shows become members"))
        for text in [none, one, chapter] {
            // Lesson 3's truth (the sitting record §25): "bind it into a book
            // to take it in hand, and it keeps collecting after you do".
            #expect(text.contains("keeps collecting after you bind it"))
            #expect(!text.contains("stop"))
        }
        #expect(BindCopy.confirm(.createChapter) == "Bind & Add Chapter")
        #expect(BindCopy.title("x", followUp: .createChapter)
                == "Bind \u{201C}x\u{201D} into a book to add chapters?")
        // The teaching offer — the sitting record §3, verbatim.
        #expect(BindCopy.teachingOffer == "Turn into a book to arrange by hand?")
    }

    // MARK: - Binding preserves identity, and it keeps collecting

    /// §19.6, ratified §20: the gathering's row IS the book's row — through
    /// the SHELF'S door. And §14.6: the bound book keeps collecting (a fresh
    /// tagging act seats at the end).
    @Test func bindingThroughTheShelfKeepsTheRowAndKeepsCollecting() async throws {
        try await withBindWorld { session, db in
            let (reading, posts, tag) = try gathering(session, count: 2)
            try session.operations.setShelfPinned(reading.id, pinned: true)
            try session.operations.setStarred(.reading(reading.id), starred: true)
            let shelf = ShelfViewModel(session: session)

            await shelf.bind(reading.id)

            #expect(shelf.lastError == nil)
            let row = try #require(try await db.read { try Queries.reading($0, id: reading.id) })
            #expect(row.id == reading.id)
            #expect(row.name == "the door")
            #expect(row.kind == .book)
            #expect(row.starred, "the row's star survives")
            #expect(try await db.read { try Queries.starred($0) }
                .contains { $0.target == .reading(reading.id) }, "the sidebar star too")
            #expect(row.querySpec == reading.querySpec, "the rule rides the row")
            #expect(try await db.read { try Queries.readings($0) }.map(\.id) == [reading.id],
                    "one row — no sibling")
            #expect(try await db.read { try Queries.assembleReading($0, readingID: reading.id) }
                .map(\.postID) == posts.map(\.id))

            // It keeps collecting: a fresh tagging act seats at the END.
            let later = try session.operations.createPost(title: "later")
            _ = try session.operations.applyTag(tag.id, toPost: later.id)
            #expect(try await db.read { try Queries.assembleReading($0, readingID: reading.id) }
                .map(\.postID) == posts.map(\.id) + [later.id])
        }
    }

    // MARK: - The spawn

    @Test func theSpawnSeedsASiblingBookAndTheGatheringStaysAsItIs() async throws {
        try await withBindWorld { session, db in
            let (source, posts, tag) = try gathering(session, count: 2)
            let shelf = ShelfViewModel(session: session)

            let made = await shelf.spawnBook(from: source.id, named: "the door (book)")

            let bookID = try #require(made)
            #expect(shelf.lastError == nil)
            #expect(shelf.lastReport == BindCopy.spawned("the door (book)", count: 2))
            let book = try #require(try await db.read { try Queries.reading($0, id: bookID) })
            #expect(book.kind == .book)
            #expect(book.querySpec == source.querySpec, "the rule copied")
            #expect(book.wingId == source.wingId)
            // HER MORNING RULING (2026-10-01, P-13ib-3 OVERRULED: "the
            // spawn isn't adding the auto tag? it should") — an HONEST
            // TEST EDIT: a one-tag rule's sole tag becomes the outflow.
            #expect(book.autoTagId == tag.id, "the sole rule tag is the auto-tag")
            #expect(book.intakeSeating == nil, "intake on, joining quietly (nil reads AUTO)")
            // Creation-time BACKFILL seated the current matches as MEMBERS.
            let rows = try await db.read { db in
                try ReadingPost.fetchAll(
                    db, sql: "SELECT * FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                    arguments: [bookID])
            }
            #expect(Set(rows.map(\.postId)) == Set(posts.map(\.id)))
            #expect(rows.allSatisfy { $0.status == .member })

            // The gathering survives untouched: still a gathering, holding nothing.
            let after = try #require(try await db.read { try Queries.reading($0, id: source.id) })
            #expect(after.kind == .gathering)
            #expect(after.querySpec == source.querySpec)
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ?",
                                 arguments: [source.id])
            } == 0)

            // And the sibling is a LIVING book: a fresh match joins it.
            let later = try session.operations.createPost(title: "later")
            _ = try session.operations.applyTag(tag.id, toPost: later.id)
            #expect(try await db.read { try Queries.assembleReading($0, readingID: bookID) }
                .map(\.postID).last == later.id)
        }
    }

    /// The ruling's AMBIGUOUS ARM (PROVISIONAL, her bundle): a rule naming
    /// SEVERAL tags (an OR fan) or none has no single honest outflow — the
    /// spawn leaves the auto-tag unset; and a rule whose sole tag is DEAD
    /// never becomes a silent no-op outflow.
    @Test func theSpawnLeavesTheAutoTagUnsetWhereNoSoleLiveTagExists() async throws {
        try await withBindWorld { session, db in
            let ops = session.operations
            let a = try ops.createTag(name: "a")
            let b = try ops.createTag(name: "b")
            let fan = try ops.createReading(
                name: "fan", kind: .gathering,
                querySpec: try RuleGrammar.encode(.or([.tag(a.id), .tag(b.id)])))
            let shelf = ShelfViewModel(session: session)
            let fanBook = try #require(await shelf.spawnBook(from: fan.id, named: "fan (book)"))
            #expect(try await db.read { try Queries.reading($0, id: fanBook)?.autoTagId } == nil,
                    "an OR fan has no single honest outflow")

            let dead = try ops.createTag(name: "dead")
            let deadRule = try ops.createReading(
                name: "gone", kind: .gathering,
                querySpec: try RuleGrammar.encode(.tag(dead.id)))
            try ops.deleteTag(dead.id)
            let deadBook = try #require(await shelf.spawnBook(from: deadRule.id, named: "gone (book)"))
            #expect(try await db.read { try Queries.reading($0, id: deadBook)?.autoTagId } == nil,
                    "a dead sole tag never becomes a silent outflow")
        }
    }

    // MARK: - The teaching moment

    private func structure(
        _ session: AppSession, for reading: Reading, db: AppDatabase
    ) async throws -> BookStructureModel {
        let structure = BookStructureModel(session: session, readingID: reading.id)
        structure.adopt(.init(
            reading: try await db.read { try Queries.reading($0, id: reading.id) },
            sections: [], deletedSections: [], assignments: [:]))
        return structure
    }

    /// The sitting record §3: "A hand-drag inside one is the teaching moment:
    /// 'Turn into a book to arrange by hand?'" — an OFFER on the one status
    /// seam (18i: offers always show), whose act opens the bind's confirm
    /// with its count. The drag itself writes nothing. Before U3 the same
    /// drag reached `assignPostToSection` and came back as "That note isn't
    /// in this book."
    @Test func aHandDragInAGatheringOffersTheBindAndItsActOpensTheConfirm() async throws {
        try await withBindWorld { session, db in
            let (reading, posts, _) = try gathering(session, count: 2)
            let structure = try await structure(session, for: reading, db: db)
            let entries = try await db.read { try Queries.assembleReading($0, readingID: reading.id) }

            let accepted = structure.acceptDrop(
                [BookStructureModel.BookDrag.post(posts[1].id).payload],
                chapter: .post(posts[0].id), post: .post(posts[0].id),
                entries: entries, viewOrder: nil)

            #expect(accepted)
            let said = try #require(session.status.current)
            #expect(said.kind == .offer)
            #expect(said.text == BindCopy.teachingOffer)
            #expect(said.action?.label == BindCopy.teachingAction)
            #expect(structure.lastError == nil, "no 'isn't in this book' dead end")
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading_post")
            } == 0, "the drag itself writes nothing")

            // The offer's act IS the bind confirm — with the count.
            said.action?.perform()
            await settle(until: { structure.bindOffer != nil })
            let offer = try #require(structure.bindOffer)
            #expect(offer.reading.id == reading.id)
            #expect(offer.count == 2)
            #expect(offer.followUp == .none)
        }
    }

    @Test func aHandDragInABookFilesAsAlwaysAndOffersNothing() async throws {
        try await withBindWorld { session, db in
            let book = try session.operations.createReading(name: "book", kind: .book)
            let a = try session.operations.createPost(title: "a")
            let b = try session.operations.createPost(title: "b")
            try session.operations.addPostToReading(a.id, to: book.id)
            try session.operations.addPostToReading(b.id, to: book.id)
            let structure = try await structure(session, for: book, db: db)
            let entries = try await db.read { try Queries.assembleReading($0, readingID: book.id) }

            structure.acceptDrop(
                [BookStructureModel.BookDrag.post(b.id).payload],
                chapter: .post(a.id), post: .post(a.id), entries: entries, viewOrder: nil)
            await settle(until: { false })

            #expect(session.status.current?.text != BindCopy.teachingOffer)
            #expect(try await db.read { try Queries.assembleReading($0, readingID: book.id) }
                .map(\.postID) == [b.id, a.id], "the drag reordered the book")
        }
    }

    @Test func aFinishedGatheringHearsTheRefusalNotAnOfferThatCanOnlyFail() async throws {
        try await withBindWorld { session, db in
            let (reading, posts, _) = try gathering(session, count: 2)
            try session.operations.lockReading(reading.id)
            let structure = try await structure(session, for: reading, db: db)

            structure.acceptDrop(
                [BookStructureModel.BookDrag.post(posts[1].id).payload],
                chapter: .post(posts[0].id), post: .post(posts[0].id),
                entries: [], viewOrder: nil)

            let said = try #require(session.status.current)
            #expect(said.kind == .refusal)
            #expect(said.action == nil)
        }
    }

    /// The navigator's "+ new chapter" on a gathering opens the SAME confirm,
    /// its follow-up named and its count carried (F-U2-3's fix shape, on the
    /// book view's road).
    @Test func theChapterDoorOpensTheBindWithItsCountAndItsFollowUp() async throws {
        try await withBindWorld { session, db in
            let (reading, _, _) = try gathering(session, count: 3)
            let structure = try await structure(session, for: reading, db: db)
            let looking = Queries.ReadingOrder(field: .createdAt, direction: .desc)

            await structure.openBindOffer(followUp: .createChapter, order: looking)

            let offer = try #require(structure.bindOffer)
            #expect(offer.count == 3)
            #expect(offer.followUp == .createChapter)
            #expect(offer.order == looking, "the bind will freeze the order she is looking through")

            // Binding through it: the same row, the order she was looking at.
            #expect(await structure.bind(order: offer.order))
            #expect(try await db.read { try Queries.reading($0, id: reading.id)?.kind } == .book)
        }
    }
}
