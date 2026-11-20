//
//  MobileStructuralFlightFenceTests.swift
//  VariorumMobileTests
//
//  **VM-2 — the keystroke fence around a structural flight** (the record
//  `notes/plans/fixes/vm-64-timing-and-lags.md`, batch 2; the VM-5 pass's
//  MAJOR 1, whose measured probe 2 these pins invert).
//
//  THE WINDOW, MADE DETERMINISTIC. Every phone structural door — and the
//  structural undo/redo door — flushes, then suspends (the fan read, the
//  operation, the settle's read) while the page still shows the note as it
//  was. The in-memory world is a `DatabaseQueue` (reads and writes share one
//  serial queue), so holding that queue parks the door at its first store trip
//  after the flush: exactly the production window, stretched until the pin
//  releases it, so no timing decides the outcome.
//
//  THE ROADS an edit can take into that window:
//    · A — HER KEYBOARD's road (`keyboardType` / `keyboardDelete`): the gate is
//      asked first and the key inserted only on a yes — what her device's E1
//      trace shows for every typed key. (r1's pins typed through a bare
//      programmatic `insertText`, which never asks the gate: a road no keyboard
//      takes, whose report's width — and so whether it routes — depended on
//      what an earlier suite left in the host. r2 removed that road from every
//      pin; TEXTKIT2 §3 records the measurement.)
//    · B — the model's own gate then a storage write (`typeEdit` — the same
//      consult, made by the harness rather than through the view's delegate);
//    · C — an edit that reaches the text with NO gate consult (the system's own
//      rewrites), written into the LAST block so its widened report can never
//      cross a separator (round 2's M12 is that other shape, and not this
//      batch's).
//
//  RED ON OLD (the pre-fix tree, `9cf3b3688`): the window's edit is approved,
//  records the WHOLE old block, and the door's own settle writes it after the
//  operation — since VX-683 B as a RESCUE, so the old text keeps the chosen take
//  and the operation's real result becomes a spurious `'conflict'` take. Each
//  product pin names the shape it fails with; the two guards say they are green
//  on both trees, and why.
//
//  Every pin types in the posture her phone types in (the foreground scene's
//  key window, the Write text view first responder, leftovers resigned), and a
//  debug assertion inside a pin is RECORDED AS A FAILING ISSUE
//  (`withDesyncsRecorded`) — never swallowed: the pin goes red, the host
//  survives. These pins use ONLY API that exists on the pre-fix tree, so the
//  same file builds against it for the red run.
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

/// Runs `door` with the store held, waits until its flight is up (`flying`)
/// and parked on the store, runs `inTheWindow` there, then releases the store
/// and lets the door land. Finishes with a flush, so whatever the window's
/// edits recorded has reached the store before the pin reads it. The hold is
/// ALWAYS released, whatever the window throws — a pin that failed must not
/// hang the run.
@MainActor
private func duringTheFlight(
    _ model: MobileEditorViewModel, db: AppDatabase,
    flying: @escaping @MainActor () -> Bool,
    door: @escaping @MainActor () async -> Void,
    inTheWindow: @MainActor () throws -> Void
) async throws {
    let hold = StoreHold()
    try await hold.take(db)
    let flight = Task { @MainActor in await door() }
    var spins = 0
    while !flying(), spins < 5000 {
        spins += 1
        await Task.yield()
    }
    var failure: Error?
    do {
        try #require(flying(), "the flight is up and parked on the held store")
        try inTheWindow()
    } catch {
        failure = error
    }
    try await hold.release()
    await flight.value
    await model.autosave.flushNow()
    if let failure { throw failure }
}

/// A structural door's flight (the controller's latch).
@MainActor
private func duringTheFlight(
    _ model: MobileEditorViewModel, db: AppDatabase,
    door: @escaping @MainActor () async -> Void,
    inTheWindow: @MainActor () throws -> Void
) async throws {
    try await duringTheFlight(
        model, db: db, flying: { model.structural.structuralInFlight },
        door: door, inTheWindow: inTheWindow)
}

// MARK: - Her keyboard's road

