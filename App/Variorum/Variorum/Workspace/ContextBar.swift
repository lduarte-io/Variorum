//
//  ContextBar.swift
//  Variorum (Mac)
//
//  Phase 13f, batch 5 (W20 b) — ONE bar above the pane saying WHERE YOU ARE.
//  **Phase 13k, batch 3 (K11/K12) — REBUILT as the compact icon row.**
//
//  It began as batch 3's back chip (W16) and grew the ascent's "in <book>"
//  in-line beside it, both spelled out in words and folding together. Her
//  13k ruling retires that presentation whole:
//
//  > *"the collapsing and growing in that bar is a little annoying to me"* …
//  > *"it should always look like this"*
//
//  So the bar is ALWAYS **← · book · ＃ · →** — four doors that never move,
//  each live or honestly grey, with the note's tag cards riding after them
//  (K12: visible at rest; ＃ folds them, deliberately and stickily).
//
//  ── WHAT CHANGED, AND WHAT DID NOT ───────────────────────────────────────
//  The NAVIGATION under it is 13f's, untouched: `NavigationHistory`'s
//  arithmetic, ⌘[ / ⌘], and the W21/membership ascent (the shell decides
//  what a named destination means — P-4). What this file owns is the FACE:
//  the back chip's spelled-out label is gone, the "in <book(s)>" sentence
//  is gone into the book icon, the → is a real forward door where before
//  there was only a fold chevron, and the whole-bar collapse retires
//  (13g's WT-2 born-collapsed default retires with it — there is nothing
//  left to collapse).
//
//  ── WHY THE ICONS COME FIRST AND THE CHIPS LAST ─────────────────────────
//  Chips vary in number and width. With the four icons in a fixed cluster
//  and the chips after them, adding a tag moves nothing she is aiming at —
//  which is the same complaint her ruling is about, one layer down.
//
//  ── WHY BOTH HALVES BELONG TO THE PANE ───────────────────────────────────
//  "Where did I come from" is the PANE's fact (batch 3's reason for putting
//  the chip in the shell rather than in `PostDetailView`), and so is "what
//  is this pane's note inside of", and so are its tags. One bar per pane
//  therefore serves a post, a book, a folder and the recovery surface
//  alike, and Write's masthead stays untouched.
//

import AppKit
import SwiftUI
import VariorumCore

struct ContextBar: View {
    let tokens: VoiceTokens
    /// Where this pane arrived from — nil ⇒ the ← is GREY (never absent:
    /// the row is a constant). It names the destination in the tooltip;
    /// since K11 it is never spelled out on the bar.
    let originLabel: String?
    /// Where ⌘] would go — nil ⇒ the → is grey. Her ruling: *"after you
    /// just went back, i feel like you should be able to go forward"*.
    let forwardLabel: String?
    /// The pane's note's books, already ORDERED (`BookChooserOrder`) — one
    /// book opens on click, several open the list, none leaves the icon
    /// grey.
    let books: [Reading]
    /// 13g batch 7 (R6-1): the note's tags, as coloured cards. Present only
    /// when the pane holds a NOTE; a pane at the shelf or in a book has no
    /// tags to wear, and no ＃ door either (P-2).
    var tagFace: TagFace? = nil
    /// K12 — her deliberate, sticky choice (`TagChipsFold`).
    let tagsFolded: Bool
    /// 13j J2 — the TRAY badge. Present only when the pane holds a note;
    /// the badge itself renders only when that note has deleted something
    /// (her sitting-round-1 ruling: *"visible ONLY when the note has
    /// deleted/archived blocks"* — calm at rest).
    var trayFace: TrayFace? = nil
    /// R4-3: the chips' corner radius. Defaulted, so every caller in the
    /// app gets the shipped shape and only the capture harness ever names
    /// one (her experiment framing — the variants are a picture, not a
    /// setting).
    var chipCornerRadius: CGFloat = TagChipShape.cornerRadius
    let onBack: () -> Void
    let onForward: () -> Void
    /// The ascent: open this book, revealed at this note.
    let onOpenBook: (String) -> Void
    let onToggleTags: () -> Void

    /// Everything the tag half needs, bundled so the bar stays a pure
    /// presentation of what it is handed (the `books` shape).
    struct TagFace {
        var tags: [Tag]
        var allTags: [Tag]
        var onApply: (String) -> Void
        var onRemove: (Tag) -> Void
    }

    /// The tray half, same bundling (13j J2).
    struct TrayFace {
        /// Blocks individually deleted from this note — **the only number
        /// the badge shows.** Sitting round 5, stated: preserved originals
        /// appear in the panel but must not inflate an urgent-looking count.
        var deletedCount: Int
        /// …which the tooltip still mentions, because "3 deleted" beside a
        /// panel holding four rows would read as a miscount.
        var preservedCount: Int
        var onOpen: () -> Void
    }

