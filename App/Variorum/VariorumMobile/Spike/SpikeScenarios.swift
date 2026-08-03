//
//  SpikeScenarios.swift
//  VariorumMobile — Stage 0 TK2-on-iOS spike (THROWAWAY; deleted at stage close)
//
//  The in-process measurement scenarios (the Phase 6 Mac spike's inventory,
//  iOS edition). Every fact gets a number; every action gets a canary
//  checkpoint. Fresh cold views per rep where the Mac spike used them.
//

#if DEBUG

import UIKit

@MainActor
final class SpikeScenarios {
    let bench: SpikeBenchViewController
    let recorder = SpikeRecorder.shared
    private var corpus50: SpikeCorpus.Result?

    init(bench: SpikeBenchViewController) {
        self.bench = bench
    }

    // MARK: - Plumbing

    private func settle(_ milliseconds: Int = 60) async {
        try? await Task.sleep(for: .milliseconds(milliseconds))
    }

    /// A fresh, cold TK2 view over the given corpus, mounted full-bleed in
    /// the scenario container, one forced viewport layout.
    private func freshView(_ corpus: SpikeCorpus.Result) -> UITextView {
        let tv = UITextView(usingTextLayoutManager: true)
        precondition(tv.textLayoutManager != nil)
        tv.frame = bench.scenarioContainer.bounds
        tv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tv.isEditable = true
        tv.autocorrectionType = .no  // scenarios measure OUR mutations; the real pipeline is the UITest's
        tv.attributedText = corpus.text
        bench.scenarioContainer.addSubview(tv)
        bench.scenarioContainer.isHidden = false
        bench.scenarioContainer.layoutIfNeeded()
        tv.textLayoutManager?.textViewportLayoutController.layoutViewport()
        return tv
    }

    private func teardown(_ tv: UITextView) {
        tv.removeFromSuperview()
    }

    private func location(_ tv: UITextView, at charIndex: Int) -> NSTextLocation? {
        guard let tlm = tv.textLayoutManager, let cm = tlm.textContentManager else { return nil }
        return cm.location(tlm.documentRange.location, offsetBy: charIndex)
    }

    private func textRange(_ tv: UITextView, chars: NSRange) -> NSTextRange? {
        guard let tlm = tv.textLayoutManager,
            let start = location(tv, at: chars.location),
            let end = location(tv, at: chars.location + chars.length)
        else { return nil }
        _ = tlm
        return NSTextRange(location: start, end: end)
    }

    /// The laid-out fragment frame containing charIndex, ensuring layout for
    /// exactly that fragment (the hybrid primitive's core — cost ∝ one
    /// fragment, never the document).
    private func ensuredFragmentFrame(_ tv: UITextView, at charIndex: Int) -> CGRect {
        guard let tlm = tv.textLayoutManager, let loc = location(tv, at: charIndex) else {
            return .null
        }
        var frame = CGRect.null
        tlm.enumerateTextLayoutFragments(from: loc, options: [.ensuresLayout]) { frag in
            frame = frag.layoutFragmentFrame
            return false
        }
        return frame
    }

    private func blockIndex(_ corpus: SpikeCorpus.Result, containing charIndex: Int) -> Int {
        var lo = 0
        var hi = corpus.blockRanges.count - 1
        while lo <= hi {
            let mid = (lo + hi) / 2
            let r = corpus.blockRanges[mid]
            if charIndex < r.location {
                hi = mid - 1
            } else if charIndex >= r.location + r.length {
                lo = mid + 1
            } else {
                return mid
            }
        }
        return max(0, min(corpus.blockRanges.count - 1, lo))
    }

    /// Block index at the visible top of the view (nil if the top fragment
    /// isn't laid out — recorded, never crashed on).
    private func topBlockIndex(_ tv: UITextView, _ corpus: SpikeCorpus.Result) -> Int? {
        guard let tlm = tv.textLayoutManager, let cm = tlm.textContentManager else { return nil }
        let point = CGPoint(x: 5, y: max(0, tv.contentOffset.y - tv.textContainerInset.top) + 1)
        guard let frag = tlm.textLayoutFragment(for: point) else { return nil }
        let offset = cm.offset(from: tlm.documentRange.location, to: frag.rangeInElement.location)
        return blockIndex(corpus, containing: offset)
    }

