import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

// VX-168 — THE PER-SETUP KEY (the VX-156 brief §12's K2; her kickoff ruling
// R-VX168-1 — the run record `notes/plans/fixes/vx-168-mcp-client-secret.md`).
// The pure rule's every arm, then the operations' exact state transitions:
// the mint at copy (hash only, capped), the per-connection admission (bind /
// request / admit / refuse, effects in one transaction, an impostor never
// touching the row it claims), Deny releasing the binding, and an adoption
// releasing every binding.

@Suite("VX-168 — the setup-key rule (who a connection is)")
struct MCPSetupKeyRuleTests {
    private typealias Rule = MCPSetupKeyRule
    private let mine = Rule.hash("vmk1_mine")
    private let other = Rule.hash("vmk1_other")
    private let bound = Rule.Client(id: "cl1", boundHash: Rule.hash("vmk1_mine"))
    private let unbound = Rule.Client(id: "cl1", boundHash: nil)

    // MARK: - No key, no name

    @Test func aBareConnectionIsRefusedUnderAnyNameBoundOrNot() {
        for client in [nil, unbound, bound] {
            for standing in [Rule.KeyStanding.unclaimed, .unknown, .boundTo(clientID: "cl1")] {
                #expect(Rule.decide(name: "claude-code", client: client, presentedHash: nil, standing: standing)
                        == .refuse(.bare), "no grandfathering (R-VX168-1): \(String(describing: client))")
            }
        }
    }

    @Test func aNamelessConnectionIsRefusedFirst() {
        #expect(Rule.decide(name: "", client: nil, presentedHash: mine, standing: .unclaimed) == .refuse(.unnamed))
        #expect(Rule.decide(name: "", client: nil, presentedHash: nil, standing: .unknown) == .refuse(.unnamed))
    }

    // MARK: - A name bound to a key

    @Test func aBoundNameAdmitsItsOwnKey() {
        #expect(Rule.decide(name: "claude-code", client: bound, presentedHash: mine,
                            standing: .boundTo(clientID: "cl1")) == .admit)
    }

    /// Two tools under one name, told apart: a key bound to ANOTHER name, or
    /// one never minted here, refuses. VX-198 (A JUSTIFIED EDIT, the ritual —
    /// R-VX184-5, "the newest copied setup wins"): this arm's premise was
    /// "a fresh key from a newer copy is another setup's, so it refuses" —
    /// exactly what her ruling reverses. The fresh (`.unclaimed`) arm now
    /// RE-BINDS (`aBoundNameRebindsAFreshCopy`); the two arms left keep their
    /// refusal, unchanged.
    @Test func aBoundNameRefusesEveryOtherKey() {
        for standing in [Rule.KeyStanding.unknown, .boundTo(clientID: "cl2")] {
            #expect(Rule.decide(name: "claude-code", client: bound, presentedHash: other, standing: standing)
                    == .refuse(.notThisNamesKey), "\(standing)")
        }
    }

    /// VX-198 (R-VX184-5): a FRESH key — minted by a copy, never presented —
    /// under a bound name RE-BINDS it: the newest copied setup wins.
    /// VX-258 (A JUSTIFIED EDIT, the ritual — her ruling): only a copy made
    /// FOR that name re-binds with zero clicks; an untagged ("Any MCP client")
    /// copy, or another name's, WAITS for her OK while the name carries her
    /// approval; a name without approval keeps the old arm.
    @Test func aBoundNameRebindsAFreshCopy() {
        #expect(Rule.decide(name: "claude-code", client: bound, presentedHash: other, copiedFor: "claude-code",
                            standing: .unclaimed) == .rebind)
        #expect(Rule.Decision.rebind.admits)
        #expect(Rule.decide(name: "claude-code", client: bound, presentedHash: other, standing: .unclaimed)
                == .awaitRebind, "an untagged copy waits for her OK")
        #expect(Rule.decide(name: "claude-code", client: bound, presentedHash: other, copiedFor: "codex-mcp-client",
                            standing: .unclaimed) == .awaitRebind, "another client's copy waits too")
        let pending = Rule.Client(id: "cl1", boundHash: mine, approved: false)
        #expect(Rule.decide(name: "claude-code", client: pending, presentedHash: other, standing: .unclaimed)
                == .rebind, "no approval to inherit: the old arm")
    }

    /// VX-198: the key a newer setup replaced refuses with its OWN reason —
    /// bound name or not (a Deny after the rebind leaves the name unbound;
    /// the old key is still the replaced one).
    @Test func aReplacedKeyRefusesWithItsOwnReason() {
        for client in [bound, unbound] {
            #expect(Rule.decide(name: "claude-code", client: client, presentedHash: other, standing: .replaced)
                    == .refuse(.replaced), "\(client)")
        }
        #expect(Rule.decide(name: "claude-code", client: nil, presentedHash: other, standing: .replaced)
                == .refuse(.replaced))
        #expect(Rule.decide(name: "claude-code", client: bound, presentedHash: nil, standing: .replaced)
                == .refuse(.bare), "no key is bare first, whatever else")
    }

    // MARK: - A name with no key bound

    /// R-VX168-1: an approved name with no key binds the FIRST fresh setup
    /// presented under it — no revoke, no re-approval.
    /// VX-258 (A JUSTIFIED EDIT, the ritual — PROVISIONAL P-VX258-2): a setup
    /// copied FOR that name; an untagged one waits for her OK while the name
    /// carries her approval (the bind arm's half of the hole); a name without
    /// approval binds as before.
    @Test func aKnownUnboundNameBindsAnUnclaimedKey() {
        #expect(Rule.decide(name: "claude-code", client: unbound, presentedHash: mine, copiedFor: "claude-code",
                            standing: .unclaimed) == .bind)
        #expect(Rule.decide(name: "claude-code", client: unbound, presentedHash: mine, standing: .unclaimed)
                == .awaitRebind)
        let denied = Rule.Client(id: "cl1", boundHash: nil, approved: false)
        #expect(Rule.decide(name: "claude-code", client: denied, presentedHash: mine, standing: .unclaimed) == .bind)
    }

    /// K2: an unknown name presenting a fresh key becomes a connection
    /// request bound to it.
    @Test func anUnknownNameWithAnUnclaimedKeyIsARequest() {
        #expect(Rule.decide(name: "codex", client: nil, presentedHash: mine, standing: .unclaimed) == .request)
    }

    @Test func aKeyBoundElsewhereOrNeverIssuedRefusesAnUnboundName() {
        for client in [nil, unbound] {
            #expect(Rule.decide(name: "codex", client: client, presentedHash: mine, standing: .boundTo(clientID: "cl9"))
                    == .refuse(.anotherNamesKey))
            #expect(Rule.decide(name: "codex", client: client, presentedHash: mine, standing: .unknown)
                    == .refuse(.notIssued))
        }
    }

    // MARK: - The key's form

    @Test func theKeyIs256RandomBitsInAShellAndJSONSafeForm() {
        let bytes = Data((0..<32).map { UInt8(truncatingIfNeeded: $0 &* 37 &+ 250) })
        let key = Rule.key(fromRandomBytes: bytes)
        #expect(key.hasPrefix(Rule.prefix))
        #expect(key.count == Rule.prefix.count + 43, "32 bytes, unpadded base64url")
        #expect(key.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "_" || $0 == "-") })
        #expect(Rule.key(fromRandomBytes: bytes) == key, "a pure function of its bytes")
    }

    @Test func theHashIsDomainSeparatedHexAndNeverTheKey() {
        let hash = Rule.hash("vmk1_abc")
        #expect(hash.count == 64 && hash.allSatisfy(\.isHexDigit))
        #expect(hash == Rule.hash("vmk1_abc"))
        #expect(hash != Rule.hash("vmk1_abd"))
        #expect(!hash.contains("abc"))
    }

    @Test func everyRefusalLogsItsOwnAct() {
        let acts = Set(Rule.Refusal.allCases.map(Rule.activityAct))
        #expect(acts.count == Rule.Refusal.allCases.count)
        #expect(!acts.contains(Rule.boundAct))
        // VX-198: the rebind's own act, distinct from every refusal's.
        #expect(!acts.contains(Rule.reboundAct) && Rule.reboundAct != Rule.boundAct)
        #expect(acts.allSatisfy { $0.hasPrefix("connect_") })
    }
}

