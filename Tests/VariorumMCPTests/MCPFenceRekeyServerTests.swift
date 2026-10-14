import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// 13n-c U1 — THE FENCE RE-KEY ON THE WIRE (VX-163) and THE ONE ANSWER
// under a Home-wing read grant (her Air-round caveat, verbatim: "the decisive
// fence-vs-scope proof re-runs under a Home-wing read grant" — under book grants
// a journal entry is out of SCOPE twice over; under a Home-wing grant only the
// FENCE keeps it out, so this is where fenced must answer exactly as nothing).
//
// AppSpec §12's contract: "everything unreachable answers ONE uniform
// not-shared shape — no fenced-vs-unshared oracle anywhere". A daily-Journal
// entry, a Private note and an id that names nothing answer byte-identically on
// every tool; a word only the daily Journal holds searches exactly like a word
// nowhere. The just-in-time ask is still put to HER (AF-6's silent-ask posture:
// the wire stays one answer whether or not an ask was raised).

private func grant(
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

@Suite("13n-c U1 — the fence re-key on the wire, and the one answer", .serialized)
struct MCPFenceRekeyServerTests {
    // MARK: - J8: the wire's own sentences say only the daily Journal is fenced

    @Test func theWiresSentencesNameTheDailyJournalNotEveryJournal() {
        let listBooks = MCPToolCatalog.listBooks.description
        let listNotes = MCPToolCatalog.listNotes.description
        #expect(listBooks.contains("The daily Journal and Private books are never listed."))
        #expect(listNotes.contains("Daily Journal entries and Private notes appear only when shared one ask at a time."))
        for text in [listBooks, listNotes] {
            let stripped = text.replacingOccurrences(of: "Daily Journal entries", with: "")
            #expect(!text.contains("Journals and") && !stripped.contains("Journal entries"),
                    "no sentence may say every journal is fenced (VX-163)")
        }
        // 13n-c U1 orchestrator ruling F-7 (a): a fenced BOOK is the one
        // answer too — AppSpec §12's "no fenced-vs-unshared oracle anywhere".
        // A fenced NOTE is the one answer, whichever fence (T-2).
        for fence in [MCPGrantRule.Fence.journal, .privateMark] {
            #expect(MCPRefusalCopy.words(.fenced(fence), .book) == MCPRefusalCopy.words(.notShared, .book))
            #expect(MCPRefusalCopy.words(.fenced(fence), .note) == MCPRefusalCopy.words(.notShared, .note))
            #expect(MCPRefusalCopy.words(.fenced(fence), .note, asked: true) == MCPRefusalCopy.words(.notShared, .note))
        }
    }

    // MARK: - A journal-trait book reads like any book

    @Test func aJournalTraitBookIsListedReadAndSearchedUnderABookAWingAndTheOpenBook() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let trait = try h.operations.createReading(name: "dream journal", kind: .book, profile: "journal")
            let member = try h.operations.newPostInReading(trait.id, title: "the flood dream")
            _ = try h.operations.newBlock(in: member.id, text: "oneirology at dawn", registeringUndo: false)

            // A book grant naming the trait book (refused as fenced before VX-163).
            let byBook = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", grant(.read, .book, trait.id))
            let books = try json(try await call(byBook, "list_books", [:]))["books"] as? [[String: Any]]
            #expect(books?.compactMap { $0["id"] as? String } == [trait.id], "the trait book is listed")
            #expect(books?.first?["notes"] as? Int == 1, "its member counts — it is not fenced")
            let listed = try json(try await call(byBook, "list_notes", ["book_id": .string(trait.id)]))
            #expect((listed["notes"] as? [[String: Any]])?.compactMap { $0["id"] as? String } == [member.id])
            let read = try await call(byBook, "read_note", ["note_id": .string(member.id)])
            #expect(read.isError != true && text(read).contains("oneirology at dawn"))
            let found = try json(try await call(byBook, "search", ["query": "oneirology"]))
            #expect((found["passages"] as? [[String: Any]])?.compactMap { $0["note_id"] as? String } == [member.id])
            await h.hangUp(byBook)

            // A Home-wing grant reaches it too.
            let byWing = try await h.connect(as: "codex")
            _ = try h.approve("codex", grant(.read, .wing, ""))
            let viaWing = try await call(byWing, "read_note", ["note_id": .string(member.id)])
            #expect(viaWing.isError != true && text(viaWing).contains("oneirology at dawn"))
            await h.hangUp(byWing)

            // And the open book, with no grant at all.
            let open = try await h.connect(as: "local-llama")
            _ = try h.approve("local-llama", nil)
            try h.operations.setMCPSwitch(.openBook, on: true)
            let viaOpen = try await call(open, "read_note", ["note_id": .string(member.id)])
            #expect(viaOpen.isError != true && text(viaOpen).contains("oneirology at dawn"))
            await h.hangUp(open)
        }
    }

    // MARK: - THE ONE ANSWER under a Home-wing read grant

    @Test func underAHomeWingReadGrantTheFencedAndTheNonexistentAnswerByteIdentically() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            // THE daily Journal, made by its own door, holding a day entry.
            let entry = try h.operations.createOrOpenJournalEntry(entryDate: "2026-07-01").container
            _ = try h.operations.newBlock(in: entry.id, text: "crataegus in the hedgerow", registeringUndo: false)
            guard case .shelved(let dailyID) = h.operations.shelveInDailyJournalBook(entry.id) else {
                Issue.record("the daily door did not file the entry")
                return
            }
            // A plain note filed in the daily Journal (the MEMBER leg alone).
            let filed = try h.operations.createPost(title: "a loose page")
            _ = try h.operations.newBlock(in: filed.id, text: "quillwort by the tarn", registeringUndo: false)
            _ = try h.operations.addPostToReading(filed.id, to: dailyID)
            // A Private note, and a ⌘J entry filed into a TRAIT book (D-1).
            let privateNote = try h.operations.createPost(title: "not for anyone")
            _ = try h.operations.newBlock(in: privateNote.id, text: "sphagnum secrets", registeringUndo: false)
            try h.operations.setNotePrivate(privateNote.id, true)
            let trait = try h.operations.createReading(name: "dream journal", kind: .book, profile: "journal")
            let dayInTrait = try h.operations.createOrOpenJournalEntry(entryDate: "2026-07-02").container
            _ = try h.operations.addPostToReading(dayInTrait.id, to: trait.id)
            // The control: a plain Home note the grant reaches.
            let plain = try h.operations.createPost(title: "plain")
            _ = try h.operations.newBlock(in: plain.id, text: "bracken everywhere", registeringUndo: false)
            let nowhere = "00000000-0000-4000-8000-00000000dead"

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", grant(.read, .wing, ""))

            // read_note / export_note: ONE answer for every unreachable note.
            for tool in ["read_note", "export_note"] {
                let void = try await call(connection, tool, ["note_id": .string(nowhere)])
                #expect(void.isError == true)
                for fenced in [entry.id, filed.id, privateNote.id, dayInTrait.id] {
                    let answer = try await call(connection, tool, ["note_id": .string(fenced)])
                    #expect(answer.isError == true)
                    #expect(text(answer) == text(void), "\(tool): fenced \(fenced) must answer as nothing")
                }
            }
            #expect(text(try await call(connection, "read_note", ["note_id": .string(plain.id)]))
                .contains("bracken everywhere"), "the control is readable")

            // search scoped to a note: the same one answer.
            let voidScoped = text(try await call(connection, "search", ["query": "the", "note_id": .string(nowhere)]))
            for fenced in [entry.id, privateNote.id] {
                #expect(text(try await call(connection, "search", ["query": "the", "note_id": .string(fenced)]))
                        == voidScoped)
            }

            // An edit-rung act on a fenced note answers as it does on nothing.
            let voidDate = text(try await call(connection, "set_entry_date", [
                "note_id": .string(nowhere), "entry_date": .string("2019-03-04"),
            ]))
            #expect(text(try await call(connection, "set_entry_date", [
                "note_id": .string(entry.id), "entry_date": .string("2019-03-04"),
            ])) == voidDate)

            // search: a word only the daily Journal holds answers EXACTLY like a
            // word nowhere (her "crat attack" probe, re-run where only the fence
            // keeps it out); the Private note's word likewise.
            let none = text(try await call(connection, "search", ["query": "zyzzyva"]))
            #expect(text(try await call(connection, "search", ["query": "crataegus"])) == none)
            #expect(text(try await call(connection, "search", ["query": "quillwort"])) == none)
            #expect(text(try await call(connection, "search", ["query": "sphagnum"])) == none)
            let control = try json(try await call(connection, "search", ["query": "bracken"]))
            #expect((control["passages"] as? [[String: Any]])?.compactMap { $0["note_id"] as? String } == [plain.id])

            // The daily Journal itself is listed nowhere.
            let books = try json(try await call(connection, "list_books", [:]))["books"] as? [[String: Any]]
            #expect(books?.compactMap { $0["id"] as? String }.contains(dailyID) == false)
            #expect(books?.compactMap { $0["id"] as? String }.contains(trait.id) == true,
                    "the trait book is — its fenced day entry never counts")
            #expect(books?.first { $0["id"] as? String == trait.id }?["notes"] as? Int == 0)

            // HER side still hears it: the ask was queued for the fenced entry,
            // never "always" (AF-6's silent ask — the wire said nothing of it).
            let asked = h.asks.value.first { $0.scopeID == entry.id }
            #expect(asked?.fence == .journal && asked?.offersAlways == false)
            await h.hangUp(connection)
        }
    }

    // MARK: - F1 (13n-c U1 ladder round 1 — the recorded F-8, built): a LIVE
    // per-ask grant holder asking a HIGHER rung hears the honest rung

    /// A client reading a fenced note on its own live grant and then asking
    /// to SUGGEST hears `rungTooLow` + the asked sentence (AF-6's ruled
    /// posture for a target the client legitimately knows), never "or doesn't
    /// exist" about a note it can read this second; the ask queues at the
    /// asked rung and never offers "always". A SPENT once grant is a lapsed
    /// grant: the one answer returns, byte-equal to an id naming nothing
    /// (the implementer's refinement — the hoist opens no road).
    @Test func aLiveGrantHolderAskingHigherHearsTheHonestRungAndALapsedGrantTheOneAnswer() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let entry = try h.operations.createOrOpenJournalEntry(entryDate: "2026-07-03").container
            let block = try h.operations.newBlock(in: entry.id, text: "a hedge of holly", registeringUndo: false)
            let nowhere = "00000000-0000-4000-8000-00000000f00d"

            // A while-connected READ grant naming the fenced note (per-ask legal).
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", grant(.read, .note, entry.id, .connection))
            let read = try await call(connection, "read_note", ["note_id": .string(entry.id)])
            #expect(read.isError != true && text(read).contains("a hedge of holly"),
                    "its own grant reads the note")
            let asksBefore = h.asks.value.count
            let refused = try await call(connection, "add_take", [
                "block_id": .string(block.block.id), "text": .string("another try"),
            ])
            #expect(refused.isError == true)
            #expect(text(refused)
                    == MCPRefusalCopy.words(.rungTooLow(granted: .read), .note) + " " + MCPRefusalCopy.askedSentence,
                    "the honest rung + the asked sentence — never the one answer to a grant holder")
            let ask = h.asks.value.last
            #expect(h.asks.value.count == asksBefore + 1 && ask?.scopeID == entry.id
                    && ask?.rung == .suggest && ask?.fence == .journal && ask?.offersAlways == false)
            await h.hangUp(connection)

            // A ONCE read grant, spent by its first read: the very next read
            // answers the one answer, byte-equal to an id naming nothing.
            let lapsed = try await h.connect(as: "codex")
            _ = try h.approve("codex", grant(.read, .note, entry.id, .once))
            let spent = try await call(lapsed, "read_note", ["note_id": .string(entry.id)])
            #expect(spent.isError != true && text(spent).contains("a hedge of holly"), "the once grant spends")
            let after = try await call(lapsed, "read_note", ["note_id": .string(entry.id)])
            let void = try await call(lapsed, "read_note", ["note_id": .string(nowhere)])
            #expect(after.isError == true && text(after) == text(void),
                    "a lapsed grant opens no road — the one answer returns")
            await h.hangUp(lapsed)
        }
    }
}
