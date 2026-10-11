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
//    chapter landing parked for it (`ShellRouter.pendingBookChapter`).
//
//  It decides nothing about WHETHER to move — `MCPShowRule` decides that, in
//  `MCPDoor`, before this is ever called (P-4: composition, never a
//  decision-bearing broadcast).
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

    /// Delivers the target; FALSE when the delivery could not FINISH (ladder
    /// round 1, F-4): a takes/lens target whose note never registered its
    /// detail inside `mountWait`, whose mode request was refused, or — the
    /// re-check after the wait's suspension — the author left the app
    /// mid-delivery (`stillStanding`, the agent road's etiquette; her own
    /// press passes the default). The caller answers the client honestly
    /// instead of claiming shown.
    @discardableResult
    func deliver(
        _ target: MCPShowTarget, into router: ShellRouter,
        stillStanding: () -> Bool = { true }
    ) async -> Bool {
        let pane = router.workspace.focusedPane
        switch target {
        case .note(let noteID, let blockID, let select):
            router.adopt(
                .post(noteID), in: pane, landing: blockID,
                find: select.map { EditorFindSeed(needle: $0, steps: true) })
            return true
        case .takes(let noteID, let blockID):
            guard await open(noteID, in: router), stillStanding() else { return false }
            session.commandRouter.pendingTakesLanding = .bloom(postID: noteID, blockID: blockID)
            if !session.commandRouter.requestMode(.takes, postID: noteID) {
                session.commandRouter.pendingTakesLanding = nil
                return false
            }
            return true
        case .lens(let noteID, let lensID):
            guard await open(noteID, in: router), stillStanding() else { return false }
            session.commandRouter.pendingLensLanding = LensLanding(postID: noteID, lensID: lensID)
            if !session.commandRouter.requestMode(.lenses, postID: noteID) {
                session.commandRouter.pendingLensLanding = nil
                return false
            }
            return true
        case .book(let bookID, let sectionID):
            router.pendingBookChapter = sectionID.map { .init(bookID: bookID, sectionID: $0) }
            router.adopt(.reading(bookID), in: pane)
            return true
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
