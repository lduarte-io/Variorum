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
//  it also carries the two Collecting settings: the join dial
//  (`intake_seating` — "new matches: join quietly at the end · wait at
//  Arrivals") and — since 13i-c U3 — the OUTFLOW CHOOSER (`OutflowChooser`:
//  a chosen, ordered, optional SET of tags, independent of the rule —
//  R-13ic-1), which retired the single auto-tag row and its forwarder op.
//  Writes go through the one rule choke point (`setReadingQuerySpec`) and
//  the two setters (`setReadingIntakeSeating`, `setReadingOutflow`); a rule
//  edit on a living book routes its gap through Arrivals (U1's catch-up —
//  nothing to do here); a save that changed the rule or the outflow, with an
//  outflow in place and members missing any of it, OFFERS "also tag the N
//  current members now" (`tagAllMembers(nil)` — every outflow tag) on the
//  one status seam (the sitting record §4, ruled).
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
        "A rule belongs to a book or a gathering \u{2014} right-click one on the Bookcase to edit it."

    static func title(_ name: String) -> String { "Rule \u{2014} \u{201C}\(name)\u{201D}" }

    static let gatheringLead = "Shows every note that matches:"
    static let bookLead = "Collects every note that matches:"

    /// 13i-c U3 (R-13ic-4, F-U1-3): NO RULE = NOTHING on a gathering — the
    /// old "shows every note" letter died at U1 (a Trash restoree is the only
    /// live rule-less gathering there can be).
    static let noRuleGathering =
        "No rule \u{2014} this gathering shows nothing until it has one."
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

    /// 17y B3 (g) — the tag made in place (a quiet receipt; 13s re-voices).
    static func madeTag(_ path: String) -> String { "Made the tag #\(path)." }

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
    /// The outflow chooser's empty state (13i-c U3 — "none" is legal).
    static let outflowNone = "nothing"

    // 13i-c U3 — R-13ic-4's faces.
    /// The gathering gate: a gathering with no term cannot be saved.
    static let gatheringNeedsRule = "A gathering needs a rule."
    /// The MINT sheet (the Bookcase's Create Gathering door — 13i-d U6 (a):
    /// the gathering mint's words, "smart" retired app-wide, §14).
    static let mintTitle = "Create Gathering"
    static let mintEmpty =
        "Add a tag or \u{2605} starred \u{2014} a gathering is made from its rule, and shows "
        + "every note that matches it."
    static let mintCreate = "Create"

    // The seam.
    static func saved(_ name: String) -> String { "Saved the rule for \u{201C}\(name)\u{201D}." }
    /// The offer, over the outflow SET (13i-c — P-13ic-11): N = the members
    /// missing at least one of the tags; the tags are named in her order.
    static func tagMembersOffer(count: Int, paths: [String]) -> String {
        let members = count == 1 ? "the 1 current member" : "the \(count) current members"
        return "Also tag \(members) with \(hashtags(paths)) now?"
    }
    static let tagMembersAction = "Tag Them"
    /// The receipt counts NOTES that newly wear at least one (P-13ic-11).
    static func taggedMembers(count: Int, paths: [String]) -> String {
        "Tagged \(count) member\(count == 1 ? "" : "s") with \(hashtags(paths))."
    }

    static func hashtags(_ paths: [String]) -> String {
        paths.map { "#\($0)" }.joined(separator: " ")
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
    /// The book's OUTFLOW, as edited (13i-c U3 — the chooser's draft; the
    /// 13i-b single `autoTagID` and its forwarder retired with it, F-U1-1).
    var outflow = OutflowDraft([])
    /// The wing's live tags — the add menus' choices and the auto-tag row's.
    private(set) var tags: [Tag] = []
    /// Live paths of the tags the STORED rule references (a tag of another
    /// wing still reads its path; a dead one has no entry).
    private(set) var referencedPaths: [String: String] = [:]
    private(set) var saving = false
    /// Adopted once: the sheet's `.task` loads on appear, and a load that
    /// landed after her first edit must never reset the draft under her.
    @ObservationIgnored private var adopted = false
    /// 13i-c U3 (R-13ic-4) — the MINT mode: a gathering not yet made, its
    /// rule drafted inline before Create (the wing it will be minted in).
    /// nil for an editor over an existing reading.
    let mintWingID: String?
    /// 13i-d U1 — the Bookcase's CONTEXT MINT (§19.1/§24): the shelf a new
    /// gathering lands on when she mints it while a shelf is solo'd; nil =
    /// unshelved. Set by the door that opens the mint sheet.
    var mintShelfID: String?
    /// 13i-c U3 — the gathering gate's Trash door ("Delete this
    /// gathering…"): the state doors' brain, so its confirm and act are the
    /// ones every other book door uses.
    let stateDoors: BookStateDoors

    /// The mint mode's sheet id (it has no reading yet).
    nonisolated static let mintKey = "mint:new-gathering"
    /// The mint mode's NAME field — held HERE, not in the host's `@State`,
    /// because the sheet's item IS this model (the `BindOffer` lesson: a
    /// sheet reads only its item, so nothing it shows can be stale).
    var mintName = ""

    init(session: AppSession, readingID: String) {
        self.session = session
        self.readingID = readingID
        self.mintWingID = nil
        self.stateDoors = BookStateDoors(session: session)
    }

    /// The MINT editor (R-13ic-4: "the mint door requires a rule") — the
    /// draft starts empty; the add menus offer the wing's live tags.
    init(session: AppSession, mintingIn wingID: String) {
        self.session = session
        self.readingID = Self.mintKey
        self.mintWingID = wingID
        self.stateDoors = BookStateDoors(session: session)
    }

    var isMint: Bool { mintWingID != nil }
    var isBook: Bool { reading?.kind == .book }
    /// **R-13ic-4's gate**: a GATHERING whose draft has no term. Its Save
    /// disables ("A gathering needs a rule") and the Trash door is offered
    /// in its place — a rule-less gathering "doesn't make sense" (hers). A
    /// BOOK's clear stays legal (the kill switch); a malformed rule is never
    /// edited here at all.
    var gatheringNeedsRule: Bool {
        reading?.kind == .gathering && ruleIsEditable && draft == nil
    }
    /// Save is a door only when something changed AND the gate is open.
    var canSave: Bool { isDirty && !saving && !gatheringNeedsRule }
    /// The mint's rule, encoded — nil until the draft has a term (Create
    /// disables until then; the op's `gatheringRequiresRule` stands behind).
    var mintSpec: String? { (try? RuleGrammar.encode(draft)) ?? nil }
    /// A malformed stored rule is never edited here (`RuleEditing.needsWrite`).
    var ruleIsEditable: Bool { stored != .malformed }
    var rows: [RuleEditing.Row] { RuleEditing.rows(of: draft) }
    var carriesLegacy: Bool { RuleEditing.carriesLegacy(draft) }

    private var storedSeating: IntakeSeating { reading?.intakeSeating ?? .auto }
    private var storedOutflow: [String] { reading?.autoTagIDs ?? [] }
    var ruleChanged: Bool { RuleEditing.needsWrite(draft: draft, stored: storedSpec) }
    var seatingChanged: Bool { isBook && seating != storedSeating }
    var outflowChanged: Bool { isBook && outflow.ids != storedOutflow }
    var isDirty: Bool { ruleChanged || seatingChanged || outflowChanged }
    /// The wing's live tag ids — what an outflow write may name.
    private var liveTagIDs: Set<String> { Set(tags.map(\.id)) }
    /// A stored outflow tag that died since: it reads "(deleted tag)" and
    /// DROPS on the next save (`setReadingOutflow` refuses a dead id).
    var storedOutflowHasDead: Bool { storedOutflow.contains { !liveTagIDs.contains($0) } }

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

    /// An outflow tag's words: "#path" for a live tag of the wing, else
    /// "(deleted tag)" (the chooser drops it at the next save).
    func outflowLabel(_ id: String) -> String {
        RuleEditorCopy.tag(path: tags.first { $0.id == id }?.path)
    }

    // MARK: The searchable picker's choices (17y B3 (g))

    /// The "+ tag" picker's options — the wing's live tags, by path.
    var tagOptions: [SearchPickerOption] {
        tags.map { SearchPickerOption(id: $0.id, label: RuleEditorCopy.tag(path: $0.path),
                                      searchText: $0.path) }
    }

    /// The wing a tag made here is born in — the book's (or the gathering
    /// being minted's): a book never reaches into another library (§9).
    private var tagWing: String { mintWingID ?? reading?.wingId ?? "" }

    /// **MAKE A TAG IN PLACE** (17y item (g), her ask: the "+ tag" menus
    /// "must let her CREATE A NEW TAG in place"). The ordinary road — the
    /// typed-path grammar (`TypedTagPath`: "/" makes a hierarchy, the deepest
    /// existing prefix anchors, the missing remainder is minted through
    /// `createTag`, one runner turn) — in the book's wing. The tag is made AT
    /// ONCE (vocabulary, not the rule: Cancel keeps it, like a tag typed on
    /// a note — PROVISIONAL P-17y-B3-g2); the caller then adds the term (or
    /// the outflow entry) to the DRAFT, which only Save writes. Returns the
    /// leaf's id (an existing one when the whole path already lived), nil
    /// with the refusal spoken.
    func createTag(_ typed: String) async -> String? {
        // A leading "#" is how a tag READS, never part of its name.
        let segments = TypedTagPath.segments(SearchPickerBrain.normalized(typed))
        guard !segments.isEmpty else {
            session.status.refuse(TypedTagPath.emptyMessage)
            return nil
        }
        let wing = tagWing
        do {
            let live = try await session.database.read { db in
                try Queries.allTags(db, wingID: wing)
            }
            guard let plan = TypedTagPath.plan(segments: segments, live: live) else { return nil }
            let leaf = try await session.runner.run { ops in
                try TypedTagPath.createMissing(plan, ops: ops, wingID: wing)
            }
            tags = try await session.database.read { db in
                try Queries.allTags(db).filter { $0.wingId == wing }
            }
            if leaf != nil, !plan.missing.isEmpty {
                session.status.receipt(RuleEditorCopy.madeTag(plan.leafPath))
            }
            return leaf
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
            return nil
        }
    }

    // MARK: Loading

    func load() async {
        guard !adopted else { return }
        if let wing = mintWingID {
            let tags = (try? await session.database.read { db in
                try Queries.allTags(db).filter { $0.wingId == wing }
            }) ?? []
            adoptMint(tags: tags)
            return
        }
        let id = readingID
        let fetched = try? await session.database.read { db -> (Reading?, [Tag], [String: String]) in
            guard let reading = try Queries.reading(db, id: id) else { return (nil, [], [:]) }
            let tags = try Queries.allTags(db).filter { $0.wingId == reading.wingId }
            var ids = Array(RuleGrammar.tagIDs(of: RuleGrammar.decode(reading.querySpec)))
            ids += reading.autoTagIDs
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
        outflow = OutflowDraft(reading.autoTagIDs)
    }

    /// The mint mode's adoption (internal for pins, like `adopt`).
    func adoptMint(tags: [Tag]) {
        adopted = true
        self.tags = tags
    }

    // MARK: The mint (R-13ic-4 — a gathering is minted WITH its rule)

    /// Mints the gathering through `ReadingsViewModel.create(querySpec:)` —
    /// the shelf's own creation road (the duplicate-name guard inside its
    /// runner closure, the op's rule guard behind it). Returns the new id,
    /// or nil with the refusal left on `readings.lastError` (the sheet shows
    /// it and stays open — refuse and keep).
    func mint(through readings: ReadingsViewModel) async -> String? {
        guard let wing = mintWingID, let spec = mintSpec else { return nil }
        let trimmed = mintName.trimmingCharacters(in: .whitespacesAndNewlines)
        return await readings.create(
            name: trimmed.isEmpty ? "Untitled" : trimmed, kind: .gathering,
            querySpec: spec, wingId: wing, shelfId: mintShelfID)
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
    /// catch-up or backfill already hears the dial she chose), the outflow,
    /// then the rule through its one choke point. An unedited save writes
    /// NOTHING. A save that set or changed the rule or the outflow, with an
    /// outflow in place and members missing any of it, OFFERS to tag them.
    /// Returns true when the sheet may close.
    @discardableResult
    func save() async -> Bool {
        guard let reading, !saving else { return false }
        guard isDirty else { return true }
        saving = true
        defer { saving = false }
        let id = readingID
        let writeSeating = seatingChanged ? seating : nil
        // A dead stored id drops on ANY save of the sheet (its row read
        // "(deleted tag)"), not only one that touched the chooser.
        let writeOutflow = outflowChanged || (isBook && storedOutflowHasDead)
        let written = outflow.written(live: liveTagIDs)
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
                if writeOutflow { try ops.setReadingOutflow(id, tagIDs: written) }
                if writeRule { try ops.setReadingQuerySpec(id, querySpec: spec) }
            }
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
            return false
        }
        session.status.receipt(RuleEditorCopy.saved(reading.name))
        if reading.kind == .book, writeRule || writeOutflow, !written.isEmpty {
            await offerToTagMembers(paths: written.compactMap { id in
                tags.first { $0.id == id }?.path
            })
        }
        return true
    }

    /// "Also tag the N current members now" — asked only when there are
    /// members the outflow would reach (N is `tagAllMembers(nil)`'s own
    /// predicate, `membersMissingAnyOutflowTag` — read AFTER the write, so it
    /// is the stored set's number).
    private func offerToTagMembers(paths: [String]) async {
        let id = readingID
        let count = (try? await session.database.read { db in
            try Queries.membersMissingAnyOutflowTag(db, readingID: id)
        }) ?? 0
        guard count > 0 else { return }
        let session = session
        session.status.offer(
            RuleEditorCopy.tagMembersOffer(count: count, paths: paths),
            action: .init(label: RuleEditorCopy.tagMembersAction) {
                Task { @MainActor in
                    do {
                        let tagged = try await session.runner.run { ops in
                            try ops.tagAllMembers(id)
                        }
                        session.status.receipt(
                            RuleEditorCopy.taggedMembers(count: tagged, paths: paths))
                    } catch {
                        session.status.refuse(OpsRefusalCopy.message(for: error))
                    }
                }
            })
    }
}

