//
//  SecretCheckModelTests.swift
//  VariorumTests — VX-510 D-B7 (VX-513, her R-510-15): THE READ-ONLY CHECK's door and sheet — `RoadKeyDoorsModel`'s
//  `offersCheck` / `openCheck` and `RoadSecretCheckModel` — over planted roads (no keychain, no disk, no window), then END TO
//  END through `AppBootstrap` on the planted road (unit A's `FirstRoundWorld`; no services needed). Headless in the
//  implementer's SwiftPM harness too.
//    - the door stands only where it can act (a library open with the key file of its key beside it, and a check road) — no
//      library open, no door; one protection sheet at a time through THE ONE PRESENTER;
//    - the sheet checks what was typed (untrimmed), says what the check said, and drops it the moment the field changes
//      (unit C's W-10) — a check still running then lands nothing; Close (and the host's dismissal) always closes, re-reads
//      nothing, speaks nothing; the sheet keeps no secret;
//    - through the bootstrap: the open library's check answers on the OPEN session, before and after the library syncs
//      (and the account's half with it), and writes nothing — no keychain item, no vault, no ledger of the library's;
//      locked behind the lobby, the door is gone and a check that still arrives refuses.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-510 D-B7 — the read-only check's door and sheet (planted roads)")
@MainActor
struct SecretCheckModelTests {
    /// A planted world: the faces it reads, the checks it was handed, what it answers, every re-read, receipt and landing.
    @MainActor
    final class World {
        var faces: RoadKeyDoorFaces? = World.standing()
        var answer: SecretCheckOutcome = .opens(.passphrase, account: .notSynced)
        var checked: [String] = []
        var reads = 0
        var receipts: [String] = []
        var landings = 0
        /// A check parked until `release` (nil: answers at once).
        var park: CheckedContinuation<Void, Never>?
        var parks = false
        let presenter = ProtectionSheetPresenter()
        var withCheck = true

        static func standing(_ stands: Bool = true) -> RoadKeyDoorFaces {
            var faces = RoadKeyDoorsModelTests.faces()
            faces.checkStands = stands
            return faces
        }

        /// The planted check road (nil when the world has none).
        var checkRoad: (@MainActor (String) async -> SecretCheckOutcome)? {
            guard withCheck else { return nil }
            return { [unowned self] typed in
                self.checked.append(typed)
                if self.parks {
                    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                        self.park = continuation
                    }
                }
                return self.answer
            }
        }

        lazy var model = RoadKeyDoorsModel(
            roads: RoadKeyDoorRoads(
                read: { [unowned self] in self.reads += 1; return self.faces },
                press: { _ in .refused("x") },
                receipt: { [unowned self] in self.receipts.append($0) },
                landed: { [unowned self] in self.landings += 1 },
                check: checkRoad),
            presenter: presenter)

