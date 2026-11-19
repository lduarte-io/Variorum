//
//  MobileDecorPlacementReadingTests.swift
//  VariorumMobileTests
//
//  VM-17's DECOR READING — ladder round 3's R3-F1 (the record is
//  `notes/plans/fixes/vm-78-fixes-to-whats-there.md`, BATCH D; the final
//  call, the "fair pin" list, is `notes/plans/fixes/vm-78-ladder-round3.md`,
//  "Final calls" → R3-F1). AN INSTRUMENT FOR A TICKET, written as a test
//  with expectations: it runs ALONE, BY TYPE, in batch D's green window, on
//  the tree WITH batch D's fix in —
//      -only-testing:VariorumMobileTests/MobileDecorPlacementReadingTests
//  — and it LEAVES THE TREE in a named commit after that window (it is no
//  standing guard: a red here starts the decor's own ticket, a green closes
//  R3-F1 hollow for the decor; either way the record says which).
//
//  Why it exists. The block decor (`Write/MobileBlockDecor.swift`: callout
//  washes and glyphs, comment marks) shares the rule window (3) proved wrong
//  for fan badges — each overlay placed from a FORCED read at its block's
//  own mid-document offset (`blockRectsUnion`, `firstLineGeometry`,
//  `lastLineEnd`), and an off-band overlay's frame left standing while
//  TextKit re-positions its fragment. Batch D changes the takes chrome only;
//  this reads whether the decor's overlays stand astray where she can see
//  them, on the probe's own note.
//
//  The note: `MobileFanBadgePlacementProbeTests`' note byte for byte (150
//  blocks of irregular length, every 7th fanned), plus a callout with a
//  glyph where `i % 5 == 2` and a comment where `i % 3 == 1`. TRUTH IS
//  TEXTKIT'S, never the decor's own helpers: fragments read UNFORCED
//  (`options: []`, a position only in `.layoutAvailable`) and
//  `textLayoutFragment(for:)` at points (it forces nothing); 1 pt; visible
//  rect = `view.bounds`; after the probe's settle; on the probe's stepped
//  walk and on the jump road (`jumpToBlock`) to every decorated block, far
//  to near, each road on a cold mount. Readings:
//    WASH  (i) every drawn wash meeting the visible rect: at three points
//              down its on-screen extent (its top + 5, its middle, its
//              bottom − 5, each clamped into the visible rect) at the
//              container's mid-width, the fragment TextKit reports begins
//              inside the wash's own block; where the wash's top edge is on
//              screen, top + 4 is within 1 pt of the block's first fragment.
//          (ii) every callout block with a laid-out fragment on screen is
//              covered there by its drawn wash.
//    GLYPH (i) a drawn glyph meeting the visible rect stands within 1 pt of
//              its block's laid-out first fragment; (ii) every glyph block
//              whose first line is laid out on screen has its glyph there.
//    MARK  (i) a drawn mark meeting the visible rect stands within 1 pt of
//              its block's LAST line's top (the last fragment, laid out),
//              and the fragment 1 pt under its top begins inside the block;
//              (ii) every commented block whose last line is laid out on
//              screen has its mark there.
//    REACH every decorated block met its (ii) premise at least once on the
//              walk, and every jump target was on screen — the reading's
//              own, never the decor's ("the reading did not reach…").
//    BADGE separately, with their own messages: the probe's badge readings
//              (i) and (ii) on THIS note — the decor's forced reads run
//              first in the same refresh door, so this is the one place the
//              badge fix meets them. A red THERE is batch D's (stop and
//              report), not the decor ticket's.
//  Lines `VM17D|` print every red and a SUMMARY for the record.
//

import Dependencies
import Foundation
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-17 / R3-F1 — the block decor on a long note, against TextKit (a reading; run alone by type; leaves after its window)", .serialized)
struct MobileDecorPlacementReadingTests {
    // MARK: The note (the probe's, byte for byte, plus the decor)

    nonisolated private static func paragraph(_ i: Int) -> String {
        let unit = "Steady words that wrap across the phone's narrow column. "
        let units = [1, 4, 9, 2, 16, 1, 6][i % 7]
        return "Block \(i): " + String(repeating: unit, count: units)
    }

