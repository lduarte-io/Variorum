//
//  MobileTakesChromeTests.swift
//  VariorumMobileTests
//
//  Mobile Stage 2, batch 1 — the takes chrome over REAL laid-out geometry
//  (the checkbox-tap suite's pattern): the ⑂ badge overlay (LK3), the
//  LK10 exclusion-rect gutter (text never under the badge; non-fanned
//  blocks reserve nothing), the peek marker + LK6 pill, and the pan
//  router's fragment-rect scoping. Gesture FEEL (dominance under a live
//  touch, loupe coexistence) was the spike's real-touch half and rides
//  the device round — these tests pin the scoping brain and the drawn
//  chrome.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Harness

/// A fanned + a fanless block whose texts WRAP (no spaces — the line
/// breaks exactly at the available width, so first-line width reads the
/// gutter's effect directly).
@MainActor
private func seedWrappingFannedPost(
    _ session: AppSession
) async throws -> (postID: String, blockA: String, a2: String, blockB: String) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "chrome", profile: .blog)
        let longRun = String(repeating: "abcdefghij", count: 20)
        let a = try ops.newBlock(in: post.id, text: "A" + longRun, at: .end)
        let b = try ops.newBlock(in: post.id, text: "B" + longRun, at: .end)
        let take = try ops.branchVariant(a.block.id, from: a.variant.id)
        try ops.autosave(take.id, text: "The other take of A.", charDelta: 5)
        return (post.id, a.block.id, take.id, b.block.id)
    }
}

@MainActor
private func makeSurface(
    _ session: AppSession, postID: String
) async -> (model: MobileEditorViewModel, surface: MobileWriteSurfaceView) {
    let model = MobileEditorViewModel(
        session: session, postID: postID,
        sleep: { _ in throw CancellationError() })
    model.tailIdleSleep = { _ in throw CancellationError() }
    let surface = MobileWriteSurfaceView()
    surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
    model.attach(textView: surface.textView)
    await model.loadOnce()
    surface.layoutIfNeeded()
    return (model, surface)
}

/// The first line fragment's typographic width at a surface offset.
@MainActor
private func firstLineWidth(_ view: MobileEditorTextView, atOffset offset: Int) -> CGFloat? {
    guard let tlm = view.textLayoutManager,
          let cm = tlm.textContentManager,
          let location = cm.location(tlm.documentRange.location, offsetBy: offset)
    else { return nil }
    var width: CGFloat?
    tlm.enumerateTextLayoutFragments(from: location, options: [.ensuresLayout]) { frag in
        width = frag.textLineFragments.first?.typographicBounds.width
        return false
    }
    return width
}

/// A point inside the fragment at a surface offset, in VIEW coordinates.
@MainActor
private func pointInsideFragment(
    _ view: MobileEditorTextView, atOffset offset: Int
) -> CGPoint? {
    guard let tlm = view.textLayoutManager,
          let cm = tlm.textContentManager,
          let location = cm.location(tlm.documentRange.location, offsetBy: offset)
    else { return nil }
    var frame: CGRect?
    tlm.enumerateTextLayoutFragments(from: location, options: [.ensuresLayout]) { frag in
        frame = frag.layoutFragmentFrame
        return false
    }
    guard let frame else { return nil }
    return CGPoint(
        x: frame.midX + view.textContainerInset.left,
        y: frame.midY + view.textContainerInset.top)
}

@MainActor
private func pillSubview(_ chrome: MobileTakesChromeController, id: String) -> UIView? {
    chrome.pillView?.subviews.first { $0.accessibilityIdentifier == id }
}

// MARK: - The suite

@MainActor
@Suite("Mobile takes chrome — badge, gutter, marker, pill, pan scoping (S2 batch 1)")
struct MobileTakesChromeTests {
    @Test func badgeAppearsOnlyOnFannedBlocksAndOnlyTheyReserveSpace() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedWrappingFannedPost(session)
            let (model, surface) = await makeSurface(session, postID: seed.postID)
            let view = surface.textView
            guard let chrome = view.takesChrome else {
                Issue.record("takes chrome not installed")
                return
            }

