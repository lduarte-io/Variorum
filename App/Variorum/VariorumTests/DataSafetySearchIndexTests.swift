//
//  DataSafetySearchIndexTests.swift
//  VariorumTests
//
//  VX-79 (the VX-980 run, batch 2) — Settings ▸ Data Safety's search-index row: R-13o-3's "explicit rebuild door",
//  its face. A FEATURE: these pins state the NEW contract (no red-on-old leg is owed). What they hold:
//
//   · Check says what it found — in step in one calm sentence, or out of step with the honest numbers and the road;
//   · Rebuild says the state it LEAVES (what `rebuildSearchIndex()` answers), never a bare "done", and heals for real
//     through the very doors the pane composes over the session's runner;
//   · a failure speaks the system's reason as a refusal (the alarm voice);
//   · one flight per press — while one act runs the row says so and BOTH doors start nothing;
//   · the pane's standing-state rule — the row draws only in the pane's wired arm, with its doors composed;
//   · nothing runs by itself — the pane's refresh calls neither door, the doors are declared `.surface` only (no ⌘K
//     row, no menu item), and no production file but the pane composes the core doors;
//   · the Settings search finds the row ("search", "index", "rebuild") without taking another row's first finding.
//
//  Every rendered string is PROVISIONAL (R-980-4) and listed in the run record; the exact-string pins hold today's
//  words so a re-voice is a deliberate edit.
//

import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore
@testable import Variorum

/// A door that holds its flight until the test opens it, counting every flight that reached it.
private actor HeldDoor {
    private(set) var flights: [DataSafetyModel.SearchIndexAct] = []
    private var waiters: [CheckedContinuation<Void, Never>] = []
    private var open = false

    func enter(_ act: DataSafetyModel.SearchIndexAct) async {
        flights.append(act)
        guard !open else { return }
        await withCheckedContinuation { waiters.append($0) }
    }

    func release() {
        open = true
        for waiter in waiters { waiter.resume() }
        waiters.removeAll()
    }
}

@MainActor
@Suite("VX-79 — Settings ▸ Data Safety's search-index row: honest receipts, one flight, nothing automatic")
struct DataSafetySearchIndexTests {
    // MARK: - The world

    nonisolated private static func healthy(_ docs: Int) -> SearchIndexIntegrity {
        SearchIndexIntegrity(docCount: docs, missing: [], orphaned: [], factDrift: [], indexMatchesContent: true)
    }

    nonisolated private static func keys(_ count: Int, _ kind: String) -> [SearchDocKey] {
        (0..<count).map { SearchDocKey(kind: kind, srcID: "\(kind)-\($0)") }
    }

    /// A backup scheduler, so the model stands in the pane's WIRED arm (`isWired` — the pane's own gate).
    private static func backup() throws -> StoreBackup {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("vx79-row-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let suite = "vx79-row-\(UUID().uuidString)"
        return StoreBackup(
            database: try AppDatabase.inMemory(), directory: dir, configuration: .init(),
            defaults: { UserDefaults(suiteName: suite)! }, now: { Date() })
    }

    private static func model(
        check: @escaping @Sendable () async throws -> SearchIndexIntegrity = { healthy(1) },
        rebuild: @escaping @Sendable () async throws -> SearchIndexIntegrity = { healthy(1) }
    ) throws -> DataSafetyModel {
        let suite = "vx79-row-defaults-\(UUID().uuidString)"
        return DataSafetyModel(
            backup: try backup(), defaults: { UserDefaults(suiteName: suite)! },
            searchIndexDoors: .init(check: check, rebuild: rebuild))
    }

    private static func line(_ model: DataSafetyModel) -> (text: String, alarm: Bool)? {
        DataSafetyModel.searchIndexLine(model.searchIndex)
    }

    // MARK: - Check

    @Test func aCheckInStepSaysSoInOneCalmSentence() async throws {
        let model = try Self.model(check: { Self.healthy(12) })
        #expect(Self.line(model) == nil, "nothing is said before she presses")
        await model.checkSearchIndex()
        #expect(model.searchIndex == .found(.check, Self.healthy(12)))
        let said = try #require(Self.line(model))
        #expect(said.text == "The search index is in step with your notes \u{2014} 12 entries.")
        #expect(!said.alarm, "a healthy index is a calm line")
        #expect(DataSafetyCopy.searchIndexReceipt(rebuilt: false, Self.healthy(1))
                    == "The search index is in step with your notes \u{2014} 1 entry.", "one entry, singular")
    }

