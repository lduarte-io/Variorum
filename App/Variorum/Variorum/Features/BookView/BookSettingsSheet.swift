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

/// One Collecting sentence: a muted label and her words (tag paths are her
/// vocabulary — the face never `chromeLabel`s the value).
nonisolated struct CollectingLine: Equatable, Sendable {
    let label: String
    let value: String
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

    static func title(isBook: Bool) -> String { isBook ? "Book Settings" : "Gathering Settings" }

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
                ? CollectingLine(label: gathersFromLabel, value: nothingByItself)
                : CollectingLine(label: "", value: RuleEditorCopy.noRuleGathering)
        case .malformed:
            return CollectingLine(label: gathersFromLabel, value: unreadableRule)
        }
    }

    /// "New matches: join quietly at the end / wait at Arrivals" (nil
    /// stored reads AUTO — P-13ib-5).
    static func newMatches(_ seating: IntakeSeating?) -> CollectingLine {
        CollectingLine(
            label: RuleEditorCopy.joinLabel,
            value: seating == .arrivals ? RuleEditorCopy.joinArrivals : RuleEditorCopy.joinAuto)
    }

    /// "Notes written here are tagged: #a #b / nothing".
    static func taggedHere(_ ids: [String], paths: [String: String]) -> CollectingLine {
        CollectingLine(
            label: RuleEditorCopy.autoTagLabel,
            value: ids.isEmpty
                ? taggedNothing
                : ids.map { RuleEditorCopy.tag(path: paths[$0]) }.joined(separator: " "))
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
    /// The rule editor, while open (the sheet's item IS its model).
    var ruleEditor: RuleEditorModel?
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
        guard let (paths, hides) = try? await session.database.read({ db in
            (try Queries.tagPaths(db, ids: ids), try Queries.hideOwnedDefault(db))
        }) else { return }
        self.paths = paths
        hideOwnedDefault = hides
    }

    /// The "Edit…" door — the rule editor for THIS reading.
    func openRuleEditor() {
        ruleEditor = RuleEditorModel(session: session, readingID: readingID)
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

    let structure: BookStructureModel
    @State private var model: BookSettingsModel
    @State private var nameField = ""
    @State private var wordTargetField = ""
    @State private var maxPostsField = ""
    @State private var parseError: String?
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    /// `model` is injectable so a pin can hand in one it already LOADED
    /// (hosted `.task` callbacks don't fire under the test host — the
    /// `RuleEditorModel` precedent); the app passes nothing.
    init(structure: BookStructureModel, model: BookSettingsModel? = nil) {
        self.structure = structure
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
            Form {
                TextField("Name", text: $nameField)
                TextField("Word target (blank = none)", text: $wordTargetField)
                TextField("Note cap (blank = none)", text: $maxPostsField)
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
        .onAppear {
            nameField = structure.reading?.name ?? ""
            wordTargetField = structure.reading?.wordTarget.map(String.init) ?? ""
            maxPostsField = structure.reading?.maxPosts.map(String.init) ?? ""
        }
        // The sentences' one-shot read, re-keyed on everything they say.
        .task(id: factsKey) {
            if let reading = structure.reading { await model.load(for: reading) }
        }
        .sheet(item: $model.ruleEditor) { editor in
            RuleEditorSheet(model: editor)
        }
        .bookStateConfirms(model.stateDoors)
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
            // Her vocabulary (tag paths) — never `chromeLabel`'d.
            Text(line.value)
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func collecting(_ reading: Reading) -> some View {
        sectionLabel(CollectingCopy.section)
        ForEach(Array(CollectingCopy.sentences(for: reading, paths: model.paths).enumerated()),
                id: \.offset) { _, line in
            sentence(line)
        }
        if reading.kind == .gathering {
            HStack(spacing: 6) {
                Text(tokens.chromeLabel(CollectingCopy.hideOwnedLabel))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                    .fixedSize()
                ForEach(HideOwnedChoice.allCases, id: \.self) { choice in
                    VoicedChip(
                        tokens: tokens,
                        text: CollectingCopy.hideOwnedWord(
                            choice, defaultHides: model.hideOwnedDefault),
                        on: HideOwnedChoice(stored: reading.hideOwned) == choice,
                        action: { Task { await model.setHideOwned(choice) } }, lines: 1)
                }
            }
        }
        Button(tokens.chromeLabel(CollectingCopy.editDoor)) { model.openRuleEditor() }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
            .help(CapabilityRegistry.capability(.editRule).verb)
    }

    @ViewBuilder
    private func state(_ reading: Reading) -> some View {
        let acts = BookStateDoorSet.rendered(for: BookStateFacts(reading))
        sectionLabel(CollectingCopy.stateSection)
        // FINISHED — one control for the finish pair. While SEALED it stays
        // on and DISABLED with the sealed words: Reopen refuses a sealed
        // book (`readingSealed`), so no Reopen door renders (P-2).
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
    }

    private func stateRow(caption: String, act: CapabilityID, readingID: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(tokens.chromeLabel(caption))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            Button(tokens.chromeLabel(CapabilityRegistry.capability(act).verb)) {
                Task { await model.stateDoors.open(act, readingID: readingID) }
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .secondary))
        }
    }

    // MARK: Saving the three fields (as shipped)

    /// Round 2, MINOR: unparseable input REFUSES and keeps (ExtentInput —
    /// the one parse rule shared with the shelf's sheet).
    private func save() -> Bool {
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
            finishedDisabled: reading.sealedAt != nil)
    }
    #endif
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
    }

    static var drawn: [String: Drawn] = [:]
}
#endif
