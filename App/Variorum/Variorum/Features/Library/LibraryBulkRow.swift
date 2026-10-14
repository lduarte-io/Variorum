//
//  LibraryBulkRow.swift
//  Variorum (Mac)
//
//  The pick's doors (13e E8, 13l Act 2, 13n-c U3) — their own row under the
//  Library's controls while several notes are picked (the UX walk's W-UX-3),
//  each label whole. Its own view since the UX-fix ladder's UXR1-3, so its
//  geometry is measurable (`LibraryBulkRowGeometryTests`).
//

import SwiftUI
import VariorumCore

struct LibraryBulkRow: View {
    let tokens: VoiceTokens
    /// How many notes are picked (every label says it).
    let count: Int
    /// The Tag menu's rows.
    let tags: [Tag]
    /// 13e E8 — the bulk half of *"remove / add them"*: the tags the PICK
    /// actually wears, so the Untag menu never offers an act that would do
    /// nothing (P-2); with none, there is no menu at all.
    let worn: [Tag]
    /// 13n-c U3 — VX-272: the share door only while an approved client exists.
    let canShare: Bool
    let onTag: (String) -> Void
    let onUntag: (String) -> Void
    /// SHARE THE PICK: THE grant sheet pre-filled with these notes.
    let onShare: () -> Void
    /// 13l Act 2 (item 3) — ONE confirmation naming the count, ONE receipt.
    let onDelete: () -> Void

    /// **UXR1-3 (the UX-fix ladder, round 1):** every door keeps its whole
    /// words (`fixedSize` — W-UX-3's point: the doors collapsed to bare
    /// chevrons in the controls' row), so a single line's minimum width is the
    /// SUM of its labels — ≈714 pt in Terminal at 3 notes, past the list
    /// column at the app's own 1240-pt default with the info panel open. The
    /// row now WRAPS instead of pushing: one line where it fits, else the count
    /// over the doors, else the doors in two lines (`LibraryBulkRowGeometryTests`
    /// — the oracle at the default window, both voices, 3/12/1000 notes).
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Self.spacing) {
                countLabel
                doors
                Spacer(minLength: 0)
            }
            VStack(alignment: .leading, spacing: Self.lineSpacing) {
                countLabel
                HStack(spacing: Self.spacing) {
                    doors
                    Spacer(minLength: 0)
                }
            }
            VStack(alignment: .leading, spacing: Self.lineSpacing) {
                countLabel
                HStack(spacing: Self.spacing) {
                    tagDoors
                    Spacer(minLength: 0)
                }
                HStack(spacing: Self.spacing) {
                    actDoors
                    Spacer(minLength: 0)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private static let spacing: CGFloat = 14
    private static let lineSpacing: CGFloat = 6

    private var countLabel: some View {
        Text(tokens.chromeLabel(LibraryCopy.notesPicked(count)))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .lineLimit(1)
            .fixedSize()
    }

    @ViewBuilder private var doors: some View {
        tagDoors
        actDoors
    }

    @ViewBuilder private var tagDoors: some View {
        Menu(tokens.chromeLabel("Tag \(count) notes")) {
            ForEach(tags, id: \.id) { tag in
                Button(tag.path) { onTag(tag.id) }
            }
        }
        .font(tokens.small)
        .fixedSize()
        if !worn.isEmpty {
            Menu(tokens.chromeLabel("Untag \(count) notes")) {
                ForEach(worn, id: \.id) { tag in
                    Button(tag.path) { onUntag(tag.id) }
                }
            }
            .font(tokens.small)
            .fixedSize()
        }
    }

    @ViewBuilder private var actDoors: some View {
        if canShare {
            Button(tokens.chromeLabel(MCPShareCopy.shareNotes(count)), action: onShare)
                .font(tokens.small)
                .fixedSize()
        }
        Button(tokens.chromeLabel("Delete \(count) notes\u{2026}"), role: .destructive, action: onDelete)
            .font(tokens.small)
            .fixedSize()
    }
}
