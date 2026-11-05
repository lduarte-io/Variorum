import Foundation
import GRDB
import MCP
import VariorumCore

/// **A REFUSAL WHOSE CAUSE IS BEYOND THE CLIENT'S REACH** (VX-825 — the VX-809
/// run, batch 1; her R-825 + R-825-sweep (b), the orchestrator's A-809-4;
/// PROVISIONAL P-809-2 for the sentences).
///
/// Some acts cannot succeed for a reason that is real and not the client's to
/// see — ownership is real, a finished book is real. The principle the door
/// builds to: **a refusal may speak a fact OF A READABLE ENTITY in her doors'
/// words; a refusal whose CAUSE is a fact of an UNREADABLE entity speaks ONE
/// fixed sentence per act family — no name, no count, no kind.** The one bit
/// that cannot be hidden (a refusal where a store without the hidden thing
/// would have let the act land) is the law's ONE recorded exception class; it
/// is said honestly and minimally, never as "not shared" (a lie about a
/// reachable note) and never by letting the act land (that would break
/// ownership or a finished book).
///
/// The test is the REACHABLE verdict: the same rule decided over only the
/// entities this client can read. Where it refuses the same way, the readable
/// entity explains the refusal, her words stand, and the answer is what a
/// store without the hidden entity answers too; where it would let the act
/// land, the cause is hidden, and the fixed sentence speaks.
///
/// Readability through the ONE rule (`decide` at read, never consuming). ∝ the
/// note's memberships. Capacity (`readingAtCapacity`) is NOT this class: it is
/// a fact of the add-target, which the client reads (QUESTIONS #218 stands —
/// A-809-4 S-1).
extension MCPWriteTools {
    /// `add_note_to_book`'s hidden-cause sentence (P-809-2, PROVISIONAL).
    static let addHiddenCauseWords =
        "That note can't be added to this book \u{2014} something beyond your reach holds it. "
        + "The author can add it in Variorum."

    /// `move_note_to_wing`'s hidden-cause sentence (A-809-4 S-2 — the move's verb,
    /// never "finished" or "sealed": those are the hidden book's facts).
    static let moveHiddenCauseWords =
        "That note can't be moved \u{2014} something beyond your reach holds it. "
        + "The author can move it in Variorum."

    /// **The ownership consult's refusal, reach-pure** (`add_note_to_book`):
    /// the error to throw in its place — her refusal RE-KEYED to the readable
    /// claimants alone (her words stand: a readable claimant explains it, and
    /// no unreadable book's id rides the error into any host's words), or the
    /// fixed sentence (every claimant that causes it is beyond reach). nil for
    /// any other error.
    func ownershipRefusalWithinReach(
        _ error: OperationError, noteID: String, bookID: String, clientName: String
    ) throws -> Error? {
        let targetOwned: Bool
        switch error {
        case .noteMemberedElsewhere: targetOwned = true
        case .noteOwnedElsewhere: targetOwned = false
        default: return nil
        }
        let readable = try readableMemberships(noteID: noteID, excluding: bookID, clientName: clientName)
        let verdict = OwnershipDecision.verdict(
            targetOwned: targetOwned,
            note: .init(memberedElsewhere: !readable.isEmpty, ownedElsewhere: readable.contains { $0.owned }))
        switch verdict {
        case .add:
            return Refused(outcome: Outcome(text: Self.addHiddenCauseWords, isError: true))
        case .needsChoice(.copyOrMove):
            return OperationError.noteMemberedElsewhere(
                postID: noteID, readingID: bookID, elsewhere: readable.map(\.book.id))
        case .needsChoice(.copyOnly):
            return OperationError.noteOwnedElsewhere(
                postID: noteID, readingID: bookID, owner: readable.first { $0.owned }?.book.id ?? "")
        }
    }

    /// **The note's memberships in other books that this client can READ**,
    /// earliest first (`Queries.noteMemberships`' order — the op's own).
    func readableMemberships(
        noteID: String, excluding bookID: String?, clientName: String
    ) throws -> [Queries.NoteMembership] {
        try database.read { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            return try Queries.noteMemberships(db, postID: noteID, excluding: bookID).filter {
                MCPGrantAuthority.decide(standing, book: try Queries.mcpBookFacts(db, readingID: $0.book.id),
                                         rung: .read).isAllowed
            }
        }
    }
}
