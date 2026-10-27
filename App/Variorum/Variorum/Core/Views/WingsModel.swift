//
//  WingsModel.swift
//  Variorum
//
//  13i-d U5 — THE WINGS' Mac brain (the sitting record §9; §21 Direction C's
//  switcher; her R-13id-2; the per-item cross-wing doors). In the SHARED home
//  (`Core/Views/`) because four features consume it — the Bookcase masthead's
//  switcher, the Library's and the Pool's note rows (Move/Copy to Wing ▸),
//  and Compare's lineage line ("go to that wing") — and a feature never
//  constructs or holds a sibling's model (CLAUDE.md): each surface owns one.
//
//  It holds a projection (the live wings) and sends operations; every refusal
//  speaks the operations layer's own words (`OpsRefusalCopy`), every act a
//  receipt in the quiet slot (P-13id-U1-13's class).
//

import Foundation
import SwiftUI
import GRDB
import Observation
import VariorumCore

@MainActor
@Observable
final class WingsModel {
    @ObservationIgnored let session: AppSession

    /// The live ADDITIONAL wings, in switcher order (Home is virtual).
    private(set) var wings: [Wing] = []
    /// **VX-268 — who reaches each WING now** (the ONE icon on the switcher's
    /// rows — ⌘L's sheet and the ▾ menu; "a shared wing never shows as shared
    /// there"): `Queries.mcpWingReaches` — a wing grant on it or the open book,
    /// `decideWing`'s read. Keyed by wing id, Home `''`. ∝ the wings × the
    /// approved clients; never reads `container`.
    private(set) var reach: [String: [MCPPlaceReach]] = [:]
    /// **VX-377 (the VX-620 run, batch 4) — every wing act this model LANDED,
    /// counted** (`move`, `copy`, `moveBook`, `moveContents`): a SIGNAL the
    /// window's one-shot wing reads key on, so they re-ask after any wing act
    /// from ANY door in the window — the sidebar's note rows (their doors' wing,
    /// the Open indicator) and the note ▾ menu's context. VX-425's rule ("the
    /// wing listings re-ask after any move") held only per door before: each
    /// renderer's `onDone` re-asked its OWN surface, and ⌘K's selector has no
    /// surface's `onDone` to call. Never a decision (P-4) — each read asks the
    /// store again.
    private(set) var actGeneration = 0

    init(session: AppSession) {
        self.session = session
    }

    /// The four acts' one bump, after their write landed (a refusal changed
    /// nothing, so it signals nothing).
    func wingActLanded() {
        actGeneration &+= 1
    }

    /// Held — the `wing` table alone (a handful of rows; nothing else wakes it).
    func track() async {
        do {
            for try await value in session.database.observe({ db in try Queries.wings(db) }) {
                adopt(value)
            }
        } catch {}
    }

    /// Internal so the pins drive it deterministically.
    func adopt(_ new: [Wing]) {
        wings = new
        // 13n-c Stage B R1 B6: ⌘L's gate — Home + the live wings.
        session.wing.noteWingCount(new.count + 1)
        // A wing that died (here or on another device) returns the app home.
        let live = Set(new.map(\.id))
        session.wing.revalidate { $0.isEmpty || live.contains($0) }
    }

    func load() async {
        if let value = try? await session.database.read({ try Queries.wings($0) }) {
            adopt(value)
        }
    }

    /// VX-268 — hold every wing's reach (the main window's task, beside
    /// `track` — the window that renders the switcher).
    func watchSharing() async {
        await MCPRowReach.hold(session, { try Queries.mcpWingReaches($0) }) { [weak self] value in
            guard let self, self.reach != value else { return }
            self.reach = value
        }
    }

    // MARK: - What the faces read

    struct Row: Equatable, Identifiable {
        let id: String
        let name: String
    }

    var currentID: String { session.wing.currentID }
    var currentName: String { name(of: currentID) }

