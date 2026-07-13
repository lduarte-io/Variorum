//
//  DiffViewTests.swift
//  VariorumTests
//
//  Phase 11, Step A4 — the line diff's pure-function pins (the plan's
//  answered interpretation 2: LINE-based over the rendered texts; the
//  whitespace toggle per §12). The view writes nothing — the I3 pin for
//  viewing rides TakesBoardTests' walk.
//

import Testing
@testable import Variorum

@Suite("Line diff (Phase 11, A4)")
struct DiffViewTests {
    @Test func identicalTextsDiffToAllSame() {
        let lines = LineDiff.compute(a: "one\ntwo", b: "one\ntwo", normalizeWhitespace: false)
        #expect(lines.map(\.kind) == [.same, .same])
        #expect(lines.map(\.text) == ["one", "two"])
    }

    @Test func insertionsDeletionsAndChangesMarkCorrectly() {
        let a = "alpha\nbeta\ngamma"
        let b = "alpha\nBETA\ngamma\ndelta"
        let lines = LineDiff.compute(a: a, b: b, normalizeWhitespace: false)
        #expect(lines.map(\.kind) == [.same, .removed, .added, .same, .added])
        #expect(lines[1].text == "beta")
        #expect(lines[2].text == "BETA")
        #expect(lines[4].text == "delta")
    }

    @Test func whitespaceToggleNormalizesComparisonNeverDisplay() {
        let a = "the  quick   fox"
        let b = "the quick fox"
        let strict = LineDiff.compute(a: a, b: b, normalizeWhitespace: false)
        #expect(strict.map(\.kind).contains(.removed) && strict.map(\.kind).contains(.added),
                "strict mode sees the whitespace difference")
        let relaxed = LineDiff.compute(a: a, b: b, normalizeWhitespace: true)
        #expect(relaxed.map(\.kind) == [.same])
        #expect(relaxed[0].text == "the  quick   fox",
                "the DISPLAYED line stays verbatim — normalization is comparison-only")
    }

    @Test func emptySidesDiffHonestly() {
        #expect(LineDiff.compute(a: "", b: "", normalizeWhitespace: false).map(\.kind) == [.same])
        let added = LineDiff.compute(a: "", b: "x\ny", normalizeWhitespace: false)
        #expect(added.map(\.kind).filter { $0 == .added }.count == 2)
    }

    @Test func storedTrailingNewlinesAreBytesInStrictMode() {
        // The 2026-07-12 ruling's content newlines are real bytes: a spaced
        // block diffs against its unspaced twin unless whitespace is
        // ignored.
        let lines = LineDiff.compute(a: "para\n", b: "para", normalizeWhitespace: false)
        #expect(lines.map(\.kind) != [.same, .same])
        // The toggle normalizes WITHIN lines; line structure (a stored
        // blank line) stays an honest difference either way.
        let relaxed = LineDiff.compute(a: "para\n", b: "para", normalizeWhitespace: true)
        #expect(relaxed.map(\.kind) == [.same, .removed])
    }
}
