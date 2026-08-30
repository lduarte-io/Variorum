# Phase 13p Handoff — Whole-Store Encryption (closed 2026-08-30)

*Self-contained per the standing rule: everything here is answerable
from the repo — the exhaustive record is
`notes/plans/phase-13p-note-protection.md`'s RUN RECORD (kickoff
sitting → four batches → the three-round ladder → closeout), the
ratify bundle is QUESTIONS #81, and the spike's numbers are
`notes/plans/phase-13p-spike-memo.md`.*

---

## YOUR CHECKLIST, in order

1. **Nothing is needed for daily use.** Your Mac app is running on your
   ENCRYPTED store — it migrated overnight at your authorization
   (< 1 s, on the exact build that was SIGKILL-drilled on a byte-copy
   of your store), and under the Standard/Auto default you will never
   feel it. Your writing is where you left it; backups are ciphertext
   now.
2. **DONE 2026-08-30 — the Mac signing gap (#81(a)) is CLOSED.** You registered this Mac in your developer account; the entitlement, profiles, both builds, the `/Applications` refresh and the tightened regression pin all landed the same afternoon. Biometric mode and iCloud escrow can now land on the Mac, and 14b's vault biometric gate is unblocked with them. One consequence to know: the ladder's R3-m1 escrow-reconcile interleave was masked by the old fast-fail and is now real — it has its own KnownIssues row at the v1-readiness owner, unfixed deliberately (it needs a red-on-old pin of an interleave, which is a small batch, not a drive-by). Original entry: **the Mac signing gap.** The app's
   signing carries no data-protection-keychain identity, so BIOMETRIC
   mode's gated item and the iCloud ESCROW copy cannot land on the
   Mac yet (every door refuses honestly; passphrase mode and all
   recovery legs work; iOS is unaffected). Fix = an
   entitlements/provisioning change in Xcode, likely minutes — or
   leave it with 13r (its KnownIssues row is parked there, with the
   ladder's R3-m1 escrow-interleave rider landing alongside whenever
   signing does). This same gap likely explains 14b's vault biometric
   gate quietly refusing on the Mac all along.
3. **The install gate (#81(f)) — EXECUTED 2026-08-30 at your word,
   after you quit the app.** `/Applications/Variorum.app` was rebuilt
   Release from the FINAL tree (commit `5123580`, 14:27) and installed
   at 14:33 — the installed binary's sha256 matches the build product
   exactly, and it is signed at that time. The phone was re-installed
   in the same run (`VariorumMobile 1.0 (1)`, confirmed on device). A
   fresh pre-refresh backup was taken first per the A1 rail and is
   CIPHERTEXT, which independently confirms your live store is
   encrypted. **The one piece still owed is the field-guide re-seed,
   and it is an in-app act:** `Help ▸ Restore Tutorial…` in the
   refreshed build, which replaces the tutorial book with the current
   lessons (the new privacy chapter). Press it whenever — nothing else
   waits on it.
4. **Your phone.** First open migrates its store (same drilled road,
   instant). Then the fun one: Settings → Protection → try BIOMETRIC
   mode — Face ID is expected to WORK on the phone (no signing gap
   there), the first live look at the gate. The on-device perf leg
   rides the same session (expectation: indistinguishable — hardware
   AES).
5. **Your recovery legs, one visit.** Today your store rides this
   Mac's Keychain (plus sync's server copy of your corpus). One visit
   to Settings → Protection lands the passphrase leg (the SAME one
   secret as your sync vault — the set-screen extends it, never a
   second secret) and shows your recovery phrase beside it.
6. **Carry the two briefs**: the Fragments carry-item (tail of
   `notes/fragments-bridge-contract.md`) and
   `notes/stargazing-privacy-policy-brief-13p.md` (the three-tier
   suite story the final policy text builds from).
7. **Taste list (#81(b)), overrule at will**: the phone protection
   screen's text-forward chrome · the nudge at the top of the phone's
   shell · the pocket guide's single privacy lesson · the cadence
   numbers (30-day reminder / ≥24 h nudge / 14-day snooze).
8. **The kept plaintext backups (#81(g))**: two pre-migration
   byte-copies of your real store remain at
   `~/dev/scratch-13p-spike/batch1/pre-drill-backup/` and
   `~/dev/scratch-13p-spike/install-backup-20260830T131907Z/`
   (everything derived was swept at the closeout; the path of the
   first was corrected 2026-08-30 — it sits under `batch1/`). Both
   were verified plaintext-headed at the post-closeout sweep. A third
   folder now sits beside them —
   `pre-reseed-backup-20260830T202941Z/`, tonight's pre-refresh copy —
   which is CIPHERTEXT and can go with them or stay as a spare. Once
   you're satisfied the encrypted world is good, say the word and they
   go.
9. **Kick off 13y when ready** — plan authored:
   `notes/plans/phase-13y-per-tenant-seq.md` (all `Sync/` + server
   SQL, the standing Fable rider; marker 7→8 and the `11_` DDL number
   13p left unclaimed; your deploy window per the 13j choreography).

## What shipped, and why it is shaped this way

**The store is encrypted at rest as one unit, universally** — SQLCipher
(Community) under your GRDB fork (`github.com/lduarte-io/GRDB.swift`,
tag `v7.11.1+sqlcipher.1`), keyed by a random 256-bit store key through
the raw-key pragma (~1 ms opens; the 165 ms KDF trap pinned at the call
site). **Per-note locks do not exist — your R13p-16 ruling**: inside an
unlocked app they'd be a curtain, not a boundary, and shipping the
lock-on-open theater your advertising will expose would be anti-brand.
The at-open modes ARE the gate story: Auto (silent, the default) ·
Biometric (passphrase fallback, never the login password) ·
Passphrase-every-open — with the locked lobby (nothing runs before
unlock), re-lock dials, and Lock Now in the demanded modes. ONE secret
ever: your 14b passphrase + BIP-39 phrase wrap the store key; the
wraps live in a sidecar envelope that rides every backup folder, so a
new-machine restore by passphrase is real (13x inherits the full
adoption drill, named on its row). Exactly ONE plaintext escape
survives: the `.md` export, now OFF by default (your #75 rider).
Backups are ciphertext under the one-commit rule; `secure_delete`
stays ON (spike-measured: no breach — it never came back to you). The
phone got its FULL face set inside the phase (PL-15 — the phone as a
first-class birthplace of stores, your mobile-only rider), and the
tutorial teaches the privacy chapter to your loss-math instruction on
both guides.

## The security story in plain words (the honest boundaries)

- **Protected**: the store file, its WAL, every app-made backup — a
  stolen drive or copied folder reads as noise. Sync stays E2EE as
  before. Search will index everything because the store itself is the
  protection (13o's handed input).
- **Not protected, said out loud**: an app that is open and unlocked in
  front of someone (the R13p-16 honesty); pre-encryption plaintext
  backups until they age out (your R13p-15 ruling), including device
  backups made before today; the opt-in `.md` export if you enable it.

## The numbers

Batches 0→1→2→4 (Batch 3 dissolved by R13p-16) + a three-round
all-Fable ladder: **round 1** 14 findings (3 MAJOR — the runbook's
stale plaintext claim, the phone's missing lock teardown, the keyed
restore-drill gap + the sidecar unlock road), **round 2** every fix
held + 5 more (1 MAJOR — the phone's four one-secret hooks, now wired
through the same shared factory as the Mac), **round 3** nothing above
MINOR, all held; ZERO disputes anywhere. Finals: core **1453/154** ·
Mac **1843/312** (green except the known intermittent latency pin —
red-under-load at close, adjudicated pre-existing by paired isolated
runs; its KnownIssues row gains the live-real-app covariate) · mobile
**513/86** (2 standing known issues) · spine **71/10**. Marker **7**;
**ZERO schema, ZERO lockstep, ZERO `Sources/VariorumCore/Sync/` lines
all phase**, diff-verified at every gate.

## Deferred, every item owned

The Mac signing gap → **13r** (+ R3-m1 riding) · the one-secret
phrase-transit corner → **v1 release readiness** · the latency-pin
calibration → **12** · the new-machine adoption drill → **13x** (named
inheritance). PROVISIONALs: eighteen across the batches, all
adjudicated with reasons in the run record; none blocks anything.
