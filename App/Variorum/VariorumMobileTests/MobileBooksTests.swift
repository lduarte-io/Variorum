//
//  MobileBooksTests.swift
//  VariorumMobileTests
//
//  Parity round Stage C, batch C2 — the books & membership family's
//  shelf-side suite: pin/unpin (the [B1] record's deferred ACT), create
//  book (her feel-round finding + the LK5 expansion's
//  smart-book-from-tags). State-transition tests through the view
//  models against a real in-memory store (the standing discipline);
//  every act routes through existing core operations.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile books — pin/unpin (parity C2)")
struct MobileBookPinTests {
    /// The pin ACT lands as pin-order state and the shelf order follows
    /// (R38's semantics through the core's own `setShelfPinned`); unpin
    /// reverses it exactly. The door's state-mirroring words are pinned
    /// beside the act (the Mac shelf menu's own vocabulary).
    @Test func pinAndUnpinReorderTheShelf() async throws {
        try await withEditorWorld { session, db in
            let (aster, zebra) = try await session.runner.run { ops -> (String, String) in
                (try ops.createReading(name: "Aster", kind: .curated).id,
                 try ops.createReading(name: "Zebra", kind: .curated).id)
            }
            let model = MobileShelfViewModel(session: session)
            let observation = Task { await model.start() }
            defer { observation.cancel() }
            await settle { model.books.count == 2 }
            #expect(model.orderedBooks.map(\.reading.id) == [aster, zebra],
                    "unpinned books order by name")

            await model.setPinned(zebra, pinned: true)
            await settle { model.pins == [zebra] }
            #expect(model.orderedBooks.map(\.reading.id) == [zebra, aster],
                    "the pinned book leads in pin order")
            #expect(try await db.read { db in
                try Queries.shelfPins(db)
            } == [zebra], "the pin is store truth, not view state")

            await model.setPinned(zebra, pinned: false)
            await settle { model.pins.isEmpty }
            #expect(model.orderedBooks.map(\.reading.id) == [aster, zebra],
                    "unpin restores the name order")
            #expect(model.lastError == nil)

            #expect(MobileShelfFaces.pinDoorTitle(pinned: false) == "Pin to Shelf Top")
            #expect(MobileShelfFaces.pinDoorTitle(pinned: true) == "Unpin from Shelf Top")
        }
    }
}

@MainActor
@Suite("Mobile books — create & smart-from-tags (parity C2)")
struct MobileBookCreateTests {
    /// The three kinds mint EXACTLY the Mac create alert's rows: a plain
    /// book (curated, manual asc, no profile), a journal book (curated,
    /// profile 'journal', entry-date asc — the dated-order shape,
    /// byte-mirrored), and nothing else is written.
    @Test func createBookMintsTheThreeKindsExactly() async throws {
        try await withEditorWorld { session, db in
            let model = MobileCreateBookModel(session: session)

            model.name = "  Essays "
            model.kind = .notes
            let essays = try #require(await model.create())
            let essaysRow = try #require(await db.read { db in
                try Queries.reading(db, id: essays)
            })
            #expect(essaysRow.name == "Essays", "the name lands trimmed")
            #expect(essaysRow.kind == .curated)
            #expect(essaysRow.profile == nil)
            #expect(essaysRow.sortField == .manual)
            #expect(essaysRow.sortDir == .asc)
            #expect(essaysRow.querySpec == nil)

