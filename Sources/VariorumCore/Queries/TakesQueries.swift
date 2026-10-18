import Foundation
import GRDB

// The takes/lens view family's read side (Phase 11, Step A3 — the kickoff
// spike record). One combined traversal so the board's standing observation
// is a single fetch, cost ∝ the post's own size (P1): slots + active fans +
// lenses with their effective picks + the fan-style setting + the seal.
extension Queries {
    /// One post's takes-board projection.
    public struct TakesProjection: Equatable, Sendable {
        /// The post's slots in reading order (the ordinary traversal —
        /// chosen resolution; lenses overlay app-side, never here).
        public var slots: [RenderedBlock]
        /// blockID → the block's live ACTIVE fan, in fan order (the fan
        /// definition — archived takes are FanPanel/history material).
        public var fans: [String: [Variant]]
        /// The post's live lenses, stable order.
        public var lenses: [Lens]
        /// lensID → blockID → variantID (EFFECTIVE picks — dangling
        /// dropped, the fall-through class).
        public var lensSelections: [String: [String: String]]
        /// 13j J5 — lensID → blockID → the pick that was DROPPED, and why.
        /// The other half of `lensSelections`: the fall-through is correct
        /// and silent, and her ruling is that a lens must say so in place
        /// with a one-click way back. Rides the projection for
        /// `unplacedOrigins`' reason — the board already re-reads on exactly
        /// the writes that change it (archiving, deleting or restoring a
        /// take all touch `variant`).
        public var lensDangles: [String: [String: DanglingPick]]
        public var fanStyle: FanStyle
        public var sealed: Bool
        /// The post's profile + entry date (taste-checkpoint R84: the
        /// journal-shaped surfaces show the R84 journal note; the
        /// Takes bottom bar shows the date face). Same container row the
        /// seal already reads.
        public var profile: Profile?
        public var entryDate: String?
        /// 13f W10b — blockID → the RELEASED originals it was derived from
        /// (live, unplaced; `Queries.unplacedOrigins`). Absent = no such
        /// origin, so the "Show Original Block" door isn't rendered there
        /// (P-2). It rides the projection rather than a fourth observation
        /// because the board already re-reads on exactly the writes that
        /// change it (a divide-W or merge lands new slots).
        public var unplacedOrigins: [String: [UnplacedOrigin]]
        /// 13k K9 — blockID → the block's CALLOUT FRAME, for the boards to
        /// draw (her instruction: *"callouts are supposed to be added to
        /// take mode as well"*; the ruled shape is ONE frame around the
        /// block's whole takes region — one block, one frame, takes inside
        /// it, R16/R27's letter). Absent = a plain block; malformed JSON is
        /// absent too (the fail-open presentation doctrine).
        ///
        /// It rides the projection rather than a fifth observation for the
        /// reason `unplacedOrigins` does: the board already re-reads on
        /// exactly the writes that change it (`updateBlockPresentation`
        /// writes the block row this projection already joins), and the
        /// read is the one Write's editor has always made
        /// (`blockPresentations`, cost ∝ the post).
        public var presentations: [String: BlockPresentation]

        public init(
            slots: [RenderedBlock] = [], fans: [String: [Variant]] = [:],
            lenses: [Lens] = [], lensSelections: [String: [String: String]] = [:],
            lensDangles: [String: [String: DanglingPick]] = [:],
            fanStyle: FanStyle = .stack, sealed: Bool = false,
            profile: Profile? = nil, entryDate: String? = nil,
            unplacedOrigins: [String: [UnplacedOrigin]] = [:],
            presentations: [String: BlockPresentation] = [:]
        ) {
            self.slots = slots
            self.fans = fans
            self.lenses = lenses
            self.lensSelections = lensSelections
            self.lensDangles = lensDangles
            self.fanStyle = fanStyle
            self.sealed = sealed
            self.profile = profile
            self.entryDate = entryDate
            self.unplacedOrigins = unplacedOrigins
            self.presentations = presentations
        }
    }

