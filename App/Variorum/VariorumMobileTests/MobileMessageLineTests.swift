//
//  MobileMessageLineTests.swift
//  VariorumMobileTests
//
//  **VM-61 — ONE MESSAGE SEAM, ONE LINE ON THE PHONE** (umbrella VM-55, batch
//  2a). Four suites:
//
//  · `MobileLineShowRuleTests` — the phone's show rule as PURE tests over the
//    shared seam's one placement rule, and the seam's behaviour under the
//    phone's placement (what draws, what is dropped, what fades, what a
//    speaker takes back). Her VM-44 ruling is the oracle: *"no line for
//    ordinary acts; a short line with Undo when something leaves the page,
//    and for refusals"*; `receipt_style` is not read (PROVISIONAL P-55-1).
//  · `MobileMessageLineGeometryTests` — the face's pure geometry rules: where
//    the line sits (above the tab bar, above the keyboard, never below the
//    safe area) and where a touch is taken (only on the line's door).
//  · `MobileMessageLineHostTests` — the host, in a REAL scene window: the
//    overlay floats above the app's window (and a sheet presented on it),
//    never becomes key, takes a touch only on its door, sits above the tab
//    bar and the keyboard, and goes when the shell's probe goes.
//  · `MobileMessageLineInsetTests` (VM-55 batch 2b, 2a follow-up 2) — the face
//    in a real window on the inset it is FED, with a home indicator (34) and
//    without (0): above the bar and the inset either way.
//  · `MobileLineDoorTests` — the phone's doors over a REAL store: each door's
//    class, each removal's Undo over its existing road (pressed, and the
//    store read back), the note's line taken back as the note moves on.
//
//  **How a regression trips them** (the brief's ask — VM-61 is a Feature, so
//  red-on-old does not bind, but each pin must be a real check): a phone
//  placement that drew ordinary receipts reds `anOrdinaryReceiptDrawsNothing`
//  and every "says nothing" door pin (`current` would be non-nil); one that
//  dropped removals or read the receipt style reds the table and
//  `theReceiptStyleIsNotReadOnThePhone`; a removal wired to a wrong road (or
//  none) reds the press-and-read-the-store pins; a stale structural Undo left
//  standing reds `theNotesUndoNeverOutlivesItsMoment`; a host that took
//  touches off its door, sat over the tab bar or the keyboard, or became key
//  reds the host pin.
//

import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// Polls `condition` on the main actor until it holds (the line's door frame
/// and an Undo's write both land a few run-loop turns later).
@MainActor
private func eventually(
    _ turns: Int = 300, _ condition: @MainActor () async throws -> Bool
) async rethrows -> Bool {
    for _ in 0..<turns {
        if try await condition() { return true }
        try? await Task.sleep(for: .milliseconds(10))
    }
    return try await condition()
}

// MARK: - The show rule

@MainActor
@Suite("VM-61 — the phone's show rule over the one seam")
struct MobileLineShowRuleTests {
    /// The phone build answers its placement once, in the shared seam.
    @Test func thePhonesPlacementIsItsLine() {
        #expect(StatusCenter().placement == .phoneLine)
    }

