//
//  AppMenuServicesTests.swift
//  VariorumTests
//
//  VX-220 — her words: the app menu's Services submenu is clutter ("open in
//  finder, change to chinese, system trace, etc."); confirmed 2026-10-13 as
//  the macOS app-menu Services submenu, not a Settings pane. Variorum
//  registers no services of its own, so every entry there is the system's.
//
//  THE MECHANISM: SwiftUI's default app menu carries the `.systemServices`
//  command group — a "Services" item whose submenu AppKit fills from every
//  installed service provider (`NSApp.servicesMenu`). Nothing in
//  `EditorCommands` replaced that group, so it shipped.
//
//  The test host runs the real app, menu included (the FindAndReplaceTests
//  precedent), so this reads the menu she sees.
//

import AppKit
import Testing
@testable import Variorum

@MainActor
@Suite("The app menu carries no Services submenu (VX-220)")
struct AppMenuServicesTests {
    private func appMenu() throws -> NSMenu {
        let mainMenu = try #require(NSApp.mainMenu, "the test host runs the real app, menu included")
        return try #require(mainMenu.items.first?.submenu, "the app menu exists")
    }

    private func describe(_ menu: NSMenu) -> String {
        menu.items.map { item in
            item.isSeparatorItem ? "————" : item.title + (item.submenu == nil ? "" : " ▸")
        }.joined(separator: " | ")
    }

    @Test func theAppMenuCarriesNoServicesSubmenu() throws {
        let menu = try appMenu()
        print("VX-220 app menu: \(describe(menu))")
        let services = menu.items.filter { item in
            guard let submenu = item.submenu else { return false }
            return submenu === NSApp.servicesMenu || item.title == "Services"
        }
        #expect(services.isEmpty,
                "the app menu carries no Services submenu (saw: \(describe(menu)))")
    }

    /// The guard (green on old and new): whatever leaves the menu leaves no
    /// doubled, leading or trailing separator behind it.
    @Test func theAppMenuHasNoDoubledOrDanglingSeparators() throws {
        let items = try appMenu().items.filter { !$0.isHidden }
        let menu = try appMenu()
        #expect(items.first?.isSeparatorItem != true, "no leading separator (\(describe(menu)))")
        #expect(items.last?.isSeparatorItem != true, "no trailing separator (\(describe(menu)))")
        for (above, below) in zip(items, items.dropFirst()) {
            #expect(!(above.isSeparatorItem && below.isSeparatorItem),
                    "no two separators in a row (\(describe(menu)))")
        }
    }
}
