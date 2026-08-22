//
//  MobileTrashTests.swift
//  VariorumMobileTests
//
//  **PR2 — "Archived & Deleted", the phone's recovery surface** (round 2,
//  batch 4). Before this batch the phone had ZERO of 13j's faces: the whole
//  vocabulary — `TrashWindow`, `Queries.trash`, `restoreBlock`,
//  `restoreVariant`, `requestPurge` — returned no hits in `VariorumMobile/`.
//
//  **These pins exist in the shape they do because of the MAC.** Its own
//  purge doors are DEAD at this tip: a `confirmationDialog` bound through a
//  computed `Binding` never presents, and 13j's view-model pins stayed
//  green over it. So every door here is proven by MOUNTING the real surface
//  and ACTIVATING the real control, and every confirm by asserting a real
//  `UIAlertController` really appears in the window.
//

import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
private func seedDeletedNote(
    _ session: AppSession, title: String
) async throws -> String {
    let post = try await session.runner.run { ops -> Container in
        let post = try ops.createPost(title: title, profile: .blog)
        _ = try ops.newBlock(in: post.id, text: "Body of \(title).", at: .end)
        return post
    }
    try await session.runner.run { ops in try ops.deleteContainer(post.id) }
    return post.id
}

@MainActor
@Suite("Mobile Trash — PR2's recovery surface")
struct MobileTrashTests {
    // MARK: - The listing

    /// Two sections, and they are NOT one list: the Trash's countdown and
    /// Archived's no-clock calm. Conflating them would make archive read as
    /// a deletion, which is the one thing they must never do to each other.
    @Test func theSurfaceCarriesBothSectionsAndTheirDifferentPromises() async throws {
        try await withEditorWorld { session, _ in
            let deleted = try await seedDeletedNote(session, title: "Gone")
            let archivedID = try await makePost(session, blocks: ["Kept."])
            try await session.runner.run { ops in try ops.archiveContainer(archivedID) }

            let model = MobileTrashModel(session: session)
            try await withHostedSurface(
                MobileTrashView(model: model, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(40)
                let labels = surface.visibleLabels
                #expect(model.trash.contains { $0.id == deleted })
                #expect(model.archived.contains { $0.postID == archivedID })
                // Both promises are ON SCREEN, in words.
                #expect(labels.contains { $0.contains("30 days") },
                        "labels were \(labels)")
                #expect(labels.contains { $0.contains(RecoveryCopy.archivedForever) })
            }
        }
    }

    /// The kind filter is applied IN SQL and restarts the observation — a
    /// window applied before a filter would window the wrong set. Driven on
    /// the real filter buttons.
    @Test func theKindFilterIsARealControlAndReallyFilters() async throws {
        try await withEditorWorld { session, _ in
            let noteID = try await seedDeletedNote(session, title: "A note")
            let readingID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(name: "A book", kind: .curated)
                return book.id
            }
            try await session.runner.run { ops in try ops.deleteReading(readingID) }

            let model = MobileTrashModel(session: session)
            try await withHostedSurface(
                MobileTrashView(model: model, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(model.trash.count == 2)

                #expect(surface.activate(RecoveryCopy.kindLabel(.book)),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(model.kindFilter == .book)
                #expect(model.trash.map(\.id) == [readingID])

                #expect(surface.activate(MobileTrashView.allFilterWord))
                await surface.settle(40)
                #expect(model.kindFilter == nil)
                #expect(Set(model.trash.map(\.id)) == Set([noteID, readingID]))
            }
        }
    }

    // MARK: - Put back

