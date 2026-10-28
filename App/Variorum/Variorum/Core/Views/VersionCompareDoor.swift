//
//  VersionCompareDoor.swift
//  Variorum (Mac)
//
//  **VX-440 batch 1 — a saved moment BESIDE the note, in Compare** (R-440-1,
//  her "rows + one-press door"; VX-130's ask: *"Compare preloaded with a
//  previous version beside the note, no promoting"*). The record is
//  `notes/plans/fixes/vx-440-sheets-history-clarity.md`.
//
//  ONE act, every door: a Versions row's "Compare with now" names its moment;
//  "Compare with Latest Version" (File, both bars' `note ▾`, ⌘K) names the
//  newest, read at the press. Both reach the board through the road the wire's
//  compare target already takes (`CommandRouter.requestCompare` — the landing
//  parked for the anchor's board, then Compare requested; the board replaces
//  its columns with exactly the moment and decides "related blocks only" from
//  its own projection, VX-298). The note's detail must be the mounted one —
//  Compare is one of its modes — which is why the doors render only there.
//

import Foundation
import VariorumCore

@MainActor
enum VersionCompareDoor {
    /// Seat `versionID` beside `noteID` in Compare. False when the switch was
    /// refused (the router has already spoken why).
    @discardableResult
    static func compare(versionID: String, with noteID: String, session: AppSession) -> Bool {
        session.commandRouter.requestCompare(postID: noteID, peers: [versionID])
    }

    /// The one-press door: the note's NEWEST moment, read now (a door rendered
    /// a moment ago may be answering for a moment promoted since). With none,
    /// the act's own honest note speaks — the race a P-2 door can still meet.
    static func compareWithLatest(noteID: String, session: AppSession) async {
        let latest = (try? await session.database.read { db in
            try Queries.latestNoteVersionID(db, of: noteID)
        }) ?? nil
        guard let latest else {
            session.status.refuse(VersionsPath.compareWithLatestUnavailable)
            return
        }
        compare(versionID: latest, with: noteID, session: session)
    }

    /// **May this note's doors seat a moment in Compare from where they are?**
    /// Only while its detail is the mounted one (a book's inline editor or a
    /// spread's board composes the same bar with no detail around it — there
    /// is no Compare mode to switch to, so the door is not drawn there: P-2).
    static func canCompare(noteID: String, session: AppSession) -> Bool {
        session.commandRouter.activePostID == noteID
    }

    /// The `note ▾` row's gate: the detail is this note's AND it has a moment
    /// (the registry's availability, read through the router's live context).
    static func latestDoorShows(noteID: String, session: AppSession) -> Bool {
        canCompare(noteID: noteID, session: session)
            && session.commandRouter.isEnabled(.compareWithLatestVersion)
    }
}
