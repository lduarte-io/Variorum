//
//  DuplicateBook.swift
//  Variorum
//
//  13i-c U4 — DUPLICATE BOOK… (the sitting record §6: "non-owned → SHALLOW (a
//  sibling pointing at the same notes; 'Duplicate with copies' optional for a
//  divergent fork); owned → DEEP ONLY (family copies with lineage; the
//  duplicate born non-owned). A gathering: no duplicate op (§3)." The 13i-c
//  plan §6; PROVISIONAL P-13ic-7 — the duplicate carries the book's
//  CONFIGURATION, never its state).
//
//  The door is the shelf row's menu: a name prompt (E13's guard — refuse and
//  keep) with a "with copies of its notes" checkbox, off by default on a
//  plain book; an OWNED book offers "Duplicate with Copies…" only (the
//  checkbox on and fixed — the operation refuses a shallow duplicate of an
//  owned book, `ownedBookDuplicatesDeep`, so the door never offers one, P-2).
//  Three pieces (P-9): the WORDS (`DuplicateBookCopy`, pure), the ACT
//  (`DuplicateBookDoor`), the FACE (`DuplicateBookSheet`).
//

import SwiftUI
import VariorumCore

// MARK: - The words

/// Every sentence Duplicate Book… says. Wording PROVISIONAL (13s); the truths
/// are ruled (§6; the edit law, §2 — a shallow duplicate is the same notes).
nonisolated enum DuplicateBookCopy {
    static func quoted(_ name: String) -> String { "\u{201C}\(name)\u{201D}" }

    /// The registry's verb — a plain book's door.
    static let verb = "Duplicate Book\u{2026}"
    /// An OWNED book's door (deep only).
    static let withCopiesVerb = "Duplicate with Copies\u{2026}"

    /// The per-target word: an owned book offers only the copies shape.
    static func verb(owned: Bool) -> String { owned ? withCopiesVerb : verb }

    static func title(_ name: String) -> String { "Duplicate \(quoted(name))" }

    /// The name the prompt starts with.
    static func suggestedName(_ name: String) -> String { "\(name) copy" }

    static let withCopiesToggle = "With copies of its notes"

    /// What the duplicate will be — said for the shape the checkbox shows.
    static func lines(name: String, owned: Bool, deep: Bool) -> [String] {
        let shape: String
        if owned {
            shape = "\(quoted(name)) owns its notes, so its duplicate carries copies of them "
                + "\u{2014} each linked to its original, which stays here."
        } else if deep {
            shape = "Each note gets its own linked copy in the duplicate; the originals stay "
                + "where they are."
        } else {
            shape = "The duplicate holds the same notes \u{2014} editing a note in either book "
                + "edits it in both. Check the box for copies that can go their own way."
        }
        return [
            shape,
            "It\u{2019}s a new book with this one\u{2019}s settings and chapters \u{2014} not owned, "
                + "not finished, unshelved.",
        ]
    }

    static func notes(_ count: Int) -> String { count == 1 ? "1 note" : "\(count) notes" }

    /// The brief's receipts: "“X copy” — N notes, the same notes" / "… N copies".
    static func duplicated(name: String, notes count: Int, deep: Bool) -> String {
        deep
            ? "\(quoted(name)) \u{2014} \(count == 1 ? "1 copy" : "\(count) copies")."
            : "\(quoted(name)) \u{2014} \(notes(count)), the same notes."
    }

    static let unavailableNote =
        "A book duplicates from its row's menu on the Bookcase \u{2014} a gathering is made again from its "
        + "rule instead."
}

// MARK: - The act

/// What the prompt was opened FOR — the sheet's whole item.
nonisolated struct DuplicateBookOffer: Identifiable, Equatable, Sendable {
    let readingID: String
    let name: String
    let owned: Bool
    var id: String { readingID }

    /// A shallow duplicate is offered only on a plain book (§6).
    var offersShallow: Bool { !owned }
}

/// What a duplicate came to — the receipt, or the refusal (refuse and keep:
/// the sheet stays up with the words, so a taken name is re-typed in place).
nonisolated enum DuplicateOutcome: Equatable, Sendable {
    case landed(String)
    case refused(String)
}

@MainActor
enum DuplicateBookDoor {
    /// **Duplicate** — E13's name guard and the op in ONE runner closure (no
    /// other write lands between the read and the insert).
    static func perform(
        session: AppSession, offer: DuplicateBookOffer, name: String, deep: Bool
    ) async -> DuplicateOutcome {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let named = trimmed.isEmpty ? DuplicateBookCopy.suggestedName(offer.name) : trimmed
        let deepAct = deep || offer.owned
        let database = session.database
        do {
            let (duplicate, count) = try await session.runner.run { ops -> (Reading, Int) in
                try ops.assertBookNameIsFree(named)
                let result = try ops.duplicateReading(offer.readingID, name: named, deep: deepAct)
                return (result.reading, try database.read { db in
                    try Queries.liveMemberNoteCount(db, readingID: result.reading.id)
                })
            }
            return .landed(DuplicateBookCopy.duplicated(
                name: duplicate.name, notes: count, deep: deepAct))
        } catch {
            return .refused(OpsRefusalCopy.message(for: error))
        }
    }
}

// MARK: - The face

struct DuplicateBookSheet: View {
    let session: AppSession
    let offer: DuplicateBookOffer

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var withCopies = false
    @State private var refusal: String?

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    private var deep: Bool { withCopies || offer.owned }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // The book's name is hers — never chrome-labelled.
            Text(DuplicateBookCopy.title(offer.name))
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
                .onSubmit { duplicate() }
            // 13i-c U4 walk (W-3): the checkbox's words are chrome — voiced.
            Toggle(tokens.chromeLabel(DuplicateBookCopy.withCopiesToggle), isOn: Binding(
                get: { deep }, set: { withCopies = $0 }))
                .disabled(offer.owned)
            ForEach(Array(DuplicateBookCopy.lines(
                name: offer.name, owned: offer.owned, deep: deep).enumerated()), id: \.offset) { _, line in
                ChromeNotice(tokens: tokens, text: line, lines: 3)
            }
            if let refusal {
                Text(refusal)
                    .font(tokens.small)
                    .alarmVoice()
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Spacer()
                Button(tokens.chromeLabel("Cancel")) { dismiss() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(.cancelAction)
                Button(tokens.chromeLabel("Duplicate")) { duplicate() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(width: 440, alignment: .leading)
        .background(tokens.surface)
        .onAppear {
            name = DuplicateBookCopy.suggestedName(offer.name)
            withCopies = offer.owned
        }
    }

    private func duplicate() {
        Task {
            switch await DuplicateBookDoor.perform(
                session: session, offer: offer, name: name, deep: deep) {
            case .landed(let receipt):
                session.status.receipt(receipt)
                dismiss()
            case .refused(let words):
                refusal = words
            }
        }
    }
}
