//
//  SurfaceComposition.swift
//  VariorumTests
//
//  17f/P47 (the pre-13u round's Act 5) — THE COMPOSITION READ every surface pin shares. VX-329 U1: moved byte-for-byte
//  out of `ProtectionSurfaceRenderTests.swift` when that suite was deleted with today's surfaces it pinned (today's
//  lobby, the posture copy, the Backups tab's lock-time copy); the road's surface suites read it.
//
//  **How these read the surface, and why it is this way.** Two measurements
//  were tried first and are recorded so nobody repeats them: the hosted view's
//  ACCESSIBILITY tree is empty in this environment (`NSHostingView` reports
//  zero subviews and zero accessibility children), and `dataWithPDF` captures
//  nothing (the hosting view is layer-backed, so nothing draws through
//  `draw(_:)`). What does work is reflecting the view's own composition:
//  `dump` walks the real `body` and every `Text`'s storage string appears in
//  it — including the fact that an UNTAKEN `_ConditionalContent` branch is
//  ABSENT (verified: a lobby with roads carries no dead-end sentence), which
//  is what makes this a composition pin rather than a source-text grep. Each
//  test ALSO hosts the real view in a real window, so a surface that cannot be
//  constructed or laid out fails here too.
//
//  One mechanical note: `dump` escapes non-ASCII, so the sentences (which carry
//  typographic apostrophes) are matched through `String(reflecting:)` — the
//  same escaping — never against the raw literal.
//
//  **THE ROAD'S OWN LIMIT, recorded beside the two rejected ones** (added
//  2026-08-31, the midpoint review's n1 — a measurement road's boundary is
//  part of the measurement, and the two roads above are recorded precisely so
//  nobody re-walks them): a composition dump proves a `Text` is **COMPOSED**,
//  not that it is **VISIBLE**. `.opacity(0)`, `.hidden()`, a zero or clipped
//  frame, a colour matching the ground, or a sentence pushed outside its
//  container all keep these pins green. What the road DOES close is the hole
//  it was built for — the whole `Text` deleted, or a branch that never takes —
//  and the hosted-window half of each pin adds "and the surface can be built
//  and laid out". Anything finer than that is a screenshot question, and it is
//  the standalone visual review's (13s), not a unit test's.
//
//  One consequence worth naming, because it is where the limit bites: a
//  sentence composed inside a `GeometryReader`'s content closure is NOT in the
//  dump at all (the closure runs at layout time), so a surface shaped that way
//  needs a mounted pin instead. The phone's twin met exactly that on its shelf
//  and records what it did — a live accessibility tree, which this environment
//  does not have.
//

import AppKit
import Foundation
import SwiftUI
import Testing

@testable import Variorum
import VariorumCore

@MainActor
enum SurfaceComposition {
    /// The view's own composition, as a searchable blob.
    static func text<V: View>(of view: V) -> String {
        var out = ""
        dump(view, to: &out, maxDepth: 120)
        return out
    }

    /// True when the surface carries this exact sentence.
    static func carries(_ sentence: String, in composition: String) -> Bool {
        composition.contains(String(reflecting: sentence))
    }

    /// Builds and lays the real view out in a real window — a surface that
    /// crashes or cannot lay out fails the pin that hosts it.
    static func host<V: View>(_ view: V, size: NSSize) async {
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer { window.orderOut(nil); window.close() }
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(origin: .zero, size: size)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        for _ in 0..<4 {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            try? await Task.sleep(for: .milliseconds(30))
        }
    }
}

