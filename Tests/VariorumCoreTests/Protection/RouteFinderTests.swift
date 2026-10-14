//
//  RouteFinderTests.swift
//  VariorumCoreTests — VX-305 U2: the route finder. Every road combination,
//  the anchor included — a follower's anchor with each typed secret, and with
//  stale copied locks; the route finder's words agree with the roads it found,
//  and every *Opens with* line names only roads that open (each named opener's
//  witness road is WALKED with the real secret of its day); the anchor
//  sentences of the doors that replace a secret; and the retirement's list —
//  everything that belongs on it, and nothing else.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// The real secrets of each day, for walking a road.
struct SecretBook {
    var passphrases: [SecretDay: String] = [:]
    var words: [SecretDay: [String]] = [:]
    var custody: [String: StoreKey] = [:]
    var apple: [String: AppleKeyMaterial] = [:]
    var oldShared: AppleKeyMaterial?
    var vaultMaster: SymmetricKey?

    func passphrase(_ day: SecretDay) throws -> String { try #require(passphrases[day], "no passphrase for \(day)") }
    func words(_ day: SecretDay) throws -> [String] { try #require(words[day], "no words for \(day)") }
}

enum WalkError: Error { case stuck(String) }

func need<T>(_ value: T?, _ what: @autoclosure () -> String) throws -> T {
    guard let value else { throw WalkError.stuck(what()) }
    return value
}

/// Walk a witness road, lock by lock, with the real secret its opener names;
/// return the key it reaches.
func walk(_ route: Route, in catalog: Catalog, book: SecretBook) throws -> StoreKey {
    var key: StoreKey?
    var opened: AnchorContents?
    func file(_ id: String) throws -> KeyFileDocument {
        try need(catalog.keyFile(id: id)?.document, "no key file \(id)")
    }
    func anchor(_ ref: AnchorRef) throws -> CastleAnchor {
        guard case .format3(let keyFile) = try file(ref.keyFile) else { throw WalkError.stuck("legacy anchor") }
        return try need(ref.kept.map { keyFile.keptAnchors[$0] } ?? keyFile.anchor, "no anchor")
    }
    func secret() throws -> ProtectionSecret {
        switch route.opener {
        case .passphrase(let day): return .passphrase(try need(book.passphrases[day], "no passphrase for \(day)"))
        case .words(let day): return .words(try need(book.words[day], "no words for \(day)"))
        default: throw WalkError.stuck("no secret for \(route.opener)")
        }
    }
    func words() throws -> [String] {
        guard case .words(let words) = try secret() else { throw WalkError.stuck("not the words") }
        return words
    }
    for step in route.steps {
        switch step {
        case .custody(let fingerprint, _):
            key = try need(book.custody[fingerprint], "no custody item")
        case .keyFileLock(let id, let road):
            switch try file(id) {
            case .format3(let keyFile):
                switch road {
                case .passphrase: key = try keyFile.open(try secret(), floor: PF.floor)
                case .words: key = try keyFile.open(words: try words())
                case .masterThroughWords: key = try keyFile.open(wordsThroughMaster: try words())
                case .master: key = try keyFile.open(master: try need(book.vaultMaster, "no master"))
                case .apple:
                    let id = try need(keyFile.apple?.keyID, "no apple wrap")
                    key = try keyFile.open(apple: try need(book.apple[id], "no apple key"))
                case .sharedApple: key = try keyFile.open(sharedApple: try need(book.oldShared, "no shared key"))
                }
            case .legacy(let legacy):
                switch road {
                case .passphrase:
                    guard case .passphrase(let typed) = try secret() else { throw WalkError.stuck("legacy passphrase") }
                    key = try legacy.open(passphrase: typed, floor: PF.floor)
                case .words: key = try legacy.open(words: try words())
                case .sharedApple: key = try legacy.open(sharedApple: try need(book.oldShared, "no shared key"))
                default: throw WalkError.stuck("legacy \(road)")
                }
            }
        case .history(let id, let fingerprint):
            guard case .format3(let keyFile) = try file(id) else { throw WalkError.stuck("legacy history") }
            key = try need(try keyFile.historyKey(fingerprint, currentKey: try need(key, "no key")), "not in history")
        case .anchorLock(let ref, _):
            opened = try anchor(ref).open(try secret(), floor: PF.floor)
        case .anchorOutgoingKey(let ref):
            opened = try anchor(ref).open(outgoingKey: try need(key, "no outgoing key"))
        case .copiedLock(let ref, let road):
            let copied = try need(try anchor(ref).locks.copiedLocks, "no copied locks")
            switch road {
            case .passphrase:
                let wrap = try need(copied.passphrase, "no copied passphrase")
                let wrapping = try need(try secret().passphraseKey(for: wrap.kdf, floor: PF.floor), "no wrapping")
                key = try need(Lock.unwrapStoreKey(wrap.wrapped, under: wrapping), "copied passphrase refused")
            case .words:
                let wrapping = try need(try secret().wordsKey(), "no words key")
                key = try need(Lock.unwrapStoreKey(try need(copied.words, "no copied words"), under: wrapping),
                               "copied words refused")
            case .masterThroughWords:
                let wrapping = try need(try secret().wordsKey(), "no words key")
                let master = try need(Lock.unwrap(try need(copied.masterWordsCopy, "no copy"), under: wrapping), "copy refused")
                key = try need(Lock.unwrapStoreKey(try need(copied.master, "no copied master"),
                                                   under: SymmetricKey(data: master)), "master refused")
            default: throw WalkError.stuck("copied \(road)")
            }
        case .anchorHolds(_, let fingerprint):
            key = try need(try need(opened, "anchor not opened").keys.first { $0.fingerprint == fingerprint }?.key,
                           "anchor doesn't hold it")
        }
    }
    return try need(key, "no key reached")
}

/// Every named opener's witness road opens `fingerprint` (promise 9) — or,
/// for a copy the catalog can't pin, one of its candidate keys.
func expectEveryRoadOpens(_ opens: OpensWith, _ fingerprint: String, _ catalog: Catalog, _ book: SecretBook,
                          orAnyOf candidates: Set<String> = [], sourceLocation: SourceLocation = #_sourceLocation) {
    for route in opens.routes {
        do {
            let key = try walk(route, in: catalog, book: book)
            #expect(PF.fp(key) == fingerprint || candidates.contains(PF.fp(key)),
                    "\(route.opener) reached another key", sourceLocation: sourceLocation)
        } catch {
            Issue.record("\(route.opener) named but does not open: \(error)", sourceLocation: sourceLocation)
        }
    }
}

/// A leave from Castle on the device that presses Use Standard, and the
/// copies from both sides of it.
struct LeaveWorld {
    let world: KeyWorld
    let castleKey = StoreKey.mint(), standardKey = StoreKey.mint()
    let apple = AppleKeyMaterial.mint()
    let newMaster = SymmetricKey(size: .bits256)
    let castleFile: KeyFile
    let anchor: CastleAnchor
    let standardFile: KeyFile
    let day1 = CF.stamp(1), leaveDay = CF.stamp(2), day3 = CF.stamp(3)

