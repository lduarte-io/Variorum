//
//  MobileProtectionDoorsTests.swift
//  VariorumMobileTests
//
//  VM-8 unit 2 — THE PROTECTION SCREEN'S REMAINING FACES, mounted for real (`MobileSurfaceDriver`: a real key window, the
//  real accessibility tree, real activation; the run record `notes/plans/vm-8-castle-catchup.md`, UNIT 2 — LIVE STATUS).
//  The faces are hand-made here (they are pure values — the planted-road suites that derive them are the Mac's and the
//  core's); the screen is the phone's whole `MobileProtectionScreen` over a hand-built `RoadStandingModel` carrying the
//  bootstrap's four models on ONE presenter, exactly as the shell mounts it:
//    - the crossings, entering only: Use Castle in the phone's words with both secrets and the gate choice; Use Standard
//      NEVER (F-U2-G — F-PH-2); the gate-style row; Use Castle's signed-out road; no export-off notice (F-U2-A);
//    - the passphrase: *Set a passphrase…* (the floor, VX-211's hint); the key doors' confirms; a pair gate said ONCE (F-U2-D,
//      P-VM8-9); New words through the look (the passphrase asked, the words once, no Copy);
//    - THE BUG-CLASS PIN (F-U2-C): unit 1's account confirm says VX-211's hint under its new passphrase (red on the pre-fix
//      tree — it said none);
//    - the check door (VX-513 — reads one secret, says the answer, writes nothing);
//    - the follow and THE PAIR on the phone (F-U2-B — unit 1's section renders the shared faces; pinned here);
//    - the receipts' home (F-U2-E, P-VM8-8);
//    - ladder L1 (round 1's MINOR-1 — P-VM8-9 (a-unified)): the owed follow's refusal ONCE per screen, every kind — in
//      the follow's place, beside its notice, or alone there where the follow out of Castle is held (P-VM8-10).
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The world: a hand-built standing on one presenter, as the shell mounts it

@MainActor
enum U2Faces {
    static let tokens = VoiceTokens.resolve(voice: .study, dark: false)
    static let faceID = RoadGateChoice(touchIDAvailable: true, preselected: .touchID)
    static let words = (1...12).map { "word\($0)" }

    /// A throwaway defaults domain (the calm-asks ledgers'), removed when the world goes.
    final class Defaults {
        let name = "vm8-u2-\(UUID().uuidString)"
        lazy var defaults: UserDefaults = UserDefaults(suiteName: name)!
        deinit { UserDefaults().removePersistentDomain(forName: name) }
    }

    /// What the planted roads heard.
    final class Heard {
        var crossings: [RoadCrossingRequest] = []
        var gates: [(GateStyle, String?)] = []
        var keyDoors: [RoadKeyDoorRequest] = []
        var checks: [String] = []
        var sets: [String] = []
        var mints: [String?] = []
        var leaves = 0
        var keyDoorReads = 0
    }

    /// The open library's faces with the bootstrap's models — every one on `presenter`.
    static func standing(
        _ store: Defaults, heard: Heard, presenter: ProtectionSheetPresenter, passphraseExists: Bool = true,
        crossings: RoadCrossingFaces? = nil, crossingsAfterLeave: RoadCrossingFaces? = nil,
        keyDoors: RoadKeyDoorFaces? = nil, check: SecretCheckOutcome? = nil,
        account: RoadAccountFaces? = nil, replacesAccountWords: Bool = false
    ) async -> RoadStandingModel {
        let reminder = PassphraseReminderModel(
            libraryID: "vm8-u2-library", moment: nil, ledger: PassphraseReminderLedger(defaults: store.defaults),
            facts: { (passphraseSet: passphraseExists, dismissals: 0) }, recordDismissal: { true })
        let mint: (String?) async -> WordsMintOutcome = { typed in
            heard.mints.append(typed)
            return .minted(words)
        }
        let band = WordsBandModel(
            libraryID: "vm8-u2-library", writes: true, ledger: WordsCardLedger(defaults: store.defaults),
            reminder: reminder, passphraseExists: { passphraseExists }, replacesAccountWords: { replacesAccountWords },
            mint: mint, copy: { _ in })
        let standing = RoadStandingModel(
            faces: .none, reminder: reminder,
            setPassphrase: { typed in
                heard.sets.append(typed)
                return .set
            },
            passphraseExists: { passphraseExists }, receiptsOwed: { [] }, band: band, mintWords: mint,
            lookAsksPassphrase: { passphraseExists })
        standing.sheets = presenter
        if let crossings {
            var left = false
            let model = RoadCrossingsModel(
                roads: RoadCrossingRoads(
                    read: { left ? (crossingsAfterLeave ?? crossings) : crossings },
                    cross: { request in
                        heard.crossings.append(request)
                        return .made(exportTurnedOff: false)
                    },
                    changeGate: { gate, passphrase in
                        heard.gates.append((gate, passphrase))
                        return .changed
                    },
                    turnExportBackOn: { false },
                    exportNoticeOwed: { true },  // even owed, the phone has no face for it (F-U2-A)
                    dismissExportNotice: {},
                    leaveForThisMacOnly: {
                        heard.leaves += 1
                        left = true
                        return nil
                    }),
                presenter: presenter)
            await model.refresh()
            standing.crossings = model
        }
        if let keyDoors {
            let model = RoadKeyDoorsModel(
                roads: RoadKeyDoorRoads(
                    read: {
                        heard.keyDoorReads += 1
                        return keyDoors
                    },
                    press: { request in
                        heard.keyDoors.append(request)
                        return .made(ProtectionWords.changePassphraseReceipt)
                    },
                    check: checkRoad(check, heard: heard)),
                presenter: presenter)
            await model.refresh()
            standing.keyDoors = model
        }
        if let account {
            let model = RoadAccountModel(
                roads: RoadAccountRoads(read: { account }, press: { _ in .refused("nothing") }), presenter: presenter)
            await model.refresh()
            standing.account = model
        }
        return standing
    }

    /// The check road answering `answer` (nil: no check road — no door, P-2).
    static func checkRoad(
        _ answer: SecretCheckOutcome?, heard: Heard
    ) -> (@MainActor (String) async -> SecretCheckOutcome)? {
        guard let answer else { return nil }
        return { typed in
            heard.checks.append(typed)
            return answer
        }
    }

    /// Standard, a local library: Use Castle open (both typed — the current passphrase; Castle's floor and the export-first
    /// line as the core says them), Use Standard and Replace All Keys not this posture's.
    static func standardLocal(newPassphrase: Bool = false) -> RoadCrossingFaces {
        let spec = DoorSpec(
            requires: .passphraseAndWords(wordsMayBeNew: false), rekeys: true,
            words: [.floorSentence, .exportAPlainCopyFirst])
        let open = RoadCrossingFaces.open(
            .useCastle, spec, passphraseSet: !newPassphrase, gate: nil, biometry: .ready, copyName: { _ in nil })
        return RoadCrossingFaces(
            mode: .standard, useCastle: .open(open), useStandard: .hidden, replaceAllKeys: .hidden, gateRow: nil)
    }

