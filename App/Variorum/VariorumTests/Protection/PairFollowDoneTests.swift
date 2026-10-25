//
//  PairFollowDoneTests.swift
//  VariorumTests — VX-529 unit 2, scope 2 (`notes/plans/fixes/vx-529-pair-catchup.md`): THE PAIR FOLLOW'S DONE, read
//  honestly. Pure (no keychain, no disk; headless in the implementer's SwiftPM harness too).
//    - `RoadSettledFollow.kind`: a follow a settle finished whose act in flight names NO new key is the PAIR catch-up
//      (unit 1's own reading — `FollowProgram.finishingSteps`: every other follow mints its new key at its press), never
//      "the keys changed" — RED on the pre-fix tree (it read `.keysReplaced`, and the durable Done said the account's keys
//      changed when only a passphrase or the twelve words had).
//    - THE STALE DONE-LINE (the VX-510 repro: Settings ▸ Sync showed "…keys changed on another device, and this Mac caught
//      up." while the account had moved again): the account section never shows a follow's Done while a follow is OWED —
//      RED on the pre-fix tree. The mark stays (the follow that lands next writes its own, the newest Done being the true
//      one — `FollowDoneMark.set`).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-529 unit 2 — the pair follow's Done: the settled kind and the stale line (pure)")
@MainActor
struct PairFollowDoneTests {
    /// A follow's act in flight as the record names it: a re-keying follow names its new key (minted at its press); the
    /// pair catch-up names none.
    static func inFlight(newKey: String?, from: ProtectionMode) -> ActInFlight {
        ActInFlight(sequence: 7, act: .follow, fromFingerprint: "old-key", toFingerprint: newKey, fromKind: from,
                    startedAt: Date(timeIntervalSinceReferenceDate: 790_000_000))
    }

    /// THE SETTLED PAIR FOLLOW (RED on old): resumed from its plan or finished from the record, in either posture, a follow
    /// naming no new key is the pair kind — its halves unknown to durable facts (the plan carries none — S-3), so the
    /// halves-unknown form; a follow naming a new key keeps the posture reading exactly as before.
    @Test func aSettledFollowNamingNoNewKeyIsThePairCatchUp() {
        let quiet = ActOutcome(act: .follow, fingerprint: "old-key")
        for mode in [ProtectionMode.standard, .castle] {
            let pair = Self.inFlight(newKey: nil, from: mode)
            #expect(RoadSettledFollow.kind(.resumed(quiet), inFlight: pair, modeAfter: mode)
                    == .pairChanged(passphrase: false, words: false), "\(mode): resumed")
            #expect(RoadSettledFollow.kind(.finishedFromRecord(quiet), inFlight: pair, modeAfter: mode)
                    == .pairChanged(passphrase: false, words: false), "\(mode): finished from the record")
            #expect(RoadSettledFollow.kind(.rolledBack(.follow), inFlight: pair, modeAfter: mode) == nil,
                    "\(mode): a rolled-back catch-up said nothing")
        }
        // The re-keying follows, unchanged (a guard — green on both sides).
        let rekeyed = ActOutcome(act: .follow, fingerprint: "new-key")
        #expect(RoadSettledFollow.kind(.resumed(rekeyed), inFlight: Self.inFlight(newKey: "new-key", from: .standard),
                                       modeAfter: .castle) == .intoCastle)
        #expect(RoadSettledFollow.kind(.resumed(rekeyed), inFlight: Self.inFlight(newKey: "new-key", from: .castle),
                                       modeAfter: .standard) == .intoStandard)
        #expect(RoadSettledFollow.kind(.resumed(rekeyed), inFlight: Self.inFlight(newKey: "new-key", from: .castle),
                                       modeAfter: .castle) == .keysReplaced)
    }

    /// The follow door as `assess` opens it for the pair kind (the passphrase moved: one of the account's secrets).
    static func pairFollowDoor() -> RoadAccountDoorOpen {
        RoadAccountDoorOpen(
            door: .follow, ask: .oneSecret, newPassphrase: false, sentences: [],
            spec: DoorSpec(requires: .oneSecret, synced: true), follow: .pairChanged(passphrase: true, words: false))
    }

    static func faces(follow: RoadAccountDoorFace) -> RoadAccountFaces {
        RoadAccountFaces(
            situation: .inSync(email: PlantedAccount.email), turnOnSync: .hidden, stopSyncingHere: .hidden,
            deleteAccountHere: .hidden, thisMacOnly: .hidden, move: .hidden, signOut: true, signIn: false,
            vaultUnreachable: false, follow: follow)
    }

    /// THE STALE DONE-LINE (RED on old): an earlier follow's Done mark stands (never OK'd) and the account has moved again —
    /// a follow is owed. The section shows NO Done beside the owed follow (its "this Mac caught up" is false now); once the
    /// follow is no longer owed the mark shows again (never lost — her OK is still its only clear).
    @Test func theDoneLineNeverStandsBesideAnOwedFollow() async {
        let planted = PlantedAccountRoads()
        planted.faces = Self.faces(follow: .open(Self.pairFollowDoor()))
        var roads = planted.roads
        roads.followDoneOwed = { .keysReplaced }
        let model = RoadAccountModel(roads: roads)
        await model.refresh()
        #expect(model.faces?.follow.openDoor != nil, "precondition: a follow is owed")
        #expect(model.followDone == nil, "the stale Done never stands beside an owed follow")
        planted.faces = Self.faces(follow: .hidden)
        await model.refresh()
        #expect(model.followDone == .keysReplaced, "nothing owed: the standing Done shows until her OK")
    }
}
