//
//  BookSettingsSheet.swift
//  Variorum
//
//  The navigator's settings leg (R43) — moved out of `BookView.swift` at
//  13i-c U3 (P-9: that file was 2,600 lines and this sheet grew two
//  sections).
//
//  13i-c U3 — THE BOOK SETTINGS SHEET (the 13i-c plan §7 U3 row; the sitting
//  record §4 "the COLLECTING pane", §5, §6; her post-close ruling 2 — the
//  DISCOVERABILITY report: "the book's own ⚙ Book Settings sheet carries NO
//  rule/dial/auto-tag … she could not find it from inside the book"). The
//  sheet is the SAME pane for a book and a gathering (§4: "its rule IS the
//  object, so binding keeps the user's mental map"):
//
//  - Name · Word target · Note cap — as shipped.
//  - **COLLECTING**, written as sentences (`CollectingCopy`): "Gathers from:
//    …" · "New matches: …" · "Notes written here are tagged: …" (a book) —
//    or the rule and the HIDE-OWNED toggle (a gathering) — with ONE "Edit…"
//    door into the rule editor.
//  - **STATE**: Finished · Sealed · Owned, their doors drawn from
//    `BookStateDoorSet` and acted through `BookStateDoors` — the SAME brain
//    and confirms the shelf row's menu uses.
//

import GRDB // AsyncValueObservation iteration (13n-c U3: the grant row's held read)
import SwiftUI
import VariorumCore

// MARK: - The Collecting sentences (pure)

/// A gathering's hide-owned toggle, three states (the plan §3 — nil FOLLOWS
/// the global default, `hide_owned_default`, SHOW unless she says otherwise).
nonisolated enum HideOwnedChoice: Equatable, Sendable, CaseIterable {
    case followDefault, show, hide

    init(stored: Bool?) {
        switch stored {
        case nil: self = .followDefault
        case false?: self = .show
        case true?: self = .hide
        }
    }

    /// What `setReadingHideOwned` stores for this choice.
    var stored: Bool? {
        switch self {
        case .followDefault: nil
        case .show: false
        case .hide: true
        }
    }
}

/// One Collecting sentence: a muted label and its value. A value that is
/// HER vocabulary (the rule read aloud — tag paths; the outflow's paths) is
/// never `chromeLabel`'d; a value in the APP's words ("join quietly at the
/// end", "nothing by itself") is voiced like any chrome word (`appWords` —
/// the U3 walk's W-3: "wait at Arrivals" stood capitalised beside lowercased
/// Terminal labels).
nonisolated struct CollectingLine: Equatable, Sendable {
    let label: String
    let value: String
    var appWords: Bool

    init(label: String, value: String, appWords: Bool = false) {
        self.label = label
        self.value = value
        self.appWords = appWords
    }
}

