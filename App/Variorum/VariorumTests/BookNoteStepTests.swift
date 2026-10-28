//
//  BookNoteStepTests.swift
//  VariorumTests
//
//  VX-563 — ⌘↑ / ⌘↓ step between a book's notes while reading (her kickoff
//  ruling: "⌘↑/⌘↓ step between notes while reading, document start/end while
//  editing" — VX-560's rule; the arms are A-648-6, all PROVISIONAL). The pins:
//  the key rule (pure — exactly ⌘, never while text holds the keyboard, never
//  in Index), the step (pure — the order, the ends' words), the NAMED seam
//  (pure — each mode's viewed note; Read ▸ Scroll's interim arm), the
//  registry's VX-560 shape, and a model-level walk of every mode's landing
//  road (Outline REVEAL-ONLY — focus untouched; the spread one note on; Read
//  ▸ Pages the paged reader's focus; Read ▸ Scroll the reveal, which becomes
//  the standing anchor). Red on old by construction: nothing here existed. The
//  key's real press in a window is the walk's (the monitor's road is
//  `BrowserNavKeyMonitor`'s, whose own pins and walk carry it).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-563 — ⌘↑ / ⌘↓ step between a book's notes while reading", .serialized)
struct BookNoteStepTests {
    // MARK: - The key rule

