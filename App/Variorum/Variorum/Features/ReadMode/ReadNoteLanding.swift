//
//  ReadNoteLanding.swift
//  Variorum
//
//  **18l UNIT U1 — note Read's two faces adopt the ONE landing authority**
//  (`Surface/LandingAuthority.swift`; the health review 2026-09-21 §1.3
//  item 1, the charter `notes/plans/post-13u-health-rounds.md` KICKOFF 2).
//
//  The review's map (§1.1) had note Read's page face and edit face as the two
//  surfaces with *"no brain — one one-shot `scrollTo`, no correction, no
//  memory, no signpost"*: the request was set, the scroll was issued, the
//  request was nil'd, and nothing looked again. That is what this file ends.
//  Each face now asks the authority to land a block and the authority
//  WATCHES the landing: the aim, a quiet interval, a hold, a correction when
//  the block is not where its face's anchor puts it, a watchdog, a scroll of
//  hers ending it — and the content-free signpost every adopter ships
//  (`landing surface=ReadNote…` in her Console, where note Read printed
//  nothing: the review §1.2's own diagnostic).
//
//  **What a landing's "top" means here** (the one thing this surface adds to
//  the authority's vocabulary, and it adds it as ARITHMETIC, not as a new
//  authority concept): the authority converges a reported number to 0.
//  The book surfaces report a row's top because their anchor IS the top.
//  Note Read keeps its SHIPPED resting anchors — the page at 0.08 of the
//  viewport, the edit face centred (where a landing puts a block is product,
//  not this unit's) — and a mode switch may carry another fraction (13u2b
//  UNIT 3). So the number reported is the block's distance from where ITS
//  anchor puts it (`ReadLandingResidual`): `ViewportCarry`'s definition, the
//  block's anchor-point at the viewport's anchor-point, which is exactly
//  what `scrollTo(_:anchor:)` does — clamped by the page's own ends, so a
//  block the page cannot bring to its anchor (the first block, centred) is
//  home where the page stops. The authority growing an aim KIND is 18l-b
//  U2's (the charter: top · minimal-reveal · viewport-fraction); this was the
//  fraction arm's arithmetic, pure and pinned — and U2 hoisted it there
//  (`LandingAim.ViewportFraction`; the old name below is a typealias).
//
//  **The per-note block MANIFEST** (`ReadNoteHeights`): what the column
//  knows about each block's height — MEASURED (a row that drew) > DERIVED
//  (the block's stored length through the ONE `ProseHeightModel`, the
//  Outline/flow/Index brain) — and so what the signpost can honestly say
//  about a landing (`offset`, `total`, `derived`, `exact`). The lengths are
//  `Queries.BlockExtent` values read off the rendered takes this host ALREADY
//  holds (`BlockTOCViewModel.rows` — the same take `Queries.blockExtents`
//  resolves, `renderPost`'s), so no second statement reads text the host has
//  in memory; they are taken ONCE per block-id list (the `FlowExtentsCache`
//  key), so nothing at autosave rate recomputes them (P1).
//
//  P-9: the authority owns aim and settle; this file owns what note Read
//  says about its column (the residual, the manifest); the faces own their
//  one act (the unanimated `scrollTo`).
//

import AppKit
import SwiftUI
import VariorumCore

// MARK: - Where a block is, against where its face's anchor puts it (pure)

/// **The fraction arm's arithmetic — HOISTED at 18l-b U2** to the authority's
/// side (`Surface/LandingAim.swift`, `LandingAim.ViewportFraction`, the
/// `.viewportFraction` aim kind's pure brain), exactly as U1's JC 2 handed it
/// forward. This name stays at its old address as a typealias (the 3C parity
/// pattern), so `ReadLandingBox.residual` and the arithmetic pins
/// (`ReadNoteLandingArithmeticTests`) read it unmodified.
typealias ReadLandingResidual = LandingAim.ViewportFraction

