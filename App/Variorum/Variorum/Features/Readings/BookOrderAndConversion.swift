//
//  BookOrderAndConversion.swift
//  Variorum
//
//  Phase 13c, Batch 2D — two book-shaped faces that belong together
//  because both are about a book's membership and ordering being
//  something she can shape:
//
//  1. **The order vocabulary (A31)** — *"see a book either by its saved
//     custom order or by an attribute like time to freely change the order
//     of it - should be more like lenses where the order can be saved."*
//     The attribute half is a FACE over machinery that has shipped since
//     Phase 2 (`reading.sort_field` + `setReadingSort`); the lens half is
//     the read-time override (`Queries.ReadingOrder`) plus one deliberate
//     save door.
//  2. **The smart→curated conversion offer (C2/N38)** — the one sheet both
//     doors (the shelf's deliberate menu item, the navigator's
//     "+ new chapter") open, per the memo's §3.
//

import SwiftUI
import VariorumCore

// MARK: - The order vocabulary (A31)

/// The reading orders offered anywhere a book's order is chosen — ONE list,
/// so the shelf, the navigator and any future door can never drift.
///
/// The list itself is inherited verbatim from the Phase 10 sidebar's
/// `ReadingsSection`, which was retired at Phase 13's IA rework (Shelf ·
/// Library · Pool · Blocks). **That took the app's ONLY sort door with
/// it** — `setReadingSort` has had no reachable face since, which is a
/// large part of why A31 reads as a missing feature rather than a missing
/// button. The book's own navigator is its home now.
enum BookOrderChoices {
    struct Choice: Identifiable, Equatable {
        let label: String
        let order: Queries.ReadingOrder
        var id: String { "\(order.field.rawValue)-\(order.direction.rawValue)" }
    }

    /// `manual` leads: it is the book's HAND order, which is the thing the
    /// other choices are alternatives to.
    static let all: [Choice] = [
        .init(label: "Manual order", order: .init(field: .manual, direction: .asc)),
        .init(label: "Entry date ↑", order: .init(field: .entryDate, direction: .asc)),
        .init(label: "Entry date ↓", order: .init(field: .entryDate, direction: .desc)),
        .init(label: "Created ↑", order: .init(field: .createdAt, direction: .asc)),
        .init(label: "Created ↓", order: .init(field: .createdAt, direction: .desc)),
        .init(label: "Last touched ↓", order: .init(field: .lastTouched, direction: .desc)),
        .init(label: "Major revision ↓", order: .init(field: .lastMajorRevision, direction: .desc)),
    ]

    /// What to call an order in chrome. Unlisted pairs (a stored
    /// `entry_date DESC` on a book created before this list, say) still get
    /// a readable name rather than a raw enum.
    static func label(for order: Queries.ReadingOrder) -> String {
        if let known = all.first(where: { $0.order == order }) { return known.label }
        let arrow = order.direction == .desc ? "↓" : "↑"
        return "\(order.field.rawValue.replacingOccurrences(of: "_", with: " ")) \(arrow)"
    }

    /// A smart book has no hand order at all: `manual` on one falls back to
    /// created-ascending (the ratified Phase 4 rule), so calling it
    /// "manual" would be a small lie in the one place she is choosing.
    static func storedLabel(for reading: Reading?) -> String {
        guard let reading else { return "book's order" }
        let stored = Queries.ReadingOrder(
            field: reading.sortField, direction: reading.sortDir)
        if reading.kind == .smart, reading.sortField == .manual { return "as collected" }
        return label(for: stored)
    }
}

// MARK: - The smart→curated conversion offer (C2/N38)

/// What the offer completes after converting — the act she actually asked
/// for, finished by the choreography (P-2: a door performs the act,
/// including the steps it needs on the way).
enum SmartConversionFollowUp: Equatable {
    case none
    case createChapter
}

/// How many posts a smart book is collecting RIGHT NOW — the number the
/// offer promises will stay.
///
/// It deliberately runs the book's own assembly rather than any cheaper
/// count, so the sentence "its current N posts stay" is the count of rows
/// the conversion will actually mint, by construction. **The shelf's own
/// `postCount` cannot answer this**: it counts `reading_post` rows, and a
/// smart book has none — it would have said "0 posts stay" on every book
/// this sheet is ever shown for. One-shot, on a deliberate press (the
/// `bookWordCounts` cost tier — never in a held observation).
enum SmartConversionCount {
    static func collected(_ session: AppSession, readingID: String) async -> Int {
        (try? await session.database.read { db in
            try Queries.assembleReading(db, readingID: readingID).count
        }) ?? 0
    }
}

/// The ONE conversion sheet. Both doors present it; neither decides
/// anything itself — it reports (`onConfirm`) and composition acts.
///
/// PROVISIONAL in full (QUESTIONS #46): the memo's five rulings are hers,
/// and each is implemented at its most spec-defensible reading with the
/// alternative recorded rather than guessed away.
struct SmartConversionOfferSheet: View {
    let reading: Reading
    /// The number of posts it is collecting right now — "its current N
    /// posts stay" is the sentence that makes the trade concrete.
    let memberCount: Int
    let followUp: SmartConversionFollowUp
    /// `(keepCollecting, collectingName)`.
    let onConfirm: (Bool, String?) -> Void

    @State private var keepCollecting = true
    @State private var collectingName = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            Text(explanation)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Toggle("Keep a fresh smart book collecting this filter", isOn: $keepCollecting)
            if keepCollecting {
                TextField(defaultCollectingName, text: $collectingName)
                    .textFieldStyle(.roundedBorder)
                Text("New matches will keep arriving there instead.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button(confirmLabel) {
                    let name = collectingName.trimmingCharacters(in: .whitespacesAndNewlines)
                    onConfirm(keepCollecting, name.isEmpty ? nil : name)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(minWidth: 420)
        .onAppear { collectingName = "" }
    }

    private var defaultCollectingName: String { "\(reading.name) (collecting)" }

    private var title: String {
        switch followUp {
        case .createChapter: "Add chapters to “\(reading.name)”?"
        case .none: "Convert “\(reading.name)” to a hand-shaped book?"
        }
    }

    private var confirmLabel: String {
        switch followUp {
        case .createChapter: "Convert & Add Chapter"
        case .none: "Convert"
        }
    }

    private var explanation: String {
        let posts = memberCount == 1 ? "1 note" : "\(memberCount) notes"
        let opener: String
        switch followUp {
        case .createChapter:
            opener = "Chapters need a book that holds its notes by hand — a smart "
                + "book's membership is its filter's answer, so there is nothing for "
                + "a chapter to hold on to. Converting fixes that."
        case .none:
            opener = "A smart book collects by its filter. A hand-shaped book holds "
                + "the notes you put in it — so it can have chapters, an order you "
                + "drag, and a note cap."
        }
        return opener
            + "\n\nIts current \(posts) stay, in the order you're looking at them. "
            + "New tag matches will stop arriving here."
    }
}
