//
//  CrashReportingTests.swift
//  VariorumTests
//
//  13r U3-B — R-13r-5: crash reporting is OPT-IN, default OFF, PROVABLY.
//
//  The claim that matters is a negative one — "when off, the app is not
//  subscribed to MetricKit" — and a negative claim is only pinnable through
//  a seam. `CrashDiagnosticRegistration` is that seam; the recorder below
//  stands where `MXMetricManager` stands, so "no registration happened" is
//  something these pins can SEE.
//
//  RED ON OLD by construction: none of these types existed before U3-B. The
//  OFF pins are the ones the finals' mutation run targets (the owner made to
//  register regardless of the preference must turn them red).
//

import Foundation
import MetricKit
import Testing
@testable import Variorum

@Suite("Crash reporting — opt-in, OFF provably (13r U3-B, R-13r-5)")
@MainActor
struct CrashReportingTests {
    /// A scrubbed defaults suite — never `.standard`, which the dev-store app
    /// and walks share (the `LibraryCatalogModel` rule).
    private func scratch(_ name: String) -> UserDefaults {
        let suite = "13r.u3b.crash.\(name)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    /// A fresh, empty folder for one pin's reports.
    private func folder(_ name: String) -> CrashReportStore {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("13r-u3b-crash-\(name)-\(UUID().uuidString)", isDirectory: true)
        return CrashReportStore(directory: url)
    }

    // MARK: OFF, provably

    @Test func aFreshInstallIsOffAndRegistersNothing() {
        let defaults = scratch("fresh")
        let recorder = RecordingRegistration()
        #expect(CrashReportingPreference.remembered(defaults) == false,
                "nothing stored means OFF")
        let owner = CrashReporting(defaults: defaults, registration: recorder, store: folder("fresh"))
        #expect(owner.isOn == false)
        #expect(recorder.registered.isEmpty,
                "OFF means NOT SUBSCRIBED: the launch road registered no MetricKit subscriber")
        #expect(owner.subscriber == nil, "no subscriber exists, so nothing can be delivered")
    }

    /// Only an explicit YES turns it on. Every other stored shape — the ones a
    /// stray `defaults write` could leave — reads OFF and registers nothing.
    @Test func onlyAnExplicitYesIsOnAndEveryOtherValueRegistersNothing() {
        let strange: [Any] = [false, "1", "YES", "true", 2, "on", Data([1])]
        for (index, value) in strange.enumerated() {
            let defaults = scratch("strange\(index)")
            defaults.set(value, forKey: CrashReportingPreference.settingKey)
            let recorder = RecordingRegistration()
            let owner = CrashReporting(
                defaults: defaults, registration: recorder, store: folder("strange\(index)"))
            #expect(owner.isOn == false, "\(value) is not a yes")
            #expect(recorder.registered.isEmpty, "\(value) registered a subscriber")
        }
        let yes = scratch("yes")
        yes.set(true, forKey: CrashReportingPreference.settingKey)
        #expect(CrashReportingPreference.remembered(yes) == true)
    }

    /// Many launches, never told yes: never subscribed, on any of them.
    @Test func launchAfterLaunchWhileOffNeverSubscribes() {
        let defaults = scratch("launches")
        let recorder = RecordingRegistration()
        for _ in 0..<5 {
            _ = CrashReporting(defaults: defaults, registration: recorder, store: folder("launches"))
        }
        #expect(recorder.registered.isEmpty)
        #expect(recorder.unregistered.isEmpty)
    }

    // MARK: ON, and back OFF

    @Test func sayingYesSubscribesOnceAndNoUnsubscribesTheSameSubscriber() throws {
        let defaults = scratch("toggle")
        let recorder = RecordingRegistration()
        let owner = CrashReporting(defaults: defaults, registration: recorder, store: folder("toggle"))

        owner.set(true)
        #expect(owner.isOn)
        #expect(defaults.object(forKey: CrashReportingPreference.settingKey) as? Bool == true,
                "her yes is remembered, locally")
        #expect(recorder.registered.count == 1)
        owner.set(true)
        #expect(recorder.registered.count == 1, "saying yes twice subscribes once")

        let subscribed = try #require(recorder.registered.first)
        owner.set(false)
        #expect(owner.isOn == false)
        #expect(defaults.object(forKey: CrashReportingPreference.settingKey) as? Bool == false)
        #expect(recorder.unregistered.count == 1)
        #expect(recorder.unregistered.first === subscribed,
                "the subscriber that was registered is the one taken back")
        #expect(owner.subscriber == nil)
    }

    /// The launch road after she said yes: subscribed before any window.
    @Test func aRememberedYesSubscribesAtLaunch() {
        let defaults = scratch("rememberedYes")
        defaults.set(true, forKey: CrashReportingPreference.settingKey)
        let recorder = RecordingRegistration()
        let owner = CrashReporting(
            defaults: defaults, registration: recorder, store: folder("rememberedYes"))
        #expect(owner.isOn)
        #expect(recorder.registered.count == 1)
        #expect(recorder.registered.first === owner.subscriber)
    }

    // MARK: What a delivery does

    @Test func aDeliveryWhileOnLandsVerbatimAndADeliveryAfterOffIsDropped() async throws {
        let defaults = scratch("delivery")
        let store = folder("delivery")
        let owner = CrashReporting(
            defaults: defaults, registration: RecordingRegistration(), store: store,
            now: { Date(timeIntervalSince1970: 1_790_000_000) })
        owner.set(true)
        let bytes = Data(CrashReportFixture.json.utf8)
        try #require(owner.subscriber).deliverAsMetricKitWould([bytes])
        // The subscriber hops to the main actor; let that hop land.
        for _ in 0..<50 where owner.reports.isEmpty { await Task.yield() }
        #expect(owner.reports.count == 1)
        #expect(owner.reports.first?.bytes == bytes, "stored byte for byte")
        #expect(owner.reports.first?.text == CrashReportFixture.json, "shown verbatim")

        // OFF: the subscriber is gone; a late delivery straight into the owner
        // (the race with unregistering) is dropped.
        owner.set(false)
        owner.receive([Data("{\"late\":true}".utf8)])
        #expect(owner.reports.count == 1, "nothing is collected while OFF")
        // Turning off does not delete what already arrived — it is hers.
        #expect(store.list().count == 1)
    }

    @Test func theSubscriberTakesDiagnosticsAndNeverMetrics() {
        #expect(CrashDiagnosticSubscriber.instancesRespond(
            to: NSSelectorFromString("didReceiveDiagnosticPayloads:")),
                "MetricKit's diagnostic callback is implemented")
        #expect(!CrashDiagnosticSubscriber.instancesRespond(
            to: NSSelectorFromString("didReceiveMetricPayloads:")),
                "the metrics callback is NOT — no metrics are ever delivered to this app")
        #expect(CrashDiagnosticSubscriber.crashReports(in: []).isEmpty)
    }

    /// The app's own owner rides MetricKit — and, built over a defaults that
    /// never said yes, is not subscribed to it.
    @Test func theAppsOwnerUsesMetricKitAndStartsOff() {
        let owner = CrashReporting.forThisApp(defaults: scratch("forThisApp"))
        #expect(owner.registration is MetricKitRegistration)
        #expect(owner.isOn == false)
        #expect(owner.subscriber == nil)
        #expect(owner.store.directory.path.hasSuffix("Diagnostics/Crash Reports"),
                "a sibling of the library folder, never inside it")
    }

    // MARK: The store

    @Test func theStoreKeepsBytesUntouchedListsNewestFirstAndDeletes() throws {
        let store = folder("store")
        let older = try #require(store.save(
            Data("{\"a\":1}".utf8), receivedAt: Date(timeIntervalSince1970: 1_790_000_000),
            suffix: "aaaa0001"))
        let newer = try #require(store.save(
            Data(CrashReportFixture.json.utf8), receivedAt: Date(timeIntervalSince1970: 1_790_086_400),
            suffix: "bbbb0002"))
        try Data("not ours".utf8).write(to: store.directory.appendingPathComponent("notes.txt"))

        let listed = store.list()
        #expect(listed.map(\.id) == [newer.id, older.id], "newest first; strangers ignored")
        #expect(listed.first?.bytes == Data(CrashReportFixture.json.utf8))
        #expect(listed.first?.receivedAt == Date(timeIntervalSince1970: 1_790_086_400),
                "the stamp in the name survives the round trip")
        #expect(newer.id.hasPrefix("crash-report-") && newer.id.hasSuffix(".json"))

        store.delete(older)
        #expect(store.list().map(\.id) == [newer.id])
    }

    @Test func aReportsHeadingIsReadOutOfItNeverAddedToIt() {
        let report = CrashReport(
            id: "x", url: URL(fileURLWithPath: "/dev/null"), receivedAt: Date(),
            bytes: Data(CrashReportFixture.json.utf8))
        #expect(report.heading == "Variorum 0.9.0 (4893) \u{00B7} macOS 27.0 (26A428)")
        let bare = CrashReport(
            id: "y", url: URL(fileURLWithPath: "/dev/null"), receivedAt: Date(),
            bytes: Data("{}".utf8))
        #expect(bare.heading == nil)
        let notText = CrashReport(
            id: "z", url: URL(fileURLWithPath: "/dev/null"), receivedAt: Date(),
            bytes: Data([0xFF, 0xFE, 0x00, 0xD8]))
        #expect(notText.text == nil, "bytes that are not UTF-8 are never shown as if they were")
    }
}

