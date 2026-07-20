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

    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    @State private var createPresented = false
    @State private var nameField = ""
    @State private var renameTarget: Reading?
    @State private var manageTarget: Reading?
    @State private var smartTarget: Reading?
    @State private var extentTarget: Reading?
    /// Batch 9 (R102): the list region hugs its content, so the
    /// quick-entry bar rides RIGHT BELOW the rows — the round-2 mockup's
    /// geometry at every window size ("the start new post typing isn't
    /// high up"). On a shelf taller than the window the region fills the
    /// window and the bar stays pinned above the fold, exactly as R3
    /// ruled.
    @State private var listContentHeight: CGFloat = 0

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

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
                .onGeometryChange(for: CGFloat.self, of: { $0.size.height }) {
                    listContentHeight = $0
                }
            }
            .frame(maxHeight: listContentHeight > 0 ? listContentHeight : nil, alignment: .top)
            entryBar
            // Batch 14: the ⌘k advice bar rides the WINDOW BOTTOM (her
            // ask); the entry box stays high with the list.
            Spacer(minLength: 0)
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
            // §14 item 10's "starting a 'new' journal as a separate
            // notebook" — a journal-profile book (dated, one entry after
            // another; round 2's re-designation door pairs with it).
            Button("Create Journal Book") {
                let name = nameField
                Task {
                    await readings.create(
                        name: name.isEmpty ? "Untitled Journal" : name,
                        kind: .curated, profile: "journal",
                        sortField: .entryDate, sortDir: .asc)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("A book holds a hand-picked, ordered post list; a smart book collects by filter; a journal book holds dated entries.")
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
                    .lineLimit(4)
                    .padding(6)
            } else if let report = model.lastReport {
                // R98's report half — informative, never red.
                Text(tokens.chromeLabel(report))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .textSelection(.enabled)
                    .lineLimit(3)
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
        if reading.kind == .curated, reading.profile == "journal" {
            // Round 2, MAJOR 2's re-designation door: finishing a bounded
            // daily journal is the EXPECTED flow — this is where the next
            // one takes over.
            Button("Use as Daily Journal") {
                Task { await model.designateDailyJournal(reading.id) }
            }
        }
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

    // MARK: - Quick entry (R3 — the shared bar; Library carries it too)

    private var entryBar: some View {
        // Batch 14: the dashed box floats under the list — no divider,
        // like the round-1 mockup she attached.
        QuickEntryBar(session: session, onOpen: onOpen, autofocus: true)
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

/// Extent-field parsing, ONE implementation for both sheets (round 2,
/// MINOR): empty = CLEAR, digits = a value, anything else = INVALID —
/// refuse and KEEP; a typo while editing must never silently delete a
/// stored extent (`Int("10k")` was nil, and nil meant clear).
enum ExtentInput: Equatable {
    case clear
    case value(Int)

    static func parse(_ field: String) -> ExtentInput? {
        let trimmed = field.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return .clear }
        guard let value = Int(trimmed) else { return nil }
        return .value(value)
    }

    var intValue: Int? {
        if case .value(let value) = self { return value }
        return nil
    }
}

/// The extent faces (word target / post cap — the machinery that existed
/// since v1 with "no UI face at all", plus v1_11's words unit).
struct BookExtentSheet: View {
    let model: ShelfViewModel
    let reading: Reading
    @State private var wordTargetField = ""
    @State private var maxPostsField = ""
    @State private var parseError: String?
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
            if let parseError {
                Text(parseError).font(.caption).foregroundStyle(.red)
            }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") {
                    guard let target = ExtentInput.parse(wordTargetField),
                          let cap = ExtentInput.parse(maxPostsField)
                    else {
                        parseError = "Extents are plain numbers (e.g. 10000) — nothing was changed."
                        return
                    }
                    Task {
                        await model.setWordTarget(reading.id, target: target.intValue)
                        await model.setMaxPosts(reading.id, maxPosts: cap.intValue)
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
