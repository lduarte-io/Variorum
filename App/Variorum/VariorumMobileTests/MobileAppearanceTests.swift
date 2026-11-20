//
//  MobileAppearanceTests.swift
//  VariorumMobileTests
//
//  VM-53 (the VM-47 run, batch 5) — **this phone's light · dark · follow-the-
//  system choice** (her LK-1/LK-2: light or dark stays each device's own;
//  AppSpec §12: a local preference), pinned at its claims, the Mac's
//  `AppearanceChoiceTests` shape on the phone's terms:
//    1. the rule is the Mac's (the shared enum): its UIKit twin, the stored form,
//       a strange value reading as follow-system, and `isDark(system:)` — the
//       lobby's resolution at the app's root;
//    2. the ONE root: a change reaches the window and everything in it — the
//       SwiftUI chrome's `colorScheme`, a UIKit view's traits — and a window shown
//       AFTER the choice wears it (the first-frame road);
//    3. it is LOCAL: nothing reaches the store's `setting` table, and the owner a
//       test runner's host builds is inert (it styles no window of the host's).
//
//  NEW BEHAVIOUR — red on old by construction (the phone had no such choice:
//  audit A, H3 "Phone follows the system only").
//

import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// A SwiftUI surface that reports the colour scheme it resolved.
private struct SchemeProbe: View {
    final class Box { var scheme: ColorScheme? }
    let box: Box
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        box.scheme = scheme
        return Color.clear.frame(width: 10, height: 10)
    }
}

