//
//  RuleEditor.swift
//  Variorum
//
//  13i-b U3 — THE RULE EDITOR (the 13i-b plan §4 item 1; the sitting record
//  §3, §4, §17(d) + §19). It replaces the v1 draft vehicle (`SmartSpecSheet`
//  and `Queries.legacyDraft`, both retired here), which collected a rule in a
//  smaller vocabulary than the store holds and so could silently drop a term
//  it could not spell on save.
//
//  The face edits the v2 rule ITSELF (`Domain/RuleEditing` — its state is a
//  `RuleTerm?`), for the shapes the grammar offers: tag terms (picked from the
//  wing's live tags, stored by ID, shown by their live path, "(deleted tag)"
//  for a dead one) and the star term, combined with all-of / any-of / not and
//  grouping. GRANDFATHERED legacy terms draw read-only and are never offered
//  (#166(d)); a MALFORMED stored rule refuses editing entirely.
//
//  It serves GATHERINGS and BOOKS — a book's rule IS its intake. For a book
//  it also carries the two Collecting settings, minimally faced: the join
//  dial (`intake_seating` — "new matches: join quietly at the end · wait at
//  Arrivals") and the auto-tag row. Writes go through the one rule choke
//  point (`setReadingQuerySpec`) and the two setters; a rule edit on a living
//  book routes its gap through Arrivals (U1's catch-up — nothing to do here);
//  a save that sets the rule or the auto-tag with an auto-tag in place OFFERS
//  "also tag the N current members now" (`tagAllMembers`) on the one status
//  seam (the sitting record §4, ruled).
//
//  13i-d re-homes this face into the Collecting pane's sentences; it is built
//  as three movable pieces (P-9): the WORDS (`RuleEditorCopy`), the MODEL
//  (`RuleEditorModel`) and the FACE (`RuleEditorSheet`).
//

import SwiftUI
import VariorumCore

// MARK: - The words

nonisolated enum RuleEditorCopy {
    /// The registry's verb — the door on a shelf row's menu.
    static let editVerb = "Edit Rule…"
    /// The registry's honest note for a dispatch nothing renders.
    static let unavailableNote =
        "A rule belongs to a book or a gathering \u{2014} right-click one on the shelf to edit it."

    static func title(_ name: String) -> String { "Rule \u{2014} \u{201C}\(name)\u{201D}" }

    static let gatheringLead = "Shows every note that matches:"
    static let bookLead = "Collects every note that matches:"

    static let noRuleGathering =
        "No rule yet \u{2014} with none, this gathering shows every note."
    static let noRuleBook =
        "No rule yet \u{2014} this book collects nothing by itself."

    static let allOf = "all of these"
    static let anyOf = "any of these"
    static let not = "not"
    static let remove = "remove"
    static let addTag = "+ tag"
    static let addStarred = "+ starred"
    static let addGroup = "+ group"
    static let groupAll = "all of…"
    static let groupAny = "any of…"
    static let starred = "\u{2605} starred"
    static let deadTag = "(deleted tag)"
    static let noTagsYet = "no tags yet"

    static func tag(path: String?) -> String { path.map { "#\($0)" } ?? deadTag }

    /// A grandfathered term, read-only, in plain words.
    static func legacy(_ term: RuleTerm) -> String {
        switch term {
        case .legacyProfile(let profile): "profile is \u{201C}\(profile)\u{201D}"
        case .legacyEntryDateFrom(let day): "entry date from \(day)"
        case .legacyEntryDateTo(let day): "entry date to \(day)"
        default: ""
        }
    }

    static let legacyNotice =
        "This rule carries an old date/profile term \u{2014} it keeps working exactly as it "
        + "is, but it can\u{2019}t be edited here."
    static let malformedNotice =
        "This rule is stored in a form this version can\u{2019}t read, so it can\u{2019}t be "
        + "edited here \u{2014} nothing about it will be changed."

    // The book's two Collecting settings.
    static let joinLabel = "New matches:"
    static let joinAuto = "join quietly at the end"
    static let joinArrivals = "wait at Arrivals"
    static let autoTagLabel = "Notes written here are tagged:"
    static let autoTagNone = "no tag"

    // The seam.
    static func saved(_ name: String) -> String { "Saved the rule for \u{201C}\(name)\u{201D}." }
    static func tagMembersOffer(count: Int, path: String) -> String {
        let members = count == 1 ? "the 1 current member" : "the \(count) current members"
        return "Also tag \(members) with #\(path) now?"
    }
    static let tagMembersAction = "Tag Them"
    static func taggedMembers(count: Int, path: String) -> String {
        "Tagged \(count) member\(count == 1 ? "" : "s") with #\(path)."
    }
}

