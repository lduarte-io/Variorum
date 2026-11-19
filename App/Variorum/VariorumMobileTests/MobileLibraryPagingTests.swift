//
//  MobileLibraryPagingTests.swift
//  VariorumMobileTests
//
//  VM-68 (the VM-64 run, batch 5) — **THE LIBRARY PAGES; A PAGE, NEVER A CAP.**
//  The record is `notes/plans/fixes/vm-64-timing-and-lags.md` (§4 batch 5; §7
//  its closeout).
//
//  These pins drive the REAL Library the way she does — mounted in a key
//  window, scrolled — and read only what is on screen, so they compile and run
//  against the pre-VM-68 phone code as well: the two paging pins are RED there
//  (the note listing cut silently at 200, the Bookless one at its window) and
//  the return pin is a GUARD, green on both (the old listing was held live
//  while hidden; the new one re-asks on return). The model's own rules are
//  `MobileLibraryPagingRulesTests`.
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// The listing's scroll view: the deepest-content `UIScrollView` under a view
/// (the Library's `ScrollView` over its `LazyVStack`).
@MainActor
private func listScrollView(in view: UIView) -> UIScrollView? {
    var best: UIScrollView?
    func walk(_ node: UIView) {
        if let scroll = node as? UIScrollView,
           scroll.contentSize.height > (best?.contentSize.height ?? 0) {
            best = scroll
        }
        for sub in node.subviews { walk(sub) }
    }
    walk(view)
    return best
}

/// **Scrolls the listing down a screen at a time, the way a thumb does**,
/// collecting every row label that comes on screen, until `done` says so or
/// the list stops growing at its end (a few still turns at the bottom).
@MainActor
private func scrollCollecting<Content: View>(
    _ surface: HostedSurface<Content>, maxSteps: Int = 400,
    until done: (Set<String>) -> Bool
) async -> Set<String> {
    var seen = Set(surface.visibleLabels)
    var stillAtBottom = 0
    var steps = 0
    while !done(seen), stillAtBottom < 6, steps < maxSteps {
        steps += 1
        guard let scroll = listScrollView(in: surface.host.view) else { break }
        let bottom = max(
            0, scroll.contentSize.height - scroll.bounds.height + scroll.adjustedContentInset.bottom)
        let target = min(bottom, scroll.contentOffset.y + scroll.bounds.height * 0.7)
        let atBottom = scroll.contentOffset.y >= bottom - 1
        scroll.setContentOffset(CGPoint(x: 0, y: target), animated: false)
        await surface.settle(6)
        let before = seen.count
        seen.formUnion(surface.visibleLabels)
        stillAtBottom = (atBottom && seen.count == before) ? stillAtBottom + 1 : 0
    }
    return seen
}

@MainActor
@Suite("VM-68 — the Library pages: every note reachable by scrolling", .serialized)
struct MobileLibraryPagingTests {
    /// The shelf model the Library wears for its books (the filter suite's own
    /// road: a harness mounting the Library alone starts it).
    private func startedShelf(_ session: AppSession) async -> (MobileShelfViewModel, Task<Void, Never>) {
        let shelf = MobileShelfViewModel(session: session)
        let observing = Task { await shelf.start() }
        await shelf.refreshTags()
        return (shelf, observing)
    }

    private nonisolated static func title(_ index: Int) -> String { String(format: "Paged note %03d", index) }

