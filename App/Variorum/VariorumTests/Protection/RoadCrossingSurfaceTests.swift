//
//  RoadCrossingSurfaceTests.swift
//  VariorumTests — VX-307 U2a piece 5: THE CROSSINGS' MAC FACES build and lay out (hosted in a real window — a face that
//  crashes or cannot lay out fails here), and Settings ▸ Protection's gate is the switch's: on the new road the pane
//  renders the crossings' section from the bootstrap's model and today's rows retire; on today's road (no road model)
//  today's rows render exactly as before. The faces' logic is the models' (pinned headless — `RoadCrossingModelTests`,
//  `RoadCrossingFacesTests`); this suite pins the composition. Mac only (hosting).
//

import Foundation
import SwiftUI
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("VX-307 U2a — the crossings' Mac faces (hosted) and the pane's gate", .serialized)
struct RoadCrossingSurfaceTests {
    private func controller() -> ProtectionController {
        let backing = InMemoryStoreKeyGuardBacking(auto: StoreKey.mint(), biometryAvailable: true, biometricSucceeds: true)
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(ProtectionDials()), backing: backing,
            envelope: ScriptedEnvelopeBox(nil), stamps: ScriptedStampsBox())
        return ProtectionController(configuration: .init(
            scope: "Variorum", storeURL: nil, gate: gate, isRealVariant: true,
            makeKDF: { PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32) }))
    }

    private func standing(defaults: UserDefaults, crossings: RoadCrossingsModel?) -> RoadStandingModel {
        let reminder = PassphraseReminderModel(
            libraryID: "lib", moment: nil, ledger: PassphraseReminderLedger(defaults: defaults),
            facts: { (passphraseSet: true, dismissals: 0) }, recordDismissal: { true })
        let model = RoadStandingModel(
            faces: .none, reminder: reminder, setPassphrase: { _ in .alreadySet },
            passphraseExists: { true }, receiptsOwed: { [] })
        model.crossings = crossings
        return model
    }

    /// The pane on the new road: the crossings' section (Standard — Use Castle open; and Castle — Use Standard open, the
    /// gate row, rule 11's notice) hosts and lays out.
    @Test func theNewRoadPaneHostsTheCrossingsSectionInBothPostures() async {
        let suite = PassphraseReminderTests.Suite()
        defer { withExtendedLifetime(suite) {} }
        let planted = PlantedCrossingRoads()
        planted.faces = PlantedCrossingRoads.faces()
        let crossings = RoadCrossingsModel(roads: planted.roads)
        await crossings.refresh()
        await SurfaceComposition.host(
            ProtectionPane(controller: controller(), services: nil,
                           roadStanding: standing(defaults: suite.defaults, crossings: crossings)),
            size: NSSize(width: 640, height: 900))
        let castle = PlantedCrossingRoads()
        let spec = DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: false), rekeys: true, words: [.ruleFive])
        castle.faces = RoadCrossingFaces(
            mode: .castle, useCastle: .hidden,
            useStandard: .open(RoadCrossingFaces.open(.useStandard, spec, passphraseSet: true, gate: .touchID,
                                                      biometry: .ready, copyName: { _ in nil })),
            replaceAllKeys: .refused(ProtectionWords.doorRefusedNeedsVault),
            gateRow: RoadGateRow(current: .touchID, touchIDAvailable: true))
        castle.press = .made(exportTurnedOff: true)
        let inCastle = RoadCrossingsModel(roads: castle.roads)
        await inCastle.refresh()
        await SurfaceComposition.host(
            ProtectionPane(controller: controller(), services: nil,
                           roadStanding: standing(defaults: suite.defaults, crossings: inCastle)),
            size: NSSize(width: 640, height: 900))
    }

    /// The confirm hosts in each shape: Use Castle with a new passphrase, the gate choice and rule 25's copies; Use
    /// Standard with the current passphrase and rule 12's sentence; with a refusal said.
    @Test func theConfirmHostsInEachShape() async throws {
        let castleSpec = DoorSpec(
            requires: .passphraseAndWords(wordsMayBeNew: false), rekeys: true,
            words: [.floorSentence, .exportAPlainCopyFirst, .copiesUnderAKeyThisMacCantDelete(["a"]),
                    .scheduledExportTurnsOff])
        let castle = RoadCrossingFaces.open(
            .useCastle, castleSpec, passphraseSet: false, gate: nil, biometry: .ready, copyName: { _ in "Backup from August 3" })
        #expect(castle.undeletableCopies == ["Backup from August 3"])
        let enter = RoadCrossingConfirmModel(door: castle, act: { _ in .refused(ProtectionWords.wordsDoNotOpen) }) { _ in }
        await SurfaceComposition.host(RoadCrossingSheet(model: enter), size: NSSize(width: 480, height: 760))
        await enter.submit(passphrase: "p", again: "p", words: (try RecoveryPhrase.generate()).joined(separator: " "))
        #expect(enter.refusal == ProtectionWords.wordsDoNotOpen)
        await SurfaceComposition.host(RoadCrossingSheet(model: enter), size: NSSize(width: 480, height: 760))
        let leaveSpec = DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: false), rekeys: true, words: [.ruleFive])
        let leave = RoadCrossingConfirmModel(
            door: RoadCrossingFaces.open(.useStandard, leaveSpec, passphraseSet: true, gate: nil, biometry: .none,
                                         copyName: { _ in nil }),
            act: { _ in .made(exportTurnedOff: false) }) { _ in }
        await SurfaceComposition.host(RoadCrossingSheet(model: leave), size: NSSize(width: 480, height: 600))
    }

    /// THE PANE'S GATE is the switch's (source pin — a Form's conditional sections are not reachable by composition
    /// before hosting, VX-306's adjudication): the crossings' section from the bootstrap's model, today's rows only with
    /// no road model, the confirm held by that model.
    @Test func thePanesTodayRowsRetireOnTheNewRoadOnly() throws {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/Features/Settings/ProtectionPane.swift"),
            encoding: .utf8)
        let body = try #require(source.range(of: "var body: some View {")).upperBound
        let rest = String(source[body...])
        let crossings = try #require(rest.range(of: "if let crossings = roadStanding?.crossings {"))
        let todayGate = try #require(rest.range(of: "if roadStanding == nil {"))
        let lead = try #require(rest.range(of: "leadSection\n"))
        let keystone = try #require(rest.range(of: "keystoneSection\n"))
        #expect(crossings.lowerBound < todayGate.lowerBound && todayGate.lowerBound < lead.lowerBound)
        #expect(lead.lowerBound < keystone.lowerBound)
        // VX-308 U1 (VX-239 + VX-243): the confirm is held by the bootstrap's ONE PRESENTER and presented through it.
        #expect(rest.contains(".protectionSheets(roadStanding?.sheets, services: services)"))
        #expect(!rest.contains("roadStanding?.crossings?.confirm"), "no second presenter of the crossings' confirm")
    }
}
