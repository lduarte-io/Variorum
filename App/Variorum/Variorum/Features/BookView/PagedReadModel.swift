//
//  PagedReadModel.swift
//  Variorum
//
//  READ's TRUE PAGINATION — the model (13c Batch 2C). It owns the page
//  domain (`PageIndex`, estimated), the realized paginators (`PagePaginator`,
//  exact), and the reader's ADDRESS. It fetches text for the posts it is
//  showing and for nothing else.
//
//  ── THE THREE RULES THIS MODEL EXISTS TO KEEP ────────────────────────────
//  1. **The reader's address is (post, page-in-post), never a page number.**
//     A measurement that corrects the domain moves the LABEL under her, not
//     the text (`PageDomain.swift`'s header has the full argument).
//  2. **Realization is a pure function of the address.** `neededPosts` says
//     which posts a spread requires — at most two — and nothing else is
//     fetched, composed or paginated (Stage 4 lesson 6; P1).
//  3. **Where a POST begins, a page begins.** A post never starts halfway
//     down a page, so pagination is anchored per post and a correction can
//     never reflow a page the reader has already been shown. The alternative
//     (posts flowing into one another) is the brief's stated lean and is
//     recorded as PROVISIONAL — QUESTIONS #45(b) — with the reason it was
//     not taken: it makes every page after a corrected estimate reflow, and
//     computing it honestly means measuring the whole chapter up front,
//     which is the P1-banned shape.
//

