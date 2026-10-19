//
//  RoadCrossingModelTests.swift
//  VariorumTests — VX-307 U2a piece 3: THE CROSSINGS' BRAIN over PLANTED roads (pure — no keychain, no disk; also runs
//  headless in the implementer's SwiftPM harness): the doors read and opened, the confirm asking exactly its door's
//  fields, the words' shape checked before the road is asked anything, a new passphrase typed twice, the typed secrets
//  composed exactly, a door the road found CHANGED re-shown (VX-108), rule 11's notice standing until OK or reversed,
//  and the gate-style row (Touch ID only with the passphrase).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// Planted roads with every call recorded.
@MainActor
final class PlantedCrossingRoads {
    var faces: RoadCrossingFaces?
    var press: RoadCrossingPress = .made(exportTurnedOff: false)
    var gateOutcome: GateChangeOutcome = .changed
    var exportBackOn = true
    private(set) var reads = 0
    private(set) var requests: [RoadCrossingRequest] = []
    private(set) var gateCalls: [(GateStyle, String?)] = []
    private(set) var exportCalls = 0
    /// Rule 11's notice owed — the road's durable mark (MAJOR-1).
    var noticeOwed = false
    private(set) var dismissCalls = 0

    var roads: RoadCrossingRoads {
        RoadCrossingRoads(
            read: { [self] in
                reads += 1
                return faces
            },
            cross: { [self] request in
                requests.append(request)
                // The production road writes rule 11's durable mark before the act (MAJOR-1).
                if press == .made(exportTurnedOff: true) { noticeOwed = true }
                return press
            },
            changeGate: { [self] gate, passphrase in
                gateCalls.append((gate, passphrase))
                return gateOutcome
            },
            turnExportBackOn: { [self] in
                exportCalls += 1
                if exportBackOn { noticeOwed = false }
                return exportBackOn
            },
            exportNoticeOwed: { [self] in noticeOwed },
            dismissExportNotice: { [self] in
                dismissCalls += 1
                noticeOwed = false
            })
    }

    static func useCastle(newPassphrase: Bool = true, touchID: Bool = true, words: [String] = []) -> RoadDoorOpen {
        let spec = DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: false), rekeys: true,
                            words: [.floorSentence, .exportAPlainCopyFirst] + words.map { _ in Words.scheduledExportTurnsOff })
        return RoadCrossingFaces.open(
            .useCastle, spec, passphraseSet: !newPassphrase, gate: nil,
            biometry: touchID ? .ready : .none, copyName: { _ in nil })
    }

    static func faces(_ useCastle: RoadDoorOpen? = useCastle(), gate: RoadGateRow? = nil) -> RoadCrossingFaces {
        RoadCrossingFaces(
            mode: gate == nil ? .standard : .castle, useCastle: useCastle.map(RoadDoorFace.open) ?? .hidden,
            useStandard: .hidden, replaceAllKeys: .hidden, gateRow: gate)
    }
}

@Suite("VX-307 U2a — the crossings' brain over planted roads")
@MainActor
struct RoadCrossingModelTests {
    static let words = (try? RecoveryPhrase.generate()) ?? []
    static var wordsText: String { words.joined(separator: " ") }

    @Test func theDoorsAreReadAndAnOpenDoorOpensItsConfirmOnTheGateChoice() async throws {
        let planted = PlantedCrossingRoads()
        planted.faces = PlantedCrossingRoads.faces()
        let model = RoadCrossingsModel(roads: planted.roads)
        model.open(.useCastle)
        #expect(model.confirm == nil, "nothing read yet — no door to open")
        await model.refresh()
        #expect(model.faces == planted.faces)
        model.open(.useStandard)
        #expect(model.confirm == nil, "a hidden door has no confirm")
        model.open(.useCastle)
        let confirm = try #require(model.confirm)
        #expect(confirm.title == ProtectionWords.useCastleTitle)
        #expect(confirm.gate == .touchID && confirm.asksNewPassphrase)
        // One confirm at a time.
        model.open(.useCastle)
        #expect(model.confirm === confirm)
    }

