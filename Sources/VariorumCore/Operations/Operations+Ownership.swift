import Dependencies
import Foundation
import GRDB

// OWNED BOOKS — the op family (13i-c U2; the sitting record §1, §2, §6, §18.4,
// §20; the 13i-c plan §3 and its §4 door enumeration).
//
// The ladder (§1): a GATHERING shows, a BOOK holds members, an OWNED book
// holds them EXCLUSIVELY — "there is no second place it lives". Ownership
// never changes the edit law (§2: editing a note is editing every book it is
// in); it removes the ambiguity, by refusing a second pointer and offering a
// COPY — always explicit, always lineage-edged ("copies are always
// ceremonies").
//
// What lives here:
// - the CONSULT — the pure `OwnershipDecision` table read at the one choke
//   point (`addPostToReading`) and the arrival seat; the refusal names the
//   choice a door must offer (P-2);
// - the two ceremonies that answer it — COPY IN and MOVE IN (claim-move) —
//   each also reachable as the answer to a waiting ARRIVAL;
// - OWN / STOP OWNING — the convert door, whose shared members fork in place;
// - the CEREMONY COPY every ownership fork mints (`ceremonyCopy`) — the
//   `duplicateAsVersion` family with the note's TAGS riding (ruled, §6).
//
// Sync (zero `Sync/` lines): every write is an ordinary row through this
// layer (S1). Races between devices converge through the SHIPPED R2 repair
// (SyncSpec §7's OWNED-exclusivity paragraph); this layer's own revival pass
// applies R2's shape locally wherever a LOCAL door revives membership rows.
extension Operations {
    // MARK: - The consult (the plan §3/§4 rows 1–2)

    /// Reads the ownership table for (book, note) and throws the choice the
    /// door must offer when a plain pointer would break an ownership promise.
    /// Every membership-creating road that inserts a plain member row calls
    /// it (the §4 enumeration); ceremonies are legal by construction.
    func consultOwnership(_ db: Database, book: Reading, postID: String) throws {
        let elsewhere = try Queries.noteMemberships(db, postID: postID, excluding: book.id)
        let facts = OwnershipDecision.NoteFacts(
            memberedElsewhere: !elsewhere.isEmpty,
            ownedElsewhere: elsewhere.contains { $0.owned })
        switch OwnershipDecision.verdict(targetOwned: book.owned, note: facts) {
        case .add:
            return
        case .needsChoice(.copyOrMove):
            throw OperationError.noteMemberedElsewhere(
                postID: postID, readingID: book.id, elsewhere: elsewhere.map(\.book.id))
        case .needsChoice(.copyOnly):
            // The EARLIEST owning claim names the owner (§18.4 — "first claim
            // wins"; a second owner can exist only as a sync residue).
            let owner = elsewhere.first { $0.owned }?.book.id ?? ""
            throw OperationError.noteOwnedElsewhere(
                postID: postID, readingID: book.id, owner: owner)
        }
    }

    // MARK: - The ceremony copy (P-13ic-5: tags ride every ownership copy)

