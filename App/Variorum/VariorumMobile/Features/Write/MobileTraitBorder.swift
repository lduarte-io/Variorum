//
//  MobileTraitBorder.swift
//  VariorumMobile
//
//  VM-54 (the VM-47 run, batch 3) — **a layer border that follows a light or
//  dark switch.** `CALayer.borderColor` is a `CGColor`, a fixed colour: a
//  dynamic `UIColor` resolved into it is frozen at that moment's appearance.
//  UIKit re-resolves a view's own `UIColor` properties (its background, a
//  label's text) when the appearance changes, but never a layer's. The take
//  cards, the takes pill and the comment draft set their borders this way at
//  `apply`/render time, and nothing re-ran them on a trait change — so a flip
//  with one on screen left the old appearance's border until the next model
//  render (the trace is in the run record, §6 "Batch 3 — results").
//
//  The fix keeps the DYNAMIC colour and re-resolves it at every change of the
//  view's user-interface style (`registerForTraitChanges`), and at each `set`.
//  One helper, owned by the view whose layer it borders.
//

import UIKit

@MainActor
final class MobileTraitBorder {
    private weak var view: UIView?
    /// The border's dynamic colour — re-resolved, never frozen.
    private(set) var color: UIColor?

    init(_ view: UIView) {
        self.view = view
        view.registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
            [weak self] (_: UIView, _: UITraitCollection) in
            self?.resolve()
        }
    }

    /// The border's colour, as a dynamic colour; resolved now for the view's
    /// current appearance and again at every light/dark change.
    func set(_ color: UIColor?) {
        self.color = color
        resolve()
    }

    private func resolve() {
        guard let view else { return }
        view.layer.borderColor = color?.resolvedColor(with: view.traitCollection).cgColor
    }
}
