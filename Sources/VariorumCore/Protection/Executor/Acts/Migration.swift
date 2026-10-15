import CryptoKit
import Foundation

// VX-305 U3 — THE MIGRATION (design §3.13): once, at first unlock on the new
// build, AS A PLAN (on a Release build only once she has turned the new
// system on — phase 2's wiring). U2's `assess` owes it (`OwedAct.migrate`) to a
// library with no record; until it runs, nothing else does.
//   1. Today's stuck marker (`RotationMarker`) resolved from disk — the act
//      never happened, or its commit happened — and cleared either way (the
//      runner's finish path is phase 2's; past its release this is the road).
//   2. The mode worked out ONCE with today's rules (`LegacyModeReader`): a
//      synced library with the vault in reach takes the vault's word; without
//      it, not yet confirmed; corner 45's ambiguous case Castle, not yet
//      confirmed. Until confirmed no custody repair runs and nothing
//      Apple-reachable is written.
//   3. The record, what this Mac remembers (this Mac's section in both homes)
//      and the device identity CARRIED OVER from today's sync custody item,
//      with its hardware marker — the family tree's first entries: the current
//      key in the recorded mode, every key the fold reaches attributed by its
//      key file (an Apple wrap — Standard; none — Castle; unknown — Castle),
//      every fingerprint the catalog's key files name, reached or not.
//   4. The per-key custody items, each of its key's kind — only once the mode
//      is confirmed (today's items stay, unread, for one release).
//   5. The format-3 key file, folding every reachable older key into the
//      history: today's key files through the old shared key or the passphrase
//      typed once, today's per-library-ID items, the 13p escrow items. Old key
//      files stay; the escrow items for keys now in the history go.
//   6. Keys of this Mac's own beside the old shared one (the move — other
//      libraries first, then the live library once confirmed Standard), then a
//      fresh backup pair.

/// What the migration starts from — today's facts, gathered by phase 2's leaves.
public struct MigrationInputs: Sendable {
    /// `Posture.derive`'s inputs (the vault's word in them when read).
    public var legacyMode: LegacyModeInputs
    /// The account today's library is enrolled in (nil: local only).
    public var account: String?
    /// Today's device identity, from the sync custody item (kept — no new cursor).
    public var carriedDeviceID: String?
    /// This Mac's settings today (UserDefaults, retired there by §3.15).
    public var settings: DeviceSettings
    /// Every fingerprint the catalog's key files name for this library.
    public var catalogFingerprints: [String]
    /// Other libraries' serving key files (catalog ids) the move gifts — assess's MovePlan.
    public var moveSubjects: [String]

    public init(
        legacyMode: LegacyModeInputs, account: String? = nil, carriedDeviceID: String? = nil,
        settings: DeviceSettings = .noChoiceYet, catalogFingerprints: [String] = [], moveSubjects: [String] = []
    ) {
        self.legacyMode = legacyMode
        self.account = account
        self.carriedDeviceID = carriedDeviceID
        self.settings = settings
        self.catalogFingerprints = catalogFingerprints
        self.moveSubjects = moveSubjects
    }
}

struct MigrationProgram: ActProgram {
    let act = ProtectionAct.migration
    static let all = ["clearOldMarker", "custodyItems", "keyFile", "removeEscrow", "moves", "memory", "backup"]

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { Self.all }
    /// With no plan, the record already written: every step again from the
    /// disk (the typed passphrase's fold the only thing a resume can't redo).
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { Self.all }

