import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// VX-760 (the VX-771 run, batch 2) — the pure rule behind edit_take's mismatch answer
// (`MCPExpectedTextMismatch.diagnose`), its place in THE ONE CHAIN
// (`MCPWireRefusalCopy.spoken`), and the door's fallbacks (`expectedTextMismatch`):
// where the door can prove nothing, the op's own refusal speaks as before. New API —
// green by construction; the red-on-old pins are `MCPExpectedTextMismatchServerTests`.

@Suite("VX-760 — the mismatch rule, its place in the chain, and the door's fallbacks", .serialized)
struct MCPExpectedTextMismatchRuleTests {
    private func pattern(_ sent: String, _ stored: String) -> MCPExpectedTextMismatch.Pattern? {
        MCPExpectedTextMismatch.diagnose(sent: sent, stored: stored)?.pattern
    }

    // MARK: - The rule

    @Test func equalTextsAreNoMismatchCanonicallySo() {
        #expect(pattern("Her line.", "Her line.") == nil)
        // The op's precondition is canonical (Swift `String` equality): an NFD
        // spelling of an NFC take is no mismatch the door would explain.
        #expect(pattern("Um cafe\u{0301}.", "Um caf\u{00E9}.") == nil)
    }

    @Test func eachPatternFromTheTwoTextsAlone() {
        #expect(pattern("Her line.", "Her line.\n") == .whitespaceAtEnds)
        #expect(pattern("  Her line.", "Her line.") == .whitespaceAtEnds)
        #expect(pattern("Her line.", "Her line. More.") == .startOfTake)
        #expect(pattern("line. More", "Her line. More.") == .passageOfTake)
        #expect(pattern("Her line. More.", "line") == .takeAndMore)
        #expect(pattern("Her line. More.", "Her line.") == .takeAndMore, "the take is the sent text's start")
        #expect(pattern("Her lines.", "Her line, rewritten.") == .differs(at: 8))
        #expect(pattern("", "Her line.") == .differs(at: 0), "an empty expected_text differs at once")
        #expect(pattern("Her line.", "") == .takeAndMore, "an empty take lies inside any text")
    }

    /// The offset is into the SENT text, in UTF-16 units, at the first grapheme
    /// that differs canonically — so a different spelling of the common run
    /// counts in the sent text's own units.
    @Test func theOffsetCountsTheSentTextsUTF16Units() {
        #expect(pattern("\u{1F30A}a", "\u{1F30A}b") == .differs(at: 2))
        #expect(pattern("cafe\u{0301} x", "caf\u{00E9} y") == .differs(at: 6), "the sent NFD run is 6 units")
        #expect(pattern("caf\u{00E9} x", "cafe\u{0301} y") == .differs(at: 5), "the sent NFC run is 5 units")
        let lengths = MCPExpectedTextMismatch.diagnose(sent: "\u{1F30A}", stored: "\u{1F30A} sea")
        #expect(lengths?.sentLength == 2 && lengths?.storedLength == 6)
    }

    @Test func noPatternClaimsARace() {
        let all: [MCPExpectedTextMismatch.Pattern] = [
            .whitespaceAtEnds, .startOfTake, .passageOfTake, .takeAndMore, .differs(at: 3),
        ]
        for pattern in all {
            let words = MCPExpectedTextMismatch(pattern: pattern, sentLength: 1, storedLength: 2).words
            #expect(!words.contains("while that gesture was landing"), "\(pattern): \(words)")
            #expect(words.hasSuffix("Nothing was written."), "\(pattern): \(words)")
            #expect(words.contains("expected_text is 1 characters, the take 2"), "both lengths — \(pattern): \(words)")
        }
    }

    // MARK: - The one chain

    /// The door's words come FIRST in the chain — in front of the app's table —
    /// and the op's own refusal still reaches the table unchanged.
    @Test func theMismatchIsSpokenFirstInTheChainAndTheOpsRefusalStillReachesTheTable() {
        let mismatch = MCPExpectedTextMismatch(pattern: .startOfTake, sentLength: 3, storedLength: 9)
        #expect(MCPWireRefusalCopy.spoken(mismatch) { _ in "the app's table" } == mismatch.words)
        #expect(MCPWireRefusalCopy.spoken(OperationError.bufferChangedSinceGesture(variantID: "v")) { _ in
            "the app's table"
        } == "the app's table", "her doors' sentence, untouched")
    }

    // MARK: - The door's fallbacks (nil — the op's refusal speaks)

    @Test func theDoorProvesNothingForAGoneMovedOrUnreachableTakeOrOneThatNowMatches() throws {
        try withDependencies {
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SystemRandomNumberGenerator())
        } operation: {
            let database = try AppDatabase.inMemory()
            try withDependencies { $0.database = database } operation: {
                let ops = Operations()
                let tools = MCPWriteTools(database: database, grants: ops, executor: MCPSerialExecutor(operations: ops))
                let note = try ops.createPost(title: "ch 1")
                let other = try ops.createPost(title: "ch 2")
                let one = try ops.newBlock(in: note.id, text: "Her line.", registeringUndo: false)
                let two = try ops.newBlock(in: note.id, text: "Her second line.", registeringUndo: false)
                let three = try ops.newBlock(in: note.id, text: "Her third line.", registeringUndo: false)
                _ = try ops.recordMCPContact(name: "claude-code", version: "1")
                let client = try #require(try database.read { try Queries.mcpClient($0, name: "claude-code") })
                let grant = try #require(try ops.approveMCPClient(
                    client.id, granting: .init(rung: .edit, scopeKind: .wing, scopeID: "", duration: .always)))
                func mismatch(_ takeID: String, _ sent: String) throws -> MCPExpectedTextMismatch? {
                    try tools.expectedTextMismatch(takeID: takeID, noteID: note.id, sent: sent, clientName: "claude-code")
                }
                // The proving case first: the door says the pattern.
                #expect(try mismatch(one.variant.id, "Her")?.pattern == .startOfTake)
                // The stored text now reads as sent: nothing to explain.
                #expect(try mismatch(one.variant.id, "Her line.") == nil)
                // The take moved to another note since the act decided.
                try ops.moveBlock(two.block.id, to: other.id, at: .end)
                #expect(try mismatch(two.variant.id, "Her") == nil)
                // The take's block is gone.
                try ops.deleteBlock(three.block.id)
                #expect(try mismatch(three.variant.id, "Her") == nil)
                // The client no longer reaches the note at edit.
                try ops.revokeMCPGrant(grant)
                #expect(try mismatch(one.variant.id, "Her") == nil)
            }
        }
    }
}
