import Foundation
import Testing
@testable import VariorumCore

/// **VX-801 (VX-827 U3a) — the view-time word compare** the block's History
/// surface washes with ("plain · against now") and Compare reads.
///
/// A PRODUCT row (a new pure function): the suite does not compile on the
/// pre-change tree, which is the honest red of an absent capability. What it
/// holds is the contract `TextCompare`'s doc states: words, not characters;
/// a space between two replacements absorbed into ONE change; paragraph
/// breaks never absorbed; both texts kept byte for byte by every run family;
/// and a bounded search that answers coarsely, never hangs (P1).
@Suite("TextCompare — the view-time word compare (VX-801)")
struct TextCompareTests {
    /// Her reference (the exploration sitting's composite): "before
    /// claude-code's edit" against the take now — FOUR changes.
    static let before = """
        A book read once is a rumor; read twice, it slowly becomes a place. The corners you missed \
        the first time hold the whole furniture of the argument, and you only notice them because \
        you already know the room.

        That is why the books that matter wear out their spines unevenly: the same forty pages, \
        returned to, until the glue gives. Nobody really teaches this.
        """
    static let after = """
        A book read once is a rumor; read twice, it starts to become a place. The corners you missed \
        the first time hold the furniture of the argument, and you only see them because you already \
        know the room.

        That is why the books that matter wear out their spines unevenly: the same forty pages, \
        returned to, until the glue gives. Nobody teaches this.
        """

