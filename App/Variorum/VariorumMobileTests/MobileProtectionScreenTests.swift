//
//  MobileProtectionScreenTests.swift
//  VariorumMobileTests
//
//  VM-8 unit 1 — THE PHONE'S CASTLE CATCH-UP, its faces mounted for real (`MobileSurfaceDriver`: a real key window, the
//  real accessibility tree, real activation; the run record `notes/plans/vm-8-castle-catchup.md`, UNIT 1):
//    - piece 1 (F-U4-2): HER PRE-DESIGN FACE on the phone lobby — her lead and body, *Start fresh…* asking her confirm
//      first, the act on its yes; no lobby title, no road, no *Open Library…* (PROVISIONAL P-VM8-1). RED on the pre-fix
//      tree: the lobby rendered its standing fields over a pre-design store and no door at all.
//    - piece 2: THE PHONE'S PROTECTION SCREEN's account section over the SHARED faces (hand-made here — the faces are
//      pure values, the planted-road suites that derive them are the Mac's): the JOIN arm's door and confirm in the phone's
//      words (P-VM8-3/-4); F-U1-1's two rule-12 arms render NOTHING; the confirm's first round STAYS and says the phone's
//      close note (P-VM8-5) with Done; rule 7's words moment shows the typed words with no Copy door (P-2: the phone has
//      no words clipboard road); the composition (`attach(services:)` before `start()`, the reopen's ask adopted once).
//

import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import VariorumMobile

// MARK: - Piece 1 — her pre-design face

@Suite("VM-8 unit 1 — her pre-design face on the phone's lobby (F-U4-2, mounted)")
@MainActor
struct MobilePreDesignFaceTests {
    static let tokens = VoiceTokens.resolve(voice: .study, dark: false)

    /// A slot holding a store and an OLDER Variorum's key-file NAME beside it (never read) — `AssessRules.preDesignStore`.
    static func preDesignStanding() -> RoadLobbyFacts {
        let facts = ProtectionFacts(
            scope: "vm8-u1-face", storeFile: .present, containerMarker: false, rememberedLibraryIDs: [],
            rememberedKeyFileCopies: [], custody: [], custodyOpensLibrary: nil, biometry: .none,
            catalog: Catalog.build([CatalogEntry(place: .container, name: "variorum-keys.json")]), now: Date())
        return RoadLobbyFacts(facts: facts, offeredTyped: [])
    }

    final class Runs { var count = 0 }

    static func lobby(_ standing: RoadLobbyFacts, runs: Runs) -> ProtectionLobbyModel {
        ProtectionLobbyModel(
            standing: standing, typedRoad: { _ in .refused("") },
            touchIDRoad: { _ in .touchIDNotOpened(press: nil, biometry: .none, itemGone: true) },
            refreshRoad: { standing }, opened: { _ in }, recordMissing: {},
            startFresh: { runs.count += 1; return nil })
    }

