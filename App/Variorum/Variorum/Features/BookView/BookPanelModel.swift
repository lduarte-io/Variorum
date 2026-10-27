//
//  BookPanelModel.swift
//  Variorum (Mac)
//
//  13i-d U2 — THE BOOK PANEL's words, its pure brain, its drag token and its
//  model. The design is hers (the identity brief's round 5, 2026-08-26,
//  verbatim-faithful): *"a book table of contents kind of view with chapters
//  + notes that becomes available in the right side pane and you can reorder
//  the notes / chapters and drag them within that view or click on it open
//  the book view already scrolled into the note from there … for notes that
//  are shared between books, you switch out what book you're look at at the
//  top of it"* — and *"in a side panel it's collapsible … so the chrome stays
//  clean for focused writing."* The sitting record §15 adds the line
//  "appears in N gatherings", names on click; §20 the remove doors.
//
//  ── WHAT IS NEW, AND WHAT IS NOT ─────────────────────────────────────────
//  Nothing here decides what a book MEANS. The grouping is the book view's
//  own (`BookStructureModel.grouped`, the navigator's row-8 collapse rule);
//  a drop resolves through the book view's own pure planners
//  (`postDropPlan` / `chapterDropTarget`) onto the EXISTING operations; the
//  click-through is THE ascent (`MembershipChip.ascend` → `RootView.openBook`
//  → the parked `BookAscent` the book view lands on) — no second landing
//  mechanism. The remove door is 13i-c's (`RemoveFromBookDoor`).
//
//  ── NO PANEL DRAG CREATES A MEMBERSHIP ───────────────────────────────────
//  The panel's drags carry a PRIVATE token type (`BookPanelDragToken`) that
//  no other drop site in the app accepts, and its own drop sites act only on
//  the book it shows — a note it shows is already a member. So the sitting
//  record §6's door enumeration ("the Book Panel's drag powers consult
//  ownership") is satisfied by construction: there is no membership-creating
//  drag to consult for. A future drag INTO the panel from elsewhere would be
//  one, and must ride `MembershipDoors` (the one consult) — recorded.
//

import Foundation
import GRDB  // AsyncValueObservation iteration
import Observation
import SwiftUI  // Transferable
import UniformTypeIdentifiers
import VariorumCore

// MARK: - The words

