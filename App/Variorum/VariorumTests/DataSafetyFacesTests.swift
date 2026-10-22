//
//  DataSafetyFacesTests.swift
//  VariorumTests
//
//  Phase 13l, Act 5 (ledger rows 16–18) — the three faces.
//
//  What these pin, in the order they matter:
//   · row 16 — the plain-text insurance actually writes prose (the whole
//     point: a SQLite-eating disaster still leaves words), on its own weekly
//     due-ness, pruned to its policy, and REPORTING when it could not;
//     plus the two traps this leg could have sprung on the persisted log —
//     a required field emptying her history, and a success reading as a
//     failed integrity check;
//   · row 17 — the words, at the state level: the signed-out line reads as
//     NORMAL, a backlog reads as waiting and never as loss, and the local
//     read answers from one transaction;
//   · row 18 — the check answers correctly, distinguishes "that isn't it"
//     from "we couldn't ask", and CHANGES NOTHING: no vault write, no
//     custody, byte-identical vault row afterwards.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

// MARK: - Row 16 — the plain-text insurance

@Suite("Plain-text insurance — the automated .md export (13l row 16)")
struct MarkdownInsuranceTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13l-act5-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func scratchDefaults() -> UserDefaults {
        UserDefaults(suiteName: "variorum-13l-act5-\(UUID().uuidString)")!
    }

    private func populatedDatabase() throws -> AppDatabase {
        let db = try AppDatabase.inMemory()
        try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1))
        } operation: {
            let ops = Operations()
            let post = try ops.createPost(title: "insurance", profile: .journal)
            _ = try ops.newBlock(in: post.id, text: "Prose that must survive SQLite itself.")
        }
        return db
    }

    private func day(_ index: Int) -> Date {
        Date(timeIntervalSince1970: Double(index) * 86_400)
    }

    @Test func anExportWritesHerProseAsPlainText() async throws {
        let source = try populatedDatabase()
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }

        let leg = await Task.detached {
            MarkdownInsurance.performExport(
                database: source, into: dir, now: day(20_000), force: false)
        }.value

        #expect(leg.outcome == .written)
        #expect((leg.files ?? 0) > 0, "an export with no files is not insurance")
        let folders = try MarkdownInsurance.existingExports(in: dir)
        #expect(folders.count == 1)
        // The point of the whole row: readable prose on disk, no Variorum
        // required. Walk the folder and find her sentence in a `.md` file.
        let written = try FileManager.default.subpathsOfDirectory(atPath: folders[0].path)
            .filter { $0.hasSuffix(".md") }
        #expect(!written.isEmpty, "the export folder holds .md files")
        let bodies = try written.map {
            try String(contentsOf: folders[0].appendingPathComponent($0), encoding: .utf8)
        }
        #expect(bodies.contains { $0.contains("Prose that must survive SQLite itself.") },
                "the words are in the plain text, not just the file count")
    }

    @Test func theCadenceIsWeeklyAndSaysSoWhenNothingIsDue() async throws {
        let source = try populatedDatabase()
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }

        let first = await Task.detached {
            MarkdownInsurance.performExport(
                database: source, into: dir, now: day(20_000), force: false)
        }.value
        #expect(first.outcome == .written)

        // Three days later: not due. A daily cadence here would rewrite the
        // whole library every day into a folder that may be cloud-synced.
        let soon = await Task.detached {
            MarkdownInsurance.performExport(
                database: source, into: dir, now: day(20_003), force: false)
        }.value
        #expect(soon.outcome == .upToDate)
        #expect(try MarkdownInsurance.existingExports(in: dir).count == 1)

        // Eight days later: due.
        let later = await Task.detached {
            MarkdownInsurance.performExport(
                database: source, into: dir, now: day(20_008), force: false)
        }.value
        #expect(later.outcome == .written)
        #expect(try MarkdownInsurance.existingExports(in: dir).count == 2)
    }

    @Test func retentionKeepsTheFourMostRecentExportsWhole() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        // Six dated folders, each with a file inside — pruning removes the
        // FOLDER, not its contents one by one.
        var names: [String] = []
        for index in 0..<6 {
            let stamp = "2026-08-0\(index + 1)-030000"
            names.append(stamp)
            let folder = dir.appendingPathComponent(stamp, isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try Data("x".utf8).write(to: folder.appendingPathComponent("note.md"))
        }
        let pruned = try MarkdownInsurance.prune(in: dir, keep: 4)
        #expect(pruned == 2)
        let survivors = try MarkdownInsurance.existingExports(in: dir)
            .map(\.lastPathComponent)
        #expect(survivors == Array(names.suffix(4)), "the four most recent, oldest gone")
    }

    @Test func aFolderThatIsNotAnExportIsLeftAlone() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        // Anything she put in the folder herself is not ours to count or to
        // prune — the listing is keyed on the stamp format, not on "every
        // directory here".
        try FileManager.default.createDirectory(
            at: dir.appendingPathComponent("my own notes", isDirectory: true),
            withIntermediateDirectories: true)
        #expect(try MarkdownInsurance.existingExports(in: dir).isEmpty)
        #expect(try MarkdownInsurance.prune(in: dir, keep: 0) == 0)
        #expect(FileManager.default.fileExists(
            atPath: dir.appendingPathComponent("my own notes").path))
    }

    @Test func noPickedFolderMeansNoExportAndTheRunSaysSo() async throws {
        let source = try populatedDatabase()
        let defaults = scratchDefaults()
        // 13p: the destination story sits behind the opt-in now (R13p-8's
        // rider — the flip's own tests live in Phase13pSubstrateTests).
        MarkdownInsurance.setEnabled(true, in: defaults)
        let leg = await Task.detached {
            MarkdownInsurance.performRun(
                database: source, defaults: defaults, now: Date(), force: true)
        }.value
        // `.noDestination`, never `.failed`: nothing is wrong — she simply
        // has not picked a folder, and the face says what turns this on.
        #expect(leg.outcome == .noDestination)
        #expect(leg.detail == nil)
    }

    @Test func anUnreachableFolderIsReportedNotSilentlySkipped() async throws {
        let source = try populatedDatabase()
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let defaults = scratchDefaults()
        // 13p: behind the opt-in, as above.
        MarkdownInsurance.setEnabled(true, in: defaults)
        let doomed = dir.appendingPathComponent("gone", isDirectory: true)
        try FileManager.default.createDirectory(at: doomed, withIntermediateDirectories: true)
        let bookmark = try doomed.bookmarkData(
            options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
        defaults.set(bookmark, forKey: BackupDestination.defaultsKey)
        try FileManager.default.removeItem(at: doomed)

        let leg = await Task.detached {
            MarkdownInsurance.performRun(
                database: source, defaults: defaults, now: Date(), force: true)
        }.value
        #expect(leg.outcome == .failed)
        #expect(leg.detail?.contains("Pick it again") == true,
                "the silent-stop failure is the one this phase exists to kill")
    }

    /// RED-ON-OLD, and the bug it guards is a data-loss-shaped one: the run
    /// record gained a third leg, and the log is PERSISTED across launches.
    /// A required `markdown` field would have made every record written
    /// before this build fail to decode — and `BackupLog.read` returns `[]`
    /// on a decode failure, so her entire backup history would have
    /// disappeared on this build's first launch, silently, from the one face
    /// whose job is to prove backups are happening.
    @Test func aLogRecordFromBeforeTheThirdLegStillDecodes() throws {
        let legacy = """
            [{"at":782900000,"primary":{"outcome":"written","integrity":"ok","pruned":0},\
            "secondary":{"outcome":"noDestination","pruned":0}}]
            """
        let defaults = scratchDefaults()
        defaults.set(Data(legacy.utf8), forKey: BackupLog.defaultsKey)
        let records = BackupLog.read(defaults)
        #expect(records.count == 1, "a pre-Act-5 record must still read")
        #expect(records.first?.markdown == nil)
        #expect(records.first?.everythingWorked == true,
                "a record with no markdown leg has nothing to have failed")
    }

    /// **THE SAME TRAP, ONE LEVEL UP — and the Optional field only covered
    /// the additive half of it** (13l, the end-of-phase ladder's LR-NIT-5).
    ///
    /// Traced: `JSONDecoder` fails an ARRAY if any single element fails, so
    /// ONE unreadable record emptied the whole persisted log. Act 5's fix made
    /// `markdown` Optional, which answers "a NEWER build reads an OLDER
    /// record". It does nothing for the mirror case: an older build reading a
    /// record a newer one wrote — here, an `Outcome` case that does not exist
    /// yet — which is one version rollback away and needs no code change at
    /// all to happen.
    ///
    /// **Red on old** (behavioural revert): decode `[BackupRunRecord]` in one
    /// shot again and this reads 0 of 3.
    @Test func oneUnreadableRecordLosesItselfAndNotTheHistory() throws {
        let defaults = scratchDefaults()
        let good = BackupRunRecord(
            at: Date(timeIntervalSince1970: 782_900_000),
            primary: .init(outcome: .written, file: "a.sqlite", integrity: "ok"),
            secondary: .init(outcome: .noDestination))
        for index in 0..<3 {
            BackupLog.append(
                BackupRunRecord(
                    at: Date(timeIntervalSince1970: 782_900_000 + Double(index)),
                    primary: .init(
                        outcome: .written, file: "f\(index).sqlite", integrity: "ok"),
                    secondary: good.secondary),
                to: defaults)
        }

        // A future build's run, as it would actually arrive: an outcome this
        // build has never heard of, written by a version she then rolled back
        // from. Mutated in the stored JSON, so the pin drives the real
        // persisted bytes rather than a hand-built string.
        var json = try JSONSerialization.jsonObject(
            with: defaults.data(forKey: BackupLog.defaultsKey)!) as! [[String: Any]]
        #expect(json.count == 3)
        var middle = json[1]
        var leg = middle["primary"] as! [String: Any]
        leg["outcome"] = "teleported"
        middle["primary"] = leg
        json[1] = middle
        defaults.set(
            try JSONSerialization.data(withJSONObject: json), forKey: BackupLog.defaultsKey)

        let records = BackupLog.read(defaults)
        #expect(records.count == 2, "the unreadable run lost itself, and only itself")
        #expect(records.map(\.primary.file) == ["f2.sqlite", "f0.sqlite"],
                "newest-first order survives the gap")
    }

    /// The second trap, and it is why the count has its own field: `Leg`'s
    /// `integrityFailed` reads "a value that is not SQLite's ok". Putting
    /// "42 files" in `integrity` would have made every successful export
    /// report as a failed check — orange in the face, `everythingWorked`
    /// false, on a run where everything worked.
    @Test func aSuccessfulExportNeverReadsAsAFailedIntegrityCheck() async throws {
        let source = try populatedDatabase()
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let leg = await Task.detached {
            MarkdownInsurance.performExport(
                database: source, into: dir, now: day(20_000), force: true)
        }.value
        #expect(leg.outcome == .written)
        #expect(leg.integrity == nil, "there is no pragma to run on a folder of markdown")
        #expect(leg.integrityFailed == false)

        let record = BackupRunRecord(
            at: Date(), primary: BackupRunRecord.Leg(outcome: .written, integrity: "ok"),
            secondary: BackupRunRecord.Leg(outcome: .noDestination), markdown: leg)
        #expect(record.everythingWorked)
    }

    @Test func aFailedExportLegMakesTheWholeRunReportItself() {
        var failed = BackupRunRecord.Leg(outcome: .failed)
        failed.detail = "the disk is full"
        let record = BackupRunRecord(
            at: Date(), primary: BackupRunRecord.Leg(outcome: .written, integrity: "ok"),
            secondary: BackupRunRecord.Leg(outcome: .noDestination), markdown: failed)
        #expect(!record.everythingWorked)
        #expect(DataSafetyModel.receipt(record).contains("the disk is full"))
    }

    @Test func anUpToDateExportSaysNothingInTheReceipt() {
        let record = BackupRunRecord(
            at: Date(), primary: BackupRunRecord.Leg(outcome: .upToDate),
            secondary: BackupRunRecord.Leg(outcome: .noDestination),
            markdown: BackupRunRecord.Leg(outcome: .upToDate))
        // A weekly job would otherwise add the same sentence to six receipts
        // out of seven, and a log line that always reads the same is a line
        // nobody reads.
        #expect(!DataSafetyModel.receipt(record).lowercased().contains("plain-text"))
    }
}

