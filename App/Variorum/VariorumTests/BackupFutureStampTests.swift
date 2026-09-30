//
//  BackupFutureStampTests.swift
//  VariorumTests
//
//  18o U1 — KnownIssues row 84 (18k C7's NOTICED 1): **a backup copy stamped
//  in the FUTURE silently stops the automatic backups, and the freshness face
//  never turns stale.**
//
//  The mechanism, traced at the code: every due-check in the backup run asks
//  `now.timeIntervalSince(newest) < interval` of the newest of the app's own
//  copies — the primary leg (`StoreBackup.performPrimaryLeg`), the second
//  folder's leg (`performSecondLeg`), the Castle lock-time copy
//  (`performLockTimeCopyIfDue`) and the weekly plain-text export
//  (`MarkdownInsurance.performExport`). A copy stamped ahead of the clock (a
//  clock that once ran fast) makes that difference NEGATIVE, so every check
//  reads "fresh" until the clock passes the stamp plus a whole interval — no
//  copy is made, and nothing says so. The face's `isStale(after:)` asks
//  `Date().timeIntervalSince(newest) > interval` of the same newest, so it is
//  negative too and the row never turns orange.
//
//  One rule answers all five readers: **a stamp later than now is not
//  evidence of freshness** — the checks and the face read the newest copy
//  stamped NO LATER than now. The future-stamped copy itself stays (it is a
//  real snapshot with a wrong date; never the app's to delete early), and it
//  keeps the one retention slot its date gives it.
//
//  The fixtures below are the 18k C7 `BackupOwnFilesTests` form (a keyed
//  on-disk store, scratch defaults, a picked second folder by bookmark, the
//  app's own names written by the writer's format); those pins ride
//  UNMODIFIED — this suite lives in its own file.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("A future-stamped backup copy (18o U1 — KnownIssues row 84)")
struct BackupFutureStampTests {
    /// 2026-09-25 12:00:00 UTC — the act's clock (C7's).
    private let noon = ISO8601DateFormatter().date(from: "2026-09-25T12:00:00Z")!
    private let day: TimeInterval = 86_400

    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-18o-u1-r84-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// Never `.standard` (the dev store's own domain while the suite runs).
    private func scratchDefaults() -> @Sendable () -> UserDefaults {
        let suite = "variorum-18o-u1-r84-\(UUID().uuidString)"
        return { UserDefaults(suiteName: suite)! }
    }

