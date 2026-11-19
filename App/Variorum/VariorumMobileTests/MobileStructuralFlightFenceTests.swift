//
//  MobileStructuralFlightFenceTests.swift
//  VariorumMobileTests
//
//  **VM-2 — the keystroke fence around a structural flight** (the record
//  `notes/plans/fixes/vm-64-timing-and-lags.md`, batch 2; the VM-5 pass's
//  MAJOR 1, whose measured probe 2 these pins invert).
//
//  THE WINDOW, MADE DETERMINISTIC. Every phone structural door flushes, then
//  suspends — the fan read, the operation, the settle's read — while the page
//  still shows the note as it was. The in-memory world is a `DatabaseQueue`
//  (reads and writes share one serial queue), so holding that queue parks the
//  door at its first store trip after the flush: exactly the production window,
//  stretched until the pin releases it. The Mac's twin holds its writer with a
//  sleep (`ReturnKeyTraceTests.aKeystrokeDuringTheFlightIsDeferredNeverDropped`);
//  this hold is released by the pin itself, so no timing decides the outcome.
//
//  THE THREE ROADS an edit can take into that window, each driven through the
//  real surface where one exists (§34's M25: "drive the real surface, and verify
//  the path you drove is the path you meant"):
//    · A — a TYPED key: `UITextView.insertText` / `deleteBackward` on the mounted
//      Write text view (the keyboard's own entry points);
//    · B — an edit the page's GATE is asked about (`typeEdit`: the delegate
//      consult, then the storage write — a paste, a formatting act, an
//      autocorrection that asks);
//    · C — an edit that reaches the text with NO gate consult (a storage write
//      with no consult — the system's own rewrites; M25 measured
//      `deleteBackward()`/`replace(_:withText:)` taking this road).
//
//  RED ON OLD (the pre-fix tree, `9cf3b3688`): on every road the window's edit
//  routes against the old tiling, records the WHOLE old block, and the door's
//  own settle writes it after the operation — since VX-683 B as a RESCUE, so
//  the old text keeps the chosen take and the operation's real result becomes
//  a spurious `'conflict'` take. Each pin names the shape it fails with.
//
//  These pins use ONLY API that exists on the pre-fix tree, so the same file
//  builds against it for the red run.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The hold

/// Holds the in-memory store's one serial queue until `release()` — the
/// flight's window, opened deterministically.
@MainActor
private final class StoreHold {
    private let gate = DispatchSemaphore(value: 0)
    private let entered = LockIsolated(false)
    private var task: Task<Void, Error>?

    func take(_ db: AppDatabase) async throws {
        let gate = gate
        let entered = entered
        task = Task.detached {
            try db.write { _ in
                entered.setValue(true)
                gate.wait()
            }
        }
        var spins = 0
        while !entered.value, spins < 5000 {
            spins += 1
            try await Task.sleep(for: .milliseconds(1))
        }
        try #require(entered.value, "the hold never took the store")
    }

    func release() async throws {
        gate.signal()
        try await task?.value
    }
}

/// Runs `door` with the store held, waits until its flight is up and parked on
/// the store, runs `inTheWindow` there, then releases the store and lets the
/// door land. Finishes with a flush, so whatever the window's edits recorded
/// has reached the store before the pin reads it. The hold is ALWAYS released,
/// whatever the window throws — a pin that failed must not hang the run.
@MainActor
private func duringTheFlight(
    _ model: MobileEditorViewModel, db: AppDatabase,
    door: @escaping @MainActor () async -> Void,
    inTheWindow: @MainActor () throws -> Void
) async throws {
    let hold = StoreHold()
    try await hold.take(db)
    let flight = Task { @MainActor in await door() }
    var spins = 0
    while !model.structural.structuralInFlight, spins < 5000 {
        spins += 1
        await Task.yield()
    }
    var failure: Error?
    do {
        try #require(model.structural.structuralInFlight,
                     "the flight is up and parked on the held store")
        try inTheWindow()
    } catch {
        failure = error
    }
    try await hold.release()
    await flight.value
    await model.autosave.flushNow()
    if let failure { throw failure }
}

