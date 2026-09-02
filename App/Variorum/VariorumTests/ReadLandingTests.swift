//
//  ReadLandingTests.swift
//  VariorumTests
//
//  The Act 10 correction round, ladder round 1 — R1-3, PIN FIRST (the
//  guard's rule for a speculative finding): Read's two faces and the `▸ 01`
//  column land with `withAnimation { proxy.scrollTo(…) }` over a LazyVStack,
//  targeting an explicit `.id` that is not the ForEach identity — the two
//  mechanisms batch B retired in the book Outline (rows 9/12: an animated
//  scroll toward lazy estimates travels wrong; row 47: an explicit id on an
//  unbuilt lazy row is unknown to the reader). Whether SwiftUI folds a
//  direct-child `.id` into the lazy row's identity is exactly what B
//  measured only for the NESTED case, so this pin asks the note's own
//  surface: a 215-block note, the arrival at block 200 (the row-39 road —
//  Write's caret in block 200, then ⌘3), the block's frame CENTRED in the
//  host within the settle. RED ⇒ the book Index pane's form (identity =
//  anchor, no animation) goes on all three sites; GREEN ⇒ the finding is
//  hollow here and nothing changes (recorded either way).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Read's far-block landing (ladder R1-3, pin-first)", .serialized)
struct ReadLandingTests {
    /// A 215-block note: the Sherlock story's size (the landing class shows
    /// only where most rows are unrealized).
    static let blockCount = 215
    /// The block the arrival lands on — far below the first screenful.
    static let landingIndex = 199

    /// The host mounted at 1100 × 750 in the canvas rig's panel; the pane's
    /// vertical centre sits under the face bar — "centred" is the block's
    /// midY within this of the host's midY.
    static let centreTolerance: CGFloat = 130

    private func mounted(
        face: ReadModeView.Face,
        _ body: @escaping (ReadModeTests.World) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a long story")
            var blocks: [String] = []
            var variants: [String] = []
            for i in 0..<Self.blockCount {
                let minted = try session.operations.newBlock(
                    in: post.id,
                    text: "Paragraph \(i) of the long story. We were seated at breakfast one "
                        + "morning, my wife and I, when the maid brought in a telegram.")
                blocks.append(minted.block.id)
                variants.append(minted.variant.id)
            }
            ReadModeView.remember(face, postID: post.id)
            #if DEBUG
            ReadModeOracle.reset()
            #endif
            // The row-39 road: she was in block 200 (Write's caret), then ⌘3 —
            // the host ARRIVES on the current block, scrolling both faces and
            // the column to it.
            let router = session.commandRouter
            _ = router.registerDetail(postID: post.id, mode: .read) { _ in }
            router.noteFocusedBlock(
                blocks[Self.landingIndex], variantID: variants[Self.landingIndex], postID: post.id)
            let model = BlockTOCViewModel(session: session, postID: post.id)
            let window = NSPanel(
                contentRect: NSRect(x: 120, y: 120, width: 1100, height: 750),
                styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.isFloatingPanel = true
            window.becomesKeyOnlyIfNeeded = false
            window.hidesOnDeactivate = false
            let hosting = NSHostingView(rootView: AnyView(
                ReadModeView(session: session, postID: post.id, model: model)
                    .environment(ThemeStore(session: session))))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            let world = ReadModeTests.World(
                session: session, postID: post.id, blockIDs: blocks, variantIDs: variants,
                model: model, window: window, hosting: hosting)
            defer { world.close() }
            await world.poll { !model.rows.isEmpty && ReadModeOracle.selectedBlockID != nil }
            try await body(world)
        }
    }

    private func centred(_ frame: CGRect, in hosting: NSView) -> Bool {
        abs(frame.midY - hosting.bounds.midY) <= Self.centreTolerance
            && frame.minY >= 0 && frame.maxY <= hosting.bounds.height
    }

    /// `edit`: the arrival at block 200 of 215 lands the pane with THAT
    /// block centred (the `rep-<id>` target under `withAnimation`).
    @Test func theEditFaceLandsAFarBlockCentredOnArrival() async throws {
        try await mounted(face: .edit) { world in
            let target = world.blockIDs[Self.landingIndex]
            #expect(ReadModeOracle.selectedBlockID == target, "the arrival selected the current block")
            let landed = await world.poll(timeout: 8) {
                ReadModeOracle.editBlockFrames[target].map { centred($0, in: world.hosting) } ?? false
            }
            let frame = ReadModeOracle.editBlockFrames[target]
            print("[ladder R1-3] edit face: block 200's frame after the settle = \(String(describing: frame)) in a \(world.hosting.bounds.size) host; realized edit rows = \(ReadModeOracle.editBlockFrames.count)")
            #expect(landed, "block 200 sits centred in the pane after the arrival — frame \(String(describing: frame))")
        }
    }

    /// `read`: the same arrival lands the calm page on the block (the
    /// `rd-<id>` target under `withAnimation`, anchored near the top).
    @Test func theReadFaceLandsAFarBlockOnArrival() async throws {
        try await mounted(face: .read) { world in
            let target = world.blockIDs[Self.landingIndex]
            #expect(ReadModeOracle.face == .read)
            let landed = await world.poll(timeout: 8) {
                guard let frame = ReadModeOracle.pageBlockFrames[target] else { return false }
                // The page anchors the block at 8 % of the viewport: inside
                // the top third of the host, fully visible.
                return frame.minY >= 0 && frame.minY <= world.hosting.bounds.height / 3
            }
            let frame = ReadModeOracle.pageBlockFrames[target]
            print("[ladder R1-3] read face: block 200's frame after the settle = \(String(describing: frame)); realized page rows = \(ReadModeOracle.pageBlockFrames.count)")
            #expect(landed, "block 200 sits at the top third of the page after the arrival — frame \(String(describing: frame))")
        }
    }
}
