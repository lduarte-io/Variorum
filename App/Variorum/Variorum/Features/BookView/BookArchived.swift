//
//  BookArchived.swift
//  Variorum
//
//  13i-d U4 — A BOOK'S ARCHIVED LINE (her #169(a)(1) ruling, 2026-10-02; the
//  13i-d plan item 9 — her words, verbatim-faithful: *"archived hides from a
//  book's index and outline but it still is a part of that book … a per book
//  'archive', since it's the soft trash, and then you see what didn't make it
//  in"*).
//
//  The ARRIVALS LINE's idiom exactly (`BookArrivals.swift` — her clutter
//  mandate is this file's law too):
//
//  · INVISIBLE when nothing is set aside — the common case draws nothing, not
//    an empty line, not a hairline;
//  · ONE quiet line when something is — "2 archived" — standing directly
//    UNDER the Arrivals line on its three hosts (Index atop the pane, Outline
//    atop the column, Book atop the spread; PROVISIONAL P-13id-U4-1), outside
//    the measured scroll content, so the landing machinery sees nothing;
//  · expanding INLINE, on her click, to the archived members (which note, when
//    it was archived) with two doors per row: **Unarchive**
//    (`unarchiveContainer` — the note comes back into the book's working view
//    and the Library) and **Remove** / **Release** on an owned book (the one
//    `.removeFromBook` act through its one shared door, `RemoveFromBookDoor`).
//    Never a persistent panel; collapsed on every open.
//
//  The INDEX never shows archived members (archive keeps its one meaning —
//  kept, out of the working view); this line is the book's one door to its
//  set-aside notes. The read is `Queries.bookArchivedMembers` (the item's ONE
//  query), observed while the line is mounted — its cost, ∝ the book's live
//  pair rows at autosave rate, is the Arrivals line's own class (KnownIssues
//  row 13 names it).
//
//  Three pieces, split by concern (P-9): the WORDS (`ArchivedLineCopy` —
//  pure, pinned), the MODEL (`BookArchivedModel` — the observed line and its
//  two acts, speaking on the one status seam), the FACE (`BookArchivedLine` —
//  renders and sends; its acts' `.surface` declaration lives with it).
//

import GRDB // AsyncValueObservation iteration
import SwiftUI
import VariorumCore

// MARK: - The words

/// Every sentence the archived line says, in one home. Wording PROVISIONAL —
/// 13s re-voices the app.
nonisolated enum ArchivedLineCopy {
    /// The registry's verb for the Unarchive door (rendered through
    /// `chromeLabel`, so the Terminal voice lowercases it).
    static let unarchiveVerb = "Unarchive"

    /// The line itself: "2 archived".
    static func line(count: Int) -> String { "\(count) archived" }

    static let lineHelp =
        "Notes of this book you\u{2019}ve archived \u{2014} still in the book, kept out of its "
        + "Index. Unarchive one to bring it back, or take it out of the book"

    static let unarchiveHelp =
        "Unarchive \u{2014} it comes back into the book (and the Library)"

    /// The row's remove door, in the row's short form — the one
    /// `.removeFromBook` act, its word the book's (§20: Release on an owned
    /// book). The full verb ("Remove from This Book") is the act's menu form.
    static func removeWord(owned: Bool) -> String { owned ? "Release" : "Remove" }

    /// When it was archived, in the app's ONE stamp vocabulary
    /// (`TimeStampFace.relative`); nil when the stamp is unreadable — the face
    /// draws nothing rather than a lie.
    static func archived(_ iso: String, now: Date) -> String? {
        guard let date = DateFormatter.variorumISO8601.date(from: iso) else { return nil }
        return "archived " + TimeStampFace.relative(date, now: now)
    }

    /// **Its hover — the whole fact** (VX-351 — the VX-348 run, U4; her
    /// R-VX348-3): *Archived Oct 13, 2026 at 4:02 PM*. nil on the same terms.
    static func archivedHelp(_ iso: String) -> String? {
        guard DateFormatter.variorumISO8601.date(from: iso) != nil else { return nil }
        return TimeStampFace.tooltip(labelled: "Archived", iso: iso)
    }

    /// The expansion's tail past the window — the count is the line's whole
    /// answer, so the listing never pretends to be all.
    static func more(_ hidden: Int) -> String { "and \(hidden) more archived" }

    /// Unarchive landed — and where the note is now.
    static func unarchived(_ title: String) -> String {
        "Unarchived \u{201C}\(title)\u{201D} \u{2014} it\u{2019}s back in the book."
    }

    /// The operation's own refusal for Unarchive, in words.
    static func refusal(for error: Error) -> String {
        if case OperationError.containerNotFound = error {
            return "That note is gone \u{2014} it was deleted, so there\u{2019}s nothing to unarchive."
        }
        return OpsRefusalCopy.message(for: error)
    }

    /// The registry's honest note for a dispatch nothing renders.
    static let unavailableNote =
        "Unarchiving acts on an archived note\u{2019}s row \u{2014} a book\u{2019}s archived line "
        + "(atop its Index, Outline or Book view), or the Library\u{2019}s Archived view."
}

