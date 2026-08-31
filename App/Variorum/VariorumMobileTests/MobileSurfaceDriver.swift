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
//  ── BATCH 4.5b's TWO ADDITIONS ───────────────────────────────────────────
//
//  **1. THE ACCESSIBILITY SERVER IS ARMED HERE, AND ITS ABSENCE IS SAID OUT
//  LOUD** (Act 1's MAJOR 4). The whole harness above rides ONE machine-local,
//  per-simulator default — `com.apple.Accessibility
//  ApplicationAccessibilityEnabled` — that is not in the repo and not in the
//  scheme. Without it every walk below returns an EMPTY tree, so **every real
//  door reads as ABSENT**: 16 pins failing as phantoms, on a clean simulator,
//  a reset one, or any other machine. Three of this round's four sub-batches
//  were dispatched onto unarmed simulators.
//
//  That is the round's green-over-nothing class INVERTED — *red over
//  nothing* — and it is the more dangerous direction, because the honest
//  response to a phantom failure is to change working code. So:
//  `AccessibilityServer.armOnce()` arms it from inside the bundle, and
//  `HostedSurface` **fails with a diagnostic naming the server** when a
//  surface known to carry content yields nothing. *"Not armed" must never
//  again be indistinguishable from "the door isn't there."*
//
//  **1b. A NOTE ON KEY WINDOWS — what is MEASURED, and what is not**
//  (`mobile-round-2.md` §60/§61). `makeKeyAndVisible()` below is what the
//  pins ride on: driving a control through `accessibilityActivate()` and
//  presenting a real `UIAlertController` both need a key window.
//
//  A cross-session report proposed that a SECOND key window in one run
//  steals key status and produces
//  `MobileEditorViewModel.swift:1540: Fatal error: mobile editor surface
//  desynced from the block index`. **That mechanism is FALSIFIED and is
//  recorded here so it is not re-adopted:** the committed tree already hosts
//  key windows outside this file — `MobileTakesBrowserTests.swift:770` and
//  `:946`, `MobileLivenessTests.swift:199` — none touched by this round and
//  all present while the suite was green, so four-plus simultaneous key
//  windows is the NORMAL, GREEN state. A counting probe run from this file
//  agreed: over one full run, two hosted surfaces were alive at once in
//  fifteen tests across four suites, all passing. What IS established is
//  narrower — one particular harness correlated with a crash under a
//  three-way isolation, and that harness differed from every other host in
//  the suite by having **no `rootViewController`** at all.
//
//  **So: nothing here is a known hazard, and one thing is explicitly NOT a
//  rule — never read a 1540 fatal as harness noise.**
//  `EditorAssertionSeam.fire` defaults to `assertionFailure` precisely so a
//  routing failure that `desyncRecovery()` then heals is SEEN. A standing
//  instruction to dismiss it would be this round's green-over-nothing
//  failure inverted. Isolate it yourself before believing anything about it.
//
//  **One real trap, traced, met in this sub-batch:** mounting a
//  `MobileWriteScreen` over a model built by `makeSurfaceEditor` and then
//  written to through the AUTOSAVE COORDINATOR re-attaches that model to a
//  different text view whose storage disagrees with the index — a desync by
//  design, which `MobileUndoDoorTests` already documented and cures with
//  `await model.refreshTakesFromStore()` before mounting. A pin that writes
//  through the coordinator and then hosts must do the same.
//
//  A precaution, not a diagnosis: a NEW hosting window that does not need
//  key status is cheapest as `window.isHidden = false`.
//
//  **2. THE LIVE `UIAlertAction` HANDLER CAN BE INVOKED** — the header above
//  recorded that a `UIAlertController`'s buttons do not respond to
//  `accessibilityActivate()`, and that honestly-stated gap is exactly where
//  batch 4's confirm BLOCKER lived: every pin presented the alert and then
//  called the model's confirm method DIRECTLY, while the pending value was
//  still set, so the one edge where SwiftUI's `isPresented` write-back meets
//  the action's deferred `Task` had no coverage at all.
//  `activateAlertAction(_:)` closes it: it reaches the action's own installed
//  handler and invokes it, which is the same closure UIKit runs on a real
//  tap — write-back and all. See `MobileConfirmDoorTests`.
//

import Foundation
import SwiftUI
import Testing
import UIKit

