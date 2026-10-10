import Dependencies
import Foundation
import GRDB

// Reading sections / chapters (Phase 13, Step A1 — v1_10; rulings R28/R50).
// First-class reorderable groupings within a CURATED book: sections are
// ordered metadata rows; membership-to-chapter assignment lives on
// `reading_post.section_id`. Deleting a chapter never touches the posts —
// their pointers dangle and read as unsectioned (the fallback class).
//
// Guards: chapters are STRUCTURE, so a locked reading ("declared done" —
// order frozen) refuses create/delete/reorder/assign, exactly like
// membership and sort changes; RENAME stays allowed under lock (the
// `renameReading` parallel — a finished book's chapter can be retitled
// without un-finishing it). Sections refuse on SMART readings
// (PROVISIONAL, QUESTIONS bundle): a smart reading has no `reading_post`
// rows to assign, so a chapter there could never hold anything — its
// derived order is the sort field's; tag-root grouping (`grouping_tag_id`)
// remains the smart reading's sectioning story.
extension Operations {
    /// A new chapter at the requested spot in the book's chapter order.
    @discardableResult
    public func createSection(
        in readingID: String, name: String, at insert: InsertPosition = .end
    ) throws -> ReadingSection {
        try database.write { db in try insertSection(db, in: readingID, name: name, at: insert) }
    }

    /// `createSection`'s row, inside a caller's transaction (13n-b U3 — the
    /// MCP door's `create_section` runs it under its guard and registers its
    /// own undo entry, `Operations+MCPEdits`). Behaviour byte-unchanged: the
    /// whole body moved, nothing in it did.
    func insertSection(
        _ db: Database, in readingID: String, name: String, at insert: InsertPosition
    ) throws -> ReadingSection {
        let reading = try liveReading(db, readingID)
        guard reading.kind == .book else {
            throw OperationError.wrongReadingKind(id: readingID, expected: .book)
        }
        guard !reading.locked else {
            throw OperationError.lockedReading(id: readingID)
        }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw OperationError.invalidSectionName(name: name)
        }
        let now = date.now
        let section = ReadingSection(
            id: newID(), readingId: readingID, name: trimmed,
            position: try sectionPosition(db, readingID: readingID, at: insert),
            createdAt: now, updatedAt: now)
        try section.insert(db)
        return section
    }

    /// Retitle a chapter — allowed under a locked reading (the
    /// `renameReading` parallel); a no-op rename writes nothing.
    public func renameSection(_ id: String, name: String) throws {
        try database.write { db in
            var section = try liveSection(db, id)
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                throw OperationError.invalidSectionName(name: name)
            }
            guard section.name != trimmed else { return }
            section.name = trimmed
            section.updatedAt = date.now
            try section.update(db)
        }
    }

    /// Tombstone the chapter. Memberships keep their `section_id` pointers
    /// — dangling reads as unsectioned (deliberately NO cascade; the posts
    /// are untouched). Recovery is `restoreSection` below: BECAUSE the
    /// pointers are never rewritten, an un-deleted chapter gets its posts
    /// back for free (Stage A review round 1, MINOR 2 — re-creating a
    /// chapter mints a fresh id the surviving pointers could never
    /// reattach to, so a restore door is owed; the never-skimpy /
    /// restoreContainer doctrine).
    public func deleteSection(_ id: String) throws {
        try database.write { db in
            var section = try liveSection(db, id)
            let reading = try liveReading(db, section.readingId)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: reading.id)
            }
            let now = date.now
            section.deletedAt = now
            section.updatedAt = now
            try section.update(db)
        }
    }

    /// The chapter's resurrection door (the comment-restore parallel; NO
    /// undo entry — the tags/locks exclusion class, this door is the
    /// recovery). One tombstone flip: the memberships' surviving pointers
    /// reattach without a write. Requires the reading live and unlocked
    /// (a chapter revival is structure); a section that died WITH its
    /// reading (cascade victim) refuses here while the reading is dead —
    /// since 13b 4F (N37/S4-28.2, the author's reversal of the pre-13
    /// "readings have no restore door" boundary) the road is
    /// `restoreReading` FIRST, which revives exact-stamp cascade victims
    /// itself; this door then serves chapters deleted INDEPENDENTLY of
    /// their (now live again) reading.
    public func restoreSection(_ id: String) throws {
        try database.write { db in
            guard var section = try ReadingSection.fetchOne(db, key: id) else {
                throw OperationError.sectionNotFound(id: id)
            }
            guard section.deletedAt != nil else {
                throw OperationError.sectionNotDeleted(id: id)
            }
            let reading = try liveReading(db, section.readingId)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: reading.id)
            }
            section.deletedAt = nil
            section.updatedAt = date.now
            try section.update(db)
        }
    }

    /// Move the chapter within the book's chapter order (the movable-
    /// chapters ruling — sitting 2: "movable chapters is great").
    public func reorderSection(_ id: String, to insert: InsertPosition) throws {
        try database.write { db in
            var section = try liveSection(db, id)
            let reading = try liveReading(db, section.readingId)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: reading.id)
            }
            section.position = try sectionPosition(
                db, readingID: section.readingId, at: insert)
            section.updatedAt = date.now
            try section.update(db)
        }
    }

    /// Point a membership at a chapter (nil = unsectioned). The section
    /// must be a live chapter of THAT reading; the reading must be
    /// unlocked. Assignment is metadata on the membership row — position
    /// within the book is untouched.
    public func assignPostToSection(
        _ postID: String, in readingID: String, section sectionID: String?
    ) throws {
        try database.write { db in
            let reading = try liveReading(db, readingID)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            guard var membership = try ReadingPost
                .filter(Column("reading_id") == readingID && Column("post_id") == postID
                    && Column("deleted_at") == nil
                    // 13i-b U1: a waiting ARRIVAL is not in the book — it has
                    // no chapter to be filed under until she seats it.
                    && Column("status") == MembershipStatus.member)
                .fetchOne(db)
            else {
                throw OperationError.postNotInReading(postID: postID, readingID: readingID)
            }
            if let sectionID {
                let section = try liveSection(db, sectionID)
                guard section.readingId == readingID else {
                    throw OperationError.sectionNotInReading(
                        sectionID: sectionID, readingID: readingID)
                }
            }
            guard membership.sectionId != sectionID else { return }
            membership.sectionId = sectionID
            try membership.update(db)
        }
    }

    // MARK: - Internals

    func liveSection(_ db: Database, _ id: String) throws -> ReadingSection {
        guard let section = try ReadingSection.fetchOne(db, key: id),
              section.deletedAt == nil
        else {
            throw OperationError.sectionNotFound(id: id)
        }
        return section
    }

    /// A `reading_section.position` in a reading's live chapter order.
    /// Anchors are section ids (the row's own id — the reference-panel
    /// precedent).
    private func sectionPosition(
        _ db: Database, readingID: String, at insert: InsertPosition
    ) throws -> String {
        try listPosition(
            db,
            in: OrderedList(
                table: "reading_section", scopeColumn: "reading_id",
                anchorColumn: "id",
                missingAnchor: { OperationError.sectionNotFound(id: $0) }),
            scopeID: readingID, at: insert)
    }
}
