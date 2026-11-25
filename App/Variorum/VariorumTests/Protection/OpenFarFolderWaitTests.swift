//
//  OpenFarFolderWaitTests.swift
//  VariorumTests — VX-1013 (`notes/plans/fixes/vx-1013-open-far-folder-wait.md`): THE OPEN NEVER WAITS ON A FOLDER
//  OUTSIDE THE LIBRARY. Every launch blocked its first frame on the protection route, and the route listed BOTH
//  catalogue roots — reading every key file's bytes — on the order of ten times, the far root being her picked backup
//  folder (commonly iCloud-synced: a cold or evicted folder blocks each read; the field gate measured minutes of blank
//  window). The launch road now reads the container only; the far folder is walked ONCE per open, off the launch path,
//  when the lobby draws or a press that would refuse joins it.
//
//  Over a PLANTED road (no keychain; the real file leaves; a temp slot whose picked far folder COUNTS every claim of it
//  — `ProtectionFarFolder.accessed`, the one door every far read goes through). The route and walk-count pins are RED on
//  the pre-fix road; the landing pins are RED there too (the old lobby already held the far folder's roads and rule 27's
//  refusal before it drew); the press pin is the preserved contract (green on both sides — a mutation of the join turns
//  it red). The record's LIVE STATUS carries the runs.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// Every claim of the far folder, counted (a test's witness — `ProtectionFarFolder.accessed`).
nonisolated final class FarReads: @unchecked Sendable {
    private let lock = NSLock()
    private var claims = 0
    var count: Int { lock.withLock { claims } }
    func tick() { lock.withLock { claims += 1 } }
    func reset() { lock.withLock { claims = 0 } }
}

/// A temp slot whose picked far folder counts its reads; removed at deinit.
nonisolated final class CountingFarSlot {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("vx1013-slot-\(UUID().uuidString)", isDirectory: true)
    let far: URL
    let reads = FarReads()
    let places: ProtectionPlaces

    init() {
        let container = root.appendingPathComponent("container", isDirectory: true)
        try? FileManager.default.createDirectory(at: container, withIntermediateDirectories: true)
        let far = root.appendingPathComponent("far", isDirectory: true)
        try? FileManager.default.createDirectory(at: far, withIntermediateDirectories: true)
        self.far = far
        let reads = reads
        places = ProtectionPlaces(
            slot: container.appendingPathComponent(CatalogNames.libraryFilename),
            farFolder: { ProtectionFarFolder(picked: far, scoped: false, accessed: { reads.tick() }) },
            scratch: root.appendingPathComponent("scratch", isDirectory: true))
    }

    deinit { try? FileManager.default.removeItem(at: root) }

    /// `<picked>/Variorum` — the catalogue's far root.
    var farRoot: URL { far.appendingPathComponent(CatalogNames.variorumFolderName, isDirectory: true) }
}

enum FarWalkRoadError: Error { case notCreated }

/// A planted road over a counting far folder (`PlantedRoad`'s leaves).
@MainActor
final class FarWalkRoad {
    let slot = CountingFarSlot()
    let custody = PlantedCustodyLeaf()
    let memory = PlantedMemoryLeaf()
    let apple = InMemoryAppleKeysLeaf()

    func system() -> ProtectionSystem {
        ProtectionSystem(
            scope: "vx1013-planted", places: slot.places, deviceName: "Test Mac", floor: .relaxedForTests,
            custody: custody, syncKeys: EmptySyncKeysLeaf(), apple: apple, memory: memory,
            biometry: FixedBiometryLeaf(.none), ids: FastIDsLeaf())
    }

    /// A context as every non-launch caller holds one (no far walk: both roots at each read).
    func context() -> RoadContext { RoadContext(system: system(), session: .signedOut, writes: true) }

    /// The launch road's context: this open's one far walk (the bootstrap's `beginOpening` makes one per open).
    func launchContext() -> RoadContext {
        var ctx = context()
        ctx.far = FarFolderWalk(places: slot.places)
        return ctx
    }

    /// The road a lock's lobby is composed over (the bootstrap's `roadInputs.compose()`, planted).
    func composed() -> ComposedRoad {
        ComposedRoad(system: system(), sessionFact: { .signedOut }, writes: true, open: nil)
    }

    func created() async throws -> (session: ProtectionRoadSession, words: [String]) {
        guard case .created(let session, let words) = await ProtectionOpenRoad.route(context()) else {
            throw FarWalkRoadError.notCreated
        }
        return (session, words.words)
    }