    @Test func aCheckOutOfStepSaysTheHonestNumbersAndTheRoad() async throws {
        let found = SearchIndexIntegrity(
            docCount: 40, missing: Self.keys(2, "take"), orphaned: Self.keys(1, "title"), factDrift: Self.keys(3, "book"),
            indexMatchesContent: false)
        let model = try Self.model(check: { found })
        await model.checkSearchIndex()
        let said = try #require(Self.line(model))
        #expect(said.text == "The search index is out of step with your notes: 2 pieces of writing are missing from it, "
                    + "1 entry points at writing that is gone, 3 entries have out-of-date details and the words it "
                    + "holds differ from your notes. Rebuild it to fix that.")
        #expect(said.alarm, "out of step wears the alarm voice")
        // Each number alone, singular and plural, and only what was found.
        let one = SearchIndexIntegrity(
            docCount: 9, missing: Self.keys(1, "comment"), orphaned: [], factDrift: [], indexMatchesContent: true)
        #expect(DataSafetyCopy.searchIndexReceipt(rebuilt: false, one)
                    == "The search index is out of step with your notes: 1 piece of writing is missing from it. "
                    + "Rebuild it to fix that.")
        let wordsOnly = SearchIndexIntegrity(
            docCount: 9, missing: [], orphaned: [], factDrift: [], indexMatchesContent: false)
        #expect(DataSafetyCopy.searchIndexDrift(wordsOnly) == "the words it holds differ from your notes")
        let two = SearchIndexIntegrity(
            docCount: 9, missing: [], orphaned: Self.keys(2, "take"), factDrift: Self.keys(1, "take"),
            indexMatchesContent: true)
        #expect(DataSafetyCopy.searchIndexDrift(two)
                    == "2 entries point at writing that is gone and 1 entry has out-of-date details")
    }

    // MARK: - Rebuild

    @Test func aRebuildSaysTheStateItLeavesNeverABareDone() async throws {
        let model = try Self.model(rebuild: { Self.healthy(40) })
        await model.rebuildSearchIndex()
        #expect(model.searchIndex == .found(.rebuild, Self.healthy(40)))
        let said = try #require(Self.line(model))
        #expect(said.text == "Rebuilt from your notes. The search index is in step with them \u{2014} 40 entries.")
        #expect(!said.alarm)
        #expect(!said.text.lowercased().contains("done"), "never a bare done — the state it leaves")
        // A rebuild that leaves the index out of step says THAT, with its numbers.
        let still = SearchIndexIntegrity(
            docCount: 40, missing: Self.keys(1, "take"), orphaned: [], factDrift: [], indexMatchesContent: true)
        #expect(DataSafetyCopy.searchIndexReceipt(rebuilt: true, still)
                    == "Rebuilt from your notes, but the search index is still out of step with them: 1 piece of "
                    + "writing is missing from it. Your notes themselves are untouched.")
        #expect(DataSafetyModel.searchIndexLine(.found(.rebuild, still))?.alarm == true)
    }

    /// The REAL doors, composed exactly as the pane composes them (`DataSafetyPane.searchIndexDoors(runner:)` over an
    /// `OperationsRunner`): over a library whose index lost a kind of entry, Check says so with the number, Rebuild
    /// heals it and says the state it leaves, and a Check after it agrees.
    @Test func thePanesDoorsCheckAndHealARealLibrary() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let ops = Operations()
            let post = try ops.createPost(title: "The lighthouse ledger")
            let minted = try ops.newBlock(in: post.id, text: "The keeper climbs the stair.", registeringUndo: false)
            _ = try ops.addBlockComment(to: minted.block.id, text: "check the tide tables")
            try await db.write { try $0.execute(sql: "DELETE FROM search_doc WHERE kind = 'comment'") }

            let suite = "vx79-row-real-\(UUID().uuidString)"
            let model = DataSafetyModel(
                backup: try Self.backup(), defaults: { UserDefaults(suiteName: suite)! },
                searchIndexDoors: DataSafetyPane.searchIndexDoors(runner: OperationsRunner(operations: ops)))
            #expect(model.drawsSearchIndexRow)

            await model.checkSearchIndex()
            guard case .found(.check, let found) = model.searchIndex else {
                Issue.record("the check answered \(model.searchIndex)")
                return
            }
            #expect(!found.isHealthy && found.missing.count == 1, "the lost comment entry is found missing")
            #expect(Self.line(model)?.text.contains("1 piece of writing is missing from it") == true)

            await model.rebuildSearchIndex()
            guard case .found(.rebuild, let left) = model.searchIndex else {
                Issue.record("the rebuild answered \(model.searchIndex)")
                return
            }
            #expect(left.isHealthy && left.docCount == 3, "healed: the title, the take, the comment")
            #expect(Self.line(model)?.text
                        == "Rebuilt from your notes. The search index is in step with them \u{2014} 3 entries.")
            await model.checkSearchIndex()
            #expect(model.searchIndex == .found(.check, left), "a check after it finds what the rebuild said")
        }
    }

    // MARK: - A failure speaks

    @Test func aFailureSpeaksTheSystemsReasonAsARefusal() async throws {
        let full = DatabaseError(resultCode: .SQLITE_FULL, message: "database or disk is full", sql: "INSERT INTO …")
        let model = try Self.model(rebuild: { throw full })
        await model.rebuildSearchIndex()
        #expect(model.searchIndex == .refused(.rebuild, reason: "database or disk is full"),
                "SQLite's own message — never the statement")
        let said = try #require(Self.line(model))
        #expect(said.text == "Couldn't rebuild the search index: database or disk is full. Nothing was changed.")
        #expect(said.alarm, "a refusal wears the alarm voice")

        let other = NSError(domain: "vx79", code: 1, userInfo: [NSLocalizedDescriptionKey: "The disk went away."])
        let checking = try Self.model(check: { throw other })
        await checking.checkSearchIndex()
        #expect(Self.line(checking)?.text == "Couldn't check the search index: The disk went away.",
                "the system's reason, its own full stop folded into the sentence's")
        #expect(!checking.searchIndexWorking, "the row lets go after a refusal")
    }

    // MARK: - One flight per press

    @Test func onePressIsOneFlightAndBothDoorsWait() async throws {
        let door = HeldDoor()
        let model = try Self.model(
            check: { await door.enter(.check); return Self.healthy(5) },
            rebuild: { await door.enter(.rebuild); return Self.healthy(5) })
        let first = Task { await model.checkSearchIndex() }
        var spins = 0
        while await door.flights.isEmpty, spins < 10_000 {
            spins += 1
            await Task.yield()
        }
        #expect(model.searchIndexWorking && model.searchIndex == .working(.check), "the row says it is working")
        #expect(Self.line(model)?.text == DataSafetyCopy.searchIndexChecking)
        #expect(Self.line(model)?.alarm == false)

        // A second press of either door while the first flies starts nothing.
        await model.checkSearchIndex()
        await model.rebuildSearchIndex()
        #expect(await door.flights == [.check], "one flight for three presses")

        await door.release()
        await first.value
        #expect(model.searchIndex == .found(.check, Self.healthy(5)))
        #expect(!model.searchIndexWorking, "and the doors are free again")
        await model.rebuildSearchIndex()
        #expect(await door.flights == [.check, .rebuild], "the next press is its own flight")
        #expect(DataSafetyModel.searchIndexLine(.working(.rebuild))?.text == DataSafetyCopy.searchIndexRebuilding)
    }

    // MARK: - The pane's standing-state rule, and nothing automatic

    @Test func theRowDrawsOnlyInThePanesWiredArmWithItsDoors() throws {
        let doors = DataSafetyModel.SearchIndexDoors(check: { Self.healthy(1) }, rebuild: { Self.healthy(1) })
        #expect(DataSafetyModel(backup: try Self.backup(), searchIndexDoors: doors).drawsSearchIndexRow,
                "wired, with doors: the row draws")
        #expect(!DataSafetyModel(backup: nil, searchIndexDoors: doors).drawsSearchIndexRow,
                "the unwired pane (\u{201C}Open the main window\u{201D}) draws no row — the pane's own precedent")
        #expect(!DataSafetyModel(backup: try Self.backup()).drawsSearchIndexRow, "no library's doors: no row")
    }

    @Test func nothingRunsUntilShePresses() async throws {
        let door = HeldDoor()
        await door.release()
        let model = try Self.model(
            check: { await door.enter(.check); return Self.healthy(1) },
            rebuild: { await door.enter(.rebuild); return Self.healthy(1) })
        await model.refresh()
        await model.refresh()
        #expect(await door.flights.isEmpty, "the pane's refresh never runs either door")
        #expect(model.searchIndex == .quiet && Self.line(model) == nil)
    }

    @Test func theDoorsAreDeclaredOnTheRowAloneNeverAPaletteOrMenuDoor() throws {
        for (id, verb) in [(CapabilityID.checkSearchIndex, DataSafetyCopy.searchIndexCheckDoor),
                           (.rebuildSearchIndex, DataSafetyCopy.searchIndexRebuildDoor)] {
            let capability = CapabilityRegistry.capability(id)
            #expect(capability.doors == [.surface], "\(id): the row's own door only — no ⌘K row, no menu item")
            #expect(capability.verb == verb, "\(id): the verb's one home is the row's words")
            #expect(DataSafetyPane.surfaceCapabilities.contains(id), "\(id): rendered by the pane that declares it")
        }
        // No production file but the pane composes the core doors, and nothing names the two acts but the
        // registry and the pane — so no launch, open, timer or palette road can reach them.
        let appRoot = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let repoRoot = appRoot.deletingLastPathComponent().deletingLastPathComponent()
        // A call into the core door (`$0.verifySearchIndex(`, `ops.rebuildSearchIndex(` — never the row's own
        // `model.…SearchIndex()`), and a reference to the declared ACT (`.checkSearchIndex` as an id — never a call).
        let callsTheCore = try NSRegularExpression(pattern: #"(?<!model)\.(?:verify|rebuild)SearchIndex\("#)
        let namesTheAct = try NSRegularExpression(pattern: #"(?<![A-Za-z0-9_])\.(?:check|rebuild)SearchIndex\b(?!\()"#)
        func hits(_ pattern: NSRegularExpression, _ source: String) -> Bool {
            pattern.firstMatch(in: source, range: NSRange(source.startIndex..., in: source)) != nil
        }
        var composers: Set<String> = []
        var namers: Set<String> = []
        for root in [appRoot.appendingPathComponent("Variorum"), appRoot.appendingPathComponent("Shared"),
                     appRoot.appendingPathComponent("VariorumMobile"), repoRoot.appendingPathComponent("Sources/VariorumMCP")] {
            guard let walker = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil) else { continue }
            for case let file as URL in walker where file.pathExtension == "swift" {
                let source = try String(contentsOf: file, encoding: .utf8)
                if hits(callsTheCore, source) { composers.insert(file.lastPathComponent) }
                if hits(namesTheAct, source) { namers.insert(file.lastPathComponent) }
            }
        }
        #expect(composers == ["DataSafetyPane.swift"], "the core doors are composed by the pane alone: \(composers)")
        #expect(namers == ["CapabilityRegistry.swift", "DataSafetyPane.swift"],
                "the two acts are named by the registry and the pane alone: \(namers)")
    }
}

