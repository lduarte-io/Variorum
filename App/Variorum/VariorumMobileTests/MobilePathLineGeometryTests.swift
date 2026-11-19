//
//  MobilePathLineGeometryTests.swift
//  VariorumMobileTests
//
//  VM-50 (the VM-47 run, batch 2) — **the Bookcase's path line holds ONE
//  line at 402 pt in both voices, and its doors answer across 44 × 44.**
//
//  THE MECHANISM (batch 1's carry-in, traced): batch 1 set the path line's
//  two word doors ("+ New Note", "Settings") at the 17 pt `control` role
//  beside the 13 pt path. In Terminal every glyph is SF Mono, so "~/shelf ·
//  14 books" (≈157 pt) + "+ new note" (≈102) + "settings" (≈82) + the 🗑 +
//  three 16 pt gaps + the 20 pt gutters needed ≈437 pt — more than 402 and
//  430 — and the path text, the one flexible member of the HStack, WRAPPED
//  to a second line (the chrome above the books grew 23 pt; batch 1's
//  `writingKeepsItsShareUnderAKeyboardSizedRegion` red exposed it). Study,
//  proportional, fit.
//
//  THE FIX: the doors are the phone's controls with 44 pt hit areas that
//  touch — the 🗑 and the Settings gear as icon buttons, + New Note an
//  inline act (15) — so the line needs ≈390 pt in Terminal at 402.
//
//  RED ON OLD (by behavioural revert of `MobileShelfView.pathLine` to the
//  pre-fix tree, `91d406593`): the path text measures two lines in Terminal
//  at 402 (the one-line bound fails) and every door is ~22 pt tall (the
//  44 pt bound fails). The run is recorded in the run record §6.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("The path line — one line, 44 pt doors (VM-50)", .serialized)
struct MobilePathLineGeometryTests {

    /// VM-53: the shell's Settings door in the environment, as the shell hands
    /// it — so the roots' ⋯ menu stands on the line the way it does on the phone.
    private func shelf(
        _ session: AppSession, tokens: VoiceTokens, width: CGFloat
    ) -> HostedSurface<some View> {
        HostedSurface(
            MobileShelfView(
                model: MobileShelfViewModel(session: session),
                stars: MobileStarsModel(session: session),
                quickNote: MobileQuickNoteModel(session: session),
                tokens: tokens, tabBar: { EmptyView() },
                onOpenBook: { _ in }, onOpenForWriting: { _ in },
                onOpenTrash: {})
                .environment(\.mobileSettingsDoor, MobileSettingsDoor {}),
            size: CGSize(width: width, height: 852))
    }

    private func frame<V: View>(_ surface: HostedSurface<V>, _ label: String) -> CGRect? {
        surface.element(labeled: label)?.accessibilityFrame
    }

    /// The path text's element: its label is the line it draws.
    private func pathFrame<V: View>(
        _ surface: HostedSurface<V>, startingWith prefix: String
    ) -> CGRect? {
        surface.visibleElements.first {
            ($0.accessibilityLabel ?? "").hasPrefix(prefix)
        }?.accessibilityFrame
    }

    @Test func theBookcasePathLineIsOneLineAtFourHundredTwoInBothVoices() async throws {
        try await withEditorWorld { session, _ in
            // Two-digit count: the long case ("14 books").
            for index in 0..<14 {
                _ = try await session.runner.run { ops in
                    try ops.createReading(name: "Volume \(index)", kind: .book)
                }
            }
            for tokens in [VoiceTokens.terminalLight, .studyLight] {
                for width in [CGFloat(402), 430] {
                    let surface = shelf(session, tokens: tokens, width: width)
                    defer { surface.tearDown() }
                    await surface.settle(40)
                    #expect(surface.host.view.bounds.width == width)

                    let pathPrefix = tokens.path(["Shelf"])
                    let path = try #require(
                        pathFrame(surface, startingWith: pathPrefix),
                        "no path line in \(tokens.voice) at \(Int(width)): \(surface.visibleLabels)")
                    // ONE line: a 13 pt line is ~16–18 tall; two would be ~34.
                    #expect(path.height < 26,
                            "the path line wrapped in \(tokens.voice) at \(Int(width)) pt: \(path)")

                    // VM-53 MOVED this list's last door: the Settings gear retired into the
                    // roots' ⋯ menu ("More"), the same 44 pt icon door in its place.
                    for door in [MobileRecoveryDoors.trashLabel, "New Note", MobileRootMenu.spokenLabel] {
                        let hit = try #require(
                            frame(surface, door),
                            "the \(door) door is missing in \(tokens.voice): \(surface.visibleLabels)")
                        #expect(hit.width >= 43.5 && hit.height >= 43.5,
                                "\(door) answers across 44 × 44 in \(tokens.voice) at \(Int(width)): \(hit)")
                        // On the path's own line, and after it.
                        #expect(abs(hit.midY - path.midY) <= 2,
                                "\(door) is off the path's line: \(hit.midY) vs \(path.midY)")
                        #expect(hit.minX >= path.maxX - 0.5,
                                "\(door) overlaps the path text: \(hit) vs \(path)")
                        #expect(hit.maxX <= width - 8 + 0.5,
                                "\(door) leaves the surface at \(Int(width)): \(hit)")
                    }
                }
            }
        }
    }

    @Test func theLibraryPathLineDoorsAnswerAcrossFortyFour() async throws {
        try await withEditorWorld { session, _ in
            for tokens in [VoiceTokens.terminalLight, .studyLight] {
                let shelfModel = MobileShelfViewModel(session: session)
                let observing = Task { await shelfModel.start() }
                defer { observing.cancel() }
                let view = MobileLibraryView(
                    model: MobileLibraryViewModel(session: session),
                    scraps: MobileScrapsModel(session: session),
                    stars: MobileStarsModel(session: session),
                    books: shelfModel, tokens: tokens, tabBar: { EmptyView() },
                    onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
                    .environment(\.mobileSettingsDoor, MobileSettingsDoor {})
                try await withHostedSurface(view, size: CGSize(width: 402, height: 852)) { surface in
                    await surface.settle(40)
                    let path = try #require(
                        pathFrame(surface, startingWith: tokens.path(["Library"])),
                        "labels: \(surface.visibleLabels)")
                    #expect(path.height < 26)
                    // VM-53: the roots' ⋯ menu joins the line.
                    for door in [MobileRecoveryDoors.trashLabel, "New Note", MobileRootMenu.spokenLabel] {
                        let hit = try #require(frame(surface, door), "labels: \(surface.visibleLabels)")
                        #expect(hit.width >= 43.5 && hit.height >= 43.5, "\(door) \(hit)")
                        #expect(abs(hit.midY - path.midY) <= 2, "\(door) is off the path's line")
                    }
                }
            }
        }
    }
}
