//
//  U4KeyFileOfferTests.swift
//  VariorumCoreTests — VX-378 U4 resumption, piece 3: RULE 21'S KEY-FILE OFFER
//  (her ruling at the U4 stop, 2026-10-17): "The one case that needs a hand —
//  the key file beside the library does not open it — is an OFFER, naming where
//  the working key file was found … "The key file beside your library doesn't
//  open it. This Mac's keychain holds a copy that does. Use it?" / "…The backup
//  from August 3 holds a key file that does. Use it?"; none → rule 27's refusal
//  naming the places it looked. Nothing guessed; nothing written before her
//  yes." New API (red by construction: the tree before the piece refused the
//  open and had no search).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// The catalog `fixture`'s container would list: the live key file, and a
/// backup pair under `key` frozen on `day` (when `key` is given).
func offerCatalog(_ fixture: EX, backupOf key: StoreKey? = nil, keyFile: KeyFile? = nil, day: Double = 2) throws -> Catalog {
    var entries: [CatalogEntry] = []
    if let live = fixture.world.liveKeyFile {
        entries.append(CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: try live.encoded()))
    }
    if let key, let keyFile {
        let folders = CF.macFolder(fixture.libraryID, CF.macA)
        entries.append(CatalogEntry(place: .container, folders: folders, name: CF.snapshotName(CF.stamp(day), key)))
        entries.append(CatalogEntry(place: .container, folders: folders, name: CF.pairName(CF.stamp(day), key), bytes: try keyFile.encoded()))
    }
    return Catalog.build(entries)
}

@Suite("VX-378 U4 — rule 21's key-file offer: found where the app keeps them, named, written only at her yes")
struct U4KeyFileOfferTests {
    /// An old key file beside the library (Use Castle replaced it): the search
    /// finds this Mac's keychain copy, offers it in her words, writes nothing;
    /// her yes puts it beside the library and the offer is no longer owed.
    @Test func theKeychainCopyIsOfferedAndHerYesPutsItBesideTheLibrary() async throws {
        let fixture = try EX(.standard)
        let olderFile = try #require(fixture.world.liveKeyFile)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .alwaysAsk)
        let current = try #require(fixture.world.liveKeyFile)
        fixture.world.liveKeyFile = olderFile
        let e2 = fixture.executor()
        var opened = try e2.unlock(with: library.key)
        fixture.world.writes = []
        let found = try e2.searchKeyFiles(opened, catalog: try offerCatalog(fixture), typed: fixture.typed)
        guard case .offer(let offer) = found else { Issue.record("no offer: \(found)"); return }
        #expect(offer.source == .thisMacsKeychain && offer.keyFile == current)
        #expect(offer.words == "The key file beside your library doesn't open it. This Mac's keychain holds a copy that does. Use it?")
        #expect(fixture.world.writes.isEmpty, "the search wrote \(fixture.world.writes)")
        #expect(fixture.world.liveKeyFile == olderFile)
        _ = try await e2.useOfferedKeyFile(&opened, offer)
        #expect(fixture.world.liveKeyFile == current)
        #expect(opened.memory?.keyFileMirror == current && opened.section.actInFlight == nil)
        #expect(try e2.searchKeyFiles(opened, catalog: try offerCatalog(fixture)) == .besideOpensIt)
    }