    /// **THE TABLE** — every kind × every receipt style, under the phone's
    /// placement: refusals and offers always draw; a receipt draws only when
    /// it left the page; the receipt style never changes an answer (P-55-1).
    @Test func thePhonesShowRuleIsHerRuling() {
        for style in ReceiptStyle.allCases {
            for leaves in [false, true] {
                #expect(StatusCenter.slot(
                    kind: .refusal, leavesPage: leaves, placement: .phoneLine,
                    receiptStyle: style) == .toast, "a refusal always draws (\(style))")
                #expect(StatusCenter.slot(
                    kind: .offer, leavesPage: leaves, placement: .phoneLine,
                    receiptStyle: style) == .toast, "an offer always draws (\(style))")
            }
            #expect(StatusCenter.slot(
                kind: .receipt, leavesPage: false, placement: .phoneLine,
                receiptStyle: style) == nil, "no line for an ordinary act (\(style))")
            #expect(StatusCenter.slot(
                kind: .receipt, leavesPage: true, placement: .phoneLine,
                receiptStyle: style) == .toast, "a removal draws (\(style))")
        }
    }

    @Test func anOrdinaryReceiptDrawsNothingButReachedTheSeam() {
        let status = StatusCenter()
        status.receipt("Take moved up.")
        #expect(status.current == nil)
        #expect(status.quietLine == nil, "the phone has no quiet slot")
        #if DEBUG
        #expect(status.lastDroppedReceipt == "Take moved up.",
                "dropped AT the seam — produced, never silently unsaid")
        #endif
    }

    @Test func aRefusalAlwaysDraws() throws {
        let status = StatusCenter()
        status.refuse("This note is locked — unlock it to add a block.")
        let line = try #require(status.current)
        #expect(line.kind == .refusal)
        #expect(!line.leavesPage)
    }

    @Test func aRemovalDrawsWithItsUndo() throws {
        let status = StatusCenter()
        var pressed = false
        status.removal("Block deleted.", undo: .init(label: "Undo", perform: { pressed = true }))
        let line = try #require(status.current)
        #expect(line.kind == .receipt)
        #expect(line.leavesPage)
        #expect(line.text == "Block deleted.")
        line.action?.perform()
        #expect(pressed, "the Undo the door handed is the Undo the line carries")
    }

    /// The merge's and the cross-block join's shipped Undo had no words: a
    /// removal may carry its Undo alone, and only a removal may (P-55-5).
    @Test func aRemovalMayCarryItsUndoAloneButNeverNothing() throws {
        let status = StatusCenter()
        status.removal("", undo: nil)
        #expect(status.current == nil, "no words and no Undo says nothing")
        status.removal("", undo: .init(label: "Undo", perform: {}))
        let line = try #require(status.current)
        #expect(line.text.isEmpty)
        #expect(line.action?.label == "Undo")
        status.clear()
        status.refuse("")
        #expect(status.current == nil, "the other doors keep the empty-text guard")
    }

    /// A dropped ordinary receipt leaves what is on screen alone — a refusal
    /// she is still reading is not swept away by an act that says nothing.
    @Test func anOrdinaryActNeverSweepsAwayARefusal() throws {
        let status = StatusCenter()
        status.refuse("That couldn't be done.")
        status.receipt("Added to “Essays”.")
        #expect(status.current?.text == "That couldn't be done.")
        #expect(status.current?.kind == .refusal)
    }

    /// P-55-1: the synced receipt setting adds and removes nothing on the phone.
    @Test func theReceiptStyleIsNotReadOnThePhone() {
        for style in ReceiptStyle.allCases {
            let status = StatusCenter()
            status.receiptStyle = style
            status.receipt("Committed — a saved moment of this take is kept.")
            #expect(status.current == nil, "ordinary stays silent under \(style)")
            status.removal("Note moved to the Trash.", undo: nil)
            #expect(status.current?.leavesPage == true, "a removal draws under \(style)")
            #expect(status.quietLine == nil)
        }
    }

    /// **The line fades by itself** — on the seam's own one clock.
    @Test func theLineFadesByItself() async {
        let status = StatusCenter()
        status.dismissAfter = .milliseconds(30)
        status.removal("Block archived.", undo: .init(label: "Undo", perform: {}))
        #expect(status.current != nil)
        #expect(await eventually { status.current == nil }, "gone on its own clock")
    }

    /// A speaker takes back only what IT said and only while it shows.
    @Test func aSpeakerTakesBackOnlyItsOwnLine() {
        final class Speaker {}
        let mine = Speaker(), theirs = Speaker()
        let status = StatusCenter()
        status.removal("Merged.", undo: .init(label: "Undo", perform: {}),
                       owner: ObjectIdentifier(mine))
        status.withdraw(owner: ObjectIdentifier(theirs))
        #expect(status.current != nil, "another speaker's withdrawal leaves it")
        status.withdraw(owner: ObjectIdentifier(mine))
        #expect(status.current == nil)
        status.refuse("Something else.")
        status.withdraw(owner: ObjectIdentifier(mine))
        #expect(status.current?.text == "Something else.", "what was said since stands")
    }

    /// The copy door's outcome decides its class where the outcome is.
    @Test func theCopyOutcomesSayTheirClass() {
        #expect(MobileNoteClipboard.Outcome.copied.line == .ordinary)
        // MOVED at VM-265 (the VM-260 run, batch 1b): the direction speaks as
        // one — still always drawn (the seam's `direct`), in the muted ink.
        #expect(MobileNoteClipboard.Outcome.copiedSavedTakes.line == .direction,
                "the copy that did not follow the screen is a direction she must see")
        #expect(MobileNoteClipboard.Outcome.nothingToCopy.line == .refusal)
        #expect(MobileNoteClipboard.Outcome.failed("x").line == .refusal)
    }
}

