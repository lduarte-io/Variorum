//
//  TakesBarAndFacesTests.swift
//  VariorumTests
//
//  VX-601 batch C — the bars, the chrome and the wording of the Takes family:
//
//  - VX-427 (R-601-3): the Takes bar's "Nw take" unit counts the take being
//    TYPED IN — the focused pane's own take — never the first column's pick;
//  - VX-586: Write's take panel titles its block "block i/N" through the bars'
//    one wording brain (`BlockLineLabel`), never the raw id;
//  - VX-321: Move Take into a Block Below's receipt names the road back in the
//    words of the list the host actually shows ("archived takes" in Write and
//    its panel), VX-154's rider's rule;
//  - VX-574: a take's WORDS wear the voice's type in every Takes face — the
//    read twin's prose in the voice's ink, the stack card's collapsed line in
//    the token layer's font.
//
//  Each red-on-old pin is verified by behavioural revert (the batch C record
//  names the trees); the GUARDS are green on both sides by design.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// A fresh in-memory session world with deterministic dependencies.
@MainActor
private func withBatchCWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 601))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
private func batchCDefaults(_ name: String) -> UserDefaults {
    let suite = "TakesBarAndFacesTests-\(name)"
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    return defaults
}

/// One note: block 1 FANNED — its chosen take "one two three." (3 words) and
/// a second take "four five six seven eight." (5 words); block 2 single
/// ("nine ten."), so the note total is never the take's count.
@MainActor
private struct FannedNote {
    let postID: String
    let blockID: String
    let chosen: String
    let other: String
    let secondBlockID: String

    static func make(_ session: AppSession) async throws -> FannedNote {
        try await session.runner.run { ops in
            let post = try ops.createPost(title: "batch C", profile: .blog)
            let first = try ops.newBlock(in: post.id, text: "one two three.", at: .end)
            let second = try ops.newBlock(in: post.id, text: "nine ten.", at: .end)
            let branch = try ops.branchVariant(first.block.id, from: first.variant.id)
            try ops.autosave(branch.id, text: "four five six seven eight.", charDelta: 12)
            return FannedNote(
                postID: post.id, blockID: first.block.id, chosen: first.variant.id,
                other: branch.id, secondBlockID: second.block.id)
        }
    }

    func model(
        _ session: AppSession, _ db: AppDatabase, defaults: UserDefaults
    ) async throws -> TakesViewModel {
        let model = TakesViewModel(session: session, postID: postID, defaults: defaults)
        model.adopt(try await db.read { [postID] in try Queries.takesProjection($0, post: postID) })
        return model
    }
}

// MARK: - VX-427 — the bar counts the take being typed in

@MainActor
@Suite("The Takes bar counts the take being typed in (VX-427, R-601-3)")
struct TakesBarTakeCountTests {
    /// **RED ON OLD:** with the ring in the bloomed fan's NOT-chosen card the
    /// bar said "3w take" — the chosen take's words, the first column's pick —
    /// and kept saying it while she typed. Now it counts the card she is in,
    /// per keystroke (the authority's buffer), and the chosen card its own.
    @Test func theBarCountsTheFocusedCardsOwnTakeNotTheChosenOne() async throws {
        try await withBatchCWorld { session, db in
            let note = try await FannedNote.make(session)
            let model = try await note.model(session, db, defaults: batchCDefaults("takes"))

            // The ring in the second take's FAN card (the article renders
            // the chosen take only — 13b 3F).
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesFanColumnID,
                blockID: note.blockID, variantID: note.other))
            #expect(model.focusedPane?.variantID == note.other,
                    "precondition: the ring is in the not-chosen take")
            #expect(TakesBottomBar.takeUnit(for: model) == "5w take",
                    "the take she is in — five words, not the chosen take's three")

            // Per keystroke: the buffer, before any autosave lands.
            model.paneEdited(variantID: note.other, newText: "four five six seven eight nine.")
            #expect(TakesBottomBar.takeUnit(for: model) == "6w take",
                    "the unit moves with her typing in THAT take")
            #expect(TakesBottomBar.wordCounts(for: model).unit == "6w take",
                    "…and it is what the bar's counts carry")
            #expect(TakesBottomBar.wordCounts(for: model).note == "5w note",
                    "the note total stays the note's (the chosen takes, cached per projection)")

            // GUARD (green on both sides): the chosen take's own pane counts
            // its own words, and no ring says no unit.
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: note.blockID, variantID: note.chosen))
            #expect(TakesBottomBar.takeUnit(for: model) == "3w take")
            model.blur()
            #expect(TakesBottomBar.takeUnit(for: model) == nil, "no ring, no unit")
        }
    }

    /// **RED ON OLD:** on the Lenses board the bar counted the CHOSEN column's
    /// take whatever lens column she typed in (`columns.first`). Now the lens
    /// column's pane counts the take that column shows — the one she is in.
    @Test func onTheLensesBoardTheBarCountsTheLensColumnsTake() async throws {
        try await withBatchCWorld { session, db in
            let note = try await FannedNote.make(session)
            let model = try await note.model(session, db, defaults: batchCDefaults("lenses"))
            model.host = .lenses
            model.addScratchColumn()
            let lensID = try #require(model.columns.last?.id)
            #expect(lensID != model.columns.first?.id, "precondition: a second column")
            await model.pick(columnID: lensID, blockID: note.blockID, variantID: note.other)
            let lens = try #require(model.columns.first { $0.id == lensID })
            #expect(model.resolvedTake(column: lens, slot: try #require(
                model.projection.slots.first { $0.blockID == note.blockID }))?.variantID
                    == note.other, "precondition: the lens column shows the second take")

            model.focus(TakesViewModel.PaneKey(
                columnID: lens.id, blockID: note.blockID, variantID: note.other))
            #expect(TakesBottomBar.takeUnit(for: model) == "5w take",
                    "the lens column's take — not the Chosen column's three words")
        }
    }
}

