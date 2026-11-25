//
//  BookListRows.swift
//  Variorum (Mac)
//
//  **VX-1084 — the List mode's groups, pure** (the VX-1036 run, batch 3): the
//  Outline's own row assembly (`BookOutlineRows`) regrouped under headings
//  with counts. Its own file so the rule compiles and pins on its own; the
//  face is `BookListView.swift`.
//

import VariorumCore

nonisolated enum BookListRows {
    /// One heading of the List, and how many of the list's notes stand under it.
    struct Heading: Equatable, Sendable {
        enum Kind: Equatable, Sendable {
            /// A book's chapter — its own "+ new note" stands at the trailing end.
            case chapter(ReadingSection)
            /// The chapterless group, last ("unfiled" — the one word).
            case unfiled
            /// A gathering's tag-path section (`grouping_tag_id`).
            case tagPath(String)
        }

        var kind: Kind
        var count: Int
    }

    /// A heading (or none — a flat book's notes) and the notes under it, in
    /// the book's order.
    struct Group: Equatable, Sendable, Identifiable {
        var id: String
        var heading: Heading?
        var entries: [Queries.ReadingEntry]
    }

    /// **The List's groups** from the Outline's row assembly — the same
    /// headings in the same order, each counted by the notes the List lists
    /// under it (the window's — PROVISIONAL P-1036-B3-6).
    static func groups(rows: [BookOutlineRows.Row]) -> [Group] {
        var groups: [Group] = []
        func open(_ id: String, _ kind: Heading.Kind) {
            groups.append(Group(id: id, heading: Heading(kind: kind, count: 0), entries: []))
        }
        for row in rows {
            switch row {
            case .chapter(let section): open(row.id, .chapter(section))
            case .unfiledHeading: open(row.id, .unfiled)
            case .tagHeading(let path, _): open(row.id, .tagPath(path))
            case .note(let entry):
                if groups.isEmpty {
                    groups.append(Group(id: "list-lead", heading: nil, entries: []))
                }
                groups[groups.count - 1].entries.append(entry)
                if groups[groups.count - 1].heading != nil {
                    groups[groups.count - 1].heading?.count += 1
                }
            }
        }
        return groups
    }

    /// A note row's anchor in the List's own scroll.
    static func noteAnchor(_ postID: String) -> String { "list-note-\(postID)" }
}

