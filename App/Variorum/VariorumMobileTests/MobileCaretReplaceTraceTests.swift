//
//  MobileCaretReplaceTraceTests.swift
//  VariorumMobileTests
//
//  VM-24 (+ VM-19) — DIAGNOSTIC INSTRUMENTS, not pins (VM-78 batch C; the
//  record is `notes/plans/fixes/vm-78-fixes-to-whats-there.md`, BATCH C —
//  LIVE STATUS). They exist to answer, in one stage window, WHERE the
//  surface and the model first disagree on the standing caret red
//  (`MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePoint…`)
//  and on VM-19's stale-first-responder desync. THREE suite types, each run
//  ALONE by type name so no instrument's posture reaches another:
//  `MobileCaretReplaceTraceTests` (the red replace in the suite's posture,
//  in the real posture after a bounded wait, and with the settle held for
//  the act), `MobileCaretReplaceTeethTraceTests` (a settle write made to
//  land inside the replace's transaction by hand) and
//  `MobileStaleResponderTraceTests` (VM-19's leftover, then an insert).
//
//  Every test here PRINTS a trace, line by line as it happens — every line
//  tagged `VM24|…` or `VM19|…`, read from the run's log with
//  `grep -E 'VM(24|19)\|'` — and
//  asserts NOTHING about the outcome it measures (a red here would be a
//  harness failure, never a finding). What each line carries:
//  - `posture[…]`: the app, every scene and window (key, hidden, level,
//    which view holds first responder), the test window, the keyboard's
//    notifications since the trace began, `GCKeyboard`, the input modes and
//    the view's text-input traits.
//  - `gate`: each consult of the model's gate (`shouldChangeTextIn`) with
//    the storage's edit mask at that moment and the gate's answer.
//  - `sel` / `chg`: `textViewDidChangeSelection` / `textViewDidChange` —
//    the two roads the caret settle runs from — with the storage's edit
//    mask BEFORE and AFTER the model's handler ran, and whether any
//    `processEditing` fired in between. `WROTE-INSIDE` = the mask was
//    empty before, non-empty after, and nothing was processed: the
//    handler's attribute write landed inside an OPEN storage transaction
//    (H1's signature).
//  - `willProcess` / `didProcess`: every `processEditing` of the surface's
//    storage (mask, range, delta), and after it the model's desync count
//    and whether its index still measures the storage.
//  - `E1 …`: the model's own edit trace (`MobileEditTrace`, bound to a
//    task-local recorder for the act alone): consults, reports, a rejected
//    arming, the desync.
//  - a call stack (UIKit / Foundation / app frames only) on every event
//    inside the act — so the log names who reported the selection, from
//    inside which transaction.
//  - `VERDICT …`: one line per case, the run's headline.
//
//  The model's gate is wrapped by a forwarding proxy installed for the act
//  alone (the model holds its gate strongly; `UITextView.delegate` is
//  weak) — no product line is touched by any of this.
//
//  They leave the tree at the batch's end, in a named commit, unless one is
//  kept as a real guard (the record says which).
//

import Dependencies
import Foundation
import GameController
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The trace

@MainActor
final class CaretInputTrace {
    let tag: String
    private(set) var lines: [String] = []
    /// True for the act alone (the replace / insert under study).
    var inAct = false
    /// The decider's switch: while the act runs, the selection and change
    /// callbacks are NOT forwarded to the model (the settle is held), and
    /// the test replays one settle after the act.
    var holdSettlesDuringAct = false
    private(set) var heldSettles = 0
    private(set) var settleWroteInsideTransaction = false
    private(set) var firstCharacterReport: NSRange?
    private(set) var firstCharacterReportMask = ""
    private(set) var processCount = 0
    private(set) var keyboard = (willShow: 0, didShow: 0, willHide: 0, didHide: 0)
    private var lastKeyboardEnd: CGRect = .null
    private var observers: [NSObjectProtocol] = []
    private weak var storage: NSTextStorage?
    private weak var model: MobileEditorViewModel?
    private var proxy: CaretTraceGateProxy?
    private var innerGate: (NSObject & UITextViewDelegate)?

    init(tag: String) { self.tag = tag }

