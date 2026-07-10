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
                id: bridge.entryID(day: "2026-07-09"))
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
                .currentEntry(id: bridge.entryID(day: "2026-07-09"))?.updatedAt
            let writesAfterFirst = await bridge.server.acceptedWriteCount

            // Second round, nothing changed: zero pushes, zero server
            // writes, the LWW stamp untouched.
            let second = try await bridge.engine.push()
            #expect(second.pushed == 0)
            #expect(await bridge.server.acceptedWriteCount == writesAfterFirst)
            #expect(await bridge.server
                .currentEntry(id: bridge.entryID(day: "2026-07-09"))?.updatedAt
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
            // A GENUINE legacy row: created before the ops-boundary guards
            // (Step 6 closed setEntryDate; round 2 closed createPost), so it
            // can only exist via pre-guard history — injected as raw SQL
            // because the operations API now correctly refuses to mint it.
            let post = try bridge.ops.createPost(profile: .journal)
            try bridge.ops.newBlock(in: post.id, text: "orphan text", at: .end)
            try await bridge.db.write { db in
                try db.execute(
                    sql: "UPDATE container SET entry_date = '2026-7-9' WHERE id = ?",
                    arguments: [post.id])
            }
            let report = try await bridge.engine.push()
            #expect(report.pushed == 0)
            #expect(report.notes.count == 1)
            #expect(await bridge.server.entryCount == 0)
        }
    }

    /// Round-2 coverage pins (NIT 6 — both behaviors sit on the author's
    /// ratify list, QUESTIONS #14(e); they pass on both sides by design):
    /// archived entries stay push-eligible…
    @Test func anArchivedEntryStillPushes() async throws {
        try await withBridge { bridge in
            let (entry, variantID) = try bridge.makeEntry(day: "2026-07-09", text: "Archived text.")
            _ = try await bridge.engine.push()
            try bridge.ops.archiveContainer(entry.id)
            try bridge.ops.autosave(variantID, text: "Edited while archived.", charDelta: 6)
            let report = try await bridge.engine.push()
            #expect(report.pushed == 1, "archive is kept-out-of-view, not a projection freeze")
            #expect(await bridge.fragmentsBody(day: "2026-07-09") == "Edited while archived.")
        }
    }

    /// …and an archived sibling keeps the duplicate-day pause — archiving
    /// is NOT the hand-merge gesture; delete or re-date releases.
    @Test func anArchivedSiblingKeepsTheDuplicateDayPause() async throws {
        try await withBridge { bridge in
            let dupA = try bridge.ops.createPost(profile: .journal, entryDate: "2026-07-09")
            try bridge.ops.newBlock(in: dupA.id, text: "Kept.", at: .end)
            let dupB = try bridge.ops.createPost(profile: .journal, entryDate: "2026-07-09")
            try bridge.ops.newBlock(in: dupB.id, text: "Archived away.", at: .end)
            try bridge.ops.archiveContainer(dupB.id)

            let stillPaused = try await bridge.engine.push()
            #expect(stillPaused.pausedDays == ["2026-07-09"],
                    "an archived sibling is still the day's text — the pause holds")
            #expect(stillPaused.pushed == 0)

            try bridge.ops.deleteContainer(dupB.id)
            let released = try await bridge.engine.push()
            #expect(released.pausedDays.isEmpty)
            #expect(released.pushed == 1)
        }
    }

    /// ROUND-3 MINOR-1 PIN (red on pre-fix code): a day rendering with a
    /// GAP slot (referenced-but-missing rows mid-sync, SyncSpec §5) must
    /// never push — its rendered text is PARTIAL (gaps contribute nothing),
    /// and pre-fix the partial body pushed and could even BLANK the
    /// Fragments row. The landing half already deferred on this store
    /// state; the push half now agrees.
    @Test func aGapSlotDayIsNeverPartiallyProjected() async throws {
        try await withBridge { bridge in
            try bridge.makeEntry(day: "2026-07-09", text: "Full agreed text.")
            _ = try await bridge.engine.run()  // agreed; Fragments holds it
            // A transient sync-race state: the slot resolves NO renderable
            // variant (chosen and default both dead) — constructed raw, the
            // way a partial pull application would leave it.
            try await bridge.db.write { db in
                try db.execute(sql: """
                    UPDATE variant SET deleted_at = '2026-07-09T00:00:00.000Z'
                    WHERE block_id IN (
                      SELECT block_id FROM container_block cb
                      JOIN container c ON c.id = cb.container_id
                      WHERE c.entry_date = '2026-07-09' AND cb.deleted_at IS NULL
                    )
                    """)
            }
            let report = try await bridge.engine.push()
            #expect(report.pushed == 0, "a partial rendering must never project")
            #expect(report.notes.contains { $0.contains("gap") })
            #expect(await bridge.fragmentsBody(day: "2026-07-09") == "Full agreed text.",
                    "pre-fix the gap day pushed its PARTIAL (here: empty) rendering")
        }
    }

    /// Round-3 NIT-1 coverage pin (green both sides by design): the
    /// clock-ahead clamp × outranking-stamp interaction. Re-projecting over
    /// a landed clock-ahead save requires stamping above it; a strict clamp
    /// REJECTS that push — visibly (MINOR-4 surface), never silently, and
    /// nothing is lost (the save is already a card in Variorum; Fragments
    /// keeps its row). Bounded: minimal stamping only ever goes 1 s above a
    /// stamp the server itself accepted. Clamp threshold/semantics: contract
    /// ask 14.
    @Test func aClampedReprojectionIsVisibleNeverSilentNothingLost() async throws {
        try await withBridge { bridge in
            let (_, variantID) = try bridge.makeEntry(day: "2026-07-09", text: "Original.")
            _ = try await bridge.engine.run()  // agreed
            // Both sides edit; the Fragments save carries a far-ahead stamp.
            try bridge.ops.autosave(variantID, text: "Variorum rewrite.", charDelta: 8)
            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Phone-ahead save.", updatedAt: bridge.fragmentsStamp(0))
            // The server clamps stamps beyond the save's own time.
            await bridge.server.setClockAheadLimit(bridge.fragmentsStamp(0))

            let round = try await bridge.engine.run()
            // The save landed as a card (nothing lost)…
            #expect(round.landing.conflictVariants == 1)
            // …and the re-projection (stamped save+1s, past the clamp) is
            // REJECTED — visibly, in the round's notes.
            #expect(round.push.rejected == 1)
            #expect(round.push.notes.contains { $0.contains("clock_ahead") })
            #expect(await bridge.fragmentsBody(day: "2026-07-09") == "Phone-ahead save.")
        }
    }

    /// RECONCILIATION (asks 9/10): the fail-closed gate. Before Fragments'
    /// first device has synced, `user_settings.local_user_id` does not
    /// exist — the canonical id is undecided, and a push would claim canon
    /// with a Variorum-invented id. ALL pushes hold, visibly, until the
    /// row appears.
    @Test func pushesFailClosedUntilTheCanonicalUserExists() async throws {
        try await withBridge(localUserID: nil) { bridge in
            try bridge.makeEntry(day: "2026-07-09", text: "Waiting to project.")
            let held = try await bridge.engine.push()
            #expect(held.pushed == 0)
            #expect(await bridge.server.entryCount == 0, "nothing may be written fail-closed")
            #expect(held.notes.contains { $0.contains("fail-closed") })

            // Fragments' first sync mints the canonical id → pushes flow.
            await bridge.server.setLocalUserID("9f1c2b3a-4d5e-6f70-8192-a3b4c5d6e7f8")
            let flowing = try await bridge.engine.push()
            #expect(flowing.pushed == 1)
            #expect(await bridge.fragmentsBody(day: "2026-07-09") == "Waiting to project.")
            // Under the DERIVED id for the server's own canonical user —
            // the id Fragments itself would derive (the join key's trick).
            #expect(await bridge.server.currentEntry(id: bridge.entryID(day: "2026-07-09"))?.body
                    == "Waiting to project.")
        }
    }

    /// RECONCILIATION (ask 12): created_at follows the WINNING push
    /// server-side, so the bridge ECHOES the pulled created_at — the
    /// original creation instant survives our re-projections.
    @Test func pushesEchoThePulledCreatedAt() async throws {
        try await withBridge { bridge in
            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
                body: "Phone original.", updatedAt: bridge.fragmentsStamp(0))
            let original = await bridge.server.currentEntry(
                id: bridge.entryID(day: "2026-07-09"))!.createdAt
            _ = try await bridge.engine.run()  // lands; records created_at

            // Variorum edits; the re-projection must not replace created_at.
            let variantID = try await bridge.db.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM variant LIMIT 1")
            }!
            try bridge.ops.autosave(variantID, text: "Edited on the Mac.", charDelta: 6)
            let report = try await bridge.engine.push()
            #expect(report.pushed == 1)
            let after = await bridge.server.currentEntry(id: bridge.entryID(day: "2026-07-09"))
            #expect(after?.body == "Edited on the Mac.")
            #expect(after?.createdAt == original,
                    "the winning push carries created_at — echoing preserves the original instant")
        }
    }

    @Test func staleOutcomeRecordsNothingSoThePullReconciles() async throws {
        try await withBridge { bridge in
            try bridge.makeEntry(day: "2026-07-09", text: "Variorum text.")
            // Fragments already holds a much-newer row (2027 stamp beats
            // the deterministic 2026 clock).
            _ = try await bridge.server.fragmentsAppWrites(
                userID: bridge.config.userID, day: "2026-07-09",
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
