//
//  ProtectionKeyDoorActs.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-308 U3 piece 5 — THE KEY DOORS' ROADS on the open library, off the main actor (`notes/plans/vx-308-accounts-key-
//  doors.md` §5c; the contract `notes/CastleRules.md` rules 6, 7). Through the session's executor — the one thing that
//  writes — and NOTHING HERE DECIDES: `assess` says what each door is (THE PANE'S ONE READ — U1's R-2), the core's acts
//  (`changePassphrase`, `resetPassphrase` — `Acts/KeyDoors.swift`) re-lock the CURRENT key on their sealed plans (rule
//  20), the synced vault half running INSIDE the act (rule 7's together-change).
//
//    - THE READ (`read`): the pane's one read, the key doors' faces from it.
//    - THE PRESS (`press`): one act at a time on the session; the door RE-READ (VX-108 — closed refuses, changed is
//      re-shown, nothing written); the CURRENT sign-in adopted into the executor under the act (R-2); Castle's Touch ID
//      road PRESSED first — a READ of this Mac's Touch ID item for the current key, which prompts (today's road's presence
//      confirm kept, design §3.9; the core's `.touchID` reads the open as the press, this makes it one now); then the core's
//      act ON THE OPEN SESSION — the key doors re-wrap the current key and never swap it, so no reopen (the set-passphrase
//      road's precedent; no reopening seam). An act stopped mid-plan says it finishes at the next open, never "nothing
//      changed" (U1's idiom).
//    New Words is the look's road (`ProtectionOpenRoad.mintFreshWords`) — never pressed here.
//

import Foundation
import VariorumCore

/// One key door's press, as the confirm hands it to the road.
nonisolated struct RoadKeyDoorRequest: Sendable, CustomStringConvertible {
    let door: RoadKeyDoor
    /// The door as the confirm showed it — the road compares the door it re-reads with this (VX-108).
    let shown: RoadKeyDoorOpen
    /// Change: the current passphrase (untrimmed).
    var current: String? = nil
    /// The new passphrase (untrimmed; typed twice at the confirm).
    let new: String
    /// Castle's forgot road: the twelve words typed.
    var words: [String]? = nil
    /// Castle's forgot road: Touch ID instead of the words.
    var touchID = false

    var description: String { "RoadKeyDoorRequest(\(door.rawValue), redacted)" }
}

/// What a key door's press came to.
nonisolated enum RoadKeyDoorPress: Equatable, Sendable {
    /// The act landed — its receipt.
    case made(String)
    case refused(String)
    /// The door is open but says something new (VX-108) — re-shown.
    case changed(RoadKeyDoorOpen)
}

nonisolated enum ProtectionKeyDoorRoad {
    /// The key doors' faces from the pane's one read (nil: the facts could not be read — no door rather than a guess).
    static func faces(_ read: ProtectionPaneFacts) -> RoadKeyDoorFaces? {
        RoadKeyDoorFaces.derive(read.facts, assess(read.facts))
    }

    /// THE READ — the pane's one read over `session` as `signIn`.
    static func read(
        _ session: ProtectionRoadSession, signIn: SessionFact, exportSwitch: ScheduledExportSwitch?
    ) async -> RoadKeyDoorFaces? {
        await ProtectionPaneRead.read(session, signIn: signIn, exportSwitch: exportSwitch).flatMap(faces)
    }

    /// THE PRESS on the OPEN session — every check first (all reads), then the act; one act at a time on the session.
    static func press(
        _ session: ProtectionRoadSession, request: RoadKeyDoorRequest, signIn: SessionFact,
        exportSwitch: ScheduledExportSwitch?
    ) async -> RoadKeyDoorPress {
        guard session.writes, request.door != .newWords else { return .refused(ProtectionWords.crossingFailed) }
        guard session.beginAct() else { return .refused(ProtectionWords.copyDoorBusy) }
        defer { session.endAct() }
        // VX-108: the door as it stands NOW, read the way the shown one was.
        guard let faces = await read(session, signIn: signIn, exportSwitch: exportSwitch) else {
            return .refused(ProtectionWords.crossingFailed)
        }
        switch faces.face(request.door) {
        case .hidden: return .refused(ProtectionWords.crossingDoorClosed)
        case .refused(let sentence): return .refused(sentence)
        case .open(let now):
            guard now == request.shown else { return .changed(now) }
        }
        // R-2: the sign-in NOW — never the open's.
        session.executor.configuration.session = signIn
        var library = session.library
        let authorization: ResetAuthorization
        switch (request.door, request.shown.reset) {
        case (.resetForgottenPassphrase, .wordsOrTouchID(let touchIDHere)?):
            if request.touchID {
                guard touchIDHere, pressTouchID(session, library) else {
                    return .refused(ProtectionWords.resetPassphraseTouchIDNotConfirmed)
                }
                authorization = .touchID
            } else {
                guard let words = request.words else { return .refused(ProtectionWords.crossingSecretsMissing) }
                authorization = .words(words)
            }
        default:
            authorization = .plainConfirm
        }
        do {
            switch request.door {
            case .changePassphrase:
                guard let current = request.current else { return .refused(ProtectionWords.crossingSecretsMissing) }
                _ = try await session.executor.changePassphrase(&library, current: current, new: request.new)
            case .resetForgottenPassphrase:
                _ = try await session.executor.resetPassphrase(&library, authorization: authorization, new: request.new)
            case .newWords:
                return .refused(ProtectionWords.crossingFailed)
            }
        } catch {
            session.library = library
            let unfinished = library.section.actInFlight != nil
            ProtectionOpenRoad.log("road: \(request.door.rawValue) did not land"
                + (unfinished ? " — its act stays in flight; the next open settles it" : "") + " — \(String(describing: error))")
            return .refused(RoadAccountFaces.actRefusalSentence(error, unfinished: unfinished))
        }
        session.library = library
        ProtectionOpenRoad.log("road: \(request.door.rawValue) — the current key re-locked "
            + "(\(StoreKeyEnvelope.shortFingerprint(library.fingerprint)))\(request.shown.synced ? ", the account's lock with it" : "")")
        return .made(request.door.receipt ?? ProtectionWords.crossingFailed)
    }

    /// Castle's Touch ID road, PRESSED: this Mac's Touch ID item for the current key, READ (the read prompts — VX-310's
    /// press), and its key the library's. True: confirmed.
    static func pressTouchID(_ session: ProtectionRoadSession, _ library: UnlockedLibrary) -> Bool {
        do {
            return try session.system.custody.readCustody(fingerprint: library.fingerprint, itemClass: .touchid) == library.key
        } catch {
            ProtectionOpenRoad.log("road: the reset's Touch ID press failed — \(String(describing: error))")
            return false
        }
    }
}
