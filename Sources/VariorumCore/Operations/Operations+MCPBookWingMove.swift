import Dependencies
import Foundation
import GRDB

// THE MCP DOOR's BOOK MOVE (VX-807 — the VX-809 run, batch 2; her R-807: "the
// app's confirm shows HER everything; the WIRE's answer reach-scopes" + her
// fuller paste: "the op answers what the app's confirm shows — the notes that
// come, the memberships cut, the waiting arrivals dismissed"; the orchestrator's
// A-809-2 (the grant), A-809-14 (the undo — the WRAP), A-809-15 (a fence never
// drops), A-809-16 (no gathering on the wire); R-805-5 (the wire keeps a daily
// Journal refusal)).
//
// Like every act the door takes, an ORDINARY OPERATION: HER door's act
// (`moveReadingToWing(db:)` — the members whole, tags adopted by path, the
// stay-behind memberships severed, finished/sealed riding whole, archived
// riding archived, the pending arrivals dismissed, landing unshelved; her
// refusals) run inside ONE transaction behind the caller's `WriteGuard`, plus
// what her door deliberately lacks and every MCP write carries: ONE
// client-named structural-undo entry with an EXACT-ROW inverse and redo.
//
// Her door registers no entry ("the symmetric door is the net"; its confirm is
// the net — P-13id-U5b-4), and the wire has no confirm — so the act WRAPS her
// body, never re-derives it (the note move's `mcpMoveNoteToWing`, lifted one
// level): every member's live membership rows, live applications (its own and
// its placed blocks') and versions' wings, the book's own columns and rows,
// are read BEFORE and AFTER her body inside the same transaction, and the
// difference is the entry's exact rows. The inverse and the redo then flip
// THOSE rows — no fresh row, no re-adoption (minted tags stay as vocabulary,
// P-13nb-U2-6's precedent; the book move tombstones no tag of the source).
//
// The op decides nothing about clients: who may act is the server's per-call
// rule (`MCPWriteTools+BookWingMove`); what the answer may SAY is the caller's
// `reach`, read here before her body so it is the client's view when it asked.
extension Operations {
    /// The wire's own refusals of a book move (none is one of her door's).
    public enum MCPBookMoveRefusal: Error, Equatable, Sendable {
        /// **A-809-15 (P-809-10):** a member's FENCE would drop — a stay-behind
        /// membership in a Private book or the daily Journal is severed, leaving
        /// the note unfenced in a book the client edits. The move refuses whole.
        case wouldShedAFence
        // (R-805-5's daily Journal refusal is not one of these: the act calls
        // the wire's SHARED move fence — `refuseMovingTheDailyJournalOnTheWire`,
        // `OperationError.dailyJournalMovesOnlyByHand` — folded in at the
        // VX-805 merge-in, retiring this op's own `.dailyJournal` belt.)
        /// **A-809-16 (P-809-11):** a GATHERING never moves on the wire — its
        /// wing is what its grants reach. The wire refuses first; this is the
        /// op's belt.
        case gathering
        /// **A-809-14:** an undo or redo found the act PARTIALLY aged — some row
        /// it wrote no longer reads the act's value (a note joined or left the
        /// book, a member joined a book or took a tag in the wing it would
        /// leave, its collecting settings or shelf changed, a row it would
        /// revive cannot come back). The replay refuses WHOLE and keeps the
        /// entry — never a partial write-back.
        case changedSince(bookID: String)
    }

    /// What the caller can read — asked of each fact the answer may name or
    /// count (the wire passes its one rule at READ, non-consuming).
    public enum MCPReadTarget: Equatable, Sendable {
        case note(String)
        /// A book or a gathering.
        case reading(String)
    }

    public typealias MCPReadReach = (Database, MCPReadTarget) throws -> Bool

    /// What one MCP book move did: HER door's facts (her receipt's — they count
    /// everything) and the reach-scoped facts the wire may answer (each read
    /// through `reach` before her body).
    public struct MCPBookWingMove: Equatable, Sendable {
        /// One severed stay-behind membership the caller can see: the note and
        /// the book it left are both readable.
        public struct LeftBook: Equatable, Sendable {
            public let noteID: String
            public let bookID: String
            public let name: String
        }

