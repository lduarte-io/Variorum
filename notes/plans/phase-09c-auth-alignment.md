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
final shape and add the consumption path — a received `previous_body` lands as a
`'fragments'` conflict variant through the ordinary landing door; otherwise it
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
