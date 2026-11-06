import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-817 (the VX-827 run, U1 — P-U1-a…g sustained, the archived call
// PROVISIONAL #264; the run record `notes/plans/fixes/vx-827-lineage.md`):
// `list_note_lineage` end to end over a real socket. Her VX-817 fence line: an
// edge appears ONLY when BOTH its ends are within the client's read reach — a
// hidden peer is simply absent, never counted, never hinted; `beyond_reach`
// always says the list is scoped. (The two-store catalog's `list_note_lineage`
// arms pin the same answers byte for byte across a store with hidden relatives
// and one without.)

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

private let lineageWords = "Notes beyond your reach, if any, are not listed."
private let twoSentences = "Paragraph seam has words. And a second sentence follows here."

private func notes(_ answer: [String: Any], _ bucket: String) -> [[String: Any]] {
    answer[bucket] as? [[String: Any]] ?? []
}

@Suite("VX-817 — list_note_lineage: one hop, both ends readable", .serialized)
struct MCPListNoteLineageServerTests {

    /// Every bucket, every kind of peer the client CAN read — a note
    /// elsewhere in Home, a copy in another wing, an archived duplicate — and
    /// every kind it cannot: a Private copy and a daily-Journal entry that its
    /// HOME WING grant would otherwise reach (the fence keys win: only a
    /// per-ask note grant reads them), a copy in an ungranted wing, and a pool
    /// copy (no note at all). The hidden ones are absent from the answer — no
    /// id, no count — and `beyond_reach` says the list is scoped.
    @Test func readablePeersAreListedByBucketAndHiddenOnesAreAbsent() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let ops = h.operations
            let studio = try ops.createWing(name: "Studio")
            let attic = try ops.createWing(name: "Attic")
            let n = try ops.createPost(title: "N")
            let a = try ops.newBlock(in: n.id, text: twoSentences, registeringUndo: false)
            _ = try ops.newBlock(in: n.id, text: "A second block.", registeringUndo: false)
            // A copy elsewhere in Home: a divided half moved to P.
            let p = try ops.createPost(title: "P")
            let half = try ops.divide(a.block.id, cut: 24)
            try ops.moveBlock(half.block.id, to: p.id)
            // A copy in another wing, an archived duplicate.
            let away = try ops.copyNoteToWing(n.id, to: studio.id)
            let archived = try ops.duplicateAsVersion(n.id, tags: .none).post
            try ops.archiveContainer(archived.id)
            // Hidden: a Private copy, a Journal entry, a copy in an ungranted
            // wing, a pool copy.
            let privateCopy = try ops.duplicateAsVersion(n.id, tags: .none).post
            _ = try ops.setNotePrivate(privateCopy.id, true)
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-06-30").container
            _ = try ops.newBlock(in: entry.id, text: "Dear diary.", registeringUndo: false)
            _ = ops.shelveInDailyJournalBook(entry.id)
            _ = try ops.markPostsAsVersions(n.id, entry.id)
            let ungranted = try ops.copyNoteToWing(n.id, to: attic.id)
            let pool = try ops.createPool(title: "scraps")
            let scrap = try ops.newBlock(in: pool.id, text: "A scrap.", registeringUndo: false)
            _ = try ops.poolDragCopy(scrap.block.id, to: n.id)

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .wing, ""))
            _ = try ops.grantMCPAccess(try h.client("claude-code").id, spec(.read, .wing, studio.id))

            let result = try await call(connection, "list_note_lineage", ["note_id": .string(n.id)])
            #expect(result.isError != true, "\(text(result))")
            let said = text(result)
            let answer = try json(result)
            #expect(answer["note_id"] as? String == n.id && answer["title"] as? String == "N")
            #expect(answer["beyond_reach"] as? String == lineageWords)
            let firstBlock = a.block.id
            let copies = notes(answer, "copies")
            #expect(copies.map { $0["note_id"] as? String } == [p.id, away.id, archived.id].sorted(),
                    "peers in note-id order: \(said)")
            let toP = try #require(copies.first { $0["note_id"] as? String == p.id })
            #expect(toP["title"] as? String == "P" && toP["wing_id"] as? String == "" && toP["archived"] as? Bool == false)
            let pLinks = try #require(toP["links"] as? [[String: Any]])
            #expect(pLinks.count == 1 && pLinks[0]["block_id"] as? String == firstBlock
                    && pLinks[0]["peer_block_id"] as? String == half.block.id
                    && pLinks[0]["origin_op"] as? String == "divide" && pLinks[0]["at"] is String)
            let toAway = try #require(copies.first { $0["note_id"] as? String == away.id })
            #expect(toAway["wing_id"] as? String == studio.id, "another wing, named")
            #expect((toAway["links"] as? [[String: Any]])?.count == 2, "one copy per block: \(toAway)")
            let toArchived = try #require(copies.first { $0["note_id"] as? String == archived.id })
            #expect(toArchived["archived"] as? Bool == true, "an archived peer is listed, marked")
            #expect(notes(answer, "originals").isEmpty, "the pool scrap is no note; nothing else is N's original")
            let versions = notes(answer, "versions")
            #expect(Set(versions.compactMap { $0["note_id"] as? String }) == [away.id, archived.id],
                    "the duplicates' one anchor each — never the Journal entry's link")
            #expect(versions.allSatisfy { ($0["links"] as? [[String: Any]])?.count == 1 })
            for hidden in [privateCopy.id, entry.id, ungranted.id, pool.id, scrap.block.id] {
                #expect(!said.contains(hidden), "\(hidden) appears nowhere")
            }
            #expect(!said.contains("edge"), "no edge id, no edge word")

            // From the copy's side: its original, readable.
            let back = try json(try await call(connection, "list_note_lineage", ["note_id": .string(p.id)]))
            #expect(notes(back, "originals").map { $0["note_id"] as? String } == [n.id])
            #expect(notes(back, "copies").isEmpty && notes(back, "versions").isEmpty)
            await h.hangUp(connection)
        }
    }

    /// The SUBJECT's once grant is spent by the read (one read means one
    /// read); a PEER's once grant is never spent — reading a peer's address is
    /// not reading the peer.
    @Test func theSubjectsOnceGrantIsSpentAPeersNever() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let n = try h.operations.createPost(title: "N")
            _ = try h.operations.newBlock(in: n.id, text: "One.", registeringUndo: false)
            let copy = try h.operations.duplicateAsVersion(n.id, tags: .none).post
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", nil)
            let client = try h.client("claude-code").id
            let subjectGrant = try h.operations.grantMCPAccess(client, spec(.read, .note, n.id, .once))
            let peerGrant = try h.operations.grantMCPAccess(client, spec(.read, .note, copy.id, .once))
            func spent(_ id: String) throws -> Bool {
                try h.database.read { db in
                    try String.fetchOne(db, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [id]) != nil
                }
            }
            let first = try await call(connection, "list_note_lineage", ["note_id": .string(n.id)])
            #expect(first.isError != true, "\(text(first))")
            #expect(notes(try json(first), "copies").map { $0["note_id"] as? String } == [copy.id],
                    "a peer reachable only by a once grant is listed")
            #expect(try spent(subjectGrant) && !(try spent(peerGrant)))
            let second = try await call(connection, "list_note_lineage", ["note_id": .string(n.id)])
            #expect(second.isError == true, "the once grant covered one read")
            await h.hangUp(connection)
        }
    }

    /// The list form: each item IS the single call (its answer byte for byte,
    /// or the single call's refusal — hidden and missing alike), with the
    /// counts; every item refused is an error answer; the call door's argument
    /// rules; one Activity line per item.
    @Test func theListFormAnswersEachItemAsTheSingleCallDoes() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let n = try h.operations.createPost(title: "N")
            _ = try h.operations.newBlock(in: n.id, text: "One.", registeringUndo: false)
            let other = try h.operations.createPost(title: "other")
            _ = try h.operations.newBlock(in: other.id, text: "Two.", registeringUndo: false)
            let hidden = try h.operations.createPost(title: "hidden")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, n.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .note, other.id))

            let single = text(try await call(connection, "list_note_lineage", ["note_id": .string(n.id)]))
            let listed = try await call(connection, "list_note_lineage", [
                "note_ids": .array([.string(n.id), .string(hidden.id), .string("no-such-note"), .string(other.id)]),
            ])
            #expect(listed.isError != true)
            let answer = try json(listed)
            let results = try #require(answer["results"] as? [[String: Any]])
            #expect(results.count == 4 && answer["landed_count"] as? Int == 2 && answer["refused_count"] as? Int == 2)
            let first = String(decoding: try JSONSerialization.data(
                withJSONObject: results[0], options: [.sortedKeys, .withoutEscapingSlashes]), as: UTF8.self)
            #expect(first == single, "an item is the single call's answer, byte for byte")
            #expect(results[1]["note_id"] as? String == hidden.id && results[2]["note_id"] as? String == "no-such-note")
            let refusedHidden = try #require(results[1]["refused"] as? String)
            #expect(refusedHidden == results[2]["refused"] as? String, "hidden = missing")
            #expect(results[3]["note_id"] as? String == other.id && results[3]["refused"] == nil)

            let allRefused = try await call(connection, "list_note_lineage", [
                "note_ids": .array([.string(hidden.id), .string("no-such-note")]),
            ])
            #expect(allRefused.isError == true, "a list where every item refused is an error answer")
            #expect(try json(allRefused)["landed_count"] as? Int == 0)

            for (arguments, words) in [
                (["note_id": Value.string(n.id), "note_ids": .array([.string(n.id)])], "Pass note_id or note_ids, not both."),
                (["note_ids": Value.array([])], "note_ids lists no note."),
                (["note_ids": Value.array([.string(n.id), .string(n.id)])], "note_ids lists a note twice."),
                (["note_ids": Value.array((0...200).map { .string("id-\($0)") })],
                 MCPWriteTools.listCapWords(201)),
                ([:], "note_id is required."),
            ] {
                let refused = try await call(connection, "list_note_lineage", arguments)
                #expect(refused.isError == true && text(refused) == words, "\(arguments): \(text(refused))")
            }

            let activity = try await h.database.read { try Queries.mcpActivity($0) }
                .filter { $0.act == "list_note_lineage" }
            #expect(activity.count == 1 + 4 + 2, "one line per item: \(activity.map { ($0.targetID, $0.allowed) })")
            await h.hangUp(connection)
        }
    }
}
