# Phase 14b — Suite E2EE — plan

> **Status: OPEN — the design sitting RAN 2026-08-04 (author-attended; the
> sitting record below holds the rulings). This file is now the PLAN file per
> the draft's own rule.**
> **Cast: ALL-FABLE, confirmed by her invocation** (`/architect-phase all
> fable`, 2026-08-04) — architect/orchestrator Fable · a fresh Fable
> implementer per batch · a fresh Fable cold reviewer per ladder round,
> matching her recorded lean and the standing Sync/ rider.

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

---

## THE DESIGN SITTING (2026-08-04 — author-attended; rulings recorded same-turn)

### Round 1 — the four structural questions (question-tool batch; her picks by
### option label — no free-text notes rode the answers)

- **R-1 (pinned question 5, the vault home): the vault tables live ON THE
  VARIORUM PROJECT — her pick: "Variorum project (Recommended)".** Presented
  with the honest tradeoff (cohabiting = one dump holds ciphertext + wrapped
  key, collapsing to passphrase strength, mitigated by the KDF ruling below;
  separation = defense-in-depth at the cost of resurrecting the cross-project
  OIDC trust 14a just retired + a second ops surface). The free re-open is
  SPENT: the 0h account-home ruling now extends to the vault's row-home, and
  the 14a "re-decide checkpoint before the first stranger account" remains the
  one standing look-back.
- **R-2 (pinned question 3, her mirror's migration): WIPE-AND-REPUSH — her
  pick: "Wipe-and-repush (Recommended)".** The mirror's data tables truncate
  behind the A1 rail; both devices' pull cursors + `sync_row_seq` reset
  DELIBERATELY as a designed, harness-proven step; her whole corpus re-pushes
  through the new encrypted serializer. No one-shot in-place migration
  machinery is built. The cursor/seq reset semantics are proven in the
  two-client harness BEFORE anything touches production; the production
  execution is an announced gate act at her explicit go.
- **R-3 (pinned question 2, Fragments insights): "Nothing server-side reads
  it" — her answer, offhand as the app's owner.** The factual half is CLOSED:
  no server-side Fragments processing reads `journal_entries` bodies, so
  journal-class E2EE trades nothing away. No ask rides ahead to the Fragments
  agent; touchpoint #2 stands as drafted.
- **R-4 (pinned question 1 + the enrollment one-way door): PASSPHRASE ENTRY
  is v1's enrollment road — her pick: "Passphrase entry, v1 (Recommended)".**
  A new device signs in, prompts for the encryption passphrase, unwraps the
  data key from the vault — identical UX on Mac and phone (PL-6's both-form-
  factors mandate; the phone first-class per her 2026-08-04 clarification).
  QR device-to-device linking is recorded as a FUTURE convenience door,
  addable without touching ciphertext (the vault format precludes nothing —
  presented and recorded as the reason this door is not one-way). The
  recovery phrase remains the disaster road regardless (a high-entropy wrap
  in the vault). The recovery-phrase restore drill enrolls the phone as part
  of the drill, per the scope boundary. *Re-affirmed at round 2 in her own
  words: "I don't want device to device enrollment as a requirement (the
  passphrase should be enough)."*

### Round 2 — the one-way doors (question-tool batch, informed by the
### in-sitting Sonnet crypto-facts lookup; two ruled clean, two confirmed
### after her clarifying questions — her words quoted)

- **R-5 (recovery-phrase format): 12-WORD BIP-39 — her pick: "12-word BIP-39
  (Recommended)".** 128-bit entropy + the built-in SHA-256 checksum (typos
  detected, never silently accepted), the 2048-word English wordlist
  (effectively unencumbered), phone-typeable with word autocomplete. The
  phrase encodes a high-entropy secret whose derived key wraps the master
  directly — immune to brute force; the passphrase wrap is the only
  brute-forceable wrap, which is what R-7's KDF hardens.