    /// Castle, synced: Use Standard OPEN (her rule-12 sentence — the core's spec) and Replace All Keys open; the gate row.
    static func castleSynced(
        useStandard: RoadDoorFace? = nil, gate: GateStyle = .alwaysAsk, touchIDAvailable: Bool = true
    ) -> RoadCrossingFaces {
        let leave = RoadCrossingFaces.open(
            .useStandard,
            DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: false), rekeys: true, synced: true, words: [.ruleFive]),
            passphraseSet: true, gate: nil, biometry: .ready, copyName: { _ in nil })
        let replace = RoadCrossingFaces.open(
            .replaceAllKeys,
            DoorSpec(requires: .passphraseAndWords(wordsMayBeNew: false), rekeys: true, synced: true),
            passphraseSet: true, gate: nil, biometry: .ready, copyName: { _ in nil })
        return RoadCrossingFaces(
            mode: .castle, useCastle: .hidden, useStandard: useStandard ?? .open(leave), replaceAllKeys: .open(replace),
            gateRow: RoadGateRow(current: gate, touchIDAvailable: touchIDAvailable))
    }

    static func keyDoorOpen(
        _ door: RoadKeyDoor, reset: RoadResetRoad? = nil, sentences: [String] = [ProtectionWords.keyDoorsLine]
    ) -> RoadKeyDoorOpen {
        RoadKeyDoorOpen(door: door, sentences: sentences, reset: reset, synced: false,
                        spec: DoorSpec(requires: door == .changePassphrase ? .currentPassphrase : .plainConfirm))
    }

    static func keyDoors(
        change: RoadKeyDoorFace = .open(keyDoorOpen(.changePassphrase)),
        newWords: RoadKeyDoorFace = .open(keyDoorOpen(.newWords)),
        reset: RoadKeyDoorFace = .open(keyDoorOpen(
            .resetForgottenPassphrase, reset: .plainConfirm,
            sentences: [ProtectionWords.keyDoorsLine, ProtectionWords.resetPassphraseStandardLead])),
        checkStands: Bool = true, pairGate: Bool = false
    ) -> RoadKeyDoorFaces {
        RoadKeyDoorFaces(
            changePassphrase: change, newWords: newWords, resetForgottenPassphrase: reset, checkStands: checkStands,
            pairGate: pairGate)
    }

    static func account(
        situation: RoadAccountSituation = .inSync(email: nil), follow: RoadAccountDoorFace = .hidden
    ) -> RoadAccountFaces {
        RoadAccountFaces(
            situation: situation, turnOnSync: .hidden, stopSyncingHere: .hidden, deleteAccountHere: .hidden,
            thisMacOnly: .hidden, move: .hidden, signOut: true, signIn: false, vaultUnreachable: false, follow: follow)
    }

    // VM-8 ladder L1 (round 1's MINOR-1): the faces while a follow is owed — `assess` refuses every key door, the crossings
    // (its gate runs before the posture's own check) and *Stop syncing here* `.followOwed`, each saying the same sentence in
    // its place (the shared derives — `RoadKeyDoorFaces`, `RoadCrossingFaces.refusalSentence`, `RoadAccountFaces.leaf`).

    /// The key doors locked by an ordinary follow (every kind but the pair — whose gate says `followFirstToCatchUp`).
    static func followLockedKeyDoors() -> RoadKeyDoorFaces {
        let locked = RoadKeyDoorFace.refused(ProtectionWords.doorRefusedFollowOwed)
        return keyDoors(change: locked, newWords: locked, reset: locked)
    }

    /// The crossings locked by the follow (Castle: Use Standard too — the phone never renders it; the gate row stands).
    static func followLockedCrossings(_ mode: ProtectionMode) -> RoadCrossingFaces {
        let locked = RoadDoorFace.refused(ProtectionWords.doorRefusedFollowOwed)
        return RoadCrossingFaces(
            mode: mode, useCastle: locked, useStandard: mode == .castle ? locked : .hidden, replaceAllKeys: locked,
            gateRow: mode == .castle ? RoadGateRow(current: .alwaysAsk, touchIDAvailable: true) : nil)
    }

    /// In sync, a follow owed: *Stop syncing here* locked by it, *Delete the account from this iPhone…* open (rule 16's
    /// local leave writes nothing on the account), *Sign out…*.
    static func followLockedAccount(follow: RoadAccountDoorFace) -> RoadAccountFaces {
        let deleteHere = RoadAccountDoorOpen(
            door: .deleteAccountHere, ask: .nothing, newPassphrase: false,
            sentences: RoadAccountFaces.leaveSentences(.deleteAccountHere), spec: DoorSpec(requires: .none, synced: true))
        return RoadAccountFaces(
            situation: .inSync(email: nil), turnOnSync: .hidden,
            stopSyncingHere: .refused(ProtectionWords.doorRefusedFollowOwed), deleteAccountHere: .open(deleteHere),
            thisMacOnly: .hidden, move: .hidden, signOut: true, signIn: false, vaultUnreachable: false, follow: follow)
    }

    /// How many visible labels say exactly `text` (a helper, not an inline closure: Xcode 27's SIL mis-typed a second
    /// `filter` closure beside a capturing one in the posture suite — "function type mismatch").
    static func count(_ text: String, in labels: [String]) -> Int {
        labels.reduce(0) { $1 == text ? $0 + 1 : $0 }
    }

    /// The one saying stands in the follow's place: after the follow door's notice, before its door.
    static func expectTheOneSayingBesideTheFollow(
        _ labels: [String], notice: String, sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let saying = labels.firstIndex(of: ProtectionWords.doorRefusedFollowOwed)
        let said = labels.firstIndex(of: notice)
        let door = labels.firstIndex(of: ProtectionWords.followDoor)
        guard let saying, let said, let door else {
            Issue.record("the notice, the saying and the door all stand — labels were \(labels)", sourceLocation: sourceLocation)
            return
        }
        #expect(said < saying && saying < door, "notice, the one saying, the door — labels were \(labels)",
                sourceLocation: sourceLocation)
    }

    /// The screen as the shell's `.protection` destination mounts it (inside a stack; the receipts' holder through the
    /// environment).
    struct Screen: View {
        let standing: RoadStandingModel
        var receipts = MobileProtectionReceipts()
        var body: some View {
            NavigationStack {
                MobileProtectionScreen(standing: standing, services: nil, tokens: U2Faces.tokens)
                    .environment(receipts)
            }
        }
    }

    /// Types `text` into the field labelled `label` on the surface's visible tree — the real `UITextField` SwiftUI renders,
    /// through `UITextInput`'s own `insertText` (the keyboard's road), so the SwiftUI binding hears it.
    static func type(_ text: String, into label: String, on surface: HostedSurface<some View>) -> Bool {
        let root: UIView = surface.host.presentedViewController?.view ?? surface.host.view
        guard let field = fields(in: root).first(where: {
            $0.placeholder == label || $0.attributedPlaceholder?.string == label || $0.accessibilityLabel == label
        }) else { return false }
        _ = field.becomeFirstResponder()
        field.insertText(text)
        return true
    }

    static func fields(in view: UIView) -> [UITextField] {
        ((view as? UITextField).map { [$0] } ?? []) + view.subviews.flatMap { fields(in: $0) }
    }
}