    private func corpus50k() -> SpikeCorpus.Result {
        if let c = corpus50 { return c }
        let c = SpikeCorpus.make(seed: 7, targetWords: 50_000)
        corpus50 = c
        return c
    }

    // MARK: - Item 1: TK2 opt-in + fallback-trigger inventory + positive control

    func runFallbackInventory() async {
        recorder.record("1.begin|fallback trigger inventory (checkpoint canary after every action)")
        let corpus = corpus50k()
        let tv = freshView(corpus)
        defer { teardown(tv) }
        let canary = SpikeCanary()

        func exercise(_ name: String, _ body: () -> Void) {
            body()
            tv.textLayoutManager?.textViewportLayoutController.layoutViewport()
            let alive = canary.check(tv, after: name)
            recorder.record("1.action|\(name)|tk2Alive=\(alive ? "YES" : "NO")")
        }

        // Typing bursts at start / middle / end (30 chars each).
        for (label, index) in [("start", 10), ("middle", corpus.utf16Length / 2), ("end", corpus.utf16Length - 2)] {
            exercise("typing burst @\(label)") {
                tv.selectedRange = NSRange(location: index, length: 0)
                for ch in "the quiet morning held its brf" {
                    tv.insertText(String(ch))
                }
            }
        }

        // Attribute add/remove, visible + offscreen paragraphs.
        exercise("textStorage attribute add/remove (visible + offscreen)") {
            let storage = tv.textStorage
            storage.beginEditing()
            storage.addAttribute(.foregroundColor, value: UIColor.systemRed, range: corpus.blockRanges[1])
            storage.addAttribute(
                SpikeCorpus.blockIDKey, value: NSNumber(value: 9_999),
                range: NSRange(location: corpus.blockRanges[1].location, length: 5))
            storage.removeAttribute(.foregroundColor, range: corpus.blockRanges[1])
            let far = corpus.blockRanges[corpus.blockRanges.count - 10]
            storage.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: far)
            storage.removeAttribute(.foregroundColor, range: far)
            storage.endEditing()
        }

        // Rendering attributes on a visible range (the §3-fragile path).
        exercise("rendering attributes set + invalidate") {
            guard let tlm = tv.textLayoutManager,
                let range = textRange(tv, chars: corpus.blockRanges[0])
            else { return }
            tlm.setRenderingAttributes([.foregroundColor: UIColor.systemOrange], for: range)
            tlm.invalidateRenderingAttributes(for: range)
        }

        // Selection sweep — far jumps across the whole document.
        exercise("selection sweep (11 far jumps)") {
            var samples: [Double] = []
            for i in 0...10 {
                let target = (corpus.utf16Length - 2) * i / 10
                samples.append(spikeMS { tv.selectedRange = NSRange(location: target, length: 50) })
            }
            recorder.record("1.selectionSweep|\(SpikeStats(samples).line)")
        }

        // Marked-text cycle (multi-stage input's mechanism).
        exercise("setMarkedText x2 + unmarkText") {
            tv.selectedRange = NSRange(location: corpus.blockRanges[3].location + 12, length: 0)
            tv.setMarkedText("hell", selectedRange: NSRange(location: 4, length: 0))
            tv.setMarkedText("hello", selectedRange: NSRange(location: 5, length: 0))
            tv.unmarkText()
        }

        // Autocorrect-shaped replace through UITextInput.
        exercise("UITextInput replace(_:withText:)") {
            let charStart = corpus.blockRanges[4].location + 4
            if let start = tv.position(from: tv.beginningOfDocument, offset: charStart),
                let end = tv.position(from: start, offset: 5),
                let range = tv.textRange(from: start, to: end)
            {
                tv.replace(range, withText: "swapd")
            }
        }

        // Trait toggles.
        exercise("autocorrection/spellChecking trait toggles") {
            tv.autocorrectionType = .yes
            tv.spellCheckingType = .yes
            tv.autocorrectionType = .no
            tv.spellCheckingType = .no
        }

        // 2k-word attributed paste mid-document.
        exercise("2k-word attributed paste mid-document") {
            let paste = SpikeCorpus.make(seed: 42, targetWords: 2_000).text
            let at = corpus.utf16Length / 2
            let t = spikeMS {
                tv.textStorage.beginEditing()
                tv.textStorage.insert(paste, at: at)
                tv.textStorage.endEditing()
            }
            recorder.record(String(format: "1.paste2k|%.1fms", t))
        }

