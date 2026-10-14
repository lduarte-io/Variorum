//
//  AssessTests.swift
//  VariorumCoreTests — VX-305 U2: `assess`, table by table — every row of the
//  four-account table; the vault's three states and a follower's hold in the
//  middle one; the mode confirmed or not (corner 45 among it); §3.10's Touch
//  ID road as data; §3.3's repairs with their guards; acts owed; every door
//  with its reason; the old shared key's checks; the move's subjects.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U2 — assess: the four account situations (§3.8)")
struct AssessAccountTests {
    @Test func noAccountIsLocalOnlyAndOffersToTurnSyncOn() throws {
        var world = try AWorld(.standard)
        #expect(try world.assessed().account.situation == .localOnly)
        #expect(try world.assessed().door(.turnOnSync).refusal == .noAccountSignedIn)
        world.session = .signedIn(accountID: PF.id(), email: "y@example.com")
        let signedIn = try world.assessed()
        #expect(signedIn.account.situation == .localOnly, "signing in changes nothing")
        #expect(signedIn.door(.turnOnSync).spec?.join == .setsUpInLibrarysMode)
        #expect(signedIn.door(.useCastle).isOpen, "the library's own mode doors stay")
    }

    @Test func theLibrarysAccountSignedInIsInSync() throws {
        let x = PF.id()
        var world = try AWorld(.castle, account: x)
        world.session = .signedIn(accountID: x, email: "x@example.com")
        let noVault = try world.assessed()
        #expect(noVault.account.situation == .inSync(account: x) && !noVault.account.confirmed)
        #expect(noVault.door(.useStandard).refusal == .needsFreshVault, "a synced act needs the vault read fresh")
        world.vault = AWorld.vault(x, .castle)
        let fresh = try world.assessed()
        #expect(fresh.account.confirmed)
        #expect(fresh.door(.useStandard).spec?.synced == true)
        for door in [Door.thisMacOnly, .stopSyncingHere, .deleteAccountHere] {
            #expect(fresh.door(door).isOpen, "\(door)")
        }
    }

    @Test func theLibrarysAccountSignedOutOffersTheOneRoadScreens() throws {
        let x = PF.id()
        let world = try AWorld(.standard, account: x)
        let assessed = try world.assessed()
        #expect(assessed.account.situation == .signedOut(account: x))
        #expect(assessed.door(.useCastle).refusal == .signedOutUseThisMacOnly)
        #expect(assessed.door(.thisMacOnly).isOpen && assessed.door(.stopSyncingHere).isOpen)
        #expect(assessed.door(.deleteAccountHere).refusal == .noAccountSignedIn)
    }

    @Test func anotherAccountSignedInOffersMoveOrSignOutOnly() throws {
        let x = PF.id(), y = PF.id()
        var world = try AWorld(.castle, account: x)
        world.session = .signedIn(accountID: y, email: "same@example.com")
        world.libraryAccountEmail = "other@example.com"
        let assessed = try world.assessed()
        #expect(assessed.account.situation == .otherAccount(library: x, signedIn: y, sameEmail: false))
        #expect(assessed.door(.moveToSignedInAccount).isOpen && assessed.door(.signOut).isOpen)
        for door in [Door.useCastle, .useStandard, .replaceAllKeys, .changePassphrase, .newWords, .thisMacOnly] {
            #expect(assessed.door(door).refusal == .otherAccountSignedIn, "\(door)")
        }
        // The same email with a different account is named.
        world.libraryAccountEmail = "same@example.com"
        let same = try world.assessed()
        #expect(same.account.situation == .otherAccount(library: x, signedIn: y, sameEmail: true))
        #expect(same.door(.moveToSignedInAccount).spec?.words.contains(.sameEmailDifferentAccount) == true)
    }

    /// Every leave re-keys, in both modes (her round-2 ruling).
    @Test func everyLeaveReKeysInBothModes() throws {
        for mode in ProtectionMode.allCases {
            let x = PF.id()
            var world = try AWorld(mode, account: x)
            world.session = .signedIn(accountID: x, email: nil)
            world.vault = AWorld.vault(x, mode == .castle ? .castle : .standard(appleKeyID: PF.id()))
            let assessed = try world.assessed()
            for door in [Door.thisMacOnly, .stopSyncingHere, .deleteAccountHere] {
                let spec = try #require(assessed.door(door).spec, "\(mode) \(door)")
                #expect(spec.rekeys, "\(mode) \(door) re-keys")
                #expect(spec.requires == (mode == .castle
                    ? .passphraseAndWords(wordsMayBeNew: true) : .passphraseOrSetNewAndWordsOrMadeNew))
            }
        }
    }

    /// The joining rules: Castle from Standard is entering Castle; Standard
    /// from Castle is leaving it (rule 5 at the consent); the same mode keeps
    /// the key.
    @Test func theJoiningRules() throws {
        let y = PF.id()
        for (library, vault, plan) in [
            (ProtectionMode.standard, VaultMode.castle, JoinPlan.entersCastle),
            (.castle, .standard(appleKeyID: PF.id()), .leavesCastle),
            (.castle, .castle, .sameMode),
            (.standard, .standard(appleKeyID: PF.id()), .sameMode),
        ] {
            var world = try AWorld(library)
            world.session = .signedIn(accountID: y, email: nil)
            world.vault = AWorld.vault(y, vault)
            let spec = try #require(try world.assessed().door(.turnOnSync).spec)
            #expect(spec.join == plan, "\(library) joining \(vault)")
            #expect(spec.rekeys == (plan != .sameMode))
            if plan == .leavesCastle { #expect(spec.words.contains(.ruleFive)) }
        }
    }
}

