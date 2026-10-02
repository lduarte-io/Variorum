//
//  BookIndexGroupingTests.swift
//  VariorumTests
//
//  13i-d U3 — THE GROUPED-BY CONTROL on the book Index's masthead (the
//  sitting record §17(f), ruled: "chapters ▾ · a tag family… · none;
//  view-local; a gathering's Index the same minus chapters") and THE
//  TAG-FAMILY GROUPED DISPLAY (§3: "never real chapters").
//
//  What is pinned:
//  - the choice is REMEMBERED per book in a LOCAL store (a scratch suite —
//    never her `.standard` domain), three ways;
//  - the menu's options per book: chapters only where a book has them, the
//    families its notes wear, none (a gathering — minus chapters);
//  - the partition rule (children A–Z, the book's order kept, "other"
//    trailing) and the fallbacks (a choice that cannot apply draws the
//    shipped look);
//  - DISPLAY ONLY: grouping a book or a gathering by a family writes nothing
//    — no `reading_section` row, no outbox row — while the held read files
//    every note.
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
private func withGroupingWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 37))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// A scratch defaults suite (never `.standard` — the test host IS the Debug
/// app, whose domain is her dev store's preferences).
private func scratchDefaults(_ name: String = #function) -> UserDefaults {
    let suite = "io.lduarte.Variorum.tests.grouping.\(name)"
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    return defaults
}

private func entry(_ id: String) -> Queries.ReadingEntry {
    Queries.ReadingEntry(postID: id, title: id, entryDate: nil, sectionPath: nil)
}

private func tag(_ id: String, _ path: String, wing: String = "") -> VariorumCore.Tag {
    let now = Date(timeIntervalSince1970: 0)
    return VariorumCore.Tag(
        id: id, parentId: nil, name: String(path.split(separator: "/").last ?? ""),
        path: path, wingId: wing, createdAt: now, updatedAt: now)
}

@MainActor
private func settle(within seconds: Double = 3, _ condition: () -> Bool) async throws {
    let deadline = Date().addingTimeInterval(seconds)
    while Date() < deadline {
        if condition() { return }
        try await Task.sleep(nanoseconds: 10_000_000)
    }
    #expect(condition(), "condition never settled")
}

@MainActor
@Suite("The Index's grouped-by control (13i-d U3)", .serialized)
struct BookIndexGroupingTests {
    // MARK: - Remembered, view-local

