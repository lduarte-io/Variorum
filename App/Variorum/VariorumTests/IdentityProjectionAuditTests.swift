//
//  IdentityProjectionAuditTests.swift
//  VariorumTests
//
//  Phase 13l, ACT 3 / L-a — the identity oracle arrives on the Mac.
//
//  Two suites, because there are two claims and they fail for different
//  reasons:
//
//  · **The WALK** (`IdentityProjectionAudit.isClean`) — a pure function over
//    an index and a storage. Pinned here rather than on the phone because
//    the hoist made it shared and this is the platform that had no coverage
//    of it at all; the phone's existing pins ride unmodified, which is the
//    zero-test-edit parity proof this repo's hoists lean on.
//  · **THE WIRING** — that the Mac's real editor actually RUNS it, on the
//    real per-keystroke road, and that it sees a corruption the editor's
//    two existing oracles are blind to. That is L-a's whole reason: the
//    mobile round reproduced exactly that blindness against this view model
//    (`stored → ["Alpha", "Beta beta", "G"]`, her paragraph written to the
//    store as one character, `desyncRecoveryCount == 0`, totals agreeing).
//
//  RED ON THE PRE-L-a TREE: the Mac had no `identityAuditFailures` and no
//  call sites — `grep -rl auditIdentityProjection App/Variorum/Variorum`
//  returned zero — so the wiring suite does not compile there, and the walk
//  suite's `anEmptyEntrysSeparatorIsAudited` fails against the phone's
//  pre-M15-Q2 shape (verified by behavioural revert; see the phase record).
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The walk

@Suite("The identity projection audit — the shared walk (13l L-a)")
struct IdentityProjectionAuditWalkTests {
    /// Builds the surface the way the editor does, so a "clean" fixture is
    /// clean for the same reason production is.
    private func materialize(
        _ texts: [String?], tail: String? = nil
    ) -> (NSMutableAttributedString, BlockRangeIndex) {
        let slots = texts.enumerated().map { i, text in slot("b\(i)", text: text) }
        let (attributed, index) = EditorDocument.materializeCore(
            slots, tail: tail, base: [:])
        return (attributed, index)
    }

    @Test func anHonestSurfaceIsClean() {
        let (storage, index) = materialize(["Alpha", "Beta beta", "Gamma"])
        #expect(IdentityProjectionAudit.isClean(index: index, storage: storage))
    }

    @Test func anHonestSurfaceWithAnOpenTailIsClean() {
        let (storage, index) = materialize(["Alpha", "Beta beta"], tail: "delta")
        #expect(IdentityProjectionAudit.isClean(index: index, storage: storage))
    }

    @Test func totalsThatDisagreeAreCaught() {
        let (storage, index) = materialize(["Alpha", "Beta"])
        storage.replaceCharacters(in: NSRange(location: 0, length: 0), with: "X")
        #expect(!IdentityProjectionAudit.isClean(index: index, storage: storage))
    }

    /// The traced corruption's shape: one block's ID stamped across the
    /// NEXT block's characters, totals untouched. Neither of the editor's
    /// two existing oracles can see this — it is the whole reason the walk
    /// exists.
    @Test func aBlockIDStampedOverItsNeighbourIsCaught() {
        let (storage, index) = materialize(["Alpha", "Beta beta", "Gamma"])
        storage.addAttribute(
            EditorDocument.blockIDAttribute, value: "b1",
            range: NSRange(location: 16, length: 5))
        #expect(storage.length == index.documentLength, "the totals still agree")
        #expect(!IdentityProjectionAudit.isClean(index: index, storage: storage))
    }

    @Test func aBlockRunGoingMissingIsCaught() {
        let (storage, index) = materialize(["Alpha", "Beta beta"])
        storage.removeAttribute(
            EditorDocument.blockIDAttribute, range: NSRange(location: 6, length: 4))
        #expect(!IdentityProjectionAudit.isClean(index: index, storage: storage))
    }

    @Test func aSeparatorThatAcquiredAnOwnerIsCaught() {
        let (storage, index) = materialize(["Alpha", "Beta"])
        storage.addAttribute(
            EditorDocument.blockIDAttribute, value: "b0",
            range: NSRange(location: 5, length: 1))
        #expect(!IdentityProjectionAudit.isClean(index: index, storage: storage))
    }

    /// The boundary half (M15 Q2): the tiling has slipped against the
    /// storage's real newlines while every total still agrees. Two
    /// same-length blocks, so the index is arithmetically satisfied and only
    /// the CHARACTER at the boundary can tell the truth.
    @Test func aTilingSlippedAgainstTheRealNewlinesIsCaught() {
        let (storage, index) = materialize(["Alpha", "Bravo"])
        // "Alpha\nBravo" → "AlphaXBravo": same length, same attribute runs,
        // no newline where the index says a block ends.
        storage.replaceCharacters(in: NSRange(location: 5, length: 1), with: "X")
        #expect(storage.length == index.documentLength, "the totals still agree")
        #expect(!IdentityProjectionAudit.isClean(index: index, storage: storage))
    }