        /// A reading in the destination already wearing the book's name (her
        /// confirm's twin line — E13's key), readable.
        public struct Twin: Equatable, Sendable {
            public let bookID: String
            public let name: String
        }

        public let move: BookWingMove
        /// The members that came with the book that the caller can read.
        public let notes: Int
        /// Of those, the archived ones (they stay archived).
        public let archivedNotes: Int
        /// Her confirm's order: members in the book's order, each one's other
        /// books earliest membership first.
        public let leftBooks: [LeftBook]
        /// The book's waiting notes the move dismissed that the caller can read.
        public let dismissedArrivals: Int
        public let twins: [Twin]
    }

    /// The book's own columns the move writes (its pre- and post-images).
    struct BookMoveColumns: Equatable, Sendable {
        let wingID: String
        let shelfID: String?
        let shelfPosition: String?
        let querySpec: String?
        let autoTagIDs: String?
        let groupingTagID: String?

        init(_ reading: Reading) {
            wingID = reading.wingId
            shelfID = reading.shelfId
            shelfPosition = reading.shelfPosition
            querySpec = reading.querySpec
            autoTagIDs = reading.autoTagIds
            groupingTagID = reading.groupingTagId
        }
    }

    /// One member's exact rows — the note move's `WingMoveRows` plus the full
    /// live sets before and after (A-809-14: a replay writes only while EVERY
    /// row reads its partner's value).
    struct BookMoveMemberRows: Sendable {
        let rows: WingMoveRows
        let membershipsBefore: Set<String>
        let membershipsAfter: Set<String>
        let applicationsBefore: Set<WingMoveApplication>
        let applicationsAfter: Set<WingMoveApplication>
    }

    /// The exact rows one book move changed — what its undo and redo replay.
    struct BookMoveRows: Sendable {
        let readingID: String
        /// The book's STORED `wing_id` before (a dangling pointer kept as it was).
        let sourceWing: String
        let destinationWing: String
        let before: BookMoveColumns
        let after: BookMoveColumns
        let members: [BookMoveMemberRows]
        /// The book's own live rows (id → status) before (members AND waiting
        /// arrivals) and after (its members — the arrivals dismissed).
        let bookRowsBefore: [String: MembershipStatus]
        let bookRowsAfter: [String: MembershipStatus]
        /// The waiting-arrival rows the move dismissed.
        let dismissed: [String]
    }

