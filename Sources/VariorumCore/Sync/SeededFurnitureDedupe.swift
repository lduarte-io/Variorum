import Foundation
import GRDB

/// **The seeded-furniture pairwise fold** (17y B-DEDUPE, R-17y-5 as trimmed
/// by R-17y-8; the binding design is `notes/plans/17y-bdedupe-design-memo.md`)
/// — the SyncSpec §7 class applied to the seeded objects the pristine-copy
/// dedupe does not judge: the FIELD GUIDE book, the three seeded GATHERINGS
/// (classics · starred notes · Quicknotes), the seeded QUICKNOTE and twin
/// notes, and the tutorial SCRAPS POOL. Two devices each correctly decided
/// "none exists yet", both seeded, and the pair met under sync.
///
/// ── THE RULE (her R-17y-5 letter, uniform over every grain) ─────────────
/// **Fold only when the copies read as the seed's own; HER ENGAGEMENT
/// (rename, edit, re-rule, re-tag, a shelf move, a star change, outflow,
/// the dial, finish/seal/own/archive) always keeps both.** The fold set is
/// the UNENGAGED seed-own copies — and, for the content-bearing grains
/// (book · note · pool), only copies CONTENT-IDENTICAL to each other
/// (ids and positions aside) fold together: keeping the smaller id then
/// loses NOTHING by construction. An engaged copy never enters a fold set
/// and is never consulted further; two unengaged copies whose content
/// differs (a stale-content seed beside a fresh one) BOTH SURVIVE — the
/// visible, safe direction (the memo's PROVISIONAL (ii); the close
/// ritual's re-seed of her real store bounds the stale case). This is
/// deliberately NARROWER than the Sherlock pass's pristine matrix: that
/// pass's manifest road does not fit the guide's seeded richness (fans, a
/// callout, the twin, per-build content — the memo §1), and pairwise
/// identity needs no manifest at all.
///
/// ── DISCIPLINE (SyncSpec §7's standing rules, all of them) ──────────────
/// Deterministic on every device (synced rows only; smallest id keeps);
/// idempotent (a second pass finds one live copy per class and returns 0);
/// repairs run inside the apply transaction with EXPLICIT outbox rows;
/// PULL-ONLY occasions with a one-shot deferral marker (the R2-3 idiom);
/// stragglers defer the whole pass — never guess; nil facts = INERT (the
/// `keyProvider` pattern — an engine nobody wired facts into cannot
/// misidentify anything). A device without facts converges by receiving
/// the outcome rows.
public struct SeededFurnitureDedupeFacts: Sendable {
    /// One seeded gathering's signature. A gathering holds nothing, so its
    /// identity is its RULE SHAPE — resolved by tag PATH, never id (the
    /// `tag.path` fold re-points applications only, so two devices' copies
    /// name DIFFERENT ids for one path and the loser's rule can name a dead
    /// twin) — or its reserved NAME under `BookNaming`'s key.
    public struct Gathering: Sendable {
        public enum RuleShape: Sendable, Equatable {
            /// `{"star":true}` — starred notes; no tag id anywhere.
            case star
            /// A single tag term whose tag's PATH is the declared one
            /// (classics · quicknote), whatever id carries it.
            case tagPath(String)
        }
        public var name: String
        public var rule: RuleShape
        /// The designation `setting` key that must converge to the keeper
        /// when it names a retired loser (`quicknote_book` — §20's letter:
        /// the repair RE-POINTS, it never mints or revives).
        public var designationKey: String?
        /// The seed's own starred flag (Quicknotes ships STARRED,
        /// R-13id-5; the others unstarred) — the flag OFF the seed's value
        /// is engagement.
        public var bornStarred: Bool

        public init(
            name: String, rule: RuleShape,
            designationKey: String? = nil, bornStarred: Bool = false
        ) {
            self.name = name
            self.rule = rule
            self.designationKey = designationKey
            self.bornStarred = bornStarred
        }
    }

    /// One reserved-titled seeded NOTE (the quicknote; the guide's twin
    /// when it lives bookless) or POOL ("tutorial scraps").
    public struct ReservedContainer: Sendable {
        public var title: String
        /// 'post' or 'pool' — the container kind the seed mints.
        public var kind: String
        /// Tag paths the SEED authors on it — an application of one is the
        /// seed's hands, never hers (the `seedTagPaths` precedent).
        public var seedTagPaths: [String]

