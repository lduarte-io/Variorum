//
//  NoteIndexOutline.swift
//  Variorum (Shared)
//
//  pre-13u Act 10 wave 2c, item 16 (W8-1) — **the Index mode's outline
//  brain, pure.** Her ruling made Index a mode of its own ("the book page,
//  for one note"): markdown headings become SECTIONS, every other block
//  nests under the most recent heading, and a heading-less note gets an
//  honest FLAT index — never an invented structure. This is that
//  derivation and nothing else: no storage, no view state, no AppKit.
//
//  It lives in `Shared/` deliberately: the book's index-like view (item 18)
//  and the phone's eventual index face both want exactly this grouping,
//  and a second copy would join the forked-brains KnownIssues row on the
//  day it was written.
//
//  The heading rule is F-3's letter, first-line scoped: a block whose
//  FIRST line starts `#`, `##` or `###` followed by a space is a section
//  head (`####` is plain text; a heading mark mid-block is content, not
//  structure). It deliberately re-states the lead check rather than
//  running `MarkdownRendering.render` over the whole text — an index
//  recomputes at projection cadence, and a first-line prefix check keeps
//  that cost ∝ the number of blocks, not the note's length (P1). The two
//  rules cannot drift silently: the pin suite holds them against each
//  other on the shared vocabulary.
//
//  Names and first-sentence handles stay DERIVED AT READ TIME view-side
//  (`Queries.tocHandle` — the §12 block-TOC rule); this brain never
//  stores or invents a title.
//

import Foundation

nonisolated enum NoteIndexOutline {
    /// One indexed block, in note order. `ordinal` is 1-based — the same
    /// human handle the editor's "block 3 of 11" uses, derived from
    /// current order at read time, never stored.
    struct Row: Equatable {
        let blockID: String
        let ordinal: Int
    }

    /// One section of the index: a heading block and the blocks under it.
    /// `head == nil` is the PREAMBLE group — blocks before the first
    /// heading (or the whole note, when no heading exists).
    struct Group: Equatable {
        let head: Row?
        let headingLevel: Int?
        var rows: [Row]
    }

    struct Outline: Equatable {
        let groups: [Group]

        /// A heading-less note: one head-less group — the honest flat
        /// index the ruling names.
        var isFlat: Bool { groups.count == 1 && groups[0].head == nil }

        /// Every row in note order (heads included) — the scroll-sync and
        /// selection walk read this.
        var allRows: [Row] {
            groups.flatMap { group in
                (group.head.map { [$0] } ?? []) + group.rows
            }
        }
    }

    /// The F-3 heading lead, checked against a block's FIRST line only:
    /// 1–3 `#` then a space ⇒ that heading level; anything else (`####`,
    /// no space, mid-block heads) ⇒ nil.
    static func headingLevel(of text: String?) -> Int? {
        guard let text, !text.isEmpty else { return nil }
        let firstLine = text.prefix(while: { $0 != "\n" })
        var level = 0
        var rest = firstLine[...]
        while rest.first == "#" {
            level += 1
            rest = rest.dropFirst()
        }
        guard (1...3).contains(level), rest.first == " " else { return nil }
        return level
    }

    /// A heading block's display title: the first line with its lead
    /// stripped, trimmed. Empty content ("`# ` alone is a heading with no
    /// words yet") stays empty — the VIEW decides what an unnamed section
    /// shows, this brain never invents words.
    static func headingTitle(of text: String?) -> String {
        guard let text, headingLevel(of: text) != nil else { return "" }
        let firstLine = text.prefix(while: { $0 != "\n" })
        let stripped = firstLine.drop(while: { $0 == "#" }).dropFirst()
        return stripped.trimmingCharacters(in: .whitespaces)
    }

    /// The whole derivation: blocks in note order → grouped index.
    static func outline(of blocks: [(id: String, text: String?)]) -> Outline {
        var groups: [Group] = []
        var current = Group(head: nil, headingLevel: nil, rows: [])
        var openedByHead = false
        for (i, block) in blocks.enumerated() {
            let row = Row(blockID: block.id, ordinal: i + 1)
            if let level = headingLevel(of: block.text) {
                // Close the running group. An EMPTY preamble is dropped
                // (nothing preceded the first heading); an empty SECTION
                // is kept (a heading with no kids still rows).
                if openedByHead || !current.rows.isEmpty {
                    groups.append(current)
                }
                current = Group(head: row, headingLevel: level, rows: [])
                openedByHead = true
            } else {
                current.rows.append(row)
            }
        }
        if openedByHead || !current.rows.isEmpty || groups.isEmpty {
            groups.append(current)
        }
        return Outline(groups: groups)
    }
}
