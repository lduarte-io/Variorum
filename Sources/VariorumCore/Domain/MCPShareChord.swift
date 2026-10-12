import Foundation

/// **⌥⌘A — SHARE THE NOTE YOU'RE IN** (13n-c U3; the VX-156 brief §4 + mockup
/// §3, D1 — nodded through at her round-2 sitting). Pure, so the decision is
/// pinned headless; the app reads the facts and acts on the outcome.
///
/// The target is DERIVED, never stored: the newest grant she made (any face,
/// revoked rows counting — "the last grant she made" is a fact about her, not
/// about the grant's life) whose client is still APPROVED names the client and
/// the rung (`Queries.mcpNewestGrant`). The duration is "while connected" when
/// that client is connected now, else "once" — **a key never mints "always"**
/// (a standing-forever grant deserves the sheet). A fenced note takes the same
/// answer: both durations are per-ask-legal for a note grant
/// (`MCPGrantRule.reaches`).
public enum MCPShareChord {
    /// The newest grant's client and rung (`Queries.mcpNewestGrant`).
    public struct Newest: Equatable, Sendable {
        public let clientID: String
        public let clientName: String
        public let rung: MCPGrantRule.Rung

        public init(clientID: String, clientName: String, rung: MCPGrantRule.Rung) {
            self.clientID = clientID
            self.clientName = clientName
            self.rung = rung
        }
    }

    public enum Outcome: Equatable, Sendable {
        /// Grant this note to this client, at this rung, for this long.
        case grant(clientID: String, clientName: String, rung: MCPGrantRule.Rung, duration: MCPGrantRule.Duration)
        /// No history (no grant ever made, or every client she granted is
        /// denied since): the chord cannot guess, so it opens the deliberate
        /// road — THE grant sheet with WHERE = this note (P-2).
        case openSheet
        /// That client already reaches this note at the rung or above: a
        /// refusal, nothing written ("claude-code already reaches this note
        /// (read and suggest).").
        case alreadyReaching(clientName: String, rung: MCPGrantRule.Rung)
    }

    /// - Parameters:
    ///   - newest: the derived client and rung, or nil (no history).
    ///   - connected: whether that client is connected now.
    ///   - reached: the highest rung that client already reaches THIS note at
    ///     (`MCPGrantRule.reach`), or nil.
    public static func decide(
        newest: Newest?, connected: Bool, reached: MCPGrantRule.Rung?
    ) -> Outcome {
        guard let newest else { return .openSheet }
        if let reached, reached >= newest.rung {
            return .alreadyReaching(clientName: newest.clientName, rung: reached)
        }
        return .grant(
            clientID: newest.clientID, clientName: newest.clientName, rung: newest.rung,
            duration: connected ? .connection : .once)
    }
}
