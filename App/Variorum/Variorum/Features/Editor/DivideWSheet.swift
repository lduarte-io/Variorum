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

#if DEBUG
/// **The flow's rebuild instrument** (reworked at the cold review's fix pass,
/// F-2/F-3). The batch shipped this as a `slotViews` counter that NOTHING in
/// production ever incremented — a tripwire that could not fire on any
/// regression, so its `== 0` assertions were green over nothing (F-3; the
/// invoked `CanvasCardMaterialization` precedent is production-bumped, which
/// is what makes ITS zero an assertion). The per-slot-view bound is carried
/// by the scan assertions plus the one-brain geometry; the vacuous
/// assertions are gone.
///
/// `rebuilds` is real: `WCutFlow.rebuild()` bumps it in production code, and
/// the F-2 pin uses it to prove a drift refresh re-derives the drawn
/// geometry (the count-preserving staleness class).
@MainActor
enum CutFlowRealization {
    static var rebuilds = 0
}
#endif

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
            // L2 (QoL round 2026-07-29), her words: *"it's not really clear to
            // me what selecting the take button below is supposed to do? just
            // split that take as well?"* — yes, exactly, and the surface never
            // said so. These two sentences are the two halves of what a check
            // MEANS; the per-row captions repeat them where she is looking.
            Text("**Check the takes that should be cut.** Each checked take carries its own \u{2702}, and its two halves become the two new blocks' takes. **An unchecked take is not cut and goes into neither new block** — it stays whole on the original, which the divide keeps.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(5)
                .fixedSize(horizontal: false, vertical: true)
            Text("Place a cut by dragging the \u{2702}, clicking between words, or \u{2190}/\u{2192} (\u{2325} by sentence, \u{21E5} moves between takes). Park it at a take's very end to send that whole take into the first block, at its start for the second. **\u{203A}** marks the take the arrow keys are aimed at. The divide is reversible (\u{2325}\u{2318}Z).")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .lineLimit(4)
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
                Text("Not cut — stays whole on the original block, in neither new one.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                Text(take.variant.workingText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture {
            // HER RULING (2026-07-29, selection: "Check it"): clicking an
            // UNCHECKED take's row checks it and aims the arrows there. It
            // used to do nothing at all — a silent dead click, the
            // fire-and-DO class (P-2), and plausibly why the checkbox and the
            // \u{203A} marker read as one control to her. A checked row keeps
            // its existing aim-the-arrows behaviour.
            activeTakeID = ceremony.rowTapped(take.id)
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
                    from: take.cut, strong: take.strongBoundaries,
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

// MARK: - The cut flow (DRAWN, not built — QoL round 2026-07-29, L1)

/// A marked take's text as a wrapping flow of word tokens with a placeable
/// slot at every legal cut position — the ✂ sits at the current cut, slots
/// click to jump, and a drag glides the ✂ between word edges (nearest slot,
/// row-first, with a small extra catch for sentence/newline slots — the gentle
/// settle's visual half).
///
/// **It DRAWS the flow instead of building one, and that is the L1 fix.** The
/// shipped version realized a `Button` + `ZStack` + hover tracker + `help` +
/// `GeometryReader` per legal cut position and a `Text` per word — measured at
/// 2,766 view elements for three 400-word takes, each measured twice per
/// layout pass, with a `PreferenceKey` round-trip writing `@State` from inside
/// layout (the publish-during-update class, P-8) — and on top of that it
/// re-ran a full sentence scan of the take's text once PER SLOT, because
/// `strongSlots` was a computed property read inside the `ForEach`. Measured:
/// 4,149 scans and 6.3 s for ONE mount, 1,383 scans and 8.7 s for ONE click;
/// at her real scale (four 3,000-word takes) a single click did not complete
/// inside a 600-second test timeout. That is the spinning rainbow she
/// reported.
///
/// Now: one `Canvas`, one `CutFlowGeometry` cached per (take, width), and the
/// pointer resolving against the same frames the drawing uses — one brain, so
/// drawing and hit-testing cannot disagree, which the three-mechanism version
/// could never promise.
private struct WCutFlow: View {
    let take: DivideWCeremony.WTake
    let tokens: VoiceTokens
    let place: (Int) -> Void

    @State private var geometry = CutFlowGeometry()
    @State private var width: CGFloat = 0
    @State private var hovered: Int?

    private static let flowFont = NSFont.preferredFont(forTextStyle: .callout)

    var body: some View {
        Canvas(opaque: false) { context, _ in
            for token in geometry.tokens {
                context.draw(
                    Text(token.text).font(.callout).foregroundStyle(tokens.ink),
                    at: CGPoint(x: token.frame.minX, y: token.frame.midY),
                    anchor: .leading)
            }
            for slot in geometry.slots where slot.boundary != take.cut {
                let height: CGFloat = slot.isStrong ? 13 : 9
                let isHovered = hovered == slot.boundary
                let mark = CGRect(
                    x: slot.frame.midX - (isHovered ? 1.25 : 0.75),
                    y: slot.frame.midY - height / 2,
                    width: isHovered ? 2.5 : 1.5,
                    height: height)
                context.fill(
                    Path(roundedRect: mark, cornerRadius: 1),
                    with: .color(isHovered
                        ? tokens.accent.opacity(0.8)
                        : (slot.isStrong ? tokens.muted.opacity(0.6) : tokens.line)))
            }
            if let cut = take.cut, let frame = geometry.slotFrame(for: cut) {
                context.draw(
                    Text("✂").font(.system(size: 13)).foregroundStyle(tokens.accent),
                    at: CGPoint(x: frame.midX, y: frame.midY),
                    anchor: .center)
            }
        }
        .frame(height: max(geometry.size.height, CutFlowGeometry.slotHeight))
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { newWidth in
            guard abs(newWidth - width) > 0.5 else { return }
            width = newWidth
            rebuild()
        }
        .onChange(of: take.id) { rebuild() }
        // The WHOLE flow, not its count (cold review F-2, pin-verified red on
        // the count key): a confirm-time drift refresh rebuilds this take
        // from CHANGED store text under the SAME id, and a token-count-
        // preserving edit left the Canvas drawing the OLD words while cuts
        // and clicks resolved against them. `FlowItem` is `Equatable`; the
        // comparison is O(tokens) per change — no text scan.
        .onChange(of: take.flow) { rebuild() }
        .onContinuousHover { phase in
            switch phase {
            case .active(let point): hovered = geometry.nearestSlot(to: point)
            case .ended: hovered = nil
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { drag in
                    guard let nearest = geometry.nearestSlot(to: drag.location),
                          nearest != take.cut else { return }
                    place(nearest)
                })
        .padding(6)
        .background(RoundedRectangle(cornerRadius: 4).fill(tokens.wash.opacity(0.35)))
        .accessibilityElement()
        .accessibilityLabel(Text(take.variant.label ?? "take"))
        .accessibilityValue(Text(accessibilityValue))
        .accessibilityHint(Text("Drag, click, or use the arrow keys to move the cut."))
    }

    /// The minimal accessibility story the ruling asked for "if cheap": one
    /// element per take, naming it and where its cut sits. **Recorded known
    /// limitation:** a drawn flow cannot expose a slot per cut position as its
    /// own element, and three thousand of them would not be usable if it did —
    /// the keyboard family (←/→, ⌥←/→, ⇥) is the accessible placement path.
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
        geometry = CutFlowGeometry.make(
            flow: take.flow, strong: take.strongBoundaries,
            width: width, font: Self.flowFont)
    }
}
