//
//  CommitsFaceModel.swift
//  Variorum (Mac)
//
//  **VX-801 (VX-827 U3a) — THE COMMITS FACE, its brain.** The block's History
//  & Lineage surface opens on this face (THE DESIGN MEMO, settled at the
//  exploration sitting, `notes/plans/fixes/vx-827-lineage.md`): one READING
//  PANE showing the selected moment's whole text, one RAIL — B's vertical dot
//  timeline, newest at the top, ALL TAKES INTERLEAVED (her ruling: *"i think
//  that showing all takes on one line is better - sometimes multiple takes
//  will have changed in a single pass round"*), the take dropdown filtering it
//  to one take — and the fast swapper: the pane follows the rail, a click or
//  ↑/↓ swaps the text instantly (her *"you should be able to preview or scroll
//  through the commit text without opening a named commit"*).
//
//  It replaces the Block History panel for every history door. Its acts are
//  the panel's acts exactly — Restore (`restoreCommit`, the pre-split confirm,
//  the flush first), Bring back as a take (`bringBackCommitAsTake`), Name /
//  Rename (`renameCommitPoint`, the seal's own refusal), the deleted take's
//  Put back (`restoreVariant`) — through the existing operations with their
//  existing words: no new op, no op changed, every refusal the op's own.
//
//  The decisions about the rail are `Domain/CommitRail` (pure, pinned
//  headlessly); the washes are `Domain/TextCompare` (view-time, stored
//  nowhere — OverallModel §8's legal diff). This model holds IDS and the
//  observed projection, never copies it into state of its own.
//
//  P3: nothing here is an editor. The pane is read-cheap text; the face
//  replaces the mode surface while it stands, so there is no second live
//  editor beside the one P3 allows (and none at all while the face shows).
//

import Foundation
import GRDB  // AsyncValueObservation iteration
import Observation
import VariorumCore

/// **THE FACE'S WORDS, ONE HOME** (PROVISIONAL — her wording pass; the acts
/// reuse the panel's shipped verbs, the words below are the face's own and
/// are drawn from her ruled composite and B's page).
nonisolated enum CommitsFaceCopy {
    static let back = "\u{2039} back"
    static let backHelp = "Back to the note, exactly where you were"
    static let crumb = "history"
    static let compareCrumb = "compare"
    static let backToHistory = "\u{2039} history"
    static let theTakeNow = "the take now"
    static let allTakes = "all takes"
    static let historyAll = "history \u{B7} all takes"
    static let historyThisTake = "history \u{B7} this take"
    static let chosenMark = "\u{2713} chosen"
    static let lockedMark = "locked"
    static let archivedMark = "archived"
    static let archivedGroup = "archived takes"
    static let plainWash = "plain"
    static let againstNowWash = "against now"
    static let compareVerb = "Compare"
    static let compareHelp =
        "This moment beside another, side by side, the changed words washed"
    /// The standing third box (her *"always being able to show 'now' as the
    /// third compare box option"*). PROVISIONAL words (P-U3a-5).
    static let addNow = "\u{FF0B} now"
    static let addNowHelp = "Show the take as it stands now beside these"
    static let removeBox = "\u{2715}"
    static let removeBoxHelp = "Put this box away"
    static let deletedTake = "deleted take"
    /// The Lineage face's door on this face's crumb row (her composite's
    /// "lineage ›"). PROVISIONAL words.
    static let lineageDoor = "lineage \u{203A}"
    static let lineageDoorHelp =
        "Where this block came from and what came of it \u{2014} the blocks it was divided, "
        + "merged, extracted or copied from, and into"
    /// What a relative's moments are compared against, and how the block you
    /// came from is named beside a relative's (B's list word: "this block").
    static let thisBlock = "this block"
    static let swapperHelp = "Click a moment, or step with \u{2191} and \u{2193} \u{2014} the pane follows"

    /// A relative's text brought back onto the block you came from
    /// (`bringBackFromLineage`) — the shipped same-block receipt's shape,
    /// naming WHERE it landed. PROVISIONAL words (#264).
    static func broughtBackFromLineage(label: String?) -> String {
        guard let label else {
            return "Brought back as a take on this block \u{2014} it's the last take in its fan."
        }
        return "Brought back as the take \u{201C}\(label)\u{201D} on this block \u{2014} it's "
            + "the last take in its fan."
    }

    static func takesCount(_ count: Int) -> String {
        "\(count) take\(count == 1 ? "" : "s") \u{25BE}"
    }

    static func commitsCount(_ count: Int) -> String {
        "\(count) commit\(count == 1 ? "" : "s")"
    }

    /// "4 changes since" — what changed between the moment and its take now.
    static func changesSince(_ count: Int) -> String {
        switch count {
        case 0: return "no changes since"
        case 1: return "1 change since"
        default: return "\(count) changes since"
        }
    }
}

