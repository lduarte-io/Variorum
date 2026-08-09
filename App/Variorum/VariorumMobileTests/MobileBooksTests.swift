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
