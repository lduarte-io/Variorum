//
//  TrayPanel.swift
//  Variorum (Mac)
//
//  Phase 13j, batch 2 (J2) — **THE PER-NOTE TRAY GETS A FACE.**
//
//  Her words (2026-08-01): *"you need to be able to see the archived blocks
//  (or deleted blocks) that are associated with a particular post, because
//  just going to the library you get a little lost."*
//
//  ── WHAT WAS ACTUALLY MISSING ────────────────────────────────────────────
//  The tray's MACHINERY has existed since Phase 2 (`deleteBlock` stamps
//  `last_container_id`, `restoreBlock` puts a block back, `Queries.trayBlocks`
//  reads the listing). What it had was one buried face: a small section at
//  the bottom of the Blocks mode's TOC, rendered only when non-empty
//  (`BlockTOCView.traySection`). Nothing in the note she was WRITING in ever
//  said a deleted block was recoverable — so past the session's ⌥⌘Z window
//  the block was, for her, gone. That is a findability defect, and this is
//  the door that ends it: it lives in the note's own chrome.
//
//  ── THE TWO SECTIONS (her round-2 ruling) ────────────────────────────────
//  She chose the visible distinction over one flat list:
//
//    · **Deleted** — blocks individually deleted FROM this note.
//    · **Preserved originals** — blocks a divide-W or a merge kept WHOLE and
//      released to lineage. They were never deleted; they are just standing
//      to one side. Round 2 removed the global "Unplaced blocks" listing
//      (J6) and made this section their home.
//
//  ONE verb per row either way — **Put back** — because from where she is
//  standing the two rows answer the same question, and two verbs for one
//  intent is the confusion this phase exists to kill.
//
//  ── WHAT THE TWO PUT BACKS ACTUALLY DO (and how they differ) ─────────────
//  A DELETED block goes through `restoreBlock`, which flips the tombstone
//  (with its exact-stamp cascade victims) AND the placement row that deletion
//  took down — so the block comes back WHERE IT WAS, in its own fractional
//  position, and Put back lands it exactly where ⌥⌘Z does. (Batch 2 shipped
//  this row against the op as it then stood, which minted a fresh placement
//  at the note's end; the architect's F2 ruling aligned the op to the restore
//  family's exact-row religion in batch 3, and the receipt reads the op's own
//  answer rather than assuming either landing — a released-then-deleted block
//  has no row to revive and still lands at the end.)
//
//  A PRESERVED ORIGINAL goes through `placeBlock` — the W-reversibility
//  primitive, exactly as the ceremony's own "reversible by re-pointing at A"
//  promises — landing immediately after its LAST live successor in this
//  note, or at the note's end when none survives. That landing is composed
//  HERE, at the face, from a fresh read at act time; no operation's
//  semantics change for it.
//
//  ── NO COUNTDOWN HERE, DELIBERATELY ──────────────────────────────────────
//  The 30-day Trash clock is J1's, batch 6. Showing "N days left" before the
//  clock exists would be exactly the class of copy J8 is about. This batch
//  shows WHEN something went, which is true today.
//
//  Read-cheap tier only (P3): rows are plain text. Nothing in a tray is ever
//  a live editor.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

/// **The ONE place the tray's user-facing name and its door are spelled**
/// — the `RecoveryPath` pattern (13f W10a), and for its reason: copy
/// elsewhere in the app promises this surface by name, so the sentence and
/// the label must be the same string or they drift apart. Rename here and
/// every receipt follows.
nonisolated enum TrayPath {
    /// The panel's own title, and the name every receipt promises.
    static let menuLabel = "This Note's Tray"

    /// **The same tray, on a surface that is not a note** (the post-13l
    /// polish round, batch 1's deferred item: the scraps editor's `note ▾`
    /// item said *"This Note's Tray…"* over a pool). A pool's tray is the
    /// scraps area's own — the `BlockRestoreLanding` kind machinery's
    /// precedent (13l row 26), applied to the door's own name.
    static func menuLabel(for home: ContainerKind) -> String {
        switch home {
        case .post: return menuLabel
        case .pool: return "This Scraps Area's Tray"
        }
    }

    /// The context bar's quiet badge — a backspace glyph and a count.
    static let doorGlyph = "\u{232B}"

    /// **How the receipts point at the door** — and since her C1 ruling the
    /// door they point at is the ICON, not the badge.
    ///
    /// Her words: *"the note tray should move to being an icon next to the
    /// scraps and reference icon and open in the side bar."* The badge
    /// survives as the glance signal (the kickoff's small call — clicking it
    /// opens the same panel), but a receipt must name a door that is ALWAYS
    /// there, and the badge is deleted-only by her own #67(a) ruling: an
    /// archived block would be pointed at a badge that is not on screen.
    static let doorPhrase = doorPhrase(for: .post)

    static func doorPhrase(for home: ContainerKind) -> String {
        switch home {
        case .post: return "the tray icon at the top of the note"
        case .pool: return "the tray icon at the top of the scraps area"
        }
    }

    /// **The tray's two VIEWS** (the use-report round's 18d batch 2 — her
    /// ruling U-9: *"archived v. leaving should be top level, with block or
    /// takes as a filter under each one"*). The names are SEMANTIC, so they
    /// live in the shared home and the phone's tray inherits them.
    ///
    /// *(They were SECTION HEADERS until 18d batch 2 — two stacked runs in
    /// one scroll, `"Leaving — on the 30-day clock"` and `"Archived — kept,
    /// no clock"`, with the takes folded under the first. Each name's second
    /// half moved one line down into that view's explainer, where there is
    /// room for it; the fold became the filter.)*
    static let archivedTab = RecoveryCopy.trayArchivedTab
    static let leavingTab = RecoveryCopy.trayLeavingTab
    static let leavingExplainer = RecoveryCopy.trayLeavingExplainer
    static let archivedExplainer = RecoveryCopy.trayArchivedExplainer
    // (`originalsSection` is RETIRED — the post-13l polish round, batch 4:
    // her G5 ruling moved unclocked originals to lineage, so the tray has no
    // such section to name. The path constants below now point at the Block
    // History pane's came-from region, which is where they went.)
    /// The one verb, both sections.
    ///
    /// **Round 2 batch 4 (mobile): the SEMANTIC strings below now live in
    /// `Shared/RecoveryCopy.swift`** and these are forwarders — this enum's
    /// own "one home so receipts cannot drift" argument, applied across the
    /// platform boundary now that the phone has recovery surfaces too. The
    /// tray's pure chrome (the menu label, the ⌫ glyph, the door phrase,
    /// the section headers) stays here, where only the Mac reads it.
    static let putBackVerb = RecoveryCopy.putBackVerb

    /// **The countdown** (13j J1 — 30 days, her fixed window). Deleted rows
    /// wear it; ARCHIVED rows never do (archive is kept-forever, and that
    /// difference is the whole reason the two states share a section header
    /// that names them both).
    static func daysLeftLabel(_ days: Int) -> String {
        RecoveryCopy.daysLeftLabel(days)
    }

    /// What an ARCHIVED row says instead of a countdown — the promise stated,
    /// so the two row kinds in one section are never read as one thing.
    static let archivedForever = RecoveryCopy.archivedForever

    /// **The stranded original's label** (her round-8b ruling): an original
    /// whose whole descendant family is in the Trash rides the family's
    /// clock, and says so where she can see it. Her failure mode, in her own
    /// words, was believing "the ancestor being there in that one ancestor
    /// tray is their guaranteed backup" — so the row MOVES, visibly, and
    /// wears the reason.
    static let goesWithItsFamily = RecoveryCopy.goesWithItsFamily

    static func doorLabel(deleted: Int) -> String { "\(doorGlyph) \(deleted)" }

    /// **The put-back receipts, in ONE place** (13j batch 3): the tray's two
    /// sections and the origin peek all speak them, so three doors onto two
    /// acts cannot describe the same landing three ways.
    ///
    /// The deleted-block half moved with the F2 rider: `restoreBlock` now
    /// flips the placement row this deletion tombstoned, so a block normally
    /// comes back WHERE IT WAS — and the receipt says that instead of
    /// "at the end", which is what it had to say while the op minted fresh.
    ///
    /// **13l Act 2 (ledger row 26): the two landing-shaped receipts take the
    /// home's KIND**, because a block can have come out of the SCRAPS area
    /// and both sentences said "note" whatever the row was. The tray's own
    /// two doors no longer switch over the landing at all — they call
    /// `RecoveryCopy.landingReceipt`, the one place a landing becomes words
    /// (the Trash surface already did), so the kind cannot be honoured in one
    /// door and forgotten in the other.
    static let putBackWhereItWas = RecoveryCopy.putBackWhereItWas
    static func putBackAtEnd(_ home: ContainerKind) -> String {
        RecoveryCopy.putBackAtEnd(home)
    }
    static let putBackBeside = RecoveryCopy.putBackBeside
    /// The block is live again but has nowhere to land (its home is gone).
    /// Unreachable from the tray, which is always open ON a live note —
    /// worded anyway, because a receipt that cannot be produced is still a
    /// receipt a future door could produce.
    static func putBackUnplaced(_ home: ContainerKind?) -> String {
        RecoveryCopy.putBackUnplaced(home)
    }

    /// **Where a released original waits, in one phrase** — the string every
    /// ceremony explainer, merge receipt and helper entry uses. It replaced
    /// `RecoveryPath.unplacedBlocks`, which named the room J6 removed; ONE
    /// constant, so eight copy sites cannot drift.
    ///
    /// **The destination MOVED at the post-13l polish round** (batch 4, her
    /// G5 ruling: *"the tray audits what is LEAVING; lineage holds what is
    /// KEPT"*), and the eight sites followed for free — which is the whole
    /// argument for the constant, made good a second time. It now names the
    /// Block History pane's came-from region.
    static var originalsPath: String { BlockHistoryPath.cameFromPath }

    /// The same phrase with the door spelled out, for copy that has to teach
    /// the way in rather than merely name the place.
    static var originalsPathWithDoor: String { BlockHistoryPath.cameFromPathWithDoor }
}

