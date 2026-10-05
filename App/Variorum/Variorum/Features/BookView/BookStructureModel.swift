//
//  BookStructureModel.swift
//  Variorum
//
//  Phase 13, B3 — the book's STRUCTURE model: real chapters (R28/R50 —
//  reading_section rows + reading_post.section_id), the view mode (Book /
//  Read — R2's reading flow; a finished book opens into Read), the book
//  settings passthroughs, and the journal-book "New Entry" door (R50's
//  binding: ordinary membership; the ONE-ENTRY-PER-DAY rule stays the
//  DAILY journal door's — untouchable, and untouched: only the designated
//  daily book routes through create-or-open).
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import VariorumCore

@MainActor
@Observable
final class BookStructureModel {
    @ObservationIgnored let session: AppSession
    let readingID: String

    /// The book's three modes. 13c Batch 2A (her 2026-07-23/24 direction):
    /// the picker reads **Outline · Book · Read**, and the cases are named
    /// for what each surface IS rather than for what it was called before:
    ///
    /// - `.outline` — the continuous vertical scroll, now the book's
    ///   WRITING surface (A39: "literally looks like write mode but has the
    ///   chapter headings and the posts are collapsible"). This was `.book`.
    /// - `.spread` — the picker's **"Book"**: the two-up spread where each
    ///   page is a whole scrollable POST. Today it is 13b 4F's single-page
    ///   Kindle view; Batch 2B makes it two-up. This was `.pages`.
    /// - `.read` — the reading flow (Batch 2C pairs it with true
    ///   pagination). Unchanged.
    ///
    /// **Why `.spread` and not `.book`** (Batch 2A judgment call 1): the
    /// picker's "Book" now names the surface the old `.book` case did NOT
    /// name, so reusing the identifier would let every stale reference —
    /// in code, in a rebased branch, in a future session reading an older
    /// batch record — compile silently against the wrong surface. Renaming
    /// BOTH cases out of the collision makes every stale reference a
    /// compile error instead.
    /// - `.index` — the index-like book view (pre-13u Act 10 wave 2c, item
    ///   18 / W8-5 — her ruling: "there should ALSO be an index like view").
    ///   The note Index mode's sibling at book scale: a standing column of
    ///   chapters and notes beside a scroll-synced rendered pane. While it
    ///   is active the minimal navigator steps aside (her reconciliation
    ///   question, answered: the index IS the outline pane grown up; the
    ///   minimal pane stays beside the other modes — two grains, deliberate).
    enum ViewMode { case outline, spread, read, index }

    /// READ's two faces (13c Batch 2C — her 2026-07-23/24 direction: Read is
    /// "the Apple-Books/Kindle PAIR of modes").
    ///
    /// - `.flow` — the vertical infinite scroll (`ReadingFlowView`), which is
    ///   what Read has always been.
    /// - `.pages` — TRUE BOOK PAGINATION: a two-page spread of identical
    ///   fixed pages with the text flowing across them (`PagedReadView`).
    ///
    /// `.flow` is the DEFAULT, deliberately: R2's ratified behavior is that a
    /// finished book *opens into the reading flow*, and a sub-mode default of
    /// `.pages` would silently change what she has been opening into for two
    /// phases. PROVISIONAL — QUESTIONS #45(e). Session/view state, never
    /// persisted (the collapse-set class, #43(b)/#44(a)).
    enum ReadForm: String, CaseIterable { case flow, pages }
    var readForm: ReadForm = .flow

    private(set) var reading: Reading?
    private(set) var sections: [ReadingSection] = []
    /// Non-empty when a chapter can be restored — the recovery door must
    /// exist even when NO section rows remain to hang a menu off (round 2,
    /// MINOR: deleting the only chapter made restoreSection unreachable).
    private(set) var deletedSections: [ReadingSection] = []
    private(set) var assignments: [String: String] = [:]
    private(set) var lastError: String?
    var mode: ViewMode = .outline
    /// Set exactly once from the first observed reading row (a finished
    /// book OPENS into the reading flow — R2; pinned).
    private var modeSeeded = false

    init(session: AppSession, readingID: String) {
        self.session = session
        self.readingID = readingID
    }

    nonisolated struct Snapshot: Equatable, Sendable {
        var reading: Reading?
        var sections: [ReadingSection]
        var deletedSections: [ReadingSection]
        var assignments: [String: String]
    }