    @Test func theChoiceIsRememberedPerBookThreeWays() {
        #expect(BookIndexGrouping(stored: "chapters") == .chapters)
        #expect(BookIndexGrouping(stored: "none") == BookIndexGrouping.none)
        #expect(BookIndexGrouping(stored: "tag:abc") == .tagFamily("abc"))
        #expect(BookIndexGrouping(stored: "tag:") == nil)
        #expect(BookIndexGrouping(stored: "garbage") == nil)
        for choice: BookIndexGrouping in [.chapters, .none, .tagFamily("t1")] {
            #expect(BookIndexGrouping(stored: choice.stored) == choice)
        }

        let defaults = scratchDefaults()
        let first = BookIndexGroupingModel(readingID: "book-1", defaults: defaults)
        #expect(first.choice == nil, "never chosen ⇒ the shipped look")
        first.choose(.tagFamily("t1"))
        let other = BookIndexGroupingModel(readingID: "book-2", defaults: defaults)
        other.choose(.none)
        // A fresh model (the Index reopened) remembers each book's own.
        #expect(BookIndexGroupingModel(readingID: "book-1", defaults: defaults).choice
                == .tagFamily("t1"))
        #expect(BookIndexGroupingModel(readingID: "book-2", defaults: defaults).choice
                == BookIndexGrouping.none)
        first.choose(.chapters)
        #expect(BookIndexGroupingModel(readingID: "book-1", defaults: defaults).choice == .chapters)
    }

    // MARK: - The menu's options

    /// Families = live tags of the book's wing that are a proper ancestor of
    /// a worn tag; chapters only where a book has them (a gathering's Index
    /// "the same minus chapters"); none always.
    @Test func theOptionsAreChaptersWhereTheyExistTheWornFamiliesAndNone() {
        let status = tag("s", "status")
        let draft = tag("d", "status/draft")
        let topic = tag("t", "topic")
        let deep = tag("x", "topic/ideas/wild")
        let ideas = tag("i", "topic/ideas")
        let away = tag("w", "status", wing: "other-wing")
        let live = [status, draft, topic, deep, ideas, away]
        let families = BookIndexGroupingBrain.families(
            worn: [draft, deep], live: live, wingID: "")
        #expect(families.map(\.id) == ["s", "t", "i"], "status · topic · topic/ideas — by path")
        #expect(BookIndexGroupingBrain.options(chaptersActive: true, families: families)
                == [.chapters, .tagFamily("s"), .tagFamily("t"), .tagFamily("i"), .none])
        #expect(BookIndexGroupingBrain.options(chaptersActive: false, families: families)
                == [.tagFamily("s"), .tagFamily("t"), .tagFamily("i"), .none],
                "no chapters ⇒ none offered (a gathering, or a book without them)")
        #expect(BookIndexGroupingBrain.families(worn: [status], live: live, wingID: "").isEmpty,
                "a worn ROOT with no worn child offers no family")
    }

    /// A choice that cannot apply draws the shipped look, never a wrong one.
    @Test func aChoiceThatCannotApplyFallsBackToTheShippedLook() {
        let status = tag("s", "status")
        typealias R = BookIndexGroupingBrain.Resolved
        #expect(BookIndexGroupingBrain.resolve(
            choice: nil, chaptersActive: true, live: [status], wingID: "") == R.shipped)
        #expect(BookIndexGroupingBrain.resolve(
            choice: .chapters, chaptersActive: false, live: [status], wingID: "") == R.shipped)
        #expect(BookIndexGroupingBrain.resolve(
            choice: .chapters, chaptersActive: true, live: [], wingID: "") == R.chapters)
        #expect(BookIndexGroupingBrain.resolve(
            choice: .tagFamily("gone"), chaptersActive: false, live: [status], wingID: "")
                == R.shipped, "a dead family root")
        #expect(BookIndexGroupingBrain.resolve(
            choice: .tagFamily("s"), chaptersActive: false, live: [status], wingID: "w2")
                == R.shipped, "another wing's tag")
        #expect(BookIndexGroupingBrain.resolve(
            choice: .tagFamily("s"), chaptersActive: true, live: [status], wingID: "")
                == R.tagFamily(status), "a family wins over chapters when chosen")
        #expect(BookIndexGroupingBrain.resolve(
            choice: BookIndexGrouping.none, chaptersActive: true, live: [], wingID: "") == R.none)
    }

    // MARK: - The partition

    @Test func aTagFamilyPartitionsTheNotesKeepingTheBooksOrder() {
        let status = tag("s", "status")
        let entries = ["n1", "n2", "n3", "n4", "n5"].map(entry)
        let sections = [
            "n1": "status/draft", "n2": "status/done", "n4": "status/draft",
        ]
        let groups = BookIndexGroupingBrain.groups(
            entries: entries, sections: sections, family: status)
        #expect(groups.map(\.title) == ["#status/done", "#status/draft", "other"])
        #expect(groups.map { $0.entries.map(\.postID) } == [["n2"], ["n1", "n4"], ["n3", "n5"]])
        #expect(groups.map(\.id) == ["fam:status/done", "fam:status/draft", "fam-none"])
        // Everything filed ⇒ no trailing group; nothing shown ⇒ nothing.
        #expect(BookIndexGroupingBrain.groups(
            entries: [entry("n1")], sections: ["n1": "status/draft"], family: status).count == 1)
        #expect(BookIndexGroupingBrain.groups(entries: [], sections: [:], family: status).isEmpty)
        #expect(BookIndexGroupingBrain.flat(entries).count == 1)
        #expect(BookIndexGroupingBrain.flat([]).isEmpty)
    }

    // MARK: - Display only (§3: never real chapters)

    /// Grouping a GATHERING and a chaptered BOOK by a tag family files every
    /// note through the held read and WRITES NOTHING: no `reading_section`
    /// row (§3 — never real chapters), no outbox row, no reading touched.
    @Test func groupingByATagFamilyMintsNoChapterAndWritesNothing() async throws {
        try await withGroupingWorld { session, db in
            let ops = session.operations
            let status = try ops.createTag(name: "status")
            let draft = try ops.createTag(parent: status.id, name: "draft")
            let done = try ops.createTag(parent: status.id, name: "done")
            let a = try ops.createPost(title: "a")
            let b = try ops.createPost(title: "b")
            let c = try ops.createPost(title: "c")
            _ = try ops.applyTag(draft.id, toPost: a.id)
            _ = try ops.applyTag(done.id, toPost: b.id)
            let gathering = try ops.createReading(
                name: "Status", kind: .gathering,
                querySpec: try RuleGrammar.encode(.tag(status.id)))
            let book = try ops.createReading(name: "Book", kind: .book)
            for note in [a, b, c] { try ops.addPostToReading(note.id, to: book.id) }
            _ = try ops.createSection(in: book.id, name: "One")

            let counts: () async throws -> (sections: Int, outbox: Int, readings: String) = {
                try await db.read { db in
                    (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading_section") ?? -1,
                     try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1,
                     try String.fetchAll(db, sql: "SELECT updated_at FROM reading ORDER BY id")
                        .joined(separator: ","))
                }
            }
            let before = try await counts()
            let defaults = scratchDefaults()
            for reading in [gathering, book] {
                let model = BookIndexGroupingModel(readingID: reading.id, defaults: defaults)
                model.choose(.tagFamily(status.id))
                let entries = try await db.read {
                    try Queries.assembleReading($0, readingID: reading.id)
                }
                let task = Task {
                    await model.track(session: session, postIDs: entries.map(\.postID))
                }
                defer { task.cancel() }
                try await settle { model.sectionsRoot == status.id && !model.sections.isEmpty }
                let groups = BookIndexGroupingBrain.groups(
                    entries: entries, sections: model.sections,
                    family: try #require(model.live.first { $0.id == status.id }))
                let titles = groups.map(\.title)
                if reading.kind == .gathering {
                    #expect(titles == ["#status/done", "#status/draft"], "\(titles)")
                } else {
                    #expect(titles == ["#status/done", "#status/draft", "other"], "\(titles)")
                }
            }
            let after = try await counts()
            #expect(after.sections == before.sections, "no reading_section row minted (§3)")
            #expect(after.outbox == before.outbox, "nothing written — no outbox row")
            #expect(after.readings == before.readings, "no reading touched")
        }
    }

    /// The mounted control: a gathering's menu has no chapters; a chaptered
    /// book never chosen reads "chapters" (the shipped look named).
    @Test func theMountedControlOffersAndChecksPerBook() async throws {
        try await withGroupingWorld { session, db in
            let ops = session.operations
            let status = try ops.createTag(name: "status")
            let draft = try ops.createTag(parent: status.id, name: "draft")
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(draft.id, toPost: note.id)
            let gathering = try ops.createReading(
                name: "G", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(status.id)))
            let book = try ops.createReading(name: "B", kind: .book)
            try ops.addPostToReading(note.id, to: book.id)
            _ = try ops.createSection(in: book.id, name: "One")
            let defaults = scratchDefaults()
            BookIndexGroupingProbe.drawn = [:]
            for reading in [gathering, book] {
                let target = try #require(
                    await BookSettingsTarget.load(session: session, readingID: reading.id))
                let model = BookIndexGroupingModel(readingID: reading.id, defaults: defaults)
                let snapshot = try await db.read {
                    try BookIndexGroupingModel.fetch($0, postIDs: [note.id], rootID: nil)
                }
                model.adopt(snapshot, rootID: nil)
                let window = NSWindow(
                    contentRect: NSRect(x: 60, y: 60, width: 320, height: 80),
                    styleMask: [.titled], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                window.contentView = NSHostingView(rootView: BookIndexGroupingControl(
                    tokens: .terminalLight, grouping: model, structure: target.structure))
                window.orderFrontRegardless()
                try await settle { BookIndexGroupingProbe.drawn[reading.id] != nil }
                window.orderOut(nil)
                window.close()
            }
            let g = try #require(BookIndexGroupingProbe.drawn[gathering.id])
            #expect(g.options == [.tagFamily(status.id), BookIndexGrouping.none],
                    "a gathering's Index: the same minus chapters")
            #expect(g.current == BookIndexGrouping.none)
            let b = try #require(BookIndexGroupingProbe.drawn[book.id])
            #expect(b.options == [.chapters, .tagFamily(status.id), BookIndexGrouping.none])
            #expect(b.current == .chapters, "never chosen on a chaptered book ⇒ chapters")
        }
    }

    /// **Ladder A round 1, MINOR 1 — U3's sharpened consequence (GENUINELY
    /// RED ON OLD — run on the pre-guard model first):** a SUPERSEDED
    /// track's late delivery (its task cancelled when the Index's key moved)
    /// never stomps the family in hand. Before the guard the late adopt
    /// overwrote `sectionsRoot`, so `BookIndexView.groups`' own
    /// `sectionsRoot == family.id` check failed and the Index fell back to
    /// the SHIPPED look — the chosen partition silently disappeared and
    /// STAYED gone until the next tagging write.
    @Test func aCancelledTracksLateDeliveryNeverStompsTheChosenFamily() async throws {
        let model = BookIndexGroupingModel(readingID: "r", defaults: scratchDefaults())
        model.adopt(
            .init(worn: [], live: [], sections: ["p": "fam/draft"]), rootID: "fam")
        // The superseded key's delivery lands on a CANCELLED task —
        // deterministic: the body cannot run before this MainActor test
        // suspends, and cancel() lands first.
        let late = Task { @MainActor in
            model.adopt(.init(worn: [], live: [], sections: [:]), rootID: nil)
        }
        late.cancel()
        _ = await late.value
        #expect(model.sectionsRoot == "fam", "the family in hand stands")
        #expect(model.sections == ["p": "fam/draft"])
    }
}
