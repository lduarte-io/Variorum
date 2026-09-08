//
//  RecoveryView.swift
//  Variorum
//
//  The recovery surfaces (Phase 10 Step 8 — brief item 4): archived posts
//  (kept-out-of-view, one click back — the face the Phase 4 closeout
//  promised `unarchiveContainer`) and deleted posts (tombstones, one
//  `restoreContainer` away — the 2026-07-05 author decision's read side).
//
//  ── 13j J6: THE "UNPLACED BLOCKS" SECTION IS GONE ────────────────────────
//  Her report, verbatim: *"what is that cursed table of lost hopes and
//  dreams? if a user ever gets there (which I'm wondering if they should at
//  all tbh) … why are we even offering to auto add deleted blocks to the
//  snippets pool? it doesn't make that much sense to me."*
//
//  The sitting's round-2 ruling removed the listing outright. Released
//  originals surface where she is standing instead: the note's own tray
//  (`TrayPanel`, "Preserved originals") and the lineage door on a successor.
//  `Queries.unplacedBlocks` survives as a debug query, not a room.
//
//  ── 13j J1: AND NOW THE TRASH ────────────────────────────────────────────
//  Her words (2026-08-01): *"some kind of 'true delete' should be added for
//  posts (going to a Trash for 30 days before really deleting), because I
//  already have posts in my library i don't want to have."* The sitting's
//  round-3 rulings shaped it:
//
//  · **Everything deleted rides ONE uniform story** — notes, blocks, takes
//    and books in ONE listing, filterable by kind and sortable by date,
//    because per-row Delete Now is only a real option if she can FIND the
//    row ("maybe you can sort the trash by blocks or note or whatever would
//    be important for that to be a real option").
//  · **Archived stays its own calm section**, with no clock at all: archive
//    is kept-forever, and the two ideas must not blur.
//  · **The window is fixed at 30 days** — no setting; Delete Now is the
//    impatience door.
//
//  ── 13j batch 6b: DELETE NOW & EMPTY TRASH, BUILT ────────────────────────
//  The purge memo's every question closed (rounds 8/8b/9/10) and its DDL
//  pre-authorized, so the doors exist now — IN-TRASH ONLY, forever (her
//  round-3 rider: "never accidental full delete from within a note").
//  Delete Now confirms EVERY time (round 10); Empty Trash confirms once,
//  naming the FULL count by kind (round 8). Both write ONE thing — a purge
//  INTENT (`Operations.requestPurge`) — and the row leaves every surface at
//  once (the read-side fence); the invisible JANITOR (`PurgeJanitor`,
//  riding the sync scheduler) then takes the bytes locally and from the
//  mirror when the horizon says every device has seen the deletion. The
//  receipts say exactly that split (the J8 bar).
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

