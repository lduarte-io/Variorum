// TK2Spike — the measurement scenarios, Steps 2–5 of the Phase 6 plan (throwaway).

import AppKit

final class Runner {
    let corpus: Corpus.Built
    let rec = Recorder.shared
    let canary = FallbackCanary.shared

    init(corpus: Corpus.Built) {
        self.corpus = corpus
    }

    // MARK: - Shared helpers

    /// Run `body` with the canary attributed to `label`; returns the number of canary
    /// events the action produced (also recorded if nonzero).
    @discardableResult
    func withAction(_ section: String, _ label: String, _ body: () -> Void) -> Int {
        let before = canary.eventCount
        canary.currentAction = label
        body()
        canary.currentAction = "idle"
        let delta = canary.eventCount - before
        if delta > 0 {
            rec2(section, "CANARY '\(label)'", "\(delta) events", note: "TK2->TK1 fallback trigger!")
        }
        return delta
    }

    private func rec2(_ section: String, _ probe: String, _ value: String, _ unit: String = "", note: String = "") {
        Recorder.shared.rec(section, probe, value, unit, note: note)
    }

    /// One keystroke burst through the NSTextInputClient path, timed per keystroke
    /// (insert + viewport layout).
    func typeBurst(_ h: Harness, count: Int) -> [Double] {
        var times: [Double] = []
        times.reserveCapacity(count)
        for i in 0..<count {
            let ch = (i % 8 == 7) ? " " : "x"
            let t0 = nowMS()
            h.textView.insertText(ch, replacementRange: NSRange(location: NSNotFound, length: 0))
            h.layoutViewport()
            times.append(nowMS() - t0)
            if i % 10 == 9 { h.pump(0.005) }
        }
        return times
    }

    func placeCaret(_ h: Harness, at offset: Int) -> Double {
        h.textView.setSelectedRange(NSRange(location: offset, length: 0))
        let t0 = nowMS()
        h.textView.scrollRangeToVisible(NSRange(location: offset, length: 0))
        h.settle(timeout: 0.6)
        return nowMS() - t0
    }

    /// Strategy C — the stored-estimate-compatible jump: scroll to a proportional
    /// estimate, then ensureLayout on JUST the target fragment (bounded work) and
    /// correct the scroll offset until the target block sits at the viewport top.
    struct HybridResult {
        let ms: Double          // landing time (estimate + corrections), pre-settle
        let iterations: Int
        let jumpPx: Double      // total correction applied (the would-be visual jump)
        let pxErr: Double       // target minY - clipTop at landing
        let paraErr: Int        // top block index - target block index at landing
        let postSettlePx: Double  // pxErr re-measured after a 0.5s settle (stability)
        let capped: Bool
    }

    func hybridJump(corpus c: Corpus.Built, fraction: Double, title: String) -> HybridResult {
        let targetOffset = Int(fraction * Double(c.charCount))
        let targetPara = c.paragraphIndex(forOffset: targetOffset)
        let targetStart = c.paragraphStarts[targetPara]
        let h = Harness(corpus: c.attributed, title: title)
        defer { h.close() }
        h.settle(timeout: 0.5)
        let estY = CGFloat(Double(targetStart) / Double(c.charCount)) * h.docHeight
        let t0 = nowMS()
        h.scrollTo(y: estY)
        var iterations = 0
        var jump = 0.0
        var finalPx = Double.nan
        var capped = false
        while true {
            guard let frag = h.firstFragment(fromOffset: targetStart, ensuringLayout: true) else { break }
            let dy = Double(frag.layoutFragmentFrame.minY - h.clipTop)
            finalPx = dy
            if abs(dy) < 1 { break }
            if iterations >= 6 { capped = true; break }
            jump += abs(dy)
            h.scrollTo(y: frag.layoutFragmentFrame.minY)
            iterations += 1
        }
        let ms = nowMS() - t0
        let topPara = c.paragraphIndex(forOffset: h.offsetAtViewportTop() ?? 0)
        h.settle(timeout: 0.5)
        var postPx = Double.nan
        if let frag = h.firstFragment(fromOffset: targetStart, ensuringLayout: true) {
            postPx = Double(frag.layoutFragmentFrame.minY - h.clipTop)
        }
        return HybridResult(ms: ms, iterations: iterations, jumpPx: jump, pxErr: finalPx,
                            paraErr: topPara - targetPara, postSettlePx: postPx, capped: capped)
    }

