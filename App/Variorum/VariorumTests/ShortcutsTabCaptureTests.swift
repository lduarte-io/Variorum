//
//  ShortcutsTabCaptureTests.swift
//  VariorumTests
//
//  VX-572 (the VX-677 run, batch 4) — IN-HOST CAPTURES of the ⌘/ helper's
//  Shortcuts tab for her verdict (taste-adjacent: her sitting screenshots
//  are the before). A SUPPLEMENT to the walker's shots on the real Debug
//  app, which are the evidence of record: the tab at rest, one group open,
//  a search hit — four voice sets, at the helper's default size.
//
//  The PNGs land in the test host's temporary directory
//  (`variorum-vx572-screens/`) AND ride out through the log as chunked base64
//  lines (`[VX-572-PNG <name> <part>] …`) — `BlockHistoryCommitsCaptureTests`'
//  recorded reason (the host's container can be closed to the shell).
//
//  OFF unless asked: it asserts nothing and the base64 would bloat a run's
//  log. To shoot, run it alone with the environment variable handed to the
//  test runner: `TEST_RUNNER_VX677_SHOTS=1 xcodebuild … test-without-building
//  -only-testing:VariorumTests/ShortcutsTabCaptureTests`.
//

import AppKit
import Foundation
import SwiftUI
import Testing
@testable import Variorum

@MainActor
@Suite(
    "VX-572 — shortcuts tab captures", .serialized,
    .enabled(if: ProcessInfo.processInfo.environment["VX677_SHOTS"] != nil,
             "a capture harness — set TEST_RUNNER_VX677_SHOTS=1 to shoot"))
struct ShortcutsTabCaptureTests {
    static let outputDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("variorum-vx572-screens")

    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func capture(
        _ tokens: VoiceTokens, dark: Bool, _ model: ShortcutsTabModel, _ name: String
    ) async {
        let size = NSSize(width: 760, height: 620)
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer { window.orderOut(nil); window.close() }
        let hosting = NSHostingView(rootView:
            ShortcutsTab(tokens: tokens, model: model)
                .frame(width: size.width, height: size.height)
                .background(tokens.surface))
        hosting.frame = NSRect(origin: .zero, size: size)
        window.contentView = hosting
        window.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
        window.makeKeyAndOrderFront(nil)
        for _ in 0..<12 {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            pump()
            try? await Task.sleep(for: .milliseconds(20))
        }
        try? FileManager.default.createDirectory(at: Self.outputDirectory, withIntermediateDirectories: true)
        guard let rep = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else { return }
        hosting.cacheDisplay(in: hosting.bounds, to: rep)
        guard let png = rep.representation(using: .png, properties: [:]) else { return }
        let url = Self.outputDirectory.appendingPathComponent(name)
        try? png.write(to: url)
        print("[VX-572] wrote \(url.path) \(rep.pixelsWide)x\(rep.pixelsHigh)")
        let encoded = png.base64EncodedString()
        var index = encoded.startIndex
        var part = 0
        while index < encoded.endIndex {
            let end = encoded.index(index, offsetBy: 8_000, limitedBy: encoded.endIndex) ?? encoded.endIndex
            print("[VX-572-PNG \(name) \(part)] \(encoded[index..<end])")
            index = end
            part += 1
        }
    }

    @Test func shootTheTabAtRestOpenAndSearching() async {
        let voices: [(String, VoiceTokens, Bool)] = [
            ("study-light", .studyLight, false), ("terminal-light", .terminalLight, false),
            ("study-dark", .studyDark, true), ("terminal-dark", .terminalDark, true),
        ]
        for (name, tokens, dark) in voices {
            await capture(tokens, dark: dark, ShortcutsTabModel(), "vx572-\(name)-1-rest.png")
            await capture(
                tokens, dark: dark, ShortcutsTabModel(expanded: [.takes]),
                "vx572-\(name)-2-takes-open.png")
            let searching = ShortcutsTabModel()
            searching.setQuery("merge")
            await capture(tokens, dark: dark, searching, "vx572-\(name)-3-search-merge.png")
            let chord = ShortcutsTabModel()
            chord.setQuery("cmd shift d")
            await capture(tokens, dark: dark, chord, "vx572-\(name)-4-search-chord.png")
        }
    }
}
