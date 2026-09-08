//
//  SnippetsDoorsTests.swift
//  VariorumTests
//
//  17o batch e — the Snippets area's DOORS (the use-report round, ledger
//  rows 38 · 39).
//
//  Row 38, her words: *"if you right click on a snippet and open it in the
//  snippet editor, it just opens a whole note with several different
//  snippets but not even the snippet that i right clicked on … the snippet i
//  clicked on was part of the tutorial so it's not in the Snippets
//  editor."* Both card doors asked `SnippetsAreaModel.activePool`, which
//  under the rail's "all snippets" head row is `pools.first` — the oldest
//  group, the seeded default that `PoolNaming` displays as "Snippets" — and
//  neither carried the block she clicked.
//
//  Row 39, her words: *"you can't tag snippets but there's a tag on there."*
//  Tagging a snippet has always been possible (block tags are the model's —
//  AppSpec §7: "block-level tags primarily serve the pool"); the one door
//  was buried in the right-click menu, so a tag she could SEE read as
//  decoration. The chip is the door now; the sheet it opens no longer sends
//  her to a sidebar section that has not existed since R52.
//
//  Red-on-old (the standing-17 rule 1, the house method — batch b's own):
//  the door's decision is a value now, so the revert probe restores
//  `SnippetOpenTarget.card`'s pre-fix body (the active group, no landing)
//  on a committed tree and watches these go red. The `PoolDetailView` mount
//  below pins the ROAD the fixed door hands its landing to, end to end.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The door's decision (pure)

@Suite("Snippets — where a door goes (17o batch e, row 38)")
@MainActor
struct SnippetOpenTargetTests {
    private static let day = Date(timeIntervalSince1970: 1_782_864_000)

    private func pool(_ id: String, _ title: String?, plus seconds: TimeInterval) -> Container {
        Container(
            id: id, kind: .pool, title: title,
            createdAt: Self.day.addingTimeInterval(seconds),
            updatedAt: Self.day.addingTimeInterval(seconds))
    }

    private func item(_ blockID: String, pool poolID: String, text: String) -> Queries.PoolItem {
        Queries.PoolItem(
            block: Queries.RenderedBlock(
                blockID: blockID, placementID: "pl-\(blockID)", position: "a",
                variantID: "v-\(blockID)", text: text, activeVariantCount: 1,
                liveVariantCount: 1, commentCount: 0, variantLocked: false),
            tagPaths: [], poolID: poolID, updatedAt: nil)
    }

