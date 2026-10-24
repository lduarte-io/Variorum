//
//  FirstRoundConfirmTests.swift
//  VariorumTests — VX-510 unit A: THE ACCOUNT CONFIRM'S FIRST ROUND over PLANTED roads (pure — no keychain, no disk, no
//  server; also runs headless in the implementer's SwiftPM harness).
//    - VX-498 (D-A1): the doors whose landing changes sync's standing on the OPEN session — Turn on sync's set-up, a join in
//      the same posture, Move in the same posture — ask the composition's first-round road ONCE, at `.made`. A leave never
//      asks (sync stops there); a re-keying act never asks (it lands through the reopen, whose fresh services run their
//      own round — F-6); a refused or changed press never asks. With no road (the phone until VM-8) nothing is asked.
//    - VX-507 (D-A2): the sheet does not close on its own at `.made` — after any words moment it shows the round's progress,
//      then its outcome: a success line, or what blocks it in the SYNC ROW's own sentence (one presentation source,
//      `SyncStatusRow.line(for:lastSuccessAt:)`), per status class. Done — always open — closes it and never cancels the
//      round; a window closing under it is Done. With no road the sheet finishes exactly as before. Words PROVISIONAL, hers
//      (P-VX510-1).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// The composition's first-round road, planted: every ask counted, its outcome chosen.
@MainActor
final class PlantedFirstRound {
    private(set) var asks = 0
    var outcome: FirstRoundOutcome = .ran(PlantedFirstRound.clean)

    /// A clean round's status (what `SyncScheduler` leaves after one).
    static var clean: SyncScheduler.Status {
        var status = SyncScheduler.Status()
        status.lastSuccessAt = Date(timeIntervalSince1970: 1_782_864_000)
        status.roundsCompleted = 1
        return status
    }

    var road: @MainActor () async -> FirstRoundOutcome {
        { [self] in
            asks += 1
            return outcome
        }
    }
}

/// VX-510 unit B1 (D-B0): the composition's RE-KEYING road, planted — the services generation (moved on by `attach()`, as
/// the reopen's attach does during the press) and every round asked, with the generation it was asked with.
@MainActor
final class PlantedReopenRound {
    private(set) var generation: Int
    private(set) var asks: [Int] = []
    var outcome: FirstRoundOutcome = .ran(PlantedFirstRound.clean)

    init(generation: Int = 0) { self.generation = generation }

    /// The reopen attached fresh services.
    func attach() { generation += 1 }

    var road: RoadAccountModel.FirstRoundAfterReopen {
        RoadAccountModel.FirstRoundAfterReopen(
            generation: { [self] in generation },
            round: { [self] asked in
                asks.append(asked)
                return outcome
            })
    }
}

/// A first-round road that parks until `release()` — the round provably running while the sheet stands.
@MainActor
final class GatedFirstRound {
    private(set) var asks = 0
    private var waiter: CheckedContinuation<Void, Never>?
    /// Whether the asking task was cancelled when the round came back (Done must never cancel it).
    private(set) var cancelledAtResume: Bool?
    var outcome: FirstRoundOutcome = .ran(PlantedFirstRound.clean)

    var road: @MainActor () async -> FirstRoundOutcome {
        { [self] in
            asks += 1
            await withCheckedContinuation { waiter = $0 }
            cancelledAtResume = Task.isCancelled
            return outcome
        }
    }

    /// Waits for the round to be asked and parked, then lets it come back.
    func release() async {
        for _ in 0..<10_000 where waiter == nil { await Task.yield() }
        waiter?.resume()
        waiter = nil
    }
}

@Suite("VX-510 unit A — the account confirm's first round (planted roads)")
@MainActor
struct FirstRoundConfirmTests {
    static let words = (try? RecoveryPhrase.generate()) ?? []
    static var wordsText: String { words.joined(separator: " ") }

