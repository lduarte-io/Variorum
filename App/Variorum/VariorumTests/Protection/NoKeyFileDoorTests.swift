//
//  NoKeyFileDoorTests.swift
//  VariorumTests — VX-308 U3 piece 4: VX-447 (her ruling, QUESTIONS #235: the no-key-file banner BECOMES THE DOOR —
//  record the words → a fresh key file → the backup follows) and F-U2-3 (the architect's ruling: a synced library's look
//  says, BEFORE minting, that new words replace the account's words everywhere), through the REAL road on planted leaves
//  (a temp slot, planted custody and memory, the planted vault — no keychain, no network; headless in the implementer's
//  harness too). Rule 27's after-open state is planted the way `ProtectionRule27FaceTests` plants it: the live key file
//  removed and this Mac's memory cleared, the silent item opening the library.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-308 U3 — VX-447: the no-key-file banner is the door; F-U2-3: the synced look says it first")
@MainActor
struct NoKeyFileDoorTests {
    /// Rule 27's after-open state on `road`: every key-file copy gone — beside the library, this Mac's memory, and any
    /// backup's pair (turning sync on took one) — the silent item opens the library.
    static func openedWithNoKeyFileAnywhere(_ road: PlantedRoad) async throws -> ProtectionRoadSession {
        try FileManager.default.removeItem(at: road.slot.places.liveKeyFile)
        road.memory.items = [:]
        if FileManager.default.fileExists(atPath: road.slot.places.backups.path) {
            try FileManager.default.removeItem(at: road.slot.places.backups)
        }
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context()) else {
            throw RoadWorld.RoadWorldError.notCreated
        }
        return session
    }

    /// The standing faces over `session`, their receipts collected (`signInNow`: the bootstrap's read of who is signed in).
    static func standing(
        _ session: ProtectionRoadSession, _ store: ThrowawayDefaults, signInNow: (@Sendable () -> SessionFact)? = nil
    ) -> (RoadStandingModel, Receipts) {
        let model = RoadStandingModel.make(
            session, ledger: PassphraseReminderLedger(defaults: store.defaults), snoozes: WordsCardSnoozes(),
            signInNow: signInNow)
        let receipts = Receipts()
        model.speak = { receipts.lines.append($0) }
        return (model, receipts)
    }

    @MainActor
    final class Receipts {
        var lines: [String] = []

        /// The backup follows OFF the main actor: wait for its one receipt (bounded).
        func awaitOne() async throws {
            for _ in 0..<500 where lines.isEmpty { try await Task.sleep(for: .milliseconds(10)) }
        }
    }

    /// The pairs this Mac's backups hold for `fingerprint` (the catalogue's read of `Backups/<library8>/<mac8>/`).
    static func pairKeyFiles(_ road: PlantedRoad, fingerprint: String) -> [KeyFile] {
        road.system().lister.catalog().keyFiles.filter { $0.role != .live && $0.fingerprint == fingerprint }
            .compactMap(\.document)
    }

    /// THE DOOR, UNSYNCED (Standard): the banner carries the act; its look mints at once — the record's stamp still says
    /// a passphrase (set before the file was lost) but no lock survives to verify one, so nothing is asked (R-U3-4); the
    /// core's VX-447 arm writes the FRESH key file the words lock (the key unchanged); the banner stands while the words
    /// are on screen; THE BACKUP FOLLOWS (rule 5's pair carrying the fresh file) with one receipt; the banner retires at
    /// the look's close; *Set a passphrase…* is offered again (rule 3's fact is "none" now); the next open finds no fault.
    /// RED ON OLD: the core refused (`secretMissing` → the look's "couldn't make your twelve words"), nothing written.
    @Test func theBannersDoorMintsAFreshKeyFileAndTheBackupFollows() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        #expect(await ProtectionOpenRoad.setFirstPassphrase(session: created, new: "set before the loss") == .set)
        let session = try await Self.openedWithNoKeyFileAnywhere(road)
        #expect(session.library.record?.passphraseSet == true, "the record's stamp, from before the loss")
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let (standing, receipts) = Self.standing(session, store)
        #expect(standing.faces.noKeyFileAnywhere == NoKeyFileAnywhere(accountRoad: false))
        #expect(standing.faces.noKeyFileDoor && standing.offersNoKeyFileDoor && standing.showsNoKeyFileBanner)
        #expect(!standing.offersSetPassphrase, "the stale stamp: the set row stays back until the file is remade")

        await standing.openNoKeyFileLook()
        let look = try #require(standing.noKeyFileLook)
        #expect(look.phase == .shown, "nothing asked: no lock is left to verify a passphrase — \(look.message ?? "")")
        #expect(!look.saysAccountWords)
        let fresh = try #require(try road.system().leaves.keyFiles.readLiveKeyFile(), "a fresh key file beside the library")
        #expect(fresh.fingerprint == created.library.fingerprint && session.key == created.key, "rule 6: the key unchanged")
        #expect(try fresh.open(words: look.words) == session.key, "the words she records open it")
        #expect(fresh.passphrase == nil && fresh.history.isEmpty)
        #expect(standing.keyFileRemade && !standing.offersNoKeyFileDoor)
        #expect(standing.showsNoKeyFileBanner, "the words are on screen in the banner — it stays")
        #expect(standing.offersSetPassphrase, "rule 3: no passphrase lock now — the set row is offered again")

        try await receipts.awaitOne()
        #expect(receipts.lines == [ProtectionWords.keyFileRemadeReceipt(backedUp: true)])
        #expect(Self.pairKeyFiles(road, fingerprint: fresh.fingerprint).contains(fresh),
                "rule 5's pair carries the fresh key file (rule 1: inside every backup)")

        look.writtenDown()
        look.close()
        #expect(!standing.showsNoKeyFileBanner, "the look closed over a remade file: the banner retires")
        #expect(standing.band?.offersWords == false, "recorded — the card's offer retires too")
        guard case .opened(let next) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the next open")
            return
        }
        #expect(!next.report.faults.contains { if case .noKeyFileAnywhere = $0 { return true } else { return false } },
                "\(next.report.faults)")
        #expect(RoadStandingFaces.derive(next.report).noKeyFileAnywhere == nil)
    }

    /// THE DOOR, SYNCED (F-U2c-5's flavor): the look asks the ACCOUNT's passphrase and says the account line first
    /// (F-U2-3); the core mints the fresh file with the account's passphrase lock and the master's copy, the vault's words
    /// change with it (rule 7); the pair follows.
    @Test func theSyncedBannersDoorAsksTheAccountsPassphraseFirstAndTheAccountsWordsChange() async throws {
        let (road, vault, _) = PlantedAccount.road()
        let (created, words) = try await road.created()
        let shown = try #require(ProtectionPaneRead.accountFaces(
            try await PlantedAccount.read(created, PlantedAccount.signedIn))?.turnOnSync.openDoor)
        let turned = await ProtectionAccountRoad.press(
            created, request: RoadAccountRequest(door: .turnOnSync, shown: shown,
                                                 typed: TypedSecrets(words: words, newPassphrase: PlantedAccount.passphrase)),
            signIn: PlantedAccount.signedIn, exportSwitch: nil)
        #expect(turned == .made(receipt: ProtectionWords.turnOnSyncReceipt))
        road.session = PlantedAccount.signedIn
        let session = try await Self.openedWithNoKeyFileAnywhere(road)
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let (standing, receipts) = Self.standing(session, store)
        #expect(standing.faces.noKeyFileAnywhere == NoKeyFileAnywhere(accountRoad: true) && standing.offersNoKeyFileDoor)

        await standing.openNoKeyFileLook()
        let look = try #require(standing.noKeyFileLook)
        #expect(look.phase == .asking && look.saysAccountWords, "asked first, the account line said — nothing minted yet")
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile() == nil)
        await look.submit(passphrase: PlantedAccount.passphrase)
        #expect(look.phase == .shown, "\(look.message ?? "")")
        let fresh = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(try fresh.open(words: look.words) == session.key)
        #expect(try fresh.open(passphrase: .passphrase(PlantedAccount.passphrase), floor: .relaxedForTests) == session.key)
        let account = try #require(vault.snapshot(PlantedAccount.account))
        #expect(fresh.master != nil && fresh.masterWordsCopy == account.vault.masterByWords)
        #expect(VaultModel.master(of: account.vault, passphrase: nil, words: try WordsKey.derive(look.words)) != nil,
                "rule 7: the account's words are the new words")
        #expect(VaultModel.master(of: account.vault, passphrase: nil, words: try WordsKey.derive(words)) == nil)
        try await receipts.awaitOne()
        #expect(receipts.lines == [ProtectionWords.keyFileRemadeReceipt(backedUp: true)])
    }

    /// The fault's SECOND arm — a STRAY in the live place (another key's file), nothing holding the library's own: her
    /// U2-7 banner stands with NO door (a mint would write over the stray — rule 21), and a press does nothing.
    @Test func aStrayBesideKeepsHerBannerWithNoDoor() async throws {
        let road = PlantedRoad()
        _ = try await road.created()
        try Plant.strayBeside(road)
        road.memory.items = [:]
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the silent item opens it")
            return
        }
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let (standing, _) = Self.standing(session, store)
        #expect(standing.faces.noKeyFileAnywhere != nil && !standing.faces.noKeyFileDoor)
        #expect(standing.showsNoKeyFileBanner && !standing.offersNoKeyFileDoor)
        let stray = try road.system().leaves.keyFiles.readLiveKeyFile()
        await standing.openNoKeyFileLook()
        #expect(standing.noKeyFileLook == nil, "no door, no look")
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile() == stray, "the stray untouched")
    }

    /// F-U2-3 through the real road on an everyday SYNCED library (its key file standing): the card's look asks the
    /// account's passphrase and says the account line BEFORE minting; *Show my twelve words* is the yes; the account's
    /// words change with the library's (rule 7). Unsynced, the look is unchanged (no line).
    @Test func aSyncedLibrarysLookSaysTheAccountLineBeforeMinting() async throws {
        let (road, vault, _) = PlantedAccount.road()
        let (session, words) = try await road.created()
        let shown = try #require(ProtectionPaneRead.accountFaces(
            try await PlantedAccount.read(session, PlantedAccount.signedIn))?.turnOnSync.openDoor)
        _ = await ProtectionAccountRoad.press(
            session, request: RoadAccountRequest(door: .turnOnSync, shown: shown,
                                                 typed: TypedSecrets(words: words, newPassphrase: PlantedAccount.passphrase)),
            signIn: PlantedAccount.signedIn, exportSwitch: nil)
        let store = ThrowawayDefaults()
        defer { store.purge() }
        // R-2 (R-U3-5): the executor carries a stale sign-in (an open made signed out); the look's mint adopts the
        // sign-in NOW from the bootstrap's read.
        session.executor.configuration.session = .signedOut
        let signedIn = PlantedAccount.signedIn
        let (standing, _) = Self.standing(session, store, signInNow: { signedIn })
        let band = try #require(standing.band)
        await band.look.open()
        #expect(band.look.phase == .asking && band.look.saysAccountWords)
        band.look.cancel()
        #expect(band.look.phase == .closed && !band.look.saysAccountWords, "Cancel: nothing minted, the line goes")
        let before = try #require(vault.snapshot(PlantedAccount.account))
        #expect(VaultModel.master(of: before.vault, passphrase: nil, words: try WordsKey.derive(words)) != nil)
        await band.look.open()
        await band.look.submit(passphrase: PlantedAccount.passphrase)
        #expect(band.look.phase == .shown, "\(band.look.message ?? "")")
        let after = try #require(vault.snapshot(PlantedAccount.account))
        #expect(VaultModel.master(of: after.vault, passphrase: nil, words: try WordsKey.derive(band.look.words)) != nil)
        #expect(VaultModel.master(of: after.vault, passphrase: nil, words: try WordsKey.derive(words)) == nil)
        // Unsynced: no line, minted at once (U2b's look, unchanged).
        let local = PlantedRoad()
        let (localSession, _) = try await local.created()
        let (localStanding, _) = Self.standing(localSession, store)
        let localBand = try #require(localStanding.band)
        await localBand.look.open()
        #expect(localBand.look.phase == .shown && !localBand.look.saysAccountWords)
    }

    /// The look's pure rule (F-U2-3): the account line says itself first whenever the library syncs — even where no
    /// passphrase would otherwise be asked — and never on an unsynced library or U2's join moment (its own look).
    @Test func theLooksAccountLineIsSaidFirstOnlyWhenSynced() async {
        var mints: [String?] = []
        let synced = WordsLookModel(
            saysRuleSix: false, passphraseExists: { false }, replacesAccountWords: { true },
            mint: { mints.append($0); return .minted((1...12).map { "word\($0)" }) }, copy: { _ in }, recorded: {})
        await synced.open()
        #expect(synced.phase == .asking && synced.saysAccountWords && mints.isEmpty)
        await synced.submit(passphrase: "typed")
        #expect(synced.phase == .shown && mints == ["typed"])
        let local = WordsLookModel(
            saysRuleSix: false, passphraseExists: { false },
            mint: { _ in .minted((1...12).map { "word\($0)" }) }, copy: { _ in }, recorded: {})
        await local.open()
        #expect(local.phase == .shown && !local.saysAccountWords)
    }

    /// R-U3-4: a look asks by the core's own fact NOW (a lock on the live key file of the key, or the account's), not the
    /// record's possibly stale stamp.
    @Test func aLookAsksByTheCoresOwnPassphraseFact() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        #expect(!ProtectionOpenRoad.lookAsksPassphrase(session.library))
        #expect(await ProtectionOpenRoad.setFirstPassphrase(session: session, new: "chosen") == .set)
        #expect(ProtectionOpenRoad.lookAsksPassphrase(session.library) && ProtectionOpenRoad.passphraseExists(session.library))
        var stale = session.library
        stale.keyFile = nil
        #expect(ProtectionOpenRoad.passphraseExists(stale), "the record's stamp still says a passphrase")
        #expect(!ProtectionOpenRoad.lookAsksPassphrase(stale), "no lock left: the look asks nothing")
        stale.record?.account = "acct"
        #expect(ProtectionOpenRoad.lookAsksPassphrase(stale), "bound: the account's passphrase is asked")
    }

    /// A look's refusal in the pane's idiom (R-U3-5 — the New Words door's synced refusals: the account moved, the vault
    /// out of reach, signed out); anything else U2b's own sentence.
    @Test func aLooksRefusalsAreSaidInThePanesIdiom() {
        #expect(ProtectionOpenRoad.lookRefusal(ExecutorRefusal.accountMoved) == ProtectionWords.doorRefusedFollowOwed)
        #expect(ProtectionOpenRoad.lookRefusal(ExecutorRefusal.needsFreshVault) == ProtectionWords.doorRefusedNeedsVault)
        #expect(ProtectionOpenRoad.lookRefusal(ExecutorRefusal.vaultOutOfReach(account: "a"))
            == ProtectionWords.doorRefusedNeedsVault)
        #expect(ProtectionOpenRoad.lookRefusal(VaultRefusal.unreachable) == ProtectionWords.doorRefusedNeedsVault)
        #expect(ProtectionOpenRoad.lookRefusal(ExecutorRefusal.signedOutUseThisMacOnly) == ProtectionWords.doorRefusedSignedOut)
        #expect(ProtectionOpenRoad.lookRefusal(ExecutorRefusal.secretMissing) == ProtectionWords.wordsLookFailed)
        #expect(ProtectionOpenRoad.lookRefusal(ExecutorRefusal.noLiveKeyFile) == ProtectionWords.wordsLookFailed)
    }
}
