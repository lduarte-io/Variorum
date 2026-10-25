//
//  ProtectionOpenRoad.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1b — THE NEW OPEN ROAD, off the main actor (`notes/plans/vx-306-castle-open-road.md` §2 U1b; the
//  contract `notes/CastleRules.md`). Since VX-329 U1 (the release switch) the ONLY open road, in every build — the
//  bootstrap's `routeAndOpen` reaches it for every store. Nothing here decides: the gatherer's facts go to `assess`, its
//  `LaunchVerdict` routes, every road verifies itself against the library in the slot, and the executor is the
//  one thing that writes.
//
//    - `.startFresh` → `createLibrary(passphrase: nil)` (rule 2: the twelve words at birth, shown once on the
//      card; rule 3: the passphrase is asked later) → the card, then the open.
//    - `.libraryMissing` → today's three-door face (unchanged this unit).
//    - `.preDesignStore` (VX-329 U4 — rule 26: a store with an older Variorum's key file beside it and none of this
//      design's) → the lobby's facts with NO road tried on the store; the face is her pre-design face.
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
    /// VX-307 U2c — VX-414: the place beside the library held NO key file when the search ran (the library's own
    /// `keyFile` nil after the repairs) — the offer then opens with her U2-7 variant, not *… doesn't open it.*
    var besideIsEmpty = false
    /// What the settle did (a word for Diagnostics), or why it could not.
    var settle: String?
    /// VX-308 U2 — VX-107: a FOLLOW the settle finished (resumed from its plan, or finished from the record) — its kind
    /// read from durable facts only (`RoadSettledFollow.kind`), so the open says the follow's Done with its other-device
    /// sentence however many crashes came between the press and this open. nil: no follow settled here.
    var settledFollow: FollowKind?
    /// VX-529 unit 2 — what the lobby's vault road landed in its press (the pair catch-up, or the E6 heal) — the account
    /// section's DURABLE notice, marked by `RoadStandingModel.make` like a settled follow's. nil: nothing landed there.
    var lobbyNotice: FollowDoneNotice?
}

