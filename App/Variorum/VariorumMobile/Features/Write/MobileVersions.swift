//
//  MobileVersions.swift
//  VariorumMobile
//
//  **NOTE ▸ VERSIONS — the phone's fourth place** (round 2, batch 6c;
//  MobileSoul **PL-14(f)**, `mobile-round-2.md` §69.6).
//
//  The five-places map is the design's north star: everything a user ever
//  had is in exactly ONE of — where you left it · **Archive** · **the
//  Trash** · **this note's VERSIONS** · **this block's HISTORY**. Batch 6a
//  built the fifth; this builds the fourth. Until now the phone had **no
//  Versions face at all** while all three of its operations were already
//  core (`saveNoteVersion` / `restoreNoteVersion` / `promoteNoteVersion`)
//  and the born-archived classifier had been hiding versions from every
//  phone listing by construction — so her saved moments existed on the
//  phone and were unreachable from it.
//
//  ── THE SHAPE, AND WHAT IS PROVISIONAL ABOUT IT ──────────────────────────
//
//  Built to the proposal's DRAWN shape (`mobile-archive-trash-design/`),
//  **PROVISIONAL on its Q5 and Q9**:
//
//  · **Q5 — the door is the note ⋯ sheet**, which gains `Save a Version`
//    and `Versions…` beside Undo · Redo · Delete Note…. The design record's
//    finding 2: the Mac teaches the two sizes of moment with two chords
//    (⌘S = this take's, ⌘⇧S = this note's) and the phone has no chord
//    culture (PL-11's own words), so the teaching moves to the two ⋯ menus —
//    block ⋯ = Commit Take + Block History…, note ⋯ = Save a Version +
//    Versions…. The masthead's chip row was NOT an option: it already wraps
//    five chips and its crowding is flagged PROVISIONAL for her.
//    **THE BLOCK HALF OF THAT SENTENCE IS 6c's, AND BATCH 9 ENDED IT** —
//    her ⋯ letter moved `Block History…` off the block ⋯ onto each live
//    take card's own ⋯ (`MobileTakesBrowserController.historyTitle`), so
//    the *write a moment / see the moments* pair now survives at exactly
//    ONE grain: this one. `MobileBlockMenu`'s header carries the whole
//    reasoning; the note kept its shape.
//  · **Q9 — a row's tap is READ**, with Restore · Promote · Delete on the
//    MOMENT rather than on the row. Four verbs do not fit a phone row, and
//    the Mac's answer — read a moment BESIDE the note in a side panel — is
//    exactly the thing the phone cannot have (the design record's §5.1).
//    So the phone COVERS: the moment reader replaces the listing on this
//    same pushed screen, with a `‹ Versions` door back, which is the
//    proposal's own drawn path line.
//
//  **EVERY SENTENCE ABOUT THE MACHINERY COMES FROM
//  `Shared/VersionsCopy.swift`.** The Mac and the phone must not describe one
//  machinery two ways — that file's own header says the phone owes a face and
//  *"when it builds one it must not re-write the sentences"*.
//
//  **FOUR phone-voiced strings exist, and they are enumerated, not counted**
//  (corrected at the 6c fix wave, cold-review m2 — this header and the batch
//  record both said "the one gap", and there were more):
//
//  · `MobileVersionsModel.noVersions` — the RE-VOICE. `VersionsPath.empty`
//    names ⌘⇧S and a chord is a platform fact (the Block History twin met
//    the identical case with `noSavepoints`), so the phone says the shared
//    sentence over the shared VERB and a phone door — never a Mac chord,
//    which would be the no-redirect breach (MobileSoul §4.4).
//  · `MobileNoteActionsSheet.saveRowDetail` and `.versionsRowDetail` — the
//    two ⋯ rows' detail subtitles, a FACE fact the shared file has no home
//    for (an iOS sheet row has a subtitle; a Mac menu item does not).
//    `VersionsPath.saveDetail` is the durable answer and is on the next
//    Shared-touching batch's list.
//  · `MobileVersionsView.backToListing` — the reader's `‹ Versions` door,
//    composed from `VersionsPath.name` and a navigation glyph.
//
//  All four are held clear of the shared sentences by
//  `theVersionsVocabularyIsSharedAndEveryPhoneVoicedLineIsListed`.
//
//  **The acts are the SHARED decision layer** (`Shared/VersionActs.swift`):
//  flush-first is not this face's to remember, the receipts are not this
//  face's to invent, and the refusals come from the family's one voice.
//
//  **P1:** the listing is a note's own version count — never corpus-shaped
//  — read on OPEN and after every verb rather than held. Deliberate, and the
//  Block History twin's own reason: a held observation over `container`
//  re-runs at autosave rate, which the Mac accepts because its pane sits
//  beside a live editor and the phone's does not (the phone stands its
//  editor down under a covering surface).
//

