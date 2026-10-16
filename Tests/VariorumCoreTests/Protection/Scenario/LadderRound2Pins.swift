//
//  LadderRound2Pins.swift
//  VariorumCoreTests — VX-305 ladder round 2, the MINOR: NEW-1's mirror proof
//  (`AssessRules.olderLibraryFileProof`) has two gates for its mirror road —
//  the live place holds ANOTHER library's file (NEW-1's pinned case,
//  `aLoneOlderFileOfALibrarySetAsideByALandingLosesToItsMemory`) or is ABSENT
//  (the `?? true` arm). This pins the ABSENT arm: the reviewer's probe shape,
//  a fixed scenario (the generator never draws the pair —
//  `ScenarioGenerator.rollsBackBothHomes`).
//  The record: `notes/plans/vx-305-ladder-round-2.md` (the finding) · `-answer.md` (red-on-old) · `-final-call.md` · `-fixes.md`.
//

import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 ladder round 2 — the MINOR: NEW-1's mirror proof with the live place ABSENT")
struct LadderRound2AbsentArmPin {
    /// A Touch ID Castle library on macA (the gate keeps the memory's key in
    /// reach through its custody item — the press — with the key file gone),
    /// opened (the migration), then two crossings (Use Standard, Use Castle):
    /// the remembered key's file holds the first Castle-era key in its
    /// history. A login-password holder then deletes the live key file AND
    /// writes back the slot file captured at the first press — the library's
    /// first Castle-era file, alone. §3.6 / P-U4-6 (ratified (a), "Memory
    /// wins"): the lone older file loses — verified through the memory's own
    /// sealed mirror, since the live place holds no file of this library.
    /// Red on the tree before NEW-1's fix (the proof required the live file
    /// of the memory's key).
    @Test func aLibraryFileReplayedWithItsKeyFileDeletedLosesToItsMemory() async throws {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .touchID)) }
        await world.done([.launch("macA")])
        await world.done([.useStandard("macA"), .useCastle("macA", .touchID, newWords: false)])
        let remembered = try #require(world.macA.slot?.record)
        #expect(remembered.mode == .castle, "the second crossing didn't enter Castle")
        let replayed = try #require(world.macA.captures.compactMap(\.slot).first?.library, "no slot capture to replay")
        #expect(replayed.libraryID == remembered.libraryID, "the replay isn't this library's — the pin lost its road")
        #expect(replayed.fingerprint != remembered.currentFingerprint, "the replay is under the current key — the pin lost its road")
        let mirror = try #require(world.macA.library?.memory?.keyFileMirror)
        #expect(mirror.fingerprint == remembered.currentFingerprint)
        #expect(mirror.history.contains { $0.fingerprint == replayed.fingerprint },
                "the memory's key file doesn't hold the replayed file's key — the pin lost its road")

        await world.step(.tamperSequence("macA", [.deleteKeyFile, .replayLibraryFile]))
        await world.step(.settle)

        let slot = try #require(world.macA.slot)
        #expect(slot.libraryID == remembered.libraryID)
        #expect(slot.record?.mode == .castle, "the replayed file lowered the mode")
        #expect(slot.fingerprint == remembered.currentFingerprint, "the slot isn't under the remembered key — the older file won")
        #expect(slot.record?.keyEpoch == remembered.keyEpoch, "the record isn't the memory's epoch")
        #expect(world.liveKeyFile(world.macA)?.fingerprint == remembered.currentFingerprint, "the memory's key file isn't live")
        #expect(world.liveKeyFile(world.macA)?.apple == nil, "an Apple wrap on a Castle key")
        #expect(world.macA.library?.memory?.currentFingerprint == remembered.currentFingerprint, "the memory was overwritten")
        #expect(world.macA.logLines.contains { $0.contains("the memory's own key file restored from its mirror — the library file came back alone") },
                "the mirror road didn't run")
        expectPromisesKept(world)
    }
}
