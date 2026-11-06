import Foundation
import Testing

@testable import VariorumMCP

// VX-846 (the VX-809 run, batch 5 — her R-846: the VX-771 handoff's O-3/O-4
// tail, "MCPSpec governs; wording hers at the build"; every sentence below is
// PROVISIONAL P-809-6, drafted for her bundle). The TOOL DESCRIPTIONS' half of
// the docs tail — the model's layer (the field guide's chapter is the human's,
// pinned in the App target's `TutorialMCPChapterTests`):
//
// 1. `remove_tag`'s board pointer names `create_gathering` only for a client
//    that can mint one (write new on a wing) and gains the lesser-grant road,
//    her words: "ask the author for a gathering".
// 2. `add_note_to_book` and `move_note_to_wing` say their HIDDEN-CAUSE fixed
//    sentences exist (A-809-4 — the batch 1 record's two noted gaps):
//    `move_book_to_wing`'s description already did ("one sentence says so").
// 3. `MCPSession.instructions` stays UNTOUCHED (R-VX184-3 — 3,089 of its
//    3,100; the bound re-asserted here beside `MCPAdviceServerTests`').
//
// RED ON OLD: written ahead of the description edits — 1 and 2 failed on the
// tree at `013c00cff` (no "ask the author for a gathering"; neither description
// named the fixed sentence), green after.
@Suite("VX-846 — the docs tail: the tool descriptions")
struct MCPDocsTailTests {
    private func description(_ name: String) throws -> String {
        try #require(MCPToolCatalog.declaration(named: name)).description
    }

    /// `remove_tag`'s board pointer: a gathering, made with create_gathering
    /// where the client can (write new on a wing), else asked of the author.
    @Test func removeTagsGatheringPointerOffersTheLesserGrantRoad() throws {
        let text = try description("remove_tag")
        #expect(text.contains("create_gathering"), "the mint is still named: \(text)")
        #expect(text.contains("write new on a wing"), "…for the client that can mint one: \(text)")
        #expect(text.contains("ask the author for a gathering"), "her lesser-grant words: \(text)")
        #expect(MCPToolCatalog.declaration(named: "create_gathering")?.rung == .writeNew)
        #expect(MCPToolCatalog.declaration(named: "create_gathering")?.scopes == [.wing],
                "create_gathering is a wing grant's act — so the pointer says so")
        // Batch 1's and batch 3's shape stays said (VX-825's keys, the swap).
        for phrase in ["still_in_books", MCPWriteTools.beyondReachKey, MCPWriteTools.tagUnusedKey, "replace_tag"] {
            #expect(text.contains(phrase), "remove_tag still says \(phrase)")
        }
    }

    /// A-809-4's two fixed sentences, said to exist where their acts are
    /// described (`move_book_to_wing`'s description is the precedent).
    @Test func theHiddenCauseSentencesAreSaidToExist() throws {
        let add = try description("add_note_to_book")
        #expect(add.contains("owns its notes"), "the ownership refusal is named: \(add)")
        #expect(add.contains("beyond your reach") && add.contains("one fixed sentence"),
                "the hidden-cause sentence is said to exist: \(add)")
        #expect(MCPWriteTools.addHiddenCauseWords.contains("beyond your reach"),
                "…and the sentence itself says so")

        let move = try description("move_note_to_wing")
        #expect(move.contains("finished or sealed"), "her refusal stays named: \(move)")
        #expect(move.contains("beyond your reach") && move.contains("one fixed sentence"),
                "the hidden-cause sentence is said to exist: \(move)")
        #expect(MCPWriteTools.moveHiddenCauseWords.contains("beyond your reach"))

        // A JUSTIFIED EDIT (VX-879 — the VX-808 run, Unit B5; the site review's
        // B2-F1, verified in code): this pin asserted the precedent's own words,
        // "nor while something beyond your reach holds one of its notes" — an
        // OVERCLAIM: a plain book the client can't read never blocks the move
        // (her body severs that membership — `relocateNote` refuses only a
        // FINISHED or SEALED holder; `MCPBookWingMoveServerTests` moves past a
        // hidden plain holder). What refuses is a frozen holder or a shed fence
        // (A-809-15); the fixed sentence is still said to exist.
        let book = try description("move_book_to_wing")
        #expect(book.contains("finished or sealed") && book.contains("a Private book or the daily Journal"),
                "the two causes that refuse, named: \(book)")
        #expect(book.contains("beyond your reach, one sentence says so"), "the hidden-cause sentence exists: \(book)")
        #expect(book.contains("A book you can't read that simply holds one of its notes never stops the move"),
                "a plain unreadable holder blocks nothing: \(book)")
        #expect(!book.contains("something beyond your reach holds one of its notes"), "the overclaim is gone: \(book)")
    }

    /// R-VX184-3: the instructions stay inside their bound — and this tail
    /// left them untouched (prefer untouched; batch 4's 3,089 of 3,100).
    /// (VX-811's tail — the VX-808 run, Unit B5 — then let the read rung say it
    /// proposes: 3,098 of 3,100.)
    @Test func theInstructionsStayInsideTheirBound() {
        #expect(MCPSession.instructions.count <= MCPSession.instructionsBound)
        #expect(MCPSession.instructionsBound == 3_100)
    }

    /// **VX-811's docs tail (the VX-808 run, Unit B5 — A-808-10, B2's handoffs;
    /// PROVISIONAL words for her bundle):** the propose road is said where the
    /// model reads the door — the advice's READ rung proposes (inside R-VX184-3's
    /// bound), `set_book_rule` names the count it answers (VX-811 ruling 4) beside
    /// its scope sentence, and `add_note_to_book` points a client that can only
    /// read at the road it has. Each truth is the catalog's own (the tool's rung
    /// and scopes; the answer's keys). RED ON OLD by absence.
    @Test func theProposeRoadIsSaidWhereTheModelReadsTheDoor() throws {
        let propose = try #require(MCPToolCatalog.declaration(named: "propose_notes_to_book"))
        #expect(propose.rung == .read && propose.scopes == [.book, .wing], "the catalog's facts the words state")

        let advice = MCPSession.instructions
        #expect(advice.contains("read (read, search and propose)"), "the read rung proposes: \(advice.prefix(900))")
        #expect(advice.count <= MCPSession.instructionsBound, "inside R-VX184-3's bound: \(advice.count)")

        let rule = try description("set_book_rule")
        #expect(rule.contains(MCPBookFacts.waitingCountKey) && rule.contains(MCPWriteTools.beyondReachKey),
                "set_book_rule names its count and the scope sentence beside it: \(rule)")
        #expect(rule.contains("how many of them you can read"), "…and what the count counts: \(rule)")

        let add = try description("add_note_to_book")
        #expect(add.contains("propose_notes_to_book"), "the read-only road is pointed at: \(add)")
    }
}
