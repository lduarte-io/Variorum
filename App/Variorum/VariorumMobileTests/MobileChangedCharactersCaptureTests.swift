//
//  MobileChangedCharactersCaptureTests.swift
//  VariorumMobileTests
//
//  **VM-24 — the capture's belts** (the record
//  `notes/plans/vm-24-unwarned-edit-routing.md`, D-24-1 and batch A's pin 5).
//  The storage observer keeps the characters that changed from the storage's
//  FIRST callback (`willProcessEditing`) and hands them to the model with the
//  SECOND (`didProcessEditing`). A value that outlived its pass, or one that
//  did not belong to the report it met, would route a report from the wrong
//  characters — so the pairing rule is pinned here twice: pure
//  (`MobileChangedCharactersCapture`), and through the real observer and
//  model, where "dropped" must mean "routed exactly as before VM-24".
//
//  These pins test machinery the fix ADDS, so they exist only on the fix
//  tree; the routing's red-on-old pins are `MobileUnarmedEditRoutingTests`.
//
//  The model-level pins drive the observer's two callbacks BY HAND around a
//  storage edit made with the delegate detached, so each pin chooses exactly
//  what the first callback said — the only way to stage a value that
//  disagrees with its report, which a real storage never sends. The report
//  they hand in is the widened shape iOS really sends for a font-only insert
//  at a block's end (`{11, 2}` — the character and the separator after it).
//

import Foundation
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The pure rule

@Suite("VM-24 — the changed characters are kept for one pass, and only for their own report")
struct MobileChangedCharactersCaptureTests {
    @Test func aPassThatChangedOnlyAttributesKeepsNothing() {
        var capture = MobileChangedCharactersCapture()
        capture.willProcess(.editedAttributes, range: NSRange(location: 0, length: 3), delta: 0)
        #expect(capture.kept == nil)

        capture.willProcess(
            [.editedCharacters, .editedAttributes], range: NSRange(location: 11, length: 1), delta: 1)
        #expect(capture.kept == MobileChangedCharactersCapture.Kept(
            range: NSRange(location: 11, length: 1), delta: 1))
        capture.willProcess(.editedAttributes, range: NSRange(location: 0, length: 3), delta: 0)
        #expect(capture.kept == nil, "a later attribute-only pass replaces the kept value with nothing")
    }

    @Test func theReportTakesItsOwnChangedCharactersAndLeavesNothingKept() {
        var capture = MobileChangedCharactersCapture()
        capture.willProcess(
            [.editedCharacters, .editedAttributes], range: NSRange(location: 11, length: 1), delta: 1)
        #expect(capture.take(reportedRange: NSRange(location: 11, length: 2), delta: 1)
                == NSRange(location: 11, length: 1), "the widened report gets the characters that changed")
        #expect(capture.kept == nil)
        #expect(capture.take(reportedRange: NSRange(location: 11, length: 2), delta: 1) == nil,
                "a second report of the same shape gets nothing — the value was this pass's")
    }

    @Test func anExactReportTakesTheSameRange() {
        var capture = MobileChangedCharactersCapture()
        capture.willProcess(.editedCharacters, range: NSRange(location: 6, length: 0), delta: -1)
        #expect(capture.take(reportedRange: NSRange(location: 6, length: 0), delta: -1)
                == NSRange(location: 6, length: 0), "a deletion's exact report: the same range")
    }

    /// A pass that changed no characters still TAKES (and so clears) — the
    /// observer calls `take` at every second callback, whatever its mask.
    @Test func anAttributeOnlyReportClearsAKeptValueItDoesNotBelongTo() {
        var capture = MobileChangedCharactersCapture()
        capture.willProcess(.editedCharacters, range: NSRange(location: 11, length: 1), delta: 1)
        #expect(capture.take(reportedRange: NSRange(location: 0, length: 3), delta: 0) == nil)
        #expect(capture.kept == nil)
        #expect(capture.take(reportedRange: NSRange(location: 11, length: 2), delta: 1) == nil,
                "nothing stale reaches the next character report")
    }

    @Test(arguments: [
        // (kept location, kept length, kept delta) against the report {11, 2} Δ+1
        [11, 1, 2],   // the delta disagrees
        [10, 1, 1],   // starts before the report
        [12, 2, 1],   // ends after the report
    ])
    func aKeptValueThatDisagreesWithItsReportIsDropped(_ kept: [Int]) {
        var capture = MobileChangedCharactersCapture()
        capture.willProcess(
            .editedCharacters, range: NSRange(location: kept[0], length: kept[1]), delta: kept[2])
        #expect(capture.take(reportedRange: NSRange(location: 11, length: 2), delta: 1) == nil)
        #expect(capture.kept == nil, "dropped, not kept for a later report")
    }
}

// MARK: - Through the real observer and model