    /// Printed AS NOTED (a host crash mid-act keeps every line before it)
    /// and kept for the verdict.
    func note(_ line: String) {
        lines.append(line)
        print("\(tag)|\(line)")
    }

    // MARK: Watching

    /// Keyboard notifications from now on (posture: does a software
    /// keyboard present for this first responder?).
    func watchKeyboard() {
        let center = NotificationCenter.default
        let names: [(Notification.Name, Int)] = [
            (UIResponder.keyboardWillShowNotification, 0),
            (UIResponder.keyboardDidShowNotification, 1),
            (UIResponder.keyboardWillHideNotification, 2),
            (UIResponder.keyboardDidHideNotification, 3),
        ]
        for (name, which) in names {
            observers.append(center.addObserver(forName: name, object: nil, queue: nil) {
                [weak self] notification in
                let end = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                    as? NSValue)?.cgRectValue ?? .null
                MainActor.assumeIsolated { self?.keyboardEvent(which, end: end) }
            })
        }
    }

    private func keyboardEvent(_ which: Int, end: CGRect) {
        switch which {
        case 0: keyboard.willShow += 1
        case 1: keyboard.didShow += 1
        case 2: keyboard.willHide += 1
        default: keyboard.didHide += 1
        }
        lastKeyboardEnd = end
        let names = ["keyboardWillShow", "keyboardDidShow", "keyboardWillHide", "keyboardDidHide"]
        note("\(names[which]) end=\(Self.rect(end))\(inAct ? " ACT stack=\(Self.stack())" : "")")
    }

    /// Wraps the model's gate with the forwarding proxy and observes the
    /// surface's storage. Undone by `uninstall`.
    func install(on view: MobileEditorTextView, model: MobileEditorViewModel) {
        self.model = model
        self.storage = view.textStorage
        if let inner = view.delegate as? (NSObject & UITextViewDelegate) {
            innerGate = inner
            let proxy = CaretTraceGateProxy(inner: inner, trace: self)
            self.proxy = proxy
            view.delegate = proxy
        } else {
            note("install: the view's delegate is not the model's gate (\(String(describing: view.delegate)))")
        }
        let center = NotificationCenter.default
        observers.append(center.addObserver(
            forName: NSTextStorage.willProcessEditingNotification,
            object: view.textStorage, queue: nil
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.storageEvent(did: false) }
        })
        observers.append(center.addObserver(
            forName: NSTextStorage.didProcessEditingNotification,
            object: view.textStorage, queue: nil
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.storageEvent(did: true) }
        })
    }

    func uninstall(from view: MobileEditorTextView) {
        if let innerGate, view.delegate === proxy { view.delegate = innerGate }
        proxy = nil
        for observer in observers { NotificationCenter.default.removeObserver(observer) }
        observers.removeAll()
    }

    private func storageEvent(did: Bool) {
        guard let storage else { return }
        let mask = storage.editedMask
        let range = storage.editedRange
        let delta = storage.changeInLength
        if !did { processCount += 1 }
        var line = "\(did ? "didProcess" : "willProcess") mask=\(Self.mask(mask)) range=\(Self.range(range)) delta=\(delta)"
        if did, let model {
            line += " desync=\(model.desyncRecoveryCount) indexLen=\(model.index.documentLength) storageLen=\(storage.length)"
            if mask.contains(.editedCharacters), firstCharacterReport == nil, inAct {
                firstCharacterReport = range
                firstCharacterReportMask = Self.mask(mask)
            }
        }
        if inAct { line += " ACT stack=\(Self.stack())" }
        note(line)
    }

    // MARK: The proxy's callbacks

    fileprivate func gate(
        _ view: UITextView, range: NSRange, text: String, forward: () -> Bool
    ) -> Bool {
        let maskBefore = storage?.editedMask ?? []
        let answer = forward()
        note("gate range=\(Self.range(range)) repl=\(text.debugDescription) answer=\(answer) mask=\(Self.mask(maskBefore)) sel=\(Self.range(view.selectedRange))\(inAct ? " ACT stack=\(Self.stack())" : "")")
        return answer
    }

    fileprivate func callback(_ name: String, _ view: UITextView, forward: () -> Void) {
        let maskBefore = storage?.editedMask ?? []
        let selection = view.selectedRange
        if inAct, holdSettlesDuringAct {
            heldSettles += 1
            note("\(name) HELD sel=\(Self.range(selection)) mask=\(Self.mask(maskBefore)) ACT stack=\(Self.stack())")
            return
        }
        let processedBefore = processCount
        forward()
        let maskAfter = storage?.editedMask ?? []
        let processedDuring = processCount - processedBefore
        let wroteInside = maskBefore.isEmpty && !maskAfter.isEmpty && processedDuring == 0
        if wroteInside, inAct { settleWroteInsideTransaction = true }
        var line = "\(name) \(inAct ? "ACT" : "pre") sel=\(Self.range(selection)) maskBefore=\(Self.mask(maskBefore)) maskAfter=\(Self.mask(maskAfter)) processedDuring=\(processedDuring)"
        if wroteInside { line += " WROTE-INSIDE-TRANSACTION" }
        if inAct { line += " stack=\(Self.stack())" }
        note(line)
    }

    // MARK: Posture

    func posture(_ label: String, testWindow: UIWindow?, view: UITextView) {
        let app = UIApplication.shared
        note("posture[\(label)] app=\(Self.state(app.applicationState)) scenes=\(app.connectedScenes.count)")
        for (i, scene) in app.connectedScenes.enumerated() {
            guard let windowScene = scene as? UIWindowScene else {
                note("  scene\(i) \(type(of: scene)) act=\(Self.activation(scene.activationState))")
                continue
            }
            note("  scene\(i) act=\(Self.activation(windowScene.activationState)) keyWindow=\(Self.id(windowScene.keyWindow)) windows=\(windowScene.windows.count)")
            for window in windowScene.windows {
                note("    win \(Self.id(window)) \(type(of: window)) \(Int(window.bounds.width))x\(Int(window.bounds.height)) key=\(window.isKeyWindow) hidden=\(window.isHidden) level=\(window.windowLevel.rawValue) test=\(window === testWindow) fr=\(Self.firstResponder(in: window))")
            }
        }
        let windowLine = testWindow.map {
            "key=\($0.isKeyWindow) onScene=\($0.windowScene != nil) hidden=\($0.isHidden) id=\(Self.id($0))"
        } ?? "none"
        note("  test window: \(windowLine) · view fr=\(view.isFirstResponder) inTestWindow=\(testWindow != nil && view.window === testWindow) editable=\(view.isEditable)")
        note("  keyboard: willShow=\(keyboard.willShow) didShow=\(keyboard.didShow) willHide=\(keyboard.willHide) didHide=\(keyboard.didHide) lastEnd=\(Self.rect(lastKeyboardEnd)) gcKeyboard=\(GCKeyboard.coalesced != nil) modes=\(UITextInputMode.activeInputModes.compactMap(\.primaryLanguage)) viewMode=\(view.textInputMode?.primaryLanguage ?? "nil")")
        note("  traits: autocorrect=\(view.autocorrectionType.rawValue) spell=\(view.spellCheckingType.rawValue) smartQuotes=\(view.smartQuotesType.rawValue) smartDashes=\(view.smartDashesType.rawValue) smartInsert=\(view.smartInsertDeleteType.rawValue) inlinePrediction=\(view.inlinePredictionType.rawValue)")
    }

    /// The model's own edit trace (`MobileEditTrace`), copied in.
    func noteE1() {
        for event in MobileEditTrace.events { note("E1 " + MobileEditTrace.line(for: event)) }
        let summary = MobileEditTrace.summary
        note("E1 summary consults=\(summary.consults) reports=\(summary.reports) gateless=\(summary.gatelessReports) armingsRejected=\(summary.armingsRejected) mismatches=\(summary.mismatches) desyncs=\(summary.desyncRecoveries) maxConsultsBeforeAReport=\(summary.maxConsultsBeforeAReport)")
    }

    // MARK: Formatting

    nonisolated static func mask(_ mask: NSTextStorage.EditActions) -> String {
        var parts: [String] = []
        if mask.contains(.editedCharacters) { parts.append("chars") }
        if mask.contains(.editedAttributes) { parts.append("attrs") }
        return parts.isEmpty ? "none" : parts.joined(separator: "+")
    }

    nonisolated static func range(_ range: NSRange) -> String {
        range.location == NSNotFound ? "{NotFound}" : "{\(range.location),\(range.length)}"
    }

    nonisolated static func rect(_ rect: CGRect) -> String {
        rect.isNull ? "null" : "\(Int(rect.minX)),\(Int(rect.minY)) \(Int(rect.width))x\(Int(rect.height))"
    }

    nonisolated static func id(_ object: AnyObject?) -> String {
        guard let object else { return "nil" }
        let address = UInt(bitPattern: Unmanaged.passUnretained(object).toOpaque())
        return String(address & 0xFFFFF, radix: 16)
    }

    nonisolated static func state(_ state: UIApplication.State) -> String {
        switch state {
        case .active: "active"
        case .inactive: "inactive"
        case .background: "background"
        @unknown default: "unknown"
        }
    }

    nonisolated static func activation(_ state: UIScene.ActivationState) -> String {
        switch state {
        case .foregroundActive: "foregroundActive"
        case .foregroundInactive: "foregroundInactive"
        case .background: "background"
        case .unattached: "unattached"
        @unknown default: "unknown"
        }
    }

    static func firstResponder(in view: UIView) -> String {
        if view.isFirstResponder { return "\(type(of: view))@\(id(view))" }
        for sub in view.subviews {
            let found = firstResponder(in: sub)
            if found != "-" { return found }
        }
        return "-"
    }

    /// UIKit / Foundation / app frames only, innermost first, the "+ offset"
    /// tails dropped — enough to name who called, from inside what.
    nonisolated static func stack(limit: Int = 26) -> String {
        let keep = ["UIKitCore", "UIFoundation", "Foundation", "VariorumMobile", "TextInput", "UIKit"]
        var frames: [String] = []
        for raw in Thread.callStackSymbols.dropFirst(2) {
            let parts = raw.split(separator: " ", omittingEmptySubsequences: true)
            guard parts.count >= 4 else { continue }
            let module = String(parts[1])
            guard keep.contains(where: { module.hasPrefix($0) }),
                  !module.hasPrefix("VariorumMobileTests") else { continue }
            let symbol = parts[3...].joined(separator: " ")
            let trimmed = symbol.components(separatedBy: " + ").first ?? symbol
            frames.append(String(trimmed.prefix(96)))
            if frames.count >= limit { break }
        }
        return frames.joined(separator: " < ")
    }
}

