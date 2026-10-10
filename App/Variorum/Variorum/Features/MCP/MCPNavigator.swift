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
    /// register its detail (the next run loop, in practice).
    static let mountWait: Duration = .seconds(2)

    func deliver(_ target: MCPShowTarget, into router: ShellRouter) async {
        let pane = router.workspace.focusedPane
        switch target {
        case .note(let noteID, let blockID, let select):
            router.adopt(
                .post(noteID), in: pane, landing: blockID,
                find: select.map { EditorFindSeed(needle: $0, steps: true) })
        case .takes(let noteID, let blockID):
            guard await open(noteID, in: router) else { return }
            session.commandRouter.pendingTakesLanding = .bloom(postID: noteID, blockID: blockID)
            if !session.commandRouter.requestMode(.takes, postID: noteID) {
                session.commandRouter.pendingTakesLanding = nil
            }
        case .lens(let noteID, let lensID):
            guard await open(noteID, in: router) else { return }
            session.commandRouter.pendingLensLanding = LensLanding(postID: noteID, lensID: lensID)
            if !session.commandRouter.requestMode(.lenses, postID: noteID) {
                session.commandRouter.pendingLensLanding = nil
            }
        case .book(let bookID, let sectionID):
            router.pendingBookChapter = sectionID.map { .init(bookID: bookID, sectionID: $0) }
            router.adopt(.reading(bookID), in: pane)
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