/// Every sentence the Book Panel says. Wording PROVISIONAL (13s re-voices).
nonisolated enum BookPanelCopy {
    static func quoted(_ name: String) -> String { "\u{201C}\(name)\u{201D}" }

    // The door (the masthead icon — the inspector cluster's fourth).
    static let showVerb = "Book Panel"
    static let doorTitle = "Book"
    static let doorSymbol = "book.closed"
    /// VX-426: the tooltip leads with the door's name (A-439-17).
    static let doorHelp = "Book \u{2014} this note's book beside the draft: its chapters and "
        + "notes; click one to open the book there"
    static let unavailableNote = "Open a note that is in a book and its book shows beside it."

    // The structure doors (the row menus — each a drag's menu twin).
    static let fileInChapterVerb = "Move to Chapter"
    /// The move menus' chapterless destination. 17y item (i) — R-17y-4, her
    /// pick: ONE word for the state everywhere it shows, and it is the
    /// headers' — "unfiled" (the menus said "No Chapter" while the Outline
    /// said "unfiled"; she read the two words as two places). 13s may
    /// re-voice sentences; the word is settled.
    static let noChapter = unfiled
    static let moveNoteUpVerb = "Move Up"
    static let moveNoteDownVerb = "Move Down"
    static let moveChapterUpVerb = "Move Chapter Up"
    static let moveChapterDownVerb = "Move Chapter Down"
    /// 17y B2 (e) — a note re-placed inside its own chapter while the book
    /// reads in a stamp order: what happened, why, and the road out (the
    /// book view navigator's "order · … ▾" → Manual order → Save as This
    /// Book's Order). Wording PROVISIONAL (13s re-voices).
    static func needsManualOrder(book: String, order: String) -> String {
        "\(quoted(book)) is sorted by \(order), so a note can\u{2019}t be placed by hand "
            + "\u{2014} set the book\u{2019}s order \u{25BE} to Manual order and save it."
    }
    static let structureUnavailableNote =
        "A note's place in its book is changed from the book's rows \u{2014} the Book Panel "
        + "beside the note, or the book's own Outline and Index."

    // The face.
    static let close = "Close"
    /// The navigator's own word for notes outside every chapter.
    static let unfiled = "unfiled"
    static let inNoBook = "This note is in no book \u{2014} it lives in the Pool."
    static func openHelp(book: String) -> String { "Open \(quoted(book)) at this note" }
    static let switcherHelp = "This note is in more than one book \u{2014} choose which one shows here"
    static let thisNoteHelp = "The note you are writing"
    static func windowed(_ count: Int) -> String {
        "Showing the first \(count) notes \u{2014} open the book for the rest."
    }

    /// "appears in N gatherings" — the sitting record §15 (ruled), names on
    /// click. nil when it appears in none (the line is invisible then).
    static func gatheringsLine(count: Int) -> String? {
        switch count {
        case 0: nil
        case 1: "appears in 1 gathering"
        default: "appears in \(count) gatherings"
        }
    }
    static let gatheringsHelp = "Gatherings show notes their rule matches \u{2014} they hold "
        + "nothing. Click to see which."
    static func openGatheringHelp(_ name: String) -> String { "Open \(quoted(name)) at this note" }

    /// The book's state words, quiet under its name (what its refusals will
    /// name — a finished book's structure doors refuse with "reopen it").
    static func stateWords(_ reading: Reading) -> String? {
        var words: [String] = []
        // 13i-e U2: an ARCHIVED book says so first (the edge — membership is a
        // fact, visibility is the book's own state; PROVISIONAL).
        if reading.archivedAt != nil { words.append(BookArchiveCopy.word) }
        if reading.owned { words.append("owned") }
        if reading.sealedAt != nil { words.append("sealed") }
        else if reading.locked { words.append("finished") }
        return words.isEmpty ? nil : words.joined(separator: " \u{B7} ")
    }
}

// MARK: - The drag (a private token — no other drop site accepts it)

nonisolated enum BookPanelDrag: Equatable, Sendable {
    case note(String)
    case chapter(String)
}

/// The panel's drag payload — `Codable` under its OWN content type, so a
/// panel row dropped anywhere else in the app is refused by every other site
/// (the `BookcaseDragToken` road). That type is DECLARED in
/// `App/Variorum/VariorumInfo.plist` (`UTExportedTypeDeclarations`), pinned by
/// `DragTypeDeclarationTests`; until 17y B2 it was not, and no panel drop ever
/// landed (F-B2-1 — the U1/U2 "synthetic harness" readings were this defect).
nonisolated struct BookPanelDragToken: Codable, Transferable, Sendable {
    let kind: String
    let id: String

    init(_ drag: BookPanelDrag) {
        switch drag {
        case .note(let id): (kind, self.id) = ("note", id)
        case .chapter(let id): (kind, self.id) = ("chapter", id)
        }
    }

    var drag: BookPanelDrag? {
        switch kind {
        case "note": .note(id)
        case "chapter": .chapter(id)
        default: nil
        }
    }

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: UTType(exportedAs: "io.lduarte.variorum.book-panel-item"))
    }
}

// MARK: - The pure brain

