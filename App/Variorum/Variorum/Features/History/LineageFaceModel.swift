//
//  LineageFaceModel.swift
//  Variorum (Mac)
//
//  **VX-801 (VX-827 U3b) — THE LINEAGE FACE, its brain.** THE DESIGN MEMO
//  (`notes/plans/fixes/vx-827-lineage.md`): *"VERTICAL, older above, NO
//  horizontal scroll anywhere: the family as a list (origin verb · first words
//  · where it lives · counts), this block marked; selecting an ancestor swaps
//  the SAME pane+rail composition to that block — its take dropdown, its rail,
//  its commits, A's two-click reach with B's geometry; Put back · Bring back as
//  take · Compare with now on the selected node's header; a Trash node muted,
//  no acts; a cross-wing node named with its wing, go-to only."* Her words at
//  the exploration sitting: *"when you select an ancestor block, you can still
//  click on its various takes & commits easily, as in A, but with the verticle
//  view instead of the horizontal scroll, as in B."*
//
//  The family is U1's read (`Queries.lineageTree`) projected by the pure
//  `LineageFamily` (order, places, acts — pinned headlessly); the selected
//  member's pane and rail are a `CommitsFaceModel` over THAT block — the
//  Commits face's own machinery, its `role` saying whose moments they are.
//  This model holds the family and the selection, and runs the header's acts
//  through the existing roads: Put back (`PreservedOriginPutBack` for a kept
//  original, `unarchiveBlock` for a set-aside block — the tray's two roads and
//  landings), Bring back as take (`LineageBringBack` — the ruled operation),
//  Compare with now (the same Compare), go to its wing (the Compare board's
//  #166(e) road).
//
//  P3: nothing here is an editor.
//

import Foundation
import GRDB  // AsyncValueObservation iteration
import Observation
import VariorumCore

/// **THE LINEAGE FACE's WORDS, ONE HOME** (PROVISIONAL — her wording pass,
/// #264; drawn from the two explorations' rows).
nonisolated enum LineageFaceCopy {
    static let crumb = "lineage"
    static let family = "family \u{B7} older above"
    static let thisBlock = CommitsFaceCopy.thisBlock
    static let here = "here"
    static let thisNote = "this note"
    static let inSnippets = "in Snippets"
    static let keptAsLineage = "kept as lineage"
    static let setAside = "set aside"
    static let inTrash = "in the Trash"
    static let savedVersion = "a saved version"
    static let compareWithNow = "Compare with now"
    static let compareWithNowHelp =
        "This block's words beside the block you came from as it is now, the changed words washed"
    static let putBackHelp =
        "Puts this block back into the note it was set aside from \u{2014} it was kept whole, "
        + "never deleted"
    static let bringBackHelp =
        "Makes these words a take of their own on this block \u{2014} the last in its fan, never "
        + "chosen. The block they came from stays as it is"
    static let trashHelp =
        "In the Trash \u{2014} put it back from the Trash itself"
    static let noLineage =
        "Nothing came before or after this block \u{2014} it was never divided, merged, extracted "
        + "or copied."
    static let selectHelp = "Read this block's takes and commits below"

    /// What happened — the connecting edge's act, in the explorations' words.
    static func verb(_ member: LineageFamily.Member) -> String {
        if member.direction == .origin { return thisBlock }
        if member.edgeType == .versionOf { return "a version" }
        switch member.originOp {
        case "divide": return "divided"
        case "merge": return "merged"
        case "extract": return "extracted"
        case "pool_copy", "manual": return "copied"
        default: return "related"
        }
    }

    /// Where it lives now.
    static func place(_ member: LineageFamily.Member, wingNames: [String: String]) -> String {
        switch member.place {
        case .thisBlock: return here
        case .placed(let home, let sameNote):
            if home.kind == .pool { return inSnippets }
            if sameNote { return thisNote }
            let note = "in \u{201C}\(home.title)\u{201D}"
            return home.isSavedVersion ? note + " (\(savedVersion))" : note
        case .keptAsLineage: return keptAsLineage
        case .setAside: return setAside
        case .inTrash: return inTrash
        case .otherWing(let wingID):
            return WingCopy.lineageElsewhere(wingName(wingID, wingNames: wingNames))
        }
    }

    /// **A member's wing, named as the wing switcher names it** (VX-920): the
    /// id read by the dangling-wing rule over the read's LIVE wing names
    /// (`Queries.effectiveWingID` — an id no live wing row carries is Home's),
    /// and Home by its one name (`WingWords.home`), never the empty "the wing
    /// “”". The member's line and its go-to button both speak it.
    static func wingName(_ wingID: String, wingNames: [String: String]) -> String {
        let wing = Queries.effectiveWingID(wingID, liveWingIDs: Set(wingNames.keys))
        return wing.isEmpty ? WingWords.home : wingNames[wing, default: WingWords.home]
    }

    /// **VX-898 — does the member stand UNPLACED?** Kept as lineage or set
    /// aside: it has no living "now" (its pane names its take "the take as
    /// kept" — `CommitsFaceCopy.nowName`). Placed members, this block, the
    /// Trash and another wing's are not (the last two are never opened).
    static func standsUnplaced(_ place: LineageFamily.Place) -> Bool {
        switch place {
        case .keptAsLineage, .setAside: return true
        case .thisBlock, .placed, .inTrash, .otherWing: return false
        }
    }

    static func counts(_ counts: LineageFamily.Counts) -> String {
        "\(counts.takes) take\(counts.takes == 1 ? "" : "s") \u{B7} "
            + CommitsFaceCopy.commitsCount(counts.commits)
    }

    /// **Put back's receipt, naming where it landed** — the road's own
    /// sentence, and the note's name when it is not the note she is in.
    static func putBackReceipt(_ base: String, home: Queries.LineageHome?, faceNoteID: String) -> String {
        guard let home, home.containerID != faceNoteID, home.kind == .post else { return base }
        return "In \u{201C}\(home.title)\u{201D}: \(base)"
    }
}

