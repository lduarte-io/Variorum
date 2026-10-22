//
//  WordsLedgerCarryRoadTests.swift
//  VariorumTests — VX-309 U1c piece 3: VX-444 (+ F-U1b-5) — THE WORDS-RECORDED LEDGER CARRIES, over planted keychain leaves
//  and a temp slot with the real file leaves (`PlantedRoad` — no keychain; the suite also runs headless in the implementer's
//  SwiftPM harness). The band card's ledger (`variorum.calmAsks.words.<libraryID>.*`) is per library ID, and Make this my
//  library makes a NEW library under the CURRENT pair (rule 17) — so the words she recorded are still the new library's
//  words, and the card must not offer them again: the outgoing library's marks carry onto the new id. T-5 with the copy's own
//  TYPED words: they ARE the new library's words — recorded. T-5 with its passphrase (fresh words minted, dropped unseen) and
//  T-8 (the creation's words, dropped unseen): the card's fresh offer stays. New API (the landings' `wordsLedger:`) — red by
//  construction on the pre-unit tree; the bootstrap's own pins are `WordsLedgerCarryRouteTests` (Mac only).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U1c — VX-444: the words-recorded ledger carries across Make this my library (planted, no keychain)", .serialized)
@MainActor
struct WordsLedgerCarryRoadTests {
    /// The band card over `libraryID` with `ledger` — does it offer the words?
    static func offers(_ libraryID: String, ledger: WordsCardLedger) -> Bool {
        let reminder = PassphraseReminderModel(
            libraryID: libraryID, moment: nil, ledger: PassphraseReminderLedger(defaults: ledger.defaults),
            facts: { (passphraseSet: true, dismissals: 0) }, recordDismissal: { true })
        return WordsBandModel(
            libraryID: libraryID, writes: true, ledger: ledger, snoozes: WordsCardSnoozes(), reminder: reminder,
            passphraseExists: { false }, mint: { _ in .refused("planted") }, copy: { _ in }).offersWords
    }

    /// Make this my library on this library's own backup: the outgoing library's marks — `recorded` here — carry onto the
    /// new library's id (the card offers nothing she already recorded); with NOTHING marked, nothing is carried and the card
    /// offers the words. The outgoing library's own marks stay.
    @Test(arguments: [true, false])
    func makeThisMyLibraryCarriesTheOutgoingLibrarysMarks(_ recorded: Bool) async throws {
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let ledger = WordsCardLedger(defaults: store.defaults)
        let road = PlantedRoad()
        let (session, words, row) = try await CopyDoorsPlant.libraryWithABackup(road)
        let oldID = try #require(session.library.record?.libraryID)
        if recorded { ledger.record(oldID) }
        #expect(Self.offers(oldID, ledger: ledger) == !recorded)
        let pair = TypedSecrets(words: words)
        guard case .ready(let copy, let catalog, let opened) = ProtectionCopyDoors.preflight(
            session, row: row, copySecrets: pair, currentPair: pair) else {
            Issue.record("the preflight passes")
            return
        }
        let result = await ProtectionCopyDoors.makeMine(
            session, copy: copy, catalog: catalog, row: row, opened: opened, currentPair: pair, wordsLedger: ledger)
        #expect(result.outcome == .made)
        let newID = try #require(session.library.record?.libraryID)
        #expect(newID != oldID)
        #expect(ledger.recorded(newID) == recorded, "the pair carried — and its mark with it")
        #expect(Self.offers(newID, ledger: ledger) == !recorded, recorded ? "never re-offered" : "the card offers the words")
        #expect(ledger.recorded(oldID) == recorded, "the outgoing library keeps its own mark")
    }

    /// The ✕'s mark carries too (she chose not to be offered — the pair she declined to be shown is the same pair).
    @Test func aDismissedCardStaysDismissedForTheNewLibrary() async throws {
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let ledger = WordsCardLedger(defaults: store.defaults)
        ledger.dismiss("lib-out")
        ledger.carry(from: "lib-out", to: "lib-new")
        #expect(ledger.dismissed("lib-new") && !ledger.recorded("lib-new"))
        #expect(!Self.offers("lib-new", ledger: ledger))
        ledger.carry(from: "lib-new", to: "lib-new")
        ledger.carry(from: "", to: "lib-x")
        #expect(!ledger.dismissed("lib-x"), "no carry from nothing")
    }

