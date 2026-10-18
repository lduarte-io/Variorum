//
//  ProtectionLobbyFace.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1b — WHAT THE NEW ROAD'S LOBBY SHOWS, as a PURE value derived from the core's assessment
//  (`LobbyRoads` + `TouchIDAssessment` — `AssessRules.lobby` / `AssessRules.touchID`, the only decision code;
//  this file adds no rule of its own, it reads them into a face). Testable from planted facts with no
//  keychain. The model (`ProtectionLobbyModel`) holds one and re-derives it; the views render it.
//
//  VX-310 (design §3.10, her ruling 2026-10-13 — "there should always be a button you can click to launch the
//  touchid prompt"):
//    - THE BUTTON whenever a Touch ID item for the library's current key exists AND Touch ID can work on this
//      Mac (hardware + an enrolled finger) — `TouchIDAssessment.button`. BUG 1's cure: no enrolled finger ⇒ no
//      button and no Touch ID prompt line, only the quiet line saying why.
//    - THE ONE AUTOMATIC ASK at open (`autoAsk`); a press that Touch ID can't serve FOR NOW (lid closed, keyboard
//      disconnected or unpaired, a lockout) keeps the button and says why (`pressSays`), changing nothing.
//    - THE CHANGED LINE after a press failed on an item that exists (`changedLine`); the re-arm question is
//      VX-308's (rendered as nothing here).
//    - BUG 2's cure lives in the MODEL: a dismissed press changes only the press fact, never the item facts the
//      button stands on (no keychain listing re-runs after a press), and the roads are re-read when she returns
//      to the app, a failed read never taking away what a good read showed.
//
//  THE TYPED ROADS: the live key file's (`LobbyRoads.typed`) plus rule 1's keychain mirror's and every catalogued
//  key file's of the library (the route's `offeredTyped` — the N5 hand-forward). With a passphrase road the
//  words wait behind one quiet door; with none the words field shows directly (rule 2: every library has them).
//

import Foundation
import VariorumCore

nonisolated struct ProtectionLobbyFace: Equatable, Sendable {
    enum TouchIDLine: Equatable, Sendable {
        /// No Touch ID hardware, or no finger enrolled on this Mac.
        case notSetUpOnThisMac
        /// No Touch ID item for this library's current key.
        case notSetUpForThisLibrary
        /// A press failed on an item that exists (§3.10's changed line).
        case changed
    }

    enum WordsRoad: Equatable, Sendable {
        case none
        /// The words field directly (no passphrase road).
        case field
        /// Behind one quiet door, beside the passphrase field.
        case disclosure
    }

    /// The *Unlock with Touch ID* button.
    var touchIDButton: Bool
    /// The one Touch ID line (nil: none).
    var touchIDLine: TouchIDLine?
    /// The one automatic ask at open.
    var autoAsk: Bool
    /// Touch ID is unusable for now — a press says why and changes nothing.
    var pressSays: TransientUnavailability?
    var passphraseField: Bool
    var wordsRoad: WordsRoad
    /// The lobby's facts could not be read (P-VX306-U1a-3) — the typed field, with the one-line reason.
    var keychainUnreadable: Bool
    /// The quiet roads met a file in the live place this build can't read as a key file (P-VX306-U1a-2).
    var liveKeyFileUnreadable: Bool
    /// RULE 27 before unlock: no road at all (its face's doors are U2's).
    var noKeyFileAnywhere: NoKeyFileAnywhere?

    /// The face for the lobby's facts, the last press and this Mac's biometry after it.
    static func derive(
        _ standing: RoadLobbyFacts, press: TouchIDPress? = nil, biometry: BiometryFacts? = nil
    ) -> ProtectionLobbyFace {
        guard var facts = standing.facts else {
            // P-VX306-U1a-3: nothing was listed, so nothing is claimed — no Touch ID face, both typed roads.
            return ProtectionLobbyFace(
                touchIDButton: false, touchIDLine: nil, autoAsk: false, pressSays: nil, passphraseField: true,
                wordsRoad: .disclosure, keychainUnreadable: true,
                liveKeyFileUnreadable: standing.liveKeyFileUnreadable, noKeyFileAnywhere: nil)
        }
        if let press { facts.touchIDPress = press }
        if let biometry { facts.biometry = biometry }
        let touchID = AssessRules.touchID(facts, guards: .all)
        let roads = AssessRules.lobby(facts)
        var typed = roads.typed.union(standing.offeredTyped)
        if typed.isEmpty, roads.noKeyFileAnywhere == nil {
            // A library this Mac can see no key file's locks for (a live file it can't read): both roads are
            // offered — every road verifies itself (rule 2: every library has its words).
            typed = [.passphrase, .words]
        }
        let line: TouchIDLine?
        if touchID.button {
            line = touchID.changedLine ? .changed : nil
        } else {
            switch touchID.quietLine {
            case .notSetUpOnThisMac?: line = .notSetUpOnThisMac
            case .notSetUpForThisLibrary?: line = .notSetUpForThisLibrary
            case nil: line = nil
            }
        }
        let passphrase = typed.contains(.passphrase)
        let words: WordsRoad = typed.contains(.words) ? (passphrase ? .disclosure : .field) : .none
        let nothing = roads.noKeyFileAnywhere
        return ProtectionLobbyFace(
            touchIDButton: touchID.button, touchIDLine: line, autoAsk: touchID.autoAsk, pressSays: touchID.pressSays,
            passphraseField: nothing == nil && passphrase, wordsRoad: nothing == nil ? words : .none,
            keychainUnreadable: false, liveKeyFileUnreadable: standing.liveKeyFileUnreadable,
            noKeyFileAnywhere: nothing)
    }

    /// The lead line over the typed field.
    var lead: String {
        ProtectionWords.lobbyLead(passphrase: passphraseField, words: wordsRoad != .none)
    }

    /// The Touch ID line's words.
    var touchIDLineWords: String? {
        switch touchIDLine {
        case .notSetUpOnThisMac?: return ProtectionWords.touchIDNotSetUpOnThisMac
        case .notSetUpForThisLibrary?: return ProtectionWords.touchIDNotSetUpForThisLibrary
        case .changed?: return ProtectionWords.touchIDChanged
        case nil: return nil
        }
    }
}
