//
//  RoadAccountModelTests.swift
//  VariorumTests — VX-308 U1 piece 5: THE ACCOUNT SECTION'S BRAIN over PLANTED roads (pure — no keychain, no disk; also
//  runs headless in the implementer's SwiftPM harness): the doors read and opened through THE ONE PRESENTER, the confirm
//  asking exactly its door's fields, the words' shape checked before the road is asked anything, the typed secrets
//  composed exactly, a door the road found CHANGED re-shown (VX-108), a landed act's receipt spoken once and the pane
//  re-read, Sign in (the Account sheet — R-5) and Sign out (offered only with the composition's road). And THE SIGNED-OUT
//  ROAD through the crossings: Use Castle while signed out shows the screen; Continue runs This Mac Only and hands the
//  floor to Use Castle's own confirm, its receipt ending with the born-Castle sentence.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// Planted account roads with every call recorded.
@MainActor
final class PlantedAccountRoads {
    var faces: RoadAccountFaces?
    var press: RoadAccountPress = .made(receipt: ProtectionWords.turnOnSyncReceipt)
    private(set) var reads = 0
    private(set) var requests: [RoadAccountRequest] = []
    private(set) var landings = 0
    private(set) var spoken: [String] = []
    /// VX-510 unit B1 (D-B0): what happens DURING the press (a re-keying act's reopen attaches fresh services) — nil: nothing.
    var onPress: (@MainActor (RoadAccountRequest) -> Void)?

    var roads: RoadAccountRoads {
        RoadAccountRoads(
            read: { [self] in
                reads += 1
                return faces
            },
            press: { [self] request in
                requests.append(request)
                onPress?(request)
                return press
            },
            landed: { [self] in landings += 1 },
            receipt: { [self] in spoken.append($0) })
    }

    static func setUp(newPassphrase: Bool = true) -> RoadAccountDoorOpen {
        RoadAccountDoorOpen(
            door: .turnOnSync, ask: .passphraseAndWords, newPassphrase: newPassphrase,
            sentences: [ProtectionWords.turnOnSyncLead, ProtectionWords.onePairAtATime,
                        ProtectionWords.turnOnSyncPosture(.standard)],
            spec: DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: false), synced: true, join: .setsUpInLibrarysMode))
    }

    static func leave(_ door: RoadAccountDoor) -> RoadAccountDoorOpen {
        RoadAccountDoorOpen(
            door: door, ask: .nothing, newPassphrase: false, sentences: RoadAccountFaces.leaveSentences(door),
            spec: DoorSpec(requires: .none))
    }

    static func faces(
        situation: RoadAccountSituation = .localOnly, turnOnSync: RoadAccountDoorFace = .open(setUp()),
        stopSyncing: RoadAccountDoorFace = .hidden, thisMacOnly: RoadAccountDoorFace = .hidden,
        signOut: Bool = true, signIn: Bool = false
    ) -> RoadAccountFaces {
        RoadAccountFaces(
            situation: situation, turnOnSync: turnOnSync, stopSyncingHere: stopSyncing, deleteAccountHere: .hidden,
            thisMacOnly: thisMacOnly, move: .hidden, signOut: signOut, signIn: signIn, vaultUnreachable: false)
    }
}

/// The signed-out road's planted leave (its answer and its calls).
@MainActor
final class LeaveRoad {
    var answer: String?
    var calls = 0
    init(answer: String?) { self.answer = answer }
}

@Suite("VX-308 U1 — the account section's brain over planted roads")
@MainActor
struct RoadAccountModelTests {
    static let words = (try? RecoveryPhrase.generate()) ?? []
    static var wordsText: String { words.joined(separator: " ") }

    @Test func theDoorsAreReadAndAnOpenDoorOpensItsConfirmThroughThePresenter() async throws {
        let planted = PlantedAccountRoads()
        planted.faces = PlantedAccountRoads.faces()
        let presenter = ProtectionSheetPresenter()
        let model = RoadAccountModel(roads: planted.roads, presenter: presenter)
        model.open(.turnOnSync)
        #expect(model.confirm == nil, "nothing read yet")
        await model.refresh()
        #expect(model.faces == planted.faces)
        model.open(.stopSyncingHere)
        #expect(model.confirm == nil, "a hidden door has no confirm")
        model.open(.turnOnSync)
        let confirm = try #require(model.confirm)
        #expect(confirm.title == ProtectionWords.turnOnSyncTitle && confirm.button == ProtectionWords.turnOnSyncButton)
        #expect(presenter.sheet(for: .settings)?.id == confirm.id)
        model.open(.turnOnSync)
        #expect(model.confirm === confirm, "one sheet at a time")
    }

