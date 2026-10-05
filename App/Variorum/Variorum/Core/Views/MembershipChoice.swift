//
//  MembershipChoice.swift
//  Variorum (Mac)
//
//  13i-c U4 — THE MEMBERSHIP CHOICE (the sitting record §2, §6; the 13i-c
//  plan §3 and §4 rows 14–18). Every road that puts a note into a book by
//  hand asks the operations layer ONE question (`addPostToReading`, whose
//  ownership consult is the choke point), and where a plain pointer would
//  break an owned book's promise the operation REFUSES with the choice it
//  names — `noteMemberedElsewhere` (an owned book meets a note that lives in
//  other books: copy it in, or move it in) or `noteOwnedElsewhere` (a plain
//  book meets a note another book owns: only a copy can come in). P-2 says a
//  refusal where a ceremony exists OPENS the choice rather than ending in
//  words. This file is that choice, once, for every host:
//
//  1. **THE WORDS** — `MembershipChoiceCopy`: every sentence the sheet and its
//     receipts say, static copy on a pure type (the `BookStateCopy`
//     precedent), so pins read them without a window. The edit law is said AT
//     the door (§2): adding never copies; a copy is a ceremony she chose.
//  2. **THE ITEM** — `MembershipChoice`: the sheet's whole input, carrying
//     the names it says (the refusals carry ids only — F-U2-6), read from the
//     same predicates the two operations act on (`noteMemberships`,
//     `moveInPreview`), so the sheet can never list a different set than the
//     act severs.
//  3. **THE MODEL** — `MembershipDoors`: the add, the offer, the two acts,
//     the receipt or the operation's own refusal on the 18i status seam.
//  4. **THE FACE** — `MembershipChoiceSheet` + `.membershipChoices(_:)`: ONE
//     renderer and ONE presentation road, so the chip, the Pool, the shelf,
//     Manage Notes… cannot drift.
//
//  It lives in the SHARED home (`Core/Views`) because four features host it
//  (CLAUDE.md: a view consumed by two features moves here; the
//  `NoteBoxFactsModel` precedent for a model beside its view).
//

import GRDB // `Database` in the item's loader
import SwiftUI
import VariorumCore

// MARK: - The words

