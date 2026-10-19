//
//  ProtectionPaneWaveTests.swift
//  VariorumTests — VX-308 ladder round 1, MINOR-2 (`notes/plans/vx-308-ladder-round-1.md`): "the pane's ONE read" was one
//  code path but THREE reads per appearance — the crossings, the account section and the key doors each ran
//  `ProtectionPaneRead.read` (a facts gather and a vault fetch over the wire), concurrently and independently, so a vault
//  that changed between them could render transiently split sections. U1's R-2 meant ONE assessment for the pane. Now an
//  appearance reads ONCE (`ProtectionPaneRead.wave`) and the three sections land their faces from it, each by its own
//  landing rule (`ProtectionPaneRefresh.wave`); every other refresh trigger keeps its own fresh read. Planted road, planted
//  vault — no network; headless in the implementer's SwiftPM harness.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-308 ladder round 1 — MINOR-2: the pane's one read, once per appearance, for its three sections")
@MainActor
struct ProtectionPaneWaveTests {
    typealias Account = PlantedAccount

    struct World {
        let session: ProtectionRoadSession
        let vault: PlantedVaultLeaf
        let exports: ScheduledExportSwitch
        let crossings: RoadCrossingsModel
        let account: RoadAccountModel
        let keyDoors: RoadKeyDoorsModel

        var fetches: Int { vault.calls.filter { $0.hasPrefix("fetch") }.count }
    }

    /// A library on the planted road, signed in to an account that already syncs elsewhere (so every section has
    /// something to say), and the three sections' models with roads that read EXACTLY as the bootstrap's do.
    private func world() async throws -> World {
        let (road, vault, _) = Account.road()
        let (session, _) = try await road.created()
        try vault.plant(accountID: Account.account, passphrase: Account.passphrase, words: try RecoveryPhrase.generate(),
                        mode: .standard)
        let signIn = Account.signedIn
        let exports = PlantedExportSwitch().road
        let crossings = RoadCrossingsModel(roads: RoadCrossingRoads(
            read: {
                await ProtectionPaneRead.read(session, signIn: signIn, exportSwitch: exports)
                    .flatMap { ProtectionCrossings.readCrossings(session, exportSwitch: exports, read: $0) }
            },
            cross: { _ in .refused("unused") }, changeGate: { _, _ in .changed }, turnExportBackOn: { false },
            exportNoticeOwed: { false }, dismissExportNotice: {}))
        let account = RoadAccountModel(roads: RoadAccountRoads(
            read: {
                await ProtectionPaneRead.read(session, signIn: signIn, exportSwitch: exports)
                    .flatMap { ProtectionPaneRead.accountFaces($0, session: session) }
            },
            press: { _ in .refused("unused") }))
        let keyDoors = RoadKeyDoorsModel(roads: RoadKeyDoorRoads(
            read: { await ProtectionKeyDoorRoad.read(session, signIn: signIn, exportSwitch: exports) },
            press: { _ in .refused("unused") }))
        return World(session: session, vault: vault, exports: exports, crossings: crossings, account: account,
                     keyDoors: keyDoors)
    }

    /// The bootstrap's wave road, over the planted session.
    private func waveRoad(_ world: World) -> @MainActor () async -> ProtectionPaneWave {
        { await ProtectionPaneRead.wave(world.session, signIn: Account.signedIn, exportSwitch: world.exports) }
    }

    /// ONE vault fetch for the appearance, and every section lands EXACTLY the faces its own read gives (re-read after,
    /// one fetch each). RED ON OLD (the three own refreshes the pane ran — the behavioural revert in the record): three
    /// fetches.
    @Test func anAppearanceReadsTheVaultOnceAndEverySectionLandsWhatItsOwnReadGives() async throws {
        let world = try await world()
        #expect(world.fetches == 0)
        await ProtectionPaneRefresh.wave(
            crossings: world.crossings, account: world.account, keyDoors: world.keyDoors, read: waveRoad(world))
        #expect(world.fetches == 1, "one wire read for the three sections")
        let crossings = try #require(world.crossings.faces)
        let account = try #require(world.account.faces)
        let keyDoors = try #require(world.keyDoors.faces)
        #expect(account.turnOnSync.openDoor != nil, "the account section has its say (the join door)")
        await world.crossings.refresh()
        await world.account.refresh()
        await world.keyDoors.refresh()
        #expect(world.fetches == 4, "each section's own read still reads for itself")
        #expect(world.crossings.faces == crossings && world.account.faces == account && world.keyDoors.faces == keyDoors,
                "the one read derives what each section's own read derives")
    }

    /// The pane's appearance (`RoadStandingModel.refreshPane`): with the bootstrap's wave road, ONE fetch; with none (a
    /// test's hand-made faces), each section reads on its own, as before.
    @Test func thePanesAppearanceTakesTheWaveRoadWhenTheBootstrapGivesOne() async throws {
        let world = try await world()
        let suite = PassphraseReminderTests.Suite()
        defer { withExtendedLifetime(suite) {} }
        let reminder = PassphraseReminderModel(
            libraryID: "lib", moment: nil, ledger: PassphraseReminderLedger(defaults: suite.defaults),
            facts: { (passphraseSet: false, dismissals: 0) }, recordDismissal: { true })
        let standing = RoadStandingModel(
            faces: .none, reminder: reminder, setPassphrase: { _ in .set }, passphraseExists: { false },
            receiptsOwed: { [] })
        standing.crossings = world.crossings
        standing.account = world.account
        standing.keyDoors = world.keyDoors
        await standing.refreshPane()
        #expect(world.fetches == 3, "no wave road: each section on its own")
        standing.paneWave = waveRoad(world)
        await standing.refreshPane()
        #expect(world.fetches == 4, "the wave road: one read for the three")
        #expect(world.crossings.faces != nil && world.account.faces != nil && world.keyDoors.faces != nil)
    }

    /// THE LANDING RULE ACROSS A WAVE: each section's number is taken BEFORE the one read starts, so a section's own read
    /// that started later and landed first is never overwritten by the wave's older faces.
    @Test func aWavesOlderFacesNeverLandOverASectionsNewerRead() async throws {
        let world = try await world()
        let ticket = world.account.beginRead()
        await world.account.refresh()
        let newer = try #require(world.account.faces)
        world.account.land(nil, read: ticket)
        #expect(world.account.faces == newer, "the older read never lands over the newer")
        let keyTicket = world.keyDoors.beginRead()
        await world.keyDoors.refresh()
        world.keyDoors.land(nil, read: keyTicket)
        #expect(world.keyDoors.faces != nil)
        let crossingTicket = world.crossings.beginRead()
        await world.crossings.refresh()
        await world.crossings.land(nil, read: crossingTicket)
        #expect(world.crossings.faces != nil)
    }
}
