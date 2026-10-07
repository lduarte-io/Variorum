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

    /// **TWO ROOMS, AND EACH CARRIES ONLY ITS OWN PROMISE** (batch 6c — her
    /// QUESTIONS #84 ruling: *"two doors, two destinations, nothing
    /// shared"*).
    ///
    /// Batch 4's pin asserted both promises on ONE screen, which was that
    /// screen's honest shape. Under Two rooms the assertion inverts and
    /// becomes stronger: the Trash room shows the 30-day clock **and never
    /// the kept-forever line**, and the Archive room shows kept-forever
    /// **and never a countdown**. Conflating them would make archive read as
    /// a deletion, which is the one thing the two states must never do to
    /// each other — and after a split, "each room shows only its own" is the
    /// form of that promise a screen can actually break.
    ///
    /// **AND THE VERSION FENCE, ON THE ONE SURFACE THAT COULD NEWLY LEAK
    /// ONE** (added at the 6c fix wave, cold-review n8). A saved moment is a
    /// container born ARCHIVED, so the new Archive room is exactly the phone
    /// listing where the born-archived classifier could show her a thing
    /// whose one home is Note ▸ Versions. The fence itself is the core's
    /// (`Queries.versionHistoryPredicate` and `observeArchivedPosts`'s
    /// `excludingVersionHistory: true` default, nine core pins deep) — what
    /// was missing was a phone-side pin holding it over the phone's own
    /// room, so a later face that passes `false` for a reason that seemed
    /// good says so here.
    @Test func theTwoRoomsCarryOnlyTheirOwnPromises() async throws {
        try await withEditorWorld { session, _ in
            let deleted = try await seedDeletedNote(session, title: "Gone")
            let archivedID = try await makePost(session, blocks: ["Kept."])
            try await session.runner.run { ops in try ops.archiveContainer(archivedID) }
            // A note with a saved moment — the moment is a container born
            // archived, and it must NOT row in the Archive room.
            let noteWithMoment = try await makePost(
                session, blocks: ["A note that keeps its moments elsewhere."])
            try await session.runner.run { ops in
                try ops.saveNoteVersion(noteWithMoment)
            }
            let momentID = try await session.database.read { db in
                try Queries.noteVersions(db, of: noteWithMoment).first?.postID
            }
            let moment = try #require(momentID)

            let trash = MobileTrashModel(session: session)
            try await withHostedSurface(
                MobileTrashView(model: trash, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(40)
                let labels = surface.visibleLabels
                #expect(trash.trash.contains { $0.id == deleted })
                #expect(labels.contains { $0.contains("30 days") },
                        "labels were \(labels)")
                // The other room's promise is NOT here.
                #expect(!labels.contains { $0.contains(RecoveryCopy.archivedForever) },
                        "labels were \(labels)")
            }

            let archive = MobileArchiveModel(session: session)
            try await withHostedSurface(
                MobileArchiveView(model: archive, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(40)
                let labels = surface.visibleLabels
                #expect(archive.archived.contains { $0.postID == archivedID })
                #expect(labels.contains { $0.contains(RecoveryCopy.archivedForever) },
                        "labels were \(labels)")
                // NO countdown anywhere in the room that keeps things.
                #expect(!labels.contains { $0.contains("days left") })
                #expect(!labels.contains { $0.contains("30 days") })
                // n8: the saved moment is born archived and stays OUT — in
                // the room's own listing and on its screen.
                #expect(!archive.archived.contains { $0.postID == moment },
                        "a moment's one home is its note's Versions")
                #expect(archive.archived.contains { $0.postID == archivedID },
                        "and the fence is not just an empty room")
            }
        }
    }

    /// **THE COMBINED SURFACE'S NAME IS GONE FROM THE LIBRARY, WHERE ITS
    /// DOOR STOOD.** `RecoveryCopy.surfaceName` — *"Archived & Deleted"* —
    /// was the label of the Library's trailing row, opening one screen that
    /// held both states; its awkward two-noun shape is exactly what the
    /// design record blames on the conflation. The string stays in `Shared/`
    /// (the Mac's own file, fenced this batch); what this pin holds is that
    /// the LIBRARY no longer speaks it and says the two rooms' words
    /// instead.
    ///
    /// **The corpus-wide claim is TRUE and is not what is driven** (the 6c
    /// cold review's n7): `RecoveryCopy.surfaceName` has zero call sites
    /// anywhere under `VariorumMobile/` — grep-verified, and re-verifiable
    /// in one line — but a pin that mounts one surface proves it of that
    /// surface. The doc says which is which so a later reader does not read
    /// this as a corpus guard it cannot be.
    @Test func theCombinedSurfacesNameIsGoneFromThePhone() async throws {
        try await withEditorWorld { session, _ in
            let library = MobileLibraryViewModel(session: session)
            let scraps = MobileScrapsModel(session: session)
            let stars = MobileStarsModel(session: session)
            try await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: scraps, stars: stars,
                    books: MobileShelfViewModel(session: session),
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in },
                    onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                await surface.settle(40)
                let labels = surface.visibleLabels
                #expect(!labels.contains(RecoveryCopy.surfaceName),
                        "labels were \(labels)")
                // What stands in its place: the narrowed row, and the glyph
                // door whose LABEL is the room's word.
                #expect(labels.contains(MobileRecoveryDoors.archiveLabel))
                #expect(labels.contains(MobileRecoveryDoors.trashLabel))
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
                let book = try ops.createReading(name: "A book", kind: .book)
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

    /// **A SAVED VERSION IS NOT A NOTE, AND VOICEOVER MUST SAY SO**
    /// (the polish round's ladder finding **LR2-4**, this batch's one
    /// bug-class fix).
    ///
    /// A saved version rides the Trash as a `.note`-kind row — it IS a
    /// container, born archived and sealed — so both of this surface's
    /// accessibility labels read `rowKind(item.kind)` and announced *"Put
    /// back note"* / *"Delete Now note"* over one of her saved moments. The
    /// Mac's DISPLAY line had been worded around this at the polish round
    /// (ledger row 23) and the phone's labels never were; the fix is the one
    /// rule in one shared home (`RecoveryCopy.rowKind(_:)` — the item
    /// overload), which both platforms now read.
    ///
    /// **RED ON OLD** by behavioural revert: put `rowKind(item.kind)` back in
    /// either label and this reds, reading "Put back note".
    @Test func aSavedVersionsDoorsAnnounceThemselvesAsSavedVersions() async throws {
        try await withEditorWorld { session, _ in
            let noteID = try await makePost(session, blocks: ["The note itself."])
            let version = try await session.runner.run { ops -> String in
                try ops.saveNoteVersion(noteID).post.id
            }
            try await session.runner.run { ops in try ops.deleteContainer(version) }

            let model = MobileTrashModel(session: session)
            try await withHostedSurface(
                MobileTrashView(model: model, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(40)
                let row = try #require(model.trash.first { $0.id == version })
                #expect(row.isVersion, "the listing knows what it is")
                let labels = surface.visibleLabels
                #expect(labels.contains(
                    "\(RecoveryCopy.putBackVerb) \(VersionsPath.trashRowKind)"),
                        "labels were \(labels)")
                #expect(labels.contains(
                    "\(RecoveryCopy.deleteNowVerb) \(VersionsPath.trashRowKind)"),
                        "labels were \(labels)")
                #expect(!labels.contains(
                    "\(RecoveryCopy.putBackVerb) \(RecoveryCopy.rowKind(.note))"),
                        "and never the note wording over a saved moment")
                // Found while pinning the labels: the ROW's own line was
                // version-blind too, and it hid the note this moment belongs
                // to (a version IS `.note`-kind, so the "not a note" guard
                // skipped exactly the row that needed the name).
                #expect(labels.contains { $0.contains(VersionsPath.trashRowKind) },
                        "the row says what it is — \(labels)")
                #expect(labels.contains { $0.contains(VersionsPath.trashRowOf("md")) },
                        "and whose moment it is — \(labels)")
            }
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

    /// **The TAKE half of the same rule** (13l Act 1, A1-MAJOR-1 — the phone's
    /// twin of the Mac pin, inherited through `TrashPutBack`). The restore is
    /// an exact flip (#68(b)), so a take ARCHIVED when it was deleted comes
    /// back archived, into its block's archived listing — and the shipped road
    /// discarded `restoreVariant`'s status and said *"Take put back."*, which
    /// sends her to the fan for something that is not there.
    ///
    /// **Red on old** on both platforms at once: the decision lives in
    /// `Shared/`, which is exactly why one fix answers both surfaces.
    @Test func puttingBackAnArchivedTakeSaysItCameBackArchived() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Alpha."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            let blockID = model.index.entries[0].blockID
            let chosen = try #require(model.index.entries[0].variantID)

            // Archived-then-deleted is reachable: `deleteVariant` accepts it
            // (I10's guard counts only ACTIVE takes) and `Queries.trash` lists
            // deleted takes with no status filter.
            let takeID = try await session.runner.run { ops -> String in
                let take = try ops.branchVariant(blockID, from: chosen)
                try ops.archiveVariant(take.id)
                try ops.deleteVariant(take.id)
                return take.id
            }

            let rows = try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now)
            }
            let row = try #require(rows.first { $0.kind == .take && $0.id == takeID })

            let trash = MobileTrashModel(session: session)
            await trash.putBack(row)
            #expect(trash.lastError == nil)
            #expect(trash.receipt == RecoveryCopy.takeRestoredArchived,
                    "the phone repeats the op's own answer too — never \"the fan\" here")
            let status = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT status FROM variant WHERE id = ?", arguments: [takeID])
            }
            #expect(status == "archived", "the exact flip stands — nothing un-archived")
        }
    }

    /// Un-archive is the Archive room's one act, and it is a real button
    /// too. Archive has no clock, so this is a plain state flip. (Batch 4's
    /// pin, following its act into the room the split gave it — the act, the
    /// receipt and the assertions are unchanged.)
    @Test func theRealUnarchiveButtonBringsANoteBack() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Kept quietly."])
            try await session.runner.run { ops in try ops.archiveContainer(postID) }
            let model = MobileArchiveModel(session: session)

            try await withHostedSurface(
                MobileArchiveView(model: model, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(surface.activate(MobileArchiveView.unarchiveVerb),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
            }

            let archivedAt = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT archived_at FROM container WHERE id = ?",
                    arguments: [postID])
            }
            #expect(archivedAt == nil)
            #expect(model.receipt == MobileArchiveModel.unarchivedReceipt)
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

                // **THE CONFIRM→ACT EDGE, DRIVEN** (batch 4.5b's BLOCKER).
                // The shipped pin called `confirmPendingPurge()` directly,
                // WHILE the pending value was still set — the one edge with
                // no coverage, and the one the defect lived in. This taps the
                // real action and lands SwiftUI's write-back in the same
                // turn: on the pre-fix code the confirm read `pendingConfirm`
                // back, found `nil`, and purged NOTHING.
                #expect(surface.tapAlertAction(
                    RecoveryCopy.deleteNowVerb,
                    writeBack: { model.purgeConfirmPresented = false }),
                        "the confirm's real action must be drivable")
                await surface.settle(40)
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
                try ops.createReading(name: "A book", kind: .book).id
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

                // The bulk door's confirm→act edge, driven the same way.
                #expect(surface.tapAlertAction(
                    "Empty Trash",
                    writeBack: { model.purgeConfirmPresented = false }),
                        "Empty Trash's real action must be drivable")
                await surface.settle(40)
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

    // MARK: - The 6c fix wave (the cold review's n9 and n10)

    /// **BOTH ROOMS' WINDOWS SAY SO, ON SCREEN** (n9 — an inherited gap that
    /// arrived on a new surface).
    ///
    /// The listings have been windowed since batch 4 (P1's Phase 10
    /// discipline: `window + 1`, a probe row, `TrashListing.windowed`) and
    /// the markers have never been driven — so *"the window is never
    /// silent"* was a claim about code nothing read. Both rooms are seeded
    /// past a deliberately tiny window and the marker is asserted where she
    /// would read it.
    ///
    /// It also holds the two rooms to **one sentence**: the Archive room and
    /// Note ▸ Versions have no filter to narrow, so they share
    /// `MobileRoomListing.truncationMarker` (declared once at this fix wave
    /// — the Archive room's private copy is retired), while the Trash's own
    /// marker keeps its *"narrow the filter"* half because the Trash HAS a
    /// filter.
    ///
    /// **NEW COVERAGE for the two rooms** (the markers were built at batch
    /// 4/6c and merely unpinned); the Versions room's marker is red-on-old
    /// and is pinned in its own suite.
    @Test func bothRoomsSayWhenTheWindowIsHidingSomething() async throws {
        try await withEditorWorld { session, _ in
            _ = try await seedDeletedNote(session, title: "First gone")
            _ = try await seedDeletedNote(session, title: "Second gone")
            for title in ["First kept", "Second kept"] {
                let id = try await makePost(session, blocks: [title])
                try await session.runner.run { ops in try ops.archiveContainer(id) }
            }

            let trash = MobileTrashModel(session: session, window: 1)
            try await withHostedSurface(
                MobileTrashView(model: trash, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(trash.trash.count == 1)
                #expect(trash.trashTruncated)
                let labels = surface.visibleLabels
                #expect(labels.contains(MobileTrashView.truncationMarker(shown: 1)),
                        "labels were \(labels)")
                // The Trash's sentence is the one WITH the filter half.
                #expect(MobileTrashView.truncationMarker(shown: 1)
                    .contains("narrow the filter"))
            }

            let archive = MobileArchiveModel(session: session, window: 1)
            try await withHostedSurface(
                MobileArchiveView(model: archive, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(archive.archived.count == 1)
                #expect(archive.truncated)
                let labels = surface.visibleLabels
                #expect(labels.contains(MobileRoomListing.truncationMarker(shown: 1)),
                        "labels were \(labels)")
                // …and the filterless rooms' sentence does not claim one.
                #expect(!MobileRoomListing.truncationMarker(shown: 1)
                    .contains("filter"))
            }
        }
    }

    /// **EACH ROOM'S "OPEN NOTE" DOOR IS DRIVEN, ON THE REAL SURFACE** (n10
    /// — the one door on the two new surfaces no pin activated, in the round
    /// that shipped four dead-door classes; §15's trap (b) is the whole
    /// reason this suite mounts anything at all).
    ///
    /// The two doors mean different things and are asserted separately: the
    /// Archive room's row opens the archived note ITSELF (an archived note
    /// is a work, not a deletion — MobileSoul §4.3's see-your-data road),
    /// and a Trash row's opens the still-live note the deleted thing came
    /// FROM.
    ///
    /// **RED-ON-OLD** for either half by pointing its `onOpen` at anything
    /// else: the id carried is asserted, not merely that something fired.
    @Test func bothRoomsOpenNoteDoorsReallyOpenTheRightNote() async throws {
        try await withEditorWorld { session, db in
            // The Archive room: the row opens the archived note itself.
            let archivedID = try await makePost(session, blocks: ["Kept and openable."])
            try await session.runner.run { ops in try ops.archiveContainer(archivedID) }
            let openedFromArchive = LockIsolatedBox<String?>(nil)
            let archive = MobileArchiveModel(session: session)
            try await withHostedSurface(
                MobileArchiveView(
                    model: archive, tokens: .terminalLight,
                    onOpen: { openedFromArchive.value = $0 })
            ) { surface in
                await surface.settle(40)
                #expect(surface.activate("Open note"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(20)
            }
            #expect(openedFromArchive.value == archivedID,
                    "the archived note opens — itself, not something near it")

            // The Trash room: a deleted BLOCK's row opens the note it came
            // from, which is still live.
            let postID = try await makePost(session, blocks: ["Keep.", "Cut."])
            let (editor, _) = await makeSurfaceEditor(session, postID: postID)
            let doomed = editor.index.entries[1].blockID
            await editor.structural.deleteBlock(blockID: doomed)
            let rows = try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now)
            }
            #expect(rows.contains { $0.id == doomed && $0.noteID == postID })

            let openedFromTrash = LockIsolatedBox<String?>(nil)
            let trash = MobileTrashModel(session: session)
            try await withHostedSurface(
                MobileTrashView(
                    model: trash, tokens: .terminalLight,
                    onOpen: { openedFromTrash.value = $0 })
            ) { surface in
                await surface.settle(40)
                #expect(surface.activate("Open note"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(20)
            }
            #expect(openedFromTrash.value == postID,
                    "a deleted block's row opens the note it came from")
        }
    }

    /// **Empty Trash is not rendered when the Trash is empty** (P-2), and
    /// the ONLY place either purge door exists is the TRASH ROOM — her
    /// round-3 rider: *"never accidental full delete from within a note."*
    ///
    /// **BATCH 6c EXTENDED THIS PIN BECAUSE THE SPLIT IS WHERE THE RULE
    /// COULD HAVE BEEN LOST.** Batch 4's version asserted the absence on a
    /// note's own surfaces only, because there was one recovery screen and
    /// the purge doors were on it. Now there are two rooms, and the archived
    /// listing that used to sit UNDER the same header — beneath the same
    /// Empty Trash button — is its own screen with its own model. So the
    /// nowhere-else assertion now names all three places a leak could
    /// appear: the **Archive room**, the **Library** (whose path line grew a
    /// door this batch), and a note's own surfaces.
    @Test func thePurgeDoorsExistNowhereButInTheTrashRoom() async throws {
        try await withEditorWorld { session, _ in
            // An empty Trash renders no Empty Trash door at all.
            let model = MobileTrashModel(session: session)
            try await withHostedSurface(
                MobileTrashView(model: model, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(30)
                #expect(!surface.visibleLabels.contains(RecoveryCopy.emptyTrashVerb))
            }

            // **THE ARCHIVE ROOM** — kept-forever, and no purge door of any
            // kind. It holds a real archived note, so this is an absence
            // asserted over a populated screen, never a vacuous one.
            let archivedID = try await makePost(session, blocks: ["Kept."])
            try await session.runner.run { ops in try ops.archiveContainer(archivedID) }
            let archive = MobileArchiveModel(session: session)
            try await withHostedSurface(
                MobileArchiveView(model: archive, tokens: .terminalLight, onOpen: { _ in })
            ) { surface in
                await surface.settle(40)
                let labels = surface.visibleLabels
                #expect(labels.contains(MobileArchiveView.unarchiveVerb),
                        "the room really rendered its rows — labels were \(labels)")
                #expect(!labels.contains(RecoveryCopy.deleteNowVerb), "labels were \(labels)")
                #expect(!labels.contains(RecoveryCopy.emptyTrashVerb))
                #expect(!labels.contains { $0.hasPrefix(RecoveryCopy.deleteNowVerb) })
            }

            // **THE LIBRARY** — it gained a door to the Trash this batch,
            // and a door to a room is not a purge door.
            let library = MobileLibraryViewModel(session: session)
            let scraps = MobileScrapsModel(session: session)
            let stars = MobileStarsModel(session: session)
            try await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: scraps, stars: stars,
                    books: MobileShelfViewModel(session: session),
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                await surface.settle(40)
                let labels = surface.visibleLabels
                #expect(labels.contains(MobileRecoveryDoors.trashLabel),
                        "the door itself is there — labels were \(labels)")
                #expect(!labels.contains(RecoveryCopy.deleteNowVerb))
                #expect(!labels.contains(RecoveryCopy.emptyTrashVerb))
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

    /// **TAKES STILL DO NOT ROW IN THE GLOBAL TRASH AFTER THE SPLIT**
    /// (`TrashScope`, her D1 ruling — a deleted take on a living block is
    /// not a note leaving the library). The brief names this as a
    /// pinned-still-true precondition of the split, and it is also the fact
    /// that decides deliverable 5: because a take is not listed here, this
    /// room is not the road that ends a take's remaining days early, and the
    /// Block History explainer must not name it. See
    /// `MobileBlockHistoryTests.theDeletedRegionPromisesNoPurgeRoadTheAppDoesNotHave`.
    @Test func theTrashRoomStillListsNoTakes() async throws {
        #expect(!TrashScope.listedKinds.contains(.take))
        #expect(!TrashScope.filterKinds.contains(.take))
        // A filter can never widen the listing past D1 — asked of the one
        // function the room's observation actually calls.
        #expect(!TrashScope.kinds(filter: .take).contains(.take))
        #expect(!TrashScope.kinds(filter: nil).contains(.take))
        #expect(!MobileTrashView.filterKinds.contains(.take))
    }

    /// **A REFUSAL BELONGS IN THE RED SLOT AND A RECEIPT DOES NOT** (§49's
    /// MINOR). A preserved original with no note recorded cannot be put back
    /// — placing needs somewhere to place — so NOTHING happens. The shipped
    /// code answered that with `putBackUnplaced`, which is the RECEIPT for a
    /// block that really was restored but had nowhere to land: it read as a
    /// success, in the red slot, over a row that had not moved.
    ///
    /// **Red on old:** restore `lastError = RecoveryCopy.putBackUnplaced` and
    /// this pin fails on the sentence.
    @Test func aPreservedOriginalWithNoNoteIsRefusedNotCongratulated() async throws {
        try await withEditorWorld { session, _ in
            let model = MobileTrashModel(session: session)
            let orphan = Queries.TrashItem(
                kind: .preservedOriginal, id: "block-1", deletedAt: "2026-08-01T00:00:00Z",
                text: "The original whole.", noteID: nil)
            await model.putBack(orphan)
            #expect(model.receipt == nil, "nothing happened, so nothing is receipted")
            #expect(model.lastError == RecoveryCopy.originalHasNoNote)
            // 13l row 26 (a JUSTIFIED pin edit — the receipt takes the home's
            // kind now, so the comparison names one): never the RECEIPT for a
            // block that really moved.
            #expect(model.lastError != RecoveryCopy.putBackUnplaced(.post),
                    "never the RECEIPT for a block that really moved")
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

    // MARK: - The harness itself (batch 4.5b — Act 1's MAJOR 4)

    /// **AN EMPTY ACCESSIBILITY TREE MUST READ AS "THE SERVER IS UNARMED",
    /// NEVER AS "THE DOOR ISN'T THERE."**
    ///
    /// The whole real-surface harness rides one machine-local, per-simulator
    /// default. Without it every walk returns nothing, so sixteen real pins
    /// fail reporting `labels were []` — indistinguishable from sixteen
    /// missing doors, and three of this round's four sub-batches were
    /// dispatched onto simulators in exactly that state. That is the
    /// green-over-nothing class inverted, and the honest response to a
    /// phantom failure is to change working code.
    ///
    /// This drives the diagnostic on the only surface that yields an empty
    /// tree on a HEALTHY machine — a genuinely empty view. The diagnostic
    /// cannot tell "empty because unarmed" from "empty because there is
    /// nothing", and this pin is the record of that trade: every real pin in
    /// this suite mounts a surface with content, so the false positive has no
    /// population, while the false NEGATIVE it prevents had sixteen.
    ///
    /// The other half — arming — is proven by the reviewer's own recipe
    /// rather than by a pin: delete the default, run, watch the phantoms;
    /// restore it, watch them pass.
    @Test func anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor() async throws {
        await withKnownIssue("the empty tree must be REPORTED as the server, not as a door") {
            await withHostedSurface(EmptyView()) { surface in
                #expect(surface.activate("A door that would exist on a real screen") == false)
            }
        }
    }

    // MARK: - Copy

    /// **ONE deletion-refusal home** (A1-18): before this batch the phone had
    /// THREE — the editor's, the Trash's and book-details' (which the shelf
    /// borrowed) — each mapping a different subset of `OperationError`, so
    /// one refused act read differently depending on the door she used, and
    /// anything none of the three had listed reached her as a raw enum dump.
    @Test func theDeletionRefusalsHaveOneHome() async throws {
        // The ACT decides the sentence, not just the error.
        #expect(DeletionRefusal.words(OperationError.lockedPost(id: "p"), act: .putBack)
            == RecoveryCopy.sealedPutBackRefusal)
        #expect(DeletionRefusal.words(OperationError.lockedPost(id: "p"), act: .delete)
            != RecoveryCopy.sealedPutBackRefusal)
        // The two surfaces' own tables now answer identically. (The Trash
        // room's side reads the shared home DIRECTLY since the 6c fix wave's
        // n5 — its one-line forward is gone, along with the byte-identical
        // twin the Archive room had grown beside it.)
        #expect(DeletionRefusal.words(OperationError.containerNotFound(id: "c"),
                                      act: .putBack)
            == MobileBookDetailsModel.refusal(.containerNotFound(id: "c")))
        #expect(DeletionRefusal.words(OperationError.readingNotFound(id: "r"),
                                      act: .putBack)
            == MobileBookDetailsModel.refusal(.readingNotFound(id: "r")))
        // The fallback is a SENTENCE that still carries the name — never a
        // bare dump, and never a swallow.
        let fallback = DeletionRefusal.words(OperationError.lockedVariant(id: "v"))
        #expect(fallback.hasSuffix("."))
        #expect(fallback.contains("lockedVariant"), "the name is kept")
        #expect(fallback != "lockedVariant(id: \"v\")", "but never bare")
        // A refusal where nothing was even attempted is its own case, and it
        // is NOT the `putBackUnplaced` RECEIPT (§49's MINOR).
        #expect(DeletionRefusal.words(RecoveryRefusal.originalHasNoNote)
            == RecoveryCopy.originalHasNoNote)
        #expect(RecoveryCopy.originalHasNoNote != RecoveryCopy.putBackUnplaced(.post))
    }

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