@MainActor
@Observable
final class CommitsFaceModel {
    @ObservationIgnored let session: AppSession
    let postID: String
    let blockID: String
    /// The take the door was pressed in — the all-takes rail's one "now" line.
    let focusedVariantID: String?

    /// **Whose moments these are** (VX-827 U3b — THE DESIGN MEMO: "selecting
    /// an ancestor swaps the SAME pane+rail composition to that block"): the
    /// block the door was pressed on (`.home` — every act the Commits face
    /// has), or a RELATIVE of it in the Lineage face, whose moments are read
    /// and compared and brought back onto the block she came from
    /// (`bringBackFromLineage`) — never restored, renamed or put back in place
    /// (PROVISIONAL P-U3b-4: a lineage block is not edited from here).
    nonisolated enum Role: Equatable, Sendable {
        case home
        case relative(homeBlockID: String, homeFocusedVariantID: String?)
    }
    let role: Role

    var isRelative: Bool { if case .relative = role { return true }; return false }

    var homeBlockID: String {
        if case .relative(let home, _) = role { return home }
        return blockID
    }

    /// What the face reads, together: the block's whole time and the take
    /// this note shows for it (the "✓ chosen" mark); for a relative, the
    /// block you came from's live takes too (its "now", for Compare).
    nonisolated struct Read: Equatable, Sendable {
        var history = Queries.BlockHistory()
        var shownTakeID: String?
        var homeTakes: [Variant] = []
    }

    private(set) var read = Read()
    private(set) var loaded = false
    /// The note's seal, watched while the face stands (the panel's row-69
    /// rule: the rename door acts and speaks under a seal, never opens a
    /// field that cannot keep a name).
    private(set) var sealed = false
    /// A receipt is not a refusal (the tray family's split).
    private(set) var status: RecoveryStatus?

    /// The rail's filter — ALL TAKES by default (her ruling).
    private(set) var filter: CommitRail.Filter = .all
    /// What the reading pane shows.
    private(set) var selection: CommitRail.Moment?
    /// The quiet runs she opened (`CommitRail.Line.id` of the run).
    private(set) var expandedRuns: Set<String> = []

    /// The pane's two faces: the moment plain, or washed against its take now.
    enum Wash: Equatable, Sendable { case plain, againstNow }
    /// PROVISIONAL default (P-U3a-3): against now — her composite draws it
    /// so, and "claude just changed something" is the case it serves.
    var wash: Wash = .againstNow

    /// The pre-split confirm (AppSpec §9), the panel's own.
    var pendingRestore: PendingRestore?
    nonisolated struct PendingRestore: Identifiable, Equatable, Sendable {
        let variantID: String
        let commit: CommitPoint
        var id: String { commit.id }
    }

    /// The rename door's field (R-13u3-1), anchored on the pane's foot.
    var renameAsk: SavepointNameAsk?

    /// **Compare's boxes**, left to right, or nil while the face shows.
    private(set) var compareBoxes: [CommitRail.Moment]?

    /// **The washes, computed once per pair of texts.** A render reads the
    /// pane's comparison twice (the washes and the count) and Compare reads
    /// one per box, while the texts change only when a moment is picked or a
    /// take's buffer moves — so a pair already compared is answered from
    /// here (a commit is immutable; a "now" is keyed by its take's
    /// `updated_at` and length). Bounded: emptied past `compareCacheLimit`.
    @ObservationIgnored private var compareCache: [String: TextCompare.Comparison] = [:]
    static let compareCacheLimit = 64

    init(session: AppSession, request: BlockHistoryRequest) {
        self.session = session
        self.postID = request.postID
        self.blockID = request.blockID
        self.focusedVariantID = request.focusedVariantID
        self.role = .home
    }

