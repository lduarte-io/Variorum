//
//  BookIndexGrouping.swift
//  Variorum (Mac)
//
//  13i-d U3 — **THE GROUPED-BY CONTROL** on the book Index's masthead (the
//  sitting record §16(f)/§17(f), ruled: *"the `grouped by` control lives on
//  the Index masthead … chapters ▾ · a tag family… · none; view-local; a
//  gathering's Index the same minus chapters"*) and **the tag-family grouped
//  DISPLAY** (§3: a gathering's capabilities include "the tag-family grouped
//  DISPLAY (never real chapters)").
//
//  What it is:
//  - A WAY OF LOOKING, never the book. Choosing a grouping writes NOTHING —
//    no `reading_section` row, no setting, no outbox row (pinned). The choice
//    is REMEMBERED per book in a LOCAL store (`UserDefaults`, injected — the
//    `BookcasePrefs` precedent and its reason: the test host is the Debug app).
//  - Never chosen ⇒ the SHIPPED look, exactly (chapters where a book has them,
//    else the stored grouping tag's runs, else flat) — so every pin and every
//    book that never touched the control sees byte-identical rows.
//  - A TAG FAMILY PARTITIONS the shown notes: one heading per child tag of
//    the family root (A–Z by path), each note under the lexically smallest
//    child it wears — `assembleReading`'s own rule, now ONE SQL fragment
//    both read (`Queries.tagFamilySectionSelect`) — the book's order inside
//    each group, and the rest trailing under "no #family" (PROVISIONAL
//    P-13id-U3-4; chapters' "unfiled" convention).
//  - The regroup changes only the Index's ROW LIST — headings and order. Every
//    pane row keeps its anchor (`bip-<postID>`) and its manifest height; a new
//    heading is a new anchor standing at the heading's constant height. The
//    landing machinery and the one live pane are untouched.
//
//  Cost (P1): ONE held observation per open Index, over `post_tag` + `tag`
//  only (`Queries.tagsWorn`, `Queries.allTags`, and — while a family is
//  chosen — `Queries.tagFamilySections`), each ∝ the Index's window; a
//  keystroke's autosave never wakes it (pinned by region in core). It serves
//  the families menu AND the filter bar's tag menu.
//

import Foundation
import GRDB
import Observation
import SwiftUI
import VariorumCore

// MARK: - The choice (view-local, remembered)

nonisolated enum BookIndexGrouping: Equatable, Hashable, Sendable {
    /// The book's real chapters (a book with live chapters only).
    case chapters
    /// A tag family — the ROOT tag's id; its children are the headings.
    case tagFamily(String)
    /// One flat run, no headings.
    case none

    /// The local store's spelling.
    var stored: String {
        switch self {
        case .chapters: "chapters"
        case .none: "none"
        case .tagFamily(let id): "tag:" + id
        }
    }

    init?(stored: String) {
        switch stored {
        case "chapters": self = .chapters
        case "none": self = .none
        default:
            guard stored.hasPrefix("tag:"), stored.count > 4 else { return nil }
            self = .tagFamily(String(stored.dropFirst(4)))
        }
    }
}

/// The per-book memory. `UserDefaults` INJECTED (the app passes `.standard`,
/// every pin a scratch suite).
struct BookIndexGroupingPrefs {
    let defaults: UserDefaults

    private static func key(_ readingID: String) -> String { "bookIndex.grouping." + readingID }

    func choice(for readingID: String) -> BookIndexGrouping? {
        defaults.string(forKey: Self.key(readingID)).flatMap(BookIndexGrouping.init(stored:))
    }

    func setChoice(_ choice: BookIndexGrouping, for readingID: String) {
        defaults.set(choice.stored, forKey: Self.key(readingID))
    }
}

// MARK: - The words