    // MARK: - Scenario: load (Step 1 verification)

    func runLoad() {
        let S = "1.load"
        rec2(S, "corpus.words", "\(corpus.wordCount)")
        rec2(S, "corpus.paragraphs(blocks)", "\(corpus.paragraphCount)")
        rec2(S, "corpus.utf16Chars", "\(corpus.charCount)")
        rec2(S, "corpus.buildTime", fmt(corpus.buildMS), "ms")

        let h = Harness(corpus: corpus.attributed, title: "load")
        defer { h.close() }
        rec2(S, "setAttributedString(50k words + blockID attrs)", fmt(h.loadMS), "ms")

        let t0 = nowMS()
        var firstLayoutMS: Double = -1
        while nowMS() - t0 < 2_000 {
            h.pump(0.01)
            if h.viewport.viewportRange != nil { firstLayoutMS = nowMS() - t0; break }
        }
        rec2(S, "timeToFirstViewportLayout", fmt(firstLayoutMS), "ms")
        rec2(S, "initialUsageHeightEstimate", fmt(Double(h.usageHeight)), "px")
        rec2(S, "initialDocViewHeight", fmt(Double(h.docHeight)), "px")

        let settle = h.settle(timeout: 3.0)
        rec2(S, "settleAtRest", "\(fmt(settle.ms)) ms, \(settle.revisions) revisions",
             note: "usage=\(fmt(Double(settle.finalUsage)))px doc=\(fmt(Double(settle.finalDoc)))px")
        rec2(S, "tk2Alive", "\(h.tk2Alive)")
        rec2(S, "canaryEventsAtRest", "\(canary.eventCount)")
    }

    // MARK: - Scenario: fallback triggers (Step 2, Fact A)

