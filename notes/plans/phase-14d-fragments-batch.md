# Phase 14d — The Fragments batch & bridge resumption — micro-plan

> **Status: OPEN — kicked off 2026-08-14 under `/architect-phase`
> (author-attended; the kickoff sitting record below carries her cast
> and sequencing rulings). Previously: FINALIZED 2026-08-11 at 14c's
> close. All FILL-AT-GATE fields completed (below); the phase
> now carries, besides the Fragments handoff, the operationalia she
> DEFERRED out of 14c's gate (signup flip · stranger validation ·
> branded auth-email links via the free template road — the phone
> re-onboard already DISCHARGED by her live confirmation). Micro phase
> by her ruling; it gates on nothing but the Fragments conversation and
> her own account acts (Pro, SMTP provider, signup flip).**

## Kickoff message (paste-ready)

You are running Variorum Phase 14d (repo ~/dev/variorum, branch main)
— a MICRO phase, likely a single author-attended session (cast decided
at this kickoff as always; the 9d shape — author present, no
coordinator relay — fits its size). Its scope has TWO parts: (A) the
ONE-BATCH Fragments handoff the author carries + Variorum's own small
bridge-resumption acts (the reason this phase exists); and (B) the
operationalia she deferred out of 14c's gate — opening the Variorum
project's signup door, validating a stranger's first onboarding
(empty-store first pull, vault setup, the PL-6 phone first-run walk),
and the SMTP + branded-auth-email setup (the free template road:
custom SMTP + a rewritten email template pointing at stargazing.tech +
a `/auth/confirm` verifyOtp handler the site agent builds — the paid
Custom Domain add-on was DECLINED). None of B is needed until real
strangers/TestFlight, so sequence it around A per her word. READ
FIRST: (1) this file in full (esp. the "ABSORBED FROM 14c" section +
the completed FILL-AT-GATE fields — the issuer is the RAW project URL
*[removed for publication]*
master plan's 14d row; (3) `notes/fragments-bridge-contract.md` — the
EXECUTION MODEL + its 2026-08-04 amendment + ALL THREE touchpoint
blocks WITH their concrete-facts additions (the brief SHE carries;
every FILL-AT-GATE field is verified-final); (4) the 14c plan
`notes/plans/phase-14c-multi-tenant.md` — Batch 2's record (the dormant
bridge machinery + THE TRACED CORNER) and the "GATE HALF — execution
record" (what deployed and what deferred here); (5) the SMTP runbook
`notes/plans/phase-14c-smtp-runbook.md` (execute its §2–§7 for part B);
(6) `notes/sync-postmortem-fragments.md` before any
`Sources/VariorumCore/Sync/` or bridge-engine line. STANDING: sessions
never touch `~/dev/fragments` or the Fragments Supabase project — the
contract file is the channel, carried by her; the Variorum mirror rails
(announced acts, committed artifacts, her go, the A1 rail) bind; the
signup toggle flips only as this phase's deliberate act.

## The scope, in execution order

**Step 0 — the SMTP config act (Round 7's re-slot; anytime in this
phase, hard deadline BEFORE TestFlight).** The runbook's §2–§6 executed
with her: the provider account (Resend recommended, hers to overrule),
the Cloudflare DNS records (SPF/DKIM; mind the runbook's grey-cloud
CNAME trap), the dashboard SMTP fields, her template-copy ratify (the
drafts are staged in the runbook §6; the reset draft's
never-touches-your-encryption-passphrase paragraph is load-bearing).
After it: delivery opens to all addresses; the email rate limit resets
to its default (adjust per the runbook's rate-limits section).

**Step 1 — the one-batch Fragments conversation (SHE carries it).**
The contract file's three touchpoints, in order, one conversation with
the Fragments agent: #1 the provider swap + her uid link (the
*[removed for publication]*
must survive — verify before proceeding) + password retirement + the
*[removed for publication]*
retired (safe since 14a shipped the direct sign-in) · #2 the
journal-class E2EE client work (the concrete format facts block; the
trim + empty-body relocations; point 9's stale-key honesty) · #3 the
entitlement check (the concrete facts block added at 14c). Her
standing latitude: Fragments may be broken mid-batch; nothing
Variorum-side depends on it.

**Step 2 — Variorum's resumption acts (small, real; the only code in
the phase).**

