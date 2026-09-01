//
//  BookIndexColumnTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 2c — the book Index column's pure brain (item 18,
//  W8-5). The fold/filter grammar is the note Index's exactly (one grammar
//  across both indexes); the GROUPING is deliberately NOT
//  `NoteIndexOutline` — a book's chapters are real `reading_section` rows,
//  not derived headings — so what these pins hold is the flattening over
//  groups the structure model already owns.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("The book index column (pre-13u Act 10 wave 2c)")
struct BookIndexColumnTests {
    private func entry(
        _ id: String, title: String? = nil, date: String? = nil,
        path: String? = nil
    ) -> Queries.ReadingEntry {
        Queries.ReadingEntry(
            postID: id, title: title, entryDate: date, sectionPath: path)
    }

    private func section(_ id: String, _ name: String) -> ReadingSection {
        ReadingSection(
            id: id, readingId: "book", name: name, position: id,
            createdAt: Date(timeIntervalSince1970: 0),
            updatedAt: Date(timeIntervalSince1970: 0))
    }

    // MARK: Grouping

    @Test func chaptersBecomeFoldableGroupsAndUnfiledTrails() {
        let groups = BookIndexColumn.groups(chapters: [
            (section("s1", "One"), [entry("a"), entry("b")]),
            (section("s2", "Two"), [entry("c")]),
            (nil, [entry("d")]),
        ])
        #expect(groups.map(\.id) == ["s1", "s2", "unfiled"])
        #expect(groups.map(\.title) == ["One", "Two", "unfiled"])
        #expect(groups[0].entries.map(\.postID) == ["a", "b"])
    }

    @Test func tagPathRunsGroupAndAHeadinglessBookReadsFlat() {
        let runs = BookIndexColumn.groups(flat: [
            entry("a", path: "life"), entry("b", path: "life"),
            entry("c"), entry("d", path: "life"),
        ])
        #expect(runs.map(\.title) == ["life", nil, "life"])
        #expect(runs[0].entries.count == 2)
        // Recurring paths keep distinct ids (X · unsectioned · X).
        #expect(runs[0].id != runs[2].id)

        let flat = BookIndexColumn.groups(flat: [entry("a"), entry("b")])
        #expect(flat.count == 1)
        #expect(flat[0].title == nil, "no headings ⇒ honestly flat, nothing to fold")
    }

    // MARK: Fold + filter (the note Index's grammar)

    @Test func foldingHidesMembersAndTheChapterRowSaysSo() {
        let groups = BookIndexColumn.groups(chapters: [
            (section("s1", "One"), [entry("a"), entry("b")]),
        ])
        let open = BookIndexColumn.rows(groups: groups, collapsed: [], filter: "")
        #expect(open.count == 3)
        let folded = BookIndexColumn.rows(groups: groups, collapsed: ["s1"], filter: "")
        #expect(folded.count == 1)
        guard case let .chapter(_, count, isFolded) = folded[0].kind else {
            Issue.record("expected the chapter row"); return
        }
        #expect(count == 2, "the folded heading still says what it holds")
        #expect(isFolded)
    }

    @Test func theFilterKeepsMatchingNotesUnderTheirChapter() {
        let groups = BookIndexColumn.groups(chapters: [
            (section("s1", "Adventures"), [
                entry("a", title: "A Scandal in Bohemia"),
                entry("b", title: "The Red-Headed League"),
            ]),
            (section("s2", "Memoirs"), [entry("c", title: "Silver Blaze")]),
        ])
        let rows = BookIndexColumn.rows(
            groups: groups, collapsed: [], filter: "scandal")
        #expect(rows.count == 2, "the chapter heading + its one matching note")
        guard case let .note(hit, _) = rows[1].kind else {
            Issue.record("expected the matching note"); return
        }
        #expect(hit.postID == "a")

        // A matching CHAPTER title keeps all its notes.
        let byChapter = BookIndexColumn.rows(
            groups: groups, collapsed: [], filter: "memoirs")
        #expect(byChapter.count == 2)
    }

    @Test func aDateAnswersTheFilterWhereATitleIsAbsent() {
        // Journal-shaped books: the entry date is the identity, so the
        // filter must reach it (the display-title rule's own fallback).
        let groups = BookIndexColumn.groups(flat: [
            entry("a", date: "2026-08-31"), entry("b", date: "2026-07-01"),
        ])
        let rows = BookIndexColumn.rows(
            groups: groups, collapsed: [], filter: "2026-08")
        #expect(rows.count == 1)
    }
}
