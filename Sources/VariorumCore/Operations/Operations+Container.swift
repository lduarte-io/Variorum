import Dependencies
import Foundation
import GRDB

// Container CRUD: posts and pools. Deleting a container tombstones one row
// here — the trigger chain owns the cascade (placements → blocks → variants,
// edges, tags, references, memberships).
extension Operations {
    /// Day keys are canonical "yyyy-MM-dd" or nothing (Phase 9b review
    /// round 2, MINOR 2 — this op was the REMAINING permissive door after
    /// Step 6 closed `setEntryDate`): a malformed key mints a live entry
    /// invisible to its own day (`createOrOpenJournalEntry` never finds
    /// it). The ops boundary is the
    /// enforcement line (Phase 8 round 2's rationale).
    ///
    /// `wingId` (13i-d U5, additive — '' = Home, every existing caller): the
    /// note is born in the wing the author is standing in (the Mac's ⌘N and
    /// toolbar door pass the current wing — §9: a wing is a separate
    /// library, so what she makes there lives there). A wing that is not live
    /// refuses (`wingNotFound`).
    @discardableResult
    public func createPost(
        title: String? = nil,
        profile: Profile? = nil,
        entryDate: String? = nil,
        wingId: String = ""
    ) throws -> Container {
        if let entryDate, !JournalDay.isValid(entryDate) {
            throw OperationError.invalidEntryDate(entryDate)
        }
        return try database.write { db in
            try requireLiveWing(db, wingId)
            return try insertPost(
                db, title: title, profile: profile, entryDate: entryDate, wingId: wingId)
        }
    }

    /// The notebook rule (author, 2026-07-07; Phase 8): the dedicated
    /// journal holds ONE entry per calendar day — "new entry" for a date
    /// that already has a live journal entry OPENS it instead. Enforced
    /// here, at the operations level, deliberately NOT as a DB unique index
    /// (no new sync-repair class): an offline same-day double-create
    /// converges to two visible entries on that day's page, hand-merged.
    ///
    /// When more than one entry carries the date (that converged race),
    /// preference is **unarchived first, then earliest `(created_at, id)`**
    /// — deterministic on every device (`archived_at` is converged metadata).
    /// The live-first tier matters when the author archived one half of a
    /// converged double-create: "Today" must open the entry the day's page
    /// shows, never a list-invisible archived sibling (review round 1). An
    /// archived entry still opens when it is ALL the day has — archive is
    /// kept-out-of-view, not gone, and opening it beats minting the
    /// same-day duplicate the notebook rule exists to prevent.
    public struct JournalEntryResult: Equatable, Sendable {
        public let container: Container
        /// False when the notebook rule opened an existing entry.
        public let created: Bool
    }

    @discardableResult
    public func createOrOpenJournalEntry(entryDate: String) throws -> JournalEntryResult {
        // Well-formedness at the operations boundary (review round 2): a
        // malformed key ("2026-7-7") would create a live entry invisible to
        // the canonical "2026-07-07" — two irreconcilable "same-day" pages
        // and broken lexicographic ordering. This op is the door EXTERNAL
        // day keys arrive through (the phone's capture; historically the
        // Fragments bridge, retired 2026-09-04).
        guard JournalDay.isValid(entryDate) else {
            throw OperationError.invalidEntryDate(entryDate)
        }
        return try database.write { db in
            // ONE preference implementation, shared with every door that
            // opens a day by key (round 2, NIT 5).
            if let existing = try Queries.canonicalJournalEntry(db, day: entryDate) {
                return JournalEntryResult(container: existing, created: false)
            }
            // 13i-d U5 (#169(b), RULED): the day's entry is born in HOME,
            // beside its Journal, whichever wing the door was pressed in.
            let created = try insertPost(
                db, title: nil, profile: .journal, entryDate: entryDate, wingId: "")
            return JournalEntryResult(container: created, created: true)
        }
    }

