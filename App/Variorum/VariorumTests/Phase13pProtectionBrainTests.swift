//
//  Phase13pProtectionBrainTests.swift
//  VariorumTests
//
//  Phase 13p, Batch 2 (commit 2) — the protection brains. pre-13x batch
//  2a: the POSTURE is derived (never a setting), the effective gate is a
//  pure function of (posture, Castle's gate style), the dials are Castle's
//  two switches with the 13p-era keys read through until §11 retires
//  them, and the presets / the escrow dial / its coupling copy are gone
//  (§13). The reminder-check cadence (R13p-9), the Standard nudge's
//  two-offer eligibility (knot 4's amendment) and the guard backing's
//  scripted custody world stand.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("pre-13x 2a — the posture derivation, the effective gate & the dials")
struct ProtectionDialsTests {
    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    @Test func demandedIsEveryGateButAuto() {
        #expect(!StoreAtOpenMode.auto.isDemanded)
        #expect(StoreAtOpenMode.biometric.isDemanded)
        #expect(StoreAtOpenMode.passphrase.isDemanded)
    }

    /// THE DERIVATION, from BOTH sources (design §3.1's posture row; the
    /// brief's pin): the vault's word when enrolled; the key file's Apple
    /// copy when local-only. RED ON OLD by construction (`Posture` and the
    /// derivation do not exist on the pre-2a tree; the mode was stored).
    /// pre-13x 2d: the answer is a `PostureReading`; `enrolled` is required.
    @Test func postureDerivesFromTheVaultWhenEnrolledAndTheKeyFileWhenLocalOnly() throws {
        let key = StoreKey.mint()
        var castleFile = StoreKeyEnvelope()
        try castleFile.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        var standardFile = castleFile
        try standardFile.setAppleWrappedCopy(key: key, under: AppleKey.mint().symmetricKey, appleKeyID: "a-1")

        // Enrolled: the vault's word outranks the key file (decision 8).
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: true, keyFile: castleFile, enrolled: true) == .determined(.standard))
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: false, keyFile: standardFile, enrolled: true) == .determined(.castle))
        // Local-only: the key file's Apple copy.
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: standardFile, enrolled: false) == .determined(.standard))
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: castleFile, enrolled: false) == .determined(.castle))
        // No key file at all: born Standard (§14.26).
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: nil, enrolled: false) == .determined(.standard))
    }

    /// The safety arm: a key file with NO passphrase wrap and no Apple copy
    /// is a Standard library whose Apple copy has not landed — entering
    /// Castle requires a passphrase (decision 5), so such a library cannot
    /// have entered it; reading it as Castle would lock a fresh user behind
    /// a lobby with no road. pre-13x 2d: reached only with NO session and
    /// NO custody — the enrolled arm below catches her phone first.
    @Test func aKeyFileWithNoSecretsAndNoAppleCopyIsStandardNeverALock() throws {
        let key = StoreKey.mint()
        let stub = StoreKeyEnvelope(keyFingerprint: StoreKeyEnvelope.fingerprint(of: key))
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: stub, enrolled: false) == .determined(.standard))
        var wordsOnly = stub
        try wordsOnly.setRecoveryWrap(key: key, words: try RecoveryPhrase.generate())
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: wordsOnly, enrolled: false) == .determined(.standard))
    }

    /// DECISION 35 (pre-13x 2d — the window's finding): an ENROLLED library
    /// whose vault has not answered is INDETERMINATE, carrying the posture
    /// its custody SHAPE reads as — her phone's secret-less format-1 key
    /// file with the raw key in the silent item reads as an indeterminate
    /// Standard-shaped library, NEVER a determined Standard (the safety arm
    /// is for a library nobody is signed into); a gated shape carries
    /// Castle; an unreadable shape carries the key file's rule. The vault's
    /// word, once in hand, DETERMINES — and outranks the legacy mode: it
    /// is a fact about the gate the device had, already honored by the
    /// custody shape. RED ON OLD: arm 3's secret-less file read as a
    /// determined Standard whatever the session held (the window's phone),
    /// and the legacy Auto outranked a Castle vault.
    @Test func anEnrolledLibraryWhoseVaultHasNotAnsweredIsIndeterminateAndActsAsItsCustodyShape() throws {
        let key = StoreKey.mint()
        let secretless = StoreKeyEnvelope(formatVersion: StoreKeyEnvelope.formatVersion1, storeID: "phone-store")
        // Her phone at the window: enrolled (a session), no secrets, the silent item.
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: secretless,
                               rawKeyCustody: .silent, enrolled: true) == .indeterminate(shape: .standard))
        let reading = Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: secretless,
                                     rawKeyCustody: .silent, enrolled: true)
        #expect(reading.isIndeterminate && reading.determined == nil && reading.acting == .standard)
        #expect(StoreAtOpenMode.effective(reading: reading, dials: ProtectionDials()) == .auto,
                "the device opens through the custody it HAS")
        // The same library, not enrolled: the safety arm, a determined Standard.
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: secretless,
                               rawKeyCustody: .silent, enrolled: false) == .determined(.standard))
        // A gated shape carries Castle; an unreadable shape the key file's rule.
        var castleFile = StoreKeyEnvelope()
        try castleFile.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: castleFile,
                               rawKeyCustody: .gatedOrNone, enrolled: true) == .indeterminate(shape: .castle))
        #expect(StoreAtOpenMode.effective(
            reading: .indeterminate(shape: .castle), dials: ProtectionDials(alwaysAsk: true)) == .passphrase)
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: castleFile,
                               rawKeyCustody: .unknown, enrolled: true) == .indeterminate(shape: .castle))
        var standardFile = castleFile
        try standardFile.setAppleWrappedCopy(key: key, under: AppleKey.mint().symmetricKey, appleKeyID: "a-1")
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: standardFile,
                               rawKeyCustody: .unknown, enrolled: true) == .indeterminate(shape: .standard))
        // The legacy stored mode never overrides an enrolled library.
        #expect(Posture.derive(legacyMode: .auto, vaultHasAppleHeldCopy: nil, keyFile: castleFile,
                               rawKeyCustody: .gatedOrNone, enrolled: true) == .indeterminate(shape: .castle))
        #expect(Posture.derive(legacyMode: .biometric, vaultHasAppleHeldCopy: nil, keyFile: secretless,
                               rawKeyCustody: .silent, enrolled: true) == .indeterminate(shape: .standard))
        // The vault's word determines, and outranks the legacy mode.
        #expect(Posture.derive(legacyMode: .auto, vaultHasAppleHeldCopy: false, keyFile: secretless,
                               rawKeyCustody: .silent, enrolled: true) == .determined(.castle))
        #expect(Posture.derive(legacyMode: .passphrase, vaultHasAppleHeldCopy: true, keyFile: nil,
                               enrolled: true) == .determined(.standard))
    }

    /// CORNER 45 (pre-13x 2b item (0); the 2a adjudication's ruling 2): a
    /// refused Apple landing never makes Castle. A local-only key file with
    /// a passphrase wrap and NO `apple` copy is Castle only when the raw
    /// key's custody is the gated item or nowhere (Castle was ENTERED);
    /// with the raw key in the SILENT bound item it is Standard-waiting —
    /// the state a refused landing followed by a passphrase set leaves —
    /// never a lock. RED ON OLD: arm (c) read every such file as Castle.
    @Test func aRefusedAppleLandingNeverMakesCastle() throws {
        let key = StoreKey.mint()
        var waiting = StoreKeyEnvelope()
        try waiting.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: waiting,
                               rawKeyCustody: .silent, enrolled: false) == .determined(.standard),
                "the raw key in the silent item: Standard-waiting, whatever the wraps say")
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: waiting,
                               rawKeyCustody: .gatedOrNone, enrolled: false) == .determined(.castle),
                "the raw key behind Touch ID or nowhere: Castle was entered")
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: waiting,
                               rawKeyCustody: .unknown, enrolled: false) == .determined(.castle),
                "a caller that cannot read custody keeps the older reading")
        // The shape never overrides the vault (decision 8) or an Apple copy.
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: false, keyFile: waiting,
                               rawKeyCustody: .silent, enrolled: true) == .determined(.castle))
        var landed = waiting
        try landed.setAppleWrappedCopy(key: key, under: AppleKey.mint().symmetricKey, appleKeyID: "a")
        #expect(Posture.derive(legacyMode: nil, vaultHasAppleHeldCopy: nil, keyFile: landed,
                               rawKeyCustody: .gatedOrNone, enrolled: false) == .determined(.standard))
    }

    /// The pre-2a read-through (§11 retires it): the 13p-era stored mode
    /// decides for a library that is NOT enrolled until the migration runs
    /// — her Mac (Biometric) routes to its lobby. pre-13x 2d (decision 35):
    /// for an ENROLLED library the legacy mode never decides — see the
    /// decision-35 pin above; the two old expectations that let it outrank
    /// a vault word moved there with the opposite answer.
    @Test func theLegacyModeReadsThroughUntilTheMigrationRetiresIt() throws {
        let key = StoreKey.mint()
        var castleFile = StoreKeyEnvelope()
        try castleFile.setPassphraseWrap(key: key, passphrase: "sesame", kdf: fastKDF())
        #expect(Posture.derive(legacyMode: .auto, vaultHasAppleHeldCopy: nil, keyFile: castleFile, enrolled: false) == .determined(.standard),
                "a silent 13p-era local-only store opens silently until its migration retires the keys")
        #expect(Posture.derive(legacyMode: .biometric, vaultHasAppleHeldCopy: nil, keyFile: nil, enrolled: false) == .determined(.castle))
        #expect(Posture.derive(legacyMode: .passphrase, vaultHasAppleHeldCopy: nil, keyFile: castleFile, enrolled: false) == .determined(.castle))
    }

    /// THE EFFECTIVE GATE (the brief's fact i): Standard ⇒ silent; Castle
    /// ⇒ the device's style.
    @Test func theEffectiveGateIsAPureFunctionOfPostureAndStyle() {
        #expect(StoreAtOpenMode.effective(posture: .standard, dials: ProtectionDials()) == .auto)
        #expect(StoreAtOpenMode.effective(posture: .standard, dials: ProtectionDials(alwaysAsk: true)) == .auto,
                "Always ask is a Castle switch — Standard has no gate")
        #expect(StoreAtOpenMode.effective(posture: .castle, dials: ProtectionDials()) == .biometric)
        #expect(StoreAtOpenMode.effective(posture: .castle, dials: ProtectionDials(alwaysAsk: true)) == .passphrase)
    }

    /// The idle dial: default 10, offered 5 · 10 · 30 · never (decision 18).
    @Test func theIdleDialDefaultsToTenAndOffersTheFourValues() {
        #expect(ProtectionDials().relockAfterIdleMinutes == 10)
        #expect(ProtectionDials.idleChoices == [5, 10, 30, nil])
        #expect(ProtectionCopy.idleChoiceLabel(nil) == "never")
        #expect(ProtectionCopy.idleChoiceLabel(30) == "30 minutes")
    }

    @Test func defaultsRoundTripPerScopeAndStore() {
        let defaults = UserDefaults(suiteName: "variorum-2a-dials-\(UUID().uuidString)")!
        // The absent-key default IS the design's default (Touch ID, 10).
        #expect(ProtectionDefaults.dials(scope: "Variorum", in: defaults) == ProtectionDials())

        var dials = ProtectionDials(alwaysAsk: true, relockAfterIdleMinutes: 30)
        ProtectionDefaults.save(dials, scope: "Variorum", storeID: "store-a", in: defaults)
        #expect(ProtectionDefaults.dials(scope: "Variorum", storeID: "store-a", in: defaults) == dials)
        // Scoped: the dev store's dials never gate her real library.
        #expect(ProtectionDefaults.dials(scope: "Variorum-dev", storeID: "store-a", in: defaults) == ProtectionDials())

        // "never" round-trips as the stored 0 (the 13p encoding, kept).
        dials.relockAfterIdleMinutes = nil
        ProtectionDefaults.save(dials, scope: "Variorum", storeID: "store-a", in: defaults)
        #expect(ProtectionDefaults.dials(scope: "Variorum", storeID: "store-a", in: defaults)
            .relockAfterIdleMinutes == nil)
    }
}

