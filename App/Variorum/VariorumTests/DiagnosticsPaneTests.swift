//
//  DiagnosticsPaneTests.swift
//  VariorumTests
//
//  13r U3-B — Settings ▸ Diagnostics, the tenth pane (the architect's ruling,
//  Option A). What these pin, through the composition road
//  (`SurfaceComposition` — the 17f/P47 render pins' tool: a `Text` deleted
//  from the surface fails here, not only a constant changed):
//   · the pane's place (between Data Safety and Acknowledgments), name and
//     symbol, and that Settings search reaches it in her words;
//   · the toggle and the privacy promise at its head; the calm empty line,
//     the right one for OFF and for ON;
//   · a received report's card shows the report's text VERBATIM and offers
//     Send Report… ONLY when it did; Delete Report always;
//   · the two acts are `.surface` only (no palette, no menu — a report is
//     sent from where it was read).
//  Red on old by construction: the pane did not exist.
//

import AppKit
import Foundation
import SwiftUI
import Testing
@testable import Variorum

@MainActor
@Suite("Settings ▸ Diagnostics (13r U3-B, the ruled tenth pane)", .serialized)
struct DiagnosticsPaneTests {
    private func owner(_ name: String, on: Bool, reports: [Data] = []) -> CrashReporting {
        let suite = "13r.u3b.pane.\(name)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = CrashReportStore(directory: FileManager.default.temporaryDirectory
            .appendingPathComponent("13r-u3b-pane-\(name)-\(UUID().uuidString)"))
        for (index, bytes) in reports.enumerated() {
            store.save(bytes, receivedAt: Date(timeIntervalSince1970: 1_790_000_000 + Double(index)))
        }
        let owner = CrashReporting(
            defaults: defaults, registration: RecordingRegistration(), store: store)
        if on { owner.set(true) }
        return owner
    }

    private func findings(_ query: String) -> [SettingsFinding] {
        SettingsSearch.findings(matching: query, in: SettingsSearch.wholeIndex)
    }

    // MARK: The pane's place and name (the ruling)

    @Test func theTenthPaneSitsBetweenDataSafetyAndAcknowledgments() throws {
        let panes = SettingsPane.allCases
        // 13n-b U1 (a CONSEQUENTIAL pin edit, annotated in place): the MCP
        // pane is the eleventh — placed beside Tags, so THIS ruling's
        // neighbours (Data Safety before, Acknowledgments after) still hold.
        #expect(panes.count == 11)
        let index = try #require(panes.firstIndex(of: .diagnostics))
        #expect(panes[index - 1] == .dataSafety)
        #expect(panes[index + 1] == .acknowledgments)
        #expect(SettingsPane.diagnostics.title == "Diagnostics")
        #expect(SettingsPane.diagnostics.symbol == "stethoscope")
        #expect(SettingsPane.diagnostics.blurb.contains("off unless you turn them on"))
        #expect(AppSettingsView.rowIDsRendered[.diagnostics] == ["crashReports"])
        #expect(SettingsCatalog.title("crashReports") == DiagnosticsCopy.toggleTitle)
        // VX-139 (a CONSEQUENTIAL pin edit, annotated in place): the
        // keep-open-notes toggle is General's sixth catalog row — General
        // is its honest home (how the app OPENS, not a note's behavior),
        // and its section sits below the palette (in Release the Updates
        // section renders after it), so
        // row 59's real intent (the short dials stay above the fold at the
        // top) holds. The cap moves 5 → 6; the crash-report opt-in this
        // pin guards is still not on the pane. PROVISIONAL P-VX139-vi —
        // hers to reverse by re-homing the toggle.
        // VX-589 (the same CONSEQUENTIAL edit, annotated): "Hide starred
        // notes from Open" joins the Open notes section as the seventh row,
        // below keep-open-notes — the short dials still top the pane; the cap
        // moves 6 → 7, and the crash-report opt-in is still not on it. ("The
        // short dials still top the pane" is reasoning from the catalog's
        // order, not a look: no capture of General with its seventh row exists
        // yet — the VX-439 ladder's m-4 — and the live look is OWED to the
        // run's evidence slice.)
        #expect(SettingsCatalog.rows(in: .general).count <= 7,
                "the opt-in did not land on the short opening pane (row 59)")
    }

    @Test func settingsSearchReachesItInHerWords() {
        for word in ["crash", "crash report", "diagnostics", "privacy", "metrickit", "analytics"] {
            #expect(findings(word).contains { $0.kind == .setting && $0.pane == .diagnostics },
                    "“\(word)” finds the crash-report opt-in")
        }
    }

    // The 19f review's MINOR 1: the catalog row's blurb is the promise's TWIN (settings
    // search renders it as the result's detail line), so its verb must match the pane's —
    // #182 (e) ratified "offers", and the two sentences must not disagree.
    @Test func theCatalogBlurbSpeaksThePromisesVerb() {
        let blurb = SettingsCatalog.rows.first { $0.id == "crashReports" }?.blurb ?? ""
        #expect(blurb.contains("offers an email draft"),
                "the search result's detail says what the pane's promise says (#182 (e))")
    }

    // MARK: What the pane composes

    @Test func offThePaneLeadsWithTheToggleAndThePromiseAndSaysNothingIsCollected() async {
        let pane = DiagnosticsPane(crashReports: owner("off", on: false))
        await SurfaceComposition.host(pane, size: NSSize(width: 520, height: 520))
        let shown = SurfaceComposition.text(of: pane.body)
        #expect(SurfaceComposition.carries(DiagnosticsCopy.toggleTitle, in: shown))
        #expect(SurfaceComposition.carries(DiagnosticsCopy.promise, in: shown))
        #expect(SurfaceComposition.carries(DiagnosticsCopy.feedbackPointer, in: shown))
        #expect(SurfaceComposition.carries(DiagnosticsCopy.emptyWhileOff, in: shown))
        #expect(!SurfaceComposition.carries(DiagnosticsCopy.emptyWhileOn, in: shown))
    }

    @Test func onWithNothingReceivedSaysSoCalmly() async {
        let pane = DiagnosticsPane(crashReports: owner("onEmpty", on: true))
        await SurfaceComposition.host(pane, size: NSSize(width: 520, height: 520))
        let shown = SurfaceComposition.text(of: pane.body)
        #expect(SurfaceComposition.carries(DiagnosticsCopy.emptyWhileOn, in: shown))
        #expect(!SurfaceComposition.carries(DiagnosticsCopy.emptyWhileOff, in: shown))
    }

    @Test func thePromiseSaysWhatTheCodeDoes() {
        let promise = DiagnosticsCopy.promise
        #expect(promise.hasPrefix("Off unless you turn it on."))
        #expect(promise.contains("stay on this Mac"))
        #expect(promise.contains("exactly as they arrived"))
        #expect(promise.contains("Nothing is ever sent on its own"))
        #expect(promise.contains(SupportDraft.address))
        #expect(promise.contains(CapabilityRegistry.capability(.sendCrashReport).verb),
                "the promise names the door by the verb the card renders")
        #expect(promise.hasSuffix("This Mac only."))
        #expect(DiagnosticsCopy.feedbackPointer.contains(SupportCopy.feedbackMenuTitle))
    }

    // MARK: A received report, verbatim

    @Test func aReportsCardShowsItVerbatimAndOffersSendAndDelete() async throws {
        let owner = owner("card", on: true, reports: [Data(CrashReportFixture.json.utf8)])
        let report = try #require(owner.reports.first)
        let card = CrashReportCard(
            report: report, tokens: .fallback(for: .light), send: {}, delete: {})
        await SurfaceComposition.host(card, size: NSSize(width: 480, height: 320))
        let shown = SurfaceComposition.text(of: card.body)
        #expect(SurfaceComposition.carries(CrashReportFixture.json, in: shown),
                "the report's whole text, verbatim, is on the card")
        #expect(SurfaceComposition.carries("Variorum 0.9.0 (4893) \u{00B7} macOS 27.0 (26A428)", in: shown))
        #expect(SurfaceComposition.carries(CapabilityRegistry.capability(.sendCrashReport).verb, in: shown))
        #expect(SurfaceComposition.carries(CapabilityRegistry.capability(.deleteCrashReport).verb, in: shown))
        #expect(!SurfaceComposition.carries(DiagnosticsCopy.notText, in: shown))

        // And the whole pane with that report hosts and lays out.
        await SurfaceComposition.host(
            DiagnosticsPane(crashReports: owner, roads: RecordingRoads()),
            size: NSSize(width: 520, height: 520))
    }

    /// Only what was shown verbatim may leave: a report that is not text is
    /// never shown as if it were, and has no Send.
    @Test func aReportThatIsNotTextHasNoSend() async throws {
        let owner = owner("notText", on: true, reports: [Data([0xFF, 0xFE, 0x00, 0xD8])])
        let report = try #require(owner.reports.first)
        let card = CrashReportCard(
            report: report, tokens: .fallback(for: .dark), send: {}, delete: {})
        await SurfaceComposition.host(card, size: NSSize(width: 480, height: 200))
        let shown = SurfaceComposition.text(of: card.body)
        #expect(SurfaceComposition.carries(DiagnosticsCopy.notText, in: shown))
        #expect(!SurfaceComposition.carries(CapabilityRegistry.capability(.sendCrashReport).verb, in: shown))
        #expect(SurfaceComposition.carries(CapabilityRegistry.capability(.deleteCrashReport).verb, in: shown))
    }

    // MARK: The registry

    @Test func theTwoActsAreSurfaceDoorsOnly() {
        for id in DiagnosticsPane.surfaceCapabilities {
            #expect(CapabilityRegistry.capability(id).doors == [.surface],
                    "\(id): sent or deleted from where it was read — never ⌘K, never a menu")
        }
        #expect(CapabilityRegistry.capability(.sendCrashReport).verb == "Send Report\u{2026}")
        #expect(CapabilityRegistry.capability(.deleteCrashReport).verb == "Delete Report")
    }
}
