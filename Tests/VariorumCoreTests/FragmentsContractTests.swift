import Foundation
import Testing
@testable import VariorumCore

/// Phase 9b, Step 1 — the deterministic-id derivation (the join key's whole
/// trick: both apps must derive the SAME id for the same user + day, or
/// same-day creates can never converge to one row).
///
/// RECONCILED 2026-07-09: the Fragments agents answered asks 8–10 — the
/// REAL namespace is pinned, derivation parity is CONFIRMED (their Swift ==
/// their Postgres == python == this implementation, via the URL-namespace
/// cross-check vector), and their three journal test vectors are the
/// goldens below. Case is LOAD-BEARING: their pipeline `bcased()`s the name
/// (lowercase) — `entryID` mirrors that, pinned by the case vectors.
@Suite("Fragments contract: deterministic id derivation (Phase 9b, Step 1)")
struct FragmentsContractTests {
    /// The RFC 4122 DNS namespace — the standard's own constant, used here
    /// only to verify the ALGORITHM against the universally-published
    /// vector (python's `uuid.uuid5(NAMESPACE_DNS, "python.org")`).
    private static let dnsNamespace = UUID(uuidString: "6ba7b810-9dad-11d1-80b4-00c04fd430c8")!
    /// The RFC URL namespace — the parity cross-check the Fragments agents
    /// verified against THEIR implementation (their §2.1 vectors): same
    /// input, same id, on both sides of the bridge.
    private static let urlNamespace = UUID(uuidString: "6ba7b811-9dad-11d1-80b4-00c04fd430c8")!
    /// A confirmed test-vector canonical user (lowercased UUID text, their
    /// convention).
    private static let vectorUser = "9f1c2b3a-4d5e-6f70-8192-a3b4c5d6e7f8"

    @Test func uuidV5AlgorithmMatchesTheRFCVector() {
        let derived = UUIDv5.derive(namespace: Self.dnsNamespace, name: "python.org")
        #expect(derived.uuidString.lowercased() == "886313e1-3b8a-5372-9b90-0c9aee199e5d")
    }

    @Test func versionAndVariantBitsAreV5() {
        let derived = UUIDv5.derive(namespace: Self.urlNamespace, name: "anything at all")
        let bytes = withUnsafeBytes(of: derived.uuid) { Array($0) }
        #expect(bytes[6] >> 4 == 0x5, "version nibble must be 5")
        #expect(bytes[8] & 0xC0 == 0x80, "variant must be RFC 4122")
    }

    @Test func entryNameComposesExactlyTheContractRecipe() {
        #expect(FragmentsContract.entryName(canonicalUser: "alice", dayKey: "2026-07-09")
                == "journal|alice|2026-07-09")
    }

    /// The PARITY cross-check (their agents verified this exact vector
    /// against their Swift and Postgres implementations): same recipe, same
    /// URL namespace, same id on both sides of the bridge.
    @Test func parityVectorMatchesTheFragmentsImplementation() {
        #expect(FragmentsContract.entryID(
            namespace: Self.urlNamespace, canonicalUser: "alice", dayKey: "2026-07-09")
                == "efd1b644-d604-5272-860d-ab4061668e96")
    }

    /// THE journal goldens — the Fragments agents' own test vectors under
    /// the REAL namespace (ask 9 ANSWERED). Same inputs, same id, on every
    /// device, in both apps, forever (their ID FREEZE).
    @Test func journalVectorsUnderTheRealNamespace() {
        func derive(_ user: String, _ day: String) -> String? {
            FragmentsContract.entryID(
                namespace: FragmentsContract.fragmentsNamespace,
                canonicalUser: user, dayKey: day)
        }
        #expect(FragmentsContract.fragmentsNamespace
                == UUID(uuidString: "7B69C1E4-9C72-4D2F-9B3A-2A41F0F4C0DE"))
        #expect(derive(Self.vectorUser, "2026-07-09")
                == "7ab43871-10ad-5597-a0d7-d721fcd3ecf9")
        #expect(derive(Self.vectorUser, "2026-01-05")
                == "25cf2660-aa22-5057-97a9-e34fc11e5198")
        #expect(derive("11111111-1111-1111-1111-111111111111", "2026-07-09")
                == "317235d4-855b-53e9-8e2b-fc6cfd9be899")
    }

    /// Case is LOAD-BEARING at the hash level (ask 10): the raw UUIDv5 of
    /// the UPPERCASED name is a DIFFERENT (wrong) id — their vector — while
    /// `entryID` lowercases the name (mirroring their `bcased()`), so a
    /// mis-cased canonical user still derives the ONE true id.
    @Test func caseHandlingMirrorsBcased() {
        let uppercasedName = "journal|9F1C2B3A-4D5E-6F70-8192-A3B4C5D6E7F8|2026-07-09"
        #expect(UUIDv5.derive(
            namespace: FragmentsContract.fragmentsNamespace, name: uppercasedName)
            .uuidString.lowercased()
                == "a1f076a6-26b1-5ded-bb42-2521ecaaa2d3",
                "raw case-sensitivity — the WRONG id their vector demonstrates")
        #expect(FragmentsContract.entryID(
            namespace: FragmentsContract.fragmentsNamespace,
            canonicalUser: "9F1C2B3A-4D5E-6F70-8192-A3B4C5D6E7F8",
            dayKey: "2026-07-09")
                == "7ab43871-10ad-5597-a0d7-d721fcd3ecf9",
                "entryID lowercases the name — a mis-cased input derives the true id")
    }

    @Test func idsAreEmittedLowercase() throws {
        let id = try #require(FragmentsContract.entryID(
            namespace: FragmentsContract.fragmentsNamespace,
            canonicalUser: Self.vectorUser, dayKey: "2026-07-09"))
        #expect(id == id.lowercased(), "Postgres uuid canonical text form is lowercase")
    }

    /// The day-key canon: only strict "yyyy-MM-dd" may derive an id — a
    /// malformed key can never join, so no id may exist for it (the same
    /// boundary `createOrOpenJournalEntry` enforces).
    @Test func malformedDayKeysDeriveNothing() {
        for bad in ["2026-7-9", "2026/07/09", "20260709", "2026-02-30", "", "today"] {
            #expect(FragmentsContract.entryID(
                namespace: FragmentsContract.fragmentsNamespace,
                canonicalUser: Self.vectorUser, dayKey: bad) == nil,
                    "\(bad) must not derive an id")
        }
    }

    @Test func configurationDefaultsToTheRealNamespace() {
        let config = FragmentsBridgeConfiguration(userID: "user-1")
        #expect(config.idNamespace == FragmentsContract.fragmentsNamespace)
    }

    @Test func bodyHashIsStableSHA256Hex() {
        // Independently computed: echo -n "hello" | shasum -a 256
        #expect(BridgeHash.body("hello")
                == "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
        #expect(BridgeHash.body("")
                == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        #expect(BridgeHash.body("hello") != BridgeHash.body("hello "))
    }
}
