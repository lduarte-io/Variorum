//
//  MobileWing.swift
//  VariorumMobile
//
//  VM-56 / VM-57 (the VM-55 run, "Wings underneath", batch 1) — THE PHONE
//  STANDS IN ONE WING. Her words (`notes/plans/vm-44/her-words.md`): "there
//  are no different wings (!!) so everything just shows up in one bunch but
//  it's hard to find items in the library." Her ruling SW-1: the wing's name
//  is the title on every root (the swipe, the dots and the dropdown are the
//  wave-2 wing face — this run builds no switcher, so a phone that never
//  switched stands in Home).
//
//  Small pieces, each a FACE-side read over the shared brains
//  (`Shared/WingState` — the current wing, its device memory, `revalidate`;
//  `Shared/WingsModel` — the held wings read; Core `Queries.wings`), never a
//  second rule:
//
//  · **FOLDED at VM-225 (batch 4):** batch 1's interim `MobileWingModel` — the
//    HELD wings observation that returned the phone Home when its wing died,
//    and named the wing for the roots' titles — is gone. Its `track` / `load` /
//    `adopt` were the Mac `WingsModel`'s three steps, and VM-63 (batch 3)
//    moved that brain to `Shared/`, so the shell now holds the shared
//    `WingsModel` itself (`MobileWingDoor.phoneWings`). The one thing the
//    shared brain does NOT say is batch 1's title rule — never a false
//    "Home" before the wings are read (`WingsModel.currentName` falls back
//    to "Home") — so that stays here, as a pure read over the brain's rows
//    (`MobileWingTitle.name`).
//  · `MobileWingScope.follow` — a held listing runs ONCE PER WING the phone
//    stands in: when the wing changes, the old run is cancelled and FINISHED
//    before the new one starts, so a listing never shows two wings at once
//    and never stays scoped to a wing that died. The Mac re-keys its views'
//    tasks on the wing (`.task(id: session.wing.currentID)`); the phone's
//    models follow it themselves, so a listing's re-read is a model fact the
//    pins can drive, and the views' task lines are untouched.
//  · `MobileWingTitle` — what a root's top line says: since VM-255 (her
//    R-260-1) the wing's name alone (P-55-2's "name · page" retired); since
//    VM-225 the name is a DOOR there (`MobileWingDoor.swift`).
//

import Foundation
import Observation
import VariorumCore

/// **A held listing, once per wing** (VM-57).
@MainActor
enum MobileWingScope {
    /// Runs `body` with the wing the phone stands in; when the wing changes,
    /// cancels it, waits for it to finish, and runs it again with the new
    /// wing. Returns when the calling task is cancelled, or when `body`
    /// returns on its own (a held observation that ended in an error stays
    /// ended, exactly as before this helper).
    static func follow(
        _ wing: WingState, _ body: @escaping @MainActor (String) async -> Void
    ) async {
        while !Task.isCancelled {
            let scope = wing.currentID
            let wingChanged = await withTaskGroup(of: Bool.self) { group -> Bool in
                // Both children hop to the main actor through their callees
                // (`body` and `changed` are main-actor-isolated).
                group.addTask {
                    await body(scope)
                    return false
                }
                group.addTask {
                    await MobileWingScope.changed(wing, from: scope)
                    return true
                }
                let first = await group.next() ?? false
                // The other child is cancelled AND awaited before this group
                // returns — the old wing's run is over before the new one
                // starts.
                group.cancelAll()
                return first
            }
            guard wingChanged else { return }
        }
    }

    /// Returns once the current wing differs from `scope` (or the task is
    /// cancelled).
    static func changed(_ wing: WingState, from scope: String) async {
        for await current in Observations({ wing.currentID }) where current != scope {
            return
        }
    }
}

/// **What a root's top line says** (VM-56; VM-255 — her R-260-1).
nonisolated enum MobileWingTitle {
    /// **The wing's name ALONE** (VM-255, her words: "I also don't think the
    /// Home · Bookcase and Home · Starred thing is necessary - it says on the
    /// bottom what area you're in"; R-260-1: the line is the wing's name, the
    /// wing door): Study reads "Home", Terminal "~/home" — the voice's own path
    /// grammar (`VoiceTokens.path`) over the one word. The page's word left
    /// the line; the bar's chip says where she is. A wing whose name is not yet
    /// read says nothing (never a false "Home").
    static func components(wing: String?) -> [String] {
        guard let wing, !wing.isEmpty else { return [] }
        return [wing]
    }

    /// **The roots' title — batch 1's rule, kept through the fold (VM-225).**
    /// "Home" for the virtual wing (known without a read), a live wing's own
    /// name once the wings are read, and nil while a non-Home wing's name is
    /// NOT yet read — never a false "Home" (the shared brain's
    /// `WingsModel.currentName` falls back to "Home" for an unread id, which is
    /// right for its Mac faces and wrong for a title). A rename arriving by
    /// sync re-titles the roots through the held read; a wing that died is
    /// gone from `wings`, and the revalidation the same read runs has already
    /// returned the phone Home.
    static func name(currentID: String, wings: [Wing]) -> String? {
        if currentID.isEmpty { return WingWords.home }
        return wings.first { $0.id == currentID }?.name
    }

    /// The shell's read of it, over the shared brain the shell holds.
    @MainActor
    static func name(of wings: WingsModel) -> String? {
        name(currentID: wings.currentID, wings: wings.wings)
    }

    /// **The line, in two pieces, so the wing's name can be a door
    /// (VM-225)** — the voice's prefix ("~/" in Terminal, nothing in Study) and
    /// the wing's name as the voice writes it. Put together they are, byte for
    /// byte, `VoiceTokens.path` over `components` — the line a root without a
    /// door draws — so making the name a door changes no letter (pinned).
    /// (VM-255: the page and the Bookcase's count that once trailed it left
    /// the line — the count is its own quiet line under the name.)
    @MainActor
    static func doorParts(_ tokens: VoiceTokens, wing: String) -> (lead: String, door: String) {
        (lead: tokens.pathPrefix, door: tokens.chromeLabel(wing))
    }
}