/// Every word the Collecting section says. Wording PROVISIONAL (13s
/// re-voices); the sentences' SHAPE is the sitting record §4's, ruled.
nonisolated enum CollectingCopy {
    static let section = "Collecting"
    static let stateSection = "State"
    static let gathersFromLabel = "Gathers from:"
    static let nothingByItself = "nothing by itself"
    static let unreadableRule = "a rule this version can\u{2019}t read"
    static let taggedNothing = "nothing"
    static let editDoor = "Edit\u{2026}"
    static let hideOwnedLabel = "Notes an owned book holds:"
    /// 13i-d U4 (F-U3-5): the hide-owned row's registry verb — the act its
    /// three chips set (`setReadingHideOwned`). Wording PROVISIONAL (13s).
    static let hideOwnedVerb = "Show or Hide Owned Notes"
    /// The extent fields' faint hint (13i-d U3 — was the fields' titles'
    /// "(blank = none)" suffix).
    static let blankIsNone = "blank = none"

    static func title(isBook: Bool) -> String { isBook ? "Book Settings" : "Gathering Settings" }

    // 13i-d U3 — the doors INTO the sheet (the sitting record §4: "reachable
    // from the book's ⋯ menu and the Bookcase row's context menu").
    /// The registry's verb (the plain book's); a gathering's row says its own.
    static let openVerb = "Book Settings\u{2026}"
    static func openVerb(isBook: Bool) -> String { title(isBook: isBook) + "\u{2026}" }
    static let openUnavailableNote =
        "A book's settings live on the book \u{2014} right-click it on the Bookcase, or use "
        + "the gear on its masthead."

    // 13i-d U3 — THE JOURNAL TRAIT's sentence (the sitting record §10,
    // verbatim: "Entries: date-stamped, named by their day, sorted by date —
    // on/off").
    static let journalTraitVerb = "Date-Stamped Entries"
    static let journalTraitLabel = "Entries:"
    static let journalTraitValue = "date-stamped, named by their day, sorted by date"
    /// The toggle's two words (the sentence's "on/off").
    static func journalTraitState(_ on: Bool) -> String { on ? "on" : "off" }
    static let journalTraitHelp =
        "Notes written here get the day's date, are named by it until you title them, and "
        + "the book sorts by date. Turning it off never changes an entry you already have."

    /// The rule in words — the boolean tree read aloud: tags by their live
    /// path ("(deleted tag)" for a dead one), the star, `not`, and `and` /
    /// `or` with a nested group in parentheses.
    static func ruleWords(_ term: RuleTerm, paths: [String: String]) -> String {
        words(term, paths: paths, nested: false)
    }

    private static func words(_ term: RuleTerm, paths: [String: String], nested: Bool) -> String {
        switch term {
        case .tag(let id):
            return RuleEditorCopy.tag(path: id.isEmpty ? nil : paths[id])
        case .star:
            return RuleEditorCopy.starred
        case .not(let inner):
            return "not " + words(inner, paths: paths, nested: true)
        case .and(let terms), .or(let terms):
            let joiner = if case .and = term { " and " } else { " or " }
            let joined = terms.map { words($0, paths: paths, nested: true) }
                .joined(separator: joiner)
            return nested && terms.count > 1 ? "(\(joined))" : joined
        case .legacyProfile, .legacyEntryDateFrom, .legacyEntryDateTo:
            return RuleEditorCopy.legacy(term)
        }
    }

    /// "Gathers from: …" — the rule, or what its absence means for THIS kind
    /// (a book with no rule collects nothing by itself — the kill switch; a
    /// gathering with no rule shows nothing — R-13ic-4, said whole).
    static func gathersFrom(
        _ rule: RuleGrammar.ReadResult, isBook: Bool, paths: [String: String]
    ) -> CollectingLine {
        switch rule {
        case .rule(let term):
            return CollectingLine(label: gathersFromLabel, value: ruleWords(term, paths: paths))
        case .none:
            return isBook
                ? CollectingLine(label: gathersFromLabel, value: nothingByItself, appWords: true)
                : CollectingLine(label: "", value: RuleEditorCopy.noRuleGathering)
        case .malformed:
            return CollectingLine(label: gathersFromLabel, value: unreadableRule, appWords: true)
        }
    }

    /// "New matches: join quietly at the end / wait at Arrivals" (nil
    /// stored reads AUTO — P-13ib-5).
    static func newMatches(_ seating: IntakeSeating?) -> CollectingLine {
        CollectingLine(
            label: RuleEditorCopy.joinLabel,
            value: seating == .arrivals ? RuleEditorCopy.joinArrivals : RuleEditorCopy.joinAuto,
            appWords: true)
    }

    /// "Notes written here are tagged: #a #b / nothing".
    static func taggedHere(_ ids: [String], paths: [String: String]) -> CollectingLine {
        CollectingLine(
            label: RuleEditorCopy.autoTagLabel,
            value: ids.isEmpty
                ? taggedNothing
                : ids.map { RuleEditorCopy.tag(path: paths[$0]) }.joined(separator: " "),
            appWords: ids.isEmpty)
    }

    /// The Collecting sentences for one reading, in the order they draw.
    static func sentences(for reading: Reading, paths: [String: String]) -> [CollectingLine] {
        let isBook = reading.kind == .book
        var lines = [gathersFrom(RuleGrammar.read(reading.querySpec), isBook: isBook, paths: paths)]
        if isBook {
            lines.append(newMatches(reading.intakeSeating))
            lines.append(taggedHere(reading.autoTagIDs, paths: paths))
        }
        return lines
    }

    /// The hide-owned toggle's three words; the follow-default one says what
    /// the app's default currently is, so the choice is never a riddle.
    static func hideOwnedWord(_ choice: HideOwnedChoice, defaultHides: Bool) -> String {
        switch choice {
        case .followDefault: defaultHides ? "as the app does (hidden)" : "as the app does (shown)"
        case .show: "show them"
        case .hide: "hide them"
        }
    }

    // The STATE section's sentences.
    static let finishedCaption =
        "Finished means the table of contents is done \u{2014} the writing inside can still "
        + "change. A finished book opens as pure text."
    static let finishedWhileSealed =
        "A sealed book stays finished \u{2014} Unseal reopens it."
    static let sealOpenCaption = "Sealed means the book is done."
    static let sealedCaption = "Sealed \u{2014} the book is done; no note in it can change."
    static let ownCaption = "An owned book is the only place its notes live."
    static let ownedCaption = "This book owns its notes \u{2014} each one lives only here."
    static let finishedToggle = "Finished"
    // 13i-e U2 — the State section's ARCHIVED row (R-13ie-1…4; her rider's
    // keep-forever framing: "it's just supposed to not be in the library, but
    // you do want to keep it forever"). The daily Journal's caption is the
    // sitting record §10's own sentence (`BookArchiveCopy.dailyJournalCaption`).
    static let archiveCaption =
        "Archiving keeps it forever \u{2014} off the Bookcase, under Archived, with no countdown."
    static let archivedCaption = "Archived \u{2014} kept under Archived, off the Bookcase."

    static func archiveCaption(for reading: Reading) -> String {
        if Queries.isDailyJournalMintShape(reading) { return BookArchiveCopy.dailyJournalCaption }
        return reading.archivedAt != nil ? archivedCaption : archiveCaption
    }
}

