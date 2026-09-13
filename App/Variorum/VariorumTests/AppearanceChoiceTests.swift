//
//  AppearanceChoiceTests.swift
//  VariorumTests
//
//  18j (her R-Q12) — the in-app light/dark choice, pinned at its three
//  claims: the pure mapping and its stored form; the ONE root actually
//  moving the whole process (a SECOND window, made after the choice, wears
//  it — the brief's own verification); and the bridge the other 48 surfaces
//  ride, which is that SwiftUI's `@Environment(\.colorScheme)` follows the
//  app appearance, so not one of them had to be touched.
//
//  RED ON OLD by construction: `AppearanceChoice` and `AppearanceController`
//  did not exist before this batch — there was no way to say "dark" while
//  the system said light. What these pin is that the road works end to end
//  and that a future change cannot quietly make it per-surface.
//

import AppKit
import SwiftUI
import Testing
@testable import Variorum

@Suite("The appearance choice (18j, her R-Q12)")
@MainActor
struct AppearanceChoiceTests {
    /// A scrubbed defaults suite — never `.standard`, which the dev-store
    /// app and her own walks share (the `LibraryCatalogModel` rule).
    private func scratch(_ name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: "18j.appearance.\(name)")!
        defaults.removePersistentDomain(forName: "18j.appearance.\(name)")
        return defaults
    }

    // MARK: The pure rule

    @Test func theThreeChoicesNameTheirAppKitAppearance() {
        #expect(AppearanceChoice.system.appearanceName == nil,
                "follow-system means NO app appearance — inherit the system's")
        #expect(AppearanceChoice.light.appearanceName == .aqua)
        #expect(AppearanceChoice.dark.appearanceName == .darkAqua)
        #expect(AppearanceChoice.allCases.count == 3, "three, and never a fourth quietly")
    }

    @Test func theChoiceIsRememberedLocallyAndAStrangeValueReadsAsFollowSystem() {
        let defaults = scratch("remembered")
        #expect(AppearanceChoice.remembered(defaults) == .system,
                "an app never told anything behaves exactly as it did before 18j")

        let controller = AppearanceController(defaults: defaults)
        controller.set(.dark)
        #expect(defaults.string(forKey: AppearanceChoice.settingKey) == "dark")
        #expect(AppearanceChoice.remembered(defaults) == .dark)
        // A fresh owner over the same defaults comes up where she left it
        // — the launch road.
        #expect(AppearanceController(defaults: defaults).choice == .dark)

        defaults.set("sepia", forKey: AppearanceChoice.settingKey)
        #expect(AppearanceChoice.remembered(defaults) == .system,
                "a value that is not one of the three is not a colour scheme")
        // Restore the process appearance this test moved.
        controller.set(.system)
    }

    // MARK: The ONE root

    /// **The brief's verification:** the choice is applied at the app, so a
    /// window made AFTER it — a note window, the quick-note pad, the
    /// Settings scene — wears it without asking. A per-scene
    /// `preferredColorScheme` could not say this.
    @Test func theChoiceMovesTheAppAndASecondWindowFollows() {
        let previous = NSApp.appearance
        defer { NSApp.appearance = previous }
        let controller = AppearanceController(defaults: scratch("root"))

        controller.set(.dark)
        #expect(NSApp.appearance?.name == .darkAqua, "the ONE write landed on the app")
        let second = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 120),
            styleMask: [.titled], backing: .buffered, defer: false)
        second.isReleasedWhenClosed = false
        defer { second.close() }
        #expect(second.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua,
                "a window made after the choice inherits it — nothing per-scene")

        controller.set(.light)
        #expect(second.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .aqua,
                "and follows it back")

        controller.set(.system)
        #expect(NSApp.appearance == nil,
                "follow-system CLEARS the app appearance rather than guessing one")
    }

    /// **The bridge every one of the 48 `@Environment(\.colorScheme)`
    /// readers rides.** If this ever stopped being true, dark mode would
    /// have to be plumbed surface by surface — which is exactly what F-9
    /// forbids — so it is pinned rather than assumed.
    @Test func swiftUIsColorSchemeFollowsTheAppAppearance() {
        let previous = NSApp.appearance
        defer { NSApp.appearance = previous }
        let controller = AppearanceController(defaults: scratch("bridge"))
        let seen = SchemeProbe.Box()

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 120),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer {
            window.orderOut(nil)
            window.close()
        }
        controller.set(.dark)
        let hosting = NSHostingView(rootView: SchemeProbe(box: seen))
        hosting.frame = NSRect(x: 0, y: 0, width: 200, height: 120)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        hosting.layoutSubtreeIfNeeded()
        window.displayIfNeeded()
        #expect(seen.scheme == .dark,
                "a SwiftUI surface under the dark choice resolves DARK — whatever the system says")

        controller.set(.light)
        hosting.layoutSubtreeIfNeeded()
        window.displayIfNeeded()
        #expect(seen.scheme == .light, "and light when she says light")

        controller.set(.system)
    }
}

/// Records the `colorScheme` its host resolves. A view, because the
/// environment value only exists inside one.
private struct SchemeProbe: View {
    @MainActor final class Box { var scheme: ColorScheme? }
    let box: Box
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Color.clear.onAppear { box.scheme = scheme }
            .onChange(of: scheme) { _, new in box.scheme = new }
    }
}