            model.name = "Mornings"
            model.kind = .journal
            let journal = try #require(await model.create())
            let journalRow = try #require(await db.read { db in
                try Queries.reading(db, id: journal)
            })
            #expect(journalRow.kind == .curated)
            #expect(journalRow.profile == "journal")
            #expect(journalRow.sortField == .entryDate)
            #expect(journalRow.sortDir == .asc)
            #expect(model.lastError == nil)
        }
    }

    /// The LK5 expansion's road end-to-end: a smart book created FROM
    /// tags carries the Mac PromoteTagsSheet's exact spec construction
    /// (OR → `tags`, AND → `tagsAll`, canonical sorted-keys JSON) and its
    /// assembly COLLECTS a tagged note immediately — the tags stay on the
    /// note (R37: nothing about creation touches applications).
    @Test func createSmartBookFromTagsBuildsTheSpecAndCollects() async throws {
        try await withEditorWorld { session, db in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "Harbor notes")
                let tag = try ops.createTag(name: "sea")
                _ = try ops.createTag(name: "sky")
                _ = try ops.applyTag(tag.id, toPost: post.id)
                return post.id
            }
            let model = MobileCreateBookModel(session: session)
            await model.loadTags()
            #expect(model.tags.map(\.path) == ["sea", "sky"], "the picker lists the taxonomy")

            model.name = "By the Water"
            model.kind = .smartFromTags
            model.selectedTagPaths = ["sea"]
            let bookID = try #require(await model.create())

            let row = try #require(await db.read { db in try Queries.reading(db, id: bookID) })
            #expect(row.kind == .smart)
            #expect(row.querySpec == #"{"tags":["sea"]}"#, "the OR spec, canonical JSON")
            let assembled = try await db.read { db in
                try Queries.assembleReading(db, readingID: bookID)
            }
            #expect(assembled.map(\.postID) == [postID], "the smart book collects at once")
            let stillTagged = try await db.read { db in
                try Queries.postTags(db, postID: postID)
            }
            #expect(stillTagged.map(\.path) == ["sea"], "the tags stay on the note")

            // The AND join is the spec brain's other arm (pure, pinned).
            #expect(try MobileCreateBookModel.spec(
                paths: ["a", "b"], joinAll: true).encodedJSON()
                == #"{"tagsAll":["a","b"]}"#)
            #expect(try MobileCreateBookModel.spec(
                paths: ["a", "b"], joinAll: false).encodedJSON()
                == #"{"tags":["a","b"]}"#)
        }
    }

    /// The face's gate, pure: no nameless book (the K1 doctrine — no
    /// literal placeholder mints), no tagless smart book (an empty spec
    /// would collect everything with no editor to fix it here).
    @Test func theCreateFaceGates() throws {
        typealias M = MobileCreateBookModel
        #expect(!M.canCreate(name: "", kind: .notes, selectedTagCount: 0))
        #expect(!M.canCreate(name: "   ", kind: .journal, selectedTagCount: 0))
        #expect(M.canCreate(name: "A", kind: .notes, selectedTagCount: 0))
        #expect(M.canCreate(name: "A", kind: .journal, selectedTagCount: 0))
        #expect(!M.canCreate(name: "A", kind: .smartFromTags, selectedTagCount: 0))
        #expect(M.canCreate(name: "A", kind: .smartFromTags, selectedTagCount: 1))
    }
}

@MainActor
@Suite("Mobile book details (parity C2 — the fork's ruled surface)")
struct MobileBookDetailsTests {
    /// Finish / reopen flips `reading.locked` both ways through the core
    /// ops, and the identity block follows the ONE faces brain (the ✓
    /// state on the name — never a meta stat). Dissolves inventory #8.
    @Test func finishAndReopenFlipTheStateAndTheFaces() async throws {
        try await withEditorWorld { session, db in
            let bookID = try await session.runner.run { ops in
                try ops.createReading(name: "Poems", kind: .curated)
            }.id
            let model = MobileBookDetailsModel(session: session, readingID: bookID)
            await model.refresh()
            #expect(model.nameLine == "Poems")

            await model.setFinished(true)
            #expect(try await db.read { db in
                try Bool.fetchOne(
                    db, sql: "SELECT locked FROM reading WHERE id = ?", arguments: [bookID])
            } == true)
            #expect(model.nameLine == "Poems ✓", "the finished state rides the name")
            #expect(model.lastError == nil)

