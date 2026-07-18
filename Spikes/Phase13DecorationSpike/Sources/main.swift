// Phase13DecorationSpike — Step A0(i): the three design-prerequisite
// measurements (the deferred-12 "answer 4"), taken against a design-corpus-
// shaped document (the seeded long post's scale: ~220 blocks / ~10k words).
//
// Method notes:
//  - The live editor is an EDITABLE explicit-TK2 NSTextView hosted in a
//    real NSScrollView + offscreen NSWindow, so viewport ranges are real.
//  - The keystroke path measured = one textStorage character insert at a
//    caret + viewport-range ensureLayout (+ the decoration work of the
//    condition) — the Phase 6/7 measurement window (draw excluded; the
//    window's own display cadence is the compositor's).
//  - Decorations follow the ground rule (TEXTKIT2 §3): overlay NSViews
//    positioned from fragment geometry — the Phase 7 badge pattern. The
//    rendering-attribute condition is measured FOR THE RECORD ONLY (the
//    §3 fragility caveat stands; the rule is overlays regardless).

import AppKit

// MARK: - Timing helpers (the ReadTierSpike shapes)

func nowMS() -> Double { Date().timeIntervalSinceReferenceDate * 1000 }
func fmt(_ v: Double, _ places: Int = 2) -> String { String(format: "%.\(places)f", v) }

struct Stats {
    let median: Double
    let p95: Double
    let max: Double
    init(_ samples: [Double]) {
        let s = samples.sorted()
        median = s.isEmpty ? 0 : s[s.count / 2]
        p95 = s.isEmpty ? 0 : s[min(s.count - 1, Int(Double(s.count) * 0.95))]
        max = s.last ?? 0
    }
    var line: String { "median \(fmt(median)) ms · p95 \(fmt(p95)) ms · max \(fmt(max)) ms" }
}

func physFootprintMB() -> Double {
    var info = task_vm_info_data_t()
    var count = mach_msg_type_number_t(
        MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size)
    let kr = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
        }
    }
    guard kr == KERN_SUCCESS else { return -1 }
    return Double(info.phys_footprint) / 1024 / 1024
}

// MARK: - Corpus (the seeded long post's shape)

let blockIDAttribute = NSAttributedString.Key("io.lduarte.variorum.blockID")
let baseFont = NSFont.preferredFont(forTextStyle: .body)

func blockText(_ index: Int) -> String {
    "Block \(index) carries a few sentences of corpus-shaped prose so the buffer "
        + "resembles the seeded long draft. The day repeated with small variations, "
        + "the way a theme repeats until suddenly it is a fugue, and the log lied less than the letter."
}

struct Doc {
    let blocks: [String]
    func attributed(paragraphGap: CGFloat?) -> NSAttributedString {
        let result = NSMutableAttributedString()
        var base: [NSAttributedString.Key: Any] = [.font: baseFont]
        if let paragraphGap {
            let style = NSMutableParagraphStyle()
            style.paragraphSpacing = paragraphGap
            base[.paragraphStyle] = style
        }
        for (i, text) in blocks.enumerated() {
            if i > 0 { result.append(NSAttributedString(string: "\n", attributes: base)) }
            var attrs = base
            attrs[blockIDAttribute] = "block-\(i)"
            result.append(NSAttributedString(string: text, attributes: attrs))
        }
        return result
    }
    var blockStarts: [Int] {
        var offsets: [Int] = []
        var location = 0
        for text in blocks {
            offsets.append(location)
            location += (text as NSString).length + 1
        }
        return offsets
    }
}

let doc = Doc(blocks: (0..<220).map(blockText))
let wordCount = doc.blocks.joined(separator: " ").split(separator: " ").count

// MARK: - The hosted live editor

@MainActor
func makeEditor(gap: CGFloat?) -> (window: NSWindow, scroll: NSScrollView, tv: NSTextView) {
    let tv = NSTextView(usingTextLayoutManager: true)
    precondition(tv.textLayoutManager != nil, "TK2 opt-in failed")
    tv.isEditable = true
    tv.isRichText = false
    tv.textContainerInset = NSSize(width: 24, height: 24)
    tv.textContainer?.widthTracksTextView = true
    tv.autoresizingMask = [.width]
    tv.textStorage?.setAttributedString(doc.attributed(paragraphGap: gap))

    let scroll = NSScrollView(frame: NSRect(x: 0, y: 0, width: 700, height: 900))
    scroll.documentView = tv
    scroll.hasVerticalScroller = true
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 700, height: 900),
        styleMask: [.titled], backing: .buffered, defer: false)
    window.contentView = scroll
    window.orderBack(nil)
    tv.frame = NSRect(x: 0, y: 0, width: 700, height: 100)
    tv.textLayoutManager?.ensureLayout(for: tv.textLayoutManager!.documentRange)
    return (window, scroll, tv)
}