@Suite("VX-168 — the setup keys' operations (mint, admit, release)")
struct MCPSetupKeyOperationsTests {
    private func count(_ db: AppDatabase, _ sql: String) throws -> Int {
        try db.read { try Int.fetchOne($0, sql: sql) ?? -1 }
    }

    private func boundHash(_ db: AppDatabase, _ name: String) throws -> String? {
        try db.read { db in
            try String.fetchOne(db, sql: "SELECT setup_key_hash FROM mcp_client WHERE name = ?", arguments: [name])
        }
    }

    // MARK: - The mint

    @Test func aCopyMintsAFreshKeyAndKeepsOnlyItsHash() throws {
        try withOperations { ops, db in
            let first = try ops.mintMCPSetupKey()
            let second = try ops.mintMCPSetupKey()
            #expect(first != second, "every copy carries a fresh key")
            #expect(first.hasPrefix(MCPSetupKeyRule.prefix))
            let stored = try db.read { try String.fetchAll($0, sql: "SELECT key_hash FROM mcp_setup_key") }
            #expect(Set(stored) == [MCPSetupKeyRule.hash(first), MCPSetupKeyRule.hash(second)])
            let everything = try db.read { db in
                try String.fetchAll(db, sql: "SELECT key_hash || minted_at FROM mcp_setup_key")
            }.joined()
            #expect(!everything.contains(first) && !everything.contains(String(first.dropFirst(5))),
                    "the key itself is never in the library")
        }
    }

    @Test func unpresentedKeysAreCappedOldestFirst() throws {
        try withOperations { ops, db in
            var keys: [String] = []
            for _ in 0...Operations.mcpSetupKeyCap { keys.append(try ops.mintMCPSetupKey()) }
            #expect(try db.read { try Queries.mcpUnclaimedSetupKeyCount($0) } == Operations.mcpSetupKeyCap)
            #expect(try db.read { try Queries.mcpSetupKeyStanding($0, hash: MCPSetupKeyRule.hash(keys[0])) } == .unknown,
                    "the oldest copy is the one forgotten")
            #expect(try db.read { try Queries.mcpSetupKeyStanding($0, hash: MCPSetupKeyRule.hash(keys.last!)) }
                    == .unclaimed)
        }
    }

    // MARK: - Admission (every arm, its effects)

    /// K2, end to end at the store: a fresh copy, presented by a NEW name,
    /// becomes a pending request bound to the key; approval needs no second
    /// step; the same key keeps admitting; the unclaimed set no longer holds it.
    @Test func aNewNameWithAFreshKeyBecomesARequestBoundToIt() throws {
        try withOperations { ops, db in
            let key = try ops.mintMCPSetupKey()
            let admission = try ops.admitMCPConnection(name: " codex ", version: "0.4", presentedKey: key)
            #expect(admission.decision == .request)
            let client = try #require(admission.client)
            #expect(client.name == "codex" && client.state == .pending && client.version == "0.4")
            #expect(client.isSetupBound)
            #expect(try boundHash(db, "codex") == MCPSetupKeyRule.hash(key))
            #expect(try db.read { try Queries.mcpUnclaimedSetupKeyCount($0) } == 0, "claimed, it leaves the set")

            try ops.approveMCPClient(client.id, granting: nil)
            let again = try ops.admitMCPConnection(name: "codex", version: "0.5", presentedKey: key)
            #expect(again.decision == .admit)
            #expect(again.client?.state == .approved && again.client?.version == "0.5")
        }
    }

    /// R-VX168-1: an APPROVED name with no key (her clients from before
    /// VX-168) binds the first fresh setup presented under it — her approval
    /// and grants kept — and from then a bare or other key refuses.
    @Test func anApprovedUnboundNameBindsTheFirstFreshSetupThenRefusesTheRest() throws {
        try withOperations { ops, db in
            let client = try ops.recordMCPContact(name: "claude-code", version: "2.1")
            let book = try ops.createReading(name: "drafts", kind: .book)
            try ops.approveMCPClient(
                client.id, granting: .init(rung: .read, scopeKind: .book, scopeID: book.id, duration: .always))
            #expect(try db.read { try Queries.mcpClient($0, id: client.id) }?.isSetupBound == false)

            #expect(try ops.admitMCPConnection(name: "claude-code", version: "2.1", presentedKey: nil).decision
                    == .refuse(.bare), "a bare arrival refuses even unbound — no grandfathering")
            // VX-258 (A JUSTIFIED EDIT, the ritual — her ruling: a key re-binds with zero clicks only the name its setup was copied FOR): her
            // re-run is Claude Code's own setup, both times.
            let key = try ops.mintMCPSetupKey(copiedFor: "claude-code")
            let bound = try ops.admitMCPConnection(name: "claude-code", version: "2.2", presentedKey: key)
            #expect(bound.decision == .bind)
            #expect(bound.client?.state == .approved && bound.client?.isSetupBound == true)
            #expect(try db.read { try Queries.mcpGrants($0, clientID: client.id) }.count == 1, "her grants kept")

            // VX-198 (A JUSTIFIED EDIT, the ritual — R-VX184-5): this leg's
            // premise was "a second tool with a newer copy is told apart" —
            // the arm her ruling reverses: the newer copy RE-BINDS, and the
            // key it replaced is the one turned away now. A key never issued
            // keeps the impostor's refusal, and a refused presentation still
            // claims nothing.
            let impostor = "vmk1_neverminted"
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: impostor).decision
                    == .refuse(.notThisNamesKey), "a key never minted here is told apart")
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: nil).decision
                    == .refuse(.bare))
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: key).decision == .admit)
            let newer = try ops.mintMCPSetupKey(copiedFor: "claude-code")
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: newer).decision
                    == .rebind, "her re-run setup takes the name")
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: key).decision
                    == .refuse(.replaced), "the key it replaced is turned away, with its own reason")
            #expect(try db.read { try Queries.mcpSetupKeyStanding($0, hash: MCPSetupKeyRule.hash(impostor)) } == .unknown,
                    "a refused presentation claims nothing")
        }
    }

    /// The impostor never touches the row it claims: no last-seen, no
    /// version, no state — only her Activity list hears it, precisely.
    @Test func aRefusalChangesNothingAboutTheClientAndIsLoggedPrecisely() throws {
        try withOperations { ops, db in
            let key = try ops.mintMCPSetupKey()
            let real = try #require(try ops.admitMCPConnection(name: "claude-code", version: "2.1", presentedKey: key).client)
            // VX-198 (A JUSTIFIED EDIT, the ritual — R-VX184-5): the impostor
            // presented a fresh MINT, which now re-binds by her ruling; an
            // impostor is a key this library never handed the name's newest
            // setup — here one never minted at all. Everything checked below
            // is unchanged.
            let other = "vmk1_impostors_own_key"
            let refused = try ops.admitMCPConnection(name: "claude-code", version: "9.9", presentedKey: other)
            #expect(refused.decision == .refuse(.notThisNamesKey) && refused.client == nil)
            let after = try #require(try db.read { try Queries.mcpClient($0, id: real.id) })
            #expect(after == real, "the row the impostor claimed is untouched")

            _ = try ops.admitMCPConnection(name: "stray", version: nil, presentedKey: nil)
            _ = try ops.admitMCPConnection(name: "forger", version: nil, presentedKey: "vmk1_madeup")
            _ = try ops.admitMCPConnection(name: "codex", version: nil, presentedKey: key)
            _ = try ops.admitMCPConnection(name: "   ", version: nil, presentedKey: key)
            let log = try db.read { db in
                try Row.fetchAll(db, sql: "SELECT client_name, act, outcome FROM mcp_activity ORDER BY id")
                    .map { "\($0["client_name"] as String) \($0["act"] as String) \($0["outcome"] as String)" }
            }
            #expect(log == [
                "claude-code connect_not_this_names_key refused",
                "stray connect_bare refused",
                "forger connect_not_issued refused",
                "codex connect_another_names_key refused",
                "\(Operations.mcpUnnamedClient) connect_unnamed refused",
            ])
            #expect(try count(db, "SELECT COUNT(*) FROM mcp_client") == 1,
                    "no refused arrival enters the waiting room")
        }
    }

    @Test func aBindIsLoggedAndARequestIsNot() throws {
        try withOperations { ops, db in
            _ = try ops.admitMCPConnection(name: "codex", version: nil, presentedKey: try ops.mintMCPSetupKey())
            let client = try ops.recordMCPContact(name: "claude-code", version: nil)
            try ops.approveMCPClient(client.id, granting: nil)
            // VX-258 (A JUSTIFIED EDIT, the ritual — her ruling: a key re-binds with zero clicks only the name its setup was copied FOR): Claude
            // Code's own setup binds its approved name.
            _ = try ops.admitMCPConnection(
                name: "claude-code", version: nil, presentedKey: try ops.mintMCPSetupKey(copiedFor: "claude-code"))
            let log = try db.read { db in
                try Row.fetchAll(db, sql: "SELECT client_name, act, outcome FROM mcp_activity ORDER BY id")
                    .map { "\($0["client_name"] as String) \($0["act"] as String) \($0["outcome"] as String)" }
            }
            #expect(log == ["claude-code \(MCPSetupKeyRule.boundAct) allowed"],
                    "a request shows in Connection requests; a bind says so in Activity")
        }
    }

    // MARK: - Release

    /// P-VX168-U1-1: Deny releases the name's key (K1's recorded rotation,
    /// "revoke and re-approve", carried to K2) — the old tool refuses; once
    /// approved again, the next fresh setup binds.
    @Test func denyReleasesTheKeySoApproveAndAFreshSetupRotateIt() throws {
        try withOperations { ops, db in
            let old = try ops.mintMCPSetupKey()
            let client = try #require(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: old).client)
            try ops.approveMCPClient(client.id, granting: nil)

            try ops.denyMCPClient(client.id)
            #expect(try db.read { try Queries.mcpClient($0, id: client.id) }?.isSetupBound == false)
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: old).decision
                    == .refuse(.notIssued), "the released key is gone, not returned to the unclaimed set")

            try ops.approveMCPClient(client.id, granting: nil)
            // VX-258 (A JUSTIFIED EDIT, the ritual — her ruling: a key re-binds with zero clicks only the name its setup was copied FOR): the
            // fresh setup is Claude Code's own.
            let fresh = try ops.mintMCPSetupKey(copiedFor: "claude-code")
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: fresh).decision == .bind)
            #expect(try boundHash(db, "claude-code") == MCPSetupKeyRule.hash(fresh))
        }
    }

    /// P-VX168-U1-2: an adopted library's keys are released with the OFF
    /// landing (same transaction, same once-per-hold guard): each approved
    /// client binds the first setup run on this Mac, grants kept.
    @Test func anAdoptionReleasesEveryKeyOncePerHold() throws {
        try withOperations { ops, db in
            let key = try ops.mintMCPSetupKey()
            let client = try #require(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: key).client)
            try ops.approveMCPClient(
                client.id, granting: .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
            _ = try ops.mintMCPSetupKey()

            #expect(try ops.landMCPAfterAdoption(holdStamp: "2026-10-12T09:00:00.000Z"))
            #expect(try count(db, "SELECT COUNT(*) FROM mcp_client WHERE setup_key_hash IS NOT NULL") == 0)
            #expect(try db.read { try Queries.mcpUnclaimedSetupKeyCount($0) } == 0)
            #expect(try db.read { try Queries.mcpGrants($0, clientID: client.id) }.count == 1, "grants kept")
            #expect(try db.read { try Queries.mcpClient($0, id: client.id) }?.state == .approved)

            // VX-258 (A JUSTIFIED EDIT, the ritual — her ruling: a key re-binds with zero clicks only the name its setup was copied FOR): the
            // setup run on this Mac is Claude Code's own (an untagged one waits
            // for her OK — the adoption's case of P-VX258-2).
            let here = try ops.mintMCPSetupKey(copiedFor: "claude-code")
            #expect(try ops.admitMCPConnection(name: "claude-code", version: nil, presentedKey: here).decision == .bind)
            #expect(try ops.landMCPAfterAdoption(holdStamp: "2026-10-12T09:00:00.000Z") == false)
            #expect(try boundHash(db, "claude-code") == MCPSetupKeyRule.hash(here),
                    "the same hold read again releases nothing")
        }
    }

    /// The waiting room's cap forgets the oldest pending request — and the
    /// key it claimed goes with it (never returned to the unclaimed set).
    @Test func aForgottenRequestTakesItsKey() throws {
        try withOperations { ops, db in
            let first = try ops.mintMCPSetupKey()
            _ = try ops.admitMCPConnection(name: "spam-0", version: nil, presentedKey: first)
            for index in 1...Operations.mcpPendingCap {
                _ = try ops.admitMCPConnection(name: "spam-\(index)", version: nil, presentedKey: try ops.mintMCPSetupKey())
            }
            #expect(try db.read { try Queries.mcpClient($0, name: "spam-0") } == nil)
            #expect(try db.read { try Queries.mcpSetupKeyStanding($0, hash: MCPSetupKeyRule.hash(first)) } == .unknown)
        }
    }
}
