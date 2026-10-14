//
//  MCPSharedRowsRulesTests.swift
//  VariorumTests (Mac)
//
//  VX-268 (RUN VX-281, U2) — the design rules beside the bug's pins
//  (`MCPSharedRowsTests` carries the red-first ones): the ONE icon's calm state
//  is NO view (a row nobody reaches gains neither width nor spacing — the ask
//  glyph's own rule, so every host writes it unguarded); a wing's ▾ menu row
//  carries ONE mark (a waiting ask outranks the shared icon — P-VX281-U2-1);
//  and P-1's declared ⇔ rendered: every new host declares the icon's three
//  acts, the menu (a mark, no door) declares none of them.
//
//  Design-class, written with the fix (these name API the seam did not have).
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-268 — the shared icon's calm state, the menu row's one mark, the declarations")
struct MCPSharedRowsRulesTests {
    private var reach: [MCPPlaceReach] {
        [MCPPlaceReach(
            client: MCPClient(
                id: "c1", name: "claude-code", version: "2", state: .approved,
                firstSeenAt: "2026-07-01T00:00:00.000Z", lastSeenAt: "2026-07-01T00:00:00.000Z",
                decidedAt: nil),
            rung: .read, grant: nil, throughTitle: nil)]
    }

    private func width<V: View>(_ view: V) -> CGFloat {
        NSHostingView(rootView: view).fittingSize.width
    }

    @Test func theCalmIconIsNoViewNeitherWidthNorSpacing() {
        for tokens in [VoiceTokens.terminalLight, VoiceTokens.studyLight] {
            let bare = width(HStack(spacing: 8) { Text("a"); Text("b") })
            let calm = width(HStack(spacing: 8) {
                Text("a"); MCPSharedIcon(reaches: [], tokens: tokens); Text("b")
            })
            let reached = width(HStack(spacing: 8) {
                Text("a"); MCPSharedIcon(reaches: reach, tokens: tokens); Text("b")
            })
            #expect(calm == bare, "nobody reaches it: no width, no spacing (\(calm) vs \(bare))")
            #expect(reached > bare + 8, "reached: the icon and its spacing (\(reached) vs \(bare))")
        }
    }

    @Test func aWingMenuRowCarriesOneMarkAndAWaitingAskOutranksTheSharedIcon() {
        #expect(WingSwitcherMenu.rowMark(asking: false, shared: false) == nil)
        #expect(WingSwitcherMenu.rowMark(asking: false, shared: true) == MCPSharedIcon.symbol)
        #expect(WingSwitcherMenu.rowMark(asking: true, shared: false) == MCPSharedIcon.pendingSymbol)
        #expect(WingSwitcherMenu.rowMark(asking: true, shared: true) == MCPSharedIcon.pendingSymbol)
    }

    @Test func everyNewHostDeclaresTheIconsActsAndTheMenuDeclaresNone() {
        let acts = Set(MCPSharedIcon.surfaceCapabilities)
        #expect(acts == [.mcpShowSharing, .mcpChangeGrant, .mcpRevokeGrant])
        // (name, declared, does the ask glyph sit there too — the parity hosts)
        let hosts: [(String, [CapabilityID], Bool)] = [
            ("LibraryCatalogView", LibraryCatalogView.surfaceCapabilities, true),
            ("PoolPostsView", PoolPostsView.surfaceCapabilities, true),
            ("BookPanelView", BookPanelView.surfaceCapabilities, true),
            ("WingSwitcherSheet", WingSwitcherSheet.surfaceCapabilities, true),
            // The Timeline is IN by the ticket's own naming, not by parity.
            ("TimelineView", TimelineView.surfaceCapabilities, false),
            // The two hosts the icon already had (13n-c U3) — unchanged.
            ("ShelfView", ShelfView.surfaceCapabilities, true),
            ("MCPNoteIndicator", MCPNoteIndicator.surfaceCapabilities, true),
        ]
        for (name, declared, parity) in hosts {
            #expect(acts.isSubset(of: Set(declared)), "\(name) renders the icon, so declares its acts")
            if parity {
                #expect(Set(declared).contains(.mcpOpenAsk), "\(name) — the ask glyph's host beside it")
            }
        }
        // The ▾ menu's row mark is no door (its press switches the wing).
        #expect(Set(WingSwitcherMenu.surfaceCapabilities).isDisjoint(with: acts))
    }
}
