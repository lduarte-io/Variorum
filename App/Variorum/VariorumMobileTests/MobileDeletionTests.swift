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
                // **ONE NOUN FOR ONE ROAD** (the post-13l polish round,
                // ledger row 5 — her A5 ruling). This line used to assert the
                // message ALSO named "Archived & Deleted", i.e. it pinned the
                // defect: one road, two nouns, in the confirm she reads while
                // deciding whether to delete her writing. STRENGTHENED to the
                // fact the test is actually about — the place is named once.
                #expect(alert.message?.contains(RecoveryCopy.surfaceName) == false,
                        "the confirm names the road ONCE — \(alert.message ?? "")")
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
                    books: MobileShelfViewModel(session: session),
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in })
            ) { surface in
                library.requestDeleteNote(row)
                await surface.settle(40)
                let alert = try #require(surface.presentedAlert,
                                         "the Library's confirm must present")
                #expect(alert.title == MobileEditorViewModel.deleteNoteConfirmTitle)
                #expect(alert.message == RecoveryCopy.moveToTrashDetail(.note))

                // **THE CONFIRM→ACT EDGE, DRIVEN** (batch 4.5b's BLOCKER).
                // The shipped pin called `confirmDeleteNote()` directly while
                // the pending note was still set. Tapping the real action and
                // landing SwiftUI's write-back in the same turn is what the
                // defect needed: pre-fix, the act read `pendingDeleteNote`
                // back, found `nil`, and deleted NOTHING.
                #expect(surface.tapAlertAction(
                    "Delete", writeBack: { library.deleteNotePresented = false }),
                        "the Delete action must be drivable")
                await surface.settle(40)
            }

            #expect(try await isTombstoned(db, table: "container", id: postID),
                    "the note really went to the Trash")
            #expect(library.receipt == RecoveryCopy.movedToTrashReceipt(.note))
        }
    }

    /// **THE LIBRARY ROW'S DELETE FLUSHES FIRST — and the shipped comment
    /// saying it need not was falsified by the shell's own architecture**
    /// (§49's MINOR). That comment read: *"this row deletes a note NO surface
    /// on this phone has open, so there is no pending buffer to land."* Both
    /// tab stacks stay alive by design (`MobileLivenessAuthority`: two
    /// `MobileWriteScreen`s can exist at once and nothing about visibility
    /// fires `onDisappear`), so the commonest road to this door is *open a
    /// note → switch to Library → delete that row* — with the note's editor
    /// mounted and its debounce still holding keystrokes.
    ///
    /// A tombstone is recoverable for 30 days; text that never reached the
    /// store is not. So the keystrokes must land BEFORE the tombstone.
    ///
    /// **Red on old:** drop the `flushEveryOpenPost()` and the typed bytes
    /// are simply gone — the stored take still reads the pre-typing text.
    @Test func theLibraryRowsDeleteLandsPendingKeystrokesFirst() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Before typing."])
            let (editor, _) = await makeSurfaceEditor(session, postID: postID)
            // `.first`, never `[0]`: a collection indexed right after its
            // size is taken is a runner-killer under a red-on-old revert.
            let variantID = try #require(editor.index.entries.first?.variantID)
            // Pending, NOT flushed — inside the debounce, exactly where a
            // typing burst lives when she switches tabs.
            editor.autosave.record(
                variantID: variantID, text: "Before typing. And this too.", charDelta: 13)

            let library = MobileLibraryViewModel(session: session)
            let row = try #require(try await db.read { db in
                try Queries.library(db, limit: 10).first { $0.postID == postID }
            })
            library.requestDeleteNote(row)
            #expect(await library.confirmDeleteNote(row))

            let stored = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [variantID])
            }
            #expect(stored == "Before typing. And this too.",
                    "the keystrokes reached the store before the tombstone")
        }
    }

    /// **A REFUSAL RAISED ON THE ⋯ SHEET IS SPOKEN ON THE ⋯ SHEET** (§49's
    /// MINOR: *a refusal spoken behind the presenting sheet*). Every act
    /// there reports through the editor's status, which renders in the WRITE
    /// masthead — and the sheet is over the masthead. On success the sheet
    /// dismisses, so it never showed; on a REFUSAL the sheet deliberately
    /// STAYS UP (a refused delete must not look like it went), and the
    /// sentence explaining why landed where she could not see it.
    ///
    /// **The refusal had to be a state the product really produces**, and the
    /// first attempt at this pin did not: a SEALED note does not refuse
    /// deletion at all — the seal is content-level and AppSpec §9 says the
    /// post itself may still be deleted (recoverable via `restoreContainer`).
    /// That pin passed while pinning a fiction. The real road is the one the
    /// refusal vocabulary already names: the note is **already gone**, which
    /// is exactly what a second tab's delete leaves behind.
    ///
    /// **Red on old:** remove the sheet's `reportLine` and the refusal is
    /// nowhere in the sheet's tree.
    @Test func aRefusedDeleteIsSpokenOnTheSheetThatRaisedIt() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Already gone."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            // Deleted from elsewhere while this editor stands on it — the
            // shell keeps both tab stacks alive, so this is an ordinary road.
            try await session.runner.run { ops in try ops.deleteContainer(postID) }

            try await withHostedSurface(
                MobileWriteScreen(session: session, postID: postID, editor: model)
            ) { surface in
                #expect(surface.activate(MobileNoteActionsSheet.doorLabel))
                await surface.settle(40)
                #expect(surface.activate(MobileEditorViewModel.deleteNoteTitle),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(surface.tapAlertAction("Delete", writeBack: {}),
                        "the sheet's Delete confirm must be drivable")
                await surface.settle(40)

                // The sheet is STILL UP — a refused delete must not look like
                // it went — which is exactly why the refusal must be here.
                let labels = surface.visibleLabels
                #expect(labels.contains(MobileEditorViewModel.deleteNoteTitle),
                        "the sheet stayed up — labels were \(labels)")
                let message = try #require(model.statusMessage, "the act refused in words")
                #expect(message == "That note is already gone.")
                #expect(labels.contains { $0.contains(message) },
                        "the refusal is ON the sheet — labels were \(labels)")
            }
        }
    }

    /// **TWO DOORS, TWO DESTINATIONS** (batch 6c — her QUESTIONS #84
    /// ruling). Batch 4's pin drove ONE door labelled *"Archived & Deleted"*;
    /// under Two rooms the Library carries two, and each must reach its own
    /// room. Both are real Buttons driven through the real accessibility
    /// activation, and the assertion that matters is that they are
    /// DIFFERENT: a split whose two doors both opened the same screen would
    /// pass a "the door exists" pin and fail the ruling entirely.
    @Test func theLibraryCarriesBothRoomsDoors() async throws {
        try await withEditorWorld { session, _ in
            let library = MobileLibraryViewModel(session: session)
            let scraps = MobileScrapsModel(session: session)
            let stars = MobileStarsModel(session: session)
            let trash = LockIsolatedBox(false)
            let archive = LockIsolatedBox(false)

            try await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: scraps, stars: stars,
                    books: MobileShelfViewModel(session: session),
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in },
                    onOpenTrash: { trash.value = true },
                    onOpenArchive: { archive.value = true })
            ) { surface in
                await surface.settle(20)
                // The path line's 🗑 — option 2's own letter, and the
                // analogue of her Mac B1 masthead trash icon.
                #expect(surface.activate(MobileRecoveryDoors.trashLabel),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(20)
                #expect(trash.value, "the glyph really opens the Trash room")
                #expect(!archive.value, "and it is NOT the archive door")

                // The trailing row, NARROWED: it says Archived and opens
                // only the archive.
                #expect(surface.activate(MobileRecoveryDoors.archiveLabel),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(20)
                #expect(archive.value, "the row really opens the Archive room")
            }
        }
    }

    /// **THE SHELF RENDERS THE SAME TRASH DOOR, FROM THE SAME DECLARATION**
    /// (batch 6c, PROVISIONAL — the design record's finding 1 and its Q6).
    ///
    /// Books live on the Shelf and a deleted BOOK rows in the Trash, so a
    /// trash door reachable only from the Library would put a tab switch
    /// between deleting a book and getting it back. The pin drives the real
    /// door on the real shelf and asserts it carries the SAME label the
    /// Library's does — one declaration, two renderers, which is what stops
    /// the two path lines drifting about what 🗑 means.
    @Test func theShelfCarriesTheSameTrashDoor() async throws {
        try await withEditorWorld { session, _ in
            let shelf = MobileShelfViewModel(session: session)
            let stars = MobileStarsModel(session: session)
            let quick = MobileQuickNoteModel()
            let opened = LockIsolatedBox(false)

            try await withHostedSurface(
                MobileShelfView(
                    model: shelf, stars: stars, quickNote: quick,
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpenBook: { _ in }, onOpenForWriting: { _ in },
                    onSettings: {},
                    onOpenTrash: { opened.value = true })
            ) { surface in
                await surface.settle(20)
                #expect(surface.activate(MobileRecoveryDoors.trashLabel),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(20)
            }
            #expect(opened.value, "the shelf's door really opens the Trash room")
            // ONE declaration: the label the Shelf drove is the Library's.
            #expect(MobileRecoveryDoors.trashLabel == RecoveryCopy.trashSection)
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

    /// **THE LAST `String(describing:)` IN THIS DOOR'S FAMILY IS CLOSED**
    /// (4.5c-phone item 4 — A1-18's 4.5c share).
    ///
    /// `DeletionRefusal` exists because three private tables each covered a
    /// different subset of `OperationError` and each fell through to a bare
    /// enum dump, so one refused act read three ways depending on the door.
    /// Two of the three were adopted at 4.5b; `deleteNoteRefusal` was the
    /// third, and this pins that it now forwards rather than deciding.
    ///
    /// **SCOPE, STATED HONESTLY — this is a contract pin, not a road pin.**
    /// `deleteContainer`'s only reachable refusal today is
    /// `containerNotFound` (its body's one guard is `liveContainer`), and BOTH
    /// tables word that identically — so nothing she can currently reach
    /// changes, and `deletingAnAlreadyGoneNoteSpeaksPlainly` above still
    /// passes unmodified, which is the proof. What closed is the FALLBACK: the
    /// next refusal this op learns to throw arrives as a sentence instead of
    /// `lockedPost(id: "…")`, which is the whole reason A1-18 wanted one home.
    ///
    /// **RED ON OLD (production, `MobileEditorViewModel.deleteNoteRefusal`):**
    /// the pre-fix table returns `String(describing:)` for every case but one,
    /// so the two `lockedPost`/`containerNotDeleted` rows below fail with the
    /// raw enum text. Quoted in the batch record.
    @Test func theNoteDeleteDoorSpeaksTheSharedDeletionVocabulary() {
        let cases: [Error] = [
            OperationError.containerNotFound(id: "c1"),
            OperationError.lockedPost(id: "p1"),
            OperationError.containerNotDeleted(id: "c1"),
            OperationError.variantNotFound(id: "v1"),
        ]
        for error in cases {
            let spoken = MobileEditorViewModel.deleteNoteRefusal(error)
            #expect(spoken == DeletionRefusal.words(error, act: .delete),
                    "the door forwards rather than keeping a table of its own")
            #expect(!spoken.contains("OperationError"), "never the raw enum")
            #expect(!spoken.contains("id: \""), "nor its associated values")
        }
        // The one case both tables always mapped, named so the pin records
        // that this sentence did NOT change.
        #expect(MobileEditorViewModel.deleteNoteRefusal(
            OperationError.containerNotFound(id: "c1")) == "That note is already gone.")
    }

    // MARK: - PR4 · Delete a book

    /// **The act, and the lesson she had to teach once already**: deleting
    /// a book does NOT delete its notes. The reading tombstones; the note
    /// it held stays live in the library; the Trash lists a `.book`.
    @Test func deletingABookKeepsItsNotes() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["A chapter."])
            let readingID = try await session.runner.run { ops in
                let book = try ops.createReading(name: "A Book", kind: .book)
                _ = try ops.addPostToReading(postID, to: book.id)
                return book.id
            }
            let shelf = MobileShelfViewModel(session: session)
            let shelfBook = try await db.read { db in
                try Queries.bookshelf(db).first { $0.reading.id == readingID }
            }
            let book = try #require(shelfBook)

            // **THE CONFIRM→ACT EDGE, DRIVEN** (batch 4.5b's BLOCKER) — the
            // shelf row's long-press is undrivable in process, but its
            // confirm is a real alert on a real surface, and the edge that
            // killed this door is the confirm's, not the menu's.
            try await withHostedSurface(
                MobileShelfView(
                    model: shelf, stars: MobileStarsModel(session: session),
                    quickNote: MobileQuickNoteModel(), tokens: .terminalLight,
                    tabBar: { EmptyView() },
                    onOpenBook: { _ in }, onOpenForWriting: { _ in },
                    onSettings: {})
            ) { surface in
                shelf.requestDeleteBook(book)
                await surface.settle(40)
                _ = try #require(surface.presentedAlert, "the shelf's confirm must present")
                #expect(surface.tapAlertAction(
                    "Delete", writeBack: { shelf.deleteBookPresented = false }),
                        "the Delete action must be drivable")
                await surface.settle(40)
            }
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
                try ops.createReading(name: "Field Notes", kind: .book).id
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
                try ops.createReading(name: "Shelf Book", kind: .book).id
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
                    onSettings: {})
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
