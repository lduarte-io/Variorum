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
        if reading.kind == .gathering, reading.sortField == .manual { return "as collected" }
        return label(for: stored)
    }
}

// MARK: - BIND INTO A BOOK (13i-b U3 — the sitting record §3, §14.6, §19.6)
//
// The door that used to be "Convert to a Hand-Shaped Book…" (13c 2D, C2/N38
// shape A). The sitting record §14.6 RECAST it: binding a gathering into a
// book KEEPS COLLECTING (her 2026-07-30 words honored over N38 shape A's
// stops-collecting) — so the old sheet's "New tag matches will stop arriving
// here." went FALSE at 13i-b U1 (finding F-1), and its default-on "keep a
// fresh smart book collecting this filter" offer began to DOUBLE-collect (the
// sibling showed a match AND the bound book seated it). Both died here; "the
// '(collecting)' offer dies" is the ruling's own clause. The deliberate
// sibling road is the spawn door beside this one ("Make a Book from This
// Gathering…").
//
// The op needed no recast: `convertSmartReadingToCurated` already IS the bind
// (same row — §19.6, pinned — the assembly materialized, the rule left on the
// row, so the book is a LIVING book under U1's intake).

/// What the bind door completes afterwards — the act she actually asked for,
/// finished by the choreography (P-2: a door performs the act, including the
/// steps it needs on the way).
enum BindFollowUp: Equatable {
    case none
    case createChapter
}

/// How many notes a gathering SHOWS right now — the number the bind promises
/// will become members.
///
/// It deliberately runs the gathering's own assembly rather than any cheaper
/// count, so "its N notes become members" is the count of rows the bind will
/// actually mint, by construction. **The shelf's own `postCount` cannot
/// answer this**: it counts `reading_post` rows, and a gathering holds none.
/// One-shot, on a deliberate press (the `bookWordCounts` cost tier — never in
/// a held observation).
enum SmartConversionCount {
    static func collected(_ session: AppSession, readingID: String) async -> Int {
        (try? await session.database.read { db in
            try Queries.assembleReading(db, readingID: readingID).count
        }) ?? 0
    }
}

/// **THE BIND SHEET'S ITEM — and it CARRIES the count** (F-U2-3, 13i-b U3).
///
/// U2's walk saw the old sheet promise "Its current 0 notes" for a gathering
/// showing 2. The count was right; the PLUMBING was not: the door set a
/// separate `@State` count and then the sheet's item, and the sheet read the
/// count inside its content closure — which ran on a view value whose
/// `@State` snapshot predated the count (nothing in the host's body read it,
/// so no re-render captured it). Carrying the count IN the item makes the
/// sheet's content a function of its own parameter: there is no second piece
/// of state to be stale. Pinned red-on-old through the real shelf
/// (`BindDoorTests`).
struct BindOffer: Identifiable, Equatable {
    let reading: Reading
    /// The notes the gathering shows — what becomes membership.
    let count: Int
    let followUp: BindFollowUp
    /// The A31 view order the host is LOOKING through (the book view's), so
    /// the bind freezes the order she sees; nil = the stored order.
    let order: Queries.ReadingOrder?
    /// 13i-c U3 — THE OWNED-NOTES LIMB (the 13i-c plan §3: "the sheet gains
    /// the limb in U3"; the sitting record §3: "owned notes in the assembly
    /// can't materialize, so the confirm lists them: copy in / leave out").
    /// The assembly's notes another book OWNS, named with their owner —
    /// exactly `Queries.bindOwnedNotesPreview`, the set the op's
    /// `ownedNotes:` limb acts on. Empty in the common case.
    var ownedElsewhere: [BindCopy.OwnedNote] = []

    var id: String { reading.id }

    /// The door's one road to an offer: load the count AND the owned-notes
    /// limb, then hand back ONE value — the host assigns it in a single write.
    static func load(
        _ session: AppSession, reading: Reading,
        followUp: BindFollowUp = .none, order: Queries.ReadingOrder? = nil
    ) async -> BindOffer {
        let count = await SmartConversionCount.collected(session, readingID: reading.id)
        let owned = (try? await session.database.read { db in
            try Queries.bindOwnedNotesPreview(db, readingID: reading.id, order: order)
        }) ?? []
        return BindOffer(
            reading: reading, count: count, followUp: followUp, order: order,
            ownedElsewhere: owned.map { BindCopy.OwnedNote(title: $0.title, owner: $0.owner.name) })
    }
}

