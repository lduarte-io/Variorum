//
//  VisualWalkProbe.swift
//  Variorum (Mac) — DEBUG ONLY, and inside DEBUG only when asked for
//
//  18l UNIT U-VIS — THE VISUAL REGRESSION HARNESS'S ORACLE ENDPOINT.
//
//  Her standing ask (2026-09-25, verbatim): *"tests that can run (don't have
//  to be part of the suite that run every time) where screenshots are taken
//  of edits, clicks, if the editor has moved unexpectedly between clicks,
//  etc."* The harness is an EXTERNAL driver (`Tools/VisualWalk/`) over the
//  real window — KnownIssues rows 35 and 89 are the classes an in-process rig
//  inherits — and it asserts on MEASURED GEOMETRY, never on pixels (the
//  18l U-VIS design note, decision 2). The app already knows its own
//  geometry; this file is the one door through which an outside process can
//  ask for it.
//
//  THE SHAPE — pull, never push:
//  - The driver posts a distributed notification (`requestName`, the object
//    a request string: an id and optional flags). This file answers with one
//    distributed notification (`answerName`, the object the answer LINE).
//  - The answer is computed AT REQUEST TIME from what is already on screen:
//    the key window's first-responder text view (TextKit 2 API only — never
//    `.layoutManager`, TEXTKIT2_NOTES §1), the focused editor's own reading
//    line (`EditorViewModel.topVisibleOffset`, the anchor family's rule, not
//    a copy of it), and existing DEBUG oracles (`ReadModeOracle`,
//    `BookIndexGeometry`). Nothing on screen registers anything for this
//    file, so there is no slot a surface writes and no registrant to key —
//    18k UNIT C4's owner-keyed rule has nothing to apply to (its class is "a
//    registration keyed by its subject with no record of who registered
//    it"; a pull-read has no registration). The one static is the process's
//    own observer token.
//  - Reads lay out NOTHING by default: no `.ensuresLayout`, the settle net's
//    O(1) last-fragment idiom, so asking does not change what it measures.
//    The ONE exception is opt-in per request (`measure`): the pane/inline
//    editor's full measurement through the app's ONE measurement brain
//    (`PaneMeasurement.height` — what the inline editor already runs per
//    keystroke), taken AFTER the frame is read, so the frame it is compared
//    against is the one the surface had. Never on the full-document editor
//    (document scale — P1).
//  - The line is numbers and fixed words (plus an 8-character note-id prefix
//    so a re-open can be matched) — never prose.
//
//  GATED TWICE: `#if DEBUG` (a Release build compiles this file to nothing),
//  and inside DEBUG the observer exists only when the process was launched
//  with `VARIORUM_VISUAL_WALK=1` — Xcode Run, the test host and every walk
//  that is not the harness never register it.
//

#if DEBUG
import AppKit

@MainActor
enum VisualWalkProbe {
    /// The launch environment key the driver sets (and the wrapper test's gate).
    static let environmentKey = "VARIORUM_VISUAL_WALK"
    static let requestName = Notification.Name("io.lduarte.Variorum.debug.visualWalk.request")
    static let answerName = Notification.Name("io.lduarte.Variorum.debug.visualWalk.answer")

    private static var observer: NSObjectProtocol?
    private static var session: (@MainActor () -> AppSession?)?

    /// Called once from `applicationDidFinishLaunching` (DEBUG). A no-op
    /// unless the harness launched this process.
    static func installIfRequested(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        session: @escaping @MainActor () -> AppSession?
    ) {
        guard environment[environmentKey] == "1", observer == nil else { return }
        self.session = session
        observer = DistributedNotificationCenter.default().addObserver(
            forName: requestName, object: nil, queue: .main
        ) { note in
            let request = (note.object as? String) ?? ""
            MainActor.assumeIsolated {
                let line = answer(to: request)
                DistributedNotificationCenter.default().postNotificationName(
                    answerName, object: line, userInfo: nil, deliverImmediately: true)
            }
        }
    }

    // MARK: - The answer

