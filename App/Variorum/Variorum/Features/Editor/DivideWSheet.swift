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
//  **18f batch 2 — THE FACE, rebuilt to mockup figure A** (the 2026-09-06
//  use-report round; her ledger row 5: *"so ugly with the spacing between the
//  words, the way that you have to scroll to get the different takes, just
//  overall"*). The mechanics are batch 1's and are untouched: the arrangement
//  brains, the seeding, the confirm roads, the key monitor's four chords. What
//  changed is everything you look at — the header with its folded `?`, the
//  row of four as option cards, the takes SIDE BY SIDE as prose cards
//  (`ProseTakeCard` over `ProseCutGeometry`, replacing the token flow), and
//  one footer holding the blocker slot and the resting line.
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
/// `rebuilds` is real: the take card's `rebuild()` bumps it in production code
/// (18f batch 2: `ProseTakeCard`, where `WCutFlow` used to), and the F-2 pin
/// uses it to prove a drift refresh re-derives the drawn geometry (the
/// count-preserving staleness class). Batch 2 makes it a STRICTER instrument:
/// the prose layout keys on the take's TEXT, so a token-count-preserving edit
/// rebuilds by construction.
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

    /// The prose face the cards draw in — the VOICE's own body font (SF Mono
    /// for terminal, Iowan Old Style for study), through the one resolution
    /// every text surface in the app reads.
    private var proseFont: NSFont {
        EditorTypography.resolve(
            voice: themeStore?.settings.voice ?? .terminal, inlineComments: false
        ).font
    }

    /// The seed FIRST (§5.2: "the seed first, emphasized by a warmer
    /// border") — the take the gesture was placed in leads the row, and the
    /// others keep their fan order behind it. ⇥ walks this same order, so
    /// what the eye reads and what the key does are one sequence.
    private var displayTakes: [DivideWCeremony.WTake] {
        var takes = state.takes
        guard let seed = state.activeVariantID,
              let i = takes.firstIndex(where: { $0.id == seed }), i != 0
        else { return takes }
        let lead = takes.remove(at: i)
        takes.insert(lead, at: 0)
        return takes
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            CeremonySheetHeader(
                tokens: tokens, title: "Divide choosing takes",
                facts: facts, help: helpLines)

            // **THE ARRANGEMENT ROW** (her ruling U-5, mockup figure A): the
            // FIRST control, four options in the ruled order, "keep on top"
            // selected on open. Batch 1 gave it its brains and its words;
            // this is the mockup's face over them.
            arrangementRow

            Text(DivideWCeremony.arrangementSentence(
                state.arrangement,
                others: state.otherTakes.count,
                unparkable: state.unparkableTakes.count))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)

            takesArea

            CeremonySheetFooter(
                tokens: tokens,
                blocker: state.confirmBlocker,
                restingLine: CeremonyCardCopy.divideRestingLine,
                confirmTitle: "Divide",
                canConfirm: state.canConfirm,
                cancel: { ceremony.cancel() },
                confirm: { Task { await ceremony.confirm() } })
        }
        .padding(20)
        .background(tokens.room)
        // Side by side needs the width, and the sheet sizes to the window
        // (§5.2 — "a large sheet; minWidth ~900").
        .frame(
            minWidth: 900, idealWidth: 1120, maxWidth: 1400,
            minHeight: 520, idealHeight: 660, maxHeight: 900)
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

    /// The header's quiet facts line. *(Mockup figure A opens with "block 4
    /// of 8" — DELIBERATELY not built: this sheet mounts on three surfaces
    /// (Write, the takes board, the lenses board) and only Write knows a
    /// block's position in its note, so the number would either be absent on
    /// two of them or ride a new field on the ceremony's state, which is
    /// mechanics — batch 1's, and closed.)*
    private var facts: [String] {
        [
            state.takes.count == 1 ? "1 take" : "\(state.takes.count) takes",
            state.arrangement == .perTake ? "choosing per take" : "cut where you clicked",
        ]
    }

    /// **The explainers, FOLDED** (§5.2). The shipped sheet stacked both of
    /// these above the takes; they live behind the `?` now, beside the
    /// keyboard legend — which names ONLY the chords the sheet actually
    /// answers (the four the key monitor handles, plus ⏎/⎋).
    private var helpLines: [String] {
        [
            DivideWCeremony.checklistExplainer,
            "**Keyboard** — \u{2190}/\u{2192} step the aimed take's \u{2702} one word · "
                + "\u{2325}\u{2190}/\u{2325}\u{2192} a sentence, a newline, or the ends · "
                + "\u{21E5}/\u{21E7}\u{21E5} aim the next/previous checked take · "
                + "\u{23CE} Divide · \u{238B} Cancel.",
        ]
    }

    // MARK: - The takes, SIDE BY SIDE (§5.2 — never a stack to scroll)

    /// Up to three columns at the sheet's width; a fourth take starts a
    /// second row of the same equal columns, and each card's own prose
    /// scrolls inside it — so the second take is never something you scroll
    /// a stack to find.
    private var takesArea: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
                ForEach(displayTakes) { take in
                    card(take)
                }
            }
            .padding(.vertical, 1)
        }
        .frame(minHeight: 300, maxHeight: 520)
    }

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(minimum: 210), spacing: 14, alignment: .top),
            count: min(3, max(1, state.takes.count)))
    }

    private func card(_ take: DivideWCeremony.WTake) -> some View {
        ProseTakeCard(
            take: take,
            tokens: tokens,
            font: proseFont,
            arrangement: state.arrangement,
            ordinal: (state.takes.firstIndex { $0.id == take.id } ?? 0) + 1,
            isSeed: take.id == state.activeVariantID,
            isAimed: state.arrangement == .perTake && take.marked
                && take.id == activeTakeID,
            // Mockup A's own rule: under a PRESET the columns only SHOW what
            // will happen — the hand-placement surface is what "Choose per
            // take…" turns them into. The SEED take stays placeable on every
            // road: its ✂ is the gesture's and hers to adjust, and every
            // preset splits exactly there.
            placeable: state.arrangement == .perTake
                || take.id == state.activeVariantID,
            // U-5 / mockup A's caption: **the checkbox appears only in
            // "Choose per take"** — under a preset the arrangement is the
            // choice, and a checkbox there would offer a second, conflicting
            // one.
            showsCheckbox: state.arrangement == .perTake,
            toggle: {
                ceremony.toggleTake(take.id)
                if activeTakeID == take.id { activeTakeID = nil }
            },
            place: { placeCut(takeID: take.id, cut: $0) },
            aim: {
                // HER RULING (2026-07-29, selection: "Check it"): clicking an
                // UNCHECKED take's card checks it and aims the arrows there.
                // U-5: only under "Choose per take" — a preset OWNS every
                // mark, so a card click there would silently contradict the
                // row of four.
                guard state.arrangement == .perTake else { return }
                activeTakeID = ceremony.rowTapped(take.id)
            })
        .frame(minHeight: 240)
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

    /// The row of four, in the ruled order, as the mockup's option cards —
    /// each with its title and the one line that says what it does. The
    /// fourth wears a dashed border: her *"the custom selector should be
    /// something you really have to choose to do"*, said in the border.
    private var arrangementRow: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: 8, alignment: .top),
                count: 4),
            alignment: .leading, spacing: 8
        ) {
            ForEach(DivideWCeremony.Arrangement.allCases) { option in
                ArrangementOptionCard(
                    tokens: tokens,
                    title: option.title,
                    detail: option.detail,
                    selected: state.arrangement == option,
                    deliberate: option == .perTake
                ) {
                    ceremony.setArrangement(option)
                    activeTakeID = state.activeVariantID
                }
                .help(option == .perTake
                    ? "Check the takes to cut and place each \u{2702} yourself"
                    : DivideWCeremony.arrangementSentence(
                        option, others: state.otherTakes.count,
                        unparkable: state.unparkableTakes.count))
            }
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
            ? displayTakes.filter { $0.marked }.map(\.id)
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

// MARK: - The retired token flow (18f batch 2)
//
// `WCutFlow` — the take drawn as word tokens with a FIXED 9-pt slot between
// every pair of them — is RETIRED here, and its retirement IS her ledger row
// 5: *"so ugly with the spacing between the words"*. Every legal cut occupied
// real width, so the prose could never read as prose.
//
// What replaces it keeps the whole architecture that flow was rebuilt into at
// L1 and only changes what is laid out: `ProseTakeCard` draws ONE Canvas from
// ONE cached geometry (`ProseCutGeometry`), and the pointer resolves against
// the same frames the drawing uses — through `CutFlowGeometry.nearestSlot`
// itself, so the snapping rule stayed one function with its own pins.
//
// `CutFlowGeometry` therefore survives as the SNAPPING BRAIN: its
// `nearestSlot` runs in production on every click and drag (fed prose-placed
// marks instead of flow slots), and its `make` — the token flow's wrap
// arithmetic — is now read by the pins alone, deliberately kept rather than
// deleted: `CutFlowEndSlotTests` is ledger row 3's evidence that the three
// §4.4 links are SOUND, and evidence is not something a face rebuild gets to
// throw away (the batch-2 brief's own instruction). `WCutPlacement.flowItems`
// keeps being derived per take for the same reason — the drift pin
// (`aDriftRefreshWithTheSameTokenCountRedrawsTheFlow`) reads `WTake.flow` as
// its non-vacuity measure.
