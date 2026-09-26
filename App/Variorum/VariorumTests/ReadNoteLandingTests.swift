//
//  ReadNoteLandingTests.swift
//  VariorumTests
//
//  **18l UNIT U1 — note Read adopts the 13u4-F3 landing shape** (the health
//  review §1.2's diagnosis, verbatim: *"Note Read mode: a one-shot aim against
//  SwiftUI's lazy estimate with no second look — the target is nil'd
//  immediately, the lazy column re-realizes under the landed offset, SwiftUI
//  re-applies the pixel offset, and nothing re-aims. Same note + same width ⇒
//  same estimate error ⇒ the identical jump every time."*).
//
//  PIN FIRST (the round's standing rule): these were written and run against
//  the PRE-FIX tree before a line of the fix. The fixture is the class's own
//  shape rather than a uniform note — a Sherlock-like story whose opening is
//  short dialogue lines and whose body is long narrative paragraphs, so the
//  lazy column's estimate for the rows it has not realized (the average of
//  the ones it has) is WRONG, exactly as it is on her long notes. (A note of
//  215 identical paragraphs — `ReadLandingTests`' fixture — makes the average
//  exact and hides the class; that is why those pins stayed green.)
//
//  What each face owes, stated as her screen: the landed block rests at the
//  face's SHIPPED anchor — the page at 0.08 of the viewport, the edit face
//  centred (`ReadPageColumn.restingAnchor`, `ReadEditPane.restingAnchor`;
//  where a landing puts a block is product, and this unit keeps both) — and it
//  STAYS there: sampled once the landing has had time to settle and again a
//  second and a half later.
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
@Suite("Note Read's far landing arrives at its anchor and holds (18l U1)", .serialized)
struct ReadNoteLandingTests {
    /// The story's shape: `shortOpening` lines of dialogue, then long
    /// narrative paragraphs of varied length (the Sherlock stories' own mix —
    /// 211 of *Copper Beeches*' 212 blocks end in a newline, and so do these).
    static let blockCount = 260
    static let shortOpening = 40
    /// The block the arrival lands on — far below the first screenful.
    static let landingIndex = 200
    /// Within this many points of its resting place a landed block is where
    /// she was taken (the authority's own tolerance plus a point of slack).
    static let restTolerance: CGFloat = 3

    static let narrative = "We were seated at breakfast one morning, my wife and I, when the "
        + "maid brought in a telegram. It was from Sherlock Holmes and ran in this way. "
    static let dialogue = "“Quite so,” said he."

    /// Block `i`'s text — deterministic, varied, ending in a newline.
    static func text(_ i: Int) -> String {
        if i < shortOpening { return "\(dialogue) (\(i))\n" }
        // 1…9 sentences in a fixed irregular walk, so neighbouring rows differ.
        let sentences = [3, 7, 1, 5, 9, 2, 6, 4, 8, 1, 5][i % 11]
        return "Paragraph \(i). " + String(repeating: narrative, count: sentences) + "\n"
    }

