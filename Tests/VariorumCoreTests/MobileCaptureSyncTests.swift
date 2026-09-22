import Dependencies
import Foundation
import Testing
@testable import VariorumCore

/// Phase 8, Step 7 (ii) — the two-store convergence scenario driven by the
/// MOBILE op stream: create-or-open journal entries (the notebook rule),
/// mint-on-first-keystroke, debounce-rate autosaves, a user re-dated entry,
/// an edit to a Mac-authored block, and the S5 conflict when both devices
/// edit the same entry across an offline window. Convergence bar unchanged:
/// empty outboxes, byte-identical synced tables.
///
/// RUN B batch B4 (ledger row 14): every round runs production's shape,
/// and the double-create scenario carries its own registry-boundary
/// chunk-split arm (the `block` boundary — a bodiless entry crossing the
/// wire mid-split).
@Suite("Sync under the mobile capture write pattern (Phase 8, Step 7)")
struct MobileCaptureSyncTests {
    @Test func offlineCaptureEditsAndConflictsConverge() async throws {
        let server = FakeSyncServer()
        let mac = try SyncClient(name: "Mac", prefix: "AA", transport: server)
        let phone = try SyncClient(name: "Phone", prefix: "BB", transport: server, clockOffset: 977, seed: 2)

        // The Mac authors a post (the editor's stream), and journals too.
        let macVariantID: String = try mac.with { ops, _ in
            let post = try ops.createPost(title: "Desk essay", profile: .blog)
            let minted = try ops.newBlock(in: post.id, text: "Written at the desk.", at: .end)
            _ = try ops.createOrOpenJournalEntry(entryDate: "2026-07-06")
            return minted.variant.id
        }
        _ = try await productionQuiescence(mac, phone, server: server)

        // ── The phone goes OFFLINE and journals (the capture stream). ──
        let phoneEntryVariant: String = try phone.with { ops, _ in
            // Create-or-open today; the first keystroke mints THE block;
            // typing continues as debounce-rate autosaves.
            let today = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            #expect(today.created)
            let minted = try ops.newBlock(in: today.container.id, text: "Phone", at: .end)
            var buffer = "Phone"
            for word in [" thoughts", " while", " offline."] {
                buffer += word
                try ops.autosave(minted.variant.id, text: buffer, charDelta: word.count)
            }
            // A backfilled entry, re-dated by the user (author 2026-07-07:
            // past days are legitimate).
            let backfill = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            #expect(!backfill.created, "the notebook rule opens today's page")
            let yesterday = try ops.createOrOpenJournalEntry(entryDate: "2026-07-05")
            #expect(yesterday.created)
            // The phone also edits the MAC-AUTHORED block's active text
            // (pillar 8's second capability).
            try ops.autosave(macVariantID, text: "Written at the desk, tightened on the phone.", charDelta: 25)
            return minted.variant.id
        }

        // Meanwhile the Mac edits the SAME desk paragraph (the S5 race).
        try mac.with { ops, _ in
            try ops.autosave(macVariantID, text: "Written at the desk, expanded at the desk.", charDelta: 22)
        }

        // ── Back online: rounds until quiescence. ──
        _ = try await productionQuiescence(mac, phone, server: server)
        #expect(try mac.syncedDump() == phone.syncedDump())
        #expect(try mac.outboxCount() == 0)
        #expect(try phone.outboxCount() == 0)

        // The journal reached the Mac: both entries, entry_date-keyed.
        let macDays = try await mac.db.read { db in
            try String.fetchAll(db, sql: """
                SELECT entry_date FROM container
                WHERE profile = 'journal' AND deleted_at IS NULL ORDER BY entry_date
                """)
        }
        #expect(macDays == ["2026-07-05", "2026-07-06", "2026-07-07"])
        let macSeesPhoneText = try await mac.db.read { db in
            try String.fetchOne(
                db, sql: "SELECT working_text FROM variant WHERE id = ?",
                arguments: [phoneEntryVariant])
        }
        #expect(macSeesPhoneText == "Phone thoughts while offline.")

        // The same-variant race resolved as S5 demands: one side's text won
        // the row, the other survives as EXACTLY ONE conflict variant on the
        // same block — nothing lost, identically on both devices.
        for client in [mac, phone] {
            let texts = try await client.db.read { db in
                try String.fetchAll(db, sql: """
                    SELECT working_text FROM variant
                    WHERE block_id = (SELECT block_id FROM variant WHERE id = ?)
                      AND deleted_at IS NULL
                    ORDER BY working_text
                    """, arguments: [macVariantID])
            }
            #expect(texts.count == 2, "\(client.name): the fan holds the winner + the rescued loser")
            #expect(texts.contains("Written at the desk, expanded at the desk."))
            #expect(texts.contains("Written at the desk, tightened on the phone."))
            let conflicts = try await client.db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM variant
                    WHERE label = 'conflict' AND deleted_at IS NULL
                    """) ?? -1
            }
            #expect(conflicts == 1, "\(client.name): exactly one conflict card, no duplicates")
        }
    }

    /// The documented same-day double-create (author 2026-07-07): two
    /// devices offline both "new entry" the same day → convergence shows
    /// TWO visible entries on that day's page (deliberately NO unique
    /// index, no repair class) — and create-or-open then opens the SAME
    /// earliest entry on both devices, deterministically.
    @Test func theOfflineSameDayDoubleCreateConvergesToTwoVisibleEntries() async throws {
        let server = FakeSyncServer()
        let mac = try SyncClient(name: "Mac", prefix: "AA", transport: server)
        let phone = try SyncClient(name: "Phone", prefix: "BB", transport: server, clockOffset: 977, seed: 2)

        try mac.with { ops, _ in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            _ = try ops.newBlock(in: entry.container.id, text: "Desk half of the day.", at: .end)
        }
        try phone.with { ops, _ in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            _ = try ops.newBlock(in: entry.container.id, text: "Phone half of the day.", at: .end)
        }
        _ = try await productionQuiescence(mac, phone, server: server)
        #expect(try mac.syncedDump() == phone.syncedDump())

        for client in [mac, phone] {
            let dayEntries = try await client.db.read { db in
                try String.fetchAll(db, sql: """
                    SELECT id FROM container
                    WHERE profile = 'journal' AND entry_date = '2026-07-07'
                      AND deleted_at IS NULL
                    ORDER BY created_at, id
                    """)
            }
            #expect(dayEntries.count == 2,
                    "\(client.name): both halves visible on the day's page — hand-merge is the author's")
        }
        // Create-or-open now opens the SAME entry on both devices.
        let macOpened = try mac.with { ops, _ in
            try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
        }
        let phoneOpened = try phone.with { ops, _ in
            try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
        }
        #expect(!macOpened.created)
        #expect(!phoneOpened.created)
        #expect(macOpened.container.id == phoneOpened.container.id,
                "the earliest-created entry opens, deterministically on every device")
    }

    /// RUN B batch B4 — the registry-boundary chunk-split arm for the
    /// capture family (ledger row 14; B1's `pushSplitAtBoundary` is the
    /// instrument): the Mac's push of its half of the double-create dies AT
    /// the `block` boundary — the entry's container crosses the wire
    /// BODILESS (its block, variant and placement stranded) — and the
    /// phone's full round runs against that partial picture (SyncSpec §5's
    /// read-side tolerance: render gaps, never crash). The resumed drain
    /// completes the family; the day still converges to the documented two
    /// visible entries with both bodies, and create-or-open still opens the
    /// same earliest entry everywhere.
    @Test func theDoubleCreateSplitAtTheBlockBoundaryStillConvergesToTwoWholeEntries() async throws {
        let server = FakeSyncServer()
        let macFault = FaultInjectingTransport(server: server)
        let mac = try SyncClient(name: "Mac", prefix: "AA", transport: macFault)
        let phone = try SyncClient(name: "Phone", prefix: "BB", transport: server, clockOffset: 977, seed: 2)

        try mac.with { ops, _ in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            _ = try ops.newBlock(in: entry.container.id, text: "Desk half of the day.", at: .end)
        }
        try phone.with { ops, _ in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
            _ = try ops.newBlock(in: entry.container.id, text: "Phone half of the day.", at: .end)
        }

        // The Mac's round: pull (empty), then the push dies at the block
        // boundary — the container lands alone.
        _ = try await mac.pull()
        try await pushSplitAtBoundary(mac, table: "block", transport: macFault)

        // The phone's full round in the gap: the bodiless entry arrives (a
        // legal partial world) and the phone's own whole entry lands.
        let gapPull = try await phone.pull()
        #expect(gapPull.applied >= 1, "the bodiless container crossed in the first chunk")
        #expect(try phone.db.fetchInt(
            """
            SELECT COUNT(*) FROM container
            WHERE profile = 'journal' AND entry_date = '2026-07-07' AND deleted_at IS NULL
            """) == 2, "the phone sees both entries mid-split — one still bodiless")
        _ = try await phone.push()

        // The Mac resumes; both families complete everywhere.
        _ = try await productionQuiescence(mac, phone, server: server)
        #expect(try mac.syncedDump() == phone.syncedDump())
        for client in [mac, phone] {
            #expect(try client.db.fetchInt(
                """
                SELECT COUNT(*) FROM container
                WHERE profile = 'journal' AND entry_date = '2026-07-07' AND deleted_at IS NULL
                """) == 2, "\(client.name): the documented two visible entries")
            for text in ["Desk half of the day.", "Phone half of the day."] {
                #expect(try client.db.fetchString(
                    "SELECT working_text FROM variant WHERE working_text = ? AND deleted_at IS NULL",
                    [text]) != nil, "\(client.name): both bodies whole after the resume")
            }
        }
        let macOpened = try mac.with { ops, _ in
            try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
        }
        let phoneOpened = try phone.with { ops, _ in
            try ops.createOrOpenJournalEntry(entryDate: "2026-07-07")
        }
        #expect(!macOpened.created && !phoneOpened.created)
        #expect(macOpened.container.id == phoneOpened.container.id,
                "create-or-open converges through the split too")
    }
}