            await model.setFinished(false)
            #expect(try await db.read { db in
                try Bool.fetchOne(
                    db, sql: "SELECT locked FROM reading WHERE id = ?", arguments: [bookID])
            } == false)
            #expect(model.nameLine == "Poems", "reopen restores exactly — a reversible guard")
        }
    }

    /// Rename trims, refuses blank at the face, and stays FREE on a
    /// finished book (the Mac's renameReading has no lock guard — the
    /// rename-stays-free-under-lock parallel, pinned).
    @Test func renameTrimsGatesBlankAndWorksOnAFinishedBook() async throws {
        try await withEditorWorld { session, db in
            let bookID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(name: "Old", kind: .curated)
                try ops.lockReading(book.id)
                return book.id
            }
            let model = MobileBookDetailsModel(session: session, readingID: bookID)
            await model.refresh()

            await model.rename("  New Name ")
            #expect(try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT name FROM reading WHERE id = ?", arguments: [bookID])
            } == "New Name", "trimmed, and free under the finish lock")
            #expect(model.lastError == nil)
            #expect(model.nameLine == "New Name ✓")

            await model.rename("   ")
            #expect(try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT name FROM reading WHERE id = ?", arguments: [bookID])
            } == "New Name", "a blank name never lands — the face gates")
            #expect(!MobileBookDetailsModel.canRename("   "))
            #expect(MobileBookDetailsModel.canRename("A"))
        }
    }

    /// The daily-designation road end-to-end (dissolves inventory #10 and
    /// gives #9 its road): a smart daily book makes the Today door speak;
    /// designating a curated journal from details makes the next Today
    /// shelve silently. The door's render rule is the Mac's own (curated
    /// + journal profile — P-2), pinned pure.
    @Test func designateDailyIsTheRoadOutOfTheTodayRefusals() async throws {
        try await withEditorWorld { session, db in
            let (_, journalID) = try await session.runner.run { ops -> (String, String) in
                let smart = try ops.createReading(
                    name: "Everything", kind: .smart, querySpec: #"{"tags":["x"]}"#)
                try ops.setDailyJournalBook(smart.id)
                let journal = try ops.createReading(
                    name: "Mornings", kind: .curated, profile: "journal",
                    sortField: .entryDate, sortDir: .asc)
                return (smart.id, journal.id)
            }
            let shelf = MobileShelfViewModel(session: session)
            _ = await shelf.openToday(day: "2026-08-09")
            #expect(shelf.lastReport?.contains("smart") == true,
                    "the smart daily book speaks")
            #expect(shelf.lastReport?.contains("Mac") == false,
                    "…and names a phone road, never the Mac")

            let details = MobileBookDetailsModel(session: session, readingID: journalID)
            await details.refresh()
            #expect(!details.isDaily)
            await details.designateDaily()
            #expect(details.isDaily)
            #expect(try await db.read { db in
                try Queries.dailyJournalBookID(db)
            } == journalID)

            let again = await shelf.openToday(day: "2026-08-09")
            #expect(again != nil)
            #expect(try await db.read { db in
                try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                    arguments: [journalID])
            } == 1, "the day's entry shelves into the new daily book")

            // The render rule, pure (P-2): curated journal only.
            func reading(_ kind: ReadingKind, _ profile: String?) -> Reading {
                Reading(
                    id: "r", ownerId: nil, name: "R", kind: kind, profile: profile,
                    sortField: .manual, sortDir: .asc, groupingTagId: nil,
                    querySpec: nil, maxPosts: nil, wordTarget: nil, locked: false,
                    createdAt: Date(), updatedAt: Date(), deletedAt: nil, syncVersion: 0)
            }
            #expect(MobileBookDetailsModel.showsDailyDoor(reading(.curated, "journal")))
            #expect(!MobileBookDetailsModel.showsDailyDoor(reading(.curated, nil)))
            #expect(!MobileBookDetailsModel.showsDailyDoor(reading(.smart, "journal")))
        }
    }

    /// The identity block DISPLAYS tags for both kinds from the shelf
    /// faces' one source (the ruled (B) reading: nothing tag-editable
    /// ships here — a curated book's tags are derived from member notes
    /// by model fact; smart-filter editing waits for the Mac's book
    /// redefinition). The door's word is pinned.
    @Test func theIdentityBlockDisplaysTagsForBothKinds() async throws {
        try await withEditorWorld { session, db in
            let (curatedID, smartID) = try await session.runner.run { ops -> (String, String) in
                let curated = try ops.createReading(name: "Essays", kind: .curated)
                let post = try ops.createPost(title: "Tagged")
                _ = try ops.addPostToReading(post.id, to: curated.id)
                let tag = try ops.createTag(name: "sea")
                _ = try ops.applyTag(tag.id, toPost: post.id)
                let smart = try ops.createReading(
                    name: "By Water", kind: .smart, querySpec: #"{"tags":["sea"]}"#)
                return (curated.id, smart.id)
            }
            let curated = MobileBookDetailsModel(session: session, readingID: curatedID)
            await curated.refresh()
            #expect(curated.tagPaths == ["sea"], "curated tags derive from member notes")
            #expect(curated.metaLine == "1 note · #sea")

            let smart = MobileBookDetailsModel(session: session, readingID: smartID)
            await smart.refresh()
            #expect(smart.tagPaths == ["sea"], "a smart book's tags are its own spec")
            #expect(smart.metaLine == "smart · #sea")

            #expect(MobileBookView.detailsDoorTitle == "Details")
        }
    }
}

/// The suites' shared settle helper (the MobileShellTests polling shape).
@MainActor
func settle(
    attempts: Int = 2000, _ done: @MainActor () -> Bool
) async {
    for _ in 0..<attempts where !done() {
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(1))
    }
}
