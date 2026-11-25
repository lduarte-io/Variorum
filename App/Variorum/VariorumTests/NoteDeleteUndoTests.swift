//
//  NoteDeleteUndoTests.swift
//  VariorumTests
//
//  VX-1077 (the VX-1082 run, batch D; `notes/plans/fixes/vx-1082-nov-24-fixes.md`
//  BATCH D) — **deleting ONE note asks nothing: it goes, and a toast with Undo
//  says so; deleting several still asks first.** Her words (2026-11-24, on
//  the ticket): *"remove confirmations on delete note are too annoying - an
//  undo toast at the bottom appearing instead would be sufficient"*; her
//  rulings in its comment: the saved-versions line moves into the toast, a
//  multi-select delete of many notes keeps its confirm, ⌥⌘Z does not undo a
//  note delete, the phone is left as it is.
//
//  The pins drive THE DOOR'S ROAD exactly as every door runs it: the door's
//  own line (`pendingDelete = await NoteDeletion.ask(…)`) into the ONE
//  shipping host (`View.deleteNoteConfirmDialog`, mounted in a `List` row
//  where the Library applies it) whose `onConfirm` is the hosts' own body
//  (`NoteDeletion.fire`), and the toast's Undo pressed as the toast's button
//  presses it (`action.perform()`).
//
//  RED ON OLD, by the fix commit's behavioural revert (its product diff,
//  `NoteDeletion.swift` only, reverse-applied): the first two tests — a
//  single note's ask presents the confirm and deletes nothing, and a landed
//  delete is a doorless receipt (under her default quiet style the toast slot
//  is empty). The third is a GUARD, green on both trees: several notes ask.
//

import AppKit
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-1077 — one note goes with an Undo toast; several still ask", .serialized)
struct NoteDeleteUndoTests {
    /// The shipping modifier over state the test owns, in a `List` row —
    /// where `LibraryCatalogView` applies it (the `NoteDeleteConfirmEdgeTests`
    /// host).
    private struct Host: View {
        @Binding var pending: NoteDeleteConfirm?
        let onConfirm: (NoteDeleteConfirm) -> Void

        var body: some View {
            List {
                Section("Library") {
                    HStack { Text("rows") }
                        .deleteNoteConfirmDialog($pending, onConfirm: onConfirm)
                }
            }
            .frame(width: 480, height: 320)
        }
    }

    @Observable
    final class Box {
        var pending: NoteDeleteConfirm?
    }

    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// Pumps and yields until `done`, or the bound passes.
    private func settle(seconds: TimeInterval = 5, until done: () -> Bool) async {
        let deadline = Date().addingTimeInterval(seconds)
        while !done(), Date() < deadline {
            pump()
            for _ in 0..<10 { await Task.yield() }
        }
    }