    /// What `shelveInDailyJournalBook` did, so each surface can speak in its
    /// own voice while there stays exactly ONE implementation of the rules.
    public enum DailyBookShelving: Equatable, Sendable {
        /// The entry joined the designated daily journal book.
        case shelved(readingID: String)
        /// Nothing to do: the pair is already decided — a LIVE membership
        /// (shelved) or a TOMBSTONED one (the author took it off the shelf).
        case alreadyDecided
        /// The daily book is finished (`reading.locked`).
        case bookFinished
        /// The daily book is at its `max_posts` cap.
        case bookAtCapacity
        /// A SMART book is designated as the daily journal — smart readings
        /// have no `reading_post` rows and cannot take memberships at all
        /// (13c Stage 1 ladder, R1-3: this is the refusal an author can
        /// actually cause AND fix, so it is modelled like its siblings
        /// rather than falling into the residual bucket, where it rendered
        /// as `wrongReadingKind(id: "8F3C-…", expected: …)` in front of her).
        case wrongKind
        /// Any other refusal — races (the book or the post died between the
        /// read and the write) and store failures. Carries a short human
        /// phrase, never an error dump (see `residualReason`).
        case refused(String)
        /// 13i-c U2 (the sitting record §6: "`shelveInDailyJournalBook` (an
        /// owned-elsewhere note bells, never throws)"): the ownership table
        /// would not let the entry in as a plain member — the Journal is
        /// plain and another book OWNS the entry, or the Journal is OWNED and
        /// the entry lives in other books — so it WAITS AT THE JOURNAL'S DOOR
        /// as an arrival for her judgment (copy in / move in / dismiss). The
        /// entry still opens; the door names the owner from
        /// `Queries.ownershipFacts`.
        case waitingAtDoor(readingID: String)
    }