1. **The deliberate un-pause:** wire the LIVE journal-bridge key
   provider — `DeviceBridgeKeyProvider` (built + pinned dormant at 14c
   batch 2) — through `AppServices`' `makeBridgeKeyProvider` seam. The
   dormancy pin flips to a liveness pin in the same commit.
2. **THE RESUMPTION ORDER — the traced corner (14c batch 2's record;
   do NOT resume naively):** the bridge's pinned round order is
   pull→push (postmortem lesson 5), and the satellite holds
   legacy-plaintext bodies — plus, if the account was ever RE-KEYED,
   old-key `e1:` bodies — that the resumed pull would refuse BEFORE
   the staged re-push overwrites them. Two arms, decided here with
   the trace in hand:
   - **(i) push-first resumption drain (the draft recommendation):**
     `stageRepushFromTruth` marks every live day, then a push-only
     drain runs BEFORE the first ordinary pull→push round — the
     overwrite lands before any pull can refuse. Trace against
     `BridgeEngine`'s actual round structure first; if a push-only
     mode needs a small affordance, it is this phase's one candidate
     code addition (red-on-old pinned like everything).
   - **(ii) tolerate visible pull refusals until overwritten** — zero
     code, honest, noisy; acceptable only if (i)'s trace shows real
     risk.
   The pull→push pin itself is NEVER weakened for ordinary rounds —
   the drain is a one-time resumption act, not a reorder.
3. **The staged re-push from truth:** every live journal day
   re-arrives as `e1:` ciphertext — this ends the satellite's
   legacy-plaintext era (her historical days encrypted at rest on
   Fragments' server from this act forward).

**Step 3 — the verification that closes the phase (the row's
letter):** a FULL bridge round-trip over ciphertext on both ends — an
entry created in either app lands in the other, encrypted in flight
and at rest on the mirror side (the resumption proof); her Fragments
uid preserved; the one-payment entitlement reads the same answer from
both apps. Then TestFlight unblocks (her standing ruling), and the
closeout ritual runs (micro-sized: the master plan row + pointer, the
contract file's state, the parity line, the handoff note).

## FILL-AT-GATE fields — COMPLETED at the 14c close (2026-08-11)

*[removed for publication]*
  — the RAW Supabase project URL. **The `auth.stargazing.tech` custom
  domain was DECLINED at the 14c gate** (her ruling): a lookup confirmed
  branded auth-email links come FREE via a rewritten email template
  (`{{ .SiteURL }}/auth/confirm?token_hash={{ .TokenHash }}&type=…`) + a
  *[removed for publication]*
  Custom Domain add-on (which rebrands only user-invisible surfaces — the
  API hostname, OAuth callbacks, and per a community report maybe not
  even the `iss`) buys nothing her users see. **14d writes Fragments'
  provider config against this raw project URL.** (If she ever changes
  her mind, attaching a custom domain later is a coordinated
  config-only update, never data — but there is nothing to verify at
  attach today because nothing is attached.) The branded-email TEMPLATE
  work + the site handler ride THIS phase's SMTP step (Step 0).
- [x] **The deployed entitlement state:** `entitlement_set` is LIVE
  (service_role-only, verified). Her account's seed row is present and
  confirmed (`hosted_sync`, non-expiring, source `14c-deploy-seed`,
  *[removed for publication]*
  *[removed for publication]*
  then FULLY PURGED by the deletion-door test — no probe residue remains
  (auth user, vault, entitlement all gone; verified).
- [x] **The signups toggle's post-gate state:** STILL OFF — the signup
  flip DEFERRED to 14d (this phase). No validation-era org-team
  membership was ever added (ARM (a) was moot — stranger validation
  deferred), so there is no cleanup owed. **Opening the signup door is
  THIS phase's act**, after/with the SMTP setup (Step 0).
- [x] **Her Variorum-usage pause status at 14c's close:** held through
  14c (Round 1); its end-state is HERS to declare. Recorded caveat for
  this phase: the 14c rebuild reset the mirror, so her PHONE's saved
  cursor is stale and it must RE-ONBOARD (fresh store, enroll by
  passphrase, pull-to-head) before phone↔Mac sync is reliable — until
  then phone writing stays local-safe but may not propagate. Its build
  VERSION is the mobile session's to confirm (the 2026-08-11 merged-tree
  Release install carries lockstepVersion 6, but its completion needed
  the phone unlocked to mount) — if already marker-6 it won't refuse on
  version, if older it will; either way re-onboard is the clean path.

## ABSORBED FROM 14c (her 2026-08-11 deferral ruling — this phase now
## carries these beside the Fragments touchpoints)

- **The signup flip** — open the Variorum project's signup door (the
  sole remaining corpus guard until then); preconditions already green
  (isolation proven, tier machinery live).
- **Stranger-onboarding validation** — a fresh account in-app: the
  empty-store first pull reads as normal, the CF-5 stepped vault setup
  as a stranger, and the PL-6 phone first-run FULL-SETUP walk (its
  first safe live subject). Whichever email-confirmation posture she
  rules with SMTP live (ARM-(a) org-team add, autoconfirm, or admin
  provisioning — the runbook §1 fork).
- **The phone re-onboard — DISCHARGED (her live confirmation
  2026-08-11), no action owed.** She installed the marker-6 build and
  phone↔Mac sync works perfectly with NO re-onboard and NO passphrase
  re-entry — correct, because the 14c repush was unwrap-only (keys
  unchanged) and enrolled devices hold class keys in the Keychain, not
  the passphrase. Kept here only as a recorded-resolved note; her phone
  is a first-class synced device against the reborn mirror.
- **Branded auth-email links** — the FREE template road (above) + the
  `/auth/confirm` handler the stargazing.tech agent builds; rides the
  SMTP step. No custom domain.

## Held facts this plan must not lose

- The bridge pause is STRUCTURAL (a refusing default provider) — no
  rounds have run since 14b; resumption is THIS phase's deliberate
  act, never a side effect.
- The re-key door's bridge-staging trigger (14c batch 2) is inert
  while the pause stands and becomes live with the un-pause — a
  re-key AFTER this phase automatically stages the journal re-push
  (the CF-8 journal-side consequence, already built).
- Fragments' `replaced` receipts fire MORE often under E2EE (random
  nonces break byte-identity) — the bridge's rule (i) discriminates by
  decrypted content, already built and pinned (contract point 8).
