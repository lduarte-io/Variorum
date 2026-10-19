//
//  RoadKeyDoorSurfaceTests.swift
//  VariorumTests — VX-308 U3 piece 6: THE KEY DOORS' AND VX-447's MAC FACES build and lay out (hosted in a real window — a
//  face that crashes or cannot lay out fails here) in every shape, the pane's and the bar's composition pinned by source,
//  and VX-448's clear AT THE LOCK through `AppBootstrap` over the planted road (a library closing behind the lobby empties
//  the words a look copied — a PRIVATE board; her clipboard is never a test's). The logic is the models' (pinned headless —
//  `RoadKeyDoorRoadTests`, `RoadKeyDoorsModelTests`, `NoKeyFileDoorTests`, `WordsConcealedClipboardTests`). Mac only.
//

import AppKit
import Foundation
import SwiftUI
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("VX-308 U3 — the key doors' and the banner door's Mac faces (hosted) and their composition", .serialized)
struct RoadKeyDoorSurfaceTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // Protection
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// A source file's CODE lines (comments dropped).
    private static func code(_ relative: String) throws -> String {
        let source = try String(contentsOf: appRoot.appendingPathComponent(relative), encoding: .utf8)
        return source.split(separator: "\n").filter {
            let line = $0.trimmingCharacters(in: .whitespaces)
            return !line.hasPrefix("//") && !line.hasPrefix("///")
        }.joined(separator: "\n")
    }

    private static func model(_ faces: RoadKeyDoorFaces?) async -> RoadKeyDoorsModel {
        let model = RoadKeyDoorsModel(roads: RoadKeyDoorRoads(read: { faces }, press: { _ in .refused("x") }))
        await model.refresh()
        return model
    }

    /// The passphrase's section hosts in each shape: both doors, a refusal in place, nothing (no passphrase — the set
    /// row stands in its place).
    @Test func theSectionHostsInEveryShape() async {
        for faces in [
            RoadKeyDoorsModelTests.faces(),
            RoadKeyDoorsModelTests.faces(
                change: .refused(ProtectionWords.doorRefusedFollowOwed),
                reset: .refused(ProtectionWords.doorRefusedFollowOwed)),
            RoadKeyDoorsModelTests.faces(change: .hidden, reset: .hidden),
        ] {
            let model = await Self.model(faces)
            await SurfaceComposition.host(
                Form { RoadKeyDoorsSection(model: model) }.formStyle(.grouped), size: NSSize(width: 640, height: 400))
        }
    }

    /// Each confirm hosts in its shape: Change (the current, a new one twice), Standard's reset, Castle's reset with and
    /// without Touch ID, a refusal said.
    @Test func eachConfirmHostsInItsShape() async throws {
        for door in [
            RoadKeyDoorsModelTests.open(.changePassphrase),
            RoadKeyDoorsModelTests.open(.resetForgottenPassphrase, reset: .plainConfirm),
            RoadKeyDoorsModelTests.open(.resetForgottenPassphrase, reset: .wordsOrTouchID(touchID: true),
                                        sentences: [ProtectionWords.keyDoorsLine, ProtectionWords.resetPassphraseCastleTouchIDLead]),
            RoadKeyDoorsModelTests.open(.resetForgottenPassphrase, reset: .wordsOrTouchID(touchID: false)),
        ] {
            let confirm = RoadKeyDoorConfirmModel(door: door, act: { _ in .refused(ProtectionWords.passphraseDoesNotOpen) }) { _ in }
            await SurfaceComposition.host(RoadKeyDoorSheet(model: confirm), size: NSSize(width: 480, height: 560))
        }
        let refusing = RoadKeyDoorConfirmModel(
            door: RoadKeyDoorsModelTests.open(.changePassphrase), act: { _ in .refused(ProtectionWords.passphraseDoesNotOpen) }) { _ in }
        await refusing.submit(current: "c", new: "n", again: "n")
        #expect(refusing.refusal == ProtectionWords.passphraseDoesNotOpen)
        await SurfaceComposition.host(RoadKeyDoorSheet(model: refusing), size: NSSize(width: 480, height: 560))
    }

    /// The words section — New Words — hosts with its face read (open; a refusal in place) and without one (U2b's door).
    @Test func theWordsSectionHostsWithNewWordsFace() async throws {
        let world = PlantedBand()
        let band = world.band()
        let standing = RoadStandingModel(
            faces: .none, reminder: band.reminder, setPassphrase: { _ in .set }, passphraseExists: { false },
            receiptsOwed: { [] }, band: band, mintWords: { _ in .minted((1...12).map { "word\($0)" }) })
        let refused = RoadKeyDoorFaces(
            changePassphrase: .hidden, newWords: .refused(ProtectionWords.doorRefusedNeedsVault), resetForgottenPassphrase: .hidden)
        for faces in [RoadKeyDoorsModelTests.faces(), refused] {
            let keyDoors = await Self.model(faces)
            await SurfaceComposition.host(
                Form { WordsLookSection(standing: standing, keyDoors: keyDoors) }.formStyle(.grouped),
                size: NSSize(width: 640, height: 400))
        }
        // The synced look's ask, the account line above it (F-U2-3).
        let synced = WordsLookModel(
            saysRuleSix: false, passphraseExists: { true }, replacesAccountWords: { true }, mint: { _ in .refused("") },
            copy: { _ in }, recorded: {})
        await synced.open()
        #expect(synced.saysAccountWords)
        await SurfaceComposition.host(
            WordsLookPanel(look: synced, tokens: VoiceTokens.fallback(for: .light)), size: NSSize(width: 640, height: 240))
    }

    /// VX-447's banner hosts in each state: the door offered, the look shown in the bar, and the stray arm (her U2-7
    /// words, no door).
    @Test func theBannerHostsAsTheDoorAndAsHerWords() async throws {
        let road = PlantedRoad()
        _ = try await road.created()
        let session = try await NoKeyFileDoorTests.openedWithNoKeyFileAnywhere(road)
        let store = ThrowawayDefaults()
        defer { store.purge() }
        let (standing, _) = NoKeyFileDoorTests.standing(session, store)
        #expect(standing.offersNoKeyFileDoor)
        await SurfaceComposition.host(ProtectionRoadBar(model: standing), size: NSSize(width: 900, height: 200))
        await standing.openNoKeyFileLook()
        #expect(standing.noKeyFileLook?.phase == .shown)
        await SurfaceComposition.host(ProtectionRoadBar(model: standing), size: NSSize(width: 900, height: 420))

        let strayRoad = PlantedRoad()
        _ = try await strayRoad.created()
        try Plant.strayBeside(strayRoad)
        strayRoad.memory.items = [:]
        guard case .opened(let straySession) = await ProtectionOpenRoad.route(strayRoad.context()) else {
            Issue.record("the silent item opens it")
            return
        }
        let (stray, _) = NoKeyFileDoorTests.standing(straySession, store)
        #expect(stray.showsNoKeyFileBanner && !stray.offersNoKeyFileDoor)
        await SurfaceComposition.host(ProtectionRoadBar(model: stray), size: NSSize(width: 900, height: 200))
    }

    /// THE COMPOSITION, BY SOURCE: the pane — the set row, then the key doors, then the words section (handed the key
    /// doors), the key doors re-read at each appearance; the presenter's host carries the key door's confirm; the
    /// bootstrap makes the key doors' model once beside the account section and hands it to the open library's faces; the
    /// bar's door is the whole line, its look the one look idiom, no raw pasteboard, no Return shortcut.
    @Test func theCompositionIsTheOnePresentersAndTheOneRead() throws {
        let pane = try Self.code("Variorum/Features/Settings/ProtectionPane.swift")
        let body = try #require(pane.range(of: "var body: some View {")).upperBound
        let rest = String(pane[body...])
        let setRow = try #require(rest.range(of: "roadPassphraseSection(roadStanding)"))
        let keyDoors = try #require(rest.range(of: "RoadKeyDoorsSection(model: keyDoors)"))
        let words = try #require(rest.range(of: "WordsLookSection(standing: roadStanding, keyDoors: roadStanding.keyDoors)"))
        #expect(setRow.lowerBound < keyDoors.lowerBound && keyDoors.lowerBound < words.lowerBound)
        // VX-308 ladder round 1 (MINOR-2) — FLIPPED DELIBERATELY: the three sections re-read from ONE read per appearance,
        // and the bootstrap hands each open library's faces that one read.
        #expect(rest.contains(".task { await roadStanding?.refreshPane() }"))
        #expect(!rest.contains(".task { await roadStanding?.keyDoors?.refresh() }"), "no second read of its own")
        #expect(rest.components(separatedBy: ".protectionSheets(").count == 2, "still one host on the pane")
        let host = try Self.code("Variorum/Features/Protection/RoadAccountSheet.swift")
        #expect(host.contains("case .keyDoor(let model):") && host.contains("RoadKeyDoorSheet(model: model)"))
        let bootstrap = try Self.code("Shared/AppBootstrap.swift")
        #expect(bootstrap.contains("roadKeyDoors = RoadKeyDoorsModel(roads: keyDoorRoads(), presenter: sheets)"))
        #expect(bootstrap.contains("roadStanding?.keyDoors = roadKeyDoors"))
        #expect(bootstrap.contains("roadStanding?.paneWave = { [weak self] in await self?.paneWave() ?? ProtectionPaneWave() }"))
        let bar = try Self.code("Variorum/Features/Protection/ProtectionRoadBar.swift")
        #expect(bar.contains("Text(ProtectionWords.noKeyFileDoor)") && bar.contains("await model.openNoKeyFileLook()"))
        #expect(bar.contains("WordsLookPanel(look: look, tokens: tokens)"))
        #expect(bar.contains("Text(ProtectionWords.noKeyFileAccountRoadOpen)"), "F-U2c-5's open-library variant")
        for road in ["NSPasteboard", ".textSelection(.enabled)", "keyboardShortcut", ".popover(", ".alert("] {
            #expect(!bar.contains(road), "the banner names \(road)")
        }
    }
}

