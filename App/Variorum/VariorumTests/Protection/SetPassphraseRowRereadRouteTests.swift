//
//  SetPassphraseRowRereadRouteTests.swift
//  VariorumTests — VX-309 U1c piece 5: VX-454 THROUGH `AppBootstrap` (a new-road bootstrap over the PLANTED road — no
//  keychain, the planted vault, no network; Mac only: `AppBootstrap` is the app's). The LANDING arm: turning sync on with a
//  new passphrase from the account section, the Protection pane still on screen (no reappearance) — the account act's
//  landing re-reads the set row (it retires), rule 3's reminder (it retires) and the key doors (Change passphrase… stands in
//  the set row's place). RED ON OLD: the landing re-read only the crossings, so the set row stood above Change/Reset until a
//  relaunch (W-VX308-2).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U1c — VX-454: an account act's landing re-reads the set row, through AppBootstrap (planted)", .serialized)
@MainActor
struct SetPassphraseRowRereadRouteTests {
    /// A new-road bootstrap over the planted road (the keyed opener over its temp slot), signed in as `session`.
    private func bootstrap(_ road: PlantedRoad, session: SessionFact) -> AppBootstrap {
        let url = road.slot.places.slot
        return AppBootstrap(
            testStoreURL: url,
            protectionRoad: ProtectionRoadTestHarness(system: road.system(), session: session, open: { key in
                Result { try AppDatabase.openStore(at: url, custody: .inMemory(initial: key)) }
                    .mapError { $0 as? AppDatabase.StoreOpenError
                        ?? AppDatabase.StoreOpenError(storePath: url.path, reason: String(describing: $0)) }
            }))
    }

    @Test func turningSyncOnRetiresTheSetRowAtTheLanding() async throws {
        try await withRoadDependencies {
            let (road, _, _) = PlantedAccount.road()
            let bootstrap = bootstrap(road, session: PlantedAccount.signedIn)
            await bootstrap.awaitOpen()
            if case .opening = bootstrap.state { await bootstrap.awaitOpen() }
            guard case .ready = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("the planted slot creates and opens: \(bootstrap.state)")
                return
            }
            let standing = try #require(bootstrap.roadStanding)
            #expect(standing.offersSetPassphrase, "no passphrase yet")
            guard case .minted(let words) = await ProtectionOpenRoad.mintFreshWords(session: session, passphrase: nil) else {
                Issue.record("the look mints the words")
                return
            }
            let account = try #require(bootstrap.roadAccount)
            await account.refresh()
            account.open(.turnOnSync)
            try await #require(account.confirm).submit(
                passphrase: PlantedAccount.passphrase, again: PlantedAccount.passphrase, words: words.joined(separator: " "))
            #expect(bootstrap.roadSession?.library.record?.account == PlantedAccount.account, "the act landed")
            // The landing's re-read runs after the act (the account model's landing task) — no pane reappearance here.
            for _ in 0..<400 where standing.offersSetPassphrase || bootstrap.roadKeyDoors?.faces?.changePassphrase.openDoor == nil {
                try await Task.sleep(for: .milliseconds(5))
            }
            #expect(!standing.offersSetPassphrase, "VX-454: the set row retired at the landing")
            #expect(standing.reminder.showing == nil)
            #expect(bootstrap.roadKeyDoors?.faces?.changePassphrase.openDoor != nil, "Change passphrase… in its place")
        }
    }
}
