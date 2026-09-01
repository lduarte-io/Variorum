//
//  TrayPanelShapeTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 1, item 1 — **This Note's Tray: the clipped section
//  header.** Her screenshot showed the Leaving section's header rendered as
//  a struck-through sliver under a divider, its explainer clipped with it.
//
//  ── THE TRACED CLASS ─────────────────────────────────────────────────────
//  The panel was a plain macOS `List`, and its Leaving section's header was
//  a VStack carrying a title AND a multi-line explainer. A plain List
//  measures section headers at a fixed height, so the taller header drew
//  clipped — only its bottom sliver survived, exactly her screenshot. (The
//  b6dae25 chrome family: text whose container is measured somewhere other
//  than where it renders.)
//
//  The rebuild retires the List for a ScrollView of calm cards (the W8-2
//  mockup grammar); headers are ordinary stacked views, so the measuring
//  mechanism is GONE, not patched. This pin holds both halves:
//  **red on old** — the old body reflected `List`; the new one must not —
//  and the full composition (both headers, the explainer, every row kind)
//  must be present over a REAL seeded store, so a regression that re-lists
//  the panel or drops a section announces itself.
//

import AppKit
import Dependencies
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("This Note's Tray — shape (Act 10 item 1)", .serialized)
struct TrayPanelShapeTests {
    /// The whole composition, at the inspector's own narrow width — and the
    /// List's absence (red on old).
    @Test func everySectionRendersUnclippedComposition() async throws {
        try await withEditor(seedBlocks: [
            "A deleted block's preview", "An archived block's preview",
            "The block that stays",
        ]) { h in
            // Seed the tray's three populations through the real ops: a
            // deleted block, an archived block, and a deleted TAKE on the
            // surviving block.
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
            // Host in a real window: the live observation loads the seeded
            // rows, and a panel that cannot lay out fails here.
            await SurfaceComposition.host(panel, size: NSSize(width: 300, height: 640))
            #expect(!model.isEmpty, "the fixture landed")
            #expect(model.deleted.count == 1)
            #expect(model.archived.count == 1)
            #expect(model.takes.count == 1)

            let shown = SurfaceComposition.text(of: panel.body)

            // Both section headers AND the Leaving explainer are in the tree.
            #expect(SurfaceComposition.carries(TrayPath.leavingSection, in: shown))
            #expect(SurfaceComposition.carries(TrayPath.archivedSection, in: shown))
            #expect(SurfaceComposition.carries(
                RecoveryCopy.trayLeavingExplainer(.post), in: shown))

            // Every row kind renders: a deleted block, an archived block,
            // the takes fold with its count.
            #expect(SurfaceComposition.carries("A deleted block's preview", in: shown))
            #expect(SurfaceComposition.carries("An archived block's preview", in: shown))
            #expect(SurfaceComposition.carries(
                RecoveryCopy.trayTakesDisclosure(1), in: shown))

            // RED ON OLD: the panel was a `List`, whose fixed header-height
            // measurement is the traced clipping mechanism. The rebuild must
            // not reintroduce one.
            #expect(!shown.contains("List<"), "the tray must not be a List again")
            #expect(shown.contains("ScrollView"), "the calm-card scroll rebuild")

            // Row 64 (the correction round): the takes fold's WHOLE line is
            // the toggle — a DisclosureGroup toggles only on its chevron,
            // and the walk clicked its label to no effect. RED ON OLD: the
            // fold was a DisclosureGroup.
            #expect(!shown.contains("DisclosureGroup"),
                    "the takes fold is a full-line Button, not a chevron-only DisclosureGroup")
        }
    }
}
