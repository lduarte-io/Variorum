//
//  BookViewModel.swift
//  Variorum
//
//  The continuous book view's model (Phase 10 Step 4): a reading's post
//  list in one continuous scroll. The assembly — curated order, smart
//  predicates, stamp sorts, NULLs-last, extent, grouping, archived-out —
//  is Phase 4's `assembleReading`, RENDERED here, never re-decided (review
//  focus 3: no business rules in view models).
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import VariorumCore

@MainActor
@Observable
final class BookViewModel {
    @ObservationIgnored let session: AppSession
    let readingID: String

    /// The bounded observation window (the `observeLibrary` discipline —
    /// P1: a held fetch re-runs at container-write rate, so it must stay
    /// viewport-shaped, not corpus-shaped). Deeper reading = a deliberate
    /// widening, not a default.
    static let entryWindow = 300

    private(set) var entries: [Queries.ReadingEntry] = []
    private(set) var readingName: String?
    private(set) var lastError: String?

    /// A31 — the way she is LOOKING at this book's order right now. nil =
    /// the book's own stored order (the default, and what every other
    /// reader sees).
    ///
    /// **View-local by design, and that IS the answer to her lens
    /// analogy.** A lens is never rendering truth (the 11a ratification):
    /// browsing a book by date must not change what export writes, what the
    /// Fragments projection pushes, or what the book looks like on another
    /// device — only `setReadingSort` does that, through the one deliberate
    /// save door. Not persisted, like every other view-local state (fan
    /// expansion, canvas picks, the Compare toggles, #43(b)).
    ///
    /// Changing it restarts the observation (`BookView`'s `.task(id:)`)
    /// rather than re-sorting delivered rows: the window is applied by the
    /// query, so a post-fetch sort would sort the first N of the old order.
    var viewOrder: Queries.ReadingOrder?
    /// True when the window really is hiding later entries (round 2 NIT:
    /// observing window+1 and capping in `adopt` means a reading of
    /// EXACTLY the window size never false-positives the marker).
    private(set) var truncated = false

    init(session: AppSession, readingID: String) {
        self.session = session
        self.readingID = readingID
    }