    /// HER FACE: her lead, her body, *Start fresh…* — no lobby title, no typed road, no *Open Library…* door.
    @Test func herFaceSaysHerWordsAndOffersStartFreshAlone() async throws {
        let runs = Runs()
        let lobby = Self.lobby(Self.preDesignStanding(), runs: runs)
        #expect(lobby.face.preDesignStore && lobby.offersStartFresh, "precondition: the fact, and the act wired")
        await withHostedSurface(MobileRoadLockView(lobby: lobby, tokens: Self.tokens)) { surface in
            await surface.settle(30)
            let labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.preDesignLead), "her lead — labels were \(labels)")
            #expect(labels.contains(ProtectionWords.preDesignBody), "her body")
            #expect(labels.contains(ProtectionWords.preDesignStartFreshDoor), "her Start fresh… door")
            #expect(!labels.contains(ProtectionWords.lobbyTitle), "no lobby title on her face (P-VX329-U4-1)")
            #expect(!labels.contains(ProtectionWords.preDesignOpenDoor), "no Open Library… on the phone (P-VM8-1)")
            #expect(!labels.contains(ProtectionWords.openButton) && !labels.contains(ProtectionWords.wordsButton),
                    "no typed road over a store no key here opens")
            #expect(runs.count == 0, "nothing runs off the face alone")
        }
    }

    /// *Start fresh…* ASKS FIRST — her confirm line, *Start fresh* and *Cancel* — and the act runs on the yes, once.
    @Test func startFreshAsksHerConfirmThenActsOnTheYes() async throws {
        let runs = Runs()
        let lobby = Self.lobby(Self.preDesignStanding(), runs: runs)
        await withHostedSurface(MobileRoadLockView(lobby: lobby, tokens: Self.tokens)) { surface in
            await surface.settle(30)
            #expect(surface.activate(ProtectionWords.preDesignStartFreshDoor))
            await surface.settle(30)
            #expect(surface.presentedAlert?.title == ProtectionWords.preDesignStartFreshConfirm, "her confirm line")
            #expect(surface.alertActionTitles == [ProtectionWords.preDesignStartFreshButton, ProtectionWords.accountCancel],
                    "titles were \(surface.alertActionTitles)")
            #expect(runs.count == 0, "the door alone acts on nothing — the confirm first")
            #expect(surface.activateAlertAction(ProtectionWords.preDesignStartFreshButton))
            await surface.settle(20)
            #expect(runs.count == 1, "the act ran on her yes")
        }
    }

    /// GUARD (green on both sides): every slot but a pre-design one keeps the standing lobby — its title and its roads.
    @Test func everyOtherSlotKeepsTheStandingLobby() async throws {
        let runs = Runs()
        let lobby = Self.lobby(RoadLobbyFacts(facts: nil, offeredTyped: []), runs: runs)
        #expect(!lobby.face.preDesignStore)
        await withHostedSurface(MobileRoadLockView(lobby: lobby, tokens: Self.tokens)) { surface in
            await surface.settle(30)
            let labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.lobbyTitle), "labels were \(labels)")
            #expect(labels.contains(ProtectionWords.openButton), "the typed road stands")
            #expect(!labels.contains(ProtectionWords.preDesignStartFreshDoor))
        }
    }
}

// MARK: - Ladder round 1's MINOR-2 — the E6 line on the phone's lobby

@Suite("VM-8 ladder L1 — the phone lobby's E6 line (R-529-6: the why and the road), mounted")
@MainActor
struct MobileLobbyE6LineTests {
    /// **MINOR-2 — the pin unit 1's face fix never had (a bug-class face fix; red on `fd56f2279`'s `MobileRoadFaces.swift`,
    /// which rendered the field without its why):** a library that syncs but whose account's passphrase was never typed on
    /// this iPhone — a fresh library JOINED a Castle account by its twelve words, Always ask, so no passphrase lock of its
    /// own (E6 by birth) — locks; signed in, the lobby's vault road takes the account's passphrase, so the passphrase field
    /// stands and the shared face's line says why and the road, beneath the lead. Through the PHONE'S OWN bootstrap over
    /// planted leaves (`MobilePlantedProtection.swift`), the lobby the phone actually mounts.
    @Test func theLobbySaysTheE6LineBeneathItsLead() async throws {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            let world = MobileTypedUnlockSyncKeysTests.World()
            let accountsWords = try RecoveryPhrase.generate()
            _ = try world.vault.plant(
                accountID: MobileTypedUnlockSyncKeysTests.account, passphrase: MobileTypedUnlockSyncKeysTests.passphrase,
                words: accountsWords, mode: .castle)
            let bootstrap = AppBootstrap(testStoreURL: world.slot.places.slot, protectionRoad: world.harness())
            await bootstrap.awaitOpen()
            guard case .newLibraryWords(let card) = bootstrap.state else {
                Issue.record("a fresh slot creates a library and shows the phone's words card — \(bootstrap.state)")
                return
            }
            card.iveWrittenThemDown()
            await bootstrap.awaitOpen()
            let section = try #require(bootstrap.roadAccount, "the account section — \(bootstrap.state)")
            await section.refresh()
            _ = try #require(section.faces?.turnOnSync.openDoor, "the join arm stands — \(String(describing: section.faces))")
            section.open(.turnOnSync)
            let join = try #require(section.confirm, "the join's confirm on the presenter")
            join.gate = .alwaysAsk
            await join.submit(words: accountsWords.joined(separator: " "))
            await bootstrap.awaitOpen()
            #expect(join.refusal == nil, "the join by the twelve words landed — \(join.refusal ?? "")")
            join.closeMoment()
            #expect(bootstrap.roadSession?.library.record?.account == MobileTypedUnlockSyncKeysTests.account)

            await bootstrap.lock()
            guard case .roadLobby(let lobby) = bootstrap.state else {
                Issue.record("Castle under Always ask locks into the road's lobby — \(bootstrap.state)")
                return
            }
            #expect(lobby.face.accountPassphraseLine == ProtectionWords.lobbyAccountPassphraseNotTypedHere,
                    "precondition: E6 — \(lobby.face)")
            await withHostedSurface(MobileRoadLockView(lobby: lobby, tokens: MobilePreDesignFaceTests.tokens)) { surface in
                await surface.settle(30)
                let labels = surface.visibleLabels
                #expect(labels.contains(ProtectionWords.lobbyAccountPassphraseNotTypedHere),
                        "the E6 line — its why and its road — labels were \(labels)")
                #expect(labels.contains(lobby.face.lead), "beneath the lead")
                if let lead = labels.firstIndex(of: lobby.face.lead),
                   let line = labels.firstIndex(of: ProtectionWords.lobbyAccountPassphraseNotTypedHere) {
                    #expect(lead < line, "the line beneath the lead — labels were \(labels)")
                }
            }
        }
    }
}

