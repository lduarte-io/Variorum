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
//   - A PLAINTEXT EXPORT carries no library ID: `protection_record` is
//     local-only and `StorePlaintextExport` drops it. Brought in, it is a NEW
//     library (VX-309 T-8 — the import road, never this file's acts).
//   - THE OFFER deletes another library's copies at her press — this Mac's
//     copies of it only, never another Mac's (rule 19).

/// What Look inside opened (rule 17) — a copy, read-only. The key is held for
/// the look and never stored; closing the copy forgets it. (VX-307 U2c:
/// Sendable — Make this my library's preflight hands it to the act, so her one
/// press opens the copy once.)
public struct LookedInside: CustomStringConvertible, Sendable {
    /// The copy's catalog id.
    public let copyID: String
    /// The key that opens it.
    public let key: StoreKey
    /// The road that opened it.
    public let road: CopyRoad

    public var description: String { "LookedInside(\(copyID), \(road), redacted)" }
}

/// Which of this Mac's quiet roads a copy door may try (VX-306 ladder round 1,
/// m2): a face's AUTOMATIC probe — the one a sheet runs as it opens, before any
/// press — reads only what never prompts (the silent item and the Apple wrap);
/// Touch ID is pressed only at a person's deliberate press.
public enum CopyQuietRoads: Equatable, Sendable {
    /// The silent item and the Apple wrap — reads that never prompt.
    case withoutAPress
    /// Every quiet road, Touch ID's included — a deliberate press.
    case includingTouchID
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
    /// and ITS key file set aside whole. `setAside` false (VX-309 U1b — T-5, the
    /// empty-slot landing): nothing is in the slot, so the step-aside half is
    /// SKIPPED, never run over nothing.
    func makeMineSwap(setAside: Bool = true) throws {
        let key = try requireToKey()
        let (_, deviceID) = try makeMineIdentity()
        // VX-488 R1 F1: the account the OUTGOING record names — read before the record is replaced below.
        let outgoingAccount = library.record?.account
        if !(try libraryOpens(key)) {
            plan.deviceID = deviceID
            plan.steps[plan.steps.firstIndex { $0.name == "swap" }!].done = true
            try leaves.plans.writePlan(try plan.sealed(under: key))
            if try leaves.library.stagedFingerprint() != Self.fp(key) { throw ActRollback(refusal: .secretsRequired(act)) }
            if setAside {
                let outgoing = parameters.outgoingKeyFile ?? library.memory?.keyFileMirror
                try leaves.library.swapStaged(setAside: true, asideKeyFile: outgoing)
            } else {
                try leaves.library.swapStaged(setAside: false, asideKeyFile: nil)
            }
        }
        library.key = key
        guard let record = try leaves.library.readRecord(with: key) else { throw ExecutorRefusal.recordMissing }
        // VX-488 R1 F1 — the outgoing library's account hold leaves with it: the landed record names no account (rule 17),
        // and with the process's one sync-keys leaf (VX-487 F-M1-1) nothing else would ever clear it (the relock that would
        // has stepped aside with its library). Always ask's session-only custody included.
        if let outgoingAccount, outgoingAccount != record.account {
            leaves.syncKeys.holdInSession(nil, accountID: outgoingAccount)
        }
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

/// **MAKE THIS MY LIBRARY INTO THE EMPTY SLOT** (VX-309 U1b — T-5; rule 17 with no library open: the missing face, rule
/// 27's lobby once its unopenable library stepped aside). The copy lands as a NEW library — a fresh identity, key and
/// device ID, Standard — and NOTHING steps aside: there is nothing in the slot, so the act's step-aside half is skipped
/// (`makeMineSwap(setAside: false)`), never run over nothing. The steps are Make this my library's own, reordered so the
/// keychain and the live place are written only once the copy is staged (a copy that cannot be staged writes nothing but
/// the plan, which the next library's settle ignores and deletes): the copy re-encrypted under the new key into the staged
/// file; the new record
/// into it (its section naming this act in flight); the new key's silent item; this Mac's own fresh Apple key for it; the
/// new key file in the live place; the new library's memory item; THE SWAP (the commit point — the empty slot takes the
/// staged file); every other library's memory item forgotten (rule 21: one library); a fresh pair (rule 5). ONE plan,
/// sealed under the NEW key and named by the new record's section — so a crash after the swap resumes at the next open
/// (its library opens by the silent item), and a crash before it leaves the slot empty (the old state) beside the act's
/// own debris, which names a library that never landed. A resume after the swap is the registry's `MakeMineProgram` (the
/// same step names, the same `makeMine` act); before it nothing can resume — no library holds the act.
struct EmptySlotMakeMineProgram: ActProgram {
    let act = ProtectionAct.makeMine
    /// This Mac's own Apple key for the new library, minted at the press (its id rides the plan and the new section).
    let apple: AppleKeyMaterial

    func steps(_ parameters: ActParameters, guards: ProtectionGuards) -> [String] {
        ["stage", "recordIntoStaged", "custodyItem", "appleKey", "keyFile", "newMemory", "swap"]
            + MakeMineProgram.afterCommit
    }

    func finishingSteps(_ library: UnlockedLibrary) -> [String] { MakeMineProgram.afterCommit }

    func run(_ step: String, _ ctx: ActContext) async throws {
        switch step {
        case "stage": try ctx.makeMineStage()
        case "recordIntoStaged": try ctx.makeMineRecord(kind: .standard)
        case "custodyItem": try ctx.newCustodyItem(kind: .standard)
        case "appleKey":
            if try ctx.leaves.apple.readAppleKey(id: apple.id) == nil {
                try ctx.leaves.apple.addAppleKey(apple, libraryID: ctx.stampLibraryID)
                ctx.log("minted a fresh own Apple key for the landed copy")
            }
        case "keyFile": try ctx.emptySlotKeyFile(apple: apple)
        case "newMemory": try ctx.makeMineMemory()
        case "swap": try ctx.makeMineSwap(setAside: false)
        case "forgetOtherLibraries": try ctx.forgetOtherLibraries()
        case "backup": try ctx.freshBackup()
        default: throw ExecutorRefusal.nothingToDo
        }
    }
}

extension ActContext {
    /// The landed library's key file: a fresh key with no past, under the secret typed at the door — the copy's own
    /// words as its words lock, or the copy's own passphrase as its passphrase lock beside words minted fresh — and this
    /// Mac's own Apple key (Standard). Idempotent: a file of the new key already standing is left as it is.
    func emptySlotKeyFile(apple: AppleKeyMaterial) throws {
        let key = try requireToKey()
        if let live = try executor.liveFormat3(), live.fingerprint == Self.fp(key) {
            library.keyFile = live
            return
        }
        let (libraryID, _) = try makeMineIdentity()
        let locks = try newLocks(passphrase: secrets.passphrase != nil, words: true, master: false, apple: apple)
        let file = try KeyFile.building(libraryID: libraryID, key: key, epoch: 1, locks: locks)
        try executor.writeLiveKeyFile(file, &library)
        log("the landed library's key file written (\(Self.fp8(file.fingerprint)))")
    }
}

/// **A copy landed into the empty slot** (T-5): the new library, and — when the copy opened by its PASSPHRASE — the twelve
/// words minted fresh for it (rule 2: every library has words from its first moment; handed back like a creation's, never
/// stored — the Mac drops them unseen and the card above the quick entry offers fresh ones at the first look). nil when the
/// copy's own words, typed at the door, became the new library's words.
public struct LandedCopy: CustomStringConvertible {
    public var library: UnlockedLibrary
    public let mintedWords: [String]?
    public var outcome: ActOutcome

    public var description: String { "LandedCopy(\(outcome.act), words \(mintedWords == nil ? "typed" : "minted, redacted"))" }
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
    /// tries only the quiet roads). `quietRoads`: which of this Mac's quiet roads
    /// may be tried — a face's automatic probe passes `.withoutAPress`, so it never
    /// raises a Touch ID prompt nobody asked for (VX-306 ladder round 1, m2).
    /// VX-307 U2c (the VX-306 ladder's round-2 NIT 2): NO DEFAULT — the prompting
    /// road is never the one a caller gets by saying nothing; every caller
    /// chooses (`.includingTouchID` only at a deliberate press).
    public func lookInside(
        _ copy: CatalogCopy, in catalog: Catalog, typed: TypedSecrets = .none,
        quietRoads: CopyQuietRoads
    ) throws -> LookedInside {
        let (key, road) = try openCopy(copy, in: catalog, typed: typed, quietRoads: quietRoads)
        return LookedInside(copyID: copy.id, key: key, road: road)
    }

    /// The key that opens a copy, and the road — every road verifies itself
    /// against the copy's own file. Reads only (a Touch ID item is READ only under
    /// `.includingTouchID` — that read is the press).
    func openCopy(
        _ copy: CatalogCopy, in catalog: Catalog, typed: TypedSecrets, quietRoads: CopyQuietRoads
    ) throws -> (StoreKey, CopyRoad) {
        let files = catalog.servingKeyFiles(of: copy).compactMap(\.document)
        let candidates = Set(copy.fingerprint.map { [$0] } ?? copy.candidateFingerprints)
        func opens(_ key: StoreKey?) -> StoreKey? {
            guard let key, copyKeyOpens(key, copy: copy) else { return nil }
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
        // Its own quiet road on this Mac — a key it holds directly (rule 4). A
        // Touch ID item's read IS a press: only when the door was pressed.
        let items = try leaves.custody.custodyItems()
        let classes: [ProtectionNames.CustodyClass] = quietRoads == .includingTouchID ? [.silent, .touchid] : [.silent]
        for fingerprint in candidates.sorted() {
            for itemClass in classes
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

    /// Whether `key` is the copy's key: one of the fingerprints its key file
    /// names (when it names any) AND it opens the copy's own file — a READ that
    /// never prompts (no keychain item is touched).
    func copyKeyOpens(_ key: StoreKey, copy: CatalogCopy) -> Bool {
        let candidates = Set(copy.fingerprint.map { [$0] } ?? copy.candidateFingerprints)
        guard candidates.isEmpty || candidates.contains(Self.fp(key)) else { return false }
        return (try? leaves.library.copyOpens(copyID: copy.id, with: key)) == true
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
        try await makeThisMyLibrary(&library, copy: copy, currentPair: currentPair) {
            // Her confirmed press — the copy's own quiet roads, Touch ID's included (m2).
            try self.openCopy(copy, in: catalog, typed: copySecrets, quietRoads: .includingTouchID).0
        }
    }

    /// **Make this my library on a copy her press already OPENED** (VX-307 U2c
    /// — the VX-306 ladder's round-2 NIT 1 (i)): the door's preflight is a look
    /// at her press (`lookInside` — the copy's own secrets, the history, or its
    /// own quiet road, Touch ID's included: ONE press), and the act takes the key
    /// that look opened instead of opening the copy a second time — re-verified
    /// against the copy's own file (`copyKeyOpens`, a read that never prompts).
    /// So her one confirmed press reads a Touch ID item at most once. A key that
    /// no longer opens the copy (it changed between) refuses `copyDoesNotOpen`;
    /// nothing else differs from the secrets form.
    public func makeThisMyLibrary(
        _ library: inout UnlockedLibrary, opened: LookedInside, copy: CatalogCopy, in catalog: Catalog,
        currentPair: TypedSecrets
    ) async throws -> ActOutcome {
        try await makeThisMyLibrary(&library, copy: copy, currentPair: currentPair) {
            guard opened.copyID == copy.id, self.copyKeyOpens(opened.key, copy: copy) else {
                throw ExecutorRefusal.copyDoesNotOpen
            }
            return opened.key
        }
    }

    /// The act's one body — `copyKey` answers the copy's key (the secrets
    /// form opens it; the opened form re-verifies the look's), read where the
    /// secrets form always read it: after the record, in-flight and vault
    /// guards, before the current pair is verified.
    private func makeThisMyLibrary(
        _ library: inout UnlockedLibrary, copy: CatalogCopy, currentPair: TypedSecrets,
        copyKey readCopyKey: () throws -> StoreKey
    ) async throws -> ActOutcome {
        guard let record = library.record else { throw ExecutorRefusal.recordMissing }
        if let inFlight = library.section.actInFlight { throw ExecutorRefusal.actInFlight(inFlight.act) }
        // Decision 35: a Standard library bound to an account mints nothing
        // Apple-reachable without its account's vault read this session.
        if record.mode == .standard, let account = record.account, guards.freshVaultBeforeAppleWriteOn,
           !readThisSession(account) {
            throw ExecutorRefusal.needsFreshVault
        }
        let copyKey = try readCopyKey()
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

    /// **Make this my library into the EMPTY SLOT** (VX-309 U1b — T-5; rule 17 with no library open). `typed`: what she
    /// typed at the door — the copy's own twelve words, or its own passphrase. THE DOOR REQUIRES A TYPED SECRET OF THE
    /// COPY'S (rule 14's precedent): with no library open there is no current pair to lock the new library under, and a
    /// quiet-road-only open carries none — so the copy must open by what was typed (its own key file, or through a
    /// history that reaches it); a quiet road that would open it does not count (`copyDoesNotOpen`). The typed WORDS become
    /// the new library's words lock (no passphrase — rule 3 asks later); a typed PASSPHRASE becomes its passphrase lock (on
    /// a fresh descriptor) and the new library's twelve words are minted fresh (`LandedCopy.mintedWords` — shown through the
    /// band's one idiom, never stored). STANDARD (an empty slot has no posture; Castle is entered deliberately —
    /// PROVISIONAL P-VX309-U1b-2). The slot must be EMPTY and the live place too — a library or a key file standing there
    /// refuses `libraryAlreadyInSlot` before anything is minted (the app's doors set a missing library's key file, or rule
    /// 27's unopenable library, aside first — never written over). One act on one plan (`EmptySlotMakeMineProgram`). It
    /// carries no sync identity and binds no account (P-VX378-U2-4). The restore hold is the app's, as for every adoption.
    public func makeThisMyLibraryInTheEmptySlot(
        copy: CatalogCopy, in catalog: Catalog, typed: TypedSecrets
    ) async throws -> LandedCopy {
        guard try !leaves.library.slotIsOccupied(), try leaves.keyFiles.readLiveKeyFile() == nil else {
            log("make mine (empty slot): refused — something stands in the slot or the live place (nothing written)")
            throw ExecutorRefusal.libraryAlreadyInSlot
        }
        // The copy's own secret, typed — each typed road tried on its own, so the lock the new library gets is the
        // secret that OPENED the copy (never a quiet road's: those carry no pair to lock it under).
        func openedByTyped(_ secret: TypedSecrets) -> StoreKey? {
            guard let (key, road) = try? openCopy(copy, in: catalog, typed: secret, quietRoads: .withoutAPress) else {
                return nil
            }
            switch road {
            case .itsOwnSecrets, .currentSecretsThroughTheHistory: return key
            case .quietRoad: return nil
            }
        }
        var secrets = ActSecrets()
        var minted: [String]?
        let copyKey: StoreKey
        if let words = typed.words, let key = openedByTyped(TypedSecrets(words: words)) {
            copyKey = key
            secrets.words = try WordsKey.derive(words)
        } else if let passphrase = typed.passphrase, let key = openedByTyped(TypedSecrets(passphrase: passphrase)) {
            copyKey = key
            secrets.passphrase = try freshPassphrase(passphrase)
            let fresh = leaves.ids.mintWords()
            secrets.words = try WordsKey.derive(fresh)
            minted = fresh
        } else {
            throw ExecutorRefusal.copyDoesNotOpen
        }
        let toKey = leaves.ids.mintLibraryKey()
        let libraryID = leaves.ids.mintID()
        let deviceID = leaves.ids.mintID()
        let apple = leaves.ids.mintAppleKey()
        let at = now()
        configuration.libraryID = libraryID
        var parameters = ActParameters(passphraseKDF: secrets.passphrase?.kdf, newKind: .standard, copyID: copy.id)
        parameters.passphraseIsNew = secrets.passphrase != nil
        parameters.newLibraryID = libraryID
        parameters.newDeviceID = deviceID
        parameters.ownAppleKeyID = apple.id
        let (section, sequence) = DeviceSection(deviceID: deviceID, settings: .noChoiceYet)
            .beginningAct(.makeMine, from: nil, to: Self.fp(toKey), fromKind: nil, at: at)
        let program = EmptySlotMakeMineProgram(apple: apple)
        let plan = ProtectionPlan(
            libraryID: libraryID, deviceID: deviceID, sequence: sequence, act: .makeMine, fromFingerprint: nil,
            toFingerprint: Self.fp(toKey), steps: program.steps(parameters, guards: guards).map { PlanStep(name: $0) },
            createdAt: at, parameters: parameters)
        try leaves.plans.writePlan(try plan.sealed(under: toKey))
        log("make mine (empty slot): begun #\(sequence) → \(Self.fp8(Self.fp(toKey))) — a new library, nothing steps aside")
        let ctx = ActContext(
            executor: self, library: UnlockedLibrary(key: toKey, record: nil, section: section, memory: nil, keyFile: nil),
            plan: plan, secrets: secrets, typed: nil, toKey: toKey, resuming: false)
        ctx.copyKey = copyKey
        // Before the swap a failure leaves what a crash there leaves — the slot EMPTY (the old state) beside this press's
        // own writes, every one of them a library that never landed (none of hers is touched): a later landing or
        // creation writes over or forgets them (the plan, the staged file, the memory item), and the doors set a live key
        // file aside before landing. Past the swap the copy IS the library: the next open finishes from its plan (rule 20).
        try await drive(program, ctx)
        return LandedCopy(library: ctx.library, mintedWords: minted, outcome: ctx.outcome)
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
    /// VX-309 U1c (VX-265): "this Mac's" is `OwnCopies.isThisMacsCopy` — told by
    /// PLACE, never by comparing a copy's `<mac8>` with the OPEN library's
    /// section: a library's device ID is its own on each Mac (rule 23), so the
    /// library that stepped aside filed its backups under its OWN `<mac8>`.
    public func offerDelete(_ library: inout UnlockedLibrary, copies: [CatalogCopy], catalog: Catalog) async throws -> ActOutcome {
        let thisLibrary = library.record?.libraryID
        let deletable = copies.filter {
            $0.library != nil && $0.library != thisLibrary && OwnCopies.isThisMacsCopy($0, in: catalog)
        }
        return try await perform(
            OfferDeleteProgram(), parameters: ActParameters(copyIDs: Set(deletable.map(\.id)).sorted()),
            secrets: ActSecrets(), library: &library)
    }

    /// **The offer's delete with NO library open** (VX-309 U1c — VX-265 at the EMPTY-SLOT listing: the missing face). The
    /// same fence (`OwnCopies.isThisMacsCopy`), and never a copy of a library this Mac REMEMBERS (rule 21 — the library
    /// missing from the slot: its copies are the ones the empty-slot landing lands from — PROVISIONAL P-VX309-U1c-2). The
    /// slot must be EMPTY: over rule 27's unopenable library the act refuses `libraryAlreadyInSlot` before anything is
    /// deleted — its ID is inside the file no key opens, so with this Mac's memory of it gone any listed library could be it,
    /// and its older backups are its last road back (rule 4). No plan: deleting copies changes no key (rule 20 is about
    /// acts that change keys) and no library holds the act — a delete that stops part of the way has deleted fewer copies,
    /// and the next press deletes the rest (each id's delete is idempotent). Returns the ids deleted; nothing deletable
    /// refuses `nothingToDo` with nothing written.
    @discardableResult
    public func offerDeleteWithNoLibraryOpen(copies: [CatalogCopy], catalog: Catalog) throws -> [String] {
        guard try !leaves.library.slotIsOccupied() else {
            log("offer delete (no library open): refused — a library stands in the slot (nothing deleted)")
            throw ExecutorRefusal.libraryAlreadyInSlot
        }
        let remembered = try leaves.memory.rememberedLibraryIDs()
        let deletable = Set(copies.filter { copy in
            guard let library = copy.library, !remembered.contains(library) else { return false }
            return OwnCopies.isThisMacsCopy(copy, in: catalog)
        }.map(\.id)).sorted()
        guard !deletable.isEmpty else { throw ExecutorRefusal.nothingToDo }
        try leaves.backups.deleteCopies(ids: deletable)
        log("offer delete (no library open): \(deletable.count) of another library's copies on this Mac")
        return deletable
    }
}
