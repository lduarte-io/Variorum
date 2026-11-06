import Foundation
import GRDB
import MCP
import VariorumCore

/// **THE READ RUNG's tool projections** (13n-b U1 — R-13n-4's "read + search
/// within scope"; the mockup §9). Thin projections of the queries the app
/// itself reads through — `read_note` IS `Queries.variorumDocumentText` (the
/// Level 0 format; VX-168 U3 — through a lens, `variorumDocumentText(…,
/// throughLens:)`), `export_note` IS `Queries.renderedText`, `search` IS the
/// 13o engine (`Queries.searchPassages`) — each gated PER CALL by the pure
/// rule over CURRENT facts.
///
/// **Transactions (round 1 F3):** `read_note`/`export_note` run in ONE write
/// transaction — the once-grant stamp must be atomic with the read it
/// authorizes, so a once grant can never be read twice. The three
/// NON-consuming tools (`list_books`, `list_notes`, `search`) assemble their
/// whole answer in ONE read snapshot and then write the activity line in a
/// short write of its own — the heavy answer never holds the writer, so her
/// own autosave is never queued behind a client's search (P2). A revocation
/// landing mid-call is honoured on the very next call, exactly as before;
/// every refusal is still logged.
///
/// P1: every call costs ∝ its scope — a book's members, a wing's page by the
/// recency index, the grants' own candidates, the search engine's matches —
/// never the corpus.
struct MCPReadTools: Sendable {
    let database: AppDatabase
    let operations: Operations
    var calendar: Calendar = JournalDay.storeCalendar
    /// U2: the app's seams — the just-in-time ask (AF-6) rides here.
    var hooks = MCPHostHooks()

    struct Outcome: Equatable, Sendable {
        let text: String
        let isError: Bool
    }

    static let defaultPageSize = 50
    static let maxPageSize = 200
    static let defaultSearchLimit = 20
    static let maxSearchLimit = 50
    /// The one refusal for a cursor this server would not have returned —
    /// undecodable, or minted by a listing of another order (F5).
    static let staleCursorMessage = "cursor is not a next_cursor this server returned."

    /// Route one `tools/call`. Unknown names answer as an error; a KNOWN tool
    /// the client cannot use answers with the rule's own refusal (the list is
    /// a courtesy — the rule is the boundary).
    func call(_ name: String, arguments: [String: Value]?, clientName: String) -> Outcome {
        let args = arguments ?? [:]
        do {
            switch name {
            case MCPToolCatalog.listBooks.name: return try listBooks(args, clientName: clientName)
            case MCPToolCatalog.listNotes.name: return try listNotes(args, clientName: clientName)
            case MCPToolCatalog.readNote.name: return try readNote(args, clientName: clientName, plain: false)
            case MCPToolCatalog.exportNote.name: return try readNote(args, clientName: clientName, plain: true)
            case MCPToolCatalog.search.name: return try search(args, clientName: clientName)
            case MCPToolCatalog.listMyActivity.name: return try listMyActivity(args, clientName: clientName)
            case MCPToolCatalog.listWings.name: return try listWings(clientName: clientName)
            case MCPToolCatalog.listNoteLineage.name: return try listNoteLineage(args, clientName: clientName)
            default: return Outcome(text: "Unknown tool: \(name).", isError: true)
            }
        } catch let failure as ArgumentFailure {
            return Outcome(text: failure.message, isError: true)
        } catch {
            // VX-369: through the one chain — never the raw error.
            return Outcome(
                text: MCPWireRefusalCopy.unexpected(error, tool: name, appWords: hooks.refusalWords), isError: true)
        }
    }

    static let handledToolNames: Set<String> = [
        "list_books", "list_notes", "read_note", "export_note", "search", "list_my_activity",
        // VX-348 U5 — VX-392.
        "list_wings",
        // VX-827 U1 — VX-817.
        "list_note_lineage",
    ]

    // MARK: - read_note / export_note

    private func readNote(_ args: [String: Value], clientName: String, plain: Bool) throws -> Outcome {
        let noteID = try requiredString(args, "note_id")
        // U2 (AF-5): the structured form — the SAME decision, the SAME once
        // stamp, the SAME transaction; only the answer's shape differs. U3
        // (R-13nb-7): `with_commits` / `commit_ids` ask for commit history,
        // which lives ONLY in the structured form (never the Level 0 text —
        // R-13n-8), so either one implies it.
        var options = MCPNoteStructure.Options()
        var versionID: String?
        var lensID: String?
        if !plain {
            options.withCommits = try optionalBool(args, "with_commits") ?? false
            options.commitIDs = try optionalStrings(args, "commit_ids") ?? []
            guard options.commitIDs.count <= MCPNoteStructure.maxCommitIDs else {
                throw ArgumentFailure(message: "commit_ids takes at most \(MCPNoteStructure.maxCommitIDs) ids per call.")
            }
            // U4 (AF-11 F-4): the carriage, each an explicit ask that implies
            // the structured form (none of it rides the Level 0 text).
            options.includeArchived = try optionalBool(args, "include_archived") ?? false
            options.withTray = try optionalBool(args, "with_tray") ?? false
            options.withLineage = try optionalBool(args, "with_lineage") ?? false
            options.withLenses = try optionalBool(args, "with_lenses") ?? false
            options.withVersions = try optionalBool(args, "with_versions") ?? false
            options.now = hooks.now()
            versionID = try optionalString(args, "version_id")
            // VX-168 U3 (VX-172): read THROUGH a lens of this note — either
            // form (the text or `with_ids`). A lens belongs to the live note;
            // a saved version carries none ("lenses never ride any copy"), so
            // the pair is an argument error — said the same whether or not
            // the lens exists (no oracle).
            lensID = try optionalString(args, "lens_id")
            options.lensID = lensID
            if versionID != nil, lensID != nil {
                throw ArgumentFailure(message: "Pass version_id or lens_id, not both: a saved version has no lenses.")
            }
            // VX-256 (VX-336 U7 — D-256-2/6): PAGES and ids_only, parsed
            // before any target is read (independent of it, so no oracle):
            // `limit` clamps 1…200 like `list_notes`; a `cursor` this read
            // would not have minted is stale; either asks for pages (a cursor
            // alone reads 50), and pages and ids_only each imply with_ids.
            let limit = try optionalInt(args, "limit")
            let cursor = try optionalString(args, "cursor")
            let after = cursor.flatMap(NotePageCursor.init(encoded:))
            if cursor != nil, after == nil { throw ArgumentFailure(message: Self.staleCursorMessage) }
            options.idsOnly = try optionalBool(args, "ids_only") ?? false
            if limit != nil || cursor != nil {
                options.page = MCPNoteStructure.Page(
                    limit: min(max(limit ?? Self.defaultPageSize, 1), Self.maxPageSize), after: after)
            }
        }
        let carriage = options.includeArchived || options.withTray || options.withLineage
            || options.withLenses || options.withVersions
        let withIDs = plain ? false
            : (try optionalBool(args, "with_ids") ?? false) || options.withCommits || !options.commitIDs.isEmpty
                || carriage || options.page != nil || options.idsOnly
        let act = plain ? MCPToolCatalog.exportNote.name : MCPToolCatalog.readNote.name
        return try database.write { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            let facts = try Queries.mcpNoteFacts(db, noteID: noteID)
            let decision = MCPGrantAuthority.decide(standing, note: facts, rung: .read, consumes: true)
            let title = facts == nil ? nil : try Queries.mcpScopeTitle(db, kind: .note, id: noteID, calendar: calendar)
            guard case .allow(let grantID, let consumesOnce) = decision else {
                try log(db, clientName, act, "note", noteID, title, allowed: false)
                let ask = facts.map { facts in
                    MCPAsk(clientName: clientName, scopeKind: .note, scopeID: noteID, title: title ?? "",
                           rung: .read, fence: facts.fence)
                }
                return MCPAsking(onAsk: hooks.onAsk).refusal(decision, .note, standing: standing, ask: ask)
            }
            // U4 (AF-11 F-4): a saved VERSION of this note, read on the NOTE's
            // grant (a moment of a note is that note's past — the note is the
            // disclosure unit, R-13nb-12). Asked only after the note itself is
            // allowed, so the words below disclose nothing the client cannot
            // already read.
            if let versionID, !(try Queries.isVersionHistory(db, versionID, of: noteID)) {
                try log(db, clientName, act, "note", noteID, title, allowed: false)
                return Outcome(text: "version_id isn't a saved version of this note (with_versions lists them).",
                               isError: true)
            }
            // VX-168 U3 (VX-172): a lens_id must name a LIVE lens of THIS
            // note. Anything else — an id naming nothing, a dead lens, a
            // lens of another note (readable or not), any other row's id —
            // answers EXACTLY as a note id naming nothing does: the same
            // decision over no facts, the same refusal, no ask (pinned byte
            // for byte). Checked after the note is allowed and BEFORE the
            // once spend, so a refused lens never spends the grant.
            if let lensID, try Queries.mcpContainerOf(lens: lensID, db) != noteID {
                try log(db, clientName, act, "note", noteID, title, allowed: false)
                return MCPAsking(onAsk: hooks.onAsk).refusal(
                    MCPGrantAuthority.decide(standing, note: nil, rung: .read, consumes: true), .note,
                    standing: standing, ask: nil)
            }
            // VX-256 (D-256-6, step 3): a cursor resumes ONLY the container it
            // paged — the note, or the saved version read — checked only after
            // the note is allowed (an unreachable note answered the one refusal
            // above, cursor or not) and BEFORE the once spend, so a stale cursor
            // never spends the grant. Logged refused, as the version check is.
            if let after = options.page?.after, after.containerID != (versionID ?? noteID) {
                try log(db, clientName, act, "note", noteID, title, allowed: false)
                return Outcome(text: Self.staleCursorMessage, isError: true)
            }
            if consumesOnce, let grantID { try operations.consumeMCPOnceGrant(db, grantID) }
            let text: String
            if plain {
                text = try Queries.renderedText(db, containerID: noteID)
            } else if let versionID {
                if withIDs {
                    // Ladder round 1, F-3: the REAL standing rides in (with
                    // `versionOf`), so lineage far sides the client can read
                    // — above all the live note whose grant authorized this
                    // call — address honestly instead of wearing the
                    // beyond-grant stub; the `books` answer stays suppressed
                    // (a moment is membered nowhere, and the key is the live
                    // read's). U7c: the version's echoes ride INTO the read, so
                    // a page's answer budget weighs them as the wire sends them.
                    var echo = ["version_id": versionID, "version_of": noteID, "note_id": noteID]
                    if let savedAt = try String.fetchOne(
                        db, sql: "SELECT created_at FROM container WHERE id = ?", arguments: [versionID]) {
                        echo["saved_at"] = savedAt
                    }
                    text = try encode(try MCPNoteStructure.read(
                        db, noteID: versionID, calendar: calendar, standing: standing,
                        options: MCPNoteStructure.Options(
                            withCommits: options.withCommits, commitIDs: options.commitIDs,
                            includeArchived: options.includeArchived, withLineage: options.withLineage,
                            now: options.now, idsOnly: options.idsOnly, page: options.page),
                        versionOf: noteID, echo: echo))
                } else {
                    text = try Queries.variorumDocumentText(db, postID: versionID)
                }
            } else if withIDs {
                text = try encode(try MCPNoteStructure.read(
                    db, noteID: noteID, calendar: calendar, standing: standing, options: options))
            } else {
                text = try Queries.variorumDocumentText(db, postID: noteID, throughLens: lensID)
            }
            try log(db, clientName, act, "note", noteID, title, allowed: true)
            // VX-827 U2 — VX-815: a TEXT form (the Level 0 document, the plain
            // export, a saved version's text) of a note INSIDE reach that holds
            // nothing answers the one sentence saying so — never the empty
            // string, the core's tolerant read of a note that does not exist (the
            // nothing-shape). Only this allowed road reaches here: the fence's one
            // refusal above is untouched. The JSON forms already say it
            // (`blocks: []` beside the title).
            if plain || !withIDs, Self.holdsNothing(text) {
                return Outcome(
                    text: versionID == nil
                        ? Self.emptyNoteWords(title: title ?? "") : Self.emptyVersionWords(title: title ?? ""),
                    isError: false)
            }
            return Outcome(text: text, isError: false)
        }
    }

