//
//  ProtectionWalkSwitch.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1b — WALK MACHINERY, DEBUG ONLY (PROVISIONAL P-VX306-U1b-9; the `VARIORUM_SCALE_FIXTURE` /
//  `VARIORUM_SEED_GATE_UNOWNED` idiom: zero Release bytes, zero store state). The new road's custody items live
//  in the DATA PROTECTION keychain, which no command-line tool reaches ("There is no command-line tool access to
//  the data protection keychain" — DTS; `/usr/bin/security` reads file-based keychains only — the U1b record's
//  lookup), and its Apple keys are iCloud Keychain items, out of any CLI's reach. So the walk's rule-8 rows (the
//  lifecycle's stage 5: "the silent item deleted by hand → the Apple wrap opens silently and the item is re-made";
//  "both gone → the typed field at once") are walked through THIS switch: a launch with
//  `VARIORUM_WALK_FORGET=silent` (or `apple`, or `silent,apple`) forgets those quiet roads ONCE, before the route
//  reads its facts — as a keychain reset would — through the production leaves, then the road runs as ever.
//
//  VX-306 U2 adds `memory` — every item of what this Mac REMEMBERS (the memory items, their sealed key-file mirror
//  with them) — so the walk's rule-27 rows ("everything gone", and a quiet-road open with no key file anywhere) and
//  rule 21's "this Mac remembers nothing" can be walked: no CLI reaches those data-protection items either.
//
//  Fenced four ways: compiled only in DEBUG; reached only on the new road (the one switch — a Debug build on the
//  Mac, the dev store's variant only); never in a hosted test run (the road's `writes`); once per process. It
//  forgets only the DEV scope's own items: every SILENT custody item of the scope (`silent`), the Apple keys
//  stamped with the library the live key file names (`apple` — an iCloud delete reaches every device on the Apple
//  account, dev-scope names only), and every memory item of the scope (`memory`). Never a product road; the walk's
//  record names each use.
//

import Foundation
import VariorumCore

