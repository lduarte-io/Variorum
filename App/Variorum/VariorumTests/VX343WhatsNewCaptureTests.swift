//
//  VX343WhatsNewCaptureTests.swift
//  VariorumTests (Mac)
//
//  VX-343 (the VX-913 run, B2) — A CAPTURE HARNESS (VX-281 U1's precedent),
//  gated OFF: the What's New sheet rendered with 0.9.5's ACTUAL notes file,
//  both voices, light. The running app can only ever show ITS OWN version's
//  notes (`WhatsNewLedger.thisAppsVersion` — no road reaches 0.9.5's sheet on
//  a later build), so this is the sheet's face for the fixture. NOT a walk and
//  the record never calls it one: no press, no scroll — only what the face
//  draws at its top. Images print as base64 chunks under
//  `[VX343-PNG <name> <part>]`.
//
//  To shoot: `TEST_RUNNER_VARIORUM_CAPTURE=vx343 xcodebuild … test
//  -only-testing:VariorumTests/VX343WhatsNewCaptureTests` under a held stage —
//  once on the pin's tree (the strays: "first." under the second bullet) and
//  once on the fix's (each bullet whole).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite(
    "VX-343 — What's New with 0.9.5's notes, captured (a harness)", .serialized,
    .enabled(if: ProcessInfo.processInfo.environment["VARIORUM_CAPTURE"] == "vx343"))
struct VX343WhatsNewCaptureTests {
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
                return start.addingTimeInterval(Double(steps))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 343))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    private func startedTheme(_ session: AppSession) async -> (ThemeStore, Task<Void, Never>) {
        let theme = ThemeStore(session: session)
        let task = Task { await theme.start() }
        for _ in 0..<60 {
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
            print("[VX343-PNG \(name) \(part)] \(encoded[index..<end])")
            index = end
            part += 1
        }
        print("[VX343-PNG-END \(name) \(part)]")
    }

    @Test func captureZeroNineFivesNotesInBothVoices() async throws {
        let notes = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent("Variorum/Features/WhatsNew/ReleaseNotes-0.9.5.md"),
            encoding: .utf8)
        for voice in [ThemeVoice.study, .terminal] {
            try await withWorld { session in
                try session.operations.setThemeVoice(voice)
                let (theme, task) = await startedTheme(session)
                defer { task.cancel() }
                await capture(
                    WhatsNewSheet(version: "0.9.5", notes: notes, onClose: {}).environment(theme),
                    size: NSSize(width: 520, height: 560),
                    name: "vx343-095-\(voice == .study ? "study" : "terminal").png")
            }
        }
    }
}
