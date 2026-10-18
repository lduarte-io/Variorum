import CryptoKit
import Foundation

// VX-305 U3 — USE STANDARD: LEAVING CASTLE IS A KEY CHANGE (rule 12,
// `notes/CastleRules.md`: "leaving hands everything out"). The door: the
// passphrase and the twelve words, typed — the words never made new here —
// and rule 5's sentence.
//   1. Synced, the account's part first: the vault's MODE flag flipped to
//      Standard in one write — no key changes on the server (rule 12; the
//      account keeps every sync key, rule 15). The sync keys go to a silent
//      item (the account's mode is Standard). Other devices follow out
//      quietly.
//   2. The new library key, re-keyed exactly as Replace All Keys does: its
//      silent item; this Mac's own FRESH Apple key; the new key file (the
//      Apple wrap, P, W, the new master when synced) whose history carries
//      the Castle key and every key before it (rule 4); the record into the
//      staged file; the swap.
//   3. What this Mac remembers; the Castle key's Touch ID item goes with its
//      key; a fresh backup.
// (The anchor written first, the leave's empty history, the id-with-no-wrap
// mark and the stuck leave's wait left with VX-378 U1 — rules 4, 12, 13; the
// rotation and the account's fresh Apple key with VX-378 U2 — rules 14, 15.)

struct LeaveCastleProgram: ActProgram {
    let act = ProtectionAct.leaveCastle
    static let afterCommit = ["memory", "retireOldCustody", "backup"]

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        (parameters.synced == true ? ["vaultMode"] : []) + LibraryRekey.steps(guards, mintsOwnAppleKey: true)
            + Self.afterCommit
    }

    func newKeySteps(_ parameters: ActParameters) -> Set<String> { LibraryRekey.newKeySteps }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { Self.afterCommit }

    func run(_ step: String, _ ctx: ActContext) async throws {
        switch step {
        case "vaultMode": try await ctx.leaveCastleWrite()
        case "mintOwnAppleKey": _ = try ctx.mintOwnAppleKey()
        case "custodyItem": try ctx.newCustodyItem(kind: .standard)
        case "keyFile":
            try ctx.newKeyFile(
                rekeyTo: .standard,
                locks: try ctx.newLocks(
                    passphrase: true, words: true, master: ctx.parameters.synced == true, apple: try ctx.ownAppleKey()))
        case "stage": try ctx.stage()
        case "recordIntoStaged": try ctx.recordIntoStaged(kind: .standard)
        case "swap": try ctx.swap { try ctx.stage(); try ctx.recordIntoStaged(kind: .standard) }
        case "memory":
            try ctx.rememberNewKey()
            ctx.outcome.done = [.ruleFive]
        case "retireOldCustody": try ctx.retireOldCustody(sweepForCastle: false)
        case "backup": try ctx.freshBackup()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

extension LibraryRekey {
    /// The re-key's steps with this Mac's own Apple key minted just before
    /// the new key file (Standard's crossings — a leave, a landing).
    static func steps(_ guards: ProtectionGuards, mintsOwnAppleKey: Bool) -> [String] {
        var steps = steps(guards)
        if mintsOwnAppleKey, let index = steps.firstIndex(of: "keyFile") { steps.insert("mintOwnAppleKey", at: index) }
        return steps
    }
}

extension ActContext {
    /// Decision 35: a synced library writes nothing Apple-reachable without a
    /// fresh vault read for its account this session.
    func requireAppleWriteAllowed() throws {
        guard executor.guards.freshVaultBeforeAppleWriteOn, let account = library.record?.account ?? accountID else { return }
        guard executor.readThisSession(account) else { throw ExecutorRefusal.needsFreshVault }
    }

    /// **Mint a fresh own Apple key for the library** — always under a fresh
    /// id (one minter, §3.5): its id stamped in the plan first (a crash after
    /// the add still knows it), the item added, the id recorded in this Mac's
    /// section. Idempotent: a key this act already minted is read back.
    func mintOwnAppleKey() throws -> AppleKeyMaterial {
        var key: AppleKeyMaterial
        if let stamped = parameters.ownAppleKeyID, let minted = try leaves.apple.readAppleKey(id: stamped) {
            key = minted
        } else {
            try requireAppleWriteAllowed()
            key = leaves.ids.mintAppleKey()
            var next = parameters
            next.ownAppleKeyID = key.id
            plan.parameters = next
            try leaves.plans.writePlan(try plan.sealed(under: library.key))
            try leaves.apple.addAppleKey(key, libraryID: stampLibraryID)
            log("minted a fresh own Apple key")
        }
        // Recorded in this Mac's section — also on a resume after a crash
        // between the add and the record.
        if !library.section.appleKeys.contains(where: { $0.id == key.id }) {
            try updateSection { $0.recordingAppleKey(AppleKeyRecord(id: key.id)) }
        }
        return key
    }

    /// This Mac's own Apple key the act minted (or the existing one it
    /// reuses), read here.
    func ownAppleKey() throws -> AppleKeyMaterial {
        try requireAppleWriteAllowed()
        guard let id = parameters.ownAppleKeyID else { throw ExecutorRefusal.appleKeyUnreadable }
        if let key = try leaves.apple.readAppleKey(id: id) { return key }
        // The key this act minted is gone (its keychain replaced or reset
        // before iCloud Keychain carried it): a fresh one, under a fresh id
        // (one minter) — a resume never sticks on it (VX-305 U4, found by the
        // scenario world).
        return try mintOwnAppleKey()
    }
}

extension ProtectionExecutor {
    /// **Use Standard.** Both secrets typed; the words never made new.
    public func useStandard(_ library: inout UnlockedLibrary, typed: TypedSecrets) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        guard record.mode == .castle else { throw ExecutorRefusal.wrongMode(.standard) }
        guard !typed.wordsAreNew else { throw ExecutorRefusal.wordsMustBeTyped }
        var parameters = ActParameters(synced: record.account != nil, accountID: record.account, newKind: .standard)
        let secrets = try await doorSecrets(library, typed: typed, parameters: &parameters)
        return try await perform(
            LeaveCastleProgram(), parameters: parameters, secrets: secrets, typed: typed,
            toKey: leaves.ids.mintLibraryKey(), library: &library)
    }
}
