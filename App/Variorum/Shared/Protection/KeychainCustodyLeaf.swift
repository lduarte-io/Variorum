//
//  KeychainCustodyLeaf.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE PRODUCTION `CustodyLeaf` (`Executor/Leaves.swift` is the contract): one generic-password
//  item per library key, of the key's kind for life — service `ProtectionNames.custodyService`, account
//  `<scope>-<fingerprint16>-<class>`:
//    - SILENT (a Standard key): `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`, no ACL — today's silent
//      item's shape (`E2EEKeychainStorage.boundQuery`); written, then VERIFIED BY A READ-BACK;
//    - TOUCH ID (a Castle key): a `SecAccessControl` with `.biometryCurrentSet` alone (the Apple facts
//      §4/§6/§10), made only at a person's press (an act's step — the executor's rule), never updated in
//      place (that would prompt): an item already there for the key is that key's (the name is the
//      fingerprint) and is kept; a new one is VERIFIED BY AN EXISTENCE PROBE (reading its data would prompt).
//  THE PRESS: a Touch ID read runs through an `LAContext` the system prompts on — never when `LAEnvironment`
//  says Touch ID is unusable for now (nothing is attempted; `lastPress` says why). `lastPress` records what
//  the most recent press did (cancelled · failed on an item that exists · unusable for now) — the lobby's
//  `TouchIDPress` fact (U1b).
//  THE LISTING reads attributes only and SKIPS an item that would need authentication — no listing ever
//  presses an item (`ProtectionKeychain`); the Touch ID items are then found BY NAME — a non-prompting
//  existence probe of `<scope>-<fp>-touchid` for every fingerprint this device knows of
//  (`touchIDCandidates`: the composition root's — every catalogued key file's keys, the live one's among
//  them, what the memory items name, the plan's two keys, the staged key — plus every silent item's), so a
//  Touch ID item for a key no file or memory here names is not listed (it opens nothing this Mac can reach,
//  and it is no quiet road — rule 9) — P-VX306-U1a-5. A Touch ID item's stamp is not readable without a
//  press, so it lists unstamped (the stamp sweep is the SILENT items' — rule 11). VX-390's stamp is
//  `kSecAttrLabel`.
//  Every mutation asks the test tripwire first (`ProtectionKeychain`).
//

import Foundation
import LocalAuthentication
import Security
import VariorumCore

