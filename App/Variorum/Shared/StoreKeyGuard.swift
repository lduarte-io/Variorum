//
//  StoreKeyGuard.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 13p, Batch 2 — the store key's DEVICE custody, whole (the
//  `DeviceKeyStore` pattern from 14b's EncryptionKeychain, applied to the
//  store key): the Auto item Batch 1 shipped (via `StoreKeyCustody`), the
//  `.biometryCurrentSet`-gated item the Biometric mode moves custody
//  into (R13p-5), the SEPARATE synchronizable escrow item (R13p-6 — no
//  access control, because Apple does not sync access-controlled items:
//  the spike's Q3 platform fact, re-confirmed codesigned this batch),
//  and the presence-confirmation seam the R13p-9 reset door uses.
//
//  THE CUSTODY LAW OF THE MODES (what makes a gate real, R13p-14):
//  · Auto        ⇒ plain item present;  gated item absent.
//  · Biometric   ⇒ gated item present;  plain item DELETED — a gate
//                  whose key still releases silently is theater.
//  · Passphrase  ⇒ NEITHER item exists — the typed passphrase (via the
//                  envelope's wrap) is the only same-device road.
//  The escrow item is NEVER an open road: the app never consults it at
//  open — it exists for RECOVERY on a machine that signed into the same
//  iCloud (13x's adoption door). Since the ninth wave's escrow/posture
//  coupling (memo §4) it is no longer orthogonal to the modes: a
//  DEMANDED mode removes it (the same-machine bypass the old
//  `escrowUnderDemandedMode` caveat described can no longer exist —
//  `ProtectionDials.effectiveEscrowOn` is the one rule).
//
//  PROMPT DISCIPLINE (the overnight rule, and the standing test rule):
//  writing the gated item never prompts (delete-then-add — updating an
//  ACL item would demand interactive auth); probing its existence never
//  prompts (`interactionNotAllowed` context); ONLY `unlockGated` and
//  `confirmPresence` evaluate biometrics, and neither is reachable from
//  any test — tests inject `InMemoryStoreKeyGuardBacking`, which scripts
//  the outcomes.
//

import Foundation
import LocalAuthentication
import Security
import VariorumCore