    /// A RELATIVE's face (the Lineage face's selected member): `blockID` is
    /// the member, the request names the block she came from.
    init(session: AppSession, relative blockID: String, shownTakeID: String?, of home: BlockHistoryRequest) {
        self.session = session
        self.postID = home.postID
        self.blockID = blockID
        self.focusedVariantID = shownTakeID
        self.role = .relative(homeBlockID: home.blockID, homeFocusedVariantID: home.focusedVariantID)
    }

    // MARK: - The observation

    nonisolated static func read(
        _ db: Database, blockID: String, homeBlockID: String? = nil, now: Date
    ) throws -> Read {
        Read(
            history: try Queries.blockHistory(db, blockID: blockID, now: now),
            shownTakeID: try Queries.shownTake(db, blockID: blockID)?.id,
            homeTakes: try homeBlockID.map { try Queries.blockFan(db, blockID: $0) } ?? [])
    }

    /// Held only while the face is on screen. The take's pending typing is
    /// written FIRST, so "the take now" is now (the panel's restore rule,
    /// applied to reading as well as to writing).
    func start() async {
        await flushBeforeReading()
        do {
            let home: String? = isRelative ? homeBlockID : nil
            for try await value in session.database.observe({ [blockID, home, now = session.now] db in
                try Self.read(db, blockID: blockID, homeBlockID: home, now: now)
            }) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            status = .refusal(String(describing: error))
        }
    }

    /// **Every note this face reads, its pending typing written first**
    /// (VX-827 ladder R1-F1): the face's own note; for a RELATIVE, also the
    /// note it is placed in — a relative in ANOTHER note, open in a second
    /// window with typing the debounce has not written, would otherwise read
    /// as stale words on the pane. Read-only: nothing here copies, so the
    /// flush's clean answer is not consulted (the bring-back road does).
    func flushBeforeReading() async {
        await session.flushExistingAutosave(forPost: postID)
        guard isRelative,
              let placed = await LineageBringBack.placedNote(session: session, blockID: blockID),
              placed != postID else { return }
        await session.flushExistingAutosave(forPost: placed)
    }

    func watchSeal() async {
        do {
            for try await header in session.database.observeContainerHeader(postID) {
                sealed = header?.locked == true
            }
        } catch is CancellationError {
        } catch {
            sealed = false
        }
    }

    /// Internal so pins drive the face deterministically.
    func adoptSeal(_ sealed: Bool) { self.sealed = sealed }

    /// Internal so pins drive the face deterministically (the panel's
    /// `adopt` seam). The first snapshot seats the opening moment; a later
    /// one keeps her place unless what she was reading is gone.
    func adopt(_ value: Read) {
        read = value
        if case .take(let id) = filter, !takes.contains(where: { $0.id == id }) {
            filter = .all
        }
        if !loaded || !isShown(selection) {
            seatOpening()
        }
        if let compareBoxes {
            let kept = compareBoxes.filter(isKnown)
            self.compareBoxes = kept.count >= 2 ? kept : nil
        }
        loaded = true
    }

    // MARK: - Projections

    var takes: [Variant] { read.history.takes }
    var history: Queries.BlockHistory { read.history }

    var leadTakeID: String? { CommitRail.leadTake(takes, focused: focusedVariantID) }

    var lines: [CommitRail.Line] {
        CommitRail.lines(
            takes: takes, commits: history.savepoints, filter: filter,
            leadTakeID: leadTakeID, expandedRuns: expandedRuns)
    }

    func take(_ id: String?) -> Variant? {
        guard let id else { return nil }
        return takes.first { $0.id == id } ?? read.homeTakes.first { $0.id == id }
    }

    /// A take of the block you came from (a relative's face only).
    func isHomeTake(_ id: String?) -> Bool {
        guard isRelative, let id else { return false }
        return read.homeTakes.contains { $0.id == id }
    }

    /// The block you came from's lead take — a relative's Compare stands
    /// beside it (the take the door was pressed in, else the first live one).
    var homeLeadTakeID: String? {
        guard case .relative(_, let focused) = role else { return leadTakeID }
        return CommitRail.leadTake(read.homeTakes, focused: focused)
    }

    func commit(_ id: String) -> (commit: CommitPoint, takeID: String)? {
        for take in takes {
            if let hit = history.savepoints[take.id]?.first(where: { $0.id == id }) {
                return (hit, take.id)
            }
        }
        return nil
    }

    /// The take a moment belongs to.
    func takeID(of moment: CommitRail.Moment?) -> String? {
        switch moment {
        case .now(let takeID)?: return takeID
        case .commit(let id)?: return commit(id)?.takeID
        case nil: return nil
        }
    }

