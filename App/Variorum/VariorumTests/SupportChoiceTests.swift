//
//  SupportChoiceTests.swift
//  VariorumTests
//
//  19f — THE PRE-DRAFT CHOICE (her QUESTIONS #181 (i) ruling, 2026-10-04):
//  before ANY draft opens, both support doors ask — "Open in Mail" or the
//  road that never needs a mail app ("Show the file and copy the address"
//  for a report; "Copy the address" for feedback). What these pin:
//   · the question's channel keeps `ShellRouter.ask`'s three rules
//     (dismissal is an answer; a second ask answers the first; answering
//     twice is safe);
//   · the ONE dispatcher asks FIRST — no road runs, nothing is copied or
//     shown before her answer — and a dismissal does nothing at all;
//   · "Open in Mail" runs the door's own road (the U3-B roads, unchanged);
//   · the second road lands `support@stargazing.tech` on the pasteboard and,
//     for a report, shows its file in Finder — and opens no draft;
//   · the two questions carry her words and the right file.
//  The pasteboard is a PRIVATE named one — her clipboard is never a test's.
//

import AppKit
import Foundation
import Testing
@testable import Variorum

@Suite("The support doors' pre-draft choice (19f, #181 (i))", .serialized)
@MainActor
struct SupportChoiceTests {
    private func poll(_ condition: @MainActor () -> Bool) async {
        for _ in 0..<400 {
            if condition() { return }
            await Task.yield()
            try? await Task.sleep(nanoseconds: 3_000_000)
        }
    }

    /// A private pasteboard holding a sentinel, so "untouched" is a fact.
    private func privatePasteboard() -> NSPasteboard {
        let pasteboard = NSPasteboard(name: NSPasteboard.Name("19f-\(UUID().uuidString)"))
        pasteboard.clearContents()
        pasteboard.setString("sentinel", forType: .string)
        return pasteboard
    }

    private let reportFile = URL(fileURLWithPath: "/tmp/crash-report-19f.json")

    // MARK: The channel (ShellRouter.ask's three rules)

    @Test func askPublishesTheQuestionAndTheAnswerResumesTheDoor() async {
        let asking = SupportChoiceAsk()
        let asked = Task { @MainActor in await asking.ask(.feedback) }
        await poll { asking.pending != nil }
        #expect(asking.pending?.question == .feedback)
        asking.answer(.copyAddress)
        #expect(asking.pending == nil, "answering clears it in the same act")
        #expect(await asked.value == .copyAddress)
    }

    @Test func dismissingIsAnAnswerNeverASilence() async {
        let asking = SupportChoiceAsk()
        let asked = Task { @MainActor in await asking.ask(.report(file: reportFile)) }
        await poll { asking.pending != nil }
        asking.answer(nil)
        #expect(await asked.value == nil)
    }

    @Test func aSecondAskAnswersTheFirstRatherThanStrandingIt() async {
        let asking = SupportChoiceAsk()
        let first = Task { @MainActor in await asking.ask(.feedback) }
        await poll { asking.pending?.question == .feedback }
        let second = Task { @MainActor in await asking.ask(.report(file: reportFile)) }
        await poll { asking.pending?.question.file == reportFile }
        #expect(await first.value == nil, "the first was answered, not stranded")
        asking.answer(.openInMail)
        #expect(await second.value == .openInMail)
    }

    @Test func answeringTwiceIsSafe() async {
        let asking = SupportChoiceAsk()
        let asked = Task { @MainActor in await asking.ask(.feedback) }
        await poll { asking.pending != nil }
        asking.answer(.openInMail)
        asking.answer(nil)
        asking.answer(.copyAddress)
        #expect(await asked.value == .openInMail)
        #expect(asking.pending == nil)
    }

    /// Each window carries its own channel (the Help door asks the window it
    /// lands in).
    @Test func everyShellCarriesItsOwnChannel() {
        let one = ShellRouter(), two = ShellRouter()
        #expect(one.supportChoice !== two.supportChoice)
        #expect(one.supportChoice.pending == nil, "nothing is asked until a door asks")
    }

    // MARK: The dispatcher — ask FIRST

    /// THE RULING'S LETTER, at the one dispatcher: the question is on screen
    /// before any road has run, and nothing has been copied or shown.
    @Test func theQuestionComesBeforeAnyRoad() async {
        let roads = RecordingRoads()
        let pasteboard = privatePasteboard()
        let asking = SupportChoiceAsk()
        let mailRoad = RanCount()
        let file = reportFile
        let door = Task { @MainActor in
            await SupportMail.ask(
                .report(file: file), choose: asking.ask, roads: roads,
                pasteboard: pasteboard
            ) {
                mailRoad.count += 1
                return .composeWithAttachment
            }
        }
        await poll { asking.pending != nil }
        #expect(asking.pending?.question == .report(file: reportFile))
        #expect(mailRoad.count == 0, "no draft before her answer")
        #expect(roads.composed.isEmpty && roads.opened.isEmpty && roads.revealed.isEmpty)
        #expect(pasteboard.string(forType: .string) == "sentinel", "nothing copied yet")
        asking.answer(.openInMail)
        #expect(await door.value == .openedInMail(.composeWithAttachment))
        #expect(mailRoad.count == 1)
    }

