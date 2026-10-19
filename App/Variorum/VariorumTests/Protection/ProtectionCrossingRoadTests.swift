//
//  ProtectionCrossingRoadTests.swift
//  VariorumTests — VX-307 U2a piece 2: THE CROSSINGS' ROADS (`ProtectionCrossings`) over the new road's PLANTED leaves
//  (no keychain — `PlantedRoad`; also runs headless in the implementer's SwiftPM harness) and a temp slot with the real
//  file and SQLCipher leaves: Use Castle under Always ask and under Touch ID (rule 11 — everything taken in), Use Standard
//  back (rule 12 — everything handed out), a typo that writes nothing, the door RE-READ at the press (VX-108), the
//  scheduled export turning off with rule 11's notice and turning back on, Replace All Keys with no account to act on,
//  and the gate-style row (`changeSettings`). The bootstrap's seam around these (the pool closed, the reopen) is
//  `ProtectionCrossingRouteTests`' (the Mac target).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// An in-memory scheduled-export switch (production's is `MarkdownInsurance` over this Mac's defaults).
nonisolated final class PlantedExportSwitch: @unchecked Sendable {
    private let lock = NSLock()
    private var on: Bool
    private var owed = false
    private(set) var writes: [Bool] = []

    init(_ on: Bool = false) { self.on = on }

    var value: Bool { lock.withLock { on } }
    /// Rule 11's notice owed — the durable mark (MAJOR-1).
    var noticeOwed: Bool { lock.withLock { owed } }

    var road: ScheduledExportSwitch {
        ScheduledExportSwitch(
            isOn: { self.value },
            set: { value in
                self.lock.withLock {
                    self.on = value
                    self.writes.append(value)
                }
            },
            noticeOwed: { self.noticeOwed },
            setNoticeOwed: { value in self.lock.withLock { self.owed = value } })
    }
}

@MainActor
enum Crossing {
    static let passphrase = "a castle passphrase"

    /// The door as the confirm opens it.
    static func open(
        _ session: ProtectionRoadSession, _ door: RoadCrossingDoor, _ exports: PlantedExportSwitch = PlantedExportSwitch()
    ) throws -> RoadDoorOpen {
        let faces = try #require(ProtectionCrossings.readCrossings(session, exportSwitch: exports.road))
        return try #require(faces.face(door).openDoor, "\(door) is open: \(faces.face(door))")
    }

    /// The door's press, the preflight then the act (the bootstrap's order, with no pool to close here).
    static func press(
        _ session: ProtectionRoadSession, _ door: RoadCrossingDoor, typed: TypedSecrets, gate: GateStyle = .alwaysAsk,
        exports: PlantedExportSwitch = PlantedExportSwitch()
    ) async throws -> CrossingResult {
        let shown = try open(session, door, exports)
        let preflight = ProtectionCrossings.preflight(session, door: door, shown: shown, typed: typed, exportSwitch: exports.road)
        guard preflight == .ready else {
            Issue.record("the preflight: \(preflight)")
            return CrossingResult(outcome: .refused("preflight"), reopenKey: session.key)
        }
        return await ProtectionCrossings.cross(session, door: door, typed: typed, gate: gate, exportSwitch: exports.road)
    }

    /// A library in Castle under Always ask (its passphrase set at the door).
    static func inCastle(_ road: PlantedRoad) async throws -> (session: ProtectionRoadSession, words: [String]) {
        let (session, words) = try await road.created()
        let result = try await press(session, .useCastle, typed: TypedSecrets(words: words, newPassphrase: passphrase))
        #expect(result.outcome == .made(.useCastle, exportTurnedOff: false))
        return (session, words)
    }

    static func items(_ road: PlantedRoad, _ itemClass: ProtectionNames.CustodyClass) -> [String] {
        road.custody.items.keys.filter { $0.itemClass == itemClass }.map(\.fingerprint).sorted()
    }
}

