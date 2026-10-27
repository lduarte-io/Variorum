//
//  SidebarRowLeads.swift
//  Variorum (Mac)
//
//  **VX-580 (the VX-439 run, A-439-11) — the sidebar's untitled notes lead
//  with their own first words, by default.** Her note (2026-10-21): *"I NEED
//  to make showing a preliminary title on the lefthand bar the default - maybe
//  fewer words than the library shows, but agh. I suppose that could be a
//  setting too."* Built the lightest way she allowed: ON, with no setting.
//
//  The words come from the LIBRARY's one brain — `NoteCardFace` (core), fed by
//  the Library's own bounded opening read (`NoteCards.load`, words only) — so a
//  note is never called one thing in the Library's list and another in the
//  sidebar. The same rule decides WHICH notes: a note with no name of its own
//  that is not a daily entry (`LibraryCardName.leadsWithItsWords`' facts — a
//  journal entry's day IS its identity, and a named note says what it is). A
//  note with no words at all keeps the name every other surface gives it (its
//  day). The row truncates it naturally (the marquee's ellipsis at rest).
//
//  DISPLAY ONLY (her item 4's law, carried): derived at read time, never
//  stored, nothing renamed — the rename door still seeds from the STORED title
//  (`NoteRename`), and `DisplayTitle` (what a note is CALLED — the masthead,
//  the pane line, the back chip, exports, the View menu's Open Note rows)
//  is untouched.
//

import Foundation
import GRDB
import VariorumCore

nonisolated enum SidebarRowLeads {
    /// **The sidebar rows' derived leads** — for each listed note that leads
    /// with its words, the card lead's text; absent for every other note (its
    /// row keeps its display name). One bounded read: the rows' own container
    /// facts, then the Library's opening read over only the notes that need it
    /// (P1 — the Open list and the star cap bound it; a sidebar of named notes
    /// reads no words at all).
    static func read(_ db: Database, noteIDs: [String]) throws -> [String: String] {
        guard !noteIDs.isEmpty else { return [:] }
        let facts = try Row.fetchAll(
            db,
            sql: """
                SELECT id, title, profile, entry_date, created_at FROM container
                WHERE id IN (\(databaseQuestionMarks(count: noteIDs.count)))
                  AND kind = 'post' AND deleted_at IS NULL
                """,
            arguments: StatementArguments(noteIDs))
        let unnamed = facts.filter { row in
            DisplayTitle.isAbsent(row["title"] as String?)
                && (row["profile"] as String?) != Profile.journal.rawValue
        }
        guard !unnamed.isEmpty else { return [:] }
        let cards = try NoteCards.load(
            db, postIDs: unnamed.map { $0["id"] as String }, includingBooks: false)
        var out: [String: String] = [:]
        for row in unnamed {
            let id: String = row["id"]
            let face = NoteCardFace.card(
                storedTitle: row["title"], leadingTexts: cards[id]?.leadingTexts ?? [],
                isJournal: false, entryDate: row["entry_date"], createdAt: row["created_at"])
            if case .words(let words) = face.lead { out[id] = words }
        }
        return out
    }
}
