//
//  ArrivalFlash.swift
//  Variorum (Mac) — Surface (beside `ComfortBand`, its sibling half of the
//  18l-c U8 design)
//
//  **18l-c UNIT U8 (a) — THE ARRIVAL FLASH.** Her words at the 18l-c
//  kickoff, verbatim: *"sometimes clicking between modes because where you're
//  at on the screen changes, it might be nice if we showed a temporary
//  highlight (like the index highlight) on the line your cursor is on after the
//  transition. lasting a brief instant. not sure what UX standards are on brief
//  indicators that are supposed to fade. you should also be able to turn this
//  flash where your cursor is setting off, but it should default to on."*
//
//  **The UX standard she asked about** (the roster's answer): the platform's
//  "here is your place" indicators — `NSTextFinder`'s found-match flash, the
//  find bar's pulse — emphasize, then fade, in about a second. So: HOLD ≈ 0.3 s
//  at full strength, then an OPACITY-ONLY fade over ≈ 0.8 s, no motion. The two
//  numbers are the NAMED CONSTANTS below — taste is one line each.
//
//  **Its face is existing vocabulary, never a new colour system:** the block
//  highlight's own face — the voice's `wash` fill with the `accent` border
//  (Write's `renderSelection`, the "picked block" band) — drawn as an overlay:
//  a decor-layer rect below Write's text over the caret's LINE, a SwiftUI
//  overlay on the Takes article's landed block and on note Read's landed row.
//  The border is what keeps it legible on a surface that is ALREADY washed
//  (Read ▸ edit's selected row wears the wash permanently — her "index
//  highlight" — and an opaque wash over itself shows nothing), exactly the
//  reason the block highlight carries one beside the editing indicator.
//
//  **When it fires is the callers' — a MODE SWITCH's entry landing, once it
//  has arrived** (Write: its bare mode-switch arrival's settle hop; the Takes
//  article: the ENTRY landing's first sighting of its row at home; note Read:
//  its mode-switch seed). A find step, a click, a bloom and a note-open never
//  flash (U7's decision 9 — find-nav is in-mode navigation).
//
//  **Reduce Motion** (System Settings ▸ Accessibility ▸ Display): the
//  DISCREET, NON-ANIMATED variant — the highlight shows at once, unanimated,
//  for the same total, and then goes. The fade is opacity-only already (the
//  HIG's own substitute for motion), but a user who asked the system to reduce
//  motion is asking for fewer things that change on their own, so nothing
//  animates. JUDGMENT CALL, recorded — "no flash at all" is one line
//  (`plan(reduceMotion:)`).
//
//  Pure: no view, no clock read, no store — elapsed time is handed in, so the
//  whole curve is pinnable (`ArrivalFlashTests`).
//

import CoreGraphics
import Foundation
import SwiftUI

nonisolated enum ArrivalFlash {
    /// **THE NAMED CONSTANT — how long the highlight holds at full strength**
    /// before it starts to fade (the roster's ≈ 0.3 s).
    static let holdSeconds: TimeInterval = 0.3
    /// **THE NAMED CONSTANT — how long the opacity-only fade takes** (the
    /// roster's ≈ 0.7–0.9 s; the middle of it).
    static let fadeSeconds: TimeInterval = 0.8

    /// One flash's timing, decided once from the system's Reduce Motion.
    struct Plan: Equatable, Sendable {
        let hold: TimeInterval
        let fade: TimeInterval
        /// false under Reduce Motion: no fade — full strength for `total`, then gone.
        let animated: Bool

        /// How long the flash is on screen at all.
        var total: TimeInterval { hold + fade }

        /// **THE CURVE, pure** — the highlight's opacity `elapsed` seconds
        /// after it began: 1 through the hold, then a smooth (cosine, ease-in-
        /// out) fall to 0 across the fade; 0 before it began and from `total`
        /// on. Unanimated (Reduce Motion): 1 until `total`, then 0.
        func opacity(at elapsed: TimeInterval) -> Double {
            guard elapsed >= 0, elapsed < total else { return 0 }
            guard animated, fade > 0, elapsed > hold else { return 1 }
            let t = min(max((elapsed - hold) / fade, 0), 1)
            return 0.5 * (1 + cos(Double.pi * t))
        }

        /// The fade's Core Animation timing (Write's decor layer): the same
        /// ease-in-out the cosine above draws, over `fade`, starting after
        /// `hold` — `CAMediaTimingFunctionName.easeInEaseOut` is the platform's
        /// name for that shape.
        var fadeBegins: TimeInterval { hold }
    }

    /// The plan for this Mac right now.
    static func plan(reduceMotion: Bool) -> Plan {
        Plan(hold: holdSeconds, fade: fadeSeconds, animated: !reduceMotion)
    }
}