    /// **The copy every ownership ceremony mints** — the Own conversion's
    /// forks, COPY IN, the seal's forks, the deep duplicate, the bind's
    /// copy-in limb. It is `copyPost` (the `duplicateAsVersion` family: whole
    /// live fans, archived takes riding, commits never copied, block names,
    /// presentations and comments copied, per-block `derived_from` edges plus
    /// ONE `version_of` anchor — "always lineage-edged", §2) **with the
    /// note's live TAGS riding** (ruled §6 — "stripping would vandalize the
    /// status/type taxonomy"; P-13ic-5 kept the OLDER copy doors tag-less —
    /// since 17y B3 item (c), her #169 tail ruling, Duplicate as Version
    /// carries tags too, through `copyLiveTags`; Diverge stays tag-less).
    ///
    /// The riding tags are a ROW copy, never an APPLYING ACT: no intake fires
    /// for them (PROVISIONAL P-13ic-U2-1 — the 13i-b record's F-6 reading of
    /// restore, applied to copies; it is also what lets a ceremony insert the
    /// copy's membership FIRST, the plan's own order, and keeps a seal's
    /// forks from being re-shared by another book's intake the moment they
    /// are minted). The book a ceremony places the copy in applies its own
    /// OUTFLOW where its letter says so (copy in does — a hand-add's class).
    ///
    /// A note with NO copyable block (an empty note — `copyPost` refuses
    /// `postHasNoBlocks`) copies as a BARE note: its row and its tags, no
    /// blocks and therefore no lineage edge (an edge joins blocks, and there
    /// is no text to descend). PROVISIONAL P-13ic-U2-2 — a ceremony must not
    /// fail on an empty note it is obliged to fork.
    func ceremonyCopy(_ db: Database, sourceID: String, now: Date) throws -> Container {
        let source = try livePost(db, sourceID)
        let copy: Container
        if try hasCopyableSlot(db, postID: sourceID) {
            copy = try copyPost(db, sourceID: sourceID, chosenPicks: nil, carryFans: true).post
        } else {
            let bare = Container(
                id: newID(), ownerId: currentOwnerID(), kind: .post,
                title: source.title, profile: source.profile, entryDate: source.entryDate,
                locked: false, floatingNotes: source.floatingNotes,
                segmentationDefault: source.segmentationDefault,
                lastTouchedAt: now, wingId: source.wingId,
                createdAt: now, updatedAt: now)
            try bare.insert(db)
            copy = bare
        }
        try copyLiveTags(db, from: sourceID, to: copy.id, wingID: source.wingId, now: now)
        return copy
    }