/// The Settings search finds the row by her words, and takes no other row's first finding.
@MainActor
@Suite("VX-79 — the Settings search finds the search-index row")
struct DataSafetySearchIndexSettingsSearchTests {
    private func findings(_ query: String) -> [SettingsFinding] {
        SettingsSearch.findings(matching: query, in: SettingsSearch.wholeIndex)
    }

    @Test func theRowIsTheSectionAndTheSearchFindsIt() throws {
        let row = try #require(SettingsCatalog.rows.first { $0.id == "searchIndex" })
        #expect(row.pane == .dataSafety && row.title == DataSafetyCopy.searchIndexSection,
                "its title IS the section's — one text")
        #expect(AppSettingsView.rowIDsRendered[.dataSafety] == ["backups", "searchIndex"], "the pane renders it")
        #expect(findings("search index").first == SettingsFinding(
            kind: .setting, pane: .dataSafety, lead: "Search index", detail: row.blurb), "named, it comes first")
        for word in ["search", "index", "rebuild", "reindex", "Search Index", "INDEX"] {
            #expect(findings(word).contains { $0.kind == .setting && $0.pane == .dataSafety && $0.lead == row.title },
                    "“\(word)” finds the row")
        }
    }

    @Test func itTakesNoOtherRowsFirstFinding() {
        // The row answers no "find" (the find family's word), "check" still names the updates row first, and
        // "backup" the backups row.
        #expect(!findings("find").contains { $0.lead == DataSafetyCopy.searchIndexSection },
                "“find” is not the row's word")
        #expect(findings("check").first { $0.kind == .setting }?.lead == UpdateSettingsCopy.title,
                "“check” still names Check for updates first")
        #expect(findings("backup").first { $0.kind == .setting }?.lead == "Backups")
    }
}
