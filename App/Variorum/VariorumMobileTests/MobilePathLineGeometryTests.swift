//
//  MobilePathLineGeometryTests.swift
//  VariorumMobileTests
//
//  VM-50 (the VM-47 run, batch 2) — **the roots' top line holds ONE 44 pt line
//  in both voices, and its doors answer across 44 × 44.**
//
//  THE MECHANISM VM-50 FIXED (batch 1's carry-in, traced): batch 1 set the path
//  line's two word doors ("+ New Note", "Settings") at the 17 pt `control` role
//  beside the 13 pt path, and in Terminal (SF Mono) the line wanted ≈437 pt and
//  its path text WRAPPED. VM-50 made the doors the phone's controls with 44 pt
//  hit areas that touch (red on old by behavioural revert, `91d406593` — the
//  run record §6).
//
//  MOVED at VM-255 (the VM-260 run, batch 1a — her four changes): the line is
//  the wing's name ALONE (the wing door), the Bookcase's count a quiet muted
//  line UNDER it inside the door's own 44 (R-260-1, R-260-6); the doors are the
//  Mac's glyphs on the phone's icon buttons — the Library's trash (the
//  Library's ONLY: "only show the trash icon within library"), New Note's
//  writing glyph, the Settings gear (the ⋯ gone). The bounds VM-50 set stand:
//  one 44 pt line at 402 and 430 in both voices, every door 44 × 44 on the wing
//  door's line, after it, on the surface.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("The roots' top line — one 44 pt line, 44 pt doors (VM-50, VM-255)", .serialized)
struct MobilePathLineGeometryTests {

    /// The shell's Settings door in the environment, as the shell hands it — so
    /// the roots' gear stands on the line the way it does on the phone.
    private func shelf(
        _ session: AppSession, tokens: VoiceTokens, width: CGFloat, onWingDoor: @escaping () -> Void = {}
    ) -> HostedSurface<some View> {
        HostedSurface(
            MobileShelfView(
                model: MobileShelfViewModel(session: session),
                stars: MobileStarsModel(session: session),
                quickNote: MobileQuickNoteModel(session: session),
                tokens: tokens, wingName: WingWords.home, onWingDoor: onWingDoor, tabBar: { EmptyView() },
                onOpenBook: { _ in }, onOpenForWriting: { _ in })
                .environment(\.mobileSettingsDoor, MobileSettingsDoor {}),
            size: CGSize(width: width, height: 852))
    }

    private func frame<V: View>(_ surface: HostedSurface<V>, _ label: String) -> CGRect? {
        surface.element(labeled: label)?.accessibilityFrame
    }

    /// The wing door: the element named by the wing, a button.
    private func wingDoor<V: View>(_ surface: HostedSurface<V>) -> NSObject? {
        surface.visibleElements.first {
            $0.accessibilityLabel == WingWords.home && $0.accessibilityTraits.contains(.button)
        }
    }

