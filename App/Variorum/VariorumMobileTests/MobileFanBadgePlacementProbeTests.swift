//
//  MobileFanBadgePlacementProbeTests.swift
//  VariorumMobileTests
//
//  VM-17 — do the phone's fan badges pile at block 1, or stray, on a long
//  fanned note? (VM-78 batch C; the record is `notes/plans/fixes/vm-78-fixes-
//  to-whats-there.md`, BATCH C — LIVE STATUS; the probe's shape is ladder
//  round 1's F2 final call, `notes/plans/fixes/vm-78-ladder-round1.md`.)
//
//  The Mac's VX-230: TextKit 2 reports a paragraph it has not laid out as a
//  `.zero` frame, and a badge placed from that frame sat at the first block
//  (TEXTKIT2 §3, VX-246 U4). The phone's badge reads its y from
//  `MobileEditorTextView.firstLineGeometry`, which FORCES `.ensuresLayout`
//  from the block's own mid-document offset (`MobileTakesChrome.swift:211`),
//  so a `.zero` frame cannot arise. What TEXTKIT2 §3 (measured on macOS)
//  says can: a layout forced mid-document places fragments at ESTIMATED
//  offsets until a viewport pass re-positions them, while an off-band
//  block's badge keeps its last resolved frame (`MobileTakesChrome.swift:
//  206-209`) — so the defect she could SEE is a stray badge in the viewport,
//  beside text that is not its block.
//
//  On a long note (150 blocks of irregular length, every 7th fanned):
//  1. THE PILE — an expectation (the guard this member keeps): at load no two
//     badges coincide and no badge but the first block's stands at block 1.
//  2. A MEASUREMENT, printed, never asserted: how far the badges drawn at
//     load for blocks below the fold stand from an IDEALIZED layout (an
//     independent bare TextKit 2 stack over a copy of the attributed text,
//     laid out whole from the start). The live surface never promised that
//     layout for text she cannot see, so a distance here is TextKit's
//     estimate, not a defect; the numbers are VM-179's (wave 4).
//  3. THE VIEWPORT INVARIANT — expectations, at every stop of two roads on a
//     COLD mount each: a stepped walk down the live surface (unanimated
//     offsets of 0.8 of a viewport, a settle after each, the maximum offset
//     re-read live at every step, ending at the live end), and the product's
//     own jump road (`MobileEditorViewModel.jumpToBlock`, the block list's
//     tap) to each fanned block, far to near. Visible rect = `view.bounds`;
//     every fragment read UNFORCED (`options: []`):
//     (i)  every DRAWN badge whose frame meets the visible rect belongs to a
//          block whose first-line fragment is `.layoutAvailable` and stands
//          within 1 pt of the badge's top — a failure is a stray or misplaced
//          badge she can see;
//     (i′) every such badge, asked independently of its own block's frame
//          (ladder round 2's R2-F3): the point 1 pt under the badge's top, at
//          the container's mid-width, must lie in a fragment that BEGINS at
//          the badge's own block offset (`textLayoutFragment(for:)`, the
//          product's own swipe hit-test call; nothing forces layout). A point
//          outside the visible rect is skipped and counted. A different
//          offset, or no fragment at all, is a miss — a badge standing beside
//          another block's text (or over none) that (i) cannot see when the
//          badge and its block's fragment share one stale forced layout;
//     (ii) every fanned block whose first-line fragment is `.layoutAvailable`
//          with its top inside the visible rect has a drawn badge within 1 pt
//          of it — a failure is a fan she can see with no badge on it;
//     (iii) REACH: every jump target meets (ii)'s premise at its stop, and
//          every fanned block meets it at least once across the walk, and on
//          each road (i′) asked at least one badge. These say "the probe did
//          not reach…": a red there is the probe's, never VM-17's.
//  VM-17 IS REAL (window (3): (i), (i′), (ii) red, M5 = M5b) and this is its
//  PIN: red on the pre-fix chrome (the `:211`/`:206-209` cites above are that
//  chrome's), green on batch D's fix (round 3's called shape, S1–S11).
//  The cost note that rode beside it (VM-179's numbers) left with the trace
//  instruments; its numbers are in the record, its code in history
//  (`a570d3960`).
//

