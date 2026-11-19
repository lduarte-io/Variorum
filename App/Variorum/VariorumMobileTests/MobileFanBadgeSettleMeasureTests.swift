//
//  MobileFanBadgeSettleMeasureTests.swift
//  VariorumMobileTests
//
//  VM-17 — AN INSTRUMENT, NOT A PIN (VM-78 batch D; the record is
//  `notes/plans/fixes/vm-78-fixes-to-whats-there.md`, BATCH D — LIVE STATUS).
//  It asserts NOTHING about the product: its only checks are `#require`s that
//  its own setup worked. It prints `VM17M|` lines, and it leaves the tree in a
//  named commit once its numbers are in the record.
//
//  RUN IT ALONE, BY TYPE:
//      -only-testing:VariorumMobileTests/MobileFanBadgeSettleMeasureTests
//  (never beside another suite: it reads timing-sensitive layout state).
//
//  What it measures. Window (3) showed the tick's badge for a fanned block
//  that has just scrolled into view standing exactly 74 pt above the line
//  TextKit settles it on: the chrome's `.nearViewport` tick resolves the
//  badge with a FORCED read (`firstLineGeometry`, `.ensuresLayout`) and
//  TextKit re-positions the fragment after that read. The fix shape for that
//  symptom turns on WHEN TextKit has re-positioned it — so on the probe's own
//  note and stepped walk, for every fanned block in the chrome's band at
//  every stop, it prints the badge (drawn top, exactly as the probe reads
//  it) and the block's first-line fragment read UNFORCED (`options: []`: its
//  top, and whether it is `.layoutAvailable`) at each of these moments, in
//  this order (each one cumulative on the one before):
//    pass       inside the stop's layout pass, right after the text view's
//               own `layoutSubviews` (so right after the chrome's tick): a
//               zero-size TEST view at subview index 0 records from its own
//               `layoutSubviews`, which UIKit runs after its superview's in
//               the same recursion — the nearest reachable point without a
//               product hook. `fired=0` on a line means it did not run.
//    afterPass  when that layout pass (`window.layoutIfNeeded()`) returns.
//    hop        after ONE main-queue hop: one `DispatchQueue.main.async`
//               block resuming a `CheckedContinuation` (the test's own
//               resumption is then one main-actor job after it).
//    relayout   after `setNeedsLayout()` + `layoutIfNeeded()` on the text
//               view — the chrome's own tick runs again (its forced reads).
//    flush      after `CATransaction.flush()`.
//    link       after one `CADisplayLink` callback (public API; a 0.5 s
//               fallback resumes it if none comes — `linkFired` counts).
//    settle     after the probe's own settle (three turns of window layout
//               + a 10 ms main-actor sleep + a yield) — THE TRUTH: the
//               unforced read here is what the probe compares a badge with.
//  Then a SECOND cold mount for option (c): at each stop, BEFORE the stop's
//  layout pass, one `NSTextLayoutManager.ensureLayout(for:)` run from the
//  TextKit viewport's start through the first character of the last fanned
//  block inside the band (the band as `nearViewportBand()` gives it then,
//  extended by one viewport length of characters to cover the step), so no
//  band fan is laid out ahead of its predecessors; then the pass, and the
//  chrome-resolved badge against that mount's settled truth.
//
//  Known limits, said plainly: both mounts carry today's load-time full pass
//  (every fan force-laid-out at load, ahead of its predecessors — the
//  confirmed shape would remove that; a test cannot, without a product
//  hook); and every moment after `relayout` carries the chrome's own forced
//  reads of that pass. Lines are printed at EVERY stop (a superset of "a
//  stop where a fan newly enters the band"), flagged `newBand` / `newVis`.
//  It plants no first responder (the window is shown, never made key) and
//  flips no global beyond the shared editor harness's own voice reset.
//

import Dependencies
import Foundation
import QuartzCore
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-17 — when does a band fan's fragment settle? (instrument; run alone by type)", .serialized)
struct MobileFanBadgeSettleMeasureTests {
    // The probe's fixture, copied byte for byte (its builder is private to
    // `MobileFanBadgePlacementProbeTests`), so the geometry is window (3)'s.
    nonisolated private static func paragraph(_ i: Int) -> String {
        let unit = "Steady words that wrap across the phone's narrow column. "
        let units = [1, 4, 9, 2, 16, 1, 6][i % 7]
        return "Block \(i): " + String(repeating: unit, count: units)
    }

