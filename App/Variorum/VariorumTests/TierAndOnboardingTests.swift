//
//  TierAndOnboardingTests.swift
//  VariorumTests
//
//  Phase 14c, batch 3 (L7 + L8) — the hosted-sync tier's gate UX and the
//  stranger's front door, pinned:
//   - the tier refusal (`SyncError.syncNotEntitled`) presents as a NORMAL
//     row, never an error face (the v1 principle: sync is the tier, the
//     app is not) — red-on-old against the generic `.error` face;
//   - the tier classifier stays disjoint from every keys classifier;
//   - the copy is honest and PRICE-AGNOSTIC (works-fully-without-it, the
//     stargazing.tech pointer, no numbers anywhere);
//   - the promoted entitlement read (B2-3's real home) feeds
//     `AccountState.hostedSync`, and the deletion door's note DERIVES
//     from the same read;
//   - the sign-up refusals classify and speak (the R94 doctrine at the
//     account-creation door), the signups-off toggle above all: a closed
//     door in words, never a generic failure.
//

import Foundation
import Dependencies
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The tier face (L7)

@MainActor
@Suite("The hosted-sync tier face (Phase 14c, batch 3)")
struct HostedSyncTierFaceTests {
    /// THE TIER ROW READS AS NORMAL (red-on-old: the pre-batch face for
    /// this error was `.error` — red label, Retry door): kind is the
    /// dedicated `.notEntitled`, and the doors are the IDLE row's own —
    /// "Sync now" enabled (activation heals on the next round, no
    /// relaunch) and "Account…" opening the tab whose tier section says
    /// what the tier is.
    @Test func theTierRefusalPresentsAsANormalRowWithTheIdleDoors() {
        let face = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true,
            isSyncing: false,
            lastError: String(describing: SyncError.syncNotEntitled),
            lastErrorIsOffline: false)
        #expect(face.kind == .notEntitled)
        #expect(face.doors == [
            SyncRowFace.Door(label: "Sync now", act: .syncNow),
            SyncRowFace.Door(label: "Account…", act: .openAccount(.account)),
        ], "the unentitled row offers exactly the idle row's doors — normal, never degraded")

        let idle = SyncRowFace.face(
            allowsSync: true, isConfigured: true, signedIn: true,
            isSyncing: false, lastError: nil, lastErrorIsOffline: false)
        #expect(face.doors == idle.doors,
                "the doors are LITERALLY the idle doors — the reads-as-normal principle in data")
    }

    /// The tier classifier is exact and disjoint from every keys
    /// classifier — commerce state never wears a keys face, and keys
    /// states never wear the tier's.
    @Test func theTierClassifierIsExactAndDisjointFromKeysClassifiers() {
        let tier = String(describing: SyncError.syncNotEntitled)
        #expect(HostedSyncTier.isNotEntitledError(tier))
        #expect(!HostedSyncTier.isNotEntitledError(
            String(describing: SyncError.encryptionKeysReplaced)))
        #expect(!HostedSyncTier.isNotEntitledError(
            String(describing: SyncError.encryptionKeysUnavailable)))
        #expect(!HostedSyncTier.isNotEntitledError("Sync error: something else"))
        #expect(!SyncRowFace.isKeysReplacedError(tier))
        #expect(!SyncRowFace.isKeysLockedError(tier))
        #expect(!SyncRowFace.isPayloadCryptoError(tier))
    }

    /// The tier copy: honest (what it is · works fully without it · where
    /// it lives) and PRICE-AGNOSTIC — she names the number at launch, so
    /// no price-shaped token may appear anywhere in the tier's statics.
    @Test func theTierCopyIsHonestAndPriceAgnostic() {
        #expect(HostedSyncTier.whatItIs.contains("end-to-end encrypted"),
                "the tier's first fact is the E2EE promise")
        #expect(HostedSyncTier.worksWithoutIt.contains("works fully without"),
                "the v1 principle's own sentence")
        #expect(HostedSyncTier.whereToGetIt.contains("stargazing.tech"),
                "where the tier lives — the web-first ruling")
        #expect(HostedSyncTier.rowLabel.contains("hosted sync isn't active"),
                "the row names the state, quietly")
        for copy in [HostedSyncTier.rowLabel, HostedSyncTier.activeLine,
                     HostedSyncTier.whatItIs, HostedSyncTier.worksWithoutIt,
                     HostedSyncTier.whereToGetIt, AccountView.signUpFootnote] {
            for token in ["$", "€", "per month", "/month", "price"] {
                #expect(!copy.lowercased().contains(token),
                        "price-agnostic machinery — no '\(token)' in: \(copy)")
            }
        }
    }

    /// Ladder R1-3 (round 1), RED-ON-OLD: PostgREST serializes
    /// `timestamptz` with an offset and up to six fractional digits
    /// whenever the microseconds are non-zero — so a real server expiry
    /// commonly reads "….123456+00:00", and the shipped parse (canonical
    /// millisecond-Z DateFormatter, then a plain `ISO8601DateFormatter`)
    /// returned nil on EVERY fractional shape, making the fail-open
    /// "unparseable counts current" arm the LIKELY arm: an EXPIRED
    /// subscription's Account tab said "Hosted sync is active". The
    /// fractional-seconds fallback closes it; the fail-open arm survives
    /// for genuinely alien text (the recorded design call).
    @Test func postgRESTFractionalTimestampsParseAndExpire() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        // A genuinely expired subscription, PostgREST-shaped: reads
        // EXPIRED (red-on-old: it counted current).
        #expect(!HostedSyncTier.isCurrent(
            AccountEntitlement(
                feature: "hosted_sync", expiresAt: "2020-01-01T00:00:00.123456+00:00"),
            now: now))
        // The same shape in the future: CURRENT because the parse works —
        // not the fail-open arm wearing a green coat.
        #expect(HostedSyncTier.isCurrent(
            AccountEntitlement(
                feature: "hosted_sync", expiresAt: "2036-01-01T00:00:00.123456+00:00"),
            now: now))
        // Postgres trims trailing fraction zeros — short fractions parse
        // too (red-on-old), and the no-fraction offset shape stays green.
        #expect(!HostedSyncTier.isCurrent(
            AccountEntitlement(
                feature: "hosted_sync", expiresAt: "2020-01-01T00:00:00.12+00:00"),
            now: now))
        #expect(!HostedSyncTier.isCurrent(
            AccountEntitlement(
                feature: "hosted_sync", expiresAt: "2020-01-01T00:00:00+00:00"),
            now: now))
        // The expiry footnote parses the fractional shape instead of
        // silently omitting a real date (red-on-old: nil).
        #expect(HostedSyncTier.expiryLine("2036-01-01T00:00:00.123456+00:00") != nil)
    }

    /// `isCurrent`: NULL expiry is non-expiring (09's letter); a future
    /// expiry is current; a past one is not; an unparseable one counts as
    /// current (the server's own gates parse authoritatively — the client
    /// must not manufacture a refusal the server never made).
    @Test func entitlementCurrencyFollowsTheColumnsLetter() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        #expect(HostedSyncTier.isCurrent(
            AccountEntitlement(feature: "hosted_sync"), now: now))
        #expect(HostedSyncTier.isCurrent(
            AccountEntitlement(feature: "hosted_sync", expiresAt: "2036-01-01T00:00:00Z"),
            now: now))
        #expect(!HostedSyncTier.isCurrent(
            AccountEntitlement(feature: "hosted_sync", expiresAt: "2020-01-01T00:00:00Z"),
            now: now))
        #expect(HostedSyncTier.isCurrent(
            AccountEntitlement(feature: "hosted_sync", expiresAt: "not-a-date"), now: now))
    }
}

