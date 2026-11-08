import Foundation
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-891 (the VX-912 run, batch B4; the VX-808 ladder's round-1 F-3): VX-859's
// book-cursor rule applied to the GATHERING shape — a `next_cursor` naming
// anything this client can't read (a member a fence hides, a member made Private
// since, a note that left the rule, an id that never was) answers exactly as one
// naming nothing: the stale sentence, and the listing starts again. Before the
// fix a gathering cursor resumed after ANY note its assembly held, readable or
// not, while a missing id answered stale — hidden told apart from missing. The
// red-on-old pin is the two-store catalog's gathering-form cursor arms
// (`MCPTwoStoreCatalogArms.cursorArms`); these pin the road's edges, pre-fix API
// only, so each compiles on the pre-fix tree.

private func spec(_ id: String) -> Operations.MCPGrantSpec {
    .init(rung: .read, scopeKind: .gathering, scopeID: id, duration: .always)
}

private func cursor(_ key: String, _ id: String) -> String {
    Data("g\n\(key)\n\(id)".utf8).base64EncodedString()
}

private func decoded(_ cursor: String?) -> [String] {
    guard let cursor, let data = Data(base64Encoded: cursor) else { return [] }
    return String(decoding: data, as: UTF8.self).components(separatedBy: "\n")
}

/// An id no row carries.
private let nothing = "00000000-0000-0000-0000-00000000FFFF"

private func page(
    _ connection: HarnessConnection, _ gatheringID: String, limit: Int, after: String? = nil
) async throws -> (ids: [String], next: String?, text: String, isError: Bool) {
    var arguments: [String: Value] = ["book_id": .string(gatheringID), "limit": .int(limit)]
    if let after { arguments["cursor"] = .string(after) }
    let result = try await connection.client.callTool(name: "list_notes", arguments: arguments)
    let said = text(result)
    guard result.isError != true else { return ([], nil, said, true) }
    let object = try json(result)
    let ids = (object["notes"] as? [[String: Any]] ?? []).compactMap { $0["id"] as? String }
    return (ids, object["next_cursor"] as? String, said, false)
}

@Suite("VX-891 — the gathering cursor resumes only after a note the client can read", .serialized)
struct MCPGatheringCursorServerTests {
    /// A Home gathering collecting #t, its notes `readable` (tagged, in mint
    /// order — the assembly's created-at order) — the client reads it through
    /// its own gathering grant.
    private func gathering(
        _ h: ServerHarness, readable count: Int
    ) throws -> (gathering: String, tag: String, notes: [String]) {
        let tag = try h.operations.createTag(name: "t")
        let gathering = try h.operations.createReading(
            name: "Gathered", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
        var notes: [String] = []
        for index in 0..<count {
            let note = try h.operations.createPost(title: "n\(index)")
            _ = try h.operations.applyTag(tag.id, toPost: note.id)
            notes.append(note.id)
        }
        return (gathering.id, tag.id, notes)
    }

    /// GUARD (green on both sides — VX-825 built it): pages tile the
    /// gathering's READABLE notes in its order, each key is the readable
    /// ordinal of the last note listed, and no cursor names the hidden member.
    @Test func pagesTileTheReadableNotesAndNoCursorNamesTheHiddenOne() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let tag = try h.operations.createTag(name: "t")
            let gathering = try h.operations.createReading(
                name: "Gathered", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            var readable: [String] = []
            var hidden = ""
            for index in 0..<5 {
                let note = try h.operations.createPost(title: "n\(index)")
                _ = try h.operations.applyTag(tag.id, toPost: note.id)
                if index == 1 {
                    _ = try h.operations.setNotePrivate(note.id, true)
                    hidden = note.id
                } else {
                    readable.append(note.id)
                }
            }
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(gathering.id))
            var seen: [String] = []
            var keys: [String] = []
            var next: String?
            for _ in 0..<10 {
                let answer = try await page(connection, gathering.id, limit: 2, after: next)
                #expect(!answer.isError, "\(answer.text)")
                seen += answer.ids
                guard let resume = answer.next else { break }
                let parts = decoded(resume)
                #expect(parts.count == 3 && parts[0] == "g" && parts[2] == answer.ids.last, "\(parts)")
                #expect(!parts.contains(hidden), "a cursor never names the hidden member")
                keys.append(parts.count == 3 ? parts[1] : "")
                next = resume
            }
            #expect(seen == readable, "the gathering's readable notes, in its order, each once")
            #expect(keys == ["1", "3"], "the readable ordinal of the last note listed: \(keys)")
            await h.hangUp(connection)
        }
    }

    /// RED ON OLD — THE FIX'S PIN: a cursor naming a member a fence hides (a
    /// Private note the rule gathers) answers byte-identically to one naming
    /// no note at all — the stale sentence. Before the fix it resumed after
    /// the hidden note and listed the page behind it.
    @Test func aCursorNamingAPrivateMemberAnswersAsOneNamingNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let world = try gathering(h, readable: 1)
            let hidden = try h.operations.createPost(title: "hidden")
            _ = try h.operations.applyTag(world.tag, toPost: hidden.id)
            _ = try h.operations.setNotePrivate(hidden.id, true)
            let later = try h.operations.createPost(title: "later")
            _ = try h.operations.applyTag(world.tag, toPost: later.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(world.gathering))
            let onHidden = try await page(connection, world.gathering, limit: 1, after: cursor("0", hidden.id))
            let onNothing = try await page(connection, world.gathering, limit: 1, after: cursor("0", nothing))
            #expect(onNothing.isError && onNothing.text == MCPReadTools.staleCursorMessage, "\(onNothing.text)")
            #expect(onHidden.isError == onNothing.isError && onHidden.text == onNothing.text,
                    "hidden reads as missing, byte for byte: \(onHidden.text)")
            await h.hangUp(connection)
        }
    }

    /// RED ON OLD: the fence's OTHER key — the daily Journal's entry, which a
    /// gathering grant never reaches (a per-ask note grant only) although the
    /// rule gathers it — answers as nothing too.
    @Test func aCursorNamingAFencedJournalEntryAnswersAsOneNamingNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let world = try gathering(h, readable: 1)
            let entry = try h.operations.createOrOpenJournalEntry(entryDate: "2026-06-30").container
            _ = h.operations.shelveInDailyJournalBook(entry.id)
            _ = try h.operations.applyTag(world.tag, toPost: entry.id)
            let later = try h.operations.createPost(title: "later")
            _ = try h.operations.applyTag(world.tag, toPost: later.id)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(world.gathering))
            let listed = try await page(connection, world.gathering, limit: 5)
            #expect(!listed.isError && !listed.ids.contains(entry.id), "the entry is fenced: \(listed.text)")
            let onEntry = try await page(connection, world.gathering, limit: 1, after: cursor("0", entry.id))
            let onNothing = try await page(connection, world.gathering, limit: 1, after: cursor("0", nothing))
            #expect(onEntry.isError == onNothing.isError && onEntry.text == onNothing.text,
                    "a fenced member reads as missing: \(onEntry.text)")
            await h.hangUp(connection)
        }
    }

    /// RED ON OLD: a cursor whose note was READABLE when it was minted and is
    /// Private now starts the listing again (the ruled trade, as the book's) —
    /// it never resumes after a note the client can no longer read.
    @Test func aCursorWhoseNoteWasMadePrivateSinceStartsTheListingAgain() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let world = try gathering(h, readable: 3)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(world.gathering))
            let first = try await page(connection, world.gathering, limit: 1)
            #expect(first.ids == [world.notes[0]] && first.next != nil, "\(first.text)")
            _ = try h.operations.setNotePrivate(world.notes[0], true)
            let resumed = try await page(connection, world.gathering, limit: 1, after: first.next)
            #expect(resumed.isError && resumed.text == MCPReadTools.staleCursorMessage, "\(resumed.text)")
            let again = try await page(connection, world.gathering, limit: 5)
            #expect(again.ids == [world.notes[1], world.notes[2]], "the listing starts again")
            await h.hangUp(connection)
        }
    }

    /// GUARD (green on both sides — the gathering cursor's own road): a
    /// cursor whose note has left the rule (untagged) answers the stale
    /// sentence, and the listing starts again.
    @Test func aCursorWhoseNoteLeftTheGatheringStartsTheListingAgain() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let world = try gathering(h, readable: 3)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(world.gathering))
            let first = try await page(connection, world.gathering, limit: 1)
            #expect(first.ids == [world.notes[0]])
            try h.operations.removeTag(world.tag, fromPost: world.notes[0])
            let resumed = try await page(connection, world.gathering, limit: 1, after: first.next)
            #expect(resumed.isError && resumed.text == MCPReadTools.staleCursorMessage, "\(resumed.text)")
            let again = try await page(connection, world.gathering, limit: 5)
            #expect(again.ids == [world.notes[1], world.notes[2]], "the listing starts again")
            await h.hangUp(connection)
        }
    }

    /// GUARD (green on both sides): a readable note's cursor resumes after it
    /// — the fix refuses only what the client can't read.
    @Test func aReadableNotesCursorStillResumesAfterIt() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let world = try gathering(h, readable: 3)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(world.gathering))
            let resumed = try await page(connection, world.gathering, limit: 5, after: cursor("0", world.notes[0]))
            #expect(!resumed.isError && resumed.ids == [world.notes[1], world.notes[2]], "\(resumed.text)")
            await h.hangUp(connection)
        }
    }
}