/// Every sentence the membership choice says. Wording PROVISIONAL — 13s
/// re-voices the app; the TRUTH each sentence states is ruled (the sitting
/// record §2 and §6; the §25 lessons 2 and 5 — no sentence here may make one
/// false).
nonisolated enum MembershipChoiceCopy {
    static func quoted(_ name: String) -> String { "\u{201C}\(name)\u{201D}" }

    /// "“X”, “Y” and “Z”" — names joined the way a sentence lists them.
    static func list(_ names: [String]) -> String {
        let quotedNames = names.map(quoted)
        switch quotedNames.count {
        case 0: return ""
        case 1: return quotedNames[0]
        default:
            return quotedNames.dropLast().joined(separator: ", ") + " and " + quotedNames.last!
        }
    }

    /// The registry's honest note for a dispatch nothing renders.
    static let unavailableNote =
        "Copy in and Move in are offered where a note meets a book that owns its notes "
        + "\u{2014} add it to the book, or judge it at the book's Arrivals."

    // The two acts' button words (the registry's verbs).
    static let copyInVerb = "Copy In"
    static let moveInVerb = "Move In"
    static func copyIntoVerb(_ book: String) -> String { "\(copyIntoLead) \(quoted(book))" }
    /// The copy-only button's CHROME half — the book's name beside it is
    /// hers and is never voiced (the walk's W-1: the Terminal voice
    /// lowercased the whole label, her book's name with it).
    static let copyIntoLead = "Copy Into"

    /// The sheet's title — what she was doing when the choice met her.
    static func title(note: String, book: String) -> String {
        "Add \(quoted(note)) to \(quoted(book))?"
    }

    /// §2, at the door — lesson 2's second and third sentences, said where
    /// the choice is made: adding never copies; a copy is hers to choose.
    static let editLaw =
        "Adding a note to a book never copies it \u{2014} a copy only happens because you "
        + "choose one, and it always remembers where it came from."

    // MARK: An OWNED book meets a note that lives in other books (copy · move)

    /// The brief's sentence: "“Book” owns its notes. This note also lives in
    /// “X”, “Y”."
    static func ownedTargetLead(book: String, elsewhere: [String]) -> String {
        "\(quoted(book)) owns its notes. This note also lives in \(list(elsewhere))."
    }

    /// What COPY IN does, said before she presses it.
    static func copyExplains(book: String, elsewhere: [String]) -> String {
        "Copy it in: a linked copy joins \(quoted(book)); the original stays in "
            + "\(list(elsewhere)), unchanged."
    }

    /// What MOVE IN does — the severed list, named (the plan §3: the confirm
    /// lists what will be severed). Members leave; a note only WAITING at
    /// another book's door stops waiting there.
    static func moveExplains(book: String, leaves: [String], waitingAt: [String]) -> String {
        var sentence = "Move it in: it leaves \(list(leaves))"
        if !waitingAt.isEmpty {
            sentence += " and stops waiting at \(list(waitingAt))\u{2019}s door"
        }
        return sentence + ", and lives only in \(quoted(book))."
    }

    /// A FINISHED book among the ones it would leave: its table of contents
    /// is done, so the note cannot leave it (the op's refusal, P-13ic-U2-4) —
    /// the sheet says so where Move would be, and Copy in stays. A SEALED
    /// book's road out is UNSEAL (13i-c ladder round 1 — Reopen refuses
    /// there, `readingSealed`; naming it was the P-2 class in copy).
    static func moveBlocked(by finished: String, sealed: Bool = false) -> String {
        sealed
            ? "It can\u{2019}t move: \(quoted(finished)) is sealed, so the note can\u{2019}t "
                + "leave it \u{2014} copy it in instead, or unseal \(quoted(finished)) first "
                + "(that reopens it too)."
            : "It can\u{2019}t move: \(quoted(finished)) is finished, so the note can\u{2019}t "
                + "leave it \u{2014} copy it in instead, or reopen \(quoted(finished)) first."
    }

    // MARK: A PLAIN book meets a note another book owns (copy only)

    /// The brief's sentence: "This note belongs to “X”, which owns its notes."
    static func ownedElsewhereLead(owner: String) -> String {
        "This note belongs to \(quoted(owner)), which owns its notes."
    }

    static func copyOnlyExplains(book: String, owner: String) -> String {
        "Only a copy can come in: a linked copy joins \(quoted(book)); the original stays "
            + "in \(quoted(owner)), unchanged."
    }

    // MARK: Receipts (the 18i seam's RECEIPT class)

    static func copied(book: String) -> String {
        "Copied into \(quoted(book)) \u{2014} a linked copy; the original stays where it was."
    }

    static func moved(book: String, left: [String]) -> String {
        left.isEmpty
            ? "Moved into \(quoted(book))."
            : "Moved into \(quoted(book)) \u{2014} it left \(list(left))."
    }

    // MARK: Refusals (the operation's own, named for its book)

    /// `sealed` (13i-d U6 — KnownIssues row 106): the TARGET book is sealed,
    /// whose road out is Unseal — Reopen refuses there (`readingSealed`,
    /// R-13ic-3). The doors read it fresh at the refusal.
    @MainActor
    static func refusal(for error: Error, book: String, sealed: Bool = false) -> String {
        if let op = error as? OperationError {
            switch op {
            case .lockedReading:
                return sealed
                    ? "\(quoted(book)) is sealed \u{2014} unseal it (its settings) to add to it; "
                        + "unsealing reopens it too."
                    : "\(quoted(book)) is finished \u{2014} reopen it (its settings) to add to it."
            case .readingAtCapacity:
                return "\(quoted(book)) is at its note cap \u{2014} extend the cap in its settings."
            case .alreadyInReading:
                return "This note is already in \(quoted(book))."
            default:
                break
            }
        }
        return OpsRefusalCopy.message(for: error)
    }

    /// Move in refused by a blocking book that cannot be NAMED (it died
    /// between the operation's refusal and the read — no fact to fork on).
    /// A sentence, never the R93-banned "Refused: error(…)" dump (the sanity
    /// pass's concern 1: the shared table has no `lockedReading` words, so
    /// the generic road speaks the raw error). "Finished" is TRUE for a
    /// sealed blocker too (Sealed = Finished + text immutability), and with
    /// no book there is no door to name — the ceremony that works is.
    static let moveRefusedUnnamed =
        "A book this note would leave is finished, so it can\u{2019}t move \u{2014} copy it "
        + "in instead."

    /// Move in refused because one of the books it would leave is finished
    /// (`lockedReading` naming THAT book, not the target). A SEALED book
    /// names Unseal (13i-c ladder round 1 — Reopen refuses there).
    static func moveRefusedFinished(_ finished: String, sealed: Bool = false) -> String {
        sealed
            ? "\(quoted(finished)) is sealed, so this note can\u{2019}t leave it \u{2014} copy "
                + "it in instead, or unseal \(quoted(finished)) first (that reopens it too)."
            : "\(quoted(finished)) is finished, so this note can\u{2019}t leave it \u{2014} copy "
                + "it in instead, or reopen \(quoted(finished)) first."
    }
}