/// **A typed key, the way HER keyboard types it**: the gate is asked first
/// and the key is inserted only on a yes. Her device's E1 trace shows a gate
/// consult before every typed key (`notes/author-reports/2026-08-23-device-
/// walk-and-product-asks.md` — `GATE … → armed`, then `EDIT … after 1 gate`);
/// a bare programmatic `insertText` never asks the gate at all (TEXTKIT2 §3,
/// measured at VM-2 r1), so a pin that types through it drives a road no
/// keyboard takes. With the arming in place the insert binds to it however
/// far iOS widens the report, so this road is deterministic in any company.
@MainActor
@discardableResult
private func keyboardType(_ textView: UITextView, _ text: String) -> Bool {
    let range = textView.selectedRange
    guard textView.delegate?.textView?(
        textView, shouldChangeTextIn: range, replacementText: text) ?? true
    else { return false }
    textView.insertText(text)
    return true
}

/// ⌫ the way her keyboard deletes: the gate asked about the span it would
/// remove (the selection, else the one composed character before the caret),
/// then the delete only on a yes.
@MainActor
@discardableResult
private func keyboardDelete(_ textView: UITextView) -> Bool {
    let selection = textView.selectedRange
    let span: NSRange
    if selection.length > 0 {
        span = selection
    } else {
        guard selection.location > 0 else { return false }
        span = (textView.textStorage.string as NSString)
            .rangeOfComposedCharacterSequence(at: selection.location - 1)
    }
    guard textView.delegate?.textView?(
        textView, shouldChangeTextIn: span, replacementText: "") ?? true
    else { return false }
    textView.deleteBackward()
    return true
}

// MARK: - The posture and the assertion seam

/// The posture her phone types in (the caret suite's `host`, VX-282 C-1): the
/// surface in the foreground scene's key window, any responder an earlier suite
/// left holding the keyboard resigned first, the Write text view first
/// responder. A view typed into from no window at all is not a posture any
/// phone is in.
@MainActor
private func host(_ surface: MobileWriteSurfaceView) throws -> UIWindow {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let scene = try #require(
        scenes.first { $0.activationState == .foregroundActive } ?? scenes.first,
        "the test host has a window scene to type in")
    let window = UIWindow(windowScene: scene)
    window.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
    let controller = UIViewController()
    controller.view.addSubview(surface)
    window.rootViewController = controller
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    window.makeKeyAndVisible()
    _ = surface.textView.becomeFirstResponder()
    return window
}

/// The teardown: the text view resigns BEFORE the window hides, so no first
/// responder outlives the pin.
@MainActor
private func dismiss(_ window: UIWindow, _ surface: MobileWriteSurfaceView) {
    _ = surface.textView.resignFirstResponder()
    window.isHidden = true
    window.rootViewController = nil
}

