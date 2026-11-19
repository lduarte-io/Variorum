//
//  TrashSearchModelTests.swift
//  VariorumTests
//
//  VX-93 (the vx-980 run, batch 3; `notes/plans/fixes/vx-980-search-fixes.md`)
//  — A SEARCH INSIDE THE TRASH, the Mac's half. Her rulings (verbatim in
//  `notes/plans/fixes/vx-980-her-rulings.md`): R-980-9 (names and deleted
//  text), R-980-10 (every word, folded, partial words, no grammar), R-980-11
//  (one passage line where the row does not show the match), R-980-12 (the
//  field always in the Trash's header beside the kind filter; empty on every
//  visit; esc clears; it narrows as she types, alongside the kind filter;
//  Empty Trash stays a whole-Trash door).
//
//  Two suites: the MODEL (`TrashSearchModelTests` — the debounced ask, the
//  narrowing over the real observations, the kind filter composing, the
//  filtered-empty sentence, the whole-Trash doors unmoved, a superseded
//  question's answer dropped) and the mounted FACE (`TrashSearchFieldTests` —
//  never a key-view stop, typing moves nothing, the passage line under its
//  row, esc clears, the pick pruned by the view's own wiring).
//
//  A feature batch: these pins state the NEW contract (no red-on-old leg is
//  owed). How each can fail is said at each pin. WRITTEN and compiled by the
//  implementer (`build-for-testing`); RUN at the orchestrator's gate.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// One turn of the main run loop (a sync helper: `run(until:)` is not for
/// async contexts — `TrashMessageBandTests`' `pump` shape).
@MainActor
private func pump(_ seconds: TimeInterval = 0.02) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

/// Pumps the run loop and yields until `done`, or the bound passes.
@MainActor
private func settle(until done: () -> Bool, seconds: TimeInterval = 10) async {
    let deadline = Date().addingTimeInterval(seconds)
    while !done(), Date() < deadline {
        pump()
        for _ in 0..<10 { await Task.yield() }
    }
}

/// The Trash a search can be asked of: three deleted notes, a deleted book, a
/// deleted block and an EMPTY deleted block (the sweep door's), all in Home.
/// Listed: three notes, the book and the two blocks — six rows.
private struct TrashWorld: Sendable {
    let garden: String      // "garden plans" — "rhubarb" in its BODY only
    let pie: String         // "rhubarb pie" — "rhubarb" in its TITLE
    let apple: String       // "apple orchard" — no rhubarb anywhere
    let book: String        // "rhubarb shelf" — a book, by its name
    let crumble: String     // a block: "rhubarb crumble" in its first line
    let emptyBlock: String  // an empty block (no history)

    @MainActor
    static func make(_ editor: EditorHarness) async throws -> TrashWorld {
        try await editor.session.runner.run { (ops: Operations) -> TrashWorld in
            let garden = try ops.createPost(title: "garden plans")
            _ = try ops.newBlock(in: garden.id, text: "We moved the rhubarb to the east bed.")
            let pie = try ops.createPost(title: "rhubarb pie")
            _ = try ops.newBlock(in: pie.id, text: "Two cups of fruit.")
            let apple = try ops.createPost(title: "apple orchard")
            _ = try ops.newBlock(in: apple.id, text: "Pruning day.")
            let book = try ops.createReading(name: "rhubarb shelf", kind: .book)
            let home = try ops.createPost(title: "kitchen")
            let crumble = try ops.newBlock(in: home.id, text: "rhubarb crumble, 2 cups")
            let empty = try ops.newBlock(in: home.id, text: "")
            try ops.deleteContainer(garden.id)
            try ops.deleteContainer(pie.id)
            try ops.deleteContainer(apple.id)
            _ = try ops.deleteReading(book.id)
            try ops.deleteBlock(crumble.block.id)
            try ops.deleteBlock(empty.block.id)
            return TrashWorld(
                garden: garden.id, pie: pie.id, apple: apple.id, book: book.id,
                crumble: crumble.block.id, emptyBlock: empty.block.id)
        }
    }
}

/// A box the DEBUG answer gate can park a continuation in.
@MainActor
private final class Held {
    var continuation: CheckedContinuation<Void, Never>?
    /// Set once the gate has held its one answer (a gate that holds once).
    var used = false
}

@MainActor
@Suite("VX-93 — the Trash's search, the model", .serialized)
struct TrashSearchModelTests {

