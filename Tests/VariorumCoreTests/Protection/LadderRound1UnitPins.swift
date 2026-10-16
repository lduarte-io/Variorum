//
//  LadderRound1UnitPins.swift
//  VariorumCoreTests — VX-305 ladder round 1: the model-level pins of the
//  confirmed findings (`notes/plans/vx-305-ladder-round-1-final-call.md`),
//  each watched red on the tree before its fix (the record:
//  `notes/plans/vx-305-ladder-round-1-fixes.md`).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 ladder round 1 — the MINOR: assess reads the live key file only when it is the current key's")
struct LiveKeyFileIsTheCurrentKeysTests {
    /// Another key's file in the live place (no mirror): a Castle library
    /// whose live place holds a Standard key's file with an Apple wrap — the
    /// round-1 wedge's Use-Standard face.
    @Test func castleWithAnotherKeysStandardFileLive() throws {
        var world = try AWorld(.castle)
        let other = StoreKey.mint()
        var locks = NewKeyLocks(passphrase: world.world.p, words: world.world.w)
        locks.apple = world.own
        world.liveFile = try KeyFile.building(libraryID: world.world.library, key: other, epoch: 2, locks: locks)
        world.appleKeys = AppleKeyFacts(readable: [world.own.id])
        world.memoryAbsent = true
        let assessed = try world.assessed()
        #expect(!assessed.faults.contains(.appleWrapOnCastleKey(keyFileID: AWorld.liveKeyFileID)),
                "the Castle fault named another key's file: \(assessed.faults)")
        #expect(assessed.faults.contains(.liveKeyFileIsAnotherKeys(keyFileID: AWorld.liveKeyFileID)), "\(assessed.faults)")
    }

    /// The Use-Castle face: a Standard library whose live place holds a
    /// Castle key's file (no Apple wrap) — no perpetual `landAppleWrap` keyed
    /// on another key's missing wrap, no lost-road fault read off it, and no
    /// Re-link subject made of it.
    @Test func standardWithAnotherKeysCastleFileLive() throws {
        var world = try AWorld(.standard)
        let other = StoreKey.mint()
        world.liveFile = try KeyFile.building(
            libraryID: world.world.library, key: other, epoch: 2,
            locks: NewKeyLocks(passphrase: world.world.p, words: world.world.w))
        world.memoryAbsent = true
        let assessed = try world.assessed()
        #expect(!assessed.repairs.contains { if case .landAppleWrap = $0 { return true }; return false },
                "a wrap owed on another key's file: \(assessed.repairs)")
        #expect(!assessed.faults.contains(.appleRoadLost(keyFileID: AWorld.liveKeyFileID)))
        #expect(assessed.faults.contains(.liveKeyFileIsAnotherKeys(keyFileID: AWorld.liveKeyFileID)), "\(assessed.faults)")
    }

    /// Mid-act the live file IS the new key's (the act's own state): no fault.
    @Test func midActTheNewKeysFileIsNoFault() throws {
        var world = try AWorld(.castle)
        let other = StoreKey.mint()
        world.liveFile = try KeyFile.building(
            libraryID: world.world.library, key: other, epoch: 2,
            locks: NewKeyLocks(passphrase: world.world.p, words: world.world.w))
        world.section = world.section.beginningAct(.replaceAllKeys, from: PF.fp(world.key), to: PF.fp(other), at: PF.t0).section
        world.recordSection = world.section
        let assessed = try world.assessed()
        #expect(!assessed.faults.contains(.liveKeyFileIsAnotherKeys(keyFileID: AWorld.liveKeyFileID)))
    }
}

@Suite("VX-305 ladder round 1 — NIT 6: before unlock, with no fingerprint hint, a Touch ID item still shows the button")
struct TouchIDLobbyWithNoHintTests {
    /// The key file AND the memory item both gone (a listed tamper): no hint
    /// names the current key before unlock, yet a Touch ID item exists and
    /// opens — the button shows (VX-310's letter: "the button whenever a
    /// Touch ID item exists"), and no quiet line says it isn't set up.
    @Test func aTouchIDItemWithNoHintShowsTheButton() throws {
        var world = try AWorld(.castle)
        world.unlocked = false
        var facts = try world.facts()
        facts.slotFingerprintHint = nil
        let touchID = assess(facts, guards: .all).touchID
        #expect(touchID.button, "no button with a Touch ID item present")
        #expect(touchID.quietLine == nil, "the quiet line said \(String(describing: touchID.quietLine))")
    }

    /// …and with no Touch ID item at all, still no button (the line stays).
    @Test func noItemNoButton() throws {
        var world = try AWorld(.castle)
        world.unlocked = false
        world.custody = []
        var facts = try world.facts()
        facts.slotFingerprintHint = nil
        let touchID = assess(facts, guards: .all).touchID
        #expect(!touchID.button)
        #expect(touchID.quietLine == .notSetUpForThisLibrary)
    }
}