/// **The ONE place the recovery surface's user-facing path is spelled**
/// (13f W10a/W10b). Her sitting question was a FINDABILITY finding — the
/// ceremony told her a block "stays whole on the original" and never said
/// where the original goes — so copy elsewhere in the app now names this
/// door. Every name here is read by the door that renders it (the Library
/// menu item, the palette row, this view's section header) as well as by
/// the copy that points at it, so the sentence and the label cannot drift
/// apart: rename one and the other follows.
///
/// It is deliberately NOT the word "Recovery": `SidebarSelection.recovery`
/// is the internal case name, and no surface has ever shown it — copy that
/// named it would send her looking for a door that does not exist.
nonisolated enum RecoveryPath {
    /// **THE SURFACE IS THE TRASH NOW, PLAINLY** (the post-13l polish round,
    /// ledger rows 7–8 — her B1/B2 rulings). It used to name both halves,
    /// because it held both: *"Archived & Deleted"*. Her direction split
    /// them — *"archived should be a different item on the left (like where
    /// library is, but it says archived)… separating archive and trash more
    /// makes sense — archive is available forever and maybe still valuable
    /// even if you don't want it in your current library"* — so Archived is
    /// its own sidebar destination (`ArchivedView`) and what is left here is
    /// the 30-day clock and nothing else.
    ///
    /// The name comes from the shared home rather than being re-typed, for
    /// this enum's founding reason: copy elsewhere promises the surface by
    /// name, and one string is what keeps the sentence and the label the same.
    static let menuLabel = RecoveryCopy.trashSection
    /// The arrow is the shipped copy's own (`\u{2192}`, as the merge
    /// ceremony and the helper already write it) — one voice, not a new one.
    /// The Trash's door lives in the Library's masthead (the trash icon her
    /// B1 ruling put where the ⋯ menu was), so the path still reads through
    /// the Library.
    static var surface: String { "Library \u{2192} \(menuLabel)" }
    /// The OTHER destination, named once: the sidebar item that holds
    /// archived notes. Its own sentence-and-label rule, same as above.
    static let archivedSurface = RecoveryCopy.archivedSection

    /// **The Trash** (13j J1, her word). One listing over every deleted
    /// thing, on the 30-day clock.
    ///
    /// **Round 2 batch 4 (mobile): the SEMANTIC half of this vocabulary now
    /// lives in `Shared/RecoveryCopy.swift`** and these are forwarders. The
    /// reason is this enum's own: copy elsewhere promises the surface by
    /// name and would drift — and that argument does not stop at the
    /// platform boundary, now that the phone has a Trash too. Renaming here
    /// still works; renaming in the shared home reaches both platforms.
    static let trashSection = RecoveryCopy.trashSection
    /// The other half: kept forever, no clock, deliberately calm.
    static let archivedSection = RecoveryCopy.archivedSection
    /// The one verb in the Trash, whatever kind the row is.
    static let putBackVerb = RecoveryCopy.putBackVerb

    /// How the Trash explains itself in one line — the promise stated where
    /// she can read it, because a countdown with no sentence is a threat.
    static let windowNote = RecoveryCopy.windowNote

    /// The kind filter's words.
    static func kindLabel(_ kind: Queries.TrashItem.Kind) -> String {
        RecoveryCopy.kindLabel(kind)
    }

    /// What ONE row calls itself, in the singular.
    static func rowKind(_ kind: Queries.TrashItem.Kind) -> String {
        RecoveryCopy.rowKind(kind)
    }

    /// The stranded original's own line (her round-8b ruling — the same
    /// sentence the note's tray shows, from the tray's one home).
    static var goesWithItsFamily: String { TrayPath.goesWithItsFamily }

    /// **The stranded-ancestor run's fold label** (the post-13l polish round,
    /// ledger row 30 — her refinement on the ratified G7 nesting). It carries
    /// the COUNT so the fold never hides its own size, and it says what the
    /// run IS, because "3 more" under a deleted block would be a riddle.
    static func strandedAncestorsDisclosure(_ count: Int) -> String {
        count == 1
            ? "1 original set aside by this block's lineage"
            : "\(count) originals set aside by this block's lineage"
    }

    // MARK: The purge doors (13j batch 6b — J1's second half, built)

    /// The per-row impatience door (her round-3 rider: in-Trash only,
    /// never a note context; round 10: confirms EVERY time).
    static let deleteNowVerb = RecoveryCopy.deleteNowVerb
    static let emptyTrashVerb = RecoveryCopy.emptyTrashVerb

    /// Delete Now's confirm, per row — destructive, unrecoverable, asked
    /// every time by her ruling.
    static func deleteNowConfirm(_ kind: Queries.TrashItem.Kind) -> String {
        RecoveryCopy.deleteNowConfirm(kind)
    }

    /// Empty Trash's confirm NAMES THE FULL COUNT BY KIND (her round-8
    /// ruling: "everything, always — the confirm names the full count").
    /// Preserved originals are named when they ride: they are the round-8b
    /// passengers, never separately purged.
    /// (Batch 6's rider: `versions` names the saved moments among the notes.)
    static func emptyTrashConfirm(
        _ counts: [Queries.TrashItem.Kind: Int], versions: Int = 0
    ) -> String {
        RecoveryCopy.emptyTrashConfirm(counts, versions: versions)
    }

    /// The receipts tell the truth about NOW vs the janitor (the J8 bar):
    /// the row left every surface the moment the intent was written; the
    /// bytes follow once every device on the account has seen the deletion
    /// (the horizon — the memo's rule; she never waits on it).
    ///
    /// `synced` (13j ladder B, B3 — her round-11 ruling: receipts true for
    /// BOTH populations): with no sync chain configured there are no
    /// "synced devices" to catch up, and the app's OWN local cleanup takes
    /// the bytes — never-synced things right away.
    ///
    /// `familyEverSynced` (R2-M1, 13j ladder B round 2 — the THIRD
    /// population: signed OUT, with synced history): a once-synced family
    /// is exactly what `LocalPurge` defers forever, so the local-cleanup
    /// sentence would be indefinitely false for it. The truth bit is
    /// `PurgeJanitor.anyFamilyEverSynced`, read per-target by the model.
    static func deleteNowReceipt(
        _ kind: Queries.TrashItem.Kind, synced: Bool, familyEverSynced: Bool = false
    ) -> String {
        RecoveryCopy.deleteNowReceipt(
            kind, synced: synced, familyEverSynced: familyEverSynced)
    }

    static func emptyTrashReceipt(
        _ total: Int, synced: Bool, anyFamilyEverSynced: Bool = false,
        versions: Int = 0
    ) -> String {
        RecoveryCopy.emptyTrashReceipt(
            total, synced: synced, anyFamilyEverSynced: anyFamilyEverSynced,
            versions: versions)
    }
}

@MainActor
@Observable
final class RecoveryViewModel {
    @ObservationIgnored private let session: AppSession

    /// The bounded window (review round 1, MINOR 3); +1 probe so the
    /// truncation markers never false-positive (round 2 NIT).
    nonisolated static let window = 500