    /// The fields are exactly the door's: turning sync on — both, a new passphrase twice; a leave — nothing typed.
    @Test func theButtonWaitsForEveryFieldTheAskNames() {
        let setUp = RoadAccountConfirmModel(door: PlantedAccountRoads.setUp(), act: { _ in .refused("x") }) { _ in }
        #expect(!setUp.canSubmit(passphrase: "p", again: "p", words: ""))
        #expect(!setUp.canSubmit(passphrase: "p", again: "", words: Self.wordsText))
        #expect(setUp.canSubmit(passphrase: "p", again: "p", words: Self.wordsText))
        let current = RoadAccountConfirmModel(
            door: PlantedAccountRoads.setUp(newPassphrase: false), act: { _ in .refused("x") }) { _ in }
        #expect(current.canSubmit(passphrase: "p", again: "", words: Self.wordsText), "the current passphrase is typed once")
        let leave = RoadAccountConfirmModel(door: PlantedAccountRoads.leave(.stopSyncingHere), act: { _ in .refused("x") }) { _ in }
        #expect(leave.canSubmit(passphrase: "", again: "", words: ""), "rule 16: a leave types nothing")
    }

    /// The words' shape and the two new passphrases are checked BEFORE the road is asked anything; the typed secrets are
    /// composed exactly (a NEW passphrase rides as the new one, untrimmed; the words as typed); a leave sends nothing.
    @Test func thePressIsShapedBeforeTheRoadAndComposedExactly() async throws {
        let planted = PlantedAccountRoads()
        planted.press = .refused("no")
        let setUp = RoadAccountConfirmModel(door: PlantedAccountRoads.setUp(), act: planted.roads.press) { _ in }
        await setUp.submit(passphrase: "p", again: "p", words: "one two three")
        #expect(setUp.refusal == ProtectionWords.wordsWrongCount(3))
        await setUp.submit(passphrase: "a new passphrase", again: "a new passphrase!", words: Self.wordsText)
        #expect(setUp.refusal == ProtectionWords.setPassphraseMismatch && planted.requests.isEmpty)
        await setUp.submit(passphrase: " spaced passphrase ", again: " spaced passphrase ", words: "  " + Self.wordsText + "\n")
        let sent = try #require(planted.requests.last)
        #expect(sent.door == .turnOnSync && sent.shown == PlantedAccountRoads.setUp())
        #expect(sent.typed.newPassphrase == " spaced passphrase " && sent.typed.passphrase == nil && sent.typed.words == Self.words)
        #expect(!sent.typed.wordsAreNew, "rule 7: the words are typed, never made new")
        #expect(setUp.refusal == "no")
        let leave = RoadAccountConfirmModel(door: PlantedAccountRoads.leave(.thisMacOnly), act: planted.roads.press) { _ in }
        await leave.submit()
        let left = try #require(planted.requests.last)
        #expect(left.door == .thisMacOnly && left.typed.passphrase == nil && left.typed.words == nil
                && left.typed.newPassphrase == nil)
    }

    /// VX-108 — the road found the door CHANGED: re-shown with a line saying so; the next press carries the new door.
    @Test func aChangedDoorIsReShownNotActedOn() async throws {
        let planted = PlantedAccountRoads()
        let changed = PlantedAccountRoads.setUp(newPassphrase: false)
        planted.press = .changed(changed)
        var finished: [RoadAccountPress?] = []
        let confirm = RoadAccountConfirmModel(door: PlantedAccountRoads.setUp(), act: planted.roads.press) { finished.append($0) }
        await confirm.submit(passphrase: "a new passphrase", again: "a new passphrase", words: Self.wordsText)
        #expect(confirm.door == changed && confirm.refusal == ProtectionWords.crossingDoorChanged && finished.isEmpty)
        planted.press = .made(receipt: "done")
        await confirm.submit(passphrase: "p", again: "", words: Self.wordsText)
        #expect(planted.requests.last?.shown == changed && finished == [.made(receipt: "done")])
    }

    /// The act landed: the confirm goes, the receipt is spoken ONCE, the pane re-reads (this section and the crossings).
    @Test func aLandedActSpeaksItsReceiptOnceAndThePaneReReads() async throws {
        let planted = PlantedAccountRoads()
        planted.faces = PlantedAccountRoads.faces(situation: .inSync(email: nil), turnOnSync: .hidden,
                                                  stopSyncing: .open(PlantedAccountRoads.leave(.stopSyncingHere)))
        planted.press = .made(receipt: ProtectionWords.stopSyncingReceipt)
        let model = RoadAccountModel(roads: planted.roads)
        await model.refresh()
        model.open(.stopSyncingHere)
        let readsBefore = planted.reads
        try await #require(model.confirm).submit()
        #expect(model.confirm == nil && planted.spoken == [ProtectionWords.stopSyncingReceipt])
        for _ in 0..<10_000 where planted.landings == 0 { await Task.yield() }
        #expect(planted.reads > readsBefore && planted.landings == 1)
        // Cancel writes nothing and speaks nothing.
        model.open(.stopSyncingHere)
        try #require(model.confirm).cancel()
        #expect(model.confirm == nil && planted.requests.count == 1 && planted.spoken.count == 1)
    }

    /// Sign in (R-5): the Account sheet through the presenter, only where no one is signed in; its close re-reads.
    @Test func signInOpensTheAccountSheetAndItsCloseReReads() async throws {
        let planted = PlantedAccountRoads()
        planted.faces = PlantedAccountRoads.faces(turnOnSync: .refused(ProtectionWords.accountSignInToTurnOnSync),
                                                  signOut: false, signIn: true)
        let presenter = ProtectionSheetPresenter()
        let model = RoadAccountModel(roads: planted.roads, presenter: presenter)
        await model.refresh()
        model.openSignIn()
        guard case .signIn(let request)? = presenter.sheet(for: .settings) else {
            Issue.record("the Account sheet stands")
            return
        }
        let reads = planted.reads
        presenter.dismiss(request.id)
        for _ in 0..<10_000 where planted.landings == 0 { await Task.yield() }
        #expect(planted.reads > reads)
    }

    /// Sign out: offered only with the composition's road (P-2); confirmed — the road ran, the pane re-reads; Cancel —
    /// nothing.
    @Test func signOutIsOfferedOnlyWithItsRoad() async throws {
        let planted = PlantedAccountRoads()
        planted.faces = PlantedAccountRoads.faces(situation: .inSync(email: nil), turnOnSync: .hidden)
        let presenter = ProtectionSheetPresenter()
        let model = RoadAccountModel(roads: planted.roads, presenter: presenter)
        await model.refresh()
        #expect(!model.offersSignOut)
        model.openSignOut()
        #expect(presenter.sheet == nil, "no road, no door")
        var signOuts = 0
        model.signOutRoad = { signOuts += 1 }
        #expect(model.offersSignOut)
        model.openSignOut()
        try #require(model.signOutConfirm).cancel()
        #expect(signOuts == 0 && presenter.sheet == nil)
        model.openSignOut()
        try await #require(model.signOutConfirm).confirm()
        #expect(signOuts == 1 && presenter.sheet == nil)
        for _ in 0..<10_000 where planted.landings == 0 { await Task.yield() }
        #expect(planted.landings == 1, "the pane re-read after the sign-out")
    }

    /// THE SIGNED-OUT ROAD (VX-264 as amended): Use Castle while signed out shows the screen; Continue runs This Mac Only,
    /// re-reads, and hands the floor to Use Castle's own confirm on the now-local library — its receipt ending with the
    /// born-Castle sentence; a refused leave says so in the screen; Cancel writes nothing.
    @Test func theSignedOutRoadLeavesThenHandsTheFloorToUseCastle() async throws {
        let planted = PlantedCrossingRoads()
        let signedOut = RoadCrossingFaces(
            mode: .standard, useCastle: .signedOutRoad, useStandard: .hidden,
            replaceAllKeys: .refused(ProtectionWords.doorRefusedSignedOut), gateRow: nil)
        planted.faces = signedOut
        let leave = LeaveRoad(answer: ProtectionWords.copyDoorBusy)
        var roads = planted.roads
        roads.leaveForThisMacOnly = {
            leave.calls += 1
            if leave.answer == nil { planted.faces = PlantedCrossingRoads.faces() }
            return leave.answer
        }
        let presenter = ProtectionSheetPresenter()
        let crossings = RoadCrossingsModel(roads: roads, presenter: presenter)
        await crossings.refresh()
        crossings.open(.useCastle)
        #expect(presenter.sheet == nil, "no confirm from the signed-out face itself")
        crossings.openSignedOutRoad()
        guard case .signedOutCastle(let screen)? = presenter.sheet(for: .settings) else {
            Issue.record("the signed-out screen stands")
            return
        }
        #expect(screen.title == ProtectionWords.signedOutCastleTitle)
        #expect(screen.sentences == [ProtectionWords.signedOutCastleLead, ProtectionWords.signedOutCastleWholeAccount])
        await screen.proceed()
        #expect(screen.refusal == ProtectionWords.copyDoorBusy && leave.calls == 1, "a refused leave is said in the screen")
        leave.answer = nil
        await screen.proceed()
        for _ in 0..<10_000 where crossings.confirm == nil { await Task.yield() }
        let confirm = try #require(crossings.confirm)
        #expect(confirm.door == PlantedCrossingRoads.useCastle() && confirm.receiptNote == ProtectionWords.bornCastleNote)
        await confirm.submit(passphrase: "a new passphrase", again: "a new passphrase", words: Self.wordsText)
        #expect(planted.requests.last?.receiptNote == ProtectionWords.bornCastleNote)
        // Cancel on a fresh screen writes nothing.
        planted.faces = signedOut
        await crossings.refresh()
        crossings.openSignedOutRoad()
        guard case .signedOutCastle(let second)? = presenter.sheet else {
            Issue.record("a second screen")
            return
        }
        second.cancel()
        #expect(presenter.sheet == nil && leave.calls == 2)
    }
}