// MARK: - The promoted entitlement read (L7 — B2-3's real home)

@MainActor
@Suite("The promoted entitlement read (Phase 14c, batch 3)", .serialized)
struct HostedSyncStatusReadTests {
    private actor ScriptedLifecycle: AccountLifecycleProviding {
        enum Script {
            case entitlements([AccountEntitlement])
            case failure
        }
        private let script: Script
        init(_ script: Script) { self.script = script }
        func truncateAccountData(activeKeyID: String, keyProof: KeyProofMaterial) async throws -> [String: Int] { [:] }
        func purgeAccount() async throws -> AccountPurgeReport {
            AccountPurgeReport(dataRows: 0, vaultRows: 0, entitlementRows: 0, authUserRemoved: true)
        }
        func fetchEntitlements() async throws -> [AccountEntitlement] {
            switch script {
            case .entitlements(let rows): return rows
            case .failure: throw AccountLifecycleError.httpFailure(status: 503, body: "down")
            }
        }
    }

    private actor QuietTransport: SyncTransport {
        /// 13y UNIT B: the challenge roads — this fake never verifies proofs,
        /// so the mint is a bare nonce and enrollment is a silent yes
        /// (uncounted round plumbing, like `schemaVersion`).
        func fetchChallenges(_ count: Int) async throws -> [String] {
            (0..<max(count, 1)).map { _ in Data((0..<32).map { _ in UInt8.random(in: 0...255) }).base64EncodedString() }
        }
        func enrollKeyProof(legacyProof: String, macKey: String, activeKeyID: String) async throws {}
        func push(_ batch: [SyncRow], activeKeyID: String, keyProof: SyncKeyProof) async throws -> [SyncPushOutcome] {
            batch.map { _ in .rejected(current: nil) }
        }
        func pull(since: Int64, limit: Int, activeKeyID: String, keyProof: SyncKeyProof, deviceID: String?) async throws -> [SyncPulledRow] { [] }
        func schemaVersion() async throws -> Int { SyncSchema.lockstepVersion }
    }

