//
//  MobileSurfaceDriver.swift
//  VariorumMobileTests
//
//  **THE ANSWER TO §15's TRAP (b): a pin that MOUNTS THE REAL SURFACE AND
//  DRIVES THE REAL CONTROL** (round 2, batch 4).
//
//  The trap, in the round's own words: the 13j view-model seam pins stayed
//  GREEN over the Mac's dead purge wiring — *"which is precisely how the
//  defect shipped."* A pin asserting a view model's number, or a view's
//  configured property, proves nothing about what renders; and a pin can
//  drive a real UIKit API and still miss, because some APIs bypass the
//  layer under test.
//
//  This harness closes that for SwiftUI surfaces. It hosts a real view in a
//  real KEY window, walks the real ACCESSIBILITY tree, and activates a
//  control through `accessibilityActivate()` — which is UIKit's own
//  activation dispatch, the road VoiceOver takes, not a test-only shortcut.
//  A presented `.alert` is then a REAL `UIAlertController` in the window,
//  with real title, message and action titles to assert.
//
//  ── WHAT WAS MEASURED BEFORE ANY OF IT WAS RELIED ON ─────────────────────
//  A throwaway probe ran on iPhone 17 Pro / iOS 26.2 before this batch
//  wrote a line of surface code. Its findings shaped the doors themselves:
//
//  · A plain SwiftUI `Button` in a hosted key window IS findable by
//    accessibility label and `accessibilityActivate()` returns TRUE and
//    fires it. ✅
//  · A SwiftUI `.alert` really presents — `host.presentedViewController` is
//    a `UIAlertController` (SwiftUI's `PlatformAlertController`) carrying
//    the exact title, message, and action titles. ✅
//  · A `.sheet`'s contents are reachable through the presented controller's
//    own accessibility tree, and its rows activate. ✅
//  · **A SwiftUI `Menu`'s rows are NOT reachable**: activating the Menu
//    presents a `_UIContextMenuActionsOnlyViewController` whose
//    accessibility tree comes back EMPTY. ❌ — which is why every door this
//    batch built is a Button or a sheet row, never a `Menu` item.
//  · **A `UIAlertController`'s own buttons do NOT activate** from in
//    process (`accessibilityActivate()` returns false). ❌ — so a confirm's
//    PRESENTATION is asserted here, and its EFFECT is driven through the
//    model's named confirm method. That split is recorded honestly rather
//    than papered over: the half that killed the Mac's doors is the
//    presentation, and that half is pinned end to end.
//
//  A `.contextMenu` (long-press) row is likewise undrivable in process; the
//  two doors that use one (the Library row, the shelf row) are pinned at
//  their model act + their confirm's presentation, and the SAME act has a
//  fully-driven twin door elsewhere (the note's ⋯ sheet, the book's details
//  sheet). Recorded in the batch report.
//

import Foundation
import SwiftUI
import Testing
import UIKit

/// A real view in a real key window.
@MainActor
final class HostedSurface<Content: View> {
    let window: UIWindow
    let host: UIHostingController<Content>

    init(_ view: Content, size: CGSize = CGSize(width: 393, height: 852)) {
        host = UIHostingController(rootView: view)
        window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.layoutIfNeeded()
    }

    /// Let SwiftUI run its update passes. On the main actor an `await`
    /// hands the thread back to the run loop, which is what actually drives
    /// layout and presentation here.
    func settle(_ turns: Int = 20) async {
        for _ in 0..<turns {
            try? await Task.sleep(for: .milliseconds(20))
            await Task.yield()
            // **A LAYOUT PASS PER TURN, and it is load-bearing.** The
            // phone's listings are `LazyVStack`s inside `ScrollView`s (the
            // P1 discipline), and a lazy stack materializes NO rows until
            // its scroll view has actually laid out — so without this the
            // harness sees only the non-lazy chrome and every row-level
            // door reads as absent. Found by a pin that failed for the
            // right-looking wrong reason.
            host.view.setNeedsLayout()
            host.view.layoutIfNeeded()
            if let presented = host.presentedViewController {
                presented.view.setNeedsLayout()
                presented.view.layoutIfNeeded()
            }
        }
    }