@MainActor
@Suite("This phone's light · dark · follow-the-system choice (VM-53, her LK-2)", .serialized)
struct MobileAppearanceTests {
    /// A scrubbed defaults suite — never `.standard`, which the dev-store app
    /// and the walks share (the Mac pin's rule).
    private func scratch(_ name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: "vm53.appearance.\(name)")!
        defaults.removePersistentDomain(forName: "vm53.appearance.\(name)")
        return defaults
    }

    // MARK: 1. The rule — the Mac's

    @Test func theThreeChoicesNameTheirUIKitStyle() {
        #expect(AppearanceChoice.system.userInterfaceStyle == .unspecified,
                "follow-system means NO override — the window inherits the system's")
        #expect(AppearanceChoice.light.userInterfaceStyle == .light)
        #expect(AppearanceChoice.dark.userInterfaceStyle == .dark)
        #expect(AppearanceChoice.allCases == [.system, .light, .dark], "three, in the Mac's order")
        #expect(AppearanceChoice.settingKey == "appearanceChoice", "the Mac's own key, in this phone's own domain")
    }

    /// The lobby resolves its tokens at the app's root, where a window's override
    /// is not seen: the choice decides, and follow-system defers to the system.
    @Test func isDarkFollowsTheChoiceAndDefersOnlyForFollowSystem() {
        for system in [false, true] {
            #expect(AppearanceChoice.system.isDark(system: system) == system)
            #expect(AppearanceChoice.light.isDark(system: system) == false)
            #expect(AppearanceChoice.dark.isDark(system: system) == true)
        }
    }

    @Test func theChoiceIsRememberedOnThisDeviceAndAStrangeValueReadsAsFollowSystem() {
        let defaults = scratch("remembered")
        #expect(AppearanceChoice.remembered(defaults) == .system,
                "a phone never told anything follows the system, as before")
        let controller = MobileAppearanceController(defaults: defaults, windows: { [] })
        #expect(controller.choice == .system)
        controller.set(.dark)
        #expect(controller.choice == .dark)
        #expect(defaults.string(forKey: AppearanceChoice.settingKey) == "dark")
        #expect(MobileAppearanceController(defaults: defaults, windows: { [] }).choice == .dark,
                "a fresh owner over the same defaults comes up where she left it — the launch road")
        defaults.set("sepia", forKey: AppearanceChoice.settingKey)
        #expect(AppearanceChoice.remembered(defaults) == .system,
                "a value that is not one of the three is not a colour scheme")
    }

    // MARK: 2. The ONE root

    /// **The window and everything in it.** A change writes the window's override;
    /// the SwiftUI chrome in it resolves that scheme (every phone surface reads
    /// `@Environment(\.colorScheme)`), and a UIKit view in it — the editor, the
    /// overlays — carries that style in its traits (their dynamic colours, and
    /// `MobileTraitBorder`'s registration, ride exactly this). Follow-system
    /// CLEARS the override rather than guessing one.
    @Test func aChangeReachesTheWindowItsSwiftUIAndItsUIKit() async {
        let box = SchemeProbe.Box()
        let host = UIHostingController(rootView: SchemeProbe(box: box))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        window.rootViewController = host
        window.isHidden = false
        defer {
            window.isHidden = true
            window.rootViewController = nil
        }
        let plain = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        host.view.addSubview(plain)
        let controller = MobileAppearanceController(defaults: scratch("reach"), windows: { [window] })

        for (choice, style, scheme) in [
            (AppearanceChoice.dark, UIUserInterfaceStyle.dark, ColorScheme.dark),
            (.light, .light, .light),
        ] {
            controller.set(choice)
            #expect(window.overrideUserInterfaceStyle == style, "the ONE write landed on the window")
            for _ in 0..<20 where box.scheme != scheme {
                window.layoutIfNeeded()
                host.view.setNeedsLayout()
                host.view.layoutIfNeeded()
                try? await Task.sleep(for: .milliseconds(10))
            }
            #expect(box.scheme == scheme, "the SwiftUI chrome in the window resolves \(choice)")
            #expect(plain.traitCollection.userInterfaceStyle == style, "a UIKit view in the window carries it")
        }
        controller.set(.system)
        #expect(window.overrideUserInterfaceStyle == .unspecified,
                "follow-system clears the override — the system's appearance governs again")
    }

    /// **The first-frame road:** a window that becomes visible AFTER the choice
    /// wears it at once (`UIWindow.didBecomeVisibleNotification`, delivered on the
    /// posting thread), so a launch never draws the system's appearance first; and
    /// the watch ends with its owner. Synchronous throughout, so no other suite's
    /// window can become visible while this owner watches.
    @Test func aWindowShownAfterTheChoiceWearsItAndTheWatchEndsWithItsOwner() {
        var controller: MobileAppearanceController? = MobileAppearanceController(
            defaults: scratch("first-frame"), windows: { [] }, watchesNewWindows: true)
        controller?.set(.dark)
        let shown = UIWindow(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        shown.rootViewController = UIViewController()
        shown.isHidden = false
        #expect(shown.overrideUserInterfaceStyle == .dark, "styled as it became visible — before any frame")
        shown.isHidden = true
        shown.rootViewController = nil

        controller = nil
        let later = UIWindow(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        later.rootViewController = UIViewController()
        later.isHidden = false
        #expect(later.overrideUserInterfaceStyle == .unspecified, "no watch outlives its owner")
        later.isHidden = true
        later.rootViewController = nil
    }

    // MARK: 3. Local — never the store; inert in a test host

    /// LK-2's other half: the choice never reaches the library. The owner holds
    /// no store at all (this pin holds the contract, by construction — a store
    /// write would have to be added to break it): the `setting` table is
    /// byte-for-byte what it was.
    @Test func theChoiceNeverReachesTheSettingTable() async throws {
        try await withEditorWorld { _, db in
            let before = try await db.read { db in
                try String.fetchAll(db, sql: "SELECT key || '=' || value FROM setting ORDER BY key")
            }
            let controller = MobileAppearanceController(defaults: scratch("local"), windows: { [] })
            controller.set(.dark)
            controller.set(.light)
            let after = try await db.read { db in
                try String.fetchAll(db, sql: "SELECT key || '=' || value FROM setting ORDER BY key")
            }
            #expect(after == before, "no setting row was written: \(after)")
            #expect(!after.contains { $0.lowercased().contains("appearance") })
        }
    }

    /// VX-604's posture: the owner a test runner's host builds reads a scratch
    /// domain (never the Debug app's own) and styles no window of the host's.
    @Test func theTestHostsOwnerIsInert() {
        let inert = MobileAppearanceController(launch: .hostingTests)
        let before = MobileAppearanceController.connectedWindows().map(\.overrideUserInterfaceStyle)
        let was = inert.choice
        inert.set(was == .dark ? .light : .dark)
        #expect(MobileAppearanceController.connectedWindows().map(\.overrideUserInterfaceStyle) == before,
                "the host's windows were not touched")
        inert.set(.system)
        UserDefaults(suiteName: MobileAppearanceController.testSuiteName)?
            .removePersistentDomain(forName: MobileAppearanceController.testSuiteName)
    }
}