import Foundation
import SwiftUI
import VariorumCore

// MARK: - The model

@MainActor
@Observable
final class MobileVersionsModel {
    @ObservationIgnored private let session: AppSession
    @ObservationIgnored let postID: String
    /// **Bounded on purpose (P1), the two rooms' twin.** The cold review's
    /// m3: this was the one new phone listing reading UNBOUNDED, and
    /// *"versions are hand-saved so there are few"* is exactly the
    /// true-today that 13w's automated rotation un-makes
    /// (`notes/plans/whole-note-history-brief.md`). `Queries.noteVersions`
    /// already carried its `limit`; nothing here asked for it.
    @ObservationIgnored private let window: Int

    private(set) var versions: [Queries.NoteVersionItem] = []
    /// The window+probe's answer: there are more moments than are listed.
    private(set) var truncated = false
    /// The moment being READ (Q9's shape) — nil is the listing.
    private(set) var reading: Queries.NoteVersionItem?
    /// The moment's own blocks, read when it is opened. A version is sealed
    /// at birth, so this is read-only by construction, never an editor (P3).
    private(set) var readingBlocks: [String] = []

    private(set) var status: RecoveryStatus?
    /// Restore's confirm — her ratified #80(d): *"i like restore having a
    /// confirm"*. Held as the pending SUBJECT so the alert can carry it into
    /// its action closure (`presenting:`) rather than read it back after
    /// SwiftUI's dismissal has cleared it — batch 4.5b's BLOCKER, one rule.
    var pendingRestore: Queries.NoteVersionItem?
    /// Delete's confirm — the Trash rider (a moment goes to the Trash for
    /// its 30 days, `VersionActs.delete`'s own ratified road).
    var pendingDelete: Queries.NoteVersionItem?

    init(session: AppSession, postID: String, window: Int = 200) {
        self.session = session
        self.postID = postID
        self.window = window
    }

    // MARK: The listing

    /// **Windowed with a probe row, and the marker is VISIBLE** — the Phase
    /// 10 discipline the Archive and Trash rooms already keep, through the
    /// same `TrashListing.windowed` brain rather than a second count.
    func load() async {
        do {
            let limit = window + 1
            let rows = try await session.database.read { [postID] db in
                try Queries.noteVersions(db, of: postID, limit: limit)
            }
            (versions, truncated) = TrashListing.windowed(rows, window: window)
        } catch {
            status = .refusal(VersionActs.words(error))
        }
    }

    // MARK: Read a moment (Q9 — the phone covers, never peeks)

    func read(_ item: Queries.NoteVersionItem) async {
        reading = item
        readingBlocks = []
        do {
            readingBlocks = try await session.database.read { db in
                // The moment's own slots, in reading order — the ordinary
                // read-time rule (`renderPost`), never a second projection.
                // A gap slot (`text == nil`) is rendered as nothing rather
                // than crashing, exactly as every other read-side surface
                // tolerates one (SyncSpec §5).
                try Queries.renderPost(db, containerID: item.postID)
                    .compactMap(\.text)
            }
        } catch {
            // **A FAILED READ LANDS ON THE LISTING, never in an empty reader
            // wearing three live verbs** (the cold review's n6). `reading`
            // is set BEFORE the read so the cover appears immediately; if
            // the read then refuses, leaving it set would put Restore,
            // Promote and Delete on a moment whose words she never saw —
            // three acts over an unread subject. The refusal is spoken on
            // the listing instead, which is where she can act on it.
            closeReader()
            status = .refusal(VersionActs.words(error))
        }
    }

    func closeReader() {
        reading = nil
        readingBlocks = []
    }

    // MARK: The three verbs

    /// **RESTORE — confirmed** (#80(d), ratified). The op saves the moment
    /// of NOW inside its own transaction and `VersionActs` flushes first, so
    /// the promise the confirm makes is the one the store keeps.
    func confirmRestore(_ item: Queries.NoteVersionItem) async {
        pendingRestore = nil
        status = nil
        do {
            let receipt = try await VersionActs.restore(
                session: session, postID: postID, versionID: item.postID)
            status = .receipt(receipt)
            closeReader()
            await load()
        } catch {
            status = .refusal(VersionActs.words(error))
        }
    }

    /// **PROMOTE — fast, NO confirm** (#80(c), ratified: *"promote having no
    /// confirm"*). It deletes nothing: the moment becomes a note of its own
    /// and leaves this list.
    func promote(_ item: Queries.NoteVersionItem) async {
        status = nil
        do {
            let receipt = try await VersionActs.promote(
                session: session, postID: postID, versionID: item.postID)
            status = .receipt(receipt)
            closeReader()
            await load()
        } catch {
            status = .refusal(VersionActs.words(error))
        }
    }

