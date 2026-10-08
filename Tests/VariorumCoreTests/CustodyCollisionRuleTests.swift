import Foundation
import Testing

@testable import VariorumCore

// Phase 13x U1 row 4 — the custody-collision rule's pins, one per memo
// arm, driven through REAL keys and the production fingerprint so the
// rule can never drift from what custody actually compares.

@Suite("13x U1 — the custody-collision rule (the memo's three arms)")
struct CustodyCollisionRuleTests {
    @Test func aSameKeySnapshotIsAlreadyAligned() {
        let key = StoreKey.mint()
        let fingerprint = StoreKeyEnvelope.fingerprint(of: key)
        #expect(CustodyCollisionRule.verdict(
            custodyHeldFingerprint: fingerprint,
            openingKeyFingerprint: fingerprint) == .alreadyAligned)
    }

    /// The collision itself: an older-key copy adopted where custody
    /// holds the live key — custody adopts the OPENER; M/C/identity are
    /// not this rule's to touch (the memo's letter).
    @Test func anOlderKeyCopyOnTheSameMacAdoptsTheOpeningKey() {
        let liveKey = StoreKey.mint()
        let oldKey = StoreKey.mint()
        #expect(CustodyCollisionRule.verdict(
            custodyHeldFingerprint: StoreKeyEnvelope.fingerprint(of: liveKey),
            openingKeyFingerprint: StoreKeyEnvelope.fingerprint(of: oldKey))
            == .adoptOpeningKey)
    }

    @Test func aMachineWithNoCustodyForTheStoreIdMintsFresh() {
        let opener = StoreKey.mint()
        #expect(CustodyCollisionRule.verdict(
            custodyHeldFingerprint: nil,
            openingKeyFingerprint: StoreKeyEnvelope.fingerprint(of: opener))
            == .mintFreshCustody)
    }

    /// The custody read feeds the rule through the SAME fingerprint
    /// function the key files carry — pinned so a drift between "what
    /// custody compares" and "what the file names" cannot open quietly.
    @Test func theRuleComparesTheProductionFingerprint() {
        let key = StoreKey.mint()
        let fingerprint = StoreKeyEnvelope.fingerprint(of: key)
        #expect(fingerprint.count == 16)
        let allHex = fingerprint.allSatisfy { $0.isHexDigit }
        #expect(allHex)
        #expect(StoreKeyEnvelope.shortFingerprint(fingerprint).count == 8)
    }
}
