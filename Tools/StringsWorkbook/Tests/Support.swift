// BRANCH-ONLY tests (`tools/strings-workbook`; never merges). Scratch stores
// only — no test here touches the Keychain, the dev store or her library.

import Foundation
@testable import StringsWorkbook
import VariorumCore

enum Repo {
    /// Tools/StringsWorkbook/Tests/Support.swift → the repo root.
    static let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent()
    static let stringsDoc = root.appendingPathComponent("notes/copy-pass/all-user-facing-strings.md")
    static let priorityDoc = root.appendingPathComponent("notes/copy-pass/priority-order.md")

    static func text(_ url: URL) throws -> String { try String(contentsOf: url, encoding: .utf8) }
}

/// The real docs, parsed once per process.
enum RealDocs {
    static let inventory: StringsInventory = {
        try! StringsInventory.parse(try! Repo.text(Repo.stringsDoc))
    }()
    static let tiers: [TierPlan.Tier] = {
        try! TierPlan.tiers(fromPriorityDoc: try! Repo.text(Repo.priorityDoc))
    }()
    static let plan: WorkbookPlan = {
        try! WorkbookPlan.make(inventory: inventory, tiers: tiers)
    }()

    static var bullets: [StringsInventory.Bullet] { inventory.surfaces.flatMap(\.bullets) }

    /// The ONE bullet whose first site is `site` — nil when none OR several
    /// (two literals can share a source line: HelperView.swift:118 holds both
    /// "Format ▸ Inline Code" and "`like this`"), so no test silently picks
    /// the wrong one. `containing` disambiguates by the doc body.
    static func bullet(firstSite site: String, containing fragment: String? = nil) -> StringsInventory.Bullet? {
        let matches = bullets.filter {
            $0.sites.first == site && (fragment.map($0.docBody.contains) ?? true)
        }
        return matches.count == 1 ? matches[0] : nil
    }
}
