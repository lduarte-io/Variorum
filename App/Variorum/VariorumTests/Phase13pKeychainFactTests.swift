//
//  Phase13pKeychainFactTests.swift
//  VariorumTests
//
//  Phase 13p, Batch 2 (commit 6) — THE Q3 CODESIGNED RE-CONFIRMATION
//  (the spike memo's named PENDING), header brought current at the
//  pre-13u round (Act 9, F5 — the old text described the pre-signing
//  world in the present tense). The spike's probe ran from an UNSIGNED
//  CLI, where the three controls all died at the entitlement check
//  (-34018) and only the question probe's DIFFERENT status (-50,
//  errSecParam) discriminated. This suite runs inside the SIGNED app
//  test host, and SINCE 2026-08-30 the app carries a real keychain
//  identity (`keychain-access-groups` + the Mac Development profile —
//  the 13p signing gap, closed by the author): the PLAIN control
//  genuinely succeeds, the ACL control now asserts its write LANDS —
//  it is the REGRESSION GUARD for the identity itself (a -34018 there
//  means the entitlement, the profile, or this Mac's device
//  registration was lost) — and the question probe still reads -50,
//  pinning the two-item design (R13p-6) as platform fact:
//  `kSecAttrSynchronizable` + `kSecAttrAccessControl` is refused as a
//  COMBINATION, so the escrow item necessarily has no biometric gate.
//
//  PROMPT DISCIPLINE (the overnight rule): every probe here is a WRITE
//  or a delete — an ACL'd item's creation never prompts (only reading
//  its data does, and nothing here reads one). The synchronizable-only
//  control from the spike is deliberately NOT repeated: in a signed
//  host it would land a real item in the login keychain marked for
//  iCloud sync — test bytes riding into the author's iCloud Keychain
//  is pollution the discrimination doesn't need (the plain control
//  proves writes succeed; the question probe fails before creating
//  anything).
//
//  Everything lives under a THROWAWAY service, deleted in defer —
//  never the store-key or E2EE custody services.
//

import Foundation
import LocalAuthentication
import Security
import Testing
import VariorumCore

@testable import Variorum

@Suite("13p — keychain platform facts: the two-item design, and which keychain a family lives in")
struct Phase13pKeychainFactTests {
    private static let probeService = "io.lduarte.Variorum.13p-q3-probe"

