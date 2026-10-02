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

    /// HOLDS the note's membership for the visit — run from `.task(id:)`, so
    /// a new note cancels the old observation and starts its own.
    ///
    /// **KnownIssues row 104, fixed here:** this was a ONE-SHOT read (the
    /// chip's `.task(id:)` + popover-open refresh), so a tagging act that
    /// SEATED the open note in a living book (13i-b's intake) left the chip
    /// reading "in no book" until the note was reopened. It is a held
    /// observation now.
    ///
    /// **The cost, named** (the brief's ask): `readingsContaining` reads
    /// `container` (a gathering's match), which autosave rewrites whole — so
    /// while a note is open this re-runs on every autosave: one indexed
    /// membership read (`idx_reading_post_post`) plus one EXISTS per live
    /// gathering, author-scale and off-main. KnownIssues row 13's bounded
    /// re-query class, at its cheap end (the cadence changed, never the
    /// scaling — P1's letter holds).
    func track(session: AppSession, postID: String) async {
        do {
            for try await value in session.database.observe({ db in
                try Queries.readingsContaining(db, postID: postID)
            }) {
                // A superseded observation (cancelled for a newer note)
                // leaves both fields to the newer one — the
                // `NoteBoxFactsModel` lesson.
                guard !Task.isCancelled else { return }
                subject = postID
                readings = value
            }
        } catch {
            // Cancellation (the note changed or the view left) ends the
            // visit quietly; a read failure leaves the last answer in hand.
        }
    }
}