    /// VX-815: a text form holds NOTHING when it is empty or only the line
    /// breaks the format puts between blocks (a note of blank blocks) — a
    /// header (`{t:…}`, `{#…}`) or any other character is something.
    static func holdsNothing(_ text: String) -> Bool {
        text.allSatisfy(\.isNewline)
    }

    /// VX-815 — the empty note's one sentence, naming it (PROVISIONAL wording,
    /// QUESTIONS #264 — hers to re-cut).
    static func emptyNoteWords(title: String) -> String {
        "\u{201C}\(title)\u{201D} is an empty note \u{2014} nothing is written in it yet."
    }

    /// …and a saved version's (read by `version_id` in the text form) —
    /// PROVISIONAL, #264.
    static func emptyVersionWords(title: String) -> String {
        "This saved version of \u{201C}\(title)\u{201D} is empty \u{2014} nothing was written in it."
    }

    // MARK: - list_note_lineage (VX-827 U1 — VX-817)

    /// **A note's lineage peers on the wire** (P-U1-a…g, the U1 ADJUDICATION):
    /// `Queries.lineagePeers` — one hop at the block level, both ends live and
    /// placed, notes only, saved versions out — with the SUBJECT decided at
    /// READ by the one rule (`read_note`'s decision, its ask and its once
    /// spend, in one write transaction) and each PEER kept only where the
    /// same rule reads it (`consumes: false` — `MCPNoteStructure.farSides`'
    /// precedent: a peer never spends a grant). A peer beyond reach is simply
    /// ABSENT — never counted, never stubbed (her VX-817 fence line; R-825) —
    /// and `beyond_reach` says so, always present. An archived peer is listed,
    /// marked (PROVISIONAL, #264). No edge id and no position key crosses.
    ///
    /// `note_ids` (1–200, no repeats, exclusive with `note_id` — VX-812's
    /// idiom): each item is the single call — its own decision, ask, once
    /// spend and Activity line, in its own transaction (a once grant covers
    /// ONE item, P-809-12) — answered in order (the single answer, or
    /// `{note_id, refused}` with the single call's words), with
    /// `landed_count` / `refused_count`; a call where every item refused is an
    /// error answer. Each item ∝ its note's placed blocks and their direct
    /// edges plus its peers' facts — never the corpus.
    private func listNoteLineage(_ args: [String: Value], clientName: String) throws -> Outcome {
        guard let value = args["note_ids"], value != .null else {
            return try noteLineage(try requiredString(args, "note_id"), clientName: clientName)
        }
        if let single = args["note_id"], single != .null {
            throw ArgumentFailure(message: "Pass note_id or note_ids, not both.")
        }
        guard let items = value.arrayValue else { throw ArgumentFailure(message: "note_ids must be an array.") }
        let ids = try items.map { item -> String in
            guard let id = item.stringValue else { throw ArgumentFailure(message: "note_ids must hold strings.") }
            return id
        }
        guard !ids.isEmpty else { throw ArgumentFailure(message: "note_ids lists no note.") }
        guard ids.count <= MCPWriteTools.listCap else {
            throw ArgumentFailure(message: MCPWriteTools.listCapWords(ids.count))
        }
        guard Set(ids).count == ids.count else { throw ArgumentFailure(message: "note_ids lists a note twice.") }
        var results: [Any] = []
        var landed = 0
        for id in ids {
            let one: Outcome
            do {
                one = try noteLineage(id, clientName: clientName)
            } catch {
                // An item's unexpected failure is THAT item's refusal, in the
                // one chain's words (VX-369) — the rest still run (VX-812).
                one = Outcome(
                    text: MCPWireRefusalCopy.unexpected(
                        error, tool: MCPToolCatalog.listNoteLineage.name, appWords: hooks.refusalWords),
                    isError: true)
            }
            if one.isError {
                results.append(["note_id": id, "refused": one.text] as [String: Any])
            } else {
                landed += 1
                results.append(try JSONSerialization.jsonObject(with: Data(one.text.utf8)))
            }
        }
        let answer: [String: Any] = ["results": results, "landed_count": landed, "refused_count": ids.count - landed]
        return Outcome(text: try encode(answer), isError: landed == 0)
    }

