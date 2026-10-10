//
//  ReadingFlowView.swift
//  Variorum
//
//  Phase 13, B3 — direction C as a VIEW MODE (R2/R56: "iBooks as an
//  editing surface… an option for a view", reachable from any book in
//  either voice; a FINISHED book opens here and shows nothing but the
//  text). One continuous page column; chapter breaks are typographic;
//  posts flow together. Clicking a post opens it for editing in the book
//  view (in-place waking is Stage C's v2-canon surface). Text loads
//  lazily per post — viewport-shaped, P3. Round 3 MAJOR: the column WAS a
//  plain VStack — every row materialized and fetched on open, cost ∝ book
//  size, exactly the shape this header already claimed not to have; the
//  DEBUG materialization counter below pins the bound.
//
//  The Act 10 correction round, batch H (ledger row 95 — the flow's
//  landing lands WRONG whenever the stories between the page and the
//  target have not loaded): the column is SEGMENTED, the book Outline's
//  row-53 answer applied here. A `LazyVStack` estimates every row it has
//  not realized at the AVERAGE of the rows it has measured, and an
//  unloaded story is one line tall until its text is read — so a far
//  story's offset was wrong by tens of thousands of points and no scroll
//  request (animated or not, by identity or not) could land on it; a
//  stability-driven corrector made it WORSE (every hop into the void
//  doubled the column's estimate — 35,426 → 116,780 pt for ~58,000 of
//  content, ladder fix 1's own log). Now every STORY is a DIRECT child of
//  the column with an HONEST height from its first frame — its remembered
//  size, or an estimate from its blocks' lengths (`FlowHeightEstimate`,
//  fed by `Queries.blockExtents`: no prose crosses the boundary) — and is
//  virtualized by the flow itself: the real text when near the viewport,
//  a placeholder of that height when far (`NearViewportObserver` +
//  `StableSurface`, hoisted from the Outline). The small rows — the title,
//  chapter headings, the closing mark — stay lazy in runs. One unanimated
//  `scrollTo` on the identity then lands exactly (the geometry above the
//  target is what it says it is), and the landing ANCHORS the target for
//  the settle that follows — the one thing that can still move it is a
//  story above it entering the near band and trading its estimate for its
//  real height, and each time the target reports itself off the top the
//  flow re-lands it on the next turn, a bounded few times, never a hop
//  into a void (there is none).
//

import AppKit
import SwiftUI
import VariorumCore

struct ReadingFlowView: View {
    let session: AppSession
    let readingName: String?
    let grouped: [(section: ReadingSection?, entries: [Queries.ReadingEntry])]
    /// Wake this post for editing — with the BLOCK under the click when a
    /// paragraph was clicked (the correction round, row 38: the scrolled-
    /// open door lands at THAT block; nil = the note as a whole).
    let onWake: (_ postID: String, _ blockID: String?) -> Void
    /// 13f W21: the post a mode switch (or W20's ascent) asked this surface
    /// to land on. Defaults nil, so every pre-existing call site is unchanged.
    var reveal: String?
    /// …and the acknowledgement, so the request is consumed exactly once.
    var onRevealLanded: (() -> Void)?
    /// Batch H: the stories' remembered sizes — the BOOK's (`BookViewModel.
    /// flowSurfaceSizes`), so a story measured once stays measured for the
    /// session across mode switches. nil (every pre-batch call site, the
    /// test hosts) ⇒ the view's own memory below.
    var sizes: SurfaceSizeMemory?
    /// Ladder R2-4: the book's block extents, cached for the BOOK
    /// (`BookViewModel.flowExtents`) — the flow is re-created per mode, and
    /// without the cache every return to Read ▸ Scroll re-ran the
    /// book-proportional lengths query. nil ⇒ the view's own cache below.
    var extentsCache: FlowExtentsCache?

    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    /// The fallback memory when the host passes none (`@State`, so it
    /// survives the host's re-evaluations — a fresh box per body would
    /// forget every story the moment the reveal slot changed).
    @State private var ownSizes = SurfaceSizeMemory()
    @State private var ownExtentsCache = FlowExtentsCache()
    /// The book's block extents, keyed by post — the estimate's input, ONE
    /// lengths-only query per entry set (the paged reader's model tier).
    /// nil until the read lands: a never-measured story then stands at
    /// `FlowHeightEstimate.unknownHeight`.
    @State private var extents: [String: [Queries.BlockExtent]]?
    /// The page column's width (the measure the estimate wraps at, and the
    /// width a remembered size must match to apply).
    @State private var columnWidth: CGFloat?
    /// The pending landing's ABOVE-TARGET bookkeeping — a reference box: no
    /// `@State` write per geometry report (the Outline landing's own lesson).
    /// **13u2b UNIT 2:** the landing's own half of this box (the anchor, the
    /// corrections, the timer, the target's last top) is the ONE authority's
    /// now; what stays is what only this surface knows — which stories are
    /// near, and which of those have said they settled.
    @State private var landing = FlowLanding()
    #if DEBUG
    /// **This flow's own name in the DEBUG oracles** (18k UNIT C4 — the
    /// `MastheadStamp.oracleOwner` shape). DEBUG-only.
    @State private var oracleOwner = UUID()
    #endif
    /// **THE ONE LANDING AUTHORITY** (`Surface/LandingAuthority.swift`): the
    /// aim/hold/quiet/correct discipline this surface used to carry as a
    /// hand-copy of the book Outline's, parameterized instead
    /// (`LandingPolicy.readingFlow` — the same numbers, one place).
    #if DEBUG
    @State private var authority = LandingAuthority(
        policy: .readingFlow,
        storyboard: LandingStoryboard(
            note: { ReadingFlowGeometry.trace.append($0) },
            dump: {
                let start = ReadingFlowGeometry.trace
                    .lastIndex(where: { $0.hasSuffix(" LAND") }) ?? 0
                return ReadingFlowGeometry.trace[start...].joined(separator: " | ")
            }))
    #else
    @State private var authority = LandingAuthority(policy: .readingFlow)
    #endif
    /// What this column's rows REPORTED while rendering real content — the
    /// manifest's `measured` arm (13u2b UNIT 2).
    @State private var heights = FlowRowHeights()

