//
//  BookHeightManifest.swift
//  Variorum (Mac) — Surface (the pure surface authorities' home, beside
//  `PaneTextAuthority`)
//
//  **Phase 13u2b UNIT 1 — the book's HEIGHTS, KNOWN BEFORE A LANDING AIMS.**
//
//  The binding design record is `notes/plans/navigation-landing-architecture-trace.md`
//  §5(b): *"Collect that into one per-book, per-width answer — `entries ×
//  (collapsed height | expanded height | estimate)` … then a landing computes
//  the target's offset arithmetically and scrolls ONCE."* This file is that
//  answer, as a pure value: no SwiftUI, no AppKit, no fonts, no database —
//  every height is handed IN, so the whole thing is arithmetic a unit test
//  can pin.
//
//  **Why it exists, in one measured sentence** (UNIT 1's trace, the plan's
//  own record): a `LazyVStack` replaces the height of every row it has not
//  realized with the AVERAGE of the ones it has, so arriving at a landing
//  target de-realizes the rows above it, the column shrinks above the target
//  by ~70 pt, and the page slides off the thing it just landed on — *"I
//  watched it stutter ~10 times, every time I did it."* A height the column
//  ASSERTS cannot do that. So the manifest's consumer is the ROW (what a far
//  row stands at) as much as the landing (where the target is).
//
//  **The three sources, in precedence order.** The plan's sentence names them
//  CONSTANT > REMEMBERED > ESTIMATE; this file orders them
//  **MEASURED > REMEMBERED > DERIVED** and the difference is deliberate, not
//  a drift:
//  - **measured** — what this very row reported while rendering REAL content,
//    at this width, in this session. It is not a guess about the column: it is
//    the column. Nothing outranks it.
//  - **remembered** — a persisted record for this surface at this width
//    (`SurfaceSizeMemory`, 18d's U-12). Survives the launch; still a claim
//    about a previous frame rather than this one.
//  - **derived** — arithmetic over content and typography (a heading's fixed
//    chrome; a card's chrome plus its primed preview's wrapped lines; an
//    expanded note's prose from its blocks' stored LENGTHS — AppSpec §4's own
//    designed fallback, *"stored per-block length estimates, not live
//    geometry"*). Always available, so the manifest is never silent.
//
//  The plan's "CONSTANT" arm is this file's `derived` arm for a heading — a
//  constant per kind and width — and a height the column actually reported
//  outranks any derivation of it, which is why measured leads. Stated here
//  rather than silently reordered.
//
//  **P1/P-8:** building a manifest is ∝ ENTRIES × a small constant and never
//  ∝ the book's prose (the derived arm reads lengths and a forty-word
//  preview, never a note's text), and it is rebuilt on adoption and on a
//  WIDTH change — never at autosave or keystroke cadence.
//

import CoreGraphics
import Foundation
import VariorumCore