    /// A moment's whole text — the take's buffer for "now", the immutable
    /// snapshot for a commit.
    func text(of moment: CommitRail.Moment?) -> String? {
        switch moment {
        case .now(let takeID)?: return take(takeID)?.workingText
        case .commit(let id)?: return commit(id)?.commit.text
        case nil: return nil
        }
    }

    var selectedCommit: CommitPoint? {
        guard case .commit(let id)? = selection else { return nil }
        return commit(id)?.commit
    }

    var selectedTake: Variant? { take(takeID(of: selection)) }

    /// The selected take is the one this note shows (the pane's green bar).
    var selectionIsChosen: Bool {
        guard let id = takeID(of: selection) else { return false }
        return id == read.shownTakeID
    }

    /// **The pane's wash** — the selected moment against its take now, or
    /// nil (plain, a "now", nothing selected).
    var paneComparison: TextCompare.Comparison? {
        guard wash == .againstNow, let selection, case .commit = selection,
              let takeID = takeID(of: selection) else { return nil }
        return comparison(selection, .now(takeID: takeID))
    }

    /// "4 changes since" — always the count, whichever wash shows (the toggle
    /// changes what the text looks like, not what is true).
    var changesSince: String? {
        guard let selection, case .commit = selection,
              let takeID = takeID(of: selection),
              let compared = comparison(selection, .now(takeID: takeID)) else { return nil }
        return CommitsFaceCopy.changesSince(compared.changeCount)
    }

    /// Two moments compared (`TextCompare`), through the cache.
    func comparison(
        _ old: CommitRail.Moment, _ new: CommitRail.Moment
    ) -> TextCompare.Comparison? {
        guard let oldText = text(of: old), let newText = text(of: new),
              let oldKey = cacheKey(old), let newKey = cacheKey(new) else { return nil }
        let key = oldKey + "\u{1F}" + newKey
        if let hit = compareCache[key] { return hit }
        let fresh = TextCompare.compare(oldText, newText)
        if compareCache.count >= Self.compareCacheLimit { compareCache.removeAll() }
        compareCache[key] = fresh
        return fresh
    }

    /// What identifies a moment's TEXT: a commit's id (its text never
    /// changes, I5); a take's id with its `updated_at` and length.
    private func cacheKey(_ moment: CommitRail.Moment) -> String? {
        switch moment {
        case .commit(let id): return id
        case .now(let takeID):
            guard let take = take(takeID) else { return nil }
            return "now:\(takeID):\(take.updatedAt.timeIntervalSince1970):\(take.workingText.utf16.count)"
        }
    }

    func predatesSplit(_ commit: CommitPoint) -> Bool {
        CommitRules.predatesSplit(commitDate: commit.createdAt, splitDates: history.splitDates)
    }

    /// A take's name on the face: its label, else its place in the fan (the
    /// panel's own heading for a live take); an archived take its label or
    /// first line (`BlockPastCopy.rowLabel`). Never the raw id.
    func takeTitle(_ id: String) -> String {
        guard let take = take(id) else { return "" }
        if isHomeTake(id) {
            let active = read.homeTakes.filter { $0.status == .active }
            let ordinal = (active.firstIndex { $0.id == id } ?? 0) + 1
            return CommitsFaceCopy.thisBlock + " \u{B7} "
                + BlockHistoryPath.takeHeading(take, ordinal: ordinal, of: active.count)
        }
        if take.status == .archived { return BlockPastCopy.rowLabel(take) }
        let active = history.activeTakes
        let ordinal = (active.firstIndex { $0.id == id } ?? 0) + 1
        return BlockHistoryPath.takeHeading(take, ordinal: ordinal, of: active.count)
    }

    /// A moment's headline: the name she gave it, else its first words; a
    /// "now" is "the take now".
    func headline(_ moment: CommitRail.Moment?) -> String {
        switch moment {
        case .now?: return CommitsFaceCopy.theTakeNow
        case .commit(let id)?:
            guard let commit = commit(id)?.commit else { return "" }
            return SavepointRowFace.name(commit) ?? CommitRowFace.restingPreview(commit.text)
        case nil: return ""
        }
    }