        // Undo (guarded — programmatic edits may or may not register).
        exercise("undoManager undo x1") {
            if tv.undoManager?.canUndo == true { tv.undoManager?.undo() }
        }

        // Editability toggles.
        exercise("isEditable/isSelectable toggles") {
            tv.isEditable = false
            tv.isSelectable = false
            tv.isSelectable = true
            tv.isEditable = true
        }

        recorder.record(
            "1.inventory|done|fallback=\(canary.fallbackDetectedAfter ?? "NONE under exercised inventory")")
        recorder.record("1.notExercised|NSTextList/lists, Writing Tools, custom caret (out of product scope — same as Mac spike)")

        // POSITIVE CONTROL: deliberately touch .layoutManager on a scratch
        // view and confirm the poll-based canary DETECTS the downgrade.
        let scratch = UITextView(usingTextLayoutManager: true)
        scratch.frame = bench.scenarioContainer.bounds
        bench.scenarioContainer.addSubview(scratch)
        scratch.attributedText = NSAttributedString(string: "positive control")
        let before = scratch.textLayoutManager != nil
        let lm = scratch.layoutManager  // the confirmed downgrade trigger
        let after = scratch.textLayoutManager != nil
        recorder.record(
            "1.positiveControl|tk2Before=\(before ? "YES" : "NO")|layoutManagerReturned=\(lm != nil ? "nonnil" : "nil")|tk2After=\(after ? "YES" : "NO")|pollCanaryDetects=\(before && !after ? "YES" : "NO")"
        )
        scratch.removeFromSuperview()
        await settle()
    }

    // MARK: - Item 2: scale — load, height convergence, scroll walk, scroll-to-end

    func runScale(words: Int) async {
        let corpus = words == 50_000 ? corpus50k() : SpikeCorpus.make(seed: 7, targetWords: words)
        recorder.record(
            "2.begin|scale=\(words)|blocks=\(corpus.blockCount)|words=\(corpus.wordCount)|utf16=\(corpus.utf16Length)")

        // Load + first layout.
        let tv = UITextView(usingTextLayoutManager: true)
        tv.frame = bench.scenarioContainer.bounds
        tv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bench.scenarioContainer.addSubview(tv)
        bench.scenarioContainer.isHidden = false
        let tLoad = spikeMS { tv.attributedText = corpus.text }
        let tFirst = spikeMS {
            bench.scenarioContainer.layoutIfNeeded()
            tv.textLayoutManager?.textViewportLayoutController.layoutViewport()
        }
        recorder.record(String(format: "2.load|setAttributedText=%.1fms|firstViewportLayout=%.1fms", tLoad, tFirst))

        guard let tlm = tv.textLayoutManager else {
            recorder.record("2.ABORT|TK2 DEAD — geometry probes skipped")
            teardown(tv)
            return
        }

        // Initial + at-rest estimates.
        let initialUsage = tlm.usageBoundsForTextContainer.height
        let initialContent = tv.contentSize.height
        await settle(120)
        let restUsage = tlm.usageBoundsForTextContainer.height
        let restContent = tv.contentSize.height
        recorder.record(
            String(
                format: "2.estimate|initialUsage=%.0fpx|restUsage=%.0fpx|initialContentSize=%.0fpx|restContentSize=%.0fpx",
                initialUsage, restUsage, initialContent, restContent))

        // Walk to the end in viewport steps: revisions, max delta, content monotonicity.
        var lastUsage = restUsage
        var lastContent = restContent
        var usageRevisions = 0
        var contentRevisions = 0
        var maxUsageDelta = 0.0
        var regressions = 0
        var lastTopBlock = -1
        var steps = 0
        let stepHeight = max(200, tv.bounds.height - 40)
        var y = 0.0
        while y < tv.contentSize.height - tv.bounds.height, steps < 2000 {
            y += stepHeight
            tv.setContentOffset(CGPoint(x: 0, y: min(y, max(0, tv.contentSize.height - tv.bounds.height))), animated: false)
            tlm.textViewportLayoutController.layoutViewport()
            let usage = tlm.usageBoundsForTextContainer.height
            if usage != lastUsage {
                usageRevisions += 1
                maxUsageDelta = max(maxUsageDelta, abs(usage - lastUsage))
                lastUsage = usage
            }
            if tv.contentSize.height != lastContent {
                contentRevisions += 1
                lastContent = tv.contentSize.height
            }
            if let top = topBlockIndex(tv, corpus) {
                if top < lastTopBlock { regressions += 1 }
                lastTopBlock = max(lastTopBlock, top)
            }
            steps += 1
        }
        await settle(120)
        let settled = tlm.usageBoundsForTextContainer.height
        recorder.record(
            String(
                format: "2.walk|steps=%d|usageRevisions=%d|maxUsageDelta=%.0fpx|contentSizeRevisions=%d|contentRegressions=%d|settledHeight=%.0fpx",
                steps, usageRevisions, maxUsageDelta, contentRevisions, regressions, settled))
        recorder.record(
            String(
                format: "2.estimateError|initialVsSettled=%.1f%%|restVsSettled=%.1f%%",
                (settled - initialUsage) / settled * 100, (settled - restUsage) / settled * 100))

        // Scroll-to-end after the walk: is the last line laid out and visible?
        let lastFrame = ensuredFragmentFrame(tv, at: corpus.utf16Length - 2)
        let visibleTop = tv.contentOffset.y - tv.textContainerInset.top
        let lastVisible =
            lastFrame.maxY <= visibleTop + tv.bounds.height + 1 && lastFrame.maxY > visibleTop
        recorder.record(
            String(
                format: "2.endAfterWalk|lastFragMaxY=%.0f|visibleTop=%.0f|lastLineVisible=%@",
                lastFrame.maxY, visibleTop, lastVisible ? "YES" : "NO"))
        teardown(tv)

        // Cold scroll-to-end on a fresh view.
        let cold = freshView(corpus)
        guard let coldTLM = cold.textLayoutManager else { teardown(cold); return }
        let t0 = CACurrentMediaTime()
        var iterations = 0
        while iterations < 12 {
            let target = max(0, cold.contentSize.height + cold.adjustedContentInset.bottom - cold.bounds.height)
            if abs(cold.contentOffset.y - target) <= 1 { break }
            cold.setContentOffset(CGPoint(x: 0, y: target), animated: false)
            coldTLM.textViewportLayoutController.layoutViewport()
            iterations += 1
        }
        let tEnd = (CACurrentMediaTime() - t0) * 1000
        let coldLast = ensuredFragmentFrame(cold, at: corpus.utf16Length - 2)
        let coldTop = cold.contentOffset.y - cold.textContainerInset.top
        let coldVisible =
            coldLast.maxY <= coldTop + cold.bounds.height + 1 && coldLast.maxY > coldTop
        recorder.record(
            String(
                format: "2.coldScrollToEnd|%.1fms|iterations=%d|lastLineVisible=%@|residual=%.1fpx",
                tEnd, iterations, coldVisible ? "YES" : "NO",
                abs(coldLast.maxY - (coldTop + cold.bounds.height))))
        teardown(cold)
        bench.scenarioContainer.isHidden = true
    }

    // MARK: - Item 2: scroll-to-location (the jump primitive)

    func runJumps(words: Int = 50_000, fractions: [Double] = [0.1, 0.25, 0.5, 0.75, 0.9], reps: Int = 3) async {
        let corpus = words == 50_000 ? corpus50k() : SpikeCorpus.make(seed: 7, targetWords: words)
        recorder.record("2.jumps.begin|scale=\(words)")

        struct Sample {
            let strategy: String
            let fraction: Double
            let ms: Double
            let errorPX: Double
            let errorBlocks: Int
            let driftPX: Double
            let iterations: Int
        }
        var samples: [Sample] = []

        for fraction in fractions {
            let targetChar = corpus.blockRanges[
                blockIndex(corpus, containing: Int(fraction * Double(corpus.utf16Length)))
            ].location
            let targetBlock = blockIndex(corpus, containing: targetChar)

            for _ in 0..<reps {
                // Strategy A: proportional offset only (cold view).
                let a = freshView(corpus)
                if a.textLayoutManager != nil {
                    let tA = CACurrentMediaTime()
                    let maxOffset = max(0, a.contentSize.height - a.bounds.height)
                    a.setContentOffset(CGPoint(x: 0, y: fraction * maxOffset), animated: false)
                    a.textLayoutManager?.textViewportLayoutController.layoutViewport()
                    let msA = (CACurrentMediaTime() - tA) * 1000
                    await settle(80)
                    let frame = ensuredFragmentFrame(a, at: targetChar)
                    let want = frame.minY + a.textContainerInset.top
                    let errorPX = abs(a.contentOffset.y - want)
                    let top = topBlockIndex(a, corpus) ?? -1
                    samples.append(
                        Sample(
                            strategy: "A", fraction: fraction, ms: msA, errorPX: errorPX,
                            errorBlocks: top >= 0 ? abs(top - targetBlock) : -1, driftPX: 0,
                            iterations: 0))
                }
                teardown(a)

                // Strategy C: bounded hybrid (cold view) — proportional guess,
                // ensureLayout on the ONE target fragment, correct, ≤3 iterations.
                let c = freshView(corpus)
                if c.textLayoutManager != nil {
                    let tC = CACurrentMediaTime()
                    let maxOffset = max(0, c.contentSize.height - c.bounds.height)
                    c.setContentOffset(CGPoint(x: 0, y: fraction * maxOffset), animated: false)
                    c.textLayoutManager?.textViewportLayoutController.layoutViewport()
                    var iterations = 0
                    while iterations < 3 {
                        let frame = ensuredFragmentFrame(c, at: targetChar)
                        let want = frame.minY + c.textContainerInset.top
                        let clamped = min(max(0, want), max(0, c.contentSize.height - c.bounds.height))
                        if abs(c.contentOffset.y - clamped) <= 0.5 { break }
                        c.setContentOffset(CGPoint(x: 0, y: clamped), animated: false)
                        c.textLayoutManager?.textViewportLayoutController.layoutViewport()
                        iterations += 1
                    }
                    let msC = (CACurrentMediaTime() - tC) * 1000
                    let landedOffset = c.contentOffset.y
                    let frame = ensuredFragmentFrame(c, at: targetChar)
                    let want = min(
                        max(0, frame.minY + c.textContainerInset.top),
                        max(0, c.contentSize.height - c.bounds.height))
                    let errorPX = abs(landedOffset - want)
                    await settle(150)
                    c.textLayoutManager?.textViewportLayoutController.layoutViewport()
                    let frame2 = ensuredFragmentFrame(c, at: targetChar)
                    let want2 = min(
                        max(0, frame2.minY + c.textContainerInset.top),
                        max(0, c.contentSize.height - c.bounds.height))
                    let drift = abs(c.contentOffset.y - want2)
                    let top = topBlockIndex(c, corpus) ?? -1
                    samples.append(
                        Sample(
                            strategy: "C", fraction: fraction, ms: msC, errorPX: errorPX,
                            errorBlocks: top >= 0 ? abs(top - targetBlock) : -1, driftPX: drift,
                            iterations: iterations))
                }
                teardown(c)
            }
        }

        for strategy in ["A", "C"] {
            let subset = samples.filter { $0.strategy == strategy }
            guard !subset.isEmpty else { continue }
            let stats = SpikeStats(subset.map(\.ms))
            let maxError = subset.map(\.errorPX).max() ?? 0
            let maxBlocks = subset.map(\.errorBlocks).max() ?? 0
            let maxDrift = subset.map(\.driftPX).max() ?? 0
            let maxIter = subset.map(\.iterations).max() ?? 0
            recorder.record(
                String(
                    format: "2.jump.%@|n=%d|%@|maxErrorPX=%.1f|maxErrorBlocks=%d|maxPostSettleDrift=%.1fpx|maxIterations=%d",
                    strategy, subset.count, stats.line, maxError, maxBlocks, maxDrift, maxIter))
        }
        bench.scenarioContainer.isHidden = true
    }

    // MARK: - Item 2: typing latency at scale

    func runTyping(words: Int = 50_000) async {
        let corpus = words == 50_000 ? corpus50k() : SpikeCorpus.make(seed: 7, targetWords: words)
        recorder.record("2.typing.begin|scale=\(words)")
        let tv = freshView(corpus)
        defer {
            teardown(tv)
            bench.scenarioContainer.isHidden = true
        }
        guard tv.textLayoutManager != nil else {
            recorder.record("2.typing|TK2 DEAD — skipped")
            return
        }
        _ = tv.becomeFirstResponder()

        func burst(_ label: String, at charIndex: Int, count: Int = 120) {
            // Land the viewport at the position first (the hybrid primitive),
            // then type — the editor-shaped condition.
            let frame = ensuredFragmentFrame(tv, at: charIndex)
            let want = min(
                max(0, frame.minY + tv.textContainerInset.top - 40),
                max(0, tv.contentSize.height - tv.bounds.height))
            tv.setContentOffset(CGPoint(x: 0, y: want), animated: false)
            tv.textLayoutManager?.textViewportLayoutController.layoutViewport()
            tv.selectedRange = NSRange(location: charIndex, length: 0)
            var samples: [Double] = []
            let chars = Array("the quiet morning held its breath while she wrote another paragraph")
            for i in 0..<count {
                let ch = String(chars[i % chars.count])
                samples.append(
                    spikeMS {
                        tv.insertText(ch)
                        tv.textLayoutManager?.textViewportLayoutController.layoutViewport()
                    })
            }
            recorder.record("2.typing.\(label)|n=\(count)|\(SpikeStats(samples).line)")
        }

        burst("start", at: 10)
        burst("middle", at: corpus.utf16Length / 2)
        burst("end", at: tv.textStorage.length - 2)

        // 5k-word attributed paste mid-document, then re-measure at middle.
        let paste = SpikeCorpus.make(seed: 43, targetWords: 5_000).text
        let tPaste = spikeMS {
            tv.textStorage.beginEditing()
            tv.textStorage.insert(paste, at: tv.textStorage.length / 2)
            tv.textStorage.endEditing()
            tv.textLayoutManager?.textViewportLayoutController.layoutViewport()
        }
        recorder.record(String(format: "2.typing.paste5k|%.1fms", tPaste))
        burst("middleAfterPaste", at: tv.textStorage.length / 2)

        _ = tv.resignFirstResponder()
    }

    /// ensureLayout over the WHOLE document — the P1-banned reference number.
    func runEnsureLayoutReference(words: Int) async {
        let corpus = words == 50_000 ? corpus50k() : SpikeCorpus.make(seed: 7, targetWords: words)
        let tv = freshView(corpus)
        defer {
            teardown(tv)
            bench.scenarioContainer.isHidden = true
        }
        guard let tlm = tv.textLayoutManager else { return }
        let t = spikeMS { tlm.ensureLayout(for: tlm.documentRange) }
        recorder.record(
            String(
                format: "2.ensureLayoutReference|scale=%d|%.1fms|trueHeight=%.0fpx", words, t,
                tlm.usageBoundsForTextContainer.height))
    }

    // MARK: - Item 3: attribute survival under input-system-shaped mutations

    func runAttributeSurvival() async {
        recorder.record("3.begin|attribute survival (programmatic UITextInput primitives; the REAL keyboard pipeline is the UITest's half)")
        let small = SpikeCorpus.make(seed: 21, targetWords: 300, giants: false)

        func fresh() -> UITextView {
            freshView(small)
        }

        func audit(_ tv: UITextView, _ name: String, blockIndex: Int, range: NSRange) {
            let runs = SpikeAttributeAudit.runs(in: tv.textStorage, range: range)
            let verdict = SpikeAttributeAudit.classify(runs, expected: blockIndex)
            recorder.record(
                "3.case|\(name)|\(verdict)|runs=\(SpikeAttributeAudit.describe(runs))")
        }

        // Case P — plain insertText mid-block (predictive-acceptance shape:
        // whole word + space arrives at once). Probe typingAttributes first:
        // does UIKit's derived typing state even CARRY the custom key?
        do {
            let tv = fresh()
            let block = 1
            let caret = small.blockRanges[block].location + 20
            tv.selectedRange = NSRange(location: caret, length: 0)
            let carriesKey = tv.typingAttributes[SpikeCorpus.blockIDKey] != nil
            recorder.record("3.typingAttributes|carryCustomKeyAtMidBlockCaret=\(carriesKey ? "YES" : "NO")|keys=\(tv.typingAttributes.keys.map(\.rawValue).sorted().joined(separator: ","))")
            tv.insertText("inserted ")
            let grownRange = NSRange(
                location: small.blockRanges[block].location,
                length: small.blockRanges[block].length + 9)
            audit(tv, "P.insertText-word+space", blockIndex: block, range: grownRange)
            // The repair cost Stage 1's reconciler would pay: re-stamp the
            // whole mutated paragraph's block ID (O(paragraph), never O(doc)).
            let tRestamp = spikeMS {
                tv.textStorage.addAttribute(
                    SpikeCorpus.blockIDKey, value: NSNumber(value: block), range: grownRange)
            }
            let repaired = SpikeAttributeAudit.classify(
                SpikeAttributeAudit.runs(in: tv.textStorage, range: grownRange), expected: block)
            recorder.record(
                String(format: "3.restampRepair|%.3fms|len=%d|verdict=%@", tRestamp,
                    grownRange.length, repaired))
            teardown(tv)
        }

        // Case B — insertText at a block START (boundary inheritance: the
        // preceding char is the PREVIOUS block's newline — does the new text
        // inherit the neighbor's ID? The seam risk Stage 1's reconciler owns).
        do {
            let tv = fresh()
            let block = 2
            let caret = small.blockRanges[block].location
            tv.selectedRange = NSRange(location: caret, length: 0)
            tv.insertText("Boundary")
            let runs = SpikeAttributeAudit.runs(
                in: tv.textStorage, range: NSRange(location: caret, length: 8))
            recorder.record(
                "3.case|B.insertText-at-block-start|insertedTextGotID=\(runs.first?.blockID.map(String.init) ?? "MISSING")|expectedOwn=\(block)|prev=\(block - 1)")
            teardown(tv)
        }

        // Case M — staged marked text, committed via unmarkText.
        do {
            let tv = fresh()
            let block = 1
            let caret = small.blockRanges[block].location + 20
            tv.selectedRange = NSRange(location: caret, length: 0)
            tv.setMarkedText("hell", selectedRange: NSRange(location: 4, length: 0))
            tv.setMarkedText("hello", selectedRange: NSRange(location: 5, length: 0))
            let midRuns = SpikeAttributeAudit.runs(
                in: tv.textStorage, range: NSRange(location: caret, length: 5))
            tv.unmarkText()
            recorder.record(
                "3.case|M.marked-mid|whileMarked=\(SpikeAttributeAudit.describe(midRuns))")
            audit(
                tv, "M.marked-committed", blockIndex: block,
                range: NSRange(
                    location: small.blockRanges[block].location,
                    length: small.blockRanges[block].length + 5))
            teardown(tv)
        }

        // Case M2 — marked text replaced by insertText (the QWERTY
        // candidate-acceptance shape).
        do {
            let tv = fresh()
            let block = 1
            let caret = small.blockRanges[block].location + 20
            tv.selectedRange = NSRange(location: caret, length: 0)
            tv.setMarkedText("helo", selectedRange: NSRange(location: 4, length: 0))
            tv.insertText("hello ")
            audit(
                tv, "M2.marked-then-insertText", blockIndex: block,
                range: NSRange(
                    location: small.blockRanges[block].location,
                    length: small.blockRanges[block].length + 6))
            teardown(tv)
        }

        // Case R — autocorrect-shaped replace(_:withText:) over a mid-block
        // word (the mechanism the input system uses for a correction).
        do {
            let tv = fresh()
            let block = 1
            let wordStart = small.blockRanges[block].location + 4
            if let start = tv.position(from: tv.beginningOfDocument, offset: wordStart),
                let end = tv.position(from: start, offset: 5),
                let range = tv.textRange(from: start, to: end)
            {
                tv.replace(range, withText: "fixed")
            }
            audit(
                tv, "R.replace-word", blockIndex: block,
                range: small.blockRanges[block])
            teardown(tv)
        }

        // Case D — dictation PROXY (UIDictationPhrase is not publicly
        // constructible; dictation's default landing is phrase-batch
        // insertText — recorded honestly as a proxy, the real path is a
        // device item).
        do {
            let tv = fresh()
            let block = min(3, small.blockRanges.count - 2)
            let caret = small.blockRanges[block].location + 10
            tv.selectedRange = NSRange(location: caret, length: 0)
            tv.insertText("a dictated phrase arrives whole ")
            audit(
                tv, "D.dictation-proxy-batch-insert", blockIndex: block,
                range: NSRange(
                    location: small.blockRanges[block].location,
                    length: small.blockRanges[block].length + 32))
            teardown(tv)
        }

        bench.scenarioContainer.isHidden = true
    }

    // MARK: - Item 4: fragment-rect scoping (the in-process half)

    func runGestureGeometry() async {
        recorder.record("4.begin|fragment-rect scoping + peek overlay (in-process half; real touches are the UITest's)")
        let tv = bench.textView!
        let t = spikeMS { _ = bench.fragmentRects(for: bench.fannedBlockIndex, in: tv) }
        let rects = bench.fragmentRects(for: bench.fannedBlockIndex, in: tv)
        recorder.record(
            String(format: "4.rects|count=%d|%.2fms|union=%@", rects.count, t,
                rects.isEmpty
                    ? "none"
                    : NSCoder.string(for: rects.dropFirst().reduce(rects[0]) { $0.union($1) })))

        // Peek flip round-trip with zero-storage-write proof.
        let before = SpikeAttributeAudit.fingerprint(tv.textStorage)
        let tFlip = spikeMS { bench.setPeek(index: 1) }
        await settle(50)
        let tFlip2 = spikeMS { bench.setPeek(index: 2) }
        await settle(50)
        let tBack = spikeMS { bench.setPeek(index: 0) }
        let after = SpikeAttributeAudit.fingerprint(tv.textStorage)
        recorder.record(
            String(
                format: "4.peekFlips|flip1=%.2fms|flip2=%.2fms|back=%.2fms|storageUntouched=%@",
                tFlip, tFlip2, tBack, before == after ? "YES" : "NO"))
    }

    // MARK: - Item 6: keyboard avoidance + accessory bar

    func runKeyboard() async {
        recorder.record("6.begin|keyboard avoidance + accessory bar")
        let tv = bench.textView!
        bench.scenarioContainer.isHidden = true
        let insetBefore = tv.contentInset
        tv.selectedRange = NSRange(location: tv.textStorage.length - 2, length: 0)
        let became = tv.becomeFirstResponder()
        await settle(700)
        let kbFrame = bench.lastKeyboardFrame
        let guide = bench.view.keyboardLayoutGuide.layoutFrame
        let insetAfter = tv.contentInset
        let accessoryInWindow = tv.inputAccessoryView?.window != nil
        var caretVisible = "unknown"
        if let sel = tv.selectedTextRange {
            let caret = tv.caretRect(for: sel.end)
            let caretInView = CGRect(
                x: caret.origin.x, y: caret.origin.y - tv.contentOffset.y,
                width: caret.width, height: caret.height)
            let obscuredTop = kbFrame.isNull
                ? tv.bounds.height
                : bench.view.convert(kbFrame, from: nil).minY
                    - tv.convert(CGPoint.zero, to: bench.view).y
            caretVisible = caretInView.maxY <= obscuredTop + 1 ? "YES" : "NO(caret under keyboard)"
        }
        recorder.record(
            "6.show|becameFirstResponder=\(became)|events=\(bench.keyboardEvents.joined(separator: ","))"
        )
        recorder.record(
            String(
                format: "6.frames|keyboard=%@|layoutGuide=%@|accessoryBarInWindow=%@",
                NSCoder.string(for: kbFrame), NSCoder.string(for: guide),
                accessoryInWindow ? "YES" : "NO"))
        recorder.record(
            String(
                format: "6.avoidance|contentInsetBottomBefore=%.1f|after=%.1f|autoAdjusted=%@|caretVisible=%@",
                insetBefore.bottom, insetAfter.bottom,
                insetAfter.bottom != insetBefore.bottom ? "YES" : "NO", caretVisible))
        _ = tv.resignFirstResponder()
        await settle(400)
        recorder.record("6.hide|events=\(bench.keyboardEvents.joined(separator: ","))")
    }

    // MARK: - The full auto-run

    func runAll() async {
        recorder.reset()
        recorder.stampEnvironment()
        await runFallbackInventory()
        await runScale(words: 50_000)
        await runJumps()
        await runTyping()
        await runEnsureLayoutReference(words: 50_000)
        await runAttributeSurvival()
        await runGestureGeometry()
        await runKeyboard()
        // 200k flatness checks (P1's document-size axis).
        await runScale(words: 200_000)
        await runTyping(words: 200_000)
        await runJumps(words: 200_000, fractions: [0.5], reps: 3)
        await runEnsureLayoutReference(words: 200_000)
        recorder.record("DONE")
    }
}

#endif
