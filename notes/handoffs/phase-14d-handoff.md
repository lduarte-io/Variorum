# Phase 14d — author handoff (closed 2026-08-16)

## Your checklist (everything that involves you, in priority order)

1. **Nothing is required to keep working.** Launch Variorum and write.
   Sync, the journal bridge (both directions, encrypted), your one
   Stargazing sign-in, and the branded account emails are all live and
   verified. *(One tiny carry: the installed build is the 20:13Z
   unification build — the closeout's REVIEW-FIX pass (nicer
   browser-flow error wording; comment truths; nothing behavioral you
   have) missed its install window because the app was running at
   close. Any session refreshes it in a minute next time the app is
   closed: `xcodebuild -scheme Variorum -configuration Release build`
   + ditto to `/Applications` — the standing one-liner.)*
2. **The stranger-validation walk — yours, on your own time** (your
   ruling: a residual; the phase closed without it). The step-by-step
   instructions live in `notes/plans/phase-14d-fragments-batch.md` →
   "Residuals" (fresh plus-addressed email → branded confirm link →
   sign in → three checks → encryption setup as a newcomer → optional
   phone first-run → exit via the stranger account's own Delete
   Account door). Report only surprises, to a polish session. Note:
   your click-through of a confirmation link is the FIRST full
   `verifyOtp` exercise of the branded road — the dispatch was
   probe-verified, the click was not; don't skip step 2.
3. **TestFlight is unblocked** (your standing ruling's condition —
   the 14-family — is complete). Invites whenever you're ready; the
   email rate limit is 30/hr, fine for invite volume.
4. **Optional, tracked, no urgency:**
   - **Secret-key rotation** — an `sb_secret_…` key was echoed into a
     local transcript during the phase (recorded honestly in the plan);
     rotate at dashboard → Settings → API keys, then update
     `.env.supabase.local`, or decline.
   *[removed for publication]*
     *[removed for publication]*
     *[removed for publication]*
     *[removed for publication]*
   - **"Bridge now" relabel** — say the word ("Sync journal now" or
     fold into one button) and it's a one-liner.
   - **The bridge auto-connect** — your "why log in twice" question,
     answered and DESIGNED (the API-driven consent road; sketch in the
     plan's Residuals): a polish session builds it at your word; until
     then Connect is one browser hop with no credential re-entry when
     the browser holds a session.
5. **Next phase at your word**, as always: the 13 family (13e · 13i ·
   13j · 13l · 13m), mobile Stage E / internal TestFlight, or the
   unslotted rows.

## What shipped and why it's shaped that way

- **SMTP + branded auth emails (Step 0):** Resend (all-TXT DNS — your
  hand), config via the Management API, your ratified humanized
  template copy, then the branded `token_hash` flip only AFTER the
  stargazing.tech `/auth/confirm` handler shipped (links would have
  404'd otherwise — the sequencing rule in the runbook). The deployed
  config is the copy's source of truth.
- **The bridge un-pause + resumption:** production wires the live
  Keychain key provider (the 14b structural pause's deliberate end);
  your journal history re-pushed encrypted (the staged re-push behind
  a verified backup, drained on your first launch, corroborated
  server-side by the Fragments agent). The resumption ran the ordinary
  pull→push round — the feared old-key-refusal case provably cannot
  exist today (the bridge never pushed ciphertext before the pause),
  so no special drain machinery was built.
- **The delegated door:** the 9c browser-flow machinery, rebuilt from
  its final (hazard-fixed) state and pointed the other way — the
  bridge signs into the Fragments project through your Stargazing
  account (`custom:stargazing`). This is the road that outlives the
  retired password: your ruling ("there should not be some kind of
  session dependency") made it this phase's build.
- **The Fragments batch (you carried it) — closed:** uid preserved
  *[removed for publication]*
  journal E2EE live both ends, entitlement quiet. ONE STARGAZING
  ACCOUNT — the docs say so everywhere now (SyncSpec §2's completion
  clause; the contract file's closing addendum; the account sheet's
  own copy).
- **Signups OPEN:** safe because 14c's isolation + the entitlement
  gate are the guard (the old signups-OFF banner in ProjectConfig is
  rewritten so no future session re-closes the door on stale
  reasoning). A live stranger-shaped signup probe returned exactly
  the right shape; the probe account was purged.
- **The account-sheet unification (your ruling):** one Stargazing
  presentation; the Fragments row is a CONNECTION of the same account
  ("Journal bridge"), not a second sign-in; the dead password form is
  gone.

## The cold review (one round, per your cast ruling)

2 MAJOR / 4 MINOR / 2 NIT — all agreed, all landed same-day; a strong
clean bill (the un-pause, arm (ii) verified against code, PKCE pins,
scope discipline, secrets hygiene). Both MAJORs were documentation:
the real-store acts' missing execution record (now written, §2.3) and
the stale signups-OFF banner (rewritten). The one code-behavior fix —
browser-flow failures spoke a raw enum face — landed with its pin
proven red-on-old live. Full dispositions: the plan's cold-review
section.

## Counts and records

Mac auth suites 33/33 · core bridge suites 85/9 · mobile builds clean
(all re-run independently by the reviewer). Zero core-logic, zero
`Sync/`, zero schema changes all phase — the full-suite baselines
stand (core 1216/128 · Mac 1246/220 tripwire-only · mobile 314/60).
The BINDING record: `notes/plans/phase-14d-fragments-batch.md` (the
whole run — sitting rulings verbatim, execution records, the
Fragments batch's closing report, review dispositions, residuals).
Canon deltas: AppSpec §14 (the 14d delta; 14c's rolled to the
archive), SyncSpec §2 (the single-account completion clause), the
contract file's addendum, KnownIssues (rotation re-owned to v1
release readiness), MobileSoul PL-8 closed + PL-9 written.