    private var page: ReadingPageTokens {
        scheme == .dark ? .dark : .light
    }
    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }
    private var memory: SurfaceSizeMemory { sizes ?? ownSizes }

    /// The flow's own coordinate space — the viewport's top is 0 there; the
    /// near/far observers and the landing's anchor reports read it.
    static let flowSpace = "reading-flow"
    /// **The flow's landing policy** — the batch-H + row-100 numbers,
    /// unchanged by 13u2b UNIT 2's hoist and now stated in one place with
    /// the reasoning for each (`LandingPolicy.readingFlow`). The two names
    /// below stay as this surface's word for them (the pins speak them).
    static let landingPolicy = LandingPolicy.readingFlow
    /// Within this many points of the top, a landing is DONE — and within
    /// this many the pins accept it (ONE number, ladder R2-7: at 2 pt the
    /// finisher re-landed on 3-pt drifts the pin would have accepted — the
    /// field guide's own log spent two of six corrections on `top=5`,
    /// `top=3`; a book of many short notes above the target could exhaust
    /// the budget on drifts and give up a few points short).
    static var landingTolerance: CGFloat { landingPolicy.tolerance }
    /// The gap the column puts between rows, at BOTH levels (the segments'
    /// and each run's) — so the manifest's offsets are the column's own
    /// arithmetic and not a second number.
    static let rowSpacing: CGFloat = 28
    /// Everything above the first row: the page column's own top padding.
    /// The flow's title is a ROW (unlike the Outline's title block), so this
    /// is the whole of the lead — which is what makes this surface the first
    /// consumer of an ABSOLUTE offset in the column's content space.
    static let columnLead: CGFloat = 40
    /// How far beyond the viewport a story still counts as near — this far
    /// above it, twice this far below (`NearViewportObserver`'s band: a row
    /// is near while its distance from the top-edge region is under the
    /// margin), and far again only beyond three times it (the hysteresis).
    /// Generous enough that the next story is realized ~2,400 pt before it
    /// scrolls into view (a story's read takes a fraction of a second) and
    /// released well after it leaves; smaller than the Outline's 2,500
    /// because the flow's rows are ALL heavy and a book of many short notes
    /// would otherwise realize a hundred surfaces at once (the round-3
    /// virtualization pin's 150-note book counts them).
    static let nearMargin: CGFloat = 1200
    /// How long a story's surface holds one size before `StableSurface`
    /// adopts it and drops the reservation. Short here, deliberately: the
    /// flow's surface is a column of SwiftUI `Text` that lays out whole in
    /// ONE pass (the first real report IS the final height — there is no
    /// TK2 provisional-width first measure, row 54's class, which is what
    /// the Outline's 1 s default guards). The walk found the cost of the
    /// default: a story above the landed target held its ESTIMATE for a
    /// second after its text was in, then dropped 181 pt under the page
    /// after the landing had already finished. (Ladder R2-2/R2-3: the
    /// finisher no longer times this interval itself — the surface SAYS
    /// when it has settled, `StableSurface.settled` → `storySettled`.)
    static let surfaceSettleInterval: TimeInterval = 0.15

    private var rows: [FlowRows.Row] {
        FlowRows.rows(readingName: readingName, grouped: grouped)
    }

    var body: some View {
        ScrollViewReader { proxy in
            column
                .coordinateSpace(name: Self.flowSpace)
                // Batch H: the landing listens to the WHOLE column — any
                // content-height change re-arms its quiet interval, and a
                // scroll by the user ends it. Ladder R2-7 (row 99's eye):
                // the scroll OFFSET rides beside the height so each `top=`
                // report in the DEBUG story carries where the page was —
                // a content transient and an offset transient then read
                // apart at a glance. Only a HEIGHT change re-arms.
                .onScrollGeometryChange(for: FlowScrollFacts.self) { geometry in
                    FlowScrollFacts(
                        offset: geometry.contentOffset.y,
                        height: geometry.contentSize.height)
                } action: { old, new in
                    landing.lastOffset = new.offset
                    if old.height != new.height { contentResized(new.height, proxy) }
                }
                .onScrollPhaseChange { _, phase in
                    if phase == .interacting { userScrolled() }
                }
                // 13f W21 — the flow's LANDING half. (Its reporting half
                // does not exist: this surface tracks no scroll position,
                // and per-row visibility reporting is the machinery 13c 2A
                // deleted on her A6 ruling. Leaving the scroll therefore
                // carries the book's standing anchor — `BookAnchor`'s header
                // states it, and the batch record lists it for her walk.)
                .onAppear { land(proxy) }
                .onChange(of: reveal) { _, _ in land(proxy) }
                // Ladder R2-12: a pending landing dies WITH the flow (a mode
                // switch mid-landing) — its check would otherwise re-arm
                // itself against a dead proxy for the whole time budget and
                // write a DONE into whatever flow mounts next (the harness's
                // own oracle read the previous test's landing).
                .onDisappear {
                    landing.end()
                    authority.end()
                    #if DEBUG
                    // 18k C4: this flow's row tops, and no other window's.
                    ReadingFlowGeometry.release(owner: oracleOwner)
                    #endif
                }
                .task(id: grouped.flatMap { $0.entries.map(\.postID) }) {
                    await loadExtents()
                }
        }
    }

    // MARK: - The column

    private var column: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Batch H: SEGMENTED — runs of small rows keep a lazy
                // container (uniform rows, honest estimates); every story is
                // a DIRECT child at an honest height (`FlowStoryRow`), so the
                // column's geometry is exact and a built row's `.id` is
                // always known to the scroll reader.
                VStack(spacing: Self.rowSpacing) {
                    ForEach(FlowRows.segments(rows)) { segment in
                        switch segment {
                        case .run(let small):
                            // **13u2b UNIT 2: the runs are no longer LAZY.**
                            // A lazy container answers "how tall is a row I
                            // have not realized" with the average of the ones
                            // it has — and the one row a CHAPTER landing aims
                            // at is a heading, which lives here. The Outline
                            // had to virtualize its runs at manifest heights
                            // (400 rows at the window's cap); this column's
                            // small rows are a title, a closing mark and one
                            // heading per chapter — fifteen cheap `Text`s on
                            // Sherlock — so they simply all exist, which is
                            // strictly more exact than any placeholder and
                            // needs no manifest arm at all.
                            VStack(spacing: Self.rowSpacing) {
                                ForEach(small) { row in
                                    smallRow(row)
                                }
                            }
                            .id(segment.id)
                        case .story(let entry):
                            FlowStoryRow(
                                session: session, entry: entry, page: page,
                                memory: memory,
                                estimate: estimate(for: entry.postID),
                                extentsKnown: extents != nil,
                                columnWidth: columnWidth,
                                onWake: { blockID in onWake(entry.postID, blockID) },
                                onNear: { near in landing.rowNear(entry.postID, near) },
                                onSettled: { storySettled(entry.postID) },
                                onLoaded: { })
                                .id(segment.id)
                                .flowAnchor(segment.id) { top, _ in
                                    // A story's own measured height needs no
                                    // second store: `SurfaceSizeMemory` IS
                                    // it, and the manifest reads it as the
                                    // REMEMBERED arm (18d's U-12 memory, per
                                    // note × surface × width).
                                    rowMoved(segment.id, top: top, height: nil)
                                }
                        }
                    }
                }
                .frame(maxWidth: 600)
                .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
                    if columnWidth != width { columnWidth = width }
                }
                .padding(.horizontal, 56)
                .background(page.paper)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .shadow(color: .black.opacity(scheme == .dark ? 0 : 0.10), radius: 12, y: 3)
                .padding(.vertical, 40)
            }
            .frame(maxWidth: .infinity)
        }
        // 13u2 UNIT B (her item 19): the room around the CREAM PAGE is the
        // voice's own, never a palette's — a page floating on a bold pastel is
        // exactly what the page's voice-independence exists to avoid.
        .background(ReadingPageTokens.room(voice: tokens.voice, dark: scheme == .dark))
    }

    /// A small row — the title, a chapter heading, the closing mark. **Every
    /// one of them carries its anchor and reports its geometry since 13u2b
    /// UNIT 2**: the anchor so a landing can address it (a chapter heading is
    /// what a chapter landing aims AT), and the report so the column knows
    /// what it is tall and a landing on a row the page is already at can
    /// terminate.
    @ViewBuilder
    private func smallRow(_ row: FlowRows.Row) -> some View {
        switch row {
        case .title(let name):
            Text(name)
                .font(page.serifTitle)
                .foregroundStyle(page.ink)
                .padding(.top, 56)
                .flowAnchor(row.id) { top, height in
                    rowMoved(row.id, top: top, height: height)
                }
        case .chapter(let section):
            Text(section.name.uppercased())
                .font(.system(size: 12, weight: .medium, design: .serif))
                .tracking(3)
                .foregroundStyle(page.chapterInk)
                .padding(.top, 22)
                .flowAnchor(row.id) { top, height in
                    rowMoved(row.id, top: top, height: height)
                }
        case .end:
            Text("· · ·")
                .font(page.serif)
                .foregroundStyle(page.pageMeta)
                .padding(.vertical, 40)
                .flowAnchor(row.id) { top, height in
                    rowMoved(row.id, top: top, height: height)
                }
        case .post:
            // Never in a run — `FlowRows.segments` makes every post a story
            // segment; the switch is exhaustive for the compiler's sake.
            EmptyView()
        }
    }

    // MARK: - The honest estimate

    /// A never-measured story's height: from its blocks' lengths once the
    /// extents have landed; the unknown fallback before that. At the
    /// column's CURRENT width (ladder R2-1/R2-8: the one fallback for a
    /// column that has not reported yet is `FlowHeightEstimate.
    /// defaultColumnWidth`, here and in the row's reservation alike).
    private func estimate(for postID: String) -> CGFloat {
        guard let extents else { return FlowHeightEstimate.unknownHeight }
        return FlowHeightEstimate.height(
            extents: extents[postID] ?? [],
            metrics: FlowHeightEstimate.metrics(
                columnWidth: columnWidth ?? FlowHeightEstimate.defaultColumnWidth))
    }

    // MARK: - 13u2b UNIT 2 — the column's own geometry, as a manifest

    /// **What this column is tall, row by row, at this width** — the same
    /// `BookHeightManifest` the book Outline builds, over the flow's rows.
    ///
    /// Its consumer here is the LANDING STORY and the Release SIGNPOST rather
    /// than the rows (the rows have stood at honest heights since batch H —
    /// every story a direct child at its remembered or estimated height, and
    /// since this unit every small row simply exists), so what it buys is the
    /// ANSWER to the question her stutter report could not answer: how much of
    /// the geometry above the thing she clicked was still arithmetic.
    ///
    /// The three sources are the manifest's own, read off the surfaces that
    /// already own them: **measured** — what a small row reported while
    /// rendering real content; **remembered** — a story's `SurfaceSizeMemory`
    /// record, but only at THIS width (18d's per-width refusal, never
    /// relaxed); **derived** — a story's estimate from its blocks' lengths,
    /// and a small row's first-frame constant.
    ///
    /// Offsets are ABSOLUTE in the column's content space: the lead is the
    /// page column's own top padding (`columnLead`) and the title is a ROW, so
    /// unlike the Outline's there is nothing unmeasured above the first row.
    private var heightManifest: BookHeightManifest {
        let width = columnWidth ?? FlowHeightEstimate.defaultColumnWidth
        let inputs: [BookHeightManifest.Input] = rows.map { row in
            switch row {
            case .title:
                BookHeightManifest.Input(
                    id: row.id, measured: heights.height(of: row.id),
                    derived: FlowRowHeights.title)
            case .chapter:
                BookHeightManifest.Input(
                    id: row.id, measured: heights.height(of: row.id),
                    derived: FlowRowHeights.chapter)
            case .end:
                BookHeightManifest.Input(
                    id: row.id, measured: heights.height(of: row.id),
                    derived: FlowRowHeights.end)
            case .post(let entry):
                // 18l-b U4 (D1): the SAME input the row stands on
                // (`FlowStoryRow.honestHeight`) — one brain, two askings.
                FlowHeightEstimate.storyInput(
                    id: row.id, remembered: memory.size(entry.postID),
                    columnWidth: width, estimate: estimate(for: entry.postID))
            }
        }
        return BookHeightManifest(
            width: width, spacing: Self.rowSpacing, leading: Self.columnLead, inputs: inputs)
    }

    /// The extents for this entry set: from the book's cache when it holds
    /// them (a mode switch re-reads nothing — R2-4), else ONE lengths-only
    /// query, stored for the next mount. Keyed by the entry-ID list, so a
    /// changed membership re-reads; a story whose TEXT changed while the
    /// book stayed open keeps its estimate until then (a visited story is
    /// governed by its remembered size; an unvisited one is off by the edit
    /// and corrected at its settle — the bounded, stated staleness).
    private func loadExtents() async {
        let postIDs = grouped.flatMap { $0.entries.map(\.postID) }
        let cache = extentsCache ?? ownExtentsCache
        if let cached = cache.lookup(postIDs) {
            extents = cached
            return
        }
        #if DEBUG
        ReadingFlowExtentsReads.count += 1
        #endif
        let rows = (try? await session.database.read { db in
            try Queries.blockExtents(db, containerIDs: postIDs)
        }) ?? []
        let byPost = Dictionary(grouping: rows, by: \.containerID)
        cache.store(byPost, for: postIDs)
        extents = byPost
    }

    // MARK: - The landing (batch H: one unanimated scroll, then ANCHORING — bounded)

    /// Put the requested post's row at the top of the page (no animation
    /// — an animated scroll toward a moving offset was row 44's class) and
    /// hold it there while the column settles. The first scroll is exact:
    /// every row above the target stands at a stated height. What can
    /// still move the target afterwards is a story ABOVE it entering the
    /// near band and trading its estimate for its real height (one event
    /// per such story; the extents landing is another). Each time the
    /// target REPORTS itself off the top while the landing is pending, the
    /// flow re-lands it on the next turn — one frame of shift, never a
    /// second — bounded by the policy's correction budget; the quiet-interval
    /// check then ends the landing once the near rows above have loaded
    /// and the page has held still. Never a hop into an unrealized void:
    /// there is none — a built row's identity is always known.
    private func land(_ proxy: ScrollViewProxy) {
        guard let reveal else { return }
        onRevealLanded?()
        let anchor = FlowRows.landingAnchor(for: reveal, grouped: grouped)
        landing.begin(anchor: anchor, target: reveal, storiesInOrder: storyIDs)
        authority.land(
            anchor,
            // What this column KNOWS about the landing — its rows, the
            // target's computed offset, and how much of the geometry above it
            // is still arithmetic. Numbers only, and they ship (the SIGNPOST).
            facts: LandingFacts(manifest: heightManifest, anchor: anchor),
            // The flow's own veto: every near story above the target has SAID
            // it settled (`StableSurface.settled` — geometry, never a clock).
            mayFinish: { landing.aboveTargetSettled() }
        ) { id in
            proxy.scrollTo(id, anchor: .top)
        }
    }

    private var storyIDs: [String] {
        grouped.flatMap { $0.entries.map(\.postID) }
    }

    /// A row reported where its top sits (and, for a SMALL row, what it is
    /// tall). Every report feeds the DEBUG oracle and the authority's seed;
    /// the pending TARGET's also re-arms the quiet interval — the decision is
    /// the interval's, never the report's.
    private func rowMoved(_ rowID: String, top: CGFloat, height: CGFloat?) {
        #if DEBUG
        ReadingFlowGeometry.recordAnchor(
            FlowRows.postID(ofAnchor: rowID) ?? rowID, top: top, owner: oracleOwner)
        #endif
        // A SMALL row's height is a fact about this column at this width (it
        // always renders real content); a story's is `SurfaceSizeMemory`'s.
        if let height {
            heights.learn(
                rowID, height: height,
                at: columnWidth ?? FlowHeightEstimate.defaultColumnWidth)
        }
        #if DEBUG
        if authority.anchor == rowID {
            ReadingFlowGeometry.trace.append(
                "top=\(Int(top)) offset=\(Int(landing.lastOffset)) corrections=\(authority.corrections)")
        }
        #endif
        // **13u2 UNIT A, ledger row 100 — THE REPORT NO LONGER RE-LANDS.** It
        // records and re-arms; the decision is the quiet interval's
        // (`LandingAuthority`), which is the book Outline's own discipline and the
        // reason the Outline converges where this surface did not.
        //
        // REPRODUCED AND TRACED (dev store, Sherlock, a ~950 pt window, the
        // eleventh chapter clicked after the ninth had landed — the record's
        // TRACE 3 has the log): the content SHRINKS 2-3 pt a report for about a
        // second as the stories above trade their estimates for real heights,
        // and each shrink moves the target with **the scroll offset CONSTANT**
        // (`offset=225936` across `top=-4 … -16`). A re-land issued from inside
        // that storm DOES move the offset (225920) and the very next report
        // shows it RESTORED (225936, the target back at -16): SwiftUI's
        // `ScrollView` re-applies its own offset on a content-size change and
        // undoes a proxy `scrollTo` made during it. So all six corrections were
        // spent on 2-pt drifts, and when the real transient arrived
        // (`content=306460`, `top=-77`, then `top=1857`) there was no budget
        // left: `gave up at top=1857.0 after 6 re-lands, 4218 ms` — two
        // paragraphs into the wrong story, which is the defect she can meet.
        //
        // A correction issued from QUIET sticks, and the budget now buys six of
        // those instead of six undone ones. Progress is still guaranteed under a
        // storm because the authority's own ceiling (`LandingPolicy.maxWait`)
        // fires the look whether or not the column ever goes quiet.
        //
        // **13u2b UNIT 2:** every row's report goes to the authority, not only
        // the target's — that is the SEED that makes a landing on the row the
        // page is already at terminate (measured RED here before this unit:
        // `gave up at top=unrealized after 0 re-lands, 4211 ms`, twice).
        authority.noteTop(rowID, top)
    }

    /// The column's content height changed (a story loaded, the extents
    /// landed): the layout is still settling — re-arm the interval.
    private func contentResized(_ height: CGFloat, _ proxy: ScrollViewProxy) {
        authority.contentChanged(height)
    }

    /// A story's surface settled (R2-2): recorded for the finisher, and —
    /// while a landing is pending — the quiet interval is re-armed, so the
    /// check that reads the settle runs a turn AFTER the reservation's drop
    /// has laid out (never inside the turn that flipped it).
    private func storySettled(_ postID: String) {
        landing.rowSettled(postID)
        // An event the authority cannot see: look again a turn later, so the
        // look that reads the settle runs AFTER the reservation's drop has
        // laid out (never inside the turn that flipped it).
        authority.nudge()
    }

    /// The user scrolled while a landing was pending: she took over — the
    /// landing ends where she put the page, never fighting her.
    private func userScrolled() {
        authority.userTookOver()
    }

}

