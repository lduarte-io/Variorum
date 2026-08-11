# Phase 14c — Author Handoff (Multi-tenant hardening & the paid tier; closed 2026-08-11)

> Self-contained per the standing rule: if a question about this phase
> could only be answered by a session's context, the docs are wrong —
> fix the docs. The BINDING record is
> `notes/plans/phase-14c-multi-tenant.md` (the design-sitting rounds
> 1–9 · THE DESIGN · batch records 1–3 · the review ladder + the
> DEDICATED isolation round · the "GATE HALF — execution record"
> section with every live act). The master plan's closeout log has the
> one-paragraph summary.

## YOUR CHECKLIST (everything left that is yours)

1. **Open 14d at your word** — the paste-ready plan is
   `notes/plans/phase-14d-fragments-batch.md` (kickoff at top). It is a
   micro phase and it now carries FOUR things deferred out of 14c
   besides the Fragments handoff: **the signup flip**, **stranger
   validation**, **the phone re-onboard**, and **the branded-email
   setup** (via the free template road — see item 4). Its
   FILL-AT-GATE fields are all completed; the confirmed issuer URL is
   the raw project URL (no custom domain — see item 4).
*[removed for publication]*
   *[removed for publication]*
   *[removed for publication]*
   *[removed for publication]*
   *[removed for publication]*
   *[removed for publication]*
3. **Re-onboard your PHONE against the reborn mirror before relying on
   phone↔Mac sync.** Today's rebuild reset the mirror (new tables, the
   changefeed counter restarted), so your phone's saved sync position is
   stale against it — the clean fix is a re-onboard (fresh store, enroll
   by passphrase, pull to head), exactly as at the 14b gate. Two honest
   unknowns for the mobile session to confirm, not me: (a) whether the
   merged-tree Release build the mobile session pushed to your phone
   today actually completed installing (it needed the phone unlocked to
   mount) — if it did, your phone is already a lockstep-6 client and
   won't refuse on version; if it didn't, its older build will refuse
   until updated; (b) either way the re-onboard is the clean path.
   **Until the phone is re-onboarded, don't rely on phone↔Mac sync** —
   your phone's writing stays safe *on the phone* but may not propagate.
   This pairs with the mobile/TestFlight run-up and is a 14d act.
*[removed for publication]*
   *[removed for publication]*
   auth emails without the separate add-on. It can: a rewritten email
   template pointing the link at `stargazing.tech` + a small
   `/auth/confirm` handler on your site (the stargazing.tech agent
   builds it) gives every link your users SEE your brand, for free. The
   *[removed for publication]*
   never see (the API hostname, OAuth callbacks — and maybe not even the
   token issuer). So the branded-email work rides 14d's SMTP step via
   the free road, and the issuer just stays the raw Supabase project URL.
5. **The doors' copy is take-as-shipped for now** (your call). When you
   want your taste pass, the three to eyeball are the Delete-account,
   Replace-keys, and Sign-up-footnote strings in
   `App/Variorum/Shared/AuthViews.swift` / `EncryptionViews.swift` —
   the load-bearing sentences are byte-pinned; the surrounding prose is
   yours to redline. Nothing blocks on it.
6. **Your Variorum-usage pause is yours to end or keep.** It held
   through 14c (Round 1). Your corpus now syncs multi-tenant and
   E2EE under your keys; nothing technical waits on the pause either way
   — but note item 3 about the phone.
*[removed for publication]*
   *[removed for publication]*
   *[removed for publication]*
   *[removed for publication]*
   *[removed for publication]*
   *[removed for publication]*
   either.

## What shipped, in one breath