    /// Runs for the view's lifetime.
    func start() async {
        do {
            // One-shot by-key fetch (round 1 NIT); a rename while the book
            // is open goes stale until reopen — cosmetic at author scale,
            // recorded.
            readingName = try await session.database.read { [readingID] db in
                try Queries.reading(db, id: readingID)?.name
            }
            for try await value in session.database.observeReading(
                readingID, limit: Self.entryWindow + 1,  // +1: the truncation probe
                order: viewOrder
            ) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// Adoption is verbatim up to the window — the query's order and
    /// content ARE the view's (internal so tests pin exactly that); the
    /// +1 probe row is consumed into `truncated`, never rendered.
    ///
    /// **The spread survives by IDENTITY, not by index (13c K6 review,
    /// K1).** `spreadLeftIndex` is a position in `entries`, so a membership
    /// insertion or an order flip used to shift the indices and silently
    /// swap which two posts the spread showed — and, because the old code
    /// never re-checked focus here, could leave `focusedPostID` pointing at
    /// an off-spread post (no editor mounted, the arrow shortcuts withdrawn
    /// for nothing). The anchor is the FOCUSED post while it is on the
    /// spread (the page under her hands keeps its side), else the left
    /// page; the clamp remains only for a post that left the book, and
    /// focus is released exactly when its post is no longer visible.
    func adopt(_ new: [Queries.ReadingEntry]) {
        let anchor: (postID: String, wasRight: Bool)? = {
            guard let indices = Self.spreadIndices(
                leftIndex: spreadLeftIndex, count: entries.count)
            else { return nil }
            let leftID = entries[indices.left].postID
            let rightID = indices.right.map { entries[$0].postID }
            if let focused = focusedPostID, focused == rightID {
                return (focused, true)
            }
            return (leftID, false)
        }()
        truncated = new.count > Self.entryWindow
        entries = truncated ? Array(new.prefix(Self.entryWindow)) : new
        if let anchor,
           let newIndex = entries.firstIndex(where: { $0.postID == anchor.postID }) {
            spreadLeftIndex = Self.clampedPage(
                anchor.wasRight ? newIndex - 1 : newIndex, count: entries.count)
        } else {
            // The anchor left the book (or the list emptied): the old
            // clamp is all that is left to do.
            spreadLeftIndex = Self.clampedPage(spreadLeftIndex, count: entries.count)
        }
        // Deliberately BOOK-scoped, not spread-scoped: this model serves
        // Outline too, where the focused post is rarely on the spread's two
        // indices — a spread-scoped release here would unmount the Outline
        // editor mid-typing on every observation delivery. With identity
        // anchoring above, a spread-focused post can only leave the spread
        // by leaving the book (or the window), which is exactly this test.
        releaseFocusIfItLeftTheBook()
    }

    private func releaseFocusIfItLeftTheBook() {
        guard let focused = focusedPostID,
              !entries.contains(where: { $0.postID == focused }) else { return }
        focus(nil)
    }

    /// The section header to show ABOVE entry `i`, if any: grouping is
    /// Phase 4's (`sectionPath` per entry); clustering into headers is the
    /// view's presentation call (the ratified reading) — a header renders
    /// where the section differs from the previous entry's.
    func sectionHeader(at i: Int) -> String? {
        guard i >= 0, i < entries.count, let section = entries[i].sectionPath else { return nil }
        if i == 0 || entries[i - 1].sectionPath != section { return section }
        return nil
    }

    // MARK: - Book-scrub (Phase 11, A5 — the Phase 6 memo's decision)

    /// The scrubber's PURE mapping: a fraction of the scrub track → the
    /// page (a POST — 50 entries are 50 pages even if one is 10k words;
    /// the post list is the scrubber's domain, never live text geometry —
    /// the memo's model-driven ruling). Clamped; empty reading → nil.
    nonisolated static func scrubIndex(fraction: Double, count: Int) -> Int? {
        guard count > 0 else { return nil }
        let clamped = min(max(fraction, 0), 1)
        return min(Int(clamped * Double(count)), count - 1)
    }

    /// The page the scrubber lands on for a track fraction.
    func scrubTarget(fraction: Double) -> Queries.ReadingEntry? {
        guard let index = Self.scrubIndex(fraction: fraction, count: entries.count) else {
            return nil
        }
        return entries[index]
    }

    /// The SPREAD's scrub position as a track fraction — the inverse of
    /// `scrubIndex` over the same domain, so the thumb sits exactly where
    /// releasing it would land (round-tripped for every index by
    /// `theSpreadScrubberRidesThePostListAndRoundTrips`).
    var spreadScrubFraction: Double {
        guard entries.count > 1 else { return 0 }
        return Double(spreadLeftIndex) / Double(entries.count - 1)
    }

    /// The scrubber's landing on the spread (13d batch 1, her #44(c)/#45(c)
    /// ruling — scrubbers on BOTH horizontal surfaces): the scrubbed POST
    /// takes the LEFT page, and the ring is released exactly as any other
    /// jump releases it. The domain is the POST LIST, never live TK2
    /// geometry — the Phase 6 memo's model-driven ruling, Stage 4 lesson 8,
    /// which is also why this reuses `scrubIndex` rather than minting a
    /// second mapping.
    func scrubSpread(fraction: Double) {
        guard let index = Self.scrubIndex(fraction: fraction, count: entries.count) else {
            return
        }
        openSpread(leftIndex: index)
    }

    // The 13b 4F reading-progress brain (`noteVisible` / `progressPosition`
    // / `readingProgress`) lived here until the 13c K6 review (K4). 2A's A6
    // ruling removed its only face and the per-row visibility reporting;
    // 2B's spread reads `spreadLeftIndex` exactly; 2C's paginated Read has
    // its own page domain — so it ended the stage with ZERO callers, and
    // its own recorded rule was "deleted rather than kept warm on
    // speculation." If an outline progress bar ever returns, her observed
    // bugginess is investigated FIRST (her A6 words), and the brain's shape
    // is one git checkout behind this comment (and in the 13b 4F record).

    // MARK: - The SPREAD's page brain (13b 4F's page = a POST, made TWO-UP
    // at 13c 2B — her direction: "basically like [today's] Pages but with
    // two posts side by side… more like a lens column, for comparison").
    // The domain is the POST LIST, never live text geometry (the Phase 6
    // memo's model-driven ruling; Stage 4 lesson 8) — which is exactly what
    // distinguishes Book from Read: **Book paginates by post, Read
    // paginates by text.**
    //
    // Vocabulary, renamed OUT of the collision at 2B for the reason 2A
    // renamed the modes: `pagedIndex` named "the one page on screen" and now
    // means "the LEFT page of the spread", so every stale reference should
    // be a compile error rather than silently mean something else.

    /// The LEFT page of the spread (an index into `entries`; clamped on
    /// adopt). The right page is its successor where the book has one.
    private(set) var spreadLeftIndex = 0

    /// How the ACTIVE page presents itself — her A44 instruction: *"stack
    /// view + the normal write view should be the editing forms offered."*
    /// Session/view state, never persisted (the collapse-set class,
    /// QUESTIONS #43(b)/#44(a)); one setting for the spread, because the
    /// forms are what the VIEW offers, not a property of a post.
    enum SpreadForm: String, Sendable, CaseIterable { case write, takes }
    var spreadForm: SpreadForm = .write

    nonisolated static func clampedPage(_ index: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return min(max(index, 0), count - 1)
    }

    /// The spread's two slots for a left index: the left page and — when the
    /// book has a successor — the right. An odd book (or a nudge onto the
    /// last post) shows ONE page and a blank leaf; nothing ever wraps round
    /// from the other end of the book (a blank leaf is honest, a wrapped
    /// page is a lie about where you are).
    nonisolated static func spreadIndices(
        leftIndex: Int, count: Int
    ) -> (left: Int, right: Int?)? {
        guard count > 0 else { return nil }
        let left = clampedPage(leftIndex, count: count)
        return (left, left + 1 < count ? left + 1 : nil)
    }

    /// Can a move of `posts` reveal anything you cannot already see? ONE rule
    /// behind every flip control's enablement: a turn or a nudge that shows
    /// no new post is refused, so the last leaf never has a live "next" that
    /// re-shows the page you are already reading (P-2 — a door that cannot
    /// act in its context isn't rendered live).
    nonisolated static func canMove(
        by posts: Int, leftIndex: Int, count: Int
    ) -> Bool {
        guard let here = spreadIndices(leftIndex: leftIndex, count: count) else { return false }
        guard let there = spreadIndices(leftIndex: leftIndex + posts, count: count)
        else { return false }
        let visible = Set([here.left, here.right].compactMap { $0 })
        let landing = Set([there.left, there.right].compactMap { $0 })
        return !landing.isSubset(of: visible)
    }

    /// The spread's entries, left first (1 or 2; empty on an empty book).
    var spreadEntries: [Queries.ReadingEntry] {
        guard let indices = Self.spreadIndices(leftIndex: spreadLeftIndex, count: entries.count)
        else { return [] }
        return [indices.left, indices.right].compactMap { $0 }.map { entries[$0] }
    }

    var leftPage: Queries.ReadingEntry? { spreadEntries.first }
    var rightPage: Queries.ReadingEntry? { spreadEntries.count > 1 ? spreadEntries[1] : nil }

    /// Land the spread with `index` as its LEFT page. Flipping away from a
    /// live page RELEASES focus — pages open read-cheap (the calm default);
    /// the unmounting editor's teardown flushes pending text through the
    /// per-post coordinator (the standing discipline). A post still on the
    /// spread KEEPS its ring: a nudge that carries your live page along has
    /// no reason to throw your caret away.
    func openSpread(leftIndex: Int) {
        let clamped = Self.clampedPage(leftIndex, count: entries.count)
        guard clamped != spreadLeftIndex else { return }
        spreadLeftIndex = clamped
        releaseFocusIfItLeftTheSpread()
    }

    private func releaseFocusIfItLeftTheSpread() {
        guard let focused = focusedPostID else { return }
        if !spreadEntries.contains(where: { $0.postID == focused }) { focus(nil) }
    }

    /// TURN THE LEAF — the default flip, two posts at a time (her ruling).
    func turnLeaf(by leaves: Int) {
        openSpread(leftIndex: spreadLeftIndex + 2 * leaves)
    }

    /// The single-step control (her sketch: *"a half arrow button or
    /// something"*): nudge the spread by ONE post, so a turn that split two
    /// posts she wanted side by side can be re-paired.
    func nudgeSpread(by posts: Int) {
        openSpread(leftIndex: spreadLeftIndex + posts)
    }

    /// The navigator's jump: show this post. A post already ON the spread is
    /// left where it is (jumping to the page you are reading must not
    /// re-shuffle the pairing you are looking at); otherwise it takes the
    /// LEFT page.
    func showPost(_ postID: String) {
        guard let index = entries.firstIndex(where: { $0.postID == postID }) else { return }
        guard !spreadEntries.contains(where: { $0.postID == postID }) else { return }
        openSpread(leftIndex: index)
    }

    /// True while this post is one of the spread's two pages.
    func isOnSpread(_ postID: String) -> Bool {
        spreadEntries.contains { $0.postID == postID }
    }

    /// Entering the spread lands on the post you were in (focus wins, else
    /// the leaf you last held).
    func seedSpreadFromFocus() {
        if let focused = focusedPostID,
           !isOnSpread(focused),
           let index = entries.firstIndex(where: { $0.postID == focused }) {
            spreadLeftIndex = index
        } else {
            spreadLeftIndex = Self.clampedPage(spreadLeftIndex, count: entries.count)
        }
    }

    // MARK: - Focus + expansion — ONE model (13b Stage 3, 3E: D1 + the
    // Stage 0 verdict "fold BookFocusState — a third focus authority —
    // into the one focus model"). What replaced BookFocusState: this
    // conductor is now the book surface's single focus authority — the
    // P-3 discipline the takes side gets from PaneTextAuthority, applied
    // to "which POST holds the live inline editor". Exactly one focused
    // post (P3's one-live-editor rule by construction); focus IMPLIES
    // expansion; and collapse RELEASES focus — the two states can no
    // longer disagree, which is precisely the D1 mechanism (the old
    // `expandedPosts.contains || focused ==` force-expand disjunct read
    // two authorities and the collapse door only wrote one).

    private(set) var focusedPostID: String?
    /// Seeds ride the next focus so the editor lands with the clicked
    /// caret (or the tapped badge's fan panel — interpretation 1, focus
    /// first).
    private(set) var caretSeed: Int?
    private(set) var fanSeed: String?
    /// The posts unfolded — Outline opens with its posts COLLAPSED.
    ///
    /// **The author's ruling at the 13c ratify walk, 2026-07-27 (QUESTIONS
    /// #43(a), option (a)): OVERTURNED.** 2A shipped this surface with
    /// posts OPEN (PROVISIONAL, flagged as a reversal of R106); she ruled
    /// the other way — *"you shouldn't see the content within a post on the
    /// book screen unless you click something"* extends to the writing
    /// surface after all. A post renders as batch 12's card; expanding is
    /// the deliberate act, and "expand all" opens the whole book in one
    /// click.
    ///
    /// **The SET's sense inverted WITH the default, and that is not
    /// cosmetic.** 2A tracked the collapsed side for a traced reason: the
    /// default must hold for a post that ARRIVES — minted by "+ new post in
    /// this book", pulled in by a tag, landed by sync — with no seeding
    /// site to forget (the silent-miss class this app keeps finding). Under
    /// collapsed-by-default the identical argument points the other way: a
    /// post nobody expanded is collapsed because it is not in the set.
    /// Pinned directly (`aPostThatArrivesAfterExpandAllIsCollapsed`).
    ///
    /// Session/view state, never persisted: this model's lifetime is the
    /// open book's (QUESTIONS #43(b), untouched by the flip).
    private(set) var expandedPosts: Set<String> = []

    func isExpanded(_ postID: String) -> Bool {
        expandedPosts.contains(postID)
    }

    /// Focus a post (nil = release): the focused post is always expanded.
    func focus(_ postID: String?, caret: Int? = nil, fanBlock: String? = nil) {
        caretSeed = caret
        fanSeed = fanBlock
        focusedPostID = postID
        if let postID { expandedPosts.insert(postID) }
    }

    /// Unfold a collapsed post (the card's disclosure) — the deliberate act
    /// this surface opens needing (#43(a)).
    func expand(_ postID: String) {
        expandedPosts.insert(postID)
    }

    /// D1: collapsing a post collapses it — focused included. Focus is
    /// RELEASED (the live editor unmounts; its teardown flushes pending
    /// text through the per-post coordinator, the Stage 1a machinery).
    func collapse(_ postID: String) {
        expandedPosts.remove(postID)
        if focusedPostID == postID {
            focusedPostID = nil
            caretSeed = nil
            fanSeed = nil
        }
    }

    /// D1's collapse-all half: everything back to cards, focus released —
    /// which under #43(a) is the surface's own default state, reached in one
    /// click from anywhere.
    func collapseAll() {
        expandedPosts.removeAll()
        focusedPostID = nil
        caretSeed = nil
        fanSeed = nil
    }

    /// Open the whole book at once. Scoped to the entries in hand — a post
    /// that arrives afterwards is COLLAPSED, which is the default and not a
    /// survivor of this gesture (the mirror of what collapse-all used to
    /// carry, and the reason the set tracks this side; see `expandedPosts`).
    func expandAll() {
        expandedPosts = Set(entries.map(\.postID))
    }
}