nonisolated struct FlowScrollFacts: Equatable, Sendable {
    var offset: CGFloat
    var height: CGFloat
}

/// **What only this surface knows about a pending landing** — which stories
/// are near the viewport and which of those have said they settled, so the
/// authority can be told whether it may finish.
///
/// **13u2b UNIT 2:** the landing's own bookkeeping (the anchor's last top, the
/// corrections, the timer, the proxy) left this box for `LandingAuthority`;
/// what remains is this list and the page's scroll offset for the story. The
/// type's shape — `begin` / `end` / `rowNear` / `rowSettled` /
/// `aboveTargetSettled` — is untouched, and so is the pin that drives it
/// (`theFinisherWaitsOnTheSurfacesWordNeverOnAClock`).
@MainActor
final class FlowLanding {
    /// The row the landing scrolls to (a story's, or its chapter heading's).
    private(set) var anchor: String?
    /// The story the reveal named.
    private(set) var target: String?
    /// The page's scroll offset at the last geometry report (R2-7: logged
    /// beside every `top=` so row 99's class is self-identifying).
    var lastOffset: CGFloat = 0
    /// The stories in page order, and which of them are near / SETTLED —
    /// so the check can tell whether the rows ABOVE the target that will
    /// realize have finished trading their estimates for real heights.
    /// `settled` is fed by the surfaces themselves (`StableSurface.settled`,
    /// ladder R2-2) and cleared when a story goes far (its surface is gone;
    /// a re-realized one reports again — R2-3's once-stamped date is gone
    /// with the clock it served).
    private var order: [String] = []
    private var near: Set<String> = []
    private var settled: Set<String> = []