// MARK: - Row 17 — the sync-status face

@Suite("The sync-status face — read-side only (13l row 17)")
struct SyncSafetyFaceTests {
    private func facts(
        allowsSync: Bool = true, isConfigured: Bool = true, signedIn: Bool = true,
        pending: Int = 0, cursor: Int64? = 4_200, lastSuccessAt: Date? = Date()
    ) -> SyncSafetyFacts {
        SyncSafetyFacts(
            allowsSync: allowsSync, isConfigured: isConfigured, signedIn: signedIn,
            pending: pending, cursor: cursor, lastSuccessAt: lastSuccessAt)
    }

    /// The brief's own requirement, and the one that is easy to get wrong: a
    /// local-only Variorum is a COMPLETE Variorum, so its line reads as
    /// normal — never as an unfinished setup step or a failure.
    @Test func signedOutReadsAsNormalAndNeverAsBroken() {
        let face = SyncSafetyFace.face(
            facts(isConfigured: false, signedIn: false, cursor: nil, lastSuccessAt: nil))
        #expect(face.isCalm)
        #expect(face.headline == "Not syncing — this Mac keeps your library to itself.")
        #expect(face.details.contains(SyncSafetyFace.localOnlyReassurance))
        let whole = ([face.headline] + face.details).joined(separator: " ").lowercased()
        for alarm in ["error", "failed", "problem", "not set up", "warning"] {
            #expect(!whole.contains(alarm), "the signed-out line said “\(alarm)”")
        }
    }