extension WingCopy {
    /// A lineage member living in ANOTHER wing — named with its wing and
    /// nothing more (#166(e)'s lineage line, the Compare board's sentence's
    /// twin). PROVISIONAL words (#264).
    nonisolated static func lineageElsewhere(_ wing: String) -> String {
        "in another library \u{2014} the wing \u{201C}\(wing)\u{201D}"
    }
}

@MainActor
@Observable
final class LineageFaceModel {
    @ObservationIgnored let session: AppSession
    /// The block the surface was opened on, and its note.
    let request: BlockHistoryRequest
    /// The member a door asked to open on (the origin door's original).
    @ObservationIgnored private let preferred: String?

    nonisolated struct Read: Equatable, Sendable {
        var tree: Queries.LineageTree?
        var counts: [String: LineageFamily.Counts] = [:]
        /// The names of the LIVE wings any member lives in (another wing's
        /// members are named with theirs; an id missing here — Home's `''`, a
        /// dead wing — is named Home, `LineageFaceCopy.wingName`).
        var wingNames: [String: String] = [:]
    }

    private(set) var members: [LineageFamily.Member] = []
    private(set) var wingNames: [String: String] = [:]
    private(set) var loaded = false
    private(set) var selectedBlockID: String?
    /// The selected member's pane and rail — the Commits face's machinery,
    /// over that block.
    private(set) var node: CommitsFaceModel?
    private(set) var status: RecoveryStatus?

    init(session: AppSession, request: BlockHistoryRequest, select: String? = nil) {
        self.session = session
        self.request = request
        self.preferred = select
    }

    // MARK: - The observation

    /// The tree (∝ this block's own lineage — U1's P1 pins), its members'
    /// counts and the wing names its homes carry: one read, re-run while the
    /// face stands.
    nonisolated static func read(_ db: Database, blockID: String) throws -> Read {
        guard let tree = try Queries.lineageTree(db, blockID: blockID) else { return Read() }
        let ids = [tree.origin.blockID] + tree.nodes.map(\.blockID)
        let wings = Set(([tree.origin] + tree.nodes).compactMap { $0.home?.wingID }.filter { !$0.isEmpty })
        var names: [String: String] = [:]
        if !wings.isEmpty {
            let json = String(decoding: try JSONEncoder().encode(wings.sorted()), as: UTF8.self)
            for row in try Row.fetchAll(
                db, sql: "SELECT id, name FROM wing WHERE deleted_at IS NULL "
                    + "AND id IN (SELECT value FROM json_each(?))",
                arguments: [json]) {
                names[row["id"]] = row["name"]
            }
        }
        return Read(
            tree: tree, counts: try Queries.lineageFamilyCounts(db, blockIDs: ids), wingNames: names)
    }

    func start() async {
        await session.flushExistingAutosave(forPost: request.postID)
        do {
            for try await value in session.database.observe({ [blockID = request.blockID] db in
                try Self.read(db, blockID: blockID)
            }) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            status = .refusal(String(describing: error))
        }
    }

