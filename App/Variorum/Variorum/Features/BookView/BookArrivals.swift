//
//  BookArrivals.swift
//  Variorum
//
//  13i-b U2 — THE ARRIVALS FACE (the 13i-b plan §3; the sitting record §4).
//
//  Her clutter mandate is this file's law: *"it's important to me that the UI
//  of a book not start to feel excessively cluttered."* So the face is:
//
//  · INVISIBLE when nothing waits — the common case draws nothing at all, not
//    an empty line, not a hairline;
//  · ONE muted line atop the book's Index and Book surfaces when something
//    does — "2 at the door";
//  · expanding INLINE, on her click, to the waiting rows (which note, when it
//    arrived) with the two judgment doors per row: **Add** (`seatArrival` —
//    the note lands at the END, unsectioned) and **Dismiss**
//    (`dismissArrival`). Never a persistent panel. The copy-in arm is
//    13i-c's and is neither built nor hinted here.
//
//  Three pieces, split by concern (P-9): the WORDS (`ArrivalsCopy` — pure,
//  pinned), the MODEL (`BookArrivalsModel` — the observed door and the two
//  acts, speaking on the one status seam), and the FACE
//  (`BookArrivalsLine` — renders and sends, the two acts' one renderer and
//  so their `.surface` declaration's home).
//
//  §23 (her overrule — "details off hides arrivals too"): the details toggle
//  is 13i-d's and does not exist yet. Nothing here fights it — whether the
//  line shows is ONE value (`ArrivalsLineFace.isShown`), so the toggle
//  composes at that one place when it lands.
//

import GRDB // AsyncValueObservation iteration
import SwiftUI
import VariorumCore

// MARK: - The words

/// Every sentence the door says, in one home — the line, the rows, the two
/// receipts and the refusals (the `SplitAtNewlinesCopy` reason: a receipt
/// worded at two sites is how copy drifts). Wording PROVISIONAL —
/// 13s re-voices the app; this is the plan §3's "N at the door", quiet.
nonisolated enum ArrivalsCopy {
    /// The judgment doors' verbs (the registry's `verb`; the face renders
    /// them through `chromeLabel`, so the Terminal voice lowercases them).
    static let addVerb = "Add"
    static let dismissVerb = "Dismiss"

    /// The line itself — the plan §3's wording.
    static func line(count: Int) -> String { "\(count) at the door" }

    /// The line's hover: what is waiting and what she can do about it.
    static let lineHelp =
        "Notes this book's rule brought in that are waiting for you — "
        + "add each to the end of the book, or dismiss it"

    static let addHelp = "Add this note to the book — it lands at the end"
    static let dismissHelp = "Dismiss — don't add this note to the book"

    /// When a row arrived, in the app's ONE stamp vocabulary
    /// (`TimeStampFace.relative` — *today 1:33 AM* · *yesterday* · *Sep 9*),
    /// labelled with this row's own verb. nil when the stamp is unreadable —
    /// the face draws nothing rather than a lie (TimeStampFace's own rule).
    static func arrived(_ iso: String, now: Date) -> String? {
        guard let date = DateFormatter.variorumISO8601.date(from: iso) else { return nil }
        return "arrived " + TimeStampFace.relative(date, now: now)
    }

    /// The expansion's tail when more wait than the window lists — the count
    /// is the door's whole answer, so the listing never pretends to be all.
    static func more(_ hidden: Int) -> String { "and \(hidden) more waiting" }

    // MARK: Receipts (it landed — her receipt setting governs where they show)

    /// Add landed. Says WHERE, because "at the end" is the ruled placement
    /// (§4) — and in a chaptered book the end is outside every chapter (the
    /// unsectioned bin renders last).
    static func added(_ title: String, chaptered: Bool) -> String {
        chaptered
            ? "\u{201C}\(title)\u{201D} added at the end of the book, outside the chapters."
            : "\u{201C}\(title)\u{201D} added at the end of the book."
    }

    /// Dismiss landed. Deliberately says no more than what happened: whether
    /// and how a dismissed note can ring again is PROVISIONAL (P-13ib-U1-1),
    /// and a receipt must stay true under every option on the table.
    static func dismissed(_ title: String) -> String {
        "Dismissed \u{201C}\(title)\u{201D}."
    }

    // MARK: Refusals (nothing happened — always shown, P-2)

    /// The operations layer's REAL refusal, in words that name the road.
    /// `book` is the book's name; `cap` its note cap when it has one.
    static func refusal(for error: Error, book: String?, cap: Int?) -> String {
        let name = book.map { "\u{201C}\($0)\u{201D}" } ?? "This book"
        guard let op = error as? OperationError else {
            return OpsRefusalCopy.message(for: error)
        }
        switch op {
        case .readingAtCapacity:
            let full = cap.map { "\(name) is full \u{2014} its cap is \($0) notes." }
                ?? "\(name) is at its note cap."
            return full + " Raise the note cap in the book\u{2019}s settings (the gear), "
                + "then add it."
        case .lockedReading:
            return "\(name) is finished \u{2014} its table of contents is done, so nothing "
                + "new joins. Reopen it in the book\u{2019}s settings to add notes."
        case .arrivalNotFound:
            return "That note isn\u{2019}t waiting at the door any more \u{2014} "
                + "it was already judged."
        case .containerNotFound:
            return "That note is gone \u{2014} it was deleted, so there\u{2019}s nothing to add."
        case .readingNotFound:
            return "This book is gone \u{2014} it was deleted."
        case .wrongReadingKind:
            return "Only a book has a door \u{2014} a gathering shows its matches "
                + "without holding them."
        default:
            return OpsRefusalCopy.message(for: error)
        }
    }

    /// The registry's honest note for a dispatch nothing renders.
    static let unavailableNote =
        "Arrivals wait atop a book\u{2019}s Index and Book views \u{2014} open the book to judge them."
}

