import Foundation
import GRDB
import VariorumCore

/// **`read_note` with `with_ids: true`** (13n-b U2 — AF-5): the note as
/// structure — its blocks in order, each with its id, the id of the take it
/// SHOWS (`shown_take_id` — the read-time rule: the placement's chosen take
/// while it is live, active and on this block, else the block default, else
/// the fan's first; VX-186 — the text itself rides once, on that take's
/// entry), every live ACTIVE take (id, label, whether it is the one shown,
/// text — archived takes are out of the fan, the export's rule) and its live
/// comments. The ids
/// are the REAL row ids: every later write revalidates them per call against
/// current facts — and they are LIVE-WIRE ONLY (R-13nb-9, her doctrine: a
/// merge or a divide mints new blocks, so an id goes stale under her
/// structural edits; a stale id refuses honestly and a re-read recovers).
/// A block's NAME rides where set (R-13nb-8 — "in the xyz block" works
/// conversationally) as metadata only: ids stay the ONE write address (names
/// are not unique). Gated by the very same decision as the text form (the
/// caller's transaction), and ∝ the note — never the corpus.
///
/// **U3 grows it (the wire-document memo's shape, R-13nb-11/R-13nb-7):**
/// - `entry_date` where the note carries one (read-only here; set at create —
///   R-13nb-26 (b));
/// - `books`: the BOOKS holding the note that THIS CLIENT MAY READ, each with
///   the chapter it is filed under (AF-10 (f): a book the grant does not
///   reach keeps its name — names stay with grants; a dangling chapter
///   pointer reads unsectioned, the app's own rule);
/// - **`lens_id`** (VX-168 U3 — VX-172, her mint 2026-10-11: "a missing human
///   action, not special agent tooling"): the note READ THROUGH one of its
///   lenses — each block's `shown_take_id` is the lens's take where it names
///   one, else the shown take, and each block says which (`via: lens |
///   chosen`); the takes' `chosen` stays the note's own fact;
/// - **`with_commits`** (R-13nb-7 — commits reached BY EXPLICIT ASK, never
///   ambient, never in the Level 0 text): each take carries its commits
///   newest first (`commit_id`, `kind`, `message`, `created_at`, `length`,
///   `text`). Texts ride newest-first ACROSS the note until the answer
///   carries `commitTextBudget` characters of them; a commit past that says
///   `text_omitted: true` and is fetched by id (`commit_ids`, ≤20 per call,
///   always with text) — a bounded answer with complete reach (AF-10 (d)).
///
/// **VX-256 (VX-336 U7 — D-256-1…9, F-256-1…7 (a)) pages it:** with `page` the
/// read is ONE keyset page of the note's placements in its own order
/// (`(position, placement id)` on `idx_cblock_order` — `pageSQL`), ending at
/// the FIRST of `page.limit` blocks or the next block carrying the SERIALIZED
/// ANSWER past `pageAnswerBudget` characters (U7c — the first page's carriage
/// counted; `fitPage`), never splitting a block and always holding one, so a
/// block larger than its page has left comes alone; every carriage ask reads
/// for THAT page's blocks only
/// (∝ the page, P1), the note-wide lists (`with_tray`, `with_versions`,
/// `dangling_picks`) riding the first page, which also says `block_count`;
/// `next_cursor` comes back only while blocks remain. Pages are NOT a snapshot
/// (each its own transaction — D-256-7). `idsOnly` answers every take's
/// `sha256` (`MCPTextDigest`) in place of its text. With neither, every form is
/// byte-for-byte as it was (G-256-1).
enum MCPNoteStructure {
    /// What the caller asked for beyond the blocks.
    struct Options: Sendable {
        var withCommits = false
        /// Commits whose text rides whatever the budget (validated to be
        /// commits of THIS note's takes).
        var commitIDs: [String] = []
        // 13n-b U4 (R-13nb-14's keyboard bar; AF-11 F-4 — explicit call
        // shapes, never ambient, uniform per rung, R-13nb-17):
        /// ARCHIVED takes join each block's fan, marked `archived: true`
        /// (the app's kept-but-out-of-view posture: absent unless asked).
        var includeArchived = false
        /// The note's TRAY — its deleted blocks and deleted takes on their
        /// 30-day clocks (the tray's leaving section, its own queries).
        var withTray = false
        /// LINEAGE: each block's direct derived_from / version_of edges, and
        /// each take's parent (take ancestry).
        var withLineage = false
        /// The note's saved LENSES, each with its picks.
        var withLenses = false
        /// The note's saved VERSIONS (Note ▸ Versions' listing).
        var withVersions = false
        /// The tray's clock (the 30-day window is "now"-relative).
        var now = Date()
        /// VX-168 U3 (VX-172): read the note THROUGH this lens — each block's
        /// `shown_take_id` is the lens's take where the lens names one (a live
        /// ACTIVE take of the block — her Lenses board's rule), else the shown
        /// take, and each block says which: `via: "lens" | "chosen"`. The
        /// caller has already checked the lens is a live lens of THIS note.
        var lensID: String?
        /// VX-256: every take answers its `sha256` (`MCPTextDigest` — the
        /// digest of its text exactly as stored) in place of its `text`;
        /// comments, commits, the tray and lineage keep their text.
        var idsOnly = false
        /// VX-256: read ONE page of the note (nil: the whole note, as ever).
        var page: Page?
    }

    /// **One page's ask** (VX-256): at most `limit` blocks, resuming after
    /// `after` (nil: the first page).
    struct Page: Sendable {
        var limit: Int
        var after: NotePageCursor?
    }

