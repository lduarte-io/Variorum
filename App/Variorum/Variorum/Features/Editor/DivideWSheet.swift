//
//  DivideWSheet.swift
//  Variorum
//
//  The W ceremony as ONE sheet (Phase 9 Step 6 — the ratified contract,
//  item 3), rebuilt at 13b Stage 4 Batch 4A to the RULED cut redesign
//  (the W memo addendum + S4-22): every checked take is visible at once
//  with its ✂ sitting in its own text (N16(b)); the ✂ drags and glides
//  between word edges, click-to-jump survives (N16(c)); keyboard placement
//  (←/→ by word, ⌥←/→ by sentence, ⇥ between takes, ⏎ confirms); a cut
//  parked at a take's very end/start keeps the take whole on the first/
//  second block (parking — the single-sentence dead end is gone both
//  ways). Confirm is gated with honest copy (`confirmBlocker`), Cancel
//  touches nothing, and the live editor is untouched for the ceremony's
//  whole duration. The sheet is ordinary SwiftUI — never the live TK2
//  editor.
//

import SwiftUI
import VariorumCore

struct DivideWSheet: View {
    /// 13d Batch 3 (A9): the sheet is parameterized on the CEREMONY, not
    /// on Write's view model — that is what lets a takes board mount the
    /// same sheet in place. Every rule it shows is the ceremony's.
    let ceremony: DivideWCeremony
    /// The presentation snapshot (`.sheet(item:)` captures the value once);
    /// rendering always prefers the LIVE ceremony state on the observable
    /// object, so marks and cut placements re-render.
    let presented: DivideWCeremony.State

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var activeTakeID: String?
    @FocusState private var keyboardFocused: Bool

