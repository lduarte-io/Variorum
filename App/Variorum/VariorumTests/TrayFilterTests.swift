//
//  TrayFilterTests.swift
//  VariorumTests
//
//  The use-report round, 18d batch 2 — **THIS NOTE'S TRAY, REORGANIZED**
//  (ledger row 34; her ruling U-9: *"you should be able to select if you want
//  to see leaving, if you want to see blocks or takes under leaving, and
//  separetly if you want to see archived (archived v. leaving should be top
//  level, with block or takes as a filter under each one"*; mockup figure D).
//
//  What this suite holds, in the brief's own order:
//    · the FILTER's pure rule over the tray's populations — the whole six-cell
//      matrix, and the identity that makes a count honest (a chip's number IS
//      the rows it renders, never a parallel sum);
//    · the CONTROL's words — the two tabs, the three chips, each explainer,
//      and the empty line of every cell, including the one cell that is empty
//      by construction;
//    · the FOLD is gone — over a REAL seeded store, a deleted take renders
//      beside the deleted block with nothing to open (**red on old**: the
//      fold was collapsed by default, so its `ForEach` was never built);
//    · the last view and filter, remembered for the session;
//    · the reveal opens on the view that holds the row it marks.
//
//  The Put back and Delete Now roads are NOT re-pinned here: this batch did
//  not touch them, and their suites (`NoteTrayTests`, `TrayPanelMoveTests`)
//  ride unmodified — which is itself part of the claim.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
// `@testable` for the ONE reason `JumpAndUndoTests` uses it: a listing row
// (`Queries.PreservedOriginal`) has no public init, and this suite's fixture
// is a VALUE — building it from a store would make a pure matrix pin a
// database test.
@testable import VariorumCore
@testable import Variorum

@MainActor
@Suite("This Note's Tray — the two views and the filter (18d batch 2, U-9)", .serialized)
struct TrayFilterTests {
    // MARK: - Fixtures

    private static func item(_ id: String, _ text: String) -> Queries.TrayItem {
        Queries.TrayItem(blockID: id, deletedAt: "2026-09-01T10:00:00.000Z", text: text)
    }

    private static func original(_ id: String) -> Queries.PreservedOriginal {
        Queries.PreservedOriginal(
            blockID: id, text: "the whole one",
            releasedAt: "2026-08-30T10:00:00.000Z", landAfterBlockID: nil)
    }

    private static func take(_ id: String) -> Queries.TrayTake {
        Queries.TrayTake(
            variantID: id, blockID: "b9", deletedAt: "2026-09-02T10:00:00.000Z",
            label: nil, text: "another way of saying it",
            blockName: nil, blockText: "The sea took the boat.")
    }

    /// One block deleted, one original stranded, two takes deleted, three
    /// blocks archived — every population non-empty and none the same size,
    /// so a rule that returned the wrong list would be caught by its count.
    private static let contents = TrayContents(
        deleted: [item("d1", "a deleted block")],
        stranded: [original("o1")],
        takes: [take("t1"), take("t2")],
        archived: [item("a1", "one"), item("a2", "two"), item("a3", "three")])

    // MARK: - The matrix (the filter's pure rule)

    /// **THE SIX CELLS.** Leaving holds three populations and the filter
    /// splits them the way her ruling names them: blocks (with the originals
    /// riding a family's countdown, which ARE blocks — figure D's caption)
    /// and takes. Archived holds blocks only; its takes cell is empty BY
    /// CONSTRUCTION, because an archived take lives among its block's
    /// archived takes and has never been the tray's to list.
    @Test func theFilterChoosesTheSameRowsTheTrayHasAlwaysHeld() {
        let c = Self.contents

        let leavingAll = TrayFilter.rows(c, view: .leaving, kind: .all)
        #expect(leavingAll.blocks.map(\.blockID) == ["d1"])
        #expect(leavingAll.stranded.map(\.blockID) == ["o1"])
        #expect(leavingAll.takes.map(\.variantID) == ["t1", "t2"])

        let leavingBlocks = TrayFilter.rows(c, view: .leaving, kind: .blocks)
        #expect(leavingBlocks.blocks.map(\.blockID) == ["d1"])
        #expect(leavingBlocks.stranded.map(\.blockID) == ["o1"],
                "an original riding a family's countdown is a BLOCK and filters here")
        #expect(leavingBlocks.takes.isEmpty)

        let leavingTakes = TrayFilter.rows(c, view: .leaving, kind: .takes)
        #expect(leavingTakes.takes.map(\.variantID) == ["t1", "t2"])
        #expect(leavingTakes.blocks.isEmpty && leavingTakes.stranded.isEmpty)