@MainActor
func viewportRange(_ tv: NSTextView) -> NSTextRange {
    tv.textLayoutManager!.textViewportLayoutController.viewportRange
        ?? tv.textLayoutManager!.documentRange
}

/// One measured keystroke: insert a character at `offset`, lay the viewport
/// out, plus the condition's decoration work; then undo the insert outside
/// the timed window.
@MainActor
func measureKeystrokes(
    _ tv: NSTextView, at offsets: [Int], reps: Int,
    decorationWork: (() -> Void)? = nil
) -> Stats {
    var samples: [Double] = []
    let lm = tv.textLayoutManager!
    for rep in 0..<reps {
        let offset = offsets[rep % offsets.count]
        let t0 = nowMS()
        tv.textStorage?.replaceCharacters(in: NSRange(location: offset, length: 0), with: "x")
        lm.ensureLayout(for: viewportRange(tv))
        decorationWork?()
        samples.append(nowMS() - t0)
        tv.textStorage?.replaceCharacters(in: NSRange(location: offset, length: 1), with: "")
    }
    return Stats(samples)
}

/// The overlay decoration set (the Phase 7 pattern): seam lines between
/// visible blocks, one editing ring, per-block badges — all plain NSViews
/// repositioned from fragment geometry each keystroke/scroll.
@MainActor
final class OverlayDeck {
    let seams: [NSBox]
    let badges: [NSTextField]
    let ring: NSBox
    private weak var tv: NSTextView?

    init(over tv: NSTextView, count: Int) {
        self.tv = tv
        seams = (0..<count).map { _ in
            let box = NSBox()
            box.boxType = .separator
            tv.addSubview(box)
            return box
        }
        badges = (0..<count).map { i in
            let label = NSTextField(labelWithString: "⑂ \(i % 5 + 1)")
            tv.addSubview(label)
            return label
        }
        ring = NSBox()
        ring.boxType = .custom
        ring.borderWidth = 1.5
        ring.cornerRadius = 3
        ring.isTransparent = false
        ring.fillColor = .clear
        tv.addSubview(ring)
    }

    /// Reposition every overlay from the CURRENT viewport's fragment
    /// geometry — the per-keystroke / per-scroll decoration work.
    func reposition() {
        guard let tv, let lm = tv.textLayoutManager else { return }
        let viewport = viewportRange(tv)
        var index = 0
        lm.enumerateTextLayoutFragments(from: viewport.location, options: [.ensuresLayout]) { fragment in
            guard index < self.seams.count else { return false }
            let frame = fragment.layoutFragmentFrame
            self.seams[index].frame = NSRect(
                x: frame.minX, y: frame.maxY + 2, width: 640, height: 1)
            self.badges[index].frame = NSRect(
                x: frame.maxX + 8, y: frame.minY, width: 44, height: 16)
            if index == 3 {
                self.ring.frame = frame.insetBy(dx: -6, dy: -4)
            }
            index += 1
            return fragment.rangeInElement.endLocation.compare(viewport.endLocation) == .orderedAscending
        }
    }
}

// MARK: - The run

