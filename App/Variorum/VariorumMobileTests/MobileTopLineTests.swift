//
//  MobileTopLineTests.swift
//  VariorumMobileTests
//
//  VM-255 (the VM-260 run, batch 1a) — **THE ROOTS' TOP LINE: the wing's name
//  alone, a Settings gear, the trash door only on the Library, the Mac's
//  glyphs for trash and new note.** Her four changes (2026-11-22), verbatim:
//  "I also don't think thte Home * Bookcase and Home * Starred thing is
//  necessary - it says on the bottom what area you're in." · "a kebab menu for
//  settings makes less sense than just showing a settings gear." · "let's just
//  only show the trash icon within library." · "i also don't like the trash
//  bin emoji, it looks out of place. the same trash bin icon the mac usesi s
//  what we should use. new note should also be a writing icon, the way it's a
//  writing icon on the mac app)." Her kickoff rulings: R-260-1 ("bookcase
//  shouldn't have its count on the same line, but it should have its count")
//  and R-260-6 (the count a muted line under the wing's name, the Bookcase
//  only); S-260-1 (the gear replaces the ⋯ outright) and S-260-2 (the Mac's
//  symbol choices) PROVISIONAL.
//
//  A look-class member: what is pinnable is pinned — the line's words (the
//  wing door's value), the trash door's fence, the gear's door (in
//  `MobileSettingsGearTests`), the glyphs' names against the Mac's own source
//  — and the look itself is the walk's captures. Every pin here reads labels
//  and source text only, so it compiles on the pre-fix tree and is RED there.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-255 — the roots' top line", .serialized)
struct MobileTopLineTests {

    /// The doors of one label that are ON the window (the band's other two
    /// roots are in every walk, a screen away).
    private func onWindow<V: View>(_ surface: HostedSurface<V>, _ label: String) -> [NSObject] {
        let window = surface.window.bounds.insetBy(dx: 1, dy: 1)
        return surface.visibleElements.filter {
            $0.accessibilityLabel == label && $0.accessibilityTraits.contains(.button)
                && window.intersects($0.accessibilityFrame)
        }
    }

    private func go<V: View>(_ surface: HostedSurface<V>, _ page: MobileTab) async {
        let word = MobileTabBar.word(page)
        #expect(onWindow(surface, word).first?.accessibilityActivate() == true, "\(word): \(surface.visibleLabels)")
        await surface.settle(40)
    }