// MARK: - The face's geometry rules (pure)

@MainActor
@Suite("VM-61 — the one line's geometry rules")
struct MobileMessageLineGeometryTests {
    /// Measured from the WINDOW's foot (the face fills the window).
    @Test func theLineSitsAboveTheBarTheKeyboardAndTheSafeArea() {
        // On a root, keyboard down: above the home indicator and the tab bar.
        #expect(MobileMessageLineModel.footOffset(keyboardOverlap: 0, safeBottom: 34, chromeInset: 44) == 78)
        // Inside a pushed screen, keyboard down: at the safe area's foot.
        #expect(MobileMessageLineModel.footOffset(keyboardOverlap: 0, safeBottom: 34, chromeInset: 0) == 34)
        // Keyboard up (its overlap counts from the window's foot): above it.
        #expect(MobileMessageLineModel.footOffset(keyboardOverlap: 336, safeBottom: 34, chromeInset: 44) == 336)
        // Never inside the home-indicator inset.
        #expect(MobileMessageLineModel.footOffset(keyboardOverlap: 10, safeBottom: 34, chromeInset: 0) == 34)
    }

    @Test func onlyTheShownLinesDoorTakesATouch() {
        let door = CGRect(x: 100, y: 700, width: 40, height: 20)
        let withUndo = StatusCenter.Item(
            id: UUID(), text: "Merged.", action: .init(label: "Undo", perform: {}),
            kind: .receipt, leavesPage: true)
        let plain = StatusCenter.Item(id: UUID(), text: "Refused.", kind: .refusal)
        #expect(MobileMessageLineModel.takesTouch(
            at: CGPoint(x: 110, y: 710), doorFrame: door, showing: withUndo))
        #expect(!MobileMessageLineModel.takesTouch(
            at: CGPoint(x: 10, y: 710), doorFrame: door, showing: withUndo),
                "the line's own ground passes the touch through")
        #expect(!MobileMessageLineModel.takesTouch(
            at: CGPoint(x: 110, y: 710), doorFrame: door, showing: plain),
                "a line with no door takes nothing (a stale frame never revives one)")
        #expect(!MobileMessageLineModel.takesTouch(
            at: CGPoint(x: 110, y: 710), doorFrame: door, showing: nil),
                "nothing showing takes nothing")
        #expect(!MobileMessageLineModel.takesTouch(
            at: CGPoint(x: 110, y: 710), doorFrame: nil, showing: withUndo))
    }

    @Test func theKeyboardsOverlapIsMeasuredFromTheWindowsFoot() {
        let window = CGRect(x: 0, y: 0, width: 393, height: 852)
        #expect(MobileMessageLineModel.keyboardOverlap(
            endFrameInWindow: CGRect(x: 0, y: 516, width: 393, height: 336),
            windowBounds: window) == 336)
        #expect(MobileMessageLineModel.keyboardOverlap(
            endFrameInWindow: CGRect(x: 0, y: 852, width: 393, height: 336),
            windowBounds: window) == 0, "a keyboard below the window covers nothing")
        #expect(MobileMessageLineModel.keyboardOverlap(
            endFrameInWindow: .zero, windowBounds: window) == 0)
    }
}

// MARK: - The host, in a real scene window

