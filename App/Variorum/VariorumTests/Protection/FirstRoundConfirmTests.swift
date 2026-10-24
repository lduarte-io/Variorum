//
//  FirstRoundConfirmTests.swift
//  VariorumTests — VX-510 unit A: THE ACCOUNT CONFIRM'S FIRST ROUND over PLANTED roads (pure — no keychain, no disk, no
//  server; also runs headless in the implementer's SwiftPM harness).
//    - VX-498 (D-A1): the doors whose landing changes sync's standing on the OPEN session — Turn on sync's set-up, a join in
//      the same posture, Move in the same posture — ask the composition's first-round road ONCE, at `.made`. A leave never
//      asks (sync stops there); a re-keying act never asks (it lands through the reopen, whose fresh services run their
//      own round — F-6); a refused or changed press never asks. With no road (the phone until VM-8) nothing is asked.
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
        let planted = PlantedAccountRoads()
        planted.press = press
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
        model.firstRound = round?.road
        await model.refresh()
        model.open(door)
        let confirm = try #require(model.confirm, "\(door)'s confirm opens")
        switch open.ask {
        case .passphraseAndWords:
            await confirm.submit(passphrase: "a new passphrase", again: "a new passphrase", words: Self.wordsText)
        case .oneSecret:
            await confirm.submit(passphrase: "the account's passphrase")
        case .passphrase:
            await confirm.submit(passphrase: "a new passphrase", again: "a new passphrase")
        case .nothing:
            await confirm.submit()
        }
        #expect(planted.requests.count == 1, "\(door) pressed once")
        return confirm
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

    /// A LEAVE never asks (sync stops); a RE-KEYING act never asks (the reopen's fresh services run their own round —
    /// F-6); with no road nothing is asked and the confirm finishes as before.
    @Test func aLeaveOrAReKeyingActNeverAsks() async throws {
        let doors: [(RoadAccountDoor, RoadAccountDoorOpen)] = [
            (.stopSyncingHere, PlantedAccountRoads.leave(.stopSyncingHere)),
            (.deleteAccountHere, PlantedAccountRoads.leave(.deleteAccountHere)),
            (.thisMacOnly, PlantedAccountRoads.leave(.thisMacOnly)),
            (.turnOnSync, PlantedJoin.join(.entersCastle)),
            (.turnOnSync, PlantedJoin.join(.leavesCastle)),
            (.moveToSignedInAccount, Self.move(.entersCastle)),
            (.follow, PlantedJoin.follow(.intoCastle)),
            (.follow, PlantedJoin.follow(.intoStandard)),
        ]
        for (door, open) in doors {
            #expect(!open.owesFirstRound, "\(door) \(String(describing: open.spec.join)) owes none")
            let round = PlantedFirstRound()
            let confirm = try await press(door, open, round: round)
            #expect(await confirm.awaitFirstRound() == nil, "\(door): no round started")
            #expect(round.asks == 0, "\(door): never asked")
        }
        // No road at all: the set-up lands and nothing is asked.
        let confirm = try await press(.turnOnSync, PlantedAccountRoads.setUp(), round: nil)
        #expect(await confirm.awaitFirstRound() == nil)
    }

    /// A refused press, or one whose door CHANGED (VX-108), lands nothing — and asks for no round.
    @Test func aRefusedOrChangedPressNeverAsks() async throws {
        for press in [RoadAccountPress.refused("no"), .changed(PlantedAccountRoads.setUp(newPassphrase: false))] {
            let round = PlantedFirstRound()
            let confirm = try await self.press(.turnOnSync, PlantedAccountRoads.setUp(), press: press, round: round)
            #expect(await confirm.awaitFirstRound() == nil && round.asks == 0, "\(press)")
        }
    }
}
