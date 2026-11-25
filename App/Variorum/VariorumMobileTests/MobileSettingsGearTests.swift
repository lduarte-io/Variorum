//
//  MobileSettingsGearTests.swift
//  VariorumMobileTests
//
//  VM-53 (the VM-47 run, batch 5) — **Settings, reachable from every root and
//  from a note** — and VM-255 (the VM-260 run, batch 1a) — **the roots' door is
//  a gear, not a ⋯.** Her words (2026-11-22): "a kebab menu for settings makes
//  less sense than just showing a settings gear." The ⋯ held one item; the gear
//  replaces it outright (S-260-1, PROVISIONAL). MOVED from `MobileRootMenuTests`
//  with the door. Pinned:
//    · the gear on EACH root, mounted: on the top line, 44 × 44, in both voices;
//      none without the shell's door (P-2); its act is the shell's door;
//    · the mounted shell: every root wears the gear and the ⋯ is gone (RED ON
//      OLD: three "More" menus, no "Settings" door on a root);
//    · the gear opens Settings through the whole shell — a plain button, so
//      drivable in process where the system `Menu` was not (RED ON OLD);
//    · a NOTE's door: the note's ⋯ sheet carries Settings, and pressing it opens
//      the Settings sheet over the note, through the whole shell (VM-53's pin,
//      unchanged).
//

import Dependencies
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// The gear's spoken name — a literal, so this file also compiles on the pre-fix
/// tree (the red-on-old run); `MobileTopLineTests` pins the declaration says it.
private let gearLabel = "Settings"

@MainActor
@Suite("The roots' Settings gear and a note's door to Settings (VM-53, VM-255)", .serialized)
struct MobileSettingsGearTests {

    /// The on-window doors of one label.
    private func onWindow<V: View>(_ surface: HostedSurface<V>, _ label: String) -> [NSObject] {
        let window = surface.window.bounds.insetBy(dx: 1, dy: 1)
        return surface.visibleElements.filter {
            $0.accessibilityLabel == label && $0.accessibilityTraits.contains(.button)
                && window.intersects($0.accessibilityFrame)
        }
    }

