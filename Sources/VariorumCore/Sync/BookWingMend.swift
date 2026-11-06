import Foundation
import GRDB

// **BOOKS NEVER SPAN WINGS, UNDER SYNC** (VX-857 — the VX-808 run; her ruling
// at the QUESTIONS #261 walkthrough, 2026-11-05: "no, no cross wing books …
// this is a gap we should close"; the binding text is the run record
// `notes/plans/fixes/vx-808-arrivals-books.md` §6 Unit B1, the orchestrator's
// ruling A-808-1..5, and SyncSpec §7's cross-wing mend). VX-805 built this
// repair class for THE DAILY JOURNAL alone (`JournalWingMend.swift`'s old
// piece 2); this file is its generalization to EVERY live book, the Journal
// now its special case (A-808-1).
//
// The class: two devices' concurrent acts leave a live MEMBER row of a live
// book whose note sits in another wing — A moves book X to wing W2 (its
// members move with it, ON A); B, offline, still sees X in W1 and files note P
// into it. The dumb server accepts both, no index is violated, and without
// this repair P stays in W1, a member of a book in W2, on every device.
//
// THE MEND (members follow their book — her VX-435 ruling, "the same
// members-move-with-the-book semantics as moveReadingToWing", generalized):
// for each note in scope, its live MEMBER rows in live books (`kind='book'` —
// a gathering holds nothing; ARCHIVED and FINISHED/SEALED books included: a
// repair is not authoring). When they all sit in the note's own effective
// wing, nothing. Otherwise ONE ANCHOR membership by the ruled rank (A-808-4):
//   (1) a FENCED book first — THE daily Journal's marker or the Private mark,
//       on the SAME two fragments the MCP fence reads (never a parallel
//       fence), so a resolution can never strip a note's fence leg;
//   (2) then a FROZEN book (finished or sealed — her door never severs a
//       frozen member; it refuses);
//   (3) then the EARLIEST-ACCEPTED membership (`sync_row_seq` ascending, a
//       never-accepted row last, ties by id — SyncSpec §7's OWNED rank).
// Within a tier, ties fall through to the next term. The note moves into the
// anchor's EFFECTIVE wing through the note move's ONE relocation
// (`Operations.relocateNote`, every reading KEPT — this act severs nothing
// itself: its saved versions ride, its post and block tags re-point by path,
// adopt-else-mint, as row copies, no intake). Each membership left in a book
// of ANOTHER wing is DEMOTED (A-808-5, option D — PROVISIONAL, her bundle):
// it flips to `status='arrival'` in place (OWNED's own mechanics — the pair's
// one live row stays, `uq_reading_post_live` untouched), stamped
// `arrival_provenance = {"kind":"wing_mend"}` — the displaced filing becomes
// a visible card at that book's door (un-seatable across wings, P-805-B3: a
// record and a one-press dismissal). A loser in a FROZEN book takes the
// DISMISSAL-RECORD class instead (the flip and the tombstone in one write — a
// finished book is never belled; this mend is that class's fourth producer).
//
// Every write enqueues its outbox row explicitly (apply mode mutes the outbox
// triggers — SyncSpec §7). Deterministic on every device (books, wings and
// accepted seqs are converged state; two devices mending one note write the
// same wing and statuses, and their fresh application/tag ids converge by the
// standing tag.path and pure-duplicate repairs). Idempotent: afterwards every
// member row of the note sits in the note's wing, and a demoted row is an
// arrival, which never re-enters scope. Never for a dead book: the member
// query joins live books only.
//
// THE OCCASIONS (A-808-2 — ∝ the batch, never the corpus):
//   (a) a reading_post row LANDED as a live MEMBER (as it arrived, or as an
//       inline repair resolved it) → the post it names. An ARRIVAL landing is
//       never an occasion (A-808-3: an arrival is no membership; and an AI may
//       propose at READ reach — VX-811 — so a bell must never relocate a note).
//   (b) a live book's row LANDED with a changed wing pointer → its live
//       members still in the wing it moved FROM (P-805-B7's tightening: what
//       spares a deliberate note move-out met between its chunks); landed NEW
//       here → all its live members.
//   (c) the daily-Journal keeper handed a loser's members over this batch →
//       those posts (the one Journal-only input).
// Deliberately NEVER a container landing: a deliberate note move-out can be
// met between its container chunk and its membership-tombstone chunk, and
// mending then would undo her move.
extension SyncEngine {
    /// The provenance every wing-mend demotion stamps (A-808-5; the spelling
    /// KEPT by Unit B2's vocabulary ruling, A-808-6) — and, a DEMOTION, its
    /// moment (A-808-7 (ii)): `{"at": <the mend's stamp>, "kind": "wing_mend"}`,
    /// canonical JSON through `ArrivalProvenance` (a demoted row's `created_at`
    /// is the ORIGINAL filing's, and would mis-say since when).
    static func wingMendArrivalProvenance(at stamp: String) throws -> String {
        var provenance = ArrivalProvenance(kind: .wingMend)
        provenance.at = stamp
        return try provenance.encodedJSON()
    }