// MARK: - The model

/// One reading's rule, open for editing. Holds projections and ids (the
/// draft rule, the wing's tag choices) and calls the operations — what an
/// edit does to the tree is `RuleEditing`'s, and every write is an op's.
///
/// `Identifiable` because the SHEET'S ITEM IS THE MODEL: a host presents
/// `.sheet(item: $editor)`, so the draft lives exactly as long as the sheet
/// and no re-render of the host can rebuild it under her (a model minted
/// inside a sheet's content closure would be — the stale-closure class
/// F-U2-3 met one door over).
@MainActor
@Observable
final class RuleEditorModel: Identifiable {
    nonisolated var id: String { readingID }
    @ObservationIgnored let session: AppSession
    let readingID: String

    private(set) var reading: Reading?
    /// The rule as STORED — three states, kept apart (`RuleGrammar.read`).
    private(set) var stored: RuleGrammar.ReadResult = .none
    private(set) var storedSpec: String?
    /// The rule being edited.
    private(set) var draft: RuleTerm?
    /// The book's join dial, as edited (nil stored reads AUTO — P-13ib-5).
    var seating: IntakeSeating = .auto
    /// The book's auto-tag, as edited.
    var autoTagID: String?
    /// The wing's live tags — the add menus' choices and the auto-tag row's.
    private(set) var tags: [Tag] = []
    /// Live paths of the tags the STORED rule references (a tag of another
    /// wing still reads its path; a dead one has no entry).
    private(set) var referencedPaths: [String: String] = [:]
    private(set) var saving = false
    /// Adopted once: the sheet's `.task` loads on appear, and a load that
    /// landed after her first edit must never reset the draft under her.
    @ObservationIgnored private var adopted = false

    init(session: AppSession, readingID: String) {
        self.session = session
        self.readingID = readingID
    }

    var isBook: Bool { reading?.kind == .book }
    /// A malformed stored rule is never edited here (`RuleEditing.needsWrite`).
    var ruleIsEditable: Bool { stored != .malformed }
    var rows: [RuleEditing.Row] { RuleEditing.rows(of: draft) }
    var carriesLegacy: Bool { RuleEditing.carriesLegacy(draft) }

    private var storedSeating: IntakeSeating { reading?.intakeSeating ?? .auto }
    var ruleChanged: Bool { RuleEditing.needsWrite(draft: draft, stored: storedSpec) }
    var seatingChanged: Bool { isBook && seating != storedSeating }
    var autoTagChanged: Bool { isBook && autoTagID != reading?.autoTagId }
    var isDirty: Bool { ruleChanged || seatingChanged || autoTagChanged }

    /// What the add menus offer — the wing's live tags, then the star. Never
    /// a legacy term (#166(d)): nothing here can mint one.
    var offeredTerms: [(label: String, term: RuleTerm)] {
        tags.map { (RuleEditorCopy.tag(path: $0.path), RuleTerm.tag($0.id)) }
            + [(RuleEditorCopy.starred, RuleTerm.star)]
    }

    /// A tag term's words: its live path, or "(deleted tag)".
    func label(forTag id: String) -> String {
        let path = tags.first { $0.id == id }?.path ?? referencedPaths[id]
        return RuleEditorCopy.tag(path: id.isEmpty ? nil : path)
    }