    /// Does `copyPlacements` find anything to copy — a live placement whose
    /// block is live and holds a live take? (Its own skip rules, asked first.)
    private func hasCopyableSlot(_ db: Database, postID: String) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (SELECT 1 FROM container_block cb
                  JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                  JOIN variant v ON v.block_id = b.id AND v.deleted_at IS NULL
                 WHERE cb.container_id = ? AND cb.deleted_at IS NULL)
                """,
            arguments: [postID]) ?? false
    }

    /// The source's live applications of live tags in its own wing, copied
    /// onto `targetID` as fresh rows (application order kept). A row copy —
    /// see `ceremonyCopy` for why it is not an act. (Internal since 17y B3
    /// item (c), when `duplicateAsVersion` rode it too; since VX-372 — D-C-1 —
    /// the duplicate APPLIES its tags through `applyLiveTags` instead, and the
    /// ceremony copy is this road's one caller.)
    func copyLiveTags(
        _ db: Database, from sourceID: String, to targetID: String, wingID: String, now: Date
    ) throws {
        let tagIDs = try String.fetchAll(
            db,
            sql: """
                SELECT pt.tag_id FROM post_tag pt
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL AND t.wing_id = ?
                WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                ORDER BY pt.created_at, pt.id
                """,
            arguments: [wingID, sourceID])
        for tagID in tagIDs {
            guard try liveApplication(db, table: "post_tag", tagID: tagID,
                                      targetColumn: "post_id", targetID: targetID) == nil
            else { continue }
            try PostTag(id: newID(), tagId: tagID, postId: targetID, createdAt: now).insert(db)
        }
    }

    /// A fork IN PLACE (the `divergePostForReading` body, inlined — the plan
    /// §3/§5): the ceremony copy takes the member's EXACT slot (position AND
    /// chapter) and the original's membership here is tombstoned — a
    /// member-class decision, so this book's intake never re-adds the
    /// original. The original lives on in its other books.
    func forkInPlace(_ db: Database, membership: ReadingPost, now: Date) throws -> Container {
        let copy = try ceremonyCopy(db, sourceID: membership.postId, now: now)
        try ReadingPost(
            id: newID(), readingId: membership.readingId, postId: copy.id,
            position: membership.position, sectionId: membership.sectionId,
            createdAt: now
        ).insert(db)
        var original = membership
        original.deletedAt = now
        try original.update(db)
        return copy
    }

    // MARK: - OWN / STOP OWNING (the convert door — the plan §3, sitting §6)

    /// One fork an ownership act made: the original, its copy, and where the
    /// original still lives — what the confirm listed and the receipt says.
    public struct OwnershipFork: Equatable, Sendable {
        public let originalID: String
        public let copyID: String
        /// The other books the ORIGINAL lives in (names, earliest first).
        public let elsewhereNames: [String]
    }

    public struct OwnConversionResult: Equatable, Sendable {
        /// The members that forked, in the book's order. Empty when nothing
        /// was shared — or the act was a no-op.
        public let copied: [OwnershipFork]
    }

    /// **"Own its notes"** (owned: true — the CONVERT door, her round-4
    /// ruling standing at §6) and **"Stop owning"** (owned: false).
    ///
    /// Owning, in ONE transaction: every live MEMBER that also lives in
    /// another live book FORKS IN PLACE — its ceremony copy (tags riding)
    /// takes this book's exact slot, the original's membership here is
    /// tombstoned, and the original keeps its other lives (round 4:
    /// "conversion-time copies persist as the independent notes they are").
    /// Sole and bookless members become owned in place — no row changes.
    /// Then `owned = 1`. The confirm's list is `Queries.ownConversionPreview`
    /// — the same `sharedMembers` predicate this acts on.
    ///
    /// Refuses a GATHERING (`wrongReadingKind` — owning requires a book; a
    /// category error, §6) and a FINISHED or SEALED book (`lockedReading` —
    /// converting forks members, a structural act; un-finish first,
    /// PROVISIONAL P-13ic-2). Owning an owned book is a no-op.
    /// NO structural-undo entry (PROVISIONAL P-13ic-1): the copies are real
    /// notes, and Stop owning is the symmetric door.
    ///
    /// Stop owning: `owned = 0`; the members stay, exclusivity lifts, nothing
    /// else moves. No-op when not owned (a gathering is never owned, so this
    /// direction never refuses one). Allowed on a finished or sealed book —
    /// it moves no row.
    @discardableResult
    public func setReadingOwned(_ id: String, owned: Bool) throws -> OwnConversionResult {
        try database.write { db in
            var reading = try liveReading(db, id)
            guard owned else {
                guard reading.owned else { return OwnConversionResult(copied: []) }
                reading.owned = false
                reading.updatedAt = date.now
                try reading.update(db)
                return OwnConversionResult(copied: [])
            }
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: id, expected: .book)
            }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: id)
            }
            guard !reading.owned else { return OwnConversionResult(copied: []) }
            let now = date.now
            let forks = try forkSharedMembers(db, readingID: id, now: now)
            reading.owned = true
            reading.updatedAt = now
            try reading.update(db)
            return OwnConversionResult(copied: forks)
        }
    }

    /// Forks every member of the book that lives elsewhere (the shared step
    /// of owning and sealing — `Queries.sharedMembers` is the set).
    func forkSharedMembers(
        _ db: Database, readingID: String, now: Date
    ) throws -> [OwnershipFork] {
        var forks: [OwnershipFork] = []
        for shared in try Queries.sharedMembers(db, readingID: readingID) {
            guard let membership = try ReadingPost.fetchOne(db, key: shared.membershipID)
            else { continue }
            let copy = try forkInPlace(db, membership: membership, now: now)
            forks.append(OwnershipFork(
                originalID: shared.postID, copyID: copy.id,
                elsewhereNames: shared.elsewhere.map(\.name)))
        }
        return forks
    }

    // MARK: - COPY IN (the ceremony — §6, §4's "copy in")

    public struct CopyInResult: Equatable, Sendable {
        /// The fresh note — the book's new member.
        public let copy: Container
        /// Its membership row here.
        public let membership: ReadingPost
        /// The ARRIVAL this copy answered, now a decided MEMBER-class
        /// tombstone (P-13ic-3) — nil for a hand copy-in.
        public let answeredArrivalID: String?
    }

    /// **COPY IN** — the note's ceremony copy (the whole family, its tags
    /// riding — P-13ic-5) joins the book at `insert`, and the original is
    /// untouched in every book it lives in. The copy's membership is inserted
    /// FIRST, then the book's OUTFLOW rides it (a hand-add's class —
    /// `newPostInReading`'s order: this pair is decided before any tagging
    /// act is heard elsewhere).
    ///
    /// Legal on any open BOOK (a copy is sole by construction — no consult).
    /// Refuses a gathering (`wrongReadingKind`), a finished or sealed book
    /// (`lockedReading`), a full one (`readingAtCapacity`), a dead note.
    /// Registers ONE structural-undo entry, `duplicateAsVersion`-shaped: the
    /// inverse un-mints the copy (its membership dies in the cascade), the
    /// redo revives it exact-row through `restoreContainer` (the diverge
    /// precedent).
    @discardableResult
    public func copyPostIntoReading(
        _ postID: String, into readingID: String, at insert: InsertPosition = .end
    ) throws -> CopyInResult {
        try copyIn(answering: nil, postID: postID, readingID: readingID, at: insert)
    }

    /// **COPY IN, answering a waiting ARRIVAL** (the plan §3's judgment arms —
    /// the face offers it on a plain book's arrival of a note owned elsewhere,
    /// and on an owned book's arrival of a membered note). The arrival row
    /// names the note and the book; the copy lands at the END, unsectioned
    /// (the `seatArrival` rule — §4: arrivals land at the end). The arrival
    /// row is tombstoned as a MEMBER-class decision — PERMANENT, so a fresh
    /// act never offers a second copy (PROVISIONAL P-13ic-3).
    @discardableResult
    public func copyPostIntoReading(answering pairID: String) throws -> CopyInResult {
        try copyIn(answering: pairID, postID: nil, readingID: nil, at: .end)
    }

    private func copyIn(
        answering pairID: String?, postID: String?, readingID: String?, at insert: InsertPosition
    ) throws -> CopyInResult {
        let result: CopyInResult = try database.write { db in
            var arrival: ReadingPost?
            if let pairID {
                guard let row = try ReadingPost.fetchOne(db, key: pairID),
                      row.deletedAt == nil, row.status == .arrival
                else { throw OperationError.arrivalNotFound(id: pairID) }
                arrival = row
            }
            let bookID = arrival?.readingId ?? readingID ?? ""
            let sourceID = arrival?.postId ?? postID ?? ""
            let reading = try liveReading(db, bookID)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: bookID, expected: .book)
            }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: bookID)
            }
            try requireSameWing(db, post: try livePost(db, sourceID), book: reading)
            if let cap = reading.maxPosts, try liveMemberCount(db, readingID: bookID) >= cap {
                throw OperationError.readingAtCapacity(id: bookID)
            }
            let now = date.now
            if var answered = arrival {
                answered.status = .member  // the member class: decided for good
                answered.deletedAt = now
                try answered.update(db)
            }
            let copy = try ceremonyCopy(db, sourceID: sourceID, now: now)
            let membership = ReadingPost(
                id: newID(), readingId: bookID, postId: copy.id,
                position: try readingPosition(db, readingID: bookID, at: insert),
                createdAt: now)
            try membership.insert(db)
            try applyAutoTag(db, book: reading, postID: copy.id, now: now)
            return CopyInResult(
                copy: copy, membership: membership, answeredArrivalID: arrival?.id)
        }
        let copyID = result.copy.id
        registerMintedContainerEntry(label: "Copy In", copyID)
        return result
    }

    // MARK: - MOVE IN (claim-move — §6, §4's "claim-move")

    public struct MoveInResult: Equatable, Sendable {
        /// The note's membership here (a waiting arrival here, seated; or a
        /// fresh row).
        public let membership: ReadingPost
        /// Every other row the move severed, tombstoned on the act's stamp —
        /// what the confirm listed (`Queries.moveInPreview`) and the receipt
        /// names.
        public let severed: [ReadingPost]
    }

    /// **MOVE IN** — the note leaves every other book and joins this one:
    /// every OTHER live row of the note in a live book (members AND waiting
    /// arrivals) is tombstoned — members as member-class decisions (removed
    /// for good), arrivals as dismissals — then the note joins here (a
    /// waiting arrival here flips to a member at `insert`; the book's OUTFLOW
    /// rides, a hand-add's class). The daily Journal's membership is severed
    /// like any other when the note is claimed out of it (§10).
    ///
    /// Refuses a gathering, a finished/sealed target (`lockedReading`), a
    /// full one (`readingAtCapacity`), a note already a member here
    /// (`alreadyInReading`) — AND a severed MEMBERSHIP in a FINISHED book
    /// (`lockedReading` naming THAT book): finishing froze its assembly, and
    /// a move is a removal there (PROVISIONAL P-13ic-U2-4 — the face offers
    /// copy in alone; the preview flags the row).
    ///
    /// A plain target is legal too (the composite is release + add; the faces
    /// offer move in only on an owned book — §4). NO structural-undo entry
    /// (PROVISIONAL P-13ic-12 — the `addPostToReading` class; a re-add by
    /// hand is the road back).
    @discardableResult
    public func movePostIntoReading(
        _ postID: String, into readingID: String, at insert: InsertPosition = .end
    ) throws -> MoveInResult {
        try moveIn(answering: nil, postID: postID, readingID: readingID, at: insert)
    }

    /// **MOVE IN, answering a waiting ARRIVAL** (the owned book's claim-move
    /// on its own bell): the arrival row itself becomes the member, at the
    /// END, unsectioned (`seatArrival`'s rule).
    @discardableResult
    public func movePostIntoReading(answering pairID: String) throws -> MoveInResult {
        try moveIn(answering: pairID, postID: nil, readingID: nil, at: .end)
    }

    private func moveIn(
        answering pairID: String?, postID: String?, readingID: String?, at insert: InsertPosition
    ) throws -> MoveInResult {
        try database.write { db in
            var arrival: ReadingPost?
            if let pairID {
                guard let row = try ReadingPost.fetchOne(db, key: pairID),
                      row.deletedAt == nil, row.status == .arrival
                else { throw OperationError.arrivalNotFound(id: pairID) }
                arrival = row
            }
            let bookID = arrival?.readingId ?? readingID ?? ""
            let noteID = arrival?.postId ?? postID ?? ""
            let reading = try liveReading(db, bookID)
            guard reading.kind == .book else {
                throw OperationError.wrongReadingKind(id: bookID, expected: .book)
            }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: bookID)
            }
            try requireSameWing(db, post: try livePost(db, noteID), book: reading)
            if try liveMembership(db, postID: noteID, readingID: bookID) != nil {
                throw OperationError.alreadyInReading(postID: noteID, readingID: bookID)
            }
            if let cap = reading.maxPosts, try liveMemberCount(db, readingID: bookID) >= cap {
                throw OperationError.readingAtCapacity(id: bookID)
            }
            let others = try Queries.noteMemberships(
                db, postID: noteID, excluding: bookID, membersOnly: false)
            if let frozen = others.first(where: { $0.finished && $0.status == .member }) {
                throw OperationError.lockedReading(id: frozen.book.id)
            }
            let now = date.now
            var severed: [ReadingPost] = []
            for other in others {
                guard var row = try ReadingPost.fetchOne(db, key: other.rowID) else { continue }
                row.deletedAt = now
                try row.update(db)
                severed.append(row)
            }
            let membership: ReadingPost
            if var waiting = try livePairRow(db, postID: noteID, readingID: bookID) {
                // Only an arrival can be live here (a member threw above).
                waiting.status = .member
                waiting.sectionId = nil
                waiting.position = try readingPosition(db, readingID: bookID, at: insert)
                try waiting.update(db)
                membership = waiting
            } else {
                membership = ReadingPost(
                    id: newID(), readingId: bookID, postId: noteID,
                    position: try readingPosition(db, readingID: bookID, at: insert),
                    createdAt: now)
                try membership.insert(db)
            }
            try applyAutoTag(db, book: reading, postID: noteID, now: now)
            return MoveInResult(membership: membership, severed: severed)
        }
    }

    // MARK: - THE REVIVAL PASS (the plan §3/§4 rows 7–9 — R2's shape, applied locally)

    /// **After any door that REVIVES membership rows** — `restoreContainer`
    /// (the note's own memberships), `restoreReading` (the book's),
    /// `reapplySmartConversion` (the bind's redo), `revertDiverge` (the diverge
    /// undo revives the original's row) and `reapplyDiverge`,
    /// `reapplyMintedContainer` (through `restoreContainer`) — the revived
    /// rows may break an ownership promise the doors upheld when each row was
    /// made (a note added elsewhere while its owned book sat in the Trash).
    /// This pass restores the promise the way SyncSpec §7's R2 repair does
    /// for a sync race, applied locally to `postIDs`:
    ///
    /// for every note with MORE THAN ONE live member row in live books where
    /// ANY is owned, the EARLIEST-CREATED membership stands (`created_at,
    /// id` — the local "earlier act"; R2 ranks by `server_seq` for the same
    /// reason — PROVISIONAL P-13ic-9). If the standing row is OWNED, every
    /// later owned-side row DEMOTES to an ARRIVAL (the bell: claim / copy in /
    /// leave) and every later PLAIN-side row is TOMBSTONED (member-class,
    /// recoverable). If the standing row is PLAIN, every owned-side row bells
    /// instead. Nothing destroyed, nothing silent — the book shows the bell,
    /// the row is recoverable. Deterministic and idempotent (the repaired
    /// state has no violation). In the caller's transaction, on its stamp.
    func enforceOwnershipAfterRevival(
        _ db: Database, postIDs: [String], now: Date
    ) throws {
        for postID in Set(postIDs).sorted() {
            let rows = try Row.fetchAll(
                db,
                sql: """
                    SELECT rp.id AS id, r.owned AS owned
                    FROM reading_post rp
                    JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL
                     AND r.kind = 'book'
                    WHERE rp.post_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                    ORDER BY rp.created_at, rp.id
                    """,
                arguments: [postID])
            let owned = rows.map { ($0["owned"] as Bool?) ?? false }
            guard rows.count > 1, owned.contains(true) else { continue }
            let standingIsOwned = owned[0]
            for index in rows.indices.dropFirst() {
                guard var membership = try ReadingPost.fetchOne(db, key: rows[index]["id"] as String)
                else { continue }
                if owned[index] {
                    membership.status = .arrival
                } else if standingIsOwned {
                    membership.deletedAt = now
                } else {
                    continue   // a plain row beside a plain standing row: legal
                }
                try membership.update(db)
            }
        }
    }

    // MARK: - The daily Journal's bell (§6: "an owned-elsewhere note bells, never throws")

    /// Rings the daily Journal's door for a pair the ownership table would
    /// not let `addPostToReading` seat: an ARRIVAL row at the END, unless any
    /// row for the pair appeared meanwhile (the decided read, re-asked inside
    /// the writer — tombstone-means-decided). Returns whether it rang.
    func bellAtDailyDoor(postID: String, readingID: String) throws -> Bool {
        try database.write { db in
            let decided = try Bool.fetchOne(
                db,
                sql: "SELECT EXISTS (SELECT 1 FROM reading_post WHERE reading_id = ? AND post_id = ?)",
                arguments: [readingID, postID]) ?? false
            guard !decided else { return false }
            try ReadingPost(
                id: newID(), readingId: readingID, postId: postID,
                position: try readingPosition(db, readingID: readingID, at: .end),
                status: .arrival, createdAt: date.now
            ).insert(db)
            return true
        }
    }

    // MARK: - HIDE-OWNED (§6 — the release valve)

    /// A GATHERING's hide-owned toggle (§6): `true` hides notes an owned book
    /// holds from this gathering's assembly, `false` shows them (badged), and
    /// nil FOLLOWS the global default (`hide_owned_default`, SHOW unless she
    /// says otherwise). Gatherings only — a book shows its members, owned or
    /// not (`wrongReadingKind`). Identity-level metadata: no-op-guarded.
    public func setReadingHideOwned(_ id: String, _ hide: Bool?) throws {
        try database.write { db in
            var reading = try liveReading(db, id)
            guard reading.kind == .gathering else {
                throw OperationError.wrongReadingKind(id: id, expected: .gathering)
            }
            guard reading.hideOwned != hide else { return }
            reading.hideOwned = hide
            reading.updatedAt = date.now
            try reading.update(db)
        }
    }

    /// Is the note BOOKLESS — no live member row in any live book? (The
    /// release receipt's question: "Released — it's in the Pool now.")
    func isBookless(_ db: Database, postID: String) throws -> Bool {
        try Queries.noteMemberships(db, postID: postID).isEmpty
    }
}
