//
//  FreshSidebarWidthTests.swift
//  VariorumTests (Mac)
//
//  VX-737 (the VX-736 run, B2) — her report from a fresh-profile install of
//  1.0: "when i first downloaded the app, the sidebar wasn't wide enough, so
//  'Home' crossed that verticle line"; her road, ruled (R-736-6): "maybe just
//  make the sidebar start out wider".
//
//  THE MECHANISM (traced): the sidebar's fresh width is `ShellSplit
//  .idealWidth`, the `@AppStorage("shellSidebarWidth")` default — the shell is
//  an `HStack` (the Act 10 container), not a `NavigationSplitView`, so neither
//  a split view's column width nor window restoration decides it; only a drag
//  of the seam writes the key, and a written key always wins. The window
//  toolbar's leading items — the traffic lights, the sidebar toggle and New
//  Note's glass group, then the "in ‹wing›" label (VX-552/VX-644) — are laid
//  out by the WINDOW, so they never move with the seam. Measured on the B1
//  walk's captures (2026-11-02, macOS 27.0.1, the dev store, a 1240-pt window
//  with a stored 230-pt sidebar): the label's ink runs 174.5…218.5 pt in
//  Study ("in Home", `w0-w0.png`) and 175.0…222.5 pt in Terminal ("in home",
//  `w2-step01.png`); the column's line sits at 230…231 pt — the line's x IS
//  the sidebar's width, since nothing sits before the column. At the old
//  fresh width (210) the label's words ran 8.5 pt (Study) and 12.5 pt
//  (Terminal) past the line: her screenshot.
//
//  THE PINS: a geometry oracle — the label's words measured offscreen in each
//  voice's own face, placed at the captured origin, its hover wash and 8 pt of
//  air inside the fresh column (RED at 210 in both voices, the watch in the
//  B2 record); the premise that the captured origin still describes the
//  toolbar (its three leading items, in order, the label in the voice's small
//  face); the stored width still winning; and P-736-4 — the window's default
//  grows with the sidebar, so the Library's controls row keeps its measured
//  room (SurfaceContracts, The Library). The live look is the joint window's
//  capture (a fresh profile shape).
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-737 — the fresh sidebar clears the toolbar's wing label")
struct FreshSidebarWidthTests {
    typealias Shell = ShellSplit<EmptyView, EmptyView>

    /// The label's ink in the window, per voice, from the captures named in
    /// the header (x in points from the window's leading edge).
    static let capturedInk: [ThemeVoice: ClosedRange<CGFloat>] = [
        .study: 174.5...218.5,
        .terminal: 175.0...222.5,
    ]

    /// Air between the label's hover wash and the column's line.
    static let air: CGFloat = 8

    /// The label's words as the toolbar draws them (`RootView`'s `.navigation`
    /// item: the wing label's words, the voice's chrome case, its small face),
    /// measured offscreen at their natural width.
    private func wordsWidth(_ voice: ThemeVoice) -> CGFloat {
        let tokens = VoiceTokens.resolve(voice: voice, dark: false)
        let words = Text(tokens.chromeLabel(QuickEntryCopy.wingLabel(WingWords.home)))
            .font(tokens.small)
            .lineLimit(1)
            .fixedSize()
        return NSHostingView(rootView: words).fittingSize.width
    }

