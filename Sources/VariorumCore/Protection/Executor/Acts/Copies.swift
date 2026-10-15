import CryptoKit
import Foundation

// VX-305 U3 — COPIES (design §3.7; OpenRule's verdicts are U2's). One file for
// the copy acts (a recorded refinement of §2's one-file-per-act: they share
// the staged-copy road).
//   - OPENING A COPY of the library in the slot (its own line by the family
//     tree): the copy re-encrypted under the library's CURRENT key straight
//     from the staged copy into place, taking the library's current facts —
//     its mode, account and family tree from the record, this Mac's facts from
//     the newer home — so a restored copy can't weaken delete on sight, can't
//     lower the mode, and carries no act in flight (the copy's record never
//     becomes the library's). The current key is never the copy's.
//   - LANDING A DIFFERENT LIBRARY: a FRESH key with an EMPTY history (no key
//     held by two Macs); one secret unlocked the pair, the other typed or made
//     new — or none, for a Standard pair through an Apple key this Mac can
//     read; this Mac's own Apple key in Standard; the pair never written; the
//     library that was here goes to the older libraries; a synced pair lands
//     held, a secret made new at its landing becoming the account's at Resume
//     Sync (the account's own forgot road — `Sync/`, phase 3/5).
//   - SEND LIBRARY writes the pair, with no sharing note.
//   - A PLAINTEXT EXPORT carries its library ID.
//   - THE OFFER deletes another library's copies at her press — this Mac's
//     copies of it only, never another Mac's; deleting the last copy this Mac
//     holds of a library deletes its key file and its Apple key too.