    func autoTagPath(_ id: String?) -> String? {
        guard let id else { return nil }
        return tags.first { $0.id == id }?.path ?? referencedPaths[id]
    }

    // MARK: Loading

    func load() async {
        guard !adopted else { return }
        let id = readingID
        let fetched = try? await session.database.read { db -> (Reading?, [Tag], [String: String]) in
            guard let reading = try Queries.reading(db, id: id) else { return (nil, [], [:]) }
            let tags = try Queries.allTags(db).filter { $0.wingId == reading.wingId }
            var ids = Array(RuleGrammar.tagIDs(of: RuleGrammar.decode(reading.querySpec)))
            if let auto = reading.autoTagId { ids.append(auto) }
            return (reading, tags, try Queries.tagPaths(db, ids: ids))
        }
        guard let (reading, tags, paths) = fetched, let reading else { return }
        adopt(reading: reading, tags: tags, referencedPaths: paths)
    }

    /// Internal so pins drive the model deterministically (hosted `.task`
    /// callbacks don't fire under the test host — the `BookArrivalsModel`
    /// precedent).
    func adopt(reading: Reading, tags: [Tag], referencedPaths: [String: String]) {
        adopted = true
        self.reading = reading
        self.tags = tags
        self.referencedPaths = referencedPaths
        storedSpec = reading.querySpec
        stored = RuleGrammar.read(reading.querySpec)
        if case .rule(let term) = stored { draft = term } else { draft = nil }
        seating = reading.intakeSeating ?? .auto
        autoTagID = reading.autoTagId
    }

    // MARK: The edits (each one `RuleEditing`'s)

    func add(_ term: RuleTerm, into target: RuleEditing.Path?) {
        guard ruleIsEditable else { return }
        draft = RuleEditing.add(term, into: target, of: draft)
    }

    func addGroup(
        _ combinator: RuleEditing.Combinator, seededWith first: RuleTerm,
        into target: RuleEditing.Path?
    ) {
        guard ruleIsEditable else { return }
        draft = RuleEditing.addGroup(combinator, seededWith: first, into: target, of: draft)
    }

    func remove(_ row: RuleEditing.Row) {
        guard ruleIsEditable, row.isRemovable else { return }
        draft = RuleEditing.remove(at: row.path, of: draft)
    }

    func toggleNot(_ row: RuleEditing.Row) {
        guard ruleIsEditable, row.isEditable else { return }
        draft = RuleEditing.toggleNegation(at: row.path, of: draft)
    }

    func setCombinator(_ combinator: RuleEditing.Combinator, of row: RuleEditing.Row) {
        guard ruleIsEditable else { return }
        draft = RuleEditing.setCombinator(combinator, at: row.nodePath, of: draft)
    }

    // MARK: Saving

    /// Writes exactly what changed — the dial first (so a rule edit's
    /// catch-up or backfill already hears the dial she chose), the auto-tag,
    /// then the rule through its one choke point. An unedited save writes
    /// NOTHING. A save that set or changed the rule or the auto-tag, with an
    /// auto-tag in place and members not yet wearing it, OFFERS to tag them.
    /// Returns true when the sheet may close.
    @discardableResult
    func save() async -> Bool {
        guard let reading, !saving else { return false }
        guard isDirty else { return true }
        saving = true
        defer { saving = false }
        let id = readingID
        let writeSeating = seatingChanged ? seating : nil
        let writeAutoTag = autoTagChanged
        let autoTag = autoTagID
        let writeRule = ruleChanged
        let spec: String?
        do {
            spec = try RuleGrammar.encode(draft)
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
            return false
        }
        do {
            try await session.runner.run { ops in
                if let writeSeating { try ops.setReadingIntakeSeating(id, writeSeating) }
                if writeAutoTag { try ops.setReadingAutoTag(id, tagID: autoTag) }
                if writeRule { try ops.setReadingQuerySpec(id, querySpec: spec) }
            }
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
            return false
        }
        session.status.receipt(RuleEditorCopy.saved(reading.name))
        if reading.kind == .book, let autoTag, writeRule || writeAutoTag,
           let path = autoTagPath(autoTag) {
            await offerToTagMembers(tagID: autoTag, path: path)
        }
        return true
    }

