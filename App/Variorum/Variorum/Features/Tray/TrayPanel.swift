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
    /// The note-menu item, and the panel's own title.
    static let menuLabel = "This Note's Tray"
    /// The context bar's quiet badge — a backspace glyph and a count.
    static let doorGlyph = "\u{232B}"
    /// How the receipts point at the badge. Named as a place in the note's
    /// own chrome, never as a menu path: the badge is the door she will see
    /// while she is standing where the delete happened.
    static let doorPhrase = "the \(doorGlyph) door in the note's bar"
    /// The deleted section's header. **"Deleted", not "Deleted & archived"**
    /// — see `TrayViewModel`'s note: no shipped operation writes
    /// `block.archived_at`, so an "archived" heading would name a state the
    /// product cannot produce.
    static let deletedSection = "Deleted"
    static let originalsSection = "Preserved originals"
    /// The one verb, both sections.
    static let putBackVerb = "Put back"

    static func doorLabel(deleted: Int) -> String { "\(doorGlyph) \(deleted)" }

    /// **The put-back receipts, in ONE place** (13j batch 3): the tray's two
    /// sections and the origin peek all speak them, so three doors onto two
    /// acts cannot describe the same landing three ways.
    ///
    /// The deleted-block half moved with the F2 rider: `restoreBlock` now
    /// flips the placement row this deletion tombstoned, so a block normally
    /// comes back WHERE IT WAS — and the receipt says that instead of
    /// "at the end", which is what it had to say while the op minted fresh.
    static let putBackWhereItWas = "Put back where it was."
    static let putBackAtEnd = "Put back at the end of this note."
    static let putBackBeside = "Put back where it came from."
    /// The block is live again but has nowhere to land (its note is gone).
    /// Unreachable from the tray, which is always open ON a live note —
    /// worded anyway, because a receipt that cannot be produced is still a
    /// receipt a future door could produce.
    static let putBackUnplaced =
        "Put back — but its note is gone, so it's waiting unplaced."

    /// **Where a released original waits, in one phrase** — the string every
    /// ceremony explainer, merge receipt and helper entry uses. It replaces
    /// `RecoveryPath.unplacedBlocks`, which named the room J6 removed; the
    /// arrow grammar is that string's own, so the voice does not change with
    /// the destination. One constant, so eight copy sites cannot drift.
    static var originalsPath: String { "\(menuLabel) \u{2192} \(originalsSection)" }

    /// The same phrase with the door spelled out, for copy that has to teach
    /// the way in rather than merely name the place.
    static var originalsPathWithDoor: String { "\(originalsPath) (\(doorPhrase))" }
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
    /// **13j batch 2 — the VERIFIED finding behind the section's name.**
    /// `block.archived_at` exists in schema v1 and in the model, and the sync
    /// serializer classifies it — but a sweep of `Sources/VariorumCore`
    /// found NO operation that ever writes it, and no `archiveBlock` exists
    /// anywhere in the repo. Block-level archive is unreachable in the
    /// product. So this listing is deleted blocks, and the section says
    /// "Deleted": naming a state nothing can produce is the same defect as
    /// naming a surface that has no door.
    private(set) var originals: [Queries.PreservedOriginal] = []
    private(set) var originalsTruncated = false
    private(set) var statusMessage: String?

    /// The row the caller asked to be shown (the J3-family lineage door's
    /// landing). Consumed by the view for its highlight; `revealMissing`
    /// says the honest thing when the asked-for block is not in either list.
    let revealBlockID: String?

    init(session: AppSession, postID: String, revealBlockID: String? = nil) {
        self.session = session
        self.postID = postID
        self.revealBlockID = revealBlockID
    }

    var isEmpty: Bool { deleted.isEmpty && originals.isEmpty }

    /// True once the listings have loaded and the requested block is in
    /// neither of them — e.g. an original released from a DIFFERENT note
    /// (`last_container_id` names where it was released, and a successor can
    /// since have moved). One quiet line rather than a guess at the cause.
    private(set) var loaded = false
    var revealMissing: Bool {
        guard loaded, let revealBlockID else { return false }
        return !deleted.contains { $0.blockID == revealBlockID }
            && !originals.contains { $0.blockID == revealBlockID }
    }

    func start() async {
        do {
            for try await value in session.database.observe({ [postID] db in
                Snapshot(
                    deleted: try Queries.trayBlocks(db, postID: postID),
                    originals: try Queries.preservedOriginals(
                        db, postID: postID, limit: Self.window + 1))
            }) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            statusMessage = String(describing: error)
        }
    }

    nonisolated struct Snapshot: Equatable, Sendable {
        var deleted: [Queries.TrayItem] = []
        var originals: [Queries.PreservedOriginal] = []
    }

    /// Internal so tests drive the panel deterministically (the
    /// `CommentsPanelModel.adopt` seam).
    func adopt(_ snapshot: Snapshot) {
        deletedTruncated = snapshot.deleted.count > Self.window
        deleted = deletedTruncated
            ? Array(snapshot.deleted.prefix(Self.window)) : snapshot.deleted
        originalsTruncated = snapshot.originals.count > Self.window
        originals = originalsTruncated
            ? Array(snapshot.originals.prefix(Self.window)) : snapshot.originals
        loaded = true
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
        statusMessage = nil
        do {
            let landing = try await session.runner.run { ops in
                try ops.restoreBlock(blockID)
            }
            statusMessage = switch landing {
            case .itsOldPlace: TrayPath.putBackWhereItWas
            case .endOfNote: TrayPath.putBackAtEnd
            case .unplaced: TrayPath.putBackUnplaced
            }
        } catch let error as OperationError {
            statusMessage = TrayRefusalCopy.message(for: error)
        } catch {
            statusMessage = String(describing: error)
        }
    }

    /// A preserved original: `placeBlock` after its last live successor,
    /// through the ONE shared brain the peek also calls (13j batch 3 — two
    /// doors, one act).
    func putBackOriginal(_ blockID: String) async {
        statusMessage = nil
        do {
            statusMessage = try await PreservedOriginPutBack.run(
                session: session, postID: postID, blockID: blockID)
        } catch let error as OperationError {
            statusMessage = TrayRefusalCopy.message(for: error)
        } catch {
            statusMessage = String(describing: error)
        }
    }
}

