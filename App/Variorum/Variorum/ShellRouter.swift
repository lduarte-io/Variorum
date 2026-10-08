//
//  ShellRouter.swift
//  Variorum (Mac)
//
//  Phase 13, B2 — the shell's routing channel: menu commands (⌘N New Post,
//  ⌘J Today, ⌘K palette — R41/R15) and the palette execute against this;
//  RootView adopts pending requests into its selection. Parent-composition
//  routing, never feature-to-feature (the EditorRouter pattern, one level
//  up).
//
//  Phase 13f, batch 3: it also carries the window's WORKSPACE (its open
//  notes and per-pane history). One shell, one workspace — so the state is
//  per-window by construction the moment batch 4 mints a second window, and
//  the navigation doors below stay what they are here: requests, adopted by
//  RootView exactly like every other pending selection (P-4 — the router
//  decides what a destination means, the doors only name one).
//

import Foundation
import Observation

@MainActor
@Observable
final class ShellRouter {
    /// A navigation the next RootView pass adopts (then clears).
    var pendingSelection: SidebarSelection?
    /// ⌘K — the palette open request (R15: every buried capability
    /// typeable).
    var paletteRequested = false
    /// 13f batch 6 (W5): the quick note's palette door. A window cannot be
    /// opened from `ShellActions` (which holds no `openWindow`), so this is
    /// a REQUEST the shell adopts — the `paletteRequested` precedent
    /// exactly, and P-4's shape: the door names what it wants, the shell
    /// decides what that means.
    var quickNoteRequested = false
    /// 13r U3-A: Help ▸ What's New — a REQUEST the shell adopts (the sheet
    /// is the window's to present), the `quickNoteRequested` shape exactly.
    var whatsNewRequested = false
    /// 13s-b U1a, piece 5: Help ▸ Take the Tour — a REQUEST the shell adopts
    /// (the tour runs over this window), `whatsNewRequested`'s shape exactly.
    /// The shell answers it with the ONE tour entry the offer line's "yes"
    /// calls (`RootView.startTour()`).
    var tourRequested = false
    /// **Whether this window's sidebar is on screen** (the Act 10 correction
    /// round, batch A — row 2). The split view used to hold this for us; with
    /// the flat `ShellSplit` it is per-window state here, toggled by the
    /// toolbar door and View ▸ Toggle Sidebar (⌃⌘S) alike.
    var sidebarShown = true

    /// 13f batch 3: the window's open notes + per-pane back/forward.
    let workspace = WorkspaceModel()

    // MARK: - The shell's CONFIRM (13u4 UNIT S3 — KnownIssues row 67)

    /// **A question the shell is asking, for the window to present.**
    ///
    /// Row 67: `Help ▸ Restore Tutorial…` confirmed through an app-modal
    /// `NSAlert.runModal()` while every other confirm in the app is a SwiftUI
    /// `.alert` — the one inconsistent confirm chrome, and an app-modal
    /// AppKit alert swallows input in ways that cost a walk an hour (the
    /// WalkKit README's own new fact). The act cannot present it itself:
    /// `ShellActions` holds no view, which is exactly why the alert lived
    /// where it did. So it is a REQUEST the shell adopts — `pendingSelection`
    /// and `quickNoteRequested`'s own shape, and P-4's: the door names what
    /// it wants, the window decides what that means.
    var pendingConfirm: Confirm?

    /// One asked question. The `answer` resumes whoever is awaiting it, so a
    /// dismissal is an ANSWER (false) rather than a silence.
    struct Confirm: Identifiable {
        let id = UUID()
        let question: String
        let detail: String
        /// The confirming button's verb; Cancel is always the other one.
        let verb: String
        let destructive: Bool
        let answer: (Bool) -> Void
    }

    /// Ask, and wait for the window to answer. **A second ask answers the
    /// first with `false`** — nothing may be left awaiting a question that
    /// is no longer on screen, and "the question went away" is a decline.
    func ask(
        question: String, detail: String, verb: String, destructive: Bool = false
    ) async -> Bool {
        await withCheckedContinuation { continuation in
            pendingConfirm?.answer(false)
            pendingConfirm = Confirm(
                question: question, detail: detail, verb: verb,
                destructive: destructive,
                answer: { continuation.resume(returning: $0) })
        }
    }

