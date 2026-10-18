//
//  VX384LibraryFollowsMintsTests.swift
//  VariorumTests
//
//  **VX-384 (the VX-348 run, U4) — a note minted from the Library List's own
//  row menu shows without re-entry.** Found by VX-383's walk (W1): right-click
//  a note row → Duplicate with Tags → the receipt speaks and the Bookcase's
//  counts move, but the List keeps its rows until she leaves the Library and
//  comes back.
//
//  THE MECHANISM (traced): the List draws `LibraryCatalogModel.noteHits` — a
//  ONE-SHOT `search()` answer, re-asked by its own doors, a wing, a mode and
//  the `.variorumNotesDeleted` signal; `LibraryViewModel.start()`'s held
//  `observeLibrary` fed `posts` only, which no face reads. The row menu's
//  duplicate (`library.duplicateAsVersion`) re-asked neither. THE FIX rides
//  VX-231's road (the VX-246 record — "the held observation that moves exactly
//  when membership does, followed by its one-shot twin"; no new signal): the
//  held listing counts its MEMBERSHIP moves and the catalog re-asks in place.
//
//  RED ON OLD: `aRowMenuDuplicateListsTheCopyWithoutReEntry` reads only what
//  the pre-fix tree has (the mounted catalog, a started `LibraryViewModel` as
//  `RootView` starts it, the row menu's act, `noteHits`). The typing guard is
//  green on both trees by nature (P1: the follow never wakes at keystroke
//  rate). The membership rule's pins are new API (fixed-only) and live in
//  `VX384ListingFollowRuleTests.swift`, removed from the red product.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-384 — the Library's List follows a mint from any door", .serialized)
struct VX384LibraryFollowsMintsTests {
    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(11) }
                return value
            }
        }
    }

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, timeout: TimeInterval = 4,
        until predicate: () -> Bool = { false }
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if predicate() { return }
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            Self.pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    /// The real catalog in a window, with the Library's held listing started
    /// exactly as `RootView` starts it (`.task(id: wing) { await library.start() }`).
    private func withMountedLibrary(
        _ body: @MainActor (AppSession, LibraryCatalogModel, LibraryViewModel, NSWindow, NSView) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        let suite = "vx384-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 384))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            for index in 0..<3 {
                let note = try session.operations.createPost(title: "note \(index)")
                _ = try session.operations.newBlock(in: note.id, text: "words of \(index)")
            }
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            let library = LibraryViewModel(session: session)
            let held = Task { await library.start() }
            defer { held.cancel() }
            await model.search()
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1000, height: 640),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: AnyView(
                LibraryCatalogView(
                    session: session, model: model, library: library,
                    tags: TagsViewModel(session: session), onOpen: { _ in })))
            hosting.frame = NSRect(x: 0, y: 0, width: 1000, height: 640)
            window.contentView = hosting
            window.orderFrontRegardless()
            defer {
                window.orderOut(nil)
                window.contentView = nil
                window.close()
            }
            await settle(window, hosting, timeout: 1.5, until: { !library.posts.isEmpty && model.noteHits.count == 3 })
            try #require(model.noteHits.count == 3, "the premise: the List shows the three notes")
            try #require(library.posts.count == 3, "the premise: the held listing delivered")
            try await body(session, model, library, window, hosting)
        }
    }

    /// **Her report, as a pin.** The row menu's Duplicate (with tags and
    /// without): the copy is listed while the Library stays mounted — no
    /// leaving, no re-entry. Pre-fix: the List kept its three rows.
    @Test(arguments: [Operations.DuplicateTags.applied, .none])
    func aRowMenuDuplicateListsTheCopyWithoutReEntry(tags: Operations.DuplicateTags) async throws {
        try await withMountedLibrary { session, model, library, window, hosting in
            let source = try #require(model.noteHits.first)
            // The copy is named by the STORE, before and after the act — never
            // by the listing (the fix lists it so fast that a listing read
            // after the act already holds it; the U4 batch's catch).
            func storeNotes() async throws -> Set<String> {
                Set(try await session.database.read { db in
                    try Queries.library(db, limit: nil).map(\.postID)
                })
            }
            let before = try await storeNotes()
            await library.duplicateAsVersion(postID: source.id, tags: tags)
            let minted = try await storeNotes().subtracting(before)
            try #require(minted.count == 1, "the premise: the act minted exactly one copy (\(minted.count))")
            let copy = try #require(minted.first)
            await settle(window, hosting, timeout: 4, until: { model.noteHits.contains { $0.id == copy } })
            #expect(model.noteHits.contains { $0.id == copy },
                    "the List lists the copy without re-entry (listed \(model.noteHits.count) of 4)")
            #expect(model.noteHits.count == 4)
        }
    }

    /// **The P1 guard** (green on both trees by nature): typing in a listed
    /// note moves the held listing's ORDER, never its membership — the List
    /// is never re-asked at keystroke rate.
    @Test func typingInAListedNoteNeverReAsksTheList() async throws {
        try await withMountedLibrary { session, model, library, window, hosting in
            let noteID = try #require(model.noteHits.last?.id)
            let variant = try #require(try await session.database.read { db in
                try Queries.renderPost(db, containerID: noteID).first?.variantID
            })
            let before = model.searchGeneration
            for index in 1...6 {
                try session.operations.autosave(
                    variant, text: "words, typed \(index)", charDelta: 1)
                await settle(window, hosting, timeout: 0.25)
            }
            await settle(window, hosting, timeout: 0.6)
            #expect(library.posts.first?.postID == noteID, "the premise: the held listing re-ordered")
            #expect(model.searchGeneration == before,
                    "typing re-asked the List \(model.searchGeneration - before) times")
        }
    }

}