    func runFallback() {
        let S = "2.fallback"
        let h = Harness(corpus: corpus.attributed, title: "fallback triggers")
        defer { h.close() }
        h.settle(timeout: 1.0)
        var exercised: [String] = []
        let ts = h.textView.textContentStorage!.textStorage!

        func check(_ label: String, _ body: () -> Void) {
            withAction(S, label, body)
            exercised.append(label)
            if !h.tk2Alive {
                rec2(S, "TK2 DEAD after", label, note: "textLayoutManager == nil")
            }
        }

        // 1. Typing at several positions.
        for (name, off) in [("start", corpus.paragraphStarts[1] + 10),
                            ("middle", corpus.charCount / 2),
                            ("end", corpus.charCount - 2)] {
            check("typing@\(name)") {
                _ = self.placeCaret(h, at: off)
                _ = self.typeBurst(h, count: 30)
            }
        }

        // 2. textStorage attribute add/remove (visible + offscreen paragraphs).
        let topPara = corpus.paragraphIndex(forOffset: h.offsetAtViewportTop() ?? 0)
        let attrParas = [topPara, min(topPara + 1, corpus.paragraphCount - 1),
                         corpus.paragraphCount / 2, corpus.paragraphCount - 3]
        check("attributeUpdate.textStorage") {
            for p in attrParas {
                let start = self.corpus.paragraphStarts[p]
                let end = p + 1 < self.corpus.paragraphCount
                    ? self.corpus.paragraphStarts[p + 1] - 1 : self.corpus.charCount
                let range = NSRange(location: start, length: end - start)
                ts.beginEditing()
                ts.addAttribute(.backgroundColor, value: NSColor.systemYellow.withAlphaComponent(0.3), range: range)
                ts.endEditing()
                h.pump(0.02)
                ts.beginEditing()
                ts.removeAttribute(.backgroundColor, range: range)
                ts.endEditing()
                h.pump(0.02)
            }
        }

        // 3. Rendering attributes on visible ranges (the §3 fragile path).
        check("attributeUpdate.rendering") {
            let base = h.offsetAtViewportTop() ?? 0
            for i in 0..<3 {
                guard let range = h.textRange(offset: base + i * 120, length: 80) else { continue }
                h.tlm.setRenderingAttributes([.foregroundColor: NSColor.systemRed], for: range)
                h.pump(0.02)
                h.tlm.invalidateRenderingAttributes(for: range)
                h.pump(0.02)
            }
        }

        // 4. Selection sweep across the whole document (timed — far selections may force layout).
        var sweepTimes: [Double] = []
        check("selectionSweep") {
            for i in 0...10 {
                let off = min(self.corpus.charCount - 500, i * self.corpus.charCount / 10)
                let t0 = nowMS()
                h.textView.setSelectedRange(NSRange(location: off, length: 400))
                sweepTimes.append(nowMS() - t0)
                h.pump(0.01)
            }
            h.textView.setSelectedRange(NSRange(location: 0, length: 0))
        }
        rec2(S, "selectionSweep.setSelectedRange", stats(sweepTimes), "ms")

        // 5. Find bar show/hide.
        check("find.showHideFindBar") {
            h.textView.usesFindBar = true
            let show = NSMenuItem()
            show.tag = NSTextFinder.Action.showFindInterface.rawValue
            h.textView.performTextFinderAction(show)
            h.pump(0.2)
            let hide = NSMenuItem()
            hide.tag = NSTextFinder.Action.hideFindInterface.rawValue
            h.textView.performTextFinderAction(hide)
            h.pump(0.1)
        }

        // 6. Continuous spell checking toggled on, misspellings typed, toggled off.
        check("spellcheck.toggleAndType") {
            h.textView.isContinuousSpellCheckingEnabled = true
            _ = self.placeCaret(h, at: self.corpus.charCount - 2)
            h.textView.insertText(" xqzt wrbl mnpo", replacementRange: NSRange(location: NSNotFound, length: 0))
            h.pump(0.8)
            h.textView.isContinuousSpellCheckingEnabled = false
        }

        // 7. Large paste mid-document (attributed, blockID-carrying).
        let chunk = Corpus.build(seed: 0xFACE_FEED, targetWords: 2_000)
        check("paste.2kWords@middle") {
            _ = self.placeCaret(h, at: self.corpus.charCount / 2)
            let t0 = nowMS()
            h.textView.insertText(chunk.attributed, replacementRange: NSRange(location: NSNotFound, length: 0))
            self.rec2(S, "paste.2kWords.insertText", fmt(nowMS() - t0), "ms")
            h.settle(timeout: 1.0)
        }

        // 8. Undo of the paste + typing.
        check("undo.x3") {
            for _ in 0..<3 { h.textView.undoManager?.undo(); h.pump(0.05) }
        }

        rec2(S, "exercisedActions", exercised.joined(separator: ", "))
        rec2(S, "canaryEventsTotal", "\(canary.eventCount)",
             note: canary.eventCount == 0 ? "no fallback observed under any exercised action" : "SEE EVENTS")
        rec2(S, "tk2AliveAtEnd", "\(h.tk2Alive)")
        rec2(S, "notExercised", "lists/NSTextList, WritingTools tables, custom caret drawing",
             note: "out of product scope; absence of evidence scoped to actions above")
    }

    // MARK: - Scenario: height estimation & scroll stability (Step 3, Fact B)