    /// The window's side of it: answer and clear, in one act, so a second
    /// press of either button cannot resume a continuation twice.
    func answerPendingConfirm(_ confirmed: Bool) {
        let pending = pendingConfirm
        pendingConfirm = nil
        pending?.answer(confirmed)
    }

    /// **19f — Help ▸ Send Feedback…'s pre-draft choice** (her #181 (i)
    /// ruling): the door asks its two-road question HERE and the window
    /// presents it (`RootView`'s `.supportChoiceAlert`) — this channel's road
    /// for a two-answer question, the `confirm` above being yes/no. The
    /// `whatsNewRequested` precedent: a feature's request the shell carries.
    let supportChoice = SupportChoiceAsk()

    // MARK: - The parked block landing (17o c/d/e round 1, MAJOR-2)

    /// **A block a navigation named, held for the mount that consumes it.**
    ///
    /// Stage C parked this on `RootView` as `@State` and only ever WROTE it:
    /// the block-naming door set it, and every ordinary navigation door —
    /// `opener`/`openHere`, the sidebar's own binding, ⌘K, the back/forward
    /// chips — went through `adopt`, which never touched the field. So a
    /// park was never consumed and never expired: `landing(for:)` kept
    /// answering for that container id forever, and re-entering the note
    /// re-landed a block she had clicked an hour ago, against row 42/U-20's
    /// ruled promise (*"every door into Write lands at the remembered
    /// caret"*).
    ///
    /// It lives on the router now for the reason `pendingSelection` does: it
    /// is per-window navigation state the shell's doors already speak to
    /// (P-4), and holding it here is what makes the rule below a fact a pin
    /// can read instead of a `@State` nobody outside one view can see.
    private(set) var blockLanding: BlockLanding?

    struct BlockLanding: Equatable, Sendable {
        let containerID: String
        let blockID: String
        /// 13o U2 (D6 — land-at-match): a search passage's matched words,
        /// riding the landing they belong to — parked, expired and spent
        /// WITH it (never a second park that could outlive its block).
        var find: EditorFindSeed? = nil

        /// A landing for a destination, if that destination is a container
        /// that can hold one and a block was actually named. Living here is
        /// what lets the one adoption door take a `String?` and still be the
        /// only place the pair is assembled.
        init?(_ destination: SidebarSelection, blockID: String?, find: EditorFindSeed? = nil) {
            guard let blockID else { return nil }
            switch destination {
            case .post(let id), .pool(let id):
                self.init(containerID: id, blockID: blockID, find: find)
            default:
                return nil
            }
        }

        init(containerID: String, blockID: String, find: EditorFindSeed? = nil) {
            self.containerID = containerID
            self.blockID = blockID
            self.find = find
        }
    }

    /// **RULE ONE — a NAVIGATION expires whatever is parked, and parks only
    /// what it names.**
    ///
    /// **What holds it, exactly** (13u2 UNIT E, KnownIssues row 47's PARK
    /// half — the sentence this doc carried before overclaimed, and this one
    /// is the true statement): parking is `private` to `adopt` below, which
    /// parks and navigates in ONE statement. So "park, then navigate" is not
    /// expressible *by a second door*: there is no door that parks without
    /// navigating, and a park followed by any navigation is a park followed
    /// by another `adopt`, which expires it — which is the rule.
    ///
    /// **The road a reader must not add, named because the fence does not
    /// reach it:** a door that navigates by calling `workspace.select`
    /// DIRECTLY rather than going through `adopt` would move the shell
    /// without expiring a park. Today `adopt` is `select`'s only caller
    /// outside `WorkspaceModel` itself (`openBeside`'s own mint) and outside
    /// the workspace's own pins — keep it that way, or the rule above stops
    /// being true and nothing in the compiler says so. Round 1 shipped this
    /// as two statements in `RootView.open` (adopt, then park) and the ORDER
    /// was load-bearing with nothing holding it: reverse the two and the
    /// clear eats every park as it is made, deleting the whole Stage C
    /// landing road with the suite green (round 2, MINOR-1).
    ///
    /// **RULE TWO — a park is SPENT WHEN IT LANDS** (`spendLanding`), because
    /// a RE-MOUNT is not a navigation: the detail view applies the landing in
    /// `onAppear`, and the shell re-mounts it whenever the pane stops being
    /// the live one — a split's other pane taking focus, a second window
    /// becoming key — neither of which passes through a navigation door. An
    /// unspent park therefore re-threw her to the block a door named an hour
    /// ago every time she came back (round 2's MAJOR).
    private func park(_ landing: BlockLanding?) {
        blockLanding = landing
        // Only a NEW park bumps the generation; spending one must not, or
        // the mount's identity would change under a view that has already
        // landed and SwiftUI would rebuild it, throwing the caret away.
        if let landing {
            landingGenerations[landing.containerID, default: 0] += 1
        }
    }