    private func withServices(
        _ script: ScriptedLifecycle.Script,
        _ body: @MainActor (AppServices) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let auth = AuthSession(
            configuration: AuthConfiguration(
                projectURL: URL(string: "https://variorum-project.test.invalid")!,
                apiKey: "publishable"),
            store: .inMemory(),
            http: { _ in throw AuthSessionError.malformedResponse("no network") })
        await auth.adopt(AuthTokens(
            accessToken: "access", refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(3600),
            userID: "user-tier", email: "tier@example.com"))
        let lifecycle = ScriptedLifecycle(script)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let services = AppServices(
                session: AppSession(database: db), storeVariant: .real,
                backupEnabled: false,
                auth: auth,
                makeSyncTransport: { _ in QuietTransport() },
                makeSyncKeyProvider: { AppTestKeyProvider() },
                makeAccountLifecycle: { _ in lifecycle },
                // pre-13x 1a (the retirement's round-3 finding 2): the seam
                // is REQUIRED now — this world declares its inertness
                // instead of inheriting a real login-keychain delete.
                legacyCleanup: {})
            try await body(services)
        }
    }

    /// An active `hosted_sync` row projects `.active` — and the deletion
    /// door's subscription note DERIVES from the same read (one read, one
    /// truth: B2-3 promoted).
    @Test func anActiveEntitlementProjectsActiveAndDerivesTheNote() async throws {
        try await withServices(.entitlements([
            AccountEntitlement(feature: "hosted_sync", expiresAt: nil, source: "manual"),
        ])) { services in
            await services.refreshHostedSyncStatus()
            #expect(services.account.hostedSync == .active(expiresAt: nil))
            await services.refreshSubscriptionNote()
            #expect(services.account.subscriptionNote != nil,
                    "the note strengthens the static advisory when the read says active")
        }
    }

    /// An expired row — or none — projects `.inactive`; no note. A row
    /// for a DIFFERENT feature never activates the tier.
    @Test func expiredForeignOrMissingRowsProjectInactive() async throws {
        try await withServices(.entitlements([
            AccountEntitlement(feature: "hosted_sync", expiresAt: "2020-01-01T00:00:00Z"),
            AccountEntitlement(feature: "some_future_feature"),
        ])) { services in
            await services.refreshHostedSyncStatus()
            #expect(services.account.hostedSync == .inactive)
            await services.refreshSubscriptionNote()
            #expect(services.account.subscriptionNote == nil)
        }
    }

    /// A FAILED read stays quiet: `.unknown` untouched, no note, no error
    /// face anywhere — reads-as-normal (when the server actually refuses
    /// a round, the sync row's tier line narrates; a status read is never
    /// its own alarm).
    @Test func aFailedReadStaysQuietAndUnknown() async throws {
        try await withServices(.failure) { services in
            let errorBefore = services.account.lastError
            await services.refreshHostedSyncStatus()
            #expect(services.account.hostedSync == .unknown)
            #expect(services.account.lastError == errorBefore,
                    "a failed status read never mints an error face")
            await services.refreshSubscriptionNote()
            #expect(services.account.subscriptionNote == nil)
        }
    }
}

// MARK: - The sign-up door's voice (L8)

