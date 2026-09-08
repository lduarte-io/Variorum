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

/// 17o batch b's ladder, R1-2 / R1-3: a pane host whose liveness a pin can
/// flip — programmatically (the N9 and bloom landings, Read's edit face) or
/// through the pane's own click-to-focus road (`PaneTextView.plainClick(at:)`
/// → `onFocusRequest`). File-scope: the `@Observable` macro cannot expand on a
/// `private` nested type.
@MainActor @Observable
fileprivate final class PaneLiveBox {
    var live = false
    var landing: Int?
}

fileprivate struct PaneLiveFlipHost: View {
    let box: PaneLiveBox
    let text: String
    var body: some View {
        PaneSurfaceView(
            text: text, isLive: box.live,
            onFocusRequest: { box.live = true },
            caretOnGoingLive: box.landing)
        .frame(width: 400)
    }
}

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

    // MARK: - 17o batch b's ladder, R1-2 / R1-3 — where a pane's caret lands on going live

    private func mountFlipHost(
        text: String, landing: Int?
    ) -> (box: PaneLiveBox, host: NSHostingController<PaneLiveFlipHost>, window: NSWindow, pane: PaneTextView)? {
        let box = PaneLiveBox()
        box.landing = landing
        let host = NSHostingController(rootView: PaneLiveFlipHost(box: box, text: text))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.layoutSubtreeIfNeeded()
        pump()
        guard let pane = findPane(host.view) else { return nil }
        return (box, host, window, pane)
    }

    private static let sixtyCharacterTake =
        "A take of prose long enough that a caret can sit well inside it."

    /// R1-3: a PROGRAMMATIC transition with nothing remembered lands at the
    /// take's START. Red on the pre-fix tree: the selection stayed where
    /// AppKit's `string =` left it — the END — and the live pane then
    /// reported that end as her place.
    @Test func aProgrammaticTransitionWithNothingRememberedLandsAtTheTakesStart() async throws {
        let (box, host, window, pane) = try #require(
            mountFlipHost(text: Self.sixtyCharacterTake, landing: nil))
        #expect(!pane.isEditable)
        box.live = true
        pump()
        host.view.layoutSubtreeIfNeeded()
        pump()
        #expect(pane.isEditable, "the flip made the pane live")
        #expect(pane.selectedRange().location == 0,
                "nothing remembered ⇒ the take's start, not AppKit's END (\(pane.selectedRange().location) of \((pane.string as NSString).length))")
        window.contentViewController = nil
    }

    /// R1-2: a CLICK into a read pane keeps the click's own place — the
    /// remembered offset the composition hands the pane is for programmatic
    /// landings only. Red on the pre-fix tree: the transition overwrote the
    /// click's 10 with the remembered 30 before the responder claim.
    @Test func aClickIntoAReadPaneKeepsTheClicksOwnPlaceOverTheRememberedOne() async throws {
        let (box, host, window, pane) = try #require(
            mountFlipHost(text: Self.sixtyCharacterTake, landing: 30))
        // What `mouseDown` does: the selection tracking loop places the
        // caret, then the plain-click road asks for focus.
        pane.setSelectedRange(NSRange(location: 10, length: 0))
        pane.plainClick(at: 10)
        #expect(box.live, "the click asked for focus")
        pump()
        host.view.layoutSubtreeIfNeeded()
        pump()
        #expect(pane.isEditable)
        #expect(pane.selectedRange().location == 10,
                "the click's place stands (\(pane.selectedRange().location)); the remembered 30 is for programmatic landings")
        window.contentViewController = nil
    }

    /// The rule's other half, unchanged by the fix (a guard, green both
    /// sides): a PROGRAMMATIC transition lands at the remembered place — and
    /// the room's `Int.max` asks for the END, clamped.
    @Test func aProgrammaticTransitionLandsAtTheRememberedPlaceAndIntMaxMeansTheEnd() async throws {
        let (box, host, window, pane) = try #require(
            mountFlipHost(text: Self.sixtyCharacterTake, landing: 30))
        box.live = true
        pump()
        host.view.layoutSubtreeIfNeeded()
        pump()
        #expect(pane.selectedRange().location == 30, "the remembered place")
        window.contentViewController = nil

        let (box2, host2, window2, pane2) = try #require(
            mountFlipHost(text: Self.sixtyCharacterTake, landing: .max))
        box2.live = true
        pump()
        host2.view.layoutSubtreeIfNeeded()
        pump()
        #expect(pane2.selectedRange().location == (pane2.string as NSString).length,
                "Int.max is the END, clamped to the text")
        window2.contentViewController = nil
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

    /// **13d batch 5 — the long-content-panes memo, §6 item 5 (her "Accept
    /// all"): the idle-voice-switch residual.** The memo's edge 3: a
    /// full-range invalidation with NO user event behind it — a voice switch,
    /// or (since A23) a paragraph-gap change — re-attributes the whole
    /// storage, which is exactly the write A47c traced as destroying a
    /// tail-scrolled pane's rendering surfaces. The occasion heals (click,
    /// scroll-end, ring move) cannot reach an idle card, so the branch now
    /// re-asserts the render tier itself. Pinned at the mechanism the A47c
    /// experiment established (`renderRestoresRun`), which is the same seam
    /// its own pins use.
    @Test func aGapOrVoiceChangeRestoresTheRenderTierWithNoUserEvent() async throws {
        let saved = UserDefaults.standard.string(forKey: ParagraphGap.settingKey)
        defer {
            if let saved {
                UserDefaults.standard.set(saved, forKey: ParagraphGap.settingKey)
            } else {
                UserDefaults.standard.removeObject(forKey: ParagraphGap.settingKey)
            }
        }
        UserDefaults.standard.set(ParagraphGap.standard.rawValue, forKey: ParagraphGap.settingKey)

        let host = NSHostingController(
            rootView: PaneSurfaceView(
                text: (1...40).map { "Paragraph \($0) of a long take." }.joined(separator: "\n\n"),
                isLive: false)
                .frame(width: 400))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.layoutSubtreeIfNeeded()
        pump(6)

        let pane = try #require(findPane(host.view))
        let spacingBefore = pane.defaultParagraphStyle?.paragraphSpacing ?? -1
        let restoresBefore = pane.renderRestoresRun

        // The invalidation, with no click, no scroll and no ring move.
        UserDefaults.standard.set(
            ParagraphGap.paragraphTall.rawValue, forKey: ParagraphGap.settingKey)
        // The restore is DEFERRED to the next main-queue turn (by design —
        // inside updateNSView the write that kills has not happened yet), and
        // in this host such a turn only runs when the main actor yields.
        for _ in 0..<6 { pump(1); await Task.yield() }
        host.view.layoutSubtreeIfNeeded()
        for _ in 0..<6 { pump(1); await Task.yield() }

        #expect((pane.defaultParagraphStyle?.paragraphSpacing ?? -1) > spacingBefore,
                "non-vacuity: the full-range re-attribution really ran")
        #expect(pane.renderRestoresRun > restoresBefore,
                "…and it re-asserted the render tier (restores \(restoresBefore) → \(pane.renderRestoresRun)) — without this the memo's edge 3 leaves a scrolled card blank until she clicks")

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

    /// **The walk's own counting rule, pinned** (13c Stage 1 ladder, R1-6,
    /// extended at R2-9). The walk above is only as strong as what it
    /// recognizes as a WRITE, and its first cut saw one of the four forms
    /// Swift offers for assigning through a `@Binding`; R1-6 added the
    /// other three. R2-9 added the fifth shape — COMPOUND assignment —
    /// which mutates a binding exactly as a plain `=` does and was counted
    /// in neither bucket, so such a write could escape the door while the
    /// equality assertion still passed. This is the guard on the guard.
    ///
    /// Honest about its two edges (R2-9, R3-6): a binding **forwarded to a
    /// child** (`Child(height: $height)`) and a write through a **mutating
    /// method** (`height.negate()`) are not assignments here and are not
    /// claimed to be — the last two lines below pin that limit VISIBLY,
    /// rather than leaving a future reader to discover it. See
    /// `assignmentCount`'s doc comment for why the mutating-method form is
    /// documented instead of counted.
    @Test func theWalkCountsEveryFormOfWritingToABinding() {
        let source = """
            self.height = 1
            height = 2
            $height.wrappedValue = 3
            _height.wrappedValue = 4
            height += 5
            self.height -= 6
            $height.wrappedValue *= 7
            if height == 8 { }
            if height >= 9 { }
            if height <= 10 { }
            if height != 11 { }
            let other = height
            heightOfSomethingElse = 12
            Child(height: $height)
            height.negate()
            """
        #expect(PaneSurfaceSource.assignmentCount(of: "height", in: source) == 7,
                "the four direct forms plus their compound-assignment variants — and nothing else")
        // The documented limit, pinned so it is visible rather than
        // discovered: a mutating method is a write the lexical rule cannot
        // tell from a read (`height.round()` vs `height.rounded()`).
        #expect(PaneSurfaceSource.assignmentCount(of: "height", in: "height.negate()") == 0,
                "R3-6's limit, stated in a pin so nobody infers completeness the walk doesn't claim")
        // …and the door-scoped count uses the SAME rule, so the equality
        // assertion compares like with like.
        #expect(PaneSurfaceSource.assignmentCount(
            of: "height", in: "$height.wrappedValue = 3") == 1)
        #expect(PaneSurfaceSource.assignmentCount(of: "height", in: "self.height = 1") == 1)
        #expect(PaneSurfaceSource.assignmentCount(of: "height", in: "height == 1") == 0)
        #expect(PaneSurfaceSource.assignmentCount(of: "height", in: "height += 1") == 1)
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

    /// Assignments to a `@Binding var name`, in **every form Swift offers**
    /// (never `==`, `>=`, `!=`, `+=`).
    ///
    /// 13c Stage 1 ladder, R1-6: the first cut counted only the bare
    /// `name =` form and REQUIRED the preceding character not to be `.`,
    /// `$` or `_` — so `self.name = …`, `$name.wrappedValue = …` and
    /// `_name.wrappedValue = …` were counted in NEITHER bucket, and a write
    /// in any of them could leave the coordinator while the walk's equality
    /// assertion still passed. That is exactly the "green by audit" gap F1
    /// was raised about, one level deeper: the guard against un-routed
    /// writes had un-guarded routes of its own.
    ///
    /// The four search forms are mutually exclusive by construction (the
    /// bare form's whole-word rule rejects a preceding `.`, `$` or `_`, and
    /// the wrapped forms are followed by `.` rather than `=`), so nothing is
    /// double-counted. `self.$name` / `self._name` are covered as suffixes
    /// of their bare twins.
    ///
    /// **What it does NOT see, stated rather than implied** (13c Stage 1
    /// ladder, R2-9 — the same overstatement one level up that R1-6 closed
    /// one level down). TWO limits, both real, both narrower than the last:
    ///
    /// 1. A binding **forwarded** to a child view (`Child(height: $height)`)
    ///    is not an assignment here, and a write the child then makes never
    ///    appears in this file at all. That is a different act from the one
    ///    F1 named.
    /// 2. A write through a **mutating method** on the binding's value
    ///    (`height.negate()`, `$text.wrappedValue.append(…)`) mutates it
    ///    exactly as `=` does, and is invisible to a rule that looks for an
    ///    assignment operator (13c ladder round 3, R3-6). **It is documented
    ///    rather than counted, deliberately:** the walk is lexical, and
    ///    `height.rounded()` and `height.round()` are indistinguishable
    ///    without a type checker — counting every `name.foo(` would flag
    ///    reads as writes and make the equality assertion meaningless. Not
    ///    reachable with today's two bindings (a `CGFloat` and a `String?`,
    ///    both only ever assigned); **if a pane ever publishes a collection
    ///    or a flag set, this is the form to close**, and the honest closing
    ///    is a type-level one, not another substring rule.
    ///
    /// The walk claims only what it checks: every write *made by this file*
    /// **through an assignment** leaves through the door.
    static func assignmentCount(of name: String, in text: String) -> Int {
        wholeWordAssignments(of: name, in: text)
            + literalAssignments(of: "self.\(name)", in: text)
            + literalAssignments(of: "$\(name).wrappedValue", in: text)
            + literalAssignments(of: "_\(name).wrappedValue", in: text)
    }

    private static func wholeWordAssignments(of name: String, in text: String) -> Int {
        var count = 0
        var rest = Substring(text)
        while let hit = rest.range(of: name) {
            let before = hit.lowerBound == rest.startIndex
                ? Character(" ") : rest[rest.index(before: hit.lowerBound)]
            let isWholeWord = !(before.isLetter || before.isNumber || before == "_"
                || before == "." || before == "$")
            if isWholeWord, isAssignment(rest[hit.upperBound...]) { count += 1 }
            rest = rest[hit.upperBound...]
        }
        return count
    }

    private static func literalAssignments(of target: String, in text: String) -> Int {
        var count = 0
        var rest = Substring(text)
        while let hit = rest.range(of: target) {
            if isAssignment(rest[hit.upperBound...]) { count += 1 }
            rest = rest[hit.upperBound...]
        }
        return count
    }

    /// A write: a single `=` (never `==`), OR an arithmetic COMPOUND
    /// assignment (`+=`, `-=`, `*=`, `/=`, `%=`) — 13c Stage 1 ladder,
    /// R2-9. `height += 8` mutates the binding exactly as `height = …`
    /// does, and the first rule counted it in neither bucket, so such a
    /// write could escape the door while the walk's equality assertion
    /// still passed.
    ///
    /// `<` and `>` are deliberately excluded: `<<=`/`>>=` are writes but
    /// `<=`/`>=` are comparisons, and no shift is meaningful on the kinds
    /// of state a pane publishes. `&=`/`|=`/`^=` likewise — bitwise, and
    /// their comparison-lookalikes (`&&`, `||`) would need more care than
    /// the classes involved earn. If a pane ever publishes an integer flag
    /// set, extend the operator set here, not the callers.
    private static func isAssignment(_ tail: Substring) -> Bool {
        let after = tail.drop { $0 == " " }
        guard let first = after.first else { return false }
        if first == "=" { return after.dropFirst().first != "=" }
        guard "+-*/%".contains(first) else { return false }
        let rest = after.dropFirst()
        return rest.first == "=" && rest.dropFirst().first != "="
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
