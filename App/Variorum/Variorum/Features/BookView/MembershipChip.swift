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
        }
        .buttonStyle(.borderless)
        .help("Which books hold this post — add it to one, or diverge a copy")
        .popover(isPresented: $popoverShown, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                if books.isEmpty {
                    Text("This post is in no book — it lives in the Pool.")
                        .font(.callout)
                } else {
                    Text("This post appears in \(books.count) book\(books.count == 1 ? "" : "s"):")
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
                            .help("Open “\(book.name)” at this post")
                            Spacer()
                            Button("remove") { remove(from: book) }
                                .buttonStyle(.borderless)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .help("Take this post out of “\(book.name)” (the post itself is untouched)")
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
                Text("Editing here edits the post everywhere it appears. "
                    + "To make a separate post that can diverge:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 280, alignment: .leading)
                Button("Duplicate as Version") {
                    duplicate()
                }
                .help("A full copy — takes and all — as a new post, linked to this one as a version")
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
                    Button("Open the Copy") {
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
                    status = "“\(book.name)” can't take this post: \(reason)"
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
                status = "Removed from “\(book.name)” — the post itself is untouched."
            } catch {
                status = ChipRefusals.message(for: error, bookName: book.name)
            }
            await refresh()
        }
    }

    private func duplicate() {
        Task {
            do {
                let result = try await session.runner.run { [postID] ops in
                    try ops.duplicateAsVersion(postID)
                }
                duplicatedPostID = result.post.id
                status = "Duplicated — the copy is its own post now (in the Pool until you shelve it)."
            } catch {
                status = ChipRefusals.message(for: error, bookName: nil)
            }
        }
    }
}

/// Readable refusal copy for the chip's doors (the "Refused: error(…)"
/// class retired — Sitting 9, R93).
enum ChipRefusals {
    static func message(for error: Error, bookName: String?) -> String {
        guard let error = error as? OperationError else { return String(describing: error) }
        let book = bookName.map { "“\($0)”" } ?? "that book"
        switch error {
        case .lockedReading:
            return "\(book) is finished — reopen it (its settings) to change what's in it."
        case .readingAtCapacity:
            return "\(book) is at its post cap — extend the cap in its settings."
        case .alreadyInReading:
            return "This post is already in \(book)."
        case .lockedPost:
            return "This post is sealed — unseal it first."
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
    /// (the `.variorumRevealUnplacedBlock` precedent, batch 2).
    static let variorumOpenBookAtPost = Notification.Name("variorumOpenBookAtPost")
}
