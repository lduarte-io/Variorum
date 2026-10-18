import CryptoKit
import Foundation

// VX-305 U3 — COPIES (design §3.7). One file for the copy acts (a recorded
// refinement of §2's one-file-per-act).
//   - A COPY IS A COPY (rule 17, `notes/CastleRules.md`), VX-378 U2:
//     LOOK INSIDE opens any copy read-only — with its own secrets, the current
//     secrets through the live key file's history (rule 4), or its own quiet
//     road on this Mac — and WRITES NOTHING: no key file, no keychain item, no
//     change to the library. MAKE THIS MY LIBRARY is one act: the copy takes the
//     live place as a NEW library — a fresh identity, key and device ID (rule
//     23) in the posture this device is in now, under its current pair — and the
//     outgoing library steps aside whole, with its own key file, into Previous
//     Libraries. You never leave Castle by opening something.
//   - SEND LIBRARY writes the pair — a copy (rule 18), with no sharing note.
//   - A PLAINTEXT EXPORT carries its library ID.
//   - THE OFFER deletes another library's copies at her press — this Mac's
//     copies of it only, never another Mac's (rule 19).

/// What Look inside opened (rule 17) — a copy, read-only. The key is held for
/// the look and never stored; closing the copy forgets it.
public struct LookedInside: CustomStringConvertible {
    /// The copy's catalog id.
    public let copyID: String
    /// The key that opens it.
    public let key: StoreKey
    /// The road that opened it.
    public let road: CopyRoad

    public var description: String { "LookedInside(\(copyID), \(road), redacted)" }
}

/// The road a copy opened by (rule 17: its own secrets, or its own quiet road
/// on this Mac; rule 4: the current secrets through the history).
public enum CopyRoad: Equatable, Sendable {
    /// A secret typed, on the copy's own key file.
    case itsOwnSecrets
    /// The current passphrase or words, through the live key file's history.
    case currentSecretsThroughTheHistory
    /// A quiet road this Mac holds to the copy's key.
    case quietRoad(QuietRoad)
}