    /// F-U1b-5 — T-5 WITH THE COPY'S OWN TYPED WORDS: they ARE the new library's words lock — counted recorded; the card
    /// offers nothing she just typed.
    @Test func theEmptySlotLandingByTypedWordsCountsThemRecorded() async throws {
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let ledger = WordsCardLedger(defaults: store.defaults)
        let road = PlantedRoad()
        let (_, words, _) = try await EmptySlotPlant.missingFace(road)
        let ctx = EmptySlotPlant.noLibraryContext(road)
        let row = try #require(ProtectionCopyDoors.listing(ctx).all.first { $0.kind == .backup })
        let result = await ProtectionCopyDoors.makeMineInTheEmptySlot(
            ctx, row: row, copySecrets: TypedSecrets(words: words), wordsLedger: ledger)
        #expect(result.outcome == .made)
        let key = try #require(result.key)
        let newID = try #require(try ProtectionLibraryFiles.readRecord(at: road.slot.places.slot, key: key)?.libraryID)
        #expect(ledger.recorded(newID), "her typed words are the new library's — recorded")
        #expect(!Self.offers(newID, ledger: ledger))
    }

    /// T-5 WITH THE COPY'S PASSPHRASE: the new library's words are minted fresh and dropped unseen — nothing is marked, so
    /// the card offers them (rule 2's first look).
    @Test func theEmptySlotLandingByItsPassphraseLeavesTheCardsOffer() async throws {
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let ledger = WordsCardLedger(defaults: store.defaults)
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        try CopyDoorsPlant.migrate(road, key: session.key)
        let passphrase = "a copy's own passphrase"
        #expect(await ProtectionOpenRoad.setFirstPassphrase(session: session, new: passphrase) == .set)
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        try session.system.backups.takeBackupPair(with: session.key, keyFile: live, deviceID: session.library.section.deviceID)
        let oldID = try #require(session.library.record?.libraryID)
        ledger.record(oldID)  // the missing library's mark — never carried by a T-5 landing
        ProtectionLibraryFiles.removeWithSidecars(road.slot.places.slot)
        let ctx = EmptySlotPlant.noLibraryContext(road)
        let row = try #require(ProtectionCopyDoors.listing(ctx).all.first { $0.kind == .backup })
        let result = await ProtectionCopyDoors.makeMineInTheEmptySlot(
            ctx, row: row, copySecrets: TypedSecrets(passphrase: passphrase),
            wordsLedger: ledger)
        #expect(result.outcome == .made)
        let key = try #require(result.key)
        let newID = try #require(try ProtectionLibraryFiles.readRecord(at: road.slot.places.slot, key: key)?.libraryID)
        #expect(!ledger.recorded(newID) && !ledger.dismissed(newID), "fresh words, unseen — nothing marked")
        #expect(Self.offers(newID, ledger: ledger), "the card offers the new words")
    }

    /// GUARD — T-8 (the creation's words, dropped unseen): the new library's card offers fresh words whatever the library
    /// that stepped aside had recorded (T-8's road takes no ledger — nothing is carried there, by construction).
    @Test func aPlaintextExportsNewLibraryOffersItsWords() async throws {
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let ledger = WordsCardLedger(defaults: store.defaults)
        let road = PlantedRoad()
        let (old, _) = try await road.created()
        try CopyDoorsPlant.migrate(road, key: old.key)
        ledger.record(try #require(old.library.record?.libraryID))
        let export = try ExportPlant.export(into: road.slot.root.appendingPathComponent("Downloads/u1c-export", isDirectory: true))
        guard case .plan(let plan) = ProtectionCopyDoors.readPlaintextExport(export) else {
            Issue.record("the export plans")
            return
        }
        let landed = await ProtectionCopyDoors.landPlaintextExport(road.context(), plan: plan)
        let newID = try #require(landed.created?.session.library.record?.libraryID)
        #expect(Self.offers(newID, ledger: ledger), "the creation's words — offered at the first look")
    }
}