/// What the face's scroll view says about the page, read at geometry
/// cadence into the landing's box (never observed state).
nonisolated struct ReadScrollFacts: Equatable, Sendable {
    var offset: CGFloat = 0
    var contentHeight: CGFloat = 0
    var viewportHeight: CGFloat = 0
    var insetTop: CGFloat = 0
    var insetBottom: CGFloat = 0

    var minOffset: CGFloat { -insetTop }
    var maxOffset: CGFloat { contentHeight + insetBottom - viewportHeight }
}

// MARK: - The block height model (pure)

nonisolated enum ReadNoteHeightModel {
    /// The type and chrome facts a block row needs, measured off the face's
    /// real font by `ReadNoteHeights.metrics` (the `FlowHeightEstimate` /
    /// `BookIndexPaneHeights` pattern — pinned without a window).
    struct Metrics: Equatable {
        var prose = ProseHeightModel.Metrics(
            charsPerLine: 76, linePitch: 21, lineSpacing: 4, paragraphGap: 8)
        /// One block row's own vertical padding.
        var blockChrome: CGFloat = 12
        /// A block that renders nothing still stands one blank line (its
        /// `Text(" ")`).
        var emptyLine: CGFloat = 17
        /// The column's gap between rows.
        var rowSpacing: CGFloat = 2
    }

    /// One block's rendered EXTENT from the rendered take in hand — the
    /// numbers `Queries.blockExtents` computes in SQL (`LENGTH()` counts code
    /// points, so this counts Unicode scalars; newlines are content, I4).
    static func extent(postID: String, row: Queries.TOCRow) -> Queries.BlockExtent {
        let text = row.text ?? ""
        return Queries.BlockExtent(
            containerID: postID, blockID: row.blockID,
            characters: text.unicodeScalars.count,
            newlines: text.utf8.reduce(0) { $0 + ($1 == 0x0A ? 1 : 0) })
    }

    /// One block row's height from its extent — the ONE paragraph model
    /// (`ProseHeightModel`), plus this surface's own chrome.
    static func blockHeight(_ extent: Queries.BlockExtent, metrics: Metrics) -> CGFloat {
        guard let prose = ProseHeightModel.height(extents: [extent], metrics: metrics.prose) else {
            return (metrics.blockChrome + metrics.emptyLine).rounded()
        }
        return (metrics.blockChrome + prose).rounded()
    }
}

// MARK: - The per-note block manifest (one per face, held by the Read host)

/// **What one face knows about its block rows' heights** — measured where a
/// row has drawn, derived elsewhere. Held by the Read HOST (one per face, for
/// as long as the note is in Read), so a face switch keeps what the other
/// visit to that face learned. Unobserved on purpose: written at geometry
/// cadence and read only when a landing states its facts.
@MainActor
final class ReadNoteHeights {
    enum Face: String { case edit, page }
    let face: Face
    private(set) var metrics = ReadNoteHeightModel.Metrics()
    /// The width + voice + type scale these answers stand at.
    private var stamp = ""
    /// The block-id list the extents were taken for (placement ids, in
    /// order) — the `FlowExtentsCache` key: a re-delivery of the same list
    /// (every autosave's) takes nothing new.
    private var key: [String] = []
    private var extents: [String: Queries.BlockExtent] = [:]
    private var measured: [String: CGFloat] = [:]
    private var derivedMemo: [String: CGFloat] = [:]
    #if DEBUG
    /// P1's pin: how many times the extents were TAKEN (once per id list).
    private(set) var extentTakes = 0
    #endif

    init(face: Face) { self.face = face }

    /// Stand at this measure, this voice and this type scale — re-measuring
    /// the type and dropping what was learned elsewhere. Idempotent.
    func stand(contentWidth: CGFloat, typeScale: Double) {
        guard contentWidth > 0 else { return }
        let stamp = "\(Int(contentWidth.rounded()))|\(EditorTypography.fingerprint ?? "-")"
            + "|\(Int((typeScale * 100).rounded()))"
        guard stamp != self.stamp else { return }
        self.stamp = stamp
        metrics = Self.metrics(face: face, contentWidth: contentWidth, typeScale: typeScale)
        measured = [:]
        derivedMemo = [:]
    }

