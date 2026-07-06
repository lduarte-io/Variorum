// TK2Spike — one window + TK2 NSTextView + geometry helpers (throwaway; Phase 6).
//
// TK2 discipline (TEXTKIT2_NOTES §4): the view is created with the explicit
// usingTextLayoutManager:true opt-in; NOTHING in this package touches `.layoutManager`
// or any NSLayoutManager API (a guaranteed downgrade trigger on macOS 26).

import AppKit

final class Harness {
    let window: NSWindow
    let scrollView: NSScrollView
    let textView: NSTextView
    private(set) var loadMS: Double = 0

    var tlm: NSTextLayoutManager { textView.textLayoutManager! }
    var contentManager: NSTextContentManager { tlm.textContentManager! }
    var viewport: NSTextViewportLayoutController { tlm.textViewportLayoutController }

    var tk2Alive: Bool { textView.textLayoutManager != nil }
    var clipTop: CGFloat { scrollView.contentView.bounds.origin.y }
    var viewportHeight: CGFloat { scrollView.contentView.bounds.height }
    var docHeight: CGFloat { textView.frame.height }
    var usageHeight: CGFloat { tlm.usageBoundsForTextContainer.height }
    var maxScroll: CGFloat { max(0, docHeight - viewportHeight) }

    init(corpus: NSAttributedString, size: NSSize = NSSize(width: 900, height: 600), title: String) {
        window = NSWindow(
            contentRect: NSRect(x: 120, y: 120, width: size.width, height: size.height),
            styleMask: [.titled, .resizable, .closable],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.title = "TK2 Spike — \(title)"

        let tv = NSTextView(usingTextLayoutManager: true)
        precondition(tv.textLayoutManager != nil, "TK2 opt-in failed at construction")
        tv.frame = NSRect(origin: .zero, size: size)
        tv.textContainerInset = .zero
        tv.isEditable = true
        tv.isSelectable = true
        tv.isRichText = true
        tv.allowsUndo = true
        tv.isVerticallyResizable = true
        tv.isHorizontallyResizable = false
        tv.autoresizingMask = [.width]
        tv.minSize = NSSize(width: 0, height: 0)
        tv.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        tv.textContainer?.widthTracksTextView = true
        tv.textContainer?.size = NSSize(width: size.width, height: CGFloat.greatestFiniteMagnitude)
        // Keep programmatic typing deterministic.
        tv.isAutomaticQuoteSubstitutionEnabled = false
        tv.isAutomaticDashSubstitutionEnabled = false
        tv.isAutomaticTextReplacementEnabled = false
        tv.isAutomaticSpellingCorrectionEnabled = false
        tv.isContinuousSpellCheckingEnabled = false
        textView = tv

        let sv = NSScrollView(frame: NSRect(origin: .zero, size: size))
        sv.hasVerticalScroller = true
        sv.documentView = tv
        sv.autoresizingMask = [.width, .height]
        scrollView = sv
        window.contentView = sv

        FallbackCanary.shared.arm()
        FallbackCanary.shared.currentAction = "load(\(title))"
        let t0 = nowMS()
        tv.textContentStorage!.textStorage!.setAttributedString(corpus)
        loadMS = nowMS() - t0
        FallbackCanary.shared.currentAction = "idle"

        // Show without activating the app (no focus steal on the author's machine).
        window.orderFrontRegardless()
    }

    func close() {
        window.orderOut(nil)
        window.close()
    }

    // MARK: - Run-loop + layout helpers

    /// Re-enter the main run loop so display/layout passes happen naturally.
    func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// Explicit viewport layout pass (idempotent when already laid out).
    func layoutViewport() {
        viewport.layoutViewport()
    }

    /// Pump until the height estimate + scroll position go quiet (or timeout).
    struct SettleResult {
        let ms: Double          // time until the last observed change
        let revisions: Int      // number of observed (usage|doc|clip) changes
        let finalUsage: CGFloat
        let finalDoc: CGFloat
    }

    @discardableResult
    func settle(timeout: TimeInterval = 2.0, interval: TimeInterval = 0.03, quiet: Int = 3) -> SettleResult {
        let start = nowMS()
        var lastChange = start
        var revisions = 0
        func sample() -> (CGFloat, CGFloat, CGFloat) {
            (usageHeight.rounded(), docHeight.rounded(), clipTop.rounded())
        }
        var last = sample()
        var quietRuns = 0
        while nowMS() - start < timeout * 1000 {
            pump(interval)
            layoutViewport()
            let cur = sample()
            if cur != last {
                revisions += 1
                lastChange = nowMS()
                last = cur
                quietRuns = 0
            } else {
                quietRuns += 1
                if quietRuns >= quiet { break }
            }
        }
        return SettleResult(ms: lastChange - start, revisions: revisions, finalUsage: last.0, finalDoc: last.1)
    }

    // MARK: - Scrolling

    func scrollTo(y: CGFloat) {
        let clamped = min(max(0, y), maxScroll)
        scrollView.contentView.scroll(to: NSPoint(x: 0, y: clamped))
        scrollView.reflectScrolledClipView(scrollView.contentView)
        layoutViewport()
    }

    // MARK: - Locations / fragments

    func location(atOffset offset: Int) -> NSTextLocation? {
        contentManager.location(contentManager.documentRange.location, offsetBy: offset)
    }

    func offset(of location: NSTextLocation) -> Int {
        contentManager.offset(from: contentManager.documentRange.location, to: location)
    }

    /// First layout fragment at/after the given character offset.
    /// `ensuringLayout` forces layout of just that fragment (bounded work).
    func firstFragment(fromOffset offset: Int, ensuringLayout: Bool) -> NSTextLayoutFragment? {
        guard let loc = location(atOffset: offset) else { return nil }
        var found: NSTextLayoutFragment?
        let options: NSTextLayoutFragment.EnumerationOptions = ensuringLayout ? [.ensuresLayout] : []
        tlm.enumerateTextLayoutFragments(from: loc, options: options) { fragment in
            found = fragment
            return false
        }
        return found
    }

    /// Character offset of the fragment at the top edge of the viewport (nil if no layout there).
    func offsetAtViewportTop() -> Int? {
        let point = CGPoint(x: 4, y: clipTop + 1)
        guard let fragment = tlm.textLayoutFragment(for: point) else { return nil }
        return offset(of: fragment.rangeInElement.location)
    }

    func textRange(offset: Int, length: Int) -> NSTextRange? {
        guard let start = location(atOffset: offset),
              let end = location(atOffset: offset + length) else { return nil }
        return NSTextRange(location: start, end: end)
    }
}
