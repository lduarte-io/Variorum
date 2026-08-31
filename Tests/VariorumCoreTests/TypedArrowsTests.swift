//
//  TypedArrowsTests.swift
//  VariorumCoreTests
//
//  pre-13u Act 10 wave 1, item 12 — the typed-arrow brain's rules, pinned
//  where they are decided (a pure Domain function, tested independently).
//

import Testing
@testable import VariorumCore

@Suite("Typed arrows (Act 10 item 12)")
struct TypedArrowsTests {
    @Test func rightArrowSubstitutes() {
        let line = "a -> b"
        // Caret just after the ">" (offset 4).
        let sub = TypedArrows.substitution(line: line, caret: 4)
        #expect(sub == TypedArrows.Substitution(range: 2..<4, replacement: "\u{2192}"))
    }

    @Test func leftArrowSubstitutes() {
        let line = "x <- y"
        let sub = TypedArrows.substitution(line: line, caret: 4)
        #expect(sub == TypedArrows.Substitution(range: 2..<4, replacement: "\u{2190}"))
    }

    @Test func lineStartPairSubstitutes() {
        let sub = TypedArrows.substitution(line: "->", caret: 2)
        #expect(sub == TypedArrows.Substitution(range: 0..<2, replacement: "\u{2192}"))
    }

    @Test func insideACodeSpanRefuses() {
        // `a->b` — the pair sits inside the inline-code span; arrows are
        // syntax there (the ruled guard).
        let line = "see `a->` here"
        // The ">" lands at offset 8 (caret 8 after typing it).
        #expect(TypedArrows.substitution(line: line, caret: 8) == nil)
    }

    @Test func outsideACodeSpanOnTheSameLineSubstitutes() {
        let line = "`code` then ->"
        let sub = TypedArrows.substitution(line: line, caret: 14)
        #expect(sub == TypedArrows.Substitution(range: 12..<14, replacement: "\u{2192}"))
    }

    @Test func longerDashRunsStayLiteral() {
        // `-->` — the recorded deliberate non-match.
        #expect(TypedArrows.substitution(line: "a --> b", caret: 5) == nil)
        // `<<-` mirrors.
        #expect(TypedArrows.substitution(line: "a <<- b", caret: 5) == nil)
    }

    @Test func unrelatedPairsRefuse() {
        #expect(TypedArrows.substitution(line: "a >- b", caret: 4) == nil)
        #expect(TypedArrows.substitution(line: "ab", caret: 2) == nil)
        #expect(TypedArrows.substitution(line: "->", caret: 1) == nil)
        #expect(TypedArrows.substitution(line: "", caret: 0) == nil)
    }

    @Test func caretPastTheLineRefuses() {
        #expect(TypedArrows.substitution(line: "->", caret: 9) == nil)
    }

    @Test func nonASCIIPrefixKeepsUTF16Arithmetic() {
        // "é" is one UTF-16 unit, "🙂" is two — the offsets are UTF-16
        // absolute like every MarkdownSyntax span.
        let line = "🙂é ->"
        let sub = TypedArrows.substitution(line: line, caret: 6)
        #expect(sub == TypedArrows.Substitution(range: 4..<6, replacement: "\u{2192}"))
    }
}