@Suite("VX-305 U2 — assess: the vault's three states, and a follower's hold in the middle one (§3.9)")
struct AssessVaultTests {
    static func synced(_ mode: ProtectionMode, vault: VaultMode, previous: String? = nil,
                       readable: Set<String> = []) throws -> (AWorld, String) {
        let x = PF.id()
        var world = try AWorld(mode, account: x)
        world.session = .signedIn(accountID: x, email: nil)
        world.vault = AWorld.vault(x, vault, previous: previous)
        world.appleKeys.readable.formUnion(readable)
        return (world, x)
    }

    @Test func aWrapReadsStandardAnIdWithNoWrapALeaveNeitherCastle() throws {
        let id = PF.id()
        #expect(AWorld.vault("a", .standard(appleKeyID: id)).mode == .standard(appleKeyID: id))
        #expect(AWorld.vault("a", .leavingCastle(appleKeyID: id)).mode == .leavingCastle(appleKeyID: id))
        #expect(AWorld.vault("a", .castle).mode == .castle)
        #expect(AWorld.vault("a", .leavingCastle(appleKeyID: id)).rotationInProgress)
        #expect(AWorld.vault("a", .castle, previous: "c0").rotationInProgress)
        #expect(!AWorld.vault("a", .castle).rotationInProgress)
    }

    @Test func aFollowerThatSeesALeaveInProgressHoldsItsReKey() throws {
        let named = PF.id()
        let (world, _) = try Self.synced(.castle, vault: .leavingCastle(appleKeyID: named), previous: "c0")
        let assessed = try world.assessed()
        #expect(assessed.acts.contains(.follow(.intoStandard, typesOneSecret: true, holdsLibraryRekey: true)))
        let vault = try #require(assessed.vault)
        #expect(vault.syncKeysCustody == .castleWay, "Castle-kind custody through the leave's rotation")
        #expect(!vault.mayCompleteLeave, "only a device that reads the named key completes it")
        #expect(vault.unfinishedLeave?.namedAppleKeyID == named)
        #expect(assessed.door(.followNow).spec?.requires == .oneSecret, "every follow out of Castle types one secret")
        #expect(assessed.door(.useCastle).refusal == .followOwed)
    }

    @Test func aDeviceThatReadsTheNamedKeyMayCompleteTheLeave() throws {
        let named = PF.id()
        let (world, _) = try Self.synced(.castle, vault: .leavingCastle(appleKeyID: named), readable: [named])
        let vault = try #require(try world.assessed().vault)
        #expect(vault.mayCompleteLeave && vault.unfinishedLeave?.namedKeyReadableHere == true)
    }

