# Phase 9c — Auth alignment (execution plan)

> Authored 2026-07-09 at Phase 9b's closeout per the front-loaded-planning rule, FROM
> `notes/plans/phase-09c-auth-brief.md` — the brief's author-ratified decisions are
> **binding** (scope = Phase 14's auth core only; identity goal = ONE account, her
> Fragments account IS her Variorum account; sequencing after 9b; what stays at 14).
> The brief's open interpretations are answered below, against a **verified-capabilities
> lookup run at plan time** (2026-07-09, Sonnet web lookup; findings recorded in §"The
> trust mechanism" — the brief mandated exactly this instead of designing from memory).
> **Staffing (CLAUDE.md model policy):** implementer **Fable** · cold reviewer **Fable**
> (the phase's core is sync-engine surgery — the standing rider makes any other
> assignment incoherent); runs as its own fresh `/run-phase` invocation.

## Kickoff message (for a fresh session)

> You are starting **Phase 9c of Variorum** — auth alignment: Variorum's deliberately
> auth-less mirror gains real user auth so the API key demotes to genuinely
> publishable, the Phase 8 Keychain paste-in retires into a real sign-in, and the
> author's **Fragments account becomes her Variorum account** (QUESTIONS #9 — one
> account, ratified). **First, verify Phase 9b is closed** (master plan pointer says
> 9c; the 9b closeout + review-round section exist in
> `notes/plans/phase-09b-fragments-bridge.md`) — if not, stop and report. Read, in
> order: `CLAUDE.md`, `notes/plans/phase-09c-auth-brief.md` IN FULL (ratified
> decisions binding), this plan IN FULL (especially "The trust mechanism" — its
> capability facts were verified 2026-07-09 and **must be re-verified against the
> author's actual project dashboards at Step 0**, capabilities move), QUESTIONS #9 and
> #13 (9b's contract asks — the bridge session this phase absorbs is gated on them),
> `notes/SyncSpec.md` §2–§5 + §12 (the transport/endpoints this phase reworks; the
> lockstep choreography that governs the mirror change), the Phase 9b closeout (the
> `FragmentsSessionProviding` seam you will implement for real),
> `Server/supabase/02_sync_rpc.sql` (the SECURITY-DEFINER surface being locked down),
> and `notes/sync-postmortem-fragments.md` (read before touching
> `Sources/VariorumCore/Sync/`). **Baselines — do not re-run at session start:** core
> `swift test` = 514 green in 59 suites; Mac app = 235 green in 43 suites; mobile = 11
> green in 4 suites (the 9b closeout's FINAL counts, post-ladder AND post the
> checkpoint contract-reconciliation — the Fragments agents' answers landed 2026-07-09
> evening and were reconciled the same night; **your cold review should give that
> reconciliation diff a real pass** — it re-pinned the fake server/transport to their
> migration-7 SQL and added the fail-closed canonical-user gate; the ladder had closed
> before it, so it has had no cold review). **This phase transitions the author's
> LIVE sync** — take the manual pre-cutover backup (A1 exists; make one anyway),
> follow SyncSpec §12 to the letter (mirror first, then every client; a half-migrated
> state refuses, never guesses), and remember the two 9d environment traps (piped
> xcodebuild masks exit codes; a live app instance or stale unsigned DerivedData
> product blocks the Mac test runner). Author-assist gates are REAL in this phase
> (dashboard configuration, SQL pastes, sign-in on her devices, the 9b bridge's
> deferred real-Fragments pass at the end) — pause and ask at each, never work around.

> **2026-07-10 re-reconcile addendum (recorded by the 9c coordinator at kickoff):** the
> Fragments side's FINAL reply arrived (the author pasted it with the 9c invocation) and
> is reconciled into `notes/fragments-bridge-contract.md` (asks 11 + 13): **zero
> corrections** to the pinned shipped-SQL facts; **one addition** — `conflicts[]` has a
> FOURTH producer, `"row carries no writable columns"` (unreachable for a bridge sending
> all six columns, but the fake-server/transport error-string pins should cover all
> four — a SMALL code item for this phase, fold into any Step 2/5 test work); and **one
> semantic re-pin** on the 15.7 receipt — emission is **genuine-OVERWRITE-only** (every
> ordinary edit push draws a receipt for the pusher's own previous body; loss
> classification is the CONSUMER's job), so Step 6(iv)'s conditional consumption item
> now carries three discrimination rules — unconditional consumption would self-conflict
> on every ordinary push (exactly the trap their own review caught in their drafted
> consumer). Also answered: emission is unconditional server-side (no opt-in flag,
> header, or parameter); leave-inline confirmed for their conflicted-copy marker. The
> ONE remaining pending Fragments event is their 15.7 deploy ping.

**Goal:** both devices sync under real user auth end-to-end; the bare publishable key
alone is refused by the mirror; an absent/expired session refuses cleanly (outbox
intact, cursor unmoved, visible status); the author signs into Variorum with her
Fragments identity; every live row carries her `owner_id` after backfill; the paste-in
is fully gone; the 9b bridge session seam is absorbed into the real sign-in; and the
9b **deferred real-Fragments pass** runs at the end of this phase (its author-assist
gate, plus the Phase 8 device rounds the author deferred until "9b AND 9c are done").

---

## The trust mechanism (brief open interpretation 1 — answered with verified facts)

**Lookup findings (2026-07-09, recorded so the phase doesn't re-research):**

1. **The brief's option (i) as imagined is NOT currently possible.** Supabase
   "Third-Party Auth" (direct Data-API trust of externally-issued JWTs) supports a
   CLOSED provider list — Clerk, Auth0, Firebase, AWS Cognito, WorkOS. There is no
   custom-OIDC entry and no documented way to register another SUPABASE project as
   the trusted issuer. Symmetric JWTs are explicitly unsupported there.
2. **The new viable door: Custom OAuth/OIDC Providers** (GA April 2026; Free plan =
   3 providers, Pro+ unlimited). Supabase Auth can delegate SIGN-IN to any
   standards-compliant OIDC issuer (issuer URL → auto-discovery). Separately, a
   Supabase project can now itself ACT as an OIDC issuer (the "OAuth 2.1 Server"
   feature; per-project discovery + JWKS endpoints). Chaining the two — **Variorum's
   project registers Fragments' project as a custom OIDC sign-in provider** — is
   structurally supported but NOT explicitly documented as a pairing anywhere the
   lookup found. Under this route Variorum Auth mints its OWN (Variorum-project)
   JWTs after the delegated handshake, so RLS/`auth.uid()` work natively, with no
   role-claim gymnastics.
3. **The legacy shared-HS256-secret route (brief option ii) still works mechanically**
   for un-migrated projects (Settings → API → JWT Secret) but is explicitly
   discouraged, cannot be rotated anymore, and **dead-ends permanently once either
   project migrates to JWT Signing Keys** (new projects default asymmetric since
   2025-10; extraction of key material becomes impossible post-migration). Importing
   the SAME asymmetric key into both projects is mechanically plausible
   ("import an existing key") but undocumented as a cross-project pattern.
4. Direct third-party-token RLS (were it ever used) needs `role: authenticated`
   claims and `auth.jwt()->>'sub'` instead of `auth.uid()` — noted only so nobody
   burns time on that path; the chosen route avoids it entirely.

**The resolution (implement A; B is the fallback; C stays rejected-leaning):**

- **(A) PRIMARY — Fragments-as-custom-OIDC-provider.** She signs into Variorum with
  her Fragments account via the delegated OIDC flow; Variorum Auth mints
  Variorum-project sessions; the mirror's RLS keys on Variorum's `auth.uid()`.
  This is the cleanest realization of the one-account goal on TODAY's verified
  capabilities — one identity, standards-based, no shared key material, no coupled
  compromise blast radius. **Step 0 spikes the undocumented pairing before anything
  builds on it.** Fragments-side prerequisite (author-carried, dashboard-only,
  zero Fragments-repo work): enable/verify the OAuth 2.1 Server feature on the
  Fragments project and register Variorum as a client app.
- **(B) FALLBACK — shared signing-key material** (the brief's option ii, modernized:
  import the same asymmetric signing key into both projects if both are on JWT
  Signing Keys; the legacy shared HS256 secret only if both projects are
  un-migrated). Costs exactly what the brief recorded: coupled rotation and blast
  radius. Taken ONLY if the Step 0 spike fails and the author confirms.
- **(C) One merged project — rejected-leaning, unchanged** (revisit only if A and B
  both fail; it strains the hands-off-Fragments boundary).

### Step 0 field notes — the author's dashboard round 1 (2026-07-10, coordinator-recorded; the implementer folds these into the Step 0 memo)

- **Tiers:** both projects Free (the author is willing to upgrade to Pro at any time if
  needed — Free's 3 custom providers suffice for route A, so no upgrade is required for
  this phase's core).
- **JWT keys:** BOTH projects are **migrated to JWT Signing Keys** — current key type
  **ECC (P-256)**; the legacy JWT secret is verify-only and rotation-locked ("can only be
  changed by rotating to a standby key and then revoking it"). Consequence, per lookup
  fact 3: **fallback B's legacy shared-HS256 form is DEAD**; only the modernized form
  (importing the same asymmetric key into both projects) remains as B.
*[removed for publication]*
  author ENABLED it.** Published endpoints (dashboard + confirmed by the coordinator's
  *[removed for publication]*
  authorize `…/auth/v1/oauth/authorize`, token `…/auth/v1/oauth/token`, JWKS
  `…/auth/v1/.well-known/jwks.json`, discovery `…/auth/v1/.well-known/openid-configuration`.
  Discovery says: `response_types=[code]`, PKCE S256, grant types authorization_code +
  refresh_token, token-endpoint auth `client_secret_basic/post/none` (public clients
  possible), id-token algs RS256/HS256/ES256, userinfo endpoint present, claims include
  `sub`/`email`. **NO `registration_endpoint` is advertised** (consistent with "Allow
  Dynamic OAuth Apps" being OFF).
- **The client-registration GAP (blocks author steps 5–6):** the Fragments OAuth Server
  page shows Site URL / Authorization Path / the "Allow Dynamic OAuth Apps" toggle and
  the endpoints — but **no manual "register a client app" UI the author could find**.
  Likely doors: (i) Dynamic OAuth App registration (RFC 7591 — toggle ON, then a
  registration endpoint should appear; register Variorum with one curl, optionally
  toggle back OFF), (ii) the Supabase Management API (her PAT exists, untracked), or
  (iii) a dashboard "OAuth Apps" list somewhere she didn't find. **UNRESOLVED —
  the implementer's Sonnet lookup targets exactly this before the author acts.**
- **The consent-UI WRINKLE (now route A's central open question, ahead of
  registration):** Supabase's OAuth server delegates the authorize-time login/consent UI
  to the project's OWN web application — "Authorization Path: path where you'll
  implement the OAuth authorization UI (consent screens). Make sure this path is
  implemented in your application"; the Fragments project's Site URL is the default
  `http://localhost:3000` placeholder (preview authorization URL
  `http://localhost:3000/oauth/consent`). **Fragments is iOS-only — no web app exists to
  serve login or consent.** The spike must determine what serves that UI (a hosted
  Supabase page? a throwaway LOCAL page at localhost:3000 for the spike, since Site URL
  already points there? what would production need permanently?) — this is the
  make-or-break question for the pairing, and a real route-A cost to weigh against
  fallback B if it demands a permanently-hosted page.
*[removed for publication]*
  "Create Custom Auth Provider": provider identifier slug (`custom:<name>`), display
  name, auto-discovery (recommended) from an Issuer URL or manual endpoints, client
  ID + client secret fields, scopes (default suggestion `openid, email, profile`),
  "allow users without email" toggle, and the fixed callback URL
  *[removed for publication]*
  yet** — blocked on client registration above. When created, the Issuer URL is exactly
  *[removed for publication]*
  Discovery URL empty).
- **Author actions remaining (blocked on the implementer's registration + consent
  findings):** register the Variorum client on the Fragments OAuth server, create the
  custom provider on Variorum, run one delegated sign-in via the scratch harness.

**Round 2 (same day, the author — two material updates):** (1) **The consent-UI wrinkle
has a production answer:** the author owns hosted websites — **stargazing.tech** is
"where my apps will have their websites" (separate repo `~/dev/stargazing-tech` with its
own Claude agent; the AUTHOR is the channel — she tasks that agent for whatever page
route A needs; planetlillian.com also exists). A permanent home for the login/consent
page therefore exists at zero Variorum-repo web cost — this removes the
"permanently-hosted page" penalty from the route-A vs fallback-B calculus; the spike can
still use a throwaway local page at the placeholder `localhost:3000` Site URL first.
(2) **The author authorized the Dynamic OAuth Apps registration path:** she can toggle
it on/off at will and asked the coordinator to perform the client registration
programmatically once it's on. Coordinator re-check after round 1: discovery still
advertises NO `registration_endpoint` (toggle off at check time; whether discovery
advertises it when ON is established empirically at flip time — if not advertised, the
implementer's lookup supplies the path). Client credentials, when issued, go in an
untracked gitignored `.env.fragments-oauth.local` — never chat, never tracked files;
the author copies them into the Variorum provider form from there.

**Round 3 (same day — the spike RAN; ROUTE A CONFIRMED by the author):** registration
succeeded through the dynamic door once the toggle actually saved (client_id
*[removed for publication]*
the untracked `.env.fragments-oauth.local`); the custom provider was created (slug
`fragments`, auto-discovery, the pinned issuer). TWO dashboard didn't-save incidents
(first the toggle, then the Authorization Path — the OAuth Server page's save step is
easy to miss); the stale path surfaced as a localhost 404, diagnosed by the
coordinator's hop trace (hop 1 Variorum→Fragments authorize PROVEN — client recognized,
PKCE + state + callback correct; hop 2 still redirecting to the old `/oauth/consent`).
After the re-save, the full delegated sign-in succeeded END TO END: consent page
(email+password against the Fragments project) → approve → callback with the REDACTED
summary. **The evidence (the Step 0 memo's substance):** a Variorum-minted session —
*[removed for publication]*
on), `iss` = Variorum `/auth/v1`, `role`/`aud` authenticated, `amr` oauth, provider
`custom:fragments` — and **`provider_token` + `provider_refresh_token` BOTH PRESENT**,
the provider token being a genuine Fragments-project user JWT (`sub
*[removed for publication]*
Fragments `/auth/v1`, `role` authenticated, exp 3600 s). The inner V↔F token exchange —
the chain's flagged biggest unknown — ran live with her real account. Observed flow
`implicit-fragment` (the harness's redirect_to shape; the real Step 1 sign-in uses the
PKCE code flow). **ROUTE A CONFIRMED (author, 2026-07-10, at the coordinator's
checkpoint question); fallback B stands down to documented-unused.** Spike tail
remaining: the toggle-OFF verification (registered clients must survive "Allow Dynamic
OAuth Apps" going off — coordinator hop-traces on her flip), then cleanup (remove the
localhost redirect URL from Variorum's URL configuration; the Authorization Path stays
`/consent.html` until the production page on stargazing.tech replaces it). Still
unverified, owned by Steps 5/6: Fragments' PostgREST accepting the provider token for
RLS (claims look right — verified only at the real-Fragments pass), and the
provider-token refresh strategy (Supabase does not persist/refresh provider tokens —
Step 5 designs the renewal or a direct-sign-in alternative).

**Round 4 (same day — toggle-off VERIFIED; risk calibration):** the author flipped
"Allow Dynamic OAuth Apps" OFF (saved, confirmed); coordinator probes: (1) the
registration endpoint refuses again (403 `oauth_dynamic_client_registration_disabled` —
the open-registration window is closed; the probe was refused outright, no side
effect); (2) the full authorize chain STILL WORKS — Fragments recognized the registered
client and minted a fresh `authorization_id`, redirecting to `/consent.html`. The
implementer's flagged inference ("toggle gates only the register handler") is now
EMPIRICALLY CONFIRMED. Spike-cleanup remainder (the localhost redirect URL in
Variorum's URL configuration) deliberately deferred to the phase-end cleanup — the
harness may serve one more verification during Steps 1/5. **Risk calibration (author,
same message):** she notes neither app holds important content yet — daily use is
deliberately deferred until after 9c, so the store is effectively pre-live and the
kickoff's "transitions the author's LIVE sync" caution overstates today's stakes. The
seconds-cheap manual pre-cutover backup stays in the choreography anyway (it costs
nothing and rehearses the path), but the cutover's risk posture is recorded as LOW.

**Round 3-precursor (2026-07-10, the implementer's Sonnet lookup — ran BEFORE the
spike above, which consumed these findings; each fact tagged DOCUMENTED /
CODE-DERIVED / INFERRED):**

- **(a) Client registration — three doors, best first.**
  1. *Dashboard (DOCUMENTED, un-reconciled with round 1):* the getting-started docs
     describe **"Authentication → OAuth Apps" → "Add a new client"** (name, redirect
     URIs, client type Public/Confidential) — a page DISTINCT from the "OAuth Server"
     page the author inventoried. Check for that literal sidebar tab first; the
     round-1 absence may be a rollout gap (unresolved).
  2. *Project-admin GoTrue endpoint (DOCUMENTED + CODE-DERIVED — the recommended
     programmatic door):* `POST https://<fragments-ref>.supabase.co/auth/v1/admin/oauth/clients`
     with `Authorization: Bearer <the FRAGMENTS project's SECRET key>` (a project key,
     NOT the Management-API PAT — round 2's "Management API" premise is corrected: no
     `api.supabase.com` route exists for OAuth-server clients; that domain's OAuth is
     the unrelated manage-organizations integration). Body `{name, redirect_uris,
     client_type: "public"|"confidential", token_endpoint_auth_method}`; returns
     `client_id` + `client_secret` **shown once**; GET on the same path lists.
     Avoids the dynamic toggle entirely — no open-registration window.
  3. *Dynamic RFC 7591 (CODE-DERIVED path):* `POST /auth/v1/oauth/clients/register` —
     path confirmed from the auth router + a live repro (supabase/auth #2285); gated
     ONLY on the toggle; **open/unauthenticated while ON** (rate-limited). Discovery
     advertising `registration_endpoint` when ON: INFERRED. Toggle-back-OFF keeping
     registered clients alive: INFERRED (the flag is checked only in the register
     handler) — verify empirically before relying. Redirect URIs: HTTPS required
     (localhost HTTP allowed; custom schemes rejected, open bug) — Variorum's HTTPS
     callback qualifies. Registering V as a **confidential** client with
     `client_secret_post` is the standard-practice call; the inner V↔F token-exchange
     mechanics are NOWHERE documented (the chain's biggest unverified assumption —
     the spike settles it live).
- **(b) Consent UI (DOCUMENTED, decisive):** **no Supabase-hosted login/consent page
  exists** — hosted projects 302 to `{site_url}{authorization_path}?authorization_id=…`
  and nothing serves it unless the project's own app does (open supabase/auth issue
  #2408 confirms the hosted-project gap). The page's whole job (CODE-DERIVED routes +
  the docs' worked example): sign the user in against the FRAGMENTS project
  (ordinary auth), `GET /auth/v1/oauth/authorizations/{id}` with the user bearer,
  `POST …/consent {action: approve|deny}`, then redirect to the returned
  `redirect_url`. **Consent auto-skips on repeat client+scope** (CODE-DERIVED), so the
  page is hit ~once per user+client+scope; no permanent first-party-skip flag exists.
  Spike: a throwaway LOCAL page at the placeholder Site URL suffices (INFERRED from
  the flow — nothing restricts Site URL); production: the ~20-line page on
  stargazing.tech (round 2's answer).
- **(c) provider_token (Step 5's question) — PARTIALLY VERIFIED:** Supabase returns
  `provider_token`/`provider_refresh_token` **only in the initial sign-in response**,
  never persists and **never refreshes** them (DOCUMENTED for social providers;
  applicability to `custom:<slug>` providers INFERRED — same code path, not stated in
  the custom-provider docs). Pre-recorded Step 5 consequence: even when present, a
  long-lived bridge session cannot ride provider_token alone — the app must hold the
  provider REFRESH token and renew against Fragments' `/auth/v1/oauth/token` as a
  registered client (a PUBLIC client, `token_endpoint_auth_method: none`, needs no
  secret on-device), or the bridge gets its own direct Fragments-project sign-in.
  Whether an F-OAuth-server-issued access token is accepted by Fragments'
  PostgREST/RLS as an ordinary user JWT is UNVERIFIED — the spike's decoded
  provider-token claims (iss/sub/role) inform it.
- **Userinfo scope needs:** not Supabase-documented; OIDC convention (`openid` → `sub`,
  `email` scope → the email claim) assumed — the planned scopes `openid, email,
  profile` cover it.
- **The spike harness SHIPPED** (implementer): `Spikes/AuthPairingSpike/` — README +
  `consent.html` (the throwaway F-side consent page: hand-rolled fetch, password
  sign-in, get-authorization, approve/deny, redirect) + `callback.html` (the session
  inspector: decodes the Variorum session's `sub`/`iss`/`email`/`amr`, reports
  provider-token presence + the provider token's decoded claims; REDACTED summary
  only — raw tokens never leave the browser). Zero dependencies, author-executed.
  The provider slug the sign-in code will default to is **`fragments`**
  (`custom:fragments`) — injectable configuration in Step 1's entry seam regardless.

**`owner_id` keying (brief open interpretation 2):** under (A), `owner_id` = the
**Variorum project's `auth.uid()`** (its native `sub`). Rationale, recorded: it is
project-local and stable regardless of how the identity was proven (delegated
Fragments sign-in today, Variorum-native accounts at Phase 14 mint the same class of
ids for other users — no re-keying of her rows, satisfying the brief's stability
requirement); keying on the FRAGMENTS uid would fuse Variorum's data identity to
another product's auth namespace forever. Under (B) the two projects share `sub`
values; the same rule (the token's `sub`) still holds. **The bridge is unaffected
either way:** it authenticates to FRAGMENTS' backend as her Fragments user
(9b's contract fact 3) — see Step 5.

## Steps

### Step 0 — The pairing spike + project inventory (author-assist gate; throwaway)
**Work:** with the author at the dashboards: (a) inventory both projects' auth state
(JWT signing-keys migration status, plan tier, OAuth 2.1 Server availability on the
Fragments project); (b) spike route (A): register the Fragments project's issuer URL
as a custom OIDC provider on the VARIORUM project, register a client on the
Fragments side, run one delegated sign-in with her real Fragments credentials from a
scratch page/CLI; (c) confirm what the resulting Variorum session contains (its
`sub`; whether the provider's tokens — a Fragments-project access token — ride along
as `provider_token`/`provider_refresh_token`, which Step 5 wants). **Decision memo
in this plan's closeout: route A confirmed or fallback B invoked (author call).**
The 2026-07-09 lookup facts above must be re-verified live here — capabilities move.
**Tests:** none (throwaway spike; the memo is the artifact).

### Step 1 — Sign-in core: session store + auth client (both targets' shared layer)
**Files:** `App/Variorum/Shared/AuthSession.swift` (new — Supabase Auth session over
the VARIORUM project: sign-in via the route-A provider flow, session persistence in
the Keychain under NEW keys, refresh, sign-out), `SyncCredentialsStore.swift`
(retirement begins: marked deprecated, read-only for migration this step).
No third-party SDK — the auth endpoints are plain REST (`/auth/v1/…`), consistent
with the hand-rolled transport doctrine; if implementation pressure suggests the
official SDK instead, STOP — a new dependency is an author-only call.
**Tests:** token/refresh state machine headless against a fake auth endpoint
(URLProtocol or protocol seam — same no-network discipline as the transports);
session persistence round-trip; sign-out clears everything.

### Step 2 — Transport token refresh (SYNC-ENGINE SURGERY — the standing rider)
**Files:** `Sources/VariorumCore/Sync/SupabaseTransport.swift` (+ a session-providing
seam mirroring 9b's `FragmentsSessionProviding` — one shape, two backends),
`SyncSession.swift` wiring.
**Work:** the transport asks a session provider per call (replacing the static
`authToken`); 401 mid-round → one refresh-and-retry, then surface as a failed round
(outbox intact, cursor unmoved — the scheduler's offline posture, reused not
duplicated); signed-out → the round refuses before any request composes (9b's
transport pinned this shape — mirror it).
**Tests:** 401-mid-round refresh-retry-once; refresh failure = clean refusal with
byte-intact outbox/cursor; signed-out never composes a request; a full
convergence scenario runs green over the new seam (the harness stays auth-agnostic
per the brief's interpretation 5 — the fake server models CAS + seq, never auth).

### Step 3 — The mirror's RLS + RPC rework (SQL artifact + author paste; SyncSpec §12 lockstep)
**Files:** `Server/supabase/04_auth_rls.sql` (new, in-repo like 01–03): `owner_id`
checks in `sync_push`/`sync_pull`/`sync_delete` (SECURITY DEFINER retained but
per-user-guarded: every row read/written must carry `owner_id = auth.uid()`; pushes
of rows without it are rejected), RLS enabled on all 13 mirror tables, anon/bare-key
access revoked.
**Choreography (§12, exactly):** (1) Step 4's backfill runs FIRST everywhere (see
ordering note there — RLS over NULL `owner_id` rows would lock her out of her own
corpus); (2) the author pastes 04 in the SQL editor; (3) only then do clients sync
under auth. A client that fails auth refuses to sync — outbox intact, visible status.
**Tests:** the in-repo DDL walk extends to 04 (allowlist unchanged, no new synced
columns except as Step 4 declares); the fake server stays auth-agnostic; the REAL
enforcement is verified at Step 6's integration pass (the brief: the fake never
proves auth).

### Step 4 — `owner_id` population through Operations + backfill (schema-value change, own commit)
**Files:** `Sources/VariorumCore/Operations/*` (top-level minting ops stamp
`owner_id` from an injected `@Dependency(\.ownerID)`-style seam — through Operations
only, review focus 1), a small backfill operation (`adoptOwnerID`) that stamps every
live+tombstoned row's NULL `owner_id`, enqueuing per-row so the mirror converges.
**Ordering (brief interpretation 3, answered):** backfill lands and PUSHES from the
Mac first, then the phone pulls/converges, THEN Step 3's RLS paste — so no client is
ever locked out mid-transition; a half-done state just means the mirror still accepts
key-auth (the pre-existing posture) until the flip. Dump-compare before/after
(the brief's verification).
**Tests:** every minting op stamps; backfill totality (no NULL `owner_id` live rows
after — including tombstones, which still sync); backfill rows reach the outbox;
convergence suite green with owner-stamped rows.

### Step 5 — The bridge session absorbed + sign-in UI; the paste-in retires
**Files:** `App/Variorum/Shared/AuthViews.swift` (functional, unstyled sign-in
replacing `SyncSetupView`), `BridgeSession.configure` wiring (the 9b seam:
`FragmentsSessionProviding` gets its real implementation — route A's
`provider_token` if Step 0 confirmed it rides along, else a direct
Fragments-project sign-in owned by the same UI; either way the bridge's
configuration facts are settled (asks 8/10 ANSWERED at 9b's reconciliation: the
namespace is the pinned constant; the canonical user is resolved from
`user_settings.local_user_id` at round time with the fail-closed gate)), deletion of `SyncCredentialsStore`
+ `SyncSetupView` (review focus 4: no dead credential path in either target; the
old Keychain item is cleared on first sign-in).
**Tests:** sign-in state drives both sessions (sync + bridge); signed-out shows the
refusal status; no code path reads the retired Keychain keys (grep-pinned like the
A6 walks); mobile target compiles with the same shared layer.

### Step 6 — Verification (the author-assist gates, batched)
**Work:** (i) full suites, three targets. (ii) The env-gated integration pass
against the REAL mirror under auth: bare publishable key alone refused; her session
syncs; expired → refresh → round completes (the brief's verification sketch, real
server — the fake proves none of this). (iii) Both devices sign in and sync
end-to-end (the Phase 8 device rounds the author deferred to post-9c fold in HERE).
(iv) **The 9b bridge's deferred real-Fragments pass** — the contract asks are
ANSWERED and reconciled (9b's checkpoint reconciliation round; headless-complete);
the pass is gated on THIS PHASE'S SIGN-IN ONLY — one manual two-way day with her
real journal, dump-compared, verifying credentials/RLS/live behavior (the shapes
are already pinned to their migration-7 SQL). **CONDITIONAL sub-item (ask 13 —
Fragments' 15.7 replaced-body receipt, shape DRAFTED not final):** if `replaced`
is live AND final on hosted by the time of this pass, pin the fake server to the
final shape and add the consumption path — **with the 2026-07-10 discrimination
rules (contract ask 13), NEVER unconditionally:** a receipt whose `previous_body`
equals the day's last pulled-or-pushed body is a no-op (the bridge knowingly
replaced text it already holds); one contained in the just-pushed body is a no-op
(a superset/merge push — the Fragments conflicted-copy re-push case); ONLY
otherwise — text the bridge never saw — does `previous_body` land as a
`'fragments'` conflict variant through the ordinary landing door. If `replaced`
is not live-and-final, this
becomes a named follow-up triggered by their deploy ping — never assumed (the
bridge's permanent posture: ignore unknown response keys, consume only if
present). (v) The
week-one dump-compare ritual begins (2026-07-07 note) once she daily-drives.
**Closeout:** results per gate; the master plan's 9c row + pointer → 10; the Phase
10 plan authored from `notes/plans/phase-10-brief.md` per the front-loaded rule;
the author handoff.

## Explicitly out of scope (the brief's §3, restated)
Multi-tenant/commercial hardening, non-author provisioning, E2EE (plaintext stays
ratified), the variorum-edition export — all Phase 14. No new third-party
dependencies (the auth REST surface is hand-rolled like the transports).

## Risks
- **Live-sync transition** — manual backup before the cutover; §12 to the letter;
  a half-migrated state refuses (stalling is free, guessing is forbidden).
- **RLS lockout** — worst case sync stalls, data stays safe locally; the
  integration pass is the proof, never the fake server.
- **The route-A pairing is undocumented** — that is exactly why Step 0 spikes it
  with the author before anything builds on it, and why fallback B is pre-agreed.
- **Token refresh is new machinery in Fable-only territory** — any change not
  covered by a convergence or integration test is unreviewed (AppSpec §15 risk 3).
- **The bridge configuration may still be blocked** on 9b's contract asks — that
  blocks only Step 5's bridge half and Step 6(iv), never the phase's core; report,
  don't guess.

## Review foci (for the cold reviewer — written at plan time, no implementation context)
1. Zero new row-writing paths; `owner_id` stamping flows through Operations only.
2. The key is truly demoted — nothing treats it as a secret, AND the mirror refuses
   bare-key access (verified against the deployed project, not the narrative).
3. Session/refresh machinery covered by tests incl. 401-mid-round; the scheduler's
   offline posture reused, not duplicated; a refused round leaves outbox/cursor
   byte-intact.
4. The paste-in fully retired — no dead Keychain paths, no orphaned setup door.
5. §12 lockstep followed and recorded step-by-step; backfill provably total.
6. The shipped trust configuration matches Step 0's memo (flag any drift from the
   recorded rationale); the one-account goal demonstrated, not asserted.
7. The 9b bridge seam absorbed without weakening it (per-call sessions, user-auth,
   never the PAT; unconfigured-and-reported when the contract asks are unanswered).

## Closeout
*(Written at phase end: what shipped, test counts, the Step 0 memo + author call,
gate results incl. the folded-in Phase 8 device rounds and the 9b real-Fragments
pass, PROVISIONALs, review dispositions, the Phase 10 plan authored, the handoff.)*

### Step 0 decision memo (2026-07-10 — the gate's artifact; field evidence in the
### Step 0 field notes rounds 1–3 above)

**DECISION: Route A — Fragments-as-custom-OIDC-provider — CONFIRMED (the author's
explicit call at the coordinator's checkpoint question). Fallback B (shared
asymmetric signing-key material) stands down to documented-unused; C stays
rejected.** The plan-time lookup's one structural unknown — whether two Supabase
projects can actually complete the OAuth 2.1 Server ↔ Custom-OIDC-Provider pairing —
was answered by RUNNING it: one delegated sign-in with the author's real Fragments
account succeeded end to end on 2026-07-10.

*[removed for publication]*
  Server enabled; Variorum registered as a client via the dynamic RFC 7591 door
  *[removed for publication]*
  `client_secret_post`; secret in the untracked `.env.fragments-oauth.local`);
  *[removed for publication]*
  (`custom:fragments`), auto-discovery from issuer
  *[removed for publication]*
  profile`. Consent UI: Supabase hosts none (verified); the spike served the
  throwaway `Spikes/AuthPairingSpike/consent.html` at the Fragments Site URL
  (`localhost:3000`, Authorization Path `/consent.html`); the production page lands
  on the author's stargazing.tech (spec: `notes/fragments-consent-page-spec.md`).
- **The evidence (redacted spike summary, verbatim values):** a Variorum-minted
  *[removed for publication]*
  the author's rows; the Step 4 keying decision collects on it), `iss` = Variorum
  `/auth/v1`, role/aud `authenticated`, amr `oauth`, provider `custom:fragments`,
  `expires_in` 3600, refresh token present — **plus `provider_token` AND
  `provider_refresh_token` both riding the initial response**, the provider token a
  *[removed for publication]*
  the `journal_entries.user_id` class, `iss` = Fragments `/auth/v1`, role
  `authenticated`). The one-account goal is DEMONSTRATED, not asserted: she signed
  in once, with her Fragments identity, and Variorum minted her Variorum session.
- **Operational notes for repetition:** the Fragments OAuth Server dashboard page
  has an easy-to-miss save step — it silently discarded the toggle once and the
  Authorization Path once (the stale path surfaced as a localhost 404; the
  coordinator's hop trace isolated it). The spike observed the harness's
  implicit-fragment flow; **the app's real sign-in (Step 1) uses the PKCE code
  flow** — and MUST capture the provider token pair at exchange time, because
  Supabase never persists or re-delivers provider tokens.
- **Still open, with owners:** (i) ~~toggle-OFF survival of the registered client~~ —
  **RESOLVED 2026-07-10 (field notes Round 4): empirically CONFIRMED** — with the
  toggle off, registration 403s (`oauth_dynamic_client_registration_disabled`) while
  *[removed for publication]*
  redirect-URL cleanup deferred to phase-end in case the harness serves Steps 1/5).
  (ii) Fragments' PostgREST accepting the provider token for RLS —
  claims look exactly right; verified only at Step 6(iv)'s real-Fragments pass.
  (iii) The provider-token refresh strategy for the bridge — options + PROVISIONAL
  in the Step 5 design note below. (iv) Consent auto-skip on repeat client+scope —
  code-derived expectation, not yet observed (single run).
- **Risk calibration (coordinator relay, 2026-07-10 — for the Step 6 gate
  narrative):** neither app holds important content yet (daily use deliberately
  deferred until post-9c), so the store is effectively pre-live. The manual
  pre-cutover backup STAYS (seconds-cheap, rehearses the path); the cutover's risk
  posture is LOW — correctness discipline unchanged, no drama owed.

### Step 5 design note — the bridge's Fragments session (options weighed 2026-07-10;
### PROVISIONAL per the addendum rules; QUESTIONS #16 carries it to the checkpoint)

Step 0 proved `provider_token` + `provider_refresh_token` ride the initial Variorum
sign-in — but Supabase never persists or refreshes them, provider tokens expire in
~1 h, and the bridge needs an indefinite Fragments-project session. Four shapes:

- **(a1) Refresh the provider pair as the registered confidential client.** The app
  holds the client_id + client_secret (Keychain, author-pasted from her untracked
  env — never bundled/committed) and renews against Fragments'
  `/auth/v1/oauth/token`. Costs: a client SECRET living on-device inside the app
  whose whole phase exists to stop shipping bearer secrets; rests on the unverified
  semantics of a third party refreshing tokens minted through Variorum's GoTrue
  exchange; and rests on (ii) above.
- **(a2) Refresh the provider pair as a second PUBLIC client** (`token_endpoint_
  auth_method: none` — supported). No secret on-device — but almost certainly
  unworkable: OAuth refresh tokens are bound to the client they were issued to
  (Variorum's confidential client), and a refresh_token grant from a different
  client_id is standardly rejected. Recorded so nobody re-derives it.
- **(b) The app registers as its OWN public client on the Fragments OAuth server**
  and runs a second delegated PKCE flow for a first-class Fragments session (one
  extra consent hop, once). No secrets; standards-clean; but stacks on BOTH
  unverified semantics (OAuth-server-issued tokens against their PostgREST/RLS,
  (ii) above) and adds a second client registration to maintain.
- **(c) A direct Fragments-project sign-in for the bridge** (her Fragments
  email+password, entered once in Variorum's sign-in surface; only the resulting
  GoTrue session persists — the password is never stored). This is EXACTLY the
  session class Fragments' own app uses, so their PostgREST/RLS acceptance is
  guaranteed by construction (no (ii) dependency); ordinary GoTrue refresh; zero
  client secrets; and it is the shape 9b's contract line already promises ("the
  bridge uses a user-auth session for the author's Fragments account, stored
  untracked on her machines"). Cost: one extra credential entry at setup — the same
  password she typed into the spike's consent page; the IDENTITY stays one account
  (the mechanism is a second session, never a second account).

**PROVISIONAL: (c).** Rationale: the only shape with zero unverified semantics and
zero on-device client secrets; the bridge's correctness must not stack on OAuth-
server token-acceptance bets that can only be tested at 6(iv). The captured
provider token pair stays persisted-but-unconsumed as evidence — if the author
prefers strict one-touch (no second password entry, ever), (a1)/(b) are the
upgrade paths and 6(iv) is where either would be proven. The Step 2 seam makes the
mechanism swappable behind `FragmentsSessionProviding` without touching the bridge.
