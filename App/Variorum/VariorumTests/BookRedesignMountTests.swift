//
//  BookRedesignMountTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 2c, item 18 (W8-5) — the two redesigned book
//  surfaces MOUNTED in a real hosted window, because their brains are
//  pinned pure (`BookIndexColumnTests`) but a brain pin cannot prove the
//  view stands up. What these hold, both P-3's letter:
//
//  · the INDEX book view hosts with real chapters and ZERO live editors
//    AT REST — no full-document editor, and (since the correction round,
//    row 22) no live pane either until a block is clicked: the pane is
//    read-cheap until her act (`BookIndexEditingTests` pins the upgrade);
//  · the OUTLINE details gutter's focused form — `EditorView` with
//    `barPlacement: .side` wrapping `CommitBar(axis: .vertical)` — mounts
//    exactly ONE live editor for the focused note. This is the one road
//    commit `9b740de` reshaped that only a hosting can execute.
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
private func withChapteredBook<T>(
    posts: Int,
    _ body: @MainActor (AppSession, AppDatabase, _ readingID: String, _ postIDs: [String]) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 18))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "the redesign", kind: .curated)
        var postIDs: [String] = []
        for p in 0..<posts {
            let post = try session.operations.createPost(title: "note \(p)")
            _ = try session.operations.newBlock(
                in: post.id,
                text: "Prose of note \(p), long enough to excerpt and to carry "
                    + "a second sentence that reads like real writing.")
            try session.operations.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        // Two real chapters; the last post stays unfiled (the trailing
        // "unfiled" group the column renders).
        let one = try session.operations.createSection(in: reading.id, name: "one")
        let two = try session.operations.createSection(in: reading.id, name: "two")
        for (i, postID) in postIDs.enumerated() where i < posts - 1 {
            try session.operations.assignPostToSection(
                postID, in: reading.id, section: i % 2 == 0 ? one.id : two.id)
        }
        return try await body(session, db, reading.id, postIDs)
    }
}

@MainActor
private func countEditablePanes(in view: NSView) -> Int {
    var count = (view as? PaneTextView)?.isEditable == true ? 1 : 0
    for sub in view.subviews { count += countEditablePanes(in: sub) }
    return count
}

@MainActor
private func countLiveEditorViews(in view: NSView) -> Int {
    var count = view is EditorTextView ? 1 : 0
    for sub in view.subviews { count += countLiveEditorViews(in: sub) }
    return count
}

@MainActor
@Suite("The book redesign mounts (pre-13u Act 10 wave 2c, item 18)", .serialized)
struct BookRedesignMountTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 40
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

    private func mounted(
        session: AppSession, readingID: String,
        model: BookViewModel, structure: BookStructureModel
    ) -> (NSWindow, NSHostingView<BookView>) {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1200, height: 800),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: BookView(
                session: session, readingID: readingID,
                model: model, structure: structure))
        hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    private func loadedStructure(
        session: AppSession, db: AppDatabase, readingID: String
    ) async throws -> BookStructureModel {
        let structure = BookStructureModel(session: session, readingID: readingID)
        structure.adopt(.init(
            reading: try await db.read { [readingID] in
                try Queries.reading($0, id: readingID)
            },
            sections: try await db.read { [readingID] in
                try Queries.readingSections($0, readingID: readingID)
            },
            deletedSections: [],
            assignments: try await db.read { [readingID] in
                try Queries.sectionAssignments($0, readingID: readingID)
            }))
        return structure
    }

    @Test func theIndexBookViewMountsChapteredWithZeroLiveEditors() async throws {
        try await withChapteredBook(posts: 4) { session, db, readingID, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(
                session: session, db: db, readingID: readingID)
            #expect(structure.chaptersActive, "the world really has chapters")
            structure.mode = .index

            let (window, hosting) = mounted(
                session: session, readingID: readingID,
                model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, until: { false }, maxTurns: 6)

            #expect(structure.mode == .index, "the mode survived the mount")
            #expect(countLiveEditorViews(in: hosting) == 0,
                    "no full-document editor mounts in the index (P-3)")
            #expect(countEditablePanes(in: hosting) == 0,
                    "and at rest no block is live — the pane is read-cheap until she clicks a block (row 22)")
        }
    }

    @Test func theOutlineGutterMountsTheOneSideBarEditor() async throws {
        try await withChapteredBook(posts: 3) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(
                session: session, db: db, readingID: readingID)
            #expect(structure.mode == .outline, "a curated book opens in Outline")

            let (window, hosting) = mounted(
                session: session, readingID: readingID,
                model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, until: { false }, maxTurns: 4)
            #expect(countLiveEditorViews(in: hosting) == 0, "cards at rest")

            // Focus a note: the ONE live editor mounts through the NEW
            // road — `barPlacement: .side`, the gutter's vertical bar.
            model.focus(postIDs[0])
            await settle(window, hosting, until: { countLiveEditorViews(in: hosting) == 1 })
            #expect(countLiveEditorViews(in: hosting) == 1,
                    "the focused note's editor mounted beside its gutter bar — one live editor, exactly (P-3)")

            // And it releases like every other host of the one authority.
            model.collapse(postIDs[0])
            await settle(window, hosting, until: { countLiveEditorViews(in: hosting) == 0 })
            #expect(countLiveEditorViews(in: hosting) == 0,
                    "collapse releases the editor — the side placement changed the bar's axis, never the liveness law")
        }
    }
}
