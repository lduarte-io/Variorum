//
//  LibraryBulkRowGeometryTests.swift
//  VariorumTests (Mac)
//
//  The 13n-c UX-fix ladder's UXR1-3 (round 1, MINOR) — a GEOMETRY ORACLE
//  (W-UX-18's style): the Library's bulk row (W-UX-3) gave every door
//  `.fixedSize()`, so its minimum width was the SUM of its labels — about
//  714 pt in Terminal at 3 notes, past the list column at the app's own
//  1240-pt default window with the info panel open (≈80 pt over), and past
//  the walked 1380-pt window from 12 notes on: the T-1 panel push the row
//  was built to end, recurring. Every door must stay findable and wholly
//  worded at the default window with the panel open.
//

import AppKit
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("13n-c UXR1-3 — the bulk row fits the list column at the default window")
struct LibraryBulkRowGeometryTests {
    /// The bulk row's room at the app's `defaultSize` (1240 pt) with the info
    /// panel open: the window − the sidebar's ideal − its seam, then the
    /// panel's share of what is left − the panel's 1-pt divider, then the
    /// controls' 24-pt padding either side.
    static var room: CGFloat {
        let library = 1240 - CGFloat(ShellSplit<EmptyView, EmptyView>.idealWidth)
            - ShellSplit<EmptyView, EmptyView>.dividerWidth
        let list = library - LibraryPanelLayout.width(total: library) - 1
        return list - 2 * 24
    }

    private static func tag(_ path: String) -> VariorumCore.Tag {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        return VariorumCore.Tag(id: path, name: path, path: path, createdAt: now, updatedAt: now)
    }

    /// Every door the row can show (a worn tag ⇒ Untag; an approved client ⇒
    /// Share), in both voices, at a few notes and at many.
    @Test(arguments: [3, 12, 1000])
    func theRowFitsTheListColumnAtTheDefaultWindowWithThePanelOpen(count: Int) {
        let room = Self.room
        #expect(room > 500 && room < 700, "the room is the list column's (\(room) pt)")
        for voice in [ThemeVoice.terminal, .study] {
            let row = LibraryBulkRow(
                tokens: VoiceTokens.resolve(voice: voice, dark: false), count: count,
                tags: [Self.tag("life/goals")], worn: [Self.tag("life/goals")], canShare: true,
                onTag: { _ in }, onUntag: { _ in }, onShare: {}, onDelete: {})
            let size = NSHostingController(rootView: row)
                .sizeThatFits(in: CGSize(width: room, height: 10_000))
            #expect(size.width <= room,
                    "\(voice) at \(count) notes: the row takes \(size.width) pt of \(room) pt")
        }
    }
}
