//
//  MobileRootMenuTests.swift
//  VariorumMobileTests
//
//  VM-53 (the VM-47 run, batch 5) — **Settings, reachable from every root and
//  from a note.** The ticket: "only the Shelf has a door to it (Library, Starred
//  and Write have none)". Pinned:
//    · the ⋯ menu's items, as data — Settings, where the shell gave the door;
//      none without one (P-2) — and its act drives the door;
//    · the ⋯ door on EACH root, mounted: on the path line, 44 × 44, in both
//      voices (red on old for Starred and the Library: no door at all); none
//      without the shell's door (P-2);
//    · the mounted shell: the ⋯ on the home root and the gear retired;
//    · a NOTE's door: the note's ⋯ sheet carries Settings, and pressing it opens
//      the Settings sheet over the note, through the whole shell (red on old: no
//      such row).
//  The system menu's rows are not reachable in process (`MobileSurfaceDriver`'s
//  header, measured) — the walk drives the real menu (PROVISIONAL P-47-22).
//

import Dependencies
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("The roots' ⋯ menu and a note's door to Settings (VM-53)", .serialized)
struct MobileRootMenuTests {
    @Test func theMenuCarriesSettingsWhereTheShellGaveTheDoor() {
        #expect(MobileRootMenu.items(settings: nil).isEmpty, "no shell, no door, no item (P-2)")
        let opened = LockIsolated(0)
        let items = MobileRootMenu.items(settings: MobileSettingsDoor { opened.withValue { $0 += 1 } })
        #expect(items.map(\.title) == ["Settings"], "one menu, carrying Settings (today's word)")
        items.first?.act()
        #expect(opened.value == 1, "the item's act is the shell's door")
    }

    private func pathFrame<V: View>(_ surface: HostedSurface<V>, startingWith prefix: String) -> CGRect? {
        surface.visibleElements.first { ($0.accessibilityLabel ?? "").hasPrefix(prefix) }?.accessibilityFrame
    }

    /// The ⋯ on each root's path line: there, 44 × 44, on the path's line.
    @Test func everyRootCarriesTheMenuOnItsPathLine() async throws {
        try await withEditorWorld { session, _ in
            for tokens in [VoiceTokens.terminalLight, .studyLight] {
                let shelfModel = MobileShelfViewModel(session: session)
                let observing = Task { await shelfModel.start() }
                defer { observing.cancel() }
                let door = MobileSettingsDoor {}
                let roots: [(String, AnyView)] = [
                    (tokens.path([MobileStarsModel.pageName]), AnyView(
                        MobileStarredView(
                            stars: MobileStarsModel(session: session), tokens: tokens,
                            tabBar: { EmptyView() }, onOpen: { _ in })
                            .environment(\.mobileSettingsDoor, door))),
                    (tokens.path(["Shelf"]), AnyView(
                        MobileShelfView(
                            model: shelfModel, stars: MobileStarsModel(session: session),
                            quickNote: MobileQuickNoteModel(session: session),
                            tokens: tokens, tabBar: { EmptyView() },
                            onOpenBook: { _ in }, onOpenForWriting: { _ in }, onOpenTrash: {})
                            .environment(\.mobileSettingsDoor, door))),
                    (tokens.path(["Library"]), AnyView(
                        MobileLibraryView(
                            model: MobileLibraryViewModel(session: session),
                            scraps: MobileScrapsModel(session: session),
                            stars: MobileStarsModel(session: session),
                            books: shelfModel, tokens: tokens, tabBar: { EmptyView() },
                            onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
                            .environment(\.mobileSettingsDoor, door))),
                ]
                for (path, root) in roots {
                    try await withHostedSurface(root, size: CGSize(width: 402, height: 852)) { surface in
                        await surface.settle(30)
                        let line = try #require(pathFrame(surface, startingWith: path),
                                                "\(path) — labels were \(surface.visibleLabels)")
                        let menu = try #require(surface.element(labeled: MobileRootMenu.spokenLabel)?.accessibilityFrame,
                                                "the ⋯ on \(path) in \(tokens.voice) — labels were \(surface.visibleLabels)")
                        #expect(menu.width >= 43.5 && menu.height >= 43.5, "\(path)'s ⋯ answers across 44: \(menu)")
                        #expect(abs(menu.midY - line.midY) <= 2, "\(path)'s ⋯ sits on its path line")
                        #expect(menu.maxX <= 402 - 8 + 0.5, "\(path)'s ⋯ stays on the surface: \(menu)")
                    }
                }
            }
        }
    }

    /// P-2: outside a shell (no door handed down) the root draws no ⋯.
    @Test func noShellNoMenu() async throws {
        try await withEditorWorld { session, _ in
            let root = MobileStarredView(
                stars: MobileStarsModel(session: session), tokens: .studyLight,
                tabBar: { EmptyView() }, onOpen: { _ in })
            await withHostedSurface(root) { surface in
                await surface.settle(20)
                #expect(surface.element(labeled: MobileRootMenu.spokenLabel) == nil,
                        "a menu with no item is not drawn — labels were \(surface.visibleLabels)")
            }
        }
    }

    /// The mounted shell: the home root carries the ⋯; the Bookcase's gear is
    /// gone into it (no "Settings" door on a root).
    @Test func theShellsHomeRootCarriesTheMenuAndTheGearIsGone() async throws {
        try await withEditorWorld { session, _ in
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: MobileShellRouter())
            ) { surface in
                await surface.settle(40)
                let menus = surface.visibleElements.filter { $0.accessibilityLabel == MobileRootMenu.spokenLabel }
                #expect(menus.count == MobileShellBand.pages.count,
                        "every root wears the ⋯ (the walk descends all three) — labels were \(surface.visibleLabels)")
                #expect(surface.element(labeled: "Settings") == nil, "the gear retired into the menu")
            }
        }
    }

    /// **A note's own door** (the ticket: Settings "reachable … from a note"): the
    /// note's ⋯ sheet carries Settings; pressing it closes that sheet and the
    /// shell's Settings sheet opens over the note.
    @Test func aNotesActionsOpenSettingsThroughTheWholeShell() async throws {
        try await withEditorWorld { session, _ in
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: MobileShellRouter())
            ) { surface in
                await surface.settle(50)
                #expect(surface.activate(MobileShelfFaces.todayDoorSpoken), "labels were \(surface.visibleLabels)")
                await surface.settle(60)
                #expect(surface.activate(MobileNoteActionsSheet.doorLabel), "labels were \(surface.visibleLabels)")
                await surface.settle(50)
                #expect(surface.activate(MobileNoteActionsSheet.settingsTitle),
                        "the note's ⋯ sheet carries Settings — labels were \(surface.visibleLabels)")
                await surface.settle(80)
                let labels = surface.visibleLabels
                #expect(labels.contains(MobileSettingsView.lookGroupTitle)
                            && labels.contains(MobileSettingsView.appearanceLabel),
                        "the Settings sheet opened over the note — labels were \(labels)")
            }
        }
    }
}