/// The injectable seam (tests script it; production is the Keychain +
/// LocalAuthentication, scoped per store variant like Batch 1's item).
nonisolated struct StoreKeyGuard: Sendable {
    // The Auto item (Batch 1's — service io.lduarte.Variorum.store-key).
    // 17h (13p-fix ladder R3-5): the deletes answer whether the item is
    // RELEASED (deleted, or never there) — their status was dropped at
    // both leaves, so the custody law's "the old item is DELETED" half
    // was enforced on nobody's word at all.
    var loadAuto: @Sendable () -> StoreKey?
    var saveAuto: @Sendable (StoreKey) -> Bool
    var deleteAuto: @Sendable () -> Bool
    // The biometric-gated item (this batch).
    var gatedItemExists: @Sendable () -> Bool
    var saveGated: @Sendable (StoreKey) -> Bool
    var deleteGated: @Sendable () -> Bool
    /// PROMPTS (Touch ID / Face ID) — production only; never on a test
    /// road. nil = failed / cancelled / unavailable / invalidated by
    /// biometry re-enrollment (the passphrase road recovers, by design).
    var unlockGated: @Sendable () async -> StoreKey?
    var biometryAvailable: @Sendable () -> Bool
    // The escrow item (R13p-6), named by the envelope's storeID.
    var loadEscrow: @Sendable (_ storeID: String) -> StoreKey?
    var saveEscrow: @Sendable (StoreKey, _ storeID: String) -> Bool
    var deleteEscrow: @Sendable (_ storeID: String) -> Void
    /// The reset door's biometric confirmation (R13p-9: "after biometric
    /// confirmation") — PROMPTS; production only. False = not confirmed.
    var confirmPresence: @Sendable (_ reason: String) async -> Bool

    /// pre-13x 1a (§1.13 / §14.3): every item is PER STORE ID. The id is
    /// the key file's, read beside `storeURL` at each act (a small file
    /// read at launch / settings cadence — `StoreIdentity.resolve`); a
    /// store with no key file yet resolves to nil, and the gated leaves
    /// then act on the LEGACY (scope-only) items alone, which is exactly
    /// what a pre-1a store holds. The silent item's road (load / save /
    /// delete) goes through core's `StoreKeyCustody`, which mints the key
    /// file on the save road so the id exists before the item does.
    static func keychain(scope: String, storeURL: URL) -> StoreKeyGuard {
        let custody = StoreKeyCustody.deviceKeychain(scope: scope, storeURL: storeURL)
        @Sendable func storeID() -> String? {
            if case .known(let id) = StoreIdentity.resolve(besideStore: storeURL) { return id }
            return nil
        }
        return StoreKeyGuard(
            loadAuto: { custody.load() },
            saveAuto: { custody.save($0) },
            deleteAuto: { StoreKeyCustody.deviceKeychainRemove(scope: scope, storeURL: storeURL) },
            gatedItemExists: { StoreKeyGuardKeychain.gatedItemExists(scope: scope, storeID: storeID()) },
            saveGated: { StoreKeyGuardKeychain.saveGated($0, scope: scope, storeID: storeID()) },
            deleteGated: { StoreKeyGuardKeychain.deleteGated(scope: scope, storeID: storeID()) },
            unlockGated: { await StoreKeyGuardKeychain.unlockGated(scope: scope, storeID: storeID()) },
            biometryAvailable: {
                // Biometrics ONLY — `.deviceOwnerAuthentication` (the
                // passcode fallback) is deliberately never consulted
                // anywhere in this file (the CF-12 ruling, kept).
                LAContext().canEvaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics, error: nil)
            },
            loadEscrow: { StoreKeyGuardKeychain.loadEscrow(storeID: $0) },
            saveEscrow: { StoreKeyGuardKeychain.saveEscrow($0, storeID: $1) },
            deleteEscrow: { StoreKeyGuardKeychain.deleteEscrow(storeID: $0) },
            confirmPresence: { reason in
                let context = LAContext()
                context.localizedFallbackTitle = ""  // no system credential
                return (try? await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: reason)) == true
            })
    }

    static func inMemory(backing: InMemoryStoreKeyGuardBacking) -> StoreKeyGuard {
        StoreKeyGuard(
            loadAuto: { backing.auto },
            // R2-6: guard FIRST, like saveGated/saveEscrow below — a
            // Keychain that reports a failed write never also changed the
            // item, and a double that does makes the refusal arms untestable.
            saveAuto: {
                guard backing.savesSucceed else { return false }
                backing.auto = $0
                return true
            },
            // 17h R3-5: the deletes consult their own knob (the
            // `savesSucceed` pattern) — a refused release changes nothing,
            // exactly like the real Keychain.
            deleteAuto: {
                guard backing.deletesSucceed else { return false }
                backing.auto = nil
                return true
            },
            gatedItemExists: { !backing.gatedWritesAreInvisible && backing.gated != nil },
            saveGated: {
                guard backing.savesSucceed else { return false }
                backing.gated = $0
                return true
            },
            deleteGated: {
                guard backing.deletesSucceed else { return false }
                backing.gated = nil
                return true
            },
            unlockGated: { backing.biometricSucceeds ? backing.gated : nil },
            biometryAvailable: { backing.biometryAvailable },
            loadEscrow: { backing.escrow[$0] },
            saveEscrow: {
                guard backing.savesSucceed else { return false }
                backing.escrow[$1] = $0
                return true
            },
            deleteEscrow: { backing.escrow[$0] = nil },
            confirmPresence: { _ in backing.biometricSucceeds })
    }
}