    /// Every run family gives its text back exactly.
    static func expectKeepsBothTexts(
        _ c: TextCompare.Comparison, _ old: String, _ new: String,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(c.old.map(\.text).joined() == old, "the old side's runs are the old text",
                sourceLocation: sourceLocation)
        #expect(c.new.map(\.text).joined() == new, "the new side's runs are the new text",
                sourceLocation: sourceLocation)
        #expect(c.unified.filter { $0.kind != .added }.map(\.text).joined() == old,
                sourceLocation: sourceLocation)
        #expect(c.unified.filter { $0.kind != .removed }.map(\.text).joined() == new,
                sourceLocation: sourceLocation)
        #expect(c.old.allSatisfy { $0.kind != .added }, sourceLocation: sourceLocation)
        #expect(c.new.allSatisfy { $0.kind != .removed }, sourceLocation: sourceLocation)
        #expect(c.old.allSatisfy { !$0.text.isEmpty } && c.new.allSatisfy { !$0.text.isEmpty },
                "no empty runs", sourceLocation: sourceLocation)
    }

    @Test func identicalTextsAreOneSameRunAndNoChange() {
        let c = TextCompare.compare("A quiet line.", "A quiet line.")
        #expect(c.changeCount == 0)
        #expect(c.isIdentical)
        #expect(c.unified == [.init(.same, "A quiet line.")])
        Self.expectKeepsBothTexts(c, "A quiet line.", "A quiet line.")
    }

    @Test func twoEmptyTextsHaveNoRunsAndNoChange() {
        let c = TextCompare.compare("", "")
        #expect(c.changeCount == 0)
        #expect(c.old.isEmpty && c.new.isEmpty && c.unified.isEmpty)
    }

    @Test func anEmptyMomentAgainstWordsIsOneAddition() {
        let c = TextCompare.compare("", "Now there are words.")
        #expect(c.changeCount == 1)
        #expect(c.unified == [.init(.added, "Now there are words.")])
        #expect(c.old.isEmpty)
        Self.expectKeepsBothTexts(c, "", "Now there are words.")
    }

    @Test func wordsAgainstAnEmptyTakeAreOneRemoval() {
        let c = TextCompare.compare("All of it went.", "")
        #expect(c.changeCount == 1)
        #expect(c.unified == [.init(.removed, "All of it went.")])
        Self.expectKeepsBothTexts(c, "All of it went.", "")
    }

    /// The reference: four changes, each one a reader's change — the
    /// replacement "slowly becomes" → "starts to become" is ONE struck phrase
    /// beside ONE washed phrase (the space between absorbed), never fragments.
    @Test func herReferenceEditReadsAsFourChanges() {
        let c = TextCompare.compare(Self.before, Self.after)
        #expect(c.changeCount == 4)
        Self.expectKeepsBothTexts(c, Self.before, Self.after)
        let removed = c.unified.filter { $0.kind == .removed }.map {
            $0.text.trimmingCharacters(in: .whitespaces)
        }
        let added = c.unified.filter { $0.kind == .added }.map {
            $0.text.trimmingCharacters(in: .whitespaces)
        }
        #expect(removed == ["slowly becomes", "whole", "notice", "really"])
        #expect(added == ["starts to become", "see"])
        // The phrase's removal comes first, its addition right after.
        let slowly = c.unified.firstIndex {
            $0.kind == .removed && $0.text.trimmingCharacters(in: .whitespaces) == "slowly becomes"
        }
        #expect(slowly.map { c.unified[$0 + 1].kind } == .added)
        #expect(slowly.map { c.unified[$0 + 1].text.trimmingCharacters(in: .whitespaces) }
                == "starts to become")
    }

    @Test func aReplacementInsideOneWordIsOneChange() {
        let c = TextCompare.compare("you only notice them", "you only see them")
        #expect(c.changeCount == 1)
        #expect(c.unified == [
            .init(.same, "you only "), .init(.removed, "notice"), .init(.added, "see"),
            .init(.same, " them"),
        ])
    }

    @Test func aParagraphBreakIsNeverAbsorbed() {
        let c = TextCompare.compare("alpha\n\nbeta", "gamma\n\ndelta")
        #expect(c.changeCount == 2, "two paragraphs' changes stay two")
        #expect(c.unified.contains(.init(.same, "\n\n")))
        Self.expectKeepsBothTexts(c, "alpha\n\nbeta", "gamma\n\ndelta")
    }

    /// A lone insertion and a lone removal around a kept space are two
    /// changes, and the kept space is never struck or washed.
    @Test func aSpaceBesideALoneInsertionStaysPlain() {
        let c = TextCompare.compare("keep this here", "keep all this")
        Self.expectKeepsBothTexts(c, "keep this here", "keep all this")
        #expect(c.unified.filter { $0.kind != .same }.allSatisfy {
            !$0.text.trimmingCharacters(in: .whitespaces).isEmpty
        }, "no run of a change is only space")
    }

    @Test func anApostropheInsideAWordBelongsToIt() {
        #expect(TextCompare.tokens("don't go") == ["don't", " ", "go"])
        #expect(TextCompare.tokens("the author\u{2019}s") == ["the", " ", "author\u{2019}s"])
        #expect(TextCompare.tokens("'quoted'") == ["'", "quoted", "'"])
        let c = TextCompare.compare("don't go", "don't stay")
        #expect(c.unified == [.init(.same, "don't "), .init(.removed, "go"), .init(.added, "stay")])
    }

    @Test func theTokensGiveTheTextBack() {
        for text in [Self.before, "émigré naïve café", "日本語の文章です。", "🙂 two 👩🏽‍💻 emoji", "a\tb\n c", ""] {
            #expect(TextCompare.tokens(text).joined() == text)
        }
    }

    @Test func caseIsAChange() {
        #expect(TextCompare.compare("The room", "the room").changeCount == 1)
    }

    @Test func graphemesAreNeverSplit() {
        let old = "a 👩🏽‍💻 b"
        let new = "a 👩🏻‍💻 b"
        let c = TextCompare.compare(old, new)
        #expect(c.changeCount == 1)
        Self.expectKeepsBothTexts(c, old, new)
        #expect(c.unified.contains(.init(.removed, "👩🏽‍💻")))
        #expect(c.unified.contains(.init(.added, "👩🏻‍💻")))
    }

    /// The bounded search (P1): past `editBudget` token edits the differing
    /// middle is ONE change — coarse and true, never a hang — and the common
    /// prefix and suffix still read as same.
    @Test func pastTheBudgetTheMiddleIsOneChange() {
        let old = "Start. " + (0..<60).map { "old\($0)" }.joined(separator: " ") + " End."
        let new = "Start. " + (0..<60).map { "new\($0)" }.joined(separator: " ") + " End."
        let coarse = TextCompare.compare(old, new, editBudget: 10)
        #expect(coarse.changeCount == 1)
        Self.expectKeepsBothTexts(coarse, old, new)
        #expect(coarse.unified.first == .init(.same, "Start. "))
        #expect(coarse.unified.last == .init(.same, " End."))
        // Inside the budget the same pair is answered word by word.
        let fine = TextCompare.compare(old, new)
        Self.expectKeepsBothTexts(fine, old, new)
        #expect(fine.changeCount >= 1)
    }

    /// The search's cost is bounded by the budget, not by the texts: a large
    /// wholesale rewrite returns (coarsely) at the default budget.
    @Test func aWholesaleRewriteOfALongBlockReturns() {
        let old = (0..<4_000).map { "w\($0)" }.joined(separator: " ")
        let new = (0..<4_000).map { "v\($0)" }.joined(separator: " ")
        let c = TextCompare.compare(old, new)
        Self.expectKeepsBothTexts(c, old, new)
        #expect(c.changeCount == 1)
    }

    @Test func myersFindsTheShortestScript() throws {
        let ops = try #require(TextCompare.myers([1, 2, 3, 4], [1, 3, 4, 5], budget: 10))
        #expect(ops.filter { if case .equal = $0 { return false }; return true }.count == 2,
                "one delete and one insert")
        #expect(TextCompare.myers([1, 2, 3], [4, 5, 6], budget: 2) == nil, "past the budget")
        #expect(TextCompare.myers([], [7], budget: 0) == [.insert(0)])
    }

    /// Many small edits across a paragraph keep both texts and count each
    /// separated change once.
    @Test func scatteredEditsKeepBothTexts() {
        let old = "One two three four five six seven eight nine ten."
        let new = "One 2 three four FIVE six seven eight nine ten!"
        let c = TextCompare.compare(old, new)
        Self.expectKeepsBothTexts(c, old, new)
        #expect(c.changeCount == 3)
    }
}