/// **The preserved original's PUT BACK, in ONE place** (13j batch 3): the
/// tray's originals section and the J3 peek are two doors onto one act, and a
/// second copy of the composition is a second place for the landing rule to
/// drift.
///
/// It is a face-level composition over `placeBlock` — the W-reversibility
/// primitive, exactly as the ceremony's "reversible by re-pointing at A"
/// promises — and NO operation's semantics change for it.
///
/// The landing is re-read HERE, at act time, rather than taken from a
/// listing: a listing is a projection, and an argument read from a projection
/// is read from a snapshot (13c R3-1's lesson, applied at the only place it
/// can bite — the successor could have moved or gone since the panel last
/// rendered). The recorded corner is unchanged: if it moves in the
/// sub-millisecond window between this read and the write, `placeBlock`
/// refuses by name and she retries.
@MainActor
enum PreservedOriginPutBack {
    /// Returns the receipt; refusals throw for the caller to word.
    static func run(session: AppSession, postID: String, blockID: String) async throws -> String {
        let landing = try await session.database.read { db in
            try Queries.preservedOriginals(db, postID: postID)
                .first { $0.blockID == blockID }?.landAfterBlockID
        }
        let insert: Operations.InsertPosition = landing.map { .after($0) } ?? .end
        try await session.runner.run { ops in
            _ = try ops.placeBlock(blockID, in: postID, at: insert)
        }
        return landing == nil ? TrayPath.putBackAtEnd : TrayPath.putBackBeside
    }
}

/// The tray's own refusals, in words. Only ONE case needs saying in this
/// surface's voice — the seal — and it says it as a diagnosis with the way
/// out (the J8 doctrine): the tray still OPENS under a seal, because reading
/// is free; it is putting back that the seal refuses.
nonisolated enum TrayRefusalCopy {
    static let sealed =
        "This note is marked complete — unseal it to put this back."

    static func message(for error: Error) -> String {
        if let error = error as? OperationError, case .lockedPost = error {
            return sealed
        }
        return OpsRefusalCopy.message(for: error)
    }
}

