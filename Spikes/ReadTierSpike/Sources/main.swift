// ReadTierSpike — Phase 10 Step 0 (throwaway measurement, the brief's decision
// protocol). Measures the two read-tier candidates over ~50 corpus-shaped
// posts:
//   (a) SwiftUI Text(AttributedString) + .textSelection(.enabled) in a
//       LazyVStack — build/refresh cost + memory (its decisive axes — badge
//       anchoring, cross-Text selection — are API-capability facts recorded
//       in the memo, verified by lookup).
//   (b) non-editable TK2 NSTextView per visible post, sized to content (the
//       shape the book view would actually hold inside an outer scroll) —
//       per-view setup+layout, memory at a dozen and at fifty views, full vs
//       differential projection refresh, selection survival, per-block badge
//       geometry availability, scroll-through cost.
//
// Corpus shape mirrors Tests/VariorumCoreTests/Support/CorpusFactory: ~120
// ASCII chars per block; typical post = 5 blocks, big post = 50 blocks. The
// attributed materialization mirrors EditorDocument (single-"\n" separator,
// block-ID attribute, body font) so the measured geometry matches what the
// real tier renders.

import AppKit
import SwiftUI

// MARK: - Timing + memory

func nowMS() -> Double { Date().timeIntervalSinceReferenceDate * 1000 }

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

// MARK: - Corpus (CorpusFactory shape)

let blockIDAttribute = NSAttributedString.Key("io.lduarte.variorum.blockID")
let separator = "\n"
let baseFont = NSFont.preferredFont(forTextStyle: .body)

func blockText(post: Int, block: Int) -> String {
    "Sentence one lives here. Sentence two of block \(block) in post \(post) "
        + "carries on for a while so the buffer resembles real prose."
}

struct SpikePost {
    let blocks: [(id: String, text: String)]

    /// EditorDocument.materialize's shape: blocks joined by a single "\n"
    /// owned by neither block; block-ID attributes over block ranges.
    func attributed() -> NSAttributedString {
        let result = NSMutableAttributedString()
        let base: [NSAttributedString.Key: Any] = [.font: baseFont]
        for (i, block) in blocks.enumerated() {
            if i > 0 { result.append(NSAttributedString(string: separator, attributes: base)) }
            var attrs = base
            attrs[blockIDAttribute] = block.id
            result.append(NSAttributedString(string: block.text, attributes: attrs))
        }
        return result
    }

    /// UTF-16 start offset of each block in the materialized document.
    var blockStarts: [Int] {
        var offsets: [Int] = []
        var location = 0
        for block in blocks {
            offsets.append(location)
            location += (block.text as NSString).length + 1
        }
        return offsets
    }
}

func makeCorpus(posts: Int, bigEvery: Int = 10) -> [SpikePost] {
    (0..<posts).map { p in
        let count = (p % bigEvery == bigEvery - 1) ? 50 : 5
        return SpikePost(blocks: (0..<count).map { b in
            (id: "post\(p)-block\(b)", text: blockText(post: p, block: b))
        })
    }
}

// MARK: - Candidate (b): non-editable TK2 NSTextView sized to content

@MainActor
func makeReadView(_ post: SpikePost, width: CGFloat) -> NSTextView {
    let tv = NSTextView(usingTextLayoutManager: true)
    precondition(tv.textLayoutManager != nil, "TK2 opt-in failed")
    tv.isEditable = false
    tv.isSelectable = true
    tv.isRichText = false
    tv.textContainerInset = NSSize(width: 8, height: 8)
    tv.textContainer?.widthTracksTextView = true
    tv.frame = NSRect(x: 0, y: 0, width: width, height: 100)
    tv.textStorage?.setAttributedString(post.attributed())
    sizeToContent(tv)
    return tv
}

@MainActor
func sizeToContent(_ tv: NSTextView) {
    guard let lm = tv.textLayoutManager else { return }
    lm.ensureLayout(for: lm.documentRange)
    let height = lm.usageBoundsForTextContainer.height + tv.textContainerInset.height * 2
    tv.frame.size.height = max(height, 1)
}