// MARK: - Whether the line shows (one value — §23's composition point)

nonisolated enum ArrivalsLineFace {
    /// The line exists only when something waits. ONE place, so 13i-d's
    /// details toggle (§23 — "details off hides arrivals too") composes here
    /// rather than at each host.
    static func isShown(_ door: Queries.BookArrivals) -> Bool { door.count > 0 }

    /// How many waiting notes the expansion does NOT list.
    static func hidden(_ door: Queries.BookArrivals) -> Int {
        max(0, door.count - door.rows.count)
    }
}

// MARK: - The model

/// The door of ONE book, observed, and its two acts. Holds projections and
/// ids only (the arrival rows' ids, the note titles to say) and calls the
/// operations — no business rule lives here: what may be seated, and when, is
/// `seatArrival`'s, and its refusal is what she hears.
@MainActor
@Observable
final class BookArrivalsModel {
    @ObservationIgnored let session: AppSession
    let readingID: String

    /// The door's answer — the count and (while open) the first rows.
    private(set) var door: Queries.BookArrivals = .none
    /// Open = the expansion lists the rows. COLLAPSED by default and after
    /// every emptying (her clutter mandate): a line that reopened itself
    /// expanded would be the persistent panel the ruling forbids.
    private(set) var expanded = false
    /// Rows whose judgment is in flight — their doors grey until the store
    /// answers, so a double click cannot fire one act twice.
    private(set) var judging: Set<String> = []

    /// How many rows the open line lists (the count is never windowed).
    static let window = 30

    init(session: AppSession, readingID: String) {
        self.session = session
        self.readingID = readingID
    }

    /// What the observation asks for: the count alone while collapsed (the
    /// common occupied state pays for no listing), the window while open.
    var listingLimit: Int { expanded ? Self.window : 0 }

    /// Observe the door. Hosted by the line with `.task(id: expanded)`, so
    /// opening the line restarts the observation with its listing, and the
    /// observation lives exactly as long as a surface shows the line (P3).
    func start() async {
        do {
            for try await value in session.database.observeBookArrivals(
                readingID, limit: listingLimit) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }

    /// Internal so pins drive the door deterministically (hosted `.task`
    /// callbacks don't fire under the test host — the `BookViewModel.adopt`
    /// precedent).
    func adopt(_ value: Queries.BookArrivals) {
        door = value
        judging.formIntersection(value.rows.map(\.id))
        if value.count == 0 { expanded = false }
    }

    /// The line's own click: open to the rows, or fold back to the line.
    func toggle() {
        guard ArrivalsLineFace.isShown(door) else { return }
        expanded.toggle()
    }

    /// **Add** — seat the arrival: the note lands at the END, unsectioned
    /// (§4). The receipt says where; a refusal is the operation's own, in
    /// words that name the road (capacity → raise the cap; finished →
    /// reopen).
    func seat(_ arrival: Queries.BookArrival, book: Reading?, chaptered: Bool) async {
        guard judging.insert(arrival.id).inserted else { return }
        defer { judging.remove(arrival.id) }
        do {
            try await session.runner.run { ops in try ops.seatArrival(arrival.id) }
            session.status.receipt(ArrivalsCopy.added(arrival.title, chaptered: chaptered))
        } catch {
            session.status.refuse(ArrivalsCopy.refusal(
                for: error, book: book?.name, cap: book?.maxPosts))
        }
    }

    /// **Dismiss** — tombstone the arrival row: the decision record (§4).
    func dismiss(_ arrival: Queries.BookArrival, book: Reading?) async {
        guard judging.insert(arrival.id).inserted else { return }
        defer { judging.remove(arrival.id) }
        do {
            try await session.runner.run { ops in try ops.dismissArrival(arrival.id) }
            session.status.receipt(ArrivalsCopy.dismissed(arrival.title))
        } catch {
            session.status.refuse(ArrivalsCopy.refusal(
                for: error, book: book?.name, cap: book?.maxPosts))
        }
    }
}

// MARK: - The face

/// **The Arrivals line** — atop the book's Index pane and its Book spread.
/// Draws NOTHING when the door is empty; one muted line when it is not;
/// the waiting rows inline when she opens it.
struct BookArrivalsLine: View {
    let model: BookArrivalsModel
    let structure: BookStructureModel