import Dependencies
import Foundation
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-17 — a long fanned note's badges: no pile, none astray in the viewport (probe)", .serialized)
struct MobileFanBadgePlacementProbeTests {
    /// Paragraph lengths that vary irregularly (one line to ~two dozen), so
    /// TextKit's estimate for an unlaid stretch is wrong in both directions.
    nonisolated private static func paragraph(_ i: Int) -> String {
        let unit = "Steady words that wrap across the phone's narrow column. "
        let units = [1, 4, 9, 2, 16, 1, 6][i % 7]
        return "Block \(i): " + String(repeating: unit, count: units)
    }

    /// A long note: `count` blocks, every `fanEvery`-th one fanned (block 0
    /// included, so the first block wears a badge too).
    private static func seedLongFannedNote(
        _ session: AppSession, count: Int, fanEvery: Int?
    ) async throws -> (postID: String, blocks: [String], fanned: [String]) {
        try await session.runner.run { ops in
            let post = try ops.createPost(title: "long fanned", profile: .blog)
            var blocks: [String] = []
            var fanned: [String] = []
            for i in 0..<count {
                let made = try ops.newBlock(
                    in: post.id, text: paragraph(i), at: .end, registeringUndo: false)
                blocks.append(made.block.id)
                if let fanEvery, i % fanEvery == 0 {
                    let take = try ops.branchVariant(made.block.id, from: made.variant.id)
                    try ops.autosave(take.id, text: "Another take of block \(i).", charDelta: 5)
                    fanned.append(made.block.id)
                }
            }
            return (post.id, blocks, fanned)
        }
    }

    /// A window on the scene (not key, no first responder): real layout
    /// passes, no keyboard.
    private static func host(_ surface: MobileWriteSurfaceView) -> UIWindow {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        let window = scene.map { UIWindow(windowScene: $0) }
            ?? UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
        window.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
        let controller = UIViewController()
        controller.view.addSubview(surface)
        window.rootViewController = controller
        window.isHidden = false
        return window
    }

    private static func unhost(_ window: UIWindow) {
        window.isHidden = true
        window.rootViewController = nil
    }

    /// Display passes AND main-queue hops (TEXTKIT2 §3's harness fact: a
    /// nested run loop alone runs no main-queue hop; an await does — and
    /// `RunLoop.run(until:)` is unavailable from async contexts on iOS).
    private static func settle(_ view: UIView, turns: Int = 6) async {
        for _ in 0..<turns {
            (view.window ?? view).layoutIfNeeded()
            // A main-actor sleep lets the run loop turn (display passes)
            // and the main queue drain (hops).
            try? await Task.sleep(for: .milliseconds(10))
            await Task.yield()
        }
    }

    /// Reading 2's yardstick: an independent bare TK2 stack over a COPY of
    /// the surface's attributed text, at the surface's container width, laid
    /// out whole from the start — each offset's first fragment minY
    /// (container coords). An idealized layout, never the live surface's.
    private static func idealMinY(
        of view: MobileEditorTextView, offsets: [Int]
    ) -> [Int: CGFloat] {
        let content = NSTextContentStorage()
        let layout = NSTextLayoutManager()
        content.addTextLayoutManager(layout)
        content.primaryTextLayoutManager = layout
        let container = NSTextContainer(
            size: CGSize(width: view.textContainer.size.width, height: 0))
        container.lineFragmentPadding = view.textContainer.lineFragmentPadding
        layout.textContainer = container
        let copy = NSAttributedString(attributedString: view.textStorage)
        content.performEditingTransaction {
            content.textStorage?.setAttributedString(copy)
        }
        layout.ensureLayout(for: layout.documentRange)
        var result: [Int: CGFloat] = [:]
        for offset in offsets {
            guard let location = content.location(
                layout.documentRange.location, offsetBy: offset) else { continue }
            layout.enumerateTextLayoutFragments(from: location, options: []) { fragment in
                result[offset] = fragment.layoutFragmentFrame.minY
                return false
            }
        }
        return result
    }

