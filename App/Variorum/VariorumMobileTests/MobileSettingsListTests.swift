//
//  MobileSettingsListTests.swift
//  VariorumMobileTests
//
//  VM-53 (the VM-47 run, batch 5) — **Settings as ONE scrolling, grouped list**.
//  The ticket: "Settings is a fixed stack that cannot scroll, nearly every row is
//  a 14 pt tall word". Pinned on the real sheet, mounted:
//    · it SCROLLS — at the largest text size the list is taller than the sheet
//      and lives in a scroll view (red on old: the sheet was a bare `VStack`, no
//      scroll view at all — audit G §5.11);
//    · every door is a WHOLE-ROW target at least the menu row's 44, at the
//      default size and at the largest (red on old: inline words whose targets
//      were the word's width);
//    · the sync row's own doors answer across 44 (red on old: the row's phone arm
//      drew them in the Mac's 11.5 pt slot as plain words, ≈ 14 tall);
//    · the groups carry their names; the voice and this phone's appearance are
//      the system's segmented control, the appearance's words the Mac's own, and
//      a segment drives the phone's owner (never the library).
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Settings — one scrolling, grouped list (VM-53)", .serialized)
struct MobileSettingsListTests {
    private static let appRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // VariorumMobileTests
        .deletingLastPathComponent()  // App/Variorum

