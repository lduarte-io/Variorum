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
//  Three small pieces, each a FACE-side holder over the shared brain
//  (`Shared/WingState` — the current wing, its device memory, `revalidate`;
//  Core `Queries.wings`), never a second rule:
//
//  · `MobileWingModel` — the HELD wings observation (the `wing` table alone,
//    a handful of rows): a wing deleted here, or arriving deleted by sync,
//    returns the phone to Home through `WingState.revalidate`, the same three
//    steps the Mac's `WingsModel.adopt` takes; and it names the current wing
//    for the roots' titles. VM-63 (batch 3) hoists the Mac's `WingsModel` to
//    `Shared/`; wave 2's wing face composes that, and this holder folds into
//    it then.
//  · `MobileWingScope.follow` — a held listing runs ONCE PER WING the phone
//    stands in: when the wing changes, the old run is cancelled and FINISHED
//    before the new one starts, so a listing never shows two wings at once
//    and never stays scoped to a wing that died. The Mac re-keys its views'
//    tasks on the wing (`.task(id: session.wing.currentID)`); the phone's
//    models follow it themselves, so a listing's re-read is a model fact the
//    pins can drive, and the views' task lines are untouched.
//  · `MobileWingTitle` — what a root's path line says: the wing's name first,
//    then the page (P-55-2, PROVISIONAL — the batch record has the options).
//

import Foundation
import GRDB // AsyncValueObservation iteration (member import visibility)
import Observation
import VariorumCore

@MainActor
@Observable
final class MobileWingModel {
    @ObservationIgnored let session: AppSession

    /// The live ADDITIONAL wings, in switcher order (Home is virtual).
    private(set) var wings: [Wing] = []
    /// Whether the held read has delivered once — until then a non-Home
    /// wing's name is not known, and the title says nothing rather than
    /// a false "Home".
    private(set) var loaded = false

    init(session: AppSession) {
        self.session = session
    }

    /// Held — the `wing` table alone (a handful of rows; no keystroke, no
    /// note write and no book write wakes it — P1).
    func track() async {
        do {
            for try await value in session.database.observe({ db in try Queries.wings(db) }) {
                adopt(value)
            }
        } catch {}
    }

    /// One-shot (headless determinism; the observation echoes it).
    func load() async {
        if let value = try? await session.database.read({ try Queries.wings($0) }) {
            adopt(value)
        }
    }

    /// The Mac `WingsModel.adopt`'s steps over the shared `WingState`: the
    /// count, then a wing that died (here, or on another device) returns the
    /// app to Home.
    func adopt(_ new: [Wing]) {
        wings = new
        loaded = true
        session.wing.noteWingCount(new.count + 1)
        let live = Set(new.map(\.id))
        session.wing.revalidate { $0.isEmpty || live.contains($0) }
    }

    /// The current wing's name — "Home" for the virtual wing (`WingWords`),
    /// a live wing's own name, nil while a non-Home wing's name is not yet
    /// read (never a false "Home"). A rename arriving by sync re-titles it
    /// (the held read watches the `wing` table).
    var currentName: String? {
        let id = session.wing.currentID
        if id.isEmpty { return WingWords.home }
        return wings.first { $0.id == id }?.name
    }
}

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

/// **What a root's path line says** (VM-56; P-55-2, PROVISIONAL).
nonisolated enum MobileWingTitle {
    /// The wing's name LEADS the root's path, then the page: Study reads
    /// "Home · Library", Terminal "~/home/library" — the voice's own path
    /// grammar (`VoiceTokens.path`), today's line, no new row. A wing whose
    /// name is not yet read leaves the page alone.
    static func components(wing: String?, page: String) -> [String] {
        guard let wing, !wing.isEmpty else { return [page] }
        return [wing, page]
    }
}
