//
//  SnippetsSurface.swift
//  Variorum (Mac)
//
//  pre-13u Act 10 wave 2b, item 17 — the Snippets refresh's brains: the
//  vocabulary (SNIPPETS in every UI string — her fifth-wave ruling on the
//  K5 precedent; `container.kind='pool'` stays the model term), the pure
//  filter/sort rule, the card's metadata face, and the surface's model
//  (groups rail · all-snippets listing · management doors · bulk acts).
//
//  The ownership answer lives in the STRUCTURE (her fourth-wave escalation
//  answered): the rail lists snippet groups as flat siblings — no book or
//  note owns one; "field guide" sits beside the default as an equal — so
//  "does each book have a pool?" stops needing to be asked.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

// MARK: - The vocabulary (pinned: "pool"/"scrap" appear in NO string here)

/// Every UI string the Snippets surface speaks, in one place so the ruled
/// vocabulary is a PIN, not a hope. Copy doctrine: structure and generous
/// targets first; a sentence only where truly necessary.
nonisolated enum SnippetsCopy {
    static let pageTitle = "Snippets"

    static func whereLine(snippets: Int, groups: Int) -> String {
        let s = snippets == 1 ? "1 snippet" : "\(snippets) snippets"
        let g = groups == 1 ? "1 group" : "\(groups) groups"
        return "\(s) in \(g)"
    }

    static let searchPrompt = "search snippets"
    static let allGroups = "all snippets"
    static let groupsHeader = "groups"
    static let newGroup = "+ new group"
    static let renameGroupRow = "rename group…"
    static let newGroupRow = "new group…"
    static let deleteGroupRow = "delete group…"
    /// The delete-group menu caption — honest to the letter: the Trash is
    /// the road back (`deleteContainer` registers no structural undo, by
    /// the 13j doctrine, so no ⌥⌘Z is promised).
    static let deleteGroupCaption = "its snippets go to the Trash with it — 30 days"
    static let openAsEditor = "open as editor"
    static let dropTarget = "drop text or a file here to add it"
    static let entryCue = "new snippet — start typing · ⏎ keeps it as a standalone snippet"
    static let emptyListing = "No snippets yet — type one below, or drop text here."
    static let emptySearch = "Nothing matches."

    // The per-card ⋯ / context rows.
    /// 17o batch e (row 38): the row names THE SNIPPET, never a particular
    /// container. It read "Open in the Snippets editor" and promised the one
    /// group it could not keep — *"the snippet i clicked on was part of the
    /// tutorial so it's not in the Snippets editor"*.
    static let openRow = "Open this snippet in its editor"
    static let tagsRow = "Tags…"
    static let moveRow = "Move to Group"
    /// **The BLOCK-side row that sends a block out of its note** — rendered
    /// by Blocks mode's row ⋯ and by Read ▸ edit's index column ⋯, and named
    /// by the tutorial's deleting chapter. ONE spelling since 13u3 UNIT H:
    /// the two menus hand-typed it identically and the lesson still called it
    /// *"Move out to a pool"*, the name it carried before the Snippets
    /// vocabulary ruling (pre-13u, W8-1) — a reader following that sentence
    /// looked for a row that is not in the menu.
    static let moveOutRow = "Move out to snippets (leaves this note)"
    static let archiveRow = "Archive Snippet"
    static let deleteRow = "Delete Snippet"

    // The bulk bar.
    static func selectedLine(_ count: Int) -> String { "\(count) selected" }
    static let bulkMove = "move to group"
    static let bulkTag = "tag"
    static let bulkArchive = "archive"
    static let bulkDelete = "delete"
    static let bulkClear = "clear"

    // Filters.
    static let tagAny = "tag: any"
    /// 17o batch e (row 39, the WALK's finding): with no snippet in the
    /// listing wearing a tag, this menu offered exactly ONE row — "tag:
    /// any" — a tag-shaped control on a page with no visible way to tag
    /// anything. That is what *"you can't tag snippets but there's a tag on
    /// there"* was looking at. The empty case now names the door, in the
    /// bulk tag menu's own idiom (a quiet disabled row, two screens away in
    /// this same file) and in the field guide's own words.
    static let tagNoneYet = "no snippet here wears a tag yet \u{2014} right-click one \u{25B8} Tags\u{2026}"
    static func tagFilter(_ path: String) -> String { "tag: \(path)" }
    static func sortLabel(_ sort: SnippetSort) -> String { "sort: \(sort.rawValue)" }

    /// 17o batch e (row 39): the tag chip on a card IS the tag door — her
    /// words, *"you can't tag snippets but there's a tag on there"*. The
    /// door existed (the ⋯ menu's "Tags…"); what it lacked was a face
    /// where the tag already shows.
    static let tagChipHelp = "This snippet's tags — click to add or remove them"

    // The metadata face's words.
    static func takesBadge(_ count: Int) -> String { "⑂ \(count) takes" }
    static func words(_ count: Int) -> String {
        count == 1 ? "1 word" : "\(count) words"
    }
    static func edited(_ day: String) -> String { "edited \(day)" }

    // Receipts (the model's one message slot; refusals keep their own).
    static func movedSnippets(_ count: Int, to group: String) -> String {
        (count == 1 ? "Snippet moved" : "\(count) snippets moved") + " to \(group)."
    }
    static func groupCreated(_ name: String) -> String { "Group \(name) created." }

    /// The pin's sweep set: every string above, enumerated so the
    /// vocabulary test cannot miss one added later without being extended
    /// deliberately.
    static var allStrings: [String] {
        [
            pageTitle, whereLine(snippets: 2, groups: 2), searchPrompt,
            allGroups, groupsHeader, newGroup, renameGroupRow, newGroupRow,
            deleteGroupRow, deleteGroupCaption, openAsEditor, dropTarget,
            entryCue, emptyListing, emptySearch, openRow, tagsRow, moveRow,
            archiveRow, deleteRow, selectedLine(2), bulkMove, bulkTag,
            bulkArchive, bulkDelete, bulkClear, tagAny, tagFilter("x"),
            sortLabel(.recent), takesBadge(2), words(2), edited("today"),
            movedSnippets(2, to: "x"), groupCreated("x"), tagChipHelp,
            tagNoneYet,
        ]
    }
}

