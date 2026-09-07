//
//  MergeCeremonySheet.swift
//  Variorum
//
//  The merge ceremony as ONE sheet (13b Stage 4, Batch 4B — the RULED
//  merge addendum, S4-23: the W's mirror). Left block's takes | right
//  block's takes; ＋ pairings placed by hand (click a take on each side —
//  the ＋ lands between them); each pairing previews its JOINED text under
//  the three-way join control (space · newline · nothing; default = the
//  canon rule or the session's last confirmed choice); unpaired takes may
//  CARRY whole; everything else stays with the released blocks in lineage
//  — today's rule, now visible and chosen instead of silent. The sheet
//  opens PRE-PAIRED with the two rendered takes, so ⏎ reproduces the
//  instant merge's exact outcome when no session join memory is set (a
//  fresh session); a remembered join seeds the pre-pair instead —
//  ruling 3's letter. Cancel touches nothing;
//  the live editor is untouched for the ceremony's whole duration. The
//  sheet is ordinary SwiftUI — never the live TK2 editor.
//
//  **18f batch 2 — THE FACE, to mockup figure B** (the 2026-09-06 use-report
//  round). Figure B's own note: *"Only the header, the name, the arrangement
//  row and the door are new; 'Pair by hand' is the shipped pairing ceremony
//  (S4-23) restyled onto this surface."* So this sheet now wears the divide
//  sheet's exact chrome (`CeremonySheetChrome`) — one family, one grammar —
//  and its columns read as cards of prose instead of button rows. Under a
//  PRESET the columns SHOW what will happen (figure A's rule, applied here);
//  under "Pair by hand…" they are the shipped hand-placement surface, whose
//  behaviour is byte-unchanged. Over a RUN of three or more (her U-16) the
//  columns become one list of the run's blocks with their shown takes marked.
//

import SwiftUI
import VariorumCore

struct MergeCeremonySheet: View {
    let model: EditorViewModel
    /// The presentation snapshot (`.sheet(item:)` captures the value once);
    /// rendering always prefers the LIVE ceremony state on the observable
    /// model, so pairings, carries, and joins re-render.
    let presented: EditorViewModel.MergeCeremonyState

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    /// The click-to-pair selection, one per column: selecting a take on
    /// each side places the ＋ between them.
    @State private var selectedFirst: String?
    @State private var selectedSecond: String?

