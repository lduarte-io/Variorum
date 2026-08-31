//
//  MobileNoteTrayTests.swift
//  VariorumMobileTests
//
//  **THE PER-NOTE TRAY** (mobile round 2, batch 6b) — §69.3's ruled shape:
//  **Archived** (kept, forever, no clock) and **Leaving** (every clocked
//  thing of THIS note: blocks, stranded originals, and its deleted takes
//  under a collapsed disclosure, each with Put back + Delete Now).
//
//  Every door here is proven by MOUNTING the real surface and ACTIVATING the
//  real control (§15's trap (b) — the Mac shipped dead purge doors under
//  green view-model pins), and the purge confirm by asserting a real
//  `UIAlertController` and then driving its own installed action with
//  SwiftUI's write-back landed in the same turn (batch 4.5b's BLOCKER).
//

import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Seeds & probes

/// A note whose blocks are pre-minted, returning the ids the pins steer by.
@MainActor
private func seedTrayNote(
    _ session: AppSession
) async throws -> (
    postID: String, keep: String, doomed: String, fanned: String,
    chosen: String, spare: String
) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "tray world", profile: .blog)
        let keep = try ops.newBlock(in: post.id, text: "The block that stays.", at: .end)
        let doomed = try ops.newBlock(in: post.id, text: "The block that goes.", at: .end)
        let fanned = try ops.newBlock(in: post.id, text: "A fanned block.", at: .end)
        let spare = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
        try ops.autosave(spare.id, text: "the spare take", charDelta: 14)
        return (post.id, keep.block.id, doomed.block.id, fanned.block.id,
                fanned.variant.id, spare.id)
    }
}

/// **The fourth listing's fixture, and it has to come from the STORE.**
/// `Queries.PreservedOriginal` carries no public initializer, so a snapshot
/// cannot be hand-built the way `TrayItem`/`TrayTake` can — and reaching for
/// one would be a `Sources/` edit. So the rows are minted: each pass fans a
/// block, divides it (which preserves the original WHOLE and releases it),
/// then deletes BOTH halves — which is exactly the state that MOVES an
/// original onto its family's clock (her round-8b ruling).
@MainActor
private func seedCountingOriginals(
    _ session: AppSession, postID: String, count: Int
) async throws {
    for i in 0..<count {
        try await session.runner.run { ops in
            let fanned = try ops.newBlock(
                in: postID, text: "Original number \(i) here.", at: .end)
            let spare = try ops.branchVariant(fanned.block.id, from: fanned.variant.id)
            try ops.autosave(spare.id, text: "another take \(i)", charDelta: 8)
            let halves = try ops.divideDuplicating(
                fanned.block.id, displayedVariantID: fanned.variant.id, cut: 9)
            try ops.deleteBlock(halves.first.block.id)
            try ops.deleteBlock(halves.second.block.id)
        }
    }
}

@MainActor
private func blockIsPlaced(_ db: AppDatabase, _ blockID: String) async throws -> Bool {
    try await db.read { db in
        try Int.fetchOne(
            db,
            sql: """
                SELECT COUNT(*) FROM container_block
                WHERE block_id = ? AND deleted_at IS NULL
                """,
            arguments: [blockID]) ?? 0
    } > 0
}

@MainActor
private func variantIsLive(_ db: AppDatabase, _ variantID: String) async throws -> Bool {
    try await db.read { db in
        try Int.fetchOne(
            db,
            sql: "SELECT COUNT(*) FROM variant WHERE id = ? AND deleted_at IS NULL",
            arguments: [variantID]) ?? 0
    } > 0
}

@MainActor
private func purgeIntents(_ db: AppDatabase) async throws -> Int {
    try await db.read { db in
        try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM purge_intent") ?? -1
    }
}

/// Close whichever sheet is up, through its own **Done** door. That door is
/// VOICED chrome (`tokens.chromeLabel` lowercases in the Terminal register)
/// and carries no explicit accessibility label, so the handle is matched
/// case-insensitively rather than guessed at a voice.
@MainActor
private func dismissSheet<Content: View>(_ surface: HostedSurface<Content>) -> Bool {
    guard let done = surface.visibleLabels.first(where: {
        $0.caseInsensitiveCompare("Done") == .orderedSame
    }) else { return false }
    return surface.activate(done)
}

/// The tray's own segment of the blocks sheet, mounted alone — the surface
/// the sheet renders, at the size the sheet renders it.
@MainActor
private func traySurface(
    _ model: MobileNoteTrayModel, _ section: MobileNoteTraySection.Section
) -> some View {
    MobileNoteTraySection(model: model, tokens: .terminalLight, section: section)
        .padding(20)
}

@MainActor
@Suite("Mobile note tray — Archived, Leaving, and the take's only purge road")
struct MobileNoteTrayTests {
    // MARK: - Archived: kept, forever, no clock