/// The model's gate behind a forwarding proxy: the three callbacks the
/// trace needs are observed (and forwarded unchanged unless the decider
/// holds the settle); every other delegate message forwards untouched.
@MainActor
final class CaretTraceGateProxy: NSObject, UITextViewDelegate {
    nonisolated(unsafe) let inner: NSObject & UITextViewDelegate
    private weak var trace: CaretInputTrace?

    init(inner: NSObject & UITextViewDelegate, trace: CaretInputTrace) {
        self.inner = inner
        self.trace = trace
    }

    nonisolated override func responds(to aSelector: Selector!) -> Bool {
        super.responds(to: aSelector) || inner.responds(to: aSelector)
    }

    nonisolated override func forwardingTarget(for aSelector: Selector!) -> Any? {
        inner.responds(to: aSelector) ? inner : super.forwardingTarget(for: aSelector)
    }

    func textView(
        _ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String
    ) -> Bool {
        let forward: () -> Bool = {
            self.inner.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
        }
        guard let trace else { return forward() }
        return trace.gate(textView, range: range, text: text, forward: forward)
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        let forward: () -> Void = { _ = self.inner.textViewDidChangeSelection?(textView) }
        guard let trace else { return forward() }
        trace.callback("sel", textView, forward: forward)
    }

    func textViewDidChange(_ textView: UITextView) {
        let forward: () -> Void = { _ = self.inner.textViewDidChange?(textView) }
        guard let trace else { return forward() }
        trace.callback("chg", textView, forward: forward)
    }
}

