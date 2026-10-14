import CryptoKit
import Foundation

// VX-305 U3 — THIS MAC'S ACTS (design §3.6, §3.10, §3.13): the settings that
// could weaken protection (the gate style, the idle lock, the scheduled
// export — sealed in this Mac's facts, written into both homes); the Touch ID
// re-arm (only after a press failed on an item that exists — her confirmed
// call); confirming the mode (a flag only when the current key was born in
// it — otherwise a key change, the crossing's road); and creating a library.

struct DeviceSettingsProgram: ActProgram {
    let act = ProtectionAct.deviceSettings
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { ["custody", "settings", "memory"] }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { ["memory"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        guard let wanted = ctx.parameters.settings else { throw ExecutorRefusal.nothingToDo }
        let fingerprint = ctx.library.fingerprint
        let item = CustodyItemFact(fingerprint: fingerprint, itemClass: .touchid)
        switch step {
        case "custody":
            guard ctx.library.record?.mode == .castle else { return }
            let has = try ctx.leaves.custody.custodyItems().contains(item)
            if wanted.gateStyle == .touchID, !has {
                // Touch ID comes on only from Settings, with the passphrase, at
                // THIS press (§3.10).
                try ctx.leaves.custody.writeCustody(ctx.library.key, itemClass: .touchid)
            } else if wanted.gateStyle != .touchID, has {
                try ctx.leaves.custody.deleteCustody(fingerprint: fingerprint, itemClass: .touchid)
            }
        case "settings":
            if ctx.library.section.settings != wanted { try ctx.updateSection { $0.withSettings(wanted) } }
        case "memory":
            try ctx.rememberNewKey()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

struct TouchIDRearmProgram: ActProgram {
    let act = ProtectionAct.touchIDRearm
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { ["custody", "settings", "memory"] }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { ["memory"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        let yes = ctx.parameters.gate == .touchID
        let fingerprint = ctx.library.fingerprint
        switch step {
        case "custody":
            // The stale item goes either way; a new one only on yes, at this press.
            if try ctx.leaves.custody.custodyItems().contains(CustodyItemFact(fingerprint: fingerprint, itemClass: .touchid)) {
                try ctx.leaves.custody.deleteCustody(fingerprint: fingerprint, itemClass: .touchid)
            }
            if yes { try ctx.leaves.custody.writeCustody(ctx.library.key, itemClass: .touchid) }
        case "settings":
            var settings = ctx.library.section.settings
            settings.gateStyle = yes ? .touchID : .alwaysAsk
            if settings != ctx.library.section.settings { try ctx.updateSection { $0.withSettings(settings) } }
        case "memory":
            try ctx.rememberNewKey()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

struct ConfirmModeProgram: ActProgram {
    let act = ProtectionAct.confirmMode
    /// Confirming runs what the migration deferred while the mode was
    /// unconfirmed (§3.13 steps 4 and 7): the per-key custody items, and — a
    /// Standard library — this Mac's own Apple key with its fresh pair (VX-305
    /// U4, found by the scenario world: confirming only flipped the flag, and
    /// nothing ever minted that key).
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { ["confirm", "custodyItems", "moves"] }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { ["confirm", "custodyItems", "moves"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        switch step {
        case "confirm":
            guard var record = ctx.library.record else { throw ExecutorRefusal.recordMissing }
            guard !record.modeConfirmed else { return }
            record.modeConfirmed = true
            try ctx.leaves.library.writeRecord(record, with: ctx.library.key)
            ctx.library.record = record
            try ctx.rememberNewKey()
        case "custodyItems": try ctx.addPerKeyCustodyItems()
        case "moves":
            // Decision 35: a synced library's own Apple key only on a fresh read.
            if let record = ctx.library.record, record.mode == .standard, let account = record.account,
               !ctx.executor.readThisSession(account) { return }
            try await ctx.executor.moveOffSharedKey(ctx, freshPair: true)
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

/// Creating a library runs with no plan (an empty slot has nothing to
/// protect or resume); no section ever names this act.
struct CreateLibraryProgram: ActProgram {
    let act = ProtectionAct.createLibrary
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { [] }
    func run(_ step: String, _ ctx: ActContext) async throws { throw ExecutorRefusal.nothingToDo }
}

extension ProtectionExecutor {
    /// **This Mac's settings** — the gate style (Touch ID on only here, with
    /// the passphrase; off deletes the item), the idle lock, the scheduled
    /// export — written into both homes.
    public func changeSettings(_ library: inout UnlockedLibrary, to settings: DeviceSettings, passphrase: String? = nil) async throws -> ActOutcome {
        if settings.gateStyle == .touchID, library.section.settings.gateStyle != .touchID {
            guard library.record?.mode == .castle else { throw ExecutorRefusal.wrongMode(.standard) }
            let biometry = leaves.biometry.biometry()
            guard biometry.hardware, biometry.enrolled else { throw ExecutorRefusal.nothingToDo }
            _ = try verifiedPassphrase(passphrase, against: library.keyFile)
        }
        return try await perform(
            DeviceSettingsProgram(), parameters: ActParameters(settings: settings), secrets: ActSecrets(), library: &library)
    }

    /// **The re-arm question's answer** — asked only after a press failed on
    /// an item that EXISTS (the guard: no question without an item). Yes
    /// makes a new item at this press; no records Always ask.
    public func answerTouchIDRearm(_ library: inout UnlockedLibrary, yes: Bool) async throws -> ActOutcome {
        guard try leaves.custody.custodyItems().contains(CustodyItemFact(fingerprint: library.fingerprint, itemClass: .touchid))
        else { throw ExecutorRefusal.nothingToDo }
        return try await perform(
            TouchIDRearmProgram(), parameters: ActParameters(gate: yes ? .touchID : .alwaysAsk), secrets: ActSecrets(),
            library: &library)
    }

    /// **Confirm the recorded mode** — when the vault answered, or corner 45's
    /// notice was. A mode the current key wasn't born in is a key change, never
    /// a move: refused here — Use Standard (or the follow) is its road.
    public func confirmMode(_ library: inout UnlockedLibrary, as mode: ProtectionMode) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.migrationOwed }
        guard !record.modeConfirmed else { throw ExecutorRefusal.nothingToDo }
        let born = library.familyTree.entry(library.fingerprint)?.kind ?? record.mode
        guard mode == born, mode == record.mode else { throw ExecutorRefusal.wrongMode(record.mode) }
        if let account = record.account, configuration.session.accountID == account {
            _ = try await readVault(accountID: account)
        }
        return try await perform(
            ConfirmModeProgram(), parameters: ActParameters(targetMode: mode), secrets: ActSecrets(), library: &library)
    }

    /// **Create a library** in an empty slot — in Standard (the default): its
    /// key, its silent item, this Mac's own Apple key, its key file (the
    /// passphrase and words when given), its record and this Mac's section, what
    /// this Mac remembers. Nothing to protect yet and nothing to resume: a crash
    /// leaves the slot empty and the creation runs again (a recorded
    /// refinement — no plan in an empty slot).
    public func createLibrary(passphrase: String? = nil, words: [String]? = nil) throws -> UnlockedLibrary {
        let key = leaves.ids.mintLibraryKey()
        let libraryID = leaves.ids.mintID()
        let deviceID = leaves.ids.mintID()
        let at = now()
        configuration.libraryID = libraryID
        var record = ProtectionRecord.minting(
            libraryID: libraryID, mode: .standard, modeConfirmed: true, account: nil,
            currentFingerprint: Self.fp(key), madeBy: deviceID, at: at)
        let apple = leaves.ids.mintAppleKey()
        let section = DeviceSection(
            deviceID: deviceID, hardwareMarker: record.marker(for: configuration.machine), settings: .noChoiceYet)
            .recordingAppleKey(AppleKeyRecord(id: apple.id, purpose: .library, origin: .minted))
        record = try record.storing(section, sealedUnder: key)
        try leaves.custody.writeCustody(key, itemClass: .silent)
        try leaves.apple.addAppleKey(apple)
        let locks = NewKeyLocks(
            passphrase: try passphrase.map { try freshPassphrase($0) }, words: try words.map { try WordsKey.derive($0) },
            apple: apple)
        let file = try KeyFile.building(libraryID: libraryID, key: key, epoch: 1, locks: locks)
        try leaves.keyFiles.writeLiveKeyFile(file)
        try leaves.library.createLibrary(with: key, record: record)
        var library = UnlockedLibrary(
            key: key, record: record, section: section, resolution: .newIdentity(predecessorID: nil), memory: nil,
            keyFile: file, familyTree: record.familyTree)
        try writeMemory(&library)
        log("create library: \(Self.fp8(Self.fp(key))) in Standard")
        return library
    }
}
