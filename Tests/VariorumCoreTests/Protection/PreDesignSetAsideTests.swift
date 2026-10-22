//
//  PreDesignSetAsideTests.swift
//  VariorumCoreTests — VX-329 U4 piece 3: THE WHOLE SET-ASIDE (the plan's §6d + THE RULING under the U4 record: (a) — link,
//  one atomic rename, unlink; resumed from the disk's own identity). Her confirm promises "Your old library will be set
//  aside whole in Previous Libraries — nothing is deleted." These pins hold that promise on a real temp folder:
//    · the members are named from the slot's LISTING alone (rule 26: never read);
//    · the files move WHOLE — every member in one `Previous Libraries/<stamp>/`, each the SAME FILE (device + inode) it
//      was in the slot, so nothing was copied (and so nothing was read); a WAL with frames rides whole; nothing of hers or
//      of the container's moves;
//    · the fresh mint lands in the emptied slot with nothing of the old library beside it;
//    · a failed link refuses WHOLE (nothing moved, no folder made); an existing `<stamp>/` is never overwritten;
//    · THE CRASH ARMS — an interruption at EVERY seam (after each link, staged, committed, after each unlink): before the
//      commit the slot is untouched and nothing is listed; after it the aside is whole and the slot a remainder of its own
//      files; the next press (or the creation road) finishes into the SAME folder — never two asides, never a split;
//    · the stale-staging sweep never deletes a file found nowhere else.
//

import CryptoKit
import Darwin
import Foundation
import Testing

@testable import VariorumCore

/// A slot's folder on disk with a library from before this design in it — and the things that are NOT the library's.
struct PreDesignSlot {
    let folder: URL
    let fingerprint = PF.fp(StoreKey.mint())

