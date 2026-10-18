import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-298 (VX-336 U6a — the run record `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`,
// U6a D-298-1…8 and THE ORCHESTRATOR'S RULINGS ON U6a's FORKS): `show_in_app` OPENS COMPARE.
// Her answers (2026-10-13): any two notes her picker would offer, no link required (1); up to
// three peers (3); the board shows exactly what the AI named, replacing the open columns (4).
// The target `compare` names `note_id` (the first column) and `peer_ids` (one to three, in
// column order — P-VX298-3). Decided at READ on every note in order, never spending a once
// grant; the FIRST refusal answers with that note's refusal — the ONE not-shared shape for
// anything unreachable, logged on that side; only AFTER every note is decided, the same wing
// and her picker's rule (an archived PEER refuses; an archived ANCHOR may show — P-VX298-2).
// "Related blocks only" is the BOARD's to decide from its own projection (F-8 (a)), so the
// target carries no posture. And `link_versions`' receipt Open › opens the two in Compare (5).
//
// Headless (the SDK's own client over a real socket, the fake app applying the move rule), so
// every pin compiles — and runs RED by ABSENCE — on the tree before the fix: there the parse
// answered `target must be "note", "takes", "lens", "book" or "wing".` for every compare call,
// and link_versions' receipt opened note A. The target is read through `showCompareParts`
// (reflection) so the file names no symbol the old tree lacks.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

/// A `compare` target's two facts — the anchor and the peers in column order — read by
/// reflection (nil for any other target), so a pin names no case the old tree lacks.
func showCompareParts(_ target: MCPShowTarget?) -> [String]? {
    guard let target, let child = Mirror(reflecting: target).children.first, child.label == "compare" else {
        return nil
    }
    let parts = Mirror(reflecting: child.value).children.map(\.value)
    guard parts.count == 2, let note = parts[0] as? String, let peers = parts[1] as? [String] else { return nil }
    return [note] + peers
}

/// A fake app: stands where the test says, applies the RULE, records what it would have
/// delivered — the contract `MCPHostHooks.show` states (`MCPShowServerTests`' own).
private final class FakeApp: @unchecked Sendable {
    let standing = LockIsolated(MCPShowRule.Standing.frontmostMainWindow)
    let delivered = LockIsolated<[MCPShowTarget]>([])

    var hook: @Sendable (MCPShowTarget) async -> MCPShowRule.Verdict {
        { [self] target in
            let verdict = MCPShowRule.verdict(standing.value)
            if verdict == .navigate { delivered.withValue { $0.append(target) } }
            return verdict
        }
    }
}

private func compare(_ note: String, _ peers: [String]) -> [String: Value] {
    ["target": .string("compare"), "note_id": .string(note), "peer_ids": .array(peers.map { .string($0) })]
}

@Suite("VX-298 — show_in_app opens Compare", .serialized)
struct MCPShowCompareServerTests {
    private func note(_ h: ServerHarness, _ title: String, wing: String = "") throws -> Container {
        let note = try h.operations.createPost(title: title, wingId: wing)
        _ = try h.operations.newBlock(in: note.id, text: "\(title).", registeringUndo: false)
        return note
    }

    /// The pair, then three peers, delivered in column order — and a show never spends a once
    /// grant. **RED on old:** the parse refused the target; nothing was delivered.
    @Test func aPairAndUpToThreePeersAreDeliveredInColumnOrderNeverSpendingAOnceGrant() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            let a = try note(h, "a"), b = try note(h, "b"), c = try note(h, "c"), d = try note(h, "d")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, a.id, .once))
            for other in [b, c, d] {
                _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .note, other.id, .once))
            }

            let pair = try await call(connection, "show_in_app", compare(a.id, [b.id]))
            #expect(pair.isError != true, "\(text(pair))")
            #expect(try json(pair)["shown"] as? Bool == true)
            #expect(showCompareParts(app.delivered.value.last) == [a.id, b.id], "A first, B beside it")
            let four = try await call(connection, "show_in_app", compare(a.id, [d.id, b.id, c.id]))
            #expect(four.isError != true, "\(text(four))")
            #expect(showCompareParts(app.delivered.value.last) == [a.id, d.id, b.id, c.id], "the columns as named")
            for id in [a.id, b.id, c.id, d.id] {
                #expect(try await call(connection, "read_note", ["note_id": .string(id)]).isError != true,
                        "showing never spent \(id)'s ONCE grant")
            }
            await h.hangUp(connection)
        }
    }

    /// Every malformed compare call is refused at the parse, before any read, naming what is
    /// wrong. **RED on old:** every form heard the old target sentence.
    @Test func theParseRefusesEveryMalformedCompareNamingWhatIsWrong() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            let a = try note(h, "a"), b = try note(h, "b")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .wing, ""))
            let needs = "target compare needs note_id and peer_ids (one to three other notes)."
            let oneToThree = "peer_ids must name one to three other notes \u{2014} Compare shows a note and up to three beside it."
            let forms: [([String: Value], String)] = [
                (["target": .string("compare"), "note_id": .string(a.id)], needs),
                (["target": .string("compare"), "peer_ids": .array([.string(b.id)])], needs),
                (["target": .string("compare"), "note_id": .string(a.id), "peer_ids": .string(b.id)],
                 "peer_ids must be an array of note ids."),
                (compare(a.id, []), oneToThree),
                (compare(a.id, ["x1", "x2", "x3", "x4"]), oneToThree),
                (["target": .string("compare"), "note_id": .string(a.id), "peer_ids": .array([.int(7)])],
                 "peer_ids must hold note ids (strings)."),
                (compare(a.id, [b.id, b.id]), "peer_ids names a note twice."),
                (compare(a.id, [b.id, a.id]), "peer_ids can't include note_id \u{2014} it is the first column already."),
            ]
            for (arguments, words) in forms {
                let refused = try await call(connection, "show_in_app", arguments)
                #expect(refused.isError == true && text(refused) == words, "\(arguments) said: \(text(refused))")
            }
            #expect(app.delivered.value.isEmpty, "nothing moved")
            await h.hangUp(connection)
        }
    }

    /// An unreachable ANCHOR or PEER answers the ONE not-shared shape, byte-identical to an id
    /// naming nothing (a version's id included), logged on THAT side; nothing is delivered.
    /// **RED on old:** the parse refused first.
    @Test func anUnreachableAnchorOrPeerAnswersTheOneNotSharedShapeLoggedOnThatSide() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            let a = try note(h, "a"), b = try note(h, "b"), hidden = try note(h, "hidden")
            let version = try h.operations.saveNoteVersion(b.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, a.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .note, b.id))
            let notShared = MCPRefusalCopy.words(.notShared, .note)

            for (arguments, side) in [
                (compare(hidden.id, [a.id]), hidden.id), (compare(a.id, [hidden.id]), hidden.id),
                (compare(a.id, [b.id, "no-such-note"]), "no-such-note"), (compare(a.id, [version.post.id]), version.post.id),
            ] {
                let refused = try await call(connection, "show_in_app", arguments)
                #expect(refused.isError == true && text(refused) == notShared, "\(text(refused))")
                let logged = try await h.database.read { try Queries.mcpActivity($0, limit: 1).first }
                #expect(logged?.targetID == side && logged?.allowed == false, "logged on the refusing side")
            }
            #expect(app.delivered.value.isEmpty, "nothing moved")
            await h.hangUp(connection)
        }
    }

    /// Only AFTER every note is decided: another wing's peer refuses in one sentence, an
    /// ARCHIVED peer refuses by her picker's rule — and an archived ANCHOR shows (P-VX298-2).
    /// An unreadable peer beside another wing's still answers the one not-shared shape (the
    /// decisions come first). **RED on old:** the parse refused first.
    @Test func anotherWingsPeerAndAnArchivedPeerRefuseAfterTheDecisionsAndAnArchivedAnchorShows() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            let elsewhere = try h.operations.createWing(name: "elsewhere")
            let a = try note(h, "a"), shelved = try note(h, "shelved"), hidden = try note(h, "hidden")
            let far = try note(h, "far", wing: elsewhere.id)
            try h.operations.archiveContainer(shelved.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, a.id))
            for other in [shelved, far] {
                _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .note, other.id))
            }

            let wings = try await call(connection, "show_in_app", compare(a.id, [far.id]))
            #expect(wings.isError == true && text(wings)
                    == "Those notes are in different wings \u{2014} each wing is a separate library, so Compare can't "
                    + "show them side by side.", "\(text(wings))")
            let archived = try await call(connection, "show_in_app", compare(a.id, [shelved.id]))
            #expect(archived.isError == true && text(archived)
                    == "\u{201C}shelved\u{201D} is archived \u{2014} Compare offers only notes in the library "
                    + "(unarchive_note first).", "\(text(archived))")
            let first = try await call(connection, "show_in_app", compare(a.id, [far.id, hidden.id]))
            #expect(text(first) == MCPRefusalCopy.words(.notShared, .note), "the decisions come before the wing")
            #expect(app.delivered.value.isEmpty)

            let anchor = try await call(connection, "show_in_app", compare(shelved.id, [a.id]))
            #expect(anchor.isError != true, "\(text(anchor))")
            #expect(showCompareParts(app.delivered.value.last) == [shelved.id, a.id], "her ⌘5 opens on an archived note")
            await h.hangUp(connection)
        }
    }

    /// Her etiquette: not frontmost, nothing moves — the same words as every target.
    /// **RED on old:** the parse refused first.
    @Test func aCompareShowMovesNothingWhileSheIsAway() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        let app = FakeApp()
        h.host.hooks.show = app.hook
        try await h.within {
            let a = try note(h, "a"), b = try note(h, "b")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .wing, ""))
            app.standing.setValue(.notFrontmost)
            let away = try await call(connection, "show_in_app", compare(a.id, [b.id]))
            #expect(away.isError == true && text(away) == MCPShowRule.notFrontmostWords)
            #expect(app.delivered.value.isEmpty)
            await h.hangUp(connection)
        }
    }
}