    /// The fields are exactly the door's: both typed; a new passphrase twice.
    @Test func theButtonWaitsForEveryFieldTheAskNames() async throws {
        let confirm = RoadCrossingConfirmModel(door: PlantedCrossingRoads.useCastle(), act: { _ in .refused("x") }) { _ in }
        #expect(!confirm.canSubmit(passphrase: "p", again: "p", words: ""))
        #expect(!confirm.canSubmit(passphrase: "p", again: "", words: Self.wordsText))
        #expect(!confirm.canSubmit(passphrase: "", again: "", words: Self.wordsText))
        #expect(confirm.canSubmit(passphrase: "p", again: "p", words: Self.wordsText))
        let current = RoadCrossingConfirmModel(
            door: PlantedCrossingRoads.useCastle(newPassphrase: false), act: { _ in .refused("x") }) { _ in }
        #expect(current.canSubmit(passphrase: "p", again: "", words: Self.wordsText), "the current passphrase is typed once")
    }

    /// The words' shape and the two new passphrases are checked BEFORE the road is asked anything.
    @Test func aMisshapenPressNeverReachesTheRoad() async throws {
        let planted = PlantedCrossingRoads()
        let confirm = RoadCrossingConfirmModel(door: PlantedCrossingRoads.useCastle(), act: planted.roads.cross) { _ in }
        await confirm.submit(passphrase: "p", again: "p", words: "one two three")
        #expect(confirm.refusal == ProtectionWords.wordsWrongCount(3))
        await confirm.submit(passphrase: "p", again: "q", words: Self.wordsText)
        #expect(confirm.refusal == ProtectionWords.setPassphraseMismatch)
        #expect(planted.requests.isEmpty)
    }