struct OpenCopyProgram: ActProgram {
    let act = ProtectionAct.openCopy

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        ["stageCopy", "recordIntoStaged", "swap", "memory"]
    }

    /// With no plan the swap is the act: a staged copy left behind is
    /// discarded (the open never happened), or the swapped one remembered.
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { ["discardStaged", "memory"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        switch step {
        case "stageCopy":
            ctx.leaves.backups.pauseCopies()
            // A resume after a relaunch no longer holds the copy's key: the
            // open never happened — it rolls back, and she opens it again.
            guard let copyID = ctx.parameters.copyID, let opener = ctx.copyOpener else {
                throw ActRollback(refusal: .secretsRequired(ctx.act))
            }
            try ctx.leaves.library.stageCopy(copyID: copyID, opener: opener, to: ctx.library.key)
        case "recordIntoStaged":
            let record = try ctx.requireRecord()
            var next = record
            if !ctx.executor.guards.copyActClearedOnOpenOn, let carried = ctx.copyRecord {
                // Guard off (DEBUG mutation pins only): the copy's own record —
                // its act in flight with it — becomes the library's.
                next = carried
            } else {
                // The library's CURRENT facts; this Mac's section from the newer
                // home; every other section that verifies; no act carried.
                let reach = ctx.executor.reach(key: ctx.library.key, keyFile: ctx.library.keyFile)
                let others = record.verifiedSections(reach: reach).filter { $0.deviceID != ctx.deviceID }
                next.deviceSections = try (others + [ctx.library.section]).map {
                    try Sealed.sealing($0, purpose: .deviceSection, libraryID: record.libraryID, key: ctx.library.key)
                }
            }
            try ctx.leaves.library.writeStagedRecord(next, with: ctx.library.key)
        case "swap":
            if try ctx.leaves.library.stagedFingerprint() != nil {
                try ctx.leaves.library.swapStaged(setAside: true)
            }
            ctx.library.record = try ctx.leaves.library.readRecord(with: ctx.library.key)
            if let record = ctx.library.record {
                ctx.library.familyTree = ctx.library.familyTree.union(record.familyTree)
                let reach = ctx.executor.reach(key: ctx.library.key, keyFile: ctx.library.keyFile)
                if let mine = record.verifiedSections(reach: reach).first(where: { $0.deviceID == ctx.deviceID }) {
                    ctx.library.section = mine
                }
            }
            ctx.leaves.backups.resumeCopies()
        case "discardStaged": try ctx.leaves.library.discardStaged()
        case "memory": try ctx.rememberNewKey()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

/// A different library's pair, as the landing takes it.
public struct LandingPair: Sendable {
    /// The pair's snapshot, by its catalog id.
    public var copyID: String
    /// Its frozen key file (never written).
    public var keyFile: KeyFileDocument
    /// Its record, when it carries one (read after its pair opens); nil for a
    /// copy from before this change — its mode is today's rule's.
    public var record: ProtectionRecord?

    public init(copyID: String, keyFile: KeyFileDocument, record: ProtectionRecord?) {
        self.copyID = copyID
        self.keyFile = keyFile
        self.record = record
    }
}

struct LandProgram: ActProgram {
    let act = ProtectionAct.land

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        // A synced pair lands HELD: nothing Apple-reachable until Resume Sync
        // reads its account's vault (decision 35) — no own Apple key at the
        // landing (asking for that read mid-act stuck the landing in flight —
        // VX-305 U4, found by the scenario world).
        ["stageCopy", "custodyItem"] + (parameters.newKind == .standard && parameters.synced != true ? ["mintOwnAppleKey"] : [])
            + ["keyFile", "recordIntoStaged", "swap", "memory"]
    }

    func newKeySteps(_ parameters: ActParameters) -> Set<String> { ["stageCopy", "custodyItem", "keyFile", "recordIntoStaged", "swap"] }
    func finishingSteps(_ library: UnlockedLibrary) -> [String] { ["memory"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        let kind = ctx.parameters.newKind ?? .castle
        switch step {
        case "stageCopy":
            ctx.leaves.backups.pauseCopies()
            guard let copyID = ctx.parameters.copyID, let opener = ctx.copyOpener else {
                throw ActRollback(refusal: .secretsRequired(ctx.act))
            }
            if try ctx.leaves.library.stagedFingerprint() == ActContext.fp(try ctx.requireToKey()) { return }
            try ctx.leaves.library.stageCopy(copyID: copyID, opener: opener, to: try ctx.requireToKey())
        case "custodyItem": try ctx.newCustodyItem(kind: kind)
        case "mintOwnAppleKey":
            // This Mac's own key for the LANDED library — recorded in its new
            // section, never the outgoing library's.
            let key = try ctx.mintAppleKey(purpose: .library, recordedInThisSection: false)
            if var landing = ctx.executor.landingInHand, !landing.section.appleKeys.contains(where: { $0.id == key.id }) {
                landing.section = landing.section.recordingAppleKey(AppleKeyRecord(id: key.id, purpose: .library, origin: .minted))
                ctx.executor.landingInHand = landing
            }
        case "keyFile":
            let key = try ctx.requireToKey()
            if ctx.library.keyFile?.fingerprint == ActContext.fp(key) { return }
            guard let landing = ctx.landingRecord else { throw ActRollback(refusal: .secretsRequired(ctx.act)) }
            let apple = kind == .standard && ctx.parameters.synced != true ? try ctx.ownAppleKey() : nil
            let locks = NewKeyLocks(passphrase: ctx.secrets.passphrase, words: ctx.secrets.words, apple: apple)
            try ctx.executor.writeLiveKeyFile(
                try KeyFile.building(libraryID: landing.libraryID, key: key, epoch: 1, locks: locks), &ctx.library)
        case "recordIntoStaged":
            let key = try ctx.requireToKey()
            guard var landing = ctx.landingRecord else { throw ActRollback(refusal: .secretsRequired(ctx.act)) }
            landing = try landing.storing(ctx.landingSection ?? ctx.library.section, sealedUnder: key)
            try ctx.leaves.library.writeStagedRecord(landing, with: key)
        case "swap":
            let key = try ctx.requireToKey()
            if !(try ctx.libraryOpens(key)) { try ctx.leaves.library.swapStaged(setAside: true) }
            // The slot holds the landed library now: this executor serves it.
            guard let record = try ctx.leaves.library.readRecord(with: key) else { throw ExecutorRefusal.recordMissing }
            ctx.executor.configuration.libraryID = record.libraryID
            // This Mac's section for the LANDED library: the press's, in hand —
            // or, on a resume (the press's memory went with the crash), the one
            // the swapped-in record carries naming this landing, where the
            // press wrote it. Never the outgoing library's (it carried another
            // identity's keys into the landed library — VX-305 U4, the soak's
            // seed 1).
            let landedSection = ctx.landingSection ?? record.verifiedSections(reach: { $0 == ActContext.fp(key) ? key : nil })
                .first { $0.actInFlight?.act == .land && $0.actInFlight?.toFingerprint == ActContext.fp(key) }
            ctx.library = UnlockedLibrary(
                key: key, record: record, section: landedSection ?? ctx.library.section,
                resolution: .newIdentity(predecessorID: nil), memory: nil, keyFile: try ctx.executor.liveFormat3(),
                familyTree: record.familyTree)
            // The plan stays the one the landed library's section names.
            ctx.plan.libraryID = record.libraryID
            if let inFlight = ctx.library.section.actInFlight {
                ctx.plan.sequence = inFlight.sequence
                ctx.plan.deviceID = ctx.library.section.deviceID
                ctx.plan.fromFingerprint = inFlight.fromFingerprint
            }
            ctx.leaves.backups.resumeCopies()
        case "memory":
            try ctx.rememberNewKey()
            if ctx.parameters.synced == true, ctx.parameters.passphraseIsNew == true || ctx.parameters.wordsAreNew == true {
                ctx.outcome.notices.append(.madeNewSecretBecomesAccountsAtResumeSync)
            }
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

struct SendLibraryProgram: ActProgram {
    let act = ProtectionAct.sendLibrary
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { ["writePair"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        guard let destination = ctx.parameters.destination, let live = ctx.library.keyFile,
              live.fingerprint == ctx.library.fingerprint else { throw ExecutorRefusal.noLiveKeyFile }
        try ctx.leaves.backups.writeSendPair(with: ctx.library.key, keyFile: live, to: destination)
    }
}

struct PlaintextExportProgram: ActProgram {
    let act = ProtectionAct.plaintextExport
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { ["export"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        guard let destination = ctx.parameters.destination else { throw ExecutorRefusal.nothingToDo }
        try ctx.leaves.library.exportPlaintext(with: ctx.library.key, to: destination)
    }
}

struct OfferDeleteProgram: ActProgram {
    let act = ProtectionAct.offerDelete
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { ["deleteCopies", "lastCopyKeys"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        switch step {
        case "deleteCopies":
            if let ids = ctx.parameters.copyIDs, !ids.isEmpty { try ctx.leaves.backups.deleteCopies(ids: ids) }
        case "lastCopyKeys":
            // The last copy this Mac held of a library: its own key file's
            // Apple key goes too (the key file goes with the folder).
            for library in ctx.parameters.keyFileIDs ?? [] {
                if let own = try ctx.leaves.keyFiles.readOwnKeyFile(libraryID: library, deviceID: ctx.deviceID),
                   let id = own.apple?.keyID {
                    try ctx.leaves.apple.deleteAppleKey(id: id)
                }
            }
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

extension ActContext {
    /// The copy's own key, in hand for the act's span (never stored).
    var copyOpener: StoreKey? {
        get { executor.copyOpenerInHand }
        set { executor.copyOpenerInHand = newValue }
    }

    /// The landing's new record and this Mac's new section for it, built at
    /// the press (non-secret, held for the act's span).
    var landingRecord: ProtectionRecord? { executor.landingInHand?.record }
    var landingSection: DeviceSection? { executor.landingInHand?.section }

    /// The copy's own record (the guard-off reading only).
    var copyRecord: ProtectionRecord? { executor.copyRecordInHand }
}

extension ProtectionExecutor {
    /// **Open a copy of this library** (OpenRule's `.ownLine`): `opener` is
    /// the copy's own key, reached by its roads (its pair's file, the
    /// history, the anchor — the route finder's); `copyRecord` its record.
    public func openCopy(
        _ library: inout UnlockedLibrary, copyID: String, opener: StoreKey, copyRecord: ProtectionRecord?
    ) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.migrationOwed }
        if let copyRecord, copyRecord.libraryID != record.libraryID { throw ExecutorRefusal.wrongLibrary }
        copyOpenerInHand = opener
        copyRecordInHand = copyRecord
        defer { copyOpenerInHand = nil; copyRecordInHand = nil }
        return try await perform(
            OpenCopyProgram(), parameters: ActParameters(copyID: copyID), secrets: ActSecrets(), library: &library)
    }

    /// **Land a different library** in the slot, replacing the one here (it
    /// goes to the older libraries). `opener`: the pair's key, opened by ONE
    /// of its secrets (or, Standard, an Apple key readable here); `typed`: the
    /// secret that opened it and the other — typed, or made new — or neither
    /// for a Standard pair through a readable Apple key; `gate`: a Castle
    /// landing's press (Touch ID where a finger is enrolled, else Always ask).
    public func land(
        _ library: inout UnlockedLibrary, pair: LandingPair, opener: StoreKey, typed: TypedSecrets, gate: GateStyle? = nil
    ) async throws -> ActOutcome {
        guard library.record != nil else { throw ExecutorRefusal.migrationOwed }
        let landedID = pair.keyFile.libraryID
        guard landedID != library.record?.libraryID else { throw ExecutorRefusal.wrongLibrary }
        // The pair's own mode: its record's, else today's rule read once.
        let mode: ProtectionMode
        if let record = pair.record {
            mode = record.mode
        } else {
            var facts: LegacyKeyFileFacts?
            if case .legacy(let legacy) = pair.keyFile { facts = LegacyKeyFileFacts(legacy.envelope) }
            if case .format3(let file) = pair.keyFile {
                facts = LegacyKeyFileFacts(hasAppleWrap: file.apple != nil || file.sharedApple != nil, hasPassphraseWrap: file.passphrase != nil)
            }
            mode = OpenFacts(libraryID: landedID, keyFingerprint: nil, keyFileFacts: facts, target: nil).copyMode
        }
        // The secrets: what opened the pair, and the other — typed (verified
        // against the pair) or made new. A Standard pair through a readable
        // Apple key may land with neither.
        var secrets = ActSecrets()
        var parameters = ActParameters(
            synced: pair.record?.account != nil, accountID: pair.record?.account, newKind: mode, copyID: pair.copyID)
        if let text = typed.passphrase {
            if case .format3(let file) = pair.keyFile, let wrap = file.passphrase,
               let key = try? PassphraseKey.derive(text, kdf: wrap.kdf),
               (try? file.open(passphrase: .passphraseKey(key), floor: configuration.floor)) != nil {
                secrets.passphrase = key
            } else if case .legacy(let legacy) = pair.keyFile, let wrap = legacy.envelope.passphrase,
                      (try? legacy.open(passphrase: text, floor: configuration.floor)) != nil {
                try wrap.kdf.validateFloor(configuration.floor)
                secrets.passphrase = try PassphraseKey.derive(text, kdf: wrap.kdf)
            } else {
                throw ExecutorRefusal.passphraseDoesNotOpen
            }
        } else if let fresh = typed.newPassphrase {
            secrets.passphrase = try freshPassphrase(fresh)
            parameters.passphraseIsNew = true
        }
        if let words = typed.words {
            if !typed.wordsAreNew {
                let opens: Bool
                switch pair.keyFile {
                case .format3(let file): opens = (try? file.open(.words(words), floor: configuration.floor)) != nil
                case .legacy(let legacy): opens = (try? legacy.open(words: words)) != nil
                }
                guard opens else { throw ExecutorRefusal.wordsDoNotOpen }
            }
            secrets.words = try WordsKey.derive(words)
            parameters.wordsAreNew = typed.wordsAreNew
        }
        if mode == .castle, secrets.passphrase == nil || secrets.words == nil { throw ExecutorRefusal.secretMissing }
        if mode == .standard, secrets.isEmpty, pair.record?.account != nil { throw ExecutorRefusal.secretMissing }
        parameters.passphraseKDF = secrets.passphrase?.kdf
        // A FRESH key with an EMPTY history (her round-2 ruling) — the guard's
        // off-reading keeps the key it came with (today's behaviour).
        let newKey = guards.rekeyAtEveryCrossingOn ? leaves.ids.mintLibraryKey() : opener
        let at = now()
        var record = pair.record ?? ProtectionRecord.minting(
            libraryID: landedID, mode: mode, modeConfirmed: true, account: nil,
            currentFingerprint: Self.fp(opener), madeBy: nil, at: at)
        record.familyTree = record.familyTree.seeding([Self.fp(opener)], kind: mode, reached: true)
        record = record.recordingRekey(to: Self.fp(newKey), kind: mode, by: library.section.deviceID, at: at)
        // This Mac starts a NEW identity for the landed library (it never
        // held it) — its gate decided at this press; other Macs' sections
        // stay theirs, re-sealed only where they verify.
        let reachPair = reach(key: opener, keyFile: nil)
        let others = (pair.record?.verifiedSections(reach: reachPair) ?? [])
        record.deviceSections = []
        let chosen = mode == .castle ? (gate ?? (leaves.biometry.biometry().enrolled ? .touchID : .alwaysAsk)) : nil
        parameters.gate = chosen
        var section = DeviceSection(
            deviceID: leaves.ids.mintID(), hardwareMarker: record.marker(for: configuration.machine),
            settings: DeviceSettings(gateStyle: chosen))
        for other in others { record = try record.storing(other.clearingActInFlight(), sealedUnder: newKey) }
        // The landing is named in BOTH libraries: the outgoing one's section
        // (a crash before the swap rolls it back there) and the landed one's
        // (a crash after finishes it there).
        section = section.beginningAct(.land, from: Self.fp(opener), to: Self.fp(newKey), at: at).section
        landingInHand = (record, section)
        copyOpenerInHand = opener
        defer { landingInHand = nil; copyOpenerInHand = nil }
        return try await perform(
            LandProgram(), parameters: parameters, secrets: secrets, typed: typed, toKey: newKey, library: &library)
    }

    /// **Send Library**: the pair, written to the folder she picked — no
    /// sharing note (the other Mac lands it under a key of its own).
    public func sendLibrary(_ library: inout UnlockedLibrary, to destination: String) async throws -> ActOutcome {
        try await perform(SendLibraryProgram(), parameters: ActParameters(destination: destination), secrets: ActSecrets(), library: &library)
    }

    /// **A plaintext export** — re-authenticated: in Castle the passphrase
    /// (never Touch ID alone); in Standard the passphrase if set.
    public func plaintextExport(_ library: inout UnlockedLibrary, typed: TypedSecrets, to destination: String) async throws -> ActOutcome {
        if library.record?.mode == .castle || library.keyFile?.passphrase != nil {
            _ = try verifiedPassphrase(typed.passphrase, against: library.keyFile)
        }
        return try await perform(
            PlaintextExportProgram(), parameters: ActParameters(destination: destination), secrets: ActSecrets(), library: &library)
    }

    /// **The offer's delete** — another library's copies, at her press: this
    /// Mac's copies of it only (never another Mac's, never this library's);
    /// the last copy of a library takes its key file's Apple key with it.
    public func offerDelete(_ library: inout UnlockedLibrary, copies: [CatalogCopy], catalog: Catalog) async throws -> ActOutcome {
        let thisLibrary = library.record?.libraryID
        let mine = library.section.mac8
        let deletable = copies.filter { $0.library != nil && $0.library != thisLibrary && $0.mac.isMac(mine) }
        let ids = Set(deletable.map(\.id))
        var emptied: [String] = []
        for other in Set(deletable.compactMap(\.library)) {
            let remaining = catalog.copies(ofLibrary: other).filter { $0.mac.isMac(mine) && !ids.contains($0.id) }
            if remaining.isEmpty { emptied.append(other) }
        }
        return try await perform(
            OfferDeleteProgram(), parameters: ActParameters(copyIDs: ids.sorted(), keyFileIDs: emptied.sorted()),
            secrets: ActSecrets(), library: &library)
    }
}
