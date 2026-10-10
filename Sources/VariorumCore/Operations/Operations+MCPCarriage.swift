import Dependencies
import Foundation
import GRDB

// THE MCP DOOR's CARRIAGE ACTS (13n-b U4 — R-13nb-14's keyboard bar,
// R-13nb-18, R-13nb-26 b/e/f; AF-11). Like the acts beside them
// (`Operations+MCPWrites`, `Operations+MCPEdits`), these are ORDINARY
// OPERATIONS: her own doors' row work, each registering exactly ONE
// structural-undo entry labeled with THE CLIENT'S NAME (P-13nb-U2-4: every
// MCP write registers one, though some of her own doors — the tray's Put
// back, the date, the chapter filing, the rule — register none), each taking
// the caller's `WriteGuard` FIRST inside its own write transaction (AF-10
// (a), carried to the new acts of this unit). They decide nothing about
// clients.
extension Operations {
    // MARK: - EDIT: put back (the tray — R-13nb-14's named IN)

    /// **`put_back` on a deleted BLOCK** — the tray's Put back exactly
    /// (`restoreBlock`: the block and its stamp-matched cascade children
    /// revive, its own placement row flips back at its old position, else it
    /// lands at its note's end), with the caller's guard first inside that
    /// transaction. ONE undo entry: the inverse is `deleteBlock`'s own row
    /// work (the block tombstoned again — the tray catches it again), the
    /// redo the exact-row flip `revertDeleteBlock` performs (the same
    /// placement row back). Her own Put back registers nothing (the recovery
    /// door class); the client's does, because every MCP write is one ⌥⌘Z.
    @discardableResult
    public func putBackBlock(
        _ blockID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> BlockRestoreLanding {
        let landing = try restoreBlock(blockID, guardedBy: guardian)
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.performDeleteBlock(blockID, quietWhenGone: true, requiring: .none) },
            redo: { try $0.revertDeleteBlock(blockID) })
        return landing
    }

    /// **`put_back` on a deleted TAKE** — `restoreVariant` exactly (a
    /// tombstone flip: label, fan position, parent, text and status come back
    /// as they were; the default pointer deliberately unmoved), guard first.
    /// ONE undo entry: the take tombstoned again through `deleteVariant`'s
    /// row work (refused while she has since CHOSEN it — choose another
    /// first, a resolvable refusal that keeps the entry), the redo the same
    /// flip again (quiet when it is already back). Returns the revived take's
    /// status (an archived take returns archived — `restoreVariant`'s answer).
    @discardableResult
    public func putBackTake(
        _ variantID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> VariantStatus {
        let status = try restoreVariant(variantID, guardedBy: guardian)
        undoStack?.register(
            label: undoLabel,
            inverse: { _ = try $0.performDeleteVariant(variantID, quietWhenGone: true) },
            redo: { ops in
                do {
                    _ = try ops.restoreVariant(variantID)
                } catch OperationError.variantNotDeleted {
                    return  // already back — the world moved past the entry
                }
            })
        return status
    }

    // MARK: - WRITE NEW: a whole-note version (R-13nb-18)

    /// **`save_version`** — `saveNoteVersion`'s mint exactly (the full family
    /// copy, born archived + sealed from one clock read, no title mutation,
    /// no entry date), guard first, with the door's own undo entry relabeled
    /// for the client (`revertMintedContainer` / `reapplyMintedContainer` —
    /// the version tombstoned and revived on its exact stamp).
    @discardableResult
    public func saveVersion(
        of postID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> PostCopyResult {
        let result: PostCopyResult = try database.write { db in
            try guardian?(db)
            return try mintNoteVersion(db, of: postID)
        }
        let versionID = result.post.id
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.revertMintedContainer(versionID) },
            redo: { try $0.reapplyMintedContainer(versionID) })
        return result
    }

    // MARK: - EDIT: a note's date (R-13nb-26 b — "agents should be able to set the date")

    /// **`set_entry_date`** — `setEntryDate`'s rule (a canonical `yyyy-MM-dd`
    /// day key or nil to un-date; a malformed key refuses `invalidEntryDate`;
    /// title/date metadata stays editable under a seal — N34's class, her op's
    /// own posture), on a live NOTE (a scraps group has no date), guard first;
    /// no-op-guarded (the same date writes nothing and registers nothing).
    /// ONE undo entry restoring the previous value exactly, the redo the new
    /// one. Returns whether anything was written.
    @discardableResult
    public func setNoteEntryDate(
        _ postID: String, entryDate: String?, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> Bool {
        if let entryDate, !JournalDay.isValid(entryDate) {
            throw OperationError.invalidEntryDate(entryDate)
        }
        let previous: String?? = try database.write { db in
            try guardian?(db)
            let post = try livePost(db, postID)
            guard post.entryDate != entryDate else { return nil }
            try writeEntryDate(db, postID: postID, entryDate)
            return .some(post.entryDate)
        }
        guard case .some(let old) = previous else { return false }
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.restoreEntryDate(postID, to: old) },
            redo: { try $0.restoreEntryDate(postID, to: entryDate) })
        return true
    }

    private func writeEntryDate(_ db: Database, postID: String, _ entryDate: String?) throws {
        try db.execute(
            sql: "UPDATE container SET entry_date = ?, updated_at = ? WHERE id = ?",
            arguments: [entryDate, DateFormatter.variorumISO8601.string(from: date.now), postID])
    }

    /// Both halves of the date entry: a gone note is the world moving past
    /// the entry (quiet); the value already as asked writes nothing.
    func restoreEntryDate(_ postID: String, to entryDate: String?) throws {
        try database.write { db in
            guard let post = try Container.fetchOne(db, key: postID), post.deletedAt == nil,
                  post.entryDate != entryDate
            else { return }
            try writeEntryDate(db, postID: postID, entryDate)
        }
    }

    // MARK: - WRITE NEW: filing an existing member into a chapter (P-13nb-U3-8 → U4, PROVISIONAL)

    /// **`file_note_in_chapter`** — `assignPostToSection`'s row work exactly
    /// (a curated BOOK's live chapter, or nil = unfiled; the note must be a
    /// MEMBER — an arrival has no chapter; a finished book refuses
    /// `lockedReading`, the chapter-structure rule), guard first;
    /// no-op-guarded. ONE undo entry restoring the membership's previous
    /// chapter pointer exactly, the redo the new one. Returns whether
    /// anything was written.
    @discardableResult
    public func fileNoteInChapter(
        _ postID: String, book readingID: String, section sectionID: String?,
        undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> Bool {
        let previous: String?? = try database.write { db in
            try guardian?(db)
            return try assignSectionRow(db, postID: postID, readingID: readingID, sectionID: sectionID)
        }
        guard case .some(let old) = previous else { return false }
        undoStack?.register(
            label: undoLabel,
            inverse: { try $0.refileMembership(postID, book: readingID, section: old) },
            redo: { try $0.refileMembership(postID, book: readingID, section: sectionID) })
        return true
    }

    /// Both halves of the filing entry. A membership gone (removed since) or
    /// a reading gone is the world moving past the entry (quiet); a finished
    /// book refuses and KEEPS the entry (resolvable — the chapter-structure
    /// rule); a chapter deleted since is restored as the pointer it was (a
    /// dangling pointer reads unfiled — `deleteSection`'s doctrine).
    func refileMembership(_ postID: String, book readingID: String, section sectionID: String?) throws {
        try database.write { db in
            guard let reading = try Reading.fetchOne(db, key: readingID), reading.deletedAt == nil,
                  var membership = try ReadingPost
                    .filter(Column("reading_id") == readingID && Column("post_id") == postID
                        && Column("deleted_at") == nil && Column("status") == MembershipStatus.member)
                    .fetchOne(db),
                  membership.sectionId != sectionID
            else { return }
            guard !reading.locked else { throw OperationError.lockedReading(id: readingID) }
            membership.sectionId = sectionID
            try membership.update(db)
        }
    }

    // MARK: - WRITE NEW: a book's rule, outflow and join dial (R-13nb-26 f; AF-11 F-1)

    /// What the client asked a book's Collecting settings to become — her
    /// rule editor's ONE Save, field by field (nil = leave as stored).
    public struct MCPBookRuleWrite: Equatable, Sendable {
        /// The rule with every TAG term naming a tag PATH (the wire's address
        /// — never an id); `.some(nil)` clears it (a book's kill switch).
        public var rule: RuleTerm??
        /// The outflow as tag PATHS, in her order; `[]` clears it.
        public var outflowPaths: [String]?
        /// The join dial: `.auto` = "join quietly at the end", `.arrivals` =
        /// "wait at Arrivals".
        public var seating: IntakeSeating?

        public init(rule: RuleTerm?? = nil, outflowPaths: [String]? = nil, seating: IntakeSeating? = nil) {
            self.rule = rule
            self.outflowPaths = outflowPaths
            self.seating = seating
        }
    }

    /// The three stored Collecting columns, exactly (the undo's pre/post images).
    public struct MCPCollectingColumns: Equatable, Sendable {
        public let querySpec: String?
        public let autoTagIDs: String?
        public let intakeSeating: IntakeSeating?
    }

    /// What `setBookRule` did.
    public struct MCPBookRuleResult: Equatable, Sendable {
        public let before: MCPCollectingColumns
        public let after: MCPCollectingColumns
        /// Whether the book's intake runs now (`IntakeDecision.intakeRuns` —
        /// false while it is finished, sealed or archived: her Save lands
        /// there too, and the catch-up waits for the reopen).
        public let intakeRuns: Bool
        /// Tags the act minted because a path named none (adopt-or-mint).
        public let mintedTags: Int

        public var changed: Bool { before != after }
    }

    /// Her rule editor's refusals that live in its FACE, mirrored at the act
    /// (AF-11 F-1: refuse exactly where her Save refuses, never more).
    public enum MCPBookRuleRefusal: Error, Equatable, Sendable {
        /// The stored rule is malformed: her editor refuses to edit it at all
        /// (`RuleEditing.needsWrite` answers false; the rows are inert).
        case storedRuleUnreadable
    }

    /// **`set_book_rule` — her rule editor's Save, projected** (AF-11 F-1).
    /// The SAME three writes her Save makes, in its order — the join dial,
    /// the outflow, then the rule through its one choke point (an intake
    /// occasion: backfill on a rule-less book, catch-up on an edit) — and
    /// each only when it CHANGES what is stored (her Save's own tests:
    /// `seating != stored ?? .auto`, the outflow's encoded set,
    /// `RuleEditing.needsWrite`'s structural equality). Stricter than her
    /// Save in ONE way only: the three land in ONE transaction, guard first,
    /// so nothing half-lands. Tags are named by PATH and resolved in the
    /// book's own wing — adopted, or minted when the path names none (her
    /// editor's make-in-place; apply_tag's precedent). A finished, sealed or
    /// archived book LANDS (her ops and her Edit… door do — 13i §5: intake
    /// pauses and the reopen catches up); the answer's `intakeRuns` says so.
    /// Refusals are hers: a malformed stored rule (her editor will not edit
    /// it), a blank path (`invalidTagName`), and the ops' own (a gathering's
    /// outflow/dial `wrongReadingKind`, a cleared gathering rule
    /// `gatheringRequiresRule`).
    ///
    /// ONE undo entry (P-13nb-U2-4) restoring the three columns exactly; the
    /// redo the written values. Seats or bells the rule's intake made STAY
    /// (§19: removing a rule never evicts — the P-13nb-U2-6 precedent), and a
    /// minted tag stays as vocabulary (13n-a's).
    @discardableResult
    public func setBookRule(
        _ readingID: String, _ write: MCPBookRuleWrite, undoLabel: String,
        guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPBookRuleResult {
        let result: MCPBookRuleResult = try database.write { db in
            try guardian?(db)
            let reading = try liveReading(db, readingID)
            if write.rule != nil, RuleGrammar.read(reading.querySpec) == .malformed {
                throw MCPBookRuleRefusal.storedRuleUnreadable
            }
            let before = MCPCollectingColumns(
                querySpec: reading.querySpec, autoTagIDs: reading.autoTagIds, intakeSeating: reading.intakeSeating)
            var adoption = TagAdoption(wing: try Queries.wingIsLive(db, id: reading.wingId) ? reading.wingId : "")
            func resolve(_ path: String) throws -> String {
                let segments = TagPath.segments(path)
                guard !segments.isEmpty,
                      let tag = try adoptPath(db, segments.joined(separator: "/"), &adoption)
                else { throw OperationError.invalidTagName(name: path) }
                return tag.id
            }
            if let seating = write.seating, seating != (reading.intakeSeating ?? .auto) {
                try writeReadingIntakeSeating(db, readingID, seating)
            }
            if let paths = write.outflowPaths {
                try writeReadingOutflow(db, readingID, tagIDs: try paths.map(resolve))
            }
            if case .some(let term) = write.rule {
                let resolved = try term.map { try $0.mappingTags(resolve) }
                if RuleEditing.needsWrite(draft: resolved, stored: reading.querySpec) {
                    try writeReadingQuerySpec(db, readingID, querySpec: try RuleGrammar.encode(resolved))
                }
            }
            let landed = try liveReading(db, readingID)
            return MCPBookRuleResult(
                before: before,
                after: MCPCollectingColumns(
                    querySpec: landed.querySpec, autoTagIDs: landed.autoTagIds,
                    intakeSeating: landed.intakeSeating),
                intakeRuns: IntakeDecision.intakeRuns(try intakeBookFacts(db, landed)),
                mintedTags: adoption.minted)
        }
        if result.changed {
            let before = result.before, after = result.after
            undoStack?.register(
                label: undoLabel,
                inverse: { try $0.restoreCollectingColumns(readingID, to: before) },
                redo: { try $0.restoreCollectingColumns(readingID, to: after) })
        }
        return result
    }

    /// Both halves of the book-rule entry: the three columns back exactly as
    /// they were (no intake runs — an undo is never an applying act, and
    /// seats stay). A reading gone is the world moving past the entry.
    func restoreCollectingColumns(_ readingID: String, to columns: MCPCollectingColumns) throws {
        try database.write { db in
            guard let reading = try Reading.fetchOne(db, key: readingID), reading.deletedAt == nil else { return }
            guard reading.querySpec != columns.querySpec || reading.autoTagIds != columns.autoTagIDs
                || reading.intakeSeating != columns.intakeSeating
            else { return }
            try db.execute(
                sql: """
                    UPDATE reading SET query_spec = ?, auto_tag_ids = ?, intake_seating = ?, updated_at = ?
                    WHERE id = ?
                    """,
                arguments: [columns.querySpec, columns.autoTagIDs, columns.intakeSeating?.rawValue,
                            DateFormatter.variorumISO8601.string(from: date.now), readingID])
        }
    }
}

extension RuleTerm {
    /// The same tree with every TAG term's payload transformed (ids ⇄ paths
    /// — the MCP door names tags by path; the store holds ids). Legacy
    /// terms and the star pass through.
    public func mappingTags(_ transform: (String) throws -> String) rethrows -> RuleTerm {
        switch self {
        case .and(let terms): return .and(try terms.map { try $0.mappingTags(transform) })
        case .or(let terms): return .or(try terms.map { try $0.mappingTags(transform) })
        case .not(let term): return .not(try term.mappingTags(transform))
        case .tag(let payload): return .tag(try transform(payload))
        case .star, .legacyProfile, .legacyEntryDateFrom, .legacyEntryDateTo: return self
        }
    }
}