@MainActor
@Suite("VM-61 — the one line's host floats over the app")
struct MobileMessageLineHostTests {
    /// **THE HOST PIN.** A real scene window stands in for the app's; a sheet
    /// is presented on it; the shell's probe raises the overlay. The line
    /// floats above both, never takes key, takes a touch only on its door,
    /// sits above the tab bar's inset and then above the keyboard, takes
    /// nothing once it is gone, and the overlay goes with the probe.
    @Test func theLineFloatsOverTheAppAndOnlyItsDoorTakesATouch() async throws {
        try await withEditorWorld { session, _ in
            let scene = try #require(
                UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first,
                "the test host has a window scene")
            let app = UIWindow(windowScene: scene)
            let root = UIViewController()
            root.view.backgroundColor = .systemBackground
            app.rootViewController = root
            app.makeKeyAndVisible()
            defer {
                app.isHidden = true
                app.rootViewController = nil
            }
            let sheet = UIViewController()
            sheet.view.backgroundColor = .systemGray
            root.present(sheet, animated: false)

            let model = MobileMessageLineModel(status: session.status, voice: { .terminal })
            let probe = MobileMessageLineHost.Probe(model: model)
            root.view.addSubview(probe)
            let overlay = try #require(probe.overlay, "joining a scene's window raises the overlay")
            #expect(overlay.windowLevel > app.windowLevel, "above the app's window and its sheet")
            if scene.activationState != .foregroundActive {
                #expect(overlay.isHidden, "never shown over a scene that is not active")
                probe.sceneDidBecomeActive()
            }
            #expect(!overlay.isHidden)
            #expect(!overlay.canBecomeKey)
            #expect(app.isKeyWindow, "the app's window keeps key (and the keyboard)")

            model.chromeInset = 44
            let pressed = LockIsolatedBox(false)
            session.status.removal(
                "Block deleted.",
                undo: .init(label: MobileLine.undoLabel, perform: { pressed.value = true }))
            #expect(await eventually {
                overlay.layoutIfNeeded()
                return model.doorFrame != nil
            }, "the line drew its door")
            let door = try #require(model.doorFrame)
            let center = CGPoint(x: door.midX, y: door.midY)
            #expect(overlay.hitTest(center, with: nil) != nil, "its door takes the touch")
            #expect(overlay.hitTest(CGPoint(x: overlay.bounds.midX, y: 140), with: nil) == nil,
                    "the rest of the screen stays the app's (the sheet under it)")
            #expect(door.minX > 40, "the words come before the door — door \(door)")
            #expect(overlay.hitTest(CGPoint(x: door.minX - 20, y: door.midY), with: nil) == nil,
                    "even the line's own words pass the touch through")
            let safeBottom = overlay.rootViewController?.view.safeAreaInsets.bottom ?? 0
            #expect(door.maxY <= overlay.bounds.maxY - safeBottom - 44 + 0.5,
                    "above the tab bar's inset — door \(door), safe \(safeBottom)")
            // 2a follow-up 2: the line stands on the WINDOW's real inset, fed
            // from UIKit — the face's safe-area-ignoring reader reads zero.
            #expect(model.safeBottom == safeBottom,
                    "the window's own inset feeds the line — model \(model.safeBottom), window \(safeBottom)")

            model.keyboardOverlap = 336
            #expect(await eventually {
                overlay.layoutIfNeeded()
                return (model.doorFrame?.maxY ?? .infinity) <= overlay.bounds.maxY - 336 + 0.5
            }, "above the keyboard — door \(String(describing: model.doorFrame))")

            session.status.clear()
            let lastDoor = try #require(model.doorFrame)
            #expect(overlay.hitTest(CGPoint(x: lastDoor.midX, y: lastDoor.midY), with: nil) == nil,
                    "with nothing showing, nothing takes a touch")
            #expect(!pressed.value)

            probe.removeFromSuperview()
            #expect(probe.overlay == nil, "the overlay goes with the shell")
            #expect(overlay.isHidden)
            root.dismiss(animated: false)
        }
    }
}

// MARK: - The face on the window's real inset (2a follow-up 2)