    func name(of id: String) -> String {
        id.isEmpty ? WingWords.home : (wings.first { $0.id == id }?.name ?? WingWords.home)
    }

    /// The switcher's rows: Home FIRST, then the live wings in order.
    var rows: [Row] {
        [Row(id: "", name: WingWords.home)] + wings.map { Row(id: $0.id, name: $0.name) }
    }

    /// The wings a note in `wingID` can move or copy to (every other row) —
    /// empty when only one library exists, so the doors are not drawn (P-2).
    func destinations(from wingID: String) -> [Row] {
        rows.filter { $0.id != wingID }
    }

    // MARK: - The switcher's acts

    /// The switch itself is a VIEW choice (a local memory, never the store —
    /// the Library `sort ▾` precedent), so it speaks nothing: the surfaces
    /// changing IS the answer.
    func switchTo(_ id: String) {
        session.wing.switchTo(id)
    }

    // MARK: - 13n-c U4 — ⌘L and the cycling masthead (VX-157)

    /// The switcher's rows in the pure brain's shape (Home first).
    var switcherRows: [WingSwitcherBrain.Row] {
        rows.map { WingSwitcherBrain.Row(id: $0.id, name: $0.name) }
    }

    /// A switch made by the SWITCHER's new doors — ⌘L's commit and the
    /// masthead word's cycle — SPEAKS the existing "Now in …" receipt (the
    /// cross-wing follow's, `WingFollow.nowIn`): a cycle is blind until it is
    /// said. The in-menu picker keeps 13i-d's silence (there she reads the
    /// name she picked). Switching to where she already is does nothing.
    func switchSaying(_ id: String) {
        guard id != currentID else { return }
        switchTo(id)
        session.status.receipt(WingFollow.nowIn(name(of: id), isHome: id.isEmpty))
    }

    /// The masthead's cycling click goes here (nil with one wing — the word
    /// is then no cycle door, P-2).
    var nextWing: WingSwitcherBrain.Row? {
        WingSwitcherBrain.next(after: currentID, in: switcherRows)
    }

    /// The masthead word, clicked without typing: the next wing, said.
    func cycle() {
        if let nextWing { switchSaying(nextWing.id) }
    }

