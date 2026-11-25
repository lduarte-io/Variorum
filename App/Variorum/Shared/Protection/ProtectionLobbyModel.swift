//
//  ProtectionLobbyModel.swift
//  Variorum (shared: Mac + Mobile — the phone's face is U3's)
//
//  VX-306 U1b — THE NEW ROAD'S LOBBY, the brain (`notes/plans/vx-306-castle-open-road.md` §2 U1b). It holds the
//  lobby's facts (roads only — before unlock nothing decides), the face derived from them
//  (`ProtectionLobbyFace.derive`, the core's assessment read into a face), and the presses. Every road is an
//  injected async closure (the bootstrap's, off the main actor; a test's, planted), so the model is testable
//  with no keychain.
//
//  The quiet roads were already tried AT ONCE by the route before this lobby shows (rule 8: it asks only when
//  no quiet road remains), so a visible lobby's typed field shows at once.
//
//  VX-310's second bug — "the button to make that prompt come up goes away … and you have to restart the app"
//  — closed here, two ways: (1) a press changes ONLY the press fact (what it did, and this Mac's biometry after
//  it); the item facts the button stands on are never re-listed after a press, so no dismissal can take the
//  button away; (2) `refresh()` re-reads the roads when she comes back to the app, and a read that fails keeps
//  the face it had — so a first read that missed the item heals without a relaunch, and a flicker never
//  removes a button. The ONE thing that drops the button is a press that found the item gone.
//
//  VX-1013 (`notes/plans/fixes/vx-1013-open-far-folder-wait.md`, D-1013-4) — the launch road's lobby draws from the
//  CONTAINER's facts and the far folder (her picked backup folder) is read once, off the launch path. When that walk
//  lands, `farWalkLanded()` takes the full facts through the same seam `refresh()` uses — extra typed roads, and rule
//  27's refusal where the full listing proves it, may appear then (PROVISIONAL P-1013-1) — or goes on through `opened`
//  when the far folder's key files let a quiet road open the library (PROVISIONAL P-1013-3). The landing never runs
//  beside a press: one that lands while a press is in flight waits for the press to end.
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class ProtectionLobbyModel {
    /// What the face shows now.
    private(set) var face: ProtectionLobbyFace
    private(set) var busy = false
    /// A refusal, or what a press said (nil: nothing to say).
    private(set) var message: String?
    /// The one automatic ask is spent once any ask ran (VX-140's rule, kept: never a re-ask she did not make).
    private(set) var autoAskSpent = false
    /// How many times a Touch ID press reached the road (a test's witness).
    private(set) var pressesRun = 0

    @ObservationIgnored private var standing: RoadLobbyFacts
    @ObservationIgnored private var press: TouchIDPress?
    @ObservationIgnored private var biometry: BiometryFacts?

    @ObservationIgnored private let typedRoad: (ProtectionSecret) async -> RoadAttempt
    @ObservationIgnored private let touchIDRoad: (ProtectionFacts?) async -> RoadAttempt
    @ObservationIgnored private let refreshRoad: () async -> RoadLobbyFacts
    @ObservationIgnored private let opened: (ProtectionRoadSession) -> Void
    @ObservationIgnored private let recordMissing: () -> Void
    /// VX-306 U2 — rule 27's face's *Start a New Library* (nil: not offered): the library no key file opens steps
    /// aside whole, then the creation. Answers the sentence to show, nil when it went on.
    @ObservationIgnored private let startNewRoad: (() async -> String?)?
    /// VX-329 U4 — her pre-design face's *Start fresh…* (nil: not offered — P-2): her confirmed act, the store from before
    /// this design set aside whole into Previous Libraries, then the calm first open. Answers the sentence to show, nil
    /// when it went on.
    @ObservationIgnored private let startFreshRoad: (() async -> String?)?
    /// VX-1013 — the far walk's landing (nil: no far walk owed — every lobby but the launch road's).
    @ObservationIgnored private let farLandingRoad: (() async -> RoadFarLanding)?
    /// The landing arrived while a press was in flight: it runs when the press ends without opening.
    @ObservationIgnored private var farLandingOwed = false
    @ObservationIgnored private var farLandingTaken = false
    /// The lobby was left — a road opened, the missing face took over, a creation went on: nothing lands on it any more.
    @ObservationIgnored private var left = false

    init(
        standing: RoadLobbyFacts,
        typedRoad: @escaping (ProtectionSecret) async -> RoadAttempt,
        touchIDRoad: @escaping (ProtectionFacts?) async -> RoadAttempt,
        refreshRoad: @escaping () async -> RoadLobbyFacts,
        opened: @escaping (ProtectionRoadSession) -> Void,
        recordMissing: @escaping () -> Void,
        startNew: (() async -> String?)? = nil,
        startFresh: (() async -> String?)? = nil,
        farLanding: (() async -> RoadFarLanding)? = nil
    ) {
        self.standing = standing
        self.typedRoad = typedRoad
        self.touchIDRoad = touchIDRoad
        self.refreshRoad = refreshRoad
        self.opened = opened
        self.recordMissing = recordMissing
        startNewRoad = startNew
        startFreshRoad = startFresh
        farLandingRoad = farLanding
        face = ProtectionLobbyFace.derive(standing)
    }

    // MARK: - The pre-design face's door (VX-329 U4)

    /// *Start fresh…* is offered (her pre-design face, with its act wired).
    var offersStartFresh: Bool { face.preDesignStore && startFreshRoad != nil }

    /// *Start fresh…*, AFTER her confirm (the face asks it — her line, the plan's §6d).
    func startFresh() async {
        guard offersStartFresh, let startFreshRoad, !busy else { return }
        busy = true
        message = nil
        let sentence = await startFreshRoad()
        busy = false
        if let sentence { message = sentence } else { left = true }
        await landOwedFarWalk()
    }

    // MARK: - Rule 27's doors (VX-306 U2)

    /// *Start a New Library* is offered (rule 27's face, with the creation wired).
    var offersStartNew: Bool { face.noKeyFileAnywhere != nil && startNewRoad != nil }

    /// Rule 27's *Start a New Library*.
    func startNewLibrary() async {
        guard offersStartNew, let startNewRoad, !busy else { return }
        busy = true
        message = nil
        let sentence = await startNewRoad()
        busy = false
        if let sentence { message = sentence } else { left = true }
        await landOwedFarWalk()
    }

    // MARK: - Touch ID (VX-310)

    /// The one automatic ask at open — only while Variorum is the active app (VX-140), only once. Never over a store from
    /// before this design (VX-329 U4 — rule 26: no key this Mac holds opens it, so no prompt is raised for one).
    func autoAskIfDue(appIsActive: Bool) async {
        guard face.autoAsk, face.touchIDButton, !face.preDesignStore, !autoAskSpent, !busy, appIsActive else { return }
        await pressTouchID()
    }

    /// THE PRESS. Unusable for now ⇒ it says why and changes nothing (no prompt is attempted).
    func pressTouchID() async {
        guard face.touchIDButton, !busy else { return }
        autoAskSpent = true
        if let reason = face.pressSays {
            message = ProtectionWords.touchIDUnusableForNow(reason)
            return
        }
        busy = true
        message = nil
        pressesRun += 1
        let attempt = await touchIDRoad(standing.facts)
        busy = false
        switch attempt {
        case .opened(let session):
            left = true
            opened(session)
        case .recordMissing:
            left = true
            recordMissing()
        case .refused(let sentence):
            message = sentence
        case .touchIDNotOpened(let press, let biometry, let itemGone):
            // ONLY the press fact moves (and this Mac's biometry after it) — the item facts stand.
            self.press = press
            self.biometry = biometry
            if itemGone, var facts = standing.facts {
                // The one road that drops the button: the press found no item to press.
                facts.custody.removeAll { $0.itemClass == .touchid }
                standing.facts = facts
            }
            rederive()
            if case .transient(let reason)? = press { message = ProtectionWords.touchIDUnusableForNow(reason) }
        }
        await landOwedFarWalk()
    }

    // MARK: - The typed roads

    func unlock(passphrase: String) async {
        // Untrimmed on purpose (a passphrase may begin or end with a space; only the empty one is refused).
        guard !passphrase.isEmpty else { return }
        await run(.passphrase(passphrase))
    }

    func unlock(wordsText: String) async {
        let words = WordsInput.words(from: wordsText)
        guard !words.isEmpty else { return }
        await run(.words(words))
    }

    private func run(_ secret: ProtectionSecret) async {
        guard !busy else { return }
        busy = true
        message = nil
        let attempt = await typedRoad(secret)
        busy = false
        switch attempt {
        case .opened(let session):
            left = true
            opened(session)
        case .recordMissing:
            left = true
            recordMissing()
        case .refused(let sentence): message = sentence
        case .touchIDNotOpened: message = ProtectionWords.somethingWentWrong
        }
        await landOwedFarWalk()
    }

    // MARK: - Re-reading the roads

    /// Re-read the roads (she came back to the app). A read that failed keeps the face this lobby had — a
    /// flicker never takes a road away; Touch ID items seen before stay (only a press drops one).
    func refresh() async {
        guard !busy else { return }
        let fresh = await refreshRoad()
        take(fresh)
    }

    /// The seam both re-reads land through: a read that failed keeps the face; Touch ID items seen before stay.
    /// `keepingUnreadableLiveFile` (the far landing's): the route's finding about the live place stands — a far folder
    /// says nothing about it.
    private func take(_ fresh: RoadLobbyFacts, keepingUnreadableLiveFile: Bool = false) {
        guard var facts = fresh.facts else { return }
        if let before = standing.facts {
            for item in before.custody where item.itemClass == .touchid && !facts.custody.contains(item) {
                facts.custody.append(item)
            }
        }
        var next = fresh
        next.facts = facts
        if keepingUnreadableLiveFile { next.liveKeyFileUnreadable = next.liveKeyFileUnreadable || standing.liveKeyFileUnreadable }
        standing = next
        rederive()
    }

    // MARK: - The far folder's walk lands (VX-1013, D-1013-4)

    /// The launch road's far walk landed (the bootstrap calls this once, while this lobby stands): the full facts are
    /// taken, or — a quiet road opening through the far folder's key files — the lobby goes on as after a press. Never
    /// beside a press (one in flight owes it to its end); once only; nothing once the lobby was left.
    func farWalkLanded() async {
        guard let farLandingRoad, !farLandingTaken, !left else { return }
        guard !busy else {
            farLandingOwed = true
            return
        }
        farLandingTaken = true
        busy = true
        let landing = await farLandingRoad()
        busy = false
        guard !left else { return }
        switch landing {
        case .opened(let session):
            left = true
            opened(session)
        case .recordMissing:
            left = true
            recordMissing()
        case .lobby(let fresh):
            take(fresh, keepingUnreadableLiveFile: true)
        }
    }

    private func landOwedFarWalk() async {
        guard farLandingOwed else { return }
        farLandingOwed = false
        await farWalkLanded()
    }

    private func rederive() {
        face = ProtectionLobbyFace.derive(standing, press: press, biometry: biometry)
    }
}
