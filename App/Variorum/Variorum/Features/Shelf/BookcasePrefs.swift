//
//  BookcasePrefs.swift
//  Variorum (Mac)
//
//  13i-d U1 — **THE BOOKCASE'S LOCAL MEMORY.** Every view preference the
//  rulings name for this board is LOCAL and remembered, never a synced
//  setting and never a Settings-pane row:
//  · `order ▾` — "View-local, remembered" (the sitting record §24);
//  · the details toggle — "a per-surface setting … remembered" (§21);
//  · the № panel's collapse — "click to collapse, click to expand … the
//    state REMEMBERED (a small local memory, never a Settings-pane row)"
//    (§19(c), carried onto the № by §23);
//  · the collapsible section headers (§7/§24);
//  · the DEFAULT shelf — PROVISIONAL P-13id-U1-1: local like its siblings
//    (the record names no store for it; every neighbouring Bookcase
//    preference is local), and nil = open on All.
//
//  `UserDefaults` is INJECTED (the KnownIssues R1-7 lesson — the test host
//  IS the Debug app, so a suite that wrote `.standard` would write her dev
//  store's preferences): the app passes `.standard`, every pin a scratch
//  suite. Keys are per WING where the value names a wing's rows (the default
//  shelf; collapse keys are shelf ids, unique anyway).
//

import Foundation

struct BookcasePrefs {
    let defaults: UserDefaults
    /// The wing this board shows ('' = Home).
    let wingID: String

    private enum Key {
        static let order = "bookcase.order"
        static let details = "bookcase.details"
        static let census = "bookcase.censusOpen"
        static let collapsed = "bookcase.collapsed"
        static func defaultShelf(_ wingID: String) -> String {
            "bookcase.defaultShelf." + (wingID.isEmpty ? "home" : wingID)
        }
    }

    var orderMode: BookcaseOrderMode {
        get { defaults.string(forKey: Key.order).flatMap(BookcaseOrderMode.init(rawValue:)) ?? .alphabetical }
        nonmutating set { defaults.set(newValue.rawValue, forKey: Key.order) }
    }

    /// Default SHOWN (the row meta is the shipped face; hiding it is her
    /// opt-in for clean chrome — §23).
    var detailsShown: Bool {
        get { defaults.object(forKey: Key.details) as? Bool ?? true }
        nonmutating set { defaults.set(newValue, forKey: Key.details) }
    }

    /// Default COLLAPSED (§23: "default collapsed to just itself").
    var censusOpen: Bool {
        get { defaults.bool(forKey: Key.census) }
        nonmutating set { defaults.set(newValue, forKey: Key.census) }
    }

    var collapsed: Set<String> {
        get { Set(defaults.stringArray(forKey: Key.collapsed) ?? []) }
        nonmutating set { defaults.set(newValue.sorted(), forKey: Key.collapsed) }
    }

    var defaultShelfID: String? {
        get { defaults.string(forKey: Key.defaultShelf(wingID)) }
        nonmutating set {
            if let newValue {
                defaults.set(newValue, forKey: Key.defaultShelf(wingID))
            } else {
                defaults.removeObject(forKey: Key.defaultShelf(wingID))
            }
        }
    }
}
