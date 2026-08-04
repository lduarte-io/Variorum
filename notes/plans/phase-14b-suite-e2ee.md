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

### Batch 1 — record (implementer session, 2026-08-04)

**What shipped (commits `ad7bbc7` vendored material · `ed30c3a` Crypto/ +
tests):**

- **L1 — vendored material, its own commit.** `Vendor/CArgon2/`: the PHC
  reference implementation's minimal Argon2id set at pinned upstream
  `f57e61e19229e23c4445b85494dbf7c07de721cb` — `include/argon2.h`,
  `src/{argon2,core,encoding,ref}.c` + headers, `src/thread.h` (header
  only), `src/blake2/{blake2b.c,blake2.h,blake2-impl.h,blamka-round-ref.h}`
  — byte-verbatim, LICENSE (dual CC0-1.0/Apache-2.0) preserved, README
  records pin + file-set rationale (NOT vendored: `opt.c` SIMD x86 path,
  `thread.c` — excluded by `ARGON2_NO_THREADS` — bench/genkat/run/test).
  Wired as the `CArgon2` C target (`publicHeadersPath: include`,
  `-DARGON2_NO_THREADS`); `VariorumCore` depends on it; the test target
  additionally depends on it directly (the RFC full-context vector calls
  `argon2_ctx`, which `PassphraseKDF` deliberately does not expose).
  BIP-39 English wordlist: `Sources/VariorumCore/Resources/bip39-english.txt`
  (bundled `.copy` resource; it must live in the target dir, so the
  provenance README sits at `Vendor/BIP39/README.md`) — bitcoin/bips pinned
  `e7263a4cfe500c89e4269889244606953691ca33`, SHA-256 =
  `2f5eed53…24dbda`, matching the canonical published hash (independently
  recomputed by the lookup agent from a fresh fetch — two-source
  confirmation).
- **L2 — `Sources/VariorumCore/Crypto/`, four pure components:**
  - `PassphraseKDF`: Argon2id via `argon2id_hash_raw`; parameters VERSIONED
    in `Descriptor` (algorithm · argon2Version · m/t/p · salt · output
    length) stored beside the wrap — unwrap re-derives from the vault's
    descriptor, never app defaults (R-7's soft door). v1 default: **m=64
    MiB, t=3, p=1, 32-byte output, 16-byte salt** (OWASP floor 19 MiB/t=2
    exceeded; RFC 9106's second recommendation with lanes held at 1 for the
    single-threaded build). Passphrase NFKD-normalized before hashing
    (cross-device composition invariance; test-pinned).
  - `RecoveryPhrase`: 12-word BIP-39 (R-5; other word counts deliberately
    refused — the vault only mints 12), generate/validate/derive, typed
    errors incl. `checksumMismatch` and `unknownWord(_:)`; standard BIP-39
    seed (PBKDF2-HMAC-SHA512 ×2048 via CommonCrypto) → HKDF-SHA256 (salt
    `variorum.suite.e2ee.v1`, info `recovery-wrap-key`) → 256-bit recovery
    wrap key; both stages drift-pinned.
  - `KeyVaultFormat`: versioned payload (v1), master wrapped by
    passphrase-KDF key AND recovery key, class keys `corpus` ·
    `journal_bridge` (each with plaintext `keyID`) wrapped by master, all
    `AES.KeyWrap` (RFC 3394). **Round 5's wrap-addition built in:**
    `masterWrappedByRecovery` is optional; `addingRecoveryWrap` adds it
    later and VERIFIES the caller's master against a class key first
    (`masterKeyMismatch` — a wrong master can never become the phrase's
    target); refuses when already present (replacing the disaster road is a
    deliberate future ceremony, not a silent overwrite). Stable sorted-keys
    JSON `encoded()`/`init(decoding:)`; every op refuses a non-v1
    `formatVersion` typed.
  - `PayloadCipher`: AES-256-GCM, per-value random 96-bit CryptoKit nonce,
    AAD `table:rowID:column:keyID`, `e1:` + base64(nonce‖ct‖tag) in TEXT
    columns; `isEncrypted(_:)` for the seam/mirror-dump assertions; typed
    refusal arms (`notEncrypted` / `unsupportedVersion` — a foreign `e<n>:`
    speaks as such / `malformedEncoding` / `malformedCiphertext` /
    `authenticationFailed` / `invalidPlaintext`), nothing crashes, nothing
    unauthenticated is ever returned.
- **The batch-1 design call THE DESIGN delegated (recorded in the
  PayloadCipher format doc-comment):** per-class keys used DIRECTLY — **no
  HKDF per-table subkeys in v1.** Grounds: NIST SP 800-38D's random-nonce
  bound (2^32 per key) sits orders of magnitude above personal-corpus write
  volume; subkeys would spread key-custody logic across the seam/Keychain
  story for marginal benefit; the `e1:` prefix + vault `format_version`
  leave an `e2:` subkey format addable with zero ambiguity.

**Test vectors used (stated per the brief):** RFC 9106 §5.3's Argon2id
full-context vector (password 32×01, salt 16×02, secret 8×03, ad 12×04,
t=3/m=32/p=4 → tag `0d640df5…01e659`) — verified byte-identical to the
pinned upstream's own `kats/argon2id` KAT and to the RFC text (Sonnet
lookup, rfc-editor.org) — via `argon2_ctx`; PLUS the pinned upstream
`src/test.c` argon2id raw-API vectors (8 parameter sets incl. p=2 and
m=256 MiB) run through `PassphraseKDF.deriveKey` itself. BIP-39: all
EIGHT 128-bit vectors from the canonical Trezor `vectors.json` referenced
by BIP-0039 (passphrase TREZOR), fetched verbatim by the lookup agent;
the empty-passphrase seed pin doubles as the well-known BIP-32 reference
seed (independent cross-check of the PBKDF2 path).