    public static func takesProjection(
        _ db: Database, post containerID: String
    ) throws -> TakesProjection {
        let slots = try renderPost(db, containerID: containerID)
        let fans = try activeFans(db, blockIDs: slots.filter { !$0.isGap }.map(\.blockID))
        let lenses = try Queries.lenses(db, post: containerID)
        var selections: [String: [String: String]] = [:]
        var dangles: [String: [String: DanglingPick]] = [:]
        for lens in lenses {
            selections[lens.id] = try effectiveLensSelection(db, lens: lens.id)
            // 13j J5: only where there IS something to say — an entry per
            // lens with no dangling pick would make "does this lens have a
            // problem" a dictionary lookup that always succeeds.
            let dangling = try danglingLensPicks(db, lens: lens.id)
            if !dangling.isEmpty { dangles[lens.id] = dangling }
        }
        let header = try Row.fetchOne(
            db, sql: "SELECT locked, profile, entry_date FROM container WHERE id = ?",
            arguments: [containerID])
        return TakesProjection(
            slots: slots, fans: fans, lenses: lenses, lensSelections: selections,
            lensDangles: dangles,
            fanStyle: try fanStyle(db),
            sealed: header?["locked"] ?? false,
            profile: (header?["profile"] as String?).flatMap(Profile.init(rawValue:)),
            entryDate: header?["entry_date"],
            unplacedOrigins: try unplacedOrigins(db, inContainer: containerID),
            // 13k K9: the SAME read Write's decoration layer makes, so the
            // two surfaces can never disagree about which blocks are framed.
            presentations: try blockPresentations(db, containerID: containerID))
    }

    /// blockID → the block's live ACTIVE fan in fan order, for a set of
    /// blocks (round 1 NIT 9: ONE tested home for the per-block fan fetch —
    /// `takesProjection` and the aligned/outline view models all read
    /// through this, never re-typed SQL).
    /// **ONE statement per call, not one per block (pre-13u Act 4, 17c
    /// P21).** This ran a separate fetch inside a Swift loop, and
    /// `takesProjection` hands it every non-gap slot of the post — then
    /// `observeTakes` HOLDS that projection, whose region includes
    /// `variant`, so a note of N blocks issued N statements at autosave
    /// rate. Measured on the seeded Sherlock corpus (a 212-block story, on
    /// disk and encrypted): `takesProjection` 71.0 ms → 32.3 ms; on an
    /// 800-block note the fan fetch alone went 353 ms → 237 ms — a smaller
    /// ratio than the statement count suggests, because what remains is
    /// decoding the same 2,400 rows. Cost was always proportional to the
    /// NOTE and never the corpus — so this is a constant factor, not a P1
    /// break, and `observeTakes`' own doc stays true either way.
    ///
    /// The batching is chunked because SQLite binds a bounded number of
    /// parameters per statement; every chunk keeps the same `(fan_position,
    /// id)` order, and each block's fan is built in that order, so the
    /// result is byte-identical to the per-block shape — including the
    /// empty-array entry for a block whose fan is entirely archived.
    public static func activeFans(
        _ db: Database, blockIDs: [String]
    ) throws -> [String: [Variant]] {
        var fans: [String: [Variant]] = [:]
        for blockID in blockIDs { fans[blockID] = [] }
        let unique = Array(Set(blockIDs))
        var start = 0
        while start < unique.count {
            let chunk = Array(unique[start..<min(start + Self.fanChunk, unique.count)])
            start += Self.fanChunk
            let placeholders = databaseQuestionMarks(count: chunk.count)
            let rows = try Variant.fetchAll(
                db,
                sql: """
                    SELECT * FROM variant
                     WHERE block_id IN (\(placeholders))
                       AND deleted_at IS NULL AND status = ?
                     ORDER BY fan_position, id
                    """,
                arguments: StatementArguments(chunk + [VariantStatus.active.rawValue]))
            for row in rows { fans[row.blockId]?.append(row) }
        }
        return fans
    }

    /// How many block ids ride in one `IN` list. Well under SQLite's
    /// parameter ceiling, and a note with more blocks than this simply
    /// pays a second statement.
    static let fanChunk = 400

