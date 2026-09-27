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
import VariorumCore
@testable import Variorum

/// 17o batch b's ladder, R1-2 / R1-3: a pane host whose liveness a pin can
/// flip — programmatically (the N9 and bloom landings, Read's edit face) or
/// through the pane's own click-to-focus road (`PaneTextView.plainClick(at:)`
/// → `onFocusRequest`). File-scope: the `@Observable` macro cannot expand on a
/// `private` nested type.
@MainActor @Observable
fileprivate final class PaneLiveBox {
    var live = false
    var landing: PaneCaretLanding = .leave
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

/// The sanity pass's RAISE-2: a host that passes NO landing at all — the
/// six hosts outside R1-3's trace (the fan/stack cards, Compare, Canvas, the
/// Write panel, the Book Index) and every post-structural ring landing.
fileprivate struct PaneBareHost: View {
    let box: PaneLiveBox
    let text: String
    var body: some View {
        PaneSurfaceView(text: text, isLive: box.live)
            .frame(width: 400)
    }
}


/// 18g ladder round 1 (the sanity pass's raise): a pane whose TOKENS a pin
/// can move after the mount — the palette click, as every host delivers it
/// (new tokens pushed into the same mounted surface).
@MainActor @Observable
fileprivate final class PaneTokensBox {
    var tokens = VoiceTokens.resolve(voice: .terminal, dark: false)
}

fileprivate struct PaneTokensHost: View {
    let box: PaneTokensBox
    var body: some View {
        PaneSurfaceView(
            text: "see [the walk](https://example.com/walk) here", isLive: false,
            tokens: box.tokens)
        .frame(width: 400)
    }
}

/// 17o batch c (row 6): a pane whose INDICATOR a pin can set, so the three
/// styles are driven through the same construction every host uses.
fileprivate struct PaneIndicatorHost: View {
    let live: Bool
    let indicator: EditingIndicatorStyle
    let tokens: VoiceTokens
    var body: some View {
        PaneSurfaceView(
            text: "a take of honest prose", isLive: live,
            tokens: tokens, indicator: indicator)
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


    // MARK: - 17o batch c, ledger row 6 — the ring follows the preference

    /// Her U-7, verbatim: *"the take mode always shows a ring around what
    /// piece you're editing — it doesn't follow the preference on cursor
    /// being enough, wanting background wash, or ring"*; U-19 (5) confirms
    /// the preference governs EVERY live pane.
    ///
    /// **The traced mechanism:** `PaneSurfaceView` stroked `tokens.ring`
    /// whenever `isLive`, reading no setting at all, while the Write
    /// surface has honoured the three styles since R14/R22 (`BlockDecor`'s
    /// `renderIndicator`). RED ON THE PRE-FIX TREE by construction: `.off`
    /// and `.background` both drew the ring.
    ///
    /// **R22's reason is preserved, not overruled** (recorded in the batch
    /// record's disposition): among many editable surfaces the ring is how
    /// you find the one live editor — and it stays the shipped look under
    /// `.outline`, which is what a pane wears wherever the appearance push
    /// has not reached. What changed is that the pane no longer overrides
    /// the preference she set.
    @Test func theLivePanesDecorationFollowsTheIndicatorPreference() {
        let tokens = VoiceTokens.resolve(voice: .terminal, dark: false)
        let rest = PaneDecoration.resolve(isLive: false, indicator: .outline, tokens: tokens)

        let off = PaneDecoration.resolve(isLive: true, indicator: .off, tokens: tokens)
        #expect(off == rest,
                "`off` — the cursor is enough: the live pane wears exactly the resting hairline")

        let outline = PaneDecoration.resolve(isLive: true, indicator: .outline, tokens: tokens)
        #expect(outline.stroke == tokens.ring && outline.lineWidth == 1.5 && outline.fill == nil,
                "`outline` — R22's ring, unchanged")

        let background = PaneDecoration.resolve(isLive: true, indicator: .background, tokens: tokens)
        #expect(background.fill == tokens.wash,
                "`background` — a wash in the SAME token Write fills the caret block with")
        #expect(background.stroke == rest.stroke && background.lineWidth == rest.lineWidth,
                "…and no ring beside it")

        // The rest look is untouched by the preference — only the LIVE pane
        // reads it (a read pane is not what she is editing).
        for style in EditingIndicatorStyle.allCases {
            #expect(PaneDecoration.resolve(isLive: false, indicator: style, tokens: tokens) == rest,
                    "a read pane renders the same under \(style)")
        }
    }

    /// The three hosts that keep a frame of their OWN around the live pane
    /// (`ReadEditPane`, `BookIndexView`, `BlocksWorkbenchView`) consume the
    /// same rule instead of reaching for `tokens.ring` — the brief's
    /// "if a host draws its own ring, it consumes the pane's decision".
    @Test func aHostsOwnFrameConsumesTheSameRule() {
        let tokens = VoiceTokens.resolve(voice: .study, dark: false)
        #expect(PaneDecoration.hostRing(indicator: .outline, tokens: tokens) == tokens.ring)
        #expect(PaneDecoration.hostRing(indicator: .off, tokens: tokens) == nil)
        #expect(PaneDecoration.hostRing(indicator: .background, tokens: tokens) == nil)
    }

    /// **18g ladder round 1, the sanity pass's raise (RED on `3adb7d2d`):**
    /// a mounted pane holding a markdown link, its host's tokens moved to a
    /// palette — the link's colour in the pane's STORAGE must follow the
    /// palette's accent. Before the fix the pane's only re-style roads were
    /// the ink gate and the base-attributes gate, neither of which a palette
    /// moves, so the link kept its old colour until the pane re-materialized.
    @Test func aPaletteChangeRecoloursAMountedPanesLink() throws {
        let savedPalette = MarkdownStyling.palette
        defer { MarkdownStyling.palette = savedPalette }
        let box = PaneTokensBox()
        let host = NSHostingController(rootView: PaneTokensHost(box: box))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 600),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        defer { window.contentViewController = nil }
        host.view.layoutSubtreeIfNeeded()
        pump()
        let pane = try #require(findPane(host.view))
        let storage = try #require(pane.textStorage)
        let linkAt = (pane.string as NSString).range(of: "the walk").location
        #expect(linkAt != NSNotFound)
        func linkColour() -> NSColor? {
            (storage.attribute(.foregroundColor, at: linkAt, effectiveRange: nil) as? NSColor)?
                .usingColorSpace(.sRGB)
        }
        func matches(_ colour: NSColor?, _ expected: Color) -> Bool {
            guard let colour, let want = NSColor(expected).usingColorSpace(.sRGB) else { return false }
            return abs(colour.redComponent - want.redComponent) < 0.002
                && abs(colour.greenComponent - want.greenComponent) < 0.002
                && abs(colour.blueComponent - want.blueComponent) < 0.002
        }
        #expect(matches(linkColour(), box.tokens.accent), "mounted: the voice's accent")

        let lavender = VoiceTokens.resolve(
            voice: .terminal, palette: .lavender, tint: .none, dark: false)
        box.tokens = lavender
        host.view.layoutSubtreeIfNeeded()
        pump()
        #expect(matches(linkColour(), lavender.accent),
                "after the palette click: the link wears the palette's accent in the SAME pane")
        // 18j ladder round 1 (R1-1): the pane's ink is the voice's ONE
        // dynamic object now, so "still the voice's" is an identity, not a
        // colour comparison.
        #expect(pane.textColor === EditorTypography.ink(for: .terminal),
                "…while the ink is still the voice's")
    }

    /// **18j ladder round 1 (R1-1) — RED ON OLD.** A pane's ink is the
    /// voice's ONE dynamic object (`EditorTypography.ink(for:)`), the same
    /// one the editor's base attributes and the face palette carry, so a
    /// light/dark change moves nothing here: `applyStyle`'s gate compares the
    /// object to itself and the whole-pane `textColor` write it guards never
    /// runs — the 18g ladder's R2-5 carve, extended to the panes. Before
    /// this the host passed `NSColor(tokens.ink)`, a colour frozen per
    /// appearance, and every flip re-attributed the pane.
    @Test func anAppearanceChangeWritesNothingInAMountedPane() throws {
        let savedPalette = MarkdownStyling.palette
        defer { MarkdownStyling.palette = savedPalette }
        let box = PaneTokensBox()
        let host = NSHostingController(rootView: PaneTokensHost(box: box))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 600),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        defer { window.contentViewController = nil }
        host.view.layoutSubtreeIfNeeded()
        pump()
        let pane = try #require(findPane(host.view))
        let storage = try #require(pane.textStorage)
        let voiceInk = EditorTypography.ink(for: .terminal)
        #expect(pane.appliedInk === voiceInk, "mounted: the dynamic ink is the applied one")
        #expect(storage.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor === voiceInk,
                "…and it is what the prose carries")

        box.tokens = VoiceTokens.resolve(voice: .terminal, dark: true)
        host.view.layoutSubtreeIfNeeded()
        pump()
        #expect(pane.appliedInk === voiceInk, "the flip moved no ink — the same object answers dark")
        #expect(storage.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor === voiceInk,
                "…so the storage was not re-attributed")
        #expect(ResolvedInk.reads(voiceInk, as: VoiceTokens.terminalDark.ink, dark: true),
                "…and it draws in the dark ink under the dark appearance")
    }

    /// A pane the appearance push has NOT reached keeps the shipped ring —
    /// the pins, the tutorial samples, any future host built before it is
    /// wired. (The default is a decision; this states it.)
    @Test func aPaneWithNoPushKeepsTheShippedRing() {
        let tokens = VoiceTokens.resolve(voice: .terminal, dark: false)
        let defaulted = PaneSurfaceView(text: "x", isLive: true, tokens: tokens)
        #expect(defaulted.indicator == .outline)
    }

    /// And it MOUNTS under each style: the decoration is a background and an
    /// overlay, so it can never move the pane's measured height (which would
    /// re-open the batch-12 clipped-take class one setting over).
    @Test func theIndicatorNeverMovesThePanesHeight() async throws {
        let tokens = VoiceTokens.resolve(voice: .terminal, dark: false)
        var heights: [EditingIndicatorStyle: CGFloat] = [:]
        for style in EditingIndicatorStyle.allCases {
            let host = NSHostingController(
                rootView: PaneIndicatorHost(live: true, indicator: style, tokens: tokens))
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 600),
                styleMask: [.borderless], backing: .buffered, defer: false)
            window.contentViewController = host
            host.view.layoutSubtreeIfNeeded()
            pump()
            let pane = try #require(findPane(host.view))
            heights[style] = pane.bounds.height
            window.contentViewController = nil
        }
        #expect(heights[.off] == heights[.outline] && heights[.outline] == heights[.background],
                "the pane measures the same under every style (\(heights))")
        #expect((heights[.outline] ?? 0) > 0, "non-vacuity: the panes mounted")
    }

    // MARK: - 17o batch b's ladder, R1-2 / R1-3 — where a pane's caret lands on going live

    private func mountFlipHost(
        text: String, landing: PaneCaretLanding
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
    /// take's START — what the reporting hosts' models hand a pane for the
    /// note's own entry (`.start`). Red on the pre-fix tree: the selection
    /// stayed where AppKit's `string =` left it — the END — and the live
    /// pane then reported that end as her place.
    @Test func aProgrammaticTransitionWithNothingRememberedLandsAtTheTakesStart() async throws {
        let (box, host, window, pane) = try #require(
            mountFlipHost(text: Self.sixtyCharacterTake, landing: .start))
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
            mountFlipHost(text: Self.sixtyCharacterTake, landing: .offset(30)))
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

    /// The sanity pass's RAISE-2 (scope): a host that passes NO landing keeps
    /// the shipped END on a programmatic transition — the rule R1-3 built is
    /// for the hosts that pass one (the ones whose panes REPORT). Red on the
    /// tree before the raise's fix: `?? 0` landed every host at the start.
    @Test func aHostThatPassesNoLandingKeepsTheShippedEndOnAProgrammaticTransition() async throws {
        let box = PaneLiveBox()
        let host = NSHostingController(rootView: PaneBareHost(box: box, text: Self.sixtyCharacterTake))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.layoutSubtreeIfNeeded()
        pump()
        let pane = try #require(findPane(host.view))
        box.live = true
        pump()
        host.view.layoutSubtreeIfNeeded()
        pump()
        #expect(pane.isEditable)
        #expect(pane.selectedRange().location == (pane.string as NSString).length,
                "no landing passed ⇒ the selection is left where it was — the shipped END (\(pane.selectedRange().location) of \((pane.string as NSString).length))")
        window.contentViewController = nil
    }

    /// The rule's other half, unchanged by the fix (a guard, green both
    /// sides): a PROGRAMMATIC transition lands at the remembered place — and
    /// the room's `.end` asks for the END.
    @Test func aProgrammaticTransitionLandsAtTheRememberedPlaceAndIntMaxMeansTheEnd() async throws {
        let (box, host, window, pane) = try #require(
            mountFlipHost(text: Self.sixtyCharacterTake, landing: .offset(30)))
        box.live = true
        pump()
        host.view.layoutSubtreeIfNeeded()
        pump()
        #expect(pane.selectedRange().location == 30, "the remembered place")
        window.contentViewController = nil

        let (box2, host2, window2, pane2) = try #require(
            mountFlipHost(text: Self.sixtyCharacterTake, landing: .end))
        box2.live = true
        pump()
        host2.view.layoutSubtreeIfNeeded()
        pump()
        #expect(pane2.selectedRange().location == (pane2.string as NSString).length,
                ".end is the END")
        window2.contentViewController = nil
    }

    /// The ladder's round 2, R2-4: the entry rule is ONE pure function both
    /// models call (`PaneCaretLanding.entering`) — the rule QUESTIONS #97
    /// asks her to ratify, in one place with a pin on it.
    @Test func theEntryRuleIsOnePureFunctionForBothModels() {
        #expect(PaneCaretLanding.entering(nil, block: "b1") == nil, "no fact ⇒ the models hand `.leave`")
        let other = FocusedBlock(postID: "p", blockID: "b2", variantID: "v", utf16Offset: 7)
        #expect(PaneCaretLanding.entering(other, block: "b1") == nil, "another block ⇒ `.leave`")
        let known = FocusedBlock(postID: "p", blockID: "b1", variantID: "v", utf16Offset: 7)
        #expect(PaneCaretLanding.entering(known, block: "b1") == .offset(7), "the remembered place")
        let unknown = FocusedBlock(postID: "p", blockID: "b1", variantID: "v", utf16Offset: nil)
        #expect(PaneCaretLanding.entering(unknown, block: "b1") == .start, "#97's PROVISIONAL default")
        let zero = FocusedBlock(postID: "p", blockID: "b1", variantID: "v", utf16Offset: 0)
        #expect(PaneCaretLanding.entering(zero, block: "b1") == .offset(0), "zero is a place, not unknown")
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
        // 18l-b U3 (SANCTIONED EDIT — this line pinned the synchronous state
        // write as the working path; her ratified shape moves it to the turn,
        // the frame lever answering synchronously instead).
        #expect(heights.isEmpty, "no height STATE write before the turn (the ratified shape)")
        #expect(canaries.count == 2, "each canary fire writes synchronously")
        #expect(scheduler.pending == 1, "three publishes, ONE deferred turn")

        scheduler.drainOneTurn()
        #expect(publisher.deferredTurns == 1)
        #expect(canaries.count == 3, "exactly one coalesced canary echo")
        #expect(heights == [46], "the state lands on the one deferred turn; converged, so it stops")
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
        // 18l-b U3 (SANCTIONED EDIT — the count pinned "one sync write";
        // the ratified shape writes the state on the turns only).
        #expect(heights.count == PanePublisher.healTurnBudget,
                "one state write per healed turn, none synchronous")
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
        // 18l-b U3 (SANCTIONED EDIT — `[46, 46]` counted the synchronous
        // state write before the turn's; the ratified shape has the turn's
        // alone).
        #expect(heights == [46])
    }

    /// The hole the door exists for: a state write that does not TAKE is
    /// re-made on a later turn, so the pane ends framed at its measured
    /// height.
    ///
    /// **18l-b U3 (SANCTIONED EDIT — this pin's name and text pinned a
    /// SYNCHRONOUS write, dropped as SwiftUI may drop one made during an
    /// update pass, re-made on the deferred turn).** Under the ratified shape
    /// there is no synchronous state write to drop; the write is the turn's,
    /// and the same convergence loop re-makes a turn's write that did not
    /// take on the turn after — the net this pin states, kept.
    @Test func aStateWriteThatDoesNotTakeIsRepublishedOnTheNextTurn() {
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
        #expect(landed == 0, "no state written before the turn")
        scheduler.drainOneTurn()
        #expect(landed == 0, "the turn's write was dropped — the bug's state")
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
        // 18l-b U3 (SANCTIONED EDIT — `[46]` was "the pre-invalidate sync
        // write"; the ratified shape makes none, so a pane torn down before
        // its turn writes no height state at all).
        #expect(heights.isEmpty, "no state write before the turn, and the torn-down turn writes none")
        #expect(canaries == ["fell back"], "no echo after teardown")
        #expect(scheduler.pending == 0)

        publisher.publishHeight()
        #expect(heights.isEmpty, "and nothing publishes afterwards")
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