    @Test func aRotationWithNoIdCompletesWithoutAnAppleCopy() throws {
        let (world, _) = try Self.synced(.castle, vault: .castle, previous: "c0")
        let assessed = try world.assessed()
        let vault = try #require(assessed.vault)
        #expect(vault.completesWithoutAppleCopy && !vault.mayCompleteLeave)
        #expect(assessed.door(.replaceAllKeys).refusal == .rotationInProgress(device: "Lillian's Air", day: CF.stamp(9)),
                "decision 32: one rotation at a time, the device and day named")
    }

    @Test func syncKeysAreHeldByWhatTheyReach() throws {
        #expect(try Self.synced(.castle, vault: .castle).0.assessed().vault?.syncKeysCustody == .castleWay)
        #expect(try Self.synced(.standard, vault: .standard(appleKeyID: PF.id())).0.assessed().vault?.syncKeysCustody == .silent)
        #expect(try Self.synced(.castle, vault: .leavingCastle(appleKeyID: PF.id())).0.assessed().vault?.syncKeysCustody == .castleWay)
    }

    @Test func theAccountMovingElsewhereIsAFollow() throws {
        let (intoCastle, _) = try Self.synced(.standard, vault: .castle)
        #expect(try intoCastle.assessed().acts.contains(.follow(.intoCastle, typesOneSecret: true, holdsLibraryRekey: false)))
        let (intoStandard, _) = try Self.synced(.castle, vault: .standard(appleKeyID: PF.id()))
        #expect(try intoStandard.assessed().acts.contains(.follow(.intoStandard, typesOneSecret: true, holdsLibraryRekey: false)))
        // Keys replaced in Standard: through the account's Apple key, nothing typed.
        let accountKey = PF.id()
        var replaced = try Self.synced(.standard, vault: .standard(appleKeyID: accountKey), readable: [accountKey]).0
        var memory = replaced.agreeingMemory
        memory.vaultFacts = VaultFacts(corpusKeyID: "c0")
        replaced.memory = memory
        #expect(try replaced.assessed().acts.contains(.follow(.keysReplaced, typesOneSecret: false, holdsLibraryRekey: false)))
        replaced.appleKeys.readable.remove(accountKey)
        #expect(try replaced.assessed().acts.contains(.follow(.keysReplaced, typesOneSecret: true, holdsLibraryRekey: false)))
    }

    @Test func aVaultReadForAnotherAccountIsNoReadingAtAll() throws {
        let x = PF.id()
        var world = try AWorld(.castle, account: x)
        world.session = .signedIn(accountID: x, email: nil)
        world.vault = AWorld.vault(PF.id(), .standard(appleKeyID: PF.id()))
        let assessed = try world.assessed()
        #expect(assessed.vault == nil && !assessed.account.confirmed)
        #expect(!assessed.acts.contains { if case .follow = $0 { return true } else { return false } })
    }
}

@Suite("VX-305 U2 — assess: the mode, confirmed or not; corner 45; before unlock nothing decides")
struct AssessModeTests {
    /// Corner 45's ambiguous case (P-U1-6's exact shape): local-only, a
    /// passphrase, no Apple wrap, the raw key in the silent item.
    static func corner45() throws -> AWorld {
        var world = try AWorld(.castle)
        world.noRecord = true
        world.legacyInputs = LegacyModeInputs(
            keyFile: LegacyKeyFileFacts(hasAppleWrap: false, hasPassphraseWrap: true), rawKeyCustody: .silent, enrolled: false)
        world.custody = [CustodyItemFact(fingerprint: PF.fp(world.key), itemClass: .silent)]
        world.section.settings = .noChoiceYet
        return world
    }

    @Test func cornerFortyFiveRecordsCastleNotYetConfirmedAndRepairsNothing() throws {
        let assessed = try Self.corner45().assessed()
        #expect(assessed.mode.mode == .castle && !assessed.mode.confirmed && assessed.mode.corner45)
        #expect(assessed.acts.contains(.corner45Notice))
        #expect(!assessed.repairs.contains { if case .deleteSilentItem = $0 { return true } else { return false } },
                "no custody repair until the notice is answered")
        #expect(assessed.door(.useStandard).spec?.rekeys == true, "Use Standard offered as the key change it now is")
        #expect(assessed.door(.useCastle).refusal == .modeNotConfirmed)
    }

    @Test func answeringCornerFortyFiveStandardIsAKeyChange() throws {
        var world = try Self.corner45()
        world.corner45Answer = .standard
        #expect(try world.assessed().acts.contains(.confirmMode(.standard, isKeyChange: true)))
        world.corner45Answer = .castle
        #expect(try world.assessed().acts.contains(.confirmMode(.castle, isKeyChange: false)))
    }

    @Test func aSyncedUnconfirmedModeWaitsForTheVault() throws {
        let x = PF.id()
        var world = try AWorld(.standard, account: x)
        world.confirmed = false
        world.session = .signedIn(accountID: x, email: nil)
        let waiting = try world.assessed()
        #expect(!waiting.acts.contains { if case .confirmMode = $0 { return true } else { return false } })
        #expect(!waiting.repairs.contains { if case .landAppleWrap = $0 { return true } else { return false } },
                "indeterminate writes nothing Apple-reachable")
        world.vault = AWorld.vault(x, .castle)
        #expect(try world.assessed().acts.contains(.confirmMode(.castle, isKeyChange: true)),
                "confirming a mode the current key wasn't born in is a key change, never a move")
    }

    @Test func beforeUnlockNothingDecides() throws {
        var world = try AWorld(.castle)
        world.unlocked = false
        let assessed = try world.assessed()
        #expect(assessed.launch == .lobby)
        #expect(assessed.mode == ModeVerdict(mode: .castle, confirmed: false, source: .hintOnly, corner45: false))
        #expect(assessed.repairs.isEmpty && assessed.acts.isEmpty && assessed.faults.isEmpty)
        #expect(assessed.doors.values.allSatisfy { $0 == .refused(.locked) })
        // The roads: the Touch ID item, the typed secrets.
        #expect(assessed.touchID.button)
        #expect(assessed.lobby.typed.openers == [.passphrase(.current), .words(.current)])
    }

    @Test func aMissingLibraryIsMissingInBothModesAndAFreshStartIsNot() throws {
        for mode in ProtectionMode.allCases {
            var world = try AWorld(mode)
            world.unlocked = false
            var facts = try world.facts()
            facts.storeFile = .absent
            #expect(assess(facts).launch == .libraryMissing)
            facts.containerMarker = false
            #expect(assess(facts).launch == .startFresh)
        }
    }

    @Test func theLobbysAutomaticRoadsAreEveryItemThatAsksNothing() throws {
        var world = try AWorld(.standard)
        world.unlocked = false
        let stray = PF.fp(StoreKey.mint())
        world.custody.append(CustodyItemFact(fingerprint: stray, itemClass: .silent))
        let lobby = try world.assessed().lobby
        // Every silent item, whatever fingerprint it names; the Apple wrap readable here.
        #expect(lobby.automatic.contains { $0.steps == [.custody(fingerprint: stray, itemClass: .silent)] })
        #expect(lobby.automatic.contains { $0.opener == .appleAccount })
        #expect(!lobby.vaultRoad)
    }
}