- The 2/hr built-in mailer cap ends at Step 0 — do not schedule
  TestFlight invites before it.

## Residuals (phase-end carry-outs — hers, at her word)

- **DMARC on stargazing.tech — deliberately NOT done in this phase
  (her ruling, 2026-08-16): she's finishing the phase without it, and
  hasn't fully decided which email should receive the reports; she
  will come back to it later.** The note to carry back, recorded at
  her request: *DMARC is entirely fine to add later (it's
  deliverability/anti-spoofing hygiene on top of SPF+DKIM, not
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  whenever you like.*
- **The secret-key rotation** (the Step 0 incident note above) —
  recommended, hers to take or decline.

## Kickoff sitting record (2026-08-14 — author-attended)

- **Invocation:** `/architect-phase`, her args: Fable orchestrator;
  "probably fable implementer but potentially opus if it's quite
  simple"; she needs the path of the Fragments handoff brief + the
  paste-ready prompt for it.
- **Binding principles:** the 13b constitution (P-1…P-9) binds per the
  `/architect-phase` skill, copied by reference exactly as 14b/14c did.
- **RULING — cast:** the 9d shape — **the architect (Fable) implements
  Step 2 directly in this author-attended session** (no coordinator
  relay, no separate implementer), **plus ONE fresh cold reviewer over
  the phase's combined diff before closeout** (the Phase-14-family
  security posture, kept cheap by the micro diff). Her pick of the
  recommended option.
- **RULING — sequencing, her words verbatim:** *"fragments prompt now
  but we're doing the SMTP right now as well. i want it to be ready to
  release pretty much at the end of this phase."* Consequence: this
  sitting carries the Fragments prompt handoff AND Step 0 (SMTP);
  the release-ready bar means part B (signup flip · stranger
  validation · branded links) completes IN this phase, not deferred
  toward TestFlight.
- **Architect sequencing note (the template-road dependency, recorded
  before Step 0 executes):** the branded `token_hash` template form
  must NOT be pasted while stargazing.tech's `/auth/confirm` handler
  doesn't exist — confirm/reset links would dead-end at a 404. Step 0
  therefore ships her ratified COPY on the stock
  `{{ .ConfirmationURL }}` links first; the flip to
  `{{ .SiteURL }}/auth/confirm?token_hash=…` is a config-only act
  taken when the site handler is live (the site-agent prompt below is
  the handler's brief). The SMTP runbook gained the same note (dated
  amendment, 2026-08-14).
