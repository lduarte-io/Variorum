//
//  ProtectionExplainerView.swift
//  Variorum (shared: Mac + Mobile)
//
//  pre-13u Act 10 wave 2a — seventh wave (iii), her ask verbatim: "maybe
//  the encryptions settings in settings should have an encryption
//  explainer tab … settings should also carry a better explanation and
//  point someone towards the tutorial." This view RENDERS the memo brain
//  (`ProtectionShapes`) — recipes + short paragraphs, the three-row
//  shapes summary as the ONLY table-shaped thing, the four what-you-need
//  states, and the keystone lines verbatim. It re-derives NOTHING (§9c
//  item 3); a sentence changes in the brain or not at all.
//
//  Plain system styling on purpose: it mounts in the Mac's Settings
//  window today and stays phone-legible for mobile's own chrome at its
//  resumption (the parity note names it).
//

import SwiftUI

struct ProtectionExplainerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // The one law leads — everything else derives from it.
                Text(ProtectionShapes.oneLaw)
                    .font(.callout.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
                Text(ProtectionShapes.deviceAsPowerfulAsPassphrase)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                group(ProtectionShapes.openRecipesTitle) {
                    bullets(ProtectionShapes.openRecipes)
                    Text(ProtectionShapes.spareKeyIsAKey)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                group(ProtectionShapes.opensNothingAloneTitle) {
                    bullets(ProtectionShapes.opensNothingAlone)
                }

                group("A new device — two different things") {
                    bullets([
                        ProtectionShapes.newDeviceAdoptCopy,
                        ProtectionShapes.newDeviceSyncEnroll,
                    ])
                    Text(ProtectionShapes.resetRoad)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(ProtectionShapes.syncSentence)
                        .font(.caption.weight(.medium))
                        .fixedSize(horizontal: false, vertical: true)
                }

                group("The two shapes (and the one that isn't)") {
                    ForEach(ProtectionShapes.shapes, id: \.name) { shape in
                        shapeCard(shape)
                    }
                }

                group("What YOU need, by mode") {
                    ForEach(ProtectionShapes.needStates, id: \.name) { state in
                        VStack(alignment: .leading, spacing: 3) {
                            Text(state.name).font(.caption.weight(.semibold))
                            Text("Day to day: \(state.daily)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Computer dies: \(state.computerDies)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(state.floor)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.bottom, 4)
                    }
                    Text(ProtectionShapes.demandedFallbackTruth)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(ProtectionShapes.compoundWarning)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Settings explains AND points (seventh wave (iii)); the
                // deep, do-it-here teaching is the field guide's.
                Text("The field guide teaches all of this in place — the "
                     + "“keeping it private” chapter. Help ▸ Restore Tutorial "
                     + "brings the book back whole if you've cut it up.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func group(
        _ title: String, @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .lineLimit(2)
            content()
        }
    }

    private func bullets(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("·").font(.callout)
                    Text(item)
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func shapeCard(_ shape: ProtectionShapes.ShapeRow) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(shape.name).font(.caption.weight(.semibold))
                if !shape.offered {
                    Text("not offered")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Capsule().fill(.quaternary))
                        .lineLimit(1)
                }
            }
            Text(shape.dials)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if shape.offered {
                Text("Who this protects you from: \(shape.stops)")
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
                Text("What it doesn't stop: \(shape.doesNotStop)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text("What if I forget my passphrase? \(shape.whatIfForget)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text("What if my computer explodes? \(shape.whatIfComputerDies)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.4)))
    }
}
