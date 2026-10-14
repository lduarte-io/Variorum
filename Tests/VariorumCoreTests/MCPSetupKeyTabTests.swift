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

@Suite("VX-258 — the tab tag in the key, and the rule's arms")
struct MCPSetupKeyTabRuleTests {
    private typealias Rule = MCPSetupKeyRule
    private let bytes = Data((0..<32).map { UInt8(truncatingIfNeeded: $0 &* 37 &+ 250) })
    private let fresh = Rule.hash("vmk2_claude-code_fresh")

    @Test func aKeyCopiedForAClientCarriesItsNameInItsAuthenticatedText() {
        let tagged = Rule.key(fromRandomBytes: bytes, copiedFor: "claude-code")
        let untagged = Rule.key(fromRandomBytes: bytes)
        #expect(tagged.hasPrefix("vmk2_claude-code_") && tagged.count == "vmk2_claude-code_".count + 43)
        #expect(untagged.hasPrefix(Rule.prefix) && untagged.count == Rule.prefix.count + 43, "the Any-client form is VX-168's")
        #expect(Rule.copiedFor(tagged) == "claude-code")
        #expect(Rule.copiedFor(untagged) == nil, "an untagged key carries no name")
        #expect(Rule.copiedFor(Rule.key(fromRandomBytes: bytes, copiedFor: "my_tool.v2")) == "my_tool.v2",
                "the name is read from the right, so it may hold _")
        #expect(Rule.hash(tagged) != Rule.hash(tagged.replacingOccurrences(of: "claude-code", with: "my-tool")),
                "the hash covers the tag: an edited tag is a key never minted")
        for malformed in ["vmk2_", "vmk2_claude-code", "vmk2_claude-code-" + String(untagged.suffix(43)),
                          "vmk2__" + String(untagged.suffix(43)), "vmk2_bad name_" + String(untagged.suffix(43))] {
            #expect(Rule.copiedFor(malformed) == nil, "\(malformed)")
        }
        #expect(MCPPreamble_keyIsSpeakable(tagged), "the shim speaks it as written")
    }

    @Test func onlyAShellSafeShortNameIsCarried() {
        #expect(Rule.canCarry("claude-code") && Rule.canCarry("codex-mcp-client") && Rule.canCarry("a.b_c-9"))
        #expect(Rule.canCarry(String(repeating: "a", count: 64)))
        for bad in ["", String(repeating: "a", count: 65), "two words", "naïve", "a/b", "a\"b", "a$b"] {
            #expect(!Rule.canCarry(bad), "\(bad)")
        }
    }

    /// The design's table, arm by arm (the run record's U1 — "VX-258", the
    /// design 2).
    @Test func everyArmOfTheTable() {
        let approvedBound = Rule.Client(id: "cl1", boundHash: Rule.hash("own"), approved: true)
        let approvedUnbound = Rule.Client(id: "cl1", boundHash: nil, approved: true)
        let pendingBound = Rule.Client(id: "cl1", boundHash: Rule.hash("own"), approved: false)
        let deniedUnbound = Rule.Client(id: "cl1", boundHash: nil, approved: false)
        func decide(_ client: Rule.Client?, _ tag: String?, _ standing: Rule.KeyStanding, name: String = "claude-code")
            -> Rule.Decision {
            Rule.decide(name: name, client: client, presentedHash: fresh, copiedFor: tag, standing: standing)
        }
        // A bound, approved name.
        #expect(Rule.decide(name: "claude-code", client: approvedBound, presentedHash: Rule.hash("own"),
                            copiedFor: nil, standing: .boundTo(clientID: "cl1")) == .admit)
        #expect(decide(approvedBound, "claude-code", .unclaimed) == .rebind, "its own tab: zero clicks")
        #expect(decide(approvedBound, nil, .unclaimed) == .awaitRebind, "Any MCP client: her OK")
        #expect(decide(approvedBound, "codex-mcp-client", .unclaimed) == .awaitRebind, "another tab: her OK (P-VX258-1)")
        // A known, approved, UNBOUND name (P-VX258-2).
        #expect(decide(approvedUnbound, "claude-code", .unclaimed) == .bind)
        #expect(decide(approvedUnbound, nil, .unclaimed) == .awaitRebind)
        #expect(decide(approvedUnbound, "codex-mcp-client", .unclaimed) == .awaitRebind)
        // No approval to inherit: the arms as they were, whatever the tag.
        for tag in [nil, "claude-code", "codex-mcp-client"] as [String?] {
            #expect(decide(pendingBound, tag, .unclaimed) == .rebind)
            #expect(decide(deniedUnbound, tag, .unclaimed) == .bind)
            #expect(decide(nil, tag, .unclaimed) == .request, "first contact is always her approval's")
        }
        // A key waiting under a name.
        #expect(decide(approvedBound, nil, .awaiting(clientID: "cl1")) == .awaitRebind, "it still waits")
        #expect(decide(approvedBound, nil, .awaiting(clientID: "cl2")) == .refuse(.anotherNamesKey))
        #expect(decide(nil, nil, .awaiting(clientID: "cl2")) == .refuse(.anotherNamesKey))
        // The refusals as before.
        #expect(decide(approvedBound, "claude-code", .replaced) == .refuse(.replaced))
        #expect(decide(approvedBound, "claude-code", .unknown) == .refuse(.notThisNamesKey))
        #expect(decide(approvedUnbound, nil, .unknown) == .refuse(.notIssued))
        #expect(decide(approvedBound, nil, .boundTo(clientID: "cl9")) == .refuse(.notThisNamesKey))
        #expect(decide(approvedUnbound, nil, .boundTo(clientID: "cl9")) == .refuse(.anotherNamesKey))
        #expect(Rule.decide(name: "claude-code", client: approvedBound, presentedHash: nil, copiedFor: "claude-code",
                            standing: .unclaimed) == .refuse(.bare))
        #expect(Rule.Decision.awaitRebind.admits, "admitted — to a request's face")
        #expect(Set([Rule.awaitingAct, Rule.rebindAllowedAct, Rule.rebindDeclinedAct]).count == 3)
        #expect(Set(Rule.Refusal.allCases.map(Rule.activityAct)).isDisjoint(
            with: [Rule.awaitingAct, Rule.rebindAllowedAct, Rule.rebindDeclinedAct]))
    }
}

