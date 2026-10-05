//
//  MembershipChip.swift
//  Variorum
//
//  Phase 13, B3 — the R35 UI REQUIREMENT (her "nail this down", resolved
//  sitting 5): when a post appears in multiple books, the editor SAYS so,
//  and duplicate-as-version is presented as THE way to separate this
//  book's copy from what shows elsewhere. Membership is not ownership:
//  editing a post edits THE post, everywhere (R31).
//
//  Taste-checkpoint fix round (Sitting 9 — R61/R67): the chip is now also
//  the ADD door ("clicking on 'in no book' also doesn't let you easily add
//  it to a book, which it should"): add to any open curated book, remove
//  per book, and after Duplicate-as-Version the copy is one click away —
//  landing in a brand-new post must be unmistakable. The explainer text
//  wraps (the truncation class, dead).
//

import SwiftUI
import VariorumCore

struct MembershipChip: View {
    let session: AppSession
    let postID: String
    /// 13f W20(c): the session's recently-visited books, most recent first —
    /// the chooser floats them within their group (her round-10 shaping).
    /// Defaults empty, so curated-before-smart alone orders a chip mounted
    /// without a workspace (a pin, a future embedding).
    var recentBookIDs: [String] = []

    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    /// 13i-d U2 (KnownIssues row 104): the note's membership, read in ONE
    /// shared place (`NoteMembershipModel`). The note detail hands down the
    /// one it owns (the Book Panel's door reads the same); a standalone mount
    /// (a pin) leaves this nil and the chip tracks its own.
    var membership: NoteMembershipModel? = nil

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var ownMembership = NoteMembershipModel()
    @State private var addableBooks: [Reading] = []
    /// R98 (batch 10): unlocked SMART books join the add list — adding
    /// applies the tags their filter needs (apply-and-report).
    @State private var addableSmartBooks: [Reading] = []
    @State private var popoverShown = false
    @State private var status: String?
    @State private var duplicatedPostID: String?
    /// 13g R1-1 (L17): which BOOK the last copy landed in — set by the
    /// diverge (its receipt names the book), nil for a plain duplicate
    /// (whose copy has no book to name).
    @State private var copyBookName: String?
    /// 13i-c U4 (§4 row 14): the add door's ownership CHOICE — the one shared
    /// road (`MembershipDoors`); its sheet hangs off the chip itself, so it
    /// outlives the popover the Add was pressed in.
    @State private var membershipDoors: MembershipDoors
    /// 13i-c U4 (§20): per GATHERING row, the rule tags this note wears —
    /// the honest "remove #tag" doors (a gathering has no membership).
    @State private var wornRuleTags: [String: [VariorumCore.Tag]] = [:]

