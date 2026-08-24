//
//  AutosaveRegistryReleaseTests.swift
//  VariorumTests
//
//  Phase 13l, ACT 3 / L-d — `AppSession.postAutosaves` gains a way to let go.
//
//  RED ON THE PRE-FIX TREE: there was no `releaseAutosave(forPost:)` at all
//  (`grep -c 'removeValue\|releaseAutosave' Shared/AppSession.swift` → 0),
//  so none of this compiles there, and the behaviour it pins — an entry
//  leaving the flush walk, and ⌘Q registering ONCE across a
//  release-then-re-mint — did not exist.
//
//  The Mac hosts these pins because the map, the registry and the ⌘Q
//  registration are all `Shared/`, and only the Mac compiles the
//  `quitFinalize` half.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The autosave registry can let go (13l L-d)")
struct AutosaveRegistryReleaseTests {
    private func withSession<T>(
        _ body: @MainActor (AppSession, AppDatabase) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    /// **THE FIX.** A capture's coordinator can be handed back, and the
    /// flush walk stops carrying it. `flushEveryOpenPost` is the observable
    /// consequence — it is what the growth actually cost.
    @Test func aReleasedPostLeavesTheFlushWalk() async throws {
        try await withSession { session, _ in
            let coordinator = session.autosave(forPost: "p1")
            #expect(session.quitFinalize.isEmpty == false, "the ⌘Q half registered")

            #expect(session.releaseAutosave(forPost: "p1"))
            #expect(session.quitFinalize.isEmpty,
                    "the registration went with the entry — no closure for a post nothing holds")

            // The proof the entry is gone: asking again mints a NEW one.
            #expect(session.autosave(forPost: "p1") !== coordinator)
        }
    }

    /// **The traced trap, CLOSED.** The Mac registers a `quitFinalize`
    /// closure when a post's coordinator is minted, so release-then-re-mint
    /// used to leave two registrations for one post. The token rides in the
    /// entry now, so the count is one either way.
    @Test func releaseThenReMintRegistersQuitExactlyOnce() async throws {
        try await withSession { session, _ in
            _ = session.autosave(forPost: "p1")
            #expect(session.quitFinalize.count == 1)

            session.releaseAutosave(forPost: "p1")
            #expect(session.quitFinalize.count == 0)

            _ = session.autosave(forPost: "p1")
            #expect(session.quitFinalize.count == 1,
                    "one post, one registration — before L-d this read 2")
        }
    }

    /// **The one thing release refuses to do.** A coordinator with unflushed
    /// text keeps its place — `flushEveryOpenPost` and ⌘Q must still reach
    /// it. Dropping it is the only way this could lose bytes.
    @Test func aDirtyCoordinatorIsNeverDropped() async throws {
        try await withSession { session, _ in
            let post = try session.operations.createPost(title: "T", profile: nil)
            let block = try session.operations.newBlock(in: post.id, text: "hello")
            let coordinator = session.autosave(
                forPost: post.id, debounce: .seconds(60),
                sleep: { _ in try await Task.sleep(for: .seconds(60)) })
            coordinator.record(
                variantID: block.variant.id, text: "hello there", charDelta: 6)
            #expect(coordinator.isDirty)

            #expect(session.releaseAutosave(forPost: post.id) == false)
            #expect(session.autosave(forPost: post.id) === coordinator,
                    "the same coordinator — the dirty entry stayed")

            await coordinator.flushNow()
            #expect(!coordinator.isDirty)
        }
    }

    /// Over-counting is the safe direction, and it is the direction a
    /// transient caller takes (`ShellActions.toggleSeal` flushes a post it
    /// never releases — an OPEN one, so its entry exists regardless). A second
    /// holder keeps the entry alive.
    ///
    /// *(13l, LR-MINOR-2: `NoteDeletion` used to be named here too and is no
    /// longer a minting caller at all — see
    /// `NoteDeletionDoorsTests.deletingANeverOpenedNoteMintsNothing`.)*
    @Test func aSecondHolderKeepsTheEntry() async throws {
        try await withSession { session, _ in
            let first = session.autosave(forPost: "p1")
            _ = session.autosave(forPost: "p1")   // a transient flush caller

            #expect(session.releaseAutosave(forPost: "p1") == false)
            #expect(session.autosave(forPost: "p1") === first,
                    "still the one coordinator — the ONE-per-post guarantee holds")
        }
    }

    /// **The growth this exists to stop, in one picture.** Each capture is
    /// a different post, so before L-d the registry only ever grew — and
    /// `flushEveryOpenPost` walked all of it at every filing and every
    /// background flush. The first half of this pin is what the pre-L-d
    /// tree did forever; the second half is the part that is new.
    @Test func capturesAccumulateUntilTheyAreReleased() async throws {
        try await withSession { session, _ in
            for i in 0..<8 { _ = session.autosave(forPost: "capture-\(i)") }
            #expect(session.quitFinalize.count == 8, "eight jots, eight entries")

            for i in 0..<8 { session.releaseAutosave(forPost: "capture-\(i)") }
            #expect(session.quitFinalize.count == 0, "and the day's jotting costs nothing")
        }
    }

    @Test func releasingAPostNobodyHoldsIsANoOp() async throws {
        try await withSession { session, _ in
            #expect(session.releaseAutosave(forPost: "never-seen") == false)
        }
    }
}