        for kind in [TrayKind.all, .blocks] {
            let archived = TrayFilter.rows(c, view: .archived, kind: kind)
            #expect(archived.blocks.map(\.blockID) == ["a1", "a2", "a3"])
            #expect(archived.stranded.isEmpty,
                    "a stranded original is on a clock — never in the kept view")
            #expect(archived.takes.isEmpty)
        }
        #expect(TrayFilter.rows(c, view: .archived, kind: .takes).isEmpty,
                "takes are never archived HERE — the cell says where they live")

        // Nothing at all: every cell is empty, and nothing throws on the way.
        for view in TrayView.allCases {
            for kind in TrayKind.allCases {
                #expect(TrayFilter.rows(TrayContents(), view: view, kind: kind).isEmpty)
            }
        }
    }

    /// **THE COUNTS ARE THE ROWS.** A chip's number is DEFINED as the rows
    /// that chip renders, and a tab's is its own `all` cell — so a control
    /// can never advertise a size the list does not hold (the fold that hid
    /// its own size, one defect up).
    @Test func everyCountIsExactlyWhatItsCellRenders() {
        let c = Self.contents
        for view in TrayView.allCases {
            for kind in TrayKind.allCases {
                #expect(TrayFilter.count(c, view: view, kind: kind)
                    == TrayFilter.rows(c, view: view, kind: kind).total)
            }
            #expect(TrayFilter.count(c, view: view)
                == TrayFilter.count(c, view: view, kind: .all))
        }
        #expect(TrayFilter.count(c, view: .leaving) == 4, "1 block + 1 original + 2 takes")
        #expect(TrayFilter.count(c, view: .archived) == 3)
        #expect(TrayFilter.count(c, view: .leaving, kind: .blocks) == 2)
        #expect(TrayFilter.count(c, view: .leaving, kind: .takes) == 2)
        #expect(TrayFilter.count(c, view: .archived, kind: .takes) == 0)
        // A view's count is the sum of its two kind cells — the filter
        // narrows the list, never the view's size.
        for view in TrayView.allCases {
            #expect(TrayFilter.count(c, view: view)
                == TrayFilter.count(c, view: view, kind: .blocks)
                    + TrayFilter.count(c, view: view, kind: .takes))
        }
    }

    // MARK: - The control's words

    /// The two tabs, the three chips, the two explainers and every empty
    /// line — the whole control as values, so the mockup's grammar is
    /// checkable without a window.
    @Test func theControlSaysWhatFigureDSays() {
        #expect(TrayFilterFace.tab(.leaving) == "Leaving")
        #expect(TrayFilterFace.tab(.archived) == "Archived")

        // `all` never carries a count (the tab above it does); a kind chip
        // carries its own only when it has one — exactly how figure D draws
        // the empty view.
        #expect(TrayFilterFace.chip(.all, count: 7) == "all")
        #expect(TrayFilterFace.chip(.blocks, count: 1) == "blocks \u{B7} 1")
        #expect(TrayFilterFace.chip(.takes, count: 6) == "takes \u{B7} 6")
        #expect(TrayFilterFace.chip(.blocks, count: 0) == "blocks")
        #expect(TrayFilterFace.chip(.takes, count: 0) == "takes")

        // One line per view — the clock in one, its absence in the other.
        #expect(TrayFilterFace.explainer(.leaving, home: .post)
            .contains("\(TrashWindow.days)-day"))
        #expect(TrayFilterFace.explainer(.leaving, home: .post)
            .contains(RecoveryCopy.deleteNowVerb))
        #expect(TrayFilterFace.explainer(.archived, home: .post).contains("no clock"))
        // The home's own noun, both views (13l row 26's rule).
        #expect(TrayFilterFace.explainer(.leaving, home: .pool)
            != TrayFilterFace.explainer(.leaving, home: .post))
        #expect(TrayFilterFace.explainer(.archived, home: .pool)
            != TrayFilterFace.explainer(.archived, home: .post))

        // Every cell's empty line is DISTINCT and names its own filter: "the
        // note has nothing on the clock" under a takes-only filter would be a
        // lie told by a control she set herself.
        var lines: Set<String> = []
        for view in TrayView.allCases {
            for kind in TrayKind.allCases {
                lines.insert(TrayFilterFace.nothing(view: view, kind: kind, home: .post))
            }
        }
        #expect(lines.count == 6)
        #expect(TrayFilterFace.nothing(view: .leaving, kind: .takes, home: .post)
            .lowercased().contains("takes"))
        #expect(TrayFilterFace.nothing(view: .archived, kind: .blocks, home: .post)
            .lowercased().contains("blocks"))
        // The cell that is empty by construction says where they DO live.
        #expect(TrayFilterFace.nothing(view: .archived, kind: .takes, home: .post)
            .contains(BlockHistoryPath.name))

        // The kind labels every card wears.
        #expect(TrayFilterFace.blockKind == "block")
        #expect(TrayFilterFace.originalKind == "original")
        #expect(TrayFilterFace.takeKind(Self.take("t1"))
            == "take \u{B7} in The sea took the boat.",
                "a take names its block through the ONE block-naming rule")
    }

    /// **THE THREE CONSTANTS THE PHONE STILL CONSUMES** (18d's round-1
    /// ladder, MINOR-4). The Mac retired all three at this batch — the two
    /// section headers became the segmented choice's two words, the fold's
    /// label became the `takes` chip's count — and deleting them from the
    /// SHARED copy home would have broken the next `main` → `mobile` pull in
    /// four places, which `iOS BUILD SUCCEEDED` on `main` cannot see because
    /// the file that consumes them (`VariorumMobile/Features/Write/
    /// MobileNoteTray.swift`) does not exist on this branch.
    ///
    /// So this pin is the guard the compiler cannot be here: the three keep
    /// their exact words until the phone's tray is reorganized to U-9's
    /// shape, and that session removes them with its own last call site.
    @Test func theRetiredSectionWordsStayForThePhonesTray() {
        #expect(RecoveryCopy.trayArchivedSection == "Archived \u{2014} kept, no clock")
        #expect(RecoveryCopy.trayLeavingSection
            == "Leaving \u{2014} on the \(TrashWindow.days)-day clock")
        #expect(RecoveryCopy.trayTakesDisclosure(1) == "1 deleted take")
        #expect(RecoveryCopy.trayTakesDisclosure(3) == "3 deleted takes")
        // …and the MAC's own control does not speak them: the two views are
        // the tab words, and the fold is gone from this app.
        #expect(TrayFilterFace.tab(.archived) != RecoveryCopy.trayArchivedSection)
        #expect(TrayFilterFace.tab(.leaving) != RecoveryCopy.trayLeavingSection)
    }

    // MARK: - The reveal

    /// A mark under the other tab is a mark she cannot see: the panel opens
    /// on the view that HOLDS the revealed row.
    @Test func theRevealNamesTheViewThatHoldsIt() {
        let c = Self.contents
        #expect(TrayFilter.viewHolding("d1", in: c) == .leaving)
        #expect(TrayFilter.viewHolding("o1", in: c) == .leaving)
        #expect(TrayFilter.viewHolding("a2", in: c) == .archived)
        #expect(TrayFilter.viewHolding("nobody", in: c) == nil,
                "…and nil is the case `revealMissing` already words")
    }

    /// **A REVEAL IS A LANDING, NOT A CHOICE** (18d's round-1 ladder, NIT-2).
    ///
    /// The panel opens on the view that HOLDS the revealed row — a mark under
    /// the other tab is a mark she cannot see — but that landing must not
    /// become the session's remembered pair. §5.4's line is *"the last view
    /// and filter"*, which is HER choice; a lineage door's receipt writing it
    /// would make the next unrelated ⌫ press open wherever the last reveal
    /// sent her.
    ///
    /// **Red on the pre-fix code:** the reveal arm called `select(view:)` /
    /// `select(kind:)`, both of which `remember()` — so the third arm below
    /// found `.archived · all` where she had left `.leaving · blocks`.
    @Test func aRevealLandsWithoutBecomingTheRememberedView() async throws {
        try await withEditor(seedBlocks: ["one"]) { h in
            // What she chose, this session.
            let chooser = TrayViewModel(session: h.session, postID: h.postID)
            chooser.select(view: .leaving)
            chooser.select(kind: .blocks)

            // A lineage door reveals a block that lives under the OTHER tab.
            let revealed = TrayViewModel(
                session: h.session, postID: h.postID, revealBlockID: "archived-1")
            revealed.adopt(TrayViewModel.Snapshot(
                archived: [Queries.TrayItem(
                    blockID: "archived-1", deletedAt: "2026-09-01T10:00:00.000Z",
                    text: "the archived one")]))
            #expect(revealed.view == .archived && revealed.kind == .all,
                    "the panel opens where the marked row actually is")

            // …and the session still holds what SHE chose.
            #expect(h.session.trayViewMemory == TrayViewMemory(view: .leaving, kind: .blocks))
            let next = TrayViewModel(session: h.session, postID: h.postID)
            #expect(next.view == .leaving && next.kind == .blocks,
                    "the next ⌫ press opens where she left it, not where a receipt sent her")
        }
    }

    // MARK: - Over the real panel

    /// **THE FOLD IS GONE** (red on old), the takes filter narrows to them,
    /// and the archived block is under the other tab.
    ///
    /// **Red on old, exactly:** the shipped panel put every deleted take
    /// behind a `▸ N deleted takes` disclosure that was COLLAPSED by default,
    /// so its `ForEach` was never built and the take's own text was nowhere
    /// in the panel's tree. Here it renders beside the deleted block with
    /// nothing to open.
    @Test func theFoldIsGoneAndTheTakesRenderWithTheBlocks() async throws {
        try await withEditor(seedBlocks: [
            "A deleted block's preview", "An archived block's preview",
            "The take's own words",
        ]) { h in
            let slots = try h.storeSlots()
            try await h.session.runner.run { (ops: Operations) in
                try ops.deleteBlock(slots[0].blockID)
                try ops.archiveBlock(slots[1].blockID)
                let spare = try ops.branchVariant(
                    slots[2].blockID, from: slots[2].variantID ?? "")
                try ops.deleteVariant(spare.id)
            }
            let model = TrayViewModel(session: h.session, postID: h.postID)
            let panel = TrayPanel(session: h.session, postID: h.postID, model: model)
            await SurfaceComposition.host(panel, size: NSSize(width: 300, height: 640))
            #expect(model.deleted.count == 1 && model.archived.count == 1
                && model.takes.count == 1, "the fixture landed")

            // The default cell — Leaving · all — holds the block AND the
            // take, with nothing folded.
            #expect(model.view == .leaving && model.kind == .all)
            #expect(model.count(of: .leaving) == 2 && model.count(of: .archived) == 1)
            #expect(model.count(of: .blocks) == 1 && model.count(of: .takes) == 1)
            var shown = SurfaceComposition.text(of: panel.body)
            #expect(SurfaceComposition.carries("A deleted block's preview", in: shown))
            #expect(SurfaceComposition.carries("The take's own words", in: shown),
                    "RED ON OLD: the take sat behind a collapsed fold")
            #expect(!shown.contains("DisclosureGroup"))

            // takes only: the block goes, the take stays.
            model.select(kind: .takes)
            shown = SurfaceComposition.text(of: panel.body)
            #expect(!SurfaceComposition.carries("A deleted block's preview", in: shown))
            #expect(SurfaceComposition.carries("The take's own words", in: shown))

            // blocks only: the mirror.
            model.select(kind: .blocks)
            shown = SurfaceComposition.text(of: panel.body)
            #expect(SurfaceComposition.carries("A deleted block's preview", in: shown))
            #expect(!SurfaceComposition.carries("The take's own words", in: shown))

            // The archived block is under the OTHER tab, never beside them.
            model.select(view: .archived)
            model.select(kind: .all)
            shown = SurfaceComposition.text(of: panel.body)
            #expect(SurfaceComposition.carries("An archived block's preview", in: shown))
            #expect(!SurfaceComposition.carries("A deleted block's preview", in: shown))
            #expect(!SurfaceComposition.carries("The take's own words", in: shown))
        }
    }

    /// **THE LAST VIEW AND FILTER, PER SESSION.** A second panel over the
    /// same session opens where she left the first — and a fresh session
    /// opens on Leaving · all, so a launch never greets her with a filtered
    /// panel she cannot remember setting.
    @Test func theLastViewAndFilterAreRememberedForTheSession() async throws {
        try await withEditor(seedBlocks: ["One"]) { h in
            let first = TrayViewModel(session: h.session, postID: h.postID)
            #expect(first.view == .leaving && first.kind == .all, "the default cell")
            first.select(view: .archived)
            first.select(kind: .takes)

            let second = TrayViewModel(session: h.session, postID: h.postID)
            #expect(second.view == .archived && second.kind == .takes)

            // A second note in the SAME session inherits it too: the choice
            // is about how she is reading the tray, not about one note.
            let other = TrayViewModel(session: h.session, postID: "another-note")
            #expect(other.view == .archived && other.kind == .takes)

            // A fresh session is a fresh launch.
            #expect(TrayViewMemory() == TrayViewMemory(view: .leaving, kind: .all))
        }
    }
}
