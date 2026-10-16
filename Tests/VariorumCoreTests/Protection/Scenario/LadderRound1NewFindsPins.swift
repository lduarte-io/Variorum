//
//  LadderRound1NewFindsPins.swift
//  VariorumCoreTests — VX-305 ladder round 1, the two PRE-EXISTING finds the
//  compound generator's shifted stream reached (both reproduce on the round's
//  base `e4ee1f083`): each pinned as a fixed scenario at its minimal sequence,
//  watched RED on the tree before its fix. The record (trace, classification,
//  red → green, the revert check): `notes/plans/vx-305-ladder-round-1-newfinds.md`.
//

import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 ladder round 1 — the new finds: NEW-2 (promise 13, a checker bug) and NEW-1 (promise 3, a model bug)")
struct LadderRound1NewFindsPins {
    /// NEW-2 — a CHECKER finding (seed 1, sequence 222 of the round-1 slice;
    /// world seed 1000225; NO tamper in it). The phone (a device that joined
    /// without a secret) follows the account's keys within Standard, so its
    /// key file's HISTORY takes its pre-follow key (b03b0684); it sends its
    /// library to macB, which lands it under a fresh key, then enters Castle
    /// and leaves it. The landed library's family tree carries the sender's
    /// keys (the copy's own facts, §3.6 — the landing's own-line seed), so
    /// promise 13's "every key from before the leave" holds b03b0684 too; and
    /// the phone's Send Library pair, which the receiver never writes and
    /// which keeps its own locks (§3.7), opens through the phone's own Apple
    /// key — its current key AND, through its history, b03b0684. The closer's
    /// exemption (`aSentStandardPairIsTheSendersOwnAfterALeave`) named only
    /// the sent image's key; the pair's history is the same road, the
    /// sender's own Standard copy in its day — no copy macB made, no key made
    /// in Castle. Before the fix: `promise 13 on macB: the Apple account or
    /// the login password reaches b03b0684, a key from before the leave`.
    @Test func aSentPairsHistoryIsTheSendersOwnAfterALeave() async throws {
        let world = try GeneratorFoundScenarios.start("a device that joined without a secret", seed: 1_000_225)
        let account = try #require(world.server.accounts.keys.sorted().first)
        #expect(account.hasPrefix("8d2d5914"), "the seed no longer builds the found world")
        for action in [Action.createLibrary("macB", secrets: true), .useCastle("macA", .alwaysAsk, newWords: true),
                       .signIn("macB", account: account), .answerCorner45("macA", .standard), .launch("macB"),
                       .follow("phone", .words), .sendLibrary(from: "phone", to: "macB"),
                       .land("macB", .wordsPassphraseMadeNew), .useCastle("macB", .alwaysAsk, newWords: true),
                       .useStandard("macB")] {
            await world.step(action)
        }
        let macB = world.macB
        #expect(macB.slot?.record?.mode == .standard, "macB didn't leave Castle")
        let kept = try #require(world.truth.keptByLeave["macB"])
        let leftAt = try #require(world.truth.leftCastleAt["macB"])
        // The trace, asserted — the exemption hides no exposure:
        let attacker = world.reach(world.attackerSeeds(macB, appleAccount: true, settled: false), files: world.keyFilesOn(macB))
        // (1) nothing made in Castle opens to the Apple account or the login password;
        let castleMade = world.truth.castleBorn.intersection(kept)
        #expect(!castleMade.isEmpty, "the leave kept no Castle key — the scenario lost its point")
        for fingerprint in castleMade.sorted() {
            #expect(attacker[fingerprint] == nil, "a key made in Castle (\(fingerprint.prefix(8))) is reachable")
        }
        // (2) no copy macB made before the leave opens to them;
        for (id, copy) in world.truth.copies where copy.madeOn == "macB" && copy.madeAt < leftAt {
            #expect(attacker[copy.fingerprint] == nil, "macB's copy \(id) from before the leave is reachable")
        }
        // (3) and without the sender's pair (its hand-off folder) nothing kept by
        // the leave is reached at all: the one road IS the phone's own pair.
        let folders = world.senders.filter { $0.value != "macB" }.map(\.key)
        #expect(!folders.isEmpty)
        let withoutPair = world.reach(
            world.attackerSeeds(macB, appleAccount: true, settled: false),
            files: world.keyFilesOn(macB, excluding: { id, _ in folders.contains { id.hasPrefix("container:\($0)/") } }))
        #expect(kept.allSatisfy { withoutPair[$0] == nil }, "a key kept by the leave is reached by another road")
        // The pair's history key is the sender's (the phone's), reached through it.
        let sentHistory = folders.flatMap { folder -> [String] in
            guard case .format3(let file)? = macB.container.files["\(folder)/\(SPath.liveKeyFile)"]?.keyFile else { return [] }
            return file.history.map(\.fingerprint)
        }
        #expect(sentHistory.contains { attacker[$0] != nil && kept.contains($0) }, "the sent pair's history no longer rides the tree — the pin lost its road")
        expectPromisesKept(world)
    }
}