/// Every word the two strengthening doors say (the bind and the spawn), in
/// one home. Wording PROVISIONAL — 13s re-voices the app; the TRUTH is ruled
/// (the sitting record §3, §14.6, §25 lesson 3).
nonisolated enum BindCopy {
    /// The registry's verbs.
    static let bindVerb = "Bind into a Book\u{2026}"
    static let spawnVerb = "Make a Book from This Gathering\u{2026}"

    static func title(_ name: String, followUp: BindFollowUp) -> String {
        switch followUp {
        case .none: "Bind \u{201C}\(name)\u{201D} into a book?"
        case .createChapter: "Bind \u{201C}\(name)\u{201D} into a book to add chapters?"
        }
    }

    static func confirm(_ followUp: BindFollowUp) -> String {
        switch followUp {
        case .none: "Bind into a Book"
        case .createChapter: "Bind & Add Chapter"
        }
    }

    /// The sheet's body — the trade made concrete, and the truth §14.6 rules:
    /// the bound book KEEPS COLLECTING.
    static func explanation(
        count: Int, followUp: BindFollowUp, hearsActs: Bool = true
    ) -> String {
        let opener: String = switch followUp {
        case .none:
            "A gathering shows every note its rule matches and holds none of them, so it "
                + "can\u{2019}t be arranged by hand. Bind it into a book to take it in hand: "
        case .createChapter:
            "Chapters need a book that holds its notes \u{2014} a gathering only shows the "
                + "notes its rule matches. Bind it into a book and the chapter follows: "
        }
        let members: String = switch count {
        case 0: "it shows no notes right now, so the book starts empty"
        case 1: "the 1 note it shows becomes a member, ready to reorder and give chapters"
        default:
            "the \(count) notes it shows become members, in the order you\u{2019}re looking "
                + "at them, ready to reorder and give chapters"
        }
        return opener + members + ".\n\n"
            + (hearsActs ? keepsCollecting : collectsOnlyAtCatchUp)
    }

    /// **Whether the bound book's "keeps collecting" promise is true**
    /// (13i-d U6 — KnownIssues row 111): only a READABLE rule that an
    /// applying act can reach (`RuleGrammar.hearsApplyingActs` — a tag or a
    /// star term). A rule of legacy terms only collects at catch-ups. (No
    /// rule / a malformed one keep the shipped words — their own corners,
    /// outside the row.)
    static func hearsActs(_ reading: Reading) -> Bool {
        if case .rule(let term) = RuleGrammar.read(reading.querySpec) {
            return RuleGrammar.hearsApplyingActs(term)
        }
        return true
    }

    /// The legacy-only rule's truth (row 111): no tagging act reaches it, so
    /// new matches come in only when the book CATCHES UP.
    static let collectsOnlyAtCatchUp =
        "It stays the same book on your Bookcase \u{2014} same name, same star. Its rule "
        + "names no tag or star, so no tagging brings new notes in: it collects only when "
        + "it catches up (reopened, restored, or its rule edited)."


    /// The sentence F-1 replaced ("New tag matches will stop arriving here."
    /// — false since U1). Lesson 3's truth, in the door's words.
    static let keepsCollecting =
        "It stays the same book on your Bookcase \u{2014} same name, same star \u{2014} and it "
        + "keeps collecting after you bind it: new notes that match its rule join at the end."

    static func bound(
        _ name: String, count: Int, copied: Int = 0, leftOut: Int = 0, hearsActs: Bool = true
    ) -> String {
        let notes = count == 1 ? "1 note" : "\(count) notes"
        var limb: [String] = []
        if copied > 0 { limb.append(copied == 1 ? "1 came in as a copy" : "\(copied) came in as copies") }
        if leftOut > 0 {
            limb.append(leftOut == 1
                ? "1 was left out \u{2014} another book owns it"
                : "\(leftOut) were left out \u{2014} other books own them")
        }
        let aside = limb.isEmpty ? "" : " (" + limb.joined(separator: "; ") + ")"
        return "\u{201C}\(name)\u{201D} is a book now \u{2014} \(notes) bound in, in the order "
            + "you had them\(aside). "
            + (hearsActs ? "It keeps collecting." : "It collects only when it catches up.")
    }

    // MARK: The bind's OWNED-NOTES LIMB (13i-c U3 — the plan §3, sitting §3)

    /// A note of the assembly another book owns, named with its owner (the
    /// app's own value, mapped from `Queries.OwnedElsewhereNote`).
    struct OwnedNote: Equatable, Sendable {
        let title: String
        let owner: String
    }

    static let ownedLead =
        "These notes belong to books that own them, so they can\u{2019}t simply join this one:"
    static func ownedLine(_ note: OwnedNote) -> String {
        "\(note.title) \u{2014} owned by \u{201C}\(note.owner)\u{201D}"
    }
    static let leaveOutChoice = "leave them out"
    static let copyInChoice = "copy them in"
    /// What each choice does, said whole (P-13ic-4: LEAVE OUT is the default
    /// — copies are ceremonies, never silent).
    static let leaveOutMeans =
        "Left out, they won\u{2019}t be in the book \u{2014} they stay where they are."
    static let copyInMeans =
        "Copied in, each gets its own copy here (tags and all); the originals stay with "
        + "the books that own them."

    /// The members the bind will make under a choice: the shown notes,
    /// minus the owned ones when they are left out (copies are members).
    static func memberCount(shown: Int, owned: Int, choice: Operations.BindOwnedNotes) -> Int {
        choice == .copyIn ? shown : max(0, shown - owned)
    }

    /// The teaching moment (the sitting record §3, verbatim): a hand-drag
    /// inside a gathering is answered with this OFFER, whose act opens the
    /// bind's confirm.
    static let teachingOffer = "Turn into a book to arrange by hand?"
    static let teachingAction = "Bind into a Book\u{2026}"

    // The spawn ("Make a book from this gathering" — the sitting record §3).
    static func spawnTitle(_ name: String) -> String { "Make a book from \u{201C}\(name)\u{201D}" }

    /// The spawn sheet's body, per the gathering's RULE STATE (ladder
    /// F-R1-3): the collecting promise is true only of a READABLE rule —
    /// NULL on a BOOK means "collects nothing by itself" (the kill switch's
    /// own asymmetry) and a malformed rule runs no intake (P-13ib-5), so
    /// those arms speak the born-empty truth instead of promising joins.
    /// Whether a rule-less gathering should offer the spawn at all is hers
    /// (bundled beside F-U4-7); these words tell the truth either way.
    static func spawnMessage(for rule: RuleGrammar.ReadResult) -> String {
        switch rule {
        case .rule(let term):
            // 13i-d U6 (row 111): "keep joining" only where an act can reach
            // the rule — a legacy-only rule joins at catch-ups.
            guard RuleGrammar.hearsApplyingActs(term) else {
                return "A new book with the same rule: the notes it matches now join it. Its "
                    + "rule names no tag or star, so later matches join only when it catches "
                    + "up. The gathering stays as it is."
            }
            return "A new book with the same rule: the notes it matches now join it, and "
                + "new matches keep joining. The gathering stays as it is."
        case .none:
            // 13i-c U3 (R-13ic-4, F-U1-3's class): no rule = NOTHING on a
            // gathering — "it shows every note" went false at U1. (The shelf
            // hides this door on a rule-less gathering now; the words stay
            // true for any road that reaches it.)
            return "This gathering has no rule, so it shows nothing. The new book "
                + "starts empty and collects nothing by itself until you give it a rule "
                + "(Edit Rule\u{2026}). The gathering stays as it is."
        case .malformed:
            return "This gathering\u{2019}s rule is stored in a form this version "
                + "can\u{2019}t read, so the new book starts empty and won\u{2019}t collect "
                + "until the rule is fixed. The gathering stays as it is."
        }
    }

    /// PROVISIONAL (P-13ib-U3-2): the sibling's suggested name.
    static func spawnDefaultName(_ name: String) -> String { "\(name) (book)" }
    static let spawnConfirm = "Make Book"
    /// 13i-c U3 — the spawn's OUTFLOW CHOOSER (her item (i): the spawn
    /// OFFERS the choice): its note under the chooser.
    static let spawnOutflowNote =
        "Prefilled with the tags its rule asks for \u{2014} change them as you like, or "
        + "remove them all."

    /// The spawn's receipt — the SAME rule-state vocabulary as the sheet
    /// (ladder round 2, NEW-R2-1: sheet and receipt read ONE
    /// `RuleGrammar.ReadResult`, so no cell can promise a door its rule
    /// state refuses). `.rule` keeps the standing promise (F-R1-3's gate:
    /// only a readable rule collects, P-13ib-5). `.none` is born empty and
    /// MAY name Edit Rule — a NULL spec edits fine, the door works.
    /// `.malformed` is born empty and names NO door: the editor refuses to
    /// edit a malformed rule by design (`ruleIsEditable` false, `needsWrite`
    /// false — a newer client's rule is not this build's to destroy), so the
    /// receipt mirrors its sheet's truth instead of instructing an
    /// impossible act.
    static func spawned(_ name: String, count: Int, rule: RuleGrammar.ReadResult) -> String {
        switch rule {
        case .rule(let term):
            let notes = count == 1 ? "1 note" : "\(count) notes"
            guard RuleGrammar.hearsApplyingActs(term) else {
                return "Made \u{201C}\(name)\u{201D} \u{2014} \(notes) joined; it collects "
                    + "only when it catches up (its rule names no tag or star)."
            }
            return "Made \u{201C}\(name)\u{201D} \u{2014} \(notes) joined, and it keeps collecting."
        case .none:
            return "Made \u{201C}\(name)\u{201D} \u{2014} it starts empty; give it a rule "
                + "(Edit Rule\u{2026}) and it will collect."
        case .malformed:
            return "Made \u{201C}\(name)\u{201D} \u{2014} it starts empty and won\u{2019}t "
                + "collect until the rule is fixed."
        }
    }

    static let bindUnavailable =
        "Only a gathering binds into a book \u{2014} right-click one on the Bookcase."
    static let spawnUnavailable =
        "A book is made from a gathering \u{2014} right-click one on the Bookcase."
}