    /// `request` = "<id>[ flag …]"; flags: `measure` (the pane/inline full
    /// measure) · `rt` (the read tiers' text columns on screen).
    static func answer(to request: String) -> String {
        let parts = request.split(separator: " ").map(String.init)
        let flags = Set(parts.dropFirst())
        var line = Line(id: parts.first ?? "?")
        if let session = session?() {
            line["mode"] = session.commandRouter.activeMode?.rawValue ?? "none"
            line["post"] = session.commandRouter.activePostID.map { String($0.prefix(8)) } ?? "none"
        }
        line["face"] = ReadModeOracle.face?.rawValue ?? "none"
        line["voice"] = EditorTypography.isAdopted ? "\(EditorTypography.current.voice)" : "unadopted"
        guard let window = NSApp.keyWindow ?? NSApp.mainWindow
                ?? NSApp.orderedWindows.first(where: { $0.isVisible && $0.canBecomeMain })
        else {
            line["win"] = "none"
            return line.text
        }
        line["win"] = Self.format(Self.screen(window.frame))
        line["key"] = window.isKeyWindow ? "1" : "0"
        if flags.contains("rt") { readTierColumns(in: window, into: &line) }
        let responder = window.firstResponder
        guard let textView = responder as? NSTextView else {
            line["fr"] = responder == nil ? "none" : "other"
            return line.text
        }
        let model = (textView.delegate as? EditorSurfaceDelegate)?.model
        if textView is EditorTextView {
            line["fr"] = model?.scrollView == nil ? "inline" : "editor"
        } else if textView is PaneTextView {
            line["fr"] = "pane"
        } else {
            line["fr"] = "text"
        }
        textFacts(textView, measure: flags.contains("measure") && model?.scrollView == nil,
                  into: &line)
        if let model {
            line["blk"] = "\(model.caretOrdinal.map(String.init) ?? "-")/\(model.blockCount)"
            if model.scrollView != nil {
                line["rline"] = model.topVisibleOffset().map(String.init) ?? "-1"
            }
            if let room = (textView as? EditorTextView)?.typewriterRoom {
                line["room"] = Self.num(room)
            }
        }
        return line.text
    }

    // MARK: - One text view's geometry (TK2 only; nothing laid out unless `measure`)

