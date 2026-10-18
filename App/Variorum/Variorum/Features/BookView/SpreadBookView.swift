//
//  SpreadBookView.swift
//  Variorum
//
//  The BOOK mode — 13c Batch 2B (ledger A43/A44), from her direction of
//  2026-07-23/24: *"basically like [today's] Pages but with two posts side
//  by side… new compared to what we have"*, *"more like a lens column, for
//  comparison."*
//
//  **Each page is a WHOLE POST, vertically scrollable and fully contained —
//  a post does NOT flow across pages.** That is what distinguishes Book from
//  Read: Book paginates by POST, Read paginates by TEXT. The page domain is
//  therefore the POST LIST (`BookViewModel.spreadLeftIndex`), never live TK2
//  geometry — the Phase 6 memo's model-driven ruling, Stage 4 lesson 8.
//
//  Flip navigation (ruled 2026-07-24): the default TURNS THE LEAF — two
//  posts at once — beside a single-step control (her sketch, *"a half arrow
//  button or something"*) that nudges the spread by ONE post, so a turn that
//  splits two posts she wanted side by side can be re-paired. Arrows
//  navigate too. The bottom bar STAYS here (unlike Outline, where A6 removed
//  it), and it carries the JUMP SCRUBBER: 2B removed the slider on the
//  brief's instruction, flagged the conflict with her own S4-9(2) ask as
//  QUESTIONS #44(c), and she RULED it back at the 13c ratify walk
//  (#44(c)/#45(c), 2026-07-27) — scrubbers on BOTH horizontal surfaces,
//  Book's spread and Read's Pages; Outline keeps none, because her A6
//  complaint was a horizontal control on a VERTICAL page. Its domain is the
//  POST LIST like every other jump here, never live TK2 geometry.
//
//  EDITABLE, in TWO forms (A44, her instruction: *"stack view + the normal
//  write view should be the editing forms offered"*): the ACTIVE page shows
//  either the takes STACK (`TakesBoardView`) or normal WRITE
//  (`EditorView(inline:)`); the other page stays read-cheap.
//
//  **Why exactly ONE page is editable at a time** (the batch's load-bearing
//  architectural finding, traced rather than assumed): P3's one-live-editor
//  rule is not a slogan here — mounting two `TakesBoardView`s would create
//  (a) two `PaneTextAuthority` owners, and the one-live-ring invariant is
//  enforced INSIDE one authority, so two boards can wear two rings, and
//  (b) two routed-command handlers, which the router resolves LIFO — ⌘S and
//  every take act would reach whichever board mounted last rather than the
//  one under her hands (the N5/D3 class). So the spread has ONE active page
//  (`BookViewModel.focusedPostID`, the book surface's existing single focus
//  authority — 13b 3E's fold, the same one Outline uses), it mounts the
//  chosen form, and its sibling renders `ReadPostView`. Clicking the sibling
//  migrates the ring: exactly the read-cheap/edit-focused split every other
//  surface already has, with two posts on screen instead of one.
//

import SwiftUI
import VariorumCore

struct SpreadBookView: View {
    let session: AppSession
    let model: BookViewModel
    let structure: BookStructureModel
    /// 13i-d U4 — the archived line atop the spread (nil composes nothing —
    /// a pin over the spread alone). 17y B3 (h): the Arrivals line it sat
    /// under moved to the masthead's door.
    var archived: BookArchivedModel? = nil
    /// WA-1 (the 13n-a walk): this mode's flip bar is the book's MAIN bottom
    /// bar, so its trailing end hosts the quiet receipt — when
    /// `BookNoteBox.quietReceiptHome` says so (one receipt never draws twice).
    var hostsQuietReceipt: Bool = true
    /// VX-303: the page header's "open ↗" — the book's ONE open door
    /// (`BookView.openInWrite`), which carries her place in that note. A host
    /// without the book's road (a pin over the spread alone) passes nothing.
    var onOpenInWrite: (String) -> Void = { _ in }

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// Arrows navigate — but ONLY while no page holds the live editor.
    /// A key equivalent is checked before the responder chain, so a
    /// permanent ◀/▶ equivalent would steal the arrow keys from the text
    /// she is typing in; conditioning it on liveness means the editor keeps
    /// every key it needs and the reading posture keeps its page turns.
    private func flipShortcut(_ key: KeyEquivalent, _ modifiers: EventModifiers)
        -> KeyboardShortcut? {
        // 13f batch 4: and never from an UNFOCUSED pane — a key equivalent
        // is checked before the responder chain, so a spread sitting beside
        // the pane she is typing in would otherwise steal the arrow keys.
        model.paneFocused && model.focusedPostID == nil
            ? KeyboardShortcut(key, modifiers: modifiers) : nil
    }