/// A surface's pending request to show the tray — the `CommentsRequest`
/// shape, because the two doors that raise it (the `note ▾` item and the
/// lineage door's landing) both live on a view model while the sheet lives
/// on its view.
///
/// `revealBlockID` is what makes the lineage door land somewhere true:
/// "Show Original Block" used to navigate to the Library's global unplaced
/// listing, which J6 removed, so it now opens the note's own tray with the
/// original's row marked.
nonisolated struct TrayRequest: Identifiable, Equatable, Sendable {
    let postID: String
    var revealBlockID: String?
    var id: String { "\(postID)#\(revealBlockID ?? "")" }
}

@MainActor
@Observable
final class TrayViewModel {
    @ObservationIgnored private let session: AppSession
    let postID: String

    /// The bounded window + the probe row, the standing held-observation
    /// discipline (`RecoveryViewModel.window`'s shape and reason).
    nonisolated static let window = 500

    private(set) var deleted: [Queries.TrayItem] = []
    private(set) var deletedTruncated = false
    /// **13j batch 6 — the state batch 2 found unreachable is real now.**
    /// That batch's VERIFY-1 swept `Sources/VariorumCore` and found NO
    /// operation writing `block.archived_at`; her round-7 ruling built
    /// `archiveBlock`/`unarchiveBlock`, so archived blocks list here beside
    /// the deleted ones — with no countdown, which is the difference the
    /// section header now names.
    private(set) var archived: [Queries.TrayItem] = []
    /// **The archived arm's probe row, finally read** (18o U1, 17e P37): it
    /// was fetched with `window + 1` like its siblings and thrown away by a
    /// bare `prefix`, so a note with more than `window` archived blocks
    /// listed exactly `window` with nothing saying more exist. Now the arm
    /// windows the way the takes arm does and the archived view renders the
    /// same `truncation` line — KnownIssues' standing rule, *"bounded view
    /// windows show markers, not more"*.
    private(set) var archivedTruncated = false
    // (The **Preserved originals** listing LEFT this model at the post-13l
    // polish round, batch 4 — her G5 ruling: *"the tray audits what is
    // LEAVING; lineage holds what is KEPT."* An UNCLOCKED original is not
    // leaving anything, so its home is the Block History pane's came-from
    // region, which also shows ALL of a merge's originals rather than the
    // first. `Snapshot.originals` stays, because `stranded` below is derived
    // from it: an original whose family has died IS leaving, and that row is
    // still this panel's.)
    /// **The note's deleted TAKES** (the post-13l polish round, ledger row 20
    /// — her G5 ruling: *"takes can be shown in that per note trash, albeit
    /// maybe not shown by default, so you can always see a list of what will
    /// be deleted"*). They left the GLOBAL Trash by her D1 ruling; this is the
    /// note-scoped audit lens that replaces it, and the ONLY place a take
    /// carries a purge door.
    ///
    /// They ride the SAME observation as the rest of the tray rather than a
    /// second one started by the disclosure, deliberately: the panel's
    /// existing arms already read `variant` (`trayBlocks` joins the default
    /// take's text), so the observation already re-runs when a buffer is
    /// saved — a second lifecycle would buy nothing and would cost the
    /// collapsed section its count, and a fold that hides its own size is not
    /// an audit.
    private(set) var takes: [Queries.TrayTake] = []
    private(set) var takesTruncated = false
    /// The originals whose last live descendant has been deleted: they have
    /// MOVED onto the family's clock, and the tray shows the move rather than
    /// letting a row quietly change meaning where she is not looking. Keyed
    /// by block id → the family's FATE (13j ladder B, B5): `.counting` rides
    /// the clock section; `.gone` — window expired or intent standing —
    /// leaves BOTH buckets, exactly as the Trash's twin arm reads the same
    /// state (the query's own doc carries the reasoning).
    private(set) var strandedFates: [String: Queries.OriginFamilyFate] = [:]

    /// **A RECEIPT IS NOT A REFUSAL** (the post-13l polish round, ledger row
    /// 6 — her A6 ruling on the 13l walk's P-5(a): *"the color: should be
    /// fixed"*).
    ///
    /// The panel had ONE status slot and painted it `.foregroundStyle(.red)`
    /// for every message class, so *"Put back where it was."* — a success,
    /// the whole point of the surface — read as an error. The Trash surface
    /// one file over had already split them (`lastError` red beside `receipt`
    /// secondary); this is the tray's own split, through the voice tokens
    /// rather than a literal colour in a themed surface.
    ///
    /// The message is CLASSED where it is produced, never guessed by the
    /// view: the doors below know whether the op answered or refused, and a
    /// view re-deriving that from the text would be exactly the projection
    /// the model exists to prevent.
    /// **The type itself is `Shared/RecoveryStatus`** since mobile round 2
    /// batch 6a — the phone's Block History face classes its messages the
    /// same way, and a receipt/refusal split written twice is the drift this
    /// very split exists to prevent. The name stays, so every shipped Mac
    /// call site and pin rides unmodified (the 3C parity pattern).
    typealias Status = RecoveryStatus

    private(set) var status: Status?

    /// The pre-existing read, kept as a forwarder so every shipped pin rides
    /// unmodified (the 3C parity pattern — a zero-test-edit suite is the
    /// proof the split moved a class and not a behaviour).
    var statusMessage: String? { status?.text }

    /// The row the caller asked to be shown (the J3-family lineage door's
    /// landing). Consumed by the view for its highlight; `revealMissing`
    /// says the honest thing when the asked-for block is not in either list.
    let revealBlockID: String?

    init(session: AppSession, postID: String, revealBlockID: String? = nil) {
        self.session = session
        self.postID = postID
        self.revealBlockID = revealBlockID
        // The last view and filter of THIS session (18d batch 2's own line;
        // the `mergeJoinMemory` precedent — one AppSession per launch, so a
        // fresh launch opens on Leaving · all and parallel test worlds stay
        // independent).
        self.view = session.trayViewMemory.view
        self.kind = session.trayViewMemory.kind
    }

