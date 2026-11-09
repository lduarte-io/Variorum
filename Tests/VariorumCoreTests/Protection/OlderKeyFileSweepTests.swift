//
//  OlderKeyFileSweepTests.swift
//  VariorumCoreTests — VX-443 (the VX-849 run, batch 4; PROVISIONAL P-849-4): the store-id envelope's sweep, as `assess`
//  decides it and the executor verifies and runs it. These name the new repair (`Repair.deleteOlderKeyFile`) and the leaf's
//  new door, so on the pre-fix tree they are COMPILE-red; the behavior red-on-old is `StaleEnvelopeSweepScenarios` (the
//  scenario world, committed on the pre-fix tree at the batch's piece 1a) and the Mac `StaleEnvelopeSweepRoadTests`; each
//  pin here has its named behavioral revert in the batch record.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-443 — the store-id envelope's sweep: assess decides it, by name, only for a key the live file holds")
struct OlderKeyFileSweepAssessTests {
    static func envelopeName(_ fingerprint: String) -> String { "variorum-keys-\(fingerprint).json" }

    static func sweeps(_ world: AWorld) throws -> [String] {
        try world.assessed().repairs.compactMap {
            if case .deleteOlderKeyFile(let name) = $0 { return name }
            return nil
        }
    }

    @Test func theNameIsReadForItsFingerprintAndNothingElse() {
        let fp = "0a1b2c3d4e5f6a7b"
        #expect(CatalogNames.preDesignKeyFileFingerprint("variorum-keys-\(fp).json") == fp)
        for name in ["variorum-keys.json", "variorum-keys-0a1b2c3d.json", "variorum-keys-0A1B2C3D4E5F6A7B.json",
                     "variorum-keys-\(fp).json.bak", "variorum-keys-\(fp).stale-1791000000.json",
                     ProtectionNames.keyFilename, CatalogNames.libraryFilename, "Previous Libraries/variorum-keys-\(fp).json"] {
            #expect(CatalogNames.preDesignKeyFileFingerprint(name) == nil, "\(name)")
        }
    }

    /// THE DECISION: the stub of the opened key, at the container's root, is owed — in both postures.
    @Test func theEnvelopeOfTheOpenedKeyIsOwedInBothPostures() throws {
        for mode in [ProtectionMode.standard, .castle] {
            var world = try AWorld(mode)
            let name = Self.envelopeName(PF.fp(world.key))
            world.extraEntries = [CatalogEntry(place: .container, name: name)]
            #expect(try Self.sweeps(world) == [name], "\(mode)")
        }
    }

    /// A key the live history holds (the pre-crossing key — rule 4 carried it) is owed too.
    @Test func theEnvelopeOfAKeyTheHistoryHoldsIsOwed() throws {
        let older = StoreKey.mint()
        var world = try AWorld(.castle, history: [older])
        let name = Self.envelopeName(PF.fp(older))
        world.extraEntries = [CatalogEntry(place: .container, name: name)]
        #expect(try Self.sweeps(world) == [name])
    }

    /// Nothing the live file does not vouch for, nothing but the fingerprint form, nothing below the root, nothing outside
    /// the container.
    @Test func noNameTheLiveFileDoesNotVouchForIsOwed() throws {
        var world = try AWorld(.standard)
        let fp = PF.fp(world.key)
        let name = Self.envelopeName(fp)
        world.extraEntries = [
            CatalogEntry(place: .container, name: Self.envelopeName(PF.fp(StoreKey.mint()))),
            CatalogEntry(place: .container, name: "variorum-keys.json"),
            CatalogEntry(place: .container, name: "variorum-keys-\(fp).stale-1791000000.json"),
            CatalogEntry(place: .container, name: "variorum-keys-\(fp.prefix(8)).json"),
            CatalogEntry(place: .container, folders: ["Previous Libraries", "2026-01-02-030405"], name: name),
            CatalogEntry(place: .container, folders: ["Backups"], name: name),
            CatalogEntry(place: .farFolder, name: name),
            CatalogEntry(place: .farFolder, folders: ["Variorum", "Backups"], name: name),
        ]
        let swept = try Self.sweeps(world)
        #expect(swept.isEmpty, "\(swept)")
    }