    /// **THE ONE DOOR a destination enters a pane through** (13u2 UNIT E —
    /// KnownIssues row 47's PARK half; the body is `RootView.adopt`'s two
    /// statements, moved here so `park` can be private to it).
    ///
    /// It parks what the caller NAMES — nothing, for every ordinary
    /// navigation — and then selects, in one statement, which is what makes
    /// the wrong order unexpressible rather than merely untaken. The caller
    /// keeps the outcome so the shell can speak the same-note refusal in its
    /// one voice; the router holds no `StatusCenter` (P-4: it decides what a
    /// destination MEANS; the shell says it out loud).
    @discardableResult
    func adopt(
        _ destination: SidebarSelection,
        in pane: PaneID? = nil,
        landing blockID: String? = nil,
        find: EditorFindSeed? = nil
    ) -> WorkspaceModel.SelectionOutcome {
        park(BlockLanding(destination, blockID: blockID, find: find))
        return workspace.select(destination, in: pane)
    }

    /// What a mounting container should land on, if this park is its own.
    func landing(for containerID: String) -> String? {
        blockLanding?.containerID == containerID ? blockLanding?.blockID : nil
    }

    /// The parked landing's find seed (13o U2, D6), if the park is this
    /// container's — the same park, so it is spent and expired with it.
    func landingFind(for containerID: String) -> EditorFindSeed? {
        blockLanding?.containerID == containerID ? blockLanding?.find : nil
    }

    /// **Spend it.** Called by the shell the moment a container's detail
    /// MOUNTS with a landing in hand — the landing has been delivered, so
    /// the park's work is done and a later re-mount of the same note must
    /// land at the remembered caret instead (U-20/row 42). A no-op when
    /// nothing of this container's is parked, so re-mounts are free.
    func spendLanding(for containerID: String) {
        if blockLanding?.containerID == containerID { blockLanding = nil }
    }

    /// **How many landings this container has been handed.** The detail's
    /// view identity keys on THIS, never on the parked block: a NEW park
    /// re-creates the editor (which is what makes "open it again, at another
    /// block" work), and spending one does not (which is what stops the
    /// spend from rebuilding the view it just landed). A container she never
    /// opened at a block sits at 0 forever and its identity never churns.
    func landingGeneration(for containerID: String) -> Int {
        landingGenerations[containerID] ?? 0
    }

    private var landingGenerations: [String: Int] = [:]

#if DEBUG
    /// **Round 2, MINOR-1's oracle** (`SidebarGeometry`'s pattern, one door
    /// wide): `RootView.open(_:blockID:in:)` is private and every production
    /// caller of it is a view closure a test cannot fire, so the one thing
    /// the finding is about — that the SHELL's block-naming door navigates
    /// and parks in the right order — had no way to be asserted through the
    /// real road. The mounted shell publishes its door here; the pin calls
    /// it. Nothing production reads it.
    ///
    /// **13u4 UNIT S3 — KnownIssues row 46's surviving item: THE REGISTRANT
    /// NAMES ITSELF.** It used to be one bare `static var` that every
    /// `RootView` mount OVERWROTE and exactly one of eight test mount sites
    /// cleared. The mechanism that makes that a defect rather than untidiness:
    /// a shell that has been torn down leaves its closure standing in a
    /// process-global, capturing that shell's router and session — so the
    /// next reader drives a DEAD shell, and it was only ever green because
    /// the pin's own mount happened to be the last publisher. That is an
    /// ordering accident, not a guarantee, and it is exactly the shape UNIT
    /// S2 fixed at the two stamp oracles: **a registration keyed by its
    /// subject with no record of who registered it.** Same idea here, same
    /// two rules — the registrant names itself, and a teardown clears only
    /// what it still owns.
    private static var blockNamingDoors: [UUID: (SidebarSelection, String?) -> Void] = [:]
    /// Publication order, so the read answers from the MOST RECENT mount —
    /// which is what a pin that just mounted a shell means by "the door".
    private static var blockNamingOwners: [UUID] = []

