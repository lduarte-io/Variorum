import Foundation

// VX-305 U3 — THE REPAIRS (design §3.3): each moves toward the record, each
// idempotent, each run by the executor — and none of them makes a Touch ID
// item or changes a key's kind. `assess` names them with their
// preconditions; the executor VERIFIES each precondition itself, with the key
// in hand, before anything is deleted (U2's hand-forward: "every `Repair`'s
// precondition is the executor's to VERIFY before a delete"). No repair runs
// while an act is in flight: the act's own plan owns the state until it ends
// (mid-act the live key file is the new key's while the library is still
// under the old — a repair reading that as "the file lost a road" would undo
// the act).

/// Why a repair did not run.
public enum RepairSkip: Equatable, Sendable {
    /// An act is in flight on this device — its plan owns the state.
    case actInFlight
    /// Its precondition did not verify (a delete would remove a road).
    case preconditionDoesNotVerify
    /// The guards forbid it: a Touch ID item made by a repair, or a delete on
    /// a Standard record's word alone.
    case forbidden
    /// Decision 35: a synced library writes nothing Apple-reachable without a
    /// fresh vault read for its account.
    case needsFreshVault
    /// The library's recorded mode isn't the one the repair belongs to, or
    /// isn't confirmed.
    case wrongMode
    /// Nothing to repair (already as the record says).
    case nothingThere
}

public struct RepairReport: Equatable, Sendable {
    public struct Skipped: Equatable, Sendable {
        public var repair: Repair
        public var reason: RepairSkip
    }

    public var done: [Repair] = []
    public var skipped: [Skipped] = []
}

extension ProtectionExecutor {
    /// **Run `assess`'s repairs** against the library in hand.
    @discardableResult
    public func runRepairs(_ repairs: [Repair], on library: inout UnlockedLibrary) throws -> RepairReport {
        var report = RepairReport()
        for repair in repairs {
            if library.section.actInFlight != nil {
                report.skipped.append(.init(repair: repair, reason: .actInFlight))
                continue
            }
            if let skip = try run(repair, &library) {
                report.skipped.append(.init(repair: repair, reason: skip))
                leaves.diagnostics.report(.repairSkipped(Self.name(of: repair)))
                log("repair \(Self.name(of: repair)): skipped (\(skip))")
            } else {
                report.done.append(repair)
                log("repair \(Self.name(of: repair)): done")
            }
        }
        return report
    }

    static func name(of repair: Repair) -> String {
        switch repair {
        case .deleteSilentItem: return "deleteSilentItem"
        case .deleteRetiredAppleKey: return "deleteRetiredAppleKey"
        case .landAppleWrap: return "landAppleWrap"
        case .refreshMemory: return "refreshMemory"
        case .restoreKeyFileFromMirror: return "restoreKeyFileFromMirror"
        case .recordHeldSyncKeysFacts: return "recordHeldSyncKeysFacts"
        case .retireOwnAppleKeys: return "retireOwnAppleKeys"
        case .recordAlwaysAskQuietly: return "recordAlwaysAskQuietly"
        case .makeTouchIDItem: return "makeTouchIDItem"
        case .deleteTouchIDItem: return "deleteTouchIDItem"
        }
    }

    /// The precondition, checked with the key in hand.
    func verifies(_ precondition: RepairPrecondition, _ library: UnlockedLibrary) -> Bool {
        guard guards.repairPreconditionsVerifiedOn else { return true }
        guard let live = library.keyFile, live.fingerprint == library.fingerprint else { return false }
        switch precondition {
        case .historyHolds(let fingerprint):
            // The live history opens with the current key and yields a key
            // with exactly this fingerprint.
            return (try? live.historyKey(fingerprint, currentKey: library.key)) != nil
        case .currentKeyHasTypedRoad:
            // A passphrase or words lock of the current key that the SEALED
            // mirror holds byte for byte — a planted file can't match it.
            guard let mirror = library.memory?.keyFileMirror, mirror.fingerprint == live.fingerprint else { return false }
            return (live.passphrase != nil && live.passphrase == mirror.passphrase)
                || (live.words != nil && live.words == mirror.words)
        }
    }

    /// The Castle repairs act only on a Castle record (a Standard record's
    /// word drives nothing destructive).
    func castleConfirmed(_ library: UnlockedLibrary) -> Bool { library.record?.mode == .castle }

