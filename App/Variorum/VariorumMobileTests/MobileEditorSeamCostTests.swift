//
//  MobileEditorSeamCostTests.swift
//  VariorumMobileTests
//
//  **Phase 13u1, UNIT 1 — the phone's half of the O(N²) sweep.**
//
//  `BlockRangeIndex.range(ofEntryAt:)` walks the entries from ZERO on every
//  call, so a caller that asks it once per entry inside a loop pays
//  Σi ≈ N²/2 on the main actor — cost proportional to the DOCUMENT, which is
//  P1's one prohibition. `KnownIssuesAndTechDebt.md`'s `planVisibleTakeEdit`
//  row (owner 13u1) demanded the class be swept **on both platforms**; the
//  phone's two loop members are `applyDifferential` (the sweep's P17, the
//  Mac twin's exact shape) and the crystallization attribute stamp.
//
//  The equivalence proof is the SHARED brain's own pin
//  (`EditorSeamCostTests.theEntryRangesWalkAgreesWithTheIndexsOwnAccessor`,
//  on `BlockRangeIndex` itself — one type, one pin, no second copy to
//  drift). What lives here is the phone's own measurement, on the phone's
//  own headless editor.
//

import Foundation
import Testing
import UIKit
import VariorumCore

@testable import VariorumMobile

@MainActor
@Suite("The phone editor's cost floor (13u1 UNIT 1)")
struct MobileEditorSeamCostTests {
    /// Eight thousand blocks — the Mac twin's fixture size, an order of
    /// magnitude past the author's own 100k-word bar (~1,400 paragraphs).
    private static let blockCount = 8_000

    private static func slot(_ i: Int, changed: Bool) -> Queries.RenderedBlock {
        Queries.RenderedBlock(
            blockID: "b\(i)", placementID: "p\(i)", position: "m\(i)",
            variantID: "v\(i)",
            text: changed ? "changed paragraph body" : "paragraph body \(i % 10)",
            activeVariantCount: 1, liveVariantCount: 1,
            commentCount: 0, variantLocked: false)
    }

    private static func bigSlots(marking changed: Int? = nil) -> [Queries.RenderedBlock] {
        (0..<blockCount).map { slot($0, changed: $0 == changed) }
    }

    /// **P17's phone half, measured.** A take switch, a `restoreCommit` and
    /// every sync landing take this road; it replaced only the changed slots
    /// but asked the accessor once per slot with no accumulation, so the
    /// walk alone was Σi ≈ N²/2 in the block count before a single character
    /// was compared. The Mac twin measured 4.41 s → 56.6 ms at this fixture
    /// size on the same accessor.
    @Test func theDifferentialProjectionApplyStaysCheapAtEightThousandBlocks() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "cost", profile: .blog)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            model.applyProjection(Self.bigSlots())
            #expect(model.index.entries.count == Self.blockCount)
            let rendersAfterFill = model.fullRenderCount

            let clock = ContinuousClock()
            let cost = clock.measure {
                model.applyProjection(Self.bigSlots(marking: Self.blockCount - 1))
            }
            #expect(model.fullRenderCount == rendersAfterFill,
                    "the DIFFERENTIAL road ran, not a full re-render")
            #expect(storage.string.hasSuffix("changed paragraph body"),
                    "…and it actually replaced the changed slot")
            #expect(cost < .milliseconds(400),
                    "the Σi accessor walk is the document-proportional term")
            print("PERF[13u1·phone] applyDifferential @\(Self.blockCount) blocks — \(cost)")
        }
    }
}
