//
//  IconTooltipTests.swift
//  VariorumTests
//
//  **VX-426 (the VX-439 run, A-439-17) — icon chrome wears a name on hover.**
//  A beta tester (her 10-20 note; her word 2026-10-18: pre-release): hovering
//  the note-face and sidebar icons should say what they are — "Notes & links",
//  "Snippets", "Tray" — because "every time I see the 'Snippets' button my
//  brain thinks it's a copy/paste tool and becomes fearful to press it."
//
//  The class-completeness table lives in the run record
//  (`notes/plans/fixes/vx-439-sidebar-bar-export-quick-wins.md`, "VX-426 — the
//  icon × tooltip table"); this file holds it as data: every icon-only door of
//  the sidebar and the note's face either already OPENED its tooltip with its
//  name or now does (a one-word descriptor and an em dash, then what it did
//  say), and the one door that said nothing on hover (the toolbar's New Note)
//  says the registry's words.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-426 — every icon-only door's tooltip leads with its name")
struct IconTooltipTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
    }

    private static func source(_ path: String) throws -> String {
        try String(contentsOf: appRoot.appending(path: path), encoding: .utf8)
    }

    /// A descriptor in sentence case: her caps rule — no word shouted.
    private func isSentenceCase(_ descriptor: String) -> Bool {
        descriptor.split(separator: " ").allSatisfy { word in
            !(word.count > 1 && word == word.uppercased() && word.contains(where: \.isLetter))
        }
    }

    // MARK: - The doors whose tooltips now lead with their name

    /// The masthead's inspector icons (the tester's "Tray" and "Snippets") and
    /// the book panel's: a one-word name, an em dash, what it opens.
    @Test func theMastheadIconsLeadWithTheirNames() {
        let named = Dictionary(uniqueKeysWithValues: PostDetailView.inspectorDoors.map { ($0.symbol, $0.help) })
        #expect(named["tray"]?.hasPrefix("Tray \u{2014} what this note has set aside") == true)
        #expect(named["square.on.square.dashed"]?.hasPrefix("Snippets \u{2014} ") == true,
                "the scraps door says the area's name, Snippets (W8-1) — never a copy tool")
        #expect(named["books.vertical"]?.hasPrefix("References \u{2014} ") == true)
        #expect(PostDetailView.bookPanelDoor.help.hasPrefix("Book \u{2014} "))
        for door in PostDetailView.shownInspectorDoors(membered: true) {
            let descriptor = door.help.components(separatedBy: " \u{2014} ").first ?? ""
            #expect(!descriptor.isEmpty && descriptor.split(separator: " ").count <= 2 && isSentenceCase(descriptor),
                    "a 1–2 word name in sentence case: \(door.help)")
        }
    }

    /// The context bar's tray badge opens the same Tray; the bottom bars' "Aa"
    /// and "?" glyphs say Formatting and the helper's own name.
    @Test func theBadgeAndTheBottomBarsGlyphsLeadWithTheirNames() {
        #expect(WorkspaceNaming.trayDoorHelp(deleted: 1).hasPrefix("Tray \u{2014} 1 block deleted"))
        #expect(WorkspaceNaming.trayDoorHelp(deleted: 3).hasPrefix("Tray \u{2014} 3 blocks deleted"))
        #expect(FormattingDoor.help(expanded: false).hasPrefix("Formatting \u{2014} "))
        #expect(FormattingDoor.help(expanded: true).hasPrefix("Put the formatting row away"),
                "the open door names its act")
        #expect(HelperCheatSheet.doorHelp.hasPrefix(
            CapabilityRegistry.capability(.helper).menuTitle() + "\n"), "the helper's own words first")
        #expect(HelperCheatSheet.doorHelp.hasSuffix(HelperCheatSheet.summary), "…then the cheat sheet")
    }

    /// Wired where they are drawn: both bottom bars' "?" read the named help,
    /// and the toolbar's New Note — the one icon that said nothing — says ⌘N's
    /// own words, the sidebar toggle's shape.
    @Test func theDoorsAreWiredToTheirNamedTooltips() throws {
        for bar in ["Variorum/Features/Editor/CommitBar.swift", "Variorum/Features/Takes/TakesBottomBar.swift"] {
            let text = try Self.source(bar)
            #expect(text.contains(".help(HelperCheatSheet.doorHelp)"), "\(bar)'s ? door")
            #expect(!text.contains(".help(HelperCheatSheet.summary)"), "\(bar): no nameless cheat sheet left")
        }
        let root = try Self.source("Variorum/RootView.swift")
        let newNote = try #require(root.range(of: "Button(\"New Note\", systemImage: \"square.and.pencil\")"))
        let after = String(root[newNote.upperBound...].prefix(600))
        #expect(after.contains(".help(CapabilityRegistry.capability(.newPost).menuTitle())"))
        #expect(CapabilityRegistry.capability(.newPost).menuTitle() == "New Note (\u{2318}N)")
        // Every icon-only masthead door renders a tooltip.
        let detail = try Self.source("Variorum/Features/Takes/PostDetailView.swift")
        let iconOnly = detail.components(separatedBy: ".labelStyle(.iconOnly)")
        #expect(iconOnly.count >= 2)
        for tail in iconOnly.dropFirst() {
            #expect(tail.prefix(200).contains(".help("), "an icon-only masthead door wears a tooltip")
        }
    }

    // MARK: - The doors that already led with their name (the table's other rows)

    /// A guard over the table's "already names itself" rows — each tooltip
    /// opens with the door's name or its act, so none needed new words.
    @Test func theDoorsThatAlreadyNamedThemselvesStillDo() {
        #expect(WorkspaceNaming.backHelp(origin: "Field Notes").hasPrefix("Back to"))
        #expect(WorkspaceNaming.forwardHelp(destination: "Orbit").hasPrefix("Forward to"))
        #expect(WorkspaceNaming.ascentHelp(topBook: "Orbit", count: 1).hasPrefix("Open \u{201C}Orbit\u{201D}"))
        #expect(WorkspaceNaming.tagFieldHelp(open: false).hasPrefix("Tag this note"))
        #expect(MCPShareCopy.lockHelp.hasPrefix("Private"))
        #expect(StarCopy.rowHelp.hasPrefix("Un-star"))
        #expect(SidebarView.closeRowHelp.hasPrefix("Close this row"))
    }
}