@Suite("VX-307 U2a — the crossings' roads over planted leaves (no keychain)")
@MainActor
struct ProtectionCrossingRoadTests {
    /// RULE 11, Always ask — the passphrase (set at the door: rule 3) AND the words typed; a new Castle key carrying the
    /// old one in its history; every silent item and this Mac's Apple key gone; no copy of the key on this Mac; a fresh
    /// backup under the new key; the reopen key the new one.
    @Test func useCastleUnderAlwaysAskTakesEverythingIn() async throws {
        let road = PlantedRoad()
        let (session, words) = try await road.created()
        let oldKey = session.key
        let oldFingerprint = session.library.fingerprint
        let libraryID = try #require(session.library.record?.libraryID)
        #expect(!Crossing.items(road, .silent).isEmpty && !road.apple.keys.isEmpty)
        let result = try await Crossing.press(
            session, .useCastle, typed: TypedSecrets(words: words, newPassphrase: Crossing.passphrase))
        #expect(result.outcome == .made(.useCastle, exportTurnedOff: false))
        let library = session.library
        #expect(library.record?.mode == .castle)
        #expect(session.key != oldKey && result.reopenKey == session.key)
        #expect(ProtectionLibraryFiles.opens(road.slot.places.slot, key: result.reopenKey))
        #expect(!ProtectionLibraryFiles.opens(road.slot.places.slot, key: oldKey))
        #expect(Crossing.items(road, .silent).isEmpty, "no silent item for any key the library has had")
        #expect(Crossing.items(road, .touchid).isEmpty, "Always ask: no copy of the key on this Mac")
        #expect(try road.apple.appleKeyIDs(ofLibrary: libraryID).isEmpty, "this Mac's Apple key deleted")
        #expect(library.section.settings.gateStyle == .alwaysAsk)
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(live.apple == nil && live.passphrase != nil && live.opensWithTheWords)
        #expect(try live.open(.words(words), floor: .relaxedForTests) == session.key)
        #expect(try live.open(passphrase: .passphrase(Crossing.passphrase), floor: .relaxedForTests) == session.key)
        #expect(live.heldFingerprints.contains(oldFingerprint), "rule 4: the history carries the earlier key")
        #expect(road.system().lister.catalog().copies.contains { $0.kind == .backup && $0.fingerprint == library.fingerprint },
                "a fresh backup under the new key")
        // The doors now: Use Standard open with rule 12's sentence; Use Castle renders nothing; the gate row stands.
        let faces = try #require(ProtectionCrossings.readCrossings(session, exportSwitch: PlantedExportSwitch().road))
        #expect(faces.mode == .castle && faces.useCastle == .hidden)
        #expect(faces.useStandard.openDoor?.sentences.contains(ProtectionWords.leaveSentence) == true)
        #expect(faces.gateRow == RoadGateRow(current: .alwaysAsk, touchIDAvailable: false))
    }

    /// RULE 11 with Touch ID chosen where this Mac has a finger: the Touch ID item is made at THIS press, for the new key.
    @Test func useCastleWithTouchIDMakesTheItemAtThisPress() async throws {
        let road = PlantedRoad()
        road.biometry = .ready
        let (session, words) = try await road.created()
        let shown = try Crossing.open(session, .useCastle)
        #expect(shown.gate == RoadGateChoice(touchIDAvailable: true, preselected: .touchID))
        let result = try await Crossing.press(
            session, .useCastle, typed: TypedSecrets(words: words, newPassphrase: Crossing.passphrase), gate: .touchID)
        #expect(result.outcome == .made(.useCastle, exportTurnedOff: false))
        #expect(Crossing.items(road, .touchid) == [session.library.fingerprint])
        #expect(Crossing.items(road, .silent).isEmpty)
        #expect(session.library.section.settings.gateStyle == .touchID)
    }

    /// RULE 12 — both secrets; a new Standard key carrying every earlier key, the Castle one included; a fresh Apple road
    /// (this Mac's own Apple key minted and wrapping it) and the on-device road back; the gate row gone.
    @Test func useStandardHandsEverythingOut() async throws {
        let road = PlantedRoad()
        let (session, words) = try await Crossing.inCastle(road)
        let castleFingerprint = session.library.fingerprint
        let libraryID = try #require(session.library.record?.libraryID)
        let open = try Crossing.open(session, .useStandard)
        #expect(!open.newPassphrase && open.sentences.contains(ProtectionWords.leaveSentence))
        let result = try await Crossing.press(
            session, .useStandard, typed: TypedSecrets(passphrase: Crossing.passphrase, words: words))
        #expect(result.outcome == .made(.useStandard, exportTurnedOff: false))
        #expect(session.library.record?.mode == .standard)
        #expect(Crossing.items(road, .silent) == [session.library.fingerprint], "the on-device road back")
        let apple = try road.apple.appleKeyIDs(ofLibrary: libraryID)
        #expect(apple.count == 1, "a fresh own Apple key")
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(live.apple.map { apple.contains($0.keyID) } == true, "the new key under the fresh Apple road")
        #expect(live.heldFingerprints.contains(castleFingerprint), "rule 12: the Castle key carried")
        let faces = try #require(ProtectionCrossings.readCrossings(session, exportSwitch: PlantedExportSwitch().road))
        #expect(faces.mode == .standard && faces.gateRow == nil && faces.useStandard == .hidden)
    }

    /// THE SESSION IS THE OPEN LIBRARY'S ONE HOLDER (the headless twin of the batch run's route-test red): a crossing run
    /// on a session writes the act's library into it, so the session's `key` — computed from what it holds — answers the
    /// key AFTER the act; a key read before it must be captured as a value. Two crossings on one session: three distinct
    /// keys, each the reopen key of its act.
    @Test func aSessionsKeyIsTheOpenLibrarysNow() async throws {
        let road = PlantedRoad()
        let (session, words) = try await road.created()
        let created = session.key
        let enter = try await Crossing.press(
            session, .useCastle, typed: TypedSecrets(words: words, newPassphrase: Crossing.passphrase))
        let castle = session.key
        #expect(castle != created && enter.reopenKey == castle)
        let leave = try await Crossing.press(
            session, .useStandard, typed: TypedSecrets(passphrase: Crossing.passphrase, words: words))
        #expect(session.key == leave.reopenKey, "the live read answers the latest act's key")
        #expect(session.key != castle && session.key != created, "three distinct keys — the captured values stand")
    }

    /// A typo is refused at the preflight — NOTHING written: the container's bytes, the keychain and the Apple keys as
    /// they were.
    @Test func aTypoIsRefusedAndWritesNothing() async throws {
        let road = PlantedRoad()
        let (session, words) = try await road.created()
        let shown = try Crossing.open(session, .useCastle)
        let before = try Plant.containerBytes(road)
        let custodyWrites = road.custody.writes.count
        let wrongWords = ProtectionCrossings.preflight(
            session, door: .useCastle, shown: shown,
            typed: TypedSecrets(words: try RecoveryPhrase.generate(), newPassphrase: Crossing.passphrase),
            exportSwitch: PlantedExportSwitch().road)
        #expect(wrongWords == .refused(ProtectionWords.wordsDoNotOpen))
        let noPassphrase = ProtectionCrossings.preflight(
            session, door: .useCastle, shown: shown, typed: TypedSecrets(words: words, newPassphrase: ""),
            exportSwitch: PlantedExportSwitch().road)
        #expect(noPassphrase == .refused(ProtectionWords.crossingSecretsMissing))
        #expect(try Plant.containerBytes(road) == before)
        #expect(road.custody.writes.count == custodyWrites)
        // With a passphrase set, a wrong one is refused the same way.
        #expect(await ProtectionOpenRoad.setFirstPassphrase(session: session, new: Crossing.passphrase) == .set)
        let current = try Crossing.open(session, .useCastle)
        #expect(!current.newPassphrase)
        let wrong = ProtectionCrossings.preflight(
            session, door: .useCastle, shown: current, typed: TypedSecrets(passphrase: "not it", words: words),
            exportSwitch: PlantedExportSwitch().road)
        #expect(wrong == .refused(ProtectionWords.passphraseDoesNotOpen))
        #expect(session.library.record?.mode == .standard)
    }

    /// VX-108 — THE PRESS RE-READS THE DOOR: a door that closed since the confirm opened refuses (nothing written); a door
    /// whose words changed (the scheduled export came on) re-shows instead of acting on what she did not read.
    @Test func vx108_theDoorIsReReadAtThePress() async throws {
        let road = PlantedRoad()
        let (session, words) = try await road.created()
        let staleCastle = try Crossing.open(session, .useCastle)
        let exports = PlantedExportSwitch(false)
        let changed = PlantedExportSwitch(true)
        guard case .changed(let fresh) = ProtectionCrossings.preflight(
            session, door: .useCastle, shown: staleCastle,
            typed: TypedSecrets(words: words, newPassphrase: Crossing.passphrase), exportSwitch: changed.road)
        else {
            Issue.record("a changed door re-shows")
            return
        }
        #expect(fresh.sentences.last == ProtectionWords.scheduledExportTurnsOff)
        #expect(session.library.record?.mode == .standard, "nothing acted")
        // The library crosses; the confirm still holding Use Castle's old door is refused at its press.
        _ = try await Crossing.press(
            session, .useCastle, typed: TypedSecrets(words: words, newPassphrase: Crossing.passphrase), exports: exports)
        let before = try Plant.containerBytes(road)
        let refused = ProtectionCrossings.preflight(
            session, door: .useCastle, shown: staleCastle,
            typed: TypedSecrets(passphrase: Crossing.passphrase, words: words), exportSwitch: exports.road)
        #expect(refused == .refused(ProtectionWords.crossingDoorClosed))
        #expect(try Plant.containerBytes(road) == before)
    }

    /// RULE 11's scheduled export: on → the door says it turns off; the act turns it off (this Mac's sealed setting and
    /// the switch) and owes the one notice; *Turn it back on* reverses both — her call.
    @Test func theScheduledExportTurnsOffWithTheNoticeAndBackOn() async throws {
        let road = PlantedRoad()
        let (session, words) = try await road.created()
        let exports = PlantedExportSwitch(true)
        let shown = try Crossing.open(session, .useCastle, exports)
        #expect(shown.sentences.last == ProtectionWords.scheduledExportTurnsOff)
        let result = try await Crossing.press(
            session, .useCastle, typed: TypedSecrets(words: words, newPassphrase: Crossing.passphrase), exports: exports)
        #expect(result.outcome == .made(.useCastle, exportTurnedOff: true))
        #expect(!exports.value && !session.library.section.settings.scheduledExport)
        #expect(await ProtectionCrossings.turnExportBackOn(session, exportSwitch: exports.road))
        #expect(exports.value && session.library.section.settings.scheduledExport)
        // With the switch off, Use Castle says nothing of it and owes no notice.
        let quiet = PlantedRoad()
        let (other, otherWords) = try await quiet.created()
        let off = PlantedExportSwitch(false)
        #expect(try Crossing.open(other, .useCastle, off).sentences.contains(ProtectionWords.scheduledExportTurnsOff) == false)
        let none = try await Crossing.press(
            other, .useCastle, typed: TypedSecrets(words: otherWords, newPassphrase: Crossing.passphrase), exports: off)
        #expect(none.outcome == .made(.useCastle, exportTurnedOff: false))
        #expect(off.writes.isEmpty, "a switch that was off is never written")
    }

    /// Replace All Keys needs an account (`.notSynced`): not rendered on a local library, refused at the press (the door
    /// re-read), and the act itself refuses before anything moves.
    @Test func replaceAllKeysHasNoSubjectOnALocalLibrary() async throws {
        let road = PlantedRoad()
        let (session, words) = try await road.created()
        let faces = try #require(ProtectionCrossings.readCrossings(session, exportSwitch: PlantedExportSwitch().road))
        #expect(faces.replaceAllKeys == .hidden)
        let spec = DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: false), rekeys: true, synced: true)
        let shown = RoadCrossingFaces.open(
            .replaceAllKeys, spec, passphraseSet: false, gate: nil, biometry: .none, copyName: { _ in nil })
        let typed = TypedSecrets(passphrase: Crossing.passphrase, words: words)
        #expect(ProtectionCrossings.preflight(
            session, door: .replaceAllKeys, shown: shown, typed: typed, exportSwitch: PlantedExportSwitch().road)
            == .refused(ProtectionWords.crossingDoorClosed))
        let key = session.key
        let result = await ProtectionCrossings.cross(
            session, door: .replaceAllKeys, typed: typed, gate: .alwaysAsk, exportSwitch: PlantedExportSwitch().road)
        #expect(result.outcome == .refused(ProtectionWords.crossingDoorClosed))
        #expect(result.reopenKey == key && session.key == key)
        // Use Standard on a Standard library — the act's own refusal, nothing swapped.
        let standard = await ProtectionCrossings.cross(
            session, door: .useStandard, typed: typed, gate: .alwaysAsk, exportSwitch: PlantedExportSwitch().road)
        #expect(standard.outcome == .refused(ProtectionWords.crossingDoorClosed))
        #expect(session.library.record?.mode == .standard && session.key == key)
    }

    /// LADDER ROUND 1, MAJOR-1 — A USE CASTLE THAT STOPS PAST ITS SWAP, BEFORE ITS EXPORT STEP (a step after the swap
    /// fails — the crash-window idiom): the in-process tail never follows the switch; the next open's settle resumes the
    /// act and turns this Mac's SEALED export off — and before the fix the weekly switch STAYED ON in Castle, with the
    /// notice unspoken (red on the pre-fix tree: the harness probe's `!exports.value`). The fix: rule 11's notice is a
    /// durable mark written before the act, and every ready on the new road reconciles — the switch follows the core's
    /// step, the notice stays owed until *OK* or *Turn it back on*.
    @Test func major1_anEntryStoppingPastItsSwapIsReconciledAtTheNextReady() async throws {
        let road = PlantedRoad()
        let (session, words) = try await road.created()
        let exports = PlantedExportSwitch(true)
        road.custody.failingDeletes = 1  // `retireOldCustody` — after the swap, before `exportOff`
        let result = try await Crossing.press(
            session, .useCastle, typed: TypedSecrets(words: words, newPassphrase: Crossing.passphrase), exports: exports)
        #expect(result.outcome == .made(.useCastle, exportTurnedOff: false), "landed past the swap, its tail never ran")
        #expect(exports.value && exports.noticeOwed, "the switch untouched in-process; the notice owed — durably")
        // The next open, through the road: its settle resumes the act and runs the export step.
        guard case .opened(let reopened) = await ProtectionOpenRoad.route(road.context(), keyInHand: result.reopenKey) else {
            Issue.record("the reopen opens the crossed library")
            return
        }
        #expect(reopened.library.record?.mode == .castle)
        #expect(!reopened.library.section.settings.scheduledExport, "the settle's resume turned the sealed export off")
        #expect(exports.value, "the hole as the pre-fix tree left it: the switch still on")
        // The ready's reconcile (the bootstrap runs it at every open on the new road).
        #expect(ProtectionCrossings.reconcileExport(reopened.library, exportSwitch: exports.road), "followed HERE")
        #expect(!exports.value, "rule 11: the weekly export is off in Castle")
        #expect(exports.noticeOwed, "the notice stays owed until OK or Turn it back on")
        #expect(!ProtectionCrossings.reconcileExport(reopened.library, exportSwitch: exports.road), "once")
    }

    /// MAJOR-1's second corner — the notice is DURABLE (a quit before *OK* loses nothing) and owed only while it applies:
    /// *OK* clears it; *Turn it back on* clears it; a ready that finds the library out of Castle clears it; an entry that
    /// refused before anything moved never leaves it; with the switch off nothing is ever owed.
    @Test func major1_theNoticeIsDurableUntilAnsweredAndOwedOnlyWhileItApplies() async throws {
        let road = PlantedRoad()
        let (session, words) = try await road.created()
        let exports = PlantedExportSwitch(true)
        // A refusal before anything moves (the act's own: a wrong passphrase on a library with one) leaves no mark.
        #expect(await ProtectionOpenRoad.setFirstPassphrase(session: session, new: Crossing.passphrase) == .set)
        let refused = await ProtectionCrossings.cross(
            session, door: .useCastle, typed: TypedSecrets(passphrase: "not it", words: words), gate: .alwaysAsk,
            exportSwitch: exports.road)
        #expect(refused.outcome == .refused(ProtectionWords.passphraseDoesNotOpen))
        #expect(!exports.noticeOwed && exports.value)
        // The entry: the in-process tail follows the switch; the mark stands past this process's memory.
        let entered = await ProtectionCrossings.cross(
            session, door: .useCastle, typed: TypedSecrets(passphrase: Crossing.passphrase, words: words),
            gate: .alwaysAsk, exportSwitch: exports.road)
        #expect(entered.outcome == .made(.useCastle, exportTurnedOff: true))
        #expect(!exports.value && exports.noticeOwed)
        #expect(!ProtectionCrossings.reconcileExport(session.library, exportSwitch: exports.road), "already followed")
        #expect(exports.noticeOwed, "a relaunch's ready still owes the notice")
        ProtectionCrossings.dismissExportNotice(exportSwitch: exports.road)
        #expect(!exports.noticeOwed)
        // *Turn it back on* answers it too.
        exports.road.setNoticeOwed(true)
        #expect(await ProtectionCrossings.turnExportBackOn(session, exportSwitch: exports.road))
        #expect(exports.value && !exports.noticeOwed)
        // A ready that finds the library out of Castle owes nothing (and never touches the switch).
        exports.road.setNoticeOwed(true)
        _ = try await Crossing.press(
            session, .useStandard, typed: TypedSecrets(passphrase: Crossing.passphrase, words: words), exports: exports)
        #expect(!ProtectionCrossings.reconcileExport(session.library, exportSwitch: exports.road))
        #expect(!exports.noticeOwed && exports.value)
    }

    /// THE GATE-STYLE ROW (Castle): Touch ID comes on only with the passphrase (a wrong one makes no item); Always ask
    /// deletes the item.
    @Test func theGateRowTurnsTouchIDOnWithThePassphraseAndOffWithout() async throws {
        let road = PlantedRoad()
        road.biometry = .ready
        let (session, _) = try await Crossing.inCastle(road)
        #expect(Crossing.items(road, .touchid).isEmpty)
        #expect(await ProtectionCrossings.changeGate(session, to: .touchID, passphrase: "not it")
            == .refused(ProtectionWords.passphraseDoesNotOpen))
        #expect(Crossing.items(road, .touchid).isEmpty, "no item without the passphrase")
        #expect(await ProtectionCrossings.changeGate(session, to: .touchID, passphrase: Crossing.passphrase) == .changed)
        #expect(Crossing.items(road, .touchid) == [session.library.fingerprint])
        #expect(session.library.section.settings.gateStyle == .touchID)
        let faces = try #require(ProtectionCrossings.readCrossings(session, exportSwitch: PlantedExportSwitch().road))
        #expect(faces.gateRow == RoadGateRow(current: .touchID, touchIDAvailable: true))
        #expect(await ProtectionCrossings.changeGate(session, to: .alwaysAsk, passphrase: nil) == .changed)
        #expect(Crossing.items(road, .touchid).isEmpty, "Always ask deletes the item")
        #expect(session.library.section.settings.gateStyle == .alwaysAsk)
    }
}
