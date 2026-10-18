//
//  ProtectionOpenRoad.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1b — THE NEW OPEN ROAD, off the main actor (`notes/plans/vx-306-castle-open-road.md` §2 U1b; the
//  contract `notes/CastleRules.md`). Reached ONLY behind the one switch (`ProtectionRoad.newRoadIsLive`, read at
//  the head of `AppBootstrap.routeAndOpen`). Nothing here decides: the gatherer's facts go to `assess`, its
//  `LaunchVerdict` routes, every road verifies itself against the library in the slot, and the executor is the
//  one thing that writes.
//
//    - `.startFresh` → `createLibrary(passphrase: nil)` (rule 2: the twelve words at birth, shown once on the
//      card; rule 3: the passphrase is asked later) → the card, then the open.
//    - `.libraryMissing` → today's three-door face (unchanged this unit).
//    - `.lobby` → THE QUIET ROADS AT ONCE, in order (rule 8: "the next open uses whatever quiet road still
//      works"): every silent item's key, then each Apple wrap whose key reads here — the live key file's first,
//      then this Mac's sealed mirror's and every catalogued key file's (P-VX306-U1b-2: the scenario world's own
//      walk, `World.walkLobby`); each candidate EXPANDED through the history of every key file this Mac holds
//      (rule 4 — a library file swapped for an older one opens through it, with rule 21's notice), the one that
//      opens the slot unlocking with every other key reached in hand (`unlock(with:alsoInHand:)`). With none
//      opening, the lobby: its typed roads are the live key file's PLUS rule 1's keychain mirror and every
//      catalogued key file (the N5 hand-forward), its Touch ID button VX-310's.
//    - After any unlock: `settle` (an act in flight resumes or rolls back — rule 20), then `assess`'s repairs
//      (`refreshMemory`, `remakeOnDeviceItem`, `remakeAppleRoad`, `restoreKeyFileFromMirror`, … — the
//      mechanism; the faces of the notice, the offer and rule 27 are U2's), a few passes as the world runs them;
//      the open continues into today's `openStoreOffMain` with the key in hand (the bootstrap's).
//    - THE THROWING EDGES never crash: an unlistable keychain (P-VX306-U1a-3) shows the typed field with a
//      one-line reason; a non-format-3 file in the live place (P-VX306-U1a-2) leaves the lobby standing with
//      its sentence; `recordMissing` (rule 26 — a store from before this design) routes to the missing face
//      with NO sentence about the store (P-VX306-K5).
//    - A HOSTED TEST RUN (the test host IS the dev-store app) runs this road READ-ONLY (`writes == false`): it
//      may open the dev library, never create one, settle, repair or take a pair — the tripwire refuses every
//      real-scope mutation in a test process, and a refused trip would land in the tripwire suite's exact count.
//

import CryptoKit
import Foundation
import os
import VariorumCore

/// The twelve words of a library just created — held only until the card's one button, never logged.
nonisolated struct OnceShownWords: Sendable, CustomStringConvertible {
    let words: [String]
    var description: String { "OnceShownWords(redacted)" }
}

/// What an open on the new road found, for the faces U2 builds (the notice, rule 1's receipt, the faults and the
/// acts owed). Values only.
nonisolated struct RoadOpenReport: Sendable {
    /// RULE 21: what the open said once (her words — `LibraryNotice.words`).
    var notice: LibraryNotice?
    var repairsDone: [Repair] = []
    var repairsSkipped: [RepairReport.Skipped] = []
    /// The faults standing after the open's repairs (the last pass's).
    var faults: [Fault] = []
    /// VX-306 U2: EVERY act any pass of the open's repairs found owed, in the order found — not only the last
    /// pass's. Rule 3's `.askPassphrase(.quietRoadFailed)` is owed at "the first launch after a quiet road has
    /// failed": the FIRST pass finds it (the on-device item gone, the Apple road lost) and the same open's repairs
    /// then re-make the road, so the last pass no longer owes it.
    var acts: [OwedAct] = []
    /// VX-306 U2 — RULE 21's key-file search, run at the open when `.offerKeyFile` is owed (a READ —
    /// `ProtectionExecutor.searchKeyFiles`): the offer, the split pair, or rule 27. nil = not owed, or the search
    /// could not read (logged).
    var keyFileSearch: KeyFileSearch?
    /// What the settle did (a word for Diagnostics), or why it could not.
    var settle: String?
}

