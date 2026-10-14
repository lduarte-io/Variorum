//
//  CatalogTests.swift
//  VariorumCoreTests — VX-305 U2: the catalog's ONE name parser covers every
//  name today's builds write (the union of today's three parsers, and agrees
//  with each of them on its own names), refuses every name no build writes,
//  and attributes each copy to its library (from the pair's key file) and its
//  Mac (from the subfolder).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// Key files and listings for the catalog, retention and route-finder suites.
enum CF {
    static func stamp(_ day: Double, _ seconds: Double = 0) -> Date {
        // Whole seconds (the names are second-granular), UTC.
        Date(timeIntervalSince1970: 1_791_000_000 + day * 86_400 + seconds)
    }

    static func stampText(_ date: Date) -> String { CatalogNames.stampString(date) }

    static func fp8(_ key: StoreKey) -> String { StoreKeyEnvelope.shortFingerprint(PF.fp(key)) }

    static func snapshotName(_ date: Date, _ key: StoreKey?) -> String {
        "variorum-backup-\(stampText(date))" + (key.map { "-\(fp8($0))" } ?? "") + ".sqlite"
    }

    static func pairName(_ date: Date, _ key: StoreKey?) -> String {
        String(snapshotName(date, key).dropLast(".sqlite".count)) + ".keys.json"
    }

    /// A format-3 key file (wraps-less — the catalog reads names and
    /// fingerprints only), optionally with older keys in its history.
    static func format3(library: String, key: StoreKey, epoch: Int = 1, history: [StoreKey] = []) throws -> Data {
        var file = KeyFile(libraryID: library, key: key, epoch: epoch)
        file.history = try history.enumerated().map { index, old in
            HistoryEntry(
                fingerprint: PF.fp(old), epoch: index + 1, retiredAt: PF.t0,
                wrapped: try AES.KeyWrap.wrap(SymmetricKey(data: old.data), using: SymmetricKey(data: key.data)))
        }
        return try file.encoded()
    }

    /// A format-2 key file (today's), with or without the old shared Apple wrap.
    static func format2(library: String, key: StoreKey, appleWrapped: Bool = false) throws -> Data {
        var envelope = StoreKeyEnvelope(storeID: library, keyFingerprint: PF.fp(key))
        if appleWrapped {
            try envelope.setAppleWrappedCopy(key: key, under: SymmetricKey(size: .bits256), appleKeyID: PF.id())
        }
        return try JSONEncoder().encode(envelope)
    }

    static let lib1 = "aaaa1111-0000-4000-8000-000000000001"
    static let lib2 = "bbbb2222-0000-4000-8000-000000000002"
    static let macA = "cccc3333-0000-4000-8000-00000000000a"
    static let macB = "dddd4444-0000-4000-8000-00000000000b"

    static func macFolder(_ library: String, _ mac: String) -> [String] {
        ["Backups", ProtectionNames.library8(library), ProtectionNames.mac8(mac)]
    }
}

