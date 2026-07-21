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
    /// Posts showing content (read-cheap or live) instead of their card.
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

    /// Expand to the read tier (the card's disclosure).
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

    /// D1's collapse-all half: everything back to cards, focus released.
    func collapseAll() {
        expandedPosts.removeAll()
        focusedPostID = nil
        caretSeed = nil
        fanSeed = nil
    }

    func expandAll() {
        expandedPosts.formUnion(entries.map(\.postID))
    }
}
