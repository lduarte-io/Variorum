//
//  MobileListingFilters.swift
//  VariorumMobile
//
//  **THE ONE FILTER BRAIN — the declaration AND the renderer, serving BOTH
//  rooms** (the Library filter batch, 2026-08-31; her rulings QUESTIONS #85
//  and #92).
//
//  Her #85, verbatim: *"Archived is a comparatively rare option, and it needs
//  the same filters that the regular library has. the mockup only had bookless
//  and scraps but those are less useful than 'books' 'posts', etc. so I'd want
//  to see that kind of sorting on the library, **which is more important
//  because it's where you see everything**."* Her #92(a): the **books** door
//  lists BOOKS AS ROWS; **posts** lists notes; scraps stays. Her #92(b): the
//  width budget gives at the SORT — it shrinks to a glyph, and everything
//  stays on ONE VISIBLE ROW (she declined horizontal scrolling, moving sort to
//  the search row, and measure-first).
//
//  **Why one file rather than a filter row per surface.** Two surfaces now
//  carry the same vocabulary, and a vocabulary that lives twice is this
//  round's own drift class (MobileSoul §3; `KnownIssuesAndTechDebt`'s
//  forked-brains row) — the second renderer copies the first, and then one of
//  them gains a door. The 6c batch left the Archive room deliberately shaped
//  for this: *"a plain `ScrollView`/`LazyVStack` under a two-line masthead with
//  nothing between them, so the Library's filter-row component drops into that
//  gap on BOTH surfaces as ONE brain rather than a second copy."*
//
//  **PHONE-LOCAL IS CORRECT HERE, and that is a judgment worth stating rather
//  than a default.** MobileSoul §3 says brains live in `VariorumCore` or
//  `App/Variorum/Shared/` and platforms own only faces — but the rule's own
//  test is whether a Mac twin exists to drift from, and there is none: the
//  Mac reaches these listings through its **sidebar** (Shelf · Library · Pool ·
//  Blocks · Archived — R44 + the post-13l Archived ruling), which is a
//  different mechanism, not a filter row. Nothing here is a rule the Mac also
//  holds, so hoisting it would move a phone face into a shared home and buy
//  no parity. *(If the Mac ever grows a kind-filter row, THAT phase hoists —
//  the standing §3 direction.)*
//

import SwiftUI
import VariorumCore

// MARK: - The declaration

/// The listing vocabulary both rooms speak.
///
/// **The door says "Notes", not "Posts" — PROVISIONAL.** Her #85/#92 said
/// *"posts"* while describing KINDS, and 13f's K5 sweep renamed post→note in
/// **all** UI strings (`container.kind='post'` stays the model term). Shipping
/// the app's own UI noun is the K5-consistent reading, and it is ONE STRING if
/// she re-words it.
///
/// **`bookless` stays a door — PROVISIONAL.** She called the provenance
/// filters *"less useful"*, not wrong, and removing a shipped door is a bigger
/// act than adding the kind doors (the R22/R25 precedent: door-count changes
/// are hers). It survives; the row was measured rather than trimmed.
nonisolated enum MobileListingFilter: String, CaseIterable, Sendable, Hashable {
    case all
    /// #92(a) — books AS ROWS, openable, the Shelf's own faces.
    case books
    /// #92(a)'s *"posts"*, in the app's own noun (see the type's doc).
    case notes
    case bookless
    /// The scraps area (parity C3): standalone blocks, not notes — its
    /// listing is `MobileScrapsModel`'s, never a note listing's.
    case scraps

    /// The door's word. `tokens.chromeLabel` voices it at render; the
    /// accessibility label stays this plain word (the standing rule: VoiceOver
    /// reads words, not chrome styling).
    var word: String {
        switch self {
        case .all: return "All"
        case .books: return "Books"
        case .notes: return "Notes"
        case .bookless: return "Bookless"
        case .scraps: return "Scraps"
        }
    }

    // *(There was an `isNoteListing` flag here, and the cold review's m3
    // retired it: the ONE site that read it — `MobileLibraryView.archiveRow`
    // — sits inside the branch that already excludes books and scraps, so
    // the clause could never be false. A guard that cannot fail reads as a
    // rule and is not one; the rule is the branch, and the pin
    // `theArchivedDoorTrailsNoteListingsOnly` proves the branch.)*

    // MARK: The per-room door sets

    /// **THE LIBRARY'S VOCABULARY** — the whole set. Her #85's own reason:
    /// the Library *"is where you see everything"*.
    static let libraryDoors: [MobileListingFilter] = [.all, .books, .notes, .bookless, .scraps]

    /// **THE ARCHIVE ROOM'S — the doors whose kind CAN exist there**, which is
    /// the honest form of *"Archived … needs the same filters that the regular
    /// library has"* (#85). Three doors are deliberately absent, and the reason
    /// is a MODEL FACT rather than a face call:
    ///
    /// - **books** — ⚠ the ORIGINAL reason here ("`reading` carries no
    ///   `archived_at`") was TRUE when this door was built and is FALSE since
    ///   13i-e (the VM-5 merge's round-1 review, MINOR 1): `Reading.archivedAt`
    ///   exists, `Operations+ReadingArchive` exists, and the phone's own shelf
    ///   long-press archives the daily Journal. The door stays absent today
    ///   only because the phone's archived-BOOKS face is OWED, not impossible —
    ///   MobileSoul's 13i-e row (F-U1-4; her 2026-10-04 walk mistook the hidden
    ///   state for a sync bug) and the board's VM-6 (4d) own it.
    /// - **bookless** — the bookless read is `Queries.poolPosts`, whose own
    ///   WHERE clause excludes archived posts. No archived-and-bookless core
    ///   read exists, and adding one is a fenced change.
    /// - **scraps** — the only archived-block read in core is
    ///   `Queries.archivedBlocks(_:postID:)`, which is per-NOTE by signature
    ///   (the tray's feed). There is no global archived-blocks listing, and the
    ///   Mac's Archived is NOTES only (the post-13l ruling) — matched, not
    ///   invented past.
    ///
    /// *(The old closing note said book-archiving "would be a schema event…
    /// nobody's to improvise" — it HAPPENED: 13i-e's v1_21/marker-12 event.
    /// What remains is the phone's face, owed at VM-6.)*
    static let archiveDoors: [MobileListingFilter] = [.all, .notes]

    /// The books listing's empty line. It lives here rather than on
    /// `MobileLibraryView` because that view is generic over its tab bar and
    /// cannot hold a static stored property — and because a listing's own
    /// words belong beside the door that opens it.
    static let noBooksLine = "No books yet."
}