    private(set) var archived: [Queries.TimelineItem] = []
    private(set) var archivedTruncated = false
    /// 13j J1: ONE listing over every deleted thing (notes · blocks · takes ·
    /// books · stranded originals), replacing the separate "Recently Deleted"
    /// and "Deleted books" sections.
    private(set) var trash: [Queries.TrashItem] = []
    private(set) var trashTruncated = false
    /// **IS THE TRASH ITSELF EMPTY — not this filtered view of it** (the
    /// post-13l polish round, ledger row 2; her A2 ruling on the 13l walk's
    /// P-5(b)).
    ///
    /// `trash` is the FILTERED listing (the kind filter is applied in SQL, as
    /// it must be — a window applied before a filter would window the wrong
    /// set), so `!trash.isEmpty` answers *"does this view show anything"* and
    /// the surface was using it to answer *"does the Trash hold anything"*.
    /// Two consequences she met: an empty **Notes** view said "The Trash is
    /// empty" while blocks sat in it, and **Empty Trash…** — a door over the
    /// WHOLE Trash — vanished with the filtered rows.
    ///
    /// It is a second, deliberately tiny observation rather than a read
    /// riding the first: the filtered observation only re-emits when the
    /// FILTERED set changes, so anything deleted or purged in another kind
    /// would have left this stale — which is the same class of bug one layer
    /// down. `limit: 1` is all the question needs, and the Trash is a
    /// summoned surface, never a keystroke road (the `poolHomes` argument,
    /// one property up).
    private(set) var trashIsEmptyUnfiltered = true
    private(set) var lastError: String?
    /// A successful Put back's own words (the tray's receipts, from their one
    /// home) — kept apart from `lastError` so a success is never rendered in
    /// the red slot.
    private(set) var receipt: String?

    /// The filter and the sort — her round-3 ruling's two controls. Changing
    /// either restarts the observation, because both are applied IN SQL
    /// (a window applied before a filter would filter the first N of the
    /// wrong set — `observeReading`'s own lesson).
    var kindFilter: Queries.TrashItem.Kind? {
        didSet { if kindFilter != oldValue { restartToken &+= 1 } }
    }
    var oldestFirst = false {
        didSet { if oldestFirst != oldValue { restartToken &+= 1 } }
    }
    /// Bumped whenever the query's shape changes; the view's `.task(id:)`
    /// restarts on it.
    private(set) var restartToken: UInt64 = 0

    init(session: AppSession) {
        self.session = session
    }

    func startArchived() async {
        do {
            for try await value in session.database.observeArchivedPosts(
                limit: Self.window + 1
            ) {
                (archived, archivedTruncated) = TrashListing.windowed(
                    value, window: Self.window)
            }
        } catch is CancellationError {
        } catch {
            // A1-MINOR-2 (13l Act 1): a raw dump on an observation starter.
            lastError = DeletionRefusal.fallback(error)
        }
    }

    /// **The listing's kinds come from `TrashScope`** (the post-13l polish
    /// round, ledger row 11 — her D1 revision: *"takes should never appear in
    /// trash or archived alone… a take alone is so small"*). It used to ask
    /// for `Kind.allCases`, which is the enum's business rather than the
    /// surface's; one decision now answers for both platforms.
    func startTrash() async {
        let kinds = TrashScope.kinds(filter: kindFilter)
        do {
            for try await value in session.database.observeTrash(
                now: session.now, kinds: kinds, oldestFirst: oldestFirst,
                limit: Self.window + 1
            ) {
                (trash, trashTruncated) = TrashListing.windowed(
                    value, window: Self.window)
                await refreshPoolHomes()
            }
        } catch is CancellationError {
        } catch {
            lastError = DeletionRefusal.fallback(error)
        }
    }

    /// Ledger row 2: the UNFILTERED truth, live. One row is the whole
    /// question, and this observation never restarts — no filter or sort
    /// touches it, which is exactly why it can answer for the Trash as a
    /// whole while `startTrash` answers for the view.
    func startTrashTotal() async {
        do {
            for try await value in session.database.observeTrash(
                now: session.now, kinds: TrashScope.listedKinds,
                oldestFirst: false, limit: 1
            ) {
                trashIsEmptyUnfiltered = value.isEmpty
            }
        } catch is CancellationError {
        } catch {
            // A failure here must never HIDE the door — the ask-time read
            // (`TrashPurge.emptyTrashConfirm`) is the authority on what
            // Empty Trash takes, and it says so honestly when there is
            // nothing. Erring open costs one honest "nothing to delete".
            trashIsEmptyUnfiltered = false
        }
    }

    /// Tests drive this listing the `adopt` way.
    func adoptTrashTotalIsEmpty(_ empty: Bool) {
        trashIsEmptyUnfiltered = empty
    }

    // MARK: A scrap's home is a POOL, and the surface says so (13l, §8b's
    // pool/scraps honesty check)

