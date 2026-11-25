//
//  CatalogNoteLine.swift
//  Variorum (Mac)
//
//  **The Library's note row — one row, two features** (the VX-1036 run, batch
//  3; VX-1084, her R-1036-38: "List is the Library's row"). The List mode's
//  note LINE (title · the stated day · the tag cards and their ＋ · the
//  trailing stamp, on one text baseline), its quiet "archived" mark, and its
//  click SHELL (one row target, the shared `rowClick` brain) moved here out of
//  `LibraryCatalogView.swift` when the book's List mode began drawing the same
//  row (CLAUDE.md's two-features rule — a view two features consume lives in
//  the shared home). Every type keeps its name, so no call site and no pin
//  moved; the book's switches are defaulted parameters the Library never sets
//  (`showsTags`, `tagUses`, `recordsLibraryProbe`). The list's face around the
//  row — its insets, separators and headers — is `LibraryListFace.swift`, here
//  beside it for the same reason.
//

import SwiftUI
import VariorumCore

/// **A note row's line** — title · date · the tag cards and their ＋ — on
/// ONE text baseline. Her report (image 4): *"the tags are also misaligned
/// from the text"*. The row already aligned on `.firstTextBaseline`; the
/// chips did not carry one (see `NoteTagChips.chip`), so the stack aligned
/// the title to a symbol's bottom edge instead. Extracted for the same pin.
struct CatalogNoteLine: View {
    let tokens: VoiceTokens
    let title: String
    /// **The day she STATED** (`container.entry_date`), or nothing. Worded
    /// by the one brain since 17q (the 18h ladder's R3-2 — this slot printed
    /// the RAW stored `2026-09-08` beside worded stamps, so the List row and
    /// the Notes card spoke one note's time in two grammars); the CALLER
    /// decides whether the row carries it at all
    /// (`LibrarySortFace.RowStamps.listDay` — nothing under the `date` sort,
    /// where the trailing stamp already says that day).
    let date: String?
    let tags: [Tag]
    let allTags: [Tag]
    let onTitleTap: () -> Void
    let onApply: (String) -> Void
    let onRemove: (Tag) -> Void
    /// **18h batch 1 (her row 9):** the muted trailing stamp — the SORT'S
    /// own (`LibrarySortFace.rowStamp`), worded by the one brain. Defaulted
    /// to nothing so the shipped alignment pins construct the line exactly as
    /// they did and keep measuring exactly what they measured.
    var stamp = LibrarySortFace.RowStamp(subject: .edited, stamp: nil)
    /// "now" for the stamp's words, injected by the pin that fixes the clock.
    var now: Date = Date()
    /// The note this row is about — the DEBUG words oracle's key (17q; nil
    /// off the pinned surfaces, and the oracle itself is DEBUG-only).
    var oracleKey: String?
    /// 13i-c U4 (§6): the owned-by badge, or nil (the common case draws
    /// nothing, so the shipped alignment pins measure exactly what they did).
    var badge: OwnershipBadgeFace.Badge? = nil
    var badgePostID: String = ""
    /// VX-84a: the note is archived — only ever on the tag-alone listing
    /// under the archived facet (R-13o-6, "rows say which they are"); false
    /// draws nothing, so the shipped alignment pins measure what they did.
    var archived = false
    /// 13n-c U4: the note an ask may wait on — its pending glyph rides the
    /// title (nil, and a calm note, draw nothing — the shipped alignment pins
    /// measure exactly what they did).
    var askTarget: MCPAskTarget? = nil
    /// VX-268 — who reaches this note now (the ONE icon's reaches, from the
    /// row's own slice; empty — the common case — draws nothing, so the
    /// shipped alignment pins measure exactly what they did).
    var reach: [MCPPlaceReach] = []
    /// VX-831 — the note's Private mark, from the row's own slice (nil — the
    /// common case — draws nothing, so the shipped alignment pins measure
    /// exactly what they did).
    var privateMark: PrivateMarkDoor? = nil
    /// **VX-1084 — the book's tags switch** (R-1036-39): false draws no tag
    /// cards and no ＋ at all (a book whose tags are hidden). The Library
    /// never sets it — its rows always wear their tags.
    var showsTags = true
    /// VX-576: the ＋ popover's use counts (most-used first); empty — the
    /// Library's — keeps the path order.
    var tagUses: [String: Int] = [:]

