//
//  ReadFlowHoverHintTests.swift
//  VariorumTests
//
//  VX-142 (the VX-143 run) — her report: *"hovering with the cursor needs to
//  not keep showing hints in read mode on a book - covers the text any time
//  your cursor is over it."*
//
//  THE MECHANISM (traced in the run record): `FlowPostView` — the WHOLE of a
//  note's prose in the book's Read flow — carried `.help(entry.displayTitle)`,
//  a system tooltip that drops the note's title under the cursor wherever it
//  rests on the text, and again after every move. The paged form carries
//  `.help` only on its flip bar, never over prose.
//
//  Read through the composition (the `SurfaceComposition` road — see
//  `ProtectionSurfaceRenderTests`' header for why `dump` and not the AX tree):
//  the post's prose is not loaded yet at construction (its `.task` reads it),
//  so the ONLY place the note's title can appear in the view's composition is
//  a hint attached to it. RED ON OLD: the tooltip carried the title.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("A book's Read flow keeps hints off the prose (VX-142)", .serialized)
struct ReadFlowHoverHintTests {
    /// ASCII on purpose: `dump` escapes non-ASCII, and a sentinel nothing
    /// else in the view could ever say.
    static let sentinelTitle = "VX142 sentinel note title"

    @Test func theFlowsProseCarriesNoHoverHint() async throws {
        let db = try AppDatabase.inMemory()
        let session = AppSession(database: db)
        let entry = Queries.ReadingEntry(
            postID: "vx142-post", title: Self.sentinelTitle,
            entryDate: nil, sectionPath: nil)
        #expect(entry.displayTitle == Self.sentinelTitle, "the fixture's title reaches the display brain")
        let post = FlowPostView(
            session: session, entry: entry, page: .light,
            onWake: { _ in }, onLoaded: { _ in })
        await SurfaceComposition.host(post, size: NSSize(width: 680, height: 400))
        let composed = SurfaceComposition.text(of: post.body)
        #expect(!SurfaceComposition.carries(Self.sentinelTitle, in: composed),
                "the note's prose carries a hover hint naming the note — the tooltip that covers the text")
    }
}