    /// The pane header's quiet line: when · whose take (✓ where chosen) ·
    /// quiet · the pre-split warning — or, for a "now", the take's own facts.
    func meta(_ moment: CommitRail.Moment?) -> [String] {
        guard let moment, let takeID = takeID(of: moment) else { return [] }
        var takeWords = takeTitle(takeID)
        if takeID == read.shownTakeID { takeWords += " \u{2713}" }
        switch moment {
        case .now:
            var pieces = [takeWords]
            if take(takeID)?.status == .archived { pieces.append(CommitsFaceCopy.archivedMark) }
            if take(takeID)?.locked == true { pieces.append(CommitsFaceCopy.lockedMark) }
            return pieces
        case .commit(let id):
            guard let commit = commit(id)?.commit else { return [] }
            var pieces = [TimeStampFace.relative(commit.createdAt, now: session.now), takeWords]
            if commit.kind == .auto { pieces.append(CommitRowFace.quietMark) }
            if predatesSplit(commit) { pieces.append(BlockHistoryCopy.predatesSplitMark) }
            return pieces
        }
    }

    /// One row of the take dropdown (the Write takes-popup family: label,
    /// ✓ chosen, locked, its commit count, its first words).
    nonisolated struct TakeEntry: Identifiable, Equatable, Sendable {
        let id: String
        let title: String
        let chosen: Bool
        let locked: Bool
        let archived: Bool
        let commitCount: Int
        let firstWords: String
    }

    /// The dropdown's rows: the live takes in fan order, then the archived
    /// group (`archived` true).
    var takeEntries: [TakeEntry] {
        let active = history.activeTakes.map(entry)
        let archived = history.archivedTakes.map(entry)
        return active + archived
    }

    private func entry(_ take: Variant) -> TakeEntry {
        TakeEntry(
            id: take.id, title: takeTitle(take.id), chosen: take.id == read.shownTakeID,
            locked: take.locked, archived: take.status == .archived,
            commitCount: history.savepoints[take.id]?.count ?? 0,
            firstWords: CommitRowFace.restingPreview(take.workingText))
    }

    /// The pane's acts for what it shows: a moment's four (THE DESIGN MEMO —
    /// Restore · Bring back as take · Compare · Rename); an ARCHIVED take's
    /// "now" offers Unarchive (PROVISIONAL P-U3a-6 — exploration A's head; the
    /// panel's archived region's job); a live take's "now" has none.
    enum PaneAct: Hashable, Sendable { case restore, bringBack, compare, rename, unarchive }

    var paneActs: [PaneAct] {
        // A relative's moment is read, compared with the block you came from,
        // and brought back onto it — nothing on the relative is written.
        if isRelative { return selection == nil ? [] : [.bringBack, .compare] }
        switch selection {
        case .commit?: return [.restore, .bringBack, .compare, .rename]
        case .now(let takeID)?:
            return take(takeID)?.status == .archived ? [.unarchive] : []
        case nil: return []
        }
    }

    // MARK: - Selecting (the rail, the dropdown, the fast swapper)

    func select(_ moment: CommitRail.Moment) {
        selection = moment
        openRunHiding(moment)
    }

    /// **The fast swapper** — ↑ (−1, newer) and ↓ (+1, older): the pane
    /// follows at once (PROVISIONAL keys, P-U3a-4).
    func step(by offset: Int) {
        guard let next = CommitRail.step(selection, by: offset, in: lines) else { return }
        selection = next
    }

    func setFilter(_ filter: CommitRail.Filter) {
        self.filter = filter
        if !isShown(selection) { seatOpening() }
    }

    /// Opens or folds a quiet run. Folding the run that holds the moment she
    /// is reading moves the pane to the run's nearest visible neighbour —
    /// below it, else above — so the pane never shows a moment the rail
    /// hides (and the swapper never jumps to the top from one).
    func toggleRun(_ id: String) {
        expandedRuns = SavepointHistoryFace.toggling(id, in: expandedRuns)
        let now = lines
        let visible = CommitRail.selectable(now)
        guard let selection, !visible.contains(selection),
              let runIndex = now.firstIndex(where: { $0.id == id }) else { return }
        let below = now[(runIndex + 1)...].lazy.compactMap(\.moment).first
        let above = now[..<runIndex].reversed().lazy.compactMap(\.moment).first
        self.selection = below ?? above
    }

    func setWash(_ wash: Wash) { self.wash = wash }

    private func seatOpening() {
        selection = CommitRail.opening(
            takes: takes, commits: history.savepoints, filter: filter, leadTakeID: leadTakeID)
        openRunHiding(selection)
    }

