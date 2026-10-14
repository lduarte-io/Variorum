import CryptoKit
import Foundation
import GRDB

// THE MCP DOOR's SETUP KEYS — the writes (VX-168; the VX-156 brief §12's K2,
// her kickoff ruling R-VX168-1). A Copy setup command MINTS a key (its hash
// pends in `mcp_setup_key`); each connection is ADMITTED or refused once, by
// the pure `Domain/MCPSetupKeyRule`, inside ONE transaction that reads the
// facts and lands the decision's effects together (two connections racing to
// claim one key serialize — the second finds it claimed). LOCAL-ONLY rows,
// never structural acts, no undo — the grants store's own discipline.

extension Operations {
    /// How many copied-but-unpresented keys the library keeps (newest first).
    /// A copy never expires by TIME (the argued call — the run record's UNIT 1
    /// RECORD): a key only buys a connection request her approval decides,
    /// or binds a name with none bound; the cap only bounds the table.
    /// PROVISIONAL P-VX168-U1-3.
    public static let mcpSetupKeyCap = 20

    /// **Copy setup command's mint** (K2 — the mint moved to copy time): a
    /// fresh 256-bit key, its hash pended, the oldest unpresented keys past
    /// the cap forgotten. Returns the KEY — the one moment it exists outside
    /// a client's settings (the caller puts it on the clipboard, never in
    /// the library).
    ///
    /// **VX-258 — `copiedFor`:** the client name the setup was copied for
    /// (Claude Code's tab, Codex's — the app's setup menu knows each tab's
    /// `clientInfo.name`); the key carries it in its text, so that name — and
    /// only it — takes the key with zero clicks. nil = an "Any MCP client"
    /// copy: it may take a name that carries her approval only by her OK. A
    /// name a key cannot carry (`MCPSetupKeyRule.canCarry`) refuses.
    public func mintMCPSetupKey(copiedFor name: String? = nil) throws -> String {
        if let name, !MCPSetupKeyRule.canCarry(name) { throw OperationError.mcpInvalidClientName(name: name) }
        let bytes = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
        let key = MCPSetupKeyRule.key(fromRandomBytes: bytes, copiedFor: name)
        let now = DateFormatter.variorumISO8601.string(from: date.now)
        try database.write { db in
            try db.execute(
                sql: "INSERT INTO mcp_setup_key (key_hash, minted_at) VALUES (?, ?)",
                arguments: [MCPSetupKeyRule.hash(key), now])
            try db.execute(
                sql: """
                    DELETE FROM mcp_setup_key WHERE key_hash NOT IN (
                      SELECT key_hash FROM mcp_setup_key ORDER BY minted_at DESC, key_hash DESC LIMIT ?)
                    """,
                arguments: [Self.mcpSetupKeyCap])
        }
        return key
    }

    /// One connection's admission: the rule's decision and, when admitted,
    /// the client row as it now stands.
    public struct MCPConnectionAdmission: Equatable, Sendable {
        public let decision: MCPSetupKeyRule.Decision
        public let client: MCPClient?
    }

