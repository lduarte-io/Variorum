//
//  BaselineProbe.swift
//  Variorum (Mac)
//
//  The Act 10 correction round, batch A (rows 10 + 11) — a DEBUG oracle for
//  TEXT BASELINES, so a pin can hold "these sit on one line" as a number
//  instead of an eye. Her report: *"the tags are also misaligned from the
//  text"* · *"the word book is misaligned"* — both baseline mismatches in
//  Library rows whose HStacks either did not align on the baseline at all
//  (the book row) or aligned on a baseline the chip did not actually carry
//  (a symbol image's bottom edge standing in for the chip text's baseline).
//
//  How it reads a baseline: SwiftUI hands a view's `firstTextBaseline`
//  offset to an `alignmentGuide` closure whenever the PARENT aligns on that
//  guide — so a probed text inside a `.firstTextBaseline` stack reports its
//  offset every layout — and `onGeometryChange` reports the same view's
//  top in a named space. Their sum is the baseline's absolute y in that
//  space; two probed texts on one line agree to within a point. A
//  no-op outside DEBUG: the modifier returns its content untouched.
//

import SwiftUI

#if DEBUG
/// Where each probed text's baseline sits, by probe id, in the probe's
/// named coordinate space (`space`).
@MainActor
enum BaselineProbe {
    static var offsets: [String: CGFloat] = [:]
    static var tops: [String: CGFloat] = [:]

    /// The absolute baseline y for a probe id — nil until both halves have
    /// reported.
    static func baseline(_ id: String) -> CGFloat? {
        guard let top = tops[id], let offset = offsets[id] else { return nil }
        return top + offset
    }

    static func reset() {
        offsets = [:]
        tops = [:]
    }
}
#endif

extension View {
    /// Probe this text's first baseline under `id`, measured in the named
    /// coordinate space `space` (the enclosing row declares it).
    @ViewBuilder
    func baselineProbe(_ id: String?, in space: String) -> some View {
        #if DEBUG
        if let id {
            self
                .alignmentGuide(.firstTextBaseline) { d in
                    let offset = d[.firstTextBaseline]
                    // Layout runs on the main thread; the closure is merely
                    // not DECLARED isolated.
                    MainActor.assumeIsolated { BaselineProbe.offsets[id] = offset }
                    return offset
                }
                .onGeometryChange(for: CGFloat.self) {
                    $0.frame(in: .named(space)).minY
                } action: { BaselineProbe.tops[id] = $0 }
        } else {
            self
        }
        #else
        self
        #endif
    }
}
