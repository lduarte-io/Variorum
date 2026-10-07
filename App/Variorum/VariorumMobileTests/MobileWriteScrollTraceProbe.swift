//
//  MobileWriteScrollTraceProbe.swift
//  VariorumMobileTests
//
//  VM-10 TRACE PROBE — TEMPORARY (deleted before the batch closes; the pins
//  live in MobileWriteScrollAuthorityTests). Hosts the REAL MobileWriteScreen
//  in a scene-attached key window, records every contentOffset change with
//  the call stack that made it, and prints `TRACE[...]` lines for the record.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
final class ScrollTraceRecorder {
    struct Change {
        let y: CGFloat
        let stack: [String]
    }
    private(set) var changes: [Change] = []
    private var token: NSKeyValueObservation?
    let label: String

    init(_ view: UITextView, label: String) {
        self.label = label
        token = view.observe(\.contentOffset, options: [.new]) { [weak self] _, change in
            let y = change.newValue?.y ?? .nan
            let stack = Thread.callStackSymbols
            MainActor.assumeIsolated {
                self?.changes.append(Change(y: y, stack: stack))
            }
        }
    }

    func reset() { changes = [] }

    func dump(_ tag: String) {
        print("TRACE[\(label)] \(tag): \(changes.count) contentOffset changes")
        var lastY: CGFloat = .nan
        for (i, c) in changes.enumerated() {
            if c.y == lastY { continue }
            lastY = c.y
            let interesting = c.stack.dropFirst(1).filter {
                $0.contains("UIKit") || $0.contains("VariorumMobile")
                    || $0.contains("UIFoundation") || $0.contains("SwiftUI")
            }.prefix(14).map { line -> String in
                // compress "N  Module  0x...  symbol + off"
                let parts = line.split(separator: " ", omittingEmptySubsequences: true)
                return parts.count > 3 ? parts[3...].joined(separator: " ") : line
            }
            print("TRACE[\(label)]   #\(i) y=\(c.y)")
            for frame in interesting { print("TRACE[\(label)]       \(frame)") }
        }
    }
}

/// Swizzled scroll entry points — record the INITIATOR of every
/// programmatic scroll on a MobileEditorTextView (KVO only sees frames).
extension UIScrollView {
    @objc dynamic func vm10_setContentOffset(_ offset: CGPoint, animated: Bool) {
        if self is MobileEditorTextView {
            ScrollInitiators.record("setContentOffset(\(offset.y), animated: \(animated))")
        }
        vm10_setContentOffset(offset, animated: animated)
    }
    @objc dynamic func vm10_scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        if self is MobileEditorTextView {
            ScrollInitiators.record("scrollRectToVisible(\(rect), animated: \(animated))")
        }
        vm10_scrollRectToVisible(rect, animated: animated)
    }
}

extension UITextView {
    @objc dynamic func vm10_scrollRangeToVisible(_ range: NSRange) {
        if self is MobileEditorTextView {
            ScrollInitiators.record("scrollRangeToVisible(\(range))")
        }
        vm10_scrollRangeToVisible(range)
    }
}