/// A two-block note on the bare storage seam (`makeEditor`), with ONE
/// character inserted at block 0's end while the storage's delegate is
/// detached — so no callback has run yet and the index still describes the
/// pre-edit note. The caller then delivers the callbacks it chooses.
@MainActor
private func blockEndInsertAwaitingItsReport(
    _ session: AppSession
) async throws -> (model: MobileEditorViewModel, storage: NSTextStorage,
                   observer: MobileStorageObserver, variantA: String) {
    let postID = try await makePost(session, blocks: ["Alpha beta.", "Gamma delta."])
    let (model, storage) = makeEditor(session, postID: postID)
    await model.loadOnce()
    let observer = try #require(storage.delegate as? MobileStorageObserver,
                                "the model's own observer is the storage's delegate")
    let variantA = try #require(model.index.entries.first?.variantID)
    storage.delegate = nil
    storage.replaceCharacters(
        in: NSRange(location: 11, length: 0),
        with: NSAttributedString(string: "X", attributes: [.font: MobileEditorStyle.baseFont]))
    storage.delegate = observer
    #expect(storage.string == "Alpha beta.X\nGamma delta.")
    #expect(model.index.entries.map(\.length) == [11, 12], "precondition: no report has reached the model")
    return (model, storage, observer, variantA)
}

/// The widened report iOS sends for that insert: the character and the
/// separator after it.
private let widenedReport = NSRange(location: 11, length: 2)

@MainActor
@Suite("VM-24 — through the observer: a report with no kept value of its own routes as before", .serialized)
struct MobileChangedCharactersObserverTests {
    /// The positive control: the first callback's own value, handed on by
    /// the second, routes the widened report to block 0.
    @Test func theFirstCallbacksValueRoutesTheWidenedReportToItsBlock() async throws {
        try await withEditorWorld { session, db in
            let world = try await blockEndInsertAwaitingItsReport(session)
            world.observer.textStorage(
                world.storage, willProcessEditing: [.editedCharacters, .editedAttributes],
                range: NSRange(location: 11, length: 1), changeInLength: 1)
            world.observer.textStorage(
                world.storage, didProcessEditing: [.editedCharacters, .editedAttributes],
                range: widenedReport, changeInLength: 1)
            #expect(world.model.desyncRecoveryCount == 0)
            #expect(world.model.index.entries.map(\.length) == [12, 12])
            await world.model.autosave.flushNow()
            #expect(try await storedText(db, variantID: world.variantA) == "Alpha beta.X")
            #expect(world.model.identityAuditFailures == 0)
        }
    }

    /// **No kept value ⇒ today's behaviour.** A second callback with no first
    /// one before it routes from the report alone — which, widened through the
    /// separator, refuses and heals exactly as the code did before VM-24.
    @Test func aReportWithNoFirstCallbackRoutesFromTheReportAsBefore() async throws {
        try await withEditorAssertionsMuted { try await withEditorWorld { session, _ in
            let world = try await blockEndInsertAwaitingItsReport(session)
            world.observer.textStorage(
                world.storage, didProcessEditing: [.editedCharacters, .editedAttributes],
                range: widenedReport, changeInLength: 1)
            #expect(world.model.desyncRecoveryCount == 1, "the report alone crosses the separator: refused")
            await settleEditor(until: { world.storage.string == "Alpha beta.\nGamma delta." })
            #expect(world.storage.string == "Alpha beta.\nGamma delta.", "healed from the store, as before")
        } }
    }

    /// A kept value whose delta or range disagrees with the report is
    /// dropped, and the report routes as before.
    @Test(arguments: [
        [11, 1, 2],   // the delta disagrees
        [10, 1, 1],   // starts before the report
    ])
    func aDisagreeingKeptValueIsDroppedAndTheReportRoutesAsBefore(_ kept: [Int]) async throws {
        try await withEditorAssertionsMuted { try await withEditorWorld { session, _ in
            let world = try await blockEndInsertAwaitingItsReport(session)
            world.observer.textStorage(
                world.storage, willProcessEditing: .editedCharacters,
                range: NSRange(location: kept[0], length: kept[1]), changeInLength: kept[2])
            world.observer.textStorage(
                world.storage, didProcessEditing: [.editedCharacters, .editedAttributes],
                range: widenedReport, changeInLength: 1)
            #expect(world.model.desyncRecoveryCount == 1, "dropped: routed from the report, as before")
            await settleEditor(until: { world.storage.string == "Alpha beta.\nGamma delta." })
        } }
    }

    /// **An attribute-only transaction leaves no kept value behind.** A first
    /// callback's value is followed by a REAL attribute-only transaction on
    /// the storage (both of its callbacks reach the observer) before the
    /// character report arrives: the value is gone, and the report routes as
    /// before. (A value that survived would route it to block 0.)
    @Test func anAttributeOnlyTransactionInBetweenLeavesNoKeptValue() async throws {
        try await withEditorAssertionsMuted { try await withEditorWorld { session, _ in
            let world = try await blockEndInsertAwaitingItsReport(session)
            world.observer.textStorage(
                world.storage, willProcessEditing: [.editedCharacters, .editedAttributes],
                range: NSRange(location: 11, length: 1), changeInLength: 1)
            world.storage.addAttribute(
                .underlineStyle, value: NSUnderlineStyle.single.rawValue,
                range: NSRange(location: 0, length: 3))
            world.observer.textStorage(
                world.storage, didProcessEditing: [.editedCharacters, .editedAttributes],
                range: widenedReport, changeInLength: 1)
            #expect(world.model.desyncRecoveryCount == 1,
                    "the attribute-only pass cleared the value: the report routed as before")
            await settleEditor(until: { world.storage.string == "Alpha beta.\nGamma delta." })
        } }
    }
}