// MARK: - VX-586 — "block i/N", never the raw id

@MainActor
@Suite("Write's take panel titles its block block i/N (VX-586)")
struct TakesPanelBlockLabelTests {
    /// **RED ON OLD:** the title read "Takes — block 00000000" — the block's
    /// id, the face 13g R5-4 retired from both bars. It now speaks the bars'
    /// own label: the block's place in the note.
    @Test func thePanelTitleSaysWhereTheBlockSitsNeverItsID() async throws {
        let slots = [
            slot("AAAA1111-0000-0000-0000-000000000001", text: "first"),
            slot("BBBB2222-0000-0000-0000-000000000002", text: "second"),
            slot("CCCC3333-0000-0000-0000-000000000003", text: "third"),
        ]
        let title = WriteTakesPanel.title(blockID: slots[1].blockID, slots: slots)
        #expect(title == "Takes — block 2/3")
        #expect(title == "Takes — " + BlockLineLabel.caret(ordinal: 2, of: 3),
                "one wording brain with the two bars")
        #expect(!title.contains("BBBB2222"), "no raw id, ever")
        #expect(WriteTakesPanel.title(blockID: slots[0].blockID, slots: slots)
                == "Takes — block 1/3")
    }

    /// **RED ON OLD:** a block the projection does not hold (not landed yet,
    /// or gone from the note) still showed its id; it now reads the brain's
    /// honest blank — never a wrong number.
    @Test func aBlockTheNoteDoesNotHoldReadsTheHonestBlank() async throws {
        let slots = [slot("AAAA1111-0000-0000-0000-000000000001", text: "first")]
        let title = WriteTakesPanel.title(
            blockID: "DDDD4444-0000-0000-0000-000000000004", slots: slots)
        #expect(title == "Takes — block —")
        #expect(!title.contains("DDDD4444"))
    }
}

// MARK: - VX-321 — the receipt speaks the list's own words

@MainActor
@Suite("Move Take into a Block Below names the list the host shows (VX-321)")
struct TakeMovedReceiptWordingTests {
    /// The Takes board's sentence, exactly as it has always read — its
    /// disclosure IS "archived · n".
    static let boardSentence =
        "That take is now the block below — the original is archived on its "
        + "block (\u{201c}archived \u{B7} n\u{201d} under its takes brings it back); "
        + "\u{2325}\u{2318}Z undoes it."