    /// The door of the most recently published shell, or nil when none is
    /// standing. Read-only on purpose: the way a door goes is its owner
    /// releasing it (or `forgetBlockNamingDoors()`, the pin's own reset —
    /// `PostDetailOracle.resetStamp`'s precedent: a pin owns nothing, so its
    /// door is unconditional).
    static var blockNamingDoor: ((SidebarSelection, String?) -> Void)? {
        blockNamingOwners.last.flatMap { blockNamingDoors[$0] }
    }

    static func publishBlockNamingDoor(
        owner: UUID, _ door: @escaping (SidebarSelection, String?) -> Void
    ) {
        blockNamingDoors[owner] = door
        blockNamingOwners.removeAll { $0 == owner }
        blockNamingOwners.append(owner)
    }

    /// Clears ONLY this owner's registration — a shell leaving cannot take
    /// down a shell still on screen (the second window's case).
    static func releaseBlockNamingDoor(owner: UUID) {
        blockNamingDoors[owner] = nil
        blockNamingOwners.removeAll { $0 == owner }
    }

    /// The test-suite reset. Unconditional, deliberately.
    static func forgetBlockNamingDoors() {
        blockNamingDoors.removeAll()
        blockNamingOwners.removeAll()
    }
#endif

    // MARK: - The navigation doors (menu + strip)

    /// ⌥⌘[ — walk the active pane back. Silent when there is nowhere to go:
    /// the menu item is grey exactly then (the registry's `canNavigateBack`),
    /// so this can only be reached by a race, and a race should not speak.
    ///
    /// **`nil` = the FOCUSED pane (13f cold review, R1-2 — the fix).** The
    /// default used to be `.primary`, which pinned the model's focus-aware
    /// default shut: with a split's second pane focused, the menu's gate
    /// (`canNavigateBack` — the focused pane's) enabled while the keystroke
    /// popped the PRIMARY pane's trail and the popped destination was then
    /// adopted into the FOCUSED pane — the wrong pane's history mutated and
    /// the wrong destination navigated; and after closing the split from
    /// the primary pane, ⌥⌘[/⌥⌘] were permanently inert (the `.primary` key
    /// left with its pane) while the menu stayed enabled — a durable dead
    /// key. The chip passes its own pane explicitly, as before.
    func goBack(in pane: PaneID? = nil) {
        if let destination = workspace.goBack(in: pane) {
            pendingSelection = destination
        }
    }

    /// ⌥⌘] — the mirror.
    func goForward(in pane: PaneID? = nil) {
        if let destination = workspace.goForward(in: pane) {
            pendingSelection = destination
        }
    }

    /// ⌘⇧n — the nth SHOWN row of the Open strip (1-based).
    func openNote(ordinal: Int) {
        if let id = workspace.openNotes.id(atOrdinal: ordinal) {
            pendingSelection = .post(id)
        }
    }

    /// View ▸ Open Note's row door (18o U3 — KnownIssues row 73): the act a
    /// menu row's click and key perform. **It opens the note the row NAMES**
    /// — the row's title, key and act read one captured id, so what the
    /// menu shows is what it opens. The ordinal road above stops at nine (the
    /// key cap), so a tenth row asked through it landed nothing — a rendered
    /// door that could never act (P-2).
    func openStripRow(_ row: OpenStripMenuRow) {
        pendingSelection = .post(row.noteID)
    }

    // MARK: - The split's doors (13f batch 4, W1/A25)

    /// Speech lands in the StatusCenter — wired by the shell, exactly as
    /// `CommandRouter.refuse` is, so the router never reaches for a session.
    @ObservationIgnored var refuse: ((String) -> Void)?

    /// "Open Beside" for a NAMED note (the row doors) — and the ONE place
    /// her round-7.3 refusal is spoken, so the menu door and every row door
    /// say the same sentence.
    func openBeside(_ destination: SidebarSelection) {
        switch workspace.openBeside(destination) {
        case .opened:
            break  // the pane appeared; nothing to say
        case .focusedExistingPane:
            refuse?(WorkspaceNaming.sameNoteNote(workspace.label(for: destination)))
        }
    }

    /// The menu door: the most recently opened note no pane is showing.
    /// Grey when there is none (the registry's `canOpenBeside`), so this is
    /// reachable only by a race — and a race should not speak.
    func openBesideMostRecent() {
        guard let id = workspace.openBesideCandidate else { return }
        openBeside(.post(id))
    }

    func closeSplit() {
        _ = workspace.closeSplit()
    }
}
