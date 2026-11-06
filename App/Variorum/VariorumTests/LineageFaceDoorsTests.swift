//
//  LineageFaceDoorsTests.swift
//  VariorumTests
//
//  VX-801 (VX-827 U3b) — **the Lineage face's doors, declared once (P-1).**
//  THE DESIGN MEMO: "The block menu carries History and Lineage rows" — and
//  her composite's "lineage ›" on the Commits face; the member header's acts
//  (Put back · Bring back as take · Compare with now · go to its wing) are
//  `.surface` acts the registry walk sees (`CapabilityRegistryTests`' surface
//  union carries the face's line). A PRODUCT row: red on the pre-U3b tree by
//  not compiling (the ids, the face, the row title did not exist).
//

import Foundation
import Testing
@testable import Variorum

@MainActor
@Suite("The Lineage face's doors (VX-801)")
struct LineageFaceDoorsTests {
    /// The door: block-scoped, on block ▾ (both bars) and the Commits face's
    /// crumb — never a palette row (the memo names two doors).
    @Test func theLineageDoorIsDeclaredOnTheBarsAndTheCommitsFace() {
        let door = CapabilityRegistry.capability(.showBlockLineage)
        #expect(door.scope == .block)
        #expect(door.doors == [.bottomBar, .surface])
        #expect(door.takesAccess == .native, "R118: not a Write privilege")
        #expect(!door.unavailableNote.isEmpty)
        #expect(CommitBar.renderedCapabilities.contains(.showBlockLineage))
        #expect(TakesBottomBar.renderedCapabilities.contains(.showBlockLineage))
        #expect(CommitsFaceView.surfaceCapabilities.contains(.showBlockLineage),
                "\u{201C}lineage \u{203A}\u{201D} on the Commits face")
    }

    /// The header's four acts are declared ONCE each, `.surface` only, and
    /// the face renders them — and no purge door (row 21's letter).
    @Test func theHeadersActsAreDeclaredOnceAsSurfaceActs() {
        let header: [CapabilityID] = [
            .putBackLineageBlock, .bringBackLineageAsTake, .compareLineageWithNow, .goToLineageWing,
        ]
        for id in header {
            #expect(CapabilityRegistry.all.filter { $0.id == id }.count == 1, "\(id) declared once")
            #expect(CapabilityRegistry.capability(id).doors == [.surface])
            #expect(LineageFaceView.surfaceCapabilities.contains(id))
        }
        #expect(CapabilityRegistry.capability(.bringBackLineageAsTake).verb
                == BlockHistoryPath.bringBackAsTakeVerb)
        #expect(CapabilityRegistry.capability(.putBackLineageBlock).verb == BlockPastCopy.putBackVerb)
        #expect(CapabilityRegistry.capability(.compareLineageWithNow).verb == LineageFaceCopy.compareWithNow)
        let rendered = LineageFaceView.surfaceCapabilities
        #expect(!rendered.contains(.deleteNow) && !rendered.contains(.emptyTrash))
    }

    /// **block ▾ carries Lineage on both bars**, under History — read from
    /// each menu's own body (`CommitsFaceDoorsTests`' precedent: a SwiftUI menu
    /// cannot be mounted headlessly).
    @Test func bothBlockMenusCarryTheLineageRow() throws {
        #expect(CommitBar.lineageRowTitle == "Lineage", "the memo's row, the act's short word")
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Variorum/Features")
        func menuBody(_ file: String, after marker: String) throws -> Substring {
            let source = try String(contentsOf: root.appendingPathComponent(file), encoding: .utf8)
            let start = try #require(source.range(of: marker))
            let body = source[start.upperBound...].prefix(9_000)
            let end = body.range(of: "\n    }\n")?.lowerBound ?? body.endIndex
            return body[..<end]
        }
        let write = try menuBody("Editor/CommitBar.swift", after: "private var blockMenu: some View {")
        #expect(write.contains("Button(Self.lineageRowTitle) { model.requestBlockLineage() }"))
        let takes = try menuBody("Takes/TakesBottomBar.swift", after: "private var blockMenu: some View {")
        #expect(takes.contains("Button(CommitBar.lineageRowTitle) { model.requestBlockLineage() }"))
    }

    /// The request both rows raise opens the Lineage face (nothing selected —
    /// the face's own opening rule); the origin door's names its original.
    @Test func theLineageRequestOpensTheLineageFace() {
        let request = BlockHistoryRequest(
            postID: "N", blockID: "B", focusedVariantID: "V", opening: .lineage(select: nil))
        #expect(request.opening == .lineage(select: nil))
        #expect(request.id != BlockHistoryRequest(postID: "N", blockID: "B", focusedVariantID: "V").id,
                "a different face is a different request (the hosts rebuild on it)")
        #expect(BlockHistoryRequest(postID: "N", blockID: "B").opening == .commits,
                "every history door's request opens the Commits face, as before")
    }
}