// MARK: - The item

/// The choice, whole — the sheet's only input (the `BookStateConfirm` lesson:
/// nothing it renders is read from a stale second piece of state).
nonisolated struct MembershipChoice: Identifiable, Equatable, Sendable {
    let kind: OwnershipDecision.Choice
    let postID: String
    let noteTitle: String
    let book: Queries.BookRef
    /// The OTHER books it is a member of (earliest first) — copy·move's lead.
    let elsewhere: [String]
    /// The owning book — copy-only's lead (the earliest owning claim, §18.4).
    let owner: Queries.BookRef?
    /// What MOVE IN severs (`Queries.moveInPreview` — exactly the op's rows).
    let severed: [Queries.SeveredMembership]

    var id: String { "\(postID)|\(book.id)" }

    var title: String { MembershipChoiceCopy.title(note: noteTitle, book: book.name) }

    /// The member books MOVE IN leaves.
    var leaves: [String] { severed.filter { !$0.isArrival }.map(\.book.name) }
    /// The books whose door it stops waiting at.
    var waitingAt: [String] { severed.filter(\.isArrival).map(\.book.name) }
    /// A finished (or sealed) book among the ones it would leave — MOVE IN
    /// refuses there; the sentence names ITS road out (reopen · unseal).
    var moveBlockedRow: Queries.SeveredMembership? {
        severed.first { !$0.isArrival && $0.finished }
    }
    var moveBlockedBy: String? { moveBlockedRow?.book.name }

    /// Whether the sheet offers MOVE IN at all (an owned target only — §4).
    var offersMove: Bool { kind == .copyOrMove }

    /// The sentences, in order.
    var lines: [String] {
        switch kind {
        case .copyOrMove:
            var lines = [
                MembershipChoiceCopy.ownedTargetLead(book: book.name, elsewhere: elsewhere),
                MembershipChoiceCopy.copyExplains(book: book.name, elsewhere: elsewhere),
            ]
            if let blocked = moveBlockedRow {
                lines.append(MembershipChoiceCopy.moveBlocked(
                    by: blocked.book.name, sealed: blocked.sealed))
            } else {
                lines.append(MembershipChoiceCopy.moveExplains(
                    book: book.name, leaves: leaves, waitingAt: waitingAt))
            }
            return lines
        case .copyOnly:
            let ownerName = owner?.name ?? (elsewhere.first ?? "")
            return [
                MembershipChoiceCopy.ownedElsewhereLead(owner: ownerName),
                MembershipChoiceCopy.copyOnlyExplains(book: book.name, owner: ownerName),
            ]
        }
    }

    /// The copy button's words: "Copy In" beside Move, "Copy Into “B”"
    /// alone.
    var copyLabel: String {
        offersMove ? MembershipChoiceCopy.copyInVerb : MembershipChoiceCopy.copyIntoVerb(book.name)
    }

    /// **The copy button's title, voiced** (13i-c U4 walk, W-1): the chrome
    /// half through the voice (`chrome` — the Terminal voice lowercases it),
    /// her book's name untouched.
    func copyButtonTitle(chrome: (String) -> String) -> String {
        offersMove
            ? chrome(MembershipChoiceCopy.copyInVerb)
            : chrome(MembershipChoiceCopy.copyIntoLead) + " "
                + MembershipChoiceCopy.quoted(book.name)
    }
}

// MARK: - The model

/// The membership doors' one brain, shared by every host that puts a note
/// into a book by hand (§4 rows 14–18). Holds the pending choice (the sheet's
/// item) and nothing persisted; every write is an operation's.
@MainActor
@Observable
final class MembershipDoors {
    @ObservationIgnored let session: AppSession
    /// The choice on screen — the host presents `.sheet(item:)` over it.
    var pending: MembershipChoice?

    init(session: AppSession) {
        self.session = session
    }

