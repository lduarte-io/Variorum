//
//  PaneSurfaceTests.swift
//  VariorumTests
//
//  Phase 13b, Stage 1a — the pane surface's own pins:
//  - N2 (red-on-old): the TK2→TK1 canary is RENDERED. The old
//    TakePaneView captured the canary message into a private var nothing
//    read — a fallback in any take pane was invisible while ReadPostView
//    rendered its own. The unified surface publishes the message into a
//    rendered banner; this pin drives the FULL path (notification →
//    canary → publish → banner) and fails when the publish wiring is
//    reverted (message unpublished, no banner height).
//

import AppKit
import SwiftUI
import Testing
@testable import Variorum

@MainActor
@Suite("Pane surface (13b 1a)", .serialized)
struct PaneSurfaceTests {
    private func pump(_ turns: Int = 4) {
        for _ in 0..<turns {
            RunLoop.main.run(until: Date().addingTimeInterval(0.04))
        }
    }

    private func findPane(_ view: NSView) -> PaneTextView? {
        if let pane = view as? PaneTextView { return pane }
        for sub in view.subviews {
            if let found = findPane(sub) { return found }
        }
        return nil
    }

    @Test func aTK1FallbackRendersAVisibleBannerInThePane() async throws {
        // The memo posture stops the world on fire in debug builds BY
        // DESIGN; the pin swaps the assertion for a no-op for exactly this
        // scope so the fire→render path can run to the banner.
        let originalHandler = FallbackCanary.assertionHandler
        FallbackCanary.assertionHandler = { _ in }
        defer { FallbackCanary.assertionHandler = originalHandler }

        let host = NSHostingController(
            rootView: PaneSurfaceView(text: "a take pane", isLive: false)
                .frame(width: 400))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.layoutSubtreeIfNeeded()
        pump()

        let pane = try #require(findPane(host.view))
        let heightBefore = host.view.fittingSize.height

        // The real trigger: AppKit announces the TK2→TK1 downgrade for
        // exactly this text view.
        NotificationCenter.default.post(
            name: NSTextView.willSwitchToNSLayoutManagerNotification, object: pane)
        pump()
        host.view.layoutSubtreeIfNeeded()
        pump()

        // The message was PUBLISHED for rendering (the old code swallowed
        // it into a private var — reverting the publish wiring reds this)…
        #expect(pane.lastPublishedCanary?.contains("TextKit 2") == true,
                "the canary message reached the rendered surface")
        // …and the banner actually RENDERS: the pane's composition grew by
        // the banner's height.
        let heightAfter = host.view.fittingSize.height
        #expect(heightAfter > heightBefore + 10,
                "the fallback banner adds visible height (\(heightBefore) → \(heightAfter))")

        window.contentViewController = nil
    }

    @Test func theMeasurementBrainMatchesTheRenderedPaneHeight() async throws {
        // The ONE measurement brain (P-3): a mounted pane's rendered
        // height equals PaneMeasurement's answer at the same width — the
        // clipped-take class is a divergence between these two numbers.
        let host = NSHostingController(
            rootView: PaneSurfaceView(
                text: "one\n\ntwo\n\nthree paragraphs of prose", isLive: false)
                .frame(width: 400))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.layoutSubtreeIfNeeded()
        pump(6)
        host.view.layoutSubtreeIfNeeded()

        let pane = try #require(findPane(host.view))
        let measured = PaneMeasurement.height(of: pane)
        #expect(measured > 24, "multi-paragraph text measures past the floor")
        #expect(abs(pane.bounds.height - max(measured, 24)) < 2,
                "rendered height \(pane.bounds.height) tracks the one brain's \(measured)")

        window.contentViewController = nil
    }
}

// MARK: - The ONE publish door (13b Stage 4, ladder round 3 — MINOR-D/E/F)