    private func openRunHiding(_ moment: CommitRail.Moment?) {
        if let run = CommitRail.runHiding(
            moment, takes: takes, commits: history.savepoints, filter: filter,
            leadTakeID: leadTakeID, expandedRuns: expandedRuns) {
            expandedRuns.insert(run)
        }
    }

    /// The moment stands on the rail as it is filtered now (a folded run's
    /// member counts — its run opens to show it).
    private func isShown(_ moment: CommitRail.Moment?) -> Bool {
        guard let moment else { return false }
        let shown: [String]
        switch filter {
        case .all: shown = takes.map(\.id)
        case .take(let id): shown = [id]
        }
        guard let takeID = takeID(of: moment) else { return false }
        if case .now = moment {
            // The all-takes rail shows ONE "now" — the lead's.
            if case .all = filter { return takeID == leadTakeID }
        }
        return shown.contains(takeID)
    }

    private func isKnown(_ moment: CommitRail.Moment) -> Bool {
        takeID(of: moment) != nil
    }

    // MARK: - Compare (THE DESIGN MEMO: two boxes + the standing "now")

    /// **Opens Compare from the selected moment**: an AI bracket's half sets
    /// before beside after; any other moment sits beside its take now (B's
    /// drawing). Each box's header can then be re-aimed at any moment.
    func openCompare() {
        if isRelative {
            if let selection { openCompare(against: selection) }
            return
        }
        guard case .commit(let id)? = selection, let hit = commit(id) else { return }
        if CommitRail.bracket(hit.commit) != nil, let pair = bracketPair(of: hit.commit, takeID: hit.takeID) {
            compareBoxes = [.commit(commitID: pair.before.id), .commit(commitID: pair.after.id)]
        } else {
            compareBoxes = [.commit(commitID: id), .now(takeID: hit.takeID)]
        }
    }

    /// **A relative's "Compare with now"** (the Lineage face's header act and
    /// its pane's Compare): the moment beside the block you came from as it
    /// stands now.
    func openCompare(against moment: CommitRail.Moment) {
        guard let home = homeLeadTakeID else { return }
        compareBoxes = [moment, .now(takeID: home)]
    }

    func closeCompare() { compareBoxes = nil }

    /// The other half of the AI edit `commit` belongs to (the rail's own
    /// pairing), as (before, after); nil for a bracket standing alone.
    func bracketPair(of commit: CommitPoint, takeID: String) -> (before: CommitPoint, after: CommitPoint)? {
        let takeLines = CommitRail.lines(
            takes: takes, commits: history.savepoints, filter: .take(takeID),
            leadTakeID: takeID)
        guard let pairID = takeLines.first(where: { $0.id == commit.id })?.pairID else { return nil }
        let members = takeLines.filter { $0.pairID == pairID }.compactMap { line -> CommitPoint? in
            if case .commit(let member, _, _) = line.content { return member }
            return nil
        }
        guard members.count == 2 else { return nil }
        // The rail lists after above before (newest first).
        return (before: members[1], after: members[0])
    }

    func reaim(box index: Int, to moment: CommitRail.Moment) {
        guard var boxes = compareBoxes, boxes.indices.contains(index) else { return }
        boxes[index] = moment
        compareBoxes = boxes
    }

    /// "＋ now" is offered while fewer than three boxes stand and none of
    /// them is a "now" (PROVISIONAL P-U3a-5): the take of the last box, as it
    /// stands.
    var canAddNow: Bool {
        guard let boxes = compareBoxes, boxes.count < 3 else { return false }
        return !boxes.contains { if case .now = $0 { return true }; return false }
    }

    func addNowBox() {
        guard canAddNow, var boxes = compareBoxes, let takeID = takeID(of: boxes.last) else { return }
        boxes.append(.now(takeID: takeID))
        compareBoxes = boxes
    }

    /// Only a THIRD box can be put away — Compare is two boxes at least.
    func removeBox(_ index: Int) {
        guard var boxes = compareBoxes, boxes.count > 2, boxes.indices.contains(index) else { return }
        boxes.remove(at: index)
        compareBoxes = boxes
    }

