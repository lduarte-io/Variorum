//
//  StaleEnvelopeSweepScenarios.swift
//  VariorumCoreTests — VX-443 (the VX-849 run, batch 4; PROVISIONAL P-849-4): THE STORE-ID ENVELOPE beside the slot,
//  swept at the open. `AppBootstrap.ensureStoreIdentity` (the new road's open, VX-306 U1b → VX-329) wrote
//  `variorum-keys-<fp16>.json` beside the library — the open's key's fingerprint, the store id, no wraps — and nothing
//  has read it since VX-329. Its NAME is exactly the pre-design detector's (`CatalogNames.isPreDesignKeyFileName`), so
//  a library that loses THIS design's key file while the stub stands reads as a store from before this design (her
//  "older version" face — no key tried, rule 1's mirror never written back). The open's repairs delete it BY NAME when
//  its fingerprint is one the live key file holds (rule 4: nothing openable is lost); everything else stays.
//
//  On the scenario world, whose launch runs `assess`'s repairs — written against the actions both trees share (a file
//  planted, the launch, the verdict read), so the red-on-old run is honest: on the pre-fix tree the three sweep pins are
//  RED (the stub survives every open; the lost key file reads as a pre-design store); the guards are green both sides.
//

import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-443 — the store-id envelope beside the slot, swept at the open (the scenario world)")
struct StaleEnvelopeSweepScenarios {
    /// The name `ensureStoreIdentity` wrote: `variorum-keys-<fp16>.json`.
    static func envelopeName(_ fingerprint: String) -> String { "variorum-keys-\(fingerprint).json" }

    /// A library opened on macA and closed again, with a file planted beside its slot (an opaque file — the world
    /// never reads it, as the app never reads it).
    static func plantedBeside(_ names: [String]) async throws -> SWorld {
        let world = try await scenarioWorld { w in try await w.fresh(on: w.macA) }
        await world.done([.launch("macA")])
        for name in names { world.macA.container.files[name] = .marker }
        await world.done([.lock("macA")])
        return world
    }

    // MARK: - The sweep (red on the pre-fix tree)

    /// THE PIN: the stub of the library's own key, beside the slot, is gone after the next open.
    @Test func theEnvelopeOfTheLibrarysOwnKeyIsGoneAfterTheNextOpen() async throws {
        let world = try await scenarioWorld { w in try await w.fresh(on: w.macA) }
        await world.done([.launch("macA")])
        let key = try #require(world.macA.library?.key)
        let stub = Self.envelopeName(PF.fp(key))
        world.macA.container.files[stub] = .marker
        await world.done([.lock("macA"), .launch("macA")])
        #expect(world.macA.container.files[stub] == nil, "the store-id envelope beside the slot survived the open")
        #expect(world.liveKeyFile(world.macA)?.fingerprint == PF.fp(key), "this design's key file untouched")
        expectPromisesKept(world)
    }

    /// VX-912 B0's flag, exactly: after a crossing the stub names the PRE-crossing key — which the live key file now
    /// carries in its history (rule 4) — and it goes at the next open.
    @Test func theEnvelopeOfThePreCrossingKeyIsGoneAfterTheNextOpen() async throws {
        let world = try await scenarioWorld { w in try await w.fresh(on: w.macA) }
        await world.done([.launch("macA")])
        let before = try #require(world.macA.library?.key)
        await world.done([.useCastle("macA", .alwaysAsk, newWords: false), .setScheduledExport("macA", false)])
        let after = try #require(world.macA.library?.key)
        #expect(after != before, "entering Castle made a new library key")
        #expect(world.liveKeyFile(world.macA)?.heldFingerprints.contains(PF.fp(before)) == true, "rule 4 carried it")
        let stub = Self.envelopeName(PF.fp(before))
        world.macA.container.files[stub] = .marker
        await world.done([.lock("macA"), .launch("macA")])
        #expect(world.macA.container.files[stub] == nil, "the pre-crossing key's envelope survived the open")
        expectPromisesKept(world)
    }

