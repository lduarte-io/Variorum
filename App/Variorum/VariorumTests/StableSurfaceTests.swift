//
//  StableSurfaceTests.swift
//  VariorumTests
//
//  The Act 10 correction round, ladder round 1 — R1-1: the row-53
//  reservation (`StableSurface`, the book Outline's remembered surface
//  size) had NO shrink path. The memory only grew for a read-cheap surface
//  and `loaded` flipped only when the surface REACHED the memory, so a
//  memory TALLER than the surface's real height — the text reflowed
//  shorter while the row was away (the pane widened, the sidebar
//  collapsed, the voice switched) — reserved a permanent blank gap under
//  the story, and the doc block claimed the opposite. The fix: a memory at
//  another WIDTH does not apply (the doc's own rule, now compared), and a
//  surface that holds one size for the settle interval adopts it — taller
//  OR shorter — and drops the reservation.
//
//  The pins mount `StableSurface` ALONE with a memory 2× its content's
//  height: the row must end at the content's height (RED ON OLD: the
//  `minHeight` reservation held for good), and the memory must be the
//  settled size; and a memory at another width must reserve nothing from
//  the first real report — well inside the settle interval.
//

import AppKit
import Foundation
import SwiftUI
import Testing
@testable import Variorum

@MainActor
@Suite("StableSurface's reservation is honest in both directions (ladder R1-1)", .serialized)
struct StableSurfaceTests {
    @MainActor
    final class Frames {
        var rowHeight: CGFloat?
        var remembered: [CGSize] = []
    }

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, timeout: TimeInterval,
        until predicate: () -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if predicate() { return true }
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            Self.pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
        return predicate()
    }

    private func mount(known: CGSize?, content: CGSize, frames: Frames) -> (NSWindow, NSHostingView<AnyView>) {
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 600, height: 900),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: AnyView(
            VStack(alignment: .leading, spacing: 0) {
                StableSurface(
                    known: known, followsShrinks: false,
                    remember: { frames.remembered.append($0) }
                ) {
                    Color.red.frame(width: content.width, height: content.height)
                }
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: {
                    frames.rowHeight = $0
                }
                Spacer(minLength: 0)
            }
            .frame(width: 600, height: 900, alignment: .top)))
        hosting.frame = NSRect(x: 0, y: 0, width: 600, height: 900)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    /// A memory twice as tall as the surface, at the SAME width: the row
    /// reserves the memory at first (row 53's promise), then — once the
    /// surface has held its real size for the settle interval — the row is
    /// exactly the content's height and the memory is the settled size.
    /// RED ON OLD: the reservation held at 400 for the whole run.
    @Test func aStaleTallerMemoryAtTheSameWidthIsDroppedOnceTheSurfaceSettles() async throws {
        let frames = Frames()
        let (window, hosting) = mount(
            known: CGSize(width: 400, height: 400), content: CGSize(width: 400, height: 200),
            frames: frames)
        defer {
            window.orderOut(nil)
            window.close()
        }
        #expect(await settle(window, hosting, timeout: 3) { frames.rowHeight != nil },
                "the row laid out")
        let settled = await settle(
            window, hosting, timeout: stableSurfaceSettleInterval + 3
        ) { frames.rowHeight.map { abs($0 - 200) < 1 } ?? false }
        let height = try #require(frames.rowHeight)
        #expect(settled, "the reservation is dropped once the surface settles below it: \(height)")
        #expect(abs(height - 200) < 1, "the row is the content's height, never the stale memory's")
        #expect(frames.remembered.last == CGSize(width: 400, height: 200),
                "the memory is the SETTLED size — smaller than before")
    }

    /// A memory taken at ANOTHER width does not apply: from the surface's
    /// first real report the row is the content's height — well inside the
    /// settle interval, because the width comparison decides at once.
    /// RED ON OLD: the width was carried, never compared — reserved for good.
    @Test func aMemoryAtAnotherWidthReservesNothing() async throws {
        let frames = Frames()
        let (window, hosting) = mount(
            known: CGSize(width: 300, height: 400), content: CGSize(width: 400, height: 200),
            frames: frames)
        defer {
            window.orderOut(nil)
            window.close()
        }
        let start = Date()
        let dropped = await settle(window, hosting, timeout: 3) {
            frames.rowHeight.map { abs($0 - 200) < 1 } ?? false
        }
        let elapsed = Date().timeIntervalSince(start)
        let height = try #require(frames.rowHeight)
        #expect(dropped, "a memory at another width reserves nothing: \(height)")
        #expect(elapsed < stableSurfaceSettleInterval,
                "…decided by the width comparison at once, not by the settle (\(elapsed) s)")
    }
}
