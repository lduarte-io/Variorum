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
/// This is the structural answer, and it covers all THREE families —
/// including escrow, which cannot be pinned behaviourally either (its
/// item is synchronizable, so a real round trip would push test bytes
/// into the author's iCloud Keychain). The builders are `internal`
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
            ("iCloud escrow (13p R13p-6)",
             StoreKeyGuardKeychain.escrowQuery(storeID: "partition-probe")),
            ("device-bound session tokens (pre-13x 1a)",
             KeychainAuthStorage.boundQuery(service: "io.lduarte.Variorum.auth-partition-probe")),
        ]
        for (name, query) in families {
            #expect(query[kSecUseDataProtectionKeychain as String] as? Bool == true,
                    "\(name): an ACL'd or synchronizable item lives in the data-protection keychain, so every query in its family must say so — a family that disagrees with itself writes an item nothing can read, and the delete that follows destroys the only reachable copy")
        }
    }

    /// The rule has ONE name, so the three families cannot drift apart by
    /// editing one comment. Stated honestly (R2-NIT): this enumerates
    /// three families BY HAND, so a fourth DP-resident builder that forgets
    /// to merge the marker fails no test here — the guard is against drift
    /// among the known families, not against omission in a new one.
    @Test func theMarkerIsOneSharedConstant() {
        #expect(KeychainPartition.dataProtection[kSecUseDataProtectionKeychain as String]
                as? Bool == true)
    }
}