    /// ONE subject's answer — the single call.
    private func noteLineage(_ noteID: String, clientName: String) throws -> Outcome {
        let act = MCPToolCatalog.listNoteLineage.name
        return try database.write { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            let facts = try Queries.mcpNoteFacts(db, noteID: noteID)
            let decision = MCPGrantAuthority.decide(standing, note: facts, rung: .read, consumes: true)
            let title = facts == nil ? nil : try Queries.mcpScopeTitle(db, kind: .note, id: noteID, calendar: calendar)
            guard case .allow(let grantID, let consumesOnce) = decision else {
                try log(db, clientName, act, "note", noteID, title, allowed: false)
                let ask = facts.map { facts in
                    MCPAsk(clientName: clientName, scopeKind: .note, scopeID: noteID, title: title ?? "",
                           rung: .read, fence: facts.fence)
                }
                return MCPAsking(onAsk: hooks.onAsk).refusal(decision, .note, standing: standing, ask: ask)
            }
            if consumesOnce, let grantID { try operations.consumeMCPOnceGrant(db, grantID) }
            let peers = try Queries.lineagePeers(db, noteID: noteID)
            let peerFacts = try Queries.mcpNoteFacts(db, noteIDs: peers.map(\.noteID))
            var copies: [[String: Any]] = [], originals: [[String: Any]] = [], versions: [[String: Any]] = []
            for peer in peers {
                guard let facts = peerFacts[peer.noteID], MCPGrantAuthority.decide(
                    standing, note: facts, rung: .read, consumes: false).isAllowed
                else { continue }  // beyond reach: absent, never counted (VX-817's line)
                let peerTitle = try Queries.mcpScopeTitle(db, kind: .note, id: peer.noteID, calendar: calendar) ?? ""
                func entry(_ relation: Queries.LineageLink.Relation) -> [String: Any]? {
                    let links = peer.links.filter { $0.relation == relation }
                    guard !links.isEmpty else { return nil }
                    return [
                        "note_id": peer.noteID, "title": peerTitle, "wing_id": facts.wingID,
                        "archived": peer.archivedAt != nil,
                        "links": links.map { link -> [String: Any] in
                            var said: [String: Any] = [
                                "block_id": link.blockID, "peer_block_id": link.peerBlockID, "at": link.at,
                            ]
                            if let op = link.originOp { said["origin_op"] = op }
                            return said
                        },
                    ]
                }
                if let copy = entry(.derivedInto) { copies.append(copy) }
                if let original = entry(.derivedFrom) { originals.append(original) }
                if let version = entry(.versionOf) { versions.append(version) }
            }
            let answer: [String: Any] = [
                "note_id": noteID, "title": title ?? "", "copies": copies, "originals": originals,
                "versions": versions,
                MCPWriteTools.beyondReachKey: MCPWriteTools.beyondReachNotesListedWords,
            ]
            try log(db, clientName, act, "note", noteID, title, allowed: true)
            return Outcome(text: try encode(answer), isError: false)
        }
    }

    // MARK: - list_books

    private func listBooks(_ args: [String: Value], clientName: String) throws -> Outcome {
        // U4 (AF-11 F-4): the archived facet's wire form — an ARCHIVED book
        // is out of the listing unless asked (the app's resting posture: out
        // of the Bookcase, listed under Archived). Presentation, never reach:
        // an archived book answers under its grant by id whatever this says.
        let includeArchived = try optionalBool(args, "include_archived") ?? false
        // F3: the whole answer from one read snapshot; the log in its own
        // short write after.
        let outcome: Outcome = try database.read { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            guard standing.state == .approved else {
                return refusal(MCPGrantAuthority.decide(standing, note: nil, rung: .read, consumes: false), .book)
            }
            let live = standing.liveGrants
            // VX-549: a gathering granted on its own lists too (its id rides
            // the prefilter beside the books'; the rule decides each by kind).
            let bookIDs = live.filter { $0.scopeKind == .book || $0.scopeKind == .gathering }.map(\.scopeID)
            let wingIDs = live.filter { $0.scopeKind == .wing }.map(\.scopeID)
            // 13n-c VX-273: a wing's GATHERINGS list beside its books under
            // wing-level reach — and since VX-549 a gathering under its own
            // grant (`decideGathering`, each one).
            let rows = try Row.fetchAll(
                db,
                sql: """
                    SELECT r.id, r.name, r.kind, r.archived_at IS NOT NULL AS archived,
                           \(Self.resolvedWing("r.wing_id")) AS wing
                    FROM reading r
                    WHERE r.deleted_at IS NULL AND r.kind IN ('book', 'gathering')
                      AND (:archived OR r.archived_at IS NULL)
                      AND (:all OR r.id IN (SELECT value FROM json_each(:books))
                           OR \(Self.resolvedWing("r.wing_id")) IN (SELECT value FROM json_each(:wings)))
                    ORDER BY r.name COLLATE NOCASE, r.id
                    """,
                arguments: ["all": standing.openBook, "books": try json(bookIDs), "wings": try json(wingIDs),
                            "archived": includeArchived])
            var books: [[String: Any]] = []
            for row in rows {
                let id: String = row["id"]
                if (row["kind"] as String) == ReadingKind.gathering.rawValue {
                    if let entry = try gatheringEntry(db, row, standing: standing) { books.append(entry) }
                    continue
                }
                let decision = MCPGrantAuthority.decide(
                    standing, book: try Queries.mcpBookFacts(db, readingID: id), rung: .read)
                guard decision.isAllowed else { continue }
                let wing: String = row["wing"]
                // Round 1 F2: the count IS what list_notes(book_id:) would
                // emit — the same member rows, the same facts, the same rule
                // (a fenced member never lists, so it never counts; counting
                // it would disclose a hidden member's existence ambient and
                // break honest counts both ways). Never a parallel SQL fence
                // that could drift from mcpNoteFacts. Cost ∝ the book.
                let memberIDs = try String.fetchAll(
                    db,
                    sql: """
                        SELECT c.id FROM reading_post rp JOIN container c ON c.id = rp.post_id
                        WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                          AND c.deleted_at IS NULL AND c.kind = 'post'
                          AND (? OR c.archived_at IS NULL)
                        """,
                    arguments: [id, includeArchived])
                let memberFacts = try Queries.mcpNoteFacts(db, noteIDs: memberIDs)
                let readable = memberIDs.count { memberID in
                    MCPGrantAuthority.decide(
                        standing, note: memberFacts[memberID], rung: .read, consumes: false
                    ).isAllowed
                }
                var entry: [String: Any] = [
                    "id": id, "name": row["name"] as String, "kind": "book", "archived": row["archived"] as Bool,
                    "wing": try Queries.mcpScopeTitle(db, kind: .wing, id: wing) ?? Queries.mcpHomeWingName,
                    "wing_id": wing,
                    "notes": readable,
                ]
                // U4 (R-13nb-26 f): what the book collects and how it stands —
                // readable books only (this loop's own decision above).
                for (key, value) in try MCPBookFacts.facts(db, readingID: id) { entry[key] = value }
                books.append(entry)
            }
            return Outcome(text: try encode(["books": books]), isError: false)
        }
        try logAfter(clientName, MCPToolCatalog.listBooks.name, nil, nil, allowed: !outcome.isError)
        return outcome
    }

    /// **A gathering's `list_books` entry** (13n-c VX-273): listed only when
    /// the rule's `decideGathering` reaches it (wing-level reach on its wing,
    /// or since VX-549 its own grant);
    /// `notes` counts exactly what `list_notes(book_id:)` would emit — its
    /// assembly (the ONE membership function, through `assembleReading`)
    /// filtered note by note through the same rule (a fenced member never
    /// lists, so it never counts); its `rule` is how it gathers. Cost ∝ the
    /// gathering's assembly — the Bookcase's own gathering counts' class.
    private func gatheringEntry(
        _ db: Database, _ row: Row, standing: MCPGrantAuthority.Standing
    ) throws -> [String: Any]? {
        let id: String = row["id"]
        guard let facts = try Queries.mcpGatheringFacts(db, readingID: id),
              MCPGrantAuthority.decide(standing, gathering: facts).isAllowed
        else { return nil }
        let readable = try Self.readableGatheringNoteCount(db, gatheringID: id, standing: standing)
        var entry: [String: Any] = [
            "id": id, "name": row["name"] as String, "kind": "gathering", "archived": row["archived"] as Bool,
            "wing": try Queries.mcpScopeTitle(db, kind: .wing, id: facts.wingID) ?? Queries.mcpHomeWingName,
            "wing_id": facts.wingID,
            "notes": readable,
        ]
        let bookFacts = try MCPBookFacts.facts(db, readingID: id)
        // VX-813: a gathering's order too (set_book_order sets it on one).
        for key in ["rule", "rule_unreadable", "order"] { entry[key] = bookFacts[key] }
        return entry
    }