    /// The live pools, by id. **Why the surface holds this at all:** a block
    /// or take deleted out of the SCRAPS area carries `last_container_id`
    /// pointing at a `kind='pool'` container, and `Queries.trash` names that
    /// home through `DisplayTitle.note` — the wrong display brain. A pool has
    /// no `entry_date`, so a nameless one reads *"Untitled"* here while every
    /// other surface shows the day it was created (13k K2, her ruling:
    /// *"i think pools can show their created day"*). The row's own door was
    /// wrong the same way: it said **Open note** and routed `.post`, opening a
    /// pool as though it were a note.
    ///
    /// It is read on the FACE rather than added to the query deliberately —
    /// this batch's fence keeps `Sources/` closed, and the fix does not need
    /// it: pools are structurally few (the Blocks area creates ONE and reuses
    /// it), the read is `deleted_at IS NULL`-bounded, and it rides the Trash's
    /// own observation, which is a summoned surface, never a keystroke road.
    /// *(What a face CANNOT reach is recorded rather than half-fixed: the
    /// shared put-back RECEIPTS — "Put back at the end of this note", "its
    /// note is gone" — still say "note" for a scrap, because the landing
    /// would have to report its container's kind for them to know better.)*
    private(set) var poolHomes: [String: Container] = [:]

    private func refreshPoolHomes() async {
        guard trash.contains(where: { $0.noteID != nil }) else {
            poolHomes = [:]
            return
        }
        do {
            let pools = try await session.database.read { db in try Queries.pools(db) }
            poolHomes = Dictionary(uniqueKeysWithValues: pools.map { ($0.id, $0) })
        } catch {
            poolHomes = [:]  // the row simply keeps the note wording
        }
    }

    /// Tests drive the pool read directly, the `adopt` way — the listing is
    /// adopted rather than observed there, so nothing would refresh it.
    func loadPoolHomesForTests() async {
        await refreshPoolHomes()
    }

    /// True when this row came out of the scraps area rather than a note.
    func homeIsPool(_ item: Queries.TrashItem) -> Bool {
        item.noteID.map { poolHomes[$0] != nil } ?? false
    }

    /// What the row calls the thing it came out of — each kind through its
    /// OWN display brain (13k K2's rule, which the Trash had never been
    /// told about).
    func homeTitle(_ item: Queries.TrashItem) -> String? {
        guard let noteID = item.noteID else { return nil }
        if let pool = poolHomes[noteID] {
            return DisplayTitle.pool(title: pool.title, createdAt: pool.createdAt)
        }
        return item.noteTitle
    }

    /// Internal so tests drive listings deterministically.
    func adopt(archived: [Queries.TimelineItem], trash: [Queries.TrashItem]) {
        self.archived = archived
        self.trash = trash
    }

    /// **"N days left"** for a row, read against the session's clock.
    func daysLeft(_ item: Queries.TrashItem) -> Int? {
        TrashWindow.daysLeft(item.deletedAt, now: session.now)
    }

    // MARK: The purge doors (13j batch 6b)

    /// What the surface is asking her to confirm. **The type is the SHARED
    /// one now** (13l Act 2's hoist — `TrashPurge.Confirm`); this alias is
    /// what keeps 13j's pins riding unmodified, the 3C parity pattern. Her
    /// rulings are stated at the shared home: Delete Now asks EVERY time
    /// (round 10 — no session-scoped don't-ask exists, deliberately), Empty
    /// Trash asks once naming the full count by kind (round 8).
    typealias PurgeConfirm = TrashPurge.Confirm

    private(set) var pendingConfirm: PurgeConfirm?

    /// The per-row door: raises the confirm — never acts directly. The
    /// original-rides-its-family belt (round 8b) is the shared rule's.
    func requestDeleteNow(_ item: Queries.TrashItem) {
        // The ladder's LR1-4: the door names what it leaves behind. The count
        // comes from the listing she is reading, which is the same listing
        // showing those moments grouped under this note.
        guard let confirm = TrashPurge.deleteNowConfirm(
            for: item, savedVersions: TrashGrouping.savedVersions(of: item, in: trash))
        else { return }
        pendingConfirm = confirm
    }

    /// The bulk door: the shared ask-time read (UNWINDOWED counts — the
    /// listing is windowed at 500 and "everything, always" means
    /// everything), then the confirm with the full count by kind. An empty
    /// Trash says so quietly instead of confirming nothing.
    func requestEmptyTrash() async {
        lastError = nil
        receipt = nil
        do {
            guard let confirm = try await TrashPurge.emptyTrashConfirm(session: session)
            else {
                receipt = RecoveryPath.emptyTrashConfirm([:])
                return
            }
            pendingConfirm = confirm
        } catch {
            // A1-MINOR-2 (13l Act 1): this was a raw `String(describing:)`
            // dump, on the most consequence-laden act on the surface.
            lastError = DeletionRefusal.fallback(error)
        }
    }

    func cancelPendingPurge() {
        pendingConfirm = nil
    }