    /// **RED ON OLD — the trash door is the Library's alone.** On the mounted
    /// shell: the Bookcase's top line carries none (old: the 🗑 there too), the
    /// Library's carries one, Starred's none.
    @Test func onlyTheLibrarysTopLineCarriesTheTrash() async throws {
        try await withEditorWorld { session, _ in
            await withHostedSurface(
                MobileShellView(session: session, services: nil, router: MobileShellRouter())
            ) { surface in
                await surface.settle(30)
                #expect(onWindow(surface, MobileRecoveryDoors.trashLabel).isEmpty,
                        "the Bookcase carries no trash door — labels \(surface.visibleLabels)")
                await go(surface, .library)
                #expect(onWindow(surface, MobileRecoveryDoors.trashLabel).count == 1, "the Library's one trash door")
                await go(surface, .starred)
                #expect(onWindow(surface, MobileRecoveryDoors.trashLabel).isEmpty, "Starred carries none")
            }
        }
    }

    /// **RED ON OLD — the line is the wing's name alone, on EVERY root, the
    /// Bookcase's included.** On the mounted shell, each root's wing door is
    /// named by the wing ("Home") and its value is the rest of what it draws —
    /// nothing, on all three. MOVED at batch 4a (R-260-11, her words: "i also
    /// don't like the "2 books" under Home. we don't have shelves on here yet,
    /// but eventually each shelves should have the numbers. in the meantime we
    /// just don't need numbers of the books i suppose until the shelves are
    /// added."): the Bookcase's quiet count line under the name ("2 books",
    /// R-260-6) is gone — RED on the batch-4a pre-fix tree, where the
    /// Bookcase's door still says it (one issue). (Before VM-255 the lines read
    /// "Bookcase  ·  2 books", "Library", "Starred" — the page word on the
    /// line.) The door stays one 44 pt line at the default size.
    @Test func theLineIsTheWingsNameAloneOnEveryRoot() async throws {
        try await withEditorWorld { session, _ in
            for name in ["Poems", "Letters"] {
                _ = try await session.runner.run { ops in try ops.createReading(name: name, kind: .book) }
            }
            let router = MobileShellRouter()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(40)
                // Two books stand, so a count line would say "2 books" (the
                // batch-4a pre-fix tree's red): the door says nothing past the name.
                for (page, value) in [
                    (MobileTab.shelf, ""),
                    (.library, ""), (.starred, ""),
                ] {
                    if page != .shelf { await go(surface, page) }
                    let door = try #require(onWindow(surface, WingWords.home).first,
                                            "\(page): the wing door — labels \(surface.visibleLabels)")
                    #expect((door.accessibilityValue ?? "") == value,
                            "\(page): the line says \"\(door.accessibilityValue ?? "")\", not \"\(value)\"")
                    #expect(door.accessibilityFrame.height <= PhoneMetrics.touchMinimum + 0.5,
                            "\(page): the name and its count sit inside the door's one 44 pt line: \(door.accessibilityFrame)")
                    // No page word anywhere on the line: nothing drawn across the
                    // wing door's own band says the page's name (the bar does).
                    let word = MobileTabBar.word(page)
                    let band = door.accessibilityFrame
                    let named = surface.visibleElements.filter {
                        ($0.accessibilityLabel ?? "").localizedCaseInsensitiveContains(word)
                            || ($0.accessibilityValue ?? "").localizedCaseInsensitiveContains(word)
                    }.filter {
                        let frame = $0.accessibilityFrame
                        return surface.window.bounds.intersects(frame)
                            && frame.midY >= band.minY && frame.midY <= band.maxY
                    }
                    #expect(named.isEmpty, "\(page): the top line names the page: \(named.map { $0.accessibilityLabel ?? "" })")
                }
            }
        }
    }

    /// **RED ON OLD — the glyphs are the Mac's own symbols** (S-260-2: the
    /// Mac's SYMBOL choices, never its views). Source text, so the pin reads
    /// the same on both trees: the phone's trash door draws `trash` (the Mac
    /// Library masthead's), the roots' New Note draws `square.and.pencil` (the
    /// Mac toolbar's New Note), the gear draws `gearshape` (the Mac's settings
    /// doors); the 🗑 emoji is gone from the phone's code; and each name is a
    /// real system symbol.
    @Test func theGlyphsAreTheMacsSymbols() throws {
        func code(_ path: String) throws -> String { try MobileProtectionCompositionTests.code(path) }
        // The phone.
        let doors = try code("VariorumMobile/Features/Shell/MobileRecoveryDoors.swift")
        #expect(doors.contains("static let trashSymbol = \"trash\""), "the trash door's symbol")
        #expect(doors.contains("Image(systemName: MobileRecoveryDoors.trashSymbol)"), "…drawn as the door")
        let newNote = try code("VariorumMobile/Features/Shell/MobileTodayDoor.swift")
        #expect(newNote.contains("static let symbol = \"square.and.pencil\""), "the New Note glyph")
        #expect(newNote.contains("Image(systemName: MobileNewNoteDoor.symbol)"), "…drawn as the door")
        let gear = try code("VariorumMobile/Features/Shell/MobileSettingsGear.swift")
        #expect(gear.contains("static let symbol = \"gearshape\""), "the Settings gear")
        #expect(gear.contains("Image(systemName: Self.symbol)"), "…drawn as the door")
        #expect(gear.contains("static let spokenLabel = \"Settings\""), "…named Settings (the pins' word)")
        // The Mac's own choices, as its source states them.
        #expect(try code("Variorum/Features/Library/LibraryCatalogView.swift")
                    .contains("case .trash: return \"trash\""), "the Mac's Library trash door")
        #expect(try code("Variorum/RootView.swift")
                    .contains("Button(\"New Note\", systemImage: \"square.and.pencil\")"), "the Mac's New Note")
        #expect(try code("Variorum/Features/BookView/BookView.swift")
                    .contains("Image(systemName: \"gearshape\")"), "the Mac's settings gear")
        // Real symbols.
        for symbol in ["trash", "square.and.pencil", "gearshape"] {
            #expect(UIImage(systemName: symbol) != nil, "\(symbol) is a system symbol")
        }
        // The emoji is gone from the phone's code (comments may still tell its history).
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("VariorumMobile")
        let walker = try #require(FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil))
        var emoji: [String] = []
        for case let file as URL in walker where file.pathExtension == "swift" {
            let relative = file.path.replacingOccurrences(of: root.path + "/", with: "")
            let source = try code("VariorumMobile/" + relative)
            if source.contains("\u{1F5D1}") || source.contains("\\u{1F5D1}") { emoji.append(relative) }
        }
        #expect(emoji.isEmpty, "the 🗑 emoji is drawn by: \(emoji)")
    }
}