@Suite("VX-305 U2 — assess: the Touch ID road, VX-310's lobby rule as data (§3.10)")
struct AssessTouchIDTests {
    @Test func theButtonIsThereWheneverAnItemExists() throws {
        var world = try AWorld(.castle)
        world.unlocked = false
        var touchID = try world.assessed().touchID
        #expect(touchID.button && touchID.autoAsk && touchID.quietLine == nil)
        // Only for now unusable: the button stays, pressing says why, nothing changes.
        world.biometry.transient = .lidClosed
        touchID = try world.assessed().touchID
        #expect(touchID.button && !touchID.autoAsk && touchID.pressSays == .lidClosed)
    }

    @Test func withNoItemOrNoFingerThereIsALineAndNoButton() throws {
        var world = try AWorld(.castle)
        world.unlocked = false
        world.custody = []
        #expect(try world.assessed().touchID.quietLine == .notSetUpForThisLibrary)
        world.custody = [CustodyItemFact(fingerprint: PF.fp(world.key), itemClass: .touchid)]
        world.biometry = BiometryFacts(hardware: true, enrolled: false)
        let noFinger = try world.assessed().touchID
        #expect(!noFinger.button && noFinger.quietLine == .notSetUpOnThisMac)
        world.biometry = .none
        #expect(try world.assessed().touchID.quietLine == .notSetUpOnThisMac)
    }

    @Test func aPressThatFailsOnAnExistingItemShowsTheChangedLineThenTheReArmQuestion() throws {
        var world = try AWorld(.castle)
        world.unlocked = false
        world.press = .failedOnExistingItem
        let lobby = try world.assessed().touchID
        #expect(lobby.changedLine && !lobby.rearmQuestion, "the question follows the passphrase's unlock")
        world.unlocked = true
        let opened = try world.assessed()
        #expect(opened.touchID.rearmQuestion && opened.acts.contains(.touchIDRearmQuestion))
    }

    @Test func aTouchIDChoiceWithNoItemRecordsAlwaysAskQuietlyAndAsksNothing() throws {
        var world = try AWorld(.castle)
        world.custody = []
        let assessed = try world.assessed()
        #expect(assessed.repairs.contains(.recordAlwaysAskQuietly))
        #expect(!assessed.touchID.rearmQuestion && !assessed.acts.contains(.touchIDRearmQuestion))
        #expect(!assessed.repairs.contains { if case .makeTouchIDItem = $0 { return true } else { return false } })
    }

    /// The stored hash moved with nothing changed (a macOS update): the button
    /// stays, a press opens — no failed press, nothing asked.
    @Test func aMovedHashChangesNothing() throws {
        var world = try AWorld(.castle)
        let assessed = try world.assessed()
        #expect(assessed.touchID.button && !assessed.touchID.changedLine && !assessed.touchID.rearmQuestion)
        world.press = .cancelled
        #expect(!(try world.assessed().touchID.rearmQuestion))
    }

    /// A new device identity starts on Always ask: nothing is recorded, no
    /// item is made, nothing is asked.
    @Test func aNewDeviceIdentityStartsOnAlwaysAsk() throws {
        var world = try AWorld(.castle)
        world.section = DeviceFacts.takingOver(
            predecessor: world.section, allSections: [world.section], newDeviceID: PF.id(), marker: "new",
            keyFileOwnAppleKeyIDs: [])
        world.custody = []
        #expect(world.section.settings.gateStyle == .alwaysAsk)
        let assessed = try world.assessed()
        #expect(!assessed.repairs.contains(.recordAlwaysAskQuietly) && !assessed.touchID.rearmQuestion)
    }
}