// MARK: - The crossings, entering only

@Suite("VM-8 unit 2 — the phone's crossings, entering only (mounted)")
@MainActor
struct MobileProtectionCrossingsTests {
    /// USE CASTLE in the phone's words: the posture line, the door; pressed, its confirm — rule 9's promise, what entering
    /// does, Previous Libraries' line, Castle's floor naming Face ID, no Data Safety pointer (P-VM8-4) — the gate choice
    /// (Face ID or Always ask, the phone's line), BOTH secrets' fields (rule 11), the door's own button. RED on the
    /// pre-unit-2 tree: the screen carried no crossings section.
    @Test func useCastleSpeaksThePhonesWordsAndAsksBothSecrets() async throws {
        let store = U2Faces.Defaults()
        let presenter = ProtectionSheetPresenter()
        let standing = await U2Faces.standing(
            store, heard: U2Faces.Heard(), presenter: presenter, crossings: U2Faces.standardLocal())
        await withHostedSurface(U2Faces.Screen(standing: standing)) { surface in
            await surface.settle(30)
            var labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.postureLine(.standard)), "the posture line — labels were \(labels)")
            #expect(surface.activate(ProtectionWords.useCastleDoor), "Use Castle… stands")
            await surface.settle(40)
            guard case .crossing(let confirm)? = presenter.sheet else {
                Issue.record("Use Castle's confirm stands on the presenter")
                return
            }
            #expect(confirm.door.ask == .passphraseAndWords)
            labels = surface.visibleLabels
            for sentence in [ProtectionWords.castlePromise, ProtectionWords.useCastleLead,
                             ProtectionWords.castleLeavesPreviousLibraries, ProtectionWords.castleFloor] {
                #expect(labels.contains(sentence), "\(sentence) — labels were \(labels)")
            }
            #expect(!labels.contains { $0.contains("Data Safety") }, "no pointer to a road the phone doesn't have")
            #expect(labels.contains(ProtectionWords.gateTouchID) && labels.contains(ProtectionWords.gateAlwaysAsk))
            #expect(labels.contains("This iPhone keeps the new key behind Face ID."), "the phone's gate line (P-VM8-3)")
            #expect(labels.contains(ProtectionWords.crossingPassphraseField), "the passphrase's field")
            #expect(labels.contains(ProtectionWords.crossingWordsField), "the twelve words' field (rule 11: both)")
            #expect(labels.contains(ProtectionWords.useCastleTitle), "the door's own button")
            #expect(!labels.contains { $0.contains("this Mac") }, "nothing names the Mac")
        }
    }

    /// F-U2-G: USE STANDARD NEVER RENDERS ON THE PHONE — open (its confirm says her rule-12 sentence, F-PH-2) or refused (a
    /// refusal for a door the phone never offers is no road); Replace All Keys stands beside it; the export-off notice never
    /// stands (F-U2-A — even with the mark owed). RED on the pre-unit-2 tree (no section) for the Replace All Keys half; the
    /// rule-12 half is a guard (red by its own revert).
    @Test func useStandardNeverRendersAndReplaceAllKeysStands() async throws {
        #expect(MobileRoadCrossingsSection.rows(U2Faces.castleSynced()) == [.open(.replaceAllKeys)])
        let refused = U2Faces.castleSynced(useStandard: .refused("A refusal for Use Standard."))
        #expect(MobileRoadCrossingsSection.rows(refused) == [.open(.replaceAllKeys)])
        for faces in [U2Faces.castleSynced(), refused] {
            let store = U2Faces.Defaults()
            let standing = await U2Faces.standing(
                store, heard: U2Faces.Heard(), presenter: ProtectionSheetPresenter(), crossings: faces)
            await withHostedSurface(U2Faces.Screen(standing: standing)) { surface in
                await surface.settle(30)
                let labels = surface.visibleLabels
                #expect(labels.contains(ProtectionWords.postureLine(.castle)), "labels were \(labels)")
                #expect(labels.contains(ProtectionWords.replaceAllKeysDoor), "Replace All Keys… stands")
                #expect(!labels.contains(ProtectionWords.useStandardDoor), "Use Standard… never renders on the phone")
                #expect(!labels.contains("A refusal for Use Standard."), "nor its refusal")
                #expect(!labels.contains(ProtectionWords.leaveSentence), "her rule-12 sentence is never said here")
                #expect(!labels.contains(ProtectionWords.exportTurnedOffNotice), "no export-off notice on the phone")
            }
        }
    }

    /// THE GATE-STYLE ROW (Castle): with Always ask, *Use Face ID…* asks the passphrase before Face ID comes on; with Face
    /// ID, *Use Always ask* acts at once.
    @Test func theGateRowAsksThePassphraseBeforeFaceID() async throws {
        let store = U2Faces.Defaults()
        let heard = U2Faces.Heard()
        let standing = await U2Faces.standing(
            store, heard: heard, presenter: ProtectionSheetPresenter(), crossings: U2Faces.castleSynced(gate: .alwaysAsk))
        await withHostedSurface(U2Faces.Screen(standing: standing)) { surface in
            await surface.settle(30)
            var labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.gateRowAlwaysAsk), "labels were \(labels)")
            #expect(surface.activate(ProtectionWords.gateRowUseTouchID), "Use Face ID… stands")
            await surface.settle(30)
            labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.crossingPassphraseField), "the passphrase first — labels were \(labels)")
            #expect(labels.contains(ProtectionWords.gateRowTouchIDButton))
            #expect(heard.gates.isEmpty, "nothing changes before the passphrase")
        }
        let faceID = await U2Faces.standing(
            store, heard: heard, presenter: ProtectionSheetPresenter(), crossings: U2Faces.castleSynced(gate: .touchID))
        await withHostedSurface(U2Faces.Screen(standing: faceID)) { surface in
            await surface.settle(30)
            #expect(surface.visibleLabels.contains(ProtectionWords.gateRowTouchID))
            #expect(surface.activate(ProtectionWords.gateRowUseAlwaysAsk))
            await surface.settle(30)
            #expect(heard.gates.count == 1 && heard.gates.first?.0 == .alwaysAsk && heard.gates.first?.1 == nil,
                    "Always ask at once, nothing typed")
        }
    }

    /// USE CASTLE WHILE SIGNED OUT is Use Castle's own door: pressed, the signed-out screen's sentences with *Continue*;
    /// *Continue* runs the leave and hands the floor to Use Castle's confirm.
    @Test func theSignedOutRoadIsUseCastlesOwnDoor() async throws {
        let store = U2Faces.Defaults()
        let heard = U2Faces.Heard()
        let presenter = ProtectionSheetPresenter()
        let signedOut = RoadCrossingFaces(
            mode: .standard, useCastle: .signedOutRoad, useStandard: .hidden, replaceAllKeys: .hidden, gateRow: nil)
        let standing = await U2Faces.standing(
            store, heard: heard, presenter: presenter, crossings: signedOut,
            crossingsAfterLeave: U2Faces.standardLocal())
        await withHostedSurface(U2Faces.Screen(standing: standing)) { surface in
            await surface.settle(30)
            #expect(surface.activate(ProtectionWords.useCastleDoor))
            await surface.settle(40)
            let labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.signedOutCastleLead), "labels were \(labels)")
            #expect(labels.contains(ProtectionWords.signedOutCastleWholeAccount))
            guard case .signedOutCastle(let screen)? = presenter.sheet else {
                Issue.record("the signed-out screen stands on the presenter")
                return
            }
            await screen.proceed()
            await surface.settle(40)
            #expect(heard.leaves == 1, "Continue ran the leave")
            guard case .crossing(let confirm)? = presenter.sheet else {
                Issue.record("Use Castle's own confirm took the floor")
                return
            }
            #expect(confirm.door.door == .useCastle && confirm.receiptNote == ProtectionWords.bornCastleNote)
        }
    }

    /// F-U2-A, THE FACT (a guard — green on both sides): the phone schedules no plain-text export — no phone source names
    /// the weekly copy (`MarkdownInsurance`) or the backup run it rides (`StoreBackup`, `ExportWriter`), and the phone
    /// composes its services with the backup run off — so rule 11's notice can never stand there.
    @Test func thePhoneSchedulesNoExport() throws {
        let phone = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("VariorumMobile", isDirectory: true)
        let walk = try #require(FileManager.default.enumerator(at: phone, includingPropertiesForKeys: nil))
        var named: [String] = []
        var walked = 0
        for case let url as URL in walk where url.pathExtension == "swift" {
            walked += 1
            // The CODE (comments dropped — a comment may narrate the Mac's road).
            let code = try String(contentsOf: url, encoding: .utf8)
                .split(separator: "\n", omittingEmptySubsequences: false)
                .map { line in line.range(of: "//").map { String(line[..<$0.lowerBound]) } ?? String(line) }
                .joined(separator: "\n")
            for name in ["MarkdownInsurance", "StoreBackup(", "ExportWriter"] where code.contains(name) {
                named.append("\(url.lastPathComponent): \(name)")
            }
        }
        #expect(walked > 40)
        #expect(named.isEmpty, "the phone names the scheduled export's machinery: \(named)")
        let root = try MobileProtectionCompositionTests.code("VariorumMobile/VariorumMobileApp.swift")
        #expect(root.contains("backupEnabled: false"))
    }
}

