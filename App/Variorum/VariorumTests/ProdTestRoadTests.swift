//
//  ProdTestRoadTests.swift
//  VariorumTests — VX-510 unit B1, D-B3: THE PROD TEST ROAD (D-ROAD — her rulings R-510-1, "make a deliberate, narrow
//  exception so dev test accounts can reach production (a named road for named test accounts; never delete the fence that
//  keeps every other walk off prod)", and R-510-6, "Env flag + allowlist"). DEBUG walk machinery; Release byte-unchanged.
//
//  The road: a DEBUG launch with `VARIORUM_PROD_TEST_ROAD=1`, NO walk project (the two roads are exclusive), and the
//  allowlist HANDED BY THE LAUNCH as `VARIORUM_PRODTEST_EMAILS` (F-B1-1 (B), ruled: the sandboxed Debug app cannot read
//  `~/.variorum/prod-test-accounts.env`, so the walk launcher reads that file — the one source of truth — and hands its one
//  key) — a non-empty list whose every entry carries `vxtest` — is ARMED: the dev store may configure sync (the coordinates
//  stay production's), and the ADMISSION is per account at every connect: only a LISTED account composes a chain; any other
//  account (hers included) keeps the fence and the sync row says why. Anything amiss refuses, fail-loud (one log line,
//  never an email).
//
//  Testability: the launch's road is read once per process from its environment, so the pins inject the pieces — the switch,
//  the walk project and the handed list into the pure rule, an environment into the launch's reading; the fence into
//  `AppServices` through its dependency (`\.devSyncFence`). This process launches with no switch (pinned).
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

    /// The handed list in the shape the launcher passes (the file's one key's value: space-separated).
    static let handed = "\(std) \(castle)"

    // MARK: - The launch decision (pure)

    /// THE FENCE HOLDS WITH NO SWITCH (ruled, pinned — R-510-6): anything but exactly `1` asks nothing, and the handed list
    /// is never even read; the dev store never syncs.
    @Test func withNoSwitchTheFenceHoldsAndNothingIsRead() {
        for value in [nil, "", "0", "true", "yes", "2", "1 1"] as [String?] {
            var reads = 0
            let road = Road.prodTestRoad(switchValue: value, walkProject: nil, allowlist: {
                reads += 1
                return Self.handed
            })
            #expect(road == .none, "\(String(describing: value))")
            #expect(reads == 0, "no switch: the handed list is never read")
            #expect(AppServices.allowsSync(storeVariant: .dev, walkLift: .none, prodTestRoad: road) == false)
        }
    }

    /// THE TWO ROADS ARE EXCLUSIVE: the switch with a walk project resolved refuses (the walk's coordinates are a
    /// throwaway's, the road's production's), before the handed list is read; the fence stands.
    @Test func theSwitchWithAWalkProjectRefuses() throws {
        var reads = 0
        let walk = Road.WalkProject(url: try #require(URL(string: "https://walkthrowaway.supabase.co")), apiKey: "k")
        let road = Road.prodTestRoad(switchValue: "1", walkProject: walk, allowlist: {
            reads += 1
            return Self.handed
        })
        #expect(road == .refused(.walkProjectToo) && reads == 0)
        #expect(AppServices.allowsSync(storeVariant: .dev, walkLift: .none, prodTestRoad: road) == false)
    }

    /// EVERY ALLOWLIST REFUSAL, fail-loud and fail-closed: nothing handed · an empty or blank list · an entry without the
    /// plainly-test marker (beside listed ones, or alone — her own address can never arm it).
    @Test func eachAllowlistFaultRefusesAndTheFenceStands() {
        let cases: [(String?, Road.ProdTestRoadRefusal)] = [
            (nil, .allowlistNotHanded),
            ("", .allowlistEmpty),
            ("   \t ", .allowlistEmpty),
            ("\"\"", .allowlistEmpty),
            ("\(Self.std) \(Self.hers)", .unmarkedEntry),
            (Self.hers, .unmarkedEntry),
            ("\(Self.std) author@gmail.com", .unmarkedEntry),
        ]
        for (handed, why) in cases {
            let road = Road.prodTestRoad(switchValue: "1", walkProject: nil, allowlist: { handed })
            #expect(road == .refused(why), "\(String(describing: handed)) → \(road)")
            #expect(!road.isArmed)
            #expect(AppServices.allowsSync(storeVariant: .dev, walkLift: .none, prodTestRoad: road) == false)
        }
    }

    /// ARMED: the switch, no walk project, a handed list of plainly-test addresses — the dev store may sync; the real
    /// store's road is unchanged.
    @Test func theSwitchAndAHandedMarkedListArmTheRoad() {
        let road = Road.prodTestRoad(switchValue: " 1 ", walkProject: nil, allowlist: { Self.handed })
        #expect(road == .armed(Road.ProdTestAllowlist(emails: [Self.std, Self.castle])))
        #expect(AppServices.allowsSync(storeVariant: .dev, walkLift: .none, prodTestRoad: road) == true)
        #expect(AppServices.allowsSync(storeVariant: .real, walkLift: .none, prodTestRoad: road) == true)
    }

    /// THE HANDED LIST, parsed as the file's one key: whitespace-split (any run of spaces, tabs or newlines), case-folded,
    /// one pair of surrounding quotes dropped; nothing else interpreted.
    @Test func theHandedListIsParsedAsTheFilesOneKey() {
        #expect(Road.allowlistEmails("\(Self.std)  \(Self.castle)") == [Self.std, Self.castle])
        #expect(Road.allowlistEmails(" \(Self.std)\t\n\(Self.castle) ") == [Self.std, Self.castle])
        #expect(Road.allowlistEmails("'A+VXTEST@Example.test'") == ["a+vxtest@example.test"])
        #expect(Road.allowlistEmails("\"a+vxtest@x.test b+vxtest@x.test\"") == ["a+vxtest@x.test", "b+vxtest@x.test"])
        #expect(Road.allowlistEmails("").isEmpty)
    }

    /// THE LAUNCH READS THE HANDED VALUE — never a file (F-B1-1 (B)): the launch's own reading over an environment arms on
    /// the switch plus the handed list, refuses the switch alone as nothing handed, and asks nothing without the switch
    /// however a list was handed.
    @Test func theLaunchReadsTheHandedListFromItsEnvironment() {
        let armed = Road.prodTestRoadForThisLaunch(walkProject: nil, environment: [
            Road.prodTestRoadKey: "1", Road.prodTestEmailsKey: Self.handed,
        ])
        #expect(armed == .armed(Road.ProdTestAllowlist(emails: [Self.std, Self.castle])), "the handed list arms the road")
        #expect(Road.prodTestRoadForThisLaunch(walkProject: nil, environment: [Road.prodTestRoadKey: "1"])
            == .refused(.allowlistNotHanded), "the switch alone: nothing handed — no file is read in its place")
        #expect(Road.prodTestRoadForThisLaunch(walkProject: nil, environment: [Road.prodTestEmailsKey: Self.handed])
            == .none, "a handed list without the switch asks nothing")
        #expect(Road.prodTestRoadForThisLaunch(walkProject: nil, environment: [
            Road.prodTestRoadKey: "1", Road.prodTestEmailsKey: "\(Self.std) \(Self.hers)",
        ]) == .refused(.unmarkedEntry), "an unmarked handed entry refuses the whole road")
    }

    /// The road reads NO FILE (F-B1-1 (B)): the walk switch's road section — code only, line comments stripped — opens no
    /// file, stats no path and looks up no home (the guard of the ruled shape; the launcher alone reads the file).
    @Test func theRoadReadsNoFile() throws {
        let file = try Self.source("Shared/Protection/ProtectionWalkSwitch.swift")
        let start = try #require(file.range(of: "// MARK: - VX-510 D-B3"))
        let end = try #require(file.range(of: "/// Forget `roads` through the production leaves"))
        let code = file[start.upperBound..<end.lowerBound].components(separatedBy: "\n")
            .map { $0.components(separatedBy: "//").first ?? "" }.joined(separator: "\n")
        for call in ["FileManager", "lstat(", "stat(", "getpwuid", "contents(atPath", "String(contentsOf", "fopen(", "open("] {
            #expect(!code.contains(call), "the road's code names \(call)")
        }
        #expect(code.contains("environment[prodTestEmailsKey]"), "the stripper's teeth: the handed read is code")
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

    /// HER-SHAPED ADDRESSES ARE NEVER ADMITTED (F-B1-1 (B)'s pin): the test accounts are plus-addresses on a real inbox, so
    /// an armed list of them must admit neither the bare inbox address nor any variant of it — case, a plus without the
    /// marker, a suffix — and a handed list that names the bare address refuses the road outright.
    @Test func aHerShapedAddressIsNeverAdmitted() {
        let tests = Road.ProdTestAllowlist(emails: ["author+vxtest-std@gmail.com", "author+vxtest-castle@gmail.com"])
        let fence = DevSyncFence(walkLift: .none, prodTestRoad: .armed(tests))
        for address in ["author@gmail.com", "AUTHOR@GMAIL.COM", " author@gmail.com ", "author+std@gmail.com",
                        "author+vxtest-std@gmail.com.example", "author+vxtest-std@gmail.co", "vxtest", "author"] {
            #expect(!tests.admits(address), "\(address)")
            #expect(!AppServices.prodTestRoadAdmits(storeVariant: .dev, fence: fence, email: address), "\(address)")
        }
        #expect(tests.admits("Author+VXTEST-std@gmail.com"), "the listed address itself, case-folded")
        #expect(Road.prodTestRoad(switchValue: "1", walkProject: nil, allowlist: {
            "author+vxtest-std@gmail.com author@gmail.com"
        }) == .refused(.unmarkedEntry), "the bare address handed beside a test one: the road never arms")
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
                     "VARIORUM_PROD_TEST_ROAD", "VARIORUM_PRODTEST", "prodTest", "launchFence"]
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