/// Everything the panel DECIDES, pure and pinned. The rules it reuses are
/// the book view's own, named at each call.
nonisolated enum BookPanelBrain {
    typealias Group = (section: ReadingSection?, entries: [Queries.ReadingEntry])

    /// The note's BOOKS in the switcher's order — the chooser's (13f
    /// W20(c)): the session's most-recently-visited first, then by name. A
    /// gathering is never here (it holds no membership; it has its line).
    static func switcherBooks(_ readings: [Reading], recentlyVisited: [String]) -> [Reading] {
        BookChooserOrder.ordered(readings.filter { $0.kind == .book }, recentlyVisited: recentlyVisited)
    }

    /// WHICH book the panel shows: the one she chose while it is still one
    /// of the note's books; else the switcher's first (the book she came
    /// from, when she came from one). nil = the note is in no book.
    static func shownBook(
        _ readings: [Reading], chosen: String?, recentlyVisited: [String]
    ) -> Reading? {
        let books = switcherBooks(readings, recentlyVisited: recentlyVisited)
        if let chosen, let hit = books.first(where: { $0.id == chosen }) { return hit }
        return books.first
    }

    /// One line of the table of contents.
    nonisolated enum Line: Equatable, Identifiable {
        /// A chapter heading. `collapsed` is the row-8 rule (the navigator's
        /// `noteLineCollapsesIntoChapter`): a chapter whose ONE note says its
        /// name shows ONE line, and that line IS the note's.
        case chapter(ReadingSection, collapsed: Queries.ReadingEntry?)
        /// The heading over notes outside every chapter (chaptered books only).
        case unfiled
        case note(Queries.ReadingEntry, indented: Bool)

        var id: String {
            switch self {
            case .chapter(let section, _): "chapter:\(section.id)"
            case .unfiled: "unfiled"
            case .note(let entry, _): "note:\(entry.postID)"
            }
        }
    }

    /// The table of contents, in the book's own order — the navigator's
    /// grouping exactly (chapters in order, each with its notes in the
    /// book's order; notes outside every chapter trail under "unfiled").
    static func lines(_ groups: [Group]) -> [Line] {
        let chaptered = groups.contains { $0.section != nil }
        var lines: [Line] = []
        for group in groups {
            if let section = group.section {
                let collapsed = BookOutlineRows.noteLineCollapsesIntoChapter(
                    section: section, entries: group.entries) ? group.entries.first : nil
                lines.append(.chapter(section, collapsed: collapsed))
                if collapsed == nil {
                    lines += group.entries.map { .note($0, indented: true) }
                }
            } else {
                if chaptered { lines.append(.unfiled) }
                lines += group.entries.map { .note($0, indented: false) }
            }
        }
        return lines
    }

    /// **VX-330 — the note a line STANDS FOR**, whose two MCP marks it wears
    /// (the ONE shared icon, then a waiting ask — `BookPanelView.noteMarks`).
    /// Her words, verbatim: *"combined chapter / note headings don't show any
    /// AI symbol but that's how the example sherlock holmes looks and i think
    /// people might share that book with AI as an example so i want it fixed
    /// pre launch."*
    ///
    /// A note line stands for its note. A COLLAPSED one-note chapter line IS
    /// that note's row (row 8: its click opens the note in its book, its menu
    /// carries the note's menu), so it stands for that note too — VX-268's
    /// parity rule ("wherever the ask glyph marks a place, the shared icon
    /// marks it too") reaching the one row it missed. A plain chapter heading
    /// and "unfiled" stand for no place an AI can be granted or ask about — a
    /// chapter is no grant scope (`MCPGrantRule.ScopeKind`) and no ask target
    /// (`MCPAskTarget`) — so they wear neither mark.
    static func markedNote(_ line: Line) -> String? {
        switch line {
        case .note(let entry, _): entry.postID
        case .chapter(_, let collapsed): collapsed?.postID
        case .unfiled: nil
        }
    }

    /// Move Up / Move Down — the twin of dragging a note onto its
    /// neighbour: WITHIN its own group (its chapter, or unfiled), where the
    /// book's MANUAL order is what she sees. nil at the group's edge, and
    /// nil whenever the book reads in a stamp order (a hand position would
    /// not show — P-2; the book view's `repositionsOnDrop` rule).
    static func noteMove(
        _ postID: String, up: Bool, groups: [Group], manualOrder: Bool
    ) -> Operations.InsertPosition? {
        guard manualOrder,
              let group = groups.first(where: { $0.entries.contains { $0.postID == postID } })
        else { return nil }
        let ids = group.entries.map(\.postID)
        guard let index = ids.firstIndex(of: postID) else { return nil }
        if up {
            return index > 0 ? .before(ids[index - 1]) : nil
        }
        return index < ids.count - 1 ? .after(ids[index + 1]) : nil
    }

    /// Whether a chapter row draws its ⠿ grip (17y B2, item (e) — her
    /// stance: "a handle that cannot drag must not render"). A LONE chapter
    /// has nowhere to go — every drop of it resolves to nothing (`dropPlan`)
    /// — so its grip is not drawn; with another chapter to move past, it is
    /// (a finished book keeps it and refuses WITH the road — U2-8).
    ///
    /// **VX-21 (was VR-127 — her 0.9.2 use: "you shouldn't see draggable bars
    /// when you can't drag"): the grips draw only while the book is in MANUAL
    /// order.** Under a stamp order (her Journal, by entry date) no note can
    /// be placed by hand, and a grip there reads as "arrange this by hand" —
    /// the false-offer class (AppSpec §12: a drop outline lights only where
    /// the drop would act; the Bookcase's grips show only while its rows are
    /// placed by hand, P-17y-B2-1). What stays, deliberately: every row still
    /// DRAGS (the panel's note rows never wore a grip), a note dropped to
    /// re-place it in a stamp order still speaks the Manual-order refusal
    /// with its road, and the row menus keep their doors.
    static func chapterGripDrawn(chapterCount: Int, manualOrder: Bool) -> Bool {
        manualOrder && chapterCount > 1
    }

    /// Move Chapter Up / Down — `BookStructureModel.moveChapter(_:up:)`'s
    /// rule, as a value (nil at the edges).
    static func chapterMove(
        _ sectionID: String, up: Bool, sections: [ReadingSection]
    ) -> Operations.InsertPosition? {
        guard let index = sections.firstIndex(where: { $0.id == sectionID }) else { return nil }
        if up {
            return index > 0 ? .before(sections[index - 1].id) : nil
        }
        return index < sections.count - 1 ? .after(sections[index + 1].id) : nil
    }

    /// Where a panel drag was dropped.
    nonisolated enum DropSite: Equatable {
        case note(String)
        case chapter(String)
        case unfiled
    }

    /// What a drop WRITES — through the existing ops only.
    nonisolated enum DropPlan: Equatable {
        /// `assignPostToSection(post, section)` then, when `before` is set,
        /// `reorderReadingPost(post, .before(before))` — the book view's
        /// `filePost`.
        case file(postID: String, sectionID: String?, before: String?)
        /// `reorderSection(section, to:)` — the book view's `moveChapter`.
        case moveChapter(sectionID: String, to: Operations.InsertPosition)
    }

    /// The ONE resolution of a panel drop, by the book view's own planners
    /// (`BookStructureModel.postDropPlan` / `chapterDropTarget`) and its
    /// no-op rules. nil = nothing to do (a note on itself, a chapter onto its
    /// own edge).
    static func dropPlan(
        _ drag: BookPanelDrag, onto site: DropSite, groups: [Group],
        sections: [ReadingSection], manualOrder: Bool
    ) -> DropPlan? {
        switch drag {
        case .note(let postID):
            let postSite: BookStructureModel.PostDropSite = switch site {
            case .note(let target): .post(target)
            case .chapter(let sectionID): .chapter(sectionID)
            case .unfiled: .unfiled
            }
            guard let plan = BookStructureModel.postDropPlan(
                postSite, dragged: postID, groups: groups, reposition: manualOrder)
            else { return nil }
            return .file(postID: postID, sectionID: plan.sectionID, before: plan.before)
        case .chapter(let sectionID):
            guard sections.contains(where: { $0.id == sectionID }) else { return nil }
            let before: String? = switch site {
            case .note(let target): BookStructureModel.chapterDropTarget(.post(target), groups: groups)
            case .chapter(let target): BookStructureModel.chapterDropTarget(.chapter(target), groups: groups)
            case .unfiled: nil
            }
            // `moveChapter(_:before:)`'s no-op rules: onto itself, or onto
            // the boundary it already sits at.
            if let before {
                guard before != sectionID,
                      let targetIndex = sections.firstIndex(where: { $0.id == before })
                else { return nil }
                if targetIndex > 0, sections[targetIndex - 1].id == sectionID { return nil }
                return .moveChapter(sectionID: sectionID, to: .before(before))
            }
            guard sections.last?.id != sectionID else { return nil }
            return .moveChapter(sectionID: sectionID, to: .end)
        }
    }

    /// What a panel drop RESOLVES to (17y B2, item (e) — the silent sort
    /// gate made to speak, P-2).
    nonisolated enum DropOutcome: Equatable {
        /// Write this through the existing ops.
        case plan(DropPlan)
        /// Nothing to do — dropped on itself, or where it already stands
        /// (in a stamp order too: onto its immediate shown successor).
        case nothing
        /// A note dropped to RE-PLACE it inside its own chapter (onto a
        /// sibling, or its own chapter's heading) while an OPEN book (never a
        /// finished or sealed one — its lock answers first) reads in a
        /// STAMP order: the book view's planner keeps an order she cannot see
        /// untouched, so the drop would write nothing under a hairline that
        /// promised "lands right above". Refuse WITH the road instead.
        case needsManualOrder
    }

    /// The ONE resolution every panel drop takes: `dropPlan` (the book
    /// view's planners, unchanged), plus the sort gate's honest answer.
    ///
    /// `frozen` = the book is finished or sealed (`reading.locked` — sealing
    /// finishes too). **The lock answers BEFORE the sort gate** (the B2
    /// ladder's MAJOR-1): a frozen book's plan runs as it is, so the op's OWN
    /// lock guard refuses ("reopen it first" / "unseal it first" — one
    /// refusal source, through `run`), because `needsManualOrder`'s road —
    /// save a Manual order — is impossible there (Save is hidden on a frozen
    /// book and `setReadingSort` refuses).
    static func dropOutcome(
        _ drag: BookPanelDrag, onto site: DropSite, groups: [Group],
        sections: [ReadingSection], manualOrder: Bool, frozen: Bool
    ) -> DropOutcome {
        guard let plan = dropPlan(
            drag, onto: site, groups: groups, sections: sections, manualOrder: manualOrder)
        else { return .nothing }
        if frozen { return .plan(plan) }
        // The gate: a stamp order, a note, a plan that files it into the
        // chapter it is ALREADY in (a write that changes nothing) — where
        // the same drop in manual order would have re-placed it.
        if !manualOrder, case .note(let postID) = drag,
           case .file(_, let sectionID, nil) = plan,
           sectionID == chapter(of: postID, in: groups),
           case .file(_, _, let before?)? = dropPlan(
               drag, onto: site, groups: groups, sections: sections, manualOrder: true),
           before != postID {
            // Already satisfied (the B2 ladder's NIT-4): dropped onto its
            // IMMEDIATE shown successor, the note would land right above
            // where it already stands — no placement was asked, so no refusal
            // is owed (manual order does the same gesture silently).
            if before == successor(of: postID, in: groups) { return .nothing }
            return .needsManualOrder
        }
        return .plan(plan)
    }

    /// The chapter a note sits in on the panel (nil = unfiled).
    private static func chapter(of postID: String, in groups: [Group]) -> String? {
        groups.first { $0.entries.contains { $0.postID == postID } }?.section?.id
    }

    /// The note shown right after `postID` in its own group (nil = it is the
    /// group's last).
    private static func successor(of postID: String, in groups: [Group]) -> String? {
        guard let entries = groups.first(where: { $0.entries.contains { $0.postID == postID } })?
                  .entries,
              let index = entries.firstIndex(where: { $0.postID == postID }),
              index + 1 < entries.count
        else { return nil }
        return entries[index + 1].postID
    }
}

