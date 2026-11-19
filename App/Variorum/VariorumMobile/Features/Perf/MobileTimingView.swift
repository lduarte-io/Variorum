//
//  MobileTimingView.swift
//  VariorumMobile
//
//  VM-65 (the VM-64 run, batch 1) — THE TIMING READOUT. Settings ▸ Diagnostics ▸
//  Timing… (PROVISIONAL P-65-1: beside the edit trace, the precedent for a
//  diagnostic shipped in Release; the alternative recorded in the run's §7).
//  Per span: how many runs, the median, the range, the last — then the per-act
//  counts and the raw totals. Copy puts exactly what is on screen on the
//  clipboard as plain text (`TimingReport`, Core), so she can paste it to a
//  session. Reset forgets the record, in memory and on disk.
//
//  Every label below is DRAFT for her wording pass (the record lists them).
//  The readout shows labels and numbers — never a note's text, title or id.
//

import SwiftUI
import UIKit
import VariorumCore

/// The readout's words. DRAFT, every one — her wording pass is owed.
enum MobileTimingCopy {
    static let door = "Timing…"                                   // DRAFT
    static let title = "Variorum timing"                          // DRAFT
    static let empty = "Nothing measured yet. Use the app, then come back."  // DRAFT
    static let copy = "Copy"
    static let copied = "Copied"
    static let refresh = "Refresh"
    static let reset = "Reset"

    /// The readout's sections, in reading order: what she named first.
    static let spans: [(heading: String, rows: [(AppTimingSeries, String)])] = [
        ("Capture box", [                                         // DRAFT
            (.boxTapToKeyboard, "Tap the box → keyboard up"),
            (.boxFile, "File → box clear"),
            (.boxOpenToNote, "Open → note on screen"),
            (.boxOpenToKeyboard, "Open → keyboard up in the note"),
        ]),
        ("Notes", [                                               // DRAFT
            (.noteOpenToScreen, "Open a note → on screen"),
            (.noteLeave, "Leave a note → saved"),
        ]),
        ("Launch and unlock", [                                   // DRAFT
            (.launchToLockScreen, "Launch → lock screen"),
            (.launchToLibraryOpen, "Launch → library open"),
            (.launchToHome, "Launch → home on screen"),
            (.launchToLibraryReady, "Launch → Library ready"),
            (.unlockToLibraryOpen, "Unlock → library open"),
            (.unlockToHome, "Unlock → home on screen"),
            (.unlockToLibraryReady, "Unlock → Library ready"),
        ]),
        ("Sync", [                                                // DRAFT
            (.ownerAdoption, "Owner check at start"),
            (.syncRound, "Sync round"),
        ]),
    ]

    /// Per-act counts and row counts (plain numbers, not milliseconds).
    static let counts: [(AppTimingSeries, String)] = [            // DRAFT
        (.noteReadsPerOpen, "Note reads per open"),
        (.noteRereadsPerSave, "Note re-reads per save"),
        (.libraryRereadsPerSave, "Library re-reads per save"),
        (.libraryRedrawsPerSave, "Library redraws per save"),
        (.savepointsPerLeaving, "Savepoints per leaving"),
        (.ownerAdoptionRows, "Owner check: rows stamped"),
        (.syncRoundSent, "Sync round: rows sent (about)"),
        (.syncRoundReceived, "Sync round: changes received (about)"),
    ]

    static let totals: [(AppTimingCounter, String)] = [           // DRAFT
        (.noteArrival, "Notes opened"),
        (.editorBuilt, "Editors built"),
        (.noteProjectionLoad, "Note reads at open"),
        (.noteProjectionFetch, "Note reads, live"),
        (.noteProjectionDelivery, "Note redraws, live"),
        (.noteProjectionRefresh, "Note reads at a tab switch"),
        (.libraryFetch, "Library reads"),
        (.libraryDelivery, "Library redraws"),
        (.booklessFetch, "Bookless reads"),
        (.booklessDelivery, "Bookless redraws"),
        (.autosaveWrite, "Saves"),
        (.savepointAttempt, "Savepoint tries"),
        (.noteLeaving, "Notes left"),
        (.appLeaving, "App left"),
    ]

    static var configuration: String {
        #if DEBUG
        return "Debug"
        #else
        return "Release"
        #endif
    }

    /// The whole readout as plain text — the screen shows it, Copy copies it.
    static func report(_ snap: TimingSnapshot<AppTimingSeries, AppTimingCounter>, build: String) -> String {
        var sections = spans.map { section in
            TimingReport.Section(
                section.heading,
                lines: section.rows.map { .init($0.1, snap.stats($0.0), unit: .milliseconds) })
        }
        sections.append(TimingReport.Section(
            "Counts",                                             // DRAFT
            lines: counts.map { .init($0.1, snap.stats($0.0), unit: .count) }))
        sections.append(TimingReport.Section(
            "Totals",                                             // DRAFT
            totals: totals.map { .init($0.1, snap.counter($0.0)) }))
        return TimingReport.text(
            title: title.uppercased(),
            header: [
                "\(configuration) · build \(build.prefix(8))",
                "ms; median and range over the last \(TimingStats.defaultCapacity) runs",  // DRAFT
            ],
            sections: sections,
            footer: [
                "Restarted before they ended: \(snap.restarts)",   // DRAFT
                "Ended too late to count: \(snap.abandoned)",      // DRAFT
                "Ended with no start: \(snap.unmatchedEnds)",      // DRAFT
            ])
    }
}

/// The readout sheet — the edit trace's own shape (`MobileEditTraceView`).
@MainActor
struct MobileTimingView: View {
    let tokens: VoiceTokens
    @Environment(\.dismiss) private var dismiss
    /// Re-read on appearance and on Refresh — the recorder is deliberately not
    /// observable (nothing on a measured road may notify SwiftUI).
    @State private var text = ""
    @State private var anything = false
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(tokens.path(["Settings", "timing"]))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                Spacer()
                Button { dismiss() } label: {
                    Text(tokens.chromeLabel("Done"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if !anything {
                        Text(tokens.chromeLabel(MobileTimingCopy.empty))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                    }
                    Text(text)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(tokens.ink)
                        .textSelection(.enabled)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }

            Divider().overlay(tokens.line)
            HStack(spacing: 18) {
                Button {
                    refresh()
                    UIPasteboard.general.string = text
                    copied = true
                } label: {
                    Text(tokens.chromeLabel(copied ? MobileTimingCopy.copied : MobileTimingCopy.copy))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Copy the timing readout")
                Button {
                    refresh()
                } label: {
                    Text(tokens.chromeLabel(MobileTimingCopy.refresh))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
                Spacer()
                Button {
                    MobileTiming.reset()
                    copied = false
                    refresh()
                } label: {
                    Text(tokens.chromeLabel(MobileTimingCopy.reset))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Reset the timing readout")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .background(tokens.room.ignoresSafeArea())
        .onAppear { refresh() }
    }

    private func refresh() {
        let snap = AppTiming.recorder.snapshot()
        anything = !snap.series.isEmpty || !snap.counters.isEmpty
        text = MobileTimingCopy.report(snap, build: MobileTiming.build)
    }
}