nonisolated final class KeychainCustodyLeaf: CustodyLeaf, @unchecked Sendable {
    static let service = ProtectionNames.custodyService
    /// The words the system's Touch ID sheet shows (today's unlock words, `StoreKeyGuard.unlockGated`).
    static let pressReason = "Unlock your Variorum library"

    let scope: String
    private let biometry: any BiometryLeaf
    /// The fingerprints whose Touch ID item the listing probes for by name.
    private let touchIDCandidates: @Sendable () -> Set<String>
    private let lock = NSLock()
    private var _lastPress: TouchIDPress?

    init(
        scope: String, biometry: any BiometryLeaf = LAEnvironmentBiometryLeaf(),
        touchIDCandidates: @escaping @Sendable () -> Set<String> = { [] }
    ) {
        self.scope = scope
        self.biometry = biometry
        self.touchIDCandidates = touchIDCandidates
    }

    /// What the most recent Touch ID press did — nil after one that read its item, or before any.
    var lastPress: TouchIDPress? {
        lock.lock()
        defer { lock.unlock() }
        return _lastPress
    }

    private func setLastPress(_ press: TouchIDPress?) {
        lock.lock()
        _lastPress = press
        lock.unlock()
    }

    #if DEBUG
    /// WALK MACHINERY (VX-307 U2a — `ProtectionWalkSwitch`'s `VARIORUM_WALK_TOUCHID=fail`, P-VX306-U1b-9's fences): the
    /// next Touch ID press on an item that EXISTS answers as one a biometry change invalidated — nothing read, the press
    /// recorded `.failedOnExistingItem` — ONCE, so lifecycle stage 11's re-arm is walked on a planted failure. Never set
    /// outside a walk launch.
    private var walkFailsNextPress = false

    func walkFailNextTouchIDPress() {
        lock.lock()
        walkFailsNextPress = true
        lock.unlock()
    }

    /// This leaf instance's name in the walk's log lines (ladder round 1, MINOR-3: the armed and the pressed instance
    /// named, so a walk can tell them apart — never key material).
    var walkInstanceName: String { String(UInt(bitPattern: ObjectIdentifier(self).hashValue), radix: 16) }

    private func takeWalkFailure() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let fails = walkFailsNextPress
        walkFailsNextPress = false
        return fails
    }
    #endif

    func account(_ fingerprint: String, _ itemClass: ProtectionNames.CustodyClass) -> String {
        ProtectionNames.custodyAccount(scope: scope, fingerprint: fingerprint, class: itemClass)
    }

    func custodyItems() throws -> [CustodyItemFact] {
        var items = Set(try ProtectionKeychain.list(service: Self.service, residence: .deviceOnly).compactMap { attributes in
            guard let account = ProtectionKeychain.account(of: attributes),
                  let parsed = ProtectionNames.parseCustodyAccount(account, scope: scope) else { return nil }
            return CustodyItemFact(
                fingerprint: parsed.fingerprint, itemClass: parsed.class, libraryID: ProtectionKeychain.label(of: attributes))
        } as [CustodyItemFact])
        let known = touchIDCandidates().union(items.map(\.fingerprint))
        for fingerprint in known where ProtectionNames.isFingerprint16(fingerprint) {
            let fact = CustodyItemFact(fingerprint: fingerprint, itemClass: .touchid)
            guard !items.contains(fact) else { continue }
            if try ProtectionKeychain.exists(service: Self.service, account: account(fingerprint, .touchid), residence: .deviceOnly) {
                items.insert(fact)
            }
        }
        return items.sorted { ($0.fingerprint, $0.itemClass.rawValue) < ($1.fingerprint, $1.itemClass.rawValue) }
    }

    func readCustody(fingerprint: String, itemClass: ProtectionNames.CustodyClass) throws -> StoreKey? {
        let account = account(fingerprint, itemClass)
        switch itemClass {
        case .silent:
            return try ProtectionKeychain.readData(service: Self.service, account: account, residence: .deviceOnly)
                .flatMap { StoreKey(data: $0) }
        case .touchid:
            guard try ProtectionKeychain.exists(service: Self.service, account: account, residence: .deviceOnly) else {
                return nil
            }
            if let transient = biometry.biometry().transient {
                setLastPress(.transient(transient))
                return nil
            }
            #if DEBUG
            if takeWalkFailure() {
                setLastPress(.failedOnExistingItem)
                ProtectionOpenRoad.log("WALK SWITCH: the planted failure answered this press — no prompt (leaf \(walkInstanceName))")
                return nil
            }
            // MINOR-3's one look: every real press names its leaf, beside the arm's line.
            ProtectionOpenRoad.log("road: a Touch ID press — the system prompt (leaf \(walkInstanceName))")
            #endif
            let context = LAContext()
            context.localizedReason = Self.pressReason
            context.localizedFallbackTitle = ""  // the fallback is the passphrase road, never a system credential
            do {
                let data = try ProtectionKeychain.readData(
                    service: Self.service, account: account, residence: .deviceOnly, context: context)
                // An item the probe found that the press reads as absent was invalidated (the facts §4.5:
                // older systems answer "not found" for an enrollment change) — failed on an item that exists.
                setLastPress(data == nil ? .failedOnExistingItem : nil)
                return data.flatMap { StoreKey(data: $0) }
            } catch ProtectionKeychain.KeychainError.status(let status, _) where status == errSecUserCanceled {
                setLastPress(.cancelled)
                return nil
            } catch ProtectionKeychain.KeychainError.status(let status, _)
                where status == errSecAuthFailed || status == errSecInteractionNotAllowed {
                // Unusable for now (the reading after the press says so), else failed on an item that exists
                // — a biometry change, or the hash moved with nothing changed: the item is the final word.
                setLastPress(biometry.biometry().transient.map { .transient($0) } ?? .failedOnExistingItem)
                return nil
            }
        }
    }

    func writeCustody(_ key: StoreKey, itemClass: ProtectionNames.CustodyClass, libraryID: String) throws {
        try ProtectionKeychain.refuseUnderTest(scope, "custody.write")
        let fingerprint = StoreKeyEnvelope.fingerprint(of: key)
        let account = account(fingerprint, itemClass)
        switch itemClass {
        case .silent:
            try ProtectionKeychain.upsert(
                service: Self.service, account: account, residence: .deviceOnly, data: key.data, label: libraryID,
                accessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
            guard try readCustody(fingerprint: fingerprint, itemClass: .silent) == key else {
                throw ProtectionKeychain.KeychainError.writeDidNotReadBack("custody.write")
            }
        case .touchid:
            if try ProtectionKeychain.exists(service: Self.service, account: account, residence: .deviceOnly) { return }
            guard let control = ProtectionKeychain.touchIDControl() else {
                throw ProtectionKeychain.KeychainError.status(errSecParam, "custody.write access control")
            }
            let status = ProtectionKeychain.addGated(
                service: Self.service, account: account, data: key.data, label: libraryID, control: control)
            guard status == errSecSuccess || status == errSecDuplicateItem else {
                throw ProtectionKeychain.KeychainError.status(status, "custody.write touchid")
            }
            guard try ProtectionKeychain.exists(service: Self.service, account: account, residence: .deviceOnly) else {
                throw ProtectionKeychain.KeychainError.writeDidNotReadBack("custody.write touchid")
            }
        }
    }

    func deleteCustody(fingerprint: String, itemClass: ProtectionNames.CustodyClass) throws {
        try ProtectionKeychain.refuseUnderTest(scope, "custody.delete")
        try ProtectionKeychain.delete(service: Self.service, account: account(fingerprint, itemClass), residence: .deviceOnly)
    }
}
