//
//  SearchPickerBrain.swift
//  Variorum (shared: Mac + Mobile)
//
//  VM-63 (the VM-55 run, "Wings underneath", batch 3) — THE ONE PICKER
//  BRAIN's query rule, hoisted with the wing brains that read it. The
//  switcher's brain (`WingSwitcherBrain.visible`, now in `Shared/`) filters
//  its rows with the picker's own sameness, so the rule it calls moved with
//  it — byte for byte, under the same name — and the rest of the picker brain
//  (the options it shows, the create offer, the sectioned lines) stays the
//  Mac's, as `extension SearchPickerBrain` beside its face
//  (`Variorum/Core/Views/SearchPicker.swift`). One rule, never a second copy.
//

import Foundation

nonisolated enum SearchPickerBrain {
    /// The query as the picker reads it: trimmed; a leading "#" dropped (she
    /// may type a tag the way it reads).
    static func normalized(_ query: String) -> String {
        var trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        while trimmed.hasPrefix("#") { trimmed.removeFirst() }
        return trimmed.trimmingCharacters(in: .whitespaces)
    }
}