    /// **A connection said who it is** — its `initialize` name and version,
    /// and the key its shim presented (nil = bare). ONE transaction: the
    /// facts read, the rule consulted, the effects landed —
    /// - admit: the name's last-seen stamp and declared version refreshed
    ///   (13n-b's first-contact refresh);
    /// - bind: the key leaves the unclaimed set and binds the known name
    ///   (logged — "connected with a new setup");
    /// - rebind (VX-198 — R-VX184-5, the newest copied setup wins): the key
    ///   leaves the unclaimed set and REPLACES the name's bound key; approval
    ///   and grants untouched; logged `connect_rebound` with the REPLACED
    ///   key's hash as the row's target — the memory that lets that key hear
    ///   its own sentence later (P-VX198-1);
    /// - request: a new PENDING connection request, bound to the key (the
    ///   waiting room's cap applies, 13n-b's rule);
    /// - awaitRebind (VX-258): the key is CLAIMED for the name — it leaves
    ///   the unclaimed set into ONE waiting row for the client (a newer wait
    ///   replaces the older, whose key is then forgotten) carrying the
    ///   version the connection declared; logged once (`connect_rebind_waiting`,
    ///   as refused — it reaches nothing); the client row untouched (the
    ///   waiting tool is not that client yet). A waiting key presented again
    ///   writes nothing. The admission returns the client so the session
    ///   knows the name it holds to a request's face;
    /// - refuse: NOTHING about the client changes (an impostor never touches
    ///   the row it claims) — the refusal is logged in words for her.
    public func admitMCPConnection(
        name: String, version: String?, presentedKey: String?
    ) throws -> MCPConnectionAdmission {
        try database.write { db in
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let presentedHash = presentedKey.map(MCPSetupKeyRule.hash)
            let existing = try Queries.mcpClient(db, name: trimmed)
            let facts: MCPSetupKeyRule.Client? = try existing.map {
                MCPSetupKeyRule.Client(
                    id: $0.id, boundHash: try Queries.mcpSetupKeyHash(db, clientID: $0.id),
                    approved: $0.state == .approved)
            }
            let standing = try presentedHash.map {
                try Queries.mcpSetupKeyStanding(db, hash: $0, name: trimmed)
            } ?? .unknown
            let decision = MCPSetupKeyRule.decide(
                name: trimmed, client: facts, presentedHash: presentedHash,
                copiedFor: presentedKey.flatMap(MCPSetupKeyRule.copiedFor), standing: standing)
            switch decision {
            case .refuse(let refusal):
                try recordMCPActivity(
                    db, clientName: trimmed.isEmpty ? Self.mcpUnnamedClient : trimmed,
                    act: MCPSetupKeyRule.activityAct(refusal), targetKind: nil, targetID: nil,
                    targetTitle: nil, allowed: false)
                return MCPConnectionAdmission(decision: decision, client: nil)
            case .awaitRebind:
                guard let presentedHash, let existing else {
                    preconditionFailure("the rule waits only for a presented key under a known name")
                }
                if case .unclaimed = standing {
                    try db.execute(sql: "DELETE FROM mcp_setup_key WHERE key_hash = ?", arguments: [presentedHash])
                    try db.execute(sql: "DELETE FROM mcp_rebind_request WHERE client_id = ?", arguments: [existing.id])
                    try db.execute(
                        sql: """
                            INSERT INTO mcp_rebind_request (id, client_id, key_hash, version, asked_at)
                            VALUES (?, ?, ?, ?, ?)
                            """,
                        arguments: [newID(), existing.id, presentedHash, version,
                                    DateFormatter.variorumISO8601.string(from: date.now)])
                    try recordMCPActivity(
                        db, clientName: trimmed, act: MCPSetupKeyRule.awaitingAct, targetKind: nil,
                        targetID: nil, targetTitle: nil, allowed: false)
                }
                return MCPConnectionAdmission(decision: decision, client: existing)
            case .admit:
                _ = try recordMCPContact(db, name: trimmed, version: version)
            case .bind, .rebind, .request:
                guard let presentedHash else { preconditionFailure("the rule claims only a presented key") }
                let client = try recordMCPContact(db, name: trimmed, version: version)
                try db.execute(sql: "DELETE FROM mcp_setup_key WHERE key_hash = ?", arguments: [presentedHash])
                try db.execute(
                    sql: "UPDATE mcp_client SET setup_key_hash = ? WHERE id = ?",
                    arguments: [presentedHash, client.id])
                switch decision {
                case .bind:
                    try recordMCPActivity(
                        db, clientName: trimmed, act: MCPSetupKeyRule.boundAct, targetKind: nil,
                        targetID: nil, targetTitle: nil, allowed: true)
                case .rebind:
                    try recordMCPActivity(
                        db, clientName: trimmed, act: MCPSetupKeyRule.reboundAct,
                        targetKind: MCPSetupKeyRule.replacedTargetKind, targetID: facts?.boundHash,
                        targetTitle: nil, allowed: true)
                default:
                    break
                }
            }
            return MCPConnectionAdmission(decision: decision, client: try Queries.mcpClient(db, name: trimmed))
        }
    }