    init() throws {
        world = try KeyWorld()
        castleFile = try world.castleFile(castleKey)
        anchor = try CastleAnchor.sealing(
            outgoingKeyFile: castleFile, outgoingKey: castleKey,
            locks: .pressingDevice(passphrase: world.p, words: world.w), madeAt: leaveDay, madeBy: CF.macA)
        let newCopy = try AES.KeyWrap.wrap(newMaster, using: world.w.key)
        standardFile = try castleFile.writingAnchor(anchor).rekeyed(
            .leavingCastle, from: castleKey, to: standardKey,
            locks: NewKeyLocks(passphrase: world.p, words: world.w, master: newMaster, masterWordsCopy: newCopy, apple: apple),
            at: leaveDay).keyFile
    }

    var newRecoveryWrap: Data { get throws { try AES.KeyWrap.wrap(newMaster, using: world.w.key) } }

    func entries(live: KeyFile? = nil) throws -> [CatalogEntry] {
        let folders = CF.macFolder(world.library, CF.macA)
        return [
            CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: try (live ?? standardFile).encoded()),
            CatalogEntry(place: .container, folders: folders, name: CF.snapshotName(day1, castleKey)),
            CatalogEntry(place: .container, folders: folders, name: CF.pairName(day1, castleKey), bytes: try castleFile.encoded()),
            CatalogEntry(place: .container, folders: folders, name: CF.snapshotName(day3, standardKey)),
            CatalogEntry(place: .container, folders: folders, name: CF.pairName(day3, standardKey), bytes: try standardFile.encoded()),
        ]
    }

    func facts(_ catalog: Catalog) throws -> RouteFacts {
        RouteFacts(
            catalog: catalog, custody: [CustodyItemFact(fingerprint: PF.fp(standardKey), itemClass: .silent)],
            readableAppleKeyIDs: [apple.id], vaultRecoveryWrap: try newRecoveryWrap, signedInToVault: true)
    }