    private var state: EditorViewModel.MergeCeremonyState {
        model.mergeCeremony ?? presented
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// The prose face the take cards read in — the voice's own body font,
    /// through the one resolution every text surface in the app reads.
    private var proseFont: Font {
        tokens.body
    }

    private var blocks: Int { max(2, state.blockIDs.count) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            CeremonySheetHeader(
                tokens: tokens, title: "Merge choosing takes",
                facts: facts, help: helpLines)

            // **THE ARRANGEMENT ROW** (her U-5's merge half; U-16 whole): the
            // FIRST control, in the divide sheet's own grammar — three options
            // for a pair, TWO for a run of three or more, and the pairing
            // surface only behind "Pair by hand…". Batch 1 gave it its brains
            // and its words; this is the mockup's face over them.
            arrangementRow

            Text(state.arrangementSentence)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)

            if state.arrangement == .pairByHand {
                pairingBody
            } else if state.isRun {
                runList
            } else {
                previewColumns
            }

            CeremonySheetFooter(
                tokens: tokens,
                blocker: state.confirmBlocker,
                restingLine: CeremonyCardCopy.mergeRestingLine(blocks: blocks),
                confirmTitle: "Merge",
                canConfirm: state.canConfirm,
                cancel: { model.cancelMergeCeremony() },
                confirm: { model.confirmMerge() })
        }
        .padding(20)
        .background(tokens.room)
        // The columns need the width, and the sheet sizes to the window —
        // the divide sheet's own measure, one family (§5.2).
        .frame(
            minWidth: 900, idealWidth: 1000, maxWidth: 1400,
            minHeight: 460, idealHeight: 600, maxHeight: 900)
    }

    /// The header's quiet facts line: how many blocks, and how many takes are
    /// in play beyond the shown ones.
    private var facts: [String] {
        var parts = [blocks == 2 ? "2 blocks" : "\(blocks) blocks"]
        if state.isRun {
            parts.append(state.otherTakes == 1
                ? "1 take beyond the shown ones"
                : "\(state.otherTakes) takes beyond the shown ones")
        } else {
            parts.append("\(state.firstTakes.count) + \(state.secondTakes.count) takes")
        }
        return parts
    }

    /// The explainer, FOLDED (§5.2) — the pairing vocabulary the sheet used to
    /// stack above its columns.
    private var helpLines: [String] {
        [
            "A **＋** pairs one take from each block into a joined take on the "
                + "merged block (click a take on each side to place it). "
                + "**Carry** rides a take over whole, unjoined. Anything unpaired "
                + "and uncarried stays with the released blocks in lineage — "
                + "\u{2325}\u{2318}Z undoes the whole merge.",
            "**Keyboard** — \u{23CE} Merge · \u{238B} Cancel.",
        ]
    }

    // MARK: - The arrangement row (U-5 · U-16)

    private var arrangementRow: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: 8, alignment: .top),
                count: state.offeredArrangements.count),
            alignment: .leading, spacing: 8
        ) {
            ForEach(state.offeredArrangements) { option in
                ArrangementOptionCard(
                    tokens: tokens,
                    title: option.title(blocks: blocks),
                    detail: option.detail(blocks: blocks),
                    selected: state.arrangement == option,
                    deliberate: option == .pairByHand
                ) {
                    model.setMergeArrangement(option)
                }
                .help(MergeArrangementCopy.sentence(
                    option, blocks: blocks, otherTakes: state.otherTakes,
                    join: state.canonJoin))
            }
        }
    }

    // MARK: - Under a PRESET: the columns SHOW what will happen

    /// Mockup figure B: the two blocks' takes side by side, the shown ones
    /// marked as the pair that joins and the rest as what comes along (or
    /// what stays behind). Nothing here is placeable — the row of three made
    /// the choice, and a live-looking control beside it would offer a second.
    private var previewColumns: some View {
        ScrollView(.vertical) {
            HStack(alignment: .top, spacing: 14) {
                previewColumn(
                    title: "First block", takes: state.firstTakes,
                    shownID: state.firstRenderedID, marker: "\u{FF0B} pairs with \u{2192}")
                previewColumn(
                    title: "Second block", takes: state.secondTakes,
                    shownID: state.secondRenderedID, marker: "\u{2190} \u{FF0B}")
            }
            .padding(.vertical, 1)
        }
        .frame(minHeight: 240, maxHeight: 460)
    }

    private func previewColumn(
        title: String, takes: [EditorViewModel.MergeTake],
        shownID: String?, marker: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(tokens.chromeLabel(title))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
            ForEach(Array(takes.enumerated()), id: \.element.id) { i, take in
                MergeTakeCard(
                    tokens: tokens, font: proseFont,
                    name: takeName(take.variant, ordinal: i + 1),
                    role: take.id == shownID
                        ? marker
                        : (state.arrangement == .bringEveryTake
                            ? "carried whole" : "stays in lineage"),
                    roleIsAccent: take.id == shownID,
                    shown: take.id == shownID,
                    locked: take.variant.locked,
                    text: take.variant.workingText,
                    dimmed: take.id != shownID && state.arrangement == .onlyTheShownOnes)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Over a RUN (U-16): one list of the run's blocks

    /// Figure B's amendment, in her words at the approval: over a run of three
    /// or more *"the columns become one list of the run's blocks with their
    /// shown takes marked"* — and never the pairing surface.
    private var runList: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(state.runBlocks.enumerated()), id: \.element.blockID) { i, block in
                    MergeTakeCard(
                        tokens: tokens, font: proseFont,
                        name: "block \(i + 1) of \(state.runBlocks.count)",
                        role: block.takeCount == 1
                            ? "1 take"
                            : (state.arrangement == .bringEveryTake
                                ? "\(block.takeCount) takes — all coming along"
                                : "\(block.takeCount) takes — only this one comes"),
                        roleIsAccent: false,
                        // No "shown here" badge in the run list: every row IS
                        // the block's shown take, so the badge would say the
                        // same thing three times (walked, 18f batch 2).
                        shown: false,
                        locked: false,
                        text: block.shownText,
                        dimmed: false)
                }
            }
            .padding(.vertical, 1)
        }
        .frame(minHeight: 240, maxHeight: 460)
    }

    // MARK: - The hand-placed sheet (S4-23, behaviour byte-unchanged)

    private var pairingBody: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 10) {
                if !state.pairings.isEmpty {
                    Text(tokens.chromeLabel("Pairings"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                    ForEach(state.pairings) { pairing in
                        pairingRow(pairing)
                    }
                }
                HStack(alignment: .top, spacing: 14) {
                    takeColumn(
                        title: "First block's takes",
                        takes: state.unpairedFirst,
                        selected: selectedFirst,
                        select: { selectFirst($0) })
                    takeColumn(
                        title: "Second block's takes",
                        takes: state.unpairedSecond,
                        selected: selectedSecond,
                        select: { selectSecond($0) })
                }
                if state.stayBehindCount > 0 {
                    Text(state.stayBehindCount == 1
                        ? "1 unpaired take will stay with its released block in lineage (\(TrayPath.originalsPath))."
                        : "\(state.stayBehindCount) unpaired takes will stay with their released blocks in lineage (\(TrayPath.originalsPath)).")
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, 1)
        }
        .frame(minHeight: 260, maxHeight: 460)
    }

    // MARK: - Pairing rows

    @ViewBuilder
    private func pairingRow(_ pairing: EditorViewModel.MergePairingDraft) -> some View {
        let head = state.take(pairing.firstVariantID)?.variant
        let tail = state.take(pairing.secondVariantID)?.variant
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 7) {
                Text(takeName(head))
                    .font(tokens.small)
                    .fontWeight(.semibold)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Text("\u{FF0B}")
                    .font(tokens.small)
                    .fontWeight(.semibold)
                    .foregroundStyle(tokens.accent)
                Text(takeName(tail))
                    .font(tokens.small)
                    .fontWeight(.semibold)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Picker("Join", selection: Binding(
                    get: { pairing.join },
                    set: { model.setMergeJoin(pairingID: pairing.id, join: $0) })
                ) {
                    Text("space").tag(MergeJoin.space)
                    Text("new line").tag(MergeJoin.newline)
                    Text("nothing").tag(MergeJoin.nothing)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .fixedSize()
                Button {
                    model.removeMergePairing(pairing.id)
                } label: {
                    Image(systemName: "xmark.circle")
                        .foregroundStyle(tokens.muted)
                }
                .buttonStyle(.plain)
                .help("Remove this pairing — both takes return to their columns")
            }
            if let head, let tail {
                // The JOIN, previewed — the same brain the operation uses
                // (MergeJoin), so the preview can never lie by a byte.
                Text(pairing.join.joined(head.workingText, tail.workingText))
                    .font(proseFont)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tokens.card, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(tokens.accent.opacity(0.4), lineWidth: 1))
    }

    // MARK: - Take columns (the hand-placement surface)

    @ViewBuilder
    private func takeColumn(
        title: String, takes: [EditorViewModel.MergeTake],
        selected: String?, select: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(tokens.chromeLabel(title))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
            if takes.isEmpty {
                Text("Every take here is paired.")
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(2)
            }
            ForEach(Array(takes.enumerated()), id: \.element.id) { i, take in
                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        select(take.id)
                    } label: {
                        MergeTakeCard(
                            tokens: tokens, font: proseFont,
                            name: takeName(take.variant, ordinal: i + 1),
                            role: selected == take.id
                                ? "picked — choose one on the other side"
                                : (take.carried ? "carried whole" : "click to pair"),
                            roleIsAccent: selected == take.id,
                            shown: selected == take.id,
                            locked: take.variant.locked,
                            text: take.variant.workingText,
                            dimmed: false,
                            selected: selected == take.id) {
                                Toggle(isOn: Binding(
                                    get: { take.carried },
                                    set: { _ in model.toggleMergeCarry(take.id) })
                                ) {
                                    Text("carry whole").font(tokens.small)
                                }
                                .toggleStyle(.checkbox)
                                .focusable(false)
                                .help("This take rides onto the merged block as its own take, unjoined")
                            }
                    }
                    .buttonStyle(.plain)
                    .focusable(false)
                    .help("Click to pair — select a take on the other side and the ＋ lands between them")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Selection → pairing

    private func selectFirst(_ id: String) {
        if let second = selectedSecond {
            model.pairMergeTakes(firstID: id, secondID: second)
            selectedFirst = nil
            selectedSecond = nil
        } else {
            selectedFirst = selectedFirst == id ? nil : id
        }
    }

    private func selectSecond(_ id: String) {
        if let first = selectedFirst {
            model.pairMergeTakes(firstID: first, secondID: id)
            selectedFirst = nil
            selectedSecond = nil
        } else {
            selectedSecond = selectedSecond == id ? nil : id
        }
    }

    private func takeName(_ take: Variant?) -> String {
        guard let take else { return "a take" }
        if let label = take.label, !label.isEmpty { return "\u{201C}\(label)\u{201D}" }
        let preview = take.workingText.prefix(24)
        return preview.isEmpty ? "an empty take" : "\u{201C}\(preview)…\u{201D}"
    }

    /// The card's name: the take's own label, else its place in its block's
    /// fan — the divide card's grammar, one family.
    private func takeName(_ take: Variant, ordinal: Int) -> String {
        if let label = take.label, !label.isEmpty { return label }
        return ordinal <= 1 ? "take" : "take \(ordinal)"
    }
}

// MARK: - The merge sheet's take card

/// One take on the merge sheet: its name and role, then its text as prose in
/// the voice's body face (the mockup's `.mini-take`). Optional trailing
/// content is the hand-placement surface's "carry whole" checkbox.
struct MergeTakeCard<Trailing: View>: View {
    let tokens: VoiceTokens
    let font: Font
    let name: String
    let role: String
    var roleIsAccent = false
    var shown = false
    var locked = false
    let text: String
    var dimmed = false
    var selected = false
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 7) {
                Text(tokens.chromeLabel(name))
                    .font(tokens.small)
                    .fontWeight(.semibold)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                CeremonyBadge(
                    tokens: tokens, text: role,
                    tint: roleIsAccent ? tokens.accent : nil)
                if shown {
                    CeremonyBadge(tokens: tokens, text: "shown here", tint: tokens.accent)
                }
                if locked {
                    CeremonyBadge(tokens: tokens, text: "locked")
                }
                Spacer(minLength: 0)
            }
            Text(text.isEmpty ? "an empty take" : text)
                .font(font)
                .foregroundStyle(tokens.ink)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            trailing()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tokens.card, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(selected ? tokens.accent : tokens.line,
                        lineWidth: selected ? 1.5 : 1))
        .opacity(dimmed ? 0.62 : 1)
        .contentShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension MergeTakeCard where Trailing == EmptyView {
    init(
        tokens: VoiceTokens, font: Font, name: String, role: String,
        roleIsAccent: Bool = false, shown: Bool = false, locked: Bool = false,
        text: String, dimmed: Bool = false, selected: Bool = false
    ) {
        self.init(
            tokens: tokens, font: font, name: name, role: role,
            roleIsAccent: roleIsAccent, shown: shown, locked: locked,
            text: text, dimmed: dimmed, selected: selected, trailing: { EmptyView() })
    }
}
