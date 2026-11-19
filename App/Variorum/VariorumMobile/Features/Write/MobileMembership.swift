//
//  MobileMembership.swift
//  VariorumMobile
//
//  Parity round Stage C, batch C2 — THE MEMBERSHIP CHIP on the phone
//  (her feel-round finding #2: "the ability to move something between
//  books"; R31/R35's truth carried: membership is not ownership —
//  editing a post edits THE post, everywhere). The masthead wears the
//  chip (the phone's note-identity surface); tapping it opens a sheet
//  (LK4's sheet-over-page grammar — the Mac's popover has no phone
//  referent) carrying the Mac chip's vocabulary:
//
//  · SEE the books holding this note — curated memberships AND smart
//    collections (derived membership IS membership, round 10's rule;
//    `Queries.readingsContaining` has always returned both).
//  · ADD to any open curated book; add to a smart book BY TAGGING
//    (R98's apply-and-report through `collectPostIntoSmartReading`).
//  · REMOVE from a curated book (the note itself untouched). A smart
//    row renders NO remove door — derived membership has no row to
//    remove, and a door that can never act isn't rendered (P-2).
//  · DIVERGE FOR THIS BOOK (W23) through the SHARED flush-first entry
//    (`AppSession.divergeForBook` — the R1-4 class: the copy carries
//    what she just typed). A smart row's diverge refuses honestly and
//    names the tag road (her ruled shape — silence where the row looks
//    actionable is the confusion).
//
//  Phone wording deltas from the Mac, deliberate and recorded: no
//  "⌥⌘Z undoes it" tail (the phone has no structural undo — the
//  recorded v1 posture; every act here is re-doable by hand), and the
//  smart-diverge refusal names no Duplicate-as-Version door (that
//  capability is OPEN-FOR-HER on the phone).
//

