//
//  RoadCrossingSurfaceTests.swift
//  VariorumTests — VX-307 U2a piece 5: THE CROSSINGS' MAC FACES build and lay out (hosted in a real window — a face that
//  crashes or cannot lay out fails here), and Settings ▸ Protection renders the crossings' section from the bootstrap's
//  model (VX-329 U1: today's rows, and the gate that showed them on today's road, were deleted with it). The faces' logic is the models' (pinned headless — `RoadCrossingModelTests`,
//  `RoadCrossingFacesTests`); this suite pins the composition. Mac only (hosting).
//

import Foundation
import SwiftUI
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("VX-307 U2a — the crossings' Mac faces (hosted) and the pane's road sections", .serialized)
struct RoadCrossingSurfaceTests {
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
            ProtectionPane(services: nil,
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
            ProtectionPane(services: nil,
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
        await enter.submit(passphrase: "a new passphrase", again: "a new passphrase", words: (try RecoveryPhrase.generate()).joined(separator: " "))
        #expect(enter.refusal == ProtectionWords.wordsDoNotOpen)
        await SurfaceComposition.host(RoadCrossingSheet(model: enter), size: NSSize(width: 480, height: 760))
        let leaveSpec = DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: false), rekeys: true, words: [.ruleFive])
        let leave = RoadCrossingConfirmModel(
            door: RoadCrossingFaces.open(.useStandard, leaveSpec, passphraseSet: true, gate: nil, biometry: .none,
                                         copyName: { _ in nil }),
            act: { _ in .made(exportTurnedOff: false) }) { _ in }
        await SurfaceComposition.host(RoadCrossingSheet(model: leave), size: NSSize(width: 480, height: 600))
    }

    /// THE PANE IS THE ROAD'S (source pin — a Form's conditional sections are not reachable by composition before
    /// hosting, VX-306's adjudication): the crossings' section from the bootstrap's model, then the closing line; today's
    /// rows and their gate are gone (VX-329 U1 — the release switch); the confirm held by the one presenter.
    @Test func thePanesSectionsAreTheRoadsAndTodaysRowsAreGone() throws {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/Features/Settings/ProtectionPane.swift"),
            encoding: .utf8)
        let body = try #require(source.range(of: "var body: some View {")).upperBound
        let rest = String(source[body...])
        let crossings = try #require(rest.range(of: "if let crossings = roadStanding?.crossings {"))
        let keystone = try #require(rest.range(of: "keystoneSection\n"))
        #expect(crossings.lowerBound < keystone.lowerBound)
        #expect(!rest.contains("if roadStanding == nil {"), "no gate for today's rows — there are none")
        #expect(!rest.contains("leadSection"), "today's lead section left with today's road")
        // VX-308 U1 (VX-239 + VX-243): the confirm is held by the bootstrap's ONE PRESENTER and presented through it.
        #expect(rest.contains(".protectionSheets(roadStanding?.sheets, services: services)"))
        #expect(!rest.contains("roadStanding?.crossings?.confirm"), "no second presenter of the crossings' confirm")
    }
}
