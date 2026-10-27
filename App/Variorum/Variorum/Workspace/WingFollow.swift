//
//  WingFollow.swift
//  Variorum (Mac) — Workspace
//
//  17y item (f) — THE CROSS-WING FOLLOW (the shape RULED by her, 2026-10-04,
//  on the architect's proposal — QUESTIONS #174's refinement carries it
//  verbatim; only build detail remained). Her lived confusion: "click on a
//  note, then click on the library and the note isn't there. or star it and
//  it doesn't appear in starred because you're still in a different wing" —
//  "your left bar showing 'library' should reflect the wing you're editing
//  in". The ruling:
//
//  · the app's ONE wing switches on OPEN of a cross-wing note ("I said edit
//    but I meant on open"), with the quiet "Now in X" receipt;
//  · under split panes it FOLLOWS THE FOCUSED PANE'S NOTE on focus too ("…not
//    change on focus if we normally change on open" made no sense to her);
//  · ONE app-wide wing stays the truth (P-13id-U5-3); editors NEVER close on a
//    wing switch — wings scope LISTINGS, not open editors;
//  · a visible WING INDICATOR on cross-wing Open-list rows.
//
//  ONE rule serves open AND focus: whatever the FOCUSED pane is asked to show
//  — every navigation door funnels through `WorkspaceModel.select`, and focus
//  moves through `focus`/`openBeside`/`closeSplit` — the workspace raises
//  (`onFocusedSubjectChanged`, the `onNotesLeft` precedent: the signal lives
//  where the fact does, so a test drives it without SwiftUI), and this type
//  follows: a note (or a book — PROVISIONAL P-17y-B3-f3) living in another
//  wing switches the app's wing to it, said once as a receipt. A switch the
//  SWITCHER makes is never undone by this: only a fresh open or a focus move
//  is followed, never a standing pane.
//

import Foundation
import GRDB
import VariorumCore

nonisolated enum WingFollow {
    /// What the follow does for a subject living in `subjectWing` (nil = not
    /// a wing-bearing subject, or unknown) while the app stands in `current`.
    enum Decision: Equatable {
        case stay
        case switchTo(String)
    }

    static func decision(current: String, subjectWing: String?) -> Decision {
        guard let subjectWing, subjectWing != current else { return .stay }
        return .switchTo(subjectWing)
    }

    /// The quiet receipt (wording PROVISIONAL — 13s re-voices). Home is a
    /// place-name, never quoted; a wing she named is hers.
    static func nowIn(_ wingName: String, isHome: Bool) -> String {
        isHome ? "Now in Home." : "Now in \u{201C}\(wingName)\u{201D}."
    }

    /// The Open row's indicator words and hover (P-17y-B3-f4).
    static func indicatorHelp(_ wingName: String) -> String {
        "In the wing \u{201C}\(wingName)\u{201D} \u{2014} opening it takes you there"
    }

    /// The wing a pane's subject lives in, as surfaces READ wings (a dangling
    /// pointer is Home's — `Queries.effectiveWing`). nil for a subject that
    /// bears no wing (the Bookcase, the Library, Snippets — one shared room —
    /// the recovery surfaces) or that no longer exists.
    static func subjectWing(_ db: Database, _ selection: SidebarSelection) throws -> String? {
        switch selection {
        case .post(let id):
            return try Queries.effectiveWing(db, ofPost: id)
        case .reading(let id):
            guard let reading = try Queries.reading(db, id: id), reading.deletedAt == nil
            else { return nil }
            return try Queries.wingName(db, id: reading.wingId) != nil ? reading.wingId : ""
        default:
            return nil
        }
    }

    /// **The Open rows' indicator** — for each open note living in ANOTHER
    /// wing than `current`, that wing's name (bounded by the Open list, P1).
    static func crossWingNames(
        _ db: Database, noteIDs: [String], current: String
    ) throws -> [String: String] {
        var out: [String: String] = [:]
        for id in noteIDs {
            guard let wing = try Queries.effectiveWing(db, ofPost: id), wing != current,
                  let name = try Queries.wingName(db, id: wing, home: WingWords.home)
            else { continue }
            out[id] = name
        }
        return out
    }

    /// **VX-425 — the sidebar note rows' wings**: for each listed note living
    /// in ANOTHER wing than `current`, that wing's ID (its Move/Copy to Wing ▸
    /// doors list the wings other than the note's own). Bounded by the rows
    /// (P1).
    static func crossWingIDs(
        _ db: Database, noteIDs: [String], current: String
    ) throws -> [String: String] {
        var out: [String: String] = [:]
        for id in noteIDs {
            guard let wing = try Queries.effectiveWing(db, ofPost: id), wing != current else { continue }
            out[id] = wing
        }
        return out
    }
}

@MainActor
extension WingFollow {
    /// **THE FOLLOW** — read the subject's wing; when it is another, switch
    /// the app's one wing to it and say so. `stillShown` guards a stale
    /// answer: focus that moved on while the read was in flight is not
    /// followed (the newer move has its own follow).
    static func follow(
        _ selection: SidebarSelection?, session: AppSession,
        stillShown: @escaping () -> Bool = { true }
    ) async {
        guard let selection else { return }
        let read = try? await session.database.read { db -> (String, String?)? in
            guard let wing = try subjectWing(db, selection) else { return nil }
            return (wing, try Queries.wingName(db, id: wing, home: WingWords.home))
        }
        guard let (wing, name) = read ?? nil, stillShown() else { return }
        guard case .switchTo(let target) = decision(
            current: session.wing.currentID, subjectWing: wing)
        else { return }
        session.wing.switchTo(target)
        session.status.receipt(nowIn(name ?? WingWords.home, isHome: target.isEmpty))
    }

    /// Wires one window's workspace to the follow (per window, the
    /// `SavepointOnLeave.wire` shape — the panes that moved are this
    /// window's; the wing they switch is the app's one).
    static func wire(workspace: WorkspaceModel, session: AppSession) {
        workspace.onFocusedSubjectChanged = { [weak workspace, weak session] selection in
            guard let session else { return }
            Task { @MainActor in
                await follow(selection, session: session) {
                    workspace?.focusedSelection == selection
                }
            }
        }
    }
}
