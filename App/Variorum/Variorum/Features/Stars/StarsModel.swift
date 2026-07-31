//
//  StarsModel.swift
//  Variorum (Mac)
//
//  Phase 13f, W4 — STARS (her sitting ruling, round 3: *"stars = a synced
//  `setting` list + a Starred sidebar section … up to 5 notes or books,
//  star/unstar via context menu + ⌘K, section at the sidebar's top"*).
//
//  A star is STORE state, not window state — it is synced, it outlives the
//  session, and both windows show the same five. So unlike the Open strip
//  (which hangs off the window's `WorkspaceModel`) this model observes the
//  core's one `setting` row and writes through the runner. Every DECISION
//  is the core's (`Operations.setStarred`'s order, cap and self-heal); this
//  holds the observed list, hands the surfaces one door value, and speaks
//  the operations layer's real refusal (P-2).
//

import Foundation
import GRDB  // AsyncValueObservation iteration
import Observation
import VariorumCore

@MainActor
@Observable
final class StarsModel {
    @ObservationIgnored let session: AppSession

    /// The starred rows, in star order, already filtered to LIVE targets by
    /// the core's read rule — so a deleted note's star simply is not here.
    private(set) var items: [Queries.StarredItem] = []
    private(set) var lastError: String?

    init(session: AppSession) {
        self.session = session
    }

    /// Held: at most `Operations.starLimit` rows by construction, which is
    /// the bounded-observation discipline satisfied by the data itself.
    func start() async {
        do {
            for try await value in session.database.observe({ db in
                try Queries.starred(db)
            }) {
                items = value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    func isStarred(_ target: StarTarget) -> Bool {
        items.contains { $0.target == target }
    }

    /// Star or un-star, and SPEAK whatever the operations layer answers —
    /// the cap's refusal is the whole reason this door fires rather than
    /// disappearing at five (P-2, and her ruling's "refuses honestly").
    func toggle(_ target: StarTarget) async {
        let starred = isStarred(target)
        do {
            try await session.runner.run { ops in
                try ops.setStarred(target, starred: !starred)
            }
            lastError = nil
        } catch {
            lastError = OpsRefusalCopy.message(for: error)
            session.status.speak(OpsRefusalCopy.message(for: error))
        }
    }

    /// The names the section renders, in the shape the app's ONE naming
    /// brain takes (`WorkspaceNaming.label`) — so a starred untitled note
    /// reads "Untitled" exactly as it does in the Open strip and the back
    /// chip, and no second fallback exists to drift from it.
    var titles: [String: String] {
        var out: [String: String] = [:]
        for item in items {
            if let name = item.name { out[item.target.id] = name }
        }
        return out
    }
}

// MARK: - The door (one value, every surface)

/// The star door as a row surface sees it: is this thing starred, and
/// toggle it. ONE value threaded to the four surfaces that render the door
/// (the Open strip, the Library catalog, the Pool, the shelf's book rows),
/// so the word on the menu item is derived in exactly one place and cannot
/// drift between them.
@MainActor
struct StarDoor {
    let isStarred: (StarTarget) -> Bool
    let toggle: (StarTarget) -> Void

    /// "Star" / "Unstar" — a state-dependent label derived from the
    /// registry-declared act, the `undoMenuTitle(for:)` shape. The registry
    /// declares the ACT once ("Toggle Star", which is what ⌘K types); a row
    /// says which direction it would go, because on a row that is the only
    /// legible wording.
    func title(for target: StarTarget) -> String {
        StarCopy.rowTitle(starred: isStarred(target))
    }
}

// MARK: - Vocabulary + the pure target rule

nonisolated enum StarCopy {
    /// The registry's ONE verb (menu title, ⌘K row).
    static let verb = "Toggle Star"
    static let starRow = "Star"
    static let unstarRow = "Unstar"
    static let sectionHeader = "Starred"
    /// The section's own glyph, and the row's un-star button.
    static let glyph = "\u{2605}"

    static func rowTitle(starred: Bool) -> String { starred ? unstarRow : starRow }

    /// What ⌘K answers where nothing starrable is open. The shelf, the
    /// library, the pool and the recovery surface are places, not things.
    static let unavailableNote =
        "Open a note or a book to star it — a star points at one of those, "
        + "and the Starred list sits at the top of the sidebar."

    static let rowHelp = "Un-star this — it leaves the Starred list; nothing else changes."
}

/// WHAT ⌘K STARS: the thing the focused pane is showing, or nothing.
///
/// Pure, and separate from the model, for the reason `MembershipChip.ascend`
/// is a named call: the palette's target is a RULE, and a rule inside a
/// closure is a rule no test can keep.
nonisolated enum StarTargeting {
    static func target(for selection: SidebarSelection?) -> StarTarget? {
        switch selection {
        case .post(let id): return .post(id)
        case .reading(let id): return .reading(id)
        // A place is not a thing you can star — and neither is a scraps
        // container (the Open strip's notes-only scope, round 7.2, applied
        // to the same question).
        case .shelf, .library, .poolPosts, .blocks, .recovery, .pool, .tag, nil:
            return nil
        }
    }

    /// The mirror: where a starred row navigates to. The Starred rows are
    /// ordinary tagged List rows, so this is what their tag carries.
    static func selection(for target: StarTarget) -> SidebarSelection {
        switch target.kind {
        case .post: return .post(target.id)
        case .reading: return .reading(target.id)
        }
    }
}