@MainActor
func run() {
    let pi = ProcessInfo.processInfo
    print("Phase13DecorationSpike — Step A0(i) (\(pi.operatingSystemVersionString))")
    print("Document: \(doc.blocks.count) blocks · ~\(wordCount) words · editor 700×900, inset 24.")
    print("")

    // Caret positions: near the start, middle, and end of the document.
    let starts = doc.blockStarts
    let offsets = [starts[10] + 40, starts[110] + 40, starts[215] + 40]
    let reps = 150

    // (a)/(c) — condition 1: BARE.
    let bare = makeEditor(gap: nil)
    let bareStats = measureKeystrokes(bare.tv, at: offsets, reps: reps)
    print("(a) keystroke edit path, BARE (insert + viewport ensureLayout):")
    print("    \(bareStats.line)")

    // Condition 2: the presentation GAP (paragraphSpacing typing attribute —
    // the Phase 10 uniform per-paragraph gap).
    let gapped = makeEditor(gap: 12)
    let gapStats = measureKeystrokes(gapped.tv, at: offsets, reps: reps)
    print("(a) keystroke edit path, +paragraph GAP (paragraphSpacing 12):")
    print("    \(gapStats.line)")

    // Condition 3: OVERLAYS (the ground rule's pattern): 18 seams + 18
    // badges + 1 ring repositioned from fragment geometry every keystroke.
    let decorated = makeEditor(gap: 12)
    let deck = OverlayDeck(over: decorated.tv, count: 18)
    deck.reposition()
    let overlayStats = measureKeystrokes(decorated.tv, at: offsets, reps: reps) {
        deck.reposition()
    }
    print("(a) keystroke edit path, +GAP +OVERLAYS (18 seams + 18 badges + ring, geometry-repositioned per keystroke):")
    print("    \(overlayStats.line)")

    // Overlay reposition alone (the scroll-tick cost).
    var repositionSamples: [Double] = []
    for _ in 0..<reps {
        let t0 = nowMS()
        deck.reposition()
        repositionSamples.append(nowMS() - t0)
    }
    print("(a) overlay reposition alone (the scroll-tick cost): \(Stats(repositionSamples).line)")

    // Condition 4 (FOR THE RECORD — TEXTKIT2 §3's fragile path, measured
    // only so the budget table is complete; the rule is overlays):
    let ra = makeEditor(gap: nil)
    let raLM = ra.tv.textLayoutManager!
    let raStats = measureKeystrokes(ra.tv, at: offsets, reps: reps) {
        let viewport = viewportRange(ra.tv)
        raLM.addRenderingAttribute(.backgroundColor, value: NSColor.yellow.withAlphaComponent(0.2), for: viewport)
        raLM.removeRenderingAttribute(.backgroundColor, for: viewport)
    }
    print("(a) FOR THE RECORD, +rendering-attribute add/remove over the viewport per keystroke (§3 caveat stands):")
    print("    \(raStats.line)")
    print("")

    // (c) headroom: against the 8 ms half-frame bar the Phase 7 smoke used.
    let budget = 8.0
    print("(c) keystroke headroom vs the 8 ms bar:")
    print("    bare p95 \(fmt(bareStats.p95)) ms → headroom \(fmt(budget - bareStats.p95)) ms")
    print("    decorated p95 \(fmt(overlayStats.p95)) ms → headroom \(fmt(budget - overlayStats.p95)) ms")
    print("    decoration cost at p95 (overlays+gap vs bare): \(fmt(overlayStats.p95 - bareStats.p95)) ms")
    print("")

    // (b) read-tier per-view at design-corpus scale: 200 posts, the
    // Phase 10 candidate-(b) construction (non-editable TK2, sized to
    // content). Mix mirrors CorpusFactory: 5-block typical, 50-block big.
    let posts: [[String]] = (0..<200).map { p in
        let count = p % 10 == 9 ? 50 : 5
        return (0..<count).map { blockText($0 + p) }
    }
    let memBefore = physFootprintMB()
    var setupTimes: [Double] = []
    var views: [NSTextView] = []
    views.reserveCapacity(posts.count)
    for post in posts {
        let t0 = nowMS()
        let tv = NSTextView(usingTextLayoutManager: true)
        tv.isEditable = false
        tv.isSelectable = true
        tv.isRichText = false
        tv.textContainerInset = NSSize(width: 8, height: 8)
        tv.textContainer?.widthTracksTextView = true
        tv.frame = NSRect(x: 0, y: 0, width: 600, height: 100)
        tv.textStorage?.setAttributedString(
            Doc(blocks: post).attributed(paragraphGap: 12))
        let lm = tv.textLayoutManager!
        lm.ensureLayout(for: lm.documentRange)
        tv.frame.size.height = max(lm.usageBoundsForTextContainer.height + 16, 1)
        setupTimes.append(nowMS() - t0)
        views.append(tv)
        if views.count == 12 {
            print("(b) read-tier memory at a dozen live views: Δ \(fmt(physFootprintMB() - memBefore, 1)) MB")
        }
    }
    print("(b) read-tier per-view setup+fullLayout at 200 views (mix 180×5-block + 20×50-block):")
    print("    \(Stats(setupTimes).line)")
    print("    (Phase 10 recorded 0.35 ms median for the same construction — re-verified above)")
    print("(b) memory at 200 live views: Δ \(fmt(physFootprintMB() - memBefore, 1)) MB from baseline")
    withExtendedLifetime(views) {}
    print("")
    print("done.")
}

final class SpikeAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        autoreleasepool { MainActor.assumeIsolated { run() } }
        exit(0)
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = SpikeAppDelegate()
app.delegate = delegate
app.run()
