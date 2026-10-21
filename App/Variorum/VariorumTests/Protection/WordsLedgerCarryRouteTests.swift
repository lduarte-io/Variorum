//
//  WordsLedgerCarryRouteTests.swift
//  VariorumTests — VX-309 U1c piece 3: VX-444 (+ F-U1b-5) THROUGH `AppBootstrap` (a new-road bootstrap over the PLANTED
//  road — no keychain, a temp slot; the test bootstrap's own reminder suite; Mac only: `AppBootstrap` is the app's). After
//  Make this my library (the standing act) the reopened library's card above the quick entry does NOT offer the words the
//  outgoing library had recorded (the pair carried — rule 17); after T-5 with the copy's own typed words it does not offer
//  them either. RED ON THE PRE-UNIT TREE (the pins compile there — they read only the bootstrap's existing faces): the new
//  library's id carried no mark, so its card offered the words again.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U1c — VX-444: the words-recorded ledger carries, through AppBootstrap (planted, no keychain)", .serialized)
@MainActor
struct WordsLedgerCarryRouteTests {
    /// The test bootstrap's ledger (its reminder suite — `PassphraseReminderLedger.testSuiteName`).
    static var ledger: WordsCardLedger {
        WordsCardLedger(defaults: UserDefaults(suiteName: PassphraseReminderLedger.testSuiteName) ?? .standard)
    }

    static func forget(_ ids: [String]) {
        let defaults = ledger.defaults
        for id in ids {
            defaults.removeObject(forKey: WordsCardLedger.Key.recorded(id))
            defaults.removeObject(forKey: WordsCardLedger.Key.dismissed(id))
        }
    }

    @Test func afterMakeThisMyLibraryTheCardNeverReOffersRecordedWords() async throws {
        try await withRoadDependencies {
            let road = PlantedRoad()
            let (bootstrap, words) = try await LockWorld.readyInStandard(road)
            let session = try #require(bootstrap.roadSession)
            let oldID = try #require(session.library.record?.libraryID)
            Self.ledger.record(oldID)
            defer { Self.forget([oldID]) }
            #expect(ProtectionBackupHook.takePair(session) == .written)
            let roads = try #require(bootstrap.copyDoorsRoads())
            let row = try #require(await roads.listing().thisLibrary.first)
            let pair = TypedSecrets(words: words)
            #expect(await bootstrap.makeThisMyLibrary(row, copySecrets: pair, currentPair: pair) == .made)
            let newID = try #require(bootstrap.roadSession?.library.record?.libraryID)
            defer { Self.forget([newID]) }
            #expect(newID != oldID)
            let band = try #require(bootstrap.roadStanding?.band)
            #expect(!band.offersWords, "the pair carried — the words she recorded are the new library's")
        }
    }

    @Test func afterTheEmptySlotLandingByTypedWordsTheCardOffersNothing() async throws {
        try await withRoadDependencies {
            let road = PlantedRoad()
            let (_, words, oldID) = try await EmptySlotPlant.missingFace(road)
            defer { Self.forget([oldID]) }
            let bootstrap = LockWorld.bootstrap(road)
            await bootstrap.awaitOpen()
            guard case .libraryMissing = bootstrap.state else {
                Issue.record("the missing face: \(bootstrap.state)")
                return
            }
            let roads = try #require(bootstrap.copyDoorsRoadsWithoutALibrary())
            let row = try #require(await roads.listing().all.first { $0.kind == .backup })
            #expect(await bootstrap.makeThisMyLibraryInTheEmptySlot(row, copySecrets: TypedSecrets(words: words)) == .made)
            guard case .ready = bootstrap.state, let newID = bootstrap.roadSession?.library.record?.libraryID else {
                Issue.record("the landed library opens: \(bootstrap.state)")
                return
            }
            defer { Self.forget([newID]) }
            let band = try #require(bootstrap.roadStanding?.band)
            #expect(!band.offersWords, "her typed words are the new library's — recorded")
        }
    }
}