    @Test func aDismissedQuestionDoesNothingAtAll() async {
        let roads = RecordingRoads()
        let pasteboard = privatePasteboard()
        var mailRoadRan = false
        let answer = await SupportMail.ask(
            .report(file: reportFile), choose: { _ in nil }, roads: roads, pasteboard: pasteboard
        ) {
            mailRoadRan = true
            return .composeWithAttachment
        }
        #expect(answer == .dismissed)
        #expect(!mailRoadRan)
        #expect(roads.composed.isEmpty && roads.opened.isEmpty && roads.revealed.isEmpty)
        #expect(pasteboard.string(forType: .string) == "sentinel")
    }

    /// "Open in Mail" is exactly the U3-B road beneath the choice: the
    /// door's own `SupportMail.open`, here over the recording roads.
    @Test func openInMailTakesTheDoorsOwnRoadAndCopiesNothing() async {
        let roads = RecordingRoads()
        let pasteboard = privatePasteboard()
        let versions = SupportDraft.Versions(app: "0.9.1", build: "4935", os: "macOS 27.0 (26A428)")
        let answer = await SupportMail.ask(
            .feedback, choose: { _ in .openInMail }, roads: roads, pasteboard: pasteboard
        ) {
            SupportMail.open(.feedback(versions), roads: roads) { _ in }
        }
        #expect(answer == .openedInMail(.mailto), "feedback's default-mail-app road, (a)")
        #expect(roads.opened.count == 1 && roads.opened.first?.scheme == "mailto")
        #expect(pasteboard.string(forType: .string) == "sentinel")
    }