    /// The judgment doors this face renders — the two acts' ONLY renderer,
    /// so the declaration lives with the builder (the `MarkdownActs` /
    /// `BlockHistoryPane` precedent), and the registry walk asserts it.
    static let surfaceCapabilities: [CapabilityID] = [.seatArrival, .dismissArrival]

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// The measure the line's words stand on — the Index pane's own prose
    /// column (640 + 34 a side), so the line reads as the page's first line
    /// rather than window chrome; the spread centres it the same way.
    private static let measure: CGFloat = 640
    private static let sideInset: CGFloat = 34

    var body: some View {
        VStack(spacing: 0) {
            // The observation's anchor: a zero-height view, so the `.task`
            // has something that always appears — even while the door is
            // empty and the line itself draws nothing.
            Color.clear.frame(height: 0)
            if ArrivalsLineFace.isShown(model.door) {
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
                        + ArrivalsCopy.line(count: model.door.count)))
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .help(ArrivalsCopy.lineHelp)
            if model.expanded {
                ForEach(model.door.rows) { arrival in
                    row(arrival)
                }
                let hidden = ArrivalsLineFace.hidden(model.door)
                if hidden > 0 {
                    Text(tokens.chromeLabel(ArrivalsCopy.more(hidden)))
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
        .onDisappear { ArrivalsLineProbe.forget(model.readingID) }
        #endif
    }

    private func row(_ arrival: Queries.BookArrival) -> some View {
        let busy = model.judging.contains(arrival.id)
        return HStack(alignment: .firstTextBaseline, spacing: 8) {
            // The note's NAME is her prose, never chrome — no `chromeLabel`
            // (the 13u3 UNIT B lesson: the Terminal voice would lowercase it).
            Text(arrival.title)
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
                .truncationMode(.tail)
                .help(arrival.title)
            Spacer(minLength: 8)
            if let stamp = ArrivalsCopy.arrived(arrival.arrivedAt, now: Date()) {
                Text(tokens.chromeLabel(stamp))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
                    .fixedSize()
            }
            Button(tokens.chromeLabel(ArrivalsCopy.addVerb)) {
                Task {
                    await model.seat(
                        arrival, book: structure.reading,
                        chaptered: structure.chaptersActive)
                }
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
            .help(ArrivalsCopy.addHelp)
            .disabled(busy)
            Button(tokens.chromeLabel(ArrivalsCopy.dismissVerb)) {
                Task { await model.dismiss(arrival, book: structure.reading) }
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .help(ArrivalsCopy.dismissHelp)
            .disabled(busy)
        }
        .padding(.leading, 18)
        #if DEBUG
        .onAppear {
            ArrivalsLineProbe.recordRow(
                model.readingID, arrival.id,
                [ArrivalsCopy.addVerb, ArrivalsCopy.dismissVerb])
        }
        .onDisappear { ArrivalsLineProbe.forgetRow(model.readingID, arrival.id) }
        #endif
    }

    #if DEBUG
    private func recordLine() {
        ArrivalsLineProbe.recordLine(
            model.readingID,
            text: ArrivalsCopy.line(count: model.door.count),
            expanded: model.expanded)
    }
    #endif
}

#if DEBUG
/// **WHAT THE MOUNTED LINE DREW, AS A TEST ORACLE** (the `TrayRowDoorProbe`
/// pattern, for its measured reason: a hosted SwiftUI tree exposes no
/// accessibility children in this test host, and a composition dump does not
/// evaluate a `ForEach`'s content). Recorded from the line's and each row's
/// own `onAppear`, keyed by the book; cleared on disappear — so "absent" is
/// an honest answer: nothing drew. DEBUG only; the shipping face carries none
/// of it.
@MainActor
enum ArrivalsLineProbe {
    struct Drawn: Equatable {
        var line: String?
        var expanded = false
        /// Arrival row id → the door verbs that row drew.
        var rows: [String: [String]] = [:]
    }

    private(set) static var drawn: [String: Drawn] = [:]

    static func reset() { drawn = [:] }

    static func recordLine(_ readingID: String, text: String, expanded: Bool) {
        drawn[readingID, default: Drawn()].line = text
        drawn[readingID, default: Drawn()].expanded = expanded
    }

    static func recordRow(_ readingID: String, _ rowID: String, _ verbs: [String]) {
        drawn[readingID, default: Drawn()].rows[rowID] = verbs
    }

    static func forgetRow(_ readingID: String, _ rowID: String) {
        drawn[readingID]?.rows[rowID] = nil
    }

    static func forget(_ readingID: String) {
        drawn[readingID] = nil
    }
}
#endif
