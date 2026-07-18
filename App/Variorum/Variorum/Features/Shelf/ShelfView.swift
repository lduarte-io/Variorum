//
//  ShelfView.swift
//  Variorum
//
//  Phase 13, B2 — THE SHELF (home): the terminal LIST style with a TAGS
//  column (R4), the ls-line, pinning (R38), finish + extent faces, and the
//  bottom QUICK-ENTRY bar (R3 — "start typing" pinned at the bottom, the
//  list scrolling above it under a max height; Enter opens the typed text
//  as a whole post; the blinking block cursor is the terminal idiom).
//  Voiced through the token layer — no literal colors here.
//

import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

struct ShelfView: View {
    let session: AppSession
    let model: ShelfViewModel
    let readings: ReadingsViewModel
    /// Cross-feature routing lives in composition: open a book, a post.
    let onOpen: (SidebarSelection) -> Void
    /// The dated home's door (R38: the journal lives on the shelf).
    let onTodaysEntry: () -> Void

    @Environment(ThemeStore.self) private var theme
    @Environment(\.colorScheme) private var scheme

    @State private var entryText = ""
    @State private var cursorOn = true
    @FocusState private var entryFocused: Bool
    @State private var createPresented = false
    @State private var nameField = ""
    @State private var renameTarget: Reading?
    @State private var manageTarget: Reading?
    @State private var smartTarget: Reading?
    @State private var extentTarget: Reading?

