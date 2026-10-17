import CryptoKit
import Foundation

// VX-305 U3 — USE CASTLE (rule 11, `notes/CastleRules.md`: "entering takes
// everything in"). The door: the passphrase and the words, both TYPED (rule 11's
// passphrase; the words because nothing else can lock the new key or the new
// master under them — rules 2, 14; never made new — rule 7). Synced, the
// account's part first: ONE vault write (a new master, a new sync key, every
// earlier sync key re-sealed under the new master, the mode Castle — rule 15),
// its write taking the door's revision (VX-109). Then the new key in
// prepare-then-commit order — its custody item (a Touch ID item made at THIS
// press, or none under Always ask), the new key file (P, W, plus the new master
// when synced; the history taking every older key — rule 4; no Apple wrap), the
// record into the staged file, the swap. Then what this Mac remembers; the old
// custody item and every silent item — each only once the history verifiably
// holds its key; the scheduled export off, with one notice; a fresh backup;
// every Apple key of this Mac's own for the library deleted and recorded
// retired. (The rotation's walk and completing write, and the account's Apple
// key, left with VX-378 U2 — rules 14, 15.)

struct EnterCastleProgram: ActProgram {
    let act = ProtectionAct.enterCastle
    static let afterCommit = ["memory", "retireOldCustody", "exportOff", "backup", "retireOwnAppleKeys"]

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        (parameters.synced == true ? ["vaultWrite"] : []) + LibraryRekey.steps(guards) + Self.afterCommit
    }

    func newKeySteps(_ parameters: ActParameters) -> Set<String> { LibraryRekey.newKeySteps }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { Self.afterCommit }

    func run(_ step: String, _ ctx: ActContext) async throws {
        switch step {
        case "vaultWrite": try await ctx.enterCastleWrite()
        case "custodyItem": try ctx.newCustodyItem(kind: .castle)
        case "keyFile":
            try ctx.newKeyFile(
                rekeyTo: .castle,
                locks: try ctx.newLocks(passphrase: true, words: true, master: ctx.parameters.synced == true))
        case "stage": try ctx.stage()
        case "recordIntoStaged": try ctx.recordIntoStaged(kind: .castle)
        case "swap": try ctx.swap { try ctx.stage(); try ctx.recordIntoStaged(kind: .castle) }
        case "memory": try ctx.rememberNewKey()
        case "retireOldCustody": try ctx.retireOldCustody(sweepForCastle: true)
        case "exportOff": try ctx.turnExportOff()
        case "backup": try ctx.freshBackup()
        case "retireOwnAppleKeys": try ctx.retireOwnAppleKeys()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

extension ProtectionExecutor {
    /// **Use Castle** — `gate`: Touch ID (an item made at this press, where a
    /// finger is enrolled) or Always ask.
    public func useCastle(_ library: inout UnlockedLibrary, typed: TypedSecrets, gate: GateStyle) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        if record.mode == .castle { throw ExecutorRefusal.wrongMode(.castle) }
        var parameters = ActParameters(
            gate: gate, synced: record.account != nil, accountID: record.account, newKind: .castle,
            outgoingAppleKeyID: library.keyFile?.apple?.keyID)
        let secrets = try await doorSecrets(library, typed: typed, parameters: &parameters)
        // Rule 9: "Touch ID on this Mac is optional" — chosen at THIS press and
        // remembered in this Mac's section with the act's first write (the
        // follow's shape), so a later Castle re-key makes its Touch ID item.
        if library.section.settings.gateStyle != gate {
            var settings = library.section.settings
            settings.gateStyle = gate
            library.section = library.section.withSettings(settings)
        }
        return try await perform(
            EnterCastleProgram(), parameters: parameters, secrets: secrets, typed: typed,
            toKey: leaves.ids.mintLibraryKey(), library: &library)
    }

    /// The door's secrets for a crossing or Replace All Keys: the passphrase
    /// TYPED — verified against the vault's copy when synced, the live key
    /// file's when local (set new when the library has none — rule 3); the
    /// words TYPED and verified (rule 7: only creating a library shows fresh
    /// words — `wordsAreNew` refuses). A synced door also reads the vault fresh
    /// (VX-108: the acts read the vault they fetch) and refuses while the
    /// account moved elsewhere (follow first).
    func doorSecrets(
        _ library: UnlockedLibrary, typed: TypedSecrets, parameters: inout ActParameters
    ) async throws -> ActSecrets {
        var secrets = ActSecrets()
        guard !typed.wordsAreNew else { throw ExecutorRefusal.wordsMustBeTyped }
        if let account = parameters.accountID, parameters.synced == true {
            try requireSignedIn(as: account)
            guard let vault = try await readVault(accountID: account) else { throw ExecutorRefusal.needsFreshVault }
            if libraryBehind(library, vault: vault) { throw ExecutorRefusal.accountMoved }
            // The account in another mode than the library: the follow comes
            // first (a door begun here would refuse inside its plan, leaving
            // the act in flight — VX-305 U4, found by the scenario world).
            if vault.mode != library.record?.mode { throw ExecutorRefusal.accountMoved }
            guard let text = typed.passphrase else { throw ExecutorRefusal.secretMissing }
            try vault.vault.kdf.validateFloor(configuration.floor)
            let passphrase = try PassphraseKey.derive(text, kdf: vault.vault.kdf)
            guard VaultModel.master(of: vault.vault, passphrase: passphrase, words: nil) != nil else {
                throw ExecutorRefusal.passphraseDoesNotOpen
            }
            secrets.passphrase = passphrase
            guard let words = typed.words else { throw ExecutorRefusal.secretMissing }
            let wordsKey = try WordsKey.derive(words)
            guard VaultModel.master(of: vault.vault, passphrase: nil, words: wordsKey) != nil else {
                throw ExecutorRefusal.wordsDoNotOpen
            }
            secrets.words = wordsKey
            parameters.doorRevision = vault.revision
            parameters.doorRowKeyID = vault.rowKeyID
        } else {
            if library.keyFile?.passphrase != nil {
                secrets.passphrase = try verifiedPassphrase(typed.passphrase, against: library.keyFile)
            } else {
                // The passphrase typed — set if none yet (rule 3: a library is
                // asked for one; until then it has its words, rule 2).
                guard let text = typed.passphrase ?? typed.newPassphrase else { throw ExecutorRefusal.secretMissing }
                secrets.passphrase = try freshPassphrase(text)
                parameters.passphraseIsNew = true
            }
            guard let words = typed.words else { throw ExecutorRefusal.secretMissing }
            // Rule 2: every library has its words — typed ones are verified,
            // never adopted unverified (the no-words arm left with VX-378 U1).
            secrets.words = try verifiedWords(words, against: library.keyFile)
        }
        parameters.passphraseKDF = secrets.passphrase?.kdf
        parameters.wordsAreNew = typed.wordsAreNew
        return secrets
    }

    /// A synced act runs signed in as the library's account (§3.8's
    /// situations: signed out — the one plain road; another account — Move or
    /// Sign out).
    func requireSignedIn(as account: String) throws {
        switch configuration.session {
        case .signedOut: throw ExecutorRefusal.signedOutUseThisMacOnly
        case .signedIn(let id, _) where id != account: throw ExecutorRefusal.otherAccountSignedIn
        case .signedIn: return
        }
    }
}
