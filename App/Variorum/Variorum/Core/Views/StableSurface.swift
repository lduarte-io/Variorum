//
//  StableSurface.swift
//  Variorum (Mac) — Core/Views (the shared Mac-chrome home)
//
//  HOISTED from Features/BookView/BookView.swift at the Act 10 correction
//  round's batch H (the hoist-at-next-touch rule, CLAUDE.md): the book's
//  Read ▸ Scroll flow (`ReadingFlowView`) is the second consumer of the
//  row-53 shapes — `NearViewportObserver` (the near/far band with
//  hysteresis) and `StableSurface` (a text surface at its remembered size
//  from the first frame) — so they move to the shared home. The address
//  changed and the observer gained the NAME of its scroll's coordinate
//  space (it was bound to `BookView.outlineSpace`); not a byte of the
//  behavior — `StableSurfaceTests` and the book's landing pins ride
//  unmodified. `SurfaceSizeMemory` is new beside them: the flow's own
//  remembered sizes (the Outline's memory lives on `BookViewModel` at
//  Write's measure — a different width, never shared).
//

import SwiftUI

/// The last settled size of each surface, keyed by post — session view
/// state, never persisted, written at geometry cadence (a plain reference
/// box, so no observed property re-renders a whole page per report).
@MainActor
final class SurfaceSizeMemory {
    private var sizes: [String: CGSize] = [:]

    func size(_ key: String) -> CGSize? { sizes[key] }

    func remember(_ key: String, _ size: CGSize) { sizes[key] = size }
}

/// Row 53: whether a row sits within `margin` points of its scroll's
/// viewport — the Outline's, the reading flow's — its frame read in the
/// scroll's named `space`, where the viewport's top is 0. Only heavy rows
/// carry it (the Outline's expanded notes, the flow's stories) — a few
/// dozen observers at most, each a comparison per scroll tick, writing its
/// state only when the answer flips. With HYSTERESIS: a row becomes near within `margin` and
/// far again only beyond three times that — a row's own placeholder ↔
/// surface swap moves the column, and without the band that move flipped
/// its neighbours back and forth (traced on the dev store as `861 ↔ 221`
/// and `21054 ↔ 94` row heights).
struct NearViewportObserver: ViewModifier {
    @Binding var near: Bool
    let margin: CGFloat
    /// The scroll's named coordinate space — the viewport's top is 0 there
    /// (`BookView.outlineSpace`, `ReadingFlowView.flowSpace`).
    let space: String
    var farMargin: CGFloat { margin * 3 }

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGFloat.self) { geometry in
                // The row's distance from the viewport's top-edge region
                // (0 while any part of it overlaps [0, margin) — a viewport
                // is at most a couple of thousand points tall).
                let frame = geometry.frame(in: .named(space))
                if frame.maxY < 0 { return -frame.maxY }
                if frame.minY > margin { return frame.minY - margin }
                return 0
            } action: { distance in
                // Decided on the next turn: a geometry report can arrive
                // inside a layout pass, and a state write there is the
                // "modifying state during view update" class (it doubled
                // the mounted editor in the harness).
                let becomesNear = !near && distance < margin
                let becomesFar = near && distance > farMargin
                guard becomesNear || becomesFar else { return }
                DispatchQueue.main.async { near = becomesNear }
            }
    }
}

/// Below this a surface is a placeholder, never worth remembering.
private let stableSurfacePlaceholderCeiling: CGFloat = 60
/// One line of slack on "reached": the read-cheap and live surfaces of one
/// note differ by their insets.
private let stableSurfaceReachedSlack: CGFloat = 24
/// Ladder R1-1: how long a surface must hold ONE size before that size is
/// adopted as its memory and the reservation is dropped — the Outline
/// landing's own minimum hold (`BookView.landingMinimumHold`), so a
/// provisional-width first measure (row 54's class) or a placeholder
/// waiting on the encrypted store's read never decides.
nonisolated let stableSurfaceSettleInterval: TimeInterval = 1.0
/// Ladder R1-1: a remembered width within this of the surface's reported
/// width is "the same width" — a memory taken at another width does not
/// apply (the window resized, the sidebar collapsed, the voice switched
/// while the row was away).
/// `nonisolated` (ladder fix 2, R2-1): the flow's pure width brain
/// (`FlowHeightEstimate.remembered(_:appliesAt:)`) compares with the SAME
/// constant, so "the same width" is one number in the app.
nonisolated let stableSurfaceWidthTolerance: CGFloat = 1

