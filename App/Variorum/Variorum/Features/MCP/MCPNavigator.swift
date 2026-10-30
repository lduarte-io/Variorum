//
//  MCPNavigator.swift
//  Variorum (MAC ONLY)
//
//  13n-b U4 — NAVIGATION's DELIVERY (R-13nb-23 + R-13nb-26 (g); AF-11 F-3).
//  Where `show_in_app` and a receipt's "Open ›" take her, delivered through
//  the roads her own doors already use — never a new landing mechanism (the
//  ceiling rule: every target is a state her doors reach):
//
//  · a NOTE — the shell's one adoption door with the caret-precise block
//    landing and, for `select`, the 13o find seed (`ShellRouter.adopt(_:in:
//    landing:find:)`: Write at the block, the words selected, the find bar
//    armed, the comfort band — the search passage's road verbatim);
//  · a note's TAKES at a block — the note opened, then her "see takes" door
//    (`CommandRouter.pendingTakesLanding = .bloom` + `requestMode(.takes)`);
//  · a LENS — the note opened, then the Lenses board told to show it
//    (`CommandRouter.pendingLensLanding` + `requestMode(.lenses)`);
//  · a BOOK, at a CHAPTER — the adoption door to the book, its Outline's
//    chapter landing parked for it (`ShellRouter.pendingBookChapter`);
//  · a WING (13n-c U6) — the app's one wing, switched as her switcher
//    switches it, the "Now in …" receipt naming the client.
//  · COMPARE (VX-336 U6a — VX-298) — the anchor opened, then its Compare
//    board told to show these notes beside it, replacing its columns
//    (`CommandRouter.pendingCompareLanding` + `requestMode(.compare)`).
//  · a SAVED VERSION (VX-675) — the VX-440 full-size page, its own
//    destination (`SidebarSelection.noteVersion` — the identity band, Back +
//    Promote, read-only, no per-note memory written: P-440-1), adopted
//    through the shell's one door exactly as a Versions row's "Open full
//    size" lands (`NoteVersionPage.open` → `RootView` → `.noteVersion`).
//
//  It decides nothing about WHETHER to move — `MCPShowRule` decides that, in
//  `MCPDoor`, before this is ever called (P-4: composition, never a
//  decision-bearing broadcast). Her OWN press (an ask's or a receipt's
//  "Open ›", ⌥⌘O) delivers through here too.
//

import Foundation
import VariorumMCP

@MainActor
struct MCPNavigator {
    let session: AppSession

    /// How long a takes or lens landing waits for the note it opened to
    /// register its detail (the next run loop, in practice). A var so the
    /// pins can shrink the timeout (ladder round 1, F-4).
    static var mountWait: Duration = .seconds(2)

    /// What a delivery came to (ladder round 1, F-4; VX-676).
    enum Delivery: Equatable {
        /// Everything landed.
        case delivered
        /// It could not FINISH while she was there: a takes/lens/compare
        /// target whose note never registered its detail inside `mountWait`,
        /// or whose mode request was refused. The caller answers the client
        /// honestly instead of claiming shown.
        case unfinished
        /// She LEFT the app mid-delivery (`stillStanding` — the agent road's
        /// etiquette, re-checked after the wait's suspension; her own press
        /// passes the default): nothing more moved. VX-676 — her amendment's
        /// letter: never refused for where she stands; the rest is the ask.
        case interrupted
    }

    /// Delivers the target (see `Delivery`).
    @discardableResult
    func deliver(
        _ target: MCPShowTarget, into router: ShellRouter,
        stillStanding: () -> Bool = { true }
    ) async -> Delivery {
        let pane = router.workspace.focusedPane
        switch target {
        case .note(let noteID, let blockID, let select):
            router.adopt(
                .post(noteID), in: pane, landing: blockID,
                find: select.map { EditorFindSeed(needle: $0, steps: true) })
            return .delivered
        case .takes(let noteID, let blockID):
            guard await open(noteID, in: router) else { return .unfinished }
            guard stillStanding() else { return .interrupted }
            session.commandRouter.pendingTakesLanding = .bloom(postID: noteID, blockID: blockID)
            if !session.commandRouter.requestMode(.takes, postID: noteID) {
                session.commandRouter.pendingTakesLanding = nil
                return .unfinished
            }
            return .delivered
        case .lens(let noteID, let lensID):
            guard await open(noteID, in: router) else { return .unfinished }
            guard stillStanding() else { return .interrupted }
            session.commandRouter.pendingLensLanding = LensLanding(postID: noteID, lensID: lensID)
            if !session.commandRouter.requestMode(.lenses, postID: noteID) {
                session.commandRouter.pendingLensLanding = nil
                return .unfinished
            }
            return .delivered
        case .compare(let noteID, let peerIDs):
            // VX-298 (D-298-5): the lens target's model — the anchor opened,
            // the landing parked for its Compare board (which replaces its
            // columns with exactly these and decides "related blocks only"
            // from its own projection), then her Compare mode requested.
            guard await open(noteID, in: router) else { return .unfinished }
            guard stillStanding() else { return .interrupted }
            session.commandRouter.pendingCompareLanding = CompareLanding(postID: noteID, peerIDs: peerIDs)
            if !session.commandRouter.requestMode(.compare, postID: noteID) {
                session.commandRouter.pendingCompareLanding = nil
                return .unfinished
            }
            return .delivered
        case .version(let noteID, let versionID):
            // VX-675: the full-size page is its own destination — the shell's
            // one adoption door, as "Open full size" lands it.
            router.adopt(.noteVersion(versionID, of: noteID), in: pane)
            return .delivered
        case .book(let bookID, let sectionID):
            router.pendingBookChapter = sectionID.map { .init(bookID: bookID, sectionID: $0) }
            router.adopt(.reading(bookID), in: pane)
            return .delivered
        case .wing(let wingID, let name, let client):
            // 13n-c U6 (VX-158 — the brief §8's A, mockup §7): her switcher's
            // OWN act — the app's one wing switched (wings scope listings;
            // editors never close on a switch, 17y (f)) — and the receipt says
            // who moved her. Already there: nothing moves and nothing is said
            // (⌘L's `switchSaying` rule).
            guard session.wing.currentID != wingID else { return .delivered }
            session.wing.switchTo(wingID)
            session.status.receipt(MCPReceiptCopy.shownWing(name, isHome: wingID.isEmpty, client: client))
            return .delivered
        }
    }

    /// The note's detail mounted and registered (already, or after the one
    /// adoption door opens it) — false when it never arrived.
    private func open(_ noteID: String, in router: ShellRouter) async -> Bool {
        if session.commandRouter.activePostID != noteID {
            router.adopt(.post(noteID), in: router.workspace.focusedPane)
        }
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: Self.mountWait)
        while session.commandRouter.activePostID != noteID {
            guard clock.now < deadline else { return false }
            try? await Task.sleep(for: .milliseconds(20))
        }
        return true
    }
}
