//
//  ProdTestRoadTests.swift
//  VariorumTests — VX-510 unit B1, D-B3: THE PROD TEST ROAD (D-ROAD — her rulings R-510-1, "make a deliberate, narrow
//  exception so dev test accounts can reach production (a named road for named test accounts; never delete the fence that
//  keeps every other walk off prod)", and R-510-6, "Env flag + allowlist"). DEBUG walk machinery; Release byte-unchanged.
//
//  The road: a DEBUG launch with `VARIORUM_PROD_TEST_ROAD=1`, NO walk project (the two roads are exclusive), and the
//  allowlist file `~/.variorum/prod-test-accounts.env` at the REAL home — mode 600, a non-empty `VARIORUM_PRODTEST_EMAILS`
//  whose every entry carries `vxtest` — is ARMED: the dev store may configure sync (the coordinates stay production's), and
//  the ADMISSION is per account at every connect: only a LISTED account composes a chain; any other account (hers included)
//  keeps the fence and the sync row says why. Anything amiss refuses, fail-loud (one log line, never an email).
//
//  Testability: the launch's road is read once per process from its environment, so the pins inject the pieces — the switch,
//  the walk project and the allowlist read into the pure rule; the fence into `AppServices` through its dependency
//  (`\.devSyncFence`); real files under a temp folder for the read. This process launches with no switch (pinned).
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-510 D-B3 — the prod test road (DEBUG walk machinery): env flag + allowlist, admission per account", .serialized)
struct ProdTestRoadTests {
    typealias Road = ProtectionWalkSwitch

    static let std = "tester+vxtest-std@example.test"
    static let castle = "tester+vxtest-castle@example.test"
    static let hers = "her@example.test"

    /// An allowlist file in the generated file's shape (`gen-prod-test-accounts.sh`): comments, the one key, and secrets
    /// beside it that the road must never take for entries.
    static func allowlist(_ emails: String) -> String {
        """
        # VX-510 production TEST accounts. Mode 600.
        VARIORUM_PRODTEST_EMAILS="\(emails)"
        VARIORUM_PRODTEST_STD_EMAIL="\(std)"
        VARIORUM_PRODTEST_STD_PASSWORD="notanemailvxtest0"
        VARIORUM_PRODTEST_STD_PASSPHRASE="alsonotanemail1"
        """
    }

    static let armedRead = Road.AllowlistRead.present(mode: 0o600, contents: allowlist("\(std) \(castle)"))

    // MARK: - The launch decision (pure)

    /// THE FENCE HOLDS WITH NO SWITCH (ruled, pinned — R-510-6): anything but exactly `1` asks nothing, and the allowlist
    /// is never even read; the dev store never syncs.
    @Test func withNoSwitchTheFenceHoldsAndNothingIsRead() {
        for value in [nil, "", "0", "true", "yes", "2", "1 1"] as [String?] {
            var reads = 0
            let road = Road.prodTestRoad(switchValue: value, walkProject: nil, allowlist: {
                reads += 1
                return Self.armedRead
            })
            #expect(road == .none, "\(String(describing: value))")
            #expect(reads == 0, "no switch: the allowlist is never read")
            #expect(AppServices.allowsSync(storeVariant: .dev, walkLift: .none, prodTestRoad: road) == false)
        }
    }