/// Stands where `MXMetricManager` stands.
@MainActor
final class RecordingRegistration: CrashDiagnosticRegistration {
    private(set) var registered: [CrashDiagnosticSubscriber] = []
    private(set) var unregistered: [CrashDiagnosticSubscriber] = []
    func register(_ subscriber: CrashDiagnosticSubscriber) { registered.append(subscriber) }
    func unregister(_ subscriber: CrashDiagnosticSubscriber) { unregistered.append(subscriber) }
}

/// A crash diagnostic in MetricKit's documented JSON shape (callStackTree +
/// diagnosticMetaData), plainly marked as a fixture.
enum CrashReportFixture {
    static let json = """
    {
      "callStackTree" : {
        "callStackPerThread" : true,
        "callStacks" : [
          {
            "threadAttributed" : true,
            "callStackRootFrames" : [
              {
                "binaryUUID" : "00000000-0000-0000-0000-000000000000",
                "offsetIntoBinaryTextSegment" : 123456,
                "sampleCount" : 1,
                "binaryName" : "Variorum",
                "address" : 4294967296
              }
            ]
          }
        ]
      },
      "diagnosticMetaData" : {
        "appBuildVersion" : "4893",
        "appVersion" : "0.9.0",
        "osVersion" : "macOS 27.0 (26A428)",
        "platformArchitecture" : "arm64e",
        "exceptionType" : 1,
        "exceptionCode" : 0,
        "signal" : 11,
        "terminationReason" : "FIXTURE — not a real crash"
      }
    }
    """
}
