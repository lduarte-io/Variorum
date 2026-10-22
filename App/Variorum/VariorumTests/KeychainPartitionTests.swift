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
/// author's iCloud Keychain — the opt-in `AppleKeyRoundTripTests` did it
/// deliberately, under a throwaway account). The builders are `internal`
/// rather than `private` precisely so this can read them. VX-329 U1: today's
/// families left with today's road; the session tokens' family and the one
/// shared marker stand here.
@Suite("Keychain partition (13p-fix)")
struct KeychainPartitionTests {
    @Test func everyDataProtectionResidentFamilyCarriesThePartitionMarker() {
        // VX-329 U1: today's custody families (the E2EE gated and bound sync custody, the gated store key, the legacy
        // iCloud escrow, today's iCloud key A) were deleted with today's road; the protection road's own families
        // (`ProtectionKeychain`) are pinned in `ProtectionKeychainFamilyTests`. The session tokens' family stands.
        let families: [(String, [String: Any])] = [
            ("device-bound session tokens (pre-13x 1a; scoped per store variant at 2c)",
             KeychainAuthStorage.boundQuery(service: "io.lduarte.Variorum.auth-partition-probe", scope: "partition-probe")),
        ]
        for (name, query) in families {
            #expect(query[kSecUseDataProtectionKeychain as String] as? Bool == true,
                    "\(name): an ACL'd or synchronizable item lives in the data-protection keychain, so every query in its family must say so — a family that disagrees with itself writes an item nothing can read, and the delete that follows destroys the only reachable copy")
        }
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
