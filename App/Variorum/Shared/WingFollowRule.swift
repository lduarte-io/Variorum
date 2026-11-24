//
//  WingFollowRule.swift
//  Variorum (shared: Mac + Mobile)
//
//  VM-63 (the VM-55 run, "Wings underneath", batch 3) — THE CROSS-WING
//  FOLLOW's RULE, hoisted: what the follow decides for a subject living in a
//  wing, and the quiet receipt it (and every said switch — `WingsModel.goTo`)
//  speaks. Moved byte for byte from the Mac's `Workspace/WingFollow.swift`,
//  which keeps the Mac's ACT as extensions of this type: reading a pane's
//  subject (`subjectWing` — the Mac's `SidebarSelection`), the follow itself
//  and its wiring to a window's workspace (`follow`, `wire` —
//  `WorkspaceModel`), and the Open rows' indicator (`indicatorHelp`,
//  `crossWingNames`, `crossWingIDs`). The ruling's narrative is that file's
//  header (17y item (f), QUESTIONS #174).
//

import Foundation

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
}
