//
//  OpenNotesMemoryTests.swift
//  VariorumTests
//
//  VX-139 (the VX-143 run, 2026-10-11 — her word: "I want it fixed now"):
//  the Open strip remembered across launches, behind a LOCAL setting.
//
//  FEATURE PINS, green-only by construction (the VX-144 precedent's split:
//  none of this API exists on the old tree, so there is no old behavior to
//  pin red — the characterization that the strip was session-only lives in
//  `WorkspaceNavigationTests`' own suite header). What is pinned:
//
//  · the PURE restore — stored order kept (her manual arrangement included),
//    dead ids dropped, duplicates collapsed, the tracked cap honored, a
//    torn recency list reconciled;
//  · the MEMORY shim — remember/stored round-trip, and the off-switch
//    FORGETS live (off means off at the very next launch);
//  · the MODEL road — the first shell claims and restores against the real
//    store (a trashed note's row does not come back), a second shell stays
//    empty, the claimant writes every strip change back, and the setting
//    off restores nothing while still claiming (so flipping it on
//    mid-session starts remembering without a relaunch).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

// MARK: - The pure restore

@Suite("The remembered strip's pure restore (VX-139)")
struct OpenNotesRestoreTests {
    @Test func restoreKeepsStoredOrderDropsDeadAndCollapsesDuplicates() {
        let notes = OpenNotes(
            restoringIDs: ["a", "dead", "b", "a", "c"],
            recency: ["c", "a", "b"],
            isLive: { $0 != "dead" })
        #expect(notes.ids == ["a", "b", "c"], "stored order, dead gone, the dupe collapsed")
        #expect(notes.recency == ["c", "a", "b"], "recency survives, filtered to the kept set")
    }

    @Test func restoreHonorsTheTrackedCap() {
        let many = (1...30).map { "n\($0)" }
        let notes = OpenNotes(restoringIDs: many, recency: many.reversed(), isLive: { _ in true })
        #expect(notes.ids.count == OpenNotes.trackedCap)
        #expect(notes.ids == many.prefix(OpenNotes.trackedCap).map { $0 },
                "the first tracked-cap rows in stored order")
        #expect(Set(notes.recency) == Set(notes.ids), "recency covers exactly the kept rows")
    }

    @Test func aTornRecencyListIsReconciledToTheBack() {
        // An interrupted write can leave an id in `ids` but not `recency`;
        // it re-joins least-recent, so the bound prefers to evict it.
        let notes = OpenNotes(
            restoringIDs: ["a", "b", "c"], recency: ["b"], isLive: { _ in true })
        #expect(notes.ids == ["a", "b", "c"])
        #expect(notes.recency == ["b", "a", "c"], "the lost ids re-join at the back")
    }
}

// MARK: - The memory shim

@Suite("The strip's this-Mac memory (VX-139)", .serialized)
struct OpenNotesMemoryShimTests {
    private func freshDefaults() -> UserDefaults {
        let suite = "OpenNotesMemoryTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    @Test func rememberRoundTripsAndDefaultsToOn() {
        let defaults = freshDefaults()
        #expect(OpenNotesMemory.isOn(defaults), "unanswered means ON — the ask is the behavior")
        var notes = OpenNotes()
        notes.opened("p1")
        notes.opened("p2")
        OpenNotesMemory.remember(notes, in: defaults)
        let stored = OpenNotesMemory.stored(defaults)
        #expect(stored.ids == ["p1", "p2"])
        #expect(stored.recency == ["p2", "p1"])
    }

    @Test func theOffSwitchForgetsLive() {
        let defaults = freshDefaults()
        var notes = OpenNotes()
        notes.opened("p1")
        OpenNotesMemory.remember(notes, in: defaults)
        #expect(OpenNotesMemory.stored(defaults).ids == ["p1"])
        // She turns it off; the very next write CLEARS rather than writes,
        // so "off" is off at the next launch, not two launches later.
        defaults.set(false, forKey: OpenNotesMemory.settingKey)
        notes.opened("p2")
        OpenNotesMemory.remember(notes, in: defaults)
        #expect(OpenNotesMemory.stored(defaults).ids.isEmpty, "off forgets")
        #expect(OpenNotesMemory.stored(defaults).recency.isEmpty)
    }
}

// MARK: - The model road

@Suite("The launch restore through the model (VX-139)", .serialized)
@MainActor
struct OpenNotesModelRestoreTests {
    private func freshDefaults() -> UserDefaults {
        let suite = "OpenNotesModelRestoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    @Test func theFirstShellRestoresLiveRowsAndWritesBackTheSecondStaysEmpty() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let keep = try await session.runner.run { ops in
                try ops.createPost(title: "Still here")
            }
            let gone = try await session.runner.run { ops in
                try ops.createPost(title: "Trashed meanwhile")
            }
            _ = try await session.runner.run { ops in
                try ops.deleteContainer(gone.id)
            }

            let defaults = freshDefaults()
            defaults.set([gone.id, keep.id], forKey: OpenNotesMemory.idsKey)
            defaults.set([keep.id, gone.id], forKey: OpenNotesMemory.recencyKey)

            WorkspaceModel.resetOpenNotesLaunchClaimForTesting()
            let first = WorkspaceModel()
            await first.restoreRememberedOpenNotes(session: session, defaults: defaults)
            #expect(first.openNotes.ids == [keep.id], "the live row returns; the trashed one does not")
            #expect(OpenNotesMemory.stored(defaults).ids == [keep.id],
                    "the store is normalized to what came back")

            // A second shell this launch starts empty, as every window always has.
            let second = WorkspaceModel()
            await second.restoreRememberedOpenNotes(session: session, defaults: defaults)
            #expect(second.openNotes.ids.isEmpty, "one claim per launch")

            // The claimant persists every strip change.
            first.visit(.post(gone.id))  // ids are view state; the strip records the visit
            #expect(OpenNotesMemory.stored(defaults).ids == [keep.id, gone.id])
            first.closeNote(gone.id)
            #expect(OpenNotesMemory.stored(defaults).ids == [keep.id])
        }
    }

    @Test func theSettingOffRestoresNothingButStillClaims() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "Not restored")
            }
            let defaults = freshDefaults()
            defaults.set([post.id], forKey: OpenNotesMemory.idsKey)
            defaults.set([post.id], forKey: OpenNotesMemory.recencyKey)
            defaults.set(false, forKey: OpenNotesMemory.settingKey)

            WorkspaceModel.resetOpenNotesLaunchClaimForTesting()
            let shell = WorkspaceModel()
            await shell.restoreRememberedOpenNotes(session: session, defaults: defaults)
            #expect(shell.openNotes.ids.isEmpty, "off restores nothing")

            // …but the claim landed: flipping the setting on mid-session
            // starts remembering without a relaunch.
            defaults.set(true, forKey: OpenNotesMemory.settingKey)
            shell.visit(.post(post.id))
            #expect(OpenNotesMemory.stored(defaults).ids == [post.id])
        }
    }
}