    /// `file` as a backup pair's key file in this Mac's far folder (an opaque snapshot beside it), named by its key.
    func plantFarPair(_ file: KeyFile, deviceID: String) throws {
        let folder = slot.farRoot.appendingPathComponent(
            ProtectionNames.backupsSubpath(libraryID: file.libraryID, deviceID: deviceID), isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let stem = CatalogNames.backupPrefix + CatalogNames.stampString(Date(timeIntervalSince1970: 1_790_000_000)) + "-"
            + KeyFingerprint.short(file.fingerprint)
        try Data("planted snapshot".utf8).write(to: folder.appendingPathComponent(stem + ".sqlite"))
        try file.encoded().write(to: folder.appendingPathComponent(stem + ".keys.json"))
    }

    func liveKeyFile() throws -> KeyFile { try #require(try system().leaves.keyFiles.readLiveKeyFile()) }

    func writeLiveKeyFile(_ file: KeyFile) throws { try file.encoded().write(to: slot.places.liveKeyFile, options: .atomic) }

    /// No quiet road left: no custody item, no Apple key, nothing remembered.
    func forgetEveryQuietRoad() {
        custody.items = [:]
        apple.keys = [:]
        memory.items = [:]
    }
}

@Suite("VX-1013 — the open never waits on the far folder; it is walked once, off the launch path", .serialized)
@MainActor
struct OpenFarFolderWaitTests {
    // MARK: - The route (red on the pre-fix road)

    /// THE ROUTE PIN: a quiet-road open — the silent item opens the library at once — completes with ZERO reads of the
    /// far folder, though one is picked and holds a backup pair of the library. RED ON OLD: the route listed both roots
    /// before its verdict, again in every facts read and custody probe, the open's expansion, repairs and log line.
    @Test func aQuietRoadOpenReadsTheFarFolderNotOnce() async throws {
        let road = FarWalkRoad()
        let (created, _) = try await road.created()
        try road.plantFarPair(try road.liveKeyFile(), deviceID: created.library.section.deviceID)
        road.slot.reads.reset()
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.launchContext()) else {
            Issue.record("the silent item opens it at once")
            return
        }
        #expect(session.key == created.key)
        #expect(road.slot.reads.count == 0, "the far folder was read \(road.slot.reads.count) time(s) on the way to the library")
    }

    /// THE WALK-COUNT PIN: one open — the lobby (no quiet road left), the far walk landing on it, a refused press, the
    /// press that opens — claims the far folder ONCE. RED ON OLD: every read of the open walked it again.
    @Test func oneOpenWalksTheFarFolderAtMostOnce() async throws {
        let road = FarWalkRoad()
        let (created, words) = try await road.created()
        try road.plantFarPair(try road.liveKeyFile(), deviceID: created.library.section.deviceID)
        road.forgetEveryQuietRoad()
        road.slot.reads.reset()
        let ctx = road.launchContext()
        guard case .lobby = await ProtectionOpenRoad.route(ctx) else {
            Issue.record("no quiet road remains — the lobby")
            return
        }
        #expect(road.slot.reads.count <= 1, "the lobby drew with at most the one walk begun")
        guard case .lobby = await ProtectionOpenRoad.landTheFarWalk(ctx) else {
            Issue.record("the landing leaves the lobby standing — no quiet road in the far folder")
            return
        }
        guard case .refused = await ProtectionOpenRoad.openTyped(ctx, secret: .words(try RecoveryPhrase.generate())) else {
            Issue.record("another library's words open nothing")
            return
        }
        guard case .opened(let session) = await ProtectionOpenRoad.openTyped(ctx, secret: .words(words)) else {
            Issue.record("the words open the library")
            return
        }
        #expect(session.key == created.key)
        #expect(road.slot.reads.count == 1, "one open, one far walk — read \(road.slot.reads.count) time(s)")
    }

    // MARK: - The press (the preserved contract — P-1013-2)

    /// THE PRESS-EQUIVALENCE PIN: a passphrase whose lock ONLY a far backup's key file carries (the key file beside the
    /// library has the words lock only; nothing remembered) still opens the library — the press finds no opener among
    /// the container's files, joins the far walk (one read), and tries once more. Green on both sides by design (the old
    /// road read the far folder up front); a mutation that drops the join turns it red.
    @Test func aPassphraseOnlyAFarKeyFileCarriesStillOpens() async throws {
        let road = FarWalkRoad()
        let (created, _) = try await road.created()
        let wordsOnly = try road.liveKeyFile()
        #expect(wordsOnly.passphrase == nil)
        let passphrase = "a far-folder passphrase"
        #expect(await ProtectionOpenRoad.setFirstPassphrase(session: created, new: passphrase) == .set)
        let withPassphrase = try road.liveKeyFile()
        #expect(withPassphrase.passphrase != nil && withPassphrase.fingerprint == wordsOnly.fingerprint)
        try road.plantFarPair(withPassphrase, deviceID: created.library.section.deviceID)
        try road.writeLiveKeyFile(wordsOnly)
        road.forgetEveryQuietRoad()
        road.slot.reads.reset()
        // A press on a launch context whose walk has not begun: the press joins it.
        guard case .opened(let session) = await ProtectionOpenRoad.openTyped(road.launchContext(), secret: .passphrase(passphrase))
        else {
            Issue.record("the far folder's key file opens the library for the passphrase it carries")
            return
        }
        #expect(session.key == created.key)
        #expect(road.slot.reads.count == 1, "the press joined the one far walk — read \(road.slot.reads.count) time(s)")
    }

    // MARK: - The lobby's landing (P-1013-1, P-1013-3) — red on the pre-fix road

    /// RULE 27 STAYS REACHABLE: nothing anywhere opens the library (no key file beside it, no copy, nothing remembered,
    /// no custody item). The lobby drawn from the container claims NOTHING (the far folder unread might hold a key file);
    /// the landing's full facts prove nothing does, and rule 27's refusal stands. RED ON OLD: the old lobby claimed rule
    /// 27 before it drew.
    @Test func ruleTwentySevenIsSaidOnceTheFarWalkLandsEmpty() async throws {
        let road = FarWalkRoad()
        _ = try await road.created()
        try FileManager.default.removeItem(at: road.slot.places.liveKeyFile)
        road.forgetEveryQuietRoad()
        let ctx = road.launchContext()
        guard case .lobby(let drawn) = await ProtectionOpenRoad.route(ctx) else {
            Issue.record("the lobby")
            return
        }
        #expect(ProtectionLobbyFace.derive(drawn).noKeyFileAnywhere == nil,
                "the far folder unread: rule 27 is never claimed on a partial listing")
        guard case .lobby(let landed) = await ProtectionOpenRoad.landTheFarWalk(ctx) else {
            Issue.record("the landing keeps the lobby")
            return
        }
        #expect(ProtectionLobbyFace.derive(landed).noKeyFileAnywhere != nil, "the full listing proves it: rule 27")
    }

