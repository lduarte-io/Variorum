//
//  OwnershipBadgeTests.swift
//  VariorumTests
//
//  13i-c U4 — THE BADGE FAMILY (the sitting record §6: "direction ruled;
//  toggleable as a set; silence the common case"), the navigator's SEALED
//  chip (F-U3-7), and the two ownership Settings rows.
//
//  What is pinned: the RULE (inside a book the shared mark, outside the
//  owned-by mark; a free note — or a note whose only book is this one —
//  nothing; the setting off silences the set); the WORDS; the FACTS read
//  page-driven; the MOUNTED book view drawing the shared mark on its Index
//  row and a gathering's view drawing the owned-by mark (the direction);
//  the chip's sealed face; the Settings catalog naming both rows where the
//  Editor pane renders them.
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
private func withBadgeWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 59))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private func pump(_ seconds: TimeInterval) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

/// Mounts the book view in `mode` with its models loaded by hand (hosted
/// `.task` callbacks do not fire under the test host), then settles until
/// `done` holds.
@MainActor
private func mountBook(
    _ session: AppSession, _ db: AppDatabase, readingID: String,
    ownership: OwnershipFactsModel, until done: () -> Bool
) async throws {
    let model = BookViewModel(session: session, readingID: readingID)
    await model.adopt(try await db.read { try Queries.assembleReading($0, readingID: readingID) })
    let structure = BookStructureModel(session: session, readingID: readingID)
    structure.adopt(.init(
        reading: try await db.read { try Queries.reading($0, id: readingID) },
        sections: [], deletedSections: [], assignments: [:]))
    structure.mode = .index
    let window = NSWindow(
        contentRect: NSRect(x: 60, y: 60, width: 1300, height: 820),
        styleMask: [.titled], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    defer {
        window.orderOut(nil)
        window.close()
    }
    let hosting = NSHostingView(rootView: BookView(
        session: session, readingID: readingID,
        model: model, structure: structure, ownership: ownership))
    hosting.frame = NSRect(x: 0, y: 0, width: 1300, height: 820)
    window.contentView = hosting
    window.makeKeyAndOrderFront(nil)
    for _ in 0..<40 where !done() {
        hosting.layoutSubtreeIfNeeded()
        window.displayIfNeeded()
        pump(0.03)
        await Task.yield()
    }
}

@MainActor
@Suite("The badge family (13i-c U4)", .serialized)
struct OwnershipBadgeTests {
    @Test func theRuleMarksSharedInsideAndOwnedOutsideAndSilencesTheCommonCase() {
        let a = Queries.BookRef(id: "a", name: "A")
        let b = Queries.BookRef(id: "b", name: "B")
        let shared = Queries.OwnershipFacts(ownedBy: nil, otherBooks: [b])
        let owned = Queries.OwnershipFacts(ownedBy: a, otherBooks: [a])
        typealias Face = OwnershipBadgeFace
        // INSIDE a book: the shared mark, naming the other books.
        #expect(Face.badge(shared, placement: .inBook, badgesOn: true) == .shared(["B"]))
        // OUTSIDE: the owned-by mark — and a merely shared note says nothing.
        #expect(Face.badge(owned, placement: .outside, badgesOn: true) == .ownedBy(a))
        #expect(Face.badge(shared, placement: .outside, badgesOn: true) == nil)
        // A free note (absent from the facts): nothing, ever.
        #expect(Face.badge(nil, placement: .inBook, badgesOn: true) == nil)
        #expect(Face.badge(nil, placement: .outside, badgesOn: true) == nil)
        // The one switch silences the set (P-13ic-10).
        #expect(Face.badge(shared, placement: .inBook, badgesOn: false) == nil)
        #expect(Face.badge(owned, placement: .outside, badgesOn: false) == nil)
        // The words.
        #expect(OwnershipBadgeCopy.ownedBy("A") == "owned by \u{201C}A\u{201D}")
        #expect(OwnershipBadgeCopy.sharedHelp(["B", "C"]).hasPrefix(
            "Also in \u{201C}B\u{201D} and \u{201C}C\u{201D}"))
        // The owned-by click-through is the ascent's third renderer.
        #expect(OwnershipBadgeView.surfaceCapabilities == [.openBookAtNote])
    }

    @Test func theFactsArePageDrivenAndExcludeTheBookBeingViewed() async throws {
        try await withBadgeWorld { session, _ in
            let ops = session.operations
            let a = try ops.createReading(name: "A", kind: .book)
            let b = try ops.createReading(name: "B", kind: .book)
            let mine = try ops.createReading(name: "Mine", kind: .book)
            try ops.setReadingOwned(mine.id, owned: true)
            let both = try ops.createPost(title: "both")
            _ = try ops.addPostToReading(both.id, to: a.id)
            _ = try ops.addPostToReading(both.id, to: b.id)
            let claimed = try ops.createPost(title: "claimed")
            _ = try ops.addPostToReading(claimed.id, to: mine.id)
            let free = try ops.createPost(title: "free")

            let model = OwnershipFactsModel()
            await model.load(
                session: session, postIDs: [both.id, claimed.id, free.id], inBook: a.id)
            #expect(model.badge(for: both.id, placement: .inBook, badgesOn: true) == .shared(["B"]))
            #expect(model.badge(for: free.id, placement: .inBook, badgesOn: true) == nil)
            await model.load(
                session: session, postIDs: [both.id, claimed.id, free.id], inBook: nil)
            #expect(model.badge(for: claimed.id, placement: .outside, badgesOn: true)
                    == .ownedBy(Queries.BookRef(id: mine.id, name: "Mine")))
            #expect(model.badge(for: both.id, placement: .outside, badgesOn: true) == nil)
        }
    }

    @Test func theBookViewMarksASharedNoteOnItsIndexRow() async throws {
        OwnershipBadgeProbe.reset()
        try await withBadgeWorld { session, db in
            let ops = session.operations
            let a = try ops.createReading(name: "A", kind: .book)
            let b = try ops.createReading(name: "B", kind: .book)
            let both = try ops.createPost(title: "both")
            let sole = try ops.createPost(title: "sole")
            for n in [both, sole] { _ = try ops.addPostToReading(n.id, to: a.id) }
            _ = try ops.addPostToReading(both.id, to: b.id)
            let ownership = OwnershipFactsModel()
            await ownership.load(session: session, postIDs: [both.id, sole.id], inBook: a.id)
            try await mountBook(session, db, readingID: a.id, ownership: ownership) {
                OwnershipBadgeProbe.drawn[both.id] != nil
            }
            #expect(OwnershipBadgeProbe.drawn[both.id] == .shared(["B"]),
                    "inside a book: the shared mark, naming the other book")
            #expect(OwnershipBadgeProbe.drawn[sole.id] == nil, "a note only here wears nothing")
        }
    }

    @Test func aGatheringsViewMarksTheOwnedNoteOwnedBy() async throws {
        OwnershipBadgeProbe.reset()
        try await withBadgeWorld { session, db in
            let ops = session.operations
            let tag = try ops.createTag(name: "t")
            let gathering = try ops.createReading(
                name: "G", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let mine = try ops.createReading(name: "Mine", kind: .book)
            try ops.setReadingOwned(mine.id, owned: true)
            let claimed = try ops.createPost(title: "claimed")
            _ = try ops.addPostToReading(claimed.id, to: mine.id)
            _ = try ops.applyTag(tag.id, toPost: claimed.id)
            let ownership = OwnershipFactsModel()
            await ownership.load(session: session, postIDs: [claimed.id], inBook: gathering.id)
            try await mountBook(session, db, readingID: gathering.id, ownership: ownership) {
                OwnershipBadgeProbe.drawn[claimed.id] != nil
            }
            #expect(OwnershipBadgeProbe.drawn[claimed.id]
                    == .ownedBy(Queries.BookRef(id: mine.id, name: "Mine")),
                    "a gathering is OUTSIDE every book: the owned-by mark")
        }
    }

    @Test func theNavigatorChipSaysSealedOnASealedBook() {
        #expect(BookStateCopy.navigatorChip(finished: false, sealed: false) == nil)
        #expect(BookStateCopy.navigatorChip(finished: true, sealed: false) == "\u{2713} finished")
        #expect(BookStateCopy.navigatorChip(finished: true, sealed: true) == "\u{2713} sealed")
    }

    @Test func theTwoSettingsRowsAreWhereTheEditorPaneRendersThem() {
        #expect(SettingsCatalog.title("ownershipBadges") == OwnershipSettingsCopy.badgesTitle)
        #expect(SettingsCatalog.title("hideOwnedDefault") == OwnershipSettingsCopy.hideOwnedTitle)
        let editor = AppSettingsView.rowIDsRendered[.editor] ?? []
        #expect(editor.contains("ownershipBadges") && editor.contains("hideOwnedDefault"))
        // The truths the help must not overclaim.
        #expect(OwnershipSettingsCopy.hideOwnedHelp.contains("The Library always shows everything"))
        #expect(OwnershipSettingsCopy.badgesHelp.contains("nothing else changes"))
    }
}