// MARK: - The passphrase, the key doors, the words

@Suite("VM-8 unit 2 — the phone's passphrase, key doors and twelve words (mounted)")
@MainActor
struct MobileProtectionPassphraseTests {
    /// *SET A PASSPHRASE…* while none exists: the shared setter — VX-211's quiet hint beneath the field as she types, the
    /// 12-character floor its only refusal (said, nothing set). RED on the pre-unit-2 tree: the phone had no setter.
    @Test func theSetterSaysTheHintAndRefusesUnderTheFloor() async throws {
        let store = U2Faces.Defaults()
        let heard = U2Faces.Heard()
        let standing = await U2Faces.standing(
            store, heard: heard, presenter: ProtectionSheetPresenter(), passphraseExists: false,
            keyDoors: U2Faces.keyDoors(change: .hidden, reset: .hidden))
        #expect(standing.offersSetPassphrase)
        try await withHostedSurface(U2Faces.Screen(standing: standing)) { surface in
            await surface.settle(30)
            #expect(surface.activate(ProtectionWords.reminderSetDoor), "labels were \(surface.visibleLabels)")
            await surface.settle(40)
            var labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.setPassphraseLead), "the setter's sheet — labels were \(labels)")
            #expect(U2Faces.type("short", into: ProtectionWords.setPassphraseField, on: surface), "the field takes typing")
            #expect(U2Faces.type("short", into: ProtectionWords.setPassphraseAgain, on: surface))
            await surface.settle(30)
            labels = surface.visibleLabels
            let hint = try #require(NewPassphraseRule.hint("short"))
            #expect(labels.contains(hint), "VX-211's hint beneath the field — labels were \(labels)")
            #expect(surface.activate(ProtectionWords.setPassphraseButton))
            await surface.settle(30)
            #expect(surface.visibleLabels.contains(ProtectionCopy.passphraseTooShort), "the floor, said")
            #expect(heard.sets.isEmpty, "nothing set under the floor")
        }
    }

    /// **W-U2-1 — BUG-CLASS (found on the walk, D08), RED ON THE PRE-FIX TREE:** *Set a passphrase…* landed, the set row
    /// retired — and the passphrase's doors (Change, Reset) did not appear until the screen was entered again: nothing
    /// re-read the key doors after the set. The sheet's close re-reads the screen's sections (the pane's one read).
    @Test func aPassphraseSetReReadsThePassphrasesDoors() async throws {
        let store = U2Faces.Defaults()
        let heard = U2Faces.Heard()
        let standing = await U2Faces.standing(
            store, heard: heard, presenter: ProtectionSheetPresenter(), passphraseExists: false,
            keyDoors: U2Faces.keyDoors(change: .hidden, reset: .hidden))
        await withHostedSurface(U2Faces.Screen(standing: standing)) { surface in
            await surface.settle(30)
            #expect(surface.activate(ProtectionWords.reminderSetDoor))
            await surface.settle(40)
            #expect(U2Faces.type("walk lantern harbor seven", into: ProtectionWords.setPassphraseField, on: surface))
            #expect(U2Faces.type("walk lantern harbor seven", into: ProtectionWords.setPassphraseAgain, on: surface))
            await surface.settle(20)
            let before = heard.keyDoorReads
            #expect(surface.activate(ProtectionWords.setPassphraseButton))
            await surface.settle(40)
            #expect(heard.sets == ["walk lantern harbor seven"], "the passphrase set")
            #expect(heard.keyDoorReads > before, "the key doors read again after the set — Change and Reset can stand")
        }
    }

    /// **F-U2-C — BUG-CLASS, RED ON THE PRE-FIX TREE:** unit 1's account confirm (Turn on sync's set-up — a NEW
    /// passphrase typed twice where none exists) said NO strength hint under its new passphrase; every new-road setter adds
    /// VX-211's quiet hint.
    @Test func theAccountConfirmsNewPassphraseSaysTheHint() async throws {
        let spec = DoorSpec(
            requires: .passphraseAndWords(wordsMayBeNew: false), synced: true, join: .setsUpInLibrarysMode)
        let setUp = RoadAccountDoorOpen(
            door: .turnOnSync, ask: .passphraseAndWords, newPassphrase: true,
            sentences: [ProtectionWords.turnOnSyncLead], spec: spec)
        let confirm = RoadAccountConfirmModel(door: setUp, act: { _ in .refused("nothing") }, finished: { _ in })
        try await withHostedSurface(MobileRoadAccountConfirmSheet(model: confirm, tokens: U2Faces.tokens)) { surface in
            await surface.settle(30)
            #expect(U2Faces.type("aaaaaaaaaaaaaaaa", into: ProtectionWords.crossingNewPassphraseField, on: surface),
                    "labels were \(surface.visibleLabels)")
            await surface.settle(30)
            let hint = try #require(NewPassphraseRule.hint("aaaaaaaaaaaaaaaa"), "a repetitive passphrase earns a hint")
            #expect(surface.visibleLabels.contains(hint), "VX-211's hint — labels were \(surface.visibleLabels)")
        }
    }

    /// THE KEY DOORS: Change passphrase… asks the current one and a new one twice (VX-211's hint beneath), VX-263's line
    /// first; Reset forgotten passphrase… in Castle asks the twelve words, or offers *Reset with Face ID* where this iPhone
    /// has its item.
    @Test func theKeyDoorsSayTheirLineAndAskExactlyTheirFields() async throws {
        let store = U2Faces.Defaults()
        let presenter = ProtectionSheetPresenter()
        let castleReset = U2Faces.keyDoorOpen(
            .resetForgottenPassphrase, reset: .wordsOrTouchID(touchID: true),
            sentences: [ProtectionWords.keyDoorsLine, ProtectionWords.resetPassphraseCastleTouchIDLead])
        let standing = await U2Faces.standing(
            store, heard: U2Faces.Heard(), presenter: presenter,
            keyDoors: U2Faces.keyDoors(reset: .open(castleReset)))
        await withHostedSurface(U2Faces.Screen(standing: standing)) { surface in
            await surface.settle(30)
            #expect(surface.activate(ProtectionWords.changePassphraseDoor), "labels were \(surface.visibleLabels)")
            await surface.settle(40)
            var labels = surface.visibleLabels
            for label in [ProtectionWords.keyDoorsLine, ProtectionWords.changePassphraseCurrentField,
                          ProtectionWords.keyDoorNewPassphraseField, ProtectionWords.keyDoorNewPassphraseAgain,
                          ProtectionWords.changePassphraseButton] {
                #expect(labels.contains(label), "\(label) — labels were \(labels)")
            }
            #expect(!labels.contains(ProtectionWords.resetPassphraseWordsField), "Change asks no words")
            guard case .keyDoor(let change)? = presenter.sheet else {
                Issue.record("Change's confirm stands")
                return
            }
            change.cancel()
            await surface.settle(30)
            #expect(surface.activate(ProtectionWords.resetPassphraseDoor))
            await surface.settle(40)
            labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.resetPassphraseCastleTouchIDLead), "labels were \(labels)")
            #expect(labels.contains(ProtectionWords.resetPassphraseWordsField), "Castle's forgot road: the words")
            #expect(labels.contains(ProtectionWords.resetPassphraseWithTouchID), "or Face ID, where its item stands")
            #expect(ProtectionWords.resetPassphraseWithTouchID == "Reset with Face ID")
            #expect(!labels.contains(ProtectionWords.changePassphraseCurrentField), "Reset asks no current passphrase")
        }
    }

    /// **F-U2-D (PROVISIONAL P-VM8-9, now (a-unified) — ladder round 1's MINOR-1) — VX-542's repetition NOT copied:**
    /// while the account's PAIR changed elsewhere every key door is locked by the follow, and the crossings and *Stop
    /// syncing here* with it; the phone says the pair sentence ONCE — the follow door's notice, beside its door — and the
    /// follow-owed refusal ONCE for the whole screen, in that place (never a copy of the pair sentence per door, never the
    /// key doors' own road beside the generic sentence: "the per-section short pointer collapses to the one saying"). RED by
    /// its unit-2 revert (the pair-gate arms removed: the pair sentence said three times) and on the pre-L1 tree (the generic
    /// sentence said twice — the crossings and the leave — and the road once more).
    @Test func aPairGateSaysThePairSentenceOnce() async throws {
        let kind = FollowKind.pairChanged(passphrase: true, words: false)
        let gate = ProtectionWords.followFirstToCatchUp(kind, device: "Studio Mac", day: "January 13")
        let pairSentence = ProtectionWords.followNotice(kind, device: "Studio Mac", day: "January 13")
        #expect(gate.hasPrefix(pairSentence), "precondition: the gate's sentence opens with the pair sentence")
        let spec = DoorSpec(requires: .oneSecret, synced: true)
        var follow = RoadAccountFaces.followDoor(kind, spec, vault: nil, exportOn: false, gate: U2Faces.faceID)
        follow.notice = pairSentence
        let store = U2Faces.Defaults()
        let standing = await U2Faces.standing(
            store, heard: U2Faces.Heard(), presenter: ProtectionSheetPresenter(),
            crossings: U2Faces.followLockedCrossings(.standard),
            keyDoors: U2Faces.keyDoors(change: .refused(gate), newWords: .refused(gate), reset: .refused(gate), pairGate: true),
            account: U2Faces.followLockedAccount(follow: .open(follow)))
        await withHostedSurface(U2Faces.Screen(standing: standing)) { surface in
            await surface.settle(30)
            let labels = surface.visibleLabels
            let saysThePair = labels.filter { $0.contains(pairSentence) }
            #expect(saysThePair.count == 1, "the pair sentence once — it was said \(saysThePair.count) times: \(labels)")
            #expect(labels.contains(pairSentence), "…as the follow door's notice")
            #expect(labels.contains(ProtectionWords.followDoor), "the follow door beside it")
            let generic = U2Faces.count(ProtectionWords.doorRefusedFollowOwed, in: labels)
            #expect(generic == 1, "the follow-owed refusal once on the screen — it was said \(generic) times: \(labels)")
            #expect(!labels.contains(ProtectionWords.followFirstToCatchUpRoad),
                    "the key doors' own road collapses into the one saying — labels were \(labels)")
            U2Faces.expectTheOneSayingBesideTheFollow(labels, notice: pairSentence)
            #expect(!labels.contains(ProtectionWords.changePassphraseDoor)
                    && !labels.contains(ProtectionWords.resetPassphraseDoor)
                    && !labels.contains(ProtectionWords.wordsSectionDoor), "no locked door renders as a door")
        }
    }

    /// NEW WORDS THROUGH THE LOOK: the door; pressed, the passphrase asked (rule 6); typed, the words shown once with the
    /// close behind her warning — and NO Copy door (the phone has no words clipboard road — P-2). A synced library's look
    /// says first that new words replace the account's (F-U2-3). RED on the pre-unit-2 tree: no words section.
    @Test func newWordsAsksThePassphraseThenShowsTheWordsOnce() async throws {
        let store = U2Faces.Defaults()
        let heard = U2Faces.Heard()
        let standing = await U2Faces.standing(
            store, heard: heard, presenter: ProtectionSheetPresenter(), keyDoors: U2Faces.keyDoors(),
            replacesAccountWords: true)
        await withHostedSurface(U2Faces.Screen(standing: standing)) { surface in
            await surface.settle(30)
            #expect(surface.activate(ProtectionWords.wordsSectionDoor), "labels were \(surface.visibleLabels)")
            await surface.settle(30)
            var labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.wordsLookReplacesAccountWords), "synced: said first — \(labels)")
            #expect(labels.contains(ProtectionWords.wordsLookAsk), "the passphrase asked")
            #expect(heard.mints.isEmpty, "nothing minted before the ask is answered")
            #expect(U2Faces.type("the library's passphrase", into: ProtectionWords.wordsLookPassphraseField, on: surface))
            await surface.settle(20)
            #expect(surface.activate(ProtectionWords.wordsLookShow))
            await surface.settle(40)
            labels = surface.visibleLabels
            #expect(heard.mints == ["the library's passphrase"], "minted with the typed passphrase (untrimmed)")
            #expect(labels.contains(ProtectionWords.wordsLookLead) && labels.contains("word1") && labels.contains("word12"),
                    "the words, once — labels were \(labels)")
            #expect(labels.contains(ProtectionWords.wordsLookWrittenDown))
            #expect(!labels.contains(ProtectionWords.wordsLookCopy), "no Copy door on the phone")
        }
    }
}