    /// Move in `plan` (the door `RoadAccountFaces.joinDoor` builds for the account signed in).
    static func move(_ plan: JoinPlan = .sameMode) -> RoadAccountDoorOpen {
        RoadAccountDoorOpen(
            door: .moveToSignedInAccount, ask: .oneSecret, newPassphrase: false,
            sentences: [ProtectionWords.moveLead, ProtectionWords.ruleSixteen],
            spec: DoorSpec(requires: .oneSecret, rekeys: plan != .sameMode, synced: true, join: plan),
            label: ProtectionWords.moveDoor(PlantedAccount.email))
    }

    /// The section showing `open` behind `door`, the road planted, the confirm opened and pressed with what its ask types.
    private func press(
        _ door: RoadAccountDoor, _ open: RoadAccountDoorOpen, press: RoadAccountPress = .made(receipt: "landed"),
        round: PlantedFirstRound?
    ) async throws -> RoadAccountConfirmModel {
        try await self.press(door, open, press: press, road: round?.road).confirm
    }

    /// …with any road, returning the section, its planted roads and the confirm.
    private func press(
        _ door: RoadAccountDoor, _ open: RoadAccountDoorOpen, press: RoadAccountPress = .made(receipt: "landed"),
        road: (@MainActor () async -> FirstRoundOutcome)?, reopen: PlantedReopenRound? = nil,
        words typedWords: String? = nil
    ) async throws -> (model: RoadAccountModel, planted: PlantedAccountRoads, confirm: RoadAccountConfirmModel) {
        let planted = PlantedAccountRoads()
        planted.press = press
        // D-B0: a re-keying act's reopen attaches fresh services DURING the press (the generation moves on).
        planted.onPress = { request in if request.shown.rekeys { reopen?.attach() } }
        var faces = PlantedAccountRoads.faces(turnOnSync: .hidden)
        switch door {
        case .turnOnSync: faces = PlantedAccountRoads.faces(turnOnSync: .open(open))
        case .stopSyncingHere:
            faces = PlantedAccountRoads.faces(situation: .inSync(email: nil), turnOnSync: .hidden, stopSyncing: .open(open))
        case .thisMacOnly:
            faces = PlantedAccountRoads.faces(situation: .signedOut, turnOnSync: .hidden, thisMacOnly: .open(open))
        case .deleteAccountHere, .moveToSignedInAccount, .follow:
            faces = RoadAccountFaces(
                situation: .inSync(email: nil), turnOnSync: .hidden, stopSyncingHere: .hidden,
                deleteAccountHere: door == .deleteAccountHere ? .open(open) : .hidden, thisMacOnly: .hidden,
                move: door == .moveToSignedInAccount ? .open(open) : .hidden, signOut: true, signIn: false,
                vaultUnreachable: false, follow: door == .follow ? .open(open) : .hidden)
        }
        planted.faces = faces
        let model = RoadAccountModel(roads: planted.roads)
        model.firstRound = road
        model.firstRoundAfterReopen = reopen?.road
        await model.refresh()
        model.open(door)
        let confirm = try #require(model.confirm, "\(door)'s confirm opens")
        switch open.ask {
        case .passphraseAndWords:
            await confirm.submit(passphrase: "a new passphrase", again: "a new passphrase", words: Self.wordsText)
        case .oneSecret:
            if let typedWords {
                await confirm.submit(words: typedWords)
            } else {
                await confirm.submit(passphrase: "the account's passphrase")
            }
        case .passphrase:
            await confirm.submit(passphrase: "a new passphrase", again: "a new passphrase")
        case .nothing:
            await confirm.submit()
        }
        #expect(planted.requests.count == 1, "\(door) pressed once")
        return (model, planted, confirm)
    }