import AppKit
import Foundation
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class PagedReadModel {
    @ObservationIgnored let session: AppSession
    @ObservationIgnored let geometry: PageGeometry
    @ObservationIgnored let typography: PageTypography

    private(set) var index: PageIndex
    private(set) var position = PageIndex.Position(postIndex: 0, pageInPost: 0)
    private(set) var lastError: String?

    /// The book's posts, in reading order (adopted from the book model).
    private(set) var entries: [Queries.ReadingEntry] = []
    private var chapterOpeners: [String: String] = [:]

    /// The realized posts. Bounded: reading forward evicts what is behind.
    private var paginators: [String: PagePaginator] = [:]
    private var recency: [String] = []
    static let cacheLimit = 4

    /// The ink the pages are composed with; a scheme flip recomposes.
    var appearance: PageAppearance {
        didSet {
            guard appearance != oldValue else { return }
            paginators.removeAll()
            recency.removeAll()
            Task { await realize() }
        }
    }

    struct PageAppearance: Equatable {
        var ink: NSColor
        var chapterInk: NSColor
        var meta: NSColor
        static let fallback = PageAppearance(
            ink: .textColor, chapterInk: .secondaryLabelColor, meta: .tertiaryLabelColor)
    }

    init(
        session: AppSession,
        geometry: PageGeometry = .standard,
        typography: PageTypography = .standard,
        appearance: PageAppearance = .fallback
    ) {
        self.session = session
        self.geometry = geometry
        self.typography = typography
        self.appearance = appearance
        index = PageIndex(metrics: typography.metrics(for: geometry))
    }

    // MARK: - The domain

    /// Adopt the book: its post order and which posts OPEN a chapter. Reads
    /// the extent index (lengths only — no prose) and rebuilds the estimated
    /// domain; measured posts keep their measurement.
    ///
    /// **The address survives by IDENTITY, not by index (13c K6 review,
    /// K1).** `Position.postIndex` is a position in `entries`, so a
    /// membership insertion — or an A31 order flip — used to shift every
    /// later index and leave the address naming a DIFFERENT post: the page
    /// under the reader silently became another post's page, which is
    /// precisely the failure the (post, page-in-post) address rule exists to
    /// prevent. The shown post's ID is captured before the list changes and
    /// its index re-derived from the new list; the clamp remains only for
    /// the post that left the book (she lands on a page that still exists,
    /// never nowhere).
    func adopt(entries: [Queries.ReadingEntry], chapterOpeners: [String: String]) async {
        let anchorPostID = self.entries.indices.contains(position.postIndex)
            ? self.entries[position.postIndex].postID : nil
        self.entries = entries
        self.chapterOpeners = chapterOpeners
        let postIDs = entries.map(\.postID)
        do {
            let extents = try await session.database.read { db in
                try Queries.blockExtents(db, containerIDs: postIDs)
            }
            var headings: [String: Double] = [:]
            for entry in entries {
                headings[entry.postID] = PageComposer.headingLines(
                    hasChapter: chapterOpeners[entry.postID] != nil)
            }
            index.adopt(postIDs: postIDs, extents: extents, headingLines: headings)
            if let anchorPostID,
               let newIndex = entries.firstIndex(where: { $0.postID == anchorPostID }) {
                position = PageIndex.Position(
                    postIndex: newIndex, pageInPost: position.pageInPost)
            }
            if let clamped = index.clamped(position) { position = clamped }
            await realize()
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    // MARK: - Realization (the P1 half)

    /// The pages a spread at `position` needs — at most two, and exactly the
    /// two it draws, each named by (post, page-within-post). PURE (the
    /// realization-bound discipline: the realized set is a function of its
    /// inputs, so a pin can state it).
    static func neededPages(
        at position: PageIndex.Position, index: PageIndex, entries: [Queries.ReadingEntry]
    ) -> [(postID: String, pageInPost: Int)] {
        [position, index.next(position)].compactMap { address -> (String, Int)? in
            guard let address, entries.indices.contains(address.postIndex) else { return nil }
            return (entries[address.postIndex].postID, address.pageInPost)
        }
    }

    /// The posts behind those pages — at most two.
    static func neededPosts(
        at position: PageIndex.Position, index: PageIndex, entries: [Queries.ReadingEntry]
    ) -> [String] {
        var posts: [String] = []
        for page in neededPages(at: position, index: index, entries: entries)
        where !posts.contains(page.postID) {
            posts.append(page.postID)
        }
        return posts
    }

    /// Compose and slice whatever the current spread needs, teach the domain
    /// what slicing found, and settle the address.
    ///
    /// **Slicing is LAZY** — only as far as the reader has walked, plus the
    /// one page ahead a turn needs. `PagePaginator`'s header carries the
    /// measurement that makes this non-negotiable: for ordinary prose whole-
    /// post pagination is milliseconds, but for a long message pasted as ONE
    /// unbroken block (the A3/A41 shape) it is 1.67 s at 25k words, because
    /// CoreText re-typesets a paragraph from its start. Cost must be ∝ what
    /// she is reading, not ∝ what she might read.
    ///
    /// Runs at most a few turns: a discovered page count can change which
    /// post the RIGHT leaf falls in, and the new post then needs slicing too.
    func realize() async {
        for _ in 0..<3 {
            var changed = false
            for page in Self.neededPages(at: position, index: index, entries: entries) {
                var paginator = paginators[page.postID]
                if paginator == nil {
                    paginator = await paginate(page.postID)
                    changed = true
                }
                guard let paginator else { continue }
                let known = paginator.knownPageCount
                // One page beyond what is drawn, so a turn knows whether the
                // post ends here without re-entering this loop.
                paginator.slice(through: page.pageInPost + 1)
                remember(page.postID, paginator)
                let alreadyMeasured =
                    index.entries.first { $0.postID == page.postID }?.isMeasured ?? false
                if paginator.isComplete {
                    if !alreadyMeasured {
                        index.adoptMeasured(
                            postID: page.postID, pages: paginator.knownPageCount)
                        changed = true
                    }
                } else if paginator.knownPageCount > known {
                    index.noteAtLeast(postID: page.postID, pages: paginator.knownPageCount)
                    changed = true
                }
            }
            if let clamped = index.clamped(position), clamped != position {
                position = clamped
                changed = true
            }
            if !changed { return }
        }
    }

    private func paginate(_ postID: String) async -> PagePaginator? {
        do {
            // The READ carries only Sendable projection rows off the pool
            // thread (P2); composition and layout are main-actor CPU over
            // ONE post — the fonts and colors never cross a thread.
            let projection = try await session.database.read { db in
                Projection(
                    slots: try Queries.renderPost(db, containerID: postID),
                    presentations: try Queries.blockPresentations(db, containerID: postID))
            }
            let entry = entries.first { $0.postID == postID }
            let composed = PageComposer.compose(
                slots: projection.slots, presentations: projection.presentations,
                title: entry.map(PagedReadModel.pageTitle), chapter: chapterOpeners[postID],
                typography: typography, ink: appearance.ink,
                chapterInk: appearance.chapterInk)
            return PagePaginator(composed: composed, contentRect: geometry.contentRect)
        } catch is CancellationError {
            return nil
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }

    private struct Projection: Sendable {
        let slots: [Queries.RenderedBlock]
        let presentations: [String: BlockPresentation]
    }

    private func remember(_ postID: String, _ paginator: PagePaginator) {
        paginators[postID] = paginator
        recency.removeAll { $0 == postID }
        recency.append(postID)
        while recency.count > Self.cacheLimit, let oldest = recency.first {
            recency.removeFirst()
            paginators.removeValue(forKey: oldest)
        }
    }

    /// How many posts are realized right now — the hosted pin's read.
    var realizedPostCount: Int { paginators.count }
    /// How many pages of this post slicing has actually cut — the lazy-
    /// slicing pin's read (a post opened at page 1 must not have been
    /// paginated to its end).
    func slicedPages(of postID: String) -> Int? { paginators[postID]?.knownPageCount }

    // MARK: - The spread

    /// One drawable page.
    struct Leaf: Identifiable {
        let address: PageIndex.Position
        let postID: String
        let pageNumber: Int
        let frame: CTFrame?
        var id: String { "\(postID)#\(address.pageInPost)" }
    }

    /// The spread's two leaves — the second is nil at the end of the book
    /// (a blank leaf, never a page wrapped round from the other end; the 2B
    /// rule, restated for a text domain).
    var leaves: [Leaf?] {
        let addresses = [position, index.next(position)]
        return addresses.map { address -> Leaf? in
            guard let address, entries.indices.contains(address.postIndex),
                  let number = index.pageNumber(of: address)
            else { return nil }
            let postID = entries[address.postIndex].postID
            return Leaf(
                address: address, postID: postID, pageNumber: number,
                frame: paginators[postID]?.frame(forPage: address.pageInPost))
        }
    }

    // MARK: - Navigation (all over the domain — never geometry)

    func canTurn(by pages: Int) -> Bool {
        index.advance(position, by: pages) != nil
    }

    func turn(by pages: Int) {
        guard let landing = index.advance(position, by: pages) else { return }
        position = landing
        Task { await realize() }
    }

    /// The scrubber's landing: a fraction of the ESTIMATED page domain.
    func scrub(fraction: Double) {
        guard index.totalPages > 0 else { return }
        let clamped = min(max(fraction, 0), 1)
        let number = max(1, min(index.totalPages, Int(clamped * Double(index.totalPages)) + 1))
        guard let landing = index.position(atPageNumber: number), landing != position else {
            return
        }
        position = landing
        Task { await realize() }
    }

    /// The navigator's jump: open this post at its first page. A post already
    /// on the spread is left alone (2B's rule — jumping to what you are
    /// reading must not move it).
    func showPost(_ postID: String) {
        guard let target = entries.firstIndex(where: { $0.postID == postID }) else { return }
        if leaves.compactMap({ $0?.postID }).contains(postID) { return }
        position = PageIndex.Position(postIndex: target, pageInPost: 0)
        Task { await realize() }
    }

    /// Enter where she was: the post the book model holds focus on.
    func seed(fromFocus postID: String?) {
        guard let postID, let target = entries.firstIndex(where: { $0.postID == postID })
        else { return }
        position = PageIndex.Position(postIndex: target, pageInPost: 0)
    }

    /// The bar's line: "pages 12–13 of ~240 — <post>". The tilde is
    /// load-bearing honesty (R112 applied to a number): while any post is
    /// still estimated, the total is a guess and says so.
    var pageLine: String {
        guard !entries.isEmpty, let first = leaves.first ?? nil else { return "no pages" }
        let approx = index.isApproximate ? "~" : ""
        let numbers: String
        if let second = leaves.count > 1 ? leaves[1] : nil {
            numbers = "pages \(first.pageNumber)–\(second.pageNumber)"
        } else {
            numbers = "page \(first.pageNumber)"
        }
        var line = "\(numbers) of \(approx)\(index.totalPages)"
        if entries.indices.contains(position.postIndex) {
            line += " — \(Self.pageTitle(entries[position.postIndex]))"
        }
        return line
    }

    var scrubFraction: Double {
        guard index.totalPages > 0, let number = index.pageNumber(of: position) else { return 0 }
        return Double(number - 1) / Double(max(1, index.totalPages - 1))
    }

    /// A page's display title — the book surfaces' shared rule.
    static func pageTitle(_ entry: Queries.ReadingEntry) -> String {
        entry.title?.isEmpty == false ? entry.title! : (entry.entryDate ?? "Untitled")
    }
}
