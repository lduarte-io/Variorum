//
//  MobilePushLandingDirectionTests.swift
//  VariorumMobileTests
//
//  A-260-1 (the VM-260 run's adjudication of batch 1a's P-260-1a; built in
//  batch 1b) — **A NOTE MADE BUT NOT OPENED SAYS WHERE IT LANDED.** Batch 1a's
//  push door (`MobileShellView.push(_:in:)`) lands nothing on a page she has
//  since left (VM-256, R-260-5): a note asked for on the Library, minted after
//  she moved to the Bookcase, is kept — it lists where it lives — and NOT opened.
//  The built arm stands; SILENT does not: an outcome other than the one she
//  asked for is a DIRECTION, and the seam's law gives a direction its line
//  (SurfaceContracts, the phone line: "a direction … keeps its line"). One
//  door-side call through the existing seam — never a refusal, no Undo
//  (nothing left the page); the words PROVISIONAL for her pass.
//
//  THE PINS:
//  · `aNoteMadeAfterSheLeftThePageSaysWhereItLanded` — RED ON OLD: the
//    Library's New Note, then Bookcase, in one turn (batch 1a's deterministic
//    window): the mint lands, nothing opens, and the line names the Library —
//    a direction, in the muted ink (old: nothing said).
//  · `aNoteMadeWhereSheStandsOpensAndSaysNothing` — a GUARD (green on both):
//    the ordinary road — New Note, staying put — opens the note and draws no
//    line.
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
@Suite("A-260-1 — a note made but not opened says where it landed", .serialized)
struct MobilePushLandingDirectionTests {

    private func onWindow<V: View>(_ surface: HostedSurface<V>, _ label: String) -> NSObject? {
        let window = surface.window.bounds.insetBy(dx: 1, dy: 1)
        return surface.visibleElements.first {
            $0.accessibilityLabel == label && window.intersects($0.accessibilityFrame)
        }
    }

    private func posts(_ db: AppDatabase) async throws -> [String] {
        try await db.read { db in
            try String.fetchAll(db, sql: "SELECT id FROM container WHERE kind = 'post' AND deleted_at IS NULL")
        }
    }

    /// **RED ON OLD.** New Note on the Library and Bookcase in ONE turn (the
    /// door only spawns its mint, so the page changes before it lands): the
    /// note is made and kept, nothing opens, and the line says where it is.
    @Test func aNoteMadeAfterSheLeftThePageSaysWhereItLanded() async throws {
        try await withEditorWorld { session, db in
            session.status.dismissAfter = .seconds(60)
            let router = MobileShellRouter()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(30)
                #expect(onWindow(surface, "Library")?.accessibilityActivate() == true,
                        "labels: \(surface.visibleLabels)")
                await surface.settle(40)
                let before = try await posts(db)
                session.status.clear()

                let newNote = try #require(onWindow(surface, "New Note"),
                                           "the Library's New Note door: \(surface.visibleLabels)")
                #expect(newNote.accessibilityActivate())
                #expect(onWindow(surface, "Bookcase")?.accessibilityActivate() == true)

                var after = try await posts(db)
                var spins = 0
                while after.count == before.count, spins < 200 {
                    spins += 1
                    await surface.settle(1)
                    after = try await posts(db)
                }
                #expect(Set(after).subtracting(before).count == 1, "the door minted its note")
                for _ in 0..<200 where session.status.current == nil {
                    await surface.settle(1)
                }
                await surface.settle(20)
                #expect(router.editors.registeredPostIDs.isEmpty, "nothing opened it")

                let line = try #require(session.status.current,
                                        "the made-but-not-opened note says where it landed")
                #expect(line.kind == .refusal, "a direction rides the always-drawn class")
                #expect(line.action == nil, "no Undo — nothing left the page")
                #expect(line.text.contains("Library"), "it names where the note is: \(line.text)")
                expectMutedInk(line)
            }
        }
    }

    /// **A GUARD — the ordinary road says nothing.** New Note on the Library,
    /// staying put: the note opens there and no line draws.
    @Test func aNoteMadeWhereSheStandsOpensAndSaysNothing() async throws {
        try await withEditorWorld { session, _ in
            session.status.dismissAfter = .seconds(60)
            let router = MobileShellRouter()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(30)
                #expect(onWindow(surface, "Library")?.accessibilityActivate() == true)
                await surface.settle(40)
                session.status.clear()
                #expect(onWindow(surface, "New Note")?.accessibilityActivate() == true,
                        "labels: \(surface.visibleLabels)")
                for _ in 0..<300 where router.editors.registeredPostIDs.isEmpty {
                    await surface.settle(1)
                }
                await surface.settle(20)
                #expect(router.editors.registeredPostIDs.count == 1, "the note opened where she stands")
                #expect(session.status.current == nil, "an ordinary open says nothing")
            }
        }
    }
}
