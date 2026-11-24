//
//  TrashSearchTests.swift
//  VariorumCoreTests
//
//  VX-93 (the vx-980 run, batch 3; `notes/plans/fixes/vx-980-search-fixes.md`)
//  — A SEARCH INSIDE THE TRASH, the read. Her rulings: R-980-9 (names and
//  deleted text: a note by its title or any of its text, blocks and takes by
//  their text, books and gatherings by name, snippet groups by name and their
//  snippets' text), R-980-10 (every word, folded, a contained run) and
//  R-980-11 (one passage line where the row does not show the match).
//
//  `Queries.trashSearch` NARROWS `Queries.trash` — the same wing fence, the
//  same 30-day window, the same purge-intent fence, the same kinds and order —
//  and reads each examined row's deleted text driven from that row's own id.
//  Pinned here: each kind's reach, the fences inherited, the reach past the
//  newest-N window, the exact-stamp family, the plan (the rows drive, every
//  store table is SEARCHed by index) and the region (the listing's own named
//  tables).
//
//  A feature batch: these pins state the NEW contract. Each can fail — every
//  expectation is an exact row set or an exact line, and the plan pin names
//  the driving table and forbids a store-table scan.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

private func search(
    _ db: AppDatabase, _ field: String, now: Date = harnessNow,
    kinds: Set<Queries.TrashItem.Kind> = Set(Queries.TrashItem.Kind.allCases),
    oldestFirst: Bool = false, limit: Int? = nil, wingID: String? = "",
    shows: @escaping (Queries.TrashItem) -> String = Queries.trashRowDefaultShown
) throws -> Queries.TrashSearchAnswer {
    try db.read {
        try Queries.trashSearch(
            $0, now: now, words: TrashTextMatch.words(field), kinds: kinds,
            oldestFirst: oldestFirst, limit: limit, wingID: wingID, shows: shows)
    }
}

private func ids(_ answer: Queries.TrashSearchAnswer) -> [String] { answer.items.map(\.id) }

/// The Mac's face's own rule for what a text row shows (`TrayRowPreview.line`:
/// the first line, trimmed) — restated here only to drive the passage pins.
private func firstLine(_ item: Queries.TrashItem) -> String {
    item.title ?? (item.text ?? "").split(separator: "\n", omittingEmptySubsequences: false)
        .first.map(String.init) ?? ""
}

@Suite("VX-93 — a search inside the Trash narrows the Trash's own listing")
struct TrashSearchTests {
    // MARK: - What it searches (R-980-9)

