import Foundation
import Testing
@testable import VariorumCore

/// Phase 14c batch 2 (L15) — THE 14D PREP's staged re-push machinery,
/// both halves per her Round-6 ruling:
///
///  - **DORMANCY**: with the structural pause in place (the engine's
///    refusing default provider — no real provider is wired anywhere in
///    production until 14d's deliberate act), staging is one inert local
///    bookkeeping write: no bridge round runs, nothing reaches the
///    transport, and the staged days simply wait.
///  - **READINESS**: the deliberate flip (a live key provider) drives a
///    full staged re-push against the fake — every agreed day re-arrives
///    on the satellite as `e1:` ciphertext re-sealed from Variorum truth,
///    including the agreed-EMPTY day (the sentinel-over-NULL design's
///    whole point).
@Suite("Bridge staged re-push from truth (Phase 14c batch 2 — the 14d prep)")
struct BridgeRestageTests {
    /// The staging marks ONLY agreed days (a real `last_synced_hash`),
    /// leaves stamp-only bookkeeping rows and their LWW stamps untouched,
    /// and is idempotent.
    @Test func stagingMarksOnlyAgreedDaysPreservesStampsAndIsIdempotent() async throws {
        try await withBridge { bridge in
            try await bridge.db.write { db in
                try BridgeEngine.recordDay(
                    db, dayKey: "2026-08-01", hash: "aaaa1111",
                    remoteStamp: "2026-08-01T00:00:00Z", remoteCreatedAt: "2026-07-30T00:00:00Z")
                try BridgeEngine.recordDay(
                    db, dayKey: "2026-08-02", hash: nil, remoteStamp: "2026-08-02T00:00:00Z")
            }
            let staged = try await bridge.db.write { db in
                try BridgeEngine.stageRepushFromTruth(db)
            }
            #expect(staged == 1, "only the AGREED day stages")

            let agreed = try await bridge.db.read { db in
                try BridgeEngine.dayRow(db, dayKey: "2026-08-01")
            }
            #expect(agreed?.hash == BridgeEngine.restagedHashSentinel)
            #expect(agreed?.remoteStamp == "2026-08-01T00:00:00Z",
                    "the LWW stamp survives — the re-push must outrank exactly what it always did")
            #expect(agreed?.remoteCreatedAt == "2026-07-30T00:00:00Z",
                    "the created_at echo survives too")
            let stampOnly = try await bridge.db.read { db in
                try BridgeEngine.dayRow(db, dayKey: "2026-08-02")
            }
            #expect(stampOnly?.hash == nil,
                    "a stamp-only row is bookkeeping, not an agreement — never staged")

            let again = try await bridge.db.write { db in
                try BridgeEngine.stageRepushFromTruth(db)
            }
            #expect(again == 0, "idempotent — an already-staged day never counts again")
        }
    }

    /// READINESS: a quiesced day (agreed, unchanged — the standing
    /// unchanged-never-pushes guard proven first) re-pushes after staging,
    /// re-sealed from truth; the identical-body receipt the fake emits
    /// (ciphertext bytes differ under a fresh nonce) is absorbed by
    /// discrimination rule (ii) — no spurious rescue; and the day settles
    /// back to a REAL agreed hash, so the next round is quiet again.
    @Test func aStagedDayRepushesFromTruthOverCiphertextAndSettles() async throws {
        try await withBridge { bridge in
            let day = "2026-08-01"
            _ = try bridge.makeEntry(day: day, text: "The words that must re-arrive.")
            _ = try await bridge.engine.run()
            _ = try await bridge.engine.run()  // quiesce (cursor past the echo)
            let writesBefore = await bridge.server.acceptedWriteCount
            _ = try await bridge.engine.run()
            #expect(await bridge.server.acceptedWriteCount == writesBefore,
                    "quiesced and unchanged: nothing pushes — the guard the staging deliberately bypasses")

            let staged = try await bridge.db.write { db in
                try BridgeEngine.stageRepushFromTruth(db)
            }
            #expect(staged == 1)
            let report = try await bridge.engine.run()
            #expect(report.push.pushed == 1, "the staged day re-pushes from truth")
            #expect(report.push.rescuedReceipts == 0,
                    "the identical-body receipt is absorbed by rule (ii) — never a spurious rescue")
            #expect(await bridge.server.acceptedWriteCount == writesBefore + 1)

            // The wire body is ciphertext; it opens to the rendered truth.
            let wire = try #require(await bridge.fragmentsWireBody(day: day))
            #expect(PayloadCipher.isEncrypted(wire))
            #expect(try BridgeTestKeys.opened(wire, day: day) == "The words that must re-arrive.")
            // No duplicate takes were minted by the re-push's receipt.
            let blockID = try #require(try bridge.firstBlockID(day: day))
            #expect(try bridge.liveVariants(blockID: blockID).count == 1)

            // Settled: the agreed hash is REAL again; the next round is quiet.
            #expect(try bridge.dayState(day) == BridgeHash.body("The words that must re-arrive."))
            let quiet = try await bridge.engine.run()
            #expect(quiet.push.pushed == 0)
        }
    }

    /// THE SENTINEL-OVER-NULL DESIGN PIN: an agreed-EMPTY day re-pushes
    /// its sealed emptiness after staging (over whatever dead-key body the
    /// satellite held), while an UNSTAGED virgin empty day still never
    /// first-pushes emptiness — the standing guard keeps its exact scope.
    @Test func anAgreedEmptyDayRepushesSealedEmptinessOnlyWhenStaged() async throws {
        try await withBridge { bridge in
            let day = "2026-08-03"
            _ = try bridge.ops.createOrOpenJournalEntry(entryDate: day)

            // Virgin (no bridge_day row): emptiness never first-pushes.
            let virgin = try await bridge.engine.push()
            #expect(virgin.pushed == 0, "the never-first-push-of-emptiness guard holds")

            // An AGREED-empty day (the pre-re-key world had settled on
            // emptiness), then staged: the emptiness re-pushes SEALED.
            try await bridge.db.write { db in
                try BridgeEngine.recordDay(
                    db, dayKey: day, hash: BridgeHash.body(""),
                    remoteStamp: "2026-08-03T00:00:00Z")
            }
            let unstagedRound = try await bridge.engine.push()
            #expect(unstagedRound.pushed == 0, "agreed-and-unchanged still never pushes")

            _ = try await bridge.db.write { db in
                try BridgeEngine.stageRepushFromTruth(db)
            }
            let stagedRound = try await bridge.engine.push()
            #expect(stagedRound.pushed == 1,
                    "the staged empty day re-pushes — a NULLed hash would have hit the emptiness guard instead")
            let wire = try #require(await bridge.fragmentsWireBody(day: day))
            #expect(PayloadCipher.isEncrypted(wire), "even emptiness travels sealed")
            #expect(try BridgeTestKeys.opened(wire, day: day) == "")
        }
    }

    /// DORMANCY: under the engine's refusing default provider (the
    /// 14b–14c structural pause's mechanism; since the 14d un-pause the
    /// keyless states — unenrolled, CF-12-locked, tests), staging
    /// changes NOTHING observable: the round refuses before any network
    /// contact, and the staged days wait intact.
    @Test func stagingIsInertWhileKeysAreUnavailable() async throws {
        try await withBridge { bridge in
            _ = try bridge.makeEntry(day: "2026-08-04", text: "waits for keys")
            try await bridge.db.write { db in
                try BridgeEngine.recordDay(
                    db, dayKey: "2026-08-04", hash: "beef0000", remoteStamp: nil)
                _ = try BridgeEngine.stageRepushFromTruth(db)
            }
            // The keyless engine — the refusing default. (This WAS the
            // Mac's production composition through the 14b→14c structural
            // pause; since the 14d un-pause production wires the live
            // provider, and this pin covers the states that still read as
            // keyless: an unenrolled device, a CF-12-locked launch, and
            // any test composition passing no provider.)
            let keyless = BridgeEngine(
                transport: bridge.server, configuration: bridge.config)
            await #expect(throws: BridgeEncryptionError.keysUnavailable) {
                _ = try await keyless.run()
            }
            #expect(await bridge.server.acceptedWriteCount == 0,
                    "no round ran — nothing reached the transport")
            let row = try await bridge.db.read { db in
                try BridgeEngine.dayRow(db, dayKey: "2026-08-04")
            }
            #expect(row?.hash == BridgeEngine.restagedHashSentinel,
                    "the staged day waits, intact, for the keys to arrive")
        }
    }
}
