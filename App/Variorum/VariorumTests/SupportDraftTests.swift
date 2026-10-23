//
//  SupportDraftTests.swift
//  VariorumTests
//
//  13r U3-B — the support door's mail draft (R-13r-3/9) and a crash report's
//  Send (R-13r-5). What these pin:
//   · the feedback draft goes to the live mailbox, pre-filled with the app
//     and OS versions and NOTHING else;
//   · the crash draft attaches the report's OWN file — the bytes the
//     Diagnostics surface showed;
//   · the `mailto:` form is RFC 6068-clean and round-trips the body;
//   · which road a draft takes, and that no road ever SENDS (the roads can
//     only open a draft on screen, reveal a file, or refuse).
//  Red on old by construction: none of this existed before U3-B.
//

import AppKit
import Foundation
import Testing
@testable import Variorum

@Suite("The support door's mail draft (13r U3-B, R-13r-3/5/9)")
@MainActor
struct SupportDraftTests {
    private let versions = SupportDraft.Versions(
        app: "0.9.0", build: "4893", os: "macOS 27.0 (26A428)")

    // MARK: The drafts

    @Test func theFeedbackDraftIsTheVersionsAndNothingElse() {
        let draft = SupportDraft.feedback(versions)
        #expect(draft.recipient == "support@stargazing.tech", "the LIVE mailbox (R-13r-9)")
        #expect(draft.subject == "Variorum feedback")
        #expect(draft.attachment == nil)
        #expect(draft.body == "\n\n\n\u{2014}\u{2014}\u{2014}\nVariorum 0.9.0 (4893)\nmacOS 27.0 (26A428)\n",
                "room to write, a rule, the two version lines — every byte she will see")
    }

    @Test func theRunningAppsVersionsAreTheBundlesOwn() {
        let mine = SupportDraft.Versions.thisMac()
        #expect(mine.app == Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
        #expect(mine.build == Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String)
        #expect(mine.app.hasPrefix("0."), "R-13r-6's pre-1.0 line (0.10 at the VX-329 release word; VX-489)")
        #expect(mine.os.hasPrefix("macOS "))
    }

    @Test func theOSLineIsReadNeverGuessed() {
        let v27 = OperatingSystemVersion(majorVersion: 27, minorVersion: 0, patchVersion: 0)
        #expect(SupportDraft.Versions.osLine(version: v27, versionString: "Version 27.0 (Build 26A428)")
                == "macOS 27.0 (26A428)")
        let v2701 = OperatingSystemVersion(majorVersion: 27, minorVersion: 0, patchVersion: 1)
        #expect(SupportDraft.Versions.osLine(version: v2701, versionString: "Version 27.0.1 (Build 26A434)")
                == "macOS 27.0.1 (26A434)")
        #expect(SupportDraft.Versions.osLine(version: v27, versionString: "Version 27.0")
                == "macOS 27.0", "no build in the string — none is invented")
    }

    @Test func theCrashDraftAttachesTheReportsOwnFile() {
        let url = URL(fileURLWithPath: "/tmp/crash-report-20261004T211500Z-abcd1234.json")
        let draft = SupportDraft.crashReport(fileName: url.lastPathComponent, at: url, versions)
        #expect(draft.recipient == "support@stargazing.tech")
        #expect(draft.subject == "Variorum crash report")
        #expect(draft.attachment == url, "the very file the surface showed — never a copy")
        #expect(draft.body.contains("Attached: crash-report-20261004T211500Z-abcd1234.json"))
        #expect(draft.body.hasSuffix("Variorum 0.9.0 (4893)\nmacOS 27.0 (26A428)\n"))

        let byHand = draft.attachingByHand()
        #expect(byHand.attachment == nil)
        #expect(byHand.recipient == draft.recipient && byHand.subject == draft.subject)
        #expect(byHand.body.contains("Please attach crash-report-20261004T211500Z-abcd1234.json"))
        #expect(!byHand.body.contains("Attached:"))
    }

    /// A report's Send carries the file whose bytes the surface showed.
    @Test func whatIsSentIsWhatWasShown() throws {
        let store = CrashReportStore(directory: FileManager.default.temporaryDirectory
            .appendingPathComponent("13r-u3b-shown-\(UUID().uuidString)"))
        let report = try #require(store.save(Data(CrashReportFixture.json.utf8), receivedAt: Date()))
        let draft = SupportDraft.crashReport(fileName: report.id, at: report.url, versions)
        let attached = try Data(contentsOf: try #require(draft.attachment))
        #expect(String(data: attached, encoding: .utf8) == report.text)
    }

    // MARK: The mailto: form

    @Test func theMailtoFormIsRFC6068CleanAndRoundTrips() throws {
        let draft = SupportDraft.feedback(versions)
        let url = try #require(draft.mailtoURL)
        let text = url.absoluteString
        #expect(text.hasPrefix("mailto:support@stargazing.tech?subject=Variorum%20feedback&body="))
        #expect(!text.contains(" ") && !text.contains("\n"), "nothing raw")
        #expect(text.contains("%0D%0A"), "line breaks as CRLF (RFC 6068 §5)")
        #expect(!text.contains("+"), "no form-encoding '+' a mail app could read as itself")

        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let body = try #require(components.queryItems?.first { $0.name == "body" }?.value)
        #expect(body.replacingOccurrences(of: "\r\n", with: "\n") == draft.body)
        #expect(components.queryItems?.map(\.name) == ["subject", "body"],
                "subject and body only — nothing a mail app is told to ignore")
    }

    // MARK: The roads (nothing is ever sent)

    @Test func feedbackOpensAPlainDraftInTheDefaultMailApp() {
        let roads = RecordingRoads()
        var refusals: [String] = []
        let road = SupportMail.open(.feedback(versions), roads: roads) { refusals.append($0) }
        #expect(road == .mailto)
        #expect(roads.opened.count == 1 && roads.opened.first?.scheme == "mailto")
        #expect(roads.composed.isEmpty, "no attachment — the compose service is not needed")
        #expect(refusals.isEmpty)
    }

    @Test func aReportsDraftComposesWithTheAttachmentWhenItCan() {
        let roads = RecordingRoads()
        roads.composeAvailable = true
        let url = URL(fileURLWithPath: "/tmp/crash-report-x.json")
        let road = SupportMail.open(
            .crashReport(fileName: "crash-report-x.json", at: url, versions), roads: roads) { _ in }
        #expect(road == .composeWithAttachment)
        #expect(roads.composed.first?.attachment == url)
        #expect(roads.opened.isEmpty && roads.revealed.isEmpty)
    }

    @Test func whenNoMailAppCanAttachTheFileIsShownAndThePlainDraftNamesIt() throws {
        let roads = RecordingRoads()
        roads.composeAvailable = false
        let url = URL(fileURLWithPath: "/tmp/crash-report-y.json")
        let road = SupportMail.open(
            .crashReport(fileName: "crash-report-y.json", at: url, versions), roads: roads) { _ in }
        #expect(road == .mailtoAndReveal)
        #expect(roads.revealed == [url])
        let opened = try #require(roads.opened.first)
        #expect(opened.absoluteString.contains("Please%20attach%20crash-report-y.json"))
    }

    @Test func aLateComposeFailureFallsBackAndHerCancelDoesNot() {
        let roads = RecordingRoads()
        roads.composeAvailable = true
        let url = URL(fileURLWithPath: "/tmp/crash-report-z.json")
        SupportMail.open(.crashReport(fileName: "crash-report-z.json", at: url, versions), roads: roads) { _ in }
        #expect(roads.opened.isEmpty)
        roads.failCompose()
        #expect(roads.revealed == [url], "the service failed — the by-hand road runs")
        #expect(roads.opened.count == 1)

        // The live delegate's classification: closing the compose window
        // unsent is her answer, and is not treated as a failure.
        #expect(LiveSupportMailRoads.isHerOwnCancel(
            NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError)))
        #expect(!LiveSupportMailRoads.isHerOwnCancel(
            NSError(domain: NSCocoaErrorDomain, code: NSFileReadNoPermissionError)))
        #expect(!LiveSupportMailRoads.isHerOwnCancel(
            NSError(domain: "other", code: NSUserCancelledError)))
    }

    /// F5 (ladder round 1, the exchange's sharpened mechanism): with drafts A
    /// then B in flight, A's LATE failure must run A's own road — never B's
    /// (the wrong draft's file shown and named) — and B's SUCCESS must clear
    /// only B's road. The live delegate's bookkeeping is driven directly over
    /// two services that are NEVER performed (performing would open Mail —
    /// which is why no red-on-old pin could run against the single-slot
    /// shape; the mutant check stands in, recorded in the plan).
    @Test func aLateFailureRunsOnlyItsOwnDraftsRoadAndASuccessClearsOnlyItsOwn() throws {
        let roads = LiveSupportMailRoads()
        let serviceA = try #require(NSSharingService(named: .composeEmail))
        let serviceB = try #require(NSSharingService(named: .composeEmail))
        var ran: [String] = []
        roads.expectFailureRoad(for: serviceA) { ran.append("A") }
        roads.expectFailureRoad(for: serviceB) { ran.append("B") }
        let failure = NSError(domain: "test", code: 1)
        roads.sharingService(serviceA, didFailToShareItems: [], error: failure)
        #expect(ran == ["A"], "A's late failure runs A's road, never B's")
        roads.sharingService(serviceB, didShareItems: [])
        roads.sharingService(serviceB, didFailToShareItems: [], error: failure)
        #expect(ran == ["A"], "B's success cleared only B's road; nothing runs twice")
        // Her own cancel consumes the road and runs nothing (unchanged).
        roads.expectFailureRoad(for: serviceA) { ran.append("A2") }
        roads.sharingService(
            serviceA, didFailToShareItems: [],
            error: NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError))
        roads.sharingService(serviceA, didFailToShareItems: [], error: failure)
        #expect(ran == ["A"], "a cancel is her answer — the road is spent, not re-run")
    }

    @Test func nothingOpeningSpeaksARefusal() {
        let roads = RecordingRoads()
        roads.urlsOpen = false
        var refusals: [String] = []
        let road = SupportMail.open(.feedback(versions), roads: roads) { refusals.append($0) }
        #expect(road == .nothingCouldOpen)
        #expect(refusals == [SupportCopy.nothingCouldOpen])
        #expect(SupportCopy.nothingCouldOpen.contains("support@stargazing.tech"))
        #expect(SupportCopy.nothingCouldOpen.contains("nothing was sent"))
    }

    // MARK: The Help door

    @Test func theHelpMenuCarriesTheSendFeedbackDoor() throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Variorum/EditorCommands.swift")
        let file = try String(contentsOf: url, encoding: .utf8)
        #expect(file.contains("Button(SupportCopy.feedbackMenuTitle) { sendFeedback() }"))
        #expect(file.contains("SupportMail.open(.feedback(.thisMac()))"))
        #expect(SupportCopy.feedbackMenuTitle == "Send Feedback\u{2026}")
    }
}

/// Stands where the mail app, Finder and the compose service stand. It has
/// no "send" — no road in `SupportMailRoads` can send.
@MainActor
final class RecordingRoads: SupportMailRoads {
    var composeAvailable = false
    var urlsOpen = true
    private(set) var composed: [SupportDraft] = []
    private(set) var opened: [URL] = []
    private(set) var revealed: [URL] = []
    private var failure: (@MainActor () -> Void)?

    func canCompose(_ draft: SupportDraft) -> Bool { composeAvailable }
    func compose(_ draft: SupportDraft, onFailure: @escaping @MainActor () -> Void) {
        composed.append(draft)
        failure = onFailure
    }
    func open(_ url: URL) -> Bool {
        guard urlsOpen else { return false }
        opened.append(url)
        return true
    }
    func reveal(_ url: URL) { revealed.append(url) }
    func failCompose() { failure?() }
}
