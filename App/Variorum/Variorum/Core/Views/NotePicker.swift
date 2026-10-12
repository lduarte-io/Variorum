//
//  NotePicker.swift
//  Variorum (Mac) — Core/Views (the shared Mac-chrome home; consumed by
//  the Library's version doors and the Pool's Add-to-Book door, and built
//  so wave 2c's Compare "Choose a note…" drops it in without change)
//
//  pre-13u Act 10 wave 2b, item 14 — **ONE searchable picker, built
//  once.** The flat corpus-enumerating submenu (manifest row 06: ~40 bare
//  titles, "2026-08-01" ×6, no search, no context — her words: "this is a
//  disaster") retires wherever a note or book is chosen from the corpus.
//  In its place: search-as-you-type over a BOUNDED feed, contextually
//  ranked (version peers first where versions are the subject; recent
//  first otherwise), with a snippet + day per row so five same-day notes
//  are tellable apart. The snippet is derived at read time by the query —
//  never stored, and deliberately NOT 13u item 4's display-name rule
//  (titles stay titles; the snippet is row context).
//
//  ── THE COMPONENT SEAM (for wave 2c) ─────────────────────────────────
//  `NotePickerSheet` is data-blind: it renders whatever a
//  `NotePickerSource.search` closure returns for the typed query. The
//  factories below are the shipped feeds; Compare's "Choose a note…"
//  is `.corpusNotes(session:excluding:versionPeersOf:peerAnnotation:)`
//  with its own pick handler — no view changes needed.
//

import SwiftUI
import VariorumCore

// MARK: - The row

/// One row the picker offers. `annotation` is the contextual mark
/// ("already versions", "finished") — quiet, never a refusal.
struct NotePickerRow: Identifiable, Equatable {
    let id: String
    let title: String
    var snippet: String?
    /// Right-side quiet context — the day, where it adds anything.
    var detail: String?
    var annotation: String?
}

// MARK: - The ranking rule (pure — pinned in NotePickerTests)

/// Contextual ranking: the priority set (version peers where versions are
/// the subject) floats to the top, STABLY — inside each partition the
/// feed's own order (recent first) is preserved untouched.
enum NotePickerRanking {
    static func rank(
        _ rows: [NotePickerRow], priorityIDs: Set<String>
    ) -> [NotePickerRow] {
        guard !priorityIDs.isEmpty else { return rows }
        return rows.filter { priorityIDs.contains($0.id) }
            + rows.filter { !priorityIDs.contains($0.id) }
    }

    /// The row's quiet detail: the note's day — suppressed when the title
    /// already IS that day (a nameless note displays its date; repeating
    /// it as context says nothing twice).
    static func detail(title: String, day: String?) -> String? {
        guard let day, day != title else { return nil }
        return day
    }
}

// MARK: - The sources

/// A picker feed: the typed query in, ranked bounded rows out.
struct NotePickerSource {
    let search: (String) async -> [NotePickerRow]
}

/// One-shot cache for the subject's version peers — read once per sheet,
/// not once per keystroke.
@MainActor
private final class PeerCache {
    private var loaded: Set<String>?

    func peers(session: AppSession, of anchor: String) async -> Set<String> {
        if let loaded { return loaded }
        let ids = (try? await session.database.read { db in
            try Queries.versionPeerPosts(db, of: anchor)
        }) ?? []
        let set = Set(ids)
        loaded = set
        return set
    }
}