    /// **THE CARRIED HOLE (13l L-a).** An EMPTY entry has no attribute run
    /// to walk, and the pre-M15-Q2 walk skipped the whole iteration for it —
    /// so an empty block's separator was never read. An empty block is
    /// precisely where the index is the SOLE authority (a zero-length range
    /// can carry no attribute), which makes its boundary the one most worth
    /// checking.
    ///
    /// RED ON THE OLD SHAPE (`guard range.length > 0 else { continue }`):
    /// this returns clean, and the slipped boundary goes unseen.
    @Test func anEmptyEntrysSeparatorIsAudited() {
        let (storage, index) = materialize(["Alpha", "", "Gamma"])
        #expect(storage.string == "Alpha\n\nGamma")
        #expect(IdentityProjectionAudit.isClean(index: index, storage: storage))
        // The EMPTY entry's own separator (offset 6) stops being a newline;
        // lengths are untouched, so nothing else in the system notices.
        storage.replaceCharacters(in: NSRange(location: 6, length: 1), with: "X")
        #expect(storage.length == index.documentLength, "the totals still agree")
        #expect(!IdentityProjectionAudit.isClean(index: index, storage: storage),
                "an empty block's boundary is audited like every other")
    }

    @Test func aTailThatAcquiredABlockIDIsCaught() {
        let (storage, index) = materialize(["Alpha"], tail: "delta")
        storage.addAttribute(
            EditorDocument.blockIDAttribute, value: "b0",
            range: NSRange(location: 6, length: 5))
        #expect(!IdentityProjectionAudit.isClean(index: index, storage: storage))
    }

    /// I4's letter: internal newlines are content, so a block that CONTAINS
    /// newlines is ordinary and must not read as corrupt.
    @Test func aBlockCarryingInternalNewlinesIsClean() {
        let (storage, index) = materialize(["one\ntwo\nthree", "next"])
        #expect(IdentityProjectionAudit.isClean(index: index, storage: storage))
    }
}

// MARK: - The wiring

@MainActor
@Suite("The identity projection audit — the Mac editor runs it (13l L-a)")
struct MacIdentityAuditWiringTests {
    /// Stamps `blockID` across `range` in the live storage — an
    /// ATTRIBUTE-ONLY write, which the surface delegate's
    /// `.editedCharacters` guard makes inert, so nothing in the editor
    /// reacts to it. That inertness is the point: this is the corruption's
    /// end state arriving with no announcement, exactly as the traced case
    /// produced it.
    private func stamp(_ storage: NSTextStorage, _ blockID: String, over range: NSRange) {
        storage.addAttribute(EditorDocument.blockIDAttribute, value: blockID, range: range)
    }