    /// **THE SECOND HALF OF THE DAILY DOOR** (Phase 13c, batch 1D — ledger
    /// A1). The day's entry belongs on the shelf: `JournalBooks.openToday`
    /// (⌘J / "Today's Entry") has always done create-or-open AND
    /// `addPostToReading` into the designated daily book — ordinary
    /// membership, R50's letter. Every OTHER door that mints the day's entry
    /// called only the first half, so the entries they made arrived in NO
    /// book, and "posts in no book" is exactly what the Pool surface lists
    /// (R29) — the author's report, verbatim: *"fragments journal did sync
    /// and appear, but not in the journal book, just appeared in the pool."*
    ///
    /// This is that half, made shared so the class cannot recur one door at
    /// a time. Callers: the phone's capture door
    /// (`EntryListViewModel.open(on:)`) and ⌘J / "Today's Entry"
    /// (`JournalBooks.openToday`); the retired Fragments bridge's landing
    /// half was the third door until 2026-09-04.
    ///
    /// **The ENSURE is whole here (author ruling, 13d sitting 2026-07-28 —
    /// QUESTIONS #37 OVERTURNED to option (iii); her words: "the fragments
    /// entries should arrive as part of Journal").** With no daily journal
    /// book designated — or a designation dangling at a deleted book, which
    /// reads the same way — this door now CREATES AND PINS the Journal book
    /// exactly as ⌘J's first press always did, and ⌘J delegates its whole
    /// ensure here. The superseded shape (create-and-pin at the ⌘J door
    /// only, every other door landing bookless and saying so) was a
    /// PROVISIONAL, and its reasoning — "minting a book on her shelf is an
    /// act only a button press she pressed may take" — is the half she
    /// overturned: a Fragments day IS a journal entry, and the journal is
    /// where it belongs whichever door carried it.
    ///
    /// Three rules, each deliberate and each UNCHANGED by that ruling:
    ///
    /// - **NEVER THROWS, so it can never block a mint or a landing.** It
    ///   returns what happened; the caller words it. "Nothing typed in
    ///   either app can be permanently lost" outranks tidiness, so a
    ///   finished book, a full book, a smart book, a failed creation and
    ///   any unexpected error all report rather than propagate.
    /// - **Never re-shelves what she took off the shelf.** ANY membership
    ///   row for the pair — live or tombstoned — means the pair is already
    ///   decided, so a headless round can never undo a deliberate
    ///   `removePostFromReading`.
    /// - **…and that same rule is what makes this a REPAIR**: an entry with
    ///   no membership row of any kind gets shelved whenever a door reaches
    ///   it again, which is how entries that landed bookless before this
    ///   existed find their way onto the shelf.
    ///
    /// What creation does NOT do: it never replaces a book she designated.
    /// A FINISHED, FULL or SMART daily book keeps its own status and its own
    /// wording — those are her deliberate states (the bounded-notebook
    /// flow's expected end among them), and answering them by minting a
    /// second Journal beside the first would be inventing product behavior.
    @discardableResult
    public func shelveInDailyJournalBook(_ postID: String) -> DailyBookShelving {
        do {
            // The ordinary path stays a READ (a designation exists on every
            // round after the first). Only its absence opens a write, and
            // that write re-reads inside the writer — GRDB serializes
            // writers, so two doors racing the very first entry cannot mint
            // two Journal books (the same hazard the Stage B review's
            // read-inside-the-runner fix closed for ⌘J, closed here at the
            // one place all four doors now share).
            let plan: (bookID: String, decided: Bool)
            if let existing = try database.read({ try Self.shelvingPlan($0, postID: postID) }) {
                plan = existing
            } else {
                plan = try database.write { db in
                    if let raced = try Self.shelvingPlan(db, postID: postID) { return raced }
                    let book = try insertDailyJournalBook(db)
                    // A book minted in this transaction can carry no
                    // membership row, so nothing is decided about the pair.
                    return (book.id, false)
                }
            }
            guard !plan.decided else {
                // HER POST-CLOSE RULING (2026-10-03, the plan's addendum —
                // "I think it's fine for it to unarchive when you command
                // J"): the daily door un-archives on EVERY press, a decided
                // pair included — the comes-back decoupled from the filing.
                // The pair itself stays decided (nothing re-files; the
                // never-re-shelve rule untouched), so a deliberate removal
                // is never undone while the Journal still returns. This
                // supersedes P-13ie-U1-12's decided arm ("a decided pair
                // brings nothing back").
                try database.write { db in
                    if let book = try Reading.fetchOne(db, key: plan.bookID),
                       book.deletedAt == nil, book.archivedAt != nil {
                        _ = try unarchiveReading(db, id: plan.bookID, now: date.now)
                    }
                }
                return .alreadyDecided
            }
            // 13i-e — THE COMES-BACK (the sitting record §10: "the daily
            // Journal can be archived, never deleted; it returns when a day
            // arrives"; the identity memo §5 edge 5). ONE write: an ARCHIVED
            // Journal (the derived read finds it — archived is live) is
            // un-archived through `unarchiveReading`'s own body FIRST — its
            // exact-stamp entries return, its catch-up runs — and then the
            // day's entry is filed inside a SAVEPOINT, so a REFUSED filing
            // (finished, full, an ownership bell, another wing) rolls back the
            // filing alone: the day arrived, so the Journal comes back either
            // way, and the bell rings at a door she can see (PROVISIONAL
            // P-13ie-U1-12, its decided arm superseded by her post-close
            // ruling above). A DEAD Journal is not found and mints fresh, as
            // before.
            let refusal: OperationError? = try database.write { db -> OperationError? in
                if let book = try Reading.fetchOne(db, key: plan.bookID),
                   book.deletedAt == nil, book.archivedAt != nil {
                    _ = try unarchiveReading(db, id: plan.bookID, now: date.now)
                }
                do {
                    try db.inSavepoint {
                        _ = try addPostToReading(db, postID, to: plan.bookID, at: .end)
                        return .commit
                    }
                    return nil
                } catch let refused as OperationError {
                    return refused
                }
            }
            if let refusal { throw refusal }
            return .shelved(readingID: plan.bookID)
        } catch OperationError.alreadyInReading {
            // Raced to shelved between the read and the write — the outcome
            // we wanted.
            return .alreadyDecided
        } catch OperationError.lockedReading {
            return .bookFinished
        } catch OperationError.readingAtCapacity {
            return .bookAtCapacity
        } catch OperationError.wrongReadingKind {
            return .wrongKind
        } catch let OperationError.noteOwnedElsewhere(_, readingID, _),
                let OperationError.noteMemberedElsewhere(_, readingID, _) {
            // 13i-c U2 — the bell, never a throw (§6): the pair is rung at
            // the door unless something decided it meanwhile.
            do {
                return try bellAtDailyDoor(postID: postID, readingID: readingID)
                    ? .waitingAtDoor(readingID: readingID) : .alreadyDecided
            } catch {
                return .refused(Self.residualReason(error))
            }
        } catch {
            return .refused(Self.residualReason(error))
        }
    }

    /// The name a freshly created daily journal book takes (13d batch 5:
    /// the constant moves here with the creation it names — the Mac's
    /// `JournalBooks` forwards to it so the two can never drift).
    /// **Lowercased at 13s-b U1b (R-13s-36/38, her words: "if field notes
    /// is lower case, and adventures of sherlock holmes is lower case,
    /// then journal and quicknotes should also default to lowercase" ·
    /// "that's fine for it only changing the defaults for fresh mints"):**
    /// FRESH MINTS ONLY by construction — this constant is read at the
    /// mint (`insertDailyJournalBook`, the phone's starter journal) and as
    /// a storeless display fallback; no writer renames an existing book,
    /// the daily designation derives from the `'daily'` MARKER (never the
    /// name — 13i-a dropped the name leg), and the keeper repair keys the
    /// same marker, so an installed base's "Journal" converges exactly as
    /// before.
    public static let defaultDailyJournalBookName = "journal"

