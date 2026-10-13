import CryptoKit
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-203 (RUN VX-201, U3) — the step-aside copies the Castle offer reaches
// (auditor B1d): the two homes an adoption writes, listed ONLY when the copy
// opens through the Apple account (the key file Variorum would open it with
// carries `apple` — F-U3-1), removed WHOLE, and the remover refusing every
// path that is not such a copy. The red-on-old reverts are
// `notes/plans/fixes/vx-201-u3-reverts/R-a…R-c` (the record's pin table).

@Suite("VX-203 — the step-aside copies the Castle offer reaches")
struct LibraryAsideCopiesTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-vx203-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// A key file beside `store`: the library key under a master copy (the
    /// Castle shape), plus the iCloud copy when `apple` (Standard), modified
    /// at `modified` — `locate`'s tiebreak.
    @discardableResult
    private func writeKeyFile(besideStore store: URL, apple: Bool, modified: Date) throws -> URL {
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope(storeID: "aside-\(UUID().uuidString.prefix(8))")
        try envelope.setMasterWrappedCopy(key: key, under: SymmetricKey(size: .bits256))
        if apple {
            try envelope.setAppleWrappedCopy(key: key, under: SymmetricKey(size: .bits256), appleKeyID: "apple-key")
        }
        let url = envelope.preferredURL(besideStore: store)
        try envelope.write(at: url)
        try FileManager.default.setAttributes([.modificationDate: modified], ofItemAtPath: url.path)
        return url
    }

    /// A crafted copy folder: an opaque store + the given key files.
    @discardableResult
    private func craftCopy(_ folder: URL, keyFiles: [(apple: Bool, modified: Date)]) throws -> URL {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let store = folder.appendingPathComponent("variorum.sqlite")
        try Data("sealed library bytes".utf8).write(to: store)
        for file in keyFiles {
            try writeKeyFile(besideStore: store, apple: file.apple, modified: file.modified)
        }
        return folder
    }

    private func snapshotOfFolder(_ folder: URL) throws -> [String: Data] {
        var out: [String: Data] = [:]
        let fm = FileManager.default
        guard fm.fileExists(atPath: folder.path) else { return out }
        for name in try fm.subpathsOfDirectory(atPath: folder.path) {
            let path = folder.appendingPathComponent(name).path
            var isDirectory: ObjCBool = false
            _ = fm.fileExists(atPath: path, isDirectory: &isDirectory)
            out[name] = isDirectory.boolValue ? Data("dir".utf8) : (fm.contents(atPath: path) ?? Data())
        }
        return out
    }

    private let older = Date(timeIntervalSince1970: 1_790_000_000)
    private let newer = Date(timeIntervalSince1970: 1_790_100_000)

    // MARK: - (a) the adoption's own two folders, listed and removed whole

    /// RED ON OLD (R-a — the lister reaches neither home; the pre-VX-203
    /// offer never looked past the snapshot pairs): a STANDARD-ERA library
    /// adopted away leaves its dated copy and its safety copy, each beside
    /// an `apple`-carrying key file — both listed (oldest stamp first, the
    /// dated copy before its safety twin), each removed whole; the adopted
    /// library and its key file are untouched.
    @Test func anAdoptedStandardEraLibrarysTwoCopiesAreListedAndEachGoesWhole() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        // The standing library — Standard-shaped: its key file carries the
        // iCloud copy beside the passphrase copy.
        let oldKey = StoreKey.mint()
        do {
            let database = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: oldKey))
            _ = database.asRebindable().binding.lock()
        }
        var oldEnvelope = StoreKeyEnvelope()
        try oldEnvelope.setPassphraseWrap(key: oldKey, passphrase: "old word", kdf: fastKDF())
        try oldEnvelope.setAppleWrappedCopy(key: oldKey, under: SymmetricKey(size: .bits256), appleKeyID: "apple-key")
        try oldEnvelope.write(at: oldEnvelope.preferredURL(besideStore: storeURL))
        // The arriving copy.
        let sourceStore = dir.appendingPathComponent("arrival/variorum.sqlite")
        let sourceKey = StoreKey.mint()
        do {
            let database = try AppDatabase.openStore(at: sourceStore, custody: .inMemory(initial: sourceKey))
            _ = database.asRebindable().binding.lock()
        }
        var sourceEnvelope = StoreKeyEnvelope()
        try sourceEnvelope.setPassphraseWrap(key: sourceKey, passphrase: "new word", kdf: fastKDF())
        let sourceKeyFile = sourceEnvelope.preferredURL(besideStore: sourceStore)
        try sourceEnvelope.write(at: sourceKeyFile)

        #expect(LibraryAdoption.appleOpenableAsideCopies(besideStore: storeURL).isEmpty, "nothing set aside yet")
        let plan = LibraryAdoption.plan(
            adopting: sourceStore, keyFile: sourceKeyFile,
            intoStoreAt: storeURL, now: Date(timeIntervalSince1970: 1_800_000_000))
        try LibraryAdoption.execute(plan)

        let listed = LibraryAdoption.appleOpenableAsideCopies(besideStore: storeURL)
        #expect(listed.map(\.path) == [plan.asideFolder.path, plan.safetyCopyFolder.path],
                "the dated copy and its safety twin — the adoption's own two folders")
        #expect(listed.allSatisfy { LibraryAdoption.isAppleOpenableAsideCopy($0, besideStore: storeURL) })
        let liveBefore = try Data(contentsOf: storeURL)
        let landedKeyFile = try #require(plan.landedKeyFile)
        let landedBefore = try Data(contentsOf: landedKeyFile)

        for folder in listed {
            try LibraryAdoption.removeAsideCopy(folder, besideStore: storeURL)
            #expect(!FileManager.default.fileExists(atPath: folder.path), "the whole stamp folder goes")
        }
        #expect(LibraryAdoption.appleOpenableAsideCopies(besideStore: storeURL).isEmpty)
        #expect(try Data(contentsOf: storeURL) == liveBefore, "the adopted library is untouched")
        #expect(try Data(contentsOf: landedKeyFile) == landedBefore, "its key file is untouched")
        #expect(FileManager.default.fileExists(
            atPath: LibraryAdoption.previousLibrariesHome(besideStore: storeURL).path),
                "the home stays — only the stamp folder goes")
    }

    // MARK: - (b) a Castle-era copy is never listed, and survives

    /// A Castle-era copy never opens through the Apple account, so it is
    /// never listed and the remover refuses it with nothing removed — the
    /// plain shape (no `apple` anywhere) and THE O.4 SHAPE (F-U3-1): the
    /// device that entered Castle kept its Standard-era key file (`apple`,
    /// older) beside the Castle one (newer) and an adoption moved both aside.
    /// RED ON OLD under R-b (any key file's `apple` qualifies): the O.4 copy
    /// is listed and removed.
    @Test func aCastleEraCopyIsNeverListedAndSurvivesTheRemover() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        let previous = LibraryAdoption.previousLibrariesHome(besideStore: storeURL)
        let safety = LibraryAdoption.safetyCopiesHome(besideStore: storeURL)
        let plainCastle = try craftCopy(
            previous.appendingPathComponent("2026-09-01-120000"), keyFiles: [(false, older)])
        let o4Castle = try craftCopy(
            previous.appendingPathComponent("2026-10-01-120000"), keyFiles: [(true, older), (false, newer)])
        let o4CastleSafety = try craftCopy(
            safety.appendingPathComponent("variorum-adopt-safety-2026-10-01-120000"),
            keyFiles: [(true, older), (false, newer)])
        // The control: the same two key files with the STANDARD one current
        // (a Castle library that left Castle carries `apple` on its live file).
        let standardNow = try craftCopy(
            previous.appendingPathComponent("2026-10-02-120000"), keyFiles: [(false, older), (true, newer)])

        #expect(LibraryAdoption.appleOpenableAsideCopies(besideStore: storeURL).map(\.path) == [standardNow.path],
                "only the copy whose CURRENT key file carries the iCloud copy")
        for castle in [plainCastle, o4Castle, o4CastleSafety] {
            let before = try snapshotOfFolder(castle)
            #expect(!LibraryAdoption.isAppleOpenableAsideCopy(castle, besideStore: storeURL))
            #expect(throws: LibraryAdoption.AsideCopyError.notAnAppleOpenableAsideCopy(castle.path)) {
                try LibraryAdoption.removeAsideCopy(castle, besideStore: storeURL)
            }
            #expect(try snapshotOfFolder(castle) == before, "\(castle.lastPathComponent) survives byte-identical")
        }
    }

    // MARK: - (c) only the adoption's naming, only its homes

    /// The A1 rail's own safety copies (`variorum-backup-a1-*`) and every
    /// other folder in the two homes are never the adoption's, even when the
    /// copy inside opens through the Apple account — never listed, the
    /// remover refuses, untouched. RED ON OLD under R-c (any folder in the
    /// homes qualifies by key file alone).
    @Test func onlyTheAdoptionsNamingInItsOwnHomeIsEverMatched() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        let previous = LibraryAdoption.previousLibrariesHome(besideStore: storeURL)
        let safety = LibraryAdoption.safetyCopiesHome(besideStore: storeURL)
        let standard: [(apple: Bool, modified: Date)] = [(true, older)]
        let foreign = [
            safety.appendingPathComponent("variorum-backup-a1-13ie-window-2026-10-04T035847Z"),  // her A1 rail
            safety.appendingPathComponent("2026-10-01-120000"),                                 // no prefix
            safety.appendingPathComponent("variorum-adopt-safety-latest"),                      // no stamp
            safety.appendingPathComponent("variorum-adopt-safety-2026-13-01-000000"),           // not a real stamp
            previous.appendingPathComponent("variorum-adopt-safety-2026-10-01-120000"),         // the wrong home
            previous.appendingPathComponent("My old library"),                                  // hers
            previous.appendingPathComponent("2026-10-01-1200"),                                 // a short stamp
            dir.appendingPathComponent("home/Backups/2026-10-01-120000"),                       // Backups itself
        ]
        for folder in foreign { try craftCopy(folder, keyFiles: standard) }
        // A loose library file directly in Previous Libraries, not a folder.
        try Data("loose".utf8).write(to: previous.appendingPathComponent("2026-10-03-120000"))
        // Two stores in one adoption-named folder (never guessed — the
        // classifier's folder rule).
        let twoStores = try craftCopy(previous.appendingPathComponent("2026-10-05-120000"), keyFiles: standard)
        try Data("second".utf8).write(to: twoStores.appendingPathComponent("other.sqlite"))
        let before = try snapshotOfFolder(dir)

        #expect(LibraryAdoption.appleOpenableAsideCopies(besideStore: storeURL).isEmpty)
        for folder in foreign + [twoStores, previous.appendingPathComponent("2026-10-03-120000")] {
            #expect(!LibraryAdoption.isAppleOpenableAsideCopy(folder, besideStore: storeURL), "\(folder.path)")
            #expect(throws: LibraryAdoption.AsideCopyError.self) {
                try LibraryAdoption.removeAsideCopy(folder, besideStore: storeURL)
            }
        }
        #expect(try snapshotOfFolder(dir) == before, "nothing anywhere was touched")
    }

    // MARK: - The remover's path guard

    /// Deletion is guarded to the two homes beside THIS store: the store's
    /// own folder, the homes themselves, a `..`-built path, another
    /// library's homes, a symlink planted as a stamp folder and a symlink
    /// planted as the home — each refused with nothing removed (the link's
    /// target, an Apple-openable copy elsewhere, survives too).
    @Test func theRemoverRefusesEveryPathThatIsNotACopyBesideThisStore() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("live".utf8).write(to: storeURL)
        let previous = LibraryAdoption.previousLibrariesHome(besideStore: storeURL)
        let real = try craftCopy(previous.appendingPathComponent("2026-10-01-120000"), keyFiles: [(true, older)])
        // Another library's own home, elsewhere on disk.
        let otherStore = dir.appendingPathComponent("elsewhere/variorum.sqlite")
        let otherCopy = try craftCopy(
            LibraryAdoption.previousLibrariesHome(besideStore: otherStore).appendingPathComponent("2026-10-01-120000"),
            keyFiles: [(true, older)])
        // A link planted as a stamp folder, pointing at an Apple-openable copy.
        let target = try craftCopy(dir.appendingPathComponent("target/2026-10-02-120000"), keyFiles: [(true, older)])
        let link = previous.appendingPathComponent("2026-10-02-120000")
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: target)
        let before = try snapshotOfFolder(dir)

        let refused = [
            storeURL.deletingLastPathComponent(),
            previous,
            LibraryAdoption.safetyCopiesHome(besideStore: storeURL),
            previous.appendingPathComponent("2026-10-01-120000/../.."),
            otherCopy,
            link,
        ]
        #expect(LibraryAdoption.appleOpenableAsideCopies(besideStore: storeURL).map(\.path) == [real.path],
                "the planted link is never listed")
        for path in refused {
            #expect(throws: LibraryAdoption.AsideCopyError.self) {
                try LibraryAdoption.removeAsideCopy(path, besideStore: storeURL)
            }
        }
        #expect(try snapshotOfFolder(dir) == before, "every refusal removed nothing")

        // A link planted as the HOME itself: nothing behind it qualifies.
        let otherHome = LibraryAdoption.previousLibrariesHome(besideStore: otherStore)
        let linkedStore = dir.appendingPathComponent("linked/variorum.sqlite")
        try FileManager.default.createDirectory(
            at: linkedStore.deletingLastPathComponent(), withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(
            at: LibraryAdoption.previousLibrariesHome(besideStore: linkedStore), withDestinationURL: otherHome)
        let throughLink = LibraryAdoption.previousLibrariesHome(besideStore: linkedStore)
            .appendingPathComponent("2026-10-01-120000")
        #expect(LibraryAdoption.appleOpenableAsideCopies(besideStore: linkedStore).isEmpty)
        #expect(throws: LibraryAdoption.AsideCopyError.self) {
            try LibraryAdoption.removeAsideCopy(throughLink, besideStore: linkedStore)
        }
        #expect(FileManager.default.fileExists(atPath: otherCopy.path), "the link's target survives")
    }

    // MARK: - (e) listing is a read

    /// Declining the offer leaves everything: the listing itself writes
    /// nothing, and the copy under the key the library now uses is never
    /// named (`keepingFingerprint`).
    @Test func listingWritesNothingAndNeverNamesTheCurrentKeysCopy() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        let previous = LibraryAdoption.previousLibrariesHome(besideStore: storeURL)
        let first = try craftCopy(previous.appendingPathComponent("2026-10-01-120000"), keyFiles: [(true, older)])
        let second = try craftCopy(previous.appendingPathComponent("2026-10-02-120000"), keyFiles: [(true, older)])
        let before = try snapshotOfFolder(dir)
        #expect(LibraryAdoption.appleOpenableAsideCopies(besideStore: storeURL).map(\.path) == [first.path, second.path])
        #expect(LibraryAdoption.appleOpenableAsideCopies(besideStore: storeURL).map(\.path) == [first.path, second.path])
        #expect(try snapshotOfFolder(dir) == before, "listing twice changed nothing")
        let secondKey = try #require(
            try StoreKeyEnvelope.loadCurrent(besideStore: second.appendingPathComponent("variorum.sqlite"))?.keyFingerprint)
        #expect(LibraryAdoption.appleOpenableAsideCopies(
            besideStore: storeURL, keepingFingerprint: StoreKeyEnvelope.shortFingerprint(secondKey)).map(\.path) == [first.path])
    }

    /// The hoist changed no path: the plan still spells both homes exactly
    /// as 13x wrote them.
    @Test func thePlanStillSpellsBothHomesAsTheAdoptionAlwaysHas() {
        let storeURL = URL(fileURLWithPath: "/tmp/vx203/home/variorum.sqlite")
        let plan = LibraryAdoption.plan(
            adopting: URL(fileURLWithPath: "/tmp/vx203/in/variorum.sqlite"), keyFile: nil,
            intoStoreAt: storeURL, now: Date(timeIntervalSince1970: 1_800_000_000))
        #expect(plan.asideFolder.path == "/tmp/vx203/home/Previous Libraries/2027-01-15-080000")
        #expect(plan.safetyCopyFolder.path
            == "/tmp/vx203/home/Backups/safety-copies/variorum-adopt-safety-2027-01-15-080000")
        #expect(LibraryAdoption.adoptionStamp("2027-01-15-080000") != nil)
        #expect(LibraryAdoption.adoptionStamp("2027-1-15-080000") == nil)
    }
}