/// **The accessibility server this whole harness rides on.**
///
/// Everything `HostedSurface` does — finding a door by label, activating it,
/// reading an alert's actions — depends on the simulator's accessibility
/// server being enabled for the process. That is a machine-local,
/// per-simulator preference (`com.apple.Accessibility
/// ApplicationAccessibilityEnabled`), which is why an unarmed simulator turns
/// sixteen real pins into phantom failures that all read "the door isn't
/// there."
///
/// Two halves, and the diagnostic is the more important one:
/// - `armOnce()` tries to enable it from inside the bundle (a runtime call
///   where the symbol exists, plus a preference write so a later launch is
///   armed even if the runtime road is not available);
/// - `remediation` is the sentence every empty tree gets attached to it, so
///   *"not armed"* can never again read as *"door absent."*
enum AccessibilityServer {
    /// The command that arms a simulator by hand, verbatim — §9's
    /// environment block carries the same line.
    static let remediation = """
        THE ACCESSIBILITY SERVER LOOKS UNARMED on this simulator, so the \
        accessibility tree came back EMPTY and EVERY door reads as absent. \
        This is not a missing door — it is a missing machine-local default. \
        Arm it and re-run:
          xcrun simctl spawn <UDID> defaults write com.apple.Accessibility \
        ApplicationAccessibilityEnabled -bool true
        (mobile-round-2.md §9; Act 1's MAJOR 4.)
        """

    private nonisolated(unsafe) static var armed = false

    /// Idempotent; called from every `HostedSurface.init`.
    @discardableResult
    static func armOnce() -> Bool {
        if armed { return true }
        armed = true
        writePreference()
        return setRuntimeFlag(true)
    }

    /// Whether the runtime believes application accessibility is on. `nil`
    /// when the symbol is unavailable — an *unknown*, never a false negative,
    /// so the diagnostic never accuses a healthy machine.
    static var runtimeEnabled: Bool? {
        guard let handle = dlopen("/usr/lib/libAccessibility.dylib", RTLD_NOW) else {
            return nil
        }
        guard let symbol = dlsym(handle, "_AXSApplicationAccessibilityEnabled") else {
            return nil
        }
        typealias Getter = @convention(c) () -> Bool
        return unsafeBitCast(symbol, to: Getter.self)()
    }

    private static func setRuntimeFlag(_ on: Bool) -> Bool {
        guard let handle = dlopen("/usr/lib/libAccessibility.dylib", RTLD_NOW) else {
            return false
        }
        typealias Setter = @convention(c) (Bool) -> Void
        for name in ["_AXSSetApplicationAccessibilityEnabled", "_AXSSetAutomationEnabled"] {
            if let symbol = dlsym(handle, name) {
                unsafeBitCast(symbol, to: Setter.self)(on)
                return true
            }
        }
        return false
    }

    /// The belt: the same default the by-hand command writes. It lands too
    /// late for the accessibility bundle of THIS launch on some runtimes, so
    /// it is insurance for the next one, never the primary road.
    private static func writePreference() {
        CFPreferencesSetValue(
            "ApplicationAccessibilityEnabled" as CFString, kCFBooleanTrue,
            "com.apple.Accessibility" as CFString,
            kCFPreferencesAnyUser, kCFPreferencesAnyHost)
        CFPreferencesSynchronize(
            "com.apple.Accessibility" as CFString,
            kCFPreferencesAnyUser, kCFPreferencesAnyHost)
    }
}

/// A real view in a real key window.
@MainActor
final class HostedSurface<Content: View> {
    let window: UIWindow
    let host: UIHostingController<Content>

    /// The key window is deliberate: `accessibilityActivate()` and real
    /// alert presentation both need one (see the note on key windows above).
    init(_ view: Content, size: CGSize = CGSize(width: 393, height: 852)) {
        AccessibilityServer.armOnce()
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
        let found: [NSObject]
        if let presented = host.presentedViewController,
           !(presented is UIAlertController) {
            found = Self.elements(of: presented.view)
        } else {
            found = Self.elements(of: host.view)
        }
        if !found.isEmpty { everSawAnElement = true }
        return found
    }

    var visibleLabels: [String] { visibleElements.compactMap(\.accessibilityLabel) }

    func element(labeled label: String) -> NSObject? {
        visibleElements.first { $0.accessibilityLabel == label }
    }

