//
//  MobileUnarmedEditRoutingTests.swift
//  VariorumMobileTests
//
//  **VM-24 — an unarmed report is routed from the characters that changed**
//  (the record `notes/plans/vm-24-unwarned-edit-routing.md`, §4.1–§4.3 and
//  batch A; her words: a word the keyboard just put in snaps back, with a
//  flicker).
//
//  THE MECHANISM these pin. An edit that reaches the storage without the
//  editor's gate having armed it — autocorrect, dictation, a marked-text
//  commit, any programmatic `replace`/`insertText`, or a typed character whose
//  arming a different report spent first (her phone's own E1 #50–#52) — is
//  routed by `fallbackVerdict` from the storage's `didProcessEditing` report.
//  That report is the range AFTER attribute fixing, which on iOS runs through
//  the paragraph's terminator (TEXTKIT2 §3). In a block with a block after
//  it, that terminator is the block SEPARATOR: the old range rebuilt from the
//  report crosses it, the verdict refuses, and `desyncRecovery` re-reads the
//  note from the store, where the edit was never recorded — the snap-back.
//
//  WHY EACH REPORT HERE IS WIDENED EVERY TIME — by construction, not luck.
//  Every edit these pins make is a storage write whose new run carries a font
//  and NO paragraph style (`unarmedEdit`, the fence suite's `systemEdit`
//  shape), landing mid-paragraph or at a paragraph's end — never at its
//  start — inside a paragraph whose every character wears the surface's base
//  paragraph style (`MobileEditorStyle.baseAttributes`, written by the
//  materializer). Attribute fixing therefore MUST write the paragraph's style
//  over the new run, and iOS reports that write from the edit's location
//  through the paragraph's terminator (TEXTKIT2 §3's iOS fixing finding;
//  round 2's M12 `{8, 9}`; VM-2's r1 window, where this very write refused
//  in a non-last block on both trees in every run). No earlier suite can
//  leave the run already wearing the style object — it carries none — which
//  is the difference from a typed `insertText`, whose typing attributes can
//  (TEXTKIT2 §3, VM-2). And each pin ASSERTS the widening it relies on, read
//  from the storage's own notifications (`StorageReports`), so a toolchain
//  that stopped widening would turn the pin red at its precondition, never
//  green over nothing.
//
//  These pins drive the UNARMED road on purpose — it is the road under
//  repair — so TEXTKIT2 §3's rule for pins that claim her keyboard's road
//  (consult the gate first) does not apply to them (the record §5's rule).
//
//  RED ON OLD (`4b0eaaacb`, main's production code): the routed pins desync
//  (recorded as a failing issue — `withDesyncsRecorded` — never a host kill)
//  and the store never receives the edit; the control is green on both trees.
//  These pins use ONLY API that exists on the base tree, so this file builds
//  against it unchanged for the red build.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The posture and the assertion seam (the fence suite's, file-local)

/// The posture her phone types in (the fence suite's and the caret suite's
/// `host`): the surface in the foreground scene's key window, any responder
/// an earlier suite left holding the keyboard resigned first, the Write text
/// view first responder.
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

/// The editor's debug assertion RECORDED as a failing issue instead of
/// stopping the host (the fence suite's `withDesyncsRecorded`): task-scoped,
/// so it reaches this pin and the tasks it spawns (a desync's heal) and
/// nothing running beside it. It never makes a pin green — a desync still
/// fails the pin, by this issue and by its `desyncRecoveryCount` expectation.
@MainActor
private func withDesyncsRecorded<T>(_ body: () async throws -> T) async rethrows -> T {
    try await EditorAssertionSeam.$handler.withValue({ message, file, line in
        Issue.record("the editor's debug assertion fired: \(message) (\(file):\(line))")
    }) {
        try await body()
    }
}

/// A trace recorder of this pin's OWN, armed (`MobileEditTraceTests`' shape):
/// it lets a pin read whether its edit reached the report with no gate
/// consult, invisibly to every suite running beside it. Arming the trace
/// changes nothing the editor does (`armingTheTraceChangesNothingTheEditorDoes`).
@MainActor
private func withOwnTrace<T>(_ body: () async throws -> T) async rethrows -> T {
    try await MobileEditTrace.$testRecorder.withValue(MobileEditTrace.Recorder(armed: true)) {
        try await body()
    }
}

