//
//  NoteBoxSlotTests.swift
//  VariorumTests
//
//  VX-141 (the VX-143 run) — her report: *"when you are in a book and click
//  on a note, there's no verticle shift … but there is a jump when you go
//  from a note to a book (the this note section briefly starts to minimize
//  and then snaps back, but it's distracting that there's movement in one
//  direction)."*
//
//  THE MECHANISM (traced in the run record): the sidebar's slot holds the
//  note's RAIL (derived from the selection, synchronously) or the book's note
//  BOX (which exists only once the book has PUBLISHED its report — from
//  `BookView.onAppear`, a later pass). Book → note: the rail arrives in the
//  very pass the box leaves — same height, a crossfade, calm. Note → book: a
//  pass holds NEITHER, so the rail's group fades out and the Open strip starts
//  sliding up; the box arrives a beat later and everything slides back.
//
//  The oracle is the slot's occupant on every sidebar body pass
//  (`SidebarGeometry.slotOccupants`, DEBUG), through the REAL shell: a note,
//  then the book. RED ON OLD: the sequence after the switch reads
//  rail → empty → … → box.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The sidebar's rail slot never empties between a note and a book (VX-141)", .serialized)
struct NoteBoxSlotTests {
    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, until predicate: () -> Bool, maxTurns: Int = 80
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return }
        }
    }

    /// A working (unfinished) book in Outline — the mode that shows the box —
    /// with a few notes, and one more note OUTSIDE it to stand on first.
    private func withBookAndNote(
        _ body: @MainActor (AppSession, _ readingID: String, _ noteID: String) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            // LIVE uuids: the oracle keys are these ids (NoteBoxMountTests' MINOR-3).
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 141))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let reading = try session.operations.createReading(name: "the slot's book", kind: .book)
            for p in 0..<3 {
                let post = try session.operations.createPost(title: "book note \(p)")
                _ = try session.operations.newBlock(
                    in: post.id, text: "Prose of book note \(p), enough to lay out.")
                try session.operations.addPostToReading(post.id, to: reading.id)
            }
            let note = try session.operations.createPost(title: "the note she stands on")
            _ = try session.operations.newBlock(in: note.id, text: "so the rail has a note.")
            try await body(session, reading.id, note.id)
        }
    }

    /// Two FINISHED books (the reading row seeds Read — the mode that says
    /// "no box"), each with a note so they are real.
    private func withTwoFinishedBooks(
        _ body: @MainActor (AppSession, _ readingA: String, _ readingB: String) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1412))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            @MainActor func finishedBook(_ name: String) throws -> String {
                let reading = try session.operations.createReading(name: name, kind: .book)
                let post = try session.operations.createPost(title: "\(name)'s note")
                _ = try session.operations.newBlock(in: post.id, text: "Prose for \(name).")
                try session.operations.addPostToReading(post.id, to: reading.id)
                try session.operations.lockReading(reading.id)
                return reading.id
            }
            let a = try finishedBook("read book a")
            let b = try finishedBook("read book b")
            try await body(session, a, b)
        }
    }

    /// **Ladder round 1 (MAJOR-1): focus returning to a Read-mode book in a
    /// split must not stand a PHANTOM empty box.** A Read book's note-box
    /// report is nil on BOTH sides of a pane-focus flip, so
    /// `.onChange(of: noteBoxReport)` never fires for it — the book never
    /// re-speaks its "no box" word, the one-id `noteBoxDeclinedBy` still
    /// names the OTHER book, and VX-141's held slot renders the empty box
    /// face forever. RED ON OLD: after focus returns to book A, the slot
    /// settles on `.box` and stays there.
    @Test func focusReturningToAReadBookNeverStandsAPhantomEmptyBox() async throws {
        try await withTwoFinishedBooks { session, readingA, readingB in
            let router = ShellRouter()
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 900),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
#if DEBUG
            SidebarGeometry.forgetBox(subject: readingA)
            SidebarGeometry.forgetBox(subject: readingB)
            let key = SidebarGeometry.bodyKey(for: router.workspace)
            SidebarGeometry.slotOccupants[key] = nil
#endif
            let hosting = NSHostingView(
                rootView: RootView(session: session, services: nil, router: router))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
#if DEBUG
            @MainActor func occupants() -> [SidebarGeometry.SlotOccupant] {
                SidebarGeometry.slotOccupants[key] ?? []
            }
            // Book A in the primary pane. A finished book flashes its
            // Outline report, then the reading row seeds Read and it speaks
            // its "no box" word — the slot must END empty (neither rail nor
            // box). The flash is the fixture's proof the book spoke at all.
            router.workspace.visit(.reading(readingA))
            _ = router.workspace.select(.reading(readingA))
            await settle(window, hosting, until: {
                occupants().contains(.box) && occupants().last == .empty
            })
            try #require(occupants().contains(.box) && occupants().last == .empty,
                         "fixture: book A spoke (the flash) and settled boxless in Read (occupants: \(occupants().map(\.rawValue)))")

            // Book B beside it — the split opens focused on B, which settles
            // boxless the same way (its own flash, its own word).
            let markB = occupants().count
            _ = router.workspace.openBeside(.reading(readingB))
            await settle(window, hosting, until: {
                occupants().dropFirst(markB).contains(.box) && occupants().last == .empty
            })
            try #require(occupants().last == .empty,
                         "fixture: book B settled boxless in Read (tail: \(occupants().dropFirst(markB).map(\.rawValue)))")

            // Focus returns to A's pane. A is mounted (no .onAppear coming)
            // and in Read (its report is nil → nil across the flip), so only
            // a focus-change publish can land its "no box" word — without
            // it, the held slot stands an empty box forever.
            let markA = occupants().count
            router.workspace.focus(.primary)
            await settle(window, hosting, until: {
                occupants().count > markA && occupants().last == .empty
            })
            let tail = Array(occupants().dropFirst(markA))
            print("[VX-141 r1] occupants after focus returned to A: \(tail.map(\.rawValue))")
            // (A frames-oracle arm was tried and measured GREEN on the
            // pre-fix tree — the phantom's probe does not re-record under
            // the held face reliably — so the occupants arm, red-on-old
            // verified, is the pin. A hollow arm earns no place.)
            #expect(occupants().last == .empty,
                    "focus returning to a Read book stands NO box — the phantom (tail: \(tail.map(\.rawValue)))")
