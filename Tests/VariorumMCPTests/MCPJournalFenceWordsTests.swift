import Foundation
import Testing

@testable import VariorumCore
@testable import VariorumMCP

// R-805-5 (the VX-805 run) — THE WIRE'S JOURNAL FENCE, IN WORDS. The two
// refusals her doors no longer meet (VX-435 moves the daily Journal, VX-436
// deletes it) are the wire's alone, so the wire speaks them FIRST through its
// ONE refusal chain (`MCPWireRefusalCopy.spoken`) — never the raw case, never
// the app table's sentence (which named archive as her road and would be
// spoken by a host whose table still carried it). No socket: the chain is
// pure. RED ON OLD: the move case did not exist and the delete case fell to
// the app's table (`BookArchiveCopy.cannotDeleteDailyJournal`, a sentence for
// her doors).

@Suite("R-805-5 — the Journal fence's words, through the one chain")
struct MCPJournalFenceWordsTests {
    /// A host table that would speak for every case — the chain must not
    /// consult it for the fence's two refusals.
    private let hostTable: (Error) -> String? = { _ in "the host's sentence" }

    @Test func theMoveFenceSpeaksTheWiresOwnSentence() {
        let error = OperationError.dailyJournalMovesOnlyByHand(id: "r")
        #expect(MCPWireRefusalCopy.spoken(error, appWords: hostTable)
                == MCPWireRefusalCopy.dailyJournalMoveWords)
        #expect(MCPWireRefusalCopy.dailyJournalMoveWords.contains("daily Journal"))
        #expect(!MCPWireRefusalCopy.dailyJournalMoveWords.contains("dailyJournal"), "never the raw case")
    }

    @Test func theDeleteFenceSpeaksTheWiresOwnSentence() {
        let error = OperationError.dailyJournalCannotBeDeleted(id: "r")
        #expect(MCPWireRefusalCopy.spoken(error, appWords: hostTable)
                == MCPWireRefusalCopy.dailyJournalDeleteWords)
        #expect(MCPWireRefusalCopy.dailyJournalDeleteWords.contains("archive_book"),
                "names the road the wire keeps open")
        #expect(MCPWireRefusalCopy.unexpected(error, tool: "delete_book", appWords: hostTable)
                == MCPWireRefusalCopy.dailyJournalDeleteWords, "the catch-all speaks it too")
    }
}
