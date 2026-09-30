//
//  TrayArchivedTruncationTests.swift
//  VariorumTests
//
//  18o U1 — 17e P37: **the tray's ARCHIVED listing said nothing when its
//  window cut it.** All four arms of `TrayViewModel.start` fetch with the
//  standing probe row (`limit: window + 1`), and `adopt` flagged two of them —
//  the deleted blocks (`deletedTruncated`) and the deleted takes
//  (`TrashListing.windowed`) — each rendered as a `truncation(…)` line. The
//  archived arm took `prefix(window)` and threw the probe row away, so a note
//  holding more than 500 archived blocks showed exactly 500 with nothing
//  saying more exist — on a recovery surface whose whole job is to audit what
//  a note has set aside. KnownIssues' standing rule: *"Bounded view windows
//  show markers, not more"* (probe-row `+1`, so an exact window never
//  false-positives).
//
//  The pins read the panel's COMPOSITION (`SurfaceComposition` — a `Text`
//  composed, not proven visible; that road's recorded limit) over a snapshot
//  handed to the model's own `adopt` seam, so nothing here waits on an
//  observation's timing. The marker goes through `tokens.chromeLabel`, whose
//  casing follows the voice — so the match ignores case.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The tray's archived window marker (18o U1 — 17e P37)")
struct TrayArchivedTruncationTests {
    private static func items(_ count: Int) -> [Queries.TrayItem] {
        (0..<count).map {
            Queries.TrayItem(
                blockID: "archived-\($0)", deletedAt: "2026-09-01T00:00:00.000Z",
                text: "archived block \($0)")
        }
    }

    private static func composition(_ model: TrayViewModel, _ editor: EditorHarness) -> String {
        let panel = TrayPanel(session: editor.session, postID: editor.postID, model: model)
        return SurfaceComposition.text(of: panel.body).lowercased()
    }

    /// **RED ON OLD:** one row past the window, the archived view lists the
    /// window and SAYS so.
    @Test func theArchivedViewSaysWhenItsWindowCutsTheListing() async throws {
        try await withEditor(seedBlocks: ["Alpha."]) { editor in
            let model = TrayViewModel(session: editor.session, postID: editor.postID)
            model.select(view: .archived)
            model.adopt(TrayViewModel.Snapshot(archived: Self.items(TrayViewModel.window + 1)))
            #expect(model.archived.count == TrayViewModel.window,
                    "the probe row is never listed")

            let shown = Self.composition(model, editor)
            // A Bool first, so a red reads as one line rather than the dump.
            let marked = shown.contains("showing the \(TrayViewModel.window) most recently archived")
            #expect(marked, "a cut listing carries its marker, like its siblings")
        }
    }

    // MARK: - Guards (green on both trees)

    /// Exactly the window is not a truncation — the probe row's whole point.
    @Test func anExactWindowOfArchivedBlocksCarriesNoMarker() async throws {
        try await withEditor(seedBlocks: ["Alpha."]) { editor in
            let model = TrayViewModel(session: editor.session, postID: editor.postID)
            model.select(view: .archived)
            model.adopt(TrayViewModel.Snapshot(archived: Self.items(TrayViewModel.window)))
            #expect(model.archived.count == TrayViewModel.window)
            let marked = Self.composition(model, editor).contains("most recently archived")
            #expect(!marked, "an exact window is not a truncation")
        }
    }

    /// The sibling marker the archived arm now matches: the Leaving view's
    /// deleted blocks, one past the window — and the archived marker never
    /// leaks into the other view.
    @Test func theLeavingViewKeepsItsOwnMarkerAndNeverTheArchivedOne() async throws {
        try await withEditor(seedBlocks: ["Alpha."]) { editor in
            let model = TrayViewModel(session: editor.session, postID: editor.postID)
            model.select(view: .leaving)
            model.adopt(TrayViewModel.Snapshot(
                deleted: Self.items(TrayViewModel.window + 1),
                archived: Self.items(TrayViewModel.window + 1)))
            let shown = Self.composition(model, editor)
            let deletedMarked = shown.contains(
                "showing the \(TrayViewModel.window) most recently deleted")
            let archivedMarked = shown.contains("most recently archived")
            #expect(deletedMarked, "the Leaving view's own marker stands")
            #expect(!archivedMarked, "each view speaks only for its own listing")
        }
    }
}
