import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-925 — A DECLARED `clientInfo.version` HOLDING U+0000 IS STORED STRIPPED,
// NEVER TRUNCATED (the VX-940 run, W4; born at the VX-912 run's B4 as F-B4-2;
// the run record `notes/plans/fixes/vx-940-pre-oss-followups.md`, "## W4 record").
//
// THE MECHANISM: GRDB binds TEXT with length −1, so SQLite keeps a bound value
// only up to its first NUL (VX-357's trace). The admission writes the version a
// connection's `initialize` declared on two rows — `mcp_client.version` (every
// arm that refreshes or mints the client row, through `recordMCPContact`) and
// `mcp_rebind_request.version` (a key waiting for her OK) — and the pane shows it
// to her: the Clients row, and Waiting's "New setup for ‹name›", where the version
// is what tells her a stranger from the client she knows. A version
// "2.1.299\u{0}-stranger" was stored, and shown, as "2.1.299".
//
// THE RULE (VX-357, her ruling 2026-10-15): every U+0000 is removed and nothing
// else changes — `StoredText.stripped`, the operations layer's one road for
// caller-supplied text. The version is display text, never an identifier (it keys
// nothing — VX-396 refuses NUL only where an id is compared), so it takes the
// prose class's strip. Nothing is counted: no answer carries the admission's
// writes (the `initialize` answer is the SDK's server info), and a count would be
// a new wire field (PROVISIONAL P-940-W4-1 — the record).
//
// RED ON THE PRE-FIX TREE by assertion (pre-fix API only): every stored version
// read only the bytes before its first NUL — "2.1" (the minted row, and the
// admission's own client), "2.2", the waiting setup's "2.1.299", "3".

@Suite("VX-925 — a declared version holding U+0000 is stored stripped")
struct MCPClientVersionNullTests {
    private func storedVersion(_ db: AppDatabase, _ name: String) throws -> String? {
        try db.read { db in
            try String.fetchOne(db, sql: "SELECT version FROM mcp_client WHERE name = ?", arguments: [name])
        }
    }

    @Test func everyAdmissionRoadStoresTheVersionWithItsNullsRemoved() throws {
        try withOperations { ops, db in
            // The REQUEST arm (an unknown name, a fresh key): the client row is minted.
            let first = try ops.mintMCPSetupKey(copiedFor: "codex")
            let requested = try ops.admitMCPConnection(name: "codex", version: "2.1\u{0}-beta", presentedKey: first)
            #expect(requested.decision == .request)
            #expect(try storedVersion(db, "codex") == "2.1-beta", "minted: every U+0000 removed, nothing else")
            #expect(requested.client?.version == "2.1-beta", "the admission's own client reads the stored text")

            // The ADMIT arm (the same name, approved, its bound key): the row's
            // version refreshed.
            try ops.approveMCPClient(try #require(requested.client).id, granting: nil)
            let admitted = try ops.admitMCPConnection(
                name: "codex", version: "2.2\u{0}\u{0}rc", presentedKey: first)
            #expect(admitted.decision == .admit)
            #expect(try storedVersion(db, "codex") == "2.2rc", "refreshed: both removed, the rest kept in order")

            // The AWAIT arm (an untagged copy under an approved, bound name): the
            // waiting row carries the version her Allow / Don't allow reads.
            let own = try ops.mintMCPSetupKey(copiedFor: "claude-code")
            let client = try #require(
                try ops.admitMCPConnection(name: "claude-code", version: "2.1.299", presentedKey: own).client)
            let book = try ops.createReading(name: "drafts", kind: .book)
            try ops.approveMCPClient(
                client.id, granting: .init(rung: .read, scopeKind: .book, scopeID: book.id, duration: .always))
            let any = try ops.mintMCPSetupKey()
            let waiting = try ops.admitMCPConnection(
                name: "claude-code", version: "2.1.299\u{0}-stranger", presentedKey: any)
            #expect(waiting.decision == .awaitRebind)
            let requests = try db.read { try Queries.mcpRebindRequests($0) }
            #expect(requests.map(\.version) == ["2.1.299-stranger"],
                    "the waiting setup shows her the whole declared version, never the bytes before a NUL")
            #expect(try storedVersion(db, "claude-code") == "2.1.299", "the client row a wait never touches")

            // The ONE contact write, called directly (the shared row write every
            // arm above goes through).
            _ = try ops.recordMCPContact(name: "cursor", version: "3\u{0}.0")
            #expect(try storedVersion(db, "cursor") == "3.0")
        }
    }

    /// The guard (green on both sides): a version without a NUL is stored byte
    /// for byte, and a nil version stays nil — the strip touches nothing else.
    @Test func aVersionWithoutANullIsStoredExactlyAsDeclared() throws {
        try withOperations { ops, db in
            let key = try ops.mintMCPSetupKey(copiedFor: "codex")
            _ = try ops.admitMCPConnection(name: "codex", version: " 0.4\t(é) ", presentedKey: key)
            #expect(try storedVersion(db, "codex") == " 0.4\t(é) ")
            _ = try ops.admitMCPConnection(name: "codex", version: nil, presentedKey: key)
            #expect(try storedVersion(db, "codex") == nil)
        }
    }
}
