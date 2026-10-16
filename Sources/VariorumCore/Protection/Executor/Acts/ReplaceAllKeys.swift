import CryptoKit
import Foundation

// VX-305 U3 — REPLACE ALL KEYS (design §3.9: "as today (decision 30
// included), on a plan, with the history"). An enrolled library's security
// act: the passphrase typed and the words typed or made new (decision 33); the
// rotation — Standard keeping the account's Apple copy under the SAME account
// key (read, never minted — decision 30), Castle with none; then this
// library's re-key WITHIN its mode: the new key's history takes the old key and
// its history (rule 4). In Standard the new key goes under this Mac's EXISTING
// own Apple key — Replace All Keys isn't a crossing, so nothing is minted for
// the library.

struct ReplaceAllKeysProgram: ActProgram {
    let act = ProtectionAct.replaceAllKeys
    static let afterCommit = ["memory", "retireOldCustody", "backup"]

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        let steps = ["rotationWrite", "walk", "rotationComplete"]
        return steps + LibraryRekey.steps(guards) + Self.afterCommit
    }

    func newKeySteps(_ parameters: ActParameters) -> Set<String> { LibraryRekey.newKeySteps }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { Self.afterCommit }

    func run(_ step: String, _ ctx: ActContext) async throws {
        let kind = try ctx.parameters.newKind ?? ctx.requireRecord().mode
        switch step {
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
            try ctx.newKeyFile(rekeyTo: kind, locks: try ctx.newLocks(passphrase: true, words: true, master: true, apple: apple))
        case "stage": try ctx.stage()
        case "recordIntoStaged": try ctx.recordIntoStaged(kind: kind)
        case "swap": try ctx.swap { try ctx.stage(); try ctx.recordIntoStaged(kind: kind) }
        case "memory": try ctx.rememberNewKey()
        case "retireOldCustody": try ctx.retireOldCustody(sweepForCastle: false)
        case "backup": try ctx.freshBackup()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

extension ActContext {
    /// This Mac's EXISTING own Apple key for the library, when readable here
    /// (a Standard re-key within its mode mints nothing; with none readable
    /// the new file carries no Apple wrap — the Apple road is lost, reported,
    /// and rule 8's quiet re-make is U2's).
    func existingOwnAppleKey() -> AppleKeyMaterial? {
        guard let id = parameters.ownAppleKeyID ?? library.keyFile?.apple?.keyID,
              library.section.appleKeys.contains(where: { $0.id == id && $0.isOwnLibraryKey && $0.retiredAt == nil })
        else { return nil }
        return try? leaves.apple.readAppleKey(id: id)
    }
}

extension ProtectionExecutor {
    /// **Replace All Keys** — synced, both secrets typed (the words typed or
    /// made new).
    public func replaceAllKeys(_ library: inout UnlockedLibrary, typed: TypedSecrets) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        guard let account = record.account else { throw ExecutorRefusal.notSynced }
        var parameters = ActParameters(
            gate: library.section.settings.gateStyle, synced: true, accountID: account, newKind: record.mode,
            ownAppleKeyID: library.keyFile?.apple?.keyID)
        let secrets = try await doorSecrets(library, typed: typed, wordsMayBeNew: true, parameters: &parameters)
        // Decision 30, at the DOOR: a Standard Replace All Keys keeps the new
        // master under the account's own Apple key, read here — never minted.
        // With none readable (and no re-link first), it is refused before any
        // write (refused from inside the plan, it left the act in flight with
        // nothing able to finish it — VX-305 U4, found by the scenario world).
        if record.mode == .standard, let vault = freshVaults[account],
           vault.format.masterWrappedByAppleHeld != nil {
            guard let id = vault.format.appleKeyID, try leaves.apple.readAppleKey(id: id) != nil else {
                throw ExecutorRefusal.appleKeyUnreadable
            }
        }
        return try await perform(
            ReplaceAllKeysProgram(), parameters: parameters, secrets: secrets, typed: typed,
            toKey: leaves.ids.mintLibraryKey(), library: &library)
    }
}
