//
//  MacWillLockTests.swift
//  VariorumTests
//
//  Pre-13u Act 9 (17a P3) — the Mac lock teardown's red-on-old pin. The
//  old `onWillLock` ran only the quit-finalize registry + services.stop():
//  the registry's closures flush AUTOSAVES, and the open tail has no
//  variant, so a paragraph still in the tail (the whole entry, under
//  `one_block` segmentation) was ON SCREEN, IN NO ROW when the lobby
//  replaced the view. `macWillLock` mirrors the quit door: the active
//  editor's full `finalizeWork` first (tail crystallized, pending
//  cross-block compound landed), then the registry, then the stop.
//

import Dependencies
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("pre-13u — the Mac lock teardown (17a P3)")
struct MacWillLockTests {
    /// RED ON OLD (behavioral revert: the registry-only closure body —
    /// `finalizeAll()` + stop — reddens the tail assertions): the open
    /// tail crystallizes BEFORE the services stop and the pool closes.
    @Test func theLockTeardownCrystallizesTheOpenTailLikeTheQuitDoor() async throws {
        try await withEditor { h in
            // Everything typed so far is the open tail — no block exists.
            h.type("a paragraph she is still writing when the screen locks")
            await h.settle()
            #expect(h.model.hasOpenTail)
            #expect(try h.storeSlots().isEmpty, "the tail is in NO row yet")

            // The lock road addresses the session's active editor, exactly
            // as the quit door does.
            h.session.editorRouter.active = h.model

            let stopped = LockIsolated(false)
            let teardown = macWillLock(session: h.session) { stopped.setValue(true) }
            await teardown()

            #expect(stopped.value, "the services stop — the old closure's half survives")
            let slots = try h.storeSlots()
            #expect(slots.map(\.text) ==
                    ["a paragraph she is still writing when the screen locks"],
                    "the tail is CRYSTALLIZED before the pool closes — nothing on screen is in no row")
        }
    }

    /// The order half: the editor's finalize lands its writes BEFORE
    /// `stopServices` runs (a stop that beat the flush would close the
    /// world under her last keystrokes — the phone's `mobileWillLock`
    /// states the same rule).
    @Test func theServicesStopOnlyAfterTheTailIsSafe() async throws {
        try await withEditor { h in
            h.type("tail text that must land first")
            await h.settle()
            h.session.editorRouter.active = h.model

            let slotsAtStop = LockIsolated(-1)
            let database = h.database
            let postID = h.postID
            let teardown = macWillLock(session: h.session) {
                let count = (try? database.read {
                    try Queries.renderPost($0, containerID: postID).count
                }) ?? -1
                slotsAtStop.setValue(count)
            }
            await teardown()
            #expect(slotsAtStop.value == 1,
                    "at the moment the services stop, the tail is already a row")
        }
    }
}