    /// **VX-498, THE MODEL'S CALL** — the set-up, a same-posture join and a same-posture Move each ask the first-round
    /// road ONCE, at the landing, and the round's outcome comes back.
    @Test func theOpenSessionDoorsAskForTheirFirstRoundAtTheLanding() async throws {
        let doors: [(RoadAccountDoor, RoadAccountDoorOpen)] = [
            (.turnOnSync, PlantedAccountRoads.setUp()),
            (.turnOnSync, PlantedJoin.join(.sameMode)),
            (.moveToSignedInAccount, Self.move(.sameMode)),
        ]
        for (door, open) in doors {
            #expect(open.owesFirstRound, "\(door) \(String(describing: open.spec.join))")
            let round = PlantedFirstRound()
            let confirm = try await press(door, open, round: round)
            #expect(await confirm.awaitFirstRound() == .ran(PlantedFirstRound.clean), "\(door): the round's outcome")
            #expect(round.asks == 1, "\(door) \(String(describing: open.spec.join)): asked once")
        }
    }

    /// A LEAVE never asks (sync stops), whichever roads are wired; with no road nothing is asked and the confirm finishes as
    /// before. (VX-510 unit B1, D-B0 — FLIPPED DELIBERATELY: unit A's form also asserted a RE-KEYING act never asks; F-6 (A)
    /// ruled that it does, through the reopen's fresh services — `aReKeyingActAsksTheReopenRoadWithThePressGeneration`.)
    @Test func aLeaveNeverAsks() async throws {
        let doors: [(RoadAccountDoor, RoadAccountDoorOpen)] = [
            (.stopSyncingHere, PlantedAccountRoads.leave(.stopSyncingHere)),
            (.deleteAccountHere, PlantedAccountRoads.leave(.deleteAccountHere)),
            (.thisMacOnly, PlantedAccountRoads.leave(.thisMacOnly)),
        ]
        for (door, open) in doors {
            #expect(!open.owesFirstRound, "\(door) owes none")
            let round = PlantedFirstRound()
            let reopen = PlantedReopenRound()
            let confirm = try await press(door, open, road: round.road, reopen: reopen).confirm
            #expect(await confirm.awaitFirstRound() == nil, "\(door): no round started")
            #expect(round.asks == 0 && reopen.asks.isEmpty, "\(door): never asked")
        }
        // No road at all: the set-up lands and nothing is asked.
        let confirm = try await press(.turnOnSync, PlantedAccountRoads.setUp(), round: nil)
        #expect(await confirm.awaitFirstRound() == nil)
    }

    /// **VX-510 unit B1, D-B0 (F-6 (A), ruled) — A RE-KEYING ACT ASKS THE REOPEN'S ROAD** (a new seam's pin — red by the
    /// record's reverts): a join entering or leaving Castle, Move entering it, and both follows each owe a first round; the
    /// press takes the services generation BEFORE the act (whose reopen attaches fresh services — the planted press bumps the
    /// generation, as that attach does), and at `.made` the round goes to the REOPEN road with the PRESS's generation — never
    /// to the open session's road, whose services the reopen released. With no reopen road wired (the phone until VM-8) a
    /// re-keying act starts no round (P-2).
    @Test func aReKeyingActAsksTheReopenRoadWithThePressGeneration() async throws {
        let doors: [(RoadAccountDoor, RoadAccountDoorOpen)] = [
            (.turnOnSync, PlantedJoin.join(.entersCastle)),
            (.turnOnSync, PlantedJoin.join(.leavesCastle)),
            (.moveToSignedInAccount, Self.move(.entersCastle)),
            (.follow, PlantedJoin.follow(.intoCastle)),
            (.follow, PlantedJoin.follow(.intoStandard)),
        ]
        for (door, open) in doors {
            #expect(open.owesFirstRound && open.rekeys, "\(door) \(String(describing: open.spec.join)) owes one, re-keying")
            let openSession = PlantedFirstRound()
            let reopen = PlantedReopenRound(generation: 7)
            let (_, planted, confirm) = try await press(door, open, road: openSession.road, reopen: reopen)
            #expect(planted.requests.count == 1)
            #expect(await confirm.awaitFirstRound() == .ran(PlantedFirstRound.clean), "\(door): the round's outcome")
            #expect(reopen.asks == [7], "\(door): the reopen road, asked once with the generation taken at the press")
            #expect(openSession.asks == 0, "\(door): never the open session's road (its services were released)")
            // The success line: the follow's own (PROVISIONAL P-VX510-B1-1); a join's or Move's the join line.
            let expected = door == .follow ? ProtectionWords.firstRoundFollowLanded : ProtectionWords.firstRoundJoinLanded
            #expect(confirm.roundLine == expected, "\(door): \(String(describing: confirm.roundLine))")
        }
        // No reopen road: a re-keying act starts no round, even with the open session's road wired.
        let openSession = PlantedFirstRound()
        let confirm = try await press(.turnOnSync, PlantedJoin.join(.entersCastle), road: openSession.road).confirm
        #expect(await confirm.awaitFirstRound() == nil && openSession.asks == 0)
    }