@Suite("13p — the ruled copy (the honesty grammar)")
struct ProtectionCopyTests {
    /// pre-13x 2c: copy §5's follow notices render VERBATIM with the device
    /// nouns interpolated and *[device] on [day]* from the vault's row.
    /// pre-13x 3a — copy §2d's Castle join face + the (d) consent
    /// (PROVISIONAL, ledger 46), verbatim; the device noun interpolated.
    @Test func theEnrollFacesRenderCopyTwoDVerbatim() {
        #expect(ProtectionCopy.joinCastleTitle == "Enter your passphrase to join sync.")
        #expect(ProtectionCopy.joinWordsDoor == "Use my twelve words instead.")
        #expect(ProtectionCopy.joinCastleRekeysSentence
                == "This account is in Castle, so this library gets a new key as it joins. Everything you wrote here stays.")
        // RUN A batch A2, row 10 — RE-BASED to HER RULING on QUESTIONS #90
        // (4), ledger 46 (the ruled-change class, not a defect): the consent
        // now DIRECTS — cancel · put the ACCOUNT in Castle · rejoin.
        #expect(ProtectionCopy.joinStandardConsent
                == "This account is in Standard, so this library will open silently from now on and your Apple account will hold a key to it. If you'd rather not leave Castle: Cancel here, put the ACCOUNT in Castle from a device already signed into it (Settings ▸ Protection ▸ Use Castle…), then join again.")
        #expect(ProtectionCopy.joinDoor == "Join" && ProtectionCopy.joinCancelDoor == "Cancel")
        #expect(ProtectionCopy.joinLaterLine == "Sync isn't joined on this \(ProtectionCopy.deviceName).")
        #expect(ProtectionCopy.connectCancelDoor == "Cancel")
        // The Connect notice: copy §3's sentence; its third door is Cancel, a follow's is Later.
        let connect = FollowNotice(kind: .connectLibrary, device: "another device", day: "an earlier day")
        #expect(connect.body == ProtectionCopy.keysDontMatchThisLibrary && connect.dismissDoor == "Cancel")
        #expect(FollowNotice(kind: .keysReplaced, device: "d", day: "y").dismissDoor == ProtectionCopy.followLaterDoor)
    }

    /// pre-13x 5a — the copy reconciliation's re-renders, verbatim: copy §3's
    /// lobby roads + the Touch ID failure, copy §2a's three twelve-words
    /// refusals (one wording at the lobby and the ceremony), copy §4's
    /// signed-out line, copy §6's backup sentences, copy §2b's
    /// conflict-follow Done (ledger 61) through the one brain.
    @MainActor
    @Test func theReconciledStringsRenderTheCopyVerbatim() {
        #expect(ProtectionCopy.lobbyPassphraseInsteadDoor == "Use your passphrase instead")
        #expect(ProtectionCopy.lobbyWordsDoor == "Use your twelve words")
        #expect(ProtectionCopy.lobbyBiometryFailed
                == "\(ProtectionCopy.biometryName) didn't go through — enter your encryption passphrase instead.")
        #expect(ProtectionCopy.message(for: RecoveryPhraseError.invalidWordCount(11))
                == "A recovery phrase is exactly 12 words — you entered 11.")
        #expect(ProtectionCopy.message(for: RecoveryPhraseError.unknownWord("zebra"))
                == "\u{201C}zebra\u{201D} isn't a recovery-phrase word — check its spelling.")
        #expect(ProtectionCopy.message(for: RecoveryPhraseError.checksumMismatch)
                == "That's not quite the phrase — one of the twelve words is off. Compare it with what you wrote down.")
        #expect(EncryptionSession.message(for: RecoveryPhraseError.checksumMismatch)
                == ProtectionCopy.message(for: RecoveryPhraseError.checksumMismatch), "one wording for the twelve words' refusals")
        #expect(EncryptionSession.message(for: RecoveryPhraseError.invalidWordCount(11))
                == ProtectionCopy.message(for: RecoveryPhraseError.invalidWordCount(11)))
        #expect(EncryptionSession.message(for: RecoveryPhraseError.unknownWord("zebra"))
                == ProtectionCopy.message(for: RecoveryPhraseError.unknownWord("zebra")))
        #expect(ProtectionCopy.signedOutLine == "Sign in to sync your library across your devices. Sync is end-to-end encrypted.")
        #expect(ProtectionCopy.backupsStandardSentence
                == "A backup opens through your Apple account — or with your passphrase or twelve words.")
        #expect(ProtectionCopy.backupsCastleSentence
                == "A backup opens with your twelve words — always, unless you regenerated them — or with the passphrase you had when it was made. Backups made while you were in Standard also open through your Apple account. Backups run while your library is open.")
        // pre-13x 5b (ledger 68): copy §6's lock-time copy line, rendered under
        // Castle on the Backups tab (row 7's feature, built at 2a).
        #expect(ProtectionCopy.backupsLockTimeCopyLine
                == "When you lock, Variorum also keeps a sealed copy of the library as it was — checked the next time you unlock.")
        // pre-13x 5b (ledger 66): copy §4's precised un-followed headline.
        #expect(ProtectionCopy.keysReplacedHeadline
                == "This account's keys changed since this \(ProtectionCopy.deviceName) joined. Enter your passphrase to pick up the new ones.")
        // RUN A batch A2, row 10 — RE-BASED to HER RULING on QUESTIONS #90
        // (3), ledger 61 + 67 (the ruled-change class): the Done now says
        // WHY — those are the words that device SHOWED when it entered
        // Castle ("like look at what you just put into Castle").
        #expect(ProtectionCopy.enteredCastleAfterAnotherDevice(device: "Lillian's iPhone")
                == "Another device entered Castle first, so this \(ProtectionCopy.deviceName) picked up that device's keys instead. The twelve words shown here are not your account's: your account's words are the ones Lillian's iPhone showed when it entered Castle — those are the set to keep.")
        #expect(ProtectionCopy.enteredCastleAfterAnotherDevice(device: nil)
                .hasSuffix("another device showed when it entered Castle — those are the set to keep."))
        #expect(ProtectionCopy.castleDoneBody(nil) == ProtectionCopy.enteredCastleDone)
        // pre-13x ladder round 1, F2 (MAJOR-3 d): the different-Apple-ID
        // sentence HEDGED — the client cannot tell another Apple account
        // from the same one under propagation lag (copy §2d, PROVISIONAL).
        #expect(ProtectionCopy.waitingDifferentAppleID
                == "This \(ProtectionCopy.deviceName)'s Apple account doesn't hold the key that set up sync — if it's the same Apple account, the key may still be arriving. Enter your passphrase or twelve words once to continue now; after that this \(ProtectionCopy.deviceName) opens on its own.")
        // F2 (MAJOR-3 b): Replace All Keys' refusal when the account's iCloud
        // key is not readable here (copy §4) — RE-DRAFTED at F2's adjudication,
        // rendered at F3 (PROVISIONAL; the door already takes the passphrase).
        #expect(ProtectionCopy.replaceKeysAppleKeyUnreachable
                == "Your Apple account's key isn't reachable on this \(ProtectionCopy.deviceName). If this \(ProtectionCopy.deviceName) is signed into the Apple account that set up sync, wait a moment and try again; if it isn't, run Replace All Keys from a \(ProtectionCopy.deviceName) that is.")
        #expect(ProtectionCopy.deviceNameWithArticle == "a Mac")
        // F2 (MAJOR-2): the Done when the fresh backup could not be made (copy
        // §2b, PROVISIONAL) — WITH the Touch ID / other-devices tail (F3, F2's
        // adjudication item 1: the tail states a fact every Castle Done owes).
        #expect(ProtectionCopy.enteredCastleWithoutFreshBackup
                == "You're in Castle. A fresh backup could not be made just now — check your Backups folder; your earlier backups are untouched. This \(ProtectionCopy.deviceName) asks for \(ProtectionCopy.biometryName) from now on; your other devices will ask the next time they open.")
        // F3 (F2's adjudication item 2): the Done on a device that keeps no
        // backups (`.notKept`) claims none; `.failed` and `.written` as before.
        #expect(ProtectionCopy.enteredCastleWithoutBackupClaim
                == "You're in Castle. Your library has a new key that your Apple account never held. This \(ProtectionCopy.deviceName) asks for \(ProtectionCopy.biometryName) from now on; your other devices will ask the next time they open.")
        func outcome(_ snapshot: PostureSwitchRunner.FreshSnapshot) -> PostureSwitchRunner.Outcome {
            PostureSwitchRunner.Outcome(
                entersCastle: true, newKeyFingerprint: "fp", insuranceTurnedOff: false,
                preSwitchSnapshots: [], freshSnapshot: snapshot, reencrypted: 0, material: nil)
        }
        #expect(ProtectionCopy.castleDoneBody(outcome(.notKept)) == ProtectionCopy.enteredCastleWithoutBackupClaim)
        #expect(ProtectionCopy.castleDoneBody(outcome(.failed)) == ProtectionCopy.enteredCastleWithoutFreshBackup)
        #expect(ProtectionCopy.castleDoneBody(outcome(.written(URL(fileURLWithPath: "/dev/null")))) == ProtectionCopy.enteredCastleDone)
        #expect(!ProtectionCopy.castleDoneBody(outcome(.notKept)).contains("backup"), "no backup claim where none is kept")
        // The nudge's lines by tier — the one brain that survived §13; F3
        // (NIT-N8): the WAITING tier speaks copy §2d's waiting title + body.
        #expect(ProtectionCopy.nudgeSentence(for: .covered) == ProtectionCopy.coveredNudgeLine)
        #expect(ProtectionCopy.nudgeSentence(for: .exposed) == ProtectionCopy.exposedNudgeHeadline + " " + ProtectionCopy.exposedNudgeBody)
        #expect(ProtectionCopy.nudgeSentence(for: .unknown) == ProtectionCopy.unknownNudgeLine)
        #expect(ProtectionCopy.nudgeSentence(for: .waiting) == ProtectionCopy.waitingTitle + " " + ProtectionCopy.waitingBody)
        #expect(ProtectionCopy.nudgeSentence(for: .waiting)
                == "Getting your key from iCloud Keychain… This usually takes a moment and can take longer. You can also enter your passphrase or twelve words instead.")
    }

    @Test func theFollowNoticesRenderCopyFiveVerbatim() {
        let day = ProtectionCopy.day(from: "2026-09-04T10:00:00Z")
        #expect(day == ProtectionCopy.day(from: "2026-09-04"), "the day, never the time")
        #expect(ProtectionCopy.day(from: nil) == "an earlier day")
        #expect(ProtectionCopy.followMovedToCastle(device: "Lillian's iPhone", day: day)
                == "Your account is now in Castle — set on Lillian's iPhone on \(day). From now on this \(ProtectionCopy.deviceName) asks for \(ProtectionCopy.biometryName) to open your library, with your passphrase as the fallback. Enter your passphrase once to pick up your new sync keys: they were replaced when Castle was entered, and only your passphrase or twelve words open them.")
        #expect(ProtectionCopy.followKeysReplaced(device: "Lillian's iPhone", day: day)
                == "Your keys were replaced on Lillian's iPhone on \(day). Enter your passphrase once to pick up the new ones.")
        // pre-13x 2d.4 (the orchestrator's ruling 1): the posture-mismatch follow's OWN sentence.
        #expect(ProtectionCopy.followCastleStillOpensOldWay
                == "Your account is in Castle, but this \(ProtectionCopy.deviceName) still opens without asking. Enter your passphrase once to move this \(ProtectionCopy.deviceName)'s key behind \(ProtectionCopy.biometryName) and give your library a fresh key.")
        #expect(ProtectionCopy.followCastleStillOpensLaterSubline == "Until then this \(ProtectionCopy.deviceName) opens and reads as before — what you write meanwhile stays under the old key until you enter your passphrase.")
        let mismatch = FollowNotice(kind: .castleStillOpensOldWay, device: "Lillian's iPhone", day: day)
        #expect(mismatch.body == ProtectionCopy.followCastleStillOpensOldWay && mismatch.laterSubline == ProtectionCopy.followCastleStillOpensLaterSubline)
        #expect(mismatch.waitingBody == ProtectionCopy.followCastleStillOpensOldWay, "no keys were replaced and sync is not paused — the banner says the same sentence")
        let rotated = FollowNotice(kind: .movedToCastle, device: "Lillian's iPhone", day: day)
        #expect(rotated.laterSubline == ProtectionCopy.followLaterSubline && rotated.waitingBody == ProtectionCopy.followWaiting(device: "Lillian's iPhone", day: day))
        #expect(ProtectionCopy.followWaiting(device: "Lillian's iPhone", day: day)
                == "Sync is paused until you enter your passphrase once — your keys were replaced on Lillian's iPhone on \(day).")
        #expect(ProtectionCopy.followMovedToStandard(device: "Lillian's iPhone", day: day)
                == "Your account is back in Standard — set on Lillian's iPhone on \(day). This \(ProtectionCopy.deviceName) opens silently again; your Apple account holds a key.")
        #expect(ProtectionCopy.alwaysAskRetiredWord(device: "Lillian's iPhone", day: day)
                == "Your passphrase was changed on Lillian's iPhone on \(day). The old one still opens this \(ProtectionCopy.deviceName), but sync waits until you enter the new one here.")
        // pre-13x 4a (ledger 50(b)): the two Later sub-lines as precised 2026-09-06; Connect's done line (copy §3).
        #expect(ProtectionCopy.followLaterSubline == "Until then this \(ProtectionCopy.deviceName) opens and reads, but doesn't sync — and what you write meanwhile stays under the old key until you pick up the new ones.")
        #expect(ProtectionCopy.connectDoneBody == "This library is connected to this account, and everything in it is uploading now.")
        #expect(ProtectionCopy.pickUpKeysFirst == "Pick up your new keys first — enter your passphrase.")
        // pre-13x 4a: copy §5's first two lines (the change notices) + copy §3's lobby lines.
        #expect(ProtectionCopy.passphraseChangedElsewhere(device: "Lillian's iPhone", day: day)
                == "Your passphrase was changed on Lillian's iPhone on \(day). Use the new one here when you can — this \(ProtectionCopy.deviceName) still takes the old one until you do.")
        #expect(ProtectionCopy.wordsRegeneratedElsewhere(device: "Lillian's iPhone", day: day)
                == "Your twelve words were regenerated on Lillian's iPhone on \(day). Use the new ones here when you can — this \(ProtectionCopy.deviceName) still takes the old ones until you do.")
        let changed = FollowNotice(kind: .passphraseChangedElsewhere, device: "Lillian's iPhone", day: day)
        #expect(changed.isChangeNotice && changed.body == ProtectionCopy.passphraseChangedElsewhere(device: "Lillian's iPhone", day: day)
                && changed.dismissDoor == ProtectionCopy.changeDismissDoor)
        #expect(ProtectionCopy.lobbyRetiredPassphrase == "Your passphrase was changed on another device — enter the new one.")
        #expect(ProtectionCopy.lobbyOfflineNote == "You're offline. If your passphrase was changed on another device recently, the one you had before still works here until you're back online.")
        #expect(ProtectionCopy.lobbyPhaseLine(.unlocking) == "Unlocking…" && ProtectionCopy.lobbyPhaseLine(.checkingAccount) == "Checking your account…")
        #expect(ProtectionCopy.followEnterDoor == "Enter Passphrase…" && ProtectionCopy.followWordsDoor == "Use Twelve Words…"
                && ProtectionCopy.followLaterDoor == "Later" && ProtectionCopy.followWaitingDoor == "Enter…"
                && ProtectionCopy.enterItNowDoor == "Enter It Now…" && ProtectionCopy.followMovedToStandardDoor == "OK")
    }

    /// **RUN A batch A2, row 12 (17l item 6) — *(0 of 0)* before the first
    /// window.** Her observation: between the vault write and the first
    /// pulled window the ceremony's line reads *(0 of 0)*, which looks like
    /// a corpus of nothing rather than a walk about to start. The gate is
    /// THE FIRST WINDOW (`total == 0` = nothing reported yet), never "done
    /// is zero" — `done == 0` is the honest count all through window one.
    @Test func theReencryptingLinePreparesUntilTheFirstWindowLands() {
        #expect(ProtectionCopy.reencryptingLine(done: 0, total: 0)
                == "Re-encrypting your library on the server… (preparing)")
        // The first window HAS landed: zero done is a real count, not a gap.
        #expect(ProtectionCopy.reencryptingLine(done: 0, total: 120)
                == "Re-encrypting your library on the server… (0 of 120)")
        #expect(ProtectionCopy.reencryptingLine(done: 118, total: 120)
                == "Re-encrypting your library on the server… (118 of 120)")
        // The running line rides the same brain, and its ONE differing arm
        // stays what each sheet always said.
        #expect(ProtectionCopy.runningLine(for: .reencrypting(done: 0, total: 0), minting: true)
                == ProtectionCopy.reencryptingLine(done: 0, total: 0))
        #expect(ProtectionCopy.runningLine(for: .rotatingKeys, minting: true) == "Minting your new keys…")
        #expect(ProtectionCopy.runningLine(for: .rotatingKeys, minting: false) == "Picking up your new keys…")
        #expect(ProtectionCopy.runningLine(for: .rekeyingLibrary, minting: true) == ProtectionCopy.rekeyingLibraryLine)
        #expect(ProtectionCopy.runningLine(for: .pullingToHead, minting: false) == "Catching up with the server…")
        #expect(ProtectionCopy.runningLine(for: .idle, minting: true) == "Working…")
    }

    /// Row 12's FACE, pinned where the face actually lives: the four
    /// ceremony/follow sheets (two Mac, two phone) carried byte-identical
    /// switches over the runner's phase, so the fix would have had to be
    /// made four times to be true anywhere. No sheet re-derives it now —
    /// they render the one brain. (The grep form is the 13u4 S3 precedent.)
    @Test func noSheetReDerivesTheRunningLine() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
        var offenders: [String] = []
        for rootName in ["Variorum", "VariorumMobile", "Shared"] {
            let root = appRoot.appendingPathComponent(rootName)
            #expect(FileManager.default.fileExists(atPath: root.path), "root missing: \(rootName)")
            guard let walker = FileManager.default.enumerator(
                at: root, includingPropertiesForKeys: nil) else { continue }
            for case let file as URL in walker where file.pathExtension == "swift" {
                // The brain's own home is where the arm belongs.
                if file.lastPathComponent == "PostureCopy.swift" { continue }
                let source = try String(contentsOf: file, encoding: .utf8)
                for (index, line) in source.split(separator: "\n", omittingEmptySubsequences: false)
                    .map(String.init).enumerated()
                where !line.trimmingCharacters(in: .whitespaces).hasPrefix("//")
                    && line.contains("case .reencrypting(") {
                    offenders.append(
                        "\(file.lastPathComponent):\(index + 1) — \(line.trimmingCharacters(in: .whitespaces))")
                }
            }
        }
        #expect(offenders.isEmpty, "a surface re-deriving the re-encrypting line: \(offenders)")
    }

    /// **RUN A batch A2, row 10 (17l item 3) — HER FOUR RULED WORDINGS on
    /// QUESTIONS #90, each a copy constant with its pin on both platforms
    /// (the phone's twin is `MobilePhoneProtectionCopyTests`). 13s
    /// re-voices; three of the four are PROVISIONAL at QUESTIONS #138.**
    @MainActor
    @Test func herFourRuledWordingsAreWhatTheSurfacesSay() {
        // (2) ledger 54 — RULED: *"Pick Up New Keys is fine as a choice"*.
        // One brain, so a door that will run at once never promises a field.
        #expect(ProtectionCopy.followPickUpKeysDoor == "Pick Up New Keys")
        #expect(ProtectionCopy.followEnterDoorLabel(asksNothing: true) == "Pick Up New Keys")
        #expect(ProtectionCopy.followEnterDoorLabel(asksNothing: false) == "Enter Passphrase…")

        // (3) ledger 61 + 67 — RULED: the Done says WHY, "like look at what
        // you just put into Castle". The device is named as the one that
        // SHOWED the account's words, not merely as an address.
        let done = ProtectionCopy.enteredCastleAfterAnotherDevice(device: "Lillian's iPhone")
        #expect(done.contains("are not your account's"))
        #expect(done.contains("Lillian's iPhone showed when it entered Castle"))
        #expect(done.contains("the set to keep"))
        #expect(ProtectionCopy.enteredCastleAfterAnotherDevice(device: nil)
                .contains("another device showed when it entered Castle"))

        // (4) ledger 46 — RULED: cancel · put the ACCOUNT in Castle · rejoin.
        let consent = ProtectionCopy.joinStandardConsent
        #expect(consent.contains("Cancel here"))
        #expect(consent.contains("put the ACCOUNT in Castle"))
        #expect(consent.contains("then join again"))
        #expect(consent.range(of: "Cancel here")!.lowerBound
                < consent.range(of: "put the ACCOUNT in Castle")!.lowerBound,
                "her order: cancel first")
        #expect(consent.range(of: "put the ACCOUNT in Castle")!.lowerBound
                < consent.range(of: "then join again")!.lowerBound)

        // (7) MINOR-6 — RULED: the sentence names the website's road (the
        // BUTTON stays her future-round candidate). The book's Chapter 7
        // carries it; this pin reads the shipped resource itself.
        let book = try! SampleLibrarySeeder.loadStories(for: .encryptionExplained)
        let chapter7 = book.first { $0.title.hasPrefix("Chapter 7") }
        let text = try! #require(chapter7).text
        #expect(text.contains("stargazing.tech"), "the website's road is named")
        #expect(text.contains("signing in and changing your password happen on the website, not in the app"))
    }

    @Test func everyModeSaysWhatItDoesNotProtect() {
        #expect(ProtectionCopy.modeSentence(.auto).contains("anyone who can use this Mac"))
        #expect(ProtectionCopy.modeSentence(.biometric).contains("login password can NOT"))
        #expect(ProtectionCopy.modeSentence(.passphrase).contains("Nothing opens it silently"))
    }

    /// pre-13x 2a: copy §1's posture words, verbatim — both postures
    /// named, tagged, one-lined, and their six card rows in the copy's
    /// order (a re-derived card would be the almost-true paraphrase the
    /// design forbids).
    @Test func thePostureCopyRendersCopySectionOneVerbatim() {
        #expect(ProtectionCopy.postureName(.standard) == "Standard")
        #expect(ProtectionCopy.postureName(.castle) == "Castle")
        #expect(ProtectionCopy.postureTag(.standard) == "the default")
        #expect(ProtectionCopy.postureTag(.castle) == "only you")
        #expect(ProtectionCopy.currentStateLine(.standard)
            == "You're in Standard. Your Apple account holds a key.")
        #expect(ProtectionCopy.currentStateLine(.castle)
            == "You're in Castle. Only you hold the keys.")
        #expect(ProtectionCopy.postureOneLine(.standard)
            == "Your Apple account holds a key. Nothing to remember day to day.")
        #expect(ProtectionCopy.postureOneLine(.castle)
            == "Only you hold the keys. Your Mac's login password can't open your library.")
        let labels = ["Who holds a key", "Opening", "A new device", "Who it stops",
                      "If your Mac dies", "The floor"]
        #expect(ProtectionCopy.postureCard(.standard).map(\.label) == labels)
        #expect(ProtectionCopy.postureCard(.castle).map(\.label) == labels)
        #expect(ProtectionCopy.postureCard(.castle)[0].text.contains(
            "released only to your fingerprint — never to your login password, never to iCloud"))
        #expect(ProtectionCopy.alwaysAskLabel == "Always ask for the passphrase")
        #expect(ProtectionCopy.idleLabel == "Lock after time away")
        #expect(ProtectionCopy.keystoneOpenMeansReadable.hasPrefix(
            "While Variorum is open and unlocked, everything in it is readable"))
    }

    /// pre-13x 2b item (0): her migration's one-time message (copy §9)
    /// renders the CORRECTED sentence — the sync keys live in this Mac's
    /// own protected Keychain beside the library's key, NEVER in the
    /// library file. RED ON OLD: the 2a string said "inside your
    /// encrypted library" (the 2a record's questions 1 and 4).
    @Test func theMigrationConfirmRendersCopyNinesCorrectedSentence() {
        #expect(ProtectionCopy.migrationConfirmBody
            == "Variorum now keeps your sync keys in this Mac's own protected Keychain, "
            + "beside your library's key — never in the library file — and your account "
            + "is in Castle. Nothing else changed. Confirm your passphrase once to finish.")
        #expect(!ProtectionCopy.migrationConfirmBody.contains("inside your encrypted library"),
                "the design's §3.3: never in the library file")
        #expect(ProtectionCopy.migrationConfirmDoor == "Confirm…")
        #expect(ProtectionCopy.migrationLaterDoor == "Later")
    }

    @Test func envelopeRefusalsSpeakInWords() {
        #expect(ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase)
            == "That passphrase doesn't unlock this library.")
        #expect(ProtectionCopy.message(for: RecoveryPhraseError.invalidWordCount(9))
            .contains("exactly 12 words"))
        #expect(ProtectionCopy.message(for: RecoveryPhraseError.unknownWord("varirum"))
            .contains("varirum"))
    }
}