    func runHeight() {
        let S = "3.height"

        // 3a. Step-scroll to the end, sampling the estimate the whole way.
        let h = Harness(corpus: corpus.attributed, title: "height drift")
        h.settle(timeout: 1.0)
        let initialUsage = h.usageHeight
        rec2(S, "estimateAfterLoadSettle", fmt(Double(initialUsage)), "px")

        var revisions = 0
        var maxDelta: CGFloat = 0
        var steps = 0
        var lastUsage = initialUsage
        var stuck = 0
        var backwardSteps = 0
        var lastTopOffset = -1
        let t0 = nowMS()
        while steps < 3_000 {
            let before = h.clipTop
            h.scrollTo(y: before + h.viewportHeight)
            h.pump(0.012)
            h.layoutViewport()
            steps += 1
            let u = h.usageHeight
            if abs(u - lastUsage) > 0.5 {
                revisions += 1
                maxDelta = max(maxDelta, abs(u - lastUsage))
                lastUsage = u
            }
            if let top = h.offsetAtViewportTop() {
                if top < lastTopOffset { backwardSteps += 1 }  // content moved BACKWARD past the viewport
                lastTopOffset = max(lastTopOffset, top)
            }
            if abs(h.clipTop - before) < 0.5 { stuck += 1; if stuck >= 2 { break } } else { stuck = 0 }
        }
        let scrollMS = nowMS() - t0
        rec2(S, "stepScrollToEnd", "\(steps) viewport steps in \(fmt(scrollMS)) ms")
        rec2(S, "estimateRevisionsWhileScrolling", "\(revisions)",
             note: "maxSingleDelta=\(fmt(Double(maxDelta)))px")
        rec2(S, "contentMovedBackwardSteps", "\(backwardSteps)",
             note: "steps where the top block regressed vs a prior step (visual jump proxy)")
        rec2(S, "settledHeightAfterFullScroll", fmt(Double(h.usageHeight)), "px",
             note: "drift from initial estimate: \(fmt(Double(h.usageHeight - initialUsage)))px (\(fmt(100 * Double(h.usageHeight - initialUsage) / Double(initialUsage), 1))%)")

        // Scroll-to-end correctness after the incremental walk.
        if let frag = h.firstFragment(fromOffset: corpus.charCount - 1, ensuringLayout: false) {
            let f = frag.layoutFragmentFrame
            let visible = f.maxY > h.clipTop && f.minY < h.clipTop + h.viewportHeight
            rec2(S, "lastLineAfterIncrementalScroll", visible ? "VISIBLE" : "NOT VISIBLE",
                 note: "fragMaxY=\(fmt(Double(f.maxY))) docH=\(fmt(Double(h.docHeight))) clipTop=\(fmt(Double(h.clipTop)))")
        } else {
            rec2(S, "lastLineAfterIncrementalScroll", "NO LAYOUT FRAGMENT", note: "fail")
        }
        h.close()

        // 3b. Cold jump straight to the end (the §2 breakage report).
        let h2 = Harness(corpus: corpus.attributed, title: "cold scrollToEnd")
        h2.settle(timeout: 0.5)
        let t1 = nowMS()
        h2.textView.scrollToEndOfDocument(nil)
        let s2 = h2.settle(timeout: 2.0)
        rec2(S, "coldScrollToEndOfDocument", fmt(nowMS() - t1), "ms",
             note: "revisions during settle: \(s2.revisions)")
        let distanceFromEnd = h2.maxScroll - h2.clipTop
        rec2(S, "distanceFromTrueEndAfterSettle", fmt(Double(distanceFromEnd)), "px",
             note: "0 = still at end after estimates revised")
        if let frag = h2.firstFragment(fromOffset: corpus.charCount - 1, ensuringLayout: false) {
            let f = frag.layoutFragmentFrame
            let visible = f.maxY > h2.clipTop && f.minY < h2.clipTop + h2.viewportHeight
            rec2(S, "lastLineAfterColdJump", visible ? "VISIBLE" : "NOT VISIBLE",
                 note: "fragMaxY=\(fmt(Double(f.maxY))) clipTop=\(fmt(Double(h2.clipTop)))")
        } else {
            rec2(S, "lastLineAfterColdJump", "NO LAYOUT FRAGMENT", note: "fail")
        }
        h2.close()

        // 3c. Window-resize reflow mid-document.
        let h3 = Harness(corpus: corpus.attributed, title: "resize reflow")
        h3.settle(timeout: 0.5)
        h3.scrollTo(y: h3.maxScroll * 0.5)
        h3.settle(timeout: 1.0)
        let paraBefore = corpus.paragraphIndex(forOffset: h3.offsetAtViewportTop() ?? 0)
        let t2 = nowMS()
        h3.window.setContentSize(NSSize(width: 600, height: 600))
        let s3 = h3.settle(timeout: 3.0)
        rec2(S, "resize900to600.settle", "\(fmt(nowMS() - t2)) ms, \(s3.revisions) revisions",
             note: "usage=\(fmt(Double(h3.usageHeight)))px doc=\(fmt(Double(h3.docHeight)))px")
        rec2(S, "resize.usageVsDocMismatch", fmt(Double(h3.usageHeight - h3.docHeight)), "px",
             note: "large positive = potential crop (§3)")
        let paraAfter = corpus.paragraphIndex(forOffset: h3.offsetAtViewportTop() ?? 0)
        rec2(S, "resize.readingPositionDrift", "\(paraAfter - paraBefore) paragraphs",
             note: "top block before=\(paraBefore) after=\(paraAfter)")
        let t3 = nowMS()
        h3.window.setContentSize(NSSize(width: 900, height: 600))
        let s4 = h3.settle(timeout: 3.0)
        let paraBack = corpus.paragraphIndex(forOffset: h3.offsetAtViewportTop() ?? 0)
        rec2(S, "resize600to900.settle", "\(fmt(nowMS() - t3)) ms, \(s4.revisions) revisions",
             note: "top block now=\(paraBack) (started at \(paraBefore))")
        h3.close()
    }