// MARK: - The filter/sort rule (pure — pinned)

nonisolated enum SnippetSort: String, CaseIterable, Sendable {
    case recent, oldest, longest
}

/// The listing rule: scope (a group or all), search, tag filter, sort —
/// applied IN MEMORY over the held listing (the observation already paid
/// for the rows; a keystroke never touches the store).
nonisolated enum SnippetFilter {
    static func apply(
        _ items: [Queries.PoolItem], groupID: String?, query: String,
        tagPath: String?, sort: SnippetSort
    ) -> [Queries.PoolItem] {
        var result = items
        if let groupID {
            result = result.filter { $0.poolID == groupID }
        }
        if let tagPath {
            result = result.filter { $0.tagPaths.contains(tagPath) }
        }
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !needle.isEmpty {
            result = result.filter { item in
                (item.block.text ?? "").localizedCaseInsensitiveContains(needle)
                    || item.tagPaths.contains {
                        $0.localizedCaseInsensitiveContains(needle)
                    }
            }
        }
        switch sort {
        case .recent:
            result.sort {
                (($0.updatedAt ?? ""), $1.block.blockID)
                    > (($1.updatedAt ?? ""), $0.block.blockID)
            }
        case .oldest:
            result.sort {
                (($0.updatedAt ?? ""), $0.block.blockID)
                    < (($1.updatedAt ?? ""), $1.block.blockID)
            }
        case .longest:
            result.sort { a, b in
                let wa = Queries.wordCount(a.block.text ?? "")
                let wb = Queries.wordCount(b.block.text ?? "")
                return wa == wb ? a.block.blockID < b.block.blockID : wa > wb
            }
        }
        return result
    }

    /// The tag-filter menu's rows: every path worn by the listing, sorted.
    static func tagPaths(_ items: [Queries.PoolItem]) -> [String] {
        Array(Set(items.flatMap(\.tagPaths))).sorted()
    }
}

// MARK: - The card's metadata face (pure — pinned)

