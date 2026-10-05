// BRANCH-ONLY tool code (`tools/strings-workbook`; never merges). The record:
// notes/plans/strings-workbook-record.md.

import Dependencies
import Foundation
import GRDB
import VariorumCore

/// Mints a `WorkbookPlan` into a store — EVERY write through the operations
/// API (AppSpec §9), exactly the doors a person's gestures use: `createReading`,
/// `createSection`, `createPost`, `addPostToReading`, `assignPostToSection`,
/// `newBlock` (the exact text — never the paste/segmentation pipeline),
/// `newBlankVariant`, `autosave`, `setTakeLabel`. No raw row writes, no schema,
/// no triggers touched; the outbox triggers capture every row as for any edit.
///
/// The ops run signed out (`OwnerIdentity.signedOut`): rows are born unowned
/// and the app's owner adoption stamps them at the next signed-in launch
/// (`AppServices.runOwnerAdoption`), before sync pushes — the road every
/// pre-sign-in row takes.
///
/// There is no undo stack (`Operations(undoStack: nil)`, the seeders' shape):
/// the mint is not a gesture. A mint that fails partway leaves a partial
/// book; the A1 safety copy is the clean road back (or Delete Book… with its
/// notes, then run again).
public enum WorkbookMint {
    public struct Report: Equatable, Sendable {
        public var readingID: String
        public var chapters: Int
        public var notes: Int
        public var blocks: Int
        public var takes: Int
    }

    public enum MintError: Error, Equatable, CustomStringConvertible {
        case alreadyMinted(existingName: String)

        public var description: String {
            switch self {
            case .alreadyMinted(let name):
                return "a book named “\(name)” already exists in this store (live or archived) — "
                    + "the workbook mints once; delete or rename that book first"
            }
        }
    }

    /// THE ONE-SHOT GUARD: any non-tombstoned reading whose name is the
    /// workbook's under the app's own comparison key (`BookNaming.key` — the
    /// E13 duplicate-name rule's key). Stricter than `assertBookNameIsFree`
    /// on purpose: an ARCHIVED "App Strings" also refuses, so a second mint
    /// can never land beside a first one she archived.
    public static func existingWorkbookName(_ db: Database) throws -> String? {
        let key = BookNaming.key(WorkbookPlan.bookName)
        return try String.fetchAll(db, sql: "SELECT name FROM reading WHERE deleted_at IS NULL")
            .first { BookNaming.key($0) == key }
    }