    private var tokens: VoiceTokens { theme.tokens(for: scheme) }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(tokens.line)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(model.orderedBooks, id: \.reading.id) { book in
                        shelfRow(book)
                        Divider().overlay(tokens.line.opacity(0.6))
                    }
                    if model.books.isEmpty {
                        Text(tokens.chromeLabel("No books yet — create one, or just start typing below."))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(24)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 10)
            }
            entryBar
            hintBar
        }
        .background(tokens.surface)
        .task { await model.start() }
        .task { await model.refreshAggregates() }
        .alert("New Book", isPresented: $createPresented) {
            TextField("Name", text: $nameField)
            Button("Create Book") {
                let name = nameField
                Task { await readings.create(name: name.isEmpty ? "Untitled" : name, kind: .curated) }
            }
            Button("Create Smart Book") {
                let name = nameField
                Task { await readings.create(name: name.isEmpty ? "Untitled" : name, kind: .smart) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("A book holds a hand-picked, ordered post list; a smart book collects by filter.")
        }
        .alert(
            "Rename Book",
            isPresented: Binding(
                get: { renameTarget != nil },
                set: { if !$0 { renameTarget = nil } }),
            presenting: renameTarget
        ) { reading in
            TextField("Name", text: $nameField)
            Button("Rename") {
                let name = nameField
                Task { await readings.rename(reading.id, to: name) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(item: $manageTarget) { reading in
            ManageReadingPostsSheet(session: session, model: readings, reading: reading)
        }
        .sheet(item: $smartTarget) { reading in
            SmartSpecSheet(session: session, model: readings, reading: reading)
        }
        .sheet(item: $extentTarget) { reading in
            BookExtentSheet(model: model, reading: reading)
        }
        .overlay(alignment: .bottomLeading) {
            if let error = model.lastError ?? readings.lastError {
                Text(error)
                    .font(tokens.small)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding(6)
            }
        }
    }

    // MARK: - Header (the ls-line)

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(tokens.path(["Shelf"]))
                .font(tokens.heading)
                .foregroundStyle(tokens.accent)
            Text(tokens.chromeLabel(
                "· \(model.books.count) books · \(model.finishedCount) finished"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Spacer()
            Button(tokens.chromeLabel("Today's Entry")) { onTodaysEntry() }
                .buttonStyle(.borderless)
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
            Button(tokens.chromeLabel("+ New Book")) {
                nameField = ""
                createPresented = true
            }
            .buttonStyle(.borderless)
            .font(tokens.small)
            .foregroundStyle(tokens.accent)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 12)
    }

    // MARK: - Rows

    private func shelfRow(_ book: Queries.ShelfBook) -> some View {
        let reading = book.reading
        let pinned = model.pins.contains(reading.id)
        return Button {
            onOpen(.reading(reading.id))
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                HStack(spacing: 4) {
                    if pinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(tokens.faint)
                    }
                    Text(tokens.chromeLabel(reading.name) + (reading.locked ? " ✓" : ""))
                        .font(tokens.body.weight(.semibold))
                        .foregroundStyle(reading.locked ? tokens.accent : tokens.ink)
                }
                .frame(minWidth: 160, alignment: .leading)
                Text(model.tagsColumn(for: book).map { "#\($0)" }.joined(separator: " "))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent.opacity(0.85))
                    .lineLimit(1)
                Spacer(minLength: 12)
                Text(metaColumn(book))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // Drag a post onto the book (sitting 1) — the drop is the gesture.
        .onDrop(of: [.plainText], isTargeted: nil) { providers in
            for provider in providers {
                _ = provider.loadObject(ofClass: NSString.self) { value, _ in
                    guard let postID = value as? String else { return }
                    Task { @MainActor in await model.addPost(postID, to: reading.id) }
                }
            }
            return !providers.isEmpty
        }
        .contextMenu { bookMenu(book) }
    }

    private func metaColumn(_ book: Queries.ShelfBook) -> String {
        let reading = book.reading
        var parts: [String] = []
        if reading.locked {
            parts.append("finished")
        }
        if reading.kind == .smart {
            parts.append("smart")
        } else {
            parts.append("\(book.postCount) posts")
            if book.sectionCount > 0 { parts.append("\(book.sectionCount) ch") }
        }
        if let progress = model.progress(for: book) {
            parts.append("\(progress.percent)% of \(progress.target)w")
        } else if let words = model.wordCounts[reading.id], words > 0 {
            parts.append("\(words)w")
        }
        if let cap = reading.maxPosts { parts.append("cap \(cap)") }
        return tokens.chromeLabel(parts.joined(separator: " · "))
    }

    @ViewBuilder
    private func bookMenu(_ book: Queries.ShelfBook) -> some View {
        let reading = book.reading
        let pinned = model.pins.contains(reading.id)
        Button(pinned ? "Unpin from Shelf Top" : "Pin to Shelf Top") {
            Task { await model.setPinned(reading.id, pinned: !pinned) }
        }
        Button("Rename…") {
            nameField = reading.name
            renameTarget = reading
        }
        if reading.kind == .curated {
            Button("Manage Posts…") { manageTarget = reading }
        } else {
            Button("Edit Filter…") { smartTarget = reading }
        }
        Button("Length & Extent…") { extentTarget = reading }
        Divider()
        Button(reading.locked ? "Reopen" : "Finish") {
            Task { await model.setFinished(reading.id, finished: !reading.locked) }
        }
        Divider()
        Button("Export Markdown…") { ReadingExport.export(session: session, reading: reading, asPDF: false) }
        Button("Export PDF…") { ReadingExport.export(session: session, reading: reading, asPDF: true) }
        Divider()
        Button("Delete Book", role: .destructive) {
            Task { await readings.delete(reading.id) }
        }
    }

    // MARK: - Quick entry (R3)

    private var entryBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            Divider().overlay(tokens.line)
            Text(tokens.chromeLabel("new post — start typing · ⏎ opens it as a post"))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .padding(.top, 8)
            HStack(spacing: 2) {
                TextField("", text: $entryText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .focused($entryFocused)
                    .lineLimit(1...4)
                    .onSubmit { submitEntry() }
                if tokens.showsBlockCursor && entryText.isEmpty && !entryFocused {
                    Rectangle()
                        .fill(tokens.accent)
                        .frame(width: 8, height: 16)
                        .opacity(cursorOn ? 1 : 0)
                        .task {
                            while !Task.isCancelled {
                                try? await Task.sleep(for: .milliseconds(550))
                                cursorOn.toggle()
                            }
                        }
                }
                Spacer()
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal, 28)
        .background(tokens.card)
        .onTapGesture { entryFocused = true }
    }

    private func submitEntry() {
        let text = entryText
        entryText = ""
        Task {
            if let id = await model.quickEntry(text) {
                onOpen(.post(id))
            }
        }
    }

    private var hintBar: some View {
        HStack {
            Text(tokens.chromeLabel("⌘K — find anything: posts, books, commands"))
            Spacer()
            Text(tokens.chromeLabel("⌘J today · ⌘N new post"))
        }
        .font(tokens.small)
        .foregroundStyle(tokens.faint)
        .padding(.horizontal, 28)
        .padding(.vertical, 6)
        .background(tokens.room)
    }
}

/// The extent faces (word target / post cap — the machinery that existed
/// since v1 with "no UI face at all", plus v1_11's words unit).
struct BookExtentSheet: View {
    let model: ShelfViewModel
    let reading: Reading
    @State private var wordTargetField = ""
    @State private var maxPostsField = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Length & Extent — “\(reading.name)”").font(.headline)
            Text("A word target shows progress on the shelf; at its end, extend it or start a new book. The post cap refuses further adds when full. Blank clears.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Form {
                TextField("Word target (e.g. 10000)", text: $wordTargetField)
                TextField("Post cap (max posts)", text: $maxPostsField)
            }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") {
                    let target = Int(wordTargetField.trimmingCharacters(in: .whitespaces))
                    let cap = Int(maxPostsField.trimmingCharacters(in: .whitespaces))
                    Task {
                        await model.setWordTarget(reading.id, target: target)
                        await model.setMaxPosts(reading.id, maxPosts: cap)
                        dismiss()
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(minWidth: 380)
        .onAppear {
            wordTargetField = reading.wordTarget.map(String.init) ?? ""
            maxPostsField = reading.maxPosts.map(String.init) ?? ""
        }
    }
}

/// The shared reading-export door (moved out of the retired sidebar
/// section so the shelf and the book view share one shape).
enum ReadingExport {
    @MainActor
    static func export(session: AppSession, reading: Reading, asPDF: Bool) {
        let name = Queries.sanitizedFilename(reading.name)
        let base = name.isEmpty ? "Untitled" : name
        guard let url = ExportPanels.saveFile(
            defaultName: "\(base).\(asPDF ? "pdf" : "md")",
            type: asPDF ? .pdf : .markdownFile) else { return }
        Task {
            let exporter = ExportModel(session: session)
            if asPDF {
                if let data = await exporter.pdfData(forReading: reading.id) {
                    exporter.writePDF(data, to: url)
                }
            } else if let markdown = await exporter.markdown(forReading: reading.id) {
                exporter.writeMarkdown(markdown, to: url)
            }
        }
    }
}