/// The library open on the new road — what the app's open, the backup hook and U2's faces hold. Used from the
/// road (off the main actor), the main actor and the backup hook's detached pair, so `library` and `report` are
/// read and written under one lock (VX-306 U2: the set-passphrase sheet and the offer's *Use it* write them while
/// a backup pair may read them).
nonisolated final class ProtectionRoadSession: @unchecked Sendable {
    let system: ProtectionSystem
    let executor: ProtectionExecutor
    /// Created by THIS open (the store identity is minted fresh beside it — today's `startNewLibrary` mint).
    let isFresh: Bool
    /// Whether the road may write (false in a hosted test run — the backup hook stays off there too).
    let writes: Bool

    private let lock = NSLock()
    private var held: UnlockedLibrary
    private var heldReport: RoadOpenReport
    private var interludeShown = false
    private var receipts: [String] = []
    private var acting = false

    init(system: ProtectionSystem, executor: ProtectionExecutor, library: UnlockedLibrary, report: RoadOpenReport,
         isFresh: Bool, writes: Bool) {
        self.system = system
        self.executor = executor
        held = library
        heldReport = report
        self.isFresh = isFresh
        self.writes = writes
    }

    var library: UnlockedLibrary {
        get { lock.withLock { held } }
        set { lock.withLock { held = newValue } }
    }

    var report: RoadOpenReport {
        get { lock.withLock { heldReport } }
        set { lock.withLock { heldReport = newValue } }
    }

    var key: StoreKey { library.key }

    /// VX-306 U2 — the interlude (rule 21's notice, then the offer) is shown ONCE per open, before the library's
    /// open continues (`RoadInterlude.cards`); a hosted test run's read-only road shows none (nothing could act).
    var owesInterlude: Bool {
        lock.withLock { writes && !interludeShown && !RoadInterlude.cards(heldReport).isEmpty }
    }

    func markInterludeShown() { lock.withLock { interludeShown = true } }

    /// VX-306 U2 — receipts the open owes the status seam once the library is open (rule 1's restore — derived
    /// from the report at the open; the offer's *Use it*): added here, taken ONCE by the ready composition.
    func addReceipt(_ text: String) { lock.withLock { receipts.append(text) } }

    func takeReceipts() -> [String] {
        lock.withLock {
            defer { receipts = [] }
            return receipts
        }
    }

    /// VX-306 U2 — one act at a time on the session (the set-passphrase sheet may be open in two places): a
    /// second begin while one runs answers false.
    func beginAct() -> Bool {
        lock.withLock {
            guard !acting else { return false }
            acting = true
            return true
        }
    }

    func endAct() { lock.withLock { acting = false } }
}

/// The lobby's facts — before unlock, roads only.
nonisolated struct RoadLobbyFacts: Sendable {
    /// nil: the keychain could not be listed (P-VX306-U1a-3) — the typed field with a one-line reason.
    var facts: ProtectionFacts?
    /// The typed roads over every key file this Mac holds for the library (the live one, the mirror, the
    /// catalogued ones).
    var offeredTyped: Set<TypedRoad>
    /// The quiet roads met a file in the live place this build can't read as a key file (P-VX306-U1a-2).
    var liveKeyFileUnreadable = false
}

/// Where the route goes.
nonisolated enum RoadRoute: Sendable {
    case opened(ProtectionRoadSession)
    case created(ProtectionRoadSession, OnceShownWords)
    case lobby(RoadLobbyFacts)
    /// The three-door face (`.libraryMissing`, and K5's `recordMissing`).
    case libraryMissing
    case failed(String)
}

/// What one of the lobby's presses did.
nonisolated enum RoadAttempt: Sendable {
    case opened(ProtectionRoadSession)
    /// A typed attempt that opened nothing — the sentence says why.
    case refused(String)
    /// K5: a key opened a store with no protection record — the missing face, no sentence.
    case recordMissing
    /// A Touch ID press that opened nothing: what it did, this Mac's biometry after it, and whether the item
    /// was found gone (the only thing that drops the button — never a listing).
    case touchIDNotOpened(press: TouchIDPress?, biometry: BiometryFacts, itemGone: Bool)
}

/// The road's inputs, composed on the main actor once per open.
nonisolated struct RoadContext: Sendable {
    let system: ProtectionSystem
    let session: SessionFact
    /// false in a hosted test run over a real scope: read-only (see the header).
    let writes: Bool
}

