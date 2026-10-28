//
//  NoteVersionPage.swift
//  Variorum (Mac)
//
//  **VX-440 batch 1 — A SAVED VERSION, FULL SIZE** (VX-432; her sitting ruling
//  R-440-2, "Back + Promote"; the record is
//  `notes/plans/fixes/vx-440-sheets-history-clarity.md`).
//
//  The ruling: the moment opens read-only in the note surface on Read's calm
//  page, under an identity band — "A saved version of ‹title› · ‹date›" —
//  carrying **Back to the note** and **Promote to a regular note…** (the same
//  confirm as Compare's unmark). The mode row and version-minting (⌘⇧S) are
//  suppressed on it.
//
//  How each clause holds, structurally rather than by suppression:
//  · it is its OWN destination (`SidebarSelection.noteVersion`), never a
//    `.post` — so no `PostDetailView` mounts: no detail registers with the
//    router, the sidebar's "this note" rail (drawn for `.post` only) is not
//    drawn, ⌘⇧S's surfaces are absent (`noteScoped` reads a mounted detail or
//    editor — none here — so File greys it and ⌘K's row speaks its note), and
//    the Open list (which tracks `.post`) gains no row;
//  · the page is `ReadPageColumn` — Read's own calm page — with its
//    paragraph click-through switched OFF (nothing here is editable);
//  · **it writes no per-note memory** (PROVISIONAL P-440-1): no `postMode.‹id›`,
//    no Read face key, no place report — it always opens at the start; the
//    pane's back/forward carry the visit like any other destination;
//  · the band is the one navigation: Back adopts the note; Promote asks the
//    one question (`VersionsPath.stopCounting…`, P-440-5) and, promoted, the
//    pane shows the new note as a note (PROVISIONAL P-440-7).
//
//  P3: everything here is read-cheap `Text` on a lazily realized page.
//

import Foundation
import GRDB  // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

extension Notification.Name {
    /// **A door naming a saved moment to open FULL SIZE** (VX-440 batch 1):
    /// `userInfo` carries `versionID` and `noteID`. A navigation SIGNAL — the
    /// shell decides what it means (P-4, the `.variorumOpenPost` precedent).
    static let variorumOpenNoteVersion = Notification.Name("variorumOpenNoteVersion")
}

@MainActor
@Observable
final class NoteVersionPageModel {
    @ObservationIgnored let session: AppSession
    let versionID: String
    let noteID: String

    /// What the band says, read together so it can never disagree with itself.
    nonisolated struct Facts: Equatable, Sendable {
        /// Still this note's saved moment (the ONE classifier) — false once it
        /// was promoted, deleted or unlinked (a back/forward visit can arrive
        /// after any of them).
        var isVersion: Bool
        /// The moment's own birth stamp — its derived name (V6).
        var savedAt: Date?
        /// The NOTE's display name (the masthead's one rule).
        var noteTitle: String
    }

    private(set) var facts: Facts?
    /// The promote's ask — a VALUE the page's alert presents (13l Act 2's rule).
    var pendingPromote = false

    init(session: AppSession, versionID: String, noteID: String) {
        self.session = session
        self.versionID = versionID
        self.noteID = noteID
    }

    nonisolated static func read(
        _ db: Database, versionID: String, noteID: String
    ) throws -> Facts {
        Facts(
            isVersion: try Queries.isVersionHistory(db, versionID, of: noteID),
            savedAt: try Container.fetchOne(db, key: versionID)?.createdAt,
            noteTitle: try Queries.noteDisplayTitle(db, id: noteID) ?? DisplayTitle.placeholder)
    }

    /// Held while the page is on screen: a rename of the note, or the moment
    /// promoted or deleted from another door, shows at once.
    func start() async {
        do {
            for try await value in session.database.observe({ [versionID, noteID] db in
                try Self.read(db, versionID: versionID, noteID: noteID)
            }) {
                adopt(value)
            }
        } catch {}
    }

    /// Internal so pins drive the page deterministically.
    func adopt(_ value: Facts) {
        facts = value
    }

    /// The band's line — the moment named by its note and its date.
    var bandLine: String? {
        guard let facts, let savedAt = facts.savedAt else { return nil }
        return VersionsPath.bandLine(noteTitle: facts.noteTitle, savedAt: savedAt)
    }

