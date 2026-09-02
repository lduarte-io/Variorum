//
//  RowClick.swift
//  Variorum (Mac)
//
//  The Act 10 correction round, ladder round 1 (R1-2) — **ONE row-click
//  brain**, hoisted from the Blocks workbench's row shell (batch C, row 25)
//  to the shared home, so the Library's rows stop holding every body click
//  for the double-click interval (the reviewer found the idiom batch C had
//  measured and replaced on the workbench still live on the surface batch E
//  rebuilt — the first thing a reader feels in the panel).
//
//  THE MECHANISM (C measured it): `.onTapGesture(count: 2)` stacked before a
//  plain `.onTapGesture` makes SwiftUI HOLD every single click until the
//  double-click window closes (`NSEvent.doubleClickInterval` — 0.5 s on her
//  Mac) before it delivers it — 0.26–0.49 s from the click to the row's
//  response; C's pin read 0.357 s on the old shell against a 150 ms budget.
//  Her bar names it (C-7: "a view that lags a second on selection is a
//  defect").
//
//  THE RULE: ONE tap handler that acts AT ONCE; a second click on the same
//  row inside the system's interval is the double — decided by the pure
//  `RowClickTiming` on the row's OWN clock, never by
//  `NSApp.currentEvent.clickCount` (`currentEvent` is only USUALLY the
//  mouse-up a tap concludes on, and `clickCount` asked of any other event
//  raises `NSInternalInconsistencyException` — batch C's crash class, caught
//  by its pin's event pump). Chords are read from the keyboard's live state
//  (`NSEvent.modifierFlags`) inside the click's own handling — the one place
//  that is true (`NoteRowClickModifiers.current`'s own reasoning; a stacked
//  modifier `TapGesture` dead-stalls every click). The first click of a
//  double has already acted (selected the row, shown the panel) — harmless,
//  and what a desktop double-click does anyway.
//
//  Consumers (the hoist's three): `WorkbenchRowShell` (Blocks), the
//  Library's book row and note row (`LibraryCatalogView`). One brain; a
//  fourth copy is a defect.
//

import AppKit
import SwiftUI

/// The double-click decision, pure and pinned: a click inside `interval`
/// of the previous one on the same row is the double.
nonisolated enum RowClickTiming {
    enum Verdict: Equatable {
        case single
        case double
    }

    static func verdict(
        now: ContinuousClock.Instant, lastClick: ContinuousClock.Instant?,
        interval: Duration
    ) -> Verdict {
        if let lastClick, now - lastClick < interval { return .double }
        return .single
    }
}

extension View {
    /// The row-click contract: `onClick` fires AT ONCE with the keyboard's
    /// live chord; a second click inside the system's double-click interval
    /// fires `onDoubleClick` instead (and resets the clock, so a third click
    /// is a single again).
    func rowClick(
        onClick: @escaping (EventModifiers) -> Void,
        onDoubleClick: @escaping () -> Void
    ) -> some View {
        modifier(RowClickModifier(onClick: onClick, onDoubleClick: onDoubleClick))
    }
}

struct RowClickModifier: ViewModifier {
    let onClick: (EventModifiers) -> Void
    let onDoubleClick: () -> Void

    /// When this row was last single-clicked — the row's own clock.
    @State private var lastClick: ContinuousClock.Instant?

    func body(content: Content) -> some View {
        content.onTapGesture {
            let now = ContinuousClock.now
            switch RowClickTiming.verdict(
                now: now, lastClick: lastClick,
                interval: .seconds(NSEvent.doubleClickInterval))
            {
            case .double:
                lastClick = nil
                onDoubleClick()
            case .single:
                lastClick = now
                onClick(Self.currentModifiers)
            }
        }
    }

    /// The keyboard's live chord, read inside the click's own handling.
    static var currentModifiers: EventModifiers {
        let flags = NSEvent.modifierFlags
        var mods: EventModifiers = []
        if flags.contains(.command) { mods.insert(.command) }
        if flags.contains(.shift) { mods.insert(.shift) }
        if flags.contains(.option) { mods.insert(.option) }
        if flags.contains(.control) { mods.insert(.control) }
        return mods
    }
}