    /// **Put back, driven on the real button**, for the kind that matters
    /// most: a note comes back from the Trash and is live in the library
    /// again.
    @Test func theRealPutBackButtonRestoresANote() async throws {
        try await withEditorWorld { session, db in
            let noteID = try await seedDeletedNote(session, title: "Rescue me")
            let model = MobileTrashModel(session: session)

            try await withHostedSurface(
                MobileTrashView(model: model, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(surface.activate(
                    "\(RecoveryCopy.putBackVerb) \(RecoveryCopy.rowKind(.note))"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
            }

            let live = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT deleted_at FROM container WHERE id = ?",
                    arguments: [noteID])
            }
            #expect(live == nil, "the note is live again")
            #expect(model.receipt == MobileTrashModel.putBackReceipt(.note))
        }
    }

    /// A deleted BLOCK comes back where it was, and the receipt says which
    /// of the three landings happened — `restoreBlock` answers it, the
    /// surface repeats it rather than guessing.
    @Test func puttingBackABlockSaysWhereItLanded() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Keep.", "Cut."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            let doomed = model.index.entries[1].blockID
            await model.structural.deleteBlock(blockID: doomed)

            let trash = MobileTrashModel(session: session)
            // The row is read ONE-SHOT from the core listing: `startTrash`
            // is a held observation that never returns, and awaiting it
            // here would hang the pin (found exactly that way).
            let rows = try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now)
            }
            let row = try #require(rows.first { $0.id == doomed })
            await trash.putBack(row)

            #expect(trash.receipt == RecoveryCopy.putBackWhereItWas)
            #expect(try await storedBlockTexts(db, postID: postID) == ["Keep.", "Cut."])
        }
    }

    /// Un-archive is the Archived section's one act, and it is a real
    /// button too. Archive has no clock, so this is a plain state flip.
    @Test func theRealUnarchiveButtonBringsANoteBack() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Kept quietly."])
            try await session.runner.run { ops in try ops.archiveContainer(postID) }
            let model = MobileTrashModel(session: session)

            try await withHostedSurface(
                MobileTrashView(model: model, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(surface.activate(MobileTrashView.unarchiveVerb),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
            }

            let archivedAt = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT archived_at FROM container WHERE id = ?",
                    arguments: [postID])
            }
            #expect(archivedAt == nil)
            #expect(model.receipt == MobileTrashModel.unarchivedReceipt)
        }
    }

    // MARK: - True delete (the doors the Mac cannot currently reach)

    /// **THE PIN THE MAC'S DEFECT WROTE.** Press the real Delete Now on a
    /// real row and the real confirm appears — title, message and both
    /// actions asserted against a live `UIAlertController`. On the Mac this
    /// exact step is where the dialog never comes.
    @Test func deleteNowPresentsARealConfirmEveryTime() async throws {
        try await withEditorWorld { session, db in
            let noteID = try await seedDeletedNote(session, title: "For good")
            let model = MobileTrashModel(session: session)

            try await withHostedSurface(
                MobileTrashView(model: model, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(surface.activate(
                    "\(RecoveryCopy.deleteNowVerb) \(RecoveryCopy.rowKind(.note))"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)

                let alert = try #require(surface.presentedAlert,
                                         "Delete Now's confirm must actually present")
                #expect(alert.title == RecoveryCopy.deleteNowVerb)
                #expect(alert.message == RecoveryCopy.deleteNowConfirm(.note))
                #expect(alert.message?.contains("no putting it back") == true)
                #expect(surface.alertActionTitles.map { $0.lowercased() }
                    .contains(RecoveryCopy.deleteNowVerb.lowercased()))
                #expect(surface.alertActionTitles.map { $0.lowercased() }
                    .contains("cancel"))

                // Asking is not doing — no intent exists yet.
                let intents = try await db.read { db in
                    try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM purge_intent") ?? -1
                }
                #expect(intents == 0)

                // The confirmed act writes the intent AND — on a local-only
                // install, which this world is — the app's own sweep takes
                // the bytes right away, so Delete Now means what it says
                // the moment she reads the receipt (13j ladder B, B3).
                await model.confirmPendingPurge()
                let minted = try await db.read { db in
                    try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM purge_intent") ?? -1
                }
                #expect(minted == 1, "one intent per thing purged")
                let rowsLeft = try await db.read { db in
                    try Int.fetchOne(
                        db, sql: "SELECT COUNT(*) FROM container WHERE id = ?",
                        arguments: [noteID]) ?? -1
                }
                #expect(rowsLeft == 0, "the bytes are really gone")
                #expect(model.receipt?.contains("gone from the app now") == true)
            }
            let stillListed = try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now).contains { $0.id == noteID }
            }
            #expect(stillListed == false, "it left the Trash the moment the intent landed")
        }
    }

    /// **Empty Trash names the FULL count by kind**, read UNWINDOWED at ask
    /// time (her round-8 ruling: "everything, always"). Driven on the real
    /// header button.
    @Test func emptyTrashNamesEverythingItWillTake() async throws {
        try await withEditorWorld { session, db in
            _ = try await seedDeletedNote(session, title: "One")
            _ = try await seedDeletedNote(session, title: "Two")
            let readingID = try await session.runner.run { ops in
                try ops.createReading(name: "A book", kind: .curated).id
            }
            try await session.runner.run { ops in try ops.deleteReading(readingID) }

            let model = MobileTrashModel(session: session)
            try await withHostedSurface(
                MobileTrashView(model: model, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(surface.activate(RecoveryCopy.emptyTrashVerb),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)

                let alert = try #require(surface.presentedAlert)
                #expect(alert.title == RecoveryCopy.emptyTrashVerb)
                // The bulk door's own verb — never "Delete Now" over a
                // question about emptying the whole Trash.
                #expect(surface.alertActionTitles.map { $0.lowercased() }
                    .contains("empty trash"))
                let message = try #require(alert.message)
                #expect(message.contains("2 notes"))
                #expect(message.contains("1 book"))

                await model.confirmPendingPurge()
            }
            let intents = try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM purge_intent") ?? -1
            }
            #expect(intents == 3, "one intent per thing the confirm named")
            // Everything named really left: no live posts, no readings.
            let leftovers = try await db.read { db in
                (posts: try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post'") ?? -1,
                 readings: try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM reading") ?? -1)
            }
            #expect(leftovers.posts == 0)
            #expect(leftovers.readings == 0)
        }
    }

    /// **Empty Trash is not rendered when the Trash is empty** (P-2), and
    /// the ONLY place either purge door exists is this surface — her
    /// round-3 rider: *"never accidental full delete from within a note."*
    @Test func thePurgeDoorsExistNowhereButHere() async throws {
        try await withEditorWorld { session, _ in
            // An empty Trash renders no Empty Trash door at all.
            let model = MobileTrashModel(session: session)
            try await withHostedSurface(
                MobileTrashView(model: model, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(30)
                #expect(!surface.visibleLabels.contains(RecoveryCopy.emptyTrashVerb))
            }

            // And a NOTE's own surfaces carry neither purge verb — the
            // structural guarantee, asserted where a leak would show.
            let postID = try await makePost(session, blocks: ["A note."])
            let (editor, _) = await makeSurfaceEditor(session, postID: postID)
            try await withHostedSurface(
                MobileWriteScreen(session: session, postID: postID, editor: editor)
            ) { surface in
                await surface.settle(30)
                #expect(surface.activate(MobileNoteActionsSheet.doorLabel))
                await surface.settle(40)
                let labels = surface.visibleLabels
                #expect(!labels.contains(RecoveryCopy.deleteNowVerb), "labels were \(labels)")
                #expect(!labels.contains(RecoveryCopy.emptyTrashVerb))
            }
        }
    }

    /// A PRESERVED ORIGINAL never wears a Delete Now — it rides its
    /// family's clock (her round-8b ruling), and the belt refuses even if a
    /// caller asks.
    @Test func aPreservedOriginalHasNoPurgeDoorOfItsOwn() async throws {
        try await withEditorWorld { session, _ in
            let model = MobileTrashModel(session: session)
            let original = Queries.TrashItem(
                kind: .preservedOriginal, id: "block-1", deletedAt: "2026-08-01T00:00:00Z",
                text: "The original whole.", noteID: "post-1")
            model.requestDeleteNow(original)
            #expect(model.pendingConfirm == nil, "the belt holds")
        }
    }

    // MARK: - Copy

    /// One vocabulary, shared with the Mac since this batch — the two
    /// platforms cannot describe one 30-day clock two ways.
    @Test func theDeletionVocabularyIsShared() async throws {
        #expect(RecoveryCopy.trashSection == "Trash")
        #expect(RecoveryCopy.archivedSection == "Archived")
        #expect(RecoveryCopy.daysLeftLabel(0) == "leaves today")
        #expect(RecoveryCopy.daysLeftLabel(1) == "1 day left")
        #expect(RecoveryCopy.archivedForever == "kept — no clock")
        #expect(RecoveryCopy.windowNote.contains("\(TrashWindow.days) days"))
        #expect(Queries.TrashItem.Kind.note.purgeTable == "container")
        #expect(Queries.TrashItem.Kind.book.purgeTable == "reading")
        #expect(Queries.TrashItem.Kind.take.purgeTable == "variant")
        #expect(Queries.TrashItem.Kind.preservedOriginal.purgeTable == "block")
    }
}
