//
//  AppSettingsView.swift
//  Variorum
//
//  Phase 13, B2 — the Settings window: APPEARANCE (the B1 global settings
//  — voice R1, seams R42, editing indicator R14/R22, inline comments R7,
//  follow-the-scroll R25, fan style) and TAGS (R52 — tag management's real
//  home: "if it's not in the sidebar it still needs to be somewhere":
//  create, adjust hierarchy, rename, delete; ⌘K-reachable; in-context
//  editing everywhere stands beside it). Promote-tag(s)-to-book (R30/R37)
//  lives here too — the manager is where you look at tags.
//

import GRDB  // AsyncValueObservation iteration (the ThemeStore pattern)
import SwiftUI
import VariorumCore

struct AppSettingsView: View {
    let session: AppSession
    @State private var theme: ThemeStore
    @State private var tags: TagsViewModel

    init(session: AppSession) {
        self.session = session
        _theme = State(initialValue: ThemeStore(session: session))
        _tags = State(initialValue: TagsViewModel(session: session))
    }

    var body: some View {
        TabView {
            AppearancePane(session: session, theme: theme)
                .tabItem { Label("Appearance", systemImage: "paintpalette") }
            TagManagerPane(session: session, tags: tags)
                .tabItem { Label("Tags", systemImage: "tag") }
        }
        .frame(width: 520, height: 440)
        .task { await theme.start() }
        .task { await tags.start() }
    }
}

// MARK: - Appearance (B1's settings, faced)

private struct AppearancePane: View {
    let session: AppSession
    let theme: ThemeStore
    /// 13b 4D (S4-19, her ruling): hover-revealed drag handles in Write —
    /// default ON; OFF = the fully clean surface. LOCAL (this Mac's
    /// UserDefaults, the takes-density class — deliberately not the synced
    /// setting table this batch; recorded).
    @AppStorage("writeHoverHandles") private var writeHoverHandles = true
    /// 13c 1E (memo Q3, option E — PROVISIONAL, QUESTIONS #39): the
    /// phantom fix's KILL SWITCH. Default ON so she can feel it before
    /// ruling on the posture; LOCAL like the hover-handle setting (this is
    /// one Mac's editor behaviour, not document semantics).
    @AppStorage(LongBlockLayout.settingKey) private var longBlockLayout = true
    /// 13d batch 4 (A23): the paragraph-gap choice. LOCAL like its two
    /// neighbours above — one Mac's editor look, not document semantics,
    /// and stored nowhere in the schema (no export/bridge byte moves).
    @AppStorage(ParagraphGap.settingKey) private var paragraphGap = ParagraphGap.standard
    /// 13d batch 4 (A24): spellcheck level, coarse by TEXTKIT2 §3's warning.
    @AppStorage(SpellcheckLevel.settingKey) private var spellcheck = SpellcheckLevel.off
    /// 13d batch 4 (A16): the DOCUMENT-GLOBAL segmentation default — the
    /// one setting on this pane that is synced, because it changes what
    /// entry DOES to the store rather than how one Mac looks.
    @State private var defaultSegmentation: Segmentation = .paragraph
    @State private var segmentationNote: String?