    /// Run one repair; nil = done.
    func run(_ repair: Repair, _ library: inout UnlockedLibrary) throws -> RepairSkip? {
        switch repair {
        case .deleteSilentItem(let fingerprint, let precondition):
            guard castleConfirmed(library) else { return .wrongMode }
            guard verifies(precondition, library) else { return .preconditionDoesNotVerify }
            guard try leaves.custody.custodyItems().contains(CustodyItemFact(fingerprint: fingerprint, itemClass: .silent))
            else { return .nothingThere }
            try leaves.custody.deleteCustody(fingerprint: fingerprint, itemClass: .silent)
            return nil

        case .deleteRetiredAppleKey(let id):
            guard castleConfirmed(library) else { return .wrongMode }
            // Delete on sight BY RECORDED ID ONLY.
            if guards.deleteOnSightByIDOnlyOn, !library.section.retiredAppleKeyIDs.contains(id) {
                return .preconditionDoesNotVerify
            }
            guard try leaves.apple.readableAppleKeyIDs().contains(id) else { return .nothingThere }
            try leaves.apple.deleteAppleKey(id: id)
            return nil

        case .landAppleWrap(let id):
            guard let record = library.record, record.mode == .standard else { return .wrongMode }
            // Decision 35: nothing Apple-reachable without a fresh vault read.
            if guards.freshVaultBeforeAppleWriteOn, let account = record.account {
                guard let vault = freshVault(for: account), vault.mode.settled == .standard else { return .needsFreshVault }
            }
            guard library.section.appleKeys.contains(where: { $0.id == id && $0.isOwnLibraryKey && $0.retiredAt == nil }),
                  let apple = try leaves.apple.readAppleKey(id: id),
                  let live = library.keyFile, live.fingerprint == library.fingerprint
            else { return .preconditionDoesNotVerify }
            if live.apple?.keyID == id { return .nothingThere }
            try writeLiveKeyFile(try live.settingApple(apple, for: library.key), &library)
            try writeMemory(&library)
            return nil

        case .refreshMemory:
            try writeMemory(&library)
            return nil

        case .restoreKeyFileFromMirror:
            guard let mirror = library.memory?.keyFileMirror, mirror.fingerprint == library.fingerprint else {
                return .preconditionDoesNotVerify
            }
            // ONLY into an empty live place (rule 1); whatever sits there is
            // never overwritten (rule 21). Never an Apple wrap re-added.
            guard try liveFormat3() == nil else { return .nothingThere }
            var restored = mirror
            restored.apple = nil
            try writeLiveKeyFile(restored, &library)
            try writeMemory(&library)
            return nil

        case .retireOwnAppleKeys(let ids):
            guard castleConfirmed(library) else { return .wrongMode }
            let listed = Set(library.section.ownLibraryAppleKeyIDsToRetire)
            let retiring = ids.filter { listed.contains($0) }
            guard !retiring.isEmpty else { return .nothingThere }
            var section = library.section.bumped()
            for id in retiring { section = section.retiringAppleKey(id: id, purpose: .library, origin: .minted, at: leaves.clock.now()) }
            try writeFacts(&library, section: section)
            let readable = try leaves.apple.readableAppleKeyIDs()
            for id in retiring where readable.contains(id) { try leaves.apple.deleteAppleKey(id: id) }
            return nil

        case .recordHeldSyncKeysFacts:
            guard let account = library.record?.account, library.memory != nil,
                  library.memory?.vaultFacts?.corpusKeyID == nil else { return .nothingThere }
            guard let held = try leaves.syncKeys.readSyncKeys(accountID: account, itemClass: .silent)
                    ?? leaves.syncKeys.sessionSyncKeys(accountID: account) else { return .nothingThere }
            // Only what the LIBRARY follows: its key file's master lock opens
            // with the held master (keys fetched fresh from the vault for the
            // session can be newer than the library — then the follow is owed,
            // read by assess from the master's words copy).
            if let live = library.keyFile, live.master != nil,
               (try? live.open(master: held.masterSymmetricKey)).map({ Self.fp($0) == library.fingerprint }) != true {
                // The library is behind the keys this device holds: a follow
                // is owed — recorded so assess reads it.
                try writeMemory(&library) { $0.vaultFacts = VaultFacts(corpusKeyID: VaultFacts.unfollowedCorpusKeyID) }
                return nil
            }
            let vault = freshVaults[account]
            let facts = vault.map { $0.corpusKeyID == held.corpusKeyID } == true
                ? VaultFacts(kdf: vault?.format.kdf, corpusKeyID: held.corpusKeyID, recoveryWrapDigest: vault?.format.recoveryWrapDigest)
                : VaultFacts(corpusKeyID: held.corpusKeyID)
            try writeMemory(&library) { $0.vaultFacts = facts }
            return nil

        case .recordAlwaysAskQuietly:
            guard library.section.settings.gateStyle == .touchID else { return .nothingThere }
            var settings = library.section.settings
            settings.gateStyle = .alwaysAsk
            try writeFacts(&library, section: library.section.withSettings(settings))
            return nil

        case .makeTouchIDItem:
            // No repair ever makes a Touch ID item — only a press (§3.10).
            guard !guards.repairNeverMakesTouchIDItemOn else { return .forbidden }
            try leaves.custody.writeCustody(library.key, itemClass: .touchid)
            return nil

        case .deleteTouchIDItem(let fingerprint):
            // Nothing destructive on a Standard record's word alone (rule 3).
            if guards.standardRecordNoDestructiveRepairOn, library.record?.mode != .castle { return .forbidden }
            try leaves.custody.deleteCustody(fingerprint: fingerprint, itemClass: .touchid)
            return nil
        }
    }
}