    /// New Wing… — named at birth (the door guard refuses Home's name and a
    /// live wing's, E13's shape), then switched to.
    @discardableResult
    func mint(named raw: String) async -> Bool {
        let name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let wing = try await session.runner.run { ops -> Wing in
                try ops.assertWingNameIsFree(name, homeName: WingWords.home)
                return try ops.createWing(name: name)
            }
            await load()
            switchTo(wing.id)
            session.status.receipt(WingCopy.minted(wing.name))
            return true
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
            return false
        }
    }

    func rename(_ id: String, to raw: String) async {
        let name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try await session.runner.run { ops in
                try ops.assertWingNameIsFree(name, excluding: id, homeName: WingWords.home)
                try ops.renameWing(id, to: name)
            }
            await load()
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }

    /// Delete Wing… — R-13id-2 at the DOOR: the contents are read first, and
    /// a non-empty wing's door SPEAKS the refusal naming what remains (P-2:
    /// the door fires and the op's own answer is said) instead of asking a
    /// question whose only answer is no. Returns true when the confirm
    /// should show.
    func deleteAsk(_ id: String) async -> Bool {
        let contents = try? await session.database.read { db in
            try Queries.wingContents(db, wingID: id)
        }
        guard let contents else { return false }
        if !contents.isEmpty {
            session.status.refuse(WingWords.notEmpty(name(of: id), contents))
            return false
        }
        return true
    }

    func delete(_ id: String) async {
        let name = name(of: id)
        do {
            try await session.runner.run { ops in try ops.deleteWing(id) }
            if currentID == id { switchTo("") }
            await load()
            session.status.receipt(WingCopy.deleted(name))
        } catch OperationError.wingNotEmpty(_, let contents) {
            // Raced: something landed in it between the ask and the act.
            session.status.refuse(WingWords.notEmpty(name, contents))
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }

    // MARK: - The note doors (Move to Wing ▸ · Copy to Wing ▸)

    /// What the move's confirm says: the books the note will leave.
    struct MoveAsk: Identifiable, Equatable {
        let postID: String
        let title: String
        let wingID: String
        let wingName: String
        let leaves: [String]
        var id: String { postID + "→" + wingID }
    }

    /// The move's ask (`Queries.wingMovePreview` — the act's own predicate):
    /// a note in a FROZEN book refuses at once, naming it; a note that leaves
    /// books returns the confirm; a bookless note moves straight away (there
    /// is nothing to confirm — PROVISIONAL P-13id-U5-12). nil = acted or
    /// refused.
    func moveAsk(postID: String, title: String, to wingID: String) async -> MoveAsk? {
        guard let preview = try? await session.database.read({ db in
            try Queries.wingMovePreview(db, postID: postID)
        }) else { return nil }
        if let frozen = preview.frozenBook {
            session.status.refuse(WingCopy.frozen(title, book: frozen))
            return nil
        }
        guard !preview.leaves.isEmpty else {
            await move(postID: postID, title: title, to: wingID)
            return nil
        }
        return MoveAsk(
            postID: postID, title: title, wingID: wingID, wingName: name(of: wingID),
            leaves: preview.leaves)
    }

    func move(postID: String, title: String, to wingID: String) async {
        let wingName = name(of: wingID)
        do {
            let result = try await session.runner.run { ops in
                try ops.moveNoteToWing(postID, to: wingID)
            }
            wingActLanded()  // VX-377: the window's one-shot wing reads re-ask
            session.status.receipt(WingCopy.moved(title, to: wingName, left: result.leftBooks.count))
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }

    func copy(postID: String, title: String, to wingID: String) async {
        let wingName = name(of: wingID)
        do {
            _ = try await session.runner.run { ops in
                try ops.copyNoteToWing(postID, to: wingID)
            }
            wingActLanded()  // VX-377: the window's one-shot wing reads re-ask
            session.status.receipt(WingCopy.copied(title, to: wingName))
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }
}

/// Every Mac word the wing doors say (13s-revoicable — PROVISIONAL
/// P-13id-U5-11). The platform-neutral sentences are `WingWords`.
nonisolated enum WingCopy {
    static let newWingVerb = "New Wing\u{2026}"
    static let renameWingVerb = "Rename Wing\u{2026}"
    static let deleteWingVerb = "Delete Wing\u{2026}"
    static let moveToWingVerb = "Move to Wing"
    static let copyToWingVerb = "Copy to Wing"
    // 13n-c U4 (round 5 — the switcher joins the Library masthead; ⌘L, VX-157):
    // the note says where wings live now, both mastheads and the chord.
    static let unavailableNote = "Wings live at the top of the Bookcase and the Library \u{2014} "
        + "\u{201C}Bookcase \u{00B7} \(WingWords.home) \u{25BE}\u{201D} \u{2014} and \u{2318}L switches between them."

    // MARK: - 13n-c U4 — ⌘L and the cycling masthead (VX-157; round 5)

    /// ⌘L's menu verb (the View menu; the registry's `.switchWing`).
    static let switchWingVerb = "Switch Wing\u{2026}"
    /// 13n-c Stage B R1 B6 — why ⌘L is grey with ONE wing, and where another
    /// comes from (PROVISIONAL P-13nc-SB-2).
    /// Her sitting (2026-10-11, second round — P-13nc-SB-2 RULED with a
    /// reword): grey-with-a-note stands, but "masthead" was too opaque — the
    /// note says where New Wing… lives in plain words (PROVISIONAL for her
    /// copy pass).
    static let switchWingUnavailable = "There is only one wing so far \u{2014} \(newWingVerb) under the "
        + "wing name at the top of the Bookcase makes another, and then \u{2318}L switches between them."
    /// THE SWITCHER's one quiet line (round 5, her ruling: the wing-isolation
    /// UI makes clear Snippets is the one room shared across wings).
    static let snippetsShared = "Snippets is the one room every wing shares."
    /// ⌘L's field (mockup §6: type a few letters).
    static let switcherPrompt = "Switch to a wing"
    /// ⌘L's foot (mockup §6's, with her held-⌘ cycling said).
    static func switcherFoot(current: String) -> String {
        "\(current) is the current wing \u{00B7} \u{23CE} switches \u{00B7} hold \u{2318} and tap L to "
            + "step \u{00B7} esc closes"
    }
    static let noWingMatches = "No wing has that name."
    /// The masthead word's hover where it CYCLES (two or more wings).
    static func cycleHelp(next: String) -> String {
        "Next wing: \u{201C}\(next)\u{201D} \u{2014} or \u{2318}L to choose one"
    }
    /// The ▾ beside the cycling word: the list and the wing acts.
    static let menuDoorHelp = "Every wing \u{2014} switch to one, or make, rename, move or delete a wing"
    /// The wing whose row the switcher marks.
    static let currentMark = "current"
    static let noteUnavailableNote = "Moving or copying a note to another wing acts on a "
        + "note \u{2014} right-click its row in the Library or the Pool, or open it and use "
        + "its note \u{25BE} menu."

    /// The switcher list's header (13i-d U6 (b)).
    static let switcherHeader = "Wings \u{2014} each a separate library"
    static let newWingTitle = "New Wing"
    static let renameWingTitle = "Rename Wing"

    static func deleteTitle(_ name: String) -> String { "Delete the wing \u{201C}\(name)\u{201D}?" }
    static let deleteMessage = "It's empty. Its shelves go with it; nothing else is touched."

    // 13i-d U6 (b) — "a wing presents as a SEPARATE LIBRARY" (the sitting
    // record §9's language line): the noun stays WING (lesson 11 — "A wing
    // is a separate library in the same app"; "Library" already names the
    // finder), and the doors that MAKE or CROSS one say what it is.
    static func minted(_ name: String) -> String {
        "Made the wing \u{201C}\(name)\u{201D} \u{2014} a separate library; you're in it now."
    }
    static func deleted(_ name: String) -> String { "Deleted the wing \u{201C}\(name)\u{201D}." }

    static func moveTitle(_ title: String, to wing: String) -> String {
        "Move \u{201C}\(title)\u{201D} to \u{201C}\(wing)\u{201D}?"
    }
    static func moveMessage(leaves books: [String]) -> String {
        let names = books.map { "\u{201C}\($0)\u{201D}" }
        let list = names.count <= 1 ? (names.first ?? "")
            : names.dropLast().joined(separator: ", ") + " and " + names.last!
        return "It leaves \(list) \u{2014} a wing is a separate library, and a book only "
            + "holds notes of its own wing. Its tags come with it."
    }
    static func moved(_ title: String, to wing: String, left: Int) -> String {
        left == 0
            ? "Moved \u{201C}\(title)\u{201D} to \u{201C}\(wing)\u{201D}."
            : "Moved \u{201C}\(title)\u{201D} to \u{201C}\(wing)\u{201D} \u{2014} it left "
                + "\(left) book\(left == 1 ? "" : "s")."
    }
    static func copied(_ title: String, to wing: String) -> String {
        "Copied \u{201C}\(title)\u{201D} to \u{201C}\(wing)\u{201D} \u{2014} a separate "
            + "library; the copy waits in its Pool."
    }
    static func frozen(_ title: String, book: String) -> String {
        "\u{201C}\(title)\u{201D} is in \u{201C}\(book)\u{201D}, which is finished \u{2014} "
            + "reopen it (or unseal it) before moving the note to another wing."
    }

    /// The lineage line (#166(e) — minimal naming, nothing deeper).
    static func versionElsewhere(_ wing: String) -> String {
        "a version of this note lives in another library \u{2014} the wing \u{201C}\(wing)\u{201D}"
    }
    static func goTo(_ wing: String) -> String { "go to \(wing) \u{203A}" }
}

// MARK: - The note-row doors (Move to Wing ▸ · Copy to Wing ▸) and the move's confirm

/// The two cross-wing doors on a note's row — ONE builder the Library's and
/// the Pool's row menus render (`SidebarView.contextMenuCapabilities`
/// declares them for the note-row grammar). Drawn only while another wing
/// exists (P-2). The row's note lives in the CURRENT wing (both surfaces list
/// the current wing's notes), so its destinations are every other wing.
struct WingNoteDoors: View {
    let wings: WingsModel
    let postID: String
    let title: String
    /// The wing the note LIVES in (13i-d U6 (k)): nil = the current wing —
    /// the Library's and the Pool's rows list only the current wing's notes;
    /// the note ▾ menu passes the open note's own wing, because an open note
    /// can be another wing's (the Open strip keeps it — F-U5-6).
    var fromWing: String? = nil
    /// The move's confirm, when the note leaves books (the caller presents it).
    let onAsk: (WingsModel.MoveAsk) -> Void
    /// After an act (the one-shot listings re-ask; held ones need nothing).
    var onDone: () -> Void = {}

    var body: some View {
        let others = wings.destinations(from: fromWing ?? wings.currentID)
        if !others.isEmpty {
            Menu(CapabilityRegistry.capability(.moveNoteToWing).verb) {
                ForEach(others) { row in
                    Button(row.name) {
                        Task {
                            if let ask = await wings.moveAsk(
                                postID: postID, title: title, to: row.id) {
                                onAsk(ask)
                            } else {
                                onDone()
                            }
                        }
                    }
                }
            }
            Menu(CapabilityRegistry.capability(.copyNoteToWing).verb) {
                ForEach(others) { row in
                    Button(row.name) {
                        Task {
                            await wings.copy(postID: postID, title: title, to: row.id)
                            onDone()
                        }
                    }
                }
            }
        }
    }
}

extension View {
    /// The move's confirm — LISTS the books the note leaves (a book never
    /// spans wings), the one question a cross-wing move asks.
    func wingMoveConfirm(
        _ pending: Binding<WingsModel.MoveAsk?>, wings: WingsModel?,
        onDone: @escaping () -> Void = {}
    ) -> some View {
        alert(
            pending.wrappedValue.map { WingCopy.moveTitle($0.title, to: $0.wingName) } ?? "",
            isPresented: Binding(
                get: { pending.wrappedValue != nil },
                set: { if !$0 { pending.wrappedValue = nil } }),
            presenting: pending.wrappedValue
        ) { ask in
            Button("Move") {
                Task {
                    await wings?.move(postID: ask.postID, title: ask.title, to: ask.wingID)
                    onDone()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { ask in
            Text(WingCopy.moveMessage(leaves: ask.leaves))
        }
    }
}

// MARK: - The note ▾ menu's renderer (13i-d U6 (k))

/// **What the note ▾ menu needs to render the cross-wing doors** — the open
/// note's wing as surfaces read it (`Queries.effectiveWing`) and its display
/// name (the confirm's and the receipt's words). Read once per note and again
/// after an act (a move changes the note's wing).
///
/// 13i-d LADDER B fix B (round 1's MINOR 2 — the ladder-A superseded-
/// observation class on U6's new code): the context carries the NOTE it was
/// loaded for, and the bars render only a MATCHING one (`matching`) — a load
/// that lands after the open note changed (or a cancellation's nil, written
/// by a task that died mid-read) can no longer draw another note's
/// destinations or put its title on the confirm. The write sites below also
/// take the sibling cancellation guard (`NoteMembershipModel`'s lesson).
struct NoteMenuWingContext: Equatable, Sendable {
    /// The note this context was loaded FOR — the gate's key.
    let postID: String
    let wingID: String
    let title: String

    static func load(_ session: AppSession, postID: String) async -> NoteMenuWingContext? {
        try? await session.database.read { db in
            guard let wing = try Queries.effectiveWing(db, ofPost: postID) else { return nil }
            return NoteMenuWingContext(
                postID: postID, wingID: wing,
                title: try Queries.noteDisplayTitle(db, id: postID) ?? "")
        }
    }

    /// The render gate, pure and pinned: the context, iff it is the OPEN
    /// note's own — anything else (another note's stale load, nil) draws
    /// nothing until the note's own load lands.
    static func matching(
        _ context: NoteMenuWingContext?, postID: String
    ) -> NoteMenuWingContext? {
        guard let context, context.postID == postID else { return nil }
        return context
    }

    /// **The RELOAD gate** (the sanity pass's NIT on fix B, confirmed): a
    /// post-act reload runs in an UNSTRUCTURED Task, which nothing ever
    /// cancels — a `Task.isCancelled` guard there is dead — so the real
    /// guard is the SUBJECT: a reload adopts only over its own note's
    /// standing context. A reload for note A landing after the bar moved to
    /// B writes nothing (B's loaded context never blinks out behind the
    /// render gate); A's own refresh still lands. Pure, pinned.
    static func reloadAdopts(over current: NoteMenuWingContext?, postID: String) -> Bool {
        current?.postID == postID
    }

    /// **VX-377 — the context's LOAD key**: the note, and the window's wing-act
    /// signal (`WingsModel.actGeneration`). A move of THIS note from any other
    /// door — ⌘K's selector, a sidebar or Library row — re-loads it, so the
    /// note ▾ menu never lists the wing the note now lives in (VX-425's rule;
    /// before, only the bar's own doors' `onDone` re-asked it).
    struct LoadKey: Equatable, Sendable {
        let postID: String
        let wingActs: Int
    }

    static func loadKey(postID: String, wings: WingsModel?) -> LoadKey {
        LoadKey(postID: postID, wingActs: wings?.actGeneration ?? 0)
    }
}

extension View {
    /// The bar's half of the note ▾ wing doors: loads the open note's context
    /// (per note) and hosts the move's confirm — an alert cannot hang off a
    /// menu item, so the bar presents it (the Library row's own shape).
    /// The structured `.task` write is cancellation-guarded (fix B); the
    /// UNSTRUCTURED reloads are subject-guarded instead (`reloadAdopts` —
    /// the sanity pass's NIT: cancellation never reaches them), so either
    /// way a stale load never stomps the next note's context.
    func noteMenuWingDoors(
        session: AppSession, postID: String, wings: WingsModel?,
        context: Binding<NoteMenuWingContext?>, ask: Binding<WingsModel.MoveAsk?>
    ) -> some View {
        self
            // VX-377: keyed on the note AND the window's wing-act signal.
            .task(id: NoteMenuWingContext.loadKey(postID: postID, wings: wings)) {
                let loaded = await NoteMenuWingContext.load(session, postID: postID)
                guard !Task.isCancelled else { return }
                context.wrappedValue = loaded
            }
            .wingMoveConfirm(ask, wings: wings) {
                // An UNSTRUCTURED task: cancellation never reaches it, so
                // the subject check is the guard (`reloadAdopts` — the
                // sanity pass's NIT), applied AFTER the await, where the
                // stale landing happens.
                Task {
                    let loaded = await NoteMenuWingContext.load(session, postID: postID)
                    guard NoteMenuWingContext.reloadAdopts(
                        over: context.wrappedValue, postID: postID) else { return }
                    context.wrappedValue = loaded
                }
            }
    }
}

