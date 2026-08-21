//
//  MobileEditRoutingCrashTests.swift
//  VariorumMobileTests
//
//  Mobile round 2, batch 1 — HER TWO CRASHES, reproduced exactly, plus the
//  closed-tail sibling.
//
//  ⚠️ THESE PINS KILL THE TEST PROCESS ON THE PRE-FIX TREE, BY DESIGN.
//  Their red-on-old is a Swift runtime trap inside `BlockRangeIndex`'s
//  preconditions — which is the defect: the app died where it already had
//  a name and a road for the state. A dying process takes the whole run's
//  report down with it, so they live here, apart from the rest of the
//  suite, and a red-on-old verification runs them with `-only-testing:`
//  one at a time.
//
//  WHY THE ACT IS A STORAGE TRANSACTION AND NOT A UIKit GESTURE: the crash
//  arrives through `-[UITextView deleteBackward]` →
//  `-[NSTextStorage coordinateEditing:]`, whose contract is that however
//  many mutations happen inside the block, exactly ONE `didProcessEditing`
//  fires at its end carrying the union range and the NET delta. That
//  contract is what these pins drive directly, which makes them
//  independent of the iOS version's keyboard decomposition. That matters
//  here: her phone runs iOS 26.6 and the newest simulator runtime on this
//  machine is 26.2 (round 2 §9 — an input-path non-reproduction on 26.2 is
//  a RUNTIME GAP, never a clean bill), so the pins deliberately do not
//  depend on `_UIKeyboardStateManager`'s behaviour at all.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile edit routing — the crash reproductions (round 2, M1)")
struct MobileEditRoutingCrashTests {
    /// The coalesced transaction her `deleteBackward` produced: one
    /// `beginEditing` / `replaceCharacters` / `endEditing` block whose net
    /// deletion is wider than the region the gate last approved.
    private func coalescedDelete(_ storage: NSTextStorage, _ range: NSRange) {
        storage.beginEditing()
        storage.replaceCharacters(in: range, with: "")
        storage.endEditing()
    }

    /// **P2 — the 13:59:27 crash** (`applyTailEdit`, proven by
    /// disassembly to be the NEGATIVE-LENGTH arm at
    /// `BlockRangeIndex.swift:347`: the tail was open and the deletion
    /// simply exceeded it).
    ///
    /// RED ON THE PRE-FIX TREE: the process dies inside
    /// `precondition((tailLength ?? 0) + lengthDelta >= 0)`.
    /// GREEN AFTER: the arming is rejected (15 removed > 5 approved), the
    /// report routes by `fallbackVerdict`, which finds no containing
    /// region and answers `.crossesBlockBoundary` — the honest road — and
    /// the surface heals from the store, which is truth.
    @Test func aCoalescedDeleteWiderThanItsTailVerdictHealsInsteadOfTrapping() async throws {
        try await withEditorWorld { session, db in
            try await withEditorAssertionsMuted {
                let world = try await editRoutingFixture(session)
                let model = world.model
                let storage = world.storage
                let before = try await storedBlockTexts(db, postID: world.postID)

                // The last gate consult before the transaction closes
                // describes only a SUB-edit: the tail.
                #expect(model.shouldChangeText(
                    in: NSRange(location: 22, length: 5), replacement: ""))

                // …and then fifteen characters go, in one report.
                coalescedDelete(storage, NSRange(location: 12, length: 15))

                #expect(model.desyncRecoveryCount == 1,
                        "the unroutable edit took the honest road, not the trap")
                await settleEditor(until: { model.index.documentLength == storage.length })
                #expect(model.index.documentLength == storage.length,
                        "the surface healed from the store")
                #expect(storage.string == "Alpha\nBeta beta\nGamma\ndelta",
                        "the store is truth: the un-routable deletion did not stand")
                await model.autosave.flushNow()
                #expect(try await storedBlockTexts(db, postID: world.postID) == before,
                        "nothing was autosaved from poisoned bookkeeping")
            }
        }
    }

    /// **P3 — the 15:52:43 crash** (`applyBlockEdit`, proven by
    /// disassembly to be the sign test at `BlockRangeIndex.swift:341` —
    /// the index was in bounds and the deletion exceeded the block).
    /// One gesture, one substitution: the same coalesced delete, with the
    /// surviving arming naming a BLOCK instead of the tail.
    @Test func aCoalescedDeleteWiderThanItsBlockVerdictHealsInsteadOfTrapping() async throws {
        try await withEditorWorld { session, db in
            try await withEditorAssertionsMuted {
                let world = try await editRoutingFixture(session)
                let model = world.model
                let storage = world.storage
                let before = try await storedBlockTexts(db, postID: world.postID)

                #expect(model.shouldChangeText(
                    in: NSRange(location: 16, length: 5), replacement: ""))
                coalescedDelete(storage, NSRange(location: 12, length: 15))

                #expect(model.desyncRecoveryCount == 1)
                await settleEditor(until: { model.index.documentLength == storage.length })
                #expect(model.index.documentLength == storage.length)
                #expect(storage.string == "Alpha\nBeta beta\nGamma\ndelta")
                await model.autosave.flushNow()
                #expect(try await storedBlockTexts(db, postID: world.postID) == before)
            }
        }
    }

    /// **P4 — the index moved under the arming** (crash 2's line-346
    /// sibling: `tailLength == nil`). A `.tail` verdict armed before a
    /// crystallization closes the tail is the sharpest stale case there
    /// is — the region it names stops existing.
    ///
    /// RED ON THE PRE-FIX TREE: the process dies inside
    /// `precondition(tailLength != nil, "no open tail")`.
    /// GREEN AFTER: the mint disarms the slot structurally, so the next
    /// report routes by `fallbackVerdict` to the block that actually owns
    /// it — no trap, and no recovery needed either.
    ///
    /// (Note what the probe proves on the way past: after the mint the
    /// arming really is gone, which is the structural half of Part 3 —
    /// the consume-time predicate would have caught it anyway, and both
    /// belts are cheap.)
    @Test func aVerdictArmedBeforeTheTailClosedIsNotApplied() async throws {
        try await withEditorWorld { session, _ in
            try await withEditorAssertionsMuted {
                let world = try await editRoutingFixture(session)
                let model = world.model
                let storage = world.storage

                // Arm against the OPEN tail…
                #expect(model.shouldChangeText(
                    in: NSRange(location: 22, length: 5), replacement: ""))

                // …then close it deterministically (the idle mint).
                model.idleMintTail()
                await model.awaitMintSettle()
                #expect(model.index.tailLength == nil, "the tail crystallized away")
                #expect(model.index.entries.count == 4)

                // A small gate-less edit inside block 0 now arrives. (A
                // DELETION, for the reason P1's comment records: iOS widens
                // an insertion's report and a widened gate-less report is a
                // different story from this one.)
                systemPathEdit(storage, range: NSRange(location: 2, length: 1), replacement: "")

                #expect(model.index.entries[0].length == 4,
                        "the edit's own block shrank; the dead tail arming was not applied")
                #expect(model.index.documentLength == storage.length)
                #expect(model.identityAuditFailures == 0)
            }
        }
    }
}