    var body: some View {
        Form {
            Section("Voice") {
                Picker("Design voice", selection: Binding(
                    get: { theme.settings.voice },
                    set: { theme.setVoice($0) })) {
                    Text("Terminal").tag(ThemeVoice.terminal)
                    Text("Study").tag(ThemeVoice.study)
                }
                .pickerStyle(.segmented)
                Text("Two voices, one structure: Terminal is mono and airy with its own idioms; Study is the warm paper-and-serif look. Everything works identically in both.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("Editor") {
                Toggle("Show block seams (dotted lines between blocks)", isOn: Binding(
                    get: { theme.settings.seamsVisible },
                    set: { theme.setSeamsVisible($0) }))
                Picker("Mark the block being edited", selection: Binding(
                    get: { theme.settings.editingIndicator },
                    set: { theme.setEditingIndicator($0) })) {
                    Text("Off — the cursor is enough").tag(EditingIndicatorStyle.off)
                    Text("Outline ring").tag(EditingIndicatorStyle.outline)
                    Text("Background").tag(EditingIndicatorStyle.background)
                }
                Toggle("Show comments inline (tinted, under the block)", isOn: Binding(
                    get: { theme.settings.inlineComments },
                    set: { theme.setInlineComments($0) }))
                Toggle("Show the block drag handle on hover (Write)", isOn: $writeHoverHandles)
                Text("ON: pointing at a block in Write reveals its ⠿ drag handle in the left margin. OFF: the fully clean writing surface. With block seams shown (⌘⇧B), every handle shows regardless. This Mac only.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Toggle("Lay out very long blocks as you reach them", isOn: $longBlockLayout)
                Text("ON: when you scroll near a very long block, Variorum asks the text system to measure that one block properly — which removes the empty space it was guessing at underneath. It happens once per block, only for blocks over about a long-paragraph's length and under a measured size cap, and never while you are actually scrolling. OFF: the text system's own estimate stands, and long blocks can show phantom space that vanishes when you scroll onto them. This Mac only.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Toggle("Takes follow the scroll", isOn: Binding(
                    get: { theme.settings.followTheScroll },
                    set: { theme.setFollowTheScroll($0) }))
                Picker("Takes open as", selection: Binding(
                    get: { theme.settings.fanStyle },
                    set: { theme.setFanStyle($0) })) {
                    Text("Stack").tag(FanStyle.stack)
                    Text("Carousel").tag(FanStyle.carousel)
                    Text("Margin grid").tag(FanStyle.marginGrid)
                    Text("Slot split").tag(FanStyle.slotSplit)
                }
                // 13d batch 4 (A23): the paragraph gap. Pure presentation
                // over the 2026-07-12 ruling's presentation half — uniform
                // and per-PARAGRAPH, never per-seam (§12: boundaries stay
                // invisible at rest).
                Picker("Space between paragraphs", selection: $paragraphGap) {
                    Text("Standard").tag(ParagraphGap.standard)
                    Text("A blank line's worth").tag(ParagraphGap.paragraphTall)
                }
                Text("Air after every paragraph — inside a block and between blocks alike, so block boundaries stay invisible at rest. Purely how it looks: nothing is stored, and exports are byte-identical either way. This Mac only.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                // 13d batch 4 (A24): coarse by design — TEXTKIT2 §3 records
                // continuous checking + the completion popover crashing
                // NSTextView, so three levels and no finer.
                Picker("Spellchecking", selection: $spellcheck) {
                    Text("Off").tag(SpellcheckLevel.off)
                    Text("Check while typing").tag(SpellcheckLevel.checkWhileTyping)
                    Text("Check and correct").tag(SpellcheckLevel.checkAndCorrect)
                }
                Text("Off (the default): no underlines; Edit ▸ Spelling and Grammar still checks on demand. Check while typing: red underlines as you go. Check and correct: macOS also fixes what it is confident about. Applies to every writing surface — Write, takes, comparisons. This Mac only.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            // 13d batch 4 (A16 — N34's deferred GLOBAL half): document
            // semantics, so it is SYNCED, and it says so. Per-post settings
            // still win where they are set.
            Section("Writing") {
                Picker(SegmentationFaceCopy.globalTitle, selection: Binding(
                    get: { defaultSegmentation },
                    set: { setDefaultSegmentation($0) })) {
                    Text(SegmentationFaceCopy.globalParagraph).tag(Segmentation.paragraph)
                    Text(SegmentationFaceCopy.globalOneBlock).tag(Segmentation.oneBlock)
                }
                Text(SegmentationFaceCopy.globalHelp)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let segmentationNote {
                    Text(segmentationNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .formStyle(.grouped)
        .padding(8)
        // A tiny bounded observation over the `setting` table (the
        // ThemeStore pattern) — so a change made on another device shows
        // here, and the picker never drifts from the store.
        .task {
            do {
                for try await value in session.database.observe({ db in
                    try Queries.defaultSegmentation(db)
                }) {
                    defaultSegmentation = value
                }
            } catch {}
        }
    }

    /// The write goes through the runner like every other setting write
    /// (the ThemeStore setters' shape); the observation above carries the
    /// new value back, so the picker never holds an optimistic guess.
    private func setDefaultSegmentation(_ segmentation: Segmentation) {
        guard segmentation != defaultSegmentation else { return }
        segmentationNote = segmentation == .oneBlock
            ? SegmentationFaceCopy.globalMintOffNote
            : SegmentationFaceCopy.globalMintOnNote
        Task {
            do {
                try await session.runner.run { try $0.setDefaultSegmentation(segmentation) }
            } catch {
                // Readable words, never the raw enum dump (the R1-3 class —
                // 13d cold review, F-9).
                segmentationNote = OpsRefusalCopy.message(for: error)
            }
        }
    }
}

// MARK: - The tag manager (R52)

private struct TagManagerPane: View {
    let session: AppSession
    let tags: TagsViewModel
    @State private var newTagParent: String?
    @State private var newTagSheet = false
    @State private var renameTarget: Tag?
    @State private var nameField = ""
    @State private var promoteTags: Set<String> = []
    @State private var promoteSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            List {
                ForEach(tags.tags, id: \.id) { tag in
                    HStack {
                        Toggle("", isOn: Binding(
                            get: { promoteTags.contains(tag.path) },
                            set: { on in
                                if on { promoteTags.insert(tag.path) } else { promoteTags.remove(tag.path) }
                            }))
                        .labelsHidden()
                        .toggleStyle(.checkbox)
                        Text(String(repeating: "    ", count: tags.depth(of: tag)) + tag.name)
                        Text(tag.path)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .contextMenu {
                        Button("New Child Tag…") {
                            newTagParent = tag.id
                            nameField = ""
                            newTagSheet = true
                        }
                        Button("Rename…") {
                            nameField = tag.name
                            renameTarget = tag
                        }
                        Divider()
                        Button("Delete (with subtree)", role: .destructive) {
                            Task { await tags.deleteTag(tag.id) }
                        }
                    }
                }
                if tags.tags.isEmpty {
                    Text("No tags yet.").foregroundStyle(.secondary)
                }
            }
            HStack {
                Button("New Tag…") {
                    newTagParent = nil
                    nameField = ""
                    newTagSheet = true
                }
                Spacer()
                // R30/R37: promote one or SEVERAL tags to a saved book —
                // AND-joined or OR-joined; the tags stay on the posts.
                Button("Promote to Book…") { promoteSheet = true }
                    .disabled(promoteTags.isEmpty)
            }
            if let error = tags.lastError {
                Text(error).font(.caption).foregroundStyle(.red)
            }
        }
        .padding(12)
        .alert(newTagParent == nil ? "New Tag" : "New Child Tag", isPresented: $newTagSheet) {
            TextField("Name", text: $nameField)
            Button("Create") {
                let name = nameField
                let parent = newTagParent
                Task { await tags.createTag(parentID: parent, name: name) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert(
            "Rename Tag",
            isPresented: Binding(
                get: { renameTarget != nil },
                set: { if !$0 { renameTarget = nil } }),
            presenting: renameTarget
        ) { tag in
            TextField("Name", text: $nameField)
            Button("Rename") {
                let name = nameField
                Task { await tags.renameTag(tag.id, to: name) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $promoteSheet) {
            PromoteTagsSheet(session: session, tagPaths: promoteTags.sorted())
        }
    }
}

/// R30's face: tags → a saved SMART book on the shelf. AND-joined
/// (`tagsAll`) or OR-joined (`tags`); the promotion LEAVES the tags on the
/// posts (R37 — trivially: nothing here touches applications).
struct PromoteTagsSheet: View {
    let session: AppSession
    let tagPaths: [String]
    @State private var name = ""
    @State private var joinAll = false
    @State private var error: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Promote to Book").font(.headline)
            Text("Creates a smart book on the shelf collecting notes by these tags. The tags stay on the notes.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(tagPaths.map { "#\($0)" }.joined(separator: "  "))
                .font(.callout)
            TextField("Book name", text: $name)
            if tagPaths.count > 1 {
                Picker("Notes must carry", selection: $joinAll) {
                    Text("any of these tags (OR)").tag(false)
                    Text("all of these tags (AND)").tag(true)
                }
                .pickerStyle(.radioGroup)
            }
            if let error {
                Text(error).font(.caption).foregroundStyle(.red)
            }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Create Book") { promote() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(16)
        .frame(minWidth: 380)
    }

    /// The spec construction is the whole promotion (pinned in
    /// `ShelfAndPaletteTests`): OR → `tags`, AND → `tagsAll` (R30's letter,
    /// the A2 vocabulary).
    static func spec(paths: [String], joinAll: Bool) -> Queries.SmartQuerySpec {
        joinAll
            ? Queries.SmartQuerySpec(tagsAll: paths)
            : Queries.SmartQuerySpec(tags: paths)
    }

    private func promote() {
        let bookName = name.trimmingCharacters(in: .whitespaces)
        let paths = tagPaths
        let all = joinAll
        Task {
            do {
                _ = try await session.runner.run { ops in
                    try ops.createReading(
                        name: bookName, kind: .smart,
                        querySpec: try Self.spec(paths: paths, joinAll: all).encodedJSON())
                }
                dismiss()
            } catch {
                self.error = String(describing: error)
            }
        }
    }
}