/// `PanePublisher` is the structural half of the round-3 hardening: every
/// state write a pane makes leaves through it, so the deferral discipline
/// is inherited rather than hand-added per publish. These pins drive it
/// with a MANUAL scheduler (no RunLoop pumping — the standing settle rule)
/// and a stubbed pane, so the coalescing, the convergence loop, and its
/// bound are pinned exactly.
///
/// Honestly unpinnable here (stated, not papered over): that SwiftUI
/// actually drops a state write made during a view-update pass is the
/// framework behavior this exists for — the pins simulate a dropped write
/// rather than provoke one, and the real-mount evidence stays the compare
/// soak's height invariant.
@MainActor
@Suite("Pane publish door (13b 4, round-3 MINOR-D/E/F)")
struct PanePublishDoorTests {
    /// A hand-drained main queue.
    private final class ManualScheduler {
        private var work: [() -> Void] = []
        var pending: Int { work.count }
        func schedule(_ item: @escaping () -> Void) { work.append(item) }
        /// Runs exactly the turns queued when the drain began.
        @discardableResult func drainOneTurn() -> Int {
            let batch = work
            work = []
            batch.forEach { $0() }
            return batch.count
        }
    }

    /// MINOR-F's fix, generalized: however many publishes of either kind
    /// fire inside one turn, exactly ONE deferred turn is scheduled — the
    /// canary echo no longer publishes on its own uncoalesced channel.
    @Test func everyPublishCoalescesIntoOneDeferredTurn() {
        let scheduler = ManualScheduler()
        var heights: [CGFloat] = []
        var canaries: [String] = []
        let publisher = PanePublisher(
            measure: { 46 }, renderedHeight: { 46 },
            writeHeight: { heights.append($0) },
            writeCanary: { canaries.append($0) },
            schedule: { scheduler.schedule($0) })

        publisher.publishHeight()
        publisher.publishCanary("fell back to TextKit 1")
        publisher.publishCanary("fell back to TextKit 1")
        #expect(heights == [46], "the sync height write is the working path")
        #expect(canaries.count == 2, "each canary fire writes synchronously")
        #expect(scheduler.pending == 1, "three publishes, ONE deferred turn")

        scheduler.drainOneTurn()
        #expect(publisher.deferredTurns == 1)
        #expect(canaries.count == 3, "exactly one coalesced canary echo")
        #expect(heights == [46, 46], "one heal re-publish; converged, so it stops")
        #expect(scheduler.pending == 0, "a converged heal schedules nothing further")
    }

