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

    /// NEW-2's SECOND ROAD — the same class, found by the round-1 slice re-run on
    /// the first fix (seed 1, sequence 222 again, shrunk to 17 steps). The
    /// phone's Standard pair lands on macB; a Time Machine snapshot of macB
    /// takes the hand-off folder with it; then macB's OWN Send Library to macA
    /// the same day writes its pair into the same-named folder (the world names
    /// a hand-off folder by its day) — overwriting the phone's pair in the
    /// container AND the world's folder → sender map. The phone's pair now
    /// lives only in the snapshot, still opening through the phone's own Apple
    /// key to its key AND its history; the exemption, read from the container's
    /// folder by the map, saw neither. The sender's own copy is that by WHAT IT
    /// IS, not where its files sit: the world now records each sent Standard
    /// pair's reach at the send. Before the fix (on the first fix's tree):
    /// `promise 13 on macB: … reaches 08a7bed3, a key from before the leave` and
    /// `… reaches b03b0684, …`.
    @Test func aSentPairsSnapshotIsTheSendersOwnToo() async throws {
        let world = try GeneratorFoundScenarios.start("a device that joined without a secret", seed: 1_000_225)
        let account = try #require(world.server.accounts.keys.sorted().first)
        #expect(account.hasPrefix("8d2d5914"), "the seed no longer builds the found world")
        for action in [Action.createLibrary("macB", secrets: true), .follow("phone", .oldPassphrase),
                       .useCastle("macA", .alwaysAsk, newWords: true), .crash(.setScheduledExport("phone", false), afterWrites: 19),
                       .useCastle("phone", .touchID, newWords: true), .resetPassphrase("phone", .plainConfirm),
                       .signIn("macB", account: account), .answerCorner45("macA", .standard), .launch("macB"),
                       .follow("phone", .words), .finishLeave("phone", mint: false), .sendLibrary(from: "phone", to: "macB"),
                       .land("macB", .wordsPassphraseMadeNew), .timeMachineSnapshot("macB"), .sendLibrary(from: "macB", to: "macA"),
                       .useCastle("macB", .alwaysAsk, newWords: true), .useStandard("macB")] {
            await world.step(action)
        }
        let macB = world.macB
        #expect(macB.slot?.record?.mode == .standard, "macB didn't leave Castle")
        let kept = try #require(world.truth.keptByLeave["macB"])
        let leftAt = try #require(world.truth.leftCastleAt["macB"])
        let attacker = world.reach(world.attackerSeeds(macB, appleAccount: true, settled: false), files: world.keyFilesOn(macB))
        let castleMade = world.truth.castleBorn.intersection(kept)
        #expect(!castleMade.isEmpty, "the leave kept no Castle key — the scenario lost its point")
        for fingerprint in castleMade.sorted() {
            #expect(attacker[fingerprint] == nil, "a key made in Castle (\(fingerprint.prefix(8))) is reachable")
        }
        for (id, copy) in world.truth.copies where copy.madeOn == "macB" && copy.madeAt < leftAt {
            #expect(attacker[copy.fingerprint] == nil, "macB's copy \(id) from before the leave is reachable")
        }
        // The road: the phone's pair, now only in the snapshot (the container's
        // same-named folder holds macB's own pair) — without any hand-off
        // folder's files, nothing kept by the leave is reached.
        let handOff = CatalogNames.handOffPrefix
        let withoutPairs = world.reach(
            world.attackerSeeds(macB, appleAccount: true, settled: false),
            files: world.keyFilesOn(macB, excluding: { id, _ in id.hasPrefix("container:\(handOff)") || id.hasPrefix("tm:\(handOff)") }))
        #expect(kept.allSatisfy { withoutPairs[$0] == nil }, "a key kept by the leave is reached by another road")
        #expect(kept.contains { attacker[$0] != nil }, "the snapshot's pair no longer reaches a kept key — the pin lost its road")
        expectPromisesKept(world)
    }

    /// NEW-1 — a MODEL finding (seed 1, sequence 54 of the round-1 slice; world
    /// seed 1000057). macB's own library Y (99708862) enters Castle (a crash
    /// past its swap, finished at the next open); then the phone's Castle pair
    /// lands — a DIFFERENT library X in the slot, Y set aside to Previous
    /// Libraries with its key file, and Y's memory item still naming the
    /// landing (the landing is named in both libraries — Copies.swift); then a
    /// login-password holder writes back the slot file they captured BEFORE Y
    /// entered Castle — Y's Standard-era file, alone. §3.6 / P-U4-6 (ratified
    /// (a), "Memory wins"): a lone older library file loses to this Mac's own
    /// memory. Before the fix it WON: the open's settle rolled back the landing
    /// act Y's memory still named, against the replayed file, and wrote that
    /// file's facts (Standard, the pre-Castle key) over the newer memory —
    /// and the memory-wins arm could not have verified anyway, because the
    /// memory's key file was not in the live place (X's was). Y read Standard
    /// under a key the adversary held in its Standard day, with no key file:
    /// `promise 3 on macB: no Apple wrap of the current key`. Now the file
    /// loses FIRST — through the memory's own sealed mirror of its key file —
    /// and Y is back in its Castle state, X's file set aside, never deleted.
    /// Both forms: the base tree's single tamper, the fixed tree's group.
    @Test(arguments: [false, true])
    func aLoneOlderFileOfALibrarySetAsideByALandingLosesToItsMemory(group: Bool) async throws {
        let world = try GeneratorFoundScenarios.start("a phone on an older build beside a synced Castle Mac", seed: 1_000_057)
        for action in [Action.createLibrary("macB", secrets: true), .updateToNewBuild("phone"),
                       .sendLibrary(from: "phone", to: "macB"),
                       .crash(.useCastle("macB", .alwaysAsk, newWords: false), afterWrites: 17)] {
            await world.step(action)
        }
        let y = try #require(world.macB.slot)
        let yCastle = try #require(y.record)
        #expect(yCastle.mode == .castle, "Y didn't enter Castle")
        await world.step(.land("macB", .wordsPassphraseMadeNew))
        let x = try #require(world.macB.slot)
        #expect(x.libraryID != y.libraryID, "the landing didn't put a different library in the slot")
        let tamper: Action = group ? .tamperSequence("macB", [.replayPlan, .plantPlan, .replayLibraryFile])
                                   : .tamper("macB", .replayLibraryFile)
        await world.step(tamper)
        await world.step(.settle)
        let context = group ? "the group" : "the single tamper"
        let slot = try #require(world.macB.slot)
        #expect(slot.libraryID == y.libraryID, "\(context): the replayed file isn't Y's — the pin lost its road")
        #expect(slot.record?.mode == .castle, "\(context): the replayed file lowered Y's mode")
        #expect(slot.fingerprint == yCastle.currentFingerprint, "\(context): the slot isn't under Y's remembered key")
        #expect(world.liveKeyFile(world.macB)?.fingerprint == yCastle.currentFingerprint, "\(context): Y's key file isn't live")
        #expect(world.liveKeyFile(world.macB)?.apple == nil, "\(context): an Apple wrap on a Castle key")
        #expect(world.catalog(world.macB).keyFiles.contains { $0.role == .setAside && $0.fingerprint == x.fingerprint },
                "\(context): X's key file wasn't set aside")
        expectPromisesKept(world, context)
    }
}