/// VX-448's clear AT THE LOCK through `AppBootstrap` (a new-road bootstrap over the PLANTED road — no keychain): the words a
/// look copied leave the clipboard when the library closes behind the lobby (`finish`'s non-ready arm). RED ON OLD: the
/// pre-VX-448 bootstrap cleared nothing at the lock (the 60-second timer was the only clear).
@MainActor
@Suite("VX-308 U3 — VX-448: the words leave the clipboard when the library locks (through AppBootstrap)", .serialized)
struct WordsClipboardLockRouteTests {
    @Test func aLibraryClosingBehindTheLobbyEmptiesTheWordsALookCopied() async {
        await withRoadDependencies {
            let road = PlantedRoad()
            let url = road.slot.places.slot
            let bootstrap = AppBootstrap(
                testOpener: { .failure(AppDatabase.StoreOpenError(storePath: "", reason: "today's road is not taken here")) },
                gate: .scripted(dials: ProtectionDials(), backing: InMemoryStoreKeyGuardBacking()),
                testPresence: StoreFilePresence.classify(at: url),
                testStoreURL: url,
                protectionRoad: ProtectionRoadTestHarness(system: road.system(), session: .signedOut, open: { key in
                    Result { try AppDatabase.openStore(at: url, custody: .inMemory(initial: key)) }
                        .mapError { $0 as? AppDatabase.StoreOpenError
                            ?? AppDatabase.StoreOpenError(storePath: url.path, reason: String(describing: $0)) }
                }))
            await bootstrap.awaitOpen()
            if case .opening = bootstrap.state { await bootstrap.awaitOpen() }
            guard case .ready = bootstrap.state else {
                Issue.record("the planted slot creates and opens: \(bootstrap.state)")
                return
            }
            WordsClipboard.clearHeld()
            let board = WordsConcealedClipboardTests.privateBoard()
            defer { board.releaseGlobally() }
            WordsClipboard.copyConcealed(WordsConcealedClipboardTests.words, to: board)
            #expect(board.string(forType: .string) != nil && WordsClipboard.holdsACopy)
            // Both quiet roads gone; the reopen lands in the lobby — the library closed.
            road.custody.items = [:]
            road.apple.keys = [:]
            bootstrap.retry()
            await bootstrap.awaitOpen()
            guard case .roadLobby = bootstrap.state else {
                Issue.record("no quiet road remains — the lobby: \(bootstrap.state)")
                return
            }
            #expect(board.string(forType: .string) == nil, "the words left the clipboard at the lock")
            #expect(!WordsClipboard.holdsACopy)
        }
    }

    /// VX-308 U4 — THE LOCK ROAD'S TWIN (F-U3-3): Lock Now on a Castle library (VX-445 — the lock lands through `finish`'s
    /// non-ready arm) empties the words a look copied. RED ON OLD: before VX-445 the new road's `lock()` did nothing, so
    /// the concealed copy stayed on the board with the library open.
    @Test func lockNowOnACastleLibraryEmptiesTheWordsALookCopied() async throws {
        try await withRoadDependencies {
            let road = PlantedRoad()
            let (bootstrap, _) = try await LockWorld.readyInCastle(road)
            WordsClipboard.clearHeld()
            let board = WordsConcealedClipboardTests.privateBoard()
            defer { board.releaseGlobally() }
            WordsClipboard.copyConcealed(WordsConcealedClipboardTests.words, to: board)
            #expect(board.string(forType: .string) != nil && WordsClipboard.holdsACopy)
            #expect(bootstrap.canLock)
            await bootstrap.lock()
            _ = try LockWorld.lobby(bootstrap)
            #expect(board.string(forType: .string) == nil, "the words left the clipboard at the lock")
            #expect(!WordsClipboard.holdsACopy)
        }
    }
}
