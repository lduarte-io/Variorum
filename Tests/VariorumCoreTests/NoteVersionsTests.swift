import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **THE VERSIONS FAMILY** (the post-13l polish round, ledger rows 16 and 23 —
/// G1 and the V-rulings). The Google-Docs answer: *"my whole note at this point
/// in time."*
///
/// The pins here are about the four things that make it a family rather than a
/// copy button: the BIRTH FACT that classifies a version (V1), the SEAL that
/// freezes it (V4b), the IDENTITY-PRESERVING restore (V4, her seventh-sitting
/// catch), and the DELETION RIDE with its exact-stamp revival (V2).
@Suite("The versions family (the post-13l polish round, rows 16/23)")
struct NoteVersionsTests {
    // MARK: - Save (V1 · V4b · V6)

    /// **BORN ARCHIVED AND BORN SEALED, FROM ONE CLOCK READ.** The equality
    /// `archived_at == created_at` IS the classifier, so it may never depend on
    /// how fast the machine is — the harness clock ticks a second per read,
    /// which is exactly the world that would catch a second `date.now`.
    @Test func aSavedVersionIsBornArchivedAndSealedFromOneClockRead() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "Prose.")

            let version = try ops.saveNoteVersion(note.id).post
            let row = try #require(try db.read { try Container.fetchOne($0, key: version.id) })
            #expect(row.archivedAt == row.createdAt,
                    "the birth fact: one clock read decides both stamps")
            #expect(row.locked, "a moment is frozen — the seal is what freezes it (V4b)")
            #expect(row.lockedAt == row.createdAt)
            #expect(row.title == "the note", "no title mutation (V6) — the date is derived")
        }
    }

    /// The listing and the Archived surface are **exact complements**: the one
    /// place a saved moment lives is its note's Versions.
    @Test func aVersionListsUnderItsNoteAndNeverAmongTheArchivedNotes() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "Prose.")
            let work = try ops.createPost(title: "a work I set aside")
            _ = try ops.newBlock(in: work.id, text: "More prose.")
            try ops.archiveContainer(work.id)

            let version = try ops.saveNoteVersion(note.id).post

            let listed = try db.read { try Queries.noteVersions($0, of: note.id) }
            #expect(listed.map(\.postID) == [version.id])
            #expect(listed.first?.blockCount == 1)
            #expect(listed.first?.preview == "Prose.")
            #expect(listed.first?.cadence == .manual,
                    "13w's automated rotation fills the same listing; the slot exists now")

            let archived = try db.read { try Queries.archivedPosts($0) }
            #expect(!archived.map(\.postID).contains(version.id))
            #expect(archived.map(\.postID).contains(work.id))
        }
    }

    /// **Her sixth-sitting catch, from the other side:** a note that was ever
    /// LIVE is a WORK. `duplicateAsVersion` is the live-fork road (lifecycle row
    /// N6), so archiving one later must never make it read as version history.
    @Test func aLiveForkArchivedLaterIsAWorkAndNeverAVersion() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "Prose.")
            let fork = try ops.duplicateAsVersion(note.id).post
            try ops.archiveContainer(fork.id)

            #expect(try db.read { try Queries.noteVersions($0, of: note.id) }.isEmpty)
            #expect(try db.read { try Queries.archivedPosts($0) }
                .map(\.postID).contains(fork.id))
        }
    }

    /// **ARCHIVING A NOTE MUST NOT DOUBLE-LIST ITS VERSIONS** — the complement
    /// property, which is why batch 5 dropped the peer's `archived_at IS NULL`
    /// clause from `archivedPosts`' fence. An archived note is a WORK she set
    /// aside; its past is still its own.
    @Test func archivingANoteLeavesItsVersionsInItsOwnListingOnly() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "Prose.")
            let version = try ops.saveNoteVersion(note.id).post
            try ops.archiveContainer(note.id)

            let archived = try db.read { try Queries.archivedPosts($0) }.map(\.postID)
            #expect(archived.contains(note.id), "the note itself is a set-aside work")
            #expect(!archived.contains(version.id),
                    "its moments stay in its Versions — never both places at once")
            #expect(try db.read { try Queries.noteVersions($0, of: note.id) }
                .map(\.postID) == [version.id])
        }
    }

    /// **V3, half one:** a version of a JOURNAL note carries no `entry_date`.
    /// A saved moment is not a day, and the notebook rule allows one entry per
    /// day. (The bridge half is pinned in `BridgeVersionTests`.)
    @Test func aVersionOfAJournalNoteCarriesNoEntryDate() throws {
        try withOperations { ops, db in
            let day = try ops.createOrOpenJournalEntry(entryDate: "2026-08-25").container
            _ = try ops.newBlock(in: day.id, text: "What happened today.")

            let version = try ops.saveNoteVersion(day.id).post
            #expect(version.entryDate == nil)
            #expect(version.profile == .journal, "the KIND of writing is preserved")
            // The day still opens to the note, never to its moment.
            let canonical = try db.read {
                try Queries.canonicalJournalEntry($0, day: "2026-08-25")
            }
            #expect(canonical?.id == day.id)
        }
    }

    @Test func savingAVersionOfABlocklessNoteRefuses() throws {
        try withOperations { ops, _ in
            let note = try ops.createPost(title: "empty")
            #expect(throws: OperationError.postHasNoBlocks(id: note.id)) {
                try ops.saveNoteVersion(note.id)
            }
        }
    }

    // MARK: - Restore (V4 — identity-preserving)

    /// **THE NOTE BECOMES ITS PAST, KEEPING ITS IDENTITY** — her seventh-sitting
    /// catch made real: the same container, the same id, the same memberships;
    /// only the content changes, and a version of NOW is saved first.
    @Test func restoringAVersionKeepsTheNoteAndSavesNowFirst() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "The first thing I wrote.")
            let book = try ops.createReading(name: "a book", kind: .curated)
            _ = try ops.addPostToReading(note.id, to: book.id)

            let version = try ops.saveNoteVersion(note.id).post

            // She writes on.
            let block = try ops.newBlock(in: note.id, text: "A second paragraph.")
            _ = block

            let result = try ops.restoreNoteVersion(note.id, from: version.id)
            #expect(result.restoredFrom == version.id)
            #expect(result.blocksRestored == 1)
            #expect(result.blocksRemoved == 2)
            let savedNow = try #require(result.savedVersionID)

            // Same container, same books.
            let header = try #require(try db.read {
                try Container.fetchOne($0, key: note.id)
            })
            #expect(header.deletedAt == nil && header.archivedAt == nil)
            #expect(try db.read { try Queries.readingsContaining($0, postID: note.id) }
                .map(\.id) == [book.id])

            // Its content IS the version's.
            #expect(try db.read { try Queries.renderedText($0, containerID: note.id) }
                    == "The first thing I wrote.")

            // …and the moment before the restore is the newest row in the
            // listing, so the restore is never a one-way door.
            let listed = try db.read { try Queries.noteVersions($0, of: note.id) }
            #expect(listed.map(\.postID) == [savedNow, version.id])
            #expect(try db.read { try Queries.renderedText($0, containerID: savedNow) }
                    == "The first thing I wrote.\n\nA second paragraph.")
        }
    }

    /// **THE OUTGOING BLOCKS TAKE THE DELETE NOW ROAD** — her eighth-sitting
    /// ruling, in the S2-safe shape: a tombstone plus a purge intent, so the
    /// rows leave every surface AT ONCE and never make Trash noise.
    @Test func theRestoresOutgoingBlocksLeaveEverySurfaceAtOnce() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "Kept.")
            let version = try ops.saveNoteVersion(note.id).post
            let doomed = try ops.newBlock(in: note.id, text: "Written after the moment.")

            _ = try ops.restoreNoteVersion(note.id, from: version.id)

            let row = try #require(try db.read { try Block.fetchOne($0, key: doomed.block.id) })
            #expect(row.deletedAt != nil, "a tombstone, never a raw row DELETE (S2)")
            let intents = try db.read {
                try Int.fetchOne(
                    $0,
                    sql: """
                        SELECT COUNT(*) FROM purge_intent
                        WHERE table_name = 'block' AND row_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [doomed.block.id])
            }
            #expect(intents == 1, "the intent is what makes it instant")
            let now = Date(timeIntervalSince1970: 1_782_864_000)
            #expect(!(try db.read { try Queries.trash($0, now: now) })
                .map(\.id).contains(doomed.block.id),
                    "the read-side fence hides an intented row from the Trash")
            #expect(!(try db.read {
                try Queries.trayBlocks($0, postID: note.id, now: now)
            }).map(\.blockID).contains(doomed.block.id),
                    "…and from the note's own tray")
        }
    }

    /// **RESTORING KEEPS EVERY VERSION LINK.** The post-level link rides a
    /// block-level edge anchored on the note's FIRST block, and the restore
    /// deletes that block — so without the re-anchor a restore would silently
    /// orphan every moment the note has, including the one it just saved.
    @Test func restoringAVersionKeepsEveryVersionLink() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "One.")
            let first = try ops.saveNoteVersion(note.id).post
            _ = try ops.newBlock(in: note.id, text: "Two.")
            let second = try ops.saveNoteVersion(note.id).post

            let result = try ops.restoreNoteVersion(note.id, from: first.id)
            let savedNow = try #require(result.savedVersionID)

            let listed = try db.read { try Queries.noteVersions($0, of: note.id) }
                .map(\.postID)
            #expect(Set(listed) == [first.id, second.id, savedNow],
                    "every moment survives the restore that deleted their anchor")
            // …and none of them leaked onto the Archived surface.
            #expect(try db.read { try Queries.archivedPosts($0) }.isEmpty)
        }
    }

    /// Fully repeatable — restore the restore (her N2 lifecycle row).
    @Test func aRestoreIsRepeatable() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "Original.")
            let original = try ops.saveNoteVersion(note.id).post
            _ = try ops.newBlock(in: note.id, text: "Later thought.")

            _ = try ops.restoreNoteVersion(note.id, from: original.id)
            #expect(try db.read { try Queries.renderedText($0, containerID: note.id) }
                    == "Original.")
            // The moment before that restore holds the later thought — restore
            // IT and the note comes forward again.
            let forward = try #require(
                try db.read { try Queries.noteVersions($0, of: note.id) }.first)
            _ = try ops.restoreNoteVersion(note.id, from: forward.postID)
            #expect(try db.read { try Queries.renderedText($0, containerID: note.id) }
                    == "Original.\n\nLater thought.")
        }
    }

    @Test func restoreRefusesUnderASealAndRefusesSomethingThatIsNotAVersion() throws {
        try withOperations { ops, _ in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "Prose.")
            let version = try ops.saveNoteVersion(note.id).post
            let stranger = try ops.createPost(title: "not a version")
            _ = try ops.newBlock(in: stranger.id, text: "Elsewhere.")

            #expect(throws: OperationError.notVersionHistory(
                version: stranger.id, note: note.id)) {
                try ops.restoreNoteVersion(note.id, from: stranger.id)
            }
            try ops.lockPost(note.id)
            #expect(throws: OperationError.lockedPost(id: note.id)) {
                try ops.restoreNoteVersion(note.id, from: version.id)
            }
        }
    }

    // MARK: - Promote (V1's "work with it as a new note" road)

    /// **PROMOTE IS ONE-WAY BY DERIVATION**, which is her word *"forever"*:
    /// clearing `archived_at` breaks the birth fact, and re-archiving stamps a
    /// LATER `archived_at`, which is what a set-aside WORK looks like.
    @Test func promotingAVersionMakesItFirstClassForeverByDerivation() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "Prose.")
            let version = try ops.saveNoteVersion(note.id).post

            try ops.promoteNoteVersion(version.id, of: note.id)
            let promoted = try #require(try db.read { try Container.fetchOne($0, key: version.id) })
            #expect(promoted.archivedAt == nil && !promoted.locked,
                    "live and writable — the seal came off with the archive")
            #expect(try db.read { try Queries.noteVersions($0, of: note.id) }.isEmpty)
            #expect(try db.read { try Queries.library($0) }.map(\.postID).contains(version.id))

            // Archived later: a WORK, never version history again.
            try ops.archiveContainer(version.id)
            #expect(try db.read { try Queries.noteVersions($0, of: note.id) }.isEmpty)
            #expect(try db.read { try Queries.archivedPosts($0) }
                .map(\.postID).contains(version.id))
        }
    }

    // MARK: - The deletion ride (V2, ratified)

    /// **VERSIONS ARE THE NOTE'S PAST, AND A THING'S PAST GOES WHERE THE THING
    /// GOES** — on the note's EXACT stamp, so the revival can tell them apart
    /// from anything that diverged.
    @Test func deletingANoteTakesItsVersionsOnItsOwnStamp() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "One.")
            let first = try ops.saveNoteVersion(note.id).post
            _ = try ops.newBlock(in: note.id, text: "Two.")
            let second = try ops.saveNoteVersion(note.id).post
            let bystander = try ops.createPost(title: "another note")
            _ = try ops.newBlock(in: bystander.id, text: "Untouched.")
            let bystanderVersion = try ops.saveNoteVersion(bystander.id).post

            try ops.deleteContainer(note.id)

            let stamps = try db.read { db -> [String: String?] in
                var out: [String: String?] = [:]
                for id in [note.id, first.id, second.id, bystanderVersion.id] {
                    out[id] = try String.fetchOne(
                        db, sql: "SELECT deleted_at FROM container WHERE id = ?",
                        arguments: [id])
                }
                return out
            }
            let noteStamp = try #require(stamps[note.id] ?? nil)
            #expect(stamps[first.id] ?? nil == noteStamp)
            #expect(stamps[second.id] ?? nil == noteStamp)
            #expect(stamps[bystanderVersion.id] ?? nil == nil,
                    "another note's moments are none of this deletion's business")
        }
    }

    /// **PUT THE NOTE BACK AND ITS VERSIONS COME BACK** — the exact-stamp
    /// revival, with everything that diverged left exactly as it was.
    @Test func puttingTheNoteBackBringsItsVersionsBackAndLeavesTheDivergedDead()
        throws
    {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "One.")
            let rides = try ops.saveNoteVersion(note.id).post
            let cutEarlier = try ops.saveNoteVersion(note.id).post
            try ops.deleteContainer(cutEarlier.id)  // her own deliberate act, its own stamp

            try ops.deleteContainer(note.id)
            try ops.restoreContainer(note.id)

            let listed = try db.read { try Queries.noteVersions($0, of: note.id) }
                .map(\.postID)
            #expect(listed == [rides.id],
                    "the one that rode comes back; the one she cut earlier stays cut")
            #expect(try db.read { try Queries.renderedText($0, containerID: rides.id) }
                    == "One.", "and its own blocks and takes came back with it")
        }
    }

    /// **A DELETED VERSION IS AN HONEST TRASH ROW** (FOUND-ITEM 1, ratified):
    /// on the clock, named as a saved moment, gathered under its note.
    @Test func aDeletedVersionRowsInTheTrashUnderItsNote() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "Prose.")
            let version = try ops.saveNoteVersion(note.id).post
            try ops.deleteContainer(version.id)

            let now = Date(timeIntervalSince1970: 1_782_864_000)
            let rows = try db.read { try Queries.trash($0, now: now) }
            let row = try #require(rows.first { $0.id == version.id })
            #expect(row.kind == .note, "a version IS a container — one road, one door set")
            #expect(row.isVersion)
            #expect(row.versionOfNoteID == note.id)
            #expect(row.noteTitle == "the note")

            // …and Put back returns it to the listing.
            try ops.restoreContainer(version.id)
            #expect(try db.read { try Queries.noteVersions($0, of: note.id) }
                .map(\.postID) == [version.id])
        }
    }

    /// An ordinary note in the Trash is never mistaken for a moment.
    @Test func anOrdinaryDeletedNoteIsNotAVersionRow() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "Prose.")
            _ = try ops.saveNoteVersion(note.id)
            try ops.deleteContainer(note.id)

            let now = Date(timeIntervalSince1970: 1_782_864_000)
            let rows = try db.read { try Queries.trash($0, now: now) }
            let noteRow = try #require(rows.first { $0.id == note.id })
            #expect(!noteRow.isVersion && noteRow.versionOfNoteID == nil)
            #expect(rows.filter(\.isVersion).count == 1, "its one moment rode along")
        }
    }
}