    /// "Also tag the N current members now" — asked only when there are
    /// members the tag would reach (N is `tagAllMembers`' own predicate).
    private func offerToTagMembers(tagID: String, path: String) async {
        let id = readingID
        let count = (try? await session.database.read { db in
            try Queries.membersMissingTag(db, readingID: id, tagID: tagID)
        }) ?? 0
        guard count > 0 else { return }
        let session = session
        session.status.offer(
            RuleEditorCopy.tagMembersOffer(count: count, path: path),
            action: .init(label: RuleEditorCopy.tagMembersAction) {
                Task { @MainActor in
                    do {
                        let tagged = try await session.runner.run { ops in
                            try ops.tagAllMembers(id, tagID: tagID)
                        }
                        session.status.receipt(
                            RuleEditorCopy.taggedMembers(count: tagged, path: path))
                    } catch {
                        session.status.refuse(OpsRefusalCopy.message(for: error))
                    }
                }
            })
    }
}

// MARK: - The face

struct RuleEditorSheet: View {
    let model: RuleEditorModel

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(RuleEditorCopy.title(model.reading?.name ?? ""))
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            Text(tokens.chromeLabel(
                model.isBook ? RuleEditorCopy.bookLead : RuleEditorCopy.gatheringLead))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
            if model.ruleIsEditable {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        if model.rows.isEmpty {
                            ChromeNotice(
                                tokens: tokens,
                                text: model.isBook
                                    ? RuleEditorCopy.noRuleBook : RuleEditorCopy.noRuleGathering,
                                lines: 2)
                            adder(target: nil, depth: 0)
                        }
                        ForEach(model.rows, id: \.identity) { row in
                            rowView(row)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }
                .frame(minHeight: 140, maxHeight: 340)
                if model.carriesLegacy {
                    ChromeNotice(tokens: tokens, text: RuleEditorCopy.legacyNotice, lines: 3)
                }
            } else {
                ChromeNotice(tokens: tokens, text: RuleEditorCopy.malformedNotice, lines: 3)
            }
            if model.isBook {
                Rectangle().fill(tokens.line).frame(height: 1)
                collectingRows
            }
            HStack {
                Spacer()
                Button(tokens.chromeLabel("Cancel")) { dismiss() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                Button(tokens.chromeLabel("Save")) {
                    Task { if await model.save() { dismiss() } }
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                .keyboardShortcut(.defaultAction)
                .disabled(!model.isDirty || model.saving)
            }
        }
        .padding(16)
        .frame(minWidth: 480, alignment: .leading)
        .background(tokens.surface)
        .task { await model.load() }
        #if DEBUG
        .onAppear { recordSettings() }
        .onDisappear { RuleEditorProbe.forget(model.readingID) }
        .onChange(of: model.isDirty) { _, _ in recordSettings() }
        #endif
    }

    // MARK: Rows