        public init(title: String, kind: String, seedTagPaths: [String] = []) {
            self.title = title
            self.kind = kind
            self.seedTagPaths = seedTagPaths
        }
    }

    /// The guide book's reserved name — EXACT, case-sensitive (the
    /// seeder's own `discover` rule; a rename is engagement). Nil = this
    /// platform seeds no guide (the phone's pocket guide is its own
    /// MOBILE PARITY row, never judged here).
    public var guideBookName: String?
    /// The tag path the guide's seed applies to every member note.
    public var guideTagPath: String?
    public var gatherings: [Gathering]
    public var containers: [ReservedContainer]
    /// The recipe for every rendered-text hash (`BridgeHash.body` at the
    /// wiring site) — a drift fails SAFE to both-survive.
    public var hash: @Sendable (String) -> String

    public init(
        guideBookName: String? = nil,
        guideTagPath: String? = nil,
        gatherings: [Gathering] = [],
        containers: [ReservedContainer] = [],
        hash: @escaping @Sendable (String) -> String
    ) {
        self.guideBookName = guideBookName
        self.guideTagPath = guideTagPath
        self.gatherings = gatherings
        self.containers = containers
        self.hash = hash
    }

    var isEmpty: Bool {
        guideBookName == nil && gatherings.isEmpty && containers.isEmpty
    }
}

extension SyncEngine {
    static let furnitureDedupePendingKey = "furniture_dedupe_pending"

    /// Whether this batch is one of the pass's occasions. PULL-ONLY (the
    /// R2-1 letter: only a pull can land the rows an in-flight copy is
    /// missing); three occasions — a `reading` row applied (book and
    /// gathering grains), the one-shot marker a deferral left, or a
    /// `container` row applied wearing a reserved title (note and pool
    /// grains; one indexed lookup over the batch's ids).
    func furnitureDedupeOccasion(_ db: Database, touched: TouchedRows) throws -> Bool {
        guard touched.isPullBatch, let facts = furnitureFacts, !facts.isEmpty
        else { return false }
        if !touched.readingIDs.isEmpty { return true }
        if try Bool.fetchOne(
            db, sql: "SELECT EXISTS (SELECT 1 FROM sync_state WHERE key = ?)",
            arguments: [Self.furnitureDedupePendingKey]) ?? false { return true }
        guard !touched.containerIDs.isEmpty else { return false }
        let reserved = facts.containers.map(\.title)
        guard !reserved.isEmpty else { return false }
        return try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (SELECT 1 FROM container
                               WHERE id IN (SELECT value FROM json_each(?))
                                 AND title IN (SELECT value FROM json_each(?)))
                """,
            arguments: [jsonArray(touched.containerIDs), jsonArray(Set(reserved))]) ?? false
    }

    /// The pass. The one-shot marker is SPENT FIRST (the R2-3 lesson — a
    /// pass that runs consumes it before deciding anything); any grain's
    /// straggler re-arms it and defers the WHOLE pass, so every device
    /// decides on the same complete picture at a later pull.
    func dedupeSeededFurniture(_ db: Database, touched: TouchedRows) throws -> Int {
        guard let facts = furnitureFacts, !facts.isEmpty else { return 0 }
        try db.execute(
            sql: "DELETE FROM sync_state WHERE key = ?",
            arguments: [Self.furnitureDedupePendingKey])

        var repairs = 0
        var deferred = false

        // ── the GATHERING grain ──────────────────────────────────────────
        for gathering in facts.gatherings {
            switch try foldGatheringCopies(db, gathering: gathering) {
            case .folded(let count): repairs += count
            case .deferred: deferred = true
            case .nothing: break
            }
        }

        // ── the BOOK grain (the field guide) ─────────────────────────────
        if let guideName = facts.guideBookName {
            switch try foldGuideCopies(
                db, name: guideName, tagPath: facts.guideTagPath,
                hash: facts.hash, touched: touched) {
            case .folded(let count): repairs += count
            case .deferred: deferred = true
            case .nothing: break
            }
        }

        // ── the NOTE and POOL grains ─────────────────────────────────────
        for reserved in facts.containers {
            switch try foldReservedContainers(
                db, reserved: reserved, hash: facts.hash, touched: touched) {
            case .folded(let count): repairs += count
            case .deferred: deferred = true
            case .nothing: break
            }
        }

        if deferred {
            try db.execute(
                sql: "INSERT OR REPLACE INTO sync_state (key, value) VALUES (?, '1')",
                arguments: [Self.furnitureDedupePendingKey])
        }
        return repairs
    }

    enum FurnitureFoldOutcome {
        case folded(Int)
        case deferred
        case nothing
    }

    // MARK: - The gathering grain

    /// Candidates per WING: live gatherings matching the seed SIGNATURE
    /// (rule-by-path, or the reserved name under `BookNaming.sameName` —
    /// the adoption predicates' own grammar). The fold set is the
    /// UNENGAGED seed-own copies; ≥ 2 fold to the smallest id. The loser
    /// tombstones with nothing to move (a gathering holds nothing; its
    /// dismissal-record rows, where any exist, stay dead history). The
    /// KEEPER's rule re-points to the live tag when it names a dead
    /// path-twin, and the designation re-points to the keeper when it
    /// names a loser.
    private func foldGatheringCopies(
        _ db: Database, gathering: SeededFurnitureDedupeFacts.Gathering
    ) throws -> FurnitureFoldOutcome {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT id, wing_id, name, query_spec, shelf_id, starred, owned,
                       locked, sealed_at, archived_at, hide_owned, intake_seating,
                       auto_tag_ids, grouping_tag_id, word_target, max_posts
                FROM reading
                WHERE kind = 'gathering' AND deleted_at IS NULL
                """)
        var byWing: [String: [Row]] = [:]
        for row in rows where try signatureMatches(db, row: row, gathering: gathering) {
            byWing[row["wing_id"] as String? ?? "", default: []].append(row)
        }

