//
//  ShelfAndPaletteTests.swift
//  VariorumTests
//
//  Phase 13, B2 — the structure stage's behavioral seams: shelf ordering
//  (pins first — R38), the quick-entry mint (R3), the promote-to-book spec
//  (R30), the palette vocabulary (R15), and the catalog scope filter
//  (R32). Pure-visual SwiftUI stays untested per the ground rules.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withShellSession<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 5))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("Shelf ordering & quick entry (Phase 13, B2)")
struct ShelfModelTests {
    @Test func orderingIsPinsThenJournalsThenRestByName() throws {
        func book(_ id: String, _ name: String, profile: String? = nil) -> Queries.ShelfBook {
            Queries.ShelfBook(
                reading: Reading(
                    id: id, name: name, kind: .curated, profile: profile,
                    createdAt: Date(), updatedAt: Date()),
                postCount: 0, sectionCount: 0)
        }
        let books = [
            book("z", "zebra"),
            book("j", "Journal 2026", profile: "journal"),
            book("a", "alpha"),
            book("d", "Dream Journal", profile: "journal"),
            book("p", "pinned late"),
        ]
        let ordered = ShelfViewModel.ordered(books: books, pins: ["p", "z"])
        #expect(ordered.map(\.reading.id) == ["p", "z", "d", "j", "a"],
                "pins first in PIN order (R38), then journal books, then the rest by name")
    }

    @Test func quickEntryMintsASegmentedPostAndReturnsItsID() async throws {
        try await withShellSession { session, db in
            let model = ShelfViewModel(session: session)
            let id = await model.quickEntry("First paragraph.\n\nSecond paragraph.")
            let postID = try #require(id)
            let rendered = try await db.read { db in try Queries.renderPost(db, containerID: postID) }
            #expect(rendered.count == 2,
                    "Enter opens the typed text as a WHOLE post — bulk entry, segmented (R3)")
            // Whitespace-only never mints.
            #expect(await model.quickEntry("   \n ") == nil)
        }
    }

    @Test func dragAPostOntoABookAddsMembershipIdempotently() async throws {
        try await withShellSession { session, db in
            let model = ShelfViewModel(session: session)
            let (postID, bookID) = try await session.runner.run { ops in
                let post = try ops.createPost(title: "floating")
                let book = try ops.createReading(name: "orbit", kind: .curated)
                return (post.id, book.id)
            }
            await model.addPost(postID, to: bookID)
            await model.addPost(postID, to: bookID)  // the drop repeats — no error
            #expect(model.lastError == nil)
            let books = try await db.read { db in try Queries.readingsContaining(db, postID: postID) }
            #expect(books.map(\.id) == [bookID])
        }
    }

    @Test func finishAndExtentFacesCallTheOps() async throws {
        try await withShellSession { session, db in
            let model = ShelfViewModel(session: session)
            let bookID = try await session.runner.run { ops in
                try ops.createReading(name: "dream", kind: .curated).id
            }
            await model.setWordTarget(bookID, target: 10_000)
            await model.setFinished(bookID, finished: true)
            let reading = try await db.read { db in try Queries.reading(db, id: bookID) }
            #expect(reading?.wordTarget == 10_000)
            #expect(reading?.locked == true)
            // Extent edits on a finished book refuse — and the refusal
            // SURFACES (the fire-and-speak posture).
            await model.setWordTarget(bookID, target: 20_000)
            #expect(model.lastError != nil)
        }
    }
}

@MainActor
@Suite("Promote to book & palette (Phase 13, B2)")
struct PromoteAndPaletteTests {
    @Test func promoteSpecIsExactlyTheR30Vocabulary() throws {
        let orSpec = PromoteTagsSheet.spec(paths: ["stars", "dreams"], joinAll: false)
        #expect(orSpec.tags == ["stars", "dreams"])
        #expect(orSpec.tagsAll == nil)
        let andSpec = PromoteTagsSheet.spec(paths: ["stars", "dreams"], joinAll: true)
        #expect(andSpec.tagsAll == ["stars", "dreams"])
        #expect(andSpec.tags == nil)
    }