    // MARK: - The view and the filter (18d batch 2 — her ruling U-9)

    /// The TOP-LEVEL choice, and the filter under it. Both live on the model
    /// rather than in the view's `@State` for the reason the fold they
    /// replace did not have to care about: they decide what the panel
    /// RENDERS, they are remembered for the session, and the reveal moves
    /// them — three things a pin must be able to drive without a window.
    private(set) var view: TrayView
    private(set) var kind: TrayKind

    func select(view: TrayView) {
        self.view = view
        remember()
    }

    func select(kind: TrayKind) {
        self.kind = kind
        remember()
    }

    private func remember() {
        session.trayViewMemory = TrayViewMemory(view: view, kind: kind)
    }

    /// The four populations as ONE value for the pure rule (`TrayFilter`).
    var contents: TrayContents {
        TrayContents(
            deleted: deleted, stranded: stranded, takes: takes, archived: archived)
    }

    /// What the current cell renders, in render order.
    var rows: TrayRows { TrayFilter.rows(contents, view: view, kind: kind) }

    /// The segmented choice's count for a view — everything it holds,
    /// whatever the filter says.
    func count(of view: TrayView) -> Int { TrayFilter.count(contents, view: view) }

    /// A chip's count, following the CURRENT view (U-9's *"under each one"*).
    func count(of kind: TrayKind) -> Int {
        TrayFilter.count(contents, view: view, kind: kind)
    }

    var isEmpty: Bool {
        deleted.isEmpty && archived.isEmpty && stranded.isEmpty && takes.isEmpty
    }

    // (`nothingIsLeaving` — "is anything on this note's clock?" — RETIRED at
    //  18d's round-1 ladder, NIT-1: the panel's empty line has been
    //  `TrayFilterFace.nothing(view:kind:home:)` since batch 2, so the
    //  property had no production reader left and only a pin still called
    //  it. The same question is `TrayFilter.count(contents, view: .leaving)`,
    //  which is the number the tab already renders. Dead code removed, not
    //  parked — this batch's own standard, applied to itself.)

    /// True once the listings have loaded and the requested block was in
    /// neither of them — e.g. an original released from a DIFFERENT note
    /// (`last_container_id` names where it was released, and a successor can
    /// since have moved). One quiet line rather than a guess at the cause.
    ///
    /// **IT IS AN ARRIVAL-TIME EXPLANATION, AND IT IS LATCHED AT ARRIVAL**
    /// (the post-13l polish round, ledger row 1 — her A1 ruling on the 13l
    /// walk's P-4: *"that just seems sloppy, it should show a success message
    /// if anything"*).
    ///
    /// The shipped version was a computed property re-evaluated live against
    /// the observation, so a SUCCESSFUL Put back from the revealed row made
    /// it true — the row had left the tray by succeeding — and the panel
    /// printed *"The block you asked to see isn't in this note's tray."*
    /// directly under the receipt that said it had just been put back. The
    /// sentence answers "why is nothing marked when I got here?", which is a
    /// question about arrival; asking it of a listing that has since changed
    /// under her own hand is asking it at the wrong moment.
    ///
    /// So it is decided ONCE, on the first loaded snapshot, and never
    /// revisited: an act of hers can no longer turn the explanation on.
    private(set) var loaded = false
    private(set) var revealMissing = false
    /// Row 68 (the correction round): the third arrival state — the revealed
    /// block EXISTS but is a KEPT original (unclocked, so this panel lists it
    /// nowhere by her G5 ruling). Latched at arrival exactly like
    /// `revealMissing`, and for its reason.
    private(set) var revealKeptInLineage = false

    func start() async {
        let now = session.now
        do {
            for try await value in session.database.observe({ [postID] db in
                Snapshot(
                    // A6 (ladder A round 1): BOTH listings bounded in SQL —
                    // the deleted half was fetched whole and windowed in
                    // memory, the discipline honored only halfway.
                    deleted: try Queries.trayBlocks(
                        db, postID: postID, now: now, limit: Self.window + 1),
                    archived: try Queries.archivedBlocks(
                        db, postID: postID, limit: Self.window + 1),
                    originals: try Queries.preservedOriginals(
                        db, postID: postID, limit: Self.window + 1),
                    // Seeded by THIS note's originals, so the recursion walks
                    // their families and nothing else — the tray holds this
                    // observation while the note is open, so its cost is P1's
                    // business (`Queries.originFamilyClocks`).
                    strandedFates: try Queries.originFamilyClocks(
                        db, postID: postID, now: now),
                    // Ledger row 20: the leaving section's third population,
                    // bounded in SQL like its siblings.
                    takes: try Queries.trayTakes(
                        db, postID: postID, now: now, limit: Self.window + 1))
            }) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            status = .refusal(String(describing: error))
        }
    }

    nonisolated struct Snapshot: Equatable, Sendable {
        var deleted: [Queries.TrayItem] = []
        var archived: [Queries.TrayItem] = []
        var originals: [Queries.PreservedOriginal] = []
        var strandedFates: [String: Queries.OriginFamilyFate] = [:]
        var takes: [Queries.TrayTake] = []
    }

    /// Internal so tests drive the panel deterministically (the
    /// `CommentsPanelModel.adopt` seam).
    func adopt(_ snapshot: Snapshot) {
        deletedTruncated = snapshot.deleted.count > Self.window
        deleted = deletedTruncated
            ? Array(snapshot.deleted.prefix(Self.window)) : snapshot.deleted
        (archived, archivedTruncated) = TrashListing.windowed(
            snapshot.archived, window: Self.window)
        (takes, takesTruncated) = TrashListing.windowed(
            snapshot.takes, window: Self.window)
        strandedFates = snapshot.strandedFates
        // The SPLIT her round-8b ruling asked for, made where the two lists
        // are handed over: an original with a live descendant stays in the
        // forever section; one whose family is COUNTING moves up into the
        // clock-bearing section, in this same panel, where she can see it
        // go — and one whose family is GONE (window expired, or Delete Now
        // named it) appears in NEITHER (13j ladder B, B5): it rode its
        // visible clock and leaves every surface exactly when the clock
        // said, unreachable-until-purge like its family.
        stranded = snapshot.originals.filter {
            if case .counting = strandedFates[$0.blockID] { return true }
            return false
        }
        // Ledger row 1: the arrival-time answer, decided on ARRIVAL. Every
        // later snapshot — including the one a successful Put back produces —
        // leaves it exactly as the first listing found it.
        if !loaded, let revealBlockID {
            // The snapshot's originals, not a stored listing: the panel no
            // longer LISTS the unclocked ones (they moved to lineage), but a
            // reveal that names one is still answerable — and answering "it
            // isn't here" for a row that exists would be the arrival-time lie
            // this sentence exists to avoid.
            let inDeleted = deleted.contains { $0.blockID == revealBlockID }
            let inArchived = archived.contains { $0.blockID == revealBlockID }
            let inOriginals = snapshot.originals.contains { $0.blockID == revealBlockID }
            let inStranded = stranded.contains { $0.blockID == revealBlockID }
            revealMissing = !inDeleted && !inArchived && !inOriginals
            // Row 68: an UNCLOCKED original (in the family, not counting) is
            // listed nowhere here — the walk's landing marked nothing and
            // said nothing. The third state says where it lives instead.
            revealKeptInLineage = inOriginals && !inStranded
                && !inDeleted && !inArchived
            // 18d batch 2: a mark under the OTHER tab is a mark she cannot
            // see. The panel opens on the view that holds the revealed row,
            // unfiltered — latched at arrival like the two sentences above,
            // and for the same reason (a later act of hers must never move
            // the tab under her hand).
            //
            // **It does NOT `remember()`** (18d's round-1 ladder, NIT-2).
            // §5.4's remembered pair is *the last view and filter* — HER
            // choice, not a landing: a lineage door's reveal that wrote the
            // memory would make "where the tray opens" mean "wherever the
            // last receipt sent me", and the next unrelated ⌫ press would
            // land somewhere she never picked. So the two fields are set
            // directly here, past `select`, and the session keeps what she
            // last chose.
            if let holder = TrayFilter.viewHolding(revealBlockID, in: contents) {
                view = holder
                kind = .all
            }
        }
        loaded = true
    }