    /// D-B0 — THE PRESSED DOOR CHOOSES THE ROAD: a same-posture join re-shown CHANGED into one that enters Castle (the
    /// account entered Castle elsewhere meanwhile — VX-108) is pressed again, and its round goes to the reopen road; the
    /// open session's road is never asked.
    @Test func aDoorReShownAsReKeyingTakesTheReopenRoad() async throws {
        let openSession = PlantedFirstRound()
        let reopen = PlantedReopenRound(generation: 3)
        let (model, planted, confirm) = try await press(
            .turnOnSync, PlantedJoin.join(.sameMode), press: .changed(PlantedJoin.join(.entersCastle)),
            road: openSession.road, reopen: reopen)
        #expect(confirm.refusal == ProtectionWords.crossingDoorChanged && confirm.round == nil)
        planted.press = .made(receipt: "joined")
        confirm.gate = .alwaysAsk
        await confirm.submit(passphrase: "the account's passphrase")
        #expect(planted.requests.count == 2 && planted.requests.last?.shown.rekeys == true)
        #expect(await confirm.awaitFirstRound() == .ran(PlantedFirstRound.clean))
        #expect(reopen.asks == [3] && openSession.asks == 0, "the pressed door's road")
        #expect(model.confirm === confirm, "the sheet stays for the round")
    }

    /// A refused press, or one whose door CHANGED (VX-108), lands nothing — and asks for no round.
    @Test func aRefusedOrChangedPressNeverAsks() async throws {
        for press in [RoadAccountPress.refused("no"), .changed(PlantedAccountRoads.setUp(newPassphrase: false))] {
            let round = PlantedFirstRound()
            let confirm = try await self.press(.turnOnSync, PlantedAccountRoads.setUp(), press: press, round: round)
            #expect(await confirm.awaitFirstRound() == nil && round.asks == 0, "\(press)")
        }
    }

    // MARK: - VX-507 (D-A2): the sheet confirms its first round

    /// **VX-507 — THE SHEET STAYS** at `.made`, showing the round's progress while it runs (Done open throughout), then its
    /// outcome; the act's receipt is spoken ONCE, at the landing — Done says nothing more.
    @Test func theSheetStaysShowingTheRoundsProgressThenItsOutcome() async throws {
        let gated = GatedFirstRound()
        let (model, planted, confirm) = try await press(.turnOnSync, PlantedAccountRoads.setUp(), road: gated.road)
        #expect(model.confirm === confirm, "the sheet stays after the act landed")
        #expect(confirm.round == .running && confirm.roundLine == nil, "the progress while the round runs")
        #expect(planted.spoken == ["landed"], "the act's receipt, spoken at the landing")
        await gated.release()
        #expect(await confirm.awaitFirstRound() == .ran(PlantedFirstRound.clean))
        #expect(confirm.round == .done(.ran(PlantedFirstRound.clean)))
        #expect(confirm.roundLine == ProtectionWords.firstRoundSetUpLanded)
        #expect(model.confirm === confirm, "the outcome stands until Done")
        confirm.done()
        #expect(model.confirm == nil, "Done closes it")
        for _ in 0..<10_000 where planted.landings == 0 { await Task.yield() }
        #expect(planted.spoken == ["landed"] && planted.landings == 1, "landed once — Done speaks nothing more")
    }