    /// With no keychain copy, a backup's key file is offered, naming the
    /// backup's day in her words.
    @Test func aBackupsKeyFileIsOfferedNamingItsDay() async throws {
        let fixture = try EX(.standard)
        let olderFile = try #require(fixture.world.liveKeyFile)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .alwaysAsk)
        let current = try #require(fixture.world.liveKeyFile)
        fixture.world.liveKeyFile = olderFile
        fixture.world.memories = [:]
        let e2 = fixture.executor()
        let opened = try e2.unlock(with: library.key)
        let catalog = try offerCatalog(fixture, backupOf: library.key, keyFile: current, day: 3)
        let found = try e2.searchKeyFiles(opened, catalog: catalog, typed: fixture.typed)
        guard case .offer(let offer) = found, case .backup(_, let date) = offer.source else {
            Issue.record("no backup offered: \(found)")
            return
        }
        #expect(date == CF.stamp(3) && offer.keyFile == current)
        #expect(offer.words == "The key file beside your library doesn't open it. The backup from <date> holds a key file that does. Use it?")
        #expect(offer.sentence { _ in "August 3" }
                == "The key file beside your library doesn't open it. The backup from August 3 holds a key file that does. Use it?")
    }

    /// No key file anywhere opens it (the stray beside it reaches nothing, no
    /// keychain copy, no backup): rule 27, the places looked named.
    @Test func withNoKeyFileAnywhereTheSearchSaysRule27() async throws {
        let fixture = try EX(.standard)
        let olderFile = try #require(fixture.world.liveKeyFile)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        fixture.world.liveKeyFile = olderFile
        fixture.world.memories = [:]
        let opened = try fixture.executor().unlock(with: library.key)
        let found = try fixture.executor().searchKeyFiles(opened, catalog: try offerCatalog(fixture), typed: fixture.typed)
        #expect(found == .noKeyFileAnywhere(NoKeyFileAnywhere(accountRoad: false)))
        if case .noKeyFileAnywhere(let nothing) = found { #expect(nothing.wouldHaveWorked == KeyFileHome.allCases) }
    }

    /// PROVISIONAL P-VX378-U4-6: an older library file beside a key file that
    /// reaches it only through its history — the library's own key file is
    /// offered when one exists; with none, the split pair is said, not refused.
    @Test func aKeyFileReachingTheLibraryOnlyThroughItsHistory() async throws {
        let fixture = try EX(.standard)
        let k0 = fixture.key
        let olderLibrary = try #require(fixture.world.live), olderFile = try #require(fixture.world.liveKeyFile)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        let k1 = library.key
        fixture.world.live = olderLibrary
        let e2 = fixture.executor()
        let opened = try e2.unlock(with: k0, alsoInHand: [k1])
        let withBackup = try e2.searchKeyFiles(opened, catalog: try offerCatalog(fixture, backupOf: k0, keyFile: olderFile))
        guard case .offer(let offer) = withBackup else { Issue.record("no offer: \(withBackup)"); return }
        #expect(offer.keyFile == olderFile)
        fixture.world.memories = [:]
        let none = try e2.searchKeyFiles(opened, catalog: try offerCatalog(fixture))
        #expect(none == .besideOpensItOnlyThroughItsHistory)
    }

    /// `assess` owes the offer — never a refusal — when the key file beside the
    /// library is another key's and a home holds the library's own (here this
    /// Mac's keychain copy); with no home holding it and the stray reaching
    /// nothing, rule 27 is said instead.
    @Test func assessOwesTheOffer() throws {
        var world = try AWorld(.castle)
        var memory = world.agreeingMemory
        memory.keyFileMirror = world.liveFile
        world.memory = memory
        #expect(!(try world.assessed()).acts.contains(.offerKeyFile))
        world.liveFile = try KeyFile.building(
            libraryID: world.world.library, key: StoreKey.mint(), epoch: 1,
            locks: NewKeyLocks(passphrase: world.world.p, words: world.world.w))
        let assessed = try world.assessed()
        #expect(assessed.acts.contains(.offerKeyFile), "\(assessed.acts)")
        #expect(assessed.doors.values.contains { $0.isOpen })
        memory.keyFileMirror = nil
        world.memory = memory
        let nothing = try world.assessed()
        #expect(!nothing.acts.contains(.offerKeyFile))
        #expect(nothing.faults.contains { if case .noKeyFileAnywhere = $0 { return true } else { return false } }, "\(nothing.faults)")
    }

    /// Rule 20 over the accepted offer: a crash after every write, a relaunch
    /// and a settle — the offered file beside the library (finished) or the
    /// stray still there (never happened), never a third state, nothing left in
    /// flight. (By hand, not `CrashHarness`: its settled-state check takes the
    /// key file beside the library to be the library's own, which the "never
    /// happened" side of THIS act is not, by construction.)
    @Test func aCrashAfterEveryWriteOfHerYesFinishesOrNeverHappened() async throws {
        func make() async throws -> (EX, KeyFile, KeyFile) {
            let fixture = try EX(.standard)
            let olderFile = try #require(fixture.world.liveKeyFile)
            let executor = fixture.executor()
            var library = try fixture.unlocked(executor)
            _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
            fixture.key = library.key
            let current = try #require(fixture.world.liveKeyFile)
            fixture.world.liveKeyFile = olderFile
            fixture.world.writes = []
            return (fixture, olderFile, current)
        }
        func yes(_ fixture: EX, _ executor: ProtectionExecutor, _ library: inout UnlockedLibrary) async throws {
            guard case .offer(let offer) = try executor.searchKeyFiles(library, catalog: try offerCatalog(fixture)) else {
                throw ExecutorRefusal.nothingToDo
            }
            _ = try await executor.useOfferedKeyFile(&library, offer)
        }
        let (clean, _, cleanCurrent) = try await make()
        let cleanExecutor = clean.executor()
        var cleanLibrary = try clean.unlocked(cleanExecutor)
        try await yes(clean, cleanExecutor, &cleanLibrary)
        #expect(clean.world.liveKeyFile == cleanCurrent)
        let count = clean.world.writes.count
        #expect(count >= 3)
        for crashAt in 1...count {
            let (fixture, stray, current) = try await make()
            fixture.world.crashAfterWrites = crashAt
            let executor = fixture.executor()
            var library = try fixture.unlocked(executor)
            do {
                try await yes(fixture, executor, &library)
                Issue.record("write \(crashAt): no crash")
            } catch is SimulatedCrash {}
            fixture.world.relaunch()
            let e2 = fixture.executor()
            var reopened = try e2.unlock(with: fixture.key)
            _ = try await e2.settle(&reopened, typed: fixture.typed)
            let done = fixture.world.liveKeyFile == current, never = fixture.world.liveKeyFile == stray
            #expect(done != never, "crash after write \(crashAt): \(done ? "both" : "neither")")
            #expect(fixture.world.plan == nil && reopened.section.actInFlight == nil, "crash after write \(crashAt): left in flight")
        }
    }
}
