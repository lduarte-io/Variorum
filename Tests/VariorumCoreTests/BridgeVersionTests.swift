import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **V3's MUST-PIN** (the post-13l polish round, ledger row 24 — the
/// architect's review pass named it a trap rather than a taste call):
///
/// > *"a version copy of a JOURNAL note may carry the copied `entry_date` — if
/// > the bridge's day scan sees it, the duplicate-day pause FIRES and her
/// > journal silently stops pushing that day."*
///
/// **It was real, and this suite is what holds the fix.** The scan reads every
/// LIVE journal-profile container with an `entry_date` and pauses any day
/// holding more than one — never newest-wins, because a slipped push would
/// overwrite one body with the other on the Fragments side. `copyPost` copies
/// `entry_date` verbatim, so a saved moment of a journal day would have been a
/// second live row on that day and the day would have gone quiet with no
/// visible cause.
///
/// The fix is in `mintNoteVersion`: **a version carries no `entry_date`,
/// because a saved moment is not a day.** The scan is untouched — nothing in
/// `Sources/VariorumCore/Sync/` and nothing in the engine — which is the point:
/// the trap closes at the door that mints the row, where the meaning is.
@Suite("The versions family × the Fragments bridge (row 24 — V3's MUST-PIN)")
struct BridgeVersionTests {
    /// The pin itself: save a version of today's entry, and the day pushes.
    @Test func aSavedVersionOfAJournalDayNeverPausesThatDay() async throws {
        try await withBridge { bridge in
            let (entry, _) = try bridge.makeEntry(day: "2026-07-09", text: "What happened.")
            _ = try await bridge.engine.push()
            #expect(try await bridge.fragmentsBody(day: "2026-07-09") == "What happened.")

            // The whole-note Versions door, on a journal day.
            let version = try bridge.ops.saveNoteVersion(entry.id).post
            #expect(version.entryDate == nil)
            #expect(version.profile == .journal)

            // She writes on, and the day still flows.
            let variantID = try #require(try await bridge.db.read { db -> String? in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT v.id FROM variant v
                        JOIN container_block cb ON cb.block_id = v.block_id
                        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                          AND v.deleted_at IS NULL
                        ORDER BY cb.position, cb.id LIMIT 1
                        """,
                    arguments: [entry.id])
            })
            try bridge.ops.autosave(variantID, text: "What happened, revised.", charDelta: 8)

            let report = try await bridge.engine.push()
            #expect(report.pausedDays.isEmpty,
                    "a saved moment must never look like a second entry for the day")
            #expect(report.pushed == 1)
            #expect(try await bridge.fragmentsBody(day: "2026-07-09")
                    == "What happened, revised.")
        }
    }

    /// The other half, so the fix cannot be mistaken for luck: a version taken
    /// while a day is ALREADY paused changes nothing about the pause, and the
    /// hand-merge still releases it.
    @Test func aVersionNeitherCausesNorReleasesADuplicateDayPause() async throws {
        try await withBridge { bridge in
            let dupA = try bridge.ops.createPost(profile: .journal, entryDate: "2026-07-09")
            try bridge.ops.newBlock(in: dupA.id, text: "First take on the day.", at: .end)
            let dupB = try bridge.ops.createPost(profile: .journal, entryDate: "2026-07-09")
            try bridge.ops.newBlock(in: dupB.id, text: "Second take on the day.", at: .end)

            _ = try bridge.ops.saveNoteVersion(dupA.id)
            let paused = try await bridge.engine.push()
            #expect(paused.pausedDays == ["2026-07-09"],
                    "the real duplicate is still a duplicate")

            // The hand-merge: one duplicate goes, and its own saved moment goes
            // with it (V2). The day releases — the version never counted.
            try bridge.ops.deleteContainer(dupB.id)
            let after = try await bridge.engine.push()
            #expect(after.pausedDays.isEmpty)
            #expect(try await bridge.fragmentsBody(day: "2026-07-09")
                    == "First take on the day.")
        }
    }
}
