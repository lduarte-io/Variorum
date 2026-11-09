import Foundation
import GRDB
import MCP
import VariorumCore

/// **`replace_tag` — tag A → tag B across the client's REACH in one wing**
/// (VX-812 — the VX-809 run, batch 3; her R-812: "'across a wing' means across
/// the client's REACH in that wing — the sweep acts on and counts only what the
/// client can see; hidden wearers of tag A are untouched, unmentioned and
/// uncounted, so the answer's totals never betray that unreadable rows exist").
///
/// **The sweep:** tag A is read by its path among the LIVE tags of `wing_id`
/// (a path naming none there is a sweep of nothing); its wearers — live,
/// non-version notes with a live application of EXACTLY A (never its subtree:
/// `remove_tag`'s address) — are walked in creation order, each decided at EDIT
/// through the one rule (`decide`, never consuming), and ONLY the notes this
/// client may edit are kept (A-809-13: the walk is over READABLE rows — a hidden
/// wearer is skipped where a store without it has no row, so the order, the cap
/// and every count are the same in both). The first 200 kept are swept; the
/// rest are counted (`remaining`, the kept ones beyond the cap — never a
/// hidden one) so the client calls again.
///
/// **Each swept note is its own act** (`Operations.replaceTagForClient`):
/// the single-note road's snapshot decision (`onNote` at EDIT — its ask, its
/// Activity line), its guard re-deciding inside its own transaction and
/// stamping a once grant there (a once grant covers ONE item — A-809-18 a.1,
/// P-809-12), its own client-named ⌥⌘Z entry; an item refusing never stops the
/// rest. The receipts ride one call-scoped run key (A-809-19) — one line at the
/// app; Open › the last swept note.
///
/// **The answer** counts the swept set only and carries the fixed scope words
/// in their notes form (`beyondReachNotesWords` — PROVISIONAL, P-809-1's
/// family). A call that landed nothing and refused something is an error
/// answer (the list forms' rule); a sweep with nothing to do is a success.
extension MCPWriteTools {
    /// `tag` and `with`: paths, a leading `#` tolerated (`remove_tag`'s
    /// parse); the two must name different tags.
    func parseReplaceTag(_ args: [String: Value]) throws -> Job {
        guard let wingID = try optionalString(args, "wing_id") else {
            throw ArgumentFailure(message: "wing_id is required (\"\" is Home).")
        }
        func path(_ key: String) throws -> String {
            let raw = try requiredText(args, key)
            let path = TagPath.segments(raw.hasPrefix("#") ? String(raw.dropFirst()) : raw).joined(separator: "/")
            guard !path.isEmpty else {
                throw ArgumentFailure(message: "\(key) must be a tag path \u{2014} names joined by /, e.g. \"percy/pt-en\".")
            }
            return path
        }
        let from = try path("tag")
        let to = try path("with")
        guard from != to else { throw ArgumentFailure(message: Self.sameTagWords) }
        return .replaceTag(wingID: wingID, from: from, to: to)
    }

    /// PROVISIONAL (the VX-809 bundle's wording list).
    static let sameTagWords = "tag and with name the same tag \u{2014} there is nothing to replace."