enum ScrollInitiators {
    nonisolated(unsafe) static var log: [(String, [String])] = []
    nonisolated(unsafe) static var installed = false
    static func record(_ what: String) {
        log.append((what, Thread.callStackSymbols))
    }
    static func install() {
        guard !installed else { return }
        installed = true
        func swap(_ cls: AnyClass, _ a: Selector, _ b: Selector) {
            guard let m1 = class_getInstanceMethod(cls, a),
                  let m2 = class_getInstanceMethod(cls, b) else { return }
            method_exchangeImplementations(m1, m2)
        }
        swap(UIScrollView.self, #selector(UIScrollView.setContentOffset(_:animated:)),
             #selector(UIScrollView.vm10_setContentOffset(_:animated:)))
        swap(UIScrollView.self, #selector(UIScrollView.scrollRectToVisible(_:animated:)),
             #selector(UIScrollView.vm10_scrollRectToVisible(_:animated:)))
        swap(UITextView.self, #selector(UITextView.scrollRangeToVisible(_:)),
             #selector(UITextView.vm10_scrollRangeToVisible(_:)))
    }
    static func dump(_ label: String) {
        print("TRACE[\(label)] initiators: \(log.count)")
        for (what, stack) in log {
            print("TRACE[\(label)]   >> \(what)")
            let frames = stack.dropFirst(1).prefix(14)
            for f in frames {
                let parts = f.split(separator: " ", omittingEmptySubsequences: true)
                print("TRACE[\(label)]        \(parts.count > 3 ? parts[3...].joined(separator: " ") : f)")
            }
        }
        log = []
    }
}

/// Forces the SOFTWARE keyboard on a headless simulator (WebKitTestRunner's
/// in-process route: GraphicsServices + the UIKeyboard class-method swizzle).
enum SoftwareKeyboard {
    nonisolated(unsafe) static var forced = false
    @MainActor static func force() {
        guard !forced else { return }
        forced = true
        if let h = dlopen("/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices", RTLD_NOW),
           let sym = dlsym(h, "GSEventSetHardwareKeyboardAttached") {
            typealias F = @convention(c) (Bool, UInt8) -> Void
            unsafeBitCast(sym, to: F.self)(false, 0)
        }
        if let cls: AnyClass = NSClassFromString("UIKeyboard"),
           let m = class_getClassMethod(cls, NSSelectorFromString("isInHardwareKeyboardMode")) {
            let block: @convention(block) (AnyObject) -> Bool = { _ in false }
            method_setImplementation(m, imp_implementationWithBlock(block))
        }
        if let impl = NSClassFromString("UIKeyboardImpl") as? NSObject.Type {
            let shared = impl.perform(NSSelectorFromString("sharedInstance"))?.takeUnretainedValue() as? NSObject
            let sel = NSSelectorFromString("setAutomaticMinimizationEnabled:")
            if let shared, shared.responds(to: sel) {
                typealias S = @convention(c) (AnyObject, Selector, Bool) -> Void
                let imp = shared.method(for: sel)
                unsafeBitCast(imp, to: S.self)(shared, sel, false)
            }
        }
    }
}

@MainActor
func traceSnapshot(_ tv: UITextView, _ label: String, _ tag: String) {
    let kb = (tv.superview?.keyboardLayoutGuide.layoutFrame) ?? .zero
    let topPoint = CGPoint(x: 30, y: tv.contentOffset.y + tv.adjustedContentInset.top + 4)
    let firstVisible = tv.closestPosition(to: topPoint).map {
        tv.offset(from: tv.beginningOfDocument, to: $0)
    } ?? -1
    let bottomPoint = CGPoint(
        x: 30, y: tv.contentOffset.y + tv.bounds.height - tv.adjustedContentInset.bottom - 4)
    let lastVisible = tv.closestPosition(to: bottomPoint).map {
        tv.offset(from: tv.beginningOfDocument, to: $0)
    } ?? -1
    let caretRect = tv.selectedTextRange.map { tv.caretRect(for: $0.end) } ?? .null
    print("""
        TRACE[\(label)] \(tag): offsetY=\(tv.contentOffset.y) contentH=\(tv.contentSize.height) \
        boundsH=\(tv.bounds.height) adjInset=(\(tv.adjustedContentInset.top),\(tv.adjustedContentInset.bottom)) \
        tcInsetBottom=\(tv.textContainerInset.bottom) sel=\(tv.selectedRange) len=\(tv.textStorage.length) \
        firstResponder=\(tv.isFirstResponder) kbGuide=\(kb) caretY=\(caretRect.minY) \
        firstVisibleChar=\(firstVisible) lastVisibleChar=\(lastVisible) \
        dragging=\(tv.isDragging) tracking=\(tv.isTracking) decel=\(tv.isDecelerating)
        """)
}

@MainActor
final class TraceHost<Content: View> {
    let window: UIWindow
    let host: UIHostingController<Content>
    init(_ view: Content, size: CGSize = CGSize(width: 402, height: 874)) {
        AccessibilityServer.armOnce()
        host = UIHostingController(rootView: view)
        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first {
            window = UIWindow(windowScene: scene)
            window.frame = CGRect(origin: .zero, size: size)
        } else {
            window = UIWindow(frame: CGRect(origin: .zero, size: size))
        }
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.layoutIfNeeded()
    }
    func settle(_ turns: Int = 20) async {
        for _ in 0..<turns {
            try? await Task.sleep(for: .milliseconds(20))
            await Task.yield()
            host.view.setNeedsLayout()
            host.view.layoutIfNeeded()
        }
    }
    func tearDown() {
        window.endEditing(true)
        window.isHidden = true
        window.rootViewController = nil
    }
}

/// A minimal accessibility driver over any window (HostedSurface's walk).
@MainActor
struct HostedSurfaceProbe {
    let window: UIWindow
    var elements: [NSObject] {
        HostedSurface<EmptyView>.elements(of: window)
    }
    var labels: [String] { elements.compactMap(\.accessibilityLabel) }
    func activate(_ label: String) -> Bool {
        guard let e = elements.first(where: { $0.accessibilityLabel == label }) else { return false }
        return e.accessibilityActivate()
    }
    func activateContaining(_ label: String) -> Bool {
        guard let e = elements.first(where: { $0.accessibilityLabel?.contains(label) == true })
        else { return false }
        return e.accessibilityActivate()
    }
}

@MainActor
func seedTraceNote(_ session: AppSession, paragraphs: Int) async throws -> String {
    let blocks = (1...paragraphs).map { n in
        "Paragraph \(n) carries enough plain words to wrap across a couple of lines on a phone page."
    }
    return try await makePost(session, blocks: blocks)
}

@MainActor
func findTextView(in view: UIView) -> MobileEditorTextView? {
    if let tv = view as? MobileEditorTextView { return tv }
    for sub in view.subviews {
        if let tv = findTextView(in: sub) { return tv }
    }
    return nil
}

@MainActor
func saveTraceImage(_ window: UIWindow, _ name: String) {
    let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
    let image = renderer.image { _ in
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
    }
    let dir = "/private/tmp/claude-501/-<home>-dev-variorum-mobile/95a74e73-2bb7-4643-b40f-1bbd2d856792/scratchpad/trace-img"
    try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    try? image.pngData()?.write(to: URL(fileURLWithPath: "\(dir)/\(name).png"))
}

@MainActor
@Suite("VM-10 TRACE PROBE (temporary)", .serialized)
struct MobileWriteScrollTraceProbe {
    /// The real road: the shell, the Library tab, the note's row — a real
    /// NavigationStack push.
    @Test func traceShellOpen() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "Scroll trace long note", profile: .blog)
                for n in 1...30 {
                    _ = try ops.newBlock(
                        in: post.id,
                        text: "Paragraph \(n) carries enough plain words to wrap across a couple of lines on a phone page.",
                        at: .end, registeringUndo: false)
                }
                return post.id
            }
            _ = postID
            let router = MobileShellRouter()
            let host = TraceHost(MobileShellView(session: session, services: nil, router: router))
            defer { host.tearDown() }
            await host.settle(30)
            let surface = HostedSurfaceProbe(window: host.window)
            #expect(surface.activate("Library"), "labels \(surface.labels)")
            await host.settle(40)
            saveTraceImage(host.window, "shell-library")
            print("TRACE[shell] labels: \(surface.labels.prefix(40))")
            let opened = surface.activate("Scroll trace long note")
                || surface.activateContaining("Scroll trace long note")
            #expect(opened, "labels \(surface.labels)")
            var tv: MobileEditorTextView?
            var recorder: ScrollTraceRecorder?
            for _ in 0..<300 {
                if let found = findTextView(in: host.window) {
                    tv = found
                    if recorder == nil { recorder = ScrollTraceRecorder(found, label: "shell open") }
                    if found.textStorage.length > 0 { break }
                }
                try? await Task.sleep(for: .milliseconds(5))
                await Task.yield()
            }
            let view = try #require(tv)
            traceSnapshot(view, "shell open", "first text")
            await host.settle(25)
            traceSnapshot(view, "shell open", "+0.5s")
            await host.settle(75)
            traceSnapshot(view, "shell open", "+2s")
            saveTraceImage(host.window, "shell-open-settled")
            recorder?.dump("shell open")
        }
    }

    @Test func traceArrival() async throws {
        for focus in [false, true] {
            try await withEditorWorld { session, _ in
                let postID = try await seedTraceNote(session, paragraphs: 30)
                let model = MobileEditorViewModel(session: session, postID: postID)
                let host = TraceHost(MobileWriteScreen(
                    session: session, postID: postID, beginEditing: focus, editor: model))
                defer { host.tearDown() }
                let label = "arrival focus=\(focus)"
                var recorder: ScrollTraceRecorder?
                for _ in 0..<200 {
                    if let tv = model.textView { recorder = ScrollTraceRecorder(tv, label: label); break }
                    await host.settle(1)
                }
                let tv = try #require(model.textView)
                traceSnapshot(tv, label, "t0")
                await host.settle(25)
                traceSnapshot(tv, label, "t+0.5s")
                await host.settle(75)
                traceSnapshot(tv, label, "t+2s")
                recorder?.dump("arrival")
            }
        }
    }

    /// THE FIGHT: ⏎ + a typed word at the end, she scrolls up, the idle
    /// mint (2 s) fires — does anything pull her back down?
    @Test func traceFight() async throws {
        ScrollInitiators.install()
        try await withEditorWorld { session, _ in
            let postID = try await seedTraceNote(session, paragraphs: 30)
            let model = MobileEditorViewModel(session: session, postID: postID)
            let host = TraceHost(MobileWriteScreen(
                session: session, postID: postID, beginEditing: true, editor: model))
            defer { host.tearDown() }
            let label = "fight"
            for _ in 0..<200 {
                if let tv = model.textView, tv.textStorage.length > 0 { break }
                await host.settle(1)
            }
            let tv = try #require(model.textView)
            await host.settle(50)
            let caret = tv.textStorage.length
            tv.selectedRange = NSRange(location: caret, length: 0)
            let r = tv.caretRect(for: tv.selectedTextRange!.end)
            tv.setContentOffset(CGPoint(x: 0, y: r.maxY - tv.bounds.height + 4), animated: false)
            await host.settle(20)
            tv.insertText("\n")
            for ch in "A new thought" { tv.insertText(String(ch)) }
            await host.settle(25)
            traceSnapshot(tv, label, "after ⏎ + typing")
            ScrollInitiators.log = []
            let recorder = ScrollTraceRecorder(tv, label: label)
            let up = max(0, tv.contentOffset.y - 400)
            tv.setContentOffset(CGPoint(x: 0, y: up), animated: false)
            traceSnapshot(tv, label, "scrolled up")
            for step in 1...10 {
                await host.settle(25)
                traceSnapshot(tv, label, "scrolled up +\(Double(step) * 0.5)s mintInFlight=\(model.mintInFlight) open=\(model.hasOpenTail) fullRenders=\(model.fullRenderCount)")
            }
            recorder.dump("after scroll-up")
            ScrollInitiators.dump(label + " after scroll-up")
        }
    }

    @Test func traceKeyboard() async throws {
        ScrollInitiators.install()
        SoftwareKeyboard.force()
        for paragraphs in [30, 3] {
            try await withEditorWorld { session, _ in
                let postID = try await seedTraceNote(session, paragraphs: paragraphs)
                let model = MobileEditorViewModel(session: session, postID: postID)
                let host = TraceHost(MobileWriteScreen(
                    session: session, postID: postID, beginEditing: true, editor: model))
                defer { host.tearDown() }
                let label = "kb p=\(paragraphs)"
                var recorder: ScrollTraceRecorder?
                for _ in 0..<200 {
                    if let tv = model.textView { recorder = ScrollTraceRecorder(tv, label: label); break }
                    await host.settle(1)
                }
                let tv = try #require(model.textView)
                for step in 1...6 {
                    await host.settle(25)
                    traceSnapshot(tv, label, "arrival +\(Double(step) * 0.5)s")
                }
                saveTraceImage(host.window, "kb-arrival-p\(paragraphs)")
                recorder?.dump("arrival")
                ScrollInitiators.dump(label + " arrival")
                // Tap-to-continue: caret to the END (her finger in the room).
                tv.selectedRange = NSRange(location: tv.textStorage.length, length: 0)
                await host.settle(30)
                traceSnapshot(tv, label, "caret to end")
                ScrollInitiators.dump(label + " caret to end")
                saveTraceImage(host.window, "kb-caretend-p\(paragraphs)")
                tv.insertText("\n")
                await host.settle(30)
                traceSnapshot(tv, label, "after ⏎")
                ScrollInitiators.dump(label + " ⏎")
                saveTraceImage(host.window, "kb-return-p\(paragraphs)")
            }
        }
    }

    @Test func traceTapToContinue() async throws {
        ScrollInitiators.install()
        SoftwareKeyboard.force()
        for (paragraphs, selectFirst) in [(8, true), (8, false), (5, true)] {
            try await withEditorWorld { session, _ in
                let postID = try await seedTraceNote(session, paragraphs: paragraphs)
                let model = MobileEditorViewModel(session: session, postID: postID)
                let host = TraceHost(MobileWriteScreen(
                    session: session, postID: postID, beginEditing: false, editor: model))
                defer { host.tearDown() }
                let label = "tap p=\(paragraphs) selectFirst=\(selectFirst)"
                for _ in 0..<200 {
                    if let tv = model.textView, tv.textStorage.length > 0 { break }
                    await host.settle(1)
                }
                let tv = try #require(model.textView)
                await host.settle(30)
                traceSnapshot(tv, label, "opened")
                saveTraceImage(host.window, "tap-opened-p\(paragraphs)")
                ScrollInitiators.log = []
                if selectFirst {
                    tv.selectedRange = NSRange(location: tv.textStorage.length, length: 0)
                    _ = tv.becomeFirstResponder()
                } else {
                    _ = tv.becomeFirstResponder()
                    tv.selectedRange = NSRange(location: tv.textStorage.length, length: 0)
                }
                for step in 1...4 {
                    await host.settle(25)
                    traceSnapshot(tv, label, "tapped +\(Double(step) * 0.5)s")
                }
                saveTraceImage(host.window, "tap-settled-p\(paragraphs)-\(selectFirst)")
                ScrollInitiators.dump(label + " tap")
            }
        }
    }

    @Test func traceGeometryWhileScrolledAway() async throws {
        ScrollInitiators.install()
        SoftwareKeyboard.force()
        try await withEditorWorld { session, _ in
            let postID = try await seedTraceNote(session, paragraphs: 30)
            let model = MobileEditorViewModel(session: session, postID: postID)
            let host = TraceHost(MobileWriteScreen(
                session: session, postID: postID, beginEditing: true, editor: model))
            defer { host.tearDown() }
            let label = "geom"
            for _ in 0..<200 {
                if let tv = model.textView, tv.textStorage.length > 0 { break }
                await host.settle(1)
            }
            let tv = try #require(model.textView)
            await host.settle(40)
            tv.selectedRange = NSRange(location: tv.textStorage.length, length: 0)
            await host.settle(30)
            tv.insertText("\n")
            await host.settle(30)
            traceSnapshot(tv, label, "after ⏎")
            tv.setContentOffset(CGPoint(x: 0, y: tv.contentOffset.y - 500), animated: false)
            await host.settle(10)
            traceSnapshot(tv, label, "scrolled up 500")
            ScrollInitiators.log = []
            // The interactive keyboard engaging: the guide (and so the text
            // view) changes height and springs back.
            let surface = tv.superview!
            let original = surface.frame
            surface.frame.size.height = original.height - 120
            surface.layoutIfNeeded()
            await host.settle(15)
            traceSnapshot(tv, label, "shrunk 120")
            surface.frame = original
            surface.layoutIfNeeded()
            await host.settle(30)
            traceSnapshot(tv, label, "restored")
            ScrollInitiators.dump(label + " geometry")
            // Keyboard down and up again, RIGHT AFTER her pan's release (the
            // interactive spring-back's timing — her pan stamped).
            ScrollInitiators.log = []
            tv.setContentOffset(CGPoint(x: 0, y: max(0, tv.contentOffset.y - 200)), animated: false)
            (tv as? MobileEditorTextView)?.noteHerScroll()
            traceSnapshot(tv, label, "scrolled up again (pan released)")
            _ = tv.resignFirstResponder()
            await host.settle(5)
            traceSnapshot(tv, label, "keyboard down")
            _ = tv.becomeFirstResponder()
            await host.settle(12)
            traceSnapshot(tv, label, "keyboard up again (within her window)")
            await host.settle(40)
            traceSnapshot(tv, label, "keyboard up again +1s")
            ScrollInitiators.dump(label + " keyboard round trip")
            // A deliberate refocus long after any pan: the ordinary reveal —
            // five rounds (the tracking-element road is timing-dependent).
            for round in 1...5 {
                ScrollInitiators.log = []
                tv.setContentOffset(CGPoint(x: 0, y: max(0, tv.contentOffset.y - 400)), animated: false)
                await host.settle(40)
                _ = tv.resignFirstResponder()
                await host.settle(40)
                _ = tv.becomeFirstResponder()
                await host.settle(60)
                traceSnapshot(tv, label, "refocus round \(round)")
                let tracking = ScrollInitiators.log.contains { $0.1.contains { $0.contains("TrackingElement") } }
                print("TRACE[\(label)] refocus round \(round) tracking-road=\(tracking) initiators=\(ScrollInitiators.log.map(\.0))")
                if round == 1 { ScrollInitiators.dump(label + " refocus r1") }
                ScrollInitiators.log = []
            }
        }
    }

    @Test func traceReturnKey() async throws {
        ScrollInitiators.install()
        for (where_, focus) in [("midbottom", true), ("end", true), ("endnofocus", false)] {
            try await withEditorWorld { session, _ in
                let postID = try await seedTraceNote(session, paragraphs: 30)
                let model = MobileEditorViewModel(session: session, postID: postID)
                let host = TraceHost(MobileWriteScreen(
                    session: session, postID: postID, beginEditing: focus, editor: model))
                defer { host.tearDown() }
                let label = "return \(where_) focus=\(focus)"
                for _ in 0..<200 {
                    if model.textView != nil, model.textView!.textStorage.length > 0 { break }
                    await host.settle(1)
                }
                let tv = try #require(model.textView)
                await host.settle(50)
                // Place the caret: end of block 12 (mid) or the doc end.
                let blocks = model.blockRangesByID()
                let ranges = blocks.values.sorted { $0.location < $1.location }
                let caret: Int
                if where_ == "midbottom" {
                    // caret at the end of block 12, with the viewport placed so
                    // block 12's last line is the LAST visible line.
                    caret = ranges[11].location + ranges[11].length
                    tv.selectedRange = NSRange(location: caret, length: 0)
                    let r = tv.caretRect(for: tv.selectedTextRange!.end)
                    tv.setContentOffset(CGPoint(x: 0, y: r.maxY - tv.bounds.height + 4), animated: false)
                } else {
                    caret = tv.textStorage.length
                    tv.selectedRange = NSRange(location: caret, length: 0)
                    let r = tv.caretRect(for: tv.selectedTextRange!.end)
                    tv.setContentOffset(CGPoint(x: 0, y: r.maxY - tv.bounds.height + 4), animated: false)
                }
                await host.settle(40)
                ScrollInitiators.log = []
                traceSnapshot(tv, label, "before ⏎")
                let recorder = ScrollTraceRecorder(tv, label: label)
                tv.insertText("\n")
                traceSnapshot(tv, label, "right after ⏎")
                await host.settle(25)
                traceSnapshot(tv, label, "⏎ +0.5s")
                recorder.dump("⏎")
                ScrollInitiators.dump(label + " ⏎")
                recorder.reset()
                // THE FIGHT: she scrolls back up a little (programmatic stand-in
                // for her pan), then we watch for anything re-scrolling.
                let up = max(0, tv.contentOffset.y - 300)
                tv.setContentOffset(CGPoint(x: 0, y: up), animated: false)
                traceSnapshot(tv, label, "after scroll-up")
                recorder.reset()
                await host.settle(150)
                traceSnapshot(tv, label, "scroll-up +3s")
                recorder.dump("after scroll-up")
                ScrollInitiators.dump(label + " after scroll-up")
                // A second ⏎ typed char then (typing continues after the pan).
                recorder.reset()
                tv.insertText("x")
                traceSnapshot(tv, label, "typed x after scroll-up")
                await host.settle(25)
                traceSnapshot(tv, label, "typed x +0.5s")
                recorder.dump("typing after scroll-up")
                ScrollInitiators.dump(label + " typing after scroll-up")
            }
        }
    }
}
