//
//  MobileRefusalLeavesItsNoteTests.swift
//  VariorumMobileTests
//
//  VM-275 (the VM-260 run, batch 1b — a Bug; her rule in the ticket) — **A
//  REFUSAL RAISED IN A NOTE CLEARS WHEN SHE LEAVES THAT NOTE; THE LINE NEVER
//  SQUEEZES THE LIST.** Her report (2026-11-24, a screen recording): "it did
//  show a problem - the error toast stays up even past leaving the note, which
//  it shouldn't." The rule it sets: a refusal raised in a note clears when she
//  leaves the note; P-55-3's fade stands otherwise; the line stays one line
//  (P-55-10) and only its CLEARING learns about navigation.
//
//  THE TRACE, half 1 (the pre-fix tree): the one line's item lives in the
//  shared seam (`StatusCenter.current`) until its 6 s clock or a newer message
//  replaces it. The note screen's leaving road (`MobileWriteScreen`'s
//  `onDisappear` — teardown, the leaving savepoint, the hold given back; since
//  VM-256 every page change takes it too) withdraws only what the note's own
//  UNDO DOOR said (`MobileLine.withdrawNoteLine(of:)` → `withdraw(owner:)`),
//  and a refusal carries no owner — so a refusal raised in the note rode on,
//  over the Library, for the rest of its clock (her recording: about 5 s of
//  its 8.5 on a page with nothing to do with it).
//
//  THE TRACE, half 2 (the squeeze): nothing in the app's window reads the line.
//  The line is its own passthrough window over the scene (`MobileMessageLine
//  Host`), raised ONCE when the shell joins its window — never per message — and
//  no page, root or shell view observes `status.current` (a whole-tree search).
//  So no row of the list can move when a line shows: what reads as the list
//  "shrinking to make room above the tab bar" is the line's own face — a
//  full-width band on the bar's ground (the room) under the bar's hairline,
//  standing flush on the bar, so the bar appears to GROW over the list's foot
//  (the join refusal is three to four lines at 15 pt — about 100 pt, more than a
//  Library row). `theListNeverMovesWhileTheLineShows` holds that finding: a
//  GUARD, expected GREEN on both trees — which disposes the half's literal
//  mechanism (rows moving) as HOLLOW; the face's anatomy is VM-277's design
//  pass (the record's VM-277 proposal carries the cure).
//
//  THE PINS:
//  · `aRefusalRaisedInANoteClearsWhenSheLeavesIt` — RED ON OLD: the note's
//    real Copy door on a note with no words refuses ("This note has no text to
//    copy."); Back; the line is gone (old: still standing).
//  · `aLineSaidBeforeTheNoteOpenedOutlivesItsLeaving` — a GUARD (green on both):
//    only what was raised IN the note clears; a refusal standing when the note
//    opened is not the note's.
//  · `aRemovalSaidInTheNoteOutlivesItsLeaving` — a GUARD (green on both): a
//    removal's line (the note's delete pops the screen while its Put back line
//    stands) is not a refusal and outlives the leaving.
//  · `theListNeverMovesWhileTheLineShows` — the half-2 GUARD above.
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-275 — a refusal raised in a note clears when she leaves it; the list never moves under the line", .serialized)
struct MobileRefusalLeavesItsNoteTests {

    /// The join refusal her recording showed — three to four lines on the phone.
    static let longRefusal = "This keystroke can't join these two blocks. Merge the blocks deliberately "
        + "instead (··· → Merge with Previous), which brings every take along."

    /// The on-window copy of a door (the band's two other roots are in every
    /// walk, a screen away).
    private func onWindow<V: View>(_ surface: HostedSurface<V>, _ label: String) -> NSObject? {
        let window = surface.window.bounds.insetBy(dx: 1, dy: 1)
        return surface.visibleElements.first {
            $0.accessibilityLabel == label && window.intersects($0.accessibilityFrame)
        }
    }

    private func titledNote(_ session: AppSession, _ title: String, words: String? = nil) async throws -> String {
        try await session.runner.run { ops -> String in
            let post = try ops.createPost(title: title, profile: .blog)
            if let words {
                _ = try ops.newBlock(in: post.id, text: words, at: .end, registeringUndo: false)
            }
            return post.id
        }
    }

