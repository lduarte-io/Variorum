//
//  ShellConfirmTests.swift
//  VariorumTests
//
//  13u4 UNIT S3 — **KnownIssues row 67: `Help ▸ Restore Tutorial…` confirmed
//  through an AppKit modal while every other confirm in the app is a SwiftUI
//  `.alert`.** The act holds no view, which is why the alert lived inside it;
//  so it ASKS the shell (`ShellRouter.ask`) and the window presents, in the
//  grammar its siblings already use — `pendingSelection`'s own shape, and
//  P-4's: the door names what it wants, the window decides what that means.
//
//  **Why the road change is worth pinning rather than just walking:** an
//  app-modal `NSAlert.runModal()` in a headless test host WAITS FOREVER —
//  the tutorial's own insurance pin hung the spine exactly that way once, and
//  `structuralUndo`'s doc carries the warning to this day. So the old road
//  was not merely inconsistent chrome: it was unpinnable by construction.
//  The `pendingConfirm` channel is a fact a test can read, which is what
//  makes the tutorial door's confirm drivable below WITHOUT the injectable
//  seam — something the pre-fix tree could not do at all (so these are the
//  "product row" shape of red-on-old: the old tree cannot run them, and it
//  cannot run them for the defect's own reason).
//

import Foundation
import Testing
import Dependencies
import VariorumCore
@testable import Variorum

@Suite("The shell's confirm channel (13u4 UNIT S3, row 67)", .serialized)
@MainActor
struct ShellConfirmTests {
    private func poll(_ condition: @MainActor () -> Bool) async {
        for _ in 0..<400 {
            if condition() { return }
            await Task.yield()
            try? await Task.sleep(nanoseconds: 3_000_000)
        }
    }

    @Test func askPublishesTheQuestionAndTheAnswerResumesTheCaller() async {
        let router = ShellRouter()
        let asked = Task { @MainActor in
            await router.ask(
                question: "Replace it?", detail: "Everything of this kind goes.",
                verb: "Replace", destructive: true)
        }
        await poll { router.pendingConfirm != nil }
        let pending = router.pendingConfirm
        #expect(pending?.question == "Replace it?")
        #expect(pending?.detail == "Everything of this kind goes.")
        #expect(pending?.verb == "Replace")
        #expect(pending?.destructive == true)

        router.answerPendingConfirm(true)
        #expect(router.pendingConfirm == nil, "answering clears it in the same act")
        #expect(await asked.value == true)
    }

    /// Dismissal is an ANSWER, never a silence — nothing may be left awaiting
    /// a question that is no longer on screen. (The window's binding setter
    /// calls exactly this.)
    @Test func dismissingTheAlertIsADecline() async {
        let router = ShellRouter()
        let asked = Task { @MainActor in
            await router.ask(question: "Q", detail: "D", verb: "Do it")
        }
        await poll { router.pendingConfirm != nil }
        router.answerPendingConfirm(false)
        #expect(await asked.value == false)
    }

    /// A second question answers the first with `false` rather than
    /// abandoning its continuation — the double-press road.
    @Test func aSecondAskDeclinesTheFirstRatherThanStrandingIt() async {
        let router = ShellRouter()
        let first = Task { @MainActor in
            await router.ask(question: "First", detail: "D", verb: "Go")
        }
        await poll { router.pendingConfirm?.question == "First" }
        let second = Task { @MainActor in
            await router.ask(question: "Second", detail: "D", verb: "Go")
        }
        await poll { router.pendingConfirm?.question == "Second" }
        #expect(await first.value == false, "the first was answered, not stranded")
        router.answerPendingConfirm(true)
        #expect(await second.value == true)
    }

    /// Answering twice cannot resume a continuation twice (which would trap):
    /// the answer and the clear are one act.
    @Test func answeringTwiceIsSafe() async {
        let router = ShellRouter()
        let asked = Task { @MainActor in
            await router.ask(question: "Q", detail: "D", verb: "Go")
        }
        await poll { router.pendingConfirm != nil }
        router.answerPendingConfirm(true)
        router.answerPendingConfirm(false)
        router.answerPendingConfirm(true)
        #expect(await asked.value == true)
        #expect(router.pendingConfirm == nil)
    }

    /// **THE ROW, end to end:** the tutorial's replace door asks through the
    /// shell — driven with NO injectable seam, which is the thing the AppKit
    /// modal made impossible — and a decline leaves her store exactly as it
    /// was.
    @Test func theTutorialsReplaceDoorAsksThroughTheShellAndADeclineChangesNothing() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let bookID = try await TutorialSeeder.restore(session: session)
            let router = ShellRouter()
            let actions = ShellActions(session: session, shell: router)

            actions.restoreTutorial()  // no `confirm:` seam — the real road
            await poll { router.pendingConfirm != nil }
            let pending = try #require(router.pendingConfirm, "the door asked the shell")
            #expect(pending.question == TutorialSeeder.replaceQuestion,
                    "the same question the modal asked, word for word")
            #expect(pending.detail == TutorialSeeder.replaceDetail)
            #expect(pending.verb == "Replace")
            #expect(pending.destructive, "a wholesale replace is destructive")

            router.answerPendingConfirm(false)
            await poll { !session.tutorialDoorInFlight }
            let stillThere = try await db.read { try Queries.reading($0, id: bookID) != nil }
            #expect(stillThere, "a decline replaced nothing")
        }
    }
}