    private static func textFacts(_ tv: NSTextView, measure: Bool, into line: inout Line) {
        guard let layoutManager = tv.textLayoutManager,
              let content = layoutManager.textContentManager,
              let storage = tv.textStorage
        else {
            line["tk"] = "none"
            return
        }
        let docStart = content.documentRange.location
        let length = storage.length
        let origin = tv.textContainerOrigin
        let visible = tv.visibleRect
        line["len"] = "\(length)"
        line["nl"] = length > 0 && storage.mutableString.character(at: length - 1) == 10 ? "1" : "0"
        let selection = tv.selectedRange()
        line["sel"] = "\(selection.location),\(selection.length)"
        line["vis"] = format(screen(visible, in: tv))
        line["frameH"] = num(tv.frame.height)
        line["insetH"] = num(tv.textContainerInset.height)
        line["originY"] = num(origin.y)
        if let container = tv.textContainer {
            line["colX"] = "\(num(screenX(origin.x, in: tv))),\(num(screenX(origin.x + container.size.width, in: tv)))"
        }
        if let clip = tv.enclosingScrollView?.contentView {
            line["clip"] = num(clip.bounds.origin.y)
        }

        // The first visible line: the first line whose TOP is at or below the
        // visible rect's top edge (a line the edge cuts is not "the first
        // line"). Starts at the fragment under the edge; bounded by the
        // viewport — no `.ensuresLayout`, on-screen fragments are laid out.
        let topC = visible.minY - origin.y
        let bottomC = visible.maxY - origin.y
        let start = layoutManager.textLayoutFragment(for: CGPoint(x: 1, y: max(0, topC)))?
            .rangeInElement.location
            ?? layoutManager.textViewportLayoutController.viewportRange?.location
            ?? docStart
        // Also the MIDDLE line: the first line WITH TEXT whose top is at or
        // below the viewport's middle and whose bottom is on screen — a
        // click target "on top of a line of text" mid-page — and the first
        // BLANK line there (a block's end in a note that keeps a blank line
        // between paragraphs: the ⏎-then-⌫ carve's target).
        typealias Seen = (offset: Int, top: CGFloat, bottom: CGFloat, blank: Bool)
        var first: Seen?
        var middle: Seen?
        var blankBelow: Seen?   // the first BLANK line in the lower half — a block's end in her notes
        let midC = (topC + bottomC) / 2
        var scanned = 0
        layoutManager.enumerateTextLayoutFragments(from: start, options: []) { fragment in
            scanned += 1
            let frame = fragment.layoutFragmentFrame
            if frame.minY > bottomC { return false }
            let fragmentStart = content.offset(from: docStart, to: fragment.rangeInElement.location)
            for textLine in fragment.textLineFragments {
                let top = frame.minY + textLine.typographicBounds.minY
                let bottom = frame.minY + textLine.typographicBounds.maxY
                let seen: Seen = (fragmentStart + textLine.characterRange.location, top, bottom,
                                  textLine.characterRange.length == 0 || isBlank(textLine, in: fragment))
                if first == nil, top >= topC - 0.5 { first = seen }
                if middle == nil, top >= midC, bottom <= bottomC, !seen.blank { middle = seen }
                if blankBelow == nil, top >= midC, bottom <= bottomC, seen.blank { blankBelow = seen }
                if first != nil, middle != nil, blankBelow != nil { return false }
            }
            return scanned < 400
        }
        if let first {
            line["top"] = "\(first.offset)"
            line["topY"] = num(screenY(first.top + origin.y, in: tv))
            line["topY1"] = num(screenY(first.bottom + origin.y, in: tv))
            line["topBlank"] = first.blank ? "1" : "0"
        } else {
            line["top"] = "-1"
        }
        if let middle {
            line["mid"] = "\(middle.offset)"
            line["midY"] = num(screenY(middle.top + origin.y, in: tv))
            line["midY1"] = num(screenY(middle.bottom + origin.y, in: tv))
        }
        if let blankBelow {
            line["blank"] = "\(blankBelow.offset)"
            line["blankY"] = num(screenY(blankBelow.top + origin.y, in: tv))
            line["blankY1"] = num(screenY(blankBelow.bottom + origin.y, in: tv))
        }

        // The caret's line (a collapsed or ranged selection: its location).
        let location = selection.location
        line["caretEnd"] = location >= length ? "1" : "0"
        let probe = location >= length && length > 0 ? length - 1 : location
        if let target = content.location(docStart, offsetBy: max(0, probe)) {
            var fragmentFound: NSTextLayoutFragment?
            layoutManager.enumerateTextLayoutFragments(from: target, options: []) { fragment in
                fragmentFound = fragment
                return false
            }
            if let fragment = fragmentFound {
                let frame = fragment.layoutFragmentFrame
                let fragmentStart = content.offset(from: docStart, to: fragment.rangeInElement.location)
                let lines = fragment.textLineFragments
                line["caretState"] = fragment.state == .layoutAvailable ? "laid" : "est"
                if let i = FragmentLines.lineIndex(
                    atLocalOffset: max(0, location - fragmentStart),
                    lineRanges: lines.map(\.characterRange)) {
                    let textLine = lines[i]
                    let bounds = textLine.typographicBounds
                    let textLines = lines.filter { $0.characterRange.length > 0 }.count
                    line["caretLine"] = "\(i)"
                    line["caretLines"] = "\(lines.count)"
                    line["caretTextLines"] = "\(textLines)"
                    line["caretY0"] = num(screenY(frame.minY + bounds.minY + origin.y, in: tv))
                    line["caretY1"] = num(screenY(frame.minY + bounds.maxY + origin.y, in: tv))
                    let local = max(0, location - fragmentStart)
                    let point = textLine.locationForCharacter(at: local)
                    line["caretX"] = num(screenX(
                        frame.minX + bounds.minX + point.x + origin.x, in: tv))
                }
            }
        }

        // The LAST line: the last layout fragment, read in O(1) exactly as the
        // settle net reads it (`InlineEditorSurface`), and its last line with
        // text (the glyph box whose descenders must not be clipped).
        var lastFragment: NSTextLayoutFragment?
        layoutManager.enumerateTextLayoutFragments(
            from: content.documentRange.endLocation, options: [.reverse]
        ) { fragment in
            lastFragment = fragment
            return false
        }
        if let fragment = lastFragment {
            recordLast(fragment, origin: origin, in: tv, suffix: "", into: &line)
        }

        // Opt-in: the ONE measurement brain, AFTER the frame was read above.
        if measure {
            line["measured"] = num(PaneMeasurement.height(of: tv))
            var settled: NSTextLayoutFragment?
            layoutManager.enumerateTextLayoutFragments(
                from: content.documentRange.endLocation, options: [.reverse]
            ) { fragment in
                settled = fragment
                return false
            }
            if let settled {
                recordLast(settled, origin: origin, in: tv, suffix: "M", into: &line)
            }
        }
    }