    /// **A gathering's `notes` as `list_books` counts it** — its assembly (the
    /// ONE membership function, through `assembleReading`) filtered note by
    /// note through the one rule at read (a fenced member never counts). The
    /// one count, shared since VX-769 by `create_gathering`'s answer, so the
    /// mint's number is the resting listing's, never a second rule. ∝ the
    /// gathering's assembly.
    static func readableGatheringNoteCount(
        _ db: Database, gatheringID: String, standing: MCPGrantAuthority.Standing
    ) throws -> Int {
        let memberIDs = try Queries.assembleReading(db, readingID: gatheringID).map(\.postID)
        let memberFacts = try Queries.mcpNoteFacts(db, noteIDs: memberIDs)
        return memberIDs.count { memberID in
            MCPGrantAuthority.decide(standing, note: memberFacts[memberID], rung: .read, consumes: false).isAllowed
        }
    }

    // MARK: - list_wings (VX-392 — VX-348 U5, her ruling R-VX348-5)

    /// **The wings this client holds a grant on** — the one listing that can
    /// name a wing holding nothing (an empty wing lists no note and no book,
    /// so before this a client granted one could never learn its id, and so
    /// never make its first write there).
    ///
    /// The answer's whole domain is the client's OWN live grants of wing scope
    /// — once grants included, since a listing never spends one and an
    /// unlisted once wing grant could never be used (PROVISIONAL P-VX392-2) —
    /// so no oracle arises: a wing it holds no grant on is simply absent, a
    /// gone wing too (its title no longer resolves), and the open book, which
    /// is no grant on any wing, lists none (P-VX392-3). Each wing says its
    /// rungs and the duration of the grant giving them, read OFF `decideWing`
    /// (the grant `create_note` / `create_book` would use — never a parallel
    /// rule), every live grant it holds there, and its contents counted
    /// EXACTLY as `list_notes(wing_id:)` and `list_books` would list them at
    /// rest — each note and book through the ONE rule, so a fenced one never
    /// counts (counting it would disclose it — Round 1 F2's rule), nothing
    /// archived either.
    ///
    /// F3's shape: one read snapshot, then the activity line in its own short
    /// write. P1: ∝ the GRANTED wings — the readings of each (shelf-scale) and
    /// each one's own notes' facts, batched; the wing filter rides
    /// `container`'s scan as `list_notes(wing_id:)`'s does (no wing index
    /// exists, and one would be synced-schema DDL). Never the other wings'
    /// notes' facts, never the corpus's.
    private func listWings(clientName: String) throws -> Outcome {
        let outcome: Outcome = try database.read { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            guard standing.state == .approved else {
                return refusal(MCPGrantAuthority.decide(standing, note: nil, rung: .read, consumes: false), .wing)
            }
            let byWing = Dictionary(grouping: standing.liveGrants.filter { $0.scopeKind == .wing }, by: \.scopeID)
            // Home first (virtual — never gone), then the switcher's order; a
            // wing deleted since its grant is absent.
            let additional = try String.fetchAll(
                db,
                sql: """
                    SELECT id FROM wing WHERE deleted_at IS NULL AND id IN (SELECT value FROM json_each(?))
                    ORDER BY position, id
                    """,
                arguments: [try json(byWing.keys.filter { !$0.isEmpty }.sorted())])
            var wings: [[String: Any]] = []
            for wingID in (byWing[""] == nil ? [] : [""]) + additional {
                guard let grants = byWing[wingID], let highest = grants.map(\.rung).max(),
                      let name = try Queries.mcpScopeTitle(db, kind: .wing, id: wingID, calendar: calendar)
                else { continue }
                // The grant the rule itself would use at the top rung.
                let giving: MCPGrantRule.Grant? =
                    if case .allow(let grantID, _) = MCPGrantAuthority.decideWing(standing, wingID: wingID, rung: highest) {
                        standing.grant(id: grantID)
                    } else { nil }
                let strongestFirst = grants.sorted {
                    ($0.rung, Self.durationWeight($0.duration), $1.id) > ($1.rung, Self.durationWeight($1.duration), $0.id)
                }
                var entry: [String: Any] = [
                    "wing_id": wingID, "name": name,
                    "rungs": MCPGrantRule.Rung.allCases.filter { $0 <= highest }.map(\.rawValue),
                    "duration": Self.durationWord((giving ?? strongestFirst[0]).duration),
                    "grants": strongestFirst.map { ["rung": $0.rung.rawValue, "duration": Self.durationWord($0.duration)] },
                    "notes": try readableNoteCount(db, wingID: wingID, standing: standing),
                ]
                let (books, gatherings) = try readableReadingCounts(db, wingID: wingID, standing: standing)
                entry["books"] = books
                entry["gatherings"] = gatherings
                wings.append(entry)
            }
            return Outcome(text: try encode(["wings": wings]), isError: false)
        }
        try logAfter(clientName, MCPToolCatalog.listWings.name, nil, nil, allowed: !outcome.isError)
        return outcome
    }

    /// A grant's duration on the wire (PROVISIONAL P-VX392-4 — the advice's
    /// own "until you disconnect", as a token).
    static func durationWord(_ duration: MCPGrantRule.Duration) -> String {
        switch duration {
        case .once: "once"
        case .connection: "until_disconnect"
        case .always: "always"
        }
    }

    private static func durationWeight(_ duration: MCPGrantRule.Duration) -> Int {
        switch duration {
        case .once: 0
        case .connection: 1
        case .always: 2
        }
    }

    /// How many notes `list_notes(wing_id:)` would list in the wing at rest:
    /// its living notes (no archived one, no saved version, no scraps), each
    /// through the ONE rule (`decide`) on its batched facts. ∝ the wing's own
    /// notes.
    private func readableNoteCount(
        _ db: Database, wingID: String, standing: MCPGrantAuthority.Standing
    ) throws -> Int {
        let scope = Queries.wingScope(column: "c.wing_id", wingID: wingID)
        let ids = try String.fetchAll(
            db,
            sql: """
                SELECT c.id FROM container c
                WHERE c.deleted_at IS NULL AND c.kind = 'post' AND c.archived_at IS NULL AND \(scope.sql)
                """,
            arguments: StatementArguments(scope.arguments))
        var readable = 0
        var start = 0
        while start < ids.count {
            let chunk = Array(ids[start..<min(start + 500, ids.count)])
            let facts = try Queries.mcpNoteFacts(db, noteIDs: chunk)
            readable += chunk.count { id in
                MCPGrantAuthority.decide(standing, note: facts[id], rung: .read, consumes: false).isAllowed
            }
            start += chunk.count
        }
        return readable
    }

    /// How many books and gatherings `list_books` would list in the wing at
    /// rest (no archived one), each decided as it decides them — a book
    /// through `decide`, a gathering through `decideGathering`; a fenced one
    /// never counts. ∝ the wing's readings (shelf-scale).
    private func readableReadingCounts(
        _ db: Database, wingID: String, standing: MCPGrantAuthority.Standing
    ) throws -> (books: Int, gatherings: Int) {
        var books = 0, gatherings = 0
        for row in try Row.fetchAll(
            db,
            sql: """
                SELECT r.id, r.kind FROM reading r
                WHERE r.deleted_at IS NULL AND r.kind IN ('book', 'gathering') AND r.archived_at IS NULL
                  AND \(Self.resolvedWing("r.wing_id")) = ?
                """,
            arguments: [wingID]) {
            let id: String = row["id"]
            if (row["kind"] as String) == ReadingKind.gathering.rawValue {
                if MCPGrantAuthority.decide(standing, gathering: try Queries.mcpGatheringFacts(db, readingID: id))
                    .isAllowed { gatherings += 1 }
            } else if MCPGrantAuthority.decide(
                standing, book: try Queries.mcpBookFacts(db, readingID: id), rung: .read).isAllowed {
                books += 1
            }
        }
        return (books, gatherings)
    }

    // MARK: - list_notes

