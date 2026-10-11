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

        /// **THE ONE STANDING-REACH RULE** (round 1 F1): the grants that can
        /// stand behind SEARCH — a once grant never feeds it (search reads
        /// words without spending, the recorded restriction beside
        /// P-13nb-U1-2). The catalog's listing and every serving road read
        /// THIS set, so the two can never drift again.
        var searchGrants: [MCPGrantRule.Grant] { liveGrants.filter { $0.duration != .once } }

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

    /// `consumes` (U2): a WRITE landing in the book (`create_note`,
    /// `import_document`, `add_note_to_book`) is content-bearing — it spends
    /// a once book grant by its first write of any rung (AF-7 as amended);
    /// a listing never does.
    static func decide(
        _ standing: Standing, book facts: MCPGrantRule.BookFacts?, rung: MCPGrantRule.Rung,
        consumes: Bool = false
    ) -> MCPGrantRule.Decision {
        guard let facts else { return missingTarget(standing) }
        return MCPGrantRule.decide(
            client: standing.state, grants: standing.grants, openBook: standing.openBook,
            target: .book(facts), rung: rung, consumes: consumes)
    }

    static func decideWing(
        _ standing: Standing, wingID: String, rung: MCPGrantRule.Rung, consumes: Bool = false
    ) -> MCPGrantRule.Decision {
        MCPGrantRule.decideWing(
            client: standing.state, grants: standing.grants, openBook: standing.openBook,
            wingID: wingID, rung: rung, consumes: consumes)
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
/// door — P-13n-1). U2 (AF-6): when a just-in-time ask WAS queued in the app,
/// a `rungTooLow` refusal — a target the client can already reach — gains
/// `askedSentence`; `notShared` keeps its ONE answer byte-for-byte whether or
/// not an ask was raised (no existence oracle).
///
/// **13n-c U1 (T-2 — AppSpec §12's "no fenced-vs-unshared oracle anywhere";
/// the brief's byte-identity under a Home-wing read grant):** a FENCED NOTE
/// answers the ONE `notShared` answer, byte for byte, on every tool — never
/// its fence's name and never the asked sentence (either would mark a daily
/// Journal entry or a Private note apart from an id that names nothing). The
/// ask is still put to HER (AF-6's own silent-ask posture for unshared
/// targets). This reverses AF-6's "`fenced` gains the said sentence" clause
/// for notes; the orchestrator's ruling F-7 (a) extends the one answer to a
/// fenced BOOK (the 13n-c plan's U1 adjudication).
enum MCPRefusalCopy {
    enum Target: Sendable, Equatable {
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
        case .fenced:
            // 13n-c U1 (T-2) + the orchestrator's ruling F-7 (a): a fenced
            // target — a note OR a book — is the ONE answer, exactly what an
            // id naming nothing hears (AppSpec §12: "no fenced-vs-unshared
            // oracle anywhere"). A fenced book still never raises an ask.
            return words(.notShared, target)
        }
    }

    /// AF-6's sentence (copy 13s-a-sweepable): said only where an ask was
    /// actually queued AND the reason is one the client already knows — a
    /// rung too low on a target it can reach — which, since the 13n-c U1
    /// ladder's F1, includes a fenced note the client holds a LIVE per-ask
    /// grant on (the rule answers `rungTooLow` there; the `fenced` REASON
    /// itself never gains the sentence).
    static let askedSentence = "Variorum has asked the author \u{2014} call again once she answers."

    /// The words for a refusal, with the asked sentence where it belongs.
    static func words(_ reason: MCPGrantRule.Reason, _ target: Target, asked: Bool) -> String {
        let base = words(reason, target)
        switch reason {
        case .rungTooLow:
            return asked ? base + " " + askedSentence : base
        case .fenced, .notShared, .clientPending, .clientDenied:
            // 13n-c U1 (T-2): `fenced` joins `notShared` — the asked sentence
            // would mark a fenced note apart from one that does not exist (a
            // fenced BOOK never raises an ask at all).
            return base
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

/// **A refusal, with the just-in-time ask raised where one belongs** (AF-6 —
/// the call NEVER blocks): an `.ask` decision for an APPROVED client on a
/// target that EXISTS (the caller passes nil for a missing one) queues the
/// ask in the app — never for a fenced BOOK, which no grant can name — and
/// the words gain the asked sentence only for a reason the client already
/// knows (`rungTooLow` — since the 13n-c U1 ladder's F1 that is also what a
/// fenced note answers its own live per-ask grant holder); `notShared` and an
/// UNREACHED fenced note stay the one answer (13n-c U1, T-2).
struct MCPAsking: Sendable {
    let onAsk: (@Sendable (MCPAsk) -> Void)?

    func refusal(
        _ decision: MCPGrantRule.Decision, _ target: MCPRefusalCopy.Target,
        standing: MCPGrantAuthority.Standing, ask: MCPAsk?
    ) -> MCPReadTools.Outcome {
        guard let reason = MCPRefusalCopy.reason(of: decision) else {
            return MCPReadTools.Outcome(text: "Not allowed.", isError: true)
        }
        var asked = false
        if case .ask = decision, standing.state == .approved, let ask, let onAsk,
           !(ask.scopeKind == .book && ask.fence != nil) {
            onAsk(ask)
            asked = true
        }
        return MCPReadTools.Outcome(text: MCPRefusalCopy.words(reason, target, asked: asked), isError: true)
    }
}