extension NotePickerSource {
    /// Item 14's note feed: `Queries.notePickerNotes` (bounded, recent
    /// first, LIKE-escaped), ranked with the subject's version peers first
    /// where a peer anchor is given (each wearing `peerAnnotation`).
    ///
    /// 13n-c U2 — `inWing` (additive; nil = byte-identical): the wing a
    /// SUBJECT-LESS feed reads instead of the session's current one (the grant
    /// sheet in Settings searches the wing she chose; a subject's own wing
    /// still wins — §9).
    @MainActor
    static func corpusNotes(
        session: AppSession, excluding subjectID: String?,
        versionPeersOf peerAnchor: String? = nil,
        peerAnnotation: String? = nil,
        inWing wingOverride: String? = nil
    ) -> NotePickerSource {
        let cache = PeerCache()
        return NotePickerSource { query in
            var peerIDs: Set<String> = []
            if let peerAnchor {
                peerIDs = await cache.peers(session: session, of: peerAnchor)
            }
            // 13i-d U5: the picker offers the SUBJECT's own wing (§9 — a
            // version link, a comparison or a book add never reaches into
            // another library); no subject = the current wing.
            let fallback = wingOverride ?? session.wing.currentID
            let hits: [Queries.NotePickerHit] = (try? await session.database.read { db in
                let wing = try subjectID.flatMap { try Queries.effectiveWing(db, ofPost: $0) }
                    ?? fallback
                return try Queries.notePickerNotes(
                    db, query: query, excluding: subjectID, wingID: wing)
            }) ?? []
            let rows = hits.map { hit in
                NotePickerRow(
                    id: hit.id, title: hit.title, snippet: hit.snippet,
                    detail: NotePickerRanking.detail(
                        title: hit.title,
                        day: hit.entryDate
                            ?? DisplayTitle.day(fromStamp: hit.touchedStamp)),
                    annotation: peerIDs.contains(hit.id) ? peerAnnotation : nil)
            }
            return NotePickerRanking.rank(rows, priorityIDs: peerIDs)
        }
    }

    /// The Unmark door's feed: EXACTLY the subject's version peers — the
    /// only notes the act can apply to, so nothing else is offered and the
    /// old "an unlinked pick speaks its refusal" corner (R60/R68) becomes
    /// unreachable by construction rather than merely spoken.
    @MainActor
    static func versionPeers(session: AppSession, of anchor: String) -> NotePickerSource {
        NotePickerSource { query in
            // 13i-d U5 (#166(e)): a version in ANOTHER wing is never offered
            // here — its snippet would be content pulled across libraries.
            let hits = (try? await session.database.read { db in
                try Queries.notePickerNotes(
                    db, ids: try Queries.versionPeerSplit(db, of: anchor).sameWing)
            }) ?? []
            let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
            return hits
                .filter {
                    needle.isEmpty
                        || $0.title.localizedCaseInsensitiveContains(needle)
                        || ($0.snippet?.localizedCaseInsensitiveContains(needle) ?? false)
                }
                .map { hit in
                    NotePickerRow(
                        id: hit.id, title: hit.title, snippet: hit.snippet,
                        detail: NotePickerRanking.detail(
                            title: hit.title,
                            day: hit.entryDate
                                ?? DisplayTitle.day(fromStamp: hit.touchedStamp)))
                }
        }
    }

    /// Item 2's book feed: the curated shelf (the only books a note can be
    /// hand-added to — the standing door's own filter), searched by name
    /// in memory (the readings listing is already held and bounded).
    /// Finished books stay offered with the honest mark — picking one lets
    /// the standing gate speak, exactly as the old dropdown did.
    static func curatedBooks(_ readings: [Reading]) -> NotePickerSource {
        NotePickerSource { query in
            let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
            return readings
                .filter { $0.kind == .book }
                .filter {
                    needle.isEmpty || $0.name.localizedCaseInsensitiveContains(needle)
                }
                .map { reading in
                    // 13i-e U2 — her second rider: an archived book is MARKED,
                    // never refused — the add lands on a plain pick.
                    let marks = [reading.locked ? "finished" : nil,
                                 reading.archivedAt != nil ? BookArchiveCopy.word : nil]
                        .compactMap { $0 }
                    return NotePickerRow(
                        id: reading.id, title: reading.name,
                        annotation: marks.isEmpty ? nil : marks.joined(separator: " \u{00B7} "))
                }
        }
    }
}

// MARK: - The sheet

