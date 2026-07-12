# Phase 9c handoff — auth alignment (implementation complete; YOUR gates pending)

> **SAT AND PASSED 2026-07-11 — THE PHASE IS CLOSED.** All seven gates green; the
> per-gate record, the sitting's seven findings, and four residuals live in the
> phase plan's sitting section. Still live from this checklist: item 4 (the
> stargazing consent page — now also the sitting's RESIDUAL 1: sign-ins ride an
> interim LAN-served page until it ships), item 6 (the 15.7 deploy ping), and the
> combined feel pass in item 7.

**Status in one line:** everything buildable is built, reviewed (two cold rounds,
ladder closed), and green — but **the phase is NOT closed until you run the Step 6
sitting**, whose complete script is **`notes/handoffs/phase-09c-step6-runbook.md`**
(this checklist's executable arm). This document is self-contained per the handoff
rule: any question about the phase should be answerable from here, the runbook, and
the phase plan's closeout (`notes/plans/phase-09c-auth-alignment.md`).

## What you must do next (the checklist)

1. **[x] Confirm "Allow new users to sign up" is OFF** on the Variorum project
   (asked of you at review round 1 — one click; the WHY is the review's BLOCKER,
   explained below; the runbook's Gate 4 proves it either way).
2. **[x] Fill the two publishable keys** in `App/Variorum/Shared/ProjectConfig.swift`
   (from your untracked env files), build, commit — runbook Gate 0.2. They are
   committable BY DESIGN once item 1 holds; the sign-in surface stays dormant until
   filled.
3. **[x] Run the Step 6 sitting** with the coordinator — the runbook end to end:
   backup → Mac sign-in (backfill runs itself) → totality checks → phone sign-in →
   the `04_auth_rls.sql` cutover + probes → device rounds → the Fragments-journal
   connection + the 9b real-Fragments pass. Budget ~an hour; every gate has expected
   outputs and a recovery path, including a full rollback.
   *(Already done early, skip when you get there: Gate 0.3 — `variorum://auth-callback`
   allow-listed, the spike's localhost redirect removed.)*
4. **[ ] Hand the consent-page spec to your stargazing.tech site agent** —
   `notes/fragments-consent-page-spec.md` (the permanent login/consent page; the
   spike's localhost page works for the sitting meanwhile). After it ships, point the
   Fragments OAuth Server page's Site URL/Authorization Path at it — and remember
   that page's save button (it silently discarded values twice on 2026-07-10).
5. **[x] The ratify walk at the checkpoint** is tiny this time: QUESTIONS #16 (the
   bridge's Fragments session = your direct email+password sign-in) — you already
   ratified it in-session on 2026-07-10; the walk just records it.
6. **[x] When Fragments' 15.7 deploy ping arrives** (their replaced-body receipt),
   bring it back here: a named follow-up pins the fake server to the final shape and
   adds the consumption path under the three discrimination rules (contract ask 13).
   Nothing is assumed until the ping. **DONE 2026-07-11 — the ping arrived the same
   day the phase closed; the deployed SQL was verified (author-authorized read-only
   look at their repo), the fake server pinned, and the consumption path shipped
   under the three rules, then hardened by a same-day Fable cold review (core
   547/62). Full record: the contract's "Ask 13 CLOSED" addendum.**
7. **[x] After the sitting passes:** daily use is unblocked (your 2026-07-07
   deferral condition — "9b AND 9c done" — is met), the week-one dump-compare ritual
   begins, and the Phase 7/9 **combined feel pass** is still owed whenever you want
   to run it.

## What shipped, and why it is shaped this way

- **One account, for real (QUESTIONS #9):** you sign into Variorum **with your
  Fragments account** via route A — Variorum's project trusts Fragments' project as
  a custom OIDC provider. This was undocumented as a pairing; Step 0 proved it live
  with your real sign-in on 2026-07-10 (the decision memo, with the redacted session
  evidence, is in the phase plan's closeout). Your Variorum identity (`owner_id`,
  RLS) is the Variorum project's own `auth.uid()` — stable forever, never fused to
  Fragments' namespace, so Phase 14 can add other users without re-keying your rows.
- **The key is demoted:** after the sitting's cutover, the API key in the app
  identifies the project and grants NOTHING — every sync call requires your
  authenticated session (`04_auth_rls.sql`: RLS on all 13 mirror tables, anon
  execute revoked, per-user owner guards on the five owner-carrying tables).
  **The one precondition (the review's BLOCKER, and why checklist item 1 exists):**
  the eight tables without an owner column — including every variant and commit,
  i.e. your prose — are served to ANY authenticated user in this single-user phase,
  and a default Supabase project lets anyone holding the publishable key CREATE an
  account. Signups-off closes that door (and the first-time-OIDC door) while
  existing users — you — keep signing in. Phase 14 replaces this procedural guard
  with real per-user isolation.
- **The paste-in is gone:** no more URL/key pasting, ever. Sign-in drives
  everything: signing in runs the owner backfill (idempotent, every launch), then
  composes sync; signing out tears it down; tokens refresh themselves (single-flight,
  once per 401, never a loop); a signed-out or expired state refuses rounds cleanly —
  outbox intact, cursor unmoved, visible status. The old Keychain item is deleted at
  your first sign-in.
- **The Fragments journal connection (bridge):** a second, separate session — your
  Fragments email+password entered ONCE in the Account sheet; only the session
  persists, never the password. You ratified this shape (#16 (c)) because it is the
  one mechanism with zero unverified semantics: it is exactly the session class the
  Fragments app itself uses. The identity story is unchanged — one account; this is
  a second *session* of it. (The delegated sign-in also captures Fragments
  provider tokens; they are stored unused as the upgrade evidence if you ever want
  strict one-touch — that upgrade would need the real-pass verification first.)
- **The A4 fence survived the sign-in era:** a dev-store session never syncs, never
  bridges, never runs adoption — even if it launches already signed in via the
  shared Keychain (pinned by test).

## Findings + dispositions, in brief (full detail: the plan's two review-round sections)

- **Round 1 (1 BLOCKER / 1 MAJOR / 3 MINOR / 4 NIT, all agreed + fixed):** the
  BLOCKER was the signup door above — the phase's central claim was falsifiable
  under deployed defaults, and the runbook's probes would have green-lit it; fixed
  at every carrier (Gate 0 toggle + Gate 4 probes incl. a live probe of the
  OIDC-first-sign-in door with a throwaway user, the 04 header precondition, pinned).
  The MAJOR: three lifecycle hazards in the browser-sheet runner (unretained
  session, a leak-the-continuation path that wedged the sign-in surface, a
  scene-less iOS anchor) — all fixed. MINORs: a sign-out racing an in-flight token
  refresh could silently resurrect the session (fixed + red-on-old pinned); the
  bridge transport lacked the 401 refresh door the sync transport got (fixed +
  pinned); the wiring tests fired real network at your production URL (fixed with
  injectable transport factories). NITs: adoption failure now holds sync composition
  visibly; clearer mirror error texts; two stale doc notes; a spec contradiction
  reconciled.
- **Round 2 (2 MINOR / 2 NIT, zero new HIGH — ladder closed):** the runbook's
  recovery for one post-cutover error was wrong (only a server-side repair works —
  corrected, with the exact SQL); the round-1 "one-flight guard" claim didn't hold
  as composed (fixed: stored flow + busy entry belts); single-flight refresh waiters
  now re-check sign-in state; one stale header updated.

## Test counts (the Phase 10 baselines once your gates pass)

Core `swift test` **547 green in 62 suites** · Mac app **254 green in 45 suites** ·
mobile **11 green in 4 suites**. *(Core was 540 at the ladder's close; the ask-13
receipt consumption and its same-day cold-review round added the rest — 2026-07-11.)*

## Where everything lives

- The sitting's script: `notes/handoffs/phase-09c-step6-runbook.md`
- The phase record (Step 0 memo, field notes, dispositions, residuals):
  `notes/plans/phase-09c-auth-alignment.md`
- The deployed-at-Gate-4 SQL: `Server/supabase/04_auth_rls.sql`
- The consent-page spec for your site agent: `notes/fragments-consent-page-spec.md`
- The throwaway spike harness (evidence + the sitting's interim consent page):
  `Spikes/AuthPairingSpike/`
- The Phase 10 plan (authored at this closeout, per the front-loaded rule):
  `notes/plans/phase-10-readings-and-first-views.md`