    /// The Archived section lists this note's archived blocks, says the
    /// kept-forever promise, shows NO countdown, and its Put back really
    /// returns the block to the note.
    @Test func theArchivedSectionKeepsBlocksForeverAndPutsThemBack() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTrayNote(session)
            try await session.runner.run { [id = seed.doomed] ops in
                try ops.archiveBlock(id)
            }
            #expect(try await blockIsPlaced(db, seed.doomed) == false,
                    "archiving releases the placement")

            let tray = MobileNoteTrayModel(session: session, postID: seed.postID)
            try await withHostedSurface(traySurface(tray, .archived)) { surface in
                await surface.settle(40)
                let labels = surface.visibleLabels
                #expect(tray.archived.contains { $0.blockID == seed.doomed })
                #expect(labels.contains { $0.contains(RecoveryCopy.archivedForever) },
                        "labels were \(labels)")
                // Archive has NO clock — that is its whole promise.
                #expect(!labels.contains { $0.contains("days left") },
                        "labels were \(labels)")
                #expect(!labels.contains { $0.contains("leaves today") })

                #expect(surface.activate("\(RecoveryCopy.putBackVerb) archived block"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
            }
            #expect(try await blockIsPlaced(db, seed.doomed),
                    "Put back really returns the block to the note")
            #expect(tray.status?.isRefusal == false)
            // The receipt is the OP's own answer, never an assumption.
            #expect(tray.status?.text == RecoveryCopy.putBackWhereItWas
                        || tray.status?.text == RecoveryCopy.putBackAtEnd(.post),
                    "receipt was \(String(describing: tray.status))")
        }
    }

    // MARK: - Leaving: everything of THIS note on the clock

    /// A deleted block rows in Leaving with its countdown, and Put back
    /// returns it.
    @Test func theLeavingSectionShowsDeletedBlocksWithTheirClock() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTrayNote(session)
            try await session.runner.run { [id = seed.doomed] ops in
                try ops.deleteBlock(id)
            }

            let tray = MobileNoteTrayModel(session: session, postID: seed.postID)
            try await withHostedSurface(traySurface(tray, .leaving)) { surface in
                await surface.settle(40)
                let labels = surface.visibleLabels
                #expect(tray.deleted.contains { $0.blockID == seed.doomed })
                #expect(labels.contains { $0.contains("days left") },
                        "labels were \(labels)")
                // The other section's promise is NOT here.
                #expect(!labels.contains { $0.contains(RecoveryCopy.archivedForever) },
                        "labels were \(labels)")

                #expect(surface.activate("\(RecoveryCopy.putBackVerb) deleted block"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
            }
            #expect(try await blockIsPlaced(db, seed.doomed))
        }
    }

    /// **THE TAKES DISCLOSURE — collapsed by default, and it carries its
    /// count either way** (her G5 words: *"albeit maybe not shown by
    /// default"*; a fold that hides its own size is not an audit). Each take
    /// NAMES ITS BLOCK — her A3 discipline, at the grain the tray owes.
    @Test func deletedTakesFoldClosedAndNameTheirBlockWhenOpened() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTrayNote(session)
            try await session.runner.run { [id = seed.spare] ops in
                try ops.deleteVariant(id)
            }

            let tray = MobileNoteTrayModel(session: session, postID: seed.postID)
            try await withHostedSurface(traySurface(tray, .leaving)) { surface in
                await surface.settle(40)
                #expect(tray.takes.count == 1)
                let closed = surface.visibleLabels
                // The fold's own label carries the count, closed.
                #expect(closed.contains(RecoveryCopy.trayTakesDisclosure(1)),
                        "labels were \(closed)")
                // …and the take's doors are NOT on screen yet.
                #expect(!closed.contains(
                    "\(RecoveryCopy.putBackVerb) \(RecoveryCopy.rowKind(.take))"),
                        "labels were \(closed)")

                #expect(surface.activate(RecoveryCopy.trayTakesDisclosure(1)))
                await surface.settle(40)
                let open = surface.visibleLabels
                #expect(open.contains(
                    "\(RecoveryCopy.putBackVerb) \(RecoveryCopy.rowKind(.take))"),
                        "labels were \(open)")
                // The row names its BLOCK through the ONE naming rule.
                let handle = Queries.tocHandle(name: nil, text: "A fanned block.")
                let meta = MobileTrayRowFace.takeMeta(tray.takes[0], daysLeft: 30)
                #expect(meta.first == RecoveryCopy.trayTakeInBlock(handle),
                        "meta was \(meta)")
            }
        }
    }

    /// The take's Put back really revives it — and the receipt reads the
    /// OP's own answer, so a take ARCHIVED when it was deleted says it came
    /// back archived rather than claiming the fan (#68(b)'s exact flip).
    @Test func aDeletedTakeComesBackAndTheReceiptSaysWhere() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTrayNote(session)
            try await session.runner.run { [id = seed.spare] ops in
                try ops.deleteVariant(id)
            }
            let tray = MobileNoteTrayModel(session: session, postID: seed.postID)
            try await withHostedSurface(traySurface(tray, .leaving)) { surface in
                await surface.settle(40)
                #expect(surface.activate(RecoveryCopy.trayTakesDisclosure(1)))
                await surface.settle(40)
                #expect(surface.activate(
                    "\(RecoveryCopy.putBackVerb) \(RecoveryCopy.rowKind(.take))"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
            }
            #expect(try await variantIsLive(db, seed.spare))
            #expect(tray.status?.text == RecoveryCopy.putBackReceipt(.take),
                    "an ACTIVE take comes back into the fan and says so")

            // Now the archived road: archive it, delete it, put it back.
            try await session.runner.run { [id = seed.spare] ops in
                try ops.archiveVariant(id)
                try ops.deleteVariant(id)
            }
            let second = MobileNoteTrayModel(session: session, postID: seed.postID)
            try await withHostedSurface(traySurface(second, .leaving)) { surface in
                await surface.settle(40)
                #expect(surface.activate(RecoveryCopy.trayTakesDisclosure(1)))
                await surface.settle(40)
                #expect(surface.activate(
                    "\(RecoveryCopy.putBackVerb) \(RecoveryCopy.rowKind(.take))"))
                await surface.settle(40)
            }
            #expect(second.status?.text == RecoveryCopy.takeRestoredArchived,
                    "receipt was \(String(describing: second.status))")
        }
    }

    // MARK: - Delete Now, on a take, HERE — and it asks EVERY time

    /// **The take's ONLY purge road** (her D1 ruling took takes out of the
    /// global Trash; her G5 ruling put a Delete Now on these rows *"to keep
    /// the capability"*). It confirms EVERY time — asking is not doing — and
    /// the confirm→act edge is driven, not simulated at the model.
    @Test func aTakeCanBeEndedEarlyHereAndItAsksEveryTime() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTrayNote(session)
            // Two deleted takes, so "every time" has a second row to prove it.
            let (spareTwo, _) = try await session.runner.run { [id = seed.fanned] ops -> (String, Bool) in
                let another = try ops.branchVariant(id, from: seed.spare)
                try ops.autosave(another.id, text: "a third take", charDelta: 12)
                return (another.id, true)
            }
            try await session.runner.run { [one = seed.spare, two = spareTwo] ops in
                try ops.deleteVariant(one)
                try ops.deleteVariant(two)
            }

            let tray = MobileNoteTrayModel(session: session, postID: seed.postID)
            try await withHostedSurface(traySurface(tray, .leaving)) { surface in
                await surface.settle(40)
                #expect(surface.activate(RecoveryCopy.trayTakesDisclosure(2)))
                await surface.settle(40)

                #expect(surface.activate(
                    "\(RecoveryCopy.deleteNowVerb) \(RecoveryCopy.rowKind(.take))"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                let alert = try #require(surface.presentedAlert,
                                         "Delete Now's confirm must actually present")
                #expect(alert.title == RecoveryCopy.deleteNowVerb)
                #expect(alert.message == RecoveryCopy.deleteNowConfirm(.take))
                #expect(alert.message?.contains("no putting it back") == true)
                // Asking is not doing.
                #expect(try await purgeIntents(db) == 0)

                #expect(surface.tapAlertAction(
                    RecoveryCopy.deleteNowVerb,
                    writeBack: { tray.purgeConfirmPresented = false }),
                        "the confirm's real action must be drivable")
                await surface.settle(40)
                #expect(try await purgeIntents(db) == 1, "one intent per thing purged")
                #expect(tray.status?.text.contains("gone from the app now") == true)

                // **EVERY TIME**: the second row asks again — there is no
                // don't-ask state anywhere in the app and none may be added.
                await surface.settle(40)
                #expect(surface.activate(
                    "\(RecoveryCopy.deleteNowVerb) \(RecoveryCopy.rowKind(.take))"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(surface.presentedAlert != nil,
                        "the second purge asks again — confirm-every-time")
            }
        }
    }

    /// **THE CONFIRM, DRIVEN IN THE REAL COMPOSITION** — the tray section
    /// inside `MobileBlockListSheet`'s `ScrollView` → `LazyVStack`, which is
    /// where production renders it. Every other purge pin here mounts the
    /// section ALONE, and an `.alert` attached to a view inside a lazy
    /// container is precisely the shape this app has been burned by: §15's
    /// trap (b), and batch 4.5b's BLOCKER, which found dead confirm doors at
    /// FIVE hosts under green view-model pins.
    ///
    /// **NEW COVERAGE, labelled honestly: it passes on the shipped tree**
    /// (the 6b cold review wrote it, ran it, and filed NIT 3 as a coverage
    /// gap rather than a defect). Its value is not a red — it is that the one
    /// composition this codebase's own history says to pin was pinned nowhere.
    @Test func theDeleteNowConfirmDrivesInsideTheRealBlocksSheet() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTrayNote(session)
            try await session.runner.run { [id = seed.spare] ops in
                try ops.deleteVariant(id)
            }
            let list = MobileBlockListModel(session: session, postID: seed.postID)
            let tray = MobileNoteTrayModel(session: session, postID: seed.postID)
            try await withHostedSurface(
                MobileBlockListSheet(
                    model: list, tokens: .terminalLight, tray: tray, onJump: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(surface.activate(MobileBlocksSegment.leaving.word),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(surface.activate(RecoveryCopy.trayTakesDisclosure(1)),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(surface.activate(
                    "\(RecoveryCopy.deleteNowVerb) \(RecoveryCopy.rowKind(.take))"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                let alert = try #require(
                    surface.presentedAlert,
                    "the confirm must present from inside the real sheet, not only alone")
                #expect(alert.title == RecoveryCopy.deleteNowVerb)
                #expect(try await purgeIntents(db) == 0, "asking is not doing")

                #expect(surface.tapAlertAction(
                    RecoveryCopy.deleteNowVerb,
                    writeBack: { tray.purgeConfirmPresented = false }),
                        "the confirm's real action must be drivable here too")
                await surface.settle(40)
                #expect(try await purgeIntents(db) == 1, "one intent per thing purged")
            }
        }
    }

    /// **THE PURGE DOOR EXISTS ON THE LEAVING SECTION AND NOWHERE ELSE IN A
    /// NOTE** — the evolved in-trash-only rule (purge doors live on TRASH
    /// SURFACES; the Leaving section is one because every row in it is
    /// already deleted and already counting down). The other two segments of
    /// the same sheet must never grow one.
    @Test func thePurgeDoorIsOnLeavingAndNowhereElseInThisNote() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTrayNote(session)
            try await session.runner.run { [a = seed.doomed, s = seed.spare] ops in
                try ops.archiveBlock(a)
                try ops.deleteVariant(s)
            }
            let tray = MobileNoteTrayModel(session: session, postID: seed.postID)

            // The ARCHIVED segment: populated, and carrying no purge door.
            try await withHostedSurface(traySurface(tray, .archived)) { surface in
                await surface.settle(40)
                #expect(!tray.archived.isEmpty, "asserted over a POPULATED screen")
                #expect(!surface.visibleLabels.contains {
                    $0.contains(RecoveryCopy.deleteNowVerb)
                }, "labels were \(surface.visibleLabels)")
                #expect(!surface.visibleLabels.contains {
                    $0.contains(RecoveryCopy.emptyTrashVerb)
                })
            }

            // The IN-THE-NOTE listing: the block list itself, never a purge.
            let list = MobileBlockListModel(session: session, postID: seed.postID)
            let leaving = MobileNoteTrayModel(session: session, postID: seed.postID)
            try await withHostedSurface(
                MobileBlockListSheet(
                    model: list, tokens: .terminalLight, tray: leaving, onJump: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(!list.rows.isEmpty, "asserted over a POPULATED screen")
                #expect(!surface.visibleLabels.contains {
                    $0.contains(RecoveryCopy.deleteNowVerb)
                }, "labels were \(surface.visibleLabels)")
            }
        }
    }

    /// **TAKES STILL NEVER ROW IN THE GLOBAL TRASH** (her D1 ruling). This
    /// batch gave a take a purge door for the first time on this phone, and
    /// this is the belt: the door is note-scoped and the global listing is
    /// unchanged.
    @Test func takesStillNeverRowInTheGlobalTrash() async throws {
        #expect(!TrashScope.listedKinds.contains(.take))
        #expect(!TrashScope.filterKinds.contains(.take))
        #expect(!TrashScope.kinds(filter: .take).contains(.take))
        #expect(!MobileTrashView.filterKinds.contains(.take))
        try await withEditorWorld { session, db in
            let seed = try await seedTrayNote(session)
            try await session.runner.run { [id = seed.spare] ops in
                try ops.deleteVariant(id)
            }
            let rows = try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now, kinds: TrashScope.listedKinds)
            }
            #expect(!rows.contains { $0.id == seed.spare },
                    "a deleted take's homes are its block's History and this note's tray")
        }
    }

    // MARK: - The unclocked original is LINEAGE's, not the tray's

    /// **NO UNCLOCKED-ORIGINALS SECTION** (her G5 ruling: *the tray audits
    /// what is LEAVING; lineage holds what is KEPT*). A divide's preserved
    /// original with a live successor is NOT here; when its whole family
    /// dies it MOVES into Leaving, wearing the family's clock and the reason.
    @Test func anOriginalJoinsLeavingOnlyWhenItsFamilyStartsCountingDown() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTrayNote(session)
            // Divide the FANNED block: its original is preserved whole.
            let halves = try await session.runner.run {
                [id = seed.fanned, displayed = seed.chosen] ops in
                try ops.divideDuplicating(id, displayedVariantID: displayed, cut: 8)
            }

            let tray = MobileNoteTrayModel(session: session, postID: seed.postID)
            try await withHostedSurface(traySurface(tray, .leaving)) { surface in
                await surface.settle(40)
                #expect(tray.stranded.isEmpty,
                        "an original with live successors is lineage's, not the tray's")
                #expect(!surface.visibleLabels.contains {
                    $0.contains(RecoveryCopy.goesWithItsFamily)
                }, "labels were \(surface.visibleLabels)")
            }

            // Kill the whole family: the original MOVES onto its clock.
            try await session.runner.run { ops in
                try ops.deleteBlock(halves.first.block.id)
                try ops.deleteBlock(halves.second.block.id)
            }
            let after = MobileNoteTrayModel(session: session, postID: seed.postID)
            try await withHostedSurface(traySurface(after, .leaving)) { surface in
                await surface.settle(40)
                #expect(after.stranded.contains { $0.blockID == seed.fanned },
                        "stranded were \(after.stranded.map(\.blockID))")
                #expect(surface.visibleLabels.contains {
                    $0.contains(RecoveryCopy.goesWithItsFamily)
                }, "labels were \(surface.visibleLabels)")
                #expect(surface.activate(
                    "\(RecoveryCopy.putBackVerb) preserved original"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(after.status?.isRefusal == false,
                        "status was \(String(describing: after.status))")
            }
        }
    }

    // MARK: - P1: every listing is windowed and says so

    /// The window+probe discipline, on all four listings — bounded IN SQL at
    /// `window + 1` and truncated in ONE place (`TrashListing.windowed`), with
    /// the FILTERLESS rooms' shared marker (the tray has no filter to narrow).
    ///
    /// **The FOURTH listing joins this pin at the 6b fix wave** (the cold
    /// review's MINOR 1). It shipped windowed nowhere and marked nowhere —
    /// and this pin's own `Snapshot` never populated `originals`, so the
    /// listing was not merely unasserted, it was absent from the fixture and
    /// the docstring's "all four" was a claim no assertion carried. Both
    /// halves are here now: the windowing at `adopt`, and the marker on the
    /// screen.
    @Test func everyTrayListingIsWindowedAndSaysSo() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedTrayNote(session)
            // Three originals whose whole families are counting down.
            try await seedCountingOriginals(session, postID: seed.postID, count: 3)
            let originals = try await db.read { [postID = seed.postID] db in
                try Queries.preservedOriginals(db, postID: postID, limit: 201)
            }
            let fates = try await db.read { [postID = seed.postID, now = session.now] db in
                try Queries.originFamilyClocks(db, postID: postID, now: now)
            }
            #expect(originals.count == 3, "originals were \(originals.map(\.blockID))")

            let tray = MobileNoteTrayModel(session: session, postID: seed.postID, window: 2)
            let item = { (id: String) in
                Queries.TrayItem(blockID: id, deletedAt: "2026-08-31T00:00:00Z", text: id)
            }
            tray.adopt(MobileNoteTrayModel.Snapshot(
                deleted: [item("d1"), item("d2"), item("d3")],
                archived: [item("a1"), item("a2"), item("a3")],
                originals: originals,
                strandedFates: fates,
                takes: [
                    Queries.TrayTake(
                        variantID: "t1", blockID: "b", deletedAt: "2026-08-31T00:00:00Z"),
                    Queries.TrayTake(
                        variantID: "t2", blockID: "b", deletedAt: "2026-08-31T00:00:00Z"),
                    Queries.TrayTake(
                        variantID: "t3", blockID: "b", deletedAt: "2026-08-31T00:00:00Z"),
                ]))
            #expect(tray.deleted.count == 2 && tray.deletedTruncated)
            #expect(tray.archived.count == 2 && tray.archivedTruncated)
            #expect(tray.takes.count == 2 && tray.takesTruncated)
            #expect(tray.stranded.count == 2 && tray.strandedTruncated,
                    "stranded was \(tray.stranded.count), truncated \(tray.strandedTruncated)")

            // …and the marker RENDERS for it, beside the deleted one. Over
            // this note's real read BOTH listings overflow a window of two
            // (six deleted halves, three counting originals), so the shared
            // filterless sentence must appear TWICE — which is the assertion
            // an unwindowed `stranded` cannot pass.
            let rendered = MobileNoteTrayModel(session: session, postID: seed.postID, window: 2)
            try await withHostedSurface(traySurface(rendered, .leaving)) { surface in
                await surface.settle(40)
                #expect(rendered.deletedTruncated && rendered.strandedTruncated,
                        "deleted \(rendered.deleted.count) / stranded \(rendered.stranded.count)")
                let marker = MobileRoomListing.truncationMarker(shown: 2)
                #expect(surface.visibleLabels.filter { $0 == marker }.count == 2,
                        "labels were \(surface.visibleLabels)")
            }
        }
    }

    /// …and the marker RENDERS, over rows the observation really delivered
    /// (the `adopt` pin above proves the windowing; this proves the sentence
    /// reaches the screen — the two halves of the Phase 10 discipline).
    @Test func theTruncationMarkerRendersAndIsTheFilterlessSentence() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTrayNote(session)
            try await session.runner.run { [a = seed.keep, b = seed.doomed, c = seed.fanned] ops in
                try ops.archiveBlock(a)
                try ops.archiveBlock(b)
                try ops.archiveBlock(c)
            }
            let tray = MobileNoteTrayModel(session: session, postID: seed.postID, window: 2)
            try await withHostedSurface(traySurface(tray, .archived)) { surface in
                await surface.settle(40)
                #expect(tray.archivedTruncated, "three rows, a window of two")
                #expect(surface.visibleLabels.contains(
                    MobileRoomListing.truncationMarker(shown: 2)),
                        "labels were \(surface.visibleLabels)")
                // The FILTERLESS sentence — this section has no filter to
                // narrow, so it must not offer narrowing one.
                #expect(!surface.visibleLabels.contains { $0.contains("narrow the filter") })
            }
        }
    }

    // MARK: - The two sections never blur each other's promise

    /// After a split, *"each section shows only its own"* is the form of the
    /// promise a screen can actually break — the Two-rooms pin's shape, one
    /// level down, inside a note.
    @Test func theTwoSectionsCarryOnlyTheirOwnPromises() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTrayNote(session)
            try await session.runner.run { [a = seed.keep, d = seed.doomed] ops in
                try ops.archiveBlock(a)
                try ops.deleteBlock(d)
            }
            let tray = MobileNoteTrayModel(session: session, postID: seed.postID)

            try await withHostedSurface(traySurface(tray, .archived)) { surface in
                await surface.settle(40)
                let labels = surface.visibleLabels
                #expect(labels.contains { $0.contains(RecoveryCopy.archivedForever) },
                        "labels were \(labels)")
                #expect(!labels.contains { $0.contains("\(TrashWindow.days)-day clock") },
                        "labels were \(labels)")
                #expect(!labels.contains { $0.contains("days left") })
            }
            try await withHostedSurface(traySurface(tray, .leaving)) { surface in
                await surface.settle(40)
                let labels = surface.visibleLabels
                #expect(labels.contains { $0.contains("\(TrashWindow.days)-day clock") },
                        "labels were \(labels)")
                #expect(!labels.contains { $0.contains(RecoveryCopy.archivedForever) },
                        "labels were \(labels)")
            }
        }
    }

    // MARK: - The empty states speak in the HOME's own noun

    @Test func anEmptyTraySaysSoInTheHomesOwnNoun() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTrayNote(session)
            let tray = MobileNoteTrayModel(session: session, postID: seed.postID)
            try await withHostedSurface(traySurface(tray, .archived)) { surface in
                await surface.settle(40)
                #expect(surface.visibleLabels.contains(
                    RecoveryCopy.trayNothingArchived(.post)),
                        "labels were \(surface.visibleLabels)")
            }
            try await withHostedSurface(traySurface(tray, .leaving)) { surface in
                await surface.settle(40)
                #expect(surface.visibleLabels.contains(
                    RecoveryCopy.trayNothingLeaving(.post)),
                        "labels were \(surface.visibleLabels)")
            }
        }
    }

    // MARK: - The face's words are the SHARED vocabulary, never new ones

    /// The whole tray's sentences come from `Shared/RecoveryCopy.swift`'s tray
    /// family — the same home the Mac's panel reads through `TrayPath` — so
    /// the two platforms cannot describe one 30-day clock two ways. The row
    /// faces are COMPOSED from shared primitives (the hoist they are owed is
    /// recorded in the batch record's residue list), and this pin asserts the
    /// composition rather than the literal, so a drift would have to change a
    /// shared sentence to happen.
    @Test func everyTraySentenceIsTheSharedOne() async throws {
        #expect(MobileNoteTrayModel.archivedSection == RecoveryCopy.trayArchivedSection)
        #expect(MobileNoteTrayModel.leavingSection == RecoveryCopy.trayLeavingSection)
        try await withEditorWorld { session, _ in
            let tray = MobileNoteTrayModel(session: session, postID: "x")
            #expect(tray.leavingExplainer == RecoveryCopy.trayLeavingExplainer(.post))
            #expect(tray.nothingArchived == RecoveryCopy.trayNothingArchived(.post))
            #expect(tray.nothingLeaving == RecoveryCopy.trayNothingLeaving(.post))
        }
        // The row faces compose shared pieces.
        let take = Queries.TrayTake(
            variantID: "v", blockID: "b", deletedAt: "2026-08-31T00:00:00Z",
            label: nil, text: "", blockName: "the block", blockText: nil)
        #expect(MobileTrayRowFace.takeLabel(take) == RecoveryCopy.emptyTakeLabel,
                "an empty take says TAKE, never block")
        #expect(MobileTrayRowFace.takeMeta(take, daysLeft: 3).contains(
            RecoveryCopy.daysLeftLabel(3)))
        #expect(MobileTrayRowFace.takeMeta(take, daysLeft: nil).contains(
            RecoveryCopy.trayTakeInBlock("the block")))
        #expect(MobileTrayRowFace.meta(
            note: nil, stamp: nil, when: "archived", clock: nil, forever: true)
            == [RecoveryCopy.archivedForever])
        // The clock, or the promise of no clock — one of the two, never both.
        #expect(MobileTrayRowFace.meta(
            note: nil, stamp: nil, when: "deleted", clock: 4, forever: false)
            == [RecoveryCopy.daysLeftLabel(4)])
    }

    // MARK: - The door: the blocks chip's sheet, in three segments (Q8)

    /// **THE DOOR** — the sheet's segment strip really switches what the
    /// sheet shows, and each segment's own promise arrives with it.
    @Test func theBlocksSheetCarriesTheTrayInThreeSegments() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTrayNote(session)
            try await session.runner.run { [a = seed.keep, d = seed.doomed] ops in
                try ops.archiveBlock(a)
                try ops.deleteBlock(d)
            }
            let list = MobileBlockListModel(session: session, postID: seed.postID)
            let tray = MobileNoteTrayModel(session: session, postID: seed.postID)
            try await withHostedSurface(
                MobileBlockListSheet(
                    model: list, tokens: .terminalLight, tray: tray, onJump: { _ in })
            ) { surface in
                await surface.settle(40)
                let strip = surface.visibleLabels
                for option in MobileBlocksSegment.allCases {
                    #expect(strip.contains(option.word), "labels were \(strip)")
                }
                // **It opens on the note's own blocks** — the surviving
                // block is listed and the ARCHIVED one is not.
                //
                // (This pair replaces a line that could not fail: a
                // `contains { … == false }` over a label array that always
                // holds the three segment words was true for any
                // implementation — the 6b cold review's NIT 1.)
                #expect(strip.contains { $0.contains("A fanned block") },
                        "labels were \(strip)")
                #expect(!strip.contains { $0.contains("The block that stays") },
                        "labels were \(strip)")
                #expect(!strip.contains { $0.contains(RecoveryCopy.archivedForever) })

                #expect(surface.activate(MobileBlocksSegment.archived.word))
                await surface.settle(40)
                #expect(surface.visibleLabels.contains {
                    $0.contains(RecoveryCopy.archivedForever)
                }, "labels were \(surface.visibleLabels)")

                #expect(surface.activate(MobileBlocksSegment.leaving.word))
                await surface.settle(40)
                #expect(surface.visibleLabels.contains {
                    $0.contains("\(TrashWindow.days)-day clock")
                }, "labels were \(surface.visibleLabels)")
            }
        }
    }

    /// The sheet WITHOUT a tray is byte-unchanged: no strip, and the block
    /// list exactly as it shipped (P-2 — a strip with nowhere to go).
    @Test func theSheetWithoutATrayRendersNoSegmentStrip() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTrayNote(session)
            let list = MobileBlockListModel(session: session, postID: seed.postID)
            try await withHostedSurface(
                MobileBlockListSheet(model: list, tokens: .terminalLight, onJump: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(!list.rows.isEmpty, "asserted over a POPULATED screen")
                for option in MobileBlocksSegment.allCases {
                    #expect(!surface.visibleLabels.contains(option.word),
                            "labels were \(surface.visibleLabels)")
                }
            }
        }
    }

    /// **THE WHOLE ROAD, THROUGH THE REAL SCREEN** — the masthead's blocks
    /// chip opens the real sheet and the tray is in it. A pin that mounts the
    /// section alone proves the section; this proves the DOOR.
    @Test func theBlocksChipOnTheRealScreenOpensTheTray() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedTrayNote(session)
            try await session.runner.run { [id = seed.doomed] ops in
                try ops.archiveBlock(id)
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            try await withHostedSurface(
                MobileWriteScreen(session: session, postID: seed.postID, editor: model)
            ) { surface in
                await surface.settle(40)
                #expect(surface.activate("Blocks"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(60)
                #expect(surface.visibleLabels.contains(MobileBlocksSegment.archived.word),
                        "labels were \(surface.visibleLabels)")
                #expect(surface.activate(MobileBlocksSegment.archived.word))
                await surface.settle(40)
                #expect(surface.visibleLabels.contains {
                    $0.contains(RecoveryCopy.archivedForever)
                }, "labels were \(surface.visibleLabels)")
            }
        }
    }

    /// **THE TRAY'S PUT BACK HEALS THE MASTHEAD'S ⚠** (the 6b cold review's
    /// MINOR 2). The lens chip's fallback marker reads the lens model's
    /// `rows`, which only `refresh()` writes — and its one external caller
    /// was the lens sheet's own `.task`. This batch then shipped a door that
    /// makes a dangling pick live again without touching a lens, so the chip
    /// could keep announcing a fallback that no longer existed, to VoiceOver
    /// as well as to the eye, until she happened to reopen the sheet.
    ///
    /// Driven end to end through the REAL screen and its REAL sheets: look
    /// through the lens, close its sheet, see the marker; open blocks ▸
    /// leaving, Put the take back, close that sheet; the marker must be gone
    /// **without reopening the lens sheet**.
    @Test func puttingATakeBackClearsTheLensChipsFallbackMarker() async throws {
        try await withEditorWorld { session, _ in
            // A lens whose ONE pick is a take this note then deletes.
            let (postID, lensName) = try await session.runner.run { ops -> (String, String) in
                let post = try ops.createPost(title: "lens tray world", profile: .blog)
                _ = try ops.newBlock(in: post.id, text: "Chosen words here.", at: .end)
                let b = try ops.newBlock(in: post.id, text: "A second block.", at: .end)
                let spare = try ops.branchVariant(b.block.id, from: b.variant.id)
                try ops.autosave(spare.id, text: "The other reading.", charDelta: 5)
                let lens = try ops.createLens(post: post.id, name: "half gone")
                try ops.setLensChoice(lens: lens.id, block: b.block.id, variant: spare.id)
                try ops.deleteVariant(spare.id)
                return (post.id, lens.name)
            }
            let (editor, _) = makeEditor(session, postID: postID)
            await editor.loadOnce()
            try await withHostedSurface(
                MobileWriteScreen(session: session, postID: postID, editor: editor)
            ) { surface in
                await surface.settle(60)
                // Calm before a lens drives the page.
                #expect(surface.visibleLabels.contains("Lenses"),
                        "labels were \(surface.visibleLabels)")

                // Look through it: the pick is deleted, so the chip says so.
                #expect(surface.activate("Lenses"))
                await surface.settle(60)
                #expect(surface.activate(lensName),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(60)
                #expect(dismissSheet(surface), "labels were \(surface.visibleLabels)")
                await surface.settle(60)
                #expect(surface.visibleLabels.contains(
                    MobileWriteScreen.lensFallbackChipLabel),
                        "labels were \(surface.visibleLabels)")

                // Put the take back, through the tray this batch shipped.
                #expect(surface.activate("Blocks"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(60)
                #expect(surface.activate(MobileBlocksSegment.leaving.word),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(surface.activate(RecoveryCopy.trayTakesDisclosure(1)),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(surface.activate(
                    "\(RecoveryCopy.putBackVerb) \(RecoveryCopy.rowKind(.take))"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(dismissSheet(surface), "labels were \(surface.visibleLabels)")
                await surface.settle(60)

                // The marker is gone, and the chip is honest again.
                #expect(!surface.visibleLabels.contains(
                    MobileWriteScreen.lensFallbackChipLabel),
                        "labels were \(surface.visibleLabels)")
                #expect(surface.visibleLabels.contains("Lenses"),
                        "labels were \(surface.visibleLabels)")
            }
        }
    }

    /// **The road's NAME is composed from the door's own two words**, so a
    /// sentence pointing at this section can never name a door that has been
    /// renamed (the flip at `MobileBlockHistoryController.deletedExplainer`
    /// rides this).
    @Test func theRoadPhrasesAreComposedFromTheDoorNotWrittenAgain() {
        #expect(MobileNoteTrayModel.roadPhrase(to: .leaving)
                == "\(MobileBlockListModel.chipWord) \u{25B8} \(MobileBlocksSegment.leaving.word)")
        #expect(MobileNoteTrayModel.purgeRoadPhrase.contains(
            MobileBlocksSegment.leaving.word))
        #expect(MobileNoteTrayModel.putBackRoadPhrase.contains(
            MobileNoteTrayModel.roadPhrase(to: .leaving)))
        #expect(MobileNoteTrayModel.archivedRoadPhrase.contains(
            MobileBlocksSegment.archived.word))
    }
}