// MARK: - Whether the line shows (one value — the Arrivals line's rule)

nonisolated enum ArchivedLineFace {
    /// The line exists only when something is set aside.
    static func isShown(_ door: Queries.BookArchivedMembers) -> Bool { door.count > 0 }

    /// How many archived members the expansion does NOT list.
    static func hidden(_ door: Queries.BookArchivedMembers) -> Int {
        max(0, door.count - door.rows.count)
    }
}

// MARK: - The model

/// The archived line of ONE book, observed, and its two acts. Holds
/// projections and ids only and calls the operations (through the shared
/// remove door) — what may be removed, and when, is the operation's, and its
/// refusal is what she hears.
@MainActor
@Observable
final class BookArchivedModel {
    @ObservationIgnored let session: AppSession
    let readingID: String

    /// The line's answer — the count and (while open) the first rows.
    private(set) var door: Queries.BookArchivedMembers = .none
    /// Open = the expansion lists the rows. COLLAPSED by default and after
    /// every emptying (the Arrivals line's rule — never a persistent panel).
    private(set) var expanded = false
    /// Rows whose act is in flight — their doors grey until the store
    /// answers, so a double click cannot fire one act twice.
    private(set) var acting: Set<String> = []

    /// How many rows the open line lists (the count is never windowed).
    static let window = 30

    init(session: AppSession, readingID: String) {
        self.session = session
        self.readingID = readingID
    }

    /// The count alone while collapsed; the window while open.
    var listingLimit: Int { expanded ? Self.window : 0 }

    /// Observe the line. Hosted by the face with `.task(id: expanded)`, so
    /// opening restarts the observation with its listing, and the observation
    /// lives exactly as long as a surface shows the line (P3).
    func start() async {
        do {
            for try await value in session.database.observeBookArchivedMembers(
                readingID, limit: listingLimit) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }

    /// Internal so pins drive the line deterministically (hosted `.task`
    /// callbacks don't fire under the test host).
    func adopt(_ value: Queries.BookArchivedMembers) {
        // Ladder A round 1, MINOR 1 (U4's refinement): a cancelled loop's
        // late delivery — the collapsed observation's count-only value
        // landing after the `.task(id: expanded)` restart's first rows —
        // would blank the expansion until the next write with nobody typing.
        // The `NoteMembershipModel` guard (the `NoteBoxFactsModel` lesson).
        guard !Task.isCancelled else { return }
        door = value
        acting.formIntersection(value.rows.map(\.id))
        if value.count == 0 { expanded = false }
    }

    /// The line's own click: open to the rows, or fold back.
    func toggle() {
        guard ArchivedLineFace.isShown(door) else { return }
        expanded.toggle()
    }

    /// **Unarchive** — the note comes back into the book's working view (its
    /// membership never left) and the Library.
    func unarchive(_ member: Queries.ArchivedMember) async {
        guard acting.insert(member.id).inserted else { return }
        defer { acting.remove(member.id) }
        let postID = member.postID
        do {
            try await session.runner.run { ops in try ops.unarchiveContainer(postID) }
            session.status.receipt(ArchivedLineCopy.unarchived(member.title))
        } catch {
            session.status.refuse(ArchivedLineCopy.refusal(for: error))
        }
    }

    /// **Remove** (or **Release** on an owned book) — the ONE remove door, so
    /// the receipt is the shared one (honest for an archived note: it stays
    /// archived) and a refusal names the book's road.
    func remove(_ member: Queries.ArchivedMember, book: Reading?) async {
        guard let book, acting.insert(member.id).inserted else { return }
        defer { acting.remove(member.id) }
        await RemoveFromBookDoor.remove(session: session, postID: member.postID, book: book)
    }
}

// MARK: - The face

/// **The archived line** — under the Arrivals line, atop the book's Index
/// pane, its Outline and its Book spread. Draws NOTHING when nothing is set
/// aside; one quiet line when something is; the rows inline when she opens it.
struct BookArchivedLine: View {
    let model: BookArchivedModel
    let structure: BookStructureModel

    /// The doors this face renders (P-1's walk): Unarchive — this line is its
    /// one renderer — and the shared remove act, its word the book's.
    static let surfaceCapabilities: [CapabilityID] = [.unarchiveNote, .removeFromBook]

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    #if DEBUG
    /// This line's own name in the DEBUG probe (the Arrivals line's reason —
    /// SwiftUI mounts the arriving surface before unmounting the departing).
    @State private var probeOwner = UUID()
    #endif

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// The Arrivals line's measure, so the two lines read as one stack.
    private static let measure: CGFloat = 640
    private static let sideInset: CGFloat = 34

    var body: some View {
        VStack(spacing: 0) {
            // The observation's anchor — always appears, even while the line
            // itself draws nothing.
            Color.clear.frame(height: 0)
            if ArchivedLineFace.isShown(model.door) {
                line
                Rectangle()
                    .fill(tokens.line)
                    .frame(height: 1)
            }
        }
        .task(id: model.expanded) { await model.start() }
    }

