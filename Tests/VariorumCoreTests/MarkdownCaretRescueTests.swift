import Foundation
import Testing
@testable import VariorumCore

/// VX-296 — the caret-aware reading (her ruling: fix (a), "your fix is
/// good" — caret-aware in the LIVE EDITOR only). The pure halves: the
/// parser's rescue (`MarkdownSyntax.spans(in:caret:)`), its O(1) gate and the
/// live surface's ledger (`MarkdownCaretRescue`). The live-editor pins that
/// type through the real edit road are the Mac target's
/// (`MarkdownCaretFaceTests`) and the phone's.
///
/// These are NEW-API pins (the `caret:` argument does not exist on the old
/// tree), so they cannot be red on old; the bug's red-on-old pins are the
/// live-editor ones. What these pin is the rule's letter and — the part the
/// ruling insists on — that the caret-BLIND reading every other reader gets
/// is exactly today's.

private func slice(_ text: String, _ range: Range<Int>) -> String {
    (text as NSString).substring(with: NSRange(location: range.lowerBound, length: range.count))
}

private func kinds(_ text: String, caret: Int? = nil) -> [MarkdownSyntax.Kind] {
    MarkdownSyntax.spans(in: text, caret: caret).map(\.kind)
}

/// Every UTF-16 caret position a writer could stand at, ends included.
private func carets(_ text: String) -> ClosedRange<Int> {
    0...(text as NSString).length
}

@Suite("VX-296 — the caret-aware markdown reading (the parser's rescue, its gate, the ledger)")
struct MarkdownCaretRescueTests {

    // MARK: - The rule (her pin: `*hello |*`, caret at `|`, is italic)

    @Test func herFlowAClosingStarAtTheCaretStillCloses() throws {
        let text = "*hello *"  // she typed the space; the caret sits before the star
        let caret = 7
        let rescued = MarkdownSyntax.spans(in: text, caret: caret)
        try #require(rescued.count == 1)
        #expect(rescued[0].kind == .italic)
        #expect(rescued[0].markers == [0..<1, 7..<8])
        #expect(slice(text, rescued[0].content) == "hello ", "the space she just typed is inside the italic")

        // Caret-blind — every reader that is not her live editor — exactly
        // as before: the closer is refused, the span is gone.
        #expect(kinds(text).isEmpty)
        // And with the caret anywhere else, the caret changes nothing.
        for other in carets(text) where other != caret {
            #expect(kinds(text, caret: other).isEmpty, "caret at \(other)")
        }
    }

    @Test func theNextLetterReadsTheSameWithOrWithoutTheCaret() {
        // `*hello w|*` — the flip back she sees today. With the rescue, the
        // reading at the space and at the letter agree, so nothing flips.
        let text = "*hello w*"
        #expect(kinds(text) == [.italic])
        for caret in carets(text) {
            #expect(kinds(text, caret: caret) == [.italic], "caret at \(caret)")
        }
    }

    @Test func everyCloserOfTheFlankingFamilyYieldsToTheCaret() throws {
        // P-U2-2 (PROVISIONAL): the closer half is ONE rule over `*`, `**`,
        // `~~` — and `_`, which shares it — so ⌘B's pair stops flickering
        // the same way ⌘I's does.
        // ⌘B's pair at a word boundary reads WRONG caret-blind today — not
        // plain but an italic over `hello *` (the bold fails, the scan steps
        // one star in, and the last star closes an italic) — so the bold
        // flicker is bold → italic → bold.
        let bold = "**hello **"
        #expect(kinds(bold) == [.italic])
        #expect(kinds(bold, caret: 8) == [.bold])
        #expect(MarkdownSyntax.spans(in: bold, caret: 8)[0].markers == [0..<2, 8..<10])

        let struck = "~~gone ~~"
        #expect(kinds(struck).isEmpty)
        #expect(kinds(struck, caret: 7) == [.strikethrough])

        let under = "_so _"
        #expect(kinds(under).isEmpty)
        #expect(kinds(under, caret: 4) == [.italic])
        // The underscore's OTHER tests hold at the caret too: a closer glued
        // to a following word is still not a closer.
        #expect(kinds("_so _x", caret: 4).isEmpty)
    }