/// **The face honours the inset it is FED** (VM-55 batch 2b — 2a follow-up 2).
/// The geometry rule's pins feed `footOffset` numbers directly, so nothing
/// drove the face with a real window's inset — and the face read the inset
/// from a `GeometryReader` that ignores the safe area, i.e. ZERO, which sat
/// the line one home-indicator inset too low, over the tab bar's doors (the
/// whole phone target's run of 2026-11-19 07:06–07:19, products of e8609cc6f:
/// `theLineFloatsOverTheAppAndOnlyItsDoorTakesATouch` red, door maxY 822
/// against 796.5, inset 34). Here the face stands in a real window with the
/// tab bar's inset, once as a device WITH a home indicator (34) and once
/// WITHOUT (0): either way its door sits above the bar AND the inset, and
/// close above them — so a face that read zero on the first device is red,
/// and one that floated the line arbitrarily high is red too.
@MainActor
@Suite("VM-61 — the one line stands on the window's real inset")
struct MobileMessageLineInsetTests {
    @Test(arguments: [CGFloat(34), CGFloat(0)])
    func theLineSitsAboveTheBarOnTheInsetItIsFed(_ inset: CGFloat) async throws {
        try await withEditorWorld { session, _ in
            let scene = try #require(
                UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first,
                "the test host has a window scene")
            let window = UIWindow(windowScene: scene)
            let model = MobileMessageLineModel(status: session.status, voice: { .terminal })
            model.safeBottom = inset
            model.chromeInset = 44
            window.rootViewController = UIHostingController(rootView: MobileMessageLineView(model: model))
            window.isHidden = false
            defer {
                window.isHidden = true
                window.rootViewController = nil
            }
            session.status.removal(
                "Block deleted.", undo: .init(label: MobileLine.undoLabel, perform: {}))
            #expect(await eventually {
                window.layoutIfNeeded()
                return model.doorFrame != nil
            }, "the line drew its door")
            let door = try #require(model.doorFrame)
            let ceiling = window.bounds.maxY - inset - 44
            #expect(door.maxY <= ceiling + 0.5,
                    "above the bar and the inset — door \(door), inset \(inset)")
            #expect(door.maxY >= ceiling - 30,
                    "and close above them, not floated away — door \(door), inset \(inset)")
            session.status.clear()
        }
    }
}

// MARK: - The line, the lock and the app-switcher snapshot

@MainActor
@Suite("VM-61 — the one line never shows over an inactive scene nor past its shell")
struct MobileMessageLineSceneTests {
    /// **The line and the lock.** The app-switcher cover (`SnapshotPrivacy`)
    /// is a redaction through the SHELL's environment, which cannot reach the
    /// overlay window — so the overlay follows its scene: hidden as the scene
    /// resigns active (before iOS snapshots it), every standing line withdrawn
    /// on the way to the background, shown again when active. And a lock, or
    /// any state but `.ready`, removes the shell — whose dismantle takes the
    /// overlay down and stops it following the scene.
    ///
    /// **How a regression trips it:** an overlay raised visible over an
    /// inactive scene, not hidden on resigning active (the snapshot), keeping a
    /// line past the background, losing a line on a transient interruption, or
    /// outliving its shell's dismantle each reds one expectation here; an
    /// observer never registered reds `observedScene`.
    @Test func theLineNeverShowsOverAnInactiveSceneNorPastItsShell() async throws {
        try await withEditorWorld { session, _ in
            let scene = try #require(
                UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first,
                "the test host has a window scene")
            let app = UIWindow(windowScene: scene)
            let root = UIViewController()
            app.rootViewController = root
            app.isHidden = false
            defer {
                app.isHidden = true
                app.rootViewController = nil
            }
            let model = MobileMessageLineModel(status: session.status, voice: { .terminal })
            let probe = MobileMessageLineHost.Probe(model: model)
            root.view.addSubview(probe)
            let overlay = try #require(probe.overlay)
            #expect(probe.observedScene === scene, "it follows its own scene's edges")
            #expect(overlay.isHidden == (scene.activationState != .foregroundActive),
                    "never shown over a scene that is not active")
            probe.sceneDidBecomeActive()
            session.status.refuse("That couldn't be done.")
            #expect(!overlay.isHidden)

            // Resigning active (the app switcher, Control Center): hidden
            // before the snapshot, and the line kept.
            probe.sceneWillResignActive()
            #expect(overlay.isHidden, "never in the app-switcher snapshot")
            #expect(session.status.current != nil, "a transient interruption loses nothing")
            probe.sceneDidBecomeActive()
            #expect(!overlay.isHidden)