    /// **A box's washed runs**: the FIRST box struck where the second has
    /// no longer got its words; every later box washed where it has words
    /// the box before it had not (her reference's two panes, read left to
    /// right — PROVISIONAL P-U3a-5 for the third box).
    func boxRuns(_ index: Int) -> [TextCompare.Run] {
        guard let boxes = compareBoxes, boxes.indices.contains(index),
              let text = text(of: boxes[index]) else { return [] }
        if boxes.count < 2 { return text.isEmpty ? [] : [.init(.same, text)] }
        if index == 0 {
            return comparison(boxes[0], boxes[1])?.old ?? [.init(.same, text)]
        }
        return comparison(boxes[index - 1], boxes[index])?.new ?? [.init(.same, text)]
    }

    /// Every moment a box's swapper can be re-aimed at, per take in the
    /// dropdown's order: the take now, then its moments newest first.
    var swapperGroups: [(takeID: String, moments: [CommitRail.Moment])] {
        takeEntries.map { entry in
            let commits = (history.savepoints[entry.id] ?? []).sorted {
                $0.createdAt != $1.createdAt ? $0.createdAt > $1.createdAt : $0.id > $1.id
            }
            return (entry.id, [.now(takeID: entry.id)] + commits.map { .commit(commitID: $0.id) })
        } + (isRelative
            ? read.homeTakes.filter { $0.status == .active }.map { ($0.id, [CommitRail.Moment.now(takeID: $0.id)]) }
            : [])
    }

    /// A moment's line in a swapper menu or a box header: "the take now", or
    /// the name / first words · when.
    func menuLine(_ moment: CommitRail.Moment) -> String {
        switch moment {
        case .now: return CommitsFaceCopy.theTakeNow
        case .commit(let id):
            guard let commit = commit(id)?.commit else { return "" }
            return headline(moment) + " \u{B7} "
                + TimeStampFace.relative(commit.createdAt, now: session.now)
        }
    }

    // MARK: - The acts (the panel's, exactly — no new op, no op changed)

    /// Restore the selected moment into its take's buffer — the flush first
    /// (a pending keystroke would overwrite it), the pre-split confirm where
    /// the moment predates a divide or extract (AppSpec §9).
    func restoreSelected(confirmed: Bool = false) async {
        guard case .commit(let id)? = selection, let hit = commit(id) else { return }
        await restore(hit.commit, of: hit.takeID, confirmed: confirmed)
    }