    /// The live surface's first-line fragment at an offset, read UNFORCED
    /// (`options: []`): its top in the text view's own (content) coordinates
    /// — the badge's frame space — and whether TextKit has laid it out.
    private static func unforcedFirstLine(
        _ view: MobileEditorTextView, at offset: Int
    ) -> (top: CGFloat, laidOut: Bool)? {
        guard let tlm = view.textLayoutManager,
              let cm = tlm.textContentManager,
              let location = cm.location(tlm.documentRange.location, offsetBy: offset)
        else { return nil }
        var result: (CGFloat, Bool)?
        tlm.enumerateTextLayoutFragments(from: location, options: []) { fragment in
            result = (
                view.textContainerInset.top + fragment.layoutFragmentFrame.minY,
                fragment.state == .layoutAvailable)
            return false
        }
        return result
    }

    /// One stop's reading of the viewport invariant.
    private struct ViewportCheck {
        /// (i) a drawn badge meeting the visible rect, off its laid-out line.
        var astray: [String] = []
        /// (ii) a laid-out fanned first line on screen with no badge on it.
        var bare: [String] = []
        /// The fanned blocks that met (ii)'s premise at this stop.
        var reached: Set<String> = []
        var badgesInView = 0
        /// (i′) a drawn badge whose point lies in another block's fragment,
        /// or in none.
        var misses: [String] = []
        /// (i′) badges asked, and badges skipped (their point off screen).
        var asked = 0
        var skipped = 0
    }

    /// (i′)'s question: the surface offset at which the fragment standing at
    /// a CONTAINER point begins, or nil when no fragment stands there.
    /// `textLayoutFragment(for:)` forces no layout.
    private static func fragmentStart(
        _ view: MobileEditorTextView, atContainerPoint point: CGPoint
    ) -> Int? {
        guard let tlm = view.textLayoutManager,
              let cm = tlm.textContentManager,
              let fragment = tlm.textLayoutFragment(for: point)
        else { return nil }
        return cm.offset(from: tlm.documentRange.location, to: fragment.rangeInElement.location)
    }

    private static func checkViewport(
        _ view: MobileEditorTextView, _ chrome: MobileTakesChromeController,
        fans: [(blockID: String, offset: Int)], stop: String
    ) -> ViewportCheck {
        var check = ViewportCheck()
        let visible = view.bounds
        let tolerance: CGFloat = 1
        for fan in fans {
            let line = unforcedFirstLine(view, at: fan.offset)
            let badge = chrome.badgeView(for: fan.blockID)
            let drawn = badge.map { $0.superview === view && !$0.isHidden && $0.alpha > 0.01 } ?? false
            let badgeTop = badge?.frame.minY
            // (i) — every drawn badge in the viewport stands on its own block.
            if drawn, let badge, badge.frame.intersects(visible) {
                check.badgesInView += 1
                let onLine = line.map { $0.laidOut && abs(badge.frame.minY - $0.top) <= tolerance } ?? false
                if !onLine {
                    check.astray.append(
                        "\(stop) @\(fan.offset) badge=\(badge.frame.minY) line=\(line.map { "\($0.top)" } ?? "none") laidOut=\(line?.laidOut ?? false)")
                }
                // (i′) — what stands AT the badge, asked without its own
                // block's frame: 1 pt under its top, at the container's
                // mid-width; a point off screen is skipped and counted.
                let pointY = badge.frame.minY + 1
                if pointY >= visible.minY, pointY < visible.maxY {
                    check.asked += 1
                    let point = CGPoint(
                        x: view.textContainer.size.width / 2,
                        y: pointY - view.textContainerInset.top)
                    if let standing = fragmentStart(view, atContainerPoint: point) {
                        if standing != fan.offset {
                            check.misses.append(
                                "(i′) \(stop) @\(fan.offset) badge=\(badge.frame.minY) stands beside the fragment at @\(standing)")
                        }
                    } else {
                        check.misses.append(
                            "(i′) \(stop) @\(fan.offset) badge=\(badge.frame.minY) no fragment at the badge's point")
                    }
                } else {
                    check.skipped += 1
                }
            }
            // (ii) — every laid-out fanned first line on screen has its badge.
            if let line, line.laidOut, line.top >= visible.minY, line.top < visible.maxY {
                check.reached.insert(fan.blockID)
                let badged = drawn && badgeTop.map { abs($0 - line.top) <= tolerance } ?? false
                if !badged {
                    check.bare.append(
                        "\(stop) @\(fan.offset) line=\(line.top) badge=\(badgeTop.map { "\($0)" } ?? "none") drawn=\(drawn)")
                }
            }
        }
        return check
    }

