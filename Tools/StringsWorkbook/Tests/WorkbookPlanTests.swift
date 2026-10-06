// BRANCH-ONLY tests (`tools/strings-workbook`; never merges).

import Foundation
import Testing
@testable import StringsWorkbook

@Suite("StringsWorkbook — the tier plan and the workbook's shape")
struct WorkbookPlanTests {
    @Test func tierChaptersAreThePriorityDocsHeadingsInOrder() {
        #expect(RealDocs.tiers.map(\.number) == [0, 1, 2, 3, 4, 5, 6])
        #expect(RealDocs.tiers.map(\.chapterName) == [
            "Tier 0 — defects, not voice",
            "Tier 1 — the first ten minutes",
            "Tier 2 — the app's spoken voice",
            "Tier 3 — the settings panes",
            "Tier 4 — the field guide & demo content",
            "Tier 5 — the mode surfaces",
            "Tier 6 — deliberately OUT of the 8 hours",
        ])
    }

    @Test func everySurfaceIsPlacedExactlyOnceAndEveryPlacementIsARealHeading() {
        let headings = Set(RealDocs.inventory.surfaces.map(\.name))
        let placed = TierPlan.placements.values.flatMap { $0 }
        #expect(placed.count == Set(placed).count)
        #expect(Set(placed) == headings)
    }

    @Test func theBookHasSevenChaptersAndNoUnprioritizedChapter() {
        let plan = RealDocs.plan
        #expect(plan.chapters.map(\.name) == RealDocs.tiers.map(\.chapterName))
        #expect(!plan.chapters.contains { $0.name == TierPlan.unprioritizedChapterName })
        #expect(plan.notes.count == 37)
        #expect(plan.blockCount == 3630)
    }

    @Test func eachChapterHoldsItsSurfacesInTheTiersListedOrder() {
        let byChapter = Dictionary(uniqueKeysWithValues: RealDocs.plan.chapters.map { ($0.name, $0.notes.map(\.title)) })
        #expect(byChapter["Tier 0 — defects, not voice"] == [])
        #expect(byChapter["Tier 1 — the first ten minutes"] == [
            "Onboarding, first run & the locked lobby",
            "Seeded content",
            "Empty states & placeholders",
            "Sidebar & Library chrome (Library, Timeline, Folder, Starred, the Open list, back/forward)",
            "Note chrome — masthead, mode row, tags, context bar, panes",
            "Quick note & capture",
        ])
        #expect(byChapter["Tier 2 — the app's spoken voice"] == [
            "Refusals, offers & receipts (the status seam)",
            "Dialogs, sheets & ceremonies (Divide/Merge choosing takes, confirms, pickers)",
            "Protection, encryption, account & sync surfaces",
            "Menus, command palette & structural-undo labels",
        ])
        #expect(byChapter["Tier 3 — the settings panes"]?.count == 9)
        #expect(byChapter["Tier 3 — the settings panes"]?.first == "Settings — window chrome, pane list & search")
        #expect(byChapter["Tier 4 — the field guide & demo content"] == [])
        #expect(byChapter["Tier 5 — the mode surfaces"]?.count == 14)
        #expect(byChapter["Tier 5 — the mode surfaces"]?.first
                == "Book surfaces — books & gatherings (Outline · Index · Book · Read, book settings and states, membership, rules, arrivals)")
        #expect(byChapter["Tier 5 — the mode surfaces"]?.last == "Import & export (templates, file names, reports)")
        #expect(byChapter["Tier 6 — deliberately OUT of the 8 hours"] == [
            "Settings — Protection",
            "Tooltips & help text — the Shortcuts & Dictionary window",
            "Accessibility-only labels",
            "Anything else user-visible",
        ])
        // Per-chapter block totals (the tiers' sizes as she will meet them).
        let blocks = RealDocs.plan.chapters.map { $0.notes.reduce(0) { $0 + $1.blocks.count } }
        #expect(blocks == [0, 276, 1253, 253, 0, 1669, 179])
    }

    @Test func blocksKeepTheInventorysOrderWithinANote() throws {
        let note = try #require(RealDocs.plan.notes.first { $0.title == "Onboarding, first run & the locked lobby" })
        #expect(note.blocks.count == 22)
        #expect(note.blocks.first?.current.hasPrefix("The new library's key file could not be written") == true)
        #expect(note.blocks.map(\.sourceLine) == note.blocks.map(\.sourceLine).sorted())
    }

    @Test func theLocatorLeadsWithTheRuledLineThenSitesSurfaceAndTags() throws {
        let note = try #require(RealDocs.plan.notes.first { $0.title == "Onboarding, first run & the locked lobby" })
        let biometry = try #require(note.blocks.first { $0.current.hasPrefix(#"\(ProtectionCopy.biometryName) didn't"#) })
        #expect(biometry.locator == """
            ⚠RULED (§11 provisional) — edit against notes/plans/pre-13x-copy.md
            App/Variorum/Shared/StoreLaunchGate.swift:625
            surface: Onboarding, first run & the locked lobby
            (templated)
            """)
        let passphrase = try #require(note.blocks.first { $0.current == "Encryption passphrase" })
        #expect(passphrase.locator == """
            ⚠RULED — edit against notes/plans/pre-13x-copy.md
            App/Variorum/Variorum/StoreFailureView.swift:83
            App/Variorum/Variorum/StoreLockView.swift:196
            surface: Onboarding, first run & the locked lobby
            """)
        let retry = try #require(note.blocks.first { $0.current == "Retry" })
        #expect(retry.locator == """
            App/Variorum/Variorum/StoreFailureView.swift:56
            surface: Onboarding, first run & the locked lobby
            """)
        // Every ruled string's locator leads with its lead — load-bearing.
        let ruled = RealDocs.bullets.filter { $0.ruled != nil }.count
        let led = RealDocs.plan.notes.flatMap(\.blocks).filter { $0.locator.hasPrefix("⚠RULED") }.count
        #expect(ruled == led)
        #expect(led == 95 + 252 + 2)
    }

    @Test func aFooterMismatchRefusesRatherThanPaperingOver() throws {
        let inventory = try StringsInventory.parse(InventoryParserTests.doc(
            #"- `"Hi"` — `a/B.swift:3`"#, footer: 2, total: 2))
        #expect(throws: WorkbookPlan.PlanError.footerMismatch(surface: "Alpha", bullets: 1, footer: 2)) {
            _ = try WorkbookPlan.make(inventory: inventory, tiers: [])
        }
    }

    @Test func aTotalsMismatchRefuses() throws {
        let inventory = try StringsInventory.parse(InventoryParserTests.doc(
            #"- `"Hi"` — `a/B.swift:3`"#, footer: 1, total: 5))
        #expect(throws: WorkbookPlan.PlanError.totalMismatch(bullets: 1, declared: 5)) {
            _ = try WorkbookPlan.make(inventory: inventory, tiers: [])
        }
    }

    @Test func anUnplacedSurfaceLandsInUnprioritizedInDocOrder() throws {
        // A synthetic surface no tier names: the Unprioritized chapter exists
        // only because something landed there (P-3).
        let inventory = try StringsInventory.parse(InventoryParserTests.doc(
            #"- `"Hi"` — `a/B.swift:3`"#, footer: 1, total: 1))
        let plan = try WorkbookPlan.make(inventory: inventory, tiers: [])
        #expect(plan.chapters.map(\.name) == [TierPlan.unprioritizedChapterName])
        #expect(plan.chapters[0].notes.map(\.title) == ["Alpha"])
    }

    @Test func aPriorityDocWhoseTiersDifferFromTheTableRefuses() {
        #expect(throws: TierPlan.PlanError.self) {
            _ = try TierPlan.tiers(fromPriorityDoc: "## Tier 0 — a (x)\n## Tier 1 — b (y)\n")
        }
    }
}
