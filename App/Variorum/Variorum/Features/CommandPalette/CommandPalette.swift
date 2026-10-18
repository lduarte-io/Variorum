//
//  CommandPalette.swift
//  Variorum
//
//  Phase 13, B2 — ⌘K (R15, ratified: "every buried capability should
//  absolutely be typeable and shortcutable"): one keystroke that searches
//  everything the app can do — posts, books, blocks (the catalog query)
//  and COMMANDS (the buried capabilities: recovery, tutorial, settings,
//  voice/seam toggles, the export/import doors). The legibility mandate's
//  concrete mechanism (R10).
//

import Foundation
import Observation
import SwiftUI
import VariorumCore

/// One executable palette row.
struct PaletteItem: Identifiable, Equatable {
    enum Kind: Equatable {
        case command
        case book
        case post
        case block
        /// 13o U2 (D7): a body hit — a passage of a note or a scrap, under
        /// the title hits, landing AT its match (D6).
        case passage
        /// 13o U2 (D7): the road to the rest — the Library's answer sheet on
        /// the same words (R-13o-9: no capped listing without a road).
        case allMatches
    }
    let id: String
    let kind: Kind
    let title: String
    let detail: String?
    /// VX-351 (the VX-348 run, U4 — her R-VX348-3): a note row's stated day
    /// hovers its whole fact (*Dated Oct 13, 2026*); nil on every other row.
    var detailHelp: String? = nil
    /// Block rows: the home container to open (round 2, MINOR — a block
    /// hit must NAVIGATE; caret-precise landing is Stage C's).
    var homeContainerID: String?
    var homeIsPool = false
    /// Passage rows (13o U2): the block the passage lives on and the find
    /// seed it lands with (`SearchLanding.findSeed`'s rule).
    var blockID: String?
    var find: EditorFindSeed?
    /// The all-matches row (13o U2): the words it carries to the Library.
    var words: String?

    static func == (lhs: PaletteItem, rhs: PaletteItem) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
@Observable
final class PaletteModel {
    @ObservationIgnored let session: AppSession
    /// The command vocabulary — injected by the shell (actions live in
    /// composition; the palette only lists and picks).
    @ObservationIgnored var commands: [(title: String, action: @MainActor () -> Void)] = []

    /// Set by the view's binding, which also spawns `refresh()` — no
    /// hidden didSet task, so tests drive the model deterministically and
    /// the generation guard only has the UI's unordered tasks to order.
    var query = ""
    private(set) var items: [PaletteItem] = []
    /// Generation-stamped adoption (round 2, MINOR — the Phase 8 ruling).
    private var generation = 0

    /// 13b Stage 3, 3E (N11): keyboard row-stepping. The › marker sits on
    /// the SELECTED row (not always the first), ↓/↑ move it, ⏎ runs it.
    /// Every refresh resets to the top (a new query is a new list — the
    /// pre-N11 ⏎-runs-first behavior is the selection's DEFAULT, no longer
    /// its only truth).
    private(set) var selectedIndex = 0

    var selectedItem: PaletteItem? {
        items.indices.contains(selectedIndex) ? items[selectedIndex] : nil
    }

    func moveSelection(by delta: Int) {
        guard !items.isEmpty else { return }
        selectedIndex = min(max(selectedIndex + delta, 0), items.count - 1)
    }

    init(session: AppSession) {
        self.session = session
    }

