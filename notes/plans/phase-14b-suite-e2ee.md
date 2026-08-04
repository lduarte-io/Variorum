# Phase 14b — Suite E2EE — kickoff draft

> **Status: DRAFT — authored at 14a's gate (2026-08-04) per the closeout ritual.**
> 14b opens AT THE AUTHOR'S WORD with its design sitting; nothing builds before
> that sitting's rulings land. The 14-family rule binds: each phase authors its
> real plan at its own kickoff sitting ("some design choices will have to be
> assessed and done in that moment") — this file is the sitting's AGENDA plus
> what already binds, and becomes the plan file when the sitting runs.
> **Cast:** decided at kickoff as always; her recorded lean (2026-08-02, on the
> master-plan row, her words): *"seems like the sort of thing i might want to
> run with an all fable cast"* — coherent with the standing Sync/ rider, which
> routes the engine surgery to Fable regardless.

## Kickoff message (paste-ready for the sitting session)

You are the architect for Variorum Phase 14b (repo ~/dev/variorum, branch
main), under `/architect-phase` discipline (the skill file governs; CLAUDE.md
binds). The phase opens with the AUTHOR-ATTENDED design sitting this file
stages. READ FIRST, in order: (1) this file in full — the agenda, what binds,
and the one-way-door list; (2) `notes/plans/phase-14a-suite-identity.md`'s
RULED STATE banner + the ladder record, and `notes/handoffs/phase-14a-handoff.md`
*[removed for publication]*
direction + the dated wrap-secret addendum); (4) the master plan's 14b/14c
rows; (5) `notes/fragments-bridge-contract.md`'s READ-THIS-FIRST pointer,
EXECUTION MODEL, and TOUCHPOINT #2 block; (6) `notes/sync-postmortem-fragments.md`
before ANY `Sources/VariorumCore/Sync/` line (the standing rule).
STANDING: the author's Variorum-usage PAUSE holds until Phase 14 completes —
the store and mirror are quiescent; the mirror is LIVE production (announced
changes only, committed artifacts, her explicit go, the A1 rail before its
migration); the signups-off toggle stays untouched; SyncSpec §12 governs the
vault's schema event. Bring the sitting questions below as question-tool
batches (≤4), record her rulings verbatim-faithful in this file same-turn,
then author the execution plan from them.

## What BINDS (settled rulings — never re-opened at the sitting)

- **The wrap secret is a SEPARATE encryption passphrase, never the account
  password** (release-strategy §4's dated addendum, 2026-08-03 — four grounds
  recorded there). 14a consequence already banked: stock Supabase auth
  suffices; no auth secret doubles as key material.
- **Fragments' E2EE is journal-class ONLY** (2026-07-30, fifth round): the
  rest of Fragments stays server-readable BY DESIGN — its insights are the
  product. The Fragments END is DESIGNED at 14b and EXECUTED in the one
  batched handoff at 14c's end (the 14b row's consistency note).
- **The hosted tier ships E2EE FROM BIRTH** (2026-07-30, §4): mandatory,
  Obsidian-Sync-shaped — independent random data key, wrapped by
  passphrase-derived key + recovery phrase, device-linking enrollment, one
  honest setup warning (unrecoverable-by-design is the warning's whole
  content — the round-0k envelope explanation).
- **The vault lives on the ACCOUNT** — under the 0h ruling that is the
  Variorum project; P-ii is VERIFIED (14a spike, round 0r: an
  OAuth-server-issued token IS an authenticated PostgREST user; RLS'd vault
  tables key on plain `auth.uid()`, no claim gymnastics). The 14c entitlement
  reads the same way.
- **The bridge PAUSES from 14b's encryption until the one-batch Fragments
  handoff** (R5's die-and-return latitude, spent as designed; her phone
  journaling rides Variorum Mobile meanwhile — and the Phase-14 pause idles
  the bridge anyway).
- **The seam is the payload serializer, text-bearing columns only**
  (release-strategy §4); `entry_date` stays plaintext metadata, disclosed
  (contract touchpoint #2).
- **The vault's tables are a SyncSpec §12 lockstep event** (schema commits
  their own; mirror deploy only at her explicit go — the R53 precedent; the
  A1 rail before anything touches the mirror).

## The design sitting's PINNED QUESTIONS (accumulated 14a → here; each needs
## her ruling before the plan is authored)

