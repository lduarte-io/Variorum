//
//  StatusToastPlacementTests.swift
//  VariorumTests
//
//  VX-121 (the VX-283 run, U3 — PROVISIONAL P-U3-1, the orchestrator's
//  ruling): **toasts over the Bookcase anchor ABOVE the quick-entry band, at
//  the same horizontal centre, by a placement RULE the toast host reads.**
//
//  THE MECHANISM (traced on the run's tip): the shell's ONE status host was
//  `RootView`'s `paneRow.overlay(alignment: .bottom) { StatusToast(…)
//  .padding(.bottom, 46) }` — a fixed 46 pt above the pane row's foot,
//  whatever the pane draws there. The Bookcase's foot (13s-b's R-13s-3) is
//  the ⌘K hint bar (~26 pt) with the quick-entry band directly above it
//  (~64 pt: the dashed box and its air), so the band spans roughly 26–90 pt
//  above the foot and a toast resting at 46 pt sits ON the box (13n-a W7's
//  capture, `w7-refusal-names-file-and-line-study.png`). The Library's bar
//  sits at ITS foot (0–64 pt) and is covered the same way. The class is any
//  toast over a quick-entry band — the ticket's statement.
//
//  THE PINS: the rule itself, pure (`StatusToastPlacement.bottomInset`); and
//  the shell MOUNTED (`RootView`, a 1240-pt-wide window — the app's default
//  width) with a refusal up, the toast's card read against every kept-clear
//  band in one space (`StatusToastOracle`, `.global`): on the Bookcase and
//  on the Library the card sits just ABOVE the band at the band's own
//  centre; on a note (no band) it rests where it always has.
//
//  RED ON OLD, by behavioural revert **R-T** (`RootView`'s host restored to
//  the fixed `.overlay(alignment: .bottom) { … .padding(.bottom, 46) }`):
//  the Bookcase and Library cells (the card overlaps the band); the note
//  cell and the pure cells are GUARDS, green on both sides.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The rule, pure

@Suite("VX-121 — the toast's placement rule")
struct StatusToastPlacementRuleTests {
    @Test func withNoBandTheToastRestsAtTheShellsInset() {
        #expect(StatusToastPlacement.bottomInset(hostHeight: 800, keepClearTops: [])
                == StatusToastPlacement.shellRestingInset)
        #expect(StatusToastPlacement.shellRestingInset == 46, "the shell's 46 pt, unchanged")
    }

    @Test func aBandReachingAboveTheRestingInsetLiftsTheToastJustAboveIt() {
        // A band whose top is 90 pt above an 800-pt host's foot (y 710).
        let inset = StatusToastPlacement.bottomInset(hostHeight: 800, keepClearTops: [710])
        #expect(inset == 90 + StatusToastPlacement.clearance)
    }

    @Test func aBandBelowTheRestingInsetLeavesTheToastWhereItRests() {
        let inset = StatusToastPlacement.bottomInset(hostHeight: 800, keepClearTops: [780])
        #expect(inset == StatusToastPlacement.shellRestingInset, "never lower than resting")
    }

    @Test func severalBandsLiftTheToastAboveTheHighest() {
        let inset = StatusToastPlacement.bottomInset(hostHeight: 800, keepClearTops: [736, 700, 790])
        #expect(inset == 100 + StatusToastPlacement.clearance)
    }

    @Test func aHostsOwnRestingInsetIsKept() {
        #expect(StatusToastPlacement.bottomInset(hostHeight: 600, keepClearTops: [], resting: 24) == 24)
        #expect(StatusToastPlacement.bottomInset(hostHeight: 600, keepClearTops: [590], resting: 24) == 24)
    }
}

// MARK: - The shell, mounted