    func refresh() async {
        generation += 1
        let mine = generation
        let trimmed = query.trimmingCharacters(in: .whitespaces).lowercased()
        var result: [PaletteItem] = []
        // Commands first — matching ones only once a query exists.
        for (index, command) in commands.enumerated() {
            if trimmed.isEmpty || command.title.lowercased().contains(trimmed) {
                result.append(PaletteItem(
                    id: "command-\(index)", kind: .command,
                    title: command.title, detail: nil))
            }
        }
        let query = query
        // 13i-d U5: ⌘K searches the CURRENT WING (§9).
        let wing = session.wing.currentID
        // 13o U2 (D7): the body search rides the same read — the one AST
        // (R-13o-8), a bounded few passages under the title hits.
        let asked = Self.passageQuestion(query)
        let (hits, passages) = (try? await session.database.read { db in
            (try Queries.searchCatalog(db, query: query, limitPerKind: 12, wingID: wing),
             // The body hits never cost the title hits: a failed passage read
             // answers none, and the catalog's rows still land.
             asked.flatMap {
                 try? Queries.searchPassages(
                     db, query: $0, scope: SearchScope(wingID: wing),
                     limit: Self.passageCount).passages
             } ?? [])
        }) ?? ([], [])
        guard mine == generation else { return }  // a newer keystroke won
        result += hits.map { hit in
            PaletteItem(
                id: "\(hit.kind)-\(hit.id)",
                kind: hit.kind == .book ? .book : (hit.kind == .post ? .post : .block),
                title: hit.title, detail: hit.detail,
                detailHelp: hit.kind == .post ? TimeStampFace.tooltip(.dated, day: hit.detail) : nil,
                homeContainerID: hit.homeContainerID, homeIsPool: hit.homeIsPool)
        }
        result += passages.compactMap(Self.passageItem)
        if asked != nil {
            // R-13o-9's letter: the few above are never the end of the road.
            result.append(PaletteItem(
                id: "all-matches", kind: .allMatches,
                title: CommandPaletteCopy.allMatches, detail: nil,
                // As typed (untrimmed): the Library reads the SAME question —
                // a word still being typed stays the same prefix there.
                words: query))
        }
        items = result
        selectedIndex = 0  // N11: a fresh list selects its top row
    }

    // MARK: - 13o U2 (D7) — the body hits

    /// How many passages ⌘K shows under its title hits (D7 — "a bounded few").
    nonisolated static let passageCount = 5

    /// The palette's question for the index: the field's words through the
    /// one v1 grammar (R-13o-8), the passages that are BODY hits — never a
    /// title (the note row above already says it) and never a book's name
    /// (the book row does). nil without words.
    nonisolated static func passageQuestion(_ text: String) -> SearchQuery? {
        var query = SearchQueryParser.parse(text)
        guard query.text != nil else { return nil }
        let body: SearchFilter = .all([.not(.docKind(.title)), .not(.family(.books))])
        query.filter = query.filter.map { .all([$0, body]) } ?? body
        return query
    }

    /// A passage as a palette row — its words, its home, its landing (D6).
    nonisolated static func passageItem(_ passage: SearchPassage) -> PaletteItem? {
        guard let home = passage.noteID, passage.kind != .wornDay else { return nil }
        let words = passage.snippet.map(\.text).joined()
        return PaletteItem(
            id: "passage-\(passage.id)", kind: .passage,
            title: words.isEmpty ? passage.homeTitle : words,
            detail: CommandPaletteCopy.passageHome(passage.homeTitle),
            homeContainerID: home, homeIsPool: passage.family == .scraps,
            blockID: passage.blockID,
            find: SearchLanding.findSeed(
                kind: passage.kind, rendered: passage.isRenderedTake, snippet: passage.snippet))
    }

