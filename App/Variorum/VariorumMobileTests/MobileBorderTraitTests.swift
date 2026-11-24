//
//  MobileBorderTraitTests.swift
//  VariorumMobileTests
//
//  VM-54 (the VM-47 run, batch 3) — **borders follow a light or dark switch.**
//  The take cards (live and archived), the takes pill and the comment draft
//  set `layer.borderColor` — a fixed `CGColor` — from a dynamic colour at
//  `apply` time, and nothing re-resolved it when the appearance changed
//  (`MobileTraitBorder`'s header has the mechanism). Each pin hosts the real
//  view in a real window, applies it in LIGHT, drives a real appearance
//  change through the window's override, and reads the layer's border back:
//  it must be the colour's DARK value.
//
//  RED ON OLD (the run record §6, proven in a snapshot worktree): before the
//  fix each border keeps its light value after the flip.
//

import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-54 — borders follow a light or dark switch")
struct MobileBorderTraitTests {
    /// sRGB components of a CGColor (nil reads as empty).
    private func rgb(_ color: CGColor?) -> [Int] {
        guard let color else { return [] }
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        _ = UIColor(cgColor: color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue].map { Int(($0 * 255).rounded()) }
    }

    private func rgb(_ color: UIColor, dark: Bool) -> [Int] {
        rgb(color.resolvedColor(
            with: UITraitCollection(userInterfaceStyle: dark ? .dark : .light)).cgColor)
    }

    /// A light-overridden window hosting `view` at a working size.
    private func hostLight(_ view: UIView, size: CGSize = CGSize(width: 360, height: 120)) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
        window.overrideUserInterfaceStyle = .light
        let host = UIViewController()
        window.rootViewController = host
        host.view.addSubview(view)
        view.frame = CGRect(origin: CGPoint(x: 16, y: 80), size: size)
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        return window
    }

    /// The appearance change, driven the way the system delivers it: the
    /// window's style flips and its traits propagate down the hierarchy.
    private func flipToDark(_ window: UIWindow, _ view: UIView) {
        window.overrideUserInterfaceStyle = .dark
        window.layoutIfNeeded()
        view.updateTraitsIfNeeded()
        view.layoutIfNeeded()
    }

    @Test func aTakeCardsEdgeFollowsTheFlip() {
        let face = MobileEditorStyle.terminalFace
        for chosen in [false, true] {
            let expected = chosen ? face.chosenMark : face.line
            #expect(rgb(expected, dark: false) != rgb(expected, dark: true), "precondition")
            let card = MobileTakesCardView(
                variantID: "v-\(chosen)", onEdit: {}, onChoose: {}, onArchive: {}, onDelete: {})
            let window = hostLight(card)
            defer { window.isHidden = true }
            card.apply(
                card: .init(
                    variantID: "v-\(chosen)", ordinal: 1, text: "A take.", label: nil,
                    isChosen: chosen, isPeeked: false, isLocked: false),
                face: face, live: false, chromeCase: { $0 })
            #expect(rgb(card.layer.borderColor) == rgb(expected, dark: false), "light first")

            flipToDark(window, card)
            #expect(rgb(card.layer.borderColor) == rgb(expected, dark: true),
                    "the card's edge followed the flip (chosen: \(chosen))")
        }
    }

    @Test func anArchivedCardsEdgeFollowsTheFlip() {
        let face = MobileEditorStyle.studyFace
        #expect(rgb(face.line, dark: false) != rgb(face.line, dark: true), "precondition")
        let card = MobileArchivedTakeCardView(variantID: "a", onUnarchive: {}, onDelete: {})
        let window = hostLight(card)
        defer { window.isHidden = true }
        card.apply(card: .init(variantID: "a", text: "Old words.", label: nil),
                   face: face, chromeCase: { $0 })
        #expect(rgb(card.layer.borderColor) == rgb(face.line, dark: false))

        flipToDark(window, card)
        #expect(rgb(card.layer.borderColor) == rgb(face.line, dark: true),
                "the archived card's edge followed the flip")
    }

    @Test func theTakesPillsEdgeFollowsTheFlip() {
        let face = MobileEditorStyle.terminalFace
        #expect(rgb(face.takeLine, dark: false) != rgb(face.takeLine, dark: true), "precondition")
        let pill = MobileTakesPillView(onPrevious: {}, onNext: {}, onChoose: {})
        let window = hostLight(pill, size: CGSize(width: 160, height: 32))
        defer { window.isHidden = true }
        pill.apply(content: .init(text: "take 2/3", canChoose: true), face: face)
        #expect(rgb(pill.layer.borderColor) == rgb(face.takeLine, dark: false))

        flipToDark(window, pill)
        #expect(rgb(pill.layer.borderColor) == rgb(face.takeLine, dark: true),
                "the pill's edge followed the flip")
    }

    /// The comment draft lives inside the comments sheet, mounted the app's way
    /// (the Write surface's own overlay, opened by the model's door).
    @Test func theCommentDraftsEdgeFollowsTheFlip() async throws {
        try await withEditorWorld { session, _ in
            let seeded = try await session.runner.run { ops in
                let post = try ops.createPost(title: "bordered", profile: .blog)
                let block = try ops.newBlock(in: post.id, text: "A block to comment on.", at: .end)
                return (post.id, block.block.id)
            }
            let (model, surface) = await makeSurfaceEditor(session, postID: seeded.0)
            let window = hostLight(surface, size: CGSize(width: 393, height: 700))
            defer { window.isHidden = true }
            surface.frame = window.bounds
            window.layoutIfNeeded()
            model.openComments(blockID: seeded.1)
            window.layoutIfNeeded()
            let sheet = try #require(surface.textView.commentsSheetView)
            func find(_ identifier: String, in root: UIView) -> UIView? {
                if root.accessibilityIdentifier == identifier { return root }
                for child in root.subviews {
                    if let hit = find(identifier, in: child) { return hit }
                }
                return nil
            }
            let draft = try #require(find("comments.draft", in: sheet))
            let line = MobileEditorStyle.face.line
            #expect(rgb(line, dark: false) != rgb(line, dark: true), "precondition")
            #expect(rgb(draft.layer.borderColor) == rgb(line, dark: false), "light first")

            flipToDark(window, draft)
            #expect(rgb(draft.layer.borderColor) == rgb(line, dark: true),
                    "the comment draft's edge followed the flip")
        }
    }
}
