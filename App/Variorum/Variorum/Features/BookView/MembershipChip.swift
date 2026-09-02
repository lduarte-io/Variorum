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
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var books: [Reading] = []
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

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
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
                    Text("This note is in no book — it lives in the Pool.")
                        .font(.callout)
                } else {
                    Text("This note appears in \(books.count) book\(books.count == 1 ? "" : "s"):")
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
                            Button(book.name) {
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
                            Button("remove") { remove(from: book) }
                                .buttonStyle(.borderless)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .help("Take this note out of “\(book.name)” (the note itself is untouched)")
                        }
                    }
                }
                // R61 — the ADD door, right where "in no book" is read.
                if !addableBooks.isEmpty || !addableSmartBooks.isEmpty {
                    Menu("Add to Book") {
                        ForEach(addableBooks, id: \.id) { book in
                            Button(book.name) { add(to: book) }
                        }
                        if !addableSmartBooks.isEmpty {
                            Divider()
                            // R98: smart books collect by filter — adding
                            // IS tagging, and the door says so.
                            ForEach(addableSmartBooks, id: \.id) { book in
                                Button("\(book.name) (by tagging)") { collect(into: book) }
                            }
                        }
                    }
                    .fixedSize()
                }
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
        .task(id: postID) { await refresh() }
        .onChange(of: popoverShown) { _, shown in
            if shown { Task { await refresh() } }
        }
    }

    /// Batch 9 (R101): the es line wears the voice's PATH grammar where a
    /// real path exists — "~/orbit" in terminal, "in Orbit" in study; no
    /// book and many books stay plain words.
    private var label: String {
        switch books.count {
        case 0: "in no book"
        case 1:
            tokens.pathPrefix.isEmpty
                ? "in \(books[0].name)"
                : tokens.path([books[0].name])
        default: "in \(books.count) books"
        }
    }

    /// The `.surface` acts this chip renders (P-1's declared ⇔ rendered
    /// walk): W23's per-book diverge door lives on the book rows here — and,
    /// since 13e E11, so does the ASCENT the same rows have carried since
    /// Phase 13 (`ascend`, wired at 13f W20(a)). Both point at the BOOK ROW,
    /// which is what makes them surface acts; the per-row condition stays the
    /// surface's (a row exists only where its book does — the
    /// `.diffAgainstChosen` split, P-2).
    static let surfaceCapabilities: [CapabilityID] = [.divergeForBook, .openBookAtNote]

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

    private func refresh() async {
        let membership = (try? await session.database.read { [postID] db in
            try Queries.readingsContaining(db, postID: postID)
        }) ?? []
        // 13f W20(c): the chooser's order is hers (round 10) — curated
        // before smart, most-recently-visited floating inside each group.
        // Smart matches ARE listed: derived membership IS membership
        // (round 10 item 2, #26(h)), and `readingsContaining` has always
        // returned them.
        books = BookChooserOrder.ordered(membership, recentlyVisited: recentBookIDs)
        let memberIDs = Set(membership.map(\.id))
        let all = ((try? await session.database.read { db in
            try Queries.readings(db)
        }) ?? [])
        // Addable = open curated books the post isn't already in.
        addableBooks = all
            .filter { $0.kind == .curated && !$0.locked && !memberIDs.contains($0.id) }
        // R98 (supersedes the pre-batch-10 "never pretends to add there"):
        // open smart books too — the add applies the filter's tags.
        addableSmartBooks = all
            .filter { $0.kind == .smart && !$0.locked && !memberIDs.contains($0.id) }
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
                    status = ChipRefusals.message(for: error, bookName: book.name)
                }
            } catch {
                status = String(describing: error)
            }
            await refresh()
        }
    }

    private func add(to book: Reading) {
        Task {
            do {
                _ = try await session.runner.run { [postID] ops in
                    try ops.addPostToReading(postID, to: book.id)
                }
                status = "Added to “\(book.name)”."
            } catch {
                status = ChipRefusals.message(for: error, bookName: book.name)
            }
            await refresh()
        }
    }

    private func remove(from book: Reading) {
        Task {
            do {
                try await session.runner.run { [postID] ops in
                    try ops.removePostFromReading(postID, from: book.id)
                }
                status = "Removed from “\(book.name)” — the note itself is untouched."
            } catch {
                status = ChipRefusals.message(for: error, bookName: book.name)
            }
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
                status = DivergeCopy.refusal(for: error, book: book.name)
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
    static func refusal(for error: Error, book: String) -> String {
        if let error = error as? OperationError, case .wrongReadingKind = error {
            return "\u{201c}\(book)\u{201d} collects by its tags, so there is no membership to "
                + "move — a copy would only appear there if it carried the same tags. "
                + "Duplicate as Version, then tag the copy."
        }
        return ChipRefusals.message(for: error, bookName: book)
    }
}

/// Readable refusal copy for the chip's doors (the "Refused: error(…)"
/// class retired — Sitting 9, R93).
nonisolated enum ChipRefusals {
    static func message(for error: Error, bookName: String?) -> String {
        guard let error = error as? OperationError else { return String(describing: error) }
        let book = bookName.map { "“\($0)”" } ?? "that book"
        switch error {
        case .lockedReading:
            return "\(book) is finished — reopen it (its settings) to change what's in it."
        case .readingAtCapacity:
            return "\(book) is at its note cap — extend the cap in its settings."
        case .alreadyInReading:
            return "This note is already in \(book)."
        case .lockedPost:
            return "This note is sealed — unseal it first."
        default:
            return "Refused: \(error)"
        }
    }
}

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