    /// The gear on each root's top line: there, 44 × 44, on the wing door's line,
    /// on the surface; and pressing it is the shell's door.
    @Test func everyRootCarriesTheGearOnItsTopLine() async throws {
        try await withEditorWorld { session, _ in
            for tokens in [VoiceTokens.terminalLight, .studyLight] {
                let shelfModel = MobileShelfViewModel(session: session)
                let observing = Task { await shelfModel.start() }
                defer { observing.cancel() }
                let opened = LockIsolated(0)
                let door = MobileSettingsDoor { opened.withValue { $0 += 1 } }
                let roots: [(String, AnyView)] = [
                    (MobileStarsModel.pageName, AnyView(
                        MobileStarredView(
                            stars: MobileStarsModel(session: session), tokens: tokens,
                            wingName: WingWords.home, onWingDoor: {},
                            tabBar: { EmptyView() }, onOpen: { _ in })
                            .environment(\.mobileSettingsDoor, door))),
                    ("Bookcase", AnyView(
                        MobileShelfView(
                            model: shelfModel, stars: MobileStarsModel(session: session),
                            quickNote: MobileQuickNoteModel(session: session),
                            tokens: tokens, wingName: WingWords.home, onWingDoor: {},
                            tabBar: { EmptyView() },
                            onOpenBook: { _ in }, onOpenForWriting: { _ in })
                            .environment(\.mobileSettingsDoor, door))),
                    ("Library", AnyView(
                        MobileLibraryView(
                            model: MobileLibraryViewModel(session: session),
                            scraps: MobileScrapsModel(session: session),
                            stars: MobileStarsModel(session: session),
                            books: shelfModel, tokens: tokens,
                            wingName: WingWords.home, onWingDoor: {},
                            tabBar: { EmptyView() },
                            onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
                            .environment(\.mobileSettingsDoor, door))),
                ]
                for (root, view) in roots {
                    try await withHostedSurface(view, size: CGSize(width: 402, height: 852)) { surface in
                        await surface.settle(30)
                        let line = try #require(onWindow(surface, WingWords.home).first?.accessibilityFrame,
                                                "\(root)'s wing door — labels were \(surface.visibleLabels)")
                        let gear = try #require(onWindow(surface, gearLabel).first,
                                                "the gear on \(root) in \(tokens.voice) — labels were \(surface.visibleLabels)")
                        let frame = gear.accessibilityFrame
                        #expect(frame.width >= 43.5 && frame.height >= 43.5, "\(root)'s gear answers across 44: \(frame)")
                        #expect(abs(frame.midY - line.midY) <= 2, "\(root)'s gear sits on its top line")
                        #expect(frame.maxX <= 402 - 8 + 0.5, "\(root)'s gear stays on the surface: \(frame)")
                        #expect(onWindow(surface, "More").isEmpty, "\(root): no ⋯ beside it")
                        let before = opened.value
                        #expect(gear.accessibilityActivate(), "\(root): the gear is a real control")
                        await surface.settle(5)
                        #expect(opened.value == before + 1, "\(root): the gear is the shell's Settings door")
                    }
                }
            }
        }
    }

    /// P-2: outside a shell (no door handed down) the root draws no gear.
    @Test func noShellNoGear() async throws {
        try await withEditorWorld { session, _ in
            let root = MobileStarredView(
                stars: MobileStarsModel(session: session), tokens: .studyLight,
                tabBar: { EmptyView() }, onOpen: { _ in })
            await withHostedSurface(root) { surface in
                await surface.settle(20)
                #expect(surface.element(labeled: gearLabel) == nil,
                        "a door that cannot act is not drawn — labels were \(surface.visibleLabels)")
            }
        }
    }

    /// **RED ON OLD — the mounted shell: every root wears the gear, and the ⋯ is
    /// gone** (the walk descends all three pages: three gears, no "More").
    @Test func theShellsRootsCarryTheGearAndTheMenuIsGone() async throws {
        try await withEditorWorld { session, _ in
            await withHostedSurface(
                MobileShellView(session: session, services: nil, router: MobileShellRouter())
            ) { surface in
                await surface.settle(40)
                let gears = surface.visibleElements.filter {
                    $0.accessibilityLabel == gearLabel && $0.accessibilityTraits.contains(.button)
                }
                #expect(gears.count == MobileShellBand.pages.count,
                        "every root wears the gear — labels were \(surface.visibleLabels)")
                #expect(surface.element(labeled: "More") == nil, "the ⋯ retired into the gear")
            }
        }
    }

    /// **RED ON OLD — the gear opens Settings, through the whole shell.** One
    /// press on the home root's gear, and the Settings sheet is up.
    @Test func theGearOpensSettingsThroughTheWholeShell() async throws {
        try await withEditorWorld { session, _ in
            await withHostedSurface(
                MobileShellView(session: session, services: nil, router: MobileShellRouter())
            ) { surface in
                await surface.settle(40)
                #expect(onWindow(surface, gearLabel).first?.accessibilityActivate() == true,
                        "the home root's gear — labels were \(surface.visibleLabels)")
                await surface.settle(80)
                let labels = surface.visibleLabels
                #expect(labels.contains(MobileSettingsView.lookGroupTitle)
                            && labels.contains(MobileSettingsView.appearanceLabel),
                        "the Settings sheet opened — labels were \(labels)")
            }
        }
    }

    /// **A note's own door** (the ticket: Settings "reachable … from a note"): the
    /// note's ⋯ sheet carries Settings; pressing it closes that sheet and the
    /// shell's Settings sheet opens over the note.
    @Test func aNotesActionsOpenSettingsThroughTheWholeShell() async throws {
        try await withEditorWorld { session, _ in
            await withHostedSurface(
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