    /// The async twin: `done` may read the store.
    private func settleReading(seconds: TimeInterval = 5, until done: () async -> Bool) async {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            if await done() { return }
            pump()
            for _ in 0..<10 { await Task.yield() }
        }
    }

    private static func buttons(in view: NSView?) -> [NSButton] {
        guard let view else { return [] }
        var found: [NSButton] = []
        if let button = view as? NSButton { found.append(button) }
        for sub in view.subviews { found.append(contentsOf: buttons(in: sub)) }
        return found
    }

    /// Mounts the host with the doors' own `onConfirm` (`NoteDeletion.fire`)
    /// and hands the body the window and the box.
    private func withDoor(
        _ session: AppSession, _ body: (NSWindow, Box) async throws -> Void
    ) async rethrows {
        let box = Box()
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 520, height: 380),
            styleMask: [.titled, .resizable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer {
            if let sheet = window.attachedSheet { window.endSheet(sheet) }
            window.orderOut(nil)
            window.close()
        }
        @Bindable var bindable = box
        window.contentView = NSHostingView(rootView: Host(
            pending: $bindable.pending,
            onConfirm: { NoteDeletion.fire(session: session, postIDs: $0.postIDs) }))
        window.orderFrontRegardless()
        pump(0.3)
        for _ in 0..<20 { await Task.yield() }
        try await body(window, box)
    }

    private func isLive(_ session: AppSession, _ postID: String) async throws -> Bool {
        try await session.database.read { db in
            try Queries.containerHeader(db, containerID: postID) != nil
        }
    }

    /// **A single note goes at once, and the delete speaks an OFFER with
    /// Undo** — no confirm presents, the note is in the Trash, and the toast
    /// (an offer: it shows under every receipt style) carries "Undo". A note
    /// with no saved versions keeps the receipt's words. ⌥⌘Z gains nothing
    /// (her ruling: it does not undo a note delete).
    /// **Red on old:** the confirm presents (a sheet), the note stays live,
    /// and nothing toasts.
    @Test func aSingleNotesDeleteAsksNothingAndSpeaksAnOfferWithUndo() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let session = editor.session
            session.status.dismissAfter = .seconds(60)
            let undoTop = session.undoStack.topLabel
            try await withDoor(session) { window, box in
                // The door's own line.
                box.pending = await NoteDeletion.ask(session: session, postIDs: [editor.postID])
                await settle { session.status.current != nil || window.attachedSheet != nil }
                await settle(seconds: 0.3) { false }

                #expect(window.attachedSheet == nil, "one note: no confirm presents")
                #expect(box.pending == nil, "the ask was taken, not left standing")
                let live = try await isLive(session, editor.postID)
                #expect(!live, "the note went to the Trash at once")
                let toast = try #require(session.status.current,
                                         "the delete speaks in the toast, under her default quiet style")
                #expect(toast.kind == .offer, "an offer — it carries a door, so it always toasts")
                #expect(toast.action?.label == "Undo")
                #expect(toast.text == RecoveryCopy.movedToTrashReceipt(.note),
                        "a note with no saved versions keeps the receipt's words: \(toast.text)")
                #expect(session.undoStack.topLabel == undoTop, "⌥⌘Z gains no entry for a note delete")
            }
        }
    }

    /// **The toast's Undo puts back EXACTLY the note just deleted — its saved
    /// versions with it** (the Put back road, `restoreContainer`), and the
    /// saved-versions line rides the toast. A note deleted on its own
    /// earlier stays in the Trash.
    /// **Red on old:** the landed delete is a doorless receipt, so under her
    /// default quiet style the toast slot is empty (the first `#require`).
    @Test func theToastsUndoPutsBackExactlyTheNoteWithItsSavedVersions() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let session = editor.session
            session.status.dismissAfter = .seconds(60)
            let (versionID, other) = try await session.runner.run {
                [postID = editor.postID] (ops: Operations) -> (String, String) in
                let version = try ops.saveNoteVersion(postID)
                let other = try ops.createPost(title: "deleted on its own")
                try ops.deleteContainer(other.id)
                return (version.post.id, other.id)
            }
            let undoTop = session.undoStack.topLabel

            // The single road: the hosts' `onConfirm` body.
            NoteDeletion.fire(session: session, postIDs: [editor.postID])
            await settle { session.status.current != nil || session.status.quietLine != nil }

            let toast = try #require(session.status.current,
                                     "a single delete toasts — an offer, whatever her receipt style")
            #expect(toast.kind == .offer)
            #expect(toast.text.contains("saved version"),
                    "the saved-versions line moved into the toast: \(toast.text)")
            let undo = try #require(toast.action, "the toast carries its Undo")
            #expect(undo.label == "Undo")
            let deleted = !(try await isLive(session, editor.postID))
            #expect(deleted, "premise: the note is in the Trash")
            let versionsBefore = try await session.database.read { db in
                try Queries.noteVersionIDs(db, of: editor.postID)
            }
            #expect(versionsBefore.isEmpty, "premise: its saved version went with it")

            undo.perform()
            await settleReading { (try? await isLive(session, editor.postID)) == true }
            let back = try await isLive(session, editor.postID)
            #expect(back, "Undo put the note back")
            let versionsAfter = try await session.database.read { db in
                try Queries.noteVersionIDs(db, of: editor.postID)
            }
            #expect(versionsAfter == [versionID], "its saved version came back with it")
            let otherBack = try await isLive(session, other)
            #expect(!otherBack, "a note deleted on its own stays in the Trash")
            #expect(session.undoStack.topLabel == undoTop, "neither the delete nor the Undo touched ⌥⌘Z")
        }
    }

    /// **GUARD (green on both trees): several notes still ask first** — her
    /// ruling's "a multi-select delete of many notes can keep a confirm". The
    /// two-note ask presents the confirm and deletes nothing until it is
    /// answered; Cancel deletes nothing at all.
    @Test func severalNotesStillAskFirst() async throws {
        try await withEditor(seedBlocks: ["Alpha one."]) { editor in
            let session = editor.session
            let other = try session.operations.createPost(title: "the second pick").id
            try await withDoor(session) { window, box in
                box.pending = await NoteDeletion.ask(session: session, postIDs: [editor.postID, other])
                await settle { window.attachedSheet != nil }
                let sheet = try #require(window.attachedSheet, "two notes: the confirm presents")
                let firstLive = try await isLive(session, editor.postID)
                let secondLive = try await isLive(session, other)
                #expect(firstLive && secondLive, "nothing goes before the answer")
                let cancel = try #require(Self.buttons(in: sheet.contentView).first { $0.title == "Cancel" })
                cancel.performClick(nil)
                await settle(seconds: 0.5) { false }
                let firstAfter = try await isLive(session, editor.postID)
                let secondAfter = try await isLive(session, other)
                #expect(firstAfter && secondAfter, "Cancel deletes nothing")
            }
        }
    }
}
