import Foundation
import GRDB

// VX-309 U1b — T-8: A PLAINTEXT EXPORT BROUGHT IN AS A NEW LIBRARY (the orchestrator's mapping ruling, the plan's §5b-R:
// "Content and its placement ride — including its kept-out-of-view-ness; configuration does not"). Bulk entry THROUGH THE
// IMPORT ROAD, never reconciled truth: every row is minted fresh in the new library by the ordinary operations, and the
// export — an unencrypted `.sqlite` (`StorePlaintextExport`, `LibraryClassifier.plaintextExport`) — is only ever READ, on a
// private staged copy (`LibraryClassifier.withStagedRead`). Two halves:
//
//   - THE READ (`PlaintextExportReading.read(exportAt:)`, pure past the disk): the export's applied migrations must be a
//     SUBSET of this build's (`schemaNewer` otherwise — a newer Variorum wrote it; VX-502, her ratified rule 2026-10-27,
//     supersedes P-VX309-U1b-7; the gate's comment carries the standing feature-detect duty that keeps it safe); then
//     each living note's text through Copy full text's OWN projection (`Queries.variorumDocumentText` — the title, every
//     live take, the tags), parsed by `VariorumDocument.parse` (the import road's one reader); its books (members in the
//     export's `(position, id)` order, filed under their chapters, a dangling chapter read as unfiled), its snippet groups
//     (each scrap's rendered text), its wings; note VERSIONS (`archived_at == created_at`) never ride.
//   - THE APPLY (`Operations.importPlaintextExport`): every wing that holds content minted by name (its notes and books
//     landing in it, their tags adopting per wing — R-13ia-1); every note once (`importDocument` — rows fresh); every book
//     (`createReading` + its chapters + each member ADDED in the export's order — once, membered in each: the many-readings
//     default), ARCHIVED books first (each archived as it lands, so a live book's name never meets its own archived twin);
//     an empty book is left out and NAMED; archived notes and archived snippet groups archived after their memberships;
//     snippet groups minted with their scraps (`createPool` + `importBlocks`). No undo entry (a library's birth — the
//     caller's operations carry no undo stack). What landed is counted (`PlaintextExportLanding`) so a partial landing is
//     visible against the receipt (the ruling's one requirement on the crash window).

/// **What a plaintext export holds, as the import road will mint it.**
public struct PlaintextExportPlan: Equatable, Sendable {
    public struct Wing: Equatable, Sendable {
        public var id: String
        public var name: String
    }

    public struct Note: Equatable, Sendable {
        /// The note's id IN THE EXPORT (never minted again — the apply maps it).
        public var id: String
        public var wingID: String
        public var archived: Bool
        public var document: VariorumDocument.NamedDocument
    }

    public struct Book: Equatable, Sendable {
        public struct Chapter: Equatable, Sendable {
            public var id: String
            public var name: String
        }

        public struct Member: Equatable, Sendable {
            public var noteID: String
            /// Its chapter's id in the export (nil, or one no live chapter carries: unfiled).
            public var chapterID: String?
        }

        public var name: String
        public var wingID: String
        public var archived: Bool
        /// In the export's `(position, id)` order.
        public var chapters: [Chapter]
        /// In the export's `(position, id)` order.
        public var members: [Member]
    }

    public struct Pool: Equatable, Sendable {
        public var title: String?
        public var archived: Bool
        /// Each scrap's rendered text, in the group's own order.
        public var scraps: [String]
    }

    public var wings: [Wing]
    /// Every living note (archived ones included, versions never), in the export's `(created_at, id)` order.
    public var notes: [Note]
    public var books: [Book]
    public var pools: [Pool]

    public init(wings: [Wing] = [], notes: [Note] = [], books: [Book] = [], pools: [Pool] = []) {
        self.wings = wings
        self.notes = notes
        self.books = books
        self.pools = pools
    }
}

/// **What landed** — the receipt's facts and the log line's (a partial landing reads against them).
public struct PlaintextExportLanding: Equatable, Sendable {
    public var books = 0
    public var notes = 0
    public var snippets = 0
    /// The wings minted (the export's wings that held content).
    public var wings = 0
    /// Books the export held with no living member note — left out, by name.
    public var emptyBooks: [String] = []
    /// Memberships an operation refused (a note membered across wings, say) — said in the log, never silent.
    public var membershipsLeftOut = 0

    public init() {}
}