    // MARK: - The field's words (R-980-12)

    /// Empty on every visit: a visit builds its own model, and the field and
    /// the question start empty — the listing is the whole Trash.
    /// (Fails if a model is born holding words, or a search state outlives
    /// `clearSearch`.)
    @Test func aVisitOpensWithAnEmptyFieldAndTheWholeTrash() async throws {
        try await withEditor { editor in
            let model = RecoveryViewModel(session: editor.session)
            #expect(model.searchText.isEmpty)
            #expect(model.askedWords.isEmpty)
            #expect(!model.isSearching)
            #expect(model.passages.isEmpty)
            model.editSearch("rhubarb")
            model.askSearchNow()
            #expect(model.isSearching)
            model.clearSearch()
            #expect(model.searchText.isEmpty && model.askedWords.isEmpty && !model.isSearching)
        }
    }

    /// The listing answers once the typing pauses (one ask for a burst of
    /// keys), at once when the field empties, never for a whitespace edit; ⏎
    /// asks now; esc clears and cancels a pending ask. (Fails if every key
    /// restarts the listing, or an emptied field waits.)
    @Test func typingAsksOncePausedAndEmptyingAnswersAtOnce() async throws {
        try await withEditor { editor in
            let model = RecoveryViewModel(session: editor.session)
            model.searchDebounce = .milliseconds(40)
            let start = model.restartToken
            model.editSearch("r")
            model.editSearch("rh")
            model.editSearch("rhub")
            #expect(model.searchText == "rhub", "the field shows every key at once")
            #expect(model.askedWords.isEmpty, "…but the listing waits for the pause")
            #expect(model.restartToken == start)
            await settle(until: { !model.askedWords.isEmpty }, seconds: 2)
            #expect(model.askedWords == ["rhub"])
            #expect(model.restartToken == start &+ 1, "one ask for the burst")

            model.editSearch("rhub  ")
            try await Task.sleep(for: .milliseconds(120))
            #expect(model.restartToken == start &+ 1, "a space typed asks nothing new")

            model.editSearch("")
            #expect(model.askedWords.isEmpty, "an emptied field answers at once")
            #expect(model.restartToken == start &+ 2)

            model.editSearch("pear")
            model.askSearchNow()
            #expect(model.askedWords == ["pear"], "⏎ asks now")

            model.editSearch("pear plum")
            model.clearSearch()
            try await Task.sleep(for: .milliseconds(120))
            #expect(model.searchText.isEmpty)
            #expect(model.askedWords.isEmpty, "esc cancelled the pending ask")
        }
    }

    // MARK: - The narrowing (R-980-9, R-980-10, R-980-11)