    func run(_ step: String, _ ctx: ActContext) async throws {
        let record = try ctx.requireRecord()
        let key = ctx.library.key
        switch step {
        case "clearOldMarker":
            guard let marker = try ctx.leaves.library.readLegacyRotationMarker(with: key) else { return }
            let landed = try ctx.leaves.keyFiles.legacyKeyFilesBesideLibrary()
                .contains { $0.file.fingerprint == marker.newKeyFingerprint }
            let resolution = marker.resolve(.init(opensUnder: ctx.library.fingerprint, newKeyFileLanded: landed))
            ctx.log("today's marker: \(resolution == .neverHappened ? "the act never happened" : "its commit happened") — cleared")
            try ctx.leaves.library.clearLegacyRotationMarker(with: key)
        case "custodyItems": try ctx.addPerKeyCustodyItems()
        case "keyFile": try ctx.migrateKeyFile()
        case "removeEscrow":
            guard let live = ctx.library.keyFile, live.fingerprint == ctx.library.fingerprint else { return }
            let held = Set(live.history.map(\.fingerprint)).union([live.fingerprint])
            for item in try ctx.leaves.legacyItems.legacyItems() {
                guard case .escrow = item.kind, let fingerprint = item.fingerprint, held.contains(fingerprint) else { continue }
                if fingerprint != live.fingerprint,
                   (try? live.historyKey(fingerprint, currentKey: key)) == nil { continue }
                try ctx.leaves.legacyItems.deleteLegacyItem(item.kind)
            }
        case "moves":
            // Decision 35: a synced library's own Apple key only on a fresh vault read.
            if record.mode == .standard, let account = record.account, !ctx.executor.readThisSession(account) { return }
            try await ctx.executor.moveOffSharedKey(ctx, freshPair: false)
        case "memory":
            try ctx.rememberNewKey()
            // What this Mac remembers of the vault is what today's key file was
            // last reconciled against — never the vault as read now: a vault
            // that moved before the migration is a follow owed (VX-305 U4).
            if let today = try ctx.leaves.keyFiles.legacyKeyFilesBesideLibrary()
                .first(where: { $0.file.fingerprint == ctx.library.fingerprint })?.file.envelope,
               today.vaultCorpusKeyID != nil {
                try ctx.executor.writeMemory(&ctx.library) {
                    $0.vaultFacts = VaultFacts(kdf: today.vaultKDF, corpusKeyID: today.vaultCorpusKeyID,
                                               recoveryWrapDigest: today.vaultRecoveryWrapDigest)
                }
            }
        case "backup":
            // The fresh pair — the move's, and the migration's last (with the
            // guard off, the move's pair is not taken).
            if ctx.executor.guards.freshPairAfterMoveOn { try ctx.freshBackup() }
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

extension ActContext {
    /// §3.13 step 4: the per-key custody items, each of its key's kind — only
    /// once the mode is confirmed (an unconfirmed mode keeps today's custody
    /// shape). Run by the migration, and by the confirmation that comes later
    /// (VX-305 U4).
    func addPerKeyCustodyItems() throws {
        let record = try requireRecord()
        let key = library.key
        guard record.modeConfirmed else { return }
        let items = try leaves.custody.custodyItems()
        switch record.mode {
        case .standard:
            if !items.contains(CustodyItemFact(fingerprint: library.fingerprint, itemClass: .silent)) {
                try leaves.custody.writeCustody(key, itemClass: .silent)
            }
        case .castle:
            // A Touch ID item where today's gated item stood (the choice
            // she made then); none under Always ask.
            let gated = try leaves.legacyItems.legacyItems().contains { if case .gated = $0.kind { return true } else { return false } }
            if gated, library.section.settings.gateStyle == .touchID,
               !items.contains(CustodyItemFact(fingerprint: library.fingerprint, itemClass: .touchid)) {
                try leaves.custody.writeCustody(key, itemClass: .touchid)
            }
        }
    }
}

extension ActContext {
    /// THE FORMAT-3 KEY FILE, folding every reachable older key (§3.13 step 6).
    func migrateKeyFile() throws {
        let key = library.key
        let current = library.fingerprint
        if let live = library.keyFile, live.fingerprint == current { return }
        let beside = try leaves.keyFiles.legacyKeyFilesBesideLibrary()
        guard let today = beside.first(where: { $0.file.fingerprint == current })?.file else {
            throw ExecutorRefusal.noLiveKeyFile
        }
        let envelope = today.envelope
        var file = KeyFile(libraryID: envelope.storeID, key: key, epoch: 1)
        file.passphrase = envelope.passphrase
        file.words = envelope.recovery
        file.master = envelope.master
        // §3.5a: the master's words copy is the recovery wrap of the master
        // THIS file's master wrap is under — copied only while the vault's
        // master is still that one (the vault's corpus key id is the one the
        // file was last reconciled against: a rotation changes it). VX-305 U4.
        if envelope.master != nil, let account = accountID, let vault = executor.freshVaults[account],
           envelope.vaultCorpusKeyID == vault.corpusKeyID {
            file.masterWordsCopy = vault.format.masterWrappedByRecovery
        }
        // Today's Apple wrap is the OLD SHARED key's: it rides beside.
        if let apple = envelope.apple { file.sharedApple = AppleWrap(keyID: envelope.appleKeyID ?? "", wrapped: apple) }
        // The fold: every older key reachable — today's key files through the
        // old shared key or the passphrase typed once, today's items, the
        // escrow items — each verified by its fingerprint.
        var folded: [(key: StoreKey, kind: ProtectionMode)] = []
        let shared = try leaves.apple.readOldSharedAppleKey()
        for (_, legacy) in beside where legacy.fingerprint != current {
            var opened: StoreKey?
            if let shared { opened = try? legacy.open(sharedApple: shared) }
            if opened == nil, let typed = typedPassphrase { opened = try? legacy.open(passphrase: typed, floor: floor) }
            if let opened { folded.append((opened, legacy.attributedKind)) }
        }
        for item in try leaves.legacyItems.legacyItems() {
            switch item.kind {
            case .silent, .escrow:
                if let held = try leaves.legacyItems.readLegacyItem(item.kind), Self.fp(held) != current {
                    folded.append((held, .castle))
                }
            case .gated, .syncCustody:
                continue
            }
        }
        var seen: Set<String> = [current]
        for (older, _) in folded where seen.insert(Self.fp(older)).inserted {
            file.history.append(HistoryEntry(
                fingerprint: Self.fp(older), epoch: 0, retiredAt: now,
                wrapped: try Lock.wrap(older.data, under: SymmetricKey(data: key.data))))
        }
        try executor.writeLiveKeyFile(file, &library)
        // The family tree learns every key the fold reached, by its kind.
        var tree = library.familyTree
        for (older, kind) in folded { tree = tree.seeding([Self.fp(older)], kind: kind, reached: true) }
        library.familyTree = tree
        if var record = library.record {
            record.familyTree = record.familyTree.union(tree)
            try leaves.library.writeRecord(record, with: key)
            library.record = record
        }
    }
}

extension ProtectionExecutor {
    /// **The migration** — `library`: the store as unlocked with today's key
    /// (no record yet); `typed`: the passphrase, typed once when the fold
    /// needs it.
    public func migrate(
        _ library: inout UnlockedLibrary, inputs: MigrationInputs, typed: TypedSecrets = .none
    ) async throws -> ActOutcome {
        guard library.record == nil else { throw ExecutorRefusal.nothingToDo }
        let verdict = LegacyModeReader.read(inputs.legacyMode)
        var (mode, confirmed) = verdict.migrationRecord
        // §3.13 step 1: "a vault that moved while the library didn't is an
        // ordinary follow". The vault's word is the ACCOUNT's mode; when this
        // library's own custody shape says, unambiguously, that its key was
        // born the other kind, the library is recorded by its key's kind and
        // the follow (a key change) is owed — today's silent follow, which
        // would make a Castle-born key Standard with no key change, is gone
        // (§3.15). PROVISIONAL P-U4-4 (VX-305 U4, found by the scenario world).
        // Unambiguous = the custody AND the key file agree (a silent item with
        // an Apple wrap is Standard-born; no silent item and no Apple wrap, a
        // passphrase lock, Castle-born). A lone shape is no evidence: a wiped
        // keychain leaves a Standard key with no silent item (the scenario
        // world's second finding here).
        if case .vault = verdict.source, inputs.legacyMode.rawKeyCustody != .unknown {
            let shape = LegacyModeReader.shapeReading(inputs.legacyMode.keyFile, inputs.legacyMode.rawKeyCustody)
            let fileSays: ProtectionMode? = inputs.legacyMode.keyFile.flatMap {
                $0.hasAppleWrap ? .standard : ($0.hasPassphraseWrap ? .castle : nil)
            }
            if shape != mode, fileSays == shape {
                mode = shape
                confirmed = true
            }
        }
        let at = now()
        let deviceID = inputs.carriedDeviceID ?? leaves.ids.mintID()
        var record = ProtectionRecord.minting(
            libraryID: libraryID, mode: mode, modeConfirmed: confirmed, account: inputs.account,
            currentFingerprint: library.fingerprint, madeBy: nil, at: at)
        record.familyTree = record.familyTree.seeding(inputs.catalogFingerprints.filter { $0 != library.fingerprint })
        var settings = inputs.settings
        if mode == .standard { settings.gateStyle = nil }
        var section = DeviceSection(
            deviceID: deviceID, hardwareMarker: record.marker(for: configuration.machine), settings: settings)
        // The old shared key, as this device's section first lists it: every
        // key file of this library that carries its wrap names its id.
        if let shared = try leaves.apple.readOldSharedAppleKey() {
            section.oldSharedKey = OldSharedKeyRecord(id: shared.id)
        } else if let named = try leaves.keyFiles.legacyKeyFilesBesideLibrary()
            .compactMap({ $0.file.envelope.apple != nil ? $0.file.envelope.appleKeyID : nil }).first {
            section.oldSharedKey = OldSharedKeyRecord(id: named)
        }
        // The account's Apple key, as this device last knew its vault (the
        // vault read now, else the key today's file was reconciled under — one
        // Apple-held copy per account, today): recorded as followed, so a
        // later act signed out knows the account still stands on it (§3.5
        // point 4's door; P-U2-4). VX-305 U4, found by the scenario world.
        if let account = inputs.account {
            let read = freshVaults[account].flatMap { $0.format.masterWrappedByAppleHeld != nil ? $0.format.appleKeyID : nil }
            let today = try leaves.keyFiles.legacyKeyFilesBesideLibrary()
                .first { $0.file.fingerprint == library.fingerprint }
                .flatMap { $0.file.envelope.master != nil && $0.file.envelope.apple != nil ? $0.file.envelope.appleKeyID : nil }
            if let id = read ?? today {
                section = section.recordingAppleKey(AppleKeyRecord(id: id, purpose: .account, accountID: account, origin: .followed))
            }
        }
        library.record = record
        library.section = section
        library.familyTree = record.familyTree
        library.resolution = inputs.carriedDeviceID == nil ? .newIdentity(predecessorID: nil) : .continuing(deviceID: deviceID)
        var parameters = ActParameters(synced: inputs.account != nil, accountID: inputs.account, keyFileIDs: inputs.moveSubjects)
        parameters.passphraseKDF = nil
        return try await perform(
            MigrationProgram(), parameters: parameters, secrets: ActSecrets(), typed: typed, library: &library)
    }
}
