//
//  PagedReadView.swift
//  Variorum
//
//  READ's second face — TRUE BOOK PAGINATION (13c Batch 2C; committed scope
//  1 / ledger C1, from `notes/plans/phase-13c-uniform-page-view-brief.md`).
//  Her direction of 2026-07-23/24: Read becomes the Apple-Books/Kindle PAIR
//  of modes — **(a) vertical infinite scroll** (`ReadingFlowView`) and
//  **(b) a TWO-PAGE SPREAD of horizontal pages each holding a SET amount of
//  text, with text flowing across identical fixed pages.**
//
//  **Read is NOT editable** (her A43 ruling, and its reasoning: Read's value
//  as a distinct mode is that it is a place to just read, and true
//  pagination plus live editing is the hardest combination in the stack to
//  keep stable — TEXTKIT2 §2). R8/R23 is honored exactly: this is not an
//  editing surface, so nothing here is expected to be editable. Two
//  consequences worth naming, both good:
//
//  - there is **no NSTextView on this surface at all** — a page is a
//    `CTFrame` drawn into a view, so there is no live ring to migrate, no
//    canary to arm, no fallback to fear, and no TK2 geometry to be lied to
//    by (`PagePaginator`'s header has the argument);
//  - **the arrow keys are unconditional** here, unlike Book's (2B had to
//    withdraw them while a page held the live editor — QUESTIONS #44(d));
//    nothing on this surface ever wants an arrow key for anything else.
//
//  The bottom bar STAYS (the brief's instruction — "KEEP the bottom bar on
//  the paginated sub-mode"), and it carries the SLIDER the brief §4 designs
//  over the ESTIMATED page domain. That is deliberately different from Book,
//  where 2B removed the slider on its own brief's instruction and flagged it
//  as QUESTIONS #44(c) — so whichever way she rules, one of the two surfaces
//  already shows her the answer she is choosing between.
//

import AppKit
import CoreText
import SwiftUI
import VariorumCore

struct PagedReadView: View {
    let session: AppSession
    let model: BookViewModel
    let structure: BookStructureModel
    /// Row 82: a click on a page's paragraph WAKES the editable index at
    /// that (note, block) — the flow's own door (`onWake`), on paper.
    var onWake: ((_ postID: String, _ blockID: String) -> Void)? = nil
    /// WA-1 (the 13n-a walk): this mode's flip bar is the book's MAIN bottom
    /// bar, so its trailing end hosts the quiet receipt — when
    /// `BookNoteBox.quietReceiptHome` says so (one receipt never draws twice).
    var hostsQuietReceipt: Bool = true