    /// WHY IT MATTERS: with the stub gone, a lost key file is the lobby's to heal (rule 1 — the mirror written back), never
    /// her pre-design face. On the pre-fix tree the stub still stands, and the verdict reads `.preDesignStore`.
    @Test func aLostKeyFileAfterTheSweepIsTheLobbysToHealNeverAPreDesignStore() async throws {
        let world = try await scenarioWorld { w in try await w.fresh(on: w.macA) }
        await world.done([.launch("macA")])
        let key = try #require(world.macA.library?.key)
        world.macA.container.files[Self.envelopeName(PF.fp(key))] = .marker
        await world.done([.lock("macA"), .launch("macA"), .lock("macA")])
        // The key file lost while the app is closed (by hand — the world's tamper step would relaunch at once).
        world.macA.container.files[SPath.liveKeyFile] = nil
        #expect(world.assessed(world.macA).launch == .lobby,
                "a library of this design that lost its key file read as a store from before this design")
        await world.done([.launch("macA")])
        #expect(world.liveKeyFile(world.macA)?.fingerprint == PF.fp(key), "rule 1: the mirror is written back")
        expectPromisesKept(world)
    }

    // MARK: - The fences (green on both sides — the false-positive class)

    /// An older name whose fingerprint this library's key file does not hold — a store from before this design moved out
    /// by hand, its key file left behind — is not this library's to delete (rule 26: we don't handle them).
    @Test func anOlderNameWhoseKeyThisLibraryNeverHadStays() async throws {
        let stranger = Self.envelopeName(PF.fp(StoreKey.mint()))
        let world = try await Self.plantedBeside([stranger])
        await world.done([.launch("macA")])
        #expect(world.macA.container.files[stranger] != nil)
        expectPromisesKept(world)
    }

    /// The fixed legacy name (no fingerprint in it — ownership unprovable by name) and an older set-aside (`.stale-`,
    /// another key's wraps by construction) stay, as does a near miss of the name.
    @Test func theLegacyNameASetAsideAndANearMissStay() async throws {
        let world = try await scenarioWorld { w in try await w.fresh(on: w.macA) }
        await world.done([.launch("macA")])
        let fp = PF.fp(try #require(world.macA.library?.key))
        let kept = ["variorum-keys.json", "variorum-keys-\(fp).stale-1791000000.json",
                    "variorum-keys-\(fp.prefix(8)).json", "variorum-keys-\(fp).json.bak"]
        for name in kept { world.macA.container.files[name] = .marker }
        await world.done([.lock("macA"), .launch("macA")])
        for name in kept { #expect(world.macA.container.files[name] != nil, "\(name) was touched") }
        expectPromisesKept(world)
    }

    /// Below the container's root nothing is the slot's: the same name inside Previous Libraries and inside this Mac's
    /// backup folder stays.
    @Test func theSameNameBelowTheRootStays() async throws {
        let world = try await scenarioWorld { w in try await w.fresh(on: w.macA) }
        await world.done([.launch("macA")])
        let library = try #require(world.macA.library)
        let name = Self.envelopeName(library.fingerprint)
        let libraryID = try #require(library.record?.libraryID)
        let below = ["Previous Libraries/2026-01-02-030405/\(name)",
                     SPath.ownFolder(libraryID, library.section.deviceID) + "/\(name)"]
        for path in below { world.macA.container.files[path] = .marker }
        await world.done([.lock("macA"), .launch("macA")])
        for path in below { #expect(world.macA.container.files[path] != nil, "\(path) was touched") }
        expectPromisesKept(world)
    }

    /// THE DETECTOR UNCHANGED: a store with an older name beside it and NO key file of this design reads as a store from
    /// before this design — the open never gets there, so nothing is swept.
    @Test func aStoreWithNoKeyFileOfThisDesignStillReadsAsPreDesign() async throws {
        let world = try await scenarioWorld { w in try await w.fresh(on: w.macA) }
        await world.done([.launch("macA")])
        let stub = Self.envelopeName(PF.fp(try #require(world.macA.library?.key)))
        await world.done([.lock("macA")])
        world.macA.container.files[SPath.liveKeyFile] = nil
        world.macA.container.files[stub] = .marker
        #expect(world.assessed(world.macA).launch == .preDesignStore)
        #expect(world.macA.container.files[stub] != nil)
    }
}
