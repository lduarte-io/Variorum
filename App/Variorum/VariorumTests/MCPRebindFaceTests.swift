//
//  MCPRebindFaceTests.swift
//  VariorumTests (Mac)
//
//  VX-258's FACE (VX-246 U1b, piece 1 (b)–(d); the run record
//  `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`). U1 built the core: a
//  key presented under the name of a client she approved, which it was not
//  copied for, WAITS for her OK — admitted with no reach, one local-only
//  `mcp_rebind_request` row per client. These pins hold the face that answers
//  it: the door's snapshot carries the waiting setups (Waiting's re-bind rows),
//  her Allow and Don't allow reach the core's two ops, a press on a setup no
//  longer waiting says so by Waiting, her Activity speaks the three acts in
//  words, and the truth lines (L1, the key's line) say the rule as built. The
//  row's look is the walk's (both voices) — these are its state transitions.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

/// An in-memory library with deterministic ids and clock (the setup menu's
/// harness).
@MainActor
private func withRebindWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 2581))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("VX-258 — a setup waiting for her OK, on the pane (VX-246 U1b)", .serialized)
struct MCPRebindFaceTests {
    /// The client she knows: `claude-code`, approved, its own setup bound.
    /// Returns its id and the bound key.
    private func approvedClaudeCode(_ ops: Operations) throws -> (id: String, key: String) {
        let key = try ops.mintMCPSetupKey(copiedFor: "claude-code")
        let met = try ops.admitMCPConnection(name: "claude-code", version: "2.1.299", presentedKey: key)
        let id = try #require(met.client?.id)
        _ = try ops.approveMCPClient(id, granting: nil)
        return (id, key)
    }

    /// A stranger's "Any MCP client" copy, presented as `claude-code`: it waits.
    private func strangerWaits(_ ops: Operations) throws -> String {
        let key = try ops.mintMCPSetupKey()
        let met = try ops.admitMCPConnection(name: "claude-code", version: "0.0.1-stranger", presentedKey: key)
        #expect(met.decision == .awaitRebind, "premise: an Any-client copy under an approved name waits")
        return key
    }

    private func pump(_ seconds: TimeInterval = 0.01) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// Lets the door's observation deliver until `condition` holds.
    private func settle(until condition: () -> Bool, turns: Int = 200) async {
        for _ in 0..<turns {
            if condition() { return }
            pump()
            await Task.yield()
        }
    }

    // MARK: - (b) the snapshot and her two answers

    /// Waiting's re-bind row reads the store: the door's snapshot carries the
    /// waiting setup — the client it would bind and the version its connection
    /// declared (what tells her a stranger from the client she knows) — and
    /// ⌥⌘,'s landing counts it as waiting.
    @Test func aWaitingSetupReachesTheDoorsSnapshot() async throws {
        try await withRebindWorld { session, _ in
            let ops = session.operations
            _ = try approvedClaudeCode(ops)
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            await settle(until: { door.snapshot.approvedCount == 1 })
            #expect(door.snapshot.rebinds.isEmpty && door.waitingCount == 0, "premise: nothing waits")

            _ = try strangerWaits(ops)
            await settle(until: { !door.snapshot.rebinds.isEmpty })
            let row = try #require(door.snapshot.rebinds.first, "the waiting setup reaches the pane")
            #expect(row.clientName == "claude-code")
            #expect(row.version == "0.0.1-stranger", "the stranger's own declared version")
            #expect(door.waitingCount == 1, "⌥⌘, lands on Waiting while a setup waits")
            #expect(MCPPane.scrollsToWaiting(request: 1, scrolled: 0, waitingCount: door.waitingCount))
        }
    }