    /// THE TWO ROADS ARE EXCLUSIVE: the switch with a walk project resolved refuses (the walk's coordinates are a
    /// throwaway's, the road's production's), before the allowlist is read; the fence stands.
    @Test func theSwitchWithAWalkProjectRefuses() throws {
        var reads = 0
        let walk = Road.WalkProject(url: try #require(URL(string: "https://walkthrowaway.supabase.co")), apiKey: "k")
        let road = Road.prodTestRoad(switchValue: "1", walkProject: walk, allowlist: {
            reads += 1
            return Self.armedRead
        })
        #expect(road == .refused(.walkProjectToo) && reads == 0)
        #expect(AppServices.allowsSync(storeVariant: .dev, walkLift: .none, prodTestRoad: road) == false)
    }

    /// EVERY ALLOWLIST REFUSAL, fail-loud and fail-closed: the file missing · unreadable (the sandbox's answer) · not mode
    /// 600 · naming no account · an entry without the plainly-test marker (her own address can never arm it).
    @Test func eachAllowlistFaultRefusesAndTheFenceStands() {
        let cases: [(Road.AllowlistRead, Road.ProdTestRoadRefusal)] = [
            (.missing, .allowlistMissing),
            (.unreadable, .allowlistUnreadable),
            (.present(mode: 0o644, contents: Self.allowlist(Self.std)), .allowlistNotPrivate),
            (.present(mode: 0o640, contents: Self.allowlist(Self.std)), .allowlistNotPrivate),
            (.present(mode: 0o600, contents: Self.allowlist("")), .allowlistEmpty),
            (.present(mode: 0o600, contents: "# nothing here\nVARIORUM_PRODTEST_STD_EMAIL=\"\(Self.std)\""), .allowlistEmpty),
            (.present(mode: 0o600, contents: Self.allowlist("\(Self.std) \(Self.hers)")), .unmarkedEntry),
        ]
        for (read, why) in cases {
            let road = Road.prodTestRoad(switchValue: "1", walkProject: nil, allowlist: { read })
            #expect(road == .refused(why), "\(read) → \(road)")
            #expect(!road.isArmed)
            #expect(AppServices.allowsSync(storeVariant: .dev, walkLift: .none, prodTestRoad: road) == false)
        }
    }

    /// ARMED: the switch, no walk project, a private file listing plainly-test addresses — the dev store may sync; the real
    /// store's road is unchanged.
    @Test func theSwitchAndAPrivateMarkedListArmTheRoad() {
        let road = Road.prodTestRoad(switchValue: " 1 ", walkProject: nil, allowlist: { Self.armedRead })
        #expect(road == .armed(Road.ProdTestAllowlist(emails: [Self.std, Self.castle])))
        #expect(AppServices.allowsSync(storeVariant: .dev, walkLift: .none, prodTestRoad: road) == true)
        #expect(AppServices.allowsSync(storeVariant: .real, walkLift: .none, prodTestRoad: road) == true)
    }

    /// THE FILE'S ONE KEY, parsed as the shell sources it: quotes optional, `export` optional, comments and every other key
    /// skipped (the secrets are never entries), case-folded, the last assignment winning.
    @Test func theAllowlistsOneKeyIsParsedAndNothingElse() {
        #expect(Road.allowlistEmails(Self.allowlist("\(Self.std)  \(Self.castle)")) == [Self.std, Self.castle])
        #expect(Road.allowlistEmails("export VARIORUM_PRODTEST_EMAILS='A+VXTEST@Example.test'") == ["a+vxtest@example.test"])
        #expect(Road.allowlistEmails("VARIORUM_PRODTEST_EMAILS=a+vxtest@x.test") == ["a+vxtest@x.test"])
        #expect(Road.allowlistEmails("VARIORUM_PRODTEST_EMAILS=\"a+vxtest@x.test\"\nVARIORUM_PRODTEST_EMAILS=\"b+vxtest@x.test\"")
            == ["b+vxtest@x.test"])
        #expect(Road.allowlistEmails("# VARIORUM_PRODTEST_EMAILS=\"a+vxtest@x.test\"").isEmpty, "a comment is no entry")
        #expect(!Road.allowlistEmails(Self.allowlist(Self.std)).contains { $0.contains("notanemail") }, "no secret read")
    }