    @State private var pages: PagedReadModel
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession, model: BookViewModel, structure: BookStructureModel,
        hostsQuietReceipt: Bool = true,
        onWake: ((_ postID: String, _ blockID: String) -> Void)? = nil
    ) {
        self.session = session
        self.model = model
        self.structure = structure
        _pages = State(initialValue: PagedReadModel(session: session))
        self.hostsQuietReceipt = hostsQuietReceipt
        self.onWake = onWake
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }
    private var page: ReadingPageTokens { scheme == .dark ? .dark : .light }
    private var appearance: PagedReadModel.PageAppearance {
        PagedReadModel.PageAppearance(
            ink: NSColor(page.ink), chapterInk: NSColor(page.chapterInk),
            meta: NSColor(page.pageMeta), codeTint: NSColor(page.codeTint))
    }

    /// Which posts OPEN a chapter — the only structural input pagination
    /// takes. The grouping itself is `BookStructureModel.grouped`, rendered
    /// here and never re-decided (the standing rule for every book surface).
    private var chapterOpeners: [String: String] {
        guard structure.chaptersActive else { return [:] }
        var openers: [String: String] = [:]
        for group in structure.grouped(entries: model.entries) {
            guard let section = group.section, let first = group.entries.first else { continue }
            openers[first.postID] = section.name
        }
        return openers
    }

    var body: some View {
        VStack(spacing: 0) {
            if model.entries.isEmpty {
                Spacer()
                Text("This book has no notes yet.")
                    .foregroundStyle(tokens.muted)
                Spacer()
            } else {
                spread
            }
        }
        // 13u2 UNIT B (her item 19): the leaves' room is the voice's own,
        // never a palette's.
        .background(ReadingPageTokens.room(voice: tokens.voice, dark: scheme == .dark))
        .safeAreaInset(edge: .bottom) { flipBar }
        .task {
            pages.appearance = appearance
            // 13f W21: a mode switch's landing outranks the book's focus —
            // it IS where she was in the mode she just left. `consumeReveal`
            // before `adopt` so a later delivery cannot re-land it.
            let landing = model.pendingReveal
            if landing != nil { model.consumeReveal() }
            pages.seed(fromFocus: landing ?? model.focusedPostID)
            await pages.adopt(entries: model.entries, chapterOpeners: chapterOpeners)
            model.notePagedAnchor(pages.currentPostID)
        }
        // 13f W21: a reveal arriving while Pages is already on screen.
        .onChange(of: model.pendingReveal) { _, reveal in
            guard let reveal else { return }
            model.consumeReveal()
            pages.showPost(reveal)
        }
        // 13f W21 — THE REPORT, not a decision: the paginated reader owns
        // its own model, so its (post, page-in-post) address has to travel
        // one step to be readable by the carry. Leaving Read ▸ Pages then
        // lands the next mode on the post she was actually reading.
        .onChange(of: pages.currentPostID) { _, postID in
            model.notePagedAnchor(postID)
        }
        .onChange(of: model.entries.map(\.postID)) { _, _ in
            Task { await pages.adopt(entries: model.entries, chapterOpeners: chapterOpeners) }
        }
        .onChange(of: scheme) { _, _ in pages.appearance = appearance }
        // The navigator's post rows jump this surface too (2B's rule: a post
        // already on the spread is left where it is).
        .onChange(of: model.focusedPostID) { _, focused in
            if let focused { pages.showPost(focused) }
        }
        .overlay(alignment: .bottom) {
            if let error = pages.lastError {
                Text(error)
                    .font(tokens.small)
                    .alarmVoice()
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
    }

    // MARK: - The spread (two leaves of paper)

    private var spread: some View {
        GeometryReader { proxy in
            let scale = pages.geometry.spreadScale(
                in: CGSize(width: proxy.size.width - 48, height: proxy.size.height - 32),
                spine: 18)
            HStack(spacing: 18) {
                ForEach(Array(pages.leaves.enumerated()), id: \.offset) { _, leaf in
                    PageLeafView(
                        leaf: leaf, geometry: pages.geometry, scale: scale,
                        page: page, appearance: appearance,
                        dark: scheme == .dark,
                        onBlockClick: leaf.map { leaf in
                            { blockID in onWake?(leaf.postID, blockID) }
                        })
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - The bottom bar (KEPT by the brief; the slider is the brief's)

    @ViewBuilder
    private var flipBar: some View {
        if !model.entries.isEmpty {
            HStack(spacing: 10) {
                Button("◀") { pages.turn(by: -2) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(.leftArrow, modifiers: [])
                    .disabled(!pages.canTurn(by: -2))
                    .help("Turn the leaf back — two pages (←)")
                Slider(
                    value: Binding(
                        get: { pages.scrubFraction },
                        set: { pages.scrub(fraction: $0) }),
                    in: 0...1)
                    .frame(minWidth: 120, maxWidth: 460)
                    .help("Scrub through the book — the page domain is estimated "
                        + "until a page has been read")
                Button("▶") { pages.turn(by: 2) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(.rightArrow, modifiers: [])
                    .disabled(!pages.canTurn(by: 2))
                    .help("Turn the leaf on — two pages (→)")
                Spacer(minLength: 12)
                // WA-1: the quiet slot at the bar's trailing end, before the
                // page line (the Bookcase hint bar's shape — it yields first).
                QuietReceiptLine(status: session.status, tokens: tokens, separated: true)
                    .opacity(hostsQuietReceipt ? 1 : 0)
                    .accessibilityHidden(!hostsQuietReceipt)
                Text(tokens.chromeLabel(pages.pageLine))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(.bar)
        }
    }
}