// MARK: - The owed follow, said once (ladder round 1's MINOR-1 — PROVISIONAL P-VM8-9 (a-unified))

@Suite("VM-8 ladder L1 — the owed follow's refusal, once per screen (mounted)")
@MainActor
struct MobileProtectionFollowOwedOnceTests {
    static let vault = VaultReading(accountID: "acct", mode: .castle, rowKeyID: "k", updatedByDevice: "Studio Mac")

    /// **MINOR-1, THE GENERIC KIND (a key replacement elsewhere — the follow door renders):** every door the follow locks
    /// (Change, Reset, New words, Use Castle, Replace All Keys, *Stop syncing here*) renders nothing, and the screen says the
    /// follow-owed refusal ONCE — in the follow's place, between its notice and its door; a door the follow does not lock
    /// keeps its row (*Delete the account from this iPhone…*). RED on the pre-L1 tree: said 4 times (the passphrase, the
    /// words, the crossings and the Sync section — round 1's probe).
    @Test func anOwedFollowSaysItsRefusalOncePerScreen() async throws {
        let follow = RoadAccountFaces.followDoor(
            .keysReplaced, DoorSpec(requires: .oneSecret, rekeys: true, synced: true), vault: Self.vault, exportOn: false,
            gate: U2Faces.faceID)
        let notice = try #require(follow.notice)
        let store = U2Faces.Defaults()
        let standing = await U2Faces.standing(
            store, heard: U2Faces.Heard(), presenter: ProtectionSheetPresenter(),
            crossings: U2Faces.followLockedCrossings(.castle), keyDoors: U2Faces.followLockedKeyDoors(),
            account: U2Faces.followLockedAccount(follow: .open(follow)))
        await withHostedSurface(U2Faces.Screen(standing: standing)) { surface in
            await surface.settle(30)
            let labels = surface.visibleLabels
            let said = U2Faces.count(ProtectionWords.doorRefusedFollowOwed, in: labels)
            #expect(said == 1, "the follow-owed refusal once on the screen — it was said \(said) times: \(labels)")
            #expect(U2Faces.count(notice, in: labels) == 1, "the follow door's notice, once")
            U2Faces.expectTheOneSayingBesideTheFollow(labels, notice: notice)
            for locked in [ProtectionWords.changePassphraseDoor, ProtectionWords.resetPassphraseDoor,
                           ProtectionWords.wordsSectionDoor, ProtectionWords.useCastleDoor,
                           ProtectionWords.replaceAllKeysDoor, ProtectionWords.stopSyncingHereDoor] {
                #expect(!labels.contains(locked), "\(locked) is locked by the follow — not rendered")
            }
            #expect(labels.contains(ProtectionWords.deleteAccountHereDoor), "a door the follow doesn't lock keeps its row")
            #expect(labels.contains(ProtectionWords.postureLine(.castle)), "the sections keep their own lines")
            // R2-MINOR-1 (the ladder's round 2): a section whose EVERY door the follow locks renders NOTHING —
            // heading and lead included, never a "Your twelve words" lead over a doorless hole (the one saying
            // lives in the follow's place, P-VM8-9 (a-unified)).
            #expect(!labels.contains(ProtectionWords.wordsSectionLine),
                    "a fully follow-locked words section renders nothing — its lead included")
            #expect(!labels.contains(ProtectionWords.wordsSectionTitle),
                    "…and its heading")
        }
    }

    /// **MINOR-1, P-VM8-10's DEAD END (the follow OUT of Castle, held for her phone wording — F-PH-2):** the follow door
    /// and its notice render nothing (F-U1-1 (A)), yet the state keeps its ONE truth-teller: the follow-owed refusal is
    /// said exactly once, in the follow's place — never four times, never zero. And when the account section has no faces
    /// yet, the screen still says it once, at the section's place (the belt). RED on the pre-L1 tree: 4 times, then 3.
    @Test func theHeldFollowOutStillSaysItOnce() async throws {
        let out = RoadAccountFaces.followDoor(
            .intoStandard, DoorSpec(requires: .none, rekeys: true, synced: true, words: [.ruleFive]), vault: Self.vault,
            exportOn: false, gate: U2Faces.faceID)
        #expect(out.saysRuleTwelve, "precondition: the follow out says her rule-12 sentence")
        let heldNotice = try #require(out.notice)
        let store = U2Faces.Defaults()
        let standing = await U2Faces.standing(
            store, heard: U2Faces.Heard(), presenter: ProtectionSheetPresenter(),
            crossings: U2Faces.followLockedCrossings(.castle), keyDoors: U2Faces.followLockedKeyDoors(),
            account: U2Faces.followLockedAccount(follow: .open(out)))
        await withHostedSurface(U2Faces.Screen(standing: standing)) { surface in
            await surface.settle(30)
            let labels = surface.visibleLabels
            let said = U2Faces.count(ProtectionWords.doorRefusedFollowOwed, in: labels)
            #expect(said >= 1, "the dead end keeps its truth-teller — labels were \(labels)")
            #expect(said == 1, "…said once — it was said \(said) times: \(labels)")
            #expect(!labels.contains(ProtectionWords.followDoor), "the held follow out renders no door (F-U1-1 (A))")
            #expect(!labels.contains(ProtectionWords.leaveSentence), "her rule-12 sentence is never said here")
            #expect(!labels.contains(heldNotice), "nor the held arm's notice")
            let situation = labels.firstIndex(of: ProtectionWords.accountInSync)
            let saying = labels.firstIndex(of: ProtectionWords.doorRefusedFollowOwed)
            if let situation, let saying {
                #expect(situation < saying, "said in the Sync section, the follow's place — labels were \(labels)")
            }
        }
        // The belt: key doors and crossings locked, the account section not read yet.
        let unread = await U2Faces.standing(
            store, heard: U2Faces.Heard(), presenter: ProtectionSheetPresenter(),
            crossings: U2Faces.followLockedCrossings(.castle), keyDoors: U2Faces.followLockedKeyDoors())
        await withHostedSurface(U2Faces.Screen(standing: unread)) { surface in
            await surface.settle(30)
            let labels = surface.visibleLabels
            let said = U2Faces.count(ProtectionWords.doorRefusedFollowOwed, in: labels)
            #expect(said == 1, "once even before the account section reads — it was said \(said) times: \(labels)")
        }
    }

    /// The sections' pure readings: a door the follow locks contributes NO row (the one saying is the screen's); a door
    /// refused for any other reason keeps its row, identical refusals once per section as before (P-VM8-9's rule). RED on
    /// the pre-L1 tree for the follow-locked half (each section said the refusal itself).
    @Test func aLockedDoorKeepsItsRowUnlessTheFollowLocksIt() {
        #expect(MobilePassphraseSection.rows(U2Faces.followLockedKeyDoors()).isEmpty, "the follow's lock: no row")
        #expect(MobileRoadCrossingsSection.rows(U2Faces.followLockedCrossings(.castle)).isEmpty)
        #expect(MobileRoadCrossingsSection.rows(U2Faces.followLockedCrossings(.standard)).isEmpty)
        let pair = ProtectionWords.followFirstToCatchUp(
            .pairChanged(passphrase: true, words: false), device: "Studio Mac", day: nil)
        #expect(MobilePassphraseSection.rows(U2Faces.keyDoors(
            change: .refused(pair), newWords: .refused(pair), reset: .refused(pair), pairGate: true)).isEmpty,
            "the pair gate: no row either")
        // Another reason keeps its row (a guard — green on both sides).
        let vault = ProtectionWords.doorRefusedNeedsVault
        #expect(MobilePassphraseSection.rows(U2Faces.keyDoors(change: .refused(vault), reset: .refused(vault)))
                == [.refused(vault)])
        let unreachable = RoadCrossingFaces(
            mode: .castle, useCastle: .hidden, useStandard: .hidden, replaceAllKeys: .refused(vault),
            gateRow: RoadGateRow(current: .alwaysAsk, touchIDAvailable: true))
        #expect(MobileRoadCrossingsSection.rows(unreachable) == [.refused(vault)])
    }
}