// MARK: - What the sheet draws (13i-d U3 — row 107)

/// **WHICH of the sheet's fields and controls draw, as data** — the face and
/// its DEBUG probe read the same answer, so they can never disagree.
nonisolated enum BookSettingsFace {
    enum Field: String, CaseIterable, Sendable {
        case name = "Name"
        case wordTarget = "Word target"
        case noteCap = "Note cap"
    }

    /// A BOOK draws all three. A GATHERING has no word target or capacity
    /// (the sitting record §3; P-13ic-U3-2 ruled to its letter — KnownIssues
    /// row 107) — except a value ALREADY stored (a 13i-b-era gathering), whose
    /// field stays so it can be cleared: the legacy way out (P-13id-U3-3).
    static func fields(for reading: Reading) -> [Field] {
        guard reading.kind == .gathering else { return Field.allCases }
        var fields: [Field] = [.name]
        if reading.wordTarget != nil { fields.append(.wordTarget) }
        if reading.maxPosts != nil { fields.append(.noteCap) }
        return fields
    }

    /// A gathering has no finish (§3) — the control draws only on one ALREADY
    /// finished, where it is the Reopen door (`BookStateDoorSet`'s own cell).
    static func showsFinished(for reading: Reading) -> Bool {
        reading.kind == .book || reading.locked
    }

    /// 13n-c U3 — whether the grant row draws (P-2 + VX-272 + VX-273). VX-549
    /// made a gathering a grant place, but its place doors (this row, a row
    /// menu's Share…) are not built — the grant sheet's WHERE is its road
    /// (PROVISIONAL MB-18: "expand no other road").
    /// 13n-c Stage B R1 B4: `grantable` is the FENCE's own answer for this
    /// book (`BookSettingsModel.isGrantable` — `Queries.mcpBookFacts`, the one
    /// derivation site the op's refusal and the sheet's offer read), never a
    /// second fence spelled here from the profile and the Private flag (plan
    /// §2: no parallel fence).
    static func showsGrantRow(for reading: Reading, grantable: Bool, canShare: Bool) -> Bool {
        canShare && reading.kind == .book && grantable
    }

    /// The grant row's sentence: "Shared with claude-code (read and suggest)"
    /// or "No client reaches this book."
    static func grantRowCaption(_ reach: [MCPPlaceReach]) -> String {
        reach.isEmpty ? MCPShareCopy.notShared
            : "\(MCPShareCopy.sharedWithLabel) \(MCPShareCopy.clients(reach))"
    }

    /// 13i-e U2 — the State section's Archived row: Archive or Unarchive, from
    /// the ONE archive table (`BookArchiveDoorSet` — the sheet carries no
    /// Delete door, so only its archive half draws here).
    static func archiveDoor(for reading: Reading) -> CapabilityID? {
        BookArchiveDoorSet.rendered(for: BookArchiveFacts(reading))
            .first { $0 == .archiveBook || $0 == .unarchiveBook }
    }
}

// MARK: - The model

/// The sheet's own brain: the Collecting projection (tag paths, the global
/// hide-owned default), the rule editor's door, the hide-owned write, and
/// the state doors. Holds projections and ids; every write is an op's.
@MainActor
@Observable
final class BookSettingsModel {
    @ObservationIgnored let session: AppSession
    let readingID: String
    /// Live paths of every tag the rule and the outflow name.
    private(set) var paths: [String: String] = [:]
    private(set) var hideOwnedDefault = false
    /// 13n-b U2 (R-13nb-4): the book's Private mark (read with the rest;
    /// kept off the `Reading` model so no stale model can ever clear it).
    private(set) var isPrivate = false
    /// 13n-c U3 — who reaches this book now, and how far (the grant row —
    /// `Queries.mcpBookReach`, the ONE rule's why). Held while the sheet is up
    /// (`watchReach`) so a grant made from the row's own Share… shows at once.
    private(set) var reach: [MCPPlaceReach] = []
    /// 13n-c Stage B R1 B4 — whether a grant may name this book NOW, the
    /// fence's own answer (`isGrantable`), held with the reach so a Private
    /// mark or a daily-Journal designation hides the row at once.
    private(set) var grantable = false
    let stateDoors: BookStateDoors

    init(session: AppSession, readingID: String) {
        self.session = session
        self.readingID = readingID
        self.stateDoors = BookStateDoors(session: session)
    }