**Own test-run counts:** the four new suites — `swift test --filter
"PassphraseKDFTests|RecoveryPhraseTests|KeyVaultFormatTests|PayloadCipherTests"`
→ **“Test run with 55 tests in 4 suites passed”** (two first-run test-side
expectation bugs fixed in-session: the `e1:` empty-body arm is
`malformedCiphertext` not `malformedEncoding` — empty string is valid
base64 — and a repeat-count landing exactly AT 3,000,000 bytes).
**KDF latency, Mac (R-7's condition, the Mac half):** v1 descriptor
(m=64MiB t=3 p=1) — samples 0.661/0.583/0.582 s, **median 0.583 s** — in
R-7's stated 0.5–1 s class. The PHONE half rides batch 3's device work,
as the plan assigns (L12).
**Full core suite (run after this record was written, per the repo-first
rule): `swift test` → “Test run with 1094 tests in 118 suites passed” —
baseline 1039/114 + the 55/4 this batch, exactly accounted; zero
pre-existing tests touched.**

**Deviations / notes:**
- Key-material randomness (`randomSalt`, `generate`, and callers' future
  master minting) deliberately does NOT flow through the seedable
  `@Dependency(\.withRandomNumberGenerator)`: a test-seedable generator in
  key-material paths is a footgun, the brief blesses CryptoKit-standard
  randomness, and the pure encoding/derivation paths are what the spec
  vectors test. Recorded, not PROVISIONAL (the brief's own carve-out).
- Two SELF-GENERATED drift pins (the v1-KDF envelope; the recovery HKDF
  stage) are implementation-generated-then-pinned — they pin against
  silent drift that would orphan vaults, not correctness (which the
  RFC/spec vectors carry); stated honestly in their comments.
- `validate` accepts ONLY 12 words (R-5 fixed the format; 15/18/21/24-word
  real BIP-39 phrases refuse as `invalidWordCount`). Design fact from the
  ruling, not PROVISIONAL.
- PROVISIONAL (small): `addingRecoveryWrap` refuses when a recovery wrap
  already exists — replace-the-phrase is left to a future deliberate
  ceremony (regenerate-phrase UX), which batch 3/the ladder can widen if
  the morning flow wants idempotent re-adds.
- The pre-existing `nonisolated(unsafe)` DateFormatter warning in
  `Models/VariorumRecord.swift` and a `if let error { throw error }`
  warning-repeat in an existing test file predate this batch; untouched.

**Recorded-not-done (owed onward):** the phone KDF latency measurement
(L12, batch 3); Keychain custody, vault PostgREST client, setup/enrollment
flows (batch 3); every `Sync/` line (batch 2 — zero `Sync/` contact this
batch, per the boundary); `08_phase14b_lockstep.sql` (batch 2); no
push — the architect pushes after verification.

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

### Batch 2 — record (implementer session, 2026-08-04)

**What shipped (four commits — `f8d76ec` classification+walk · `96b1e88`
the lockstep/schema commit, standing alone · `a4b5765` the seam+gating ·
`a8c69c5` the crown remainder):**

- **L3 — the classification IN the registry.** `SyncTable` gains
  `plainColumns` AND `encryptedColumns` (both explicit; `excludedColumns`
  unchanged) — the brief named only `encryptedColumns`, and the addition of
  an explicit PLAIN set is the deliberate delta WITH REASON: a
  plain-by-default reading makes the completeness walk vacuous (every
  column would be trivially "classified"), and only an explicit
  plain/encrypted/excluded partition makes an unclassified future column
  BUILD-FAILING, which is the walk's entire mandate. The walk
  (`SyncSchemaTests.everyColumnOfEverySyncedTableIsClassifiedExactlyOnce`)
  introspects PRAGMA table_info per synced table and fails on
  unclassified/phantom/overlapping columns and a non-plain PK; the
  doctored-double red proof follows the A6 precedent. **The classification
  ships THE DESIGN's 18-column disclosure list EXACTLY, zero deltas**
  (pinned flat in `theEncryptedSetMatchesTheDisclosureListExactly`, so a
  future adjustment is a visible diff): variant.working_text/label ·
  commit_point.text/message · block.name/presentation ·
  container.title/floating_notes · reading.name/query_spec ·
  reading_section.name · tag.name/path · block_comment.text ·
  reference.name/url/view_state · lens.name; canvas x/y and
  setting.value plain per THE DESIGN's parentheticals.
- **L7 — the lockstep event, AUTHORED NEVER DEPLOYED** (its own commit per
  the standing convention): `Server/supabase/08_phase14b_lockstep.sql` —
  `key_vault` (user_id PK = auth.uid() referencing auth.users; the
  KeyVaultFormat/Descriptor fields 1:1 — format_version, the six KDF
  descriptor columns + salt, master wrapped by passphrase NOT NULL, master
  wrapped by recovery NULLABLE (the Round-5 overnight state), both v1
  class keys WITH key ids, timestamps), owner-only RLS policies
  (select/insert/update on `auth.uid() = user_id`; DELIBERATELY no delete
  policy or grant — losing the vault orphans the ciphertext corpus;
  removal is 14c's account-deletion-scale operationalia), `revoke all from
  anon` + `grant select, insert, update to authenticated` (the
  P-ii-verified plain-PostgREST pattern), marker 4→5 as the file's LAST
  statement. `SyncSchema.lockstepVersion = 5` in the SAME commit;
  `AuthRLSDDLTests` extends the lockstepFiles chain (marker-pair pin,
  monotonic history, marker-last-statement) + new pins: the 08 header's
  choreography, the vault's RLS/policies/no-delete-door, the format
  columns, and never-in-the-RPC-allowlists; `key_vault` joins the
  serializer walk's server-only table set beside `sync_meta`. **The header
  records why the marker bumps with no mirror-column change:** the
  client's serializer semantics changed — pre-14b clients and the
  encrypted corpus must refuse each other, and §12's marker is the fence.
- **L4 — THE SEAM** (`Sources/VariorumCore/Sync/SyncEncryption.swift`, new
  file + three edit sites in `SyncEngine.swift`): `SyncPayloadCrypto`
  seals encrypted-classified text at row→wire (push chunks; the local
  plaintext chunk is retained for the accept bookkeeping's
  clear-vs-re-dirty comparison) and opens at wire→row — the pull window
  BEFORE the apply transaction exists, AND the push-reject's `current` row
  BEFORE the FK check and merge. **`Merge.swift`, `Repairs.swift`,
  `SupabaseTransport.swift`, `SyncTransport.swift`, `SyncScheduler.swift`:
  ZERO-line diff across the whole batch** (`git diff f8d76ec^..HEAD` on
  those paths is empty — the inland-plaintext promise proven by the diff,
  as the brief demands). NULL passes (presence is disclosed structure); a
  non-text value in an encrypted column refuses typed both directions
  (the blobInPayload doctrine). AAD = `table:rowID:column:keyID` via
  batch 1's `PayloadCipher`; the corpus class key serves every synced
  table (R-8 — journal-bridge is the bridge's, batch 3).
- **L5 — key-provider gating + the visible refusal.** `SyncEngine` gains
  `keyProvider: any SyncKeyProviding` with default
  `UnenrolledKeyProvider` — the POST-14B DEFAULT REFUSES every round
  (no plaintext mode exists), which keeps the App target compiling
  unchanged (`SyncSession.swift` untouched; zero `App/` lines) with the
  designed pre-enrollment behavior until batch 3 wires the
  Keychain-backed provider. Keys are checked FIRST — before the §12
  lockstep call, so a locked device refuses with ZERO network contact
  (pinned by `CountingTransport`). Any provider throw maps to
  `SyncError.encryptionKeysUnavailable`, whose description names the fix
  ("Enter your encryption passphrase…") — the status-row pin mirrors the
  §12 pin's shape exactly (outbox intact, cursor unmoved, heals with no
  state surgery, `lastErrorIsOffline == false`). New typed errors beside
  it: `unencryptedValueInEncryptedColumn(table:rowID:column:)` (the
  policy refusal — non-`e1:` in an encrypted column) and
  `payloadCryptoFailure(table:rowID:column:detail:)` (tamper/wrong-key/
  foreign-version/non-text).
- **L6 — the crown.** (a) The harness binds ONE suite-wide fixed test key
  (`Support/SyncTestKeys.swift`; `SyncClient.keyProvider` defaults to it),
  so THE ENTIRE existing convergence/fault-injection/repair/soak/
  visibility-skew suite set runs over ciphertext BY DEFAULT — the
  22-suite sync set (126 tests) green unchanged in semantics. The honest
  test diffs, exactly the seam's proof: crafted server rows now seal as a
  real competing device would (SyncPushTests' competing-writer recipes;
  SyncPullTests' TestRows builders + local-fetch crafted rows — each
  sealed under its OWN rowID because the AAD binds per-row), and
  server-content assertions open ciphertext via `SyncTestKeys.openedText`;
  six directly-constructed engines gained the test provider. (b) The
  mirror-dump assertion (`SyncMirrorDumpAndResyncTests`): every
  encrypted-classified value in the fake server's total dump bears `e1:`,
  never equals its local plaintext, opens to exactly it — with coverage
  PINNED equal to the full 18-column classification (a future encrypted
  column cannot escape the walk), over a world that includes tombstoned
  rows. (c) `resyncReinitialize()` on the engine — the R-2 client half,
  core semantics only (batch 3 productizes the door): sync_version→0
  everywhere, `sync_row_seq` cleared, cursor cleared, EVERY row (live AND
  tombstoned; commit_point and setting included) enqueued; device_id
  survives; ONE plain write transaction with triggers deliberately live
  (the enqueues are the goal) plus explicit INSERT..SELECTs for totality.
  (d) The scenario: `server.wipe()` (seq deliberately NOT reset —
  SyncSpec §9 pinned by `headSeq > seqBeforeWipe`), A re-inits + repushes
  through the encrypting serializer, a FRESH device onboards by
  pull-to-head and converges byte-identical tombstones included, and the
  pre-wipe second device re-inits too (the per-client reset the R-2
  choreography prescribes).

**The hallucination guard — refusal pins verified red by behavioral
revert, each mechanism self-traced:** (1) the keys gate reverted to
"guess a key instead of refusing" → both gating pins fail (and the healed
round then fails `authenticationFailed` — the silent-divergence disaster
the refusal exists to prevent, demonstrated); (2) the decrypt policy
reverted to plaintext-pass-through → the policy pin fails (the row
lands); (3) the push seam reverted to ship plaintext → the
mirror-ciphertext pin fails (and the decrypt side of the same suite
catches its own plaintext echo — the two halves police each other). All
three reverts restored; the suite re-run green.

**Own test-run lines (verbatim):**
- The sync-adjacent set (22 suites incl. the two new ones):
  `Test run with 126 tests in 22 suites passed after 0.801 seconds.`
  (pre-crown; the crown suite adds 3 more:
  `Test run with 3 tests in 1 suite passed after 0.155 seconds.`)
- Registry/DDL walks: `Test run with 31 tests in 3 suites passed`.
- Full core suite: **PENDING — run after this record lands (the
  repo-first rule); expected 1094 + 14 new = 1108 tests / 120 suites.**

**PROVISIONALs / deviations (recorded reasons):**
- `plainColumns` added beside the brief's `encryptedColumns` — reason
  above (the walk cannot build-fail otherwise). Not PROVISIONAL: it is
  the only shape satisfying the brief's own build-failing mandate.
- Classification deltas from THE DESIGN: NONE.
- The engine's `keyProvider` parameter is DEFAULTED (to the refusing
  provider) rather than required — deliberate: zero `App/` lines is a
  hard boundary, `SyncSession.swift` constructs the engine, and the
  default IS the mandated post-14b behavior (refuse until enrolled).
  Batch 3 replaces the default at the construction site.
- PROVISIONAL (small): keys are checked BEFORE the §12 lockstep probe
  (cheaper refusal — no network when locked; either order satisfies the
  refusal contract). If the ladder prefers §12 primacy, it is a two-line
  swap.
- `SupabaseIntegrationTests` (env-gated, real mirror) untouched: it now
  inherits the harness test key, so a deliberate env-gated run against
  the PRODUCTION mirror would push test-key ciphertext — and would in any
  case refuse at the §12 gate until 08 deploys (marker 4 ≠ 5). The gate's
  runbook owns when/how that pass runs post-deploy (real keys land with
  batch 3's vault client).

**Recorded-not-done (owed onward):** the vault PostgREST client, Keychain
custody, enrollment/setup flows, CHANGE PASSPHRASE, the (re)generate
surface (batch 3 — L8/L9); `resyncReinitialize` productized behind an
announced door (batch 3 — L10); the bridge journal-class capability +
touchpoint #2 concrete facts (batch 3 — L11); phone KDF latency (L12);
the deploy of 08 + marker 5 (the ARCHITECT's gate act, never this
session); no push to origin (the architect pushes after verification).

**Batch 3 — vault client, setup/enrollment UX, the bridge capability, the
runbook.**
1. Vault PostgREST client (authenticated reads/writes on `key_vault`;
   single-flight; typed refusals) + Keychain custody (per-device; distinct
   service; the R-6 future-biometric door left open and noted in code).
2. The shared setup + enrollment flows (Mac AND phone through the one seam,
   the 14a `AccountView` precedent): passphrase choose + the ONE honest
   warning (wording drafted for her gate ratify) + phrase display/confirm;
   enrollment passphrase-unwrap; the sync status face's locked-state line;
   **CHANGE PASSPHRASE** (authorized by the current passphrase OR the
   recovery phrase — re-wrap master, vault row update, recovery words
   untouched) and the phrase surface built as **(RE)GENERATE** (first
   generation and future regenerate are one flow; the Round-7 addition).
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

### Round 7 — passphrase confirmation + the change-passphrase scope addition
### (mid-sitting, 2026-08-04; recorded before Round 6 chronologically-adjacent)

Her message, in substance: she made her passphrase but could only enter it
once with no verification — asked for a confirm-twice script; asked whether
a mistyped passphrase is disastrous given the recovery words; and asked
"will we be adding something this phase to be able to change your
passphrase with the recovery words if needed?"

1. **Confirm-twice script given** (her own Terminal, `read -s` twice,
   compare, only a match writes the file — overwrites her single-entry
   version).
2. **A typo would NOT be disastrous — the mechanism, recorded:** the
   overnight setup wraps master with whatever the file holds, and the Mac
   keeps master in its KEYCHAIN — so the morning phrase generation works
   regardless, and a suspected typo is fixed by a cheap re-wrap (set a new
   passphrase while master is held) with nothing lost. Local plaintext
   truth is never at risk in any arm. The confirm-twice script exists so
   this road is never needed.
3. **SCOPE ADDITION at her ask (binding on batch 3): CHANGE PASSPHRASE
   ships THIS PHASE** — authorized by EITHER the current passphrase OR the
   recovery phrase (the forgot-passphrase road: phrase-unwrap master →
   new passphrase wrap; recovery words UNCHANGED by a passphrase change —
   independent wraps). The morning phrase-add flow is built as
   (RE)GENERATE RECOVERY PHRASE — the same surface serves first-generation
   and a future regenerate (old recovery wrap replaced). Ledger row L9
   widens to carry both; the restore drill (gate step 6) exercises the
   phrase-unwrap mechanics this rides on.

### Round 8 — her goodnight confirmation (2026-08-04, the sitting's close)

Her message, verbatim: *"ok great - i've put in my passphrase, you have my
permission for everything that should be needed overnight (and I'll see if
something does block it anyway), we added something valuable to the scope
that's standard and should be there anyway, and in the morning i'll
hopefully be ready to save my 12 recovery words, test them out, and try out
the passphrase on teh phone build! goodnight and I can't wait to see what's
been built tomorrow."*

Recorded: the passphrase file VERIFIED PRESENT (existence + `600` perms +
gitignore only — contents untouched, the arrangement's discipline); her
BLANKET OVERNIGHT PERMISSION is explicit and covers the Round-5 conditional
production tail (still gated on the ladder closing clean, and every
production step still logs its before/after states); the morning remains:
recovery words (generate → write → confirm) → the phrase drill → the phone
build (the mobile project's morning merge, Round 6 item 3) → the two
ratifies → the passphrase file's announced deletion.

**Batch-1 verification (the architect's own, post-record):** commits
`ad7bbc7`/`ed30c3a`/`48f365a` spot-checked against their claims; the
`Sync/`+`App/`+`Server/` scope diff EMPTY; the four suites re-run green
(55/4, own run; KDF 0.573s median); the implementer's advisory flag
RESOLVED — Mac AND mobile Xcode builds of the app against the new package
target both BUILD SUCCEEDED (the C target + resource bundle wire correctly
at the app level). Batch 2 spawned.

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
| L1 | Vendored CArgon2 + wordlist (own commit; R-7 approval recorded) | **done — batch 1** (`ad7bbc7`; pins f57e61e1 / e7263a4c, batch record above) |
| L2 | `Crypto/` module: KDF · RecoveryPhrase · KeyVaultFormat · PayloadCipher, vectors + tamper arms | **done — batch 1** (`ed30c3a`; 55 tests/4 suites; full core 1094/118 green; Mac KDF latency 0.583 s median; Round-5 wrap-addition included) |
| L3 | `SyncSchema` classification + completeness walk | **done — batch 2** (`f8d76ec`; plain+encrypted explicit per table, THE DESIGN's 18 columns exactly, walk build-failing, doctored red proof) |
| L4 | The serializer seam (encrypt-out/decrypt-in incl. reject-merge) | **done — batch 2** (`a4b5765`; SyncEncryption.swift + 3 engine edit sites; Merge/Repairs/transports ZERO-diff — proven on the batch diff) |
| L5 | Key-provider gating + visible refusal | **done — batch 2** (`a4b5765`; keys-first refusal, zero network contact, §12-shape pins, status names the fix; all refusal pins revert-verified red) |
| L6 | Convergence suites GREEN over ciphertext + mirror-dump assertion + re-init harness scenario | **done — batch 2** (`a4b5765`+`a8c69c5`; 22-suite sync set green over ciphertext; total-dump walk pinned to full classification coverage; wipe keeps seq monotonic, fresh device onboards byte-identical) |
| L7 | `08_phase14b_lockstep.sql` + `lockstepVersion` 5 (same commit; deploy at gate) | **done — batch 2** (`96b1e88`, the standalone schema commit; AUTHORED + PINNED, deploy remains the architect's gate act) |
| L8 | Vault client + Keychain custody | pending — batch 3 |
| L9 | Setup/enrollment flows, BOTH form factors (PL-6) + CHANGE PASSPHRASE (current-passphrase OR recovery-phrase authorized — her Round-7 scope addition) + the (re)generate-recovery-phrase surface | pending — batch 3 |
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
