//
//  MobilePageLeavingTests.swift
//  VariorumMobileTests
//
//  VM-256 (the VM-260 run, batch 1a; her ruling R-260-5) — **A PAGE SHE LEAVES
//  RETURNS TO ITS ROOT, A NOTE INCLUDED; ARRIVING ANYWHERE SHOWS THE PAGE
//  ITSELF.** Her words (2026-11-22): "clicking on library should bring me to
//  library, not whatever note i last had open." Her ruling (2026-11-25): "Note
//  closes on leaving" — the note's quiet savepoint is the existing leaving
//  occasion (`closeAutoCommit` when the note stops being shown), no new
//  operation; P-71-1 retires with its premise.
//
//  THE TRACE (the pre-fix tree, `MobileShellView`): the BAR road already held
//  the law — the bar shows only on roots and lists, a tab from a list returns
//  the stack it leaves to its root (P-47-19, VM-52, in her wave-1 build), and a
//  swipe starts only on a root. Two roads did not:
//  · **A note asked for, landing after she left the page.** The New Note door
//    (the Library's and the Bookcase's), Today, a created book's open, a
//    diverged copy's landing — each mints first and pushes when the mint
//    returns, onto the stack it was asked from, whatever page shows by then. A
//    runner that lags (VM-64's two lags) is the window: she taps New Note,
//    nothing happens, she taps Bookcase — and the note is pushed onto the
//    HIDDEN Library stack, where it mounts, registers and takes the pen while
//    hidden (the liveness authority's forbidden state), and is what "Library"
//    shows when she comes back.
//  · **A page change that is not the bar's** — the Protection ask's adoption
//    (`adoptProtectionRequest` → `selectPage(.shelf)`) changed the page
//    without returning the page left to its root.
//  The fix makes both halves structural: the ONE page road (`selectPage`)
//  returns the page being left to its root on every road, and the ONE push door
//  (`push(_:in:)`) never lands a screen on a page that is not showing.
//
//  THE PINS:
//  · `aNoteAskedForOnAPageSheLeftNeverStandsThere` — RED ON OLD: the
//    Library's New Note and then Bookcase in ONE turn (the door's action only
//    spawns its mint, so the page changes first — the lag's window made
//    deterministic): no editor mounts on the hidden page, and Library shows
//    the Library itself (old: a registered, live editor on the hidden stack,
//    and the note where the Library should be). The minted note is kept.
//  · `leavingAPageClosesItsNoteAndSavepointsItOnce` — the ruling's own
//    sentence on the bar road (a GUARD: green on old, which already popped —
//    recorded as such): a note opened from the Library with words no savepoint
//    holds, Versions over it, Bookcase by the bar — the note closes, its leaving
//    savepoint is written exactly once, and Library shows the Library itself.
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-256 — a page she leaves returns to its root; a note closes on leaving", .serialized)
struct MobilePageLeavingTests {

    /// The on-window copy of a door (the band's two other roots are in every
    /// walk, a screen away).
    private func onWindow<V: View>(_ surface: HostedSurface<V>, _ label: String) -> NSObject? {
        let window = surface.window.bounds.insetBy(dx: 1, dy: 1)
        return surface.visibleElements.first {
            $0.accessibilityLabel == label && window.intersects($0.accessibilityFrame)
        }
    }

    /// The Library ROOT is what shows: its "All" filter door is on the window.
    private func libraryRootShows<V: View>(_ surface: HostedSurface<V>) -> Bool {
        onWindow(surface, MobileListingFilter.all.word) != nil
    }

    private func posts(_ db: AppDatabase) async throws -> [String] {
        try await db.read { db in
            try String.fetchAll(db, sql: "SELECT id FROM container WHERE kind = 'post' AND deleted_at IS NULL")
        }
    }