// MARK: - The face

struct RuleEditorSheet: View {
    /// The REGISTRY acts this sheet renders as `.surface` doors (P-1's walk):
    /// the Trash door R-13ic-4's gathering gate offers ("Delete this
    /// gathering…").
    static let surfaceCapabilities: [CapabilityID] = [.deleteBook]

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
            RuleTreeEditor(
                model: model, tokens: tokens,
                emptyNotice: model.isBook
                    ? RuleEditorCopy.noRuleBook : RuleEditorCopy.noRuleGathering)
            if model.isBook {
                Rectangle().fill(tokens.line).frame(height: 1)
                collectingRows
            }
            // 13i-c U3 — R-13ic-4's GATE: a gathering with no term cannot be
            // saved (the op refuses `gatheringRequiresRule`); the honest door
            // in Save's place is the ordinary Trash road, confirmed.
            if model.gatheringNeedsRule {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    ChromeNotice(
                        tokens: tokens, text: RuleEditorCopy.gatheringNeedsRule,
                        ink: tokens.ink, lines: 2)
                    Spacer(minLength: 8)
                    Button(tokens.chromeLabel(BookStateCopy.deleteGatheringDoor)) {
                        Task { await model.stateDoors.open(.deleteBook, readingID: model.readingID) }
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .secondary))
                    .help(CapabilityRegistry.capability(.deleteBook).verb)
                }
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
                .disabled(!model.canSave)
            }
        }
        .padding(16)
        .frame(minWidth: 480, alignment: .leading)
        .background(tokens.surface)
        .task { await model.load() }
        // The gate's confirm; a landed delete closes the editor (its
        // gathering is in the Trash — there is nothing left to edit).
        .bookStateConfirms(model.stateDoors) { act in
            if act == .deleteBook { dismiss() }
        }
        #if DEBUG
        .onAppear { recordSettings() }
        .onDisappear { RuleEditorProbe.forget(model.readingID) }
        .onChange(of: model.isDirty) { _, _ in recordSettings() }
        .onChange(of: model.outflow) { _, _ in recordSettings() }
        .onChange(of: model.gatheringNeedsRule) { _, _ in recordSettings() }
        #endif
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
            // 13i-c U3 — THE OUTFLOW CHOOSER (R-13ic-1): a chosen, ordered,
            // optional set, independent of the rule above.
            OutflowChooser(
                tokens: tokens, draft: Bindable(model).outflow, tags: model.tags,
                label: model.outflowLabel,
                // 17y B3 (g): the "+ tag" picker makes a tag in place too.
                onCreate: { typed in await model.createTag(typed) })
        }
    }

    #if DEBUG
    private func recordSettings() {
        RuleEditorProbe.recordSettings(
            model.readingID,
            collecting: model.isBook,
            saveEnabled: model.canSave,
            notice: model.ruleIsEditable
                ? (model.carriesLegacy ? RuleEditorCopy.legacyNotice : nil)
                : RuleEditorCopy.malformedNotice,
            outflow: model.isBook ? model.outflow.ids.map(model.outflowLabel) : [],
            gate: model.gatheringNeedsRule ? RuleEditorCopy.gatheringNeedsRule : nil,
            gateDoor: model.gatheringNeedsRule ? BookStateCopy.deleteGatheringDoor : nil)
    }
    #endif
}