    private func query(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.probeService,
            kSecAttrAccount as String: account,
        ]
    }

    /// 13p-fix: an ACL'd add lands in the DATA-PROTECTION keychain, so a
    /// delete without the flag searched the file-based one and could never
    /// remove what this suite created — every run since the keychain
    /// identity landed left an ACL'd item resident. Sweep BOTH keychains.
    private func deleteProbe(account: String, synchronizable: Bool = false) {
        for dataProtection in [false, true] {
            var q = query(account: account)
            if synchronizable { q[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny }
            if dataProtection { q[kSecUseDataProtectionKeychain as String] = true }
            SecItemDelete(q as CFDictionary)
        }
    }

    /// Control A: a plain add SUCCEEDS in the signed host — the fact that
    /// separates this environment from the spike's unsigned CLI (-34018)
    /// and makes the question probe's refusal attributable to the
    /// PARAMETERS, not the environment.
    @Test func aPlainAddSucceedsInTheSignedHost() {
        let account = "plain-\(UUID().uuidString)"
        defer { deleteProbe(account: account) }
        var attributes = query(account: account)
        attributes[kSecValueData as String] = Data("probe".utf8)
        attributes[kSecAttrAccessible as String] =
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(attributes as CFDictionary, nil)
        #expect(status == errSecSuccess,
                "the signed host writes plainly (got \(status))")
    }

    /// Control C — THE FINDING, AND ITS CLOSE. An ACL'd item can only
    /// live in the DATA-PROTECTION keychain, and on macOS an app is
    /// admitted there only with a keychain access group — which is what
    /// forces a provisioning profile onto the signature. Batch 2 found
    /// the app carried NO such identity, so this write returned
    /// `errSecMissingEntitlement` (-34018) and the Biometric mode's
    /// gated item, the synchronizable escrow item, and 14b's CF-12 vault
    /// gate all refused honestly on the Mac (QUESTIONS #81(a)).
    ///
    /// CLOSED 2026-08-30 by the author: `Variorum.entitlements` gained
    /// `keychain-access-groups` = `$(AppIdentifierPrefix)$(PRODUCT_BUNDLE_IDENTIFIER)`
    /// (per-config, so the dev fence survives), this Mac was registered
    /// in her developer account, and automatic signing now embeds a Mac
    /// Development profile — the signed app carries
    *[removed for publication]*
    /// `application-identifier` and `keychain-access-groups`.
    ///
    /// THE PIN IS THEREFORE TIGHTENED to assert the write LANDS: this is
    /// now the regression guard for the identity itself. A -34018 here
    /// means the entitlement, the profile, or the device registration
    /// has been lost — read the failure that way rather than as a
    /// keychain fault. It still asserts the write never prompts
    /// (creation never does; only reading an ACL'd item's data would).
    @Test func anACLGatedAddLandsBecauseTheAppCarriesAKeychainIdentity() {
        let account = "gated-\(UUID().uuidString)"
        defer { deleteProbe(account: account) }
        var error: Unmanaged<CFError>?
        guard let control = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            &error)
        else {
            Issue.record("SecAccessControlCreateWithFlags refused: \(String(describing: error))")
            return
        }
        var attributes = query(account: account)
        attributes[kSecValueData as String] = Data("probe".utf8)
        attributes[kSecAttrAccessControl as String] = control
        let status = SecItemAdd(attributes as CFDictionary, nil)
        #expect(status == errSecSuccess,
                "the ACL'd write must LAND — the app carries a keychain identity since 2026-08-30 (got \(status); -34018 means the entitlement, the profile, or this Mac's device registration was lost)")
    }

    /// THE QUESTION (Q3): synchronizable + biometric ACL together —
    /// `errSecParam`, in the signed environment too. The two-item design
    /// (R13p-6: a gated device item AND a separate ungated escrow item)
    /// is platform fact, not lore. Nothing is created, so nothing can
    /// ride into iCloud Keychain from this probe.
    @Test func synchronizablePlusACLIsRefusedAsParameters() {
        let account = "combined-\(UUID().uuidString)"
        defer { deleteProbe(account: account, synchronizable: true) }
        var error: Unmanaged<CFError>?
        guard let control = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            &error)
        else {
            Issue.record("SecAccessControlCreateWithFlags refused: \(String(describing: error))")
            return
        }
        var attributes = query(account: account)
        attributes[kSecValueData as String] = Data("probe".utf8)
        attributes[kSecAttrAccessControl as String] = control
        attributes[kSecAttrSynchronizable as String] = true
        let status = SecItemAdd(attributes as CFDictionary, nil)
        // Parameter validation runs BEFORE the entitlement check (the
        // spike's own discrimination logic, now re-confirmed codesigned):
        // the plain control succeeds and the ACL control now LANDS (it
        // read -34018 until the keychain identity arrived on 2026-08-30 —
        // corrected here at 13p-fix ladder round 2), while THIS
        // combination reads -50 — a genuine rejection of the parameters,
        // not of the environment.
        #expect(status == errSecParam,
                "Apple refuses the COMBINATION (got \(status)) — the escrow item necessarily carries no biometric gate, exactly as R13p-6 designs")

        // And nothing landed: the refusal happened before creation.
        // 13p-fix R1-6: the DP marker rides this probe too — without it
        // this searched the FILE-BASED keychain for the absence of an item
        // that could only ever land in the data-protection one, and would
        // have passed identically had the combination been accepted.
        var probe = query(account: account)
        probe[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
        probe[kSecUseDataProtectionKeychain as String] = true
        probe[kSecReturnAttributes as String] = true
        #expect(SecItemCopyMatching(probe as CFDictionary, nil) == errSecItemNotFound)
    }

    // MARK: - 13p-fix (2026-08-30): the asymmetry, and the round trip

    /// THE PLATFORM FACT the fix rides, pinned so the REASON survives.
    /// On macOS an ACL'd add is routed to the data-protection keychain;
    /// a read without `kSecUseDataProtectionKeychain` searches the
    /// file-based one and cannot see it. Attributes only, non-interactive
    /// — an ACL'd item's CREATION never prompts and nothing here reads
    /// one's data, so this cannot hang a suite. Throwaway service; never
    /// synchronizable, so no test byte can ride into iCloud Keychain.
    @Test func anACLdAddIsInvisibleToAReadThatDoesNotAskForTheDataProtectionKeychain() {
        let account = "asymmetry-\(UUID().uuidString)"
        defer { deleteProbe(account: account) }
        var error: Unmanaged<CFError>?
        guard let control = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            &error)
        else {
            Issue.record("SecAccessControlCreateWithFlags refused: \(String(describing: error))")
            return
        }
        var attributes = query(account: account)
        attributes[kSecValueData as String] = Data("probe".utf8)
        attributes[kSecAttrAccessControl as String] = control
        #expect(SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess)

        func probe(dataProtection: Bool) -> OSStatus {
            var q = query(account: account)
            q[kSecReturnAttributes as String] = true
            q[kSecMatchLimit as String] = kSecMatchLimitOne
            let ctx = LAContext()
            ctx.interactionNotAllowed = true
            q[kSecUseAuthenticationContext as String] = ctx
            if dataProtection { q[kSecUseDataProtectionKeychain as String] = true }
            return SecItemCopyMatching(q as CFDictionary, nil)
        }
        #expect(probe(dataProtection: false) == errSecItemNotFound,
                "the file-based keychain cannot see an ACL'd item")
        // R2-5: NOT-absent is the discriminating fact. Production's own
        // probe accepts `errSecSuccess || errSecInteractionNotAllowed`, so
        // hard-asserting one of them would red this pin for a
        // non-regression on a point release that returns the other.
        // Measured here today: -25308.
        #expect(probe(dataProtection: true) != errSecItemNotFound,
                "the data-protection keychain HAS it")
    }

    // (VX-329 U1: the gated store key's two round trips — `StoreKeyGuardKeychain`'s write, probe, re-save choreography and
    // delete — drove today's store-key custody, deleted with it. The protection road's custody family round-trips the real
    // keychain in its own opt-in suites.)
}