    /// **The oracle (RED at 210).** The label's words, placed at the captured
    /// origin, plus the quiet style's hover wash and the air, fit inside the
    /// fresh column in both voices. Conservative by the face's own leading
    /// side bearing (about a point): the words' advance is laid from the
    /// first INK column, not from the text's origin.
    @Test(arguments: [ThemeVoice.study, .terminal])
    func theFreshColumnClearsTheToolbarsWingLabel(voice: ThemeVoice) throws {
        let ink = try #require(Self.capturedInk[voice])
        let words = wordsWidth(voice)
        // Premise: the face measured here is the face the capture drew (its
        // advance within a few points of the drawn ink — a changed font or
        // changed words trips this and asks for a fresh capture).
        #expect(abs(words - (ink.upperBound - ink.lowerBound)) <= 3.5,
                "\(voice): measured \(words) pt against the captured ink's \(ink.upperBound - ink.lowerBound)")
        let wordsEnd = ink.lowerBound + words
        let washEnd = wordsEnd + VoicedButtonStyle.labelInset
        #expect(washEnd + Self.air <= CGFloat(Shell.idealWidth),
                "\(voice): the label's wash ends at \(washEnd) pt; the fresh column's line is at \(Shell.idealWidth)")
    }

    private func source(_ path: String) throws -> String {
        try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent().deletingLastPathComponent()
                .appendingPathComponent("Variorum/\(path)"),
            encoding: .utf8)
    }

    /// The captured origin's premise: the toolbar still leads with exactly
    /// these three `.navigation` items, in this order — the sidebar toggle,
    /// New Note, the wing label in the voice's small face as a quiet voiced
    /// word. An item added before the label moves it, and the capture must be
    /// re-taken.
    @Test func theCapturedOriginStillDescribesTheToolbar() throws {
        let root = try source("RootView.swift")
        let items = root.components(separatedBy: "ToolbarItem(placement: .navigation)")
        #expect(items.count == 4, "three leading items (\(items.count - 1))")
        guard items.count == 4 else { return }
        #expect(items[1].contains("WorkspaceNaming.toggleSidebarVerb"), "first, the sidebar toggle")
        #expect(items[2].contains("Button(\"New Note\", systemImage: \"square.and.pencil\")"), "then New Note")
        let label = String(items[3].prefix(1_200))
        #expect(label.contains("QuickEntryCopy.wingLabel(wings.currentName)"), "then the wing label")
        #expect(label.contains(".font(tokens.small)"), "in the voice's small face")
        #expect(label.contains(".buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))"),
                "a quiet voiced word — its wash is the style's inset")
    }

    /// Restoration wins (R-736-6: "user-resized widths are untouched"): the
    /// column reads the stored key with the fresh width as its DEFAULT only,
    /// and the seam's drag is the one writer.
    @Test func aDraggedWidthStillWins() throws {
        let shell = try source("Workspace/ShellSplit.swift")
        #expect(shell.contains("@AppStorage(Self.widthKey) private var sidebarWidth: Double = Self.idealWidth"))
        #expect(shell.components(separatedBy: "sidebarWidth = ").count == 2, "one writer — the drag")
        #expect(Shell.widthKey == "shellSidebarWidth", "the key a dragged width was stored under")
        #expect(Shell.clamped(Shell.idealWidth) == CGFloat(Shell.idealWidth), "the fresh width is a usable width")
    }

    /// **P-736-4 — the window grows with the sidebar.** The Library's controls
    /// row is one line at the default window with the panel closed by only
    /// about 4 pt in Terminal (`LibraryControlsFlowRuleTests`' in-app widths,
    /// threshold ≈ 977 pt of row). A fresh sidebar 30 pt wider in a 1240-pt
    /// window would have wrapped Terminal's row; so the default window is the
    /// sidebar + its seam + the detail's measured 1029, and the row keeps its
    /// 981 pt.
    @Test func theDefaultWindowGrowsWithTheSidebarSoTheLibraryKeepsItsRoom() throws {
        let detail = Shell.defaultWindowSize.width - CGFloat(Shell.idealWidth) - Shell.dividerWidth
        #expect(detail == Shell.defaultDetailWidth && detail == 1029, "the detail keeps its measured room")
        #expect(Shell.defaultWindowSize == CGSize(width: 1270, height: 840))
        // The row's room: the detail less the header's 24-pt inset either side.
        let row = detail - 2 * 24
        for voice in [ThemeVoice.terminal, .study] {
            #expect(LibraryControlsFlowRule.fitsOneLine(
                LibraryControlsFlowRuleTests.inApp(voice), width: row, spacing: 10),
                "\(voice): one line closed at the default window")
        }
        let unwidened = 1240 - CGFloat(Shell.idealWidth) - Shell.dividerWidth - 2 * 24
        #expect(!LibraryControlsFlowRule.fitsOneLine(
            LibraryControlsFlowRuleTests.inApp(.terminal), width: unwidened, spacing: 10),
            "the reason: a 1240-pt window with the wider column would wrap Terminal's row")
        let app = try source("VariorumApp.swift")
        #expect(app.contains(".defaultSize(ShellSplit<EmptyView, EmptyView>.defaultWindowSize)"),
                "the main window's scene reads the shell's default")
    }
}