/// **THE RULE'S TREE, EDITABLE** (13i-c U3 — extracted from the editor sheet
/// so the MINT sheet drafts a rule with the SAME rows, doors and probe; one
/// face for one grammar). It draws the rows `RuleEditing` derives, the add
/// doors, and the legacy/malformed notices; `emptyNotice` is the host's
/// sentence for a draft with no term.
struct RuleTreeEditor: View {
    let model: RuleEditorModel
    let tokens: VoiceTokens
    let emptyNotice: String

    var body: some View {
        if model.ruleIsEditable {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    if model.rows.isEmpty {
                        ChromeNotice(tokens: tokens, text: emptyNotice, lines: 2)
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
            // 17y B3 item (g) — THE ONE PICKER (R-17y-3): type-to-filter over
            // the wing's tags, and a 'New tag "#x"' row that makes the tag in
            // place (the typed-path grammar) and adds its term.
            SearchPicker(
                tokens: tokens, label: RuleEditorCopy.addTag,
                prompt: SearchPickerCopy.tagPrompt, options: model.tagOptions,
                emptyText: RuleEditorCopy.noTagsYet,
                createLabel: SearchPickerCopy.newTag(_:), key: SearchPickerCopy.tagKey(_:),
                onPick: { id in model.add(.tag(id), into: target) },
                onCreate: { typed in
                    Task {
                        if let id = await model.createTag(typed) {
                            model.add(.tag(id), into: target)
                        }
                    }
                })
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
        /// 13i-c U3: the outflow chooser's rows, in order, as drawn.
        var outflow: [String] = []
        /// 13i-c U3: R-13ic-4's gate words and its Trash door, when shown.
        var gate: String?
        var gateDoor: String?
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
        _ readingID: String, collecting: Bool, saveEnabled: Bool, notice: String?,
        outflow: [String] = [], gate: String? = nil, gateDoor: String? = nil
    ) {
        var entry = drawn[readingID, default: Drawn()]
        entry.collecting = collecting
        entry.saveEnabled = saveEnabled
        entry.notice = notice
        entry.outflow = outflow
        entry.gate = gate
        entry.gateDoor = gateDoor
        drawn[readingID] = entry
    }

    static func forget(_ readingID: String) { drawn[readingID] = nil }

    static func key(_ target: RuleEditing.Path?) -> String {
        target.map { "\($0)" } ?? "root"
    }
}
#endif