- **Secrets rule for Step 0 (the `.env.supabase.local` pattern):** the
  provider API key lands in an untracked env file by HER hand
  (`.env.smtp.local`, gitignored) or directly into the dashboard —
  never a transcript.

## Step 0 execution record (SMTP — 2026-08-16, the kickoff sitting's
## second day; architect acts via the Management API, hers by hand)

- **Her acts, done:** Resend account + domain `stargazing.tech` added;
  the Cloudflare records placed (Resend's shape: DKIM TXT on
  `resend._domainkey`, SPF TXT + feedback MX on `send`); domain
  **VERIFIED** at Resend; the API key staged in `.env.smtp.local`.
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  *[removed for publication]*
  pass without it.
- **Hygiene fix (committed `d360530`):** `.env.smtp.local` arrived
  untracked but NOT gitignored (the other secret files are ignored by
  name) — added it plus the `.env.*.local` glob before touching
  anything else.
- **Config pushed (PATCH 200, read-back verified):**
  `smtp.resend.com:587`, user `resend`, pass set (never echoed),
  sender `Stargazing <no-reply@stargazing.tech>` (the runbook's
  candidates — one-line renames if she rules otherwise),
  `smtp_max_frequency` 60 s, `rate_limit_email_sent` pinned 30/hr
  (was unset-default). Useful read-backs: `site_url` is ALREADY
  `https://stargazing.tech` (good for the branded flip),
  `mailer_autoconfirm` false, `disable_signup` still true (the door
  stays shut until the deliberate flip).
- **Delivery probe fired:** throwaway auth user
  *[removed for publication]*
  (bypasses signups-off by design), `/auth/v1/recover` → 200 through
  the new SMTP. Non-team address ⇒ delivery at all proves custom SMTP
  live (the built-in mailer refuses such addresses). AWAITING her
  inbox check: sender correct + `spf=pass`/`dkim=pass` headers.
  **Cleanup owed: purge the throwaway user after her check** (it must
  not survive into the stranger-validation walk).
