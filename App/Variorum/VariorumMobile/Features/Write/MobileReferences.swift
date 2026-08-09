//
//  MobileReferences.swift
//  VariorumMobile
//
//  Parity round Stage C, batch C3 — the "MORE INFO" list (her precision
//  #3, the matrix's references family: SEE a note's references, ADD a
//  URL, OPEN one; the side-by-side panel itself is a ruled exclusion).
//  The masthead's identity area wears a "more info" chip; tapping it
//  opens this sheet over the page (LK4's grammar).
//
//  · URL rows OPEN — the row is a door to the link (the system browser;
//    a read-only web pane beside the draft is the Mac panel's shape and
//    excluded here).
//  · FILE rows are listed HONESTLY IN NEUTRAL WORDS: `file_bookmark` is
//    LOCAL-ONLY by model fact (AppSpec §7 — "files are per-machine"),
//    so a file row here carries a name and no file. The copy states
//    what a file row IS without naming any platform (the C3 brief's
//    letter).
//  · ADD is the URL door (her "maybe add + open one"); REMOVE rides the
//    row's long-press — a row the phone can add, it must also be able
//    to take back (the no-redirect principle; PROVISIONAL, recorded).
//
//  Every act routes through the existing core operations
//  (`addReference`, `removeReference`); the row order is the panel's
//  own (`Queries.references` — position, id).
//

import Foundation
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class MobileReferencesModel {
    @ObservationIgnored private let session: AppSession
    @ObservationIgnored let postID: String

    private(set) var references: [Reference] = []
    private(set) var status: String?

    init(session: AppSession, postID: String) {
        self.session = session
        self.postID = postID
    }

    // MARK: - Pure brains (pinned)

    /// The masthead chip's words: the door word alone when the note has
    /// no references, the count beside it when it does.
    nonisolated static func chipLabel(count: Int) -> String {
        count == 0 ? "more info" : "more info · \(count)"
    }

    /// The Mac `ReferencesViewModel.addURL` normalization, extracted
    /// pure: bare "example.com" reads as https; a string that can't
    /// become a loadable URL is nil (the caller refuses).
    nonisolated static func normalized(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let candidate = trimmed.contains("://") ? trimmed : "https://\(trimmed)"
        guard let url = URL(string: candidate), url.host() != nil else { return nil }
        return candidate
    }

    /// What a row is called: its stored name, else its URL, else the
    /// bare kind word.
    nonisolated static func rowTitle(_ reference: Reference) -> String {
        if let name = reference.name, !name.isEmpty { return name }
        if let url = reference.url, !url.isEmpty { return url }
        return reference.kind == .url ? "link" : "file"
    }

    /// The URL a row OPENS — URL rows only. A file row opens nothing:
    /// its bookmark is per-machine by model fact, so there is no file
    /// here to open (never a refusal to invent — the row's own words
    /// say what it is).
    nonisolated static func openableURL(_ reference: Reference) -> URL? {
        guard reference.kind == .url, let raw = reference.url else { return nil }
        return URL(string: raw)
    }

    /// The FILE row's honest sentence — what a file row IS, in neutral
    /// words, no platform named (the C3 brief's letter; the model fact
    /// is AppSpec §7's: bookmarks are per-machine and never sync).
    static let fileRowNote =
        "A file stays on the device where it was added — only its name travels here."

    /// The add door's refusal (phone words).
    nonisolated static func notLoadable(_ raw: String) -> String {
        "Not a loadable link: \(raw)"
    }

    // MARK: - Reads

    func refresh() async {
        do {
            let postID = postID
            references = try await session.database.read { db in
                try Queries.references(db, containerID: postID)
            }
        } catch {
            status = String(describing: error)
        }
    }

    // MARK: - Acts (every one an existing core operation)

    /// Adds a URL reference — scheme-normalized, named by its host (the
    /// Mac door's own semantics). Returns true when it landed (the
    /// field clears on it).
    @discardableResult
    func addURL(_ raw: String) async -> Bool {
        guard let normalized = Self.normalized(raw) else {
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { status = Self.notLoadable(trimmed) }
            return false
        }
        do {
            let host = URL(string: normalized)?.host()
            try await session.runner.run { [postID] ops in
                _ = try ops.addReference(
                    to: postID, kind: .url, name: host, url: normalized)
            }
            status = nil
            await refresh()
            return true
        } catch {
            status = String(describing: error)
            await refresh()
            return false
        }
    }

    func remove(_ id: String) async {
        do {
            try await session.runner.run { ops in
                try ops.removeReference(id)
            }
            status = nil
        } catch {
            status = String(describing: error)
        }
        await refresh()
    }
}

/// The "more info" sheet (LK4's grammar).
struct MobileReferencesSheet: View {
    @Bindable var model: MobileReferencesModel
    let tokens: VoiceTokens
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    @State private var addPresented = false
    @State private var addField = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(tokens.chromeLabel("More Info"))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                Spacer()
                Button(tokens.chromeLabel("Done")) { dismiss() }
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .buttonStyle(.plain)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if model.references.isEmpty {
                        Text(tokens.chromeLabel(
                            "Nothing kept beside this note yet — add a link below."))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    ForEach(model.references, id: \.id) { reference in
                        row(reference)
                    }
                    addRow
                    if let status = model.status {
                        Text(status)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .background(tokens.room.ignoresSafeArea())
        .task { await model.refresh() }
        .alert("Add a Link", isPresented: $addPresented) {
            TextField("example.com or https://…", text: $addField)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Button("Add") {
                let raw = addField
                let model = model
                Task {
                    if await model.addURL(raw) { addField = "" }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The link is kept beside this note; tapping its row opens it.")
        }
    }

    /// One reference's row: a URL row is a DOOR (opens the link); a
    /// file row is its name plus the honest sentence. Long-press holds
    /// remove on both.
    @ViewBuilder
    private func row(_ reference: Reference) -> some View {
        let title = MobileReferencesModel.rowTitle(reference)
        Group {
            if let url = MobileReferencesModel.openableURL(reference) {
                Button {
                    openURL(url)
                } label: {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(tokens.body)
                            .foregroundStyle(tokens.accent)
                            .lineLimit(1)
                        Text(tokens.chromeLabel("opens"))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open \(title)")
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                    Text(tokens.chromeLabel(MobileReferencesModel.fileRowNote))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 6)
            }
        }
        .contextMenu {
            Button(tokens.chromeLabel("Remove"), role: .destructive) {
                let model = model
                let id = reference.id
                Task { await model.remove(id) }
            }
        }
    }

    private var addRow: some View {
        Button {
            addField = ""
            addPresented = true
        } label: {
            HStack {
                Text(tokens.chromeLabel("+ add a link"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                Spacer()
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add a Link")
    }
}
