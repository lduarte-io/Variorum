//
//  MobileStars.swift
//  VariorumMobile
//
//  Parity round Stage C, batch C3 — STARS cross (her sitting ruling 10:
//  "CROSS — act + starred face, exact shape at the batch"). The storage
//  mechanism is the Mac's own, found in code and reused THROUGH CORE
//  (13f W4, her ruling: "stars = a synced `setting` list … up to 5
//  notes or books"; the cap is 15 since her 2026-09-18 #112(b) ruling —
//  `Operations.starLimit` is the number's one home): `Operations.
//  setStarred` owns the append-order list, the honest cap, and the
//  self-heal; `Queries.starred` is the
//  ONE read rule (live targets only). Nothing star-shaped is decided
//  here — this model observes, toggles, and speaks the op's refusal in
//  phone words.
//
//  The faces (the batch's call, PROVISIONAL):
//  · THE STARRED SECTION sits at the SHELF's top — the Mac's
//    sidebar-top placement mirrored onto the phone's home surface; a
//    row navigates (book → contents, note → writing), rendered only
//    when anything is starred.
//  · THE ACT rides the long-press rows: the shelf book row (beside
//    Pin — the Mac 13f adjacency: pinning orders THIS list, a star
//    lifts the thing to the top section) and the Library note row.
//
//  Starred names ride the ONE display brain: a note star resolves
//  through `DisplayTitle.note` (title → day — the C2 one-chain
//  doctrine; `StarredItem.name` alone would render an untitled note
//  blank), a book star is its stored name.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import VariorumCore

@MainActor
@Observable
final class MobileStarsModel {
    @ObservationIgnored private let session: AppSession

    /// The starred rows, star order, live targets only (the core read
    /// rule; at most `Operations.starLimit` by construction).
    private(set) var items: [Queries.StarredItem] = []
    /// Note stars' display names through the ONE brain (keyed by
    /// target id; books render their own stored name).
    private(set) var noteNames: [String: String] = [:]
    private(set) var lastError: String?
    /// WHERE the last refusal's door fired (parity D2 — the routed C3
    /// R1-7 mechanism: `lastError` is one field on the one shared model
    /// and BOTH tab roots rendered it, so a cap refusal fired from the
    /// Library also sat waiting at the shelf's bottom, and vice versa,
    /// until some later toggle happened to succeed). A door refusal now
    /// carries its origin and renders THERE only (`error(on:)`); a
    /// HOMELESS error (a store-read failure — not door-fired) renders
    /// on every root, honestly, and never auto-clears.
    private(set) var errorHome: DoorHome?
    /// The refusal's clearing cadence (the routed item's second half:
    /// the refusal never cleared passively). Injectable so the pin can
    /// drive it deterministically; ~8 s reads the two-line sentence.
    @ObservationIgnored var errorClearDelay: Duration = .seconds(8)
    @ObservationIgnored private var errorClearTask: Task<Void, Never>?

    /// Which tab root a star door lives on.
    ///
    /// **`.starred` joins at batch 10**, with the page that lists them: an
    /// un-star fired from the starred page is a door refusal like any
    /// other, and without its own home it would have reported on the two
    /// roots that did not fire it — precisely the D2 defect this enum was
    /// added to close.
    enum DoorHome {
        case shelf
        case library
        case starred
    }

    init(session: AppSession) {
        self.session = session
    }

    // MARK: - Pure brains (pinned)

    /// **The page's name** (batch 10) — the tab door's word, the path
    /// line's, and the word every refusal names when it points at the
    /// list. One symbol, so a re-wording cannot leave a sentence pointing
    /// at a surface that is called something else.
    nonisolated static let pageName = "Starred"

    /// The empty state. It names the ACT that fills the page, because a
    /// page that says only "nothing here" is a dead end.
    nonisolated static let emptyLine =
        "Nothing starred yet — press and hold a note or a book, then choose Star."

    /// A starred row's spoken label: the name and what KIND of thing it is
    /// (an explicit label replaces the one SwiftUI would compose from the
    /// row's children, so the kind must be said or it leaves the tree —
    /// the Library book row's own measured lesson).
    nonisolated static func spokenRow(name: String, kind: StarTarget.Kind) -> String {
        "\(name), \(kind == .reading ? "book" : "note")"
    }

    /// What a root renders: its own door's refusal, or a homeless
    /// (store-read) error anywhere.
    func error(on home: DoorHome) -> String? {
        guard lastError != nil else { return nil }
        return (errorHome == home || errorHome == nil) ? lastError : nil
    }

    /// The row door's state-mirroring words — the Mac `StarCopy`'s own.
    nonisolated static func doorTitle(starred: Bool) -> String {
        starred ? "Unstar" : "Star"
    }

