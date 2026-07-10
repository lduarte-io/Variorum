import Foundation
import Testing
@testable import VariorumCore

/// Phase 9b, Step 3 — the push half: rendered journal text projects out to
/// Fragments under the deterministic id; unchanged text NEVER pushes (the
/// clobber-guard mirror — a pointless `updated_at` bump would LWW-beat a
/// real Fragments edit, the forbidden class); duplicate days pause, visibly,
/// day-scoped, releasable.
@Suite("Bridge push half (Phase 9b, Step 3)")
struct BridgePushTests {
    @Test func changedEntryPushesOnceUnderTheDerivedID() async throws {
        try await withBridge { bridge in
            try bridge.makeEntry(day: "2026-07-09", text: "Dear diary, day one.")
            let report = try await bridge.engine.push()
            #expect(report.pushed == 1)
            #expect(report.pausedDays.isEmpty)
            let entry = await bridge.server.currentEntry(
                id: bridge.config.entryID(dayKey: "2026-07-09")!)
            #expect(entry?.body == "Dear diary, day one.")
            #expect(entry?.date == "2026-07-09")
            #expect(entry?.userID == "user-author")
            // The agreed hash recorded on accept.
            #expect(try bridge.dayState("2026-07-09")
                    == BridgeHash.body("Dear diary, day one."))
        }
    }

    @Test func unchangedNeverPushes_theClobberGuardMirror() async throws {
        try await withBridge { bridge in
            try bridge.makeEntry(day: "2026-07-09", text: "Same text.")
            _ = try await bridge.engine.push()
            let stampAfterFirst = await bridge.server
                .currentEntry(id: bridge.config.entryID(dayKey: "2026-07-09")!)?.updatedAt
            let writesAfterFirst = await bridge.server.acceptedWriteCount

            // Second round, nothing changed: zero pushes, zero server
            // writes, the LWW stamp untouched.
            let second = try await bridge.engine.push()
            #expect(second.pushed == 0)
            #expect(await bridge.server.acceptedWriteCount == writesAfterFirst)
            #expect(await bridge.server
                .currentEntry(id: bridge.config.entryID(dayKey: "2026-07-09")!)?.updatedAt
                    == stampAfterFirst)
        }
    }

    @Test func editingThenPushingProjectsTheNewText() async throws {
        try await withBridge { bridge in
            let (_, variantID) = try bridge.makeEntry(day: "2026-07-09", text: "Draft one.")
            _ = try await bridge.engine.push()
            try bridge.ops.autosave(variantID, text: "Draft two.", charDelta: 2)
            let report = try await bridge.engine.push()
            #expect(report.pushed == 1)
            #expect(await bridge.fragmentsBody(day: "2026-07-09") == "Draft two.")
        }
    }

    @Test func duplicateDayHoldsThatDayOnlyAndReleasesAfterHandMerge() async throws {
        try await withBridge { bridge in
            // The documented offline race: two live entries on one date
            // (createPost bypasses the notebook rule, as a converged
            // double-create would).
            let dupA = try bridge.ops.createPost(profile: .journal, entryDate: "2026-07-09")
            try bridge.ops.newBlock(in: dupA.id, text: "First take on the day.", at: .end)
            let dupB = try bridge.ops.createPost(profile: .journal, entryDate: "2026-07-09")
            try bridge.ops.newBlock(in: dupB.id, text: "Second take on the day.", at: .end)
            try bridge.makeEntry(day: "2026-07-10", text: "An ordinary day.")

            let report = try await bridge.engine.push()
            // The paused day pushed NOTHING; the ordinary day flowed.
            #expect(report.pausedDays == ["2026-07-09"])
            #expect(report.pushed == 1)
            #expect(await bridge.fragmentsBody(day: "2026-07-09") == nil)
            #expect(await bridge.fragmentsBody(day: "2026-07-10") == "An ordinary day.")

            // Hand-merge: the author deletes one duplicate → the pause
            // releases and the day pushes.
            try bridge.ops.deleteContainer(dupB.id)
            let after = try await bridge.engine.push()
            #expect(after.pausedDays.isEmpty)
            #expect(after.pushed == 1)
            #expect(await bridge.fragmentsBody(day: "2026-07-09") == "First take on the day.")
        }
    }

    @Test func graduatedEntryStillPushesItsRenderedText() async throws {
        try await withBridge { bridge in
            let (entry, variantID) = try bridge.makeEntry(
                day: "2026-07-09", text: "Morning paragraph.")
            try bridge.ops.newBlock(in: entry.id, text: "Evening paragraph.", at: .end)
            _ = try bridge.ops.branchVariant(
                try bridge.firstBlockID(day: "2026-07-09")!, from: variantID)
            let report = try await bridge.engine.push()
            #expect(report.pushed == 1)
            // The projection is the rendered text — the graduated policy's
            // push-only direction.
            #expect(await bridge.fragmentsBody(day: "2026-07-09")
                    == "Morning paragraph.\n\nEvening paragraph.")
        }
    }

    @Test func emptyRenderedTextIsNeverAFirstPush() async throws {
        try await withBridge { bridge in
            // An entry with no text yet (created, nothing typed): pushing
            // emptiness could only LWW-blank a Fragments body the bridge
            // has not landed.
            _ = try bridge.ops.createOrOpenJournalEntry(entryDate: "2026-07-09")
            let report = try await bridge.engine.push()
            #expect(report.pushed == 0)
            #expect(await bridge.server.entryCount == 0)
        }
    }

    @Test func emptyingAPreviouslyAgreedDayDoesPush() async throws {
        try await withBridge { bridge in
            let (_, variantID) = try bridge.makeEntry(day: "2026-07-09", text: "Some text.")
            _ = try await bridge.engine.push()
            // The author empties the entry in Variorum: a real projection.
            try bridge.ops.autosave(variantID, text: "", charDelta: 10)
            let report = try await bridge.engine.push()
            #expect(report.pushed == 1)
            #expect(await bridge.fragmentsBody(day: "2026-07-09") == "")
        }
    }

    @Test func malformedEntryDateIsNotedNeverBridged() async throws {
        try await withBridge { bridge in
            // Legacy rows predating Step 6's setEntryDate guard.
            let post = try bridge.ops.createPost(profile: .journal, entryDate: "2026-7-9")
            try bridge.ops.newBlock(in: post.id, text: "orphan text", at: .end)
            let report = try await bridge.engine.push()
            #expect(report.pushed == 0)
            #expect(report.notes.count == 1)
            #expect(await bridge.server.entryCount == 0)
        }
    }

    @Test func staleOutcomeRecordsNothingSoThePullReconciles() async throws {
        try await withBridge { bridge in
            try bridge.makeEntry(day: "2026-07-09", text: "Variorum text.")
            // Fragments already holds a much-newer row (2027 stamp beats
            // the deterministic 2026 clock).
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-09",
                body: "Fragments text, newer.", updatedAt: bridge.fragmentsStamp(0))
            let report = try await bridge.engine.push()
            #expect(report.pushed == 0)
            #expect(report.stale == 1)
            // No agreed state was invented; their body untouched.
            #expect(try bridge.dayState("2026-07-09") == nil)
            #expect(await bridge.fragmentsBody(day: "2026-07-09") == "Fragments text, newer.")
        }
    }
}