    /// An id-keyed container liveness probe (round 2 NIT 6 — the tested
    /// home for the tutorial's seeding/reset checks; the SyncSession
    /// outbox-count class).
    public static func containerIsLive(
        _ db: Database, id: String, includingArchived: Bool = true
    ) throws -> Bool {
        let archiveClause = includingArchived ? "" : " AND archived_at IS NULL"
        return try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (SELECT 1 FROM container
                WHERE id = ? AND deleted_at IS NULL\(archiveClause))
                """,
            arguments: [id]) ?? false
    }

    /// A container's title, tolerant (nil when missing/tombstoned-title) —
    /// the view models' one-line header fetch (round 1 NIT 9).
    public static func containerTitle(_ db: Database, id: String) throws -> String? {
        try String.fetchOne(
            db, sql: "SELECT title FROM container WHERE id = ?", arguments: [id])
    }

    /// **What ONE note is called on screen** (13g batch 7, R6-3) — the
    /// display brain over the row, for the chrome that names a single note
    /// (the masthead, the pane line, the back chip, the Open strip, a star).
    /// nil where the row is gone; those callers already have their own
    /// per-kind fallback and must keep it.
    public static func noteDisplayTitle(_ db: Database, id: String) throws -> String? {
        guard let row = try Row.fetchOne(
            db, sql: "SELECT title, entry_date, created_at FROM container WHERE id = ?",
            arguments: [id])
        else { return nil }
        return DisplayTitle.note(
            title: row["title"], entryDate: row["entry_date"], createdAt: row["created_at"])
    }

    /// **What ONE POOL is called on screen** (13k K2 — her ruling: a
    /// nameless pool shows the day it was created). The `noteDisplayTitle`
    /// twin, one link shorter because a pool has no `entry_date`; nil where
    /// the row is gone, so the chrome's per-kind fallback still covers the
    /// one case it was always for.
    public static func poolDisplayTitle(_ db: Database, id: String) throws -> String? {
        guard let row = try Row.fetchOne(
            db, sql: "SELECT title, created_at FROM container WHERE id = ?",
            arguments: [id])
        else { return nil }
        return DisplayTitle.pool(title: row["title"], createdAtStamp: row["created_at"])
    }

    /// The fan-style setting ('fan_style'; default .stack — the recorded
    /// build-time call).
    public static func fanStyle(_ db: Database) throws -> FanStyle {
        let raw = try String.fetchOne(
            db, sql: "SELECT value FROM setting WHERE key = 'fan_style'")
        return raw.flatMap(FanStyle.init(rawValue:)) ?? .stack
    }

    /// BLOCK-LEVEL KINSHIP between two posts (spike record item 6 — the
    /// aligned versions/outline↔draft rows are keyed by `derived_from`
    /// lineage, NEVER by order): each of `other`'s placed blocks maps to
    /// its nearest lineage kin among `anchor`'s placed blocks (ancestors
    /// and descendants both count — a version copy's blocks DESCEND from
    /// the original's; an outline's draft blocks descend from outline
    /// blocks; direction is presentation). The block itself counts at
    /// depth 0 (two posts can point at... no — I2 forbids sharing; kept
    /// for self-comparison degenerates). Unmatched blocks are absent —
    /// the view renders them as orphan rows with blanks.
    public static func blockKinship(
        _ db: Database, anchor anchorID: String, other otherID: String,
        maxDepth: Int = 32
    ) throws -> [String: String] {
        let anchorBlocks = try String.fetchAll(
            db,
            sql: """
                SELECT block_id FROM container_block
                WHERE container_id = ? AND deleted_at IS NULL
                """,
            arguments: [anchorID])
        let anchorSet = Set(anchorBlocks)
        guard !anchorSet.isEmpty else { return [:] }
        let otherBlocks = try String.fetchAll(
            db,
            sql: """
                SELECT block_id FROM container_block
                WHERE container_id = ? AND deleted_at IS NULL
                ORDER BY position, id
                """,
            arguments: [otherID])

        var kinship: [String: String] = [:]
        for blockID in otherBlocks {
            if anchorSet.contains(blockID) {
                kinship[blockID] = blockID
                continue
            }
            // Nearest kin by lineage distance; ancestors win ties (a
            // divided block's pieces point AT their source).
            let up = try ancestors(db, of: blockID, maxDepth: maxDepth)
                .first { anchorSet.contains($0.blockID) }
            let down = try descendants(db, of: blockID, maxDepth: maxDepth)
                .first { anchorSet.contains($0.blockID) }
            switch (up, down) {
            case (let up?, let down?):
                kinship[blockID] = up.depth <= down.depth ? up.blockID : down.blockID
            case (let up?, nil):
                kinship[blockID] = up.blockID
            case (nil, let down?):
                kinship[blockID] = down.blockID
            case (nil, nil):
                break
            }
        }
        return kinship
    }
}

// MARK: - The block-TOC (Phase 11, Step A6 — AppSpec §14's 2026-07-07 delta)

extension Queries {
    /// One TOC row: the slot's identity + the stored NAME (v1_6) + the
    /// rendered take. The display handle for unnamed blocks is DERIVED at
    /// read time (`tocHandle`) — never stored anywhere (the
    /// no-denormalization rule; review focus 7).
    public struct TOCRow: Equatable, Sendable {
        public let blockID: String
        public let placementID: String
        public let name: String?
        public let variantID: String?
        public let text: String?
        public let hasFan: Bool
        public let variantLocked: Bool
        /// How many ACTIVE takes the block keeps (VX-304 — the book Index's
        /// "⑂N" badge, the Outline badge's own count). Read from the same
        /// `renderPost` slot `hasFan` comes from, so the two never disagree;
        /// a caller that builds a row by hand and names no count gets the
        /// smallest count its `hasFan` allows (2 for a fan, else 1).
        public let activeVariantCount: Int

        public init(
            blockID: String, placementID: String, name: String?,
            variantID: String?, text: String?, hasFan: Bool, variantLocked: Bool,
            activeVariantCount: Int? = nil
        ) {
            self.blockID = blockID
            self.placementID = placementID
            self.name = name
            self.variantID = variantID
            self.text = text
            self.hasFan = hasFan
            self.variantLocked = variantLocked
            self.activeVariantCount = activeVariantCount ?? (hasFan ? 2 : 1)
        }
    }

    /// The post's TOC rows in reading order — `renderPost` joined with the
    /// blocks' names. Cost ∝ the post (P1); the TOC is the natural face of
    /// §4's within-post virtualization door (rows are cheap; text upgrades
    /// on expand).
    public static func blockTOC(_ db: Database, post containerID: String) throws -> [TOCRow] {
        let slots = try renderPost(db, containerID: containerID)
        guard !slots.isEmpty else { return [] }
        let names: [String: String] = Dictionary(
            uniqueKeysWithValues: try Row.fetchAll(
                db,
                sql: """
                    SELECT b.id AS id, b.name AS name
                    FROM block b
                    JOIN container_block cb ON cb.block_id = b.id
                    WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                      AND b.deleted_at IS NULL AND b.name IS NOT NULL
                    """,
                arguments: [containerID]
            ).map { ($0["id"], $0["name"]) })
        return slots.map { slot in
            TOCRow(
                blockID: slot.blockID, placementID: slot.placementID,
                name: names[slot.blockID],
                variantID: slot.variantID, text: slot.text,
                hasFan: slot.hasFan, variantLocked: slot.variantLocked,
                activeVariantCount: slot.activeVariantCount)
        }
    }

    /// The TOC row's display handle, derived AT READ TIME (the 2026-07-07
    /// delta's letter): the explicit name where set, else the rendered
    /// take's FIRST SENTENCE via the existing BoundarySnapping sentence
    /// rules — never stored, never copied. Pure.
    public static func tocHandle(name: String?, text: String?) -> String {
        if let name, !name.isEmpty { return name }
        guard let text, !text.isEmpty else { return "(empty block)" }
        let sentenceEnd = BoundarySnapping
            .boundaries(in: text, granularity: .sentence)
            .first { $0 > 0 }
        let handle: String
        if let sentenceEnd,
           let index = BoundarySnapping.graphemeIndex(atUTF16: sentenceEnd, in: text) {
            handle = String(text[..<index])
        } else {
            handle = text
        }
        let trimmed = handle.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "(empty block)" : trimmed
    }
}

// MARK: - The block workbench (pre-13u Act 10 wave 2c, item 16 — W8-1's
// direction C: "blocks as objects", real facts per row)

extension Queries {
    /// One workbench row: the slot's identity + the FACTS her ruling asked
    /// the page to earn — takes, comments, lock, words, edited, tags. Word
    /// count and the edited day are derived AT READ TIME from the rendered
    /// take's own row (nothing stored, nothing copied); tags are the
    /// block's live applications as paths.
    public struct WorkbenchRow: Equatable, Sendable {
        public let blockID: String
        public let placementID: String
        public let name: String?
        public let variantID: String?
        public let text: String?
        /// The fan: live ACTIVE takes (the badge's count).
        public let activeVariantCount: Int
        /// Everything live regardless of status — what EXISTS (R1-1's
        /// distinction, carried so a bulk delete's ask can be honest).
        public let liveVariantCount: Int
        public let commentCount: Int
        public let variantLocked: Bool
        /// Words of the rendered take (the one `Queries.wordCount` rule).
        public let wordCount: Int
        /// The rendered take's `updated_at` — when this block's shown text
        /// last moved.
        public let editedAt: String?
        /// Live tag paths on the block, sorted.
        public let tagPaths: [String]

        public init(
            blockID: String, placementID: String, name: String?,
            variantID: String?, text: String?, activeVariantCount: Int,
            liveVariantCount: Int, commentCount: Int, variantLocked: Bool,
            wordCount: Int, editedAt: String?, tagPaths: [String]
        ) {
            self.blockID = blockID
            self.placementID = placementID
            self.name = name
            self.variantID = variantID
            self.text = text
            self.activeVariantCount = activeVariantCount
            self.liveVariantCount = liveVariantCount
            self.commentCount = commentCount
            self.variantLocked = variantLocked
            self.wordCount = wordCount
            self.editedAt = editedAt
            self.tagPaths = tagPaths
        }

        public var hasFan: Bool { activeVariantCount > 1 }
    }

    /// The post's workbench rows in reading order — `renderPost` (which
    /// already counts takes and comments through the live block row)
    /// joined with names, the rendered takes' edit stamps, and the blocks'
    /// live tags. Cost ∝ the post (P1): three bounded statements over the
    /// post's own ids, never a corpus walk.
    public static func blockWorkbench(
        _ db: Database, post containerID: String
    ) throws -> [WorkbenchRow] {
        let toc = try blockTOC(db, post: containerID)
        guard !toc.isEmpty else { return [] }
        let slots = try renderPost(db, containerID: containerID)
        let slotsByID = Dictionary(uniqueKeysWithValues: slots.map { ($0.blockID, $0) })

        // The rendered takes' edit stamps — chunked at `fanChunk` like the
        // tag lookup below (the ladder's F14: one rule for every IN list
        // over a note's ids, so a 900-block note never meets SQLite's
        // variable ceiling on one road and not the other).
        let variantIDs = toc.compactMap(\.variantID)
        var editedAt: [String: String] = [:]
        var variantStart = 0
        while variantStart < variantIDs.count {
            let chunk = Array(variantIDs[variantStart..<min(variantStart + fanChunk, variantIDs.count)])
            variantStart += fanChunk
            let placeholders = databaseQuestionMarks(count: chunk.count)
            for row in try Row.fetchAll(
                db,
                sql: "SELECT id, updated_at FROM variant WHERE id IN (\(placeholders))",
                arguments: StatementArguments(chunk)
            ) {
                editedAt[row["id"]] = row["updated_at"]
            }
        }

        // The blocks' live tags, as paths.
        var tagPaths: [String: [String]] = [:]
        let blockIDs = toc.map(\.blockID)
        var start = 0
        while start < blockIDs.count {
            let chunk = Array(blockIDs[start..<min(start + fanChunk, blockIDs.count)])
            start += fanChunk
            let placeholders = databaseQuestionMarks(count: chunk.count)
            for row in try Row.fetchAll(
                db,
                sql: """
                    SELECT bt.block_id AS block_id, t.path AS path
                    FROM block_tag bt
                    JOIN tag t ON t.id = bt.tag_id AND t.deleted_at IS NULL
                    WHERE bt.deleted_at IS NULL AND bt.block_id IN (\(placeholders))
                    ORDER BY t.path
                    """,
                arguments: StatementArguments(chunk)
            ) {
                tagPaths[row["block_id"], default: []].append(row["path"])
            }
        }

        return toc.map { row in
            let slot = slotsByID[row.blockID]
            return WorkbenchRow(
                blockID: row.blockID, placementID: row.placementID,
                name: row.name, variantID: row.variantID, text: row.text,
                activeVariantCount: slot?.activeVariantCount ?? 0,
                liveVariantCount: slot?.liveVariantCount ?? 0,
                commentCount: slot?.commentCount ?? 0,
                variantLocked: row.variantLocked,
                wordCount: wordCount(row.text ?? ""),
                editedAt: row.variantID.flatMap { editedAt[$0] },
                tagPaths: tagPaths[row.blockID] ?? [])
        }
    }
}

extension AppDatabase {
    /// The workbench's standing observation (wave 2c) — the TOC cadence,
    /// widened with the facts.
    public func observeBlockWorkbench(
        _ containerID: String
    ) -> AsyncValueObservation<[Queries.WorkbenchRow]> {
        observe { try Queries.blockWorkbench($0, post: containerID) }
    }
}

extension AppDatabase {
    /// The takes board's standing observation (Phase 11, A3). One post's
    /// combined projection — bounded by construction (cost ∝ this post).
    public func observeTakes(
        _ containerID: String
    ) -> AsyncValueObservation<Queries.TakesProjection> {
        observe { try Queries.takesProjection($0, post: containerID) }
    }

    /// The block-TOC's standing observation (Phase 11, A6).
    public func observeBlockTOC(
        _ containerID: String
    ) -> AsyncValueObservation<[Queries.TOCRow]> {
        observe { try Queries.blockTOC($0, post: containerID) }
    }
}