    /// **RED ON OLD** (one sentence for every host): Write and its take panel
    /// list a block's archived takes under "archived takes", and the Lenses
    /// board lists none — so their receipts name THAT road, never the board's
    /// disclosure they do not have. The board's own words are byte-unchanged.
    @Test func eachHostsReceiptNamesItsOwnList() {
        let header = TakeStructureCopy.archivedTakesHeader
        #expect(header == "archived takes", "the panel's list header (GUARD — the literal)")
        let quoted = "\u{201c}\(header)\u{201d}"

        let write = TakeStructureCopy.movedNote(.write)
        #expect(write.contains(quoted), "Write names its takes panel's list: \(write)")
        #expect(!write.contains("archived \u{B7} n"))

        let panel = TakeStructureCopy.movedNote(.writePanel)
        #expect(panel.contains(quoted), "the panel names its own list: \(panel)")
        #expect(!panel.contains("archived \u{B7} n"))

        let lenses = TakeStructureCopy.movedNote(.lensesBoard)
        #expect(lenses.contains("Takes board"), "Lenses points at the board that lists it: \(lenses)")
        #expect(!lenses.contains("archived \u{B7} n"))

        #expect(TakeStructureCopy.movedNote(.takesBoard) == Self.boardSentence,
                "the board's sentence is the one it always said")
    }

    /// **RED ON OLD — the door, on Write's take panel:** the panel's model
    /// (`writePanelBlockID`) moved the take and said "archived · n".
    @Test func thePanelsDoorSpeaksThePanelsList() async throws {
        try await withBatchCWorld { session, db in
            let note = try await FannedNote.make(session)
            let model = try await note.model(session, db, defaults: batchCDefaults("panel"))
            model.writePanelBlockID = note.blockID
            await model.moveTakeIntoBlockBelow(blockID: note.blockID, variantID: note.other)
            let receipt = try #require(model.statusMessage, "the door spoke")
            #expect(model.status?.isRefusal == false, "a receipt (\(receipt))")
            #expect(receipt == TakeStructureCopy.movedNote(.writePanel))
            #expect(receipt.contains("\u{201c}archived takes\u{201d}"), "\(receipt)")
        }
    }

    /// **RED ON OLD — the door, on the Lenses board**, which renders no
    /// archived list at all.
    @Test func theLensesBoardsDoorPointsAtTheTakesBoard() async throws {
        try await withBatchCWorld { session, db in
            let note = try await FannedNote.make(session)
            let model = try await note.model(session, db, defaults: batchCDefaults("lensdoor"))
            model.host = .lenses
            await model.moveTakeIntoBlockBelow(blockID: note.blockID, variantID: note.other)
            let receipt = try #require(model.statusMessage, "the door spoke")
            #expect(receipt == TakeStructureCopy.movedNote(.lensesBoard), "\(receipt)")
        }
    }

    /// GUARD (green on both sides): the Takes board's door keeps its words.
    @Test func theTakesBoardsDoorKeepsItsDisclosuresWords() async throws {
        try await withBatchCWorld { session, db in
            let note = try await FannedNote.make(session)
            let model = try await note.model(session, db, defaults: batchCDefaults("board"))
            await model.moveTakeIntoBlockBelow(blockID: note.blockID, variantID: note.other)
            #expect(model.statusMessage == Self.boardSentence)
        }
    }

    /// **RED ON OLD — the door, in Write itself** (⌥⌘⏎ on the caret's take):
    /// Write's road back is the block's takes panel, headed "archived takes".
    @Test func writesDoorNamesTheTakesPanelsList() async throws {
        try await withEditor(seedBlocks: ["Shown take."]) { h in
            let slot = try #require(try h.storeSlots().first)
            let shown = try #require(slot.variantID)
            let second = try h.session.operations.branchVariant(slot.blockID, from: shown)
            try h.session.operations.autosave(second.id, text: "Second take.", charDelta: 0)
            try h.reload()
            h.textView.setSelectedRange(NSRange(location: 2, length: 0))
            h.model.updateCaretContext()

            await h.model.structural.moveCaretTakeIntoBlockBelow()
            for _ in 0..<400 where h.model.statusMessage == nil {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
            #expect(try h.storeSlots().count == 2, "the take really moved")
            #expect(h.model.statusMessage == TakeStructureCopy.movedNote(.write),
                    "\(h.model.statusMessage ?? "nil")")
            #expect(h.model.statusMessage?.contains("\u{201c}archived takes\u{201d}") == true)
        }
    }
}

// MARK: - VX-574 — a take's words wear the voice's type everywhere in Takes

@MainActor
@Suite("Takes' words wear the voice's type (VX-574)")
struct TakesProseFaceTests {
    /// **RED ON OLD:** the read twin of the Takes board (every unfocused pane
    /// or non-key window holding a note in Takes) drew her words in the
    /// voice's MUTED grey — lighter than every other reader of her prose. It
    /// draws them in the voice's ink now, in both voices and both rooms.
    @Test func theReadTwinDrawsHerWordsInTheVoicesInk() {
        for voice in [ThemeVoice.study, .terminal] {
            for dark in [false, true] {
                let tokens = VoiceTokens.resolve(voice: voice, dark: dark)
                #expect(tokens.ink != tokens.muted, "precondition: the two differ (\(voice), dark \(dark))")
                #expect(ReadTakesView.proseInk(tokens) == tokens.ink,
                        "\(voice) dark \(dark): the prose ink, never muted")
            }
        }
    }

    /// **RED ON OLD:** a stack card folded by its ▾ showed its first line in
    /// `.callout` — a literal system font outside the token layer. It wears
    /// the voice's small face now (the board's other one-line take summary's).
    @Test func theCollapsedCardLineWearsTheVoicesFont() {
        for voice in [ThemeVoice.study, .terminal] {
            let tokens = VoiceTokens.resolve(voice: voice, dark: false)
            #expect(TakesBoardView.collapsedTakeLineFont(tokens) == tokens.small, "\(voice)")
            #expect(TakesBoardView.collapsedTakeLineFont(tokens) != Font.callout, "\(voice)")
        }
    }
}