    /// Drive a REAL control by its accessibility label. Returns false when
    /// no such control is on screen — which is itself a finding, so callers
    /// assert on it rather than ignoring it.
    ///
    /// **A false return over an EMPTY tree is a different finding entirely**,
    /// and it says so: an unarmed accessibility server makes every door read
    /// as absent, and a failure that looks like a missing door is how a
    /// session ends up "fixing" working code.
    @discardableResult
    func activate(_ label: String, sourceLocation: SourceLocation = #_sourceLocation) -> Bool {
        let elements = visibleElements
        guard let element = elements.first(where: { $0.accessibilityLabel == label })
        else {
            if elements.isEmpty {
                reportEmptyTree(lookingFor: label, sourceLocation: sourceLocation)
            }
            return false
        }
        return element.accessibilityActivate()
    }

    // MARK: - The accessibility server's absence, said out loud

    /// Set the first time ANY element is seen. A surface that never saw one
    /// was walking a dead tree, and every absence it "proved" proved nothing.
    private var everSawAnElement = false

    /// **Reported EVERY time, deliberately.** A first draft suppressed
    /// repeats so an unarmed simulator would read as one diagnosis rather
    /// than sixteen — which is exactly backwards: the other fifteen would
    /// then fail with the ORIGINAL confusing message (`labels were []`,
    /// indistinguishable from an absent door) and the single signpost would
    /// be lost among them. Sixteen copies of one unmistakable sentence is
    /// the outcome worth having.
    private func reportEmptyTree(lookingFor label: String?, sourceLocation: SourceLocation) {
        let runtime = AccessibilityServer.runtimeEnabled
            .map { $0 ? "on" : "OFF" } ?? "unknown"
        let looking = label.map { " (looking for “\($0)”)" } ?? ""
        Issue.record(
            """
            \(AccessibilityServer.remediation)
            [surface\(looking): the walk returned ZERO elements; \
            _AXSApplicationAccessibilityEnabled reads \(runtime)]
            """,
            sourceLocation: sourceLocation)
    }

    /// The end-of-life check, and it is the half that catches the QUIET
    /// failure: a pin whose only assertions are ABSENCES (*"no purge verb
    /// leaks into a note"*) passes vacuously over a dead tree. A surface
    /// that lived its whole life without seeing one element is reported.
    func checkAccessibilityTreeWasAlive(sourceLocation: SourceLocation) {
        guard !everSawAnElement, visibleElements.isEmpty else { return }
        reportEmptyTree(lookingFor: nil, sourceLocation: sourceLocation)
    }

    // MARK: - Driving a presented alert's REAL action

    /// **The edge batch 4's BLOCKER lived in.** `accessibilityActivate()`
    /// does not work on a `UIAlertController`'s buttons, so every confirm was
    /// pinned by presenting the alert and then calling the model's confirm
    /// method directly — which never exercises SwiftUI's `isPresented`
    /// write-back, and the write-back is what killed four doors.
    ///
    /// This reaches the action's own installed handler — the very closure
    /// UIKit invokes on a tap — and calls it. Returns false when there is no
    /// such action or the handler cannot be reached, so a caller asserts on
    /// it rather than passing over nothing.
    /// Case-insensitive on the title: the phone's chrome labels are voiced
    /// (`tokens.chromeLabel` lowercases in the Terminal register), so a
    /// caller naming the door's word must not have to know which voice the
    /// surface was mounted in — the sibling assertions already compare
    /// lowercased for the same reason.
    @discardableResult
    func activateAlertAction(_ title: String) -> Bool {
        guard let alert = presentedAlert,
              let action = alert.actions.first(where: {
                  $0.title?.lowercased() == title.lowercased()
              })
        else { return false }
        guard let handler = AlertActionHandler.of(action) else { return false }
        handler(action)
        return true
    }