    /// The far folder's key file carries a passphrase lock the container's do not: the lobby draws with the words road
    /// alone, and the landing adds the passphrase road (P-1013-1). RED ON OLD: the old lobby offered it before it drew.
    @Test func theFarFoldersTypedRoadsAppearWhenItsWalkLands() async throws {
        let road = FarWalkRoad()
        let (created, _) = try await road.created()
        let wordsOnly = try road.liveKeyFile()
        #expect(await ProtectionOpenRoad.setFirstPassphrase(session: created, new: "a far-folder passphrase") == .set)
        try road.plantFarPair(try road.liveKeyFile(), deviceID: created.library.section.deviceID)
        try road.writeLiveKeyFile(wordsOnly)
        road.forgetEveryQuietRoad()
        let ctx = road.launchContext()
        guard case .lobby(let drawn) = await ProtectionOpenRoad.route(ctx) else {
            Issue.record("the lobby")
            return
        }
        #expect(drawn.offeredTyped == [.words], "drawn from the container: \(drawn.offeredTyped)")
        guard case .lobby(let landed) = await ProtectionOpenRoad.landTheFarWalk(ctx) else {
            Issue.record("the landing keeps the lobby")
            return
        }
        #expect(landed.offeredTyped == [.words, .passphrase], "the far key file's passphrase road: \(landed.offeredTyped)")
        #expect(ProtectionLobbyFace.derive(landed).passphraseField)
    }