    /// **RED ON OLD — a note asked for on a page she has left never stands
    /// there.** On the Library: New Note, then Bookcase, in one turn (no await
    /// between them — the door's mint cannot have landed). The mint lands; no
    /// editor mounts on the hidden Library stack and none holds the pen; the
    /// note exists (nothing is lost — it lists in the Library); and Library by
    /// the bar shows the Library itself.
    @Test func aNoteAskedForOnAPageSheLeftNeverStandsThere() async throws {
        try await withEditorWorld { session, db in
            let router = MobileShellRouter()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(30)
                #expect(onWindow(surface, "Library")?.accessibilityActivate() == true,
                        "labels: \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(libraryRootShows(surface), "on the Library: \(surface.visibleLabels)")
                let before = try await posts(db)

                // ONE turn: the door spawns its mint; the page changes before it lands.
                let newNote = try #require(onWindow(surface, "New Note"),
                                           "the Library's New Note door: \(surface.visibleLabels)")
                #expect(newNote.accessibilityActivate())
                #expect(onWindow(surface, "Bookcase")?.accessibilityActivate() == true)

                // The mint lands (its note is kept).
                var after = try await posts(db)
                var spins = 0
                while after.count == before.count, spins < 200 {
                    spins += 1
                    await surface.settle(1)
                    after = try await posts(db)
                }
                let minted = Set(after).subtracting(before)
                #expect(minted.count == 1, "the door minted its note: \(minted)")
                await surface.settle(60)

                #expect(onWindow(surface, "Bookcase")?.accessibilityTraits.contains(.selected) == true,
                        "she is on the Bookcase")
                #expect(router.editors.registeredPostIDs.isEmpty,
                        "no editor stands on the hidden Library: \(router.editors.registeredPostIDs)")
                #expect(router.editors.live == nil, "and none holds the pen while hidden")

                // Arriving at the Library shows the Library itself.
                #expect(onWindow(surface, "Library")?.accessibilityActivate() == true)
                await surface.settle(60)
                #expect(onWindow(surface, "Library")?.accessibilityTraits.contains(.selected) == true)
                #expect(libraryRootShows(surface),
                        "Library shows the Library, not the note — labels \(surface.visibleLabels)")
                #expect(router.editors.registeredPostIDs.isEmpty, "no note is open there")
            }
        }
    }

    /// **The ruling's sentence on the bar road** (a GUARD — the bar road popped
    /// on the old tree too). A note with words no savepoint holds, opened from
    /// the Library; Versions over it (a list — the bar stands); Bookcase by the
    /// bar: the note closes (its editor leaves the liveness authority), its
    /// leaving savepoint is written EXACTLY ONCE, and Library by the bar then
    /// shows the Library itself — the count still one.
    @Test func leavingAPageClosesItsNoteAndSavepointsItOnce() async throws {
        try await withEditorWorld { session, db in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "Left open", profile: .blog)
                _ = try ops.newBlock(in: post.id, text: "words no savepoint holds yet", at: .end, registeringUndo: false)
                return post.id
            }
            func autoSavepoints() async throws -> Int {
                try await db.read { db in
                    try Int.fetchOne(db, sql: """
                        SELECT COUNT(*) FROM commit_point cp
                        JOIN variant v ON v.id = cp.variant_id
                        JOIN container_block cb ON cb.block_id = v.block_id AND cb.deleted_at IS NULL
                        WHERE cb.container_id = ? AND cp.kind = 'auto'
                        """, arguments: [postID]) ?? -1
                }
            }
            #expect(try await autoSavepoints() == 0, "fixture: nothing saved yet")

            let router = MobileShellRouter()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(30)
                #expect(onWindow(surface, "Library")?.accessibilityActivate() == true)
                await surface.settle(40)
                for _ in 0..<100 where onWindow(surface, "Left open") == nil {
                    await surface.settle(1)
                }
                #expect(onWindow(surface, "Left open")?.accessibilityActivate() == true,
                        "the note's row: \(surface.visibleLabels)")
                await surface.settle(60)
                #expect(router.editors.registeredPostIDs == [postID], "the note is open on the Library")

                // Versions over it: a list, the bar stands.
                #expect(surface.activate(MobileNoteActionsSheet.doorLabel), "labels: \(surface.visibleLabels)")
                await surface.settle(50)
                #expect(surface.activate(VersionsPath.menuLabel), "labels: \(surface.visibleLabels)")
                await surface.settle(60)
                #expect(surface.visibleLabels.contains(MobileVersionsModel.noVersions),
                        "the Versions listing: \(surface.visibleLabels)")

                // Leave the page by the bar.
                #expect(onWindow(surface, "Bookcase")?.accessibilityActivate() == true,
                        "the bar on the listing: \(surface.visibleLabels)")
                for _ in 0..<200 where !router.editors.registeredPostIDs.isEmpty {
                    await surface.settle(1)
                }
                #expect(router.editors.registeredPostIDs.isEmpty, "the note closed as she left its page")
                var spins = 0
                while try await autoSavepoints() == 0, spins < 200 {
                    spins += 1
                    await surface.settle(1)
                }
                await surface.settle(20)
                #expect(try await autoSavepoints() == 1, "its leaving savepoint, written once")

                // Back to the Library: the Library itself.
                #expect(onWindow(surface, "Library")?.accessibilityActivate() == true)
                await surface.settle(60)
                #expect(libraryRootShows(surface),
                        "Library shows the Library — labels \(surface.visibleLabels)")
                #expect(router.editors.registeredPostIDs.isEmpty, "no note is open there")
                #expect(try await autoSavepoints() == 1, "and no second savepoint")
            }
        }
    }
}