    /// The shelving question, asked once: which book is designated, and is
    /// this pair already decided (ANY membership row — live or tombstoned)?
    /// nil ⇒ no live designation. Used from the read path AND re-used inside
    /// the writer, so the race re-check cannot ask a different question.
    private static func shelvingPlan(
        _ db: Database, postID: String
    ) throws -> (bookID: String, decided: Bool)? {
        guard let bookID = try Queries.dailyJournalBookID(db) else { return nil }
        let decided = try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (
                  SELECT 1 FROM reading_post
                  WHERE reading_id = ? AND post_id = ?
                )
                """,
            arguments: [bookID, postID]) ?? false
        return (bookID, decided)
    }

    /// Creates, designates and pins the daily journal book — the ⌘J door's
    /// long-standing first-press shape, moved here whole by the author's
    /// #37(iii) ruling. Same reading (curated, `profile: "journal"`, sorted
    /// by `entry_date` ascending), same designation, same shelf pin; all
    /// three in the CALLER's transaction so a partial state cannot exist.
    private func insertDailyJournalBook(_ db: Database) throws -> Reading {
        let now = date.now
        let book = Reading(
            id: newID(), ownerId: currentOwnerID(),
            name: Self.defaultDailyJournalBookName, kind: .book,
            // The shared mint-mark: the Journal-keeper repair's predicate
            // filters on exactly this constant (pre-13u Act 0).
            profile: Queries.dailyJournalBookProfile, sortField: .entryDate, sortDir: .desc,
            // 13i-d U5 (#169(b), RULED — KnownIssues row 105): the daily
            // Journal is HOME-ONLY, so its mint's Home is DELIBERATE, never a
            // default that happened to hold — the designation refuses any
            // other wing's book (`setDailyJournalBook`), and no door moves it.
            wingId: "",
            createdAt: now, updatedAt: now)
        try book.insert(db)
        try setDailyJournalBook(db, book.id)
        try setShelfPinned(db, book.id, pinned: true)
        return book
    }

    /// The residual bucket's wording (13c Stage 1 ladder, R1-3). Its
    /// callers put this string in front of the author — the phone's capture
    /// note (and, until 2026-09-04, the retired bridge's status row) — and
    /// raw `String(describing:)` on
    /// an `OperationError` renders its associated values: row ids and
    /// fully-qualified enum case paths. The same batch retired exactly that
    /// pattern in `ShellActions`; this is the same fix at the source.
    ///
    /// What can reach here after the named cases above are races (the
    /// designated book or the entry died between the read and the write)
    /// and store failures. None is actionable, so each gets a short human
    /// phrase and the internals stay out — structurally, not per-case.
    private static func residualReason(_ error: Error) -> String {
        guard let operationError = error as? OperationError else {
            return "the daily journal book could not be reached"
        }
        switch operationError {
        case .readingNotFound:
            return "the daily journal book is no longer there"
        case .containerNotFound, .wrongContainerKind:
            return "the entry is no longer there"
        default:
            return "the daily journal book could not be reached"
        }
    }

    /// The shared mint behind `createPost`, `createOrOpenJournalEntry`,
    /// and `importPost` (internal, one shape — Phase 11b).
    func insertPost(
        _ db: Database, title: String?, profile: Profile?, entryDate: String?,
        wingId: String = ""
    ) throws -> Container {
        let now = date.now
        var post = Container(
            id: newID(), ownerId: currentOwnerID(), kind: .post, title: title,
            profile: profile, entryDate: entryDate, wingId: wingId,
            createdAt: now, updatedAt: now)
        // A journal post defaults to one-block-per-entry (AppSpec §7): the
        // journal restriction is a profile seed, never a data-model split.
        if profile == .journal {
            post.segmentationDefault = .oneBlock
        }
        try post.insert(db)
        return post
    }

    @discardableResult
    public func createPool(title: String? = nil) throws -> Container {
        let now = date.now
        let pool = Container(
            id: newID(), ownerId: currentOwnerID(), kind: .pool, title: title,
            profile: .pool, createdAt: now, updatedAt: now)
        try database.write { db in try pool.insert(db) }
        return pool
    }

    public func renameContainer(_ id: String, title: String?) throws {
        try updateLiveContainer(id) { $0.title = title }
    }

    /// Day keys are canonical "yyyy-MM-dd" or nothing (Phase 9b, Step 6 —
    /// closing the KnownIssues row): this op was the one permissive door to
    /// a malformed key, which the notebook rule's open-by-date would then
    /// never find — a live entry
    /// invisible to its own day. `nil` stays allowed (un-dating a post is
    /// legitimate); the same boundary `createOrOpenJournalEntry` enforces.
    public func setEntryDate(_ id: String, entryDate: String?) throws {
        if let entryDate, !JournalDay.isValid(entryDate) {
            throw OperationError.invalidEntryDate(entryDate)
        }
        try updateLiveContainer(id) { $0.entryDate = entryDate }
    }

    public func setProfile(_ id: String, profile: Profile?) throws {
        try updateLiveContainer(id) { $0.profile = profile }
    }

    public func setSegmentationDefault(_ id: String, segmentation: Segmentation?) throws {
        try updateLiveContainer(id) { $0.segmentationDefault = segmentation }
    }

    /// Sets (or clears, with nil) the per-POST words-based extent TARGET
    /// (13b Stage 4, v1_12 — S4-28.1/N36; the `setReadingWordTarget` twin).
    /// Display/progress semantics only, never an add/type-time refusal —
    /// word counts change with every edit, so nothing gates on them.
    /// Non-positive targets refuse; a no-op set writes nothing (the
    /// identity-level class — no touch, no churn, `updated_at` unmoved).
    /// PROVISIONAL (13b 4F judgment call — the seal posture): a SEALED
    /// post refuses, mirroring the reading extent setters' refuse-under-
    /// locked rule ("extending a finished notebook is un-finishing it
    /// first" — a sealed post is marked complete, and its writing goal is
    /// part of what "complete" froze). The alternative reading — the N34
    /// container-row-metadata-allowed class (title/date/profile/
    /// segmentation stay editable under seal) — is one guard-line away;
    /// recorded in the 4F batch record for the author's walk.
    public func setPostWordTarget(_ id: String, wordTarget: Int?) throws {
        try database.write { db in
            var post = try livePost(db, id)
            try ensureUnlocked(post)
            if let wordTarget, wordTarget <= 0 {
                throw OperationError.invalidExtent(value: wordTarget)
            }
            guard post.wordTarget != wordTarget else { return }
            post.wordTarget = wordTarget
            post.updatedAt = date.now
            try post.update(db)
        }
    }

    /// Floating notes are post *content*, so a locked post refuses the edit
    /// (title/date/profile above are library metadata and stay editable —
    /// the lock freezes edits, commits, order, and chosen variants).
    public func updateFloatingNotes(_ id: String, notes: String?) throws {
        try database.write { db in
            var container = try liveContainer(db, id)
            try ensureUnlocked(container)
            container.floatingNotes = notes
            container.updatedAt = date.now
            try container.update(db)
        }
    }

    /// Domain archive (kept, out of view) — NOT a sync tombstone.
    public func archiveContainer(_ id: String) throws {
        let now = date.now
        try database.write { db in
            try archiveContainerRow(db, id, now: now)
        }
    }

    public func unarchiveContainer(_ id: String) throws {
        try database.write { db in
            try unarchiveContainerRow(db, id)
        }
    }

    /// `archiveContainer`'s row work inside a caller's transaction (VX-184
    /// U5 — `archive_note`): `updateLiveContainer(id, now:)`'s body with the
    /// archive's one mutation, byte-identical (the clock read stays the
    /// door's, before the write, exactly as it was).
    func archiveContainerRow(_ db: Database, _ id: String, now: Date) throws {
            var container = try liveContainer(db, id)
            container.archivedAt = now
            container.updatedAt = now
            try container.update(db)
    }

    /// `unarchiveContainer`'s row work inside a caller's transaction (VX-184
    /// U5 — `unarchive_note`), byte-identical.
    func unarchiveContainerRow(_ db: Database, _ id: String) throws {
            var container = try liveContainer(db, id)
            container.archivedAt = nil
            container.updatedAt = date.now
            try container.update(db)
    }

    /// Tombstone (S2). The trigger chain cascades: placements and their
    /// singly-owned blocks, those blocks' variants/edges/block_tags, plus the
    /// container's reading memberships, post tags, and references.
    ///
    /// **AND ITS SAVED VERSIONS GO WITH IT** (the post-13l polish round,
    /// ledger row 23 — V2, ratified: *"I agree it should auto delete versions
    /// and not ask for a confirmation dialog"*). Her own question had the
    /// recursive answer: **versions ARE the note's past, and a thing's past
    /// goes where the thing goes** — the Google-Docs intuition (delete the
    /// doc, its history goes), and it dissolves the orphaned-version hole
    /// rather than papering over it. They ride the SAME 30-day clock, row in
    /// the Trash under their note's group, and come back with it.
    ///
    /// **It lives HERE, in the operation, and not in a door**, because a note
    /// is deleted through five of them (the `note ▾` menus, the Library rows,
    /// the Pool rows, ⌘-click multi-select, and a redo's re-apply). A rule
    /// that any one of them could forget is a rule that gets forgotten.
    ///
    /// **ONE clock read for the whole compound**: the versions carry the
    /// note's EXACT `deleted_at`, which is what lets `restoreContainer`
    /// recognise them as its cascade victims and lets an independently-deleted
    /// version stay dead (the 13l exact-stamp doctrine).
    /// **AND IT CLEARS THE REDO FUTURE** (17b P6, RUN A batch A1): removing
    /// a note's whole content is a new structural act, and AppSpec §9's rule
    /// has no exception for the recovery-door class that registers nothing.
    /// Without it a redo could revive a block from the abandoned timeline
    /// into a tombstoned note, or refuse on a cascade-tombstoned take and
    /// wedge the session's stack. It runs after the write, so a refusal
    /// leaves the future as it found it. (13j's doctrine — the Trash is the
    /// recovery door, not structural undo — is untouched: this gives
    /// `deleteContainer` no inverse, it only stops an abandoned one.)
    /// Like `register`, it runs OUTSIDE the transaction: a future compound
    /// that composed this op as a leg and then rolled back would still have
    /// cleared the future — the recorded R1-10 class (13c Stage 1), accepted;
    /// no caller composes it today (ladder round 1, hazard note).
    public func deleteContainer(_ id: String) throws {
        try database.write { db in
            try tombstoneNoteFamily(db, id: id, now: date.now)
        }
        undoStack?.clearRedoFuture()
    }

    /// The `deleteContainer` body — the note and its saved versions on ONE
    /// stamp — shared with `deleteReadingWithNotes` (13i-c U2), whose notes
    /// go to the Trash exactly as this door sends one ("versions ride, as
    /// that door's letter says" — the 13i-c plan §6).
    func tombstoneNoteFamily(_ db: Database, id: String, now: Date) throws {
        var container = try liveContainer(db, id)
        for versionID in try Queries.noteVersionIDs(db, of: id) {
            guard var version = try Container.fetchOne(db, key: versionID),
                  version.deletedAt == nil
            else { continue }
            version.deletedAt = now
            version.updatedAt = now
            try version.update(db)
        }
        container.deletedAt = now
        container.updatedAt = now
        try container.update(db)
    }

    /// Undo a `deleteContainer` (author decision 2026-07-05: deleted posts
    /// must be recoverable): clear the container's tombstone and every
    /// cascade victim stamped with its exact `deleted_at` — placements,
    /// their singly-owned blocks (and those blocks' variants/edges/tags via
    /// the shared flip helper), reading memberships, post tags, references.
    /// Independently-deleted rows carry different stamps and stay dead, as
    /// do memberships/applications whose reading or tag died in the
    /// meantime (a live pointer under a dead parent helps nobody).
    ///
    /// **AND ITS VERSIONS COME BACK WITH IT** (the post-13l polish round,
    /// ledger row 23 — V2's other half, and the exact-stamp story it asked
    /// the round to design). A saved version is a separate CONTAINER, so it
    /// is not reachable through the placement cascade the body below walks;
    /// it is identified instead by the classifier plus the note's exact
    /// `deleted_at`, and then restored through this very body — its own
    /// blocks, takes, edges and lenses carry that same stamp, because one
    /// transaction wrote them all.
    ///
    /// What stays dead is what diverged: a version she deleted on its own
    /// earlier carries a different stamp, and so does one deleted after the
    /// note. Both are ordinary Trash rows with their own Put back.
    ///
    /// **13i-c U2 — and OWNERSHIP holds after it** (the 13i-c plan §4 row 8):
    /// the note's revived memberships pass through
    /// `enforceOwnershipAfterRevival` in this transaction — a note that came
    /// back into an owned book AND another (added elsewhere while it lay in
    /// the Trash) keeps its earliest membership, the later one bells or goes,
    /// R2's shape applied locally.
    public func restoreContainer(_ id: String) throws {
        try database.write { db in
            try restoreNoteFamily(db, id: id)
            try enforceOwnershipAfterRevival(db, postIDs: [id], now: date.now)
        }
    }

    /// The `restoreContainer` body — the note and the versions that died with
    /// it, exact-stamp — shared with `restoreReading`'s return-WHOLE half
    /// (13i-c U2: a book deleted with its notes brings them back first).
    func restoreNoteFamily(_ db: Database, id: String) throws {
        let stamp = try Container.fetchOne(db, key: id)?.deletedAt
            .map { DateFormatter.variorumISO8601.string(from: $0) }
        try restoreContainerRows(db, id: id)
        guard let stamp else { return }
        for versionID in try Queries.versionHistoryDeletedWith(db, note: id, stamp: stamp) {
            try restoreContainerRows(db, id: versionID)
        }
    }

    /// One container's own restore — the body `restoreContainer` runs for the
    /// note and then for each version that died with it.
    private func restoreContainerRows(_ db: Database, id: String) throws {
            guard var container = try Container.fetchOne(db, key: id) else {
                throw OperationError.containerNotFound(id: id)
            }
            guard let deletedAt = container.deletedAt else {
                throw OperationError.containerNotDeleted(id: id)
            }
            let stamp = DateFormatter.variorumISO8601.string(from: deletedAt)
            let now = date.now
            let nowStamp = DateFormatter.variorumISO8601.string(from: now)

            // The blocks this cascade took down: reachable through this
            // container's same-stamp placements AND themselves same-stamped.
            let blockIDs = try String.fetchAll(
                db,
                sql: """
                    SELECT b.id FROM block b
                    JOIN container_block cb ON cb.block_id = b.id
                    WHERE cb.container_id = ? AND cb.deleted_at = ? AND b.deleted_at = ?
                    """,
                arguments: [id, stamp, stamp])

            container.deletedAt = nil
            container.updatedAt = now
            // 13i-d U5 — RE-HOME on Put back (PROVISIONAL P-13id-U5-2): a note
            // whose wing was deleted while it lay in the Trash (it listed in
            // HOME's Trash by the dangling-wing rule) comes back as an
            // ordinary HOME note, never a permanently dangling one.
            if try !Queries.wingIsLive(db, id: container.wingId) {
                container.wingId = ""
            }
            try container.update(db)
            // 13j ladder B (B1): a restored row voids any live intent
            // naming it — a leftover intent must never claim it later.
            // Cascade-revived blocks carry no intents of their own (an
            // intent is minted per TRASH ROW, and a cascade victim never
            // lists there), so voiding the container's is the whole job.
            try voidPurgeIntents(db, table: "container", rowID: id)

            // Phase 11 (review round 1, MAJOR): the container's LENSES
            // revive by the exact-stamp contract — BEFORE the block flips
            // below, so each block's cascade flip sees live lenses when it
            // revives that block's picks (the lens-live guard). A lens
            // deleted independently (different stamp) stays dead, and so
            // do its picks.
            try db.execute(
                sql: """
                    UPDATE lens SET deleted_at = NULL, updated_at = ?
                    WHERE container_id = ? AND deleted_at = ?
                    """,
                arguments: [nowStamp, id, stamp])

            // A placement revives only when its block will be live after
            // this restore (dying with us, or independently restored) AND
            // has no live placement meanwhile — a block that was restored
            // and re-placed elsewhere keeps its new home (I2), and one that
            // was restored then re-deleted (different stamp) stays dead.
            // Must run before the block flips below, while `deleted_at =
            // stamp` still identifies "dying with us".
            try db.execute(
                sql: """
                    UPDATE container_block SET deleted_at = NULL, updated_at = ?
                    WHERE container_id = ? AND deleted_at = ?
                      AND block_id IN
                          (SELECT id FROM block WHERE deleted_at IS NULL OR deleted_at = ?)
                      AND block_id NOT IN
                          (SELECT block_id FROM container_block WHERE deleted_at IS NULL)
                    """,
                arguments: [nowStamp, id, stamp, stamp])
            for blockID in blockIDs {
                try db.execute(
                    sql: "UPDATE block SET deleted_at = NULL, updated_at = ? WHERE id = ?",
                    arguments: [nowStamp, blockID])
                try flipBlockCascadeTombstones(db, blockID: blockID, stamp: stamp, now: now)
            }
            // 13i-c U2 (PROVISIONAL P-13ic-U2-6 — found by the ownership
            // soak): a membership revives into a SEALED book only when the
            // note is itself sealed. A note that lay in the Trash while its
            // book was sealed was never part of that edition; reviving it
            // there would put an editable note inside a book whose text is
            // immutable — the door's own answer (a sealed book refuses every
            // add) is that it comes back OUTSIDE the edition.
            //
            // A FINISHED (not sealed) book takes its membership back — KEPT AS
            // SHIPPED by her ruling R-13id-3 (13i-d kickoff, 2026-10-02;
            // KnownIssues row 109, ratified-documented): a restore returns
            // what was there — the membership existed before the delete, so
            // the table of contents gains nothing new — and the finish freeze
            // keeps binding NEW adds (her doors), never recovery. (The same
            // exact-stamp letter revives a waiting ARRIVAL row with its note;
            // `dismissArrival` stays legal on a finished book — its door.)
            //
            // 13i-d U5b (F-U5b-1, PROVISIONAL P-13id-U5b-5): and only into a
            // book of the note's OWN wing, read AFTER the re-home above — a
            // book never spans wings (§9), so a book that moved to another
            // wing while the note lay in the Trash does not take it back (the
            // row stays decided-dead: "rows whose story diverged stay as they
            // are"). `Queries.revivalWingScope` is the one predicate both
            // revival sites read.
            let sameWing = Queries.revivalWingScope(wingID: container.wingId)
            let revivalArguments: [(any DatabaseValueConvertible)?] =
                [id, stamp, container.locked ? 1 : 0] + sameWing.arguments
            try db.execute(
                sql: """
                    UPDATE reading_post SET deleted_at = NULL
                    WHERE post_id = ? AND deleted_at = ?
                      AND reading_id IN (SELECT id FROM reading WHERE deleted_at IS NULL
                                           AND (sealed_at IS NULL OR ? = 1)
                                           AND \(sameWing.sql))
                    """,
                arguments: StatementArguments(revivalArguments))
            try db.execute(
                sql: """
                    UPDATE post_tag SET deleted_at = NULL
                    WHERE post_id = ? AND deleted_at = ?
                      AND tag_id IN (SELECT id FROM tag WHERE deleted_at IS NULL)
                    """,
                arguments: [id, stamp])
            try db.execute(
                sql: """
                    UPDATE reference SET deleted_at = NULL, updated_at = ?
                    WHERE container_id = ? AND deleted_at = ?
                    """,
                arguments: [nowStamp, id, stamp])
            // Round 2, MINOR 2 (the departed-block corner of the round-1
            // MAJOR): the container cascade stamps canvas rows and lens
            // picks for blocks that DEPARTED before the delete too (their
            // rows stay live by design — the remembered position; the
            // inert pick), and those blocks are never in the per-block
            // loop above (nothing tombstoned them). Flip every exact-stamp
            // victim whose block is LIVE — revived in this restore or
            // living elsewhere; a block that died independently keeps its
            // rows dead (the standing live-parent guard shape).
            try db.execute(
                sql: """
                    UPDATE canvas_layout SET deleted_at = NULL, updated_at = ?
                    WHERE container_id = ? AND deleted_at = ?
                      AND block_id IN (SELECT id FROM block WHERE deleted_at IS NULL)
                    """,
                arguments: [nowStamp, id, stamp])
            try db.execute(
                sql: """
                    UPDATE lens_choice SET deleted_at = NULL, updated_at = ?
                    WHERE deleted_at = ?
                      AND lens_id IN
                          (SELECT id FROM lens WHERE container_id = ? AND deleted_at IS NULL)
                      AND block_id IN (SELECT id FROM block WHERE deleted_at IS NULL)
                    """,
                arguments: [nowStamp, stamp, id])
    }

    private func updateLiveContainer(
        _ id: String, now: Date? = nil, _ mutate: (inout Container) -> Void
    ) throws {
        try database.write { db in
            var container = try liveContainer(db, id)
            mutate(&container)
            container.updatedAt = now ?? date.now
            try container.update(db)
        }
    }
}