    /// A quiet road only the far folder's key file carries (its Apple wrap, readable here; the key file beside the
    /// library has none; nothing remembered, no custody item): the lobby draws, and the landing OPENS the library
    /// through it (P-1013-3). RED ON OLD: the old route opened it at once (it read the far folder before its verdict).
    @Test func aQuietRoadTheFarFolderRevealsOpensTheLobby() async throws {
        let road = FarWalkRoad()
        let (created, _) = try await road.created()
        let live = try road.liveKeyFile()
        #expect(live.apple != nil, "a Standard library's key file carries its Apple wrap")
        try road.plantFarPair(live, deviceID: created.library.section.deviceID)
        var bare = live
        bare.apple = nil
        try road.writeLiveKeyFile(bare)
        road.custody.items = [:]
        road.memory.items = [:]
        let ctx = road.launchContext()
        guard case .lobby = await ProtectionOpenRoad.route(ctx) else {
            Issue.record("the container holds no quiet road — the lobby draws")
            return
        }
        guard case .opened(let session) = await ProtectionOpenRoad.landTheFarWalk(ctx) else {
            Issue.record("the far folder's Apple wrap opens it once the walk lands")
            return
        }
        #expect(session.key == created.key)
    }

    // MARK: - The custody probe (red on the pre-fix road)

    /// THE PROBE PIN: the Keychain custody leaf's probe-by-name (`ProtectionSystem.touchIDCandidates`) runs inside every
    /// custody listing — the gatherer's and the executor's own. Under the launch road's scope (`CatalogRead.probing` =
    /// this open's walk, unread) it names the container's key files' fingerprints (and the memory items', the plan's,
    /// the staged key's) and reads NO far folder; under every other caller's scope it walks both roots, as before. RED ON
    /// OLD: the probe walked both roots at every listing.
    @Test func theCustodyProbeReadsNoFarFolderInsideTheLaunchRoad() async throws {
        let road = FarWalkRoad()
        let (created, _) = try await road.created()
        try road.plantFarPair(try road.liveKeyFile(), deviceID: created.library.section.deviceID)
        let probe = ProtectionSystem.touchIDCandidates(places: road.slot.places, memory: road.memory)
        road.slot.reads.reset()
        let walk = FarFolderWalk(places: road.slot.places)
        let named = CatalogRead.$probing.withValue(.thisOpen(walk)) { probe() }
        #expect(named.contains(created.library.fingerprint), "the current key is named by the container's key file")
        #expect(road.slot.reads.count == 0, "the probe read the far folder \(road.slot.reads.count) time(s) inside an open")
        _ = probe()
        #expect(road.slot.reads.count == 1, "every other caller's probe walks both roots, as before")
    }

    // MARK: - The lock's lobby (R-1013-A2 — piece 6; red on the pre-piece road)

    /// THE RELOCK PIN: the lobby a lock lands in (Lock Now, the idle and sleep monitors — `AppBootstrap.lockOnNewRoad`
    /// composes its context through `ProtectionRoadLock.lobbyContext`) reads the CONTAINER's facts with no far read, begins
    /// its own far walk behind it, and the landing refreshes its roads — the far key file's passphrase road appears —
    /// with ONE far read in all. RED BEFORE PIECE 6: the lock's lobby read both roots before it drew.
    @Test func aLocksLobbyReadsNoFarFolderAndItsLandingRefreshesItsRoads() async throws {
        let road = FarWalkRoad()
        let (created, _) = try await road.created()
        let wordsOnly = try road.liveKeyFile()
        #expect(await ProtectionOpenRoad.setFirstPassphrase(session: created, new: "a far-folder passphrase") == .set)
        try road.plantFarPair(try road.liveKeyFile(), deviceID: created.library.section.deviceID)
        try road.writeLiveKeyFile(wordsOnly)
        road.forgetEveryQuietRoad()
        road.slot.reads.reset()
        let ctx = ProtectionRoadLock.lobbyContext(road.composed())
        let drawn = ProtectionRoadLock.lobby(ctx)
        #expect(drawn.facts?.catalog.unreadPlaces == [.farFolder], "the lock's lobby drew from the container's facts")
        #expect(drawn.offeredTyped == [.words], "drawn from the container: \(drawn.offeredTyped)")
        #expect(ctx.far?.hasBegun == true, "the far walk begins behind the lock's lobby")
        guard case .lobby(let landed) = await ProtectionOpenRoad.landTheFarWalk(ctx) else {
            Issue.record("a lock's landing keeps the lobby")
            return
        }
        #expect(landed.offeredTyped == [.words, .passphrase], "the landing refreshed the roads: \(landed.offeredTyped)")
        #expect(road.slot.reads.count == 1, "one lock, one far walk — read \(road.slot.reads.count) time(s)")
    }