    /// The cap's refusal in PHONE words: the road it names is the
    /// phone's own starred list (the Mac copy names the sidebar, which
    /// does not exist here).
    ///
    /// **RE-POINTED AT BATCH 10, and it is a bug-class fix rather than a
    /// re-wording.** It said *"in the starred list at the top of the
    /// shelf"* — and this batch retired that list from the shelf at her
    /// instruction (*"I don't like where it appears above the shelf"*), so
    /// the sentence would have sent her to a place that no longer exists.
    /// The name now comes from `pageName`, the one symbol the tab door and
    /// the path line also read, so a re-wording can never strand it again.
    nonisolated static func capRefusal(limit: Int) -> String {
        "You can star \(limit) things at a time — un-star one in \(pageName), "
            + "and this can take its place."
    }

    /// Where a starred row navigates — the phone's route vocabulary.
    nonisolated static func route(for target: StarTarget) -> MobileRoute {
        switch target.kind {
        case .post: return .note(target.id, focus: false)
        case .reading: return .book(target.id)
        }
    }

    // MARK: - Observation

    /// Held: at most `starLimit` rows by construction (the bounded-
    /// observation discipline satisfied by the data itself — the Mac
    /// StarsModel's own note).
    func start() async {
        do {
            for try await value in session.database.observe({ db in
                try Queries.starred(db)
            }) {
                items = value
                await resolveNames()
            }
        } catch is CancellationError {
        } catch {
            speakHomeless(String(describing: error))
        }
    }

    /// One-shot for headless determinism (the observation echoes it in
    /// production).
    func refresh() async {
        do {
            items = try await session.database.read { try Queries.starred($0) }
            await resolveNames()
        } catch {
            speakHomeless(String(describing: error))
        }
    }

    /// Note stars resolve their display name through the ONE brain
    /// (title → entry day → created day — the C2 one-chain doctrine).
    /// Bounded by the cap: at most `Operations.starLimit` point-reads.
    private func resolveNames() async {
        let postIDs = items.filter { $0.target.kind == .post }.map(\.target.id)
        guard !postIDs.isEmpty else {
            noteNames = [:]
            return
        }
        do {
            let headers = try await session.database.read { db in
                try postIDs.compactMap { try Queries.containerHeader(db, containerID: $0) }
            }
            noteNames = Dictionary(uniqueKeysWithValues: headers.map { header in
                (header.id, DisplayTitle.note(
                    title: header.title, entryDate: header.entryDate,
                    createdAt: header.createdAt))
            })
        } catch {
            speakHomeless(String(describing: error))
        }
    }

    // MARK: - The one door value (the Mac StarDoor's shape)

    func isStarred(_ target: StarTarget) -> Bool {
        items.contains { $0.target == target }
    }

    /// What a starred row is CALLED: notes through the one display
    /// brain, books by their stored name.
    func displayName(_ item: Queries.StarredItem) -> String {
        if item.target.kind == .post {
            return noteNames[item.target.id] ?? item.name ?? ""
        }
        return item.name ?? ""
    }

    /// Star or un-star, and SPEAK what the operations layer answers —
    /// the cap refuses honestly rather than evicting the oldest star
    /// (the op's own rule; P-2's fire-and-refuse). The refusal speaks
    /// at ITS door's root and clears after a beat (the D2 routed item).
    func toggle(_ target: StarTarget, from home: DoorHome) async {
        let starred = isStarred(target)
        do {
            try await session.runner.run { ops in
                try ops.setStarred(target, starred: !starred)
            }
            clearError()
        } catch let error as OperationError {
            if case .starLimitReached(let limit) = error {
                speak(Self.capRefusal(limit: limit), at: home)
            } else {
                speak("Refused: \(error)", at: home)
            }
        } catch {
            speak(String(describing: error), at: home)
        }
        await refresh()
    }

    /// A HOMELESS error (store reads — no door produced it): renders at
    /// EVERY root and never auto-clears (the D2 recorded semantics).
    /// One setter so an error landing inside a refusal's clear window can
    /// never inherit the refusal's home or its cadence (D ladder R1-2).
    private func speakHomeless(_ message: String) {
        errorClearTask?.cancel()
        errorClearTask = nil
        errorHome = nil
        lastError = message
    }

    /// A door refusal: spoken at its root, cleared after the cadence
    /// (each fresh refusal restarts the clock).
    private func speak(_ message: String, at home: DoorHome) {
        lastError = message
        errorHome = home
        errorClearTask?.cancel()
        errorClearTask = Task { [weak self] in
            guard let delay = self?.errorClearDelay else { return }
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            self?.lastError = nil
            self?.errorHome = nil
        }
    }

    private func clearError() {
        errorClearTask?.cancel()
        errorClearTask = nil
        lastError = nil
        errorHome = nil
    }
}
