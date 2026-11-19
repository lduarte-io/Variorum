//
//  MobileFanBadgePlacementProbeTests.swift
//  VariorumMobileTests
//
//  VM-17 — do the phone's fan badges pile at block 1 on a long fanned note?
//  (VM-78 batch C; the record is `notes/plans/fixes/vm-78-fixes-to-whats-
//  there.md`, BATCH C — LIVE STATUS.) The Mac's VX-230: TextKit 2 reports a
//  paragraph it has not laid out as a `.zero` frame, and a badge placed from
//  that frame sat at the first block (TEXTKIT2 §3, VX-246 U4). The phone's
//  badge reads its y from `MobileEditorTextView.firstLineGeometry`, which
//  FORCES `.ensuresLayout` from the block's own offset — so a `.zero` frame
//  cannot arise; but TEXTKIT2 §3 also records that a layout forced from a
//  mid-document location places fragments at ESTIMATED offsets until a
//  viewport pass re-positions them. The probe therefore reads three things
//  on a long note with many fanned blocks below the fold:
//  1. THE PILE (VX-230's shape): no two badges coincide, and no badge but
//     the first block's sits at the first block.
//  2. OFF-SCREEN, AT ITS OWN BLOCK: every badge drawn at load for a block
//     below the fold stands where that block's first line really is — the
//     truth taken from an independent bare TextKit 2 stack over the same
//     attributed text, laid out whole from the start (VX-246: a whole walk
//     with nothing laid out ahead of it is exact). A badge not drawn passes.
//  3. VISIBLE, AT ITS OWN BLOCK: scrolled to, each badge stands on its
//     block's live first line.
//  Red ⇒ the fix takes this probe as its pin; green ⇒ the finding is hollow
//  and this stays as a guard. The cost note (what forcing `.ensuresLayout`
//  for every fanned block costs on a long note — VM-179's, wave 4) prints
//  only.
//

