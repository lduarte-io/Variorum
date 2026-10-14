import Foundation
import GRDB
import MCP
import VariorumCore

/// **THE EDIT RUNG's DELIBERATE ACTS on the wire** (VX-168 U2): VX-169's
/// `save_commit` (her settlement at the 2026-10-12 pre-run sitting — edit,
/// `kind='manual'`, the client's name prefixed) and VX-174's merge button
/// (R-MERGE-1 — `choose_take` per block, `adopt_lens` wholesale, edit). Thin
/// projections of `Operations+MCPDeliberate` — her commit, her ✓, her "✓ Make
/// this the note" — a missing human action made first-class on the protocol,
/// never special agent tooling.
///
/// Each takes the edit rung's two decisions (AF-10 (a), the U2 ladder's F2
/// closed rung-wide): the SNAPSHOT (`onNote`, `spendsAfter: false`) speaks the
/// refusal and raises the just-in-time ask; the `WriteGuard` re-decides on the
/// act's own rows INSIDE its write transaction — the note re-resolved from the
/// take or the lens — and spends any once grant there, atomic with the act.
/// A take or lens that lives in no reachable note (dead, a stranger's id, a
/// version's, a scraps group's) answers the ONE not-shared answer.
extension MCPWriteTools {
    enum DeliberateJob: Sendable {
        case commit(takeID: String, message: String)
        case choose(takeID: String)
        case adoptLens(lensID: String)

        var tool: String {
            switch self {
            case .commit: MCPToolCatalog.saveCommit.name
            case .choose: MCPToolCatalog.chooseTake.name
            case .adoptLens: MCPToolCatalog.adoptLens.name
            }
        }

        /// VX-275 (`Job.flushesHerEditorFirst`): a COMMIT copies the take (her
        /// ⌘S flushes first — `commitCaret`); a choice or an adoption moves
        /// pointers only, and her flush lands in the take she typed in.
        var flushesHerEditorFirst: Bool {
            switch self {
            case .commit: true
            case .choose, .adoptLens: false
            }
        }
    }

    // MARK: - Arguments (parsed BEFORE the executor)

    func parseDeliberate(_ name: String, _ args: [String: Value]) throws -> DeliberateJob? {
        switch name {
        case MCPToolCatalog.saveCommit.name:
            // The message is required: it is what the commit is FOR, and the
            // stored "<client>: <message>" is how her history says who.
            return .commit(takeID: try requiredString(args, "take_id"), message: try requiredText(args, "message"))
        case MCPToolCatalog.chooseTake.name:
            return .choose(takeID: try requiredString(args, "take_id"))
        case MCPToolCatalog.adoptLens.name:
            return .adoptLens(lensID: try requiredString(args, "lens_id"))
        default:
            return nil
        }
    }

    // MARK: - The serial body

    func performDeliberate(
        _ deliberate: DeliberateJob, job: Job, ops: Operations, clientName: String
    ) throws -> Result<Landed, Refused> {
        let label = { (act: Operations.MCPWriteAct) in act.undoLabel(client: clientName) }
        switch deliberate {
        case .commit(let takeID, let message):
            let noteID = try database.read { try Queries.mcpContainerOf(take: takeID, $0) } ?? ""
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName,
                              logged: ("take", takeID), spendsAfter: false) { title in
                let commit = try ops.commitTakeForClient(
                    takeID, message: message, client: clientName,
                    guardedBy: guardEdit(clientName) { db in [try Queries.mcpContainerOf(take: takeID, db)] })
                let blockID = try database.read { db in
                    try String.fetchOne(db, sql: "SELECT block_id FROM variant WHERE id = ?", arguments: [takeID])
                }
                return (["commit_id": commit.id, "take_id": takeID, "block_id": blockID ?? NSNull(),
                         "note_id": noteID, "message": commit.message ?? NSNull(),
                         "saved_at": DateFormatter.variorumISO8601.string(from: commit.createdAt)],
                        MCPWriteReceipt(clientName: clientName, act: .commit, targetID: noteID, targetTitle: title,
                                        show: blockID.map { .note(noteID: noteID, blockID: $0, select: nil) }))
            }

        case .choose(let takeID):
            let noteID = try database.read { try Queries.mcpContainerOf(take: takeID, $0) } ?? ""
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName,
                              logged: ("take", takeID), spendsAfter: false) { title in
                let choice = try ops.chooseTake(
                    takeID, undoLabel: label(.choice),
                    guardedBy: guardEdit(clientName) { db in [try Queries.mcpContainerOf(take: takeID, db)] })
                return (["take_id": takeID, "block_id": choice.blockID, "note_id": noteID, "changed": choice.changed],
                        choice.changed
                        ? MCPWriteReceipt(clientName: clientName, act: .choice, targetID: noteID, targetTitle: title,
                                          show: .takes(noteID: noteID, blockID: choice.blockID))
                        : nil)
            }

        case .adoptLens(let lensID):
            let noteID = try database.read { try Queries.mcpContainerOf(lens: lensID, $0) } ?? ""
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName,
                              logged: ("lens", lensID), spendsAfter: false) { title in
                let adoption = try ops.adoptLensAsNote(
                    lensID, undoLabel: label(.lensAdoption),
                    guardedBy: guardEdit(clientName) { db in [try Queries.mcpContainerOf(lens: lensID, db)] })
                let lensName = try database.read { db in
                    try String.fetchOne(db, sql: "SELECT name FROM lens WHERE id = ?", arguments: [lensID])
                }
                var answer: [String: Any] = [
                    "lens_id": lensID, "note_id": noteID, "changed": adoption.changed, "chose": adoption.moved,
                ]
                if let kept = adoption.keptAs {
                    answer["kept_as_lens_id"] = kept.id
                    answer["kept_as"] = kept.name
                }
                return (answer, adoption.changed
                        ? MCPWriteReceipt(clientName: clientName, act: .lensAdoption, targetID: noteID,
                                          targetTitle: title, detail: lensName,
                                          show: .note(noteID: noteID, blockID: nil, select: nil))
                        : nil)
            }
        }
    }
}