    /// **`move_book_to_wing`'s act** — her door (`moveReadingToWing(db:)`)
    /// inside ONE transaction: the caller's guard FIRST (A-809-2's two
    /// decisions, re-made on the act's own facts, once grants stamped there);
    /// then the wire's belts (a gathering — A-809-16; the daily Journal —
    /// R-805-5's shared move fence, `refuseMovingTheDailyJournalOnTheWire`:
    /// her body moves the Journal since VX-435, so on the wire this line is
    /// what refuses it, behind the fenced book facts); the pre-act reads (the rows, the fences, the answer's
    /// reach-scoped facts); her body (her refusals unchanged: `wingNotFound`,
    /// `readingAlreadyInWing`, a stay-behind MEMBER row in a finished or sealed
    /// book — `lockedReading` / `readingSealed`); then A-809-15 — a member
    /// fenced before and not after rolls the whole act back
    /// (`wouldShedAFence`).
    ///
    /// ONE undo entry, `undoLabel` ("claude-code's book wing move" — A-809-14):
    /// see `revertMCPBookMove` / `reapplyMCPBookMove`.
    @discardableResult
    public func mcpMoveBookToWing(
        _ readingID: String, to wingID: String, undoLabel: String,
        guardedBy guardian: WriteGuard? = nil, reach: MCPReadReach? = nil
    ) throws -> MCPBookWingMove {
        let landed: (result: MCPBookWingMove, rows: BookMoveRows, stamp: String) = try database.write { db in
            try guardian?(db)
            let reading = try liveReading(db, readingID)
            guard reading.kind == .book else { throw MCPBookMoveRefusal.gathering }
            try Self.refuseMovingTheDailyJournalOnTheWire(db, readingID: readingID)
            func readable(_ target: MCPReadTarget) throws -> Bool { try reach?(db, target) ?? true }

            // The pre-act reads.
            let members = try Queries.bookMoveMembers(db, readingID: readingID)
            let memberIDs = members.map(\.postID)
            let fencedBefore = try Queries.mcpNoteFacts(db, noteIDs: memberIDs).filter { $0.value.fence != nil }
            var before: [String: (wing: String, memberships: [(row: ReadingPost, reading: Reading)],
                                  state: (memberships: Set<String>, applications: [WingMoveApplication],
                                          versionWings: [String: String]))] = [:]
            for id in memberIDs {
                before[id] = (try livePost(db, id).wingId, try wingMoveMemberships(db, postID: id),
                              try wingMoveState(db, postID: id))
            }
            let bookRowsBefore = try bookRows(db, readingID)
            let dismissed = try ReadingPost.fetchAll(
                db, sql: "SELECT * FROM reading_post WHERE \(Queries.pendingArrivalRowsWhere) ORDER BY position, id",
                arguments: [readingID])

            // The answer's facts, through the caller's reach, as it stood.
            var readableIDs: Set<String> = []
            for member in members where try readable(.note(member.postID)) { readableIDs.insert(member.postID) }
            var left: [MCPBookWingMove.LeftBook] = []
            for member in members where readableIDs.contains(member.postID) {
                for (row, book) in before[member.postID]?.memberships ?? []
                where try row.status == .member && book.id != readingID && readable(.reading(book.id)) {
                    left.append(.init(noteID: member.postID, bookID: book.id, name: book.name))
                }
            }
            var waitingReadable = 0
            for row in dismissed where try readable(.note(row.postId)) { waitingReadable += 1 }
            let key = BookNaming.key(reading.name)
            let scope = Queries.wingScope(column: "wing_id", wingID: wingID)
            var twins: [MCPBookWingMove.Twin] = []
            for row in try Row.fetchAll(
                db,
                sql: "SELECT id, name FROM reading WHERE deleted_at IS NULL AND id <> ? AND \(scope.sql) ORDER BY name, id",
                arguments: StatementArguments([readingID] + scope.arguments))
            where try BookNaming.key(row["name"]) == key && readable(.reading(row["id"])) {
                twins.append(.init(bookID: row["id"], name: row["name"]))
            }

            // Her body.
            let (move, now) = try moveReadingToWing(db, readingID, to: wingID)

            // A-809-15: no member's fence drops with a severed membership.
            let factsAfter = try Queries.mcpNoteFacts(db, noteIDs: memberIDs)
            for id in fencedBefore.keys where factsAfter[id]?.fence == nil {
                throw MCPBookMoveRefusal.wouldShedAFence
            }

            // The exact rows.
            var memberRows: [BookMoveMemberRows] = []
            for member in members {
                guard let prior = before[member.postID] else { continue }
                let after = try wingMoveState(db, postID: member.postID)
                let note = try livePost(db, member.postID)
                let priorApplications = Set(prior.state.applications)
                let afterApplications = Set(after.applications)
                memberRows.append(BookMoveMemberRows(
                    rows: WingMoveRows(
                        postID: member.postID,
                        sourceWing: prior.wing,
                        destinationWing: note.wingId,
                        versionWings: prior.state.versionWings.filter { after.versionWings[$0.key] != $0.value },
                        severed: prior.memberships.map(\.row.id).filter { !after.memberships.contains($0) },
                        removedApplications: prior.state.applications.filter { !afterApplications.contains($0) },
                        addedApplications: after.applications.filter { !priorApplications.contains($0) }),
                    membershipsBefore: prior.state.memberships, membershipsAfter: after.memberships,
                    applicationsBefore: priorApplications, applicationsAfter: afterApplications))
            }
            let landedBook = try liveReading(db, readingID)
            let rows = BookMoveRows(
                readingID: readingID, sourceWing: reading.wingId, destinationWing: wingID,
                before: BookMoveColumns(reading), after: BookMoveColumns(landedBook), members: memberRows,
                bookRowsBefore: bookRowsBefore, bookRowsAfter: try bookRows(db, readingID),
                dismissed: dismissed.map(\.id))
            let result = MCPBookWingMove(
                move: move, notes: readableIDs.count,
                archivedNotes: members.filter { $0.archived && readableIDs.contains($0.postID) }.count,
                leftBooks: left, dismissedArrivals: waitingReadable, twins: twins)
            return (result, rows, DateFormatter.variorumISO8601.string(from: now))
        }
        let rows = landed.rows
        let forward = LockIsolated(landed.stamp)
        let backward = LockIsolated<String?>(nil)
        undoStack?.register(
            label: undoLabel,
            inverse: { ops in
                guard let stamp = try ops.revertMCPBookMove(rows, forwardStamp: forward.value) else { return false }
                backward.setValue(stamp)
                return true
            },
            redo: { ops in
                guard let stamp = try ops.reapplyMCPBookMove(rows, backwardStamp: backward.value) else { return false }
                forward.setValue(stamp)
                return true
            })
        return landed.result
    }