    /// The one-shot read behind the sentences — re-run whenever the rule,
    /// the outflow or the toggle changes (the host keys it on them).
    func load(for reading: Reading) async {
        let ids = Array(RuleGrammar.tagIDs(of: RuleGrammar.decode(reading.querySpec)))
            + reading.autoTagIDs
        let readingID = readingID
        guard let (paths, hides, marked) = try? await session.database.read({ db in
            (try Queries.tagPaths(db, ids: ids), try Queries.hideOwnedDefault(db),
             try Queries.isBookPrivate(db, readingID: readingID))
        }) else { return }
        self.paths = paths
        hideOwnedDefault = hides
        isPrivate = marked
    }

    /// **13n-c U3 — the grant row's held read** (reading + the grants store
    /// only; never `container`, so never at autosave rate).
    func watchReach() async {
        let id = readingID
        do {
            for try await value in session.database.observe({ db in
                GrantRowFacts(
                    reach: try Queries.mcpBookReach(db, readingID: id),
                    grantable: try Self.isGrantable(db, readingID: id))
            }) {
                if reach != value.reach { reach = value.reach }
                if grantable != value.grantable { grantable = value.grantable }
            }
        } catch {}
    }

    /// The grant row's held facts (one observation — `reading` + the grants
    /// store; never `container`, so never at autosave rate).
    nonisolated struct GrantRowFacts: Equatable, Sendable {
        let reach: [MCPPlaceReach]
        let grantable: Bool
    }

    /// **May a grant name this book?** — the fence's OWN facts
    /// (`Queries.mcpBookFacts`: a live BOOK with no fence — not THE daily
    /// Journal, not Private), the very read `insertMCPGrant` refuses on and
    /// `mcpGrantableBooks` / `mcpFencedBookIDs` filter by. Never re-derived.
    nonisolated static func isGrantable(_ db: Database, readingID: String) throws -> Bool {
        guard let facts = try Queries.mcpBookFacts(db, readingID: readingID) else { return false }
        return facts.fence == nil
    }

    /// Pins hand a reach in (hosted `.task`s don't fire under the test host).
    func adoptReach(_ value: [MCPPlaceReach], grantable: Bool = true) {
        reach = value
        self.grantable = grantable
    }