#if DEBUG
nonisolated enum ProtectionWalkSwitch {
    static let environmentKey = "VARIORUM_WALK_FORGET"

    enum Road: String, CaseIterable, Sendable {
        case silent
        case apple
        /// VX-306 U2: what this Mac remembers — every memory item of the scope.
        case memory
    }

    /// `silent`, `apple`, `memory`, comma-separated (order and spaces free); anything else names nothing.
    static func parse(_ value: String?) -> Set<Road> {
        Set((value ?? "").split(separator: ",").compactMap {
            Road(rawValue: $0.trimmingCharacters(in: .whitespaces).lowercased())
        })
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var spent = false

    /// The launch's one forgetting (the process environment's), before the route's facts. A second call does
    /// nothing.
    static func forgetOnceIfAsked(_ ctx: RoadContext, environment: [String: String] = ProcessInfo.processInfo.environment) {
        let roads = parse(environment[environmentKey])
        guard !roads.isEmpty, ctx.writes else { return }
        lock.lock()
        let first = !spent
        spent = true
        lock.unlock()
        guard first else { return }
        forget(roads, ctx.system)
    }

    // MARK: - VX-307 U2a — a planted failed Touch ID press (stage 11's re-arm)

    /// `VARIORUM_WALK_TOUCHID=fail`: the launch's first Touch ID press on an item that exists answers as one a biometry
    /// change invalidated (`KeychainCustodyLeaf.walkFailNextTouchIDPress` — nothing read; the press recorded
    /// `.failedOnExistingItem`), so the lobby shows the changed line and the typed open owes the re-arm question.
    /// THE FIRST PRESS IS USUALLY THE LOBBY'S AUTO-ASK (`RoadLockView`'s `.task` and its became-active hook): it spends
    /// the plant SILENTLY — the changed line, no prompt — and every later press is a REAL one (the system prompt; its
    /// cancel overwrites the failed press, so the re-arm is no longer owed). The walk TYPES the passphrase right after the
    /// changed line (ladder round 1, MINOR-3 — the armed and the pressed leaf are one instance within a composed road).
    /// PROVISIONAL P-VX307-U2a-6, the same four fences as the forgetting (DEBUG, the new road, a writing road, once per
    /// process).
    static let touchIDKey = "VARIORUM_WALK_TOUCHID"

    /// `fail` (case and spaces free) and nothing else.
    static func parseTouchID(_ value: String?) -> Bool {
        (value ?? "").trimmingCharacters(in: .whitespaces).lowercased() == "fail"
    }

    nonisolated(unsafe) private static var touchIDSpent = false

    /// The launch's one planted failure, armed on the road's custody leaf before the lobby presses. A second call does
    /// nothing; true when it armed one.
    @discardableResult
    static func failTouchIDOnceIfAsked(
        _ ctx: RoadContext, environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> Bool {
        guard parseTouchID(environment[touchIDKey]), ctx.writes,
              let custody = ctx.system.custody as? KeychainCustodyLeaf else { return false }
        lock.lock()
        let first = !touchIDSpent
        touchIDSpent = true
        lock.unlock()
        guard first else { return false }
        custody.walkFailNextTouchIDPress()
        ProtectionOpenRoad.log(
            "WALK SWITCH (\(touchIDKey)): the next Touch ID press fails on its item (stage 11's re-arm) — armed on leaf "
                + custody.walkInstanceName)
        return true
    }

    // MARK: - VX-308 U1 piece 0 — the walk's project coordinates (the account arms' walk against a throwaway project)

    /// `VARIORUM_WALK_PROJECT_URL` + `VARIORUM_WALK_ANON_KEY`: a DEBUG launch with BOTH set points `ProjectConfig`'s
    /// project coordinates — the sign-in, the vault client, every transport — at that project for THIS launch (the plan's
    /// §5 row 7: the account-sequence walk runs against a throwaway project carrying the held marker-14 artifact, never
    /// the production mirror). Read once per process at `ProjectConfig`'s first use, under `#if DEBUG` only; logged once
    /// (never the values). One of the two alone, a blank value, or a URL that is not https names nothing — the
    /// production coordinates stand. PROVISIONAL P-VX308-U1-0 (the fences' idiom: DEBUG, per-launch, logged once).
    static let projectURLKey = "VARIORUM_WALK_PROJECT_URL"
    static let projectKeyKey = "VARIORUM_WALK_ANON_KEY"

    struct WalkProject: Equatable, Sendable {
        let url: URL
        let apiKey: String
    }

    /// The override's rule, pure: both set (trimmed, non-empty) and the URL an https URL with a host → the pair.
    static func projectOverride(environment: [String: String]) -> WalkProject? {
        let rawURL = (environment[projectURLKey] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let key = (environment[projectKeyKey] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !rawURL.isEmpty, !key.isEmpty, let url = URL(string: rawURL), url.scheme?.lowercased() == "https",
              let host = url.host, !host.isEmpty
        else { return nil }
        return WalkProject(url: url, apiKey: key)
    }

    /// The launch's override, read once (`ProjectConfig`'s static lets call it at first use): the rule over this
    /// process's environment, said once in the protection log — that the coordinates are overridden, and whether they
    /// name the production mirror's own host — never the URL or the key.
    static func projectOverrideForThisLaunch(productionHost: String?) -> WalkProject? {
        guard let project = projectOverride(environment: ProcessInfo.processInfo.environment) else { return nil }
        let isProduction = project.url.host == productionHost
        ProtectionOpenRoad.log(
            "WALK SWITCH (\(projectURLKey) + \(projectKeyKey)): this launch's project coordinates are overridden — "
                + (isProduction ? "they name the production mirror's own host" : "a walk project's, not the production mirror"))
        return project
    }

    // MARK: - VX-483 — the A4 fence's walk lift (a walk's rounds land against the throwaway project, in the app)

    /// What THIS launch's walk project does to the A4 fence (a dev-store session never configures sync —
    /// `AppServices`' derivation). The lift is DEBUG walk machinery (this file is `#if DEBUG` whole), decided once per
    /// process from `ProjectConfig`'s OWN resolved walk project — never a second environment parse.
    enum SyncFenceLift: Equatable, Sendable {
        /// No walk project resolved this launch (no switch, or one that names nothing): the fence stands.
        case none
        /// A walk project that is NOT the production mirror: the dev store's sessions may configure sync against it (the
        /// coordinates `ProjectConfig` already points every transport and the sign-in at).
        case lifted(host: String)
        /// A walk project whose URL carries the production mirror's ref — REFUSED, fail-loud: the fence stands, and the
        /// launch says why.
        case refusedProduction(host: String)

        /// Whether the dev store may configure sync this launch.
        var lifts: Bool {
            if case .lifted = self { return true }
            return false
        }
    }

    /// The lift's rule, pure. `productionHost` is the production mirror's own host (`ProjectConfig.productionProjectURL`
    /// — the one place its ref is written); the REF is that host's first label, matched case-folded ANYWHERE in the walk
    /// project's URL (a subdomain, a trailing dot, a capitalised host, a path all refuse). A production host with no
    /// derivable ref refuses too — the fence fails closed.
    static func syncFenceLift(walkProject: WalkProject?, productionHost: String?) -> SyncFenceLift {
        guard let walkProject else { return .none }
        let host = walkProject.url.host ?? ""
        guard let ref = productionHost?.split(separator: ".").first.map({ $0.lowercased() }), !ref.isEmpty,
              !walkProject.url.absoluteString.lowercased().contains(ref)
        else { return .refusedProduction(host: host) }
        return .lifted(host: host)
    }

    /// The launch's one decision (`ProjectConfig.walkSyncFenceLift` calls it once, at first use), said once in the
    /// protection log — the host only, never the URL or the key. Nothing is said when no walk project resolved.
    static func syncFenceLiftForThisLaunch(walkProject: WalkProject?, productionHost: String?) -> SyncFenceLift {
        let lift = syncFenceLift(walkProject: walkProject, productionHost: productionHost)
        switch lift {
        case .none:
            break
        case .lifted(let host):
            ProtectionOpenRoad.log(
                "A4 FENCE (VX-483): LIFTED for this launch — the dev store may sync against the walk project at \(host), "
                    + "not the production mirror")
        case .refusedProduction(let host):
            ProtectionOpenRoad.log(
                "A4 FENCE (VX-483): the lift is REFUSED — the walk project (\(host)) carries the production mirror's ref; "
                    + "the dev store's sync fence stands")
        }
        return lift
    }

    // MARK: - VX-510 D-B3 — THE PROD TEST ROAD (R-510-1, R-510-6: "Env flag + allowlist"; F-B1-1 (B), ruled)

    /// `VARIORUM_PROD_TEST_ROAD=1`: a DEBUG launch asking for the named, narrow exception to the A4 fence — the DEV store may
    /// sync with PRODUCTION, and only while an account the allowlist names is signed in (her rulings R-510-1/-6: "a named
    /// road for named test accounts; never delete the fence that keeps every other walk off prod"). Release: absent.
    static let prodTestRoadKey = "VARIORUM_PROD_TEST_ROAD"
    /// The allowlist, HANDED BY THE LAUNCH (F-B1-1 (B), ruled): the sandboxed Debug app cannot read `~/.variorum/` (both
    /// configurations share one sandboxed entitlements file), so the walk launcher (`Tools/WalkKit/first-run-walk.sh`,
    /// outside the sandbox) reads the ONE source of truth — `~/.variorum/prod-test-accounts.env`, mode 600, every entry
    /// plainly-test — and hands that file's one key to the launch under the same name: a space-separated list of test
    /// emails. The app reads only this value — never a file — and keeps every guard of its own: exactly `1` asks, a walk
    /// project refuses, an empty list refuses, every entry carries the marker, and the admission is per account at connect.
    static let prodTestEmailsKey = "VARIORUM_PRODTEST_EMAILS"
    static let prodTestMarker = "vxtest"

    /// The listed test accounts, case-folded.
    struct ProdTestAllowlist: Equatable, Sendable {
        let emails: Set<String>

        /// Whether `email` (the signed-in account's) is listed — exactly, case-folded; no email is never listed.
        func admits(_ email: String?) -> Bool {
            guard let email = email?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !email.isEmpty
            else { return false }
            return emails.contains(email)
        }
    }

    /// Why an asked-for road did not arm (the launch says it once — never an email).
    enum ProdTestRoadRefusal: String, Equatable, Sendable {
        case walkProjectToo = "a walk project is set too — the two roads are exclusive"
        case allowlistNotHanded = "the launch handed no allowlist (VARIORUM_PRODTEST_EMAILS)"
        case allowlistEmpty = "the allowlist names no account"
        case unmarkedEntry = "an allowlist entry is not a plainly-test address"
    }

    /// THIS launch's prod test road.
    enum ProdTestRoad: Equatable, Sendable {
        /// Not asked (no `VARIORUM_PROD_TEST_ROAD=1`): the fence stands, nothing read.
        case none
        /// Asked and armed: the dev store may sync with production while a listed account is signed in.
        case armed(ProdTestAllowlist)
        /// Asked and refused, fail-loud: the fence stands, and the launch says why.
        case refused(ProdTestRoadRefusal)

        var isArmed: Bool {
            if case .armed = self { return true }
            return false
        }
    }

    /// The road's rule, pure. `switchValue`: the launch's `VARIORUM_PROD_TEST_ROAD` (exactly `1` asks); `walkProject`:
    /// `ProjectConfig`'s OWN resolved walk project (a walk project and the road are exclusive — the walk's coordinates are a
    /// throwaway's, the road's production's); `allowlist`: the launch's handed `VARIORUM_PRODTEST_EMAILS` (nil = not
    /// handed), read ONLY when the road was asked.
    static func prodTestRoad(
        switchValue: String?, walkProject: WalkProject?, allowlist: () -> String?
    ) -> ProdTestRoad {
        guard switchValue?.trimmingCharacters(in: .whitespacesAndNewlines) == "1" else { return .none }
        guard walkProject == nil else { return .refused(.walkProjectToo) }
        guard let handed = allowlist() else { return .refused(.allowlistNotHanded) }
        let emails = allowlistEmails(handed)
        guard !emails.isEmpty else { return .refused(.allowlistEmpty) }
        guard emails.allSatisfy({ $0.contains(prodTestMarker) }) else { return .refused(.unmarkedEntry) }
        return .armed(ProdTestAllowlist(emails: Set(emails)))
    }

    /// The handed list's entries — the file's one key's shape: whitespace-split, case-folded; one pair of surrounding quotes
    /// is dropped (a launcher that passed the file's quoted form), nothing else is interpreted.
    static func allowlistEmails(_ handed: String) -> [String] {
        var value = handed.trimmingCharacters(in: .whitespacesAndNewlines)
        if let quote = value.first, quote == "\"" || quote == "'", value.count >= 2, value.last == quote {
            value = String(value.dropFirst().dropLast())
        }
        return value.split(whereSeparator: \.isWhitespace).map { $0.lowercased() }
    }

    /// The launch's one road (`ProjectConfig.prodTestRoad` calls it once, at first use): the rule over THIS process's
    /// environment — the switch and the handed allowlist, never a file — said once in the protection log: armed (how many
    /// accounts, never which) or refused (why). Nothing is said when the road was not asked.
    static func prodTestRoadForThisLaunch(
        walkProject: WalkProject?, environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> ProdTestRoad {
        let road = prodTestRoad(
            switchValue: environment[prodTestRoadKey], walkProject: walkProject,
            allowlist: { environment[prodTestEmailsKey] })
        switch road {
        case .none:
            break
        case .armed(let list):
            ProtectionOpenRoad.log(
                "PROD TEST ROAD (VX-510): ARMED for this launch — the dev store may sync with PRODUCTION while one of the "
                    + "\(list.emails.count) listed test account(s) is signed in; any other account keeps the fence")
        case .refused(let why):
            ProtectionOpenRoad.log(
                "PROD TEST ROAD (VX-510): REFUSED — \(why.rawValue); the dev store's sync fence stands")
        }
        return road
    }

    /// Forget `roads` through the production leaves — the dev scope's silent items; this library's Apple keys.
    static func forget(_ roads: Set<Road>, _ system: ProtectionSystem) {
        if roads.contains(.silent) {
            let silent = ((try? system.leaves.custody.custodyItems()) ?? []).filter { $0.itemClass == .silent }
            for item in silent {
                try? system.leaves.custody.deleteCustody(fingerprint: item.fingerprint, itemClass: .silent)
            }
            ProtectionOpenRoad.log("WALK SWITCH (\(environmentKey)): forgot \(silent.count) silent custody item(s) of scope \(system.scope)")
        }
        if roads.contains(.apple) {
            let libraryID = ((try? system.leaves.keyFiles.readLiveKeyFile()) ?? nil)?.libraryID
            let ids = libraryID.flatMap { try? system.leaves.apple.appleKeyIDs(ofLibrary: $0) } ?? []
            for id in ids { try? system.leaves.apple.deleteAppleKey(id: id) }
            ProtectionOpenRoad.log("WALK SWITCH (\(environmentKey)): forgot \(ids.count) Apple key(s) of library \(String((libraryID ?? "none").prefix(8)))")
        }
        if roads.contains(.memory) {
            let remembered = (try? system.leaves.memory.rememberedLibraryIDs()) ?? []
            for libraryID in remembered { try? system.leaves.memory.deleteMemory(libraryID: libraryID) }
            ProtectionOpenRoad.log("WALK SWITCH (\(environmentKey)): forgot \(remembered.count) memory item(s) of scope \(system.scope)")
        }
    }
}
#endif
