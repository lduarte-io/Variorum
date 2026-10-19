//
//  RoadAccountSurfaceTests.swift
//  VariorumTests — VX-308 U1 piece 6: THE ACCOUNT SECTION'S MAC FACES build and lay out (hosted in a real window — a face
//  that crashes or cannot lay out fails here) in every situation, each sheet in each shape, and the pane's composition is
//  the switch's: on the new road the account section sits beneath the crossings and every protection sheet presents
//  through the one presenter's host; today's road (no road model) is untouched. The faces' logic is the models'
//  (pinned headless — `RoadAccountModelTests`, `RoadAccountFacesTests`); this suite pins the composition. Mac only.
//

import Foundation
import SwiftUI
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("VX-308 U1 — the account section's Mac faces (hosted) and the pane's composition", .serialized)
struct RoadAccountSurfaceTests {
    /// The section hosts in every situation `assess` names, with each door face it can carry.
    @Test func theSectionHostsInEverySituation() async {
        let shapes: [RoadAccountFaces] = [
            PlantedAccountRoads.faces(turnOnSync: .refused(ProtectionWords.accountSignInToTurnOnSync), signOut: false,
                                      signIn: true),
            PlantedAccountRoads.faces(),
            PlantedAccountRoads.faces(turnOnSync: .notYet(ProtectionWords.moveNotYet)),
            PlantedAccountRoads.faces(situation: .inSync(email: PlantedAccount.email), turnOnSync: .hidden,
                                      stopSyncing: .open(PlantedAccountRoads.leave(.stopSyncingHere))),
            PlantedAccountRoads.faces(situation: .signedOut, turnOnSync: .hidden,
                                      thisMacOnly: .open(PlantedAccountRoads.leave(.thisMacOnly)), signOut: false,
                                      signIn: true),
            PlantedAccountRoads.faces(situation: .otherAccount(signedInEmail: PlantedAccount.email, sameEmail: true),
                                      turnOnSync: .hidden),
        ]
        for faces in shapes {
            let planted = PlantedAccountRoads()
            planted.faces = faces
            let model = RoadAccountModel(roads: planted.roads)
            model.signOutRoad = {}
            await model.refresh()
            await SurfaceComposition.host(
                Form { RoadAccountSection(model: model) }.formStyle(.grouped), size: NSSize(width: 640, height: 600))
        }
    }

    /// Each sheet hosts in its shape: turning sync on (a new passphrase twice, the words), a leave (rule 16's sentences,
    /// the third leave's pointer), a refusal said, sign-out, and the signed-out screen.
    @Test func eachSheetHostsInItsShape() async throws {
        let setUp = RoadAccountConfirmModel(
            door: PlantedAccountRoads.setUp(), act: { _ in .refused(ProtectionWords.wordsDoNotOpen) }) { _ in }
        await SurfaceComposition.host(RoadAccountConfirmSheet(model: setUp), size: NSSize(width: 480, height: 640))
        await setUp.submit(passphrase: "p", again: "p", words: try RecoveryPhrase.generate().joined(separator: " "))
        #expect(setUp.refusal == ProtectionWords.wordsDoNotOpen)
        await SurfaceComposition.host(RoadAccountConfirmSheet(model: setUp), size: NSSize(width: 480, height: 640))
        let delete = RoadAccountConfirmModel(
            door: PlantedAccountRoads.leave(.deleteAccountHere), act: { _ in .made(receipt: "x") }) { _ in }
        await SurfaceComposition.host(RoadAccountConfirmSheet(model: delete), size: NSSize(width: 480, height: 600))
        let signOut = RoadSignOutModel(signOut: {}) { _ in }
        await SurfaceComposition.host(RoadSignOutSheet(model: signOut), size: NSSize(width: 460, height: 320))
        let screen = RoadSignedOutCastleModel(leave: { nil }) { _ in }
        await SurfaceComposition.host(RoadSignedOutCastleSheet(model: screen), size: NSSize(width: 480, height: 400))
    }

    /// THE PANE'S COMPOSITION (source pin — a Form's conditional sections are not reachable by composition before
    /// hosting, VX-306's adjudication): the account section beneath the crossings, before today's gate; every new-road
    /// protection sheet through the one presenter's host, alone; the account doors re-read at each appearance.
    @Test func thePaneHostsTheAccountSectionAndTheOnePresenter() throws {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/Features/Settings/ProtectionPane.swift"),
            encoding: .utf8)
        let body = try #require(source.range(of: "var body: some View {")).upperBound
        let rest = String(source[body...])
        let crossings = try #require(rest.range(of: "if let crossings = roadStanding?.crossings {"))
        let account = try #require(rest.range(of: "if let account = roadStanding?.account {"))
        let todayGate = try #require(rest.range(of: "if roadStanding == nil {"))
        #expect(crossings.lowerBound < account.lowerBound && account.lowerBound < todayGate.lowerBound)
        #expect(rest.contains(".task { await roadStanding?.account?.refresh() }"))
        #expect(rest.components(separatedBy: ".protectionSheets(").count == 2, "one host on the pane")
    }
}