    func begin(anchor: String, target: String, storiesInOrder: [String]) {
        self.anchor = anchor
        self.target = target
        order = storiesInOrder
    }

    func end() {
        anchor = nil
        target = nil
    }

    func rowNear(_ postID: String, _ isNear: Bool) {
        if isNear {
            near.insert(postID)
        } else {
            near.remove(postID)
            settled.remove(postID)
        }
    }

    /// The story's surface held one real size for its settle interval and
    /// dropped its reservation — the surface's own word (R2-2).
    func rowSettled(_ postID: String) {
        settled.insert(postID)
    }

    /// Every near story above the target has SETTLED — its surface has said
    /// so (a far one is a placeholder of a stated height and will not move
    /// the page). Geometry, never a clock: a near story that has not
    /// reported settled blocks the finish however long it has been loaded.
    func aboveTargetSettled() -> Bool {
        guard let target, let at = order.firstIndex(of: target) else { return true }
        return order[..<at].allSatisfy { postID in
            !near.contains(postID) || settled.contains(postID)
        }
    }
}

/// The flow's rows, FLAT, each with the identity the landing scrolls to
/// (`FlowRows.anchor(postID)` — W21's `flow-<id>`): the reading's title, a
/// chapter's heading, a post, the closing mark — and, since batch H, the
/// SEGMENTS: runs of small rows (lazy) and stories (direct children). Pure,
/// so the order, the anchors and the split are pinnable without a window.
nonisolated enum FlowRows {
    enum Row: Identifiable {
        case title(String)
        case chapter(ReadingSection)
        case post(Queries.ReadingEntry)
        case end

        var id: String {
            switch self {
            case .title: "flow-title"
            case .chapter(let section): "flow-chapter-\(section.id)"
            case .post(let entry): FlowRows.anchor(entry.postID)
            case .end: "flow-end"
            }
        }
    }

    /// A stretch of the column: a RUN of small rows sharing one lazy
    /// container, or ONE story standing as a direct child (row 95).
    enum Segment: Identifiable {
        case run([Row])
        case story(Queries.ReadingEntry)

        var id: String {
            switch self {
            case .run(let rows): "run-" + (rows.first?.id ?? "empty")
            case .story(let entry): FlowRows.anchor(entry.postID)
            }
        }
    }

    /// The landing anchor of a post's row — the row's own identity.
    static func anchor(_ postID: String) -> String { "flow-\(postID)" }

    /// The post behind a story row's anchor (nil for a heading's).
    static func postID(ofAnchor id: String) -> String? {
        guard id.hasPrefix("flow-"), !id.hasPrefix("flow-chapter-"),
              id != "flow-title", id != "flow-end" else { return nil }
        return String(id.dropFirst("flow-".count))
    }

    /// Where a reveal of this post LANDS (batch H): at its CHAPTER's
    /// heading when it opens the chapter — a chapter click reads as a
    /// chapter, heading first, the way a book opens — else at the post's
    /// own row.
    static func landingAnchor(
        for postID: String,
        grouped: [(section: ReadingSection?, entries: [Queries.ReadingEntry])]
    ) -> String {
        for group in grouped {
            if let section = group.section, group.entries.first?.postID == postID {
                return Row.chapter(section).id
            }
        }
        return anchor(postID)
    }

    static func rows(
        readingName: String?,
        grouped: [(section: ReadingSection?, entries: [Queries.ReadingEntry])]
    ) -> [Row] {
        var rows: [Row] = []
        if let readingName { rows.append(.title(readingName)) }
        for group in grouped {
            if let section = group.section { rows.append(.chapter(section)) }
            rows.append(contentsOf: group.entries.map(Row.post))
        }
        rows.append(.end)
        return rows
    }

    /// Split the flat rows at every post. Pure — pinned.
    static func segments(_ rows: [Row]) -> [Segment] {
        var result: [Segment] = []
        var run: [Row] = []
        for row in rows {
            if case .post(let entry) = row {
                if !run.isEmpty { result.append(.run(run)); run = [] }
                result.append(.story(entry))
            } else {
                run.append(row)
            }
        }
        if !run.isEmpty { result.append(.run(run)) }
        return result
    }
}