    /// **DELETE — confirmed**, and it is the ordinary move-to-Trash road, so
    /// the moment waits out its 30 days like everything else. (**No purge
    /// door here**: ending those days early is the Trash room's, her evolved
    /// rule — this face has no `requestPurge` road at all.)
    func confirmDelete(_ item: Queries.NoteVersionItem) async {
        pendingDelete = nil
        status = nil
        do {
            let receipt = try await VersionActs.delete(
                session: session, versionID: item.postID)
            status = .receipt(receipt)
            closeReader()
            await load()
        } catch {
            status = .refusal(VersionActs.words(error))
        }
    }

    // MARK: The alert hosts' bindings

    /// The rule the phone learned the hard way (batch 4.5b): a binding
    /// setter must never clear state an action's continuation will read
    /// back. Both confirms carry their subject into the action closure via
    /// `presenting:`, so there is no read-back left for a setter to beat.
    var restorePresented: Bool {
        get { pendingRestore != nil }
        set { if !newValue { pendingRestore = nil } }
    }

    var deletePresented: Bool {
        get { pendingDelete != nil }
        set { if !newValue { pendingDelete = nil } }
    }

    // MARK: Words

    /// **The phone's empty line.** `VersionsPath.empty` names ⌘⇧S and the
    /// phone has no chords, so the sentence is re-voiced over the SHARED
    /// verb — the `BlockHistoryController.noSavepoints` precedent exactly.
    static var noVersions: String {
        "No saved moments yet — \(VersionsPath.saveVerb) in \u{22EF} keeps the "
            + "whole note as it is right now."
    }

    /// A row's own two lines, from the shared face rules.
    static func rowTitle(_ item: Queries.NoteVersionItem) -> String {
        VersionsPath.rowTitle(item)
    }

    /// A row's second line: everything the shared meta says EXCEPT the piece
    /// the row's title is already saying, plus the moment's first words.
    ///
    /// **It drops the title's own piece BY NAME, never by position** (the
    /// cold review's m1). The first draft took `rowMeta` minus element 0 on
    /// the strength of the date being first — a positional coupling to an
    /// array whose contract promises no order and whose own doc names a live
    /// future that will edit it: 13w's automated rotation renders in that
    /// same list (`notes/plans/whole-note-history-brief.md`), and a new
    /// leading piece would have silently dropped the block count instead
    /// with nothing on screen to say so. Removing the piece that IS the
    /// title says what the line actually means and survives a reorder.
    ///
    /// The assumption that remains — that the shared meta's leading piece is
    /// the title's date — is no longer load-bearing, but it IS pinned
    /// (`theRowsMetaSaysEverythingButTheTitle`), so a 13w reorder announces
    /// itself here rather than passing quietly.
    static func rowMeta(_ item: Queries.NoteVersionItem) -> String {
        let title = VersionsPath.rowTitle(item)
        var pieces = VersionsPath.rowMeta(item).filter { $0 != title }
        if let preview = item.preview?.trimmingCharacters(in: .whitespacesAndNewlines),
           !preview.isEmpty {
            pieces.append("\u{201C}\(preview.prefix(64))\u{201D}")
        }
        return pieces.joined(separator: "  \u{00B7}  ")
    }
}

// MARK: - The screen

/// The pushed screen — it OWNS the model for the visit (the
/// `MobileWriteScreen` / `MobileWriteView` split, and its reason): a model
/// built inline in a `navigationDestination` builder is re-made on every
/// re-render, which would drop the moment being read and the last receipt.
/// Pins mount `MobileVersionsView` directly with the model they drove.
struct MobileVersionsScreen: View {
    @State private var model: MobileVersionsModel
    let tokens: VoiceTokens

    init(session: AppSession, postID: String, tokens: VoiceTokens) {
        _model = State(initialValue: MobileVersionsModel(session: session, postID: postID))
        self.tokens = tokens
    }

    var body: some View {
        MobileVersionsView(model: model, tokens: tokens)
    }
}

struct MobileVersionsView: View {
    @Bindable var model: MobileVersionsModel
    let tokens: VoiceTokens

    /// The reader's back door, and the proposal's own drawn path line.
    static let backToListing = "\u{2039} \(VersionsPath.name)"

