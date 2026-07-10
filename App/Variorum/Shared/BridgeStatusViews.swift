//
//  BridgeStatusViews.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 9b, Step 5 — the bridge status row (the phase's ONLY UI):
//  last-bridged time, the duplicate-day pause when active, errors.
//  Functional and unstyled (Phase 13 owns beauty). No setup door here —
//  the bridge configures through Phase 9c's sign-in, never a paste-in.
//

import SwiftUI
import VariorumCore

struct BridgeStatusRow: View {
    let bridge: BridgeSession

    var body: some View {
        HStack(spacing: 6) {
            if !bridge.allowsBridge {
                // The A4 fence's bridge seam: dev stores (and the phone,
                // this phase) never bridge.
                Text("Bridge off")
                    .foregroundStyle(.secondary)
            } else if !bridge.isConfigured {
                // Awaiting Phase 9c's sign-in — deliberately no setup door.
                Text("Fragments bridge off (sign-in arrives with 9c)")
                    .foregroundStyle(.secondary)
            } else if bridge.status.isBridging {
                ProgressView().controlSize(.small)
                Text("Bridging…")
            } else if let error = bridge.status.lastError {
                Text("Bridge error")
                    .foregroundStyle(.red)
                    .help(error)
                Button("Retry") { bridge.trigger() }
            } else {
                Text(lastBridgedLabel)
                    .foregroundStyle(.secondary)
                if !bridge.status.pausedDays.isEmpty {
                    // The duplicate-day pause, visibly: these days push
                    // nothing until the author hand-merges.
                    Text("· \(bridge.status.pausedDays.joined(separator: ", ")) paused (two entries — merge to resume)")
                        .foregroundStyle(.orange)
                }
                Button("Bridge now") { bridge.trigger() }
            }
        }
        .font(.caption)
        .padding(6)
    }

    private var lastBridgedLabel: String {
        guard let last = bridge.status.lastSuccessAt else { return "Not bridged yet" }
        return "Bridged \(last.formatted(date: .omitted, time: .shortened))"
    }
}
