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
        case .refreshRecordSection: return "refreshRecordSection"
        case .restoreKeyFileFromMirror: return "restoreKeyFileFromMirror"
        case .restoreKeyFileFromCopy: return "restoreKeyFileFromCopy"
        case .rekeyOlderLibraryFile: return "rekeyOlderLibraryFile"
        case .recordHeldSyncKeysFacts: return "recordHeldSyncKeysFacts"
        case .restoreRecordFactsFromMemory: return "restoreRecordFactsFromMemory"
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

        case .refreshRecordSection:
            try writeFacts(&library, section: library.section)
            return nil

        case .restoreKeyFileFromMirror:
            guard let mirror = library.memory?.keyFileMirror, mirror.fingerprint == library.fingerprint else {
                return .preconditionDoesNotVerify
            }
            // Never an Apple wrap re-added: those leave legitimately.
            // Another key's file in the live place is overwritten in place
            // deliberately — a crashed act's never-used new-key file or a
            // replayed genuine one, whose keys the mirror's history already
            // holds; the copy repair's set-aside is the belt (VX-305
            // ladder round 2, NIT 2).
            let live = try liveFormat3()
            var restored = mirror
            restored.apple = live?.fingerprint == mirror.fingerprint ? live?.apple : nil
            try writeLiveKeyFile(restored, &library)
            try writeMemory(&library)
            return nil

        case .restoreKeyFileFromCopy(let id):
            // The live place holds NO file of the current key: absent (both
            // deleted), or ANOTHER key's (a roll back with no plan to trust
            // and the memory item gone — VX-305 ladder round 1, the MAJOR:
            // §3.3's "Always: the record, what this Mac remembers and the key
            // file agree"). The LIVE KEY FILE is repaired from this Mac's own
            // catalogued frozen pair — never a library copy offered, opened or
            // restored, never the library file, no unlock-screen face: not her
            // dropped newest-copy offer (P-U4-10). A restored file keeps the
            // locks of its day; re-locking under current secrets is P-R1-1's
            // door.
            let present = try leaves.keyFiles.readLiveKeyFile()
            if let live = present, live.fingerprint == library.fingerprint { return .nothingThere }
            guard var copy = try leaves.keyFiles.readKeyFile(catalogID: id),
                  copy.fingerprint == library.fingerprint, copy.libraryID == library.record?.libraryID
            else { return .preconditionDoesNotVerify }
            // Another key's file goes ASIDE first — never deleted (it may be an
            // adversary's artifact worth keeping visible); a crash right after leaves the live place empty
            // and this repair owed again.
            if let present, try !setAsideLiveKeyFile(fingerprint: present.fingerprint) { return .preconditionDoesNotVerify }
            // Never an Apple wrap re-added: those leave legitimately.
            copy.apple = nil
            try writeLiveKeyFile(copy, &library)
            try writeMemory(&library)
            return nil

        case .rekeyOlderLibraryFile(let to):
            return try rekeyOlderLibraryFile(to: to, &library)

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

        case .restoreRecordFactsFromMemory:
            guard guards.libraryFileLosesToMemoryOn, var record = library.record, let memory = library.memory,
                  memory.currentFingerprint == record.currentFingerprint, memory.keyEpoch == record.keyEpoch,
                  let confirmed = memory.lastConfirmed,
                  library.familyTree.entry(record.currentFingerprint).map({ $0.kind == confirmed.mode }) ?? true
            else { return .preconditionDoesNotVerify }
            record.mode = confirmed.mode
            record.account = confirmed.account
            library.record = record
            try writeFacts(&library, section: library.section)
            leaves.diagnostics.report(.olderLibraryFileRekeyed(older8: String(record.currentFingerprint.prefix(8)), current8: String(record.currentFingerprint.prefix(8))))
            log("the library file was older than this Mac remembers — its facts taken from the memory")
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

extension ProtectionExecutor {
    /// Whatever sits in the live place goes ASIDE under today's set-aside
    /// shape, named by its key's fingerprint and this moment's epoch (the
    /// next free epoch if one is taken) — never deleted, never overwriting.
    /// False only when no free name was found. VX-305 ladder round 1.
    func setAsideLiveKeyFile(fingerprint: String?) throws -> Bool {
        let epoch = Int(now().timeIntervalSince1970)
        for offset in 0..<60 {
            let name = ProtectionNames.setAsideKeyFilename(fingerprint: fingerprint, epoch: epoch + offset)
            if try leaves.keyFiles.setAsideLiveKeyFile(as: name) {
                log("the live place held \(Self.fp8(fingerprint))'s file, not the current key's — set aside")
                return true
            }
        }
        return false
    }