    /// **THE ADD** — one road for every hand-add. Returns nil when the note
    /// joined, or the CHOICE an ownership refusal named (nothing joined; the
    /// caller offers it — `offer` — after closing whatever popover it was
    /// in). Every OTHER refusal is rethrown, so each host keeps speaking it
    /// in its own words.
    func add(
        _ postID: String, to readingID: String
    ) async throws -> OwnershipDecision.Choice? {
        do {
            _ = try await session.runner.run { ops in
                try ops.addPostToReading(postID, to: readingID)
            }
            return nil
        } catch let error as OperationError {
            guard let choice = Self.choice(for: error) else { throw error }
            return choice
        }
    }

    /// `add`, then OPEN the choice at once when one was named (P-2 — the
    /// refusal opens the ceremony instead of ending in words). True when the
    /// note joined; false when the sheet is up instead — or when the book
    /// vanished and the refusal was spoken (no sheet; the round-2 doc NIT).
    @discardableResult
    func addOrOffer(_ postID: String, to readingID: String) async throws -> Bool {
        guard let choice = try await add(postID, to: readingID) else { return true }
        await offer(choice, postID: postID, readingID: readingID)
        return false
    }

    /// Which choice an operation's refusal names — nil for any other refusal.
    nonisolated static func choice(for error: Error) -> OwnershipDecision.Choice? {
        switch error as? OperationError {
        case .noteMemberedElsewhere: return .copyOrMove
        case .noteOwnedElsewhere: return .copyOnly
        default: return nil
        }
    }

    /// Load the names the sheet says and open it. Returns whether it opened
    /// (13i-c ladder round 1): a book that VANISHED between the refusal and
    /// the offer speaks the operation's words instead of vanishing the press
    /// (P-2 — a door never ends in silence).
    @discardableResult
    func offer(
        _ kind: OwnershipDecision.Choice, postID: String, readingID: String
    ) async -> Bool {
        do {
            guard let item = try await session.database.read({ db in
                try Self.load(db, kind: kind, postID: postID, readingID: readingID)
            }) else {
                session.status.refuse(OpsRefusalCopy.message(
                    for: OperationError.readingNotFound(id: readingID)))
                return false
            }
            pending = item
            return true
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
            return false
        }
    }

    /// The item, read from the predicates the two operations act on.
    nonisolated static func load(
        _ db: Database, kind: OwnershipDecision.Choice, postID: String, readingID: String
    ) throws -> MembershipChoice? {
        guard let reading = try Queries.reading(db, id: readingID) else { return nil }
        let memberships = try Queries.noteMemberships(db, postID: postID, excluding: readingID)
        return MembershipChoice(
            kind: kind, postID: postID,
            noteTitle: try Queries.noteDisplayTitle(db, id: postID) ?? "",
            book: Queries.BookRef(id: reading.id, name: reading.name),
            elsewhere: memberships.map(\.book.name),
            owner: memberships.first(where: \.owned)?.book,
            severed: try Queries.moveInPreview(db, postID: postID, into: readingID))
    }

    /// **COPY IN** — the ceremony she chose. Returns the receipt on success.
    @discardableResult
    func copyIn(_ choice: MembershipChoice) async -> String? {
        pending = nil
        do {
            _ = try await session.runner.run { ops in
                try ops.copyPostIntoReading(choice.postID, into: choice.book.id)
            }
            let receipt = MembershipChoiceCopy.copied(book: choice.book.name)
            session.status.receipt(receipt)
            return receipt
        } catch {
            session.status.refuse(await targetRefusal(error, choice: choice))
            return nil
        }
    }

    /// The TARGET's refusal in words (13i-d U6 — KnownIssues row 106): a
    /// finished target names Reopen, a SEALED one Unseal — read FRESH, like
    /// the blocking book's arm below (the sheet's book is a name, not a
    /// state, and a moment old).
    private func targetRefusal(_ error: Error, choice: MembershipChoice) async -> String {
        var sealed = false
        if case OperationError.lockedReading(let id) = error, id == choice.book.id {
            sealed = ((try? await session.database.read { db in
                try Queries.reading(db, id: id)
            }) ?? nil)?.sealedAt != nil
        }
        return MembershipChoiceCopy.refusal(for: error, book: choice.book.name, sealed: sealed)
    }