    func restore(_ commit: CommitPoint, of variantID: String, confirmed: Bool = false) async {
        if !confirmed, predatesSplit(commit) {
            pendingRestore = PendingRestore(variantID: variantID, commit: commit)
            return
        }
        pendingRestore = nil
        status = nil
        await session.flushExistingAutosave(forPost: postID)
        do {
            try await session.runner.run { ops in
                try ops.restoreCommit(variantID, commitID: commit.id)
            }
            status = .receipt(BlockHistoryCopy.restoredSavepoint)
            // VX-431's landing parcel, as the panel posts it: a SIGNAL each
            // writing surface decides about. While this face stands in the
            // full pane no surface is mounted beside it, so the parcel is
            // inert (consumed only on change by a mounted surface — never at
            // an arrival); under a sheet host the surface beneath takes it.
            session.commandRouter.pendingRestoreLanding = RestoreLanding(
                postID: postID, blockID: blockID, variantID: variantID, text: commit.text)
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    func confirmPendingRestore(_ pending: PendingRestore) async {
        await restore(pending.commit, of: pending.variantID, confirmed: true)
    }

    /// "Bring back as a take" — the moment becomes a take of its own on this
    /// block (`bringBackCommitAsTake`: the fan's end, never chosen, never born
    /// locked, named after the moment; a seal refuses). No flush: it copies
    /// the COMMIT's text, never a buffer.
    func bringBackSelected() async {
        if isRelative {
            switch selection {
            case .commit(let id)?: await bringBackFromLineage(.commit(id))
            case .now(let takeID)?: await bringBackFromLineage(.take(takeID))
            case nil: return
            }
            return
        }
        guard let commit = selectedCommit else { return }
        status = nil
        do {
            let take = try await session.runner.run { ops in
                try ops.bringBackCommitAsTake(commit.id)
            }
            status = .receipt(BlockHistoryPath.broughtBackAsTake(label: take.label))
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    /// **A relative's text onto the block you came from** (U3b-P RULED —
    /// `bringBackFromLineage`: the fan's end, never chosen, the source's name
    /// as its label; the fence and the seal refuse in the operation's words).
    func bringBackFromLineage(_ source: Operations.LineageTakeSource) async {
        status = nil
        do {
            status = .receipt(try await LineageBringBack.run(
                session: session, source: source, onto: homeBlockID))
        } catch let refusal as LineageBringBack.Refusal {
            status = .refusal(refusal.sentence)
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    /// Clears the face's line (the Lineage face's own acts speak in its place).
    func clearStatus() { status = nil }

    /// The rename door opens its field — or, under a seal, acts and speaks
    /// the standing refusal (the panel's row-69 rule).
    func askRenameSelected() {
        guard let commit = selectedCommit else { return }
        if sealed {
            status = .refusal(TrayRefusalCopy.message(for: OperationError.lockedPost(id: postID)))
        } else {
            renameAsk = .renaming(commit)
        }
    }

    func rename(commitID: String, to name: String?) async {
        status = nil
        do {
            let wrote = try await session.runner.run { ops in
                try ops.renameCommitPoint(commitID, message: name)
            }
            guard wrote else { return }
            status = .receipt(BlockHistoryCopy.renamed(SavepointName.normalized(name)))
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    /// A deleted take's Put back (`restoreVariant`; the receipt reads the
    /// op's own answer — an archived take comes back archived).
    func putBackTake(_ variantID: String) async {
        status = nil
        do {
            let restored = try await session.runner.run { ops in
                try ops.restoreVariant(variantID)
            }
            status = .receipt(BlockPastCopy.restored(restored))
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    /// Unarchive an archived take (PROVISIONAL placement, P-U3a-6; the op
    /// and the receipt are the panel's archived region's own).
    func unarchive(_ variantID: String) async {
        status = nil
        do {
            try await session.runner.run { ops in try ops.unarchiveVariant(variantID) }
            status = .receipt(BlockHistoryCopy.unarchivedTake)
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }
}

/// **The cross-block Bring back as take, as both doors run it** — the
/// Lineage face's member header and a relative's pane foot: ONE road, so the
/// two cannot drift on the operation or the words (the `PreservedOriginPutBack`
/// shape). Returns the receipt; refusals throw for the caller to word.
@MainActor
enum LineageBringBack {
    /// A bring-back that did not reach the operation (VX-827 ladder R1-F1).
    enum Refusal: Error, Equatable {
        /// The source take's note could not write its pending typing — copying
        /// the store now would copy words she has since changed (the flush
        /// road's contract, `AppSession.flushExistingAutosave`; the
        /// `VersionActs` precedent and its standing sentence).
        case unsavedChanges

        var sentence: String {
            switch self {
            case .unsavedChanges: return OpsRefusalCopy.unsavedChanges
            }
        }
    }

    /// **A `.take` source's pending typing lands FIRST** (VX-827 ladder
    /// R1-F1): the operation copies the take's `working_text` as stored, so
    /// the note the source is placed in — another note, perhaps, live in a
    /// second window — is flushed before the copy, and a flush that keeps
    /// bytes pending refuses rather than copy stale words. A `.commit` copies
    /// an immutable snapshot (I5) and needs nothing; an unplaced source has
    /// no editor and nothing pending.
    static func run(
        session: AppSession, source: Operations.LineageTakeSource, onto blockID: String
    ) async throws -> String {
        if case .take(let takeID) = source,
           let note = await placedNote(session: session, takeID: takeID),
           !(await session.flushExistingAutosave(forPost: note)) {
            throw Refusal.unsavedChanges
        }
        let take = try await session.runner.run { ops in
            try ops.bringBackFromLineage(source, onto: blockID)
        }
        return CommitsFaceCopy.broughtBackFromLineage(label: take.label)
    }

    /// The container a block is live-placed in (a note, or the scraps), or
    /// nil — one indexed read (`uq_cblock_ownership`).
    static func placedNote(session: AppSession, blockID: String) async -> String? {
        try? await session.database.read { db in
            try String.fetchOne(
                db,
                sql: "SELECT container_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                arguments: [blockID])
        }
    }

    /// The container a take's block is live-placed in, or nil.
    static func placedNote(session: AppSession, takeID: String) async -> String? {
        try? await session.database.read { db in
            try String.fetchOne(
                db,
                sql: """
                    SELECT cb.container_id FROM variant v
                    JOIN container_block cb ON cb.block_id = v.block_id AND cb.deleted_at IS NULL
                    WHERE v.id = ?
                    """,
                arguments: [takeID])
        }
    }
}
