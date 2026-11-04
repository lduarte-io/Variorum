import Foundation

/// **`edit_take`'s MISMATCH, SAID AS WHAT THE DOOR CAN PROVE** (VX-760 — the
/// VX-771 run, batch 2; the run record's BATCH 2 RECORD. PROVISIONAL P-771-9).
///
/// The op refuses any `expected_text` that is not the take's stored text
/// (`bufferChangedSinceGesture` — `Operations.editTakeUnderInsurance`), and the
/// app's table reads that refusal as a race with the author ("The text changed
/// while that gesture was landing…"). On the wire the common case is not a race:
/// her pending typing has already landed before the act (VX-275), so a mismatch
/// usually means the client sent part of the take, trimmed it, or sent more than
/// it. The door knows exactly two facts — the text SENT and the text STORED now —
/// and says the pattern those two prove, with both lengths, never claiming a race
/// it can't prove; where the texts genuinely diverge, the buffer-moved reading
/// stays available as a possibility.
///
/// Spoken through THE ONE CHAIN: the edit_take door throws this value and
/// `MCPWireRefusalCopy.words` speaks it first, in front of the app's table. A
/// "character" is a UTF-16 unit (the door's unit — `read_note`'s page budget);
/// every comparison is CANONICAL, as the op's precondition is (Swift `String`
/// equality), so a mismatch is never explained by a spelling the op ignores.
struct MCPExpectedTextMismatch: Error, Equatable, Sendable {
    enum Pattern: Equatable, Sendable {
        /// They differ only in whitespace at the start or the end.
        case whitespaceAtEnds
        /// The sent text is a proper prefix of the take.
        case startOfTake
        /// The sent text is a passage from inside the take.
        case passageOfTake
        /// The take's whole text lies inside the sent one, and more.
        case takeAndMore
        /// Where they first differ — a UTF-16 offset into the SENT text (the
        /// start of the first grapheme that differs, canonically).
        case differs(at: Int)
    }

    let pattern: Pattern
    /// The sent text's length, in UTF-16 units.
    let sentLength: Int
    /// The stored text's length, in UTF-16 units.
    let storedLength: Int

    /// The pattern the two texts prove; nil when they are canonically equal
    /// (then nothing differs to explain — the op's own refusal speaks).
    static func diagnose(sent: String, stored: String) -> MCPExpectedTextMismatch? {
        guard sent != stored else { return nil }
        let pattern: Pattern
        if sent.trimmingCharacters(in: .whitespacesAndNewlines)
            == stored.trimmingCharacters(in: .whitespacesAndNewlines) {
            pattern = .whitespaceAtEnds
        } else {
            // The common run, grapheme by grapheme (canonical `Character`
            // equality), and its length in the SENT text's UTF-16 units.
            var offset = 0
            var s = sent.startIndex, t = stored.startIndex
            while s < sent.endIndex, t < stored.endIndex, sent[s] == stored[t] {
                offset += sent[s].utf16.count
                s = sent.index(after: s)
                t = stored.index(after: t)
            }
            let sentDone = s == sent.endIndex, storedDone = t == stored.endIndex
            if sent.isEmpty {
                pattern = .differs(at: 0)
            } else if sentDone, !storedDone {
                pattern = .startOfTake
            } else if (storedDone && !sentDone) || (!sentDone && sent.range(of: stored) != nil) {
                pattern = .takeAndMore
            } else if stored.range(of: sent) != nil {
                pattern = .passageOfTake
            } else {
                pattern = .differs(at: offset)
            }
        }
        return MCPExpectedTextMismatch(pattern: pattern, sentLength: sent.utf16.count, storedLength: stored.utf16.count)
    }

    private var lengths: String {
        "expected_text is \(sentLength) characters, the take \(storedLength)"
    }

    /// The refusal, in the MCP room's technical register (P-13n-1).
    var words: String {
        switch pattern {
        case .whitespaceAtEnds:
            return "expected_text doesn't match the take's current text: they differ only in whitespace at the "
                + "start or end (\(lengths)). Send the take's text exactly as read_note gives it — nothing "
                + "trimmed or added. Nothing was written."
        case .startOfTake:
            return "expected_text matches only the start of the take (\(lengths)): it must be the take's WHOLE "
                + "current text, exactly as read_note gives it (with_ids: true). If you sent part of it, send "
                + "all of it — or change just that passage with old_str and new_str; if you read it earlier, it "
                + "has grown since — read it again. Nothing was written."
        case .passageOfTake:
            return "expected_text matches only a passage from inside the take (\(lengths)): it must be the "
                + "take's WHOLE current text, exactly as read_note gives it (with_ids: true). If you sent part "
                + "of it, send all of it — or change just that passage with old_str and new_str; if you read it "
                + "earlier, it has grown since — read it again. Nothing was written."
        case .takeAndMore:
            return "expected_text holds the take's whole current text and more (\(lengths)): it must be exactly "
                + "this one take's text, as read_note gives it — no other take's or block's. If you read it "
                + "earlier, it has shrunk since — read it again. Nothing was written."
        case .differs(let offset):
            return "expected_text doesn't match the take's current text: they first differ at character "
                + "\(offset) of expected_text (\(lengths); characters are UTF-16 units). If you read the take "
                + "earlier, it has changed since — the author's pending typing lands before every edit — so "
                + "read it again (read_note with with_ids: true) and send its text exactly. Nothing was written."
        }
    }
}