    func book(passphraseBeforeLeave: String? = nil) -> SecretBook {
        let before = passphraseBeforeLeave ?? world.passphrase
        var book = SecretBook()
        book.passphrases = [.current: world.passphrase, .of(leaveDay): before,
                            .heldHere(until: day1): before, .heldHere(until: day3): before]
        book.words = [.current: world.words, .of(leaveDay): world.words,
                      .heldHere(until: day1): world.words, .heldHere(until: day3): world.words]
        book.custody = [PF.fp(standardKey): standardKey]
        book.apple = [apple.id: apple]
        book.vaultMaster = newMaster
        return book
    }
}

@Suite("VX-305 U2 — the route finder: every road, and only roads that open")
struct RouteFinderRoadTests {
    /// After a leave, a copy from Castle opens with the passphrase or the
    /// words of the leave's day — through its own frozen file and the anchor —
    /// and through nothing Apple-reachable (promise 13); a copy from after it
    /// opens through the Apple account, this Mac and the current secrets.
    @Test func afterALeaveCastleCopiesOpenWithTheDaysSecretsAndNothingAppleReachable() throws {
        let leave = try LeaveWorld()
        let catalog = Catalog.build(try leave.entries())
        let finder = RouteFinder(try leave.facts(catalog))
        let before = finder.opensWith(fingerprint: PF.fp(leave.castleKey))
        #expect(!before.openers.contains { $0.isApple }, "promise 13: nothing Apple-reachable")
        #expect(!before.openers.contains(.thisMac) && !before.openers.contains(.accountOnline))
        #expect(before.openers.contains(.words(.of(leave.leaveDay))), "the anchor, with the leave day's words")
        #expect(before.openers.contains(.passphrase(.current)), "the passphrase is unchanged since the leave")
        #expect(before.line == [.passphrase(.current), .words(.of(leave.leaveDay))])
        expectEveryRoadOpens(before, PF.fp(leave.castleKey), catalog, leave.book())

        let after = finder.opensWith(fingerprint: PF.fp(leave.standardKey))
        #expect(after.line == [.thisMac, .passphrase(.current), .words(.current), .accountOnline, .appleAccount])
        expectEveryRoadOpens(after, PF.fp(leave.standardKey), catalog, leave.book())
    }

    /// The anchor keeps the secrets of its day: change the passphrase after
    /// the leave, and the Castle copies name the leave day's passphrase.
    @Test func aPassphraseChangedAfterTheLeaveIsNamedByTheLeavesDay() throws {
        let leave = try LeaveWorld()
        let changed = try leave.standardFile.settingPassphrase(try PF.passphraseKey("a new one"), for: leave.standardKey)
        let catalog = Catalog.build(try leave.entries(live: changed))
        let finder = RouteFinder(try leave.facts(catalog))
        let before = finder.opensWith(fingerprint: PF.fp(leave.castleKey))
        #expect(!before.openers.contains(.passphrase(.current)), "the new passphrase opens nothing from before the leave")
        #expect(before.line == [.passphrase(.of(leave.leaveDay)), .words(.of(leave.leaveDay))])
        var book = leave.book()
        book.passphrases[.current] = "a new one"
        expectEveryRoadOpens(before, PF.fp(leave.castleKey), catalog, book)
        // The copy from after the leave: its frozen file keeps the old
        // passphrase (held here then); the live file takes the new one.
        let after = finder.opensWith(fingerprint: PF.fp(leave.standardKey))
        #expect(after.openers.contains(.passphrase(.current)) && after.openers.contains(.passphrase(.heldHere(until: leave.day3))))
        expectEveryRoadOpens(after, PF.fp(leave.standardKey), catalog, book)
    }