    /// **The Private row** (13n-b U2 — R-13nb-4): `setBookPrivate` through
    /// the runner; the receipt in the app's voice, or the op's own refusal.
    /// Allowed on a finished, sealed or archived book (PROVISIONAL
    /// P-13nb-U2-1 — the mark protects rather than authors).
    func setPrivate(_ on: Bool, name: String) async {
        let id = readingID
        do {
            let wrote = try await session.runner.run { try $0.setBookPrivate(id, on) }
            isPrivate = on
            if wrote {
                session.status.receipt(on ? PrivateMarkCopy.markedBook(name) : PrivateMarkCopy.clearedBook(name))
            }
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }

    /// The "Edit…" door's editor — the rule editor for THIS reading. The
    /// sheet HANDS it to its host and closes (W-1, the U3 walk): the editor's
    /// "also tag the N current members" offer is a toast on the window, and
    /// a settings sheet left open over it blocked its button (window-modal)
    /// until the toast's clock ran out — so the editor must never open while
    /// this sheet is up.
    func makeRuleEditor() -> RuleEditorModel {
        RuleEditorModel(session: session, readingID: readingID)
    }

    /// **The journal trait's toggle** (13i-d U3 — the sitting record §10:
    /// *"Entries: date-stamped, named by their day, sorted by date — on/off"*).
    /// Through `setJournalTrait`; its refusals SPEAK, named for the book —
    /// the daily Journal's trait is constitutive (`dailyJournalTraitIs
    /// Constitutive`), a finished book's is frozen (`lockedReading`).
    ///
    /// **ON also sorts the book by entry date, newest first** — unless it
    /// already sorts by date (PROVISIONAL P-13id-U3-2): the sentence she
    /// switches on says "sorted by date", and the trait's op writes only the
    /// profile, so without this the row would turn on a sentence that is
    /// false of her book. Newest first is the Create Journal Book door's own
    /// order. OFF leaves the order hers ("flipping it off never rewrites
    /// existing entries" — and never her order either).
    func setJournalTrait(_ on: Bool, reading: Reading) async {
        let id = readingID
        let sortsByDate = reading.sortField == .entryDate
        do {
            try await session.runner.run { ops in
                try ops.setJournalTrait(id, on: on)
                if on, !sortsByDate {
                    try ops.setReadingSort(id, field: .entryDate, direction: .desc)
                }
            }
        } catch {
            session.status.refuse(BookStateCopy.refusal(
                for: error, name: reading.name, sealed: reading.sealedAt != nil))
        }
    }

    /// A gathering's hide-owned toggle (`setReadingHideOwned`; gatherings
    /// only — a book never renders the row).
    func setHideOwned(_ choice: HideOwnedChoice) async {
        let id = readingID
        do {
            try await session.runner.run { ops in try ops.setReadingHideOwned(id, choice.stored) }
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }
}

// MARK: - The face

struct BookSettingsSheet: View {
    /// The REGISTRY acts this sheet renders as `.surface` doors (P-1's walk):
    /// the six state doors (which of each pair — `BookStateDoorSet`) and the
    /// rule editor's door ("Edit…" in the Collecting section).
    static let surfaceCapabilities: [CapabilityID] = BookStateDoorSet.all + [.editRule]
        // 13i-e U2: the State section's Archived row (Archive / Unarchive —
        // `BookArchiveDoorSet`; the sheet draws no Delete).
        + [.archiveBook, .unarchiveBook]
        // 13i-d U3: the journal trait's on/off (§10).
        + [.setJournalTrait]
        // 13i-d U4 (F-U3-5, the adjudication after U3): a GATHERING's
        // hide-owned chips — 13i-c U3's row, undeclared until now.
        + [.setReadingHideOwned]
        // 13n-b U2 (R-13nb-4): the State section's Private row (books only).
        + [.markBookPrivate]
        // 13n-c U3 (R-13n-4's grant face; VX-156 item 2): the grant row's
        // Share… — THE grant sheet pre-filled on this book, over this sheet.
        + [.mcpShareBook]

    let structure: BookStructureModel
    /// The Edit… handoff (W-1): the host presents the editor AFTER this
    /// sheet dismisses. The default does nothing (a pin's mount).
    var onEditRule: (RuleEditorModel) -> Void = { _ in }
    @State private var model: BookSettingsModel
    @State private var nameField = ""
    @State private var wordTargetField = ""
    @State private var maxPostsField = ""
    @State private var parseError: String?
    @State private var seeded = false
    /// 13n-c U3: the grant sheet THIS sheet presents (a sheet over a sheet —
    /// T-U3-7: the window's own grant sheet cannot present while this is up).
    @State private var grantOpening: MCPGrantOpening?
    /// 13n-c U3: the window's road (nil in harness mounts — no grant row).
    @Environment(\.mcpShareRoad) private var mcpShareRoad
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    /// `model` is injectable so a pin can hand in one it already LOADED
    /// (hosted `.task` callbacks don't fire under the test host — the
    /// `RuleEditorModel` precedent); the app passes nothing.
    init(
        structure: BookStructureModel, model: BookSettingsModel? = nil,
        onEditRule: @escaping (RuleEditorModel) -> Void = { _ in }
    ) {
        self.structure = structure
        self.onEditRule = onEditRule
        _model = State(initialValue: model ?? BookSettingsModel(
            session: structure.session, readingID: structure.readingID))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(CollectingCopy.title(isBook: structure.reading?.kind != .gathering))
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            let fields = structure.reading.map(BookSettingsFace.fields(for:))
                ?? BookSettingsFace.Field.allCases
            // 13i-d U3 (the 13i-c walk's polish note): the three fields take
            // the voice — `VoicedField`, the chrome vocabulary's own.
            VStack(alignment: .leading, spacing: 8) {
                ForEach(fields, id: \.self) { field in
                    switch field {
                    case .name:
                        VoicedField(tokens: tokens, label: field.rawValue, text: $nameField)
                    case .wordTarget:
                        VoicedField(
                            tokens: tokens, label: field.rawValue, text: $wordTargetField,
                            prompt: CollectingCopy.blankIsNone)
                    case .noteCap:
                        VoicedField(
                            tokens: tokens, label: field.rawValue, text: $maxPostsField,
                            prompt: CollectingCopy.blankIsNone)
                    }
                }
            }
            if let reading = structure.reading {
                collecting(reading)
                state(reading)
            }
            if let parseError {
                Text(parseError).font(tokens.small).alarmVoice()
            }
            HStack {
                Spacer()
                Button(tokens.chromeLabel("Close")) {
                    if save() { dismiss() }
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(minWidth: 420, alignment: .leading)
        .background(tokens.surface)
        // 13i-d U3: seeded ONCE, from the book itself — on appear when the
        // book is already in hand (the book view's road, the Bookcase's
        // pre-loaded target), else the moment it arrives.
        .onAppear { seedFields() }
        .onChange(of: structure.reading?.id) { _, _ in seedFields() }
        // The sentences' one-shot read, re-keyed on everything they say.
        .task(id: factsKey) {
            if let reading = structure.reading { await model.load(for: reading) }
        }
        .bookStateConfirms(model.stateDoors)
        // 13n-c U3: who reaches the book, held while the sheet is up; and the
        // grant sheet it opens, presented over it.
        .task { await model.watchReach() }
        .sheet(item: $grantOpening) { opening in
            if let road = mcpShareRoad {
                road.sheet(opening) { grantOpening = nil }
            }
        }
        #if DEBUG
        .onAppear { record() }
        .onChange(of: drawnKey) { _, _ in record() }
        #endif
    }

    private var factsKey: String {
        guard let reading = structure.reading else { return "" }
        return [reading.querySpec ?? "", reading.autoTagIds ?? "",
                "\(String(describing: reading.hideOwned))"].joined(separator: "|")
    }

    // MARK: Sections

    private func sectionLabel(_ words: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(tokens.chromeLabel(words))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(1)
            Rectangle().fill(tokens.line).frame(height: 1)
        }
        .padding(.top, 8)
    }

    private func sentence(_ line: CollectingLine) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            if !line.label.isEmpty {
                Text(tokens.chromeLabel(line.label))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                    .fixedSize()
            }
            // Her vocabulary (tag paths) — never `chromeLabel`'d; the app's
            // own words are voiced (W-3).
            Text(line.appWords ? tokens.chromeLabel(line.value) : line.value)
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func collecting(_ reading: Reading) -> some View {
        sectionLabel(CollectingCopy.section)
        // 13i-e U2 — THE VISIBLE PAUSE (R-13ie-4: "every method of auto
        // ingestion should pause, which should be clear to users"). Said
        // first, above the rule it pauses; the explicit add doors are
        // untouched (her amendment). nil where nothing auto-ingests.
        if let paused = BookArchiveCopy.pausedSentence(for: reading) {
            ChromeNotice(tokens: tokens, text: paused, ink: tokens.ink, lines: 3)
        }
        ForEach(Array(CollectingCopy.sentences(for: reading, paths: model.paths).enumerated()),
                id: \.offset) { _, line in
            sentence(line)
        }
        if reading.kind == .gathering {
            // The label on its own line and the three chips under it (W-2,
            // the U3 walk: on one line at the sheet's width the chips
            // truncated to "as the a…" / "show th…").
            VStack(alignment: .leading, spacing: 4) {
                Text(tokens.chromeLabel(CollectingCopy.hideOwnedLabel))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                    .fixedSize()
                HStack(spacing: 6) {
                    ForEach(HideOwnedChoice.allCases, id: \.self) { choice in
                        VoicedChip(
                            tokens: tokens,
                            text: CollectingCopy.hideOwnedWord(
                                choice, defaultHides: model.hideOwnedDefault),
                            on: HideOwnedChoice(stored: reading.hideOwned) == choice,
                            action: { Task { await model.setHideOwned(choice) } }, lines: 1)
                            .lineLimit(1)  // 19g: a one-line chip (P-8)
                            .fixedSize()
                    }
                }
                .padding(.leading, 12)
                // 13i-d U4 (F-U3-5): the chips are a declared act now.
                .help(CapabilityRegistry.capability(.setReadingHideOwned).verb)
            }
        }
        Button(tokens.chromeLabel(CollectingCopy.editDoor)) {
            // W-1: hand the editor to the host and close — the editor opens
            // over the book once this sheet is gone.
            onEditRule(model.makeRuleEditor())
            dismiss()
        }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
            .help(CapabilityRegistry.capability(.editRule).verb)
        // 13i-d U3 — THE JOURNAL TRAIT joins the pane (§10): BOOKS only — a
        // gathering mints no entries, so the row could never act there (P-2).
        if reading.kind == .book {
            journalTraitRow(reading)
        }
    }

    /// §10's sentence, verbatim in shape — "Entries: date-stamped, named by
    /// their day, sorted by date — on/off" — the label muted, the app's words
    /// voiced, and the on/off pair as the sheet's own chips (the hide-owned
    /// row's idiom). A chip acts only when it CHANGES the trait; the daily
    /// Journal's "off" acts and speaks the op's refusal (P-2: fire-and-do).
    private func journalTraitRow(_ reading: Reading) -> some View {
        let on = Queries.hasJournalTrait(reading.profile)
        return VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(tokens.chromeLabel(CollectingCopy.journalTraitLabel))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                    .fixedSize()
                Text(tokens.chromeLabel(CollectingCopy.journalTraitValue))
                    .font(tokens.small)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack(spacing: 6) {
                ForEach([true, false], id: \.self) { value in
                    VoicedChip(
                        tokens: tokens,
                        text: CollectingCopy.journalTraitState(value),
                        on: on == value,
                        action: {
                            guard value != on else { return }
                            Task { await model.setJournalTrait(value, reading: reading) }
                        },
                        lines: 1)
                        .lineLimit(1)  // 19g: a one-line chip (P-8)
                        .fixedSize()
                }
            }
            .padding(.leading, 12)
        }
        .padding(.top, 4)
        .help(CollectingCopy.journalTraitHelp)
    }

    @ViewBuilder
    private func state(_ reading: Reading) -> some View {
        let acts = BookStateDoorSet.rendered(for: BookStateFacts(reading))
        let showsFinished = BookSettingsFace.showsFinished(for: reading)
        let archive = BookSettingsFace.archiveDoor(for: reading)
        // 13i-d U3 (row 107): a section with nothing in it draws no label.
        // 13i-e U2: every reading has the Archived row now (R-13ie-3 —
        // gatherings archive too), so the section always draws.
        if showsFinished || !acts.isEmpty || archive != nil {
            sectionLabel(CollectingCopy.stateSection)
        }
        // FINISHED — one control for the finish pair. While SEALED it stays
        // on and DISABLED with the sealed words: Reopen refuses a sealed
        // book (`readingSealed`), so no Reopen door renders (P-2).
        if showsFinished {
            Toggle(tokens.chromeLabel(CollectingCopy.finishedToggle), isOn: Binding(
                get: { reading.locked },
                set: { finished in
                    let act: CapabilityID = finished ? .finishBook : .reopenBook
                    guard acts.contains(act) else { return }
                    Task { await model.stateDoors.open(act, readingID: reading.id) }
                }))
                .font(tokens.small)
                .disabled(!acts.contains(.finishBook) && !acts.contains(.reopenBook))
            ChromeNotice(
                tokens: tokens,
                text: reading.sealedAt != nil
                    ? CollectingCopy.finishedWhileSealed : CollectingCopy.finishedCaption,
                lines: 3)
        }
        if let seal = acts.first(where: { $0 == .sealBook || $0 == .unsealBook }) {
            stateRow(
                caption: seal == .unsealBook
                    ? CollectingCopy.sealedCaption : CollectingCopy.sealOpenCaption,
                act: seal, readingID: reading.id)
        }
        if let own = acts.first(where: { $0 == .ownBook || $0 == .unownBook }) {
            stateRow(
                caption: own == .unownBook ? CollectingCopy.ownedCaption : CollectingCopy.ownCaption,
                act: own, readingID: reading.id)
        }
        // 13n-b U2 — PRIVATE (R-13nb-4): BOOKS only — a gathering refuses
        // the mark (`wrongReadingKind`), so it never renders (P-2).
        if reading.kind == .book {
            Toggle(tokens.chromeLabel(CapabilityRegistry.capability(.markBookPrivate).verb), isOn: Binding(
                get: { model.isPrivate },
                set: { on in Task { await model.setPrivate(on, name: reading.name) } }))
                .font(tokens.small)
            ChromeNotice(tokens: tokens, text: PrivateMarkCopy.bookCaption, lines: 3)
        }
        // 13n-c U3 — THE GRANT ROW (R-13n-4 named Book Settings a grant face;
        // VX-156 item 2, mockup §2): who reaches this book now, and Share… —
        // THE grant sheet pre-filled. Drawn only where a grant can land (P-2):
        // a BOOK (a gathering's door is not built — VX-549's MB-18), not THE daily Journal and not
        // Private (the fence — the op refuses; the Private row above says why),
        // and only while an approved client exists (VX-272). Settings-class
        // words, no "AI" — the client's own name says who.
        if BookSettingsFace.showsGrantRow(
            for: reading, grantable: model.grantable, canShare: mcpShareRoad?.canShare ?? false) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(tokens.chromeLabel(BookSettingsFace.grantRowCaption(model.reach)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                Button(tokens.chromeLabel(CapabilityRegistry.capability(.mcpShareBook).verb)) {
                    grantOpening = MCPGrantOpening(place: .book(reading.id), origin: .place)
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .secondary))
            }
        }
        // 13i-e U2 — ARCHIVED (the table's Archive / Unarchive; an owned
        // book's Archive asks — "Archive…").
        if let archive {
            stateRow(
                caption: CollectingCopy.archiveCaption(for: reading), act: archive,
                readingID: reading.id,
                label: archive == .archiveBook
                    ? BookStateCopy.archiveDoorLabel(asks: BookStateCopy.archiveAsks(reading)) : nil)
        }
    }

    private func stateRow(
        caption: String, act: CapabilityID, readingID: String, label: String? = nil
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(tokens.chromeLabel(caption))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            Button(tokens.chromeLabel(label ?? CapabilityRegistry.capability(act).verb)) {
                Task { await model.stateDoors.open(act, readingID: readingID) }
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .secondary))
        }
    }

    // MARK: Saving the three fields (as shipped)

    private func seedFields() {
        guard !seeded, let reading = structure.reading else { return }
        seeded = true
        nameField = reading.name
        wordTargetField = reading.wordTarget.map(String.init) ?? ""
        maxPostsField = reading.maxPosts.map(String.init) ?? ""
    }

    /// Round 2, MINOR: unparseable input REFUSES and keeps (ExtentInput —
    /// the one parse rule shared with the shelf's sheet).
    private func save() -> Bool {
        // 13i-d U3: a sheet whose book never arrived (or left) writes nothing
        // — its fields were never seeded, so they say nothing about the book.
        guard structure.reading != nil else { return true }
        guard let target = ExtentInput.parse(wordTargetField),
              let cap = ExtentInput.parse(maxPostsField)
        else {
            parseError = "Extents are plain positive numbers (e.g. 10000) — nothing was changed."
            return false
        }
        let name = nameField.trimmingCharacters(in: .whitespaces)
        Task {
            if !name.isEmpty, name != structure.reading?.name {
                await structure.rename(to: name)
            }
            if target.intValue != structure.reading?.wordTarget {
                await structure.setWordTarget(target.intValue)
            }
            if cap.intValue != structure.reading?.maxPosts {
                await structure.setMaxPosts(cap.intValue)
            }
        }
        return true
    }

    #if DEBUG
    private var drawnKey: String {
        guard let reading = structure.reading else { return "" }
        return factsKey + "|\(reading.locked)|\(String(describing: reading.sealedAt))"
            + "|\(reading.owned)|\(model.paths.count)|\(model.hideOwnedDefault)"
            + "|\(reading.profile ?? "")|\(String(describing: reading.wordTarget))"
            + "|\(String(describing: reading.maxPosts))"
            + "|\(String(describing: reading.archivedAt))"
    }

    private func record() {
        guard let reading = structure.reading else { return }
        BookSettingsProbe.drawn[reading.id] = .init(
            title: CollectingCopy.title(isBook: reading.kind == .book),
            collecting: CollectingCopy.sentences(for: reading, paths: model.paths),
            hideOwned: reading.kind == .gathering
                ? HideOwnedChoice.allCases.map {
                    CollectingCopy.hideOwnedWord($0, defaultHides: model.hideOwnedDefault)
                } : [],
            stateDoors: BookStateDoorSet.rendered(for: BookStateFacts(reading)),
            finishedDisabled: reading.sealedAt != nil,
            journalTrait: reading.kind == .book ? Queries.hasJournalTrait(reading.profile) : nil,
            fields: BookSettingsFace.fields(for: reading).map(\.rawValue),
            finishedShown: BookSettingsFace.showsFinished(for: reading),
            archiveDoor: BookSettingsFace.archiveDoor(for: reading),
            archiveCaption: CollectingCopy.archiveCaption(for: reading),
            paused: BookArchiveCopy.pausedSentence(for: reading))
    }
    #endif
}