    @ViewBuilder
    private func rowView(_ row: RuleEditing.Row) -> some View {
        switch row.kind {
        case .adder(let target):
            adder(target: target, depth: row.depth)
        default:
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(String(repeating: "not ", count: row.negations))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
                    .fixedSize()
                termView(row)
                Spacer(minLength: 8)
                if row.isEditable {
                    VoicedChip(
                        tokens: tokens, text: RuleEditorCopy.not, on: row.negations > 0,
                        action: { model.toggleNot(row) }, lines: 1)
                }
                if row.isRemovable {
                    Button(tokens.chromeLabel(RuleEditorCopy.remove)) { model.remove(row) }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                }
            }
            .padding(.leading, CGFloat(row.depth) * 18)
            #if DEBUG
            .onAppear { RuleEditorProbe.recordRow(model.readingID, row.identity, drawn(row)) }
            .onDisappear { RuleEditorProbe.forgetRow(model.readingID, row.identity) }
            #endif
        }
    }

    @ViewBuilder
    private func termView(_ row: RuleEditing.Row) -> some View {
        switch row.kind {
        case .group(let combinator, _):
            VoicedMenu(
                tokens: tokens,
                label: combinator == .all ? RuleEditorCopy.allOf : RuleEditorCopy.anyOf
            ) {
                Button(RuleEditorCopy.allOf) { model.setCombinator(.all, of: row) }
                Button(RuleEditorCopy.anyOf) { model.setCombinator(.any, of: row) }
            }
        case .tag(let id):
            // A tag's path is her vocabulary — never `chromeLabel`'d.
            Text(model.label(forTag: id))
                .font(tokens.small)
                .foregroundStyle(id.isEmpty || model.label(forTag: id) == RuleEditorCopy.deadTag
                                 ? tokens.faint : tokens.ink)
                .lineLimit(1)
                .truncationMode(.middle)
        case .star:
            Text(tokens.chromeLabel(RuleEditorCopy.starred))
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
        case .legacy(let term):
            Text(RuleEditorCopy.legacy(term))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(1)
        case .adder:
            EmptyView()
        }
    }

    /// A group's add doors: a tag, the star, or a new group born seeded.
    private func adder(target: RuleEditing.Path?, depth: Int) -> some View {
        HStack(spacing: 4) {
            VoicedMenu(tokens: tokens, label: RuleEditorCopy.addTag, role: .quiet) {
                if model.tags.isEmpty {
                    Text(RuleEditorCopy.noTagsYet)
                }
                ForEach(model.tags, id: \.id) { tag in
                    Button(RuleEditorCopy.tag(path: tag.path)) { model.add(.tag(tag.id), into: target) }
                }
            }
            Button(tokens.chromeLabel(RuleEditorCopy.addStarred)) { model.add(.star, into: target) }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            VoicedMenu(tokens: tokens, label: RuleEditorCopy.addGroup, role: .quiet) {
                Menu(RuleEditorCopy.groupAll) { seeds(.all, target: target) }
                Menu(RuleEditorCopy.groupAny) { seeds(.any, target: target) }
            }
            Spacer(minLength: 0)
        }
        .padding(.leading, CGFloat(depth) * 18)
        #if DEBUG
        .onAppear {
            RuleEditorProbe.recordAdder(
                model.readingID, target: target,
                offered: model.offeredTerms.map(\.label))
        }
        .onDisappear { RuleEditorProbe.forgetAdder(model.readingID, target: target) }
        #endif
    }

    @ViewBuilder
    private func seeds(_ combinator: RuleEditing.Combinator, target: RuleEditing.Path?) -> some View {
        ForEach(Array(model.offeredTerms.enumerated()), id: \.offset) { _, offered in
            Button(offered.label) {
                model.addGroup(combinator, seededWith: offered.term, into: target)
            }
        }
    }

    // MARK: The book's Collecting rows

    private var collectingRows: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text(tokens.chromeLabel(RuleEditorCopy.joinLabel))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                VoicedChip(
                    tokens: tokens, text: RuleEditorCopy.joinAuto, on: model.seating == .auto,
                    action: { model.seating = .auto }, lines: 1)
                VoicedChip(
                    tokens: tokens, text: RuleEditorCopy.joinArrivals,
                    on: model.seating == .arrivals,
                    action: { model.seating = .arrivals }, lines: 1)
            }
            HStack(spacing: 6) {
                Text(tokens.chromeLabel(RuleEditorCopy.autoTagLabel))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                VoicedMenu(
                    tokens: tokens,
                    label: model.autoTagPath(model.autoTagID).map { "#\($0)" }
                        ?? (model.autoTagID == nil ? RuleEditorCopy.autoTagNone : RuleEditorCopy.deadTag)
                ) {
                    Button(RuleEditorCopy.autoTagNone) { model.autoTagID = nil }
                    ForEach(model.tags, id: \.id) { tag in
                        Button(RuleEditorCopy.tag(path: tag.path)) { model.autoTagID = tag.id }
                    }
                }
            }
        }
    }

    #if DEBUG
    private func drawn(_ row: RuleEditing.Row) -> RuleEditorProbe.DrawnRow {
        let words: String = switch row.kind {
        case .group(let combinator, _):
            combinator == .all ? RuleEditorCopy.allOf : RuleEditorCopy.anyOf
        case .tag(let id): model.label(forTag: id)
        case .star: RuleEditorCopy.starred
        case .legacy(let term): RuleEditorCopy.legacy(term)
        case .adder: ""
        }
        var doors: [String] = []
        if row.isEditable { doors.append(RuleEditorCopy.not) }
        if row.isRemovable { doors.append(RuleEditorCopy.remove) }
        return .init(
            depth: row.depth, negations: row.negations, words: words, doors: doors)
    }

    private func recordSettings() {
        RuleEditorProbe.recordSettings(
            model.readingID,
            collecting: model.isBook,
            saveEnabled: model.isDirty && !model.saving,
            notice: model.ruleIsEditable
                ? (model.carriesLegacy ? RuleEditorCopy.legacyNotice : nil)
                : RuleEditorCopy.malformedNotice)
    }
    #endif
}