/// The editor's debug assertion, RECORDED as a failing issue instead of
/// stopping the host — task-scoped, so it reaches this pin and the tasks it
/// spawns (the door's flight, a desync's heal) and nothing running beside it.
/// This never makes a pin green: a desync still fails the pin here, by this
/// issue and by its `desyncRecoveryCount == 0` expectation; it only keeps one
/// pin's red from taking the rest of the run down with it.
@MainActor
private func withDesyncsRecorded<T>(_ body: () async throws -> T) async rethrows -> T {
    try await EditorAssertionSeam.$handler.withValue({ message, file, line in
        Issue.record("the editor's debug assertion fired: \(message) (\(file):\(line))")
    }) {
        try await body()
    }
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

/// The DEBUG identity oracle and the desync heal stayed quiet (the batch's
/// "the DEBUG identity audit quiet").
@MainActor
private func expectQuietIdentity(_ model: MobileEditorViewModel) {
    #expect(model.identityAuditFailures == 0, "the identity audit stayed quiet")
    #expect(model.desyncRecoveryCount == 0, "the page never desynced")
}

// MARK: - The pins

@MainActor
@Suite("VM-2 — the keystroke fence around a structural flight (probe 2 inverted, per door)", .serialized)
struct MobileStructuralFlightFenceTests {
    private static let seedA = "Alpha beta. Gamma delta."
    private static let seedB = "Second block prose."

    // MARK: Divide — the three roads

    /// **THE PIN (probe 2 inverted), her keyboard's road.** Keys typed at the
    /// caret while the divide lands — a ⌫ among them — are refused at the
    /// gate, and the refusal is said once the flight lands; the divide lands
    /// whole, nothing reads twice, no stale write is rescued.
    ///
    /// RED ON OLD: the gate approved them; the whole OLD block was written
    /// after the divide — `["Alpha beta. XGamma delta.", "Gamma delta.", …]`,
    /// the moved half reading twice — plus a spurious conflict take holding
    /// the divide's real `"Alpha beta."`, and no sentence.
    @Test func keysTypedWhileADivideLandsAreRefusedAndSaid() async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: [Self.seedA, Self.seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = try host(surface)
            defer { dismiss(window, surface) }
            let textView = surface.textView
            textView.selectedRange = NSRange(location: 12, length: 0)  // "Alpha beta. |Gamma"

            try await duringTheFlight(model, db: db, door: {
                await model.structural.divide(atSurfaceCaret: 12)
            }, inTheWindow: {
                keyboardType(textView, "X")
                keyboardType(textView, "Y")
                keyboardDelete(textView)
            })

            #expect(try await storedBlockTexts(db, postID: postID)
                == ["Alpha beta.", "Gamma delta.", Self.seedB],
                "the divide landed whole and nothing typed in its window reached the store")
            #expect(try await conflictTakes(db) == 0, "no stale write was rescued")
            #expect(model.statusMessage == StructuralUndoCopy.anotherIsLanding,
                    "the refusal is said after the flight lands")
            #expect(model.statusAction == .undo, "the divide's own Undo stays beside it")
            expectQuietIdentity(model)
        } }
    }

    /// **Road B, divide.** The same refusal through the harness's own gate
    /// consult (`typeEdit`) — the model-level twin of the keyboard road.
    ///
    /// RED ON OLD: `["Alpha beta. Gamma delta.X", "Gamma delta.", …]`, a
    /// conflict take, and the status line empty.
    @Test func anEditTheGateIsAskedAboutDuringADivideIsRefusedAndSaid() async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: [Self.seedA, Self.seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = try host(surface)
            defer { dismiss(window, surface) }
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
        } }
    }

    /// **Road C, divide.** An edit that reaches the text with no gate consult
    /// (the system's own rewrites) is withheld: nothing of it is written, the
    /// page is re-read from the store before the flight ends, and the
    /// withholding is said. ONE block, so the write lands in the last block,
    /// where its widened report routes to `.block(0)` — the edit the storage
    /// belt exists to withhold (in a block with a separator after it the same
    /// write is round 2's M12 on either tree: unroutable, healed by a re-read,
    /// never a stale write).
    ///
    /// RED ON OLD: routed to `.block(0)` and written whole after the divide —
    /// `["Alpha beta. Gamma delta.X", "Gamma delta."]` plus a conflict take.
    @Test func aGatelessEditDuringADivideIsWithheldAndThePageReReadFromTheStore() async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: [Self.seedA])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = try host(surface)
            defer { dismiss(window, surface) }
            let storage = surface.textView.textStorage
            let end = (Self.seedA as NSString).length

            try await duringTheFlight(model, db: db, door: {
                await model.structural.divide(atSurfaceCaret: 12)
            }, inTheWindow: {
                systemEdit(storage, at: end, insert: "X")
            })

            #expect(try await storedBlockTexts(db, postID: postID)
                == ["Alpha beta.", "Gamma delta."])
            #expect(try await conflictTakes(db) == 0)
            // The page agrees with the store — the withheld bytes did not linger.
            #expect(storage.string == "Alpha beta.\nGamma delta.")
            #expect(!model.autosave.isDirty)
            #expect(model.statusMessage == StructuralUndoCopy.anotherIsLanding)
            expectQuietIdentity(model)
        } }
    }

    // MARK: Merge — prose must not land in a released block

    /// **Her keyboard's road, merge.** A key typed in the trailing block
    /// while it merges with the one above is refused and said — it can never
    /// reach the released source's take.
    ///
    /// RED ON OLD: the key was approved and written into the trailing block's
    /// take after the merge released it — `markerInUnplacedTakes == 1`, the
    /// prose gone from the note (the VM-5 record's "typed prose silently
    /// leaves the note").
    @Test func aKeyTypedWhileAMergeLandsNeverLandsInAReleasedSource() async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, db in
            let postID = try await makePost(
                session, blocks: ["First half.", "Second half goes here."])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = try host(surface)
            defer { dismiss(window, surface) }
            let textView = surface.textView
            let trailing = try #require(model.index.entries.last?.blockID)
            let range = try #require(model.rangeOfBlock(trailing))
            textView.selectedRange = NSRange(location: range.location + 3, length: 0)

            try await duringTheFlight(model, db: db, door: {
                await model.structural.mergeWithPrevious(atSurfaceCaret: range.location + 3)
            }, inTheWindow: {
                keyboardType(textView, "X")
            })

            #expect(try await storedBlockTexts(db, postID: postID)
                == ["First half.\nSecond half goes here."])
            #expect(try await markerInUnplacedTakes(db, "X") == 0,
                    "nothing she typed landed in a released source")
            #expect(try await conflictTakes(db) == 0)
            #expect(model.statusMessage == StructuralUndoCopy.anotherIsLanding)
            expectQuietIdentity(model)
        } }
    }

    /// **Road C, merge.** A gate-less edit into the trailing (last) block while
    /// it merges is withheld — it can never reach the released source's take.
    ///
    /// RED ON OLD: `markerInUnplacedTakes == 1` — the edit's whole-block text
    /// was written into the released trailing source.
    @Test func aGatelessEditDuringAMergeNeverLandsInAReleasedSource() async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, db in
            let postID = try await makePost(
                session, blocks: ["First half.", "Second half goes here."])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = try host(surface)
            defer { dismiss(window, surface) }
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
        } }
    }

    // MARK: Extract and Make Block — the lifted span must not read twice

    /// **Her keyboard's road, extract.** A key typed at the end of the source
    /// while its first sentence is extracted is refused and said; the span
    /// reads once.
    ///
    /// RED ON OLD: the source's whole OLD text (span included) was written
    /// over the remainder — `["Alpha beta.", "Alpha beta. Gamma delta.X", …]`,
    /// the span twice, plus a conflict take.
    @Test func aKeyTypedWhileAnExtractLandsNeverDuplicatesTheSpan() async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: [Self.seedA, Self.seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = try host(surface)
            defer { dismiss(window, surface) }
            let textView = surface.textView
            textView.selectedRange = NSRange(location: (Self.seedA as NSString).length, length: 0)

            try await duringTheFlight(model, db: db, door: {
                await model.structural.extractSelection(range: NSRange(location: 0, length: 11))
            }, inTheWindow: {
                keyboardType(textView, "X")
            })

            #expect(try await storedBlockTexts(db, postID: postID)
                == ["Alpha beta.", "Gamma delta.", Self.seedB],
                "the span was lifted out once and the source kept only the rest")
            #expect(try await conflictTakes(db) == 0)
            #expect(model.statusMessage == StructuralUndoCopy.anotherIsLanding)
            expectQuietIdentity(model)
        } }
    }

    /// **Her keyboard's road, make block** (two divides as one compound): a key
    /// typed at the source's end while it lands never resurrects the pre-op
    /// text.
    ///
    /// RED ON OLD: `["Alpha beta. Gamma delta. Epsilon zeta.X", "Gamma
    /// delta.", "Epsilon zeta.", …]` plus a conflict take.
    @Test func aKeyTypedWhileMakeBlockLandsNeverResurrectsTheWholeSource() async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, db in
            let seed = "Alpha beta. Gamma delta. Epsilon zeta."
            let postID = try await makePost(session, blocks: [seed, Self.seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = try host(surface)
            defer { dismiss(window, surface) }
            let textView = surface.textView
            textView.selectedRange = NSRange(location: (seed as NSString).length, length: 0)

            try await duringTheFlight(model, db: db, door: {
                await model.structural.makeBlockFromSelection(
                    range: NSRange(location: 12, length: 12))  // "Gamma delta."
            }, inTheWindow: {
                keyboardType(textView, "X")
            })

            #expect(try await storedBlockTexts(db, postID: postID)
                == ["Alpha beta.", "Gamma delta.", "Epsilon zeta.", Self.seedB])
            #expect(try await conflictTakes(db) == 0)
            #expect(model.statusMessage == StructuralUndoCopy.anotherIsLanding)
            expectQuietIdentity(model)
        } }
    }

    // MARK: The structural undo door — the same window

    /// **Her keyboard's road, the undo door.** An undo of a divide is a
    /// structural flight with the same window (flush → the inverse on the
    /// runner → the settle's read) over a page that still shows the divided
    /// note. A key typed into the first half while it lands is refused and
    /// said; the undo lands whole; the undo's own Redo stays beside the
    /// sentence.
    ///
    /// RED ON OLD: the key was approved and the first half's OLD text
    /// (`"Alpha beta.X"`) written after the inverse restored the whole —
    /// the undo reverses itself (`["Alpha beta.X", …]`) and the restored text
    /// lands in a spurious conflict take.
    @Test func aKeyTypedWhileAnUndoLandsIsRefusedAndTheUndoLandsWhole() async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: [Self.seedA, Self.seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = try host(surface)
            defer { dismiss(window, surface) }
            let textView = surface.textView

            await model.structural.divide(atSurfaceCaret: 12)
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["Alpha beta.", "Gamma delta.", Self.seedB], "precondition: divided")
            textView.selectedRange = NSRange(location: 11, length: 0)  // "Alpha beta.|"

            try await duringTheFlight(model, db: db, flying: { model.undoDoor.inFlight }, door: {
                await model.undoDoor.beginUndo(from: .receipt)
            }, inTheWindow: {
                keyboardType(textView, "X")
            })

            #expect(try await storedBlockTexts(db, postID: postID)
                == [Self.seedA, Self.seedB], "the undo landed whole")
            #expect(try await conflictTakes(db) == 0, "no stale write was rescued")
            #expect(model.statusMessage == StructuralUndoCopy.anotherIsLanding)
            #expect(model.statusAction == .redo, "the undo's own Redo stays beside it")
            expectQuietIdentity(model)
        } }
    }

    // MARK: Insert block below — exempt (its row is hollow)

    /// **Insert Below is EXEMPT from the fence** (PROVISIONAL — the
    /// orchestrator's r2 call; hers at the merge, the alternative being to
    /// fence it like every door). `newBlock` rewrites no existing text, so a
    /// key typed into the block above while it lands records that block's
    /// CURRENT text: never lost, never duplicated, no rescue — and the door's
    /// own receipt, not a refusal. GREEN ON BOTH TREES by design: the pre-fix
    /// tree did exactly this (the row was hollow), and the fix keeps it.
    @Test func aKeyTypedWhileInsertBelowLandsIsNeitherLostNorDuplicated() async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: [Self.seedA, Self.seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = try host(surface)
            defer { dismiss(window, surface) }
            let textView = surface.textView
            let blockA = try #require(model.index.entries.first?.blockID)
            textView.selectedRange = NSRange(
                location: (Self.seedA as NSString).length, length: 0)

            try await duringTheFlight(model, db: db, door: {
                await model.structural.insertBlockBelow(blockID: blockA)
            }, inTheWindow: {
                keyboardType(textView, "X")
            })

            #expect(try await storedBlockTexts(db, postID: postID)
                == [Self.seedA + "X", "", Self.seedB],
                "the key landed where she typed it, once; the new block stands empty")
            #expect(try await conflictTakes(db) == 0)
            #expect(model.statusMessage == MobileStructuralController.blockInsertedStatus,
                    "the door's own receipt — nothing was refused")
            expectQuietIdentity(model)
        } }
    }

    // MARK: The fence is gone once the flight has landed

    /// **A guard, GREEN ON BOTH TREES:** after a flight lands, typing is
    /// ordinary again — the very next key, typed the way her keyboard types
    /// it, lands at once and is saved, and nothing is said.
    ///
    /// r1 typed this key through a bare programmatic `insertText` (no gate
    /// consult): its report's width then depended on what earlier suites left
    /// in the host, and it desynced on BOTH trees in some company — a road no
    /// keyboard takes (§7 batch 2 ▸ "Iteration r1 → r2"). Her road binds.
    @Test func afterTheFlightLandsTypingIsOrdinaryAgain() async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: [Self.seedA, Self.seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = try host(surface)
            defer { dismiss(window, surface) }
            let textView = surface.textView

            await model.structural.divide(atSurfaceCaret: 12)
            #expect(!model.structural.structuralInFlight)
            #expect(keyboardType(textView, "Z"), "the gate is open again")
            #expect(model.autosave.isDirty, "the key landed and recorded at once")
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["Alpha beta.", "ZGamma delta.", Self.seedB])
            #expect(model.statusMessage == nil, "nothing was refused, so nothing is said")
            expectQuietIdentity(model)
        } }
    }
}