    func performReplaceTag(
        wingID: String, from: String, to: String, job: Job, ops: Operations, clientName: String
    ) throws -> Result<Landed, Refused> {
        let (standing, fromTagID, kept) = try database.read { db -> (MCPGrantAuthority.Standing, String?, [String]) in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            guard let tagID = try String.fetchOne(
                db, sql: "SELECT id FROM tag WHERE path = ? AND wing_id = ? AND deleted_at IS NULL",
                arguments: [from, wingID])
            else { return (standing, nil, []) }
            return (standing, tagID, try Self.editableWearers(db, tagID: tagID, standing: standing))
        }
        let swept = Array(kept.prefix(Self.listCap))
        let runKey = "replace_tag·\(UUID().uuidString)"
        var replaced: [String] = []
        var refused: [[String: Any]] = []
        var receipts: [MCPWriteReceipt] = []
        var unlogged: MCPActivityLogFailure?
        var toPath = to
        var toTagID: String?
        for noteID in swept {
            guard let fromTagID else { break }
            let outcome: Result<Landed, Refused>
            do {
                outcome = try onNote(noteID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { title in
                    let replacement: Operations.MCPTagReplacement
                    do {
                        replacement = try ops.replaceTagForClient(
                            fromTagID, with: to, onNote: noteID,
                            undoLabel: Operations.MCPWriteAct.tagReplace.undoLabel(client: clientName),
                            guardedBy: guardEdit(clientName) { _ in [noteID] })
                    } catch OperationError.tagNotApplied {
                        throw Refused(outcome: Outcome(text: Self.notWornWords(from), isError: true))
                    }
                    toPath = replacement.toPath
                    toTagID = replacement.toTagID
                    var receipt = MCPWriteReceipt(
                        clientName: clientName, act: .tagReplace, targetID: noteID, targetTitle: title,
                        detail: from, show: .note(noteID: noteID, blockID: nil, select: nil))
                    receipt.replacementPath = replacement.toPath
                    return (["note_id": noteID], receipt)
                }
            } catch {
                outcome = .failure(Refused(outcome: Outcome(
                    text: MCPWireRefusalCopy.unexpected(error, tool: job.tool, appWords: hooks.refusalWords),
                    isError: true)))
            }
            switch outcome {
            case .success(let one):
                replaced.append(noteID)
                receipts += one.receipts.map { receipt in
                    var stamped = receipt
                    stamped.runKey = runKey
                    return stamped
                }
                // VX-775: a replaced note whose Activity line failed stays
                // REPLACED; the call tells her once, counting them.
                unlogged = .coalescing(unlogged, one.activityLogFailure, tool: job.tool)
            case .failure(let refusal):
                refused.append(["note_id": noteID, "refused": refusal.outcome.text])
            }
        }
        var answer: [String: Any] = [
            "wing_id": wingID, "tag": from, "with": toPath, "with_tag_id": toTagID ?? NSNull(),
            "replaced": replaced, "replaced_count": replaced.count,
            "refused": refused, "refused_count": refused.count,
            "remaining": kept.count - swept.count,
            Self.beyondReachKey: Self.beyondReachNotesWords,
        ]
        let removed = job.nullCharactersWritten
        if removed > 0, !replaced.isEmpty { answer[MCPNullCharacters.answerKey] = removed }
        let text = try encode(answer)
        guard !replaced.isEmpty || refused.isEmpty else {
            return .failure(Refused(outcome: Outcome(text: text, isError: true)))
        }
        return .success(Landed(answer: text, receipts: receipts, activityLogFailure: unlogged))
    }

    /// **The wearers of exactly `tagID` this client may EDIT**, in creation
    /// order — the walk over READABLE rows only (A-809-13): every live,
    /// non-version note wearing the tag, decided at EDIT through the one rule
    /// (never consuming), in pages of `listCap` ids (`mcpNoteFacts`' batched
    /// facts). ∝ the tag's wearers.
    static func editableWearers(
        _ db: Database, tagID: String, standing: MCPGrantAuthority.Standing
    ) throws -> [String] {
        let wearers = try String.fetchAll(
            db,
            sql: """
                SELECT c.id FROM post_tag pt
                JOIN container c ON c.id = pt.post_id AND c.deleted_at IS NULL AND c.kind = 'post'
                WHERE pt.tag_id = ? AND pt.deleted_at IS NULL
                ORDER BY c.created_at, c.id
                """,
            arguments: [tagID])
        var kept: [String] = []
        var start = 0
        while start < wearers.count {
            let page = Array(wearers[start..<min(start + listCap, wearers.count)])
            let facts = try Queries.mcpNoteFacts(db, noteIDs: page)
            kept += page.filter {
                MCPGrantAuthority.decide(standing, note: facts[$0], rung: .edit, consumes: false).isAllowed
            }
            start += listCap
        }
        return kept
    }
}