    private static func seedDecoratedLongNote(
        _ session: AppSession
    ) async throws -> (postID: String, fanned: [String], callouts: [String], commented: [String]) {
        try await session.runner.run { ops in
            let post = try ops.createPost(title: "long fanned", profile: .blog)
            var fanned: [String] = []
            var callouts: [String] = []
            var commented: [String] = []
            for i in 0..<150 {
                let made = try ops.newBlock(
                    in: post.id, text: paragraph(i), at: .end, registeringUndo: false)
                if i % 7 == 0 {
                    let take = try ops.branchVariant(made.block.id, from: made.variant.id)
                    try ops.autosave(take.id, text: "Another take of block \(i).", charDelta: 5)
                    fanned.append(made.block.id)
                }
                if i % 5 == 2 {
                    try ops.setBlockPresentation(
                        made.block.id, BlockPresentation(color: "sand", emoji: "🕯"))
                    callouts.append(made.block.id)
                }
                if i % 3 == 1 {
                    _ = try ops.addBlockComment(
                        to: made.block.id, text: "A working note on block \(i).")
                    commented.append(made.block.id)
                }
            }
            return (post.id, fanned, callouts, commented)
        }
    }

    // MARK: The probe's host and settle

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
        window.endEditing(true)
        window.isHidden = true
        window.rootViewController = nil
    }

    private static func settle(_ view: UIView, turns: Int = 6) async {
        for _ in 0..<turns {
            (view.window ?? view).layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(10))
            await Task.yield()
        }
    }

    // MARK: TextKit's truth (nothing here forces layout)

    /// One fragment of a block, read unforced: its frame in the text view's
    /// own (content) coordinates and whether TextKit has laid it out.
    private struct Fragment {
        let frame: CGRect
        let laidOut: Bool
        let lastLineTop: CGFloat?
    }

    /// A block's fragments, read UNFORCED from its start until a fragment
    /// begins at or after its end (one fragment, for a zero-length block).
    private static func fragments(_ view: MobileEditorTextView, of range: NSRange) -> [Fragment] {
        guard let tlm = view.textLayoutManager,
              let cm = tlm.textContentManager,
              let start = cm.location(tlm.documentRange.location, offsetBy: range.location),
              let end = cm.location(
                tlm.documentRange.location, offsetBy: range.location + range.length)
        else { return [] }
        let inset = view.textContainerInset
        var result: [Fragment] = []
        tlm.enumerateTextLayoutFragments(from: start, options: []) { fragment in
            if range.length > 0,
               fragment.rangeInElement.location.compare(end) != .orderedAscending {
                return false
            }
            let frame = fragment.layoutFragmentFrame.offsetBy(dx: inset.left, dy: inset.top)
            let lastLineTop = fragment.textLineFragments.last.map {
                frame.minY + $0.typographicBounds.minY
            }
            result.append(Fragment(
                frame: frame, laidOut: fragment.state == .layoutAvailable,
                lastLineTop: lastLineTop))
            return range.length > 0
        }
        return result
    }

    /// The surface offset at which the fragment standing at a CONTENT point
    /// begins (`textLayoutFragment(for:)`, the swipe hit-test's call; it
    /// forces nothing), or nil when no fragment stands there.
    private static func fragmentStart(_ view: MobileEditorTextView, atContentY y: CGFloat) -> Int? {
        guard let tlm = view.textLayoutManager,
              let cm = tlm.textContentManager
        else { return nil }
        let point = CGPoint(
            x: view.textContainer.size.width / 2, y: y - view.textContainerInset.top)
        guard let fragment = tlm.textLayoutFragment(for: point) else { return nil }
        return cm.offset(from: tlm.documentRange.location, to: fragment.rangeInElement.location)
    }

    private static func begins(_ start: Int?, inside range: NSRange) -> Bool {
        guard let start else { return false }
        if range.length == 0 { return start == range.location }
        return start >= range.location && start < range.location + range.length
    }

    private static func isDrawn(_ overlay: UIView?, in view: MobileEditorTextView) -> Bool {
        guard let overlay else { return false }
        return overlay.superview === view && !overlay.isHidden && overlay.alpha > 0.01
    }

    // MARK: One stop's readings

    private struct Decorated {
        let blockID: String
        let range: NSRange
    }

    private struct Check {
        var washAstray: [String] = []
        var washBare: [String] = []
        var glyphAstray: [String] = []
        var glyphBare: [String] = []
        var markAstray: [String] = []
        var markBare: [String] = []
        var badgeAstray: [String] = []
        var badgeBare: [String] = []
        var washReached: Set<String> = []
        var glyphReached: Set<String> = []
        var markReached: Set<String> = []
        var onScreen: Set<String> = []
        var washesInView = 0
        var glyphsInView = 0
        var marksInView = 0
    }

    private static func check(
        _ view: MobileEditorTextView,
        decor: MobileBlockDecorController, chrome: MobileTakesChromeController,
        callouts: [Decorated], commented: [Decorated], fans: [Decorated], stop: String
    ) -> Check {
        var check = Check()
        let visible = view.bounds
        let tolerance: CGFloat = 1
        func clamp(_ y: CGFloat) -> CGFloat { min(max(y, visible.minY), visible.maxY - 0.5) }
        func onScreen(_ y: CGFloat) -> Bool { y >= visible.minY && y < visible.maxY }

        for block in callouts {
            let frags = fragments(view, of: block.range)
            let first = frags.first
            if let first, first.laidOut, onScreen(first.frame.minY) { check.onScreen.insert(block.blockID) }

            // WASH (i)
            let wash = decor.frameView(for: block.blockID)
            if isDrawn(wash, in: view), let wash, wash.frame.intersects(visible) {
                check.washesInView += 1
                let probes = [
                    ("top+5", wash.frame.minY + 5),
                    ("middle", wash.frame.midY),
                    ("bottom-5", wash.frame.maxY - 5),
                ]
                for (name, y) in probes {
                    let at = clamp(y)
                    let start = fragmentStart(view, atContentY: at)
                    if !begins(start, inside: block.range) {
                        check.washAstray.append(
                            "\(stop) @\(block.range.location) wash \(name) y=\(at) "
                                + (start.map { "stands beside the fragment at @\($0)" } ?? "over no fragment"))
                    }
                }
                if onScreen(wash.frame.minY) {
                    let edgeOK = first.map { $0.laidOut && abs(wash.frame.minY + 4 - $0.frame.minY) <= tolerance } ?? false
                    if !edgeOK {
                        check.washAstray.append(
                            "\(stop) @\(block.range.location) wash top+4=\(wash.frame.minY + 4) first fragment=\(first.map { "\($0.frame.minY)" } ?? "none") laidOut=\(first?.laidOut ?? false)")
                    }
                }
            }
            // WASH (ii)
            for fragment in frags where fragment.laidOut && fragment.frame.intersects(visible) {
                check.washReached.insert(block.blockID)
                let part = fragment.frame.intersection(visible)
                let covered = isDrawn(wash, in: view) && wash.map {
                    $0.frame.minY <= part.minY + tolerance && $0.frame.maxY >= part.maxY - tolerance
                } == true
                if !covered {
                    check.washBare.append(
                        "\(stop) @\(block.range.location) fragment \(part.minY)..\(part.maxY) wash=\(wash.map { "\($0.frame.minY)..\($0.frame.maxY)" } ?? "none") drawn=\(isDrawn(wash, in: view))")
                }
            }

            // GLYPH (i) and (ii)
            let glyph = decor.emojiLabel(for: block.blockID)
            if isDrawn(glyph, in: view), let glyph, glyph.frame.intersects(visible) {
                check.glyphsInView += 1
                let onLine = first.map { $0.laidOut && abs(glyph.frame.minY - $0.frame.minY) <= tolerance } ?? false
                if !onLine {
                    check.glyphAstray.append(
                        "\(stop) @\(block.range.location) glyph=\(glyph.frame.minY) first fragment=\(first.map { "\($0.frame.minY)" } ?? "none") laidOut=\(first?.laidOut ?? false)")
                }
            }
            if let first, first.laidOut, onScreen(first.frame.minY) {
                check.glyphReached.insert(block.blockID)
                let there = isDrawn(glyph, in: view) && glyph.map { abs($0.frame.minY - first.frame.minY) <= tolerance } == true
                if !there {
                    check.glyphBare.append(
                        "\(stop) @\(block.range.location) line=\(first.frame.minY) glyph=\(glyph.map { "\($0.frame.minY)" } ?? "none") drawn=\(isDrawn(glyph, in: view))")
                }
            }
        }

        for block in commented {
            let last = fragments(view, of: block.range).last
            let lastTop = last.flatMap { $0.laidOut ? $0.lastLineTop : nil }
            // MARK (i)
            let mark = decor.commentMark(for: block.blockID)
            if isDrawn(mark, in: view), let mark, mark.frame.intersects(visible) {
                check.marksInView += 1
                let onLine = lastTop.map { abs(mark.frame.minY - $0) <= tolerance } ?? false
                if !onLine {
                    check.markAstray.append(
                        "\(stop) @\(block.range.location) mark=\(mark.frame.minY) last line=\(lastTop.map { "\($0)" } ?? "none")")
                }
                let at = mark.frame.minY + 1
                if onScreen(at) {
                    let start = fragmentStart(view, atContentY: at)
                    if !begins(start, inside: block.range) {
                        check.markAstray.append(
                            "\(stop) @\(block.range.location) mark=\(mark.frame.minY) "
                                + (start.map { "stands beside the fragment at @\($0)" } ?? "over no fragment"))
                    }
                }
            }
            // MARK (ii)
            if let lastTop, onScreen(lastTop) {
                check.markReached.insert(block.blockID)
                let there = isDrawn(mark, in: view) && mark.map { abs($0.frame.minY - lastTop) <= tolerance } == true
                if !there {
                    check.markBare.append(
                        "\(stop) @\(block.range.location) last line=\(lastTop) mark=\(mark.map { "\($0.frame.minY)" } ?? "none") drawn=\(isDrawn(mark, in: view))")
                }
            }
            if let first = fragments(view, of: block.range).first, first.laidOut, onScreen(first.frame.minY) {
                check.onScreen.insert(block.blockID)
            }
        }

        // BADGE — the probe's readings (i) and (ii), on this note.
        for fan in fans {
            let first = fragments(view, of: NSRange(location: fan.range.location, length: 0)).first
            let badge = chrome.badgeView(for: fan.blockID)
            if isDrawn(badge, in: view), let badge, badge.frame.intersects(visible) {
                let onLine = first.map { $0.laidOut && abs(badge.frame.minY - $0.frame.minY) <= tolerance } ?? false
                if !onLine {
                    check.badgeAstray.append(
                        "\(stop) @\(fan.range.location) badge=\(badge.frame.minY) line=\(first.map { "\($0.frame.minY)" } ?? "none") laidOut=\(first?.laidOut ?? false)")
                }
            }
            if let first, first.laidOut, onScreen(first.frame.minY) {
                let badged = isDrawn(badge, in: view) && badge.map { abs($0.frame.minY - first.frame.minY) <= tolerance } == true
                if !badged {
                    check.badgeBare.append(
                        "\(stop) @\(fan.range.location) line=\(first.frame.minY) badge=\(badge.map { "\($0.frame.minY)" } ?? "none") drawn=\(isDrawn(badge, in: view))")
                }
            }
        }
        return check
    }

    private static func listed(_ items: [String]) -> String {
        items.count <= 8 ? "\(items)" : "\(Array(items.prefix(8))) … and \(items.count - 8) more"
    }

    // MARK: The reading

    @Test func theDecorStandsOnItsOwnBlocksInTheViewportOnALongNote() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await Self.seedDecoratedLongNote(session)
            #expect(seed.fanned.count >= 20, "non-vacuity: many fanned blocks (the probe's note)")
            #expect(seed.callouts.count >= 20, "non-vacuity: many callouts with a glyph")
            #expect(seed.commented.count >= 40, "non-vacuity: many commented blocks")
            var total = Check()
            var stops = 0
            var jumps = 0
            var jumpMissed: [String] = []
            var calloutBlocks: [Decorated] = []
            var commentedBlocks: [Decorated] = []
            var fanBlocks: [Decorated] = []

            func absorb(_ check: Check) {
                total.washAstray += check.washAstray
                total.washBare += check.washBare
                total.glyphAstray += check.glyphAstray
                total.glyphBare += check.glyphBare
                total.markAstray += check.markAstray
                total.markBare += check.markBare
                total.badgeAstray += check.badgeAstray
                total.badgeBare += check.badgeBare
                total.washesInView += check.washesInView
                total.glyphsInView += check.glyphsInView
                total.marksInView += check.marksInView
            }

            // ── Mount A (cold): the stepped walk.
            do {
                let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
                let window = Self.host(surface)
                defer { Self.unhost(window) }
                let view = surface.textView
                await Self.settle(view)
                let chrome = try #require(view.takesChrome, "takes chrome installed")
                let decor = try #require(view.blockDecor, "block decor installed")
                var ranges: [String: NSRange] = [:]
                for id in seed.callouts + seed.commented + seed.fanned {
                    let range = try #require(model.rangeOfBlock(id), "every decorated block has a range")
                    ranges[id] = range
                }
                func decorated(_ ids: [String]) -> [Decorated] {
                    ids.compactMap { id in ranges[id].map { Decorated(blockID: id, range: $0) } }
                }
                calloutBlocks = decorated(seed.callouts)
                commentedBlocks = decorated(seed.commented)
                fanBlocks = decorated(seed.fanned)
                #expect(view.contentSize.height > 6_000, "non-vacuity: the note dwarfs the viewport")

                var offset: CGFloat = 0
                while true {
                    view.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
                    await Self.settle(view, turns: 3)
                    let check = Self.check(
                        view, decor: decor, chrome: chrome, callouts: calloutBlocks,
                        commented: commentedBlocks, fans: fanBlocks, stop: "walk#\(stops)@\(Int(offset))")
                    absorb(check)
                    total.washReached.formUnion(check.washReached)
                    total.glyphReached.formUnion(check.glyphReached)
                    total.markReached.formUnion(check.markReached)
                    print("VM17D|walk|stop=\(stops) offset=\(Int(offset)) washes=\(check.washesInView) glyphs=\(check.glyphsInView) marks=\(check.marksInView) washAstray=\(check.washAstray.count) washBare=\(check.washBare.count) glyphAstray=\(check.glyphAstray.count) glyphBare=\(check.glyphBare.count) markAstray=\(check.markAstray.count) markBare=\(check.markBare.count) badgeAstray=\(check.badgeAstray.count) badgeBare=\(check.badgeBare.count)")
                    stops += 1
                    let end = max(0, view.contentSize.height + view.adjustedContentInset.bottom - view.bounds.height)
                    if offset >= end - 0.5 || stops >= 400 { break }
                    offset = min(offset + 0.8 * view.bounds.height, end)
                }
                #expect(model.identityAuditFailures == 0)
                #expect(!view.canaryFired)
            }

            // ── Mount B (cold): the jump road to every decorated block, far to near.
            do {
                let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
                let window = Self.host(surface)
                defer { Self.unhost(window) }
                let view = surface.textView
                await Self.settle(view)
                let chrome = try #require(view.takesChrome, "takes chrome installed")
                let decor = try #require(view.blockDecor, "block decor installed")
                let targets = (calloutBlocks + commentedBlocks)
                    .reduce(into: [Decorated]()) { list, block in
                        if !list.contains(where: { $0.blockID == block.blockID }) { list.append(block) }
                    }
                    .sorted { $0.range.location > $1.range.location }
                for target in targets {
                    jumps += 1
                    model.jumpToBlock(target.blockID)
                    await Self.settle(view, turns: 3)
                    let check = Self.check(
                        view, decor: decor, chrome: chrome, callouts: calloutBlocks,
                        commented: commentedBlocks, fans: fanBlocks, stop: "jump@\(target.range.location)")
                    absorb(check)
                    if !check.onScreen.contains(target.blockID) {
                        jumpMissed.append(
                            "@\(target.range.location) visible=\(Int(view.bounds.minY))..<\(Int(view.bounds.maxY))")
                    }
                    print("VM17D|jump|target=@\(target.range.location) offset=\(Int(view.contentOffset.y)) washAstray=\(check.washAstray.count) washBare=\(check.washBare.count) glyphAstray=\(check.glyphAstray.count) glyphBare=\(check.glyphBare.count) markAstray=\(check.markAstray.count) markBare=\(check.markBare.count) badgeAstray=\(check.badgeAstray.count) badgeBare=\(check.badgeBare.count) onScreen=\(check.onScreen.contains(target.blockID))")
                }
                #expect(model.identityAuditFailures == 0)
                #expect(!view.canaryFired)
            }

            for line in total.washAstray { print("VM17D|wash|(i) \(line)") }
            for line in total.washBare { print("VM17D|wash|(ii) \(line)") }
            for line in total.glyphAstray { print("VM17D|glyph|(i) \(line)") }
            for line in total.glyphBare { print("VM17D|glyph|(ii) \(line)") }
            for line in total.markAstray { print("VM17D|mark|(i) \(line)") }
            for line in total.markBare { print("VM17D|mark|(ii) \(line)") }
            for line in total.badgeAstray { print("VM17D|badge|(i) \(line)") }
            for line in total.badgeBare { print("VM17D|badge|(ii) \(line)") }

            // THE DECOR — the decor ticket's (R3-F1): red starts that ticket
            // with this red on file; green closes R3-F1 hollow for the decor.
            #expect(total.washAstray.isEmpty,
                    "DECOR (R3-F1, the decor ticket's): a drawn callout wash in the viewport stands off its own block — \(Self.listed(total.washAstray))")
            #expect(total.washBare.isEmpty,
                    "DECOR (R3-F1, the decor ticket's): a callout block's text on screen is not covered by its wash — \(Self.listed(total.washBare))")
            #expect(total.glyphAstray.isEmpty,
                    "DECOR (R3-F1, the decor ticket's): a drawn callout glyph in the viewport stands off its block's first line — \(Self.listed(total.glyphAstray))")
            #expect(total.glyphBare.isEmpty,
                    "DECOR (R3-F1, the decor ticket's): a callout block's first line on screen has no glyph on it — \(Self.listed(total.glyphBare))")
            #expect(total.markAstray.isEmpty,
                    "DECOR (R3-F1, the decor ticket's): a drawn comment mark in the viewport stands off its block's last line — \(Self.listed(total.markAstray))")
            #expect(total.markBare.isEmpty,
                    "DECOR (R3-F1, the decor ticket's): a commented block's last line on screen has no mark on it — \(Self.listed(total.markBare))")

            // REACH — the reading's own, never the decor's.
            let washUnreached = calloutBlocks.filter { !total.washReached.contains($0.blockID) }.map(\.range.location)
            let glyphUnreached = calloutBlocks.filter { !total.glyphReached.contains($0.blockID) }.map(\.range.location)
            let markUnreached = commentedBlocks.filter { !total.markReached.contains($0.blockID) }.map(\.range.location)
            #expect(washUnreached.isEmpty,
                    "the reading did not reach these callout blocks' text on its walk (a red here is the reading's own, never the decor's) — \(washUnreached)")
            #expect(glyphUnreached.isEmpty,
                    "the reading did not reach these callout blocks' first lines on its walk (a red here is the reading's own, never the decor's) — \(glyphUnreached)")
            #expect(markUnreached.isEmpty,
                    "the reading did not reach these commented blocks' last lines on its walk (a red here is the reading's own, never the decor's) — \(markUnreached)")
            #expect(jumpMissed.isEmpty,
                    "the reading did not reach these jump targets on screen (a red here is the reading's own, never the decor's) — \(Self.listed(jumpMissed))")

            // THE BADGE — batch D's, on this note: a red here is the badge
            // fix meeting the decor's forced reads — stop and report.
            #expect(total.badgeAstray.isEmpty,
                    "BADGE (batch D's — stop and report, not the decor ticket's): a drawn badge in the viewport stands off its own block on the decorated note — \(Self.listed(total.badgeAstray))")
            #expect(total.badgeBare.isEmpty,
                    "BADGE (batch D's — stop and report, not the decor ticket's): a fanned block on screen has no badge on its first line on the decorated note — \(Self.listed(total.badgeBare))")

            print("VM17D|SUMMARY stops=\(stops) jumps=\(jumps) callouts=\(calloutBlocks.count) commented=\(commentedBlocks.count) fans=\(fanBlocks.count) inView(washes=\(total.washesInView) glyphs=\(total.glyphsInView) marks=\(total.marksInView)) washAstray=\(total.washAstray.count) washBare=\(total.washBare.count) glyphAstray=\(total.glyphAstray.count) glyphBare=\(total.glyphBare.count) markAstray=\(total.markAstray.count) markBare=\(total.markBare.count) badgeAstray=\(total.badgeAstray.count) badgeBare=\(total.badgeBare.count) reach(wash=\(calloutBlocks.count - washUnreached.count)/\(calloutBlocks.count) glyph=\(calloutBlocks.count - glyphUnreached.count)/\(calloutBlocks.count) mark=\(commentedBlocks.count - markUnreached.count)/\(commentedBlocks.count)) jumpMissed=\(jumpMissed.count)")
        }
    }
}