    private func listNotes(_ args: [String: Value], clientName: String) throws -> Outcome {
        let limit = min(max(try optionalInt(args, "limit") ?? Self.defaultPageSize, 1), Self.maxPageSize)
        let cursor = try optionalString(args, "cursor").flatMap(PageCursor.init(encoded:))
        if try optionalString(args, "cursor") != nil, cursor == nil {
            throw ArgumentFailure(message: Self.staleCursorMessage)
        }
        let bookID = try optionalString(args, "book_id")
        let wingID = try optionalString(args, "wing_id")
        guard bookID == nil || wingID == nil else {
            throw ArgumentFailure(message: "Pass book_id or wing_id, not both.")
        }
        // U4 (AF-11 F-4): archived notes join only when asked — the facet's
        // resting posture on every listing, a book's archived members
        // included (her Index never shows them; her archived line does).
        let includeArchived = try optionalBool(args, "include_archived") ?? false
        // Round 1 F5: a cursor resumes only the listing ORDER that minted it
        // — book order's key is a position, the recency listings' a stamp;
        // crossed, the keyset comparison pages garbage. Same words as an
        // undecodable cursor.
        // 13n-c VX-273: a book id may name a GATHERING, whose order is its
        // assembly's — its own cursor shape, checked once the place is known.
        if let cursor, (bookID != nil) == (cursor.shape == .recency) {
            throw ArgumentFailure(message: Self.staleCursorMessage)
        }
        // VX-827 U2 — VX-810: `tag`, a PATH in every tag tool's form (`remove_tag`'s
        // parse and words), parsed before any target is read (no oracle).
        let tagPath = try optionalTagPath(args)
        let act = MCPToolCatalog.listNotes.name
        // F3: one read snapshot; the log in its own short write after.
        let outcome: Outcome = try database.read { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            // VX-825 (her R-825): the page is decided over READABLE rows only.
            // `fetch` reads one raw page after a cursor (nil = a stale gathering
            // cursor); the walk below keeps the rows this client can read, until
            // `limit` are kept or the order runs out — so a hidden row never
            // shortens a page, and `next_cursor` names the last KEPT row (before
            // VX-825 it named the last RAW row, a hidden note's id among them).
            let fetch: (PageCursor?) throws -> [PageRow]?
            // VX-184 U5 (P-VX196-5): a BOOK's chapters, in order — so a chapter
            // with no notes filed is addressable too (the chapter acts).
            var chapters: [[String: Any]]?
            var gatheringOrdinal: Int?
            // VX-810: the tag's wearers in the listing's own wing (nil: every
            // wing — the bare form lists across wings), read only once the place
            // is allowed; nil = no filter. Every wearer still passes the per-note
            // rule below, so a hidden wearer is absent exactly as unfiltered.
            func wearers(inWing wing: String?) throws -> [String]? {
                try tagPath.map { try Queries.notesWearingTag(db, path: $0, wingID: wing) }
            }
            if let bookID {
                let place = try MCPGrantAuthority.readPlace(db, readingID: bookID)
                let decision = MCPGrantAuthority.decide(standing, reading: place)
                guard decision.isAllowed else { return refusal(decision, .book) }
                let tagged = try wearers(inWing: place.facts?.wingID)
                switch place {
                case .book:
                    if let cursor, cursor.shape != .book {
                        return Outcome(text: Self.staleCursorMessage, isError: true)
                    }
                    fetch = { after in
                        try bookPage(
                            db, bookID: bookID, includeArchived: includeArchived, tagged: tagged, after: after,
                            limit: limit)
                    }
                    chapters = try Row.fetchAll(
                        db,
                        sql: """
                            SELECT id, name FROM reading_section WHERE reading_id = ? AND deleted_at IS NULL
                            ORDER BY position, id
                            """,
                        arguments: [bookID]
                    ).map { ["section_id": $0["id"] as String, "name": $0["name"] as String] }
                case .gathering:
                    if let cursor, cursor.shape != .gathering {
                        return Outcome(text: Self.staleCursorMessage, isError: true)
                    }
                    fetch = { after in
                        try gatheringPage(db, gatheringID: bookID, tagged: tagged, after: after, limit: limit)
                    }
                    // A gathering cursor resumes by its note's id; its key is the
                    // READABLE ordinal (VX-825 — it was the assembly index, which
                    // counted the hidden notes before it).
                    gatheringOrdinal = cursor.flatMap { Int($0.key) }.map { $0 + 1 } ?? 0
                }
            } else if let wingID {
                let decision = MCPGrantAuthority.decideWing(standing, wingID: wingID, rung: .read)
                guard decision.isAllowed else { return refusal(decision, .wing) }
                let tagged = try wearers(inWing: wingID)
                fetch = { after in
                    try recencyPage(
                        db, wingID: wingID, candidates: tagged, includeArchived: includeArchived, after: after,
                        limit: limit)
                }
            } else {
                guard standing.state == .approved else {
                    return refusal(MCPGrantAuthority.decide(standing, note: nil, rung: .read, consumes: false), .note)
                }
                if let tagged = try wearers(inWing: nil) {
                    // VX-810: the wearers ARE the candidates — every note the
                    // rule reads is in the shared listing's sources, so the
                    // readable wearers are exactly its notes wearing the tag
                    // (∝ the wearers, never the reached wings' notes).
                    fetch = { after in
                        try recencyPage(
                            db, wingID: nil, candidates: tagged, includeArchived: includeArchived, after: after,
                            limit: limit)
                    }
                } else {
                    fetch = { after in
                        try sharedPage(db, standing: standing, includeArchived: includeArchived, after: after, limit: limit)
                    }
                }
            }
            var kept: [(row: PageRow, facts: MCPGrantRule.NoteFacts)] = []
            var after = cursor
            walk: while true {
                guard let raw = try fetch(after) else { return Outcome(text: Self.staleCursorMessage, isError: true) }
                let facts = try Queries.mcpNoteFacts(db, noteIDs: raw.map(\.id))
                for row in raw {
                    let decision = MCPGrantAuthority.decide(standing, note: facts[row.id], rung: .read, consumes: false)
                    guard decision.isAllowed, let noteFacts = facts[row.id] else { continue }
                    kept.append((row, noteFacts))
                    if kept.count == limit { break walk }
                }
                guard raw.count == limit, let last = raw.last else { break }
                after = last.cursor
            }
            // VX-825 (her R-825): a note's `book_ids` are the books THIS client
            // can read — an unreadable book's id never crosses (it did, every
            // listed note carried every live book holding it).
            var readableBook: [String: Bool] = [:]
            func readsBook(_ id: String) throws -> Bool {
                if let known = readableBook[id] { return known }
                let reads = MCPGrantAuthority.decide(
                    standing, book: try Queries.mcpBookFacts(db, readingID: id), rung: .read).isAllowed
                readableBook[id] = reads
                return reads
            }
            // VX-827 U2 — VX-810: each row says the tags the note ITSELF wears
            // (`tag_ids` + `tags`, the header's — the mint answers' pairing) and
            // its `entry_date` (null when undated — the VX-758 rider). ∝ the page.
            let worn = try Queries.wornTags(db, noteIDs: kept.map(\.row.id))
            var notes: [[String: Any]] = []
            for (row, noteFacts) in kept {
                let tags = worn[row.id] ?? []
                var note: [String: Any] = [
                    "id": row.id, "title": row.title, "edited": row.touched,
                    "book_ids": try noteFacts.bookIDs.sorted().filter(readsBook), "wing_id": noteFacts.wingID,
                    "entry_date": row.entryDate.flatMap { $0.isEmpty ? nil : $0 } ?? NSNull(),
                    "tag_ids": tags.map(\.id), "tags": tags.map(\.path),
                ]
                if let section = row.section {
                    note["section_id"] = section.id
                    note["section_name"] = section.name
                }
                if row.archived { note["archived"] = true }
                notes.append(note)
            }
            var answer: [String: Any] = ["notes": notes]
            if let chapters { answer["chapters"] = chapters }
            if kept.count == limit, let last = kept.last?.row {
                let resume = gatheringOrdinal.map {
                    PageCursor(shape: .gathering, key: String($0 + kept.count - 1), id: last.id)
                } ?? last.cursor
                answer["next_cursor"] = resume.encoded
            }
            return Outcome(text: try encode(answer), isError: false)
        }
        try logAfter(clientName, act, bookID != nil ? "book" : (wingID != nil ? "wing" : nil),
                     bookID ?? wingID, allowed: !outcome.isError)
        return outcome
    }

    /// One listed note before the rule's per-note pass.
    private struct PageRow {
        let id: String
        let title: String
        let touched: String
        let cursor: PageCursor
        /// U3 (R-13nb-11 G-1): the chapter this note is filed under in the
        /// LISTED book (book-order listings only; a dangling pointer reads
        /// unsectioned).
        var section: (id: String, name: String)? = nil
        /// U4: an archived note (listed only under `include_archived`).
        var archived = false
        /// VX-810 (the VX-758 rider): the note's stored day, nil when undated.
        var entryDate: String? = nil
    }