    /// The `.surface` acts this bar renders (P-1's declared ⇔ rendered
    /// walk).
    ///
    /// **13e E11: the ASCENT joined them.** It was deliberately left out at
    /// 13k ("declaring it is a build-time call on the walk register" —
    /// QUESTIONS #55(i)), she ratified that with the declare-it alternative
    /// left open, and then asked for the registry to be kept up to date. The
    /// act is unchanged; what it gains is a catalog row, a written refusal
    /// and this walk's coverage.
    static let surfaceCapabilities: [CapabilityID] = [
        .navigateBack, .navigateForward, .toggleTagChips, .openBookAtNote,
        // 13e E8: the CARDS' own doors — `＋` types a tag on, `✕` takes one
        // off. They have worked since 13g R6-1 and were never declared; the
        // Library's rows now render the same act, so the one act is
        // declared once and both renderers name it (E11's shape, one act
        // over).
        .tagNote,
        // 13j J2: the tray badge — the bar's fifth door, and the only one
        // that is CONDITIONAL (see `trayDoorShown`).
        .showNoteTray,
    ]

    @State private var listingBooks = false

    private var isNote: Bool { tagFace != nil }

    /// The doors this bar renders, in her screenshot's order — and the
    /// literal thing the body iterates, so "the row never changes" is a
    /// claim a pin can hold.
    var renderedIcons: [ContextBarDoors.Icon] {
        ContextBarDoors.iconRow(isNote: isNote)
    }

    var backEnabled: Bool { originLabel != nil }
    var forwardEnabled: Bool { forwardLabel != nil }

    /// 13e E11 — the book door's enablement, read FROM the registry rather
    /// than re-derived here (P-1: "gating is data, never per-view
    /// if-statements"). Byte-identical to the shipped `!books.isEmpty` by
    /// construction — the context it builds carries exactly that fact — which
    /// is what makes the declaration load-bearing instead of decorative
    /// without changing anything she can see.
    var bookEnabled: Bool {
        CapabilityRegistry.isEnabled(
            .openBookAtNote, in: CapabilityContext(canAscendToBook: !books.isEmpty))
    }

    /// What the ＃ door DOES, as a value the body reads: fold and the cards
    /// go, unfold and they are back. K12's whole behaviour, stated where a
    /// pin can hold it rather than only inside a `ViewBuilder`.
    var chipsShown: Bool { tagFace != nil && !tagsFolded }

    /// **Whether the tray badge is on the bar** (13j J2), as a value rather
    /// than an `if` inside the body — the K11 discipline this file already
    /// keeps for `renderedIcons`.
    ///
    /// ── HOW THIS SITS WITH HER K11 RULING ────────────────────────────────
    /// K11 says the icon row *"should always look like this"* — four doors
    /// that never move — and its stated reason is that *"adding a tag moves
    /// nothing she is aiming at"*. Her later J2 ruling asks for a door that
    /// is *"visible ONLY when the note has deleted/archived blocks"*. Both
    /// are hers, and they compose exactly: `ContextBarDoors.iconRow` is
    /// UNTOUCHED, so the four aiming targets stay a constant cluster in
    /// their constant order; the badge appears AFTER them, before the chips,
    /// and only ever moves when she has just deleted something — a
    /// deliberate act of her own, not the passive drift the ruling names.
    var trayDoorShown: Bool { (trayFace?.deletedCount ?? 0) > 0 }

    /// Nothing to say ⇒ no bar: a cold launch at the shelf keeps exactly
    /// the chrome it had before any of this shipped.
    ///
    /// **`isNote` is load-bearing beyond the icon row (13e batch 8, rider
    /// 1).** It is what makes this answer TRUE ON THE FIRST PASS for a
    /// note-only window, whose history is empty and whose `books` arrive from
    /// an async read. Before K11 added it, that window's bar appeared a
    /// runloop late — inserted above the masthead, whose pixels were already
    /// presented — and clipped the top of the window until she resized it
    /// (the KnownIssues row, traced in `NoteWindowView`, reproduced by
    /// reverting exactly this line). Making the bar conditional on anything
    /// loaded ASYNCHRONOUSLY re-opens that defect; `NoteWindowFirstPassTests`
    /// is the guard.
    var hasContent: Bool {
        ContextBarDoors.hasContent(
            isNote: isNote, canBack: backEnabled, canForward: forwardEnabled,
            bookCount: books.count)
    }