@MainActor
func blockFragmentFrame(_ tv: NSTextView, offset: Int) -> CGRect? {
    guard let lm = tv.textLayoutManager, let cm = lm.textContentManager,
          let loc = cm.location(cm.documentRange.location, offsetBy: offset)
    else { return nil }
    var frame: CGRect?
    lm.enumerateTextLayoutFragments(from: loc, options: [.ensuresLayout]) {
        frame = $0.layoutFragmentFrame
        return false
    }
    return frame
}

@MainActor
func runCandidateB(corpus: [SpikePost]) {
    print("== Candidate (b): non-editable TK2 NSTextView per post, sized to content, width 600 ==")

    // Per-view setup+layout cost, a dozen "visible" posts (corpus mix:
    // typical 5-block posts + one 50-block big post — the bigEvery slot).
    let dozen = Array(corpus.prefix(12))
    let memBefore = physFootprintMB()
    var setupTimes: [Double] = []
    var views: [NSTextView] = []
    for post in dozen {
        let t0 = nowMS()
        views.append(makeReadView(post, width: 600))
        setupTimes.append(nowMS() - t0)
    }
    let memDozen = physFootprintMB()
    print("  setup+fullLayout per view (12 views, mix 11×5-block + 1×50-block):")
    print("    \(Stats(setupTimes).line)")
    let bigIndex = dozen.firstIndex { $0.blocks.count == 50 } ?? 0
    print("    the 50-block view alone: \(fmt(setupTimes[bigIndex])) ms")
    print("  memory: baseline \(fmt(memBefore, 1)) MB -> 12 views \(fmt(memDozen, 1)) MB (Δ \(fmt(memDozen - memBefore, 1)) MB)")

    var fifty: [NSTextView] = []
    for post in corpus { fifty.append(makeReadView(post, width: 600)) }
    let memFifty = physFootprintMB()
    print("  memory: 50 MORE views (62 total live) -> \(fmt(memFifty, 1)) MB (Δ from baseline \(fmt(memFifty - memBefore, 1)) MB)")

    // Projection refresh, full vs differential, on the big view.
    let bigView = views[bigIndex]
    let bigPost = dozen[bigIndex]
    var refreshed = bigPost
    refreshed = SpikePost(blocks: refreshed.blocks.enumerated().map { i, b in
        i == 25 ? (id: b.id, text: b.text + " Edited elsewhere.") : b
    })
    var t0 = nowMS()
    bigView.textStorage?.setAttributedString(refreshed.attributed())
    sizeToContent(bigView)
    let fullRefresh = nowMS() - t0

    // Differential: replace ONE block's range only (the Phase 7 idiom).
    let starts = refreshed.blockStarts
    let target = 25
    let oldLen = (refreshed.blocks[target].text as NSString).length
    let newText = refreshed.blocks[target].text + " More."
    t0 = nowMS()
    bigView.textStorage?.replaceCharacters(
        in: NSRange(location: starts[target], length: oldLen), with: newText)
    sizeToContent(bigView)
    let diffRefresh = nowMS() - t0
    print("  projection refresh on the 50-block view: full setAttributedString \(fmt(fullRefresh)) ms · differential one-block replace \(fmt(diffRefresh)) ms")

    // Selection: cross-block by construction (one view spans the post);
    // survival across a differential refresh vs a full one.
    let selection = NSRange(location: starts[30], length: 60) // spans block 30 into 31
    bigView.setSelectedRange(selection)
    let crossBlock = bigView.selectedRange() == selection
    // Differential edit BEFORE the selection: NSTextView shifts it.
    let before = bigView.selectedRange()
    bigView.textStorage?.replaceCharacters(
        in: NSRange(location: starts[2], length: 5), with: "XYZAB")
    let afterDiff = bigView.selectedRange()
    let survivedDiff = afterDiff.length == before.length && afterDiff.length > 0
    // Full re-set: selection resets (the known cost of full renders).
    bigView.textStorage?.setAttributedString(refreshed.attributed())
    let afterFull = bigView.selectedRange()
    print("  selection: cross-block per-post = \(crossBlock) · survives DIFFERENTIAL refresh = \(survivedDiff) (len \(before.length) -> \(afterDiff.length)) · survives FULL re-set = \(afterFull.length > 0) (len -> \(afterFull.length))")

    // Badge anchoring: a fragment frame for every block start.
    let anchorable = refreshed.blockStarts.allSatisfy { blockFragmentFrame(bigView, offset: $0) != nil }
    print("  badge anchoring: fragment frame available for every block start = \(anchorable)")

    // Scroll-through: 50 views stacked in one flipped document view inside a
    // real NSScrollView; step the clip through the whole stack.
    let stack = FlippedView(frame: .zero)
    var y: CGFloat = 0
    for view in fifty {
        view.setFrameOrigin(NSPoint(x: 0, y: y))
        stack.addSubview(view)
        y += view.frame.height + 24
    }
    stack.frame = NSRect(x: 0, y: 0, width: 600, height: y)
    let scroll = NSScrollView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
    scroll.documentView = stack
    var stepTimes: [Double] = []
    var offset: CGFloat = 0
    while offset < y - 800 {
        let t = nowMS()
        scroll.contentView.scroll(to: NSPoint(x: 0, y: offset))
        scroll.reflectScrolledClipView(scroll.contentView)
        stepTimes.append(nowMS() - t)
        offset += 200
    }
    print("  scroll-through 50 stacked views (200 px steps, \(stepTimes.count) steps): \(Stats(stepTimes).line)")

    withExtendedLifetime(views) {}
    withExtendedLifetime(fifty) {}
}