// MARK: - The check (VX-513)

@Suite("VM-8 unit 2 — the phone's check door (mounted; it writes nothing)")
@MainActor
struct MobileProtectionCheckTests {
    /// THE CHECK: its door beside the key doors; pressed, one concealed field; checked, the answer in the check's own
    /// sentences — here the fourth answer in the catch-up's state with its pointer, naming the iPhone; typing again clears
    /// what was said. The road is read once with exactly what was typed. RED on the pre-unit-2 tree: no door.
    @Test func theCheckReadsOneSecretAndSaysTheAnswer() async throws {
        let store = U2Faces.Defaults()
        let heard = U2Faces.Heard()
        let presenter = ProtectionSheetPresenter()
        let answer = SecretCheckOutcome.doesNotOpen(.passphrase, opensAccount: true, because: .catchUpOwed)
        let standing = await U2Faces.standing(
            store, heard: heard, presenter: presenter, keyDoors: U2Faces.keyDoors(), check: answer)
        await withHostedSurface(U2Faces.Screen(standing: standing)) { surface in
            await surface.settle(30)
            #expect(surface.activate(ProtectionWords.checkSecretsDoor), "labels were \(surface.visibleLabels)")
            await surface.settle(40)
            var labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.checkSecretsLead), "labels were \(labels)")
            #expect(labels.contains(ProtectionWords.checkSecretsField))
            #expect(U2Faces.type(" an account passphrase ", into: ProtectionWords.checkSecretsField, on: surface))
            await surface.settle(20)
            #expect(surface.activate(ProtectionWords.checkSecretsButton))
            await surface.settle(40)
            labels = surface.visibleLabels
            #expect(heard.checks == [" an account passphrase "], "read once, untrimmed")
            #expect(labels.contains(ProtectionWords.checkSecretsOpensAccountNotLibrary(.passphrase)), "labels were \(labels)")
            #expect(labels.contains("You can catch this iPhone up in Settings \u{25B8} Protection."), "the pointer, the phone's")
            #expect(U2Faces.type("x", into: ProtectionWords.checkSecretsField, on: surface))
            await surface.settle(30)
            #expect(!surface.visibleLabels.contains(ProtectionWords.checkSecretsCatchUpPointer), "typing again clears it")
            guard case .checkSecrets(let sheet)? = presenter.sheet else {
                Issue.record("the check's sheet stands")
                return
            }
            sheet.close()
            await surface.settle(20)
            #expect(presenter.sheet == nil, "Close always closes — nothing to cancel")
        }
    }

    /// No live key file of the open key: no door (P-2 — nothing to check the library against).
    @Test func noKeyFileNoCheckDoor() async throws {
        let store = U2Faces.Defaults()
        let standing = await U2Faces.standing(
            store, heard: U2Faces.Heard(), presenter: ProtectionSheetPresenter(),
            keyDoors: U2Faces.keyDoors(checkStands: false), check: .refused("never"))
        await withHostedSurface(U2Faces.Screen(standing: standing)) { surface in
            await surface.settle(30)
            #expect(!surface.visibleLabels.contains(ProtectionWords.checkSecretsDoor))
        }
    }
}