    /// Whether a `reading_post` row lands as a live MEMBER — the mend's
    /// occasion (a). An absent or NULL status reads as the column's default
    /// ('member' — a pre-13i-a mirror row's never-set value).
    static func landsAsLiveMember(_ row: SyncRow) -> Bool {
        guard row.table == "reading_post", !row.isTombstoned else { return false }
        return row.columns["status"] != .text(MembershipStatus.arrival.rawValue)
    }

    /// THE MEND (the file header). Runs post-batch, right after the Journal
    /// keeper, inside the apply transaction. Returns the repair writes it
    /// enqueued.
    func mendBookMembersIntoTheirWing(
        _ db: Database, touched: TouchedRows, keeperMoved: Set<String>
    ) throws -> Int {
        var wings = WingLookup()

        // The scope — the three occasions, never the corpus.
        var scope = keeperMoved                                     // (c)
        scope.formUnion(touched.liveMemberLandingPosts)              // (a)
        for (readingID, landing) in touched.readingWingLandings {    // (b)
            let members = try liveBookMemberPostIDs(db, readingID: readingID)
            guard !members.isEmpty else { continue }
            if let priorWing = landing {
                let movedFrom = try wings.effective(db, priorWing)
                for postID in members where try Queries.effectiveWing(db, ofPost: postID) == movedFrom {
                    scope.insert(postID)
                }
            } else {
                scope.formUnion(members)
            }
        }
        guard !scope.isEmpty else { return 0 }

        let ops = Operations()
        let now = date.now
        let stamp = nowStamp()
        let demotionStamp = try Self.wingMendArrivalProvenance(at: stamp)
        var adoptions: [String: Operations.TagAdoption] = [:]
        var repairs = 0
        for postID in scope.sorted() {
            guard let post = try Container.fetchOne(db, key: postID),
                  post.deletedAt == nil, post.kind == .post,
                  let noteWing = try Queries.effectiveWing(db, ofPost: postID)
            else { continue }
            let memberships = try liveMemberships(db, postID: postID)
            guard !memberships.isEmpty else { continue }
            // A book wing pointer naming NO local wing row is a straggler
            // (causal order delivers the wing first, so this is defensive):
            // its effective wing is unknown, and reading it as Home could
            // move the note or demote a row toward the wrong wing. Never
            // write on it.
            var placed: [(membership: Membership, wing: String)] = []
            var straggles = false
            for membership in memberships {
                guard try wings.isKnown(db, membership.wingID) else { straggles = true; break }
                placed.append((membership, try wings.effective(db, membership.wingID)))
            }
            guard !straggles, placed.contains(where: { $0.wing != noteWing }) else { continue }

            let anchor = placed.min { Self.outranks($0.membership, $1.membership) }!
            let target = anchor.wing

            // The note follows the anchor's book.
            if noteWing != target {
                // Keep EVERY reading the note has rows in: the relocation
                // severs nothing — the demotions below are the only status
                // change, and they are this repair's own writes.
                let keeping = Set(try ops.wingMoveMemberships(db, postID: postID).map(\.reading.id))
                var adoption = adoptions[target] ?? Operations.TagAdoption(wing: target)
                _ = try ops.relocateNote(
                    db, postID: postID, to: target, keeping: keeping, adoption: &adoption, now: now)
                adoptions[target] = adoption
                try enqueueExplicitly(db, table: "container", rowID: postID)
                repairs += 1
                for versionID in try Queries.noteVersionIDs(db, of: postID) {
                    guard try Container.fetchOne(db, key: versionID)?.deletedAt == nil else { continue }
                    try enqueueExplicitly(db, table: "container", rowID: versionID)
                    repairs += 1
                }
            }

            // The memberships left in a book of another wing: DEMOTED (D).
            for (membership, wing) in placed where wing != target {
                if membership.frozen {
                    // The dismissal-record class: a finished book is never belled.
                    try db.execute(
                        sql: """
                            UPDATE reading_post
                            SET status = 'arrival', deleted_at = ?, arrival_provenance = ?
                            WHERE id = ?
                            """,
                        arguments: [stamp, demotionStamp, membership.id])
                } else {
                    try db.execute(
                        sql: "UPDATE reading_post SET status = 'arrival', arrival_provenance = ? WHERE id = ?",
                        arguments: [demotionStamp, membership.id])
                }
                try enqueueExplicitly(db, table: "reading_post", rowID: membership.id)
                repairs += 1
            }
        }
        for target in adoptions.keys.sorted() {
            for written in adoptions[target]!.written {
                try enqueueExplicitly(db, table: written.table, rowID: written.rowID)
                repairs += 1
            }
        }
        return repairs
    }

