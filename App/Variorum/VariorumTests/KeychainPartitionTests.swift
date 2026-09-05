import Foundation
import Security
import Testing

@testable import Variorum

/// 13p-fix R1-3. The E2EE gated family cannot be exercised against the
/// real Keychain — its account is FIXED (`device-keys-biometric`), so a
/// test write would land on the author's live custody. That left the
/// family whose breakage caused the incident with no pin of its own:
/// nothing failed if its query lost the partition marker.
///
/// This is the structural answer, and it covers every DP-resident family
/// — including the iCloud key A (pre-13x 2a), whose family cannot be
/// pinned behaviourally in the ordinary suite either (its item is
/// synchronizable, so a real round trip would push test bytes into the
/// author's iCloud Keychain — the opt-in `AppleKeyRoundTripTests` does it
/// deliberately, under a throwaway account). The builders are `internal`
/// rather than `private` precisely so this can read them.
@Suite("Keychain partition (13p-fix)")
struct KeychainPartitionTests {
    @Test func everyDataProtectionResidentFamilyCarriesThePartitionMarker() {
        let families: [(String, [String: Any])] = [
            ("E2EE gated sync custody (14b CF-12 → pre-13x 1a, per store)",
             E2EEKeychainStorage.gatedQuery(scope: SyncCustodyScope(scope: "partition-probe", storeID: "partition-probe-store"))),
            ("E2EE bound sync custody (pre-13x 1a, per store)",
             E2EEKeychainStorage.boundQuery(scope: SyncCustodyScope(scope: "partition-probe", storeID: "partition-probe-store"))),
            ("gated store key (13p Biometric mode)",
             StoreKeyGuardKeychain.gatedQuery(scope: "partition-probe", storeID: "partition-probe-store")),
            ("the LEGACY iCloud escrow (13p R13p-6 — the migration's door only)",
             StoreKeyGuardKeychain.legacyEscrowQuery(storeID: "partition-probe")),
            ("device-bound session tokens (pre-13x 1a)",
             KeychainAuthStorage.boundQuery(service: "io.lduarte.Variorum.auth-partition-probe")),
            ("the iCloud key A (pre-13x 2a)",
             AppleKeyKeychain.query(account: "partition-probe-apple-key")),
        ]
        for (name, query) in families {
            #expect(query[kSecUseDataProtectionKeychain as String] as? Bool == true,
                    "\(name): an ACL'd or synchronizable item lives in the data-protection keychain, so every query in its family must say so — a family that disagrees with itself writes an item nothing can read, and the delete that follows destroys the only reachable copy")
        }
    }

    /// pre-13x 2a — THE APPLE-KEY QUERY FAMILY, Q5's rule (the spike,
    /// measured on macOS 26.5.2): ONE builder carrying `kSecAttrSynchronizable
    /// = true` (a flagless search never matches — a flagless DELETE is a
    /// silent no-op), the SHARED access group (a group-less write lands in
    /// the first entitled group, invisible to the phone) and the DP marker,
    /// on every verb. RED ON OLD by construction (no such family existed;
    /// the 13p escrow builder named no group).
    @Test func theAppleKeyFamilyIsOneBuilderWithTheFlagTheGroupAndTheMarker() {
        let query = AppleKeyKeychain.query(account: "partition-probe-apple-key")
        #expect(query[kSecAttrSynchronizable as String] as? Bool == true,
                "the flag decides whether the item is VISIBLE at all")
        #expect(query[kSecAttrAccessGroup as String] as? String == AppleKeyKeychain.sharedGroup,
                "the group decides WHERE a write lands — the phone reads only the shared group")
        #expect(AppleKeyKeychain.sharedGroup.hasSuffix(".io.lduarte.Variorum.shared"))
        #expect(query[kSecAttrService as String] as? String == AppleKeyKeychain.service)
        // The dev-scope discriminator rides the ACCOUNT (surprise 4): a
        // Debug build never reads the Release install's A.
        #expect(AppleKeyKeychain.account(scope: "Variorum") != AppleKeyKeychain.account(scope: "Variorum-dev"))
        #expect(AppleKeyKeychain.account(scope: "Variorum-dev").contains("Variorum-dev"))
    }

    /// The rule has ONE name, so the families cannot drift apart by
    /// editing one comment. Stated honestly (R2-NIT): this enumerates the
    /// families BY HAND, so a new DP-resident builder that forgets to merge
    /// the marker fails no test here — the guard is against drift among the
    /// known families, not against omission in a new one.
    @Test func theMarkerIsOneSharedConstant() {
        #expect(KeychainPartition.dataProtection[kSecUseDataProtectionKeychain as String]
                as? Bool == true)
    }
}
