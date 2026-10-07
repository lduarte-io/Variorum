//
//  MobileNoteTray.swift
//  VariorumMobile
//
//  **THE PER-NOTE TRAY** (mobile round 2, batch 6b) — the phone's edition of
//  the post-13l polish round's RULED tray (`mobile-round-2.md` §69.3,
//  MobileSoul **PL-14(e)** / **PL-11(a)**), built to that round's design and
//  never to the mid-design it superseded.
//
//  ── HER TWO SECTIONS, AND THE ONE THAT IS DELIBERATELY ABSENT ─────────────
//    · **Archived** — this note's archived blocks: kept, forever, **no
//      clock**. One verb, Put back (`unarchiveBlock`).
//    · **Leaving** — every CLOCKED thing of THIS note: blocks it deleted,
//      originals that have MOVED onto a family's clock, and its deleted
//      TAKES under a **collapsed-by-default** disclosure — each take naming
//      its block (her A3 discipline) and carrying **Put back** and **Delete
//      Now**, confirmed EVERY time.
//    · **NO unclocked-originals section.** Her G5 ruling: *the tray audits
//      what is LEAVING; lineage holds what is KEPT.* An original standing
//      whole beside its successors is not leaving anything, so its home is
//      the Block History face's **came from** region (shipped at batch 6a).
//      A clocked original joins Leaving when its family's clock starts.
//
//  ── WHY A PURGE DOOR IS LEGAL HERE ───────────────────────────────────────
//  13j's round-3 rider put the purge doors *"inside the Trash only — never a
//  door in a note or the editor, ever"*. Her G5 ruling supersedes it IN PART
//  with the rule the polish round records: **purge doors live in TRASH
//  SURFACES — the global Trash and this note-level trash section — and never
//  in the writing flow.** The Leaving section qualifies by construction:
//  every row in it is already deleted and already counting down. That is also
//  what makes batch 6c's declined explainer flip true at last — a deleted
//  TAKE never rows in the global Trash (`TrashScope`, her D1 ruling), so
//  until this section existed the phone had no purge road to name.
//
//  ── WHAT IS SHARED AND WHAT IS THE PHONE'S ───────────────────────────────
//  The reads are core (`Queries.trayBlocks` / `archivedBlocks` /
//  `preservedOriginals` / `originFamilyClocks` / `trayTakes`). Every
//  SENTENCE is `Shared/RecoveryCopy.swift`'s tray vocabulary, which the Mac's
//  panel reads through `TrayPath`'s forwarders — so the two trays cannot
//  describe one 30-day clock two ways. The acts are the shared decision layer
//  (`PreservedOriginPutBack`, `TrashPurge`, `DeletionRefusal`) and the shared
//  message classification (`RecoveryStatus`). What is the phone's own: the
//  ROW SHAPE below, this surface's flush-free read-cheap face, and the door's
//  placement (the blocks chip's sheet — one subject in three states).
//
//  ── P1 / P3 ──────────────────────────────────────────────────────────────
//  Every listing is bounded IN SQL at `window + 1` with a visible truncation
//  marker (the Phase 10 window+probe discipline; the marker is the filterless
//  rooms' shared sentence, since the tray has no filter to narrow). Rows are
//  read-cheap `Text` — nothing in a tray is ever a live editor.
//
//  The observation is HELD, and only while the tray's segment is on screen:
//  `Queries.trayBlocks` and `trayTakes` read `variant`, so a held read
//  re-runs at autosave rate — which costs nothing here because the sheet
//  covers the page while it is up (she is not typing), and the `.task` dies
//  with the segment. That is the same shape its sibling in the same sheet
//  already uses (`MobileBlockListModel.start`, parity D2's routed NIT), and
//  the reason the Block History face made the opposite call: that face's Mac
//  twin stands open BESIDE a live editor, and this one cannot.
//

import Foundation
import GRDB // AsyncValueObservation iteration (member import visibility)
import Observation
import SwiftUI
import VariorumCore

// MARK: - The brain

