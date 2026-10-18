//
//  PoolPostsView.swift
//  Variorum
//
//  Phase 13, B2 — THE POOL (R29/R44): "an area for posts that do not
//  belong to any book", top-level by her ruling ("when you make a random
//  post, that's where it goes, and it's still easier to find and see").
//  Its PURPOSE is drainage: every row offers Add-to-Book and the addable
//  tags surface (R46) so floating posts move down into books. The listing
//  is a QUERY over membership — nothing maintains a pool state.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class PoolPostsModel {
    @ObservationIgnored let session: AppSession
    /// The Pool's LOOSE notes — bookless and shown by no gathering (13i-b U4:
    /// the split's own class; the rows the page always lists).
    private(set) var posts: [Queries.TimelineItem] = []
    /// 13i-b U4 — THE TUCK (the sitting record §8; lesson 10): the bookless
    /// notes some gathering shows, tucked behind the masthead count. Rows are
    /// windowed like `posts`; the counts are exact.
    private(set) var tucked: [Queries.TimelineItem] = []
    private(set) var looseCount = 0
    private(set) var tuckedCount = 0
    /// Is the tucked run showing? VIEW state — off on every visit, never
    /// remembered (PROVISIONAL P-13ib-U4-4), the Arrivals expansion's rule.
    private(set) var showsTucked = false
    /// 13e E8: whole tags, like the Library's — the chips need the id to
    /// take one off (`TagChips` carries the reasoning).
    private(set) var postTags: [String: [Tag]] = [:]
    /// Row 87 (the Act 10 correction round, batch G — R-cor-11(2)): the
    /// listed notes' first words, from the note picker's OWN road
    /// (`Queries.notePickerNotes(ids:)` — one brain, no second rule),
    /// keyed by note. Shown under a TITLELESS card's day (the rule is
    /// `PoolCardFace.preview`); 13u2 item 4 still designs the one-brain
    /// card family later.
    private(set) var snippets: [String: String] = [:]
    private(set) var lastError: String?
    /// **VX-268 — who reaches each DRAWN note now** (the ONE icon on the Pool's
    /// rows — her kickoff call: "Pool rows … IN"): `Queries.mcpNoteReaches`
    /// over `drawnIDs` — ∝ the Pool's own window (`window` loose rows, plus the
    /// tucked run while it shows), held while the page shows.
    private(set) var reach: [String: [MCPPlaceReach]] = [:]

    /// Bounded like every held listing (the observeLibrary discipline).
    nonisolated static let window = 200

    /// 13i-c U4 (§4 row 16): the drainage door's ownership CHOICE — the one
    /// shared road. A Pool note is bookless, so the plain add is the common
    /// case; the choice meets only a note claimed since the listing was read.
    @ObservationIgnored let membershipDoors: MembershipDoors

    init(session: AppSession) {
        self.session = session
        self.membershipDoors = MembershipDoors(session: session)
    }

    func start() async {
        // 13i-d U5: the CURRENT WING's bookless notes (the Pool of THIS
        // library); the view restarts this task when the wing switches.
        let wing = session.wing.currentID
        do {
            for try await value in session.database.observe({ db in
                try Queries.notePoolListing(db, window: Self.window, wingID: wing)
            }) {
                await adopt(value)
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// One delivered split, adopted — the observation's body, and the pins'
    /// seam (a hosted `.task` does not fire under the test host).
    func adopt(_ listing: Queries.PoolListing) async {
        posts = listing.loose
        tucked = listing.tucked
        looseCount = listing.looseCount
        tuckedCount = listing.tuckedCount
        await loadTags()
    }

    /// The masthead's one click: show the tucked notes, or tuck them away.
    func toggleTucked() async {
        showsTucked.toggle()
        await loadTags()
    }

    /// **Open the tucked run, idempotently** (13s-b U2, F-U2-W-2 — the
    /// tour's leg 3: her starred note is tucked, and the leg's door is on its
    /// row). The masthead's "show" is a TOGGLE; this only ever opens, so a
    /// second ask never closes what the first opened. Leaving the page still
    /// tucks it away (`tuckAway`), exactly as every visit does.
    func showTucked() async {
        guard !showsTucked else { return }
        await toggleTucked()
    }

    /// Leaving the page tucks the run away again — a fresh visit opens
    /// tucked (P-13ib-U4-4). The model is RootView's and outlives the page,
    /// so without this the click outlived the visit (F-U4-3, walk-found).
    func tuckAway() {
        showsTucked = false
    }

    /// The rows the page draws: the loose ones, plus the tucked run while it
    /// shows — so the chips/previews reads stay bounded by what is on screen.
    var drawnIDs: [String] {
        posts.map(\.postID) + (showsTucked ? tucked.map(\.postID) : [])
    }

    /// VX-268 — hold the drawn rows' reach (the view's `.task(id: drawnIDs)`
    /// restarts it when the rows change).
    func holdReach(_ ids: [String]) async {
        await MCPRowReach.hold(session, { try Queries.mcpNoteReaches($0, noteIDs: ids) }) { [weak self] value in
            guard let self, self.reach != value else { return }
            self.reach = value
        }
    }

    private func loadTags() async {
        let ids = drawnIDs
        guard !ids.isEmpty else {
            postTags = [:]
            snippets = [:]
            return
        }
        let read = try? await session.database.read { db in
            (tags: try TagChips.load(db, postIDs: ids),
             // Row 87: the picker's preview road, for the listed ids — bounded
             // by the Pool's own window, one statement.
             snippets: try Queries.notePickerNotes(db, ids: ids))
        }
        postTags = read?.tags ?? [:]
        snippets = Dictionary(
            uniqueKeysWithValues: (read?.snippets ?? []).compactMap { hit in
                hit.snippet.map { (hit.id, $0) }
            })
    }

    /// 17y B3 item (o) — the add picker's INLINE MINT: a plain book, then the
    /// one membership road (the consult and the gate are the add's own); an
    /// ownership refusal opens the choice sheet. Other refusals speak here.
    func mintBook(_ typed: String, adding postID: String) async {
        do {
            _ = try await membershipDoors.mintAndAdd(typed, postID: postID)
            lastError = nil
        } catch let error as OperationError {
            lastError = ReadingsViewModel.message(error)
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The drainage gesture: into a book (the pool row's whole point). Through
    /// the one membership road (13i-c U4): an ownership refusal OPENS the
    /// choice sheet (P-2) rather than ending in words.
    func addToBook(_ postID: String, readingID: String) async {
        do {
            try await membershipDoors.addOrOffer(postID, to: readingID)
            lastError = nil
        } catch let error as OperationError {
            if case .alreadyInReading = error { return }
            lastError = ReadingsViewModel.message(error)
        } catch {
            lastError = String(describing: error)
        }
    }

    func applyTag(_ tagID: String, to postID: String) async {
        do {
            try await session.runner.run { ops in
                do {
                    try ops.applyTag(tagID, toPost: postID)
                } catch OperationError.alreadyTagged {}
            }
            await loadTags()
        } catch {
            lastError = TagsViewModel.message(error)
        }
    }

    /// 13e E8 — the Library's two doors, on the pool's rows. Same reasoning,
    /// same one implementation: adding rides the shipped type-to-create door
    /// (13b 3D's N24, the context bar's `＋`), removing is the ops call with
    /// batch semantics. The pool listing is the OTHER half of the R46
    /// surface her round-11 ask named, so a different grammar here would be
    /// exactly the second tag mechanism this work exists to avoid.
    func applyTypedPath(_ raw: String, to postID: String) async {
        let door = TagAssignmentViewModel(session: session, postID: postID)
        if await door.applyTypedPath(raw) == nil {
            lastError = door.lastError
        } else {
            lastError = nil
        }
        await loadTags()
    }

    func removeTag(_ tagID: String, from postID: String) async {
        do {
            try await session.runner.run { ops in
                do {
                    try ops.removeTag(tagID, fromPost: postID)
                } catch OperationError.tagNotApplied {}
            }
            await loadTags()
        } catch {
            lastError = TagsViewModel.message(error)
        }
    }
}

struct PoolPostsView: View {
    /// 13e E8: the pool rows' tag doors — the THIRD renderer of the one
    /// `.tagNote` act (the context bar's cards and the Library's rows are
    /// the others), declared so the `.surface` walk covers them.
    static let surfaceCapabilities: [CapabilityID] = [.tagNote]
        // 13n-c U4: a note row's pending-ask glyph.
        + MCPAskGlyph.surfaceCapabilities
        // VX-268: the ONE shared icon on a note row and its popover's doors.
        + MCPSharedIcon.surfaceCapabilities

    let session: AppSession
    let model: PoolPostsModel
    /// **P39a (the pre-13u round, Act 2's sweep; fixed at 13u2 UNIT D).**
    /// This used to be `let library: LibraryViewModel` — a feature holding a
    /// REFERENCE to a sibling feature's view model, which is the cross-feature
    /// rule's own wording after its 2026-08-30 refinement ("never holds a
    /// reference to one, never calls its business logic"). The sweep measured
    /// 57 candidate sites and found exactly two real violations; this is one.
    ///
    /// The refined rule's stated REASON is what the shape below answers: a
    /// cross-feature view-model reference destroys testability and isolation
    /// (lifecycle entanglement, hidden mutation paths, an un-mockable seam) —
    /// so Pool now receives two CLOSURES and `RootView` passes the Library's
    /// methods into them. The acts are byte-identical; what changes is that
    /// the Pool no longer knows a `LibraryViewModel` exists, and a pin can
    /// hand it two closures instead of a whole sibling.
    /// VX-372: the duplicate act, with her tag choice (the parent's —
    /// `LibraryViewModel.duplicateAsVersion(postID:tags:)`, P39a).
    let onDuplicateAsVersion: (String, Operations.DuplicateTags) async -> Void
    let onArchive: (String) async -> Void
    let readings: ReadingsViewModel
    let tags: TagsViewModel
    let onOpen: (SidebarSelection) -> Void
    /// 13f batch 4 (W1/A25): the split's row door.
    var onOpenBeside: ((String) -> Void)? = nil
    /// 13f batch 5b (W2/A26): the note-only window's row door.
    var onOpenInNewWindow: ((String) -> Void)? = nil
    /// 13f batch 6 (W4): the star door, from the one note-row grammar.
    var starDoor: StarDoor? = nil
    /// 13i-d U5: the cross-wing note doors' brain (owned by the composition
    /// root); nil in harness mounts — the doors are then not drawn.
    var wings: WingsModel? = nil

    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    /// 13l Act 2 (item 3): the pending delete ask, in the one shared host.
    @State private var pendingDelete: NoteDeleteConfirm?
    /// 13i-d U5: the move's confirm (the books the note would leave).
    @State private var wingMove: WingsModel.MoveAsk?

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// pre-13u Act 10 wave 2b (item 2): which note the Add-to-Book picker
    /// was opened FOR — a value the sheet presents.
    struct BookPickTarget: Identifiable, Equatable {
        let postID: String
        var id: String { postID }
    }

    @State private var bookPickTarget: BookPickTarget?

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(tokens.path(["Pool"]))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
                // 13i-b U4 — her masthead shape, the sitting record §8:
                // "Pool · 2 notes · 14 in gatherings · show".
                Text(tokens.chromeLabel(
                    PoolTuckCopy.masthead(loose: model.looseCount, tucked: model.tuckedCount)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                if model.tuckedCount > 0 {
                    Button(tokens.chromeLabel(PoolTuckCopy.toggle(showing: model.showsTucked))) {
                        Task { await model.toggleTucked() }
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                    .help(PoolTuckCopy.toggleHelp(showing: model.showsTucked))
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            Divider().overlay(tokens.line)
            // Item 2 + the W8-2 restyle: the hairline List retires for calm
            // cards — the mockup's card/metadata-chip grammar (her granted
            // latitude: chips on the metadata line, not a tag column; the
            // column judged in place and not missed — the chips ARE doors,
            // which a column of text could not be).
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    if let empty = PoolTuckCopy.empty(loose: model.looseCount, tucked: model.tuckedCount) {
                        // 13i-b U4: an empty-but-gathered Pool SAYS so (§8) —
                        // never "the pool is empty" over tucked notes. First,
                        // under the masthead whose count it explains.
                        Text(tokens.chromeLabel(empty))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    // The tucked run, on her click — at the TOP, right under the
                    // masthead that opened it (walk-found F-U4-5: at the bottom
                    // it drowned under a long Pool, the very reason §8 moved the
                    // count to the masthead). The Library's quiet section-label
                    // idiom (gray words over a hairline) names both runs.
                    if model.showsTucked, !model.tucked.isEmpty {
                        sectionLabel(PoolTuckCopy.tuckedSection, first: true)
                        ForEach(model.tucked, id: \.postID) { item in
                            row(item, tucked: true)
                        }
                        if !model.posts.isEmpty {
                            sectionLabel(PoolTuckCopy.looseSection, first: false)
                        }
                    }
                    ForEach(model.posts, id: \.postID) { item in
                        row(item, tucked: false)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
        .background(tokens.surface)
        .task(id: model.session.wing.currentID) { await model.start() }
        // VX-268: who reaches the drawn rows — held, re-aimed as they change.
        .task(id: model.drawnIDs) { await model.holdReach(model.drawnIDs) }
        .wingMoveConfirm($wingMove, wings: wings)
        .onDisappear { model.tuckAway() }
        #if DEBUG
        .onAppear { recordMasthead() }
        .onChange(of: PoolTuckProbe.Face(model)) { _, _ in recordMasthead() }
        .onDisappear { PoolTuckProbe.forgetFace() }
        #endif
        .deleteNoteConfirmDialog($pendingDelete) { confirm in
            NoteDeletion.fire(session: session, postIDs: confirm.postIDs)
        }
        // 13i-c U4 (§4 row 16): the add's ownership choice, the one road.
        .membershipChoices(model.membershipDoors)
        // Item 2's ruled door: the every-row "Add to Book ▾" dropdown
        // retires for the ONE searchable picker (item 14's component); the
        // CAPABILITY is byte-identical — the pick fires the same
        // `model.addToBook`, and the standing gate's refusals still speak.
        .sheet(item: $bookPickTarget) { target in
            NotePickerSheet(
                tokens: tokens,
                title: "Add to Book",
                prompt: "search books",
                emptyState: "No books match.",
                source: .curatedBooks(readings.readings),
                onPick: { row in
                    Task { await model.addToBook(target.postID, readingID: row.id) }
                },
                // 17y B3 item (o): the same idiom's INLINE MINT — 'New book
                // "X"' makes a plain book and adds the note through the one
                // membership road (`MembershipDoors.mintAndAdd`).
                createLabel: AddToBookCopy.newBook(_:),
                createKey: AddToBookCopy.key(_:),
                onCreate: { typed in
                    Task { await model.mintBook(typed, adding: target.postID) }
                })
        }
        .overlay(alignment: .bottomLeading) {
            if let error = model.lastError {
                Text(error)
                    .font(tokens.small)
                    .alarmVoice()
                    .textSelection(.enabled)
                    .padding(6)
            }
        }
    }

    private func sectionLabel(_ words: String, first: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(tokens.chromeLabel(words))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(1)
            Rectangle().fill(tokens.line).frame(height: 1)
        }
        .padding(.top, first ? 4 : 14)
        .padding(.horizontal, 4)
    }

    #if DEBUG
    private func recordMasthead() {
        PoolTuckProbe.recordFace(
            masthead: PoolTuckCopy.masthead(loose: model.looseCount, tucked: model.tuckedCount),
            toggle: model.tuckedCount > 0 ? PoolTuckCopy.toggle(showing: model.showsTucked) : nil,
            empty: PoolTuckCopy.empty(loose: model.looseCount, tucked: model.tuckedCount),
            tuckedSection: model.showsTucked && !model.tucked.isEmpty,
            looseSection: model.showsTucked && !model.tucked.isEmpty && !model.posts.isEmpty)
    }
    #endif

    private func row(_ item: Queries.TimelineItem, tucked: Bool) -> some View {
        // 13u3 UNIT B (her item 4): the ONE brain the Library's rows ask —
        // her name where she typed one, a daily entry's day, else the note's
        // own first words.
        let name = PoolCardFace.card(item, snippet: model.snippets[item.postID])
        return CalmCard(tokens: tokens) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(name.lead.text)
                            .font(tokens.body)
                            .foregroundStyle(tokens.ink)
                            .lineLimit(1)
                        // VX-268: the ONE shared icon (nothing when nobody
                        // reaches it), then a waiting ask — the Bookcase's order.
                        MCPSharedIcon(reaches: model.reach[item.postID] ?? [], tokens: tokens)
                        // 13n-c U4: an ask waiting on this note.
                        MCPAskGlyph(.note(item.postID), tokens: tokens)
                        // The quiet day — suppressed when the lead already IS
                        // the day (the picker's one detail rule). Under item
                        // 4 this is where a words-led card's date lives: the
                        // metadata line, as her ruling says.
                        if let day = NotePickerRanking.detail(
                            title: name.lead.text,
                            day: DisplayTitle.day(fromStamp: item.stamp))
                        {
                            Text(tokens.chromeLabel(day))
                                .font(tokens.small)
                                .foregroundStyle(tokens.faint)
                                .lineLimit(1)
                                // VX-351: the edit's whole fact on hover — the
                                // picker's own rule (this IS its detail).
                                .stampHelp(NotePickerRanking.detailHelp(
                                    title: name.lead.text, entryDate: nil, touchedStamp: item.stamp))
                        }
                    }
                    // Row 87: a titleless card is a wall of bare dates
                    // without this — the words the lead did not take, the
                    // picker's own two-line preview.
                    if let preview = PoolCardFace.preview(name) {
                        Text(preview)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    // 13e E8: the note's own chip grammar (colour · leaf ·
                    // ✕ off · ＋ types one on) — the ruled metadata-line
                    // chips, identical to the Library's rows.
                    NoteTagsRow(
                        tokens: tokens,
                        tags: model.postTags[item.postID] ?? [],
                        allTags: tags.tags,
                        onApply: { path in
                            Task { await model.applyTypedPath(path, to: item.postID) }
                        },
                        onRemove: { tag in
                            Task { await model.removeTag(tag.id, from: item.postID) }
                        })
                }
                Spacer(minLength: 8)
                Button(tokens.chromeLabel("add to book")) {
                    bookPickTarget = BookPickTarget(postID: item.postID)
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                .help("Into a book — the pool's whole point. Search opens; finished books say so.")
                // 13s-b U2: the leg's third stop ("Click into add to book").
                .tourAnchor(.poolAddToBook(item.postID), cornerRadius: 6)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onOpen(.post(item.postID)) }
        .draggable(item.postID)
        #if DEBUG
        .onAppear { PoolTuckProbe.recordRow(item.postID, tucked: tucked) }
        .onDisappear { PoolTuckProbe.forgetRow(item.postID, tucked: tucked) }
        #endif
        .contextMenu {
            Button("Open") { onOpen(.post(item.postID)) }
            if let onOpenBeside {
                Button(WorkspaceNaming.openBesideVerb) { onOpenBeside(item.postID) }
            }
            if let starDoor {
                Button(starDoor.title(for: .post(item.postID))) {
                    starDoor.toggle(.post(item.postID))
                }
            }
            if let onOpenInNewWindow {
                Button(CapabilityRegistry.capability(.openInNewWindow).verb) {
                    onOpenInNewWindow(item.postID)
                }
            }
            // VX-372 (VX-383 U1 — D-C-2): the note-row grammar's two
            // duplicate doors (`SidebarView.contextMenuCapabilities`), the
            // Library's twin — through the parent's act (P39a).
            Button(CapabilityRegistry.capability(.duplicateNoteWithTags).verb) {
                Task { await onDuplicateAsVersion(item.postID, .applied) }
            }
            Button(CapabilityRegistry.capability(.duplicateNoteWithoutTags).verb) {
                Task { await onDuplicateAsVersion(item.postID, .none) }
            }
            // 13i-d U5 — the explicit cross-wing doors (the sitting record §9).
            if let wings {
                WingNoteDoors(
                    wings: wings, postID: item.postID, title: item.displayTitle,
                    onAsk: { wingMove = $0 })
            }
            Divider()
            // Ledger row 25: the same declaration the Library's row renders
            // (`SidebarView.contextMenuCapabilities`), so both say one word.
            Button(CapabilityRegistry.capability(.archiveNote).verb) {
                Task { await onArchive(item.postID) }
            }
            // 13l Act 2 (item 3): the note-row grammar's delete door, with
            // the confirmation her ruling gave the Library's — this row
            // renders the SAME declaration (`SidebarView.contextMenuCapabilities`)
            // and must therefore ask the same question in the same words.
            Button(RecoveryCopy.deleteNoteTitle, role: .destructive) {
                Task { pendingDelete = await NoteDeletion.ask(
                    session: session, postIDs: [item.postID]) }
            }
        }
    }
}

/// **The Pool card's two lines.**
///
/// Row 87's rule stands exactly as she gave it (R-cor-11(2): *"a derived line
/// under a titleless card's date"* — a titled card already says what it is);
/// what changed at **13u3 UNIT B** is what the card LEADS with. A titleless
/// card no longer leads with its day and previews its words — it leads with
/// the WORDS (her item 4), the day steps down to the quiet slot beside them,
/// and this line carries on from where the lead stopped. One rule, one brain
/// (`NoteCardFace`), shared with the Library's two renderers; the words are
/// still the note picker's own snippet, never a second derivation.
nonisolated enum PoolCardFace {
    /// What the row's card shows, from the listing's row and the snippet
    /// read beside it.
    static func card(_ item: Queries.TimelineItem, snippet: String?) -> NoteCardFace.Card {
        NoteCardFace.card(
            storedTitle: item.title,
            leadingTexts: [snippet ?? ""],
            isJournal: item.isJournalEntry,
            entryDate: item.entryDate,
            createdAt: item.createdAt)
    }

    /// The line UNDER the lead — nothing at all under a card she named (her
    /// rule), the continuation under a card leading with its own words, and
    /// the words under a card leading with its day.
    static func preview(_ card: NoteCardFace.Card) -> String? {
        guard card.lead.isDerived else { return nil }
        return card.preview.isEmpty ? nil : card.preview
    }
}

/// **THE TUCK'S WORDS, ONE HOME** (13i-b U4 — the sitting record §8, her
/// masthead shape verbatim: "Pool · 2 notes · 14 in gatherings · show"; §25
/// lesson 10). Pure. The count words agree in number ("1 note", "1 in a
/// gathering"); the voice casing is the caller's `chromeLabel`. 13s
/// re-voices all of it (PROVISIONAL P-13ib-U4-5).
nonisolated enum PoolTuckCopy {
    static func notes(_ count: Int) -> String {
        count == 1 ? "1 note" : "\(count) notes"
    }

    static func inGatherings(_ count: Int) -> String {
        count == 1 ? "1 in a gathering" : "\(count) in gatherings"
    }

    /// The words after "Pool": "· 2 notes · 14 in gatherings ·", the toggle
    /// then closing her shape. With nothing tucked, the tuck says nothing.
    static func masthead(loose: Int, tucked: Int) -> String {
        guard tucked > 0 else { return "\u{B7} \(notes(loose))" }
        return "\u{B7} \(notes(loose)) \u{B7} \(inGatherings(tucked)) \u{B7}"
    }

    /// The one click.
    static func toggle(showing: Bool) -> String { showing ? "hide" : "show" }

    static func toggleHelp(showing: Bool) -> String {
        showing
            ? "Tuck the notes that show in gatherings back behind the count."
            : "Notes that show in gatherings tuck behind this count \u{2014} one click lists them here too."
    }

    /// The label over the tucked run while it shows.
    static let tuckedSection = "in gatherings"
    /// The label over the loose run, drawn only while the tucked run shows
    /// above it (the empty state's own noun).
    static let looseSection = "loose notes"

    /// The empty state — nil while loose notes list. An EMPTY-BUT-GATHERED
    /// Pool says so (§8); only a Pool with nothing tucked either says it is
    /// empty.
    static func empty(loose: Int, tucked: Int) -> String? {
        guard loose == 0 else { return nil }
        switch tucked {
        case 0: return "Every note lives in a book. The pool is empty."
        case 1: return "No loose notes \u{2014} the one bookless note shows in a gathering."
        default: return "No loose notes \u{2014} all \(tucked) bookless notes show in gatherings."
        }
    }
}

#if DEBUG
/// **WHAT THE MOUNTED POOL DREW, AS A TEST ORACLE** (the `ArrivalsLineProbe`
/// pattern, for its measured reason: a hosted SwiftUI tree exposes no
/// accessibility children in this test host). The masthead/empty/section facts
/// are recorded from the page's own `onAppear`/`onChange`; each card from its
/// own `onAppear`, cleared on disappear — so an absent row is an honest "not
/// drawn". DEBUG only; the shipping face carries none of it. One Pool page is
/// mounted at a time (the sidebar's one destination), so it is unkeyed.
@MainActor
enum PoolTuckProbe {
    struct Drawn: Equatable {
        var masthead: String?
        var toggle: String?
        var empty: String?
        var tuckedSection = false
        var looseSection = false
        var looseRows: Set<String> = []
        var tuckedRows: Set<String> = []
    }

    /// The facts the masthead/empty state read — `onChange`'s key.
    struct Face: Equatable {
        let loose: Int
        let tucked: Int
        let showing: Bool
        let tuckedRows: Int

        init(_ model: PoolPostsModel) {
            loose = model.looseCount
            tucked = model.tuckedCount
            showing = model.showsTucked
            tuckedRows = model.tucked.count
        }
    }

    private(set) static var drawn = Drawn()

    static func reset() { drawn = Drawn() }

    static func recordFace(
        masthead: String, toggle: String?, empty: String?, tuckedSection: Bool,
        looseSection: Bool
    ) {
        drawn.masthead = masthead
        drawn.toggle = toggle
        drawn.empty = empty
        drawn.tuckedSection = tuckedSection
        drawn.looseSection = looseSection
    }

    static func forgetFace() {
        drawn.masthead = nil
        drawn.toggle = nil
        drawn.empty = nil
        drawn.tuckedSection = false
        drawn.looseSection = false
    }

    static func recordRow(_ postID: String, tucked: Bool) {
        if tucked { drawn.tuckedRows.insert(postID) } else { drawn.looseRows.insert(postID) }
    }

    /// Per class: SwiftUI may mount a card's NEW place before it unmounts the
    /// old one (an untucked note moving runs), so a forget clears only its own.
    static func forgetRow(_ postID: String, tucked: Bool) {
        if tucked { drawn.tuckedRows.remove(postID) } else { drawn.looseRows.remove(postID) }
    }
}
#endif