    /// A follower that typed the WORDS at its follow, whose file held the
    /// library under a passphrase changed elsewhere and never typed there (a
    /// STALE copied lock): the line names the words of the day and the
    /// passphrase this Mac held — never the leave day's passphrase, which
    /// doesn't open it.
    @Test func aFollowersAnchorWithTheWordsTypedAndAStaleCopiedPassphrase() throws {
        let world = try KeyWorld()
        let stale = try PF.passphraseKey("the one before")
        let castleKey = StoreKey.mint(), standardKey = StoreKey.mint()
        let oldCopy = try AES.KeyWrap.wrap(world.master, using: world.w.key)
        let followerFile = try KeyFile.building(
            libraryID: world.library, key: castleKey, epoch: 1,
            locks: NewKeyLocks(passphrase: stale, words: world.w, master: world.master, masterWordsCopy: oldCopy))
        let leaveDay = CF.stamp(5)
        let anchor = try CastleAnchor.sealing(
            outgoingKeyFile: followerFile, outgoingKey: castleKey,
            locks: .follower(typed: .words(world.w), outgoingKeyFile: followerFile, includeMasterRoad: true),
            madeAt: leaveDay, madeBy: CF.macB)
        let newMaster = SymmetricKey(size: .bits256)
        let newCopy = try AES.KeyWrap.wrap(newMaster, using: world.w.key)
        let apple = AppleKeyMaterial.mint()
        let live = try followerFile.writingAnchor(anchor).rekeyed(
            .leavingCastle, from: castleKey, to: standardKey,
            locks: NewKeyLocks(words: world.w, master: newMaster, masterWordsCopy: newCopy, apple: apple), at: leaveDay).keyFile
        let day1 = CF.stamp(1)
        let folders = CF.macFolder(world.library, CF.macB)
        let catalog = Catalog.build([
            CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: try live.encoded()),
            CatalogEntry(place: .container, folders: folders, name: CF.snapshotName(day1, castleKey)),
            CatalogEntry(place: .container, folders: folders, name: CF.pairName(day1, castleKey), bytes: try followerFile.encoded()),
        ])
        let finder = RouteFinder(RouteFacts(
            catalog: catalog, readableAppleKeyIDs: [apple.id], vaultRecoveryWrap: newCopy, signedInToVault: true))
        let opens = finder.opensWith(fingerprint: PF.fp(castleKey))
        #expect(opens.line == [.passphrase(.heldHere(until: leaveDay)), .words(.of(leaveDay))])
        #expect(!opens.openers.contains(.passphrase(.of(leaveDay))), "the leave day's passphrase is never named")
        #expect(!anchor.opens(with: .passphrase(world.passphrase), floor: PF.floor), "…because it doesn't open it")
        #expect(!opens.openers.contains { $0.isApple })
        var book = SecretBook()
        book.passphrases = [.heldHere(until: leaveDay): "the one before", .heldHere(until: day1): "the one before"]
        book.words = [.of(leaveDay): world.words, .heldHere(until: leaveDay): world.words,
                      .heldHere(until: day1): world.words, .current: world.words]
        expectEveryRoadOpens(opens, PF.fp(castleKey), catalog, book)
    }

    /// A follower that typed the PASSPHRASE: its anchor opens with it (the
    /// birth-time lock), and the live file is locked under the same
    /// derivation, so it reads as the current passphrase until it changes.
    @Test func aFollowersAnchorWithThePassphraseTyped() throws {
        let world = try KeyWorld()
        let castleKey = StoreKey.mint(), standardKey = StoreKey.mint()
        let followerFile = try KeyFile.building(
            libraryID: world.library, key: castleKey, epoch: 1, locks: NewKeyLocks(passphrase: world.p, words: world.w))
        let leaveDay = CF.stamp(5)
        let anchor = try CastleAnchor.sealing(
            outgoingKeyFile: followerFile, outgoingKey: castleKey,
            locks: .follower(typed: .passphrase(world.p), outgoingKeyFile: followerFile, includeMasterRoad: false),
            madeAt: leaveDay, madeBy: CF.macB)
        let live = try followerFile.writingAnchor(anchor).rekeyed(
            .leavingCastle, from: castleKey, to: standardKey, locks: NewKeyLocks(passphrase: world.p), at: leaveDay).keyFile
        let catalog = Catalog.build([
            CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: try live.encoded()),
        ])
        let opens = RouteFinder(RouteFacts(catalog: catalog)).opensWith(fingerprint: PF.fp(castleKey))
        #expect(opens.line == [.passphrase(.current), .words(.heldHere(until: leaveDay))])
        var book = SecretBook()
        book.passphrases = [.current: world.passphrase, .heldHere(until: leaveDay): world.passphrase]
        book.words = [.heldHere(until: leaveDay): world.words]
        expectEveryRoadOpens(opens, PF.fp(castleKey), catalog, book)
    }

    /// A device that only ever had the words typed: no lock anywhere is a
    /// passphrase's, so its copies' line says the twelve words alone.
    @Test func aWordsOnlyFollowersCopiesSayTheWordsNotThePassphrase() throws {
        let world = try KeyWorld()
        let castleKey = StoreKey.mint(), standardKey = StoreKey.mint()
        let copy = try AES.KeyWrap.wrap(world.master, using: world.w.key)
        let followerFile = try KeyFile.building(
            libraryID: world.library, key: castleKey, epoch: 1,
            locks: NewKeyLocks(words: world.w, master: world.master, masterWordsCopy: copy))
        let leaveDay = CF.stamp(6)
        let anchor = try CastleAnchor.sealing(
            outgoingKeyFile: followerFile, outgoingKey: castleKey,
            locks: .follower(typed: .words(world.w), outgoingKeyFile: followerFile, includeMasterRoad: true),
            madeAt: leaveDay, madeBy: CF.macB)
        let live = try followerFile.writingAnchor(anchor).rekeyed(
            .leavingCastle, from: castleKey, to: standardKey, locks: NewKeyLocks(words: world.w), at: leaveDay).keyFile
        let catalog = Catalog.build([CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: try live.encoded())])
        let opens = RouteFinder(RouteFacts(catalog: catalog)).opensWith(fingerprint: PF.fp(castleKey))
        #expect(opens.line == [.words(.of(leaveDay))])
        #expect(!opens.openers.contains { if case .passphrase = $0 { return true } else { return false } })
        var book = SecretBook()
        book.words = [.of(leaveDay): world.words, .heldHere(until: leaveDay): world.words]
        expectEveryRoadOpens(opens, PF.fp(castleKey), catalog, book)
    }

    /// Custody, Touch ID, the history, an Apple key readable here, one this
    /// Mac lists but can't read, the old shared key: every road combination
    /// names its opener — and each one walks.
    @Test func everyRoadCombinationIsNamedAndWalks() throws {
        let world = try KeyWorld()
        let old = StoreKey.mint(), current = StoreKey.mint(), gated = StoreKey.mint()
        let own = AppleKeyMaterial.mint(), lost = AppleKeyMaterial.mint(), shared = AppleKeyMaterial.mint()
        // An older Standard key under the old shared key, then a re-key within
        // the mode taking it into the history.
        var oldFile = try KeyFile.building(libraryID: world.library, key: old, epoch: 1,
                                           locks: NewKeyLocks(passphrase: world.p, apple: lost))
        oldFile.sharedApple = AppleWrap(keyID: shared.id, wrapped: try AES.KeyWrap.wrap(SymmetricKey(data: old.data), using: shared.key))
        let currentFile = try oldFile.rekeyed(.withinMode, from: old, to: current,
                                              locks: NewKeyLocks(passphrase: world.p, words: world.w, apple: own), at: CF.stamp(2)).keyFile
        let catalog = Catalog.build([
            CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: try currentFile.encoded()),
            CatalogEntry(place: .container, folders: ["Backups"], name: CF.snapshotName(CF.stamp(1), old)),
            CatalogEntry(place: .container, folders: ["Backups"], name: CF.pairName(CF.stamp(1), old), bytes: try oldFile.encoded()),
        ])
        let finder = RouteFinder(RouteFacts(
            catalog: catalog,
            custody: [CustodyItemFact(fingerprint: PF.fp(current), itemClass: .silent),
                      CustodyItemFact(fingerprint: PF.fp(gated), itemClass: .touchid)],
            readableAppleKeyIDs: [own.id], oldSharedAppleKeyID: shared.id,
            ownAppleKeyIDsNotReadableHere: [lost.id]))
        let opens = finder.opensWith(fingerprint: PF.fp(old))
        #expect(opens.line == [.thisMac, .passphrase(.current), .words(.current), .appleAccount, .oldSharedAppleKey,
                               .appleKeyNotReadableHere])
        // Each road's steps are the locks it names.
        #expect(opens.route(for: .oldSharedAppleKey)?.steps.count == 1)
        #expect(opens.route(for: .thisMac)?.steps.count == 2, "the silent item, then the history")
        var book = SecretBook()
        book.passphrases = [.current: world.passphrase]
        book.words = [.current: world.words]
        book.custody = [PF.fp(current): current, PF.fp(gated): gated]
        book.apple = [own.id: own, lost.id: lost]
        book.oldShared = shared
        expectEveryRoadOpens(opens, PF.fp(old), catalog, book)
        #expect(finder.opensWith(fingerprint: PF.fp(gated)).line == [.touchID])
        // The old shared key taken away: everything else still stands.
        let without = finder.withoutOldSharedKey().opensWith(fingerprint: PF.fp(old))
        #expect(!without.openers.contains(.oldSharedAppleKey) && without.openers.count == opens.openers.count - 1)
    }

    /// A copy whose key the catalog can't pin (several of today's key files
    /// beside an aside copy, no dates listed): the line names only what opens
    /// EVERY candidate. With dates listed, today's newest-modified rule pins it.
    @Test func aCopyWhoseKeyCantBePinnedNamesOnlyWhatOpensEveryCandidate() throws {
        let world = try KeyWorld()
        let a = StoreKey.mint(), b = StoreKey.mint()
        var envelopeA = StoreKeyEnvelope(storeID: world.library)
        try envelopeA.setRecoveryWrap(key: a, words: world.words)
        try envelopeA.setPassphraseWrap(key: a, passphrase: world.passphrase, kdf: PF.fastKDF())
        var envelopeB = StoreKeyEnvelope(storeID: world.library)
        try envelopeB.setRecoveryWrap(key: b, words: world.words)
        let folders = ["Previous Libraries", CF.stampText(CF.stamp(9))]
        func entries(dated: Bool) throws -> [CatalogEntry] {
            [
                CatalogEntry(place: .container, folders: folders, name: "variorum.sqlite"),
                CatalogEntry(place: .container, folders: folders, name: StoreKeyEnvelope.filename(forFingerprint: PF.fp(a)),
                             bytes: try JSONEncoder().encode(envelopeA), modifiedAt: dated ? CF.stamp(8) : nil),
                CatalogEntry(place: .container, folders: folders, name: StoreKeyEnvelope.filename(forFingerprint: PF.fp(b)),
                             bytes: try JSONEncoder().encode(envelopeB), modifiedAt: dated ? CF.stamp(7) : nil),
            ]
        }
        let catalog = Catalog.build(try entries(dated: false))
        let copy = try #require(catalog.copies.first)
        #expect(copy.fingerprint == nil && Set(copy.candidateFingerprints) == [PF.fp(a), PF.fp(b)])
        let opens = RouteFinder(RouteFacts(catalog: catalog)).opensWith(copy: copy)
        // The words (held here on the folder's day) open both; the passphrase
        // opens only a — so it is not named.
        #expect(opens.line == [.words(.heldHere(until: CF.stamp(9)))])
        var book = SecretBook()
        book.words = [.heldHere(until: CF.stamp(9)): world.words]
        expectEveryRoadOpens(opens, PF.fp(a), catalog, book, orAnyOf: [PF.fp(b)])
        #expect(Set(opens.routes.map(\.steps.last)).count == 2, "a witness road to each candidate")
        // Dated: today's newest-modified rule pins the copy to a.
        let dated = Catalog.build(try entries(dated: true))
        #expect(dated.copies.first?.fingerprint == PF.fp(a))
    }

    /// A kept anchor sealed inside a later anchor still needs the secrets of
    /// ITS day: the outer anchor's locks are never named for the keys only the
    /// inner one holds — until a file that carries the inner anchor in the
    /// clear (a backup from between the two leaves) is in the catalog.
    @Test func aNestedAnchorsKeysNeedTheirOwnDaysSecrets() throws {
        let world = try KeyWorld()
        let c1 = StoreKey.mint(), s1 = StoreKey.mint(), c2 = StoreKey.mint(), s2 = StoreKey.mint()
        let leave1 = CF.stamp(1), leave2 = CF.stamp(4)
        let file1 = try world.castleFile(c1, synced: false)
        let anchor1 = try CastleAnchor.sealing(outgoingKeyFile: file1, outgoingKey: c1,
                                               locks: .pressingDevice(passphrase: world.p, words: world.w),
                                               madeAt: leave1, madeBy: nil)
        let standard1 = try file1.writingAnchor(anchor1).rekeyed(
            .leavingCastle, from: c1, to: s1, locks: NewKeyLocks(passphrase: world.p, words: world.w), at: leave1).keyFile
        // Both secrets change; entering Castle again can't fold anchor 1 in.
        let p2 = try PF.passphraseKey("second"), words2 = try PF.words(), w2 = try PF.wordsKey(words2)
        let castle2 = try standard1.rekeyed(
            .enteringCastle(openers: [.passphrase("second"), .words(words2)]), from: s1, to: c2,
            locks: NewKeyLocks(passphrase: p2, words: w2), at: CF.stamp(3), floor: PF.floor)
        #expect(castle2.unopenedAnchors == [anchor1])
        let anchor2 = try CastleAnchor.sealing(outgoingKeyFile: castle2.keyFile, outgoingKey: c2,
                                               locks: .pressingDevice(passphrase: p2, words: w2), madeAt: leave2, madeBy: nil)
        #expect(anchor2.heldFingerprints.contains(PF.fp(c1)) && !anchor2.directFingerprints.contains(PF.fp(c1)))
        let standard2 = try castle2.keyFile.writingAnchor(anchor2).rekeyed(
            .leavingCastle, from: c2, to: s2, locks: NewKeyLocks(passphrase: p2, words: w2), at: leave2).keyFile
        var entries = [CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: try standard2.encoded())]
        let alone = RouteFinder(RouteFacts(catalog: Catalog.build(entries))).opensWith(fingerprint: PF.fp(c1))
        #expect(!alone.opens, "anchor 2's locks are never named for a key only anchor 1 holds")
        // A backup from Castle's second stretch carries anchor 1 beside its
        // history, in the clear: its own day's secrets name it.
        entries.append(CatalogEntry(place: .container, folders: CF.macFolder(world.library, CF.macA),
                                    name: CF.pairName(CF.stamp(3), c2), bytes: try castle2.keyFile.encoded()))
        let catalog = Catalog.build(entries)
        let withBackup = RouteFinder(RouteFacts(catalog: catalog)).opensWith(fingerprint: PF.fp(c1))
        #expect(withBackup.line == [.passphrase(.of(leave1)), .words(.of(leave1))])
        var book = SecretBook()
        book.passphrases = [.of(leave1): world.passphrase]
        book.words = [.of(leave1): world.words]
        expectEveryRoadOpens(withBackup, PF.fp(c1), catalog, book)
    }
}

