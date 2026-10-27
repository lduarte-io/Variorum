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
//  The words come from the LIBRARY's one brain — `NoteCardFace` (core), fed the
//  same opening the Library's card reads (the first `NoteCards.blockWindow`
//  slots, each cut at `NoteCards.snippetLimit`) — so a note is never called one
//  thing in the Library's list and another in the sidebar.
//
//  **The read is FLAT in the note's length (the VX-439 ladder's M-1, P1).** The
//  column HOLDS this read (every autosave stamps `container`, so it re-runs at
//  typing rate), so its words come through `Queries.leadingBlockTexts` — one
//  index-ordered seek per untitled note, stopped by a `LIMIT` (that read's own
//  query-plan pin) — never `NoteCards.load`, whose window function over the
//  note's placements reads every block of the note before it keeps three (0.2 ms
//  at 3 blocks, 36 ms at 20,000, measured). The one bounded consequence is that
//  read's own, stated there: a live placement over a DEAD block (a sync race)
//  takes a slot as a gap, where the Library's window skips it.
//
//  The same rule decides WHICH notes: a note with no name of its own
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
    /// facts, then each untitled note's opening slots — a `LIMIT`-stopped seek
    /// per note (P1 — cost ∝ the rows × the window, never ∝ a note's length;
    /// the Open list and the star cap bound the rows; a sidebar of named notes
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
        var out: [String: String] = [:]
        for row in unnamed {
            let id: String = row["id"]
            // The Library card's opening, read flat: its window of slots, each
            // cut where the card's read cuts it (`substr(…, 1, snippetLimit)`).
            let leading = try Queries.leadingBlockTexts(
                db, containerID: id, blocks: NoteCards.blockWindow
            ).map { String($0.prefix(NoteCards.snippetLimit)) }
            let face = NoteCardFace.card(
                storedTitle: row["title"], leadingTexts: leading,
                isJournal: false, entryDate: row["entry_date"], createdAt: row["created_at"])
            if case .words(let words) = face.lead { out[id] = words }
        }
        return out
    }
}
