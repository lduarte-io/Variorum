import Dependencies
import Foundation
import GRDB

// THE QUICK NOTE'S SHELF (Phase 13g, batch 7 — her ruling R6-4, verbatim:
// *"i also like the idea of quicknotes automatically adding a quicknote tag
// and there being a smart 'quicknotes' book that's just based on tag, so if
// you remove the tag it leaves the book."*)
//
// The whole feature is TWO STANDING THINGS pointed at each other, which is
// why it needs no schema and no new semantics: an ordinary post tag, and an
// ordinary SMART book whose predicate is that tag. "Removing the tag leaves
// the book" is not a rule written here — it is what smart membership has
// always meant (`assembleReading` walks the predicate every time), and the
// pin in this batch asserts exactly that nothing had to be taught it.
extension Operations {
    /// The tag every quick note wears. A plain top-level path, so it reads
    /// as itself in the tag manager and in the chips on the context bar.
    public static let quicknoteTagPath = "quicknote"

    /// The name a freshly created quicknotes book takes (the
    /// `defaultDailyJournalBookName` shape: the constant lives with the
    /// creation it names).
    public static let defaultQuicknoteBookName = "Quicknotes"

    /// The designation setting's ONE key (17y B-DEDUPE NIT-7 — the
    /// `twinTitle` precedent): the writer below and the furniture fold's
    /// facts read the same spelling.
    public static let quicknoteBookDesignationKey = "quicknote_book"

    /// What `fileAsQuicknote` did, so the caller can speak in its own voice
    /// while there stays exactly ONE implementation of the rules — the
    /// `DailyBookShelving` shape, and for its reason.
    public enum QuicknoteFiling: Equatable, Sendable {
        /// The note wears the tag; the smart book is on the shelf.
        case filed(tagID: String, readingID: String)
        /// The note wears the tag and NO Quicknotes gathering shows it —
        /// she deleted the one this store was given (13i-b U4, §20: her
        /// deletion is her word; the note still lands, tagged, and the
        /// tag's own listing and the Pool find it).
        case taggedOnly(tagID: String)
        /// The note already wore the tag (a re-file, or her own hand).
        case alreadyTagged(tagID: String)
        /// Anything else — races and store failures. A short human phrase,
        /// never an error dump.
        case refused(String)
    }

    /// **THE SECOND HALF OF THE QUICK-NOTE MINT** (her R6-4). Tag the note,
    /// and make sure the book that collects the tag exists.
    ///
    /// **It NEVER THROWS**, for `shelveInDailyJournalBook`'s reason exactly:
    /// the note is already minted and already durable by the time this runs,
    /// and "nothing typed can be permanently lost" outranks tidiness — a
    /// failure here must be able to report rather than take the capture with
    /// it. The caller words the outcome.
    ///
    /// **The book self-creates on the #37(iii) precedent** (her ruling for
    /// the Journal book, applied to its sibling): with no designation — or
    /// one dangling at a deleted book, which reads the same way — this mints
    /// the smart book, designates it and pins it to the shelf. What creation
    /// does NOT do is replace a book she made: a designation pointing at a
    /// LIVE book is hers, whatever state it is in, and this never mints a
    /// second one beside it.
    ///
    /// **It is a READ-THEN-ACT composite, not one transaction** — stated so
    /// no reader infers atomicity: the tag ensure, the application and the
    /// book ensure are separate ops, exactly as `shelveInDailyJournalBook`
    /// reads its designation and then calls `addPostToReading`. Each ensure
    /// re-reads inside its own writer (GRDB serializes writers), so two
    /// quick notes filed in the same instant cannot mint two tags or two
    /// books; what is not covered is the sub-millisecond window in which she
    /// deletes the tag between the ensure and the apply, which reports as a
    /// refusal rather than corrupting anything.
    @discardableResult
    public func fileAsQuicknote(_ postID: String) -> QuicknoteFiling {
        do {
            let tagID = try ensureQuicknoteTag()
            let readingID = try ensureQuicknotesBook()
            do {
                _ = try applyTag(tagID, toPost: postID)
                guard let readingID else { return .taggedOnly(tagID: tagID) }
                return .filed(tagID: tagID, readingID: readingID)
            } catch OperationError.alreadyTagged {
                return .alreadyTagged(tagID: tagID)
            }
        } catch {
            return .refused(Self.quicknoteResidualReason(error))
        }
    }