@MainActor
@Observable
final class MobileNoteTrayModel {
    @ObservationIgnored private let session: AppSession
    @ObservationIgnored let postID: String
    /// What this tray is the tray OF. The phone's Write screen hosts NOTES
    /// only (`MobileShellView`'s `.note` route is its one host; the scraps
    /// area is its own surface), so this is `.post` everywhere today — it is
    /// a parameter because every sentence it feeds already takes the home's
    /// kind (13l row 26's rule: a scraps area is not a note), and hard-coding
    /// the word here is exactly how that rule gets lost.
    @ObservationIgnored let home: ContainerKind
    /// Bounded on purpose (P1) — the phone's rooms' own value, read on a
    /// 393 pt column.
    @ObservationIgnored private let window: Int

    private(set) var archived: [Queries.TrayItem] = []
    private(set) var archivedTruncated = false
    private(set) var deleted: [Queries.TrayItem] = []
    private(set) var deletedTruncated = false
    private(set) var takes: [Queries.TrayTake] = []
    private(set) var takesTruncated = false
    /// The originals that have MOVED onto a family's clock (her round-8b
    /// ruling). An original with a live descendant is not here — it is
    /// lineage's, in Block History ▸ Came from.
    private(set) var stranded: [Queries.PreservedOriginal] = []
    private(set) var strandedTruncated = false
    private(set) var strandedFates: [String: Queries.OriginFamilyFate] = [:]
    private(set) var loaded = false

    /// **A receipt is not a refusal** — the shared classification
    /// (`RecoveryStatus`), so the face renders muted or alarm without any
    /// view re-deriving the class from the words.
    private(set) var status: RecoveryStatus?

    init(session: AppSession, postID: String, home: ContainerKind = .post, window: Int = 200) {
        self.session = session
        self.postID = postID
        self.home = home
        self.window = window
    }

    // MARK: - Copy (the SHARED tray vocabulary; nothing invented here)

    static var archivedSection: String { RecoveryCopy.trayArchivedSection }
    static var leavingSection: String { RecoveryCopy.trayLeavingSection }
    var leavingExplainer: String { RecoveryCopy.trayLeavingExplainer(home) }
    var nothingArchived: String { RecoveryCopy.trayNothingArchived(home) }
    var nothingLeaving: String { RecoveryCopy.trayNothingLeaving(home) }

    /// **The road to this section, in one phrase** — what
    /// `BlockHistoryCopy.deletedRegionExplainer(purgeRoad:)` now ends with
    /// (batch 6b's deliverable 4). It is COMPOSED from the door's own two
    /// words (the chip and the segment), never a third literal, so a re-word
    /// of either lands here for free and the sentence can never point at a
    /// door that has been renamed.
    ///
    /// Phone-voiced deliberately: the Mac's equivalent names *This Note's
    /// Tray*, which is a Mac door — sharing it would be the no-redirect
    /// breach (MobileSoul §4.4) wearing a shared home's clothes.
    static var purgeRoadPhrase: String {
        "open \(roadPhrase(to: .leaving))"
    }

    /// The same road, in the shape a RECEIPT wants ("… you can put it back
    /// from blocks ▸ leaving"). One composition, three callers.
    static var putBackRoadPhrase: String {
        "you can put it back from \(roadPhrase(to: .leaving))"
    }

    /// Where an archived block went, named the same way.
    static var archivedRoadPhrase: String { roadPhrase(to: .archived) }

    /// The door's two words, joined: the chip, then the segment.
    static func roadPhrase(to segment: MobileBlocksSegment) -> String {
        "\(MobileBlockListModel.chipWord) \u{25B8} \(segment.word)"
    }

    /// Is anything on this note's clock? — asked once so the face asks one
    /// question instead of three (`TrayViewModel.nothingIsLeaving`'s shape).
    var nothingIsLeaving: Bool {
        deleted.isEmpty && stranded.isEmpty && takes.isEmpty
    }

    // MARK: - The listing (bounded in SQL, held only while shown)

    nonisolated struct Snapshot: Equatable, Sendable {
        var deleted: [Queries.TrayItem] = []
        var archived: [Queries.TrayItem] = []
        var originals: [Queries.PreservedOriginal] = []
        var strandedFates: [String: Queries.OriginFamilyFate] = [:]
        var takes: [Queries.TrayTake] = []
    }

