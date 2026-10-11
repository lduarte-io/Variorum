import Foundation
import GRDB

// THE MCP DOOR's GRANTS STORE — the writes (13n-b U1; A-5/A-6/A-8; the
// grammar R-13n-4). Every change to who may reach the library goes through
// here: first contact (a PENDING connection request — no access), approve
// (with its first grant, one transaction), deny, grant, revoke, the once
// grant's consumption, the while-connected grants' end, the switches, and the
// coarse activity log with its cap. LOCAL-ONLY rows (no outbox, no sync) — and
// never structural acts: none registers undo (the pane's doors are their own
// recovery, like the Trash's).
//
// Each write has a db-level form for an in-transaction caller: the server
// consumes a once grant and records its activity INSIDE the transaction that
// reads the note, so a once grant can never be read twice and a refused call
// is always logged.

extension Operations {
    /// What a grant gives: how much, where, for how long (R-13n-4).
    public struct MCPGrantSpec: Equatable, Sendable {
        public var rung: MCPGrantRule.Rung
        public var scopeKind: MCPGrantRule.ScopeKind
        public var scopeID: String
        public var duration: MCPGrantRule.Duration

        public init(
            rung: MCPGrantRule.Rung, scopeKind: MCPGrantRule.ScopeKind, scopeID: String,
            duration: MCPGrantRule.Duration
        ) {
            self.rung = rung
            self.scopeKind = scopeKind
            self.scopeID = scopeID
            self.duration = duration
        }
    }

    /// The pending-request cap: a local process can announce any name, so
    /// the waiting room is bounded — past it, the OLDEST pending request is
    /// forgotten (it never had access). PROVISIONAL P-13nb-U1-6.
    public static let mcpPendingCap = 50
    /// The activity log's cap — coarse, never a growing pile (A-5;
    /// R-13n-10). PROVISIONAL P-13nb-U1-6.
    public static let mcpActivityCap = 500

    // MARK: - First contact

    /// A client said who it is (`initialize`). An unknown name becomes a
    /// PENDING connection request with NO access (R-13n-4: approved in the
    /// pane, never by a popup); a known one has its last-seen stamp and
    /// declared version refreshed — its state is untouched (a denied client
    /// stays denied). Returns the row as it now stands.
    @discardableResult
    public func recordMCPContact(name: String, version: String?) throws -> MCPClient {
        try database.write { db in try recordMCPContact(db, name: name, version: version) }
    }