// MARK: - The model

/// The panel's model: the SHOWN book's table of contents (held while the
/// panel is open) and the panel's acts. Membership — which books, which
/// gatherings — is the note detail's `NoteMembershipModel`, handed down.
@MainActor
@Observable
final class BookPanelModel {
    /// The bounded observation window — the book view's own
    /// (`BookViewModel.entryWindow`): a held fetch re-runs at container-write
    /// rate, so it stays viewport-shaped, never corpus-shaped (P1).
    nonisolated static let entryWindow = 300

    @ObservationIgnored let session: AppSession
    /// The note the panel stands beside.
    let postID: String
    /// The book she chose in the switcher (session state; nil = the
    /// brain's default).
    var chosenBookID: String?

    nonisolated struct Snapshot: Equatable, Sendable {
        var reading: Reading?
        var sections: [ReadingSection]
        var assignments: [String: String]
        var entries: [Queries.ReadingEntry]
        var truncated: Bool
    }

    /// The shown book's contents, keyed by the book they describe.
    private(set) var snapshot: Snapshot?
    private(set) var snapshotBookID: String?
    /// **VX-268 — who reaches each listed NOTE now** (the ONE icon on the
    /// panel's note rows — her kickoff call: "the Book Panel's rows … IN"):
    /// `Queries.mcpNoteReaches` over the shown book's entries — ∝ the panel's
    /// own window (`entryWindow`), held while the panel shows that book.
    private(set) var reach: [String: [MCPPlaceReach]] = [:]