Your mirror is reborn multi-tenant: the 18 data tables recreated so
another account's rows are structurally UNADDRESSABLE (composite
`(owner_id, id)` primary keys), with TWO independent enforcement layers
— forced row-level security AND explicit tenant-scoped guards in the
sync functions, and at the gate a live repair (a dedicated non-bypass
database role owns the three data functions) made that second layer
genuinely bind. A stranger's account can't read, write, overwrite, or
delete any of your rows through any door — proven both in the two-user
convergence harness and LIVE against a real second account we
provisioned and then deleted: it saw zero of your rows, its writes
couldn't touch yours, a row it pushed at one of your exact ids landed
in its OWN partition with your row byte-untouched, and its
account-deletion removed only its own footprint while your 186 notes
sat intact. Your corpus was repushed from local truth in one round —
7,278 rows, exact counts, zero plaintext, owner uniform. The paid tier's
machinery is deployed and gated (entitlement on the account, both apps
read it), and the two account doors — replace-your-keys and
delete-your-account (the local copy always survives) — are built and,
for deletion, verified end to end.

## What DIDN'T ship (deferred to 14d, by your ruling — none of it is
## needed until real strangers arrive)

The signup door is still OFF; no stranger has been onboarded through the
in-app flow; your phone hasn't re-onboarded; and there is no branded
auth-email yet. All four ride 14d, where the SMTP setup and the
stargazing.tech site handler that make the stranger email experience
real will exist. The isolation and the tier — the parts that had to be
right before anyone else could ever sign up — are done and proven.

## The state of the world (verify, don't trust)

- **Tip:** this closeout's commits on `main`, pushed. The gate added
  only SQL/test/doc changes (three new AuthRLSDDLTests pins for the two
  adjudicated-sweep fixes + the BYPASSRLS repair); no app/core feature
  code, engine inland zero-diff all phase.
- **The mirror:** lockstep marker 6; your corpus live and multi-tenant;
  *[removed for publication]*
  non-expiring). Signups OFF.
- **Live artifacts executed at the gate** (all committed, registry-clean):
  `09_phase14c_multitenant.sql` (the rebuild) ·
  `maintenance/14c-gate-grant-tidy.sql` (the service_role tidy) ·
  `maintenance/14c-gate-definer-owner.sql` (the BYPASSRLS repair;
  includes the one-line rollback in its header) ·
  `maintenance/14c-post-deploy-grant-sweep.sql` (the read-only verifier,
  all-OK/INFO). One live grant (`grant authenticated to
  variorum_definer`) was run by your hand in the SQL editor because the
  harness declined it for me — it's recorded in the definer-owner
  artifact's header.
- **Backups from the gate:** `variorum-backup-2026-08-11-024144.sqlite`
  (the pre-deploy snapshot, integrity ok) + a 20-file mirror export,
  both in your store's `Backups/` home.
- **Counts:** core 1201/127 · Mac 1240/219 (the standing
  TakePaneMeasureTests tripwire the one allowed red, BY IDENTITY) ·
  mobile 175/26 · spine 51/7.

## Findings and their dispositions (all recorded, none open against you
## except where noted)

- **I-1 (a real privacy call, ruled by you):** the shared global sync
  counter lets one account coarsely infer how much others wrote
  (volume/timing — never content, never who). You accepted-and-recorded
  it into the E2EE disclosure list ("i honestly don't think that matters
  that much"). Closing the channel entirely (per-tenant counters) is a
  future engine phase, not built.
- **The gate found and fixed live:** a leftover service_role grant on
  the two account doors (tidied — zero reach, posture only); a
  platform function auto-enabling RLS (benign, recorded); and the big
  one — the hosted database owner role has BYPASSRLS, which would have
  left your ruled two-layer net one-layered, so at your go the three
  data functions were re-owned to a non-bypass role. All verified.
- **Sustained provisionals** (no action owed): a vault-less account
  deletes with typed confirmation + session alone; the subscription
  note is best-effort; the entitlement shape is final. B1-1 (a test
  harness latitude) was retired with reasons.

## Where everything lives

- Binding record: `notes/plans/phase-14c-multi-tenant.md`
- 14d plan: `notes/plans/phase-14d-fragments-batch.md`
- SMTP runbook (14d executes it): `notes/plans/phase-14c-smtp-runbook.md`
- The site-agent contract (the checkout): the "stargazing.tech
  checkout — contract facts" block in the binding record
- Fragments touchpoints: `notes/fragments-bridge-contract.md`