@Suite("VX-305 U2 — assess: §3.3's repairs, guards included")
struct AssessRepairTests {
    @Test func inCastleNoSilentItemForAnyKeyTheLibraryHasHad() throws {
        let older = StoreKey.mint(), lost = StoreKey.mint()
        var world = try AWorld(.castle, history: [older])
        world.tree = world.tree.seeding([PF.fp(lost)])
        world.custody += [
            CustodyItemFact(fingerprint: PF.fp(world.key), itemClass: .silent),
            CustodyItemFact(fingerprint: PF.fp(older), itemClass: .silent),
            CustodyItemFact(fingerprint: PF.fp(lost), itemClass: .silent),
        ]
        let assessed = try world.assessed()
        #expect(assessed.repairs.contains(.deleteSilentItem(fingerprint: PF.fp(world.key), precondition: .currentKeyHasTypedRoad)))
        #expect(assessed.repairs.contains(.deleteSilentItem(fingerprint: PF.fp(older), precondition: .historyHolds(fingerprint: PF.fp(older)))))
        #expect(assessed.faults.contains(.silentItemIsOnlyRoad(fingerprint: PF.fp(lost))),
                "a key the history doesn't hold keeps its road")
        #expect(!assessed.repairs.contains { if case .deleteSilentItem(let fp, _) = $0 { return fp == PF.fp(lost) } else { return false } })
    }

    @Test func inCastleTodaysItemsAndKeyFilesGoOnceTheHistoryHoldsTheirKey() throws {
        let older = StoreKey.mint(), unreached = StoreKey.mint()
        var world = try AWorld(.castle, history: [older])
        world.tree = world.tree.seeding([PF.fp(unreached)])
        let bound = LegacyItemFact.Kind.silent(account: LegacyItems.boundAccount(scope: AWorld.scope, libraryID: world.world.library))
        let escrow = LegacyItemFact.Kind.escrow(libraryID: world.world.library)
        let gated = LegacyItemFact.Kind.gated(account: LegacyItems.gatedAccount(scope: AWorld.scope, libraryID: world.world.library))
        world.legacyItems = [LegacyItemFact(kind: bound, fingerprint: PF.fp(older)),
                             LegacyItemFact(kind: escrow, fingerprint: PF.fp(older)),
                             LegacyItemFact(kind: gated, fingerprint: nil)]
        world.extraEntries = [
            CatalogEntry(place: .container, name: StoreKeyEnvelope.filename(forFingerprint: PF.fp(older)),
                         bytes: try CF.format2(library: world.world.library, key: older)),
            CatalogEntry(place: .container, name: StoreKeyEnvelope.filename(forFingerprint: PF.fp(unreached)),
                         bytes: try CF.format2(library: world.world.library, key: unreached)),
        ]
        let assessed = try world.assessed()
        let precondition = RepairPrecondition.historyHolds(fingerprint: PF.fp(older))
        #expect(assessed.repairs.contains(.deleteLegacyItem(bound, fingerprint: PF.fp(older), precondition: precondition)))
        #expect(assessed.repairs.contains(.deleteLegacyItem(escrow, fingerprint: PF.fp(older), precondition: precondition)))
        #expect(!assessed.repairs.contains { if case .deleteLegacyItem(.gated, _, _) = $0 { return true } else { return false } })
        let olderFile = Catalog.id(place: .container, folders: [], name: StoreKeyEnvelope.filename(forFingerprint: PF.fp(older)))
        let unreachedFile = Catalog.id(place: .container, folders: [], name: StoreKeyEnvelope.filename(forFingerprint: PF.fp(unreached)))
        #expect(assessed.repairs.contains(.deleteLegacyKeyFile(keyFileID: olderFile, precondition: precondition)))
        #expect(!assessed.repairs.contains { if case .deleteLegacyKeyFile(unreachedFile, _) = $0 { return true } else { return false } },
                "a key the fold couldn't reach keeps its file: it's that copy's only road")
    }

    @Test func anAppleWrapOnACastleKeyIsAFaultTheReKeyAnswers() throws {
        var world = try AWorld(.castle)
        world.liveFile = try world.liveFile.settingApple(AppleKeyMaterial.mint(), for: world.key)
        let assessed = try world.assessed()
        #expect(assessed.faults.contains(.appleWrapOnCastleKey(keyFileID: AWorld.liveKeyFileID)))
        #expect(assessed.acts.contains(.rekeyForFault))
    }

    @Test func deleteOnSightIsByRecordedIDOnly() throws {
        var world = try AWorld(.castle)
        let retired = PF.id(), anotherMacs = PF.id()
        world.section = world.section.retiringAppleKey(id: retired, purpose: .library, origin: .minted, at: PF.t0)
        world.recordSection = world.section
        world.appleKeys.readable = [retired, anotherMacs]
        let assessed = try world.assessed()
        #expect(assessed.repairs.contains(.deleteRetiredAppleKey(id: retired)))
        #expect(!assessed.repairs.contains(.deleteRetiredAppleKey(id: anotherMacs)),
                "another Mac's copy of this library may be in Standard under a key of its own")
    }

    @Test func theOldSharedKeyIsDeletedOnSightOnlyUnderTheIdThisSectionRetired() throws {
        var world = try AWorld(.castle)
        let shared = PF.id()
        world.section.oldSharedKey = OldSharedKeyRecord(id: shared, retiredAt: PF.t0)
        world.recordSection = world.section
        world.appleKeys.oldSharedID = shared
        #expect(try world.assessed().repairs.contains(.deleteRetiredOldSharedKey(id: shared)))
        // An older build minted a new old-name item later: a new id, left alone.
        world.appleKeys.oldSharedID = PF.id()
        #expect(!(try world.assessed().repairs.contains { if case .deleteRetiredOldSharedKey = $0 { return true } else { return false } }))
    }

    @Test func inStandardTheWrapLandsUnderThisMacsOwnKeyAndNoRepairMintsOne() throws {
        var world = try AWorld(.standard)
        world.liveFile = world.liveFile.droppingApple()
        #expect(try world.assessed().repairs.contains(.landAppleWrap(appleKeyID: world.own.id)))
        // The own key can't be read here (iCloud Keychain reset, another Apple
        // ID): the Apple road is lost — Re-link's library arm, never a mint.
        world.appleKeys.readable = []
        let lost = try world.assessed()
        #expect(!lost.repairs.contains { if case .landAppleWrap = $0 { return true } else { return false } })
        #expect(lost.faults.contains(.appleRoadLost(keyFileID: AWorld.liveKeyFileID)))
        #expect(lost.acts.contains(.relinkLibraryArm(keyFileIDs: [AWorld.liveKeyFileID])))
        #expect(lost.door(.relinkLibraryArm).isOpen)
    }

    @Test func decision35ASyncedLibraryWritesNothingAppleReachableWithoutAFreshVault() throws {
        let x = PF.id()
        var world = try AWorld(.standard, account: x)
        world.liveFile = world.liveFile.droppingApple()
        world.session = .signedIn(accountID: x, email: nil)
        #expect(!(try world.assessed().repairs.contains(.landAppleWrap(appleKeyID: world.own.id))))
        world.vault = AWorld.vault(x, .standard(appleKeyID: PF.id()))
        #expect(try world.assessed().repairs.contains(.landAppleWrap(appleKeyID: world.own.id)))
    }

    @Test func inStandardNothingDestructiveRunsOnTheRecordsWordAlone() throws {
        var world = try AWorld(.standard)
        let stray = PF.fp(StoreKey.mint())
        world.custody.append(CustodyItemFact(fingerprint: stray, itemClass: .touchid))
        let assessed = try world.assessed()
        #expect(assessed.faults.contains(.touchIDItemInStandard(fingerprint: stray)))
        #expect(!assessed.repairs.contains(.deleteTouchIDItem(fingerprint: stray)))
    }

    /// No repair ever makes a Touch ID item or changes a key's kind: across
    /// every shape here, the repairs only delete, land a wrap under an
    /// existing key, refresh the two homes, or record Always ask.
    @Test func noRepairMakesATouchIDItemOrChangesAKeysKind() throws {
        var shapes: [AWorld] = []
        for mode in ProtectionMode.allCases {
            var world = try AWorld(mode)
            world.custody = []
            world.memoryAbsent = true
            shapes.append(world)
            var second = try AWorld(mode, history: [StoreKey.mint()])
            second.custody.append(CustodyItemFact(fingerprint: PF.fp(second.key), itemClass: mode == .castle ? .silent : .touchid))
            shapes.append(second)
        }
        shapes.append(try AssessModeTests.corner45())
        for world in shapes {
            for repair in try world.assessed().repairs {
                switch repair {
                case .makeTouchIDItem, .deleteTouchIDItem:
                    Issue.record("\(repair) — a guard's bug shape with every guard on")
                case .deleteSilentItem, .deleteLegacyItem, .deleteLegacyKeyFile, .deleteRetiredAppleKey,
                     .deleteRetiredOldSharedKey, .landAppleWrap, .refreshMemory, .refreshRecordSection, .recordAlwaysAskQuietly:
                    continue
                }
            }
        }
    }

    @Test func theTwoHomesAreRefreshedWhenEitherIsBehind() throws {
        var world = try AWorld(.castle)
        #expect(!(try world.assessed().repairs.contains(.refreshMemory)))
        world.memoryAbsent = true
        #expect(try world.assessed().repairs.contains(.refreshMemory))
        world.memoryAbsent = false
        world.recordSection = world.section.bumped()
        #expect(try world.assessed().repairs.contains(.refreshRecordSection))
    }

    @Test func aSilentSyncKeysItemWhileTheyReachACastleEraKeyIsReported() throws {
        let x = PF.id()
        var world = try AWorld(.castle, account: x)
        world.session = .signedIn(accountID: x, email: nil)
        world.vault = AWorld.vault(x, .castle)
        world.syncKeys = [SyncKeysItemFact(accountID: x, itemClass: .silent)]
        #expect(try world.assessed().faults.contains(.silentSyncKeysWhileCastleWay(account: x)))
    }
}