// MARK: - The SwiftUI face (the Takes article's landed block, note Read's rows)

/// **The flash's SwiftUI face** — the block highlight's own vocabulary (the
/// voice's `wash`, the `accent` border) sampled from the pure curve on every
/// frame while it runs, so a row realized mid-flash shows exactly the strength
/// the flash has reached. TWO parts, because a fill must sit BEHIND the text
/// (a surface's wash can be opaque — Terminal's is — and a fill over prose
/// would hide it) while the border is drawn on the row's edge, OVER the room
/// around the text: the host places `.fill` in a background and `.stroke` in an
/// overlay. Mounted by its host only while its one-shot arrival state is set
/// (the host clears it after the plan's `total`), so nothing ticks at rest.
struct ArrivalFlashFace: View {
    enum Part { case fill, stroke }

    let part: Part
    let startedAt: Date
    let plan: ArrivalFlash.Plan
    let tokens: VoiceTokens
    var cornerRadius: CGFloat = 6
    /// DEBUG oracle key (`ArrivalFlashOracle`) — which face this is.
    var oracleKey: String = ""

    var body: some View {
        // Unanimated (Reduce Motion): one frame at the start and one at the
        // end — nothing ticks in between.
        SwiftUI.TimelineView(.animation(minimumInterval: plan.animated ? nil : plan.total)) { context in
            let opacity = plan.opacity(at: context.date.timeIntervalSince(startedAt))
            shape
                .opacity(opacity)
                #if DEBUG
                .onAppear { ArrivalFlashOracle.note(oracleKey, part: part, opacity: opacity) }
                .onChange(of: opacity) { _, new in ArrivalFlashOracle.note(oracleKey, part: part, opacity: new) }
                #endif
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    @ViewBuilder private var shape: some View {
        switch part {
        case .fill:
            RoundedRectangle(cornerRadius: cornerRadius).fill(tokens.wash)
        case .stroke:
            RoundedRectangle(cornerRadius: cornerRadius).strokeBorder(tokens.accent, lineWidth: 1.5)
        }
    }
}

#if DEBUG
/// **What the flash faces DREW, per face key** (DEBUG — the pins' read and the
/// walk probe's): the strongest opacity each face part has shown since the
/// last reset, and how many times it was drawn. A face never mounted (the
/// setting off, a find step, a note-open) leaves no key.
@MainActor
enum ArrivalFlashOracle {
    struct Seen: Equatable {
        var peakFill: Double = 0
        var peakStroke: Double = 0
        var draws = 0
    }

    private(set) static var seen: [String: Seen] = [:]

    static func note(_ key: String, part: ArrivalFlashFace.Part, opacity: Double) {
        var entry = seen[key] ?? Seen()
        switch part {
        case .fill: entry.peakFill = max(entry.peakFill, opacity)
        case .stroke: entry.peakStroke = max(entry.peakStroke, opacity)
        }
        entry.draws += 1
        seen[key] = entry
    }

    static func reset() { seen = [:] }
}
#endif
