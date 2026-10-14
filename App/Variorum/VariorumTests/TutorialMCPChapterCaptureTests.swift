//
//  TutorialMCPChapterCaptureTests.swift
//  VariorumTests (Mac)
//
//  13n-c U5 — A CAPTURE HARNESS (U1–U4's precedent), gated OFF: the field
//  guide's MCP chapter and the setup menu rendered offscreen in both voices,
//  for when no walk can run (the session was LOCKED at U5's walk; unlocking is
//  hers). These are NOT a walk and the record never calls them one: nothing is
//  pressed, scrolled, copied by a hand or opened — each lesson is drawn by the
//  READ TIER's own face (`ReadPostView`, what the book's Outline shows at
//  rest) over a freshly seeded guide, and the setup menu by its own view
//  (`MCPSetupMenu`) inside the pane's grouped section, once per client and once
//  after a copy (the receipt under the button). Images print as base64 chunks
//  under `[13NC-U5-PNG <name> <part>]`.
//
//  To re-shoot: `TEST_RUNNER_VARIORUM_CAPTURE=13nc-u5 xcodebuild … test
//  -only-testing:VariorumTests/TutorialMCPChapterCaptureTests` under a held stage.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite(
    "13n-c U5 — the MCP chapter + the setup menu, captured (a harness)", .serialized,
    .enabled(if: ProcessInfo.processInfo.environment["VARIORUM_CAPTURE"] == "13nc-u5"))
struct TutorialMCPChapterCaptureTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func withWorld(_ body: @MainActor (AppSession) async throws -> Void) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_790_812_800)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let steps = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(steps) * 60)
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 213))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            session.seededBookMarkIsSet = { _ in false }
            session.markSeededBook = { _ in }
            try await body(session)
        }
    }

    private func startedTheme(_ session: AppSession, voice: ThemeVoice) async throws -> (ThemeStore, Task<Void, Never>) {
        try session.operations.setThemeVoice(voice)
        let theme = ThemeStore(session: session)
        let task = Task { await theme.start() }
        for _ in 0..<100 where theme.settings.voice != voice {
            pump(0.02)
            await Task.yield()
        }
        return (theme, task)
    }

    private func capture<V: View>(_ view: V, size: NSSize, name: String, settle: Int = 60) async {
        let window = NSWindow(
            contentRect: NSRect(origin: NSPoint(x: 40, y: 40), size: size),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.appearance = NSAppearance(named: .aqua)
        defer {
            window.orderOut(nil)
            window.close()
        }
        let hosting = NSHostingView(rootView: view.environment(\.colorScheme, .light))
        hosting.appearance = window.appearance
        hosting.frame = NSRect(origin: .zero, size: size)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        for _ in 0..<settle {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
        guard let rep = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else {
            Issue.record("no bitmap for \(name)")
            return
        }
        hosting.cacheDisplay(in: hosting.bounds, to: rep)
        guard let png = rep.representation(using: .png, properties: [:]) else { return }
        let encoded = png.base64EncodedString()
        var index = encoded.startIndex
        var part = 0
        while index < encoded.endIndex {
            let end = encoded.index(index, offsetBy: 8_000, limitedBy: encoded.endIndex) ?? encoded.endIndex
            print("[13NC-U5-PNG \(name) \(part)] \(encoded[index..<end])")
            index = end
            part += 1
        }
        print("[13NC-U5-PNG-END \(name) \(part)]")
    }

    private func voiceName(_ voice: ThemeVoice) -> String { voice == .study ? "study" : "terminal" }

    /// A lesson as the read tier draws it, under its title (the harness's
    /// label — the book's own card heading is the Outline's, not drawn here).
    private func lessonFace(_ session: AppSession, _ postID: String, title: String, tokens: VoiceTokens) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
                .padding(.horizontal, 8)
            ReadPostView(session: session, postID: postID)
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(width: 680, alignment: .topLeading)
        .background(tokens.room)
    }

    @Test func captureTheChapterAndTheSetupMenu() async throws {
        for voice in [ThemeVoice.study, .terminal] {
            try await withWorld { session in
                let guideID = try await TutorialSeeder.restore(session: session)
                let (theme, task) = try await startedTheme(session, voice: voice)
                defer { task.cancel() }
                let tokens = theme.tokens(for: .light)
                let v = voiceName(voice)

                // 1 — EACH LESSON, as the read tier draws it.
                let ids: [String: String] = try await session.database.read { db in
                    let rows = try Row.fetchAll(
                        db,
                        sql: """
                            SELECT c.id, c.title FROM reading_post rp
                            JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                            WHERE rp.reading_id = ? AND rp.deleted_at IS NULL
                            """,
                        arguments: [guideID])
                    return Dictionary(uniqueKeysWithValues: rows.map { ($0["title"] as String, $0["id"] as String) })
                }
                for (number, title) in TutorialSeeder.mcpLessons.enumerated() {
                    let postID = try #require(ids[title], "\(title) is seeded")
                    await capture(
                        lessonFace(session, postID, title: title, tokens: tokens).environment(theme),
                        size: NSSize(width: 680, height: 900),
                        name: "u5-lesson-\(number + 1)-\(v).png", settle: 80)
                }

                // 2 — THE SETUP MENU (VX-274), in the pane's grouped section:
                // each client chosen, then a copy's receipt under the button.
                let door = MCPDoor(serverAllowed: false)
                // VX-168: a copy mints its key in the library — the door is
                // attached so the copied face shows its receipt.
                door.attach(session: session)
                defer { door.detach() }
                for client in MCPSetupClient.allCases {
                    await capture(
                        Form {
                            Section(MCPPaneCopy.connectSection) {
                                MCPSetupMenu(door: door, client: .constant(client), tokens: tokens)
                            }
                        }
                        .formStyle(.grouped)
                        .environment(theme),
                        size: NSSize(width: 560, height: 520), name: "u5-setup-\(client.rawValue)-\(v).png")
                }
                let pasteboard = NSPasteboard(name: NSPasteboard.Name("variorum-u5-capture-\(UUID().uuidString)"))
                defer { pasteboard.releaseGlobally() }
                await door.copySetupCommand(for: .codex, to: pasteboard)
                await capture(
                    Form {
                        Section(MCPPaneCopy.connectSection) {
                            MCPSetupMenu(door: door, client: .constant(.codex), tokens: tokens)
                        }
                    }
                    .formStyle(.grouped)
                    .environment(theme),
                    size: NSSize(width: 560, height: 520), name: "u5-setup-copied-\(v).png")
            }
        }
    }
}