// MARK: - The honest estimate (pure arithmetic over stored lengths)

/// A never-measured story's height on the page, modelled from its blocks'
/// LENGTHS (`Queries.blockExtents` — the paged reader's model tier; no
/// prose is read to estimate). The model is the paged reader's own
/// (`PageEstimator.lines`): a block is its own paragraph, its internal
/// newlines are content (I4), each paragraph ends mid-line (half a line
/// wasted on average) — at the FLOW's metrics: the 16-pt serif page font
/// wrapped at the column's measure, one line's pitch = the font's line
/// height + the paragraphs' `lineSpacing(6)`, 13 pt between paragraphs and
/// between blocks (the column's `spacing: 13`). Empty blocks contribute
/// nothing (the row renders none). Measured against the Sherlock library
/// in the batch record (`ReadingFlowEstimateTests`).
nonisolated enum FlowHeightEstimate {
    struct Metrics: Equatable {
        /// Characters per wrapped line at the measure.
        var charsPerLine: Double
        /// One line's pitch (the font's line height + the line spacing).
        var linePitch: CGFloat
    }

    /// The flow's paragraph spacing (`VStack(spacing: 13)`, both levels).
    static let paragraphGap: CGFloat = 13
    /// The row's `lineSpacing` on every paragraph.
    static let lineSpacing: CGFloat = 6
    /// The page font (`ReadingPageTokens.serif`: 16-pt system serif).
    static let fontSize: CGFloat = 16
    /// A story whose extents have not landed yet (the read is in flight):
    /// the Outline's own never-measured fallback, corrected the moment the
    /// lengths arrive. Only the column's first frames ever stand on it —
    /// a story mounts NO surface while its height is unknown (ladder R2-5:
    /// three 800-pt priors fit the near band, so a fresh flow mounted its
    /// first three stories and threw two away when the lengths landed).
    static let unknownHeight: CGFloat = 800
    /// A note with no renderable text: the row's one blank line.
    static let emptyNoteHeight: CGFloat = 20
    /// The column's measure before it has reported (`.frame(maxWidth: 600)`
    /// — the page column's cap, so the common case exactly). Ladder R2-8:
    /// the ONE fallback, for the estimate and the reservation alike — the
    /// reservation used to answer nil for an unreported column while the
    /// estimate assumed 600, so a story that flipped near on that one turn
    /// reserved nothing and stood one line tall until its text arrived.
    static let defaultColumnWidth: CGFloat = 600

    /// 18d batch 4 (U-12): the stamp a REMEMBERED story size carries on
    /// disk (`SurfaceSizeMemory.Record`). The page's type is the flow's
    /// own and voice-independent — a fixed system serif at `fontSize`, a
    /// fixed gap and line spacing — so this is the page's metrics, NOT
    /// `EditorTypography.fingerprint` (which would drop every remembered
    /// story on a voice switch that moved nothing on this page). It exists
    /// so that if the page's own type ever moves, the memories taken under
    /// the old one are refused rather than reserved.
    ///
    /// **The maintenance rule it carries:** this is a COMPILE-TIME constant
    /// because the page's metrics are constants. The note's own Read mode has
    /// a runtime type-size dial (`readModeTypeScale`, its "Aa − / Aa +") and
    /// that surface is a different one — it composes no `StableSurface`. If a
    /// dial like it ever reaches THIS page, this must become a function of it
    /// in the same edit, or every remembered story height silently outlives
    /// the size it was measured at.
    static let fingerprint = "page-\(Int(fontSize))-\(Int(paragraphGap))-\(Int(lineSpacing))"

    /// Does a REMEMBERED size apply at this column width? Ladder R2-1 —
    /// R1-1's rule reaches the flow: a size measured at another width is
    /// not this story's height here (a 600-pt column's 20,000 pt is ~26,000
    /// at 450), so it neither sizes the far placeholder nor reserves from
    /// the surface's first frame; the estimate at the CURRENT width does.
    /// `stableSurfaceWidthTolerance` is the same 1 pt `StableSurface`
    /// compares with, so the two never disagree about "the same width".
    static func remembered(_ size: CGSize, appliesAt columnWidth: CGFloat) -> Bool {
        abs(size.width - columnWidth) <= stableSurfaceWidthTolerance
    }

    /// **A story's height question, as a manifest INPUT — built in ONE place
    /// for both askings** (18l-b U4; the post-13u health review's D1, §1.3
    /// item 2): the ROW (`FlowStoryRow`, through `honestHeight` below — what
    /// the far placeholder and the reservation stand at) and the COLUMN's manifest
    /// (`ReadingFlowView.heightManifest` — the offsets a landing aims by).
    /// The row used to answer through its own two-arm rule while the column
    /// resolved through `BookHeightManifest.resolve`; the two agreed only
    /// because a story's input carries no measured arm (and no production road
    /// remembers a non-positive height) — KnownIssues row 58's drift class.
    /// Now both read `BookHeightManifest.resolve` of THIS input (the Outline's
    /// and the Index's shape: `outlineRowInput` / `indexPaneRowInput`). The
    /// remembered arm is offered only at THIS width (R2-1); the derived arm is
    /// the estimate at this width.
    static func storyInput(
        id: String, remembered: CGSize?, columnWidth: CGFloat, estimate: CGFloat
    ) -> BookHeightManifest.Input {
        BookHeightManifest.Input(
            id: id,
            remembered: remembered.flatMap {
                Self.remembered($0, appliesAt: columnWidth) ? $0.height : nil
            },
            derived: estimate)
    }

    /// The height a story STANDS at before its text is measured here — as
    /// the far placeholder and as the surface's reservation: the remembered
    /// size when it was taken at this width, else the estimate at this width.
    /// **Through the one brain since 18l-b U4** (`storyInput` →
    /// `BookHeightManifest.resolve`), and **the ROW's one rule**: `FlowStoryRow`
    /// calls exactly this (it holds no rule of its own — the U4 ladder's round
    /// 1, MINOR-1), so the pins that speak this name bind production:
    /// `ReadingFlowEstimateTests` (R2-1, the width gate) and
    /// `FlowStoryHeightOneBrainTests` (this == the column's `storyInput`
    /// resolved, for every input).
    static func honestHeight(remembered: CGSize?, columnWidth: CGFloat, estimate: CGFloat) -> CGFloat {
        // `resolve` reads no id (the manifest's row carries `FlowRows.anchor`).
        BookHeightManifest.resolve(storyInput(
            id: "", remembered: remembered, columnWidth: columnWidth, estimate: estimate)).0
    }

    /// What a story's surface RESERVES from its first frame: the honest
    /// height at the column's width — or NOTHING once its read has come
    /// back EMPTY (ladder R2-9: a failed read, or a note whose render is
    /// blank against extents that said otherwise). A surface under the
    /// placeholder ceiling never arms the settle that would drop the
    /// reservation, so without this a story-sized blank hole stood where
    /// the story should be for the rest of the session.
    static func reservation(honestHeight: CGFloat, columnWidth: CGFloat, loadedEmpty: Bool) -> CGSize? {
        loadedEmpty ? nil : CGSize(width: columnWidth, height: honestHeight)
    }
    /// The calibration from the Sherlock measurement (batch H): the modelled
    /// height against the real one, applied as a factor. 1 = the model as
    /// stated; the record states the measured value and why.
    static let calibration: Double = 1

    /// The page's metrics at a column width, measured off the real font
    /// rather than guessed (the paged reader's own method).
    @MainActor
    static func metrics(columnWidth: CGFloat) -> Metrics {
        if let cached = metricsCache[columnWidth] { return cached }
        let base = NSFont.systemFont(ofSize: fontSize)
        let font = NSFont(descriptor: base.fontDescriptor.withDesign(.serif) ?? base.fontDescriptor,
                          size: fontSize) ?? base
        let sample = "the quick brown fox jumps over a lazy dog and keeps going "
        let width = (sample as NSString)
            .size(withAttributes: [.font: font]).width / CGFloat(sample.count)
        let lineHeight = font.ascender - font.descender + font.leading
        let metrics = Metrics(
            charsPerLine: max(8, Double(columnWidth / max(width, 1))),
            linePitch: lineHeight + lineSpacing)
        metricsCache[columnWidth] = metrics
        return metrics
    }

    @MainActor private static var metricsCache: [CGFloat: Metrics] = [:]

    /// The paragraphs a block RENDERS on the page from its newline count.
    /// A stored block normally ends in ONE newline — the paragraph
    /// separator the author typed (⏎⏎ between paragraphs stores k−1
    /// trailing newlines on the block, `SegmentationRules`) and the sample
    /// library's paragraphs alike — and the flow DROPS blank display lines,
    /// so that newline renders nothing. The rule: `max(1, newlines)` — a
    /// block without a trailing newline (a note's last block, a one-block
    /// note) is one paragraph; the normal block is one; each newline beyond
    /// the separator is a real break. (The paged reader's `PageEstimator`
    /// counts `newlines + 1` and absorbs the difference in its runtime
    /// calibration; measured here against Sherlock, `+ 1` over-read every
    /// story by ~39 % — the batch record has the table.)
    ///
    /// **13u2b UNIT 2:** the rule itself is `ProseHeightModel`'s now — ONE
    /// model for this surface and the Outline's expanded rows (UNIT 1 marked
    /// the hoist and left it standing for the moment the second consumer
    /// arrived). These two names stay as the flow's word for it.
    static func paragraphs(newlines: Int) -> Int {
        ProseHeightModel.paragraphs(newlines: newlines)
    }

    /// The lines one block occupies (the paged reader's rule, restated over
    /// the rendered paragraph count).
    static func lines(characters: Int, newlines: Int, metrics: Metrics) -> Double {
        ProseHeightModel.lines(
            characters: characters, newlines: newlines, metrics: prose(metrics))
    }

    /// The page's own type facts, as the shared model asks for them: the
    /// measured chars-per-line and pitch, plus the page's FIXED spacing
    /// constants (`lineSpacing` between a paragraph's lines; the column's
    /// 13-pt gap between paragraphs and between blocks — measured on
    /// Sherlock: the pitch alone over-read every story by ~8 %, and this is
    /// the whole of it).
    static func prose(_ metrics: Metrics) -> ProseHeightModel.Metrics {
        ProseHeightModel.Metrics(
            charsPerLine: metrics.charsPerLine, linePitch: metrics.linePitch,
            lineSpacing: lineSpacing, paragraphGap: paragraphGap)
    }

    /// One story's height from its blocks' extents. The page's own half of
    /// the sentence — its blank line, its calibration and its rounding — stays
    /// here; the arithmetic is the shared model's.
    static func height(extents: [Queries.BlockExtent], metrics: Metrics) -> CGFloat {
        guard let total = ProseHeightModel.height(extents: extents, metrics: prose(metrics))
        else { return emptyNoteHeight }
        return (total * calibration).rounded()
    }
}