import Dependencies
import Foundation
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-17 — a long fanned note's badges stand at their own blocks (probe)", .serialized)
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

    /// The truth: an independent bare TK2 stack over a COPY of the surface's
    /// attributed text, at the surface's container width, laid out whole from
    /// the start — each offset's first fragment minY (container coords).
    private static func settledMinY(
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

    /// The live surface's own fragment at an offset, NOT forced: its minY and
    /// whether TextKit had laid it out.
    private static func liveFragment(
        _ view: MobileEditorTextView, at offset: Int
    ) -> (minY: CGFloat, laidOut: Bool)? {
        guard let tlm = view.textLayoutManager,
              let cm = tlm.textContentManager,
              let location = cm.location(tlm.documentRange.location, offsetBy: offset),
              let fragment = tlm.textLayoutFragment(for: location)
        else { return nil }
        return (fragment.layoutFragmentFrame.minY, fragment.state == .layoutAvailable)
    }

    @Test func noFanBadgePilesAtTheFirstBlockOrStandsOffItsOwnBlockOnALongNote() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await Self.seedLongFannedNote(session, count: 150, fanEvery: 7)
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            let window = Self.host(surface)
            defer {
                window.isHidden = true
                window.rootViewController = nil
            }
            let view = surface.textView
            await Self.settle(view)
            let chrome = try #require(view.takesChrome, "takes chrome installed")
            let inset = view.textContainerInset
            let tolerance: CGFloat = 1

            let offsets = try seed.fanned.map { try #require(model.rangeOfBlock($0)).location }
            let truth = Self.settledMinY(of: view, offsets: offsets)
            #expect(view.contentSize.height > 6_000, "non-vacuity: the note dwarfs the viewport")
            #expect(seed.fanned.count >= 20, "non-vacuity: many fanned blocks")

            // ── At load: every badge as the chrome drew it.
            struct Reading {
                let blockID: String
                let offset: Int
                let badgeY: CGFloat?
                let truthY: CGFloat
            }
            var readings: [Reading] = []
            for (blockID, offset) in zip(seed.fanned, offsets) {
                let truthY = try #require(truth[offset], "the bare stack laid out offset \(offset)")
                readings.append(Reading(
                    blockID: blockID, offset: offset,
                    badgeY: chrome.badgeView(for: blockID)?.frame.minY,
                    truthY: inset.top + truthY))
            }
            let firstBlockY = inset.top + (truth[offsets[0]] ?? 0)
            let viewportBottom = view.bounds.height

            // 1 — THE PILE.
            let drawn = readings.filter { $0.badgeY != nil }
            var coinciding: [String] = []
            for (i, a) in drawn.enumerated() {
                for b in drawn[(i + 1)...] where abs(a.badgeY! - b.badgeY!) < tolerance {
                    coinciding.append("blocks@\(a.offset)&\(b.offset) y=\(a.badgeY!)")
                }
            }
            let atBlockOne = drawn.filter {
                $0.offset != offsets[0] && abs($0.badgeY! - firstBlockY) < tolerance
            }
            #expect(coinciding.isEmpty, "VM-17 pile: two badges coincide — \(coinciding)")
            #expect(atBlockOne.isEmpty,
                    "VM-17 pile: a later block's badge stands at block 1 — \(atBlockOne.map(\.offset))")

            // 2 — OFF-SCREEN AT LOAD, AT ITS OWN BLOCK (or not drawn).
            let offPlace = readings.filter {
                guard let y = $0.badgeY else { return false }
                return $0.truthY > viewportBottom && abs(y - $0.truthY) > tolerance
            }
            #expect(offPlace.isEmpty,
                    "VM-17: an off-screen badge stands off its own block — \(offPlace.map { "@\($0.offset) badge=\($0.badgeY!) truth=\($0.truthY)" })")

            // 3 — VISIBLE: scrolled to, each badge on its block's live line.
            var visibleOff: [String] = []
            var table: [String] = []
            for reading in readings {
                view.setContentOffset(
                    CGPoint(x: 0, y: max(0, reading.truthY - 120)), animated: false)
                await Self.settle(view, turns: 3)
                let live = Self.liveFragment(view, at: reading.offset)
                let badgeNow = chrome.badgeView(for: reading.blockID)?.frame.minY
                let liveY = live.map { inset.top + $0.minY }
                if let badgeNow, let liveY, abs(badgeNow - liveY) > tolerance {
                    visibleOff.append("@\(reading.offset) badge=\(badgeNow) line=\(liveY)")
                }
                if badgeNow == nil { visibleOff.append("@\(reading.offset) no badge on screen") }
                table.append("@\(reading.offset) loadBadge=\(reading.badgeY.map { "\($0)" } ?? "nil") truth=\(reading.truthY) visibleBadge=\(badgeNow.map { "\($0)" } ?? "nil") liveLine=\(liveY.map { "\($0)" } ?? "nil") laidOut=\(live?.laidOut ?? false)")
            }
            #expect(visibleOff.isEmpty, "VM-17: a visible badge stands off its block — \(visibleOff)")
            for row in table { print("VM17|probe|\(row)") }
            print("VM17|probe|SUMMARY fanned=\(readings.count) drawnAtLoad=\(drawn.count) coinciding=\(coinciding.count) atBlockOne=\(atBlockOne.count) offPlaceOffscreen=\(offPlace.count) visibleOff=\(visibleOff.count) contentHeight=\(Int(view.contentSize.height))")
            #expect(model.identityAuditFailures == 0)
            #expect(!view.canaryFired)
        }
    }

    /// COST NOTE (prints only — VM-179 owns the cost, wave 4): the load of a
    /// long note with and without fans over the SAME text, and a `.document`
    /// chrome pass forced from a cold layout, which is where every fanned
    /// block's `.ensuresLayout` is paid.
    @Test(arguments: [150, 600])
    func vm17CostNote_theDocumentPassOnALongFannedNote(_ count: Int) async throws {
        var lines: [String] = []
        for fanned in [false, true] {
            try await withEditorWorld { session, _ in
                let seed = try await Self.seedLongFannedNote(
                    session, count: count, fanEvery: fanned ? 7 : nil)
                let model = MobileEditorViewModel(
                    session: session, postID: seed.postID,
                    sleep: { _ in throw CancellationError() })
                model.tailIdleSleep = { _ in throw CancellationError() }
                let surface = MobileWriteSurfaceView()
                surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
                model.attach(textView: surface.textView)
                let clock = ContinuousClock()
                let load = await clock.measure { await model.loadOnce() }
                let window = Self.host(surface)
                defer {
                    window.isHidden = true
                    window.rootViewController = nil
                }
                let view = surface.textView
                await Self.settle(view)
                var cold: Duration = .zero
                var warm: Duration = .zero
                if let chrome = view.takesChrome, let tlm = view.textLayoutManager {
                    tlm.invalidateLayout(for: tlm.documentRange)
                    cold = clock.measure { chrome.refresh(scope: .document) }
                    warm = clock.measure { chrome.refresh(scope: .document) }
                }
                lines.append("blocks=\(count) fanned=\(seed.fanned.count) loadOnce=\(load) documentPassCold=\(cold) documentPassWarm=\(warm) contentHeight=\(Int(view.contentSize.height))")
            }
        }
        for line in lines { print("VM17|cost|\(line)") }
    }
}
