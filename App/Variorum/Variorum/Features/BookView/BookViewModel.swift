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
                readingID, limit: Self.entryWindow + 1  // +1: the truncation probe
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
    func adopt(_ new: [Queries.ReadingEntry]) {
        truncated = new.count > Self.entryWindow
        entries = truncated ? Array(new.prefix(Self.entryWindow)) : new
        // The page brain never points past the (possibly shrunk) list.
        pagedIndex = Self.clampedPage(pagedIndex, count: entries.count)
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

    // MARK: - Reading progress (13b 4F — S4-9(1), N31: "it needs a
    // progress bar"). MODEL-DRIVEN per the Phase 6 memo's ruling: the
    // domain is the POST LIST, never live text/pixel geometry — the view
    // reports which posts' content is on screen (SwiftUI scroll
    // visibility, one boolean per realized row) and the brain answers
    // "you are at post k of n" from the entry order alone. Cost ∝
    // realized rows (P1); nothing here reads TK2 geometry.
    //
    // 13c 2A: OUTLINE no longer has a consumer — her A6 ruling removed
    // its whole bottom inset, progress bar included ("it seems a bit
    // buggy… remove it fully for now"), and the per-row visibility
    // reporting went with it rather than costing work for a face that
    // isn't drawn. The brain stays: it is pure and pinned, the Book
    // spread and Read's paginated sub-mode both KEEP a bottom bar, and
    // batches 2B/2C own those. If the outline bar ever returns, her
    // observed bugginess gets investigated FIRST.

    /// The posts whose CONTENT view is currently on screen (the card, or
    /// the expanded body — one tracked view per row).
    private(set) var visiblePosts: Set<String> = []
    /// The sticky progress position (1-based): the FURTHEST visible post.
    /// Sticky so a transition frame with zero reports (row swap, mode
    /// flip) never snaps the bar to nothing.
    private(set) var progressPosition: Int?

    func noteVisible(_ postID: String, _ visible: Bool) {
        if visible {
            visiblePosts.insert(postID)
        } else {
            visiblePosts.remove(postID)
        }
        progressPosition = Self.progressPosition(
            visible: visiblePosts, entries: entries, previous: progressPosition)
    }

    /// The pure half (pinned): the furthest visible entry's 1-based
    /// position; `previous` when nothing reports (sticky); nil only
    /// before anything was ever visible.
    nonisolated static func progressPosition(
        visible: Set<String>, entries: [Queries.ReadingEntry], previous: Int?
    ) -> Int? {
        let indexByID = Dictionary(
            uniqueKeysWithValues: entries.enumerated().map { ($0.element.postID, $0.offset) })
        let furthest = visible.compactMap { indexByID[$0] }.max()
        if let furthest { return furthest + 1 }
        return previous
    }

    /// The bar's rendering: position, total, and the filled fraction.
    var readingProgress: (position: Int, total: Int, fraction: Double)? {
        guard !entries.isEmpty else { return nil }
        let position = min(progressPosition ?? 1, entries.count)
        return (position, entries.count, Double(position) / Double(entries.count))
    }

    // MARK: - The paged view's page brain (13b 4F — S4-9(2), N31: page =
    // a POST; the same model-driven domain as the scrubber — the post
    // list; the Phase 6 memo binds).

    /// The current page (an index into `entries`; clamped on adopt).
    private(set) var pagedIndex = 0

    nonisolated static func clampedPage(_ index: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return min(max(index, 0), count - 1)
    }

    /// The current page's entry (nil on an empty book).
    var currentPage: Queries.ReadingEntry? {
        guard pagedIndex >= 0, pagedIndex < entries.count else { return nil }
        return entries[pagedIndex]
    }

    /// Land on a page. Flipping away from a live page RELEASES focus —
    /// pages open read-cheap (the calm default; P3's one-live-editor rule
    /// holds by construction either way, since only the current page
    /// mounts). The unmounting editor's teardown flushes pending text
    /// through the per-post coordinator (the standing discipline).
    func openPage(_ index: Int) {
        let clamped = Self.clampedPage(index, count: entries.count)
        guard clamped != pagedIndex else { return }
        pagedIndex = clamped
        if let focused = focusedPostID, entries.indices.contains(clamped),
           entries[clamped].postID != focused {
            focus(nil)
        }
    }

    /// Land on a post's page (the navigator's door while paging).
    func openPage(post postID: String) {
        guard let index = entries.firstIndex(where: { $0.postID == postID }) else { return }
        openPage(index)
    }

    func flipPage(by delta: Int) {
        openPage(pagedIndex + delta)
    }

    /// Entering the paged view lands on the post you were in (focus wins,
    /// else the page you last held).
    func seedPageFromFocus() {
        if let focused = focusedPostID,
           let index = entries.firstIndex(where: { $0.postID == focused }) {
            pagedIndex = index
        } else {
            pagedIndex = Self.clampedPage(pagedIndex, count: entries.count)
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
    /// The posts folded shut (13c 2A — A39: Outline is the book's WRITING
    /// surface, so a post reads OPEN and COLLAPSE is the deliberate act;
    /// batch 12's R106 default was the other way round, when this surface
    /// was a book *screen* rather than a place to write. PROVISIONAL —
    /// QUESTIONS #43).
    ///
    /// Tracking the collapsed side rather than the expanded one is what
    /// makes the default hold for free: a post that arrives later — minted
    /// by "+ new post in this book", pulled in by a tag, landed by sync —
    /// is open the moment it appears, with nothing to seed.
    ///
    /// Session/view state, never persisted: this model's lifetime is the
    /// open book's (QUESTIONS #43(b)).
    private(set) var collapsedPosts: Set<String> = []

    func isExpanded(_ postID: String) -> Bool {
        !collapsedPosts.contains(postID)
    }

    /// Focus a post (nil = release): the focused post is always expanded.
    func focus(_ postID: String?, caret: Int? = nil, fanBlock: String? = nil) {
        caretSeed = caret
        fanSeed = fanBlock
        focusedPostID = postID
        if let postID { collapsedPosts.remove(postID) }
    }

    /// Unfold a collapsed post (the card's disclosure).
    func expand(_ postID: String) {
        collapsedPosts.remove(postID)
    }

    /// D1: collapsing a post collapses it — focused included. Focus is
    /// RELEASED (the live editor unmounts; its teardown flushes pending
    /// text through the per-post coordinator, the Stage 1a machinery).
    func collapse(_ postID: String) {
        collapsedPosts.insert(postID)
        if focusedPostID == postID {
            focusedPostID = nil
            caretSeed = nil
            fanSeed = nil
        }
    }

    /// D1's collapse-all half: everything back to cards, focus released.
    /// Scoped to the entries in hand — a post that arrives afterwards is
    /// open, which is the writing surface's default and not a survivor of
    /// this gesture.
    func collapseAll() {
        collapsedPosts = Set(entries.map(\.postID))
        focusedPostID = nil
        caretSeed = nil
        fanSeed = nil
    }

    func expandAll() {
        collapsedPosts.removeAll()
    }
}