@Suite("VX-305 U2 — assess: the doors, with their reasons")
struct AssessDoorTests {
    @Test func useCastleRetiresEveryOwnKeyAndNamesWhatItCantDelete() throws {
        var world = try AWorld(.standard)
        let relinked = PF.id(), adopted = PF.id(), formerAppleID = PF.id()
        world.section = world.section
            .recordingAppleKey(AppleKeyRecord(id: relinked, purpose: .library, origin: .minted))
            .recordingAppleKey(AppleKeyRecord(id: adopted, purpose: .library, origin: .adopted))
            .recordingAppleKey(AppleKeyRecord(id: formerAppleID, purpose: .library, origin: .minted))
            .recordingAppleKey(AppleKeyRecord(id: PF.id(), purpose: .account, accountID: PF.id(), origin: .followed))
        world.section.settings.scheduledExport = true
        world.recordSection = world.section
        world.appleKeys.readable = [world.own.id, relinked, adopted]
        // A copy under the key left in a former Apple ID.
        let copyKey = StoreKey.mint()
        let copyFile = try KeyFile.building(libraryID: world.world.library, key: copyKey, epoch: 1,
                                            locks: NewKeyLocks(apple: AppleKeyMaterial(id: formerAppleID, key: SymmetricKey(size: .bits256))))
        let folders = CF.macFolder(world.world.library, CF.macA)
        world.extraEntries = [
            CatalogEntry(place: .container, folders: folders, name: CF.snapshotName(CF.stamp(1), copyKey)),
            CatalogEntry(place: .container, folders: folders, name: CF.pairName(CF.stamp(1), copyKey), bytes: try copyFile.encoded()),
        ]
        let spec = try #require(try world.assessed().door(.useCastle).spec)
        #expect(Set(spec.retiresOwnAppleKeys) == [world.own.id, relinked, adopted, formerAppleID],
                "every own key this Mac's section lists — never the account's")
        #expect(spec.rekeys && spec.requires == .passphraseAndWords(wordsMayBeNew: true))
        #expect(spec.words.contains(.floorSentence) && spec.words.contains(.exportAPlainCopyFirst))
        #expect(spec.words.contains(.scheduledExportTurnsOff))
        let catalog = Catalog.build(try world.entries())
        #expect(spec.words.contains(.copiesUnderAKeyThisMacCantDelete([catalog.copies[0].id])))
    }

    @Test func useStandardTypesTheWordsNeverMakesNewOnesAndSaysRuleFive() throws {
        let spec = try #require(try AWorld(.castle).assessed().door(.useStandard).spec)
        #expect(spec.requires == .passphraseAndWords(wordsMayBeNew: false) && spec.rekeys)
        #expect(spec.words == [.ruleFive])
        #expect(try AWorld(.castle).assessed().door(.useCastle).refusal == .wrongMode(.castle))
    }

    @Test func replaceAllKeysOnAnAccountStillOnTheOldSharedKeyReLinksFirst() throws {
        let x = PF.id(), shared = PF.id()
        var world = try AWorld(.standard, account: x)
        world.session = .signedIn(accountID: x, email: nil)
        world.vault = AWorld.vault(x, .standard(appleKeyID: shared))
        world.appleKeys.oldSharedID = shared
        #expect(try world.assessed().door(.replaceAllKeys).spec?.relinksAccountFirst == true)
        #expect(try AWorld(.standard).assessed().door(.replaceAllKeys).refusal == .notSynced)
    }

    @Test func theKeyDoorsSayTheirAnchorSentenceWhileAnAnchorExists() throws {
        let leave = try LeaveWorld()
        var world = try AWorld(.standard)
        world.key = leave.standardKey
        world.liveFile = leave.standardFile
        world.custody = [CustodyItemFact(fingerprint: PF.fp(leave.standardKey), itemClass: .silent)]
        world.appleKeys.readable = [leave.apple.id]
        let assessed = try world.assessed()
        func sentence(_ door: Door) -> AnchorSentence? {
            assessed.door(door).spec?.words.compactMap { if case .anchor(let s) = $0 { return s } else { return nil } }.first
        }
        #expect(sentence(.newWords)?.door == .replacesWords)
        #expect(sentence(.changePassphrase)?.replacedSecretOpensIt == true)
        #expect(sentence(.resetForgottenPassphrase)?.stillOpensWith == [.words(.of(leave.leaveDay))])
        #expect(assessed.door(.resetForgottenPassphrase).spec?.requires == .plainConfirm)
        #expect(try AWorld(.castle).assessed().door(.resetForgottenPassphrase).spec?.requires == .touchIDOrWords)
    }

    @Test func aFinishDoorNamesTheLeaveALostDeviceStarted() throws {
        let named = PF.id()
        var world = try AssessVaultTests.synced(.standard, vault: .leavingCastle(appleKeyID: named), readable: [named]).0
        world.section.actInFlight = nil
        let assessed = try world.assessed()
        #expect(assessed.vault?.unfinishedLeave == UnfinishedLeave(
            device: "Lillian's Air", day: CF.stamp(9), namedAppleKeyID: named, namedKeyReadableHere: true))
        #expect(assessed.door(.finishLeavingCastle).isOpen)
    }
}