    /// On the Library, its row opened, its editor standing.
    private func openFromTheLibrary<V: View>(
        _ surface: HostedSurface<V>, router: MobileShellRouter, title: String, postID: String
    ) async {
        #expect(onWindow(surface, "Library")?.accessibilityActivate() == true,
                "labels: \(surface.visibleLabels)")
        await surface.settle(40)
        for _ in 0..<100 where onWindow(surface, title) == nil {
            await surface.settle(1)
        }
        #expect(onWindow(surface, title)?.accessibilityActivate() == true,
                "the note's row: \(surface.visibleLabels)")
        for _ in 0..<200 where router.editors.registeredPostIDs != [postID] {
            await surface.settle(1)
        }
        await surface.settle(20)
        #expect(router.editors.registeredPostIDs == [postID], "the note is open")
    }

    /// The pushed note's system Back, then the leaving road run to its end.
    private func leaveByBack<V: View>(_ surface: HostedSurface<V>, router: MobileShellRouter) async {
        let back = surface.visibleElements.first {
            $0.accessibilityLabel == "Back" && $0.accessibilityTraits.contains(.button)
        }
        #expect(back?.accessibilityActivate() == true, "the note's Back: \(surface.visibleLabels)")
        for _ in 0..<200 where !router.editors.registeredPostIDs.isEmpty {
            await surface.settle(1)
        }
        await surface.settle(30)
        #expect(router.editors.registeredPostIDs.isEmpty, "the note left")
    }

    /// **RED ON OLD — her rule.** A refusal raised IN a note (the note's own
    /// Copy door, on a note with no words) is gone once she leaves the note. The
    /// seam's clock is held long so only the leaving can clear it.
    @Test func aRefusalRaisedInANoteClearsWhenSheLeavesIt() async throws {
        try await withEditorWorld { session, _ in
            session.status.dismissAfter = .seconds(60)
            let postID = try await titledNote(session, "Nothing here")
            let router = MobileShellRouter()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(30)
                await openFromTheLibrary(surface, router: router, title: "Nothing here", postID: postID)

                #expect(surface.activate("Copy Note"), "labels: \(surface.visibleLabels)")
                let refused = MobileNoteClipboard.Outcome.nothingToCopy.message
                for _ in 0..<200 where session.status.current?.text != refused {
                    await surface.settle(1)
                }
                let line = try #require(session.status.current, "the note's refusal is on the line")
                #expect(line.text == refused)
                #expect(line.kind == .refusal)

                await leaveByBack(surface, router: router)
                let still = session.status.current?.text ?? "nothing"
                #expect(session.status.current == nil,
                        "the refusal raised in the note left with the note — still showing: \(still)")
            }
        }
    }

    /// **A GUARD — only the note's own refusal clears.** A refusal already
    /// standing when the note opened was not raised in it, and the note's
    /// leaving leaves it to its clock.
    @Test func aLineSaidBeforeTheNoteOpenedOutlivesItsLeaving() async throws {
        try await withEditorWorld { session, _ in
            session.status.dismissAfter = .seconds(60)
            let postID = try await titledNote(session, "Plain", words: "Some words.")
            let router = MobileShellRouter()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(30)
                session.status.refuse("That couldn't be done.")
                let before = try #require(session.status.current)
                await openFromTheLibrary(surface, router: router, title: "Plain", postID: postID)
                await leaveByBack(surface, router: router)
                #expect(session.status.current?.id == before.id,
                        "a line from before the note opened is not the note's to clear")
            }
        }
    }

    /// **A GUARD — a removal outlives the leaving.** The note's delete pops its
    /// screen while its Put back line stands; a removal is not a refusal, and
    /// only refusals clear on leaving.
    @Test func aRemovalSaidInTheNoteOutlivesItsLeaving() async throws {
        try await withEditorWorld { session, _ in
            session.status.dismissAfter = .seconds(60)
            let postID = try await titledNote(session, "Plain", words: "Some words.")
            let router = MobileShellRouter()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(30)
                await openFromTheLibrary(surface, router: router, title: "Plain", postID: postID)
                session.status.removal(
                    "Note moved to the Trash.", undo: .init(label: MobileLine.undoLabel, perform: {}))
                let removal = try #require(session.status.current)
                await leaveByBack(surface, router: router)
                #expect(session.status.current?.id == removal.id, "the removal's line stands")
            }
        }
    }

    /// **HALF 2's TRACE, as a GUARD (expected GREEN on both trees).** On the
    /// Library with rows on screen, a four-line refusal takes the line: no row
    /// moves and none changes size — nothing in the app's window reads the line.
    /// Green on old disposes the half's literal mechanism (rows squeezed) as
    /// HOLLOW; what she saw is the line's face (see the header).
    @Test func theListNeverMovesWhileTheLineShows() async throws {
        try await withEditorWorld { session, _ in
            session.status.dismissAfter = .seconds(60)
            let titles = ["Row one", "Row two", "Row three", "Row four", "Row five"]
            for title in titles {
                _ = try await titledNote(session, title, words: "Words for \(title.lowercased()).")
            }
            let router = MobileShellRouter()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(30)
                #expect(onWindow(surface, "Library")?.accessibilityActivate() == true)
                await surface.settle(60)
                @MainActor func frames() -> [String: CGRect] {
                    var found: [String: CGRect] = [:]
                    for title in titles {
                        if let row = onWindow(surface, title) { found[title] = row.accessibilityFrame }
                    }
                    return found
                }
                let resting = frames()
                #expect(resting.count >= 3, "rows on the window: \(surface.visibleLabels)")

                session.status.refuse(Self.longRefusal)
                #expect(session.status.current != nil, "the line shows")
                await surface.settle(60)
                let showing = frames()
                #expect(showing == resting,
                        "no row moved or shrank while the line showed — resting \(resting), showing \(showing)")

                session.status.clear()
                await surface.settle(30)
                #expect(frames() == resting, "and none moved when it went")
            }
        }
    }
}
