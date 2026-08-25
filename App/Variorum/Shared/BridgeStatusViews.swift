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
    /// **The live voice's tokens** (the post-13l polish round, batch 5 —
    /// the architect's routed flag 3: this row's *"Bridge error"* was the last
    /// literal `.red` in a themed surface after batch 4's sweep).
    ///
    /// **Why a parameter and not a modifier.** This file compiles into BOTH
    /// targets, and neither of the two roads batch 4 used reaches here: the
    /// Mac's `.alarmVoice()` lives in `Variorum/Theme/VoiceControls.swift`
    /// (Mac-only — the mobile target would not compile a call to it), and
    /// `\.sharedPageStyle` is **nil on macOS BY CONSTRUCTION** — a pinned
    /// one-seam law, so routing through `pageCaptionError` would have compiled
    /// to the same literal red and dressed a no-op as a fix.
    ///
    /// Defaulted nil, so every existing caller and pin rides byte-unmodified
    /// and the nil arm draws exactly what shipped; the ONE caller (the Mac
    /// sidebar) passes the live voice, and the phone's future bridge face
    /// inherits the seam rather than inventing one.
    var tokens: VoiceTokens?
    /// The auth door for auth-shaped failures (Sitting 9, R94) — the Mac
    /// sidebar passes its account-sheet opener; absent = no door shown.
    var onOpenAccount: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
        HStack(spacing: 6) {
            if !bridge.allowsBridge {
                // The A4 fence's bridge seam: dev stores (and the phone,
                // this phase) never bridge.
                Text("Bridge off")
                    .foregroundStyle(.secondary)
            } else if !bridge.isConfigured {
                // No Fragments session yet (14d wording — the 9b-era
                // "sign-in arrives with 9c" placeholder outlived three
                // phases; her report caught it). The door is the account
                // sheet's Stargazing connect button.
                Text("Journal bridge off")
                    .foregroundStyle(.secondary)
                if let onOpenAccount {
                    Button("Connect…") { onOpenAccount() }
                }
            } else if bridge.status.isBridging {
                ProgressView().controlSize(.small)
                Text("Bridging…")
            } else if bridge.status.lastError != nil {
                Text("Bridge error")
                    .foregroundStyle(tokens?.alarm ?? .red)
                Button("Retry") { bridge.trigger(manual: true) }
                if let onOpenAccount,
                   ErrorPresentation.isAuthShaped(bridge.status.lastError ?? "") {
                    Button("Account…") { onOpenAccount() }
                }
            } else {
                Text(lastBridgedLabel)
                    .foregroundStyle(.secondary)
                if !bridge.status.pausedDays.isEmpty {
                    // The duplicate-day pause, visibly: these days push
                    // nothing until the author hand-merges. Archived
                    // entries still count as the day's entries (archive is
                    // kept-out-of-view, not gone — QUESTIONS #14e), so the
                    // pause releases on delete or re-date, not archive.
                    // The pause is a WARNING, not an error, and warning is a
                    // third signal class she has not ruled on (batch 4's
                    // record). It keeps its literal orange deliberately, with
                    // the reason written here rather than left to be found.
                    Text("· \(bridge.status.pausedDays.joined(separator: ", ")) paused (two entries — delete or re-date one to resume)")
                        .foregroundStyle(.orange)
                }
                if bridge.status.stalled || !bridge.status.issueNotes.isEmpty {
                    // Stalls and per-day push rejections recur silently
                    // otherwise (review round 1, MINOR 4) — surface them;
                    // hover for the verbatim notes.
                    Text("· needs attention (\(max(bridge.status.issueNotes.count, 1)))")
                        .foregroundStyle(.orange)
                        .help(bridge.status.issueNotes.joined(separator: "\n"))
                }
                Button("Bridge now") { bridge.trigger(manual: true) }
            }
        }
        // Sitting 9 (R94): the CAUSE renders inline, never hover-only —
        // "i do think it's bad that there wasn't a more helpful message."
        if let error = bridge.status.lastError, !bridge.status.isBridging {
            ErrorCauseNote(error: error)
        }
        }
        .font(.caption)
        .padding(6)
    }

    private var lastBridgedLabel: String {
        Self.lastBridgedLabel(bridge.status.lastSuccessAt, now: Date())
    }

    /// A STALE BRIDGE MUST NOT LOOK FRESH (13c A2). The time-only form read
    /// as "just now" for a bridge whose last round was DAYS ago — which is
    /// exactly how the author's five-day starvation presented while she was
    /// signed out of the Variorum project (the row said "Bridged 11:04 PM"
    /// the whole time). Past today, the label carries the date, so the row
    /// answers "when did this last refresh?" — the question her report
    /// ("doesn't seem to refresh often enough") was really asking.
    ///
    /// Pure and injected-now so it pins by test; the view re-renders on every
    /// status change, which is when the answer can change.
    static func lastBridgedLabel(
        _ last: Date?, now: Date, calendar: Calendar = .current
    ) -> String {
        guard let last else { return "Not bridged yet" }
        if calendar.isDate(last, inSameDayAs: now) {
            return "Bridged \(last.formatted(date: .omitted, time: .shortened))"
        }
        return "Bridged \(last.formatted(date: .abbreviated, time: .shortened))"
    }
}
