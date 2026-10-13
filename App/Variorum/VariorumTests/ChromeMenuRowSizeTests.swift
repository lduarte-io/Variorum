import AppKit
import Foundation
import SwiftUI
import Testing
@testable import Variorum

// VX-223 — the small-menu-text CLASS (her reports, 2026-10-13: "very small
// text on Read mode's three-dots dropdown and in Blocks", "several dropdowns
// that are too small that start with three dots", "Lenses dropdown text too
// small"). The mechanism — measured, and recorded in the run record's BATCH
// 3 RECORD: a SwiftUI `Menu` in the borderless style is an `NSPopUpButton`
// underneath, its popped rows draw in the pop-up's font, and that font
// follows the control's SIZE. Every site in her report sits inside a row of
// controls carrying `.controlSize(.mini)`, so the menu inherits mini and its
// rows draw at 9 pt. VX-155 found this on the take card and fixed that one
// site by hand; this suite holds the CLASS.
//
// The per-surface pins live with each host's own mount (Read's index column,
// Blocks, Lenses, a book's Index) and share `ChromeMenuProbe`; this file
// carries the probe and the class lint.

/// Reads every `NSPopUpButton` a mounted surface built — the AppKit control a
/// borderless SwiftUI `Menu` is underneath — and the font size that drives
/// its popped rows (the VX-155 pin's measure, generalised).
@MainActor
enum ChromeMenuProbe {
    static func popUps(in view: NSView) -> [NSPopUpButton] {
        var found: [NSPopUpButton] = []
        if let popUp = view as? NSPopUpButton { found.append(popUp) }
        for sub in view.subviews { found += popUps(in: sub) }
        return found
    }

    /// The point size each pop-up's rows will draw at.
    static func rowSizes(in view: NSView) -> [CGFloat] {
        popUps(in: view).map { $0.font?.pointSize ?? 0 }
    }

    /// The standard menu size — what a popped row should read at.
    static var menuSize: CGFloat { NSFont.systemFontSize(for: .regular) }
}

@Suite("VX-223 — chrome menus pop at menu size (the class)")
struct ChromeMenuRowSizeTests {
    /// **THE CLASS LINT — RED ON OLD.** Every borderless pull-down in the Mac
    /// app is the chrome vocabulary's one component, which pins its own
    /// control size so no host's mini/small can reach its rows. Before the
    /// fix, nine sites in seven files spelled `.menuStyle(.borderlessButton)`
    /// themselves, and every one inside a mini row inherited mini.
    @Test func everyBorderlessPullDownIsTheChromeComponent() throws {
        let app = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
        var offenders: [String] = []
        for folder in ["Variorum", "Shared"] {
            let root = app.appendingPathComponent(folder)
            let files = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)
            while let url = files?.nextObject() as? URL {
                guard url.pathExtension == "swift",
                      url.lastPathComponent != "VoiceControls.swift" else { continue }
                let source = try String(contentsOf: url, encoding: .utf8)
                let count = source.components(separatedBy: ".menuStyle(.borderlessButton)").count - 1
                if count > 0 { offenders.append("\(url.lastPathComponent) ×\(count)") }
            }
        }
        #expect(offenders.isEmpty,
                "borderless pull-downs outside the chrome component: \(offenders.sorted())")
    }

    /// **THE COMPONENT'S ORACLE (the fix's face):** inside a row of mini
    /// controls carrying a small host font — the worst host the class has —
    /// the chrome pull-down pops at menu size AND lays out at exactly the
    /// frame the old inherited-mini menu had, so nothing around a ⋯ moves.
    /// The OLD shape is mounted beside it as the control: its rows pop mini
    /// (the mechanism, measured on both trees).
    @MainActor
    @Test func theComponentPopsAtMenuSizeInAMiniRowAndKeepsTheMiniFrame() async throws {
        let fixed = try await mount(
            HStack(spacing: 2) { ChromePullDown("⋯") { Button("row") {} } }
                .font(.system(size: 11)).controlSize(.mini))
        let old = try await mount(
            HStack(spacing: 2) {
                Menu("⋯") { Button("row") {} }
                    .menuStyle(.borderlessButton).lineLimit(1).fixedSize()
            }
            .font(.system(size: 11)).controlSize(.mini))
        #expect(fixed.rows >= ChromeMenuProbe.menuSize, "the component pops at menu size (\(fixed.rows))")
        #expect(old.rows < ChromeMenuProbe.menuSize, "the control: an inherited mini pops small (\(old.rows))")
        #expect(fixed.size == old.size, "the same frame as the mini control: \(fixed.size) vs \(old.size)")

        // …and with the chevron hidden (the book Index's row ⋯, row 21).
        let fixedBare = try await mount(
            ChromePullDown("⋯", showsIndicator: false) { Button("row") {} }.controlSize(.mini))
        let oldBare = try await mount(
            Menu("⋯") { Button("row") {} }
                .menuStyle(.borderlessButton).menuIndicator(.hidden)
                .lineLimit(1).fixedSize().controlSize(.mini))
        #expect(fixedBare.rows >= ChromeMenuProbe.menuSize)
        #expect(fixedBare.size == oldBare.size, "\(fixedBare.size) vs \(oldBare.size)")
    }

    @MainActor
    private func mount<V: View>(_ view: V) async throws -> (rows: CGFloat, size: CGSize) {
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(x: 0, y: 0, width: 300, height: 60)
        let window = NSWindow(
            contentRect: hosting.frame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = hosting
        defer { window.close() }
        var popUp: NSPopUpButton?
        for _ in 0..<100 {
            hosting.layoutSubtreeIfNeeded()
            popUp = ChromeMenuProbe.popUps(in: hosting).first
            if popUp != nil { break }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
        let found = try #require(popUp, "a borderless menu is an NSPopUpButton underneath")
        return (found.font?.pointSize ?? 0, hosting.fittingSize)
    }
}