    @Test func theOpenerHalfNeverYieldsToTheCaret() {
        // P-U2-1 (PROVISIONAL — closer only, as ruled): whitespace AFTER an
        // opener still refuses it, wherever the caret is.
        let text = "* hello*"
        for caret in carets(text) {
            #expect(kinds(text, caret: caret).isEmpty, "caret at \(caret)")
        }
    }

    @Test func aCaretRescuesNothingWithoutAnOpener() {
        #expect(kinds("hello *", caret: 6).isEmpty)
        #expect(kinds("hello **", caret: 6).isEmpty)
    }

    // MARK: - Arithmetic stays arithmetic at EVERY caret position

    @Test func arithmeticIsPlainAtEveryCaretPosition() {
        for text in ["2 * 3 * 4", "2 ** 3 ** 4", "a ~~ b ~~ c", "2 _ 3 _ 4", "x * y", "* *",
                     "**bold** and 2 * 3 * 4"] {
            let blind = kinds(text)
            for caret in carets(text) {
                #expect(kinds(text, caret: caret) == blind, "\(text) — caret at \(caret)")
            }
        }
        #expect(kinds("2 * 3 * 4").isEmpty)
        #expect(kinds("**bold** and 2 * 3 * 4") == [.bold])
    }

    // MARK: - The caret-blind reading is today's, byte for byte

    @Test func noCaretReadsExactlyAsBefore() {
        // `*foo *bar*` — the ticket's own example: without a caret it reads
        // as it always has (one italic over `foo *bar`).
        let text = "*foo *bar*"
        let blind = MarkdownSyntax.spans(in: text)
        #expect(blind.map(\.kind) == [.italic])
        #expect(slice(text, blind[0].content) == "foo *bar")
        #expect(MarkdownSyntax.spans(in: text, caret: nil) == blind)
        // With the caret right before the inner star the live reading is the
        // one she is typing toward — recorded so the difference is a fact,
        // not a surprise.
        #expect(slice(text, MarkdownSyntax.spans(in: text, caret: 5)[0].content) == "foo ")
    }

    /// THE GATE'S SOUNDNESS: wherever `point(in:selection:)` says a caret
    /// cannot matter, the caret-aware reading IS the caret-blind one — so a
    /// surface that restyles honouring the caret only where the gate answers
    /// can never miss a rescue. Exhaustive over a corpus × every caret.
    @Test func whereTheGateSaysNoTheCaretChangesNothing() {
        let corpus = [
            "*hello *", "*hello w*", "**hello **", "~~gone ~~", "_so _", "* hello*",
            "2 * 3 * 4", "*foo *bar*", "a *b * c*", "*a **b** c*", "say **this** and `that`",
            "# A *Big * title", "- [ ] a *task *", "[link *](u) *x *", "*a \u{301}*",
            "\u{1F600} *e \u{1F600} *", "line one *a \nline *two *", "`*a *`", "_a_b _",
        ]
        for text in corpus {
            let ns = text as NSString
            let blind = MarkdownSyntax.spans(in: text)
            for caret in carets(text) {
                let gate = MarkdownCaretRescue.point(
                    in: ns, selection: NSRange(location: caret, length: 0))
                let aware = MarkdownSyntax.spans(in: text, caret: caret)
                if gate == nil {
                    #expect(aware == blind, "\(text.debugDescription) — caret at \(caret)")
                } else {
                    #expect(gate == caret)
                }
            }
        }
    }