    @Test func theKeysStepOnlyWhileReadingAndNeverInIndex() {
        typealias Step = BookNoteStep
        let up = Step.upArrowKeyCode, down = Step.downArrowKeyCode
        func dir(_ key: UInt16, _ mods: NSEvent.ModifierFlags, text: Bool = false,
                 _ mode: BookStructureModel.ViewMode = .outline) -> Step.Direction? {
            Step.direction(keyCode: key, modifiers: mods, textIsFirstResponder: text, mode: mode)
        }
        for mode in [BookStructureModel.ViewMode.outline, .spread, .read] {
            #expect(dir(up, .command, mode) == .previous, "⌘↑ steps back in \(mode)")
            #expect(dir(down, .command, mode) == .next, "⌘↓ steps on in \(mode)")
            #expect(dir(down, .command, text: true, mode) == nil, "typing: ⌘↓ is the text's document end")
        }
        #expect(dir(down, .command, .index) == nil, "Index is never consumed (A-648-6 (1))")
        #expect(dir(up, .command, .index) == nil)
        #expect(dir(down, [.command, .shift]) == nil, "⇧⌘↓ selects")
        #expect(dir(down, [.command, .option]) == nil)
        #expect(dir(down, [.command, .control]) == nil, "⌃⌘↓ is Next Block")
        #expect(dir(down, []) == nil, "a bare ↓ is the page's")
        #expect(dir(PageTurnKeys.rightArrowKeyCode, .command) == nil, "⌘→ is VX-560's forward")
        #expect(dir(down, [.command, .numericPad, .function]) == .next,
                "an arrow's own flags are not modifiers she pressed")
        #expect(Step.Direction.previous.capability == .previousNoteInBook)
        #expect(Step.Direction.next.capability == .nextNoteInBook)
    }

    // MARK: - The step

    @Test func theStepWalksTheOrderAndSaysTheEnds() {
        let order = ["a", "b", "c"]
        #expect(BookNoteStep.step(.next, from: nil, order: order) == .land(postID: "a"),
                "nothing viewed is before the first note")
        #expect(BookNoteStep.step(.previous, from: nil, order: order) == .atFirst)
        #expect(BookNoteStep.step(.next, from: "a", order: order) == .land(postID: "b"))
        #expect(BookNoteStep.step(.previous, from: "b", order: order) == .land(postID: "a"))
        #expect(BookNoteStep.step(.next, from: "c", order: order) == .atLast)
        #expect(BookNoteStep.step(.previous, from: "a", order: order) == .atFirst)
        #expect(BookNoteStep.step(.next, from: "gone", order: order) == .land(postID: "a"),
                "a note the order lost views nothing")
        #expect(BookNoteStep.step(.next, from: nil, order: []) == nil, "an empty book: the key passes on")
        #expect(BookNoteStep.words(for: .atFirst) == "That's the book's first note.")
        #expect(BookNoteStep.words(for: .atLast) == "That's the book's last note.")
        #expect(BookNoteStep.words(for: .land(postID: "a")) == nil)
    }

    // MARK: - The named seam (A-648-6 (2))

    @Test func theSeamReadsEachModesOwnViewedNote() {
        let order = ["a", "b", "c"]
        let facts = BookNoteStep.Facts(outlineViewed: "b", spreadLeft: "c", pagedShown: "a", standingAnchor: "b")
        func viewed(_ mode: BookStructureModel.ViewMode, _ facts: BookNoteStep.Facts,
                    _ form: BookStructureModel.ReadForm = .flow) -> String? {
            BookNoteStep.viewedNote(mode: mode, readForm: form, facts: facts, order: order)
        }
        #expect(viewed(.outline, facts) == "b", "Outline: VX-562's viewed note")
        #expect(viewed(.spread, facts) == "c", "the spread: its left page")
        #expect(viewed(.read, facts, .pages) == "a", "Read ▸ Pages: the paged reader's note")
        #expect(viewed(.read, facts, .flow) == "b", "Read ▸ Scroll (INTERIM): the standing anchor")
        #expect(viewed(.index, facts) == nil, "Index never steps")
        let empty = BookNoteStep.Facts()
        #expect(viewed(.outline, empty) == nil, "the title block holds the page")
        #expect(viewed(.read, empty, .flow) == "a", "nothing landed yet: the flow's first note")
        #expect(viewed(.read, empty, .pages) == "a")
        #expect(viewed(.outline, BookNoteStep.Facts(outlineViewed: "gone")) == nil, "a stale report")
    }

    // MARK: - The registry (P-1 — VX-560's door shape)

    @Test func theStepIsDeclaredInVX560sShape() {
        for (id, key) in [(CapabilityID.previousNoteInBook, "\u{2318}\u{2191}"), (.nextNoteInBook, "\u{2318}\u{2193}")] {
            let cap = CapabilityRegistry.capability(id)
            #expect(cap.doors == [.surface], "\(id): the book's key monitor is its one door")
            #expect(cap.shortcutLabel == nil, "\(id): no menu key — it would take document start/end from text")
            #expect(cap.alternateShortcutLabel == key)
            #expect(EditorCommands.keyEquivalent(for: id) == nil)
            #expect(!EditorCommands.menuRendered.contains(id))
            #expect(BookView.surfaceCapabilities.contains(id), "\(id): the book view renders the monitor")
            #expect(CapabilityRegistry.isEnabled(id, in: CapabilityContext(focusedPaneShowsBook: true)))
            #expect(!CapabilityRegistry.isEnabled(id, in: CapabilityContext(focusedPaneShowsNote: true)))
        }
        #expect(HelperView.shortcutKeysShown.isSuperset(of: ["\u{2318}\u{2191}", "\u{2318}\u{2193}"]),
                "the helper (⌘/) shows both")
    }

    // MARK: - Every mode's landing road (the model)

    private func withBook(
        _ body: @MainActor (AppSession, BookViewModel, BookStructureModel, [String]) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator { Date(timeIntervalSince1970: 1_782_864_000) }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 563))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let reading = try ops.createReading(name: "stepping", kind: .book)
            var ids: [String] = []
            for title in ["a", "b", "c", "d"] {
                let post = try ops.createPost(title: title)
                try ops.addPostToReading(post.id, to: reading.id)
                ids.append(post.id)
            }
            let chapterX = try ops.createSection(in: reading.id, name: "X")
            let chapterY = try ops.createSection(in: reading.id, name: "Y")
            let model = BookViewModel(session: session, readingID: reading.id)
            await model.adopt(try await db.read { [id = reading.id] in
                try Queries.assembleReading($0, readingID: id)
            })
            #expect(model.entries.map(\.postID) == ids, "the book's own order: a b c d")
            let structure = BookStructureModel(session: session, readingID: reading.id)
            // Chapters: X holds a and c, Y holds b, d is unfiled — so the
            // GROUPED order (Outline, Read ▸ Scroll) is a c b d, while the
            // leaves (the spread, Read ▸ Pages) keep a b c d.
            structure.adopt(.init(
                reading: try await db.read { try Queries.reading($0, id: reading.id) },
                sections: [chapterX, chapterY], deletedSections: [],
                assignments: [ids[0]: chapterX.id, ids[2]: chapterX.id, ids[1]: chapterY.id]))
            #expect(structure.chaptersActive)
            try await body(session, model, structure, ids)
        }
    }

    @Test func eachModeStepsInItsOwnOrderThroughItsOwnRoad() async throws {
        try await withBook { session, model, structure, ids in
            let (a, b, c, d) = (ids[0], ids[1], ids[2], ids[3])
            @MainActor func press(_ direction: BookNoteStep.Direction) -> Bool {
                BookNoteStepDoor.step(direction, model: model, structure: structure, status: session.status)
            }

            // OUTLINE — grouped order a c b d; REVEAL-ONLY, focus untouched.
            structure.mode = .outline
            #expect(BookNoteStepDoor.order(structure: structure, entries: model.entries) == [a, c, b, d])
            #expect(press(.next))
            #expect(model.pendingReveal == a, "nothing viewed: the first note, revealed")
            #expect(model.focusedPostID == nil, "REVEAL-ONLY: no live editor mounted (A-648-6 (3))")
            model.consumeReveal()
            model.noteOutlineViewed(.init(postID: a))   // the follower adopts the landing
            #expect(press(.next) && model.pendingReveal == c, "the next in the PAGE's order — across a chapter")
            model.consumeReveal()
            #expect(press(.previous) && session.status.spoken?.text == BookNoteStep.firstNoteWords,
                    "at the first note ⌘↑ says so")
            #expect(session.status.spoken?.kind == .refusal)
            #expect(model.pendingReveal == nil, "and lands nothing")
            session.status.clear()
            model.noteOutlineViewed(.init(postID: d))
            #expect(press(.next) && session.status.spoken?.text == BookNoteStep.lastNoteWords)
            session.status.clear()

            // THE SPREAD — the leaves' order a b c d; the next note becomes the left page.
            structure.mode = .spread
            model.openSpread(leftIndex: 0)
            #expect(model.leftPage?.postID == a)
            #expect(press(.next) && model.leftPage?.postID == b,
                    "one note on — even though b was already the right page")
            #expect(press(.next) && model.leftPage?.postID == c)
            #expect(press(.previous) && model.leftPage?.postID == b)

            // READ ▸ PAGES — the leaves' order; the paged reader follows focus.
            structure.mode = .read
            structure.readForm = .pages
            model.notePagedAnchor(b)
            #expect(press(.next) && model.focusedPostID == c, "the paged reader turns to c's first page")

            // READ ▸ SCROLL — the grouped order; the reveal becomes the standing anchor.
            structure.readForm = .flow
            model.consumeReveal()
            #expect(press(.next))
            let first = try #require(model.pendingReveal)
            #expect(model.standingAnchorPostID == first)
            model.consumeReveal()
            let second = BookNoteStepDoor.order(structure: structure, entries: model.entries)
            #expect(second == [a, c, b, d])
            #expect(press(.next) && model.pendingReveal == second[(second.firstIndex(of: first) ?? 0) + 1],
                    "each press steps on from where the last landed")

            // INDEX — never consumed; nothing moves.
            structure.mode = .index
            model.consumeReveal()
            #expect(!press(.next) && model.pendingReveal == nil)
            #expect(session.status.spoken == nil)
        }
    }

    @Test func anEmptyBookLetsTheKeyPass() throws {
        let db = try AppDatabase.inMemory()
        try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator { Date(timeIntervalSince1970: 1_782_864_000) }
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let reading = try session.operations.createReading(name: "empty", kind: .book)
            let model = BookViewModel(session: session, readingID: reading.id)
            let structure = BookStructureModel(session: session, readingID: reading.id)
            structure.mode = .outline
            #expect(!BookNoteStepDoor.step(.next, model: model, structure: structure, status: session.status))
            #expect(session.status.spoken == nil, "nothing to say — the key is not used")
        }
    }

    /// The book view installs the monitor, live only in its focused pane, on
    /// its current mode, through the one step act (source — a window's key
    /// monitor is the walk's to press; `BrowserNavKeyMonitor`'s shape).
    @Test func theBookViewRendersTheMonitorOnItsFocusedPane() throws {
        let text = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/Features/BookView/BookView.swift"),
            encoding: .utf8)
        #expect(text.contains("BookNoteStepKeyMonitor(\n                isActive: paneFocused, mode: structure.mode,"))
        #expect(text.contains("onStep: { stepNote($0) })"))
        #expect(text.contains("BookNoteStepDoor.step(direction, model: model, structure: structure, status: session.status)"))
    }
}
