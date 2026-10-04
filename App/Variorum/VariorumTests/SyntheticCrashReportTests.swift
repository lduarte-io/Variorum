//
//  SyntheticCrashReportTests.swift
//  VariorumTests
//
//  13r U3-B — the walk's synthetic-payload door is gated: by the launch
//  environment, and by the opt-in (an OFF app has no subscriber to deliver
//  into). Red on old by construction (the door did not exist).
//

import Foundation
import Testing
@testable import Variorum

@Suite("The synthetic crash-report door (13r U3-B, DEBUG walk only)")
@MainActor
struct SyntheticCrashReportTests {
    private func owner(_ name: String, on: Bool) -> CrashReporting {
        let suite = "13r.u3b.synthetic.\(name)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = CrashReportStore(directory: FileManager.default.temporaryDirectory
            .appendingPathComponent("13r-u3b-synthetic-\(name)-\(UUID().uuidString)"))
        let owner = CrashReporting(
            defaults: defaults, registration: RecordingRegistration(), store: store)
        if on { owner.set(true) }
        return owner
    }

    private func reportFile() throws -> String {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("13r-u3b-synthetic-\(UUID().uuidString).json")
        try Data(CrashReportFixture.json.utf8).write(to: url)
        return url.path
    }

    @Test func notAskedForMeansNothingHappens() {
        let owner = owner("notAsked", on: true)
        #expect(SyntheticCrashReport.injectIfRequested(environment: [:], into: owner) == .notRequested)
        #expect(owner.reports.isEmpty)
    }

    @Test func offMeansNothingIsDeliveredEvenWhenAskedFor() throws {
        let owner = owner("off", on: false)
        let outcome = SyntheticCrashReport.injectIfRequested(
            environment: [SyntheticCrashReport.environmentKey: try reportFile()], into: owner)
        #expect(outcome == .offSoNothingDelivered)
        #expect(owner.reports.isEmpty)
        #expect(owner.store.list().isEmpty, "nothing reached the folder")
    }

    @Test func onAndAskedForTheReportArrivesThroughTheSubscriberVerbatim() async throws {
        let owner = owner("on", on: true)
        let outcome = SyntheticCrashReport.injectIfRequested(
            environment: [SyntheticCrashReport.environmentKey: try reportFile()], into: owner)
        #expect(outcome == .delivered)
        for _ in 0..<50 where owner.reports.isEmpty { await Task.yield() }
        #expect(owner.reports.count == 1)
        #expect(owner.reports.first?.text == CrashReportFixture.json)
    }

    @Test func anUnreadablePathDeliversNothing() {
        let owner = owner("unreadable", on: true)
        let outcome = SyntheticCrashReport.injectIfRequested(
            environment: [SyntheticCrashReport.environmentKey: "/nonexistent/\(UUID().uuidString)"],
            into: owner)
        #expect(outcome == .unreadable)
        #expect(owner.reports.isEmpty)
    }
}