    /// The listing narrows to the rows holding every word, the passages ride
    /// with it, and the kind filter composes (both narrow, neither resets the
    /// other). Driven over the REAL observations. (Fails if a row is listed
    /// that does not hold the words, a body match carries no passage, a shown
    /// match carries one, or the filter resets the words or the words the
    /// filter.)
    @Test func theSearchNarrowsTheListingAndComposesWithTheKindFilter() async throws {
        try await withEditor { editor in
            let world = try await TrashWorld.make(editor)
            let model = RecoveryViewModel(session: editor.session)
            model.editSearch("rhubarb")
            model.askSearchNow()
            var listing = Task { await model.startTrash() }
            await settle(until: { model.trashListingLoaded })
            #expect(Set(model.trash.map(\.id)) == [world.garden, world.pie, world.book, world.crumble])
            #expect(model.passages[world.garden] == "We moved the rhubarb to the east bed.",
                    "found by its body, which its row does not show")
            #expect(model.passages[world.pie] == nil, "its title shows the word")
            #expect(model.passages[world.book] == nil, "a book is found by the name it shows")
            #expect(model.passages[world.crumble] == nil, "its first line shows the word")

            listing.cancel()
            model.kindFilter = .note
            #expect(model.askedWords == ["rhubarb"], "the filter never resets the words")
            listing = Task { await model.startTrash() }
            await settle(until: { Set(model.trash.map(\.id)) == [world.garden, world.pie] })
            #expect(Set(model.trash.map(\.id)) == [world.garden, world.pie])

            listing.cancel()
            model.clearSearch()
            #expect(model.kindFilter == .note, "the words never reset the filter")
            model.kindFilter = nil
            listing = Task { await model.startTrash() }
            defer { listing.cancel() }
            let (now, wing) = (editor.session.now, editor.session.wing.currentID)
            let whole = try await editor.session.database.read { db in
                try Queries.trash(
                    db, now: now, kinds: TrashScope.listedKinds,
                    limit: RecoveryViewModel.window + 1, wingID: wing)
            }
            #expect(whole.count == 6, "premise: three notes, the book, two blocks")
            await settle(until: { model.trash.count == 6 && model.trashListingLoaded })
            #expect(model.trash == whole, "words cleared: the whole Trash, exactly the plain listing")
            #expect(model.passages.isEmpty)
        }
    }

    /// The face's rule for what a row shows — its name, else its first line —
    /// is what decides whether a passage is owed. (Fails if the rule drifts
    /// from what `trashRow` draws.)
    @Test func aRowShowsItsNameElseItsFirstLine() {
        let note = Queries.TrashItem(kind: .note, id: "n", deletedAt: "x", title: "garden plans", text: nil)
        let block = Queries.TrashItem(kind: .block, id: "b", deletedAt: "x", text: "first line\nsecond line")
        let empty = Queries.TrashItem(kind: .block, id: "e", deletedAt: "x", text: "")
        #expect(RecoveryViewModel.shownText(note) == "garden plans")
        #expect(RecoveryViewModel.shownText(block) == TrayRowPreview.line(block.text))
        #expect(RecoveryViewModel.shownText(block) == "first line")
        #expect(RecoveryViewModel.shownText(empty) == TrayRowPreview.emptyBlock)
    }

    // MARK: - The filtered-empty sentence (R-980-12)

    /// Words typed and nothing matching: the search's own sentence — never
    /// "The Trash is empty." while the Trash holds things — naming the kind
    /// when a kind filter is on; and nothing while a new question has not
    /// answered. (Fails if the empty Trash's sentence speaks for an empty
    /// narrowing, or a stale sentence speaks before the answer.)
    @Test func theFilteredEmptySentenceSpeaksForTheWords() async throws {
        try await withEditor { editor in
            _ = try await TrashWorld.make(editor)
            let model = RecoveryViewModel(session: editor.session)
            let total = Task { await model.startTrashTotal() }
            defer { total.cancel() }
            model.editSearch("zzzz")
            model.askSearchNow()
            #expect(model.trashEmptyStateLine == nil, "the question has not answered")
            var listing = Task { await model.startTrash() }
            await settle(until: { model.trashListingLoaded && model.trashTotalLoaded })
            #expect(model.trash.isEmpty)
            #expect(model.trashEmptyStateLine == "Nothing in the Trash matches.")
            #expect(model.trashEmptyStateLine != RecoveryCopy.trashEmptyLine(filteredBy: nil, holdsOtherKinds: false))

            listing.cancel()
            model.kindFilter = .book
            listing = Task { await model.startTrash() }
            defer { listing.cancel() }
            await settle(until: { model.trashListingLoaded })
            #expect(model.trashEmptyStateLine == "No books in the Trash match.")
            #expect(TrashSearchCopy.noMatches(filteredBy: .snippetGroup) == "No snippet groups in the Trash match.")
            #expect(TrashSearchCopy.noMatches(filteredBy: .note) == "No notes in the Trash match.")

            model.clearSearch()
            #expect(model.trashEmptyStateLine == nil, "the cleared question has not answered yet")
        }
    }

    // MARK: - Everything else keeps its rule

    /// Empty Trash and Delete N empty blocks… stay WHOLE-Trash doors under a
    /// typed search — drawn, counted and confirmed over the whole Trash even
    /// when the narrowing shows nothing. (Fails if either door read the
    /// narrowed listing.)
    @Test func theWholeTrashDoorsKeepTheirWholeTrashRule() async throws {
        try await withEditor { editor in
            let world = try await TrashWorld.make(editor)
            let model = RecoveryViewModel(session: editor.session)
            model.editSearch("zzzz")
            model.askSearchNow()
            let listing = Task { await model.startTrash() }
            let total = Task { await model.startTrashTotal() }
            let blocks = Task { await model.startEmptyBlocks() }
            defer { listing.cancel(); total.cancel(); blocks.cancel() }
            await settle(until: {
                model.trashListingLoaded && model.trashTotalLoaded && !model.emptyBlockIDs.isEmpty
            })
            #expect(model.trash.isEmpty, "premise: the narrowing shows nothing")
            #expect(RecoveryView.showsEmptyTrashDoor(model), "Empty Trash stays on screen")
            #expect(RecoveryView.showsDeleteEmptyBlocksDoor(model), "the sweep stays on screen")
            #expect(model.emptyBlockIDs == [world.emptyBlock])

            await model.requestEmptyTrash()
            guard case .emptyTrash(let counts, _) = model.pendingConfirm else {
                Issue.record("Empty Trash asks: \(String(describing: model.pendingConfirm))")
                return
            }
            #expect(counts[.note] == 3, "the confirm names every note in the Trash, not the narrowed none")
            #expect(counts[.book] == 1)
            #expect(counts[.block] == 2)
            model.cancelPendingPurge()
        }
    }

    /// **A superseded question's answer is dropped** (the VX-408 precedent):
    /// the first question's answer is HELD at the DEBUG gate until the second
    /// question has landed, then released — and the listing keeps the second
    /// question's rows. (Fails without the question guard: the released
    /// answer would land "rhubarb"'s rows over "orchard"'s.)
    @Test func aSupersededQuestionsAnswerIsDropped() async throws {
        try await withEditor { editor in
            let world = try await TrashWorld.make(editor)
            let model = RecoveryViewModel(session: editor.session)
            let held = Held()
            model.editSearch("rhubarb")
            model.askSearchNow()
            // The question the next start asks — read AFTER the ask, since an
            // ask may be a question of its own (ladder round 1, MINOR-1).
            let firstQuestion = model.listingQuestion &+ 1
            model.listingAnswerGate = { question in
                guard question == firstQuestion, held.continuation == nil else { return }
                await withCheckedContinuation { held.continuation = $0 }
            }
            let first = Task { await model.startTrash() }
            defer { first.cancel() }
            await settle(until: { held.continuation != nil })
            #expect(held.continuation != nil, "premise: the first answer is held")

            model.editSearch("orchard")
            model.askSearchNow()
            let second = Task { await model.startTrash() }
            defer { second.cancel() }
            await settle(until: { model.trashListingLoaded })
            #expect(model.trash.map(\.id) == [world.apple])

            held.continuation?.resume()
            held.continuation = nil
            await first.value
            await settle(until: { false }, seconds: 0.3)
            #expect(model.trash.map(\.id) == [world.apple], "the superseded answer never landed")
            #expect(model.passages.isEmpty, "\"orchard\" is in the title it shows")
        }
    }

    /// **An answer still in flight when the words change is dropped — before
    /// the listing restarts** (ladder round 1, MINOR-1). Esc (or any edit that
    /// changes the asked words) lowers the listing and bumps `restartToken`;
    /// the view's `.task(id:)` restart that runs the next `startTrash` comes a
    /// beat later, as its own main-actor job. An answer of the OLD question
    /// already on its way in that beat — here the no-match search's own first
    /// answer, held at the DEBUG gate while the field is cleared, with no new
    /// start run — must not land: it would blank the rows and say "The Trash
    /// is empty." over a Trash holding six. (Fails while only `startTrash`
    /// moves the question: the held answer still answers its unchanged
    /// question, and `adoptListing` raises the listing with `[]`.)
    @Test func anAnswerStillInFlightWhenTheFieldClearsIsDropped() async throws {
        try await withEditor { editor in
            _ = try await TrashWorld.make(editor)
            let model = RecoveryViewModel(session: editor.session)
            let total = Task { await model.startTrashTotal() }
            defer { total.cancel() }
            var listing = Task { await model.startTrash() }
            defer { listing.cancel() }
            await settle(until: { model.trashListingLoaded && model.trashTotalLoaded })
            #expect(model.trash.count == 6, "premise: the whole Trash is on screen")
            #expect(!model.trashIsEmptyUnfiltered, "premise: the Trash holds rows")

            // Words that match nothing. The view's restart cancels the plain
            // listing and starts the search, whose first answer is held.
            model.editSearch("zzzz")
            model.askSearchNow()
            listing.cancel()
            let held = Held()
            let searchQuestion = model.listingQuestion &+ 1
            model.listingAnswerGate = { question in
                guard question == searchQuestion, !held.used else { return }
                held.used = true
                await withCheckedContinuation { held.continuation = $0 }
            }
            listing = Task { await model.startTrash() }
            await settle(until: { held.continuation != nil })
            #expect(held.continuation != nil, "premise: the search's answer is held")
            #expect(model.trash.count == 6 && !model.trashListingLoaded,
                    "premise: the rows stay drawn, the question unanswered")

            // Esc: the field cleared — and the view's restart has NOT run yet.
            model.clearSearch()
            #expect(!model.isSearching)
            held.continuation?.resume()
            held.continuation = nil
            await settle(until: { model.trashListingLoaded || model.trash.isEmpty }, seconds: 0.5)
            #expect(!model.trashListingLoaded, "the search's answer never answered the cleared question")
            #expect(model.trash.count == 6, "the search's empty answer never blanked the rows")
            #expect(model.trashEmptyStateLine == nil,
                    "never \"The Trash is empty.\" over a Trash holding rows: \(String(describing: model.trashEmptyStateLine))")

            // The cleared question's own start answers it: the whole Trash.
            listing.cancel()
            listing = Task { await model.startTrash() }
            await settle(until: { model.trashListingLoaded })
            #expect(model.trash.count == 6)
            #expect(model.trashEmptyStateLine == nil)
        }
    }
}