    private static func seedLongFannedNote(
        _ session: AppSession, count: Int, fanEvery: Int
    ) async throws -> (postID: String, fanned: [String]) {
        try await session.runner.run { ops in
            let post = try ops.createPost(title: "long fanned", profile: .blog)
            var fanned: [String] = []
            for i in 0..<count {
                let made = try ops.newBlock(
                    in: post.id, text: paragraph(i), at: .end, registeringUndo: false)
                if i % fanEvery == 0 {
                    let take = try ops.branchVariant(made.block.id, from: made.variant.id)
                    try ops.autosave(take.id, text: "Another take of block \(i).", charDelta: 5)
                    fanned.append(made.block.id)
                }
            }
            return (post.id, fanned)
        }
    }

    /// The probe's host: a window on the scene, shown, never key.
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

    /// The probe's settle, unchanged.
    private static func settle(_ view: UIView, turns: Int = 6) async {
        for _ in 0..<turns {
            (view.window ?? view).layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(10))
            await Task.yield()
        }
    }

    private static func mainQueueHop() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            DispatchQueue.main.async { continuation.resume() }
        }
    }

    /// The probe's yardstick, for the `ideal=` column only: a bare TK2 stack
    /// over a copy of the text, laid out whole from the start.
    private static func idealTop(
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
                result[offset] = view.textContainerInset.top + fragment.layoutFragmentFrame.minY
                return false
            }
        }
        return result
    }

    // MARK: Reads

    /// One fan at one moment: the drawn badge's top (nil = not drawn) and
    /// the first-line fragment read unforced (top in content coordinates;
    /// nil = no fragment), with its `.layoutAvailable` state.
    private struct Snapshot {
        var badge: CGFloat?
        var top: CGFloat?
        var laidOut: Bool
    }

    private struct Fan {
        let blockID: String
        let range: NSRange
    }

    private static func snapshot(
        _ view: MobileEditorTextView, _ chrome: MobileTakesChromeController, _ fan: Fan
    ) -> Snapshot {
        let badge = chrome.badgeView(for: fan.blockID)
        let drawn = badge.map { $0.superview === view && !$0.isHidden && $0.alpha > 0.01 } ?? false
        var snap = Snapshot(badge: drawn ? badge?.frame.minY : nil, top: nil, laidOut: false)
        if let tlm = view.textLayoutManager, let cm = tlm.textContentManager,
           let location = cm.location(tlm.documentRange.location, offsetBy: fan.range.location) {
            tlm.enumerateTextLayoutFragments(from: location, options: []) { fragment in
                snap.top = view.textContainerInset.top + fragment.layoutFragmentFrame.minY
                snap.laidOut = fragment.state == .layoutAvailable
                return false
            }
        }
        return snap
    }

    private static func snapshotAll(
        _ view: MobileEditorTextView, _ chrome: MobileTakesChromeController, _ fans: [Fan]
    ) -> [Snapshot] {
        fans.map { snapshot(view, chrome, $0) }
    }

    /// The chrome's own band rule (`MobileTakesChromeController.refresh`'s
    /// `near`), over `nearViewportBand()`; nil band = everything near.
    private static func inBand(_ range: NSRange, _ band: NSRange?) -> Bool {
        guard let band else { return true }
        return range.location < band.location + band.length
            && band.location < range.location + max(range.length, 1)
    }

    private static func fmt(_ value: CGFloat?) -> String {
        value.map { String(format: "%.2f", Double($0)) } ?? "-"
    }

    private static func cell(_ snap: Snapshot) -> String {
        "b:\(fmt(snap.badge)),t:\(fmt(snap.top)),\(snap.laidOut ? "L" : "E")"
    }

    // MARK: Tallies

    private struct Tally {
        var agree = 0
        var disagree = 0
        var missing = 0
        var largest: CGFloat = 0

        mutating func add(_ value: CGFloat?, usable: Bool, truth: CGFloat) {
            guard usable, let value else { missing += 1; return }
            let distance = abs(value - truth)
            if distance <= 1 {
                agree += 1
            } else {
                disagree += 1
                largest = max(largest, distance)
            }
        }

        var text: String {
            "agree=\(agree) disagree=\(disagree) missing=\(missing) largest=\(String(format: "%.2f", Double(largest)))"
        }
    }

    /// One band fan's row at one stop: its moments, its truth, its flags.
    private struct Row {
        let newVisible: Bool
        let moments: [String: Snapshot]
        let truth: Snapshot
    }

    private static func summarize(
        _ rows: [Row], mount: String, moments: [String]
    ) {
        let usable = rows.filter { $0.truth.laidOut && $0.truth.top != nil }
        print("VM17M|SUMMARY mount=\(mount) bandFanReads=\(rows.count) withTruth=\(usable.count) newVisible=\(usable.filter(\.newVisible).count)")
        for moment in moments {
            var unforcedAll = Tally(), unforcedNew = Tally()
            var badgeAll = Tally(), badgeNew = Tally()
            for row in usable {
                guard let snap = row.moments[moment], let truth = row.truth.top else { continue }
                unforcedAll.add(snap.top, usable: snap.laidOut, truth: truth)
                badgeAll.add(snap.badge, usable: true, truth: truth)
                if row.newVisible {
                    unforcedNew.add(snap.top, usable: snap.laidOut, truth: truth)
                    badgeNew.add(snap.badge, usable: true, truth: truth)
                }
            }
            print("VM17M|SUMMARY mount=\(mount) moment=\(moment) read=unforced all(\(unforcedAll.text)) newVisible(\(unforcedNew.text))")
            print("VM17M|SUMMARY mount=\(mount) moment=\(moment) read=badge all(\(badgeAll.text)) newVisible(\(badgeNew.text))")
        }
    }

    // MARK: The instrument

    @Test func whenDoesABandFansFragmentSettleOnTheSteppedWalk() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await Self.seedLongFannedNote(session, count: 150, fanEvery: 7)
            try #require(seed.fanned.count >= 20, "setup: many fanned blocks")

            // ── Mount 1 (cold): the moments, on the probe's stepped walk.
            var ideal: [Int: CGFloat] = [:]
            var fans: [Fan] = []
            do {
                let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
                let window = Self.host(surface)
                defer { Self.unhost(window) }
                let view = surface.textView
                await Self.settle(view)
                let chrome = try #require(view.takesChrome, "setup: the takes chrome is installed")
                fans = try seed.fanned.map { id in
                    Fan(blockID: id, range: try #require(model.rangeOfBlock(id), "setup: every fan has a range"))
                }
                try #require(view.contentSize.height > 6_000, "setup: the note dwarfs the viewport")
                ideal = Self.idealTop(of: view, offsets: fans.map(\.range.location))

                let sentinel = PassSentinel(frame: .zero)
                sentinel.isUserInteractionEnabled = false
                sentinel.isAccessibilityElement = false
                view.insertSubview(sentinel, at: 0)
                defer { sentinel.removeFromSuperview() }
                let turn = DisplayTurn()

                let order = ["pass", "afterPass", "hop", "relayout", "flush", "link"]
                var rows: [Row] = []
                var lastBand: Set<Int> = []
                var lastVisible: Set<Int> = []
                var sentinelFired = 0
                var linkFired = 0
                var offset: CGFloat = 0
                var stop = 0
                while true {
                    var passSnaps: [Snapshot]?
                    var passBand: NSRange?
                    sentinel.onLayout = {
                        passBand = view.nearViewportBand()
                        passSnaps = Self.snapshotAll(view, chrome, fans)
                    }
                    sentinel.setNeedsLayout()
                    view.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
                    (view.window ?? view).layoutIfNeeded()
                    sentinel.onLayout = nil
                    if passSnaps != nil { sentinelFired += 1 }
                    let afterBand = view.nearViewportBand()
                    let afterPass = Self.snapshotAll(view, chrome, fans)
                    await Self.mainQueueHop()
                    let hop = Self.snapshotAll(view, chrome, fans)
                    view.setNeedsLayout()
                    view.layoutIfNeeded()
                    let relayout = Self.snapshotAll(view, chrome, fans)
                    CATransaction.flush()
                    let flush = Self.snapshotAll(view, chrome, fans)
                    if await turn.next() { linkFired += 1 }
                    let link = Self.snapshotAll(view, chrome, fans)
                    await Self.settle(view, turns: 3)
                    let settled = Self.snapshotAll(view, chrome, fans)

                    let band = passSnaps != nil ? passBand : afterBand
                    let visible = view.bounds
                    var bandNow: Set<Int> = []
                    var visibleNow: Set<Int> = []
                    for (index, fan) in fans.enumerated() {
                        let truth = settled[index]
                        if truth.laidOut, let top = truth.top, top >= visible.minY, top < visible.maxY {
                            visibleNow.insert(index)
                        }
                        guard Self.inBand(fan.range, band) else { continue }
                        bandNow.insert(index)
                        let newVisible = visibleNow.contains(index) && !lastVisible.contains(index)
                        var moments: [String: Snapshot] = [
                            "afterPass": afterPass[index], "hop": hop[index],
                            "relayout": relayout[index], "flush": flush[index], "link": link[index],
                        ]
                        if let passSnaps { moments["pass"] = passSnaps[index] }
                        rows.append(Row(newVisible: newVisible, moments: moments, truth: truth))
                        let cells = order.map { name in "\(name)=\(moments[name].map(Self.cell) ?? "unrun")" }
                        print("VM17M|walk#\(stop)@\(Int(offset)) vis=\(Int(visible.minY))..\(Int(visible.maxY)) band=\(band.map { "\($0.location)..\($0.location + $0.length)" } ?? "all") @\(fan.range.location) newBand=\(lastBand.contains(index) ? 0 : 1) newVis=\(newVisible ? 1 : 0) ideal=\(Self.fmt(ideal[fan.range.location])) \(cells.joined(separator: " ")) settle=\(Self.cell(truth)) fired=\(passSnaps != nil ? 1 : 0)")
                    }
                    lastBand = bandNow
                    lastVisible = visibleNow
                    stop += 1
                    let end = max(0, view.contentSize.height + view.adjustedContentInset.bottom - view.bounds.height)
                    if offset >= end - 0.5 || stop >= 400 { break }
                    offset = min(offset + 0.8 * view.bounds.height, end)
                }
                print("VM17M|walk|END stops=\(stop) sentinelFired=\(sentinelFired)/\(stop) linkFired=\(linkFired)/\(stop) contentHeight=\(Int(view.contentSize.height))")
                Self.summarize(rows, mount: "1", moments: order)
                // What the probe saw: the badge after the settle, against the truth.
                var probeAll = Tally(), probeNew = Tally()
                for row in rows where row.truth.laidOut {
                    guard let truth = row.truth.top else { continue }
                    probeAll.add(row.truth.badge, usable: true, truth: truth)
                    if row.newVisible { probeNew.add(row.truth.badge, usable: true, truth: truth) }
                }
                print("VM17M|SUMMARY mount=1 moment=settle read=badge all(\(probeAll.text)) newVisible(\(probeNew.text)) — the probe's own reading, after a relayout this walk adds")
            }

            // ── Mount 2 (cold): option (c) — the band laid out in one run
            // from the viewport's start before each stop's pass.
            do {
                let (_, surface) = await makeSurfaceEditor(session, postID: seed.postID)
                let window = Self.host(surface)
                defer { Self.unhost(window) }
                let view = surface.textView
                await Self.settle(view)
                let chrome = try #require(view.takesChrome, "setup: the takes chrome is installed")
                let tlm = try #require(view.textLayoutManager, "setup: TextKit 2")
                let cm = try #require(tlm.textContentManager, "setup: a content manager")

                let sentinel = PassSentinel(frame: .zero)
                sentinel.isUserInteractionEnabled = false
                sentinel.isAccessibilityElement = false
                view.insertSubview(sentinel, at: 0)
                defer { sentinel.removeFromSuperview() }

                var rows: [Row] = []
                var lastVisible: Set<Int> = []
                var runs = 0
                var runSeconds: Double = 0
                var offset: CGFloat = 0
                var stop = 0
                while true {
                    // The band run: viewport start → the last band fan's
                    // first character, the band extended by one viewport.
                    var ranTo = "none"
                    if let viewport = tlm.textViewportLayoutController.viewportRange {
                        let start = cm.offset(from: tlm.documentRange.location, to: viewport.location)
                        let end = cm.offset(from: tlm.documentRange.location, to: viewport.endLocation)
                        let band = view.nearViewportBand()
                        let reach = (band.map { $0.location + $0.length } ?? end) + max(end - start, 0)
                        if let last = fans.last(where: { $0.range.location >= start && $0.range.location < reach }),
                           let through = cm.location(tlm.documentRange.location, offsetBy: last.range.location + 1),
                           let range = NSTextRange(location: viewport.location, end: through) {
                            let began = CFAbsoluteTimeGetCurrent()
                            tlm.ensureLayout(for: range)
                            runSeconds += CFAbsoluteTimeGetCurrent() - began
                            runs += 1
                            ranTo = "\(start)..\(last.range.location + 1)"
                        }
                    }
                    var passSnaps: [Snapshot]?
                    var passBand: NSRange?
                    sentinel.onLayout = {
                        passBand = view.nearViewportBand()
                        passSnaps = Self.snapshotAll(view, chrome, fans)
                    }
                    sentinel.setNeedsLayout()
                    view.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
                    (view.window ?? view).layoutIfNeeded()
                    sentinel.onLayout = nil
                    let afterBand = view.nearViewportBand()
                    let afterPass = Self.snapshotAll(view, chrome, fans)
                    await Self.settle(view, turns: 3)
                    let settled = Self.snapshotAll(view, chrome, fans)

                    let band = passSnaps != nil ? passBand : afterBand
                    let visible = view.bounds
                    var visibleNow: Set<Int> = []
                    for (index, fan) in fans.enumerated() {
                        let truth = settled[index]
                        if truth.laidOut, let top = truth.top, top >= visible.minY, top < visible.maxY {
                            visibleNow.insert(index)
                        }
                        guard Self.inBand(fan.range, band) else { continue }
                        let newVisible = visibleNow.contains(index) && !lastVisible.contains(index)
                        // The chrome-resolved frame under (c) is the pass's
                        // badge (the sentinel's), else the after-pass one.
                        let resolved = passSnaps?[index] ?? afterPass[index]
                        rows.append(Row(newVisible: newVisible, moments: ["bandRun": resolved], truth: truth))
                        print("VM17M|c|walk#\(stop)@\(Int(offset)) vis=\(Int(visible.minY))..\(Int(visible.maxY)) ran=\(ranTo) @\(fan.range.location) newVis=\(newVisible ? 1 : 0) ideal=\(Self.fmt(ideal[fan.range.location])) bandRun=\(Self.cell(resolved)) settle=\(Self.cell(truth)) fired=\(passSnaps != nil ? 1 : 0)")
                    }
                    lastVisible = visibleNow
                    stop += 1
                    let end = max(0, view.contentSize.height + view.adjustedContentInset.bottom - view.bounds.height)
                    if offset >= end - 0.5 || stop >= 400 { break }
                    offset = min(offset + 0.8 * view.bounds.height, end)
                }
                print("VM17M|c|END stops=\(stop) runs=\(runs) runTotalMs=\(String(format: "%.2f", runSeconds * 1000)) contentHeight=\(Int(view.contentSize.height))")
                Self.summarize(rows, mount: "2", moments: ["bandRun"])
            }
        }
    }
}

// MARK: - Test-side helpers (no product hook)

/// A zero-size test view placed at the text view's subview index 0: UIKit
/// lays a view's subviews out after the view itself in one recursion, so its
/// `layoutSubviews` runs right after the text view's (and the chrome's tick).
@MainActor
private final class PassSentinel: UIView {
    var onLayout: (@MainActor () -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?()
    }
}

/// One `CADisplayLink` callback, awaited; a 0.5 s fallback resumes it if no
/// callback comes (the result says which).
@MainActor
private final class DisplayTurn: NSObject {
    private var continuation: CheckedContinuation<Bool, Never>?
    private var link: CADisplayLink?

    func next(timeout: TimeInterval = 0.5) async -> Bool {
        await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            self.continuation = continuation
            let link = CADisplayLink(target: self, selector: #selector(fire(_:)))
            self.link = link
            link.add(to: .main, forMode: .common)
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) { [weak self] in
                MainActor.assumeIsolated { self?.finish(fired: false) }
            }
        }
    }

    @objc private func fire(_ link: CADisplayLink) {
        finish(fired: true)
    }

    private func finish(fired: Bool) {
        link?.invalidate()
        link = nil
        guard let continuation else { return }
        self.continuation = nil
        continuation.resume(returning: fired)
    }
}