    // MARK: - Scenario: scroll-to-arbitrary-location (Step 4, Fact C — the book-scrub question)

    func runScrub() {
        let S = "4.scrub"
        let fractions: [Double] = [0.10, 0.25, 0.50, 0.75, 0.90]
        let reps = 3

        struct Sample {
            var ms: Double
            var paraErr: Int
            var pxErr: Double
        }
        var aggA: [Sample] = [], aggD: [Sample] = []
        var aggC: [HybridResult] = []

        for fraction in fractions {
            let targetOffset = Int(fraction * Double(corpus.charCount))
            let targetPara = corpus.paragraphIndex(forOffset: targetOffset)
            let targetStart = corpus.paragraphStarts[targetPara]

            var a: [Sample] = [], d: [Sample] = []
            var c: [HybridResult] = []
            var bNotes: [String] = []

            for _ in 0..<reps {
                // Strategy A — naive proportional scroll on a cold view.
                autoreleasepool {
                    let h = Harness(corpus: corpus.attributed, title: "A \(Int(fraction * 100))%")
                    h.settle(timeout: 0.5)
                    let estY = CGFloat(Double(targetStart) / Double(corpus.charCount)) * h.docHeight
                    let t0 = nowMS()
                    h.scrollTo(y: estY)
                    h.settle(timeout: 1.0)
                    let ms = nowMS() - t0
                    let topPara = corpus.paragraphIndex(forOffset: h.offsetAtViewportTop() ?? 0)
                    var pxErr = Double.nan
                    if let frag = h.firstFragment(fromOffset: targetStart, ensuringLayout: true) {
                        pxErr = Double(frag.layoutFragmentFrame.minY - h.clipTop)
                    }
                    a.append(Sample(ms: ms, paraErr: topPara - targetPara, pxErr: pxErr))
                    h.close()
                }

                // Strategy B — relocateViewport(to:) (undocumented for this use; experiment).
                autoreleasepool {
                    let h = Harness(corpus: corpus.attributed, title: "B \(Int(fraction * 100))%")
                    h.settle(timeout: 0.5)
                    guard let loc = h.location(atOffset: targetStart) else { return }
                    let clipBefore = h.clipTop
                    let t0 = nowMS()
                    h.viewport.relocateViewport(to: loc)
                    let callMS = nowMS() - t0
                    let vpImmediate = h.viewport.viewportRange.map { corpus.paragraphIndex(forOffset: h.offset(of: $0.location)) }
                    let clipMoved = Double(h.clipTop - clipBefore)
                    h.pump(0.15)
                    h.layoutViewport()
                    let vpAfterPump = h.viewport.viewportRange.map { corpus.paragraphIndex(forOffset: h.offset(of: $0.location)) }
                    let topByPoint = h.offsetAtViewportTop().map { corpus.paragraphIndex(forOffset: $0) }
                    bNotes.append(
                        "call=\(fmt(callMS))ms vpTop(immediate)=\(vpImmediate.map(String.init) ?? "nil") "
                        + "vpTop(afterPump)=\(vpAfterPump.map(String.init) ?? "nil") "
                        + "clipMoved=\(fmt(clipMoved))px topByPoint=\(topByPoint.map(String.init) ?? "nil") "
                        + "target=\(targetPara)")
                    h.close()
                }

                // Strategy C — bounded hybrid: proportional estimate, then ensureLayout on
                // just the landing fragment and correct until the target sits at the top.
                autoreleasepool {
                    let r = hybridJump(corpus: corpus, fraction: fraction, title: "C \(Int(fraction * 100))%")
                    c.append(r)
                    if r.capped {
                        rec2(S, "C@\(Int(fraction * 100))% hit iteration cap", "6", note: "correction did not converge")
                    }
                }

                // Strategy D — what naive code does: scrollRangeToVisible.
                autoreleasepool {
                    let h = Harness(corpus: corpus.attributed, title: "D \(Int(fraction * 100))%")
                    h.settle(timeout: 0.5)
                    let t0 = nowMS()
                    h.textView.scrollRangeToVisible(NSRange(location: targetStart, length: 1))
                    h.settle(timeout: 1.0)
                    let ms = nowMS() - t0
                    var pxErr = Double.nan
                    var visible = false
                    if let frag = h.firstFragment(fromOffset: targetStart, ensuringLayout: true) {
                        let f = frag.layoutFragmentFrame
                        visible = f.maxY > h.clipTop && f.minY < h.clipTop + h.viewportHeight
                        pxErr = Double(f.minY - h.clipTop)
                    }
                    let topPara = corpus.paragraphIndex(forOffset: h.offsetAtViewportTop() ?? 0)
                    d.append(Sample(ms: ms, paraErr: visible ? 0 : topPara - targetPara, pxErr: pxErr))
                    h.close()
                }
            }

            func summarize(_ name: String, _ xs: [Sample]) {
                guard !xs.isEmpty else { return }
                let msStats = stats(xs.map { $0.ms })
                let paraErrs = xs.map { abs($0.paraErr) }
                let pxErrs = xs.filter { !$0.pxErr.isNaN }.map { abs($0.pxErr) }
                rec2(S, "\(name) @\(Int(fraction * 100))%",
                     "paraErr(max)=\(paraErrs.max() ?? -1) pxErr(max)=\(fmt(pxErrs.max() ?? .nan))",
                     note: "time: \(msStats)")
            }
            summarize("A-proportional", a)
            summarize("D-scrollRangeToVisible", d)
            rec2(S, "C-hybrid @\(Int(fraction * 100))%",
                 "paraErr(max)=\(c.map { abs($0.paraErr) }.max() ?? -1) pxErr(max)=\(fmt(c.map { abs($0.pxErr) }.max() ?? .nan)) postSettleDrift(max)=\(fmt(c.map { abs($0.postSettlePx) }.max() ?? .nan))",
                 note: "time: \(stats(c.map { $0.ms })); iters max=\(c.map { $0.iterations }.max() ?? 0); jump max=\(fmt(c.map { $0.jumpPx }.max() ?? 0))px")
            for (i, n) in bNotes.enumerated() {
                rec2(S, "B-relocateViewport @\(Int(fraction * 100))% rep\(i + 1)", n)
            }
            aggA += a; aggC += c; aggD += d
        }

        func overall(_ name: String, _ xs: [Sample]) {
            guard !xs.isEmpty else { return }
            rec2(S, "\(name) OVERALL",
                 "paraErr max=\(xs.map { abs($0.paraErr) }.max()!) avg=\(fmt(Double(xs.map { abs($0.paraErr) }.reduce(0, +)) / Double(xs.count), 1))",
                 note: "time: \(stats(xs.map { $0.ms })) ms; pxErr max=\(fmt(xs.filter { !$0.pxErr.isNaN }.map { abs($0.pxErr) }.max() ?? .nan))")
        }
        overall("A-proportional", aggA)
        overall("D-scrollRangeToVisible", aggD)
        rec2(S, "C-hybrid OVERALL",
             "paraErr max=\(aggC.map { abs($0.paraErr) }.max() ?? -1) pxErr max=\(fmt(aggC.map { abs($0.pxErr) }.max() ?? .nan)) postSettleDrift max=\(fmt(aggC.map { abs($0.postSettlePx) }.max() ?? .nan))",
             note: "time: \(stats(aggC.map { $0.ms })) ms; iters max=\(aggC.map { $0.iterations }.max() ?? 0); jump max=\(fmt(aggC.map { $0.jumpPx }.max() ?? 0))px; capped=\(aggC.filter { $0.capped }.count)")
    }