    @Test func theGateReadsGraphemesTheWayTheParserDoes() throws {
        // A space carrying a combining mark is whitespace to the parser (its
        // first scalar decides); the gate agrees, and the rescue happens.
        let text = "*a \u{301}*"
        let star = (text as NSString).length - 1
        #expect(MarkdownCaretRescue.point(
            in: text as NSString, selection: NSRange(location: star, length: 0)) == star)
        #expect(kinds(text, caret: star) == [.italic])
        // A caret inside a surrogate pair names no grapheme start: no rescue
        // (the star at 6 is refused as ever), while the caret AT the star
        // rescues it.
        let emoji = "*e \u{1F600} *"
        #expect(MarkdownCaretRescue.point(
            in: emoji as NSString, selection: NSRange(location: 4, length: 0)) == nil)
        #expect(kinds(emoji, caret: 4).isEmpty)
        #expect(kinds(emoji, caret: 6) == [.italic])
    }

    @Test func theGateAnswersOnlyAnInsertionPointBetweenSpaceAndMarker() {
        let text = "*hello *" as NSString
        #expect(MarkdownCaretRescue.point(in: text, selection: NSRange(location: 7, length: 0)) == 7)
        #expect(MarkdownCaretRescue.point(in: text, selection: NSRange(location: 7, length: 1)) == nil,
                "a selection is not typing")
        #expect(MarkdownCaretRescue.point(in: text, selection: NSRange(location: 6, length: 0)) == nil)
        #expect(MarkdownCaretRescue.point(in: text, selection: NSRange(location: 8, length: 0)) == nil)
        #expect(MarkdownCaretRescue.point(in: text, selection: NSRange(location: NSNotFound, length: 0)) == nil)
        #expect(MarkdownCaretRescue.point(
            in: "a\n*" as NSString, selection: NSRange(location: 2, length: 0)) == nil,
                "a newline before the marker puts it at a line's start")
    }

    @Test func theScanCostIsTheLineHandedIn() {
        // P1: the caret adds no scan — the reading walks exactly what it was
        // handed, as the caret-blind one does.
        let text = "*hello *"
        MarkdownScanCount.reset()
        _ = MarkdownSyntax.spans(in: text, caret: 7)
        #expect(MarkdownScanCount.current == (text as NSString).length)
    }

    // MARK: - The ledger (the live surface's bookkeeping)

    /// Her flow, as a surface lives it: each keystroke is an edit (its own
    /// restyle caret-blind), then the caret settles.
    @Test func theLedgerFollowsHerTypingFlow() {
        var ledger = MarkdownCaretRescue.Ledger()
        // `*hello|*` — typing `o` landed; the caret settles after a letter.
        ledger.noteEdit(replacing: NSRange(location: 5, length: 0), newLength: 1)
        #expect(ledger.settle(selection: NSRange(location: 6, length: 0), in: "*hello*") == nil)

        // The space: `*hello |*` — the caret settles at a rescue point.
        ledger.noteEdit(replacing: NSRange(location: 6, length: 0), newLength: 1)
        #expect(ledger.settle(selection: NSRange(location: 7, length: 0), in: "*hello *")
            == .init(clear: nil, honour: 7))
        #expect(ledger.honoured == 7)

        // `w`: `*hello w|*` — the honoured run moved right with the letter,
        // and its line (already caret-blind from the keystroke) is cleared
        // once more — the over-claim's price, one line.
        ledger.noteEdit(replacing: NSRange(location: 7, length: 0), newLength: 1)
        #expect(ledger.honoured == 8)
        #expect(ledger.settle(selection: NSRange(location: 8, length: 0), in: "*hello w*")
            == .init(clear: 8, honour: nil))
        #expect(ledger.honoured == nil)
    }

    @Test func aCaretThatLeavesARescueUnstylesItsLine() {
        var ledger = MarkdownCaretRescue.Ledger()
        let text = "*hello *\nnext line" as NSString
        #expect(ledger.settle(selection: NSRange(location: 7, length: 0), in: text)
            == .init(clear: nil, honour: 7))
        // Arrow right, past the star: the trailing space is left behind.
        #expect(ledger.settle(selection: NSRange(location: 8, length: 0), in: text)
            == .init(clear: 7, honour: nil))
        // Back to the rescue point, then a click on the next line.
        _ = ledger.settle(selection: NSRange(location: 7, length: 0), in: text)
        #expect(ledger.settle(selection: NSRange(location: 12, length: 0), in: text)
            == .init(clear: 7, honour: nil))
        // A caret that neither sits at nor leaves a rescue point costs nothing.
        #expect(ledger.settle(selection: NSRange(location: 14, length: 0), in: text) == nil)
        #expect(ledger.settle(selection: NSRange(location: 2, length: 0), in: text) == nil)
    }

    @Test func theSurfaceGoingReadClearsItsHonour() {
        var ledger = MarkdownCaretRescue.Ledger()
        _ = ledger.settle(selection: NSRange(location: 7, length: 0), in: "*hello *")
        #expect(ledger.settle(selection: nil, in: "*hello *") == .init(clear: 7, honour: nil))
        #expect(ledger.settle(selection: nil, in: "*hello *") == nil)
    }

    @Test func oneLineIsRestyledOnceWhenTheCaretMovesWithinIt() {
        var ledger = MarkdownCaretRescue.Ledger()
        let text = "*a * and *b *" as NSString
        _ = ledger.settle(selection: NSRange(location: 3, length: 0), in: text)
        #expect(ledger.settle(selection: NSRange(location: 12, length: 0), in: text)
            == .init(clear: nil, honour: 12), "the honour pass covers the line it leaves")
    }

    /// The coincidence an offset comparison alone would miss: the caret
    /// settles on the SAME offset it was honoured at, but an edit re-derived
    /// the line caret-blind in between (a backspace among two spaces before
    /// the star). The edit mark makes the settle re-honour.
    @Test func anEditAtTheSameOffsetStillReHonours() {
        var ledger = MarkdownCaretRescue.Ledger()
        // `*a  |*` — honoured at 4.
        _ = ledger.settle(selection: NSRange(location: 4, length: 0), in: "*a  *")
        // ⌫: [3, 4) removed → `*a |*`, the caret at 3, the claim shifted to 3.
        ledger.noteEdit(replacing: NSRange(location: 3, length: 1), newLength: 0)
        #expect(ledger.honoured == 3)
        #expect(ledger.settle(selection: NSRange(location: 3, length: 0), in: "*a *")
            == .init(clear: nil, honour: 3))
    }

    @Test func editsElsewhereKeepTheClaimOnItsRun() {
        let text: NSString = "first\nsecond *x *"  // the rescue point: 16
        var ledger = MarkdownCaretRescue.Ledger()
        #expect(ledger.settle(selection: NSRange(location: 16, length: 0), in: text)
            == .init(clear: nil, honour: 16))
        // An edit on an EARLIER line (a sync landing, a structural rewrite):
        // the run moved, the claim moves with it.
        ledger.noteEdit(replacing: NSRange(location: 0, length: 5), newLength: 2)
        #expect(ledger.honoured == 13)
        // An edit AFTER the claim leaves it where it is.
        ledger.noteEdit(replacing: NSRange(location: 20, length: 0), newLength: 3)
        #expect(ledger.honoured == 13)
        // An edit that swallows the claimed run moves the claim to the edit's
        // start — a line the edit's own restyle covered (an over-claim).
        ledger.noteEdit(replacing: NSRange(location: 10, length: 8), newLength: 1)
        #expect(ledger.honoured == 10)
        // A report widened by attribute fixing (the same run added to both
        // lengths) shifts a later claim exactly as the narrow report would.
        var wide = MarkdownCaretRescue.Ledger()
        var narrow = MarkdownCaretRescue.Ledger()
        _ = wide.settle(selection: NSRange(location: 16, length: 0), in: text)
        _ = narrow.settle(selection: NSRange(location: 16, length: 0), in: text)
        wide.noteEdit(replacing: NSRange(location: 2, length: 4), newLength: 5)
        narrow.noteEdit(replacing: NSRange(location: 2, length: 0), newLength: 1)
        #expect(wide.honoured == narrow.honoured)
        #expect(wide.honoured == 17)
    }
}
