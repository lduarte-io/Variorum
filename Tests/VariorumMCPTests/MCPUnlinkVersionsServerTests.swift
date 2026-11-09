import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-943 (the VX-915 run, batch 6 — the record `notes/plans/fixes/vx-915-recents-sweep.md`
// BATCH 6): `unlink_versions`, link_versions' opposite (her relay: "an unlink_versions that
// takes the ID link_versions already returns, at the same permission level"). ONE link taken
// back by the `edge_id` link_versions answered; WRITE NEW on BOTH notes the link joins, their
// once grants spent together; BOTH notes READABLE before any other answer, so a link to a note
// the client cannot read answers the one not-shared shape byte-identical to an id naming
// nothing (VX-825); a saved version's link and a gone link refuse in words; ONE client-named
// undo honouring VX-276. An Improvement: these pins assert the NEW contract (red on old by
// absence — the tool did not exist).

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

private func pair(_ a: String, _ b: String) -> Value {
    .object(["block_a": .string(a), "block_b": .string(b)])
}

private func unlink(_ connection: HarnessConnection, _ edgeID: String) async throws
    -> (content: [Tool.Content], isError: Bool?)
{
    try await call(connection, "unlink_versions", ["edge_id": .string(edgeID)])
}

/// An entry with the named keys taken out (`at` differs call to call).
private func without(_ entry: [String: Any], _ keys: Set<String>) -> NSDictionary {
    NSDictionary(dictionary: entry.filter { !keys.contains($0.key) })
}

@Suite("VX-943 — unlink_versions: one link taken back by its edge id", .serialized)
struct MCPUnlinkVersionsServerTests {
    private struct World {
        let book: Reading
        let a: Container
        let b: Container
        let aBlocks: [String]
        let bBlocks: [String]
    }

    private func world(_ h: ServerHarness) throws -> World {
        let book = try h.operations.createReading(name: "drafts", kind: .book)
        let a = try h.operations.createPost(title: "draft one")
        let b = try h.operations.createPost(title: "draft two")
        var aBlocks: [String] = []
        var bBlocks: [String] = []
        for (note, texts) in [(a, ["A first.", "A second."]), (b, ["B first.", "B second."])] {
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            for text in texts {
                let block = try h.operations.newBlock(in: note.id, text: text, registeringUndo: false).block.id
                if note.id == a.id { aBlocks.append(block) } else { bBlocks.append(block) }
            }
        }
        return World(book: book, a: a, b: b, aBlocks: aBlocks, bBlocks: bBlocks)
    }

    /// link_versions on the wire: each pair's `edge_id`, in pair order.
    private func link(_ connection: HarnessConnection, _ w: World, _ pairs: [(String, String)]) async throws -> [String] {
        let linked = try await call(connection, "link_versions", [
            "note_a": .string(w.a.id), "note_b": .string(w.b.id), "pairs": .array(pairs.map { pair($0.0, $0.1) }),
        ])
        #expect(linked.isError != true, "\(text(linked))")
        let links = try #require(try json(linked)["links"] as? [[String: Any]])
        return links.compactMap { $0["edge_id"] as? String }
    }

    private func edgeIsLive(_ h: ServerHarness, _ id: String) async throws -> Bool {
        try await h.database.read { db in
            try Bool.fetchOne(db, sql: "SELECT deleted_at IS NULL FROM edge WHERE id = ?", arguments: [id]) ?? false
        }
    }

    private func peers(_ h: ServerHarness, _ noteID: String) async throws -> [String] {
        try await h.database.read { try Queries.versionPeerPosts($0, of: noteID) }
    }

    /// The link's ends as the act reads them — the stored (canonical) order.
    private func ends(_ h: ServerHarness, _ edgeID: String) async throws -> Queries.MCPVersionLinkEnds {
        try #require(try await h.database.read { try Queries.mcpVersionLinkEnds($0, edgeID: edgeID) })
    }

    private func revokeAll(_ h: ServerHarness) throws {
        let client = try h.client("claude-code").id
        for grant in try h.database.read({ try Queries.mcpGrants($0, clientID: client) }) {
            try h.operations.revokeMCPGrant(grant.id)
        }
    }

    private static let notShared = MCPRefusalCopy.words(.notShared, .note)

    // MARK: - The round trip

    /// The id link_versions answered takes the link back — both notes untouched, Compare no
    /// longer pairing them — as ONE client-named undo; undo puts back the very edge, redo takes
    /// it again, and the next undo finds the redo's own stamp.
    @Test func theIDLinkVersionsAnsweredUnlinksAsOneUndoAndRoundTrips() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))
            let edge = try #require(try await link(connection, w, [(w.aBlocks[0], w.bBlocks[0])]).first)
            let stored = try await ends(h, edge)
            #expect(Set(stored.noteIDs) == [w.a.id, w.b.id] && Set(stored.blockIDs) == [w.aBlocks[0], w.bBlocks[0]])
            let textsBefore = try await h.database.read { db in
                try String.fetchAll(db, sql: "SELECT working_text FROM variant ORDER BY id")
            }

            let unlinked = try await unlink(connection, edge)
            #expect(unlinked.isError != true, "\(text(unlinked))")
            let answer = try json(unlinked)
            #expect(answer["edge_id"] as? String == edge)
            #expect(answer["note_ids"] as? [String] == stored.noteIDs, "the link's two notes, in its stored order")
            #expect(answer["block_ids"] as? [String] == stored.blockIDs, "and its two blocks, parallel")
            #expect(answer["unlinked"] as? Bool == true)
            #expect(answer["still_versions"] as? Bool == false, "that was the notes' only link")
            #expect(Set(answer.keys) == ["edge_id", "note_ids", "block_ids", "unlinked", "still_versions"])
            #expect(try await edgeIsLive(h, edge) == false)
            #expect(try await peers(h, w.a.id).isEmpty, "Compare no longer offers them as versions")
            let textsAfter = try await h.database.read { db in
                try String.fetchAll(db, sql: "SELECT working_text FROM variant ORDER BY id")
            }
            #expect(textsAfter == textsBefore, "both notes stay exactly as they are")

            #expect(h.undoStack.depth == 2 && h.undoStack.topLabel == "claude-code's version link removal")
            let receipt = try #require(h.receipts.value.last)
            #expect(receipt.act == .versionUnlink && receipt.targetID == stored.noteIDs[0])
            #expect(showCompareParts(receipt.show) == stored.noteIDs, "Open › opens the two in Compare")

            #expect(try h.undoStack.undoReporting(with: h.writeOperations)
                    == UndoStack.Outcome(label: "claude-code's version link removal", changed: true))
            #expect(try await edgeIsLive(h, edge), "the undo puts back the very edge")
            #expect(try await peers(h, w.a.id) == [w.b.id])
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's version link removal")
            #expect(try await edgeIsLive(h, edge) == false, "the redo takes it again")
            #expect(try h.undoStack.undoReporting(with: h.writeOperations)?.changed == true,
                    "the next undo finds the redo's own stamp")
            #expect(try await edgeIsLive(h, edge))
            await h.hangUp(connection)
        }
    }

    /// One call takes ONE link: a multi-pair link answered several ids, and the notes stay
    /// versions — `still_versions` says so — until the last goes.
    @Test func stillVersionsSaysWhetherAnotherLinkStillPairsTheNotes() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))
            let edges = try await link(connection, w, [(w.aBlocks[0], w.bBlocks[0]), (w.aBlocks[1], w.bBlocks[1])])
            #expect(edges.count == 2)
            let first = try json(try await unlink(connection, edges[0]))
            #expect(first["still_versions"] as? Bool == true, "the other pair still links them")
            #expect(try await peers(h, w.a.id) == [w.b.id])
            #expect(try await edgeIsLive(h, edges[1]), "only the named link went")
            let second = try json(try await unlink(connection, edges[1]))
            #expect(second["still_versions"] as? Bool == false)
            #expect(try await peers(h, w.a.id).isEmpty)
            #expect(h.undoStack.depth == 3, "each unlink its own entry")
            await h.hangUp(connection)
        }
    }

    /// **A link inside ONE note** (the VX-915 ladder's F-7): her `moveBlock` re-homing one end
    /// leaves both blocks in one note. The unlink lands, its Open › opens that note at the link's
    /// first block, and its receipt carries the note ONCE — the far side's `detail` nil, which is
    /// what her receipt line reads to say "inside “A”" instead of "between “A” and “A”". RED ON
    /// OLD: the receipt's `detail` was the far note's title — the same note's — so the line read
    /// "removed the version link between “draft one” and “draft one”".
    @Test func aLinkInsideOneNoteCarriesTheNoteOnceOnItsReceipt() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))
            let edge = try #require(try await link(connection, w, [(w.aBlocks[0], w.bBlocks[0])]).first)
            try h.operations.moveBlock(w.bBlocks[0], to: w.a.id)
            let stored = try await ends(h, edge)
            #expect(stored.noteIDs == [w.a.id, w.a.id], "the premise: both ends now sit in one note")

            let unlinked = try await unlink(connection, edge)
            #expect(unlinked.isError != true, "\(text(unlinked))")
            #expect(try json(unlinked)["note_ids"] as? [String] == [w.a.id, w.a.id], "the answer is unchanged")
            let receipt = try #require(h.receipts.value.last)
            #expect(receipt.act == .versionUnlink && receipt.targetID == w.a.id)
            #expect(receipt.targetTitle == "draft one")
            #expect(receipt.show == .note(noteID: w.a.id, blockID: stored.blockIDs[0], select: nil),
                    "Open › opens the one note at the link's first block")
            #expect(receipt.detail == nil, "the note once — no far side to name: \(receipt.detail ?? "nil")")
            await h.hangUp(connection)
        }
    }

    // MARK: - VX-276: the undo writes back only over the act's own result

    /// Her own re-link of the pair since (a live twin) leaves the unlink's undo QUIET: nothing
    /// written, the entry retired, no redo future; and a redo whose link she has since unmarked
    /// in Compare is quiet too, her unmark standing.
    @Test func theUndoAndTheRedoAreQuietWhenTheLinkMovedOn() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))
            let edge = try #require(try await link(connection, w, [(w.aBlocks[0], w.bBlocks[0])]).first)
            #expect(try await unlink(connection, edge).isError != true)
            let hers = try h.operations.markVersionOf(w.aBlocks[0], w.bBlocks[0])
            #expect(try h.undoStack.undoReporting(with: h.writeOperations)
                    == UndoStack.Outcome(label: "claude-code's version link removal", changed: false))
            let clientsLive = try await edgeIsLive(h, edge)
            let hersLive = try await edgeIsLive(h, hers.id)
            #expect(!clientsLive && hersLive, "her twin stands; the client's edge stays dead")
            #expect(h.undoStack.redoDepth == 0, "a quiet undo retires its entry")

            // The redo's mirror: undo (revived), she unmarks in Compare, redo is quiet.
            try h.operations.removeVersionOf(w.aBlocks[0], w.bBlocks[0])
            let again = try #require(try await link(connection, w, [(w.aBlocks[1], w.bBlocks[1])]).first)
            #expect(try await unlink(connection, again).isError != true)
            #expect(try h.undoStack.undoReporting(with: h.writeOperations)?.changed == true)
            try h.operations.unmarkPostsAsVersions(w.a.id, w.b.id)
            let herStamp = try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT deleted_at FROM edge WHERE id = ?", arguments: [again])
            }
            #expect(try h.undoStack.redoReporting(with: h.writeOperations)
                    == UndoStack.Outcome(label: "claude-code's version link removal", changed: false))
            let stampAfter = try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT deleted_at FROM edge WHERE id = ?", arguments: [again])
            }
            #expect(stampAfter == herStamp && herStamp != nil, "her unmark stands, its stamp untouched")
            await h.hangUp(connection)
        }
    }

    // MARK: - The grant matrix

    /// WRITE NEW on BOTH notes (link_versions' rung — the agent's ask she relayed, an OPEN choice
    /// for her, PROVISIONAL P-915-B6-1; the VX-915 ladder's F-3): a side the client may only
    /// read hears the rung's refusal, naming nothing else, with ITS ask; once grants on both
    /// sides are spent together by the one act.
    @Test func writeNewOnBothNotesTheShortSideSpeaksAndOnceGrantsSpendTogether() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))
            let edge = try #require(try await link(connection, w, [(w.aBlocks[0], w.bBlocks[0])]).first)
            let client = try h.client("claude-code").id
            try revokeAll(h)
            _ = try h.operations.grantMCPAccess(client, spec(.writeNew, .note, w.a.id))
            _ = try h.operations.grantMCPAccess(client, spec(.read, .note, w.b.id))

            let short = try await unlink(connection, edge)
            #expect(short.isError == true && text(short) == "This client may only read here. "
                    + MCPRefusalCopy.askedSentence, "\(text(short))")
            #expect(h.asks.value.last?.scopeID == w.b.id && h.asks.value.last?.rung == .writeNew)
            #expect(try await edgeIsLive(h, edge))

            // Read on both: the FIRST note in the link's stored order speaks.
            try revokeAll(h)
            _ = try h.operations.grantMCPAccess(client, spec(.read, .note, w.a.id))
            _ = try h.operations.grantMCPAccess(client, spec(.read, .note, w.b.id))
            let stored = try await ends(h, edge)
            let readOnly = try await unlink(connection, edge)
            #expect(readOnly.isError == true && text(readOnly).hasPrefix("This client may only read here."))
            #expect(h.asks.value.last?.scopeID == stored.noteIDs[0])

            try revokeAll(h)
            _ = try h.operations.grantMCPAccess(client, spec(.writeNew, .note, w.a.id, .once))
            _ = try h.operations.grantMCPAccess(client, spec(.writeNew, .note, w.b.id, .once))
            #expect(try await unlink(connection, edge).isError != true)
            let spent = try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM mcp_grant WHERE consumed_at IS NOT NULL")
            }
            #expect(spent == 2, "both sides' once grants paid for the one act")
            _ = try h.operations.markVersionOf(w.aBlocks[1], w.bBlocks[1])
            let hers = try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM edge WHERE deleted_at IS NULL AND type = 'version_of'")
            }
            let again = try await unlink(connection, try #require(hers))
            #expect(again.isError == true && text(again) == Self.notShared, "nothing is left to spend")
            await h.hangUp(connection)
        }
    }

    /// **VX-825 — removing a link leaks nothing about an unreadable far side.** A link to a note
    /// the client cannot READ answers the ONE not-shared shape, byte-identical to an id naming
    /// nothing — even where the client holds the READABLE side at read only (a rung refusal
    /// there would tell the far side exists: a store without it has no such link at all), and
    /// even where it holds write new on the readable side. A Private far side, an edge of
    /// another type and an end released to lineage answer the same. The unreadable side's ask
    /// is raised silently (link_versions' posture); nothing is written.
    @Test func anUnreadableSideAnswersExactlyAsAnIDNamingNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))
            let edge = try #require(try await link(connection, w, [(w.aBlocks[0], w.bBlocks[0])]).first)
            let missing = try await unlink(connection, "00000000-dead-beef-0000-000000000000")
            #expect(missing.isError == true && text(missing) == Self.notShared, "\(text(missing))")
            let client = try h.client("claude-code").id

            try revokeAll(h)
            _ = try h.operations.grantMCPAccess(client, spec(.writeNew, .note, w.a.id))
            let asksBefore = h.asks.value.count
            let hiddenB = try await unlink(connection, edge)
            #expect(hiddenB.isError == true && text(hiddenB) == text(missing), "write new on A, B hidden")
            #expect(h.asks.value.count == asksBefore + 1 && h.asks.value.last?.scopeID == w.b.id
                    && h.asks.value.last?.rung == .writeNew, "the hidden side's ask is put to HER, silently")

            try revokeAll(h)
            _ = try h.operations.grantMCPAccess(client, spec(.read, .note, w.a.id))
            let readA = try await unlink(connection, edge)
            #expect(readA.isError == true && text(readA) == text(missing),
                    "read on A, B hidden — the one shape, never A's rung refusal")

            try revokeAll(h)
            _ = try h.operations.grantMCPAccess(client, spec(.writeNew, .book, w.book.id))
            _ = try h.operations.setNotePrivate(w.b.id, true)
            let privateB = try await unlink(connection, edge)
            #expect(privateB.isError == true && text(privateB) == text(missing), "a Private far side")
            _ = try h.operations.setNotePrivate(w.b.id, false)

            // Another edge type: a divide's derived_from link between two of the client's notes'
            // blocks is no version link.
            let divided = try h.operations.newBlock(in: w.a.id, text: "Left half. Right half.", registeringUndo: false)
            _ = try h.operations.divide(divided.block.id, cut: 11)
            let derived = try #require(try await h.database.read { db in
                try String.fetchOne(db, sql: "SELECT id FROM edge WHERE type = 'derived_from' AND deleted_at IS NULL")
            })
            let wrongType = try await unlink(connection, derived)
            #expect(wrongType.isError == true && text(wrongType) == text(missing), "a derived_from edge")

            // An end released to lineage (merged away) — the link joins no two notes now.
            _ = try h.operations.merge(w.bBlocks[0], w.bBlocks[1])
            let released = try await unlink(connection, edge)
            #expect(released.isError == true && text(released) == text(missing), "an end released to lineage")

            #expect(try await edgeIsLive(h, edge), "nothing was written")
            await h.hangUp(connection)
        }
    }

    // MARK: - The act's own refusals, in words

    /// A link that ties a note to one of its SAVED VERSIONS is never bare-unlinked (her Compare
    /// door promotes there, after a confirm; a bare unlink would declassify the version): it
    /// refuses in words once the note is readable — at read alone, before any rung, raising no
    /// ask — and answers the one shape while the note is not.
    @Test func aSavedVersionsLinkRefusesInWordsBeforeAnyRung() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let saved = try h.operations.saveNoteVersion(w.a.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))
            let asksBefore = h.asks.value.count

            let refused = try await unlink(connection, saved.versionEdge.id)
            #expect(refused.isError == true && text(refused) == MCPWriteTools.savedVersionLinkWords, "\(text(refused))")
            #expect(try await edgeIsLive(h, saved.versionEdge.id))
            let versions = try await h.database.read { try Queries.noteVersions($0, of: w.a.id) }
            #expect(versions.map(\.postID) == [saved.post.id], "the version is still the note's")

            let client = try h.client("claude-code").id
            try revokeAll(h)
            _ = try h.operations.grantMCPAccess(client, spec(.read, .note, w.a.id))
            let readOnly = try await unlink(connection, saved.versionEdge.id)
            #expect(text(readOnly) == MCPWriteTools.savedVersionLinkWords, "said at read, before the rung")
            #expect(h.asks.value.count == asksBefore, "no grant could make it land, so nothing is asked")

            try revokeAll(h)
            _ = try h.operations.grantMCPAccess(client, spec(.read, .note, w.b.id))
            let hidden = try await unlink(connection, saved.versionEdge.id)
            let missing = try await unlink(connection, "00000000-dead-beef-0000-000000000000")
            #expect(hidden.isError == true && text(hidden) == text(missing), "the note unreadable: the one shape")
            #expect(h.undoStack.depth == 0)
            await h.hangUp(connection)
        }
    }

    /// A link already gone — the client's own unlink, or the author's ⌥⌘Z of the link — says
    /// so (remove_tag's not-worn precedent), and answers the one shape while a note is unreadable.
    @Test func aLinkAlreadyGoneRefusesInWords() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))
            let edges = try await link(connection, w, [(w.aBlocks[0], w.bBlocks[0])])
            let edge = try #require(edges.first)
            #expect(try await unlink(connection, edge).isError != true)
            let twice = try await unlink(connection, edge)
            #expect(twice.isError == true && text(twice) == MCPWriteTools.linkAlreadyGoneWords, "\(text(twice))")
            #expect(h.undoStack.depth == 2, "a refusal registers nothing")

            let other = try #require(try await link(connection, w, [(w.aBlocks[1], w.bBlocks[1])]).first)
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's version link")
            let undone = try await unlink(connection, other)
            #expect(text(undone) == MCPWriteTools.linkAlreadyGoneWords, "her ⌥⌘Z of the link took it")

            try revokeAll(h)
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .note, w.a.id))
            let hidden = try await unlink(connection, edge)
            #expect(hidden.isError == true && text(hidden) == Self.notShared, "a note unreadable: the one shape")
            await h.hangUp(connection)
        }
    }

    /// **The refusal-wording walk (VX-362: no raw Swift case on the wire):** every case the act
    /// can throw is worded by the tool's ONE map — never its case name, never "Refused:", never
    /// the error's bare description; the not-shared case is the door's one sentence, byte for byte.
    @Test func everyRefusalOfTheActIsWorded() {
        let cases: [Operations.MCPVersionUnlinkRefusal] = [.noSuchLink, .savedVersion, .alreadyUnlinked]
        for refusal in cases {
            let words = MCPWriteTools.words(refusal)
            #expect(!words.hasPrefix("Refused:") && !words.contains("\(refusal)") && words != "\(refusal)",
                    "\(refusal) speaks a raw case: \(words)")
            #expect(words.hasSuffix("."), "\(refusal) is a sentence: \(words)")
        }
        #expect(MCPWriteTools.words(.noSuchLink) == Self.notShared, "the one shape, byte for byte")
        #expect(MCPWriteTools.words(.savedVersion) == MCPWriteTools.savedVersionLinkWords)
        #expect(MCPWriteTools.words(.alreadyUnlinked) == MCPWriteTools.linkAlreadyGoneWords)
    }

    /// **The description claims no authorship the act does not enforce** (the VX-915 ladder's
    /// F-3, its code half): the act takes ANY live `version_of` link by its id — the author's own
    /// Compare mark included (`unlinkVersionForClient` has no authorship fence; the ids reach the
    /// wire only from link_versions' answers) — so the description says where ids come from and
    /// never that the link must be one "link_versions made". It still says the rung and the saved
    /// version's refusal. RED ON OLD: the description read "Remove one version link that
    /// link_versions made, …".
    @Test func theDescriptionSaysWhereIDsComeFromAndClaimsNoAuthorship() throws {
        let text = try #require(MCPToolCatalog.declaration(named: "unlink_versions")).description
        #expect(!text.contains("link_versions made"), "no own-only claim the act does not enforce: \(text)")
        #expect(text.hasPrefix("Remove one version link by its edge_id"), "the link, by its id: \(text)")
        #expect(text.contains("the ids come from link_versions' answers"), "where the ids come from: \(text)")
        #expect(text.contains("Needs write new on both notes the link joins"), "the rung, still said: \(text)")
        #expect(text.contains("A link that ties a note to one of its saved versions is refused"),
                "the saved version's refusal, still said: \(text)")
    }

    // MARK: - The door's rules

    /// VX-396: an `edge_id` holding U+0000 refuses at the call door naming its path; VX-606: an
    /// undeclared argument refuses before any decision; a missing id is the parse's sentence —
    /// nothing written, nothing logged, nothing asked.
    @Test func theDoorsParseRulesHoldForTheNewID() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))
            let edge = try #require(try await link(connection, w, [(w.aBlocks[0], w.bBlocks[0])]).first)
            let activityBefore = try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM mcp_activity") ?? 0
            }
            let asksBefore = h.asks.value.count

            let nul = try await unlink(connection, edge + "\u{0}")
            #expect(nul.isError == true && text(nul) == MCPNullIdentifier(arguments: ["edge_id"]).words, "\(text(nul))")
            let extra = try await call(connection, "unlink_versions", ["edge_id": .string(edge), "note_id": .string(w.a.id)])
            #expect(extra.isError == true
                    && text(extra) == MCPArgumentSchema.words(tool: "unlink_versions", undeclared: ["note_id"]),
                    "\(text(extra))")
            let absent = try await call(connection, "unlink_versions", [:])
            #expect(absent.isError == true && text(absent) == "edge_id is required.", "\(text(absent))")

            let activityAfter = try await h.database.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM mcp_activity") ?? 0
            }
            #expect(activityAfter == activityBefore && h.asks.value.count == asksBefore)
            #expect(try await edgeIsLive(h, edge))
            await h.hangUp(connection)
        }
    }

    /// Activity in words and `list_my_activity`: a landed unlink is listed with the note the
    /// answer told the client; a REFUSED one answers no target and no title — a hidden far side
    /// and an id naming nothing read byte-identical.
    @Test func listMyActivityListsItAndARefusedRowNamesNoTarget() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let w = try world(h)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, w.book.id))
            let edges = try await link(connection, w, [(w.aBlocks[0], w.bBlocks[0]), (w.aBlocks[1], w.bBlocks[1])])
            let stored = try await ends(h, edges[0])
            #expect(try await unlink(connection, edges[0]).isError != true)

            let client = try h.client("claude-code").id
            try revokeAll(h)
            _ = try h.operations.grantMCPAccess(client, spec(.writeNew, .note, w.a.id))
            #expect(try await unlink(connection, edges[1]).isError == true)
            #expect(try await unlink(connection, "00000000-dead-beef-0000-000000000000").isError == true)

            let listed = try json(try await call(connection, "list_my_activity", [:]))
            let acts = (listed["acts"] as? [[String: Any]] ?? []).filter { $0["tool"] as? String == "unlink_versions" }
            #expect(acts.count == 3, "\(acts)")
            let landed = try #require(acts.last)
            #expect(landed["outcome"] as? String == "allowed" && landed["target_kind"] as? String == "note"
                    && landed["target_id"] as? String == stored.noteIDs[0] && landed["title"] != nil, "\(landed)")
            let (missingRow, hiddenRow) = (acts[0], acts[1])
            #expect(without(hiddenRow, ["at"]) == without(missingRow, ["at"]), "hidden and missing read the same")
            #expect(hiddenRow["target_id"] == nil && hiddenRow["target_kind"] == nil && hiddenRow["title"] == nil)

            // Her pane names the note the hidden side's refusal logged (she is the author).
            let logged = try await h.database.read { db in
                try String.fetchAll(db, sql: """
                    SELECT COALESCE(target_id, '-') FROM mcp_activity WHERE act = 'unlink_versions' ORDER BY id
                    """)
            }
            #expect(logged == [stored.noteIDs[0], w.b.id, "-"], "\(logged)")
            await h.hangUp(connection)
        }
    }
}
