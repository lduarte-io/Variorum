//
//  ProseTakeCard.swift
//  Variorum (Mac)
//
//  **THE DIVIDE SHEET'S TAKE, AS THE MOCKUP DRAWS IT** — 18f batch 2,
//  figure A. Her ledger row 5, verbatim: *"so ugly with the spacing between
//  the words, the way that you have to scroll to get the different takes,
//  just overall"*.
//
//  One card per take, three of them side by side:
//
//    · a header — the take's name, its badges, and (only under "Choose per
//      take…") its checkbox;
//    · ONE status line — *"✂ splits here — 41 words above, 38 below"*, or
//      where the whole take is going when the ✂ is parked;
//    · the take as PROSE, drawn from `ProseCutGeometry` — natural spacing,
//      the two halves tinted around the ✂, and the ✂ itself an OVERLAY on
//      the inter-word gap, so the layout never moves when it does;
//    · a footer that names the destination with the same two swatches the
//      tints use — *"shown, not explained"*.
//
//  ONE brain for drawing and hit-testing (the L1 doctrine): the Canvas draws
//  from the cached geometry and the drag resolves against it, through
//  `CutFlowGeometry.nearestSlot` — the same snapping rule, with its own pins.
//

import AppKit
import CoreText
import SwiftUI
import VariorumCore

/// Where a take goes when the divide lands — the card's footer and its
/// status line say the same thing, from this one answer.
enum CeremonyDestination: Equatable {
    /// The take splits at the ✂: its halves become the two blocks' takes.
    case split
    /// Parked at the end — the whole take stays on the top block.
    case top
    /// Parked at the start — the whole take goes to the bottom block.
    case bottom
    /// "Copy takes to both": not cut, ridden whole onto both successors.
    case both
    /// Not cut at all — it stays on the original block, in lineage.
    case original
    /// Checked, but its ✂ has not been placed yet (hand-placement only).
    case unplaced
    /// Empty text: there is nothing to place, so it stays on the original.
    case empty
}

/// The card's pure copy and its one destination rule — pinned rather than
/// read off a screenshot (`FannedDefaultsCopy`'s doctrine: a sentence may
/// only claim what the operation will actually do).
nonisolated enum CeremonyCardCopy {
    static func destination(
        arrangement: DivideWCeremony.Arrangement, isSeed: Bool,
        marked: Bool, isEmpty: Bool, cut: Int?,
        parkedAtEnd: Bool, parkedAtStart: Bool
    ) -> CeremonyDestination {
        if isEmpty { return marked && arrangement == .perTake ? .empty : .original }
        guard marked else { return .original }
        if arrangement == .copyToBoth, !isSeed { return .both }
        if parkedAtEnd { return .top }
        if parkedAtStart { return .bottom }
        return cut == nil ? .unplaced : .split
    }

    /// The ONE status line per take (§5.2). `words` is (above, below) at the
    /// current ✂ — nil before the card has laid its prose out, which is the
    /// one frame where the counts are not yet known.
    static func status(
        _ destination: CeremonyDestination, words: (above: Int, below: Int)?
    ) -> String {
        switch destination {
        case .split:
            guard let words else { return "\u{2702} splits here." }
            return "\u{2702} splits here — \(wordCount(words.above)) above, "
                + "\(words.below) below"
        case .top:
            return "\u{2702} at the end — this whole take stays on the top block"
        case .bottom:
            return "\u{2702} at the start — this whole take goes to the bottom block"
        case .both:
            return "Not cut — this whole take rides onto BOTH blocks"
        case .original:
            return "Not cut — stays whole on the original block, in lineage"
        case .unplaced:
            return "Place the \u{2702} — drag it, click between words, or \u{2190}/\u{2192}"
        case .empty:
            return "This take is empty — there's no cut to place. Uncheck it."
        }
    }

    private static func wordCount(_ n: Int) -> String {
        n == 1 ? "1 word" : "\(n) words"
    }

    /// **The divide sheet's resting footer line** (§5.2; 13f W10a's promise
    /// kept where the eye rests): the original is never lost, and the line
    /// says where it went, in the canon path's own words.
    static var divideRestingLine: String {
        "The original block stays whole in \(TrayPath.originalsPath)."
    }

    /// The merge sheet's, in the same grammar (mockup figure B's footer).
    static func mergeRestingLine(blocks: Int) -> String {
        blocks > 2
            ? "The original blocks stay whole in \(TrayPath.originalsPath)."
            : "Both original blocks stay whole in \(TrayPath.originalsPath)."
    }

    /// The footer's destination line — the swatch labels, in order.
    static func footer(_ destination: CeremonyDestination) -> [String] {
        switch destination {
        case .split: return ["top block", "bottom block"]
        case .top: return ["top block · whole"]
        case .bottom: return ["bottom block · whole"]
        // Two swatches, no "· whole" on either: the status line above already
        // says the whole take rides onto both, and the longer pair truncated
        // at a three-column card's width (walked, 18f batch 2).
        case .both: return ["top block", "bottom block"]
        case .original, .empty: return []
        case .unplaced: return []
        }
    }

    /// What the footer says when no swatch applies.
    static func footerNote(_ destination: CeremonyDestination) -> String? {
        switch destination {
        case .original, .empty: return "original block · lineage"
        case .unplaced: return "no cut placed yet"
        case .split, .top, .bottom, .both: return nil
        }
    }
}