    /// **THE CONFIRM→ACT EDGE, and it is the edge the BLOCKER lived in.**
    ///
    /// A real tap on an alert action does two things in ONE synchronous turn:
    /// it runs the action, and SwiftUI writes `isPresented = false`. The
    /// action's own `Task { … }` cannot resume until that turn yields — so an
    /// act that READS ITS SUBJECT BACK after the suspension reads whatever
    /// the write-back left, which for four phone doors was `nil`.
    ///
    /// **What is real here and what is not, measured on iOS 26 rather than
    /// assumed** (probe, 2026-08-22 — the honesty this pin's own subject
    /// demands):
    /// - The action's installed handler IS reachable and invoking it DOES run
    ///   the SwiftUI `Button`'s closure. Real.
    /// - The handler does **NOT** itself perform the `isPresented`
    ///   write-back — the alert stays up and the bound value survives; the
    ///   write-back comes from SwiftUI's dismissal machinery.
    /// - Driving that dismissal through UIKit in process does not reproduce
    ///   the turn: `dismiss(animated: false)` lands the write-back a runloop
    ///   turn LATER, by which time the action's `Task` has already run — and
    ///   dismissing FIRST makes SwiftUI refuse to run the action at all.
    ///   A `UIAlertController`'s action views also stay inert to
    ///   `accessibilityActivate()`, so there is no in-process real tap.
    ///
    /// So `writeBack` is supplied by the caller and performs the write-back
    /// through **the very binding SwiftUI writes** (`model.xPresented =
    /// false`), synchronously, with no suspension between it and the action.
    /// That is faithful to the mechanism this round verified three times, and
    /// the one simulated step is named here rather than hidden.
    @discardableResult
    func tapAlertAction(_ title: String, writeBack: () -> Void) -> Bool {
        guard activateAlertAction(title) else { return false }
        writeBack()
        return true
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
        // Hiding relinquishes key status before the next host asks for it.
        window.isHidden = true
        window.rootViewController = nil
    }
}

/// **Reaches a `UIAction`'s installed handler** — the block menu's rows.
///
/// `MobileSurfaceDriver`'s header records that a SwiftUI `Menu`'s rows are
/// unreachable in process, and that stays true of the PRESENTED menu. But the
/// phone's ⋯ block menu is a UIKit `UIMenu` built by
/// `MobileBlockMenuController.menuElements(…)`, and the elements it hands to
/// both of its doors are ordinary `UIAction`s — whose handlers ARE reachable
/// and ARE the exact closures UIKit runs on a tap. So the block menu's rows
/// are drivable at the action level even though the presented menu is not
/// (batch 4.5b, §53 finding 4). Same failure mode as `AlertActionHandler`: a
/// rename in a future OS makes the lookup nil and the caller's `#expect`
/// fails loudly.
enum MenuActionHandler {
    typealias Handler = @convention(block) (UIAction) -> Void

    static func of(_ action: UIAction) -> Handler? {
        guard action.responds(to: NSSelectorFromString("handler")),
              let boxed = action.value(forKey: "handler")
        else { return nil }
        return unsafeBitCast(boxed as AnyObject, to: Handler.self)
    }

    /// Find a row by title anywhere in a menu element list (submenus
    /// included) and run its real handler.
    @discardableResult
    @MainActor
    static func activate(_ title: String, in elements: [UIMenuElement]) -> Bool {
        for element in elements {
            if let action = element as? UIAction, action.title == title {
                guard let handler = of(action) else { return false }
                handler(action)
                return true
            }
            if let menu = element as? UIMenu, activate(title, in: menu.children) {
                return true
            }
        }
        return false
    }
}

/// Reaches a `UIAlertAction`'s installed handler.
///
/// `UIAlertAction` stores its handler privately and exposes it under the
/// `handler` key; this is test-bundle-only code, never shipped, and it is the
/// only way to drive the confirm→act edge in process. If a future OS renames
/// the key the lookup returns nil and every caller's `#expect` fails loudly —
/// the failure mode is a red pin, never a silent pass.
enum AlertActionHandler {
    typealias Handler = @convention(block) (UIAlertAction) -> Void

    static func of(_ action: UIAlertAction) -> Handler? {
        guard action.responds(to: NSSelectorFromString("handler")),
              let boxed = action.value(forKey: "handler")
        else { return nil }
        return unsafeBitCast(boxed as AnyObject, to: Handler.self)
    }
}

/// Mount, run, tear down.
///
/// **`size:` exists so a WIDTH pin can host the REAL surface** (the filter
/// batch's cold review, M1): a geometry case that measures a hand-built
/// stand-in proves things about the stand-in, so the fit law needs the real
/// view at a real narrow width. The default is the harness's own 393 × 852,
/// so every existing caller is byte-unchanged.
@MainActor
func withHostedSurface<Content: View, T>(
    _ view: Content,
    size: CGSize = CGSize(width: 393, height: 852),
    sourceLocation: SourceLocation = #_sourceLocation,
    _ body: (HostedSurface<Content>) async throws -> T
) async rethrows -> T {
    let surface = HostedSurface(view, size: size)
    defer {
        // Before anything is torn down: did this surface ever see a single
        // accessibility element? A surface that never did was walking a dead
        // tree, and an unarmed server must never read as an absent door.
        surface.checkAccessibilityTreeWasAlive(sourceLocation: sourceLocation)
        surface.tearDown()
    }
    await surface.settle()
    return try await body(surface)
}
