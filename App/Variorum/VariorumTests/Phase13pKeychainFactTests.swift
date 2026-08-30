//
//  Phase13pKeychainFactTests.swift
//  VariorumTests
//
//  Phase 13p, Batch 2 (commit 6) — THE Q3 CODESIGNED RE-CONFIRMATION
//  (the spike memo's named PENDING): the spike's probe ran from an
//  UNSIGNED CLI, where the three controls all died at the entitlement
//  check (-34018) and only the question probe's DIFFERENT status (-50,
//  errSecParam) discriminated. This suite runs inside the SIGNED app
//  test host: the PLAIN control genuinely succeeds, the ACL control
//  surfaces the ENTITLEMENT FINDING its own doc comment records (no
//  keychain identity in today's signing ⇒ -34018), and the question
//  probe still reads -50 — pinning the two-item design (R13p-6) as
//  platform fact: `kSecAttrSynchronizable` + `kSecAttrAccessControl`
//  is refused as a COMBINATION, so the escrow item necessarily has no
//  biometric gate.
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

@testable import Variorum

@Suite("13p — Q3 codesigned: the two-item design is platform fact")
struct Phase13pKeychainFactTests {
    private static let probeService = "io.lduarte.Variorum.13p-q3-probe"

    private func query(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.probeService,
            kSecAttrAccount as String: account,
        ]
    }

    private func deleteProbe(account: String, synchronizable: Bool = false) {
        var q = query(account: account)
        if synchronizable { q[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny }
        SecItemDelete(q as CFDictionary)
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

    /// Control C — AND A FINDING (2026-08-30, this batch, recorded in the
    /// run record): an ACL'd item can only live in the DATA-PROTECTION
    /// keychain, and on macOS that requires a keychain identity the app
    /// does not carry today (`Variorum.entitlements` has no
    /// keychain-access-groups / application-identifier — no provisioning
    /// profile), so the write comes back `errSecMissingEntitlement`
    /// (-34018) rather than landing. CONSEQUENCE, stated so nobody
    /// discovers it at an acceptance walk: until the app's signing gains
    /// a keychain identity, the Biometric mode's gated item (and likely
    /// the synchronizable escrow item) cannot LAND on the Mac — every
    /// door refuses HONESTLY at its own guard ("the Keychain refused…"),
    /// no data is at risk, and the passphrase mode is unaffected. The
    /// signing change is the author's call (CLAUDE.md: signing is hers).
    /// This pin accepts EITHER outcome and asserts the write never
    /// prompts; the question probe below discriminates regardless.
    @Test func anACLGatedAddEitherLandsOrRefusesByEntitlement() {
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
        #expect(status == errSecSuccess || status == errSecMissingEntitlement,
                "an ACL write lands where the app has a keychain identity and refuses -34018 where it doesn't (got \(status)) — never a prompt, never a hang")
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
        // the plain control succeeds and the ACL control reads -34018 in
        // this environment, while THIS combination reads -50 — a genuine
        // rejection of the parameters, not of the environment.
        #expect(status == errSecParam,
                "Apple refuses the COMBINATION (got \(status)) — the escrow item necessarily carries no biometric gate, exactly as R13p-6 designs")

        // And nothing landed: the refusal happened before creation.
        var probe = query(account: account)
        probe[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
        probe[kSecReturnAttributes as String] = true
        #expect(SecItemCopyMatching(probe as CFDictionary, nil) == errSecItemNotFound)
    }
}