- **R-6 (unlock cadence): ENROLLMENT-ONLY — her words: "I think enrollment
  only is fine - would I be able to make biometric per launch a setting
  later? for if you're more personally concerned about it? or is this
  closing the door on that?"** Ruled enrollment-only: after the one-time
  unwrap, the data keys persist in the device Keychain (hardware-backed,
  per-device); day-to-day sync stays invisible. **Her question ANSWERED and
  the answer binds the design: the door stays OPEN** — unlock cadence is a
  device-local policy (Keychain accessibility + an optional biometric access
  control on the key item), never part of the vault format, the ciphertext,
  or the protocol; a future "require Face ID/Touch ID at launch" setting is
  addable at any phase with zero migration. The one inherent cost when such
  a setting is ON (sync waits for the first unlock each launch) was stated
  in-sitting. The 14b build must not preclude this (and cannot, by the
  design's shape — recorded so no reviewer wonders).
- **R-7 (the KDF): ARGON2ID WITH THE DEPENDENCY — her lean, then her
  explicit confirm (see below).** Her round-2 note verbatim: "what do
  standard notes and obsidian use? do i have to pay a licensing fee? I lean
  towards just doing what you recommend here with Argon2id and I don't want
  device to device enrollment as a requirement (the passphrase should be
  enough) but I don't fully understand the implications of the choice."
  The in-sitting answers (recorded because her confirm rests on them):
  Obsidian Sync uses scrypt→HKDF→AES-256-GCM (their published explainer);
  Standard Notes' current protocol (004) uses Argon2id via libsodium with
  XChaCha20-Poly1305 — i.e. the recommendation is literally the Standard
  Notes shape. NO licensing fee ever: libsodium/swift-sodium is ISC and the
  PHC reference implementation is dual CC0-1.0/Apache-2.0 — free, no
  royalties, no copyleft; the only obligation is notice preservation (CC0
  has none). Implications stated plainly: (1) dump brute-force cost rises
  orders of magnitude; (2) unlock ~0.5–1 s once per device + ~64 MiB
  TRANSIENT memory during derivation (fine on phone; MobileSoul's bar is
  steady-state); (3) one small pinned dependency — the architect's
  integration lean is the PHC reference C VENDORED as an SPM target (code
  frozen in-repo, no package supply chain), decided at plan time within
  this approval; (4) the door is SOFTER than feared — the KDF only
  stretches the passphrase to wrap the MASTER key, so a future KDF change
  is a one-key re-wrap at next unlock, never a corpus re-encrypt; the
  genuinely one-way parts are the corpus AEAD format and what Fragments
  builds against at touchpoint #2; (5) web-someday is safe (libsodium/
  Argon2 compile to WASM). Parameters: tuned at build in the ~64 MiB class
  (OWASP-floor-exceeding), with on-device latency measured on BOTH form
  factors.
- **R-8 (key hierarchy): MASTER + PER-CLASS KEYS — her note, then her
  explicit confirm (see below).** Her round-2 note verbatim: "i'm a litle
  confused at the tradeoff here - if there is only one passphrase entry for
  enrollment, is there any disadvantage to doing option 1? I think option 1
  sounds like it's fine but want to confirm this." The in-sitting answer
  (recorded): NO user-visible disadvantage — one passphrase entry unwraps
  the master, class keys unwrap instantly beneath it, the hierarchy is
  never seen; the costs are entirely internal (a couple more vault rows, a
  little more wrap/unwrap code, tested once); the benefits are real
  (Fragments' client only ever touches the journal-bridge key; per-class
  rotation = one class re-encrypted, not the suite). Vault shape: master
  wrapped twice (passphrase-KDF wrap + recovery-phrase wrap); v1 class
  keys — Variorum corpus · journal-bridge — wrapped by master via CryptoKit
  `AES.KeyWrap` (RFC 3394).

### Round 3 — the two explicit confirms (question-tool batch; her picks by
### option label)

- **R-7 CONFIRMED — "Confirmed — Argon2id (Recommended)":** Argon2id via a
  vendored copy of the official PHC reference implementation (CC0/
  Apache-2.0 — free, no fee, frozen in-repo; ISC swift-sodium permitted as
  the alternate if it proves cleaner at plan time — her approval covers
  both), parameters in the ~64 MiB class tuned with on-device latency
  measured on BOTH form factors. Passphrase-only enrollment stands.
