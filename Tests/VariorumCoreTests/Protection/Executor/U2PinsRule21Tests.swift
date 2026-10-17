//
//  U2PinsRule21Tests.swift
//  VariorumCoreTests — VX-378 U2 piece F: RULE 21, detect and refuse
//  (`notes/CastleRules.md`: "If the file in the live place is not the one this
//  Mac remembers, the app refuses to open, says what it found, and offers the
//  two doors of rule 17. It never repairs by guessing"), the memory at exactly
//  four things, and an act stranded by a lost memory item finishing from the
//  plan on disk (the orchestrator's adjudications 2, 5, 7 after U1). Written
//  against the API both trees share (refusals read through their printed
//  form), so the red-on-old run is honest.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U2 — rule 21: a live place this Mac doesn't remember is refused, never repaired")
struct U2PinsRule21Tests {
    /// Adjudication 2: a library file replayed into the live place (the lobby's
    /// road reaches it through the key file's history) — refused, nothing
    /// written.
    @Test func aReplayedLibraryFileIsRefused() async throws {
        let fixture = try EX(.standard)
        let k0 = fixture.key
        let older = fixture.world.live!
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        let k1 = library.key
        fixture.world.live = older
        fixture.world.writes = []
        do {
            _ = try fixture.executor().unlock(with: k0, alsoInHand: [k1])
            Issue.record("a replayed library file opened")
        } catch {
            #expect("\(error)".contains("libraryDisagreesWithMemory") && "\(error)".contains("libraryFileUnderAnotherKey"), "\(error)")
        }
        #expect(fixture.world.writes.isEmpty)
    }

    /// Adjudication 2: a key file replayed into the live place (an older key's
    /// file beside the current library) — refused, nothing written, the stray
    /// file left as found.
    @Test func aReplayedKeyFileIsRefused() async throws {
        let fixture = try EX(.standard)
        let olderFile = try #require(fixture.world.liveKeyFile)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        fixture.world.liveKeyFile = olderFile
        fixture.world.writes = []
        do {
            _ = try fixture.executor().unlock(with: library.key)
            Issue.record("a replayed key file opened")
        } catch {
            #expect("\(error)".contains("libraryDisagreesWithMemory") && "\(error)".contains("keyFileOfAnotherKey"), "\(error)")
        }
        #expect(fixture.world.writes.isEmpty && fixture.world.liveKeyFile == olderFile)
    }

    /// Another library in the live place while this Mac remembers its own —
    /// refused ("a copy is a copy": it is never silently made this Mac's).
    @Test func anotherLibraryInTheLivePlaceIsRefused() async throws {
        let mine = try EX(.castle)
        let theirs = try EX(.standard)
        mine.world.live = theirs.world.live
        mine.world.liveKeyFile = theirs.world.liveKeyFile
        mine.world.writes = []
        do {
            _ = try mine.executor().unlock(with: theirs.key)
            Issue.record("another library opened as this Mac's")
        } catch {
            #expect("\(error)".contains("libraryDisagreesWithMemory") && "\(error)".contains("anotherLibrary"), "\(error)")
        }
        #expect(mine.world.writes.isEmpty)
    }

    /// Adjudication 5: an ABSENT memory never refuses (rule 8's keychain reset).
    @Test func anAbsentMemoryIsNoDisagreement() throws {
        let fixture = try EX(.standard)
        fixture.world.memories = [:]
        let library = try fixture.executor().unlock(with: fixture.key)
        #expect(library.memory == nil)
    }

    /// `assess` says it too: the fault, no repair, no act, every door closed.
    @Test func assessReportsItAndOpensNoDoor() throws {
        var world = try AWorld(.castle)
        var memory = world.agreeingMemory
        memory.currentFingerprint = PF.fp(StoreKey.mint())
        world.memory = memory
        let assessed = try world.assessed()
        #expect("\(assessed.faults)".contains("libraryDisagreesWithMemory"), "\(assessed.faults)")
        #expect(assessed.repairs.isEmpty && assessed.acts.isEmpty)
        #expect(!assessed.doors.values.contains { $0.isOpen })
    }

    /// Adjudication 5: the memory item lost mid-act — the act finishes (or rolls
    /// back) from the plan on disk, in the section that plan names; then this
    /// Mac takes its fresh device ID.
    @Test func anActStrandedByALostMemoryItemSettlesFromThePlan() async throws {
        let fixture = try EX(.standard)
        try await midUseCastle(fixture, stopAfter: 7)
        let original = fixture.deviceID
        fixture.world.memories = [:]
        let (_, library, _) = try await fixture.relaunchAndSettle()
        expectSettled(fixture, library)
        #expect(library.section.deviceID != original, "the plan's section kept after the act settled")
        #expect(library.section.actInFlight == nil)
    }

    /// Adjudication 7: what this Mac remembers is exactly rule 21's four things.
    @Test func theMemoryHoldsExactlyFourThings() async throws {
        let fixture = try EX(.castle)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        var settings = library.section.settings
        settings.idleLockMinutes = 30
        _ = try await executor.changeSettings(&library, to: settings)
        let sealed = try #require(fixture.world.memories[fixture.libraryID])
        let fields = try #require(try JSONSerialization.jsonObject(with: sealed.payload) as? [String: Any])
        #expect(Set(fields.keys) == ["format", "libraryID", "currentFingerprint", "deviceID", "keyFileMirror"],
                "\(fields.keys.sorted())")
    }
}