    @discardableResult
    public func recordMCPContact(_ db: Database, name: String, version: String?) throws -> MCPClient {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw OperationError.mcpInvalidClientName(name: name) }
        let now = DateFormatter.variorumISO8601.string(from: date.now)
        if let existing = try Queries.mcpClient(db, name: trimmed) {
            try db.execute(
                sql: "UPDATE mcp_client SET last_seen_at = ?, version = ? WHERE id = ?",
                arguments: [now, version, existing.id])
        } else {
            try db.execute(
                sql: """
                    INSERT INTO mcp_client (id, name, version, state, first_seen_at, last_seen_at)
                    VALUES (?, ?, ?, 'pending', ?, ?)
                    """,
                arguments: [newID(), trimmed, version, now, now])
            // The waiting room's cap: forget the oldest pending requests past
            // it (pending clients hold no grants — nothing else to tidy).
            try db.execute(
                sql: """
                    DELETE FROM mcp_client WHERE state = 'pending' AND id NOT IN (
                      SELECT id FROM mcp_client WHERE state = 'pending'
                      ORDER BY first_seen_at DESC, id DESC LIMIT ?)
                    """,
                arguments: [Self.mcpPendingCap])
        }
        guard let client = try Queries.mcpClient(db, name: trimmed) else {
            throw OperationError.mcpClientNotFound(id: trimmed)
        }
        return client
    }

    // MARK: - Approve, deny

    /// **Approve…** — the client becomes approved and, when `granting` is
    /// given, receives that first grant in the SAME transaction (the sheet's
    /// one press). Approving an approved client only adds the grant.
    @discardableResult
    public func approveMCPClient(_ clientID: String, granting spec: MCPGrantSpec?) throws -> String? {
        try database.write { db in
            guard let client = try Queries.mcpClient(db, id: clientID) else {
                throw OperationError.mcpClientNotFound(id: clientID)
            }
            let now = DateFormatter.variorumISO8601.string(from: date.now)
            if client.state != .approved {
                try db.execute(
                    sql: "UPDATE mcp_client SET state = 'approved', decided_at = ? WHERE id = ?",
                    arguments: [now, clientID])
            }
            guard let spec else { return nil }
            return try insertMCPGrant(db, clientID: clientID, spec: spec, now: now)
        }
    }

    /// **Deny** (a connection request) or **Revoke** (an approved client —
    /// PROVISIONAL P-13nb-U1-5: the clients list's revoke is a deny): the
    /// client is denied and EVERY grant it holds is revoked at once — its
    /// next call refuses. A no-op on a client already denied.
    public func denyMCPClient(_ clientID: String) throws {
        try database.write { db in
            guard let client = try Queries.mcpClient(db, id: clientID) else {
                throw OperationError.mcpClientNotFound(id: clientID)
            }
            let now = DateFormatter.variorumISO8601.string(from: date.now)
            try db.execute(
                sql: "UPDATE mcp_grant SET revoked_at = ? WHERE client_id = ? AND revoked_at IS NULL",
                arguments: [now, clientID])
            guard client.state != .denied else { return }
            try db.execute(
                sql: "UPDATE mcp_client SET state = 'denied', decided_at = ? WHERE id = ?",
                arguments: [now, clientID])
        }
    }

    // MARK: - Grant, revoke

    /// One grant to an APPROVED client. Refuses a client not approved, a
    /// scope that is not a live target of its kind, a FENCED book (a
    /// journal's or a Private book's notes are shared one ask at a time —
    /// a book grant there would reach nothing), and an "always" grant on a
    /// fenced note (the ask never offers it — R-13n-4).
    @discardableResult
    public func grantMCPAccess(_ clientID: String, _ spec: MCPGrantSpec) throws -> String {
        try database.write { db in
            guard let client = try Queries.mcpClient(db, id: clientID) else {
                throw OperationError.mcpClientNotFound(id: clientID)
            }
            guard client.state == .approved else {
                throw OperationError.mcpClientNotApproved(id: clientID)
            }
            let now = DateFormatter.variorumISO8601.string(from: date.now)
            return try insertMCPGrant(db, clientID: clientID, spec: spec, now: now)
        }
    }

    private func insertMCPGrant(
        _ db: Database, clientID: String, spec: MCPGrantSpec, now: String
    ) throws -> String {
        switch spec.scopeKind {
        case .note:
            guard let facts = try Queries.mcpNoteFacts(db, noteID: spec.scopeID) else {
                throw OperationError.mcpGrantScopeNotFound(kind: spec.scopeKind.rawValue, id: spec.scopeID)
            }
            if facts.fence != nil, spec.duration == .always {
                throw OperationError.mcpGrantScopeFenced(kind: spec.scopeKind.rawValue, id: spec.scopeID)
            }
        case .book:
            guard let facts = try Queries.mcpBookFacts(db, readingID: spec.scopeID) else {
                throw OperationError.mcpGrantScopeNotFound(kind: spec.scopeKind.rawValue, id: spec.scopeID)
            }
            if facts.fence != nil {
                throw OperationError.mcpGrantScopeFenced(kind: spec.scopeKind.rawValue, id: spec.scopeID)
            }
        case .wing:
            let liveWing = try Bool.fetchOne(
                db, sql: "SELECT EXISTS (SELECT 1 FROM wing WHERE id = ? AND deleted_at IS NULL)",
                arguments: [spec.scopeID]) ?? false
            guard spec.scopeID.isEmpty || liveWing else {
                throw OperationError.mcpGrantScopeNotFound(kind: spec.scopeKind.rawValue, id: spec.scopeID)
            }
        }
        let id = newID()
        try db.execute(
            sql: """
                INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
            arguments: [id, clientID, spec.rung.rawValue, spec.scopeKind.rawValue, spec.scopeID,
                        spec.duration.rawValue, now])
        return id
    }

    /// **Revoke** one grant — immediate: the very next call reads it dead. A
    /// no-op on a grant already revoked.
    public func revokeMCPGrant(_ grantID: String) throws {
        try database.write { db in
            guard try Queries.mcpGrant(db, id: grantID) != nil else {
                throw OperationError.mcpGrantNotFound(id: grantID)
            }
            try db.execute(
                sql: "UPDATE mcp_grant SET revoked_at = ? WHERE id = ? AND revoked_at IS NULL",
                arguments: [DateFormatter.variorumISO8601.string(from: date.now), grantID])
        }
    }

    // MARK: - The server's in-transaction writes

    /// A once grant's one use, stamped inside the call that spends it.
    /// Refuses a grant that is not a live, unspent once grant — the read it
    /// guards must not proceed (a race between two calls cannot spend it
    /// twice: both run in serialized write transactions).
    public func consumeMCPOnceGrant(_ db: Database, _ grantID: String) throws {
        try db.execute(
            sql: """
                UPDATE mcp_grant SET consumed_at = ?
                WHERE id = ? AND duration = 'once' AND consumed_at IS NULL AND revoked_at IS NULL
                """,
            arguments: [DateFormatter.variorumISO8601.string(from: date.now), grantID])
        guard db.changesCount == 1 else { throw OperationError.mcpGrantNotFound(id: grantID) }
    }

    /// **"While connected" ends** — the client's last connection closed: its
    /// while-connected grants are revoked (R-13n-4; §9's "session = the MCP
    /// connection's lifetime").
    public func endMCPConnectionGrants(clientID: String) throws {
        try database.write { db in
            try db.execute(
                sql: """
                    UPDATE mcp_grant SET revoked_at = ?
                    WHERE client_id = ? AND duration = 'connection' AND revoked_at IS NULL
                    """,
                arguments: [DateFormatter.variorumISO8601.string(from: date.now), clientID])
        }
    }

    /// The server's START sweep: no connection survives a server stop (or a
    /// crash), so no while-connected grant may either.
    public func sweepMCPConnectionGrants() throws {
        try database.write { db in
            try db.execute(
                sql: "UPDATE mcp_grant SET revoked_at = ? WHERE duration = 'connection' AND revoked_at IS NULL",
                arguments: [DateFormatter.variorumISO8601.string(from: date.now)])
        }
    }

    /// One line of the coarse log (who · what · which target's title ·
    /// allowed or refused · when), then the cap.
    public func recordMCPActivity(
        _ db: Database, clientName: String, act: String, targetKind: String?, targetID: String?,
        targetTitle: String?, allowed: Bool
    ) throws {
        try db.execute(
            sql: """
                INSERT INTO mcp_activity (client_name, act, target_kind, target_id, target_title, outcome, at)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
            arguments: [clientName, act, targetKind, targetID, targetTitle,
                        allowed ? "allowed" : "refused",
                        DateFormatter.variorumISO8601.string(from: date.now)])
        try db.execute(
            sql: "DELETE FROM mcp_activity WHERE id <= (SELECT MAX(id) FROM mcp_activity) - ?",
            arguments: [Self.mcpActivityCap])
    }

    // MARK: - Adoption lands OFF (R-13nb-6)

    /// **A handed-off or restored library arrives with the server OFF,
    /// grants kept** (R-13nb-6, hers: "the restore-hold shape applied to the
    /// door"). Every 13x adoption writes a RESTORE HOLD beside the store with
    /// a fresh stamp (`LibraryRestoreHold` — both doors, before the move);
    /// the door calls this at the first ready that finds a hold standing,
    /// BEFORE any server start. When the hold's stamp is not yet
    /// acknowledged here, the `server` switch is written OFF and the stamp
    /// recorded — in ONE transaction, so an adopted library can never serve
    /// before the write, and a crash before it simply repeats it next ready.
    /// Once acknowledged, the same hold changes nothing — so her deliberate
    /// re-enable (the pane's toggle) stands for the rest of the hold's life
    /// (Resume clears the hold; a NEW adoption's hold carries a new stamp and
    /// lands OFF again). Grants, clients and the open book are untouched —
    /// they resume on the re-enable. The acknowledgement lives in the grants
    /// store (A-6's boundary-state home; local-only). Returns whether the
    /// switch was turned off by THIS call.
    @discardableResult
    public func landMCPAfterAdoption(holdStamp: String) throws -> Bool {
        try database.write { db in
            let acknowledged = try String.fetchOne(
                db, sql: "SELECT value FROM mcp_switch WHERE key = ?",
                arguments: [Queries.mcpAdoptionAckKey])
            guard acknowledged != holdStamp else { return false }
            let now = DateFormatter.variorumISO8601.string(from: date.now)
            for (key, value) in [(MCPSwitch.server.rawValue, "0"), (Queries.mcpAdoptionAckKey, holdStamp)] {
                try db.execute(
                    sql: """
                        INSERT INTO mcp_switch (key, value, updated_at) VALUES (?, ?, ?)
                        ON CONFLICT(key) DO UPDATE SET value = excluded.value, updated_at = excluded.updated_at
                        """,
                    arguments: [key, value, now])
            }
            return true
        }
    }

    // MARK: - The switches

    /// The server toggle or the open book (A-6). No-op-guarded.
    public func setMCPSwitch(_ key: MCPSwitch, on: Bool) throws {
        try database.write { db in
            guard try Queries.mcpSwitch(db, key) != on else { return }
            try db.execute(
                sql: """
                    INSERT INTO mcp_switch (key, value, updated_at) VALUES (?, ?, ?)
                    ON CONFLICT(key) DO UPDATE SET value = excluded.value, updated_at = excluded.updated_at
                    """,
                arguments: [key.rawValue, on ? "1" : "0", DateFormatter.variorumISO8601.string(from: date.now)])
        }
    }
}