    private static func recordLast(
        _ fragment: NSTextLayoutFragment, origin: CGPoint, in tv: NSTextView,
        suffix: String, into line: inout Line
    ) {
        let frame = fragment.layoutFragmentFrame
        line["lastState" + suffix] = fragment.state == .layoutAvailable ? "laid" : "est"
        line["lastFrag" + suffix] = num(frame.maxY + origin.y)
        let glyphs = fragment.textLineFragments.last(where: { $0.characterRange.length > 0 })
            ?? fragment.textLineFragments.last
        if let glyphs {
            let bottom = frame.minY + glyphs.typographicBounds.maxY + origin.y
            line["lastGlyph" + suffix] = num(bottom)
            line["lastGlyphY" + suffix] = num(screenY(bottom, in: tv))
        }
    }

    private static func isBlank(_ textLine: NSTextLineFragment, in fragment: NSTextLayoutFragment) -> Bool {
        let string = textLine.attributedString.string as NSString
        let range = textLine.characterRange
        guard range.location >= 0, range.upperBound <= string.length else { return false }
        return string.substring(with: range)
            .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - The read tiers' text columns (existing DEBUG oracles)

    /// Where a click "on top of a line of text" goes: the book Index's
    /// read-tier prose rectangles (`BookIndexGeometry.paneReadTierFrames` —
    /// `.global`, the window's own y-down space) and Read ▸ edit's
    /// (`ReadModeOracle.editBlockFrames`, narrowed to the text column exactly
    /// as `IndexClickCaretTests` narrows it). Read ▸ edit's rows are measured
    /// in the Read host's NAMED space, whose place in the window no oracle
    /// records — so it is CALIBRATED here from the one live pane: 13u2 B's
    /// pinned alignment puts the live pane's prose origin exactly where its
    /// row's read-tier column would start, so (pane prose origin in the
    /// window) − (live row's column origin in the host space) is the host
    /// space's offset. No live pane ⇒ `rtR=uncal` rather than a guess.
    private static func readTierColumns(in window: NSWindow, into line: inout Line) {
        let windowTop = primaryHeight - window.frame.maxY
        func toScreen(_ rect: CGRect, dx: CGFloat = 0, dy: CGFloat = 0) -> CGRect {
            CGRect(x: window.frame.minX + rect.minX + dx, y: windowTop + rect.minY + dy,
                   width: rect.width, height: rect.height)
        }
        line["rtI"] = columns(BookIndexGeometry.paneReadTierFrames.values.map { toScreen($0) })
        let panes = editablePanes(in: window.contentView)
        line["panes"] = "\(panes.count)"
        let top = IndexProseColumn.readTierTop(
            resting: IndexProseColumn.readEditRestingTop, paneInset: PaneTextView.proseTopInset)
        let leading = IndexProseColumn.readTierLeading(
            resting: IndexProseColumn.readEditResting, paneInset: PaneTextView.proseLeadingInset)
        func column(_ row: CGRect) -> CGRect {
            CGRect(x: row.minX + leading, y: row.minY + top,
                   width: row.width - leading - IndexProseColumn.readEditResting,
                   height: row.height - top - IndexProseColumn.readEditRestingTop)
        }
        let live = ReadModeOracle.liveBlockID
        var offset: (dx: CGFloat, dy: CGFloat, how: String)?
        if let live, let liveRow = ReadModeOracle.editBlockFrames[live],
           let pane = panes.first(where: {
               $0.identifier?.rawValue.hasPrefix("pane:\(ReadEditPane.role)") == true }) {
            // The pane's prose origin, in the window's y-down space.
            let prose = pane.convert(
                NSPoint(x: PaneTextView.proseLeadingInset, y: PaneTextView.proseTopInset), to: nil)
            let liveColumn = column(liveRow)
            offset = (prose.x - liveColumn.minX, window.frame.height - prose.y - liveColumn.minY, "pane")
        } else if let post = session?()?.commandRouter.activePostID,
                  let face = ReadModeOracle.faceFrames[post] {
            // No live pane (Read ▸ edit at rest): the face — the edit column — is one scroll
            // view; the AppKit scroll view whose size is the face's IS it, and its window
            // origin minus the face's host-space origin is the same offset.
            for scroll in scrollViews(in: window.contentView) {
                let r = scroll.convert(scroll.bounds, to: nil)
                if abs(r.width - face.width) < 1.5, abs(r.height - face.height) < 1.5 {
                    offset = (r.minX - face.minX, window.frame.height - r.maxY - face.minY, "face")
                    break
                }
            }
        }
        guard let offset else {
            line["rtR"] = ReadModeOracle.editBlockFrames.isEmpty ? "none" : "uncal"
            return
        }
        line["rtRcal"] = "\(offset.how):\(num(offset.dx)),\(num(offset.dy))"
        line["rtR"] = columns(ReadModeOracle.editBlockFrames
            .filter { $0.key != live }.values
            .map { toScreen(column($0), dx: offset.dx, dy: offset.dy) })
    }

    private static func scrollViews(in view: NSView?) -> [NSScrollView] {
        guard let view else { return [] }
        var out: [NSScrollView] = view is NSScrollView ? [view as! NSScrollView] : []
        for sub in view.subviews { out += scrollViews(in: sub) }
        return out
    }

    private static func editablePanes(in view: NSView?) -> [PaneTextView] {
        guard let view else { return [] }
        var out: [PaneTextView] = []
        if let pane = view as? PaneTextView, pane.isEditable { out.append(pane) }
        for sub in view.subviews { out += editablePanes(in: sub) }
        return out
    }

    private static func columns(_ rects: [CGRect]) -> String {
        let sorted = rects.filter { $0.width > 0 && $0.height > 0 }
            .sorted { $0.minY < $1.minY }.prefix(40)
        return sorted.isEmpty ? "none" : sorted.map(format).joined(separator: ";")
    }

    // MARK: - Coordinates (Quartz global: top-left origin, points — `cliclick`'s)

    private static var primaryHeight: CGFloat { NSScreen.screens.first?.frame.height ?? 0 }

    private static func screen(_ appKit: NSRect) -> CGRect {
        CGRect(x: appKit.minX, y: primaryHeight - appKit.maxY, width: appKit.width, height: appKit.height)
    }

    private static func screen(_ rect: NSRect, in view: NSView) -> CGRect {
        guard let window = view.window else { return .zero }
        return screen(window.convertToScreen(view.convert(rect, to: nil)))
    }

    private static func screenY(_ y: CGFloat, in view: NSView) -> CGFloat {
        screen(NSRect(x: 0, y: y, width: 0, height: 0), in: view).minY
    }

    private static func screenX(_ x: CGFloat, in view: NSView) -> CGFloat {
        screen(NSRect(x: x, y: 0, width: 0, height: 0), in: view).minX
    }

    private static func num(_ value: CGFloat) -> String { String(format: "%.1f", Double(value)) }

    private static func format(_ rect: CGRect) -> String {
        "\(num(rect.minX)),\(num(rect.minY)),\(num(rect.width)),\(num(rect.height))"
    }

    /// The answer line: `vis id=<id> key=value …`, keys in insertion order.
    struct Line {
        private var pairs: [(String, String)] = []
        init(id: String) { pairs.append(("id", id)) }
        subscript(key: String) -> String? {
            get { pairs.first { $0.0 == key }?.1 }
            set {
                pairs.removeAll { $0.0 == key }
                if let newValue { pairs.append((key, newValue)) }
            }
        }
        var text: String { "vis " + pairs.map { "\($0.0)=\($0.1)" }.joined(separator: " ") }
    }
}
#endif