    init(session: AppSession, postID: String) {
        self.session = session
        self.postID = postID
    }

    // MARK: The held read (while the panel shows this book)

    /// Holds the shown book's table of contents — run from
    /// `.task(id: bookID)`, so switching books restarts it.
    ///
    /// **The cost, named:** the assembly reads `container` (titles, the
    /// archived filter), which autosave rewrites, so while the panel is open
    /// this re-runs per autosave — bounded by the window (the book view's own
    /// navigator observation, one level smaller: no previews). KnownIssues
    /// row 13's class, recorded there.
    func observe(bookID: String) async {
        do {
            for try await value in session.database.observe({ db in
                let entries = try Queries.assembleReading(
                    db, readingID: bookID, limit: Self.entryWindow + 1)
                return Snapshot(
                    reading: try Queries.reading(db, id: bookID),
                    sections: try Queries.readingSections(db, readingID: bookID),
                    assignments: try Queries.sectionAssignments(db, readingID: bookID),
                    entries: Array(entries.prefix(Self.entryWindow)),
                    truncated: entries.count > Self.entryWindow)
            }) {
                guard !Task.isCancelled else { return }
                snapshot = value
                snapshotBookID = bookID
            }
        } catch {
            // Cancellation (a book switch, the panel closing) ends it quietly.
        }
    }