    /// The confirmed act: ONE op (`requestPurge` — the intent write; rows
    /// leave every surface at once via the read-side fence), and the
    /// receipt says the NOW/janitor split honestly. The janitor rides the
    /// next sync round — the intent's own outbox row triggers one.
    ///
    /// **The confirm is PASSED IN, never read back** (13l Act 2 — the rule
    /// is written out at `View.purgeConfirmDialog`). The shipped version
    /// opened `guard let confirm = pendingConfirm else { return }`, and the
    /// dialog's own dismissal had already nilled it inside the same turn, so
    /// this method returned without doing anything every single time.
    func confirmPendingPurge(_ confirm: PurgeConfirm) async {
        pendingConfirm = nil
        lastError = nil
        receipt = nil
        do {
            receipt = try await TrashPurge.confirm(session: session, confirm)
            forgetLocalMemories(of: confirm)
        } catch let error as OperationError {
            lastError = TrayRefusalCopy.message(for: error)
        } catch {
            // A1-MINOR-2 (13l Act 1): the other raw dump on this surface.
            lastError = DeletionRefusal.fallback(error)
        }
    }

    /// **The one production occasion where a note's per-note VIEW STATE
    /// should die** (18d ladder round 2, MINOR-3 — traced under J43 rather
    /// than assumed). Not `deleteContainer`: a deleted note is in the Trash
    /// and Put back must find her caret and her remembered lengths exactly
    /// where she left them. The point of no return is the PURGE, and this is
    /// its Mac door. Local-only keys, so the eviction is local too — the act
    /// itself stays the shared one, untouched.
    ///
    /// **Delete Now only, and deliberately.** The id is in hand there. Empty
    /// Trash's targets are re-read INSIDE the shared act at act time (its own
    /// rule — a confirm is a pause, the listing is a projection) and are not
    /// returned, so covering it would mean a fourth read racing the act's
    /// third to decide what to forget. Those keys are the accepted,
    /// arithmetic-bounded leak the KnownIssues row names (~40 bytes a key;
    /// `defaults delete` ends it), not a silent gap.
    private func forgetLocalMemories(of confirm: PurgeConfirm) {
        guard case .deleteNow(let item, _) = confirm,
              item.kind == .note, !item.isVersion
        else { return }
        // One call, every per-note memory — the router's door is the list.
        session.commandRouter.forgetCurrentBlock(for: item.id)
    }

    /// **Put back — one verb, each kind's own road** (13j J1). Every road
    /// already existed; what was missing was a place to stand where all four
    /// are offered together.
    ///
    /// **THE ACT IS NOW THE SHARED ONE** (`TrashPutBack` — batch 4.5b's hoist
    /// of §49's MAJOR). The phone's Trash shipped a near-verbatim copy of
    /// this model, and it had already drifted here in its first week: the
    /// phone read `restoreBlock`'s LANDING and told her where the block went,
    /// while this road wrote `_ = try ops.restoreBlock(…)` and discarded the
    /// answer — so Put back landed **silently on the Mac** even though this
    /// view renders `receipt` right beside `lastError`. Two recovery surfaces
    /// answering *"where did it go?"* two ways is precisely what M-C forbids,
    /// and no amount of shared WORDS could have stopped it, because the
    /// divergence was in the decision about which word to say.
    ///
    /// The Mac keeps its own VOICE for refusals (`TrayRefusalCopy`) — a face,
    /// not a decision.
    func putBack(_ item: Queries.TrashItem) async {
        lastError = nil
        receipt = nil
        do {
            receipt = try await TrashPutBack.run(session: session, item: item)
        } catch let error as OperationError {
            lastError = TrayRefusalCopy.message(for: error)
        } catch {
            // Includes `RecoveryRefusal` — a preserved original with no note.
            lastError = DeletionRefusal.fallback(error)
        }
    }
}

// The Trash-row → purge-root table mapping MOVED to
// `Shared/RecoveryCopy.swift` at round 2 batch 4 (mobile). It used to live
// here "beside its only renderer", promising that "the phone's future Trash
// face … will carry its own twin" — which is the six-brains drift class
// stated as a plan. The phone's Trash face exists now, and there is ONE
// mapping.