    /// Her **Allow**: the waiting key takes the name — approval and grants
    /// untouched — the row leaves, and her Activity says what she did.
    @Test func herAllowMovesTheNameAndTheRowLeaves() async throws {
        try await withRebindWorld { session, db in
            let ops = session.operations
            let known = try approvedClaudeCode(ops)
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let stranger = try strangerWaits(ops)
            await settle(until: { !door.snapshot.rebinds.isEmpty })
            let row = try #require(door.snapshot.rebinds.first)

            door.allowRebind(row.id)
            await settle(until: { door.snapshot.rebinds.isEmpty })
            #expect(door.snapshot.rebinds.isEmpty, "the row leaves with the store")
            #expect(try await db.read { try Queries.mcpSetupKeyHash($0, clientID: known.id) }
                    == MCPSetupKeyRule.hash(stranger), "the name now holds the setup she allowed")
            #expect(try await db.read { try Queries.mcpClient($0, id: known.id)?.state } == .approved)
            #expect(door.note == nil, "an answer that landed speaks no caption")
            let acts = try await db.read { try Queries.mcpActivity($0) }.map(\.act)
            #expect(acts.contains(MCPSetupKeyRule.rebindAllowedAct), "her Allow is logged")
        }
    }

    /// Her **Don't allow**: the waiting key is forgotten, the name keeps its
    /// own, and the turned-down key's next connection is refused.
    @Test func herDontAllowForgetsTheKeyAndTheRowLeaves() async throws {
        try await withRebindWorld { session, db in
            let ops = session.operations
            let known = try approvedClaudeCode(ops)
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            let stranger = try strangerWaits(ops)
            await settle(until: { !door.snapshot.rebinds.isEmpty })
            let row = try #require(door.snapshot.rebinds.first)

            door.declineRebind(row.id)
            await settle(until: { door.snapshot.rebinds.isEmpty })
            #expect(door.snapshot.rebinds.isEmpty, "the row leaves with the store")
            #expect(try await db.read { try Queries.mcpSetupKeyHash($0, clientID: known.id) }
                    == MCPSetupKeyRule.hash(known.key), "the name keeps its own setup")
            let again = try ops.admitMCPConnection(name: "claude-code", version: "0.0.1-stranger", presentedKey: stranger)
            #expect(!again.decision.admits, "the turned-down setup is refused next time (\(again.decision))")
            #expect(try ops.admitMCPConnection(name: "claude-code", version: "2.1.299", presentedKey: known.key)
                .decision == .admit, "the client she knows never notices")
        }
    }

    /// A press on a setup no longer waiting (answered elsewhere, its client
    /// denied, a library adopted) is a door that did nothing — it SAYS so, by
    /// Waiting, where she pressed (Settings has no status seam).
    @Test func anAnswerToASetupNoLongerWaitingSaysSoByWaiting() async throws {
        try await withRebindWorld { session, _ in
            let door = MCPDoor(serverAllowed: false)
            door.attach(session: session)
            defer { door.detach() }
            door.allowRebind("no-such-setup")
            await settle(until: { door.note != nil })
            #expect(door.note == MCPDoor.Note(text: "That setup isn't waiting any more.", place: .waiting))
            door.note = nil
            door.declineRebind("no-such-setup")
            await settle(until: { door.note != nil })
            #expect(door.note == MCPDoor.Note(text: "That setup isn't waiting any more.", place: .waiting))
            #expect(MCPPaneCopy.refusal(OperationError.mcpRebindRequestNotFound(id: "x"))
                    == "That setup isn't waiting any more.")
        }
    }

    // MARK: - (b) the declarations (P-1)

    @Test func theRebindDoorsAreThePanesSurfaceActsWithTheirVerbs() {
        #expect(MCPPane.surfaceCapabilities.contains(.mcpAllowRebind))
        #expect(MCPPane.surfaceCapabilities.contains(.mcpDeclineRebind))
        #expect(CapabilityRegistry.capability(.mcpAllowRebind).verb == "Allow")
        #expect(CapabilityRegistry.capability(.mcpDeclineRebind).verb == MCPAskCopy.dontAllow,
                "the ask sheet's own word, one source")
        for id in [CapabilityID.mcpAllowRebind, .mcpDeclineRebind] {
            #expect(CapabilityRegistry.capability(id).doors == [.surface], "\(id) is answered where it waits")
        }
    }

    // MARK: - (c) the words

    private func line(_ act: String, allowed: Bool, kind: String? = nil, count: Int = 1) -> String {
        MCPPaneCopy.activityLine(MCPActivityFace.Line(
            id: 1, clientName: "claude-code", act: act, targetKind: kind,
            targetID: kind == nil ? nil : "0f0f", targetTitle: nil, allowed: allowed, count: count,
            at: "2026-10-14T00:00:00.000Z"))
    }

    /// Her Activity says each act in words — never an act id, never a key's
    /// hash (the Allow row carries the replaced key's hash as its target).
    @Test func everySetupActSpeaksInWords() {
        #expect(line(MCPSetupKeyRule.awaitingAct, allowed: false)
                == "claude-code asked to use a setup that wasn't copied for it")
        #expect(line(MCPSetupKeyRule.awaitingAct, allowed: false, count: 2)
                == "claude-code asked to use a setup that wasn't copied for it (2 times)")
        #expect(line(MCPSetupKeyRule.rebindAllowedAct, allowed: true, kind: MCPSetupKeyRule.replacedTargetKind)
                == "claude-code took the new setup you allowed, which replaced its earlier one")
        #expect(line(MCPSetupKeyRule.rebindAllowedAct, allowed: true)
                == "claude-code took the new setup you allowed", "an unbound name replaced nothing")
        #expect(line(MCPSetupKeyRule.rebindDeclinedAct, allowed: false)
                == "claude-code\u{2019}s new setup wasn\u{2019}t allowed")
        for act in [MCPSetupKeyRule.awaitingAct, MCPSetupKeyRule.rebindAllowedAct, MCPSetupKeyRule.rebindDeclinedAct] {
            let said = line(act, allowed: act == MCPSetupKeyRule.rebindAllowedAct, kind: MCPSetupKeyRule.replacedTargetKind)
            #expect(!said.contains("_") && !said.contains("0f0f") && !said.contains("refused"), "\(act): \(said)")
        }
    }

    /// The row's words: who, the declared version, what each answer does — no
    /// "AI" (VX-272), no shouted word.
    @Test func theRowSaysWhoWhenAndWhatEachAnswerDoes() {
        #expect(MCPPaneCopy.rebindTitle("claude-code") == "New setup for claude-code")
        let detail = MCPPaneCopy.rebindDetail(name: "claude-code", version: "9.9", firstSeen: "2 minutes ago")
        #expect(detail == "Connected as claude-code (version 9.9) with a setup that wasn't copied for it, "
                + "2 minutes ago. It reaches nothing until you allow it; allowing moves the name, with its grants, "
                + "to this setup.")
        #expect(!MCPPaneCopy.rebindDetail(name: "x", version: nil, firstSeen: "now").contains("version"),
                "no version declared, none said")
        for text in [MCPPaneCopy.rebindTitle("claude-code"), detail] {
            #expect(text.range(of: #"\bAI\b"#, options: .regularExpression) == nil, "VX-272: \(text)")
            #expect(text.range(of: #"\b(?!MCP\b|JSON\b)[A-Z]{3,}\b"#, options: .regularExpression) == nil, "\(text)")
        }
    }

    // MARK: - (d) the truth lines, against the rule they describe

    /// L1 and the key's line say the rule as built — the client's OWN setup,
    /// run again, moves the name; an "Any MCP client" copy waits for her OK
    /// before it takes a name she approved; any other key, or none, is
    /// refused — each clause pinned against `MCPSetupKeyRule.decide`.
    @Test func theTruthLinesSayTheRuleAsBuilt() {
        for text in [MCPPaneCopy.clientBoundary, MCPPaneCopy.keyLine] {
            #expect(text.contains("own setup again"), "a client's own setup re-run: \(text)")
            #expect(text.contains("a setup copied for any MCP client waits for your OK before it takes a name you approved"))
        }
        #expect(MCPPaneCopy.clientBoundary.contains("any other key, or none, is refused"))
        #expect(MCPPaneCopy.keySummary.contains("own setup again"), "the line never promises the Any road")
        #expect(MCPPaneCopy.clientBoundarySummary.contains("not programs running as you"), "L1's line, still true")
        let bound = MCPSetupKeyRule.Client(id: "c", boundHash: MCPSetupKeyRule.hash("vmk1_first"))
        let fresh = MCPSetupKeyRule.hash("vmk1_fresh")
        #expect(MCPSetupKeyRule.decide(name: "claude-code", client: bound, presentedHash: fresh,
                                       copiedFor: "claude-code", standing: .unclaimed) == .rebind,
                "the client's own setup, run again, moves the name")
        #expect(MCPSetupKeyRule.decide(name: "claude-code", client: bound, presentedHash: fresh, standing: .unclaimed)
                == .awaitRebind, "an Any-client copy waits for her OK")
        #expect(MCPSetupKeyRule.decide(name: "claude-code", client: bound, presentedHash: fresh, standing: .replaced)
                == .refuse(.replaced), "another key is refused")
        #expect(MCPSetupKeyRule.decide(name: "claude-code", client: bound, presentedHash: nil, standing: .unknown)
                == .refuse(.bare), "…or none")
    }
}
