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
    nonisolated static let entryWindow = 300

    /// **The window she is reading through** (13o U3 — the book Index's cap
    /// gets a road, PROVISIONAL P-13o-U3-8): it starts at `entryWindow` and
    /// grows by one window per "show more ›" — the deliberate widening this
    /// type's own doc names, never a default (P1: a held fetch costs ∝ the
    /// window she asked for). A capped listing with no road to the rest was
    /// her ruled-against class (R-13o-9's own words: "the 40 cap with no
    /// escape is terrible"). Part of the observation key, so a wider window
    /// restarts the observation rather than re-reading in place.
    private(set) var window = BookViewModel.entryWindow

    /// Read one more window of the book (the "show more ›" road).
    func showMore() {
        window += Self.entryWindow
    }

    private(set) var entries: [Queries.ReadingEntry] = []
    private(set) var readingName: String?
    private(set) var lastError: String?

    /// A31 — the way she is LOOKING at this book's order right now. nil =
    /// the book's own stored order (the default, and what every other
    /// reader sees).
    ///
    /// **View-local by design, and that IS the answer to her lens
    /// analogy.** A lens is never rendering truth (the 11a ratification):
    /// browsing a book by date must not change what export writes or what
    /// the book looks like on another
    /// device — only `setReadingSort` does that, through the one deliberate
    /// save door. Not persisted, like every other view-local state (fan
    /// expansion, canvas picks, the Compare toggles, #43(b)).
    ///
    /// Changing it restarts the observation (`BookView`'s `.task(id:)`)
    /// rather than re-sorting delivered rows: the window is applied by the
    /// query, so a post-fetch sort would sort the first N of the old order.
    var viewOrder: Queries.ReadingOrder?
    /// **13i-d U3 — the in-book FILTER** (the sitting record §18.1): a
    /// view-local tag/star rule narrowing what this book SHOWS — never its
    /// membership (`assembleReading`'s `filter:`, 13i-b's mechanics). The
    /// Index's filter bar sets it and CLEARS it when the Index leaves (the
    /// bar is its only face — P-13id-U3-5). Like `viewOrder`, it is a task
    /// input: changing it restarts the observation (`BookView`'s
    /// `.task(id: observationKey)`), so the window is applied over the
    /// narrowed assembly, never by a post-fetch filter.
    var viewFilter: RuleTerm?

    /// The observation's restart key — the order AND the filter it reads by.
    nonisolated struct ObservationKey: Equatable {
        var order: Queries.ReadingOrder?
        var filter: RuleTerm?
        /// 13o U3: the window she is reading through.
        var window = BookViewModel.entryWindow
    }

    var observationKey: ObservationKey {
        ObservationKey(order: viewOrder, filter: viewFilter, window: window)
    }
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
                readingID, limit: window + 1,  // +1: the truncation probe
                order: viewOrder, filter: viewFilter
            ) {
                await adopt(value)
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
    /// **13u2 UNIT A2 — WHY THIS IS `async` (item 18, RULING A-1).** The
    /// cards' previews are PRIMED here, before the entries are published, so
    /// that the invariant below holds with no timing in it:
    ///
    ///   > an entry is never published without its card preview in hand.
    ///
    /// The traced defect it closes: a collapsed card used to fetch its own
    /// preview from a `.task` on the row, so its HEIGHT depended on when that
    /// read returned — every card above a landing target grew 46 → 103 pt at
    /// an arbitrary moment AFTER the page had arrived (854 pt of drift on the
    /// real Sherlock book; her *"stutter … once I've already arrived"* and
    /// the recovery hop a second later, *"moved down to where the note
    /// started"*). Nothing about the card's SIZE changes here — that is what
    /// the reverted first attempt did, and it relocated the defect rather
    /// than closing it. The settled column is byte-identical to before.
    ///
    /// The suspension sits BEFORE the state mutation, never inside it:
    /// `applyEntries` below is the old synchronous body, untouched, so the
    /// spread-anchor reasoning it carries still runs in one turn.
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
    func adopt(_ new: [Queries.ReadingEntry]) async {
        await primeCardPreviews(for: new)
        applyEntries(new)
    }

    private func applyEntries(_ new: [Queries.ReadingEntry]) {
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
        truncated = new.count > window
        entries = truncated ? Array(new.prefix(window)) : new
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

    // MARK: - 13u2 UNIT A2 — THE CARDS' PREVIEWS, PRIMED WITH THE ENTRIES
    //
    // The Outline's collapsed card shows the note's opening words. It used to
    // fetch them itself, per realized row, from a WHOLE-note render — which
    // made two things true at once: the read cost ∝ the note's text for forty
    // words of it (P1), and, worse, the card's HEIGHT arrived late. Item 18
    // is the second one: a card that grows after a landing has arrived moves
    // the page under her, and the landing then spends a hop recovering.
    //
    // Priming closes it by removing the timing, not by reserving room: the
    // book reads every entry's leading blocks in ONE bounded read as the
    // entries arrive, so a card's first frame already knows its words. No
    // card changes height, no card changes SIZE either, and the settled
    // column is exactly what it was.

    /// How many leading blocks the preview reads per note.
    ///
    /// Four, not one: `BookOutlineRows.cardPreview` skips a lone heading or
    /// numeral at the front (`I.`, `# Part One`) and reads ACROSS block
    /// breaks until it has ~forty words, and a note may well open with an
    /// empty block since Return started minting them (18c's U-1). One stub
    /// plus three blocks of prose overshoots forty words in every shape the
    /// sample library and her corpus have. It is a SMALL CONSTANT, which is
    /// the property that matters: cost ∝ entries × 4 slots, never ∝ the
    /// book's text.
    static let cardPreviewBlocks = 4

    /// Each entry's card preview, derived at read time and never stored.
    /// Observed (a refresh re-renders the cards); the dictionary is the
    /// book's, so it is evicted down to the entries in hand on every
    /// adoption.
    private(set) var cardPreviews: [String: String] = [:]

    /// What a card shows. `""` covers both "this note has nothing to preview"
    /// and "not primed" — the card renders no excerpt either way, and the
    /// priming invariant (`adopt`) is what makes the second case impossible
    /// for an entry the view can see.
    func cardPreview(_ postID: String) -> String {
        cardPreviews[postID] ?? ""
    }

    /// Read the previews the incoming entries do not have yet, and forget the
    /// ones whose notes have left the book. Runs BEFORE `applyEntries`, so an
    /// entry never reaches the view without its words.
    ///
    /// Steady state costs NOTHING: the entries re-deliver on every container
    /// write (an autosave stamps `last_touched_at`), and a delivery whose
    /// notes are all primed does not open the database at all.
    private func primeCardPreviews(for incoming: [Queries.ReadingEntry]) async {
        let wanted = incoming.prefix(window).map(\.postID)
        let missing = wanted.filter { cardPreviews[$0] == nil }
        if !missing.isEmpty {
            await readCardPreviews(missing)
        }
        evictCardPreviews(keeping: wanted)
    }

    /// The one read. A failure leaves the ids UNSET rather than writing an
    /// empty preview, so the next delivery tries again — an empty string here
    /// means "read, and there is nothing to show", and the two must not be
    /// confused (the same distinction the reverted attempt needed a separate
    /// `factsLoaded` flag for).
    private func readCardPreviews(_ postIDs: [String]) async {
        let blocks = Self.cardPreviewBlocks
        guard let texts = try? await session.database.read({ db in
            try Queries.leadingBlockTexts(db, containerIDs: postIDs, blocks: blocks)
        }) else { return }
        #if DEBUG
        BookCardPreviewReads.reads += 1
        BookCardPreviewReads.notes += postIDs.count
        #endif
        for id in postIDs {
            cardPreviews[id] = BookOutlineRows.cardPreview(blocks: texts[id] ?? [])
            // 13u2b UNIT 1: the words changed, so the card's shape may have
            // too — and the height learned for the old shape was the old
            // card's.
            outlineHeights.forgetCardShape(id)
        }
    }

    private func evictCardPreviews(keeping ids: [String]) {
        let live = Set(ids)
        guard cardPreviews.contains(where: { !live.contains($0.key) }) else { return }
        cardPreviews = cardPreviews.filter { live.contains($0.key) }
    }

    /// **A note that was OPEN may have been edited, so its card re-reads when
    /// it closes.** This is the freshness the per-row `.task` used to give for
    /// free (its id carried the expansion, so collapsing re-read), kept
    /// deliberately rather than dropped: without it a note edited in the book
    /// would show its old opening words until the book was reopened.
    ///
    /// It cannot re-open item 18: the card keeps the words it has while the
    /// re-read runs (never an empty slot, never a 46-pt card), and a collapse
    /// is not a landing. A height change here would mean her own edit really
    /// did change the note's opening — which is the card telling the truth.
    private func refreshCardPreviews(_ postIDs: [String]) {
        let ids = postIDs.filter { cardPreviews[$0] != nil }
        guard !ids.isEmpty else { return }
        Task { [weak self] in await self?.readCardPreviews(ids) }
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

    /// How many of this book's notes are open — the DEBUG landing story's
    /// "what shape is this column in" number (13u2b UNIT 1), and the thing a
    /// walk has to be able to state rather than infer from the screen.
    var expandedCount: Int { expandedPosts.count }

    // MARK: - Row 53 (the Act 10 correction round): the expanded surfaces'
    // REMEMBERED SIZES

    /// The last settled size of each expanded note's text surface (read-
    /// cheap or live), keyed by post — session view state, never persisted.
    /// Why it exists: Outline's lazy column re-realizes an expanded story
    /// every time it scrolls back into range, and the surface comes back
    /// at its placeholder (24/40 pt), grows to a first measure, then to its
    /// final ~20,000 pt — thousands of points of layout change per row,
    /// several rows at once, for hundreds of milliseconds. Under that
    /// churn the container's estimates never converge and no scroll
    /// request lands (the orchestrator's walk, row 53: the page inside the
    /// wrong story). A row that remembers its size reserves it from the
    /// first frame it is realized (`OutlinePostRow`), so the column's
    /// layout is right at once and only a story opened for the FIRST time
    /// ever grows — at the top of the page, downward, harmlessly.
    ///
    /// `@ObservationIgnored`: written at geometry cadence and read only at
    /// a row's realization — an observed property here would re-render the
    /// whole book per report.
    ///
    /// **18d batch 4 (U-12) — and now it OUTLIVES the launch.** The plain
    /// dictionary that used to sit here is a `SurfaceSizeMemory` in the
    /// `outline` key space: the same session behaviour, plus one
    /// `UserDefaults` record per note written when a surface SETTLES
    /// (`persistSurfaceSize`, called from `StableSurface`'s own settle
    /// announcement — never at geometry cadence). Her words: *"I see no
    /// reason why we wouldn't add in remembering the length of notes so it
    /// can be perfect after the first time."* Local-only view state, never
    /// synced, no schema.
    @ObservationIgnored let outlineSurfaceSizes =
        SurfaceSizeMemory(.outline, fingerprint: { EditorTypography.fingerprint })

    func rememberedSurfaceSize(_ postID: String) -> CGSize? {
        outlineSurfaceSizes.size(postID)
    }

    func rememberSurfaceSize(_ postID: String, _ size: CGSize) {
        outlineSurfaceSizes.remember(postID, size)
    }

    /// The Outline surface for this note settled — the one occasion its
    /// size reaches the disk (the ~100 µs-a-call rule, `CurrentBlockMemory`'s
    /// measured lesson: never on a report, never on a keystroke).
    func persistSurfaceSize(_ postID: String) {
        outlineSurfaceSizes.persist(postID)
    }

    /// **VX-91 — should this expanded row mount its surfaces EARLY, before
    /// it is near the viewport?** The navigator's click on a far expanded
    /// story used to land the scroll on a viewport of `Color.clear`
    /// placeholders — the clicked TITLE alone, no text (her report, caught
    /// on the walk's film) — because the row's surfaces mounted only after
    /// arrival flipped `nearViewport`, and only then began their
    /// story-sized fills. The row she is ON HER WAY TO (focused, or the
    /// pending reveal's target) mounts at the click instead, so the text
    /// loads while the scroll travels.
    ///
    /// The width-matched-memory guard is LOAD-BEARING: with no memory at
    /// this width `StableSurface` reserves nothing, so an early mount
    /// would collapse a placeholder standing ~16k pt tall to its content's
    /// birth height mid-scroll — the exact reshuffle class this exists to
    /// calm. Such a row keeps the shipped behavior (placeholder until
    /// near); her steady-state store has a persisted record for every
    /// story it has realized (18d batch 4).
    func outlineRowPreMounts(_ postID: String) -> Bool {
        guard liveFocusedPostID == postID || pendingReveal == postID else { return false }
        guard let remembered = rememberedSurfaceSize(postID),
              abs(remembered.width - outlineContentWidth) <= stableSurfaceWidthTolerance
        else { return false }
        return true
    }

    /// Batch H (row 95): the Read ▸ Scroll flow's remembered story sizes —
    /// the same idea at the PAGE's measure (a story on the flow's 600-pt
    /// serif column is not the story at Write's measure above, so the two
    /// memories never share a size). Held here so a story measured once
    /// stays measured for the session across mode switches; the flow
    /// itself is re-created per mode.
    /// (18d batch 4: persisted too, in its OWN key space and under the
    /// PAGE's typography stamp — a story's height on the 600-pt serif page
    /// is not its height at Write's measure, so the two memories must never
    /// read each other's records.)
    @ObservationIgnored let flowSurfaceSizes =
        SurfaceSizeMemory(.flow, fingerprint: { FlowHeightEstimate.fingerprint })

    /// Ladder R2-4: the flow's block extents (the estimate's input), cached
    /// for the book beside the sizes — a return to Read ▸ Scroll re-reads
    /// no lengths (the flow itself is re-created per mode).
    ///
    /// **13u2b UNIT 1: the Outline is its second reader** — the same lengths
    /// answer "how tall is this note going to be" for an expanded row the
    /// column has never measured, and one cache serves both surfaces (a
    /// return to Read ▸ Scroll after opening a story in Outline re-reads
    /// nothing).
    @ObservationIgnored let flowExtents = FlowExtentsCache()

    // MARK: - 13u2b UNIT 1 — THE OUTLINE'S HEIGHTS
    //
    // The column's rows stand at KNOWN heights instead of at a lazy
    // container's average, so nothing above a landed target can move under
    // her (the plan's UNIT 1 RECORD has the trace: arriving at `top = 0`
    // de-realized the rows above, the estimate for them was ~70 pt short, the
    // content shrank and the page slid off the thing it had just landed on —
    // thirteen times, four seconds, her *"stutter ~10 times"*).
    //
    // What lives here is only the PLUMBING: the width the column stands at
    // (observed, because a change must re-render the rows), the lazy lengths
    // read, and the three thin doors the rows and the landing ask through.
    // The arithmetic is `BookHeightManifest` (pure) and the learning is
    // `BookOutlineHeights` (unobserved, geometry cadence).

    /// The learned heights and the measured type. Unobserved on purpose —
    /// see the file's own note.
    @ObservationIgnored let outlineHeights = BookOutlineHeights()

    /// The width the Outline's content column is really drawing at. Observed
    /// (a width change must re-render every row's placeholder), written ONLY
    /// when it really moves — the same 1-pt tolerance `StableSurface` and the
    /// flow compare with, so "the same width" is one number in the app.
    private(set) var outlineContentWidth: CGFloat = 0

    /// The column reported its measure.
    func reportOutlineContentWidth(_ width: CGFloat) {
        guard width > 0, abs(width - outlineContentWidth) > stableSurfaceWidthTolerance else { return }
        outlineContentWidth = width
        outlineHeights.stand(at: width)
        // A width the memories were not taken at leaves the expanded notes
        // with no remembered size (18d's deliberate refusal — never relaxed
        // here): the lengths estimate is what covers them, so it is wanted
        // now rather than at the next expansion.
        ensureOutlineExtents()
    }

    /// Bumped when the lengths land, so a row standing on the estimate
    /// re-renders with it. Observed and read by `outlineSurfaceHeight`.
    private(set) var outlineExtentsGeneration = 0
    @ObservationIgnored private var outlineExtentsInFlight = false

    /// **The lengths read, LAZILY.** A book opened and read with everything
    /// collapsed — her own gesture, and the default since #43(a) — never
    /// reaches this at all: a card's height has nothing to do with its note's
    /// length. It is wanted only when an EXPANDED note has no remembered size
    /// at this width, which is the cold case the trace measured at 20,848 pt
    /// of first-aim error.
    ///
    /// One bounded statement for the book (`Queries.blockExtents` — lengths
    /// computed in SQL, no prose crossing the boundary), cached for the book
    /// beside the flow's, and never re-run while it holds this entry set.
    func ensureOutlineExtents() {
        // **Nothing expanded ⇒ nothing to estimate.** This guard is the P1
        // sentence itself, and it was written after the pin caught its
        // absence: `reportOutlineContentWidth` calls this, and the column
        // reports its width on every mount, so without it EVERY book paid for
        // the lengths on open — including the all-cards book her own gesture
        // opens. (Pinned: `BookOutlineCostTests`.)
        guard !expandedPosts.isEmpty else { return }
        let ids = entries.map(\.postID)
        guard !ids.isEmpty, !outlineExtentsInFlight, flowExtents.lookup(ids) == nil else { return }
        outlineExtentsInFlight = true
        Task { [weak self] in
            guard let self else { return }
            defer { self.outlineExtentsInFlight = false }
            guard let rows = try? await session.database.read({ db in
                try Queries.blockExtents(db, containerIDs: ids)
            }) else { return }
            var byPost: [String: [Queries.BlockExtent]] = [:]
            for row in rows { byPost[row.containerID, default: []].append(row) }
            for id in ids where byPost[id] == nil { byPost[id] = [] }
            flowExtents.store(byPost, for: ids)
            #if DEBUG
            BookOutlineExtentReads.byBook[readingID, default: 0] += 1
            #endif
            outlineExtentsGeneration += 1
        }
    }

    /// What an EXPANDED note's text surface stands at before it is measured
    /// here — the far row's placeholder, and the height the manifest gives
    /// that row's prose.
    ///
    /// The order, and every step of it is a rule that already existed:
    /// 1. the remembered size **taken at this width** (18d's U-12 memory);
    /// 2. the estimate from this note's blocks' LENGTHS (AppSpec §4's
    ///    designed fallback) — this is the arm that covers the width her
    ///    memories were not taken at, which is exactly why 18d's per-width
    ///    refusal is not relaxed to make room for it;
    /// 3. a remembered size taken at ANOTHER width — the pre-existing
    ///    behaviour of this placeholder, kept as the last guess before the
    ///    unmeasured constant, because a note's height at 696 pt is a better
    ///    guess for it at 500 than 800 pt is;
    /// 4. the unmeasured constant.
    func outlineSurfaceHeight(_ postID: String) -> CGFloat {
        outlineSurfaceAnswer(postID).height
    }

    /// The same answer, plus WHICH arm gave it — so the manifest can say
    /// honestly whether a row's height is a remembered fact or arithmetic.
    /// (Without this every expanded row read as arithmetic, and
    /// `isExactAbove` was pessimistic about a column whose stories it
    /// actually knew: seen on this unit's walk as `expanded=5 derived=5
    /// exactAbove=N` over a book every one of whose stories had been
    /// measured.)
    func outlineSurfaceAnswer(_ postID: String) -> (height: CGFloat, remembered: Bool) {
        // Read so a row standing on the estimate re-renders when the lengths
        // land (the Observation dependency IS the mechanism here).
        _ = outlineExtentsGeneration
        let remembered = outlineSurfaceSizes.size(postID)
        if let remembered,
           abs(remembered.width - outlineContentWidth) <= stableSurfaceWidthTolerance {
            return (remembered.height, true)
        }
        // Element-wise against the entries (no per-ask id-list build — this
        // runs per far expanded row per body pass; 13u2b ladder NIT 2).
        if let extents = flowExtents.lookup(matching: entries)?[postID], !extents.isEmpty {
            return (BookOutlineHeightModel.expandedHeight(
                extents: extents, metrics: outlineHeights.metrics), false)
        }
        // A record from ANOTHER width is a guess, not a fact — it sizes the
        // placeholder (better than the unmeasured constant by the width
        // ratio) but it does not let the column claim exactness.
        if let remembered { return (remembered.height, false) }
        return (outlineHeights.metrics.expandedUnknown, false)
    }

    /// What a WHOLE row stands at — the small rows' placeholder, and the
    /// manifest's per-row answer.
    func outlineRowHeight(_ anchorID: String, shape: BookOutlineHeights.Shape) -> CGFloat {
        BookHeightManifest.resolve(outlineRowInput(anchorID, shape: shape)).0
    }

    /// The same question as a manifest input (one precedence brain).
    func outlineRowInput(
        _ anchorID: String, shape: BookOutlineHeights.Shape
    ) -> BookHeightManifest.Input {
        switch shape {
        case .expandedNote:
            // A whole expanded row is its surface plus the header and the
            // padding around it.
            let postID = String(anchorID.dropFirst("page-".count))
            let answer = outlineSurfaceAnswer(postID)
            let height = answer.height + outlineHeights.metrics.expandedChrome
            return outlineHeights.input(
                anchorID, shape: shape,
                remembered: answer.remembered ? height : nil,
                derived: height)
        default:
            return outlineHeights.input(anchorID, shape: shape)
        }
    }

    /// A row reported its height while rendering real content.
    func learnOutlineRowHeight(
        _ anchorID: String, shape: BookOutlineHeights.Shape, height: CGFloat
    ) {
        outlineHeights.learn(anchorID, shape: shape, height: height)
    }

    /// The card's shape at this width — its preview's wrapped line count, so
    /// one measured card teaches every card that looks like it.
    func outlineCardShape(_ postID: String) -> BookOutlineHeights.Shape {
        outlineHeights.cardShape(postID, excerpt: cardPreview(postID))
    }

    /// **The whole column, as heights and offsets** — the view hands in the
    /// row list (it is the view that knows the book's grouping) and the
    /// arithmetic happens here, through the same per-row brain the rows
    /// themselves ask, so the two can never disagree.
    ///
    /// Built on demand: it is arithmetic over the rows in hand — no read, no
    /// layout, ∝ entries — and building it fresh is cheaper than keeping it
    /// correct. The landing's own story reads it; UNIT 2's flow is the next
    /// consumer.
    ///
    /// The row SPACING is the column's own `VStack(spacing: 10)`, at both
    /// levels; the `leading` is 0, so offsets are from the FIRST ROW rather
    /// than from the top of the scroll's content (the column's lead — the
    /// book's title block and the vertical padding — is voice- and
    /// width-dependent, and nothing consumes an absolute offset yet: the
    /// landing addresses rows by anchor, which is exact now that no row's
    /// height is estimated).
    func outlineHeightManifest(rows: [BookOutlineRows.Row]) -> BookHeightManifest {
        let inputs: [BookHeightManifest.Input] = rows.map { row in
            switch row {
            case .chapter:
                outlineRowInput(row.id, shape: .chapterHeading)
            case .unfiledHeading:
                outlineRowInput(row.id, shape: .unfiledHeading)
            case .tagHeading:
                outlineRowInput(row.id, shape: .tagHeading)
            case .note(let entry):
                outlineRowInput(
                    row.id,
                    shape: isExpanded(entry.postID)
                        ? .expandedNote
                        : outlineCardShape(entry.postID))
            }
        }
        return BookHeightManifest(
            width: outlineContentWidth, spacing: BookOutlineHeights.rowSpacing,
            leading: 0, inputs: inputs)
    }

    /// The VOICE changed: re-measure the type and drop what was learned under
    /// the old one (Study's 16-pt Iowan is not Terminal's 14-pt monospace, and
    /// a card's wrapped line count moves with it). The width is unchanged, so
    /// this goes through the same one door — `stand` compares a stamp that
    /// carries both facts, which is why there is no second rule here.
    func restandOutlineHeights() {
        outlineHeights.stand(at: outlineContentWidth)
        indexPaneHeights.stand(at: indexContentWidth)
    }

    // MARK: - 13u4 UNIT F3 — THE INDEX PANE'S HEIGHTS
    //
    // The same idea as the Outline's above, on the surface UNIT F1 left with
    // the landing authority and no heights: the pane's rows stand at KNOWN
    // heights instead of at a lazy container's average, so the column stops
    // moving under a landing that has already arrived. What lives here is the
    // PLUMBING alone — the width, the lengths read and the doors the rows and
    // the landing ask through; the arithmetic is `BookIndexPaneHeightModel`
    // (pure) and the learning is `BookIndexPaneHeights` (unobserved).

    /// The learned heights and the measured type for the Index pane.
    /// Unobserved on purpose — see that file's own note.
    @ObservationIgnored let indexPaneHeights = BookIndexPaneHeights()

    /// The width the Index pane's content column is really drawing at.
    /// Observed (a width change must re-render every row's placeholder),
    /// written ONLY when it really moves — the same 1-pt tolerance
    /// `StableSurface`, the flow and the Outline compare with.
    private(set) var indexContentWidth: CGFloat = 0

    /// The pane reported its measure.
    func reportIndexContentWidth(_ width: CGFloat) {
        guard width > 0,
              abs(width - indexContentWidth) > stableSurfaceWidthTolerance else { return }
        indexContentWidth = width
        indexPaneHeights.stand(at: width)
    }

    /// Bumped when the lengths land, so a row standing on the estimate
    /// re-renders with it. Observed and read by `indexPaneRowHeight`.
    private(set) var indexExtentsGeneration = 0
    @ObservationIgnored private var indexExtentsInFlight = false

    /// **The lengths read for the INDEX pane — one bounded statement for the
    /// book, ONCE.**
    ///
    /// Unlike the Outline's door this has no "nothing expanded" guard, and
    /// that is the surface's own shape rather than an omission: the Index pane
    /// renders EVERY note's prose (it is the whole book as read-cheap text),
    /// so every row needs its note's length from the first frame. The cost
    /// shape is stated and pinned: ONE `Queries.blockExtents` — lengths
    /// computed in SQL, no prose crossing the boundary — per ENTRY SET, shared
    /// through the book's `flowExtents` cache with the Outline and the reading
    /// flow, so a mode switch re-reads nothing and **nothing at autosave rate
    /// ever reaches this at all**.
    func ensureIndexExtents() {
        let ids = entries.map(\.postID)
        guard !ids.isEmpty, !indexExtentsInFlight, flowExtents.lookup(ids) == nil else { return }
        indexExtentsInFlight = true
        Task { [weak self] in
            guard let self else { return }
            defer { self.indexExtentsInFlight = false }
            guard let rows = try? await session.database.read({ db in
                try Queries.blockExtents(db, containerIDs: ids)
            }) else { return }
            var byPost: [String: [Queries.BlockExtent]] = [:]
            for row in rows { byPost[row.containerID, default: []].append(row) }
            for id in ids where byPost[id] == nil { byPost[id] = [] }
            flowExtents.store(byPost, for: ids)
            // Every derivation taken before the lengths landed was taken over
            // the "not known yet" prior; what a row MEASURED is untouched.
            indexPaneHeights.forgetDerived()
            #if DEBUG
            BookIndexExtentReads.byBook[readingID, default: 0] += 1
            #endif
            indexExtentsGeneration += 1
        }
    }

    /// **Are the book's LENGTHS in hand?** Until they are, a note row stands
    /// on the never-measured prior, and a height that is not honest must not
    /// be decided on (the flow's ladder R2-5 rule). Observed through the
    /// generation, so a row re-decides the moment they land.
    var indexExtentsKnown: Bool {
        _ = indexExtentsGeneration
        return flowExtents.lookup(matching: entries) != nil
    }

    /// What one pane row stands at: the manifest's precedence over this
    /// surface's own answers. `postID` nil ⇒ a chapter heading.
    func indexPaneRowHeight(_ anchorID: String, postID: String?) -> CGFloat {
        BookHeightManifest.resolve(indexPaneRowInput(anchorID, postID: postID)).0
    }

    /// The same question as a manifest input (one precedence brain, asked per
    /// row and per column).
    func indexPaneRowInput(_ anchorID: String, postID: String?) -> BookHeightManifest.Input {
        // Read so a row standing on the estimate re-renders when the lengths
        // land (the Observation dependency IS the mechanism here).
        _ = indexExtentsGeneration
        guard let postID else {
            return indexPaneHeights.input(
                anchorID, derived: indexPaneHeights.metrics.heading, isHeading: true)
        }
        // Element-wise against the entries (no per-ask id-list build — this
        // runs per row per body pass; the 13u2b ladder's NIT 2).
        let extents = flowExtents.lookup(matching: entries)?[postID]
        return indexPaneHeights.input(
            anchorID,
            derived: indexPaneHeights.derived(postID, extents: extents),
            isHeading: false)
    }

    /// A pane row reported its height while rendering real content.
    func learnIndexPaneRowHeight(_ anchorID: String, height: CGFloat, isHeading: Bool) {
        indexPaneHeights.learn(anchorID, height: height, isHeading: isHeading)
    }

    /// **The whole pane, as heights and offsets** — the view hands in the row
    /// list (it is the view that knows the book's grouping) and the arithmetic
    /// happens here, through the same per-row brain the rows themselves ask.
    ///
    /// Built on demand: arithmetic over the rows in hand, no read, no layout,
    /// ∝ rows. Its consumer is the LANDING'S FACTS — the signpost's `offset`,
    /// `derived` and `exact`, which UNIT F1 could only answer with −1 and "all
    /// of them".
    ///
    /// `leading` is 0: offsets are from the FIRST ROW rather than from the top
    /// of the scroll's content, exactly as the Outline's manifest is built,
    /// and nothing consumes an absolute offset — the landing addresses rows by
    /// anchor.
    func indexPaneManifest(rows: [(id: String, postID: String?)]) -> BookHeightManifest {
        BookHeightManifest(
            width: indexContentWidth, spacing: BookIndexPaneHeights.rowSpacing,
            leading: 0,
            inputs: rows.map { indexPaneRowInput($0.id, postID: $0.postID) })
    }

    /// 13f batch 4 (the MOUNT rule): whether this book's PANE is the
    /// focused one. A book in an unfocused pane mounts no live surface —
    /// and it does so through the book's OWN single focus authority below,
    /// which is a second REASON for one mechanism to answer nil, never a
    /// second mechanism (P-3).
    var paneFocused = true

    /// The post that may mount a live surface. Every liveness read goes
    /// through this; `focusedPostID` stays the book's reading position, so
    /// a pane regaining focus restores exactly what it was editing.
    var liveFocusedPostID: String? { paneFocused ? focusedPostID : nil }

    /// Set by the shell when this book sits in a pane: focusing a post
    /// inside an unfocused pane asks for the PANE first, so one click both
    /// claims the pane and opens the post (13f batch 4).
    @ObservationIgnored var onPaneFocusRequest: (() -> Void)?

    /// Focus a post (nil = release): the focused post is always expanded.
    ///
    /// **A bare focus lands at the note's FIRST block** (the Act 10
    /// correction round, ledger row 44's second symptom): a focus with no
    /// caret seeds offset 0. Without a seed the inline editor's first
    /// projection fill carried the insertion point to the document's END
    /// (AppKit moves a zero-length selection that sits inside an edited
    /// range to the range's end — a whole-document insertion at 0 over a
    /// `{0,0}` selection lands at the last character), so a navigator
    /// click on a 215-block story opened it at block 215/215. The
    /// detail editor claims the caret itself on a bare arrival; the inline
    /// editor deliberately never steals the window's focus as a side effect
    /// of RENDERING, so the deliberate act — this focus — carries the seed.
    /// Pinned: `BookOutlineLandingTests.aBareFocusLandsAtTheFirstBlock`.
    func focus(_ postID: String?, caret: Int? = nil, fanBlock: String? = nil) {
        // One line covers all twelve call sites — the reason this rides the
        // model rather than being threaded through the views.
        if postID != nil, !paneFocused { onPaneFocusRequest?() }
        caretSeed = postID == nil ? nil : (caret ?? 0)
        fanSeed = fanBlock
        focusedPostID = postID
        if let postID {
            expandedPosts.insert(postID)
            ensureOutlineExtents()
        }
    }

    /// Unfold a collapsed post (the card's disclosure) — the deliberate act
    /// this surface opens needing (#43(a)).
    func expand(_ postID: String) {
        expandedPosts.insert(postID)
        // 13u2b UNIT 1: an expanded note is the ONLY row whose height needs
        // its note's length, so the lengths read is wanted here and nowhere
        // else — a book read entirely in cards never runs it.
        ensureOutlineExtents()
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
        // 13u2 UNIT A2: the card is about to show again, and the note may
        // have been edited while it was open.
        refreshCardPreviews([postID])
    }

    /// D1's collapse-all half: everything back to cards, focus released —
    /// which under #43(a) is the surface's own default state, reached in one
    /// click from anywhere.
    func collapseAll() {
        let wereOpen = Array(expandedPosts)
        expandedPosts.removeAll()
        focusedPostID = nil
        caretSeed = nil
        fanSeed = nil
        refreshCardPreviews(wereOpen)
    }

    /// Open the whole book at once. Scoped to the entries in hand — a post
    /// that arrives afterwards is COLLAPSED, which is the default and not a
    /// survivor of this gesture (the mirror of what collapse-all used to
    /// carry, and the reason the set tracks this side; see `expandedPosts`).
    func expandAll() {
        expandedPosts = Set(entries.map(\.postID))
        ensureOutlineExtents()
    }

    // MARK: - W21 — the book's PLACE, carried across a mode switch
    //
    // The rule is `BookAnchor`'s (pure); this holds the two facts the rule
    // needs that are not already mine, and the ONE landing request the
    // arriving surface consumes. Nothing here decides anything.

    /// Read ▸ Pages' address, REPORTED by the paginated reader (it owns its
    /// own model, so its place has to travel one step to be readable here).
    private(set) var pagedAnchorPostID: String?
    /// Index's selected note, REPORTED by the index column (wave 2c — the
    /// same pattern, same reason).
    private(set) var indexAnchorPostID: String?
    /// Where the book was last carried to — the fallback for a surface that
    /// tracks no position (Read ▸ Scroll; see `BookAnchor`'s header).
    private(set) var standingAnchorPostID: String?
    /// The post a mode switch asked the ARRIVING surface to land on. One
    /// slot, consumed by whichever surface mounts — never a queue, because a
    /// book shows exactly one mode at a time.
    private(set) var pendingReveal: String?

    /// The paginated reader's report (not a decision — the address is its).
    func notePagedAnchor(_ postID: String?) {
        pagedAnchorPostID = postID
    }

    /// The index column's report (not a decision — the selection is its).
    func noteIndexAnchor(_ postID: String?) {
        indexAnchorPostID = postID
    }

    /// **The index column's SELECTION** (18d batch 1 — the walk's second
    /// finding). Deliberately NOT `indexAnchorPostID`: that one is W21's
    /// CARRY ("if you clicked over to another mode, where would you land"),
    /// and the index writes it only on a selection SHE makes — the arrival's
    /// own seed passes `report: false`, so a book opened straight into Index
    /// has a highlighted row, a scrolled pane, and a nil anchor. The box's
    /// question is "is a note selected right now", which the seeded row
    /// answers yes to; so it gets its own report and the carry's cadence is
    /// untouched.
    private(set) var indexSelectedPostID: String?

    func noteIndexSelection(_ postID: String?) {
        indexSelectedPostID = postID
    }

    /// **The index's LIVE note** (18d batch 1): the note whose block the
    /// index's one live pane is in, reported the same way its selection is.
    /// Index mounts no full-document editor by design — it is a projection
    /// tier that upgrades ONE block (`BookIndexEditModel`, P-3) — so the
    /// book's own `liveFocusedPostID` cannot answer for it, and the sidebar
    /// box's third state needs an answer in every editing mode.
    private(set) var indexLivePostID: String?

    func noteIndexLive(_ postID: String?) {
        indexLivePostID = postID
    }

    /// **VX-303 — the Index's live BLOCK and its pane's CARET**, reported the
    /// same way its live note is, for the open doors (`BookOpenDoor`): the
    /// block the one live pane holds, and the last caret that pane reported
    /// (`PaneSurfaceView.onSelectionChange` — consumed, never changed), with
    /// the block it reported from. Read only at a door's press, so neither is
    /// observed: a caret walking inside a block wakes nobody.
    @ObservationIgnored private(set) var indexLiveBlockID: String?
    @ObservationIgnored private(set) var indexCaret: (postID: String, place: BookOpenDoor.Place)?

    func noteIndexLiveBlock(_ blockID: String?) {
        indexLiveBlockID = blockID
    }

    func noteIndexCaret(postID: String, blockID: String, offsetInBlock: Int) {
        indexCaret = (postID, BookOpenDoor.Place(blockID: blockID, offsetInBlock: offsetInBlock))
    }

    // MARK: - 18o U4 (R-18k-6) — the note she LEAVES inside the book

    /// The note her caret was last in (`BookNoteTrail` holds the rule).
    /// View state, like the reports above: never persisted, ids only.
    @ObservationIgnored private var noteTrail = BookNoteTrail()

    /// **The book's LEAVING signal** — raised with a note she has just moved
    /// off (into a different note, or out of the book). Wired by `BookView`
    /// to `AppSession.savepointOnLeaving` (`SavepointOnLeave.wire(book:)`); a
    /// no-op by default, so a book built in a test or a preview writes
    /// nothing — `WorkspaceModel.onNotesLeft`'s shape, for the notes the
    /// workspace's shown set cannot see.
    @ObservationIgnored var onNoteLeft: (String) -> Void = { _ in }

    /// The book's note state as the sidebar box publishes it (`BookView`
    /// derives it through `BookNoteBox`, from the facts above and the mode).
    func notePlaceChanged(_ state: NoteBoxState) {
        if let left = noteTrail.observe(state) { onNoteLeft(left) }
    }

    /// The book is leaving its pane (the pane shows something else, the split
    /// closes, the window goes): the note she was in is left.
    func leaveBook() {
        if let left = noteTrail.leaveBook() { onNoteLeft(left) }
    }

    /// The facts `BookAnchor` reads, assembled from my own state.
    var anchorPlace: BookAnchor.Place {
        BookAnchor.Place(
            focusedPostID: focusedPostID,
            spreadPostIDs: spreadEntries.map(\.postID),
            pagedPostID: pagedAnchorPostID,
            indexPostID: indexAnchorPostID,
            standingPostID: standingAnchorPostID)
    }

    /// THE CARRY (her round-8 ruling): capture where the DEPARTING mode is
    /// and ask the arriving one to land there. Called by the mode picker
    /// BEFORE the mode changes — the departing mode is the one that knows.
    ///
    /// A place it cannot name leaves both slots alone: a book with nothing
    /// focused and nothing read has no place to carry, and clearing the
    /// standing anchor there would throw away the last one she had.
    func carryPlace(from mode: BookStructureModel.ViewMode, readForm: BookStructureModel.ReadForm) {
        guard let post = BookAnchor.currentPost(
            mode: mode, readForm: readForm, place: anchorPlace)
        else { return }
        standingAnchorPostID = post
        pendingReveal = post
    }

    /// An outside door (W20's ascent) asking this book to open AT a post.
    func requestReveal(_ postID: String) {
        standingAnchorPostID = postID
        pendingReveal = postID
        pendingLanding = nil
    }

    /// The arriving surface took the landing. Idempotent. A block-precise
    /// landing (`pendingLanding`) dies with the note landing it rode.
    func consumeReveal() {
        pendingReveal = nil
        pendingLanding = nil
    }

    // MARK: - The scrolled-open door (the correction round, row 38 — 13u
    // item 17 pulled in): a BLOCK-precise landing

    /// The block a read-cheap click asked the editing surface to make live
    /// — `LandingTarget`, the one door value. Rides beside `pendingReveal`
    /// (the note half, which every surface already lands); the book Index
    /// consumes the block half. Set only through `requestLanding`.
    private(set) var pendingLanding: LandingTarget?

    /// The scrolled-open door's request: land in this note, at this block.
    /// The caller switches the mode; the arriving surface lands both halves.
    func requestLanding(_ target: LandingTarget) {
        standingAnchorPostID = target.postID
        pendingReveal = target.postID
        pendingLanding = target
    }

    // MARK: - Outline's CHAPTER landing (the Act 10 correction round, rows
    // 9/12/14/44 — one landing door, not two)

    /// The chapter Outline was asked to put at the top of the page. Beside
    /// `pendingReveal` (a NOTE landing) rather than folded into it: every
    /// consumer of the note slot reads a post id, and a chapter is not one.
    /// The navigator's chapter row and the body's chapter heading both
    /// request through here — before this round the navigator wrote a
    /// view-private `scrollTarget` beside W21's slot, so the book had TWO
    /// landing mechanisms and a test could reach neither.
    private(set) var pendingChapterReveal: String?

    func requestChapterReveal(_ sectionID: String) {
        pendingChapterReveal = sectionID
    }

    /// Outline took the chapter landing. Idempotent.
    func consumeChapterReveal() {
        pendingChapterReveal = nil
    }
}

#if DEBUG
/// 13u2 UNIT A2's oracle: how many bounded card-preview reads the book has
/// performed, and over how many notes. It replaces `BookOutlineFactsReads`,
/// which counted WHOLE-note renders done per realized row — machinery this
/// unit deletes, and a counter with no incrementer is a pin that cannot
/// fail. The claim these numbers carry is stronger than the one they
/// replace: the book reads each entry's opening ONCE, whatever the rows do
/// afterwards.
@MainActor
enum BookCardPreviewReads {
    /// Database round trips.
    static var reads = 0
    /// Notes read across them.
    static var notes = 0

    static func reset() {
        reads = 0
        notes = 0
    }
}
#endif