    /// The contents, but only if they are `bookID`'s.
    func snapshot(for bookID: String) -> Snapshot? {
        snapshotBookID == bookID ? snapshot : nil
    }

    /// The notes the panel lists for `bookID` (its entry window) — the ids
    /// the reach hold reads (VX-268).
    func entryIDs(for bookID: String?) -> [String] {
        guard let bookID, let snapshot = snapshot(for: bookID) else { return [] }
        return snapshot.entries.map(\.postID)
    }

    /// VX-268 — hold the listed notes' reach (the view's `.task(id:)` on the
    /// entry ids — a book switch or a membership change restarts it; an
    /// autosave never changes the ids).
    func holdReach(_ ids: [String]) async {
        await MCPRowReach.hold(session, { try Queries.mcpNoteReaches($0, noteIDs: ids) }) { [weak self] value in
            guard let self, self.reach != value else { return }
            self.reach = value
        }
    }

    func groups(for bookID: String) -> [BookPanelBrain.Group] {
        guard let snapshot = snapshot(for: bookID) else { return [] }
        return BookStructureModel.grouped(
            entries: snapshot.entries, sections: snapshot.sections,
            assignments: snapshot.assignments)
    }

    /// True when the book's own MANUAL order is what she sees — the only
    /// order a hand move can show (the book view's `repositionsOnDrop`).
    func manualOrder(for bookID: String) -> Bool {
        snapshot(for: bookID)?.reading?.sortField == .manual
    }

    // MARK: The acts

    /// THE CLICK-THROUGH: open the book scrolled to the note — the ascent
    /// road, consumed (never a second landing mechanism).
    func open(book: Reading, at postID: String) {
        MembershipChip.ascend(bookID: book.id, postID: postID)
    }

    /// Move to Chapter ▸ (nil = No Chapter) — the twin of dragging a note
    /// onto a chapter heading (or the unfiled heading).
    func file(_ postID: String, in book: Reading, chapter sectionID: String?) async {
        await run(book) { ops in
            try ops.assignPostToSection(postID, in: book.id, section: sectionID)
        }
    }