nonisolated enum ProtectionOpenRoad {
    static let logger = Logger(subsystem: "io.lduarte.Variorum", category: "protection")

    /// One line to the protection log (never key material — act names, outcomes, error descriptions).
    static func log(_ line: String) { logger.notice("\(line, privacy: .public)") }

    // MARK: - The route

    /// The launch's road: a key already in hand (today's adoption doors hand one back) is tried first through
    /// the executor; otherwise the facts → `assess` → the verdict.
    static func route(_ ctx: RoadContext, keyInHand: StoreKey? = nil) async -> RoadRoute {
        if let keyInHand {
            switch await open(ctx, candidates: [keyInHand], typed: .none) {
            case .opened(let session): return .opened(session)
            case .recordMissing: return .libraryMissing
            case .noneOpens, .unreadableLiveKeyFile, .failed: break  // the ordinary road decides
            }
        }
        let lobby = lobbyFacts(ctx)
        guard let facts = lobby.facts else {
            // P-VX306-U1a-3: no listing, no guess. Over an empty slot nothing is created on a guess.
            if StoreFilePresence.classify(at: ctx.system.places.slot) == .absent {
                return .failed(ProtectionWords.keychainUnreadableNoLibrary)
            }
            return .lobby(lobby)
        }
        let assessment = assess(facts)
        switch assessment.launch {
        case .startFresh:
            return await create(ctx, setAsideLiveKeyFile: false)
        case .libraryMissing:
            return .libraryMissing
        case .lobby, .open:
            var standing = lobby
            switch await open(ctx, candidates: quietCandidates(ctx, facts: facts), typed: .none) {
            case .opened(let session): return .opened(session)
            case .recordMissing: return .libraryMissing
            case .unreadableLiveKeyFile: standing.liveKeyFileUnreadable = true
            case .noneOpens: break
            case .failed(let error): log("road: a quiet road failed to open — \(String(describing: error))")
            }
            return .lobby(standing)
        }
    }

    /// The lobby's facts, read now (a READ). A listing that could not be read yields no facts (P-VX306-U1a-3).
    static func lobbyFacts(_ ctx: RoadContext) -> RoadLobbyFacts {
        do {
            let facts = try ctx.system.facts(session: ctx.session)
            return RoadLobbyFacts(facts: facts, offeredTyped: offeredTyped(ctx, facts: facts))
        } catch {
            log("road: the lobby's facts could not be read — \(String(describing: error))")
            return RoadLobbyFacts(facts: nil, offeredTyped: [.passphrase, .words])
        }
    }

    // MARK: - Creating

    /// RULE 2 — a library in the empty slot, its twelve words handed back to be shown ONCE (never stored).
    /// `setAsideLiveKeyFile`: the missing face's *Start a New Library* — a key file of the missing library still
    /// in the live place steps aside into `Previous Libraries/<stamp>/` first (P-VX306-U1b-3: rule 1 — the key
    /// file is as essential as the library; the creation would write over it).
    /// `setAsideUnopenableLibrary` (VX-306 U2 — rule 27's face's *Start a New Library*, PROVISIONAL P-VX306-U2-5): the
    /// library in the slot that no key file opens is moved WHOLE (the file, its sidecars, any file in the live
    /// place) into `Previous Libraries/<stamp>/` first — never deleted (a key file found later still opens it there).
    static func create(
        _ ctx: RoadContext, setAsideLiveKeyFile: Bool, setAsideUnopenableLibrary: Bool = false
    ) async -> RoadRoute {
        guard ctx.writes else { return .failed(ProtectionWords.testRunNeverCreates) }
        do {
            if setAsideUnopenableLibrary { try setAsideUnopenableLibraryFor(ctx.system.places) }
            if setAsideLiveKeyFile { try setAsideLiveKeyFileFor(ctx.system.places) }
            let executor = ctx.system.executor(session: ctx.session)
            let created = try executor.createLibrary(passphrase: nil)
            var library = created.library
            var report = RoadOpenReport(notice: library.notice)
            // Nothing to settle in a library just made (no plan in an empty slot); the repairs' passes run.
            repairPasses(ctx, executor, &library, &report)
            logSummary(ctx, library, report, how: "created")
            let session = ProtectionRoadSession(
                system: ctx.system, executor: executor, library: library, report: report, isFresh: true,
                writes: ctx.writes)
            return .created(session, OnceShownWords(words: created.words))
        } catch {
            log("road: the creation failed — \(String(describing: error))")
            return .failed(ProtectionWords.couldNotCreate)
        }
    }

    /// A live key file in an EMPTY slot, moved (never deleted) into `Previous Libraries/<stamp>/`.
    static func setAsideLiveKeyFileFor(_ places: ProtectionPlaces) throws {
        let manager = FileManager.default
        guard manager.fileExists(atPath: places.liveKeyFile.path),
              !manager.fileExists(atPath: places.slot.path) else { return }
        var date = Date()
        for _ in 0..<120 {
            let folder = places.previousLibraries.appendingPathComponent(CatalogNames.stampString(date), isDirectory: true)
            if !manager.fileExists(atPath: folder.path) {
                try manager.createDirectory(at: folder, withIntermediateDirectories: true)
                try manager.moveItem(at: places.liveKeyFile, to: folder.appendingPathComponent(ProtectionNames.keyFilename))
                return
            }
            date += 1
        }
    }

    // MARK: - The lobby's presses

    /// A typed secret on every key file this Mac holds for the library — each key verified against the slot.
    static func openTyped(_ ctx: RoadContext, secret: ProtectionSecret) async -> RoadAttempt {
        if case .words(let words) = secret {
            do {
                try RecoveryPhrase.validate(words)
            } catch let error as RecoveryPhraseError {
                return .refused(sentence(for: error))
            } catch {
                return .refused(ProtectionWords.wordsDoNotOpen)
            }
        }
        let files = heldKeyFiles(ctx, facts: (try? ctx.system.facts(session: ctx.session)))
        let candidates = typedCandidates(secret, files: files, floor: ctx.system.floor)
        var typed = TypedSecrets.none
        switch secret {
        case .passphrase(let passphrase): typed = TypedSecrets(passphrase: passphrase)
        case .words(let words): typed = TypedSecrets(words: words)
        case .passphraseKey: break
        }
        switch await open(ctx, candidates: candidates, typed: typed) {
        case .opened(let session): return .opened(session)
        case .recordMissing: return .recordMissing
        case .unreadableLiveKeyFile: return .refused(ProtectionWords.liveKeyFileUnreadable)
        case .failed(let error):
            log("road: a typed open failed — \(String(describing: error))")
            return .refused(ProtectionWords.somethingWentWrong)
        case .noneOpens:
            if case .words = secret { return .refused(ProtectionWords.wordsDoNotOpen) }
            return .refused(ProtectionWords.passphraseDoesNotOpen)
        }
    }

    /// THE PRESS (VX-310): the Touch ID item for the current key (the live key file's), else the first one this
    /// scope lists — read through `readCustody(.touchid)`, which prompts. Never pressed while Touch ID is only
    /// unusable for now (the face says why first).
    static func pressTouchID(_ ctx: RoadContext, facts: ProtectionFacts?) async -> RoadAttempt {
        let custody = ctx.system.custody
        let touchItems = (facts?.custody ?? []).filter { $0.itemClass == .touchid }
        let hint = facts?.slotFingerprintHint
        guard let item = touchItems.first(where: { $0.fingerprint == hint }) ?? touchItems.first else {
            return .touchIDNotOpened(press: nil, biometry: ctx.system.leaves.biometry.biometry(), itemGone: true)
        }
        let key: StoreKey?
        do {
            key = try custody.readCustody(fingerprint: item.fingerprint, itemClass: .touchid)
        } catch {
            log("road: the Touch ID read failed — \(String(describing: error))")
            key = nil
        }
        let press = (custody as? KeychainCustodyLeaf)?.lastPress
        guard let key else {
            // No key, no recorded press: the item was not there to press (the probe found none).
            let gone = press == nil
            return .touchIDNotOpened(press: press, biometry: ctx.system.leaves.biometry.biometry(), itemGone: gone)
        }
        switch await open(ctx, candidates: [key], typed: .none) {
        case .opened(let session): return .opened(session)
        case .recordMissing: return .recordMissing
        case .unreadableLiveKeyFile: return .refused(ProtectionWords.liveKeyFileUnreadable)
        case .noneOpens, .failed:
            // The item's key opens nothing here: failed on an item that exists (the item is the final word).
            return .touchIDNotOpened(
                press: .failedOnExistingItem, biometry: ctx.system.leaves.biometry.biometry(), itemGone: false)
        }
    }

    // MARK: - Roads → keys

    /// Every key file this Mac holds that a road can open: the live one, the sealed mirror in what this Mac
    /// remembers (read as stated — a key file holds no secret; the unlock verifies), every catalogued one.
    static func heldKeyFiles(_ ctx: RoadContext, facts: ProtectionFacts?) -> [KeyFile] {
        var files: [KeyFile] = []
        func add(_ file: KeyFile?) { if let file, !files.contains(file) { files.append(file) } }
        add((try? ctx.system.leaves.keyFiles.readLiveKeyFile()) ?? nil)
        let remembered = facts?.rememberedLibraryIDs ?? ((try? ctx.system.leaves.memory.rememberedLibraryIDs()) ?? [])
        for libraryID in remembered.sorted() {
            guard let sealed = (try? ctx.system.leaves.memory.readMemory(libraryID: libraryID)) ?? nil,
                  let memory = try? ProtectionCoding.decoder().decode(DeviceMemory.self, from: sealed.payload)
            else { continue }
            add(memory.keyFileMirror)
        }
        for file in (facts?.catalog ?? ctx.system.lister.catalog()).keyFiles { add(file.document) }
        return files
    }

    /// The quiet roads' keys, in order: every silent item, then each Apple wrap whose key reads here.
    static func quietCandidates(_ ctx: RoadContext, facts: ProtectionFacts) -> [StoreKey] {
        var keys: [StoreKey] = []
        func add(_ key: StoreKey?) { if let key, !keys.contains(key) { keys.append(key) } }
        for item in facts.custody where item.itemClass == .silent {
            add((try? ctx.system.leaves.custody.readCustody(fingerprint: item.fingerprint, itemClass: .silent)) ?? nil)
        }
        let readable = facts.appleKeys.readable
        for file in heldKeyFiles(ctx, facts: facts) {
            guard let wrap = file.apple, readable.contains(wrap.keyID),
                  let apple = (try? ctx.system.leaves.apple.readAppleKey(id: wrap.keyID)) ?? nil else { continue }
            add(try? file.open(apple: apple))
        }
        return keys
    }

    /// A typed secret on every file — the passphrase derived ONCE per descriptor (the floor checked first).
    static func typedCandidates(_ secret: ProtectionSecret, files: [KeyFile], floor: PassphraseKDF.Floor) -> [StoreKey] {
        var keys: [StoreKey] = []
        func add(_ key: StoreKey?) { if let key, !keys.contains(key) { keys.append(key) } }
        switch secret {
        case .passphrase(let typed):
            guard !typed.isEmpty else { return [] }
            var derived: [PassphraseKey] = []
            for file in files {
                guard let kdf = file.passphrase?.kdf else { continue }
                let key: PassphraseKey
                if let known = derived.first(where: { $0.kdf == kdf }) {
                    key = known
                } else {
                    guard (try? kdf.validateFloor(floor)) != nil,
                          let fresh = try? PassphraseKey.derive(typed, kdf: kdf) else { continue }
                    derived.append(fresh)
                    key = fresh
                }
                add(try? file.open(.passphraseKey(key), floor: floor))
            }
        case .words, .passphraseKey:
            for file in files { add(try? file.open(secret, floor: floor)) }
        }
        return keys
    }

    /// Every candidate expanded through the history of each file whose current key it is (rule 4).
    static func expand(_ candidates: [StoreKey], files: [KeyFile]) -> [StoreKey] {
        var keys = candidates
        var index = 0
        while index < keys.count {
            let key = keys[index]
            index += 1
            let fingerprint = StoreKeyEnvelope.fingerprint(of: key)
            for file in files where file.fingerprint == fingerprint {
                for older in (try? file.historyKeys(currentKey: key)) ?? [] where !keys.contains(older.key) {
                    keys.append(older.key)
                }
            }
        }
        return keys
    }

    // MARK: - Opening

    enum OpenTry {
        case opened(ProtectionRoadSession)
        case noneOpens
        case recordMissing
        case unreadableLiveKeyFile
        case failed(any Error)
    }

    /// The candidates expanded, the one that opens the slot unlocking with every other key reached in hand;
    /// then the settle and the repairs.
    static func open(_ ctx: RoadContext, candidates: [StoreKey], typed: TypedSecrets) async -> OpenTry {
        guard !candidates.isEmpty else { return .noneOpens }
        let expanded = expand(candidates, files: heldKeyFiles(ctx, facts: nil))
        let library = ctx.system.leaves.library
        guard let opener = expanded.first(where: { (try? library.libraryOpens(with: $0)) == true }) else {
            return .noneOpens
        }
        let executor = ctx.system.executor(session: ctx.session)
        do {
            var unlocked = try executor.unlock(with: opener, alsoInHand: expanded.filter { $0 != opener })
            var report = RoadOpenReport(notice: unlocked.notice)
            if ctx.writes {
                // RULE 20: an act in flight resumes or rolls back; neither failing blocks the open (the world's
                // own reading — the lobby opens the library all the same, the act stays owed).
                do {
                    report.settle = String(describing: try await executor.settle(&unlocked, typed: typed))
                } catch {
                    report.settle = "could not settle: \(String(describing: error))"
                    log("road: the act in flight could not settle now — \(String(describing: error))")
                }
            } else {
                report.settle = "read-only (a hosted test run)"
            }
            repairPasses(ctx, executor, &unlocked, &report)
            report.keyFileSearch = searchIfOwed(ctx, executor, unlocked, report)
            logSummary(ctx, unlocked, report, how: "opened")
            let session = ProtectionRoadSession(
                system: ctx.system, executor: executor, library: unlocked, report: report, isFresh: false,
                writes: ctx.writes)
            for receipt in RoadStandingFaces.derive(report).receipts { session.addReceipt(receipt) }
            return .opened(session)
        } catch ExecutorRefusal.recordMissing {
            return .recordMissing
        } catch FileKeyFileStoreLeaf.KeyFileStoreError.unreadableLiveKeyFile {
            return .unreadableLiveKeyFile
        } catch {
            return .failed(error)
        }
    }

    /// After unlock (and the settle): `assess`'s repairs, a few passes as the world runs them. A repair that
    /// fails never blocks the open (it re-runs at the next open). Read-only in a hosted test run: the
    /// assessment is read for the report, nothing runs.
    static func repairPasses(
        _ ctx: RoadContext, _ executor: ProtectionExecutor, _ library: inout UnlockedLibrary,
        _ report: inout RoadOpenReport
    ) {
        var acts: [OwedAct] = []
        defer { report.acts = acts }
        for pass in 0..<4 {
            guard let facts = try? ctx.system.facts(session: ctx.session, unlocked: library) else { break }
            let assessment = assess(facts)
            report.faults = assessment.faults
            for act in assessment.acts where !acts.contains(act) { acts.append(act) }
            guard ctx.writes, pass < 3, !assessment.repairs.isEmpty else { break }
            do {
                let ran = try executor.runRepairs(assessment.repairs, on: &library)
                report.repairsDone += ran.done
                report.repairsSkipped += ran.skipped
                if ran.done.isEmpty { break }
            } catch {
                log("road: a repair failed — \(String(describing: error))")
                break
            }
        }
    }

    /// ONE Diagnostics line per open (the walk reads it — `log show … category == "protection"`): what the
    /// library and this Mac hold now, by count and eight-character name only — never key material.
    static func logSummary(_ ctx: RoadContext, _ library: UnlockedLibrary, _ report: RoadOpenReport, how: String) {
        let facts = try? ctx.system.facts(session: ctx.session, unlocked: library)
        let silent = facts.map { String($0.custody.filter { $0.itemClass == .silent }.count) } ?? "?"
        let touch = facts.map { String($0.custody.filter { $0.itemClass == .touchid }.count) } ?? "?"
        let apple = facts.map { $0.appleKeys.readable.map { String($0.prefix(8)) }.sorted().joined(separator: ",") } ?? "?"
        let memory = facts.map { String($0.rememberedLibraryIDs.count) } ?? "?"
        let roads = library.keyFile.map { $0.roads.map(\.rawValue).sorted().joined(separator: ",") } ?? "none"
        let libraryID = String((library.record?.libraryID ?? "none").prefix(8))
        let repairs = report.repairsDone.map { String(String(describing: $0).prefix(32)) }.joined(separator: ",")
        log("road: \(how) — library \(libraryID) key \(StoreKeyEnvelope.shortFingerprint(library.fingerprint)) "
            + "device \(library.section.deviceID.prefix(8)); custody silent \(silent) touchid \(touch); Apple keys "
            + "readable [\(apple)]; memory items \(memory); live key file roads [\(roads)]; notice "
            + "\(report.notice != nil); repairs [\(repairs)]; faults \(report.faults.count); acts \(report.acts.count); "
            + "settle \(report.settle ?? "-")")
    }

    // MARK: - Words for the refusals

    static func sentence(for error: RecoveryPhraseError) -> String {
        switch error {
        case .invalidWordCount(let count): return ProtectionWords.wordsWrongCount(count)
        case .unknownWord(let word): return ProtectionWords.wordsUnknownWord(word)
        case .checksumMismatch: return ProtectionWords.wordsChecksum
        default: return ProtectionWords.wordsDoNotOpen
        }
    }

    /// The typed roads the library's key files carry — the lobby's `typed` plus the mirror's and the catalogued
    /// files' of the library (the live file's ID, else every library this Mac remembers).
    static func offeredTyped(_ ctx: RoadContext, facts: ProtectionFacts) -> Set<TypedRoad> {
        var roads = AssessRules.lobby(facts).typed
        let live = facts.catalog.liveKeyFile?.document
        let libraries = live.map { Set([$0.libraryID]) } ?? facts.rememberedLibraryIDs
        for file in heldKeyFiles(ctx, facts: facts) where libraries.isEmpty || libraries.contains(file.libraryID) {
            if file.passphrase != nil { roads.insert(.passphrase) }
            if file.opensWithTheWords { roads.insert(.words) }
        }
        return roads
    }
}

