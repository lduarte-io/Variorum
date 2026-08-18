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

    /// 13b Stage 3, 3E (N11): keyboard row-stepping — ⏎ runs the SELECTED
    /// row, not always the first; ↓/↑ move the selection (clamped); a
    /// refresh resets to the top. The 3A drive's shadow bite is the named
    /// case: ⌘K "extract" ⏎ ran the EXTRACT ACT instead of opening the
    /// extract lesson — stepping down first now reaches the post row.
    /// Red-on-old: `selectedItem`/`moveSelection` reverted to first-row-
    /// always turns the stepped-execution half red (behavioral revert).
    @Test func paletteArrowsMoveTheSelectionAndEnterRunsIt() async throws {
        try await withShellSession { session, _ in
            _ = try await session.runner.run { ops in
                let post = try ops.createPost(title: "extract lesson")
                _ = try ops.newBlock(in: post.id, text: "Prose.", at: .end)
                return post.id
            }
            let model = PaletteModel(session: session)
            var executed: [String] = []
            model.commands = [("Extract Selection", { executed.append("act") })]
            model.query = "extract"
            await model.refresh()

            // The shadow shape: the act row first, the same-named post
            // beneath it. Default selection = the top row (the pre-N11
            // behavior is the default, not the only truth).
            #expect(model.items.count >= 2)
            #expect(model.selectedIndex == 0)
            #expect(model.selectedItem?.kind == .command)

            // ↓ moves the › marker; ⏎ runs the SELECTED row.
            model.moveSelection(by: 1)
            #expect(model.selectedItem?.kind == .post,
                    "the shadowed post row is keyboard-reachable now")
            var opened: SidebarSelection?
            if let selected = model.selectedItem {
                model.execute(selected) { picked, _ in opened = picked }
            }
            #expect(executed.isEmpty, "the act did NOT run — the selection did")
            if case .post = opened {} else {
                Issue.record("stepping+⏎ opens the post — got \(String(describing: opened))")
            }

            // Clamps at both ends; ↑ returns; refresh resets.
            model.moveSelection(by: 99)
            #expect(model.selectedIndex == model.items.count - 1, "clamped at the end")
            model.moveSelection(by: -99)
            #expect(model.selectedIndex == 0, "clamped at the top")
            model.moveSelection(by: 1)
            model.query = "extract lesson"
            await model.refresh()
            #expect(model.selectedIndex == 0, "a fresh list selects its top row")
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

    @Test func staleTagChipReadsNeverLand() async throws {
        // Round 3, MINOR (red-on-old by behavioral revert — remove the
        // post-read generation check and the stale chips land): the chips
        // read is a second suspension point after the round-2 hits guard;
        // a superseded generation's chips must never describe the newer
        // query's rows.
        try await withShellSession { session, _ in
            let (tagged, other) = try await session.runner.run { ops -> (String, String) in
                let tag = try ops.createTag(parent: nil, name: "stars")
                let tagged = try ops.createPost(title: "tagged post", profile: .generic)
                try ops.applyTag(tag.id, toPost: tagged.id)
                let other = try ops.createPost(title: "plain post", profile: .generic)
                return (tagged.id, other.id)
            }
            let model = LibraryCatalogModel(session: session)
            await model.search()  // the CURRENT generation's chips
            // 13e E8 (JUSTIFIED EDIT — a TYPE change, not a meaning one):
            // the chips carry whole `Tag` rows now, because taking a tag
            // OFF a row needs its id. The assertions read the same fact
            // through `.path`; the staleness contract they exist for is
            // untouched.
            #expect(model.postTags[tagged]?.map(\.path) == ["stars"])

            // A STALE generation's chips arrive late (the race, made
            // deterministic): they must not land.
            await model.loadTagChips(for: [other], generation: 0)
            #expect(model.postTags[tagged]?.map(\.path) == ["stars"],
                    "the superseded read never overwrites the current chips")
            #expect(model.postTags.count >= 1)
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
        // 13b Stage 4 ladder round 1, MINOR-2 (red-on-old: parse accepted
        // any Int, so "0"/"-5" reached the ops layer and its refusal
        // surfaced as a raw enum dump): non-positive is INVALID at the
        // field — every ExtentInput consumer feeds a setter that refuses
        // `<= 0`, and the refusal now lands refuse-and-keep at the door.
        #expect(ExtentInput.parse("0") == nil)
        #expect(ExtentInput.parse("-5") == nil)
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