// MARK: - Piece 2 — the Protection screen's account section

@Suite("VM-8 unit 1 — the phone's Protection screen: the account section over the shared faces (mounted)")
@MainActor
struct MobileProtectionAccountSectionTests {
    static let tokens = VoiceTokens.resolve(voice: .study, dark: false)
    static let faceID = RoadGateChoice(touchIDAvailable: true, preselected: .touchID)

    /// THE JOIN INTO CASTLE — her phone's arm: a fresh Standard library, her account in Castle (the core's spec shape:
    /// Use Castle's words, one secret, re-keying).
    static func joinIntoCastle() -> RoadAccountDoorOpen {
        let spec = DoorSpec(
            requires: .oneSecret, rekeys: true, synced: true, join: .entersCastle,
            words: [.floorSentence, .exportAPlainCopyFirst])
        var join = RoadAccountFaces.joinDoor(.turnOnSync, spec, library: .standard, gate: faceID, copyName: { _ in nil })
        join.label = ProtectionWords.joinSyncDoor
        join.accountEmail = "her@example.test"
        return join
    }

    static func faces(
        situation: RoadAccountSituation = .localOnly, turnOnSync: RoadAccountDoorFace = .hidden,
        move: RoadAccountDoorFace = .hidden, follow: RoadAccountDoorFace = .hidden, signIn: Bool = false
    ) -> RoadAccountFaces {
        RoadAccountFaces(
            situation: situation, turnOnSync: turnOnSync, stopSyncingHere: .hidden, deleteAccountHere: .hidden,
            thisMacOnly: .hidden, move: move, signOut: !signIn, signIn: signIn, vaultUnreachable: false, follow: follow)
    }

    static func model(_ faces: RoadAccountFaces) async -> RoadAccountModel {
        let model = RoadAccountModel(roads: RoadAccountRoads(read: { faces }, press: { _ in .refused("nothing") }))
        await model.refresh()
        return model
    }

    /// The section and the presenter's host, as the screen mounts them.
    struct Section: View {
        let model: RoadAccountModel
        var body: some View {
            ScrollView { MobileRoadAccountSection(model: model, tokens: MobileProtectionAccountSectionTests.tokens) }
                .modifier(MobileProtectionSheetsHost(
                    presenter: model.presenter, services: nil, tokens: MobileProtectionAccountSectionTests.tokens))
        }
    }