    /// The `quicknote` tag, minted if it is not there. Re-read inside the
    /// writer so two doors racing the first quick note cannot mint two tags
    /// (the `shelvingPlan` shape).
    func ensureQuicknoteTag() throws -> String {
        let path = Self.quicknoteTagPath
        if let existing = try database.read({ db in
            try Self.liveTagID(db, path: path)
        }) {
            return existing
        }
        return try database.write { db in
            if let raced = try Self.liveTagID(db, path: path) { return raced }
            let now = date.now
            let tag = Tag(
                id: newID(), ownerId: currentOwnerID(), parentId: nil,
                name: path, path: path, createdAt: now, updatedAt: now)
            try tag.insert(db)
            return tag.id
        }
    }

    /// The designated quicknotes book, minted + designated + pinned the
    /// FIRST time a store files a quick note.
    ///
    /// **13i-b U4 — her deletion is her word** (the sitting record §20,
    /// ratified §23: Quicknotes is an ORDINARY gathering, "no special
    /// identity, no delete guard … deleting the gathering breaks nothing —
    /// quick notes still land, still tagged, still findable in the tag's own
    /// listing, and the gathering is re-makeable in one gesture"). The 13g
    /// shape read a DANGLING designation as "none" and minted a fresh book —
    /// the daily Journal's comes-back trait, which §20 withholds from
    /// Quicknotes. Now a designation that names a reading no longer live (in
    /// the Trash, purged, or not yet arrived by sync) answers nil: nothing is
    /// minted, and the caller files the note tagged-only. Restoring the book
    /// from the Trash is the ordinary door back (the designation was never
    /// moved). PROVISIONAL P-13ib-U4-2.
    func ensureQuicknotesBook() throws -> String? {
        if let existing = try database.read({ try Queries.quicknotesBookID($0) }) {
            return existing
        }
        return try database.write { db -> String? in
            if let raced = try Queries.quicknotesBookID(db) { return raced }
            // A designation exists but names nothing live: she decided.
            if try Queries.quicknotesBookWasDesignated(db) { return nil }
            let now = date.now
            // 13i-a: the rule is stored v2 and references the tag BY ID
            // (§19's ruling), so the tag row must exist before the rule
            // can name it — ensure it HERE too (idempotent beside the
            // door's own ensure; a caller reaching this mint first must
            // not store a dead term).
            let tagID: String
            if let existing = try Self.liveTagID(db, path: Self.quicknoteTagPath) {
                tagID = existing
            } else {
                let tag = Tag(
                    id: newID(), ownerId: currentOwnerID(), parentId: nil,
                    name: Self.quicknoteTagPath, path: Self.quicknoteTagPath,
                    createdAt: now, updatedAt: now)
                try tag.insert(db)
                tagID = tag.id
            }
            let book = Reading(
                id: newID(), ownerId: currentOwnerID(),
                name: Self.defaultQuicknoteBookName, kind: .gathering,
                profile: "collection", sortField: .createdAt, sortDir: .desc,
                querySpec: try RuleGrammar.encode(.tag(tagID)),
                createdAt: now, updatedAt: now)
            try book.insert(db)
            try upsertSetting(db, key: Self.quicknoteBookDesignationKey, value: book.id)
            try setShelfPinned(db, book.id, pinned: true)
            return book.id
        }
    }

    private static func liveTagID(_ db: Database, path: String) throws -> String? {
        try String.fetchOne(
            db,
            sql: "SELECT id FROM tag WHERE path = ? AND deleted_at IS NULL",
            arguments: [path])
    }

    /// The residual bucket's wording (`residualReason`'s twin — raw
    /// `String(describing:)` on an `OperationError` renders row ids and enum
    /// case paths, and both callers put this string in front of the author).
    private static func quicknoteResidualReason(_ error: Error) -> String {
        guard let operationError = error as? OperationError else {
            return "the quicknotes shelf could not be reached"
        }
        switch operationError {
        case .containerNotFound, .wrongContainerKind:
            return "the note is no longer there"
        case .tagNotFound:
            return "the quicknote tag is no longer there"
        default:
            return "the quicknotes shelf could not be reached"
        }
    }
}
