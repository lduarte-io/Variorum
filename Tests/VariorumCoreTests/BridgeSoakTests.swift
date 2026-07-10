import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 9b, Step 7 — the round-trip matrix's randomized face and the
/// bridge-under-sync convergence:
///
/// (ii) a seeded soak interleaving Variorum edits, Fragments writes,
/// deletions, duplicate-days, and graduations with engine rounds — after
/// quiescence the surfaces converge byte-equal, every rescued body traces
/// to a real Fragments write, hashes/cursor are consistent, and a quiescent
/// round makes NO server writes (no gratuitous pushes);
///
/// (iii) the bridge and the MIRROR sync engine running together — bridge
/// landings ride the outbox to the other device like any operation, and
/// both convergence properties hold at once.
@Suite("Bridge round-trip soak (Phase 9b, Step 7)")
struct BridgeSoakTests {
    // MARK: (i-shaped warmup) both directions in one deterministic pass

    @Test func roundTripBothDirectionsConverges() async throws {
        try await withBridge { bridge in
            // Variorum-authored day; Fragments-authored day.
            try bridge.makeEntry(day: "2026-07-01", text: "Mac-side entry.")
            _ = try await bridge.server.fragmentsAppWrites(
                configuration: bridge.config, day: "2026-07-02",
                body: "Phone-side entry.", updatedAt: bridge.fragmentsStamp(0))

            _ = try await bridge.engine.run()

            #expect(await bridge.fragmentsBody(day: "2026-07-01") == "Mac-side entry.")
            #expect(try bridge.rendered(day: "2026-07-02") == "Phone-side entry.")

            // Quiescent: a second round moves nothing anywhere.
            let writesBefore = await bridge.server.acceptedWriteCount
            let quiet = try await bridge.engine.run()
            #expect(quiet.push.pushed == 0)
            #expect(quiet.landing.created == 0 && quiet.landing.updated == 0)
            #expect(await bridge.server.acceptedWriteCount == writesBefore)
        }
    }

    // MARK: (ii) the randomized soak