/// **THE PURGE CONFIRM'S HOST — ONE PLACE, AND THE RULE LIVES WITH IT**
/// (13l Act 2, ledger item 2 — her live report: *"clicking Delete Now in the
/// Trash produced NO confirmation and NO effect"*).
///
/// **THE RULE, and it names the property that matters rather than a shape:**
/// *a binding setter must never clear state that an action's continuation
/// will read back.*
///
/// SwiftUI dismisses a confirmation dialog by writing `isPresented = false`
/// **synchronously, inside the button's own click handling**, while an
/// action's `Task { … }` cannot resume until that turn yields. The shipped
/// host's setter called `cancelPendingPurge()` — nilling `pendingConfirm` —
/// and `confirmPendingPurge()` opened by reading `pendingConfirm` back, so
/// its `guard` always returned: **the dialog presented, she pressed Delete
/// for Good, and nothing was purged — no intent, no receipt, the row still
/// listed.** Both purge doors ride this one host, so true delete was
/// unreachable from the UI entirely.
///
/// Two mechanism facts, MEASURED on macOS 26 in the test host rather than
/// reasoned about (the pin below drives all of them):
/// - The dialog **presents perfectly**, including from inside a `List` row,
///   and including over a computed `Binding(get:set:)` — the title argument
///   reads `pendingConfirm` during `body`, which registers the observation
///   dependency. The long-recorded presentation hypothesis is dead.
/// - A real click on the `_NSAlertPanel`'s button runs this closure and
///   SwiftUI's write-back in ONE turn; the action's `Task` resumes after.
///
/// The fix is therefore not a different binding shape: **the act's value
/// rides into the action closure** (`presenting:`) and
/// `confirmPendingPurge(_:)` takes it as a parameter, so no read-back
/// survives for any setter to beat. The phone's five hosts were corrected the
/// same way at mobile round 2's batch 4.5b; this was the Mac's fifth.
///
/// It is a modifier rather than four lines inline so the rule has somewhere
/// to be written down, and so the pin can drive the SHIPPING wiring (the
/// surface builds its own `@State` model, which a test cannot reach).
extension View {
    func purgeConfirmDialog(_ model: RecoveryViewModel) -> some View {
        confirmationDialog(
            model.pendingConfirm?.message ?? "",
            isPresented: Binding(
                get: { model.pendingConfirm != nil },
                set: { presented in if !presented { model.cancelPendingPurge() } }),
            titleVisibility: .visible,
            presenting: model.pendingConfirm
        ) { confirm in
            Button("Delete for Good", role: .destructive) {
                Task { await model.confirmPendingPurge(confirm) }
            }
            Button("Cancel", role: .cancel) { model.cancelPendingPurge() }
        }
    }
}

struct RecoveryView: View {
    let session: AppSession
    let library: LibraryViewModel
    var openPost: (String) -> Void
    /// 13l (§8b): the scraps area's own route, so a scrap's row never opens
    /// its pool as a note. nil falls back to `openPost` — the pre-13l
    /// behaviour, for any host that has no pool route.
    var openPool: ((String) -> Void)?
    @State private var model: RecoveryViewModel
    /// Ledger row 30: which deletions' stranded-ancestor runs she has folded
    /// away. COLLAPSED-set rather than expanded-set, deliberately: her ruling
    /// is *"not collapsed by default"*, and the default must not depend on
    /// anything having been seeded.
    @State private var collapsedAncestors: Set<String> = []

    /// 13j batch 6b (P-1): the Trash surface is the ONE renderer of the two
    /// purge acts — the walk's union names every renderer by construction,
    /// so a door leaking into any note context would fail the walk.
    static let surfaceCapabilities: [CapabilityID] = [.deleteNow, .emptyTrash]

    /// **Is the bulk purge door on screen?** (the post-13l polish round,
    /// ledger row 2.) Named rather than written inline so a pin can drive the
    /// DECISION the view makes, not a property standing beside it — the
    /// shipped expression was `!model.trash.isEmpty`, which asked about the
    /// FILTERED view, and a door over the whole Trash vanished with a kind
    /// filter that happened to match nothing.
    static func showsEmptyTrashDoor(_ model: RecoveryViewModel) -> Bool {
        !model.trashIsEmptyUnfiltered
    }

    init(
        session: AppSession, library: LibraryViewModel,
        openPost: @escaping (String) -> Void,
        openPool: ((String) -> Void)? = nil
    ) {
        self.session = session
        self.library = library
        self.openPost = openPost
        self.openPool = openPool
        _model = State(initialValue: RecoveryViewModel(session: session))
    }

    var body: some View { list }

    /// **THE LISTING'S SHAPE** (the post-13l polish round, ledger rows 3 + 22
    /// — A3's naming folded into G7's grouping, which is the same fix twice:
    /// a row must name what it came out of, and a note's rows say it once
    /// together rather than each on its own line). The decision is
    /// `TrashGrouping`'s; this renders it.
    private var entries: [TrashGrouping.Entry] { TrashGrouping.entries(model.trash) }