@Suite("VX-305 U2 — the anchor's sentences: what still opens the copies from before the leave (§3.9)")
struct AnchorSentenceTests {
    @Test func everyDoorThatReplacesASecretSaysItsSentence() throws {
        let leave = try LeaveWorld()
        let finder = RouteFinder(try leave.facts(Catalog.build(try leave.entries())))
        let words = try #require(finder.anchorSentence(for: .replacesWords))
        #expect(words.day == leave.leaveDay)
        #expect(words.stillOpensWith == [.passphrase(.current), .words(.of(leave.leaveDay))])
        let change = try #require(finder.anchorSentence(for: .changePassphrase))
        #expect(change.replacedSecretOpensIt == true, "the passphrase being changed is the anchor's")
        let reset = try #require(finder.anchorSentence(for: .resetForgottenPassphrase))
        #expect(reset.stillOpensWith == [.words(.of(leave.leaveDay))], "the reset road names that day's words only")
        #expect(try #require(finder.anchorSentence(for: .useCastleCannotFold)).stillOpensWith == words.stillOpensWith)
    }

    @Test func afterASecondPassphraseChangeTheSentenceNamesTheDay() throws {
        let leave = try LeaveWorld()
        let changed = try leave.standardFile.settingPassphrase(try PF.passphraseKey("a new one"), for: leave.standardKey)
        let finder = RouteFinder(try leave.facts(Catalog.build(try leave.entries(live: changed))))
        let change = try #require(finder.anchorSentence(for: .changePassphrase))
        #expect(change.replacedSecretOpensIt == nil, "the passphrase being replaced now is not provably the anchor's")
        #expect(change.stillOpensWith == [.passphrase(.of(leave.leaveDay)), .words(.of(leave.leaveDay))])
    }