- **R-8 CONFIRMED — "Confirmed — master + per-class (Recommended)":** the
  vault stores the twice-wrapped master plus per-class keys (Variorum
  corpus · journal-bridge); Fragments' side only ever handles the
  journal-bridge key at touchpoint #2.

**The sitting is COMPLETE: all five pinned questions ruled (R-1 vault home ·
R-2 wipe-and-repush · R-3 insights-factual-closed · R-4 enrollment · R-5
recovery format · R-6 unlock cadence · R-7 KDF · R-8 key hierarchy). The
execution plan below is authored from these rulings, same sitting.**

---

## The binding principles (the 13b constitution, P-1…P-9 — copied per the
## `/architect-phase` skill; the skill file holds the byte-verbatim text and
## the application precisions, all BINDING here; phase-specific names inside
## them are the rules' provenance)

P-1 one capability registry · P-2 fire-and-DO · P-3 one text surface, one
liveness authority · P-4 broadcasts carry signals, never decisions · P-5 the
friction doctrine · P-6 the tutorial is the executable spec (the spine rides
every batch) · P-7 find bugs before she does (red-on-old absolute) · P-8
standing law consolidated (P1–P3 bind; overlays never rendering attributes;
chrome fixedSize carries lineLimit; complexity in the store, restraint in the
UI) · P-9 no god objects in the frontend. Full text:
`.claude/skills/architect-phase/SKILL.md` — read by every implementer.
**Phase-specific rider:** every `Sources/VariorumCore/Sync/` line is
sync-engine surgery (the standing Fable rider); `notes/sync-postmortem-fragments.md`
is mandatory pre-reading for any session that touches it, and any sync change
not covered by a convergence test is unreviewed by definition (AppSpec §15.3).

## THE DESIGN (settled by rulings R-1…R-8 — the architecture the batches build)

**What encrypts, where.** Local SQLite stays PLAINTEXT (FileVault + device
passcode guard the device; the E2EE boundary is the network/server). The seam
is the payload serializer (`SyncSchema`'s row→payload fetch and payload→row
apply/parse paths): text-bearing columns encrypt on the way OUT, decrypt on
the way IN — including the reject-merge parse — so the engine inland
(`Merge.swift`, `Repairs.swift`, CAS, cursors) operates on plaintext locals
and never notices, exactly as release-strategy §4 promised. `SyncSchema`
already being the ONE registry (engine + fake server + mirror DDL derive from
it, introspection-tested) is what makes this the landing: each `SyncTable`
gains an `encryptedColumns: Set<String>` beside `excludedColumns`, and a
PRAGMA-introspection completeness walk asserts EVERY column of EVERY synced
table is explicitly classified plain / encrypted / excluded — a future
migration cannot silently leak a new text column (the postmortem's
serializer-drift lesson, applied to encryption).

**The ciphertext format.** AEAD via CryptoKit (AES-256-GCM; hardware-
accelerated), per-value random 96-bit nonce (CryptoKit-generated), AAD
binding `table:rowid:column` + the key id — a ciphertext cannot be swapped
between rows/columns undetected even though ids stay plaintext. Encoding: a
version-prefixed base64 string (`e1:…`) in the existing TEXT columns — NO
mirror column-type changes. Per-class keys per R-8; HKDF per-table subkeys
are batch-1's call as cheap nonce-bound insurance (personal scale is
comfortably inside the 2^32 bound either way; whichever is chosen is
recorded in the format doc).

