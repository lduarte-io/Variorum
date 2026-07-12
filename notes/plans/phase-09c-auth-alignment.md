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

**Round 5 (same day — two author process amendments):** (1) **The Step 3 SQL paste is
re-gated from author-paste to coordinator-executes-with-standing-authorization:** the
author explicitly authorized the coordinator to run `04_auth_rls.sql` against the
Variorum project via her PAT (untracked `.env.supabase.local`, Management API) at the
cutover moment — "I think you should be able to do it yourself with the PAT"; she
remains on standby for the same sitting's sign-ins and the backfill trigger. Conditions
the coordinator holds itself to: announce before executing, the committed in-repo file
is the exact artifact run, §12 ordering unchanged (backup → backfill converged on both
devices → THEN the paste), post-paste verification probes (bare-key refusal; her
session syncs). Supersedes the "author pastes in the SQL editor" wording in Step 3 and
the kickoff. (2) **Step 6 gets a self-contained RUNBOOK as a first-class deliverable**
(author ask, same message — this coordinator session is at 400k+ tokens and she wants
the option of running Step 6's walkthroughs/checks with a FRESH agent): the implementer
writes `notes/handoffs/phase-09c-step6-runbook.md` — every gate as an executable
checklist a fresh session (or the author alone) can conduct without ANY prior-session
context: the backup command, the backfill trigger + totality verification, the cutover
execution + exact post-paste probes with expected outputs, Release-install steps for
the phone (and WHY release — the A4 fence), both device sign-ins, the device-round
script (offline capture, two-way edits, the same-entry conflict check), the
real-Fragments pass script + dump-compare commands, the bridge configuration checks,
and per-gate failure→recovery paths (RLS-lockout rollback included). The ordinary
phase handoff still gets written per the closeout ritual; the runbook is its Step 6
arm, held to the same bar: if a gate question needs this session's context, the
runbook is incomplete.

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
checks in `sync_push`/`sync_pull` *(correction, review round 1 NIT: this line
originally also named `sync_delete` — Variorum's dialect has no such RPC; that is
Fragments' migration-7 surface. The shipped artifact correctly reworks exactly the
two that exist)* (SECURITY DEFINER retained but
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

## Closeout (2026-07-10 — implementer: Fable, single session; the review ladder
## CLOSED at round 2 with zero new HIGH findings. **THE PHASE IS NOT CLOSED**:
## Step 6's author-assist gates are PENDING THE SITTING — the runbook
## `notes/handoffs/phase-09c-step6-runbook.md` is the sitting's script, and the
## master plan's pointer stays at 9c until the gates pass.)

### What shipped, by step

- **Step 0 — the pairing spike + inventory (author-assist; CLOSED):** route A
  CONFIRMED by running it end to end with her real account — the decision memo
  below is the gate's artifact; the throwaway harness lives in
  `Spikes/AuthPairingSpike/` (consent page + session inspector, zero
  dependencies); five field-note rounds in the plan body carry the full record
  (registration doors, the consent-UI mechanics, provider-token behavior, the
  toggle-off confirmation, the dashboard save trap).
- **Step 1 — the sign-in core** (`App/Variorum/Shared/AuthSession.swift`,
  `SignInFlow.swift`; 13 Mac tests): plain-REST Supabase Auth over the Variorum
  project (no SDK — the hand-rolled doctrine); PKCE code flow against
  `custom:fragments` (RFC 7636 vector-pinned); Keychain persistence under NEW
  keys; single-flight refresh with THE PRESERVATION RULE (the provider token
  pair — delivered ONLY at the sign-in exchange, never re-delivered — survives
  every refresh, pinned); fail-visible-never-fail-destructive refresh failures
  (only signOut clears — and sign-out is TERMINAL, the round-1 pin);
  `UserSessionProviding` conformance so the same object drives the transport;
  the password door (`signInWithPassword`) for the bridge's Fragments session;
  ASWebAuthenticationSession as the browser face (retained, start-checked,
  real-window-anchored after round 1).
- **Step 2 — the transport session seam + token refresh (sync-engine surgery;
  7 core tests):** the 9b seam GENERALIZED into `Auth/UserSession.swift` (one
  shape, two backends; the Fragments names became typealiases — zero bridge
  churn); `SupabaseTransport` authenticates per call via the provider —
  signed-out refuses before any request composes; a 401 gets exactly ONE
  refresh-and-retry; a refused round leaves outbox/cursor/row-seqs byte-intact
  (engine-level pin); a FULL convergence scenario runs through the transport's
  real wire mapping against the auth-agnostic fake (byte-identical dumps, every
  request carrying the session bearer). Round 1 extended the same 401 door to
  the BRIDGE transport (`FragmentsRPCTransport`), red-on-old-pinned.
- **Step 3 — the mirror's auth/RLS rework as the committed artifact**
  (`Server/supabase/04_auth_rls.sql`; 10 DDL pins): RLS on all 13 mirrors (no
  policies — the SECURITY DEFINER RPCs stay the only doors), anon/public
  execute revoked (the key demotion), both RPCs re-created on 03's bodies
  (horizon preserved, pinned) with `auth.uid()` gates, the two-half owner guard
  on pushes to the five owner tables (incoming rows must carry the caller's
  owner_id, NULL rejected; stored foreign/NULL rows never overwritten nor
  echoed — distinct error texts after round 1's NIT), and owner-filtered pulls.
  Guard failures RAISE (whole-call refusal — never a CAS-merge invitation).
  **The round-1 BLOCKER's load-bearing precondition rides the header, pinned:
  the single-user premise guards the eight non-owner tables ONLY with the
  Variorum project's signup door OFF** — Gate 0 disables it, Gate 4 probes it
  (403 + the OIDC-first-sign-in door probed live). NOT deployed — the paste is
  Gate 4 of the sitting, after the backfill converges (§12 choreography in the
  header, both execution hands recorded).
- **Step 4 — owner_id through Operations + the backfill (own commit; 7 core
  tests):** `@Dependency(\.ownerIdentity)` (live/test default signed-out; the
  app installs a per-call Keychain-reading closure at bootstrap —
  `OwnerIdentity.install`, the `AppDatabase.install` twin, no mutable global);
  all EIGHT top-level mint sites stamp; `adoptOwnerID()` — introspected owner
  tables, NULL-only, live AND tombstoned, outbox-riding (the backfill PUSHES),
  `updated_at`/`sync_version` untouched, idempotent, refuses signed-out — with
  the §12 choreography proven end-to-end on the sync harness (two devices
  converge byte-identical, fully owned). `owner_id` = the Variorum project's
  `auth.uid()` (the keying decision; the spike verified the exact value).
- **Step 5 — the sign-in era wired; the paste-in RETIRED (6 Mac wiring
  tests):** AppServices owns both sessions; sign-in → adoption FIRST → the
  sync chain over the auth provider → trigger; the Fragments session (ratified
  (c)) composes the bridge engine; sign-out tears down; the A4 fence holds
  even for a session that LAUNCHES signed in (sync + bridge + adoption all
  fenced, pinned); transport composition is factory-injectable (round 1 — the
  wiring tests are no-network composition truths); `SyncCredentialsStore` +
  `SyncSetupView` DELETED, the legacy Keychain item cleared on first sign-in,
  and the RETIREMENT WALK is a test (the old service string survives only in
  the cleanup). `ProjectConfig.swift` carries the projects' public coordinates
  (keys author-filled at Gate 0; committable BY DESIGN under the signups-off
  precondition). UI: `AccountView` (both doors, functional/unstyled);
  `SyncStatusRow`'s door is "Sign in…".
- **Step 6 — PENDING THE AUTHOR SITTING.** The runbook
  (`notes/handoffs/phase-09c-step6-runbook.md`, a first-class deliverable at
  her request) scripts all seven gates with expected outputs and
  failure→recovery paths (incl. the full RLS-lockout rollback and the round-2
  corrected server-side backfill repair). Folded in: the Phase 8 device
  rounds and the 9b real-Fragments pass (its ask-13 conditional stays held on
  Fragments' 15.7 deploy ping). Gate 0.3 (redirect URLs) was completed early
  by the author; the signups toggle was requested at round 1 and is confirmed
  at the sitting by Gate 4's probes either way.
- **Also this phase:** the 2026-07-10 contract item (the FOURTH `conflicts[]`
  producer pinned); the consent-page spec for the author's site agent
  (`notes/fragments-consent-page-spec.md`, session-persistence recommendation
  included); 02's SECURITY NOTE re-pointed at 04 (debt paid).

### Test counts (FINAL, post-ladder — the Phase 10 baselines once the gates pass)

- Core `swift test`: **540 green in 62 suites** (was 514/59 at phase start —
  +26 tests, +3 suites).
- Mac app: **254 green in 45 suites** (was 235/43 — +19, +2).
- Mobile: **11 green in 4 suites** (unchanged in count; rebuilt + re-run — the
  shared auth files compile into it).

### PROVISIONALs + ratifications

- **QUESTIONS #16 (the bridge's Fragments-session mechanism): RATIFIED EARLY
  by the author in-session 2026-07-10** — shape (c), direct sign-in ("if it
  can't be helped, direct fragments sign in is fine"); shipped as ratified;
  the captured provider pair stays persisted-but-unconsumed as the upgrade
  evidence. The checkpoint walk records the pre-answer.
- **No other PROVISIONALs are open from this phase.** The Step 0 memo's author
  call (route A) and the plan's owner-keying decision are recorded above; the
  runbook's Gate 4.3 carries the one live verification with a STOP arm (the
  OIDC-door/toggle interaction) rather than an assumption.

### Documented residuals (recorded, deliberately not solved here)

- **The single-user premise is procedural, not structural:** the eight
  non-owner tables are open to any authenticated Variorum-project user; the
  signups-off toggle is the guard until Phase 14's multi-tenant isolation
  (parent-join RLS). Carried in 04's header, ProjectConfig, and the runbook.
- **Fragments' PostgREST acceptance of OAuth-server-issued tokens stays
  unverified** — moot for the shipped bridge session (shape (c) uses the
  ordinary session class) but recorded for any future (a1)/(b) upgrade.
- **The 15.7 `replaced`-receipt consumption** stays a named follow-up on
  Fragments' deploy ping (Gate 6.5's conditional; the three discrimination
  rules recorded in contract ask 13).
- **The env-gated `SupabaseIntegrationTests` token semantics changed
  post-flip:** `VARIORUM_SUPABASE_TOKEN` must now be a real user access token
  (recorded at the test; the bare key is refused by design).

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

*(QUESTIONS #16 note: the author RATIFIED shape (c) in-session on 2026-07-10, before
the checkpoint — "if it can't be helped, direct fragments sign in is fine", relayed
by the coordinator with the instruction to build on it as ratified. Step 5 shipped
(c); the ratify walk records the pre-answer.)*

## Review round 1 (2026-07-10, cold reviewer — same-model flow) — 1 BLOCKER /
## 1 MAJOR / 3 MINOR / 4 NIT; ALL AGREED; every bug-class fix red-on-old-pinned
## (both pins verified red by behavioral revert); the reviewer also gave the 9b
## reconciliation diff a no-findings pass and a clean bill on the seven review
## foci. Dispositions below anchor round 2.

1. **BLOCKER — the demotion claim was falsified by the Variorum project's
   default-open signup door; the runbook's probes would have green-lit the false
   claim.** AGREED — mechanism re-traced and confirmed end to end: 04 guards the
   five owner tables per-user but serves/accepts the EIGHT non-owner tables
   (`variant` + `commit_point` = the whole prose corpus) for ANY authenticated
   user — the single-user premise IS their guard — while a default project mints
   authenticated sessions for any bearer of the (deliberately hardcoded,
   committable) publishable key via `POST /auth/v1/signup`; the same toggle gates
   first-time delegated OIDC sign-ins through the shared create-account path
   (soon relevant: Fragments' TestFlight users). Nothing in the phase mentioned
   the toggle, and Gate 4's probes all pass in the vulnerable state. **Fixed
   (operational + doc class, per the coordinator's routing; the author was asked
   to flip the toggle immediately):** runbook Gate 0 gains item 1 (disable
   "Allow new users to sign up" BEFORE everything else; existing users — hers,
   minted at the spike — keep signing in, so route A is unaffected); Gate 4 gains
   probe 2 (signup → expected 403 "Signups not allowed for this instance"; a
   session coming back = STOP, the dashboard save trap) and probe 3 (the
   OIDC-first-sign-in door verified closed by ONE live probe with a throwaway
   second Fragments user, since first-party docs never state the toggle covers
   custom providers — with a STOP-and-report arm if it is not refused); the
   failure table gains the signup row; `04_auth_rls.sql`'s header gains the
   LOAD-BEARING PRECONDITION block (pinned by the new
   `theHeaderCarriesTheSignupsOffPrecondition` — doc-class red-on-old: the
   pre-fix header lacked it); `ProjectConfig.swift`'s "committable by design"
   claim now carries the precondition explicitly. Self-caught alongside: 04's
   non-owner-table list wrongly included `reading` (an owner table) — corrected
   to the eight. The phase's goal statement ("the bare key grants nothing") is
   understood everywhere as conditional on signups-off until Phase 14.
2. **MAJOR — SignInFlow's three stacked lifecycle hazards** (unretained session;
   ignored `start() == false` leaking the continuation and wedging the sign-in
   surface busy forever; a scene-less `ASPresentationAnchor()` on iOS). AGREED —
   all three mechanisms verified against the ASWebAuthenticationSession contract
   (retention documented required; a false `start()` provably never invokes the
   completion; the bare anchor is the known iOS failure-to-present shape).
   **Fixed:** the session is retained in an instance property for the flow's
   duration (doubling as a one-flight guard, `FlowError.alreadyRunning`);
   `start() == false` resumes the continuation with `FlowError.couldNotPresent`;
   the anchor is the real key/main window (macOS) or the foreground-active
   scene's key window (iOS), with the bare anchor only as the last-resort
   fallback. No pin owed (the thin-face convention; Gate 2/3 exercises it for
   real) — mechanism trace above is the justification.
3. **MINOR — sign-out racing an in-flight refresh resurrected the signed-out
   session, Keychain included.** AGREED — traced: the actor releases at
   `try await task.value`; a completed-HTTP refresh resumed after `signOut()`
   and adopted+saved unconditionally, so the UI/sync said signed out while the
   Keychain held live tokens, the ownerIdentity closure resumed stamping, and
   the next launch came up signed in — the file's own "only signOut clears"
   contract inverted. **Fixed:** after the await, a nil `tokens` discards the
   result (throws `notSignedIn`); a CHANGED refresh token (a new sign-in
   superseded the in-flight refresh — the same mechanism's other arm, found
   while fixing) returns the live session without saving the stale result.
   **Red-on-old pin:** `signOutDuringAnInFlightRefreshDoesNotResurrectTheSession`
   (endpoint-routed loader: slow refresh, instant logout; sign-out mid-flight;
   asserts the discarded result, the empty store, and signed-out state) —
   verified RED by behavioral revert (all three assertions failed with the
   resurrected Keychain visible in the failure output), green restored.
4. **MINOR — the bridge transport lacked the 401 refresh door the mirror
   transport got at Step 2**, though both now ride the same refreshable
   AuthSession. AGREED — traced: `FragmentsRPCTransport` only ever called
   `currentSession()` (which refreshes within 60 s of LOCAL expiry), so a
   server-side-stale token failed every bridge round — visibly and
   state-intact, but wedged — for up to ~59 minutes. **Fixed:** the rpc gained
   the identical ONE-refresh-and-retry branch (via the protocol's
   `refreshedSession()` door, built for exactly this sharing), the expectedUser
   cross-check re-applied to the refreshed session, and the HTTP hop gained the
   same internal `load` seam as the mirror transport. **Red-on-old pin:**
   `a401RefreshesOnceAndRetriesWithTheNewBearer` (bridge twin of the Step 2
   pin: 401 then 200; two requests; second bearer fresh; identical payload) —
   verified RED by behavioral revert (surfaced `httpFailure(401)` after one
   request), green restored.
5. **MINOR — the wiring tests fired real network requests at the production
   project URL** (the AppServices sign-in wiring composed the ProjectConfig
   production transports; assertions didn't depend on the outcome, so the
   suites stayed green while breaking the repo-wide no-network discipline —
   and post-Gate-0 key-fill every CI run would have probed the real project).
   AGREED. **Fixed:** AppServices gained injectable `makeSyncTransport` /
   `makeBridgeTransport` factories (defaults compose the production
   ProjectConfig transports); the wiring tests inject recording fakes and now
   additionally assert rounds RAN on the injected transports (sign-in test:
   sync calls > 0; bridge test: bridge calls > 0; dev-fence test: BOTH zero;
   bridge-disabled test: zero) — the fence/wiring claims are now composition
   truths, not network luck. Test-infrastructure class: the strengthened
   assertions are the pin (they fail without the seam by construction — the
   factory parameter cannot be injected on the pre-fix init).
6. **NIT — a failed adoption didn't gate sync composition** (post-flip every
   round would fail until relaunch). AGREED — fixed the lighter-but-honest way:
   `runOwnerAdoption()` returns success and `connectSyncIfAllowed` composes
   NOTHING on failure, surfacing "sync held; sign out and back in (or relaunch)
   to retry" on the account state — the same §12 stall-never-guess posture as
   the engine, and no chain that is guaranteed to fail. Architectural class:
   mechanism traced (adoption throws only on store-level write failure), no pin
   owed; the happy-path wiring tests cover the composed side.
7. **NIT — the stored-half guard's message misled for NULL-owner stored rows**
   ("belongs to another owner" for a row that merely escaped the backfill,
   while the runbook keys recovery off error text). AGREED — 04 branches the
   NULL case into "row … is not yet backfilled — complete the owner adoption
   before the flip"; the runbook's failure table gains the matching row; the
   `pushCarriesBothOwnerGuards` pin still passes (both original strings
   remain).
8. **NIT — 02_sync_rpc.sql's SECURITY NOTE still forward-pointed the auth debt
   at Phase 14.** AGREED — the note now records the debt as PAID by 04 in this
   phase (read 04 before reasoning from 02's superseded bodies); Phase 14 keeps
   only multi-tenant isolation.
9. **NIT — the plan's Step 3 named `sync_delete` among the RPCs to rework**
   (Fragments' dialect, not Variorum's). AGREED — corrected in place with a
   bracketed review-round note; the shipped artifact was already correct.
10. **NIT — the consent-page spec contradicted itself on session persistence**
    (the 2026-07-10 recommendation vs the older "no session persistence"
    minimalism bullet). AGREED — reconciled to the recommendation: the
    persisted Fragments session is the ONE sanctioned piece of state; the
    reconciliation is noted inline so the site agent sees one instruction.

**Counts after the fix round: core `swift test` 540 green in 62 suites (was
538 — +1 bridge-401 pin, +1 signup-precondition header pin); Mac app 254 green
in 45 suites (was 253 — +1 sign-out-race pin); mobile 11 green in 4 suites
(rebuilt + re-run — the shared AuthSession/SignInFlow/AppServices changes
compile into it).**

## Review round 2 (2026-07-10, fresh cold reviewer) — ZERO new BLOCKER/MAJOR
## (2 MINOR / 2 NIT) + a clean bill on every round-1 fix (04 diffed line-by-line
## vs 03; the stamping sweep; both 401 doors; the retirement walk; counts
## verified by execution). Per the ladder, the ladder CLOSES here — no round 3.
## ALL FOUR AGREED; dispositions below.

1. **MINOR — the runbook's failure-table recovery for the `not yet backfilled`
   error could not work post-cutover.** AGREED — mechanism re-traced: that error
   is 04's STORED-half guard firing on a NULL-owner MIRROR row; post-flip the
   local adoption stamps LOCAL rows only, the pull's owner filter hides the NULL
   mirror row (it can never re-serve), and every push touching it RAISEs — the
   prescribed relaunch loop never self-heals. (Pre-flip, Gate 2.5's "Sync now and
   re-check" stays correct — 03's un-guarded bodies accept the overwrite.)
   **Fixed (doc class):** the failure-table row now prescribes the SERVER-side
   repair (`update <table> set owner_id = '<her uid>' where id = '<row-id>'` via
   PAT/SQL editor — table + id ride the error text — with the Gate 2 mirror
   totality query for enumeration and the Gate 4 full rollback as the wide-spread
   arm); the Gate 4 recovery list gains the matching bullet AND splits the
   `owner_id mismatch` bullet honestly (the INCOMING-half guard, where local
   adoption DOES fix a locally-unowned pulled row) from the stored-half case.
   The runbook answers this gate question correctly now.
2. **MINOR — the round-1 "doubles as a one-flight guard" claim was falsified by
   composition** (a per-invocation `SignInFlow()` made `alreadyRunning`
   unreachable; the busy button-disable has a real two-rapid-taps window because
   nothing guarded the method entries). AGREED — **fixed both ways:** the flow is
   hoisted to a stored `let signInFlow` on AppServices (the shipped guard is now
   real: a second tap lands on the same instance and throws `alreadyRunning`),
   AND `signInWithFragments`/`connectFragmentsJournal` gained `guard
   !account.busy` entry belts (two enqueued Tasks can both pass the button's
   disable). Thin-face class per the round-1 disposition — no pin owed;
   mechanism traced above.
3. **NIT — single-flight sibling waiters bypassed the post-await sign-out
   guard** (a waiter returned the raw task value; after a sign-out mid-refresh
   its caller issued one authenticated request post-sign-out — no save, no
   resurrection, equivalent to a request already in flight). AGREED — took the
   route-through-the-guards arm, restructured for determinism: the leader's
   whole refresh (HTTP + the post-await guards + adoption) now lives INSIDE the
   single-flight task (`performRefresh`), so every awaiter observes a SETTLED
   outcome (the naive waiter-side guard alone had an ordering hole: a waiter
   resuming before the leader adopted would have returned the stale pre-refresh
   tokens); waiters then re-check sign-in state and return the LIVE tokens
   (covers the superseding-sign-in arm too). The round-1 pin and the
   single-flight pin both still green — the round-1 red-on-old property
   (sign-out is terminal, Keychain included) is unchanged.
4. **NIT — BridgeSession's stale "CONFIGURATION IS DELIBERATELY ABSENT THIS
   PHASE" header.** AGREED — rewritten: the production caller is
   `AppServices.connectBridgeIfAllowed` (9c Step 5), composing over the
   Fragments session per QUESTIONS #16 (c), stopping on disconnect; the
   original wording is quoted as history so the correction is visible.

**Counts after the round-2 fix pass (the ladder's FINAL): core `swift test`
540 green in 62 suites; Mac app 254 green in 45 suites; mobile 11 green in 4
suites — all three targets re-run green.**

---

## Step 6 — THE GATE SITTING (2026-07-11; the author + a fresh Fable session driving — the runbook's fresh-session design used as intended). ALL SEVEN GATES PASSED; THE PHASE CLOSES HERE.

**Gate 0 (preconditions):** signups confirmed OFF pre-sitting (proven at Gate 4).
Both publishable keys filled in `ProjectConfig.swift`, Release build green.
Redirect URLs done early (runbook 0.3). Consent page served from the spike
(localhost, then the Gate 3 LAN arm). Mac Release install lands at
`/Applications/Variorum.app` (new standing arrangement — CLAUDE.md workflow
addition this sitting: the installed copy is the ONLY thing the author launches;
sessions refresh it after Mac-app changes).
**Gate 1 (backup):** taken app-quit; `integrity_check` = `ok`
(`~/Desktop/variorum-pre-9c-cutover.sqlite`).
**Gate 2 (Mac sign-in + backfill):** PASSED — after the sitting's findings 1–3
below were fixed (the first real end-to-end `SignInFlow` run was THIS sitting,
exactly as the thin-face convention predicted). Adoption stamped everything;
*[removed for publication]*
Wrinkle observed working as designed: the two Phase 5 integration fixtures
("from the Mac/phone DD380EAF") pulled down unowned AFTER sign-in's adoption
pass; the every-signed-in-launch idempotent adoption stamped them at relaunch —
the self-heal, observed live.
**Gate 3 (phone):** Release install + sign-in PASSED via the LAN arm: the phone
cannot reach localhost, so Fragments' OAuth Site URL was pointed at the Mac's
LAN IP (`http://<lan-ip>:3000`) serving the spike page — RESIDUAL 1 below.
**Gate 4 (cutover + probes):** `04_auth_rls.sql` executed VERBATIM via the
author's PAT (Management API, HTTP 201, no errors). Bare-key `sync_pull` →
401/`42501` with AND without the Authorization header; direct table read →
401/`42501` (the Data API door is dead); signup → refused `signup_disabled`
"Signups not allowed for this instance" — **recorded deviation: HTTP 422, not
the runbook's expected 403** (platform drift; same gate, same meaning, no
session minted). **The OIDC first-sign-in door: proven closed at the actual
decision point** — after finding 7 unblocked the flow, a scripted hop-by-hop
probe walked the throwaway Fragments user's full delegated flow; Variorum's
callback received code+state and refused `access_denied / signup_disabled`;
`auth.users` stayed at exactly one (her). Throwaway user deleted; the temporary
localhost redirect re-add removed (author-confirmed). Positive probes: both
devices Sync-now green post-flip.
**Gate 5 (device rounds — Phase 8's deferred, folded in):** PASSED with
findings. (1) Offline capture: outbox kept, drained clean on reconnect, the Mac
pulled both changes — but the status row read "SyncError" while offline
(finding 6). (2) Two-way distinct-block edits: both edits on both devices, zero
conflict variants — but the iOS editor sometimes grows trailing blank lines
(finding 6). (3) The S5 race: **run as the simultaneous-edit variant** (the
author kept one device online — other work running; deviation recorded), several
repetitions: exactly one `conflict`-labeled take per race, both devices converge
on the winner, nothing lost. The both-offline arm was not run as scripted; the
CAS-reject/merge machinery exercised is the same S5 class.
**Gate 6 (the bridge / 9b's real-Fragments pass):** PASSED — largely proven
ORGANICALLY mid-sitting, before the cutover: a Fragments-written entry landed in
Variorum with the correct store shape (journal profile, `entry_date` set), and a
Variorum edit re-projected to the Fragments Day screen. The fail-closed
canonical-user gate never tripped (`user_settings` present). Dump-compare:
byte-identical. NOT run live: the simultaneous both-app edit-war (headless-
pinned in 9b; insured by S5 + the fifth occasion; week one exercises it
organically). Ask-13: NO deploy ping as of the sitting — nothing consumed, the
conditional stays a named follow-up.
**Gate 7 (close):** final totality five zeros local AND mirror; post-fix suites
re-run green — Mac 254/45, mobile 11/4 (core untouched by the sitting: 540/62
stands); the localhost redirect confirmed gone; the consent serving documented
as LAN-interim (RESIDUAL 1).

### The sitting's findings (seven; each mechanism traced live)

1. **The consent page didn't handle auto-approval** — a previously-granted
   client+scope auto-approves at the details GET (the response IS the completion
   `redirect_url`); the spike page rendered it as a pending request and its
   consent POST 400'd ("authorization request is no longer pending"), stalling
   the author's first sign-in attempt. FIXED in the page; the production spec
   corrected (the auto-skip runs THROUGH the page, not around it).
2. **`SignInFlow`'s completion handler trapped off-main** — SIGTRAP in
   `dispatch_assert_queue`: ASWebAuthenticationSession delivered its completion
   on a background XPC reply queue; the closure had inherited @MainActor
   isolation and Swift 6's runtime check killed the app mid-sign-in. FIXED: the
   closure is explicitly `@Sendable`/nonisolated (it only resumes a
   continuation — thread-safe by construction). Thin-face class; the crash
   report is the trace.
3. **The Mac target lacked the outgoing-network entitlement** — sandbox on,
   network client off (the Xcode template default): every app-side URLSession
   call failed as DNS `-1003` while the browser sheet (a separate system
   process) worked; never caught before because the GUI app had never made a
   network request until this sitting (Phase 5/8 real-server passes ran via
   `swift test`). FIXED: `ENABLE_OUTGOING_NETWORK_CONNECTIONS = YES`, both
   configs.
4. **The Account sheet's two Fragments doors conflate** — the author signed into
   the BRIDGE form believing it was the identity sign-in, and everything
   appeared to work because bridge traffic needs only the Fragments session
   (diagnosed from the store: `sync_state` empty, adoption never run). UX
   finding for the feel-pass/Phase 13 territory; recorded, not restyled now.
5. **Return was a silent no-op in the bridge credential fields** — FIXED:
   email's Return advances focus, password's Return submits through the same
   door as Connect (`connectBridge()`).
6. **Offline reads as "SyncError" / iOS trailing blank lines** — both recorded
   as KnownIssues rows (owners: Phase 10 and Phase 15 respectively; the iOS one
   proven STORED content by store query — one live variant carries a 3-newline
   trailing run).
7. **The `redirect_uri` trap** (this sitting's own fix-of-a-fix, owned
   honestly): finding 1's patch followed `details.redirect_uri` — the client's
   REGISTERED callback base, no code/state — on the pending path, sending every
   fresh-consent browser flow to Variorum's callback as "OAuth state parameter
   missing" (both of the author's throwaway browser probes hit it). FIXED
   (`redirect_url` ONLY, both paths) + the trap spelled out in the production
   spec; the scripted probe transcript is the trace.

Also recorded where they live: the "Show Blocks" tint row gained the
per-wrapped-line evidence (KnownIssues, owner 10 unchanged); the Phase 10 plan
gained the author's journal-home expectation as binding input (her first
bridge-landed entry rendered as an untitled row in the flat library); the Phase
11 brief gained the HTML-mockup-spike kickoff addendum (author decision); the
Phase 14 brief gained her encryption leaning + the bridge-plaintext constraint;
CLAUDE.md gained the /Applications install rule AND the amended model policy
(author, 2026-07-11: Fable implements 10 and 11 same-model; 13 = author-attended
Fable sessions; 14 = Fable end-to-end); QUESTIONS #16's early ratification was
walked and stands (nothing new queued).

### Residuals (operational, named)

1. **Sign-in currently depends on interim consent serving:** Fragments' OAuth
   Site URL points at the Mac's LAN IP (`<lan-ip>:3000`), served by a
   session-bound `python3 -m http.server 3000` in `Spikes/AuthPairingSpike/` —
   which DIES with the sitting session. Sign-ins are rare (once per device;
   tokens self-refresh, so daily use is unaffected), but any FUTURE sign-in
   needs that server re-run — until the stargazing.tech consent page ships
   (handoff item 4) and Site URL/Authorization Path point there permanently.
2. The two DD380EAF fixture posts remain in the library (owned) — delete via
   Phase 10's lifecycle UI.
3. ~~Fragments' 15.7 deploy ping still pending (ask-13 consumption stays the
   named follow-up; nothing assumed).~~ **RESOLVED 2026-07-11, hours after the
   sitting:** the ping arrived; the deployed SQL was verified against their repo
   (author-authorized read-only look — their prose's `"conflicts": {}` example was
   wrong per their own SQL, the recorded trap); the fake server is pinned to the
   final shape and the consumption path shipped under ask 13's three discrimination
   rules, closing the 9b "first-push overwrite window" residual for every
   in-process path (the one-shot-delivery process-death sliver is the recorded
   remainder). Core 545/62, then 547/62 after the same-day Fable cold review of
   the diff (2 MAJOR / 1 MINOR / 3 NIT, all agreed + fixed, red-on-old pinned).
   Record: the contract's "Ask 13 CLOSED" addendum.
4. The Phase 7/9 combined feel pass remains owed whenever the author wants it.

**THE PHASE IS CLOSED (2026-07-11).** Phase 10 baselines: **core 547/62 ·
Mac 254/45 · mobile 11/4** (Mac + mobile re-run green after the sitting's fixes;
core superseded twice the same day — 540→545 by the ask-13 receipt consumption,
545→547 by its Fable cold-review round — record: the contract's "Ask 13 CLOSED"
addendum).
