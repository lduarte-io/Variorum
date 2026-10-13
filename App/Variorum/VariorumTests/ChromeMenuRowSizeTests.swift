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
}