/// VX-308 U2 — VX-107: THE FOLLOW A SETTLE FINISHED, by kind, from DURABLE facts — the act in flight as the unlock read it
/// from the record (sealed in the library: its act and the library's mode when it began), the settle's outcome (its act),
/// and the record's mode after — exactly the reading the core's own plan-less finish makes (`FollowProgram
/// .finishingSteps`: `fromKind` against the record's mode). Never the outcome's notices (a resume's outcome carries only
/// the notices of the steps THAT run ran — `.followedOutOfCastle` lives in the `memory` step, so a crash after it loses
/// it: VX-107's class) and never this process's memory.
nonisolated enum RoadSettledFollow {
    static func kind(_ settle: SettleOutcome, inFlight: ActInFlight?, modeAfter: ProtectionMode?) -> FollowKind? {
        let outcome: ActOutcome
        switch settle {
        case .resumed(let finished), .finishedFromRecord(let finished): outcome = finished
        case .nothingInFlight, .rolledBack: return nil
        }
        guard outcome.act == .follow, let inFlight, inFlight.act == .follow else { return nil }
        // VX-529 unit 2 (scope 2): a follow whose act in flight names NO new key is the PAIR catch-up — every other follow
        // mints its new key at its press (the core's own reading, `FollowProgram.finishingSteps`). Its halves are no durable
        // fact (the plan carries none — S-3), so the halves-unknown form; never "the keys changed".
        if inFlight.toFingerprint == nil { return .pairChanged(passphrase: false, words: false) }
        guard let from = inFlight.fromKind, let to = modeAfter else { return nil }
        switch (from, to) {
        case (.standard, .castle): return .intoCastle
        case (.castle, .standard): return .intoStandard
        default: return .keysReplaced
        }
    }
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
        case .preDesignStore:
            // VX-329 U4 — RULE 26: a store from before this design. No road is tried on it (this build has no reader for
            // it, and nothing here reads it); the lobby's face says so in her words (`ProtectionLobbyFace.preDesignStore`).
            return .lobby(lobby)
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
        // VX-329 U4 — THE RULING: the resume and the stale-staging sweep run on the creation road too (an interrupted
        // whole set-aside's remainder leaves the slot before anything is made beside it).
        finishAnInterruptedSetAside(ctx.system.places)
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

    /// A FACE's *Start a New Library* — the missing face (K5's record-less store among the states it shows) and rule
    /// 27's face (VX-306 ladder round 1, m1): whatever stands in the slot steps aside first, never written over — a
    /// library no road here opens moves WHOLE, with its sidecars and its key file (P-VX306-U2-5), else a missing
    /// library's key file alone (P-VX306-U1b-3) — then the creation and its words. Before round 1 the missing face set
    /// the key file aside only when the slot was EMPTY, so over a record-less store its one act met the creation's
    /// no-clobber belt ("a library is already in the slot") and could never succeed.
    static func startNewLibraryFromAFace(_ ctx: RoadContext) async -> RoadRoute {
        await create(ctx, setAsideLiveKeyFile: true, setAsideUnopenableLibrary: true)
    }

    /// VX-329 U4 — her pre-design face's *Start fresh…*, on her confirm's yes (the plan's §6d; THE RULING (a)): the slot
    /// re-read (the fact must still hold — names only; a stale face moves nothing), the library from before this design
    /// set aside WHOLE (`setAsidePreDesignLibraryWholeFor` — its key files, sidecars and hold with it; the resume first;
    /// no byte read), then the creation exactly as an empty slot's — the calm first open. Nothing is created unless the
    /// set-aside landed. PROVISIONAL P-VX329-U4-6: a refusal says the creation's own sentence (her words have none).
    static func startFreshOverAPreDesignStore(_ ctx: RoadContext) async -> RoadRoute {
        guard ctx.writes else { return .failed(ProtectionWords.testRunNeverCreates) }
        guard slotHoldsAPreDesignStore(ctx.system.places) else {
            log("road: Start fresh refused — the slot no longer holds a store from before this design (nothing moved)")
            return .failed(ProtectionWords.couldNotCreate)
        }
        do {
            try setAsidePreDesignLibraryWholeFor(ctx.system.places, carryingHold: true)
        } catch {
            log("road: Start fresh refused — the library from before this design could not be set aside whole "
                + "(\(String(describing: error)))")
            return .failed(ProtectionWords.couldNotCreate)
        }
        return await create(ctx, setAsideLiveKeyFile: false)
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

    /// A typed secret on every key file this Mac holds for the library — each key verified against the slot. VX-501: a
    /// library it opens that is bound to an account in Castle loads that account's sync keys for the session from the vault
    /// with the secret just typed (`loadSyncKeysAfterTypedUnlock` — the passphrase's derived key reused, never re-derived),
    /// waiting at most `syncKeysWithin` for the vault before the open goes on.
    static func openTyped(
        _ ctx: RoadContext, secret: ProtectionSecret, syncKeysWithin bound: Duration = typedUnlockVaultBound
    ) async -> RoadAttempt {
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
        let typedRoad = typedCandidatesAndKeys(secret, files: files, floor: ctx.system.floor)
        var typed = TypedSecrets.none
        switch secret {
        case .passphrase(let passphrase): typed = TypedSecrets(passphrase: passphrase)
        case .words(let words): typed = TypedSecrets(words: words)
        case .passphraseKey: break
        }
        switch await open(ctx, candidates: typedRoad.keys, typed: typed) {
        case .opened(let session):
            // VX-501: the typed twin of the Touch ID load — off the main actor (the lobby's press is detached), after the
            // open, before the app's open goes on (bounded; never hostage).
            await loadSyncKeysAfterTypedUnlock(session, signIn: ctx.session, typed: typedRoad.unlock, within: bound)
            return .opened(session)
        case .recordMissing: return .recordMissing
        case .unreadableLiveKeyFile: return .refused(ProtectionWords.liveKeyFileUnreadable)
        case .failed(let error):
            log("road: a typed open failed — \(String(describing: error))")
            return .refused(ProtectionWords.somethingWentWrong)
        case .noneOpens:
            if case .words = secret { return .refused(ProtectionWords.wordsDoNotOpen) }
            // VX-529 unit 2 — R-529-1: every local road refused the typed passphrase; signed in, it earns ONE bounded
            // vault read (`openThroughTheVault`). nil: nothing the read proves — today's refusal, byte for byte.
            if case .passphrase(let text) = secret,
               let attempt = await openThroughTheVault(ctx, passphrase: text, files: files, within: bound) {
                return attempt
            }
            return .refused(ProtectionWords.passphraseDoesNotOpen)
        }
    }

    /// **VX-529 unit 2 — R-529-1 (her pick: "Open through the vault"): THE LOBBY'S VAULT ROAD** (`notes/plans/fixes/
    /// vx-529-pair-catchup.md`, scope 3 and its guardrails). Reached only from `openTyped`, only for a PASSPHRASE that every
    /// local road refused, only on a writing road (a hosted test run reads nothing) and only while someone is signed in:
    /// ONE bounded read of the signed-in account's vault (VX-501's race, the same bound), then the core's pure decision
    /// (`VaultRoad.answer` — the passphrase under the VAULT's descriptor opening its master, the master opening a held key
    /// file's master lock). The key it finds goes through the ORDINARY open (the slot verifies it; the settle and the repairs
    /// as at every open) — nothing is written before that unlock; then the catch-up lands with the typed secret in hand
    /// (`catchUpThroughTheVault`). Where it opens nothing it says only what the read proves (the account's passphrase changed
    /// elsewhere, named; E6's "not the account's"); nil — offline, a slow server, no vault, no proof, or a key the slot
    /// refuses — keeps today's refusal byte for byte, every byte as it was.
    static func openThroughTheVault(
        _ ctx: RoadContext, passphrase text: String, files: [KeyFile], within bound: Duration
    ) async -> RoadAttempt? {
        guard ctx.writes, let account = ctx.session.accountID else { return nil }
        let snapshot: VaultSnapshot
        switch await boundedVaultRead(ctx.system.leaves.vault, accountID: account, within: bound) {
        case .read(let read?):
            snapshot = read
        case .read(nil):
            log("road: the vault road found no vault for the signed-in account — today's refusal")
            return nil
        case .failed(let error):
            log("road: the vault road's read failed — \(String(describing: error)); today's refusal, nothing written")
            return nil
        case .timedOut:
            log("road: the vault road's read took longer than \(bound) — today's refusal, nothing written")
            return nil
        }
        let live = (try? ctx.system.leaves.keyFiles.readLiveKeyFile()) ?? nil
        switch VaultRoad.answer(text, vault: snapshot, files: files, live: live, floor: ctx.system.floor) {
        case .nothingToSay:
            log("road: the vault road proves nothing for this passphrase — today's refusal")
            return nil
        case .notTheAccountsPassphrase:
            return .refused(ProtectionWords.passphraseDoesNotOpenAccount)
        case .passphraseChangedElsewhere(let device, let day):
            return .refused(ProtectionWords.lobbyPassphraseChangedElsewhere(
                device: device, day: day.map { ProtectionWords.day($0) }))
        case .opens(let key, let derived):
            switch await open(ctx, candidates: [key], typed: TypedSecrets(passphrase: text)) {
            case .opened(let session):
                log("road: the account's passphrase opened the library through the vault (R-529-1)")
                await catchUpThroughTheVault(
                    session, account: account, passphrase: text, derived: derived, vault: snapshot, signIn: ctx.session,
                    within: bound)
                return .opened(session)
            case .recordMissing:
                return .recordMissing
            case .unreadableLiveKeyFile:
                return .refused(ProtectionWords.liveKeyFileUnreadable)
            case .noneOpens:
                log("road: the vault road's key does not open the library in the slot — today's refusal")
                return nil
            case .failed(let error):
                log("road: the vault road's open failed — \(String(describing: error))")
                return .refused(ProtectionWords.somethingWentWrong)
            }
        }
    }

    /// **VX-529 unit 2 — the vault road's catch-up, in the same press, with the typed secret in hand** (never a quiet road):
    /// on the session's one-act lock, a pair follow owed against the vault just read ⇒ the core's pair catch-up (unit 1's act
    /// — its own fresh read re-verifies, E4); then a synced file still without a passphrase lock (E6) ⇒ the heal
    /// (P-VX529-4, `landTheAccountsPassphraseLock` over the read in hand). Either failing leaves the library OPEN — never
    /// hostage; the follow stays owed in Settings — and is said in the log. What landed is the account section's DURABLE
    /// notice (VX-457's mark, written by `RoadStandingModel.make` from `RoadOpenReport.lobbyNotice`). Then the sync keys
    /// load as at every typed unlock (VX-501) — over the read in hand (the catch-up held them already where it ran).
    static func catchUpThroughTheVault(
        _ session: ProtectionRoadSession, account: String, passphrase text: String, derived: PassphraseKey,
        vault snapshot: VaultSnapshot, signIn: SessionFact, within bound: Duration
    ) async {
        guard session.writes, session.library.record?.account == account else {
            log("road: the vault road opened a library that doesn't name the signed-in account — no catch-up")
            return
        }
        guard session.beginAct() else { return }
        let executor = session.executor
        var library = session.library
        var notice: FollowDoneNotice?
        let current = library.keyFile.flatMap { $0.fingerprint == library.fingerprint ? $0 : nil }
        if let pair = AssessRules.pairFollow(current, snapshot.reading) {
            do {
                _ = try await executor.follow(&library, kind: pair, typed: TypedSecrets(passphrase: text))
                notice = .followed(pair)
                log("road: the vault road's catch-up landed — the key file re-locked to the account's pair")
            } catch {
                log("road: the vault road opened the library; its catch-up did not land — \(String(describing: error)); "
                    + "the follow stays owed")
            }
            session.library = library
        }
        if library.record?.account != nil, library.keyFile?.passphrase == nil {
            do {
                if try await executor.landTheAccountsPassphraseLock(
                    &library, passphrase: text, vault: executor.freshVaults[account] ?? snapshot) {
                    notice = notice ?? .passphraseLanded
                }
            } catch {
                log("road: the vault road opened the library; the heal did not land — \(String(describing: error))")
            }
            session.library = library
        }
        session.endAct()
        if let notice {
            var report = session.report
            report.lobbyNotice = notice
            session.report = report
        }
        await loadSyncKeysAfterTypedUnlock(
            session, signIn: signIn, typed: .passphrase([derived]), within: bound,
            vault: executor.freshVaults[account] ?? snapshot)
    }

    /// THE PRESS (VX-310): the Touch ID item for the current key (the live key file's), else the first one this
    /// scope lists — read through the custody leaf's Touch ID read, which prompts. Never pressed while Touch ID is only
    /// unusable for now (the face says why first). VX-487 (b): the press the read evaluated is kept for THIS call only —
    /// a library it opens that is bound to an account loads that account's sync keys into session memory riding it
    /// (`loadSyncKeysForTheSession` — one press, never two prompts) — and ended on every path.
    static func pressTouchID(_ ctx: RoadContext, facts: ProtectionFacts?) async -> RoadAttempt {
        let custody = ctx.system.custody
        let touchItems = (facts?.custody ?? []).filter { $0.itemClass == .touchid }
        let hint = facts?.slotFingerprintHint
        guard let item = touchItems.first(where: { $0.fingerprint == hint }) ?? touchItems.first else {
            return .touchIDNotOpened(press: nil, biometry: ctx.system.leaves.biometry.biometry(), itemGone: true)
        }
        var key: StoreKey?
        var evaluated: TouchIDPressContext?
        do {
            if let handing = custody as? TouchIDPressHanding {
                (key, evaluated) = try handing.readTouchIDCustody(fingerprint: item.fingerprint)
            } else {
                key = try custody.readCustody(fingerprint: item.fingerprint, itemClass: .touchid)
            }
        } catch {
            log("road: the Touch ID read failed — \(String(describing: error))")
            key = nil
        }
        // VX-487 (b): the press ends with this call, whatever the open does next.
        defer { evaluated?.invalidate() }
        let press = (custody as? KeychainCustodyLeaf)?.lastPress
        guard let key else {
            // No key, no recorded press: the item was not there to press (the probe found none).
            let gone = press == nil
            return .touchIDNotOpened(press: press, biometry: ctx.system.leaves.biometry.biometry(), itemGone: gone)
        }
        switch await open(ctx, candidates: [key], typed: .none) {
        case .opened(let session):
            loadSyncKeysForTheSession(session, riding: evaluated)
            return .opened(session)
        case .recordMissing: return .recordMissing
        case .unreadableLiveKeyFile: return .refused(ProtectionWords.liveKeyFileUnreadable)
        case .noneOpens, .failed:
            // The item's key opens nothing here: failed on an item that exists (the item is the final word).
            return .touchIDNotOpened(
                press: .failedOnExistingItem, biometry: ctx.system.leaves.biometry.biometry(), itemGone: false)
        }
    }

    /// **VX-487 (b) — THE TOUCH ID UNLOCK LOADS THE ACCOUNT'S SYNC KEYS FOR THE SESSION.** Under Castle with Touch ID the
    /// account's keys live in a Touch ID item (rule 15's custody), which the engine's provider never reads (a press per
    /// round is nobody's wish — P-VX307-U1-3: "rounds run while an act or unlock has loaded session memory"). So the
    /// press that opened a library whose RECORD names an account (the provider's own truth) reads that account's item
    /// riding the same press — never a second prompt — and holds the keys in session memory (gone at a relock or a
    /// crash). NEVER HOSTAGE: no press to ride, no item, or a read that fails is said in the log and the library opens all
    /// the same; the row says locked until an act or the next Touch ID unlock loads them. An unbound library reads
    /// nothing. (The typed roads' twin is `loadSyncKeysAfterTypedUnlock` — VX-501.)
    static func loadSyncKeysForTheSession(_ session: ProtectionRoadSession, riding press: TouchIDPressContext?) {
        guard let account = session.library.record?.account else { return }
        guard let press, !press.isInvalidated else {
            log("road: the Touch ID unlock opened a synced library with no press to ride — its sync keys stay unloaded "
                + "until an act or the next Touch ID unlock")
            return
        }
        guard let leaf = session.system.leaves.syncKeys as? TouchIDPressRiding else {
            log("road: the Touch ID unlock opened a synced library whose sync-keys leaf cannot ride a press — its sync "
                + "keys stay unloaded until an act or the next Touch ID unlock")
            return
        }
        do {
            guard let keys = try leaf.readSyncKeys(accountID: account, riding: press) else {
                log("road: the Touch ID unlock's sync-keys read found no readable Touch ID item for the account — "
                    + "nothing loaded")
                return
            }
            session.system.leaves.syncKeys.holdInSession(keys, accountID: account)
            log("road: the Touch ID unlock loaded the account's sync keys for the session (sync key "
                + "\(keys.rowKeyID.prefix(8)))")
        } catch {
            log("road: the Touch ID unlock's sync-keys read failed — \(String(describing: error)); the library opens, "
                + "its sync keys stay unloaded")
        }
    }

    /// What a typed unlock's secret leaves in hand for the sync-keys load: the passphrase's DERIVED keys (one per descriptor
    /// the open derived under — the Argon2id already paid, never paid twice), or the words. Never stored; gone with the call.
    enum TypedUnlockSecret: Sendable, CustomStringConvertible {
        case passphrase([PassphraseKey])
        case words([String])
        case nothing

        var description: String { "TypedUnlockSecret(redacted)" }
    }

    /// How long a typed unlock waits for the account's vault before the open goes on without the sync keys (VX-501 —
    /// never hostage: a slow or unreachable server costs the unlock at most this, and a read that answers later is
    /// discarded, so no hold can land after the open moved on). PROVISIONAL P-VX510-B2-1 (the record's unit B2).
    static let typedUnlockVaultBound: Duration = .seconds(10)

    /// **VX-510 D-B4 — VX-501: THE TYPED CASTLE UNLOCK LOADS THE ACCOUNT'S SYNC KEYS FOR THE SESSION** (her R-494-4: "a typed
    /// unlock should hold sync keys in session until lock"; R-510-11). The typed twin of VX-487 (b)'s Touch ID load: under
    /// Castle the engine's provider reads session memory and the silent item only (P-VX307-U1-3) — Castle keeps no silent
    /// item (rule 9) and Always ask no item at all — so a library opened by its passphrase or its words now derives the
    /// account's keys from the VAULT with the secret just typed (the key doors' own derivation, `holdSyncKeysForTheSession`'s
    /// two calls: the master from the typed secret against the vault, then `keys(master:)`) and holds them in session memory
    /// (gone at a relock — `ProtectionRoadLock.dropSessionMemory` — or a crash). The passphrase's key is the one the open
    /// derived (the account's lock carries the vault's descriptor — `joinKeyFile`), never derived again; the words' wrap key
    /// is derived once here (the BIP-39 seed, the open's own derivations being the core's). The vault: the one this session
    /// already read (an act's resume at the settle), else ONE read, bounded (`typedUnlockVaultBound`). Only keys this library
    /// FOLLOWS are held (the record's `accountRowKeyID` — exactly what the Touch ID item would hold; an account that moved
    /// since leaves the follow to load them). NEVER HOSTAGE: no account, Standard (its silent item serves — nothing read),
    /// signed out or into another account, offline, a slow server, a secret that opens the library but not the vault, a moved
    /// account — each is said in the log and the library opens all the same; the row says locked as before. A read-only road
    /// (a hosted test run) reads nothing. No Touch ID item is read (a prompt), nothing is written to disk.
    /// VX-529 unit 2 — `vault`: a read the caller holds from this same press (the lobby's vault road — its one bounded read);
    /// nil: as before.
    static func loadSyncKeysAfterTypedUnlock(
        _ session: ProtectionRoadSession, signIn: SessionFact, typed: TypedUnlockSecret,
        within bound: Duration = typedUnlockVaultBound, vault given: VaultSnapshot? = nil
    ) async {
        guard session.writes, let record = session.library.record, let account = record.account else { return }
        guard record.mode == .castle else { return }
        let leaf = session.system.leaves.syncKeys
        if let held = leaf.sessionSyncKeys(accountID: account)
            ?? ((try? leaf.readSyncKeys(accountID: account, itemClass: .silent)) ?? nil),
           held.rowKeyID == record.accountRowKeyID {
            log("road: the typed unlock found the account's sync keys already loaded — nothing read")
            return
        }
        guard signIn.accountID == account else {
            log("road: the typed unlock opened a synced library while signed out or into another account — its sync keys "
                + "stay unloaded (nothing read)")
            return
        }
        let snapshot: VaultSnapshot
        if let fresh = given ?? session.executor.freshVaults[account] {
            snapshot = fresh
        } else {
            switch await boundedVaultRead(session.system.leaves.vault, accountID: account, within: bound) {
            case .read(let read?):
                snapshot = read
            case .read(nil):
                log("road: the typed unlock found no vault for the library's account — nothing loaded")
                return
            case .failed(let error):
                log("road: the typed unlock's vault read failed — \(String(describing: error)); the library opens, its "
                    + "sync keys stay unloaded")
                return
            case .timedOut:
                log("road: the typed unlock's vault read took longer than \(bound) — the library opens, its sync keys stay "
                    + "unloaded (a later answer is discarded)")
                return
            }
        }
        let master: SymmetricKey?
        switch typed {
        case .passphrase(let derived):
            master = derived.first { $0.kdf == snapshot.vault.kdf }
                .flatMap { snapshot.vault.master(passphrase: $0, words: nil) }
        case .words(let words):
            master = (try? WordsKey.derive(words)).flatMap { snapshot.vault.master(passphrase: nil, words: $0) }
        case .nothing:
            master = nil
        }
        guard let master else {
            log("road: the typed secret opens the library but not the account's vault (changed elsewhere?) — nothing "
                + "loaded; a follow or a key door loads them")
            return
        }
        guard let keys = try? snapshot.vault.keys(master: master) else {
            log("road: the typed unlock reached a master that is not the vault's — nothing loaded")
            return
        }
        guard keys.rowKeyID == record.accountRowKeyID else {
            log("road: the account's sync key moved since this library followed — nothing loaded; the follow loads them")
            return
        }
        leaf.holdInSession(keys, accountID: account)
        log("road: the typed unlock loaded the account's sync keys for the session (sync key \(keys.rowKeyID.prefix(8)))")
    }

    /// One vault read, answered within `bound` or not at all: the first of the read and the timer wins; the loser is
    /// cancelled and its answer, should one still come, is dropped (the caller holds nothing it did not get in time).
    enum BoundedVaultRead: Sendable {
        case read(VaultSnapshot?)
        case failed(any Error)
        case timedOut
    }

    static func boundedVaultRead(_ leaf: any VaultLeaf, accountID: String, within bound: Duration) async -> BoundedVaultRead {
        nonisolated(unsafe) let leaf = leaf
        return await withCheckedContinuation { continuation in
            let race = BoundedRace(continuation)
            race.add(Task {
                do {
                    race.finish(.read(try await leaf.fetchVault(accountID: accountID)))
                } catch {
                    race.finish(.failed(error))
                }
            })
            race.add(Task {
                try? await Task.sleep(for: bound)
                race.finish(.timedOut)
            })
        }
    }

    /// The race's one answer: the first `finish` resumes the caller and cancels every racer; later ones do nothing.
    private final class BoundedRace: @unchecked Sendable {
        private let lock = NSLock()
        private var continuation: CheckedContinuation<BoundedVaultRead, Never>?
        private var racers: [Task<Void, Never>] = []

        init(_ continuation: CheckedContinuation<BoundedVaultRead, Never>) { self.continuation = continuation }

        func add(_ racer: Task<Void, Never>) {
            let answered = lock.withLock { () -> Bool in
                guard continuation != nil else { return true }
                racers.append(racer)
                return false
            }
            if answered { racer.cancel() }
        }

        func finish(_ answer: BoundedVaultRead) {
            let (waiting, losers) = lock.withLock { () -> (CheckedContinuation<BoundedVaultRead, Never>?, [Task<Void, Never>]) in
                defer {
                    continuation = nil
                    racers = []
                }
                return (continuation, racers)
            }
            guard let waiting else { return }
            losers.forEach { $0.cancel() }
            waiting.resume(returning: answer)
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
        typedCandidatesAndKeys(secret, files: files, floor: floor).keys
    }

    /// `typedCandidates`, with what the derivation left in hand for the sync-keys load (VX-501): the passphrase's derived
    /// keys, one per descriptor — so the load never derives a second time — or the words.
    static func typedCandidatesAndKeys(
        _ secret: ProtectionSecret, files: [KeyFile], floor: PassphraseKDF.Floor
    ) -> (keys: [StoreKey], unlock: TypedUnlockSecret) {
        var keys: [StoreKey] = []
        func add(_ key: StoreKey?) { if let key, !keys.contains(key) { keys.append(key) } }
        switch secret {
        case .passphrase(let typed):
            guard !typed.isEmpty else { return ([], .nothing) }
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
            return (keys, .passphrase(derived))
        case .words(let words):
            for file in files { add(try? file.open(secret, floor: floor)) }
            return (keys, .words(words))
        case .passphraseKey(let derived):
            for file in files { add(try? file.open(secret, floor: floor)) }
            return (keys, .passphrase([derived]))
        }
    }

    /// Every candidate expanded through the history of each file whose current key it is (rule 4).
    static func expand(_ candidates: [StoreKey], files: [KeyFile]) -> [StoreKey] {
        var keys = candidates
        var index = 0
        while index < keys.count {
            let key = keys[index]
            index += 1
            let fingerprint = KeyFingerprint.of(key)
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
            // VX-107: the act in flight as the record names it, read BEFORE the settle ends it.
            let inFlight = unlocked.section.actInFlight
            if ctx.writes {
                // RULE 20: an act in flight resumes or rolls back; neither failing blocks the open (the world's
                // own reading — the lobby opens the library all the same, the act stays owed).
                do {
                    let settled = try await executor.settle(&unlocked, typed: typed)
                    report.settle = String(describing: settled)
                    report.settledFollow = RoadSettledFollow.kind(
                        settled, inFlight: inFlight, modeAfter: unlocked.record?.mode)
                } catch {
                    report.settle = "could not settle: \(String(describing: error))"
                    log("road: the act in flight could not settle now — \(String(describing: error))")
                }
            } else {
                report.settle = "read-only (a hosted test run)"
            }
            repairPasses(ctx, executor, &unlocked, &report)
            report.keyFileSearch = searchIfOwed(ctx, executor, unlocked, report)
            report.besideIsEmpty = unlocked.keyFile == nil
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
            let facts: ProtectionFacts
            do {
                facts = try ctx.system.facts(session: ctx.session, unlocked: library)
            } catch {
                // Said, like every other throwing edge of the road (the ladder's round-1 NIT 2): the open goes on, the
                // repairs run again at the next open.
                log("road: the open's facts could not be read for its repairs (pass \(pass)) — \(String(describing: error))")
                break
            }
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
        log("road: \(how) — library \(libraryID) key \(KeyFingerprint.short(library.fingerprint)) "
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
    /// READ-ONLY in a hosted test run (the test host is the dev-store app — `KeychainTestTripwire`). VX-423: every
    /// system composed here rides `auth`, the process's one refresh authority (the bootstrap's) — its vault leaf never
    /// mints a session of its own. VX-487 F-M1-1: and over `syncKeys`, the process's one sync-keys leaf (the bootstrap's),
    /// so session memory held through one composed system survives into the next — a re-keying act's reopen composes a
    /// fresh system, and the act's hold must reach the reopened session the engine reads.
    static func live(variant: AppDatabase.StoreVariant, auth: AuthSession, syncKeys: any SyncKeysLeaf) -> RoadInputs {
        let scope = variant.rawValue
        nonisolated(unsafe) let syncKeys = syncKeys
        return RoadInputs(
            makeSystem: { try? ProtectionSystem.live(variant: variant, session: auth, syncKeys: syncKeys) },
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

/// TEST-ONLY: a bootstrap over a temp slot and a throwaway scope (`AppBootstrap(testStoreURL:protectionRoad:)` — VX-329
/// U1: required, the bootstrap's one road) — the system, the sign-in, and the opener that opens the temp slot with the
/// key in hand.
struct ProtectionRoadTestHarness {
    var system: ProtectionSystem
    var session: SessionFact = .signedOut
    var writes = true
    var open: @Sendable (StoreKey) -> Result<AppDatabase, AppDatabase.StoreOpenError>
}