@Suite("VX-305 U2 — assess: the old shared key's checks at the door, and the move's subjects (§3.5)")
struct AssessOldSharedKeyTests {
    /// A vault it can read, or the library's former account, still on the old
    /// key — other than the act's own account — stops Use Castle at its door.
    @Test func aVaultOnTheOldKeyStopsUseCastleUnlessItIsTheActsOwn() throws {
        let x = PF.id(), shared = PF.id()
        var world = try AWorld(.standard, account: x)
        world.session = .signedIn(accountID: x, email: nil)
        world.vault = AWorld.vault(x, .standard(appleKeyID: shared))
        world.appleKeys.oldSharedID = shared
        #expect(try world.assessed().door(.useCastle).isOpen, "the account this very act moves into Castle")
        // This-Mac-Only Castle: the account stays — and on the old key, it stops.
        world.section.oldSharedKey = OldSharedKeyRecord(id: shared)
        world.section = world.section.recordingAppleKey(AppleKeyRecord(id: shared, purpose: .account, accountID: x, origin: .followed))
        world.recordSection = world.section
        world.session = .signedOut
        world.vault = nil
        let checks = try #require(try world.assessed().retirement)
        #expect(checks.doorStops == [x] && checks.uncheckedAccounts == [x])
    }

    @Test func aLibraryAlreadyInCastleGetsOneAskAndADoor() throws {
        var world = try AWorld(.castle)
        world.section.oldSharedKey = OldSharedKeyRecord(id: PF.id())
        world.recordSection = world.section
        let assessed = try world.assessed()
        #expect(assessed.acts.contains(.retireOldSharedKeyAsk))
        #expect(assessed.door(.retireOldSharedKey).spec?.retiresOldSharedKey == true)
        var dismissed = world.agreeingMemory
        dismissed.nudgeDismissals[AssessRules.retireOldSharedKeyNudge] = PF.t0
        world.memory = dismissed
        let later = try world.assessed()
        #expect(!later.acts.contains(.retireOldSharedKeyAsk) && later.door(.retireOldSharedKey).isOpen,
                "asked once; the door stays in Settings")
    }

    /// The move gives keys of this Mac's own beside the old one — to other
    /// libraries whose newest copy here is Standard, never for copies the
    /// catalog can't attribute to this Mac.
    @Test func theMovesGiftsAreOnlyForThisMacsCopies() throws {
        var world = try AWorld(.standard)
        world.liveFile = world.liveFile.droppingApple()
        let shared = AppleKeyMaterial.mint()
        func pair(_ library: String, mac: String, place: CatalogPlace, day: Double, standard: Bool) throws -> [CatalogEntry] {
            let key = StoreKey.mint()
            var file = try KeyFile.building(libraryID: library, key: key, epoch: 1, locks: NewKeyLocks(passphrase: world.world.p))
            if standard {
                file.sharedApple = AppleWrap(keyID: shared.id, wrapped: try AES.KeyWrap.wrap(SymmetricKey(data: key.data), using: shared.key))
            }
            let folders = CF.macFolder(library, mac)
            return [CatalogEntry(place: place, folders: folders, name: CF.snapshotName(CF.stamp(day), key)),
                    CatalogEntry(place: place, folders: folders, name: CF.pairName(CF.stamp(day), key), bytes: try file.encoded())]
        }
        let mine = PF.id(), castleNow = PF.id(), theirs = PF.id()
        world.extraEntries = try pair(mine, mac: CF.macA, place: .container, day: 1, standard: true)
            + pair(castleNow, mac: CF.macA, place: .farFolder, day: 1, standard: true)
            + pair(castleNow, mac: CF.macA, place: .farFolder, day: 2, standard: false)
            + pair(theirs, mac: CF.macB, place: .farFolder, day: 1, standard: true)
        let plan = try world.assessed().movePlan
        #expect(plan.otherLibraries == [mine], "newest Castle: no gift; another Mac's: no gift")
        #expect(plan.liveLibrary, "the live Standard library gains this Mac's own key")
    }
}