/// The tests' custody world — items and biometric outcomes, scripted.
nonisolated final class InMemoryStoreKeyGuardBacking: @unchecked Sendable {
    private let lock = NSLock()
    private var _auto: StoreKey?
    private var _gated: StoreKey?
    private var _escrow: [String: StoreKey] = [:]
    private var _biometryAvailable: Bool
    private var _biometricSucceeds: Bool
    private var _savesSucceed = true
    /// 17h R3-5: the delete twin of `savesSucceed` — script a Keychain
    /// that refuses to release an item, so the refuse-on-failed-release
    /// arms are drivable.
    private var _deletesSucceed = true
    /// 13p-fix R1-1: reproduce the shape that cost the author her key —
    /// a gated WRITE that succeeds while the gated READ cannot find it
    /// (the data-protection/file-based split, and every future identity
    /// regression that behaves like it).
    private var _gatedWritesAreInvisible = false

    init(
        auto: StoreKey? = nil, gated: StoreKey? = nil,
        biometryAvailable: Bool = false, biometricSucceeds: Bool = false
    ) {
        _auto = auto
        _gated = gated
        _biometryAvailable = biometryAvailable
        _biometricSucceeds = biometricSucceeds
    }

    var auto: StoreKey? {
        get { lock.lock(); defer { lock.unlock() }; return _auto }
        set { lock.lock(); defer { lock.unlock() }; _auto = newValue }
    }
    var gated: StoreKey? {
        get { lock.lock(); defer { lock.unlock() }; return _gated }
        set { lock.lock(); defer { lock.unlock() }; _gated = newValue }
    }
    var escrow: [String: StoreKey] {
        get { lock.lock(); defer { lock.unlock() }; return _escrow }
        set { lock.lock(); defer { lock.unlock() }; _escrow = newValue }
    }
    var biometryAvailable: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _biometryAvailable }
        set { lock.lock(); defer { lock.unlock() }; _biometryAvailable = newValue }
    }
    var biometricSucceeds: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _biometricSucceeds }
        set { lock.lock(); defer { lock.unlock() }; _biometricSucceeds = newValue }
    }
    var savesSucceed: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _savesSucceed }
        set { lock.lock(); defer { lock.unlock() }; _savesSucceed = newValue }
    }
    var deletesSucceed: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _deletesSucceed }
        set { lock.lock(); defer { lock.unlock() }; _deletesSucceed = newValue }
    }
    var gatedWritesAreInvisible: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _gatedWritesAreInvisible }
        set { lock.lock(); defer { lock.unlock() }; _gatedWritesAreInvisible = newValue }
    }
}

