import CryptoKit
import Foundation

// VX-305 U3 — REPLACE ALL KEYS (design §3.9, on a plan, with the history). An
// enrolled library's security act: the passphrase and the words TYPED (rule 7:
// only creating a library shows fresh words); this library's re-key WITHIN its
// posture — the new key's history takes the old key and its history (rule 4),
// the new key locked under the passphrase, the words and the account's master.
// In Standard the new key goes under this Mac's EXISTING own Apple key — Replace
// All Keys isn't a crossing, so nothing is minted for the library. THE ACCOUNT'S
// SYNC KEY IS NOT REPLACED: it changes only when the account enters Castle (rule
// 15) — PROVISIONAL P-VX378-U2-1 records the reading. (The rotation, the walk
// and the account Apple copy kept under the same key — decision 30 — left with
// VX-378 U2.)

struct ReplaceAllKeysProgram: ActProgram {
    let act = ProtectionAct.replaceAllKeys
    static let afterCommit = ["memory", "retireOldCustody", "backup"]

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        LibraryRekey.steps(guards) + Self.afterCommit
    }

    func newKeySteps(_ parameters: ActParameters) -> Set<String> { LibraryRekey.newKeySteps }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { Self.afterCommit }

    func run(_ step: String, _ ctx: ActContext) async throws {
        let kind = try ctx.parameters.newKind ?? ctx.requireRecord().mode
        switch step {
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
              library.section.appleKeys.contains(where: { $0.id == id && $0.retiredAt == nil })
        else { return nil }
        return try? leaves.apple.readAppleKey(id: id)
    }
}

extension ProtectionExecutor {
    /// **Replace All Keys** — synced, both secrets typed (never made new — rule
    /// 7); the library's key only (rule 15).
    public func replaceAllKeys(_ library: inout UnlockedLibrary, typed: TypedSecrets) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        guard let account = record.account else { throw ExecutorRefusal.notSynced }
        var parameters = ActParameters(
            gate: library.section.settings.gateStyle, synced: true, accountID: account, newKind: record.mode,
            ownAppleKeyID: library.keyFile?.apple?.keyID)
        let secrets = try await doorSecrets(library, typed: typed, parameters: &parameters)
        return try await perform(
            ReplaceAllKeysProgram(), parameters: parameters, secrets: secrets, typed: typed,
            toKey: leaves.ids.mintLibraryKey(), library: &library)
    }
}
