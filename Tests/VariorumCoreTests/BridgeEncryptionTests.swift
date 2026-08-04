import CryptoKit
import Foundation
import Testing
@testable import VariorumCore

/// Phase 14b batch 3 (L11) — the bridge's journal-class E2EE capability:
/// the structural pause (the default provider refuses before any network
/// contact), ciphertext on the wire under the touchpoint-#2 AAD
/// convention, decrypt-on-land for bodies AND receipts, the legacy-
/// plaintext rule, and the tamper refusals. The broader crown is the
/// EXISTING bridge suite set running green over ciphertext (the harness
/// binds the fixed journal key).
@Suite("Bridge journal-class E2EE (Phase 14b, L11)")
struct BridgeEncryptionTests {

    /// A transport that counts contact — the keys-first pin's witness.
    private actor CountingBridgeTransport: FragmentsBridgeTransport {
        private(set) var calls = 0
        func push(_ entries: [FragmentsEntry]) async throws -> FragmentsPushResponse {
            calls += 1
            return FragmentsPushResponse(applied: entries.count, skipped: 0)
        }
        func pull(after cursor: FragmentsPullCursor?, limit: Int) async throws -> [FragmentsEntry] {
            calls += 1
            return []
        }
        func delete(ids: [String]) async throws -> Int {
            calls += 1
            return 0
        }
        func fetchLocalUserID() async throws -> String? {
            calls += 1
            return nil
        }
    }

