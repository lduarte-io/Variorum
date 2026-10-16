import CryptoKit
import Foundation

// VX-305 U3 — THE OLD SHARED KEY AND RE-LINK (design §3.5, §3.9).
//   - THE MOVE (§3.5 point 2) — keys of this Mac's own BESIDE the old shared
//     key, never instead of it: each other library this Mac holds copies of
//     whose newest copy is in Standard gets this Mac's own key file for it,
//     under an Apple key of its own, made once per library per Mac, its old
//     shared wrap riding beside; the live library, confirmed Standard
//     (decision 35), gains this Mac's own Apple key beside its old wrap; and a
//     fresh backup pair, so the newest pair carries every wrap. The move only
//     adds roads.
//   - THE RETIREMENT (§3.5 point 4–5) — Use Castle's last step (CommonSteps'
//     `retireOldSharedKey`), or its own door on a library already in Castle
//     before this change: the moves again, the vault read fresh, the old-name
//     item deleted only by the id this device's section lists, recorded
//     retired on this device's section only.
//   - RE-LINK (17m's door, reshaped): the account arm mints a FRESH account
//     key and lands the vault's Apple copy under it (never the old shared
//     key; re-keys nothing); the LIBRARY ARM mints a fresh own key for every
//     Standard key file this Mac holds whose own Apple key can't be read here,
//     the live one and other libraries' — re-keying nothing.

struct MoveOffSharedKeyProgram: ActProgram {
    let act = ProtectionAct.moveOffSharedKey
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { ["move"] }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { ["move"] }
    func run(_ step: String, _ ctx: ActContext) async throws { try await ctx.executor.moveOffSharedKey(ctx, freshPair: true) }
}

struct RetireSharedKeyProgram: ActProgram {
    let act = ProtectionAct.retireSharedKey
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { ["retireOldSharedKey"] }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { ["retireOldSharedKey"] }
    func run(_ step: String, _ ctx: ActContext) async throws { try await ctx.retireOldSharedKey() }
}