// MARK: - Hosts

@MainActor
enum CaretTraceHost {
    /// `MobileMarkdownCaretTests.host(_:)` byte for byte: a window on the
    /// foreground scene, leftovers resigned, key, the view first responder.
    static func sceneWindow(_ surface: MobileWriteSurfaceView) -> UIWindow {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        let window = scene.map { UIWindow(windowScene: $0) }
            ?? UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
        window.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
        let controller = UIViewController()
        controller.view.addSubview(surface)
        window.rootViewController = controller
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        window.makeKeyAndVisible()
        _ = surface.textView.becomeFirstResponder()
        return window
    }

    /// The caret suite's posture BEFORE VX-282's keyfix: a bare frame
    /// window (never a scene's), no leftover resigned.
    static func frameWindow(_ surface: MobileWriteSurfaceView) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
        let controller = UIViewController()
        controller.view.addSubview(surface)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        _ = surface.textView.becomeFirstResponder()
        return window
    }

    static func dismiss(_ window: UIWindow, _ surface: MobileWriteSurfaceView) {
        _ = surface.textView.resignFirstResponder()
        window.isHidden = true
        window.rootViewController = nil
    }

    /// Bounded: until the window is key, the view first responder and the
    /// keyboard's presentation (if one began) has finished — at least a
    /// few turns either way, so UIKit's deferred work gets to run.
    static func waitForTheRealPosture(
        _ window: UIWindow, _ view: UITextView, trace: CaretInputTrace
    ) async -> Int {
        var spins = 0
        while spins < 300 {
            let keyboardSettled = trace.keyboard.willShow == trace.keyboard.didShow
            if spins >= 20, window.isKeyWindow, view.isFirstResponder, keyboardSettled { break }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
            spins += 1
        }
        return spins
    }
}

