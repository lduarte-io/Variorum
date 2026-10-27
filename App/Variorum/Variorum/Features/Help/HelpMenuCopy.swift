//
//  HelpMenuCopy.swift
//  Variorum (Mac)
//
//  VX-602 (the VX-439 run, A-439-9 + C-602-1) — her CLEAN checklist: "what's
//  under the help menu is SO confusing. 'Restore Tutorial' should be restore
//  field guide. take the tour should be the onboarding tutorial still. it's
//  just confusing." The Help menu names each thing once: the FIELD GUIDE (the
//  book of lessons — Open the Field Guide, Restore Field Guide…) and the
//  ONBOARDING TUTORIAL (the tour — `TourOfferCopy.menuTitle`). The words
//  that are registry verbs stay in the registry; this holds the undeclared
//  door's title and the sentences that name a declared one.
//

import Foundation

nonisolated enum HelpMenuCopy {
    /// Help ▸ Open the Field Guide — the undeclared standard Help door (the
    /// What's New precedent) and its ⌘K twin. It opens the field guide, the
    /// same book Restore Field Guide… restores (C-602-1: "Open the Tutorial"
    /// beside "Take the Onboarding Tutorial" was the confusion she named).
    static let openFieldGuide = "Open the Field Guide"

    /// The restore door's name as a sentence says it (its verb without the
    /// ellipsis that promises a confirm) — read from the registry, one source.
    static var restoreFieldGuideName: String {
        let verb = CapabilityRegistry.capability(.restoreTutorial).verb
        return verb.hasSuffix("\u{2026}") ? String(verb.dropLast()) : verb
    }
}