            // To the background: hidden, and every standing line withdrawn.
            probe.sceneDidEnterBackground()
            #expect(overlay.isHidden)
            #expect(session.status.current == nil, "a line never outlives her leaving the app")
            probe.sceneDidBecomeActive()

            // The shell dismantled — a lock, a reopen, any state but `.ready`.
            MobileMessageLineHost.dismantleUIView(probe, coordinator: ())
            #expect(probe.overlay == nil)
            #expect(overlay.isHidden, "gone before whatever replaces the shell draws")
            #expect(probe.observedScene == nil, "and it follows the scene no more")
            probe.removeFromSuperview()
        }
    }
}

// MARK: - The phone's doors over a real store

@MainActor
@Suite("VM-61 — each phone door's class, and each Undo's road")
struct MobileLineDoorTests {
    // MARK: Removals: a line, with Undo over a road that exists

    @Test func aDeletedNoteSpeaksItsLineAndUndoPutsItBack() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Doomed."])
            let library = MobileLibraryViewModel(session: session)
            let listed = try await db.read { db in try Queries.library(db, limit: 10) }
            let row = try #require(listed.first { $0.postID == postID })
            #expect(await library.confirmDeleteNote(row))
            let line = try #require(session.status.current)
            #expect(line.kind == .receipt)
            #expect(line.leavesPage)
            #expect(line.text == RecoveryCopy.movedToTrashReceipt(.note))
            #expect(line.action?.label == MobileLine.undoLabel)

