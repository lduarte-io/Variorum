//
//  RouteFinderTests.swift
//  VariorumCoreTests — VX-305 U2: the route finder. Its words agree with the
//  roads it found, and every *Opens with* line names only roads that open
//  (each named opener's witness road is WALKED with the real secret of its
//  day). (The anchor's roads, the followers' anchors and the anchor sentences
//  left with VX-378 U1 — rules 4, 6, 12; piece J reduces the finder to rule
//  4's one sentence.)
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
    func file(_ id: String) throws -> KeyFile {
        try need(catalog.keyFile(id: id)?.document, "no key file \(id)")
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
            do {
                let keyFile = try file(id)
                switch road {
                case .passphrase: key = try keyFile.open(try secret(), floor: PF.floor)
                case .words: key = try keyFile.open(words: try words())
                case .masterThroughWords: key = try keyFile.open(wordsThroughMaster: try words())
                case .master: key = try keyFile.open(master: try need(book.vaultMaster, "no master"))
                case .apple:
                    let id = try need(keyFile.apple?.keyID, "no apple wrap")
                    key = try keyFile.open(apple: try need(book.apple[id], "no apple key"))
                }
            }
        case .history(let id, let fingerprint):
            let keyFile = try file(id)
            key = try need(try keyFile.historyKey(fingerprint, currentKey: try need(key, "no key")), "not in history")
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
/// copies from both sides of it: the new Standard key's history carries the
/// Castle key (rule 4, rule 12).
struct LeaveWorld {
    let world: KeyWorld
    let castleKey = StoreKey.mint(), standardKey = StoreKey.mint()
    let apple = AppleKeyMaterial.mint()
    let newMaster = SymmetricKey(size: .bits256)
    let castleFile: KeyFile
    let standardFile: KeyFile
    let day1 = CF.stamp(1), leaveDay = CF.stamp(2), day3 = CF.stamp(3)

    init() throws {
        world = try KeyWorld()
        castleFile = try world.castleFile(castleKey)
        let newCopy = try AES.KeyWrap.wrap(newMaster, using: world.w.key)
        standardFile = try castleFile.rekeyed(
            from: castleKey, to: standardKey, kind: .standard,
            locks: NewKeyLocks(passphrase: world.p, words: world.w, master: newMaster, masterWordsCopy: newCopy, apple: apple),
            at: leaveDay)
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
        book.passphrases = [.current: world.passphrase,
                            .heldHere(until: day1): before, .heldHere(until: day3): before]
        book.words = [.current: world.words,
                      .heldHere(until: day1): world.words, .heldHere(until: day3): world.words]
        book.custody = [PF.fp(standardKey): standardKey]
        book.apple = [apple.id: apple]
        book.vaultMaster = newMaster
        return book
    }
}

@Suite("VX-305 U2 — the route finder: every road, and only roads that open")
struct RouteFinderRoadTests {
    /// After a leave, a copy from Castle opens with the CURRENT passphrase and
    /// words — the live key file's history carries the Castle key (rule 4) —
    /// and every road the line names opens it; a copy from after it opens
    /// through this Mac, the current secrets, the account and the Apple road.
    @Test func afterALeaveCastleCopiesOpenWithTheCurrentSecrets() throws {
        let leave = try LeaveWorld()
        let catalog = Catalog.build(try leave.entries())
        let finder = RouteFinder(try leave.facts(catalog))
        let before = finder.opensWith(fingerprint: PF.fp(leave.castleKey))
        #expect(before.openers.contains(.passphrase(.current)) && before.openers.contains(.words(.current)))
        expectEveryRoadOpens(before, PF.fp(leave.castleKey), catalog, leave.book())

        let after = finder.opensWith(fingerprint: PF.fp(leave.standardKey))
        #expect(after.line == [.thisMac, .passphrase(.current), .words(.current), .accountOnline, .appleAccount])
        expectEveryRoadOpens(after, PF.fp(leave.standardKey), catalog, leave.book())
    }

    /// Rule 6: a passphrase changed after the leave re-locks the current key,
    /// so the NEW passphrase opens the Castle copies through the history.
    @Test func aPassphraseChangedAfterTheLeaveStillOpensTheCastleCopies() throws {
        let leave = try LeaveWorld()
        let changed = try leave.standardFile.settingPassphrase(try PF.passphraseKey("a new one"), for: leave.standardKey)
        let catalog = Catalog.build(try leave.entries(live: changed))
        let finder = RouteFinder(try leave.facts(catalog))
        let before = finder.opensWith(fingerprint: PF.fp(leave.castleKey))
        #expect(before.openers.contains(.passphrase(.current)), "the new passphrase opens what came before the leave")
        var book = leave.book()
        book.passphrases[.current] = "a new one"
        expectEveryRoadOpens(before, PF.fp(leave.castleKey), catalog, book)
        // The copy from after the leave: its frozen file keeps the old
        // passphrase (held here then); the live file takes the new one.
        let after = finder.opensWith(fingerprint: PF.fp(leave.standardKey))
        #expect(after.openers.contains(.passphrase(.current)) && after.openers.contains(.passphrase(.heldHere(until: leave.day3))))
        expectEveryRoadOpens(after, PF.fp(leave.standardKey), catalog, book)
    }
}