    private var state: DivideWCeremony.State {
        ceremony.state ?? presented
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Divide into takes").font(.headline)
            Text("Each checked take carries its own cut — drag the ✂, click between words, or use ←/→ (⌥ jumps by sentence, ⇥ moves between takes). Park the ✂ at a take's very end to keep it whole on the first block, at its start for the second. Unmarked takes stay on the original block; the divide is reversible (⌥⌘Z).")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(6)
                .fixedSize(horizontal: false, vertical: true)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(state.takes) { take in
                        takeRow(take)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(minHeight: 240, maxHeight: 420)

            if let blocker = state.confirmBlocker {
                Text(blocker)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack {
                Button("Cancel") { ceremony.cancel() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Divide") { Task { await ceremony.confirm() } }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!state.canConfirm)
            }
        }
        .padding(12)
        .frame(minWidth: 560)
        .focusable()
        .focused($keyboardFocused)
        .onKeyPress(phases: .down) { handleKey($0) }
        .onAppear {
            activeTakeID = state.activeVariantID
            keyboardFocused = true
        }
    }

    // MARK: - Rows

    @ViewBuilder
    private func takeRow(_ take: DivideWCeremony.WTake) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(isOn: Binding(
                get: { take.marked },
                set: { _ in
                    ceremony.toggleTake(take.id)
                    if activeTakeID == take.id { activeTakeID = nil }
                })
            ) {
                HStack(spacing: 6) {
                    if take.marked, take.id == activeTakeID {
                        // The keyboard's active-take marker (the › idiom).
                        Text("›").font(.caption).foregroundStyle(tokens.accent)
                    }
                    Text(take.variant.label ?? "take")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if take.id == state.activeVariantID {
                        Text("shown here").font(.caption2).foregroundStyle(.tertiary)
                    }
                    if take.variant.locked {
                        Text("locked").font(.caption2).foregroundStyle(.tertiary)
                    }
                }
            }

            if take.marked {
                if take.boundaries.isEmpty {
                    Text("This take is empty — there's no cut to place. Uncheck it (it stays on the original block).")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .lineLimit(2)
                } else {
                    WCutFlow(
                        take: take,
                        tokens: tokens,
                        place: { placeCut(takeID: take.id, cut: $0) })
                    placementNote(take)
                }
            } else {
                Text(take.variant.workingText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture {
            if take.marked { activeTakeID = take.id }
        }
    }

    @ViewBuilder
    private func placementNote(_ take: DivideWCeremony.WTake) -> some View {
        if take.parkedAtEnd {
            Text("✂ parked at the end — this whole take rides into the first block.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        } else if take.parkedAtStart {
            Text("✂ parked at the start — this whole take rides into the second block.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        } else if take.cut == nil {
            Text("Place the cut: drag the ✂ in, click between words, or press ←/→.")
                .font(.caption2)
                .foregroundStyle(.orange)
                .lineLimit(2)
        }
    }

    // MARK: - Placement plumbing

    private func placeCut(takeID: String, cut: Int) {
        activeTakeID = takeID
        ceremony.placeCut(takeID: takeID, cut: cut)
    }

    // MARK: - Keyboard (←/→ word · ⌥←/→ sentence · ⇥ takes)

    private func handleKey(_ press: KeyPress) -> KeyPress.Result {
        let markedIDs = state.takes.filter(\.marked).map(\.id)
        switch press.key {
        case .tab:
            guard let next = WCutPlacement.nextTake(
                after: activeTakeID, in: markedIDs,
                forward: !press.modifiers.contains(.shift))
            else { return .ignored }
            activeTakeID = next
            return .handled
        case .leftArrow, .rightArrow:
            let forward = press.key == .rightArrow
            // The active take, or the first checked one if none is active.
            guard let takeID = (activeTakeID.flatMap { markedIDs.contains($0) ? $0 : nil })
                    ?? markedIDs.first,
                  let take = state.takes.first(where: { $0.id == takeID }),
                  !take.boundaries.isEmpty
            else { return .ignored }
            let next: Int?
            if press.modifiers.contains(.option) {
                next = WCutPlacement.sentenceStep(
                    from: take.cut, in: take.variant.workingText,
                    boundaries: take.boundaries, forward: forward)
            } else {
                next = WCutPlacement.wordStep(
                    from: take.cut, boundaries: take.boundaries, forward: forward)
            }
            if let next, next != take.cut {
                placeCut(takeID: takeID, cut: next)
            } else {
                activeTakeID = takeID
            }
            return .handled
        default:
            return .ignored
        }
    }
}

// MARK: - The cut flow (words + slots + the draggable ✂)

/// A marked take's text as a wrapping flow of word tokens with a placeable
/// slot at every legal cut position — the ✂ sits at the current cut, slots
/// click to jump, and a drag anywhere in the flow glides the ✂ between
/// word edges (nearest slot, row-first, with a small extra catch for
/// sentence/newline slots — the gentle settle's visual half). Cost is
/// bounded by the take's word count — fan-scale, never corpus-scale.
private struct WCutFlow: View {
    let take: DivideWCeremony.WTake
    let tokens: VoiceTokens
    let place: (Int) -> Void

    @State private var slotFrames: [Int: CGRect] = [:]

    private var spaceName: String { "wcutflow-\(take.id)" }

    private var strongSlots: Set<Int> {
        Set(BoundarySnapping.boundaries(
            in: take.variant.workingText, granularity: .sentence))
    }

    var body: some View {
        let items = WCutPlacement.flowItems(
            text: take.variant.workingText, boundaries: take.boundaries)
        CutFlowLayout(lineSpacing: 4) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                switch item {
                case .slot(let boundary):
                    CutSlotView(
                        isCut: take.cut == boundary,
                        isStrong: strongSlots.contains(boundary),
                        tokens: tokens
                    ) {
                        place(boundary)
                    }
                    .background(GeometryReader { geo in
                        Color.clear.preference(
                            key: SlotFramesKey.self,
                            value: [boundary: geo.frame(in: .named(spaceName))])
                    })
                case .token(let text, let breaksLineAfter):
                    Text(text)
                        .font(.callout)
                        .foregroundStyle(tokens.ink)
                        .fixedSize()
                        .lineLimit(1)
                        .layoutValue(key: CutFlowLayout.BreaksLineAfter.self,
                                     value: breaksLineAfter)
                }
            }
        }
            .coordinateSpace(name: spaceName)
            .onPreferenceChange(SlotFramesKey.self) { slotFrames = $0 }
            .gesture(
                DragGesture(minimumDistance: 4, coordinateSpace: .named(spaceName))
                    .onChanged { drag in
                        guard let nearest = nearestSlot(to: drag.location),
                              nearest != take.cut else { return }
                        place(nearest)
                    })
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 4).fill(tokens.wash.opacity(0.35)))
    }

    /// Nearest slot to a drag location: row-first (the slot whose line the
    /// pointer is on wins), then horizontal distance, with a few extra
    /// points of catch for strong (sentence/newline/end) slots — the
    /// gentle settle, geometrically.
    private func nearestSlot(to point: CGPoint) -> Int? {
        slotFrames.min { a, b in score(a, point) < score(b, point) }?.key
    }

    private func score(_ entry: (key: Int, value: CGRect), _ point: CGPoint) -> CGFloat {
        let frame = entry.value
        let dy = abs(point.y - frame.midY)
        let dx = abs(point.x - frame.midX)
        let pull: CGFloat = strongSlots.contains(entry.key) ? 4 : 0
        // Rows are ~18pt tall: a full row of vertical distance outweighs
        // any horizontal distance within a row.
        return dy * 100 + max(0, dx - pull)
    }
}

private struct CutSlotView: View {
    let isCut: Bool
    let isStrong: Bool
    let tokens: VoiceTokens
    let place: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: place) {
            ZStack {
                if isCut {
                    Text("✂")
                        .font(.system(size: 13))
                        .foregroundStyle(tokens.accent)
                } else {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(hovering
                            ? tokens.accent.opacity(0.8)
                            : (isStrong ? tokens.muted.opacity(0.6) : tokens.line))
                        .frame(width: hovering ? 2.5 : 1.5,
                               height: isStrong ? 13 : 9)
                }
            }
            .frame(width: isCut ? 18 : 9, height: 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help(isCut
            ? "The cut lands here — drag to move it"
            : "Click to place the cut here")
    }
}

private struct SlotFramesKey: PreferenceKey {
    static let defaultValue: [Int: CGRect] = [:]
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

/// A wrapping flow layout for slot/token runs: items lay out left to
/// right, wrap at the proposed width, and a token flagged `BreaksLineAfter`
/// forces the next item onto a new line (outline takes keep their visible
/// line structure). Bounded by the take's token count.
private struct CutFlowLayout: Layout {
    var lineSpacing: CGFloat = 3

    struct BreaksLineAfter: LayoutValueKey {
        static let defaultValue = false
    }

    func sizeThatFits(
        proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? 560
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, widest: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            x += size.width
            rowHeight = max(rowHeight, size.height)
            widest = max(widest, x)
            if subview[BreaksLineAfter.self] {
                x = 0
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
        }
        return CGSize(width: proposal.width ?? widest, height: y + rowHeight)
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) {
        let maxWidth = bounds.width
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
            subview.place(
                at: CGPoint(x: bounds.minX + x, y: bounds.minY + y),
                anchor: .topLeading,
                proposal: ProposedViewSize(size))
            x += size.width
            rowHeight = max(rowHeight, size.height)
            if subview[BreaksLineAfter.self] {
                x = 0
                y += rowHeight + lineSpacing
                rowHeight = 0
            }
        }
    }
}