    /// **THE HEADLINE.** The traced corruption's shape, reproduced on the
    /// Mac: block 1's ID across block 2's characters. Then an ORDINARY
    /// keystroke through the REAL typing path — and the assertions are the
    /// three-way comparison L-a exists to make:
    ///
    /// · `desyncRecoveryCount == 0` — nothing was refused; oracle one blind.
    /// · `documentLength == storage.length` — the totals agree; oracle two
    ///   blind.
    /// · `identityAuditFailures == 1` — the new oracle, and only it, speaks.
    @Test func aStampedNeighbourIsCaughtOnTheNextKeystroke() async throws {
        try await withEditor(seedBlocks: ["Alpha", "Beta beta", "Gamma"]) { harness in
            try await withMacEditorAssertionsMuted {
                let model = harness.model
                let storage = try #require(harness.textView.textStorage)
                #expect(harness.documentText == "Alpha\nBeta beta\nGamma")
                #expect(model.identityAuditFailures == 0)

                let secondID = model.index.entries[1].blockID
                stamp(storage, secondID, over: NSRange(location: 16, length: 5))

                harness.type("!", at: 5)

                #expect(model.desyncRecoveryCount == 0,
                        "nothing was refused — the router's oracle cannot see this")
                #expect(model.index.documentLength == storage.length,
                        "the totals agree — the length oracle cannot see this either")
                #expect(model.identityAuditFailures == 1,
                        "the identity audit is the one thing that notices")
            }
        }
    }

    /// The other half of the same claim: the walk is wired to the doors that
    /// REPLACE the tiling, not only to the keystroke road. A full render
    /// over a corrupted surface is the cheapest way to observe it — the
    /// corruption is planted, then `adoptRewrite` runs inside the render.
    @Test func aProjectionRewriteAuditsTheSurfaceItJustWrote() async throws {
        try await withEditor(seedBlocks: ["Alpha", "Beta beta"]) { harness in
            try await withMacEditorAssertionsMuted {
                let model = harness.model
                let storage = try #require(harness.textView.textStorage)
                let before = model.identityAuditFailures

                // The separator acquires an owner — a projection that no
                // length can contradict — and then the tiling-write door
                // runs over it. (A full render would REPAIR the surface by
                // rewriting it, which is the honest outcome and exactly why
                // the audit is placed after the adopt rather than before.)
                stamp(storage, model.index.entries[0].blockID,
                      over: NSRange(location: 5, length: 1))
                model.adoptRewrite(
                    index: model.index, slots: model.slots, tailText: nil)

                #expect(model.identityAuditFailures == before + 1,
                        "the tiling-write door audits what it adopted")
                #expect(model.desyncRecoveryCount == 0)
            }
        }
    }

    /// **THE DEFECT THE AUDIT FOUND ON ITS FIRST MAC RUN (13l L-a).**
    ///
    /// `NSTextStorage` attribute fixing WIDENS the reported edited range to
    /// the whole paragraph *including its terminator* on macOS 26 — a
    /// one-character insertion at offset 2 reports `{2, 5}` (measured; the
    /// spy is below). `storageDidEdit` stamped the block's ID over that
    /// report, so **every keystroke in every non-last block wrote that
    /// block's identity onto the separator after it**, breaking the rule
    /// `EditorDocumentCore` states as true "by construction": the separator
    /// is owned by NEITHER neighbour.
    ///
    /// RED ON THE PRE-FIX TREE (`setBlockAttribute(…, over: editedRange)`):
    /// the separator reads the block's ID and the audit fires on every
    /// keystroke. Nothing in production reads `blockID(at:)` today, which is
    /// why it went unseen — and why the audit is what found it.
    @Test func aKeystrokeNeverStampsItsSeparator() async throws {
        try await withEditor(seedBlocks: ["Alpha", "Beta beta", "Gamma"]) { harness in
            let model = harness.model
            let storage = try #require(harness.textView.textStorage)

            harness.type("X", at: 2)          // mid-block, non-last block
            #expect(harness.documentText == "AlXpha\nBeta beta\nGamma")
            #expect(EditorDocument.blockID(at: 6, in: storage) == nil,
                    "the separator after block 0 is owned by no block")
            #expect(EditorDocument.blockID(at: 5, in: storage)
                    == model.index.entries[0].blockID)
            #expect(EditorDocument.blockID(at: 7, in: storage)
                    == model.index.entries[1].blockID)

            harness.type("Y", at: 9)          // and again, one block over
            #expect(EditorDocument.blockID(at: 17, in: storage) == nil)
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
        }
    }

    /// The measurement the fix rests on, pinned so a future point release
    /// that CHANGES it is visible rather than mysterious (TEXTKIT2_NOTES §5
    /// discipline). This asserts AppKit's behaviour, not ours.
    @Test func appKitWidensAnInsertionsReportedRangeToTheParagraph() async throws {
        try await withEditor(seedBlocks: ["Alpha", "Beta beta"]) { harness in
            let storage = try #require(harness.textView.textStorage)
            final class ReportSpy: NSObject, NSTextStorageDelegate {
                nonisolated(unsafe) var reports: [NSRange] = []
                func textStorage(
                    _ storage: NSTextStorage,
                    didProcessEditing editedMask: NSTextStorageEditActions,
                    range editedRange: NSRange, changeInLength delta: Int
                ) {
                    guard editedMask.contains(.editedCharacters) else { return }
                    reports.append(editedRange)
                }
            }
            let spy = ReportSpy()
            let previous = storage.delegate
            storage.delegate = spy
            harness.type("X", at: 2)
            storage.delegate = previous
            // A 1-character insertion reports 5 — the paragraph's tail and
            // its terminator.
            #expect(spy.reports == [NSRange(location: 2, length: 5)])
        }
    }

    /// And it is not a false-positive machine: ordinary typing, an opened
    /// tail, and a crystallization all leave it at zero. (The soak's
    /// `desyncRecoveryCount == 0` discipline, for the new counter.)
    @Test func ordinaryWritingNeverTripsTheAudit() async throws {
        try await withEditor(seedBlocks: ["Alpha", "Beta beta"]) { harness in
            let model = harness.model
            harness.type("!", at: 5)
            harness.type(" more", at: model.index.documentLength)
            harness.type("\n", at: model.index.documentLength)
            harness.type("a fresh paragraph")
            await harness.settle()
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
        }
    }
}