    /// A book's live member notes in book order, keyset-paged on
    /// `(position, post id)` — ∝ the page. VX-810: `tagged` (non-nil) keeps
    /// only those members (the tag's wearers) — still the book's order and
    /// its cursor, the walk ∝ the book's members.
    private func bookPage(
        _ db: Database, bookID: String, includeArchived: Bool, tagged: [String]? = nil,
        after cursor: PageCursor?, limit: Int
    ) throws -> [PageRow] {
        try Row.fetchAll(
            db,
            sql: """
                SELECT c.id, c.title, c.entry_date, c.created_at, c.archived_at IS NOT NULL AS archived,
                       COALESCE(c.last_touched_at, c.created_at) AS touched, rp.position,
                       s.id AS section_id, s.name AS section_name
                FROM reading_post rp JOIN container c ON c.id = rp.post_id
                LEFT JOIN reading_section s
                  ON s.id = rp.section_id AND s.deleted_at IS NULL AND s.reading_id = rp.reading_id
                WHERE rp.reading_id = :book AND rp.deleted_at IS NULL AND rp.status = 'member'
                  AND c.deleted_at IS NULL AND c.kind = 'post'
                  AND (:archived OR c.archived_at IS NULL)
                  AND (:after IS NULL OR (rp.position, c.id) > (:after, :afterID))
                  AND (:tagged IS NULL OR c.id IN (SELECT value FROM json_each(:tagged)))
                ORDER BY rp.position, c.id
                LIMIT :limit
                """,
            arguments: ["book": bookID, "after": cursor?.key, "afterID": cursor?.id ?? "", "limit": limit,
                        "archived": includeArchived, "tagged": try tagged.map(json)]
        ).map { row in
            PageRow(id: row["id"], title: displayTitle(row), touched: row["touched"],
                    cursor: PageCursor(shape: .book, key: row["position"], id: row["id"]),
                    section: (row["section_id"] as String?).map { ($0, row["section_name"] as String) },
                    archived: row["archived"], entryDate: row["entry_date"])
        }
    }

    /// **A GATHERING's notes in its own order** (13n-c VX-273): its assembly
    /// (`assembleReading` — the ONE membership function; living notes only,
    /// so `include_archived` has nothing to add), resumed after the cursor's
    /// note. nil when that note is no longer in the assembly (it moved under
    /// the cursor — the listing starts again). Cost ∝ the gathering's
    /// assembly, then the page.
    private func gatheringPage(
        _ db: Database, gatheringID: String, tagged: [String]? = nil, after cursor: PageCursor?, limit: Int
    ) throws -> [PageRow]? {
        var entries = try Queries.assembleReading(db, readingID: gatheringID)
        // VX-810: only the assembly's notes wearing the tag, in its own order.
        if let tagged {
            let wearing = Set(tagged)
            entries = entries.filter { wearing.contains($0.postID) }
        }
        var start = 0
        if let cursor {
            guard let index = entries.firstIndex(where: { $0.postID == cursor.id }) else { return nil }
            start = index + 1
        }
        let slice = Array(entries.dropFirst(start).prefix(limit))
        var touched: [String: String] = [:]
        for row in try Row.fetchAll(
            db,
            sql: """
                SELECT c.id, COALESCE(c.last_touched_at, c.created_at) AS touched
                FROM json_each(?) j JOIN container c ON c.id = j.value
                """,
            arguments: [try json(slice.map(\.postID))]) {
            touched[row["id"]] = row["touched"]
        }
        return slice.enumerated().map { offset, entry in
            PageRow(
                id: entry.postID,
                title: DisplayTitle.note(
                    title: entry.title, entryDate: entry.entryDate, createdAt: entry.createdAt, calendar: calendar),
                touched: touched[entry.postID] ?? "",
                cursor: PageCursor(shape: .gathering, key: String(start + offset), id: entry.postID),
                entryDate: entry.entryDate)
        }
    }

    /// Living (unarchived) notes by recency, keyset-paged on `(touched, id)`:
    /// a whole wing through the recency index, or — when `candidates` is
    /// given — only those ids (cost ∝ the candidates, never the corpus).
    private func recencyPage(
        _ db: Database, wingID: String?, candidates: [String]?, includeArchived: Bool = false,
        after cursor: PageCursor?, limit: Int
    ) throws -> [PageRow] {
        var clauses: [String] = [
            "c.deleted_at IS NULL", "c.kind = 'post'",
            "(:after IS NULL OR (COALESCE(c.last_touched_at, c.created_at), c.id) < (:after, :afterID))",
        ]
        // The living corpus by default; U4's `include_archived` lifts the
        // archive fence — never the version fence (a saved version is born
        // archived, `archived_at = created_at`, and lists under no facet).
        clauses.append(includeArchived
            ? "NOT (c.archived_at IS NOT NULL AND c.archived_at = c.created_at)"
            : "c.archived_at IS NULL")
        var arguments: [String: (any DatabaseValueConvertible)?] = [
            "after": cursor?.key, "afterID": cursor?.id ?? "", "limit": limit,
        ]
        if let wingID {
            let scope = Queries.wingScope(column: "c.wing_id", wingID: wingID)
            let fragment = scope.sql.replacingOccurrences(of: "?", with: ":wing")
            clauses.append(fragment)
            if fragment.contains(":wing") { arguments["wing"] = wingID }
        }
        let source: String
        if let candidates {
            source = "json_each(:candidates) j JOIN container c ON c.id = j.value"
            arguments["candidates"] = try json(candidates)
        } else {
            source = "container c"
        }
        return try Row.fetchAll(
            db,
            sql: """
                SELECT c.id, c.title, c.entry_date, c.created_at, c.archived_at IS NOT NULL AS archived,
                       COALESCE(c.last_touched_at, c.created_at) AS touched
                FROM \(source)
                WHERE \(clauses.joined(separator: " AND "))
                ORDER BY touched DESC, c.id DESC
                LIMIT :limit
                """,
            arguments: StatementArguments(arguments)
        ).map { row in
            PageRow(id: row["id"], title: displayTitle(row), touched: row["touched"],
                    cursor: PageCursor(shape: .recency, key: row["touched"], id: row["id"]),
                    archived: row["archived"], entryDate: row["entry_date"])
        }
    }