/// The preamble's own speakability check, without importing the socket module
/// into the core tests (its rule: printable ASCII, no spaces, ≤ 256).
private func MCPPreamble_keyIsSpeakable(_ key: String) -> Bool {
    key.utf8.count <= 256 && key.utf8.allSatisfy { $0 > 0x20 && $0 < 0x7F }
}

@Suite("VX-258 — a setup waiting for her OK (the operations)")
struct MCPSetupKeyWaitTests {
    private func boundHash(_ db: AppDatabase, _ name: String) throws -> String? {
        try db.read { db in
            try String.fetchOne(db, sql: "SELECT setup_key_hash FROM mcp_client WHERE name = ?", arguments: [name])
        }
    }

    private func log(_ db: AppDatabase) throws -> [String] {
        try db.read { db in
            try Row.fetchAll(db, sql: "SELECT client_name, act, outcome FROM mcp_activity ORDER BY id")
                .map { "\($0["client_name"] as String) \($0["act"] as String) \($0["outcome"] as String)" }
        }
    }

    /// claude-code, set up from its own tab and approved with a grant.
    private func approvedClaudeCode(_ ops: Operations) throws -> (client: MCPClient, key: String) {
        let key = try ops.mintMCPSetupKey(copiedFor: "claude-code")
        let client = try #require(try ops.admitMCPConnection(name: "claude-code", version: "2.1", presentedKey: key).client)
        let book = try ops.createReading(name: "drafts", kind: .book)
        try ops.approveMCPClient(
            client.id, granting: .init(rung: .edit, scopeKind: .book, scopeID: book.id, duration: .always))
        return (try #require(try ops.database.read { try Queries.mcpClient($0, id: client.id) }), key)
    }

    @Test func aTabCopyMintsItsNameIntoTheKeyAndABadNameMintsNothing() throws {
        try withOperations { ops, db in
            let key = try ops.mintMCPSetupKey(copiedFor: "claude-code")
            #expect(MCPSetupKeyRule.copiedFor(key) == "claude-code")
            #expect(try db.read { try Queries.mcpSetupKeyStanding($0, hash: MCPSetupKeyRule.hash(key)) } == .unclaimed)
            #expect(throws: OperationError.mcpInvalidClientName(name: "two words")) {
                try ops.mintMCPSetupKey(copiedFor: "two words")
            }
            #expect(try db.read { try Queries.mcpUnclaimedSetupKeyCount($0) } == 1, "a refused mint keeps nothing")
        }
    }