    /// The originals now riding the Trash's clock — rendered in the first
    /// section beside the deleted blocks, wearing the family's countdown.
    private(set) var stranded: [Queries.PreservedOriginal] = []

    /// The counting family clock for a stranded row (nil for permanent or
    /// gone — the row then renders elsewhere or nowhere, B5).
    func strandedClock(_ blockID: String) -> String? {
        if case .counting(let stamp)? = strandedFates[blockID] { return stamp }
        return nil
    }

    // MARK: - Put back

    /// A deleted block: `restoreBlock`.
    ///
    /// **13j batch 3 — the F2 rider.** The op now flips the placement row
    /// this deletion tombstoned, so the block comes back in its OWN place and
    /// Put back lands it exactly where ⌥⌘Z does. The receipt reads the op's
    /// own answer rather than assuming one: a block released to lineage and
    /// deleted later has no row to revive and still lands at the end, and
    /// saying "where it was" there would be the copy-truth defect one door
    /// over.
    func putBackDeleted(_ blockID: String) async {
        status = nil
        do {
            let landing = try await session.runner.run { ops in
                try ops.restoreBlock(blockID)
            }
            // 13l row 26: ONE place turns a landing into words, and it reads
            // the home's kind the op now reports — so a scrap's Put back
            // stops calling the scraps area a note.
            status = .receipt(RecoveryCopy.landingReceipt(landing))
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(String(describing: error))
        }
    }

    /// An ARCHIVED block (13j, her round-7 ruling): `unarchiveBlock` — the
    /// stamp is cleared and the placement row this archive released comes
    /// back, so the block lands where it stood. The receipt reads the op's
    /// own answer, exactly as the deleted row's does.
    func putBackArchived(_ blockID: String) async {
        status = nil
        do {
            let landing = try await session.runner.run { ops in
                try ops.unarchiveBlock(blockID)
            }
            status = .receipt(RecoveryCopy.landingReceipt(landing))
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(String(describing: error))
        }
    }

    /// A preserved original: `placeBlock` after its last live successor,
    /// through the ONE shared brain the peek also calls (13j batch 3 — two
    /// doors, one act).
    func putBackOriginal(_ blockID: String) async {
        status = nil
        do {
            // The act's own contract: it RETURNS the receipt and THROWS its
            // refusals, so the class is decided by which road we are on and
            // never by reading the sentence back.
            status = .receipt(try await PreservedOriginPutBack.run(
                session: session, postID: postID, blockID: blockID))
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(String(describing: error))
        }
    }

