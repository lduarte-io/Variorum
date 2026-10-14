//
//  MCPSetupTabKeyTests.swift
//  VariorumTests (Mac)
//
//  VX-258 — THE MERGE GATE (VX-246 U1b, piece 1(a); the run record
//  `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`). U1 built the core:
//  a key copied FOR a client's name takes that name with zero clicks; any
//  other fresh key under an approved name waits for her OK. But the app's one
//  mint call site (`MCPDoor.copySetupCommand`) still minted every copy
//  UNTAGGED — so her re-run of Claude Code's own setup, under the approved
//  `claude-code`, WAITED for an OK the pane could not yet give. These pins read
//  the copy as a client presents it (pre-fix API only — red on the tree before
//  the mint call site passes the tab's name).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

/// An in-memory library with deterministic ids and clock (the setup menu's
/// harness, `MCPSetupMenuTests`).
@MainActor
private func withTabWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 258))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("VX-258 — each tab's copy carries its client's name (the merge gate)")
struct MCPSetupTabKeyTests {
    /// The name each tab's client declares in its `initialize` — Claude Code's
    /// seen live (VX-184 U1's round; re-read live at U1b's window, leg 0);
    /// Codex's from an EXTERNAL LOOKUP of its source (`codex-rs/codex-mcp`,
    /// `Implementation::new("codex-mcp-client", …)` — VX-246 U1's trace, item 6;
    /// Codex is not installed on the Pro); "Any MCP client" names nobody.
    private static let declared: [(MCPSetupClient, String?)] = [
        (.claudeCode, "claude-code"), (.codex, "codex-mcp-client"), (.anyClient, nil),
    ]

    private func copy(_ client: MCPSetupClient, door: MCPDoor) async throws -> String {
        let pasteboard = NSPasteboard(name: NSPasteboard.Name("variorum-vx258-tab-\(UUID().uuidString)"))
        defer { pasteboard.releaseGlobally() }
        await door.copySetupCommand(for: client, to: pasteboard)
        let copied = try #require(pasteboard.string(forType: .string), "the copy landed")
        let key = try #require(
            copied.firstMatch(of: #/VARIORUM_MCP_KEY(?:=|": ")"?(vmk[12]_[A-Za-z0-9._-]+)/#).map { String($0.output.1) },
            "the copied setup carries its key")
        return key
    }

    /// Each tab's copy carries the name of the client its setup is for — the
    /// tag the rule reads (`MCPSetupKeyRule.copiedFor`, authenticated by the
    /// hash) — and "Any MCP client"'s copy carries none.
    @Test func eachTabsCopyCarriesItsClientsName() async throws {
        try await withTabWorld { session, _ in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            for (client, name) in Self.declared {
                let key = try await copy(client, door: door)
                #expect(MCPSetupKeyRule.copiedFor(key) == name,
                        "\(client.label)'s copy is for \(name ?? "any client") — read \(key.prefix(9))…")
                if let name {
                    #expect(key.hasPrefix(MCPSetupKeyRule.copiedForPrefix + name + "_"), "the tagged form")
                } else {
                    #expect(key.hasPrefix(MCPSetupKeyRule.prefix), "the untagged form")
                }
            }
        }
    }

    /// **Her re-run of a client's OWN setup moves its approved name, zero
    /// clicks** (R-VX184-5 as she ruled it at VX-258): the name bound to its
    /// first key, approved; a fresh copy from that client's tab, presented
    /// under the name → `.rebind`, the name's key moved, its approval kept.
    @Test(arguments: [MCPSetupClient.claudeCode, .codex])
    func aClientsOwnSetupRerunMovesItsApprovedNameWithZeroClicks(_ client: MCPSetupClient) async throws {
        try await withTabWorld { session, db in
            let name = try #require(Self.declared.first { $0.0 == client }?.1)
            let ops = session.operations
            // The client as she knows it: approved, its first setup bound.
            let first = try ops.mintMCPSetupKey(copiedFor: name)
            let met = try ops.admitMCPConnection(name: name, version: "1.0", presentedKey: first)
            #expect(met.decision == .request, "premise: first contact is a connection request")
            let clientID = try #require(met.client?.id)
            _ = try ops.approveMCPClient(clientID, granting: nil)
            let firstHash = MCPSetupKeyRule.hash(first)
            #expect(try await db.read { try Queries.mcpSetupKeyHash($0, clientID: clientID) } == firstHash,
                    "premise: the first setup is bound")

            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let rerun = try await copy(client, door: door)
            let admitted = try ops.admitMCPConnection(name: name, version: "1.1", presentedKey: rerun)
            #expect(admitted.decision == .rebind,
                    "\(client.label)'s own setup, run again, moves its name — never waits (\(admitted.decision))")
            #expect(try await db.read { try Queries.mcpSetupKeyHash($0, clientID: clientID) }
                    == MCPSetupKeyRule.hash(rerun), "the name now holds the re-run's key")
            #expect(try await db.read { try Queries.mcpClient($0, id: clientID)?.state } == .approved,
                    "its approval stays")
            #expect(try await db.read { try Queries.mcpRebindRequests($0) }.isEmpty, "nothing waits on her")
        }
    }

    /// The control (green on both sides): an "Any MCP client" copy presented
    /// under an approved, bound name waits for her OK — the hole VX-258
    /// closed stays closed.
    @Test func anAnyClientCopyUnderAnApprovedNameWaitsForHerOK() async throws {
        try await withTabWorld { session, db in
            let ops = session.operations
            let first = try ops.mintMCPSetupKey(copiedFor: "claude-code")
            let met = try ops.admitMCPConnection(name: "claude-code", version: "1.0", presentedKey: first)
            let clientID = try #require(met.client?.id)
            _ = try ops.approveMCPClient(clientID, granting: nil)

            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let any = try await copy(.anyClient, door: door)
            let admitted = try ops.admitMCPConnection(name: "claude-code", version: "9.9", presentedKey: any)
            #expect(admitted.decision == .awaitRebind, "an Any-client copy waits for her OK")
            #expect(try await db.read { try Queries.mcpSetupKeyHash($0, clientID: clientID) }
                    == MCPSetupKeyRule.hash(first), "the name keeps its own key")
            #expect(try await db.read { try Queries.mcpRebindRequests($0) }.map(\.clientName) == ["claude-code"])
        }
    }
}