    /// EVERY note shared with the client: under the open book or a wing grant
    /// the reached wings' notes by recency; otherwise the grants' own
    /// candidates (shared notes + the shared books' members).
    private func sharedPage(
        _ db: Database, standing: MCPGrantAuthority.Standing, includeArchived: Bool,
        after cursor: PageCursor?, limit: Int
    ) throws -> [PageRow] {
        let live = standing.liveGrants
        if standing.openBook {
            return try recencyPage(
                db, wingID: nil, candidates: nil, includeArchived: includeArchived, after: cursor, limit: limit)
        }
        let noteIDs = live.filter { $0.scopeKind == .note }.map(\.scopeID)
        let bookIDs = live.filter { $0.scopeKind == .book }.map(\.scopeID)
        let wingIDs = Set(live.filter { $0.scopeKind == .wing }.map(\.scopeID))
        var candidates = Set(noteIDs)
        if !bookIDs.isEmpty {
            candidates.formUnion(try String.fetchAll(
                db,
                sql: """
                    SELECT rp.post_id FROM reading_post rp
                    WHERE rp.reading_id IN (SELECT value FROM json_each(?))
                      AND rp.deleted_at IS NULL AND rp.status = 'member'
                    """,
                arguments: [try json(bookIDs)]))
        }
        // VX-549: a granted gathering's notes are its ASSEMBLY now (the ONE
        // membership function, through `assembleReading` — empty while it is
        // archived or rule-less); ∝ each granted gathering's assembly. Every
        // candidate still passes the per-note rule below.
        for grant in live where grant.scopeKind == .gathering {
            candidates.formUnion(try Queries.assembleReading(db, readingID: grant.scopeID).map(\.postID))
        }
        if wingIDs.isEmpty {
            return try recencyPage(
                db, wingID: nil, candidates: candidates.sorted(), includeArchived: includeArchived,
                after: cursor, limit: limit)
        }
        // Wing-level reach: the reached wings' notes plus any candidate
        // outside them, merged by recency (each source keyset-paged by the
        // same cursor, so the merge pages exactly).
        var rows: [PageRow] = []
        for wing in wingIDs.sorted() {
            rows += try recencyPage(
                db, wingID: wing, candidates: nil, includeArchived: includeArchived, after: cursor, limit: limit)
        }
        rows += try recencyPage(
            db, wingID: nil, candidates: candidates.sorted(), includeArchived: includeArchived,
            after: cursor, limit: limit)
        var seen = Set<String>()
        return rows
            .sorted { ($0.touched, $0.id) > ($1.touched, $1.id) }
            .filter { seen.insert($0.id).inserted }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - list_my_activity (VX-261)

    /// **The client's own recent acts** (VX-336 U7 — D-261-1…7): an APPROVED
    /// client's rows logged under its name since its current approval
    /// (P-VX261-1 — `decided_at`; Deny is her "stop trusting this client" and
    /// a re-approved name starts with no reach and no history), newest first,
    /// each AS LOGGED (`MCPOwnActivity`). A pending or denied client hears its
    /// standing's own sentence (`list_books`' guard). The parse first (the
    /// cursor's decode, independent of any target), then ONE read snapshot,
    /// then the activity line in its own short write (F3) — logged like every
    /// read, target-less, and never listed in its own answer. Not a `Job`: it
    /// reads the log only, nothing of her text, so no flush; no undo. Cost ∝
    /// the page, over a table bounded by its cap.
    private func listMyActivity(_ args: [String: Value], clientName: String) throws -> Outcome {
        let limit = min(max(try optionalInt(args, "limit") ?? Self.defaultPageSize, 1), Self.maxPageSize)
        let cursor = try optionalString(args, "cursor")
        let before = cursor.flatMap(MCPOwnActivity.rowID(decoding:))
        if cursor != nil, before == nil { throw ArgumentFailure(message: Self.staleCursorMessage) }
        let includeReads = try optionalBool(args, "include_reads") ?? false
        let outcome: Outcome = try database.read { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            guard standing.state == .approved else {
                return refusal(MCPGrantAuthority.decide(standing, note: nil, rung: .read, consumes: false), .note)
            }
            // An approved client always carries its approval's stamp; without
            // one there is no era to read from — fail closed (nothing listed).
            guard let since = try Queries.mcpClient(db, name: clientName)?.decidedAt else {
                return Outcome(text: try encode(["acts": [Any]()]), isError: false)
            }
            let rows = try Queries.mcpOwnActivity(
                db, clientName: clientName, since: since, acts: MCPOwnActivity.listedActs(includeReads: includeReads),
                before: before, limit: limit + 1)
            let page = rows.prefix(limit)
            var answer: [String: Any] = ["acts": page.map(MCPOwnActivity.entry)]
            // Only while rows remain (the one extra row read says so).
            if rows.count > limit, let last = page.last { answer["next_cursor"] = MCPOwnActivity.cursor(after: last.id) }
            return Outcome(text: try encode(answer), isError: false)
        }
        try logAfter(clientName, MCPToolCatalog.listMyActivity.name, nil, nil, allowed: !outcome.isError)
        return outcome
    }

    // MARK: - search

    private func search(_ args: [String: Value], clientName: String) throws -> Outcome {
        let text = try requiredString(args, "query")
        let limit = min(max(try optionalInt(args, "limit") ?? Self.defaultSearchLimit, 1), Self.maxSearchLimit)
        let bookID = try optionalString(args, "book_id")
        let noteID = try optionalString(args, "note_id")
        // R2-2 (U1 ladder round 2, riding this touch): the pair refuses here
        // exactly as `list_notes` refuses its pair, never silently note-wins.
        guard bookID == nil || noteID == nil else {
            throw ArgumentFailure(message: "Pass book_id or note_id, not both.")
        }
        var query = SearchQueryParser.parse(text, typeAhead: false, calendar: calendar)
        guard !query.isEmpty else { throw ArgumentFailure(message: "Give search some words to look for.") }
        // U3 (R-13nb-10, her correction): the `+ commits` facet's WIRE form —
        // explicit per call, default OFF (R-VX83's letter: a savepoint never
        // lists without the facet). Its passages pass the same per-note rule
        // as every other passage (`passes`), P1 ∝ matches as ever. U1's
        // search-never-reaches-savepoints state flips here, deliberately.
        query.includesSavepoints = try optionalBool(args, "include_commits") ?? false
        // U4 (AF-11 F-4, PROVISIONAL — R-13nb-10 left the archived facet
        // UI-only and the sitting carried the inventory row): the archived
        // facet's wire form, built to the facet's letter — living AND
        // archived when asked (`includingArchived`), each passage marked.
        let includeArchived = try optionalBool(args, "include_archived") ?? false
        if includeArchived { query.visibility = .includingArchived }
        let act = MCPToolCatalog.search.name
        // F3: the whole engine runs on one read snapshot (under the open book
        // it is the heaviest call the server serves — it must never hold the
        // writer); the log lands in its own short write after.
        let outcome: Outcome = try database.read { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            var scopes: [SearchScope] = []
            if let noteID {
                let facts = try Queries.mcpNoteFacts(db, noteID: noteID)
                let decision = MCPGrantAuthority.decide(standing, note: facts, rung: .read, consumes: false)
                guard isStandingAllow(decision, standing), let facts else {
                    // R2-1 (U1 ladder round 2): the synthesized ask reads the
                    // fence — a fenced target's ask never offers "always".
                    return refusal(
                        decision.isAllowed ? .ask(.notShared, offersAlways: facts?.fence == nil) : decision, .note)
                }
                scopes = [SearchScope(wingID: facts.wingID, within: .note(id: noteID))]
            } else if let bookID {
                // 13n-c VX-273: a book OR a gathering (its own scope — the
                // search composer reads the ONE membership function).
                let place = try MCPGrantAuthority.readPlace(db, readingID: bookID)
                let facts = place.facts
                let decision = MCPGrantAuthority.decide(standing, reading: place)
                // Round 1 F1: search serves STANDING reach only — a once book
                // grant would pass the book decision and then fail every
                // passage, an eternally empty page; refuse it here instead,
                // the same rule the catalog's listing reads.
                guard isStandingAllow(decision, standing), let facts else {
                    return refusal(decision.isAllowed ? .ask(.notShared, offersAlways: true) : decision, .book)
                }
                scopes = [SearchScope(wingID: facts.wingID, within: .book(id: bookID))]
            } else {
                guard standing.state == .approved else {
                    return refusal(MCPGrantAuthority.decide(standing, note: nil, rung: .read, consumes: false), .note)
                }
                scopes = try reachedScopes(db, standing)
            }
            var passages: [[String: Any]] = []
            var truncated = false
            var seen = Set<String>()
            scopeLoop: for scope in scopes {
                let page = try Queries.searchPassages(db, query: query, scope: scope, limit: limit, calendar: calendar)
                if page.next != nil { truncated = true }
                let facts = try Queries.mcpNoteFacts(db, noteIDs: page.passages.compactMap(\.noteID))
                for passage in page.passages where seen.insert(passage.id).inserted {
                    guard try passes(db, passage, facts, standing) else { continue }
                    passages.append(encodePassage(passage))
                    if passages.count == limit { truncated = true; break scopeLoop }
                }
            }
            return Outcome(text: try encode(["passages": passages, "truncated": truncated]), isError: false)
        }
        try logAfter(clientName, act, noteID != nil ? "note" : (bookID != nil ? "book" : nil),
                     noteID ?? bookID, allowed: !outcome.isError)
        return outcome
    }

    /// Every scope the client's reach covers, wing-level first: the open
    /// book's wings (Home and every live wing) or the wing grants', then the
    /// shared books outside them, then the shared notes outside both (a once
    /// grant never feeds search — search reads words without spending it).
    private func reachedScopes(_ db: Database, _ standing: MCPGrantAuthority.Standing) throws -> [SearchScope] {
        let live = standing.searchGrants  // F1: the ONE standing-reach rule
        var wings: [String] = live.filter { $0.scopeKind == .wing }.map(\.scopeID)
        if standing.openBook {
            wings = [""] + (try String.fetchAll(db, sql: "SELECT id FROM wing WHERE deleted_at IS NULL ORDER BY position, id"))
        }
        let wingSet = Set(wings)
        var scopes = Array(Set(wings)).sorted().map { SearchScope(wingID: $0, within: .library) }
        var bookIDs: Set<String> = []
        for grant in live where grant.scopeKind == .book {
            guard let facts = try Queries.mcpBookFacts(db, readingID: grant.scopeID),
                  !wingSet.contains(facts.wingID) else { continue }
            bookIDs.insert(facts.id)
            scopes.append(SearchScope(wingID: facts.wingID, within: .book(id: facts.id)))
        }
        // VX-549: a granted gathering outside the reached wings is its own
        // scope (the search composer's `.book(id)` on a gathering reads the
        // ONE membership function); a note it assembles is then not searched
        // again on its own note grant's scope.
        var gatheringIDs: Set<String> = []
        for grant in live where grant.scopeKind == .gathering {
            guard let facts = try Queries.mcpGatheringFacts(db, readingID: grant.scopeID),
                  facts.fence == nil, !wingSet.contains(facts.wingID) else { continue }
            gatheringIDs.insert(facts.id)
            scopes.append(SearchScope(wingID: facts.wingID, within: .book(id: facts.id)))
        }
        for grant in live where grant.scopeKind == .note {
            guard let facts = try Queries.mcpNoteFacts(db, noteID: grant.scopeID),
                  !wingSet.contains(facts.wingID), facts.bookIDs.isDisjoint(with: bookIDs),
                  facts.gatheringIDs.isDisjoint(with: gatheringIDs) else { continue }
            scopes.append(SearchScope(wingID: facts.wingID, within: .note(id: facts.id)))
        }
        return scopes
    }

    /// A passage shows only when the rule allows its note (or its book, for a
    /// book or chapter name) AND the allowing grant is a standing one.
    private func passes(
        _ db: Database, _ passage: SearchPassage, _ facts: [String: MCPGrantRule.NoteFacts],
        _ standing: MCPGrantAuthority.Standing
    ) throws -> Bool {
        if let noteID = passage.noteID {
            let decision = MCPGrantAuthority.decide(standing, note: facts[noteID], rung: .read, consumes: false)
            return isStandingAllow(decision, standing)
        }
        if let readingID = passage.readingID {
            // 13n-c VX-273: a gathering's own name reads as a fact under
            // wing-level reach, as it lists.
            return MCPGrantAuthority.decide(
                standing, reading: try MCPGrantAuthority.readPlace(db, readingID: readingID)).isAllowed
        }
        return false
    }

    private func isStandingAllow(_ decision: MCPGrantRule.Decision, _ standing: MCPGrantAuthority.Standing) -> Bool {
        guard case .allow(let grantID, _) = decision else { return false }
        return standing.grant(id: grantID)?.duration != .once
    }

    private func encodePassage(_ passage: SearchPassage) -> [String: Any] {
        var entry: [String: Any] = [
            "kind": passage.kind.rawValue,
            "snippet": passage.snippet.map { $0.isMatch ? "**\($0.text)**" : $0.text }.joined(),
        ]
        if let noteID = passage.noteID {
            entry["note_id"] = noteID
            entry["note_title"] = passage.homeTitle
        }
        if let readingID = passage.readingID {
            entry["book_id"] = readingID
            entry["book_name"] = passage.homeTitle
        }
        if let blockID = passage.blockID { entry["block_id"] = blockID }
        if passage.kind == .savepoint {
            entry["commit_id"] = passage.sourceID
            if let savedAt = passage.savedAt { entry["saved_at"] = savedAt }
        }
        if passage.isArchived { entry["archived"] = true }
        return entry
    }

    // MARK: - Shared pieces

    private func refusal(_ decision: MCPGrantRule.Decision, _ target: MCPRefusalCopy.Target) -> Outcome {
        guard let reason = MCPRefusalCopy.reason(of: decision) else {
            return Outcome(text: "Not allowed.", isError: true)
        }
        return Outcome(text: MCPRefusalCopy.words(reason, target), isError: true)
    }

    private func log(
        _ db: Database, _ clientName: String, _ act: String, _ kind: String?, _ id: String?,
        _ title: String?, allowed: Bool
    ) throws {
        try operations.recordMCPActivity(
            db, clientName: clientName, act: act, targetKind: kind, targetID: id,
            targetTitle: title, allowed: allowed)
    }

    /// F3: the non-consuming tools' activity line, a short write of its own
    /// AFTER the read snapshot that built the answer (the consuming tools log
    /// inside their one write transaction — the once stamp binds them to it).
    private func logAfter(
        _ clientName: String, _ act: String, _ kind: String?, _ id: String?, allowed: Bool
    ) throws {
        try database.write { db in
            try log(db, clientName, act, kind, id, nil, allowed: allowed)
        }
    }

    private func displayTitle(_ row: Row) -> String {
        DisplayTitle.note(
            title: row["title"], entryDate: row["entry_date"], createdAt: row["created_at"], calendar: calendar)
    }

    static func resolvedWing(_ column: String) -> String {
        "CASE WHEN \(column) = '' OR \(column) NOT IN (SELECT w.id FROM wing w WHERE w.deleted_at IS NULL) "
            + "THEN '' ELSE \(column) END"
    }

    private func json(_ values: [String]) throws -> String {
        String(decoding: try JSONEncoder().encode(values), as: UTF8.self)
    }

    private func encode(_ object: [String: Any]) throws -> String {
        // U4: an answer holding a non-JSON value (a `Date`, say) would raise
        // an Objective-C exception and take the APP down — refuse it as an
        // error instead. U7c: the ONE encoding, shared with the page budget
        // that measures it (`MCPNoteStructure.answerText`).
        try MCPNoteStructure.answerText(object)
    }

    // MARK: - Arguments

    struct ArgumentFailure: Error {
        let message: String
    }

    private func requiredString(_ args: [String: Value], _ key: String) throws -> String {
        guard let value = try optionalString(args, key), !value.isEmpty else {
            throw ArgumentFailure(message: "\(key) is required.")
        }
        return value
    }

    private func optionalString(_ args: [String: Value], _ key: String) throws -> String? {
        guard let value = args[key], value != .null else { return nil }
        guard let string = value.stringValue else { throw ArgumentFailure(message: "\(key) must be a string.") }
        return string
    }

    private func optionalBool(_ args: [String: Value], _ key: String) throws -> Bool? {
        guard let value = args[key], value != .null else { return nil }
        guard let bool = value.boolValue else { throw ArgumentFailure(message: "\(key) must be true or false.") }
        return bool
    }

    private func optionalStrings(_ args: [String: Value], _ key: String) throws -> [String]? {
        guard let value = args[key], value != .null else { return nil }
        guard let items = value.arrayValue else { throw ArgumentFailure(message: "\(key) must be an array.") }
        return try items.map { item in
            guard let string = item.stringValue else { throw ArgumentFailure(message: "\(key) must hold strings.") }
            return string
        }
    }

    /// VX-827 U2 — VX-810: `list_notes`' `tag` — a PATH exactly as every tag
    /// tool takes one (`remove_tag`'s parse: `TagPath.segments`, a leading `#`
    /// tolerated) and refused in its one sentence when it names no path.
    private func optionalTagPath(_ args: [String: Value]) throws -> String? {
        guard let raw = try optionalString(args, "tag") else { return nil }
        let path = TagPath.segments(raw.hasPrefix("#") ? String(raw.dropFirst()) : raw).joined(separator: "/")
        guard !path.isEmpty else { throw ArgumentFailure(message: MCPWriteTools.tagPathWords) }
        return path
    }

    private func optionalInt(_ args: [String: Value], _ key: String) throws -> Int? {
        guard let value = args[key], value != .null else { return nil }
        if let int = value.intValue { return int }
        if case .double(let double) = value, double.rounded() == double { return Int(double) }
        throw ArgumentFailure(message: "\(key) must be an integer.")
    }
}

/// A keyset page's resume point — `(shape, sort key, id)`, opaque to the
/// client. The SHAPE names the listing order that minted it (round 1 F5):
/// book order's key is a fractional position, the recency listings' a touched
/// stamp — replaying one against the other would page garbage (never a leak:
/// every row still passes the rule), so a mismatched cursor refuses with the
/// same words as an undecodable one.
struct PageCursor: Equatable, Sendable {
    enum Shape: String, Sendable {
        /// A book's member order — `(position, post id)`.
        case book = "b"
        /// Recency — `(touched, id)`, descending.
        case recency = "r"
        /// 13n-c VX-273: a GATHERING's assembly order — `(index, post id)`;
        /// resumes after the note it names.
        case gathering = "g"
    }

    let shape: Shape
    let key: String
    let id: String

    var encoded: String { Data("\(shape.rawValue)\n\(key)\n\(id)".utf8).base64EncodedString() }

    init(shape: Shape, key: String, id: String) {
        self.shape = shape
        self.key = key
        self.id = id
    }

    init?(encoded: String) {
        guard let data = Data(base64Encoded: encoded),
              let text = String(data: data, encoding: .utf8)
        else { return nil }
        let parts = text.split(separator: "\n", maxSplits: 2, omittingEmptySubsequences: false)
        guard parts.count == 3, let shape = Shape(rawValue: String(parts[0])) else { return nil }
        self.shape = shape
        key = String(parts[1])
        id = String(parts[2])
        guard !key.isEmpty, !id.isEmpty else { return nil }
    }
}