    var body: some View {
        VStack(spacing: 0) {
            // 13i-d U4: the archived line atop the spread (zero height when
            // empty). 17y B3 (h): the Arrivals line LEFT — the masthead door.
            if let archived {
                BookArchivedLine(model: archived, structure: structure)
            }
            if model.spreadEntries.isEmpty {
                Spacer()
                Text("This book has no notes yet.")
                    .foregroundStyle(tokens.muted)
                Spacer()
            } else {
                HStack(spacing: 0) {
                    page(model.leftPage)
                    // The spine.
                    Divider().overlay(tokens.line)
                    page(model.rightPage)
                }
            }
        }
        .safeAreaInset(edge: .bottom) { flipBar }
        .onAppear {
            model.seedSpreadFromFocus()
            landReveal()
        }
        // 13f W21: a reveal arriving while the spread is already on screen
        // (W20's ascent into an open book).
        .onChange(of: model.pendingReveal) { _, _ in landReveal() }
    }

    /// THE SPREAD'S HALF of W21's landing. `showPost` is the standing jump
    /// and its standing rule holds unchanged: a post already on the spread
    /// is left exactly where it is, so arriving at a page you are already
    /// reading never re-shuffles the pairing.
    private func landReveal() {
        guard let postID = model.pendingReveal else { return }
        model.consumeReveal()
        model.showPost(postID)
    }

    // MARK: - A page (a whole post, contained)