/// A weak handle (the polluter is left to UIKit's own retention, exactly as
/// the liveness test leaves it).
@MainActor
final class WeakTextView {
    weak var value: MobileEditorTextView?
    init(_ value: MobileEditorTextView) { self.value = value }
}

// MARK: - The instruments

/// The rescue-point replace, traced (the shared body of the VM-24 suites).
@MainActor
enum CaretReplaceTrace {
    nonisolated static let replacements = ["Hello", "hi", "hello there"]

    enum Variant: String, Sendable, CaseIterable {
        /// The red test's own posture and timing: no turn between host and act.
        case suitePosture
        /// The same, after waiting until the window is key, the view first
        /// responder and the keyboard settled (H2's decider).
        case realPosture
        /// The suite's posture with the selection/change callbacks HELD for
        /// the act and one settle replayed after it (H1's decider).
        case settleHeld
        /// The assertion's teeth: the settle made to write inside an explicit
        /// storage transaction that the replace then joins (the product rule
        /// "no face write joins an edit's transaction" broken by hand, test
        /// side — red by construction in any posture).
        case writeInsideByHand
    }

    /// Two fresh worlds per case (does the red hold within one process?).
    static func run(_ variant: Variant, _ replacement: String) async throws {
        for iteration in 1...2 {
            try await traceOneReplace(variant, replacement, iteration: iteration)
        }
    }

