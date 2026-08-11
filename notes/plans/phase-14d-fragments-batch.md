# Phase 14d — The Fragments batch & bridge resumption — micro-plan

> **Status: DRAFT — authored in 14c's build-half session (2026-08-05,
> the Round-9 assignment: the seat holding the batch-2/3 code context
> writes this plan; the 14c GATE session finalizes the FILL-AT-GATE
> fields at its closeout; the phase opens at the author's word AFTER
> 14c closes). Micro phase by her ruling: 14c closes without waiting
> on Fragments — this phase gates on nothing but the Fragments
> conversation itself.**

## Kickoff message (paste-ready once 14c's closeout finalizes this file)

You are running Variorum Phase 14d (repo ~/dev/variorum, branch main)
— a MICRO phase, likely a single author-attended session (cast decided
at this kickoff as always; the 9d shape — author present, no
coordinator relay — fits its size). Its whole scope: the ONE-BATCH
Fragments handoff the author carries, plus Variorum's own small
resumption acts. READ FIRST: (1) this file in full; (2) the master
plan's 14d row; (3) `notes/fragments-bridge-contract.md` — the
EXECUTION MODEL + its 2026-08-04 amendment + ALL THREE touchpoint
blocks WITH their concrete-facts additions (this is the brief SHE
carries; treat every FILL-AT-GATE field as verified-final before her
conversation runs); (4) the 14c plan's Batch 2 record (the dormant
machinery + THE TRACED CORNER) and Round 6/7 rulings; (5) the SMTP
runbook `notes/plans/phase-14c-smtp-runbook.md`; (6)
`notes/sync-postmortem-fragments.md` before any `Sources/VariorumCore/
Sync/` or bridge-engine line. STANDING: sessions never touch
`~/dev/fragments` or the Fragments Supabase project — the contract
file is the channel, carried by her; the Variorum mirror rails
(announced acts, committed artifacts, her go, the A1 rail) bind.

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