    private var list: some View {
        List {
            // Ledger row 8: the Archived half MOVED to its own sidebar
            // surface (`ArchivedView`) at her B2 direction — *"separating
            // archive and trash more makes sense"*. What is left here is the
            // clock, which is what "Trash" means.
            Section(RecoveryPath.trashSection) {
                Text(RecoveryPath.windowNote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                controls
                if model.trash.isEmpty {
                    // Ledger row 2: an empty VIEW is not an empty Trash, and
                    // the sentence now knows the difference.
                    Text(RecoveryCopy.trashEmptyLine(
                        filteredBy: model.kindFilter,
                        holdsOtherKinds: !model.trashIsEmptyUnfiltered))
                        .foregroundStyle(.secondary)
                }
                // The ladder's LR1-10: identified by the store's ids, never by
                // position — a Put back or a Delete Now shifts everything
                // below it, and an index would call each of those a new row.
                ForEach(entries) { entry in
                    switch entry {
                    case .row(let row): plainRow(row)
                    case .group(let group): groupRows(group)
                    }
                }
                if model.trashTruncated {
                    Text("Showing the \(RecoveryViewModel.window) most recent — older ones aren't listed.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let error = model.lastError ?? library.lastError {
                Text(error)
                    .font(.caption)
                    .alarmVoice()
                    .textSelection(.enabled)
                    .padding(4)
            } else if let receipt = model.receipt {
                Text(receipt)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
        // Restarts when the filter or the sort changes — both are applied in
        // SQL, so the observation itself is what moves.
        .task(id: model.restartToken) { await model.startTrash() }
        // Ledger row 2: the unfiltered truth, on its own observation, which
        // deliberately does NOT restart with the filter.
        .task { await model.startTrashTotal() }
    }

    /// A row with nobody to gather under — it keeps its own "from ‹note›".
    @ViewBuilder
    private func plainRow(_ row: TrashGrouping.Row) -> some View {
        trashRow(row.item, namesItsHome: true)
        nestedRows(row, indent: 16)
    }

    /// One note's rows under one name. When the note itself is in the Trash
    /// its OWN row is the header — the group is literally the note and what
    /// went with it (her G7 words: *"a more visible UI for 'your ancestors
    /// die with you'"*, one grain up).
    @ViewBuilder
    private func groupRows(_ group: TrashGrouping.Group) -> some View {
        if let noteRow = group.noteRow {
            trashRow(noteRow, namesItsHome: false)
        } else if let first = group.rows.first, let title = model.homeTitle(first.item) {
            Text("from \(title)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        ForEach(group.rows, id: \.item.id) { row in
            trashRow(row.item, namesItsHome: false)
                .padding(.leading, 16)
            nestedRows(row, indent: 32)
        }
    }

    /// Ledger row 22's tenth-sitting extension: the ancestors a deletion
    /// stranded, shown UNDER the block that stranded them.
    ///
    /// **…AND THEY FOLD** (ledger row 30, her mid-round refinement on the
    /// ratified shape): *"I think the ancestors should be collapsible with a
    /// dropdown arrow style toggle or something like that optionally (not
    /// collapsed by default)."* So the run is a `DisclosureGroup` that starts
    /// OPEN — which is the whole point of the nesting she asked for (*"going to
    /// trash shows you what you just deleted"*) — and closes at will. The label
    /// carries the COUNT either way, because a fold that hides its own size is
    /// not an audit (the tray's takes disclosure, same rule).
    ///
    /// Expansion is session UI state, keyed by the anchor row's id, so folding
    /// one deletion's ancestors never folds another's.
    @ViewBuilder
    private func nestedRows(_ row: TrashGrouping.Row, indent: CGFloat) -> some View {
        if !row.nested.isEmpty {
            DisclosureGroup(isExpanded: Binding(
                get: { !collapsedAncestors.contains(row.item.id) },
                set: { open in
                    if open { collapsedAncestors.remove(row.item.id) }
                    else { collapsedAncestors.insert(row.item.id) }
                })
            ) {
                ForEach(row.nested, id: \.id) { original in
                    trashRow(original, namesItsHome: false)
                        .padding(.leading, indent)
                }
            } label: {
                Text(RecoveryPath.strandedAncestorsDisclosure(row.nested.count))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.leading, indent)
        }
    }

    /// Her round-3 ruling's two controls: filter by kind, sort by date —
    /// and, since batch 6b, the Empty Trash door (in-Trash only, forever).
    private var controls: some View {
        HStack(spacing: 12) {
            Picker("Show", selection: Binding(
                get: { model.kindFilter },
                set: { model.kindFilter = $0 })) {
                Text("Everything").tag(Queries.TrashItem.Kind?.none)
                // Ledger row 11 (D1): the rows the Trash lists, from the ONE
                // decision — so the picker can never offer a kind the listing
                // no longer holds (a Takes filter over a takeless listing is
                // the "The Trash is empty" lie one layer up, rebuilt).
                ForEach(TrashScope.filterKinds, id: \.self) { kind in
                    Text(RecoveryPath.kindLabel(kind)).tag(Queries.TrashItem.Kind?.some(kind))
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: 220)
            // Ledger row 2 (her A2 ruling): the FILTERS-APPLIED chip. It
            // stands whenever the listing is narrowed — not only when the
            // narrowed result is empty — so "the Trash is empty" can never be
            // read off a view she forgot she had filtered; and it clears the
            // filter, so the signal is also the door out (P-2).
            if let kind = model.kindFilter {
                Button(RecoveryCopy.filterAppliedChip(kind)) {
                    model.kindFilter = nil
                }
                .controlSize(.small)
                .help(RecoveryCopy.filterAppliedHelp)
            }
            Toggle("Oldest first", isOn: Binding(
                get: { model.oldestFirst },
                set: { model.oldestFirst = $0 }))
                .toggleStyle(.checkbox)
            Spacer()
            // 13j batch 6b (J1): the bulk purge door — rendered only when
            // the Trash holds something (P-2: a door that cannot act is
            // not rendered); the confirm names the full count by kind.
            //
            // **Ledger row 2, the visibility read.** This was
            // `!model.trash.isEmpty` — the FILTERED listing — so a kind
            // filter with no matches hid a door that acts on the WHOLE
            // Trash. What Empty Trash TAKES is untouched here (that is G6,
            // batch 2's); this decides only whether it is on screen, and it
            // now asks the question the door is actually about.
            if Self.showsEmptyTrashDoor(model) {
                Button(RecoveryPath.emptyTrashVerb) {
                    Task { await model.requestEmptyTrash() }
                }
                .controlSize(.small)
                .help("Everything in the Trash goes for good — the confirm names the full count")
            }
        }
        .font(.caption)
        .purgeConfirmDialog(model)
    }

    /// `namesItsHome` (ledger rows 3 + 22): a row inside a note's group is
    /// already named by the group's header, and repeating "from ‹note›" on
    /// every line is the clutter G7 exists to remove. A standalone row keeps
    /// it — the naming never disappears, it just moves up one line.
    @ViewBuilder
    private func trashRow(
        _ item: Queries.TrashItem, namesItsHome: Bool = true
    ) -> some View {
        HStack(spacing: 6) {
            Text(item.title ?? TrayRowPreview.line(item.text))
                .lineLimit(1)
            // Ledger row 23 (FOUND-ITEM 1): a saved version is a note-kind
            // row, and calling it "note" is the one thing that would make the
            // group unreadable — the header IS a note, and so would every row
            // under it be.
            // LR2-4's one rule, one home (batch 6a): `RecoveryCopy.rowKind(_:)`
            // is this exact ternary, shared, so the phone's accessibility
            // labels and this display line cannot drift.
            Text(RecoveryCopy.rowKind(item))
                .font(.caption)
                .foregroundStyle(.secondary)
            if item.kind == .preservedOriginal {
                Text(RecoveryPath.goesWithItsFamily)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            // "from ‹note›" — the context her round-5 statement asked for,
            // with the honest addition when that note is in the Trash too.
            // 13l (§8b): the NAME comes from the home's own display brain,
            // so a scrap says what the scraps area is actually called.
            if namesItsHome, let noteTitle = model.homeTitle(item) {
                Text(item.isVersion
                     ? VersionsPath.trashRowOf(noteTitle)
                     : item.noteIsDeleted
                     ? "from \(noteTitle) (also in the Trash)"
                     : "from \(noteTitle)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
            if let display = TrayRowPreview.stampText(item.deletedAt, verb: "deleted") {
                Text(display)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            if let days = model.daysLeft(item) {
                Text(TrayPath.daysLeftLabel(days))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            // The open-there door, only where the note is live (P-2: a door
            // that cannot act is not rendered). 13l (§8b): a scrap's home is
            // the SCRAPS AREA — it says so, and it routes there, instead of
            // opening a pool as though it were a note.
            if let noteID = item.noteID, !item.noteIsDeleted,
               item.kind != .note, item.kind != .book {
                let pool = model.homeIsPool(item)
                // Item 17's ruled vocabulary: the scrap area speaks as
                // "snippets" in every UI string (the K5 precedent).
                Button(pool ? "Open snippets" : "Open note") {
                    if pool, let openPool {
                        openPool(noteID)
                    } else {
                        openPost(noteID)
                    }
                }
                .controlSize(.small)
            }
            Button(RecoveryPath.putBackVerb) {
                Task { await model.putBack(item) }
            }
            .controlSize(.small)
            .help(putBackHelp(item))
            // 13j batch 6b (J1 — her rider): the per-row impatience door.
            // IN-TRASH ONLY, and never on a preserved original (it rides
            // its family, round 8b — its row says so already). Confirms
            // EVERY time (round 10).
            if item.kind != .preservedOriginal {
                Button(RecoveryPath.deleteNowVerb, role: .destructive) {
                    model.requestDeleteNow(item)
                }
                .controlSize(.small)
                .help("Skips the rest of the \(TrashWindow.days) days — asked to confirm every time")
            }
        }
    }

    private func putBackHelp(_ item: Queries.TrashItem) -> String {
        switch item.kind {
        case .note: return "The note comes back with its blocks, its tags and its books"
        case .book: return "The book comes back whole — chapters and membership included"
        // 13l (§8b): note-agnostic on purpose — a block or take can have come
        // out of the SCRAPS area, and the help was calling that pool a note.
        case .block: return "The block goes back where it was"
        case .take: return "The take comes back in its block, exactly as it was"
        case .snippetGroup:
            return "The group comes back with its snippets"
        case .preservedOriginal:
            return "Places the original back where it came from — it stops counting down"
        }
    }

    // The archived rows' `title(_:)` builder LEFT with them (ledger row 8) —
    // `ArchivedView` renders that listing now, in its own room.
}