/// The bootstrap's composition of the one presenter and the account roads (a new-road bootstrap over the PLANTED road —
/// no keychain, the planted vault; Mac only: `AppBootstrap` is the app's).
@MainActor
@Suite("VX-308 U1 — the one presenter and the account roads through AppBootstrap (planted)", .serialized)
struct ProtectionAccountRouteTests {
    /// A new-road bootstrap over the planted road (the keyed opener over its temp slot), signed in as `session`.
    private func bootstrap(_ road: PlantedRoad, session: SessionFact) -> AppBootstrap {
        let url = road.slot.places.slot
        return AppBootstrap(
            testOpener: { .failure(AppDatabase.StoreOpenError(storePath: "", reason: "today's road is not taken here")) },
            gate: .scripted(dials: ProtectionDials(), backing: InMemoryStoreKeyGuardBacking()),
            testPresence: StoreFilePresence.classify(at: url),
            testStoreURL: url,
            protectionRoad: ProtectionRoadTestHarness(system: road.system(), session: session, open: { key in
                Result { try AppDatabase.openStore(at: url, custody: .inMemory(initial: key)) }
                    .mapError { $0 as? AppDatabase.StoreOpenError
                        ?? AppDatabase.StoreOpenError(storePath: url.path, reason: String(describing: $0)) }
            }))
    }

    private func ready(_ bootstrap: AppBootstrap) async {
        await bootstrap.awaitOpen()
        if case .opening = bootstrap.state { await bootstrap.awaitOpen() }
    }

    /// VX-239 ON THE NEW ROAD — RED ON OLD BY REVERT (`finish`'s `libraryClosed()` line removed → red): a crossing's
    /// confirm standing when the library closes (both quiet roads gone, a reopen lands in the lobby) is DROPPED, and the
    /// unlock that follows opens with no sheet re-presented. The one presenter is the bootstrap's, shared by the crossings
    /// and the account section, and handed to the open library's faces.
    @Test func aSheetStandingWhenTheLibraryClosesNeverReturnsAfterTheUnlock() async throws {
        try await withRoadDependencies {
            let road = PlantedRoad()
            let bootstrap = bootstrap(road, session: .signedOut)
            await ready(bootstrap)
            guard case .ready = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("the planted slot creates and opens: \(bootstrap.state)")
                return
            }
            let sheets = try #require(bootstrap.protectionSheets)
            let crossings = try #require(bootstrap.roadCrossings)
            #expect(crossings.presenter === sheets && bootstrap.roadAccount?.presenter === sheets)
            #expect(bootstrap.roadStanding?.sheets === sheets && bootstrap.roadStanding?.account === bootstrap.roadAccount)
            // The library's words — the look mints the ones she records (rule 2; nothing kept them at creation).
            guard case .minted(let words) = await ProtectionOpenRoad.mintFreshWords(session: session, passphrase: nil) else {
                Issue.record("the look mints the words")
                return
            }
            await crossings.refresh()
            crossings.open(.useCastle)
            #expect(sheets.sheet(for: .settings) != nil, "the confirm stands")
            // Both quiet roads gone; the reopen lands in the lobby — the library closed.
            road.custody.items = [:]
            road.apple.keys = [:]
            bootstrap.retry()
            await bootstrap.awaitOpen()
            guard case .roadLobby(let lobby) = bootstrap.state else {
                Issue.record("no quiet road remains — the lobby: \(bootstrap.state)")
                return
            }
            #expect(sheets.sheet == nil, "VX-239: dropped at the closed state")
            await lobby.unlock(wordsText: words.joined(separator: " "))
            await ready(bootstrap)
            guard case .ready = bootstrap.state else {
                Issue.record("the words open the library: \(bootstrap.state)")
                return
            }
            #expect(sheets.sheet == nil && sheets.sheet(for: .settings) == nil, "and never re-presented after the unlock")
            #expect(bootstrap.protectionSheets === sheets, "the presenter outlives the reopen")
        }
    }

    /// THE ACCOUNT ROADS END TO END through the bootstrap (the planted vault — no network): turning sync on from the
    /// section binds the open library to the signed-in account; then P-VX308-U1-F1's hook (the Account sheet's deletion
    /// landed) runs the protection half — the record stops naming the account, this Mac forgets its sync keys.
    @Test func turningSyncOnThenTheDeletionsHookRunTheirRoads() async throws {
        try await withRoadDependencies {
            let (road, vault, keys) = PlantedAccount.road()
            let bootstrap = bootstrap(road, session: PlantedAccount.signedIn)
            await ready(bootstrap)
            guard case .ready = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("the planted slot creates and opens: \(bootstrap.state)")
                return
            }
            guard case .minted(let words) = await ProtectionOpenRoad.mintFreshWords(session: session, passphrase: nil) else {
                Issue.record("the look mints the words")
                return
            }
            let account = try #require(bootstrap.roadAccount)
            await account.refresh()
            #expect(account.faces?.turnOnSync.openDoor?.door == .turnOnSync)
            account.open(.turnOnSync)
            try await #require(account.confirm).submit(
                passphrase: PlantedAccount.passphrase, again: PlantedAccount.passphrase, words: words.joined(separator: " "))
            #expect(account.confirm == nil, "the act landed")
            #expect(bootstrap.roadSession?.library.record?.account == PlantedAccount.account)
            #expect(vault.snapshot(PlantedAccount.account) != nil && !keys.accountsHeld.isEmpty)
            await bootstrap.accountDeletedOnNewRoad(PlantedAccount.other)
            #expect(bootstrap.roadSession?.library.record?.account == PlantedAccount.account, "another account: nothing")
            await bootstrap.accountDeletedOnNewRoad(PlantedAccount.account)
            #expect(bootstrap.roadSession?.library.record?.account == nil && keys.accountsHeld.isEmpty)
        }
    }
}
