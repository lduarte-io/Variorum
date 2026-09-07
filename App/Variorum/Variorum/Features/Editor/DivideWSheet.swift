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

import AppKit
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
    /// Ledger row 3's fix — see `installKeyMonitor`.
    @State private var keyMonitor: Any?

    private var state: DivideWCeremony.State {
        ceremony.state ?? presented
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Divide choosing takes").font(.headline)

            // **THE ARRANGEMENT ROW** (her ruling U-5, mockup figure A): the
            // FIRST control, four options in the ruled order, "keep on top"
            // selected on open. Batch 1 gives it its brains and its words on
            // today's controls (`VoicedChip` is the chrome vocabulary, P-8);
            // batch 2 gives it the mockup's face.
            arrangementRow

            Text(DivideWCeremony.arrangementSentence(
                state.arrangement,
                others: state.otherTakes.count,
                unparkable: state.unparkableTakes.count))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)

            if state.arrangement == .perTake {
                // L2 (QoL round 2026-07-29), her words: *"it's not really clear to
                // me what selecting the take button below is supposed to do? just
                // split that take as well?"* — yes, exactly, and the surface never
                // said so. These two sentences are the two halves of what a check
                // MEANS; the per-row captions repeat them where she is looking.
                // 13f W10a (her sitting question): the line said an unchecked take
                // "stays whole on the original" and stopped there — *"but how do I
                // even see the original one?"* It now NAMES where the original
                // goes, in the merge ceremony's own established grammar (that
                // sheet has always spelled this road out for its stay-behind
                // takes; the divide's half of the same sentence was simply
                // missing). `RecoveryPath` is the shared name.
                //
                // U-5 folds both explainers behind "Choose per take…": under a
                // preset there is no checklist to explain, and the one sentence
                // above says what will happen instead.
                Text(.init(DivideWCeremony.checklistExplainer))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(6)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Place a cut by dragging the \u{2702}, clicking between words, or \u{2190}/\u{2192} (\u{2325} by sentence, \u{21E5} moves between takes). Park it at a take's very end to send that whole take into the first block, at its start for the second. **\u{203A}** marks the take the arrow keys are aimed at. The divide is reversible (\u{2325}\u{2318}Z).")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

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
        // The row of four needs the width; the FACE (and the real sizing to
        // the window) is batch 2's.
        .frame(minWidth: 720)
        .focusable()
        .focused($keyboardFocused)
        .onKeyPress(phases: .down) { handleKey($0) }
        .onAppear {
            activeTakeID = state.activeVariantID
            keyboardFocused = true
            installKeyMonitor()
        }
        .onDisappear { removeKeyMonitor() }
    }

    // MARK: - The keyboard's focus (LEDGER ROW 3 — her *"the scissors
    // couldn't be placed at the end of the block"*)

    /// **Re-arm the sheet's key focus after ANY control interaction.**
    ///
    /// Traced by USE on the dev-store build (18f batch 1's walk, captured):
    /// the sheet armed `keyboardFocused` exactly once, in `onAppear`, and
    /// every control inside it — a take's checkbox `Toggle`, and now the
    /// arrangement chips — takes first responder when clicked. The
    /// `.focusable()` container never took it back, so ←/→, ⌥←/→ and ⇥ were
    /// DEAD for the rest of the sheet's life after the first click on a
    /// control. Her own session made that click unavoidable: the lesson (and
    /// the sheet's own copy) tells you to uncheck a take before confirming.
    /// What was left was dragging a ✂ into a 9-pt slot in a flow whose glyph
    /// overlaps its neighbours — which is exactly "couldn't be placed at the
    /// end".
    ///
    /// The three pure brains §4.4 named are all sound and pinned
    /// (`CutFlowEndSlotTests`): the end is legal, it is laid inside the
    /// flow, and a point right of the last token resolves to it. The fault
    /// was one level up, in the gesture wiring, as the plan predicted it
    /// would be if those three passed.
    /// **THE FIX, and why it is a key MONITOR rather than a focus re-arm.**
    /// Three focus roads were tried on the dev-store build and all three
    /// stayed deaf: assigning `keyboardFocused = true` (a no-op — `@FocusState`
    /// publishes edges), bouncing it false→true in the same turn, and bouncing
    /// it a runloop turn later; `.focusable(false)` on the controls did not
    /// stop them taking first responder either. SwiftUI would not hand the
    /// container's focus back while an AppKit control inside a `ScrollView`
    /// held it.
    ///
    /// So the placement keys stop depending on focus at all. The monitor is
    /// installed only while THIS sheet is on screen (it is window-modal, so
    /// that is exactly its scope), acts only on the four placement chords,
    /// and returns every other event untouched — nothing else in the app can
    /// see a difference. `.onKeyPress` stays on the container as the ordinary
    /// road; the monitor is what makes it survive her first click.
    private func installKeyMonitor() {
        guard keyMonitor == nil else { return }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard ceremony.state != nil else { return event }
            return handleKeyEvent(event) ? nil : event
        }
    }

    private func removeKeyMonitor() {
        if let keyMonitor { NSEvent.removeMonitor(keyMonitor) }
        keyMonitor = nil
    }

    /// True = handled (the event is swallowed). Reads the same brains the
    /// `.onKeyPress` road does, so the two cannot answer differently.
    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        switch event.keyCode {
        case 48:  // ⇥
            return stepTake(forward: !event.modifierFlags.contains(.shift))
        case 123:  // ←
            return stepCut(forward: false, bySentence: event.modifierFlags.contains(.option))
        case 124:  // →
            return stepCut(forward: true, bySentence: event.modifierFlags.contains(.option))
        default:
            return false
        }
    }

    // MARK: - The arrangement row (U-5)

    private var arrangementRow: some View {
        HStack(spacing: 8) {
            ForEach(DivideWCeremony.Arrangement.allCases) { option in
                VoicedChip(
                    tokens: tokens, text: option.title,
                    on: state.arrangement == option
                ) {
                    ceremony.setArrangement(option)
                    activeTakeID = state.activeVariantID
                }
                // ROW 3: the sheet's placement keys live on the container's
                // focus, and a control that TAKES first responder on click
                // silently ends them. These act; they never need focus.
                .focusable(false)
                .help(option == .perTake
                    ? "Check the takes to cut and place each \u{2702} yourself"
                    : DivideWCeremony.arrangementSentence(
                        option, others: state.otherTakes.count,
                        unparkable: state.unparkableTakes.count))
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: - Rows

    @ViewBuilder
    private func takeRow(_ take: DivideWCeremony.WTake) -> some View {
        let header = HStack(spacing: 6) {
            if take.marked, take.id == activeTakeID, state.arrangement == .perTake {
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
        VStack(alignment: .leading, spacing: 4) {
            // U-5 / mockup A's caption: **the checkbox appears only in
            // "Choose per take"** — under a preset the arrangement is the
            // choice, and a checkbox there would offer a second, conflicting
            // one.
            if state.arrangement == .perTake {
                Toggle(isOn: Binding(
                    get: { take.marked },
                    set: { _ in
                        ceremony.toggleTake(take.id)
                        if activeTakeID == take.id { activeTakeID = nil }
                    })
                ) { header }
                // ROW 3, the same rule as the chips: the checkbox acts, and
                // taking first responder from the sheet is all it did besides.
                .focusable(false)
            } else {
                header
            }

            if let note = DivideWCeremony.presetRowNote(
                state.arrangement,
                isSeed: take.id == state.activeVariantID,
                isEmpty: take.variant.workingText.isEmpty) {
                Text(note)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if take.marked, take.cut != nil || state.arrangement == .perTake {
                if take.boundaries.isEmpty {
                    Text("This take is empty — there's no cut to place. Uncheck it (it stays on the original block).")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .lineLimit(2)
                } else {
                    // Mockup A's own rule: under a PRESET the columns only
                    // SHOW what will happen — the hand-placement surface is
                    // what "Choose per take…" turns them into. The SEED take
                    // stays placeable on every road: its ✂ is the gesture's
                    // and hers to adjust, and every preset splits exactly
                    // there.
                    WCutFlow(
                        take: take,
                        tokens: tokens,
                        placeable: state.arrangement == .perTake
                            || take.id == state.activeVariantID,
                        place: { placeCut(takeID: take.id, cut: $0) })
                    // Under a PRESET the row's own note already said where
                    // this take goes; the placement note is the hand-placed
                    // sheet's voice and would say it a second time.
                    if state.arrangement == .perTake || take.id == state.activeVariantID {
                        placementNote(take)
                    }
                }
            } else {
                // 13f W10a: the per-row caption names the destination too —
                // it is where she was actually looking when she asked. Under a
                // PRESET the destination is the preset's, not "the original
                // block", so `presetRowNote` above has already said it.
                if state.arrangement == .perTake {
                    Text(DivideWCeremony.uncheckedRowNote)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
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
            //
            // U-5: only under "Choose per take". A preset OWNS every mark, so
            // a row click there would silently contradict the row of four.
            guard state.arrangement == .perTake else { return }
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
        switch press.key {
        case .tab:
            return stepTake(forward: !press.modifiers.contains(.shift))
                ? .handled : .ignored
        case .leftArrow, .rightArrow:
            return stepCut(
                forward: press.key == .rightArrow,
                bySentence: press.modifiers.contains(.option)) ? .handled : .ignored
        default:
            return .ignored
        }
    }

    /// Under a PRESET only the seed take's ✂ is hers to move (mockup A: the
    /// other columns only show), so the arrow keys aim there and ⇥ — which
    /// exists to walk between hand-placed takes — has nothing to walk.
    private var aimableTakeIDs: [String] {
        state.arrangement == .perTake
            ? state.takes.filter { $0.marked }.map(\.id)
            : [state.activeVariantID].compactMap { $0 }
    }

    @discardableResult
    private func stepTake(forward: Bool) -> Bool {
        guard state.arrangement == .perTake,
              let next = WCutPlacement.nextTake(
                after: activeTakeID, in: aimableTakeIDs, forward: forward)
        else { return false }
        activeTakeID = next
        return true
    }

    @discardableResult
    private func stepCut(forward: Bool, bySentence: Bool) -> Bool {
        let ids = aimableTakeIDs
        // The active take, or the first checked one if none is active.
        guard let takeID = (activeTakeID.flatMap { ids.contains($0) ? $0 : nil }) ?? ids.first,
              let take = state.takes.first(where: { $0.id == takeID }),
              !take.boundaries.isEmpty
        else { return false }
        let next = bySentence
            ? WCutPlacement.sentenceStep(
                from: take.cut, strong: take.strongBoundaries,
                boundaries: take.boundaries, forward: forward)
            : WCutPlacement.wordStep(
                from: take.cut, boundaries: take.boundaries, forward: forward)
        if let next, next != take.cut {
            placeCut(takeID: takeID, cut: next)
        } else {
            activeTakeID = takeID
        }
        return true
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
    /// False = SHOW-ONLY (mockup A: under a preset the columns show what
    /// will happen; the drag is not attached at all, so there is no
    /// affordance that looks live and isn't).
    var placeable = true
    let place: (Int) -> Void

    @State private var geometry = CutFlowGeometry()
    @State private var width: CGFloat = 0

    private static let flowFont = NSFont.preferredFont(forTextStyle: .callout)

    var body: some View {
        Canvas(opaque: false) { context, _ in
            for token in geometry.tokens {
                context.draw(
                    Text(token.text).font(.callout).foregroundStyle(tokens.ink),
                    at: CGPoint(x: token.frame.minX, y: token.frame.midY),
                    anchor: .leading)
            }
            // 13f W9 — HER RULING (2026-07-30): *"I also think we don't need
            // all those lines to show where you can cut - I feel like it's
            // pretty clear that it only jumps to in between words."* The tick
            // mark at every legal cut position is gone, and the hover
            // highlight with it (it was one of those lines, thickened).
            //
            // RENDERING ONLY. The slots still exist in the geometry and still
            // do all their work: `slotWidth` is what puts the gap between two
            // words (so the flow's wrap arithmetic and every cached layout are
            // byte-unchanged), `nearestSlot` still resolves clicks and drags
            // against the same frames, `isStrong` still gives sentence ends and
            // newlines their extra catch, and `slotFrame(for:)` still places
            // the ✂. Snap rule, keyboard steps, parking and checkbox semantics
            // are all untouched — their pins run unmodified.
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
        // 13f W9: `onContinuousHover` went with the ticks — its ONLY consumer
        // was the hovered tick's highlight, and a hover tracker that changes
        // nothing on screen is state churn per mouse move (13d judgment call
        // 1's dead-code class). Clicking and dragging are unaffected: both
        // resolve through `nearestSlot` on the gesture below, which never read
        // the hover.
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { drag in
                    guard placeable,
                          let nearest = geometry.nearestSlot(to: drag.location),
                          nearest != take.cut else { return }
                    place(nearest)
                },
            including: placeable ? .all : .subviews)
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
