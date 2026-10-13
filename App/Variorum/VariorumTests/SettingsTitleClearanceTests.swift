//
//  SettingsTitleClearanceTests.swift
//  VariorumTests
//
//  VX-225 — her ruling (2026-10-13), verbatim: "why don't we just make the
//  pane on the left a little wider? the overlap is always the same amount
//  and it's not big. that would make the issue invisible since we can't
//  find out why it's happening."
//
//  On her Mac the Settings window's title ("Variorum Settings", leading-
//  aligned after the traffic lights since Tahoe) runs a few points past the
//  leading column's edge while the titlebar's backing stops at that edge.
//  The backing's behaviour is UNEXPLAINED (it never reproduced on the dev
//  build); this is her ruled cosmetic guarantee, not a traced fix: the
//  column must clear the RELEASE title with room to spare.
//
//  THE ORACLE: the real `Settings {}` window, opened in the test host
//  through the app menu's own Settings… item; the live title field's
//  origin and font; the release title measured in that font. The test host
//  is the Debug app, whose own title ("Variorum Dev Settings") is longer —
//  the RELEASE string is what ships.
//

import AppKit
import Testing
@testable import Variorum

@MainActor
@Suite("Settings — the leading column clears the window title (VX-225)", .serialized)
struct SettingsTitleClearanceTests {
    /// What the Release build's Settings window is titled.
    static let releaseTitle = "Variorum Settings"
    /// The clearance past the title's last glyph — the same breathing room
    /// the titlebar leaves between the traffic lights and the title.
    static let clearance: CGFloat = 16
    /// The column's width before VX-225.
    static let oldSidebarWidth: CGFloat = 196

    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settingsWindow() -> NSWindow? {
        NSApp.windows.first { $0.identifier?.rawValue == "com_apple_SwiftUI_Settings_window" }
    }

    /// The app menu's own Settings… item — the door she uses.
    private func openSettings() throws -> NSWindow {
        let appMenu = try #require(NSApp.mainMenu?.items.first?.submenu, "the app menu exists")
        let index = try #require(
            appMenu.items.firstIndex { $0.title.hasPrefix("Settings") }, "Settings… is in the app menu")
        appMenu.performActionForItem(at: index)
        for _ in 0..<100 {
            pump()
            if let window = settingsWindow(), window.isVisible { return window }
        }
        return try #require(settingsWindow(), "the Settings window opened")
    }

    /// The titlebar's title field — the text field showing the window title.
    private func titleField(in window: NSWindow) -> NSTextField? {
        func find(_ view: NSView) -> NSTextField? {
            if let field = view as? NSTextField, field.stringValue == window.title { return field }
            for sub in view.subviews { if let hit = find(sub) { return hit } }
            return nil
        }
        return window.contentView?.superview.flatMap(find)
    }

    @Test func theLeadingColumnClearsTheReleaseTitleWithRoomToSpare() throws {
        let window = try openSettings()
        defer {
            window.close()
            for _ in 0..<10 { pump() }
        }
        for _ in 0..<20 { pump() }
        let field = try #require(titleField(in: window), "the titlebar's title field (\(window.title))")
        let attributes = field.attributedStringValue.length > 0
            ? field.attributedStringValue.attributes(at: 0, effectiveRange: nil)
            : [.font: field.font ?? NSFont.titleBarFont(ofSize: 0)]
        let origin = field.convert(field.bounds, to: nil).minX
        let liveWidth = NSAttributedString(string: window.title, attributes: attributes).size().width
        let releaseWidth = NSAttributedString(string: Self.releaseTitle, attributes: attributes).size().width
        let releaseEnd = origin + releaseWidth
        print("VX-225 title field origin=\(origin) font=\(String(describing: attributes[.font])) "
              + "live(\(window.title))=\(origin + liveWidth) release(\(Self.releaseTitle))=\(releaseEnd) "
              + "window=\(window.frame.size) column=\(AppSettingsView.sidebarWidth)")

        #expect(releaseEnd + Self.clearance <= AppSettingsView.sidebarWidth,
                """
                the leading column clears the release title with \(Self.clearance) pt to spare \
                (title ends at \(releaseEnd); column \(AppSettingsView.sidebarWidth))
                """)
        // Non-vacuity: the oracle tells the old width from the new one.
        #expect(releaseEnd + Self.clearance > Self.oldSidebarWidth,
                "the 196-pt column did NOT clear it — her bleed's geometry")
        // The window grew by exactly the column's delta: the detail column,
        // where every pane was laid out, keeps its width.
        #expect(window.frame.width == AppSettingsView.contentSize.width,
                "the real window is the declared content width (\(window.frame.width))")
        #expect(AppSettingsView.contentSize.width - AppSettingsView.sidebarWidth - 1 == 523,
                "the detail column stays 523 pt — 720 − 196 − the hairline, as it was")
    }
}