    var body: some View {
        if hasContent {
            HStack(spacing: 1) {
                ForEach(renderedIcons, id: \.self) { icon in
                    switch icon {
                    case .back: backDoor
                    case .book: bookDoor
                    case .tags: tagsDoor
                    case .forward: forwardDoor
                    }
                }
                if let trayFace, trayDoorShown {
                    trayDoor(trayFace)
                }
                if let tagFace, chipsShown {
                    NoteTagChips(
                        tokens: tokens, tags: tagFace.tags, allTags: tagFace.allTags,
                        onApply: tagFace.onApply, onRemove: tagFace.onRemove,
                        cornerRadius: chipCornerRadius)
                        .padding(.leading, 6)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 3)
            .background(tokens.room)
        }
    }

    // MARK: - The four doors

    /// One glyph's frame. `minWidth` so a grey door occupies exactly the
    /// room a live one does — the row must not shift as history fills.
    private func glyph<Content: View>(
        enabled: Bool, @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .font(tokens.small)
            .foregroundStyle(enabled ? tokens.accent : tokens.faint)
            .frame(minWidth: 15)
            .padding(.vertical, 2)
            .padding(.horizontal, 3)
            .contentShape(Rectangle())
    }

    private var backDoor: some View {
        Button(action: onBack) {
            glyph(enabled: backEnabled) { Text(ContextBarDoors.backGlyph) }
        }
        .buttonStyle(.plain)
        .disabled(!backEnabled)
        .help(WorkspaceNaming.backHelp(origin: originLabel))
    }

    private var forwardDoor: some View {
        Button(action: onForward) {
            glyph(enabled: forwardEnabled) { Text(ContextBarDoors.forwardGlyph) }
        }
        .buttonStyle(.plain)
        .disabled(!forwardEnabled)
        .help(WorkspaceNaming.forwardHelp(destination: forwardLabel))
    }

    /// THE ASCENT. One book opens; several list; ⌘-click lists either way
    /// (her ruling). Grey with none — and grey rather than absent, because
    /// her ruling names exactly that case.
    private var bookDoor: some View {
        Button {
            // The modifier is read at ACT time, which is when it is true.
            // The decision itself is pure (`ContextBarDoors.bookClick`) so
            // the three-way rule is pinnable without an event.
            switch ContextBarDoors.bookClick(
                bookCount: books.count,
                commandHeld: NSEvent.modifierFlags.contains(.command)
            ) {
            case .none: break  // grey; unreachable except by a race
            case .open: if let first = books.first { onOpenBook(first.id) }
            case .list: listingBooks = true
            }
        } label: {
            glyph(enabled: bookEnabled) { Image(systemName: "book") }
        }
        .buttonStyle(.plain)
        .disabled(!bookEnabled)
        .help(WorkspaceNaming.ascentHelp(topBook: books.first?.name, count: books.count))
        .popover(isPresented: $listingBooks, arrowEdge: .bottom) { bookList }
    }

    /// The dropdown — the same rows the membership chip offers, minus its
    /// editing doors: this is a navigation door, and adding/removing books
    /// stays where it has always been (the masthead's chip).
    private var bookList: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(WorkspaceNaming.ascentListHeader(count: books.count))
                .font(.callout.weight(.semibold))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 260, alignment: .leading)
            ForEach(books, id: \.id) { book in
                Button(book.name) {
                    listingBooks = false
                    onOpenBook(book.id)
                }
                .buttonStyle(.link)
                .help("Open \u{201C}\(book.name)\u{201D} at this note")
            }
        }
        .padding(12)
    }

    /// **⌫ N — the tray badge** (13j J2). Quiet, countable, and it says
    /// what it opens: no glyph on its own can carry "the blocks this note
    /// deleted", so the tooltip does the naming and the panel does the rest.
    private func trayDoor(_ face: TrayFace) -> some View {
        Button(action: face.onOpen) {
            glyph(enabled: true) {
                Text(tokens.chromeLabel(TrayPath.doorLabel(deleted: face.deletedCount)))
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .help(WorkspaceNaming.trayDoorHelp(
            deleted: face.deletedCount, preserved: face.preservedCount))
    }

    /// K12's deliberate fold. Folded it carries the count (the shipped
    /// folded grammar); unfolded the cards are right there.
    private var tagsDoor: some View {
        Button(action: onToggleTags) {
            glyph(enabled: true) {
                HStack(spacing: 2) {
                    Image(systemName: "number")
                    if let count = ContextBarDoors.tagsDoorCount(
                        folded: tagsFolded, tagCount: tagFace?.tags.count ?? 0) {
                        Text(tokens.chromeLabel("\(count)"))
                            .foregroundStyle(tokens.muted)
                            .lineLimit(1)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .help(WorkspaceNaming.tagsFoldHelp(folded: tagsFolded))
    }
}