/// The one searchable picker surface: the mockup's squarish-rounded
/// search field (W8-2) over calm-card rows. ⏎ picks the top row; Esc
/// cancels; every row is one generous click.
struct NotePickerSheet: View {
    let tokens: VoiceTokens
    /// What the pick DOES — the door's own verb ("Mark as Versions with").
    let title: String
    var prompt = "search notes"
    var emptyState = "Nothing matches."
    let source: NotePickerSource
    let onPick: (NotePickerRow) -> Void
    /// 17y item (o) — THE INLINE MINT (the one picker idiom, `SearchPicker`'s
    /// brain): when a host can MAKE what was typed, the create row names it
    /// ('New book "X"') atop the matches, and ⏎ takes it when nothing
    /// matches. nil = search only (the note pickers).
    var createLabel: ((String) -> String)? = nil
    var createKey: (String) -> String = { $0 }
    var onCreate: ((String) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var rows: [NotePickerRow] = []
    @State private var generation = 0
    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(tokens.chromeLabel(title))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
                Spacer()
                Button(tokens.chromeLabel("cancel")) { dismiss() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(.cancelAction)
            }
            // The mockup's search field: squarish-rounded, generous.
            HStack(spacing: 6) {
                Text("⌕")
                    .font(tokens.body)
                    .foregroundStyle(tokens.muted)
                TextField(prompt, text: $query)
                    .textFieldStyle(.plain)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .focused($searchFocused)
                    .onSubmit {
                        if let top = rows.first {
                            pick(top)
                        } else if let offer = createOffer {
                            create(offer)
                        }
                    }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(tokens.card, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    if let offer = createOffer, let createLabel {
                        Button {
                            create(offer)
                        } label: {
                            CalmCard(tokens: tokens) {
                                Text(createLabel(offer))
                                    .font(tokens.body)
                                    .foregroundStyle(tokens.accent)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    ForEach(rows) { row in
                        rowCard(row)
                    }
                    if rows.isEmpty, createOffer == nil {
                        Text(tokens.chromeLabel(emptyState))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.vertical, 2)
            }
            .frame(minHeight: 260, maxHeight: 380)
        }
        .padding(16)
        .frame(minWidth: 460)
        .background(tokens.surface)
        .task { await runSearch() }
        .task(id: query) { await runSearch() }
        .onAppear { searchFocused = true }
    }

    private func rowCard(_ row: NotePickerRow) -> some View {
        Button {
            pick(row)
        } label: {
            CalmCard(tokens: tokens) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(row.title)
                            .font(tokens.body)
                            .foregroundStyle(tokens.ink)
                            .lineLimit(1)
                        if let annotation = row.annotation {
                            Text(tokens.chromeLabel(annotation))
                                .font(tokens.small)
                                .foregroundStyle(tokens.accent.opacity(0.85))
                                .lineLimit(1)
                        }
                        Spacer(minLength: 0)
                        if let detail = row.detail {
                            Text(tokens.chromeLabel(detail))
                                .font(tokens.small)
                                .foregroundStyle(tokens.faint)
                                .lineLimit(1)
                        }
                    }
                    if let snippet = row.snippet {
                        Text(snippet)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func pick(_ row: NotePickerRow) {
        dismiss()
        onPick(row)
    }

    /// The create row's value, by the one brain (`SearchPickerBrain`): the
    /// typed text when no row already IS it.
    private var createOffer: String? {
        guard createLabel != nil, onCreate != nil else { return nil }
        return SearchPickerBrain.createOffer(
            query: query,
            options: rows.map { SearchPickerOption(id: $0.id, label: $0.title) },
            key: createKey)
    }

    private func create(_ typed: String) {
        dismiss()
        onCreate?(typed)
    }

    /// The palette's cadence: one bounded read per typed query, latest
    /// keystroke wins — no debounce machinery, no stale overwrite.
    private func runSearch() async {
        generation += 1
        let mine = generation
        let result = await source.search(query)
        guard mine == generation else { return }
        rows = result
    }
}