/// **What the flow's SMALL rows reported** (13u2b UNIT 2) — the manifest's
/// `measured` arm for the title, the chapter headings and the closing mark.
///
/// Why there is no shape generalization here, where the book Outline's
/// `BookOutlineHeights` has one: the Outline learns BY SHAPE because a book of
/// 400 rows can never have them all realized, so one measured card must teach
/// every card that looks like it. This column's small rows are a title, a
/// closing mark and one heading per chapter — fifteen on Sherlock — and since
/// this unit they are all always realized, so a per-row measurement is
/// COMPLETE and a shape is a generalization of nothing. A story's own measured
/// height is not here either: `SurfaceSizeMemory` is that store, and the
/// manifest reads it as the remembered arm.
///
/// Not observed, deliberately: written at geometry cadence, read in a body.
@MainActor
final class FlowRowHeights {
    private var measured: [String: CGFloat] = [:]
    private var width: CGFloat = 0

    /// A row rendered real content at this height. A width change drops
    /// everything learned at the old measure — the page's serif title wraps
    /// differently at another one, exactly as `SurfaceSizeMemory` refuses a
    /// record from another width.
    func learn(_ id: String, height: CGFloat, at width: CGFloat) {
        guard height.isFinite, height > 0 else { return }
        if abs(width - self.width) > stableSurfaceWidthTolerance {
            self.width = width
            measured = [:]
        }
        // Only a real change is written: a row re-reporting the same height
        // during a scroll costs one comparison and no write.
        if let known = measured[id], abs(known - height) <= 0.5 { return }
        measured[id] = height
    }