@Suite("13p — reminder & nudge cadence (pure)")
struct ProtectionCadenceTests {
    private let day: TimeInterval = 24 * 60 * 60

    @Test func reminderNeedsAPassphraseAndCastle() {
        let now = Date()
        #expect(!ReminderCheckPolicy.isDue(
            now: now, enabled: true, passphraseSetAt: nil,
            lastConfirmedAt: nil, lastDismissedAt: nil),
            "no reminder exists before a passphrase does")
        #expect(!ReminderCheckPolicy.isDue(
            now: now, enabled: false, passphraseSetAt: now.addingTimeInterval(-90 * day),
            lastConfirmedAt: nil, lastDismissedAt: nil),
            "Standard has no reminder — the nudge covers it (§13)")
    }

    @Test func reminderAnchorsOnTheNewestOfSetConfirmDismiss() {
        let now = Date()
        let old = now.addingTimeInterval(-90 * day)
        #expect(ReminderCheckPolicy.isDue(
            now: now, enabled: true, passphraseSetAt: old,
            lastConfirmedAt: nil, lastDismissedAt: nil))
        #expect(!ReminderCheckPolicy.isDue(
            now: now, enabled: true, passphraseSetAt: old,
            lastConfirmedAt: now.addingTimeInterval(-day), lastDismissedAt: nil),
            "a fresh confirmation resets the clock")
        #expect(!ReminderCheckPolicy.isDue(
            now: now, enabled: true, passphraseSetAt: old,
            lastConfirmedAt: old, lastDismissedAt: now.addingTimeInterval(-day)),
            "a dismissal snoozes a full cadence — it never re-nags tomorrow")
    }

    @Test func nudgeWaitsForRealUseAndStopsWhenBothArtifactsExist() {
        let now = Date()
        let yesterday = now.addingTimeInterval(-2 * day)
        #expect(StandardNudgePolicy.isEligible(
            now: now, firstUseAt: yesterday, dismissedForever: false,
            snoozedUntil: nil, hasPassphraseWrap: false, hasRecoveryWrap: false))
        #expect(!StandardNudgePolicy.isEligible(
            now: now, firstUseAt: now, dismissedForever: false,
            snoozedUntil: nil, hasPassphraseWrap: false, hasRecoveryWrap: false),
            "never at first launch — knot 4's letter")
        #expect(!StandardNudgePolicy.isEligible(
            now: now, firstUseAt: yesterday, dismissedForever: false,
            snoozedUntil: nil, hasPassphraseWrap: true, hasRecoveryWrap: true),
            "both artifacts in hand ⇒ nothing to offer")
        #expect(StandardNudgePolicy.isEligible(
            now: now, firstUseAt: yesterday, dismissedForever: false,
            snoozedUntil: nil, hasPassphraseWrap: true, hasRecoveryWrap: false),
            "one missing artifact keeps the offer alive (her two-offer amendment)")
        #expect(!StandardNudgePolicy.isEligible(
            now: now, firstUseAt: yesterday, dismissedForever: true,
            snoozedUntil: nil, hasPassphraseWrap: false, hasRecoveryWrap: false))
        #expect(!StandardNudgePolicy.isEligible(
            now: now, firstUseAt: yesterday, dismissedForever: false,
            snoozedUntil: now.addingTimeInterval(day),
            hasPassphraseWrap: false, hasRecoveryWrap: false))
    }

    /// pre-13x 2a — THE IDLE CLOCK (decision 18): time since Variorum was
    /// last USED; nil minutes = never; the threshold is inclusive.
    @Test func theIdleClockIsTimeSinceVariorumWasLastUsed() {
        let now = Date()
        #expect(IdleLockClock.isDue(now: now, lastUsedAt: now.addingTimeInterval(-10 * 60), minutes: 10))
        #expect(!IdleLockClock.isDue(now: now, lastUsedAt: now.addingTimeInterval(-9 * 60), minutes: 10))
        #expect(!IdleLockClock.isDue(now: now, lastUsedAt: now.addingTimeInterval(-24 * 3600), minutes: nil),
                "never means never")
        #expect(!IdleLockClock.isDue(now: now, lastUsedAt: nil, minutes: 5),
                "no activity stamp yet ⇒ nothing to measure against")
        #expect(IdleLockClock.isDue(idleSeconds: 5 * 60, minutes: 5))
    }
}