    static let probeSpace = "catalog-note-line"

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                // ONE line, as the Notes card's title has always been (13u3
                // UNIT B): the row IS a single baseline — a title, a day, the
                // chips and the stamp all sit on it — so a wrapped name would
                // break the alignment those pins measure. It also makes the
                // two modes agree about a long name: both truncate.
                .lineLimit(1)
                .baselineProbe("note.title", in: Self.probeSpace)
                .onTapGesture(perform: onTitleTap)
            // VX-268: the ONE shared icon beside its sibling, the ask glyph
            // (the Bookcase row's order — shared, then a waiting ask).
            if !reach.isEmpty {
                MCPSharedIcon(reaches: reach, tokens: tokens)
                    .baselineProbe("note.shared", in: Self.probeSpace)
            }
            // VX-831: the Private mark — shared, private, then a waiting ask.
            PrivateMarkView(door: privateMark, tokens: tokens)
            if let askTarget {
                MCPAskGlyph(askTarget, tokens: tokens)
            }
            if let date {
                CatalogRowStamp(
                    tokens: tokens,
                    face: LibrarySortFace.RowStamp(subject: .dated, stamp: date), now: now,
                    baselineProbePrefix: "note", baselineProbeSpace: Self.probeSpace,
                    baselineProbeName: "date",
                    oracleKey: oracleKey, oracleSlot: "row.date")
            }
            if showsTags {
                NoteTagsRow(
                    tokens: tokens, tags: tags, allTags: allTags,
                    onApply: onApply, onRemove: onRemove,
                    baselineProbePrefix: "note", baselineProbeSpace: Self.probeSpace,
                    uses: tagUses)
            }
            if let badge {
                OwnershipBadgeView(tokens: tokens, badge: badge, postID: badgePostID)
            }
            if archived {
                CatalogArchivedMark(tokens: tokens)
            }
            Spacer()
            // Her row 9: *"see the created time and last edited time easily
            // on the library."* At the row's trailing edge, muted, on the
            // title's own baseline, the whole fact on hover.
            CatalogRowStamp(
                tokens: tokens, face: stamp, now: now,
                baselineProbePrefix: "note", baselineProbeSpace: Self.probeSpace,
                oracleKey: oracleKey, oracleSlot: "row.stamp")
        }
        .coordinateSpace(name: Self.probeSpace)
    }
}

/// **The quiet "archived" mark a listed note wears** (VX-84a — a `#tag`
/// typed alone with the archived facet on lists the tag's archived notes, and
/// each says so: R-13o-6's letter, the answer sheet's own badge word and
/// shape — `SearchAnswerCopy.archivedMark`).
struct CatalogArchivedMark: View {
    let tokens: VoiceTokens

    var body: some View {
        Text(tokens.chromeLabel(SearchAnswerCopy.archivedMark))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .padding(.horizontal, 5)
            .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(tokens.line))
            .lineLimit(1)
            .fixedSize()
            .help(SearchAnswerCopy.archivedNote)
    }
}

/// The note row's click SHELL (ladder R1-2): the whole row is the target,
/// the shared `rowClick` brain decides single vs double, and the modifiers
/// arrive as the click model's own `NoteRowClickModifiers`. Internal so the
/// pin can mount ONE row alone in a real window and click it for real (the
/// workbench shell's own pin shape — the whole catalog under the rig's
/// event pump hangs, as the whole workbench did in batch C).
struct CatalogNoteRowShell<Content: View>: View {
    let postID: String
    let onClick: (NoteRowClickModifiers) -> Void
    let onDoubleClick: () -> Void
    /// VX-1084: the Library's DEBUG row-frame oracle is the CATALOG's — a
    /// host that is not the catalog (the book's List) records nothing there.
    var recordsLibraryProbe = true
    @ViewBuilder var content: () -> Content

    var body: some View {
        probed(content().contentShape(Rectangle()))
            .rowClick(
                onClick: { modifiers in
                    onClick(NoteRowClickModifiers(
                        command: modifiers.contains(.command), shift: modifiers.contains(.shift)))
                },
                onDoubleClick: onDoubleClick)
    }

    @ViewBuilder
    private func probed<V: View>(_ row: V) -> some View {
        if recordsLibraryProbe {
            row.libraryGeometryProbe(.noteRow(postID))
        } else {
            row
        }
    }
}