    /// THE READ over real files: a private file's mode and text; a world-readable one's mode; missing; a symlink is never
    /// followed (unreadable).
    @Test func theReadReportsTheFilesModeAndNeverFollowsALink() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("vx510-b1-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let file = folder.appendingPathComponent("prod-test-accounts.env")
        try Self.allowlist(Self.std).write(to: file, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: file.path)
        #expect(Road.readAllowlist(atPath: file.path) == .present(mode: 0o600, contents: Self.allowlist(Self.std)))
        try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: file.path)
        guard case .present(let mode, _) = Road.readAllowlist(atPath: file.path) else {
            Issue.record("read")
            return
        }
        #expect(mode == 0o644)
        #expect(Road.readAllowlist(atPath: folder.appendingPathComponent("absent.env").path) == .missing)
        let link = folder.appendingPathComponent("link.env")
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: file)
        #expect(Road.readAllowlist(atPath: link.path) == .unreadable, "a link is never followed")
    }

    /// This process launches with no switch: its road is `.none` (the value every composition here reads).
    @Test func thisLaunchsRoadWithNoSwitchIsNone() throws {
        try #require(ProcessInfo.processInfo.environment[Road.prodTestRoadKey] == nil, "a launch with no road switch")
        #expect(ProjectConfig.prodTestRoad == .none)
        #expect(DevSyncFence.thisLaunch.prodTestRoad == .none)
    }

    // MARK: - The admission (pure), then through the real services

    static let armed = DevSyncFence(
        walkLift: .none, prodTestRoad: .armed(Road.ProdTestAllowlist(emails: [std, castle])))

    /// THE ADMISSION IS PER ACCOUNT (ruled, pinned — R-510-6: "refuses an unlisted account"): while the dev store syncs only
    /// by the road, a listed account is admitted (case-folded), an unlisted one — hers included — and no email are not; the
    /// real store and a walk-lifted dev store are never gated by the road.
    @Test func theAdmissionIsPerAccount() {
        #expect(AppServices.prodTestRoadAdmits(storeVariant: .dev, fence: Self.armed, email: Self.std))
        #expect(AppServices.prodTestRoadAdmits(storeVariant: .dev, fence: Self.armed, email: " TESTER+VXTEST-CASTLE@example.test "))
        #expect(!AppServices.prodTestRoadAdmits(storeVariant: .dev, fence: Self.armed, email: Self.hers), "hers: never listed")
        #expect(!AppServices.prodTestRoadAdmits(storeVariant: .dev, fence: Self.armed, email: nil))
        #expect(!AppServices.prodTestRoadAdmits(storeVariant: .dev, fence: Self.armed, email: ""))
        #expect(AppServices.prodTestRoadAdmits(storeVariant: .real, fence: Self.armed, email: Self.hers))
        let lifted = DevSyncFence(walkLift: .lifted(host: "walkthrowaway.supabase.co"), prodTestRoad: .none)
        #expect(AppServices.prodTestRoadAdmits(storeVariant: .dev, fence: lifted, email: Self.hers))
    }

    /// The world: an in-memory store, the fence injected, a signed-in session (the email the admission reads), an accepting
    /// fake server; the DEV store's services composed exactly as the roots compose them.
    private static func withServices(
        fence: DevSyncFence, email: String,
        _ body: @MainActor (AppServices, AuthSession, FirstRoundServer) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 510))
            $0.ownerIdentity = OwnerIdentity { "owner-510" }
            $0.devSyncFence = fence
        } operation: { @MainActor in
            let server = FirstRoundServer()
            let auth = AuthSession(
                configuration: AuthConfiguration(projectURL: URL(string: "https://vx510-road.invalid")!, apiKey: "k"),
                store: .inMemory(), http: { _ in throw AuthSessionError.malformedResponse("no network") })
            await auth.adopt(AuthTokens(
                accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(3600), userID: "owner-510",
                email: email))
            let services = AppServices(
                session: AppSession(database: db), storeVariant: .dev, backupEnabled: false, auth: auth,
                makeSyncTransport: { _ in server }, makeSyncKeyProvider: { AppTestKeyProvider() }, legacyCleanup: {})
            try await body(services, auth, server)
            services.stop()
            try? await Task.sleep(for: .milliseconds(200))
        }
    }

    /// ARMED + A LISTED ACCOUNT ⇒ THE CHAIN COMPOSES on the DEV store, and a round runs (against the fake here).
    @Test func armedAndListedComposesTheChain() async throws {
        try await Self.withServices(fence: Self.armed, email: Self.std) { services, _, server in
            #expect(services.sync.allowsSync, "armed: the dev store may sync")
            await services.start()
            #expect(services.sync.isConfigured, "a listed test account: the chain composed")
            #expect(!services.account.notOnTheProdTestRoad)
            #expect(SyncRowFace.prodTestRoadRefusal(refused: services.account.notOnTheProdTestRoad) == nil)
            guard case .ran(let status) = await services.runFirstRound() else {
                Issue.record("a round ran")
                return
            }
            #expect(status.lastError == nil && status.lastSuccessAt != nil)
            #expect(await server.pulls > 0)
        }
    }

    /// ARMED + AN UNLISTED ACCOUNT ⇒ NO CHAIN, AND THE ROW SAYS WHY (never "Sync off (dev store)" alone, never silent); a
    /// first round answers "not configured"; and a sign-in as a LISTED account re-runs the admission and composes.
    @Test func armedAndUnlistedComposesNothingAndTheRowSaysWhy() async throws {
        try await Self.withServices(fence: Self.armed, email: Self.hers) { services, auth, _ in
            #expect(services.sync.allowsSync)
            await services.start()
            #expect(!services.sync.isConfigured, "an unlisted account: no chain")
            #expect(services.account.notOnTheProdTestRoad, "the refusal recorded for the row")
            let face = try #require(SyncRowFace.prodTestRoadRefusal(refused: services.account.notOnTheProdTestRoad))
            #expect(face.kind == .notOnTheProdTestRoad)
            #expect(face.doors == [SyncRowFace.Door(label: "Account…", act: .openAccount(.account))])
            let line = SyncStatusRow.line(for: face.kind, lastSuccessAt: nil)
            #expect(line == SyncStatusRow.notOnTheProdTestRoadLabel)
            #expect(line == "Sync off (dev store) \u{2014} this account isn't a listed test account", "PROVISIONAL, hers")
            #expect(line != SyncStatusRow.line(for: .devStore, lastSuccessAt: nil), "never the dev-store line alone")
            #expect(await services.runFirstRound() == .notConfigured, "the admission holds on every road to a chain")

            await auth.adopt(AuthTokens(
                accessToken: "a2", refreshToken: "r2", expiresAt: Date().addingTimeInterval(3600), userID: "owner-510",
                email: Self.castle))
            await FirstRoundWorld.settle(seconds: 5) { services.sync.isConfigured }
            #expect(services.sync.isConfigured, "a sign-in as a listed account re-runs the admission")
            #expect(!services.account.notOnTheProdTestRoad, "and the row's refusal goes")
        }
    }

    // MARK: - By source: the row consults the road first; Release names nothing of it

    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath).resolvingSymlinksInPath().deletingLastPathComponent().deletingLastPathComponent()
    }

    private static func source(_ relative: String) throws -> String {
        try String(contentsOf: appRoot.appendingPathComponent(relative), encoding: .utf8)
    }

    /// The text a RELEASE build compiles: every `#if DEBUG` arm dropped (its `#else` kept), nested conditions honoured, and
    /// line comments stripped (an absence check must read code, never a mention).
    static func releaseText(_ source: String) -> String {
        var kept: [String] = []
        var frames: [(debug: Bool, inElse: Bool)] = []
        for line in source.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("#if ") {
                frames.append((debug: trimmed == "#if DEBUG", inElse: false))
                continue
            }
            if trimmed.hasPrefix("#else") || trimmed.hasPrefix("#elseif") {
                if !frames.isEmpty { frames[frames.count - 1].inElse = true }
                continue
            }
            if trimmed.hasPrefix("#endif") {
                if !frames.isEmpty { frames.removeLast() }
                continue
            }
            guard !frames.contains(where: { $0.debug && !$0.inElse }) else { continue }
            kept.append(line.components(separatedBy: "//").first ?? "")
        }
        return kept.joined(separator: "\n")
    }

    /// The row's face consults the road's refusal BEFORE its ordinary face, inside the DEBUG fence (the code, not a mention).
    @Test func theRowConsultsTheRoadsRefusalFirst() throws {
        let views = try Self.source("Shared/SyncStatusViews.swift")
        let face = try #require(views.range(of: "private var face: SyncRowFace {"))
        let body = views[face.upperBound...].prefix(600)
        let debug = try #require(body.range(of: "#if DEBUG"))
        let consult = try #require(body.range(
            of: "if let refusal = SyncRowFace.prodTestRoadRefusal(refused: services.account.notOnTheProdTestRoad) { return refusal }"))
        let ordinary = try #require(body.range(of: "return SyncRowFace.face("))
        #expect(debug.lowerBound < consult.lowerBound && consult.upperBound < ordinary.lowerBound)
    }

    /// **RELEASE BYTE-UNCHANGED (ruled — R-510-6)**: the text a Release build compiles names nothing of the road — every line
    /// of it lives inside a `#if DEBUG` arm (the walk-switch file is `#if DEBUG` whole), so the fence stays absolute.
    @Test func aReleaseBuildCompilesNothingOfTheRoad() throws {
        let names = ["ProdTestRoad", "prodTestRoad", "DevSyncFence", "devSyncFence", "devFence", "notOnTheProdTestRoad",
                     "VARIORUM_PROD_TEST_ROAD", "prodTest", "launchFence"]
        for file in ["Shared/AppServices.swift", "Shared/SyncStatusViews.swift", "Shared/ProjectConfig.swift",
                     "Shared/Protection/ProtectionWalkSwitch.swift"] {
            let release = Self.releaseText(try Self.source(file))
            for name in names {
                #expect(!release.contains(name), "\(file): Release compiles \(name)")
            }
        }
        // The stripper's own teeth: it keeps what Release compiles.
        let services = Self.releaseText(try Self.source("Shared/AppServices.swift"))
        #expect(services.contains("sync = SyncSession(database: session.database, allowsSync: storeVariant == .real)"))
        #expect(Self.releaseText(try Self.source("Shared/SyncStatusViews.swift")).contains("return SyncRowFace.face("))
    }
}
