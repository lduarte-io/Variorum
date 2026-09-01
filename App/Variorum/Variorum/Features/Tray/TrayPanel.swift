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

    /// **The tray's three sections** (the post-13l polish round, ledger rows
    /// 9 and 20 — her C1 *"preserved originals separated from deleted"* and
    /// her G5 leaving section). The names are SEMANTIC, so they live in the
    /// shared home and the phone's batch-6 tray inherits them.
    ///
    /// *(The single `"Deleted & archived"` header these two replace held a
    /// forever-list and a countdown under one name — the same blur her B2
    /// ruling split one level up, inside one note.)*
    static let archivedSection = RecoveryCopy.trayArchivedSection
    static let leavingSection = RecoveryCopy.trayLeavingSection
    static let leavingExplainer = RecoveryCopy.trayLeavingExplainer
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
    }

    var isEmpty: Bool {
        deleted.isEmpty && archived.isEmpty && stranded.isEmpty && takes.isEmpty
    }

    /// Is anything on this note's clock? — the leaving section's own emptiness,
    /// named so the face asks one question instead of three.
    var nothingIsLeaving: Bool {
        deleted.isEmpty && stranded.isEmpty && takes.isEmpty
    }

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
        archived = Array(snapshot.archived.prefix(Self.window))
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
    /// The takes fold — **collapsed by default**, her G5 words (*"albeit
    /// maybe not shown by default"*). Session UI state like every other
    /// expansion in the app; a fold is not document semantics.
    @State private var takesShown = false
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

    /// **The Act 10 item 1 rebuild.** Her screenshot showed the SECOND
    /// section's header clipped to a sliver under a divider — the traced
    /// class is the `List` section header itself: a plain macOS List
    /// measures headers at a fixed height, and this panel's Leaving header
    /// carries a title AND a multi-line explainer. The rebuild retires the
    /// List for a ScrollView of calm cards (the W8-2 mockup grammar), where
    /// headers are ordinary stacked views that cannot be clipped by a
    /// header-height measurement — the mechanism dies by construction
    /// (`TrayPanelShapeTests` pins the List's absence and the composition).
    ///
    /// Ordering (her "badly ordered / organized", judged in place under the
    /// granted latitude): **LEAVING first** — what is counting down is what
    /// she opened the tray for — then the takes fold, then ARCHIVED (kept
    /// forever, no urgency, reads calmly below).
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
                Text(tokens.chromeLabel(RecoveryCopy.trayRevealKeptInLineage(home)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    // ── LEAVING (her G5 ruling) ────────────────────────────
                    // The complete per-note pre-purge audit: blocks, takes,
                    // and the originals that have MOVED onto a family's
                    // clock.
                    CalmSectionHeader(
                        tokens: tokens, title: TrayPath.leavingSection,
                        detail: RecoveryCopy.trayLeavingExplainer(home))
                    if model.nothingIsLeaving {
                        empty(RecoveryCopy.trayNothingLeaving(home))
                    }
                    ForEach(model.deleted, id: \.blockID) { item in
                        row(
                            blockID: item.blockID, text: item.text,
                            stamp: item.deletedAt, when: "deleted",
                            clock: TrashWindow.daysLeft(item.deletedAt, now: session.now),
                            help: "Puts the block back where it was in this note "
                                + "(a released original that was deleted later has "
                                + "no old place left, and lands at the end)"
                        ) {
                            await model.putBackDeleted(item.blockID)
                        }
                    }
                    // The originals that MOVED here (round 8b): their whole
                    // family is in the Trash, so they ride its clock.
                    ForEach(model.stranded, id: \.blockID) { item in
                        row(
                            blockID: item.blockID, text: item.text,
                            stamp: model.strandedClock(item.blockID), when: "goes",
                            clock: model.strandedClock(item.blockID).flatMap {
                                TrashWindow.daysLeft($0, now: session.now)
                            },
                            note: TrayPath.goesWithItsFamily,
                            help: "Put back the blocks it became — or put the "
                                + "original itself back into this note — and it "
                                + "stops counting down"
                        ) {
                            await model.putBackOriginal(item.blockID)
                        }
                    }
                    if model.deletedTruncated { truncation("deleted") }
                    if !model.takes.isEmpty { takesDisclosure }
                    // ── ARCHIVED (lifecycle row B1) ────────────────────────
                    // Kept, forever, no clock, under its own header: her B2
                    // ruling split archive from the Trash one level up for
                    // exactly this reason, and the pair blurs the same way
                    // inside a note.
                    CalmSectionHeader(tokens: tokens, title: TrayPath.archivedSection)
                        .padding(.top, 8)
                    if model.archived.isEmpty {
                        empty(RecoveryCopy.trayNothingArchived(home))
                    }
                    ForEach(model.archived, id: \.blockID) { item in
                        row(
                            blockID: item.blockID, text: item.text,
                            stamp: item.deletedAt, when: "archived", clock: nil,
                            forever: true,
                            help: "Kept out of the note, with no clock — Put back "
                                + "returns it where it stood"
                        ) {
                            await model.putBackArchived(item.blockID)
                        }
                    }
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

    private func close() {
        if let onClose { onClose() } else { dismiss() }
    }

    /// **The takes fold** (her G5 ruling): collapsed at rest, complete when
    /// opened, and carrying its count either way. Each row names its BLOCK
    /// (A3's discipline — the note is the panel, so the row owes the block),
    /// and carries the two doors her fourth sitting placed here: **Put back**
    /// and **Delete Now**.
    @ViewBuilder private var takesDisclosure: some View {
        // Row 64 (the correction round): the WHOLE line is the toggle. The
        // DisclosureGroup it replaces toggled only on its chevron — a click
        // on the label did nothing (C-7's generous targets; walked).
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { takesShown.toggle() }
        } label: {
            HStack(spacing: 6) {
                Text(tokens.chromeLabel(takesShown ? "\u{25BE}" : "\u{25B8}"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                Text(tokens.chromeLabel(RecoveryCopy.trayTakesDisclosure(model.takes.count)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Takes deleted on their own — each on its own "
            + "\(TrashWindow.days) days. They never show in the Library's Trash: "
            + "a take alone is hard to place, so this is where they are audited.")
        if takesShown {
            ForEach(model.takes) { take in
                takeRow(take)
            }
            if model.takesTruncated { truncation("deleted") }
        }
    }

    private func takeRow(_ take: Queries.TrayTake) -> some View {
        CalmCard(tokens: tokens) {
            VStack(alignment: .leading, spacing: 4) {
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
                    if let slot = TrayTakeFace.clockSlot(take, now: session.now) {
                        Text(tokens.chromeLabel(slot))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(1)
                            .fixedSize()
                            .layoutPriority(1)
                    }
                    Spacer(minLength: 8)
                    Button(TrayPath.putBackVerb) {
                        Task { await model.putBackTake(take.variantID) }
                    }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary, compact: true))
                    .fixedSize()
                    .help("Puts this take back exactly as it was — its label, its "
                        + "place in the fan and its savepoints come back with it "
                        + "(a take that was archived when it was deleted comes "
                        + "back archived)")
                    // The purge door, on the ONE surface a take has one (her G5
                    // fourth-sitting addition). It confirms every time — no
                    // don't-ask state exists anywhere in the app, and none may
                    // be added (her round-10 ruling).
                    //
                    // Row 63's rider (the post-fix walk): a VERB never
                    // truncates — the walk met "Delete…" on a destructive
                    // door; the squeeze belongs to the lead, so both buttons
                    // keep their natural size.
                    Button(RecoveryCopy.deleteNowVerb, role: .destructive) {
                        model.requestDeleteNowTake(take)
                    }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, role: .danger, compact: true))
                    .fixedSize()
                    .help("Ends this take's remaining days now. There is no putting "
                        + "it back afterwards.")
                }
            }
        }
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
    private func row(
        blockID: String, text: String?, stamp: String?, when: String,
        clock: Int?, forever: Bool = false, note: String? = nil, help: String,
        putBack: @escaping () async -> Void
    ) -> some View {
        // The reveal's mark rides the card's own selected grammar: a long
        // list still answers "which one" (`RecoveryView`'s W10b idiom).
        CalmCard(tokens: tokens, selected: model.revealBlockID == blockID) {
            VStack(alignment: .leading, spacing: 4) {
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
                    if let slot = TrayRowFace.clockSlot(clock: clock, forever: forever) {
                        Text(tokens.chromeLabel(slot))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(1)
                            .fixedSize()
                            .layoutPriority(1)
                    }
                    Spacer(minLength: 8)
                    Button(TrayPath.putBackVerb) { Task { await putBack() } }
                        .buttonStyle(CalmButtonStyle(
                            tokens: tokens, role: .primary, compact: true))
                        .fixedSize()  // a verb never truncates (row 63's rider)
                        .help(help)
                }
            }
        }
    }
}

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

    /// Which block it came out of, when it went, and how long it has. The
    /// block's handle runs through `Queries.tocHandle` — the ONE block-naming
    /// rule (its explicit name, else its first sentence, derived at read time
    /// and never stored) — rather than a second rule invented here.
    ///
    /// **Row 63: the same two-slot split as `TrayRowFace`** — the walk found
    /// this row's stamp AND clock both gone behind the block handle. The
    /// stamp is date-only; the clock rides its own uncompressible slot.
    static func lead(_ take: Queries.TrayTake) -> [String] {
        var pieces = [RecoveryCopy.trayTakeInBlock(
            Queries.tocHandle(name: take.blockName, text: take.blockText))]
        if let stamp = TrayRowPreview.stampTextDateOnly(take.deletedAt, verb: "deleted") {
            pieces.append(stamp)
        }
        return pieces
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