    /// MINOR-E's fix: the heal is a CONVERGENCE loop, not one unverified
    /// retry — while the pane renders short of its measured text the
    /// publish is re-made, and the loop is BOUNDED so a structurally
    /// constrained frame cannot spin the main queue forever.
    @Test func theHealReSchedulesWhileTheFrameIsShortAndStopsAtTheBound() {
        let scheduler = ManualScheduler()
        var heights: [CGFloat] = []
        let publisher = PanePublisher(
            measure: { 46 },
            renderedHeight: { 29 },  // the clipped pane: never converges
            writeHeight: { heights.append($0) }, writeCanary: { _ in },
            schedule: { scheduler.schedule($0) })

        publisher.publishHeight()
        var turns = 0
        while scheduler.pending > 0, turns < PanePublisher.healTurnBudget + 5 {
            scheduler.drainOneTurn()
            turns += 1
        }
        #expect(turns == PanePublisher.healTurnBudget,
                "the heal retried the whole budget and no further")
        #expect(heights.count == PanePublisher.healTurnBudget + 1,
                "one sync write + one per healed turn")
        #expect(scheduler.pending == 0, "the bound holds — no perpetual turn")
    }

    /// The other half of the same rule: as soon as the rendered frame
    /// agrees (within the slack the compare soak itself allows), the heal
    /// stops — no gratuitous turns per keystroke.
    @Test func theHealStopsAsSoonAsTheFrameConverges() {
        let scheduler = ManualScheduler()
        var rendered: CGFloat = 29
        var heights: [CGFloat] = []
        let publisher = PanePublisher(
            measure: { 46 }, renderedHeight: { rendered },
            writeHeight: { heights.append($0) }, writeCanary: { _ in },
            schedule: { scheduler.schedule($0) })

        publisher.publishHeight()
        rendered = 46 - PanePublisher.convergenceSlack  // exactly within slack
        scheduler.drainOneTurn()
        #expect(scheduler.pending == 0, "converged frame ⇒ no further turns")
        #expect(heights == [46, 46])
    }

    /// The hole the door exists for: a synchronous write DROPPED (as
    /// SwiftUI may drop one made during an update pass) is re-made on the
    /// deferred turn, so the pane ends framed at its measured height.
    @Test func aDroppedSynchronousWriteIsRepublishedOnTheDeferredTurn() {
        let scheduler = ManualScheduler()
        var landed: CGFloat = 0
        var dropNext = true
        let publisher = PanePublisher(
            measure: { 46 }, renderedHeight: { landed },
            writeHeight: { height in
                if dropNext { dropNext = false; return }  // the dropped write
                landed = height
            },
            writeCanary: { _ in }, schedule: { scheduler.schedule($0) })

        publisher.publishHeight()
        #expect(landed == 0, "the sync write was dropped — the bug's state")
        scheduler.drainOneTurn()
        #expect(landed == 46, "the heal re-published and it landed")
        #expect(scheduler.pending == 0, "and then converged")
    }

    // MARK: F1 — the one-publish-door guarantee, ENFORCED (13c 1A)
    //
    // The Stage 4 gate found a real bug here: a height written into SwiftUI
    // state DURING an update pass is silently dropped, leaving a pane framed
    // one line tall under two lines of text. `PanePublisher` closed it for
    // the two publishes that existed — but the routing itself was a COMMENT
    // ("Nothing in this coordinator writes SwiftUI state except through
    // it"), and `install` takes the write closures as loose parameters, so a
    // third piece of pane state (a measured width, a scroll offset, a
    // selection echo) could be written straight out of `updateNSView` and
    // nothing would fail. That is P-1's shape one layer down: green by
    // audit rather than by construction.
    //
    // The chosen closing is the WALK (the registry-walk spirit, and the
    // shape the plan's F1 finding offered first), because the type-level
    // alternative — `install` taking one value only `PanePublisher` can
    // consume — channels only the publishes that exist today and would not
    // stop a fourth closure being added beside it. The walk is written
    // NAME-INDEPENDENTLY: it reads the surface's own `@Binding`
    // declarations out of the source, so a binding added tomorrow is
    // covered without anyone remembering to update this test.

    /// Every SwiftUI state write the pane surface makes must be lexically
    /// inside the `install(…)` call — i.e. it becomes a `PanePublisher`
    /// write closure and inherits the sync-write + bounded-heal discipline.
    @Test func everyPaneStateWriteLeavesThroughThePublishDoor() throws {
        let source = try PaneSurfaceSource.text()
        let representable = try PaneSurfaceSource.body(
            of: "private struct PaneSurfaceRepresentable", in: source)

        // The bindings, read from the source itself — no hard-coded list.
        var bindings: [String] = []
        for line in representable.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("@Binding var ") else { continue }
            let rest = trimmed.dropFirst("@Binding var ".count)
            bindings.append(String(rest.prefix { $0.isLetter || $0.isNumber || $0 == "_" }))
        }
        #expect(bindings.count >= 2, "found the pane's bindings: \(bindings)")

        let installCall = try PaneSurfaceSource.installCall(in: representable)
        for name in bindings {
            let assignments = PaneSurfaceSource.assignmentCount(of: name, in: representable)
            let insideInstall = PaneSurfaceSource.assignmentCount(of: name, in: installCall)
            #expect(assignments > 0, "\(name) is written somewhere")
            #expect(assignments == insideInstall,
                    "every write to `\(name)` must be a PanePublisher write closure passed to install(…) — found \(assignments) write(s), \(insideInstall) inside the door")
        }
    }

    /// …and the coordinator can never acquire state of its own: SwiftUI
    /// bindings never enter it, so `install`'s closures remain the only
    /// channel by which anything it does can reach a view.
    @Test func theCoordinatorHoldsNoSwiftUIStateOfItsOwn() throws {
        let source = try PaneSurfaceSource.text()
        let coordinator = try PaneSurfaceSource.body(
            of: "final class Coordinator: NSObject, NSTextViewDelegate", in: source)
        #expect(!coordinator.contains("@Binding"),
                "the coordinator must not declare SwiftUI bindings")
        #expect(!coordinator.contains("@State"),
                "the coordinator must not declare SwiftUI state")
        // The publisher is the only thing it stores that can write outward.
        #expect(coordinator.contains("private var publisher: PanePublisher?"))
    }

    /// A dismantled pane publishes nothing: `invalidate()` drops every
    /// closure and every pending duty, and an already-scheduled turn finds
    /// nothing to do (no write into a torn-down view's state).
    @Test func anInvalidatedPublisherStopsWriting() {
        let scheduler = ManualScheduler()
        var heights: [CGFloat] = []
        var canaries: [String] = []
        let publisher = PanePublisher(
            measure: { 46 }, renderedHeight: { 29 },
            writeHeight: { heights.append($0) },
            writeCanary: { canaries.append($0) },
            schedule: { scheduler.schedule($0) })

        publisher.publishHeight()
        publisher.publishCanary("fell back")
        publisher.invalidate()
        scheduler.drainOneTurn()
        #expect(heights == [46], "only the pre-invalidate sync write")
        #expect(canaries == ["fell back"], "no echo after teardown")
        #expect(scheduler.pending == 0)

        publisher.publishHeight()
        #expect(heights == [46], "and nothing publishes afterwards")
        #expect(scheduler.pending == 0)
    }
}