/// The quiet metadata parts under a snippet's text: the takes badge (the
/// W8-4 ruling — a fan's size, shown only when there IS a fan), the word
/// count (the one counting rule), and the edited day.
nonisolated enum SnippetCardFace {
    static func metadata(
        activeTakes: Int, text: String?, updatedAt: String?,
        calendar: Calendar = .current
    ) -> [String] {
        var parts: [String] = []
        if activeTakes > 1 { parts.append(SnippetsCopy.takesBadge(activeTakes)) }
        parts.append(SnippetsCopy.words(Queries.wordCount(text ?? "")))
        if let edited = editedPart(updatedAt: updatedAt, calendar: calendar) {
            parts.append(edited)
        }
        return parts
    }

    /// The metadata's edited part exactly as `metadata` says it — the one
    /// place its words are made, so the card can find it to hover it.
    static func editedPart(updatedAt: String?, calendar: Calendar = .current) -> String? {
        DisplayTitle.day(fromStamp: updatedAt, calendar: calendar).map(SnippetsCopy.edited)
    }

    /// **The edited part's hover — the whole fact** (VX-351 — the VX-348 run,
    /// U4; her R-VX348-3): *Edited Oct 13, 2026 at 4:02 PM*.
    static func editedHelp(updatedAt: String?) -> String? {
        TimeStampFace.tooltip(.edited, iso: updatedAt)
    }
}

// MARK: - Where a Snippets door goes (pure — pinned)

/// **What a Snippets door opens** — a container, and optionally the block to
/// land on (17o batch e, ledger row 38; her words: *"if you right click on a
/// snippet and open it in the snippet editor, it just opens a whole note with
/// several different snippets but not even the snippet that i right clicked
/// on … the snippet i clicked on was part of the tutorial so it's not in the
/// Snippets editor"*).
///
/// The two doors of this surface differ, and that difference IS the fix:
///
/// - a **card** is pointed at directly (the `.tagBlock` grammar — the target
///   is the row you right-clicked), so it opens the card's OWN group at the
///   snippet she clicked;
/// - the header's **open as editor** is a SCOPE door — it opens the group she
///   is browsing, landing nowhere in particular.
///
/// Before this the card's two doors both asked for `activePool`, which under
/// the rail's "all snippets" head row is `pools.first` — the oldest group,
/// the seeded default — so a card in any other group opened the wrong
/// container, with no landing either way.
nonisolated struct SnippetOpenTarget: Equatable, Sendable {
    /// The `container.kind='pool'` row to open (the group, in the surface's
    /// ruled vocabulary).
    let poolID: String
    /// The block to land the caret in, when the door pointed at one.
    let blockID: String?

    /// A CARD's door: its own group, landing on the clicked snippet.
    static func card(_ item: Queries.PoolItem) -> SnippetOpenTarget {
        SnippetOpenTarget(poolID: item.poolID, blockID: item.block.blockID)
    }

    /// The HEADER's door: the group being browsed, no landing.
    static func group(_ pool: Container) -> SnippetOpenTarget {
        SnippetOpenTarget(poolID: pool.id, blockID: nil)
    }
}

// MARK: - The surface's model

/// The Snippets page's model: the groups rail, the all-groups listing,
/// the management doors (create · rename · delete a group, move snippets
/// between groups), and the bulk acts. Chrome only — every mutation is an
/// operations call.
@MainActor
@Observable
final class SnippetsAreaModel {
    @ObservationIgnored let session: AppSession

    private(set) var pools: [Container] = []
    private(set) var counts: [String: Int] = [:]
    /// EVERY group's rows (the rail scopes in memory via `SnippetFilter`).
    private(set) var items: [Queries.PoolItem] = []
    /// nil = all snippets (the rail's head row).
    private(set) var selectedGroupID: String?
    private(set) var lastError: String?
    /// A success's own words — never rendered in the error slot (the
    /// ledger row 6 split, as everywhere).
    private(set) var receipt: String?

    init(session: AppSession) {
        self.session = session
    }