// MARK: - Probes

/// Road C: a storage write the gate is never asked about (the harness's
/// gate-bypassing replacement; the system's own rewrites take this road).
@MainActor
private func systemEdit(_ storage: NSTextStorage, at location: Int, insert text: String) {
    storage.replaceCharacters(
        in: NSRange(location: location, length: 0),
        with: NSAttributedString(
            string: text, attributes: [.font: MobileEditorStyle.baseFont]))
}

/// Live takes labelled `'conflict'` anywhere in the store — the spurious card a
/// stale autosave's VX-683 B rescue mints.
@MainActor
private func conflictTakes(_ db: AppDatabase) async throws -> Int {
    try await db.read { db in
        try Int.fetchOne(
            db,
            sql: "SELECT COUNT(*) FROM variant WHERE label = 'conflict' AND deleted_at IS NULL")
            ?? 0
    }
}

/// Live takes holding `marker` on a block that has NO live placement — a merge's
/// released sources, where prose typed into the window used to land.
@MainActor
private func markerInUnplacedTakes(_ db: AppDatabase, _ marker: String) async throws -> Int {
    try await db.read { db in
        try Int.fetchOne(
            db,
            sql: """
                SELECT COUNT(*) FROM variant v
                WHERE v.deleted_at IS NULL AND instr(v.working_text, ?) > 0
                  AND NOT EXISTS (
                    SELECT 1 FROM container_block cb
                    WHERE cb.block_id = v.block_id AND cb.deleted_at IS NULL)
                """,
            arguments: [marker]) ?? 0
    }
}

/// How often `marker` occurs across the note's rendered text.
private func occurrences(of marker: String, in texts: [String]) -> Int {
    texts.joined(separator: "\n").components(separatedBy: marker).count - 1
}

/// The note's rendered text with every `marker` taken out — what the operation
/// alone should have left.
private func withoutMarker(_ marker: String, _ texts: [String]) -> [String] {
    texts.map { $0.replacingOccurrences(of: marker, with: "") }
}

/// The DEBUG identity oracle and the desync heal stayed quiet (the batch's
/// "the DEBUG identity audit quiet").
@MainActor
private func expectQuietIdentity(_ model: MobileEditorViewModel) {
    #expect(model.identityAuditFailures == 0, "the identity audit stayed quiet")
    #expect(model.desyncRecoveryCount == 0, "the page never desynced")
}

// MARK: - The pins

@MainActor
@Suite("VM-2 — the keystroke fence around a structural flight (probe 2 inverted, per door)")
struct MobileStructuralFlightFenceTests {
    private static let seedA = "Alpha beta. Gamma delta."
    private static let seedB = "Second block prose."

    // MARK: Divide — the three roads