/// One book's rows and what each one is TALL, at one content width.
///
/// Rows are given in column order; the manifest adds the cumulative offset
/// arithmetic (each row's top, from the column's content top) so a landing
/// can address a row it has never seen.
nonisolated struct BookHeightManifest: Equatable {
    /// Where a row's height came from — carried per row so a consumer can ask
    /// the question that matters to a landing: *is everything above my target
    /// a fact, or is some of it arithmetic?*
    enum Source: Equatable {
        /// The row reported this height while rendering real content here.
        case measured
        /// A persisted record for this surface at this width.
        case remembered
        /// Arithmetic over content + typography.
        case derived
    }

    /// What the builder is handed per row: the answers each source has, if
    /// any. `derived` is not optional — a manifest with a hole in it would
    /// hand its consumer a nil exactly where the lazy estimate used to be.
    struct Input: Equatable {
        var id: String
        var measured: CGFloat?
        var remembered: CGFloat?
        var derived: CGFloat

        init(id: String, measured: CGFloat? = nil, remembered: CGFloat? = nil, derived: CGFloat) {
            self.id = id
            self.measured = measured
            self.remembered = remembered
            self.derived = derived
        }
    }

    /// One resolved row: its height, where that came from, and where its top
    /// sits in the column's content.
    struct Row: Equatable {
        var id: String
        var height: CGFloat
        var source: Source
        var offset: CGFloat
    }

    /// The content width this manifest was built at. A manifest does not
    /// apply at another width — a card's preview wraps differently and a
    /// story's prose reflows — which is the same rule `StableSurface` and
    /// `FlowHeightEstimate` already compare with.
    let width: CGFloat
    /// The gap the column puts between rows (`VStack(spacing:)`).
    let spacing: CGFloat
    /// Everything above the first row (the book's title block and the
    /// column's own top padding). Carried so offsets are absolute in the
    /// column's content space.
    let leading: CGFloat
    private(set) var rows: [Row]
    private let position: [String: Int]

    init(width: CGFloat, spacing: CGFloat, leading: CGFloat, inputs: [Input]) {
        self.width = width
        self.spacing = spacing
        self.leading = leading
        var rows: [Row] = []
        var position: [String: Int] = [:]
        var y = leading
        rows.reserveCapacity(inputs.count)
        for input in inputs {
            // A duplicate anchor is a bug in the row list, never a reason to
            // hand back two answers: the first wins and the second is
            // skipped, so `offset(of:)` stays single-valued.
            guard position[input.id] == nil else { continue }
            let resolved = Self.resolve(input)
            position[input.id] = rows.count
            rows.append(Row(id: input.id, height: resolved.0, source: resolved.1, offset: y))
            y += resolved.0 + spacing
        }
        self.rows = rows
        self.position = position
    }

    /// The precedence, in one place. A source that answers with a
    /// non-positive or non-finite number has not answered — the next source
    /// takes it, and `derived` (clamped) is the floor.
    ///
    /// Internal rather than private because the column asks it TWICE, and
    /// both askings must agree: once per ROW (what a far row stands at, asked
    /// during that row's own body) and once per COLUMN (the cumulative
    /// offsets a landing reads). One brain, two consumers — never two
    /// precedence rules that drift.
    static func resolve(_ input: Input) -> (CGFloat, Source) {
        if let measured = input.measured, measured.isFinite, measured > 0 {
            return (measured, .measured)
        }
        if let remembered = input.remembered, remembered.isFinite, remembered > 0 {
            return (remembered, .remembered)
        }
        return (input.derived.isFinite ? max(0, input.derived) : 0, .derived)
    }

    func height(of id: String) -> CGFloat? {
        position[id].map { rows[$0].height }
    }

    /// Where this row's top sits, from the column's content top.
    func offset(of id: String) -> CGFloat? {
        position[id].map { rows[$0].offset }
    }

    func source(of id: String) -> Source? {
        position[id].map { rows[$0].source }
    }

    /// The column's whole content height, trailing gap excluded.
    var totalHeight: CGFloat {
        guard let last = rows.last else { return leading }
        return last.offset + last.height
    }

    /// Does this manifest describe the column at `width`? The tolerance is
    /// `StableSurface`'s own, so "the same width" is ONE number in the app.
    func appliesAt(_ width: CGFloat) -> Bool {
        abs(self.width - width) <= stableSurfaceWidthTolerance
    }

    /// **Has the landing anything left to correct?** True when every row
    /// ABOVE this one is a measured or remembered fact — in which case the
    /// target's position cannot move under it and the compensator is a net
    /// with nothing to catch. False when some row above is still arithmetic.
    /// (Rows BELOW the target never move it.)
    func isExactAbove(_ id: String) -> Bool {
        guard let index = position[id] else { return false }
        return !rows[..<index].contains { $0.source == .derived }
    }

    /// How many rows are still arithmetic — the number a DEBUG landing story
    /// prints, and the one that should fall to zero as a book is read.
    var derivedCount: Int { rows.reduce(0) { $0 + ($1.source == .derived ? 1 : 0) } }
}