    var body: some View {
        Group {
            if model.reading != nil {
                reader
            } else {
                listing
            }
        }
        .background(tokens.room.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { reportLine }
        .task { await model.load() }
        .alert(
            VersionsPath.restoreConfirmTitle,
            isPresented: $model.restorePresented,
            presenting: model.pendingRestore
        ) { item in
            Button(tokens.chromeLabel(VersionsPath.restoreVerb)) {
                let model = model
                Task { await model.confirmRestore(item) }
            }
            Button(tokens.chromeLabel("Cancel"), role: .cancel) {
                model.pendingRestore = nil
            }
        } message: { _ in
            Text(VersionsPath.restoreConfirmDetail)
        }
        .alert(
            VersionsPath.deleteVerb,
            isPresented: $model.deletePresented,
            presenting: model.pendingDelete
        ) { item in
            Button(tokens.chromeLabel("Delete"), role: .destructive) {
                let model = model
                Task { await model.confirmDelete(item) }
            }
            Button(tokens.chromeLabel("Cancel"), role: .cancel) {
                model.pendingDelete = nil
            }
        } message: { _ in
            Text(VersionsPath.deleteHelp)
        }
    }

    // MARK: The listing

    private var listing: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                header
                if model.versions.isEmpty {
                    line(MobileVersionsModel.noVersions)
                } else {
                    ForEach(model.versions, id: \.postID) { item in
                        row(item)
                    }
                }
                // The window is never silent (P1's visible half, and the
                // Archive room's own sentence — this room has no filter to
                // narrow either).
                if model.truncated {
                    line(MobileRoomListing.truncationMarker(shown: model.versions.count))
                }
            }
            .padding(.horizontal, 8)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(tokens.path([VersionsPath.name]))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Text(tokens.chromeLabel(VersionsPath.explainer))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    /// One moment's row: the DATE leads (V6 — no title mutation, the listing
    /// derives its display), then how much of the note it holds and its
    /// first words. **The whole row is the Read door** (Q9).
    private func row(_ item: Queries.NoteVersionItem) -> some View {
        Button {
            let model = model
            Task { await model.read(item) }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(tokens.chromeLabel(MobileVersionsModel.rowTitle(item)))
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Text(tokens.chromeLabel(MobileVersionsModel.rowMeta(item)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // The row IS the Read door, so it says so — `VersionsPath.openVerb`
        // is the Mac's own word for the same act.
        .accessibilityLabel(
            "\(VersionsPath.openVerb) \(MobileVersionsModel.rowTitle(item))")
    }

    // MARK: The moment (read-only by construction — a version is sealed)

    @ViewBuilder
    private var reader: some View {
        if let item = model.reading {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Button {
                        model.closeReader()
                    } label: {
                        Text(tokens.chromeLabel(Self.backToListing))
                            .font(tokens.small)
                            .foregroundStyle(tokens.accent)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Self.backToListing)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                VStack(alignment: .leading, spacing: 4) {
                    Text(tokens.path([MobileVersionsModel.rowTitle(item)]))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                    Text(tokens.chromeLabel(MobileVersionsModel.rowMeta(item)))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .lineLimit(2)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 6)
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(model.readingBlocks.enumerated()), id: \.offset) {
                            _, text in
                            Text(text)
                                .font(tokens.body)
                                .foregroundStyle(tokens.ink)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
                verbs(item)
            }
        }
    }

    /// The three verbs, on the MOMENT (Q9). Restore and Delete confirm;
    /// **Promote fires instantly** — her ratified #80(c).
    private func verbs(_ item: Queries.NoteVersionItem) -> some View {
        HStack(spacing: 18) {
            Button {
                model.pendingRestore = item
            } label: {
                Text(tokens.chromeLabel(VersionsPath.restoreVerb))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(VersionsPath.restoreVerb)
            Button {
                let model = model
                Task { await model.promote(item) }
            } label: {
                Text(tokens.chromeLabel(VersionsPath.promoteVerb))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(VersionsPath.promoteVerb)
            Spacer(minLength: 0)
            Button {
                model.pendingDelete = item
            } label: {
                Text(tokens.chromeLabel(VersionsPath.deleteVerb))
                    .font(tokens.small)
                    .foregroundStyle(tokens.alarm)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(VersionsPath.deleteVerb)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(tokens.room)
        .overlay(alignment: .top) {
            Rectangle().fill(tokens.line).frame(height: 1)
        }
    }

    /// The room's own prose line. **It carries an explicit accessibility
    /// label**, which is the standing rule rather than a nicety: the
    /// Terminal voice lowercases chrome, so VoiceOver would otherwise
    /// announce *"save a version"* for a door the sheet calls **Save a
    /// Version** — *"accessibility labels stay plain; VoiceOver reads words,
    /// not chrome styling"* (`MobileWriteScreen`'s own note).
    private func line(_ text: String) -> some View {
        Text(tokens.chromeLabel(text))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .accessibilityLabel(text)
    }

    /// Receipt or refusal, CLASSED where it was produced (`RecoveryStatus`,
    /// the shared rule) — never guessed from the text by this view.
    @ViewBuilder
    private var reportLine: some View {
        if let status = model.status {
            Text(tokens.chromeLabel(status.text))
                .font(tokens.small)
                .foregroundStyle(status.isRefusal ? tokens.alarm : tokens.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(tokens.room)
                .accessibilityLabel(status.text)
        }
    }
}