// MARK: - The unarmed edit and what the storage said about it

/// **The unarmed edit**: a storage write the gate is never asked about (no
/// `shouldChangeTextIn` — a direct `replaceCharacters`, the road the system's
/// own rewrites reach the report by), whose new run carries a font and no
/// paragraph style — the construction the header explains.
@MainActor
private func unarmedEdit(_ storage: NSTextStorage, replacing range: NSRange, with text: String) {
    storage.replaceCharacters(
        in: range,
        with: NSAttributedString(
            string: text, attributes: [.font: MobileEditorStyle.baseFont]))
}

/// The storage's OWN account of each character edit while installed: the
/// range it had accumulated before attribute fixing (`willProcessEditing`)
/// and the range it reported after (`didProcessEditing`) — read from its
/// notifications, so the pin observes without standing between the storage
/// and the model's delegate.
@MainActor
private final class StorageReports {
    private weak var storage: NSTextStorage?
    private var observers: [NSObjectProtocol] = []
    private(set) var beforeFixing: [NSRange] = []
    private(set) var reported: [NSRange] = []

    init(_ storage: NSTextStorage) {
        self.storage = storage
        let center = NotificationCenter.default
        observers.append(center.addObserver(
            forName: NSTextStorage.willProcessEditingNotification, object: storage, queue: nil
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.note(afterFixing: false) }
        })
        observers.append(center.addObserver(
            forName: NSTextStorage.didProcessEditingNotification, object: storage, queue: nil
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.note(afterFixing: true) }
        })
    }

    private func note(afterFixing: Bool) {
        guard let storage, storage.editedMask.contains(.editedCharacters) else { return }
        if afterFixing {
            reported.append(storage.editedRange)
        } else {
            beforeFixing.append(storage.editedRange)
        }
    }

    func stop() {
        for observer in observers { NotificationCenter.default.removeObserver(observer) }
        observers.removeAll()
    }
}

// MARK: - The flight hold (the fence suite's, file-local)

/// Holds the in-memory store's one serial queue until `release()` — a
/// structural flight's window, opened deterministically (the fence suite's
/// `StoreHold`, `MobileStructuralFlightFenceTests.swift`).
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

/// Runs a structural `door` with the store held, waits until its flight is
/// up and parked on the store, runs `inTheWindow` there, then releases the
/// store and lets the door land; finishes with a flush. The hold is ALWAYS
/// released, whatever the window throws (the fence suite's `duringTheFlight`).
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
        try #require(model.structural.structuralInFlight, "the flight is up and parked on the held store")
        try inTheWindow()
    } catch {
        failure = error
    }
    try await hold.release()
    await flight.value
    await model.autosave.flushNow()
    if let failure { throw failure }
}

// MARK: - Store reads

/// Live takes labelled `'conflict'` anywhere in the store — the card a stale
/// autosave's VX-683 B rescue mints.
@MainActor
private func conflictTakes(_ db: AppDatabase) async throws -> Int {
    try await db.read { db in
        try Int.fetchOne(
            db,
            sql: "SELECT COUNT(*) FROM variant WHERE label = 'conflict' AND deleted_at IS NULL")
            ?? 0
    }
}

/// The DEBUG identity oracle and the desync heal stayed quiet.
@MainActor
private func expectQuietIdentity(_ model: MobileEditorViewModel) {
    #expect(model.identityAuditFailures == 0, "the identity audit stayed quiet")
    #expect(model.desyncRecoveryCount == 0, "the page never desynced")
}

// MARK: - The pins

@MainActor
@Suite("VM-24 — an unarmed report is routed from the characters that changed", .serialized)
struct MobileUnarmedEditRoutingTests {
    private nonisolated static let seedA = "Alpha beta. Gamma delta."  // 24 units; its separator at 24
    private nonisolated static let seedB = "Second block prose."