    private func scratch(_ name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: "vm53.settings.\(name)")!
        defaults.removePersistentDomain(forName: "vm53.settings.\(name)")
        return defaults
    }

    /// The router the sheet reads, with this phone's owner on a scratch domain
    /// and no window to style (the pins look at the owner, not the host).
    private func router(_ name: String) -> MobileShellRouter {
        MobileShellRouter(appearance: MobileAppearanceController(defaults: scratch(name), windows: { [] }))
    }

    private func firstScrollView(in view: UIView) -> UIScrollView? {
        if let scroll = view as? UIScrollView { return scroll }
        for sub in view.subviews {
            if let found = firstScrollView(in: sub) { return found }
        }
        return nil
    }

    /// **It scrolls.** At the largest text size the list is taller than the sheet
    /// and it lives in a scroll view, so nothing clips and the last row is reached
    /// by scrolling (the mockup's S1 at the largest text).
    @Test func theListScrollsAtTheLargestTextSize() async throws {
        try await withEditorWorld { session, _ in
            let sheet = MobileSettingsView(session: session, router: router("scrolls"), services: nil)
                .environment(\.dynamicTypeSize, .accessibility5)
            try await withHostedSurface(sheet, size: CGSize(width: 402, height: 640)) { surface in
                await surface.settle(30)
                let scroll = try #require(firstScrollView(in: surface.host.view),
                                          "Settings is ONE scrolling list — no scroll view was found")
                #expect(scroll.contentSize.height > scroll.bounds.height,
                        "at AX5 the list is taller than the sheet: \(scroll.contentSize) in \(scroll.bounds.size)")
                #expect(surface.element(labeled: "Open the edit trace") != nil,
                        "the last group's door is in the list, reached by scrolling — labels were \(surface.visibleLabels)")
            }
        }
    }

    /// **Whole-row doors.** Each door answers across the sheet's full width and
    /// at least the one-line menu row's 44, at the default size and the largest.
    @Test(arguments: [DynamicTypeSize.large, .accessibility5])
    func everyDoorIsAWholeRowAtLeastFortyFourTall(_ size: DynamicTypeSize) async throws {
        try await withEditorWorld { session, _ in
            let sheet = MobileSettingsView(session: session, router: router("rows"), services: nil)
                .environment(\.dynamicTypeSize, size)
            try await withHostedSurface(sheet, size: CGSize(width: 402, height: 852)) { surface in
                await surface.settle(30)
                for door in [MobileTagManagerSheet.doorTitle, "Acknowledgments", "Open the edit trace"] {
                    let frame = try #require(surface.element(labeled: door)?.accessibilityFrame,
                                             "\(door) — labels were \(surface.visibleLabels)")
                    #expect(frame.height >= 43.5, "\(door) answers across 44 tall at \(size): \(frame)")
                    #expect(frame.width >= 402 - 1, "\(door) is the whole row at \(size): \(frame)")
                }
            }
        }
    }

    /// **The sync row's doors answer across 44** (the row's phone arm — the
    /// Settings sheet is its only host). Real services over the world's library,
    /// signed out: the row's door is *Sign in…*.
    @Test func theSyncRowsDoorsAnswerAcrossFortyFour() async throws {
        try await withEditorWorld { session, _ in
            let auth = AuthSession(
                configuration: AuthConfiguration(projectURL: URL(string: "https://vm53.invalid")!, apiKey: "k"),
                store: .inMemory(), http: { _ in throw AuthSessionError.malformedResponse("no network") })
            let services = AppServices(
                session: session, storeVariant: .real, backupEnabled: false, auth: auth,
                makeSyncKeyProvider: { UnenrolledKeyProvider() }, networkPath: nil, legacyCleanup: {})
            defer { services.stop() }
            let sheet = MobileSettingsView(session: session, router: router("sync"), services: services)
            try await withHostedSurface(sheet, size: CGSize(width: 402, height: 852)) { surface in
                await surface.settle(30)
                let door = try #require(surface.element(labeled: "Sign in…")?.accessibilityFrame,
                                        "labels were \(surface.visibleLabels)")
                #expect(door.height >= 43.5 && door.width >= 43.5, "the sync row's door answers across 44: \(door)")
            }
        }
    }

    /// **The groups, and the two choices.** The group names stand; the voice is
    /// one choice (its two words kept) showing the library's voice selected; this
    /// phone's appearance is the system control in the Mac's words, and a segment
    /// drives the PHONE's owner — remembered in its own defaults.
    @Test func theGroupsAndTheTwoChoices() async throws {
        try await withEditorWorld { session, _ in
            let defaults = scratch("choices")
            let router = MobileShellRouter(
                appearance: MobileAppearanceController(defaults: defaults, windows: { [] }))
            let sheet = MobileSettingsView(session: session, router: router, services: nil)
            try await withHostedSurface(sheet, size: CGSize(width: 402, height: 852)) { surface in
                await surface.settle(30)
                let labels = surface.visibleLabels
                for group in [
                    MobileSettingsView.libraryGroupTitle, MobileSettingsView.lookGroupTitle,
                    MobileSettingsView.tagsGroupTitle, MobileSettingsView.helpGroupTitle,
                    MobileSettingsView.diagnosticsGroupTitle,
                ] {
                    #expect(labels.contains(group), "the \(group) group stands — labels were \(labels)")
                }
                @MainActor func segment(_ word: String) -> NSObject? {
                    surface.visibleElements.first {
                        $0.accessibilityLabel == word && $0.accessibilityTraits.contains(.button)
                    }
                }
                let shown = MobileSettingsView.voiceWord(router.voice)
                let other = MobileSettingsView.voiceWord(router.voice == .study ? .terminal : .study)
                #expect(segment(shown)?.accessibilityTraits.contains(.selected) == true,
                        "the library's voice is the chosen segment")
                #expect(segment(other)?.accessibilityTraits.contains(.selected) == false)

                for choice in AppearanceChoice.allCases {
                    #expect(segment(MobileSettingsView.appearanceWord(choice)) != nil,
                            "\(choice)'s segment — labels were \(labels)")
                }
                #expect(segment("Follow system")?.accessibilityTraits.contains(.selected) == true,
                        "a phone never told anything follows the system")
                #expect(surface.activate("Dark"))
                await surface.settle(10)
                #expect(router.appearance.choice == .dark, "the segment drove this phone's owner")
                #expect(defaults.string(forKey: AppearanceChoice.settingKey) == "dark",
                        "remembered in this device's own defaults")
                #expect(segment("Dark")?.accessibilityTraits.contains(.selected) == true)
            }
        }
    }

    /// **The appearance choice speaks the Mac's own words** (the same row on both
    /// platforms; the brief: "the Mac's own words for the same rows"). Held to the
    /// Mac's row by its source, so the two cannot drift apart.
    @Test func theAppearanceWordsAreTheMacsOwn() throws {
        let mac = try String(
            contentsOf: Self.appRoot.appendingPathComponent(
                "Variorum/Features/Settings/AppearanceChoiceRow.swift"),
            encoding: .utf8)
        for choice in AppearanceChoice.allCases {
            let word = MobileSettingsView.appearanceWord(choice)
            #expect(mac.contains("Text(\"\(word)\").tag(AppearanceChoice.\(choice.rawValue))"),
                    "the Mac's row says \(word) for \(choice)")
        }
        #expect(mac.contains("Picker(\"\(MobileSettingsView.appearanceLabel)\""), "the Mac's label")
    }
}