    /// THE PAUSE IS STRUCTURAL (and the wiring pin — fails without the
    /// keys-first gating): an engine nobody wired keys into refuses every
    /// round half BEFORE any network contact, in the visible grammar.
    /// This is the phase's designed bridge pause: the app wires no real
    /// provider until the one-batch Fragments handoff.
    @Test func theDefaultProviderRefusesEveryRoundBeforeAnyTransportContact() async throws {
        try await withOperationsAsync { _, _ in
            let transport = CountingBridgeTransport()
            let engine = BridgeEngine(
                transport: transport,
                configuration: FragmentsBridgeConfiguration(userID: "user-author"))
            await #expect(throws: BridgeEncryptionError.keysUnavailable) {
                try await engine.run()
            }
            await #expect(throws: BridgeEncryptionError.keysUnavailable) {
                try await engine.pullAndLand()
            }
            await #expect(throws: BridgeEncryptionError.keysUnavailable) {
                try await engine.push()
            }
            #expect(await transport.calls == 0,
                    "keys are checked FIRST — a paused bridge makes zero network contact")
            // The visible grammar: the status row renders this verbatim.
            #expect(String(describing: BridgeEncryptionError.keysUnavailable)
                .hasPrefix("Bridge paused:"))
            #expect(String(describing: BridgeEncryptionError.keysUnavailable)
                .contains("Nothing is lost while paused"))
        }
    }

    /// The wire never carries her words; the AAD binds the DAY (the
    /// touchpoint-#2 convention: journal_entries:<date>:body:<key_id>), so
    /// a ciphertext cannot be moved between days undetected.
    @Test func pushedBodiesAreCiphertextBoundToTheirDay() async throws {
        try await withBridge { bridge in
            try bridge.makeEntry(day: "2026-07-09", text: "Her words, never on the wire.")
            _ = try await bridge.engine.push()

            let wire = try #require(await bridge.fragmentsWireBody(day: "2026-07-09"))
            #expect(PayloadCipher.isEncrypted(wire))
            #expect(!wire.contains("Her words"))
            // Opens under ITS day…
            #expect(try BridgeCrypto.openLanded(
                wire, day: "2026-07-09", keys: BridgeTestKeys.keys)
                == "Her words, never on the wire.")
            // …and REFUSES under any other day (the AAD binding).
            #expect(throws: PayloadCipherError.authenticationFailed) {
                _ = try PayloadCipher.open(
                    wire, key: BridgeTestKeys.journalKey,
                    binding: BridgeCrypto.binding(
                        day: "2026-07-10", keyID: BridgeTestKeys.journalKeyID))
            }
        }
    }

    /// A post-E2EE Fragments client's write (sealed under the shared
    /// journal-bridge key, the touchpoint-#2 shape) lands as PLAINTEXT in
    /// the Variorum store through the ordinary doors.
    @Test func anEncryptedFragmentsWriteLandsAsPlaintext() async throws {
        try await withBridge { bridge in
            _ = try await bridge.server.fragmentsAppWrites(
                userID: "user-author", day: "2026-07-09",
                body: try BridgeTestKeys.seal("Typed on the phone, encrypted.", day: "2026-07-09"),
                updatedAt: bridge.fragmentsStamp(1))
            let report = try await bridge.engine.pullAndLand()
            #expect(report.created == 1)
            #expect(try bridge.rendered(day: "2026-07-09")
                == "Typed on the phone, encrypted.")
        }
    }

    /// THE LEGACY RULE, pinned explicitly: a plaintext body (a pre-E2EE row
    /// or an interim Fragments-era write — journal_entries is never wiped)
    /// lands verbatim rather than jamming the cursor.
    @Test func legacyPlaintextBodiesStillLand() async throws {
        try await withBridge { bridge in
            _ = try await bridge.server.fragmentsAppWrites(
                userID: "user-author", day: "2026-07-08",
                body: "A pre-E2EE body, plain on the wire.",
                updatedAt: bridge.fragmentsStamp(1))
            let report = try await bridge.engine.pullAndLand()
            #expect(report.created == 1)
            #expect(try bridge.rendered(day: "2026-07-08")
                == "A pre-E2EE body, plain on the wire.")
        }
    }

    /// Cold-pass NIT-1's red-on-old: a legacy plaintext body whose first
    /// character run is a NON-ASCII numeral ("e²: …") is NOT a version
    /// prefix — it must land as legacy plaintext, not refuse as
    /// `unsupportedVersion("e²:")`. Pre-fix, `foreignVersionPrefix` scanned
    /// with bare `Character.isNumber` (true for superscripts/fractions/
    /// non-ASCII numerals), so this body refused the round — this test RED
    /// on that code; post-fix the scan is ASCII-only and the body rides the
    /// `.notEncrypted` legacy arm.
    @Test func aNonASCIINumeralBodyLandsAsLegacyPlaintextNotAVersionRefusal() async throws {
        try await withBridge { bridge in
            _ = try await bridge.server.fragmentsAppWrites(
                userID: "user-author", day: "2026-07-08",
                body: "e²: second draft, plain on the wire.",
                updatedAt: bridge.fragmentsStamp(1))
            let report = try await bridge.engine.pullAndLand()
            #expect(report.created == 1)
            #expect(try bridge.rendered(day: "2026-07-08")
                == "e²: second draft, plain on the wire.")
        }
    }

    /// R1-4's red-on-old: a FUTURE-version ciphertext body (`e2:…`) must
    /// never land verbatim as the day's journal text. Pre-fix, `openLanded`
    /// guarded on the exact-`e1:` `isEncrypted` check, so an `e2:` value
    /// fell to the plaintext pass-through and ciphertext soup became the
    /// entry; post-fix the pass-through rides ONLY `PayloadCipher.open`'s
    /// `.notEncrypted` arm and `unsupportedVersion` refuses the round with
    /// the cursor held (behavioral-revert verified: restoring the old guard
    /// makes this test fail on the landed `e2:AAAA` body).
    @Test func aFutureVersionCiphertextBodyRefusesTheRoundInsteadOfLanding() async throws {
        try await withBridge { bridge in
            _ = try await bridge.server.fragmentsAppWrites(
                userID: "user-author", day: "2026-07-09",
                body: "e2:AAAA", updatedAt: bridge.fragmentsStamp(1))

            await #expect(throws: PayloadCipherError.unsupportedVersion("e2:")) {
                try await bridge.engine.pullAndLand()
            }
            #expect(try bridge.rendered(day: "2026-07-09") == nil,
                    "ciphertext soup never becomes the day's text")
            let cursor = try await bridge.db.read { try BridgeEngine.cursor($0) }
            #expect(cursor == nil, "the cursor holds before the refused row")
        }
    }

    /// A tampered `e1:` body REFUSES the round — nothing unauthenticated
    /// ever lands; the cursor holds so the row re-serves (visibly failing)
    /// until the server-side fault is addressed.
    @Test func aTamperedCiphertextBodyRefusesTheRoundWithNothingLanded() async throws {
        try await withBridge { bridge in
            var sealed = try BridgeTestKeys.seal("The true text.", day: "2026-07-09")
            // Flip a character inside the base64 body.
            let index = sealed.index(sealed.endIndex, offsetBy: -4)
            sealed = sealed.replacingCharacters(
                in: index..<sealed.index(after: index),
                with: sealed[index] == "A" ? "B" : "A")
            _ = try await bridge.server.fragmentsAppWrites(
                userID: "user-author", day: "2026-07-09",
                body: sealed, updatedAt: bridge.fragmentsStamp(1))

            await #expect(throws: (any Error).self) {
                try await bridge.engine.pullAndLand()
            }
            #expect(try bridge.rendered(day: "2026-07-09") == nil,
                    "nothing unauthenticated lands")
            let cursor = try await bridge.db.read { try BridgeEngine.cursor($0) }
            #expect(cursor == nil, "the cursor holds before the refused row")
        }
    }

    /// Rule (iii) over ciphertext: an UNSEEN post-E2EE Fragments save
    /// destroyed by our winning push comes back as an encrypted receipt
    /// body — opened at the seam, rescued as a PLAINTEXT 'fragments' take.
    @Test func anEncryptedUnseenReceiptBodyRescuesThePlaintext() async throws {
        try await withBridge { bridge in
            _ = try await bridge.server.fragmentsAppWrites(
                userID: "user-author", day: "2026-07-09",
                body: try BridgeTestKeys.seal("Encrypted, never pulled.", day: "2026-07-09"),
                updatedAt: "2020-01-01T00:00:00.000Z")  // loses LWW to our push
            try bridge.makeEntry(day: "2026-07-09", text: "Written in Variorum.")
            let report = try await bridge.engine.push()
            #expect(report.pushed == 1)
            #expect(report.rescuedReceipts == 1)
            let blockID = try bridge.firstBlockID(day: "2026-07-09")!
            let variants = try bridge.liveVariants(blockID: blockID)
            #expect(variants.map(\.text)
                == ["Written in Variorum.", "Encrypted, never pulled."],
                "the rescue lands WORDS, never ciphertext")
            #expect(variants.map(\.label) == [nil, "fragments"])
        }
    }

    /// The never-throw receipt doctrine holds at the crypto arm: an
    /// UNOPENABLE `e1:` receipt body (tamper/corruption — it is the only
    /// copy) is preserved durably VERBATIM and spoken, never dropped and
    /// never a thrown round.
    @Test func anUnopenableReceiptBodyIsPreservedVerbatim() async throws {
        try await withBridge { bridge in
            // A corrupted-looking `e1:` body sitting live on the server
            // with an old stamp — our push wins and draws the receipt.
            _ = try await bridge.server.fragmentsAppWrites(
                userID: "user-author", day: "2026-07-09",
                body: "e1:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                updatedAt: "2020-01-01T00:00:00.000Z")
            try bridge.makeEntry(day: "2026-07-09", text: "Written in Variorum.")
            let report = try await bridge.engine.push()
            #expect(report.pushed == 1, "the push itself succeeds — never a thrown round")
            #expect(report.rescuedReceipts == 0)
            #expect(report.notes.contains { $0.contains("could not be decrypted") })
            // Durable, poison-note style: it re-surfaces every round.
            let preserved = try await bridge.db.read { try BridgeEngine.unrescuedBodyNotes($0) }
            #expect(preserved.count == 1)
            #expect(preserved[0].contains("e1:AAAA"))
        }
    }
}
