//
//  CommitVocabularyTests.swift
//  VariorumTests
//
//  13s-b U4 (VX-103) — **the app-surface commit sweep's pins.** Her R-13s-31,
//  verbatim: *"renaming savepoints to commits is a new task for 13s that is
//  being noted - but I want that changed everywhere."*
//
//  `DeadVocabularyTests` fences the LABELS and HEADERS app-wide, and only
//  them — R-13s-32's shape lets explanatory prose keep "savepoint" where it
//  defines commit (the tour's step-4 sentence is the recorded exemplar). So
//  the PROSE this sweep moved anyway — receipts, help, the ⌘/ helper, the
//  Settings pane's sentences — would be free to drift back with nothing to
//  notice. These pins hold each of those surfaces by its own constant. Every
//  one is red on the pre-sweep tree by construction: each string said
//  "savepoint".
//
//  The keys never moved (`savepoint_cadence`, `commit_point`, every code
//  name): the last test holds that half too — the old word still FINDS the
//  pane, because the Settings search keeps it as a never-rendered keyword.
//

import Foundation
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("13s-b U4 — the app's surfaces say commit (R-13s-31)")
struct CommitVocabularyTests {
    private func saysSavepoint(_ text: String) -> Bool {
        DeadVocabularyTests.containsWord("savepoint", in: text)
            || DeadVocabularyTests.containsWord("savepoints", in: text)
    }

    /// Block History's header and its fold line — both platforms read these.
    @Test func blockHistorySaysCommits() {
        #expect(BlockHistoryPath.savepointsSection == "Commits")
        #expect(SavepointRuns.runLabel(count: 2) == "2 quiet commits")
        #expect(!saysSavepoint(SavepointRuns.runHelp))
        let take = Variant(
            id: "v", blockId: "b", fanPosition: "a",
            createdAt: Date(timeIntervalSince1970: 0), updatedAt: Date(timeIntervalSince1970: 0))
        #expect(BlockPastCopy.putBackHelp(take).contains("its commits all come back"))
    }

    /// The Settings pane: its section header, both pickers' titles, every
    /// sentence under them, and the Writing pane's own one-liner.
    @Test func theSettingsPaneSaysCommit() {
        #expect(SavepointCadenceCopy.title == "Commits Variorum makes for you")
        #expect(HistoryPruningCopy.title == "Old quiet commits")
        let sentences = [SavepointCadenceCopy.help, SavepointCadenceCopy.insuranceNote,
                         HistoryPruningCopy.help, SettingsPane.writing.blurb]
            + SavepointCadence.allCases.map(SavepointCadenceCopy.label)
            + HistoryPruning.allCases.map(HistoryPruningCopy.label)
            + SettingsCatalog.rows.flatMap { [$0.title, $0.blurb] }
        for sentence in sentences {
            #expect(!saysSavepoint(sentence), "still says savepoint: \(sentence)")
        }
        #expect(HistoryPruningCopy.help.contains("Commits you made yourself with \u{2318}S"))
    }

    /// The commit doors' receipts and the name field's help (all four Mac
    /// commit doors), and the never-pruned refusal.
    @Test func theCommitDoorsSayCommit() {
        #expect(SavepointNameCopy.unnamedReceipt == "Committed \u{2014} an immutable saved moment of this take.")
        #expect(SavepointNameCopy.filed("before the rewrite")
                == "Committed \u{201C}before the rewrite\u{201D} \u{2014} an immutable saved moment of this take.")
        #expect(SavepointNameCopy.help.hasSuffix("beside the commit"))
        let refusal = OpsRefusalCopy.message(for: OperationError.deliberateSavepointNeverPruned(id: "c"))
        #expect(refusal.contains("deliberate \u{2318}S commit"))
        #expect(!saysSavepoint(refusal))
    }

    /// The ⌘/ helper: every shortcut row and every dictionary entry — the
    /// "commit" entry still DEFINES the word, in the app's plain gloss.
    @Test func theHelperSaysCommitOnEveryRow() throws {
        let rows = HelperView.groups.flatMap(\.items).map { "\($0.keys) — \($0.does)" }
            + HelperView.entries.map { "\($0.term) — \($0.definition)" }
        #expect(rows.count > 40, "the walk read the real helper (\(rows.count) rows)")
        for row in rows {
            #expect(!saysSavepoint(row), "the helper still says savepoint: \(row.prefix(90))")
        }
        let commit = try #require(HelperView.entries.first { $0.term == "commit" })
        #expect(commit.definition.hasPrefix("An immutable saved moment of one take (\u{2318}S)."))
    }

    /// The Library's day filter, and the Jekyll book's front matter.
    @Test func theDayFilterAndTheJekyllFrontMatterSayCommit() {
        #expect(LibraryDayFace.caveat.hasSuffix("earlier days show up where a commit landed."))
        #expect(SampleLibraryJekyllBook.aboutThisBook.contains("commits spread over the weeks"))
        #expect(!saysSavepoint(SampleLibraryJekyllBook.aboutThisBook))
    }

    /// The KEYS stayed (the brief's one exception), and the old word still
    /// finds the pane: the Settings search keeps "savepoint" as a keyword it
    /// never renders, and "commit" finds the same row.
    @Test func theOldWordStillFindsThePaneItsKeyNamed() {
        let byOldWord = SettingsSearch.findings(matching: "savepoint", in: SettingsSearch.settingsEntries)
        let byNewWord = SettingsSearch.findings(matching: "commit", in: SettingsSearch.settingsEntries)
        #expect(byOldWord.first?.lead == SavepointCadenceCopy.title)
        #expect(byNewWord.contains { $0.lead == SavepointCadenceCopy.title })
        #expect(SettingsCatalog.title("cadence") == SavepointCadenceCopy.title)
    }
}