    func height(of id: String) -> CGFloat? { measured[id] }

    /// The first-frame constants, before a row has reported: the page's own
    /// declared type and padding, which are voice-INDEPENDENT (the flow's
    /// page is a fixed system serif — `FlowHeightEstimate.fingerprint`'s own
    /// reason). Each is superseded by that row's own report within a frame,
    /// so they are a first-frame answer and never a claim.
    ///
    /// - title: `ReadingPageTokens.serifTitle` (25 pt semibold serif ≈ 30 pt
    ///   of line) under 56 pt of top padding.
    /// - chapter: a 12-pt serif line (≈ 14) under 22 pt of top padding.
    /// - end: the closing mark at the page serif (16 pt ≈ 19) between two
    ///   40-pt paddings.
    static let title: CGFloat = 86
    static let chapter: CGFloat = 36
    static let end: CGFloat = 99
}

/// The book's block extents for the flow's estimate, cached for the BOOK
/// (ladder R2-4 — `BookViewModel.flowExtents`): `Queries.blockExtents` is
/// one lengths-only statement per 400 entries, but its work is `LENGTH()`
/// over the chosen take of every block of every note — cost ∝ the BOOK's
/// text (the `bookWordCounts` class, recorded in KnownIssues with owner
/// 12) — and the flow is re-created on every mode switch. The cache is
/// keyed by the entry-ID list: a changed membership misses and re-reads.
/// A plain reference box (never observed — written once per read).
@MainActor
final class FlowExtentsCache {
    private var postIDs: [String] = []
    private var extents: [String: [Queries.BlockExtent]]?

    /// The cached extents for exactly this entry set, else nil.
    func lookup(_ postIDs: [String]) -> [String: [Queries.BlockExtent]]? {
        self.postIDs == postIDs ? extents : nil
    }

    /// The same answer, compared element-wise against the ENTRIES themselves
    /// (count + `zip`, no allocation) — for the hot callers that would
    /// otherwise build an id list per ask (13u2b ladder round 1, NIT 2: the
    /// Outline's expanded-row placeholder asks per row per body pass, so an
    /// `entries.map(\.postID)` there was O(expanded × entries) of pure
    /// key-building at the window's 300-note cap).
    func lookup(matching entries: [Queries.ReadingEntry]) -> [String: [Queries.BlockExtent]]? {
        guard postIDs.count == entries.count,
              zip(postIDs, entries).allSatisfy({ $0 == $1.postID })
        else { return nil }
        return extents
    }

    func store(_ extents: [String: [Queries.BlockExtent]], for postIDs: [String]) {
        self.postIDs = postIDs
        self.extents = extents
    }
}

#if DEBUG
/// Ladder R2-4's pin support: how many times the flow ran the lengths
/// query — a second mount over the book's cache must add nothing.
@MainActor
enum ReadingFlowExtentsReads {
    static var count = 0
}

/// Where each story row's TOP sits in the flow's scroll space — the
/// landing oracle, so a pin can say whether a reveal put its post at the
/// top of the page (the book Outline's own `BookOutlineGeometry` shape) —
/// and the pending landing's story (`LAND` · `CORRECT` · `DONE`).
@MainActor
enum ReadingFlowGeometry {
    // **18k UNIT C4 — the row tops NAME THEIR OWNER** (the rule and its
    // reasons: `Core/Views/DebugOracleOwnership.swift`): the mounted flow's
    // `oracleOwner`, released when that flow leaves. Keyed by the story's
    // note, the same book's flow in two windows shared every key, and after
    // one window closed the tops were ITS — measured red,
    // `DebugOracleTwoWindowTests`.
    private static var anchorTopStore = OwnedRegistrations<String, CGFloat>()

    static var anchorTops: [String: CGFloat] { anchorTopStore.current }
    /// An append-only LOG, not a registration (18k C4 — SAFE-AS-IS (A)); the
    /// 13u2b landing story. Bounded like every DEBUG log (`DebugOracleLog`):
    /// it had no reset door but a pin's assignment and grew for a DEBUG
    /// process's whole life.
    static var trace: [String] = [] {
        didSet { DebugOracleLog.bound(&trace) }
    }

    static func recordAnchor(_ key: String, top: CGFloat, owner: UUID) {
        anchorTopStore.publish(top, for: key, owner: owner)
    }

    /// A flow leaving: its own tops, and no other window's.
    static func release(owner: UUID) { anchorTopStore.release(owner: owner) }

    /// A PIN's door, unconditional (a pin owns nothing).
    static func forgetAnchorTops() { anchorTopStore.forgetAll() }
}
#endif

/// What a flow row reports: where its top sits in the flow's space, and how
/// tall it is (13u2b UNIT 2 — the height is the manifest's `measured` arm for
/// the small rows, which always render real content).
nonisolated private struct FlowRowGeometry: Equatable, Sendable {
    var top: CGFloat
    var height: CGFloat
}

private extension View {
    /// A row's landing anchor report: to the authority's seed, to the
    /// column's own heights, and (in DEBUG) to the oracle.
    func flowAnchor(_ id: String, report: @escaping (CGFloat, CGFloat) -> Void) -> some View {
        self.onGeometryChange(for: FlowRowGeometry.self) {
            let frame = $0.frame(in: .named(ReadingFlowView.flowSpace))
            return FlowRowGeometry(top: frame.minY, height: frame.height)
        } action: { geometry in
            report(geometry.top, geometry.height)
        }
    }
}

#if DEBUG
/// Round 3 (MAJOR) pin support: counts REALIZED story surfaces so the
/// virtualization pin can assert the flow defers off-viewport rows (a
/// plain column materializes the whole book at once — red on the pre-fix
/// code by behavioral revert). Batch H moved the count from
/// `FlowPostView.init` to the realized surface's `onAppear`: every story
/// row is constructed now (a direct child), and a far row's placeholder
/// is not a surface — the P3 fact the pin guards is how many text
/// surfaces exist.
@MainActor
enum ReadingFlowMaterialization {
    static var count = 0
}
#endif

