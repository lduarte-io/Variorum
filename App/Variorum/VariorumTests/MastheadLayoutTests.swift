//
//  MastheadLayoutTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch A — rows 4 + 19: **the masthead title
//  is centered on the masthead's full width in EVERY mode.** Her words: Read
//  "doesn't have a centered title above the read"; Lenses "the title is once
//  again weirdly aligned". The mechanism (walk-confirmed in both voices):
//  the trailing cluster took its natural width and the title centered in the
//  REMAINDER, landing about a third of the way across.
//
//  The pin mounts the real detail, switches it through every mode by the
//  router (⌘1–⌘8's own road), and reads the DEBUG oracle the masthead
//  writes — the title block's midX against the masthead's midX, in the
//  masthead's own coordinate space. RED ON OLD: the old HStack put the title
//  block's midX well left of center (its layer was the leading VStack, which
//  hugged its content; the block's midX sat near a third of the width).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The masthead title centers in every mode (correction round, rows 4/19)", .serialized)
struct MastheadLayoutTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 80
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    @Test func theTitleBlockCentersOnTheMastheadInEveryMode() async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 4))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a centered title")
            _ = try session.operations.newBlock(in: post.id, text: "a block, so every mode can host.")
            _ = try session.operations.newBlock(in: post.id, text: "and a second one.")
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(post.id)")

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
                UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)")
            }
            let hosting = NSHostingView(
                rootView: PostDetailView(session: session, postID: post.id)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: {
                session.commandRouter.activePostID == post.id
            })

            // The oracle is STICKY across modes deliberately: a geometry
            // report fires only when the geometry CHANGES, and a masthead
            // that stays put across a mode switch reports nothing new —
            // which is itself the claim (one layout for every mode). A mode
            // that moved the title would re-report, and the read below
            // would see it.
            for mode in PostMode.allCases {
                #expect(session.commandRouter.requestMode(mode, postID: post.id))
                await settle(window, hosting, until: {
                    session.commandRouter.activeMode == mode
                })
                await settle(window, hosting, until: { false }, maxTurns: 6)
                #if DEBUG
                let title = try #require(MastheadGeometry.titleMidX, "the masthead reported its title in \(mode.rawValue)")
                let content = try #require(MastheadGeometry.contentMidX, "…and its own width")
                #expect(abs(title - content) <= 1,
                        "in \(mode.rawValue) the title block's midX (\(title)) sits on the masthead's midX (\(content)) within 1 pt")
                #endif
            }
        }
    }
}