        var repairs = 0
        let stamp = nowStamp()
        for (_, candidates) in byWing {
            var seedOwn: [Row] = []
            for candidate in candidates {
                switch try gatheringIsSeedsOwn(db, row: candidate, gathering: gathering) {
                case true: seedOwn.append(candidate)
                case false: continue
                case nil: return .deferred  // a `shelf` record still in flight
                }
            }
            guard seedOwn.count > 1 else { continue }
            let sorted = seedOwn.sorted { ($0["id"] as String) < ($1["id"] as String) }
            let keeperID: String = sorted[0]["id"]
            for loser in sorted.dropFirst() {
                let loserID: String = loser["id"]
                try db.execute(
                    sql: "UPDATE reading SET deleted_at = ?, updated_at = ? WHERE id = ?",
                    arguments: [stamp, stamp, loserID])
                try enqueueExplicitly(db, table: "reading", rowID: loserID)
                repairs += 1
                // The §7 belt (round-1 MINOR-6, SPECULATIVE reachability):
                // no ops road mints live children under a gathering today,
                // but if any ever exist the muted cascade must still push.
                repairs += try enqueueSuppressedCascadeVictims(
                    db, parent: ("reading", loserID, stamp), arrivingDead: [:])
                // §20's letter: the designation only ever RE-POINTS —
                // loser → keeper; anything else it names is left alone.
                if let key = gathering.designationKey,
                   try String.fetchOne(
                    db, sql: "SELECT value FROM setting WHERE key = ?",
                    arguments: [key]) == loserID {
                    try db.execute(
                        sql: "INSERT OR REPLACE INTO setting (key, value, sync_version) "
                            + "VALUES (?, ?, COALESCE((SELECT sync_version FROM setting WHERE key = ?), 0))",
                        arguments: [key, keeperID, key])
                    try enqueueExplicitly(db, table: "setting", rowID: key)
                    repairs += 1
                }
            }
            repairs += try repointKeeperRule(db, keeperID: keeperID, gathering: gathering)
        }
        return repairs > 0 ? .folded(repairs) : .nothing
    }

    /// The signature: the rule resolves to the declared shape BY PATH
    /// (dead tag rows readable — the whole point), or the name is the
    /// reserved one under the E13 key. A STRAGGLING rule reading (its tag
    /// row has never arrived) counts as a candidate so the grain can
    /// DEFER on it rather than guess (the round-1 MAJOR-3).
    private func signatureMatches(
        _ db: Database, row: Row, gathering: SeededFurnitureDedupeFacts.Gathering
    ) throws -> Bool {
        if BookNaming.sameName(row["name"] as String? ?? "", gathering.name) { return true }
        switch try ruleReading(db, spec: row["query_spec"], shape: gathering.rule) {
        case .matches, .straggling: return true
        case .differs: return false
        }
    }

    enum RuleReading: Equatable {
        /// The rule IS the declared shape; carries the tag id it names
        /// ("" for `.star`).
        case matches(String)
        /// A readable rule of a different shape, or a PRESENT tag row of a
        /// different path — definitively not the seed's.
        case differs
        /// The rule names a tag row this store has NEVER SEEN (absent —
        /// distinct from dead, which stays readable): the evidence is in
        /// flight; defer, never guess (the round-1 MAJOR-3 — the old
        /// reading returned `differs` here and the pair stood un-folded
        /// with no marker until an unrelated book happened to land).
        case straggling
    }

    /// Resolves a stored rule against the declared shape. A malformed or
    /// absent rule DIFFERS (fails closed, the grammar's own rule).
    private func ruleReading(
        _ db: Database, spec: String?, shape: SeededFurnitureDedupeFacts.Gathering.RuleShape
    ) throws -> RuleReading {
        guard case .rule(let term) = RuleGrammar.read(spec) else { return .differs }
        switch (shape, term) {
        case (.star, .star):
            return .matches("")
        case (.tagPath(let path), .tag(let tagID)):
            guard let tagPath = try String.fetchOne(
                db, sql: "SELECT path FROM tag WHERE id = ?", arguments: [tagID])
            else { return .straggling }
            return tagPath == path ? .matches(tagID) : .differs
        default:
            return .differs
        }
    }

    /// Seed's-own = the signature holds by RULE SHAPE (not merely name),
    /// the name is still the reserved one, and no engagement flag is set.
    /// Every leg errs toward ENGAGED, which keeps copies. Returns nil —
    /// STRAGGLING — when the shelf pointer names a row this store has
    /// never seen (her shelf may be in flight; a DEAD `shelf` record is the
    /// ordinary dangling-reads-unshelved state and stays the seed's).
    private func gatheringIsSeedsOwn(
        _ db: Database, row: Row, gathering: SeededFurnitureDedupeFacts.Gathering
    ) throws -> Bool? {
        switch try ruleReading(db, spec: row["query_spec"], shape: gathering.rule) {
        case .matches: break
        case .differs: return false
        case .straggling: return nil  // the tag row is in flight — defer
        }
        guard BookNaming.sameName(row["name"] as String? ?? "", gathering.name) else { return false }
        if (row["owned"] as Int? ?? 0) != 0 { return false }
        if (row["locked"] as Int? ?? 0) != 0 { return false }
        if (row["sealed_at"] as String?) != nil { return false }
        if (row["archived_at"] as String?) != nil { return false }
        if (row["hide_owned"] as Int?) != nil { return false }
        if (row["intake_seating"] as String?) != nil { return false }
        if let outflow = row["auto_tag_ids"] as String?, !outflow.isEmpty, outflow != "[]" {
            return false
        }
        if (row["grouping_tag_id"] as String?) != nil { return false }
        if (row["word_target"] as Int?) != nil { return false }
        if (row["max_posts"] as Int?) != nil { return false }
        if (row["starred"] as Int? ?? 0) != (gathering.bornStarred ? 1 : 0) { return false }
        // The shelf: nil/dangling-dead (unshelved — starred notes,
        // Quicknotes) or a `role='welcome'` shelf (classics ships ON
        // Welcome) are the seed's states; her own shelf is engagement; a
        // pointer to a NEVER-SEEN row is a straggler (defer).
        if let shelfID = row["shelf_id"] as String? {
            guard let shelf = try Row.fetchOne(
                db, sql: "SELECT role, deleted_at FROM shelf WHERE id = ?",
                arguments: [shelfID])
            else { return nil }
            if (shelf["deleted_at"] as String?) == nil {
                let role = shelf["role"] as String?
                if role != "welcome" { return false }
            }
        }
        return true
    }

    /// The keeper's rule re-point: when its single tag term names a DEAD
    /// row of the declared path while a LIVE row of that path stands (the
    /// `tag.path` fold's residue on rules), rewrite the rule to the live
    /// id — an explicit outbox row, SyncSpec §7's standing rule. `.star`
    /// rules carry no id and need nothing.
    private func repointKeeperRule(
        _ db: Database, keeperID: String, gathering: SeededFurnitureDedupeFacts.Gathering
    ) throws -> Int {
        guard case .tagPath(let path) = gathering.rule else { return 0 }
        guard let spec = try String.fetchOne(
            db, sql: "SELECT query_spec FROM reading WHERE id = ?", arguments: [keeperID]),
            case .rule(.tag(let namedID)) = RuleGrammar.read(spec)
        else { return 0 }
        let named = try Row.fetchOne(
            db, sql: "SELECT path, deleted_at FROM tag WHERE id = ?", arguments: [namedID])
        guard let named, (named["path"] as String?) == path,
              (named["deleted_at"] as String?) != nil
        else { return 0 }
        guard let liveID = try String.fetchOne(
            db,
            sql: """
                SELECT t.id FROM tag t
                JOIN reading r ON r.id = ?
                WHERE t.path = ? AND t.deleted_at IS NULL AND t.wing_id = r.wing_id
                ORDER BY t.id LIMIT 1
                """,
            arguments: [keeperID, path])
        else { return 0 }
        let stamp = nowStamp()
        try db.execute(
            sql: "UPDATE reading SET query_spec = ?, updated_at = ? WHERE id = ?",
            arguments: [try RuleGrammar.encode(.tag(liveID)), stamp, keeperID])
        try enqueueExplicitly(db, table: "reading", rowID: keeperID)
        return 1
    }

    // MARK: - The book grain (the field guide)

    /// Live readings wearing the EXACT reserved name, per wing. The fold
    /// set is the unengaged copies grouped by CONTENT SIGNATURE; each
    /// identical class of ≥ 2 folds to its smallest id through the
    /// family-complete retirement (`retireSampleCopy` — ordinary
    /// tombstones, Trash-listed, explicit outbox rows). A straggling copy
    /// (any member or block still in flight) defers the whole pass.
    private func foldGuideCopies(
        _ db: Database, name: String, tagPath: String?,
        hash: @Sendable (String) -> String,
        touched: TouchedRows
    ) throws -> FurnitureFoldOutcome {
        let copies = try Row.fetchAll(
            db,
            sql: """
                SELECT id, wing_id FROM reading
                WHERE name = ? AND kind = 'book' AND deleted_at IS NULL
                ORDER BY id
                """,
            arguments: [name])
        guard copies.count > 1 else { return .nothing }
        // The F2 quiescence arm (the sample pass's own letter): a copy
        // whose reading row arrived THIS batch is indeterminate — its
        // engagement rows (comments, tags, references) sort after the
        // membership chunk in the push order and can still be in flight,
        // so judging now could read an edited copy as unengaged and fold
        // it. Defer the whole grain; the marker re-fires at the next pull,
        // the empty window included.
        if copies.contains(where: { touched.readingIDs.contains($0["id"] as String) }) {
            return .deferred
        }

        var byWing: [String: [String]] = [:]
        for copy in copies {
            byWing[copy["wing_id"] as String? ?? "", default: []].append(copy["id"])
        }
        var repairs = 0
        for (_, ids) in byWing where ids.count > 1 {
            var classes: [String: [String]] = [:]
            for id in ids {
                switch try SeededFurnitureClassifier.guideVerdict(
                    db, copyID: id, tagPath: tagPath, hash: hash) {
                case .engaged:
                    continue
                case .straggling:
                    return .deferred
                case .foldable(let value):
                    classes[value, default: []].append(id)
                }
            }
            for (_, twins) in classes where twins.count > 1 {
                for loser in twins.sorted().dropFirst() {
                    repairs += try retireSampleCopy(
                        db, copyID: loser, arrivingDead: touched.arrivingDeadIDs)
                }
            }
        }
        return repairs > 0 ? .folded(repairs) : .nothing
    }


}