    /// The rows in hand: their extents are taken when the block-id list is
    /// new, and never again for the same list (P1 — ∝ the note, once).
    func adopt(postID: String, rows: [Queries.TOCRow]) {
        guard rows.count != key.count
                || !zip(key, rows).allSatisfy({ $0 == $1.placementID })
        else { return }
        key = rows.map(\.placementID)
        var taken: [String: Queries.BlockExtent] = [:]
        taken.reserveCapacity(rows.count)
        for row in rows {
            taken[row.placementID] = ReadNoteHeightModel.extent(postID: postID, row: row)
        }
        extents = taken
        derivedMemo = [:]
        #if DEBUG
        extentTakes += 1
        #endif
    }

    /// A row drew at this height.
    func learn(_ placementID: String, height: CGFloat) {
        guard height.isFinite, height > 0 else { return }
        if let known = measured[placementID], abs(known - height) <= 0.5 { return }
        measured[placementID] = height
    }

    func derived(_ placementID: String) -> CGFloat {
        if let cached = derivedMemo[placementID] { return cached }
        guard let extent = extents[placementID] else {
            return (metrics.blockChrome + metrics.emptyLine).rounded()
        }
        let height = ReadNoteHeightModel.blockHeight(extent, metrics: metrics)
        derivedMemo[placementID] = height
        return height
    }

    func input(_ placementID: String) -> BookHeightManifest.Input {
        BookHeightManifest.Input(
            id: placementID, measured: measured[placementID], derived: derived(placementID))
    }

    /// The column as heights and offsets — built at a LANDING only
    /// (arithmetic over the rows in hand, ∝ rows; no read, no layout).
    ///
    /// `leading` is everything above the first block row in the scroll's
    /// CONTENT space (the manifest's contract — ladder round 1, MINOR-3): the
    /// edit column's top padding; the page's two paddings, its header row and
    /// one row gap. The offsets are then absolute, and a landing whose rows
    /// above are all measured (`exact=1`) states the column's geometry for
    /// the rows ABOVE the target; `total` still omits the bottom paddings
    /// and the page's footer, and `exact` says nothing about rows below
    /// (round-2 NIT-2's precision).
    /// Where rows above are arithmetic they are the manifest's MODEL of a
    /// column that stands at SwiftUI's own realization (the rows are lazy —
    /// QUESTIONS #151), which `LandingFacts`' doc says.
    func manifest(_ rows: [Queries.TOCRow], width: CGFloat, leading: CGFloat) -> BookHeightManifest {
        BookHeightManifest(
            width: width, spacing: metrics.rowSpacing, leading: leading,
            inputs: rows.map { input($0.placementID) })
    }

    var measuredCount: Int { measured.count }

    // MARK: - The type, measured off the face's real font

