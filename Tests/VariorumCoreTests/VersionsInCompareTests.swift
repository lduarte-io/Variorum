import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VX-440 batch 1 — SAVED VERSIONS IN COMPARE** (VX-130 · VX-437 · VX-432; the
/// record is `notes/plans/fixes/vx-440-sheets-history-clarity.md`).
///
/// Her VX-437 redirect (2026-10-28), the contract these pins hold at the core
/// layer: *"doesn't it seem wrong for the older version of a note to NOT show up
/// in compare?? … you should be allowed to stop counting it as a version but i
/// think that should mean that it is automatically promoted."*
///
/// **The live check (the record's B1-1), traced first, pinned here where the
/// core decides it.** Compare's auto-fill reads `Queries.versionPeerSplit(…)
/// .sameWing`, which is `versionPeerPosts` split by wing — and that read follows
/// live `version_of` edges with NO version-history or archive fence. A saved
/// version is minted by the copy machine with exactly such an edge, in the
/// source's wing, so it IS a same-wing peer: Compare already seats it and its
/// card already wears "unmark". What "unmark" then does to it at the op level is
/// `NoteVersionsTests.adeliberateUnmarkStillUnlinksAVersion`'s documented
/// behaviour — the pair comes apart and the moment leaks onto the Archived
/// surface. The DOOR that reached that op on a saved version is the defect; its
/// red-on-old pin lives with the door (`CompareViewModelTests
/// .unmarkOnASavedVersionNeverDeclassifiesIt`, Mac suite).
@Suite("VX-440 batch 1 — saved versions in Compare")
struct VersionsInCompareTests {
    // MARK: - The live check: what Compare's auto-fill reads today

    /// **A SAVED VERSION IS A SAME-WING VERSION PEER** — the input Compare's
    /// auto-fill seats from, so a note whose only `version_of` peer is a saved
    /// moment opens Compare with that moment beside it. Her VX-437 ruling makes
    /// this the CONTRACT ("never filtered out of auto-fill"); before it, it was
    /// the unexamined behaviour the scout flagged. Green on both sides by
    /// design: it documents the input, it is not a bug pin.
    @Test func aSavedVersionIsASameWingVersionPeerSoCompareSeatsIt() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "Prose.")
            let version = try ops.saveNoteVersion(note.id).post

            let split = try db.read { try Queries.versionPeerSplit($0, of: note.id) }
            #expect(split.sameWing == [version.id],
                    "the moment rides the copy's version_of edge in the note's own wing")
            #expect(split.otherWings.isEmpty)
            #expect(try db.read { try Queries.isVersionHistory($0, version.id, of: note.id) },
                    "…and the classifier still names it this note's saved version")
        }
    }

    // MARK: - B1-2: the note-driven stamps read (Compare's columns, the latest door)

    /// The listing's ids, in the listing's order — the one answer both reads
    /// must give.
    private func listed(_ db: AppDatabase, _ note: String) throws -> [String] {
        try db.read { try Queries.noteVersions($0, of: note).map(\.postID) }
    }

    private func stamped(_ db: AppDatabase, _ note: String) throws -> [String] {
        try db.read { try Queries.noteVersionStamps($0, of: note).map(\.postID) }
    }

    /// **THE STAMPS ARE THE LISTING'S OWN ANSWER, NEWEST FIRST** — same
    /// classifier, same order, so Compare's columns and Note ▸ Versions can
    /// never disagree about which moments a note has; the latest is the first.
    /// An ordinary duplicate (a version LINK, born live) is never a moment.
    @Test func theStampsAreTheListingsOwnAnswerNewestFirst() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "Prose.")
            #expect(try stamped(db, note.id).isEmpty)
            #expect(try db.read { try Queries.latestNoteVersionID($0, of: note.id) } == nil,
                    "no moment ⇒ the latest door has no target (and renders nowhere)")

            let first = try ops.saveNoteVersion(note.id).post
            _ = try ops.duplicateAsVersion(note.id)  // a link, never a moment
            let second = try ops.saveNoteVersion(note.id).post
            let third = try ops.saveNoteVersion(note.id).post

            #expect(try stamped(db, note.id) == [third.id, second.id, first.id])
            #expect(try stamped(db, note.id) == listed(db, note.id),
                    "one classifier, one order — the pane and the board agree")
            #expect(try db.read { try Queries.latestNoteVersionID($0, of: note.id) } == third.id)
            let stamps = try db.read { try Queries.noteVersionStamps($0, of: note.id) }
            #expect(stamps.first?.savedAt == third.createdAt,
                    "the moment's derived name is its birth stamp (V6)")
        }
    }

    /// **THE NOTE SIDE IS READ PAST ITS TOMBSTONES, AS THE CLASSIFIER READS IT**
    /// (LR1-1's shapes): merging the anchor block away, archiving it, deleting
    /// it — the moments stay the note's in the listing, so they stay in the
    /// stamps too. A deliberate unlink and a promote take a moment out of both.
    @Test func theStampsFollowTheListingAcrossTheAnchorsShapes() throws {
        try withOperations { ops, db in
            // merge releases the anchor's placement
            let merged = try ops.createPost(title: "merged")
            let m1 = try ops.newBlock(in: merged.id, text: "One.")
            let m2 = try ops.newBlock(in: merged.id, text: "Two.")
            let mv = try ops.saveNoteVersion(merged.id).post
            _ = try ops.merge(m1.block.id, m2.block.id)
            #expect(try stamped(db, merged.id) == [mv.id])
            #expect(try stamped(db, merged.id) == listed(db, merged.id))

            // archiveBlock releases it to the tray
            let archived = try ops.createPost(title: "archived")
            let a1 = try ops.newBlock(in: archived.id, text: "One.")
            _ = try ops.newBlock(in: archived.id, text: "Two.")
            let av = try ops.saveNoteVersion(archived.id).post
            try ops.archiveBlock(a1.block.id)
            #expect(try stamped(db, archived.id) == [av.id])
            #expect(try stamped(db, archived.id) == listed(db, archived.id))

            // deleteBlock cascade-tombstones the edge itself (its exact stamp)
            let deleted = try ops.createPost(title: "deleted")
            let d1 = try ops.newBlock(in: deleted.id, text: "One.")
            _ = try ops.newBlock(in: deleted.id, text: "Two.")
            let dv = try ops.saveNoteVersion(deleted.id).post
            try ops.deleteBlock(d1.block.id)
            #expect(try stamped(db, deleted.id) == [dv.id])
            #expect(try stamped(db, deleted.id) == listed(db, deleted.id))

            // a deliberate unlink (the road VX-437 closes at the door) and a
            // promote both take the moment out of the note's past — in both reads
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "Prose.")
            let kept = try ops.saveNoteVersion(note.id).post
            let unlinked = try ops.saveNoteVersion(note.id).post
            let promoted = try ops.saveNoteVersion(note.id).post
            try ops.unmarkPostsAsVersions(note.id, unlinked.id)
            try ops.promoteNoteVersion(promoted.id, of: note.id)
            #expect(try stamped(db, note.id) == [kept.id])
            #expect(try stamped(db, note.id) == listed(db, note.id))

            // and a moment sent to the Trash is no longer one
            try ops.deleteContainer(kept.id)
            #expect(try stamped(db, note.id).isEmpty)
            #expect(try listed(db, note.id).isEmpty)
        }
    }

    /// **NOTE-DRIVEN, NEVER THE CORPUS'S MOMENTS** (P1): the candidates are
    /// reached from the note's own placements through the edge indexes, and
    /// the outer row is a SEEK by id — the read never walks every saved moment
    /// in the library the way the summoned listing does. Pinned on the plan
    /// SQLite chooses, so a rewrite that falls back to the corpus walk shows.
    @Test func theStampsReadIsDrivenFromTheNotesOwnPlacements() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "Prose.")
            _ = try ops.saveNoteVersion(note.id)
            let other = try ops.createPost(title: "another note")
            _ = try ops.newBlock(in: other.id, text: "More.")
            _ = try ops.saveNoteVersion(other.id)

            let plan = try db.read { db -> [String] in
                // The statement `noteVersionStamps` runs, asked for its plan
                // through GRDB's own trace of the real call.
                var details: [String] = []
                let sqlCapture = SQLCapture()
                db.trace { event in
                    if case .statement(let statement) = event { sqlCapture.last = statement.sql }
                }
                _ = try Queries.noteVersionStamps(db, of: note.id, limit: 1)
                db.trace(options: [], nil)
                let sql = try #require(sqlCapture.last)
                for row in try Row.fetchAll(
                    db, sql: "EXPLAIN QUERY PLAN " + sql,
                    arguments: ["note": note.id, "limit": 1]) {
                    details.append(row["detail"] ?? "")
                }
                return details
            }
            #expect(plan.contains { $0.contains("SEARCH theirs USING INDEX idx_cblock_order") },
                    "the candidates come from the note's own placements: \(plan)")
            #expect(plan.contains { $0.contains("idx_edge_source") }
                    && plan.contains { $0.contains("idx_edge_target") },
                    "both link directions seek: \(plan)")
            #expect(plan.contains { $0.hasPrefix("SEARCH v ") && $0.contains("id=?") },
                    "the moment row is a seek by id, never a walk of the corpus's moments: \(plan)")
            #expect(!plan.contains { $0.hasPrefix("SCAN") },
                    "nothing is scanned whole: \(plan)")
        }
    }
}

/// A box the trace closure can write into (the closure is `@Sendable`).
private final class SQLCapture: @unchecked Sendable {
    var last: String?
}