        func release() {
            park?.resume()
            park = nil
        }
    }

    /// The door stands only where it can act: no faces (no library open), a face whose key file isn't beside the library,
    /// no check road — each renders no door and its press presents nothing; standing, the press presents the sheet through
    /// the one presenter; one protection sheet at a time either way.
    @Test func theDoorStandsOnlyWhereItCanAct() async throws {
        let world = World()
        world.faces = nil
        await world.model.refresh()
        #expect(!world.model.offersCheck, "no library open: no door")
        world.model.openCheck()
        #expect(world.presenter.sheet == nil)

        world.faces = World.standing(false)
        await world.model.refresh()
        #expect(!world.model.offersCheck, "no key file of the key beside the library: no door")

        let roadless = World()
        roadless.withCheck = false
        await roadless.model.refresh()
        #expect(!roadless.model.offersCheck, "no check road: no door")
        roadless.model.openCheck()
        #expect(roadless.presenter.sheet == nil)

        world.faces = World.standing()
        await world.model.refresh()
        #expect(world.model.offersCheck)
        world.model.openCheck()
        let sheet = try #require(world.model.checkSheet)
        #expect(world.presenter.sheet(for: .settings)?.id == sheet.id, "on Settings, its host")
        world.model.openCheck()
        world.model.open(.changePassphrase)
        #expect(world.model.checkSheet === sheet && world.model.confirm == nil, "one sheet at a time")
        sheet.close()
        world.presenter.present(.signIn(ProtectionSignInRequest(closed: {})), on: .settings)
        world.model.openCheck()
        #expect(world.model.checkSheet == nil, "another protection sheet standing holds the door back")
    }

    /// The sheet checks what was typed, UNTRIMMED, says what the check said, and nothing else happens: no receipt, no
    /// landing, no re-read. An empty field can't be checked.
    @Test func theSheetChecksWhatWasTypedAndSaysWhatTheCheckSaid() async throws {
        let world = World()
        await world.model.refresh()
        world.model.openCheck()
        let sheet = try #require(world.model.checkSheet)
        #expect(!sheet.canSubmit("") && sheet.canSubmit(" a "))
        await sheet.submit("")
        #expect(world.checked.isEmpty && sheet.outcome == nil)
        world.answer = .opens(.passphrase, account: .opens)
        await sheet.submit(" her passphrase ")
        #expect(world.checked == [" her passphrase "], "never trimmed")
        #expect(sheet.outcome == .opens(.passphrase, account: .opens) && !sheet.busy)
        #expect(sheet.outcome?.lines == ["That passphrase opens this library and your account."])
        world.answer = .doesNotOpen(.words, opensAccount: false)
        await sheet.submit("twelve words")
        #expect(sheet.outcome?.lines == [ProtectionWords.wordsDoNotOpen] && sheet.outcome?.warns == true)
        let readsBefore = world.reads
        sheet.close()
        #expect(world.presenter.sheet == nil && world.model.checkSheet == nil, "Close: the sheet goes")
        for _ in 0..<20 { await Task.yield() }
        #expect(world.receipts.isEmpty && world.landings == 0 && world.reads == readsBefore,
                "a check changes nothing: nothing said, nothing re-read")
    }

    /// W-10's lesson (unit C): what was said goes the moment the field changes — and a check still running then lands
    /// nothing (its answer is about text no longer typed); Close during a check lands nothing either.
    @Test func retypingClearsWhatWasSaidAndALateAnswerLandsNothing() async throws {
        let world = World()
        await world.model.refresh()
        world.model.openCheck()
        let sheet = try #require(world.model.checkSheet)
        await sheet.submit("first")
        #expect(sheet.outcome != nil)
        sheet.edited()
        #expect(sheet.outcome == nil, "the field changed: what was said is gone")

        world.parks = true
        let running = Task { await sheet.submit("second") }
        for _ in 0..<50 where world.park == nil { await Task.yield() }
        #expect(sheet.busy && !sheet.canSubmit("third"), "one check at a time")
        sheet.edited()
        world.release()
        await running.value
        #expect(sheet.outcome == nil && !sheet.busy, "the late answer is about text no longer typed — dropped")

        let closing = Task { await sheet.submit("fourth") }
        for _ in 0..<50 where world.park == nil { await Task.yield() }
        world.presenter.hostDismissed(.settings)
        #expect(world.presenter.sheet == nil, "the host's dismissal is Close, even mid-check (it reads only)")
        world.release()
        await closing.value
        #expect(sheet.outcome == nil && sheet.closed)
    }

    /// The sheet KEEPS NO SECRET: nothing it holds after a check carries what was typed (the text lives in the sheet's
    /// field alone).
    @Test func theSheetKeepsNoSecret() async throws {
        let world = World()
        await world.model.refresh()
        world.model.openCheck()
        let sheet = try #require(world.model.checkSheet)
        let secret = "a-secret-\(UUID().uuidString)"
        await sheet.submit(secret)
        func holds(_ value: Any, depth: Int = 0) -> Bool {
            if String(describing: value).contains(secret) { return true }
            guard depth < 4 else { return false }
            return Mirror(reflecting: value).children.contains { holds($0.value, depth: depth + 1) }
        }
        #expect(!holds(sheet), "the sheet holds nothing of what was typed")
        #expect(world.checked == [secret], "(the planted road saw it — the check itself is the road's)")
    }
}

@Suite("VX-510 D-B7 — the read-only check through AppBootstrap (planted road)", .serialized)
@MainActor
struct SecretCheckBootstrapTests {
    typealias Account = PlantedAccount

    static func keyDoors(_ world: FirstRoundWorld) async throws -> RoadKeyDoorsModel {
        let keyDoors = try #require(world.bootstrap.roadKeyDoors, "the bootstrap's key doors")
        #expect(world.bootstrap.roadStanding?.keyDoors === keyDoors, "the open library's faces carry them to the pane")
        await keyDoors.refresh()
        return keyDoors
    }

