//
//  EditorDecorTransactionTests.swift
//  VariorumTests
//
//  **13u3 LADDER ROUND 1, R1-1 — the deleteBackward spin's precondition,
//  held at zero.** The sampled hang (UNIT B's record: 1,839/1,839 frames in
//  `ensureLayoutForBounds:` → `_estimatedTextLocationForVerticalOffset:` at
//  99% CPU) was `refreshDecorations`' layout-forcing fragment query running
//  SYNCHRONOUSLY inside `NSTextStorage.processEditing` — reached through
//  `storageDidEdit` → `updateCaretContext`'s indicator arm whenever the
//  editing indicator is on and the (stale, mid-transaction) caret read maps
//  to a different block than before the edit. TEXTKIT2 §2's estimation
//  class, and the codebase's own rule at the sibling observer ("geometry
//  reads must wait for it to close").
//
//  The hang itself cannot be honestly pinned (a once-seen OS-internal
//  estimation loop); what CAN be — and is, red-on-old — is its
//  PRECONDITION: the DEBUG oracle `decorLayoutQueriesInEditTransaction`
//  counts any decoration-pass layout walk that runs while the storage-edit
//  transaction is open, through the REAL delegate pipeline (shouldChange →
//  storage edit → didProcessEditing). Zero, or the spin's door is open
//  again. The second half holds the fix honest the other way: the deferred
//  refresh still ARRIVES, through the settle hop the same edit armed.
//

import AppKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The decoration pass stays out of the edit transaction (13u3 ladder R1-1)")
struct EditorDecorTransactionTests {
    /// **The spin's arm, driven for real, and the oracle at zero.** Two
    /// blocks; the caret parked on block 1's inclusive END boundary; then a
    /// one-character deletion inside block 1 through the real pipeline.
    /// During `processEditing` the selection is STALE (the caution the
    /// responses file records: the text view's own adjustment has not run)
    /// while the index has already shrunk block 1 — so the in-transaction
    /// caret read maps to BLOCK 2, `caretBlockID != previousCaretBlock` is
    /// true with the indicator on, and the arm fires exactly as the sample
    /// caught it firing.
    @Test func theIndicatorRefreshNeverForcesLayoutInsideTheEditTransaction() async throws {
        try await withEditor(seedBlocks: ["AB", "CD"]) { h in
            h.model.appearance.indicator = .outline
            h.textView.setSelectedRange(NSRange(location: 2, length: 0))
            h.model.updateCaretContext()
            let blocks = h.model.index.entries.map(\.blockID)
            #expect(h.model.caretBlockID == blocks[0], "the inclusive end is block 1's")

            var delivered: [BlockDecor.State] = []
            h.model.decorSink = { delivered.append($0) }

            // The edit: block 1's first character goes, through the real
            // delegate pipeline.
            h.replace(NSRange(location: 0, length: 1), with: "")

            #expect(h.model.decorLayoutQueriesInEditTransaction == 0,
                    "no layout-forcing decoration walk inside the storage-edit transaction — the sampled spin's precondition (R1-1)")

            // NON-STARVATION: deferred is not dropped. In THIS construction
            // the caret ends back in block 1 (AppKit's post-edit fixup) and
            // no line moved, so the final state EQUALS the last delivered
            // one and the equality gate rightly sends nothing on its own.
            // The honest liveness check is therefore that the pipeline still
            // delivers the current truth on its next occasion, transaction
            // closed — the settle hop drained first so its own delivery (if
            // any) lands before the forced one.
            h.model.overlayLayoutDidSettle()
            try? await Task.sleep(for: .milliseconds(50))
            await Task.yield()
            delivered.removeAll()
            h.model.pushDecorationsToSink()
            let last = try #require(delivered.last,
                                    "the decoration pipeline is alive after the deferral")
            #expect(last.caretBlockID == h.model.caretBlockID)
            #expect(last.entryCount == 2)
            #expect(h.model.decorLayoutQueriesInEditTransaction == 0,
                    "…and no delivery road re-entered the transaction")
        }
    }

    /// **The safe road is untouched:** a caret move with NO edit (the
    /// arrow-key / click road — `textViewDidChangeSelection`, outside any
    /// storage transaction) still refreshes the indicator synchronously, so
    /// the fix starves nothing it did not have to.
    @Test func aPlainCaretMoveStillRefreshesTheIndicatorSynchronously() async throws {
        try await withEditor(seedBlocks: ["AB", "CD"]) { h in
            h.model.appearance.indicator = .outline
            h.textView.setSelectedRange(NSRange(location: 0, length: 0))
            h.model.updateCaretContext()

            var delivered: [BlockDecor.State] = []
            h.model.decorSink = { delivered.append($0) }

            // Into block 2 — a selection change, no edit transaction.
            h.textView.setSelectedRange(NSRange(location: 4, length: 0))
            h.model.updateCaretContext()

            let blocks = h.model.index.entries.map(\.blockID)
            #expect(h.model.caretBlockID == blocks[1])
            #expect(delivered.contains { $0.caretBlockID == blocks[1] },
                    "the indicator followed the caret with no hop needed")
            #expect(h.model.decorLayoutQueriesInEditTransaction == 0)
        }
    }
}
