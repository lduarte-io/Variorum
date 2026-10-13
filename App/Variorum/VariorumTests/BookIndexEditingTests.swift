//
//  BookIndexEditingTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch B — rows 22 + 38 (R-cor-7): the book
//  Index EDITS IN PLACE through ONE liveness authority, and a Read ▸ Scroll
//  click lands in it at THAT block (the scrolled-open door, `LandingTarget`).
//
//  What is pinned: after a landing, exactly ONE editable pane exists in the
//  hosted book and it is the named block's take (P-3's invariant, counted
//  in the NSView tree by the pane's `pane:<role>|<variant>` identifier); a
//  second landing MIGRATES the ring (still one); the model's overlay and
//  flush choreography. Red-on-old: the pre-round index mounted no editable
//  pane at all (the double-click handed off to Outline), so every landing
//  expectation below is red there by construction — and
//  `BookRedesignMountTests` keeps the at-rest half (zero live, until a click).
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
private func withIndexBook<T>(
    _ body: @MainActor (
        AppSession, AppDatabase, _ readingID: String,
        _ postIDs: [String], _ blocks: [String: [(blockID: String, variantID: String)]]
    ) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 22))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "the index", kind: .book)
        var postIDs: [String] = []
        var blocks: [String: [(blockID: String, variantID: String)]] = [:]
        for p in 0..<5 {
            let post = try session.operations.createPost(title: "note \(p)")
            var made: [(String, String)] = []
            for b in 0..<3 {
                let block = try session.operations.newBlock(
                    in: post.id, text: "Block \(b) of note \(p) — a sentence of prose to read.")
                made.append((block.block.id, block.variant.id))
            }
            blocks[post.id] = made
            try session.operations.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        let one = try session.operations.createSection(in: reading.id, name: "one")
        let two = try session.operations.createSection(in: reading.id, name: "two")
        for (i, postID) in postIDs.enumerated() {
            try session.operations.assignPostToSection(
                postID, in: reading.id, section: i < 3 ? one.id : two.id)
        }
        return try await body(session, db, reading.id, postIDs, blocks)
    }
}

@MainActor
private func editablePanes(in view: NSView) -> [PaneTextView] {
    var out: [PaneTextView] = []
    if let pane = view as? PaneTextView, pane.isEditable { out.append(pane) }
    for sub in view.subviews { out += editablePanes(in: sub) }
    return out
}