// MARK: - The bootstrap's inputs (VX-306 U1b)

/// What the new road needs from a bootstrap: the protection system (composed per open on the main actor —
/// `ProtectionSystem.deviceName` reads the device on the main actor), the sign-in, whether it may write, and —
/// under a test — the opener that takes the key in hand.
nonisolated struct RoadInputs: Sendable {
    let makeSystem: @MainActor @Sendable () -> ProtectionSystem?
    let sessionFact: @Sendable () -> SessionFact
    let writes: Bool
    let open: (@Sendable (StoreKey) -> Result<AppDatabase, AppDatabase.StoreOpenError>)?

    /// Production: the variant's slot and far folder; the scoped sign-in (read off the main actor, a read); and
    /// READ-ONLY in a hosted test run (the test host is the dev-store app — `KeychainTestTripwire`).
    static func live(variant: AppDatabase.StoreVariant) -> RoadInputs {
        let scope = variant.rawValue
        return RoadInputs(
            makeSystem: { try? ProtectionSystem.live(variant: variant) },
            sessionFact: {
                KeychainAuthStorage.load(service: KeychainAuthStorage.variorumService, scope: scope)
                    .map { SessionFact.signedIn(accountID: $0.userID, email: $0.email) } ?? .signedOut
            },
            writes: !KeychainTestTripwire.armed,
            open: nil)
    }

    static func test(_ harness: ProtectionRoadTestHarness) -> RoadInputs {
        let system = harness.system
        let session = harness.session
        return RoadInputs(
            makeSystem: { system }, sessionFact: { session }, writes: harness.writes, open: harness.open)
    }

    @MainActor func compose() -> ComposedRoad? {
        makeSystem().map { ComposedRoad(system: $0, sessionFact: sessionFact, writes: writes, open: open) }
    }
}

/// The road for one open.
nonisolated struct ComposedRoad: Sendable {
    let system: ProtectionSystem
    let sessionFact: @Sendable () -> SessionFact
    let writes: Bool
    let open: (@Sendable (StoreKey) -> Result<AppDatabase, AppDatabase.StoreOpenError>)?

    /// The road's context — the sign-in read now (off the main actor: the road's callers are detached).
    func context() -> RoadContext { RoadContext(system: system, session: sessionFact(), writes: writes) }
}

/// TEST-ONLY: a new-road bootstrap over a temp slot and a throwaway scope (`AppBootstrap(testOpener:…,
/// protectionRoad:)`) — the system, the sign-in, and the opener that opens the temp slot with the key in hand.
struct ProtectionRoadTestHarness {
    var system: ProtectionSystem
    var session: SessionFact = .signedOut
    var writes = true
    var open: @Sendable (StoreKey) -> Result<AppDatabase, AppDatabase.StoreOpenError>
}