    @Test func aDevStoreSessionSaysWhyItWillNeverSync() {
        let face = SyncSafetyFace.face(facts(allowsSync: false))
        #expect(face.isCalm)
        #expect(face.headline.contains("development store"),
                "the A4 fence is a fact about the build, not a fault")
    }

    @Test func anEmptyOutboxIsTheAnswerToDidMyWritingReachTheMirror() {
        let face = SyncSafetyFace.face(facts(pending: 0))
        #expect(face.isCalm)
        #expect(face.headline == "Everything written on this Mac has reached your account.")
    }

    @Test func aBacklogReadsAsWaitingAndNeverAsLoss() {
        let one = SyncSafetyFace.face(facts(pending: 1))
        #expect(one.headline == "1 change is still waiting to go up.")
        let many = SyncSafetyFace.face(facts(pending: 7))
        #expect(many.headline == "7 changes are still waiting to go up.")
        #expect(!many.isCalm, "a backlog is worth noticing…")
        #expect(many.details.contains(SyncSafetyFace.waitingReassurance),
                "…and offline is designed for: the outbox keeps everything")
    }

    /// The scheduler's stamp is IN MEMORY — it starts empty every launch. A
    /// face that showed a blank or an old time there would be lying about a
    /// system that is working fine.
    @Test func noRoundThisLaunchIsSaidOutLoud() {
        let face = SyncSafetyFace.face(facts(lastSuccessAt: nil))
        #expect(face.details.contains { $0.contains("since Variorum opened") })
    }

    @Test func aStoreThatHasNeverPulledSaysThatRatherThanShowingZero() {
        let never = SyncSafetyFace.face(facts(cursor: nil))
        #expect(never.details.contains { $0.contains("hasn't received anything") })
        let zero = SyncSafetyFace.face(facts(cursor: 0))
        #expect(zero.details.contains { $0.contains("hasn't received anything") },
                "cursor 0 is the same fact as no cursor")
        let some = SyncSafetyFace.face(facts(cursor: 4_200))
        #expect(some.details.contains { $0.contains("#4200") })
    }

    @Test func signedOutWithABacklogNamesTheBacklog() {
        let face = SyncSafetyFace.face(
            facts(isConfigured: false, signedIn: false, pending: 3))
        #expect(face.isCalm, "it is still not a fault — it is where she is")
        #expect(face.details.contains { $0.contains("3 changes") },
                "when nothing is going up, how much is only here matters most")
    }

    /// The SHARED half, pinned on its own: which of the five things is true
    /// is decided once, in `Shared/`, so the phone's twin renders the same
    /// story in its own nouns rather than re-deriving the rule. (The words
    /// above are the Mac's — the mobile no-redirect sweep is what taught
    /// this row where the seam goes.)
    @Test func theStandingIsTheSharedHalfAndTheWordsAreThePlatformS() {
        #expect(facts(allowsSync: false).standing == .devStore)
        #expect(facts(isConfigured: false, signedIn: false).standing == .localOnly)
        #expect(facts(isConfigured: false, signedIn: true).standing == .signedInNotSyncing)
        #expect(facts(pending: 0).standing == .allSent)
        #expect(facts(pending: 9).standing == .waiting(9))
        // Only a real backlog asks for attention; every other standing is
        // a normal state of a working app.
        #expect(SyncSafetyStanding.localOnly.isCalm)
        #expect(SyncSafetyStanding.signedInNotSyncing.isCalm)
        #expect(SyncSafetyStanding.devStore.isCalm)
        #expect(SyncSafetyStanding.allSent.isCalm)
        #expect(!SyncSafetyStanding.waiting(1).isCalm)
    }

    /// **THE THREE TONES** (the post-13l polish round, ledger row 31 — her
    /// words: *"a gentle green on fully synced might look nice"*).
    ///
    /// `isCalm` gives a two-way answer, and her ruling needs three: the
    /// settled state wants a gentle POSITIVE, a backlog wants attention, and
    /// **signed-out stays QUIET** — her #75(d) ratification, which a two-way
    /// answer cannot express, because "calm" would paint a signed-out Mac the
    /// same green as one that has sent everything, and being local-only is a
    /// complete state rather than an accomplishment. The decision is the
    /// standing's, shared with the phone; the pane renders a token from it.
    @Test func onlyTheSettledStateWearsTheGentlePositiveAndSignedOutStaysQuiet() {
        #expect(SyncSafetyStanding.allSent.tone == .settled)
        #expect(SyncSafetyStanding.waiting(3).tone == .attention)
        #expect(SyncSafetyStanding.localOnly.tone == .quiet)
        #expect(SyncSafetyStanding.signedInNotSyncing.tone == .quiet)
        #expect(SyncSafetyStanding.devStore.tone == .quiet)
        // The face CARRIES it — a view never re-derives the rule.
        #expect(SyncSafetyFace.face(facts(pending: 0)).tone == .settled)
        #expect(SyncSafetyFace.face(facts(pending: 4)).tone == .attention)
        #expect(SyncSafetyFace.face(
            facts(isConfigured: false, signedIn: false)).tone == .quiet)
        // …and `isCalm` still answers its own question beside it: a
        // signed-out Mac is calm AND quiet; a settled one is calm AND green.
        #expect(SyncSafetyFace.face(facts(pending: 0)).isCalm)
        #expect(SyncSafetyFace.face(
            facts(isConfigured: false, signedIn: false)).isCalm)
    }

    /// The local read: both facts, one transaction, straight from the store.
    /// Zero engine lines — this is the whole of row 17's contact with sync.
    @Test func theLocalReadAnswersFromTheStore() async throws {
        let db = try AppDatabase.inMemory()
        let fresh = try await db.read { try SyncSafetyFacts.read($0) }
        // NOT zero, and that is a fact worth knowing rather than a wrinkle
        // in the test: a brand-new store's `setting` seeds go through the
        // outbox triggers like every other write, so a never-synced install
        // genuinely does owe the server those rows. The face says so
        // honestly; the count here is therefore a DELTA.
        #expect(fresh.cursor == nil, "a store that has never pulled has no cursor")
        let baseline = fresh.pending

        try await db.write { db in
            try db.execute(sql: """
                INSERT INTO sync_outbox (table_name, row_id, queued_at)
                VALUES ('container', 'c-1', '2026-08-24T00:00:00.000Z'),
                       ('variant', 'v-1', '2026-08-24T00:00:00.000Z')
                """)
            try db.execute(sql: """
                INSERT OR REPLACE INTO sync_state (key, value)
                VALUES ('last_server_seq', '918')
                """)
        }
        let after = try await db.read { try SyncSafetyFacts.read($0) }
        #expect(after.pending == baseline + 2)
        #expect(after.cursor == 918)
    }
}

// (VX-329 U1: row 18's sanity check — `SecretCheckModel` over today's vault client and `EncryptionSession` — was today's
// road and was deleted with it, its suite with it.)