    /// THE JOIN ARM: its door is the join's own name ("Sync this library…" — P-VX510-3); pressed, its confirm says the
    /// join's sentences in the PHONE's words — no Data Safety pointer (P-VM8-4), the Face ID gate's line naming Face ID
    /// (P-VM8-3) — with the account's one secret, the two gate choices and the join's own button.
    @Test func theJoinArmsDoorAndConfirmSpeakThePhonesWords() async throws {
        let model = await Self.model(Self.faces(turnOnSync: .open(Self.joinIntoCastle())))
        await withHostedSurface(Section(model: model)) { surface in
            await surface.settle(30)
            #expect(surface.visibleLabels.contains(ProtectionWords.joinSyncDoor), "labels were \(surface.visibleLabels)")
            #expect(surface.activate(ProtectionWords.joinSyncDoor))
            await surface.settle(40)
            guard case .account(let confirm)? = model.presenter.sheet else {
                Issue.record("the join's confirm stands on the presenter")
                return
            }
            #expect(confirm.door.door == .turnOnSync && confirm.door.ask == .oneSecret)
            let labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.joinLead), "the join's lead — labels were \(labels)")
            #expect(labels.contains(ProtectionWords.castleFloor), "Castle's floor, the phone's biometry named")
            #expect(!labels.contains { $0.contains("Data Safety") }, "no pointer to a road the phone doesn't have (P-VM8-4)")
            #expect(labels.contains(ProtectionWords.gateTouchID) && labels.contains(ProtectionWords.gateAlwaysAsk),
                    "the gate choice: Face ID or Always ask")
            #expect(labels.contains("This iPhone keeps the new key behind Face ID."), "the phone's gate line (P-VM8-3)")
            #expect(!labels.contains { $0.contains("fingerprint") }, "a fingerprint is Touch ID's word")
            #expect(labels.contains(ProtectionWords.joinSyncButton), "the join's own button")
        }
    }

    /// F-U1-1, RULED (A): the arms whose confirm says HER rule-12 sentence — the join that leaves Castle, Move out of
    /// Castle, the follow out of Castle — render NOTHING on the phone (their words name the Mac; their phone wording is
    /// hers, F-PH-2); an ordinary follow beside them still renders.
    @Test func theRuleTwelveArmsRenderNothing() async throws {
        let leaving = DoorSpec(requires: .oneSecret, rekeys: true, synced: true, join: .leavesCastle, words: [.ruleFive])
        var join = RoadAccountFaces.joinDoor(.turnOnSync, leaving, library: .castle, gate: Self.faceID, copyName: { _ in nil })
        join.label = ProtectionWords.joinSyncDoor
        var move = RoadAccountFaces.joinDoor(
            .moveToSignedInAccount, leaving, library: .castle, gate: Self.faceID, copyName: { _ in nil })
        move.label = ProtectionWords.moveDoor("other@example.test")
        let out = RoadAccountFaces.followDoor(
            .intoStandard, DoorSpec(requires: .none, rekeys: true, synced: true, words: [.ruleFive]), vault: nil,
            exportOn: false, gate: Self.faceID)
        #expect(join.saysRuleTwelve && move.saysRuleTwelve && out.saysRuleTwelve, "precondition: each says rule 12")
        #expect(join.sentences.contains(ProtectionWords.leaveSentence))

        let localOnly = await Self.model(Self.faces(turnOnSync: .open(join)))
        await withHostedSurface(Section(model: localOnly)) { surface in
            await surface.settle(30)
            let labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.accountLocalOnly), "the situation still says itself — \(labels)")
            #expect(!labels.contains(ProtectionWords.joinSyncDoor), "the Castle-leaving join renders nothing")
        }
        let other = await Self.model(Self.faces(
            situation: .otherAccount(signedInEmail: "other@example.test", sameEmail: false), move: .open(move)))
        await withHostedSurface(Section(model: other)) { surface in
            await surface.settle(30)
            #expect(!surface.visibleLabels.contains(ProtectionWords.moveDoor("other@example.test")),
                    "Move out of Castle renders nothing")
        }
        let inSync = await Self.model(Self.faces(situation: .inSync(email: nil), follow: .open(out)))
        await withHostedSurface(Section(model: inSync)) { surface in
            await surface.settle(30)
            let labels = surface.visibleLabels
            #expect(!labels.contains(ProtectionWords.followDoor), "the follow out of Castle renders nothing — \(labels)")
            #expect(!labels.contains { $0.contains("this Mac") }, "her Mac-naming sentence is never said here")
        }
        // An ordinary follow (into Castle — no rule-12 sentence) renders, its notice beside its door.
        let into = RoadAccountFaces.followDoor(
            .intoCastle, DoorSpec(requires: .oneSecret, rekeys: true, synced: true), vault: nil, exportOn: false,
            gate: Self.faceID)
        let following = await Self.model(Self.faces(situation: .inSync(email: nil), follow: .open(into)))
        await withHostedSurface(Section(model: following)) { surface in
            await surface.settle(30)
            #expect(surface.visibleLabels.contains(ProtectionWords.followDoor), "labels were \(surface.visibleLabels)")
        }
    }

    /// THE FIRST ROUND STAYS (P-VX510-1's shape): the act landed, the sheet shows the round running with the PHONE's close
    /// note (P-VM8-5) and Done; when the round comes back, the join's success line — Done still the one door.
    @Test func theFirstRoundSheetStaysWithThePhonesCloseNoteThenSaysItsOutcome() async throws {
        final class Gate { var resume: CheckedContinuation<Void, Never>? }
        let gate = Gate()
        var finished: [RoadAccountPress?] = []
        let confirm = RoadAccountConfirmModel(
            door: Self.joinIntoCastle(), act: { _ in .made(receipt: nil, wordsReplaced: false) },
            firstRound: {
                await withCheckedContinuation { gate.resume = $0 }
                var status = SyncScheduler.Status()
                status.lastSuccessAt = Date()
                return .ran(status)
            },
            finished: { finished.append($0) })
        await confirm.submit(passphrase: "the account's passphrase")
        #expect(confirm.round == .running, "the act landed; its first round runs")
        await withHostedSurface(MobileRoadAccountConfirmSheet(model: confirm, tokens: Self.tokens)) { surface in
            await surface.settle(30)
            var labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.firstRoundProgress), "labels were \(labels)")
            #expect(labels.contains("You can close this \u{2014} sync keeps going, and Settings says when it's done."),
                    "the phone's close note (P-VM8-5)")
            #expect(!labels.contains { $0.contains("bottom of the window") }, "no window bar on the phone")
            #expect(labels.contains(ProtectionWords.firstRoundDone), "Done is open throughout")
            #expect(finished.isEmpty, "the sheet stays")
            gate.resume?.resume()
            _ = await confirm.awaitFirstRound()
            await surface.settle(30)
            labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.firstRoundJoinLanded), "the join's line — labels were \(labels)")
            #expect(surface.activate(ProtectionWords.firstRoundDone))
            await surface.settle(10)
            #expect(finished.count == 1, "Done closes it, the act's landing finished once")
        }
    }

    /// RULE 7's WORDS MOMENT on the phone: the words she typed, shown once under her sentence, with the close behind her
    /// warning — and NO Copy door (the phone has no words clipboard road — P-2).
    @Test func theWordsMomentShowsTheTypedWordsWithNoCopyDoor() async throws {
        let words = try RecoveryPhrase.generate()
        let confirm = RoadAccountConfirmModel(
            door: Self.joinIntoCastle(), act: { _ in .made(receipt: nil, wordsReplaced: true) }, finished: { _ in })
        await confirm.submit(words: words.joined(separator: " "))
        guard case .shown? = confirm.moment else {
            Issue.record("the typed words' moment stands")
            return
        }
        await withHostedSurface(MobileRoadAccountConfirmSheet(model: confirm, tokens: Self.tokens)) { surface in
            await surface.settle(30)
            let labels = surface.visibleLabels
            #expect(labels.contains(ProtectionWords.joinWordsSentence), "rule 7's sentence — labels were \(labels)")
            #expect(labels.contains(words[0]) && labels.contains(words[11]), "the twelve words, once")
            #expect(labels.contains(ProtectionWords.wordsLookWrittenDown))
            #expect(!labels.contains(ProtectionWords.wordsLookCopy), "no Copy door on the phone")
        }
    }
}