@Suite("VX-305 U2 — the catalog's one name parser: the union of today's three, and nothing else")
struct CatalogNameTests {
    /// Every name today's builds write, built with today's own writers where
    /// they live in core, parses — and as the right thing.
    @Test func everyNameTodaysBuildsWriteParses() throws {
        let key = StoreKey.mint()
        let fp = PF.fp(key)
        let when = CF.stamp(3, 3723)
        let stamp = CF.stampText(when)
        // The backup writer (`StoreBackup.performPrimaryLeg` + the lock-time copy).
        #expect(CatalogNames.parseFile("variorum-backup-\(stamp).sqlite") == .snapshot(stamp: when, fingerprint8: nil))
        #expect(CatalogNames.parseFile(CF.snapshotName(when, key)) == .snapshot(stamp: when, fingerprint8: CF.fp8(key)))
        // The pair writer (`StoreBackup.pairedKeyFile` = `LibraryClassifier.pairedKeyFile`).
        let pair = LibraryClassifier.pairedKeyFile(for: URL(fileURLWithPath: "/x/" + CF.snapshotName(when, key)))
        #expect(CatalogNames.parseFile(pair.lastPathComponent) == .snapshotKeyFile(stamp: when, fingerprint8: CF.fp8(key)))
        // The key-file names (`StoreKeyEnvelope.filename(forFingerprint:)`, the legacy name).
        #expect(CatalogNames.parseFile(StoreKeyEnvelope.filename(forFingerprint: fp)) == .fingerprintKeyFile(fingerprint: fp))
        #expect(CatalogNames.parseFile(StoreKeyEnvelope.legacyFilename) == .legacyKeyFile)
        // The set-aside writers (`StoreIdentity.setAside`, the launch gate's): the
        // same expression, restated here.
        for base in [StoreKeyEnvelope.filename(forFingerprint: fp), StoreKeyEnvelope.legacyFilename] {
            let aside = URL(fileURLWithPath: "/x/" + base).deletingPathExtension()
                .appendingPathExtension("stale-\(Int(when.timeIntervalSince1970)).json").lastPathComponent
            let expected: CatalogNames.FileName = .setAsideKeyFile(
                fingerprint: base == StoreKeyEnvelope.legacyFilename ? nil : fp, setAsideAt: when)
            #expect(CatalogNames.parseFile(aside) == expected, "\(aside)")
        }
        // The adoption's two stamp folders (`LibraryAdoption.plan`).
        let store = URL(fileURLWithPath: "/lib/variorum.sqlite")
        let plan = LibraryAdoption.plan(adopting: URL(fileURLWithPath: "/in/variorum.sqlite"), keyFile: nil,
                                        intoStoreAt: store, now: when)
        #expect(CatalogNames.parseFolder(plan.asideFolder.lastPathComponent, under: .previousLibraries)
            == .previousLibrary(stamp: when))
        #expect(CatalogNames.parseFolder(plan.safetyCopyFolder.lastPathComponent, under: .safetyCopies)
            == .adoptionSafetyCopy(stamp: when))
        #expect(CatalogNames.parseFolder(LibraryAdoption.previousLibrariesFolderName, under: nil) == .previousLibraries)
        // The slot, its sidecars, the recipe, the exports, the hand-off folder.
        #expect(CatalogNames.parseFile("variorum.sqlite") == .library)
        #expect(CatalogNames.parseFile("variorum.sqlite-wal") == .sidecar(of: .library, suffix: "-wal"))
        #expect(CatalogNames.parseFile(CF.snapshotName(when, key) + "-shm")
            == .sidecar(of: .snapshot(stamp: when, fingerprint8: CF.fp8(key)), suffix: "-shm"))
        #expect(CatalogNames.parseFile("RESTORE.md") == .restoreRecipe)
        #expect(CatalogNames.parseFolder("md-exports", under: .variorum) == .markdownExports)
        #expect(CatalogNames.parseFolder("Variorum Library — 2026-10-06", under: nil) == .handOff(day: "2026-10-06"))
        #expect(CatalogNames.parseFolder("Variorum Library — 2026-10-06 (3)", under: nil) == .handOff(day: "2026-10-06"))
        // This build's own.
        #expect(CatalogNames.parseFile(ProtectionNames.keyFilename) == .keyFile)
        #expect(CatalogNames.parseFile(ProtectionNames.planFilename) == .plan)
        let sub = ProtectionNames.backupsSubpath(libraryID: CF.lib1, deviceID: CF.macA).split(separator: "/").map(String.init)
        #expect(CatalogNames.parseFolder(sub[1], under: .backups) == .libraryFolder(library8: sub[1]))
        #expect(CatalogNames.parseFolder(sub[2], under: .libraryFolder(library8: sub[1])) == .macFolder(mac8: sub[2]))
    }

    /// On every name in a corpus — the app's and adversarial ones — the one
    /// parser agrees with each of today's parsers about what that parser
    /// reads (the union keeps each one's answers).
    @Test func theOneParserAgreesWithEachOfTodaysThree() {
        let key = StoreKey.mint()
        let stamp = CF.stampText(CF.stamp(7, 45_296))
        let corpus = [
            "variorum-backup-\(stamp).sqlite",
            "variorum-backup-\(stamp)-\(CF.fp8(key)).sqlite",
            "variorum-backup-\(stamp)-ABCDEF12.sqlite",          // uppercase fp8 — never written
            "variorum-backup-\(stamp)-abcdef1.sqlite",           // seven hex
            "variorum-backup-\(stamp)-abcdef123.sqlite",         // nine hex
            "variorum-backup-\(stamp)-a1-window.sqlite",         // the A1 rail's shape
            "variorum-backup-a1-\(stamp).sqlite",
            "variorum-backup-seed-drill-1.sqlite",
            "variorum-backup-2026-13-40-999999.sqlite",          // a stamp that does not read back
            "variorum-backup-2026-1-2-3.sqlite",
            "variorum-backup-.sqlite",
            "variorum-backup-\(stamp)",                          // no extension
            "notvariorum-backup-\(stamp).sqlite",
        ]
        for name in corpus {
            let url = URL(fileURLWithPath: "/folder/" + name)
            let mine: (Date, String?)? = {
                if case .snapshot(let date, let fp8)? = CatalogNames.parseFile(name) { return (date, fp8) }
                return nil
            }()
            // 1. The backup-name parser (`StoreBackup.date(fromBackupURL:)`, restated
            //    as `BackupRestoreCandidates.backupDate` — the listing reads `.sqlite`).
            let theirs = url.pathExtension == "sqlite" ? BackupRestoreCandidates.backupDate(url) : nil
            #expect(mine?.0 == theirs, "\(name): the backup-name parser")
            // 2. The classifier's fp8 (its routing flag is looser on purpose — a
            //    picked file; its fp8 is exact).
            if let mine {
                #expect(LibraryClassifier.backupNameFingerprint(url).fp8 == mine.1, "\(name): the classifier's fp8")
            }
        }
        // 3. The stamp-folder qualifier (`LibraryAdoption.adoptionStamp`).
        for folder in [stamp, "2026-13-40-999999", "variorum-backup-a1-\(stamp)", stamp + "x", "x" + stamp] {
            let mine: Date? = {
                if case .previousLibrary(let date)? = CatalogNames.parseFolder(folder, under: .previousLibraries) { return date }
                return nil
            }()
            #expect(mine == LibraryAdoption.adoptionStamp(folder), "\(folder): the stamp-folder qualifier")
            let safety = CatalogNames.parseFolder("variorum-adopt-safety-" + folder, under: .safetyCopies)
            #expect((safety != nil) == (LibraryAdoption.adoptionStamp(folder) != nil), "\(folder): the safety twin")
        }
        // And the key-file names (`StoreKeyEnvelope.fingerprint(fromFilename:)`).
        for name in ["variorum-keys-0123456789abcdef.json", "variorum-keys-0123456789ABCDEF.json",
                     "variorum-keys-0123456789abcde.json", "variorum-keys-0123456789abcdefg.json",
                     "variorum-keys-.json", "variorum-keys.json"] {
            let mine: String? = {
                if case .fingerprintKeyFile(let fp)? = CatalogNames.parseFile(name) { return fp }
                return nil
            }()
            #expect(mine == StoreKeyEnvelope.fingerprint(fromFilename: name), "\(name)")
        }
    }

    @Test func aNameNoBuildWritesIsNotTheApps() {
        for name in ["variorum-backup-a1-2026-10-05-101010.sqlite", "variorum-library-keys.stale-1.json",
                     "variorum-keys.stale-.json", "variorum-keys.stale-12a.json", "notes.txt",
                     "variorum-plan.json.bak", "variorum.sqlite-journal-old"] {
            #expect(CatalogNames.parseFile(name) == nil, "\(name)")
        }
        #expect(CatalogNames.parseFolder("variorum-backup-a1-2026-10-05", under: .safetyCopies) == nil)
        #expect(CatalogNames.parseFolder("not-hex!", under: .backups) == nil)
        #expect(CatalogNames.parseFolder("Variorum Library — 2026-10-06 (1)", under: nil) == nil)
    }
}

