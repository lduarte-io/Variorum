//
//  EditRoutingCrashTests.swift
//  VariorumTests
//
//  Mobile round 2, batch 1 — the MAC TWINS of her two iPhone crashes.
//
//  ⚠️ THESE PINS KILL THE TEST PROCESS ON THE PRE-FIX TREE, BY DESIGN
//  (`BlockRangeIndex`'s preconditions), which is why they sit apart from
//  the rest of the suite. See `EditRoutingTests.swift`'s header for why
//  the Mac gets twins of an iOS-only observed crash: the brain is shared
//  and the Mac's exposure is latent, not prevented.
//
//  The act is an `NSTextStorage` coalescing transaction, not a keyboard
//  gesture — the platform-independent shape of the contract her crash
//  arrived through (`coordinateEditing:` → one report, union range, net
//  delta), and the same shape `EditorFind`'s M1/M1b already measured on
//  AppKit's own Replace All.
//

import AppKit
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Mac edit routing — the crash reproductions (round 2, M1)")
struct MacEditRoutingCrashTests {
    private func fixture(_ harness: EditorHarness) {
        harness.type("\n", at: harness.model.index.documentLength)
        harness.type("delta")
    }

    private func coalescedDelete(_ storage: NSTextStorage, _ range: NSRange) {
        storage.beginEditing()
        storage.replaceCharacters(in: range, with: "")
        storage.endEditing()
    }

    /// The tail arm (her 13:59:27 crash's twin): the last gate consult
    /// describes the tail, the report carries a wider net deletion.
    /// RED ON THE PRE-FIX TREE: the process dies in
    /// `precondition((tailLength ?? 0) + lengthDelta >= 0)`.
    @Test func aCoalescedDeleteWiderThanItsTailVerdictHealsInsteadOfTrapping() async throws {
        try await withEditor(seedBlocks: ["Alpha", "Beta beta", "Gamma"]) { harness in
            try await withMacEditorAssertionsMuted {
                fixture(harness)
                let model = harness.model
                let storage = try #require(harness.textView.textStorage)
                let before = try harness.storeSlots().compactMap(\.text)

                #expect(model.shouldChangeText(
                    in: NSRange(location: 22, length: 5), replacement: ""))
                coalescedDelete(storage, NSRange(location: 12, length: 15))

                #expect(model.desyncRecoveryCount == 1,
                        "the unroutable edit took the honest road, not the trap")
                await harness.settle()
                await settleMacEditor(until: { model.index.documentLength == storage.length })
                #expect(model.index.documentLength == storage.length,
                        "the surface healed from the store")
                await harness.flush()
                #expect(try harness.storeSlots().compactMap(\.text) == before,
                        "nothing was autosaved from poisoned bookkeeping")
            }
        }
    }

    /// The block arm (her 15:52:43 crash's twin). RED ON THE PRE-FIX TREE:
    /// the process dies in
    /// `precondition(entries[index].length + lengthDelta >= 0)`.
    @Test func aCoalescedDeleteWiderThanItsBlockVerdictHealsInsteadOfTrapping() async throws {
        try await withEditor(seedBlocks: ["Alpha", "Beta beta", "Gamma"]) { harness in
            try await withMacEditorAssertionsMuted {
                fixture(harness)
                let model = harness.model
                let storage = try #require(harness.textView.textStorage)
                let before = try harness.storeSlots().compactMap(\.text)

                #expect(model.shouldChangeText(
                    in: NSRange(location: 16, length: 5), replacement: ""))
                coalescedDelete(storage, NSRange(location: 12, length: 15))

                #expect(model.desyncRecoveryCount == 1)
                await harness.settle()
                await settleMacEditor(until: { model.index.documentLength == storage.length })
                #expect(model.index.documentLength == storage.length)
                await harness.flush()
                #expect(try harness.storeSlots().compactMap(\.text) == before)
            }
        }
    }
}