    private static func listed(_ items: [String]) -> String {
        items.count <= 8 ? "\(items)" : "\(Array(items.prefix(8))) … and \(items.count - 8) more"
    }

    @Test func noFanBadgePilesAndNoneStandsAstrayInTheViewportOnALongNote() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await Self.seedLongFannedNote(session, count: 150, fanEvery: 7)
            #expect(seed.fanned.count >= 20, "non-vacuity: many fanned blocks")
            var astray: [String] = []
            var bare: [String] = []
            var misses: [String] = []
            var walkAsked = 0
            var jumpAsked = 0
            var skipped = 0
            var walkReached: Set<String> = []
            var jumpMissed: [String] = []
            var fans: [(blockID: String, offset: Int)] = []

            // ── Mount A (cold): the load's readings, then the stepped walk.
            do {
                let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
                let window = Self.host(surface)
                defer { Self.unhost(window) }
                let view = surface.textView
                await Self.settle(view)
                let chrome = try #require(view.takesChrome, "takes chrome installed")
                let inset = view.textContainerInset
                let offsets = try seed.fanned.map { try #require(model.rangeOfBlock($0)).location }
                fans = Array(zip(seed.fanned, offsets)).map { (blockID: $0.0, offset: $0.1) }
                #expect(view.contentSize.height > 6_000, "non-vacuity: the note dwarfs the viewport")

                // 1 — THE PILE (an expectation).
                let atLoad = fans.map { ($0, chrome.badgeView(for: $0.blockID)?.frame.minY) }
                let drawn = atLoad.compactMap { pair in pair.1.map { (fan: pair.0, y: $0) } }
                let firstY = drawn.first { $0.fan.offset == offsets[0] }?.y
                var coinciding: [String] = []
                for (i, a) in drawn.enumerated() {
                    for b in drawn[(i + 1)...] where abs(a.y - b.y) < 1 {
                        coinciding.append("@\(a.fan.offset)&@\(b.fan.offset) y=\(a.y)")
                    }
                }
                let atBlockOne = drawn.filter { pair in
                    pair.fan.offset != offsets[0] && firstY.map { abs(pair.y - $0) < 1 } == true
                }
                #expect(coinciding.isEmpty, "VM-17 pile: two badges coincide — \(coinciding)")
                #expect(atBlockOne.isEmpty,
                        "VM-17 pile: a later block's badge stands at block 1 — \(atBlockOne.map { $0.fan.offset })")

                // 2 — A MEASUREMENT (printed, never asserted).
                let ideal = Self.idealMinY(of: view, offsets: offsets)
                var distances: [CGFloat] = []
                var offscreenDrawn = 0
                for pair in drawn {
                    guard let idealTop = ideal[pair.fan.offset].map({ inset.top + $0 }) else { continue }
                    let distance = abs(pair.y - idealTop)
                    let offscreen = idealTop > view.bounds.height
                    if offscreen { offscreenDrawn += 1 }
                    if offscreen, distance > 1 { distances.append(distance) }
                    print("VM17|load|@\(pair.fan.offset) badge=\(pair.y) ideal=\(idealTop) distance=\(distance) offscreen=\(offscreen)")
                }
                let mean = distances.isEmpty ? 0 : distances.reduce(0, +) / CGFloat(distances.count)
                print("VM17|reading2|offscreenDrawn=\(offscreenDrawn) offIdeal=\(distances.count) largest=\(distances.max() ?? 0) mean=\(mean) (TextKit's estimate — a measurement for VM-179, never a verdict)")

                // 3, road one — the stepped walk down the live surface.
                var offset: CGFloat = 0
                var stop = 0
                while true {
                    view.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
                    await Self.settle(view, turns: 3)
                    let check = Self.checkViewport(view, chrome, fans: fans, stop: "walk#\(stop)@\(Int(offset))")
                    astray += check.astray
                    bare += check.bare
                    misses += check.misses
                    walkAsked += check.asked
                    skipped += check.skipped
                    walkReached.formUnion(check.reached)
                    print("VM17|walk|stop=\(stop) offset=\(Int(offset)) badgesInView=\(check.badgesInView) fansOnScreen=\(check.reached.count) astray=\(check.astray.count) bare=\(check.bare.count) asked=\(check.asked) skipped=\(check.skipped) misses=\(check.misses.count)")
                    stop += 1
                    // The end, re-read LIVE at every step (TK2's estimate moves it).
                    let end = max(0, view.contentSize.height + view.adjustedContentInset.bottom - view.bounds.height)
                    if offset >= end - 0.5 || stop >= 400 { break }
                    offset = min(offset + 0.8 * view.bounds.height, end)
                }
                print("VM17|walk|END stops=\(stop) finalOffset=\(Int(offset)) contentHeight=\(Int(view.contentSize.height)) reached=\(walkReached.count)/\(fans.count)")
                #expect(model.identityAuditFailures == 0)
                #expect(!view.canaryFired)
            }