1. **Device enrollment INCLUDES THE PHONE from the design start** (the
   mobile agent's flag, relayed by the author 2026-08-04; parity ledger
   PL-6 is this class — mobile is IN the design sitting, not informed
   after). *Her 2026-08-04 clarification, correcting an earlier
   "phone-first" shorthand: the phone is a FIRST-CLASS device — that is the
   whole flag. It is NOT a requirement that the phone enroll first or lead
   the design.* Enrollment, key unwrap, and recovery-phrase entry UX are
   designed for BOTH form factors together (never Mac-first-phone-later);
   the recovery-phrase restore drill enrolls the phone as part of the
   drill. How enrollment actually works — including which device
   typically enrolls first — is this sitting's design question, open.
2. **Fragments insights vs journal-class E2EE** (the round-0v sweep's finding
   3, pinned on the 14b row): does anything server-side read the bridge's
   `journal_entries` (Fragments insights)? If yes, journal-class E2EE trades
   those insights away — the sitting rules client-side computation vs the
   accepted trade. (An ask to the Fragments side may be needed to even answer
   the factual half — it can ride ahead of the one-batch handoff as a
   question, not a work order.)
3. **Her mirror's migration: WIPE-AND-REPUSH vs in-place** (the 14a round-0y
   sweep — R3 applied to the mirror): local SQLite is truth, the mirror is a
   peer, her pause leaves ONE active device — re-initializing the mirror
   through the new encrypted serializer may beat migration machinery
   entirely. The sitting weighs server_seq/cursor reset implications (every
   client's pull cursor; `sync_row_seq`; the changefeed's monotonicity) and
   rules the road. The A1 rail rides whichever road wins.
4. **The one-way doors, decided deliberately at the sitting** (the round-0e
   "build fast, decide carefully" step — these bake into ciphertext and
   cannot be cheaply re-decided): the KDF (algorithm/parameters — a Sonnet
   lookup for current-best-practice parameters is in-scope sitting work),
   the recovery-phrase format (wordlist, length, checksum), the
   key-hierarchy shape (one data key vs per-class keys — the journal class's
   shared-key need with Fragments bears directly), and the enrollment
   protocol (how a new device gets the data key: passphrase-unwrap vs
   device-to-device approval).
5. **The vault-home question re-opens FREE at this sitting** (the standing
   round-0g guardrail, recorded in 14a's RULED STATE): the vault is NEW data
   at 14b — the separate-project option can be re-taken NOW at zero
   migration cost (vault separation = a Variorum dump alone is useless
   without a second independent compromise; cohabiting = one dump holds
   ciphertext + wrapped key, collapsing to passphrase strength). Her 0h
   ruling put the ACCOUNT on the Variorum project; the vault's row-home is
   this sitting's own call.

## Scope boundary (from the master-plan 14b row — the sitting refines, the
## split's boundary stands)

Variorum sync E2EE from birth (payload-serializer seam, text-bearing columns;
the account-level key vault + recovery phrase; device-linking enrollment; one
honest setup warning; her own mirror's migration) · the bridge's journal
class E2EE on BOTH ends under the shared key, designed here, Fragments-side
executed in the 14c-end batch (the bridge pauses meanwhile) · the
Fragments-side asks (trim + empty-body-as-deletion relocated client-side or
made metadata) ride the contract file · device enrollment includes the PHONE
from the design start. Verification per the row: convergence suites green
over ciphertext; a total mirror dump reads as structure, never words; a
recovery-phrase restore drill (phone enrolled in the drill).

## What 14a left in place (verified facts, never re-derive)

- Her suite account stands on its own: direct email+password on user
  *[removed for publication]*
  sign-in is the direct form (Mac + mobile, one shared seam);
  `custom:fragments` retired (identity + provider — see the 14a gate record).
- P-ii verified live (round 0r): vault-shaped RLS'd tables on the project
  work with OAuth-server-issued tokens AND ordinary password-grant sessions;
  the bare key grants nothing.
- The signups-off toggle is the SOLE corpus guard until 14c — 14b never
  touches it.
- The store and mirror are QUIESCENT (her Phase-14 pause) — the migration
  window is as safe as it will ever be.
- Baselines at 14a's closeout: see `notes/handoffs/phase-14a-handoff.md`
  (final counts recorded there; never re-run at session start).
- Zero `Sync/` lines were touched in 14a; 14b is where the standing rider's
  sync-engine surgery actually begins — `notes/sync-postmortem-fragments.md`
  is mandatory pre-reading for it.
