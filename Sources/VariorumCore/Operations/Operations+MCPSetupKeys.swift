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
    public func mintMCPSetupKey() throws -> String {
        let bytes = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }
        let key = MCPSetupKeyRule.key(fromRandomBytes: bytes)
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
    /// - request: a new PENDING connection request, bound to the key (the
    ///   waiting room's cap applies, 13n-b's rule);
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
                MCPSetupKeyRule.Client(id: $0.id, boundHash: try Queries.mcpSetupKeyHash(db, clientID: $0.id))
            }
            let standing = try presentedHash.map { try Queries.mcpSetupKeyStanding(db, hash: $0) } ?? .unknown
            let decision = MCPSetupKeyRule.decide(
                name: trimmed, client: facts, presentedHash: presentedHash, standing: standing)
            switch decision {
            case .refuse(let refusal):
                try recordMCPActivity(
                    db, clientName: trimmed.isEmpty ? Self.mcpUnnamedClient : trimmed,
                    act: MCPSetupKeyRule.activityAct(refusal), targetKind: nil, targetID: nil,
                    targetTitle: nil, allowed: false)
                return MCPConnectionAdmission(decision: decision, client: nil)
            case .admit:
                _ = try recordMCPContact(db, name: trimmed, version: version)
            case .bind, .request:
                guard let presentedHash else { preconditionFailure("the rule claims only a presented key") }
                let client = try recordMCPContact(db, name: trimmed, version: version)
                try db.execute(sql: "DELETE FROM mcp_setup_key WHERE key_hash = ?", arguments: [presentedHash])
                try db.execute(
                    sql: "UPDATE mcp_client SET setup_key_hash = ? WHERE id = ?",
                    arguments: [presentedHash, client.id])
                if decision == .bind {
                    try recordMCPActivity(
                        db, clientName: trimmed, act: MCPSetupKeyRule.boundAct, targetKind: nil,
                        targetID: nil, targetTitle: nil, allowed: true)
                }
            }
            return MCPConnectionAdmission(decision: decision, client: try Queries.mcpClient(db, name: trimmed))
        }
    }

    /// The name a refused nameless connection is logged under.
    public static let mcpUnnamedClient = "an unnamed client"
}

extension Queries {
    /// The hash of the key bound to a client; nil = unbound (or no client).
    public static func mcpSetupKeyHash(_ db: Database, clientID: String) throws -> String? {
        try String.fetchOne(db, sql: "SELECT setup_key_hash FROM mcp_client WHERE id = ?", arguments: [clientID])
    }

    /// Where a presented key (by its hash) stands: bound to a client, still
    /// unclaimed, or unknown here.
    public static func mcpSetupKeyStanding(_ db: Database, hash: String) throws -> MCPSetupKeyRule.KeyStanding {
        if let clientID = try String.fetchOne(
            db, sql: "SELECT id FROM mcp_client WHERE setup_key_hash = ?", arguments: [hash]) {
            return .boundTo(clientID: clientID)
        }
        let pending = try Bool.fetchOne(
            db, sql: "SELECT EXISTS (SELECT 1 FROM mcp_setup_key WHERE key_hash = ?)", arguments: [hash]) ?? false
        return pending ? .unclaimed : .unknown
    }

    /// How many copied keys wait unpresented (the drill's and the pins' read).
    public static func mcpUnclaimedSetupKeyCount(_ db: Database) throws -> Int {
        try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM mcp_setup_key") ?? 0
    }
}