    /// The typed secrets are composed exactly: a NEW passphrase rides as the new one (rule 3); a current one as the
    /// passphrase; the words as typed; Use Castle's gate choice; untrimmed.
    @Test func theTypedSecretsAreComposedExactly() async throws {
        let planted = PlantedCrossingRoads()
        planted.press = .refused("no")
        let new = RoadCrossingConfirmModel(door: PlantedCrossingRoads.useCastle(), act: planted.roads.cross) { _ in }
        new.gate = .alwaysAsk
        await new.submit(passphrase: " spaced ", again: " spaced ", words: "  " + Self.wordsText + "\n")
        let first = try #require(planted.requests.last)
        #expect(first.door == .useCastle && first.gate == .alwaysAsk)
        #expect(first.typed.newPassphrase == " spaced " && first.typed.passphrase == nil)
        #expect(first.typed.words == Self.words)
        #expect(new.refusal == "no")
        let current = RoadCrossingConfirmModel(
            door: PlantedCrossingRoads.useCastle(newPassphrase: false), act: planted.roads.cross) { _ in }
        await current.submit(passphrase: "mine", again: "", words: Self.wordsText)
        let second = try #require(planted.requests.last)
        #expect(second.typed.passphrase == "mine" && second.typed.newPassphrase == nil)
        #expect(second.gate == .touchID, "the preselected choice where Touch ID works here")
        // A door with no gate choice (Use Standard) rides Always ask, whatever the confirm holds.
        let spec = DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: false), rekeys: true, words: [.ruleFive])
        let leave = RoadCrossingConfirmModel(
            door: RoadCrossingFaces.open(.useStandard, spec, passphraseSet: true, gate: .touchID, biometry: .ready,
                                         copyName: { _ in nil }),
            act: planted.roads.cross) { _ in }
        await leave.submit(passphrase: "mine", again: "", words: Self.wordsText)
        #expect(planted.requests.last?.door == .useStandard && planted.requests.last?.gate == .alwaysAsk)
    }

    /// VX-108 — the road found the door CHANGED: re-shown with its new words and a line saying so; the next press carries
    /// the new door.
    @Test func aChangedDoorIsReShownNotActedOn() async throws {
        let planted = PlantedCrossingRoads()
        let shown = PlantedCrossingRoads.useCastle()
        let changed = PlantedCrossingRoads.useCastle(words: ["export"])
        planted.press = .changed(changed)
        var finished: [RoadCrossingPress?] = []
        let confirm = RoadCrossingConfirmModel(door: shown, act: planted.roads.cross) { finished.append($0) }
        await confirm.submit(passphrase: "p", again: "p", words: Self.wordsText)
        #expect(confirm.door == changed && confirm.refusal == ProtectionWords.crossingDoorChanged)
        #expect(finished.isEmpty)
        planted.press = .made(exportTurnedOff: true)
        await confirm.submit(passphrase: "p", again: "p", words: Self.wordsText)
        #expect(planted.requests.last?.shown == changed)
        #expect(finished == [.made(exportTurnedOff: true)])
    }

    /// The crossing landed: the confirm goes, rule 11's notice stands when owed, the doors are re-read.
    @Test func aCrossingThatLandedClosesTheConfirmAndOwesTheNotice() async throws {
        let planted = PlantedCrossingRoads()
        planted.faces = PlantedCrossingRoads.faces()
        planted.press = .made(exportTurnedOff: true)
        let model = RoadCrossingsModel(roads: planted.roads)
        await model.refresh()
        model.open(.useCastle)
        let confirm = try #require(model.confirm)
        let readsBefore = planted.reads
        await confirm.submit(passphrase: "p", again: "p", words: Self.wordsText)
        #expect(model.confirm == nil)
        #expect(model.exportNotice)
        await model.refresh()
        #expect(planted.reads > readsBefore)
        // The reversal failing keeps the notice and says so; succeeding retires it.
        planted.exportBackOn = false
        await model.turnExportBackOn()
        #expect(model.exportNotice && model.exportNoticeMessage == ProtectionWords.exportTurnBackOnFailed)
        planted.exportBackOn = true
        await model.turnExportBackOn()
        #expect(!model.exportNotice && model.exportNoticeMessage == nil && planted.exportCalls == 2)
    }

    /// No notice owed — none shown; OK retires one; Cancel writes nothing and closes the confirm.
    @Test func theNoticeIsOwedOnlyByTheActAndCancelWritesNothing() async throws {
        let planted = PlantedCrossingRoads()
        planted.faces = PlantedCrossingRoads.faces()
        let model = RoadCrossingsModel(roads: planted.roads)
        await model.refresh()
        model.open(.useCastle)
        try #require(model.confirm).cancel()
        #expect(model.confirm == nil && planted.requests.isEmpty)
        model.open(.useCastle)
        try await #require(model.confirm).submit(passphrase: "p", again: "p", words: Self.wordsText)
        #expect(!model.exportNotice)
        planted.press = .made(exportTurnedOff: true)
        model.open(.useCastle)
        try await #require(model.confirm).submit(passphrase: "p", again: "p", words: Self.wordsText)
        model.exportNoticeOK()
        #expect(!model.exportNotice && planted.exportCalls == 0, "OK reverses nothing")
        #expect(planted.dismissCalls == 1 && !planted.noticeOwed, "OK clears the durable mark")
    }

    /// LADDER ROUND 1, MAJOR-1 — the notice is the road's DURABLE mark, re-read at every refresh: a model made fresh (a
    /// relaunch after a quit before OK, or an entry finished by a later open's settle) shows it with no crossing in this
    /// process; OK clears it for good.
    @Test func major1_theNoticeIsReReadFromTheDurableMark() async {
        let planted = PlantedCrossingRoads()
        planted.faces = PlantedCrossingRoads.faces()
        planted.noticeOwed = true
        let model = RoadCrossingsModel(roads: planted.roads)
        #expect(!model.exportNotice)
        await model.refresh()
        #expect(model.exportNotice, "owed with no crossing in this process")
        model.exportNoticeOK()
        await model.refresh()
        #expect(!model.exportNotice && planted.dismissCalls == 1)
    }

    /// THE GATE-STYLE ROW: Always ask at once; Touch ID only after the passphrase is asked — a refusal said, a change
    /// re-reads the doors.
    @Test func theGateRowAsksThePassphraseForTouchIDAndNotForAlwaysAsk() async throws {
        let planted = PlantedCrossingRoads()
        planted.faces = PlantedCrossingRoads.faces(nil, gate: RoadGateRow(current: .alwaysAsk, touchIDAvailable: true))
        let model = RoadCrossingsModel(roads: planted.roads)
        await model.refresh()
        await model.useTouchID(passphrase: "p")
        #expect(planted.gateCalls.isEmpty, "never without the ask")
        model.beginTouchID()
        #expect(model.gateAsksPassphrase)
        planted.gateOutcome = .refused(ProtectionWords.passphraseDoesNotOpen)
        await model.useTouchID(passphrase: "wrong")
        #expect(model.gateRefusal == ProtectionWords.passphraseDoesNotOpen && model.gateAsksPassphrase)
        planted.gateOutcome = .changed
        let reads = planted.reads
        await model.useTouchID(passphrase: "right")
        #expect(!model.gateAsksPassphrase && model.gateRefusal == nil && planted.reads == reads + 1)
        await model.useAlwaysAsk()
        #expect(planted.gateCalls.map(\.0) == [.touchID, .touchID, .alwaysAsk])
        #expect(planted.gateCalls.map(\.1) == ["wrong", "right", nil])
    }
}