    /// Every accessibility element under a view, in tree order.
    ///
    /// **It walks the CONTAINER PROTOCOL as well as the `accessibilityElements`
    /// array, and that is not belt-and-braces — it is the only way to see a
    /// `LazyVStack`'s rows.** Measured: the phone's listings (`ScrollView`
    /// over `LazyVStack`, the P1 discipline) expose their whole content as a
    /// single `AccessibilityLazyLayoutNode`, whose children answer only to
    /// `accessibilityElementCount()` / `accessibilityElement(at:)`. A walker
    /// that read `accessibilityElements` alone saw the non-lazy chrome and
    /// NOTHING else — every row-level door read as absent, which is the
    /// false-green shape this harness exists to prevent.
    static func elements(of object: NSObject) -> [NSObject] {
        var found: [NSObject] = []
        var seen = Set<ObjectIdentifier>()
        walk(object, into: &found, seen: &seen, depth: 0)
        return found
    }

    /// Cycle-guarded and depth-capped: accessibility containers can hand
    /// back their own ancestors (measured — a bare recursion never
    /// terminated here), so identity is tracked and the walk is bounded.
    private static func walk(
        _ object: NSObject, into found: inout [NSObject],
        seen: inout Set<ObjectIdentifier>, depth: Int
    ) {
        guard depth < 40, seen.insert(ObjectIdentifier(object)).inserted else { return }
        if let elements = object.accessibilityElements {
            for element in elements {
                guard let child = element as? NSObject else { continue }
                found.append(child)
                walk(child, into: &found, seen: &seen, depth: depth + 1)
            }
        } else {
            let count = object.accessibilityElementCount()
            if count != NSNotFound, count > 0 {
                for i in 0..<count {
                    guard let child = object.accessibilityElement(at: i) as? NSObject
                    else { continue }
                    found.append(child)
                    walk(child, into: &found, seen: &seen, depth: depth + 1)
                }
            }
        }
        if let view = object as? UIView {
            if view.isAccessibilityElement { found.append(view) }
            for sub in view.subviews {
                walk(sub, into: &found, seen: &seen, depth: depth + 1)
            }
        }
    }

    /// The elements of whatever is actually on screen — the presented
    /// controller's tree when one is up (a sheet), else the root's.
    var visibleElements: [NSObject] {
        if let presented = host.presentedViewController,
           !(presented is UIAlertController) {
            return Self.elements(of: presented.view)
        }
        return Self.elements(of: host.view)
    }

    var visibleLabels: [String] { visibleElements.compactMap(\.accessibilityLabel) }

    func element(labeled label: String) -> NSObject? {
        visibleElements.first { $0.accessibilityLabel == label }
    }

    /// Drive a REAL control by its accessibility label. Returns false when
    /// no such control is on screen — which is itself a finding, so callers
    /// assert on it rather than ignoring it.
    @discardableResult
    func activate(_ label: String) -> Bool {
        guard let element = element(labeled: label) else { return false }
        return element.accessibilityActivate()
    }

    /// The REAL alert currently presented, if any (SwiftUI's `.alert` and
    /// `.confirmationDialog` both present a `UIAlertController` on iOS).
    var presentedAlert: UIAlertController? {
        var controller: UIViewController? = host
        while let next = controller?.presentedViewController {
            if let alert = next as? UIAlertController { return alert }
            controller = next
        }
        return nil
    }

    /// The alert's action titles, in order — the confirm's real buttons.
    var alertActionTitles: [String] {
        (presentedAlert?.actions ?? []).compactMap(\.title)
    }

    func tearDown() {
        host.dismiss(animated: false)
        window.isHidden = true
        window.rootViewController = nil
    }
}

/// Mount, run, tear down.
@MainActor
func withHostedSurface<Content: View, T>(
    _ view: Content,
    _ body: (HostedSurface<Content>) async throws -> T
) async rethrows -> T {
    let surface = HostedSurface(view)
    defer { surface.tearDown() }
    await surface.settle()
    return try await body(surface)
}