/// **THE BIND SHEET** — both doors present it (the shelf's menu item and the
/// book navigator's "+ new chapter"), and the teaching offer opens it. It
/// decides nothing itself: it reports (`onConfirm`) and composition acts.
struct BindIntoBookSheet: View {
    let offer: BindOffer
    /// Reports the press WITH the owned-notes choice (13i-c U3 — the limb).
    let onConfirm: (Operations.BindOwnedNotes) -> Void
    /// The limb's choice — LEAVE OUT by default (P-13ic-4).
    @State private var ownedNotes: Operations.BindOwnedNotes = .leaveOut

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(BindCopy.title(offer.reading.name, followUp: offer.followUp))
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            ChromeNotice(
                tokens: tokens,
                text: BindCopy.explanation(
                    count: memberCount, followUp: offer.followUp,
                    hearsActs: BindCopy.hearsActs(offer.reading)),
                ink: tokens.ink, lines: 10)
            if !offer.ownedElsewhere.isEmpty {
                ownedLimb
            }
            HStack {
                Spacer()
                Button(tokens.chromeLabel("Cancel")) { dismiss() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                Button(tokens.chromeLabel(BindCopy.confirm(offer.followUp))) {
                    onConfirm(ownedNotes)
                    dismiss()
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(width: 460, alignment: .leading)
        .background(tokens.surface)
        #if DEBUG
        .onAppear { record() }
        .onChange(of: ownedNotes) { _, _ in record() }
        #endif
    }

    /// The members the bind will make under the current choice.
    private var memberCount: Int {
        BindCopy.memberCount(
            shown: offer.count, owned: offer.ownedElsewhere.count, choice: ownedNotes)
    }

    /// THE OWNED-NOTES LIMB: the notes listed with their owners, and the
    /// two-way choice (leave out · copy in), each said whole.
    private var ownedLimb: some View {
        VStack(alignment: .leading, spacing: 6) {
            ChromeNotice(tokens: tokens, text: BindCopy.ownedLead, ink: tokens.ink, lines: 2)
            ScrollView {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(Array(offer.ownedElsewhere.enumerated()), id: \.offset) { _, note in
                        // A note's title is her prose — never `chromeLabel`'d.
                        Text("\u{00B7} " + BindCopy.ownedLine(note))
                            .font(tokens.small)
                            .foregroundStyle(tokens.ink)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(maxHeight: 140)
            HStack(spacing: 6) {
                VoicedChip(
                    tokens: tokens, text: BindCopy.leaveOutChoice, on: ownedNotes == .leaveOut,
                    action: { ownedNotes = .leaveOut }, lines: 1)
                VoicedChip(
                    tokens: tokens, text: BindCopy.copyInChoice, on: ownedNotes == .copyIn,
                    action: { ownedNotes = .copyIn }, lines: 1)
            }
            ChromeNotice(
                tokens: tokens,
                text: ownedNotes == .copyIn ? BindCopy.copyInMeans : BindCopy.leaveOutMeans,
                lines: 3)
        }
    }

    #if DEBUG
    private func record() {
        BindDoorProbe.shown = .init(
            readingID: offer.reading.id, count: offer.count,
            title: BindCopy.title(offer.reading.name, followUp: offer.followUp),
            body: BindCopy.explanation(
                count: memberCount, followUp: offer.followUp,
                hearsActs: BindCopy.hearsActs(offer.reading)),
            confirm: BindCopy.confirm(offer.followUp),
            owned: offer.ownedElsewhere.map(BindCopy.ownedLine),
            ownedChoice: ownedNotes)
    }
    #endif
}

// MARK: - MAKE A BOOK FROM THIS GATHERING — the spawn sheet (13i-c U3)

/// **THE SPAWN SHEET'S ITEM** (13i-c U3 — her item (i): the spawn OFFERS the
/// outflow choice, prefilled). Carries everything the sheet shows — the
/// gathering, the suggested name, the wing's live tags and the PREFILL — so
/// the sheet reads only its item (the `BindOffer` lesson).
struct SpawnOffer: Identifiable, Equatable {
    let source: Reading
    let defaultName: String
    /// The gathering's wing's live tags — the chooser's choices.
    let tags: [Tag]
    /// `ShelfViewModel.spawnPrefill`: the rule's POSITIVE tags, live-filtered.
    let prefill: [String]

    var id: String { source.id }

    static func load(_ session: AppSession, gathering: Reading) async -> SpawnOffer {
        let (tags, prefill) = (try? await session.database.read { db in
            (try Queries.allTags(db).filter { $0.wingId == gathering.wingId },
             try ShelfViewModel.spawnPrefill(db, gathering: gathering))
        }) ?? ([], [])
        return SpawnOffer(
            source: gathering, defaultName: BindCopy.spawnDefaultName(gathering.name),
            tags: tags, prefill: prefill)
    }
}

/// The spawn's sheet: the name, the truth per the rule's state, and the
/// OUTFLOW CHOOSER prefilled with the rule's positive tags, editable before
/// the mint. It decides nothing — it reports the name and the chosen set.
struct SpawnBookSheet: View {
    let offer: SpawnOffer
    let onConfirm: (_ name: String, _ outflow: [String]) -> Void

    @State private var name: String
    @State private var outflow: OutflowDraft
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    init(offer: SpawnOffer, onConfirm: @escaping (_ name: String, _ outflow: [String]) -> Void) {
        self.offer = offer
        self.onConfirm = onConfirm
        _name = State(initialValue: offer.defaultName)
        _outflow = State(initialValue: OutflowDraft(offer.prefill))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    private func label(_ id: String) -> String {
        RuleEditorCopy.tag(path: offer.tags.first { $0.id == id }?.path)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(BindCopy.spawnTitle(offer.source.name))
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            TextField("Name", text: $name)
            ChromeNotice(
                tokens: tokens,
                text: BindCopy.spawnMessage(for: RuleGrammar.read(offer.source.querySpec)),
                ink: tokens.ink, lines: 6)
            Rectangle().fill(tokens.line).frame(height: 1)
            OutflowChooser(tokens: tokens, draft: $outflow, tags: offer.tags, label: label)
            ChromeNotice(tokens: tokens, text: BindCopy.spawnOutflowNote, lines: 2)
            HStack {
                Spacer()
                Button(tokens.chromeLabel("Cancel")) { dismiss() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(.cancelAction)
                Button(tokens.chromeLabel(BindCopy.spawnConfirm)) {
                    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    onConfirm(trimmed.isEmpty ? offer.defaultName : trimmed, outflow.ids)
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
        .onAppear { record() }
        .onChange(of: outflow) { _, _ in record() }
        #endif
    }

    #if DEBUG
    private func record() {
        SpawnSheetProbe.shown = .init(
            sourceID: offer.source.id, name: name, outflow: outflow.ids.map(label))
    }
    #endif
}

#if DEBUG
/// **THE BIND DOOR, AS A TEST ORACLE** (13i-b U3 — F-U2-3's pin). Two halves:
/// the shelf's door function, published by the mounted shelf (its `@State`
/// is unreachable from outside — the `TrashConfirmEdgeTests` note), and what
/// the presented sheet promised, recorded on appear. DEBUG only; the shipping
/// door carries none of it.
@MainActor
enum BindDoorProbe {
    struct Shown: Equatable {
        var readingID: String
        var count: Int
        var title = ""
        var body = ""
        var confirm = ""
        /// 13i-c U3 — the owned-notes limb as drawn (empty when absent).
        var owned: [String] = []
        var ownedChoice: Operations.BindOwnedNotes = .leaveOut
    }

    static var openShelfDoor: ((Reading) -> Void)?
    static var shown: Shown?
}

/// **WHAT THE MOUNTED SPAWN SHEET OFFERED** (13i-c U3): the prefilled
/// outflow, as drawn. DEBUG only.
@MainActor
enum SpawnSheetProbe {
    struct Shown: Equatable {
        var sourceID: String
        var name: String
        var outflow: [String]
    }

    static var shown: Shown?
}
#endif
