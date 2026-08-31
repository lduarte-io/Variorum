//
//  MobileCreateBook.swift
//  VariorumMobile
//
//  Parity round Stage C, batch C2 — CREATE BOOK on the phone (her
//  feel-round finding #2: "create a new book"; the matrix's three kinds)
//  plus SMART-BOOK CREATION FROM TAGS (the LK5 expansion ruling verbatim:
//  "people also need to be able to create books based on tags").
//
//  One door, one sheet: the Mac's shelf "+ New Book" alert (three kinds)
//  and its Settings "Promote to Book…" sheet fold into ONE phone flow,
//  deliberately — the phone has no smart-filter EDITOR (book structure
//  management is OPEN-FOR-HER, C1's matrix), so a smart book minted with
//  an empty spec would be a dead end here. Smart creation therefore IS
//  the from-tags road: the spec is chosen at birth, exactly the Mac
//  PromoteTagsSheet's construction (OR → `tags`, AND → `tagsAll` — R30's
//  letter), and the tags stay on the notes (R37 — nothing here touches
//  applications).
//
//  Every act routes through the existing core operation (`createReading`);
//  no business rules live here.
//

import Foundation
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class MobileCreateBookModel {
    /// The three kinds the door offers (the Mac alert's own three).
    enum BookKind: String, CaseIterable, Sendable {
        case notes
        case journal
        case smartFromTags
    }

    @ObservationIgnored private let session: AppSession

    var name = ""
    var kind: BookKind = .notes
    /// Selected tag PATHS (the spec's vocabulary; sorted at build).
    var selectedTagPaths: Set<String> = []
    /// AND vs OR when several tags are picked (the Mac's radio pair).
    var joinAll = false
    private(set) var tags: [Tag] = []
    private(set) var lastError: String?

    init(session: AppSession) {
        self.session = session
    }

    /// One-shot: the taxonomy for the smart picker (author-scale rows).
    /// One flight at a time — this sheet's only write is the mint.
    let latch = MobileWriteLatch()

    func loadTags() async {
        do {
            tags = try await session.database.read { try Queries.allTags($0) }
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The face's gate, pure: a name is required (refuse-at-the-field —
    /// the Mac PromoteTagsSheet's `.disabled` shape, chosen over the
    /// create alert's "Untitled" default: the 13k K1 doctrine retired
    /// literal placeholders); a smart book needs at least one tag (an
    /// empty spec would collect everything and be uneditable here).
    var canCreate: Bool {
        Self.canCreate(
            name: name, kind: kind, selectedTagCount: selectedTagPaths.count)
    }

    nonisolated static func canCreate(
        name: String, kind: BookKind, selectedTagCount: Int
    ) -> Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        if kind == .smartFromTags { return selectedTagCount > 0 }
        return true
    }

    /// The spec construction IS the promotion (the Mac
    /// `PromoteTagsSheet.spec`'s exact rule, mirrored): OR → `tags`,
    /// AND → `tagsAll`.
    nonisolated static func spec(
        paths: [String], joinAll: Bool
    ) -> Queries.SmartQuerySpec {
        joinAll
            ? Queries.SmartQuerySpec(tagsAll: paths)
            : Queries.SmartQuerySpec(tags: paths)
    }

    /// Mints the book through the ONE core operation; returns the new
    /// book's id so the door can land on it (fire-and-DO — the created
    /// book opens as its contents front).
    ///
    /// **THE DUPLICATE-NAME GUARD ARRIVES HERE AT PL-10(b)** (her 13e E13
    /// ruling: *refuse at the door*). `assertBookNameIsFree` has been in
    /// core since 13e and the Mac has refused at five doors; the phone had
    /// **zero references to it**, so the same name could be minted twice
    /// from this sheet — the confusion her ruling is about, on the device
    /// she writes on.
    ///
    /// **The read sits INSIDE the runner closure with the mint**, exactly as
    /// the Mac's `ReadingsViewModel.create` does and for the operation's own
    /// stated reason: runner bodies are synchronous, so no other door's
    /// write can land between the read and the insert. The only surviving
    /// race is the cross-device one her ruling deliberately tolerates
    /// (`BookNaming`'s doc has the why-not-a-schema-rule).
    func create() async -> String? {
        // THE DOOR-LEVEL LATCH (the architectural review's MAJOR 1). The
        // button's `.disabled` reads `canCreate`, which is a pure function
        // of the name, the kind and the tags — NONE of which change during
        // the write — so the sheet stays presented and the button stays
        // hittable for the whole flight, and a double tap ran this twice.
        // The core guard below now refuses the second mint, which is the
        // authoritative layer and stays; this is the layer that stops a
        // gesture made ONCE from producing a refusal she has to read.
        await latch.run { await self.createOnce() } ?? nil
    }

    private func createOnce() async -> String? {
        guard canCreate else { return nil }
        let bookName = name.trimmingCharacters(in: .whitespaces)
        do {
            let id: String
            switch kind {
            case .notes:
                id = try await session.runner.run { ops in
                    try ops.assertBookNameIsFree(bookName)
                    return try ops.createReading(name: bookName, kind: .curated)
                }.id
            case .journal:
                // The Mac create alert's journal shape, byte-mirrored:
                // curated, profile 'journal', dated order ascending.
                id = try await session.runner.run { ops in
                    try ops.assertBookNameIsFree(bookName)
                    return try ops.createReading(
                        name: bookName, kind: .curated, profile: "journal",
                        sortField: .entryDate, sortDir: .asc)
                }.id
            case .smartFromTags:
                let paths = selectedTagPaths.sorted()
                let all = joinAll && paths.count > 1
                let json = try Self.spec(paths: paths, joinAll: all).encodedJSON()
                id = try await session.runner.run { ops in
                    try ops.assertBookNameIsFree(bookName)
                    return try ops.createReading(
                        name: bookName, kind: .smart, querySpec: json)
                }.id
            }
            lastError = nil
            return id
        } catch OperationError.duplicateBookName(let existing) {
            // Her sentence, from the ONE home — HOISTED to `Shared/` for
            // this door rather than copied (MobileSoul §3). Without this arm
            // the refusal reached her as `String(describing:)`'s raw enum
            // dump, which is the lecture-without-a-door class P-2 retired.
            lastError = BookNameCopy.refusal(existing: existing)
            return nil
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }
}

/// The create sheet (the phone's form grammar — LK4's sheet-over-page for
/// summoned machinery; an alert cannot host the tag picker step).
struct MobileCreateBookSheet: View {
    /// The shelf door's word (voice-cased at render; pinned beside the
    /// + New Note twin's).
    static let doorTitle = "+ New Book"

    @State private var model: MobileCreateBookModel
    let tokens: VoiceTokens
    /// Lands on the created book (the contents front — P35).
    let onCreated: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    init(
        session: AppSession, tokens: VoiceTokens,
        onCreated: @escaping (String) -> Void
    ) {
        _model = State(initialValue: MobileCreateBookModel(session: session))
        self.tokens = tokens
        self.onCreated = onCreated
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(tokens.chromeLabel("New Book"))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                Spacer()
                Button(tokens.chromeLabel("Cancel")) { dismiss() }
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .buttonStyle(.plain)
            }
            TextField(tokens.chromeLabel("Name"), text: $model.name)
                .textFieldStyle(.plain)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(tokens.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(tokens.line, lineWidth: 1)))
            kindRow
            Text(tokens.chromeLabel(caption))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            if model.kind == .smartFromTags {
                tagPicker
            }
            Spacer(minLength: 0)
            if let error = model.lastError {
                Text(error).font(tokens.small).foregroundStyle(tokens.alarm)
            }
            Button {
                Task {
                    if let id = await model.create() {
                        dismiss()
                        onCreated(id)
                    }
                }
            } label: {
                Text(tokens.chromeLabel("Create Book"))
                    .font(tokens.body)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(tokens.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(tokens.line, lineWidth: 1)))
            }
            .buttonStyle(.plain)
            .foregroundStyle(model.canCreate ? tokens.accent : tokens.faint)
            .disabled(!model.canCreate)
        }
        .padding(20)
        .background(tokens.room.ignoresSafeArea())
        .task { await model.loadTags() }
    }

    private var caption: String {
        switch model.kind {
        case .notes:
            return "A book holds a hand-picked, ordered note list."
        case .journal:
            return "A journal book holds dated entries, one after another."
        case .smartFromTags:
            return "A smart book collects notes by these tags — the tags stay on the notes."
        }
    }

    private var kindRow: some View {
        HStack(spacing: 18) {
            kindDoor("Book", .notes)
            kindDoor("Journal Book", .journal)
            kindDoor("Smart Book", .smartFromTags)
            Spacer()
        }
    }

    private func kindDoor(_ label: String, _ target: MobileCreateBookModel.BookKind) -> some View {
        Button {
            model.kind = target
        } label: {
            Text(tokens.chromeLabel(label))
                .font(tokens.small)
                .foregroundStyle(model.kind == target ? tokens.ink : tokens.faint)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(model.kind == target ? .isSelected : [])
    }

    private var tagPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            if model.tags.isEmpty {
                Text(tokens.chromeLabel("No tags yet — notes get tags first; a smart book collects by them."))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(model.tags, id: \.id) { tag in
                            tagRow(tag)
                        }
                    }
                }
                .frame(maxHeight: 220)
                if model.selectedTagPaths.count > 1 {
                    // The Mac's radio pair, as two text doors.
                    HStack(spacing: 18) {
                        joinDoor("any of these (OR)", false)
                        joinDoor("all of these (AND)", true)
                        Spacer()
                    }
                }
            }
        }
    }

    private func tagRow(_ tag: Tag) -> some View {
        let selected = model.selectedTagPaths.contains(tag.path)
        return Button {
            if selected {
                model.selectedTagPaths.remove(tag.path)
            } else {
                model.selectedTagPaths.insert(tag.path)
            }
        } label: {
            HStack(spacing: 8) {
                Text(selected ? "✓" : " ")
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .frame(width: 14, alignment: .leading)
                Text("#\(MobileShelfFaces.leaf(tag.path))")
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                Text(tag.path)
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func joinDoor(_ label: String, _ target: Bool) -> some View {
        Button {
            model.joinAll = target
        } label: {
            Text(tokens.chromeLabel(label))
                .font(tokens.small)
                .foregroundStyle(model.joinAll == target ? tokens.ink : tokens.faint)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(model.joinAll == target ? .isSelected : [])
    }
}