            line.action?.perform()
            #expect(try await eventually {
                try await db.read { db in
                    try String.fetchOne(
                        db, sql: "SELECT deleted_at FROM container WHERE id = ?",
                        arguments: [postID])
                } == nil
            }, "Undo is the Trash's own Put back")
            #expect(session.status.current?.kind != .refusal, "and it landed quietly")
        }
    }

    /// The shelf row's delete and Book Details' are one act: one line, one road.
    @Test func aDeletedBookSpeaksTheSameLineFromEitherDoorAndUndoPutsItBack() async throws {
        try await withEditorWorld { session, db in
            let (first, second) = try await session.runner.run { ops in
                (try ops.createReading(name: "Essays", kind: .book).id,
                 try ops.createReading(name: "Letters", kind: .book).id)
            }
            let shelf = MobileShelfViewModel(session: session)
            let shelved = try await db.read { try Queries.bookshelf($0) }
            let book = try #require(shelved.first { $0.reading.id == first })
            #expect(await shelf.confirmDeleteBook(book))
            let fromRow = try #require(session.status.current)
            #expect(fromRow.leavesPage)
            #expect(fromRow.text == RecoveryCopy.movedToTrashReceipt(.book))

            let details = MobileBookDetailsModel(session: session, readingID: second)
            await details.refresh()
            #expect(await details.deleteBook())
            let fromDetails = try #require(session.status.current)
            #expect(fromDetails.id != fromRow.id)
            #expect(fromDetails.text == fromRow.text, "the same act says the same line")

            fromDetails.action?.perform()
            #expect(try await eventually {
                try await db.read { db in
                    try String.fetchOne(
                        db, sql: "SELECT deleted_at FROM reading WHERE id = ?",
                        arguments: [second])
                } == nil
            }, "Undo is the Trash's own Put back for a book")
        }
    }

    @Test func theJournalsArchiveSpeaksItsLineAndUndoUnarchives() async throws {
        try await withEditorWorld { session, db in
            let journal = try await session.runner.run { ops -> String in
                let entry = try ops.createPost(title: nil)
                guard case .shelved(let id) = ops.shelveInDailyJournalBook(entry.id) else {
                    throw LineFixtureError.notShelved
                }
                return id
            }
            let shelf = MobileShelfViewModel(session: session)
            let shelved = try await db.read { try Queries.bookshelf($0) }
            let book = try #require(shelved.first { $0.reading.id == journal })
            await shelf.archiveDailyJournal(book)
            let line = try #require(session.status.current)
            #expect(line.leavesPage)
            #expect(line.text == MobileShelfFaces.archivedDailyJournalReceipt(name: book.reading.name))
            line.action?.perform()
            #expect(try await eventually {
                try await db.read { try Queries.reading($0, id: journal) }?.archivedAt == nil
            }, "Undo is the existing unarchive")
        }
    }

    /// A block delete's line carries the NOTE's own Undo — pressed, the block
    /// is back; and the note screen takes the line back as it goes.
    @Test func aBlockDeleteSpeaksWithTheNotesUndoAndTheNoteTakesItBack() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Keep.", "Cut.", "Also cut."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)

            await model.structural.deleteBlock(blockID: model.index.entries[2].blockID)
            var line = try #require(session.status.current)
            #expect(line.leavesPage)
            #expect(line.owner == ObjectIdentifier(model.undoDoor), "the note's own line")
            #expect(line.text.hasPrefix("Block deleted"))
            MobileLine.withdrawNoteLine(of: model.undoDoor, session: session)
            #expect(session.status.current == nil, "the note took its line back as it went")

            await model.structural.deleteBlock(blockID: model.index.entries[1].blockID)
            line = try #require(session.status.current)
            #expect(try await storedBlockTexts(db, postID: postID) == ["Keep."])
            line.action?.perform()
            #expect(try await eventually {
                try await storedBlockTexts(db, postID: postID) == ["Keep.", "Cut."]
            }, "Undo is the note's structural undo door")
        }
    }

    /// A merge's line is its shipped bare Undo — no words (P-55-5).
    @Test func aMergeSpeaksItsWordlessUndo() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["One.", "Two."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            let second = try #require(model.rangeOfBlock(model.index.entries[1].blockID))
            await model.structural.mergeWithPrevious(atSurfaceCaret: second.location + 1)
            #expect(try await storedBlockTexts(db, postID: postID) == ["One.\nTwo."])
            let line = try #require(session.status.current)
            #expect(line.leavesPage)
            #expect(line.text.isEmpty)
            #expect(line.action?.label == MobileLine.undoLabel)
            line.action?.perform()
            #expect(try await eventually {
                try await storedBlockTexts(db, postID: postID) == ["One.", "Two."]
            })
        }
    }

    /// A confirmed Delete Now took something off the page for good: the line,
    /// with no Undo (a purge has no road back).
    @Test func aConfirmedDeleteNowSpeaksWithNoUndo() async throws {
        try await withEditorWorld { session, db in
            let noteID = try await session.runner.run { ops -> String in
                let note = try ops.createPost(title: "Gone soon")
                try ops.deleteContainer(note.id)
                return note.id
            }
            let trash = MobileTrashModel(session: session)
            let inTrash = try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now)
            }
            let row = try #require(inTrash.first { $0.id == noteID })
            let confirm = try #require(TrashPurge.deleteNowConfirm(for: row))
            await trash.confirmPendingPurge(confirm)
            let line = try #require(session.status.current)
            #expect(line.leavesPage)
            #expect(line.action == nil, "no Undo where no road exists")
        }
    }

    // MARK: Ordinary acts: nothing on the line

    @Test func ordinaryActsSayNothing() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["One two three four.", "Next."])
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)

            // Divide: nothing said, and its bare Undo is the ⋯ sheet's now.
            surface.textView.selectedRange = NSRange(location: 8, length: 0)
            await model.structural.divide(atSurfaceCaret: 8)
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["One two", "three four.", "Next."])
            #expect(session.status.current == nil, "a divide says nothing")
            #expect(model.statusAction == .undo, "the model still records its way back")

            // New Block Below: her own example of too noisy.
            await model.structural.insertBlockBelow(blockID: model.index.entries[0].blockID)
            #expect(session.status.current == nil)
            #if DEBUG
            #expect(session.status.lastDroppedReceipt == MobileStructuralController.blockInsertedStatus)
            #endif

            // A star.
            let stars = MobileStarsModel(session: session)
            await stars.toggle(.post(postID), from: .library)
            #expect(stars.isStarred(.post(postID)))
            #expect(session.status.current == nil, "a star says nothing")

            // Joining a book.
            let bookID = try await session.runner.run { ops in
                try ops.createReading(name: "Essays", kind: .book).id
            }
            let membership = MobileMembershipModel(session: session, postID: postID)
            let read = try await db.read { try Queries.reading($0, id: bookID) }
            let book = try #require(read)
            await membership.add(to: book)
            #expect(membership.status == "Added to “Essays”.", "the model keeps its record")
            #expect(session.status.current == nil, "joining a book says nothing")
            #if DEBUG
            #expect(session.status.lastDroppedReceipt == "Added to “Essays”.")
            #endif
        }
    }

    /// A Put back is a restoration — ordinary (P-55-4): the row leaving the
    /// Trash is the answer.
    @Test func aPutBackSaysNothing() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Keep.", "Cut."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            let doomed = model.index.entries[1].blockID
            await model.structural.deleteBlock(blockID: doomed)
            session.status.clear()

            let trash = MobileTrashModel(session: session)
            let inTrash = try await db.read { [now = session.now] db in
                try Queries.trash(db, now: now)
            }
            let row = try #require(inTrash.first { $0.id == doomed })
            await trash.putBack(row)
            #expect(trash.receipt == RecoveryCopy.putBackWhereItWas, "the model keeps its record")
            #expect(session.status.current == nil)
        }
    }

    // MARK: Refusals: always

    @Test func refusalsAlwaysSpeak() async throws {
        try await withEditorWorld { session, db in
            // The structural gate, under a seal.
            let sealed = try await makePost(session, blocks: ["Sealed."], locked: true)
            let (model, _) = await makeSurfaceEditor(session, postID: sealed)
            await model.structural.insertBlockBelow(blockID: model.index.entries[0].blockID)
            var line = try #require(session.status.current)
            #expect(line.kind == .refusal)
            #expect(line.text == "This note is locked — unlock it to add a block.")

            // A door that did nothing: Empty Trash with nothing in it.
            let trash = MobileTrashModel(session: session)
            await trash.requestEmptyTrash()
            line = try #require(session.status.current)
            #expect(line.kind == .refusal)
            #expect(line.text == RecoveryCopy.emptyTrashConfirm([:]))

            // A book that cannot take the note.
            let (postID, bookID) = try await session.runner.run { ops -> (String, String) in
                let post = try ops.createPost(title: "Loose")
                let book = try ops.createReading(name: "Finished", kind: .book)
                try ops.lockReading(book.id)
                return (post.id, book.id)
            }
            let membership = MobileMembershipModel(session: session, postID: postID)
            let read = try await db.read { try Queries.reading($0, id: bookID) }
            let book = try #require(read)
            await membership.add(to: book)
            line = try #require(session.status.current)
            #expect(line.kind == .refusal)
            #expect(line.text == membership.status)
        }
    }

    // MARK: The note's Undo never outlives its moment

    /// M20's law, on the one line: a structural Undo names the stack's top as
    /// it was, so any later word from the same note takes the line back — an
    /// ordinary act it drops, and an undo pressed from the ⋯ sheet.
    @Test func theNotesUndoNeverOutlivesItsMoment() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["Keep.", "Cut."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)

            await model.structural.deleteBlock(blockID: model.index.entries[1].blockID)
            #expect(session.status.current?.leavesPage == true)
            await model.structural.insertBlockBelow(blockID: model.index.entries[0].blockID)
            #expect(session.status.current == nil,
                    "a later ordinary act moved the stack's top — the stale Undo is gone")

            await model.structural.deleteBlock(blockID: model.index.entries[0].blockID)
            #expect(session.status.current?.leavesPage == true)
            await model.undoDoor.beginUndo(from: .sheet)
            #expect(session.status.current == nil,
                    "an undo from the ⋯ sheet lands quietly and takes the line back")
            _ = db
        }
    }

    /// A press that finds nothing to undo says so — a refusal (the Mac
    /// door's class, `ShellActions`).
    @Test func anUndoWithNothingToUndoRefuses() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Nothing done yet."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            await model.undoDoor.beginUndo(from: .sheet)
            let line = try #require(session.status.current)
            #expect(line.kind == .refusal)
            #expect(line.text == StructuralUndoCopy.nothingToUndo)
        }
    }
}

private enum LineFixtureError: Error { case notShelved }
