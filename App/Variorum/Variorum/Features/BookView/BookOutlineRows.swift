//
//  BookOutlineRows.swift
//  Variorum
//
//  The Act 10 correction round, batch B (rows 9/12/14/44/47) — Outline's
//  rows, FLATTENED: one lazy item per chapter heading, unfiled heading,
//  tag-path heading and note, each carrying the anchor id the page lands
//  on. Pure, so the flattening is pinned rather than observed.
//
//  Why flat: `ScrollViewProxy.scrollTo` reaches an UNREALIZED row of a
//  `LazyVStack` only through the row's own `ForEach` identity — an explicit
//  `.id` on a view that has not been built yet is unknown to the reader
//  (measured in this round's harness: a reveal of an off-screen card moved
//  nothing; the same reveal by the ForEach identity landed). With nested
//  `ForEach`es (groups, then entries) the chapter heading's identity was an
//  `Optional<String>` group id shared with its entries' container, and the
//  card's `page-<id>` anchor lived INSIDE the row. One flat list makes every
//  landing target a first-class lazy identity — the grouping itself is
//  still `BookStructureModel.grouped` (chapters) and `sectionHeader(at:)`'s
//  rule (tag paths); nothing here re-decides an order.
//

import Foundation
import VariorumCore

nonisolated enum BookOutlineRows {
    enum Row: Identifiable, Equatable {
        /// A real chapter heading (curated books with live sections).
        case chapter(ReadingSection)
        /// The trailing "unfiled" heading (ratified: strays trail).
        case unfiledHeading
        /// A smart book's tag-path heading (`grouping_tag_id` sectioning).
        case tagHeading(path: String, ordinal: Int)
        /// One note's row — a card, or the expanded note.
        case note(Queries.ReadingEntry)

        /// The landing anchor — what `scrollTo` targets and what the
        /// geometry oracle reports under.
        var id: String {
            switch self {
            case .chapter(let section): Self.chapterAnchor(section.id)
            case .unfiledHeading: "unfiled"
            case .tagHeading(_, let ordinal): "path-\(ordinal)"
            case .note(let entry): Self.noteAnchor(entry.postID)
            }
        }

        static func chapterAnchor(_ sectionID: String) -> String { "chapter-\(sectionID)" }
        static func noteAnchor(_ postID: String) -> String { "page-\(postID)" }
    }

    /// Chaptered books: each group's heading (or the unfiled heading), then
    /// its notes — `grouped`'s order, rendered.
    static func rows(
        grouped: [(section: ReadingSection?, entries: [Queries.ReadingEntry])]
    ) -> [Row] {
        var result: [Row] = []
        for group in grouped {
            if let section = group.section {
                result.append(.chapter(section))
            } else {
                result.append(.unfiledHeading)
            }
            result.append(contentsOf: group.entries.map { .note($0) })
        }
        return result
    }

    /// Flat books (smart, or curated without chapters): a tag-path heading
    /// where the section differs from the previous entry's (the
    /// `sectionHeader(at:)` rule, restated over the whole list so the row
    /// list is one pure value).
    static func rows(flat entries: [Queries.ReadingEntry]) -> [Row] {
        var result: [Row] = []
        for (i, entry) in entries.enumerated() {
            if let path = entry.sectionPath,
               i == 0 || entries[i - 1].sectionPath != path {
                result.append(.tagHeading(path: path, ordinal: i))
            }
            result.append(.note(entry))
        }
        return result
    }
}
