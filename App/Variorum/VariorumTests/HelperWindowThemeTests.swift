//
//  HelperWindowThemeTests.swift
//  VariorumTests
//
//  F-FW-2 (the VX-677 run, the fixes unit — `notes/plans/fixes/vx-677-editor-
//  panes-ai-door.md`, FIXES RECORD, F-3; VX-572's own scope) — **the ⌘/ helper
//  WINDOW draws in the open library's voice: under a Study store its
//  descriptions read in Study's face, never Terminal's fallback.**
//
//  The final walk (S-572-1/2, Study): the helper window rendered in TERMINAL's
//  face — mono descriptions, lowercase headings — while the app was in Study.
//  The scene closure built `HelperView()` with no `ThemeStore` in its
//  environment, so the helper read `VoiceTokens.fallback` (Terminal). Batch 4's
//  face pin (`ShortcutsTabFaceTests`) stayed green because it hands the TAB its
//  tokens itself; this suite mounts the WINDOW's ROOT exactly as the app's
//  scene hosts it (`HelperSceneContent(state:)`, the one line in
//  `VariorumApp`'s `Window("Shortcuts & Dictionary")` — the source guard below
//  holds that line) over a real session whose voice is Study, and reads what
//  the mounted helper DREW in through its DEBUG pin door (`HelperViewOracle` —
//  in-process SwiftUI builds no accessibility tree to read a face from).
//
//  **THE PIN — RED on the pre-fix tree** (the seam commit: the content is the
//  bare `HelperView()`, no theme reaches it) **and on `vx677-c/revFW2`** (the
//  fix with its one `.environment(theme)` line reverted — the root makes its
//  theme, the helper never gets it); **GREEN on the fix.**
//  GUARDS (green on both): a helper with no open library keeps its fallback
//  face; the app's helper window hosts this content.
//
//  VX-692 (the toolchain's closure merge, F-B3-1): no closure-bearing
//  expression sits inside `#expect`/`#require` here — every closure-bearing
//  read is bound to a local first.
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
@Suite("F-FW-2 — the helper window draws in the open library's voice (the VX-677 run)", .serialized)
struct HelperWindowThemeTests {
    // MARK: - Harness

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated { RunLoop.main.run(until: Date().addingTimeInterval(seconds)) }
    }

    private static func settle(
        _ window: NSWindow, _ hosting: NSView, timeout: TimeInterval = 5,
        until predicate: () -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if predicate() { return true }
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
        return predicate()
    }

    /// Every value of type `T` reachable in `subject`'s stored structure, not
    /// descending into `VoiceTokens` (`ShortcutsTabFaceTests`' walk).
    private static func values<T>(_ type: T.Type, in subject: Any, depth: Int = 0) -> [T] {
        guard depth < 80 else { return [] }
        if subject is VoiceTokens { return [] }
        var found: [T] = []
        if let hit = subject as? T { found.append(hit) }
        for child in Mirror(reflecting: subject).children {
            found += values(type, in: child.value, depth: depth + 1)
        }
        return found
    }

    private static func signature(_ value: Any) -> String {
        var out = ""
        dump(value, to: &out)
        return out
    }

    /// A session over an in-memory store in the given voice; the global
    /// typography a theme store adopts is restored after.
    private func withSession(
        voice: ThemeVoice, _ body: @MainActor (AppSession) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let typography = EditorTypography.current
        let adopted = EditorTypography.isAdopted
        defer {
            EditorTypography.current = typography
            EditorTypography.isAdopted = adopted
        }
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            try session.operations.setThemeVoice(voice)
            try await body(session)
        }
    }

    /// The window's content mounted as the app's helper window hosts it, at
    /// its default size.
    private func mount(_ state: AppBootstrap.State) -> (NSWindow, NSView) {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 760, height: 620),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: HelperSceneContent(state: state))
        hosting.frame = NSRect(x: 0, y: 0, width: 760, height: 620)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    // MARK: - The pin

    /// **The helper WINDOW, under a Study library, draws in Study — its
    /// descriptions in Study's face (Iowan), never the Terminal fallback.**
    @Test func theHelperWindowDrawsItsDescriptionsInTheLibrarysVoice() async throws {
        try await withSession(voice: .study) { session in
            let (window, hosting) = mount(.ready(session))
            defer { window.orderOut(nil); window.close() }

            let drewStudy = await Self.settle(window, hosting) {
                HelperViewOracle.drawnTokens(forSession: session)?.voice == .study
            }
            let drawn = HelperViewOracle.drawnTokens(forSession: session)
            let root = HelperViewOracle.hasRoot(forSession: session)
            let unthemed = HelperViewOracle.lastUnthemed.map { "\($0.voice)" } ?? "nil"
            print("[F-FW-2] root-theme=\(root) drawn=\(drawn.map { "\($0.voice)" } ?? "nil") "
                + "lastUnthemed=\(unthemed)")
            #expect(drewStudy,
                    "the helper window drew in the open library's voice (Study) — not the fallback (\(unthemed))")
            let tokens = try #require(drawn, "the window's root gave the helper its library's theme")

            // The descriptions' face: the row composes the voice's body face,
            // which in Study is Iowan — not the chord column's mono.
            let firstRow = ShortcutCatalog.rows.first
            let row = try #require(firstRow)
            let studyBody = Self.signature(VoiceTokens.studyLight.body)
            let drawnBody = Self.signature(tokens.body)
            let rowFonts = Self.values(Font.self, in: ShortcutRowView(row: row, tokens: tokens).body)
                .map(Self.signature)
            #expect(drawnBody == studyBody, "the description face is Study's")
            #expect(rowFonts.contains(studyBody), "the description column composes Study's face")
            #expect(drawnBody != Self.signature(tokens.mono), "and not the mono")
        }
    }

    // MARK: - Guards

    /// **With no open library there is no voice to read** — the helper keeps
    /// the fallback face it always had (green on both trees).
    @Test func aHelperWithNoOpenLibraryKeepsItsFallbackFace() async throws {
        HelperViewOracle.forgetUnthemed()
        let (window, hosting) = mount(.opening)
        defer { window.orderOut(nil); window.close() }
        let drew = await Self.settle(window, hosting) { HelperViewOracle.lastUnthemed != nil }
        let voice = HelperViewOracle.lastUnthemed?.voice
        let said = voice.map { "\($0)" } ?? "nil"
        #expect(drew, "the helper drew")
        #expect(voice == .terminal, "the fallback face: \(said)")
    }

    /// **The app's helper window hosts this content** — the mounted pin's
    /// premise, held as source: the scene's closure is
    /// `HelperSceneContent(state: bootstrap.state)`, never a bare
    /// `HelperView()` (green on both trees).
    @Test func theAppsHelperWindowHostsItsSceneContent() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let raw = try String(
            contentsOf: root.appending(path: "Variorum/VariorumApp.swift"), encoding: .utf8)
        let code = raw.split(separator: "\n", omittingEmptySubsequences: false)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
            .joined(separator: "\n")
        let opener = "Window(\"Shortcuts & Dictionary\", id: \"variorum-helper\") {"
        let start = try #require(code.range(of: opener), "the helper's Window scene")
        let tail = code[start.upperBound...]
        let close = try #require(tail.firstIndex(of: "}"), "its closure closes")
        let closure = String(tail[..<close])
        #expect(closure.contains("HelperSceneContent(state: bootstrap.state)"), "\(closure)")
        #expect(!closure.contains("HelperView()"), "\(closure)")
    }
}
