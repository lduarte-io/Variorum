//
//  BookFilterBar.swift
//  Variorum (Mac)
//
//  13i-d U3 — THE IN-BOOK FILTER BAR's FACE (the sitting record §18.1, her
//  ORIGINAL sitting ask, verbatim: *"being able to either filter a book within
//  itself for a subset of the tags, or make a new book to look at just the
//  tags, is important."*). RULED: a view-local filter bar on a book's (and a
//  gathering's) Index — filter the view by tags/star, NEVER mutating
//  membership — plus the "Save this filter as a gathering" door (rule = the
//  book's tag association ∧ the filter). The MECHANICS shipped at 13i-b U4
//  (`Queries.assembleReading(…, filter:)`, `Operations.saveFilterAsGathering`);
//  this file is the face.
//

import SwiftUI
import VariorumCore

/// Every word the filter bar says. Wording PROVISIONAL (13s re-voices); the
/// TRUTHS are ruled (§18.1: it filters the VIEW; saving mints a gathering).
nonisolated enum BookFilterCopy {
    /// The registry's verb — §18.1's own words.
    static let saveVerb = "Save This Filter as a Gathering\u{2026}"
    static let unavailableNote =
        "The filter lives on a book's Index \u{2014} choose a tag there, then save it as a "
        + "gathering."
}

/// The bar (its face lands with piece 9 of the U3 record; the declaration is
/// here from the start so the registry walk names its renderer).
struct BookFilterBar: View {
    /// P-1's walk: the bar's one WRITE — saving the filter as a gathering.
    /// The terms themselves are view-local looks, never acts.
    static let surfaceCapabilities: [CapabilityID] = [.saveFilterAsGathering]

    var body: some View { EmptyView() }
}
