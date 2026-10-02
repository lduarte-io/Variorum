//
//  NoteMembershipModel.swift
//  Variorum (Mac)
//
//  13i-d U2 — THE NOTE'S MEMBERSHIP, read in ONE place (KnownIssues row 104's
//  subject). Which readings hold or show the open note: its BOOK memberships
//  (`status='member'` rows) and the GATHERINGS whose rule shows it — the
//  `Queries.readingsContaining` read the membership chip has always made.
//
//  ── WHY IT LIVES IN THE SHARED HOME ──────────────────────────────────────
//  Two features consume it: the membership chip (`Features/BookView`) and the
//  note detail's Book Panel door (`Features/Takes` renders it, the panel is
//  `Features/BookView`'s). The note detail OWNS one and hands it to both, so
//  the note is read once, not once per consumer (CLAUDE.md's composition
//  rule: a feature never holds a sibling's model — a shared one lives here).
//

import Foundation
import GRDB  // AsyncValueObservation iteration
import Observation
import VariorumCore

@MainActor
@Observable
final class NoteMembershipModel {
    /// The note the readings in hand are about — read through the accessors
    /// below so a stale note's books never appear under a new note's title
    /// (the `NoteBoxFactsModel.subject` shape).
    private(set) var subject: String?
    private var readings: [Reading] = []

    /// Every reading holding or showing `postID`, by (name, id) — empty
    /// unless the readings in hand are THIS note's.
    func readings(for postID: String) -> [Reading] {
        subject == postID ? readings : []
    }

    /// The BOOKS the note is a member of (a gathering holds no membership).
    func books(for postID: String) -> [Reading] {
        readings(for: postID).filter { $0.kind == .book }
    }

    /// The GATHERINGS whose rule shows the note right now.
    func gatherings(for postID: String) -> [Reading] {
        readings(for: postID).filter { $0.kind == .gathering }
    }

    /// Reads the note's membership for the visit. Run from `.task(id:)`.
    func track(session: AppSession, postID: String) async {
        let value = (try? await session.database.read { db in
            try Queries.readingsContaining(db, postID: postID)
        }) ?? []
        // A superseded read (the task was cancelled for a newer note) leaves
        // both fields to the newer one — the `NoteBoxFactsModel` lesson.
        guard !Task.isCancelled else { return }
        subject = postID
        readings = value
    }
}