// MARK: - Piece 2 — the composition

@Suite("VM-8 unit 1 — the phone's composition: the services-held roads and the reopen's ask")
@MainActor
struct MobileProtectionCompositionTests {
    static let appRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // VariorumMobileTests
        .deletingLastPathComponent()  // App/Variorum

    static func code(_ path: String) throws -> String {
        try String(contentsOf: appRoot.appendingPathComponent(path), encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line in line.range(of: "//").map { String(line[..<$0.lowerBound]) } ?? String(line) }
            .joined(separator: "\n")
    }

    /// THE SERVICES-HELD ROADS (VX-510 D-A1/D-B0 — the first round, the re-keying act's round, sign-out, the deletion
    /// hook) are wired through the bootstrap's ONE function from the phone's root, BEFORE `start()` (so a re-keying act's
    /// round rides the chain the start composes). RED on the pre-fix tree: the phone wired only the deletion hook, inline.
    @Test func thePhonesRootAttachesItsServicesBeforeStart() throws {
        let root = try Self.code("VariorumMobile/VariorumMobileApp.swift")
        let attach = try #require(root.range(of: "bootstrap.attach(services: fresh)"), "the phone attaches its services")
        let start = try #require(root.range(of: "await fresh.start()"))
        #expect(attach.upperBound <= start.lowerBound, "attached before start()")
        #expect(!root.contains("fresh.afterAccountDeleted ="), "the deletion hook rides the one function")
    }

