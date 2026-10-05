//
//  NoteTagsRowHoverTests.swift
//  VariorumTests
//
//  **17y B1 (k) — the Cards view's quiet tag row never loops under a resting
//  pointer** (found by the B1 walk; PRE-EXISTING since 13e E8). With the
//  pointer resting on an untagged card's chip row the app ran at 100 % CPU
//  forever — measured on the pre-fix Debug build and on the first B1 build
//  alike: the quiet state's room spans the row, the revealed `＋` is narrow,
//  so revealing moved the pointer OUT of the hovered view, which hid the `＋`
//  and put the pointer back IN. The pin: the hover region is ONE rectangle in
//  both states — the row's width, the reserved height.
//
//  No compiling red-on-old form (the state could not be seeded before this
//  batch's `initiallyHovering`); the red is the record's measurement — 99.7 /
//  100.0 % CPU on the pre-fix build with the pointer resting there.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("17y B1 (k) — the quiet tag row's hover region is one rectangle", .serialized)
struct NoteTagsRowHoverTests {
    private func region(revealed: Bool) async throws -> CGRect {
        #if DEBUG
        NoteTagsRowProbe.hoverRegions = [:]
        #endif
        let window = NSWindow(
            contentRect: NSRect(x: 40, y: 40, width: 600, height: 80),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: AnyView(
            NoteTagsRow(
                tokens: .fallback(for: .light), tags: [], allTags: [],
                onApply: { _ in }, onRemove: { _ in }, revealsOnHover: true,
                initiallyHovering: revealed)
            .padding(10)))
        hosting.frame = NSRect(x: 0, y: 0, width: 600, height: 80)
        window.contentView = hosting
        window.orderFront(nil)
        defer { window.orderOut(nil); window.close() }
        for _ in 0..<8 {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(15))
        }
        #if DEBUG
        return try #require(NoteTagsRowProbe.hoverRegions[revealed])
        #else
        return .zero
        #endif
    }

    @Test func theQuietAndTheRevealedRowTrackOneRegion() async throws {
        let quiet = try await region(revealed: false)
        let revealed = try await region(revealed: true)
        #expect(abs(quiet.width - revealed.width) <= 0.5,
                "quiet \(quiet) vs revealed \(revealed): a reveal must not move the pointer out")
        #expect(abs(quiet.height - revealed.height) <= 0.5,
                "quiet \(quiet) vs revealed \(revealed)")
        #expect(quiet.width >= 570, "the region is the row's width (\(quiet.width))")
    }
}