    private func mounted(
        face: ReadModeView.Face,
        _ body: @escaping (ReadModeTests.World) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 41))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a scandal in bohemia")
            var blocks: [String] = []
            var variants: [String] = []
            for i in 0..<Self.blockCount {
                let minted = try session.operations.newBlock(in: post.id, text: Self.text(i))
                blocks.append(minted.block.id)
                variants.append(minted.variant.id)
            }
            ReadModeView.remember(face, postID: post.id)
            #if DEBUG
            ReadModeOracle.reset()
            #endif
            // The row-39 road (`ReadLandingTests`' own): she was in block 201
            // elsewhere, then ⌘3 — the host ARRIVES on the current block and
            // lands both faces on it. A place reported after the registration
            // is not the note's opening (R-18l-1), so it lands by the standing
            // rules — the coldest landing there is: nothing below the first
            // screenful has ever been drawn.
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

    /// Where the landed block sits against where its face's anchor puts it:
    /// the block's `anchor`-point at the viewport's `anchor`-point
    /// (`ViewportCarry`'s definition, which IS `scrollTo(_:anchor:)`'s). 0 is
    /// home; positive is below it.
    static func residual(block: CGRect, face: CGRect, anchor: CGFloat) -> CGFloat {
        let rest = face.minY + CGFloat(ViewportCarry.topInset(
            fraction: Double(anchor), blockHeight: Double(block.height),
            viewportHeight: Double(face.height)))
        return block.minY - rest
    }

    private func settledResidual(
        _ world: ReadModeTests.World, frames: () -> [String: CGRect], anchor: CGFloat
    ) async -> (first: CGFloat?, second: CGFloat?) {
        let target = world.blockIDs[Self.landingIndex]
        await world.poll(timeout: 8) { frames()[target] != nil }
        // The landing's own time to settle (the authority's hold is a second;
        // a correction adds one more), then a look — and another later, so a
        // landing that arrives and then slides is caught.
        _ = await world.poll(timeout: 3) { false }
        let first = frames()[target].flatMap { block in
            ReadModeOracle.faceFrames[world.postID].map {
                Self.residual(block: block, face: $0, anchor: anchor)
            }
        }
        _ = await world.poll(timeout: 1.5) { false }
        let second = frames()[target].flatMap { block in
            ReadModeOracle.faceFrames[world.postID].map {
                Self.residual(block: block, face: $0, anchor: anchor)
            }
        }
        // What the face actually drew, for the record: the realized rows by
        // their place in the note, and the ones inside the viewport.
        let face = ReadModeOracle.faceFrames[world.postID] ?? .zero
        let drawn = frames()
        let indices = world.blockIDs.indices.filter { drawn[world.blockIDs[$0]] != nil }
        let onScreen = indices.filter { i in
            drawn[world.blockIDs[i]].map { $0.maxY > face.minY && $0.minY < face.maxY } ?? false
        }
        print("[18l U1] realized rows \(indices.first.map { $0 + 1 } ?? -1)…"
            + "\(indices.last.map { $0 + 1 } ?? -1) (\(indices.count)); on screen "
            + "\(onScreen.map { $0 + 1 }); face \(face)")
        return (first, second)
    }

    /// **`edit`: the far block lands CENTRED, and stays.**
    @Test func theEditFaceLandsAColdFarBlockCentredAndItStays() async throws {
        try await mounted(face: .edit) { world in
            let (first, second) = await settledResidual(
                world, frames: { ReadModeOracle.editBlockFrames }, anchor: 0.5)
            print("[18l U1] edit face: block \(Self.landingIndex + 1)'s distance from centre "
                + "= \(String(describing: first)) then \(String(describing: second)) pt")
            let a = try #require(first, "the landed block drew")
            let b = try #require(second)
            #expect(abs(a) <= Self.restTolerance,
                    "the landing arrived at the centre — it is \(a) pt away")
            #expect(abs(b) <= Self.restTolerance,
                    "…and it is still there 1.5 s later — \(b) pt away")
        }
    }

    /// **`read`: the far block lands at 0.08 of the page, and stays.**
    @Test func theReadFaceLandsAColdFarBlockAtItsAnchorAndItStays() async throws {
        try await mounted(face: .read) { world in
            let (first, second) = await settledResidual(
                world, frames: { ReadModeOracle.pageBlockFrames }, anchor: 0.08)
            print("[18l U1] read face: block \(Self.landingIndex + 1)'s distance from its "
                + "anchor = \(String(describing: first)) then \(String(describing: second)) pt")
            let a = try #require(first, "the landed block drew")
            let b = try #require(second)
            #expect(abs(a) <= Self.restTolerance,
                    "the landing arrived at the page's anchor — it is \(a) pt away")
            #expect(abs(b) <= Self.restTolerance,
                    "…and it is still there 1.5 s later — \(b) pt away")
        }
    }
}