    /// A deleted TAKE: `restoreVariant` — the recovery-door class (no undo
    /// entry; the door IS the recovery). The receipt reads the op's OWN
    /// answer, exactly as every other put-back road on this model does: the
    /// restore is an exact flip (#68(b)), so a take that was archived when it
    /// was deleted comes back archived, into the archived listing rather than
    /// the fan, and one sentence for both would be false for one of them.
    func putBackTake(_ variantID: String) async {
        status = nil
        do {
            let restored = try await session.runner.run { ops in
                try ops.restoreVariant(variantID)
            }
            status = .receipt(RecoveryCopy.takeRestoredReceipt(restored))
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    // MARK: - Delete Now, on a take, HERE (her G5 fourth-sitting addition)

    /// **The purge door's pending ask.** Her ruling gave the take rows in this
    /// section a Delete Now *"to keep the capability"* — and the
    /// confirmation-consistency principle binds it exactly as it binds the
    /// Trash's: **it confirms EVERY time**, with no don't-ask state anywhere
    /// and none to be added (her round-10 ruling).
    ///
    /// **This is the evolved in-Trash-only rule, not a breach of it.** The
    /// 13j round-3 rider said purge doors live *"inside the Trash only —
    /// never a door in a note or the editor, ever"*; her G5 ruling
    /// supersedes it IN PART with the rule the round records: purge doors
    /// live in TRASH SURFACES — the global Trash and this note-level trash
    /// section — and never in the writing flow. This section is a trash
    /// surface: it lists only what is already deleted and already counting
    /// down.
    private(set) var pendingPurge: TrashPurge.Confirm?

    /// The per-row door: raises the confirm, never acts. The Trash's own
    /// `requestDeleteNow` shape, and the same shared rule behind it.
    func requestDeleteNowTake(_ take: Queries.TrayTake) {
        guard let confirm = TrashPurge.deleteNowConfirm(for: trashItem(for: take))
        else { return }
        pendingPurge = confirm
    }

    /// **THE SAME DOOR ON A LEAVING BLOCK ROW** — 17p batch b, row 3, her
    /// ruling R-Q3 (*"Add it to block rows"*: the block rows get Delete Now
    /// *"with the same confirm-every-time door the Library's Trash gives a
    /// block"*).
    ///
    /// It is `requestDeleteNowTake`'s line for a different row type, and
    /// deliberately nothing more: ONE confirm (`TrashPurge.deleteNowConfirm`),
    /// ONE act (`confirmPendingPurge` → `TrashPurge.confirm` → `requestPurge`),
    /// ONE copy (`RecoveryCopy.deleteNowConfirm(.block)` — the very sentence
    /// the Trash's own block row asks). No second confirm text and no second
    /// purge path exist for this row, because the capability was never
    /// missing — only its door in this panel was (review focus F-4).
    ///
    /// `savedVersions` is deliberately left at its default 0: the count the
    /// Trash passes names a NOTE's saved moments beside it in the Trash
    /// (`RecoveryView`'s LR1-4 line), and a block has none — a sentence about
    /// versions over a block row would be false.
    func requestDeleteNowBlock(_ item: Queries.TrayItem) {
        guard let confirm = TrashPurge.deleteNowConfirm(for: trashItem(for: item))
        else { return }
        pendingPurge = confirm
    }

    func cancelPendingPurge() {
        pendingPurge = nil
    }

    /// **The confirm is PASSED IN, never read back** — 13l Act 2's rule, and
    /// the reason it is a rule: SwiftUI writes `isPresented = false`
    /// synchronously inside the button's own click handling, before an
    /// action's `Task` can resume, so a continuation that opened by reading
    /// the pending value back returned without doing anything every time.
    /// Four dead confirm doors were found that way; this door is born with
    /// the fix.
    func confirmPendingPurge(_ confirm: TrashPurge.Confirm) async {
        pendingPurge = nil
        status = nil
        do {
            status = .receipt(try await TrashPurge.confirm(session: session, confirm))
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    /// The take, as the shared purge layer's row type. The purge machinery
    /// speaks `Queries.TrashItem` because a purge target is a table and a row
    /// id — and a take's are exactly `variant` and its own id, whichever
    /// surface offered the door.
    nonisolated func trashItem(for take: Queries.TrayTake) -> Queries.TrashItem {
        Queries.TrashItem(
            kind: .take, id: take.variantID, deletedAt: take.deletedAt,
            text: take.text, noteID: postID, blockID: take.blockID)
    }

    /// The leaving BLOCK, as the shared purge layer's row type (row 3). A
    /// block's purge target is the `block` table and the block's own id —
    /// exactly what the global Trash hands the same machinery for the same
    /// row (`Queries.trash`'s block arm), so the family the server-side
    /// expansion takes is the same family either door would have taken.
    nonisolated func trashItem(for item: Queries.TrayItem) -> Queries.TrashItem {
        Queries.TrashItem(
            kind: .block, id: item.blockID, deletedAt: item.deletedAt,
            text: item.text, noteID: postID, blockID: item.blockID)
    }
}

// `PreservedOriginPutBack` MOVED to `Shared/RecoveryCopy.swift` at round 2
// batch 4 (mobile), with its full doc comment: the phone's Trash needs the
// identical read-then-place composition, and two copies of a read-then-write
// is exactly what MobileSoul §3 forbids. The tray's two doors above still
// call it; so does the phone's Trash.

/// **Did this delete strand a preserved original?** (13j, her round-8b
/// ruling (d) — the receipt names it.)
///
/// Her concern, verbatim: *"the issue I don't want is for someone to think
/// the ancestor being there in that one ancestor tray is their guaranteed
/// backup and then they freely delete a block only to realize the ancestor
/// disappeared later."* The design answer was that the original MOVES,
/// visibly, onto the family's clock — and the moment the move happens is a
/// delete she just made, so the receipt is where she will actually read it.
///
/// Asked AFTER the delete lands, from the store: whether the deleted block
/// was the last live descendant is a fact about rows, not about a
/// projection, and a projection is exactly what a surface would be guessing
/// from. Returns nil when nothing was stranded — the ordinary case, and no
/// sentence at all is better than a reassuring one.
@MainActor
enum StrandedOriginals {
    static func note(session: AppSession, blockIDs: [String]) async -> String? {
        guard !blockIDs.isEmpty else { return nil }
        let stranded = (try? await session.database.read { db in
            try Queries.originalsStrandedBy(db, blockIDs: blockIDs)
        }) ?? []
        guard !stranded.isEmpty else { return nil }
        return BlockSelectionCopy.strandedOriginalNote(stranded.count)
    }
}

/// The tray's own refusals, in words. Only ONE case needs saying in this
/// surface's voice — the seal — and it says it as a diagnosis with the way
/// out (the J8 doctrine): the tray still OPENS under a seal, because reading
/// is free; it is putting back that the seal refuses.
nonisolated enum TrayRefusalCopy {
    static let sealed = RecoveryCopy.sealedPutBackRefusal

    static func message(for error: Error) -> String {
        if let error = error as? OperationError, case .lockedPost = error {
            return sealed
        }
        return OpsRefusalCopy.message(for: error)
    }
}

/// **THE TRAY'S REGISTRY DOORS** (P-1) — declared on the panel itself, the
/// `RecoveryView`/`BlockPastSection` shape: the surface that renders an act
/// inline is the surface that names it, and the walk's union names every
/// renderer by construction.
///
/// **`.deleteNow` on this surface is the EVOLVED in-Trash-only rule, and it
/// is worth reading the evolution rather than assuming a breach.** 13j's
/// round-3 rider put the purge doors *"inside the Trash only — never a door
/// in a note or the editor, ever"*, and the registry walk has enforced it by
/// naming `RecoveryView` as their only renderer. Her G5 fourth-sitting ruling
/// supersedes that IN PART: the take rows in the note's leaving section carry
/// a Delete Now *"to keep the capability"*, because takes no longer row in
/// the global Trash at all (D1) and a capability with no door is a capability
/// removed. The rule the round records in its place: **purge doors live in
/// TRASH SURFACES — the global Trash and this note-level trash section — and
/// never in the writing flow.** This section qualifies by construction: every
/// row in it is already deleted and already counting down.
struct TrayPanel: View {
    /// The registry ids this panel renders inline (see the note above).
    static let surfaceCapabilities: [CapabilityID] = [.restoreTake, .deleteNow]

    let session: AppSession
    let postID: String
    /// What this tray is the tray OF. A pool's tray is the scraps area's own
    /// (batch 1's deferred item — the label said "This Note's Tray" over a
    /// container that is not a note). Defaulted, so every note-side host and
    /// every shipped pin rides unmodified.
    var home: ContainerKind = .post
    /// **How this panel closes.** In a sheet the environment's `dismiss` is
    /// the answer; in the INSPECTOR (her C1 move) it is not — the panel is a
    /// column the host puts away, so the host hands down the closing act.
    var onClose: (() -> Void)?
    @State private var model: TrayViewModel
    // (The takes FOLD retired at 18d batch 2 — her ruling U-9. Its `@State`
    //  went with it: the view and the filter that replace it live on the
    //  MODEL, remembered for the session, because the reveal moves them and
    //  a pin must be able to drive them without a window.)
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession, postID: String, revealBlockID: String? = nil,
        home: ContainerKind = .post, onClose: (() -> Void)? = nil,
        model: TrayViewModel? = nil
    ) {
        self.session = session
        self.postID = postID
        self.home = home
        self.onClose = onClose
        _model = State(initialValue: model
            ?? TrayViewModel(session: session, postID: postID, revealBlockID: revealBlockID))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// **The Act 10 item 1 rebuild, REORGANIZED at 18d batch 2.**
    ///
    /// Act 10 retired the `List` for a ScrollView of calm cards (her
    /// screenshot: the Leaving header clipped to a sliver, the traced class
    /// being a plain List's fixed header-height measurement). That grammar
    /// stays. What her ruling U-9 changes is the CHOOSING above it:
    ///
    ///   *"you should be able to select if you want to see leaving, if you
    ///   want to see blocks or takes under leaving, and separetly if you want
    ///   to see archived (archived v. leaving should be top level, with block
    ///   or takes as a filter under each one"*
    ///
    /// So the two stacked sections become ONE segmented choice carrying its
    /// count, with ONE filter row under it whose counts follow the view, and
    /// one explainer line per view. **The "▸ N deleted takes" fold retires:**
    /// the filter is the fold, and it is a fold that cannot be missed — her
    /// complaint was a disclosure hiding under the block cards.
    ///
    /// Nothing about what the tray HOLDS moved: the three leaving
    /// populations and the archived one are the same rows from the same
    /// queries, and Put back / Delete Now are where they were (the 13j
    /// doctrine — a purge door lives in a trash surface, never in the
    /// writing flow).
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(tokens.chromeLabel(TrayPath.menuLabel(for: home)))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Spacer()
                Button("Close") { close() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
            }
            // Ledger row 6: a receipt reads as a receipt. The two classes
            // are the model's (`TrayViewModel.Status`), and both colours are
            // VOICE TOKENS — the shipped slot painted a literal `.red` in a
            // themed surface, which is the second half of the same defect.
            if let status = model.status {
                Text(status.text)
                    .font(tokens.small)
                    .foregroundStyle(status.isRefusal ? tokens.alarm : tokens.muted)
                    .textSelection(.enabled)
            }
            if model.revealMissing {
                Text(tokens.chromeLabel(RecoveryCopy.trayRevealMissing(home)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
            // Row 68 (the correction round): the arrival explanation's THIRD
            // state — the asked-for block is a KEPT original (G5 moved what
            // is kept to lineage), so nothing here is wrong and nothing here
            // is marked; the sentence says where it actually lives.
            if model.revealKeptInLineage {
                // Row 89: an explainer sentence wraps whole, never truncates.
                // (Ladder R1-6: not the b6dae25 class — the tray pins
                // `minWidth: 280`, so the near-zero-width probe measures 280 pt
                // either way; pinned in `ChromeMinHeightTests`. Left here.)
                Text(tokens.chromeLabel(RecoveryCopy.trayRevealKeptInLineage(home)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            viewChoice
            filterRow
            explainerLine
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    cellRows
                }
                .padding(.bottom, 8)
            }
        }
        .padding(12)
        // The panel lives in the INSPECTOR now (her C1 ruling), whose column
        // width the host sets — so the minimum is the SHEET's floor for the
        // hosts that still present it that way, and never a demand the
        // inspector cannot meet.
        .frame(minWidth: 280, minHeight: 280)
        .background(tokens.surface)
        .task { await model.start() }
        .trayPurgeConfirmDialog(model)
    }

    /// **THE TOP-LEVEL CHOICE** (U-9), in the mockup's `.seg` grammar: two
    /// words in one bordered group, the chosen one washed and accented, each
    /// carrying its count — including a zero, because *"Archived 0"* answers
    /// the question before she clicks it. Full-width halves rather than the
    /// mockup's inline pill: the panel is an inspector column at 280 pt, and
    /// a generous target is C-7's standing rule.
    private var viewChoice: some View {
        HStack(spacing: 0) {
            ForEach(TrayView.allCases) { choice in
                let on = model.view == choice
                Button { model.select(view: choice) } label: {
                    HStack(spacing: 5) {
                        Text(tokens.chromeLabel(TrayFilterFace.tab(choice)))
                            .font(tokens.small)
                            .fontWeight(on ? .semibold : .regular)
                            .foregroundStyle(on ? tokens.accent : tokens.muted)
                            .lineLimit(1)
                        Text("\(model.count(of: choice))")
                            .font(tokens.small)
                            .foregroundStyle(on ? tokens.accent : tokens.faint)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(on ? tokens.wash : tokens.card)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(TrayFilterFace.explainer(choice, home: home))
                if choice != TrayView.allCases.last {
                    Rectangle().fill(tokens.line).frame(width: 1)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
    }

    /// **THE FILTER UNDER BOTH VIEWS** — one row, shared, so the control
    /// never changes shape under her hand (figure D). The counts follow the
    /// view; `all` carries none, because the segment above it does.
    private var filterRow: some View {
        HStack(spacing: 6) {
            ForEach(TrayKind.allCases) { kind in
                VoicedChip(
                    tokens: tokens,
                    text: TrayFilterFace.chip(kind, count: model.count(of: kind)),
                    on: model.kind == kind) { model.select(kind: kind) }
                    .help(chipHelp(kind))
            }
            Spacer(minLength: 0)
        }
    }

    /// A chip's tooltip. The takes chip inherits the retired fold's own
    /// sentence — the one thing that surface said which nothing else does.
    private func chipHelp(_ kind: TrayKind) -> String {
        switch kind {
        case .all:
            return "Everything this view holds"
        case .blocks:
            return model.view == .leaving
                ? "Blocks this note deleted, and originals riding a family's countdown"
                : "Blocks archived out of this note — kept, with no clock"
        case .takes:
            return "Takes deleted on their own \u{2014} each on its own "
                + "\(TrashWindow.days) days. They never show in the Library's "
                + "Trash: a take alone is hard to place, so this is where they "
                + "are audited."
        }
    }

    /// The one line under the filter: what THIS view is, and what its verbs
    /// do. Row 89's rule — a meaning line wraps whole, never truncates.
    private var explainerLine: some View {
        Text(tokens.chromeLabel(TrayFilterFace.explainer(model.view, home: home)))
            .font(tokens.small)
            .foregroundStyle(tokens.faint)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// The chosen cell, in render order — blocks, the originals that moved
    /// onto a family's clock, then takes. Each card names its kind, because
    /// under a filter a row can no longer borrow its meaning from a header.
    @ViewBuilder private var cellRows: some View {
        let rows = model.rows
        if rows.isEmpty {
            empty(TrayFilterFace.nothing(
                view: model.view, kind: model.kind, home: home))
        }
        ForEach(rows.blocks, id: \.blockID) { item in
            if model.view == .leaving {
                row(
                    kind: TrayFilterFace.blockKind,
                    blockID: item.blockID, text: item.text,
                    stamp: item.deletedAt, when: "deleted",
                    clock: TrashWindow.daysLeft(item.deletedAt, now: session.now),
                    help: "Puts the block back where it was in this note "
                        + "(a released original that was deleted later has "
                        + "no old place left, and lands at the end)",
                    // Row 3 (her R-Q3): the door the explainer above has
                    // always promised. Same confirm, same act, same copy as
                    // the Library Trash's own block row.
                    deleteNow: TrayPurgeDoor.offered(.block, view: model.view)
                        ? .block(act: { model.requestDeleteNowBlock(item) })
                        : nil
                ) {
                    await model.putBackDeleted(item.blockID)
                }
            } else {
                // ── ARCHIVED (lifecycle row B1) ────────────────────────
                // Kept, forever, no clock: her B2 ruling split archive from
                // the Trash one level up, and U-9 makes that split the
                // panel's own top-level choice.
                row(
                    kind: TrayFilterFace.blockKind,
                    blockID: item.blockID, text: item.text,
                    stamp: item.deletedAt, when: "archived", clock: nil,
                    forever: true,
                    help: "Kept out of the note, with no clock — Put back "
                        + "returns it where it stood",
                    // NEVER a purge door here — this branch IS the archived
                    // view, where `TrayPurgeDoor.offered(.block, view:)` is
                    // false: archived is KEPT, with no clock (her B2 ruling),
                    // so there are no remaining days for a door to skip, and
                    // the block is live. The literal nil, as the stranded
                    // site below writes it (17p batch b ladder round 1,
                    // R1-4): a door built behind a rule that is false by
                    // construction is dead code wearing a help sentence.
                    deleteNow: nil
                ) {
                    await model.putBackArchived(item.blockID)
                }
            }
        }
        // The originals that MOVED here (round 8b): their whole family is in
        // the Trash, so they ride its clock — and they are BLOCKS, so they
        // filter under blocks (figure D's caption), their stranded-clock
        // line unchanged.
        ForEach(rows.stranded, id: \.blockID) { item in
            row(
                kind: TrayFilterFace.originalKind,
                blockID: item.blockID, text: item.text,
                stamp: model.strandedClock(item.blockID), when: "goes",
                clock: model.strandedClock(item.blockID).flatMap {
                    TrashWindow.daysLeft($0, now: session.now)
                },
                note: TrayPath.goesWithItsFamily,
                help: "Put back the blocks it became — or put the "
                    + "original itself back into this note — and it "
                    + "stops counting down",
                // NEVER a purge door here — `TrayPurgeDoor.offered(
                // .strandedOriginal, view:)` is false in both views, which is
                // her R-Q3's own words (*"stranded originals stay without
                // one"*): it rides its FAMILY's clock (round 8b), exactly as
                // the Trash refuses it the same door, and
                // `TrashPurge.deleteNowConfirm` is the belt behind both faces.
                // Written as the literal nil rather than through the rule
                // because a rendered door that could never act is P-2's own
                // defect — the rule's enumeration is what the pin holds.
                deleteNow: nil
            ) {
                await model.putBackOriginal(item.blockID)
            }
        }
        if model.view == .leaving, !rows.blocks.isEmpty, model.deletedTruncated {
            truncation("deleted")
        }
        // 18o U1 (17e P37): the archived view's own marker — its listing is
        // windowed exactly like the two above, and now says so.
        if model.view == .archived, !rows.blocks.isEmpty, model.archivedTruncated {
            truncation("archived")
        }
        ForEach(rows.takes) { take in
            takeRow(take)
        }
        if !rows.takes.isEmpty, model.takesTruncated { truncation("deleted") }
    }

    private func close() {
        if let onClose { onClose() } else { dismiss() }
    }

    // (`takesDisclosure` — the *"▸ N deleted takes"* full-line toggle
    //  (Act 10's row 64, itself a `DisclosureGroup` before that) — RETIRED
    //  at 18d batch 2. Her ruling U-9 makes the takes a FILTER: the count it
    //  carried is the `takes` chip's, visible without opening anything, and
    //  the rows it hid are one click away in a control that names itself.
    //  The help it carried — *"they never show in the Library's Trash: a
    //  take alone is hard to place, so this is where they are audited"* —
    //  rides the chip's own tooltip below.)

    private func takeRow(_ take: Queries.TrayTake) -> some View {
        CalmCard(tokens: tokens) {
            VStack(alignment: .leading, spacing: 4) {
                // The kind label (figure D): what this row IS, and — her A3
                // discipline, moved one line up out of the quiet lead — the
                // block it came out of.
                kindLabel(TrayFilterFace.takeKind(take))
                Text(TrayTakeFace.label(take))
                    .font(tokens.body)
                    .foregroundStyle(take.text.isEmpty ? tokens.muted : tokens.ink)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    // Row 63: the lead truncates; the CLOCK never does.
                    Text(tokens.chromeLabel(TrayTakeFace.lead(take)
                        .joined(separator: " \u{B7} ")))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .lineLimit(1)
                        .stampHelp(TrayTakeFace.leadHelp(take))  // VX-351
                    if let slot = TrayTakeFace.clockSlot(take, now: session.now) {
                        Text(tokens.chromeLabel(slot))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(1)
                            .fixedSize()
                            .layoutPriority(1)
                    }
                    Spacer(minLength: 8)
                    // The purge door, on the ONE surface a take has one (her G5
                    // fourth-sitting addition). It confirms every time — no
                    // don't-ask state exists anywhere in the app, and none may
                    // be added (her round-10 ruling).
                    //
                    // 17p batch b (row 3): the two verbs are ONE cluster now
                    // (`TrayRowVerbs`), shared with the block rows that gained
                    // the same door — the styles, the `fixedSize` rider and the
                    // order are the take row's own, kept byte-for-byte.
                    TrayRowVerbs(
                        tokens: tokens, rowID: take.variantID,
                        putBackHelp: "Puts this take back exactly as it was — its label, its "
                            + "place in the fan and its commits come back with it "
                            + "(a take that was archived when it was deleted comes "
                            + "back archived)",
                        putBack: { await model.putBackTake(take.variantID) },
                        deleteNow: TrayPurgeDoor.offered(.take, view: model.view)
                            ? .take(act: { model.requestDeleteNowTake(take) })
                            : nil)
                }
            }
        }
    }

    /// The card's kind line — the quietest register in the panel, above the
    /// preview (the mockup's `.kind`).
    private func kindLabel(_ text: String) -> some View {
        Text(tokens.chromeLabel(text))
            .font(tokens.small)
            .foregroundStyle(tokens.faint)
            .lineLimit(1)
    }

    private func empty(_ line: String) -> some View {
        Text(tokens.chromeLabel(line))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .padding(.vertical, 2)
    }

    private func truncation(_ what: String) -> some View {
        Text(tokens.chromeLabel(
            "Showing the \(TrayViewModel.window) most recently \(what) — "
            + "older ones aren't listed."))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
    }

    /// One row: the preview on its OWN line, then everything about it.
    /// Read-cheap by construction — a `Text`, never a pane (P3).
    ///
    /// **THE PREVIEW GETS THE LINE** (the post-13l polish round, ledger row 9
    /// — the 13l walk's P-1: *"the tray row's preview is squeezed to about ten
    /// characters"*, `"Nobody warn…"`, `"The sea took t…"`, while the stamp and
    /// the countdown kept their room).
    ///
    /// The mechanism the walk traced: the row was ONE `HStack`, and the
    /// flexible `Text` is what SwiftUI compresses first — so the thing that
    /// identifies the block lost to the metadata beside it, at a panel width
    /// of 420. Her C1 move makes the container NARROWER, not wider (an
    /// inspector column, not a sheet), so a `layoutPriority` alone would only
    /// move the squeeze around. The row stacks instead: the preview owns a
    /// full-width line (up to two), and the stamp, the clock and the label
    /// share the quiet line under it with the verb. Nothing competes.
    ///
    /// **`deleteNow` — 17p batch b, row 3 (her R-Q3).** A row carries the
    /// purge door only where `TrayPurgeDoor` says it may: nil is the answer
    /// for a stranded original (it rides its family's clock) and for every
    /// archived row (kept, no clock — there are no days to skip). Of the
    /// three `row(...)` call sites in `cellRows`, the leaving-block site
    /// consults that rule; the archived and stranded sites, whose answer the
    /// rule fixes at nil, write the literal and cite it (the ladder's R1-4 —
    /// a door built behind a rule that is false by construction is dead
    /// code). This builder only draws what it is handed.
    private func row(
        kind: String,
        blockID: String, text: String?, stamp: String?, when: String,
        clock: Int?, forever: Bool = false, note: String? = nil, help: String,
        deleteNow: TrayRowVerbs.Purge? = nil,
        putBack: @escaping () async -> Void
    ) -> some View {
        // The reveal's mark rides the card's own selected grammar: a long
        // list still answers "which one" (`RecoveryView`'s W10b idiom).
        CalmCard(tokens: tokens, selected: model.revealBlockID == blockID) {
            VStack(alignment: .leading, spacing: 4) {
                // 18d batch 2 (figure D): every card names its kind. Under a
                // filter a row cannot borrow its meaning from the header
                // above it — and there is no header above it any more.
                kindLabel(kind)
                Text(TrayRowPreview.line(text))
                    .font(tokens.body)
                    .foregroundStyle(text?.isEmpty == false ? tokens.ink : tokens.muted)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    // Row 63: the lead truncates; the CLOCK never does.
                    Text(tokens.chromeLabel(TrayRowFace.lead(
                        note: note, stamp: stamp, when: when)
                        .joined(separator: " \u{B7} ")))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .lineLimit(1)
                        .stampHelp(TrayRowFace.leadHelp(stamp: stamp, when: when))  // VX-351
                    if let slot = TrayRowFace.clockSlot(clock: clock, forever: forever) {
                        Text(tokens.chromeLabel(slot))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(1)
                            .fixedSize()
                            .layoutPriority(1)
                    }
                    Spacer(minLength: 8)
                    TrayRowVerbs(
                        tokens: tokens, rowID: blockID, putBackHelp: help,
                        putBack: putBack, deleteNow: deleteNow)
                }
            }
        }
    }
}

/// **A ROW'S TRAILING VERBS — ONE CLUSTER, EVERY ROW** (17p batch b, row 3).
///
/// Before this batch the two row builders each hand-rolled the same buttons:
/// `takeRow` drew Put back + Delete Now, `row(...)` drew Put back alone, with
/// the styles, the help and row 63's `fixedSize` rider written twice. Row 3
/// gives the leaving BLOCK rows the same purge door (her R-Q3), which would
/// have made it three copies of one cluster — the drift class MobileSoul §3
/// names and review focus F-0 checks. So the cluster is one view, and the
/// order (Put back, then the destructive verb) and both styles are the take
/// row's own, kept byte-for-byte.
///
/// **Row 63's rider, preserved:** a VERB never truncates. Both buttons carry
/// `.fixedSize()`; the squeeze belongs to the lead line above them.
struct TrayRowVerbs: View {
    /// The purge door's two halves, together — so a row can never render the
    /// button without the sentence that says what it costs. The init is
    /// PRIVATE (the ladder's R2-2): the two factories below are the only door
    /// in, so "the sentence lives once per kind" is true by construction, not
    /// by a census of call sites.
    struct Purge {
        let help: String
        let act: () -> Void

        private init(help: String, act: @escaping () -> Void) {
            self.help = help
            self.act = act
        }

        /// The purge door for a BLOCK row / a TAKE row — the help sentence
        /// that says what the door costs lives ONCE, here, per kind (17p
        /// batch b ladder round 1, R1-4): the row builders name the kind and
        /// hand over the act, so a third row type cannot mint a third copy
        /// of the sentence (the verb cluster's own de-duplication, one
        /// register down).
        static func block(act: @escaping () -> Void) -> Purge { door("block", act: act) }
        static func take(act: @escaping () -> Void) -> Purge { door("take", act: act) }

        private static func door(_ noun: String, act: @escaping () -> Void) -> Purge {
            Purge(
                help: "Ends this \(noun)'s remaining days now. There is no putting "
                    + "it back afterwards.",
                act: act)
        }
    }

    let tokens: VoiceTokens
    /// The row this cluster belongs to (a block id or a variant id) — the
    /// DEBUG probe's key, and nothing the face reads.
    let rowID: String
    let putBackHelp: String
    let putBack: () async -> Void
    /// nil where `TrayPurgeDoor` says this row carries no purge door.
    let deleteNow: Purge?

    var body: some View {
        HStack(spacing: 8) {
            Button(TrayPath.putBackVerb) { Task { await putBack() } }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary, compact: true))
                // P-8 (R-13u4-5's sweep, 13u4 UNIT S3): a `fixedSize` chrome label
                // states its own line policy, so its IDEAL width can never be a
                // wrapped one (the b6dae25 class's window-sizing hazard).
                // The rider above is the same decision stated in words: a verb
                // never truncates, and now it never wraps either.
                .lineLimit(1)
                .fixedSize()  // a verb never truncates (row 63's rider)
                .help(putBackHelp)
            if let deleteNow {
                Button(RecoveryCopy.deleteNowVerb, role: .destructive, action: deleteNow.act)
                    .buttonStyle(CalmButtonStyle(tokens: tokens, role: .danger, compact: true))
                    .lineLimit(1)
                    .fixedSize()
                    .help(deleteNow.help)
            }
        }
        #if DEBUG
        .onAppear { TrayRowDoorProbe.record(rowID, verbs) }
        #endif
    }

    /// What this cluster draws, in order — the value the DEBUG probe reports
    /// and the one the composition pin reads.
    var verbs: [String] {
        deleteNow == nil
            ? [TrayPath.putBackVerb]
            : [TrayPath.putBackVerb, RecoveryCopy.deleteNowVerb]
    }
}

#if DEBUG
/// **THE TRAY ROW'S DOORS, AS A TEST ORACLE** (17p batch b, row 3 — the
/// `TakesCellChrome` / `TakesArticleDoorProbe` pattern batch a established,
/// and for the same measured reason: a hosted SwiftUI tree reports ONE
/// accessibility element with no children in this test host, and a
/// composition `dump` does not evaluate a `ForEach`'s content closure — so
/// *"which doors did the panel actually draw on THIS row"* is unanswerable
/// any other way).
///
/// It records what a MOUNTED row drew, from the row's own `onAppear`, keyed
/// by the row's id. DEBUG only; the shipping panel carries none of it.
@MainActor
enum TrayRowDoorProbe {
    private(set) static var verbs: [String: [String]] = [:]

    static func reset() { verbs = [:] }

    static func record(_ rowID: String, _ drawn: [String]) { verbs[rowID] = drawn }
}
#endif

/// **THE ROW'S TWO LINES, AS A VALUE** (ledger row 9's layout fix, stated
/// where a pin can hold it): the preview is one thing, and everything that
/// describes it is another. The squeeze the walk met was the two sharing one
/// line box; this is the shape that cannot.
nonisolated enum TrayRowFace {
    /// The quiet line under the preview, in reading order: what the row IS,
    /// when it went, and how long it has. Empty pieces drop out — a row never
    /// wears a separator around nothing.
    ///
    /// **Row 63 (the Act 10 correction round): the line is TWO SLOTS now.**
    /// The walk met "· 30…" and "· k…" at every width in Terminal — the
    /// clock, the one fact the leaving section exists for, was the piece the
    /// layout truncated first, and the archived row's whole promise went with
    /// it. So the truncatable LEAD (what it is · a DATE-ONLY stamp — the
    /// `OriginPeekCopy.stamp` ruling, whose capture is this same failure) and
    /// the CLOCK/promise are separate values; the view gives the clock a slot
    /// the layout may never compress; and `meta` is DERIVED from the pair, so
    /// the pinned value and the rendered pair cannot drift.
    static func lead(note: String?, stamp: String?, when: String) -> [String] {
        var pieces: [String] = []
        if let note, !note.isEmpty { pieces.append(note) }
        if let stamp,
           let display = TrayRowPreview.stampTextDateOnly(stamp, verb: when) {
            pieces.append(display)
        }
        return pieces
    }

    /// VX-351 (the VX-348 run, U4 — her R-VX348-1/3): the lead's hover — its
    /// stamp's whole fact (*Deleted Oct 13, 2026 at 4:02 PM*); the glance
    /// stays date-only (row 63).
    static func leadHelp(stamp: String?, when: String) -> String? {
        TrayRowPreview.stampHelp(stamp, verb: when)
    }

    /// The clock, or the promise of no clock — one of the two, never both
    /// and never neither for a clocked/kept row (13j J1 / round 7).
    static func clockSlot(clock: Int?, forever: Bool) -> String? {
        if let clock { return TrayPath.daysLeftLabel(clock) }
        return forever ? TrayPath.archivedForever : nil
    }

    static func meta(
        note: String?, stamp: String?, when: String, clock: Int?, forever: Bool
    ) -> [String] {
        var pieces = lead(note: note, stamp: stamp, when: when)
        if let slot = clockSlot(clock: clock, forever: forever) { pieces.append(slot) }
        return pieces
    }
}

/// **A DELETED TAKE'S ROW, AS A VALUE** (ledger row 20). Its label, and the
/// quiet line that names its BLOCK — her A3 discipline, which the note-scoped
/// panel owes at the block grain because the panel itself is the note.
nonisolated enum TrayTakeFace {
    /// The take's own label where it has one, else its first line — and the
    /// empty case says **take**, never "block" (the `BlockPastCopy.emptyTake`
    /// lesson: a row in a fan that calls itself a block is the same small
    /// dishonesty this family of surfaces exists to end).
    static func label(_ take: Queries.TrayTake) -> String {
        if let label = take.label, !label.isEmpty { return label }
        let line = TrayRowPreview.line(take.text)
        return line == TrayRowPreview.emptyBlock ? RecoveryCopy.emptyTakeLabel : line
    }

    /// When it went — and, since 18d batch 2, ONLY that.
    ///
    /// **Which block it came out of moved UP into the card's kind label**
    /// (`TrayFilterFace.takeKind`, figure D's *"take · of block 3"*). Her A3
    /// discipline is unchanged and unweakened — a take row still names its
    /// block, through the same `Queries.tocHandle`, the ONE block-naming
    /// rule; it says so on the line that says what the row IS, which is
    /// where the mockup puts it and where a filtered list needs it.
    ///
    /// **Row 63's split survives**: the stamp is date-only and truncatable,
    /// the clock rides its own uncompressible slot beside it.
    static func lead(_ take: Queries.TrayTake) -> [String] {
        guard let stamp = TrayRowPreview.stampTextDateOnly(
            take.deletedAt, verb: "deleted") else { return [] }
        return [stamp]
    }

    /// VX-351: the lead's hover — *Deleted Oct 13, 2026 at 4:02 PM*.
    static func leadHelp(_ take: Queries.TrayTake) -> String? {
        TrayRowPreview.stampHelp(take.deletedAt, verb: "deleted")
    }

    static func clockSlot(_ take: Queries.TrayTake, now: Date) -> String? {
        TrashWindow.daysLeft(take.deletedAt, now: now).map(TrayPath.daysLeftLabel)
    }

    static func meta(_ take: Queries.TrayTake, now: Date) -> [String] {
        var pieces = lead(take)
        if let slot = clockSlot(take, now: now) { pieces.append(slot) }
        return pieces
    }
}

/// **THE TRAY'S PURGE CONFIRM HOST** — the same rule, written down again
/// where the second host is (13l Act 2's finding: *a binding setter must
/// never clear state that an action's continuation will read back*).
///
/// The confirm's value rides into the action closure through `presenting:`,
/// and `confirmPendingPurge(_:)` takes it as a parameter — so no read-back
/// survives for SwiftUI's synchronous dismissal write to beat. Four dead
/// confirm doors were found across the two apps by not doing this; the fifth
/// was the Mac's Delete Now itself.
extension View {
    func trayPurgeConfirmDialog(_ model: TrayViewModel) -> some View {
        confirmationDialog(
            model.pendingPurge?.message ?? "",
            isPresented: Binding(
                get: { model.pendingPurge != nil },
                set: { presented in if !presented { model.cancelPendingPurge() } }),
            titleVisibility: .visible,
            presenting: model.pendingPurge
        ) { confirm in
            Button("Delete for Good", role: .destructive) {
                Task { await model.confirmPendingPurge(confirm) }
            }
            Button("Cancel", role: .cancel) { model.cancelPendingPurge() }
        }
    }
}

// (`TrayRowPreview` moved to `Shared/BlockHistoryFace.swift` at mobile
//  round 2 batch 6a — the phone's Block History rows name takes and
//  originals exactly as these rows name blocks. An address moved; the
//  rule and every string are byte-identical.)