    /// Move Up / Move Down — the twin of dragging a note onto its neighbour.
    func move(_ postID: String, in book: Reading, up: Bool) async {
        guard let target = BookPanelBrain.noteMove(
            postID, up: up, groups: groups(for: book.id), manualOrder: manualOrder(for: book.id))
        else { return }
        await run(book) { ops in try ops.reorderReadingPost(postID, in: book.id, to: target) }
    }

    /// Move Chapter Up / Down — the twin of dragging a chapter heading.
    func moveChapter(_ sectionID: String, in book: Reading, up: Bool) async {
        guard let target = BookPanelBrain.chapterMove(
            sectionID, up: up, sections: snapshot(for: book.id)?.sections ?? [])
        else { return }
        await run(book) { ops in try ops.reorderSection(sectionID, to: target) }
    }

    /// A panel drop, resolved by the brain onto the existing ops. Returns
    /// whether the drop was the panel's (a foreign token never reaches here
    /// — the content type keeps it out).
    @discardableResult
    func drop(_ drag: BookPanelDrag, onto site: BookPanelBrain.DropSite, in book: Reading) async -> Bool {
        // The held row — the one the order gate already reads — so the lock
        // consult and the refusal's sealed/finished wording agree with it.
        let shown = snapshot(for: book.id)?.reading ?? book
        let plan: BookPanelBrain.DropPlan
        switch BookPanelBrain.dropOutcome(
            drag, onto: site, groups: groups(for: book.id),
            sections: snapshot(for: book.id)?.sections ?? [],
            manualOrder: manualOrder(for: book.id), frozen: shown.locked) {
        case .nothing:
            return false
        case .needsManualOrder:
            // 17y B2 (e): the silent sort gate speaks, with the road out.
            session.status.refuse(BookPanelCopy.needsManualOrder(
                book: shown.name, order: BookOrderChoices.storedLabel(for: shown)))
            return true
        case .plan(let resolved):
            plan = resolved
        }
        switch plan {
        case .file(let postID, let sectionID, let before):
            await run(shown) { ops in
                try ops.assignPostToSection(postID, in: book.id, section: sectionID)
                if let before {
                    try ops.reorderReadingPost(postID, in: book.id, to: .before(before))
                }
            }
        case .moveChapter(let sectionID, let target):
            await run(shown) { ops in try ops.reorderSection(sectionID, to: target) }
        }
        return true
    }

    /// Remove from This Book / Release from This Book (§20) — 13i-c's one
    /// road; its receipt (or the op's refusal) speaks on the status seam.
    func remove(_ postID: String, from book: Reading) async {
        await RemoveFromBookDoor.remove(session: session, postID: postID, book: book)
    }

    /// A gathering's honest door — take the tag off (§20).
    func removeTag(_ tag: VariorumCore.Tag, from gathering: Reading) async {
        await RemoveFromBookDoor.removeTag(
            session: session, postID: postID, tag: tag, gathering: gathering)
    }

    /// The tags behind each gathering's honest door, read when the line opens.
    func wornRuleTags(_ gatherings: [Reading]) async -> [String: [VariorumCore.Tag]] {
        (try? await session.database.read { [postID] db in
            var worn: [String: [VariorumCore.Tag]] = [:]
            for gathering in gatherings {
                worn[gathering.id] = try RemoveFromBookDoor.wornRuleTags(
                    db, postID: postID, gathering: gathering)
            }
            return worn
        }) ?? [:]
    }

    /// The structure doors' one road: success is SILENT (the table of
    /// contents moving is the answer — P-13id-U1-13's precedent); a refusal
    /// is the op's own, named for its book with its road (a finished book's
    /// "reopen it first"), on the status seam.
    private func run(
        _ book: Reading, _ body: @escaping @Sendable (Operations) throws -> Void
    ) async {
        do {
            try await session.runner.run(body)
        } catch {
            session.status.refuse(BookStateCopy.refusal(
                for: error, name: book.name, sealed: book.sealedAt != nil))
        }
    }
}