    /// Executes a row. Block hits carry their block ID beside the home
    /// selection (Stage C: the caret lands ON the block, not just in the
    /// right post — the round-2 MINOR's recorded remainder).
    ///
    /// 13o U2 (D7): a PASSAGE lands at its match through `onLand` (the
    /// shell's block landing with its find seed — D6), falling back to the
    /// block landing; the ALL-MATCHES row hands its words to
    /// `onSearchLibrary` (the Library's answer sheet on the same question).
    func execute(
        _ item: PaletteItem,
        onOpen: (SidebarSelection, _ blockID: String?) -> Void,
        onLand: ((SidebarSelection, _ blockID: String, EditorFindSeed?) -> Void)? = nil,
        onSearchLibrary: ((String) -> Void)? = nil
    ) {
        switch item.kind {
        case .passage:
            guard let home = item.homeContainerID else { return }
            let selection: SidebarSelection = item.homeIsPool ? .pool(home) : .post(home)
            if let block = item.blockID, let onLand {
                onLand(selection, block, item.find)
            } else {
                onOpen(selection, item.blockID)
            }
        case .allMatches:
            if let words = item.words { onSearchLibrary?(words) }
        case .command:
            if let index = Int(item.id.dropFirst("command-".count)),
               commands.indices.contains(index) {
                commands[index].action()
            }
        case .book:
            onOpen(.reading(String(item.id.dropFirst("book-".count))), nil)
        case .post:
            onOpen(.post(String(item.id.dropFirst("post-".count))), nil)
        case .block:
            // A block opens its HOME surface with the caret seeded at the
            // block itself (fire-and-speak on the legibility surface).
            if let home = item.homeContainerID {
                onOpen(
                    item.homeIsPool ? .pool(home) : .post(home),
                    String(item.id.dropFirst("block-".count)))
            }
        }
    }
}

struct CommandPaletteView: View {
    let model: PaletteModel
    let onOpen: (SidebarSelection, _ blockID: String?) -> Void
    /// 13o U2 (D7): a passage's landing at its match, and the all-matches
    /// road — the shell's (nil in a harness: a passage falls back to its
    /// block landing, the road does nothing).
    var onLand: ((SidebarSelection, String, EditorFindSeed?) -> Void)? = nil
    var onSearchLibrary: ((String) -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @FocusState private var fieldFocused: Bool

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField(tokens.chromeLabel("Find anything — notes, books, commands…"),
                      text: Binding(get: { model.query }, set: { value in
                          model.query = value
                          Task { await model.refresh() }
                      }))
                .textFieldStyle(.plain)
                .font(tokens.body)
                .padding(12)
                .focused($fieldFocused)
                // 13b 3E (N11): ↓/↑ step the › marker through the rows
                // while the field keeps the keyboard; ⏎ runs the SELECTED
                // row (the field's caret never needed the arrows — this is
                // a one-line list navigator, the ⌘K grammar everywhere).
                .onKeyPress(.downArrow) {
                    model.moveSelection(by: 1)
                    return .handled
                }
                .onKeyPress(.upArrow) {
                    model.moveSelection(by: -1)
                    return .handled
                }
                .onSubmit {
                    if let selected = model.selectedItem {
                        model.execute(
                            selected, onOpen: { selection, blockID in onOpen(selection, blockID) },
                            onLand: onLand, onSearchLibrary: onSearchLibrary)
                        dismiss()
                    }
                }
            Divider().overlay(tokens.line)
            List(model.items) { item in
                Button {
                    model.execute(
                        item, onOpen: { selection, blockID in onOpen(selection, blockID) },
                        onLand: onLand, onSearchLibrary: onSearchLibrary)
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        // N11 (13b 3E): ⏎ runs the SELECTED row — the ›
                        // marker rides the selection, moved by ↓/↑.
                        Text(item.id == model.selectedItem?.id
                            ? tokens.selectionMarker.trimmingCharacters(in: .whitespaces)
                            : " ")
                            .font(tokens.body.weight(.bold))
                            .foregroundStyle(tokens.accent)
                            .frame(width: 10)
                        Image(systemName: icon(for: item.kind))
                            .foregroundStyle(tokens.muted)
                            .frame(width: 16)
                        Text(item.title)
                            .font(item.kind == .passage ? tokens.small : tokens.body)
                            .foregroundStyle(item.kind == .allMatches ? tokens.accent : tokens.ink)
                            .lineLimit(1)
                        if let detail = item.detail {
                            Text(tokens.chromeLabel(detail))
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                                .stampHelp(item.detailHelp)  // VX-351
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .frame(minHeight: 260, maxHeight: 340)
        }
        .frame(width: 560)
        .background(tokens.card)
        .task {
            model.query = ""
            await model.refresh()
            fieldFocused = true
        }
    }

    private func icon(for kind: PaletteItem.Kind) -> String {
        switch kind {
        case .command: "command"
        case .book: "book"
        case .post: "doc.text"
        case .block: "square.on.square"
        case .passage: "text.quote"
        case .allMatches: "magnifyingglass"
        }
    }
}

/// What the palette's 13o rows say (one place — F-0).
nonisolated enum CommandPaletteCopy {
    /// The road row (PROVISIONAL P-13o-U2-5).
    static let allMatches = "All matches in the Library \u{203A}"
    /// A passage row's home.
    static func passageHome(_ title: String) -> String { "in \(title)" }
}