// MARK: - The Bookcase's road into the sheet (13i-d U3)

/// **The sheet, opened from OUTSIDE the book** — the Bookcase row's "Book
/// Settings…" (the sitting record §4's second road). The book view hands the
/// sheet its own live `BookStructureModel`; a host that has none makes one
/// here, LOADED before the sheet presents (the `BindOffer.load` rule: the
/// item arrives with its facts, so the sheet's fields never seed from an
/// empty book — an empty Word target saved back would CLEAR the stored one)
/// and observed for the sheet's life by `BookSettingsHost`.
@MainActor
struct BookSettingsTarget: Identifiable {
    let readingID: String
    let structure: BookStructureModel
    var id: String { readingID }

    /// nil when the book is gone (deleted elsewhere between the click and
    /// the read) — the caller speaks the refusal.
    static func load(session: AppSession, readingID: String) async -> BookSettingsTarget? {
        let structure = BookStructureModel(session: session, readingID: readingID)
        guard let snapshot = try? await session.database.read({ db in
            BookStructureModel.Snapshot(
                reading: try Queries.reading(db, id: readingID),
                sections: try Queries.readingSections(db, readingID: readingID),
                deletedSections: try Queries.deletedReadingSections(db, readingID: readingID),
                assignments: try Queries.sectionAssignments(db, readingID: readingID))
        }), snapshot.reading != nil else { return nil }
        structure.adopt(snapshot)
        return BookSettingsTarget(readingID: readingID, structure: structure)
    }
}