    func start() async {
        do {
            for try await value in session.database.observeAllPoolItems() {
                items = value
                await refreshRail()
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The rail's rows + counts — one bounded read per listing change.
    private func refreshRail() async {
        let read = try? await session.database.read { db in
            (try Queries.pools(db), try Queries.poolCounts(db))
        }
        if let (pools, counts) = read {
            self.pools = pools
            self.counts = counts
            // A selected group that died falls back to all.
            if let selected = selectedGroupID, !pools.contains(where: { $0.id == selected }) {
                selectedGroupID = nil
            }
        }
    }

    func select(groupID: String?) {
        selectedGroupID = groupID
    }

    /// The group container-level acts target: the selected group, else the
    /// default (oldest — the standing rule).
    var activePool: Container? {
        pools.first { $0.id == selectedGroupID } ?? pools.first
    }

    /// Internal so tests drive listings deterministically.
    func adopt(pools: [Container], items: [Queries.PoolItem]) {
        self.pools = pools
        self.items = items
    }

    // MARK: Group management (item 17's four new doors)

    @discardableResult
    func createGroup(named name: String) async -> String? {
        clear()
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let pool = try await session.runner.run { ops in
                try ops.createPool(title: trimmed.isEmpty ? nil : trimmed)
            }
            receipt = SnippetsCopy.groupCreated(PoolNaming.title(pool))
            await refreshRail()
            return pool.id
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }

    func renameGroup(_ groupID: String, to name: String) async {
        clear()
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try await session.runner.run { ops in
                try ops.renameContainer(groupID, title: trimmed.isEmpty ? nil : trimmed)
            }
            await refreshRail()
        } catch {
            lastError = String(describing: error)
        }
    }

    /// **Delete a group — the ordinary `deleteContainer`/Trash road** (her
    /// ruled door). Flush first like every structural door (the group may
    /// be open as an editor with a dirty buffer); the Trash lists it as a
    /// snippet-group row (the wave's core arm), Put back revives it whole.
    ///
    /// `NoteDeletion.run`'s kind fence is NOT this door's road and stays
    /// untouched: that fence guards the NOTE-shaped doors from tombstoning
    /// a pool by accident (#77's 28 lost scraps); this is the deliberate,
    /// group-shaped act the ruling asked for — and it exists at all only
    /// because the Trash can now speak for the road.
    func deleteGroup(_ groupID: String) async {
        clear()
        await session.flushExistingAutosave(forPost: groupID)
        do {
            try await session.runner.run { ops in
                try ops.deleteContainer(groupID)
            }
            // Every pane/window standing on the group gets off it (the
            // navigate-away letter — `.pool` selections ride `noteID`).
            NotificationCenter.default.post(
                name: .variorumNotesDeleted, object: nil,
                userInfo: ["postIDs": [groupID]])
            receipt = RecoveryCopy.movedToTrashReceipt(.snippetGroup)
            await refreshRail()
        } catch {
            lastError = DeletionRefusal.words(error, act: .delete)
        }
    }

    /// How many snippets the delete-group confirm names — read at ASK time
    /// (a confirm is a pause; a listing is a projection).
    func snippetCount(in groupID: String) async -> Int {
        (try? await session.database.read { db in
            try Queries.poolCounts(db)[groupID] ?? 0
        }) ?? 0
    }

    // MARK: Snippet acts (single and bulk — one road each)

    func moveSnippets(_ blockIDs: [String], to groupID: String) async {
        clear()
        guard !blockIDs.isEmpty else { return }
        do {
            try await session.runner.run { ops in
                for id in blockIDs {
                    try ops.moveBlock(id, to: groupID)
                }
            }
            let name = PoolNaming.title(pools.first { $0.id == groupID })
            receipt = SnippetsCopy.movedSnippets(blockIDs.count, to: name)
        } catch {
            lastError = DeletionRefusal.words(error, act: .delete)
        }
    }

    func archiveSnippets(_ blockIDs: [String]) async {
        clear()
        guard !blockIDs.isEmpty else { return }
        do {
            try await session.runner.run { ops in
                for id in blockIDs { try ops.archiveBlock(id) }
            }
            receipt = BlockSelectionCopy.archivedNote(home: .pool)
        } catch {
            lastError = DeletionRefusal.words(error, act: .delete)
        }
    }

    func deleteSnippets(_ blockIDs: [String]) async {
        clear()
        guard !blockIDs.isEmpty else { return }
        do {
            try await session.runner.run { ops in
                for id in blockIDs { try ops.deleteBlock(id) }
            }
            receipt = BlockSelectionCopy.deletedNote(blockIDs.count, home: .pool)
        } catch {
            lastError = DeletionRefusal.words(error, act: .delete)
        }
    }

    /// The bulk tag door: one existing tag applied to every picked snippet
    /// (already-tagged rows skip quietly — the standing batch semantics).
    func applyTag(_ tagID: String, to blockIDs: [String]) async {
        clear()
        do {
            try await session.runner.run { ops in
                for id in blockIDs {
                    do {
                        _ = try ops.applyTag(tagID, toBlock: id)
                    } catch OperationError.alreadyTagged {}
                }
            }
        } catch {
            lastError = TagsViewModel.message(error)
        }
    }

    /// The bulk tag menu's rows — one bounded read when the bar appears.
    func allTags() async -> [Tag] {
        (try? await session.database.read { try Queries.allTags($0) }) ?? []
    }

    private func clear() {
        lastError = nil
        receipt = nil
    }
}
