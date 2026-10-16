import CryptoKit
import Foundation

// VX-305 U3 — USE STANDARD: LEAVING CASTLE IS A KEY CHANGE (design §3.9; her
// round-2 ruling "a fresh key at every crossing"; §3.4's "leaving Castle —
// nothing"). The door: the passphrase and the twelve words, typed — the words
// never made new here, so the paper she has keeps opening what stays behind —
// and rule 5's sentence.
//   1. THE ANCHOR FIRST: the outgoing Castle key and its whole history sealed
//      under the typed passphrase and words, written into the CURRENT key
//      file before any other step, and carried into the new one.
//   2. Synced, the rotation: the account's FRESH Apple key minted at this
//      press (in iCloud Keychain before the write), then the first write
//      naming its id in `apple_key_id` with NO wrap — the mark of a leave, and
//      the account's commit point (past it a crash resumes, never rolls back).
//      The new sync keys and the previous corpus key stay in Castle-kind
//      custody while the previous key stands. The walk. One write completes
//      the leave — the account's Apple wrap under the named key, the window
//      closed — made only by a device that reads that key (this one: it
//      minted it). Then the sync keys go to a silent item.
//   3. The new library key: its silent item; this Mac's own FRESH Apple key;
//      the new key file (the Apple wrap, P, W, the new master when synced; an
//      empty history; the anchor carried); the record into the staged file;
//      the swap.
//   4. What this Mac remembers; the Castle key's Touch ID item goes with its
//      key; a fresh backup.

struct LeaveCastleProgram: ActProgram {
    let act = ProtectionAct.leaveCastle
    static let afterCommit = ["memory", "retireOldCustody", "backup"]

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        var steps = ["anchor"]
        if parameters.synced == true {
            steps += ["mintAccountAppleKey", "rotationWrite", "walk", "rotationComplete"]
        }
        return steps + LibraryRekey.steps(guards, mintsOwnAppleKey: true) + Self.afterCommit
    }

    func newKeySteps(_ parameters: ActParameters) -> Set<String> { LibraryRekey.newKeySteps }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { Self.afterCommit }

    func run(_ step: String, _ ctx: ActContext) async throws {
        switch step {
        case "anchor":
            guard let words = ctx.secrets.words else { throw ExecutorRefusal.secretsRequired(ctx.act) }
            try ctx.writeAnchor(.pressingDevice(passphrase: try ctx.requirePassphrase(), words: words))
        case "mintAccountAppleKey":
            _ = try ctx.mintAppleKey(purpose: .account)
        case "rotationWrite":
            guard let id = ctx.parameters.accountAppleKeyID else { throw ExecutorRefusal.appleKeyUnreadable }
            try await ctx.rotationWrite(
                apple: .leaveNaming(id: id), castleWay: ctx.executor.guards.castleKindCustodyThroughLeaveOn)
        case "walk": try await ctx.walk()
        case "rotationComplete": try await ctx.completeRotation(castleWayAfter: false)
        case "mintOwnAppleKey": _ = try ctx.mintAppleKey(purpose: .library)
        case "custodyItem": try ctx.newCustodyItem(kind: .standard)
        case "keyFile":
            try ctx.newKeyFile(
                .leavingCastle,
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
        // A leave of the account writes its NEW key's Apple wrap for a library
        // that is local from the swap on — nothing synced to read the vault
        // for (and a resume, which reads no vault, must not stick on it —
        // VX-305 U4, found by the scenario world).
        if parameters.changesAccount == true, parameters.targetAccount == nil { return }
        guard executor.guards.freshVaultBeforeAppleWriteOn, let account = library.record?.account ?? accountID else { return }
        guard executor.readThisSession(account) else { throw ExecutorRefusal.needsFreshVault }
    }

    /// **Mint a fresh Apple key** — always under a fresh id (one minter,
    /// §3.5): its id stamped in the plan first (a crash after the add still
    /// knows it), the item added, the id recorded in this Mac's section.
    /// Idempotent: a key this act already minted is read back.
    func mintAppleKey(purpose: AppleKeyPurpose, recordedInThisSection: Bool = true) throws -> AppleKeyMaterial {
        let stamped = purpose == .library ? parameters.ownAppleKeyID : parameters.accountAppleKeyID
        var key: AppleKeyMaterial
        if let stamped, let minted = try leaves.apple.readAppleKey(id: stamped) {
            key = minted
        } else {
            try requireAppleWriteAllowed()
            key = leaves.ids.mintAppleKey()
            var next = parameters
            if purpose == .library { next.ownAppleKeyID = key.id } else { next.accountAppleKeyID = key.id }
            plan.parameters = next
            try leaves.plans.writePlan(try plan.sealed(under: library.key))
            try leaves.apple.addAppleKey(key)
            log("minted a fresh \(purpose.rawValue) Apple key")
        }
        // Recorded in this Mac's section — also on a resume after a crash
        // between the add and the record.
        if recordedInThisSection, !library.section.appleKeys.contains(where: { $0.id == key.id }) {
            try updateSection {
                $0.recordingAppleKey(AppleKeyRecord(
                    id: key.id, purpose: purpose, accountID: purpose == .account ? accountID : nil, origin: .minted))
            }
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
        return try mintAppleKey(purpose: .library)
    }
}

extension ProtectionExecutor {
    /// **Use Standard.** Both secrets typed; the words never made new.
    /// Corner 45's Castle-not-yet-confirmed library takes this road as the
    /// key change it now is.
    public func useStandard(_ library: inout UnlockedLibrary, typed: TypedSecrets) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.migrationOwed }
        guard record.mode == .castle else { throw ExecutorRefusal.wrongMode(.standard) }
        guard record.modeConfirmed || record.account == nil else { throw ExecutorRefusal.modeNotConfirmed }
        guard !typed.wordsAreNew else { throw ExecutorRefusal.wordsMustBeTyped }
        var parameters = ActParameters(synced: record.account != nil, accountID: record.account, newKind: .standard)
        let secrets = try await doorSecrets(library, typed: typed, wordsMayBeNew: false, parameters: &parameters)
        return try await perform(
            LeaveCastleProgram(), parameters: parameters, secrets: secrets, typed: typed,
            toKey: leaves.ids.mintLibraryKey(), library: &library)
    }
}