@Suite("13p — the guard's scripted custody world")
struct StoreKeyGuardBackingTests {
    @Test func theCustodyLawOfTheModesIsExpressible() {
        let key = StoreKey.mint()
        let backing = InMemoryStoreKeyGuardBacking(auto: key)
        let guardSeam = StoreKeyGuard.inMemory(backing: backing)

        // Auto: plain present, gated absent.
        #expect(guardSeam.loadAuto() == key)
        #expect(!guardSeam.gatedItemExists())

        // → Biometric: gated lands, plain DELETED (no silent release).
        #expect(guardSeam.saveGated(key))
        guardSeam.deleteAuto()
        #expect(guardSeam.gatedItemExists())
        #expect(guardSeam.loadAuto() == nil, "a gate whose key still releases silently is theater")

        // → Passphrase-every-open: neither item.
        guardSeam.deleteGated()
        #expect(!guardSeam.gatedItemExists())
        #expect(guardSeam.loadAuto() == nil)
    }

    @Test func biometricOutcomesAreScriptedNeverPrompted() async {
        let key = StoreKey.mint()
        let backing = InMemoryStoreKeyGuardBacking(
            gated: key, biometryAvailable: true, biometricSucceeds: false)
        let guardSeam = StoreKeyGuard.inMemory(backing: backing)
        #expect(await guardSeam.unlockGated() == nil, "a failed evaluation yields nil")
        backing.biometricSucceeds = true
        #expect(await guardSeam.unlockGated() == key)
        #expect(await guardSeam.confirmPresence("reset") == true)
    }