    @Test func aDeletedNoteIsFoundByItsTitleAndByAnyOfItsText() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "Garden plans")
            let first = try ops.newBlock(in: note.id, text: "Seeds to order.")
            _ = try ops.newBlock(in: note.id, text: "We moved the rhubarb to the east bed.")
            // A take that is not the chosen one, and an archived take: both
            // went into the Trash with the note and come back with Put back.
            let other = try ops.branchVariant(first.block.id, from: first.variant.id)
            try ops.autosave(other.id, text: "Seeds — the marigold kind.", charDelta: 0)
            let kept = try ops.branchVariant(first.block.id, from: first.variant.id)
            try ops.autosave(kept.id, text: "An old line about parsnips.", charDelta: 0)
            try ops.archiveVariant(kept.id)
            let elsewhere = try ops.createPost(title: "Another note")
            _ = try ops.newBlock(in: elsewhere.id, text: "nothing to see")
            try ops.deleteContainer(note.id)
            try ops.deleteContainer(elsewhere.id)

            #expect(ids(try search(db, "garden")) == [note.id], "by its title")
            #expect(ids(try search(db, "rhubarb")) == [note.id], "by a block's text")
            #expect(ids(try search(db, "marigold")) == [note.id], "by a take that is not the chosen one")
            #expect(ids(try search(db, "parsnips")) == [note.id], "by an archived take that went in with it")
            #expect(ids(try search(db, "garden rhubarb")) == [note.id], "one word in the title, one in the text")
            #expect(ids(try search(db, "rhubarb pear")) == [], "every word, or nothing")
            #expect(Set(ids(try search(db, "e"))) == [note.id, elsewhere.id])

            // The passage: owed by a body match, never by a title match.
            let byBody = try search(db, "rhubarb")
            #expect(byBody.passages[note.id] == "We moved the rhubarb to the east bed.")
            #expect(try search(db, "garden").passages.isEmpty, "the row shows its title — nothing to explain")
            #expect(try search(db, "garden rhubarb").passages[note.id] == "We moved the rhubarb to the east bed.",
                    "the passage explains the word the title does not show")
        }
    }

    @Test func aBlockAndATakeAreFoundByTheirText() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "Recipes")
            let crumble = try ops.newBlock(in: note.id, text: "rhubarb crumble, 2 cups\nthen the oats")
            let alt = try ops.branchVariant(crumble.block.id, from: crumble.variant.id)
            try ops.autosave(alt.id, text: "a crumble with ginger", charDelta: 0)
            try ops.deleteBlock(crumble.block.id)
            let stays = try ops.newBlock(in: note.id, text: "A block that stays.")
            let take = try ops.branchVariant(stays.block.id, from: stays.variant.id)
            try ops.autosave(take.id, text: "a take about quinces", charDelta: 0)
            try ops.deleteVariant(take.id)

            #expect(ids(try search(db, "rhubarb")) == [crumble.block.id])
            #expect(ids(try search(db, "ginger")) == [crumble.block.id], "a block by any take that went in with it")
            #expect(ids(try search(db, "quince")) == [take.id], "a take by its own text")
            #expect(ids(try search(db, "recipes")) == [], "a block is found by its text, never its home's title")

            // The passage follows what the row shows: by the face's first-line
            // rule, a match in the first line needs none and one below it does.
            #expect(try search(db, "rhubarb", shows: firstLine).passages.isEmpty)
            // (The lead keeps 32 characters before the match; the cut fell
            // inside "rhubarb", so it steps to that word's end — an ellipsis
            // says the text was cut.)
            let oats = try search(db, "oats", shows: firstLine)
            #expect(oats.passages[crumble.block.id] == "\u{2026}crumble, 2 cups then the oats")
            #expect(try search(db, "ginger", shows: firstLine).passages[crumble.block.id]
                    == "a crumble with ginger", "the passage comes from the take that holds the word")
        }
    }

    @Test func aBookAndAGatheringAreFoundByTheirNamesAlone() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Orchard Journal", kind: .book)
            let member = try ops.createPost(title: "pruning day")
            _ = try ops.newBlock(in: member.id, text: "the apple trees")
            _ = try ops.addPostToReading(member.id, to: book.id)
            let gathering = try ops.createReading(
                name: "Starred orchard things", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            try ops.deleteReading(book.id)
            try ops.deleteReading(gathering.id)

            #expect(Set(ids(try search(db, "orchard"))) == [book.id, gathering.id])
            #expect(ids(try search(db, "journal orch")) == [book.id])
            #expect(ids(try search(db, "apple")) == [], "a book is never found by its notes' text")
            #expect(try search(db, "orchard").passages.isEmpty, "a name is always shown")
        }
    }

    @Test func aSnippetGroupIsFoundByItsNameAndItsSnippets() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "Loose lines")
            _ = try ops.newBlock(in: pool.id, text: "the heron stood in the reeds")
            try ops.deleteContainer(pool.id)

            #expect(ids(try search(db, "loose")) == [pool.id])
            #expect(ids(try search(db, "heron")) == [pool.id])
            #expect(try search(db, "heron").passages[pool.id] == "the heron stood in the reeds")
        }
    }

    @Test func aPreservedOriginalIsFoundByItsText() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "divided")
            let block = try ops.newBlock(in: note.id, text: "First half here. Second half there.")
            let take = try ops.branchVariant(block.block.id, from: block.variant.id)
            let w = try ops.divideW(block.block.id, cuts: [block.variant.id: 16, take.id: 16])
            try ops.deleteBlock(w.first.block.id)
            try ops.deleteBlock(w.second.block.id)
            let listed = try db.read { try Queries.trash($0, now: harnessNow, wingID: "") }
            #expect(listed.contains { $0.kind == .preservedOriginal && $0.id == block.block.id },
                    "premise: the original is stranded onto the family's clock")

            let found = try search(db, "second half", kinds: [.preservedOriginal])
            #expect(ids(found) == [block.block.id])
        }
    }

    // MARK: - How words match (R-980-10)

    @Test func wordsFoldCaseAndAccentsAndMatchAsContainedRuns() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "Café notes")
            _ = try ops.newBlock(in: note.id, text: "Crème brûlée for 1 + 1 guests; #dessert")
            try ops.deleteContainer(note.id)

            for field in ["cafe", "CAFÉ", "creme brulee", "BRÛL", "1 + 1", "+", "#dessert", "dess", "guests;"] {
                #expect(ids(try search(db, field)) == [note.id], "\(field)")
            }
            for field in ["#desserts", "1+1", "creme pie"] {
                #expect(ids(try search(db, field)) == [], "\(field)")
            }
        }
    }

    // MARK: - The listing's own fences, inherited

    @Test func theWingFenceTheWindowAndThePurgeFenceAreTheListings() throws {
        try withOperations { ops, db in
            let far = try ops.createWing(name: "Far")
            let home = try ops.createPost(title: "lantern at home")
            let away = try ops.createPost(title: "lantern far away", wingId: far.id)
            let purged = try ops.createPost(title: "lantern purged")
            try ops.deleteContainer(home.id)
            try ops.deleteContainer(away.id)
            try ops.deleteContainer(purged.id)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "container", rowID: purged.id)])

            #expect(ids(try search(db, "lantern", wingID: "")) == [home.id],
                    "Home's Trash: another wing's row never lists, a purge-fenced row never lists")
            #expect(ids(try search(db, "lantern", wingID: far.id)) == [away.id])
            #expect(ids(try search(db, "lantern", now: harnessNow.addingTimeInterval(31 * 86_400))) == [],
                    "past the 30-day window it has left the Trash, and the search")
            // Every row the search lists, the listing lists — never a second rule.
            for wing in ["", far.id] {
                let listing = try db.read { try Queries.trash($0, now: harnessNow, wingID: wing) }
                let found = try search(db, "lantern", wingID: wing)
                #expect(found.items.allSatisfy(listing.contains), "every row found is a row the listing lists, as it lists it")
            }
        }
    }

    @Test func aKindFilterAndTheOrderAreTheListingsToo() throws {
        try withOperations { ops, db in
            let a = try ops.createPost(title: "quill one")
            let b = try ops.createPost(title: "quill two")
            let book = try ops.createReading(name: "quill book", kind: .book)
            try ops.deleteContainer(a.id)
            try ops.deleteContainer(b.id)
            try ops.deleteReading(book.id)

            #expect(ids(try search(db, "quill")) == [book.id, b.id, a.id], "newest first, the listing's order")
            #expect(ids(try search(db, "quill", oldestFirst: true)) == [a.id, b.id, book.id])
            #expect(ids(try search(db, "quill", kinds: [.note])) == [b.id, a.id], "the kind filter composes")
            #expect(ids(try search(db, "quill", limit: 2)) == [book.id, b.id], "the window bounds the narrowed answer")
        }
    }

    /// The search reaches this wing's WHOLE Trash, not the newest rows the
    /// display window holds: a word only the oldest row holds is found even
    /// when the limit would have cut that row from the plain listing.
    @Test func theSearchReachesPastTheNewestRowsTheWindowShows() throws {
        try withOperations { ops, db in
            let oldest = try ops.createPost(title: "the walrus")
            try ops.deleteContainer(oldest.id)
            for index in 0..<5 {
                let note = try ops.createPost(title: "filler \(index)")
                try ops.deleteContainer(note.id)
            }
            let plain = try db.read { try Queries.trash($0, now: harnessNow, limit: 2, wingID: "") }
            #expect(!plain.map(\.id).contains(oldest.id), "premise: the plain window of 2 cuts it")
            #expect(ids(try search(db, "walrus", limit: 2)) == [oldest.id])
        }
    }

    /// The exact-stamp family: a block deleted on its own BEFORE its note is
    /// its own row (a different stamp), so its words find that row, not the
    /// note's — exactly what Put back of each brings back.
    @Test func aNotesFamilyIsWhatWentInWithItOnItsExactStamp() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the house")
            _ = try ops.newBlock(in: note.id, text: "the kitchen table")
            let earlier = try ops.newBlock(in: note.id, text: "the attic window")
            try ops.deleteBlock(earlier.block.id)
            try ops.deleteContainer(note.id)

            #expect(ids(try search(db, "kitchen")) == [note.id])
            #expect(ids(try search(db, "attic")) == [earlier.block.id],
                    "the earlier block is its own Trash row and its text is its own")
        }
    }

    @Test func noWordsIsTheListingAsItStands() throws {
        try withOperations { ops, db in
            for index in 0..<3 {
                let note = try ops.createPost(title: "n\(index)")
                try ops.deleteContainer(note.id)
            }
            let listing = try db.read { try Queries.trash($0, now: harnessNow, limit: 2, wingID: "") }
            let answer = try search(db, "   ", limit: 2)
            #expect(answer.items == listing)
            #expect(answer.passages.isEmpty)
        }
    }

    // MARK: - Cost (P1, P2)

    /// **The text read is DRIVEN by the Trash's own rows** — `json_each` over
    /// the examined rows' ids first, then every store table SEARCHed by index;
    /// never a scan of `container`, `container_block`, `block` or `variant`.
    @Test func theTextReadIsDrivenFromTheTrashsOwnRows() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "a note")
            let block = try ops.newBlock(in: note.id, text: "a block")
            let lone = try ops.newBlock(in: note.id, text: "a lone block")
            try ops.deleteBlock(lone.block.id)
            try ops.deleteContainer(note.id)
            _ = block

            for sql in [Queries.trashContainerTextsSQL, Queries.trashBlockTextsSQL] {
                let plan: [String] = try db.read { database in
                    try Row.fetchAll(
                        database, sql: "EXPLAIN QUERY PLAN " + sql,
                        arguments: [String(decoding: try JSONEncoder().encode([note.id]), as: UTF8.self)])
                        .map { $0["detail"] as String }
                }
                let text = plan.joined(separator: "\n")
                #expect(plan.first?.hasPrefix("SCAN j VIRTUAL TABLE") == true, "the rows' ids drive:\n\(text)")
                var seeks = ["SEARCH b USING INDEX sqlite_autoindex_block_1 (id=?)",
                             "SEARCH v USING INDEX idx_variant_block (block_id=?)"]
                if sql == Queries.trashContainerTextsSQL {
                    seeks += ["SEARCH c USING INDEX sqlite_autoindex_container_1 (id=?)",
                              "SEARCH cb USING INDEX idx_cblock_order (container_id=?)"]
                }
                for seek in seeks {
                    #expect(text.contains(seek), "\(seek) — missing:\n\(text)")
                }
                for alias in ["c", "cb", "b", "v", "container", "container_block", "block", "variant"] {
                    #expect(!plan.contains { $0 == "SCAN \(alias)" || $0.hasPrefix("SCAN \(alias) ") },
                            "SCAN \(alias) is a corpus walk:\n\(text)")
                }
            }
        }
    }

    /// The narrowing reads only the listing's own named tables, so the held
    /// observation's constant region (`Queries.trashTables`) is exact for it
    /// too — a write the narrowed answer depends on always wakes it.
    @Test func theNarrowingReadsExactlyTheListingsNamedTables() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "a note")
            _ = try ops.newBlock(in: note.id, text: "words in it")
            try ops.deleteContainer(note.id)
            let pool = try ops.createPool(title: "scraps")
            _ = try ops.newBlock(in: pool.id, text: "words in a scrap")
            try ops.deleteContainer(pool.id)
            let kept = try ops.createPost(title: "kept")
            let block = try ops.newBlock(in: kept.id, text: "words in a block")
            try ops.deleteBlock(block.block.id)

            let region: DatabaseRegion = try db.read { database in
                let captured = LockIsolated<[String]>([])
                let capturing = LockIsolated(true)
                database.trace(options: .statement) { event in
                    guard capturing.value, case .statement(let statement) = event else { return }
                    let sql = statement.sql
                    captured.withValue { $0.append(sql) }
                }
                let found = try Queries.trashSearch(
                    database, now: harnessNow, words: ["words"], limit: 501, wingID: "")
                #expect(found.items.count == 3, "premise: both text statements ran")
                capturing.setValue(false)
                var region = DatabaseRegion()
                for sql in captured.value {
                    region = region.union(try database.makeStatement(sql: sql).databaseRegion)
                }
                return region
            }
            let tables = try db.read { database in
                try String.fetchAll(
                    database,
                    sql: "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'")
            }
            let read = Set(tables.filter { region.isModified(byEventsOfKind: .insert(tableName: $0)) })
            #expect(read.isSubset(of: Set(Queries.trashTables)),
                    "read but not named: \(read.subtracting(Queries.trashTables).sorted())")
        }
    }

    /// The held answer follows the Trash: a matched note put back leaves the
    /// narrowed listing (the observation re-reads on the listing's region).
    @Test func theHeldAnswerFollowsAPutBack() async throws {
        try await withOperationsAsync { ops, db in
            let note = try ops.createPost(title: "the lighthouse")
            try ops.deleteContainer(note.id)
            var iterator = db.observeTrashSearch(
                now: harnessNow, words: ["lighthouse"], kinds: Set(Queries.TrashItem.Kind.allCases),
                oldestFirst: false, limit: 501, wingID: ""
            ).makeAsyncIterator()
            #expect(try await iterator.next()?.items.map(\.id) == [note.id])
            try ops.restoreContainer(note.id)
            #expect(try await iterator.next()?.items.isEmpty == true, "put back: it leaves the narrowed listing")
        }
    }
}