    /// A face's metrics at a content width. Every constant is read off the
    /// face's own drawing (named at each line) — never invented.
    static func metrics(
        face: Face, contentWidth: CGFloat, typeScale: Double
    ) -> ReadNoteHeightModel.Metrics {
        var metrics = ReadNoteHeightModel.Metrics()
        let font: NSFont
        let lineSpacing: CGFloat
        let prose: CGFloat
        switch face {
        case .edit:
            // `ReadEditBlock`'s read tier: the voice's body font (`tokens.body`
            // — the same two faces `EditorTypography` resolves), `lineSpacing`
            // and paragraph gap from the tiers' ONE vocabulary
            // (`IndexProseColumn.lines`, 18l-c U5 — U0's constants promoted),
            // padded by the tier's `IndexProseColumn` numbers; the column's
            // `LazyVStack(spacing: 2)`.
            font = EditorTypography.current.font
            lineSpacing = IndexProseColumn.lines.lineSpacing
            metrics.prose.paragraphGap = IndexProseColumn.lines.paragraphGap
            let leading = IndexProseColumn.readTierLeading(
                resting: IndexProseColumn.readEditResting,
                paneInset: PaneTextView.proseLeadingInset)
            prose = contentWidth - leading - IndexProseColumn.readEditResting
            metrics.blockChrome = IndexProseColumn.readTierTop(
                resting: IndexProseColumn.readEditRestingTop,
                paneInset: PaneTextView.proseTopInset)
                + IndexProseColumn.readTierBottom(
                    resting: IndexProseColumn.readEditRestingTop,
                    paneInset: PaneTextView.proseBottomInset)
            metrics.rowSpacing = 2
        case .page:
            // `ReadPageBlock`: the page serif at `(16 × scale).rounded()`,
            // `lineSpacing(6 × scale)`, paragraphs 11 × scale apart, the row's
            // 8/3 padding; the page column's `LazyVStack(spacing: 14 × scale)`.
            let size = (16 * typeScale).rounded()
            let base = NSFont.systemFont(ofSize: size)
            font = base.fontDescriptor.withDesign(.serif)
                .flatMap { NSFont(descriptor: $0, size: size) } ?? base
            lineSpacing = 6 * typeScale
            metrics.prose.paragraphGap = 11 * typeScale
            prose = contentWidth - 16
            metrics.blockChrome = 6
            metrics.rowSpacing = 14 * typeScale
        }
        let sample = "the quick brown fox jumps over a lazy dog and keeps going "
        let advance = (sample as NSString).size(withAttributes: [.font: font]).width
            / CGFloat(sample.count)
        let lineHeight = font.ascender - font.descender + font.leading
        metrics.prose.charsPerLine = max(8, Double(max(80, prose) / max(advance, 1)))
        metrics.prose.linePitch = lineHeight + lineSpacing
        metrics.prose.lineSpacing = lineSpacing
        metrics.emptyLine = lineHeight
        return metrics
    }
}

// MARK: - One face's landing bookkeeping (NOT render state)

/// The page facts and the pending target's last place — written at
/// geometry cadence, read by the landing. A reference box a `@State` merely
/// holds, so its writes invalidate nothing (the Index's `PaneLandingBox` rule:
/// a state write per report would be a loop of the landing's own making).
@MainActor
final class ReadLandingBox {
    var scroll = ReadScrollFacts()
    /// The rows' stack width — the manifest's measure.
    var contentWidth: CGFloat = 0
    /// The page face's header row height, measured (the page's `leading`
    /// includes it — ladder round 1, MINOR-3). The edit face has no header.
    var headerHeight: CGFloat = 0
    /// The pending landing's anchor fraction.
    var anchorY: CGFloat = 0.5
    /// Where each realized row last said it was (viewport-relative top,
    /// height) — the seed that lets a landing on the block the page is
    /// ALREADY at terminate (`LandingAuthority.tops`' reason), and the
    /// residual's input. A row that goes away takes its entry with it.
    var rows: [String: (top: CGFloat, height: CGFloat)] = [:]

    func residual(_ placementID: String) -> CGFloat? {
        guard let row = rows[placementID], scroll.viewportHeight > 0 else { return nil }
        return ReadLandingResidual.residual(
            blockTop: row.top, blockHeight: row.height,
            viewportHeight: scroll.viewportHeight, anchorY: anchorY,
            offset: scroll.offset, minOffset: scroll.minOffset, maxOffset: scroll.maxOffset)
    }
}

#if DEBUG
/// The DEBUG landing story (the Index's `BookIndexGeometry.trace` shape) —
/// an append-only, bounded log the storyboard writes and the pins read.
@MainActor
enum ReadLandingStory {
    static var trace: [String] = [] {
        didSet { DebugOracleLog.bound(&trace) }
    }

    static func storyboard(_ surface: LandingSurface) -> LandingStoryboard {
        LandingStoryboard(
            note: { trace.append("[\(surface.rawValue)] \($0)") },
            dump: {
                let start = trace.lastIndex(where: { $0.hasSuffix(" LAND") }) ?? 0
                return trace[start...].joined(separator: " | ")
            })
    }
}
#endif

extension LandingAuthority {
    /// A note Read face's authority, with its DEBUG story wired.
    static func readNote(_ policy: LandingPolicy) -> LandingAuthority {
        #if DEBUG
        LandingAuthority(policy: policy, storyboard: ReadLandingStory.storyboard(policy.surface))
        #else
        LandingAuthority(policy: policy)
        #endif
    }
}