    /// The name a refused nameless connection is logged under.
    public static let mcpUnnamedClient = "an unnamed client"

    // MARK: - Her answer to a waiting setup (VX-258)

    /// **Allow** — the waiting key takes the name: ONE transaction — the
    /// client must still be approved (a Deny since dropped the wait; one that
    /// slipped past refuses here, nothing written); the name's bound key is
    /// REPLACED by (or, unbound, bound to) the waiting key; the wait leaves;
    /// logged `connect_rebind_allowed` with the replaced key's hash as the
    /// row's target (nil when the name was unbound), so a connection still
    /// presenting that key hears its own sentence (VX-198's memory). Approval
    /// and grants untouched. Returns the client as it now stands. No undo
    /// entry (the grants store's discipline: the pane's doors are their own
    /// recovery — a re-run setup, or Deny).
    @discardableResult
    public func allowMCPRebind(_ requestID: String) throws -> MCPClient {
        try database.write { db in
            guard let row = try Row.fetchOne(
                db, sql: "SELECT client_id, key_hash FROM mcp_rebind_request WHERE id = ?", arguments: [requestID])
            else { throw OperationError.mcpRebindRequestNotFound(id: requestID) }
            let clientID: String = row["client_id"]
            let keyHash: String = row["key_hash"]
            guard let client = try Queries.mcpClient(db, id: clientID) else {
                throw OperationError.mcpClientNotFound(id: clientID)
            }
            guard client.state == .approved else { throw OperationError.mcpClientNotApproved(id: clientID) }
            let replaced = try Queries.mcpSetupKeyHash(db, clientID: clientID)
            try db.execute(sql: "DELETE FROM mcp_rebind_request WHERE id = ?", arguments: [requestID])
            try db.execute(
                sql: "UPDATE mcp_client SET setup_key_hash = ? WHERE id = ?", arguments: [keyHash, clientID])
            try recordMCPActivity(
                db, clientName: client.name, act: MCPSetupKeyRule.rebindAllowedAct,
                targetKind: replaced.map { _ in MCPSetupKeyRule.replacedTargetKind }, targetID: replaced,
                targetTitle: nil, allowed: true)
            guard let now = try Queries.mcpClient(db, id: clientID) else {
                throw OperationError.mcpClientNotFound(id: clientID)
            }
            return now
        }
    }

    /// **Don't allow** — the waiting key is forgotten (it was never anyone's:
    /// its next connection reads it as a key this library doesn't hold and
    /// hears the ONE sentence); the name keeps its own key, so the client she
    /// knows never notices. Logged `connect_rebind_declined`. Returns the
    /// client's name (for her receipt). No undo entry.
    @discardableResult
    public func declineMCPRebind(_ requestID: String) throws -> String {
        try database.write { db in
            guard let name = try String.fetchOne(
                db,
                sql: """
                    SELECT c.name FROM mcp_rebind_request r JOIN mcp_client c ON c.id = r.client_id WHERE r.id = ?
                    """,
                arguments: [requestID])
            else { throw OperationError.mcpRebindRequestNotFound(id: requestID) }
            try db.execute(sql: "DELETE FROM mcp_rebind_request WHERE id = ?", arguments: [requestID])
            try recordMCPActivity(
                db, clientName: name, act: MCPSetupKeyRule.rebindDeclinedAct, targetKind: nil, targetID: nil,
                targetTitle: nil, allowed: false)
            return name
        }
    }
}