    /// pre-13x 2a: the 13p escrow family survives ONLY as the migration's
    /// door — read by store id, removed released-or-never-there.
    @Test func theLegacyEscrowDoorReadsAndRemovesPerStoreID() {
        let backing = InMemoryStoreKeyGuardBacking()
        let guardSeam = StoreKeyGuard.inMemory(backing: backing)
        let a = StoreKey.mint()
        let b = StoreKey.mint()
        backing.escrow["store-a"] = a
        backing.escrow["store-b"] = b
        #expect(guardSeam.loadLegacyEscrow("store-a") == a)
        #expect(guardSeam.removeLegacyEscrow("store-a"))
        #expect(guardSeam.loadLegacyEscrow("store-a") == nil)
        #expect(guardSeam.loadLegacyEscrow("store-b") == b, "per-store items never cross")
        #expect(guardSeam.removeLegacyEscrow("never-there"), "released = gone, or never there")
    }
}

/// pre-13x 1a → 2a — the dials are PER STORE ID with a legacy read-through
/// (the postures design §3.1), retired per store by §11's migration.
@Suite("pre-13x 2a — the dials per store id, the legacy read-through, and its retirement")
struct ProtectionDialsPerStoreTests {
    @Test func aStoreWithNoKeysOfItsOwnReadsTheLegacyScopeKeys() {
        let defaults = UserDefaults(suiteName: "variorum-2a-dials-\(UUID().uuidString)")!
        let scope = "probe"
        // The 13p-era scope keys, as her existing library holds them.
        defaults.set("passphrase", forKey: ProtectionDefaults.key("mode", scope: scope))
        defaults.set(15, forKey: ProtectionDefaults.key("relockIdleMinutes", scope: scope))
        let read = ProtectionDefaults.dials(scope: scope, storeID: "store-a", in: defaults)
        #expect(read.alwaysAsk, "a stored passphrase-every-open mode reads as Always ask")
        #expect(read.relockAfterIdleMinutes == 15)
        #expect(ProtectionDefaults.legacyMode(scope: scope, storeID: "store-a", in: defaults) == .passphrase)
    }

