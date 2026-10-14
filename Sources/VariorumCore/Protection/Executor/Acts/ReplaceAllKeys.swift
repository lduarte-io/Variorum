import CryptoKit
import Foundation

// VX-305 U3 — REPLACE ALL KEYS (design §3.9: "as today (decision 30
// included), on a plan, with the history"). An enrolled library's security
// act: the passphrase typed and the words typed or made new (decision 33); the
// rotation — Standard keeping the account's Apple copy under the SAME account
// key (read, never minted — decision 30), Castle with none; then this
// library's re-key WITHIN its mode: the new key's history takes the old key and
// its history, the anchor carried unchanged. In Standard the new key goes under
// this Mac's EXISTING own Apple key — Replace All Keys isn't a crossing, so
// nothing is minted for the library. An account still on the old shared key
// is re-linked first (§3.5 point 7): a fresh account key, so the new master
// goes under the account's own key.

struct ReplaceAllKeysProgram: ActProgram {
    let act = ProtectionAct.replaceAllKeys
    static let afterCommit = ["memory", "retireOldCustody", "backup"]

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        var steps: [String] = parameters.relinksFirst == true ? ["relinkAccount"] : []
        steps += ["rotationWrite", "walk", "rotationComplete"]
        return steps + LibraryRekey.steps(guards) + Self.afterCommit
    }

    func newKeySteps(_ parameters: ActParameters) -> Set<String> { LibraryRekey.newKeySteps }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { Self.afterCommit }

    func run(_ step: String, _ ctx: ActContext) async throws {
        let kind = try ctx.parameters.newKind ?? ctx.requireRecord().mode
        switch step {
        case "relinkAccount":
            try await ctx.relinkAccount()
        case "rotationWrite":
            if kind == .standard {
                // Decision 30: under the SAME account key — read here and the
                // vault's, never minted; refused before any write otherwise.
                let snapshot = try await ctx.freshRead()
                guard let id = snapshot.format.appleKeyID, let key = try ctx.leaves.apple.readAppleKey(id: id) else {
                    throw ExecutorRefusal.appleKeyUnreadable
                }
                try await ctx.rotationWrite(apple: .keptUnder(key), castleWay: false)
            } else {
                try await ctx.rotationWrite(apple: .none, castleWay: true)
            }
        case "walk": try await ctx.walk()
        case "rotationComplete": try await ctx.completeRotation(castleWayAfter: kind == .castle)
        case "custodyItem": try ctx.newCustodyItem(kind: kind)
        case "keyFile":
            let apple = kind == .standard ? ctx.existingOwnAppleKey() : nil
            try ctx.newKeyFile(.withinMode, locks: try ctx.newLocks(passphrase: true, words: true, master: true, apple: apple))
        case "stage": try ctx.stage()
        case "recordIntoStaged": try ctx.recordIntoStaged(kind: kind)
        case "swap": try ctx.swap { try ctx.stage(); try ctx.recordIntoStaged(kind: kind) }
        case "memory":
            try ctx.rememberNewKey()
            ctx.saySentence(.replacesWords)
        case "retireOldCustody": try ctx.retireOldCustody(sweepForCastle: false)
        case "backup": try ctx.freshBackup()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

extension ActContext {
    /// This Mac's EXISTING own Apple key for the library, when readable here
    /// (a Standard re-key within its mode mints nothing; with none readable
    /// the new file carries no Apple wrap — the Apple road is lost and
    /// Re-link's library arm is offered).
    func existingOwnAppleKey() -> AppleKeyMaterial? {
        guard let id = parameters.ownAppleKeyID ?? library.keyFile?.apple?.keyID,
              library.section.appleKeys.contains(where: { $0.id == id && $0.isOwnLibraryKey && $0.retiredAt == nil })
        else { return nil }
        return try? leaves.apple.readAppleKey(id: id)
    }

    /// Re-link the account (17m's door, reshaped — §3.9): a FRESH account
    /// key minted at the press, the vault's Apple copy of the master landed
    /// under it with the vault's CAS. Never the old shared key; re-keys
    /// nothing. Idempotent: a vault already naming this act's key is done.
    func relinkAccount() async throws {
        let snapshot = try await freshRead()
        if let id = parameters.accountAppleKeyID, snapshot.format.appleKeyID == id,
           snapshot.format.masterWrappedByAppleHeld != nil {
            return
        }
        let key = try mintAppleKey(purpose: .account)
        let held = try material(for: snapshot)
        let format = try snapshot.format.settingAppleHeldCopy(
            masterKey: held.masterSymmetricKey, appleKey: key.key, appleKeyID: key.id)
        let written = try await leaves.vault.updateVault(
            format, accountID: snapshot.accountID, expectedRevision: snapshot.revision,
            proofMaster: held.masterSymmetricKey, device: deviceName)
        executor.noteFresh(written)
        log("the account re-linked under a fresh key")
    }

    /// Every door that replaces a secret while an anchor exists says what
    /// still opens the copies from before the leave — one sentence, from the
    /// route finder, for this device's anchor (§3.9).
    func saySentence(_ door: SecretReplacingDoor) {
        if let sentence = executor.anchorSentence(door, keyFile: library.keyFile) {
            outcome.done.append(.anchor(sentence))
        }
    }
}

extension ProtectionExecutor {
    /// The anchor sentence for `door`, from the route finder over this
    /// device's live key file (nil when it carries no anchor).
    func anchorSentence(_ door: SecretReplacingDoor, keyFile: KeyFile?) -> AnchorSentence? {
        guard let keyFile, keyFile.anchor != nil, let bytes = try? keyFile.encoded() else { return nil }
        let catalog = Catalog.build([CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: bytes)])
        return RouteFinder(RouteFacts(catalog: catalog)).anchorSentence(for: door)
    }

    /// **Replace All Keys** — synced, both secrets typed (the words typed or
    /// made new).
    public func replaceAllKeys(_ library: inout UnlockedLibrary, typed: TypedSecrets) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.migrationOwed }
        guard record.modeConfirmed else { throw ExecutorRefusal.modeNotConfirmed }
        guard let account = record.account else { throw ExecutorRefusal.notSynced }
        var parameters = ActParameters(
            gate: library.section.settings.gateStyle, synced: true, accountID: account, newKind: record.mode,
            ownAppleKeyID: library.keyFile?.apple?.keyID)
        let secrets = try await doorSecrets(library, typed: typed, wordsMayBeNew: true, parameters: &parameters)
        if let vault = freshVaults[account], vault.format.masterWrappedByAppleHeld != nil,
           let id = vault.format.appleKeyID, let shared = try leaves.apple.readOldSharedAppleKey(), shared.id == id {
            parameters.relinksFirst = true
        }
        return try await perform(
            ReplaceAllKeysProgram(), parameters: parameters, secrets: secrets, typed: typed,
            toKey: leaves.ids.mintLibraryKey(), library: &library)
    }
}
