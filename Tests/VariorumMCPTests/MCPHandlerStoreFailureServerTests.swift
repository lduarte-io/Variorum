import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-776 (the VX-808 run, Unit B5 — the VX-369 sweep's row 19, deferred at the
// VX-771 run because no headless store can fail a READ): a store read that fails
// inside `MCPSession`'s SDK handlers — the standing read behind `tools/list`, the
// waiting-key check behind every `tools/call` — left the handler as a throw, and
// the SDK answered it with a JSON-RPC internal error carrying the error's
// `localizedDescription`: GRDB's description, the executed SQL included. THE
// FAILING READER (`MCPServerHost.handlerReadProbe`, DEBUG-only — `MCPSession.
// handlerRead`) makes such a read fail as a broken store does; both handlers now
// speak through THE ONE CHAIN (`MCPWireRefusalCopy`, P-771-11's form: SQLite's code
// and its own message, never the SQL, no claim about what landed). RED ON OLD.

/// The store-failure sentence (PROVISIONAL P-771-11), spelled here so the pins
/// compile and run on the tree before the words.
private func storeWords(_ detail: String) -> String {
    "Variorum's library store refused the work (\(detail)), so this call may not have landed — read what it "
        + "touches before trying again."
}

/// A failing read, as GRDB raises it for a broken store (its description names
/// the executed SQL).
private let ioError = DatabaseError(
    resultCode: .SQLITE_IOERR, message: "disk I/O error",
    sql: "SELECT secret_column FROM mcp_client WHERE name = ?")

@Suite("VX-776 — a store read failing in the SDK handlers is worded, never GRDB's text", .serialized)
struct MCPHandlerStoreFailureServerTests {
    /// `tools/list` on an approved connection whose standing read fails: the
    /// JSON-RPC error's words are the store-failure sentence, never GRDB's text.
    @Test func aFailingStandingReadBehindTheToolListIsWorded() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
            #expect(!(try await connection.client.listTools().tools.isEmpty), "non-vacuity: it lists")
            h.host.handlerReadProbe = { throw ioError }
            defer { h.host.handlerReadProbe = nil }
            var said: String?
            do {
                _ = try await connection.client.listTools()
                Issue.record("the failing read listed tools")
            } catch let error as MCPError {
                if case .internalError(let detail) = error { said = detail }
                else { Issue.record("an internal error, as before: \(error)") }
            }
            #expect(said == storeWords("SQLite error 10: disk I/O error"), "\(said ?? "-")")
            #expect(!(said ?? "").contains("while executing") && !(said ?? "").contains("secret_column"),
                    "never the executed SQL: \(said ?? "-")")
            h.host.handlerReadProbe = nil
            #expect(!(try await connection.client.listTools().tools.isEmpty), "the store back, it lists again")
            await h.hangUp(connection)
        }
    }

    /// A `tools/call` on a connection whose key waits for her OK, its waiting
    /// check failing: a TOOL RESULT (isError), in the store-failure words —
    /// the catch-all families' shape — never the SDK's raw internal error.
    @Test func aFailingWaitingCheckBehindACallIsWordedAsAToolResult() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let real = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
            await h.hangUp(real)
            // An "Any MCP client" copy under her approved name: it waits.
            let waiting = try await h.connect(as: "claude-code", presenting: try h.operations.mintMCPSetupKey())
            #expect(try await waiting.client.listTools().tools.isEmpty, "non-vacuity: it waits for her OK")
            h.host.handlerReadProbe = { throw ioError }
            defer { h.host.handlerReadProbe = nil }
            var answer: (content: [Tool.Content], isError: Bool?)?
            var raw: String?
            do {
                answer = try await waiting.client.callTool(name: "list_books", arguments: [:])
            } catch {
                raw = "\(error)"
            }
            #expect(raw == nil, "a tool result, never the SDK's internal error: \(raw ?? "-")")
            if let answer {
                #expect(answer.isError == true)
                #expect(text(answer) == storeWords("SQLite error 10: disk I/O error"), "\(text(answer))")
                #expect(!text(answer).contains("while executing"), "never the executed SQL")
            }
            await h.hangUp(waiting)
        }
    }
}