/// Row 53 (the Act 10 correction round): an expanded note's text surface
/// at its REMEMBERED size from the first frame it is realized. The column
/// re-realizes an expanded story whenever it scrolls back into range; its
/// surface would come back at a placeholder height and grow in steps to
/// ~20,000 pt (a DB read, a first measure at a provisional width, the
/// final) — the layout churn under which no landing can take. With a
/// remembered size (`BookViewModel`), the row reserves that height until
/// the surface has reached it, and the column's layout is right from the
/// first frame.
///
/// **What the memory is (ladder R1-1 — the reservation is honest in BOTH
/// directions):** the surface's last SETTLED size. While a surface loads,
/// a read-cheap memory grows with it and a live editor's follows typing
/// both ways once loaded (`followsShrinks`); and whenever a surface holds
/// one size for `stableSurfaceSettleInterval` — taller OR shorter than the
/// memory — that size is adopted and the reservation is dropped, so a
/// memory that is TALLER than the surface's real height (text reflowed
/// shorter while the row was away) can never hold a permanent gap under
/// the story. A memory taken at ANOTHER width (`stableSurfaceWidthTolerance`)
/// does not apply and reserves nothing from the surface's first real
/// report — the stored `CGSize`'s width is compared, not merely carried.
/// Before R1-1 the read-cheap memory only ever grew and `loaded` flipped
/// only when the surface REACHED the memory, so a stale taller memory
/// reserved a blank gap for the session (the reviewer's trace). Identity
/// per surface kind (the caller's `.id`), so a note demoted from live to
/// read-cheap starts a fresh reservation from the same memory. Internal
/// (not private) so the pin can mount it alone. Since ladder fix 2 (R2-2)
/// the surface also ANNOUNCES its settle (`settled`) — the flow's landing
/// waits on that, never on a clock.
struct StableSurface<Content: View>: View {
    let known: CGSize?
    let followsShrinks: Bool
    /// How long the surface must hold one size before it is adopted
    /// (batch H: a parameter — the Outline's TK2 surfaces keep the 1 s
    /// default that guards a provisional-width first measure; the reading
    /// flow's `Text` column lays out whole in one pass and settles faster).
    var settleInterval: TimeInterval = stableSurfaceSettleInterval
    /// Ladder fix 2 (R2-2): the surface SAYS when it has settled — it held
    /// ONE real size for `settleInterval`, adopted it and dropped its
    /// reservation — so a landing that must wait for the rows above its
    /// target can wait on the surfaces' own geometry instead of guessing
    /// from a wall clock (the flow's finisher read "loaded + a margin" and
    /// the margin lost to a long layout pass). Fired synchronously in the
    /// settle closure, after `loaded` flips; a listener re-arming its own
    /// quiet interval on it therefore never decides in the same turn as
    /// the reservation's drop. nil = nobody listening (the Outline).
    var settled: (() -> Void)? = nil
    let remember: (CGSize) -> Void
    @ViewBuilder let content: () -> Content
    /// The surface has reached (or settled at) a size: the reservation is
    /// off and the memory follows the surface.
    @State private var loaded = false
    /// R1-1: the width the surface last reported above the placeholder
    /// ceiling — the reservation applies only while it matches the memory's.
    @State private var reportedWidth: CGFloat?
    /// R1-1: the settle bookkeeping, in a reference box — no `@State` write
    /// per geometry report (the landing's own lesson).
    @State private var settle = SettleBox()

    final class SettleBox {
        var lastSize: CGSize?
        var generation = 0
    }

    var body: some View {
        content()
            .onGeometryChange(for: CGSize.self) { $0.size } action: { size in
                report(size)
            }
            .frame(minHeight: reserved, alignment: .top)
    }

    private func report(_ size: CGSize) {
        if !loaded {
            let reached = known.map { size.height >= $0.height - stableSurfaceReachedSlack } ?? true
            // Flipped on the next turn, never inside the layout pass that
            // reported (the state-during-update class).
            if reached { DispatchQueue.main.async { loaded = true } }
        }
        guard size.height > stableSurfacePlaceholderCeiling, size.width > 0 else { return }
        if reportedWidth != size.width {
            DispatchQueue.main.async { reportedWidth = size.width }
        }
        if loaded && followsShrinks {
            remember(size)
        } else if size.height > (known?.height ?? 0) {
            remember(size)
        }
        // R1-1: the settle. Every real report re-arms it; the check that
        // fires after a quiet interval with the size unchanged adopts THAT
        // size — smaller or larger — and drops the reservation.
        settle.lastSize = size
        settle.generation += 1
        let generation = settle.generation
        let box = settle
        DispatchQueue.main.asyncAfter(deadline: .now() + settleInterval) {
            guard box.generation == generation, box.lastSize == size else { return }
            remember(size)
            loaded = true
            settled?()
        }
    }

    private var reserved: CGFloat? {
        guard !loaded, let known else { return nil }
        if let reportedWidth, abs(reportedWidth - known.width) > stableSurfaceWidthTolerance {
            return nil
        }
        return known.height
    }
}
