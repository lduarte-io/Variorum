//
//  MobileDeletionTests.swift
//  VariorumMobileTests
//
//  **PR1 · PR4 · PR7 — round 2, batch 4.** The parity inventory's headline,
//  verified by its own sweep and now closed: *the phone cannot delete a
//  note, and nothing it deletes can ever come back.* `deleteContainer` and
//  `deleteReading` each appeared in `VariorumMobile/` exactly ONCE, inside
//  the tutorial seeder's cleanup.
//
//  Every door here is pinned twice over: the ACT against store rows, and
//  the DOOR by mounting the real surface and activating the real control
//  (§15's trap (b) — `MobileSurfaceDriver` carries what was measured about
//  what can and cannot be driven in process).
//
//  Red-on-old is structural for all of it: none of these doors existed, so
//  every `activate` returns false on the pre-batch code and every store
//  assertion fails.
//

import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
private func liveContainerCount(_ db: AppDatabase) async throws -> Int {
    try await db.read { db in
        try Int.fetchOne(
            db,
            sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL")
            ?? -1
    }
}

@MainActor
private func isTombstoned(_ db: AppDatabase, table: String, id: String) async throws -> Bool {
    try await db.read { db in
        try String.fetchOne(
            db, sql: "SELECT deleted_at FROM \(table) WHERE id = ?", arguments: [id]) != nil
    }
}

@MainActor
@Suite("Mobile deletion — PR1 delete a note, PR4 delete a book")
struct MobileDeletionTests {
    // MARK: - PR1 · Delete a note

    /// **The act.** `deleteNote` tombstones the note, the receipt names the
    /// Trash and its clock, and the core Trash listing can now show a
    /// `.note` row — a case the phone could never populate before.
    @Test func deletingANoteMovesItToTheTrashAndSaysSo() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Something written."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)

            #expect(await model.deleteNote())
            #expect(try await isTombstoned(db, table: "container", id: postID))
            #expect(model.statusMessage == RecoveryCopy.movedToTrashReceipt(.note))
            #expect(model.statusMessage.map { $0.contains("30 days") } == true)

            let trash = try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now)
            }
            #expect(trash.contains { $0.kind == .note && $0.id == postID })
        }
    }

    /// **The DOOR, driven.** Open the real ⋯ sheet from the real masthead,
    /// find the real "Delete Note…" row, activate it — and the confirm
    /// really presents, with the shared wording that names the Trash, the
    /// window, and the way back.
    ///
    /// This is the pin shape the Mac's dead purge doors never had: it is
    /// not the model's `pendingDelete` flag, it is a `UIAlertController` in
    /// a window.
    @Test func theNoteActionsDeleteRowPresentsTheRealConfirm() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Something written."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)

            try await withHostedSurface(
                MobileWriteScreen(session: session, postID: postID, editor: model)
            ) { surface in
                #expect(surface.activate(MobileNoteActionsSheet.doorLabel))
                await surface.settle(40)
                #expect(surface.activate(MobileEditorViewModel.deleteNoteTitle),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)

                let alert = try #require(surface.presentedAlert,
                                         "the confirm must actually present")
                #expect(alert.title == MobileEditorViewModel.deleteNoteConfirmTitle)
                #expect(alert.message == RecoveryCopy.moveToTrashDetail(.note))
                #expect(alert.message?.contains(RecoveryCopy.trashSection) == true)
                #expect(alert.message?.contains(RecoveryCopy.surfaceName) == true)
                #expect(surface.alertActionTitles.map { $0.lowercased() }
                    .contains("delete"))
                #expect(surface.alertActionTitles.map { $0.lowercased() }
                    .contains("cancel"))
            }

            // Asking is not doing: the note is still live.
            #expect(try await isTombstoned(db, table: "container", id: postID) == false)
        }
    }

    /// The Library row's door: its long-press menu row is not drivable in
    /// process (a `.contextMenu`'s items have no in-process activation), so
    /// this pin drives the model's request — and then proves the half that
    /// actually killed the Mac's doors: that the REAL Library view really
    /// presents the confirm when the model asks it to.
    @Test func theLibraryRowsConfirmReallyPresents() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["A library note."])
            let library = MobileLibraryViewModel(session: session)
            let scraps = MobileScrapsModel(session: session)
            let stars = MobileStarsModel(session: session)
            let item = try await db.read { db in
                try Queries.library(db, limit: 10).first { $0.postID == postID }
            }
            let row = try #require(item)

            try await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: scraps, stars: stars,
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in })
            ) { surface in
                library.requestDeleteNote(row)
                await surface.settle(40)
                let alert = try #require(surface.presentedAlert,
                                         "the Library's confirm must present")
                #expect(alert.title == MobileEditorViewModel.deleteNoteConfirmTitle)
                #expect(alert.message == RecoveryCopy.moveToTrashDetail(.note))
            }

            #expect(await library.confirmDeleteNote())
            #expect(try await isTombstoned(db, table: "container", id: postID))
            #expect(library.receipt == RecoveryCopy.movedToTrashReceipt(.note))
        }
    }

    /// **The recovery surface's door is on the Library, and it is a real
    /// button.** (The row is the `+ new book` precedent: a list ends with
    /// the way to the things that left it.)
    @Test func theLibraryCarriesTheRecoveryDoor() async throws {
        try await withEditorWorld { session, _ in
            let library = MobileLibraryViewModel(session: session)
            let scraps = MobileScrapsModel(session: session)
            let stars = MobileStarsModel(session: session)
            let opened = LockIsolatedBox(false)

            try await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: scraps, stars: stars,
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in },
                    onOpenRecovery: { opened.value = true })
            ) { surface in
                #expect(surface.activate(RecoveryCopy.surfaceName),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(20)
            }
            #expect(opened.value, "the door really opens the surface")
        }
    }

    /// A note deleted from under an editor is gone, and the door says the
    /// honest thing rather than an enum dump if it is asked twice.
    @Test func deletingAnAlreadyGoneNoteSpeaksPlainly() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Twice deleted."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            #expect(await model.deleteNote())
            #expect(await model.deleteNote() == false)
            #expect(model.statusMessage == "That note is already gone.")
        }
    }

    // MARK: - PR4 · Delete a book

    /// **The act, and the lesson she had to teach once already**: deleting
    /// a book does NOT delete its notes. The reading tombstones; the note
    /// it held stays live in the library; the Trash lists a `.book`.
    @Test func deletingABookKeepsItsNotes() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["A chapter."])
            let readingID = try await session.runner.run { ops in
                let book = try ops.createReading(name: "A Book", kind: .curated)
                _ = try ops.addPostToReading(postID, to: book.id)
                return book.id
            }
            let shelf = MobileShelfViewModel(session: session)
            let shelfBook = try await db.read { db in
                try Queries.bookshelf(db).first { $0.reading.id == readingID }
            }
            let book = try #require(shelfBook)

            shelf.requestDeleteBook(book)
            #expect(await shelf.confirmDeleteBook())
            #expect(try await isTombstoned(db, table: "reading", id: readingID))
            // Its NOTE is untouched — pointed at, never contained.
            #expect(try await isTombstoned(db, table: "container", id: postID) == false)
            #expect(try await liveContainerCount(db) == 1)
            #expect(shelf.lastReport == RecoveryCopy.movedToTrashReceipt(.book))

            let trash = try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now)
            }
            #expect(trash.contains { $0.kind == .book && $0.id == readingID })
        }
    }

    /// **The DOOR, driven**: the book-details sheet's real "Delete Book…"
    /// button presents the real confirm, and the confirm carries the
    /// notes-stay sentence.
    @Test func theBookDetailsDeleteRowPresentsTheRealConfirm() async throws {
        try await withEditorWorld { session, db in
            let readingID = try await session.runner.run { ops in
                try ops.createReading(name: "Field Notes", kind: .curated).id
            }

            try await withHostedSurface(
                MobileBookDetailsSheet(
                    session: session, readingID: readingID, tokens: .terminalLight)
            ) { surface in
                await surface.settle(30)
                #expect(surface.activate(MobileShelfFaces.deleteBookDoorTitle),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                let alert = try #require(surface.presentedAlert,
                                         "the confirm must actually present")
                #expect(alert.title == MobileShelfFaces.deleteBookConfirmTitle)
                #expect(alert.message?.contains("Field Notes") == true,
                        "the confirm names what it destroys (principle M-E)")
                #expect(alert.message?.contains(
                    RecoveryCopy.deleteBookKeepsItsNotes) == true)
                // The action words render through the VOICE register
                // (terminal lowercases chrome), so the pin asserts the act
                // rather than the casing.
                #expect(surface.alertActionTitles.map { $0.lowercased() }
                    .contains("delete"))
                #expect(surface.alertActionTitles.map { $0.lowercased() }
                    .contains("cancel"))
            }
            #expect(try await isTombstoned(db, table: "reading", id: readingID) == false)
        }
    }

    /// The shelf row's confirm really presents too (the row itself is a
    /// `.contextMenu` item — undrivable in process, so the model's request
    /// stands in for the tap and the PRESENTATION is what is proven).
    @Test func theShelfRowsConfirmReallyPresents() async throws {
        try await withEditorWorld { session, db in
            let readingID = try await session.runner.run { ops in
                try ops.createReading(name: "Shelf Book", kind: .curated).id
            }
            let shelf = MobileShelfViewModel(session: session)
            let stars = MobileStarsModel(session: session)
            let quickNote = MobileQuickNoteModel()
            let shelfBook = try await db.read { db in
                try Queries.bookshelf(db).first { $0.reading.id == readingID }
            }
            let book = try #require(shelfBook)

            try await withHostedSurface(
                MobileShelfView(
                    model: shelf, stars: stars, quickNote: quickNote,
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpenBook: { _ in }, onOpenForWriting: { _ in },
                    onOpenNote: { _ in }, onSettings: {})
            ) { surface in
                shelf.requestDeleteBook(book)
                await surface.settle(40)
                let alert = try #require(surface.presentedAlert)
                #expect(alert.title == MobileShelfFaces.deleteBookConfirmTitle)
                #expect(alert.message?.contains("Shelf Book") == true)
            }
        }
    }

    /// One wording family for both book doors — the shelf row and the
    /// details sheet cannot describe one act two ways.
    @Test func bothBookDoorsSpeakOneWording() async throws {
        #expect(MobileShelfFaces.deleteBookConfirmDetail(name: "X")
            .contains(RecoveryCopy.deleteBookKeepsItsNotes))
        #expect(MobileShelfFaces.deleteBookConfirmDetail(name: nil)
            .hasPrefix("The book goes"))
        #expect(MobileShelfFaces.deleteBookDoorTitle == "Delete Book…")
    }
}

/// A tiny main-actor box for a pin's "did the closure fire" oracle.
@MainActor
final class LockIsolatedBox<Value> {
    var value: Value
    init(_ value: Value) { self.value = value }
}
