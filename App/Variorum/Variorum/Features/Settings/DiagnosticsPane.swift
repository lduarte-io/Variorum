//
//  DiagnosticsPane.swift
//  Variorum (MAC ONLY)
//
//  13r U3-B — Settings ▸ Diagnostics, THE TENTH PANE (the architect's ruling
//  on the in-batch fork, the plan's LIVE STATUS: Option A — between Data
//  Safety and Acknowledgments; the toggle with the privacy story at its
//  head; the received reports under it with the raw JSON ALWAYS VISIBLE).
//
//  The pane holds no rule: it reads the app's ONE crash-reporting owner
//  (`CrashReporting`, on the app delegate — handed down like `appearance`
//  and `updates`) and calls it. Its two acts are declared in the registry
//  (`.sendCrashReport`, `.deleteCrashReport` — the Data Safety precedent)
//  and render their verbs from it.
//
//  VERBATIM means SHOWN BEFORE SEND IS REACHABLE: each report's text sits in
//  a bounded, scrollable, selectable monospaced box on its own card — never
//  behind a disclosure — and Send Report… is rendered only for a report
//  whose bytes were shown as text (`CrashReport.text`). What Send attaches
//  is the same file the box shows.
//

import AppKit
import SwiftUI

struct DiagnosticsPane: View {
    let crashReports: CrashReporting
    /// The roads a draft opens through (injected for the pins; the live
    /// AppKit roads in the app).
    var roads: SupportMailRoads = LiveSupportMailRoads.shared
    /// 19f: where the second road copies the address (a pin passes a
    /// private pasteboard — her clipboard is never a test's).
    var pasteboard: NSPasteboard = .general
    /// 19f: who asks the pre-draft question. Nil = this pane's own `.alert`
    /// (`asking`); a pin passes its own.
    var choose: SupportChooser?
    /// Settings has no status seam of its own, so a draft that could not
    /// open says so here, under the reports (the Data Safety `note` shape).
    @State private var note: String?
    /// 19f: the pane's own channel for the pre-draft question.
    @State private var asking = SupportChoiceAsk()
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    /// P-1: the two acts this surface renders, declared once and walked.
    static let surfaceCapabilities: [CapabilityID] = [.sendCrashReport, .deleteCrashReport]

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        Form {
            Section(DiagnosticsCopy.section) {
                Toggle(SettingsCatalog.title("crashReports"), isOn: Binding(
                    get: { crashReports.isOn },
                    set: { crashReports.set($0) }))
                Text(DiagnosticsCopy.promise)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(10)
                    .fixedSize(horizontal: false, vertical: true)
                Text(DiagnosticsCopy.feedbackPointer)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Section(DiagnosticsCopy.receivedSection) {
                if crashReports.reports.isEmpty {
                    Text(crashReports.isOn ? DiagnosticsCopy.emptyWhileOn : DiagnosticsCopy.emptyWhileOff)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                } else {
                    ForEach(crashReports.reports) { report in
                        CrashReportCard(
                            report: report, tokens: tokens,
                            send: { send(report) },
                            delete: { crashReports.delete(report) })
                    }
                }
                if let note {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .supportChoiceAlert(asking)
        // A report can arrive while Settings is closed; the pane re-reads the
        // folder when it appears.
        .onAppear { crashReports.refresh() }
    }

    /// Send Report…: the support door's draft with this report attached,
    /// opened on screen in a mail app. Nothing is sent here. (Internal, not
    /// private, so a pin can press the door — 19f.)
    func send(_ report: CrashReport) {
        note = nil
        SupportMail.open(
            .crashReport(fileName: report.id, at: report.url, .thisMac()),
            roads: roads) { refusal in note = refusal }
    }
}

/// One received report: its heading (read out of it), when it arrived, the
/// report ITSELF verbatim, and the two doors. Its own view so a pin can read
/// exactly what a card composes.
struct CrashReportCard: View {
    let report: CrashReport
    let tokens: VoiceTokens
    let send: () -> Void
    let delete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(report.heading ?? DiagnosticsCopy.untitled)
                .font(.callout)
                .lineLimit(2)
            Text(DiagnosticsCopy.received(report.receivedAt))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            if let text = report.text {
                // VERBATIM: `Text(verbatim:)` — no Markdown, no localisation,
                // the bytes as text. Bounded so a long report never pushes the
                // pane's other controls away; scrollable and selectable so all
                // of it can be read and copied.
                ScrollView([.vertical, .horizontal]) {
                    Text(verbatim: text)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(tokens.ink)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: true, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(8)
                }
                .frame(height: 180)
                .background(tokens.card, in: RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(tokens.line, lineWidth: 1))
            } else {
                Text(DiagnosticsCopy.notText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 10) {
                // Only what was shown verbatim may leave (P-2: no door that
                // could send what she never saw).
                if report.text != nil {
                    Button(CapabilityRegistry.capability(.sendCrashReport).verb, action: send)
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                }
                Button(CapabilityRegistry.capability(.deleteCrashReport).verb, action: delete)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                Spacer(minLength: 0)
            }
        }
        .padding(.vertical, 4)
    }
}
