//
//  LibraryPlace.swift
//  Variorum (Mac)
//
//  **VX-823 (the VX-828 run, batch C) — THE LIBRARY REMEMBERS WHERE YOU WERE.**
//  Her ask: *"what's the lift on you keeping where you were in the library
//  after entering a note and leaving it? it's kinda driving me crazy to not
//  have this."* The catalog's MODEL already outlives a note round trip (it is
//  `RootView`'s `@State`), so the question — the query, scope, sort, the armed
//  day, the facets — and the listed rows survive; what died was the VIEW: its
//  scroll views and their offsets, re-mounted at the top, re-asked from the
//  first page (the batch C trace, `notes/plans/fixes/vx-828-editor-shell-qol.md`).
//
//  This file is the PURE brain (the orchestrator's ruling on batch C's fork,
//  P-828-11): **the place is the rows that were ON SCREEN, never a pixel** —
//  each row's id and how far its top sat below the viewport's top (`into`),
//  the Write/Takes reading-anchor precedent (U0b's `ReadingAnchor`, Takes'
//  `ArticlePlace`), plus a bounded neighbourhood of the ids listed just above
//  and below them. On return each id is re-resolved in the CURRENT listing:
//  the first surviving on-screen row lands at its own `into` — the row she
//  OPENED is not an anchor while another on-screen row survives (under the
//  default edited-newest-first sort a keystroke in the note moves it to the
//  top; the rows before her eyes did not move) — then the nearest surviving
//  neighbour, then the top. No step reads the store or searches the corpus.
//
//  The view's half (the rows' reports, the scroll window, the unbound landing
//  and its hold) is `LibraryPlaceScroll.swift`; the model's half (the memory,
//  the return's in-place re-ask, the return mark) is `LibraryCatalogPlace.swift`.
//

import CoreGraphics
import Foundation

