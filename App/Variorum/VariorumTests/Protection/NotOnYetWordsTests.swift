//
//  NotOnYetWordsTests.swift
//  VariorumTests — VX-510 unit A (VX-506, riding): "sync shouldn't seem like you're restarting it." Two faces said a lock
//  or a restart where there is only a not-yet:
//    - Settings ▸ Protection's door over the JOIN arm (the signed-in account already syncs — its vault exists) read "Turn on
//      sync…", the set-up arm's own name, for an account that is already on (her words: "should that not be sign into sync
//      instead of turn on?"). The join arm's door gets its own label; the set-up arm keeps "Turn on sync…". RED on old.
//    - the sync row's keys refusal said "Sync locked — this Mac hasn't unlocked your account's sync keys" for a library
//      that has NOT joined (its record names no account) — there is no lock there, only a not-yet. The face splits on the
//      bootstrap's record fact (`RoadStandingModel.syncsWithAnAccount`): unjoined reads "Sync isn't on for this library
//      yet" with the same Protection… door; a joined library whose keys are not loaded keeps P-VX486-2's line.
//  Words PROVISIONAL, hers (the run record's OPEN ITEMS, P-VX510-2 (a) and P-VX510-3 (a) built). Over the planted road (no
//  keychain, the planted vault — no network); also runs headless in the implementer's SwiftPM harness.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-510 unit A — the not-yet words (VX-506)")
@MainActor
struct NotOnYetWordsTests {
    typealias Account = PlantedAccount

    /// **VX-506 — THE JOIN ARM'S DOOR (red on old: it wore "Turn on sync…", the set-up arm's name).** With no vault on the
    /// signed-in account the door is the set-up — "Turn on sync…"; once the account syncs (another device turned it on) the
    /// same door is the JOIN and says so in its own words, in every posture the join can take.
    @Test(arguments: [ProtectionMode.standard, .castle])
    func theJoinArmsDoorHasItsOwnLabel(_ accountMode: ProtectionMode) async throws {
        let (road, vault, _) = Account.road()
        let (session, _) = try await road.created()
        let setUp = try #require(
            ProtectionPaneRead.accountFaces(try await Account.read(session, Account.signedIn))?.turnOnSync.openDoor)
        #expect(setUp.spec.join == .setsUpInLibrarysMode, "no vault yet — the set-up arm")
        #expect(setUp.doorLabel == "Turn on sync\u{2026}", "the set-up arm keeps its name")

        try vault.plant(
            accountID: Account.account, passphrase: "another device's", words: try RecoveryPhrase.generate(),
            mode: accountMode)
        let join = try #require(
            ProtectionPaneRead.accountFaces(try await Account.read(session, Account.signedIn))?.turnOnSync.openDoor)
        #expect(join.spec.join != nil && join.spec.join != .setsUpInLibrarysMode, "the account syncs — the join arm")
        #expect(join.doorLabel == "Sync this library\u{2026}", "the join's own door (PROVISIONAL, hers)")
        #expect(join.doorLabel != setUp.doorLabel, "never the set-up arm's name over the join")
    }

    private static let keysLocked = String(describing: SyncError.encryptionKeysUnavailable)

    private static func face(libraryJoined: Bool?, error: String? = keysLocked, door: Bool = true) -> SyncRowFace {
        SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true, isSyncing: false, lastError: error,
            lastErrorIsOffline: false, canOpenProtection: door, libraryJoined: libraryJoined)
    }

    /// **VX-506 — THE UNJOINED ROW (a new seam's pin — red by the record's revert):** the keys refusal over a library whose
    /// record names no account reads a not-yet — never "locked" — with the locked face's own door where the pane exists, and
    /// the sentence alone where it doesn't (P-2).
    @Test func theUnjoinedLibrarysRowSaysNotOnYetNeverLocked() {
        let unjoined = Self.face(libraryJoined: false)
        #expect(unjoined.kind == .notOnYet)
        #expect(unjoined.doors == [SyncRowFace.Door(label: "Protection\u{2026}", act: .openProtection)],
                "the same door: Settings ▸ Protection, where Turn on sync stands")
        #expect(Self.face(libraryJoined: false, door: false).doors.isEmpty, "no pane, the sentence alone")
        let line = SyncStatusRow.line(for: unjoined.kind, lastSuccessAt: nil)
        #expect(line == "Sync isn't on for this library yet", "PROVISIONAL, hers (P-VX510-2 (a))")
        #expect(line == SyncStatusRow.notOnYetLabel)
        #expect(!line.lowercased().contains("locked") && !line.contains("keys"), "nothing is locked — a not-yet")
    }

    /// The JOINED library whose keys are not loaded keeps P-VX486-2's locked line and door; an unknown fact (no injection —
    /// every composition before this one) keeps the shipped face too.
    @Test func theJoinedLockedRowIsUnchanged() {
        for joined in [true, nil] as [Bool?] {
            let face = Self.face(libraryJoined: joined)
            #expect(face.kind == .keysLocked, "\(String(describing: joined))")
            #expect(face.doors == [SyncRowFace.Door(label: "Protection\u{2026}", act: .openProtection)])
            #expect(SyncStatusRow.line(for: face.kind, lastSuccessAt: nil) == SyncStatusRow.lockedLabel)
        }
        #expect(SyncStatusRow.lockedLabel
            == "Sync locked \u{2014} this \(ProtectionCopy.deviceName) hasn't unlocked your account's sync keys")
    }

    /// Only the KEYS refusal splits on the fact: every other state reads the same whether the library has joined or not.
    @Test func onlyTheKeysRefusalSplits() {
        let errors: [String?] = [
            nil, "Sync error: something else",
            String(describing: SyncError.encryptionKeysReplaced),
            String(describing: SyncError.accountMismatch(bound: "a", signedIn: "b")),
            String(describing: SyncError.schemaLockstepMismatch(client: 12, server: 13)),
        ]
        for error in errors {
            #expect(Self.face(libraryJoined: false, error: error) == Self.face(libraryJoined: true, error: error),
                    "\(String(describing: error))")
            #expect(Self.face(libraryJoined: false, error: error).kind != .notOnYet)
        }
    }

    /// Both roots hand the row the open library's record fact (the bootstrap's standing faces — the hold banner's own read),
    /// so the face can split. Source pins (the composition roots are app files).
    @Test func bothRootsInjectTheLibrarysRecordFact() throws {
        let app = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let injection = ".environment(\\.librarySyncsWithAnAccount, bootstrap.roadStanding?.syncsWithAnAccount)"
        for root in ["Variorum/VariorumApp.swift", "VariorumMobile/VariorumMobileApp.swift"] {
            let text = try String(contentsOf: app.appendingPathComponent(root), encoding: .utf8)
            #expect(text.contains(injection), "\(root) injects the record fact")
        }
    }
}