struct RelinkAppleProgram: ActProgram {
    let act = ProtectionAct.relinkApple
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        parameters.relinksFirst == true ? ["relinkAccount", "memory"] : ["libraryArm", "memory"]
    }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { ["memory"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        switch step {
        case "relinkAccount": try await ctx.relinkAccount()
        case "libraryArm": try ctx.relinkLibraryArm()
        case "memory": try ctx.rememberNewKey()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

extension ActContext {
    /// Re-link's library arm: a fresh own key for each Standard key file this
    /// Mac holds whose own Apple key can't be read here.
    func relinkLibraryArm() throws {
        let readable = try leaves.apple.readableAppleKeyIDs()
        if library.record?.mode == .standard, let live = library.keyFile, live.fingerprint == library.fingerprint,
           live.apple.map({ !readable.contains($0.keyID) }) ?? true {
            let fresh = try mintAppleKey(purpose: .library)
            if library.keyFile?.apple?.keyID != fresh.id {
                try executor.writeLiveKeyFile(try live.settingApple(fresh, for: library.key), &library)
            }
        }
        // Other libraries' own key files: their key reached through the old
        // shared key's wrap while it exists (else it needs that library's
        // secret — reported, not guessed; PROVISIONAL P-U3-5).
        let shared = try leaves.apple.readOldSharedAppleKey()
        for libraryID in parameters.keyFileIDs ?? [] {
            guard let own = try leaves.keyFiles.readOwnKeyFile(libraryID: libraryID, deviceID: deviceID),
                  own.apple.map({ !readable.contains($0.keyID) }) ?? true else { continue }
            guard let shared, let key = try? own.open(sharedApple: shared) else {
                leaves.diagnostics.report(.repairSkipped("relinkLibraryArm \(libraryID.prefix(8)): its key needs its secret"))
                continue
            }
            try requireAppleWriteAllowed()
            let fresh = leaves.ids.mintAppleKey()
            try leaves.apple.addAppleKey(fresh)
            try leaves.keyFiles.writeOwnKeyFile(try own.settingApple(fresh, for: key), deviceID: deviceID)
        }
    }
}

extension ProtectionExecutor {
    /// **The moves** (§3.5 point 2) — also re-run by the retirement.
    /// `freshPair`: the move ends with its fresh backup pair (the migration
    /// takes its own, as its last step).
    func moveOffSharedKey(_ ctx: ActContext, freshPair: Bool) async throws {
        // The gifts open another library's key through the old shared key, so
        // they need it readable; the live library's own key doesn't — a
        // Standard library whose Apple copy never landed (today's exposed and
        // Standard-waiting shapes, confirmed Standard) gains this Mac's own
        // key all the same (§3.13 step 7: "give everything this Mac holds in
        // Standard a key of its own" — VX-305 U4, found by the scenario world).
        let shared = try leaves.apple.readOldSharedAppleKey()
        var moved = false
        for catalogID in shared == nil ? [] : ctx.parameters.keyFileIDs ?? [] {
            guard let shared else { break }
            guard let document = try leaves.keyFiles.readKeyFile(catalogID: catalogID) else { continue }
            let libraryID = document.libraryID
            guard libraryID != ctx.library.record?.libraryID else { continue }
            if let existing = try leaves.keyFiles.readOwnKeyFile(libraryID: libraryID, deviceID: ctx.deviceID),
               existing.apple != nil { continue }  // made once per library per Mac
            var gift: KeyFile
            let key: StoreKey
            let sharedWrap: AppleWrap?
            switch document {
            case .legacy(let legacy):
                guard let opened = try? legacy.open(sharedApple: shared) else { continue }
                key = opened
                gift = KeyFile(libraryID: libraryID, key: key, epoch: 1)
                gift.passphrase = legacy.envelope.passphrase
                gift.words = legacy.envelope.recovery
                sharedWrap = legacy.envelope.apple.map { AppleWrap(keyID: legacy.envelope.appleKeyID ?? shared.id, wrapped: $0) }
            case .format3(let file):
                guard let opened = try? file.open(sharedApple: shared) else { continue }
                key = opened
                gift = file
                gift.apple = nil
                sharedWrap = file.sharedApple
            }
            try ctx.requireAppleWriteAllowed()
            let own = leaves.ids.mintAppleKey()
            try leaves.apple.addAppleKey(own)
            gift = try gift.settingApple(own, for: key)
            gift.sharedApple = guards.moveKeepsOldWrapOn ? sharedWrap : nil
            try leaves.keyFiles.writeOwnKeyFile(gift, deviceID: ctx.deviceID)
            moved = true
        }
        // The live library — confirmed Standard (decision 35 for a synced one).
        if let record = ctx.library.record, record.mode == .standard, record.modeConfirmed,
           let live = ctx.library.keyFile, live.fingerprint == ctx.library.fingerprint, live.apple == nil {
            let own = try ctx.mintAppleKey(purpose: .library)
            var file = try live.settingApple(own, for: ctx.library.key)
            if !guards.moveKeepsOldWrapOn { file = file.droppingSharedApple() }
            try writeLiveKeyFile(file, &ctx.library)
            try ctx.rememberNewKey()
            moved = true
        }
        if moved, freshPair, guards.freshPairAfterMoveOn { try ctx.freshBackup() }
    }

    /// **The move off the old shared key** (§3.5 point 2) — `subjects`: the
    /// serving key files (catalog ids) of the other libraries assess's
    /// MovePlan names.
    public func moveOffSharedKey(_ library: inout UnlockedLibrary, subjects: [String]) async throws -> ActOutcome {
        if let account = library.record?.account, library.record?.mode == .standard {
            try requireSignedIn(as: account)
            guard try await readVault(accountID: account) != nil else { throw ExecutorRefusal.needsFreshVault }
        }
        return try await perform(
            MoveOffSharedKeyProgram(), parameters: ActParameters(keyFileIDs: subjects), secrets: ActSecrets(),
            library: &library)
    }

    /// **Retire the old Apple key…** — a library already in Castle before
    /// this change (its own door, Settings ▸ Protection).
    public func retireOldSharedKey(_ library: inout UnlockedLibrary, moves subjects: [String] = []) async throws -> ActOutcome {
        guard let record = library.record, record.mode == .castle, record.modeConfirmed else {
            throw ExecutorRefusal.wrongMode(library.record?.mode ?? .standard)
        }
        return try await perform(
            RetireSharedKeyProgram(), parameters: ActParameters(keyFileIDs: subjects), secrets: ActSecrets(),
            library: &library)
    }

    /// **Re-link the account** — Standard, synced: a fresh account key minted
    /// at the press, the vault's Apple copy landed under it (CAS). Its consent
    /// says the key reaches other devices only through iCloud Keychain.
    public func relinkAccount(_ library: inout UnlockedLibrary, passphrase: String) async throws -> ActOutcome {
        guard let record = library.record, record.mode == .standard, record.modeConfirmed else {
            throw ExecutorRefusal.wrongMode(library.record?.mode ?? .castle)
        }
        guard let account = record.account else { throw ExecutorRefusal.notSynced }
        try requireSignedIn(as: account)
        guard let vault = try await readVault(accountID: account) else { throw ExecutorRefusal.needsFreshVault }
        // The ACCOUNT must be in Standard and this library current with it: a
        // device that hasn't followed the account into Castle would land an
        // Apple copy over the Castle-era master — the account lowered from a
        // stale device (§3.9's vault invariant — VX-305 U4, found by the
        // scenario world). The follow comes first.
        if vault.reading.rotationInProgress { throw ExecutorRefusal.rotationInProgress }
        if vault.mode.settled != .standard || libraryBehind(library, vault: vault) { throw ExecutorRefusal.accountMoved }
        try vault.format.kdf.validateFloor(configuration.floor)
        let typed = try PassphraseKey.derive(passphrase, kdf: vault.format.kdf)
        guard VaultModel.master(of: vault.format, passphrase: typed, words: nil) != nil else {
            throw ExecutorRefusal.passphraseDoesNotOpen
        }
        var parameters = ActParameters(synced: true, accountID: account, passphraseKDF: typed.kdf)
        parameters.relinksFirst = true
        return try await perform(
            RelinkAppleProgram(), parameters: parameters, secrets: ActSecrets(passphrase: typed), library: &library)
    }

    /// **Re-link's library arm** — `otherLibraries`: the libraries whose own
    /// key file of this Mac's needs a fresh own key (assess's subjects).
    public func relinkLibraryArm(_ library: inout UnlockedLibrary, otherLibraries: [String] = []) async throws -> ActOutcome {
        if let account = library.record?.account {
            try requireSignedIn(as: account)
            guard try await readVault(accountID: account) != nil else { throw ExecutorRefusal.needsFreshVault }
        }
        return try await perform(
            RelinkAppleProgram(), parameters: ActParameters(keyFileIDs: otherLibraries), secrets: ActSecrets(),
            library: &library)
    }
}