// MARK: - The follow and THE PAIR (F-U2-B — unit 1's section renders the shared faces; pinned on the phone)

@Suite("VM-8 unit 2 — the follow and the pair catch-up on the phone (mounted)")
@MainActor
struct MobileProtectionFollowTests {
    static func section(_ faces: RoadAccountFaces, done: FollowDoneNotice? = nil) async -> RoadAccountModel {
        let model = RoadAccountModel(roads: RoadAccountRoads(
            read: { faces }, press: { _ in .refused("nothing") }, followDoneNoticeOwed: { done }))
        await model.refresh()
        return model
    }

    struct Section: View {
        let model: RoadAccountModel
        var body: some View {
            ScrollView { MobileRoadAccountSection(model: model, tokens: U2Faces.tokens) }
                .modifier(MobileProtectionSheetsHost(presenter: model.presenter, services: nil, tokens: U2Faces.tokens))
        }
    }

    /// THE PAIR FOLLOW (the passphrase moved): its notice names the half, the device and the day beside its door; its
    /// confirm takes EITHER of the account's current secrets (R-529-5) and says the second road (P-VX529-2).
    @Test func thePairFollowNamesTheChangeAndTakesEitherSecret() async throws {
        let kind = FollowKind.pairChanged(passphrase: true, words: false)
        let vault = VaultReading(accountID: "acct", mode: .castle, rowKeyID: "k", updatedByDevice: "Studio Mac")
        let follow = RoadAccountFaces.followDoor(
            kind, DoorSpec(requires: .oneSecret, synced: true), vault: vault, exportOn: false, gate: U2Faces.faceID)
        let model = await Self.section(U2Faces.account(follow: .open(follow)))
        await withHostedSurface(Section(model: model)) { surface in
            await surface.settle(30)
            var labels = surface.visibleLabels
            let notice = ProtectionWords.followNotice(kind, device: "Studio Mac", day: nil)
            #expect(labels.contains(notice), "the pair's notice — labels were \(labels)")
            #expect(surface.activate(ProtectionWords.followDoor))
            await surface.settle(40)
            labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.followAsk(kind)), "either current secret — labels were \(labels)")
            #expect(labels.contains(ProtectionWords.pairSecondRoad), "the second road, beside it")
            #expect(labels.contains(ProtectionWords.followPassphraseField) && labels.contains(ProtectionWords.followWordsField))
            #expect(!labels.contains(ProtectionWords.gateHeading), "a pair follow re-locks — no gate choice")
        }
    }

    /// THE QUIET WORDS-ONLY CATCH-UP (R-529-2): one press, nothing typed — said in the phone's words.
    @Test func theWordsOnlyCatchUpTypesNothing() async throws {
        let kind = FollowKind.pairChanged(passphrase: false, words: true)
        let follow = RoadAccountFaces.followDoor(
            kind, DoorSpec(requires: .none, synced: true), vault: nil, exportOn: false, gate: U2Faces.faceID)
        let model = await Self.section(U2Faces.account(follow: .open(follow)))
        await withHostedSurface(Section(model: model)) { surface in
            await surface.settle(30)
            #expect(surface.activate(ProtectionWords.followDoor))
            await surface.settle(40)
            let labels = surface.visibleLabels
            #expect(labels.contains("This iPhone catches up without asking you for anything."), "labels were \(labels)")
            #expect(!labels.contains(ProtectionWords.followPassphraseField) && !labels.contains(ProtectionWords.followWordsField))
        }
    }

    /// R-529-5's WORDS ARM: the catch-up landed by the twelve words — the sheet says the window plainly and the Reset chain
    /// beside its round.
    @Test func theWordsArmSaysItsWindowAndTheResetChain() async throws {
        let kind = FollowKind.pairChanged(passphrase: true, words: false)
        let follow = RoadAccountFaces.followDoor(
            kind, DoorSpec(requires: .oneSecret, synced: true), vault: nil, exportOn: false, gate: U2Faces.faceID)
        let confirm = RoadAccountConfirmModel(
            door: follow, act: { _ in .made(receipt: nil) },
            firstRound: {
                var status = SyncScheduler.Status()
                status.lastSuccessAt = Date()
                return .ran(status)
            },
            finished: { _ in })
        let words = try RecoveryPhrase.generate()
        await confirm.submit(words: words.joined(separator: " "))
        _ = await confirm.awaitFirstRound()
        #expect(confirm.landedLines == [ProtectionWords.pairWordsWindow, ProtectionWords.pairResetChain])
        await withHostedSurface(MobileRoadAccountConfirmSheet(model: confirm, tokens: U2Faces.tokens)) { surface in
            await surface.settle(30)
            let labels = surface.visibleLabels
            #expect(labels.contains("Until you type your account's passphrase on this iPhone, copies made here open with your "
                + "twelve words."), "the window, the phone's — labels were \(labels)")
            #expect(labels.contains(ProtectionWords.pairResetChain), "the Reset chain")
            #expect(labels.contains(ProtectionWords.firstRoundFollowLanded), "the round's line")
        }
    }

    /// VX-457 — THE DURABLE DONE: it stands with its OK while nothing is owed; while a follow IS owed the stale Done is not
    /// said (P-VX529-U2-2 — the shared rule; the phone renders what the model says).
    @Test func theDurableDoneStandsAndNeverBesideAnOwedFollow() async throws {
        let done = FollowDoneNotice.followed(.pairChanged(passphrase: true, words: false))
        let quiet = await Self.section(U2Faces.account(), done: done)
        await withHostedSurface(Section(model: quiet)) { surface in
            await surface.settle(30)
            let labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.followDoneNotice(done)), "labels were \(labels)")
            #expect(labels.contains(ProtectionWords.followDoneOK))
        }
        let owed = RoadAccountFaces.followDoor(
            .keysReplaced, DoorSpec(requires: .oneSecret, rekeys: true, synced: true), vault: nil, exportOn: false,
            gate: U2Faces.faceID)
        let following = await Self.section(U2Faces.account(follow: .open(owed)), done: done)
        await withHostedSurface(Section(model: following)) { surface in
            await surface.settle(30)
            let labels = surface.visibleLabels
            #expect(!labels.contains(ProtectionWords.followDoneNotice(done)), "no stale Done beside an owed follow")
            #expect(labels.contains(ProtectionWords.followDoor))
        }
    }
}