    /// The book's own live rows (id → status), every status.
    private func bookRows(_ db: Database, _ readingID: String) throws -> [String: MembershipStatus] {
        var rows: [String: MembershipStatus] = [:]
        for row in try ReadingPost.fetchAll(
            db, sql: "SELECT * FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL", arguments: [readingID]) {
            rows[row.id] = row.status
        }
        return rows
    }

    // MARK: - The replays (A-809-14)

    /// **The inverse — the book and every member back where they came from, on
    /// the move's own rows.** Returns the stamp it tombstoned the re-pointed
    /// copies on (the redo revives exactly those), or nil when the entry is
    /// OBSOLETE and nothing was written.
    ///
    /// - **Obsolete (quiet — the note move's letter: a replay that would cross
    ///   wings does nothing):** the book is gone, it no longer stands in the
    ///   wing the move took it to (her own door moved it on), or either of the
    ///   entry's wings, or the book's own current wing, is no longer live (F1 /
    ///   R2-N1, the note move's two ladder rulings).
    /// - **Refused WHOLE, the entry kept (`changedSince` — A-809-14's VX-276
    ///   discipline):** any row the act wrote no longer reads the act's value —
    ///   the book's columns (its wing, shelf, rule, outflow, grouping), its own
    ///   rows (a note joined or left it), a member's wing, versions, live
    ///   memberships or live applications (it joined a book or took a tag in
    ///   the destination), a re-pointed copy gone, an original application
    ///   that cannot come back (its tag dead, a live twin), a severed or
    ///   dismissed row no longer on the act's stamp or no longer revivable (its
    ///   book dead or moved, a live row for the pair, a sealed book holding an
    ///   unsealed note). Checked FIRST, before any write — never a partial
    ///   write-back.
    /// - Otherwise, in ONE transaction: the copies tombstoned, the originals
    ///   revived (purge intents voided), each member and the versions the move
    ///   re-homed back to their stored wing, the severed rows revived on their
    ///   stamp (a FINISHED book takes its row back — R-13id-3), the book's
    ///   columns back to their pre-images (a shelf dead since reads unshelved —
    ///   a dangling pointer), the dismissed arrivals back waiting, then the
    ///   ownership revival pass.
    func revertMCPBookMove(_ rows: BookMoveRows, forwardStamp: String) throws -> String? {
        try database.write { db -> String? in
            guard var book = try Reading.fetchOne(db, key: rows.readingID), book.deletedAt == nil,
                  try Queries.wingIsLive(db, id: rows.destinationWing),
                  try Queries.wingIsLive(db, id: book.wingId),
                  try sameEffectiveWing(db, book.wingId, rows.destinationWing),
                  try Queries.wingIsLive(db, id: rows.sourceWing)
            else { return nil }
            let changed = MCPBookMoveRefusal.changedSince(bookID: rows.readingID)
            guard BookMoveColumns(book) == rows.after, try bookRows(db, rows.readingID) == rows.bookRowsAfter
            else { throw changed }
            for member in rows.members {
                try requireMemberReads(
                    db, member, wing: member.rows.destinationWing, memberships: member.membershipsAfter,
                    applications: member.applicationsAfter, versionsIn: member.rows.destinationWing, changed)
                for application in member.rows.removedApplications {
                    guard try applicationRevives(db, application, postID: member.rows.postID, stamp: forwardStamp)
                    else { throw changed }
                }
            }
            for member in rows.members {
                for rowID in member.rows.severed {
                    guard try membershipRevives(
                        db, rowID, postID: member.rows.postID, intoWing: rows.sourceWing, stamp: forwardStamp)
                    else { throw changed }
                }
            }
            for rowID in rows.dismissed {
                guard try arrivalRevives(db, rowID, stamp: forwardStamp) else { throw changed }
            }

            let now = date.now
            let stamp = DateFormatter.variorumISO8601.string(from: now)
            for member in rows.members {
                for application in member.rows.addedApplications {
                    try db.execute(
                        sql: "UPDATE \(application.table) SET deleted_at = ? WHERE id = ? AND deleted_at IS NULL",
                        arguments: [stamp, application.id])
                }
                for application in member.rows.removedApplications {
                    try reviveWingMoveApplication(db, application, postID: member.rows.postID, stamp: forwardStamp)
                }
                var note = try livePost(db, member.rows.postID)
                note.wingId = member.rows.sourceWing
                note.updatedAt = now
                try note.update(db)
                try rehomeVersions(
                    db, member.rows.versionWings.map { ($0.key, from: member.rows.destinationWing, to: $0.value) },
                    now: now)
                for rowID in member.rows.severed {
                    try reviveWingMoveMembership(db, rowID, note: note, stamp: forwardStamp)
                }
            }
            book.wingId = rows.before.wingID
            book.shelfId = rows.before.shelfID
            book.shelfPosition = rows.before.shelfPosition
            book.querySpec = rows.before.querySpec
            book.autoTagIds = rows.before.autoTagIDs
            book.groupingTagId = rows.before.groupingTagID
            book.updatedAt = now
            try book.update(db)
            for rowID in rows.dismissed {
                try db.execute(sql: "UPDATE reading_post SET deleted_at = NULL WHERE id = ?", arguments: [rowID])
                try voidPurgeIntents(db, table: "reading_post", rowID: rowID)
            }
            try enforceOwnershipAfterRevival(db, postIDs: rows.members.map(\.rows.postID), now: now)
            return stamp
        }
    }

