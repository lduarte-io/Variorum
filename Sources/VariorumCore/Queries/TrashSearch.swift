import Foundation
import GRDB

// **A SEARCH INSIDE THE TRASH** (VX-93 — the vx-980 run's batch 3; her rulings
// R-980-9 · R-980-10 · R-980-11 · R-980-12, verbatim in
// `notes/plans/fixes/vx-980-her-rulings.md`). Her words at the VX-83 sitting:
// *"searching stuff that wasn't saved and was purposefully deleted is a
// different issue. it might be better to just add a search to trash later than
// add trash to the main search."*
//
// So the finder is untouched — the index keeps dropping tombstoned docs, no
// visibility fact, no composer fence — and this is a NARROWING of the Trash's
// own listing: `Queries.trash` answers exactly as it always does (its wing
// fence, its 30-day window, its purge-intent fence, its kinds and its order),
// and this read keeps the rows whose name or deleted text holds every typed
// word (`TrashTextMatch`). There is no second listing rule to drift.
extension Queries {
    /// The narrowed listing and the passage lines it owes.
    public struct TrashSearchAnswer: Equatable, Sendable {
        /// The rows that match, in the listing's own order, at most `limit`.
        public let items: [TrashItem]
        /// Row id → its ONE passage line (R-980-11) — present only on a row
        /// matched by text it does not already show.
        public let passages: [String: String]

        public init(items: [TrashItem], passages: [String: String] = [:]) {
            self.items = items
            self.passages = passages
        }
    }

    /// **What a row shows, absent a face's own rule**: a named row its name,
    /// a text row (block, take, original) its whole shown take. The Mac's face
    /// passes its own (`title ?? TrayRowPreview.line(text)` — the first line).
    public static func trashRowDefaultShown(_ item: TrashItem) -> String {
        item.title ?? item.text ?? ""
    }

    /// **The Trash, narrowed to the rows holding every word** (VX-93).
    ///
    /// The listing is `trash(…)` itself — the SAME arguments (kinds, order,
    /// wing) and no limit, so a search reaches this wing's whole Trash rather
    /// than its newest 500 — then narrowed in that order, chunk by chunk,
    /// stopping once `limit` rows match. Each chunk's deleted texts are read
    /// by `trashRowTexts`, driven from the chunk's own ids. `words` empty is no
    /// search: the listing as it stands, `limit` applied, no passages.
    ///
    /// `shows` is what the face shows of a row (R-980-11: a passage only
    /// under a row matched by text it does not already show).
    ///
    /// **Cost (P1):** the listing's own (unchanged — its arms scan their store
    /// tables by `deleted_at`, as they always have) plus, per row examined,
    /// its own family's texts by index seeks — ∝ this wing's Trash, never the
    /// living corpus. Pure Swift matching over those texts. Read on a reader
    /// (the observation below), off the main thread (P2).
    public static func trashSearch(
        _ db: Database, now: Date, words: [String],
        kinds: Set<TrashItem.Kind> = Set(TrashItem.Kind.allCases),
        oldestFirst: Bool = false, limit: Int? = nil, wingID: String? = nil,
        shows: (TrashItem) -> String = trashRowDefaultShown
    ) throws -> TrashSearchAnswer {
        guard !words.isEmpty else {
            return TrashSearchAnswer(items: try trash(
                db, now: now, kinds: kinds, oldestFirst: oldestFirst, limit: limit,
                wingID: wingID))
        }
        let listing = try trash(
            db, now: now, kinds: kinds, oldestFirst: oldestFirst, limit: nil, wingID: wingID)
        var items: [TrashItem] = []
        var passages: [String: String] = [:]
        var start = listing.startIndex
        scan: while start < listing.endIndex {
            let end = listing.index(start, offsetBy: trashSearchChunk, limitedBy: listing.endIndex)
                ?? listing.endIndex
            let chunk = Array(listing[start..<end])
            start = end
            let texts = try trashRowTexts(db, chunk)
            for item in chunk {
                let body = texts[item.id] ?? []
                let name = item.title.map { [$0] } ?? []
                guard TrashTextMatch.matchesEvery(words, in: name + body) else { continue }
                items.append(item)
                if let line = TrashTextMatch.passage(words: words, shown: shows(item), texts: body) {
                    passages[item.id] = line
                }
                if let limit, items.count >= limit { break scan }
            }
        }
        return TrashSearchAnswer(items: items, passages: passages)
    }

    /// How many listed rows one pair of text statements serves.
    static let trashSearchChunk = 200