    /// The library file is older than what this Mac remembers (§3.6, promise
    /// 10): verified with the keys in hand — the memory (sealed, verified at
    /// unlock) names `to` at a newer epoch, the proof below is `to`'s file, and
    /// its history opens with `to` to exactly the key the file is under — the
    /// file is re-encrypted under `to` and its record takes the memory's facts.
    /// Idempotent: a crash before the swap leaves the older file (the staged
    /// one is discarded at the next open and this runs again); after it, the
    /// file is current and nothing is owed. P-U4-6 (ratified (a)). VX-305 U4.
    ///
    /// The proof (`AssessRules.olderLibraryFileProof`) is the live file of the
    /// memory's key — or, the file having come back ALONE (the live place
    /// holding no key file of this library: absent, or another library's, as a
    /// landing that set this library aside leaves it), the memory's own sealed
    /// mirror of that file: whatever sits in the live place then goes ASIDE
    /// (never deleted, never overwritten) and the mirror comes back, Apple
    /// wraps stripped (never re-added by a restore), before the re-key —
    /// everything verified first. A crash after the set-aside leaves the live
    /// place empty (the same proof again); after the mirror's write, the live
    /// file is the memory's (the first proof). VX-305 ladder round 1, NEW-1.
    func rekeyOlderLibraryFile(to: String, _ library: inout UnlockedLibrary) throws -> RepairSkip? {
        guard let record = library.record, let memory = library.memory, memory.currentFingerprint == to,
              memory.deviceSection.deviceID == library.section.deviceID,
              memory.keyEpoch > record.keyEpoch,
              let proof = AssessRules.olderLibraryFileProof(
                  memoryFingerprint: to, mirror: memory.keyFileMirror, live: library.keyFile,
                  fileFingerprint: library.fingerprint, libraryID: record.libraryID),
              let newKey = ([library.key] + library.keysInHand).first(where: { Self.fp($0) == to }),
              let older = try? proof.historyKey(library.fingerprint, currentKey: newKey),
              Self.fp(older) == library.fingerprint
        else { return .preconditionDoesNotVerify }
        var live = proof
        if library.keyFile?.fingerprint != to {
            // The mirror's road: another library's file (or nothing) in the
            // live place — set aside first, then the memory's file back.
            let present = try leaves.keyFiles.readLiveKeyFile()
            if let present, try !setAsideLiveKeyFile(fingerprint: present.fingerprint) { return .preconditionDoesNotVerify }
            live.apple = nil
            try writeLiveKeyFile(live, &library)
            log("the memory's own key file restored from its mirror — the library file came back alone")
        }
        if try leaves.library.stagedFingerprint() != to {
            try leaves.library.stageReencryption(from: library.key, to: newKey)
        }
        let reach = reach(key: newKey, keyFile: live, extra: [library.key])
        var next = record
        // The current key's kind is the mode (§3.2); the account and the
        // confirmation are what this Mac last confirmed for that mode.
        next.mode = library.familyTree.entry(to)?.kind ?? memory.lastConfirmed?.mode ?? record.mode
        if let confirmed = memory.lastConfirmed, confirmed.mode == next.mode {
            next.account = confirmed.account
        }
        next.currentFingerprint = to
        next.keyEpoch = memory.keyEpoch
        next.familyTree = library.familyTree.union(record.familyTree)
        let others = record.verifiedSections(reach: reach).filter { $0.deviceID != library.section.deviceID }
        next.deviceSections = try (others + [library.section]).map {
            try Sealed.sealing($0, purpose: .deviceSection, libraryID: next.libraryID, key: newKey)
        }
        try leaves.library.writeStagedRecord(next, with: newKey)
        try leaves.library.swapStaged(setAside: false)
        library.key = newKey
        library.keysInHand = []
        guard let written = try leaves.library.readRecord(with: newKey) else { throw ExecutorRefusal.recordMissing }
        library.record = written
        library.familyTree = library.familyTree.union(written.familyTree)
        leaves.diagnostics.report(.olderLibraryFileRekeyed(older8: String(Self.fp(older).prefix(8)), current8: String(to.prefix(8))))
        log("the library file was older than this Mac remembers — re-encrypted under \(to.prefix(8)), the memory's facts kept")
        try writeMemory(&library)
        return nil
    }
}