    func start() async {
        let now = session.now
        let limit = window + 1
        do {
            for try await value in session.database.observe({ [postID] db in
                Snapshot(
                    deleted: try Queries.trayBlocks(
                        db, postID: postID, now: now, limit: limit),
                    archived: try Queries.archivedBlocks(
                        db, postID: postID, limit: limit),
                    originals: try Queries.preservedOriginals(
                        db, postID: postID, limit: limit),
                    // Seeded by THIS note's originals, so the recursion walks
                    // their families and nothing else (the query's own doc).
                    strandedFates: try Queries.originFamilyClocks(
                        db, postID: postID, now: now),
                    takes: try Queries.trayTakes(
                        db, postID: postID, now: now, limit: limit))
            }) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    /// Internal so pins drive the face deterministically (the Mac
    /// `TrayViewModel.adopt` seam, same reason).
    func adopt(_ snapshot: Snapshot) {
        (deleted, deletedTruncated) = TrashListing.windowed(
            snapshot.deleted, window: window)
        (archived, archivedTruncated) = TrashListing.windowed(
            snapshot.archived, window: window)
        (takes, takesTruncated) = TrashListing.windowed(
            snapshot.takes, window: window)
        strandedFates = snapshot.strandedFates
        // Her round-8b split, made where the lists are handed over: an
        // original with a live descendant stays in lineage; one whose family
        // is COUNTING moves into the clock-bearing section where she can see
        // it go; one whose family is GONE appears in neither (13j ladder B,
        // B5) — it rode a visible clock for its 30 days and left exactly when
        // the clock said.
        //
        // **And then it is WINDOWED like the other three** (the 6b cold
        // review's MINOR 1). It is the one listing the batch handed over
        // raw, which meant a note holding 201 counting originals rendered
        // 201 rows and said nothing — the +1 probe row, which exists so a
        // cut can be DETECTED, rendered as content instead. P1 was never
        // breached (the SQL `LIMIT` bounds the read either way); the
        // VISIBLE-truncation half of the Phase 10 discipline was.
        //
        // Honest residual, recorded rather than papered over: the probe
        // row is consumed by this FILTER, so the marker fires when the
        // counting subset itself overflows the window — a note whose
        // `window + 1` originals are mostly non-counting can still have
        // counting ones beyond the SQL cut, unseen and unmarked. Closing
        // that needs the filter pushed into `preservedOriginals`' own SQL,
        // which is `Sources/` work.
        (stranded, strandedTruncated) = TrashListing.windowed(
            snapshot.originals.filter {
                if case .counting = strandedFates[$0.blockID] { return true }
                return false
            },
            window: window)
        loaded = true
    }

    /// The counting family clock for a stranded row (nil for permanent or
    /// gone — the row then renders elsewhere or nowhere, B5).
    func strandedClock(_ blockID: String) -> String? {
        if case .counting(let stamp)? = strandedFates[blockID] { return stamp }
        return nil
    }

    func daysLeft(_ stamp: String?) -> Int? {
        guard let stamp else { return nil }
        return TrashWindow.daysLeft(stamp, now: session.now)
    }

    // MARK: - Put back (one verb, each row's own road)

    /// An ARCHIVED block: `unarchiveBlock` — the stamp is cleared and the
    /// placement this archive released comes back, so the block lands where
    /// it stood. The receipt reads the OP's own answer (`landingReceipt`),
    /// never a guess: a block whose note is gone lands unplaced and says so.
    func putBackArchived(_ blockID: String) async {
        status = nil
        do {
            let landing = try await session.runner.run { ops in
                try ops.unarchiveBlock(blockID)
            }
            report(.receipt(RecoveryCopy.landingReceipt(landing)))
        } catch {
            report(.refusal(Self.refusal(error, act: .putBack)))
        }
    }

    /// A DELETED block: `restoreBlock` — the tombstone flips with its
    /// exact-stamp cascade victims AND the placement the deletion took down,
    /// so it comes back where it was. Same receipt rule.
    func putBackDeleted(_ blockID: String) async {
        status = nil
        do {
            let landing = try await session.runner.run { ops in
                try ops.restoreBlock(blockID)
            }
            report(.receipt(RecoveryCopy.landingReceipt(landing)))
        } catch {
            report(.refusal(Self.refusal(error, act: .putBack)))
        }
    }

    /// A stranded ORIGINAL: `placeBlock` after its last live successor,
    /// through the SHARED act the Mac's tray and the phone's Block History
    /// both call — two platforms' doors onto one act cannot drift on where
    /// the block lands or what the receipt says.
    func putBackOriginal(_ blockID: String) async {
        status = nil
        do {
            report(.receipt(try await PreservedOriginPutBack.run(
                session: session, postID: postID, blockID: blockID)))
        } catch {
            report(.refusal(Self.refusal(error, act: .putBack)))
        }
    }

    /// A deleted TAKE: `restoreVariant` — the recovery-door class (no undo
    /// entry; the door IS the recovery). The receipt reads the op's own
    /// answer, because the restore is an exact flip (#68(b)) and a take that
    /// was archived when it was deleted comes back ARCHIVED, into its block's
    /// archived listing rather than the fan.
    func putBackTake(_ variantID: String) async {
        status = nil
        do {
            let restored = try await session.runner.run { ops in
                try ops.restoreVariant(variantID)
            }
            report(.receipt(RecoveryCopy.takeRestoredReceipt(restored)))
        } catch {
            report(.refusal(Self.refusal(error, act: .putBack)))
        }
    }

    // MARK: - Delete Now, on a take, HERE (her G5 fourth-sitting addition)

    /// What the surface is asking her to confirm — the SHARED type, so this
    /// door and the Trash room's ask the same question in the same words.
    typealias PurgeConfirm = TrashPurge.Confirm

    private(set) var pendingConfirm: PurgeConfirm?

    /// The alert host's binding.
    ///
    /// **THE RULE, named by the property that matters** (batch 4.5b's confirm
    /// BLOCKER): *a binding setter must never clear state that an action's
    /// continuation will read back.* SwiftUI writes `isPresented = false`
    /// synchronously inside tap handling, before an action's `Task` can
    /// resume — so `confirmPendingPurge(_:)` takes the confirm as a
    /// PARAMETER (`presenting:` carries it into the closure) and no read-back
    /// survives for the dismissal to beat.
    var purgeConfirmPresented: Bool {
        get { pendingConfirm != nil }
        set { if !newValue { pendingConfirm = nil } }
    }

    /// The per-row door: raises the confirm, never acts. It confirms EVERY
    /// time — there is no don't-ask state anywhere in the app and none may be
    /// added (her round-10 ruling).
    func requestDeleteNowTake(_ take: Queries.TrayTake) {
        guard let confirm = TrashPurge.deleteNowConfirm(for: trashItem(for: take))
        else { return }
        pendingConfirm = confirm
    }

    func cancelPendingPurge() {
        pendingConfirm = nil
    }

    /// The confirmed act, through the SHARED purge layer: ONE op
    /// (`requestPurge` — the intent write; the row leaves every surface at
    /// once through the read-side fence), then the local sweep, then the
    /// receipt that tells the truth about the NOW/janitor split.
    func confirmPendingPurge(_ confirm: PurgeConfirm) async {
        pendingConfirm = nil
        status = nil
        do {
            report(.receipt(try await TrashPurge.confirm(session: session, confirm)))
        } catch {
            // A PURGE refusal, never a put-back one — the seal's way out
            // differs by act, which is why `Act` is a parameter (A1-18).
            report(.refusal(Self.refusal(error, act: .delete)))
        }
    }

    /// The take, as the shared purge layer's row type. A purge target is a
    /// table and a row id, and a take's are exactly `variant` and its own id
    /// — whichever surface offered the door.
    nonisolated func trashItem(for take: Queries.TrayTake) -> Queries.TrashItem {
        Queries.TrashItem(
            kind: .take, id: take.variantID, deletedAt: take.deletedAt,
            text: take.text, noteID: postID, blockID: take.blockID)
    }

    // MARK: - Status / refusal voice

    private func report(_ status: RecoveryStatus) {
        self.status = status
    }

    /// **The ONE deletion-refusal home, called directly** (A1-18; the 6c cold
    /// review's n5 retired the one-line forwards that used to stand in front
    /// of it). `RecoveryRefusal` — nothing attempted — falls to the shared
    /// fallback, which is why it is never rendered as a receipt.
    static func refusal(_ error: Error, act: DeletionRefusal.Act) -> String {
        guard let error = error as? OperationError else {
            return DeletionRefusal.fallback(error)
        }
        return DeletionRefusal.words(error, act: act)
    }
}

// MARK: - The row faces (pure — composed from SHARED sentences, never new ones)

/// **A TRAY ROW'S QUIET LINE, AS A VALUE** — what the row IS, when it went,
/// and how long it has. Pure, so a pin holds what the row says without
/// rendering it.
///
/// **This is the Mac `TrayRowFace`/`TrayTakeFace`'s phone twin, and it is
/// recorded as a HOIST OWED rather than claimed as a face** (MobileSoul §3;
/// `KnownIssuesAndTechDebt.md`'s forked-brains row is the family). Those two
/// enums are pure rules and belong in `Shared/` beside `DeletedTakeFace`,
/// which batch 6a already moved for exactly this reason — but every road to
/// them is fenced for this batch (`App/Variorum/Variorum/` and
/// `App/Variorum/Shared/` alike), so the phone composes the SAME shared
/// primitives (`TrayRowPreview`, `RecoveryCopy.trayTakeInBlock`,
/// `RecoveryCopy.daysLeftLabel`, `RecoveryCopy.archivedForever`,
/// `Queries.tocHandle`) and a pin asserts the composition rather than the
/// literal — so a drift would have to change a shared sentence to happen.
nonisolated enum MobileTrayRowFace {
    /// The quiet line under a BLOCK row's preview, in reading order.
    /// Empty pieces drop out — a row never wears a separator around nothing.
    static func meta(
        note: String?, stamp: String?, when: String, clock: Int?, forever: Bool
    ) -> [String] {
        var pieces: [String] = []
        if let note, !note.isEmpty { pieces.append(note) }
        if let stamp, let display = TrayRowPreview.stampText(stamp, verb: when) {
            pieces.append(display)
        }
        // The clock, or the promise of no clock — one of the two, never both
        // and never neither (13j J1 / round 7).
        if let clock {
            pieces.append(RecoveryCopy.daysLeftLabel(clock))
        } else if forever {
            pieces.append(RecoveryCopy.archivedForever)
        }
        return pieces
    }

    /// A deleted TAKE's row label: its own label where it has one, else its
    /// first line — and the empty case says **take**, never "block" (the
    /// `BlockPastCopy.emptyTake` lesson).
    static func takeLabel(_ take: Queries.TrayTake) -> String {
        if let label = take.label, !label.isEmpty { return label }
        let line = TrayRowPreview.line(take.text)
        return line == TrayRowPreview.emptyBlock ? RecoveryCopy.emptyTakeLabel : line
    }

    /// A take row NAMES ITS BLOCK (her A3 discipline: *"a deleted take
    /// definitely needs to name both note & block or it's kinda useless"* —
    /// the tray IS the note, so the row owes the block). The handle runs
    /// through `Queries.tocHandle`, the ONE block-naming rule, never a second
    /// one invented here.
    static func takeMeta(_ take: Queries.TrayTake, daysLeft: Int?) -> [String] {
        var pieces = [RecoveryCopy.trayTakeInBlock(
            Queries.tocHandle(name: take.blockName, text: take.blockText))]
        if let stamp = TrayRowPreview.stampText(take.deletedAt, verb: "deleted") {
            pieces.append(stamp)
        }
        if let daysLeft { pieces.append(RecoveryCopy.daysLeftLabel(daysLeft)) }
        return pieces
    }

    static func line(_ pieces: [String]) -> String {
        pieces.joined(separator: "  \u{B7}  ")
    }
}

// MARK: - The face

/// The tray, rendered inside the blocks sheet's `archived` / `leaving`
/// segments — one subject (this note's blocks) in three states.
///
/// **Every act is a VISIBLE BUTTON, never a swipe or a `Menu` row** — the
/// standing rule since batch 4, and its reason is measured rather than
/// aesthetic: a SwiftUI `Menu`'s rows present into a hierarchy whose
/// accessibility tree comes back EMPTY, so a pin cannot drive one, and this
/// app has shipped dead purge doors under green view-model pins before.
struct MobileNoteTraySection: View {
    @Bindable var model: MobileNoteTrayModel
    let tokens: VoiceTokens
    /// Which half this instance renders. The two sections are two segments,
    /// so they never share a screen and cannot blur each other's promise —
    /// her B2 split, one level down.
    let section: Section

    enum Section { case archived, leaving }

    /// The takes fold — **collapsed by default**, her G5 words (*"albeit
    /// maybe not shown by default"*). Session UI state like every other
    /// expansion in the app; a fold is not document semantics.
    @State private var takesShown = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch section {
            case .archived: archivedSection
            case .leaving: leavingSection
            }
            if let status = model.status {
                Text(tokens.chromeLabel(status.text))
                    .font(tokens.small)
                    .foregroundStyle(status.isRefusal ? tokens.alarm : tokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel(status.text)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        // The held observation, alive only while this segment is on screen
        // (the header's P1 note). It delivers the initial read too, so this
        // one call is the whole lifecycle.
        .task { await model.start() }
        // Delete Now's confirm — a REAL `@Bindable` projection (§15's trap
        // (a)) with the act's value riding INTO the action closure
        // (`presenting:` — batch 4.5b's BLOCKER fix, the half that matters).
        .alert(
            model.pendingConfirm?.title ?? "",
            isPresented: $model.purgeConfirmPresented,
            presenting: model.pendingConfirm
        ) { confirm in
            Button(tokens.chromeLabel(confirm.confirmVerb), role: .destructive) {
                let model = model
                Task { await model.confirmPendingPurge(confirm) }
            }
            Button(tokens.chromeLabel("Cancel"), role: .cancel) {
                model.cancelPendingPurge()
            }
        } message: { confirm in
            Text(confirm.message)
        }
    }

    // MARK: Archived — kept, forever, no clock

    @ViewBuilder private var archivedSection: some View {
        header(MobileNoteTrayModel.archivedSection, explainer: nil)
        if model.archived.isEmpty {
            quiet(model.nothingArchived)
        } else {
            ForEach(model.archived, id: \.blockID) { item in
                blockRow(
                    item, when: "archived", clock: nil, forever: true,
                    note: nil, verbSuffix: "archived block"
                ) {
                    await model.putBackArchived(item.blockID)
                }
            }
        }
        if model.archivedTruncated {
            quiet(MobileRoomListing.truncationMarker(shown: model.archived.count))
        }
    }

    // MARK: Leaving — everything of this note on the clock

    @ViewBuilder private var leavingSection: some View {
        header(MobileNoteTrayModel.leavingSection, explainer: model.leavingExplainer)
        if model.nothingIsLeaving {
            quiet(model.nothingLeaving)
        }
        ForEach(model.deleted, id: \.blockID) { item in
            blockRow(
                item, when: "deleted", clock: model.daysLeft(item.deletedAt),
                forever: false, note: nil, verbSuffix: "deleted block"
            ) {
                await model.putBackDeleted(item.blockID)
            }
        }
        // The originals that MOVED here (her round-8b ruling): their whole
        // family is in the Trash, so they ride its clock — and the row wears
        // the reason, because a row that quietly changed meaning where she is
        // not looking is the trust violation that ruling exists against.
        ForEach(model.stranded, id: \.blockID) { item in
            let clockStamp = model.strandedClock(item.blockID)
            strandedRow(item, stamp: clockStamp, clock: model.daysLeft(clockStamp))
        }
        if model.deletedTruncated {
            quiet(MobileRoomListing.truncationMarker(shown: model.deleted.count))
        }
        if model.strandedTruncated {
            quiet(MobileRoomListing.truncationMarker(shown: model.stranded.count))
        }
        if !model.takes.isEmpty { takesDisclosure }
    }

    /// **The takes fold** — collapsed at rest, complete when opened, and
    /// carrying its count either way: a fold that hides its own size is not
    /// an audit.
    @ViewBuilder private var takesDisclosure: some View {
        Button {
            takesShown.toggle()
        } label: {
            Text(tokens.chromeLabel(
                (takesShown ? "\u{25BE} " : "\u{25B8} ")
                + RecoveryCopy.trayTakesDisclosure(model.takes.count)))
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(RecoveryCopy.trayTakesDisclosure(model.takes.count))
        if takesShown {
            ForEach(model.takes) { take in
                takeRow(take)
            }
            if model.takesTruncated {
                quiet(MobileRoomListing.truncationMarker(shown: model.takes.count))
            }
        }
    }

    // MARK: Rows

    private func header(_ title: String, explainer: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(tokens.chromeLabel(title))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .accessibilityLabel(title)
            if let explainer {
                Text(tokens.chromeLabel(explainer))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel(explainer)
            }
        }
    }

    /// **The plain sentence rides as the accessibility label** — the standing
    /// rule (labels stay plain; VoiceOver reads words, not chrome styling),
    /// which the Terminal voice's lowercasing makes load-bearing.
    private func quiet(_ text: String) -> some View {
        Text(tokens.chromeLabel(text))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(text)
    }

    /// One block row: the preview owns its own line, and everything about it
    /// shares the quiet line under it with the verb. (The Mac's ledger row 9
    /// lesson — one `HStack` compresses the flexible `Text` first, and on a
    /// 393 pt column that is the thing that identifies the block.)
    private func blockRow(
        _ item: Queries.TrayItem, when: String, clock: Int?, forever: Bool,
        note: String?, verbSuffix: String, putBack: @escaping () async -> Void
    ) -> some View {
        row(
            preview: TrayRowPreview.line(item.text),
            hasText: item.text?.isEmpty == false,
            meta: MobileTrayRowFace.meta(
                note: note, stamp: item.deletedAt, when: when, clock: clock,
                forever: forever),
            verbLabel: "\(RecoveryCopy.putBackVerb) \(verbSuffix)",
            putBack: putBack)
    }

    private func strandedRow(
        _ item: Queries.PreservedOriginal, stamp: String?, clock: Int?
    ) -> some View {
        row(
            preview: TrayRowPreview.line(item.text),
            hasText: item.text?.isEmpty == false,
            meta: MobileTrayRowFace.meta(
                note: RecoveryCopy.goesWithItsFamily, stamp: stamp, when: "goes",
                clock: clock, forever: false),
            verbLabel: "\(RecoveryCopy.putBackVerb) preserved original",
            putBack: { await model.putBackOriginal(item.blockID) })
    }

    private func row(
        preview: String, hasText: Bool, meta: [String], verbLabel: String,
        putBack: @escaping () async -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(preview)
                .font(tokens.body)
                .foregroundStyle(hasText ? tokens.ink : tokens.muted)
                .lineLimit(2)
            HStack(spacing: 18) {
                Text(tokens.chromeLabel(MobileTrayRowFace.line(meta)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(2)
                Spacer(minLength: 8)
                Button {
                    Task { await putBack() }
                } label: {
                    Text(tokens.chromeLabel(RecoveryCopy.putBackVerb))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(verbLabel)
            }
        }
        .padding(.vertical, 4)
    }

    /// A deleted take's row: its label, the block it came out of, its clock,
    /// and the two doors her fourth sitting placed here.
    private func takeRow(_ take: Queries.TrayTake) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(MobileTrayRowFace.takeLabel(take))
                .font(tokens.body)
                .foregroundStyle(take.text.isEmpty ? tokens.muted : tokens.ink)
                .lineLimit(2)
            Text(tokens.chromeLabel(MobileTrayRowFace.line(
                MobileTrayRowFace.takeMeta(
                    take, daysLeft: model.daysLeft(take.deletedAt)))))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(2)
            HStack(spacing: 18) {
                Button {
                    let model = model
                    Task { await model.putBackTake(take.variantID) }
                } label: {
                    Text(tokens.chromeLabel(RecoveryCopy.putBackVerb))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    "\(RecoveryCopy.putBackVerb) \(RecoveryCopy.rowKind(.take))")
                // The purge door, on the ONE surface a take has one (her G5
                // fourth-sitting addition; the evolved trash-surfaces rule —
                // see the header). It confirms EVERY time.
                Button {
                    model.requestDeleteNowTake(take)
                } label: {
                    Text(tokens.chromeLabel(RecoveryCopy.deleteNowVerb))
                        .font(tokens.small)
                        .foregroundStyle(tokens.alarm)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    "\(RecoveryCopy.deleteNowVerb) \(RecoveryCopy.rowKind(.take))")
                Spacer(minLength: 0)
            }
        }
        .padding(.vertical, 4)
        .padding(.leading, 12)
    }
}