/// The Keychain half. The gated item shares Batch 1's SERVICE (one
/// service = one custody family; the ACCOUNT carries the policy, the
/// E2EE `gatedAccount` pattern); the escrow item is its OWN service —
/// synchronizable, named by storeID, never by device or scope.
nonisolated enum StoreKeyGuardKeychain {
    static let escrowService = "io.lduarte.Variorum.store-key-escrow"
    /// pre-13x 1a: the gated item's account is PER STORE ID
    /// (`<scope>-<storeID>-biometric`); nil = the 13p-era LEGACY account
    /// (`<scope>-biometric`), which `unlockGated` migrates onto the
    /// per-store one under the evaluated context (a gated item can only be
    /// read with a prompt, so its TN3137 road runs at unlock).
    static func gatedAccount(scope: String, storeID: String?) -> String {
        storeID.map { "\(scope)-\($0)-biometric" } ?? legacyGatedAccount(scope: scope)
    }
    static func legacyGatedAccount(scope: String) -> String { "\(scope)-biometric" }

    // MARK: The gated item (R13p-5's Biometric mode)

    /// Non-prompting existence probe (attributes read without user auth;
    /// the non-interactive context is the belt — the E2EE pattern). The
    /// per-store item OR the legacy one — a pre-1a store's gate is real
    /// until its unlock migrates it.
    static func gatedItemExists(scope: String, storeID: String?) -> Bool {
        if itemExists(gatedQuery(scope: scope, storeID: storeID)) { return true }
        return storeID != nil && itemExists(gatedQuery(scope: scope, storeID: nil))
    }

    private static func itemExists(_ base: [String: Any]) -> Bool {
        var query = base
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        let probe = LAContext()
        probe.interactionNotAllowed = true
        query[kSecUseAuthenticationContext as String] = probe
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return status == errSecSuccess || status == errSecInteractionNotAllowed
    }

    /// Delete-then-add (updating an ACL item would demand interactive
    /// auth; WRITING must never prompt — the prompt belongs to the
    /// unlock alone). `.biometryCurrentSet` ALONE: never `.devicePasscode`,
    /// never an `.or` escape — re-enrolled biometry invalidates the item
    /// BY DESIGN under this threat model; the passphrase road recovers.
    /// 17h R2-7: the forced order's window is narrowed to probe width via
    /// `GatedSaveChoreography` (see its doc for what survives). In this
    /// family every production road reaches here with the gated item
    /// ABSENT (`setMode` refuses same-mode re-entry, and the custody law
    /// keeps the item absent outside Biometric) — the probe still runs,
    /// because ONE choreography for both gated families is the point, and
    /// an R3-5-class lingering item is exactly when it earns its keep.
    @discardableResult
    static func saveGated(_ key: StoreKey, scope: String, storeID: String?) -> Bool {
        guard let control = accessControl() else { return false }
        return GatedSaveChoreography.run(
            sweepProbe: { SecItemDelete(probeQuery(scope: scope, storeID: storeID) as CFDictionary) },
            addProbe: {
                var attributes = probeQuery(scope: scope, storeID: storeID)
                attributes[kSecValueData as String] = Data("probe".utf8)
                attributes[kSecAttrAccessControl as String] = control
                return SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess
            },
            releaseExisting: { deleteGated(scope: scope, storeID: storeID) },
            addIncoming: {
                var attributes = gatedQuery(scope: scope, storeID: storeID)
                attributes[kSecValueData as String] = key.data
                attributes[kSecAttrAccessControl as String] = control
                return SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess
            })
    }

    /// Her ruling, in flags: `.biometryCurrentSet` ALONE — never
    /// `.devicePasscode`, never an `.or` escape.
    private static func accessControl() -> SecAccessControl? {
        var error: Unmanaged<CFError>?
        return SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            &error)
    }

    /// 17h R2-7: the probe item's account — the gated account's sibling
    /// (the account-carries-the-policy pattern), same service, same DP
    /// partition, dummy bytes, swept within the same call.
    static func probeAccount(scope: String, storeID: String?) -> String {
        "\(gatedAccount(scope: scope, storeID: storeID))-probe"
    }

    private static func probeQuery(scope: String, storeID: String?) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: StoreKeyCustody.deviceKeychainService,
            kSecAttrAccount as String: probeAccount(scope: scope, storeID: storeID),
        ].merging(KeychainPartition.dataProtection) { a, _ in a }
    }

    /// 17h (R3-5): released = deleted, or never there. Anything else is a
    /// refusal the caller must not paper over — the `.biometric` arm's
    /// silently-still-releasing key and the `.auto` arm's lingering gate
    /// were both this dropped status. pre-13x 1a: the per-store item AND
    /// the legacy one — a lingering legacy gated item would be a second
    /// road nobody knows about.
    @discardableResult
    static func deleteGated(scope: String, storeID: String?) -> Bool {
        let own = SecItemDelete(gatedQuery(scope: scope, storeID: storeID) as CFDictionary)
        var released = own == errSecSuccess || own == errSecItemNotFound
        if storeID != nil {
            let legacy = SecItemDelete(gatedQuery(scope: scope, storeID: nil) as CFDictionary)
            released = released && (legacy == errSecSuccess || legacy == errSecItemNotFound)
        }
        return released
    }

    /// The at-open unlock: evaluate biometrics (ONLY), then read under
    /// the evaluated context so the system never double-prompts. pre-13x
    /// 1a: ONE evaluation serves the per-store item, and — a pre-1a store
    /// — the legacy item, whose key is then re-added under the store id
    /// (verified by presence; the legacy released) so the next unlock
    /// reads the per-store item straight: the TN3137 road for an item
    /// that can only be read with a prompt.
    static func unlockGated(scope: String, storeID: String?) async -> StoreKey? {
        let context = LAContext()
        context.localizedFallbackTitle = ""  // our fallback is the passphrase
        guard (try? await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Unlock your Variorum library"))
            == true
        else { return nil }
        if let key = readGated(scope: scope, storeID: storeID, context: context) { return key }
        guard let storeID, let legacy = readGated(scope: scope, storeID: nil, context: context)
        else { return nil }
        migrateLegacyGated(legacy, scope: scope, storeID: storeID)
        return legacy
    }

    /// Read the gated item's DATA under an evaluated context.
    private static func readGated(scope: String, storeID: String?, context: LAContext) -> StoreKey? {
        var query = gatedQuery(scope: scope, storeID: storeID)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecUseAuthenticationContext as String] = context
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return StoreKey(data: data)
    }

    /// The legacy gated item's TN3137 road, run once the key is in hand:
    /// add under the store id → VERIFY (presence — reading an ACL'd item's
    /// data would prompt again) → release the legacy. A refused add or an
    /// unverified write leaves the legacy item as the working custody; the
    /// next unlock retries.
    private static func migrateLegacyGated(_ key: StoreKey, scope: String, storeID: String) {
        guard let control = accessControl() else { return }
        var attributes = gatedQuery(scope: scope, storeID: storeID)
        attributes[kSecValueData as String] = key.data
        attributes[kSecAttrAccessControl as String] = control
        guard SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess else { return }
        guard itemExists(gatedQuery(scope: scope, storeID: storeID)) else {
            SecItemDelete(gatedQuery(scope: scope, storeID: storeID) as CFDictionary)
            return
        }
        SecItemDelete(gatedQuery(scope: scope, storeID: nil) as CFDictionary)
    }

    /// Internal (see `EncryptionKeychain.gatedBaseQuery`): the partition
    /// marker is asserted structurally, for every family, by
    /// `KeychainPartitionTests`.
    static func gatedQuery(scope: String, storeID: String?) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: StoreKeyCustody.deviceKeychainService,
            kSecAttrAccount as String: gatedAccount(scope: scope, storeID: storeID),
        ].merging(KeychainPartition.dataProtection) { a, _ in a }
    }

    // MARK: The escrow item (R13p-6)

    /// Synchronizable, NO access control (the two-item design is platform
    /// fact — Q3's errSecParam), non-ThisDeviceOnly accessibility (a
    /// ThisDeviceOnly class cannot sync by definition). `AfterFirstUnlock`
    /// so a restore onto a new device can read it without ceremony.
    static func loadEscrow(storeID: String) -> StoreKey? {
        var query = escrowQuery(storeID: storeID)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return StoreKey(data: data)
    }

    @discardableResult
    static func saveEscrow(_ key: StoreKey, storeID: String) -> Bool {
        var attributes = escrowQuery(storeID: storeID)
        attributes[kSecValueData as String] = key.data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let update: [String: Any] = [kSecValueData as String: key.data]
            return SecItemUpdate(
                escrowQuery(storeID: storeID) as CFDictionary, update as CFDictionary)
                == errSecSuccess
        }
        return status == errSecSuccess
    }

    static func deleteEscrow(storeID: String) {
        SecItemDelete(escrowQuery(storeID: storeID) as CFDictionary)
    }

    /// `kSecAttrSynchronizable` rides EVERY escrow query — a search
    /// without it does not match synchronizable items.
    /// NOTE (13p-fix ladder R1-4 — the escrow leg of the original
    /// diagnosis was WRONG and is corrected here): this family was never
    /// asymmetric. `kSecAttrSynchronizable` ALREADY targets the
    /// data-protection keychain on its own, so load/save/delete have
    /// always agreed. The partition marker rides anyway, per Apple's
    /// set-it-everywhere guidance and so all three families are visibly
    /// one rule — a belt, not a fix.
    static func escrowQuery(storeID: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: escrowService,
            kSecAttrAccount as String: storeID,
            kSecAttrSynchronizable as String: true,
        ].merging(KeychainPartition.dataProtection) { a, _ in a }
    }
}