    private static func traceOneReplace(
        _ variant: Variant, _ replacement: String, iteration: Int
    ) async throws {
        try await withEditorAssertionsMuted {
            try await withEditorWorld { session, _ in
                MobileEditorStyle.voice = .study
                defer { MobileEditorStyle.voice = .terminal }
                let trace = CaretInputTrace(
                    tag: "VM24|\(variant.rawValue)|\(replacement)|#\(iteration)")
                trace.watchKeyboard()
                let postID = try await makePost(session, blocks: ["*hello *", "next block"])
                let (model, surface) = await makeSurfaceEditor(session, postID: postID)
                let view = surface.textView
                let storage = view.textStorage
                trace.posture("before-host", testWindow: nil, view: view)
                let window = CaretTraceHost.sceneWindow(surface)
                defer { CaretTraceHost.dismiss(window, surface) }
                trace.posture("after-host", testWindow: window, view: view)
                if variant == .realPosture {
                    let spins = await CaretTraceHost.waitForTheRealPosture(window, view, trace: trace)
                    trace.note("waited spins=\(spins)")
                    trace.posture("after-wait", testWindow: window, view: view)
                }

                view.selectedRange = NSRange(location: 7, length: 0)
                let honouredBefore = (1..<7).allSatisfy { isItalic(storage, at: $0) }
                trace.note("pre-act honoured=\(honouredBefore) string=\(storage.string.debugDescription) sel=\(CaretInputTrace.range(view.selectedRange)) desync=\(model.desyncRecoveryCount)")
                trace.posture("at-act", testWindow: window, view: view)

                let start = try #require(view.position(from: view.beginningOfDocument, offset: 1))
                let end = try #require(view.position(from: start, offset: 5))
                let range = try #require(view.textRange(from: start, to: end))

                trace.install(on: view, model: model)
                trace.holdSettlesDuringAct = variant == .settleHeld
                let desyncBefore = model.desyncRecoveryCount
                MobileEditTrace.$testRecorder.withValue(MobileEditTrace.Recorder(armed: true)) {
                    trace.inAct = true
                    if variant == .writeInsideByHand {
                        storage.beginEditing()
                        // The caret leaves the rescue point: the settle clears
                        // the honour — its write lands inside OUR open
                        // transaction (the mask is still empty).
                        view.selectedRange = NSRange(location: 0, length: 0)
                        view.replace(range, withText: replacement)
                        storage.endEditing()
                    } else {
                        view.replace(range, withText: replacement)
                    }
                    trace.inAct = false
                    trace.noteE1()
                }
                if variant == .settleHeld {
                    model.settleMarkdownCaret()
                    trace.note("held=\(trace.heldSettles) — one settle replayed after the act")
                }
                trace.uninstall(from: view)

                let length = (replacement as NSString).length
                let caret = view.selectedRange
                let honouredAfter = caret == NSRange(location: length + 2, length: 0)
                    ? (1..<(length + 2)).allSatisfy { isItalic(storage, at: $0) }
                    : nil
                trace.note("post-act string=\(storage.string.debugDescription) sel=\(CaretInputTrace.range(caret)) desync=\(model.desyncRecoveryCount) audit=\(model.identityAuditFailures) indexLen=\(model.index.documentLength) storageLen=\(storage.length) honouredAtRescue=\(honouredAfter.map(String.init(describing:)) ?? "n/a")")
                trace.posture("after-act", testWindow: window, view: view)
                trace.note("VERDICT variant=\(variant.rawValue) case=\(replacement.debugDescription) iteration=\(iteration) desync=\(model.desyncRecoveryCount - desyncBefore) settleWroteInside=\(trace.settleWroteInsideTransaction) held=\(trace.heldSettles) firstCharReport=\(trace.firstCharacterReport.map(CaretInputTrace.range) ?? "none")/\(trace.firstCharacterReportMask) key=\(window.isKeyWindow) fr=\(view.isFirstResponder) kbdWillShow=\(trace.keyboard.willShow)")
            }
        }
    }

    static func isItalic(_ storage: NSTextStorage, at offset: Int) -> Bool {
        (storage.attribute(.font, at: offset, effectiveRange: nil) as? UIFont)?
            .fontDescriptor.symbolicTraits.contains(.traitItalic) ?? false
    }
}

/// VM-24 — the red test's replace in three postures (run ALONE by type).
@MainActor
@Suite("VM-24 — the caret red's trace: suite posture, real posture, settle held (DIAGNOSTIC)", .serialized)
struct MobileCaretReplaceTraceTests {
    @Test(arguments: CaretReplaceTrace.replacements)
    func vm24_suitePosture(_ replacement: String) async throws {
        try await CaretReplaceTrace.run(.suitePosture, replacement)
    }

    @Test(arguments: CaretReplaceTrace.replacements)
    func vm24_realPosture(_ replacement: String) async throws {
        try await CaretReplaceTrace.run(.realPosture, replacement)
    }

    @Test(arguments: CaretReplaceTrace.replacements)
    func vm24_settleHeld(_ replacement: String) async throws {
        try await CaretReplaceTrace.run(.settleHeld, replacement)
    }
}

/// VM-24 — the assertion's teeth, its own type (it opens a storage
/// transaction around UIKit's replace; if TextKit objects, only this run
/// pays).
@MainActor
@Suite("VM-24 — the assertion's teeth: a settle write inside the replace's transaction (DIAGNOSTIC)", .serialized)
struct MobileCaretReplaceTeethTraceTests {
    @Test(arguments: CaretReplaceTrace.replacements)
    func vm24_writeInsideByHand(_ replacement: String) async throws {
        try await CaretReplaceTrace.run(.writeInsideByHand, replacement)
    }
}