public enum PlaintextExportReading {
    public enum Failure: Error, Equatable, Sendable {
        /// The export carries migration identifiers this build has never heard of: a newer Variorum wrote it. Under VX-502's
        /// subset rule this is the ONLY schema refusal — an earlier build's export reads.
        case schemaNewer
        /// Not a Variorum plaintext export.
        case notAnExport
        /// A note's text could not be read back through the document format (the export's own projection) — named.
        case unreadableNote(title: String, line: Int?)
    }

    /// The export at `url` read into a plan — on a private staged copy, never the picked file in place.
    public static func read(exportAt url: URL) throws -> PlaintextExportPlan {
        try LibraryClassifier.withStagedRead(of: url, key: nil) { db in try plan(db) }
    }

    /// The plan, from an open export.
    static func plan(_ db: Database) throws -> PlaintextExportPlan {
        guard try db.tableExists("grdb_migrations"), try db.tableExists("container") else { throw Failure.notAnExport }
        // THE GATE — VX-502 (her ratified rule, 2026-10-27; supersedes P-VX309-U1b-7): an export whose applied migrations
        // are a SUBSET of this build's known set is read; one carrying an identifier this build has never heard of was
        // written by a newer Variorum and refuses. An earlier build's export reads because its physical schema already
        // holds everything this reader touches (the VX-502 record's D-A2 verification, column by column: the newest column
        // read is `reading.archived_at`, v1_21; no content-bearing export predates v1_31 — VX-461).
        // THE STANDING DUTY: any future migration that changes a table this reader touches — here and in everything it
        // calls (`Queries.variorumDocumentText` with its record decodes, `blockPresentations`, `exportBlocks`) — must add
        // a feature-detect, the `hasStatus` precedent below: an older export must keep reading. A file whose physical
        // schema predates the reader's needs (never a real export) throws a database error, which the door's generic
        // catch refuses honestly.
        let applied = try Set(String.fetchAll(db, sql: "SELECT identifier FROM grdb_migrations"))
        let known = Set(AppDatabase.migrator.migrations)
        guard applied.isSubset(of: known) else { throw Failure.schemaNewer }

        var plan = PlaintextExportPlan()
        plan.wings = try Row.fetchAll(
            db, sql: "SELECT id, name FROM wing WHERE deleted_at IS NULL ORDER BY position, id"
        ).map { PlaintextExportPlan.Wing(id: $0["id"], name: $0["name"]) }

        // Every living note — a VERSION (born archived on its own creation stamp — AppSpec §9's classifier) never rides.
        let notes = try Row.fetchAll(db, sql: """
            SELECT id, title, entry_date, created_at, wing_id, archived_at FROM container
            WHERE kind = 'post' AND deleted_at IS NULL
              AND NOT (archived_at IS NOT NULL AND archived_at = created_at)
            ORDER BY created_at, id
            """)
        for row in notes {
            let id: String = row["id"]
            let title: String? = row["title"]
            let fallback = DisplayTitle.note(title: title, entryDate: row["entry_date"], createdAt: row["created_at"])
            let text = try Queries.variorumDocumentText(db, postID: id)
            let document: VariorumDocument.Document
            do {
                document = try VariorumDocument.parse(text)
            } catch let failure {
                // A blank note (no title, no tag, no block) reads as the format's stub — an empty note in its place.
                guard failure.reason == .empty else {
                    throw Failure.unreadableNote(title: fallback, line: failure.line)
                }
                document = VariorumDocument.Document(blocks: [])
            }
            plan.notes.append(PlaintextExportPlan.Note(
                id: id, wingID: row["wing_id"] ?? "", archived: (row["archived_at"] as String?) != nil,
                document: VariorumDocument.NamedDocument(fallbackTitle: fallback, document: document)))
        }

        let hasStatus = try db.columns(in: "reading_post").contains { $0.name == "status" }
        let books = try Row.fetchAll(db, sql: """
            SELECT id, name, wing_id, archived_at FROM reading
            WHERE deleted_at IS NULL AND kind IN ('book', 'curated')
            """)
        for row in books {
            let id: String = row["id"]
            let chapters = try Row.fetchAll(
                db, sql: "SELECT id, name FROM reading_section WHERE reading_id = ? AND deleted_at IS NULL ORDER BY position, id",
                arguments: [id]
            ).map { PlaintextExportPlan.Book.Chapter(id: $0["id"], name: $0["name"]) }
            let members = try Row.fetchAll(db, sql: """
                SELECT rp.post_id, rp.section_id FROM reading_post rp
                JOIN container c ON c.id = rp.post_id
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL\(hasStatus ? " AND rp.status = 'member'" : "")
                  AND c.kind = 'post' AND c.deleted_at IS NULL
                ORDER BY rp.position, rp.id
                """, arguments: [id]
            ).map { PlaintextExportPlan.Book.Member(noteID: $0["post_id"], chapterID: $0["section_id"]) }
            plan.books.append(PlaintextExportPlan.Book(
                name: row["name"], wingID: row["wing_id"] ?? "", archived: (row["archived_at"] as String?) != nil,
                chapters: chapters, members: members))
        }
        plan.books.sort { VariorumDocumentFolder.orderedBefore($0.name, $1.name) }

        let pools = try Row.fetchAll(db, sql: """
            SELECT id, title, archived_at FROM container WHERE kind = 'pool' AND deleted_at IS NULL ORDER BY created_at, id
            """)
        for row in pools {
            let id: String = row["id"]
            let title: String? = row["title"]
            let frames = try Queries.blockPresentations(db, containerID: id)
            let scraps = try Queries.exportBlocks(db, postID: id, includeVariants: false, frames: frames)
                .map(\.text).filter { !$0.isEmpty }
            plan.pools.append(PlaintextExportPlan.Pool(
                title: DisplayTitle.isAbsent(title) ? nil : title, archived: (row["archived_at"] as String?) != nil,
                scraps: scraps))
        }
        return plan
    }
}

