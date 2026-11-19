//
//  WingsModel.swift
//  Variorum (shared: Mac + Mobile)
//
//  13i-d U5 — THE WINGS' brain (the sitting record §9; §21 Direction C's
//  switcher; her R-13id-2; the per-item cross-wing doors). Four Mac features
//  consume it — the Bookcase masthead's switcher, the Library's and the
//  Pool's note rows (Move/Copy to Wing ▸), and Compare's lineage line ("go to
//  that wing") — and a feature never constructs or holds a sibling's model
//  (CLAUDE.md): each surface owns one.
//
//  It holds a projection (the live wings) and sends operations; every refusal
//  speaks the operations layer's own words, every act a receipt in the quiet
//  slot (P-13id-U1-13's class).
//
//  VM-63 (the VM-55 run, "Wings underneath", batch 3) — MOVED HERE from the
//  Mac's `Core/Views/` so a phone wing face composes the same brain (MobileSoul
//  §3: brains in shared code, platforms own faces). Byte for byte, but for
//  the seams a shared brain needs, each named where it sits:
//  · the refusal WORDS are handed in (`refusalWords` — the Mac's
//    `init(session:)` passes `OpsRefusalCopy.message(for:)`, the Mac's half of
//    the table, so every Mac site speaks exactly as before);
//  · the MCP reach hold and the ⌘digit chord's answer are the Mac's
//    (`Variorum/Core/Views/WingsModel+Mac.swift`), the reach landing through
//    `adoptReach`;
//  · `landInBookcase` was already the window's to wire.
//  With it moved the open note's wing context (`NoteMenuWingContext` — the
//  read and its stale-load gates, which the Mac's note ▾ bar renders from). It
//  speaks through the one status seam both platforms share (`session.status`):
//  a receipt stays a receipt, a refusal a refusal — it never says `removal` or
//  `withdraw`s (pinned for the hoisted files by `VM61MacStatusSeamPinTests`).
//  The Mac's faces stay the Mac's: the switcher menu and sheet, the toolbar
//  label, the note doors and their confirm (`WingNoteDoors.swift`), the book
//  doors' confirms (`WingBookMoves.swift`).
//

import Foundation
import GRDB
import Observation
import VariorumCore

@MainActor
@Observable
final class WingsModel {
    @ObservationIgnored let session: AppSession
    /// **VM-63 — the platform's words for an operations refusal** (the hoist's
    /// one words seam). The Mac's are `OpsRefusalCopy.message(for:)` — its own
    /// arms, then the shared table on the Mac's roads — handed in by the Mac's
    /// `init(session:)` (`WingsModel+Mac.swift`); a phone face hands its own
    /// road (the shared table's `sentence(for:roads:)`).
    @ObservationIgnored let refusalWords: (Error) -> String

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