    /// **MOVE IN** — the claim-move she chose. Returns the receipt on success.
    @discardableResult
    func moveIn(_ choice: MembershipChoice) async -> String? {
        pending = nil
        let database = session.database
        do {
            let left: [String] = try await session.runner.run { ops in
                let result = try ops.movePostIntoReading(choice.postID, into: choice.book.id)
                // The receipt names the books it LEFT (member rows only — a
                // waiting arrival elsewhere was never a home).
                let leftIDs = result.severed.filter { $0.status == .member }.map(\.readingId)
                return try database.read { db in
                    try leftIDs.compactMap { try Queries.reading(db, id: $0)?.name }
                }
            }
            let receipt = MembershipChoiceCopy.moved(book: choice.book.name, left: left)
            session.status.receipt(receipt)
            return receipt
        } catch {
            if case OperationError.lockedReading(let id) = error, id != choice.book.id {
                // 13i-c ladder (round 1 + the sanity pass's concern 1): the
                // blocking book is read FRESH — so its name AND its real road
                // (reopen · unseal) are current, not the sheet's stale
                // preview — and a book that cannot be read speaks the
                // book-less sentence, never the "Refused: error(…)" dump
                // (the shared table has no lockedReading words).
                let blocking = (try? await database.read { db in
                    try Queries.reading(db, id: id)
                }) ?? nil
                if let blocking {
                    session.status.refuse(MembershipChoiceCopy.moveRefusedFinished(
                        blocking.name, sealed: blocking.sealedAt != nil))
                } else {
                    session.status.refuse(MembershipChoiceCopy.moveRefusedUnnamed)
                }
            } else {
                session.status.refuse(await targetRefusal(error, choice: choice))
            }
            return nil
        }
    }

    func cancel() { pending = nil }
}

// MARK: - The face

/// **ONE renderer** for the membership choice. It decides nothing: it shows
/// its item and reports the press.
struct MembershipChoiceSheet: View {
    /// The two ceremonies this sheet renders — `.copyIn` and `.moveIn`'s
    /// `.surface` doors (the Arrivals line is their other renderer).
    static let surfaceCapabilities: [CapabilityID] = [.copyIn, .moveIn]

    let choice: MembershipChoice
    let onCopy: () -> Void
    let onMove: () -> Void

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Her note's name is her prose — the title is not chrome-labelled.
            Text(choice.title)
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(Array(choice.lines.enumerated()), id: \.offset) { _, line in
                ChromeNotice(tokens: tokens, text: line, ink: tokens.ink, lines: 4)
            }
            ChromeNotice(tokens: tokens, text: MembershipChoiceCopy.editLaw, lines: 3)
            HStack {
                Spacer()
                Button(tokens.chromeLabel("Cancel")) { dismiss() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(.cancelAction)
                if choice.offersMove {
                    Button(tokens.chromeLabel(MembershipChoiceCopy.moveInVerb)) {
                        onMove()
                        dismiss()
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .secondary))
                    .disabled(choice.moveBlockedBy != nil)
                }
                Button(choice.copyButtonTitle(chrome: tokens.chromeLabel)) {
                    onCopy()
                    dismiss()
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(width: 480, alignment: .leading)
        .background(tokens.surface)
        #if DEBUG
        .onAppear { MembershipChoiceProbe.shown = choice }
        .onDisappear { if MembershipChoiceProbe.shown == choice { MembershipChoiceProbe.shown = nil } }
        #endif
    }
}

extension View {
    /// Hosts the membership choice over any surface that adds notes to books
    /// by hand — ONE presentation road (the `.bookStateConfirms` precedent).
    /// `onLanded` hears an act that LANDED, with its receipt (a host with its
    /// own status line echoes it; a list re-reads).
    func membershipChoices(
        _ doors: MembershipDoors, onLanded: ((String) -> Void)? = nil
    ) -> some View {
        sheet(item: Bindable(doors).pending) { item in
            MembershipChoiceSheet(
                choice: item,
                onCopy: {
                    Task {
                        if let receipt = await doors.copyIn(item) { onLanded?(receipt) }
                    }
                },
                onMove: {
                    Task {
                        if let receipt = await doors.moveIn(item) { onLanded?(receipt) }
                    }
                })
        }
    }
}

#if DEBUG
/// **WHAT THE MOUNTED CHOICE SAID, AS A TEST ORACLE** (the `BookStateProbe`
/// pattern): recorded on appear, cleared on disappear. DEBUG only.
@MainActor
enum MembershipChoiceProbe {
    static var shown: MembershipChoice?
}
#endif
