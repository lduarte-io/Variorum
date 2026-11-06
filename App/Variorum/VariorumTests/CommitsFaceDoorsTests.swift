//
//  CommitsFaceDoorsTests.swift
//  VariorumTests
//
//  VX-801 (VX-827 U3a) — **the Commits face's doors, declared once (P-1).**
//  THE DESIGN MEMO: "The block menu carries History and Lineage rows; the
//  bottom bar's history word opens the Commits face" — and the face's acts at
//  the pane's foot ("Restore · Bring back as take · Compare · Rename") are
//  `.surface` acts the registry walk sees (`CapabilityRegistryTests`'s surface
//  union carries the face's line). A PRODUCT row: red on the pre-U3a tree by
//  not compiling (the four ids, the face, the row title did not exist).
//

import Foundation
import Testing
@testable import Variorum

@MainActor
@Suite("The Commits face's doors (VX-801)")
struct CommitsFaceDoorsTests {
    /// Each of the face's acts is declared ONCE, as a `.surface` act, in the
    /// panel's own words — and the face is no trash surface.
    @Test func theFacesActsAreDeclaredOnceAsSurfaceActs() {
        let rendered = CommitsFaceView.surfaceCapabilities
        #expect(Set(rendered).count == rendered.count, "no act twice")
        for id in rendered {
            let doors = CapabilityRegistry.capability(id).doors
            #expect(doors.contains(.surface), "\(id) is pointed at on the face")
        }
        #expect(!rendered.contains(.deleteNow), "row 21's letter: not a trash surface")
        #expect(CapabilityRegistry.capability(.restoreCommit).verb == BlockHistoryCopy.restoreVerb)
        #expect(CapabilityRegistry.capability(.bringBackCommitAsTake).verb
                == BlockHistoryPath.bringBackAsTakeVerb)
        #expect(CapabilityRegistry.capability(.renameCommit).verb
                == BlockHistoryCopy.renameSavepointVerb)
        #expect(CapabilityRegistry.capability(.compareCommits).verb == CommitsFaceCopy.compareVerb)
        // The new acts carry no door beyond the face: no menu, bar, palette.
        for id in [CapabilityID.restoreCommit, .bringBackCommitAsTake, .compareCommits, .renameCommit] {
            #expect(CapabilityRegistry.capability(id).doors == [.surface])
        }
    }

    /// **block ▾ carries History on both bars** — read from each menu's own
    /// body (a SwiftUI menu cannot be mounted headlessly; the
    /// `theLibraryNoteRowMenuRendersItsDeclaredDoors` precedent), so deleting
    /// either row turns this red even while the other keeps the bars'
    /// declared set green.
    @Test func bothBlockMenusCarryTheHistoryRow() throws {
        #expect(CommitBar.historyRowTitle == "History", "the memo's row, the act's short word")
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
        #expect(write.contains("Button(Self.historyRowTitle) { model.requestBlockHistory() }"),
                "Write's block ▾ renders the History row onto the bar's own act")
        let takes = try menuBody("Takes/TakesBottomBar.swift", after: "private var blockMenu: some View {")
        #expect(takes.contains("Button(CommitBar.historyRowTitle) { model.requestBlockHistory() }"),
                "the Takes bar's block ▾ renders it too (R6-2's one grammar)")
        // The act the rows run is the bars' declared history act.
        #expect(CommitBar.renderedCapabilities.contains(.showBlockHistory))
        #expect(TakesBottomBar.renderedCapabilities.contains(.showBlockHistory))
    }
}