    /// **The redo — the same move again, on the same rows.** Returns the stamp
    /// it severed, dismissed and re-pointed on (the next undo revives exactly
    /// those), or nil when OBSOLETE (the book gone, no longer in the wing it
    /// came from, either wing or its own current wing dead — the inverse's
    /// rules mirrored). Refused WHOLE, the entry kept, when any row no longer
    /// reads the inverse's value (`changedSince` — the inverse's list, the
    /// other way) — and her door's own refusal first: a severed row that is a
    /// live MEMBER of a sealed or finished book (`readingSealed` /
    /// `lockedReading` — reopen or unseal, then redo). Her ⇧⌥⌘Z is her own act
    /// (no guard rides a redo), so a fence she put on a stay-behind book since
    /// is hers to cross.
    func reapplyMCPBookMove(_ rows: BookMoveRows, backwardStamp: String?) throws -> String? {
        try database.write { db -> String? in
            guard var book = try Reading.fetchOne(db, key: rows.readingID), book.deletedAt == nil,
                  try Queries.wingIsLive(db, id: rows.sourceWing),
                  try Queries.wingIsLive(db, id: book.wingId),
                  try sameEffectiveWing(db, book.wingId, rows.sourceWing),
                  try Queries.wingIsLive(db, id: rows.destinationWing)
            else { return nil }
            let changed = MCPBookMoveRefusal.changedSince(bookID: rows.readingID)
            guard BookMoveColumns(book) == rows.before, try bookRows(db, rows.readingID) == rows.bookRowsBefore
            else { throw changed }
            var live: [ReadingPost] = []
            for member in rows.members {
                for rowID in member.rows.severed {
                    guard let row = try ReadingPost.fetchOne(db, key: rowID), row.deletedAt == nil,
                          let reading = try Reading.fetchOne(db, key: row.readingId), reading.deletedAt == nil
                    else { throw changed }
                    if row.status == .member {
                        if reading.sealedAt != nil { throw OperationError.readingSealed(id: reading.id) }
                        if reading.locked { throw OperationError.lockedReading(id: reading.id) }
                    }
                    live.append(row)
                }
            }
            for member in rows.members {
                try requireMemberReads(
                    db, member, wing: member.rows.sourceWing, memberships: member.membershipsBefore,
                    applications: member.applicationsBefore, versionsIn: nil, changed)
                if let backwardStamp {
                    for application in member.rows.addedApplications {
                        guard try applicationRevives(db, application, postID: member.rows.postID, stamp: backwardStamp)
                        else { throw changed }
                    }
                }
            }

            let now = date.now
            let stamp = DateFormatter.variorumISO8601.string(from: now)
            for var row in live {
                row.deletedAt = now
                try row.update(db)
            }
            for member in rows.members {
                for application in member.rows.removedApplications {
                    try db.execute(
                        sql: "UPDATE \(application.table) SET deleted_at = ? WHERE id = ? AND deleted_at IS NULL",
                        arguments: [stamp, application.id])
                }
                if let backwardStamp {
                    for application in member.rows.addedApplications {
                        try reviveWingMoveApplication(db, application, postID: member.rows.postID, stamp: backwardStamp)
                    }
                }
                var note = try livePost(db, member.rows.postID)
                note.wingId = member.rows.destinationWing
                note.updatedAt = now
                try note.update(db)
                try rehomeVersions(
                    db, member.rows.versionWings.map { ($0.key, from: $0.value, to: member.rows.destinationWing) },
                    now: now)
            }
            book.wingId = rows.after.wingID
            book.shelfId = rows.after.shelfID
            book.shelfPosition = rows.after.shelfPosition
            book.querySpec = rows.after.querySpec
            book.autoTagIds = rows.after.autoTagIDs
            book.groupingTagId = rows.after.groupingTagID
            book.updatedAt = now
            try book.update(db)
            for rowID in rows.dismissed {
                try db.execute(
                    sql: "UPDATE reading_post SET deleted_at = ? WHERE id = ? AND deleted_at IS NULL",
                    arguments: [stamp, rowID])
            }
            return stamp
        }
    }