    @Test(arguments: [UInt64(11), UInt64(42), UInt64(2026)])
    func randomizedSoakConvergesWithNothingInvented(seed: UInt64) async throws {
        try await withBridge(seed: seed) { bridge in
            var rng = SeededGenerator(seed: seed &* 7919)
            let days = ["2026-07-01", "2026-07-02", "2026-07-03", "2026-07-04"]
            var fragmentsLedger: Set<String> = []  // every body Fragments ever wrote
            var fragmentsStampCounter = 0
            var totals = BridgeEngine.RoundReport()

            func nextFragmentsStamp() -> String {
                fragmentsStampCounter += 1
                return String(format: "2027-01-01T%02d:%02d:00.000Z",
                              fragmentsStampCounter / 60, fragmentsStampCounter % 60)
            }

            /// The day's canonical entry + its single-unfanned variant, if
            /// it is in the two-way regime.
            func canonicalEntry(_ day: String) throws -> (id: String, variantID: String?)? {
                try bridge.db.read { db in
                    guard let id = try String.fetchOne(
                        db,
                        sql: """
                            SELECT id FROM container
                            WHERE kind = 'post' AND profile = 'journal'
                              AND entry_date = ? AND deleted_at IS NULL
                            ORDER BY (archived_at IS NOT NULL) ASC, created_at ASC, id ASC
                            LIMIT 1
                            """,
                        arguments: [day])
                    else { return nil }
                    let slots = try Queries.renderPost(db, containerID: id)
                    guard slots.count == 1, !slots[0].isGap,
                          slots[0].activeVariantCount <= 1
                    else { return (id, nil) }
                    return (id, slots[0].variantID)
                }
            }

            func liveEntryIDs(_ day: String) throws -> [String] {
                try bridge.db.read { db in
                    try String.fetchAll(
                        db,
                        sql: """
                            SELECT id FROM container
                            WHERE kind = 'post' AND profile = 'journal'
                              AND entry_date = ? AND deleted_at IS NULL
                            ORDER BY created_at, id
                            """,
                        arguments: [day])
                }
            }

            for step in 0..<60 {
                let day = days[Int(rng.next() % UInt64(days.count))]
                switch rng.next() % 8 {
                case 0:  // Variorum: create-or-extend the day's entry
                    let entry = try bridge.ops.createOrOpenJournalEntry(entryDate: day).container
                    let hasBlocks = try bridge.db.fetchInt(
                        "SELECT COUNT(*) FROM container_block WHERE container_id = ? AND deleted_at IS NULL",
                        [entry.id])! > 0
                    if !hasBlocks, !entry.locked {
                        try bridge.ops.newBlock(in: entry.id, text: "V\(step) fresh text for \(day).", at: .end)
                    }
                case 1:  // Variorum: edit the single-unfanned entry
                    if let (_, variantID) = try canonicalEntry(day), let variantID {
                        try bridge.ops.autosave(
                            variantID, text: "V\(step) edited text for \(day).", charDelta: 8)
                    }
                case 2:  // Variorum: graduate by second block
                    if let (id, variantID) = try canonicalEntry(day), variantID != nil {
                        try bridge.ops.newBlock(in: id, text: "V\(step) second paragraph.", at: .end)
                    }
                case 3:  // Variorum: graduate by fanning
                    if let (id, variantID) = try canonicalEntry(day), let variantID {
                        // The canonical ENTRY's block (a day with duplicates
                        // has several entries; the variant lives on this one).
                        if let blockID = try bridge.db.fetchString(
                            "SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL",
                            [id]) {
                            _ = try bridge.ops.branchVariant(blockID, from: variantID)
                        }
                    }
                case 4:  // Variorum: mint a duplicate-day entry (the offline race)
                    if try liveEntryIDs(day).count == 1 {
                        let dup = try bridge.ops.createPost(profile: .journal, entryDate: day)
                        try bridge.ops.newBlock(in: dup.id, text: "V\(step) duplicate entry.", at: .end)
                    }
                case 5:  // Variorum: hand-merge (delete the newest duplicate)
                    let ids = try liveEntryIDs(day)
                    if ids.count > 1 {
                        try bridge.ops.deleteContainer(ids.last!)
                    }
                case 6:  // Fragments: the app writes a body
                    let body = "F\(step) phone text for \(day)."
                    fragmentsLedger.insert(body)
                    _ = try await bridge.server.fragmentsAppWrites(
                        configuration: bridge.config, day: day,
                        body: body, updatedAt: nextFragmentsStamp())
                default:  // Fragments: the app deletes the day
                    _ = try await bridge.server.fragmentsAppDeletes(
                        configuration: bridge.config, day: day,
                        deletedAt: nextFragmentsStamp())
                }

                if step % 5 == 4 {
                    let report = try await bridge.engine.run()
                    accumulate(&totals, report)
                    // Per-round: the pause is exactly the duplicated days.
                    let dupDays = try Set(days.filter { try liveEntryIDs($0).count > 1 })
                    #expect(Set(report.push.pausedDays) == dupDays,
                            "pausedDays must be exactly the duplicated days")
                }
            }

            // Resolve remaining duplicates (the hand-merge), then run to
            // quiescence.
            for day in days {
                let ids = try liveEntryIDs(day)
                for extra in ids.dropFirst() {
                    try bridge.ops.deleteContainer(extra)
                }
            }
            var quiesced = false
            for _ in 0..<8 {
                let report = try await bridge.engine.run()
                accumulate(&totals, report)
                let active = report.push.pushed + report.landing.created
                    + report.landing.updated + report.landing.conflictVariants
                    + report.landing.rescuedVariants
                if active == 0 {
                    quiesced = true
                    break
                }
            }
            #expect(quiesced, "the soak must reach quiescence")

            // A quiescent round makes ZERO server writes (no gratuitous
            // pushes — the clobber-guard mirror under load).
            let writesBefore = await bridge.server.acceptedWriteCount
            _ = try await bridge.engine.run()
            #expect(await bridge.server.acceptedWriteCount == writesBefore)

            // Convergence: every day agrees byte-equal across the surfaces.
            for day in days {
                let rendered = try bridge.rendered(day: day)
                let fragments = await bridge.fragmentsBody(day: day)
                if let fragments {
                    #expect(fragments == (rendered ?? ""),
                            "day \(day): Fragments body must equal Variorum's rendered text")
                } else {
                    // No live Fragments row: Variorum must have nothing to
                    // project (no entry, empty text, or an agreed emptiness).
                    #expect((rendered ?? "").isEmpty,
                            "day \(day): non-empty Variorum text must be projected")
                }
                // Hash bookkeeping consistent with the converged state.
                if let rendered, let state = try bridge.dayState(day) {
                    #expect(state == BridgeHash.body(rendered),
                            "day \(day): agreed hash must match the converged text")
                }
            }

            // Nothing invented: every bridge-minted variant's text was a
            // real Fragments body (the ledger).
            let mintedVariants = try await bridge.db.read { db in
                try String.fetchAll(
                    db,
                    sql: "SELECT working_text FROM variant WHERE label = 'fragments' AND deleted_at IS NULL")
            }
            for text in mintedVariants {
                #expect(fragmentsLedger.contains(text),
                        "a 'fragments' variant carries text Fragments never wrote")
            }

            // Non-vacuity: the soak genuinely exercised both directions.
            #expect(totals.push.pushed > 0, "the soak never pushed")
            #expect(totals.landing.created + totals.landing.updated > 0,
                    "the soak never landed")
            #expect(totals.landing.conflictVariants + totals.landing.rescuedVariants > 0,
                    "the soak never rescued a body as a variant")
        }
    }

    private func accumulate(_ totals: inout BridgeEngine.RoundReport, _ report: BridgeEngine.RoundReport) {
        totals.push.pushed += report.push.pushed
        totals.landing.created += report.landing.created
        totals.landing.updated += report.landing.updated
        totals.landing.conflictVariants += report.landing.conflictVariants
        totals.landing.rescuedVariants += report.landing.rescuedVariants
        totals.landing.skipped += report.landing.skipped
    }

    // MARK: (iii) the bridge and the mirror sync engine together

    @Test func bridgeLandingsRideTheOutboxToTheOtherDevice() async throws {
        let syncServer = FakeSyncServer()
        let mac = try SyncClient(name: "mac", prefix: "AA", transport: syncServer)
        let phone = try SyncClient(name: "phone", prefix: "BB", transport: syncServer, clockOffset: 7)

        let config = FragmentsBridgeConfiguration(
            idNamespace: UUID(uuidString: "6ba7b811-9dad-11d1-80b4-00c04fd430c8")!,
            canonicalUserKey: "author",
            userID: "user-author")
        let fragmentsServer = FakeFragmentsServer()
        let bridgeEngine = BridgeEngine(transport: fragmentsServer, configuration: config)

        // Mac authors one journal day; the phone captures another (through
        // the mirror); Fragments writes a third.
        try mac.with { ops, _ in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-01").container
            _ = try ops.newBlock(in: entry.id, text: "Mac morning entry.", at: .end)
        }
        try phone.with { ops, _ in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-02").container
            _ = try ops.newBlock(in: entry.id, text: "Phone capture entry.", at: .end)
        }
        _ = try await fragmentsServer.fragmentsAppWrites(
            configuration: config, day: "2026-07-03",
            body: "Fragments journal entry.", updatedAt: "2027-01-01T00:00:00.000Z")

        // Mirror sync first (the app's cadence), then the bridge on the Mac,
        // then mirror sync again so bridge landings replicate to the phone.
        try await syncToQuiescence(mac, phone, server: syncServer)
        _ = try await mac.withAsync { _ in try await bridgeEngine.run() }
        try await syncToQuiescence(mac, phone, server: syncServer)
        // One more bridge round so days that reached the Mac via the mirror
        // in the second sync pass (none here, but the cadence is honest)
        // project too — and to prove quiescence.
        let quiet = try await mac.withAsync { _ in try await bridgeEngine.run() }
        #expect(quiet.push.pushed == 0 && quiet.landing.created == 0)

        // The two Variorum devices are byte-identical (the Phase 5 bar) —
        // the Fragments landing is ordinary synced state.
        #expect(try mac.syncedDump() == phone.syncedDump())
        try #expect(mac.outboxCount() == 0)
        try #expect(phone.outboxCount() == 0)

        // The Fragments-authored day exists on BOTH devices.
        for client in [mac, phone] {
            let body = try client.db.fetchString("""
                SELECT v.working_text FROM variant v
                JOIN container_block cb ON cb.block_id = v.block_id AND cb.deleted_at IS NULL
                JOIN container c ON c.id = cb.container_id
                WHERE c.entry_date = '2026-07-03' AND c.deleted_at IS NULL
                """)
            #expect(body == "Fragments journal entry.", "\(client.name) missing the landed entry")
        }

        // And Fragments holds both Variorum-authored days (the phone's via
        // the mirror → Mac → bridge).
        #expect(await fragmentsServer.liveEntry(userID: config.userID, date: "2026-07-01")?.body
                == "Mac morning entry.")
        #expect(await fragmentsServer.liveEntry(userID: config.userID, date: "2026-07-02")?.body
                == "Phone capture entry.")
    }
}
