//
//  MobileTimingView.swift
//  VariorumMobile
//
//  VM-65 (the VM-64 run, batch 1) — THE TIMING READOUT. Settings ▸ Diagnostics ▸
//  Timing… (PROVISIONAL P-65-1: beside the edit trace, the precedent for a
//  diagnostic shipped in Release; the alternative recorded in the run's §7).
//  Per span: how many runs, the median, the range, the last — then the per-act
//  counts and the raw totals. THIS build's table first, then the PREVIOUS
//  build's under it when one is kept (the author's sharpening: the before and
//  after read on the phone itself), each headed by its build and the day it
//  began collecting. Copy puts exactly what is on screen on the clipboard as
//  plain text (`TimingReport`, Core), both tables, so she can paste it to a
//  session. Reset clears THIS build's table only (PROVISIONAL P-65-4).
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
        (.savepointsPerLeaving, "Commits per leaving"),
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
        (.savepointAttempt, "Commit tries"),
        (.noteLeaving, "Notes left"),
        (.appLeaving, "App left"),
    ]

    static let thisBuild = "This build"                           // DRAFT
    static let previousBuild = "Previous build"                   // DRAFT

    /// One build's table, from wherever it is read: the live record (this
    /// build) or the kept file (the previous build).
    struct Table {
        var label: String
        var since: Date?
        var stats: (AppTimingSeries) -> TimingStats?
        var counter: (AppTimingCounter) -> Int
        var restarts: Int
        var abandoned: Int
        var unmatchedEnds: Int
    }

    static func table(
        _ snap: TimingSnapshot<AppTimingSeries, AppTimingCounter>, label: String
    ) -> Table {
        Table(
            label: label, since: snap.since, stats: { snap.stats($0) }, counter: { snap.counter($0) },
            restarts: snap.restarts, abandoned: snap.abandoned, unmatchedEnds: snap.unmatchedEnds)
    }

    static func table(_ archive: TimingArchive) -> Table {
        Table(
            label: archive.label ?? archive.build, since: archive.since,
            stats: { archive.series[$0.rawValue] }, counter: { archive.counters[$0.rawValue] ?? 0 },
            restarts: archive.restarts, abandoned: archive.abandoned,
            unmatchedEnds: archive.unmatchedEnds)
    }

    /// The whole readout as plain text — the screen shows it, Copy copies it:
    /// this build's table, then the previous build's when one is kept, each
    /// headed by its build and the day it began collecting.
    static func report(current: Table, previous: Table?) -> String {
        var out = block(current, heading: thisBuild)
        if let previous { out += "\n\n" + block(previous, heading: previousBuild) }
        return out
    }

    private static func block(_ table: Table, heading: String) -> String {
        var sections = spans.map { section in
            TimingReport.Section(
                section.heading,
                lines: section.rows.map { .init($0.1, table.stats($0.0), unit: .milliseconds) })
        }
        sections.append(TimingReport.Section(
            "Counts",                                             // DRAFT
            lines: counts.map { .init($0.1, table.stats($0.0), unit: .count) }))
        sections.append(TimingReport.Section(
            "Totals",                                             // DRAFT
            totals: totals.map { .init($0.1, table.counter($0.0)) }))
        let since = table.since.map {
            "collecting since " + $0.formatted(date: .abbreviated, time: .omitted)  // DRAFT
        } ?? "nothing collected yet"                              // DRAFT
        return TimingReport.text(
            // The words as drafted, never forced into capitals (her sentence-case
            // rule; VM-64 ladder round 2, finding 9) — the wording pass is hers.
            title: "\(title) — \(heading)",
            header: [
                table.label,
                since,
                "n = runs; median and range over the last \(TimingStats.defaultCapacity); ms",  // DRAFT
            ],
            sections: sections,
            footer: [
                "Restarted before they ended: \(table.restarts)",  // DRAFT
                "Ended too late to count: \(table.abandoned)",     // DRAFT
                "Ended with no start: \(table.unmatchedEnds)",     // DRAFT
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
        let previous = MobileTiming.previousBuild
        anything = !snap.series.isEmpty || !snap.counters.isEmpty || previous != nil
        text = MobileTimingCopy.report(
            current: MobileTimingCopy.table(snap, label: MobileTiming.build.label),
            previous: previous.map(MobileTimingCopy.table))
    }
}