    /// The characters one PAGE's ANSWER carries before it ends (VX-256 —
    /// F-256-2 (a); RE-RULED at U7c, P-VX256-1 PROVISIONAL — THE ORCHESTRATOR
    /// ON U7's WINDOW: the live round measured the client's inline cap between
    /// 43,062 and 50,984 characters of answer, and a take-text budget let a
    /// page's ids and records carry it to ≈ 2× its text). A page ends at
    /// `page.limit` blocks or as soon as adding the next block would carry the
    /// SERIALIZED answer (`answerText` — the very JSON the tool returns) past
    /// this many characters (`answerSize`), the first page's note-wide carriage
    /// included; a page always holds one whole block, so a block larger than
    /// what its page has left comes alone. Commit text rides within what is
    /// left (`text_omitted` past it).
    static let pageAnswerBudget = 32_000

    /// **The serialized answer** — the ONE encoding `read_note` sends
    /// (`MCPReadTools.encode` calls it) and the page budget measures (U7c): a
    /// sorted-keys compact JSON object. An answer holding a non-JSON value
    /// refuses as `MCPAnswerEncodingFailure` (U4: never an Objective-C
    /// exception that would take the app down).
    static func answerText(_ object: [String: Any]) throws -> String {
        guard JSONSerialization.isValidJSONObject(object) else { throw MCPAnswerEncodingFailure() }
        return String(decoding: try JSONSerialization.data(
            withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes]), as: UTF8.self)
    }

    /// An answer's size in the budget's unit (U7c): UTF-16 code units — the
    /// "characters" a JavaScript client such as Claude Code counts, and never
    /// fewer than Unicode scalars or Swift Characters, so "about 32,000
    /// characters" holds under every reading of the word.
    static func answerSize(_ text: String) -> Int { text.utf16.count }

    /// **ONE PAGE of the note's placements** (VX-256 — D-256-5): the keyset
    /// `(position, placement id) > (cursor)` written as a RANGE on `position`
    /// so `idx_cblock_order(container_id, position)` seeks the cursor instead
    /// of walking the note to it — the first page passes `''`, which sorts
    /// before every fractional key. ∝ the page (P1; the plan is pinned).
    static let pageSQL = """
        SELECT cb.id AS placement_id, cb.position, cb.block_id, cb.chosen_variant_id,
               b.default_variant_id, b.name
        FROM container_block cb JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
          AND cb.position >= ? AND (cb.position > ? OR cb.id > ?)
        ORDER BY cb.position, cb.id
        LIMIT ?
        """

    /// The first page's `block_count`: the note's live blocks now — one count
    /// over its placements' index range (the Hard rules' named allowance, "∝
    /// the note's blocks", first page only — F-256-5 (a)).
    static let blockCountSQL = """
        SELECT COUNT(*) FROM container_block cb JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
        """

    /// The most deleted blocks, deleted takes, versions and lenses one answer
    /// carries (each list says `truncated` past it) — ∝ the note, bounded.
    static let carriageCap = 200

    /// The characters of commit text one answer carries before later
    /// commits say `text_omitted` (AF-10 (d)).
    static let commitTextBudget = 100_000
    static let maxCommitIDs = 20

    /// `versionOf` (ladder round 1, F-3): non-nil when `noteID` is a SAVED
    /// VERSION being read on its live note's grant — the live note's id. The
    /// lineage classification then treats the live note (and its released
    /// originals, and its other saved moments) as the note's own family
    /// instead of stubbing the very note whose grant authorized the call as
    /// `beyond_grant`; the `books` answer stays the live-note read's alone.
    /// `echo` (U7c): keys the CALLER's answer carries beside the structure —
    /// a version read's `version_id`, `version_of`, `note_id` (the live note's)
    /// and `saved_at` — set on the answer here so a PAGE's budget weighs them
    /// as the wire will send them.
    static func read(
        _ db: Database, noteID: String, calendar: Calendar,
        standing: MCPGrantAuthority.Standing? = nil, options: Options = Options(),
        versionOf liveNoteID: String? = nil, echo: [String: String] = [:]
    ) throws -> [String: Any] {
        let title = try Queries.mcpScopeTitle(db, kind: .note, id: noteID, calendar: calendar) ?? ""
        // VX-256: a page is the first page when it resumes after nothing; the
        // unpaged read is its own "first page" (every note-wide list rides).
        let page = options.page
        let firstPage = page?.after == nil
        var placements: [Row]
        /// Blocks remain past this page's CANDIDATES (a page only): the extra
        /// row read, or the cost bound below ending the candidates early.
        var remains = false
        if let page {
            let after = page.after
            let fetched = try Row.fetchAll(
                db, sql: pageSQL,
                arguments: [noteID, after?.position ?? "", after?.position ?? "", after?.placementID ?? "",
                            page.limit + 1])
            remains = fetched.count > page.limit
            placements = Array(fetched.prefix(page.limit))
        } else {
            placements = try Row.fetchAll(
                db,
                sql: """
                    SELECT cb.block_id, cb.chosen_variant_id, b.default_variant_id, b.name
                    FROM container_block cb JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                    WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                    ORDER BY cb.position, cb.id
                    """,
                arguments: [noteID])
        }
        var blockIDs: [String] = placements.map { $0["block_id"] }
        var takes: [String: [Row]] = [:]
        for row in try Row.fetchAll(
            db,
            sql: """
                SELECT v.id, v.block_id, v.label, v.working_text, v.status, v.parent_variant_id
                FROM json_each(?) j
                JOIN variant v ON v.block_id = j.value
                WHERE v.deleted_at IS NULL AND (v.status = 'active' OR ?)
                ORDER BY v.fan_position, v.id
                """,
            arguments: [String(decoding: try JSONEncoder().encode(blockIDs), as: UTF8.self), options.includeArchived]) {
            takes[row["block_id"], default: []].append(row)
        }
        // The note's tray rides the FIRST page (VX-256 — F-256-7 (a)); read
        // here so a page weighs it.
        let trayAnswer = options.withTray && firstPage ? try tray(db, noteID: noteID, now: options.now) : nil
        if page != nil {
            // U7c — THE COST BOUND (never the page rule; `fitPage` is): the
            // answer carries every take's text verbatim (escaping only adds),
            // so no block past the point where the take text alone — plus the
            // first page's tray text — passes the budget can ride, the first
            // block excepted. The carriage below is read only for the blocks
            // before it (∝ what can be on the page; none under ids_only).
            var used = trayAnswer.map(Self.textSize(ofTray:)) ?? 0
            var kept = 0
            for placement in placements {
                let fan = takes[placement["block_id"] as String] ?? []
                let chars = options.idsOnly ? 0 : fan.reduce(0) { $0 + answerSize($1["working_text"] as String) }
                if kept > 0, used + chars > pageAnswerBudget { break }
                used += chars
                kept += 1
            }
            if kept < placements.count {
                remains = true
                placements.removeLast(placements.count - kept)
                blockIDs = placements.map { $0["block_id"] }
                let onPage = Set(blockIDs)
                takes = takes.filter { onPage.contains($0.key) }
            }
        }
        let json = String(decoding: try JSONEncoder().encode(blockIDs), as: UTF8.self)
        let lineage = options.withLineage
            ? try Self.lineage(db, noteID: noteID, blockIDs: blockIDs, standing: standing, versionOf: liveNoteID)
            : nil
        let parents = options.withLineage
            ? try Self.parents(
                db, noteID: noteID,
                parentIDs: takes.values.flatMap { $0.compactMap { $0["parent_variant_id"] as String? } },
                standing: standing, versionOf: liveNoteID)
            : [:]
        var comments: [String: [[String: Any]]] = [:]
        for row in try Row.fetchAll(
            db,
            sql: """
                SELECT c.id, c.block_id, c.text FROM json_each(?) j
                JOIN block_comment c ON c.block_id = j.value
                WHERE c.deleted_at IS NULL
                ORDER BY c.created_at, c.id
                """,
            arguments: [json]) {
            comments[row["block_id"], default: []].append(["comment_id": row["id"] as String, "text": row["text"] as String])
        }
        // The unpaged read's commits, under the note-wide budget; a PAGE reads
        // its commits once its blocks are weighed (`fitPage`, U7c).
        let commitLists = page == nil && (options.withCommits || !options.commitIDs.isEmpty)
            ? try commits(db, takeIDs: takes.values.flatMap { $0.map { $0["id"] as String } }, options: options)
            : nil
        // VX-172: the lens's EFFECTIVE picks — the very read her Lenses board
        // makes (`Queries.takesProjection.lensSelections`): a pick whose take
        // was archived or deleted since is dropped, so the block falls
        // through to its shown take, exactly as her lens column does.
        // VX-256: a page reads the lens's picks for ITS blocks only (D-256-4).
        let lensPicks = try options.lensID.map { lensID in
            page == nil
                ? try Queries.effectiveLensSelection(db, lens: lensID)
                : try Queries.effectiveLensSelection(db, lens: lensID, blocks: blockIDs)
        }
        var blocks: [[String: Any]] = []
        for placement in placements {
            let blockID: String = placement["block_id"]
            let fan = takes[blockID] ?? []
            // The SHOWN take is read over the ACTIVE fan only (AppSpec §7's
            // fallback: an archived chosen take renders the default) — an
            // archived take joining the list under `include_archived` never
            // becomes the one shown.
            let active = fan.filter { ($0["status"] as String) == "active" }
            let ids = Set(active.map { $0["id"] as String })
            let chosen: String? = placement["chosen_variant_id"]
            let fallback: String? = placement["default_variant_id"]
            let shown = [chosen, fallback].compactMap { $0 }.first { ids.contains($0) } ?? active.first?["id"]
            var entries: [[String: Any]] = []
            for take in fan {
                let id: String = take["id"]
                let text: String = take["working_text"]
                var entry: [String: Any] = ["take_id": id, "chosen": id == shown]
                // VX-256: ids_only answers the take's digest in place of its words.
                if options.idsOnly { entry["sha256"] = MCPTextDigest.sha256(text) } else { entry["text"] = text }
                if let label: String = take["label"] { entry["label"] = label }
                if (take["status"] as String) == "archived" { entry["archived"] = true }
                if let commitLists { entry["commits"] = commitLists[id] ?? [] }
                if options.withLineage, let parent: String = take["parent_variant_id"] {
                    for (key, value) in parents[parent] ?? Self.beyondGrantParent { entry[key] = value }
                }
                entries.append(entry)
            }
            // VX-172 — through a lens: the board's own rule
            // (`PaneTextAuthority.resolvedText`): the lens's pick where it is
            // a live ACTIVE take of this block, else the slot's shown take.
            // `chosen` on the takes stays the NOTE's fact — a lens is a view.
            var via: String?
            var shownTakeID = shown
            if let lensPicks {
                if let pick = lensPicks[blockID], active.contains(where: { ($0["id"] as String) == pick }) {
                    shownTakeID = pick
                    via = "lens"
                } else {
                    via = "chosen"
                }
            }
            // VX-186 (VX-184 U3): the block NAMES the take it shows — the
            // note's shown take, or the lens's where `via` says so — and the
            // text crosses ONCE, on that take's own entry. (Until this unit
            // the block also carried that text as its own `text`: every shown
            // take's words went out twice.) A block with no live active take
            // shows nothing and names nothing.
            var entry: [String: Any] = [
                "block_id": blockID, "takes": entries, "comments": comments[blockID] ?? [],
            ]
            if let shownTakeID { entry["shown_take_id"] = shownTakeID }
            if let via { entry["via"] = via }
            if let name: String = placement["name"], !name.isEmpty { entry["name"] = name }
            if let lineage { entry["lineage"] = lineage[blockID] ?? [] }
            blocks.append(entry)
        }
        var answer: [String: Any] = ["note_id": noteID, "title": title, "blocks": blocks]
        // VX-172: the view the blocks were read through, said (the
        // `version_id` echo's precedent).
        if let lensID = options.lensID { answer["lens_id"] = lensID }
        if let entryDate = try String.fetchOne(
            db, sql: "SELECT entry_date FROM container WHERE id = ?", arguments: [noteID]), !entryDate.isEmpty {
            answer["entry_date"] = entryDate
        }
        if let standing, liveNoteID == nil {
            answer["books"] = try books(db, noteID: noteID, standing: standing)
        }
        if let trayAnswer { answer["tray"] = trayAnswer }
        if options.withLenses {
            // VX-256 (F-256-7 (a)): the list on every page, each lens's picks
            // for the page's blocks, dangling_picks on the first page only.
            let lenses = try lenses(
                db, noteID: noteID, blockOrder: blockIDs, pageBlocks: page == nil ? nil : blockIDs,
                danglingPicks: firstPage)
            answer["lenses"] = lenses.entries
            // Ladder round 1, F-5: the cap says so (the tray's shape) —
            // never a silent drop.
            if lenses.truncated { answer["lenses_truncated"] = true }
        }
        if options.withVersions, firstPage {
            let versions = try versions(db, noteID: noteID)
            answer["versions"] = versions.entries
            if versions.truncated { answer["versions_truncated"] = true }
        }
        for (key, value) in echo { answer[key] = value }
        guard page != nil else { return answer }
        if firstPage {
            answer["block_count"] = try Int.fetchOne(db, sql: blockCountSQL, arguments: [noteID]) ?? 0
        }
        return try fitPage(
            db, answer: answer, placements: placements, remains: remains, containerID: noteID, options: options)
    }

    /// **THE PAGE, FITTED TO ITS ANSWER** (VX-256 re-ruled at U7c — P-VX256-1,
    /// PROVISIONAL; the run record's U7c UNIT RECORD, D-U7c-1…6). `answer` is
    /// the page with every CANDIDATE block (`blocks`, each lens's `picks` for
    /// all of them) and its header — the first page's carriage and the
    /// caller's echoes included. The page keeps the first `k` blocks, `k` the
    /// largest the rule allows: block 1 always (whole — a block larger than
    /// what the page has left comes ALONE); each next block only while the
    /// answer with it — its entry, its lens picks, the moved `next_cursor` —
    /// stays within `pageAnswerBudget`, sized exactly piece by piece on the
    /// very encoding the wire sends (`answerText`: an object's sorted, compact
    /// JSON is its pieces' JSON joined by commas). Commits (`with_commits` /
    /// `commit_ids`) are read for the weighed blocks' takes and weigh with them
    /// as metadata (an asked commit with its text, every other `text_omitted`),
    /// the page shrinking while it is over; then unasked texts ride newest-first
    /// across the page within what is left, and the first that does not fit
    /// ends them. The finished answer is measured once more and the page
    /// shrinks if it is over — the bound holds by that check, never by the
    /// arithmetic alone. ∝ the page (P1): every piece is one candidate's.
    private static func fitPage(
        _ db: Database, answer header: [String: Any], placements: [Row], remains: Bool, containerID: String,
        options: Options
    ) throws -> [String: Any] {
        let budget = pageAnswerBudget
        var entries = header["blocks"] as? [[String: Any]] ?? []
        let count = entries.count
        let lensEntries = header["lenses"] as? [[String: Any]]
        let rank = Dictionary(
            entries.enumerated().map { ($1["block_id"] as? String ?? "", $0) }, uniquingKeysWith: { first, _ in first })
        /// The resume point after a `k`-block page, while blocks remain.
        func cursor(after k: Int) -> String? {
            guard k > 0, k < count || remains else { return nil }
            return NotePageCursor(
                containerID: containerID, position: placements[k - 1]["position"],
                placementID: placements[k - 1]["placement_id"]).encoded
        }
        /// The answer of a `k`-block page: the first `k` of `list`, each lens's
        /// picks among them, the cursor after them.
        func assemble(_ k: Int, _ list: [[String: Any]]) -> [String: Any] {
            var answer = header
            answer["blocks"] = Array(list.prefix(k))
            if let lensEntries {
                answer["lenses"] = lensEntries.map { lens -> [String: Any] in
                    var lens = lens
                    lens["picks"] = (lens["picks"] as? [[String: Any]] ?? [])
                        .filter { (rank[$0["block_id"] as? String ?? ""] ?? count) < k }
                    return lens
                }
            }
            answer["next_cursor"] = cursor(after: k)
            return answer
        }
        guard count > 0 else { return assemble(0, entries) }

        // THE PIECES, each measured on the wire's encoding: the page with no
        // block, no pick and no cursor (`base` — its `[]`s already counted);
        // each block's entry (+ 1 comma after the first); each lens pick (+ 1
        // comma after its lens's first, which `firsts` takes back); the cursor
        // pair (+ 1 comma — the answer always holds other keys).
        let base = answerSize(try answerText(assemble(0, entries)))
        var lengths = try entries.map { answerSize(try answerText($0)) }
        var picks = [Int](repeating: 0, count: count)
        var firsts = [Int](repeating: 0, count: count)
        for lens in lensEntries ?? [] {
            let ranked = try (lens["picks"] as? [[String: Any]] ?? []).compactMap { pick -> (Int, Int)? in
                guard let at = rank[pick["block_id"] as? String ?? ""] else { return nil }
                return (at, answerSize(try answerText(pick)) + 1)
            }
            for (at, size) in ranked { picks[at] += size }
            if let first = ranked.map(\.0).min() { firsts[first] += 1 }
        }
        func cursorSize(after k: Int) throws -> Int {
            guard let cursor = cursor(after: k) else { return 0 }
            return answerSize(try answerText(["next_cursor": cursor])) - 2 + 1
        }
        /// The exact size of a `k`-block page's answer (k ≥ 1).
        func size(_ k: Int) throws -> Int {
            var total = base + (k - 1)
            for index in 0..<k { total += lengths[index] + picks[index] - firsts[index] }
            return total + (try cursorSize(after: k))
        }
        var k = 1
        var running = base + lengths[0] + picks[0] - firsts[0]  // a 1-block page, before its cursor
        while k < count {
            let grown = running + 1 + lengths[k] + picks[k] - firsts[k]
            guard grown + (try cursorSize(after: k + 1)) <= budget else { break }
            running = grown
            k += 1
        }

        let commitsAsked = options.withCommits || !options.commitIDs.isEmpty
        let asked = Set(options.commitIDs)
        var rows: [Row] = []
        func takeIDs(_ entry: [String: Any]) -> [String] {
            (entry["takes"] as? [[String: Any]] ?? []).compactMap { $0["take_id"] as? String }
        }
        if commitsAsked {
            // The weighed blocks' commits, as metadata — newest first across
            // the page (an asked one with its text, every other text_omitted) —
            // and the page weighed again with them, shrinking while it is over.
            rows = try commitRows(db, takeIDs: entries.prefix(k).flatMap(takeIDs))
            var lists: [String: [[String: Any]]] = [:]
            for row in rows {
                lists[row["variant_id"], default: []].append(commitEntry(row, withText: asked.contains(row["id"])))
            }
            for index in 0..<k {
                entries[index] = withCommitLists(entries[index], lists)
                lengths[index] = answerSize(try answerText(entries[index]))
            }
            while k > 1, try size(k) > budget { k -= 1 }
        }
        while true {
            var list = Array(entries.prefix(k))
            if commitsAsked {
                let onPage = Set(list.flatMap(takeIDs))
                let pageRows = rows.filter { onPage.contains($0["variant_id"]) }
                let known = Set(pageRows.map { $0["id"] as String })
                if let stranger = options.commitIDs.first(where: { !known.contains($0) }) {
                    throw MCPReadTools.ArgumentFailure(message: "commit_id \(stranger) isn't a commit of a take on this page.")
                }
                // Commit text rides in what is left of the page's budget.
                var left = budget - (try size(k))
                let omitted = answerSize(try answerText(["text_omitted": true]))
                var riding: Set<String> = []
                for row in pageRows where !asked.contains(row["id"]) {
                    let delta = answerSize(try answerText(["text": row["text"] as String])) - omitted
                    guard delta <= left else { break }
                    riding.insert(row["id"])
                    left -= delta
                }
                var lists: [String: [[String: Any]]] = [:]
                for row in pageRows {
                    let id: String = row["id"]
                    lists[row["variant_id"], default: []].append(
                        commitEntry(row, withText: asked.contains(id) || riding.contains(id)))
                }
                list = list.map { withCommitLists($0, lists) }
            }
            let fitted = assemble(k, list)
            // The bound holds by this measurement: the sizes above are exact,
            // so the page never shrinks here — unless they were not.
            if k == 1 { return fitted }
            if answerSize(try answerText(fitted)) <= budget { return fitted }
            k -= 1
        }
    }

    /// A block entry with each of its takes carrying its commit list (`[]`
    /// when it has none — the unpaged form's shape).
    private static func withCommitLists(
        _ entry: [String: Any], _ lists: [String: [[String: Any]]]
    ) -> [String: Any] {
        var entry = entry
        entry["takes"] = (entry["takes"] as? [[String: Any]] ?? []).map { take -> [String: Any] in
            var take = take
            take["commits"] = lists[take["take_id"] as? String ?? ""] ?? []
            return take
        }
        return entry
    }

    /// The UTF-16 characters of text a tray answer carries (its blocks' and
    /// takes') — the cost bound's share of the first page's carriage.
    private static func textSize(ofTray tray: [String: Any]) -> Int {
        ["blocks", "takes"].reduce(0) { total, key in
            total + (tray[key] as? [[String: Any]] ?? []).reduce(0) { $0 + answerSize(($1["text"] as? String) ?? "") }
        }
    }

    // MARK: - 13n-b U4: the carriage (AF-11 F-4)

    /// **The note's TRAY** — the leaving section exactly as her tray panel
    /// lists it (`Queries.trayBlocks` / `trayTakes`: individually deleted,
    /// inside the 30-day window, no purge intent; a take that died WITH its
    /// block rides the block's row). `put_back` addresses these ids.
    static func tray(_ db: Database, noteID: String, now: Date) throws -> [String: Any] {
        let blocks = try Queries.trayBlocks(db, postID: noteID, now: now, limit: carriageCap + 1)
        let takes = try Queries.trayTakes(db, postID: noteID, now: now, limit: carriageCap + 1)
        var answer: [String: Any] = [
            "blocks": blocks.prefix(carriageCap).map { item -> [String: Any] in
                ["block_id": item.blockID, "deleted_at": item.deletedAt, "text": item.text ?? ""]
            },
            "takes": takes.prefix(carriageCap).map { take -> [String: Any] in
                var entry: [String: Any] = [
                    "take_id": take.variantID, "block_id": take.blockID, "deleted_at": take.deletedAt,
                    "text": take.text,
                ]
                if let label = take.label { entry["label"] = label }
                return entry
            },
        ]
        if blocks.count > carriageCap || takes.count > carriageCap { answer["truncated"] = true }
        return answer
    }

    /// **The note's saved LENSES** — each lens's name and its EFFECTIVE picks
    /// (a pick whose take has since been archived or deleted falls through to
    /// the note's own chosen take, `effectiveLensSelection`'s rule — counted
    /// in `dangling_picks`), in the note's block order.
    /// Capped at `carriageCap` with a truncated flag (ladder round 1, F-5 —
    /// the tray's own shape; a silent drop said nothing).
    /// VX-256: `pageBlocks` reads each lens's picks for those blocks only (a
    /// page's — ∝ the page), and `danglingPicks: false` leaves the note-wide
    /// count to the first page.
    static func lenses(
        _ db: Database, noteID: String, blockOrder: [String], pageBlocks: [String]? = nil,
        danglingPicks: Bool = true
    ) throws -> (entries: [[String: Any]], truncated: Bool) {
        let rank = Dictionary(blockOrder.enumerated().map { ($1, $0) }, uniquingKeysWith: { first, _ in first })
        let all = try Queries.lenses(db, post: noteID)
        let entries = try all.prefix(carriageCap).map { lens -> [String: Any] in
            let selection = try pageBlocks.map { try Queries.effectiveLensSelection(db, lens: lens.id, blocks: $0) }
                ?? Queries.effectiveLensSelection(db, lens: lens.id)
            let picks = selection
                .filter { rank[$0.key] != nil }
                .sorted { (rank[$0.key] ?? 0, $0.key) < (rank[$1.key] ?? 0, $1.key) }
                .map { ["block_id": $0.key, "take_id": $0.value] }
            var entry: [String: Any] = ["lens_id": lens.id, "name": lens.name, "picks": picks]
            if danglingPicks { entry["dangling_picks"] = try Queries.danglingLensPicks(db, lens: lens.id).count }
            return entry
        }
        return (entries, all.count > carriageCap)
    }

    /// **The note's saved VERSIONS** — Note ▸ Versions' listing (newest
    /// first); `read_note`'s `version_id` reads one.
    /// Capped at `carriageCap` with a truncated flag (ladder round 1, F-5).
    static func versions(_ db: Database, noteID: String) throws -> (entries: [[String: Any]], truncated: Bool) {
        let all = try Queries.noteVersions(db, of: noteID, limit: carriageCap + 1)
        let entries = all.prefix(carriageCap).map { item -> [String: Any] in
            var entry: [String: Any] = [
                "version_id": item.postID, "saved_at": DateFormatter.variorumISO8601.string(from: item.savedAt),
                "block_count": item.blockCount,
            ]
            if let preview = item.preview { entry["preview"] = String(preview.prefix(280)) }
            return entry
        }
        return (entries, all.count > carriageCap)
    }

    /// The ONE uniform stub for a lineage far side beyond the client's grant
    /// (AF-11 F-4's RIDER): no id, no title, no kind — nothing distinguishes a
    /// FENCED far side from a merely unshared one, a scrap, or a released
    /// block of another note. The edge's own relation rides beside it.
    static func beyondGrant(_ relation: String) -> [String: Any] {
        ["relation": relation, "beyond_grant": true]
    }

    /// A take's parent beyond the grant — the same uniform stub's twin.
    static var beyondGrantParent: [String: Any] { ["parent_beyond_grant": true] }

    /// Where a far-side block lives, as the client may know it.
    private enum FarSide {
        case thisNote
        case releasedOriginal(text: String?)
        case version(String)
        case readableNote(String)
        case beyondGrant
    }

    /// Classifies far-side blocks for THIS client (`standing`), batched.
    /// `liveNoteID` (ladder round 1, F-3) is non-nil on a VERSION read: the
    /// live note whose grant authorized the call — its blocks address as a
    /// readable note (never the stub), its other saved moments as versions,
    /// and its released originals as the family's own (exactly what reading
    /// the live note with `with_lineage` would disclose).
    private static func farSides(
        _ db: Database, noteID: String, blockIDs: Set<String>, standing: MCPGrantAuthority.Standing?,
        liveNoteID: String? = nil
    ) throws -> [String: FarSide] {
        guard !blockIDs.isEmpty else { return [:] }
        let json = String(decoding: try JSONEncoder().encode(blockIDs.sorted()), as: UTF8.self)
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT b.id, b.last_container_id, cb.container_id AS placed, dv.working_text AS text
                FROM json_each(?) j JOIN block b ON b.id = j.value AND b.deleted_at IS NULL
                LEFT JOIN container_block cb ON cb.block_id = b.id AND cb.deleted_at IS NULL
                LEFT JOIN variant dv ON dv.id = b.default_variant_id AND dv.deleted_at IS NULL
                """,
            arguments: [json])
        // The family whose versions count as "a saved moment of this note":
        // the live note on a version read, this note otherwise.
        let family = liveNoteID ?? noteID
        let homes = Set(rows.compactMap { $0["placed"] as String? }).subtracting([noteID])
        let facts = try Queries.mcpNoteFacts(db, noteIDs: homes.sorted())
        var sides: [String: FarSide] = [:]
        for row in rows {
            let id: String = row["id"]
            if let placed: String = row["placed"] {
                if placed == noteID {
                    sides[id] = .thisNote
                } else if placed == liveNoteID {
                    sides[id] = .readableNote(placed)
                } else if try Queries.isVersionHistory(db, placed, of: family) {
                    sides[id] = .version(placed)
                } else if let standing, MCPGrantAuthority.decide(
                    standing, note: facts[placed], rung: .read, consumes: false).isAllowed {
                    sides[id] = .readableNote(placed)
                } else {
                    sides[id] = .beyondGrant
                }
            } else if let last = row["last_container_id"] as String?, last == noteID || last == liveNoteID {
                sides[id] = .releasedOriginal(text: row["text"])
            } else {
                sides[id] = .beyondGrant
            }
        }
        return sides
    }

    /// **LINEAGE** — each of the note's blocks' DIRECT live edges
    /// (`derived_from` both ways and `version_of`), the far side as the client
    /// may know it: a block of this note, a released original of this note
    /// (with its text — part of the note's own history), a block of one of
    /// its saved versions, a block of another note the client can read, or
    /// the ONE uniform stub. A dead far side is left out (the lineage walks'
    /// live-endpoint rule). ∝ the note's blocks' edges (both indexes).
    static func lineage(
        _ db: Database, noteID: String, blockIDs: [String], standing: MCPGrantAuthority.Standing?,
        versionOf liveNoteID: String? = nil
    ) throws -> [String: [[String: Any]]] {
        guard !blockIDs.isEmpty else { return [:] }
        let json = String(decoding: try JSONEncoder().encode(blockIDs), as: UTF8.self)
        let edges = try Row.fetchAll(
            db,
            sql: """
                SELECT e.id, e.source_block_id, e.target_block_id, e.type, e.origin_op, e.created_at
                FROM json_each(?) j JOIN edge e ON e.source_block_id = j.value
                WHERE e.deleted_at IS NULL
                UNION
                SELECT e.id, e.source_block_id, e.target_block_id, e.type, e.origin_op, e.created_at
                FROM json_each(?) j JOIN edge e ON e.target_block_id = j.value
                WHERE e.deleted_at IS NULL
                ORDER BY 6, 1
                """,
            arguments: [json, json])
        let mine = Set(blockIDs)
        var far: Set<String> = []
        for edge in edges {
            far.insert(edge["source_block_id"])
            far.insert(edge["target_block_id"])
        }
        let sides = try farSides(db, noteID: noteID, blockIDs: far, standing: standing, liveNoteID: liveNoteID)
        var lineage: [String: [[String: Any]]] = [:]
        for edge in edges {
            let source: String = edge["source_block_id"]
            let target: String = edge["target_block_id"]
            let type: String = edge["type"]
            for (block, other, relation) in [
                (source, target, type == "version_of" ? "version_of" : "derived_from"),
                (target, source, type == "version_of" ? "version_of" : "derived_into"),
            ] where mine.contains(block) {
                guard let side = sides[other] else { continue }  // a dead far side
                var entry: [String: Any]
                switch side {
                case .beyondGrant:
                    lineage[block, default: []].append(beyondGrant(relation))
                    continue
                case .thisNote:
                    entry = ["relation": relation, "block_id": other]
                case .releasedOriginal(let text):
                    entry = ["relation": relation, "block_id": other, "released": true, "text": text ?? ""]
                case .version(let versionID):
                    entry = ["relation": relation, "block_id": other, "version_id": versionID]
                case .readableNote(let otherNote):
                    entry = ["relation": relation, "block_id": other, "note_id": otherNote]
                }
                if let op: String = edge["origin_op"] { entry["origin_op"] = op }
                entry["at"] = edge["created_at"] as String
                lineage[block, default: []].append(entry)
            }
        }
        return lineage
    }

    /// **TAKE ANCESTRY** — each parent take's address as the client may know
    /// it: its id when its block belongs to this note's family (placed here,
    /// released from here, a version of this note's) or to a note the client
    /// can read (with that note's id), else the uniform stub's twin.
    static func parents(
        _ db: Database, noteID: String, parentIDs: [String], standing: MCPGrantAuthority.Standing?,
        versionOf liveNoteID: String? = nil
    ) throws -> [String: [String: Any]] {
        guard !parentIDs.isEmpty else { return [:] }
        let json = String(decoding: try JSONEncoder().encode(Array(Set(parentIDs)).sorted()), as: UTF8.self)
        let rows = try Row.fetchAll(
            db,
            sql: "SELECT v.id, v.block_id FROM json_each(?) j JOIN variant v ON v.id = j.value",
            arguments: [json])
        let sides = try farSides(db, noteID: noteID, blockIDs: Set(rows.map { $0["block_id"] as String }),
                                 standing: standing, liveNoteID: liveNoteID)
        var answer: [String: [String: Any]] = [:]
        for row in rows {
            let id: String = row["id"]
            switch sides[row["block_id"] as String] {
            case .thisNote?, .releasedOriginal?: answer[id] = ["parent_take_id": id]
            case .version(let versionID)?: answer[id] = ["parent_take_id": id, "parent_version_id": versionID]
            case .readableNote(let other)?: answer[id] = ["parent_take_id": id, "parent_note_id": other]
            case .beyondGrant?, nil: answer[id] = beyondGrantParent
            }
        }
        return answer
    }

    /// The books holding the note that this client may READ, with each
    /// membership's chapter (a dangling pointer reads unsectioned).
    static func books(
        _ db: Database, noteID: String, standing: MCPGrantAuthority.Standing
    ) throws -> [[String: Any]] {
        try Row.fetchAll(
            db,
            sql: """
                SELECT r.id, r.name, s.id AS section_id, s.name AS section_name
                FROM reading_post rp
                JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL AND r.kind = 'book'
                LEFT JOIN reading_section s
                  ON s.id = rp.section_id AND s.deleted_at IS NULL AND s.reading_id = rp.reading_id
                WHERE rp.post_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                ORDER BY r.name COLLATE NOCASE, r.id
                """,
            arguments: [noteID]
        ).compactMap { row -> [String: Any]? in
            let bookID: String = row["id"]
            guard MCPGrantAuthority.decide(
                standing, book: try Queries.mcpBookFacts(db, readingID: bookID), rung: .read
            ).isAllowed else { return nil }
            var entry: [String: Any] = ["book_id": bookID, "name": row["name"] as String]
            if let sectionID: String = row["section_id"] {
                entry["section_id"] = sectionID
                entry["section_name"] = row["section_name"] as String
            }
            return entry
        }
    }

    /// Each take's commits, newest first, with texts riding newest-first
    /// across the note until `commitTextBudget` is spent; `commitIDs` always
    /// ride with text and must be commits of these takes. The UNPAGED read's
    /// (a PAGE weighs its commits with its blocks — `fitPage`, U7c; there a
    /// stranger "isn't a commit of a take on this page", P-VX256-4).
    static func commits(
        _ db: Database, takeIDs: [String], options: Options
    ) throws -> [String: [[String: Any]]] {
        let rows = try commitRows(db, takeIDs: takeIDs)
        let known = Set(rows.map { $0["id"] as String })
        if let stranger = options.commitIDs.first(where: { !known.contains($0) }) {
            throw MCPReadTools.ArgumentFailure(message: "commit_id \(stranger) isn't a commit of this note.")
        }
        let asked = Set(options.commitIDs)
        var budget = commitTextBudget
        var lists: [String: [[String: Any]]] = [:]
        for row in rows {
            let id: String = row["id"]
            let text: String = row["text"]
            let rides: Bool
            if asked.contains(id) {
                rides = true
            } else if text.count <= budget {
                rides = true
                budget -= text.count
            } else {
                rides = false
                budget = 0
            }
            lists[row["variant_id"], default: []].append(commitEntry(row, withText: rides))
        }
        return lists
    }

    /// These takes' commits, newest first across them.
    private static func commitRows(_ db: Database, takeIDs: [String]) throws -> [Row] {
        try Row.fetchAll(
            db,
            sql: """
                SELECT c.id, c.variant_id, c.kind, c.message, c.created_at, c.text FROM json_each(?) j
                JOIN commit_point c ON c.variant_id = j.value
                ORDER BY c.created_at DESC, c.id DESC
                """,
            arguments: [String(decoding: try JSONEncoder().encode(takeIDs), as: UTF8.self)])
    }

    /// One commit's entry: its text when it rides, else `text_omitted`.
    private static func commitEntry(_ row: Row, withText: Bool) -> [String: Any] {
        let text: String = row["text"]
        var entry: [String: Any] = [
            "commit_id": row["id"] as String, "kind": row["kind"] as String,
            "created_at": row["created_at"] as String, "length": text.count,
        ]
        if let message: String = row["message"] { entry["message"] = message }
        if withText { entry["text"] = text } else { entry["text_omitted"] = true }
        return entry
    }
}

/// **A paged `read_note`'s resume point** (VX-256 — D-256-3): the last page
/// block's placement `(position, id)`, the read's own order, and the container
/// it pages (the note, or the saved version) — opaque to the client, base64 of
/// `n\n<container id>\n<position>\n<placement id>`. It resumes ONLY that
/// container: anything else answers `MCPReadTools.staleCursorMessage`, so a
/// `list_notes` or `list_my_activity` cursor (another shape) never decodes as
/// one. Keyed on a position, never a live row, so deleting the cursor's own
/// block never breaks the resume.
struct NotePageCursor: Equatable, Sendable {
    let containerID: String
    let position: String
    let placementID: String

    var encoded: String {
        Data("n\n\(containerID)\n\(position)\n\(placementID)".utf8).base64EncodedString()
    }

    init(containerID: String, position: String, placementID: String) {
        self.containerID = containerID
        self.position = position
        self.placementID = placementID
    }

    init?(encoded: String) {
        guard let data = Data(base64Encoded: encoded), let text = String(data: data, encoding: .utf8) else {
            return nil
        }
        let parts = text.split(separator: "\n", maxSplits: 3, omittingEmptySubsequences: false).map(String.init)
        guard parts.count == 4, parts[0] == "n", !parts[1].isEmpty, !parts[2].isEmpty, !parts[3].isEmpty,
              !parts[3].contains("\n")
        else { return nil }
        containerID = parts[1]
        position = parts[2]
        placementID = parts[3]
    }
}