/// MAKE THIS MY LIBRARY (rule 17). On a plan (rule 20): the new key's custody
/// item; Standard, a fresh own Apple key; the NEW library's key file (no past —
/// a fresh key, under the current pair) in the live place, the outgoing one held
/// by the plan and the mirror; the copy re-encrypted under the new key into the
/// staged file; the new record (a fresh library ID, the posture of now, this
/// device's new section carrying the act) into it; the new library's memory
/// item; THE SWAP, the outgoing library and its key file set aside whole (the
/// plan re-sealed for the new library first, so a crash on either side resumes
/// or rolls back); then the outgoing library's memory item forgotten (rule 21:
/// one library) and a fresh pair. Before the swap a resume holds no copy key and
/// rolls back (a plan never holds one — the old landing's P-U3-6).
struct MakeMineProgram: ActProgram {
    let act = ProtectionAct.makeMine
    static let afterCommit = ["forgetOtherLibraries", "backup"]
    /// The steps up to the copy's stage — the ones a resume can't finish
    /// without the copy's key.
    static let beforeTheStage: Set<String> = ["custodyItem", "mintOwnAppleKey", "keyFile", "stage"]

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        var steps = ["custodyItem"]
        if parameters.newKind == .standard { steps.append("mintOwnAppleKey") }
        return steps + ["keyFile", "stage", "recordIntoStaged", "newMemory", "swap"] + Self.afterCommit
    }

    func newKeySteps(_ parameters: ActParameters) -> Set<String> {
        ["custodyItem", "keyFile", "stage", "recordIntoStaged", "newMemory", "swap"]
    }

    func finishingSteps(_ library: UnlockedLibrary) -> [String] { Self.afterCommit }

    func run(_ step: String, _ ctx: ActContext) async throws {
        let kind = try ctx.parameters.newKind ?? ctx.requireRecord().mode
        // A resume holds no copy key (a plan never holds one): before the copy
        // is staged under the new key, it can't finish — roll back at once,
        // before any step that would write or need its account's vault
        // (census class (G), VX-378 U4: the own Apple key's fresh-vault check
        // stopped such a resume with the act left in flight).
        if ctx.resuming, ctx.copyKey == nil, Self.beforeTheStage.contains(step),
           try ctx.leaves.library.stagedFingerprint() == nil || ctx.toKey.map(ActContext.fp) != (try ctx.leaves.library.stagedFingerprint()) {
            throw ActRollback(refusal: .secretsRequired(ctx.act))
        }
        switch step {
        case "custodyItem": try ctx.newCustodyItem(kind: kind)
        case "mintOwnAppleKey": _ = try ctx.mintOwnAppleKey()
        case "keyFile": try ctx.makeMineKeyFile(kind: kind)
        case "stage": try ctx.makeMineStage()
        case "recordIntoStaged": try ctx.makeMineRecord(kind: kind)
        case "newMemory": try ctx.makeMineMemory()
        case "swap": try ctx.makeMineSwap()
        case "forgetOtherLibraries": try ctx.forgetOtherLibraries()
        case "backup": try ctx.freshBackup()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

extension ActContext {
    /// The new library's identity, as the press minted it (in the plan).
    func makeMineIdentity() throws -> (libraryID: String, deviceID: String) {
        guard let libraryID = parameters.newLibraryID, let deviceID = parameters.newDeviceID else {
            throw ExecutorRefusal.nothingToDo
        }
        return (libraryID, deviceID)
    }

    /// The new library's key file: a fresh key with no past, locked under the
    /// current pair (the passphrase when there is one, the words always) and,
    /// Standard, the fresh own Apple key. Never the account's master: the new
    /// library carries no sync identity.
    func makeMineKeyFile(kind: ProtectionMode) throws {
        let key = try requireToKey()
        if let live = library.keyFile, live.fingerprint == Self.fp(key) { return }
        let (libraryID, _) = try makeMineIdentity()
        let apple = kind == .standard ? try ownAppleKey() : nil
        let locks = try newLocks(passphrase: secrets.passphrase != nil, words: true, master: false, apple: apple)
        let file = try KeyFile.building(libraryID: libraryID, key: key, epoch: 1, locks: locks)
        try executor.writeLiveKeyFile(file, &library)
        log("the new library's key file written (\(Self.fp8(file.fingerprint)))")
    }

    /// The copy re-encrypted under the new key into the staged file.
    func makeMineStage() throws {
        leaves.backups.pauseCopies()
        let key = try requireToKey()
        if try libraryOpens(key) { return }
        guard let copyKey, let copyID = parameters.copyID else {
            // A resume holds no copy key (a plan never holds one): roll back.
            throw ActRollback(refusal: .secretsRequired(act))
        }
        try leaves.library.stageCopy(copyID: copyID, opener: copyKey, to: key)
    }

    /// The NEW record into the staged file: a fresh library ID, the posture of
    /// now, no account; this device's new section (its fresh device ID, the
    /// settings of now, the fresh own Apple key, the act in flight).
    func makeMineRecord(kind: ProtectionMode) throws {
        let key = try requireToKey()
        if try libraryOpens(key) { return }
        let (libraryID, deviceID) = try makeMineIdentity()
        var record = ProtectionRecord.minting(
            libraryID: libraryID, mode: kind, account: nil, currentFingerprint: Self.fp(key),
            passphraseSet: secrets.passphrase != nil, at: now)
        var section = DeviceSection(deviceID: deviceID, settings: library.section.settings)
        if let own = parameters.ownAppleKeyID { section = section.recordingAppleKey(AppleKeyRecord(id: own)) }
        section.actInFlight = library.section.actInFlight
        section.lastActSequence = library.section.lastActSequence
        record = try record.storing(section, sealedUnder: key)
        try leaves.library.writeStagedRecord(record, with: key)
    }

    /// The new library's memory item (rule 21's four things), before the swap:
    /// whichever side a crash leaves, this Mac remembers the library in the live
    /// place.
    func makeMineMemory() throws {
        let key = try requireToKey()
        let (libraryID, deviceID) = try makeMineIdentity()
        guard let file = library.keyFile, file.fingerprint == Self.fp(key) else { throw ExecutorRefusal.noLiveKeyFile }
        let memory = DeviceMemory(libraryID: libraryID, currentFingerprint: Self.fp(key), deviceID: deviceID, keyFileMirror: file)
        try leaves.memory.writeMemory(try memory.sealed(under: key), libraryID: libraryID)
    }

    /// THE SWAP — the commit point: the plan re-sealed for the new library
    /// first, then the staged copy into the live place with the outgoing library
    /// and ITS key file set aside whole.
    func makeMineSwap() throws {
        let key = try requireToKey()
        let (_, deviceID) = try makeMineIdentity()
        if !(try libraryOpens(key)) {
            plan.deviceID = deviceID
            plan.steps[plan.steps.firstIndex { $0.name == "swap" }!].done = true
            try leaves.plans.writePlan(try plan.sealed(under: key))
            if try leaves.library.stagedFingerprint() != Self.fp(key) { throw ActRollback(refusal: .secretsRequired(act)) }
            let outgoing = parameters.outgoingKeyFile ?? library.memory?.keyFileMirror
            try leaves.library.swapStaged(setAside: true, asideKeyFile: outgoing)
        }
        library.key = key
        guard let record = try leaves.library.readRecord(with: key) else { throw ExecutorRefusal.recordMissing }
        library.record = record
        library.keyFile = try executor.liveFormat3()
        library.section = record.verifiedSections { $0 == Self.fp(key) ? key : nil }
            .first { $0.deviceID == deviceID } ?? library.section
        library.memory = nil
        executor.configuration.libraryID = record.libraryID
        heldFromKey = nil
        leaves.backups.resumeCopies()
        log("swapped — this Mac's library is the copy, a new library under \(Self.fp8(Self.fp(key)))")
    }

    /// Rule 21: this Mac remembers ONE library — every other library's memory
    /// item goes (the outgoing one among them; it lives on in Previous
    /// Libraries with its key file).
    func forgetOtherLibraries() throws {
        guard let current = library.record?.libraryID else { return }
        for other in try leaves.memory.rememberedLibraryIDs() where other != current {
            try leaves.memory.deleteMemory(libraryID: other)
        }
        try executor.writeMemory(&library)
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
    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] { ["deleteCopies"] }

    func run(_ step: String, _ ctx: ActContext) async throws {
        if let ids = ctx.parameters.copyIDs, !ids.isEmpty { try ctx.leaves.backups.deleteCopies(ids: ids) }
    }
}

extension ProtectionExecutor {
    /// **Look inside** (rule 17): any copy — a backup, someone else's library —
    /// opened read-only with its own secrets, the current secrets through the
    /// live key file's history (rule 4), or its own quiet road on this Mac.
    /// WRITES NOTHING: no key file, no keychain item, no change to the library;
    /// close it and the app forgets it. `typed`: what she typed at its door (none
    /// tries only the quiet roads).
    public func lookInside(_ copy: CatalogCopy, in catalog: Catalog, typed: TypedSecrets = .none) throws -> LookedInside {
        let (key, road) = try openCopy(copy, in: catalog, typed: typed)
        return LookedInside(copyID: copy.id, key: key, road: road)
    }

    /// The key that opens a copy, and the road — every road verifies itself
    /// against the copy's own file. Reads only.
    func openCopy(_ copy: CatalogCopy, in catalog: Catalog, typed: TypedSecrets) throws -> (StoreKey, CopyRoad) {
        let files = catalog.servingKeyFiles(of: copy).compactMap(\.document)
        let candidates = Set(copy.fingerprint.map { [$0] } ?? copy.candidateFingerprints)
        func opens(_ key: StoreKey?) -> StoreKey? {
            guard let key, candidates.isEmpty || candidates.contains(Self.fp(key)),
                  (try? leaves.library.copyOpens(copyID: copy.id, with: key)) == true else { return nil }
            return key
        }
        var secrets: [ProtectionSecret] = []
        if let passphrase = typed.passphrase { secrets.append(.passphrase(passphrase)) }
        if let words = typed.words { secrets.append(.words(words)) }
        // Its own secrets, on its own key file (the key file's history too —
        // a key file opens its earlier keys).
        for file in files {
            for secret in secrets {
                guard let current = try? file.open(secret, floor: configuration.floor) else { continue }
                if let key = opens(current) { return (key, .itsOwnSecrets) }
                for older in (try? file.historyKeys(currentKey: current)) ?? [] {
                    if let key = opens(older.key) { return (key, .itsOwnSecrets) }
                }
            }
        }
        // The current secrets, through the live key file's history (rule 4).
        if let live = catalog.liveKeyFile?.document {
            for secret in secrets {
                guard let current = try? live.open(secret, floor: configuration.floor) else { continue }
                for older in [OpenedKey(fingerprint: live.fingerprint, epoch: live.epoch, retiredAt: nil, key: current)]
                    + ((try? live.historyKeys(currentKey: current)) ?? []) {
                    if let key = opens(older.key) { return (key, .currentSecretsThroughTheHistory) }
                }
            }
        }
        // Its own quiet road on this Mac — a key it holds directly (rule 4).
        let items = try leaves.custody.custodyItems()
        for fingerprint in candidates.sorted() {
            for itemClass in [ProtectionNames.CustodyClass.silent, .touchid]
            where items.contains(CustodyItemFact(fingerprint: fingerprint, itemClass: itemClass)) {
                if let key = opens(try leaves.custody.readCustody(fingerprint: fingerprint, itemClass: itemClass)) {
                    return (key, .quietRoad(itemClass == .silent ? .thisMac : .touchID))
                }
            }
        }
        for file in files {
            if let wrap = file.apple, let apple = try leaves.apple.readAppleKey(id: wrap.keyID),
               let key = opens(try? file.open(apple: apple)) {
                return (key, .quietRoad(.appleAccount))
            }
        }
        throw ExecutorRefusal.copyDoesNotOpen
    }

    /// **Make this my library** (rule 17) — one confirmed door. `copySecrets`:
    /// what opens the copy at its door (or nothing, for its quiet road);
    /// `currentPair`: this device's current passphrase (when it has one) and its
    /// words, verified, which lock the new library ("under your current pair").
    /// The copy becomes a NEW library in the posture this device is in now; the
    /// library in the live place steps aside whole into Previous Libraries. It
    /// carries no sync identity (PROVISIONAL P-VX378-U2-4).
    public func makeThisMyLibrary(
        _ library: inout UnlockedLibrary, copy: CatalogCopy, in catalog: Catalog, copySecrets: TypedSecrets = .none,
        currentPair: TypedSecrets
    ) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        if let inFlight = library.section.actInFlight { throw ExecutorRefusal.actInFlight(inFlight.act) }
        // Decision 35: a Standard library bound to an account mints nothing
        // Apple-reachable without its account's vault read this session.
        if record.mode == .standard, let account = record.account, guards.freshVaultBeforeAppleWriteOn,
           !readThisSession(account) {
            throw ExecutorRefusal.needsFreshVault
        }
        let (copyKey, _) = try openCopy(copy, in: catalog, typed: copySecrets)
        guard !currentPair.wordsAreNew else { throw ExecutorRefusal.wordsMustBeTyped }
        var secrets = ActSecrets()
        if library.keyFile?.passphrase != nil {
            secrets.passphrase = try verifiedPassphrase(currentPair.passphrase, against: library.keyFile)
        }
        secrets.words = try verifiedWords(currentPair.words, against: library.keyFile)
        let gate = library.section.settings.gateStyle
        var parameters = ActParameters(
            gate: gate, passphraseKDF: secrets.passphrase?.kdf, newKind: record.mode, copyID: copy.id)
        parameters.newLibraryID = leaves.ids.mintID()
        parameters.newDeviceID = leaves.ids.mintID()
        let program = MakeMineProgram()
        let toKey = leaves.ids.mintLibraryKey()
        return try await perform(program, parameters: parameters, secrets: secrets, typed: currentPair, toKey: toKey,
                                 copyKey: copyKey, library: &library)
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
    /// Mac's copies of it only (never another Mac's, never this library's).
    public func offerDelete(_ library: inout UnlockedLibrary, copies: [CatalogCopy], catalog: Catalog) async throws -> ActOutcome {
        let thisLibrary = library.record?.libraryID
        let mine = library.section.mac8
        let deletable = copies.filter { $0.library != nil && $0.library != thisLibrary && $0.mac.isMac(mine) }
        return try await perform(
            OfferDeleteProgram(), parameters: ActParameters(copyIDs: Set(deletable.map(\.id)).sorted()),
            secrets: ActSecrets(), library: &library)
    }
}