    /// One unarmed edit inside block 0 (which has a block after it), and the
    /// block text it must leave behind.
    struct InBlockEdit: Sendable, CustomTestStringConvertible {
        let name: String
        let location: Int
        let length: Int
        let text: String
        let blockAfter: String
        var testDescription: String { name }
    }

    nonisolated static let inBlockEdits: [InBlockEdit] = [
        InBlockEdit(
            name: "an insert at the block's end", location: 24, length: 0, text: "X",
            blockAfter: "Alpha beta. Gamma delta.X"),
        InBlockEdit(
            name: "an insert mid-paragraph", location: 12, length: 0, text: "and ",
            blockAfter: "Alpha beta. and Gamma delta."),
        InBlockEdit(
            name: "a replace mid-paragraph", location: 12, length: 5, text: "Om",
            blockAfter: "Alpha beta. Om delta."),
    ]

    /// **PIN 1 — THE NEW PIN, RED ON OLD.** A gate-less edit inside a block
    /// that has a block after it, whose report fixing widens through the
    /// block's terminator, is routed to its block: no desync, the page holds
    /// the text, the store holds it in that block's take after a flush, the
    /// DEBUG identity audit stays quiet, and the next block is untouched.
    ///
    /// RED ON OLD: the old range rebuilt from the widened report crosses the
    /// separator → `.refuse` → `desyncRecovery` (a recorded assertion, the
    /// count 1) — the edit is never recorded, so the store keeps the old text
    /// and the heal puts it back on the page: her snap-back.
    @Test(arguments: inBlockEdits)
    func anUnarmedEditWhoseReportIsWidenedPastItsBlockRoutesToItsBlock(
        _ edit: InBlockEdit
    ) async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, db in
            try await withOwnTrace {
                let postID = try await makePost(session, blocks: [Self.seedA, Self.seedB])
                let (model, surface) = await makeSurfaceEditor(session, postID: postID)
                let window = try host(surface)
                defer { dismiss(window, surface) }
                let storage = surface.textView.textStorage
                let variantA = try #require(model.index.entries.first?.variantID)
                let variantB = try #require(model.index.entries.last?.variantID)
                let lengthB = (Self.seedB as NSString).length
                let lengthAfter = (edit.blockAfter as NSString).length
                let inserted = (edit.text as NSString).length

                let reports = StorageReports(storage)
                defer { reports.stop() }
                unarmedEdit(
                    storage, replacing: NSRange(location: edit.location, length: edit.length),
                    with: edit.text)

                // Non-vacuity — the road and the widening this pin is about.
                #expect(MobileEditTrace.summary.gatelessReports == 1,
                        "the edit reached the storage report with no gate consult")
                #expect(reports.beforeFixing.first
                        == NSRange(location: edit.location, length: inserted),
                        "before fixing, the storage's range is exactly the characters that changed")
                let reported = try #require(reports.reported.first)
                try #require(reported.upperBound > lengthAfter,
                             "fixing widened the report through block 0's terminator — the separator at \(lengthAfter) (reported \(reported))")

                // The routing.
                #expect(model.desyncRecoveryCount == 0, "routed to its block, never refused")
                #expect(storage.string == edit.blockAfter + "\n" + Self.seedB,
                        "the page holds the text")
                #expect(model.index.entries.map(\.length) == [lengthAfter, lengthB],
                        "block 0 took the change; block 1 is untouched")
                #expect(model.autosave.isDirty, "the edit was recorded for autosave")
                await model.autosave.flushNow()
                #expect(try await storedText(db, variantID: variantA) == edit.blockAfter,
                        "the store holds it in that block's take")
                #expect(try await storedText(db, variantID: variantB) == Self.seedB,
                        "the next block's take is untouched")
                #expect(try await conflictTakes(db) == 0, "nothing was rescued as a conflict")
                #expect(storage.string == edit.blockAfter + "\n" + Self.seedB,
                        "the page still holds the text after the flush — no heal put the old words back")
                expectQuietIdentity(model)
            }
        } }
    }

    /// **PIN 2 — THE CONTROL, GREEN ON BOTH TREES.** A gate-less replace that
    /// truly spans a block separator still refuses and heals from the store,
    /// and nothing is written to either block's take: the storage's own
    /// pre-fixing range of such a change still crosses the separator, so
    /// routing from the changed characters cannot loosen this refusal.
    @Test func anUnarmedReplaceThatTrulySpansASeparatorStillRefusesAndHeals() async throws {
        try await withEditorAssertionsMuted { try await withEditorWorld { session, db in
            let seedA = "Alpha beta."     // 11 units; its separator at 11
            let seedB = "Gamma delta."
            let postID = try await makePost(session, blocks: [seedA, seedB])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = try host(surface)
            defer { dismiss(window, surface) }
            let storage = surface.textView.textStorage
            let variantA = try #require(model.index.entries.first?.variantID)
            let variantB = try #require(model.index.entries.last?.variantID)
            let page = seedA + "\n" + seedB

            let reports = StorageReports(storage)
            defer { reports.stop() }
            // (9, 5) is "a.\nGa": from inside block 0, through the separator,
            // into block 1.
            unarmedEdit(storage, replacing: NSRange(location: 9, length: 5), with: "Z")
            #expect(reports.beforeFixing.first == NSRange(location: 9, length: 1),
                    "non-vacuity: the changed characters are the replacement itself, whose old span (9, 5) crosses the separator at 11")

            #expect(model.desyncRecoveryCount == 1, "refused and healed, exactly as before")
            await settleEditor(until: { storage.string == page })
            #expect(storage.string == page, "the page was healed from the store")
            await model.autosave.flushNow()
            #expect(try await storedText(db, variantID: variantA) == seedA,
                    "nothing was written to block 0's take")
            #expect(try await storedText(db, variantID: variantB) == seedB,
                    "nothing was written to block 1's take")
            #expect(try await conflictTakes(db) == 0)
            #expect(model.identityAuditFailures == 0)
        } }
    }

    /// **PIN 3 — THE SPENT ARMING, RED ON OLD.** Her phone's E1 #50–#52: the
    /// gate is asked about a character at offset n and arms; a DIFFERENT
    /// report lands first and takes the arming (here a net-zero replace in the
    /// LAST block — E1 #51's Δ+0 — whose widened report can only run to the
    /// document's end, so it routes on any tree); the consulted insert then
    /// lands with no arming left, and its report is widened through block 0's
    /// terminator. It routes to block 0.
    ///
    /// RED ON OLD: the second report refuses → desync; the comma never reaches
    /// the store.
    @Test func aConsultedInsertWhoseArmingWasSpentRoutesToItsBlock() async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, db in
            try await withOwnTrace {
                let seedA = "Alpha beta."     // 11 units; its separator at 11
                let seedB = "Gamma delta."
                let postID = try await makePost(session, blocks: [seedA, seedB])
                let (model, surface) = await makeSurfaceEditor(session, postID: postID)
                let window = try host(surface)
                defer { dismiss(window, surface) }
                let storage = surface.textView.textStorage
                let variantA = try #require(model.index.entries.first?.variantID)
                let variantB = try #require(model.index.entries.last?.variantID)

                // E1 #50: the gate is asked about one character at 5, and arms.
                #expect(model.shouldChangeText(
                    in: NSRange(location: 5, length: 0), replacement: ","),
                    "the consult approves the comma")
                let reports = StorageReports(storage)
                defer { reports.stop() }
                // E1 #51: a different report lands first — the 'm' at 14 in
                // "Gamma", replaced by itself (net zero) — and takes the arming.
                unarmedEdit(storage, replacing: NSRange(location: 14, length: 1), with: "m")
                #expect(model.desyncRecoveryCount == 0,
                        "the spending report routes on any tree (its report ends at the document's end)")
                // E1 #52: the consulted insert lands, after 0 gates.
                unarmedEdit(storage, replacing: NSRange(location: 5, length: 0), with: ",")

                // Non-vacuity — the shape E1 recorded, and the widening.
                let traced = MobileEditTrace.events.filter { $0.kind == .report }
                #expect(traced.count == 2)
                #expect(traced.first?.flags.contains(.armingRejected) == true,
                        "the first report took the arming and the binding declined it")
                #expect(traced.last?.flags.contains(.gateless) == true,
                        "the consulted insert arrived with no gate consult left")
                #expect(reports.beforeFixing.last == NSRange(location: 5, length: 1))
                let reported = try #require(reports.reported.last)
                try #require(reported.upperBound > 12,
                             "fixing widened the insert's report through block 0's terminator at 12 (reported \(reported))")

                // The routing.
                #expect(storage.string == "Alpha, beta.\nGamma delta.")
                #expect(model.index.entries.map(\.length) == [12, 12])
                await model.autosave.flushNow()
                #expect(try await storedText(db, variantID: variantA) == "Alpha, beta.",
                        "the comma reached block 0's take")
                #expect(try await storedText(db, variantID: variantB) == seedB)
                #expect(try await conflictTakes(db) == 0)
                #expect(storage.string == "Alpha, beta.\nGamma delta.",
                        "no heal put the old words back")
                expectQuietIdentity(model)
            }
        } }
    }

    /// **PIN 4 — THE FENCE, RED ON OLD** (D-24-2's one new fence pin). A
    /// gate-less edit whose report is widened past a NON-LAST block's end,
    /// while a divide of that block is landing, is routed to its block — where
    /// VM-2's storage belt withholds it: nothing of it is written toward the
    /// store (no stale write, no conflict take), the page is re-read from the
    /// store before the fence drops, the withholding is said as it drops, and
    /// nothing desyncs. (The fence suite's own road-C pins write into the LAST
    /// block, where the old code already routed.)
    ///
    /// RED ON OLD: the widened report refused → `desyncRecovery` in mid-flight
    /// (a flush and a re-read while the act lands), the belt never reached, so
    /// nothing is said.
    @Test func anUnarmedWidenedEditInANonLastBlockDuringADivideIsWithheldAndSaid() async throws {
        try await withDesyncsRecorded { try await withEditorWorld { session, db in
            try await withOwnTrace {
                let postID = try await makePost(session, blocks: [Self.seedA, Self.seedB])
                let (model, surface) = await makeSurfaceEditor(session, postID: postID)
                let window = try host(surface)
                defer { dismiss(window, surface) }
                let storage = surface.textView.textStorage
                let end = (Self.seedA as NSString).length

                var reported: NSRange?
                var beforeFixing: NSRange?
                try await duringTheFlight(model, db: db, door: {
                    await model.structural.divide(atSurfaceCaret: 12)
                }, inTheWindow: {
                    let reports = StorageReports(storage)
                    defer { reports.stop() }
                    unarmedEdit(storage, replacing: NSRange(location: end, length: 0), with: "X")
                    beforeFixing = reports.beforeFixing.first
                    reported = reports.reported.first
                })

                // Non-vacuity — the road and the widening.
                #expect(beforeFixing == NSRange(location: end, length: 1))
                let widened = try #require(reported)
                try #require(widened.upperBound > end + 1,
                             "fixing widened the report through block 0's terminator at \(end + 1) (reported \(widened))")
                #expect(MobileEditTrace.events.contains {
                    $0.kind == .report && $0.flags.contains(.gateless)
                }, "the window's edit reached the report with no gate consult")

                // The fence.
                #expect(try await storedBlockTexts(db, postID: postID)
                    == ["Alpha beta.", "Gamma delta.", Self.seedB],
                    "the divide landed whole and nothing of the withheld edit reached the store")
                #expect(try await conflictTakes(db) == 0, "no stale write was rescued")
                #expect(storage.string == "Alpha beta.\nGamma delta.\n" + Self.seedB,
                        "the page was re-read from the store — the withheld byte did not linger")
                #expect(!model.autosave.isDirty)
                #expect(model.statusMessage == StructuralUndoCopy.anotherIsLanding,
                        "the withholding is said as the fence drops")
                expectQuietIdentity(model)
            }
        } }
    }
}