    @Test func aStoresOwnSaveEndsTheReadThroughForThatStoreOnly() {
        let defaults = UserDefaults(suiteName: "variorum-2a-dials-\(UUID().uuidString)")!
        let scope = "probe"
        defaults.set("biometric", forKey: ProtectionDefaults.key("mode", scope: scope))
        ProtectionDefaults.save(ProtectionDials(), scope: scope, storeID: "store-new", in: defaults)
        #expect(ProtectionDefaults.legacyMode(scope: scope, storeID: "store-new", in: defaults) == nil,
                "a NEW library reads only its own keys — never the old library's Castle")
        #expect(ProtectionDefaults.legacyMode(scope: scope, storeID: "store-old", in: defaults) == .biometric,
                "another store id still reads through to the legacy mode")
        #expect(!ProtectionDefaults.dials(scope: scope, storeID: "store-new", in: defaults).alwaysAsk)
    }

    /// §11's leg: the 13p-era keys retire — the gate style she had
    /// survives as the store's own `alwaysAsk`, and every legacy leaf goes
    /// at both levels. Idempotent.
    @Test func retiringTheLegacyKeysKeepsTheStyleAndRemovesEveryLeaf() {
        let defaults = UserDefaults(suiteName: "variorum-2a-dials-\(UUID().uuidString)")!
        let scope = "probe"
        defaults.set("passphrase", forKey: ProtectionDefaults.key("mode", scope: scope))
        defaults.set(true, forKey: ProtectionDefaults.key("escrowOff", scope: scope))
        defaults.set(true, forKey: ProtectionDefaults.key("relockOnSleep", scope: scope))
        defaults.set(true, forKey: ProtectionDefaults.key("reminders", scope: scope))
        defaults.set(30, forKey: ProtectionDefaults.key("relockIdleMinutes", scope: scope))
        #expect(ProtectionDefaults.hasLegacyKeys(scope: scope, storeID: "store-a", in: defaults))

        ProtectionDefaults.retireLegacyKeys(scope: scope, storeID: "store-a", in: defaults)
        #expect(!ProtectionDefaults.hasLegacyKeys(scope: scope, storeID: "store-a", in: defaults))
        #expect(ProtectionDefaults.legacyMode(scope: scope, storeID: "store-a", in: defaults) == nil)
        let after = ProtectionDefaults.dials(scope: scope, storeID: "store-a", in: defaults)
        #expect(after.alwaysAsk, "the style she had survives as the store's own key")
        #expect(after.relockAfterIdleMinutes == 30)
        ProtectionDefaults.retireLegacyKeys(scope: scope, storeID: "store-a", in: defaults)
        #expect(ProtectionDefaults.dials(scope: scope, storeID: "store-a", in: defaults) == after, "idempotent")
    }
}