// MARK: - The card

struct ProseTakeCard: View {
    let take: DivideWCeremony.WTake
    let tokens: VoiceTokens
    let font: NSFont
    let arrangement: DivideWCeremony.Arrangement
    /// The take's place in the block's fan (1-based) — the card's name when
    /// the take carries no label of its own, in the mockup's own grammar
    /// ("take" · "take 2" · "take 3").
    let ordinal: Int
    let isSeed: Bool
    let isAimed: Bool
    /// False = SHOW-ONLY (mockup A: under a preset the columns only show
    /// what will happen; the drag is not attached, so nothing looks live
    /// that isn't). The SEED stays placeable on every road.
    let placeable: Bool
    let showsCheckbox: Bool
    let toggle: () -> Void
    let place: (Int) -> Void
    let aim: () -> Void

    @State private var geometry = ProseCutGeometry()
    @State private var width: CGFloat = 0

    private var destination: CeremonyDestination {
        CeremonyCardCopy.destination(
            arrangement: arrangement, isSeed: isSeed, marked: take.marked,
            isEmpty: take.variant.workingText.isEmpty, cut: take.cut,
            parkedAtEnd: take.parkedAtEnd, parkedAtStart: take.parkedAtStart)
    }

    private var words: (above: Int, below: Int)? {
        guard let cut = take.cut, !geometry.isEmpty else { return nil }
        let above = geometry.wordsBefore(cut)
        return (above, max(0, geometry.wordCount - above))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider().overlay(tokens.line.opacity(0.6))
            Text(CeremonyCardCopy.status(destination, words: words))
                .font(tokens.small)
                .foregroundStyle(destination == .empty ? tokens.alarm : tokens.muted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
                .padding(.top, 8)
            prose
            Spacer(minLength: 0)
            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(tokens.card, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSeed ? tokens.ring.opacity(0.55) : tokens.line,
                        lineWidth: isSeed ? 1.5 : 1))
        // The unchecked take dims (mockup A, state 2) — it is not part of
        // the divide, and the card says so before its footer does.
        .opacity(take.marked ? 1 : 0.62)
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture { aim() }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 7) {
            if showsCheckbox {
                Toggle(isOn: Binding(get: { take.marked }, set: { _ in toggle() })) {
                    EmptyView()
                }
                .toggleStyle(.checkbox)
                .labelsHidden()
                // Row 3 (18f batch 1): the checkbox acts; taking the sheet's
                // first responder is all it ever did besides.
                .focusable(false)
            }
            if isAimed {
                Text("\u{203A}")
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            Text(tokens.chromeLabel(
                take.variant.label ?? (ordinal <= 1 ? "take" : "take \(ordinal)")))
                .font(tokens.small)
                .fontWeight(.semibold)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            if isSeed {
                CeremonyBadge(tokens: tokens, text: "shown here", tint: tokens.accent)
            }
            if take.variant.locked {
                CeremonyBadge(tokens: tokens, text: "locked")
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(tokens.wash.opacity(0.35))
    }

    // MARK: The prose (drawn, one brain — L1's own architecture)

    @ViewBuilder
    private var prose: some View {
        if take.variant.workingText.isEmpty {
            Text("There is nothing in this take to cut.")
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
        } else {
            ScrollView(.vertical) {
                Canvas(opaque: false) { context, _ in
                    draw(in: context)
                }
                .frame(height: max(geometry.size.height, 1), alignment: .topLeading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { new in
                    guard abs(new - width) > 0.5 else { return }
                    width = new
                    rebuild()
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            guard placeable,
                                  let nearest = geometry.nearestBoundary(to: drag.location),
                                  nearest != take.cut else { return }
                            place(nearest)
                        },
                    including: placeable ? .all : .subviews)
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 10)
                .accessibilityElement()
                .accessibilityLabel(Text(take.variant.label ?? "take"))
                .accessibilityValue(Text(accessibilityValue))
                .accessibilityHint(
                    Text("Drag, click, or use the arrow keys to move the cut."))
            }
            .frame(maxHeight: 260)
            .onChange(of: take.variant.workingText) { rebuild() }
            .onChange(of: font) { rebuild() }
        }
    }

    private func draw(in context: GraphicsContext) {
        guard !geometry.isEmpty else { return }
        // The two halves, behind the words: the tint is the layout's
        // passenger, never its cause.
        if take.marked, destination == .split || destination == .top
            || destination == .bottom {
            let halves = geometry.halfRects(splitAt: take.cut)
            for rect in halves.top {
                context.fill(Path(rect), with: .color(CeremonyHalfTint.top(tokens)))
            }
            for rect in halves.bottom {
                context.fill(Path(rect), with: .color(CeremonyHalfTint.bottom(tokens)))
            }
        }
        // The prose itself, drawn from the same lines the marks were placed
        // on — one brain, so what is drawn and what is clicked cannot
        // disagree (`Canvas` + Core Text; no TextKit anywhere near this).
        context.withCGContext { cg in
            cg.saveGState()
            cg.textMatrix = CGAffineTransform(scaleX: 1, y: -1)
            cg.setFillColor(NSColor(tokens.ink).cgColor)
            for line in geometry.lines {
                cg.textPosition = CGPoint(
                    x: line.origin.x, y: line.origin.y + line.baseline)
                CTLineDraw(line.line, cg)
            }
            cg.restoreGState()
        }
        // The ✂, OVER the inter-word gap it sits in: a hairline rule down the
        // line's band and the glyph riding just above it, on a small chip of
        // the card's own colour so it reads clear of the line above (the
        // mockup's `.cut::after`, which punches out the same way).
        guard take.marked, let cut = take.cut,
              let frame = geometry.markFrame(at: cut),
              let air = geometry.lineIndex(for: cut).map({ geometry.lines[$0].textTop })
        else { return }
        let bar = CGRect(
            x: frame.midX - 0.75, y: frame.minY + air - 1,
            width: 1.5, height: max(frame.height - air, 2))
        context.fill(
            Path(roundedRect: bar, cornerRadius: 0.75), with: .color(tokens.ring))
        let chip = CGRect(
            x: frame.midX - 6.5, y: frame.minY + air - 12, width: 13, height: 11.5)
        context.fill(
            Path(roundedRect: chip, cornerRadius: 3), with: .color(tokens.card))
        context.draw(
            Text("\u{2702}").font(.system(size: 9.5)).foregroundStyle(tokens.ring),
            at: CGPoint(x: chip.midX, y: chip.midY),
            anchor: .center)
    }

    /// The minimal accessibility story (unchanged from the drawn flow's): one
    /// element per take, naming it and where its cut sits. The keyboard family
    /// (←/→, ⌥←/→, ⇥) stays the accessible placement path.
    private var accessibilityValue: String {
        guard let cut = take.cut else { return "no cut placed" }
        if take.parkedAtEnd { return "whole take goes to the first block" }
        if take.parkedAtStart { return "whole take goes to the second block" }
        let index = take.boundaries.firstIndex(of: cut).map { $0 + 1 } ?? 0
        return "cut at position \(index) of \(take.boundaries.count)"
    }

    private func rebuild() {
        #if DEBUG
        CutFlowRealization.rebuilds += 1
        #endif
        geometry = ProseCutGeometry.make(
            text: take.variant.workingText, boundaries: take.boundaries,
            strong: take.strongBoundaries, width: width, font: font)
    }

    // MARK: Footer

    private var footer: some View {
        HStack(spacing: 12) {
            let labels = CeremonyCardCopy.footer(destination)
            if labels.isEmpty {
                Text(tokens.chromeLabel(
                    CeremonyCardCopy.footerNote(destination) ?? ""))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
            } else {
                ForEach(Array(labels.enumerated()), id: \.offset) { i, label in
                    CeremonySwatch(
                        color: i == 0 && destination != .bottom
                            ? CeremonyHalfTint.top(tokens)
                            : CeremonyHalfTint.bottom(tokens),
                        label: label, tokens: tokens)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .overlay(alignment: .top) { Divider().overlay(tokens.line.opacity(0.6)) }
    }
}