    @ViewBuilder
    private func page(_ entry: Queries.ReadingEntry?) -> some View {
        if let entry {
            SpreadPage(
                session: session, model: model, entry: entry, tokens: tokens,
                chapter: chapterName(entry), onOpenInWrite: onOpenInWrite)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // The blank leaf: an odd book ends on a single page rather than
            // wrapping a post round from the other end (a blank leaf is
            // honest about where the book stops).
            VStack {
                Spacer()
                Text(tokens.chromeLabel("end of the book"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(tokens.surface)
        }
    }

    // MARK: - The bottom bar (KEPT here by ruling — WITH the jump scrubber)

    @ViewBuilder
    private var flipBar: some View {
        if !model.entries.isEmpty {
            HStack(spacing: 8) {
                Button("◀") { model.turnLeaf(by: -1) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(flipShortcut(.leftArrow, []))
                    .disabled(!canMove(-2))
                    .help("Turn the leaf back — two notes at once (←)")
                Button("◁") { model.nudgeSpread(by: -1) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(flipShortcut(.leftArrow, .option))
                    .disabled(!canMove(-1))
                    .help("Nudge back by ONE note — re-pair the two pages (⌥←)")
                // THE JUMP SCRUBBER — back beside the leaf-turn controls by
                // her ruling (#44(c)/#45(c), 13c ratify walk): one rule for
                // both horizontal surfaces, so Book carries a scrubber like
                // Read's Pages does. (Outline still carries none — her A6
                // complaint was a horizontal control on a VERTICAL page.)
                // The domain is the POST LIST: 40 posts are 40 pages, however
                // long any of them is (Stage 4 lesson 8).
                Slider(
                    value: Binding(
                        get: { model.spreadScrubFraction },
                        set: { model.scrubSpread(fraction: $0) }),
                    in: 0...1)
                    .frame(minWidth: 120, maxWidth: 460)
                    .disabled(model.entries.count < 2)
                    .help("Jump through the book — the scrub domain is the "
                        + "note list, one page per note")
                Button("▷") { model.nudgeSpread(by: 1) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(flipShortcut(.rightArrow, .option))
                    .disabled(!canMove(1))
                    .help("Nudge on by ONE note — re-pair the two pages (⌥→)")
                Button("▶") { model.turnLeaf(by: 1) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(flipShortcut(.rightArrow, []))
                    .disabled(!canMove(2))
                    .help("Turn the leaf on — two notes at once (→)")
                Spacer(minLength: 12)
                // The page line reads TRAILING now that the scrubber holds
                // the bar's flexible middle — the arrangement Read's Pages
                // bar already uses, so the two horizontal surfaces read as
                // one thing (the point of her one-rule-for-both ruling).
                // WA-1: the quiet slot before it, at the bar's trailing end
                // (the Bookcase hint bar's shape — it yields first).
                QuietReceiptLine(status: session.status, tokens: tokens, separated: true)
                    .opacity(hostsQuietReceipt ? 1 : 0)
                    .accessibilityHidden(!hostsQuietReceipt)
                Text(tokens.chromeLabel(pageLine))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                Divider().frame(height: 14).overlay(tokens.line)
                // A44 — the page you write in shows Write, or the takes
                // stack. ONE control for the spread: the forms are what the
                // VIEW offers (her sentence), not a property of a post.
                // PROVISIONAL, QUESTIONS #44(a).
                Picker("", selection: Binding(
                    get: { model.spreadForm },
                    set: { model.spreadForm = $0 })) {
                    Text(tokens.chromeLabel("Write")).tag(BookViewModel.SpreadForm.write)
                    Text(tokens.chromeLabel("Takes")).tag(BookViewModel.SpreadForm.takes)
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
                .help("How the page you're writing in presents itself — the ordinary "
                    + "Write editor, or that note's takes")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(.bar)
        }
    }

    private func canMove(_ posts: Int) -> Bool {
        BookViewModel.canMove(
            by: posts, leftIndex: model.spreadLeftIndex, count: model.entries.count)
    }

    /// "pages 3–4 of 40" — read straight off the post-list index (no
    /// visibility reporting, no geometry). Deliberately TEXT and not a
    /// `ProgressView`: she ruled the book's progress bar out for now
    /// ("it seems a bit buggy… remove it fully for now"), and a spread whose
    /// position is exactly known does not need one to say where it is.
    private var pageLine: String {
        let total = model.entries.count
        let left = model.spreadLeftIndex + 1
        let numbers = model.rightPage == nil ? "page \(left)" : "pages \(left)–\(left + 1)"
        var line = "\(numbers) of \(total)"
        if let title = model.leftPage.map(spreadEntryTitle) {
            line += " — \(title)"
            if let right = model.rightPage.map(spreadEntryTitle) { line += " · \(right)" }
        }
        return line
    }

    /// The page's chapter context (curated books with chapters): the
    /// membership's live section name, read from the structure model's
    /// observed assignments — a dangling pointer reads as unsectioned,
    /// exactly like everywhere else.
    private func chapterName(_ entry: Queries.ReadingEntry) -> String? {
        guard structure.chaptersActive,
              let sectionID = structure.assignments[entry.postID]
        else { return nil }
        return structure.sections.first { $0.id == sectionID }?.name
    }
}

#if DEBUG
/// 13c 2B's realization pin support (the `BookOutlineMaterialization`
/// precedent, Stage 4 lesson 6): counts `SpreadPage` materializations so the
/// P3 pin can assert the spread realizes THE SPREAD, never the book.
@MainActor
enum BookSpreadMaterialization {
    static var count = 0
}
#endif

/// One page of the spread: a whole post, contained and vertically
/// scrollable. The ACTIVE page (the book's one focused post) shows the
/// chosen editing form; its sibling stays read-cheap and upgrades on click,
/// which is how the ring migrates between the pages (P3).
private struct SpreadPage: View {
    let session: AppSession
    let model: BookViewModel
    let entry: Queries.ReadingEntry
    let tokens: VoiceTokens
    let chapter: String?
    /// VX-303: the header's "open ↗" (`BookView.openInWrite`).
    let onOpenInWrite: (String) -> Void

    init(
        session: AppSession, model: BookViewModel, entry: Queries.ReadingEntry,
        tokens: VoiceTokens, chapter: String?, onOpenInWrite: @escaping (String) -> Void
    ) {
        self.session = session
        self.model = model
        self.entry = entry
        self.tokens = tokens
        self.chapter = chapter
        self.onOpenInWrite = onOpenInWrite
        #if DEBUG
        BookSpreadMaterialization.count += 1
        #endif
    }

    /// 13f batch 4: the pane's focus folds in through `liveFocusedPostID` —
    /// a spread in an unfocused pane mounts no editable page.
    private var isActive: Bool { model.liveFocusedPostID == entry.postID }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(tokens.line)
            pageBody
        }
        .background(tokens.surface)
    }

    private var header: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                if let chapter {
                    Text(tokens.chromeLabel(chapter))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                }
                HStack(spacing: 6) {
                    Text(spreadEntryTitle(entry))
                        .font(tokens.heading)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                    if let date = entry.entryDate {
                        Text(date)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(1)
                    }
                }
            }
            Spacer()
            // VX-303: the book's ONE open door — her place rides it.
            Button(tokens.chromeLabel("open ↗")) { onOpenInWrite(entry.postID) }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .help("Open this note in the full editor (Write · Takes · Lenses · …)")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    /// The page body. The takes board brings its own scrolling (and its own
    /// bottom bar), so it is never wrapped in the page's ScrollView; Write
    /// and the read tier are content-sized and are.
    @ViewBuilder
    private var pageBody: some View {
        if isActive, model.spreadForm == .takes {
            // THE one takes board (see the file header for why only the
            // active page may mount one).
            TakesBoardView(session: session, postID: entry.postID)
                .id("spread-takes-\(entry.postID)")
        } else {
            ScrollView {
                Group {
                    if isActive {
                        // THE one live editor — the full-document editor,
                        // exactly as Outline mounts it (its identity
                        // machinery, its autosave, its routed acts).
                        //
                        // 18d batch 1 (her U-10, her own words about THIS
                        // mode: *"even when you're in the book editing mode
                        // (where you scroll through notes and each note is a
                        // page but you can edit) … it won't be at the bottom"*):
                        // the bar renders in the sidebar's note box, not in
                        // the page. It used to sit under the prose INSIDE this
                        // page's scroll, which is why it read as a card
                        // floating mid-page on a short note.
                        EditorView(
                            session: session, postID: entry.postID, inline: true,
                            caretSeed: model.caretSeed, fanSeed: model.fanSeed,
                            barPlacement: .inSidebarBox,
                            // 13u3 UNIT A1: the page's 20 pt padding becomes
                            // the surface's gutter; the prose keeps this
                            // page's leading anchor and its measure exactly.
                            gutter: .page)
                            .id(entry.postID)
                    } else {
                        ReadPostView(
                            session: session, postID: entry.postID,
                            gutter: .page,
                            onFocusRequest: { offset in
                                model.focus(entry.postID, caret: offset)
                            },
                            onBadgeTap: { blockID in
                                model.focus(entry.postID, fanBlock: blockID)
                            })
                            .id("spread-read-\(entry.postID)")
                    }
                }
                .frame(maxWidth: BookView.proseColumn, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            // A new page is a new scroll — never the old page's offset.
            .id("spread-scroll-\(entry.postID)-\(isActive)")
        }
    }
}

/// A page's display title — the book surfaces' shared rule (13g batch 7,
/// R6-3: the ONE display brain).
private func spreadEntryTitle(_ entry: Queries.ReadingEntry) -> String {
    entry.displayTitle
}