@MainActor
@Suite("VX-121 — a toast over the Bookcase or the Library sits above its quick-entry band", .serialized)
struct StatusToastPlacementShellTests {
    private func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.01))
    }

    private func settle(turns: Int = 300, until predicate: () -> Bool) async {
        for _ in 0..<turns where !predicate() {
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    /// A few extra frames so a geometry change has reached the oracle.
    private func frames(_ count: Int = 20) async {
        for _ in 0..<count {
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    private struct Read {
        let toast: CGRect
        let bands: [CGRect]
        /// The mounted shell's own frame, in the SAME `.global` space as the
        /// card and the bands — the pane row (the toast's host) runs to its
        /// foot (`ShellSplit`'s detail fills the height). The first window
        /// measured the HOSTING VIEW's height instead (832 pt) while the shell's
        /// foot read ≈52 pt lower in `.global` — a harness fact, recorded.
        let shell: CGRect
        let hostHeight: CGFloat
    }

    /// The shell's frame, reported by the test's own wrapper (the
    /// `BookcaseQuickEntryPlacementTests.RootFrame` precedent — no product
    /// probe).
    @MainActor
    private final class ShellFrame {
        var frame: CGRect?
    }

    /// The shell in a 1240 × 800 window, on `selection` (nil = the Bookcase,
    /// where a shell opens), with a refusal up; hands the body the card and
    /// the bands, all in the window's `.global` space.
    private func withAToastUp(
        on selection: (AppSession) throws -> SidebarSelection?,
        expectBand: Bool,
        _ body: (Read) throws -> Void
    ) async throws {
        #if DEBUG
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            session.status.dismissAfter = .seconds(60)
            let target = try selection(session)
            StatusToastOracle.forget()
            let router = ShellRouter()
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1240, height: 800),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let shellFrame = ShellFrame()
            let hosting = NSHostingView(rootView: RootView(session: session, services: nil, router: router)
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                    shellFrame.frame = $0
                })
            window.contentView = hosting
            window.orderFrontRegardless()
            defer {
                session.status.clear()
                window.orderOut(nil)
                window.contentView = nil
                window.close()
            }
            await settle { router.workspace.history().current != nil }
            if let target {
                router.pendingSelection = target
                await settle { router.workspace.focusedSelection == target && router.pendingSelection == nil }
            }
            if expectBand {
                await settle { !StatusToastOracle.bands.isEmpty }
            }
            await frames()

            session.status.refuse(
                "Nothing was imported — “field notes.md” line 12 starts a take with no block above it.")
            await settle { StatusToastOracle.frame != nil }
            await frames()
            let toast = try #require(StatusToastOracle.frame, "the toast drew")
            let bands = StatusToastOracle.bands
            let shell = try #require(shellFrame.frame, "the shell reported its frame")
            print("[VX-121 toast placement] \(String(describing: target)) · toast \(toast) · bands \(bands) · shell \(shell) · host \(hosting.bounds.size)")
            try body(Read(toast: toast, bands: bands, shell: shell, hostHeight: hosting.bounds.height))
        }
        #endif
    }

    private func expectAboveEveryBand(_ read: Read, _ surface: String) {
        #expect(read.bands.count == 1, "\(surface): one quick-entry band on screen (\(read.bands))")
        for band in read.bands {
            #expect(read.toast.maxY <= band.minY - StatusToastPlacement.clearance + 0.5, """
                \(surface): the toast's card sits ABOVE the quick-entry band, never on it \
                (card foot \(read.toast.maxY), band top \(band.minY))
                """)
            #expect(read.toast.maxY >= band.minY - StatusToastPlacement.clearance - 2, """
                \(surface): …and just above it, not floating up the page \
                (card foot \(read.toast.maxY), band top \(band.minY))
                """)
            #expect(abs(read.toast.midX - band.midX) < 1.5, """
                \(surface): at the same horizontal centre (card \(read.toast.midX), band \(band.midX))
                """)
        }
    }

    /// **RED ON OLD (R-T).** The Bookcase — the ticket's surface.
    @Test func aToastOverTheBookcaseSitsAboveTheQuickEntryBand() async throws {
        try await withAToastUp(on: { _ in nil }, expectBand: true) { read in
            expectAboveEveryBand(read, "the Bookcase")
        }
    }

    /// **RED ON OLD (R-T).** The Library carries the same bar at its foot
    /// (PROVISIONAL P-U3-3 — the band marks itself, so both surfaces).
    @Test func aToastOverTheLibrarySitsAboveItsQuickEntryBand() async throws {
        try await withAToastUp(on: { _ in .library }, expectBand: true) { read in
            expectAboveEveryBand(read, "the Library")
        }
    }

    /// GUARD (green on both sides): a surface with no band below keeps the
    /// shell's resting 46 pt.
    @Test func aToastOverANoteRestsWhereItAlwaysHas() async throws {
        try await withAToastUp(
            on: { session in .post(try session.operations.createPost(title: "a note").id) },
            expectBand: false
        ) { read in
            #expect(read.bands.isEmpty, "a note's surface draws no quick-entry band (\(read.bands))")
            #expect(abs((read.shell.maxY - read.toast.maxY) - StatusToastPlacement.shellRestingInset) < 1.5, """
                the toast rests 46 pt above the shell's foot, in one space \
                (card foot \(read.toast.maxY), shell foot \(read.shell.maxY); the host reads \(read.hostHeight) tall)
                """)
        }
    }
}