/// VM-19 — a stale first responder, then an insert of a run (run ALONE by
/// type: its polluter must not reach another suite).
@MainActor
@Suite("VM-19 — a stale first responder, then an insert of a run (DIAGNOSTIC)", .serialized)
struct MobileStaleResponderTraceTests {
    enum Victim: String, Sendable, CaseIterable {
        /// The caret suite's posture before VX-282's keyfix (C-1's red one).
        case frameWindow
        /// The keyfix posture (the scene's window, leftovers resigned, key).
        case sceneWindow
    }

    /// `MobileLivenessTests.arrivalRaisesFocusBeforeTheObservationLoops`'
    /// exact leftover, built on purpose in its own world: a text view raised
    /// to first responder in a frame window that is then only HIDDEN, never
    /// resigned, its locals dropped as the test returns.
    private func leaveAStaleFirstResponder() async throws -> WeakTextView {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["the polluter"])
            let (_, surface) = await makeSurfaceEditor(session, postID: postID)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
            window.addSubview(surface)
            window.makeKeyAndVisible()
            defer { window.isHidden = true }
            _ = surface.textView.becomeFirstResponder()
            for _ in 0..<20 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            return WeakTextView(surface.textView)
        }
    }

    @Test(arguments: Victim.allCases, [true, false])
    func vm19_traceAnInsertOfARunAfterAStaleFirstResponder(
        _ victim: Victim, _ polluted: Bool
    ) async throws {
        let polluter: WeakTextView? = if polluted { try await leaveAStaleFirstResponder() } else { nil }
        defer { _ = polluter?.value?.resignFirstResponder() }
        try await withEditorAssertionsMuted {
            try await withEditorWorld { session, _ in
                MobileEditorStyle.voice = .study
                defer { MobileEditorStyle.voice = .terminal }
                let trace = CaretInputTrace(
                    tag: "VM19|\(victim.rawValue)|\(polluted ? "polluted" : "clean")")
                trace.watchKeyboard()
                trace.note("polluter alive=\(polluter?.value != nil) fr=\(polluter?.value?.isFirstResponder ?? false) window=\(CaretInputTrace.id(polluter?.value?.window)) windowHidden=\(polluter?.value?.window?.isHidden ?? true)")
                let postID = try await makePost(session, blocks: ["**", "next block"])
                let (model, surface) = await makeSurfaceEditor(session, postID: postID)
                let view = surface.textView
                let storage = view.textStorage
                let window = victim == .frameWindow
                    ? CaretTraceHost.frameWindow(surface)
                    : CaretTraceHost.sceneWindow(surface)
                defer { CaretTraceHost.dismiss(window, surface) }
                view.selectedRange = NSRange(location: 1, length: 0)
                trace.note("polluter at act alive=\(polluter?.value != nil) fr=\(polluter?.value?.isFirstResponder ?? false)")
                trace.posture("at-act", testWindow: window, view: view)

                trace.install(on: view, model: model)
                let desyncBefore = model.desyncRecoveryCount
                MobileEditTrace.$testRecorder.withValue(MobileEditTrace.Recorder(armed: true)) {
                    trace.inAct = true
                    view.insertText("hello ")
                    trace.inAct = false
                    trace.noteE1()
                }
                trace.uninstall(from: view)
                trace.note("post-act string=\(storage.string.debugDescription) sel=\(CaretInputTrace.range(view.selectedRange)) desync=\(model.desyncRecoveryCount) audit=\(model.identityAuditFailures) indexLen=\(model.index.documentLength) storageLen=\(storage.length)")
                trace.note("VERDICT victim=\(victim.rawValue) polluted=\(polluted) desync=\(model.desyncRecoveryCount - desyncBefore) settleWroteInside=\(trace.settleWroteInsideTransaction) firstCharReport=\(trace.firstCharacterReport.map(CaretInputTrace.range) ?? "none")/\(trace.firstCharacterReportMask) key=\(window.isKeyWindow) fr=\(view.isFirstResponder) polluterFR=\(polluter?.value?.isFirstResponder ?? false) kbdWillShow=\(trace.keyboard.willShow)")
            }
        }
    }
}