    /// A model holding a listing, with no store behind it — `adopt` is the
    /// surface's own test seam.
    private func area(
        pools: [Container], items: [Queries.PoolItem], selected: String?
    ) async throws -> SnippetsAreaModel {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Self.day)
        } operation: { @MainActor in
            let model = SnippetsAreaModel(session: AppSession(database: db))
            model.adopt(pools: pools, items: items)
            model.select(groupID: selected)
            return model
        }
    }

    /// **HER EXACT SHAPE.** Two groups — the seeded default, minted first,
    /// and the tutorial's, minted after — and the rail on "all snippets", so
    /// `activePool` is the default. A card in the tutorial's group opens the
    /// TUTORIAL's group, at the snippet clicked. The pre-fix answer (the
    /// active group, no landing) is asserted as the thing this is NOT, in
    /// the same test, so a revert cannot look like a pass.
    @Test func aCardsDoorNamesItsOwnGroupAndTheSnippetClicked() async throws {
        let seeded = pool("pool-default", "Pool", plus: 0)
        let tutorial = pool("pool-tutorial", TutorialSeeder.scrapPoolTitle, plus: 60)
        let mine = item("b-mine", pool: seeded.id, text: "a line of my own")
        let hers = item("b-hers", pool: tutorial.id, text: "a scrap: the harbor bell rang twice")
        let area = try await area(
            pools: [seeded, tutorial], items: [mine, hers], selected: nil)
        #expect(area.activePool?.id == seeded.id,
                "browsing all groups, the ACTIVE pool is the oldest — the seeded default")

        let target = SnippetOpenTarget.card(hers)
        #expect(target.poolID == tutorial.id,
                "the card opens ITS OWN group, not the one the rail happens to be showing")
        #expect(target.blockID == "b-hers", "…and lands on the snippet she clicked")
        #expect(target != SnippetOpenTarget(poolID: seeded.id, blockID: nil),
                "the pre-fix answer — the active group, no landing — is exactly what this is not")

        // A card in the group she IS browsing names the same group either
        // way; the landing is the difference that always mattered.
        #expect(SnippetOpenTarget.card(mine)
                == SnippetOpenTarget(poolID: seeded.id, blockID: "b-mine"))
    }

    /// The header's *open as editor* is a SCOPE door and keeps its meaning:
    /// the group being browsed, whole, landing nowhere in particular.
    @Test func theHeadersScopeDoorOpensTheGroupBeingBrowsedWithNoLanding() async throws {
        let seeded = pool("pool-default", "Pool", plus: 0)
        let tutorial = pool("pool-tutorial", TutorialSeeder.scrapPoolTitle, plus: 60)
        let browsingAll = try await area(
            pools: [seeded, tutorial], items: [], selected: nil)
        #expect(SnippetOpenTarget.group(try #require(browsingAll.activePool))
                == SnippetOpenTarget(poolID: seeded.id, blockID: nil))
        let browsingTutorial = try await area(
            pools: [seeded, tutorial], items: [], selected: tutorial.id)
        #expect(SnippetOpenTarget.group(try #require(browsingTutorial.activePool))
                == SnippetOpenTarget(poolID: tutorial.id, blockID: nil),
                "picking a group in the rail moves the scope door with it")
    }

    /// The copy half of row 38: the row names THE SNIPPET, never one
    /// particular container — the promise her report caught being broken.
    @Test func theOpenRowNamesTheSnippetAndNotAContainerItCannotPromise() {
        #expect(SnippetsCopy.openRow.localizedCaseInsensitiveContains("snippet"))
        #expect(!SnippetsCopy.openRow.contains("the Snippets editor"),
                "\u{201C}Open in the Snippets editor\u{201D} promised the one group it could not keep")
        // And the ruled vocabulary still holds over every string, the two
        // new ones included (the item-17 sweep's own rule).
        for string in SnippetsCopy.allStrings {
            #expect(!string.localizedCaseInsensitiveContains("pool"))
            #expect(!string.localizedCaseInsensitiveContains("scrap"))
        }
    }
}

// MARK: - The landing, end to end through the real editor

@Suite("Snippets — the editor lands on the snippet the door named (17o batch e, row 38)", .serialized)
@MainActor
struct SnippetsLandingTests {
    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private static func settle(
        _ window: NSWindow, _ hosting: NSView, timeout: TimeInterval = 8,
        until predicate: () -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if predicate() { return true }
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
        return predicate()
    }

    private static func views<V: NSView>(_ type: V.Type, in view: NSView) -> [V] {
        var found: [V] = []
        if let v = view as? V { found.append(v) }
        for sub in view.subviews { found.append(contentsOf: views(type, in: sub)) }
        return found
    }