extension Operations {
    /// **A plaintext export's content minted into THIS library** (T-8 — the mapping ruled at §5b-R; the file header says
    /// how). Every row fresh, through the ordinary operations; no undo entry when this `Operations` carries no undo stack
    /// (the door's — a library's birth). Throws the first operation's refusal (what landed before it stands — counted in
    /// the log by the caller).
    public func importPlaintextExport(
        _ plan: PlaintextExportPlan, landed: ((PlaintextExportLanding) -> Void)? = nil
    ) throws -> PlaintextExportLanding {
        var landing = PlaintextExportLanding()
        defer { landed?(landing) }
        // THE WINGS that hold content, minted by name; Home ('') is virtual; a wing the export no longer has reads as Home.
        var wingIDs: [String: String] = ["": ""]
        let used = Set(plan.notes.map(\.wingID) + plan.books.filter { !$0.members.isEmpty }.map(\.wingID))
        for wing in plan.wings where used.contains(wing.id) {
            wingIDs[wing.id] = try createWing(name: wing.name).id
            landing.wings += 1
        }
        func wing(_ id: String) -> String { wingIDs[id] ?? "" }

        // EVERY NOTE ONCE — rows fresh, tags adopting by path in its wing.
        var noteIDs: [String: String] = [:]
        for note in plan.notes {
            noteIDs[note.id] = try importDocument(note.document, wingId: wing(note.wingID)).post.id
            landing.notes += 1
        }

        // THE BOOKS — archived ones first (each archived as it lands), then the live; a–z within each; an empty one named.
        for book in plan.books.filter(\.archived) + plan.books.filter({ !$0.archived }) {
            let members = book.members.compactMap { member in noteIDs[member.noteID].map { (member, $0) } }
            guard !members.isEmpty else {
                landing.emptyBooks.append(book.name)
                continue
            }
            let reading = try createReading(name: book.name, kind: .book, wingId: wing(book.wingID))
            var chapterIDs: [String: String] = [:]
            for chapter in book.chapters {
                chapterIDs[chapter.id] = try createSection(in: reading.id, name: chapter.name).id
            }
            for (member, noteID) in members {
                do {
                    _ = try addPostToReading(noteID, to: reading.id)
                    if let chapter = member.chapterID, let sectionID = chapterIDs[chapter] {
                        try assignPostToSection(noteID, in: reading.id, section: sectionID)
                    }
                } catch {
                    landing.membershipsLeftOut += 1
                }
            }
            if book.archived { try archiveReading(reading.id) }
            landing.books += 1
        }

        // Kept out of view, as it was — after every membership landed.
        for note in plan.notes where note.archived {
            if let id = noteIDs[note.id] { try archiveContainer(id) }
        }

        // THE SNIPPET GROUPS — each its scraps, in its own order.
        for pool in plan.pools {
            let minted = try createPool(title: pool.title)
            for scrap in pool.scraps { _ = try importBlocks(into: minted.id, text: scrap) }
            if pool.archived { try archiveContainer(minted.id) }
            landing.snippets += 1
        }
        return landing
    }
}
