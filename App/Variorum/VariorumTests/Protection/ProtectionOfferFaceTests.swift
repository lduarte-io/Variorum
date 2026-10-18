//
//  ProtectionOfferFaceTests.swift
//  VariorumTests — VX-306 U2 piece 3: RULE 21's KEY-FILE OFFER from planted facts — a stray key file beside the library → this Mac's
//  keychain named; *Not now* writes NOTHING; *Use it* puts the library's own file back, says where it came from, and
//  the next open owes nothing; a backup's key file named with its day when this Mac's copy is gone too; *Use it*
//  failing; the search's other answers read into the standing faces.
//  (`notes/plans/vx-306-castle-open-road.md` §2 U2 + its addendum; the contract `notes/CastleRules.md`.)
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U2 — rule 21's key-file offer (planted facts)")
@MainActor
struct ProtectionOfferFaceTests {
    static let day: (Date) -> String = { ProtectionWords.day($0) }

    // MARK: - Rule 21: the offer

    /// A stray key file beside the library: this Mac's keychain holds the library's own — the offer names it.
    /// *Not now* writes NOTHING; the library opens either way.
    @Test func aStrayBesideIsOfferedFromThisMacsKeychainAndNotNowWritesNothing() async throws {
        let road = PlantedRoad()
        _ = try await road.created()
        try Plant.strayBeside(road)
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the silent item opens it")
            return
        }
        #expect(session.report.acts.contains(.offerKeyFile))
        guard case .offer(let offer)? = session.report.keyFileSearch else {
            Issue.record("the search found the keychain copy: \(String(describing: session.report.keyFileSearch))")
            return
        }
        #expect(offer.source == .thisMacsKeychain)
        #expect(session.owesInterlude)
        let card = try #require(RoadInterlude.cards(session.report).first)
        #expect(RoadInterlude.sentence(card, day: Self.day)
            == "The key file beside your library doesn't open it. This Mac's keychain holds a copy that does. Use it?")

        let before = try Plant.containerBytes(road)
        let memoryBefore = road.memory.items
        let custodyBefore = road.custody.items
        let appleBefore = Set(road.apple.keys.keys)
        var used = 0, receipts: [String] = [], finished = 0
        let model = RoadInterludeModel(
            cards: RoadInterlude.cards(session.report), day: Self.day,
            useOffer: { _ in used += 1; return .used }, receipt: { receipts.append($0) }, finished: { finished += 1 })
        model.notNow()
        #expect(used == 0 && receipts.isEmpty && finished == 1, "Not now calls nothing, says nothing, and goes on")
        #expect(try Plant.containerBytes(road) == before, "no file written")
        #expect(road.memory.items == memoryBefore && road.custody.items == custodyBefore
                && Set(road.apple.keys.keys) == appleBefore, "no keychain item written")
        // And the offer stays owed: the next open asks again.
        guard case .opened(let again) = await ProtectionOpenRoad.route(road.context()) else { Issue.record("the road did not open as planted"); return }
        #expect(again.owesInterlude)
    }

    /// *Use it*: the library's own key file back beside it (one act), the receipt naming the keychain, nothing owed after.
    @Test func useItPutsTheLibrarysOwnFileBackAndSaysWhere() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        let own = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        try Plant.strayBeside(road)
        let ctx = road.context()
        guard case .opened(let session) = await ProtectionOpenRoad.route(ctx),
              case .offer(let offer)? = session.report.keyFileSearch else {
            Issue.record("the offer")
            return
        }
        #expect(offer.keyFile.fingerprint == created.library.fingerprint, "the offered file is the library's own")
        var receipts: [String] = []
        var finished = 0
        let model = RoadInterludeModel(
            cards: RoadInterlude.cards(session.report), day: Self.day,
            useOffer: { await ProtectionOpenRoad.useOffer(ctx, session: session, offer: $0) },
            receipt: { receipts.append($0) }, finished: { finished += 1 })
        await model.useIt()
        #expect(finished == 1)
        #expect(receipts == ["Key file restored from this Mac's keychain."])
        let back = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(back.fingerprint == created.library.fingerprint && back.libraryID == own.libraryID)
        #expect(session.report.keyFileSearch == nil, "nothing owed after")
        guard case .opened(let again) = await ProtectionOpenRoad.route(road.context()) else { Issue.record("the road did not open as planted"); return }
        #expect(!again.owesInterlude && again.report.keyFileSearch == nil)
    }

    /// This Mac's copy gone too: a BACKUP's key file is named, with its day.
    @Test func aBackupsKeyFileIsNamedWithItsDayWhenThisMacsCopyIsGone() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        let own = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        try road.system().backups.takeBackupPair(with: created.key, keyFile: own, deviceID: created.library.section.deviceID)
        try Plant.strayBeside(road)
        road.memory.items = [:]
        let ctx = road.context()
        guard case .opened(let session) = await ProtectionOpenRoad.route(ctx),
              case .offer(let offer)? = session.report.keyFileSearch,
              case .backup(_, let date?) = offer.source else {
            Issue.record("a backup's key file offered with its day")
            return
        }
        let sentence = RoadInterlude.sentence(.offer(offer), day: Self.day)
        #expect(sentence == "The key file beside your library doesn't open it. The backup from \(Self.day(date)) holds a "
            + "key file that does. Use it?")
        #expect(RoadInterlude.receipt(offer, day: Self.day) == "Key file restored from the backup from \(Self.day(date)).")
        #expect(await ProtectionOpenRoad.useOffer(ctx, session: session, offer: offer) == .used)
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile()?.fingerprint == created.library.fingerprint)
    }

    /// *Use it* failing says so; both doors stay.
    @Test func useItFailingSaysSoAndBothDoorsStay() async throws {
        let road = PlantedRoad()
        _ = try await road.created()
        try Plant.strayBeside(road)
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context()),
              case .offer(let offer)? = session.report.keyFileSearch else {
            Issue.record("the offer")
            return
        }
        var finished = 0
        let model = RoadInterludeModel(
            cards: [.offer(offer)], day: Self.day, useOffer: { _ in .failed }, receipt: { _ in }, finished: { finished += 1 })
        await model.useIt()
        #expect(model.message == ProtectionWords.offerUseFailed && finished == 0)
        #expect(model.current == RoadInterlude.Card.offer(offer))
        model.notNow()
        #expect(finished == 1 && model.message == nil)
    }

    /// The search's other answers, read into the standing faces: the split pair's line; rule 27 (P-VX378-U4-6).
    @Test func theSearchsOtherAnswersAreTheStandingFaces() {
        var report = RoadOpenReport()
        report.keyFileSearch = .besideOpensItOnlyThroughItsHistory
        #expect(RoadStandingFaces.derive(report).splitPair)
        #expect(RoadInterlude.cards(report).isEmpty, "the split pair is a standing line, never a card")
        report.keyFileSearch = .noKeyFileAnywhere(NoKeyFileAnywhere(accountRoad: true))
        #expect(RoadStandingFaces.derive(report).noKeyFileAnywhere == NoKeyFileAnywhere(accountRoad: true))
        report.keyFileSearch = .besideOpensIt
        #expect(RoadStandingFaces.derive(report) == .none)
    }
}