    // MARK: - The anchor

    /// One live MEMBER row of a live book, with the rank's three facts.
    struct Membership {
        let id: String
        let readingID: String
        let wingID: String
        let fenced: Bool
        let frozen: Bool
        /// The row's known `server_seq`; 0 = never accepted (ranks LAST).
        let seq: Int64
    }

    /// The ruled rank (A-808-4): fenced → frozen → earliest-accepted → id.
    /// True when `lhs` outranks `rhs` (the anchor is the minimum).
    static func outranks(_ lhs: Membership, _ rhs: Membership) -> Bool {
        if lhs.fenced != rhs.fenced { return lhs.fenced }
        if lhs.frozen != rhs.frozen { return lhs.frozen }
        let (left, right) = (lhs.seq == 0 ? Int64.max : lhs.seq, rhs.seq == 0 ? Int64.max : rhs.seq)
        if left != right { return left < right }
        return lhs.id < rhs.id
    }

    /// The note's live MEMBER rows in live BOOKS (gatherings hold nothing;
    /// a dead book's row is inert — never a mend for a dead book). The two
    /// fence legs are the MCP fence's own SQL fragments (`Queries
    /// .dailyJournalLegForBook` / `.privateLegForBook`).
    private func liveMemberships(_ db: Database, postID: String) throws -> [Membership] {
        try Row.fetchAll(
            db,
            sql: """
                SELECT rp.id AS id, r.id AS reading_id, r.wing_id AS wing_id,
                       ((\(Queries.dailyJournalLegForBook)) OR (\(Queries.privateLegForBook))) AS fenced,
                       (r.locked = 1 OR r.sealed_at IS NOT NULL) AS frozen,
                       COALESCE(s.server_seq, 0) AS seq
                FROM reading_post rp
                JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL AND r.kind = 'book'
                LEFT JOIN sync_row_seq s ON s.table_name = 'reading_post' AND s.row_id = rp.id
                WHERE rp.post_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                ORDER BY rp.id
                """,
            arguments: [postID]
        ).map { row in
            Membership(
                id: row["id"], readingID: row["reading_id"], wingID: row["wing_id"],
                fenced: row["fenced"], frozen: row["frozen"], seq: row["seq"])
        }
    }

    /// A live BOOK's live member posts (occasion (b)'s set; a gathering or a
    /// dead reading answers none).
    private func liveBookMemberPostIDs(_ db: Database, readingID: String) throws -> [String] {
        try String.fetchAll(
            db,
            sql: """
                SELECT rp.post_id FROM reading_post rp
                JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL AND r.kind = 'book'
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                ORDER BY rp.post_id
                """,
            arguments: [readingID])
    }

    /// The pass's wing reads, once each: whether a pointer names a local wing
    /// row at all (a straggler names none), and its EFFECTIVE wing as surfaces
    /// read it (a dead or dangling pointer is Home's — `Queries.wingIsLive`).
    private struct WingLookup {
        private var known: [String: Bool] = [:]
        private var live: [String: Bool] = [:]

        mutating func isKnown(_ db: Database, _ wingID: String) throws -> Bool {
            if wingID.isEmpty { return true }
            if let cached = known[wingID] { return cached }
            let exists = try Bool.fetchOne(
                db, sql: "SELECT EXISTS (SELECT 1 FROM wing WHERE id = ?)", arguments: [wingID]) ?? false
            known[wingID] = exists
            return exists
        }

        mutating func effective(_ db: Database, _ wingID: String) throws -> String {
            if wingID.isEmpty { return "" }
            if let cached = live[wingID] { return cached ? wingID : "" }
            let isLive = try Queries.wingIsLive(db, id: wingID)
            live[wingID] = isLive
            return isLive ? wingID : ""
        }
    }
}
