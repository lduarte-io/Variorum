//
//  CommitsCompareView.swift
//  Variorum (Mac)
//
//  **VX-801 (VX-827 U3a) — COMPARE** (THE DESIGN MEMO): side by side, from
//  any moment's Compare act — two boxes (the picked moment · now; an AI's
//  edit sets before · after), EACH box's header a swapper that re-aims it at
//  any take's moment, and "now" always offerable as a standing third box
//  (her *"i think being able to open 3 commits would be helpful (before
//  claude, after claude, now)… or maybe instead of a third commit, always
//  being able to show 'now' as the third compare box option"*). The changed
//  words are washed in her reference's language: the first box struck where
//  its words left, every later box washed where its words arrived.
//
//  Read-only, like the face: every box is a `Text` (P3). The acts live on the
//  face's pane — Compare is for reading (PROVISIONAL, P-U3a-5).
//

import SwiftUI
import VariorumCore

struct CommitsCompareView: View {
    let model: CommitsFaceModel
    let tokens: VoiceTokens

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Button(tokens.chromeLabel(CommitsFaceCopy.backToHistory)) { model.closeCompare() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                Spacer(minLength: 0)
                if model.canAddNow {
                    Button(tokens.chromeLabel(CommitsFaceCopy.addNow)) { model.addNowBox() }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                        .help(CommitsFaceCopy.addNowHelp)
                }
            }
            HStack(alignment: .top, spacing: 10) {
                ForEach(Array((model.compareBoxes ?? []).enumerated()), id: \.offset) { index, moment in
                    box(index, moment)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }

    private func box(_ index: Int, _ moment: CommitRail.Moment) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                // The box's swapper — any moment of any take of this block.
                VoicedMenu(tokens: tokens, label: model.menuLine(moment), role: .quiet) {
                    ForEach(model.swapperGroups, id: \.takeID) { group in
                        Section(model.takeTitle(group.takeID)) {
                            ForEach(group.moments, id: \.self) { candidate in
                                Button(model.menuLine(candidate)) {
                                    model.reaim(box: index, to: candidate)
                                }
                            }
                        }
                    }
                }
                .lineLimit(1)
                Spacer(minLength: 4)
                if (model.compareBoxes?.count ?? 0) > 2 {
                    Button(tokens.chromeLabel(CommitsFaceCopy.removeBox)) { model.removeBox(index) }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                        .help(CommitsFaceCopy.removeBoxHelp)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            Text(tokens.chromeLabel(model.meta(moment).joined(separator: " \u{B7} ")))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.bottom, 8)
            Divider().overlay(tokens.line)
            ScrollView {
                Text(CommitsFaceText.attributed(
                    runs: model.boxRuns(index), tokens: tokens,
                    empty: (model.text(of: moment) ?? "").isEmpty))
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .textSelection(.enabled)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
        }
        .background(tokens.surface, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(tokens.line, lineWidth: 1))
    }
}