    /// **The confirm's answer** — the shared versions act; true when the moment
    /// became a note. Its receipt and refusals speak in the family's words on
    /// the one status seam.
    func promote() async -> Bool {
        pendingPromote = false
        do {
            session.status.receipt(try await VersionActs.promote(
                session: session, postID: noteID, versionID: versionID))
            return true
        } catch {
            session.status.refuse(VersionActs.words(error, seal: .mac))
            return false
        }
    }
}

struct NoteVersionPage: View {
    let session: AppSession
    let versionID: String
    let noteID: String
    /// "Back to the note" — the shell adopts the note into this pane.
    let onBack: () -> Void
    /// The moment became a note: the shell shows it AS a note (P-440-7).
    let onPromoted: () -> Void

    @State private var model: NoteVersionPageModel
    /// Read's own row source over the MOMENT (its rows never change: sealed).
    @State private var toc: BlockTOCViewModel
    @State private var carry = ReadCarryGeometry()
    @State private var heights = ReadNoteHeights(face: .page)
    /// Never set: the page always opens at its start (P-440-1).
    @State private var pageTarget: ReadLanding?
    /// Read's type size, READ (never written here) — her reading posture.
    @AppStorage("readModeTypeScale") private var typeScale = 1.0
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession, versionID: String, noteID: String,
        onBack: @escaping () -> Void, onPromoted: @escaping () -> Void
    ) {
        self.session = session
        self.versionID = versionID
        self.noteID = noteID
        self.onBack = onBack
        self.onPromoted = onPromoted
        _model = State(initialValue: NoteVersionPageModel(
            session: session, versionID: versionID, noteID: noteID))
        _toc = State(initialValue: BlockTOCViewModel(session: session, postID: versionID))
    }

    /// **The door every surface uses to open a moment full size** — the
    /// Versions row's "Open full size" and a moment's Compare column. A signal
    /// to the shell (`RootView` turns it into the `.noteVersion` destination).
    static func open(versionID: String, of noteID: String) {
        NotificationCenter.default.post(
            name: .variorumOpenNoteVersion, object: nil,
            userInfo: ["versionID": versionID, "noteID": noteID])
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            band
            if model.facts?.isVersion == false {
                gone
            } else {
                ReadPageColumn(
                    session: session, postID: versionID, model: toc,
                    page: scheme == .dark ? .dark : .light, tokens: tokens,
                    typeScale: typeScale, dark: scheme == .dark,
                    pageTarget: $pageTarget,
                    carriedBlockID: nil, carryGeometry: carry, heights: heights,
                    flashOn: false,
                    onOpenInEdit: nil)
            }
        }
        .background(tokens.room)
        .task { await toc.primeRows(); await toc.start() }
        .task { await model.start() }
        .onDisappear { toc.teardown() }
        .alert(
            VersionsPath.stopCountingTitle,
            isPresented: Binding(
                get: { model.pendingPromote },
                set: { if !$0 { model.pendingPromote = false } })
        ) {
            Button(VersionsPath.stopCountingVerb) {
                Task { if await model.promote() { onPromoted() } }
            }
            Button("Cancel", role: .cancel) { model.pendingPromote = false }
        } message: {
            Text(VersionsPath.stopCountingDetail)
        }
    }

    // MARK: - The identity band (R-440-2)

    private var band: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(model.bandLine ?? VersionsPath.name)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer(minLength: 8)
            Button(tokens.chromeLabel(VersionsPath.backToNoteVerb)) { onBack() }
                .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                .lineLimit(1)
                .fixedSize()
                .help("Returns to the note as it is now")
            if model.facts?.isVersion != false {
                Button(tokens.chromeLabel(VersionsPath.promoteToNoteVerb)) {
                    model.pendingPromote = true
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                .lineLimit(1)
                .fixedSize()
                .help(VersionsPath.promoteHelp)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
        .background(tokens.card)
        .overlay(alignment: .bottom) { Divider().overlay(tokens.line) }
    }

    /// The moment is no longer this note's (promoted, deleted or unlinked
    /// since): its words are not shown as if it were — the band's Back stays.
    private var gone: some View {
        VStack(spacing: 8) {
            Spacer()
            Text(tokens.chromeLabel(VersionsPath.fullSizeGone))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
