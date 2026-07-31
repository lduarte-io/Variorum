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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Merge blocks — pair their takes").font(.headline)
            Text("A ＋ pairs one take from each block into a joined take on the merged block (click a take on each side to place it). \u{201C}Carry\u{201D} rides a take over whole, unjoined. Anything unpaired and uncarried stays with the released blocks in lineage — ⌥⌘Z undoes the whole merge.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(5)
                .fixedSize(horizontal: false, vertical: true)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if !state.pairings.isEmpty {
                        Text("Pairings").font(.caption).foregroundStyle(.secondary)
                        ForEach(state.pairings) { pairing in
                            pairingRow(pairing)
                        }
                    }
                    HStack(alignment: .top, spacing: 12) {
                        takeColumn(
                            title: "First block's takes",
                            takes: state.unpairedFirst,
                            selected: selectedFirst,
                            select: { selectFirst($0) })
                        Divider()
                        takeColumn(
                            title: "Second block's takes",
                            takes: state.unpairedSecond,
                            selected: selectedSecond,
                            select: { selectSecond($0) })
                    }
                    if state.stayBehindCount > 0 {
                        Text(state.stayBehindCount == 1
                            ? "1 unpaired take will stay with its released block in lineage (\(RecoveryPath.unplacedBlocks))."
                            : "\(state.stayBehindCount) unpaired takes will stay with their released blocks in lineage (\(RecoveryPath.unplacedBlocks)).")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(minHeight: 240, maxHeight: 440)

            if let blocker = state.confirmBlocker {
                Text(blocker)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack {
                Button("Cancel") { model.cancelMergeCeremony() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Merge") { model.confirmMerge() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!state.canConfirm)
            }
        }
        .padding(12)
        .frame(minWidth: 620)
    }

    // MARK: - Pairing rows

    @ViewBuilder
    private func pairingRow(_ pairing: EditorViewModel.MergePairingDraft) -> some View {
        let head = state.take(pairing.firstVariantID)?.variant
        let tail = state.take(pairing.secondVariantID)?.variant
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(takeName(head))
                    .font(.caption)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Text("＋")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(tokens.accent)
                Text(takeName(tail))
                    .font(.caption)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Spacer()
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
                }
                .buttonStyle(.plain)
                .help("Remove this pairing — both takes return to their columns")
            }
            if let head, let tail {
                // The JOIN, previewed — the same brain the operation uses
                // (MergeJoin), so the preview can never lie by a byte.
                Text(pairing.join.joined(head.workingText, tail.workingText))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .padding(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 4).fill(tokens.wash.opacity(0.35)))
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Take columns

    @ViewBuilder
    private func takeColumn(
        title: String, takes: [EditorViewModel.MergeTake],
        selected: String?, select: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            if takes.isEmpty {
                Text("Every take here is paired.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
            }
            ForEach(takes) { take in
                VStack(alignment: .leading, spacing: 2) {
                    Button {
                        select(take.id)
                    } label: {
                        HStack(spacing: 6) {
                            Text(selected == take.id ? "›" : " ")
                                .font(.caption)
                                .foregroundStyle(tokens.accent)
                            Text(take.variant.workingText.isEmpty
                                ? "an empty take" : take.variant.workingText)
                                .font(.caption)
                                .foregroundStyle(tokens.ink)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help("Click to pair — select a take on the other side and the ＋ lands between them")
                    HStack(spacing: 6) {
                        if let label = take.variant.label, !label.isEmpty {
                            Text(label).font(.caption2).foregroundStyle(.tertiary)
                        }
                        if take.variant.locked {
                            Text("locked — merges copy, never edit")
                                .font(.caption2).foregroundStyle(.tertiary)
                        }
                        Toggle(isOn: Binding(
                            get: { take.carried },
                            set: { _ in model.toggleMergeCarry(take.id) })
                        ) {
                            Text("carry whole").font(.caption2)
                        }
                        .toggleStyle(.checkbox)
                        .help("This take rides onto the merged block as its own take, unjoined")
                    }
                    .padding(.leading, 14)
                }
                .padding(.vertical, 2)
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
}