import Foundation
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class MobileMembershipModel {
    @ObservationIgnored private let session: AppSession
    @ObservationIgnored let postID: String

    /// Books holding this note, curated group first (the Mac chooser's
    /// curated-before-smart; the phone has no visit history, so name
    /// order inside each group — recorded).
    private(set) var books: [Reading] = []
    private(set) var addableBooks: [Reading] = []
    private(set) var addableSmartBooks: [Reading] = []
    private(set) var status: String?

    /// VM-61: the slot speaks on the phone's one line with the class its door
    /// gives it — joining, leaving a book and diverging are ordinary acts (no
    /// line — her ruling; leaving a book takes a pointer away, never the
    /// note: PROVISIONAL P-55-4); a refusal always speaks, and so does a
    /// gathering's collect-by-tagging, a direction (PROVISIONAL P-55-11).
    private func say(_ text: String, as line: MobileLine.Class) {
        status = text
        MobileLine.say(text, as: line, session: session)
    }
    /// The last diverge's landing (R67: the copy is one tap away).
    private(set) var divergedCopyID: String?
    private(set) var divergedBookName: String?

    init(session: AppSession, postID: String) {
        self.session = session
        self.postID = postID
    }

    // MARK: - Pure brains (pinned)

    /// The chip's words — the Mac label's own three cases; the single
    /// case renders through the voice's path grammar at the view.
    nonisolated static func labelText(bookNames: [String]) -> String {
        switch bookNames.count {
        case 0: return "in no book"
        case 1: return "in \(bookNames[0])"
        default: return "in \(bookNames.count) books"
        }
    }

    /// Curated before smart, name order inside each group.
    nonisolated static func ordered(_ memberships: [Reading]) -> [Reading] {
        let curated = memberships.filter { $0.kind == .book }
            .sorted { ($0.name, $0.id) < ($1.name, $1.id) }
        let smart = memberships.filter { $0.kind == .gathering }
            .sorted { ($0.name, $0.id) < ($1.name, $1.id) }
        return curated + smart
    }

    /// Which doors a row carries (P-2 made pinnable): remove exists only
    /// where a membership ROW exists to remove.
    nonisolated static func rowCarriesRemove(_ reading: Reading) -> Bool {
        reading.kind == .book
    }

    // MARK: - Reads

    ///
    /// VM-59: what the sheet OFFERS is the note's own wing's books and
    /// gatherings — a book never spans wings, so another wing's book could
    /// only refuse (`crossWingMembership`); the note's own wing, never the
    /// app's current one.
    func refresh() async {
        do {
            let postID = postID
            let (membership, all) = try await session.database.read { db in
                let wing = try Queries.effectiveWing(db, ofPost: postID) ?? ""
                return (try Queries.readingsContaining(db, postID: postID),
                        try Queries.readings(db, wingID: wing))
            }
            books = Self.ordered(membership)
            let memberIDs = Set(membership.map(\.id))
            addableBooks = all.filter {
                $0.kind == .book && !$0.locked && !memberIDs.contains($0.id)
            }
            addableSmartBooks = all.filter {
                $0.kind == .gathering && !$0.locked && !memberIDs.contains($0.id)
            }
        } catch {
            say(OpsRefusalCopy.sentence(for: error, roads: .phone), as: .refusal)
        }
    }

    // MARK: - Acts (every one an existing core operation)

    func add(to book: Reading) async {
        do {
            _ = try await session.runner.run { [postID] ops in
                try ops.addPostToReading(postID, to: book.id)
            }
            say("Added to “\(book.name)”.", as: .ordinary)
        } catch {
            say(Self.refusal(error, bookName: book.name), as: .refusal)
        }
        await refresh()
    }

    /// R98 — a smart book accepts by TAGGING (apply-and-report).
    func collect(into book: Reading) async {
        do {
            let result = try await session.runner.run { [postID] ops in
                try ops.collectPostIntoSmartReading(postID, into: book.id)
            }
            // Already matching did nothing — a refusal (a door that did
            // nothing says so). A tagging that seats it applied tags she did
            // not ask for by name — a direction (P-55-11), in P-55-7's class.
            if result.alreadyMatched {
                say("Already collected — it matches “\(book.name)”'s filter.", as: .refusal)
            } else {
                say("Added by tagging \(result.appliedTagPaths.map { "#\($0)" }.joined(separator: " ")) — “\(book.name)” collects by filter.", as: .refusal)
            }
        } catch let error as OperationError {
            if case .smartFilterUnsatisfiable(_, let reason) = error {
                say("“\(book.name)” can't take this note: \(reason)", as: .refusal)
            } else {
                say(Self.refusal(error, bookName: book.name), as: .refusal)
            }
        } catch {
            say(OpsRefusalCopy.sentence(for: error, roads: .phone), as: .refusal)
        }
        await refresh()
    }

    func remove(from book: Reading) async {
        do {
            try await session.runner.run { [postID] ops in
                try ops.removePostFromReading(postID, from: book.id)
            }
            say("Removed from “\(book.name)” — the note itself is untouched.", as: .ordinary)
        } catch {
            say(Self.refusal(error, bookName: book.name), as: .refusal)
        }
        await refresh()
    }

    /// W23's compound through the SHARED flush-first entry (R1-4: the
    /// pending buffer lands first, so the copy carries what she just
    /// typed). One transaction, the operations layer's own refusals.
    func diverge(for book: Reading) async {
        do {
            let result = try await session.divergeForBook(postID, in: book.id)
            divergedCopyID = result.copy.post.id
            divergedBookName = book.name
            say("Diverged — “\(book.name)” holds the copy now, in the same place; the original is untouched elsewhere.", as: .ordinary)
        } catch {
            say(Self.divergeRefusal(error, bookName: book.name), as: .refusal)
        }
        await refresh()
    }

    // MARK: - Refusal copy (phone words; no platform names)

    /// The four book arms stay HERE because they carry the book's NAME, a
    /// context the shared table has no slot for (18m U3's collapse rule);
    /// everything else the table has words for, it says (18m U3 — this arm
    /// used to dump "Refused: …"), and where it has none the one plain
    /// fallback speaks (VM-62 — never the case name).
    nonisolated static func refusal(_ error: Error, bookName: String?) -> String {
        guard let error = error as? OperationError else {
            return OpsRefusalCopy.sentence(for: error, roads: .phone)
        }
        let book = bookName.map { "“\($0)”" } ?? "that book"
        switch error {
        case .lockedReading:
            return "\(book) is finished — reopen it to change what's in it."
        case .readingAtCapacity:
            return "\(book) is at its note cap."
        case .alreadyInReading:
            return "This note is already in \(book)."
        case .postNotInReading:
            return "This note isn't in \(book)."
        default:
            return OpsRefusalCopy.sentence(for: error, roads: .phone)
        }
    }

    /// A SMART book has no membership row to swap: its notes arrive by
    /// tag, so the road there is the tag (the Mac's own sentence, minus
    /// the Duplicate-as-Version tail — that door doesn't exist here).
    nonisolated static func divergeRefusal(_ error: Error, bookName: String) -> String {
        if let error = error as? OperationError, case .wrongReadingKind = error {
            return "“\(bookName)” collects by its tags, so there is no membership to "
                + "move — a copy would only appear there if it carried the same tags."
        }
        return refusal(error, bookName: bookName)
    }
}

/// The chip's sheet — the Mac popover's phone face (LK4's grammar).
struct MobileMembershipSheet: View {
    @Bindable var model: MobileMembershipModel
    let tokens: VoiceTokens
    /// R67 — the diverged copy is one tap away, never hunted for.
    let onOpenNote: ((String) -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(tokens.chromeLabel("Books"))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                Spacer()
                Button(tokens.chromeLabel("Done")) { dismiss() }
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .buttonStyle(.plain)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    membershipSection
                    addSection
                    if model.books.count > 0 {
                        // R31/R35's truth, said where an elsewhere exists
                        // (the L17 conditioning).
                        Text(tokens.chromeLabel(
                            "Editing here edits the note everywhere it appears."))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    // VM-61: this sheet's message speaks on the shell's one line, which draws above it.
                    if let copy = model.divergedCopyID, let onOpenNote {
                        Button {
                            dismiss()
                            onOpenNote(copy)
                        } label: {
                            Text(tokens.chromeLabel(openCopyLabel))
                                .font(tokens.small)
                                .foregroundStyle(tokens.accent)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(20)
        .background(tokens.room.ignoresSafeArea())
        .task { await model.refresh() }
    }

    private var openCopyLabel: String {
        guard let book = model.divergedBookName else { return "Open the copy" }
        return "Open the copy in “\(book)”"
    }

    @ViewBuilder
    private var membershipSection: some View {
        if model.books.isEmpty {
            Text(tokens.chromeLabel(
                "This note is in no book yet — it lives in the Library's bookless filter."))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            ForEach(model.books, id: \.id) { book in
                HStack(spacing: 10) {
                    Text(tokens.chromeLabel(MobileShelfFaces.name(for: book)))
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                    if book.kind == .gathering {
                        Text(tokens.chromeLabel("smart"))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                    }
                    Spacer()
                    Button(tokens.chromeLabel("diverge")) {
                        Task { await model.diverge(for: book) }
                    }
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .buttonStyle(.plain)
                    if MobileMembershipModel.rowCarriesRemove(book) {
                        Button(tokens.chromeLabel("remove")) {
                            Task { await model.remove(from: book) }
                        }
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    @ViewBuilder
    private var addSection: some View {
        if !model.addableBooks.isEmpty || !model.addableSmartBooks.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text(tokens.chromeLabel("Add to a book"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .padding(.top, 6)
                ForEach(model.addableBooks, id: \.id) { book in
                    addRow(book.name) { await model.add(to: book) }
                }
                // R98: smart books collect by filter — adding IS tagging,
                // and the door says so.
                ForEach(model.addableSmartBooks, id: \.id) { book in
                    addRow("\(book.name) (by tagging)") { await model.collect(into: book) }
                }
            }
        }
    }

    private func addRow(
        _ label: String, act: @escaping () async -> Void
    ) -> some View {
        Button {
            Task { await act() }
        } label: {
            HStack {
                Text(tokens.chromeLabel("+ \(label)"))
                    .font(tokens.body)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
