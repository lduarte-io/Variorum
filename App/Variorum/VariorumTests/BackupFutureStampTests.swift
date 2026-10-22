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
//  VX-329 U1 — THE RELEASE SWITCH: three of the five readers were today's
//  flat legs (the primary snapshot's due-check, the second folder's, the
//  Castle lock-time copy) and were deleted with them, their pins with them;
//  the pair road's due-check reads the rule through `OwnCopies` (the
//  catalogue's trusted stamps — pinned in the core). The weekly export's
//  check and the face's stale rule stand, pinned here.
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

    private func stamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: date)
    }

    private func pickSecondFolder(_ picked: URL, in defaults: UserDefaults) throws {
        let bookmark = try picked.bookmarkData(
            options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
        defaults.set(bookmark, forKey: BackupDestination.defaultsKey)
    }

    /// The real clock, to the second (the stamp's grain) — the face reads
    /// `Date()`, so its fixtures are placed around the real now.
    private var realNow: Date { Date(timeIntervalSince1970: floor(Date().timeIntervalSince1970)) }

    // MARK: - The due-checks (RED ON OLD: each check read the future copy as fresh)

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

    /// The row turns orange when the copies it can trust are old — whatever a future stamp says. VX-329 U1: the row's
    /// count, newest and oldest come from this Mac's pairs (`OwnCopies.Summary`, trusted stamps only — the core's); the
    /// face's own rule stands — a newest it cannot trust is no evidence of freshness.
    @Test func theFaceTurnsStaleWhenOnlyAFutureStampLooksFresh() throws {
        let now = realNow
        let future = DataSafetyModel.FolderSummary(
            displayPath: "Backups", exists: true, count: 2, newest: now.addingTimeInterval(3 * day),
            oldest: now.addingTimeInterval(-3 * day))
        #expect(future.isStale(after: DataSafetyPane.snapshotStaleAfter, now: now),
                "a newest stamped ahead of the clock is not freshness")
        let stale = DataSafetyModel.FolderSummary(
            displayPath: "Backups", exists: true, count: 1, newest: now.addingTimeInterval(-3 * day),
            oldest: now.addingTimeInterval(-3 * day))
        #expect(stale.isStale(after: DataSafetyPane.snapshotStaleAfter, now: now), "three days old is stale")
    }

    /// A row with no copy the face can trust says so in orange.
    @Test func aFolderHoldingOnlyAFutureCopyReadsStale() throws {
        let none = DataSafetyModel.FolderSummary(displayPath: "Backups", exists: true, count: 1, newest: nil, oldest: nil)
        #expect(none.isStale(after: DataSafetyPane.snapshotStaleAfter))
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

    /// An ordinary recent copy reads fresh.
    @Test func anOrdinaryRecentCopyStillReadsFresh() throws {
        let now = realNow
        let recent = DataSafetyModel.FolderSummary(
            displayPath: "Backups", exists: true, count: 1, newest: now.addingTimeInterval(-3_600),
            oldest: now.addingTimeInterval(-3_600))
        #expect(!recent.isStale(after: DataSafetyPane.snapshotStaleAfter, now: now))
    }
}
