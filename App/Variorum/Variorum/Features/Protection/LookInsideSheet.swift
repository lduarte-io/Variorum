//
//  LookInsideSheet.swift
//  Variorum
//
//  VX-306 U3 — LOOK INSIDE, the Mac's face (rule 17; the orchestrator's ruling P-VX306-U3-15 — (b), the read-only facts
//  sheet). §7c (10)'s line first (*This is a copy from <date>. Nothing you do here changes it or your library.*, built
//  exactly as drafted), then the copy's kind; its books with their note counts; its notes newest first, a page at a
//  time (*Show more*); a note's text read-only when she picks one (*Back* to the lists); *Make this my library…* beside
//  *Close* where a library is open. Nothing here is editable and nothing here writes: every word is read from a private
//  copy through `LookInsideModel`, and closing forgets. When the copy's own quiet road doesn't open it, its passphrase or
//  twelve words are asked first (the copy's field, §7c (8)'s label).
//  VX-307 U2c — VX-413: the note page carries *Copy full text* beside *Back* (the note onto the clipboard in the Variorum
//  document format — the same door and name a live note has), its receipt said under it; the text itself stays as it
//  was — read-only, never selectable into an edit road.
//

import SwiftUI
import VariorumCore

struct LookInsideSheet: View {
    @Bindable var model: LookInsideModel

    @State private var secret = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ProtectionWords.lookInsideTitle).font(.title3.weight(.semibold))
            Text(model.frameLine)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
            Text(model.kindLine)
                .font(.caption)
                .foregroundStyle(.secondary)
            switch model.phase {
            case .opening:
                working(ProtectionWords.lookInsideOpening)
            case .needsSecret:
                Text(ProtectionWords.lookInsideAsk)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                PeekableSecretField(label: ProtectionWords.makeMineCopySecretField, text: $secret, onSubmit: submit)
                    .textFieldStyle(.roundedBorder)
                if model.busy { working(ProtectionWords.lookInsideOpening) }
            case .unavailable, .closed:
                EmptyView()
            case .open:
                if let note = model.shown {
                    noteView(note)
                } else {
                    lists
                }
            }
            if let refusal = model.refusal {
                Text(refusal)
                    .font(.callout)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Button(ProtectionWords.lookInsideClose) { model.close() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                if model.phase == .needsSecret {
                    Button(ProtectionWords.openButton) { submit() }
                        .keyboardShortcut(.defaultAction)
                        .disabled(model.busy || secret.isEmpty)
                }
                if model.offersMakeMine, model.phase == .open {
                    Button(ProtectionWords.makeMineDoor) { model.makeMine() }
                }
            }
        }
    }

    private var lists: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(ProtectionWords.lookInsideBooks).font(.callout.weight(.semibold))
                if model.books.isEmpty {
                    Text(ProtectionWords.lookInsideNoBooks).font(.caption).foregroundStyle(.secondary)
                }
                ForEach(model.books) { book in
                    HStack {
                        Text(book.name).lineLimit(1)
                        Spacer()
                        Text(ProtectionWords.lookInsideBookCount(book.noteCount))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Text(ProtectionWords.lookInsideNotes).font(.callout.weight(.semibold)).padding(.top, 6)
                if model.notes.isEmpty {
                    Text(ProtectionWords.lookInsideNoNotes).font(.caption).foregroundStyle(.secondary)
                }
                ForEach(model.notes) { note in
                    Button {
                        Task { await model.show(note) }
                    } label: {
                        HStack {
                            Text(title(note.title)).lineLimit(1)
                            Spacer()
                            if let day = note.entryDate ?? note.touchedAt.map({ String($0.prefix(10)) }) {
                                Text(day).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(model.busy)
                }
                if model.hasMoreNotes {
                    Button(ProtectionWords.lookInsideMore) { Task { await model.moreNotes() } }
                        .disabled(model.busy)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 320)
    }

    private func noteView(_ note: ProtectionCopyPeek.NoteText) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(ProtectionWords.lookInsideBack) { model.back() }
                Spacer()
                // VX-307 U2c — VX-413: the note onto the clipboard in the Copy full text format (the same door and name
                // a live note has); nothing written to the copy or the library.
                if model.offersCopyFullText {
                    Button(ProtectionWords.lookInsideCopyFullText) { Task { await model.copyFullText() } }
                        .disabled(model.busy)
                }
            }
            if let line = model.copyLine {
                Text(line.sentence)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(title(note.title)).font(.callout.weight(.semibold))
            ScrollView {
                // Read-only, never selectable into an edit road: the page as it reads.
                Text(note.blocks.joined(separator: "\n"))
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 280)
        }
    }

    private func working(_ line: String) -> some View {
        HStack(spacing: 6) {
            TravellingDotsIndicator(ink: .secondary)
            Text(line).font(.caption).foregroundStyle(.secondary)
        }
    }

    private func title(_ title: String?) -> String {
        let trimmed = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? ProtectionWords.lookInsideUntitled : trimmed
    }

    private func submit() {
        let typed = secret
        secret = ""
        Task { await model.submit(secret: typed) }
    }
}