    func start() async {
        do {
            for try await value in session.database.observe({ [readingID] db in
                Snapshot(
                    reading: try Queries.reading(db, id: readingID),
                    sections: try Queries.readingSections(db, readingID: readingID),
                    deletedSections: try Queries.deletedReadingSections(db, readingID: readingID),
                    assignments: try Queries.sectionAssignments(db, readingID: readingID))
            }) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    func adopt(_ snapshot: Snapshot) {
        reading = snapshot.reading
        sections = snapshot.sections
        deletedSections = snapshot.deletedSections
        assignments = snapshot.assignments
        if !modeSeeded, let reading = snapshot.reading {
            mode = Self.defaultMode(for: reading)
            modeSeeded = true
        }
    }

    /// R2: a FINISHED book is nothing but the text — it opens into the
    /// reading flow; a working book opens into OUTLINE, which is where the
    /// book is written (13c 2A, A39).
    nonisolated static func defaultMode(for reading: Reading) -> ViewMode {
        reading.locked ? .read : .outline
    }

    /// Chapters apply to curated books; smart/stamp-sorted books keep the
    /// Phase 4 tag-path headers.
    var chaptersActive: Bool {
        guard let reading else { return false }
        return reading.kind == .book && !sections.isEmpty
    }

    /// The grouped presentation (pure, pinned): chapters in (position, id)
    /// order, each with its member entries in the reading's own entry
    /// order; UNFILED entries last under a nil group (a chapter is an
    /// organization; stragglers trail — recorded call).
    nonisolated static func grouped(
        entries: [Queries.ReadingEntry],
        sections: [ReadingSection],
        assignments: [String: String]
    ) -> [(section: ReadingSection?, entries: [Queries.ReadingEntry])] {
        var bySection: [String: [Queries.ReadingEntry]] = [:]
        var unfiled: [Queries.ReadingEntry] = []
        for entry in entries {
            if let sectionID = assignments[entry.postID] {
                bySection[sectionID, default: []].append(entry)
            } else {
                unfiled.append(entry)
            }
        }
        var result: [(ReadingSection?, [Queries.ReadingEntry])] = sections.map {
            ($0, bySection[$0.id] ?? [])
        }
        if !unfiled.isEmpty {
            result.append((nil, unfiled))
        }
        return result
    }

    func grouped(entries: [Queries.ReadingEntry])
        -> [(section: ReadingSection?, entries: [Queries.ReadingEntry])] {
        Self.grouped(entries: entries, sections: sections, assignments: assignments)
    }

    // MARK: - Chapter CRUD (R28; movable chapters — sitting 2)

    func createChapter(named name: String) async {
        await run { try $0.createSection(in: self.readingID, name: name) }
    }

    func renameChapter(_ sectionID: String, to name: String) async {
        await run { try $0.renameSection(sectionID, name: name) }
    }

    func deleteChapter(_ sectionID: String) async {
        await run { try $0.deleteSection(sectionID) }
    }

    func restoreLastDeletedChapter() async {
        guard let newest = deletedSections.first else {
            lastError = "No deleted chapter to restore."
            return
        }
        await run { try $0.restoreSection(newest.id) }
    }

    /// Move a chapter one slot up/down (the movable-chapters gesture; the
    /// polished drag bar is Stage C's — R19).
    func moveChapter(_ sectionID: String, up: Bool) async {
        guard let index = sections.firstIndex(where: { $0.id == sectionID }) else { return }
        let target: Operations.InsertPosition
        if up {
            guard index > 0 else { return }
            target = .before(sections[index - 1].id)
        } else {
            guard index < sections.count - 1 else { return }
            target = .after(sections[index + 1].id)
        }
        await run { try $0.reorderSection(sectionID, to: target) }
    }

    /// R19's polished gesture (Stage C): drop a dragged chapter BEFORE
    /// `targetID` (nil = the end). Foreign strings and no-op drops (the
    /// chapter's own edges) touch nothing.
    func moveChapter(_ sectionID: String, before targetID: String?) async {
        guard sectionID != targetID,
              sections.contains(where: { $0.id == sectionID })
        else { return }
        if let targetID {
            guard let targetIndex = sections.firstIndex(where: { $0.id == targetID })
            else { return }
            if targetIndex > 0, sections[targetIndex - 1].id == sectionID { return }
            await run { try $0.reorderSection(sectionID, to: .before(targetID)) }
        } else {
            guard sections.last?.id != sectionID else { return }
            await run { try $0.reorderSection(sectionID, to: .end) }
        }
    }

    /// File a post into a chapter (nil = unfiled).
    func assign(_ postID: String, to sectionID: String?) async {
        await run { try $0.assignPostToSection(postID, in: self.readingID, section: sectionID) }
    }

    // MARK: - Drag & drop in a chaptered book (13f W11 — her ruling)

    /// Her W11 ruling, verbatim: *"i think we should fix the reach, but it
    /// should also be possible to pick up a post and move it to another
    /// chapter."*
    ///
    /// Batch 1's trace found no defect in the chapter drag — the machinery is
    /// byte-identical to the build she confirmed working — but found that a
    /// chapter's only drop targets were another chapter's HEADER (glyph-wide,
    /// in the body) and a 14 pt strip at the very bottom of the book. With two
    /// chapters, moving one DOWN had no target at all unless she found that
    /// strip. So the fix is reach: more targets, bigger targets, and a
    /// resolution rule for the ones that are not chapter headers.
    ///
    /// **The semantics are UNCHANGED.** Everything below resolves to the
    /// `moveChapter(_:before:)` / `assignPostToSection` doors that already
    /// existed and are already pinned; nothing here decides what a drop MEANS
    /// beyond "which existing anchor is nearest".
    ///
    /// The payload discriminates by prefix — the `LensesBoardView.dragPayload`
    /// precedent — because a chaptered book now drags TWO kinds of thing over
    /// the same drop targets, and a bare id could not tell them apart. It is
    /// still one `String` transferable, so no new payload type meets the
    /// standing post/block drags.
    nonisolated enum BookDrag: Equatable, Sendable {
        case chapter(String)
        case post(String)

        private static let chapterPrefix = "book-chapter:"
        private static let postPrefix = "book-post:"

        var payload: String {
            switch self {
            case .chapter(let id): return Self.chapterPrefix + id
            case .post(let id): return Self.postPrefix + id
            }
        }

        /// A payload from anywhere else in the app (a scrap, a catalog hit, a
        /// lens block) decodes to nil and the drop is refused — strictly
        /// better than the bare-id era, where a foreign string reached the
        /// model and was rejected only by an id lookup.
        static func decode(_ raw: String) -> BookDrag? {
            if raw.hasPrefix(chapterPrefix) {
                return .chapter(String(raw.dropFirst(chapterPrefix.count)))
            }
            if raw.hasPrefix(postPrefix) {
                return .post(String(raw.dropFirst(postPrefix.count)))
            }
            return nil
        }
    }

    /// Where a CHAPTER was dropped.
    nonisolated enum ChapterDropSite: Equatable, Sendable {
        /// A chapter's own header row — "before this chapter" (the shipped
        /// meaning, unchanged).
        case chapter(String)
        /// The gap immediately above a chapter's heading — the same meaning,
        /// with a target of its own so a chapter is reachable without hitting
        /// its heading exactly.
        case gapBefore(String)
        /// A post row. Snaps to the NEAREST chapter boundary.
        case end
        case post(String)
    }

    /// Resolves a chapter drop to the `before:` anchor `moveChapter` takes
    /// (nil = the end of the chapter order).
    ///
    /// "Nearest boundary" is measured in ROWS, not pixels: a post in the top
    /// half of its chapter takes the boundary above it, one in the bottom half
    /// the boundary below. Rows are what the model knows, and the alternative
    /// — geometry — would put the rule in a place no test can reach.
    nonisolated static func chapterDropTarget(
        _ site: ChapterDropSite,
        groups: [(section: ReadingSection?, entries: [Queries.ReadingEntry])]
    ) -> String? {
        switch site {
        case .end:
            return nil
        case .chapter(let id), .gapBefore(let id):
            return id
        case .post(let postID):
            guard let index = groups.firstIndex(where: { group in
                group.entries.contains { $0.postID == postID }
            }) else { return nil }
            let group = groups[index]
            // Unfiled trails every chapter, so a drop there means the end.
            guard let section = group.section else { return nil }
            let row = group.entries.firstIndex { $0.postID == postID } ?? 0
            if row * 2 < group.entries.count { return section.id }
            // The boundary BELOW this chapter: the next chapter's, or the end.
            let next = groups[(index + 1)...].first { $0.section != nil }
            return next?.section?.id
        }
    }

    /// Where a POST was dropped.
    nonisolated enum PostDropSite: Equatable, Sendable {
        /// A chapter's header — file it there, at that chapter's top.
        case chapter(String)
        /// Another post's row — file it into that post's chapter, above it.
        case post(String)
        /// The "unfiled" heading (or the book's tail): out of every chapter.
        case unfiled
    }

    /// What a post drop writes: the chapter it joins, and the membership
    /// anchor it lands above. `before == nil` leaves the book's order alone.
    nonisolated struct PostDropPlan: Equatable, Sendable {
        var sectionID: String?
        var before: String?
    }

    /// `nil` = nothing to do (a post dropped on itself).
    ///
    /// `reposition` is false unless POSITION is what orders the book on
    /// screen: under a stamp sort the stored manual order is not what she is
    /// looking at, and silently rewriting it from a drop would edit an order
    /// she cannot see. The chapter half of the drop always happens — that is
    /// what her ruling asked for.
    nonisolated static func postDropPlan(
        _ site: PostDropSite, dragged postID: String,
        groups: [(section: ReadingSection?, entries: [Queries.ReadingEntry])],
        reposition: Bool
    ) -> PostDropPlan? {
        switch site {
        case .unfiled:
            return PostDropPlan(sectionID: nil, before: nil)
        case .chapter(let sectionID):
            let first = groups
                .first { $0.section?.id == sectionID }?
                .entries.first?.postID
            return PostDropPlan(
                sectionID: sectionID,
                before: (reposition && first != postID) ? first : nil)
        case .post(let targetID):
            guard targetID != postID else { return nil }
            let group = groups.first { group in
                group.entries.contains { $0.postID == targetID }
            }
            return PostDropPlan(
                sectionID: group?.section?.id,
                before: reposition ? targetID : nil)
        }
    }

    /// What a post drop RESOLVES to on the book view's own rows (17y B3
    /// item 11 — F-B2-7, re-owned from the B2 ladder's round 1): the Book
    /// Panel's `BookPanelBrain.DropOutcome`, mirrored with B2's two settled
    /// orderings.
    nonisolated enum PostDropOutcome: Equatable, Sendable {
        /// Write this through the standing ops.
        case plan(PostDropPlan)
        /// Nothing to do — dropped on itself, or already where it stands (in
        /// a stamp order: onto its immediate SHOWN successor — NIT-4's rule).
        case nothing
        /// A note dropped to RE-PLACE it inside its own chapter (onto a
        /// sibling, or its own chapter's heading) while an OPEN book reads in
        /// a STAMP order: `postDropPlan` keeps the order she cannot see
        /// untouched, so the drop would file the note into the chapter it is
        /// already in — a write that changes nothing, under a hairline that
        /// promised "lands right above". It refuses WITH the road instead.
        case needsManualOrder
    }

    /// **THE ONE RESOLUTION every book-view post drop takes** (17y B3 item
    /// 11): `postDropPlan`, unchanged, plus the sort gate's honest answer.
    /// `frozen` = finished or sealed (`reading.locked` — sealing finishes
    /// too). **The lock answers FIRST** (the B2 ladder's MAJOR-1): a frozen
    /// book's plan runs as it is so the operation's own refusal speaks
    /// (reopen / unseal), because the sort advice's road — save a Manual
    /// order — is impossible there.
    nonisolated static func postDropOutcome(
        _ site: PostDropSite, dragged postID: String,
        groups: [(section: ReadingSection?, entries: [Queries.ReadingEntry])],
        reposition: Bool, frozen: Bool
    ) -> PostDropOutcome {
        guard let plan = postDropPlan(
            site, dragged: postID, groups: groups, reposition: reposition)
        else { return .nothing }
        if frozen { return .plan(plan) }
        // The gate: a stamp order, a plan that files the note into the
        // chapter it is ALREADY in, where the same drop in manual order
        // would have re-placed it.
        if !reposition, plan.before == nil,
           plan.sectionID == chapterKey(of: postID, in: groups),
           let manual = postDropPlan(site, dragged: postID, groups: groups, reposition: true),
           let before = manual.before, before != postID {
            // Already satisfied (NIT-4): onto its immediate shown successor
            // it would land right where it stands — no placement was asked.
            if before == shownSuccessor(of: postID, in: groups) { return .nothing }
            return .needsManualOrder
        }
        return .plan(plan)
    }

    /// The chapter a note is shown in (nil = unfiled, or a chapterless book).
    private nonisolated static func chapterKey(
        of postID: String,
        in groups: [(section: ReadingSection?, entries: [Queries.ReadingEntry])]
    ) -> String? {
        groups.first { $0.entries.contains { $0.postID == postID } }?.section?.id
    }

    /// The note shown right after `postID` in its own group (nil = last).
    private nonisolated static func shownSuccessor(
        of postID: String,
        in groups: [(section: ReadingSection?, entries: [Queries.ReadingEntry])]
    ) -> String? {
        guard let entries = groups.first(where: { $0.entries.contains { $0.postID == postID } })?
                  .entries,
              let index = entries.firstIndex(where: { $0.postID == postID }),
              index + 1 < entries.count
        else { return nil }
        return entries[index + 1].postID
    }

    /// True when a drop should also reposition the membership — i.e. the book
    /// is rendering in its stored MANUAL order (no view-local override, or an
    /// override that is itself manual).
    func repositionsOnDrop(viewOrder: Queries.ReadingOrder?) -> Bool {
        (viewOrder?.field ?? reading?.sortField ?? .manual) == .manual
    }

    /// The chapter drag's one door, site-shaped (13f W11a).
    func moveChapter(
        _ sectionID: String, onto site: ChapterDropSite,
        entries: [Queries.ReadingEntry]
    ) async {
        await moveChapter(
            sectionID,
            before: Self.chapterDropTarget(site, groups: grouped(entries: entries)))
    }

    /// **ONE brain behind every drop target in a chaptered book** (13f W11):
    /// decode the payload, dispatch to the door that owns that KIND of drag.
    /// Each SITE says what a chapter means there and what a post means there;
    /// nothing re-derives semantics, and an undecodable payload (a scrap, a
    /// catalog hit, a lens block) is refused rather than guessed at.
    ///
    /// It lives on the model rather than in a view because two views host
    /// post rows — the navigator and Outline's own body — and a dispatcher
    /// copied into both is the class of drift P-1 exists to kill.
    @discardableResult
    func acceptDrop(
        _ items: [String],
        chapter chapterSite: ChapterDropSite, post postSite: PostDropSite,
        entries: [Queries.ReadingEntry], viewOrder: Queries.ReadingOrder?
    ) -> Bool {
        guard let raw = items.first, let drag = BookDrag.decode(raw) else { return false }
        // 13i-b U3 — THE TEACHING MOMENT (the sitting record §3, verbatim:
        // "A hand-drag inside one is the teaching moment: 'Turn into a book
        // to arrange by hand?'"). A gathering holds no rows, so a hand-drag
        // in its view used to reach `assignPostToSection` and come back as
        // "That note isn't in this book." — true, and a dead end. The answer
        // is an OFFER on the one status seam (18i's kinds: offers always
        // show), and its act IS the bind's confirm (P-2: fire-and-DO — the
        // door opens the real sheet, with the order she is looking through).
        // Nothing is filed and nothing is written by the drag itself.
        if reading?.kind == .gathering, case .post = drag {
            offerToBind(viewOrder: viewOrder)
            return true
        }
        switch drag {
        case .chapter(let sectionID):
            Task { await moveChapter(sectionID, onto: chapterSite, entries: entries) }
        case .post(let postID):
            let reposition = repositionsOnDrop(viewOrder: viewOrder)
            Task {
                await filePost(
                    postID, onto: postSite, entries: entries, reposition: reposition,
                    viewOrder: viewOrder)
            }
        }
        return true
    }

    /// The teaching OFFER (13i-b U3): "Turn into a book to arrange by hand?"
    /// — its button opens the bind confirm for this gathering. A finished
    /// gathering refuses a bind (the op's own rule), so there the honest
    /// answer is the refusal in words, never an offer that can only fail.
    func offerToBind(viewOrder: Queries.ReadingOrder?) {
        guard let reading, reading.kind == .gathering else { return }
        guard !reading.locked else {
            session.status.refuse(ReadingsViewModel.message(
                OperationError.lockedReading(id: reading.id)))
            return
        }
        session.status.offer(
            BindCopy.teachingOffer,
            action: .init(label: BindCopy.teachingAction) { [weak self] in
                Task { await self?.openBindOffer(order: viewOrder) }
            })
    }

    /// The post drag's one door (13f W11b): assignment through the standing
    /// `assignPostToSection`, order through the standing
    /// `reorderReadingPost` — no new semantics, and a LOCKED book refuses
    /// through the operation itself, spoken (P-2; QUESTIONS #25(b)).
    ///
    /// 17y B3 item 11 (F-B2-7): it resolves through `postDropOutcome` — a
    /// stamp-ordered re-place inside the note's own chapter used to write
    /// nothing and say nothing; it now refuses WITH the road (the Book
    /// Panel's words, naming the order she is looking through — `viewOrder`
    /// when she browses in one, else the stored order), and a drop already
    /// satisfied stays a quiet nothing. A frozen book still answers first,
    /// through the operation (above).
    func filePost(
        _ postID: String, onto site: PostDropSite,
        entries: [Queries.ReadingEntry], reposition: Bool,
        viewOrder: Queries.ReadingOrder? = nil
    ) async {
        let plan: PostDropPlan
        switch Self.postDropOutcome(
            site, dragged: postID, groups: grouped(entries: entries),
            reposition: reposition, frozen: reading?.locked ?? false) {
        case .nothing:
            return
        case .needsManualOrder:
            let order = viewOrder.map(BookOrderChoices.label(for:))
                ?? BookOrderChoices.storedLabel(for: reading)
            lastError = BookPanelCopy.needsManualOrder(
                book: reading?.name ?? "This book", order: order)
            return
        case .plan(let resolved):
            plan = resolved
        }
        await run { [readingID] ops in
            try ops.assignPostToSection(postID, in: readingID, section: plan.sectionID)
            if let before = plan.before {
                try ops.reorderReadingPost(postID, in: readingID, to: .before(before))
            }
        }
    }

    // MARK: - Book settings (the navigator's third leg — R43)

    // (13i-c U3: `setFinished` RETIRED onto `BookStateDoors` — the settings
    // sheet's STATE section and the shelf menu share ONE road for the finish
    // pair, so Finish asks when arrivals wait (§24) and a sealed book shows
    // no Reopen, everywhere at once.)

    func rename(to name: String) async {
        // 13e E13 — the same guard the shelf's rename carries, at the book's
        // own door (her round-3 ruling; `excluding` is this book's row).
        await run {
            try $0.assertBookNameIsFree(name, excluding: self.readingID)
            try $0.renameReading(self.readingID, name: name)
        }
    }

    func setWordTarget(_ target: Int?) async {
        await run { try $0.setReadingWordTarget(self.readingID, wordTarget: target) }
    }

    func setMaxPosts(_ cap: Int?) async {
        await run { try $0.setReadingMaxPosts(self.readingID, maxPosts: cap) }
    }

    /// SAVE the order she is browsing in as the book's own (A31's second
    /// half — the lens grammar's "adopt": look freely, keep it when you
    /// like it). `setReadingSort` has existed since Phase 2 and lost its
    /// only door at Phase 13's IA rework; this is where it lives now.
    func saveOrder(_ order: Queries.ReadingOrder) async {
        await run {
            try $0.setReadingSort(
                self.readingID, field: order.field, direction: order.direction)
        }
    }

    // MARK: - Bind into a book (13i-b U3; the door 13c 2D shipped as "convert")

    /// The bind sheet's ITEM while it is up (13i-b U3) — held HERE rather than
    /// in the view because two roads open it: the navigator's "+ new chapter"
    /// on a gathering, and the teaching OFFER `acceptDrop` makes on a
    /// gathering's hand-drag, which is this model's to make. The item carries
    /// its own count (F-U2-3's fix shape).
    var bindOffer: BindOffer?

    /// Open the bind confirm for THIS gathering: load the offer (count
    /// included), then present it with one write. `order` is the A31 view
    /// order the book view is looking through, so the bind freezes what she
    /// sees.
    func openBindOffer(
        followUp: BindFollowUp = .none, order: Queries.ReadingOrder? = nil
    ) async {
        guard let reading, reading.kind == .gathering else { return }
        bindOffer = await BindOffer.load(
            session, reading: reading, followUp: followUp, order: order)
    }

    /// Bind, then finish the act she asked for. Returns true on success so
    /// the caller can run the follow-up (P-2's choreography: "+ new chapter"
    /// on a gathering binds AND opens the chapter prompt). The same row
    /// becomes the book and keeps collecting (the sitting record §14.6,
    /// §19.6); no "(collecting)" sibling any more (the ruling's clause).
    ///
    /// `order` (13c K6 review, K2): the A31 view-order override the book
    /// view is browsing through, so the bind freezes the order she is
    /// actually LOOKING at — the sheet's own promise. nil = the stored order.
    func bind(
        order: Queries.ReadingOrder? = nil,
        ownedNotes: Operations.BindOwnedNotes = .leaveOut
    ) async -> Bool {
        do {
            let readingID = readingID
            let result = try await session.runner.run { ops in
                try ops.convertSmartReadingToCurated(
                    readingID, order: order, ownedNotes: ownedNotes)
            }
            lastError = nil
            // 13i-c U3: the receipt names the owned-notes limb's outcome.
            session.status.receipt(BindCopy.bound(
                result.reading.name, count: result.membershipIDs.count,
                copied: result.copied.count, leftOut: result.leftOut.count,
                hearsActs: BindCopy.hearsActs(result.reading)))
            return true
        } catch let error as OperationError {
            lastError = ReadingsViewModel.message(error)
            return false
        } catch {
            lastError = String(describing: error)
            return false
        }
    }

    // MARK: - The journal-book entry door (R50, the B3 design detail)

    /// "New Entry" on a journal-profile book. THE DAILY BOOK routes
    /// through `createOrOpenJournalEntry` — the one-entry-per-day rule is
    /// the daily Journal's own rule and is UNTOUCHABLE (R50; the retired bridge's too, until 2026-09-04). OTHER journal
    /// books (the dream journal) mint a **`.generic`** dated post with
    /// one-block segmentation set explicitly (the notebook feel) and add
    /// it to THIS book — **NEVER container `profile='journal'`** (Stage B
    /// review round 2, BLOCKER: that profile+date shape IS the daily
    /// journal's identity — `canonicalJournalEntry` (and, then, the Fragments
    /// bridge sweep) keyed on it, so a `.journal` dream entry became
    /// "the day's entry" for ⌘J (and pushed/paused the bridge's day).
    /// Journal-BOOK identity lives on `reading.profile`, not the post).
    /// Several entries on one day stay legal in these books; the daily
    /// rule's scope is the daily SHAPE, which these entries no longer
    /// wear (pinned, red-on-old verified by revert).
    /// The designation read runs INSIDE the runner (round 2, MINOR: the
    /// pre-runner read raced).
    ///
    /// Round 3, MINOR — the Outcome doctrine at this sibling door (the
    /// round-2 ⌘J shape, applied consistently): on a LOCKED/FULL book the
    /// DAILY branch still opens the entry (the untouchable create-or-open)
    /// with a SPEAKING note; the NON-DAILY branch refuses BEFORE MINTING —
    /// `assertReadingAcceptsPosts` runs inside the serialized closure, so
    /// a concurrent lock can never strand a stray `.generic` post in the
    /// Pool — and its refusal speaks through the message table (the raw
    /// `String(describing:)` retired with it).
    func newEntry(day: String? = nil) async -> String? {
        let entryDay = day ?? JournalDay.dayString(from: Date())
        let database = session.database
        do {
            let readingID = readingID
            let outcome: (id: String, note: String?) = try await session.runner.run { ops in
                if try ops.dailyJournalBookID() == readingID {
                    let entry = try ops.createOrOpenJournalEntry(entryDate: entryDay)
                    do {
                        _ = try ops.addPostToReading(entry.container.id, to: readingID)
                    } catch OperationError.alreadyInReading {
                    } catch OperationError.lockedReading {
                        // A SEALED book's road out is Unseal (13i-c ladder
                        // round 1 — Reopen refuses there, `readingSealed`).
                        let sealed = ((try? database.read { db in
                            try Queries.reading(db, id: readingID)?.sealedAt != nil
                        }) ?? false)
                        return (entry.container.id,
                                sealed
                                ? "Today's entry opened, but this book is sealed — it "
                                    + "wasn't added. Unseal the book in its settings (that "
                                    + "reopens it too), or pick a new daily journal "
                                    + "(Use as Daily Journal)."
                                : "Today's entry opened, but this book is finished — it "
                                    + "wasn't added. Reopen the book in its settings, or pick "
                                    + "a new daily journal (Use as Daily Journal).")
                    } catch OperationError.readingAtCapacity {
                        return (entry.container.id,
                                "Today's entry opened, but this book is at its note cap — "
                                + "it wasn't added. Extend the cap in the book's settings.")
                    } catch OperationError.noteOwnedElsewhere, OperationError.noteMemberedElsewhere {
                        // 13i-c U4 (§4 row 15 — this model's own add road): an
                        // OWNERSHIP refusal at the daily book's door BELLS,
                        // exactly as ⌘J does (the sitting record §6: "an
                        // owned-elsewhere note bells, never throws") — the
                        // entry still opens, the note names who holds it, and
                        // the Arrivals line atop this book offers Copy in /
                        // Move in / Dismiss (row 19). The shared daily door is
                        // the act, so the pair is decided by the one rule.
                        let shelving = ops.shelveInDailyJournalBook(entry.container.id)
                        return (entry.container.id, JournalBooks.shelvingNote(
                            shelving, entryID: entry.container.id,
                            bookName: (try? ops.dailyJournalBookName() ?? nil)
                                ?? JournalBooks.defaultDailyBookName,
                            database: database))
                    }
                    return (entry.container.id, nil)
                }
                // REFUSE BEFORE MINT, now structural (13i-c ladder round 1,
                // the F-5 wing class): `newPostInReading` gates, mints and
                // members in ONE transaction — a refusal leaves no stray
                // post, the note is born in the BOOK's wing (§9 — a book
                // never spans wings), and the book's outflow rides exactly
                // as a hand-add's would. The old composite (assert →
                // createPost → addPostToReading) minted in wing '' under a
                // non-Home book.
                let post = try ops.newPostInReading(
                    readingID, profile: .generic, entryDate: entryDay)
                try ops.setSegmentationDefault(post.id, segmentation: .oneBlock)
                return (post.id, nil)
            }
            lastError = outcome.note
            return outcome.id
        } catch let error as OperationError {
            lastError = ReadingsViewModel.message(error)
            return nil
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }

    /// Sitting 9 (R62/R75): a NEW POST born INSIDE this book — one
    /// transaction (post + membership; refusals mint no stray), the
    /// non-journal sibling of "+ new entry".
    func newPost() async -> String? {
        do {
            let readingID = readingID
            let post = try await session.runner.run { ops in
                try ops.newPostInReading(readingID)
            }
            lastError = nil
            return post.id
        } catch let error as OperationError {
            lastError = ReadingsViewModel.message(error)
            return nil
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        do {
            try await session.runner.run(body)
            lastError = nil
        } catch let error as OperationError {
            lastError = ReadingsViewModel.message(error)
        } catch {
            lastError = String(describing: error)
        }
    }
}

/// The Today's-Entry door with the R50 ensure-membership half (shared by
/// the shelf button, ⌘J, and the palette): create-or-open THE day's entry
/// (the untouchable rule), then make sure a designated DAILY JOURNAL BOOK
/// exists (created + pinned + designated on first use) and holds the
/// entry — the journal lives on the shelf as ordinary membership (R38 +
/// R50). PROVISIONAL shape, QUESTIONS bundle.
enum JournalBooks {
    /// 13d batch 5 (#37(iii)): the name lives with the CREATION, which is
    /// now the shared core door's — this forwards so nothing drifts.
    nonisolated static var defaultDailyBookName: String {
        Operations.defaultDailyJournalBookName
    }

    /// The door's outcome: the entry ALWAYS opens; `note` speaks when the
    /// membership half couldn't happen (Stage B review round 2, MAJOR 2:
    /// finishing/filling the daily book is an EXPECTED gesture in the
    /// bounded-notebook flow — it must never wedge ⌘J into a thrown error,
    /// and never silently).
    struct Outcome: Equatable {
        let postID: String
        let note: String?
        /// 13i-e U2 (the architect's F-U1-6 ruling): a RECEIPT when the day's
        /// filing brought an archived daily Journal back ("it returns when a
        /// day arrives") — spoken on the status seam's receipt kind, so
        /// `receipt_style` governs. nil otherwise.
        var receipt: String? = nil
    }

    /// The derived daily Journal's id and whether it is archived — read
    /// BEFORE and AFTER the shelving at the door (P-13ie-U1-13's shape: the
    /// shared shelving result stays unchanged). nil when there is none.
    nonisolated static func dailyJournalArchiveState(
        _ database: AppDatabase
    ) -> (id: String, archived: Bool)? {
        (try? database.read { db -> (id: String, archived: Bool)? in
            guard let id = try Queries.dailyJournalBookID(db),
                  let book = try Queries.reading(db, id: id)
            else { return nil }
            return (id, book.archivedAt != nil)
        }) ?? nil
    }

    /// The comes-back RECEIPT, decided from the two reads: the SAME book was
    /// archived before the filing and is not after.
    nonisolated static func comesBackReceipt(
        before: (id: String, archived: Bool)?, after: (id: String, archived: Bool)?
    ) -> String? {
        guard let before, before.archived, let after, after.id == before.id, !after.archived
        else { return nil }
        return BookArchiveCopy.journalCameBack
    }

    /// **What the daily door SAYS about its shelving** — ONE mapping for ⌘J
    /// (`openToday`) and the daily book's own "+ new entry" (13i-c U4: the
    /// two doors share the shelving rule, so they share its words). nil when
    /// there is nothing to say (shelved, or the pair already decided).
    nonisolated static func shelvingNote(
        _ shelving: Operations.DailyBookShelving, entryID: String, bookName: String,
        database: AppDatabase
    ) -> String? {
        switch shelving {
        case .shelved, .alreadyDecided:
            return nil
        case .bookFinished:
            // The daily book is FINISHED (the bounded-notebook flow's
            // expected end): the entry still opens; the note speaks and
            // points at the re-designation door. A SEALED Journal's road out
            // is UNSEAL (13i-c ladder round 1 — Reopen refuses on a sealed
            // book, `readingSealed`, R-13ic-3).
            let sealed = ((try? database.read { db -> Bool in
                guard let id = try Queries.dailyJournalBookID(db),
                      let book = try Queries.reading(db, id: id)
                else { return false }
                return book.sealedAt != nil
            }) ?? false)
            if sealed {
                return "Today's entry opened, but “\(bookName)” is sealed — "
                    + "it wasn't added. Pick a new daily journal from a book's "
                    + "menu on the Bookcase (Use as Daily Journal), or unseal "
                    + "“\(bookName)” (that reopens it too)."
            }
            return "Today's entry opened, but “\(bookName)” is finished — "
                + "it wasn't added. Pick a new daily journal from a book's "
                + "menu on the Bookcase (Use as Daily Journal), or reopen “\(bookName)”."
        case .bookAtCapacity:
            return "Today's entry opened, but “\(bookName)” is at its note cap — "
                + "it wasn't added. Extend the cap or start a new daily journal "
                + "(Use as Daily Journal in a book's menu on the Bookcase)."
        case .wrongKind:
            // 13i-d U6 (a): the ruled noun (§1) — a gathering holds nothing.
            return "Today's entry opened, but “\(bookName)” is a gathering — "
                + "it shows what its rule matches and can't hold entries. Pick a "
                + "book with Use as Daily Journal."
        case .waitingAtDoor(let readingID):
            // 13i-c U2 (the sitting record §6 — "an owned-elsewhere note
            // bells, never throws"): book ownership kept the entry from
            // joining on its own, so it waits at the Journal's door for her
            // judgment. 13i-c U4 (F-U2-6): the note NAMES who holds it.
            let facts = (try? database.read { db -> (owned: Bool, others: [Queries.NoteMembership]) in
                (try Queries.reading(db, id: readingID)?.owned ?? false,
                 try Queries.noteMemberships(db, postID: entryID, excluding: readingID))
            })
            return JournalWaitingCopy.note(
                journal: bookName, journalOwned: facts?.owned ?? false,
                elsewhere: facts?.others.map(\.book.name) ?? [],
                owner: facts?.others.first(where: \.owned)?.book.name)
        case .refused:
            // The shared door creates a book where none is designated,
            // so only a race or a store failure reaches here — and it
            // gets a speaking note rather than a silent miss.
            return "Today's entry opened, but it wasn't added to a daily "
                + "journal book. Pick one with Use as Daily Journal."
        }
    }

    @MainActor
    static func openToday(session: AppSession, day: String? = nil) async throws -> Outcome {
        let entryDay = day ?? JournalDay.dayString(from: Date())
        let database = session.database
        // The designation read runs INSIDE the runner (round 2, MINOR:
        // two rapid invocations both saw nil pre-runner and minted two
        // "Journal" books).
        return try await session.runner.run { ops in
            let entry = try ops.createOrOpenJournalEntry(entryDate: entryDay)
            // 13i-e U2 — read the Journal's archive state BEFORE the filing
            // (the comes-back receipt's first half).
            let before = dailyJournalArchiveState(database)
            // The ENSURE half — CREATE-AND-PIN INCLUDED — delegates WHOLLY
            // to the one implementation (13c Stage 1 ladder R1-4, completed
            // by the author's 13d #37(iii) ruling). This door used to call
            // `addPostToReading` itself and catch `alreadyInReading`, which
            // fires on LIVE rows only — so a membership she had deliberately
            // removed (a tombstoned row) was invisible here and ⌘J silently
            // put the entry back on the shelf, while the bridge and the
            // phone correctly left it alone. Then create-and-pin stayed
            // behind as the ONE residue, on the reasoning that minting a
            // book is a button-press-only act — which she overturned: the
            // bridge's days belong in Journal too. So all four doors share
            // one rule with nothing left at this one.
            let shelving = ops.shelveInDailyJournalBook(entry.container.id)
            let bookName = (try? ops.dailyJournalBookName() ?? nil) ?? defaultDailyBookName
            return Outcome(
                postID: entry.container.id,
                note: shelvingNote(
                    shelving, entryID: entry.container.id, bookName: bookName,
                    database: database),
                receipt: comesBackReceipt(before: before, after: dailyJournalArchiveState(database)))
        }
    }
}

/// **THE DAILY DOOR'S WAITING NOTE** (13i-c U4 — F-U2-6: the refusals carry
/// ids, so the face names the books). The §3 plan's sentence: "Today's entry
/// opened — it's waiting at the Journal's door, because “X” owns it." Pure,
/// so pins read it. Wording PROVISIONAL (13s).
nonisolated enum JournalWaitingCopy {
    static func quoted(_ name: String) -> String { "\u{201C}\(name)\u{201D}" }

    static func note(
        journal: String, journalOwned: Bool, elsewhere: [String], owner: String?
    ) -> String {
        let lead = "Today's entry opened \u{2014} it's waiting at \(quoted(journal))'s door, "
        if let owner, !journalOwned {
            return lead + "because \(quoted(owner)) owns it. Open \(quoted(journal)) to copy "
                + "it in or dismiss it."
        }
        if journalOwned, !elsewhere.isEmpty {
            return lead + "because \(quoted(journal)) owns its notes and the entry also lives "
                + "in \(MembershipChoiceCopy.list(elsewhere)). Open \(quoted(journal)) to copy "
                + "it in, move it in, or dismiss it."
        }
        return lead + "because it already lives in another book and one of them owns its "
            + "notes. Open \(quoted(journal)) to judge it."
    }
}