    private func keyedStore(in dir: URL) throws -> AppDatabase {
        let db = try AppDatabase.onDisk(
            url: dir.appendingPathComponent("store.sqlite"), key: StoreKey.mint())
        try withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1))
        } operation: {
            let ops = Operations()
            let post = try ops.createPost(title: "a day's words", profile: .journal)
            _ = try ops.newBlock(in: post.id, text: "Words the snapshot must hold.")
        }
        return db
    }

    /// The app's own snapshot name for `date` (the writer's format, UTC).
    private func ownName(_ date: Date, fingerprint: String? = nil) -> String {
        "\(StoreBackup.filePrefix)\(stamp(date))"
            + (fingerprint.map { "-" + StoreKeyEnvelope.shortFingerprint($0) } ?? "")
            + ".\(StoreBackup.fileExtension)"
    }

    private func stamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: date)
    }

    /// A stand-in copy under the app's own name — the due-checks and the face
    /// read NAMES (the stamp), never the bytes.
    private func placeOwnCopy(at date: Date, in dir: URL, fingerprint: String? = nil) throws -> String {
        let name = ownName(date, fingerprint: fingerprint)
        try Data("a copy".utf8).write(to: dir.appendingPathComponent(name))
        return name
    }

    private func pickSecondFolder(_ picked: URL, in defaults: UserDefaults) throws {
        let bookmark = try picked.bookmarkData(
            options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
        defaults.set(bookmark, forKey: BackupDestination.defaultsKey)
    }

    private func sqliteNames(in dir: URL) -> [String] {
        ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
            .filter { $0.hasSuffix(".sqlite") }
            .sorted()
    }

    private func run(
        _ source: AppDatabase, _ dir: URL, _ defaults: @escaping @Sendable () -> UserDefaults,
        at stamp: Date, force: Bool
    ) async -> BackupRunRecord {
        await Task.detached {
            StoreBackup.performRun(
                database: source, directory: dir, configuration: .init(),
                defaults: defaults(), now: stamp, force: force)
        }.value
    }

    /// The real clock, to the second (the stamp's grain) — the face reads
    /// `Date()`, so its fixtures are placed around the real now.
    private var realNow: Date { Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970)) }

    // MARK: - The due-checks (RED ON OLD: each check read the future copy as fresh)

    /// THE PRIMARY LEG: a copy stamped three days ahead no longer holds the
    /// daily snapshot off — and the check does not then write at every hour
    /// either (the future copy is not what it asks about).
    @Test func aFutureStampedCopyNeverStopsTheAutomaticSnapshot() async throws {
        let storeDir = try temporaryDirectory()
        let backups = try temporaryDirectory()
        defer { for d in [storeDir, backups] { try? FileManager.default.removeItem(at: d) } }
        let source = try keyedStore(in: storeDir)
        let defaults = scratchDefaults()
        let old = try placeOwnCopy(at: noon.addingTimeInterval(-2 * day), in: backups)
        let ahead = try placeOwnCopy(at: noon.addingTimeInterval(3 * day), in: backups)

        let record = await run(source, backups, defaults, at: noon, force: false)
        #expect(record.primary.outcome == .written,
                "the check read \(record.primary.outcome) (\(record.primary.file ?? "-")) — a future stamp held it off")
        let act = record.primary.file ?? "-"
        #expect(sqliteNames(in: backups) == [old, act, ahead].sorted(),
                "the folder holds \(sqliteNames(in: backups))")

        // An hour later the act's own copy is the fresh one: nothing is written.
        let later = await run(source, backups, defaults, at: noon.addingTimeInterval(3_600), force: false)
        #expect(later.primary.outcome == .upToDate,
                "an hour-old copy is fresh; the check \(later.primary.outcome)")
        #expect(sqliteNames(in: backups).count == 3)
    }

    /// THE SECOND FOLDER'S LEG: its own due-check is the far folder's — a
    /// future-stamped copy there no longer stops the copy there.
    @Test func aFutureStampedCopyInTheSecondFolderNeverStopsItsCopy() async throws {
        let storeDir = try temporaryDirectory()
        let backups = try temporaryDirectory()
        let picked = try temporaryDirectory()
        defer { for d in [storeDir, backups, picked] { try? FileManager.default.removeItem(at: d) } }
        let source = try keyedStore(in: storeDir)
        let defaults = scratchDefaults()
        // Beside the library: an hour-old real snapshot (the primary is fresh).
        let anHourAgo = noon.addingTimeInterval(-3_600)
        let fresh = try #require(try await Task.detached {
            try StoreBackup.performBackupIfDue(
                database: source, directory: backups, configuration: .init(),
                now: anHourAgo, force: true)
        }.value)
        try pickSecondFolder(picked, in: defaults())
        let far = BackupDestination.backupsFolder(in: picked)
        try FileManager.default.createDirectory(at: far, withIntermediateDirectories: true)
        let ahead = try placeOwnCopy(at: noon.addingTimeInterval(3 * day), in: far)

        let record = await run(source, backups, defaults, at: noon, force: false)
        #expect(record.primary.outcome == .upToDate)
        #expect(record.secondary.outcome == .written,
                "the far leg read \(record.secondary.outcome) — a future stamp held it off")
        #expect(sqliteNames(in: far) == [fresh.lastPathComponent, ahead].sorted(),
                "the far folder holds \(sqliteNames(in: far))")
    }

    /// THE CASTLE LOCK-TIME COPY (SnapshotPairTests' world): a future-stamped
    /// copy beside the library no longer stops the keyless copy at lock.
    @Test func aFutureStampedCopyNeverStopsTheLockTimeCopy() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let backups = dir.appendingPathComponent("library/Backups", isDirectory: true)
        let defaults = UserDefaults(suiteName: "variorum-18o-u1-r84-lock-\(UUID().uuidString)")!
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
        try await database.write { db in
            try db.execute(
                sql: "INSERT OR REPLACE INTO setting (key, value) VALUES (?, ?)",
                arguments: ["lock_probe", "a row to copy"])
        }
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(
            key: key, passphrase: "word",
            kdf: PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32))
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))
        database.asRebindable().binding.lock()

        let now = Date(timeIntervalSince1970: 1_800_000_000)
        try FileManager.default.createDirectory(at: backups, withIntermediateDirectories: true)
        let ahead = try placeOwnCopy(at: now.addingTimeInterval(3 * day), in: backups)

        let copy = StoreBackup.performLockTimeCopyIfDue(
            storeURL: storeURL, directory: backups, interval: day, defaults: defaults, now: now)
        #expect(copy != nil, "a future stamp held the lock-time copy off")
        #expect(sqliteNames(in: backups).contains(ahead), "the future copy itself stays")
    }

    /// THE WEEKLY PLAIN-TEXT EXPORT: the same clock, one cadence up.
    @Test func aFutureDatedExportNeverStopsTheWeeklyExport() async throws {
        let source = try AppDatabase.inMemory()
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let now = Date(timeIntervalSince1970: 20_000 * day)
        let aheadFolder = dir.appendingPathComponent(stamp(now.addingTimeInterval(10 * day)))
        try FileManager.default.createDirectory(at: aheadFolder, withIntermediateDirectories: true)

        let leg = await Task.detached {
            MarkdownInsurance.performExport(database: source, into: dir, now: now, force: false)
        }.value
        #expect(leg.outcome == .written, "the export read \(leg.outcome) — a future folder held it off")
        #expect(try MarkdownInsurance.existingExports(in: dir).count == 2)
    }

    // MARK: - The face (RED ON OLD: a future newest never read stale)

    /// The row turns orange when the copies it can trust are old — whatever a
    /// future stamp says — and reads its newest and its reach from them; the
    /// future copy is still COUNTED (it is a real file).
    @Test func theFaceTurnsStaleWhenOnlyAFutureStampLooksFresh() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let now = realNow
        let stale = now.addingTimeInterval(-3 * day)
        _ = try placeOwnCopy(at: stale, in: dir)
        _ = try placeOwnCopy(at: now.addingTimeInterval(3 * day), in: dir)

        let summary = DataSafetyModel.summarize(dir)
        #expect(summary.count == 2, "the future copy is still counted")
        #expect(summary.newest == stale, "newest read \(String(describing: summary.newest))")
        #expect(summary.oldest == stale)
        let orange = summary.isStale(after: DataSafetyPane.snapshotStaleAfter)
        #expect(orange, "three days without a trustworthy copy is stale")
    }

    /// A folder whose ONLY copy is stamped ahead has no copy the face can
    /// trust: it says so in orange, and names no future date as the newest.
    @Test func aFolderHoldingOnlyAFutureCopyReadsStale() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        _ = try placeOwnCopy(at: realNow.addingTimeInterval(3 * day), in: dir)

        let summary = DataSafetyModel.summarize(dir)
        #expect(summary.count == 1)
        #expect(summary.newest == nil, "newest read \(String(describing: summary.newest))")
        let orange = summary.isStale(after: DataSafetyPane.snapshotStaleAfter)
        #expect(orange)
    }

    /// The exports row, the same rule one cadence up (nine days).
    @Test func theExportsRowTurnsStaleWhenOnlyAFutureFolderLooksFresh() throws {
        let picked = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: picked) }
        let defaults = scratchDefaults()()
        try pickSecondFolder(picked, in: defaults)
        let exports = MarkdownInsurance.exportsFolder(in: picked)
        let stale = realNow.addingTimeInterval(-10 * day)
        for date in [stale, realNow.addingTimeInterval(3 * day)] {
            try FileManager.default.createDirectory(
                at: exports.appendingPathComponent(stamp(date)), withIntermediateDirectories: true)
        }

        let summary = try #require(DataSafetyModel.summarizeExports(in: defaults))
        #expect(summary.count == 2)
        #expect(summary.newest == stale, "newest read \(String(describing: summary.newest))")
        let orange = summary.isStale(after: DataSafetyPane.exportStaleAfter)
        #expect(orange)
    }

    // MARK: - Guard (green on both trees)

    /// An ordinary past copy reads exactly as before: fresh when it is, and
    /// the face's newest is its date.
    @Test func anOrdinaryRecentCopyStillReadsFresh() async throws {
        let storeDir = try temporaryDirectory()
        let backups = try temporaryDirectory()
        defer { for d in [storeDir, backups] { try? FileManager.default.removeItem(at: d) } }
        let source = try keyedStore(in: storeDir)
        _ = try placeOwnCopy(at: noon.addingTimeInterval(-3_600), in: backups)
        let record = await run(source, backups, scratchDefaults(), at: noon, force: false)
        #expect(record.primary.outcome == .upToDate)

        let face = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: face) }
        let recent = realNow.addingTimeInterval(-3_600)
        _ = try placeOwnCopy(at: recent, in: face)
        let summary = DataSafetyModel.summarize(face)
        #expect(summary.newest == recent)
        let orange = summary.isStale(after: DataSafetyPane.snapshotStaleAfter)
        #expect(!orange)
    }
}