// MARK: - The receipts' home (F-U2-E, PROVISIONAL P-VM8-8)

@Suite("VM-8 unit 2 — the protection receipts' phone home")
@MainActor
struct MobileProtectionReceiptsTests {
    /// What the open library's faces SPEAK lands in the shell's holder — the receipts an open owes at once (rule 1's
    /// restore receipt, P-VX329-PH-1's device-neutral sentence) — and the screen shows it muted under its title (the
    /// newest three, one line each); leaving the screen clears it. RED on the pre-unit-2 tree: the phone set no
    /// `speak` — nothing was said.
    @Test func theScreenSaysWhatTheFacesSpoke() async throws {
        let store = U2Faces.Defaults()
        let reminder = PassphraseReminderModel(
            libraryID: "vm8-u2-library", moment: nil, ledger: PassphraseReminderLedger(defaults: store.defaults),
            facts: { (passphraseSet: true, dismissals: 0) }, recordDismissal: { true })
        var owed = [ProtectionWords.restoredFromMirror]
        let standing = RoadStandingModel(
            faces: .none, reminder: reminder, setPassphrase: { _ in .set }, passphraseExists: { true },
            receiptsOwed: {
                defer { owed = [] }
                return owed
            })
        let receipts = MobileProtectionReceipts()
        standing.speak = { text in receipts.say(text) }
        #expect(receipts.lines == ["The key file beside your library was missing. This iPhone's sealed copy was put back."],
                "the open's owed receipt, spoken at once, in the phone's words")
        standing.speak?(ProtectionWords.changePassphraseReceipt)
        await withHostedSurface(U2Faces.Screen(standing: standing, receipts: receipts)) { surface in
            await surface.settle(30)
            let labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.restoredFromMirror), "labels were \(labels)")
            #expect(labels.contains(ProtectionWords.changePassphraseReceipt))
        }
        receipts.screenLeft()
        #expect(receipts.lines.isEmpty, "leaving the screen clears what it showed")
        for index in 0..<5 { receipts.say("receipt \(index)") }
        #expect(receipts.lines == ["receipt 2", "receipt 3", "receipt 4"], "the newest few")
    }

    /// THE COMPOSITION (source): the shell hands the open library's faces its holder as their receipt door — on appear and
    /// at every new open's faces — and the Protection destination carries the holder.
    @Test func theShellHandsTheFacesItsHolder() throws {
        let shell = try MobileProtectionCompositionTests.code("VariorumMobile/Features/Shell/MobileShellView.swift")
        #expect(shell.contains("standing.speak = { text in receipts.say(text) }"))
        #expect(shell.contains(".onAppear { attachProtectionReceipts() }"))
        #expect(shell.contains(".onChange(of: bootstrap?.roadStanding.map { ObjectIdentifier($0) }) { _, _ in "
            + "attachProtectionReceipts() }"))
        #expect(shell.contains(".environment(protectionReceipts)"))
        let screen = try MobileProtectionCompositionTests.code(
            "VariorumMobile/Features/Protection/MobileProtectionScreen.swift")
        #expect(screen.contains(".onDisappear { receipts?.screenLeft() }"))
    }
}