    /// Runs `body` with `Operations` bound to `database`: live clock and ids,
    /// the system random generator for fractional-index jitter, signed out.
    static func withOperations<T>(on database: AppDatabase, _ body: (Operations) throws -> T) throws -> T {
        try withDependencies {
            $0.database = database
            $0.date = DateGenerator { Date() }
            $0.uuid = UUIDGenerator { UUID() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
            $0.ownerIdentity = .signedOut
        } operation: {
            try body(Operations(undoStack: nil))
        }
    }

    /// Mints the plan. Refuses BEFORE the first write when the workbook
    /// already exists. `progress(done, total)` fires after every block.
    @discardableResult
    public static func mint(
        _ plan: WorkbookPlan, into database: AppDatabase,
        progress: ((Int, Int) -> Void)? = nil
    ) throws -> Report {
        if let existing = try database.read({ try existingWorkbookName($0) }) {
            throw MintError.alreadyMinted(existingName: existing)
        }
        let total = plan.blockCount
        return try withOperations(on: database) { ops in
            // A plain book (the `'book'` profile — AppSpec §7), no rule, Home
            // wing, unshelved: `createReading`'s defaults are exactly that.
            let book = try ops.createReading(
                name: WorkbookPlan.bookName, kind: .book, profile: "book")
            var done = 0
            var notes = 0
            for chapter in plan.chapters {
                let section = try ops.createSection(in: book.id, name: chapter.name)
                for note in chapter.notes {
                    let post = try ops.createPost(title: note.title)
                    try ops.addPostToReading(post.id, to: book.id, at: .end)
                    try ops.assignPostToSection(post.id, in: book.id, section: section.id)
                    notes += 1
                    for block in note.blocks {
                        // Take 1 — chosen AND default by `newBlock`'s own letter.
                        let minted = try ops.newBlock(in: post.id, text: block.current, at: .end)
                        // Takes 2 and 3 — each at the fan's END, so the fan
                        // order is current · rewrite · where.
                        let rewrite = try ops.newBlankVariant(minted.block.id)
                        let locator = try ops.newBlankVariant(minted.block.id)
                        try ops.autosave(locator.id, text: block.locator, charDelta: block.locator.count)
                        try ops.setTakeLabel(minted.variant.id, label: WorkbookPlan.takeLabels.current)
                        try ops.setTakeLabel(rewrite.id, label: WorkbookPlan.takeLabels.rewrite)
                        try ops.setTakeLabel(locator.id, label: WorkbookPlan.takeLabels.locator)
                        done += 1
                        progress?(done, total)
                    }
                }
            }
            return Report(
                readingID: book.id, chapters: plan.chapters.count, notes: notes,
                blocks: done, takes: done * 3)
        }
    }

    // MARK: - Read-back verification (independent of the ops: plain SQL)

    public enum VerificationError: Error, Equatable, CustomStringConvertible {
        case mismatch(String)
        public var description: String {
            switch self { case .mismatch(let what): return "verification failed: \(what)" }
        }
    }

    /// Re-reads the minted book with plain SQL and compares EVERYTHING to the
    /// plan: the book row, chapter names and order, each chapter's notes and
    /// order, each note's blocks and order, and each block's three takes —
    /// labels, texts, fan order, chosen = default = take 1, all active.
    public static func verify(_ plan: WorkbookPlan, readingID: String, in database: AppDatabase) throws {
        try database.read { db in
            func fail(_ what: String) -> VerificationError { .mismatch(what) }

            guard let book = try Row.fetchOne(db, sql: """
                SELECT name, kind, query_spec, wing_id, shelf_id, archived_at, locked
                FROM reading WHERE id = ? AND deleted_at IS NULL
                """, arguments: [readingID])
            else { throw fail("the book row is missing") }
            guard (book["name"] as String) == WorkbookPlan.bookName,
                  (book["kind"] as String) == "book",
                  (book["query_spec"] as String?) == nil,
                  (book["wing_id"] as String) == "",
                  (book["shelf_id"] as String?) == nil,
                  (book["archived_at"] as String?) == nil,
                  (book["locked"] as Int) == 0
            else { throw fail("the book row is not a plain, rule-less, unshelved Home book") }

            let sections = try Row.fetchAll(db, sql: """
                SELECT id, name FROM reading_section
                WHERE reading_id = ? AND deleted_at IS NULL ORDER BY position, id
                """, arguments: [readingID])
            guard sections.map({ $0["name"] as String }) == plan.chapters.map(\.name) else {
                throw fail("chapter names/order differ: \(sections.map { $0["name"] as String })")
            }

            let members = try Row.fetchAll(db, sql: """
                SELECT rp.post_id, rp.section_id, c.title
                FROM reading_post rp JOIN container c ON c.id = rp.post_id
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                  AND c.deleted_at IS NULL
                ORDER BY rp.position, rp.id
                """, arguments: [readingID])
            guard members.count == plan.notes.count else {
                throw fail("\(members.count) member notes, planned \(plan.notes.count)")
            }

            for (chapterIndex, chapter) in plan.chapters.enumerated() {
                let sectionID: String = sections[chapterIndex]["id"]
                let inChapter = members.filter { ($0["section_id"] as String?) == sectionID }
                guard inChapter.map({ $0["title"] as String? }) == chapter.notes.map(\.title) else {
                    throw fail("chapter “\(chapter.name)” notes differ")
                }
                for (noteIndex, note) in chapter.notes.enumerated() {
                    let postID: String = inChapter[noteIndex]["post_id"]
                    let placements = try Row.fetchAll(db, sql: """
                        SELECT cb.block_id, cb.chosen_variant_id, b.default_variant_id
                        FROM container_block cb JOIN block b ON b.id = cb.block_id
                        WHERE cb.container_id = ? AND cb.deleted_at IS NULL AND b.deleted_at IS NULL
                        ORDER BY cb.position, cb.id
                        """, arguments: [postID])
                    guard placements.count == note.blocks.count else {
                        throw fail("note “\(note.title)” has \(placements.count) blocks, planned \(note.blocks.count)")
                    }
                    for (blockIndex, planned) in note.blocks.enumerated() {
                        let placement = placements[blockIndex]
                        let blockID: String = placement["block_id"]
                        let takes = try Row.fetchAll(db, sql: """
                            SELECT id, label, working_text, status, locked FROM variant
                            WHERE block_id = ? AND deleted_at IS NULL ORDER BY fan_position, id
                            """, arguments: [blockID])
                        let here = "note “\(note.title)” block \(blockIndex + 1) (inventory line \(planned.sourceLine))"
                        guard takes.count == 3 else { throw fail("\(here): \(takes.count) takes") }
                        guard takes.map({ $0["label"] as String? })
                                == [WorkbookPlan.takeLabels.current, WorkbookPlan.takeLabels.rewrite,
                                    WorkbookPlan.takeLabels.locator]
                        else { throw fail("\(here): take labels/order differ") }
                        guard takes.map({ $0["working_text"] as String })
                                == [planned.current, "", planned.locator]
                        else { throw fail("\(here): take texts differ") }
                        guard takes.allSatisfy({ ($0["status"] as String) == "active" && ($0["locked"] as Int) == 0 })
                        else { throw fail("\(here): a take is not active/unlocked") }
                        let first: String = takes[0]["id"]
                        guard (placement["chosen_variant_id"] as String?) == first,
                              (placement["default_variant_id"] as String?) == first
                        else { throw fail("\(here): take 1 is not chosen and default") }
                    }
                }
            }
        }
    }
}
