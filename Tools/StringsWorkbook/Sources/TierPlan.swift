// BRANCH-ONLY tool code (`tools/strings-workbook`; never merges). The record:
// notes/plans/strings-workbook-record.md.

import Foundation

/// The burn-down order of `notes/copy-pass/priority-order.md`, as the
/// workbook's chapters.
///
/// **Chapter names** come from the priority doc itself at run time: each
/// `## Tier N — title (…)` heading, minus its trailing time-box parenthetical.
///
/// **Which surface sits in which tier** is a hand placement (the doc names
/// surfaces by short forms and counts — "Sidebar & Library chrome (122)",
/// "Books & gatherings (479)" — never by exact heading), transcribed here with
/// the rule the batch record states as PROVISIONAL P-2:
/// - a surface sits in the FIRST tier that names it — as a surface, or by a
///   part of it — at the position of that first mention;
/// - Tier 0 names defect STRINGS by site, never surfaces, so it places none;
/// - Tier 3 sends "Settings ▸ Protection" to Tier 6 explicitly ("land with the
///   ruled corpus (Tier 6)"), and that instruction is honoured;
/// - so the two surfaces a tier names only IN PART land where they are first
///   asked for: "Seeded content" in Tier 1 (item 2, the welcome names) and
///   "Protection, encryption, account & sync surfaces" in Tier 2 (item 3, the
///   §11-provisional strings "yours to settle now"); Tier 4's documents and
///   Tier 6's ruled corpus are not inlined in the inventory, so those two
///   chapters hold nothing of their own.
/// A surface no tier names goes to the final "Unprioritized" chapter, in
/// document order (none does in the 2026-10-04 compile; the chapter is made
/// only when something lands there — P-3).
public enum TierPlan {
    public static let unprioritizedChapterName = "Unprioritized"

    /// Tier number → the inventory's exact surface headings, in tier order.
    public static let placements: [Int: [String]] = [
        0: [],
        1: [
            "Onboarding, first run & the locked lobby",                       // item 1
            "Seeded content",                                                  // item 2 (P-2)
            "Empty states & placeholders",                                     // item 3
            "Sidebar & Library chrome (Library, Timeline, Folder, Starred, the Open list, back/forward)",  // item 4
            "Note chrome — masthead, mode row, tags, context bar, panes",      // item 4
            "Quick note & capture",                                            // item 5
        ],
        2: [
            "Refusals, offers & receipts (the status seam)",                   // item 1
            "Dialogs, sheets & ceremonies (Divide/Merge choosing takes, confirms, pickers)",  // item 2
            "Protection, encryption, account & sync surfaces",                 // item 3 (P-2)
            "Menus, command palette & structural-undo labels",                 // item 4
        ],
        3: [
            "Settings — window chrome, pane list & search",
            "Settings — General",
            "Settings — Editor",
            "Settings — Takes",
            "Settings — Writing",
            "Settings — Shortcuts",
            "Settings — Tags",
            "Settings — Data Safety",
            "Settings — Acknowledgments",
        ],
        4: [],
        5: [
            "Book surfaces — books & gatherings (Outline · Index · Book · Read, book settings and states, membership, rules, arrivals)",
            "Book surfaces — the Bookcase, shelves & wings",
            "Note mode row — Write (the editor, bottom bar, comments, find, formatting, references, word targets)",
            "Note mode row — Takes",
            "Archived & Deleted (the Trash) and putting things back",
            "This Note's Tray & Block History",
            "Pool & Snippets (the scraps area)",
            "Note mode row — Compare (incl. Outline note, Diff)",
            "Note mode row — Blocks (workbench & block index)",
            "Note mode row — Lenses",
            "Note Versions",
            "Note mode row — Canvas",
            "Note mode row — Read",
            "Import & export (templates, file names, reports)",
        ],
        6: [
            "Settings — Protection",                                           // Tier 3's redirect
            "Tooltips & help text — the Shortcuts & Dictionary window",
            "Accessibility-only labels",
            "Anything else user-visible",
        ],
    ]

    public struct Tier: Equatable, Sendable {
        public var number: Int
        /// The chapter name: the doc's heading minus its parenthetical.
        public var chapterName: String
    }

    public enum PlanError: Error, Equatable, CustomStringConvertible {
        case tiersDoNotMatchPlacements(found: [Int], placed: [Int])

        public var description: String {
            switch self {
            case .tiersDoNotMatchPlacements(let found, let placed):
                return "priority-order.md names tiers \(found) but the placement table covers \(placed) — "
                    + "the doc changed since the table was transcribed"
            }
        }
    }

    /// Every `## Tier N — …` heading of the priority doc, in order. Refuses
    /// when the doc's tiers are not exactly the placement table's.
    public static func tiers(fromPriorityDoc markdown: String) throws -> [Tier] {
        var tiers: [Tier] = []
        for line in markdown.components(separatedBy: "\n") where line.hasPrefix("## Tier ") {
            let heading = String(line.dropFirst(3))
            let digits = heading.dropFirst("Tier ".count).prefix(while: \.isNumber)
            guard let number = Int(digits) else { continue }
            tiers.append(Tier(number: number, chapterName: chapterName(fromHeading: heading)))
        }
        let found = tiers.map(\.number)
        let placed = placements.keys.sorted()
        guard found == placed else {
            throw PlanError.tiersDoNotMatchPlacements(found: found, placed: placed)
        }
        return tiers
    }

    /// "Tier 1 — the first ten minutes (~1.5h, full read, rewrite freely)" →
    /// "Tier 1 — the first ten minutes". A heading without a trailing
    /// parenthetical is kept whole.
    static func chapterName(fromHeading heading: String) -> String {
        let trimmed = heading.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasSuffix(")"), let open = trimmed.range(of: " (", options: .backwards) else {
            return trimmed
        }
        return String(trimmed[..<open.lowerBound])
    }
}