    @Test func noAnchorNoSentence() throws {
        let world = try KeyWorld()
        let key = StoreKey.mint()
        let catalog = Catalog.build([
            CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: try world.castleFile(key).encoded()),
        ])
        #expect(RouteFinder(RouteFacts(catalog: catalog)).anchorSentence(for: .replacesWords) == nil)
    }
}

@Suite("VX-305 U2 — the retirement's list: everything that belongs on it, and nothing else")
struct RetirementRoutesTests {
    @Test func theRetirementsListIsExact() throws {
        let world = try KeyWorld()
        let shared = AppleKeyMaterial.mint(), own = AppleKeyMaterial.mint(), otherOwn = AppleKeyMaterial.mint()
        func sharedWrap(_ key: StoreKey) throws -> AppleWrap {
            AppleWrap(keyID: shared.id, wrapped: try AES.KeyWrap.wrap(SymmetricKey(data: key.data), using: shared.key))
        }
        let live = StoreKey.mint(), onlyShared = StoreKey.mint(), otherLibrary = StoreKey.mint()
        let castleCopy = StoreKey.mint(), unattributed = StoreKey.mint(), otherMacKey = StoreKey.mint()
        // The live Standard library: its own key, the old shared wrap riding
        // beside it, a passphrase and the words.
        var liveFile = try KeyFile.building(libraryID: CF.lib1, key: live, epoch: 1,
                                            locks: NewKeyLocks(passphrase: world.p, words: world.w, apple: own))
        liveFile.sharedApple = try sharedWrap(live)
        // A copy of this library whose only road is the old shared key (today's format 2).
        var legacy = StoreKeyEnvelope(storeID: CF.lib1, keyFingerprint: PF.fp(onlyShared))
        try legacy.setAppleWrappedCopy(key: onlyShared, under: shared.key, appleKeyID: shared.id)
        // Another library on this Mac: this Mac's own key file for it, Standard, no secrets.
        var otherFile = try KeyFile.building(libraryID: CF.lib2, key: otherLibrary, epoch: 1, locks: NewKeyLocks(apple: own))
        otherFile.sharedApple = try sharedWrap(otherLibrary)
        // A Castle copy (passphrase and words): never on the list.
        let castleFile = try world.castleFile(castleCopy)
        // An unattributed far copy of another library: Standard, no secrets.
        let unattributedFile = try KeyFile.building(libraryID: CF.lib2, key: unattributed, epoch: 1, locks: NewKeyLocks(apple: own))
        // Another Mac's pair holding this library's live key in its history.
        let otherMacFile = try liveFile.rekeyed(.withinMode, from: live, to: otherMacKey,
                                                locks: NewKeyLocks(passphrase: world.p, apple: otherOwn), at: CF.stamp(2)).keyFile
        let mine = CF.macFolder(CF.lib1, CF.macA), mineOther = CF.macFolder(CF.lib2, CF.macA)
        let theirs = CF.macFolder(CF.lib1, CF.macB)
        let d = CF.stamp(1)
        let catalog = Catalog.build([
            CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: try liveFile.encoded()),
            CatalogEntry(place: .container, folders: ["Backups"], name: CF.snapshotName(d, onlyShared)),
            CatalogEntry(place: .container, folders: ["Backups"], name: CF.pairName(d, onlyShared), bytes: try JSONEncoder().encode(legacy)),
            CatalogEntry(place: .container, folders: mineOther, name: ProtectionNames.keyFilename, bytes: try otherFile.encoded()),
            CatalogEntry(place: .container, folders: mineOther, name: CF.snapshotName(d, otherLibrary)),
            CatalogEntry(place: .container, folders: mineOther, name: CF.pairName(d, otherLibrary), bytes: try otherFile.encoded()),
            CatalogEntry(place: .container, folders: mine, name: CF.snapshotName(d, castleCopy)),
            CatalogEntry(place: .container, folders: mine, name: CF.pairName(d, castleCopy), bytes: try castleFile.encoded()),
            CatalogEntry(place: .farFolder, folders: ["Backups"], name: CF.snapshotName(d, unattributed)),
            CatalogEntry(place: .farFolder, folders: ["Backups"], name: CF.pairName(d, unattributed), bytes: try unattributedFile.encoded()),
            CatalogEntry(place: .farFolder, folders: theirs, name: CF.snapshotName(CF.stamp(2), otherMacKey)),
            CatalogEntry(place: .farFolder, folders: theirs, name: CF.pairName(CF.stamp(2), otherMacKey), bytes: try otherMacFile.encoded()),
        ])
        let finder = RouteFinder(RouteFacts(
            catalog: catalog, custody: [CustodyItemFact(fingerprint: PF.fp(live), itemClass: .silent)],
            readableAppleKeyIDs: [own.id], oldSharedAppleKeyID: shared.id))
        let routes = finder.retirementRoutes(thisMac: CF.macA, libraryFingerprints: [PF.fp(live), PF.fp(onlyShared)])
        func copyID(_ key: StoreKey) -> RetirementSubject {
            .copy(catalog.copies.first { $0.fingerprint == PF.fp(key) }!.id)
        }
        let liveSubject = RetirementSubject.library(keyFile: catalog.liveKeyFile!.id)
        let otherLibrarySubject = RetirementSubject.library(
            keyFile: catalog.keyFiles.first { $0.role == .ownKeyFile }!.id)
        #expect(Set(routes.wouldStopOpening) == [copyID(onlyShared)])
        #expect(Set(routes.appleKeyAlone) == [otherLibrarySubject, copyID(otherLibrary), copyID(unattributed)])
        #expect(Set(routes.stillNeedsIt) == [liveSubject, otherLibrarySubject, copyID(onlyShared), copyID(otherLibrary)])
        #expect(routes.otherMacsKeyFiles == catalog.keyFiles.filter { $0.mac == .mac8(ProtectionNames.mac8(CF.macB)) }.map(\.id))
        // The Castle copy and the live library (it keeps its secrets) are on none of it.
        #expect(!routes.appleKeyAlone.contains(copyID(castleCopy)) && !routes.wouldStopOpening.contains(copyID(castleCopy)))
        #expect(!routes.appleKeyAlone.contains(liveSubject))
    }
}