    /// **Road A, divide (THE PIN — probe 2 inverted).** Keys typed at the
    /// caret while the divide lands — a ⌫ among them — wait for the flight
    /// and replay, in order, at the caret it lands: the start of the minted
    /// half, which is where she was typing. Nothing is lost; nothing reads
    /// twice.
    ///
    /// RED ON OLD: the keys landed in the OLD block A at offset 12 and its
    /// whole text was written after the divide — `["Alpha beta. XGamma
    /// delta.", "Gamma delta.", …]`, the moved half reading twice, plus a
    /// spurious conflict take holding the divide's real `"Alpha beta."`.
    @Test func keysTypedWhileADivideLandsReplayAtTheLandedCaret() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: [Self.seedA, Self.seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let textView = surface.textView
            textView.selectedRange = NSRange(location: 12, length: 0)  // "Alpha beta. |Gamma"

            try await duringTheFlight(model, db: db, door: {
                await model.structural.divide(atSurfaceCaret: 12)
            }, inTheWindow: {
                textView.insertText("X")
                textView.insertText("Y")
                textView.deleteBackward()
            })

            #expect(try await storedBlockTexts(db, postID: postID)
                == ["Alpha beta.", "XGamma delta.", Self.seedB],
                "the divide landed and her keys followed it, ⌫ included")
            #expect(try await conflictTakes(db) == 0, "no stale write was rescued")
            expectQuietIdentity(model)
        }
    }

    /// **Road B, divide.** An edit the gate is asked about while the divide
    /// lands is refused, and the refusal is SAID once the flight lands (the
    /// door's own receipt would otherwise wipe it before she could read it).
    ///
    /// RED ON OLD: the gate approved it; `["Alpha beta. Gamma delta.X",
    /// "Gamma delta.", …]` plus a conflict take, and the status line empty.
    @Test func anEditTheGateIsAskedAboutDuringADivideIsRefusedAndSaid() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: [Self.seedA, Self.seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let storage = surface.textView.textStorage
            let end = (Self.seedA as NSString).length

            try await duringTheFlight(model, db: db, door: {
                await model.structural.divide(atSurfaceCaret: 12)
            }, inTheWindow: {
                typeEdit(model, storage, range: NSRange(location: end, length: 0),
                         replacement: "X")
            })

            #expect(try await storedBlockTexts(db, postID: postID)
                == ["Alpha beta.", "Gamma delta.", Self.seedB])
            #expect(try await conflictTakes(db) == 0)
            #expect(model.statusMessage == StructuralUndoCopy.anotherIsLanding,
                    "the refused edit is spoken for after the flight lands")
            #expect(model.statusAction == .undo, "the divide's own Undo stays beside it")
            expectQuietIdentity(model)
        }
    }

    /// **Road C, divide.** An edit that reaches the text with no gate consult
    /// (the system's own rewrites) is withheld: nothing of it is written, the
    /// page is re-read from the store before the flight ends, and the
    /// withholding is said.
    ///
    /// RED ON OLD: routed by `fallbackVerdict` to `.block(0)` and written whole
    /// after the divide — `["Alpha beta. Gamma delta.X", "Gamma delta.", …]`
    /// plus a conflict take.
    @Test func aGatelessEditDuringADivideIsWithheldAndThePageReReadFromTheStore() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: [Self.seedA, Self.seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let storage = surface.textView.textStorage
            let end = (Self.seedA as NSString).length

            try await duringTheFlight(model, db: db, door: {
                await model.structural.divide(atSurfaceCaret: 12)
            }, inTheWindow: {
                systemEdit(storage, at: end, insert: "X")
            })

            #expect(try await storedBlockTexts(db, postID: postID)
                == ["Alpha beta.", "Gamma delta.", Self.seedB])
            #expect(try await conflictTakes(db) == 0)
            // The page agrees with the store — the withheld bytes did not linger.
            #expect(storage.string == "Alpha beta.\nGamma delta.\n\(Self.seedB)")
            #expect(!model.autosave.isDirty)
            #expect(model.statusMessage == StructuralUndoCopy.anotherIsLanding)
            expectQuietIdentity(model)
        }
    }

    // MARK: Merge — prose must not land in a released block

    /// **Road A, merge.** A key typed in the trailing block while it merges
    /// with the one above waits and replays into the MERGED block — exactly
    /// once, and never in either released source.
    ///
    /// RED ON OLD: the key was written into the trailing block's take after the
    /// merge released it — the merged block holds no `X` and a released source
    /// does (the VM-5 record's "typed prose silently leaves the note").
    @Test func aKeyTypedWhileAMergeLandsEndsUpInTheMergedBlock() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(
                session, blocks: ["First half.", "Second half goes here."])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let textView = surface.textView
            let trailing = try #require(model.index.entries.last?.blockID)
            let range = try #require(model.rangeOfBlock(trailing))
            textView.selectedRange = NSRange(location: range.location + 3, length: 0)

            try await duringTheFlight(model, db: db, door: {
                await model.structural.mergeWithPrevious(atSurfaceCaret: range.location + 3)
            }, inTheWindow: {
                textView.insertText("X")
            })

            let texts = try await storedBlockTexts(db, postID: postID)
            #expect(texts.count == 1, "the two blocks merged")
            #expect(withoutMarker("X", texts) == ["First half.\nSecond half goes here."])
            #expect(occurrences(of: "X", in: texts) == 1, "her key is in the note, once")
            #expect(try await markerInUnplacedTakes(db, "X") == 0,
                    "nothing she typed landed in a released source")
            #expect(try await conflictTakes(db) == 0)
            expectQuietIdentity(model)
        }
    }

    /// **Road C, merge.** A gate-less edit into the trailing block while it
    /// merges is withheld — it can never reach the released source's take.
    ///
    /// RED ON OLD: `markerInUnplacedTakes == 1` — the edit's whole-block text
    /// was written into the released trailing source.
    @Test func aGatelessEditDuringAMergeNeverLandsInAReleasedSource() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(
                session, blocks: ["First half.", "Second half goes here."])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let storage = surface.textView.textStorage
            let trailing = try #require(model.index.entries.last?.blockID)
            let range = try #require(model.rangeOfBlock(trailing))

            try await duringTheFlight(model, db: db, door: {
                await model.structural.mergeWithPrevious(atSurfaceCaret: range.location + 3)
            }, inTheWindow: {
                systemEdit(storage, at: range.location + 3, insert: "X")
            })

            #expect(try await storedBlockTexts(db, postID: postID)
                == ["First half.\nSecond half goes here."])
            #expect(try await markerInUnplacedTakes(db, "X") == 0)
            #expect(try await conflictTakes(db) == 0)
            #expect(model.statusMessage == StructuralUndoCopy.anotherIsLanding)
            expectQuietIdentity(model)
        }
    }

    // MARK: Extract and Make Block — the lifted span must not read twice

    /// **Road A, extract.** A key typed at the end of the source while its
    /// first sentence is extracted waits and replays at the landed caret; the
    /// extracted span reads once.
    ///
    /// RED ON OLD: the source's whole OLD text (span included) was written over
    /// the remainder after the extract — `["Alpha beta.", "Alpha beta. Gamma
    /// delta.X", …]`, the span twice, plus a conflict take.
    @Test func aKeyTypedWhileAnExtractLandsNeverDuplicatesTheSpan() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: [Self.seedA, Self.seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let textView = surface.textView
            let end = (Self.seedA as NSString).length
            textView.selectedRange = NSRange(location: end, length: 0)

            try await duringTheFlight(model, db: db, door: {
                await model.structural.extractSelection(range: NSRange(location: 0, length: 11))
            }, inTheWindow: {
                textView.insertText("X")
            })

            let texts = try await storedBlockTexts(db, postID: postID)
            #expect(withoutMarker("X", texts) == ["Alpha beta.", "Gamma delta.", Self.seedB],
                    "the span was lifted out once and the source kept only the rest")
            #expect(occurrences(of: "X", in: texts) == 1, "her key is in the note, once")
            #expect(try await conflictTakes(db) == 0)
            expectQuietIdentity(model)
        }
    }

    /// **Road A, make block.** The composed middle-span act (two divides as
    /// one compound): a key typed at the source's end while it lands never
    /// resurrects the pre-op text.
    ///
    /// RED ON OLD: `["Alpha beta. Gamma delta. Epsilon zeta.X", "Gamma
    /// delta.", "Epsilon zeta.", …]` plus a conflict take.
    @Test func aKeyTypedWhileMakeBlockLandsNeverResurrectsTheWholeSource() async throws {
        try await withEditorWorld { session, db in
            let seed = "Alpha beta. Gamma delta. Epsilon zeta."
            let postID = try await makePost(session, blocks: [seed, Self.seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let textView = surface.textView
            textView.selectedRange = NSRange(location: (seed as NSString).length, length: 0)

            try await duringTheFlight(model, db: db, door: {
                await model.structural.makeBlockFromSelection(
                    range: NSRange(location: 12, length: 12))  // "Gamma delta."
            }, inTheWindow: {
                textView.insertText("X")
            })

            let texts = try await storedBlockTexts(db, postID: postID)
            #expect(withoutMarker("X", texts)
                == ["Alpha beta.", "Gamma delta.", "Epsilon zeta.", Self.seedB])
            #expect(occurrences(of: "X", in: texts) == 1)
            #expect(try await conflictTakes(db) == 0)
            expectQuietIdentity(model)
        }
    }

    // MARK: Insert block below — the twin, and what the fence changes there

    /// **The insert-below twin of probe 2 — HOLLOW ON OLD, recorded as such.**
    /// `newBlock` rewrites no existing text, so a key typed into block A while
    /// it lands records A's CURRENT text: no stale write was ever possible on
    /// this door, and this oracle (never lost, never duplicated, no rescue)
    /// holds on both trees. Kept so the door stays covered by the oracle the
    /// other three are pinned to.
    @Test func insertBelowTwinNoKeyTypedDuringTheFlightIsLostOrDuplicated() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: [Self.seedA, Self.seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let textView = surface.textView
            let blockA = try #require(model.index.entries.first?.blockID)
            textView.selectedRange = NSRange(
                location: (Self.seedA as NSString).length, length: 0)

            try await duringTheFlight(model, db: db, door: {
                await model.structural.insertBlockBelow(blockID: blockA)
            }, inTheWindow: {
                textView.insertText("X")
            })

            let texts = try await storedBlockTexts(db, postID: postID)
            #expect(withoutMarker("X", texts) == [Self.seedA, "", Self.seedB])
            #expect(occurrences(of: "X", in: texts) == 1)
            #expect(try await conflictTakes(db) == 0)
            expectQuietIdentity(model)
        }
    }

    /// **What the fence changes on insert-below — a BEHAVIOUR pin, not a bug
    /// pin.** The fence is the one latch every door shares, so a key typed
    /// while New Block Below lands now waits and lands at the caret the door
    /// lands: IN THE NEW BLOCK, which is the Mac's own rule for its ⌘⇧⏎ flight
    /// (`runStructural`'s deferred keys land at the landed caret) and the
    /// door's own receipt ("type away"). On the old tree the key went into A
    /// (`["Alpha beta. Gamma delta.X", "", …]`) — a misplacement, not a stale
    /// write; red there by design of the change, recorded in the record.
    @Test func aKeyTypedWhileInsertBelowLandsGoesIntoTheNewBlock() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: [Self.seedA, Self.seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let textView = surface.textView
            let blockA = try #require(model.index.entries.first?.blockID)
            textView.selectedRange = NSRange(
                location: (Self.seedA as NSString).length, length: 0)

            try await duringTheFlight(model, db: db, door: {
                await model.structural.insertBlockBelow(blockID: blockA)
            }, inTheWindow: {
                textView.insertText("X")
            })

            #expect(try await storedBlockTexts(db, postID: postID)
                == [Self.seedA, "X", Self.seedB])
            expectQuietIdentity(model)
        }
    }

    // MARK: The fence is gone once the flight has landed

    /// After a flight lands, typing is ordinary again: the very next key
    /// lands at once, through the gate, and is saved.
    @Test func afterTheFlightLandsTypingIsOrdinaryAgain() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: [Self.seedA, Self.seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let textView = surface.textView

            await model.structural.divide(atSurfaceCaret: 12)
            #expect(!model.structural.structuralInFlight)
            textView.insertText("Z")
            #expect(model.autosave.isDirty, "the key landed and recorded at once")
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["Alpha beta.", "ZGamma delta.", Self.seedB])
            #expect(model.statusMessage == nil, "nothing was refused, so nothing is said")
            expectQuietIdentity(model)
        }
    }
}