/// **The furniture classifier, ONE public body** (the `SampleCopyClassifier`
/// precedent, applied at the B-DEDUPE ladder's round 1): the engine's pass
/// and the Mac's REAL-SEED drift guard invoke the SAME functions, so the
/// shipped seed's foldability is pinned against the real classifier — never
/// a synthetic mirror of it.
public enum SeededFurnitureClassifier {
    public enum Verdict: Equatable, Sendable {
        case engaged
        case straggling
        case foldable(signature: String)
    }

    /// One guide copy's verdict: ENGAGED on any sign of her hands (every
    /// leg errs this way — engagement keeps copies), STRAGGLING when any
    /// row is still in flight, else the copy's content signature —
    /// chapters in order, members in book order with their chapter
    /// assignment, and every member note's own signature. SEED-AUTHORED
    /// state (the ladder's BLOCKER-1) — the book's word target, a sealed
    /// lesson's lock, the seed's block comments — rides the IDENTITY, not
    /// engagement: identical on both copies it folds; any act of hers
    /// makes the pair differ and both survive, the ruled letter exactly.
    public static func guideVerdict(
        _ db: Database, copyID: String, tagPath: String?,
        hash: @Sendable (String) -> String
    ) throws -> Verdict {
        guard let book = try Row.fetchOne(
            db,
            sql: """
                SELECT locked, sealed_at, owned, archived_at, word_target, max_posts,
                       grouping_tag_id, sort_field, sort_dir, shelf_id, hide_owned,
                       intake_seating, auto_tag_ids, query_spec
                FROM reading WHERE id = ?
                """,
            arguments: [copyID])
        else { return .straggling }
        if (book["locked"] as Int? ?? 0) != 0 { return .engaged }
        if (book["sealed_at"] as String?) != nil { return .engaged }
        if (book["owned"] as Int? ?? 0) != 0 { return .engaged }
        if (book["archived_at"] as String?) != nil { return .engaged }
        // word_target is SEED-AUTHORED (the mint ships 4000) — identity,
        // not engagement (BLOCKER-1): a target she changes differs.
        if (book["max_posts"] as Int?) != nil { return .engaged }
        if (book["grouping_tag_id"] as String?) != nil { return .engaged }
        if (book["query_spec"] as String?) != nil { return .engaged }
        if (book["sort_field"] as String?) != SortField.manual.rawValue { return .engaged }
        if (book["sort_dir"] as String?) != SortDirection.asc.rawValue { return .engaged }
        if (book["hide_owned"] as Int?) != nil { return .engaged }
        if (book["intake_seating"] as String?) != nil { return .engaged }
        if let outflow = book["auto_tag_ids"] as String?, !outflow.isEmpty, outflow != "[]" {
            return .engaged
        }
        if let shelfID = book["shelf_id"] as String? {
            guard let shelf = try Row.fetchOne(
                db, sql: "SELECT role, deleted_at FROM shelf WHERE id = ?",
                arguments: [shelfID])
            else { return .straggling }  // her shelf may be in flight
            if (shelf["deleted_at"] as String?) == nil,
               (shelf["role"] as String?) != "welcome" {
                return .engaged
            }
        }

        let chapters = try Row.fetchAll(
            db,
            sql: """
                SELECT id, name FROM reading_section
                WHERE reading_id = ? AND deleted_at IS NULL ORDER BY position, id
                """,
            arguments: [copyID])
        var chapterIndex: [String: Int] = [:]
        for (index, chapter) in chapters.enumerated() {
            chapterIndex[chapter["id"] as String] = index
        }
        let memberships = try Row.fetchAll(
            db,
            sql: """
                SELECT post_id, section_id, status, deleted_at FROM reading_post
                WHERE reading_id = ? ORDER BY position, id
                """,
            arguments: [copyID])
        guard !memberships.isEmpty else { return .straggling }
        // A dead membership or a waiting arrival on a seed copy is an act
        // or an event the seed never produces — engagement's side.
        if memberships.contains(where: {
            ($0["deleted_at"] as String?) != nil || ($0["status"] as String?) != "member"
        }) { return .engaged }

        var parts: [String] = ["wt:\(book["word_target"] as Int? ?? -1)"]
        parts += chapters.map { $0["name"] as String }
        for membership in memberships {
            let postID: String = membership["post_id"]
            let section = membership["section_id"] as String?
            let index = section.flatMap { chapterIndex[$0] }
            guard let index else { return .engaged }  // unfiled/foreign chapter: hers
            switch try noteVerdict(
                db, postID: postID, within: copyID,
                seedTagPaths: [tagPath].compactMap { $0 }, hash: hash) {
            case .engaged: return .engaged
            case .straggling: return .straggling
            case .foldable(let value):
                parts.append("\(index)|\(value)")
            }
        }
        return .foldable(signature: hash(parts.joined(separator: "\u{1F}")))
    }
}

