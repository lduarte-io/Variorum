//
//  LibraryBooksRegion.swift
//  Variorum (Mac)
//
//  **17y B1 item (k)'s rider — the books stop swallowing the notes.** Her
//  words: on the "All" screen, "once books hit ~half of the vertical area,
//  books start to scroll within their own little view, so that many books
//  won't mean you see no notes." The surface her words name is the Library's
//  List mode under the "All" scope — the one screen that lists books ABOVE
//  notes (the Bookcase lists books only; Cards lists notes only) — where every
//  book used to sit in one list with the notes, so a wing of thirty books put
//  the first note below the window.
//
//  The rule is pure (pinned): under All, when the books would take more than
//  HALF the listing's height and anything else is listed below them, they get
//  their own List capped at half, scrolling inside it; fewer books stay in
//  the one list exactly as before. The height is the books List's own
//  measured row pitch times the count — never a guessed row count, so both
//  voices split at the same visual point.
//

import SwiftUI
import VariorumCore

enum LibraryBooksRegion {
    /// "~half of the vertical area" — hers.
    static let share: CGFloat = 0.5
    /// A List row's pitch and the section header's lead before the List has
    /// measured its own (Terminal's, measured 2026-10-05); replaced by the
    /// drawn pitch the moment two book rows report.
    static let defaultPitch: CGFloat = 25
    static let defaultLead: CGFloat = 30

    /// Does the List mode split the books into their own capped list?
    static func capsBooks(
        scope: LibraryCatalogModel.Scope, books: Int, showsMore: Bool,
        pitch: CGFloat, lead: CGFloat, height: CGFloat
    ) -> Bool {
        guard scope == .all, showsMore, books > 0, height > 0 else { return false }
        return lead + CGFloat(books) * pitch > height * share
    }

    /// The capped region's height: half the listing's, on whole points.
    static func cappedHeight(_ height: CGFloat) -> CGFloat {
        (height * share).rounded()
    }
}

/// **The end of the listed notes while more remain** (17y B1 (k)): the
/// listing asks for the next page before she gets here
/// (`LibraryCatalogModel.prefetchMargin`), so this row is normally passed as
/// an empty line; if a very fast scroll outruns the page, it says the notes
/// are coming rather than reading as the end of the Library.
struct LibraryMoreNotesRow: View {
    let tokens: VoiceTokens
    let loading: Bool

    var body: some View {
        Text(tokens.chromeLabel(loading ? LibraryCopy.loadingMoreNotes : ""))
            .font(tokens.small)
            .foregroundStyle(tokens.faint)
            .lineLimit(1)
            .frame(maxWidth: .infinity, minHeight: 18, alignment: .leading)
            .accessibilityHidden(!loading)
    }
}