extension RuleEditing.Row {
    /// A row's identity for the face: its address AND what it is, so an edit
    /// that changes a row draws a NEW row (and its `onAppear` speaks again).
    var identity: String { "\(path)|\(nodePath)|\(kind)|\(negations)" }
}

#if DEBUG
/// **WHAT THE MOUNTED EDITOR DREW, AS A TEST ORACLE** (the `ArrivalsLineProbe`
/// pattern, for its measured reason: a hosted SwiftUI tree exposes no
/// accessibility children in this test host). Recorded from each row's own
/// `onAppear`, keyed by the reading; cleared on disappear — so "absent" is an
/// honest answer. The add doors record the choices their menus list (menus
/// are not evaluated until opened; the list is the same array the menu draws).
/// DEBUG only.
@MainActor
enum RuleEditorProbe {
    struct DrawnRow: Equatable {
        var depth: Int
        var negations: Int
        var words: String
        var doors: [String]
    }

    struct Drawn: Equatable {
        var rows: [String: DrawnRow] = [:]
        var adders: [String: [String]] = [:]
        var collecting = false
        var saveEnabled = false
        var notice: String?
    }

    private(set) static var drawn: [String: Drawn] = [:]

    static func reset() { drawn = [:] }

    static func recordRow(_ readingID: String, _ identity: String, _ row: DrawnRow) {
        drawn[readingID, default: Drawn()].rows[identity] = row
    }

    static func forgetRow(_ readingID: String, _ identity: String) {
        drawn[readingID]?.rows[identity] = nil
    }

    static func recordAdder(_ readingID: String, target: RuleEditing.Path?, offered: [String]) {
        drawn[readingID, default: Drawn()].adders[key(target)] = offered
    }

    static func forgetAdder(_ readingID: String, target: RuleEditing.Path?) {
        drawn[readingID]?.adders[key(target)] = nil
    }

    static func recordSettings(
        _ readingID: String, collecting: Bool, saveEnabled: Bool, notice: String?
    ) {
        var entry = drawn[readingID, default: Drawn()]
        entry.collecting = collecting
        entry.saveEnabled = saveEnabled
        entry.notice = notice
        drawn[readingID] = entry
    }

    static func forget(_ readingID: String) { drawn[readingID] = nil }

    static func key(_ target: RuleEditing.Path?) -> String {
        target.map { "\($0)" } ?? "root"
    }
}
#endif