    /// A lock is never theater: the quiet roads are not tried at a lock, and the far walk's landing on a lock's lobby
    /// keeps it so — a far key file's Apple wrap that WOULD open the library (the launch road's landing opens through it,
    /// `aQuietRoadTheFarFolderRevealsOpensTheLobby`) leaves the lock's lobby standing. RED BEFORE PIECE 6 (the lock's
    /// context carried no far walk and its landing, reached over it, would try the quiet roads like the launch's).
    @Test func aLocksLobbyNeverTriesTheQuietRoadsWhenItsWalkLands() async throws {
        let road = FarWalkRoad()
        let (created, _) = try await road.created()
        let live = try road.liveKeyFile()
        try road.plantFarPair(live, deviceID: created.library.section.deviceID)
        var bare = live
        bare.apple = nil
        try road.writeLiveKeyFile(bare)
        road.custody.items = [:]
        road.memory.items = [:]
        let ctx = ProtectionRoadLock.lobbyContext(road.composed())
        _ = ProtectionRoadLock.lobby(ctx)
        guard case .lobby = await ProtectionOpenRoad.landTheFarWalk(ctx) else {
            Issue.record("a lock's landing never opens the library by a quiet road")
            return
        }
    }

    // MARK: - The lobby model: the landing never runs beside a press

    /// The far walk lands while a press is in flight: the landing waits for the press to end (no second road runs
    /// beside it), then the full facts are taken — once.
    @Test func aLandingDuringAPressWaitsForThePressToEnd() async throws {
        let standing = LobbyFixture.standing(try LobbyFixture.facts(
            file: try LobbyFixture.liveKeyFile(passphrase: false), touchIDItem: false, biometry: .none))
        let full = LobbyFixture.standing(try LobbyFixture.facts(
            file: try LobbyFixture.liveKeyFile(passphrase: true), touchIDItem: false, biometry: .none))
        let gate = PressGate()
        var landings = 0
        let model = ProtectionLobbyModel(
            standing: standing,
            typedRoad: { _ in
                await gate.wait()
                return .refused(ProtectionWords.wordsDoNotOpen)
            },
            touchIDRoad: { _ in .touchIDNotOpened(press: .cancelled, biometry: .none, itemGone: false) },
            refreshRoad: { standing },
            opened: { _ in },
            recordMissing: {},
            farLanding: {
                landings += 1
                return .lobby(full)
            })
        #expect(!model.face.passphraseField)
        let press = Task { await model.unlock(wordsText: "one two three") }
        while !model.busy { await Task.yield() }
        await model.farWalkLanded()
        #expect(landings == 0, "a press is in flight — the landing waits")
        gate.open()
        await press.value
        #expect(landings == 1, "the press ended without opening — the landing ran, once")
        #expect(model.face.passphraseField, "the full facts were taken")
        await model.farWalkLanded()
        #expect(landings == 1, "once only")
    }

    // MARK: - The lobby model: a refresh never narrows what the landing took (round 1, F-R1-1 — red on the batch-1 tree)

    /// A refresh (she came back to the app) whose read began BEFORE the far walk landed carries the container's partial
    /// listing; the landing runs while it is in flight and takes the full one. When the refresh then answers, the lobby
    /// KEEPS the landed facts: here rule 27's refusal, which only the full listing may claim. RED ON THE BATCH-1 TREE:
    /// `take` replaced the standing whole, so the banner (and its door) vanished until the next refresh.
    @Test func aRefreshReadBeforeTheLandingNeverTakesRuleTwentySevenBackAway() async throws {
        var partial = try LobbyFixture.facts(file: nil, touchIDItem: false, biometry: .none)
        partial.catalog.unreadPlaces = [.farFolder]
        let partialFacts = partial
        let full = try LobbyFixture.facts(file: nil, touchIDItem: false, biometry: .none)
        let gate = RefreshGate()
        let model = ProtectionLobbyModel(
            standing: LobbyFixture.standing(partialFacts),
            typedRoad: { _ in .refused(ProtectionWords.wordsDoNotOpen) },
            touchIDRoad: { _ in .touchIDNotOpened(press: .cancelled, biometry: .none, itemGone: false) },
            refreshRoad: {
                await gate.hold()
                return LobbyFixture.standing(partialFacts)
            },
            opened: { _ in },
            recordMissing: {},
            farLanding: { .lobby(LobbyFixture.standing(full)) })
        #expect(model.face.noKeyFileAnywhere == nil, "drawn from the container's listing: rule 27 is not claimed")
        let refresh = Task { await model.refresh() }
        while !gate.entered { await Task.yield() }
        await model.farWalkLanded()
        #expect(model.face.noKeyFileAnywhere != nil, "the landing's full listing proves it: rule 27")
        gate.open()
        await refresh.value
        #expect(model.face.noKeyFileAnywhere != nil, "the refresh read before the landing never narrows the lobby back")
    }

