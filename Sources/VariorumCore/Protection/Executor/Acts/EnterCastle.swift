import CryptoKit
import Foundation

// VX-305 U3 — USE CASTLE (design §3.9; §3.4's "entering Castle — everything";
// §3.5's retirements). The door: the passphrase and the words typed (decision
// 33 — the words typed or made new); synced, the rotation exactly as today's
// protocol with VX-109's fix (its first write takes the door's revision). Then
// the new key in prepare-then-commit order — its custody item (a Touch ID item
// made at THIS press, or none under Always ask), the new key file (P, W, plus
// the new master when synced; the history taking every older key, the anchor
// folded back in — an anchor the typed secrets can't open kept beside it,
// unchanged; no Apple wrap), the record into the staged file, the swap. Then
// what this Mac remembers; the old custody item, every silent item, the
// per-library-ID items, the 13p escrow items and the format-1/2 key files —
// each only once the history verifiably holds its key; the scheduled export
// off, with one notice; a fresh backup; every Apple key of this Mac's own for
// the library deleted and recorded retired (synced: the account's was, when
// the rotation completed). (The old shared key's retirement left with rule 26.)

struct EnterCastleProgram: ActProgram {
    let act = ProtectionAct.enterCastle
    static let afterCommit = ["memory", "retireOldCustody", "exportOff", "backup", "retireOwnAppleKeys"]

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        var steps: [String] = []
        if parameters.synced == true { steps += ["rotationWrite", "walk", "rotationComplete"] }
        return steps + LibraryRekey.steps(guards) + Self.afterCommit
    }

    func newKeySteps(_ parameters: ActParameters) -> Set<String> { LibraryRekey.newKeySteps }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { Self.afterCommit }

    func run(_ step: String, _ ctx: ActContext) async throws {
        switch step {
        case "rotationWrite": try await ctx.rotationWrite(apple: .none, castleWay: true)
        case "walk": try await ctx.walk()
        case "rotationComplete":
            try await ctx.completeRotation(castleWayAfter: true)
            try ctx.retireAccountAppleKey()
        case "custodyItem": try ctx.newCustodyItem(kind: .castle)
        case "keyFile":
            try ctx.newKeyFile(
                .enteringCastle(openers: ctx.anchorOpeners()),
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

extension ActContext {
    /// The secrets typed at this door or follow, as openers for an anchor of
    /// an earlier day (its own descriptor) — §3.4's fold.
    func anchorOpeners() -> [ProtectionSecret] {
        var openers: [ProtectionSecret] = []
        if let typedPassphrase { openers.append(.passphrase(typedPassphrase)) }
        if let passphrase = secrets.passphrase { openers.append(.passphraseKey(passphrase)) }
        if let typedWords { openers.append(.words(typedWords)) }
        return openers
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
        let secrets = try await doorSecrets(library, typed: typed, wordsMayBeNew: true, parameters: &parameters)
        if let account = record.account, let vault = freshVaults[account] {
            parameters.retiringAccountAppleKeyID = vault.format.masterWrappedByAppleHeld != nil ? vault.format.appleKeyID : nil
        }
        return try await perform(
            EnterCastleProgram(), parameters: parameters, secrets: secrets, typed: typed,
            toKey: leaves.ids.mintLibraryKey(), library: &library)
    }

    /// The door's secrets for a crossing or a rotation (decision 33): the
    /// passphrase TYPED — verified against the vault's copy when synced, the
    /// live key file's when local (set new when the library has none); the
    /// words TYPED and verified, or — where `wordsMayBeNew` — made new. A
    /// synced door also reads the vault fresh (VX-108: the acts read the
    /// vault they fetch) and refuses while a rotation stands (decision 32) or
    /// the account moved elsewhere (follow first).
    func doorSecrets(
        _ library: UnlockedLibrary, typed: TypedSecrets, wordsMayBeNew: Bool, parameters: inout ActParameters
    ) async throws -> ActSecrets {
        var secrets = ActSecrets()
        if let account = parameters.accountID, parameters.synced == true {
            try requireSignedIn(as: account)
            guard let vault = try await readVault(accountID: account) else { throw ExecutorRefusal.needsFreshVault }
            if vault.reading.rotationInProgress { throw ExecutorRefusal.rotationInProgress }
            if libraryBehind(library, vault: vault) { throw ExecutorRefusal.accountMoved }
            // The account in another mode than the library: the follow comes
            // first (a door begun here would refuse inside its plan, leaving
            // the act in flight — VX-305 U4, found by the scenario world).
            if let settled = vault.mode.settled, settled != library.record?.mode { throw ExecutorRefusal.accountMoved }
            guard let text = typed.passphrase else { throw ExecutorRefusal.secretMissing }
            try vault.format.kdf.validateFloor(configuration.floor)
            let passphrase = try PassphraseKey.derive(text, kdf: vault.format.kdf)
            guard VaultModel.master(of: vault.format, passphrase: passphrase, words: nil) != nil else {
                throw ExecutorRefusal.passphraseDoesNotOpen
            }
            secrets.passphrase = passphrase
            guard let words = typed.words else { throw ExecutorRefusal.secretMissing }
            if typed.wordsAreNew {
                guard wordsMayBeNew else { throw ExecutorRefusal.wordsMustBeTyped }
            } else if vault.format.masterWrappedByRecovery != nil {
                guard VaultModel.master(of: vault.format, passphrase: nil, words: try WordsKey.derive(words)) != nil else {
                    throw ExecutorRefusal.wordsDoNotOpen
                }
            }
            secrets.words = try WordsKey.derive(words)
            parameters.doorRevision = vault.revision
            parameters.oldCorpusKeyID = vault.corpusKeyID
        } else {
            if library.keyFile?.passphrase != nil {
                secrets.passphrase = try verifiedPassphrase(typed.passphrase, against: library.keyFile)
            } else {
                // The passphrase typed — set if none (an exposed-era library).
                guard let text = typed.passphrase ?? typed.newPassphrase else { throw ExecutorRefusal.secretMissing }
                secrets.passphrase = try freshPassphrase(text)
                parameters.passphraseIsNew = true
            }
            guard let words = typed.words else { throw ExecutorRefusal.secretMissing }
            if typed.wordsAreNew || library.keyFile?.words == nil {
                guard wordsMayBeNew || library.keyFile?.words == nil else { throw ExecutorRefusal.wordsMustBeTyped }
                secrets.words = try WordsKey.derive(words)
            } else {
                secrets.words = try verifiedWords(words, against: library.keyFile)
            }
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