// MARK: - The renderer

/// **The filter row, one renderer for both rooms.**
///
/// Plain `Button` doors (§15's trap (b): a door a pin can drive — never a
/// `Menu` row, whose accessibility tree comes back empty), one visible row, no
/// horizontal scroll (#92(b)'s letter).
///
/// **The fit rule, and it is measured rather than asserted:** the row must hold
/// five doors plus the sort glyph at 320 pt (Display Zoom) — the width the 4.5d
/// keyboard-bar work established as the narrowest the app is ever shown at.
/// `lineLimit(1)` + `minimumScaleFactor` is the degradation road her ruling
/// leaves open: a door that cannot fit its nominal size SHRINKS rather than
/// clipping or wrapping, exactly as the keyboard strip narrows at 320 instead
/// of hanging off both edges. The measurements live in
/// `MobileFilterRowGeometryTests` and in the batch record.
struct MobileFilterRow<Trailing: View>: View {
    let doors: [MobileListingFilter]
    let selection: MobileListingFilter
    let tokens: VoiceTokens
    let select: (MobileListingFilter) -> Void
    @ViewBuilder let trailing: () -> Trailing

    /// The gap between doors. Measured at 320 pt with five terminal-voice
    /// words (`all bookless books notes scraps` in 11.5 pt monospaced) plus the
    /// glyph — see the geometry pins, which read the REAL frames off a hosted
    /// surface rather than recomputing this number.
    static var doorSpacing: CGFloat { 11 }

    // *(There was an `identifier` here — *"the identifier the geometry pins
    // find this row by"* — and the cold review's m6 caught that no pin ever
    // found anything by it. It is deleted rather than adopted because the
    // claim turned out to be UNBUILDABLE, not merely unbuilt: the row is a
    // container, not an accessibility element, so its identifier never
    // reaches the tree at all. MEASURED on the real Library at 320 pt —
    // `identifiers on the real surface: []`, printed by
    // `theRealLibrarysRowFitsWithoutShrinkingAtDisplayZoom`, which is also
    // the case that now bounds the row by measuring every door in it.)*

    var body: some View {
        HStack(spacing: Self.doorSpacing) {
            ForEach(doors, id: \.self) { door in
                Button {
                    select(door)
                } label: {
                    Text(tokens.chromeLabel(door.word))
                        .font(tokens.small)
                        .foregroundStyle(selection == door ? tokens.ink : tokens.faint)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(door.word)
                .accessibilityAddTraits(selection == door ? .isSelected : [])
            }
            Spacer(minLength: 4)
            trailing()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }
}

extension MobileFilterRow where Trailing == EmptyView {
    /// The Archive room's shape: the same doors, no trailing control (its
    /// listing has one order — `archived_at DESC`, the core query's own).
    init(
        doors: [MobileListingFilter], selection: MobileListingFilter,
        tokens: VoiceTokens, select: @escaping (MobileListingFilter) -> Void
    ) {
        self.init(
            doors: doors, selection: selection, tokens: tokens, select: select,
            trailing: { EmptyView() })
    }
}

// MARK: - The sort glyph (#92(b))

/// **THE SORT, SHRUNK TO A GLYPH** — her #92(b) ruling, which is where the
/// width budget gives: *"everything stays on one visible row"*.
///
/// The menu behind it is byte-unchanged (the four standing stamps), and so is
/// its availability rule (`.all` only — see `MobileLibraryView.filterRow`).
/// What changed is the door: `sort: last meaningful edit` — up to 27
/// characters of monospaced chrome — becomes one 11.5 pt glyph, and **the full
/// verb moves into the accessibility label**, so nothing an assistive reader
/// hears is lost. That is the same trade the Today badge made at R26.2 (*"the
/// SPOKEN form stays the full name"*).
///
/// It is a DECLARATION, not a view, for the same reason `MobileRecoveryDoors`
/// is: the glyph and the spoken sentence are one decision, and the menu they
/// hang off belongs to the surface that owns the sort (the Library). A second
/// copy of either on any future surface is the drift this file exists to stop.
nonisolated enum MobileSortDoor {
    /// SF Symbol, not a text glyph: it renders identically in both voices and
    /// scales with the chrome font.
    static let symbol = "arrow.up.arrow.down"

    /// What VoiceOver reads: the full verb AND the current stamp, so the door
    /// says what it does and what it is set to.
    static func label(sortWord: String) -> String { "Sort: \(sortWord)" }
}