/// Every word the control says. Wording PROVISIONAL (13s re-voices).
nonisolated enum BookIndexGroupingCopy {
    static let label = "group"
    static let chapters = "chapters"
    static let none = "none"
    static let familiesHeader = "a tag family"
    static func family(_ path: String) -> String { "#" + path }
    /// The trailing group's heading — the notes under no child of the family.
    static func ungrouped(_ familyPath: String) -> String { "no #" + familyPath }
    static let noFamilies = "no tag families in this book's notes"
    static let help =
        "Group this Index by the book's chapters, by a tag family, or not at all \u{2014} a way "
        + "of looking: nothing is written, and the book's own chapters are untouched."
}

// MARK: - The pure brain

nonisolated enum BookIndexGroupingBrain {
    /// What the Index groups by, resolved against the book in hand.
    enum Resolved: Equatable {
        /// Never chosen (or a choice that cannot apply): the shipped look.
        case shipped
        case chapters
        case tagFamily(VariorumCore.Tag)
        case none
    }

    /// **The families on offer:** every live tag of the book's wing that is a
    /// PROPER ANCESTOR of a tag the shown notes wear — exactly the roots under
    /// which some shown note files (a family nobody here wears would file
    /// every note under "no #…"). By path.
    static func families(
        worn: [VariorumCore.Tag], live: [VariorumCore.Tag], wingID: String
    ) -> [VariorumCore.Tag] {
        let wornPaths = worn.filter { $0.wingId == wingID }.map(\.path)
        return live
            .filter { tag in
                tag.wingId == wingID
                    && wornPaths.contains { $0.hasPrefix(tag.path + "/") }
            }
            .sorted { $0.path == $1.path ? $0.id < $1.id : $0.path < $1.path }
    }

    /// The choice, resolved: a choice that cannot apply here falls back to
    /// the shipped look rather than drawing a wrong one (chapters on a book
    /// with none or on a gathering; a family whose root died or left the wing).
    static func resolve(
        choice: BookIndexGrouping?, chaptersActive: Bool,
        live: [VariorumCore.Tag], wingID: String
    ) -> Resolved {
        switch choice {
        case nil:
            return .shipped
        case .chapters?:
            return chaptersActive ? .chapters : .shipped
        case .none?:
            return .none
        case .tagFamily(let id)?:
            guard let root = live.first(where: { $0.id == id && $0.wingId == wingID })
            else { return .shipped }
            return .tagFamily(root)
        }
    }

    /// The menu's choices for this book, in order: chapters (a book with live
    /// chapters — a gathering's Index "the same minus chapters", §17(f)), the
    /// families, none.
    static func options(
        chaptersActive: Bool, families: [VariorumCore.Tag]
    ) -> [BookIndexGrouping] {
        (chaptersActive ? [.chapters] : []) + families.map { .tagFamily($0.id) } + [.none]
    }

    /// **The family partition** — one group per child path present (A–Z),
    /// the book's order kept inside each, the rest trailing under "no #…".
    static func groups(
        entries: [Queries.ReadingEntry], sections: [String: String],
        family: VariorumCore.Tag
    ) -> [BookIndexColumn.Group] {
        var byChild: [String: [Queries.ReadingEntry]] = [:]
        var rest: [Queries.ReadingEntry] = []
        for entry in entries {
            if let child = sections[entry.postID] {
                byChild[child, default: []].append(entry)
            } else {
                rest.append(entry)
            }
        }
        var result = byChild.keys.sorted().map { child in
            BookIndexColumn.Group(
                id: "fam:" + child, title: BookIndexGroupingCopy.family(child),
                entries: byChild[child] ?? [])
        }
        if !rest.isEmpty {
            result.append(BookIndexColumn.Group(
                id: "fam-none", title: BookIndexGroupingCopy.ungrouped(family.path),
                entries: rest))
        }
        return result
    }

    /// "none": one flat run, no headings (an empty book draws nothing).
    static func flat(_ entries: [Queries.ReadingEntry]) -> [BookIndexColumn.Group] {
        entries.isEmpty ? [] : [BookIndexColumn.Group(id: "run:0", title: nil, entries: entries)]
    }

    /// The OPTION that is in force — the menu's checkmark (the shipped look
    /// names its own: chapters, the stored grouping tag, or none).
    static func current(
        _ resolved: Resolved, chaptersActive: Bool, storedGroupingID: String?
    ) -> BookIndexGrouping {
        switch resolved {
        case .chapters: return .chapters
        case .none: return .none
        case .tagFamily(let tag): return .tagFamily(tag.id)
        case .shipped:
            if chaptersActive { return .chapters }
            if let storedGroupingID { return .tagFamily(storedGroupingID) }
            return .none
        }
    }

    /// The control's label for what is IN FORCE (the shipped look names
    /// itself too: chapters, the stored grouping tag, or none).
    static func label(
        _ resolved: Resolved, chaptersActive: Bool, storedGroupingPath: String?
    ) -> String {
        switch resolved {
        case .chapters: return BookIndexGroupingCopy.chapters
        case .none: return BookIndexGroupingCopy.none
        case .tagFamily(let tag): return BookIndexGroupingCopy.family(tag.path)
        case .shipped:
            if chaptersActive { return BookIndexGroupingCopy.chapters }
            if let storedGroupingPath { return BookIndexGroupingCopy.family(storedGroupingPath) }
            return BookIndexGroupingCopy.none
        }
    }
}