extension SyncEngine {
    // MARK: - The note and pool grains

    /// Live containers of the declared kind wearing the reserved title,
    /// per wing — the NOTE grain scoped to BOOKLESS posts (a twin living
    /// inside its guide rides the book grain instead). Unengaged copies
    /// group by content signature; identical classes of ≥ 2 fold to the
    /// smallest id (the container's cascade takes the family, explicit
    /// outbox rows throughout).
    private func foldReservedContainers(
        _ db: Database, reserved: SeededFurnitureDedupeFacts.ReservedContainer,
        hash: @Sendable (String) -> String,
        touched: TouchedRows
    ) throws -> FurnitureFoldOutcome {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT id, wing_id FROM container
                WHERE kind = ? AND title = ? AND deleted_at IS NULL
                ORDER BY id
                """,
            arguments: [reserved.kind, reserved.title])
        guard rows.count > 1 else { return .nothing }
        // The F2 quiescence arm, container grain: a copy arriving THIS
        // batch may have its comment/tag/reference chunk still in flight.
        if rows.contains(where: { touched.containerIDs.contains($0["id"] as String) }) {
            return .deferred
        }

        var byWing: [String: [String]] = [:]
        for row in rows {
            let id: String = row["id"]
            if reserved.kind == "post" {
                let membered = try Bool.fetchOne(
                    db,
                    sql: """
                        SELECT EXISTS (SELECT 1 FROM reading_post
                                       WHERE post_id = ? AND deleted_at IS NULL)
                        """,
                    arguments: [id]) ?? false
                if membered { continue }
            }
            byWing[row["wing_id"] as String? ?? "", default: []].append(id)
        }

        var repairs = 0
        let stamp = nowStamp()
        for (_, ids) in byWing where ids.count > 1 {
            var classes: [String: [String]] = [:]
            for id in ids {
                switch try SeededFurnitureClassifier.noteVerdict(
                    db, postID: id, within: nil,
                    seedTagPaths: reserved.seedTagPaths, hash: hash) {
                case .engaged: continue
                case .straggling: return .deferred
                case .foldable(let value):
                    classes[value, default: []].append(id)
                }
            }
            for (_, twins) in classes where twins.count > 1 {
                for loser in twins.sorted().dropFirst() {
                    try db.execute(
                        sql: "UPDATE container SET deleted_at = ?, updated_at = ? WHERE id = ?",
                        arguments: [stamp, stamp, loser])
                    try enqueueExplicitly(db, table: "container", rowID: loser)
                    repairs += 1
                    repairs += try enqueueSuppressedCascadeVictims(
                        db, parent: ("container", loser, stamp),
                        arrivingDead: touched.arrivingDeadIDs)
                }
            }
        }
        return repairs > 0 ? .folded(repairs) : .nothing
    }

}

extension SeededFurnitureClassifier {
    /// One note's (or pool's) verdict. ENGAGED: a manual savepoint, a live
    /// reference, a tag beyond the declared seed paths, a block tag,
    /// floating notes, an entry date, an archive — or, for a guide member,
    /// a live membership in any OTHER reading. IDENTITY (BLOCKER-1's move —
    /// seed-authored state the real mint ships): the note's LOCK (the
    /// sealed lesson) and its live COMMENTS as ordered (block-ordinal,
    /// text) tuples — created_at deliberately excluded, each device's seed
    /// stamps its own clock. STRAGGLING: a placement without its block's
    /// variants, or no placements at all. Else the content signature:
    /// the rendered text's hash plus a structural skeleton — blocks in
    /// placement order; per block the active take texts in fan order, the
    /// archived-take count, any locked take, the block name, the
    /// presentation, and the CHOSEN take's index (nil or dead chosen
    /// NORMALIZES TO -1 — deliberately NOT the default's index; the
    /// direction is conservative only, recorded at the round-1 MINOR-5).
    public static func noteVerdict(
        _ db: Database, postID: String, within readingID: String?,
        seedTagPaths: [String], hash: @Sendable (String) -> String
    ) throws -> Verdict {
        guard let post = try Row.fetchOne(
            db,
            sql: """
                SELECT title, locked, archived_at, entry_date, floating_notes
                FROM container WHERE id = ? AND deleted_at IS NULL
                """,
            arguments: [postID])
        else { return .straggling }
        if (post["archived_at"] as String?) != nil { return .engaged }
        if (post["entry_date"] as String?) != nil { return .engaged }
        if let notes = post["floating_notes"] as String?, !notes.isEmpty { return .engaged }

        if let readingID {
            let elsewhere = try Bool.fetchOne(
                db,
                sql: """
                    SELECT EXISTS (SELECT 1 FROM reading_post
                                   WHERE post_id = ? AND reading_id <> ? AND deleted_at IS NULL)
                    """,
                arguments: [postID, readingID]) ?? false
            if elsewhere { return .engaged }
        }

        let seedPathsJSON = jsonArrayLiteral(seedTagPaths)
        let engagement = try Bool.fetchOne(
            db,
            sql: """
                SELECT EXISTS (SELECT 1 FROM post_tag pt
                               JOIN tag t ON t.id = pt.tag_id
                               WHERE pt.post_id = ?1 AND pt.deleted_at IS NULL
                                 AND t.path NOT IN (SELECT value FROM json_each(?2)))
                    OR EXISTS (SELECT 1 FROM block_tag bt
                               JOIN container_block cb ON cb.block_id = bt.block_id
                               WHERE cb.container_id = ?1 AND cb.deleted_at IS NULL
                                 AND bt.deleted_at IS NULL)
                    OR EXISTS (SELECT 1 FROM commit_point cp
                               JOIN variant v ON v.id = cp.variant_id
                               JOIN container_block cb ON cb.block_id = v.block_id
                               WHERE cb.container_id = ?1 AND cb.deleted_at IS NULL
                                 AND cp.kind = 'manual')
                    OR EXISTS (SELECT 1 FROM reference
                               WHERE container_id = ?1 AND deleted_at IS NULL)
                """,
            arguments: [postID, seedPathsJSON]) ?? false
        if engagement { return .engaged }

        let placements = try Row.fetchAll(
            db,
            sql: """
                SELECT block_id, chosen_variant_id FROM container_block
                WHERE container_id = ? AND deleted_at IS NULL
                ORDER BY position, id
                """,
            arguments: [postID])
        guard !placements.isEmpty else { return .straggling }

        var parts: [String] = [post["title"] as String? ?? "",
                               "lk:\(post["locked"] as Int? ?? 0)"]
        // The note's live comments, as (block-ordinal, text) tuples in
        // placement order — identity, not engagement (BLOCKER-1): the
        // seed's own comment matches across copies; hers differ.
        let comments = try Row.fetchAll(
            db,
            sql: """
                SELECT cb.position AS pos, cb.id AS pid, bc.text AS text
                FROM block_comment bc
                JOIN container_block cb ON cb.block_id = bc.block_id
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                  AND bc.deleted_at IS NULL
                ORDER BY cb.position, cb.id, bc.text
                """,
            arguments: [postID])
        var commentOrdinal: [String: Int] = [:]
        parts += comments.map { row -> String in
            let key = (row["pos"] as String? ?? "") + "|" + (row["pid"] as String? ?? "")
            let ordinal = commentOrdinal.count
            if commentOrdinal[key] == nil { commentOrdinal[key] = ordinal }
            return "c\(commentOrdinal[key]!):\(hash(row["text"] as String? ?? ""))"
        }
        for placement in placements {
            let blockID: String = placement["block_id"]
            guard let block = try Row.fetchOne(
                db,
                sql: "SELECT name, presentation FROM block WHERE id = ? AND deleted_at IS NULL",
                arguments: [blockID])
            else { return .straggling }
            let takes = try Row.fetchAll(
                db,
                sql: """
                    SELECT id, working_text, status, locked FROM variant
                    WHERE block_id = ? AND deleted_at IS NULL
                    ORDER BY fan_position, id
                    """,
                arguments: [blockID])
            guard !takes.isEmpty else { return .straggling }
            if takes.contains(where: { ($0["locked"] as Int? ?? 0) != 0 }) { return .engaged }
            let active = takes.filter { ($0["status"] as String?) == "active" }
            let archivedCount = takes.count - active.count
            let chosen = placement["chosen_variant_id"] as String?
            let chosenIndex = chosen.flatMap { id in
                active.firstIndex { ($0["id"] as String) == id }
            } ?? -1
            var blockParts: [String] = [
                block["name"] as String? ?? "",
                block["presentation"] as String? ?? "",
                "\(archivedCount)", "\(chosenIndex)",
            ]
            blockParts += active.map { hash($0["working_text"] as String? ?? "") }
            parts.append(blockParts.joined(separator: "\u{1E}"))
        }
        let rendered = try Queries.renderedText(db, containerID: postID)
        parts.append(hash(rendered))
        return .foldable(signature: hash(parts.joined(separator: "\u{1F}")))
    }

    /// A JSON array literal for `json_each` binding (the
    /// `SampleCopyClassifier` door's own precedent).
    private static func jsonArrayLiteral(_ values: [String]) -> String {
        let data = try? JSONSerialization.data(withJSONObject: values)
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }
}