    /// Every door on the line: 44 × 44, on the wing door's line, after it, inside
    /// the surface, and keeping the one 44 pt row.
    private func expectDoors<V: View>(
        _ doors: [String], on surface: HostedSurface<V>, wing: CGRect, width: CGFloat, voice: ThemeVoice,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        for label in doors {
            let hit = try #require(frame(surface, label),
                                   "the \(label) door is missing in \(voice): \(surface.visibleLabels)",
                                   sourceLocation: sourceLocation)
            #expect(hit.width >= 43.5 && hit.height >= 43.5,
                    "\(label) answers across 44 × 44 in \(voice) at \(Int(width)): \(hit)", sourceLocation: sourceLocation)
            #expect(hit.height <= 44.5, "\(label) keeps the one 44 pt row: \(hit)", sourceLocation: sourceLocation)
            #expect(abs(hit.midY - wing.midY) <= 2,
                    "\(label) is off the wing door's line: \(hit.midY) vs \(wing.midY)", sourceLocation: sourceLocation)
            #expect(hit.minX >= wing.maxX - 0.5, "\(label) overlaps the wing door: \(hit) vs \(wing)",
                    sourceLocation: sourceLocation)
            #expect(hit.maxX <= width - 8 + 0.5, "\(label) leaves the surface at \(Int(width)): \(hit)",
                    sourceLocation: sourceLocation)
        }
    }

    /// **The Bookcase's line** — the long case (a two-digit count, "14 books"),
    /// 402 and 430, both voices: the wing door a 44 × 44 target that never grows
    /// the line with its count inside it (its value is the count, voiced), the
    /// New Note glyph and the gear 44 × 44 on its line, and NO trash door.
    @Test func theBookcaseLineIsTheWingsNameItsCountAndTwoDoors() async throws {
        try await withEditorWorld { session, _ in
            for index in 0..<14 {
                _ = try await session.runner.run { ops in
                    try ops.createReading(name: "Volume \(index)", kind: .book)
                }
            }
            for tokens in [VoiceTokens.terminalLight, .studyLight] {
                for width in [CGFloat(402), 430] {
                    var presses = 0
                    let surface = shelf(session, tokens: tokens, width: width, onWingDoor: { presses += 1 })
                    defer { surface.tearDown() }
                    await surface.settle(40)
                    #expect(surface.host.view.bounds.width == width)
                    let door = try #require(wingDoor(surface),
                                            "no wing door in \(tokens.voice) at \(Int(width)): \(surface.visibleLabels)")
                    let wing = door.accessibilityFrame
                    #expect(wing.width >= 43.5 && wing.height >= 43.5,
                            "the wing door answers across 44 × 44 in \(tokens.voice) at \(Int(width)): \(wing)")
                    #expect(wing.height <= 44.5,
                            "the name and its count stay inside one 44 pt line in \(tokens.voice) at \(Int(width)): \(wing)")
                    #expect(wing.minX >= PhoneMetrics.gutter - 0.5, "the door starts at the gutter: \(wing)")
                    #expect(door.accessibilityValue == tokens.chromeLabel(MobileShelfFaces.bookCount(14)),
                            "the count under the name: \(door.accessibilityValue ?? "nil")")
                    try expectDoors(["New Note", MobileSettingsGear.spokenLabel], on: surface,
                                    wing: wing, width: width, voice: tokens.voice)
                    #expect(frame(surface, MobileRecoveryDoors.trashLabel) == nil,
                            "the Bookcase carries no trash door (VM-255)")
                    #expect(door.accessibilityActivate(), "the wing door is a real control")
                    await surface.settle(5)
                    #expect(presses == 1, "pressing the wing door opens the list")
                }
            }
        }
    }

    /// **The Library's line**: the wing door (no count — its value empty), then
    /// the trash, New Note and the gear, each 44 × 44 on the door's line.
    @Test func theLibraryLineIsTheWingsNameAndThreeDoors() async throws {
        try await withEditorWorld { session, _ in
            for tokens in [VoiceTokens.terminalLight, .studyLight] {
                let shelfModel = MobileShelfViewModel(session: session)
                let observing = Task { await shelfModel.start() }
                defer { observing.cancel() }
                let view = MobileLibraryView(
                    model: MobileLibraryViewModel(session: session),
                    scraps: MobileScrapsModel(session: session),
                    stars: MobileStarsModel(session: session),
                    books: shelfModel, tokens: tokens, wingName: WingWords.home, onWingDoor: {},
                    tabBar: { EmptyView() },
                    onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
                    .environment(\.mobileSettingsDoor, MobileSettingsDoor {})
                try await withHostedSurface(view, size: CGSize(width: 402, height: 852)) { surface in
                    await surface.settle(40)
                    let door = try #require(wingDoor(surface), "labels: \(surface.visibleLabels)")
                    #expect(door.accessibilityFrame.height <= 44.5, "one 44 pt line: \(door.accessibilityFrame)")
                    #expect((door.accessibilityValue ?? "") == "", "no count on the Library's line")
                    try expectDoors([MobileRecoveryDoors.trashLabel, "New Note", MobileSettingsGear.spokenLabel],
                                    on: surface, wing: door.accessibilityFrame, width: 402, voice: tokens.voice)
                }
            }
        }
    }
}