    // MARK: - Scenario: typing latency at scale (Step 5, Fact D)

    func runTyping() {
        let S = "5.typing"
        let h = Harness(corpus: corpus.attributed, title: "typing latency")
        defer { h.close() }
        h.settle(timeout: 1.0)

        func positions(_ length: Int) -> [(String, Int)] {
            [("start", corpus.paragraphStarts[1] + 10), ("middle", length / 2), ("end", length - 2)]
        }

        let len0 = h.textView.textContentStorage!.textStorage!.length
        for (name, off) in positions(len0) {
            let scrollMS = placeCaret(h, at: off)
            rec2(S, "caretPlacement@\(name) (scrollRangeToVisible+settle)", fmt(scrollMS), "ms")
            let times = typeBurst(h, count: 120)
            rec2(S, "keystroke@\(name)", stats(times), "ms")
        }

        // Large paste mid-document, then re-measure.
        let chunk = Corpus.build(seed: 0xBEEF_CAFE, targetWords: 5_000)
        let lenBefore = h.textView.textContentStorage!.textStorage!.length
        _ = placeCaret(h, at: lenBefore / 2)
        let t0 = nowMS()
        h.textView.insertText(chunk.attributed, replacementRange: NSRange(location: NSNotFound, length: 0))
        rec2(S, "paste.5kWords@middle.insertText", fmt(nowMS() - t0), "ms")
        let s = h.settle(timeout: 2.0)
        rec2(S, "paste.settle", "\(fmt(s.ms)) ms, \(s.revisions) revisions")

        let len1 = h.textView.textContentStorage!.textStorage!.length
        for (name, off) in positions(len1) {
            _ = placeCaret(h, at: off)
            let times = typeBurst(h, count: 120)
            rec2(S, "keystroke@\(name) post-paste (55k words)", stats(times), "ms")
        }
        rec2(S, "tk2AliveAtEnd", "\(h.tk2Alive)")
    }