    @Test func anUntaggedCopyUnderAnApprovedNameWaitsReachingNothing() throws {
        try withOperations { ops, db in
            let (client, own) = try approvedClaudeCode(ops)
            let before = try #require(try db.read { try Queries.mcpClient($0, id: client.id) })
            let any = try ops.mintMCPSetupKey()
            let waiting = try ops.admitMCPConnection(name: "claude-code", version: "0.1", presentedKey: any)
            #expect(waiting.decision == .awaitRebind && waiting.client?.id == client.id)
            #expect(try boundHash(db, "claude-code") == MCPSetupKeyRule.hash(own), "the name keeps its key")
            #expect(try db.read { try Queries.mcpClient($0, id: client.id) } == before, "the row untouched")
            #expect(try db.read { try Queries.mcpUnclaimedSetupKeyCount($0) } == 0, "claimed — it left the set")
            #expect(try db.read { try Queries.mcpSetupKeyStanding($0, hash: MCPSetupKeyRule.hash(any)) }
                    == .awaiting(clientID: client.id))
            let requests = try db.read { try Queries.mcpRebindRequests($0) }
            #expect(requests.count == 1 && requests[0].clientName == "claude-code" && requests[0].version == "0.1")

            // Presented again: still waiting, nothing new written.
            #expect(try ops.admitMCPConnection(name: "claude-code", version: "0.1", presentedKey: any).decision
                    == .awaitRebind)
            #expect(try db.read { try Queries.mcpRebindRequests($0) } == requests)
            // Under another name it is another name's key.
            #expect(try ops.admitMCPConnection(name: "stranger", version: nil, presentedKey: any).decision
                    == .refuse(.anotherNamesKey))
            // The real client never notices.
            #expect(try ops.admitMCPConnection(name: "claude-code", version: "2.1", presentedKey: own).decision == .admit)
            #expect(try log(db) == [
                "claude-code \(MCPSetupKeyRule.awaitingAct) refused",
                "stranger connect_another_names_key refused",
            ], "the wait is said once; a refusal of the claimed key is precise")
        }
    }

    @Test func aNewerWaitForTheSameNameReplacesTheOlder() throws {
        try withOperations { ops, db in
            _ = try approvedClaudeCode(ops)
            let older = try ops.mintMCPSetupKey()
            _ = try ops.admitMCPConnection(name: "claude-code", version: "0.1", presentedKey: older)
            let newer = try ops.mintMCPSetupKey()
            _ = try ops.admitMCPConnection(name: "claude-code", version: "0.2", presentedKey: newer)
            let requests = try db.read { try Queries.mcpRebindRequests($0) }
            #expect(requests.map(\.version) == ["0.2"], "one waiting setup per name — the newer")
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: older).decision
                    == .refuse(.notThisNamesKey), "the older key is forgotten: the one sentence")
        }
    }

    @Test func herAllowBindsTheWaitingKeyAndTheReplacedKeyHearsItsOwnReason() throws {
        try withOperations { ops, db in
            let (client, own) = try approvedClaudeCode(ops)
            let any = try ops.mintMCPSetupKey()
            _ = try ops.admitMCPConnection(name: "claude-code", version: "0.1", presentedKey: any)
            let request = try #require(try db.read { try Queries.mcpRebindRequests($0) }.first)

            let allowed = try ops.allowMCPRebind(request.id)
            #expect(allowed.id == client.id && allowed.state == .approved && allowed.isSetupBound)
            #expect(try boundHash(db, "claude-code") == MCPSetupKeyRule.hash(any))
            #expect(try db.read { try Queries.mcpRebindRequests($0) }.isEmpty)
            #expect(try db.read { try Queries.mcpGrants($0, clientID: client.id) }.count == 1, "her grants kept")
            #expect(try ops.admitMCPConnection(name: "claude-code", version: "0.1", presentedKey: any).decision == .admit)
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: own).decision
                    == .refuse(.replaced), "the key she replaced hears its own sentence")
            let allowedRow = try db.read { db in
                try Row.fetchOne(db, sql: "SELECT target_kind, target_id, outcome FROM mcp_activity WHERE act = ?",
                                 arguments: [MCPSetupKeyRule.rebindAllowedAct])
            }
            #expect(allowedRow?["target_kind"] as String? == MCPSetupKeyRule.replacedTargetKind)
            #expect(allowedRow?["target_id"] as String? == MCPSetupKeyRule.hash(own))
            #expect(allowedRow?["outcome"] as String? == "allowed")
            #expect(throws: OperationError.mcpRebindRequestNotFound(id: request.id), "an answered ask is gone") {
                try ops.allowMCPRebind(request.id)
            }
        }
    }

    @Test func herAllowOnAnUnboundNameBinds() throws {
        try withOperations { ops, db in
            let client = try ops.recordMCPContact(name: "claude-code", version: "2.1")
            try ops.approveMCPClient(client.id, granting: nil)
            let any = try ops.mintMCPSetupKey()
            #expect(try ops.admitMCPConnection(name: "claude-code", version: "0.1", presentedKey: any).decision
                    == .awaitRebind)
            let request = try #require(try db.read { try Queries.mcpRebindRequests($0) }.first)
            _ = try ops.allowMCPRebind(request.id)
            #expect(try boundHash(db, "claude-code") == MCPSetupKeyRule.hash(any))
            #expect(try db.read { db in
                try Row.fetchOne(db, sql: "SELECT target_kind, target_id FROM mcp_activity WHERE act = ?",
                                 arguments: [MCPSetupKeyRule.rebindAllowedAct])
            }.map { ($0["target_kind"] as String?) == nil && ($0["target_id"] as String?) == nil } == true,
                    "nothing was replaced")
        }
    }

    @Test func herDontAllowForgetsTheKeyAndTheNameKeepsItsOwn() throws {
        try withOperations { ops, db in
            let (_, own) = try approvedClaudeCode(ops)
            let any = try ops.mintMCPSetupKey()
            _ = try ops.admitMCPConnection(name: "claude-code", version: "0.1", presentedKey: any)
            let request = try #require(try db.read { try Queries.mcpRebindRequests($0) }.first)
            #expect(try ops.declineMCPRebind(request.id) == "claude-code")
            #expect(try db.read { try Queries.mcpRebindRequests($0) }.isEmpty)
            #expect(try boundHash(db, "claude-code") == MCPSetupKeyRule.hash(own))
            #expect(try db.read { try Queries.mcpSetupKeyStanding($0, hash: MCPSetupKeyRule.hash(any), name: "claude-code") }
                    == .unknown, "forgotten — never anyone's")
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: any).decision
                    == .refuse(.notThisNamesKey), "its next connection hears the one sentence")
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: own).decision == .admit)
            #expect(try log(db).contains("claude-code \(MCPSetupKeyRule.rebindDeclinedAct) refused"))
            #expect(throws: OperationError.mcpRebindRequestNotFound(id: request.id)) {
                try ops.declineMCPRebind(request.id)
            }
        }
    }

    @Test func aDenyOrAnAdoptionAnswersTheWaitToo() throws {
        try withOperations { ops, db in
            let (client, _) = try approvedClaudeCode(ops)
            _ = try ops.admitMCPConnection(name: "claude-code", version: "0.1", presentedKey: try ops.mintMCPSetupKey())
            let request = try #require(try db.read { try Queries.mcpRebindRequests($0) }.first)
            try ops.denyMCPClient(client.id)
            #expect(try db.read { try Queries.mcpRebindRequests($0) }.isEmpty, "Deny is a no")
            #expect(throws: OperationError.mcpRebindRequestNotFound(id: request.id)) { try ops.allowMCPRebind(request.id) }

            try ops.approveMCPClient(client.id, granting: nil)
            _ = try ops.admitMCPConnection(name: "claude-code", version: "0.2", presentedKey: try ops.mintMCPSetupKey())
            #expect(try db.read { try Queries.mcpRebindRequests($0) }.count == 1)
            #expect(try ops.landMCPAfterAdoption(holdStamp: "2026-10-14T09:00:00.000Z"))
            #expect(try db.read { try Queries.mcpRebindRequests($0) }.isEmpty, "an adoption releases the waits")
        }
    }

    /// A tab key under a name it was NOT copied for: first contact is a
    /// request (her approval decides; no reach to inherit), and an approved
    /// name waits for her OK (P-VX258-1).
    @Test func aTabKeyUnderAnotherNameIsNeverStrongerThanAnUntaggedOne() throws {
        try withOperations { ops, db in
            _ = try approvedClaudeCode(ops)
            let codexTab = try ops.mintMCPSetupKey(copiedFor: "codex-mcp-client")
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: codexTab).decision
                    == .awaitRebind)
            let another = try ops.mintMCPSetupKey(copiedFor: "codex-mcp-client")
            #expect(try ops.admitMCPConnection(name: "a-renamed-tool", version: nil, presentedKey: another).decision
                    == .request)
            #expect(try db.read { try Queries.mcpClient($0, name: "a-renamed-tool") }?.state == .pending)
        }
    }
}