**The vault (R-1, R-8).** One new table on the VARIORUM project —
`key_vault`: `user_id` PK (= `auth.uid()`, RLS'd exactly as P-ii verified),
`format_version`, KDF descriptor (algorithm/params/salt — versioned so a
future KDF change is a one-key re-wrap, R-7's soft-door fact), master key
wrapped by the passphrase-KDF key, master wrapped by the recovery-phrase key,
per-class keys (corpus · journal-bridge, each with a key id) wrapped by
master via CryptoKit `AES.KeyWrap` (RFC 3394), timestamps. Accessed via
plain authenticated PostgREST (account data, NOT row-sync data — the sync
engine never touches it). **SyncSpec §12 lockstep event: marker 4→5**, DDL
`Server/supabase/08_phase14b_lockstep.sql`, deploy ONLY at her explicit go
at the gate (the R53 precedent); `SyncSchema.lockstepVersion` bumps in the
same commit as the DDL file (the `AuthRLSDDLTests` pin holds them together).

**Keys on device (R-4, R-6).** Setup (first device): choose the encryption
passphrase + the ONE honest warning (unrecoverable-by-design is its whole
content) + the 12-word BIP-39 phrase displayed once and confirmed by
re-entry. Enrollment (new device): sign in → type the passphrase → unwrap
master → class keys → ALL persist in the device Keychain (hardware-backed;
enrollment-only cadence). The design must not preclude a future
"require biometrics at launch" setting (R-6's answered door — Keychain
access-control policy, zero format impact). The recovery phrase is the
disaster road: phrase → BIP-39 seed → HKDF → recovery wrap key → master.
Identical flows both form factors (PL-6; shared seam per the 14a
`AccountView` precedent).

**Sync gating.** E2EE active + keys absent/locked ⇒ the engine REFUSES the
round visibly — outbox intact, cursor unmoved, a status line naming the fix
("enter your encryption passphrase") — the exact SyncSpec §12 refusal
grammar. New `sync_state` keys carry enrollment state/key ids (local-only).

**Her migration (R-2): wipe-and-repush.** No in-place migration machinery.
Client-side: a `resyncReinitialize` operation — reset every synced row's
`sync_version` to 0, clear `sync_row_seq`, clear the pull cursor, enqueue
every row (live AND tombstoned) into the outbox — proven in the two-client
harness BEFORE production. Server-side: truncate the sixteen data tables
(never `auth.*`, never `key_vault`, never `sync_meta`) via a committed SQL
artifact executed at her explicit go behind the A1 rail (+ a mirror export
for belt-and-braces). The global `server_seq` sequence is NOT reset
(ordering authority stays monotonic; SyncSpec §9). The phone RE-ONBOARDS:
fresh store, enrollment, pull-to-head over ciphertext — which IS the restore
drill's fresh-device half (her 4.5 MB corpus is far inside the pull-to-head
memory row's envelope).

**The bridge (journal class — designed here, Fragments-side executed at the
14c-end batch).** `BridgeEngine` gains journal-class capability: encrypt
`renderedText` with the journal-bridge key on push, decrypt landed bodies on
land; `entry_date` stays plaintext metadata, disclosed. The bridge is PAUSED
from this phase until the one-batch handoff (the R5 latitude, spent as
designed) — capability ships, rounds do not run. Touchpoint #2's contract
block gains the CONCRETE format facts (AEAD, encoding, AAD convention, key
id, vault access) so the Fragments batch is an execution, not a design; the
trim + empty-body-as-deletion relocations ride as drafted. R-3 closed the
insights question: nothing server-side reads `journal_entries` — the trade
is empty.

**The disclosure list (author-facing, ratified at the gate).** What the
server still sees under E2EE: `entry_date` (which days carry entries),
timestamps, positions/order, kinds/status/profile enums, lock flags, the
structural graph (ids, edges, memberships), payload sizes and write cadence,
`setting` values (enum semantics, no prose). Everything user-authored
encrypts — the initial classification: `variant.working_text` ·
`variant.label` · `commit_point.text` · `commit_point.message` ·
`block.name` · `block.presentation` · `container.title` ·
`container.floating_notes` · `reading.name` · `reading.query_spec` ·
`reading_section.name` · `tag.name` · `tag.path` · `block_comment.text` ·
`reference.name` · `reference.url` · `reference.view_state` · `lens.name`.
(`canvas_layout` coordinates stay plain — spatial metadata, no prose; the
completeness walk forces every future column to take a side.) Batch 2 may
adjust with recorded reasons; the gate presents the final list.

## The batches (fresh Fable implementer per batch, strictly sequential;
## the spine + red-on-old ride every one; briefs = this file's named sections)

**Batch 1 — the crypto substrate (zero `Sync/` contact).**
1. Vendored material, ITS OWN COMMIT (the model-change convention applied to
   the dependency her R-7 approval covers): `Vendor/CArgon2/` — the PHC
   reference implementation's Argon2id-relevant sources, license files
   preserved, pinned upstream commit recorded in a README — as a C target in
   `Package.swift`; plus the BIP-39 English wordlist as a bundled resource
   (2048 words, checksummed in a test against the spec's SHA).
2. `Sources/VariorumCore/Crypto/`: `PassphraseKDF` (Argon2id; params
   versioned; the ~64 MiB-class default per R-7) · `RecoveryPhrase` (BIP-39
   generate/validate/derive; checksum errors speak) · `KeyVaultFormat` (the
   versioned vault payload: wrap/unwrap master both roads, class-key
   wrap/unwrap via `AES.KeyWrap`; tamper → typed refusal) · `PayloadCipher`
   (AEAD seal/open with AAD + `e1:` encoding; wrong-key/wrong-AAD/garbage →
   typed refusals, never crashes).
3. Tests per step: RFC 9106 Argon2id test vectors against the vendored
   build; BIP-39 spec vectors (entropy→words→seed); full wrap→unwrap
   round-trips + every tamper/mismatch arm; encoding round-trips incl.
   empty string and multi-MB text; a latency harness measuring KDF
   derivation on the Mac (the phone measurement rides batch 3's device
   work — BOTH recorded before the gate, R-7's condition).

**Batch 2 — the serializer seam + engine gating (THE `Sync/` surgery; the
postmortem + SyncSpec are mandatory pre-reading; every change convergence-
tested).**
1. `SyncSchema`: `encryptedColumns` per table + the classification above;
   the PRAGMA completeness walk (every column classified exactly once, build-
   failing); `lockstepVersion` 4→5 **in the same commit as**
   `Server/supabase/08_phase14b_lockstep.sql` (the `key_vault` DDL + marker
   UPDATE — authored and pinned now, DEPLOYED only at the gate).
2. The seam: encrypt at row→payload fetch, decrypt at payload→row apply AND
   at the reject-merge parse (`SyncEngine` + `SupabaseTransport` payload
   boundaries; `Merge.swift`/`Repairs.swift` semantics byte-untouched — the
   diff proves it).
3. Key-provider seam + visible refusal (keys absent/locked ⇒ refuse round,
   outbox intact, cursor unmoved — pinned exactly like the §12 skew
   refusal).
4. **The crown assertion: the existing two-client convergence suites run
   GREEN over ciphertext** — the fake-server harness runs with encryption
   ON (conflict-as-variant, repairs, races, fault-injection, the A5
   visibility-skew scenario — all of them, over ciphertext payloads); plus
   the mirror-dump assertion (every text-bearing value in the fake server's
   store bears the `e1:` prefix and decrypts to the expected plaintext —
   structure visible, words never); plus a `resyncReinitialize` harness
   scenario (wipe the fake mirror, re-init client A, repush, client B
   fresh-onboards and converges byte-identical).

**Batch 3 — vault client, setup/enrollment UX, the bridge capability, the
runbook.**
1. Vault PostgREST client (authenticated reads/writes on `key_vault`;
   single-flight; typed refusals) + Keychain custody (per-device; distinct
   service; the R-6 future-biometric door left open and noted in code).
2. The shared setup + enrollment flows (Mac AND phone through the one seam,
   the 14a `AccountView` precedent): passphrase choose + the ONE honest
   warning (wording drafted for her gate ratify) + phrase display/confirm;
   enrollment passphrase-unwrap; the sync status face's locked-state line.
3. `resyncReinitialize` as a real client operation (the harness-proven
   semantics from batch 2, productized behind an explicit announced door —
   never reachable casually).
4. `BridgeEngine` journal-class capability (encrypt push / decrypt land;
   rounds stay paused) + the touchpoint #2 contract-block update with the
   concrete format facts + the phone KDF latency measurement (R-7's
   condition) + the disclosure list finalized for the gate.
5. Tests: vault client round-trips against a scripted server; enrollment
   state machine incl. wrong-passphrase (KDF-derived key fails unwrap →
   speaks, never crashes), checksum-failing phrase, vault-absent,
   vault-newer-format arms; bridge capability round-trip over ciphertext;
   the spine + both suites green.

**THE LADDER — one ladder over the phase's combined diff** (fresh Fable cold
reviewer, `notes/REVIEW_PROMPT.md` verbatim, zero framing; findings recorded
here before any fix session; round 2 re-reviews; new BLOCKER/MAJOR ⇒ round
3; cap three).

### Round 4 — her overnight directive (mid-sitting message, 2026-08-04,
### recorded verbatim; the architect's dispositions beneath)

Her message, in full: *"let me know if there's anything left in the design
sitting I see you say that it's complete.  variorum is closed and my app is
ready for refresh (you don't need to ask my permission for relaunch) and
whatever else is required. I'm going to bed and plan to have this run
overnight - I think your permissions layer will have some issues with you
deleting what's currently in the database (even though I approved the wipe
and refill plan explicitly and you have my PAT to use), so do you want to
give me that command now so I can run it? and is there anything else you
want from me now so that the rest of the phase can run overnight?"*

Dispositions (recorded before the run starts):
1. **Nothing is left in the design sitting** — all five pinned questions
   ruled (R-1…R-8). What remains for her is GATE work, not design (the
   morning checklist below).
2. **The `/Applications` refresh is PRE-AUTHORIZED** (her words; no per-step
   ask) — still SEQUENCED after the marker-5 deploy per the lockstep-strand
   rule, at the zero-instance window her closed app provides.
3. **The mirror WIPE is pre-approved by her words but was deliberately NOT
   handed to her tonight:** it sequences AFTER her vault setup — the
   encrypted repush needs keys wrapped by HER passphrase, which cannot be
   chosen in her absence — and after the A1 rail. Running it tonight gains
   nothing (the truncate is instant when its moment comes) and would break
   the ordering. Declined with reasons, here for the record.
4. **The OVERNIGHT RUN = batches 1–3 + the ladder** (zero production
   contact). The ONE candidate production act overnight is the ADDITIVE
   vault deploy (`08` + marker 5), attempted ONLY if the ladder closes
   clean — announced HERE as the R53-compliant announcement, covered by her
   "whatever else is required" + the stored-PAT arrangement. If the
   permission layer blocks it, it bundles to the morning checklist (one
   paste for her). The refresh follows the deploy or bundles with it.
5. **THE MORNING CHECKLIST (hers, ~10 minutes + the drill):** ① vault
   setup — choose the encryption passphrase (separate from, and stronger
   than, the account password — the standing wrap-secret ruling) + write
   down the 12-word recovery phrase; ② the mirror wipe at her go (the
   committed artifact; A1 + mirror export run first by the architect);
   ③ the repush + live dump verification (watched, hers to witness);
   ④ phone: fresh install → sign in → enroll by passphrase → her corpus
   readable (PL-6 live); ⑤ the recovery drill by the WRITTEN PHRASE;
   ⑥ ratify the setup-warning wording + the disclosure list; ⑦ deploy +
   refresh here too if the permission layer held them overnight.
6. **Nothing else is needed from her tonight** — both credential files
   verified present (`.env.supabase.local`, `.env.fragments-oauth.local`);
   the phone is a morning item by nature.

### Round 5 — her passphrase-file offer (mid-sitting, 2026-08-04; amends
### Round 4's item 3)

Her message, verbatim: *"can i choose a passphrase now and put it into an
environment file in a way where you can't read it? that might be able to
work for overnight - correct?"*

The arrangement, accepted with the honesty caveat stated to her plainly:
1. **The honesty caveat (recorded because the phase's soul demands it):**
   nothing on this machine is truly unreadable to the agent layer — sessions
   run as her user. The guarantee is DESIGN + DISCIPLINE, the stored-PAT
   pattern applied to one more secret: the file (`.env.e2ee-passphrase.local`,
   gitignored BEFORE creation, `chmod 600`) is consumed directly by the
   setup tool, never printed, never logged, never echoed into any
   transcript; she creates it in HER OWN Terminal (never via `!`, whose
   output lands in-conversation) via `read -s` so it also never touches her
   shell history or screen. And by R-7's soft-door fact the passphrase is
   CHANGEABLE later (a master re-wrap, cheap by design) if she ever wants a
   clean break from this arrangement.
2. **What it unblocks — the CONDITIONAL production tail:** IF the ladder
   closes clean overnight, the run may continue past it at her standing
   pre-approvals: deploy `08`/marker 5 → her vault setup from the file
   (**passphrase wrap ONLY** — see 3) → the A1 rail + mirror export → the
   WIPE (her Round-4 pre-approval + this arrangement) → the repush → the
   live dump verification → the `/Applications` refresh. If ANYTHING in the
   ladder wobbles, every production act waits for morning exactly as Round
   4 sequenced.
3. **The recovery phrase is generated in her PRESENCE regardless** — its
   entire point is being seen once and written down, so persisting it to
   disk overnight would put the disaster secret in plaintext exactly where
   it must never live. The overnight vault carries the passphrase wrap
   alone; the MORNING adds the recovery wrap (unwrap master via Keychain →
   generate the 12 words → she writes them → confirm re-entry → the wrap
   lands). `KeyVaultFormat` must support wrap-addition — batch 1/3 note.
4. **File hygiene:** the file's bytes ARE the passphrase (a single trailing
   newline is stripped, forgiving); the file is DELETED at the morning
   gate's end as an announced checklist act (added to Round 4 item 5 as ⑧).
5. The morning checklist otherwise stands: phone enrollment, the recovery
   drill (phrase-only unwrap), the two ratifies, and anything the
   permission layer held.

### Round 6 — three morning-adjacent clarifications (mid-sitting, 2026-08-04)

1. **Passphrase policy (her question: "just has to be 12 characters long at
   least, right? no other requirements?"):** NO hard requirement exists in
   any ruling — the honest answer given: the passphrase is the dump's only
   brute-force barrier (R-1's accepted tradeoff; Argon2id multiplies each
   guess's cost but LENGTH is the real defense), so the recommendation is a
   4+-random-word phrase or 16+ mixed characters; 12 characters is an
   acceptable floor if it is no dictionary word and no reused password;
   NEVER the account password (the standing ruling) and never a password
   used anywhere else. The headless setup tool enforces only non-empty +
   a recorded warning under 12 characters — her choice is hers.
2. **Where the recovery phrase gets generated (her question):** in the
   VARIORUM MAC APP's E2EE settings surface (the batch-3 shared flow —
   the Settings/sync sheet family): the app, holding master via Keychain
   from the overnight setup, generates the 12 words, displays them ONCE,
   she writes them down, confirms by re-entry, and the recovery wrap lands
   in the vault. A UI act, not a terminal act.
3. **THE PHONE-BUILD TIMING CONSTRAINT (surfaced reviewing her draft
   message to the mobile project; binds gate step 5):** the morning phone
   verification needs a phone build carrying the 14B code (marker-5
   lockstep + the decrypt seam + enrollment) — a pre-14b phone build
   against the post-gate mirror REFUSES to sync by design (marker 4 ≠ 5),
   and could not read ciphertext anyway. So the mobile project must merge
   `main` → `mobile` IN THE MORNING (after the overnight batches land),
   never from tonight's main; the phone install must be a RELEASE build
   (the A4 fence — Debug is the dev store, never her corpus); the
   enrollment UX arrives through the shared seam (batch 3; PL-6). Relayed
   to her as a paste-ready addition to her mobile-session message.

**THE GATE (announced steps, her explicit go per step — amended by Round 4:
refresh pre-authorized; wipe pre-approved and sequenced at step 4; deploy
attempted overnight if the ladder closes clean):**
1. A1 backup of her real store + a mirror export (belt-and-braces).
2. Deploy `08_phase14b_lockstep.sql` (vault table + marker 5) — her go; the
   committed artifact verbatim; after-state verified (`sync_schema_version()`
   = 5, `key_vault` present, RLS enabled, zero rows).
3. Her vault setup on her account: passphrase (the wrap-secret ruling: a
   SEPARATE, stronger secret than the bootstrap password), the warning, the
   12-word phrase written down by her hand; vault row verified.
4. Mac: `resyncReinitialize` + the mirror truncate artifact at her go (A1
   rail already run) → repush → the LIVE dump verification: every
   text-bearing column value on the production mirror bears `e1:`, none
   decrypts server-side, structure intact.
5. The phone: fresh install/store → sign in → ENROLL by passphrase →
   pull-to-head over ciphertext → her corpus readable on the phone (PL-6's
   deliverable, live).
6. The recovery drill: on a scratch state, unwrap by the WRITTEN PHRASE
   alone (no passphrase) → corpus readable — the row's drill, phone
   included per the scope boundary.
7. `/Applications` refresh ONLY AFTER step 2's deploy (the lockstep-strand
   rule: a marker-5 client against a marker-4 mirror refuses by design;
   never strand her build), at a sanctioned zero-instance window.
8. Disclosure list + warning wording ratified; her passphrase/phrase custody
   confirmed; the pause's END remains HER call (14c still ahead).

## Ledger (running; every row owned)

| # | Item | Status |
|---|------|--------|
| L1 | Vendored CArgon2 + wordlist (own commit; R-7 approval recorded) | pending — batch 1 |
| L2 | `Crypto/` module: KDF · RecoveryPhrase · KeyVaultFormat · PayloadCipher, vectors + tamper arms | pending — batch 1 |
| L3 | `SyncSchema` classification + completeness walk | pending — batch 2 |
| L4 | The serializer seam (encrypt-out/decrypt-in incl. reject-merge) | pending — batch 2 |
| L5 | Key-provider gating + visible refusal | pending — batch 2 |
| L6 | Convergence suites GREEN over ciphertext + mirror-dump assertion + re-init harness scenario | pending — batch 2 |
| L7 | `08_phase14b_lockstep.sql` + `lockstepVersion` 5 (same commit; deploy at gate) | pending — batch 2 |
| L8 | Vault client + Keychain custody | pending — batch 3 |
| L9 | Setup/enrollment flows, BOTH form factors (PL-6) | pending — batch 3 |
| L10 | `resyncReinitialize` productized | pending — batch 3 |
| L11 | Bridge journal-class capability (paused) + touchpoint #2 concrete facts | pending — batch 3 |
| L12 | Phone KDF latency measured (R-7's condition) | pending — batch 3 |
| L13 | Disclosure list + warning wording for her ratify | pending — batch 3 → gate |
| L14 | The ladder (combined diff) | pending |
| L15 | The gate steps 1–8 (deploy · setup · wipe-repush · phone enroll · recovery drill · refresh · ratifies) | pending — her go per step |
| L16 | MobileSoul PL-6 updated at design time (done this sitting) + closeout parity line | PL-6 written; closeout line owed |

## Environment traps (carried into every batch brief, per the skill)

- Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate
  by PATH; real-store instances treated by STORE, never quit/killed; no
  Release builds or `/Applications` refreshes while one lives — and NO
  refresh before the gate's step-2 deploy (the lockstep-strand rule).
- The mirror is LIVE production: any dashboard/SQL change announced before it
  happens, committed in-repo artifacts verbatim, her explicit go, the A1 rail
  first. The signups-off toggle is NEVER touched (14c's).
- Backups WAL-safe with UTC names, ALWAYS before touching the real store.
- Mac tests from `App/Variorum/`, suite-level `-only-testing` only; zsh
  `pipestatus`; never a custom build configuration (the 4G trap); core tests
  via `swift test` from the repo root.
- The standing tripwire red (`TakePaneMeasureTests.aStrandedRenderTier…`) is
  BY IDENTITY the one allowed Mac red; anything else is real.
- Baselines (never re-run at session start — 14a's closeout is the record):
  core 1039/114 · Mac 1196/208 (the tripwire) · mobile 172/24 · spine 51/7.
- Sessions never touch `~/dev/fragments` or the Fragments project
  *[removed for publication]*
- Implementer sessions WAIT SYNCHRONOUSLY on their own builds/tests (the 14a
  background-wait death), and write repo-first records BEFORE long
  verification runs with claims marked PENDING.

## Verification (the phase's acceptance, from the master-plan row)

Convergence suites green over ciphertext (L6) · a total mirror dump reads as
structure, never words (harness assertion + the gate's LIVE verification) ·
the recovery-phrase restore drill with the phone enrolled (gate steps 5–6) ·
the spine green every batch · zero KnownIssues rows orphaned (none touched
by this phase's scope; the pull-to-head row's envelope note recorded above).