    // MARK: - Scenario: 200k-word scale check (the P1 document-size axis)

    func runScale() {
        let S = "7.scale200k"
        let big = Corpus.build(seed: Corpus.defaultSeed &+ 0x5CA1E, targetWords: 200_000)
        rec2(S, "corpus", "\(big.wordCount) words, \(big.paragraphCount) blocks, \(big.charCount) utf16 chars")

        var results: [HybridResult] = []
        for _ in 0..<3 {
            autoreleasepool {
                results.append(hybridJump(corpus: big, fraction: 0.5, title: "scale C 50%"))
            }
        }
        rec2(S, "C-hybrid @50% (200k words)",
             "paraErr max=\(results.map { abs($0.paraErr) }.max() ?? -1) pxErr max=\(fmt(results.map { abs($0.pxErr) }.max() ?? .nan)) postSettleDrift max=\(fmt(results.map { abs($0.postSettlePx) }.max() ?? .nan))",
             note: "time: \(stats(results.map { $0.ms })); iters max=\(results.map { $0.iterations }.max() ?? 0); flat vs 50k = P1 pass")

        autoreleasepool {
            let h = Harness(corpus: big.attributed, title: "scale typing")
            h.settle(timeout: 1.0)
            _ = placeCaret(h, at: big.charCount / 2)
            let times = typeBurst(h, count: 120)
            rec2(S, "keystroke@middle (200k words)", stats(times), "ms")
            h.close()
        }

        autoreleasepool {
            let h = Harness(corpus: big.attributed, title: "scale ensureLayout")
            h.settle(timeout: 0.5)
            let t0 = nowMS()
            h.tlm.ensureLayout(for: h.contentManager.documentRange)
            rec2(S, "ensureLayout(documentRange) 200k", fmt(nowMS() - t0), "ms",
                 note: "grows with document size — the path P1 bans")
            rec2(S, "trueHeight 200k", fmt(Double(h.usageHeight)), "px")
            h.close()
        }
    }

    // MARK: - Scenario: full-document ensureLayout (the P1 fail-by-definition reference)

    func runEnsure() {
        let S = "6.fullEnsureLayout"
        let h = Harness(corpus: corpus.attributed, title: "ensureLayout(whole doc)")
        defer { h.close() }
        h.settle(timeout: 0.5)
        rec2(S, "estimateBeforeEnsure", fmt(Double(h.usageHeight)), "px")
        let t0 = nowMS()
        h.tlm.ensureLayout(for: h.contentManager.documentRange)
        let ms = nowMS() - t0
        rec2(S, "ensureLayout(documentRange)", fmt(ms), "ms",
             note: "the cost P1 bans from ever being on a user path")
        rec2(S, "trueHeightAfterEnsure", fmt(Double(h.usageHeight)), "px",
             note: "estimate error was \(fmt(Double(h.usageHeight) - Double(h.docHeight), 1))px vs docView; "
                 + "avg px/block=\(fmt(Double(h.usageHeight) / Double(corpus.paragraphCount), 1))")
    }
}