            // The badge: ⑂ alone, count-free, on the fanned block only.
            let badge = chrome.badgeView(for: seed.blockA)
            #expect(badge != nil)
            #expect((badge as? UIButton)?.title(for: .normal)
                    == MobileTakesChromeController.badgeGlyph)
            #expect(chrome.badgeView(for: seed.blockB) == nil)

            // LK10: exactly ONE gutter — the fanned block's; non-fanned
            // blocks reserve nothing.
            #expect(view.textContainer.exclusionPaths.count == 1)
            let gutter = view.textContainer.exclusionPaths[0].bounds
            #expect(abs(gutter.maxX - view.textContainer.size.width) < 1)
            #expect(gutter.width == MobileTakesChromeController.gutterWidth)

            // The badge sits inside the gutter's column, on the first line.
            if let badge {
                #expect(badge.frame.minX >= gutter.minX + view.textContainerInset.left - 1)
                #expect(abs(badge.frame.minY - (gutter.minY + view.textContainerInset.top)) < 1)
            }
            #expect(model.identityAuditFailures == 0)
            #expect(!view.canaryFired)
        }
    }

    @Test func textNeverRunsUnderTheBadge() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedWrappingFannedPost(session)
            let (model, surface) = await makeSurface(session, postID: seed.postID)
            let view = surface.textView
            let containerWidth = view.textContainer.size.width
            let reserved = containerWidth - MobileTakesChromeController.gutterWidth

            // The FANNED block's first line ends short of the gutter…
            guard let rangeA = model.rangeOfBlock(seed.blockA),
                  let widthA = firstLineWidth(view, atOffset: rangeA.location)
            else {
                Issue.record("no laid-out geometry for block A")
                return
            }
            #expect(widthA <= reserved + 1, "the first line must stop at the gutter")

            // …while the NON-fanned block's first line (same unbroken run)
            // uses the full width — the discrimination that proves the
            // exclusion rect, not the text, did it.
            guard let rangeB = model.rangeOfBlock(seed.blockB),
                  let widthB = firstLineWidth(view, atOffset: rangeB.location)
            else {
                Issue.record("no laid-out geometry for block B")
                return
            }
            #expect(widthB > reserved, "a non-fanned block reserves nothing")
        }
    }

    @Test func panRouterScopesToFannedBlockGeometry() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedWrappingFannedPost(session)
            let (model, surface) = await makeSurface(session, postID: seed.postID)
            let view = surface.textView
            guard let router = view.takesPanRouter else {
                Issue.record("pan router not installed")
                return
            }
            guard let rangeA = model.rangeOfBlock(seed.blockA),
                  let rangeB = model.rangeOfBlock(seed.blockB),
                  let pointA = pointInsideFragment(view, atOffset: rangeA.location),
                  let pointB = pointInsideFragment(view, atOffset: rangeB.location)
            else {
                Issue.record("no laid-out geometry")
                return
            }

            // A pan starting on the fanned block targets it; the fanless
            // block and off-text space never respond (M5).
            #expect(router.panTargetBlockID(at: pointA) == seed.blockA)
            #expect(router.panTargetBlockID(at: pointB) == nil)
            #expect(router.blockID(at: pointB) == seed.blockB, "scoping is the FAN, not the hit-test")
            #expect(router.panTargetBlockID(at: CGPoint(x: 50, y: 5000)) == nil)

            // The gesture is installed delegate-gated on the view, never
            // simultaneous with the scroll pan (the spike's proven config).
            let pans = view.gestureRecognizers?.compactMap { $0 as? UIPanGestureRecognizer }
                .filter { $0.delegate === router } ?? []
            #expect(pans.count == 1)
        }
    }

    @Test func aFlipShowsTheMarkerAndThePill() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedWrappingFannedPost(session)
            let (model, surface) = await makeSurface(session, postID: seed.postID)
            let view = surface.textView
            guard let chrome = view.takesChrome else {
                Issue.record("takes chrome not installed")
                return
            }
            #expect(chrome.markerView(for: seed.blockA) == nil)

            model.takes.flip(blockID: seed.blockA, forward: true)

            // The marker: the takes register's wash + edge bar, BEHIND the
            // text (subview index 0), spanning the peeked block.
            guard let marker = chrome.markerView(for: seed.blockA) else {
                Issue.record("no peek marker after the flip")
                return
            }
            #expect(view.subviews.firstIndex(of: marker) == 0, "the wash sits behind the text")
            #expect(marker.backgroundColor == MobileEditorStyle.face.takeTint)
            #expect(marker.subviews.first?.backgroundColor == MobileEditorStyle.face.takeLine)
            #expect(marker.frame.height > 0)

            // The pill: showing, under the block, ‹ take 2/2 › with ✓.
            #expect(chrome.pillIsShowing)
            #expect(chrome.pillBlockID == seed.blockA)
            #expect((pillSubview(chrome, id: "takes.pill.choose") as? UIButton)?.isHidden == false)
            #expect(pillSubview(chrome, id: "takes.pill.chosenState")?.isHidden == true)
            if let pill = chrome.pillView, let marker = chrome.markerView(for: seed.blockA) {
                #expect(pill.frame.minY >= marker.frame.maxY - 8, "the pill rides UNDER the block")
            }

            // Flip back onto chosen: marker gone, pill states "✓ chosen"
            // with no ✓ door (P-2).
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(chrome.markerView(for: seed.blockA) == nil)
            #expect(chrome.pillIsShowing)
            #expect((pillSubview(chrome, id: "takes.pill.choose") as? UIButton)?.isHidden == true)
            #expect(pillSubview(chrome, id: "takes.pill.chosenState")?.isHidden == false)
            #expect(model.identityAuditFailures == 0)
            #expect(!view.canaryFired)
        }
    }

    @Test func chooseFromThePeekEndsTheMarkerAndThePillStatesChosen() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedWrappingFannedPost(session)
            let (model, surface) = await makeSurface(session, postID: seed.postID)
            guard let chrome = surface.textView.takesChrome else {
                Issue.record("takes chrome not installed")
                return
            }
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(chrome.markerView(for: seed.blockA) != nil)

            await model.takes.chooseDisplayed(blockID: seed.blockA)

            #expect(chrome.markerView(for: seed.blockA) == nil, "chosen is not a peek")
            #expect(chrome.pillIsShowing)
            #expect((pillSubview(chrome, id: "takes.pill.choose") as? UIButton)?.isHidden == true)
            #expect(pillSubview(chrome, id: "takes.pill.chosenState")?.isHidden == false)
        }
    }

    @Test func theBadgeTapOpensTheBrowserNotThePill_P15Retired() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedWrappingFannedPost(session)
            let (model, surface) = await makeSurface(session, postID: seed.postID)
            guard let chrome = surface.textView.takesChrome else {
                Issue.record("takes chrome not installed")
                return
            }
            #expect(!chrome.pillIsShowing)

            chrome.badgeTapped(seed.blockA)

            // S2 batch 2: the tap is the BROWSER's door (LK3's letter —
            // batch 1's interim pill reveal, P15, retired exactly as its
            // own record planned). The pill remains the in-page FLIP's
            // face (`aFlipShowsTheMarkerAndThePill` pins it); a tap
            // peeks nothing and writes nothing.
            #expect(!chrome.pillIsShowing)
            #expect(model.takesBrowser.openBlockID == seed.blockA)
            #expect(!model.takes.isPeeking(seed.blockA))
        }
    }

    @Test func perTickRefreshResolvesOnlyNearViewportGeometry() async throws {
        // The S2 ladder round-1 MINOR-3 call-shape pin (P-8: per-tick
        // cost ∝ realized rows, never the post). A long post with a
        // fanned block at the top (in the viewport) and one far below:
        // a `.nearViewport` pass — the layoutSubviews tick's scope —
        // forces geometry ONLY for the near block, while the far block's
        // gutter exclusion survives from its cached rect (dropping it
        // would reflow the document); a `.document` pass resolves both.
        // On the old code every fanned block was layout-forced per tick.
        try await withEditorWorld { session, db in
            let seed = try await session.runner.run { ops in
                let post = try ops.createPost(title: "long", profile: .blog)
                let near = try ops.newBlock(in: post.id, text: "The near fanned block.", at: .end)
                let filler = String(
                    repeating: "A steady filler paragraph that wraps across the "
                        + "surface a few times to build real height. ",
                    count: 5)
                for _ in 0..<60 {
                    _ = try ops.newBlock(in: post.id, text: filler, at: .end)
                }
                let far = try ops.newBlock(in: post.id, text: "The far fanned block.", at: .end)
                let nearTake = try ops.branchVariant(near.block.id, from: near.variant.id)
                try ops.autosave(nearTake.id, text: "Near, the other way.", charDelta: 5)
                let farTake = try ops.branchVariant(far.block.id, from: far.variant.id)
                try ops.autosave(farTake.id, text: "Far, the other way.", charDelta: 5)
                return (postID: post.id, near: near.block.id, far: far.block.id)
            }
            let (model, surface) = await makeSurface(session, postID: seed.postID)
            let view = surface.textView
            guard let chrome = view.takesChrome else {
                Issue.record("takes chrome not installed")
                return
            }
            // Both fanned blocks carry badges and gutters (full passes ran
            // at load); the far one sits far outside the 700 pt viewport.
            #expect(chrome.badgeView(for: seed.near) != nil)
            #expect(chrome.badgeView(for: seed.far) != nil)
            #expect(view.textContainer.exclusionPaths.count == 2)
            #expect(view.contentSize.height > 2_000, "the post must dwarf the viewport")

            // The per-tick scope: the near block resolves, the FAR one is
            // never layout-forced — yet its exclusion survives (cached).
            chrome.refresh(scope: .nearViewport)
            #expect(chrome.lastGeometryResolvedBlockIDs.contains(seed.near))
            #expect(!chrome.lastGeometryResolvedBlockIDs.contains(seed.far),
                    "a scroll tick must not force layout of far-off-screen fragments (P-8; TEXTKIT2 §2)")
            #expect(chrome.badgeView(for: seed.far) != nil)
            #expect(view.textContainer.exclusionPaths.count == 2,
                    "the off-band gutter survives from its cached rect")

            // The full pass (every content/geometry input axis) resolves
            // both — the scope discriminates, the vocabulary doesn't shrink.
            chrome.refresh(scope: .document)
            #expect(chrome.lastGeometryResolvedBlockIDs.contains(seed.near))
            #expect(chrome.lastGeometryResolvedBlockIDs.contains(seed.far))
            #expect(model.identityAuditFailures == 0)
            #expect(!view.canaryFired)
        }
    }

    @Test func theChromeRestylesWithTheVoice() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedWrappingFannedPost(session)
            let (model, surface) = await makeSurface(session, postID: seed.postID)
            guard let chrome = surface.textView.takesChrome else {
                Issue.record("takes chrome not installed")
                return
            }
            let badge = chrome.badgeView(for: seed.blockA) as? UIButton
            #expect(badge?.titleColor(for: .normal) == MobileEditorStyle.terminalFace.muted)

            MobileEditorStyle.voice = .study
            defer {
                MobileEditorStyle.voice = .terminal
                model.applyVoiceChange()
            }
            model.applyVoiceChange()
            #expect(badge?.titleColor(for: .normal) == MobileEditorStyle.studyFace.muted)
        }
    }
}