    /// **Each row's DELETED TEXT, in reading order** (R-980-9) — the texts a
    /// Put back would bring back, read the way the restores read them:
    ///
    /// · a NOTE or a SNIPPET GROUP: its cascade family, `restoreContainer`'s
    ///   own join — the blocks reached through this container's placements
    ///   dead on the container's exact stamp and themselves dead on it — and
    ///   every take of those blocks that comes back with them (dead on that
    ///   stamp, or already live), archived takes included;
    /// · a BLOCK: its takes dead on its stamp or still live (`restoreBlock`'s
    ///   exact-stamp rule — the listing's own default-take join reads the same);
    /// · a PRESERVED ORIGINAL: a live block — its live takes (the same
    ///   statement: its `deleted_at` is NULL, so only live takes join);
    /// · a TAKE: its own text, already on the row;
    /// · a BOOK or a GATHERING: nothing — it is found by its name alone.
    ///
    /// Two statements, each DRIVEN by the rows' own ids (`json_each` first,
    /// `CROSS JOIN` — SQLite's join-order directive, the `smartMembershipSQL`
    /// lesson) and SEARCHing every store table by index; pinned on the plan
    /// (`TrashSearchTests.theTextReadIsDrivenFromTheTrashsOwnRows`).
    static func trashRowTexts(
        _ db: Database, _ items: [TrashItem]
    ) throws -> [String: [String]] {
        var texts: [String: [String]] = [:]
        for item in items where item.kind == .take {
            texts[item.id] = [item.text ?? ""]
        }
        let containers = items.filter { $0.kind == .note || $0.kind == .snippetGroup }.map(\.id)
        if !containers.isEmpty {
            for row in try Row.fetchAll(
                db, sql: trashContainerTextsSQL, arguments: [try jsonIDs(containers)])
            {
                texts[row["row_id"] as String, default: []].append(row["text"] ?? "")
            }
        }
        let blocks = items.filter { $0.kind == .block || $0.kind == .preservedOriginal }.map(\.id)
        if !blocks.isEmpty {
            for row in try Row.fetchAll(
                db, sql: trashBlockTextsSQL, arguments: [try jsonIDs(blocks)])
            {
                texts[row["row_id"] as String, default: []].append(row["text"] ?? "")
            }
        }
        return texts
    }

    /// A container row's family texts — `restoreContainerRows`' join.
    static let trashContainerTextsSQL = """
        SELECT j.value AS row_id, v.working_text AS text
        FROM json_each(?) j
        CROSS JOIN container c ON c.id = j.value
        CROSS JOIN container_block cb
          ON cb.container_id = c.id AND cb.deleted_at = c.deleted_at
        CROSS JOIN block b ON b.id = cb.block_id AND b.deleted_at = c.deleted_at
        CROSS JOIN variant v ON v.block_id = b.id
          AND (v.deleted_at IS NULL OR v.deleted_at = b.deleted_at)
        ORDER BY j.key, cb.position, cb.id, v.fan_position, v.id
        """

    /// A block row's takes (dead on its stamp, or live), and a preserved
    /// original's (live — its own stamp is NULL).
    static let trashBlockTextsSQL = """
        SELECT j.value AS row_id, v.working_text AS text
        FROM json_each(?) j
        CROSS JOIN block b ON b.id = j.value
        CROSS JOIN variant v ON v.block_id = b.id
          AND (v.deleted_at IS NULL OR v.deleted_at = b.deleted_at)
        ORDER BY j.key, v.fan_position, v.id
        """

    private static func jsonIDs(_ ids: [String]) throws -> String {
        String(decoding: try JSONEncoder().encode(ids), as: UTF8.self)
    }
}

extension AppDatabase {
    /// **The Trash, narrowed, live** — `observeTrash`'s twin for a typed
    /// search (VX-93). Woken by the SAME named region (`Queries.trashTables`
    /// — every table the narrowing reads is one the listing reads), so its
    /// re-fetch runs on a reader after a commit, never on the writer inside
    /// one (VX-670), and a Put back or a Delete Now leaves the narrowed
    /// listing as it leaves the listing.
    public func observeTrashSearch(
        now: Date, words: [String], kinds: Set<Queries.TrashItem.Kind>, oldestFirst: Bool,
        limit: Int, wingID: String? = nil,
        shows: @escaping @Sendable (Queries.TrashItem) -> String = Queries.trashRowDefaultShown
    ) -> AsyncValueObservation<Queries.TrashSearchAnswer> {
        observe(tracking: Queries.trashTables.map { Table($0) }) {
            try Queries.trashSearch(
                $0, now: now, words: words, kinds: kinds, oldestFirst: oldestFirst,
                limit: limit, wingID: wingID, shows: shows)
        }
    }
}
