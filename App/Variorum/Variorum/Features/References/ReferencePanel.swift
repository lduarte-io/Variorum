//
//  ReferencePanel.swift
//  Variorum
//
//  Phase 11b, Step B3 — the reference panel (AppSpec §7, §12): per-post
//  sources beside the draft. PDFs render in PDFKit (page memory via
//  `view_state`; selected text DRAGS OUT and lands through the editor's
//  ordinary drop path — bulk entry, NO lineage edge: a reference is not a
//  block, so `derived_from` is impossible without a new edge class —
//  PROVISIONAL, QUESTIONS #20); other files render in Quick Look; URLs in
//  a read-only web pane or externally. EPUB/annotations/citations stay
//  permanently out of scope (the knowledge base this app refuses to be).
//  Functional, unstyled (Phase 13 owns beauty).
//

import AppKit
import PDFKit
import Quartz
import SwiftUI
import UniformTypeIdentifiers
import VariorumCore
import WebKit

struct ReferencePanel: View {
    @State private var model: ReferencesViewModel
    @State private var selectedID: String?
    @State private var urlField = ""

    init(session: AppSession, postID: String) {
        _model = State(initialValue: ReferencesViewModel(session: session, postID: postID))
    }

    private var selected: Reference? {
        model.references.first { $0.id == selectedID }
            ?? model.references.first
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                listing
            }
            .frame(maxHeight: 200)
            Divider()
            if let reference = selected {
                ReferencePreview(model: model, reference: reference)
                    .id(reference.id)
            } else {
                Text("Add a source file or URL — it renders beside the draft.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            if let error = model.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
        .task { await model.start() }
        .onDisappear { model.stopAllAccess() }
    }

    private var listing: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(model.references, id: \.id) { reference in
                HStack(spacing: 6) {
                    Image(systemName: reference.kind == .url ? "link" : "doc")
                        .foregroundStyle(.secondary)
                    Text(reference.name ?? reference.url ?? "reference")
                        .lineLimit(1)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture { selectedID = reference.id }
                .background(selected?.id == reference.id ? Color.accentColor.opacity(0.15) : .clear)
                .contextMenu {
                    Button("Move Up") { Task { await model.moveUp(reference.id) } }
                    Button("Move Down") { Task { await model.moveDown(reference.id) } }
                    if reference.kind == .url, let url = reference.url.flatMap(URL.init(string:)) {
                        Button("Open in Browser") { NSWorkspace.shared.open(url) }
                    }
                    Divider()
                    Button("Remove", role: .destructive) {
                        Task { await model.remove(reference.id) }
                    }
                }
            }
            HStack(spacing: 6) {
                TextField("Add URL…", text: $urlField)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        let value = urlField
                        urlField = ""
                        Task { await model.addURL(value) }
                    }
                Button("Add File…") { addFile() }
            }
            .font(.caption)
        }
        .padding(8)
    }

    /// The file door — an author-visible open panel; the grant it returns
    /// is what the security-scoped bookmark preserves across launches.
    private func addFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.prompt = "Add Reference"
        guard panel.runModal() == .OK else { return }
        let urls = panel.urls
        Task {
            for url in urls {
                await model.addFile(url)
            }
        }
    }
}

// MARK: - Previews per kind

private struct ReferencePreview: View {
    let model: ReferencesViewModel
    let reference: Reference

    var body: some View {
        switch reference.kind {
        case .url:
            if let url = reference.url.flatMap(URL.init(string:)) {
                WebPane(url: url)
            } else {
                unavailable("This URL can't be loaded.")
            }
        case .file:
            if let url = model.resolveFileURL(reference) {
                if url.pathExtension.lowercased() == "pdf" {
                    PDFPane(
                        url: url,
                        initialPage: model.viewState(reference).pdfPage
                    ) { page in
                        Task { await model.saveViewState(
                            reference.id, ReferenceViewState(pdfPage: page)) }
                    }
                } else {
                    QuickLookPane(url: url)
                }
            } else {
                unavailable("The file can't be found — it may have moved.")
            }
        }
    }

    private func unavailable(_ message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// PDFKit pane: page memory rides `view_state`; PDFView's built-in text
/// selection supports dragging OUT — the landing is the editor's ordinary
/// drop path (bulk entry / content edit), a gesture-style copy with NO
/// lineage edge (PROVISIONAL — QUESTIONS #20).
private struct PDFPane: NSViewRepresentable {
    let url: URL
    let initialPage: Int?
    let onPageChange: (Int) -> Void

    func makeNSView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.document = PDFDocument(url: url)
        if let initialPage, let page = view.document?.page(at: initialPage) {
            view.go(to: page)
        }
        context.coordinator.observe(view, onPageChange: onPageChange)
        return view
    }

    func updateNSView(_ view: PDFView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        // NotificationCenter's removeObserver is thread-safe; the token is
        // only written once (observe) and read in deinit.
        nonisolated(unsafe) private var observer: (any NSObjectProtocol)?

        func observe(_ view: PDFView, onPageChange: @escaping (Int) -> Void) {
            observer = NotificationCenter.default.addObserver(
                forName: .PDFViewPageChanged, object: view, queue: .main
            ) { notification in
                guard let view = notification.object as? PDFView,
                      let page = view.currentPage,
                      let index = view.document?.index(for: page) else { return }
                onPageChange(index)
            }
        }

        deinit {
            if let observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
}

/// Quick Look for everything that isn't a PDF or a URL.
private struct QuickLookPane: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> QLPreviewView {
        let view = QLPreviewView(frame: .zero, style: .normal) ?? QLPreviewView()
        view.previewItem = url as NSURL
        return view
    }

    func updateNSView(_ view: QLPreviewView, context: Context) {
        view.previewItem = url as NSURL
    }
}

/// Read-only web pane for URL references (§7: read-only WKWebView or
/// opened externally — the context menu carries "Open in Browser").
private struct WebPane: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.load(URLRequest(url: url))
        return view
    }

    func updateNSView(_ view: WKWebView, context: Context) {}
}
