//
//  CompareOutlineMintColumnTests.swift
//  VariorumTests
//
//  **VX-740 — one "make outline note" press, ONE Compare column** (VX-770
//  batch 4; the mechanism traced at the vx-736 ladder, round 1, and re-located
//  at HEAD in the run record's BATCH 4 RECORD; the fix is the orchestrator's
//  P-770-1, PROVISIONAL: the auto-fill's seat stands, the resume yields).
//
//  THE RACE: `makeOutlinePost` suspends on the mint. The board's store
//  observation hears the commit and can deliver the fresh projection — whose
//  `versionPeers` now names the outline — BEFORE the act resumes; `adopt`'s
//  auto-fill seats it in the empty first slot. The resumed act then found no
//  empty slot and APPENDED a second slot holding the same note.
//
//  THE STAGING (deterministic, no product seam): the session's undo stack
//  announces the mint's registration on the runner's thread — after the
//  mint's write has committed, before `run` returns. The pin's observer hops
//  to main synchronously there (main is idle: the test is awaiting) and adopts
//  a fresh read of the board's projection — the observation's delivery, landed
//  where the app's race lands it. Then the REAL `makeOutlinePost` resumes.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withOutlineWorld(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> Void
) async throws {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 740))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// A two-block draft with NO version peer — Compare opens it on the offer
/// band, nothing auto-filled (the board her J5 walk pressed the door on).
@MainActor
private func makeDraft(_ session: AppSession) async throws -> String {
    try await session.runner.run { ops in
        let draft = try ops.createPost(title: "the draft")
        _ = try ops.newBlock(in: draft.id, text: "The opening paragraph. It goes on a while.", at: .end)
        _ = try ops.newBlock(in: draft.id, text: "The second paragraph. Shorter.", at: .end)
        return draft.id
    }
}

@MainActor
private func freshProjection(
    _ db: AppDatabase, anchor: String, peers: [String]
) throws -> CompareProjection {
    try db.read { try CompareViewModel.read($0, anchor: anchor, peers: peers) }
}

/// What the store observation would deliver at the mint's commit: one fresh
/// read of the board's projection for the peers it holds AT THAT MOMENT,
/// adopted on main — staged once, inside the mint's own registration (after
/// its write commits, before `run` returns).
private final class MidMintDelivery: Sendable {
    /// Set once the staged delivery ran.
    let ran = LockIsolated(false)
    /// The slots right after the staged adoption: (slot id, note id).
    let slotsAfterDelivery = LockIsolated<[(String, String?)]>([])
    let failure = LockIsolated<String?>(nil)

    @MainActor
    func arm(on session: AppSession, model: CompareViewModel, db: AppDatabase, anchor: String) {
        session.undoStack.setChangeObserver { [self] in
            guard !ran.value else { return }
            ran.setValue(true)
            DispatchQueue.main.sync {
                MainActor.assumeIsolated {
                    do {
                        let peers = model.peerSlots.compactMap(\.postID)
                        model.adopt(try freshProjection(db, anchor: anchor, peers: peers))
                        let slots: [(String, String?)] = model.peerSlots.map { ($0.id, $0.postID) }
                        slotsAfterDelivery.setValue(slots)
                    } catch {
                        failure.setValue("\(error)")
                    }
                }
            }
        }
    }
}

@MainActor
@Suite("VX-740 — one outline mint opens one Compare column (P-770-1)", .serialized)
struct CompareOutlineMintColumnTests {
    /// **RED ON OLD — her J5 sighting.** The observation's delivery lands
    /// between the mint and the resume; the auto-fill seats the fresh outline;
    /// the old resume appended a second column holding the same note. P-770-1:
    /// ONE column, the note where the auto-fill seated it.
    @Test func anOutlineTheAutoFillSeatsWhileTheMintIsInFlightOpensOneColumn() async throws {
        try await withOutlineWorld { session, db in
            let draft = try await makeDraft(session)
            let model = CompareViewModel(session: session, anchorPostID: draft)
            model.adopt(try freshProjection(db, anchor: draft, peers: []))
            #expect(model.noPeerIsOpen, "fixture: no version peer, so the board opens on the offer band")

            let delivery = MidMintDelivery()
            delivery.arm(on: session, model: model, db: db, anchor: draft)
            defer { session.undoStack.setChangeObserver(nil) }
            await model.makeOutlinePost()

            #expect(delivery.failure.value == nil, "the staged delivery read: \(delivery.failure.value ?? "")")
            let outline = try #require(
                try freshProjection(db, anchor: draft, peers: []).versionPeers.first,
                "the mint landed: the outline is the draft's version peer")
            // The premise: the staging reproduced the race's state — the
            // delivery ran mid-act and the AUTO-FILL seated the outline.
            #expect(delivery.ran.value, "premise: the delivery ran between the mint and the resume")
            let seatedByAutoFill = delivery.slotsAfterDelivery.value
            #expect(seatedByAutoFill.map(\.1) == [outline],
                    "premise: the auto-fill seated the fresh outline before the act resumed (\(seatedByAutoFill))")

            let columns = model.peerSlots.compactMap(\.postID)
            #expect(columns == [outline],
                    "one press, one column — the outline opens once (columns: \(columns))")
            #expect(model.peerSlots.count == 1, "no second slot was appended (\(model.peerSlots.count) slots)")
            #expect(model.peerSlots.first?.id == seatedByAutoFill.first?.0,
                    "the auto-fill's seat stands — the same slot, not a re-seat (P-770-1)")
        }
    }

    /// GUARD (green on both trees): the ordinary order — nothing delivers
    /// mid-act — seats the outline in the empty first slot, once.
    @Test func theOrdinaryOrderSeatsTheOutlineInTheEmptySlot() async throws {
        try await withOutlineWorld { session, db in
            let draft = try await makeDraft(session)
            let model = CompareViewModel(session: session, anchorPostID: draft)
            model.adopt(try freshProjection(db, anchor: draft, peers: []))
            await model.makeOutlinePost()
            let outline = try #require(try freshProjection(db, anchor: draft, peers: []).versionPeers.first)
            #expect(model.peerSlots.compactMap(\.postID) == [outline])
            #expect(model.peerSlots.count == 1)
        }
    }

    /// GUARD (green on both trees): a board already showing ANOTHER note, the
    /// same mid-act delivery staged — the auto-fill has already fired, so it
    /// seats nothing, and the resume opens the outline in a column of its own.
    /// The dedupe yields only to the SAME note, never to an occupied slot.
    @Test func anOutlineMintedBesideAnOpenNoteStillOpensItsOwnColumn() async throws {
        try await withOutlineWorld { session, db in
            let draft = try await makeDraft(session)
            let twin = try await session.runner.run { ops in
                try ops.duplicateAsVersion(draft).post.id
            }
            let model = CompareViewModel(session: session, anchorPostID: draft)
            model.adopt(try freshProjection(db, anchor: draft, peers: []))
            #expect(model.peerSlots.compactMap(\.postID) == [twin],
                    "fixture: the auto-fill seated the draft's version peer")

            let delivery = MidMintDelivery()
            delivery.arm(on: session, model: model, db: db, anchor: draft)
            defer { session.undoStack.setChangeObserver(nil) }
            await model.makeOutlinePost()

            #expect(delivery.ran.value, "premise: the delivery ran between the mint and the resume")
            let peers = try freshProjection(db, anchor: draft, peers: []).versionPeers
            let outline = try #require(peers.first { $0 != twin }, "the mint landed")
            #expect(model.peerSlots.compactMap(\.postID) == [twin, outline],
                    "the twin's column stays; the outline opens beside it")
        }
    }
}
