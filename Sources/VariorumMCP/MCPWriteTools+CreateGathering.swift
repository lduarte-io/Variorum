import Foundation
import GRDB
import MCP
import VariorumCore

/// **`create_gathering` — a gathering minted on the wire, at WRITE NEW on the
/// wing** (VX-769 — the VX-771 run, batch 3; her ruling R-771-B: "the wire
/// gains minting a gathering"; the tool shape the orchestrator's call,
/// PROVISIONAL P-771-2 — its own tool, never a `create_book` kind: a gathering
/// refuses chapters, extents and a finish, and its rule is hers after birth).
/// A thin projection of `Operations.createGatheringForClient` — her Mint
/// gathering sheet's row through her one body — behind `create_book`'s own
/// decision and ask (`inWing`: wing-level reach at write new, a once wing grant
/// spent by the landed mint). Why it exists: a GATHERING evicts a note when
/// the tag goes, by definition (it holds nothing; it shows what its rule
/// matches now) — exactly the board shape a tag-rule BOOK cannot be, since
/// un-tagging is a non-event there (VX-764's report).
///
/// **The rule** arrives in `set_book_rule`'s wire grammar and is read by its
/// ONE parser (`MCPBookFacts.decodeRule` — every malformed or empty rule in its
/// own words; a legacy term refused); a missing or null rule refuses here
/// (R-13ic-4: a gathering is born WITH its rule). Its tag paths resolve in the
/// wing exactly as `set_book_rule`'s do (adopted, or minted).
///
/// **No applying act** — a gathering assembles at read: nothing seats, nothing
/// bells. **A mint grants nothing** (R-VX185-1): the client reaches the new
/// gathering exactly as it reaches one of hers, through `decideGathering`.
/// **The rule stays hers** after birth: `set_book_rule` on it answers the
/// gathering sentence (A-648-5), byte-unchanged.
///
/// **The answer:** `gathering_id`, `name`, `wing_id`, `rule` (as stored, in
/// the wire's grammar — each tag by its live path: `list_books`' and
/// `set_book_rule`'s read), `notes` (`list_books`' own count of what it
/// gathers that this client can read — `MCPReadTools.readableGatheringNoteCount`,
/// the one rule), and `minted_tags` when a path minted one (`set_book_rule`'s
/// key). The receipt names the gathering and opens it. ∝ the rule + the
/// gathering's assembly.
extension MCPWriteTools {
    /// The missing rule's sentence (PROVISIONAL words, her copy pass — VX-234).
    static let gatheringRuleRequiredWords =
        "rule is required: a gathering is made with its rule, written as set_book_rule writes one \u{2014} "
        + "e.g. {\"tag\": \"board\"} or {\"or\": [{\"tag\": \"board\"}, {\"star\": true}]}."

    /// `name`, `wing_id` (`create_book`'s two sentences, in its order) and the
    /// required `rule`.
    func parseCreateGathering(_ args: [String: Value]) throws -> Job {
        guard let wingID = try optionalString(args, "wing_id") else {
            throw ArgumentFailure(message: "wing_id is required (\"\" is Home).")
        }
        let name = try requiredText(args, "name")
        guard let value = args["rule"], value != .null else {
            throw ArgumentFailure(message: Self.gatheringRuleRequiredWords)
        }
        return .createGathering(name: name, wingID: wingID, rule: try MCPBookFacts.decodeRule(value))
    }

    func performCreateGathering(
        name: String, wingID: String, rule: RuleTerm, job: Job, ops: Operations, clientName: String
    ) throws -> Result<Landed, Refused> {
        try inWing(wingID, job: job, clientName: clientName) {
            // VX-259 (create_book's rule): the name is checked only against
            // the books and gatherings this client can READ.
            let mint = try ops.createGatheringForClient(
                named: name, inWing: wingID, rule: rule,
                undoLabel: Operations.MCPWriteAct.gathering.undoLabel(client: clientName),
                namesCountedBy: readableBooks(clientName))
            let gathering = mint.gathering
            let (storedRule, notes) = try database.read { db in
                (try MCPBookFacts.facts(db, readingID: gathering.id)["rule"],
                 try MCPReadTools.readableGatheringNoteCount(
                     db, gatheringID: gathering.id,
                     standing: try MCPGrantAuthority.standing(db, clientName: clientName)))
            }
            var answer: [String: Any] = [
                "gathering_id": gathering.id, "name": gathering.name, "wing_id": gathering.wingId,
                "rule": storedRule ?? NSNull(), "notes": notes,
            ]
            if mint.mintedTags > 0 { answer["minted_tags"] = mint.mintedTags }
            return (answer, MCPWriteReceipt(
                clientName: clientName, act: .gathering, targetID: gathering.id, targetTitle: gathering.name,
                show: .book(bookID: gathering.id, sectionID: nil)))
        }
    }
}