    init() throws {
        folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("vx329-u4-setaside-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    }

    var store: URL { url(CatalogNames.libraryFilename) }
    var previous: URL { folder.appendingPathComponent(CatalogNames.previousLibrariesFolderName, isDirectory: true) }
    func url(_ name: String) -> URL { folder.appendingPathComponent(name) }

    /// The library's files (members) and the bytes each was planted with.
    var library: [String] {
        [CatalogNames.libraryFilename, "variorum.sqlite-wal", "variorum.sqlite-shm", PF.olderLegacyKeyFilename,
         PF.olderKeyFilename(fingerprint), "variorum-keys-\(fingerprint).stale-1791000000.json", LibraryRestoreHold.filename]
    }
    /// What stands beside it and is NOT the library's: the container's marker, the recipe, her file, a copies home.
    static let notTheLibrarys = ["variorum-library-lived-here", CatalogNames.restoreRecipeFilename, "notes.txt"]

    func plant() throws -> [String: Data] {
        var bytes: [String: Data] = [:]
        for name in library + Self.notTheLibrarys {
            // The WAL carries "frames" — non-empty bytes that must ride whole, never be drained.
            let data = Data((0..<(name.hasSuffix("-wal") ? 4096 : 512)).map { _ in UInt8.random(in: 0...255) })
            try data.write(to: url(name))
            bytes[name] = data
        }
        let backups = folder.appendingPathComponent(CatalogNames.backupsFolderName, isDirectory: true)
        try FileManager.default.createDirectory(at: backups, withIntermediateDirectories: true)
        try Data("a flat backup of the old build's".utf8).write(to: backups.appendingPathComponent("variorum-backup-x.sqlite"))
        return bytes
    }

    func names() throws -> Set<String> { Set(try FileManager.default.contentsOfDirectory(atPath: folder.path)) }

    func identities() -> [String: PreDesignSetAside.Identity] {
        var map: [String: PreDesignSetAside.Identity] = [:]
        for name in library { map[name] = PreDesignSetAside.identity(url(name)) }
        return map
    }

    /// The visible (committed) aside folders, and the hidden staging ones.
    func asides() -> [URL] {
        ((try? FileManager.default.contentsOfDirectory(atPath: previous.path)) ?? [])
            .filter { CatalogNames.stamp($0) != nil }.sorted().map { previous.appendingPathComponent($0, isDirectory: true) }
    }
    func staging() -> [String] {
        ((try? FileManager.default.contentsOfDirectory(atPath: previous.path)) ?? [])
            .filter { $0.hasPrefix(PreDesignSetAside.stagingPrefix) }
    }

    /// The slot as the catalogue would list its root (names only) — the fact's input.
    func readsAsPreDesign() throws -> Bool {
        let present = FileManager.default.fileExists(atPath: store.path)
        let entries = try names().map { CatalogEntry(place: .container, name: $0) }
        return AssessRules.preDesignStore(storeFile: present ? .present : .absent, catalog: Catalog.build(entries))
    }

    func remove() { try? FileManager.default.removeItem(at: folder) }
}

@Suite("VX-329 U4 — the whole set-aside: link, one rename, unlink; resumed from the disk's own identity")
struct PreDesignSetAsideTests {
    static let now = CF.stamp(5)

    /// Every member of `slot.library` in exactly `folder`, each the same file it was in the slot, its bytes unchanged.
    static func expectWhole(_ folder: URL, _ slot: PreDesignSlot, before: [String: PreDesignSetAside.Identity],
                            bytes: [String: Data], sourceLocation: SourceLocation = #_sourceLocation) throws {
        let inside = Set(try FileManager.default.contentsOfDirectory(atPath: folder.path))
        #expect(inside == Set(slot.library), "the aside holds the library whole: \(inside.sorted())",
                sourceLocation: sourceLocation)
        for name in slot.library {
            let here = PreDesignSetAside.identity(folder.appendingPathComponent(name))
            #expect(here?.device == before[name]?.device && here?.inode == before[name]?.inode,
                    "\(name) is the same file — moved by its entry, never copied", sourceLocation: sourceLocation)
            #expect(try Data(contentsOf: folder.appendingPathComponent(name)) == bytes[name], "\(name)'s bytes",
                    sourceLocation: sourceLocation)
        }
    }

    // MARK: - The members, from the listing alone

    @Test func theMembersAreNamedFromTheSlotsListingAlone() {
        let fp = PF.fp(StoreKey.mint())
        let names = ["notes.txt", "variorum-library-lived-here", ProtectionNames.keyFilename, ProtectionNames.planFilename,
                     CatalogNames.restoreRecipeFilename, LibraryRestoreHold.filename, PF.olderKeyFilename(fp),
                     "variorum.sqlite-shm", CatalogNames.libraryFilename, "variorum.sqlite-wal", PF.olderLegacyKeyFilename,
                     "variorum-keys.stale-1791000000.json", "variorum-keys.stale-.json", "variorum-keys-0a1b2c3d.json",
                     "variorum.sqlite-journal"]
        #expect(PreDesignSetAside.members(inSlotFolder: names, carryingHold: true) == [
            "variorum.sqlite-wal", "variorum.sqlite-shm", "variorum.sqlite-journal", CatalogNames.libraryFilename,
        ] + [PF.olderKeyFilename(fp), PF.olderLegacyKeyFilename, "variorum-keys.stale-1791000000.json"].sorted()
            + [LibraryRestoreHold.filename], "the sidecars leave first, then the store, its key files, its hold")
        let withoutTheHold = PreDesignSetAside.members(inSlotFolder: names, carryingHold: false)
        #expect(!withoutTheHold.contains(LibraryRestoreHold.filename), "a landing's own hold stays (T-5)")
        #expect(!withoutTheHold.contains(ProtectionNames.keyFilename) && !withoutTheHold.contains("notes.txt"))
        #expect(PreDesignSetAside.members(inSlotFolder: ["notes.txt"], carryingHold: true).isEmpty)
    }

    // MARK: - Files moved whole; the fresh mint after

    @Test func theLibraryIsSetAsideWholeTheSlotEmptiedNothingCopied() throws {
        let slot = try PreDesignSlot()
        defer { slot.remove() }
        let bytes = try slot.plant()
        let before = slot.identities()
        #expect(try slot.readsAsPreDesign())
        let report = try PreDesignSetAside.setAsideWhole(slotFolder: slot.folder, carryingHold: true, now: Self.now)
        let folder = try #require(report.folder)
        #expect(folder == slot.previous.appendingPathComponent(CatalogNames.stampString(Self.now), isDirectory: true))
        try Self.expectWhole(folder, slot, before: before, bytes: bytes)
        let left = try slot.names()
        #expect(left.isDisjoint(with: slot.library), "nothing of the library left in the slot: \(left.sorted())")
        #expect(Set(PreDesignSlot.notTheLibrarys).isSubset(of: left), "nothing of hers or the container's moved")
        #expect(left.contains(CatalogNames.backupsFolderName))
        #expect(slot.staging().isEmpty && slot.asides().count == 1)
        #expect(CatalogNames.parseFolder(folder.lastPathComponent, under: .previousLibraries)
            == .previousLibrary(stamp: Self.now), "a Previous Libraries folder the catalogue reads")
        #expect(try !slot.readsAsPreDesign(), "her face is gone")
    }

    @Test func theFreshMintLandsInTheEmptiedSlotWithNothingOfTheOldBesideIt() throws {
        let slot = try PreDesignSlot()
        defer { slot.remove() }
        _ = try slot.plant()
        try PreDesignSetAside.setAsideWhole(slotFolder: slot.folder, carryingHold: true, now: Self.now)
        let key = StoreKey.mint()
        let record = ProtectionRecord.minting(
            libraryID: PF.id(), mode: .standard, account: nil, currentFingerprint: PF.fp(key), at: PF.t0)
        try ProtectionLibraryFiles.createLibrary(at: slot.store, key: key, record: record, date: PF.t0)
        #expect(ProtectionLibraryFiles.opens(slot.store, key: key), "the new library opens with its own key")
        #expect(try ProtectionLibraryFiles.readRecord(at: slot.store, key: key) == record)
        #expect(try !slot.readsAsPreDesign(), "a store with no older name beside it")
        let aside = try #require(slot.asides().first)
        #expect(PreDesignSetAside.identity(aside.appendingPathComponent(CatalogNames.libraryFilename))?.inode
            != PreDesignSetAside.identity(slot.store)?.inode, "the old store is untouched in its aside")
    }

    // MARK: - Refusals: nothing moved

    @Test func aFailedLinkRefusesWholeAndNothingMoves() throws {
        let slot = try PreDesignSlot()
        defer { slot.remove() }
        let bytes = try slot.plant()
        // A member that cannot be linked (a folder wearing a key file's name — `link(2)` refuses a directory).
        try FileManager.default.createDirectory(
            at: slot.url("variorum-keys-\(slot.fingerprint).stale-1791000001.json"), withIntermediateDirectories: false)
        let before = slot.identities()
        #expect(throws: PreDesignSetAside.Failure.self) {
            try PreDesignSetAside.setAsideWhole(slotFolder: slot.folder, carryingHold: true, now: Self.now)
        }
        for name in slot.library {
            #expect(PreDesignSetAside.identity(slot.url(name))?.inode == before[name]?.inode, "\(name) stays")
            #expect(try Data(contentsOf: slot.url(name)) == bytes[name])
        }
        #expect(!FileManager.default.fileExists(atPath: slot.previous.path), "no folder made, no staging left")
    }

    @Test func anExistingStampIsNeverOverwrittenAFreshOneIsTaken() throws {
        let slot = try PreDesignSlot()
        defer { slot.remove() }
        let bytes = try slot.plant()
        let before = slot.identities()
        let taken = slot.previous.appendingPathComponent(CatalogNames.stampString(Self.now), isDirectory: true)
        try FileManager.default.createDirectory(at: taken, withIntermediateDirectories: true)  // EMPTY — rename(2) would
        let report = try PreDesignSetAside.setAsideWhole(slotFolder: slot.folder, carryingHold: true, now: Self.now)
        let folder = try #require(report.folder)
        #expect(folder.lastPathComponent == CatalogNames.stampString(Self.now + 1), "the next free stamp")
        #expect(try FileManager.default.contentsOfDirectory(atPath: taken.path).isEmpty, "the existing folder untouched")
        try Self.expectWhole(folder, slot, before: before, bytes: bytes)
    }

    // MARK: - The crash arms (every seam)

    /// The seams of one act over the planted slot, in order.
    static func seams(_ slot: PreDesignSlot) -> [PreDesignSetAside.Seam] {
        let order = PreDesignSetAside.members(inSlotFolder: slot.library, carryingHold: true)
        return order.map { .linked($0) } + [.staged, .committed] + order.map { .unlinked($0) }
    }

    @Test func aCrashAtAnySeamLeavesTheOldStateOrAFinishableOneAndTheNextPressFinishesIntoTheSameFolder() throws {
        let probe = try PreDesignSlot()
        let count = Self.seams(probe).count
        probe.remove()
        #expect(count == 2 * 7 + 2, "seven members linked, staged, committed, seven unlinked")
        for index in 0..<count {
            let slot = try PreDesignSlot()
            defer { slot.remove() }
            // Each slot names its own older key files (its own fingerprint): its seams are its own.
            let seams = Self.seams(slot)
            let stop = seams[index]
            let bytes = try slot.plant()
            let before = slot.identities()
            #expect(throws: PreDesignSetAside.Interruption.self) {
                try PreDesignSetAside.setAsideWhole(
                    slotFolder: slot.folder, carryingHold: true, now: Self.now,
                    seam: { if $0 == stop { throw PreDesignSetAside.Interruption() } })
            }
            let order = PreDesignSetAside.members(inSlotFolder: slot.library, carryingHold: true)
            let committedAt = seams.firstIndex(of: .committed)!
            let stopAt = seams.firstIndex(of: stop)!
            if stopAt < committedAt {
                // THE OLD STATE: the slot untouched, nothing listed (only hidden staging debris).
                for name in slot.library {
                    #expect(PreDesignSetAside.identity(slot.url(name))?.inode == before[name]?.inode, "\(stop): \(name)")
                }
                #expect(slot.asides().isEmpty, "\(stop): nothing listed before the commit")
                #expect(try slot.readsAsPreDesign(), "\(stop): her face again")
            } else {
                // THE NEW STATE, FINISHABLE: the aside whole; the slot a remainder of its own files.
                #expect(slot.asides().count == 1, "\(stop)")
                try Self.expectWhole(try #require(slot.asides().first), slot, before: before, bytes: bytes)
                let unlinked: Int
                if case .unlinked(let name) = stop { unlinked = order.firstIndex(of: name)! + 1 } else { unlinked = 0 }
                #expect(try slot.names().intersection(slot.library) == Set(order.dropFirst(unlinked)), "\(stop)")
                // The store still there ⇒ every older key file is too ⇒ her face again; gone ⇒ an empty slot.
                let storeLeft = FileManager.default.fileExists(atPath: slot.store.path)
                #expect(try slot.readsAsPreDesign() == storeLeft, "\(stop)")
            }
            // THE NEXT PRESS (her face again) — or, the store gone, THE CREATION ROAD's finish.
            if FileManager.default.fileExists(atPath: slot.store.path) {
                try PreDesignSetAside.setAsideWhole(slotFolder: slot.folder, carryingHold: true, now: Self.now + 60)
            } else {
                try PreDesignSetAside.finishInterrupted(slotFolder: slot.folder)
            }
            #expect(slot.asides().count == 1, "\(stop): never a second aside")
            #expect(slot.staging().isEmpty, "\(stop): the stale staging swept")
            try Self.expectWhole(try #require(slot.asides().first), slot, before: before, bytes: bytes)
            #expect(try slot.names().isDisjoint(with: slot.library), "\(stop): the slot emptied of the library")
        }
    }

    /// A remainder whose sidecar is NOT its aside's (something opened the old store since) is left as it is — a stray WAL
    /// must never stand beside the next library, and nothing guesses.
    @Test func aRemainderBesideAForeignSidecarIsLeftAsItIs() throws {
        let slot = try PreDesignSlot()
        defer { slot.remove() }
        _ = try slot.plant()
        #expect(throws: PreDesignSetAside.Interruption.self) {
            try PreDesignSetAside.setAsideWhole(
                slotFolder: slot.folder, carryingHold: true, now: Self.now,
                seam: { if $0 == .committed { throw PreDesignSetAside.Interruption() } })
        }
        let wal = slot.url("variorum.sqlite-wal")
        try FileManager.default.removeItem(at: wal)
        try Data("a newer WAL".utf8).write(to: wal)
        let before = try slot.names()
        #expect(throws: PreDesignSetAside.Failure.self) { try PreDesignSetAside.finishInterrupted(slotFolder: slot.folder) }
        #expect(try slot.names() == before, "nothing left the slot")
    }

    // MARK: - The stale-staging sweep

    @Test func theStaleStagingSweepNeverDeletesAFileFoundNowhereElse() throws {
        let slot = try PreDesignSlot()
        defer { slot.remove() }
        _ = try slot.plant()
        try FileManager.default.createDirectory(at: slot.previous, withIntermediateDirectories: true)
        // Debris: hard links of the slot's own files.
        let debris = slot.previous.appendingPathComponent(PreDesignSetAside.stagingPrefix + "a", isDirectory: true)
        try FileManager.default.createDirectory(at: debris, withIntermediateDirectories: false)
        #expect(link(slot.store.path, debris.appendingPathComponent(CatalogNames.libraryFilename).path) == 0)
        // Not debris: a file whose only entry is here.
        let only = slot.previous.appendingPathComponent(PreDesignSetAside.stagingPrefix + "b", isDirectory: true)
        try FileManager.default.createDirectory(at: only, withIntermediateDirectories: false)
        try Data("the only copy".utf8).write(to: only.appendingPathComponent(PF.olderLegacyKeyFilename))
        let report = try PreDesignSetAside.finishInterrupted(slotFolder: slot.folder)
        #expect(report.sweptStaging == 1 && report.keptStaging.count == 1)
        #expect(slot.staging().isEmpty)
        let kept = try #require(report.keptStaging.first)
        #expect(try Data(contentsOf: kept.appendingPathComponent(PF.olderLegacyKeyFilename)) == Data("the only copy".utf8),
                "committed to a stamp of its own, never deleted")
        #expect(FileManager.default.fileExists(atPath: slot.store.path), "the slot's own store untouched by a sweep")
    }
}