@MainActor
@Suite("The book Index edits in place (Act 10 correction round, rows 22 + 38)", .serialized)
struct BookIndexEditingTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 60
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private func loadedStructure(
        session: AppSession, db: AppDatabase, readingID: String
    ) async throws -> BookStructureModel {
        let structure = BookStructureModel(session: session, readingID: readingID)
        structure.adopt(.init(
            reading: try await db.read { [readingID] in try Queries.reading($0, id: readingID) },
            sections: try await db.read { [readingID] in
                try Queries.readingSections($0, readingID: readingID)
            },
            deletedSections: [],
            assignments: try await db.read { [readingID] in
                try Queries.sectionAssignments($0, readingID: readingID)
            }))
        return structure
    }

    private func mounted(
        session: AppSession, readingID: String,
        model: BookViewModel, structure: BookStructureModel
    ) -> (NSWindow, NSHostingView<BookView>) {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1200, height: 760),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: BookView(
                session: session, readingID: readingID, model: model, structure: structure))
        hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 760)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    private func paneIdentifier(_ variantID: String) -> String {
        "pane:\(BookIndexEditModel.columnID)|\(variantID)"
    }

    /// **Row 21 — the chapter count and the row ⋯ end in one column.** Her
    /// punchlist 5 (image 7): *"the number of notes per chapter should be
    /// better aligned with the ⋯ menu."* The chapter row's count was a bare
    /// `Text` flush against the row's trailing padding; the note row's
    /// `Menu` (`.borderlessButton`) reserved room for a disclosure chevron,
    /// so its ⋯ sat inboard of the count above it. Both now end in
    /// `BookIndexColumn.trailingColumn`, and the chevron is hidden.
    ///
    /// (Pinned HERE rather than in `BookIndexColumnTests`, which the brief
    /// names: that suite is pure column logic with no mount, and a claim
    /// about two rectangles needs the real rows on screen — this file owns
    /// the book mount.)
    ///
    /// **The pin had to be re-shaped once, and the first shape is recorded
    /// because it was HOLLOW:** comparing the two views' trailing edges
    /// passes on both trees (measured — count `maxX` 282.0, menu `maxX`
    /// 282.0 before the fix). The chevron is drawn INSIDE the menu's own
    /// control, so the boxes always ended together and only the GLYPH sat
    /// inboard. The claim that can see it is the control's WIDTH: 28 pt for
    /// ⋯-plus-chevron against the 22-pt column both rows now end in.
    ///
    /// RED ON OLD: the note menu's control measures wider than the trailing
    /// column, because it is reserving room to the right of its ⋯.
    @Test func theChapterCountAndTheRowMenuEndInOneTrailingColumn() async throws {
        try await withIndexBook { session, db, readingID, _, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            structure.mode = .index
            #if DEBUG
            BookIndexGeometry.reset()
            #endif
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            #if DEBUG
            await settle(window, hosting, until: {
                BookIndexGeometry.chapterCountFrame != nil
                    && BookIndexGeometry.noteMenuFrame != nil
            })
            await settle(window, hosting, until: { false }, maxTurns: 6)
            let count = try #require(BookIndexGeometry.chapterCountFrame,
                                     "a chapter row reported its count")
            let menu = try #require(BookIndexGeometry.noteMenuFrame,
                                    "a note row reported its ⋯")
            print("[17o d row 21] count \(count) · menu \(menu)")
            #expect(count.width > 0 && menu.width > 0)
            #expect(menu.width <= BookIndexColumn.trailingColumn,
                    "the ⋯ control reserves no room to its right — 28.0 with the chevron, now \(menu.width)")
            #expect(abs(count.maxX - menu.maxX) <= 1,
                    "…and both end in the one column: count \(count.maxX), ⋯ \(menu.maxX)")
            #endif
        }
    }

    /// **VX-223 — the note row's ⋯ pops at menu size** (the class her report
    /// names — "several dropdowns that are too small that start with three
    /// dots"). The row's ⋯ carried `.controlSize(.mini)` on the Menu itself,
    /// so its popped rows drew at the mini 9 pt. RED ON OLD by that
    /// mechanism; the class lives in `ChromeMenuRowSizeTests`. The row-21
    /// geometry above must hold unchanged with the fix (the control stays
    /// 15 pt wide — the mini metric rides the label now).
    @Test func theNoteRowMenuPopsAtMenuSize() async throws {
        try await withIndexBook { session, db, readingID, _, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            structure.mode = .index
            #if DEBUG
            BookIndexGeometry.reset()
            #endif
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            #if DEBUG
            await settle(window, hosting, until: { BookIndexGeometry.noteMenuFrame != nil })
            #endif
            await settle(window, hosting, until: { false }, maxTurns: 6)
            let sizes = ChromeMenuProbe.rowSizes(in: hosting)
            #expect(sizes.count >= 5, "every note row's ⋯ is a pop-up underneath (\(sizes))")
            #expect(sizes.allSatisfy { $0 >= ChromeMenuProbe.menuSize },
                    "every popped row reads at menu size, never mini: \(sizes)")
        }
    }

    /// Row 22: a landing on note 1's THIRD block makes exactly that block
    /// live — one editable pane in the whole book — and a second landing
    /// on another note MIGRATES the ring rather than adding one.
    @Test func aLandingMakesTheNamedBlockTheOneLivePaneAndASecondMigratesIt() async throws {
        try await withIndexBook { session, db, readingID, postIDs, blocks in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            structure.mode = .index
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, until: { false }, maxTurns: 6)
            #expect(editablePanes(in: hosting).isEmpty, "read-cheap at rest")

            let target = blocks[postIDs[1]]![2]
            model.requestLanding(LandingTarget(postID: postIDs[1], blockID: target.blockID))
            await settle(window, hosting, until: { editablePanes(in: hosting).count == 1 })
            let live = editablePanes(in: hosting)
            #expect(live.count == 1, "exactly one live pane in the whole book: \(live.count)")
            #expect(live.first?.identifier?.rawValue == paneIdentifier(target.variantID),
                    "…and it is the named block's take")
            #expect(model.pendingLanding == nil, "the landing was consumed")

            // The second landing: the ring MIGRATES (P-3 — never two).
            let next = blocks[postIDs[3]]![0]
            model.requestLanding(LandingTarget(postID: postIDs[3], blockID: next.blockID))
            await settle(window, hosting, until: {
                editablePanes(in: hosting).first?.identifier?.rawValue == paneIdentifier(next.variantID)
            })
            let after = editablePanes(in: hosting)
            #expect(after.count == 1, "still exactly one: \(after.count)")
            #expect(after.first?.identifier?.rawValue == paneIdentifier(next.variantID))
        }
    }

    /// Row 38's door, exactly what the Read ▸ Scroll click does: request
    /// the landing, switch to Index — and the index arrives at that block,
    /// live. (A landing with NO block names the note's first block.)
    @Test func theReadClickLandsInIndexAtThatBlock() async throws {
        try await withIndexBook { session, db, readingID, postIDs, blocks in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            structure.mode = .read
            structure.readForm = .flow
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, until: { false }, maxTurns: 6)

            // What `BookView`'s flow `onWake` does, exactly.
            let target = blocks[postIDs[4]]![1]
            model.requestLanding(LandingTarget(postID: postIDs[4], blockID: target.blockID))
            structure.mode = .index
            await settle(window, hosting, until: { editablePanes(in: hosting).count == 1 })
            #expect(structure.mode == .index)
            let live = editablePanes(in: hosting)
            #expect(live.count == 1)
            #expect(live.first?.identifier?.rawValue == paneIdentifier(target.variantID),
                    "the Read click's block is the live one — not the top, not the last")

            // A block-less landing (a title click) lands the note's FIRST block.
            model.requestLanding(LandingTarget(postID: postIDs[0]))
            let first = blocks[postIDs[0]]![0]
            await settle(window, hosting, until: {
                editablePanes(in: hosting).first?.identifier?.rawValue == paneIdentifier(first.variantID)
            })
            #expect(editablePanes(in: hosting).first?.identifier?.rawValue == paneIdentifier(first.variantID))
        }
    }

    /// The model alone: one ring over several posts; the overlay; the
    /// landing that waits for rows; blur releases.
    /// Ladder R1-8: a model reused after a `teardown` re-subscribes to its
    /// coordinator's refusals — the old teardown kept the coordinators
    /// cached with their observers gone, so a later refusal went unheard.
    /// RED ON OLD: nothing spoken after the teardown.
    @Test func aModelReusedAfterATeardownStillHearsItsCoordinatorsRefusals() async throws {
        try await withIndexBook { session, _, _, postIDs, blocks in
            let edit = BookIndexEditModel(session: session)
            let a = blocks[postIDs[0]]![0]
            edit.makeLive(postID: postIDs[0], blockID: a.blockID, variantID: a.variantID)
            edit.teardown()

            // Reused: an edit on a take the store does not hold — the
            // coordinator's flush refuses, and the model must HEAR it.
            session.status.clear()
            edit.makeLive(postID: postIDs[0], blockID: a.blockID, variantID: a.variantID)
            edit.paneEdited(postID: postIDs[0], variantID: "no-such-take", oldText: "", newText: "typed")
            await session.autosave(forPost: postIDs[0]).flushNow()
            #expect(session.status.current != nil,
                    "the refusal after a teardown is reported — the model re-subscribed")
            edit.teardown()
        }
    }

    @Test func theEditModelHoldsOneRingAcrossPostsAndOverlaysTheBuffer() async throws {
        try await withIndexBook { session, _, _, postIDs, blocks in
            let edit = BookIndexEditModel(session: session)
            let a = blocks[postIDs[0]]![0]
            let b = blocks[postIDs[2]]![1]
            edit.makeLive(postID: postIDs[0], blockID: a.blockID, variantID: a.variantID)
            #expect(edit.liveBlockID == a.blockID)
            #expect(edit.livePostID == postIDs[0])
            edit.makeLive(postID: postIDs[2], blockID: b.blockID, variantID: b.variantID)
            #expect(edit.liveBlockID == b.blockID, "the ring migrated across posts")
            #expect(!edit.isLive(postID: postIDs[0], blockID: a.blockID, variantID: a.variantID))

            edit.paneEdited(postID: postIDs[2], variantID: b.variantID, oldText: "old", newText: "old and new")
            #expect(edit.displayText(variantID: b.variantID, storeText: "old") == "old and new",
                    "a dirty pane is buffer-authoritative")

            // A landing that arrives before rows: taken on the note's adopt.
            let c = blocks[postIDs[4]]![2]
            edit.requestLiveBlock(LandingTarget(postID: postIDs[4], blockID: c.blockID))
            #expect(edit.takePendingLiveBlock(postID: postIDs[1], rows: []) == nil,
                    "another note's adopt does not take it")
            let rows = blocks[postIDs[4]]!.map {
                Queries.TOCRow(
                    blockID: $0.blockID, placementID: "pl", name: nil,
                    variantID: $0.variantID, text: "t", hasFan: false, variantLocked: false)
            }
            #expect(edit.takePendingLiveBlock(postID: postIDs[4], rows: rows) == c.blockID)
            #expect(edit.liveBlockID == c.blockID)
            #expect(edit.pendingLiveBlock == nil, "consumed once")

            edit.blur()
            #expect(edit.liveBlockID == nil)
            edit.teardown()
        }
    }

    // MARK: - 13u2 UNIT B — her item 19 (R-13u-10), the book Index's presentation

    /// **(a) THE WHOLE NOTE NO LONGER TAKES THE WASH.** Her words, verbatim:
    /// *"in index, even when I have a color mode on I don't want the whole
    /// note i'm editing to be that color, it's too much."* The selected note
    /// is still marked — its TITLE line takes the same wash the column's own
    /// row does — and the mark is a row, not a slab the prose is read through.
    ///
    /// Two measured rectangles, because that is what the claim is about.
    /// RED ON OLD: the washed rectangle IS the note's rectangle (the
    /// background sat on the note's whole `VStack`), so the ratio is 1.
    /// Measured after: **25.0 pt of a 152.0-pt note.**
    @Test func theSelectedNotesWashMarksItsTitleNotItsWholeBody() async throws {
        try await withIndexBook { session, db, readingID, postIDs, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            structure.mode = .index
            #if DEBUG
            BookIndexGeometry.reset()
            #endif
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            #if DEBUG
            // The arrival seed selects the first note.
            let first = postIDs[0]
            await settle(window, hosting, until: {
                BookIndexGeometry.paneSelectionWashHeights[first] != nil
                    && (BookIndexGeometry.paneNoteHeights[first] ?? 0) > 0
            })
            await settle(window, hosting, until: { false }, maxTurns: 6)
            let wash = try #require(BookIndexGeometry.paneSelectionWashHeights[first],
                                    "the selected note reported its wash")
            let note = try #require(BookIndexGeometry.paneNoteHeights[first],
                                    "…and its own height")
            print("[13u2 B a] wash \(wash) of note \(note)")
            #expect(note > 100, "the fixture's note is several blocks tall: \(note)")
            #expect(wash < note / 3,
                    "the wash marks a line, not the note: \(wash) of \(note)")
            #endif
        }
    }

    /// **(c) CLICKING INTO A BLOCK DOES NOT MOVE ITS PROSE.** Her words:
    /// *"the text indents in index mode where you're editing it, which should
    /// not be happening the second you click into a block."*
    ///
    /// One x, measured the same way in both tiers (`BookIndexGeometry`
    /// .paneProseLeading): the read tier reports its text column's own
    /// leading edge; the live tier reports its pane's, plus the pane's
    /// MEASURED internal inset. RED ON OLD: the two differ by
    /// `PaneTextView.proseLeadingInset` — 11 pt on this machine — because
    /// both tiers were padded the same and only one of them has an inset.
    @Test func clickingIntoABlockDoesNotMoveItsProseSideways() async throws {
        try await withIndexBook { session, db, readingID, postIDs, blocks in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            structure.mode = .index
            #if DEBUG
            BookIndexGeometry.reset()
            #endif
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            #if DEBUG
            let target = blocks[postIDs[0]]![1]
            await settle(window, hosting, until: {
                BookIndexGeometry.paneProseLeading[target.blockID] != nil
            })
            await settle(window, hosting, until: { false }, maxTurns: 6)
            let atRest = try #require(BookIndexGeometry.paneProseLeading[target.blockID],
                                      "the read tier reported where its prose starts")

            model.requestLanding(LandingTarget(postID: postIDs[0], blockID: target.blockID))
            await settle(window, hosting, until: { editablePanes(in: hosting).count == 1 })
            await settle(window, hosting, until: { false }, maxTurns: 8)
            let live = try #require(BookIndexGeometry.paneProseLeading[target.blockID],
                                    "the live pane reported where its prose starts")
            print("[13u2 B c] rest \(atRest) · live \(live) · inset \(PaneTextView.proseLeadingInset)")
            #expect(PaneTextView.proseLeadingInset > 0,
                    "a pane really does inset its own prose — the defect's whole cause")
            #expect(abs(live - atRest) <= 1,
                    "the prose did not move: rest \(atRest), live \(live)")
            #endif
        }
    }

    // **(d) THE BOOK INDEX'S COLUMN — DISMISSED AS HOLLOW, and recorded.**
    // A pin was written here asserting that a LANDING on another note moves
    // the column's mark to it. It passes on the PRE-FIX tree: `landOrSeed`
    // already selects the revealed note before its pane makes a block live,
    // and the row's own tap selects too — so in this column, whose rows are
    // NOTES, the mark already follows the ring by every road there is. The
    // defect she reported is the NOTE surface's column, whose rows are
    // BLOCKS; its pin is `ReadModeTests.theIndexColumnMarksTheBlockTheCursorIsIn`.
    // (The follow that WAS added here is gone with the pin — it also tore the
    // index's state down; `BookIndexView` carries the measurement.)

}