    init(session: AppSession, refusalWords: @escaping (Error) -> String) {
        self.session = session
        self.refusalWords = refusalWords
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

    /// VX-268 — one answer from the reach hold (`watchSharing`, the Mac's
    /// half — the MCP door is the Mac's), landed only when it changed.
    func adoptReach(_ value: [String: [MCPPlaceReach]]) {
        guard reach != value else { return }
        reach = value
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

    /// The wings a note or book in `wingID` can move or copy to (every other
    /// row) — empty when only one library exists, so the doors are not drawn
    /// (P-2).
    ///
    /// VX-878 ladder F1: `wingID` is read as surfaces read it (R-13ia-2 — an
    /// id naming no live wing is Home's: `Queries.wingScope`,
    /// `Queries.effectiveWing`, this model's own `name(of:)`), so a book whose
    /// wing died — a stored, dangling `wing_id` — is never offered Home, where
    /// it already lives. One heal for every face that hands in a stored id
    /// (the book rows, Book Settings' wing row, the note-title menu, ⌘K).
    func destinations(from wingID: String) -> [Row] {
        let effective = wings.contains { $0.id == wingID } ? wingID : ""
        return rows.filter { $0.id != effective }
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

    /// A switch made by the SWITCHER's new doors — ⌘L's commit, the masthead
    /// word's cycle and (VX-824) the ⌘digit chord — SPEAKS the existing
    /// "Now in …" receipt (the cross-wing follow's, `WingFollow.nowIn`): a
    /// cycle is blind until it is said. The in-menu picker keeps 13i-d's
    /// silence (there she reads the name she picked) — `goTo(_:saying:)`.
    /// Switching to where she already is says nothing — and, since VX-833,
    /// still LANDS (the deliberate road below).
    func switchSaying(_ id: String) {
        goTo(id, saying: true)
    }

    // MARK: - VX-833 — THE DELIBERATE SWITCH LANDS IN THE WING'S BOOKCASE

    /// **Where a deliberate switch lands** — wired by the window that owns
    /// this model (`RootView.wireWingLanding`: the shell's one request road,
    /// `pendingSelection = .shelf`, adopted into the focused pane). Composition,
    /// never a broadcast (P-4): the model says "a deliberate switch happened",
    /// the window decides it means "show the Bookcase". A model no window
    /// wired (a pin, a preview) lands nowhere.
    @ObservationIgnored var landInBookcase: () -> Void = {}

    /// **THE ONE DELIBERATE ROAD** (VX-833, her ruling: *"let's just keep
    /// landing in the bookcase. i want it to be consistent"*; the run's fork
    /// ruling, Q-B2 (a) + P-828-1 (ii)(a)). Every door whose act is choosing a
    /// wing — ⌘L's sheet (and so the toolbar's "in ‹wing›", which opens it),
    /// the masthead ▾ list, the masthead word's cycle, the ⌘digit chord —
    /// comes here: the app's one wing switches (when it is another) and the
    /// focused pane lands on that wing's Bookcase. The CURRENT wing, picked
    /// deliberately, lands too — "pick a wing" means one thing on every road —
    /// with no receipt (the wing did not change). NOT here, by the ruling: the
    /// cross-wing follow (`WingFollow`), New Wing…'s switch-in, Delete Wing's
    /// return to Home, a dead wing's revalidation, Compare's lineage "go to
    /// ‹wing› ›" and the MCP door's wing landing.
    ///
    /// **VX-870 — the ONE carve-out** (her word at the VX-828 bundle sitting,
    /// Q-B2: *"it would be nice if clicking it in library didn't move you
    /// either"*): `landing: false` is the LIBRARY masthead's cycle only
    /// (`cycleInPlace`) — the wing switches and is said, and she stays in the
    /// Library, which re-scopes under her. Every other door still lands.
    func goTo(_ id: String, saying: Bool, landing: Bool = true) {
        if id != currentID {
            switchTo(id)
            if saying {
                session.status.receipt(WingFollow.nowIn(name(of: id), isHome: id.isEmpty))
            }
        }
        if landing { landInBookcase() }
    }

    /// The masthead's cycling click goes here (nil with one wing — the word
    /// is then no cycle door, P-2).
    var nextWing: WingSwitcherBrain.Row? {
        WingSwitcherBrain.next(after: currentID, in: switcherRows)
    }

    /// The masthead word, clicked without typing: the next wing, said — and
    /// (VX-833) landed on its Bookcase, like every deliberate switch.
    func cycle() {
        if let nextWing { switchSaying(nextWing.id) }
    }

    /// **VX-870 (the VX-914 run, batch 4) — the LIBRARY masthead's cycle
    /// switches IN PLACE**: the next wing, said ("Now in …" — a cycle is blind
    /// until it is said), and NO landing — she stays in the Library and it
    /// re-scopes to the new wing under her (its listing re-asks on the wing:
    /// `LibraryCatalogView`'s `.task(id: session.wing.currentID)`), so clicking
    /// again keeps cycling where her pointer already is. The deliberate carve-
    /// out from VX-833's one road (the vx-828 record's Q-B2 (b) shape, the
    /// Library only): the Bookcase's cycle (`cycle`, which lands where she
    /// already stands), ⌘L, the ▾ list and ⌘1–⌘9 all still land on the wing's
    /// Bookcase.
    func cycleInPlace() {
        if let nextWing { goTo(nextWing.id, saying: true, landing: false) }
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
            session.status.refuse(refusalWords(error))
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
            session.status.refuse(refusalWords(error))
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
            session.status.refuse(refusalWords(error))
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
            session.status.refuse(refusalWords(error))
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
            session.status.refuse(refusalWords(error))
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

/// **The words the wings' brain SPEAKS** — its receipts and refusals (VM-63:
/// declared with the brain, so either platform's brain says them; every word
/// the Mac's FACES say is the Mac's extension, `WingsModel+Mac.swift`, and the
/// platform-neutral nouns are `WingWords`). 13s-revoicable — PROVISIONAL
/// P-13id-U5-11.
nonisolated enum WingCopy {
    // 13i-d U6 (b) — "a wing presents as a SEPARATE LIBRARY" (the sitting
    // record §9's language line): the noun stays WING (lesson 11 — "A wing
    // is a separate library in the same app"; "Library" already names the
    // finder), and the doors that MAKE or CROSS one say what it is.
    static func minted(_ name: String) -> String {
        "Made the wing \u{201C}\(name)\u{201D} \u{2014} a separate library; you're in it now."
    }
    static func deleted(_ name: String) -> String { "Deleted the wing \u{201C}\(name)\u{201D}." }
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
}