    /// **VX-507 — DONE NEVER CANCELS THE ROUND**: Done while the round runs closes the sheet at once; the round comes back
    /// afterwards, never cancelled; a window closing under the round phase (the host's dismissal → `cancel`) is Done —
    /// the act's landing, never "she left".
    @Test func doneClosesTheSheetAndNeverCancelsTheRound() async throws {
        let gated = GatedFirstRound()
        let (model, _, confirm) = try await press(.turnOnSync, PlantedAccountRoads.setUp(), road: gated.road)
        #expect(confirm.round == .running)
        confirm.done()
        #expect(model.confirm == nil, "Done closed the sheet while the round ran")
        await gated.release()
        #expect(await confirm.awaitFirstRound() == .ran(PlantedFirstRound.clean), "the round came back")
        #expect(gated.cancelledAtResume == false, "never cancelled")

        var finished: [RoadAccountPress?] = []
        let closing = GatedFirstRound()
        let hosted = RoadAccountConfirmModel(
            door: PlantedAccountRoads.setUp(), act: { _ in .made(receipt: "landed") }, firstRound: closing.road,
            finished: { finished.append($0) })
        await hosted.submit(passphrase: "a new passphrase", again: "a new passphrase", words: Self.wordsText)
        #expect(hosted.round == .running && finished.isEmpty)
        hosted.cancel()
        #expect(finished == [.made(receipt: "landed")], "a window closing under the round is Done — the act landed")
        await closing.release()
        #expect(await hosted.awaitFirstRound() != nil && closing.cancelledAtResume == false)
    }

    /// **VX-507 — after the WORDS MOMENT**: a join whose words were replaced shows rule 7's moment first (the round already
    /// running beneath it); closing the moment turns the sheet to the round — it no longer goes with the moment.
    @Test func theRoundPhaseFollowsTheWordsMoment() async throws {
        let gated = GatedFirstRound()
        let (model, _, confirm) = try await press(
            .turnOnSync, PlantedJoin.join(.sameMode), press: .made(receipt: "joined", wordsReplaced: true),
            road: gated.road)
        guard case .notShown? = confirm.moment else {
            Issue.record("the passphrase-typed join's moment stands first")
            return
        }
        #expect(confirm.round == .running, "the round started at the landing, beneath the moment")
        confirm.done()
        #expect(model.confirm === confirm, "Done waits for the moment — never past her words")
        confirm.closeMoment()
        #expect(model.confirm === confirm && confirm.moment == nil && confirm.round != nil, "the sheet turns to the round")
        await gated.release()
        _ = await confirm.awaitFirstRound()
        #expect(confirm.roundLine == ProtectionWords.firstRoundJoinLanded, "a join's success line")
        confirm.done()
        #expect(model.confirm == nil)
    }

    /// With NO road (the phone until VM-8; a test world without one) the sheet finishes exactly as before: gone at `.made`.
    @Test func withNoRoadTheSheetGoesAtTheLandingAsBefore() async throws {
        let (model, planted, confirm) = try await press(.turnOnSync, PlantedAccountRoads.setUp(), road: nil)
        #expect(model.confirm == nil && confirm.round == nil, "no round phase")
        for _ in 0..<10_000 where planted.landings == 0 { await Task.yield() }
        #expect(planted.spoken == ["landed"] && planted.landings == 1)
    }