            // ── Mount B (cold): the product's jump road, far to near.
            do {
                let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
                let window = Self.host(surface)
                defer { Self.unhost(window) }
                let view = surface.textView
                await Self.settle(view)
                let chrome = try #require(view.takesChrome, "takes chrome installed")
                for fan in fans.reversed() {
                    model.jumpToBlock(fan.blockID)
                    await Self.settle(view, turns: 3)
                    let check = Self.checkViewport(view, chrome, fans: fans, stop: "jump@\(fan.offset)")
                    astray += check.astray
                    bare += check.bare
                    misses += check.misses
                    jumpAsked += check.asked
                    skipped += check.skipped
                    if !check.reached.contains(fan.blockID) {
                        let line = Self.unforcedFirstLine(view, at: fan.offset)
                        jumpMissed.append("@\(fan.offset) line=\(line.map { "\($0.top)" } ?? "none") laidOut=\(line?.laidOut ?? false) visible=\(Int(view.bounds.minY))..<\(Int(view.bounds.maxY))")
                    }
                    print("VM17|jump|target=@\(fan.offset) offset=\(Int(view.contentOffset.y)) badgesInView=\(check.badgesInView) fansOnScreen=\(check.reached.count) astray=\(check.astray.count) bare=\(check.bare.count) asked=\(check.asked) skipped=\(check.skipped) misses=\(check.misses.count) reachedTarget=\(check.reached.contains(fan.blockID))")
                }
                #expect(model.identityAuditFailures == 0)
                #expect(!view.canaryFired)
            }

            // (i), (i′) and (ii) — VM-17's verdict.
            for line in astray { print("VM17|astray|\(line)") }
            for line in misses { print("VM17|astray|\(line)") }
            for line in bare { print("VM17|bare|\(line)") }
            #expect(astray.isEmpty,
                    "VM-17: a drawn badge in the viewport stands off its own block (a stray or misplaced badge she can see) — \(Self.listed(astray))")
            #expect(misses.isEmpty,
                    "VM-17 (i′): a drawn badge in the viewport stands beside another block's text, or over none — \(Self.listed(misses))")
            #expect(bare.isEmpty,
                    "VM-17: a fanned block on screen has no badge on its first line — \(Self.listed(bare))")
            // (iii) — REACH: the probe's own non-vacuity, never VM-17's.
            let walkUnreached = fans.filter { !walkReached.contains($0.blockID) }.map { $0.offset }
            #expect(walkUnreached.isEmpty,
                    "the probe did not reach these fanned blocks on its stepped walk (a red here is the probe's, never VM-17's) — \(walkUnreached)")
            #expect(jumpMissed.isEmpty,
                    "the probe did not reach these jump targets on screen (a red here is the probe's, never VM-17's) — \(Self.listed(jumpMissed))")
            #expect(walkAsked > 0,
                    "the probe did not reach: (i′) asked no badge on the stepped walk (a red here is the probe's, never VM-17's)")
            #expect(jumpAsked > 0,
                    "the probe did not reach: (i′) asked no badge on the jump road (a red here is the probe's, never VM-17's)")
            print("VM17|SUMMARY fans=\(fans.count) astray=\(astray.count) bare=\(bare.count) misses=\(misses.count) asked=\(walkAsked + jumpAsked) (walk \(walkAsked), jump \(jumpAsked)) skipped=\(skipped) walkReached=\(walkReached.count) jumpMissed=\(jumpMissed.count)")
        }
    }
}