    // MARK: - The replays' checks (each answers before any write)

    /// A member still reads the act's (or the inverse's) value: live, its
    /// stored wing exactly `wing`, its live memberships and live applications
    /// exactly the given sets, and — for the inverse — every version the move
    /// re-homed still in `versionsIn`.
    private func requireMemberReads(
        _ db: Database, _ member: BookMoveMemberRows, wing: String, memberships: Set<String>,
        applications: Set<WingMoveApplication>, versionsIn: String?, _ changed: MCPBookMoveRefusal
    ) throws {
        guard let note = try Container.fetchOne(db, key: member.rows.postID), note.deletedAt == nil,
              note.wingId == wing
        else { throw changed }
        let state = try wingMoveState(db, postID: member.rows.postID)
        guard state.memberships == memberships, Set(state.applications) == applications else { throw changed }
        for (versionID, priorWing) in member.rows.versionWings {
            guard let version = try Container.fetchOne(db, key: versionID), version.deletedAt == nil,
                  version.wingId == (versionsIn ?? priorWing)
            else { throw changed }
        }
    }

    /// An application the move (or a replay) tombstoned on `stamp` can come
    /// back exactly: still on that stamp, its tag live, its target still this
    /// note (or a block placed in it), no live twin.
    private func applicationRevives(
        _ db: Database, _ application: WingMoveApplication, postID: String, stamp: String
    ) throws -> Bool {
        let (column, target): (String, String) = application.table == "post_tag"
            ? ("post_id", "a.post_id = :post")
            : ("block_id", """
                EXISTS (SELECT 1 FROM container_block cb WHERE cb.block_id = a.block_id
                        AND cb.container_id = :post AND cb.deleted_at IS NULL)
                """)
        guard let row = try Row.fetchOne(
            db,
            sql: """
                SELECT a.tag_id AS tag_id, a.\(column) AS target FROM \(application.table) a
                JOIN tag t ON t.id = a.tag_id AND t.deleted_at IS NULL
                WHERE a.id = :id AND a.deleted_at = :stamp AND \(target)
                """,
            arguments: ["id": application.id, "stamp": stamp, "post": postID])
        else { return false }
        return try liveApplication(
            db, table: application.table, tagID: row["tag_id"], targetColumn: column, targetID: row["target"]) == nil
    }