    /// The same race over a typed road only the far folder's key file carries: the landing adds the passphrase field
    /// (P-1013-1), and a refresh read before it landed never takes the field away. RED ON THE BATCH-1 TREE.
    @Test func aRefreshReadBeforeTheLandingNeverTakesTheFarFilesRoadBackAway() async throws {
        let wordsOnly = try LobbyFixture.liveKeyFile(passphrase: false)
        var partial = try LobbyFixture.facts(file: wordsOnly, touchIDItem: false, biometry: .none)
        partial.catalog.unreadPlaces = [.farFolder]
        let partialFacts = partial
        let full = try LobbyFixture.facts(file: wordsOnly, touchIDItem: false, biometry: .none)
        let gate = RefreshGate()
        let model = ProtectionLobbyModel(
            standing: LobbyFixture.standing(partialFacts, offered: [.words]),
            typedRoad: { _ in .refused(ProtectionWords.wordsDoNotOpen) },
            touchIDRoad: { _ in .touchIDNotOpened(press: .cancelled, biometry: .none, itemGone: false) },
            refreshRoad: {
                await gate.hold()
                return LobbyFixture.standing(partialFacts, offered: [.words])
            },
            opened: { _ in },
            recordMissing: {},
            farLanding: { .lobby(LobbyFixture.standing(full, offered: [.words, .passphrase])) })
        #expect(!model.face.passphraseField, "drawn from the container: the words road alone")
        let refresh = Task { await model.refresh() }
        while !gate.entered { await Task.yield() }
        await model.farWalkLanded()
        #expect(model.face.passphraseField, "the landing added the far key file's passphrase road")
        gate.open()
        await refresh.value
        #expect(model.face.passphraseField, "the refresh read before the landing never takes the road away")
    }

    /// The guard's edge: a lobby whose standing has NO facts (the keychain could not be listed) takes any read that has
    /// facts — a partial one included — exactly as before. Green on both sides by design (no width to keep); a guard
    /// that read a missing standing as a whole listing would turn it red.
    @Test func aLobbyWithNoFactsTakesAPartialReadAsBefore() async throws {
        let wordsOnly = try LobbyFixture.liveKeyFile(passphrase: false)
        var partial = try LobbyFixture.facts(file: wordsOnly, touchIDItem: false, biometry: .none)
        partial.catalog.unreadPlaces = [.farFolder]
        let partialFacts = partial
        let model = ProtectionLobbyModel(
            standing: LobbyFixture.standing(nil),
            typedRoad: { _ in .refused(ProtectionWords.wordsDoNotOpen) },
            touchIDRoad: { _ in .touchIDNotOpened(press: .cancelled, biometry: .none, itemGone: false) },
            refreshRoad: { LobbyFixture.standing(partialFacts, offered: [.words]) },
            opened: { _ in },
            recordMissing: {})
        #expect(model.face.keychainUnreadable, "nothing listed")
        await model.refresh()
        #expect(!model.face.keychainUnreadable, "the read with facts was taken")
        #expect(!model.face.passphraseField, "its roads: the words alone")
    }
}

/// A refresh held open until the test lets it go; `entered` once the read is in flight.
@MainActor
final class RefreshGate {
    private(set) var entered = false
    private var waiter: CheckedContinuation<Void, Never>?
    private var opened = false

    func hold() async {
        entered = true
        if opened { return }
        await withCheckedContinuation { waiter = $0 }
    }

    func open() {
        opened = true
        waiter?.resume()
        waiter = nil
    }
}

/// A press held open until the test lets it go.
@MainActor
final class PressGate {
    private var waiter: CheckedContinuation<Void, Never>?
    private var opened = false

    func wait() async {
        if opened { return }
        await withCheckedContinuation { waiter = $0 }
    }

    func open() {
        opened = true
        waiter?.resume()
        waiter = nil
    }
}