    /// What a check must never touch on the bootstrap's world: every keychain leaf's write log, every non-fetch vault call,
    /// the library's calm-asks ledger keys (the words card's — `variorum.calmAsks.words.<libraryID>.*`).
    static func untouched(_ world: FirstRoundWorld) throws -> [String] {
        let libraryID = try #require(world.bootstrap.roadSession?.library.record?.libraryID)
        let defaults = UserDefaults(suiteName: PassphraseReminderLedger.testSuiteName) ?? .standard
        let ledger = defaults.dictionaryRepresentation().keys.filter { $0.contains(libraryID) }.sorted()
            .map { "\($0)=\(String(describing: defaults.object(forKey: $0)))" }
        return world.road.custody.writes + world.road.memory.writes + world.road.apple.writes
            + world.vault.calls.filter { !$0.hasPrefix("fetch ") } + ledger
    }

    /// END TO END: the open library's door stands; its sheet checks on the OPEN session — the words open the library, a
    /// wrong passphrase does not; after Turn on sync, the account's half too (the passphrase opens both) — and nothing any
    /// check does writes a thing.
    @Test func theOpenLibrarysCheckRunsOnTheOpenSessionAndWritesNothing() async throws {
        try await FirstRoundWorld.run { world in
            let keyDoors = try await Self.keyDoors(world)
            #expect(keyDoors.offersCheck, "a library open, its key file beside it: the door stands")
            keyDoors.openCheck()
            var sheet = try #require(keyDoors.checkSheet)
            var before = try Self.untouched(world)
            await sheet.submit(world.words.joined(separator: " "))
            #expect(sheet.outcome == .opens(.words, account: .notSynced))
            await sheet.submit("not a passphrase it has")
            #expect(sheet.outcome == .doesNotOpen(.passphrase, opensAccount: false))
            #expect(try Self.untouched(world) == before, "nothing written")
            sheet.close()

            _ = try await FirstRunDrillTests.press(
                world, passphrase: Account.passphrase, again: Account.passphrase, words: world.words,
                expecting: .setsUpInLibrarysMode)
            #expect(world.bootstrap.roadSession?.library.record?.account == Account.account, "the library syncs now")
            #expect(world.bootstrap.protectionSheets?.sheet == nil, "the set-up's sheet went (no first-round road here)")
            await keyDoors.refresh()
            keyDoors.openCheck()
            sheet = try #require(keyDoors.checkSheet)
            before = try Self.untouched(world)
            let fetches = world.vault.calls.filter { $0.hasPrefix("fetch ") }.count
            let cache = world.bootstrap.roadSession?.executor.freshVaults
            await sheet.submit(Account.passphrase)
            #expect(sheet.outcome == .opens(.passphrase, account: .opens))
            await sheet.submit(world.words.joined(separator: " "))
            #expect(sheet.outcome == .opens(.words, account: .opens))
            // (≥: the set-up's landing re-reads the pane's sections on their own tasks, each a vault read of its own; the
            // road suite pins exactly one per check.)
            #expect(world.vault.calls.filter { $0.hasPrefix("fetch ") }.count >= fetches + 2, "the account's half read")
            #expect(try Self.untouched(world) == before, "nothing written")
            #expect(world.bootstrap.roadSession?.executor.freshVaults == cache,
                    "the check never touches the executor's session vault cache")
            sheet.close()
        }
    }

    /// NO LIBRARY OPEN, NO DOOR: behind the lobby (both quiet roads gone, the reopen lands there), the key doors' read says
    /// nothing, so the door is not rendered and its press presents nothing (the pane itself renders only on the ready arm);
    /// a check that still arrives on the road refuses.
    @Test func withNoLibraryOpenTheDoorIsGone() async throws {
        try await FirstRoundWorld.run { world in
            let keyDoors = try await Self.keyDoors(world)
            #expect(keyDoors.offersCheck)
            world.road.custody.items = [:]
            world.road.apple.keys = [:]
            world.bootstrap.retry()
            await world.bootstrap.awaitOpen()
            guard case .roadLobby = world.bootstrap.state else {
                Issue.record("no quiet road remains — the lobby: \(world.bootstrap.state)")
                return
            }
            await keyDoors.refresh()
            #expect(!keyDoors.offersCheck, "no library open: no door")
            keyDoors.openCheck()
            #expect(world.bootstrap.protectionSheets?.sheet == nil)
            let check = try #require(world.bootstrap.keyDoorRoads().check)
            #expect(await check(world.words.joined(separator: " ")) == .refused(ProtectionWords.crossingDoorClosed))
        }
    }
}
