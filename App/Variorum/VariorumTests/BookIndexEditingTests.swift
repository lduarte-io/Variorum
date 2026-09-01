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
        let reading = try session.operations.createReading(name: "the index", kind: .curated)
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

    /// Row 22: a landing on note 1's THIRD block makes exactly that block
    /// live — one editable pane in the whole book — and a second landing
    /// on another note MIGRATES the ring rather than adding one.
    @Test func aLandingMakesTheNamedBlockTheOneLivePaneAndASecondMigratesIt() async throws {
        try await withIndexBook { session, db, readingID, postIDs, blocks in
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
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
            model.adopt(try await db.read { [readingID] in
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
}
