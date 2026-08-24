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
    /// The Library ⋯ menu's item, and the palette row. It names BOTH halves
    /// of the surface, which is what it holds: the calm Archived section and
    /// the Trash's countdown (13j J1 — her ruled name for the deleted half
    /// is `trashSection` below).
    static let menuLabel = "Archived & Deleted"
    /// The arrow is the shipped copy's own (`\u{2192}`, as the merge
    /// ceremony and the helper already write it) — one voice, not a new one.
    static var surface: String { "Library \u{2192} \(menuLabel)" }

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
    static func emptyTrashConfirm(_ counts: [Queries.TrashItem.Kind: Int]) -> String {
        RecoveryCopy.emptyTrashConfirm(counts)
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
        _ total: Int, synced: Bool, anyFamilyEverSynced: Bool = false
    ) -> String {
        RecoveryCopy.emptyTrashReceipt(
            total, synced: synced, anyFamilyEverSynced: anyFamilyEverSynced)
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
                archivedTruncated = value.count > Self.window
                archived = archivedTruncated ? Array(value.prefix(Self.window)) : value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    func startTrash() async {
        let kinds: Set<Queries.TrashItem.Kind> = kindFilter.map { [$0] }
            ?? Set(Queries.TrashItem.Kind.allCases)
        do {
            for try await value in session.database.observeTrash(
                now: session.now, kinds: kinds, oldestFirst: oldestFirst,
                limit: Self.window + 1
            ) {
                trashTruncated = value.count > Self.window
                trash = trashTruncated ? Array(value.prefix(Self.window)) : value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
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

    /// What the surface is asking her to confirm. Delete Now asks EVERY
    /// time (round 10 — no session-scoped don't-ask exists, deliberately);
    /// Empty Trash asks once, naming the full count by kind (round 8).
    enum PurgeConfirm: Equatable {
        case deleteNow(Queries.TrashItem)
        case emptyTrash(counts: [Queries.TrashItem.Kind: Int])

        var message: String {
            switch self {
            case .deleteNow(let item):
                return RecoveryPath.deleteNowConfirm(item.kind)
            case .emptyTrash(let counts):
                return RecoveryPath.emptyTrashConfirm(counts)
            }
        }
    }

    private(set) var pendingConfirm: PurgeConfirm?

    /// The per-row door: raises the confirm — never acts directly.
    func requestDeleteNow(_ item: Queries.TrashItem) {
        guard item.kind != .preservedOriginal else {
            // A preserved original has no purge door of its own — it rides
            // its family (round 8b). The row renders no Delete Now, so
            // this is a belt, not a face.
            return
        }
        pendingConfirm = .deleteNow(item)
    }

    /// The bulk door: reads the UNWINDOWED counts AT ASK TIME (the listing
    /// is windowed at 500; "everything, always" means everything), then
    /// raises the confirm with the full count by kind.
    func requestEmptyTrash() async {
        lastError = nil
        receipt = nil
        do {
            let now = session.now
            let everything = try await session.database.read { db in
                try Queries.trash(db, now: now)
            }
            var counts: [Queries.TrashItem.Kind: Int] = [:]
            for item in everything { counts[item.kind, default: 0] += 1 }
            if counts.filter({ $0.key != .preservedOriginal }).values.reduce(0, +) == 0 {
                receipt = RecoveryPath.emptyTrashConfirm([:])
                return
            }
            pendingConfirm = .emptyTrash(counts: counts)
        } catch {
            lastError = String(describing: error)
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
            let synced = session.syncConfigured()
            switch confirm {
            case .deleteNow(let item):
                let target = SyncPurgeTarget(table: item.kind.purgeTable, rowID: item.id)
                // R2-M1: the signed-out-with-synced-history population —
                // read the family's truth bit (before the intent lands;
                // the intent write changes no seq rows) so the local
                // wording never claims a cleanup LocalPurge will defer.
                var familySynced = false
                if !synced {
                    familySynced = try await session.database.read { db in
                        try PurgeJanitor.anyFamilyEverSynced(db, targets: [target])
                    }
                }
                try await session.runner.run { ops in
                    _ = try ops.requestPurge([target])
                }
                receipt = RecoveryPath.deleteNowReceipt(
                    item.kind, synced: synced, familyEverSynced: familySynced)
            case .emptyTrash:
                // Re-read at ACT time (a confirm is a pause; the listing is
                // a projection — the R3-1 lesson): everything currently in
                // the Trash, unwindowed, minted in one transaction.
                let now = session.now
                let everything = try await session.database.read { db in
                    try Queries.trash(db, now: now)
                }
                let targets = everything
                    .filter { $0.kind != .preservedOriginal }
                    .map { SyncPurgeTarget(table: $0.kind.purgeTable, rowID: $0.id) }
                // R2-M1: same truth bit, batch-wide — one once-synced
                // family among the targets means the receipt must speak
                // the sign-in road for that part of the batch.
                var anyFamilySynced = false
                if !synced {
                    anyFamilySynced = try await session.database.read { db in
                        try PurgeJanitor.anyFamilyEverSynced(db, targets: targets)
                    }
                }
                try await session.runner.run { ops in
                    _ = try ops.requestPurge(targets)
                }
                receipt = RecoveryPath.emptyTrashReceipt(
                    targets.count, synced: synced, anyFamilyEverSynced: anyFamilySynced)
            }
            // 13j ladder B (B3): on a local-only install the cleanup IS
            // the app's — run it now, so Delete Now means what it says the
            // moment she reads it (never-synced families remove here; a
            // configured chain's janitor owns the road instead).
            await session.sweepLocalPurge()
        } catch let error as OperationError {
            lastError = TrayRefusalCopy.message(for: error)
        } catch {
            lastError = String(describing: error)
        }
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
    @State private var model: RecoveryViewModel

    /// 13j batch 6b (P-1): the Trash surface is the ONE renderer of the two
    /// purge acts — the walk's union names every renderer by construction,
    /// so a door leaking into any note context would fail the walk.
    static let surfaceCapabilities: [CapabilityID] = [.deleteNow, .emptyTrash]

    init(
        session: AppSession, library: LibraryViewModel,
        openPost: @escaping (String) -> Void
    ) {
        self.session = session
        self.library = library
        self.openPost = openPost
        _model = State(initialValue: RecoveryViewModel(session: session))
    }

    var body: some View { list }

    private var list: some View {
        List {
            Section(RecoveryPath.archivedSection) {
                if model.archived.isEmpty {
                    Text("Nothing archived.").foregroundStyle(.secondary)
                }
                ForEach(model.archived, id: \.postID) { item in
                    HStack {
                        title(item)
                        Spacer()
                        Button("Open") { openPost(item.postID) }
                        Button("Unarchive") {
                            Task { await library.unarchive(postID: item.postID) }
                        }
                    }
                }
                if model.archivedTruncated {
                    Text("Showing the \(RecoveryViewModel.window) most recently archived — older ones aren't listed.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Section(RecoveryPath.trashSection) {
                Text(RecoveryPath.windowNote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                controls
                if model.trash.isEmpty {
                    Text("The Trash is empty.").foregroundStyle(.secondary)
                }
                ForEach(model.trash) { item in
                    trashRow(item)
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
                    .foregroundStyle(.red)
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
        .task { await model.startArchived() }
        // Restarts when the filter or the sort changes — both are applied in
        // SQL, so the observation itself is what moves.
        .task(id: model.restartToken) { await model.startTrash() }
    }

    /// Her round-3 ruling's two controls: filter by kind, sort by date —
    /// and, since batch 6b, the Empty Trash door (in-Trash only, forever).
    private var controls: some View {
        HStack(spacing: 12) {
            Picker("Show", selection: Binding(
                get: { model.kindFilter },
                set: { model.kindFilter = $0 })) {
                Text("Everything").tag(Queries.TrashItem.Kind?.none)
                ForEach(Queries.TrashItem.Kind.allCases, id: \.self) { kind in
                    Text(RecoveryPath.kindLabel(kind)).tag(Queries.TrashItem.Kind?.some(kind))
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: 220)
            Toggle("Oldest first", isOn: Binding(
                get: { model.oldestFirst },
                set: { model.oldestFirst = $0 }))
                .toggleStyle(.checkbox)
            Spacer()
            // 13j batch 6b (J1): the bulk purge door — rendered only when
            // the Trash holds something (P-2: a door that cannot act is
            // not rendered); the confirm names the full count by kind.
            if !model.trash.isEmpty {
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

    @ViewBuilder
    private func trashRow(_ item: Queries.TrashItem) -> some View {
        HStack(spacing: 6) {
            Text(item.title ?? TrayRowPreview.line(item.text))
                .lineLimit(1)
            Text(RecoveryPath.rowKind(item.kind))
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
            if let noteTitle = item.noteTitle {
                Text(item.noteIsDeleted
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
            // that cannot act is not rendered).
            if let noteID = item.noteID, !item.noteIsDeleted,
               item.kind != .note, item.kind != .book {
                Button("Open note") { openPost(noteID) }
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
        case .block: return "The block goes back where it was in its note"
        case .take: return "The take comes back in its block, exactly as it was"
        case .preservedOriginal:
            return "Places the original back into its note — it stops counting down"
        }
    }

    private func title(_ item: Queries.TimelineItem) -> some View {
        HStack(spacing: 6) {
            Text(item.displayTitle)
            if let date = item.entryDate {
                Text(date).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
