//
//  QuitDoorTests.swift
//  VariorumTests
//
//  13g batch 5 — the kickoff sweep's SECOND trace (the KnownIssues row
//  "Windowless launch (the openApplication path) + quit-from-windowless
//  hangs"). These are CHARACTERIZATION pins, not a fix: they record what
//  the app's own quit door decides in each state, so the next session
//  reading the row does not have to re-derive it — and so a change that
//  makes the door unconditionally asynchronous is caught.
//
//  What they establish, and it is a RULED-OUT candidate for the reported
//  quit hang: in the windowless-LAUNCH state — no window ever presented,
//  therefore `RootView.onAppear` never ran, therefore no session on the
//  delegate, and in any case no post opened and so no autosave coordinator
//  registered — `applicationShouldTerminate` returns `.terminateNow`
//  SYNCHRONOUSLY. It spawns no Task and awaits nothing, so it cannot be
//  what leaves such a process alive.
//
//  What the door DOES take asynchronously (`.terminateLater`, replying from
//  a Task with no deadline) is the state where a post has been opened — the
//  registry gains one entry per opened post, in `AppSession.autosave(forPost:)`.
//  That branch is asserted here by its PRECONDITION only: driving it would
//  call `NSApp.reply(toApplicationShouldTerminate:)` inside the test host,
//  and a pin must not be able to quit the runner.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@Suite("The quit door's decision (13g batch 5 — the windowless-launch trace)")
@MainActor
struct QuitDoorTests {
    /// The windowless-LAUNCH state exactly: nothing ever presented a window,
    /// so `RootView.onAppear` never handed the delegate a session.
    @Test func withNoSessionTheDoorTerminatesNowAndAwaitsNothing() {
        let delegate = VariorumAppDelegate()
        #expect(delegate.session == nil)
        #expect(delegate.applicationShouldTerminate(NSApp) == .terminateNow)
    }

    /// A session that has never opened a post: no active editor, and the
    /// quit registry is empty because entries are registered per OPENED
    /// post. Still synchronous.
    @Test func aSessionThatOpenedNothingStillTerminatesNow() throws {
        let db = try AppDatabase.inMemory()
        try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let delegate = VariorumAppDelegate()
            delegate.session = session

            #expect(session.editorRouter.active == nil)
            #expect(session.quitFinalize.isEmpty,
                    "entries are registered per opened post, not at session birth")
            #expect(delegate.applicationShouldTerminate(NSApp) == .terminateNow)
        }
    }

    /// The asynchronous branch's PRECONDITION — asserted without driving the
    /// door (see the file header). Opening one post is enough to put the quit
    /// door on the `.terminateLater` road, where completion depends on every
    /// registered flush returning; there is no deadline on that wait.
    @Test func openingOnePostPutsTheDoorOnTheAsynchronousRoad() throws {
        let db = try AppDatabase.inMemory()
        try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "T")
            _ = session.autosave(forPost: post.id)

            #expect(!session.quitFinalize.isEmpty,
                    "one entry per opened post — this is what makes ⌘Q asynchronous")
        }
    }
}