    /// Before unlock nothing decides; a live file of ANOTHER key (rule 21's stray) vouches for nothing.
    @Test func nothingIsOwedUnlessTheOpenedKeysLiveFileVouches() throws {
        var locked = try AWorld(.standard)
        locked.extraEntries = [CatalogEntry(place: .container, name: Self.envelopeName(PF.fp(locked.key)))]
        locked.unlocked = false
        #expect(try locked.assessed().repairs.isEmpty)

        var stray = try AWorld(.standard)
        let name = Self.envelopeName(PF.fp(stray.key))
        stray.extraEntries = [CatalogEntry(place: .container, name: name)]
        let other = StoreKey.mint()
        stray.liveFile = try KeyFile.building(
            libraryID: stray.world.library, key: other, epoch: 1, locks: NewKeyLocks(passphrase: stray.world.p, words: stray.world.w))
        #expect(try Self.sweeps(stray).isEmpty, "a live file of another key vouches for nothing")
    }
}

@Suite("VX-443 — the store-id envelope's sweep: the executor verifies with the key in hand, then deletes by name")
struct OlderKeyFileSweepExecutorTests {
    static func envelopeName(_ fingerprint: String) -> String { "variorum-keys-\(fingerprint).json" }

    @Test func aVerifiedEnvelopeIsDeletedByNameAndSaidOnce() throws {
        let fixture = try EX(.standard)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let name = Self.envelopeName(PF.fp(fixture.key))
        fixture.world.besideTheLibrary = [name]
        let report = try executor.runRepairs([.deleteOlderKeyFile(name: name)], on: &library)
        #expect(report.done == [.deleteOlderKeyFile(name: name)] && report.skipped.isEmpty)
        #expect(fixture.world.besideTheLibrary.isEmpty)
        #expect(fixture.world.writes.last == .olderKeyFileDelete(name))
        #expect(fixture.world.logLines.filter { $0.contains(name) }.count == 1, "said once, by name: \(fixture.world.logLines)")
        let again = try executor.runRepairs([.deleteOlderKeyFile(name: name)], on: &library)
        #expect(again.skipped.map(\.reason) == [.nothingThere], "idempotent")
    }

    /// The pre-crossing key's envelope: verified by OPENING the live history under the current key.
    @Test func thePreCrossingKeysEnvelopeIsVerifiedThroughTheHistory() async throws {
        let fixture = try EX(.standard)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let before = library.key
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .alwaysAsk)
        #expect(library.key != before)
        let name = Self.envelopeName(PF.fp(before))
        fixture.world.besideTheLibrary = [name]
        let report = try executor.runRepairs([.deleteOlderKeyFile(name: name)], on: &library)
        #expect(report.done == [.deleteOlderKeyFile(name: name)], "\(report)")
        #expect(fixture.world.besideTheLibrary.isEmpty)
    }

    /// A repair the live file does not vouch for — forged, or `assess` wrong — deletes nothing: another key's name, or no
    /// live key file of the opened key.
    @Test func anUnvouchedNameIsRefusedAndNothingIsTouched() throws {
        let fixture = try EX(.standard)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let stranger = Self.envelopeName(PF.fp(StoreKey.mint()))
        fixture.world.besideTheLibrary = [stranger]
        let writes = fixture.world.writes.count
        let report = try executor.runRepairs([.deleteOlderKeyFile(name: stranger)], on: &library)
        #expect(report.skipped.map(\.reason) == [.preconditionDoesNotVerify])
        #expect(fixture.world.besideTheLibrary == [stranger] && fixture.world.writes.count == writes)

        let own = Self.envelopeName(PF.fp(fixture.key))
        fixture.world.besideTheLibrary = [own]
        library.keyFile = nil
        let noLive = try executor.runRepairs([.deleteOlderKeyFile(name: own)], on: &library)
        #expect(noLive.skipped.map(\.reason) == [.preconditionDoesNotVerify])
        #expect(fixture.world.besideTheLibrary == [own] && fixture.world.writes.count == writes)
    }

    /// Any name but an older fingerprint-named key file's is forbidden before a leaf is reached — this design's own names
    /// above all.
    @Test func everyOtherNameIsForbidden() throws {
        let fixture = try EX(.standard)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let fp = PF.fp(fixture.key)
        let writes = fixture.world.writes.count
        for name in [ProtectionNames.keyFilename, CatalogNames.libraryFilename, "variorum-keys.json",
                     "variorum-keys-\(fp).stale-1791000000.json", "../variorum-keys-\(fp).json"] {
            let report = try executor.runRepairs([.deleteOlderKeyFile(name: name)], on: &library)
            #expect(report.skipped.map(\.reason) == [.forbidden], "\(name)")
        }
        #expect(fixture.world.writes.count == writes)
        #expect(fixture.world.liveKeyFile != nil)
    }
}
