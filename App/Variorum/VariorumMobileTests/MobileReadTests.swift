//
//  MobileReadTests.swift
//  VariorumMobileTests
//
//  Mobile Stage 4, batch 1 (M8/LK9) — the Read flow's pure brains: the
//  FlowParagraph-mirror transform over the ONE shared law
//  (`MarkdownRendering.render`), the LK9 chrome strings, and the page
//  assembly. Headless — the SwiftUI column composes these; the pins hold
//  the mirror to the shared law's output (the recorded drift-risk
//  discipline).
//

import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile Read page brains (S4 batch 1)")
struct MobileReadTests {
    // MARK: The paragraph transform (the FlowParagraph mirror)

    @Test func blankDisplayLinesDropAndMarkersHide() {
        let paragraphs = MobileReadPage.paragraphs(
            of: "# Title\n\nBody with **bold** words.")
        #expect(paragraphs.count == 2)
        #expect(paragraphs[0].style == .heading(level: 1))
        // Read hides the markers (the F-5 surface rule): the rendered
        // heading text carries no "# ".
        #expect(String(paragraphs[0].text.characters) == "Title")
        #expect(String(paragraphs[1].text.characters) == "Body with bold words.")
        // The bold run carries the intent.
        let bold = paragraphs[1].text.runs.contains { run in
            run.inlinePresentationIntent?.contains(.stronglyEmphasized) == true
        }
        #expect(bold)
    }

    @Test func theCodeChipHugsTheRunAndInertLinksStayPlain() {
        let tint = Color(hex: 0xF3EEE0)
        let code = MobileReadPage.paragraphs(of: "Some `code` here.", codeTint: tint)
        #expect(code.count == 1)
        let chipRun = code[0].text.runs.first { run in
            run.inlinePresentationIntent?.contains(.code) == true
        }
        #expect(chipRun != nil)
        #expect(chipRun?.backgroundColor == tint)

        // The link guard (the MarkdownLink.openable mirror): http/https
        // carry `.link`; anything else is INERT — plain text.
        let live = MobileReadPage.paragraphs(of: "[site](https://example.com)")
        #expect(live[0].text.runs.contains { $0.link != nil })
        let inert = MobileReadPage.paragraphs(of: "[disk](file:///etc/hosts)")
        #expect(!inert[0].text.runs.contains { $0.link != nil })
        #expect(MobileReadPage.openableLink("  https://example.com ") != nil)
        #expect(MobileReadPage.openableLink("file:///etc") == nil)
        #expect(MobileReadPage.openableLink("javascript:alert(1)") == nil)
        #expect(MobileReadPage.openableLink("https://") == nil)
    }

    @Test func listLinesSitInPerLevelWithTheDrawnClamp() {
        let list = MobileReadPage.paragraphs(of: "- top\n  - nested")
        #expect(list.count == 2)
        #expect(list[0].style == .bullet)
        #expect(list[0].indentLevel == 0)
        #expect(list[0].indent == 16)
        #expect(list[1].indentLevel == 1)
        #expect(list[1].indent == 32)
        // The drawn clamp (13k K8): storage depth uncapped, DRAWN indent
        // clamps — a runaway nest cannot walk off the page.
        let deep = String(repeating: "  ", count: 12) + "- deep"
        let clamped = MobileReadPage.paragraphs(of: deep)
        let maxIndent = 16 + 16 * CGFloat(MarkdownRendering.maxDrawnIndentLevel)
        #expect(clamped[0].indent == maxIndent)
    }

    @Test func headingsScaleSerifAndBodyIsThePageSerif() {
        let page = ReadingPageTokens.light
        let h1 = MobileReadPage.Paragraph(text: "", style: .heading(level: 1))
        let h3 = MobileReadPage.Paragraph(text: "", style: .heading(level: 3))
        let body = MobileReadPage.Paragraph(text: "", style: .body)
        #expect(h1.font(page) != body.font(page))
        #expect(h3.font(page) != h1.font(page))
        #expect(body.font(page) == page.serif)
    }

    // MARK: LK9's chrome strings

    @Test func romanNumeralsReadLowercase() {
        #expect(MobileReadPage.roman(1) == "i")
        #expect(MobileReadPage.roman(2) == "ii")
        #expect(MobileReadPage.roman(4) == "iv")
        #expect(MobileReadPage.roman(9) == "ix")
        #expect(MobileReadPage.roman(14) == "xiv")
        #expect(MobileReadPage.roman(40) == "xl")
        #expect(MobileReadPage.roman(0) == "")
    }

    @Test func captionAndMetaSpeakTheRatifiedFrame() {
        // The LK9 frame: "II · THE LONG FIELD" over the chapter,
        // "note 3 of 9 · ii" under the note.
        #expect(MobileReadPage.chapterCaption(index: 2, name: "The Long Field")
            == "II · THE LONG FIELD")
        // Tag-derived section PATHS show their leaf (the K3 doctrine —
        // the book list's own header rule).
        #expect(MobileReadPage.chapterCaption(index: 1, name: "books/poetry")
            == "I · POETRY")
        #expect(MobileReadPage.pageMeta(ordinal: 3, total: 9, chapterIndex: 2)
            == "note 3 of 9 · ii")
        #expect(MobileReadPage.pageMeta(ordinal: 3, total: 9, chapterIndex: nil)
            == "note 3 of 9")
    }

    @Test func theAssemblyNumbersNotesAndChaptersInBookOrder() {
        func entry(_ id: String) -> Queries.ReadingEntry {
            Queries.ReadingEntry(
                postID: id, title: id, entryDate: nil, sectionPath: nil)
        }
        let groups: [(section: String?, entries: [Queries.ReadingEntry])] = [
            (section: nil, entries: [entry("p1")]),
            (section: "Alpha", entries: [entry("p2"), entry("p3")]),
            (section: "Beta", entries: [entry("p4")]),
        ]
        let chapters = MobileReadPage.assemble(groups)
        #expect(chapters.count == 3)
        #expect(chapters[0].caption == nil)
        #expect(chapters[1].caption == "I · ALPHA")
        #expect(chapters[2].caption == "II · BETA")
        #expect(chapters.flatMap(\.notes).map(\.ordinal) == [1, 2, 3, 4])
        #expect(chapters.flatMap(\.notes).map(\.chapterIndex) == [nil, 1, 1, 2])
    }
}