#endif
        }
    }

    @Test func goingFromANoteToABookNeverEmptiesTheSlot() async throws {
        try await withBookAndNote { session, readingID, noteID in
            let router = ShellRouter()
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 900),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
#if DEBUG
            SidebarGeometry.forgetRail(noteID)
            SidebarGeometry.forgetBox(subject: readingID)
            let key = SidebarGeometry.bodyKey(for: router.workspace)
            SidebarGeometry.slotOccupants[key] = nil
#endif
            let hosting = NSHostingView(
                rootView: RootView(session: session, services: nil, router: router))
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            // The note first: the rail stands in the slot.
            router.workspace.visit(.post(noteID))
            _ = router.workspace.select(.post(noteID))
#if DEBUG
            await settle(window, hosting, until: {
                SidebarGeometry.railGroupHeights[noteID] != nil
            })
            #expect(SidebarGeometry.slotOccupants[key]?.last == .rail,
                    "the note's rail holds the slot before the switch")
            let mark = SidebarGeometry.slotOccupants[key]?.count ?? 0

            // …then the book, as a click in the sidebar delivers it.
            router.pendingSelection = .reading(readingID)
            await settle(window, hosting, until: {
                SidebarGeometry.noteBoxFrames[readingID] != nil
            })
            #expect(SidebarGeometry.noteBoxFrames[readingID] != nil,
                    "the book's box arrived in the slot")
            let history = SidebarGeometry.slotOccupants[key] ?? []
            let after = Array(history.dropFirst(mark))
            // From the switch on: the rail may stand for passes that still
            // render the note; the first thing to REPLACE it must be the box.
            let replacement = after.first { $0 != .rail }
            print("[VX-141] slot occupants after the switch: \(after.map(\.rawValue))")
            #expect(replacement == .box,
                    "note → book: the slot went \(replacement?.rawValue ?? "nowhere") before the box arrived — the collapse she sees begin (\(after.map(\.rawValue)))")
            #expect(!after.contains(.empty),
                    "no pass after the switch holds an empty slot (\(after.map(\.rawValue)))")
#endif
        }
    }
}
