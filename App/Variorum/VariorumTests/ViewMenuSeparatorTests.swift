//
//  ViewMenuSeparatorTests.swift
//  VariorumTests
//
//  VX-359 (the VX-283 run's U3 rider, born at U1b's F-3 trace) — the View
//  menu drew TWO hairlines between Close Split and Toggle Sidebar (the U1
//  walk's W9 capture; the walker's AX read: two separators in a row).
//
//  THE MECHANISM (F-3's trace, re-verified on this tip): the note group is
//  `EditorCommands`' `CommandGroup(before: .toolbar)`, and it ENDED with a
//  `Divider()` after Close Split (`07d9f583`, 13f batch 4). The next items
//  belong to OTHER command groups (the system's, then `after: .sidebar`'s
//  Toggle Sidebar · Find Anything… · Switch Wing…), and SwiftUI separates
//  command groups with a separator of its own — so the group's trailing
//  `Divider()` and the boundary's separator drew back to back.
//
//  The test host runs the real app with its real SwiftUI-built main menu
//  (the `AppMenuServicesTests` / `FindAndReplaceTests` precedent), so this
//  reads the View menu she sees. RED ON OLD: the doubled pair after Close
//  Split.
//

import AppKit
import Testing
@testable import Variorum

@MainActor
@Suite("The View menu draws no doubled or dangling separators (VX-359)")
struct ViewMenuSeparatorTests {
    private func viewMenu() throws -> NSMenu {
        let mainMenu = try #require(NSApp.mainMenu, "the test host runs the real app, menu included")
        let menu = try #require(
            mainMenu.items.first { $0.title == "View" }?.submenu, "the View menu exists")
        // As AppKit does before it draws the menu: let its owner rebuild it,
        // then validate (a SwiftUI command menu fills on update).
        menu.delegate?.menuNeedsUpdate?(menu)
        menu.update()
        return menu
    }

    private func describe(_ items: [NSMenuItem]) -> String {
        items.map { item in
            item.isSeparatorItem ? "————" : item.title + (item.submenu == nil ? "" : " ▸")
        }.joined(separator: " | ")
    }

    @Test func theViewMenuHasNoDoubledOrDanglingSeparators() throws {
        // What is DRAWN: a hidden item between two separators still leaves
        // them adjacent on screen, so hidden items are dropped first.
        let items = try viewMenu().items.filter { !$0.isHidden }
        let shown = describe(items)
        print("VX-359 View menu: \(shown)")
        #expect(items.contains { $0.title == CapabilityRegistry.capability(.closeSplit).verb },
                "the read reached the note group (\(shown))")
        #expect(items.first?.isSeparatorItem != true, "no leading separator (\(shown))")
        #expect(items.last?.isSeparatorItem != true, "no trailing separator (\(shown))")
        for (above, below) in zip(items, items.dropFirst()) {
            #expect(!(above.isSeparatorItem && below.isSeparatorItem),
                    "no two separators in a row (\(shown))")
        }
    }
}