@Suite("VX-305 U2 — the catalog: every place copies live, each copy attributed to its library and its Mac")
struct CatalogAttributionTests {
    /// A shared far folder holding two Macs' and two libraries' copies, a
    /// legacy flat copy, the container's own copies, an aside folder, a
    /// safety copy, set-aside files and foreign files.
    static func world() throws -> (catalog: Catalog, keys: [String: StoreKey]) {
        let k1a = StoreKey.mint(), k1b = StoreKey.mint(), k2 = StoreKey.mint(), old = StoreKey.mint()
        let flat = StoreKey.mint(), aside = StoreKey.mint(), live = StoreKey.mint()
        let d1 = CF.stamp(1), d2 = CF.stamp(2)
        var entries: [CatalogEntry] = []
        // The far folder: lib1 from Mac A and from Mac B, lib2 from Mac A.
        for (library, mac, key, day) in [(CF.lib1, CF.macA, k1a, d1), (CF.lib1, CF.macB, k1b, d2), (CF.lib2, CF.macA, k2, d1)] {
            let folders = CF.macFolder(library, mac)
            entries.append(CatalogEntry(place: .farFolder, folders: folders, name: CF.snapshotName(day, key)))
            entries.append(CatalogEntry(place: .farFolder, folders: folders, name: CF.pairName(day, key),
                                        bytes: try CF.format3(library: library, key: key)))
        }
        // This Mac's own key file for lib2 (§3.5 point 2).
        entries.append(CatalogEntry(place: .farFolder, folders: CF.macFolder(CF.lib2, CF.macA),
                                    name: ProtectionNames.keyFilename, bytes: try CF.format3(library: CF.lib2, key: k2)))
        // A legacy flat far copy whose key file sits one level up (today's folder file).
        entries.append(CatalogEntry(place: .farFolder, folders: ["Backups"], name: CF.snapshotName(d1, flat)))
        entries.append(CatalogEntry(place: .farFolder, name: StoreKeyEnvelope.filename(forFingerprint: PF.fp(flat)),
                                    bytes: try CF.format2(library: CF.lib1, key: flat)))
        // The container: a legacy flat stamp-only copy served by the legacy file.
        entries.append(CatalogEntry(place: .container, folders: ["Backups"], name: CF.snapshotName(d1, nil)))
        entries.append(CatalogEntry(place: .container, folders: ["Backups"], name: StoreKeyEnvelope.legacyFilename,
                                    bytes: try CF.format2(library: CF.lib1, key: old)))
        // An aside folder (format 3 beside today's file) and a safety copy.
        let asideFolders = ["Previous Libraries", CF.stampText(d2)]
        entries.append(CatalogEntry(place: .container, folders: asideFolders, name: "variorum.sqlite"))
        entries.append(CatalogEntry(place: .container, folders: asideFolders, name: ProtectionNames.keyFilename,
                                    bytes: try CF.format3(library: CF.lib2, key: aside)))
        entries.append(CatalogEntry(place: .container, folders: asideFolders,
                                    name: StoreKeyEnvelope.filename(forFingerprint: PF.fp(old)),
                                    bytes: try CF.format2(library: CF.lib1, key: old)))
        let safety = ["Backups", "safety-copies", "variorum-adopt-safety-" + CF.stampText(d2)]
        entries.append(CatalogEntry(place: .container, folders: safety, name: "variorum.sqlite"))
        entries.append(CatalogEntry(place: .container, folders: safety, name: StoreKeyEnvelope.legacyFilename,
                                    bytes: try CF.format2(library: CF.lib1, key: old)))
        // Beside the slot: the live file, today's file, a set-aside file, the slot itself.
        entries.append(CatalogEntry(place: .container, name: "variorum.sqlite"))
        entries.append(CatalogEntry(place: .container, name: ProtectionNames.keyFilename,
                                    bytes: try CF.format3(library: CF.lib1, key: live, epoch: 2, history: [old])))
        entries.append(CatalogEntry(place: .container, name: StoreKeyEnvelope.filename(forFingerprint: PF.fp(old)),
                                    bytes: try CF.format2(library: CF.lib1, key: old)))
        entries.append(CatalogEntry(place: .container, name: "variorum-keys.stale-1791000000.json",
                                    bytes: try CF.format2(library: CF.lib1, key: old)))
        // Foreign: the A1 rail's copies, a drill file, a stray folder.
        entries.append(CatalogEntry(place: .container, folders: ["Backups", "safety-copies"],
                                    name: "variorum-backup-a1-2026-10-05-101010.sqlite"))
        entries.append(CatalogEntry(place: .farFolder, folders: ["Backups"], name: "variorum-backup-seed-drill-1.sqlite"))
        entries.append(CatalogEntry(place: .farFolder, folders: ["Backups", "zzzz"], name: CF.snapshotName(d1, flat)))
        // Hers, not a copy: an export.
        entries.append(CatalogEntry(place: .farFolder, folders: ["md-exports", "2026-10-05"], name: "note.md"))
        let keys = ["k1a": k1a, "k1b": k1b, "k2": k2, "old": old, "flat": flat, "aside": aside, "live": live]
        return (Catalog.build(entries), keys)
    }