// MARK: - Source reading for the F1 walk

/// Reads `PaneSurface.swift` and slices out balanced-brace bodies. Crude by
/// design: a real parser would be a dependency, and the shapes this walk
/// asks about (a declaration's body; one call's argument list) are
/// unambiguous in this file.
private enum PaneSurfaceSource {
    static func text() throws -> String {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()   // VariorumTests
            .deletingLastPathComponent()   // App/Variorum
            .appendingPathComponent("Variorum/Surface/PaneSurface.swift")
        return try String(contentsOf: url, encoding: .utf8)
    }

    /// The `{ … }` body following `declaration`, brace-balanced.
    static func body(of declaration: String, in source: String) throws -> String {
        let start = try #require(source.range(of: declaration),
                                 "PaneSurface.swift no longer declares `\(declaration)` — the F1 walk must be re-pointed, not deleted")
        return balanced(from: source[start.upperBound...], open: "{", close: "}")
    }

    /// The argument list of the `install(` call, parenthesis-balanced.
    static func installCall(in body: String) throws -> String {
        let start = try #require(body.range(of: "install("),
                                 "the pane no longer installs through one call")
        // Balance from the "(" itself — `upperBound` sits just past it.
        return balanced(from: body[body.index(before: start.upperBound)...],
                        open: "(", close: ")")
    }

    /// Assignments `name =` (never `==`, `>=`, `!=`, `+=`).
    static func assignmentCount(of name: String, in text: String) -> Int {
        var count = 0
        var rest = Substring(text)
        while let hit = rest.range(of: name) {
            let after = rest[hit.upperBound...].drop { $0 == " " }
            let before = hit.lowerBound == rest.startIndex
                ? Character(" ") : rest[rest.index(before: hit.lowerBound)]
            let isWholeWord = !(before.isLetter || before.isNumber || before == "_"
                || before == "." || before == "$")
            if isWholeWord, after.first == "=", after.dropFirst().first != "=" {
                count += 1
            }
            rest = rest[hit.upperBound...]
        }
        return count
    }

    private static func balanced(
        from text: Substring, open: Character, close: Character
    ) -> String {
        var depth = 0
        var started = false
        var out = ""
        for character in text {
            if character == open {
                depth += 1
                started = true
            }
            if started { out.append(character) }
            if character == close {
                depth -= 1
                if depth == 0 { break }
            }
        }
        return out
    }
}