    /// A severed membership the move tombstoned on `stamp` can come back
    /// exactly (the note's revival rules — `reviveWingMoveMembership`'s): still
    /// on that stamp, its book live and in `wing`, no live row for the pair, a
    /// sealed book only for a sealed note.
    private func membershipRevives(
        _ db: Database, _ rowID: String, postID: String, intoWing wing: String, stamp: String
    ) throws -> Bool {
        guard let row = try ReadingPost.fetchOne(
                db, sql: "SELECT * FROM reading_post WHERE id = ? AND deleted_at = ?", arguments: [rowID, stamp]),
              let reading = try Reading.fetchOne(db, key: row.readingId), reading.deletedAt == nil,
              try sameEffectiveWing(db, reading.wingId, wing),
              let note = try Container.fetchOne(db, key: postID),
              reading.sealedAt == nil || note.locked,
              try livePairRow(db, postID: postID, readingID: reading.id) == nil
        else { return false }
        return true
    }

    /// A dismissed arrival can wait again: still on the act's stamp, its note
    /// live, no live row for the pair.
    private func arrivalRevives(_ db: Database, _ rowID: String, stamp: String) throws -> Bool {
        guard let row = try ReadingPost.fetchOne(
                db, sql: "SELECT * FROM reading_post WHERE id = ? AND deleted_at = ?", arguments: [rowID, stamp]),
              try Container.fetchOne(db, key: row.postId)?.deletedAt == nil,
              try livePairRow(db, postID: row.postId, readingID: row.readingId) == nil
        else { return false }
        return true
    }
}

extension Queries {
    /// **The book move's stay-behind MEMBER rows, in the act's own order** —
    /// the book's members in its order `(position, id)`, each one's member rows
    /// in OTHER live books earliest first (`bookWingMovePreview`'s loop), with
    /// whether that book is finished or sealed (the rows `relocateNote` would
    /// refuse on). The wire's frozen refusal decides over the READABLE ones
    /// (A-809-4). ∝ the book's members.
    public struct BookMoveStayBehind: Equatable, Sendable {
        public let noteID: String
        public let noteTitle: String
        public let bookID: String
        public let bookName: String
        public let finished: Bool
        public let sealed: Bool
    }

    public static func bookMoveStayBehind(_ db: Database, readingID: String) throws -> [BookMoveStayBehind] {
        var rows: [BookMoveStayBehind] = []
        for member in try bookMoveMembers(db, readingID: readingID) {
            for row in try Row.fetchAll(
                db,
                sql: """
                    SELECT r.id AS id, r.name AS name, r.locked AS locked, r.sealed_at AS sealed
                    FROM reading_post rp
                    JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL
                    WHERE rp.post_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                      AND rp.reading_id <> ?
                    ORDER BY rp.created_at, rp.id
                    """,
                arguments: [member.postID, readingID]) {
                rows.append(BookMoveStayBehind(
                    noteID: member.postID, noteTitle: member.title, bookID: row["id"], bookName: row["name"],
                    finished: (row["locked"] as Int?) == 1, sealed: (row["sealed"] as String?) != nil))
            }
        }
        return rows
    }
}