    /// Internal so pins drive the face deterministically. The first snapshot
    /// seats the opening member; a later one keeps her selection while it can
    /// still be shown.
    func adopt(_ value: Read) {
        members = value.tree.map { LineageFamily.members($0, counts: value.counts) } ?? []
        wingNames = value.wingNames
        let stillShown = members.contains { $0.blockID == selectedBlockID && $0.selectable }
        if !loaded || !stillShown {
            if let opening = LineageFamily.opening(members, prefer: loaded ? nil : preferred) {
                select(opening)
            }
        }
        tellNodeWhereItStands()
        loaded = true
    }

    /// **VX-898** — the selected member's pane names its take by where the
    /// member stands, read from THIS family read every time it re-runs, so a
    /// Put back (kept → placed) flips "the take as kept" to "the take now" live.
    private func tellNodeWhereItStands() {
        guard let node, let member = selected else { return }
        let unplaced = LineageFaceCopy.standsUnplaced(member.place)
        if node.relativeStandsUnplaced != unplaced { node.relativeStandsUnplaced = unplaced }
    }

    // MARK: - Projections

    var selected: LineageFamily.Member? {
        members.first { $0.blockID == selectedBlockID }
    }

    /// Nothing but this block — the honest empty state.
    var hasNoLineage: Bool { loaded && members.allSatisfy { $0.direction == .origin } }

    func verb(_ member: LineageFamily.Member) -> String { LineageFaceCopy.verb(member) }
    func place(_ member: LineageFamily.Member) -> String {
        LineageFaceCopy.place(member, wingNames: wingNames)
    }

    func wingName(_ id: String) -> String { LineageFaceCopy.wingName(id, wingNames: wingNames) }

    // MARK: - Selecting

    /// Swaps the pane and rail to this member (selectable members only — a
    /// Trash member and another wing's are not opened here).
    func select(_ blockID: String) {
        guard let member = members.first(where: { $0.blockID == blockID && $0.selectable }) else { return }
        guard blockID != selectedBlockID || node == nil else { return }
        selectedBlockID = blockID
        status = nil
        node = member.direction == .origin
            ? CommitsFaceModel(session: session, request: request)
            : CommitsFaceModel(
                session: session, relative: blockID, shownTakeID: member.shownTakeID, of: request)
        tellNodeWhereItStands()
    }

    // MARK: - The header's acts

    /// **Put back** — a kept original is PLACED back into the note it was
    /// released from (`PreservedOriginPutBack`, the tray's and the old
    /// panel's one road, its landing re-read at act time); a set-aside block
    /// comes back where it stood (`unarchiveBlock`, the tray's road). The
    /// receipt is the road's own, naming the note when it is another.
    func putBack() async {
        guard let member = selected, member.acts.contains(.putBack) else { return }
        status = nil
        node?.clearStatus()
        do {
            switch member.place {
            case .keptAsLineage(let home?):
                let base = try await PreservedOriginPutBack.run(
                    session: session, postID: home.containerID, blockID: member.blockID)
                status = .receipt(LineageFaceCopy.putBackReceipt(
                    base, home: home, faceNoteID: request.postID))
            case .setAside(let home):
                let landing = try await session.runner.run { ops in
                    try ops.unarchiveBlock(member.blockID)
                }
                status = .receipt(LineageFaceCopy.putBackReceipt(
                    RecoveryCopy.landingReceipt(landing), home: home, faceNoteID: request.postID))
            default:
                return
            }
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.words(error, act: .putBack))
        }
    }

    /// **Bring back as take** — the member's shown take (its active text)
    /// becomes a take on the block she came from (the ruled operation, its
    /// one road).
    func bringBack() async {
        guard let member = selected, member.acts.contains(.bringBackAsTake),
              let take = member.shownTakeID else { return }
        status = nil
        node?.clearStatus()
        do {
            status = .receipt(try await LineageBringBack.run(
                session: session, source: .take(take), onto: request.blockID))
        } catch let refusal as LineageBringBack.Refusal {
            status = .refusal(refusal.sentence)
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    /// **Compare with now** — the member's shown take beside the block she
    /// came from as it stands (the same Compare, in the pane's place).
    func compareWithNow() {
        guard let member = selected, member.acts.contains(.compareWithNow),
              let take = member.shownTakeID else { return }
        node?.openCompare(against: .now(takeID: take))
    }

    /// **Go to its wing** — another wing's member's only door (#166(e): a
    /// plain go-to road, no preview, no deep link; the Compare board's own
    /// act).
    func goToWing(_ wingID: String) {
        session.wing.switchTo(wingID)
    }
}
