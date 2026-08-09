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

/// The governing paragraph style at a surface location (B3: the gutter
/// is a first-paragraph tail reservation — storage truth, read exactly
/// where layout reads it).
@MainActor
private func governingStyle(
    _ view: MobileEditorTextView, at location: Int
) -> NSParagraphStyle? {
    view.textStorage.attribute(
        .paragraphStyle, at: location, effectiveRange: nil) as? NSParagraphStyle
}

@MainActor
private func tailReservation(_ view: MobileEditorTextView, at location: Int) -> CGFloat {
    -(governingStyle(view, at: location)?.tailIndent ?? 0)
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

            // LK10: exactly ONE reservation — the fanned block's first
            // paragraph ends `gutterWidth` short of the trailing margin
            // (B3's paragraph-style mechanism); the fanless block
            // reserves nothing; and the container carries NO exclusion
            // paths (FB2-1's root — their presence alone made every
            // keystroke's relayout document-scale; pinned).
            let rangeA = try #require(model.rangeOfBlock(seed.blockA))
            let rangeB = try #require(model.rangeOfBlock(seed.blockB))
            #expect(tailReservation(view, at: rangeA.location)
                    == MobileTakesChromeController.gutterWidth)
            #expect(tailReservation(view, at: rangeB.location) == 0)
            #expect(view.textContainer.exclusionPaths.isEmpty)

            // The badge sits in the reserved trailing column, on the
            // fanned block's first line.
            if let badge, let line = view.firstLineGeometry(atOffset: rangeA.location) {
                #expect(badge.frame.minX >= view.textContainerInset.left
                        + view.textContainer.size.width
                        - MobileTakesChromeController.gutterWidth - 1)
                #expect(abs(badge.frame.minY
                        - (line.fragmentMinY + view.textContainerInset.top)) < 1)
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

    /// P38 (parity A3, her ruled fix — marker PLACEMENT stands; the
    /// one-line fanned+commented crowding corner goes): a fanned block
    /// that is also commented reserves the ●n marker's room in its
    /// first-line gutter (content-keyed — never measured line count, the
    /// oscillation trap), so the marker can never run under the ⑂ badge.
    /// RED-ON-OLD: the fixture's text is computed to end inside the old
    /// crowding zone (right against the 30 pt gutter), where the old
    /// tree's marker frame overlapped the badge's.
    @Test func aOneLineFannedAndCommentedBlockNeverCrowdsTheBadge() async throws {
        try await withEditorWorld { session, _ in
            // The fixture, computed against the harness geometry (393 pt
            // surface, mono base font in the terminal world): text whose
            // end lands ONE LINE under the old 30 pt gutter (right edge ≤
            // cw−30−pad) yet inside the badge's reach (end+3 plus the
            // marker's ~30 pt crosses the badge's left edge at cw−26) —
            // the steady-state crowding her P38 corner recorded. Target
            // end ≈ cw−43.
            let charW = ("a" as NSString).size(
                withAttributes: [.font: MobileEditorStyle.baseFont]).width
            // The REAL container width at the harness frame (read off a
            // made view so the A3 prose insets — or any future margin —
            // can never stale this arithmetic).
            let probe = MobileEditorTextView.make()
            probe.frame = CGRect(x: 0, y: 0, width: 393, height: 100)
            probe.layoutIfNeeded()
            let containerWidth = probe.textContainer.size.width
            let pad = probe.textContainer.lineFragmentPadding // read live so the guard can't silently degrade (ladder R2 NIT)
            let count = Int(((containerWidth - 43) - pad) / charW)
            let filling = String(repeating: "a", count: count)

            let seed = try await session.runner.run { ops -> (post: String, a: String, b: String) in
                let post = try ops.createPost(title: "crowd", profile: .blog)
                let a = try ops.newBlock(in: post.id, text: filling, at: .end)
                _ = try ops.branchVariant(a.block.id, from: a.variant.id)
                _ = try ops.addBlockComment(to: a.block.id, text: "One.")
                let b = try ops.newBlock(in: post.id, text: filling, at: .end)
                _ = try ops.branchVariant(b.block.id, from: b.variant.id)
                return (post.id, a.block.id, b.block.id)
            }
            let (model, surface) = await makeSurface(session, postID: seed.post)
            let view = surface.textView
            guard let chrome = view.takesChrome, let decor = view.blockDecor else {
                Issue.record("chrome not installed")
                return
            }
            // The second chrome pass the app takes on its own: installing
            // the widened reservation invalidates that paragraph, and the
            // next layout tick re-measures the marker under it (the
            // standing decor→chrome ordering; a single pass holds
            // pre-reservation geometry for exactly one tick).
            view.refreshChrome()

            // The MECHANISM (B3's paragraph-tail form): the
            // fanned+commented block's reservation is widened by the
            // marker's room; its fanned-but-uncommented sibling keeps the
            // plain LK10 room (discrimination against a blanket widening).
            let rangeA = try #require(model.rangeOfBlock(seed.a))
            let rangeB = try #require(model.rangeOfBlock(seed.b))
            #expect(tailReservation(view, at: rangeA.location)
                    == MobileTakesChromeController.gutterWidth
                        + MobileTakesChromeController.commentMarkRoom)
            #expect(tailReservation(view, at: rangeB.location)
                    == MobileTakesChromeController.gutterWidth)

            // The BEHAVIOR: the ●n marker never intersects the ⑂ badge.
            let badge = try #require(chrome.badgeView(for: seed.a))
            let mark = try #require(decor.commentMark(for: seed.a))
            #expect(!mark.frame.intersects(badge.frame),
                    "the marker must never run under the badge")
        }
    }

    /// FIX-3 (Stage A ladder round 1, the pin-first probe): the reviewer's
    /// ~3 pt residual window — `commentMarkRoom` vs the marker's own
    /// measured width — probed by FLUSH-END one-liners. The standing pin's
    /// fixture WRAPS under the widened exclusion (it asserts the two-line
    /// safe case); this one seeds a band of candidate lengths spanning the
    /// flush boundary, so whatever TK2 does with `lineFragmentPadding` at
    /// exclusion-path edges (the finding's undetermined half), the maximal
    /// one-liner — the marker as far right as it can ever sit — is in the
    /// set. Every one-line fanned+commented candidate's ●n marker must
    /// clear the ⑂ badge.
    @Test func aFlushEndOneLineFannedAndCommentedBlockNeverCrowdsTheBadge() async throws {
        try await withEditorWorld { session, _ in
            let charW = ("a" as NSString).size(
                withAttributes: [.font: MobileEditorStyle.baseFont]).width
            let probe = MobileEditorTextView.make()
            probe.frame = CGRect(x: 0, y: 0, width: 393, height: 100)
            probe.layoutIfNeeded()
            let containerWidth = probe.textContainer.size.width
            let pad = probe.textContainer.lineFragmentPadding // read live so the guard can't silently degrade (ladder R2 NIT)
            let reserved = MobileTakesChromeController.gutterWidth
                + MobileTakesChromeController.commentMarkRoom
            let center = Int(((containerWidth - reserved) - pad) / charW)
            let counts = Array((center - 3)...(center + 2))

            let seed = try await session.runner.run { ops -> (post: String, blocks: [String]) in
                let post = try ops.createPost(title: "flush", profile: .blog)
                var blocks: [String] = []
                for count in counts {
                    let a = try ops.newBlock(
                        in: post.id, text: String(repeating: "a", count: count), at: .end)
                    _ = try ops.branchVariant(a.block.id, from: a.variant.id)
                    _ = try ops.addBlockComment(to: a.block.id, text: "One.")
                    blocks.append(a.block.id)
                }
                return (post.id, blocks)
            }
            let (model, surface) = await makeSurface(session, postID: seed.post)
            let view = surface.textView
            guard let chrome = view.takesChrome, let decor = view.blockDecor else {
                Issue.record("chrome not installed")
                return
            }
            _ = model
            // The second chrome pass the app takes on its own (the standing
            // decor→chrome ordering; see the pin above), then settle rounds
            // (exclusion → relayout → chrome) until the geometry stops
            // moving, as the app's own layout ticks would — the STEADY
            // state is what this pin asserts (the one-tick pre-exclusion
            // transient is the standing recorded behavior).
            view.refreshChrome()
            for _ in 0..<4 {
                surface.layoutIfNeeded()
                view.refreshChrome()
            }

            // PROBE VERDICT (2026-08-09, iPhone 17 Pro / iOS 26.2, recorded
            // per the pin-first rule): GREEN — TK2 applies
            // lineFragmentPadding (5 pt) against exclusion-path edges, so
            // glyphs stop at cw−56−5 = 302 (max one-line endX measured
            // 299.25; the next candidate wraps) while crossing needs
            // endX > cw−59 = 304 — the reviewer's ~3 pt window is EMPTY,
            // worst-case clearance ≥ 2 pt. The ●12 marker's fitted width
            // is ALSO 30.0 (the button's insets floor) — no multi-digit
            // widening at 12. `commentMarkRoom` stands at 26.
            var oneLiners = 0
            for blockID in seed.blocks {
                let badge = try #require(chrome.badgeView(for: blockID))
                let mark = try #require(decor.commentMark(for: blockID))
                // A one-liner iff the marker (LAST line) shares the badge's
                // (FIRST line's) vertical band — the crossing precondition.
                guard mark.frame.maxY > badge.frame.minY,
                      mark.frame.minY < badge.frame.maxY else { continue }
                oneLiners += 1
                #expect(!mark.frame.intersects(badge.frame),
                        "flush-end one-liner: marker \(mark.frame) crosses badge \(badge.frame)")
            }
            #expect(oneLiners > 0,
                    "the probe produced no one-liner — recompute the candidate band")
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
            // Both fanned blocks carry badges and tail reservations (full
            // passes ran at load); the far one sits far outside the
            // 700 pt viewport.
            #expect(chrome.badgeView(for: seed.near) != nil)
            #expect(chrome.badgeView(for: seed.far) != nil)
            let nearRange = try #require(model.rangeOfBlock(seed.near))
            let farRange = try #require(model.rangeOfBlock(seed.far))
            #expect(tailReservation(view, at: nearRange.location)
                    == MobileTakesChromeController.gutterWidth)
            #expect(tailReservation(view, at: farRange.location)
                    == MobileTakesChromeController.gutterWidth)
            #expect(view.contentSize.height > 2_000, "the post must dwarf the viewport")

            // The per-tick scope: the near block resolves, the FAR one is
            // never layout-forced — yet its reservation survives (storage
            // truth needs no geometry to verify).
            chrome.refresh(scope: .nearViewport)
            #expect(chrome.lastGeometryResolvedBlockIDs.contains(seed.near))
            #expect(!chrome.lastGeometryResolvedBlockIDs.contains(seed.far),
                    "a scroll tick must not force layout of far-off-screen fragments (P-8; TEXTKIT2 §2)")
            #expect(chrome.badgeView(for: seed.far) != nil)
            #expect(tailReservation(view, at: farRange.location)
                    == MobileTakesChromeController.gutterWidth,
                    "the off-band reservation survives — storage truth, undisturbed by a tick")

            // The full pass (every content/geometry input axis) resolves
            // both — the scope discriminates, the vocabulary doesn't shrink.
            chrome.refresh(scope: .document)
            #expect(chrome.lastGeometryResolvedBlockIDs.contains(seed.near))
            #expect(chrome.lastGeometryResolvedBlockIDs.contains(seed.far))
            #expect(model.identityAuditFailures == 0)
            #expect(!view.canaryFired)
        }
    }

    /// FB2-1 (parity B3 — the fix's mechanism pin; P-8's invalidation law
    /// on the EDIT road): a typed character's chrome pass is EDIT-scoped
    /// (the near-viewport band ∪ the edited range) — a keystroke never
    /// forces layout of far-off-screen decorated blocks; the container
    /// carries NO exclusion paths (FB2-1's ROOT: their presence alone
    /// made every keystroke's relayout document-scale — the B3 probe's
    /// numbers ride the batch record — so none may ever return to this
    /// surface); and a pass whose reservations all held writes NOTHING
    /// (the far block's governing style is the very same object after
    /// the keystroke — a write would mint a fresh one and invalidate
    /// its paragraph). RED-ON-OLD on the FAR-NOT-RESOLVED half: pre-B3,
    /// `storageDidEdit` refreshed `.document`, so every keystroke
    /// geometry-forced the far block — run red on that tree before the
    /// fix landed. The write-free and no-exclusions halves are GUARDS
    /// against regrowth, not the discriminator (recorded per the
    /// hallucination guard).
    @Test func aKeystrokesChromePassIsEditScopedAndWriteFreeWhenNothingMoved() async throws {
        try await withEditorWorld { session, db in
            let seed = try await session.runner.run { ops in
                let post = try ops.createPost(title: "edit-scope", profile: .blog)
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
            #expect(view.contentSize.height > 2_000, "the post must dwarf the viewport")
            // Settle to steady state (the app's own reservation→relayout
            // cadence — the FIX-3 probe's rounds), then photograph the
            // far block's governing style instance.
            view.refreshChrome()
            for _ in 0..<4 {
                surface.layoutIfNeeded()
                view.refreshChrome()
            }
            let farBefore = try #require(model.rangeOfBlock(seed.far))
            #expect(tailReservation(view, at: farBefore.location)
                    == MobileTakesChromeController.gutterWidth)
            let styleBefore = governingStyle(view, at: farBefore.location)

            // ONE typed character inside the near block, through the
            // policed road (gate → storage → storageDidEdit → the chrome
            // pass under test). Nothing pumps another layout pass before
            // the assertions — the keystroke's own pass is what's read.
            guard let range = model.rangeOfBlock(seed.near), range.length > 1 else {
                Issue.record("no surface range for the near block")
                return
            }
            typeEdit(
                model, view.textStorage,
                range: NSRange(location: range.location + 1, length: 0), replacement: "x")

            // The edit road's scope: the near (in-band, edited) block may
            // resolve; the FAR block is never layout-forced by a keystroke…
            #expect(!chrome.lastGeometryResolvedBlockIDs.contains(seed.far),
                    "a keystroke must never force far-off-screen layout (FB2-1; P-8)")
            // …its chrome survives (badge frame content-anchored,
            // reservation storage truth)…
            #expect(chrome.badgeView(for: seed.far) != nil)
            let farAfter = try #require(model.rangeOfBlock(seed.far))
            #expect(tailReservation(view, at: farAfter.location)
                    == MobileTakesChromeController.gutterWidth)
            // …the container carries NO exclusion paths (FB2-1's root —
            // presence alone is the document-scale relayout class)…
            #expect(view.textContainer.exclusionPaths.isEmpty,
                    "container exclusion paths may never return to this surface (FB2-1)")
            // …and a pass whose reservations all held wrote NOTHING (a
            // write mints a fresh style object and invalidates the
            // paragraph).
            #expect(governingStyle(view, at: farAfter.location) === styleBefore,
                    "an unchanged reservation must never be re-written — the write is the invalidation")
            #expect(model.identityAuditFailures == 0)
            #expect(!view.canaryFired)
        }
    }

    /// FIX-B1 road (a) (Stage B ladder round 1, MINOR 1 — the split
    /// residue): typing Enter INSIDE a fanned block's first paragraph
    /// (I4: the newline is content, not structure) splits it, and the
    /// continuation paragraph's characters still carry the reservation's
    /// `tailIndent` — the governing-character equality gate reads only
    /// the FIRST paragraph, and cleanup on fan-death cleared only the
    /// first paragraph too, so nothing ever healed the strand: every
    /// continuation line rendered 30+ pt short until a full
    /// re-materialization. The reservation walk now HEALS the block's
    /// non-first paragraphs to zero on every pass (band-independent,
    /// equality-gated — a clean continuation paragraph is never
    /// re-written). RED-ON-OLD: born before the fix and run red on the
    /// unfixed tree; re-verified by behavioral revert (heal removed →
    /// the continuation paragraph reads the stranded −30).
    @Test func aMidParagraphReturnNeverStrandsTheReservationOnTheContinuationParagraph() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedWrappingFannedPost(session)
            let (model, surface) = await makeSurface(session, postID: seed.postID)
            let view = surface.textView
            // Settled: the fanned block's first paragraph carries the gutter.
            let before = try #require(model.rangeOfBlock(seed.blockA))
            #expect(tailReservation(view, at: before.location)
                    == MobileTakesChromeController.gutterWidth)

            // The mid-paragraph Enter, through the policed road — the
            // storage edit's own chrome pass (`.edit`-scoped; the
            // reservation walk is band-independent) is what must heal.
            typeEdit(
                model, view.textStorage,
                range: NSRange(location: before.location + 5, length: 0),
                replacement: "\n")

            let after = try #require(model.rangeOfBlock(seed.blockA))
            #expect(after.length == before.length + 1, "the newline is block content (I4)")
            // The continuation paragraph's governing character sits right
            // after the typed newline.
            let continuation = before.location + 6
            #expect(tailReservation(view, at: continuation) == 0,
                    "the continuation paragraph must not keep the first paragraph's reservation")
            // The first paragraph keeps its gutter — the heal never
            // over-clears the reservation itself.
            #expect(tailReservation(view, at: after.location)
                    == MobileTakesChromeController.gutterWidth)
            #expect(model.identityAuditFailures == 0)
            #expect(!view.canaryFired)
        }
    }

    /// FIX-B1 road (b) (Stage B ladder round 1, MINOR 1 — the separator
    /// inheritance): the separator after a one-paragraph fanned block
    /// carries the block's reservation style — and CANNOT be kept clean:
    /// NSTextStorage attribute FIXING re-propagates the paragraph's
    /// governing style across the whole paragraph, terminator included
    /// (measured by the fix session's probe; a write clamped to exclude
    /// the terminator reads back styled). UIKit re-derives
    /// `typingAttributes` from the character before the caret, so text
    /// typed in the open tail — and every block crystallized from it —
    /// inherited a permanent 30 pt dent in paragraphs the reservation
    /// walk never visits. The fix heals the LANDING: the `.edit` road's
    /// chrome pass zeroes reservation fields across the edited range's
    /// ungoverned paragraphs, so the derived dent never survives its own
    /// keystroke. The walk simulates the documented derivation the way
    /// FB1-1's rule simulates the keyboard: the typed character carries
    /// the style read off the actual preceding character (windowless
    /// `insertText` bypasses `typingAttributes`, so the real derivation
    /// cannot be exercised headless). RED-ON-OLD: born before the fix
    /// and run red on the unfixed tree; re-verified by behavioral
    /// revert (residue heal removed → the tail keeps the dent).
    @Test func aTailTypedAfterAFannedBlockNeverInheritsTheReservation() async throws {
        try await withEditorWorld { session, _ in
            // The fanned block is the post's LAST block — the open tail
            // follows its separator (her exact case).
            let seed = try await session.runner.run { ops -> (postID: String, blockA: String) in
                let post = try ops.createPost(title: "tail-dent", profile: .blog)
                let a = try ops.newBlock(
                    in: post.id, text: "A" + String(repeating: "abcdefghij", count: 20), at: .end)
                let take = try ops.branchVariant(a.block.id, from: a.variant.id)
                try ops.autosave(take.id, text: "The other take of A.", charDelta: 5)
                return (post.id, a.block.id)
            }
            let (model, surface) = await makeSurface(session, postID: seed.postID)
            let view = surface.textView
            let storage = view.textStorage
            let rangeA = try #require(model.rangeOfBlock(seed.blockA))
            #expect(tailReservation(view, at: rangeA.location)
                    == MobileTakesChromeController.gutterWidth)

            // Open the tail (the gate road — ⏎ at the document's end);
            // the typed newline is the separator.
            typeEdit(model, storage,
                     range: NSRange(location: storage.length, length: 0), replacement: "\n")
            let separator = storage.length - 1
            #expect((storage.string as NSString)
                .substring(with: NSRange(location: separator, length: 1)) == "\n")

            // The derivation's feed: the separator carries the block's
            // reservation (attribute fixing — the probe's measured truth;
            // a clean feed would make this pin vacuous, so it is guarded).
            let derived = governingStyle(view, at: separator)
            #expect(-(derived?.tailIndent ?? 0) == MobileTakesChromeController.gutterWidth,
                    "the probe is dead — the separator no longer carries the style this pin exists to contain")

            // Type into the tail CARRYING the derived style (the
            // documented typingAttributes derivation, simulated from the
            // real preceding character per FB1-1's walk rule).
            var attributes: [NSAttributedString.Key: Any] = [.font: MobileEditorStyle.baseFont]
            if let derived { attributes[.paragraphStyle] = derived }
            let typedAt = storage.length
            let allowed = model.shouldChangeText(
                in: NSRange(location: typedAt, length: 0), replacement: "x", isPaste: false)
            #expect(allowed, "the tail must accept typing")
            storage.replaceCharacters(
                in: NSRange(location: typedAt, length: 0),
                with: NSAttributedString(string: "x", attributes: attributes))

            // The landing is healed in its own keystroke's pass: the tail
            // character carries NO reservation…
            #expect(tailReservation(view, at: typedAt) == 0,
                    "a tail typed after a fanned block must not inherit its reservation")
            // …while the fanned block keeps its own gutter untouched.
            #expect(tailReservation(view, at: rangeA.location)
                    == MobileTakesChromeController.gutterWidth)
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