// MARK: - The face, mounted

@MainActor
@Suite("VX-93 — the Trash's search field, mounted", .serialized)
struct TrashSearchFieldTests {

    private func mount(
        _ editor: EditorHarness, model: RecoveryViewModel
    ) -> NSWindow {
        let library = LibraryViewModel(session: editor.session)
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 900, height: 520),
            styleMask: [.titled, .resizable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: RecoveryView(
            session: editor.session, library: library, openPost: { _ in }, model: model))
        window.orderFrontRegardless()
        return window
    }

    private func field(in view: NSView?) -> TrashSearchTextField.Field? {
        guard let view else { return nil }
        if let field = view as? TrashSearchTextField.Field { return field }
        for child in view.subviews {
            if let found = field(in: child) { return found }
        }
        return nil
    }

    /// **Never a key-view stop, never the opening caret** (VX-332's law; the
    /// sidebar field's precedent): the field declines `canBecomeKeyView`, the
    /// window's key-view loop never reaches it, and the window opening on the
    /// Trash does not give it the keyboard — while a click's road (making it
    /// first responder) still can. (Fails if the field becomes a SwiftUI
    /// `TextField` or loses its subclass.)
    @Test func theFieldIsNeverAKeyViewStopAndNeverTakesTheOpeningCaret() async throws {
        try await withEditor { editor in
            _ = try await TrashWorld.make(editor)
            let model = RecoveryViewModel(session: editor.session)
            let window = mount(editor, model: model)
            defer { window.orderOut(nil); window.close() }
            await settle(until: { model.trashListingLoaded })
            let found = try #require(field(in: window.contentView), "the field is drawn")
            #expect(!found.canBecomeKeyView)
            #expect(found.acceptsFirstResponder, "a click can still put the caret there")

            @MainActor func holdsKeyboard() -> Bool {
                guard let editor = window.firstResponder as? NSTextView, editor.isFieldEditor else {
                    return window.firstResponder === found
                }
                return (editor.delegate as AnyObject?) === found
            }
            #expect(!holdsKeyboard(), "the opening never gives it the keyboard")

            window.recalculateKeyViewLoop()
            var seen: Set<ObjectIdentifier> = []
            var next = window.contentView?.nextValidKeyView
            while let view = next, seen.insert(ObjectIdentifier(view)).inserted {
                #expect(view !== found, "the key-view loop never stops at the field")
                next = view.nextValidKeyView
            }
            window.selectNextKeyView(nil)
            #expect(!holdsKeyboard(), "Tab never lands in it")

            #expect(window.makeFirstResponder(found))
            #expect(holdsKeyboard(), "her click's road gives it the keyboard")
        }
    }

    /// **Typing moves nothing; the passage sits under its row; esc clears.**
    /// The field is first in the controls row; typing "rhubarb" into it (its
    /// own editor, its own delegate) narrows the listing; the field's frame
    /// and a row that stays listed keep their measure; a body match's passage
    /// line lies inside its row's card, below the row's line; esc empties the
    /// field and the Trash is whole again. (Fails if the field's width
    /// followed its text, the passage drew outside its row, or esc did
    /// nothing.)
    @Test func typingNarrowsMovesNothingAndEscClears() async throws {
        try await withEditor { editor in
            let world = try await TrashWorld.make(editor)
            let model = RecoveryViewModel(session: editor.session)
            model.searchDebounce = .milliseconds(30)
            TrashFootProbe.reset()
            defer { TrashFootProbe.reset() }
            let window = mount(editor, model: model)
            defer { window.orderOut(nil); window.close() }
            await settle(until: { model.trash.count == 6 })
            await settle(until: { false }, seconds: 0.3)
            #expect(model.trash.count == 6, "premise: three notes, the book, two blocks")
            let fieldBefore = try #require(TrashFootProbe.frames["field"])
            let pieBefore = try #require(TrashFootProbe.frames["row:\(world.pie)"])

            let found = try #require(field(in: window.contentView))
            #expect(window.makeFirstResponder(found))
            let fieldEditor = try #require(found.currentEditor() as? NSTextView)
            fieldEditor.insertText("rhubarb", replacementRange: fieldEditor.selectedRange())
            #expect(model.searchText == "rhubarb", "the field's own delegate carried her typing")
            await settle(until: { model.trash.count == 4 && model.trashListingLoaded })
            await settle(until: { TrashFootProbe.frames["passage:\(world.garden)"] != nil })
            await settle(until: { false }, seconds: 0.3)
            #expect(Set(model.trash.map(\.id)) == [world.garden, world.pie, world.book, world.crumble])

            let fieldAfter = try #require(TrashFootProbe.frames["field"])
            #expect(abs(fieldAfter.minX - fieldBefore.minX) < 0.5 && abs(fieldAfter.width - fieldBefore.width) < 0.5
                    && abs(fieldAfter.minY - fieldBefore.minY) < 0.5,
                    "typing never moved the field (\(fieldBefore) → \(fieldAfter))")
            let pieAfter = try #require(TrashFootProbe.frames["row:\(world.pie)"])
            #expect(abs(pieAfter.minX - pieBefore.minX) < 0.5 && abs(pieAfter.width - pieBefore.width) < 0.5,
                    "a row's own measure never moves (\(pieBefore) → \(pieAfter))")
            let passage = try #require(TrashFootProbe.frames["passage:\(world.garden)"], "the passage line is drawn")
            let row = try #require(TrashFootProbe.frames["row:\(world.garden)"])
            #expect(row.contains(CGPoint(x: passage.midX, y: passage.midY)), "inside its row's card (\(passage) in \(row))")
            #expect(passage.minY > row.minY + 8, "under the row's line, never beside it")
            #expect(TrashFootProbe.frames["passage:\(world.pie)"] == nil, "a title match carries none")

            fieldEditor.doCommand(by: #selector(NSResponder.cancelOperation(_:)))
            #expect(model.searchText.isEmpty, "esc clears")
            #expect(!model.isSearching)
            await settle(until: { model.trash.count == 6 && model.trashListingLoaded })
            #expect(model.trash.count == 6, "the Trash is whole again")
            #expect(found.stringValue.isEmpty)
        }
    }

    /// **The pick is pruned to the rows the search shows** — by the view's
    /// own wiring (`.onChange(of: visibleRowIDs)`), exactly as the kind filter
    /// prunes it. (Fails if a row the search hid stays picked — a bulk bar
    /// acting on rows nothing on screen highlights.)
    @Test func theSelectionIsPrunedToTheRowsTheSearchShows() async throws {
        try await withEditor { editor in
            let world = try await TrashWorld.make(editor)
            let model = RecoveryViewModel(session: editor.session)
            let window = mount(editor, model: model)
            defer { window.orderOut(nil); window.close() }
            await settle(until: { model.trash.count == 6 })
            let order = RecoveryView.visibleRowIDs(TrashGrouping.entries(model.trash), collapsed: [])
            model.clickRow(world.garden, modifiers: .none, order: order)
            model.clickRow(world.apple, modifiers: .command_, order: order)
            #expect(model.selectedRows == [world.garden, world.apple])

            model.editSearch("rhubarb")
            model.askSearchNow()
            await settle(until: { model.trash.count == 4 && model.trashListingLoaded })
            await settle(until: { model.selectedRows.count == 1 }, seconds: 2)
            #expect(model.selectedRows == [world.garden], "the hidden row left the pick; the shown one stayed")
        }
    }
}
