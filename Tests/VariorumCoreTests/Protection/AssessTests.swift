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

    /// No leave re-keys, in either mode (rule 16 — superseding her round-2
    /// ruling's "every leave re-keys").
    @Test func noLeaveReKeysOrAsksASecretInEitherMode() throws {
        for mode in ProtectionMode.allCases {
            let x = PF.id()
            var world = try AWorld(mode, account: x)
            world.session = .signedIn(accountID: x, email: nil)
            world.vault = AWorld.vault(x, mode == .castle ? .castle : .standard(appleKeyID: PF.id()))
            let assessed = try world.assessed()
            for door in [Door.thisMacOnly, .stopSyncingHere, .deleteAccountHere] {
                let spec = try #require(assessed.door(door).spec, "\(mode) \(door)")
                // Rule 16: no leave changes a key or a secret, so none asks
                // for one (PROVISIONAL P-VX378-U1-2).
                #expect(!spec.rekeys, "\(mode) \(door) re-keys")
                #expect(spec.requires == SecretRequirement.none)
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

    /// A wrap reads Standard; no wrap reads Castle — an id with no wrap
    /// included (the leave's third state left with VX-378 U1, rule 12).
    @Test func aWrapReadsStandardNoWrapReadsCastle() throws {
        let id = PF.id()
        #expect(AWorld.vault("a", .standard(appleKeyID: id)).mode == .standard(appleKeyID: id))
        #expect(AWorld.vault("a", .castle).mode == .castle)
        #expect(VaultReading(accountID: "a", hasAppleWrap: false, appleKeyID: id).mode == .castle)
        #expect(!VaultReading(accountID: "a", hasAppleWrap: false, appleKeyID: id).rotationInProgress)
        #expect(AWorld.vault("a", .castle, previous: "c0").rotationInProgress)
        #expect(!AWorld.vault("a", .castle).rotationInProgress)
    }

    /// A leave's rotation in progress reads Standard from its first write
    /// (the wrap written at once — rule 12): the follower holds its re-key,
    /// its sync keys held the account's way (rule 15's custody).
    @Test func aFollowerThatSeesALeavesRotationHoldsItsReKey() throws {
        let (world, _) = try Self.synced(.castle, vault: .standard(appleKeyID: PF.id()), previous: "c0")
        let assessed = try world.assessed()
        #expect(assessed.acts.contains(.follow(.intoStandard, typesOneSecret: true, holdsLibraryRekey: true)))
        let vault = try #require(assessed.vault)
        #expect(vault.syncKeysCustody == .silent, "custody by the account's mode, never by what the keys reach")
        #expect(assessed.door(.followNow).spec?.requires == .oneSecret, "every follow out of Castle types one secret")
        #expect(assessed.door(.useCastle).refusal == .followOwed)
    }

    @Test func aRotationWithNoIdCompletesWithoutAnAppleCopy() throws {
        let (world, _) = try Self.synced(.castle, vault: .castle, previous: "c0")
        let assessed = try world.assessed()
        let vault = try #require(assessed.vault)
        #expect(vault.completesWithoutAppleCopy)
        #expect(assessed.door(.replaceAllKeys).refusal == .rotationInProgress(device: "Lillian's Air", day: CF.stamp(9)),
                "decision 32: one rotation at a time, the device and day named")
    }

    @Test func syncKeysAreHeldByTheAccountsMode() throws {
        #expect(try Self.synced(.castle, vault: .castle).0.assessed().vault?.syncKeysCustody == .castleWay)
        #expect(try Self.synced(.standard, vault: .standard(appleKeyID: PF.id())).0.assessed().vault?.syncKeysCustody == .silent)
        #expect(try Self.synced(.castle, vault: .standard(appleKeyID: PF.id()), previous: "c0").0.assessed()
            .vault?.syncKeysCustody == .silent)
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

    /// This device's own leave, mid-way: its plan finishes it — never read as
    /// the account moving elsewhere.
    @Test func thisDevicesOwnActInFlightIsNotAFollow() throws {
        var world = try Self.synced(.castle, vault: .standard(appleKeyID: PF.id()), previous: "c0").0
        world.section = world.section.beginningAct(.leaveCastle, from: PF.fp(world.key), to: nil, at: PF.t0).section
        let assessed = try world.assessed()
        #expect(!assessed.acts.contains { if case .follow = $0 { return true } else { return false } })
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

@Suite("VX-305 U2 — assess: before unlock nothing decides (the mode's confirmed-or-not and corner 45 left with rule 26)")
struct AssessModeTests {
    @Test func beforeUnlockNothingDecides() throws {
        var world = try AWorld(.castle)
        world.unlocked = false
        let assessed = try world.assessed()
        #expect(assessed.launch == .lobby)
        #expect(assessed.mode == ModeVerdict(mode: .castle, source: .hintOnly))
        #expect(assessed.repairs.isEmpty && assessed.acts.isEmpty && assessed.faults.isEmpty)
        #expect(assessed.doors.values.allSatisfy { $0 == .refused(.locked) })
        // The roads: the Touch ID item, the typed secrets.
        #expect(assessed.touchID.button)
        #expect(assessed.lobby.typed == [.passphrase, .words])
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
        #expect(lobby.silentItems.contains(CustodyItemFact(fingerprint: stray, itemClass: .silent)))
        #expect(lobby.appleKeyID == world.own.id)
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

}

@Suite("VX-305 U2 — assess: §3.3's repairs, guards included")
struct AssessRepairTests {
    @Test func inCastleNoSilentItemForAnyKeyTheLibraryHasHad() throws {
        let older = StoreKey.mint(), lost = StoreKey.mint()
        var world = try AWorld(.castle, history: [older])
        world.custody += [
            CustodyItemFact(fingerprint: PF.fp(world.key), itemClass: .silent),
            CustodyItemFact(fingerprint: PF.fp(older), itemClass: .silent),
            CustodyItemFact(fingerprint: PF.fp(lost), itemClass: .silent),
        ]
        let assessed = try world.assessed()
        #expect(assessed.repairs.contains(.deleteSilentItem(fingerprint: PF.fp(world.key), precondition: .currentKeyHasTypedRoad)))
        #expect(assessed.repairs.contains(.deleteSilentItem(fingerprint: PF.fp(older), precondition: .historyHolds(fingerprint: PF.fp(older)))))
        // A key the key file doesn't list is no key the library has had (rule 4
        // — the family tree, which could name one, left with VX-378 U1): its
        // item is neither deleted nor reported.
        #expect(!assessed.faults.contains(.silentItemIsOnlyRoad(fingerprint: PF.fp(lost))))
        #expect(!assessed.repairs.contains { if case .deleteSilentItem(let fp, _) = $0 { return fp == PF.fp(lost) } else { return false } })
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
        world.appleKeys.readable = [retired, anotherMacs]
        let assessed = try world.assessed()
        #expect(assessed.repairs.contains(.deleteRetiredAppleKey(id: retired)))
        #expect(!assessed.repairs.contains(.deleteRetiredAppleKey(id: anotherMacs)),
                "another Mac's copy of this library may be in Standard under a key of its own")
    }

    @Test func inStandardTheWrapLandsUnderThisMacsOwnKeyAndNoRepairMintsOne() throws {
        var world = try AWorld(.standard)
        world.liveFile = world.liveFile.droppingApple()
        #expect(try world.assessed().repairs.contains(.landAppleWrap(appleKeyID: world.own.id)))
        // The own key can't be read here (iCloud Keychain reset, another Apple
        // ID): the Apple road is lost — reported, never a mint (Re-link left
        // with VX-378 U1; rule 8's quiet re-make is U2's).
        world.appleKeys.readable = []
        let lost = try world.assessed()
        #expect(!lost.repairs.contains { if case .landAppleWrap = $0 { return true } else { return false } })
        #expect(lost.faults.contains(.appleRoadLost(keyFileID: AWorld.liveKeyFileID)))
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
        for world in shapes {
            for repair in try world.assessed().repairs {
                switch repair {
                case .makeTouchIDItem, .deleteTouchIDItem:
                    Issue.record("\(repair) — a guard's bug shape with every guard on")
                case .deleteSilentItem, .deleteRetiredAppleKey, .landAppleWrap, .refreshMemory,
                     .restoreKeyFileFromMirror, .recordAlwaysAskQuietly, .recordHeldSyncKeysFacts, .retireOwnAppleKeys:
                    continue
                }
            }
        }
    }

    /// What this Mac remembers names the current key and this Mac's device ID
    /// (rule 21): an absent item, or one naming another device ID, is
    /// refreshed. (The second home's refresh left with VX-378 U1.)
    @Test func whatThisMacRemembersIsRefreshedWhenItIsMissingOrNamesAnotherDevice() throws {
        var world = try AWorld(.castle)
        #expect(!(try world.assessed().repairs.contains(.refreshMemory)))
        world.memoryAbsent = true
        #expect(try world.assessed().repairs.contains(.refreshMemory))
        world.memoryAbsent = false
        var other = world.agreeingMemory
        other.deviceID = PF.id()
        world.memory = other
        #expect(try world.assessed().repairs.contains(.refreshMemory))
    }

    /// The key file and the sealed mirror (rule 1): the mirror is written back
    /// ONLY into an empty live place; a present file is never rewritten from
    /// it (rule 21 — VX-378 U1); a file that changed a wrap (a key door) is
    /// followed by the mirror.
    @Test func theMirrorIsWrittenBackOnlyIntoAnEmptyLivePlace() throws {
        var world = try AWorld(.castle)
        var memory = world.agreeingMemory
        memory.keyFileMirror = world.liveFile
        world.memory = memory
        #expect(!(try world.assessed().repairs.contains(.restoreKeyFileFromMirror)))
        #expect(!(try world.assessed().repairs.contains(.refreshMemory)))
        // A words wrap removed from the file: NOT written back (rule 21).
        var stripped = world.liveFile
        stripped.words = nil
        let full = world.liveFile
        world.liveFile = stripped
        #expect(!(try world.assessed().repairs.contains(.restoreKeyFileFromMirror)))
        // The passphrase changed by a key door: the mirror follows.
        world.liveFile = try full.settingPassphrase(try PF.passphraseKey("changed"), for: world.key)
        let changed = try world.assessed().repairs
        #expect(changed.contains(.refreshMemory) && !changed.contains(.restoreKeyFileFromMirror))
        // The file deleted: written back.
        var noFile = try AWorld(.castle)
        var mirrored = noFile.agreeingMemory
        mirrored.keyFileMirror = noFile.liveFile
        noFile.memory = mirrored
        var facts = try noFile.facts()
        facts.catalog = Catalog()
        #expect(assess(facts).repairs.contains(.restoreKeyFileFromMirror))
    }

    /// One Apple key per library per Mac and one per account: the library's
    /// wrap lands only under this Mac's own key for it — never the account's.
    @Test func theLibraryWrapNeverLandsUnderTheAccountsKey() throws {
        var world = try AWorld(.standard)
        world.liveFile = world.liveFile.droppingApple()
        let accountKey = PF.id()
        world.section = DeviceSection(
            deviceID: CF.macA, settings: DeviceSettings(gateStyle: nil),
            appleKeys: [AppleKeyRecord(id: accountKey, purpose: .account, accountID: PF.id(), origin: .followed)])
        world.appleKeys.readable = [accountKey]
        let assessed = try world.assessed()
        #expect(!assessed.repairs.contains { if case .landAppleWrap = $0 { return true } else { return false } })
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
        let relinked = PF.id(), minted = PF.id(), formerAppleID = PF.id()
        world.section = world.section
            .recordingAppleKey(AppleKeyRecord(id: relinked, purpose: .library, origin: .minted))
            .recordingAppleKey(AppleKeyRecord(id: minted, purpose: .library, origin: .minted))
            .recordingAppleKey(AppleKeyRecord(id: formerAppleID, purpose: .library, origin: .minted))
            .recordingAppleKey(AppleKeyRecord(id: PF.id(), purpose: .account, accountID: PF.id(), origin: .followed))
        world.section.settings.scheduledExport = true
        world.appleKeys.readable = [world.own.id, relinked, minted]
        // A copy under the key left in a former Apple ID.
        let copyKey = StoreKey.mint()
        let copyFile = try KeyFile.building(libraryID: world.world.library, key: copyKey, epoch: 1,
                                            locks: NewKeyLocks(words: world.world.w, apple: AppleKeyMaterial(id: formerAppleID, key: SymmetricKey(size: .bits256))))
        let folders = CF.macFolder(world.world.library, CF.macA)
        world.extraEntries = [
            CatalogEntry(place: .container, folders: folders, name: CF.snapshotName(CF.stamp(1), copyKey)),
            CatalogEntry(place: .container, folders: folders, name: CF.pairName(CF.stamp(1), copyKey), bytes: try copyFile.encoded()),
        ]
        let spec = try #require(try world.assessed().door(.useCastle).spec)
        #expect(Set(spec.retiresOwnAppleKeys) == [world.own.id, relinked, minted, formerAppleID],
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

    /// The key doors re-lock the current key (rule 6) and, after a leave, say
    /// nothing about copies from before it — the current secrets open them
    /// (rule 4; the anchor sentences left with VX-378 U1).
    @Test func theKeyDoorsAfterALeaveSayNoAnchorSentence() throws {
        let leave = try LeaveWorld()
        var world = try AWorld(.standard)
        world.key = leave.standardKey
        world.liveFile = leave.standardFile
        world.custody = [CustodyItemFact(fingerprint: PF.fp(leave.standardKey), itemClass: .silent)]
        world.appleKeys.readable = [leave.apple.id]
        let assessed = try world.assessed()
        for door in [Door.newWords, .changePassphrase, .resetForgottenPassphrase] {
            #expect(assessed.door(door).spec?.words == [], "\(door)")
        }
        #expect(assessed.door(.resetForgottenPassphrase).spec?.requires == .plainConfirm)
        #expect(try AWorld(.castle).assessed().door(.resetForgottenPassphrase).spec?.requires == .touchIDOrWords)
    }

}
