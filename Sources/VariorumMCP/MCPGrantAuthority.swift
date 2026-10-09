import Foundation
import GRDB
import VariorumCore

/// **THE GRANT AUTHORITY** (13n-b U1, A-7): the server's one consult of the
/// pure rule, PER CALL, against the store's CURRENT facts, read inside the
/// call's own transaction. It never decides anything itself — it gathers the
/// client's standing (state, grants, the open book) and the target's facts and
/// hands them to `MCPGrantRule.decide`.
struct MCPGrantAuthority: Sendable {
    /// One call's standing: the client as named in this session's
    /// `initialize`, read fresh (a revocation lands on the very next call).
    struct Standing: Sendable {
        let clientName: String
        let client: MCPClient?
        let grants: [MCPGrantRule.Grant]
        let openBook: Bool

        var state: MCPGrantRule.ClientState? { client?.state }

        /// Live grants only (not revoked, not a spent once grant).
        var liveGrants: [MCPGrantRule.Grant] { grants.filter(\.isLive) }

        func grant(id: String?) -> MCPGrantRule.Grant? {
            id.flatMap { id in grants.first { $0.id == id } }
        }
    }

    static func standing(_ db: Database, clientName: String) throws -> Standing {
        let client = try Queries.mcpClient(db, name: clientName)
        let grants = try client.map { try Queries.mcpGrants(db, clientID: $0.id).map(\.ruleGrant) } ?? []
        return Standing(
            clientName: clientName, client: client, grants: grants,
            openBook: try Queries.mcpSwitch(db, .openBook))
    }

    /// The rule's decision on a note — or, when the note has no facts (gone,
    /// a version, a scraps group, a stranger's id), the client gate and then
    /// `notShared`: one answer for "unshared" and "does not exist".
    static func decide(
        _ standing: Standing, note facts: MCPGrantRule.NoteFacts?, rung: MCPGrantRule.Rung, consumes: Bool
    ) -> MCPGrantRule.Decision {
        guard let facts else { return missingTarget(standing) }
        return MCPGrantRule.decide(
            client: standing.state, grants: standing.grants, openBook: standing.openBook,
            target: .note(facts), rung: rung, consumes: consumes)
    }

    static func decide(
        _ standing: Standing, book facts: MCPGrantRule.BookFacts?, rung: MCPGrantRule.Rung
    ) -> MCPGrantRule.Decision {
        guard let facts else { return missingTarget(standing) }
        return MCPGrantRule.decide(
            client: standing.state, grants: standing.grants, openBook: standing.openBook,
            target: .book(facts), rung: rung, consumes: false)
    }

    static func decideWing(_ standing: Standing, wingID: String, rung: MCPGrantRule.Rung) -> MCPGrantRule.Decision {
        MCPGrantRule.decideWing(
            client: standing.state, grants: standing.grants, openBook: standing.openBook,
            wingID: wingID, rung: rung)
    }

    private static func missingTarget(_ standing: Standing) -> MCPGrantRule.Decision {
        switch standing.state {
        case .approved: .ask(.notShared, offersAlways: true)
        case .denied: .refuse(.clientDenied)
        case .pending, nil: .refuse(.clientPending)
        }
    }
}

/// **The refusals, as the client reads them** (R-13n-4's "refusals speak to
/// the client exactly as they speak to you"; technical register inside the
/// door — P-13n-1). An "ask" decision reads the same in U1: the just-in-time
/// ask is U2's, so the words say how she would share it.
enum MCPRefusalCopy {
    enum Target: Sendable {
        case note, book, wing
        var noun: String {
            switch self {
            case .note: "note"
            case .book: "book"
            case .wing: "wing"
            }
        }
    }

    static func words(_ reason: MCPGrantRule.Reason, _ target: Target) -> String {
        switch reason {
        case .clientPending:
            return "This client's connection request is waiting in Variorum \u{25B8} Settings \u{25B8} MCP. "
                + "Nothing is readable until the author approves it."
        case .clientDenied:
            return "Variorum has denied this client. The author can approve it again in "
                + "Variorum \u{25B8} Settings \u{25B8} MCP."
        case .notShared:
            return "That \(target.noun) isn't shared with this client, or doesn't exist. The author "
                + "can share it from Variorum \u{25B8} Settings \u{25B8} MCP."
        case .rungTooLow(let granted):
            return "This client may only \(rungWords(granted)) here."
        case .fenced(.journal):
            return "That's a journal entry. Journal entries are shared one ask at a time, never by "
                + "a standing grant; the author hasn't shared this one with this client."
        case .fenced(.privateMark):
            return "That \(target.noun) is marked Private \u{2014} never shared with AI unless the "
                + "author shares it for one ask."
        }
    }

    static func rungWords(_ rung: MCPGrantRule.Rung) -> String {
        switch rung {
        case .read: "read"
        case .suggest: "read and suggest"
        case .writeNew: "read, suggest and write new"
        case .edit: "read, suggest, write new and edit"
        }
    }

    static func reason(of decision: MCPGrantRule.Decision) -> MCPGrantRule.Reason? {
        switch decision {
        case .allow: nil
        case .ask(let reason, _): reason
        case .refuse(let reason): reason
        }
    }
}