    @Test func everyCopyIsAttributedToItsLibraryFromItsKeyFileAndToItsMacFromItsSubfolder() throws {
        let (catalog, keys) = try Self.world()
        func copy(_ key: String) -> CatalogCopy? { catalog.copies.first { $0.fingerprint == PF.fp(keys[key]!) } }
        #expect(copy("k1a")?.library == CF.lib1 && copy("k1a")?.mac == .mac8(ProtectionNames.mac8(CF.macA)))
        #expect(copy("k1b")?.library == CF.lib1 && copy("k1b")?.mac == .mac8(ProtectionNames.mac8(CF.macB)))
        #expect(copy("k2")?.library == CF.lib2 && copy("k2")?.mac == .mac8(ProtectionNames.mac8(CF.macA)))
        #expect(copy("k1a")?.kind == .backup)
        // A legacy flat far copy: its library from today's folder file, its Mac unattributed.
        #expect(copy("flat")?.kind == .legacyFlatBackup)
        #expect(copy("flat")?.library == CF.lib1 && copy("flat")?.mac == .unattributed)
        // The container's stamp-only flat copy: this Mac's by place, served by the legacy file.
        let stampOnly = catalog.copies.first { $0.place == .container && $0.kind == .legacyFlatBackup }
        #expect(stampOnly?.mac == .thisMacsContainer && stampOnly?.library == CF.lib1)
        #expect(stampOnly?.fingerprint == PF.fp(keys["old"]!))
        // The aside folder: its format-3 file first — the key it is under.
        let aside = catalog.copies.first { $0.kind == .previousLibrary }
        #expect(aside?.fingerprint == PF.fp(keys["aside"]!) && aside?.library == nil,
                "two key files naming different libraries leave the library unattributed")
        #expect(catalog.copies.contains { $0.kind == .adoptionSafetyCopy && $0.library == CF.lib1 })
        // The slot itself is never a copy.
        #expect(!catalog.copies.contains { $0.place == .container && $0.folders.isEmpty })
        #expect(catalog.copies.count == 7)
    }

    @Test func everyKeyFileHasItsRole() throws {
        let (catalog, _) = try Self.world()
        func roles(_ role: KeyFileRole) -> Int { catalog.keyFiles.filter { $0.role == role }.count }
        #expect(roles(.live) == 1)
        #expect(roles(.besideLibrary) == 1)
        #expect(roles(.setAside) == 1)
        #expect(roles(.snapshotPair) == 3)
        #expect(roles(.ownKeyFile) == 1)
        #expect(roles(.folderKeyFile) == 2)
        #expect(roles(.asideCopy) == 3)
        #expect(catalog.liveKeyFile?.heldFingerprints.count == 2, "the live file leads to its history too")
    }

    @Test func foreignNamesAreListedNeverCatalogued() throws {
        let (catalog, _) = try Self.world()
        let names = catalog.foreign.map(\.name)
        #expect(names.contains("variorum-backup-a1-2026-10-05-101010.sqlite"))
        #expect(names.contains("variorum-backup-seed-drill-1.sqlite"))
        #expect(catalog.foreign.contains { $0.folders == ["Backups", "zzzz"] })
        #expect(!names.contains("note.md"), "an export is hers, not foreign to a copy's place")
        #expect(!catalog.copies.contains { $0.name.contains("a1") || $0.name.contains("seed") })
    }

    /// Today's pair rules: a pair that disagrees with the name's fp8 is not
    /// offered; the folder's fingerprint file of that fp8 serves instead.
    @Test func aMismatchedPairIsNeverOfferedAsIfItOpened() throws {
        let key = StoreKey.mint(), other = StoreKey.mint()
        let when = CF.stamp(4)
        let catalog = Catalog.build([
            CatalogEntry(place: .container, folders: ["Backups"], name: CF.snapshotName(when, key)),
            CatalogEntry(place: .container, folders: ["Backups"], name: CF.pairName(when, key),
                         bytes: try CF.format2(library: CF.lib1, key: other)),
            CatalogEntry(place: .container, folders: ["Backups"], name: StoreKeyEnvelope.filename(forFingerprint: PF.fp(key)),
                         bytes: try CF.format2(library: CF.lib1, key: key)),
        ])
        let copy = try #require(catalog.copies.first)
        #expect(copy.servingKeyFiles == [Catalog.id(place: .container, folders: ["Backups"],
                                                    name: StoreKeyEnvelope.filename(forFingerprint: PF.fp(key)))])
        #expect(copy.fingerprint == PF.fp(key))
    }
}
