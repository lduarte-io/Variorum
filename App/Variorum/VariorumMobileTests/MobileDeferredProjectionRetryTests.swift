//
//  MobileDeferredProjectionRetryTests.swift
//  VariorumMobileTests
//
//  **18m U2, rider F-2 — the phone twin of 17b P36: a failed re-read keeps
//  the marker.**
//
//  THE MECHANISM (the Mac's, line for line — its pin is
//  `DeferredProjectionRetryTests`): `MobileEditorViewModel.applyPendingIfClean`
//  nils `pendingProjection` before spawning its re-read task (deliberately —
//  the deferred value was fetched before the flush that just landed, so it
//  must never be applied as-is). Its failure arm was a bare `return`, while
//  the two guards immediately below it BOTH put a value back. So a thrown
//  read dropped the deferred marker with nothing to re-arm it, and an
//  externally-changed projection — a sync-arrived conflict take, a
//  chosen-take flip made on another surface — waited on the next
//  ValueObservation delivery, which only fires on a FURTHER store change.
//  17b P36 fixed the Mac's copy; the phone's was outside that entry's scope
//  (the 18m U2 band map, finding F-2).
//
//  THE READ CAN GENUINELY THROW: the ambient database is a BOUND view and a
//  lock closes the pool (`StoreLockedError` — 13p Batch 2), which is the
//  state this suite stages by locking the binding under the model's feet.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import VariorumMobile

@Suite("18m U2 F-2 — a deferred projection survives a failed re-read (the phone)", .serialized)
@MainActor
struct MobileDeferredProjectionRetryTests {
    /// A session over a REBINDABLE store, plus the binding that can lock it.
    private func world() throws -> (session: AppSession, binding: StoreBinding, postID: String) {
        let raw = try AppDatabase.inMemory()
        let (view, binding) = raw.asRebindable()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try withDependencies {
            $0.database = view
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
        } operation: { @MainActor in
            let session = AppSession(database: view)
            let post = try session.operations.createPost(title: "T")
            _ = try session.operations.newBlock(in: post.id, text: "Alpha.")
            return (session, binding, post.id)
        }
    }

    private func deferredProjection(_ session: AppSession, postID: String) throws
        -> [Queries.RenderedBlock] {
        try session.database.read { try Queries.takesProjection($0, post: postID).slots }
    }

    @Test func theMarkerSurvivesAReadThatThrows() async throws {
        let w = try world()
        let model = MobileEditorViewModel(session: w.session, postID: w.postID)
        // No storage is attached, so this DEFERS rather than rendering —
        // the same marker the dirty-buffer and in-flight roads set.
        model.applyProjection(try deferredProjection(w.session, postID: w.postID))
        #expect(model.hasDeferredProjection, "the premise: a projection is waiting")

        // The store closes under it — a lock, the finding's own trigger.
        _ = w.binding.lock()
        model.applyPendingIfClean()
        #expect(!model.hasDeferredProjection,
                "the door really ran: it clears the marker before the re-read, by design")

        // Let the re-read task run and fail.
        for _ in 0..<200 {
            if model.hasDeferredProjection { break }
            try? await Task.sleep(for: .milliseconds(5))
        }
        #expect(model.hasDeferredProjection,
                "a thrown re-read restores the marker, so the next clean moment retries")
    }

    /// The guard against over-firing: with the store OPEN the door runs its
    /// re-read and the model never lands in a refusing state — the fix
    /// touches one failure arm and nothing else.
    @Test func theOrdinaryRoadIsUnchangedWhenTheStoreIsOpen() async throws {
        let w = try world()
        let model = MobileEditorViewModel(session: w.session, postID: w.postID)
        model.applyProjection(try deferredProjection(w.session, postID: w.postID))

        model.applyPendingIfClean()
        try? await Task.sleep(for: .milliseconds(50))

        #expect(model.statusMessage == nil, "no refusal, no observation error")
    }
}