nonisolated struct LibraryPlace: Equatable, Sendable {
    /// One row that was on screen: its id, where its top sat below the
    /// viewport's top (negative: a row cut by the top edge), and its height.
    struct Row: Equatable, Sendable {
        let id: String
        let into: CGFloat
        let height: CGFloat
    }

    /// A scroll view's reading, in its CONTENT's space: where the viewport's
    /// top sits, how tall the viewport is, how tall the content is.
    struct Window: Equatable, Sendable {
        var offset: CGFloat
        var viewport: CGFloat
        var content: CGFloat

        static let unmeasured = Window(offset: 0, viewport: 0, content: 0)

        var isMeasured: Bool { viewport > 0 && content > 0 }
        /// The furthest the content can scroll.
        var maxOffset: CGFloat { max(0, content - viewport) }
    }

    /// **Which scroll view a pane's place was read on** — the order its rows
    /// are drawn in differs: the List's one column (its books when they are
    /// not split off into their capped region · its notes · a tag's blocks),
    /// the Cards (notes), the answer sheet (its books · its groups).
    enum Surface: Equatable, Sendable {
        case list(includesBooks: Bool)
        case cards
        case sheet

        /// Q2/Q4 (P-828-12/-14): the surfaces that draw a selection face —
        /// the List's rows and the answer sheet's (List-faced in every mode);
        /// the Cards draw none, so a return there is the place alone.
        var drawsSelection: Bool { self != .cards }
    }

    /// Where a return lands: this row, its top `into` below the viewport's top.
    struct Landing: Equatable, Sendable {
        let id: String
        let into: CGFloat
        let height: CGFloat
    }

    /// **The order a surface DRAWS its rows in** — read through two lookups,
    /// so a listing of thousands is never copied to ask about a dozen ids.
    struct Order {
        let count: Int
        let position: (String) -> Int?
        let id: (Int) -> String?

        /// A plain list (the pins' road; the small segments' build).
        init(ids: [String]) {
            var index: [String: Int] = [:]
            index.reserveCapacity(ids.count)
            for (position, id) in ids.enumerated() where index[id] == nil { index[id] = position }
            count = ids.count
            position = { index[$0] }
            id = { ids.indices.contains($0) ? ids[$0] : nil }
        }

        init(count: Int, position: @escaping (String) -> Int?, id: @escaping (Int) -> String?) {
            self.count = count
            self.position = position
            self.id = id
        }

        /// Segments drawn one after another (the List's books · notes · blocks;
        /// the answer sheet's books · groups).
        static func concatenated(_ segments: [Order]) -> Order {
            var starts: [Int] = []
            var total = 0
            for segment in segments {
                starts.append(total)
                total += segment.count
            }
            return Order(
                count: total,
                position: { id in
                    for (index, segment) in segments.enumerated() {
                        if let local = segment.position(id) { return starts[index] + local }
                    }
                    return nil
                },
                id: { position in
                    guard position >= 0 else { return nil }
                    for (index, segment) in segments.enumerated().reversed() where position >= starts[index] {
                        return segment.id(position - starts[index])
                    }
                    return nil
                })
        }
    }

    /// The rows on screen, top-down.
    let rows: [Row]
    /// The listed ids just ABOVE the on-screen rows, nearest first.
    let above: [String]
    /// The listed ids just BELOW the on-screen rows, nearest first.
    let below: [String]
    /// The row she OPENED from, when the Library was left by a row's open.
    let openedID: String?

    /// How many neighbours each side the place keeps — the fallback's reach
    /// when every on-screen row is gone (bounded: never a corpus walk).
    static let neighbourhood = 12

    // MARK: - Capture (at rest, and at a row's open)

    /// **The place the window shows**: every row whose frame (in the content's
    /// space) meets the viewport and that the surface still lists, top-down,
    /// with its `into`; and the `neighbourhood` listed ids each side. nil when
    /// nothing measured is on screen.
    static func capture(
        window: Window, frames: [String: CGRect], order: Order, openedID: String?
    ) -> LibraryPlace? {
        guard window.isMeasured else { return nil }
        let top = window.offset
        let bottom = window.offset + window.viewport
        let onScreen = frames
            .compactMap { id, frame -> (id: String, frame: CGRect, position: Int)? in
                guard frame.height > 0, frame.maxY > top + 0.5, frame.minY < bottom - 0.5,
                      let position = order.position(id) else { return nil }
                return (id, frame, position)
            }
            .sorted { ($0.frame.minY, $0.position) < ($1.frame.minY, $1.position) }
        guard let first = onScreen.first else { return nil }
        let positions = onScreen.map(\.position)
        let highest = positions.min() ?? first.position
        let lowest = positions.max() ?? first.position
        let above = (1...neighbourhood).compactMap { order.id(highest - $0) }
        let below = (1...neighbourhood).compactMap { order.id(lowest + $0) }
        return LibraryPlace(
            rows: onScreen.map { Row(id: $0.id, into: $0.frame.minY - top, height: $0.frame.height) },
            above: above, below: below, openedID: openedID)
    }

    // MARK: - Resolve (on return, against the CURRENT listing)

    /// **Where the return lands** (P-828-11's chain): the first on-screen row
    /// the surface still lists — skipping the OPENED row while another
    /// survives — at its own `into`; else the nearest surviving neighbour
    /// (below first at a tie: the reading she was doing continues downward),
    /// where the on-screen rows began; else nil — the top.
    static func resolve(_ place: LibraryPlace, in order: Order) -> Landing? {
        let survivors = place.rows.filter { order.position($0.id) != nil }
        if let anchor = survivors.first(where: { $0.id != place.openedID }) ?? survivors.first {
            return Landing(id: anchor.id, into: anchor.into, height: anchor.height)
        }
        let into = place.rows.first?.into ?? 0
        let height = place.rows.first?.height ?? 0
        for distance in 0..<max(place.above.count, place.below.count) {
            if distance < place.below.count, order.position(place.below[distance]) != nil {
                return Landing(id: place.below[distance], into: into, height: height)
            }
            if distance < place.above.count, order.position(place.above[distance]) != nil {
                // Its foot where the on-screen rows began (its own height is
                // unknown — the lead row's stands in).
                return Landing(id: place.above[distance], into: into - height, height: height)
            }
        }
        return nil
    }

    // MARK: - The landing's arithmetic

    /// The proxy's unit y: the row's point at this fraction of its height
    /// meets the viewport's point at the same fraction, so the row's top lands
    /// `into` below the viewport's top — `into / (viewport − height)`. Takes
    /// measured the proxy honouring it, a NEGATIVE `into` linearly
    /// (`TakesBoardLayout.ArticlePlace.anchorY`'s record); a row with no room
    /// beside it aims at the top.
    static func anchorY(into: CGFloat, height: CGFloat, viewport: CGFloat) -> CGFloat {
        let room = viewport - height
        guard room > 1 else { return 0 }
        return min(into / room, 1)
    }

    /// **The landing has arrived** — the row's top within half a point of its
    /// `into`, or as close as the scroll can bring it (at its top, a row that
    /// wanted to sit lower cannot; at its end, one that wanted to sit higher
    /// cannot).
    static func isSettled(frame: CGRect, window: Window, landing: Landing) -> Bool {
        let actual = frame.minY - window.offset
        if abs(actual - landing.into) <= 0.5 { return true }
        if window.offset <= 0.5, actual < landing.into { return true }
        if window.offset >= window.maxOffset - 0.5, actual > landing.into { return true }
        return false
    }

    /// **The return's in-place re-ask, bounded by the place's depth** (Q5 —
    /// ruled "∝ the place's depth"): the deepest remembered position plus ONE
    /// page — a reach she made herself by scrolling there once, never the
    /// corpus. A surface with nothing of that kind asks the first page.
    static func depth(reach: Int?, page: Int) -> Int {
        max(page, (reach ?? -1) + 1 + page)
    }
}

/// A place as the model remembers it: the rows, and the wing they were in (a
/// wing switch is a new question — the place is not carried across it).
nonisolated struct LibraryRememberedPlace: Equatable, Sendable {
    let place: LibraryPlace
    let wing: String
    /// The deepest listed NOTE position the place names (the notes' re-ask
    /// depth) — nil when it names none.
    let noteReach: Int?
    /// The deepest answer-sheet GROUP position it names — nil when none.
    let groupReach: Int?
}
