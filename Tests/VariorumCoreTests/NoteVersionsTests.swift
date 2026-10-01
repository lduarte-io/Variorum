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
    /// day. (The bridge half was pinned in `BridgeVersionTests`, retired with
    /// the bridge on 2026-09-04.)
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
            let book = try ops.createReading(name: "a book", kind: .book)
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

    /// **A RESTORE REBASELINES THE CHURN** (the ladder's LR1-6). AppSpec §10's
    /// meaningful-edit stamp measures `churn / max(baseline, 1)`, and a
    /// restore replaces the note's WHOLE content — so leaving the old
    /// baseline and the old accumulator in place runs the threshold against a
    /// phantom: a long note restored to a short moment would cross on the
    /// next typo, a short one restored to a long moment would never cross at
    /// all. `copyPost` already rebaselines its copy for exactly this reason;
    /// the restore is the same act on the same container.
    @Test func restoringAVersionRebaselinesTheNotesChurn() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            let block = try ops.newBlock(in: note.id, text: "Short.")
            let version = try ops.saveNoteVersion(note.id).post

            // Grow the note well past the moment (this crosses the threshold
            // and rebaselines onto the long text), then type a little more so
            // an accumulator is actually standing when the restore lands.
            let long = String(repeating: "a lot more prose. ", count: 20)
            try ops.autosave(block.variant.id, text: long, charDelta: long.count)
            try ops.autosave(block.variant.id, text: long + "tail", charDelta: 4)
            let before = try #require(try db.read { try Container.fetchOne($0, key: note.id) })
            #expect(before.churnAccumulator > 0)
            #expect(before.baselineLength == long.count)

            _ = try ops.restoreNoteVersion(note.id, from: version.id)

            let after = try #require(try db.read { try Container.fetchOne($0, key: note.id) })
            #expect(after.churnAccumulator == 0,
                    "the churn was against text that is no longer here")
            #expect(after.baselineLength == "Short.".count,
                    "and the baseline is what the note now holds")
        }
    }

    // MARK: - The seal insures what it protects (the ladder's LR1-2)

    /// **A MOMENT IS SEALED, SO THE SEAL INSURES IT** — AppSpec §9's ruled
    /// doctrine, applied rather than re-invented: *"locking a dirty buffer
    /// first appends one quiet auto commit… the guard insures exactly what it
    /// protects."*
    ///
    /// Copies never carry commits (the pool-drag rule, and right), so a saved
    /// moment's takes were born with ZERO savepoints while the seal made that
    /// invisible. PROMOTE takes the seal off — and one edit afterwards then
    /// destroyed the moment's own text with nothing to restore and nothing in
    /// the Trash. This is the sealing-a-post occasion (`lockPost`'s own
    /// helper, called because the mint seals), not a seventh occasion.
    @Test func aMomentsTakesAreInsuredAtBirthSoPromoteCannotDestroyThem() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            let block = try ops.newBlock(in: note.id, text: "The moment's words.")
            _ = try ops.branchVariant(block.block.id, from: block.variant.id)

            let version = try ops.saveNoteVersion(note.id).post

            let takes = try db.read { db in
                try Variant.fetchAll(
                    db,
                    sql: """
                        SELECT v.* FROM variant v
                        JOIN container_block cb ON cb.block_id = v.block_id
                        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                          AND v.deleted_at IS NULL
                        ORDER BY v.fan_position, v.id
                        """,
                    arguments: [version.id])
            }
            #expect(takes.count == 2, "the whole fan rode along (V7's chosen cost)")
            for take in takes {
                let saved = try db.read { db in
                    try String.fetchAll(
                        db,
                        sql: "SELECT text FROM commit_point WHERE variant_id = ? ORDER BY created_at",
                        arguments: [take.id])
                }
                #expect(saved == [take.workingText],
                        "every take of the moment carries a savepoint OF the moment")
            }

            // …and the promise it buys: promote, edit, and the moment is
            // still one restore away.
            try ops.promoteNoteVersion(version.id, of: note.id)
            let first = try #require(takes.first)
            try ops.autosave(first.id, text: "typed over it", charDelta: 13)
            let commits = try db.read { try Queries.commitHistory($0, variantID: first.id) }
            #expect(commits.map(\.text) == ["The moment's words."],
                    "the moment survives the first edit after a promote")
        }
    }

    /// An EMPTY take takes no savepoint — the landing's own rule (*"an empty
    /// body — a landed deletion — takes no commit"*), inherited for free
    /// because this is `lockPost`'s helper and `isDirty` already says so.
    @Test func anEmptyTakeInAMomentTakesNoSavepoint() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            let block = try ops.newBlock(in: note.id, text: "Words.")
            _ = try ops.newBlankVariant(block.block.id)

            let version = try ops.saveNoteVersion(note.id).post

            let rows = try db.read { db in
                try Row.fetchAll(
                    db,
                    sql: """
                        SELECT v.working_text AS text,
                               (SELECT COUNT(*) FROM commit_point c WHERE c.variant_id = v.id)
                                 AS saved
                        FROM variant v
                        JOIN container_block cb ON cb.block_id = v.block_id
                        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                          AND v.deleted_at IS NULL
                        """,
                    arguments: [version.id])
            }
            for row in rows {
                let text: String = row["text"]
                #expect((row["saved"] as Int) == (text.isEmpty ? 0 : 1))
            }
        }
    }

    // MARK: - The classifier survives ordinary work (the ladder's LR1-1)

    /// **MERGING THE NOTE'S FIRST BLOCK MUST NOT EXPEL ITS MOMENTS.**
    ///
    /// The `version_of` edge is anchored on the note's FIRST block (I8 —
    /// posts are edges-only across versions, and edges are block-to-block).
    /// A merge RELEASES its source blocks to lineage: their placements are
    /// tombstoned. If the classifier asked about a LIVE placement, an
    /// ordinary join — the very gesture the round's own tutorial teaches —
    /// would drop every saved moment out of Note ▸ Versions and into the
    /// Archived surface, with Restore and Promote refusing on the way past.
    ///
    /// Lineage is a fact about what happened (the `strandedOriginals`
    /// doctrine): the block WAS this note's, and the moment IS its past.
    @Test func mergingTheNotesFirstBlockKeepsItsMoments() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            let first = try ops.newBlock(in: note.id, text: "One.")
            let second = try ops.newBlock(in: note.id, text: "Two.")
            let version = try ops.saveNoteVersion(note.id).post

            _ = try ops.merge(first.block.id, second.block.id)

            #expect(try db.read { try Queries.noteVersions($0, of: note.id) }
                .map(\.postID) == [version.id],
                "the moment is still this note's past")
            #expect(!(try db.read { try Queries.archivedPosts($0) }
                .map(\.postID).contains(version.id)),
                "and it never leaks onto the Archived surface (V1, both ways)")
            #expect(try db.read { try Queries.isVersionHistory($0, version.id, of: note.id) },
                "so Restore and Promote still authorize")
            #expect(try db.read { try Queries.noteVersionIDs($0, of: note.id) } == [version.id],
                "and the deletion ride still claims it (V2)")
        }
    }

    /// **ARCHIVING THE NOTE'S FIRST BLOCK MUST NOT EXPEL ITS MOMENTS** — the
    /// same mechanism through the other everyday door (`archiveBlock`
    /// tombstones the placement and stamps `last_container_id`).
    @Test func archivingTheNotesFirstBlockKeepsItsMoments() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            let first = try ops.newBlock(in: note.id, text: "One.")
            _ = try ops.newBlock(in: note.id, text: "Two.")
            let version = try ops.saveNoteVersion(note.id).post

            try ops.archiveBlock(first.block.id)

            #expect(try db.read { try Queries.noteVersions($0, of: note.id) }
                .map(\.postID) == [version.id])
            #expect(!(try db.read { try Queries.archivedPosts($0) }
                .map(\.postID).contains(version.id)))
            #expect(try db.read { try Queries.isVersionHistory($0, version.id, of: note.id) })
        }
    }

    /// **DELETING THE NOTE'S FIRST BLOCK MUST NOT EXPEL ITS MOMENTS.** This
    /// leg breaks a different fence: the block tombstone's trigger cascade
    /// tombstones the EDGE itself (`cascade_block_tombstone`), stamped with
    /// the block's own `deleted_at`. That cascade signature is what the
    /// classifier reads past — a deliberate `unmarkPostsAsVersions` carries
    /// no such stamp and still unlinks (pinned below).
    @Test func deletingTheNotesFirstBlockKeepsItsMoments() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            let first = try ops.newBlock(in: note.id, text: "One.")
            _ = try ops.newBlock(in: note.id, text: "Two.")
            let version = try ops.saveNoteVersion(note.id).post

            try ops.deleteBlock(first.block.id)

            #expect(try db.read { try Queries.noteVersions($0, of: note.id) }
                .map(\.postID) == [version.id])
            #expect(!(try db.read { try Queries.archivedPosts($0) }
                .map(\.postID).contains(version.id)))
            #expect(try db.read { try Queries.isVersionHistory($0, version.id, of: note.id) })

            // …and Put back leaves it exactly as it was.
            try ops.restoreBlock(first.block.id)
            #expect(try db.read { try Queries.noteVersions($0, of: note.id) }
                .map(\.postID) == [version.id])
        }
    }

    /// **THE TRASH ROW'S GROUPING SURVIVES THE SAME GESTURES** (the ladder's
    /// LR1-1 rider): a deleted moment must still name the note it is a moment
    /// of after that note's first block has been merged away, or it rows in
    /// the Trash as an anonymous note.
    @Test func aDeletedMomentStillNamesItsNoteAfterAMerge() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            let first = try ops.newBlock(in: note.id, text: "One.")
            let second = try ops.newBlock(in: note.id, text: "Two.")
            let version = try ops.saveNoteVersion(note.id).post

            _ = try ops.merge(first.block.id, second.block.id)
            try ops.deleteContainer(version.id)

            let now = Date(timeIntervalSince1970: 1_782_864_000)
            let row = try #require(
                try db.read { try Queries.trash($0, now: now) }.first { $0.id == version.id })
            #expect(row.isVersion)
            #expect(row.versionOfNoteID == note.id)
            #expect(row.noteTitle == "the note")
        }
    }

    /// **MOVING THE ANCHOR OUT OF THE NOTE IS THE ONE GESTURE READ-SIDE
    /// MEANS CANNOT ANSWER — pinned as the DOCUMENTED behaviour it is.**
    ///
    /// `moveBlock` rewrites the placement's `container_id` in place: no
    /// tombstone, no `last_container_id`, nothing left behind saying the
    /// block was ever this note's. So the moments follow the anchor to its
    /// new home, and no query can tell that from a legitimate re-home. The
    /// durable answer is QUESTIONS #19's option (c) — a post-level link,
    /// which is a schema call and hers (KnownIssues, owner 13w).
    ///
    /// This pin exists so the behaviour is a KNOWN one: if a later change
    /// makes it right, this test says so out loud instead of passing quietly.
    @Test func movingTheAnchorBlockTakesTheMomentsWithItAndThatIsRecorded() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            let first = try ops.newBlock(in: note.id, text: "One.")
            _ = try ops.newBlock(in: note.id, text: "Two.")
            let elsewhere = try ops.createPost(title: "the other note")
            let version = try ops.saveNoteVersion(note.id).post

            try ops.moveBlock(first.block.id, to: elsewhere.id)

            #expect(try db.read { try Queries.noteVersions($0, of: note.id) }.isEmpty,
                    "documented, not desired: the anchor left, so the link left with it")
            #expect(try db.read { try Queries.noteVersions($0, of: elsewhere.id) }
                .map(\.postID) == [version.id],
                "…and it reads as the destination's moment")
            #expect(!(try db.read { try Queries.archivedPosts($0) }
                .map(\.postID).contains(version.id)),
                "it is at least never LOOSE: some live note still claims it")
        }
    }

    /// **…and moved to a POOL the moment is not lost, it is LOOSE** (the
    /// ladder's LR2-5, correcting the KnownIssues row's *"would list
    /// nowhere"*). The Archived surface's fence excludes version history only
    /// where the peer is a live `post`; a scraps area is a `pool`, so the
    /// fence stops holding and the moment RENDERS THERE — a sealed, unnamed
    /// stranger among her set-aside works. Recorded as behaviour so the
    /// KnownIssues sentence is checkable rather than remembered.
    @Test func movingTheAnchorToAPoolLeavesTheMomentLooseOnTheArchivedSurface() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            let first = try ops.newBlock(in: note.id, text: "One.")
            _ = try ops.newBlock(in: note.id, text: "Two.")
            let scraps = try ops.createPool(title: "scraps")
            let version = try ops.saveNoteVersion(note.id).post

            try ops.moveBlock(first.block.id, to: scraps.id)

            #expect(try db.read { try Queries.noteVersions($0, of: note.id) }.isEmpty,
                    "documented, not desired: the anchor left the note")
            #expect(try db.read { try Queries.archivedPosts($0) }
                .map(\.postID).contains(version.id),
                "and with no live NOTE peer to fence it, it rows among the archived works")
            let row = try #require(try db.read { try Container.fetchOne($0, key: version.id) })
            #expect(row.locked, "…still sealed, which is what makes it read as a stranger")
        }
    }

    /// **THE UNLINK STILL UNLINKS.** Reading past the cascade's tombstone must
    /// not read past a deliberate one: `unmarkPostsAsVersions` stamps the edge
    /// with a time no endpoint block shares, so the pair really does come
    /// apart (the R60/R68 door, kept honest by the exact-stamp signature).
    @Test func adeliberateUnmarkStillUnlinksAVersion() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "One.")
            let version = try ops.saveNoteVersion(note.id).post

            try ops.unmarkPostsAsVersions(note.id, version.id)

            #expect(try db.read { try Queries.noteVersions($0, of: note.id) }.isEmpty,
                    "an unmarked pair is not version history any more")
            #expect(try db.read { try Queries.archivedPosts($0) }
                .map(\.postID).contains(version.id),
                "and what is left is an ordinary archived note")
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

    // MARK: - The restore re-anchors what the classifier keeps (the ladder's LR2-1)

    /// Does this moment carry a LIVE `version_of` edge whose note-side
    /// endpoint is a block the note still LIVE-PLACES?
    ///
    /// This is `restoreNoteVersion`'s own step-4 claim, asked of the store —
    /// and it is deliberately STRICTER than the listing's question. The
    /// classifier reads the note side past its tombstones (LR1-1), so a
    /// moment can list happily while its only link hangs off a block the note
    /// released. That state is not stable: a released original is exactly what
    /// the restore's own Delete Now road sweeps in
    /// (`joinStrandedOriginals` → `expandBlock` takes EVERY edge of a stranded
    /// original), and once the janitor executes there is no row left to read
    /// past. **Listed-but-not-anchored is the state that silently expires**,
    /// which is why the restore must leave nothing in it.
    private func liveAnchoredLink(
        _ db: Database, moment momentID: String, note noteID: String
    ) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (
                  SELECT 1 FROM edge e
                  JOIN container_block mine
                    ON mine.block_id IN (e.source_block_id, e.target_block_id)
                   AND mine.container_id = :moment AND mine.deleted_at IS NULL
                  JOIN container_block theirs
                    ON theirs.block_id IN (e.source_block_id, e.target_block_id)
                   AND theirs.block_id <> mine.block_id
                   AND theirs.container_id = :note AND theirs.deleted_at IS NULL
                  JOIN block anchor
                    ON anchor.id = theirs.block_id AND anchor.deleted_at IS NULL
                  WHERE e.type = 'version_of' AND e.deleted_at IS NULL)
                """,
            arguments: ["moment": momentID, "note": noteID]) ?? false
    }

    /// Runs the janitor's physical removal over every standing intent — the
    /// consequence driven rather than argued.
    private func sweepStandingIntents(_ db: AppDatabase) throws {
        try db.write { db in
            try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
            let roots = try Row.fetchAll(
                db,
                sql: """
                    SELECT table_name, row_id FROM purge_intent
                    WHERE deleted_at IS NULL ORDER BY id
                    """
            ).map { SyncPurgeTarget(table: $0["table_name"], rowID: $0["row_id"]) }
            guard !roots.isEmpty else { return }
            let family = try PurgeFamily.expand(db, roots: roots)
            try PurgeFamily.deleteLocal(
                db, family: family, stamp: "2026-08-26T00:00:00.000Z")
        }
    }

    /// **A MOMENT WHOSE ANCHOR WAS MERGED AWAY MUST BE RE-ANCHORED BY THE
    /// RESTORE — the ladder's LR2-1.**
    ///
    /// LR1-1 taught the CLASSIFIER to read past the tombstones an ordinary
    /// join leaves behind, so the moment stays in Note ▸ Versions. Step 4 of
    /// the restore never learned the same lesson: it enumerated peers with
    /// `versionPeerPosts`, which fences all three liveness reads, so exactly
    /// the moments LR1-1 rescued were the ones it skipped. The link then went
    /// on hanging off the released original — and the restore's own Delete Now
    /// road strands that original into the purge family, edges and all.
    ///
    /// So the enumeration is now the classifier's own (`noteVersionIDs`,
    /// unioned with the live compare peers): **one classifier, read by every
    /// scope, the op's read included** (LR1-5's doctrine).
    @Test func restoringReAnchorsAMomentWhoseAnchorWasMergedAway() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            let first = try ops.newBlock(in: note.id, text: "One.")
            let second = try ops.newBlock(in: note.id, text: "Two.")
            let version = try ops.saveNoteVersion(note.id).post

            // Her ordinary prose — the seam join the round's own tutorial
            // teaches. It releases the anchor to lineage.
            _ = try ops.merge(first.block.id, second.block.id)

            let result = try ops.restoreNoteVersion(note.id, from: version.id)
            let savedNow = try #require(result.savedVersionID)

            let listed = try db.read { try Queries.noteVersions($0, of: note.id) }
                .map(\.postID)
            #expect(Set(listed) == [version.id, savedNow],
                    "the listing still claims every moment")
            for moment in [version.id, savedNow] {
                #expect(try db.read { try liveAnchoredLink($0, moment: moment, note: note.id) },
                        "every moment leaves the restore anchored on a block the note places")
            }

            // The consequence, DRIVEN: the restore's Delete Now road strands
            // the released original into the purge family, and `expandBlock`
            // takes every edge it carries. A moment left un-re-anchored has
            // nothing to read past once the janitor executes.
            try sweepStandingIntents(db)
            #expect(Set(try db.read { try Queries.noteVersions($0, of: note.id) }
                .map(\.postID)) == [version.id, savedNow],
                "…and they survive the sweep that follows")
            #expect(try db.read { try Queries.archivedPosts($0) }.isEmpty,
                    "so nothing leaks onto the Archived surface as a sealed stranger")
            #expect(try db.read { try Queries.isVersionHistory($0, version.id, of: note.id) },
                    "and Restore/Promote still authorize afterwards")
        }
    }

    /// The same hole through `archiveBlock` — the placement is tombstoned, so
    /// `versionPeerPosts` skipped the moment here too. The archived block is
    /// never outgoing and never strands (archive rides no deletion — the
    /// covenant), so nothing expires; what was wrong was the op's own claim
    /// that *every* link is re-anchored, and a link left hanging on a block
    /// the note no longer places is one gesture from the merge leg's fate.
    @Test func restoringReAnchorsAMomentWhoseAnchorWasArchived() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            let first = try ops.newBlock(in: note.id, text: "One.")
            _ = try ops.newBlock(in: note.id, text: "Two.")
            let version = try ops.saveNoteVersion(note.id).post

            try ops.archiveBlock(first.block.id)

            let result = try ops.restoreNoteVersion(note.id, from: version.id)
            let savedNow = try #require(result.savedVersionID)

            for moment in [version.id, savedNow] {
                #expect(try db.read { try liveAnchoredLink($0, moment: moment, note: note.id) })
            }
            #expect(Set(try db.read { try Queries.noteVersions($0, of: note.id) }
                .map(\.postID)) == [version.id, savedNow])
        }
    }

    /// And through `deleteBlock`, whose trigger cascade tombstones the EDGE
    /// itself. This is LR2-1's *plain leg*: the deleted anchor is on its own
    /// 30-day clock, and when that clock (or a Delete Now) runs, the edge row
    /// is physically gone — so a moment never re-anchored is unlinked for
    /// good. The restore is the door that can still fix it, and now does.
    @Test func restoringReAnchorsAMomentWhoseAnchorWasDeletedAndThenPurged() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            let first = try ops.newBlock(in: note.id, text: "One.")
            _ = try ops.newBlock(in: note.id, text: "Two.")
            let version = try ops.saveNoteVersion(note.id).post

            try ops.deleteBlock(first.block.id)
            _ = try ops.requestPurge([SyncPurgeTarget(table: "block", rowID: first.block.id)])

            let result = try ops.restoreNoteVersion(note.id, from: version.id)
            let savedNow = try #require(result.savedVersionID)

            try sweepStandingIntents(db)
            #expect(Set(try db.read { try Queries.noteVersions($0, of: note.id) }
                .map(\.postID)) == [version.id, savedNow],
                "the moments outlive the anchor's physical removal")
            for moment in [version.id, savedNow] {
                #expect(try db.read { try liveAnchoredLink($0, moment: moment, note: note.id) })
            }
            #expect(try db.read { try Queries.archivedPosts($0) }.isEmpty)
        }
    }

    /// **THE UNMARK IS STILL RESPECTED BY THE RESTORE** — the guard that
    /// proves the wider enumeration is precise rather than blanket. A pair she
    /// deliberately came apart is not version history any more, so the
    /// classifier does not name it and the restore does not re-mint its link.
    @Test func aRestoreNeverReMintsALinkSheDeliberatelyUnmarked() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note")
            _ = try ops.newBlock(in: note.id, text: "One.")
            let kept = try ops.saveNoteVersion(note.id).post
            let unmarked = try ops.saveNoteVersion(note.id).post
            try ops.unmarkPostsAsVersions(note.id, unmarked.id)

            let result = try ops.restoreNoteVersion(note.id, from: kept.id)
            let savedNow = try #require(result.savedVersionID)

            #expect(Set(try db.read { try Queries.noteVersions($0, of: note.id) }
                .map(\.postID)) == [kept.id, savedNow],
                "the unmarked copy stays out")
            #expect(!(try db.read {
                try liveAnchoredLink($0, moment: unmarked.id, note: note.id)
            }), "and the restore mints it no new link")
            #expect(try db.read { try Queries.archivedPosts($0) }
                .map(\.postID) == [unmarked.id],
                "what is left of it is an ordinary archived note")
        }
    }
}