- **Step 0 COMPLETE (2026-08-16, same sitting):** she confirmed the
  probe email ARRIVED ("i got the stargazing email in my email! so
  *[removed for publication]*
  nothing survives into the stranger-validation walk). **Templates
  PASTED (PATCH 200, read-back verified) with HER RATIFIED COPY** —
  her own confirm-signup rewrite verbatim (typo fixed), reset kept
  with the load-bearing account-password-vs-encryption-passphrase
  paragraph rephrased plainly, all three humanized per her advance
  ratify ("whatever you do with that is fine and ratified"; "the em
  dashes and how they're phrased is just too AI"). The LIVE config is
  the copy's source of truth; the runbook §6 drafts are superseded
  (dated note added there). Stock `{{ .ConfirmationURL }}` form as
  ruled; the branded flip still waits on the site handler.
- **INCIDENT NOTE (architect's own, honest):** while fetching "the
  publishable key" for the site prompt, `VARIORUM_SUPABASE_API_KEY`
  from `.env.supabase.local` was echoed into the transcript — and it
  turned out to be an `sb_secret_…` SECRET key (that env file is
  architect tooling, not app config). Exposure bounded to her local
  transcript; RECOMMENDED: rotate the secret key at the dashboard
  (Settings → API keys) and update the env file — her call, tracked
  here until she takes or declines it. The actual publishable key
  (`sb_publishable_X-TQvz2RDj4cnCABZao4ww_WWGdSTwp`, public by
  design) was then fetched cleanly for the site prompt.

## Step 2 execution record (the un-pause + the resumption order —
## 2026-08-16, the architect implementing per the cast ruling)

**2.1 The deliberate un-pause — BUILT, PINNED, REVERT-VERIFIED:**
`VariorumApp`'s production composition now passes
`makeBridgeKeyProvider: { DeviceBridgeKeyProvider() }` (the Mac's
construction site; the phone's composition is untouched — the bridge
is disabled there by Phase 9b's Mac-side scope). Comment truths
updated at all three carriers (the AppServices seam doc, the
provider's own doc, the core dormancy test). **The dormancy pin
flipped to liveness as the plan demanded:** core
`stagingIsInertWhileTheStructuralPauseStands` RENAMED to its post-14d
truth `stagingIsInertWhileKeysAreUnavailable` (same mechanism — the
refusing default now models the unenrolled/CF-12-locked states, no
longer production); NEW app-side liveness pin
`theMacProductionCompositionWiresTheLiveBridgeKeyProvider`
(source-anchored, the retirement-walk precedent — the scene body is
not constructible headless). **Red-on-old by behavioral revert:** the
wiring stashed → the suite fails on exactly that pin (14/15 pass);
restored → 15/15. Core bridge suites 85/9 green. *(A vacuous-pass
trap re-confirmed live: function-level `-only-testing` selected 0
tests and "passed" — the environment traps' suite-level-only rule is
load-bearing; the revert proof was re-run at suite level.)*

**2.2 THE RESUMPTION ORDER — ARM (ii) RULED BY TRACE (the architect's
call, the plan's two arms adjudicated with the trace in hand):**

- The traced facts: `run()` is pull→push (pinned, untouched); the
  pull's ONLY refusal classes are unopenable `e1:` bodies (tampered /
  old-key / future-version) — legacy PLAINTEXT lands as text by the
  three-arm classification, and plaintext rows are what Fragments has
  written since the pause (their client has no E2EE until touchpoint
  #2).
- **The refusal set arm (ii) would tolerate is EMPTY at this
  resumption:** the bridge NEVER ran an encrypted round (the pause
  predates any possible `e1:` push — GM-2's record), so no old-key
  ciphertext can exist in the satellite; her 14b re-keys predate any
  possible Fragments-side ciphertext; and any `e1:` their new client
  writes post-handoff seals under the CURRENT vault key, which
  `DeviceBridgeKeyProvider` also holds. There is nothing to refuse.
- **Consequence: arm (i)'s push-first drain is NOT BUILT** — it would
  be engine surface guarding a state that cannot occur today (dead
  code, and `BridgeEngine` surgery for nothing). The ordinary
  pull→push round resumes unmodified.
- **The FUTURE corner keeps batch 2's recorded posture as the final
  word (the plan asked 14d to own it):** a post-14d re-key with
  unlanded Fragments writes ahead of the cursor refuses the round
  VISIBLY, cursor held, until those rows are re-saved Fragments-side
  under the new key or the account re-enrolls them; the re-key door
  already stages the re-push. Narrow (needs both events), loud, loses
  nothing. If it ever bites in practice, a one-time push-only drain
  affordance is the then-fix — built against the live evidence, not
  speculatively.

**2.3 The staging + first-round choreography (the acts that remain):**
(a) A1 rail — WAL-safe backup of the real store; (b) staging —
`stageRepushFromTruth`'s exact UPDATE run once against the real
store's `bridge_day` at a zero-instance window (inert bookkeeping;
the staged days wait); (c) the `/Applications` refresh with the
un-paused build (no lockstep change — marker 6 both sides); (d) her
first launch runs the resumed round: pull (any pause-era plaintext
lands via the standing doctrine), then every staged live day
re-pushes as `e1:` — ending the satellite's legacy-plaintext era.
Honest scope note: sentinel rows for days with no live entry are
inert residue (nothing to push; a revived day re-pushes then), so
"zero-plaintext satellite" scopes to live days re-pushed from truth.

**2.4 THE SESSION DEPENDENCY — flagged, then RESOLVED BY HER RULING
(2026-08-16):** bridge rounds run only while the Mac's FRAGMENTS
session is connected, and the only sign-in door was
`connectFragmentsJournal` — the direct EMAIL+PASSWORD grant, which
touchpoint #1 retires. Her rulings, verbatim-faithful: *"this is not
a micro session anymore even, this is the everything gets done and is
working and ready for release from an email / fragments / account,
etc. session"* (THE SCOPE WIDENING — part B completes in-phase, the
phase's bar is release-readiness); *"there should not be some kind of
session dependency. the fragments session is working right now and
will be done sometime"* (the connect-now stopgap REJECTED — build the
proper door); *"can't we just wait to run the bridge tests til the
door back in exists?"* (YES — the round-trip verification waits for
the door + the Fragments side; nothing is lost meanwhile: staged days
wait inert, a dead session means visible refusals only).

**2.5 THE DELEGATED DOOR — BUILT (2026-08-16; the road back in; round
0x's "moves wholesale to the Fragments-batch era" landing exactly
there):** the 9c browser-flow machinery REBUILT from its final
pre-deletion state, pointed the other way — the bridge signs into the
FRAGMENTS project through the suite issuer's provider entry
(`custom:stargazing`, touchpoint #1). Pieces: `PKCE` (RFC 7636 S256)
restored into AuthSession + the delegated methods
(`authorizeURL(verifier:providerSlug:redirectURI:)` /
`handleCallback` / `exchangeCode` — NO provider-token capture: the
minted session IS the goal, unlike the retired 9c architecture);
`SignInFlow.swift` restored verbatim-with-lessons (all three 9c
lifecycle hazards + the XPC-queue SIGTRAP fix preserved);
`ProjectConfig.fragmentsSuiteProviderSlug = "stargazing"` +
`fragmentsBridgeRedirectURI = "variorum://auth-callback"`;
`AppServices.connectFragmentsJournalDelegated()` (cancelled browser
sheet = a decision, not an error); the account sheet's Fragments
section gains "Sign in with your Stargazing account" ABOVE the
password form (both doors through the transition; the password form
retires when the batch confirms — architect call, recorded). The
retirement walk AMENDED to its new truth
(`theRetiredFragmentsIssuerDirectionStaysOutWhileTheRebuiltFlowLives`:
SignInFlow.swift must EXIST; `custom:fragments` /
`signInWithFragments` / `provider_token` stay forbidden;
browser-flow machinery allowed ONLY in SignInFlow.swift — the walk
caught my own ProjectConfig comment naming the framework, reworded).
Four new AuthSessionTests pins (the RFC appendix-B vector · the
authorize-URL shape · callback-without-code refuses ·
exchange-mints-and-persists with exact request shape). **Counts:**
the two Mac auth suites 33/33 green; mobile target BUILD SUCCEEDED
(all six touched files are shared; SignInFlow's iOS anchor arm rides).
The `callbackWithoutCode` case taught both ErrorPresentation
switches honest lines. **NOT testable end-to-end until touchpoint #1
exists server-side** — the live exercise is the batch's, by design.

**NEW FRAGMENTS-SIDE ASKS (join the batch prompt — the door's two
config needs):** (i) allowlist `variorum://auth-callback` in the
FRAGMENTS project's auth Redirect URLs (the bridge's delegated
sign-in rides it); (ii) the provider entry's slug should be exactly
`stargazing` (the app's authorize URL says `custom:stargazing`) — if
it lands under another name, report it and the one app constant
follows.

**Pro plan — CONFIRMED PURCHASED (her mid-sitting report,
2026-08-16):** the Supabase project is on Pro — the 14c gate ruling
("the real backups that the pro level plan offers") executed. Nothing
app- or config-side keys on the plan tier; recorded as done.

You are the Fragments-side agent for the ONE-BATCH suite handoff (the
author carries this conversation; the Variorum side calls it Phase
14d). All work happens in `~/dev/fragments` and the Fragments Supabase
project. The ONE outside document in scope is the contract file the
author provides (`fragments-bridge-contract.md`, carried read-only
from the Variorum repo — read it, never edit it, and touch nothing
else outside your repo; contract changes route through the author,
never happen silently). READ IT IN FULL FIRST. The operative sections
are the "READ THIS FIRST (2026-08-04)" pointer, the EXECUTION MODEL
block, and the THREE TOUCHPOINT blocks with their concrete-facts
additions (touchpoint #2's format facts; touchpoint #3's entitlement
facts). Every coordinate in them is verified-final as of the Variorum
14c gate (2026-08-11); everything above those blocks in the
14a-horizon section is superseded history kept for the record. THE
JOB: execute all three touchpoints in ONE batch, in this order —
mid-batch breakage is fine (the author's standing latitude), finish
states matter. **Touchpoint #1 — provider swap + identity:** (1) add
the suite issuer as a trusted OIDC provider and route ALL sign-in
through the delegated PKCE flow. Issuer:
*[removed for publication]*
project URL; a custom domain was DECLINED at the 14c gate; write every
config against this URL. client_id
*[removed for publication]*
`client_secret_post`, registered redirect
*[removed for publication]*
client_secret the author supplies by hand — never commit it, never
echo it. (2) THE FIRST-SIGN-IN RULE (load-bearing): on her first
delegated sign-in, VERIFY the minted session's uid equals her existing
*[removed for publication]*
that account — and link deliberately via the admin API before
proceeding: every `journal_entries` row keys on the old uid. (3) Then
retire her email+password identity (single sign-in; no Fragments
password survives) and the native signup SURFACE — while the project's
global "allow new users to sign up" toggle stays ON (a first delegated
sign-in rides the create-account path). (4) Switch OFF Fragments' own
OAuth 2.1 Server (its old role as Variorum's issuer) and retire the
*[removed for publication]*
shipped at 14a and nothing depends on the old issuer. (5) Config
hygiene: remove any stargazing.tech URLs from Fragments' own auth
configuration — none belong there. (6) THE BRIDGE'S DELEGATED ROAD
(two config needs on YOUR project — the Variorum side built its door
at 14d and it rides your provider entry): add
`variorum://auth-callback` to the Fragments project's auth Redirect
URLs allow-list, and make the provider entry's slug exactly
`stargazing` (the Variorum app's authorize URL says
`custom:stargazing`) — if it must land under another name, report the
actual slug through the author so the app constant follows.
**Touchpoint #2 — journal-class
E2EE:** build the client end exactly to the concrete format facts
block: AES-256-GCM with per-value random 96-bit nonce; the `e1:`
prefix matched EXACTLY (the three-arm classification: `e1:` =
ciphertext, any other `e<ASCII digits>:` = unsupported future version
(refuse, never display), anything else = legacy plaintext); the
byte-exact AAD grammar `journal_entries:<date>:body:<key_id>`; the
vault unwrap chain (encryption passphrase → Argon2id with the ROW's
stored params → AES-KeyWrap unwrap master → unwrap the
journal_bridge class key; persist ONLY the class key + its id — never
master, never the corpus key); the TRIM and EMPTY-BODY-AS-DELETION
behaviors move CLIENT-side (post-decrypt/pre-encrypt); `replaced`
receipts discriminate by DECRYPTED content, never byte identity (they
fire more often under random nonces — expected); the stale-key
honesty rule (key-id mismatch against the vault row speaks "keys were
replaced; re-enroll", never a generic error). Suite terminology
ruling: nothing is ever called "Passkey". `journal_entries` schema and
key semantics stay FROZEN; nothing Variorum-specific enters Fragments.
**Touchpoint #3 — the entitlement check:** read the `entitlement`
table on the suite project per its facts block — feature exactly
`hosted_sync`; entitled = a row exists AND (`expires_at` IS NULL OR in
the future); READ-ONLY (writes are service-role-only by design);
degrade QUIET on failed reads; what gating means in Fragments is yours
to shape. CONTEXT: the Variorum bridge is PAUSED and resumes
Variorum-side after this batch — her historical journal days then
re-arrive as `e1:` ciphertext via a staged re-push from Variorum truth
(your side never migrates rows; expect legacy plaintext in
`journal_entries` until that lands). REPORT BACK through the author,
explicitly: (a) the uid-verification outcome; (b) old issuer OFF + old
client retired; (c) the E2EE client's shipped state, piece by piece;
(d) the entitlement read returning entitled under her account; (e)
anything that needs a contract change — through her, never silently.

## The stargazing.tech site-agent prompt (paste-ready — Step 0's
## branded-link half; she tasks that repo's own agent with it)

Build the auth-email landing flow on stargazing.tech for the
Stargazing suite (the Variorum/Fragments account system). The suite's
*[removed for publication]*
its PUBLISHABLE key, public by design:
`sb_publishable_X-TQvz2RDj4cnCABZao4ww_WWGdSTwp`). The
auth emails will link to
`https://stargazing.tech/auth/confirm?token_hash=<hash>&type=<type>`
(Supabase's documented server-side PKCE pattern), so build: (1) an
`/auth/confirm` handler that reads `token_hash` + `type` from the
query and calls `supabase.auth.verifyOtp({ token_hash, type })`
against the project — on success for `type=signup` or
`type=email_change`, show a plain "email confirmed — you can return to
the app" page; on failure, a plain honest error page (expired/used
link, with "request a new one from the app"). (2) For
`type=recovery`, verifyOtp mints a session — then show a
choose-new-password form that calls `auth.updateUser({ password })`
with that session, confirming success plainly. IMPORTANT WORDING RULE
(the suite's E2EE story): the recovery page must say it resets the
ACCOUNT password (sign-in) and never touches the user's encryption
passphrase or recovery phrase — those protect their writing and only
they hold them. No marketing voice anywhere; plain words; name the
suite once ("Stargazing — one login for Variorum and Fragments").
Report back the exact deployed route URL(s) so the Variorum side can
add them to the project's redirect allowlist and set the Site URL
before the email templates flip to the token_hash form.