    /// **THE 201ST NOTE IS REACHABLE BY SCROLLING** — W-037, her "a page, never
    /// a cap" (the Mac's 17y B1 (k) letter: *"we need an area in which people
    /// can scroll through ALL of their notes"*). 230 notes, each touched in
    /// turn, so the newest-first listing runs 229 → 0; the Library is mounted
    /// as the app mounts it (its default page) and scrolled to its end.
    ///
    /// *RED ON THE PRE-VM-68 CODE:* the held `observeLibrary(limit: 200)` cut
    /// the listing at the 200th note with no marker and no road — notes 029 …
    /// 000 never came on screen.
    @Test func theTwoHundredAndFirstNoteIsReachableByScrolling() async throws {
        try await withEditorWorld { session, _ in
            try await session.runner.run { ops in
                for index in 0..<230 {
                    let post = try ops.createPost(title: Self.title(index))
                    _ = try ops.newBlock(in: post.id, text: "Words \(index).", at: .end)
                }
            }
            let library = MobileLibraryViewModel(session: session)
            let (shelf, observing) = await startedShelf(session)
            defer { observing.cancel() }

            await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: MobileScrapsModel(session: session),
                    stars: MobileStarsModel(session: session), books: shelf,
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                await surface.settle(40)
                #expect(surface.visibleLabels.contains { $0.hasPrefix(Self.title(229)) },
                        "the newest note leads — labels were \(Array(surface.visibleLabels.prefix(20)))")
                let seen = await scrollCollecting(surface) { labels in
                    labels.contains { $0.hasPrefix(Self.title(0)) }
                }
                #expect(seen.contains { $0.hasPrefix(Self.title(29)) },
                        "the 201st note never came on screen — the listing stops at 200")
                #expect(seen.contains { $0.hasPrefix(Self.title(0)) },
                        "the oldest note never came on screen")
                let listed = (0..<230).filter { index in
                    seen.contains { $0.hasPrefix(Self.title(index)) }
                }
                #expect(listed.count == 230, "every note came on screen once scrolled: \(listed.count) of 230")
            }
        }
    }

    /// **THE BOOKLESS DOOR PAGES TOO** — the Pool's phone home lists every
    /// loose note, not its first window. Twelve loose notes, three in a book,
    /// a page of five.
    ///
    /// *RED ON THE PRE-VM-68 CODE:* `Queries.poolPosts(limit: 5)` was the whole
    /// listing — the seven oldest loose notes were unreachable.
    @Test func theBooklessDoorListsEveryLooseNote() async throws {
        try await withEditorWorld { session, _ in
            try await session.runner.run { ops in
                let book = try ops.createReading(name: "Shelved", kind: .book)
                for index in 0..<15 {
                    let post = try ops.createPost(title: String(format: "Loose %02d", index))
                    _ = try ops.newBlock(in: post.id, text: "Words.", at: .end)
                    if index % 5 == 2 { _ = try ops.addPostToReading(post.id, to: book.id) }
                }
            }
            let library = MobileLibraryViewModel(session: session, listingLimit: 5)
            library.filter = .bookless
            let (shelf, observing) = await startedShelf(session)
            defer { observing.cancel() }

            await withHostedSurface(
                MobileLibraryView(
                    model: library, scraps: MobileScrapsModel(session: session),
                    stars: MobileStarsModel(session: session), books: shelf,
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            ) { surface in
                await surface.settle(40)
                let seen = await scrollCollecting(surface) { labels in
                    labels.contains { $0.hasPrefix("Loose 00") }
                }
                let loose = (0..<15).filter { $0 % 5 != 2 }
                for index in loose {
                    #expect(seen.contains { $0.hasPrefix(String(format: "Loose %02d", index)) },
                            "loose note \(index) never came on screen")
                }
                for index in (0..<15).filter({ $0 % 5 == 2 }) {
                    #expect(!seen.contains { $0.hasPrefix(String(format: "Loose %02d", index)) },
                            "a note in a book rows under Bookless: \(index)")
                }
            }
        }
    }

    /// **THE RETURN IS CURRENT** — a GUARD, green on both sides: a note minted
    /// while the Library is off screen in the band (the box files from the
    /// Shelf; a sync apply lands) is listed when she swipes back. Before VM-68
    /// the hidden listing was held and caught it live; since, nothing is held
    /// while hidden and the return re-asks.
    @Test func aNoteMintedWhileTheLibraryIsAwayIsListedWhenSheReturns() async throws {
        try await withEditorWorld { session, _ in
            try await session.runner.run { ops in
                for index in 0..<4 {
                    let post = try ops.createPost(title: "Standing note \(index)")
                    _ = try ops.newBlock(in: post.id, text: "Words.", at: .end)
                }
            }
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: MobileShellRouter())
            ) { surface in
                await surface.settle(40)
                // Away on the Shelf: a note arrives.
                try await session.runner.run { ops in
                    let post = try ops.createPost(title: "Arrived while away")
                    _ = try ops.newBlock(in: post.id, text: "New words.", at: .end)
                }
                await surface.settle(20)
                #expect(surface.activate("Library"), "the Library's tab door")
                await surface.settle(40)
                let labels = surface.visibleLabels
                #expect(labels.contains { $0.hasPrefix("Arrived while away") },
                        "the return shows a stale listing — labels were \(Array(labels.prefix(20)))")
                #expect(labels.contains { $0.hasPrefix("Standing note 3") })
            }
        }
    }
}