    private var line: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                model.toggle()
            } label: {
                Text(tokens.chromeLabel(
                    (model.expanded ? "\u{25BE} " : "\u{25B8} ")
                        + ArchivedLineCopy.line(count: model.door.count)))
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .help(ArchivedLineCopy.lineHelp)
            if model.expanded {
                ForEach(model.door.rows) { member in
                    row(member)
                }
                let hidden = ArchivedLineFace.hidden(model.door)
                if hidden > 0 {
                    Text(tokens.chromeLabel(ArchivedLineCopy.more(hidden)))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .lineLimit(1)
                        .padding(.leading, 5)
                }
            }
        }
        .frame(maxWidth: Self.measure, alignment: .leading)
        .padding(.horizontal, Self.sideInset)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(tokens.surface)
        #if DEBUG
        .onAppear { recordLine() }
        .onChange(of: model.door) { _, _ in recordLine() }
        .onChange(of: model.expanded) { _, _ in recordLine() }
        .onDisappear { ArchivedLineProbe.forget(model.readingID, owner: probeOwner) }
        #endif
    }

    private func row(_ member: Queries.ArchivedMember) -> some View {
        let busy = model.acting.contains(member.id)
        let owned = structure.reading?.owned ?? false
        return HStack(alignment: .firstTextBaseline, spacing: 8) {
            // The note's NAME is her prose, never chrome — no `chromeLabel`.
            Text(member.title)
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
                .truncationMode(.tail)
                .help(member.title)
            Spacer(minLength: 8)
            if let stamp = ArchivedLineCopy.archived(member.archivedAt, now: Date()) {
                Text(tokens.chromeLabel(stamp))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
                    .fixedSize()
                    .help(ArchivedLineCopy.archivedHelp(member.archivedAt) ?? stamp)  // VX-351
            }
            Button(tokens.chromeLabel(ArchivedLineCopy.unarchiveVerb)) {
                Task { await model.unarchive(member) }
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
            .help(ArchivedLineCopy.unarchiveHelp)
            .disabled(busy)
            Button(tokens.chromeLabel(ArchivedLineCopy.removeWord(owned: owned))) {
                Task { await model.remove(member, book: structure.reading) }
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .help(structure.reading.map {
                RemoveFromBookCopy.help(owned: owned, book: $0.name)
            } ?? RemoveFromBookCopy.verb(owned: owned))
            .disabled(busy)
        }
        .padding(.leading, 18)
        #if DEBUG
        .onAppear {
            ArchivedLineProbe.recordRow(
                model.readingID, owner: probeOwner, member.id,
                [ArchivedLineCopy.unarchiveVerb, ArchivedLineCopy.removeWord(owned: owned)])
        }
        .onDisappear {
            ArchivedLineProbe.forgetRow(model.readingID, owner: probeOwner, member.id)
        }
        #endif
    }

    #if DEBUG
    private func recordLine() {
        ArchivedLineProbe.recordLine(
            model.readingID, owner: probeOwner,
            text: ArchivedLineCopy.line(count: model.door.count),
            expanded: model.expanded)
    }
    #endif
}

#if DEBUG
/// **WHAT THE MOUNTED LINE DREW, AS A TEST ORACLE** — `ArrivalsLineProbe`'s
/// shape and reasons exactly (a hosted SwiftUI tree exposes no accessibility
/// children in this test host). Recorded from the line's and each row's own
/// `onAppear`, keyed by the book, OWNED per line instance; cleared on
/// disappear — so "absent" is an honest answer. DEBUG only.
@MainActor
enum ArchivedLineProbe {
    struct Drawn: Equatable {
        var owner: UUID
        var line: String?
        var expanded = false
        /// Membership row id → the door words that row drew.
        var rows: [String: [String]] = [:]
    }

    private(set) static var drawn: [String: Drawn] = [:]

    static func reset() { drawn = [:] }

    private static func claim(_ readingID: String, _ owner: UUID) -> Drawn {
        if let entry = drawn[readingID], entry.owner == owner { return entry }
        return Drawn(owner: owner)
    }

    static func recordLine(_ readingID: String, owner: UUID, text: String, expanded: Bool) {
        var entry = claim(readingID, owner)
        entry.line = text
        entry.expanded = expanded
        drawn[readingID] = entry
    }

    static func recordRow(
        _ readingID: String, owner: UUID, _ rowID: String, _ words: [String]
    ) {
        var entry = claim(readingID, owner)
        entry.rows[rowID] = words
        drawn[readingID] = entry
    }

    static func forgetRow(_ readingID: String, owner: UUID, _ rowID: String) {
        guard drawn[readingID]?.owner == owner else { return }
        drawn[readingID]?.rows[rowID] = nil
    }

    static func forget(_ readingID: String, owner: UUID) {
        guard drawn[readingID]?.owner == owner else { return }
        drawn[readingID] = nil
    }
}
#endif