    /// The ROAD the fixed card door hands its landing to: a group opened
    /// with a named snippet puts the caret at that snippet's start, and one
    /// opened WITHOUT (the header's scope door) does not — which is exactly
    /// what every card door did before this batch.
    @Test func openingAGroupAtANamedSnippetLandsTheCaretInIt() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let group = try session.operations.createPool(title: TutorialSeeder.scrapPoolTitle)
            var blocks: [String] = []
            for text in [
                "a scrap: the harbor bell rang twice for no ship anyone could see.",
                "a scrap with two takes — option-drag me and both come along.",
                "the third scrap, the one she right-clicked.",
            ] {
                blocks.append(try session.operations.newBlock(
                    in: group.id, text: text, at: .end).block.id)
            }
            let slots = try await db.read { [id = group.id] db in
                try Queries.renderPost(db, containerID: id)
            }
            let index = BlockRangeIndex(slots: slots, tail: nil)
            let thirdStart = index.range(ofEntryAt: 2).location
            #expect(thirdStart > 0, "the third snippet does not begin at the document's start")

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1000, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }

            // The CARD door's road: the group, at the snippet named.
            let landed = NSHostingView(
                rootView: PoolDetailView(
                    session: session, poolID: group.id, initialBlockID: blocks[2])
                    .environment(ThemeStore(session: session)))
            landed.frame = NSRect(x: 0, y: 0, width: 1000, height: 700)
            window.contentView = landed
            window.makeKeyAndOrderFront(nil)
            #expect(await Self.settle(window, landed) {
                guard let view = Self.views(EditorTextView.self, in: landed).first,
                      view.string.count >= index.documentLength else { return false }
                return view.selectedRange().location == thirdStart
            }, "the caret is inside the snippet the door named (wanted \(thirdStart))")

            // The HEADER door's road: the same group, no landing — the caret
            // does NOT sit in the third snippet. This is what she saw from
            // every card door before this batch.
            let bare = NSHostingView(
                rootView: PoolDetailView(session: session, poolID: group.id)
                    .environment(ThemeStore(session: session)))
            bare.frame = NSRect(x: 0, y: 0, width: 1000, height: 700)
            window.contentView = bare
            _ = await Self.settle(window, bare) {
                guard let view = Self.views(EditorTextView.self, in: bare).first else { return false }
                return view.string.count >= index.documentLength
            }
            let bareEditor = try #require(Self.views(EditorTextView.self, in: bare).first)
            #expect(bareEditor.selectedRange().location != thirdStart,
                    "the scope door lands nowhere in particular — that is its job")
        }
    }
}

// MARK: - The tag door's face (row 39)

@Suite("Snippets — the tag door, where the tag shows (17o batch e, row 39)")
@MainActor
struct SnippetTagDoorTests {
    /// The act is DECLARED by this surface (P-1's registry walk asserts the
    /// union), and the chip's own words exist, so the second face is a fact
    /// rather than a hope. That the chip IS a button is held by the walk —
    /// an `NSHostingView` exposes no accessibility children to a direct
    /// tree walk (the `MastheadTagDoorTests` finding, recorded there), so a
    /// SwiftUI `.plain` button inside a card cannot be counted from a test.
    @Test func theSurfaceDeclaresTheBlockTagActAndTheChipCarriesItsWords() {
        #expect(BlocksAreaView.surfaceCapabilities.contains(.tagBlock))
        #expect(CapabilityRegistry.capability(.tagBlock).doors.contains(.surface))
        #expect(SnippetsCopy.tagChipHelp.localizedCaseInsensitiveContains("tag"))
        #expect(SnippetsCopy.tagChipHelp.localizedCaseInsensitiveContains("click"),
                "the chip says it is a door")
    }

    /// **The walk's finding, pinned** (row 39's other half): with no snippet
    /// in the listing wearing a tag, the toolrow's tag FILTER offered exactly
    /// one row, "tag: any" — a tag-shaped control on a page with no visible
    /// way to tag anything, which is what her *"there's a tag on there"* was
    /// looking at (capture `walk-07`). The empty case names the real door.
    @Test func theTagFilterNamesTheDoorWhenNothingIsTagged() {
        #expect(SnippetFilter.tagPaths([]).isEmpty,
                "the empty listing is the case the menu now has words for")
        #expect(SnippetsCopy.tagNoneYet.localizedCaseInsensitiveContains("tag"))
        #expect(SnippetsCopy.tagNoneYet.localizedCaseInsensitiveContains("Tags\u{2026}"),
                "it names the door by the words on it")
        #expect(!SnippetsCopy.tagNoneYet.localizedCaseInsensitiveContains("pool"))
        #expect(!SnippetsCopy.tagNoneYet.localizedCaseInsensitiveContains("scrap"))
    }

    /// **Red-on-old, and the only genuinely old-failing string here:** the
    /// sheet the door opens told her to make a tag in "the sidebar's Tags
    /// section" — a room gone since R52 moved tag management into Settings.
    @Test func theSheetSendsHerWhereTagsActuallyLive() {
        #expect(!BlockTagCopy.noTagsYet.localizedCaseInsensitiveContains("sidebar"),
                "the sidebar has had no Tags section since R52")
        #expect(BlockTagCopy.noTagsYet.contains("Settings"))
    }
}