/// The DERIVED arm's arithmetic: what a row is tall when nothing has
/// measured it yet. Pure, and parameterized by METRICS the caller measures
/// off the real fonts — the `FlowHeightEstimate.metrics(columnWidth:)`
/// pattern, which exists so the model can be pinned without a window.
///
/// **Its numbers are MEASURED FACTS, not invented constants**, and that is
/// worth saying because a modelled fallback usually is invented: the card's
/// bare and three-line heights (46 and 103 pt) are the ones the 13u2 traces
/// read off the real Sherlock book on the dev store (UNIT A's TRACE 2:
/// `page-…  h=46` before the preview landed, `h=103` after), and the chapter
/// heading's 51 pt is from the same traces. They are the SHIPPED voice's,
/// which is why the caller overrides them with what this column actually
/// reports the moment it reports anything (`BookOutlineHeights`): the model
/// is a first-frame answer, never a claim about every voice.
nonisolated enum BookOutlineHeightModel {
    /// The type facts a card needs, measured off the real font by the caller.
    struct Metrics: Equatable {
        /// A card with NO excerpt (the traces' `h=46`): both paddings, the
        /// title row, the border, the row's own bottom padding.
        var cardChrome: CGFloat = 46
        /// The card's `VStack(spacing:)` between the title row and the
        /// excerpt.
        var cardExcerptGap: CGFloat = 0
        /// One excerpt line's height in the card's body face. 19 pt is the
        /// traces' own arithmetic: (103 − 46) / 3 lines.
        var cardLineHeight: CGFloat = 19
        /// Characters of the excerpt face that fit the card's inner measure.
        var cardCharsPerLine: Double = 90
        /// The card's `lineLimit` — 3 today; a cap, so a long preview cannot
        /// make a card taller than the card can be.
        var cardLineLimit: Int = 3
        /// A chapter heading row, its 28-pt lead-in included (traced: 51).
        var chapterHeading: CGFloat = 51
        /// The trailing "unfiled" heading.
        var unfiledHeading: CGFloat = 51
        /// A smart book's tag-path heading.
        var tagHeading: CGFloat = 51
        /// An expanded note's chrome: its header row and the padding under
        /// the surface — everything but the prose. The ROW is the surface
        /// plus this; the PLACEHOLDER inside the row is the surface alone.
        var expandedChrome: CGFloat = 60
        /// What an expanded note's SURFACE stands at when nothing is known
        /// about it — no remembered size, no lengths yet. The Outline's own
        /// shipped fallback (`OutlinePostRow.unmeasuredSurfaceHeight`), kept
        /// to the point so the cold case is never worse than it was.
        var expandedUnknown: CGFloat = 800
        /// A note with nothing renderable: the surface's one blank line (the
        /// flow's `emptyNoteHeight` at the editor's own pitch).
        var expandedEmpty: CGFloat = 24
        /// The prose metrics the expanded estimate wraps text at.
        var prose: ProseMetrics = ProseMetrics()
    }

    /// The prose model's inputs. **13u2b UNIT 2 — THE HOIST FIRED:** this was
    /// a struct here, restated from the flow's own shape because *"the flow is
    /// UNIT 2's to adopt and a shared brain minted while one consumer is out
    /// of scope is a refactor nobody measured."* The flow is now the second
    /// consumer, so both read ONE model (`ProseHeightModel`) and this name
    /// stays as the Outline's word for it — every call site and every pin is
    /// untouched.
    typealias ProseMetrics = ProseHeightModel.Metrics

    /// What kind of row this is — the only thing the model needs to know to
    /// answer, and the key the caller learns heights under.
    enum Shape: Hashable {
        case chapterHeading
        case unfiledHeading
        case tagHeading
        /// A collapsed card, by how many lines its preview wraps to (0…the
        /// card's line limit). Cards of one line count ARE the same height,
        /// which is what makes learning one of them teach the rest.
        case card(lines: Int)
        /// An expanded note — never shape-learned (every note is its own
        /// length), so this case carries no payload and exists only to make
        /// the switch total.
        case expandedNote
    }

    /// The row's shape, so the caller can learn and look up by it.
    static func cardShape(excerpt: String, metrics: Metrics) -> Shape {
        .card(lines: excerptLines(excerpt, metrics: metrics))
    }

    /// The modelled height of a shape — the last resort, before anything has
    /// been measured here.
    static func modelled(_ shape: Shape, metrics: Metrics) -> CGFloat {
        switch shape {
        case .chapterHeading: metrics.chapterHeading
        case .unfiledHeading: metrics.unfiledHeading
        case .tagHeading: metrics.tagHeading
        case .card(let lines):
            lines > 0
                ? metrics.cardChrome + metrics.cardExcerptGap + CGFloat(lines) * metrics.cardLineHeight
                : metrics.cardChrome
        // A whole ROW: the unknown surface plus the header and padding
        // around it. (The row's placeholder inside it is the surface alone —
        // `BookViewModel.outlineSurfaceHeight`.)
        case .expandedNote: metrics.expandedUnknown + metrics.expandedChrome
        }
    }

    /// How many lines the card's excerpt wraps to. The preview is ONE
    /// paragraph by construction (`BookOutlineRows.cardPreview` replaces its
    /// newlines with spaces and joins blocks with a space), so this is the
    /// character count over the measure, capped by the card's line limit.
    static func excerptLines(_ excerpt: String, metrics: Metrics) -> Int {
        guard !excerpt.isEmpty, metrics.cardCharsPerLine > 0 else { return 0 }
        let lines = Int((Double(excerpt.count) / metrics.cardCharsPerLine).rounded(.up))
        return min(max(1, lines), max(1, metrics.cardLineLimit))
    }

    /// An expanded note's TEXT SURFACE from its blocks' stored LENGTHS —
    /// never its prose (AppSpec §4's designed fallback; `Queries.blockExtents`
    /// computes the lengths in SQL and no text crosses the boundary). The
    /// whole ROW is this plus `expandedChrome`.
    ///
    /// The paragraph model is the ONE model (`ProseHeightModel` — 13u2b UNIT
    /// 2's hoist), measured against the real Sherlock library: a block is its
    /// own paragraph, its internal newlines are content (I4), each paragraph
    /// ends mid-line (half a line wasted on average), `lineSpacing` sits only
    /// BETWEEN a paragraph's lines. What stays HERE is the Outline's own half
    /// of the sentence — its empty answer and its floor, which are facts
    /// about the editor's surface and not about prose.
    static func expandedHeight(
        extents: [Queries.BlockExtent], metrics: Metrics
    ) -> CGFloat {
        guard let total = ProseHeightModel.height(extents: extents, metrics: metrics.prose)
        else { return metrics.expandedEmpty }
        return max(metrics.expandedEmpty, total.rounded())
    }
}