    @Test func copyTheAddressPutsTheAddressOnThePasteboardAndOpensNoDraft() async {
        let roads = RecordingRoads()
        let pasteboard = privatePasteboard()
        var mailRoadRan = false
        let answer = await SupportMail.ask(
            .feedback, choose: { _ in .copyAddress }, roads: roads, pasteboard: pasteboard
        ) {
            mailRoadRan = true
            return .mailto
        }
        #expect(answer == .copiedAddress(revealed: nil))
        #expect(pasteboard.string(forType: .string) == "support@stargazing.tech")
        #expect(pasteboard.pasteboardItems?.count == 1, "cleared, then set — the address alone")
        #expect(!mailRoadRan, "no draft on this road")
        #expect(roads.composed.isEmpty && roads.opened.isEmpty && roads.revealed.isEmpty,
                "feedback has no file to show")
    }

    @Test func showTheFileAndCopyTheAddressRevealsTheReportsOwnFile() async {
        let roads = RecordingRoads()
        let pasteboard = privatePasteboard()
        var mailRoadRan = false
        let answer = await SupportMail.ask(
            .report(file: reportFile), choose: { _ in .copyAddress }, roads: roads,
            pasteboard: pasteboard
        ) {
            mailRoadRan = true
            return .composeWithAttachment
        }
        #expect(answer == .copiedAddress(revealed: reportFile))
        #expect(pasteboard.string(forType: .string) == "support@stargazing.tech")
        #expect(roads.revealed == [reportFile], "the report's own file, shown in Finder")
        #expect(!mailRoadRan && roads.composed.isEmpty && roads.opened.isEmpty,
                "no draft and no mail app on this road")
    }

    // MARK: The doors — BOTH ask before any draft opens (red on the old shape)

    private func ownerWithOneReport(_ name: String) throws -> (CrashReporting, CrashReport) {
        let suite = "19f.door.\(name)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        let store = CrashReportStore(directory: FileManager.default.temporaryDirectory
            .appendingPathComponent("19f-door-\(name)-\(UUID().uuidString)"))
        store.save(Data(CrashReportFixture.json.utf8), receivedAt: Date())
        let owner = CrashReporting(
            defaults: defaults, registration: RecordingRegistration(), store: store)
        owner.set(true)
        let report = try #require(owner.reports.first)
        return (owner, report)
    }

    /// Settings ▸ Diagnostics' Send Report…, pressed: the question is on
    /// screen and NOTHING has opened — no compose, no `mailto:`, no Finder,
    /// no copy. The old door composed at the press. Then "Open in Mail"
    /// takes exactly the U3-B road with the report's own file attached.
    @Test func theReportDoorAsksBeforeAnyDraftOpens() async throws {
        let (owner, report) = try ownerWithOneReport("asks")
        let roads = RecordingRoads()
        roads.composeAvailable = true
        let pasteboard = privatePasteboard()
        let asking = SupportChoiceAsk()
        let pane = DiagnosticsPane(
            crashReports: owner, roads: roads, pasteboard: pasteboard, choose: asking.ask)

        pane.send(report)
        await poll { asking.pending != nil }
        #expect(asking.pending?.question == .report(file: report.url),
                "the report's question, carrying the report's own file")
        #expect(roads.composed.isEmpty && roads.opened.isEmpty && roads.revealed.isEmpty,
                "nothing opens before her answer")
        #expect(pasteboard.string(forType: .string) == "sentinel")

        asking.answer(.openInMail)
        await poll { !roads.composed.isEmpty }
        #expect(roads.composed.count == 1)
        #expect(roads.composed.first?.attachment == report.url, "the U3-B road, unchanged")
        #expect(pasteboard.string(forType: .string) == "sentinel", "Open in Mail copies nothing")
    }

    /// The report door's second road: the file shown in Finder and the
    /// address on the pasteboard — and NO draft, so no mail app is needed.
    @Test func theReportDoorsSecondRoadShowsTheFileAndCopiesTheAddress() async throws {
        let (owner, report) = try ownerWithOneReport("copies")
        let roads = RecordingRoads()
        roads.composeAvailable = true
        let pasteboard = privatePasteboard()
        let asking = SupportChoiceAsk()
        DiagnosticsPane(
            crashReports: owner, roads: roads, pasteboard: pasteboard, choose: asking.ask
        ).send(report)
        await poll { asking.pending != nil }
        #expect(roads.composed.isEmpty && roads.opened.isEmpty && roads.revealed.isEmpty)

        asking.answer(.copyAddress)
        await poll { !roads.revealed.isEmpty }
        #expect(roads.revealed == [report.url], "the report's own file, in Finder")
        #expect(pasteboard.string(forType: .string) == "support@stargazing.tech")
        #expect(roads.composed.isEmpty && roads.opened.isEmpty, "no draft on this road")
    }

    /// Cancel on the report door's question: nothing at all happens.
    @Test func aDismissedReportQuestionOpensNothing() async throws {
        let (owner, report) = try ownerWithOneReport("dismissed")
        let roads = RecordingRoads()
        roads.composeAvailable = true
        let pasteboard = privatePasteboard()
        let asking = SupportChoiceAsk()
        DiagnosticsPane(
            crashReports: owner, roads: roads, pasteboard: pasteboard, choose: asking.ask
        ).send(report)
        await poll { asking.pending != nil }
        #expect(asking.pending != nil, "the door asked")
        asking.answer(nil)
        for _ in 0..<20 { await Task.yield() }
        #expect(roads.composed.isEmpty && roads.opened.isEmpty && roads.revealed.isEmpty)
        #expect(pasteboard.string(forType: .string) == "sentinel")
    }

    /// Help ▸ Send Feedback… (a `Commands` door — read from its source, the
    /// SupportDraftTests precedent for this very door): its act ASKS the
    /// feedback question — of the window, or with no window the app-modal
    /// ask — and its one mail road, `SupportMail.open(.feedback(.thisMac()))`
    /// (the U3-B act, verbatim), sits INSIDE the question's Open in Mail
    /// road. The old act opened the draft at the press.
    @Test func theHelpDoorAsksBeforeItsDraftOpens() throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Variorum/EditorCommands.swift")
        let file = try String(contentsOf: url, encoding: .utf8)
        let start = try #require(file.range(of: "private func sendFeedback() {"))
        let rest = file[start.upperBound...]
        let end = try #require(rest.range(of: "\n    }\n"), "the act's closing brace")
        let act = String(rest[..<end.lowerBound])

        let ask = try #require(act.range(of: "SupportMail.ask(.feedback"),
                               "the Help door asks the feedback question")
        let open = try #require(act.range(of: "SupportMail.open(.feedback(.thisMac()))"))
        #expect(ask.lowerBound < open.lowerBound,
                "the draft opens only on the question's Open in Mail road")
        #expect(act.components(separatedBy: "SupportMail.open(").count == 2,
                "exactly one mail road in the act — the one inside the question")
        #expect(act.contains("supportChoice"), "asked of the window (the shell's channel)")
        #expect(act.contains("SupportChoiceModal.ask"), "with no window, the app-modal ask")
    }

    // MARK: The questions (her words)

    @Test func theTwoQuestionsCarryHerWords() {
        let feedback = SupportQuestion.feedback
        #expect(feedback.openInMail == "Open in Mail")
        #expect(feedback.copyAddress == "Copy the address")
        #expect(feedback.file == nil, "the feedback door's shape, minus the file")

        let report = SupportQuestion.report(file: reportFile)
        #expect(report.openInMail == "Open in Mail")
        #expect(report.copyAddress == "Show the file and copy the address")
        #expect(report.file == reportFile)

        for question in [feedback, report] {
            #expect(question.detail.contains("support@stargazing.tech"))
            #expect(question.detail.contains("Nothing is sent until you send it."))
            #expect(!question.title.isEmpty)
        }
        #expect(report.detail.contains("attached") && report.detail.contains("Finder"))
        #expect(SupportCopy.copiedAddress.contains("support@stargazing.tech"))
        #expect(SupportCopy.copiedAddressShowingFile("crash-report-x.json")
            .contains("crash-report-x.json"))
    }
}

/// How many times a door's mail road ran (a box a `Task` may capture).
@MainActor
final class RanCount {
    var count = 0
}