// MARK: - The model

/// The Index's grouping state for ONE book: the remembered choice and the one
/// held read the control and the filter bar consume. Holds ids and
/// projections; writes nothing to the store, ever.
@MainActor
@Observable
final class BookIndexGroupingModel {
    let readingID: String
    @ObservationIgnored private let prefs: BookIndexGroupingPrefs
    private(set) var choice: BookIndexGrouping?
    /// The live tags the tracked notes wear (the families' source; the
    /// filter bar's tag menu).
    private(set) var worn: [VariorumCore.Tag] = []
    /// Every live tag (author-scale) — resolves a chosen family's root.
    private(set) var live: [VariorumCore.Tag] = []
    /// Where each tracked note files under the CHOSEN family, and that
    /// family's root (a partition is drawn only from its own family's map).
    private(set) var sections: [String: String] = [:]
    private(set) var sectionsRoot: String?

    init(readingID: String, defaults: UserDefaults = .standard) {
        self.readingID = readingID
        self.prefs = BookIndexGroupingPrefs(defaults: defaults)
        self.choice = prefs.choice(for: readingID)
    }

    /// Her pick — remembered for this book, on this Mac.
    func choose(_ choice: BookIndexGrouping) {
        self.choice = choice
        prefs.setChoice(choice, for: readingID)
    }

    /// The family root the held read must file notes under (nil unless a
    /// family is chosen) — part of the read's task key.
    var familyRootID: String? {
        if case .tagFamily(let id)? = choice { return id }
        return nil
    }

    nonisolated struct Snapshot: Equatable, Sendable {
        var worn: [VariorumCore.Tag]
        var live: [VariorumCore.Tag]
        var sections: [String: String]
    }

    /// The ONE fetch — `post_tag` + `tag` only (core-pinned by region).
    nonisolated static func fetch(
        _ db: Database, postIDs: [String], rootID: String?
    ) throws -> Snapshot {
        Snapshot(
            worn: try Queries.tagsWorn(db, postIDs: postIDs),
            live: try Queries.allTags(db),
            sections: try rootID.map {
                try Queries.tagFamilySections(db, rootID: $0, postIDs: postIDs)
            } ?? [:])
    }

    /// HELD for the Index's life, keyed by the notes it shows and the chosen
    /// family (the caller's `.task(id:)` restarts it when either changes).
    func track(session: AppSession, postIDs: [String]) async {
        let rootID = familyRootID
        do {
            for try await snapshot in session.database.observe({ db in
                try Self.fetch(db, postIDs: postIDs, rootID: rootID)
            }) {
                adopt(snapshot, rootID: rootID)
            }
        } catch {
            // Cancellation (the Index left, or its key moved): the next
            // track starts fresh.
        }
    }