struct TrayPanel: View {
    let session: AppSession
    let postID: String
    @State private var model: TrayViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession, postID: String, revealBlockID: String? = nil,
        model: TrayViewModel? = nil
    ) {
        self.session = session
        self.postID = postID
        _model = State(initialValue: model
            ?? TrayViewModel(session: session, postID: postID, revealBlockID: revealBlockID))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(tokens.chromeLabel(TrayPath.menuLabel))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                Spacer()
                Button("Close") { dismiss() }
            }
            if let status = model.statusMessage {
                Text(status)
                    .font(tokens.small)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }
            if model.revealMissing {
                Text(tokens.chromeLabel(
                    "The block you asked to see isn't in this note's tray."))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
            List {
                Section(tokens.chromeLabel(TrayPath.deletedSection)) {
                    if model.deleted.isEmpty {
                        empty("Nothing deleted from this note.")
                    }
                    ForEach(model.deleted, id: \.blockID) { item in
                        row(
                            blockID: item.blockID, text: item.text,
                            stamp: item.deletedAt, when: "deleted",
                            help: "Puts the block back where it was in this note "
                                + "(a released original that was deleted later has "
                                + "no old place left, and lands at the end)"
                        ) {
                            await model.putBackDeleted(item.blockID)
                        }
                    }
                    if model.deletedTruncated { truncation("deleted") }
                }
                Section(tokens.chromeLabel(TrayPath.originalsSection)) {
                    if model.originals.isEmpty {
                        empty("No originals are waiting here — a divide or a merge "
                            + "that keeps one whole puts it in this section.")
                    }
                    ForEach(model.originals, id: \.blockID) { item in
                        row(
                            blockID: item.blockID, text: item.text,
                            stamp: item.releasedAt, when: "released",
                            help: item.landAfterBlockID == nil
                                ? "Puts the original back at the end of this note"
                                : "Puts the original back beside the blocks it became"
                        ) {
                            await model.putBackOriginal(item.blockID)
                        }
                    }
                    if model.originalsTruncated { truncation("released") }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .padding(12)
        .frame(minWidth: 420, minHeight: 280)
        .background(tokens.surface)
        .task { await model.start() }
    }

    private func empty(_ line: String) -> some View {
        Text(tokens.chromeLabel(line))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
    }

    private func truncation(_ what: String) -> some View {
        Text(tokens.chromeLabel(
            "Showing the \(TrayViewModel.window) most recently \(what) — "
            + "older ones aren't listed."))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
    }

    /// One row: a first-line preview, when it went, and the ONE verb.
    /// Read-cheap by construction — a `Text`, never a pane (P3).
    private func row(
        blockID: String, text: String?, stamp: String?, when: String, help: String,
        putBack: @escaping () async -> Void
    ) -> some View {
        HStack(spacing: 8) {
            Text(TrayRowPreview.line(text))
                .font(tokens.body)
                .foregroundStyle(text?.isEmpty == false ? tokens.ink : tokens.muted)
                .lineLimit(1)
            if let stamp, let display = TrayRowPreview.stampText(stamp, verb: when) {
                Text(tokens.chromeLabel(display))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Button(TrayPath.putBackVerb) { Task { await putBack() } }
                .controlSize(.small)
                .help(help)
        }
        .padding(.vertical, 2)
        // The reveal's mark: a long list still answers "which one"
        // (`RecoveryView`'s own W10b idiom, which this surface inherits).
        .listRowBackground(
            model.revealBlockID == blockID
                ? Color.accentColor.opacity(0.18) : Color.clear)
    }
}

/// The row's two derivations, pure so a pin can hold them without a view.
nonisolated enum TrayRowPreview {
    /// The FIRST LINE only — a multi-paragraph block's tray row must not
    /// grow to the block's height, and its first line is what identifies it
    /// (the `tocHandle` instinct, without borrowing its naming rules: a
    /// tray row is not a heading).
    /// The empty case's words, named so a caller in another scope can tell
    /// it apart and say its OWN noun (13j batch 3: the History face's take
    /// rows read "(empty block)" until the capture caught it).
    static let emptyBlock = "(empty block)"

    static func line(_ text: String?, limit: Int = 90) -> String {
        guard let text, !text.isEmpty else { return emptyBlock }
        let first = text.split(
            separator: "\n", maxSplits: 1, omittingEmptySubsequences: false)[0]
        let trimmed = first.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return emptyBlock }
        return trimmed.count > limit ? String(trimmed.prefix(limit)) + "\u{2026}" : trimmed
    }

    /// "deleted 12 Aug" — the stored canonical stamp, read through the ONE
    /// parser (`DateFormatter.variorumISO8601`), never re-parsed by hand.
    /// A stamp that doesn't parse renders nothing at all rather than raw
    /// ISO text.
    static func stampText(_ stamp: String, verb: String) -> String? {
        guard let date = DateFormatter.variorumISO8601.date(from: stamp) else { return nil }
        return "\(verb) \(date.formatted(date: .abbreviated, time: .shortened))"
    }
}