@MainActor
@Suite("Sign-up refusals classify and speak (Phase 14c, batch 3)")
struct SignUpPresentationTests {
    /// THE COMMON PRE-GATE REFUSAL: the signups-off toggle (the corpus
    /// guard, flipped only as the gate's deliberate act). It must speak
    /// as a CLOSED DOOR — the server refuses all new accounts — never as
    /// a generic failure blaming this user's input. Both GoTrue
    /// vocabularies classify (the modern error_code and the message
    /// text).
    @Test func theSignupsOffToggleSpeaksAsAClosedDoor() {
        let modern = AuthSessionError.endpointFailure(
            status: 422,
            body: #"{"code":422,"error_code":"signup_disabled","msg":"Signups not allowed for this instance"}"#)
        #expect(ErrorPresentation.signUpFailureMessage(modern)
                == ErrorPresentation.signUpClosedMessage)
        let older = AuthSessionError.endpointFailure(
            status: 422, body: #"{"msg":"Signups not allowed for this instance"}"#)
        #expect(ErrorPresentation.signUpFailureMessage(older)
                == ErrorPresentation.signUpClosedMessage)
        #expect(ErrorPresentation.signUpClosedMessage.contains("isn't open yet"),
                "a closed door in words — the server's state, not the user's failure")
    }

    @Test func theOtherRefusalArmsSpeakTheirOwnWords() {
        let exists = AuthSessionError.endpointFailure(
            status: 422,
            body: #"{"code":422,"error_code":"user_already_exists","msg":"User already registered"}"#)
        #expect(ErrorPresentation.signUpFailureMessage(exists)
                == ErrorPresentation.signUpExistsMessage)
        // pre-13x 3b (decision 25; copy §4): the server's two refusals in
        // copy's words — the length floor and the leaked-password refusal.
        let weak = AuthSessionError.endpointFailure(
            status: 422,
            body: #"{"code":422,"error_code":"weak_password","msg":"Password should be at least 12 characters.","weak_password":{"reasons":["length"]}}"#)
        #expect(ErrorPresentation.signUpFailureMessage(weak) == ProtectionCopy.signupPasswordTooShort)
        let pwned = AuthSessionError.endpointFailure(
            status: 422,
            body: #"{"code":422,"error_code":"weak_password","msg":"Password is known to be weak and easy to guess, please choose a different one.","weak_password":{"reasons":["pwned"]}}"#)
        #expect(ErrorPresentation.signUpFailureMessage(pwned) == ProtectionCopy.signupPasswordBreached)
        #expect(AccountView.passwordFloor == 12 && ProtectionCopy.signupPasswordFloorHint == "At least 12 characters.")
        let rate = AuthSessionError.endpointFailure(
            status: 429,
            body: #"{"code":429,"error_code":"over_email_send_rate_limit","msg":"For security purposes, you can only request this once every 60 seconds"}"#)
        #expect(ErrorPresentation.signUpFailureMessage(rate).contains("Too many attempts"))
        let network = URLError(.notConnectedToInternet)
        #expect(ErrorPresentation.signUpFailureMessage(network).contains("check your connection"))
        let unknown = AuthSessionError.endpointFailure(status: 500, body: "boom")
        #expect(ErrorPresentation.signUpFailureMessage(unknown).contains("HTTP 500"),
                "the fallback still names the shape instead of dumping an enum")
        // The pre-SMTP era's REAL stranger refusal (source-verified): the
        // built-in mailer refuses non-team recipients even with signups
        // ON — the arm blames the server's email setup, never the input.
        let unauthorized = AuthSessionError.endpointFailure(
            status: 403,
            body: #"{"code":403,"error_code":"email_address_not_authorized","msg":"Email address not authorized"}"#)
        #expect(ErrorPresentation.signUpFailureMessage(unauthorized)
                    .contains("email delivery isn't fully set up"))
    }

    /// The surface's own statics: the confirmation notice says what
    /// happened and what to do — and stays TRUE under GoTrue's
    /// enumeration prevention (an already-registered email gets the same
    /// session-less 200 and NO email; the notice covers that road
    /// without revealing which one fired). The footnote speaks the v1
    /// principle at the door.
    @Test func theSignUpSurfaceCopyIsPinned() {
        #expect(AccountState.confirmationNotice.contains("confirmation link"),
                "the notice names the email road")
        #expect(AccountState.confirmationNotice.contains("sign in"),
                "…and the step after it")
        #expect(AccountState.confirmationNotice.contains("no email arrives"),
                "the enumeration-prevention road is covered honestly — an existing address gets the identical response and no email")
        #expect(AccountView.signUpFootnote.contains("works fully without an account"),
                "the door itself says the app is whole without it")
    }
}