    @Test func paletteListsCommandsAndCatalogHitsAndExecutes() async throws {
        try await withShellSession { session, db in
            _ = try await session.runner.run { ops in
                let post = try ops.createPost(title: "the storm chapter")
                _ = try ops.newBlock(in: post.id, text: "Prose.", at: .end)
                _ = try ops.createReading(name: "Orbit", kind: .curated)
                return post.id
            }
            let model = PaletteModel(session: session)
            var executed: [String] = []
            model.commands = [
                ("New Post", { executed.append("new") }),
                ("Toggle Block Seams", { executed.append("seams") }),
            ]
            await model.refresh()
            #expect(model.items.contains { $0.kind == .command && $0.title == "New Post" })
            #expect(model.items.contains { $0.kind == .book && $0.title == "Orbit" })
            #expect(model.items.contains { $0.kind == .post && $0.title == "the storm chapter" })

            // Typing filters commands AND narrows the catalog.
            model.query = "seams"
            await model.refresh()
            #expect(model.items.contains { $0.title == "Toggle Block Seams" })
            #expect(!model.items.contains { $0.title == "New Post" })

            // Execution: a command runs its action; a post routes.
            if let command = model.items.first(where: { $0.kind == .command }) {
                model.execute(command) { _, _ in }
            }
            #expect(executed == ["seams"])
            model.query = "storm"
            await model.refresh()
            var opened: SidebarSelection?
            if let post = model.items.first(where: { $0.kind == .post }) {
                model.execute(post) { picked, _ in opened = picked }
            }
            if case .post = opened {} else {
                Issue.record("a post hit must route to .post — got \(String(describing: opened))")
            }
            _ = db
        }
    }

    @Test func paletteBlockHitsNavigateToTheirHome() async throws {
        // Round 2, MINOR (was a silent `break`): Enter on a block result
        // opens its HOME surface — post or Blocks pool.
        try await withShellSession { session, _ in
            _ = try await session.runner.run { ops in
                let pool = try ops.createPool(title: "scraps")
                _ = try ops.newBlock(in: pool.id, text: "a lantern scrap", at: .end)
                let post = try ops.createPost(title: "harbor")
                let made = try ops.newBlock(in: post.id, text: "Prose.", at: .end)
                try ops.setBlockName(made.block.id, name: "the lantern thesis")
                return post.id
            }
            let model = PaletteModel(session: session)
            model.query = "lantern"
            await model.refresh()
            let blocks = model.items.filter { $0.kind == .block }
            #expect(blocks.count == 2)
            var opened: [(SidebarSelection, String?)] = []
            for hit in blocks {
                model.execute(hit) { opened.append(($0, $1)) }
            }
            #expect(opened.count == 2, "every block hit NAVIGATES — no dead rows")
            #expect(opened.contains { if case .pool = $0.0 { true } else { false } })
            #expect(opened.contains { if case .post = $0.0 { true } else { false } })
            // Stage C: the landing is CARET-PRECISE — the block ID rides
            // beside the home selection for the shell to seed the caret.
            #expect(opened.allSatisfy { $0.1 != nil && !$0.1!.isEmpty },
                    "block hits carry their block ID")
        }
    }

    @Test func extentInputDistinguishesClearFromTypo() {
        // Round 2, MINOR (red-on-old: `Int("10k")` = nil silently CLEARED
        // a stored extent): empty clears, digits set, garbage REFUSES.
        #expect(ExtentInput.parse("") == .clear)
        #expect(ExtentInput.parse("  ") == .clear)
        #expect(ExtentInput.parse("10000") == .value(10_000))
        #expect(ExtentInput.parse("10k") == nil)
        #expect(ExtentInput.parse("12,000") == nil)
    }

    @Test func catalogScopeFilterIsExact() throws {
        let hits = [
            Queries.CatalogHit(kind: .book, id: "b", title: "Book", detail: nil),
            Queries.CatalogHit(kind: .post, id: "p", title: "Post", detail: nil),
            Queries.CatalogHit(kind: .block, id: "k", title: "Block", detail: nil),
        ]
        let db = try! AppDatabase.inMemory()
        let model = LibraryCatalogModel(session: AppSession(database: db))
        model.scope = .books
        #expect(model.filtered(hits).map(\.id) == ["b"])
        model.scope = .blocks
        #expect(model.filtered(hits).map(\.id) == ["k"])
        model.scope = .all
        #expect(model.filtered(hits).count == 3)
    }
}
