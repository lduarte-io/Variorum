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

        #expect(try description("move_book_to_wing").contains("something beyond your reach holds one of its notes"),
                "the precedent stands")
    }

    /// R-VX184-3: the instructions stay inside their bound — and this tail
    /// left them untouched (prefer untouched; batch 4's 3,089 of 3,100).
    @Test func theInstructionsStayInsideTheirBound() {
        #expect(MCPSession.instructions.count <= MCPSession.instructionsBound)
        #expect(MCPSession.instructionsBound == 3_100)
    }
}
