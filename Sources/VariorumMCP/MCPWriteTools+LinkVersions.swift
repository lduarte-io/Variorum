import Foundation
import GRDB
import MCP
import VariorumCore

/// **`link_versions` — two notes linked as versions, by NAMED pairs**
/// (VX-184 U3 — VX-187; her ruling R-VX187-1: the AI names the paragraph
/// pairs, at least one `{block_a, block_b}` across the two notes, never
/// positional guessing). A thin projection of
/// `Operations.linkVersionsForClient` (her `version_of` road, one transaction,
/// ONE client-named undo entry).
///
/// **WRITE NEW on BOTH notes — `move_note_to_wing`'s two-sided shape:** the
/// snapshot decides `note_a`, then `note_b` (the first refusal speaks and
/// raises ITS ask); then the wings (one library — her picker never offers
/// another wing's note), then every pair's blocks (after both decisions, so a
/// client learns nothing of a note it cannot reach). The act runs behind a
/// guard that decides BOTH notes again on ONE standing read inside its own
/// transaction and stamps their once grants as one union there — both spend
/// or neither.
extension MCPWriteTools {
    static let differentWingsWords =
        "Those notes are in different wings \u{2014} each wing is a separate library, so notes in two of "
        + "them can't be linked as versions."

    static func blockNotInNoteWords(index: Int, side: String) -> String {
        "pairs[\(index)].block_\(side) isn't a block of note_\(side) \u{2014} read_note with with_ids: true "
            + "gives its block ids."
    }

    // MARK: - Arguments (parsed BEFORE the executor)

    func parseLinkVersions(_ args: [String: Value]) throws -> Job {
        let noteA = try requiredString(args, "note_a")
        let noteB = try requiredString(args, "note_b")
        guard noteA != noteB else { throw ArgumentFailure(message: "note_a and note_b must be two different notes.") }
        guard let value = args["pairs"], value != .null else { throw ArgumentFailure(message: "pairs is required.") }
        guard let list = value.arrayValue else { throw ArgumentFailure(message: "pairs must be an array.") }
        guard !list.isEmpty else {
            throw ArgumentFailure(message:
                "pairs must name at least one pair \u{2014} {block_a, block_b}, a block of note_a and the block of "
                + "note_b it corresponds to.")
        }
        guard list.count <= Self.batchCap else {
            throw ArgumentFailure(message: Self.overCapWords(tool: "link_versions", noun: "pairs", count: list.count))
        }
        var seen = Set<[String]>()
        let pairs: [Operations.MCPVersionPair] = try list.enumerated().map { index, item in
            guard let fields = item.objectValue else { throw ArgumentFailure(message: "pairs[\(index)] must be an object.") }
            func id(_ key: String) throws -> String {
                guard let value = fields[key]?.stringValue, !value.isEmpty else {
                    throw ArgumentFailure(message: "pairs[\(index)].\(key) is required.")
                }
                return value
            }
            let pair = Operations.MCPVersionPair(blockA: try id("block_a"), blockB: try id("block_b"))
            guard seen.insert([pair.blockA, pair.blockB]).inserted else {
                throw ArgumentFailure(message: "pairs[\(index)] repeats an earlier pair.")
            }
            return pair
        }
        return .linkVersions(noteA: noteA, noteB: noteB, pairs: pairs)
    }

    // MARK: - The serial body

    func performLinkVersions(
        noteA: String, noteB: String, pairs: [Operations.MCPVersionPair], job: Job, ops: Operations,
        clientName: String
    ) throws -> Result<Landed, Refused> {
        let (standing, factsA, titleA, factsB, titleB) = try database.read { db in
            let factsA = try Queries.mcpNoteFacts(db, noteID: noteA)
            let factsB = try Queries.mcpNoteFacts(db, noteID: noteB)
            return (try MCPGrantAuthority.standing(db, clientName: clientName),
                    factsA, factsA == nil ? nil : try Queries.mcpScopeTitle(db, kind: .note, id: noteA, calendar: calendar),
                    factsB, factsB == nil ? nil : try Queries.mcpScopeTitle(db, kind: .note, id: noteB, calendar: calendar))
        }
        for (noteID, facts, title) in [(noteA, factsA, titleA), (noteB, factsB, titleB)] {
            let decision = MCPGrantAuthority.decide(standing, note: facts, rung: .writeNew, consumes: true)
            guard decision.isAllowed else {
                try log(clientName, job.tool, "note", noteID, title, allowed: false)
                let ask = facts.map { MCPAsk(clientName: clientName, scopeKind: .note, scopeID: noteID,
                                             title: title ?? "", rung: .writeNew, fence: $0.fence) }
                return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                    .refusal(decision, .note, standing: standing, ask: ask)))
            }
        }
        return try land(job, clientName: clientName, kind: "note", id: noteA, title: titleA) {
            // Every pair's blocks on the snapshot — after BOTH decisions.
            let placed = try database.read { db in
                (try placedBlocks(db, noteA), try placedBlocks(db, noteB))
            }
            for (index, pair) in pairs.enumerated() {
                if !placed.0.contains(pair.blockA) {
                    throw ArgumentFailure(message: Self.blockNotInNoteWords(index: index, side: "a"))
                }
                if !placed.1.contains(pair.blockB) {
                    throw ArgumentFailure(message: Self.blockNotInNoteWords(index: index, side: "b"))
                }
            }
            let edges: [Edge]
            do {
                edges = try ops.linkVersionsForClient(
                    noteA: noteA, noteB: noteB, pairs: pairs,
                    undoLabel: Operations.MCPWriteAct.versionLink.undoLabel(client: clientName),
                    guardedBy: guardNotes(clientName, rung: .writeNew) { _ in [noteA, noteB] })
            } catch let refusal as Operations.MCPVersionLinkRefusal {
                throw Refused(outcome: Outcome(text: Self.words(refusal), isError: true))
            }
            let links: [[String: Any]] = zip(pairs, edges).map { pair, edge in
                ["block_a": pair.blockA, "block_b": pair.blockB, "edge_id": edge.id]
            }
            return (["note_a": noteA, "note_b": noteB, "links": links],
                    MCPWriteReceipt(clientName: clientName, act: .versionLink, targetID: noteA, targetTitle: titleA,
                                    detail: titleB, show: .note(noteID: noteA, blockID: nil, select: nil)))
        }
    }

    private func placedBlocks(_ db: Database, _ noteID: String) throws -> Set<String> {
        Set(try String.fetchAll(
            db,
            sql: """
                SELECT cb.block_id FROM container_block cb
                JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                """,
            arguments: [noteID]))
    }

    static func words(_ refusal: Operations.MCPVersionLinkRefusal) -> String {
        switch refusal {
        case .sameNote: "note_a and note_b must be two different notes."
        case .differentWings: differentWingsWords
        case .blockNotInNote(let index, let side): blockNotInNoteWords(index: index, side: side)
        case .repeatedPair(let index): "pairs[\(index)] repeats an earlier pair."
        case .alreadyLinked(let index):
            "pairs[\(index)] is already linked \u{2014} those two blocks are versions already; leave that pair out."
        }
    }
}
