// BRANCH-ONLY tool code (`tools/strings-workbook`; never merges). The record:
// notes/plans/strings-workbook-record.md.

import Foundation

/// The workbook, planned in full before a single row is written — pure, so
/// the tests cover the exact shape the mint will produce.
///
/// The shape (issue #5; the brief): ONE book "App Strings"; chapters = the
/// priority tiers in order (+ "Unprioritized" only when something lands
/// there); one NOTE per inventory surface, titled with its heading, in its
/// tier's order; one BLOCK per string bullet (multi-site bullets stay one
/// block); THREE takes per block in this fan order — "current" (chosen and
/// default: the screen text), "rewrite" (empty: her writing surface), "where"
/// (the locator).
public struct WorkbookPlan: Equatable, Sendable {
    public static let bookName = "App Strings"
    public static let takeLabels = (current: "current", rewrite: "rewrite", locator: "where")
    /// The lead line a ⚠RULED string's locator opens with — LOAD-BEARING:
    /// those words are ruled, and editing them is re-ruling against the file.
    public static let ruledLead = "⚠RULED — edit against notes/plans/pre-13x-copy.md"
    public static let provisionalLead =
        "⚠RULED (§11 provisional) — edit against notes/plans/pre-13x-copy.md"

    public struct Chapter: Equatable, Sendable {
        public var name: String
        public var notes: [Note]
    }

    public struct Note: Equatable, Sendable {
        /// The surface's heading, verbatim.
        public var title: String
        public var blocks: [Block]
    }

    public struct Block: Equatable, Sendable {
        /// Take 1, "current" — chosen and default.
        public var current: String
        /// Take 3, "where".
        public var locator: String
        /// The inventory line the bullet came from (diagnostics only).
        public var sourceLine: Int
    }

    public var chapters: [Chapter]

    public var notes: [Note] { chapters.flatMap(\.notes) }
    public var blockCount: Int { notes.reduce(0) { $0 + $1.blocks.count } }

    public enum PlanError: Error, Equatable, CustomStringConvertible {
        case footerMismatch(surface: String, bullets: Int, footer: Int?)
        case totalMismatch(bullets: Int, declared: Int?)
        case unknownPlacement(String)
        case placedTwice(String)

        public var description: String {
            switch self {
            case .footerMismatch(let surface, let bullets, let footer):
                return "surface “\(surface)” has \(bullets) bullets but its footer says "
                    + "\(footer.map(String.init) ?? "nothing")"
            case .totalMismatch(let bullets, let declared):
                return "the inventory holds \(bullets) bullets but its Totals table says "
                    + "\(declared.map(String.init) ?? "nothing")"
            case .unknownPlacement(let name):
                return "the tier table places “\(name)”, which is not a surface heading in the inventory"
            case .placedTwice(let name):
                return "the tier table places “\(name)” twice"
            }
        }
    }

    /// Builds the plan. REFUSES — never papers over — when the inventory's
    /// own counts disagree (a surface's bullets vs its footer; the sum vs the
    /// Totals table) or the tier table names a heading the inventory lacks.
    public static func make(inventory: StringsInventory, tiers: [TierPlan.Tier]) throws -> WorkbookPlan {
        for surface in inventory.surfaces where surface.bullets.count != surface.footerCount {
            throw PlanError.footerMismatch(
                surface: surface.name, bullets: surface.bullets.count, footer: surface.footerCount)
        }
        guard inventory.bulletCount == inventory.declaredTotal else {
            throw PlanError.totalMismatch(bullets: inventory.bulletCount, declared: inventory.declaredTotal)
        }

        let byName = Dictionary(inventory.surfaces.map { ($0.name, $0) }, uniquingKeysWith: { a, _ in a })
        var placed = Set<String>()
        var chapters: [Chapter] = []
        for tier in tiers {
            var notes: [Note] = []
            for name in TierPlan.placements[tier.number] ?? [] {
                guard let surface = byName[name] else { throw PlanError.unknownPlacement(name) }
                guard placed.insert(name).inserted else { throw PlanError.placedTwice(name) }
                notes.append(note(for: surface))
            }
            chapters.append(Chapter(name: tier.chapterName, notes: notes))
        }
        let unplaced = inventory.surfaces.filter { !placed.contains($0.name) }
        if !unplaced.isEmpty {
            chapters.append(Chapter(name: TierPlan.unprioritizedChapterName, notes: unplaced.map(note(for:))))
        }
        return WorkbookPlan(chapters: chapters)
    }

    static func note(for surface: StringsInventory.Surface) -> Note {
        Note(title: surface.name, blocks: surface.bullets.map { bullet in
            Block(current: bullet.current, locator: locator(for: bullet, surface: surface.name),
                  sourceLine: bullet.line)
        })
    }

    /// Take 3: the ⚠RULED lead when present, every site on its own line, the
    /// surface, then the remaining tags.
    static func locator(for bullet: StringsInventory.Bullet, surface: String) -> String {
        var lines: [String] = []
        switch bullet.ruled {
        case .provisional: lines.append(provisionalLead)
        case .ruled: lines.append(ruledLead)
        case nil: break
        }
        lines.append(contentsOf: bullet.sites)
        lines.append("surface: \(surface)")
        if !bullet.tags.isEmpty {
            lines.append(bullet.tags.joined(separator: " "))
        }
        return lines.joined(separator: "\n")
    }
}
