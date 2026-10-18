import Foundation
import Testing
@testable import VariorumCore

/// **VX-357 — the ONE rule, pure** (`StoredText`; the run record
/// `notes/plans/fixes/vx-348-prelaunch-sweep.md`, U1 UNIT RECORD): every
/// U+0000 removed, nothing else touched; and the three Domain rules that
/// compose it (`SavepointName`, `TagPath`, `BookNaming`), so a face that
/// consults one of them agrees with what the store keeps.
@Suite("VX-357 — StoredText: U+0000 removed, nothing else changed")
struct StoredTextTests {
    @Test func everyNullCharacterIsRemovedAndNothingElse() {
        #expect(StoredText.stripped("before\u{0}after") == "beforeafter")
        #expect(StoredText.stripped("\u{0}lead, mid\u{0}dle, trail\u{0}") == "lead, middle, trail")
        #expect(StoredText.stripped("\u{0}\u{0}\u{0}") == "")
        #expect(StoredText.stripped("") == "")
        // Nothing else is touched: whitespace, newlines, other controls,
        // emoji, a decomposed é (NFD stays NFD), curly quotes.
        let untouched = "  two\nlines\t\u{1}\u{7F} \u{1F989} cafe\u{0301} \u{201C}q\u{201D}  "
        #expect(StoredText.stripped(untouched) == untouched)
        #expect(Array(StoredText.stripped(untouched).utf8) == Array(untouched.utf8), "byte for byte")
        // A null between a letter and its combining mark: the scalars around
        // it are kept exactly.
        #expect(Array(StoredText.stripped("e\u{0}\u{0301}").unicodeScalars) == ["e", "\u{0301}"])
        #expect(StoredText.stripped(nil as String?) == nil)
        #expect(StoredText.stripped("a\u{0}" as String?) == "a")
    }

    @Test func theCountIsTheNumberRemoved() {
        #expect(StoredText.nullCount("before\u{0}after") == 1)
        #expect(StoredText.nullCount("\u{0}a\u{0}\u{0}b\u{0}") == 4)
        #expect(StoredText.nullCount("none here \u{1F989}") == 0)
        #expect(StoredText.nullCount(nil as String?) == 0)
        #expect(StoredText.containsNull("x\u{0}") && !StoredText.containsNull("x"))
        for text in ["a\u{0}b", "\u{0}", "no", "\u{1F989}\u{0}\u{1F989}"] {
            #expect(text.utf8.count - StoredText.stripped(text).utf8.count == StoredText.nullCount(text),
                    "the count is exactly what the strip removes: \(text.debugDescription)")
        }
    }

    /// A text with no null character comes back as itself — the hot path
    /// (every autosave) never allocates.
    @Test func aTextWithoutANullComesBackUnchanged() {
        let prose = String(repeating: "A paragraph of prose. ", count: 2_000)
        #expect(StoredText.stripped(prose) == prose)
        #expect(!StoredText.containsNull(prose))
    }

    @Test func theRulesThatComposeItAgreeWithTheStore() {
        #expect(SavepointName.normalized("first\u{0} draft") == "first draft")
        #expect(SavepointName.normalized("\u{0}\u{0}") == nil, "a name of nothing but nulls is no name")
        #expect(TagPath.segments("topic/sub\u{0}topic") == ["topic", "subtopic"])
        #expect(TagPath.segments("a/\u{0}/b") == ["a", "b"], "a segment of nothing but a null is passed over")
        #expect(BookNaming.sameName("Field\u{0} notes", "field notes"), "a typed name collides as it will be stored")
    }
}