    init(
        session: AppSession, postID: String, recentBookIDs: [String] = [],
        membership: NoteMembershipModel? = nil
    ) {
        self.session = session
        self.postID = postID
        self.recentBookIDs = recentBookIDs
        self.membership = membership
        _membershipDoors = State(initialValue: MembershipDoors(session: session))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// The membership in hand — the host's, else the chip's own.
    private var model: NoteMembershipModel { membership ?? ownMembership }

    /// 13f W20(c): the chooser's order is hers (round 10) — curated before
    /// smart, most-recently-visited floating inside each group. Smart
    /// matches ARE listed: derived membership IS membership (round 10 item
    /// 2, #26(h)), and `readingsContaining` has always returned them.
    private var books: [Reading] {
        BookChooserOrder.ordered(model.readings(for: postID), recentlyVisited: recentBookIDs)
    }

    var body: some View {
        Button {
            popoverShown.toggle()
        } label: {
            Text(tokens.chromeLabel(label))
                .font(tokens.small)
                .foregroundStyle(books.count > 1 ? tokens.accent : tokens.muted)
                // Row 80b (the correction round, batch G): on a masthead too
                // narrow for the chip's whole path the chip ELLIPSIZES at
                // its tail rather than pushing the tag cluster (P-8: a chrome
                // label is one line, always).
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .buttonStyle(.borderless)
        .help("Which books hold this note — add it to one, or diverge a copy")
        .popover(isPresented: $popoverShown, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                if books.isEmpty {
                    Text(MembershipChip.headline(bookCount: 0, gatheringCount: 0))
                        .font(.callout)
                } else {
                    // 13i-d U6 (g): books and gatherings counted apart — a
                    // gathering SHOWS the note, it never holds it (§1).
                    Text(MembershipChip.headline(
                        bookCount: memberBookCount, gatheringCount: gatheringCount))
                        .font(.callout.weight(.semibold))
                    ForEach(books, id: \.id) { book in
                        HStack(spacing: 6) {
                            // 13f W20(a) — THE ASCENT, wired. This link has
                            // rendered since Phase 13 and done NOTHING: it
                            // called an OPTIONAL closure that its one mount
                            // (`PostDetailView`) never passed. The optional is
                            // gone rather than filled in, because a door whose
                            // reach depends on a caller remembering to hand it
                            // one is the fire-and-DO class that produced the
                            // bug. It names a destination; the shell decides
                            // what that means (P-4).
                            // 13i-e U2: an archived book is named "(archived)"
                            // (the edge: membership is a fact; visibility is
                            // the book's own state).
                            Button(BookArchiveCopy.name(book)) {
                                popoverShown = false
                                MembershipChip.ascend(bookID: book.id, postID: postID)
                            }
                            .buttonStyle(.link)
                            .help("Open “\(book.name)” at this note")
                            Spacer()
                            // 13f W23 — DIVERGE FOR THIS BOOK, on the row
                            // that names the book. Rendered on every book
                            // row, smart included: a smart target REFUSES
                            // honestly and names the tag road (her ruled
                            // shape — silence where the row looks actionable
                            // is the confusion, not the tidiness).
                            Button("diverge") { diverge(for: book) }
                                .buttonStyle(.borderless)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .help(DivergeCopy.help(book: book.name))
                            // 13i-c U4 — THE REMOVE/RELEASE VOCABULARY (the
                            // sitting record §20): ONE act whose word follows
                            // the book — "release" on an owned book (the note
                            // goes back to the Pool, whole — lesson 5). A
                            // GATHERING has no membership to remove, so it
                            // offers the honest door instead: one "remove
                            // #tag" per rule tag the note wears (`removeTag`).
                            if book.kind == .book {
                                Button(RemoveFromBookCopy.rowWord(owned: book.owned)) {
                                    remove(from: book)
                                }
                                .buttonStyle(.borderless)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .help(RemoveFromBookCopy.help(owned: book.owned, book: book.name))
                            } else {
                                ForEach(wornRuleTags[book.id] ?? [], id: \.id) { tag in
                                    Button(RemoveFromBookCopy.removeTagRowWord(path: tag.path)) {
                                        removeTag(tag, from: book)
                                    }
                                    .buttonStyle(.borderless)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .help(RemoveFromBookCopy.removeTagHelp(gathering: book.name))
                                }
                            }
                        }
                    }
                }
                // R61 — the ADD door, right where "in no book" is read.
                // 17y B3 item (o) — THE SAME PICKER IDIOM + THE INLINE MINT
                // (her ruling at the question tool): type-to-filter over the
                // books (an archived one MARKED, never refused — 13i-e's rider;
                // a gathering joins "by tagging", R98), and the search field
                // doubles as the mint — 'New book "X"' makes a PLAIN book and
                // adds the note through the one membership road (the consult,
                // the gate). Always drawn now: with no other book she can
                // still make one.
                SearchPicker(
                    tokens: tokens, label: AddToBookCopy.verb, prompt: AddToBookCopy.prompt,
                    options: addOptions, emptyText: AddToBookCopy.empty,
                    createLabel: AddToBookCopy.newBook(_:), key: AddToBookCopy.key(_:),
                    onPick: { id in pickBook(id) },
                    onCreate: { typed in mint(typed) },
                    role: .secondary)
                Divider()
                // 13g cold review R1-1 (L17 — her WT-7 round-4 ruling,
                // built at the review after the batches dropped it): the
                // "everywhere it appears" sentence is said only where an
                // elsewhere EXISTS. The round-4 record's own suspicion,
                // verified: nothing gated this line, so a bookless note —
                // including the ORIGINAL right after a diverge moved it out
                // of its only book — read a claim with no referent.
                Text(MembershipChip.explainerLine(bookCount: books.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 280, alignment: .leading)
                Button("Duplicate as Version") {
                    duplicate()
                }
                .help("A full copy — takes and all — as a new note, linked to this one as a version")
                if let status {
                    Text(status)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 280, alignment: .leading)
                }
                if let copy = duplicatedPostID {
                    // R67: landing in a brand-new post must be unmistakable
                    // — the copy is one click away, never hunted for.
                    // 13g R1-1 (L17's receipt half): the button reads as a
                    // RECEIPT of the past act — the diverge's carries the
                    // book that now holds the copy ("tied to the past act
                    // and naming its book", the round-4 disposition's own
                    // words); the plain duplicate's copy has no book, so
                    // its receipt stays bare beside its own status line.
                    Button(DivergeCopy.openCopyLabel(book: copyBookName)) {
                        popoverShown = false
                        NotificationCenter.default.post(
                            name: .variorumOpenPost, object: nil,
                            userInfo: ["postID": copy])
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
            .padding(12)
        }
        // 13i-d U2 (row 104): a standalone chip holds its own observation;
        // under the note detail the host's model is already tracking.
        .task(id: postID) {
            if membership == nil {
                await ownMembership.track(session: session, postID: postID)
            }
        }
        .task(id: postID) { await refresh() }
        .onChange(of: popoverShown) { _, shown in
            if shown { Task { await refresh() } }
        }
        .onChange(of: model.readings(for: postID).map(\.id)) { _, _ in
            Task { await refresh() }
        }
        // 13i-c U4 (§4 row 14): an ownership refusal OPENS the choice (P-2).
        .membershipChoices(membershipDoors) { _ in
            Task { await refresh() }
        }
        #if DEBUG
        // The add door's own function, reachable by a mounted pin (the chip's
        // `@State` is unreachable from outside — the `BindDoorProbe` shape).
        .onAppear { MembershipChipProbe.addDoor = { book in add(to: book) } }
        #endif
    }

    /// Batch 9 (R101): the es line wears the voice's PATH grammar where a
    /// real path exists — "~/orbit" in terminal, "in Orbit" in study; no
    /// book and many books stay plain words.
    private var label: String {
        let memberBooks = books.filter { $0.kind == .book }
        return MembershipChip.label(
            bookNames: memberBooks.map(BookArchiveCopy.name), gatheringCount: gatheringCount
        ) { name in
            tokens.pathPrefix.isEmpty ? "in \(name)" : tokens.path([name])
        }
    }

    private var memberBookCount: Int { books.filter { $0.kind == .book }.count }
    private var gatheringCount: Int { books.filter { $0.kind == .gathering }.count }

    /// **13i-d U6 (g) — F-U3-4, TRACED FIRST.** The chip said "in 2 books"
    /// for a note in ONE book and one GATHERING. The trace: the reader is
    /// HONEST — `Queries.readingsContaining`'s membership arm reads BOOK rows
    /// only (`r.kind = 'book'`, `status = 'member'`, 13i-c F-R1-7's
    /// books-only contract), and it appends each gathering whose RULE shows
    /// the note (the assembly road, deliberately — the chip lists where the
    /// note appears). The word "books" was the lie: a gathering holds no
    /// membership (§1 — "it shows"), so the label counts the two apart.
    /// Pure and static (`explainerLine`'s reason): a promise made inside a
    /// view's closure is a promise no test can keep.
    ///
    /// - no book: "in no book"; one book: its path (`singleBook`); more:
    ///   "in N books";
    /// - any gatherings ride after a dot: "· N gathering(s)" — "appears in N
    ///   gatherings" is the Book Panel's own line (P-13id-U2-12).
    static func label(
        bookNames: [String], gatheringCount: Int, singleBook: (String) -> String
    ) -> String {
        let bookPart: String
        switch bookNames.count {
        case 0: bookPart = "in no book"
        case 1: bookPart = singleBook(bookNames[0])
        default: bookPart = "in \(bookNames.count) books"
        }
        guard gatheringCount > 0 else { return bookPart }
        return bookPart + " \u{00B7} " + gatheringsWord(gatheringCount)
    }

    /// The popover's headline over the rows — books by membership, gatherings
    /// by appearance.
    static func headline(bookCount: Int, gatheringCount: Int) -> String {
        let pool = "This note is in no book \u{2014} it lives in the Pool"
        switch (bookCount, gatheringCount) {
        case (0, 0): return pool + "."
        case (0, let g): return pool + " \u{2014} and appears in \(gatheringsWord(g)):"
        case (let b, 0): return "This note is in \(booksWord(b)):"
        case (let b, let g): return "This note is in \(booksWord(b)) and appears in \(gatheringsWord(g)):"
        }
    }

    private static func booksWord(_ n: Int) -> String { "\(n) book\(n == 1 ? "" : "s")" }
    static func gatheringsWord(_ n: Int) -> String { "\(n) gathering\(n == 1 ? "" : "s")" }

    /// The `.surface` acts this chip renders (P-1's declared ⇔ rendered
    /// walk): W23's per-book diverge door lives on the book rows here — and,
    /// since 13e E11, so does the ASCENT the same rows have carried since
    /// Phase 13 (`ascend`, wired at 13f W20(a)). Both point at the BOOK ROW,
    /// which is what makes them surface acts; the per-row condition stays the
    /// surface's (a row exists only where its book does — the
    /// `.diffAgainstChosen` split, P-2).
    static let surfaceCapabilities: [CapabilityID] = [
        .divergeForBook, .openBookAtNote,
        // 13i-c U4 (§20): the book rows' remove/release door, and a
        // gathering row's honest "remove #tag".
        .removeFromBook, .removeRuleTag,
    ]

    /// 13g cold review R1-1 (L17's explainer half — her WT-7 round-4
    /// ruling): the lead-in above "Duplicate as Version", CONDITIONED on
    /// membership. "Editing here edits the note everywhere it appears" is
    /// R31/R35's truth exactly where the note HAS an elsewhere; a bookless
    /// note gets the door's plain introduction instead, because a claim
    /// with no referent reads as noise (the round-4 record's verified
    /// suspicion). Pure and static for `ascend`'s reason: a promise made
    /// inside a view's closure is a promise no test can keep.
    static func explainerLine(bookCount: Int) -> String {
        bookCount > 0
            ? "Editing here edits the note everywhere it appears. "
                + "To make a separate note that can diverge:"
            : "To make a separate, linked copy of this note:"
    }

    /// 13f W20(a) — THE ASCENT, as a named call rather than a closure body,
    /// for the reason batch 2 moved the ceremony's sentences out of `Text`
    /// literals: **a promise made inside a view's closure is a promise no
    /// test can keep.** This one is pinned.
    static func ascend(bookID: String, postID: String) {
        NotificationCenter.default.post(
            name: .variorumOpenBookAtPost, object: nil,
            userInfo: ["bookID": bookID, "postID": postID])
    }

    /// The popover's EXTRAS — the honest doors' worn tags and the add lists —
    /// re-read on open and whenever the observed membership moves. The
    /// membership itself is the model's held observation (row 104).
    private func refresh() async {
        let membership = model.readings(for: postID)
        // 13i-c U4 (§20): the honest doors' tags, per gathering row.
        let gatherings = membership.filter { $0.kind == .gathering }
        wornRuleTags = (try? await session.database.read { [postID] db in
            var worn: [String: [VariorumCore.Tag]] = [:]
            for gathering in gatherings {
                worn[gathering.id] = try RemoveFromBookDoor.wornRuleTags(
                    db, postID: postID, gathering: gathering)
            }
            return worn
        }) ?? [:]
        let memberIDs = Set(membership.map(\.id))
        // 13i-d U5: the NOTE's wing's books only — a book never spans wings
        // (the op refuses `crossWingMembership`; the chooser never offers it).
        let all = ((try? await session.database.read { [postID] db in
            try Queries.readings(
                db, wingID: try Queries.effectiveWing(db, ofPost: postID) ?? "")
        }) ?? [])
        // Addable = open curated books the post isn't already in.
        addableBooks = all
            .filter { $0.kind == .book && !$0.locked && !memberIDs.contains($0.id) }
        // R98 (supersedes the pre-batch-10 "never pretends to add there"):
        // open smart books too — the add applies the filter's tags.
        addableSmartBooks = all
            .filter { $0.kind == .gathering && !$0.locked && !memberIDs.contains($0.id) }
    }

    /// 17y (o): the add picker's options — the open books the note is not
    /// in (an archived one marked), then the open gatherings "by tagging".
    private var addOptions: [SearchPickerOption] {
        addableBooks.map { book in
            SearchPickerOption(
                id: book.id, label: book.name,
                annotation: book.archivedAt != nil ? BookArchiveCopy.word : nil)
        } + addableSmartBooks.map { book in
            SearchPickerOption(id: book.id, label: book.name, annotation: AddToBookCopy.byTagging)
        }
    }

    /// A pick: a book joins by membership, a gathering by tagging (R98).
    private func pickBook(_ id: String) {
        if let book = addableBooks.first(where: { $0.id == id }) {
            add(to: book)
        } else if let gathering = addableSmartBooks.first(where: { $0.id == id }) {
            collect(into: gathering)
        }
    }

    /// 17y (o) — THE INLINE MINT, through the one membership brain
    /// (`MembershipDoors.mintAndAdd` — the consult and the gate are the add's
    /// own). An ownership refusal closes the popover and opens the choice,
    /// exactly as an existing book's add does.
    private func mint(_ typed: String) {
        Task {
            do {
                switch try await membershipDoors.mintAndAdd(typed, postID: postID) {
                case .added(let name):
                    status = AddToBookCopy.made(name)
                case .offered:
                    popoverShown = false
                }
            } catch {
                status = ChipRefusals.message(for: error, bookName: typed)
            }
            await refresh()
        }
    }

    /// R98 — apply-and-report through `collectPostIntoSmartReading`.
    private func collect(into book: Reading) {
        Task {
            do {
                let result = try await session.runner.run { [postID] ops in
                    try ops.collectPostIntoSmartReading(postID, into: book.id)
                }
                status = result.alreadyMatched
                    ? "Already collected — it matches “\(book.name)”'s filter."
                    : "Added by tagging \(result.appliedTagPaths.map { "#\($0)" }.joined(separator: " ")) — “\(book.name)” collects by filter."
            } catch let error as OperationError {
                if case .smartFilterUnsatisfiable(_, let reason) = error {
                    status = "“\(book.name)” can't take this note: \(reason)"
                } else {
                    status = ChipRefusals.message(
                        for: error, bookName: book.name, sealed: book.sealedAt != nil)
                }
            } catch {
                status = String(describing: error)
            }
            await refresh()
        }
    }

    /// The ADD door (R61) — through the one membership road (13i-c U4, §4
    /// row 14). A plain add lands and says so here; an OWNERSHIP refusal
    /// closes the popover and opens the choice sheet (copy in / move in, or
    /// copy in only — P-2: the refusal opens the ceremony, never ends in
    /// words); any other refusal speaks the chip's own words.
    private func add(to book: Reading) {
        Task {
            do {
                if let choice = try await membershipDoors.add(postID, to: book.id) {
                    popoverShown = false
                    await membershipDoors.offer(choice, postID: postID, readingID: book.id)
                } else {
                    status = "Added to “\(book.name)”."
                }
            } catch {
                status = ChipRefusals.message(
                    for: error, bookName: book.name, sealed: book.sealedAt != nil)
            }
            await refresh()
        }
    }

    /// 13i-c U4 (§20): the one remove/release road — its receipt (or the
    /// op's refusal, named for its book) on the chip's own line.
    private func remove(from book: Reading) {
        Task {
            status = await RemoveFromBookDoor.remove(
                session: session, postID: postID, book: book, speak: false).text
            await refresh()
        }
    }

    /// 13i-c U4 (§20): a gathering's honest door — take the tag off.
    private func removeTag(_ tag: VariorumCore.Tag, from gathering: Reading) {
        Task {
            status = await RemoveFromBookDoor.removeTag(
                session: session, postID: postID, tag: tag, gathering: gathering,
                speak: false).text
            await refresh()
        }
    }

    /// 13f W23 — the compound, at the door that names its book. The op is
    /// ONE transaction with ONE undo entry; this only reports. It rides the
    /// SHARED entry (13f cold review, R1-4): the post's pending buffer is
    /// flushed first, so the copy carries what she just typed.
    private func diverge(for book: Reading) {
        Task {
            do {
                let result = try await session.divergeForBook(postID, in: book.id)
                duplicatedPostID = result.copy.post.id
                copyBookName = book.name  // 13g R1-1: the receipt names it
                status = DivergeCopy.done(book: book.name)
            } catch {
                status = DivergeCopy.refusal(
                    for: error, book: book.name, sealed: book.sealedAt != nil)
            }
            await refresh()
        }
    }

    private func duplicate() {
        Task {
            do {
                // 13e E10: the chip's duplicate row rides the copy family's
                // one flush-first entry, exactly as its diverge row does
                // (`session.divergeForBook` is the same body) — the chip
                // sits in the masthead ABOVE a live editor, so its post is
                // dirty whenever she is typing.
                let result = try await session.runCopying(from: postID) { [postID] ops in
                    try ops.duplicateAsVersion(postID)
                }
                duplicatedPostID = result.post.id
                copyBookName = nil  // 13g R1-1: a plain duplicate has no book to name
                status = "Duplicated — the copy is its own note now (in the Pool until you shelve it)."
            } catch {
                status = ChipRefusals.message(for: error, bookName: nil)
            }
        }
    }
}

/// 13f W23's words, in one place — the act's label, its help, what it says
/// when it lands, and the one refusal that needs its own sentence.
///
/// It lives beside `ChipRefusals` for the same reason that type does: a
/// promise made in a `Text` literal is a promise no test can keep, and both
/// of W23's doors (this chip's row and the first-edit note's button) must
/// say the same thing about the same act.
/// `nonisolated` for the reason the registry layer's own value types are
/// (batch 3 judgment call 4): the capability table is nonisolated and reads
/// `verb` from here, and pure string mapping has no actor to belong to.
nonisolated enum DivergeCopy {
    static let verb = "Diverge for This Book"

    /// The note's button names the book, because the note fires where she is
    /// writing and the book is not otherwise on screen.
    static func buttonLabel(book: String) -> String { "Diverge for \u{201c}\(book)\u{201d}" }

    static func help(book: String) -> String {
        "Make a copy that can diverge and put it in \u{201c}\(book)\u{201d} in this note's "
            + "place — the original stays in its other books and in the library"
    }

    static func done(book: String) -> String {
        "Diverged — \u{201c}\(book)\u{201d} holds the copy now, in the same place; the "
            + "original is untouched elsewhere. \u{2325}\u{2318}Z undoes it."
    }

    /// 13g cold review R1-1 (L17's receipt half — her WT-7 round-4 ruling:
    /// the receipt reads as a receipt "tied to the past act and naming its
    /// book"). The diverge's landing button carries the book that now holds
    /// the copy; a plain duplicate's copy has no book, so its receipt stays
    /// the bare "Open the Copy" beside its own status line.
    static func openCopyLabel(book: String?) -> String {
        guard let book else { return "Open the Copy" }
        return "Open the Copy in \u{201c}\(book)\u{201d}"
    }

    /// A SMART book has no membership row to swap: its posts arrive by tag,
    /// so the road there is the tag. 13i owns that design; this says so
    /// rather than pretending or staying silent.
    static func refusal(for error: Error, book: String, sealed: Bool = false) -> String {
        if let error = error as? OperationError, case .wrongReadingKind = error {
            return "\u{201c}\(book)\u{201d} collects by its tags, so there is no membership to "
                + "move — a copy would only appear there if it carried the same tags. "
                + "Duplicate as Version, then tag the copy."
        }
        return ChipRefusals.message(for: error, bookName: book, sealed: sealed)
    }
}

/// Readable refusal copy for the chip's doors (the "Refused: error(…)"
/// class retired — Sitting 9, R93).
nonisolated enum ChipRefusals {
    /// `sealed` (13i-c ladder round 1 — the sealed-named-reopen class): a
    /// SEALED book's road out is Unseal, never Reopen (`unlockReading`
    /// refuses a sealed book, `readingSealed`, R-13ic-3) — every chip call
    /// site has the book row, so it says which door is real.
    static func message(for error: Error, bookName: String?, sealed: Bool = false) -> String {
        // 13i-d U6 — the walk's W-1: anything this table has no BOOK words for
        // defers to the app's one refusal table, never a raw dump. (Diverge on
        // an empty note spoke "Refused: postHasNoBlocks(id: …)" — the R93
        // class — while the shared table has had its sentence all along.)
        guard let error = error as? OperationError else { return OpsRefusalCopy.message(for: error) }
        let book = bookName.map { "“\($0)”" } ?? "that book"
        switch error {
        case .lockedReading:
            return sealed
                ? "\(book) is sealed — unseal it (its settings) to change what's in it; "
                    + "unsealing reopens it too."
                : "\(book) is finished — reopen it (its settings) to change what's in it."
        case .readingAtCapacity:
            return "\(book) is at its note cap — extend the cap in its settings."
        case .alreadyInReading:
            return "This note is already in \(book)."
        case .lockedPost:
            return "This note is sealed — unseal it first."
        default:
            return OpsRefusalCopy.message(for: error)
        }
    }
}

#if DEBUG
/// **THE CHIP'S ADD DOOR, AS A TEST HOOK** (13i-c U4 — the `BindDoorProbe`
/// shape): the mounted chip registers the very function its "Add to Book"
/// menu calls, so a pin drives the real road and reads the presented sheet.
@MainActor
enum MembershipChipProbe {
    static var addDoor: ((Reading) -> Void)?
}
#endif

extension Notification.Name {
    /// A surface asks the shell to open a post (RootView routes it).
    static let variorumOpenPost = Notification.Name("variorumOpenPost")

    /// 13f W20(a) — THE ASCENT: a surface asks the shell to open a BOOK,
    /// revealed at a post (`userInfo`: `bookID`, `postID`). P-4 exactly —
    /// the surface names a destination, `RootView` decides what it means
    /// (the `.variorumOpenPost` precedent, one level up; the W10b
    /// `.variorumRevealUnplacedBlock` that first carried this shape was
    /// retired at 13j J6 — its destination no longer exists).
    static let variorumOpenBookAtPost = Notification.Name("variorumOpenBookAtPost")
}