    /// **VX-507 — THE OUTCOME PER STATUS CLASS, in the sync row's own words** (one presentation source): a clean round is the
    /// set-up's or the join's success line; offline, the keys, the account gate, the lockstep, replaced keys, a server
    /// refusal (its cause beneath, as the row shows it), a stalled pull, held and not configured each read
    /// "Sync hasn't run yet: ‹the row's sentence›." (P-VX510-1; held P-VX510-A1).
    @Test func eachOutcomeSaysTheRowsOwnSentence() async throws {
        func ran(_ error: String?, offline: Bool = false, stalled: Bool = false, success: Bool = false) -> FirstRoundOutcome {
            var status = SyncScheduler.Status()
            status.lastError = error
            status.lastErrorIsOffline = offline
            status.pullStalled = stalled
            status.roundsCompleted = 1
            if success || error == nil { status.lastSuccessAt = Date(timeIntervalSince1970: 1_782_864_000) }
            return .ran(status)
        }
        func line(_ outcome: FirstRoundOutcome, joins: Bool = false) -> String {
            RoadAccountConfirmModel.firstRoundLine(outcome, joins: joins)
        }
        func blocked(_ kind: SyncRowFace.Kind) -> String {
            "Sync hasn't run yet: " + SyncStatusRow.line(for: kind, lastSuccessAt: nil) + "."
        }
        #expect(line(ran(nil)) == "Synced. Your library is on your account now.")
        #expect(line(ran(nil), joins: true) == "Synced. Your account's writing is in this library now.")
        // VX-510 unit B1 (D-B0): the follow's clean round (PROVISIONAL P-VX510-B1-1).
        #expect(RoadAccountConfirmModel.firstRoundLine(ran(nil), joins: false, follows: true)
            == "Synced. This library is up to date with your account again.")
        #expect(RoadAccountConfirmModel.firstRoundLine(
            ran(String(describing: URLError(.notConnectedToInternet)), offline: true), joins: false, follows: true)
            == "Sync hasn't run yet: Waiting to sync (offline).", "a blocked follow says the row's sentence like any")
        let offline = String(describing: URLError(.notConnectedToInternet))
        #expect(line(ran(offline, offline: true)) == "Sync hasn't run yet: Waiting to sync (offline).")
        #expect(line(ran(String(describing: SyncError.encryptionKeysUnavailable))) == blocked(.keysLocked))
        #expect(line(ran(String(describing: SyncError.encryptionKeysUnavailable)))
            == "Sync hasn't run yet: Sync locked \u{2014} this \(ProtectionCopy.deviceName) hasn't unlocked your account's sync keys.")
        #expect(line(ran(String(describing: SyncError.accountMismatch(bound: "a", signedIn: "b")))) == blocked(.accountMismatch))
        #expect(line(ran(String(describing: SyncError.schemaLockstepMismatch(client: 12, server: 13))))
            == blocked(.appOutOfDate))
        #expect(line(ran(String(describing: SyncError.encryptionKeysReplaced))) == blocked(.keysReplaced))
        #expect(line(ran("HTTP 500 — the server refused")) == "Sync hasn't run yet: Sync error.")
        #expect(line(ran(nil, stalled: true)) == blocked(.stalled))
        #expect(line(.held)
            == "Sync hasn't run yet: Sync is waiting since the restore \u{2014} press Resume Sync in the main window's banner.")
        #expect(line(.notConfigured) == "Sync hasn't run yet: Sync is off.")

        // A server refusal's cause stands beneath the line, as the row shows it under its error face; no other class has one.
        let refused = RoadAccountConfirmModel(
            door: PlantedAccountRoads.setUp(), act: { _ in .made(receipt: nil) },
            firstRound: { ran("HTTP 500 — the server refused") }, finished: { _ in })
        await refused.submit(passphrase: "a new passphrase", again: "a new passphrase", words: Self.wordsText)
        _ = await refused.awaitFirstRound()
        #expect(refused.roundErrorCause == "HTTP 500 — the server refused")
        let locked = RoadAccountConfirmModel(
            door: PlantedAccountRoads.setUp(), act: { _ in .made(receipt: nil) },
            firstRound: { ran(String(describing: SyncError.encryptionKeysUnavailable)) }, finished: { _ in })
        await locked.submit(passphrase: "a new passphrase", again: "a new passphrase", words: Self.wordsText)
        _ = await locked.awaitFirstRound()
        #expect(locked.roundErrorCause == nil, "the locked face carries its cause in its line")
    }
}
