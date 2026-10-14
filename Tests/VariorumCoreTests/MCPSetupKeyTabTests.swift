import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-258 — SETUP KEYS TIED TO THEIR TAB; AN ANY-CLIENT RE-BIND WAITS FOR HER OK
// (VX-184's ladder, round 1's MAJOR; her ruling: "tie keys to their tab and for
// the general "Any MCP client" case, we should probably do the re-bind waits for
// my ok? i don't want everyone who isn't using claude or codex to be vulnerable
// to this. the best protection at each level"; the run record
// `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U1 — "VX-258").
//
// THE RED-FIRST PINS, on the PRE-FIX API only (`mintMCPSetupKey()`,
// `admitMCPConnection`, the rows): VX-168's impostor returns — a fresh MINT (the
// "Any MCP client" copy she hands a tool she is trying) presented under a BOUND,
// APPROVED name must not take that name, its approval or its grants; and the
// same under a known, approved, UNBOUND name (the bind arm — after an adoption,
// a Deny-then-approve, or a client approved before VX-168). Watched RED on the
// pre-fix tree, where the first re-bound the name and the second bound it.

@Suite("VX-258 — a fresh mint never takes a name that carries her approval (pre-fix API)")
struct MCPSetupKeyImpostorTests {
    private func boundHash(_ db: AppDatabase, _ name: String) throws -> String? {
        try db.read { db in
            try String.fetchOne(db, sql: "SELECT setup_key_hash FROM mcp_client WHERE name = ?", arguments: [name])
        }
    }

    @Test func aFreshMintUnderABoundApprovedNameTakesNothing() throws {
        try withOperations { ops, db in
            let first = try ops.mintMCPSetupKey()
            let client = try #require(
                try ops.admitMCPConnection(name: "claude-code", version: "2.1", presentedKey: first).client)
            let book = try ops.createReading(name: "drafts", kind: .book)
            try ops.approveMCPClient(
                client.id, granting: .init(rung: .edit, scopeKind: .book, scopeID: book.id, duration: .always))

            // VX-168's impostor, restored: the "Any MCP client" copy she gave a
            // tool she is trying — which calls itself claude-code.
            let impostor = try ops.mintMCPSetupKey()
            _ = try ops.admitMCPConnection(name: "claude-code", version: "9.9", presentedKey: impostor)
            #expect(try boundHash(db, "claude-code") == MCPSetupKeyRule.hash(first), "the name keeps its own key")
            let after = try #require(try db.read { try Queries.mcpClient($0, id: client.id) })
            #expect(after.state == .approved && after.version == "2.1", "the row the impostor claimed is untouched")
            #expect(try db.read { try Queries.mcpGrants($0, clientID: client.id) }.count == 1, "her grants stay hers")
            #expect(try ops.admitMCPConnection(name: "claude-code", version: "2.2", presentedKey: first).decision.admits,
                    "the real client still connects")
        }
    }

    @Test func aFreshMintUnderAnApprovedUnboundNameTakesNothing() throws {
        try withOperations { ops, db in
            let client = try ops.recordMCPContact(name: "claude-code", version: "2.1")
            let book = try ops.createReading(name: "drafts", kind: .book)
            try ops.approveMCPClient(
                client.id, granting: .init(rung: .edit, scopeKind: .book, scopeID: book.id, duration: .always))
            #expect(try boundHash(db, "claude-code") == nil, "approved, no key bound (an adopted library's posture)")

            let impostor = try ops.mintMCPSetupKey()
            _ = try ops.admitMCPConnection(name: "claude-code", version: "9.9", presentedKey: impostor)
            #expect(try boundHash(db, "claude-code") == nil, "an untagged copy does not bind an approved name")
            #expect(try db.read { try Queries.mcpClient($0, id: client.id) }?.version == "2.1", "the row untouched")
        }
    }
}
