//
//  VX176LibraryTintTests.swift
//  VariorumTests (Mac)
//
//  **VX-176 (the VX-348 run, U3) — the Library's segmented controls draw in
//  the VOICE's accent.** Observed at the 13n-c UX walk (W-UX-11's
//  out-of-scope note, 2026-10-11): the Library's scope and mode segmented
//  controls kept the SYSTEM accent (blue) in dark Terminal while every MCP
//  face and Settings' scene tint with the voice. THE MECHANISM: SwiftUI hands
//  a segmented picker's selected-segment colour to AppKit as the control's
//  `selectedSegmentBezelColor` FROM THE TINT — measured headless (a segmented
//  `Picker` under `.tint(x)` reads x there; with no tint it reads nil, the
//  system's own accent) — and nothing on the Library's road set a tint (only
//  Settings' scene and the MCP sheets do). THE FIX: `.tint(tokens.accent)` at
//  the catalog's root, the panes' own idiom.
//
//  THE PIN, RED ON OLD BY BEHAVIOUR (pre-fix APIs only): the real catalog
//  mounted in a dark (and a light) window, both voices; both of the row's
//  `NSSegmentedControl`s carry a selected-segment colour equal to the voice's
//  accent. Before: nil (the system blue).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-176 — the Library's segmented controls wear the voice's accent", .serialized)
struct VX176LibraryTintTests {
    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private static func settle(_ window: NSWindow, _ hosting: NSView, _ seconds: TimeInterval) async {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    private static func segmentedControls(in view: NSView) -> [NSSegmentedControl] {
        var found: [NSSegmentedControl] = []
        func walk(_ view: NSView) {
            if let control = view as? NSSegmentedControl { found.append(control) }
            for sub in view.subviews { walk(sub) }
        }
        walk(view)
        return found
    }

    private static func components(_ color: NSColor?) -> [CGFloat]? {
        guard let rgb = color?.usingColorSpace(.sRGB) else { return nil }
        return [rgb.redComponent, rgb.greenComponent, rgb.blueComponent]
    }

    @Test(arguments: [(ThemeVoice.terminal, true), (.study, true), (.terminal, false), (.study, false)])
    func theScopeAndModeControlsWearTheVoicesAccent(voice: ThemeVoice, dark: Bool) async throws {
        #if DEBUG
        let db = try AppDatabase.inMemory()
        let suite = "vx176-tint-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 176))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            for index in 0..<3 {
                let note = try session.operations.createPost(title: "A note \(index)")
                _ = try session.operations.newBlock(in: note.id, text: "words \(index)")
            }
            try session.operations.setThemeVoice(voice)
            let theme = ThemeStore(session: session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            await model.search()
            LibraryPanelOracle.reset()

            let window = NSWindow(
                contentRect: NSRect(x: 40, y: 40, width: 1029, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
            let hosting = NSHostingView(rootView: AnyView(
                LibraryCatalogView(
                    session: session, model: model, library: LibraryViewModel(session: session),
                    tags: TagsViewModel(session: session), onOpen: { _ in })
                .environment(theme)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1029, height: 700)
            window.contentView = hosting
            window.orderFrontRegardless()
            defer {
                window.orderOut(nil)
                window.contentView = nil
                window.close()
            }
            await Self.settle(window, hosting, 1.2)

            let accent = try #require(Self.components(NSColor(theme.tokens(for: dark ? .dark : .light).accent)))
            let controls = Self.segmentedControls(in: hosting)
            #expect(controls.count == 2, "\(voice) \(dark ? "dark" : "light"): the row's two segmented controls (\(controls.count))")
            for control in controls {
                let label = control.label(forSegment: 0) ?? "?"
                let bezel = Self.components(control.selectedSegmentBezelColor)
                print("[VX-176 tint] \(voice) · \(dark ? "dark" : "light") · \(label) · bezel \(String(describing: bezel)) · accent \(accent)")
                let drawn = try #require(bezel,
                    "\(voice) \(dark ? "dark" : "light"): \(label)'s selected segment draws the SYSTEM accent (no colour of the voice's)")
                #expect(zip(drawn, accent).allSatisfy { abs($0 - $1) < 0.02 },
                        "\(voice) \(dark ? "dark" : "light"): \(label)'s selected segment \(drawn) is the voice's accent \(accent)")
            }
        }
        #endif
    }
}
