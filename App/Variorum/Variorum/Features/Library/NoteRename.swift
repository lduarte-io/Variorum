//
//  NoteRename.swift
//  Variorum (Mac)
//
//  **VX-425 (the VX-439 run, A-439-16) — RENAME NOTE…, one ask for every row
//  that renders it.** Her ask (2026-10-18) and a beta tester's: the sidebar's
//  note rows get Rename beside Delete and Close. The Library's note rows have
//  carried a "Rename…" alert since 9d; the sidebar's rows are its second
//  renderer, so the alert's WORDS and its seed live here once (the
//  `deleteNoteConfirmDialog` precedent — the wording is the thing that must
//  not drift between two doors of one act).
//
//  The seed is the note's STORED title, never its display answer: an untitled
//  note is shown by its date (or, in the sidebar, its first words — VX-580),
//  and naming it after that would be naming it after itself (13g batch 7,
//  R6-3). The write is the one rename road, `LibraryViewModel.rename`
//  (`renameContainer`; a blank stores NULL and the note reads "Untitled"
//  again).
//

import GRDB
import SwiftUI
import VariorumCore

/// The ask's words (sentence case — her standing rule).
nonisolated enum NoteRenameCopy {
    static let alertTitle = "Rename Note"
    static let field = "Title"
    static let confirm = "Rename"
}

@MainActor
enum NoteRename {
    /// The field's seed: the note's STORED title ("" when it has none) — read
    /// at the press, so a door never needs the title in hand.
    static func storedTitle(session: AppSession, postID: String) async -> String {
        let stored = try? await session.database.read { db in
            try Queries.containerTitle(db, id: postID)
        }
        return (stored ?? nil) ?? ""
    }
}

extension View {
    /// **The one rename ask** — the Library's alert, hoisted: a text field
    /// holding `title` (its seed), Rename and Cancel. Presented while `target`
    /// names a note; `onRename` receives the note and the field's words.
    func noteRenameAlert(
        target: Binding<String?>, title: Binding<String>,
        onRename: @escaping (_ postID: String, _ title: String) -> Void
    ) -> some View {
        alert(
            NoteRenameCopy.alertTitle,
            isPresented: Binding(
                get: { target.wrappedValue != nil },
                set: { if !$0 { target.wrappedValue = nil } }),
            presenting: target.wrappedValue
        ) { postID in
            TextField(NoteRenameCopy.field, text: title)
            Button(NoteRenameCopy.confirm) { onRename(postID, title.wrappedValue) }
            Button("Cancel", role: .cancel) {}
        }
    }
}