    /// F-U1-3 — THE REOPEN'S ASK: adopted ONCE per ask (the controller's counter and its mark outlive the shell), and the
    /// shell adopts it on appear and on change, pushing the Protection screen on the shelf's stack.
    @Test func theReopensAskIsAdoptedOnceAndPushesTheScreen() throws {
        let protection = ProtectionController()
        #expect(!MobileShellView.adoptsProtectionRequest(protection), "nothing asked, nothing adopted")
        protection.requestProtectionPaneForRoadCrossing()
        #expect(MobileShellView.adoptsProtectionRequest(protection), "the reopen's ask is adopted")
        #expect(!MobileShellView.adoptsProtectionRequest(protection), "…once")
        protection.requestProtectionPane()
        #expect(MobileShellView.adoptsProtectionRequest(protection), "a fresh ask is adopted again")
        let shell = try Self.code("VariorumMobile/Features/Shell/MobileShellView.swift")
        #expect(shell.contains(".onAppear { adoptProtectionRequest() }"))
        #expect(shell.contains(".onChange(of: bootstrap?.protection.settingsRequest) { _, _ in adoptProtectionRequest() }"))
        #expect(shell.contains("shelfPath = NavigationPath([MobileRoute.protection])"))
        #expect(shell.contains("MobileProtectionScreen(standing: bootstrap?.roadStanding, services: services, tokens: tokens)"))
    }

    /// The Settings row and the sync row's *Protection…* door (VX-486's, given its phone home) both open the screen, and
    /// only where it can act (the shell's road, the app's services — ladder L1's NIT-2 — AND an account section on the open
    /// library — P-2).
    @Test func settingsOpensTheScreenOnlyWhereItCanAct() throws {
        let settings = try Self.code("VariorumMobile/Features/Shell/MobileSettingsView.swift")
        #expect(settings.contains(
            "guard let onOpenProtection, services != nil, bootstrap?.roadStanding?.account != nil else { return nil }"))
        #expect(settings.contains(".environment(\\.protectionPaneDoor, protectionDoor.map { open in ProtectionPaneDoor { open() } })"))
        #expect(settings.contains("if let protectionDoor {"))
        let shell = try Self.code("VariorumMobile/Features/Shell/MobileShellView.swift")
        #expect(shell.contains("onOpenProtection: { openProtection() }"))
        #expect(shell.contains("leavingShelf { shelfPath.append(MobileRoute.protection) }"))
    }

    /// **Ladder round 1's NIT-2 — RED ON THE PRE-L1 TREE:** before the app's services are composed (the `.ready` arm's
    /// `.task` makes them; the sync row says *Starting…* meanwhile), Settings rendered *Protection…* on the account section
    /// alone — and the screen's *Sign in…* then had no Account sheet to present (only the Mac's "in this window" sentence).
    /// Now the row stands only beside services (P-2: a door that cannot act is not rendered). Mounted for real over the
    /// PHONE'S OWN bootstrap (a fresh library open on the road — its account section made) with no services.
    @Test func noServicesNoProtectionRow() async {
        await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            let world = MobileTypedUnlockSyncKeysTests.World()
            let bootstrap = AppBootstrap(testStoreURL: world.slot.places.slot, protectionRoad: world.harness())
            await bootstrap.awaitOpen()
            guard case .newLibraryWords(let card) = bootstrap.state else {
                Issue.record("a fresh slot creates a library — \(bootstrap.state)")
                return
            }
            card.iveWrittenThemDown()
            await bootstrap.awaitOpen()
            guard case .ready(let session) = bootstrap.state else {
                Issue.record("the library opens — \(bootstrap.state)")
                return
            }
            #expect(bootstrap.roadStanding?.account != nil, "precondition: the account section stands")
            let store = U2Faces.Defaults()
            let settings = MobileSettingsView(
                session: session, router: MobileShellRouter(defaults: store.defaults), services: nil,
                bootstrap: bootstrap, onOpenProtection: {})
            await withHostedSurface(settings) { surface in
                await surface.settle(30)
                let labels = surface.visibleLabels
                #expect(labels.contains { $0.lowercased() == "starting\u{2026}" },
                        "the sync row's own not-yet, beside it — labels were \(labels)")
                #expect(!labels.contains(SyncRowFace.openProtectionLabel),
                        "no Protection… row while no services exist — labels were \(labels)")
            }
        }
    }
}