/// One story on the page (batch H): virtualized by the flow itself — the
/// real text (`FlowPostView` inside a `StableSurface` at its remembered or
/// estimated size) while near the viewport, a placeholder of exactly that
/// height while far. Starts far, so a distant row never mounts a surface
/// for one frame; the row's first geometry report decides. And it stays a
/// placeholder while its HEIGHT IS UNKNOWN — no memory, the extents not
/// landed (ladder R2-5): a surface mounted against the 800-pt prior is a
/// whole-story read that the true length then pushes far and discards.
private struct FlowStoryRow: View {
    let session: AppSession
    let entry: Queries.ReadingEntry
    let page: ReadingPageTokens
    let memory: SurfaceSizeMemory
    let estimate: CGFloat
    /// The book's extents have landed — the estimate is honest, not the prior.
    let extentsKnown: Bool
    let columnWidth: CGFloat?
    let onWake: (String?) -> Void
    let onNear: (Bool) -> Void
    /// The surface settled (R2-2) — the landing's "this row is done moving".
    let onSettled: () -> Void
    let onLoaded: () -> Void

    @State private var near = false
    /// R2-9: the read came back with nothing to render — the reservation is
    /// off, the memory holds the empty note's line, the landing hears
    /// "settled" (a ≤ 60-pt surface never says so itself).
    @State private var loadedEmpty = false

    /// The row's height is honest — remembered here, or estimated from
    /// landed extents (R2-5): only then may the near/far observer decide,
    /// so `near` never turns true on the 800-pt prior's geometry.
    private var heightKnown: Bool {
        extentsKnown || memory.size(entry.postID) != nil
    }

    var body: some View {
        Group {
            if near {
                StableSurface(
                    known: known, followsShrinks: false,
                    settleInterval: ReadingFlowView.surfaceSettleInterval,
                    settled: settledHere,
                    remember: { memory.remember(entry.postID, $0) }
                ) {
                    FlowPostView(
                        session: session, entry: entry, page: page,
                        onWake: onWake,
                        onLoaded: { isEmpty in
                            onLoaded()
                            guard isEmpty else { return }
                            loadedEmpty = true
                            memory.remember(
                                entry.postID,
                                CGSize(width: width, height: FlowHeightEstimate.emptyNoteHeight))
                            settledHere()
                        })
                }
                .onAppear { materialized() }
            } else {
                Color.clear.frame(height: honestHeight)
            }
        }
        .modifier(NearViewportObserver(
            near: $near, margin: ReadingFlowView.nearMargin, space: ReadingFlowView.flowSpace,
            armed: heightKnown))
        .onChange(of: near, initial: true) { _, isNear in onNear(isNear) }
    }

    /// 18d batch 4 (U-12): this story SETTLED — the one occasion its
    /// remembered length reaches the disk, and the landing's "this row is
    /// done moving" in the same breath. Both settle roads come through
    /// here: the surface's own announcement (R2-2) and R2-9's empty-read
    /// road, which stands in for it when the surface is too short to speak.
    private func settledHere() {
        memory.persist(entry.postID)
        onSettled()
    }

    /// The column's width for this row's geometry — the reported one, else
    /// the one fallback (R2-8).
    private var width: CGFloat { columnWidth ?? FlowHeightEstimate.defaultColumnWidth }

    /// The height this story stands at until its text is measured HERE:
    /// its remembered size when that was taken at this width, else the
    /// estimate at this width (R2-1 — the one brain for the placeholder
    /// and the reservation). **18l-b U4 (D1): the row holds NO rule of its
    /// own** — it calls the pinned `FlowHeightEstimate.honestHeight`, which
    /// is `BookHeightManifest.resolve` of the very input the column's
    /// manifest builds for this story (`FlowHeightEstimate.storyInput`), so
    /// the height the row stands at and the height a landing aims by are ONE
    /// answer (the U4 ladder's round 1, MINOR-1: the first cut inlined a
    /// second copy of that expression here, and the pins read the other one).
    private var honestHeight: CGFloat {
        FlowHeightEstimate.honestHeight(
            remembered: memory.size(entry.postID), columnWidth: width, estimate: estimate)
    }

    /// What the surface reserves from its first frame — the honest height
    /// at the column's width (`StableSurface` compares the width against
    /// the surface's first real report, so a resize between the two frames
    /// still drops the reservation rather than holding a stale one) — or
    /// nothing once the read came back empty (R2-9).
    private var known: CGSize? {
        FlowHeightEstimate.reservation(
            honestHeight: honestHeight, columnWidth: width, loadedEmpty: loadedEmpty)
    }

    private func materialized() {
        #if DEBUG
        ReadingFlowMaterialization.count += 1
        #endif
    }
}

/// One post on the page: lazy text, serif paragraphs; each BLOCK's
/// paragraphs are a click target that wakes editing AT that block (row 38);
/// the note's empty state wakes the note as a whole.
///
/// Internal rather than `private` since VX-142 (the VX-143 run), so its
/// composition pin can build it directly — nothing outside this file
/// constructs one.
struct FlowPostView: View {
    let session: AppSession
    let entry: Queries.ReadingEntry
    let page: ReadingPageTokens
    let onWake: (String?) -> Void
    /// Batch H: the text is in — and whether there was any (R2-9: an empty
    /// load has no surface to settle; the row drops its reservation).
    let onLoaded: (_ isEmpty: Bool) -> Void

    /// 13g batch 4 (L11): rendered paragraphs — the display text with its
    /// markdown applied, plus the line's own style — kept PER BLOCK since
    /// the correction round, so a click knows which block it fell in. Read
    /// is a reading surface (her A43 ruling), so the F-5 surface rule
    /// applies: markers hidden; the click maps to a block, never to a
    /// text offset (a SwiftUI `Text` cannot say where inside itself).
    @State private var blocks: [(blockID: String, paragraphs: [FlowParagraph])] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            ForEach(blocks, id: \.blockID) { block in
                VStack(alignment: .leading, spacing: 13) {
                    ForEach(Array(block.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                        Text(paragraph.text)
                            .font(paragraph.font(page))
                            .foregroundStyle(page.ink)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, paragraph.indent)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { onWake(block.blockID) }
            }
            if blocks.isEmpty {
                Text(" ")
                    .font(page.serif)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture { onWake(nil) }
            }
        }
        // A link's plain click opens it (F-5); the scheme guard is the same
        // one every other surface asks, so an inert address does nothing
        // rather than something surprising.
        .environment(\.openURL, OpenURLAction { url in
            MarkdownLink.open(url.absoluteString) ? .handled : .discarded
        })
        // 13g cold review R1-4: the ONE note-naming surface batch 7's sweep
        // missed (it rendered "" rather than "Untitled", so the grep never
        // saw it) — the display brain answers here like everywhere else.
        .help(entry.displayTitle)
        .task(id: entry.postID) {
            // The rendered projection per BLOCK (renderedText semantics —
            // chosen takes; blank takes and gaps contribute nothing), each
            // RENDERED for reading (13g L11 — one transform per block of a
            // realized row, so the cost stays ∝ what the column
            // materialized). 13k K10: the page's own code chip rides in.
            let slots: [(String, String)] = (try? await session.database.read { [id = entry.postID] db in
                try Queries.renderPost(db, containerID: id).compactMap { slot in
                    guard let text = slot.text, !text.isEmpty else { return nil }
                    return (slot.blockID, text)
                }
            }) ?? []
            blocks = slots.map { blockID, text in
                (blockID, FlowParagraph.paragraphs(of: text, codeTint: page.codeTint))
            }
            onLoaded(blocks.isEmpty)
        }
    }
}