final class FlippedView: NSView {
    override var isFlipped: Bool { true }
}

// MARK: - Candidate (a): SwiftUI Text in a LazyVStack

struct PostListModel {
    var posts: [SpikePost]
}

struct ReadTierList: View {
    let posts: [AttributedString]
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(posts.indices, id: \.self) { i in
                    Text(posts[i])
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(8)
        }
    }
}

@MainActor
func runCandidateA(corpus: [SpikePost]) {
    print("== Candidate (a): SwiftUI Text(AttributedString) + .textSelection(.enabled), LazyVStack ==")
    let attributed = corpus.map { AttributedString($0.attributed()) }

    let memBefore = physFootprintMB()
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 600, height: 800),
        styleMask: [.titled], backing: .buffered, defer: false)
    var t0 = nowMS()
    let hosting = NSHostingView(rootView: ReadTierList(posts: attributed))
    hosting.frame = NSRect(x: 0, y: 0, width: 600, height: 800)
    window.contentView = hosting
    window.orderBack(nil)
    hosting.layoutSubtreeIfNeeded()
    window.displayIfNeeded()
    RunLoop.main.run(until: Date().addingTimeInterval(0.3))
    let firstLayout = nowMS() - t0
    let memAfter = physFootprintMB()
    print("  first layout of the 50-post LazyVStack window: \(fmt(firstLayout)) ms (includes one 0.3 s run-loop settle)")
    print("  memory: baseline \(fmt(memBefore, 1)) MB -> hosted list \(fmt(memAfter, 1)) MB (Δ \(fmt(memAfter - memBefore, 1)) MB)")

    // Content refresh: one post's text changes, the list re-renders.
    var refreshed = attributed
    refreshed[3] = AttributedString(NSAttributedString(string: String(repeating: "Changed text. ", count: 40)))
    t0 = nowMS()
    hosting.rootView = ReadTierList(posts: refreshed)
    hosting.layoutSubtreeIfNeeded()
    window.displayIfNeeded()
    RunLoop.main.run(until: Date().addingTimeInterval(0.1))
    print("  one-post content refresh (root re-set + settle): \(fmt(nowMS() - t0)) ms (includes one 0.1 s run-loop settle)")

    print("  capability axes (API facts, not runtime measurements — memo records the lookup):")
    print("    per-block geometry inside one Text (badge anchoring): NO public API to read")
    print("    text-range frames out of a Text view; TextRenderer exposes Text.Layout only")
    print("    inside the draw pass. Cross-Text selection: one gesture cannot span Text views.")
    window.orderOut(nil)
}

// MARK: - Entry

final class SpikeAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let pi = ProcessInfo.processInfo
        print("ReadTierSpike — Phase 10 Step 0 (\(pi.operatingSystemVersionString))")
        print("Corpus: 50 posts — 45 typical (5 blocks ≈ 600 chars) + 5 big (50 blocks ≈ 6k chars); width 600.")
        print("")
        let corpus = makeCorpus(posts: 50)
        autoreleasepool { runCandidateB(corpus: corpus) }
        print("")
        autoreleasepool { runCandidateA(corpus: corpus) }
        exit(0)
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = SpikeAppDelegate()
app.delegate = delegate
app.run()