    func adopt(_ snapshot: Snapshot, rootID: String?) {
        worn = snapshot.worn
        live = snapshot.live
        sections = snapshot.sections
        sectionsRoot = rootID
    }
}

// MARK: - The face (the Index masthead's `group ▾`)

/// **`group · <mode> ▾`** — the book masthead's order control's idiom, drawn
/// only in Index (§17(f): "the Index masthead"). Its own view so the held
/// read's deliveries re-render this word and nothing around it.
struct BookIndexGroupingControl: View {
    let tokens: VoiceTokens
    let grouping: BookIndexGroupingModel
    let structure: BookStructureModel

    var body: some View {
        let wing = structure.reading?.wingId ?? ""
        let chaptersActive = structure.chaptersActive
        let families = BookIndexGroupingBrain.families(
            worn: grouping.worn, live: grouping.live, wingID: wing)
        let resolved = grouping.choice.map {
            BookIndexGroupingBrain.resolve(
                choice: $0, chaptersActive: chaptersActive, live: grouping.live, wingID: wing)
        } ?? .shipped
        // The stored grouping tag (a pre-13i-d book's) names the shipped look
        // when it is live.
        let stored = structure.reading?.groupingTagId.flatMap { id in
            grouping.live.first { $0.id == id && $0.wingId == wing }
        }
        let current = BookIndexGroupingBrain.current(
            resolved, chaptersActive: chaptersActive, storedGroupingID: stored?.id)
        let label = BookIndexGroupingBrain.label(
            resolved, chaptersActive: chaptersActive, storedGroupingPath: stored?.path)
        // Deliberately NOT `VoicedMenu` (the order control's reason: its
        // `.fixedSize()` would push the 190–300 pt column wider than its frame
        // on a long family path). The label truncates; the menu says it all.
        Menu {
            if chaptersActive {
                option(.chapters, BookIndexGroupingCopy.chapters, current: current)
            }
            Section(BookIndexGroupingCopy.familiesHeader) {
                if families.isEmpty {
                    Text(BookIndexGroupingCopy.noFamilies)
                } else {
                    ForEach(families, id: \.id) { family in
                        option(.tagFamily(family.id),
                               BookIndexGroupingCopy.family(family.path), current: current)
                    }
                }
            }
            option(.none, BookIndexGroupingCopy.none, current: current)
        } label: {
            Text(tokens.chromeLabel("\(BookIndexGroupingCopy.label) \u{00B7} ") + label + " \u{25BE}")
                .font(tokens.small)
                .foregroundStyle(grouping.choice == nil ? tokens.muted : tokens.accent)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .help(BookIndexGroupingCopy.help)
        #if DEBUG
        .onAppear { record(current: current, families: families) }
        .onChange(of: current) { _, now in record(current: now, families: families) }
        .onChange(of: families.map(\.id)) { _, _ in record(current: current, families: families) }
        #endif
    }

    @ViewBuilder
    private func option(
        _ choice: BookIndexGrouping, _ words: String, current: BookIndexGrouping
    ) -> some View {
        Button {
            grouping.choose(choice)
        } label: {
            if current == choice {
                Label(words, systemImage: "checkmark")
            } else {
                Text(words)
            }
        }
    }

    #if DEBUG
    private func record(current: BookIndexGrouping, families: [VariorumCore.Tag]) {
        BookIndexGroupingProbe.drawn[grouping.readingID] = .init(
            current: current,
            options: BookIndexGroupingBrain.options(
                chaptersActive: structure.chaptersActive, families: families))
    }
    #endif
}

#if DEBUG
/// What the mounted control offers and checks (the `BookSettingsProbe`
/// pattern — a hosted SwiftUI menu exposes nothing to a direct walk).
@MainActor
enum BookIndexGroupingProbe {
    struct Drawn: Equatable {
        var current: BookIndexGrouping
        var options: [BookIndexGrouping]
    }

    static var drawn: [String: Drawn] = [:]
}
#endif
