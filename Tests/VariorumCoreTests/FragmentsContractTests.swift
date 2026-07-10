import Foundation
import Testing
@testable import VariorumCore

/// Phase 9b, Step 1 — the deterministic-id derivation (the join key's whole
/// trick: both apps must derive the SAME id for the same user + day, or
/// same-day creates can never converge to one row).
///
/// **Contract finding, recorded honestly:** the plan expected these tests to
/// pin "the contract's worked examples", but `notes/fragments-bridge-contract.md`
/// pins the RECIPE (`UUIDv5("journal|<canonical-user>|<dayKey>")`) without
/// the namespace UUID or any worked example. So these tests pin what IS
/// pinnable today: (1) the RFC 4122 §4.3 algorithm against the standard's
/// lineage vector, (2) the recipe's exact composition, and (3) frozen golden
/// vectors computed under a stand-in namespace — listed verbatim in the
/// contract file's asks for the Fragments agents to confirm against their
/// implementation (with their real namespace) before the post-9c real pass.
@Suite("Fragments contract: deterministic id derivation (Phase 9b, Step 1)")
struct FragmentsContractTests {
    /// The RFC 4122 DNS namespace — the standard's own constant, used here
    /// only to verify the ALGORITHM against the universally-published
    /// vector (python's `uuid.uuid5(NAMESPACE_DNS, "python.org")`).
    private static let dnsNamespace = UUID(uuidString: "6ba7b810-9dad-11d1-80b4-00c04fd430c8")!
    /// Stand-in namespace for the golden vectors below (the RFC URL
    /// namespace). The REAL namespace is Fragments' — author-supplied
    /// configuration; contract ask #A1.
    private static let standInNamespace = UUID(uuidString: "6ba7b811-9dad-11d1-80b4-00c04fd430c8")!

    @Test func uuidV5AlgorithmMatchesTheRFCVector() {
        let derived = UUIDv5.derive(namespace: Self.dnsNamespace, name: "python.org")
        #expect(derived.uuidString.lowercased() == "886313e1-3b8a-5372-9b90-0c9aee199e5d")
    }

    @Test func versionAndVariantBitsAreV5() {
        let derived = UUIDv5.derive(namespace: Self.standInNamespace, name: "anything at all")
        let bytes = withUnsafeBytes(of: derived.uuid) { Array($0) }
        #expect(bytes[6] >> 4 == 0x5, "version nibble must be 5")
        #expect(bytes[8] & 0xC0 == 0x80, "variant must be RFC 4122")
    }

    @Test func entryNameComposesExactlyTheContractRecipe() {
        #expect(FragmentsContract.entryName(canonicalUser: "alice", dayKey: "2026-07-09")
                == "journal|alice|2026-07-09")
    }

    /// Golden vectors frozen 2026-07-09 (computed independently with
    /// python3 `uuid.uuid5` under the stand-in namespace) — listed in the
    /// contract file for Fragments-side confirmation. Distinct users and
    /// distinct days must yield distinct ids; the same inputs the same id,
    /// on every device, forever.
    @Test func goldenVectorsUnderTheStandInNamespace() {
        func derive(_ user: String, _ day: String) -> String? {
            FragmentsContract.entryID(
                namespace: Self.standInNamespace, canonicalUser: user, dayKey: day)
        }
        #expect(derive("alice", "2026-07-09") == "efd1b644-d604-5272-860d-ab4061668e96")
        #expect(derive("alice", "2026-07-10") == "e0c414b0-cf5f-5893-b20c-ee5525cd60e4")
        #expect(derive("bob", "2026-07-09") == "40b446b4-5dfe-501c-ba06-a96a0bb3630c")
        // Non-ASCII canonical users hash their UTF-8 bytes.
        #expect(derive("áuser", "2026-01-01") == "3404e4fe-fbc8-50d6-ae96-231aca90551c")
    }

    @Test func idsAreEmittedLowercase() throws {
        let id = try #require(FragmentsContract.entryID(
            namespace: Self.standInNamespace, canonicalUser: "alice", dayKey: "2026-07-09"))
        #expect(id == id.lowercased(), "Postgres uuid canonical text form is lowercase")
    }

    /// The day-key canon: only strict "yyyy-MM-dd" may derive an id — a
    /// malformed key can never join, so no id may exist for it (the same
    /// boundary `createOrOpenJournalEntry` enforces).
    @Test func malformedDayKeysDeriveNothing() {
        for bad in ["2026-7-9", "2026/07/09", "20260709", "2026-02-30", "", "today"] {
            #expect(FragmentsContract.entryID(
                namespace: Self.standInNamespace, canonicalUser: "alice", dayKey: bad) == nil,
                    "\(bad) must not derive an id")
        }
    }

    @Test func configurationDerivesThroughTheSameDoor() {
        let config = FragmentsBridgeConfiguration(
            idNamespace: Self.standInNamespace, canonicalUserKey: "alice", userID: "user-1")
        #expect(config.entryID(dayKey: "2026-07-09") == "efd1b644-d604-5272-860d-ab4061668e96")
        #expect(config.entryID(dayKey: "not-a-day") == nil)
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
