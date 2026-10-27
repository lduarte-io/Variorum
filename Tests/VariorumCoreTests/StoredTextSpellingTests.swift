import Foundation
import Testing
@testable import VariorumCore

/// **VX-358 — the same words in another spelling, pure** (`StoredText.spellingDiffers`;
/// the run record `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`, BATCH 2a
/// RECORD, PROVISIONAL MB-5): true exactly when two texts are equal under Swift's
/// canonical `String ==` (the no-op guards' rule) and their UTF-8 bytes differ — the
/// one case where a no-op's stored bytes (and the wire's digest of them) cannot match
/// the bytes asked. The op-level answers are pinned on the wire
/// (`MCPSpellingNoOpServerTests`).
@Suite("VX-358 — StoredText: canonically equal, spelled otherwise")
struct StoredTextSpellingTests {
    @Test func theTable() {
        // Canonically equal, byte-different → true (both directions).
        #expect(StoredText.spellingDiffers("caf\u{00E9}", from: "cafe\u{0301}"), "NFC asked, NFD stored")
        #expect(StoredText.spellingDiffers("cafe\u{0301}", from: "caf\u{00E9}"), "NFD asked, NFC stored")
        // Other canonical equivalents: a singleton (Å the Ångström sign vs Å),
        // Hangul syllable vs its jamo, combining marks in another order.
        #expect(StoredText.spellingDiffers("\u{212B}", from: "\u{00C5}"), "the Ångström sign is Å")
        #expect(StoredText.spellingDiffers("\u{AC00}", from: "\u{1100}\u{1161}"), "가 composed vs jamo")
        #expect(StoredText.spellingDiffers("a\u{0301}\u{0316}", from: "a\u{0316}\u{0301}"),
                "marks of different classes in either order")
        // Byte-identical → false (the ordinary no-op).
        #expect(!StoredText.spellingDiffers("caf\u{00E9}", from: "caf\u{00E9}"))
        #expect(!StoredText.spellingDiffers("", from: ""))
        #expect(!StoredText.spellingDiffers("\u{1F989} an owl", from: "\u{1F989} an owl"))
        // Different words → false (not a no-op at all — the write lands).
        #expect(!StoredText.spellingDiffers("cafe", from: "caf\u{00E9}"), "e is not é")
        #expect(!StoredText.spellingDiffers("Caf\u{00E9}", from: "caf\u{00E9}"), "case is meaning")
        #expect(!StoredText.spellingDiffers("caf\u{00E9} ", from: "caf\u{00E9}"), "a trailing space is meaning")
        // Compatibility forms are NOT canonical equivalents: ﬁ is not "fi".
        #expect(!StoredText.spellingDiffers("\u{FB01}", from: "fi"), "a ligature is a different text")
    }
}
