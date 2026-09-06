//
//  TravellingDotsIndicator.swift
//  Variorum (shared: Mac + Mobile)
//
//  pre-13x batch 5b, item 1 (ledger 32) — THE ORIGINAL ANIMATED INDICATOR.
//  Design §15's words: "an ORIGINAL animated indicator with movement — her
//  example: a line with a few black dots travelling back and forth — never
//  the system spinner." This is the ceremonies' indicator: every protection
//  surface's busy state on both platforms (the posture switches, the key
//  doors, the follow, the lobby's phase line, the Turn On Sync ceremony,
//  the passphrase set, the migration confirm, the secret check, the
//  missing-library screen). The REST of the app keeps its `ProgressView`s —
//  this is not an app-wide restyle. Pinned: no protection-surface file names
//  `ProgressView` (the grep pin), the brain below, and the view hosted alone.
//
//  THE SHAPE: a hairline, three dots travelling along it there and back
//  as one trail (the lead turns at each end, the two behind follow), driven
//  by `TimelineView(.animation)`. The ink is the CALLER's token — the
//  voice's `muted` / `ink`, or the shared page style's — never a literal
//  colour (the one-module rule for the design layer); the line is the same
//  ink at a lower opacity. Reduce Motion ⇒ the dots REST, evenly spaced,
//  and the timeline is paused. The accessibility label is *Working…*.
//

import SwiftUI

struct TravellingDotsIndicator: View {
    /// The ink for the dots and the line — the caller's token.
    var ink: Color = .secondary
    var width: CGFloat = 44
    var dotDiameter: CGFloat = 5

    /// One full trip — there and back — in seconds.
    nonisolated static let period: Double = 1.6
    nonisolated static let dotCount = 3
    /// How far each trailing dot runs behind the one ahead of it, as a
    /// fraction of the trip.
    nonisolated static let trail: Double = 0.09
    /// The spoken label (chrome — listed in copy §11 for 13s).
    nonisolated static let accessibilityLabel = "Working…"

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The shared account/encryption pages' seam: the page style's muted
    /// ink where one is injected (the phone), `.secondary` where none is
    /// (the Mac — the exact pre-5b construction of those pages' captions).
    init(pageStyle: SharedPageStyle?) {
        self.init(ink: pageStyle?.tokens.muted ?? .secondary)
    }

    init(ink: Color = .secondary, width: CGFloat = 44, dotDiameter: CGFloat = 5) {
        self.ink = ink
        self.width = width
        self.dotDiameter = dotDiameter
    }

    var body: some View {
        SwiftUI.TimelineView(.animation(paused: reduceMotion)) { context in
            let phase = reduceMotion
                ? 0
                : context.date.timeIntervalSinceReferenceDate
                    .truncatingRemainder(dividingBy: Self.period) / Self.period
            let positions = Self.dotPositions(phase: phase, reduceMotion: reduceMotion, count: Self.dotCount)
            Canvas { canvas, size in
                let midY = size.height / 2
                var line = Path()
                line.move(to: CGPoint(x: 0, y: midY))
                line.addLine(to: CGPoint(x: size.width, y: midY))
                canvas.stroke(line, with: .color(ink.opacity(0.35)), lineWidth: 1)
                let travel = max(size.width - dotDiameter, 0)
                for position in positions {
                    let rect = CGRect(
                        x: position * travel, y: midY - dotDiameter / 2,
                        width: dotDiameter, height: dotDiameter)
                    canvas.fill(Path(ellipseIn: rect), with: .color(ink))
                }
            }
        }
        .frame(width: width, height: dotDiameter + 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(Self.accessibilityLabel))
        .accessibilityAddTraits(.updatesFrequently)
    }

    /// THE BRAIN (pure; the pin reads it): each dot's position along the
    /// line as a fraction 0…1. In motion, a triangle wave — 0 → 1 over the
    /// first half of the trip and back over the second — with each trailing
    /// dot a fixed fraction behind the one ahead, so the three read as one
    /// trail turning at each end. Under Reduce Motion the dots rest evenly
    /// spaced, whatever the phase.
    nonisolated static func dotPositions(phase: Double, reduceMotion: Bool, count: Int) -> [Double] {
        guard count > 0 else { return [] }
        if reduceMotion {
            return (0..<count).map { Double($0 + 1) / Double(count + 1) }
        }
        return (0..<count).map { index in
            let shifted = (phase - Double(index) * trail).truncatingRemainder(dividingBy: 1)
            let wrapped = shifted < 0 ? shifted + 1 : shifted
            return wrapped < 0.5 ? wrapped * 2 : (1 - wrapped) * 2
        }
    }
}