/// The sheet over a target's structure, observed while it is up (the book
/// view's own structure is observed by the book view; this one by its host).
struct BookSettingsHost: View {
    let target: BookSettingsTarget
    var onEditRule: (RuleEditorModel) -> Void = { _ in }

    var body: some View {
        BookSettingsSheet(structure: target.structure, onEditRule: onEditRule)
            .task { await target.structure.start() }
    }
}

#if DEBUG
/// **WHAT THE MOUNTED SETTINGS SHEET DREW, AS A TEST ORACLE** (the
/// `RuleEditorProbe` pattern — a hosted SwiftUI tree exposes no
/// accessibility children in this test host). DEBUG only.
@MainActor
enum BookSettingsProbe {
    struct Drawn: Equatable {
        var title: String
        var collecting: [CollectingLine]
        var hideOwned: [String]
        var stateDoors: [CapabilityID]
        var finishedDisabled: Bool
        /// 13i-d U3: the journal-trait row's state — nil when no row is drawn
        /// (a gathering).
        var journalTrait: Bool? = nil
        /// 13i-d U3 (row 107): which of the three fields are drawn, and
        /// whether the Finished control is.
        var fields: [String] = []
        var finishedShown = true
        /// 13i-e U2: the Archived row's door and caption, and the Collecting
        /// pane's pause sentence (nil when not drawn).
        var archiveDoor: CapabilityID? = nil
        var archiveCaption: String? = nil
        var paused: String? = nil
    }

    static var drawn: [String: Drawn] = [:]
}
#endif
