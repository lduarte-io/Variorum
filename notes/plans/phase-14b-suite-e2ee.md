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
harness BEFORE production. Server-side: truncate the eighteen data tables
(never `auth.*`, never `key_vault`, never `sync_meta`) via a committed SQL
artifact executed at her explicit go behind the A1 rail (+ a mirror export
for belt-and-braces) — `Server/supabase/maintenance/14b-mirror-truncate.sql`,
authored at ladder R1-1 and pinned table-for-table to the registry. The global `server_seq` sequence is NOT reset
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
- Full core suite (run after this record landed, per the repo-first
  rule): `swift test` → **“Test run with 1108 tests in 120 suites passed
  after 29.384 seconds.”** — baseline 1094/118 + exactly the 14 new tests
  (3 SyncSchemaTests walks · 2 AuthRLSDDLTests vault pins · 6
  SyncEncryptionTests · 3 SyncMirrorDumpAndResyncTests) in 2 new suites;
  zero pre-existing tests deleted, the updated ones listed above.

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
   never reachable casually). **The door, concretized by the architect
   before batch 3 (the Round-5 tail's executor): a headless maintenance
   EXECUTABLE (`vault-bootstrap`, a new Package.swift executable target —
   never linked into any app).** Inputs: the real-store path · the
   passphrase-file path (bytes = passphrase, one trailing newline
   stripped; file never printed) · project coordinates · a SHORT-LIVED
   access token handed in by the architect (minted at the gate via the
   announced Management-API admin road — generate-link → verify — so the
   runner stays pure client machinery and holds no PAT). Acts, each
   logged: create the vault row via PostgREST (passphrase wrap ONLY per
   Round 5; REFUSES if a vault row already exists — idempotence by
   refusal, never overwrite) OR unwrap an existing vault; then
   `resyncReinitialize` on the store; then engine rounds until the outbox
   drains; keys live in memory only and die with the process (the app
   enrolls from the vault in the morning — Keychain custody is the APP's
   act, never the runner's). A `--dry-run` mode prints the plan without
   writing. The runner's own tests script its refusal arms; the
   live-production run is the gate's, behind the A1 rail.
4. `BridgeEngine` journal-class capability (encrypt push / decrypt land;
   rounds stay paused) + the touchpoint #2 contract-block update with the
   concrete format facts + the phone KDF latency measurement (R-7's
   condition) + the disclosure list finalized for the gate.
5. Tests: vault client round-trips against a scripted server; enrollment
   state machine incl. wrong-passphrase (KDF-derived key fails unwrap →
   speaks, never crashes), checksum-failing phrase, vault-absent,
   vault-newer-format arms; bridge capability round-trip over ciphertext;
   the spine + both suites green.

### Batch 3 — record (implementer session, 2026-08-04)

**What shipped (four commits — `80f2204` vault client + custody · `363d0b6`
the flows + L12 · `e4e9908` the runner · `80a6e5e` the bridge capability +
contract facts):**

- **L8 — the vault client + Keychain custody.** `KeyVaultClient` (Crypto/,
  an actor): authenticated PostgREST on `key_vault`, columns 1:1 with 08's
  DDL (`KeyVaultWireRow`), SINGLE-FLIGHT fetch (concurrent reads coalesce
  onto one request, pinned), typed refusals — `vaultAlreadyExists` (create
  never overwrites; PostgREST 409 = the PK backstop), `vaultAbsent` (update
  never invents), `unsupportedFormatVersion` (refuse-by-version at fetch —
  a newer vault is never guessed at), `malformedRow` — and the 9c auth
  posture verbatim (signed-out refuses before composing; ONE 401
  refresh-and-retry, pinned). The row's `user_id` is ALWAYS the session's
  user, never caller-supplied. Custody: `E2EEKeychainStorage`
  (App/Shared — the 9c `KeychainAuthStorage` pattern, its own service
  `io.lduarte.Variorum.e2ee-keys`, `AfterFirstUnlock`), the
  `DeviceKeyStore` seam (in-memory for every test — no test touches the
  real Keychain), and **the R-6 future-biometrics door left open and
  documented in the file's header comment** (a SecAccessControl on the one
  item — policy on the item, never format). `DeviceKeySyncProvider` is the
  REAL engine provider (batch-2 PROVISIONAL 2 resolved): reads custody per
  round, so enrollment heals with no re-composition and a cleared device
  refuses in the engine's own grammar.
- **L9 — the shared flows.** `VaultEnrollment` (core — the ONE brain the
  Mac app, the phone, and the runner share): `setUp` (passphrase wrap ONLY,
  Round 5), `enroll(passphrase:)` / `enroll(recoveryWords:)` (both roads;
  wrong-passphrase and every phrase-validation arm SPEAK, never crash),
  `landRecoveryWrap` (the CONFIRMED words land; first generation rides
  batch-1's strict `addingRecoveryWrap`, replacement rides the NEW
  `replacingRecoveryWrap` behind an explicit `allowReplace` — batch-1's
  PROVISIONAL widened exactly as its record predicted, the Crypto addition
  recorded in-code), `changePassphrase(authorizedBy: passphrase|recovery,
  newPassphrase:)` (Round 7: fresh salt + descriptor, master re-wrapped,
  recovery words UNTOUCHED — pinned; the recovery road returns material,
  so forgot-passphrase both fixes and enrolls). App-side:
  `EncryptionSession` (@Observable state projection + the wording every
  refusal speaks) and `EncryptionView` (ONE shared functional surface,
  the AccountView precedent: setup with the ONE honest warning + the
  sub-12-character caution; enrollment with the phrase road; the 12 words
  shown ONCE and confirmed by full re-entry per Round 5 item 3's order;
  regenerate behind a confirmationDialog; change-passphrase with the
  forgot-it toggle). The sync status face gains the LOCKED-STATE line
  ("Sync locked — enter your encryption passphrase" + the Unlock… door;
  the classifier matches `SyncError.encryptionKeysUnavailable`'s surfaced
  description EXACTLY — a substring match would swallow unrelated errors)
  and the Encryption… door beside Account… (Round 6 item 2's home; the
  phone reaches both through MobileSettingsView's same shared row).
  `SyncSession.configure` gains a REQUIRED `keyProvider:` (deliberately
  not defaulted at THIS seam — every composition site decides, the
  required-`redo:` precedent); `AppServices` wires
  `DeviceKeySyncProvider` + composes `EncryptionSession` over the same
  auth session the transport rides, and key-landing triggers one healing
  round.
- **L10 — the runner.** `vault-bootstrap`: a new Package.swift
  **executableTarget** (Tools/VaultBootstrap — never linked into any app;
  no new dependencies, hand-rolled argument parsing) over the core
  `VaultBootstrap` brain (Crypto/ — testable, injectable client/transport/
  log). Exactly the concretization: store path (must EXIST — a typo can't
  mint an empty store) · passphrase-file path (bytes = passphrase, ONE
  trailing newline stripped at the BYTE level — `\r\n` is one grapheme to
  Swift, found by the pin's first run; never printed, never logged —
  pinned) · project coordinates · the short-lived access token (its `sub`
  read locally for session composition only — RLS is the authority). Acts
  logged step-by-step: create-vault (passphrase wrap ONLY; an existing row
  takes the unwrap arm and is NEVER overwritten; the fetch-create race
  lands on the 409 refusal) or unwrap-existing → `resyncReinitialize` →
  pull→push rounds until the outbox drains (bounded at 50;
  `outboxNeverDrained` refuses to claim success). Keys die with the
  process — the runner target and its brain contain no Keychain code by
  construction. `--dry-run` logs the plan (arm included — a read) and
  writes NOTHING (pinned: no vault, no enqueue, no push). Run-too-early
  self-defense noted in code: pre-truncate plaintext meets the decrypt
  seam's policy refusal — cursor unmoved, nothing lands.
- **L11 — the bridge capability, PAUSED.** `BridgeEncryption.swift` (new,
  Bridge/): `BridgeKeyProviding` (a SEPARATE protocol from the sync seam,
  deliberately — R-8's letter: the bridge only ever touches the
  journal-bridge class) with the refusing `UnenrolledBridgeKeyProvider` as
  `BridgeEngine`'s DEFAULT — **the pause is STRUCTURAL**: the app wires no
  real bridge provider this phase (the 14c-end batch does, when Fragments
  can read ciphertext), so every bridge round refuses visibly
  ("Bridge paused: …", the §12 grammar) BEFORE any network contact, and
  no plaintext-push code path exists anymore. Keys-first in BOTH halves;
  encrypt-on-push at the wire (inland hashes/day-state/discrimination all
  stay plaintext — the sync seam's boundary design; the empty body seals
  too, the deletion semantic now client-side); decrypt-on-land for pulled
  bodies AND `replaced`-receipt bodies (opened BEFORE discrimination — a
  rescue lands words; an unopenable receipt body preserves durably
  VERBATIM under the never-throw doctrine; a tombstone's body is never
  read, left verbatim). **The AAD convention, designed and recorded
  (touchpoint #2):** `UTF-8("journal_entries:<date>:body:<key_id>")` —
  the DAY is the binding (the join key; a ciphertext cannot move between
  days), the key id is the vault's `journal_bridge_key_id`; the suite's
  one `table:rowID:column:keyID` grammar with the day in the rowID slot.
  **The legacy rule (PROVISIONAL, recorded reasons):** a non-`e1:` body
  LANDS as legacy plaintext — `journal_entries` is never wiped (no R-2
  analog), pre-E2EE rows and interim writes are historical data, and
  refusing them would jam the cursor on exactly the transition the
  one-batch handoff executes; a tampered `e1:` body still refuses the
  round with the cursor held (nothing unauthenticated ever lands). THE
  BRIDGE CROWN: the ENTIRE existing bridge suite set runs GREEN over
  ciphertext (105 tests / 9 suites — the harness binds the fixed journal
  key; server-body assertions open at the edge; the receipt rules (i)–(iii)
  compose over ciphertext unchanged). The contract file's TOUCHPOINT #2
  block gained the concrete facts ADDITIVELY (AEAD · encoding · AAD ·
  key-id source · the full vault unwrap chain incl. the recovery road's
  constants · the legacy posture · the trim/empty-body-as-deletion
  client-side relocations · the nonce-vs-receipt behavioral note).
- **L12 — the phone KDF latency.** The mobile suite gains
  `MobileKDFLatencyTests` — v1-descriptor derivation measured ON THE
  SIMULATOR: **0.686 s** (iPhone 17 Pro sim; run green under the locked
  session). **A SIMULATOR NUMBER IS NOT THE DEVICE NUMBER** — the device
  number lands at the gate through the enrollment flow itself, which
  measures every derivation and shows it on its own surface
  (`EncryptionSession.lastKDFSeconds` → the enrolled section's caption +
  os_log `io.lduarte.Variorum`/`e2ee`), so the gate reads it off the
  phone screen at step 5.
- **L13 — the GATE RATIFY block** (below, after this record): the setup
  warning wording as shipped in `EncryptionView.setupWarning` + the
  passphrase recommendation + the disclosure list (unchanged from THE
  DESIGN — batch 2 shipped it with zero deltas; restated for her one-look
  ratify).

**The hallucination guard — revert-verified red, each mechanism traced:**
(1) the bridge keys gate reverted to guess-a-key → the pause pin fails all
four ways (rounds run, transport contacted); (2) the push seam reverted to
ship plaintext → the ciphertext-on-the-wire pin fails; (3) the land seam
reverted to raw bytes → the encrypted-write-lands pin AND the tamper-refusal
pin fail (raw ciphertext lands — the exact disaster); (4) the receipt seam
reverted to raw → the encrypted-receipt rescue pin fails (a ciphertext take)
and the unopenable-receipt pin fails (rescuedReceipts 1, no preservation).
All restored; suites re-run green. App-side: the locked-provider pin
(refusal status + ZERO transport calls) fails without L9's plumb-through by
construction (a dropped provider = the working default the test never
installs); the existing wiring pins (`syncTransport.calls > 0`) are the
other direction of the same seam.

**Environment finding (binding on the acceptance below): the Mac GUI test
runner cannot run in the CURRENT locked login session** — the 13b-recorded
class, reproduced THREE times (~343 s "hung before establishing connection"
/ "timed out while preparing"), including on the untouched control suite
`StoreLocationTests` and after a `caffeinate -u` display wake — the diff is
not the cause. (13k-era locked runs succeeded, so the lock STATE matters,
not the lock alone; whatever state the session is in tonight blocks the
host.) What IS proven: the Mac test bundle COMPILES (the hung runs build
everything and reach "Testing started"), both app targets BUILD SUCCEEDED
(Mac + iPhone sim), and the SIMULATOR runs tests fine (the mobile suite
executed green). The Mac suite + the spine (which rides the Mac host)
carry PENDING below for the architect's unlocked window.

**Acceptance (the full pre-ladder set — finalized):**
- Core `swift test` from the repo root: **“Test run with 1146 tests in 124
  suites passed after 30.814 seconds.”** — baseline 1108/120 + 23/2 vault
  + 8/1 runner + 7/1 bridge, EXACTLY accounted; zero pre-existing tests
  deleted (the updated bridge assertions listed in the L11 commit).
- Mac suite: **BLOCKED — the locked-session runner hang** (the environment
  finding above; a FOURTH control probe failed identically after the other
  suites ran). What stands in its place, explicit:
  **“** TEST BUILD SUCCEEDED **”** (`build-for-testing`, the whole app +
  VariorumTests bundle) and the app build's **“** BUILD SUCCEEDED **”**.
  Expected at the unlocked window: 1196/208 + 4 EncryptionFlowTests + 2
  SyncLockedFaceTests in 2 new suites = **1202/210**, the standing TakePane
  tripwire the one allowed red.
- Mobile suite (iPhone 17 Pro sim): **“Test run with 173 tests in 25
  suites passed after 4.871 seconds.”** — baseline 172/24 + the KDF
  latency suite, exactly accounted.
- The spine (7 Tutorial suites, 51/7): **BLOCKED — rides the Mac host,
  same finding, same window.**

**PROVISIONALs / deviations (recorded reasons):**
- **PROVISIONAL (bridge):** the legacy-plaintext land rule (above — the
  most spec-defensible reading; the refuse alternative jams the cursor on
  the handoff's own transition). One residual corner recorded *(restated
  at ladder R2-2 to match shipped post-R1-4 behavior)*: a pre-handoff
  plaintext body beginning with ANY `e<digits>:` prefix — a literal
  `e1:<valid base64>` shape refuses as tamper, and e.g. a Day entry
  starting "e2: second draft…" refuses as `unsupportedVersion` — refuses
  the round at resumption, cursor held: visible, not silent, nothing lost,
  fixed by editing the entry; narrow, and the refuse direction is the
  R1-4 disposition's own choice.
- **PROVISIONAL (small):** `EncryptionSession.isKeysLockedError` matches
  the refusal description EXACTLY (equality, not substring) — a wrapped or
  translated error would fall back to the generic error face, never hide.
- `SyncSession.configure`'s `keyProvider:` is REQUIRED, not defaulted —
  deviation from batch-2's defaulted-engine-parameter shape, deliberate:
  the app seam is where composition decides (the required-`redo:`
  precedent); the ENGINE keeps its refusing default.
- `KeyVaultClient`'s load-injectable init is PUBLIC (unlike the transports'
  internal seams): the App-layer flow tests script vault responses via
  public API only (App tests import VariorumCore non-@testable); recorded
  in-code.
- The runner picks its arm automatically (absent → create, present →
  unwrap) per the plan's own "create … OR unwrap-existing"; the
  create-refusal guards the race, not the arm choice.
- The drift-arm receipt (id ≠ pushed id) preserves its body VERBATIM —
  under E2EE that may be ciphertext under an unknowable day binding; raw
  preservation is the honest form (the never-throw doctrine holds).
- Batch-2's PROVISIONAL (keys-before-lockstep probe order) untouched, as
  assigned to the ladder.

**Scope proof:** `git diff bdf3c41..HEAD -- Sources/VariorumCore/Sync/
Vendor/ Server/` is EMPTY — zero engine-seam lines, zero vendored lines,
zero server artifacts this batch (SyncSession is App/Shared). No new
dependencies (the executable target depends on VariorumCore alone). No
schema.

**Recorded-not-done (owed onward):** the Mac suite + spine EXECUTION (the
locked-session block above — the bundle compiles; the architect runs them
at an unlocked window, or this session re-runs if the session unlocks);
the LIVE phone KDF number and the enrollment drill (the gate, steps 5–6);
the deploy of 08/marker 5 + every production act (the architect's, per
Rounds 4/5); no push to origin (the architect pushes after verification).

### GATE RATIFY (L13 — her one-look ratify at gate step 8)

**The ONE honest setup warning (as shipped in `EncryptionView`):**

> This passphrase is not your account password, and it is never sent
> anywhere. Variorum cannot reset it and cannot read your writing without
> it — there is no "forgot passphrase" email, by design. If you lose the
> passphrase and your 12-word recovery phrase, everything you've synced is
> unreadable forever.

**The recommendation line beside it:** "Use a long passphrase: four or more
random words, or 16+ mixed characters — and never a password you use
anywhere else." (Plus the soft caution under 12 characters — never a hard
block, per Round 6.)

**The disclosure list (what the server still sees under E2EE — unchanged
from THE DESIGN; batch 2 shipped the classification with ZERO deltas):**
`entry_date` (which days carry entries) · timestamps · positions/order ·
kinds/status/profile enums · lock flags · the structural graph (ids,
edges, memberships) · payload sizes and write cadence · `setting` values
(enum semantics, no prose) · canvas x/y (spatial metadata). Everything
user-authored encrypts — the eighteen columns: variant.working_text ·
variant.label · commit_point.text · commit_point.message · block.name ·
block.presentation · container.title · container.floating_notes ·
reading.name · reading.query_spec · reading_section.name · tag.name ·
tag.path · block_comment.text · reference.name · reference.url ·
reference.view_state · lens.name. (The bridge adds: `journal_entries.body`
ciphertext on the Fragments side; its `date` column stays plaintext,
disclosed.)

**Batch-3 verification (the architect's own, post-record):** tree clean;
six commits matching their claims; inland scope (Merge/Repairs/Vendor)
EMPTY; the contract edit verified purely additive (+62 lines inside
touchpoint #2); **full core suite re-run by the architect: 1146/124
PASSED** (the second stale-SourceKit burst again refuted by CLI). **THE
ACCEPTANCE HOLD, independently confirmed:** the architect's own bounded
probe on the UNTOUCHED control suite (`StoreLocationTests`) hung past 300 s
under the locked login session — the implementer's environment finding
reproduced exactly (the 13b-recorded GUI-runner class; the wedged probe
stopped cleanly, instance check clean). **Mac suite (expected 1202/210,
tripwire-only) + spine (51/7) execution is HELD FOR THE MORNING'S UNLOCKED
WINDOW and is a PRECONDITION for the wipe/repush and the `/Applications`
refresh** — build-for-testing compiles green, core + mobile CLI suites
green, so the hold is environmental, not a code signal. The overnight tail
narrows accordingly: ladder overnight; deploy of `08` (additive, zero data
risk) if the ladder closes clean; wipe · repush · refresh · everything
her-facing rides the morning.

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

**Batch-2 verification (the architect's own, post-record):** tree clean;
the six commits match their claims; the inland scope diff
(Merge/Repairs/Transports/Scheduler + App + Bridge + Crypto + Vendor)
EMPTY as promised; **full core suite re-run by the architect: 1108 tests
in 120 suites PASSED** (a burst of stale SourceKit diagnostics against the
new registry members was refuted by the CLI run — the committed tree is
consistent); `08_phase14b_lockstep.sql` spot-read approved (nullable
recovery wrap per Round 5, owner-only RLS on auth.uid(), NO delete door —
vault removal is an account-deletion-scale act, 14c's; the marker bump
deliberately the file's last statement; deploy remains the architect's
gate act). The implementer's two PROVISIONALs stand for the ladder
(keys-before-lockstep probe order; the defaulted refusing key provider —
batch 3 wires the real provider at the app's construction site). Mac +
mobile app builds against the new engine init running as the architect's
background check; batch 3 spawned in parallel (its first act is reading,
not compiling).

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

### Cold-review ladder — ROUND 1 (2026-08-05 overnight; fresh Fable
### reviewer, REVIEW_PROMPT verbatim, zero implementation context)

**Verdict: NO BLOCKER — 1 MAJOR + 3 MINOR + 5 NIT.** The reviewer's own
runs: core 1146/124 green, mobile 173/25 green (Mac suite + spine honored
the recorded environment hold). All four standing PROVISIONALs dispositioned
ACCEPTED by the reviewer (keys-before-§12 order; the engine's defaulted
refusing provider resolved at the app seam; the bridge legacy-plaintext
land rule — with R1-4 below as its needed refinement; the exact-match
locked classifier). Findings + architect dispositions (adjudicated against
the spec docs; the implementer sessions are dead, so dispositions are
architect-direct):

| # | Sev | Finding (condensed — the reviewer's full mechanism is the record) | Disposition |
|---|-----|-------------------------------------------------------------------|-------------|
| R1-1 | MAJOR | The committed mirror-truncate artifact DOES NOT EXIST (THE DESIGN promises it; gate step 4 names it; `Server/supabase/` holds only 01–08) and THE DESIGN says "sixteen data tables" — the registry has EIGHTEEN. A table skipped at truncate keeps plaintext rows the decrypt seam then refuses on every pull — a permanent cursor wedge (the run-too-early class made durable). Unowned gap — the no-blank-owner smell. | CONFIRMED — fix: author `Server/supabase/maintenance/14b-mirror-truncate.sql` (one TRUNCATE of exactly the 18 registry tables; NEVER `key_vault`/`sync_meta`/`auth.*`; header states it is the R-2 one-time gate act, not schema choreography — the numbered chain stays schema-only); pin its table list EQUAL to `SyncSchema.tables` in `AuthRLSDDLTests` (the DDL-pin shape — the artifact-class red-on-old); correct "sixteen"→"eighteen" in THE DESIGN. |
| R1-2 | MINOR | `key_vault` read-modify-write is last-writer-wins (no version token): a cross-device race can silently revert a vault change — worst arm: a freshly REGENERATED recovery phrase reverted to the discarded words (the written phrase stops working, the discarded one works). First-generation arm accidentally protected by Codable nil-omission. | CONFIRMED — and fixed NOW while 08 is UNDEPLOYED (zero-cost moment; 14c provisions strangers on this table): 08 gains `revision integer not null default 1`; the client PATCHes with a `revision=eq.<fetched>` filter + sets `revision+1`, zero-rows-updated ⇒ typed conflict refusal (refetch, never blind-retry) — the house CAS shape. Red-on-old via the ScriptedVault interleaving; the nil-omission subtlety stated in the fix's tests. |
| R1-3 | MINOR | `SupabaseIntegrationTests` post-deploy becomes a production sync-wedge foot-gun: env-gated run pushes TEST-KEY-sealed rows to the real mirror; her devices' next pull jams permanently at `payloadCryptoFailure` (park/heal deliberately Phase 12). | CONFIRMED — fix: the test additionally requires an explicit `VARIORUM_INTEGRATION_ALLOW_TEST_KEYS=1` opt-in (skip otherwise, message naming why); the gate's live dump verification is the sanctioned real-server pass. |
| R1-4 | MINOR | The bridge lands FUTURE-version ciphertext (`e2:…`) verbatim as journal text (the `isEncrypted` exact-`e1:` guard bypasses `PayloadCipher.open`'s `unsupportedVersion` arm the sync seam honors) — ciphertext soup becomes the day's text. | CONFIRMED — fix: route landed bodies through `PayloadCipher.open`; pass through ONLY on `.notEncrypted`; `unsupportedVersion` refuses the round, cursor held. Red-on-old: the `"e2:AAAA"` pin (lands today, refuses after). |
| R1-5 | NIT | THE DESIGN's "new `sync_state` keys carry enrollment state/key ids" was never built — custody went wholesale to the Keychain (the better shape), deviation unrecorded. | CONFIRMED — a closeout deviation note (no code change). |
| R1-6 | NIT | `VaultEnrollment.material(from:)` throws `unknownClassKey(.corpus)` even when journal-bridge is the missing key — the refusal misnames the offender. | CONFIRMED — fix with the trivial arm. |
| R1-7 | NIT | `SyncSchema.swift:75` header comment still says "The 13 synced tables" above the 18-table array. | CONFIRMED — fix the comment. |
| R1-8 | NIT | The runner's access token rides argv (`ps`-visible). Architect-run + short-lived. | CONFIRMED — add `--access-token-file` (argv form retained; the gate uses the file form). |
| R1-9 | NIT | The disclosure list's `setting`-values promise is column-fenced, not row-fenced — a future prose-valued setting KEY would travel plaintext with no tripwire. | CONFIRMED — one sentence in AppSpec §7's setting conventions AT CLOSEOUT (canonical-doc changes ride the ritual), noted on the closeout list. |

**Route: R1-1–R1-4 + R1-6/R1-7/R1-8 → ONE fresh fix implementer session;
R1-5/R1-9 → the closeout list. ROUND 2 re-reviews the fixes with a fresh
reviewer. The 08 deploy HOLDS until round 2 closes (R1-2 amends 08
itself — deploying pre-fix would turn a free column into a ninth lockstep
file).**

### Ladder fix record (round 1 → 2) — fix implementer session, 2026-08-04

**Commits:** `be33974` (schema artifacts — the R1-1 truncate artifact +
R1-2's 08 amendment, one commit per the route's allowance) · `1c0b9d2`
(the code fixes + pins + THE DESIGN's sixteen→eighteen correction).

**Per finding — what changed, and the revert verification:**

- **R1-1 (MAJOR) — FIXED, artifact-class red verified.**
  `Server/supabase/maintenance/14b-mirror-truncate.sql` authored: ONE
  `truncate table` statement over EXACTLY the eighteen registry tables
  (`SyncSchema.tables`), deliberately OUTSIDE the numbered chain (header
  states the R-2 one-time gate-act posture — no marker, not schema
  choreography, A1 rail + mirror export + her go; no `restart identity`,
  SyncSpec §9). Pin: `AuthRLSDDLTests.theMirrorTruncateArtifactMatches
  TheRegistryExactly` — a pure `truncateProblems` check (missing/extra/
  forbidden/statement-count) asserted empty against the parsed artifact,
  order-insensitive vs the registry, provably free of
  `key_vault`/`sync_meta`/`auth.*`, single-statement, no marker.
  **Red-on-old:** (a) artifact-absent — the pre-fix state — pin run with
  the file moved aside: FAILED (`NSCocoaErrorDomain 260`, no such file);
  restored: passes. (b) the doctored-fixture proof
  (`aDoctoredTruncateListIsFlaggedByTheCheck`) pins that the check bites
  on a skipped registry table AND on a forbidden `key_vault` entry —
  the two R1-1 failure classes, never a vacuous pass. THE DESIGN's
  "sixteen data tables" corrected to "eighteen" with a pointer to the
  artifact.
- **R1-2 (MINOR) — FIXED, revert-verified BOTH assertions.** 08 (still
  UNDEPLOYED — the sanctioned moment) gains `revision integer not null
  default 1`, marker still the last statement; the DDL pin gains the
  column + its default. Client CAS, the house shape:
  `KeyVaultClient.fetchVault` now returns `FetchedVault` (format + the
  revision token — they travel together so an update derived from a
  fetch carries THAT fetch's token); `updateVault(_:expectedRevision:)`
  PATCHes behind `revision=eq.<fetched>` and writes fetched+1; zero rows
  disambiguates by re-read into `vaultAbsent` vs the NEW typed
  `vaultRevisionConflict` (doc + app wording both say refetch-and-
  re-derive, never blind-retry). Wired through `VaultEnrollment`
  (`landRecoveryWrap`, `changePassphrase` — the two update doors) and the
  app seam; the bootstrap brain performs NO updates (create-or-unwrap
  only), verified, so nothing to wire there. The wire row's `revision`
  decodes-if-present with default 1 (the server column default; encoding
  stays synthesized so the recovery wrap's NIL-OMISSION is preserved).
  `ScriptedVaultServer` models the filter AND PostgREST's
  keys-present-only PATCH merge (an absent filter matches any revision —
  exactly PostgREST, which is what lets the behavioral revert reproduce
  the pre-fix arm). **Red-on-old (behavioral revert — the
  `revision=eq.` filter dropped from `updateVault`, run, restored):**
  `aStaleFetchUpdateAfterARegenerateRefusesInsteadOfRevertingThePhrase`
  FAILED both ways the finding predicted — no conflict thrown AND
  `wrongRecoveryPhrase` on the freshly WRITTEN phrase (the discarded
  words had silently won); `aStaleRevisionUpdateRefusesTypedWithout
  Writing` failed beside it. Restored: both pass. **The nil-omission
  subtlety pinned as knowledge**
  (`codableNilOmissionIsWhyTheFirstGenerationArmWasAccidentallySafe`):
  the stale no-wrap row's PATCH body carries NO
  `master_wrapped_by_recovery` key at all, which is why only the
  regenerate arm could ever clobber.
- **R1-3 (MINOR) — FIXED, test-only (no red-on-old owed).**
  `SupabaseIntegrationTests` now additionally requires
  `VARIORUM_INTEGRATION_ALLOW_TEST_KEYS=1`; the skip message names the
  test-key production-wedge mechanism (`payloadCryptoFailure`, park/heal
  Phase 12) and the gate's live dump verification as the sanctioned
  real-server pass.
- **R1-4 (MINOR) — FIXED, revert-verified.** `BridgeCrypto.openLanded`
  routes every landed body through `PayloadCipher.open`; the legacy
  pass-through rides ONLY the `.notEncrypted` arm — `unsupportedVersion`
  (and every other crypto failure) now refuses the round with the cursor
  held; the receipt half inherits the same behavior through its existing
  preserve-verbatim catch (an `e2:` receipt body now preserves durably
  instead of passing to discrimination as text). **Red-on-old
  (behavioral revert — the old exact-`e1:` guard restored, run,
  re-fixed):** `aFutureVersionCiphertextBodyRefusesTheRoundInsteadOf
  Landing` FAILED on all three assertions — the `e2:AAAA` body LANDED
  (created: 1), rendered as the day's text, cursor advanced. Restored:
  passes.
- **R1-6 (NIT) — FIXED.** `VaultEnrollment.material(from:)` splits the
  joint guard; each arm names the class it is actually missing
  (`.corpus` / `.journalBridge`). Trivial-arm per the disposition; no
  pin owed (the client's wire row makes the state unreachable through
  every live path).
- **R1-7 (NIT) — FIXED.** The `SyncSchema.tables` header comment now
  reads "The synced tables, in FK-dependency-friendly apply order" — no
  literal count to drift. The ONE `Sync/` line of this session
  (`git diff` on `Sources/VariorumCore/Sync/`: 1 insertion, 1 deletion,
  that comment).
- **R1-8 (NIT) — FIXED.** `vault-bootstrap` gains `--access-token-file`
  (bytes = token, ONE trailing newline stripped at the byte level via the
  shared helper, never printed/logged); `--access-token` retained;
  EXACTLY ONE of the two required (usage says so; violating it exits 2).
  The byte contract lives in the brain as
  `VaultBootstrap.accessToken(fromFileBytes:)` with typed refusals,
  tested beside the passphrase-file contract.

**Acceptance (all waits synchronous):**
- Core, full suite from the repo root: **“Test run with 1153 tests in 124
  suites passed after 30.752 seconds.”** — baseline 1146/124 + exactly
  the 7 new pins (2 truncate-artifact · 3 CAS · 1 bridge e2: · 1
  token-file), zero suites added, zero pre-existing tests deleted (the
  updated call sites: fetchVault's `.format` accessors + the two
  `updateVault(_:expectedRevision:)` signatures in the vault tests).
- Mobile (iPhone 17 Pro sim): **“Test run with 173 tests in 25 suites
  passed after 4.663 seconds.”** + ** TEST SUCCEEDED ** — baseline exact.
- Mac suite + spine: NOT attempted (the recorded locked-session hold —
  the architect's unlocked window). In their place, the sanctioned
  stand-in: **** TEST BUILD SUCCEEDED **** (`build-for-testing`, Mac app +
  VariorumTests bundle — the touched shared `EncryptionSession` compiles
  for both form factors).

**Deliberately not touched (recorded):** `BridgeEngine`'s receipt-half
comment still says "an unopenable `e1:` body" where R1-4 widened the
class to any `e<n>:` — behavior is correct (the catch preserves
verbatim), wording one revision behind; left for the round-2 reviewer or
closeout sweep rather than exceeding the findings' scope. R1-5/R1-9 ride
the closeout list per the route. No `Vendor/`, no deploy/dashboard
contact, no `.env*` reads, no push (the architect pushes after
verification).

### Cold-review ladder — ROUND 2 (2026-08-05 overnight; fresh Fable
### reviewer anchored on round 1's recorded findings + dispositions + the
### fix record)

**Verdict: EVERY ROUND-1 DISPOSITION HOLDS — ZERO NEW BLOCKER/MAJOR. THE
LADDER CLOSES AT ROUND 2** (round 3 is owed only on new HIGH findings).
The reviewer re-derived every mechanism itself: ran its OWN behavioral
reverts on all three behavior fixes (R1-2 — the filter dropped, the
regenerate-race pin failed on the finding's exact worst arm, the written
phrase dead; R1-4 — the pre-fix guard restored, the `e2:AAAA` body landed,
rendered, and advanced the cursor; R1-1 — the artifact-absent probe failed
the pin), re-ran the full core suite (1153/124, reproducing the fix
record's line), mobile (173/25), and confirmed the phase-wide inland
zero-diff with its own git evidence. All four standing PROVISIONALs
independently ACCEPTED. New findings, both NIT + one wording note, all
dispositioned by the architect at the close:

| # | Sev | Finding | Disposition |
|---|-----|---------|-------------|
| R2-1 | NIT | `key_vault.updated_at` is never maintained after insert (no trigger; the wire row omits timestamps) — a column whose name promises bookkeeping nothing writes. No consumer reads it. | CONFIRMED — fixed by the architect pre-deploy at the reviewer's offered docs option: 08 now states the column is INSERT-TIME-ONLY by design; the client-write one-liner is recorded on the closeout list as a 14c vault-generalization candidate (post-ladder code churn declined at 5 a.m. discipline). |
| R2-2 | NIT | The batch-3 PROVISIONAL note understates the post-R1-4 refusing set: ANY legacy plaintext body beginning `e<digits>:` refuses at resumption (visible, cursor held, fixed by editing the entry) — not just the literal-`e1:` corner. | CONFIRMED — the note corrected in place by the architect (the record now matches shipped behavior); the closeout restates the corner in the phase summary. |
| R2-3 | note | `BridgeEngine.swift:723`'s receipt-half comment says "an unopenable `e1:` body" where R1-4 widened the class to any `e<n>:` — wording one revision behind; behavior correct (catch-all preserve-verbatim). | Folded into the closeout hygiene sweep (a comment-only touch, batched there). |

**THE LADDER IS CLOSED. The Round-4/5 condition ("attempted ONLY if the
ladder closes clean") is SATISFIED — the overnight production tail may
proceed in its recorded order: A1 backup + mirror export → the 08 deploy →
after-state verification. The wipe · repush · refresh · everything
her-facing still rides the morning (the Mac suite + spine at the unlocked
window remain the wipe's precondition).**

### The overnight tail — EXECUTED (2026-08-04 ~06:55–07:05 local; post-ladder,
### per the Round-4/5 authorization and the recorded narrowing)

- **Gate step 1 — the A1 rail: DONE.** Instance check clean (pgrep, path-
  discriminated); WAL-safe backup `variorum-backup-2026-08-04-125511.sqlite`
  (UTC name, `PRAGMA integrity_check` = ok, 4,907,008 bytes) in the store's
  `Backups/` home. **Mirror export DONE beside it**
  (`Backups/mirror-export-2026-08-04-125511/`): all 18 data tables +
  `sync_meta` as JSON via the stored-PAT Management-API road, 19 files,
  3,954,986 bytes total (variant.json 1.4 MB — the corpus's shape as
  expected).
- **Gate step 2 — the 08 deploy: DONE.** Pre-state read first:
  `lockstep_version = "4"`. The committed
  `Server/supabase/08_phase14b_lockstep.sql` executed VERBATIM (body-file +
  curl; one road note: python-urllib's default user agent is
  Cloudflare-blocked on the Management API — 403 code 1010 — curl is the
  proven client). **After-state verified, every check:**
  `lockstep_version = "5"` · `key_vault` present with all 17 columns
  including `revision` · `relrowsecurity = true` · exactly the three owner
  policies (select/insert/update — NO delete, by design) · `key_vault`
  rows = 0. The installed marker-4 build now visibly refuses to sync BY
  DESIGN (outbox intact, cursor unmoved) — the accepted §12 consequence;
  her pause means no round was running; the refresh (pre-authorized)
  follows the morning's Mac-suite green.
- **THE OVERNIGHT RUN STOPS HERE, deliberately** (the recorded narrowing):
  the vault setup, wipe, repush, refresh, and every her-facing act ride
  the morning — the Mac suite + spine at the unlocked window are the
  wipe's precondition, and the runner's session token is minted at the
  gate, announced, not at 5 a.m.

### Her validation walk — findings + rulings (2026-08-04, at the gate; the
### COPY/FLOW ROUND's ledger — her announcement: "we'll get through
### validation and then ill give comments and we'll do a short copy / flow /
### etc. round"; the round runs IN-PHASE, after the gate, before closeout)

- **CF-1 (setup sheet):** "Done" (sheet dismiss) beside "Create Encrypted
  Vault" (the act) reads ambiguous — her report verbatim: "am I supposed to
  hit done or create encrypted vault? I think that's a little bit unclear."
- **CF-2 (the regenerate/change coherence question), her words:** "it's
  easy to regenerate your recovery phrase but changing your passphrase
  requires the recovery phrase, but you can just regenerate that instantly.
  i'm not sure what the actual goal is." The model's honest answer
  (explained in-sitting, to be made LEGIBLE at the round): an ENROLLED
  device already holds the master key — its gates are about deliberateness,
  not security against someone at the unlocked machine; the phrase's real
  job is the new-device/forgot-passphrase road. Round candidate: gate
  Regenerate behind the passphrase too, so the surface's story is coherent.
- **CF-3 (recovery-phrase entry discoverability):** her question "do you
  put in the recovery phrase, separated by spaces, instead of your
  passphrase?" — the ANSWER: no; "Forgot it? Authorize with the recovery
  phrase" is a BUTTON that reveals a dedicated 12-words field (spaces
  between words), but it renders like static hint text — the R94-family
  legibility miss; same pattern exists (correctly, with a visible button)
  on the enrollment screen.
- **CF-4 (the phrase-confirm box):** behavior verified GOOD by her (only
  the exact 12 words confirm; anything else rejects) but the STATE is
  unclear — "from the user perspective it looks like you can just exit if
  you want."
- **CF-5 — RULING: the recovery phrase becomes MANDATORY AT SETUP.** Her
  words: "It also seemed very optional to make a recovery passphrase - I
  think it should be mandatory and the setup shouldn't work if you don't."
  (The optional wrap-addition arm existed for the overnight road, which
  went unused; setup walks straight into generate→write→confirm.)
- **CF-6 — RULING (the warning wording — her ratify became an EDIT):**
  clarify that the LOCAL copy survives — what's lost is the synced/remote
  copy and new-device enrollment; her words: "it seems like your local
  copy will be destroyed with the current phrasing."
- **CF-7 — RULING: a real step FLOW with an understanding CHECKBOX.** Her
  words: "this text is too easy to skip over... they should have to check
  a checkbox that's like 'I understand that if I lose my recovery phrase
  and my passphrase, that I will not be able to recover anything from sync
  or add new devices'."
- **CF-8 — FUTURE (recorded, not built; her explicit deferral):**
  remote-reset for users who lose sync access but hold the local corpus —
  "are we going to allow them to delete their remote account /
  subscription and reupload with a whole new key? that seems like it makes
  sense to me and it should go on the plan for later... for now we just
  say, keep track of this!" Owner: 14c's operationalia (the machinery IS
  R-2's own shape — resyncReinitialize + a fresh vault — made user-facing;
  composes with account deletion and the tier).
- **CF-9 (storage-recommendation copy):** recommend paper or a password
  manager; "two copies of the passphrase and two copies of the recovery
  key, stored separately."
- **CF-10 (the round's framing principle), her words:** "i think this will
  be some people's first experience with true end to end encryption that
  isn't like an 'apple manages this for you' deal, and we need the flow to
  make more sense for them."
- **Hygiene note:** the phrase set shown in her screenshot was REGENERATED
  immediately after (her own act) — the exposed words are dead; the live
  set is the post-regenerate one she confirmed. Her Keychain-prompt
  side-report (Always Allow not sticking across prompts — the known macOS
  dev-signing behavior) recorded with GM-1's family.
- **Pre-wipe vault state read (the architect):** one `key_vault` row on
  *[removed for publication]*
  the CAS token moving as designed), `has_recovery_wrap` TRUE, KDF 65536
  KiB / t=3. Her Mac is ENROLLED; the setup half of the gate is DONE.
- **CF-11 — RULED IN (post-repush): a "Forget encryption keys on this
  device" door.** Surfaced answering her phone-drill question: sign-out
  deliberately does not clear custody, and iOS keychain items persist
  across reinstall — so the phrase road on an enrolled phone has NO path
  without this door, and device-handoff/switching genuinely needs it. Her
  word: "yeah, forget encryption keys would be good to do." Ships in the
  copy/flow round; the round's acceptance re-runs the drill on the phone
  properly (forget → re-enroll via the phrase).
- **CF-12 — her lift question (2026-08-04): QR enrollment + the biometric
  setting, "the copy round might be a good time for it to ride after
  we've validated the core flow."** The architect's honest shapes,
  relayed: the BIOMETRIC require-at-launch setting (R-6's answered-open
  door) is a REAL MINI-BATCH, rideable in the round (SecAccessControl on
  the key item + LocalAuthentication unlock-once-per-launch + a
  device-local toggle + both form factors + pins; sync waits for first
  unlock while ON — the known cost). QR DEVICE-LINKING is NOT round
  material: a genuine key-delivery protocol (ephemeral-key QR exchange, a
  delivery channel — likely a server mailbox table = another §12 lockstep
  event — camera plumbing, two-device UX both directions) — it stays the
  recorded R-4 future door with its own design sitting when she wants it.
  TERMINOLOGY note relayed: what she's seeing called "passkey" elsewhere
  is WebAuthn SIGN-IN credentials (an account-password replacement — a
  14c-era issuer consideration), unrelated to the encryption
  passphrase/keys; what we'd build is biometric-GATED KEYCHAIN access.
- **The phone status (hers, same message):** the installed mobile build
  "didn't add an account login option" — the phone's encryption test
  WAITS on the mobile session adding the sign-in door (that face is the
  mobile project's scope; she is working with that session directly).
  PL-6's phone half rides that + CF-11's door.

### The validation tail — PASSED (2026-08-04, her reports; the gate's
### remaining her-facing steps)

- **GATE STEP 5 — THE PHONE: PASSED.** Her words: "phone test is done and
  I successfully logged in and decrypted... and all of my work is
  available on my phone! it all showed up :)" (the mobile session added
  the login door on its side first). **L12 SATISFIED — the DEVICE KDF
  number: 0.16 s on the phone** (the app's own surfaced measurement; the
  Mac app shows the same 0.16 s class — the earlier 0.57–0.62 s numbers
  were DEBUG builds of the harness/runner, the apps are Release-optimized;
  both numbers recorded with that explanation). The enrolled state reads
  correctly on the phone ("a recovery phrase is on file for this
  account").
- **GATE STEP 6 — THE PHRASE DRILL (light road): PASSED.** Her words: "i
  also changed my passphrase on my mac using the recovery phrase (it
  really is very unclear that it's a button)" — the words→unwrap→re-wrap
  road proven end-to-end with her paper copy; CF-3's legibility finding
  re-confirmed in the same breath. **The cross-device invariant CONFIRMED
  LIVE: her phone stayed enrolled and reading through the passphrase
  change** (class keys in device custody are untouched by a master
  re-wrap — exactly the R-8 hierarchy's promise). The proper phone drill
  (forget → re-enroll via phrase) rides the round's acceptance through
  CF-11's door as recorded.
- **The passphrase FILE deleted** (announced; its purpose spent at the
  repush, and her passphrase change made it stale — the live passphrase
  now exists nowhere but her head, exactly the end state the design
  wants).
- **CF-12 RESOLVED BY HER RULING: QR DEFERRED ("we'll defer QR device
  linking"), the BIOMETRIC require-setting IS IN the copy round.** Her
  design ask on it, RULED IN: **biometric OR the encryption passphrase
  ONLY — never the device passcode** ("can we make it such that it only
  accepts biometric or the passphrase? not your phone passcode? I feel
  like this is more of a 'no one can read my diary' step"). Technically
  clean: the key item gates on `.biometryCurrentSet` alone (no
  `.devicePasscode` fallback); biometric failure/unavailability falls
  back to TYPING THE PASSPHRASE (re-derive → unwrap from the vault) — and
  biometry re-enrollment invalidating the item is a FEATURE under this
  threat model (a newly added fingerprint grants nothing; the passphrase
  road recovers). Honest boundary stated to her and accepted: the local
  store stays plaintext by design (the E2EE boundary is the server);
  OS-level protections (iOS file protection, FileVault) carry the
  at-rest story, and the raw-file caveat is real but obscure.
- **CF-13 (copy):** make it unmistakable that the WHOLE phrase is the
  secret — her words: "i could see someone thinking that any of the words
  would be a password."
- **TERMINOLOGY RULING: nothing is ever called "Passkey"** ("let's not
  call anything Passkey to not confuse users").
- Her closing read: "so things are looking pretty damn good!"

### THE COPY/FLOW ROUND — the batch brief (authored post-validation; a
### fresh Fable implementer; ONE cold review pass over the round's diff
### follows it, then her walk + the proper phone drill as acceptance)

Scope — CF-1…CF-13 + the CF-12 biometric ruling, exactly:
1. **THE SETUP FLOW becomes a real STEPPED flow** (CF-1/5/6/7/9/10/13):
   step 1 choose passphrase (recommendation copy + CF-9's two-copies
   advice: paper or a password manager, two copies of each secret, stored
   separately); step 2 the WARNING as its own step with the MANDATORY
   CHECKBOX — her exact words: "I understand that if I lose my recovery
   phrase and my passphrase, that I will not be able to recover anything
   from sync or add new devices" — and the CF-6 clarification (the
   writing on YOUR devices survives no matter what; what's lost is the
   synced copy and new-device enrollment); step 3 create; step 4 the
   recovery phrase MANDATORY (CF-5 — generate → display with CF-13's
   whole-phrase-is-the-secret copy → write down → confirm by re-entry;
   the flow cannot complete without it; no ambient "Done" that reads as
   an action — CF-1). First-experience framing (CF-10) governs the copy.
2. **CF-2:** Regenerate Recovery Phrase gates behind the passphrase (the
   surface's rules become coherent).
3. **CF-3:** "Forgot it? Authorize with the recovery phrase" LOOKS like a
   button, both places it appears.
4. **CF-4:** the phrase-display/confirm states read as required steps,
   never optional-looking (largely falls out of the flow restructure;
   apply to the regenerate surface too).
5. **CF-11:** "Forget Encryption Keys on This Device" — confirmed
   destructive door; clears custody; the surface returns to the
   enrollment state and the sync face to its locked line; pin (forget ⇒
   zero keys in custody + the engine refuses visibly again).
6. **The BIOMETRIC require-setting (CF-12's ruling):** a device-local
   toggle ("Require Face ID / Touch ID to unlock sync" — per-platform
   naming, NEVER "Passkey"); custody item gated `.biometryCurrentSet`
   ONLY (no `.devicePasscode` fallback — her ruling: biometric or the
   PASSPHRASE, never the phone passcode); biometric failure/unavailable
   ⇒ the passphrase road (re-derive → unwrap); unlock once per launch,
   sync waits until it happens (the known cost, stated in the toggle's
   own copy); biometry-re-enrollment invalidates the item BY DESIGN (the
   passphrase recovers — a one-line note in the toggle copy); both form
   factors through the shared seam; pins for the gated/ungated arms and
   the fallback (scripted LAContext seam — no real biometrics in tests).
7. **Terminology pin:** a test asserting no shipped UI string contains
   "passkey" (case-insensitive) — the ruling made durable.
8. The GATE RATIFY block's disclosure list gets its final user-facing
   copy staged for her walk (still awaiting her one look).
Boundaries: zero `Sources/VariorumCore/Sync/` lines; core additive-only
if genuinely needed (record why); no schema, no server, no production
contact; the bridge untouched; nothing beyond the CF items. Acceptance:
core + full Mac suite (tripwire-only) + mobile + spine, own runs; then
HER walk + the phone drill (forget → re-enroll via phrase) as the
round's human acceptance.

### Copy/flow round — record (implementer session, 2026-08-04; written
### EXTRA-COMPLETE at the author's mid-round instruction — a fresh Fable
### orchestrator adjudicates this round after a mid-phase crossover, so this
### record is self-contained: what shipped per CF item, every design call
### with its reason, the revert evidence, the copy verbatim for her walk,
### and the exact acceptance accounting)

**Commit: `969ff83` (implementation + pins, one coherent diff — four files,
ALL App-side: `App/Variorum/Shared/EncryptionKeychain.swift` ·
`EncryptionSession.swift` · `EncryptionViews.swift` ·
`App/Variorum/VariorumTests/EncryptionFlowTests.swift`). The record
finalization is its own commit after the long runs.**

**Scope proof (for the adjudicator's own re-derivation):** `git show
--stat 969ff83` = exactly those four files. Zero
`Sources/VariorumCore/Sync/` lines; zero `Sources/VariorumCore/` lines at
all — `VaultEnrollment.swift` is UNTOUCHED (the brief's additive-with-
reasons carve was never needed: `enroll(passphrase:)` already IS the
honest verification CF-2 wanted, and the forget/biometric doors are pure
custody policy, which was always the App layer's). No schema, no server
artifacts, no production or dashboard contact, no `.env*` reads, no new
dependencies. The bridge untouched. No push (the architect pushes after
verification).

**The eight brief items, one by one:**

1. **The stepped setup flow (CF-1/5/6/7/9/10/13) — BUILT.** `.noVault`
   renders a 3-step view-local flow; the mandatory phrase is step 4 BY
   CONSTRUCTION: it renders from `.enrolled(hasRecoveryWrap: false)`
   itself, so an interruption (close, crash, relaunch — including her real
   overnight-era shape, and a new device enrolling into a wrap-less vault)
   RESUMES at the required step; it cannot be skipped because it is a
   state, not a screen. Step 1: passphrase + repeat + the CF-10 intro
   (what E2EE is, before any secret is chosen) + the standing
   recommendation + short-passphrase caution. Step 2: the CF-6-amended
   warning + the CF-9 storage advice + HER EXACT SENTENCE as a mandatory
   checkbox (macOS `.checkbox` toggle style; iOS the native switch —
   platform-native rendering of "checkbox", recorded below). Step 3: the
   one act ("Create Encrypted Vault") with a back road. Step 4: the words
   auto-generate on appear (no optional-looking "Generate" offer to
   decline — CF-5), CF-13's whole-phrase copy, numbered display, the
   write-down/type-back two-liner (CF-4's required framing), confirm by
   full re-entry, NO cancel on the mandatory arm. The advance gates are
   pure functions (`EncryptionSetupRules`) so tests pin them. CF-1's
   "Done" ambiguity: the sheet's dismissal is now a borderless "Close" in
   the header row — no `defaultAction`, never beside an act.
2. **CF-2 — BUILT.** "Regenerate Recovery Phrase…" reveals a passphrase
   gate; `EncryptionSession.generatePhraseAuthorized(passphrase:)`
   verifies by a REAL vault unwrap (`VaultEnrollment.enroll` — never a
   local compare), and only then mints. Wrong passphrase refuses in the
   standing wording and mints nothing (pinned).
3. **CF-3 — BUILT.** "Forgot it? Authorize with the recovery phrase" is a
   `.bordered` button (her live find quoted at the site); the same
   treatment on every reveal-toggle of the family — "Use my recovery
   phrase instead" and both "Back to…" counterparts — so no reveal
   anywhere renders as static hint text.
4. **CF-4 — BUILT** (largely fell out of the restructure, as the brief
   predicted): the display/confirm section reads as numbered required
   steps; the REGENERATE arm shares the identical section (with a Cancel,
   legitimate there — the old wrap stays valid until confirm) plus the
   "old phrase keeps working until this confirm lands — then it stops,
   everywhere" line.
5. **CF-11 — BUILT.** "Forget Encryption Keys on This Device…" — a
   destructive-role button behind a `confirmationDialog`; the act clears
   custody + the launch cache + the biometric gate, fires `onKeysChanged`
   (so the engine's next round refuses VISIBLY at once — the sync face
   returns to its locked line, never a stale reading), and the surface
   returns to the ENROLLMENT state (the vault survives). Pinned: forget ⇒
   zero keys in custody + `DeviceKeySyncProvider` throws
   `SyncKeyProviderError.notEnrolled` — the exact seam the locked-face pin
   (batch 3) already proves surfaces as the visible refusal with zero
   transport contact — + state `.notEnrolled` + the hook fired once.
6. **The biometric require-setting (CF-12's ruling) — BUILT.**
   - **The mechanism:** with the toggle ON, custody moves to a SECOND
     Keychain item (`device-keys-biometric` under the same service) behind
     `SecAccessControlCreateWithFlags(kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
     .biometryCurrentSet)` — `.biometryCurrentSet` ALONE, no
     `.devicePasscode`, no `.or` escape (her ruling in flags); which
     account holds the item IS the policy of record (no side flag to
     drift). Unlock is ONCE PER LAUNCH: a successful
     `LAContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics)`
     (biometrics-only policy; the system prompt's fallback button
     suppressed — falling back is OUR passphrase road, never a system
     credential) reads the item under the evaluated context and fills a
     process-lifetime cache; until then `DeviceKeyStore.load()` returns
     nil and the engine refuses its rounds in its own standing grammar —
     sync waits, exactly the stated cost, spoken in the toggle's own copy.
   - **The fallback:** biometric failure/unavailability/invalidation ⇒
     the passphrase road (`enroll(passphrase:)` re-derives + re-unwraps
     from the vault); the save under an ON gate re-persists GATED and
     unlocks the launch — the gate SURVIVES the fallback (policy is hers
     to turn off, never a side effect; pinned). Biometry re-enrollment
     invalidates the item BY DESIGN (a new fingerprint/face grants
     nothing; one line in the toggle copy says the passphrase still gets
     you in).
   - **The seam (the brief's LAContext-behind-a-seam mandate):**
     `DeviceKeyStore` (the file's standing struct-of-closures seam, the
     AuthTokensStore pattern) gained the policy surface —
     `biometryAvailable` / `isBiometricGateOn` / `setBiometricGate` /
     `unlockWithBiometrics` — and ALL LAContext/SecAccessControl code
     lives inside the `.keychain()` closures alone. Tests script custody
     AND biometric outcomes through the new `InMemoryKeyBacking`
     (persisted item + gate flag + launch cache + scripted availability/
     outcome, `simulateRelaunch()` as the once-per-launch lever) — no
     test touches the real Keychain or LocalAuthentication.
   - **The projection:** new session state `.enrolledLocked(hasRecoveryWrap:)`
     (custody exists, launch locked) renders the locked section — the
     biometric door first, the passphrase road and (when a wrap exists)
     the phrase road beneath, and the never-the-passcode line. The toggle
     lives in the enrolled management area with per-platform naming
     ("Touch ID" / "Face ID or Touch ID" — the forbidden word nowhere),
     disabled for turning ON when biometry is unavailable (turning OFF
     always allowed). `biometricRequired` is a tracked property seeded at
     `refresh()` — deliberately NOT at init: a Keychain probe at
     construction is the GM-1 stall class (`AppServices.init` →
     synchronous securityd wait), noted in code.
7. **The terminology pin — BUILT, and it BIT on its first run:** a deep
   file walk (the R1-3 deep-walk precedent) over all three shipped source
   roots (`Shared/`, `Variorum/`, `VariorumMobile/` — 188 files) asserts
   the forbidden credential word (composed in the test, never written)
   appears NOWHERE, case-insensitive, comments included (stricter than
   "UI strings" — recorded as deliberate: a comment is where the word
   would creep back in from). Its first run FAILED on this very round's
   own fresh comment in EncryptionViews.swift ("NEVER \"P…\""), which was
   reworded — the pin proved non-vacuous live, on real code, before it
   ever went green.
8. **The disclosure list's user-facing copy — STAGED** (verbatim below):
   shipped as a `DisclosureGroup("What the server can and can't see")` in
   the enrolled management area; the technical 18-column list in the GATE
   RATIFY block is unchanged and stays the engineering record.

**The copy, VERBATIM (for her walk's ratify — all of it lives as statics
on `EncryptionView`, so the walk and the code cannot drift):**

- *Setup intro (CF-10):* "End-to-end encryption means your writing is
  sealed on this device before it syncs — the server only ever stores
  sealed text it cannot read. Two secrets can unseal it: the passphrase
  you choose now, and a 12-word recovery phrase you'll write down in a
  moment. Variorum holds neither."
- *The warning (CF-6-amended):* "This passphrase is not your account
  password, and it is never sent anywhere. Variorum cannot reset it and
  cannot read your writing without it — there is no “forgot passphrase”
  email, by design. If you lose both the passphrase and your 12-word
  recovery phrase, the synced copy is unreadable forever and no new
  device can be added — the writing already on your devices stays
  readable and stays yours."
- *The checkbox (CF-7, HER SENTENCE BYTE-EXACT, pinned):* "I understand
  that if I lose my recovery phrase and my passphrase, that I will not be
  able to recover anything from sync or add new devices"
- *Storage advice (CF-9):* "Store them like they matter: on paper or in a
  password manager. Keep two copies of the passphrase and two copies of
  the recovery phrase, stored separately." *(Her words said "recovery
  key" — rendered "recovery phrase" for the surface's one-term
  consistency; flagged for her walk.)*
- *Whole-phrase (CF-13):* "All 12 words together, in order, are the
  secret — no single word is a password. Anyone with the whole phrase can
  unlock your synced writing; anyone with less has nothing."
- *Step 4 heading + line:* "Step 4 of 4 — Your recovery phrase (required)"
  / "If you ever forget the passphrase, these 12 words are the only other
  way into your synced writing. Setup isn't finished until you've written
  them down and confirmed them — closing now just leaves this step
  waiting."
- *The forget confirm (CF-11):* "Sync on this device stops until you
  unlock again with your encryption passphrase or recovery phrase.
  Nothing is deleted from this device or your account." (+ the caption:
  "For handing a device off, or testing your recovery phrase. Your
  writing on this device and the account vault are untouched.")
- *The biometric toggle (CF-12; macOS arm):* "Require Touch ID to unlock
  sync" / "While this is on, sync waits each launch until you unlock —
  with Touch ID, or by typing your encryption passphrase. Your device
  passcode never unlocks it. If Touch ID is re-enrolled, the stored keys
  are invalidated by design — the passphrase still gets you in." (iOS
  arm says "Face ID or Touch ID" / "…If biometrics are re-enrolled…".)
- *The locked section:* "Sync is locked on this device." / "Touch ID — or
  your encryption passphrase — unlocks it. Your device passcode never
  does." / button "Unlock with Touch ID"; failure speaks "Biometric
  unlock didn't go through — enter your encryption passphrase instead."
- *The disclosure copy (item 8):* "Everything you write is sealed on your
  devices before it syncs: your text and takes, titles, book and chapter
  names, tags, comments, commit messages, and reference names and links.
  The server can never read any of it. // What the server still sees is
  the shape, not the words: that an entry exists on a day, how items are
  ordered and connected, their sizes, when you sync, and settings
  switches. Sealed words plus visible shape is what lets sync work
  without trusting the server."

**The hallucination guard — FIVE behavioral reverts, each run against the
pins, each red on its finding's exact mechanism, each restored (the suite
re-run green after restoration — the 14-test targeted set):**

1. *Forget door* (`store.clear()` removed from `forgetDeviceKeys`): the
   CF-11 pin failed 3 ways — custody remained, the provider RETURNED KEYS
   (sync would keep pushing after "forget" — the disaster), state stayed
   `.enrolled`.
2. *Gate flip* (`setBiometricGate` call removed — the toggle flips only
   the projection): both gate pins failed — a "fresh launch" still read
   custody and the provider returned keys while the toggle claimed ON
   (the user believes their diary is biometric-locked; it is not), and
   the fallback test's locked precondition never held.
3. *Unlock guess* (`store.unlockWithBiometrics()` skipped — the flow
   claims success): the unlock pin failed — state said `.enrolled` while
   `load()` was nil and the provider STILL refused (a "successful" unlock
   after which sync stays dead); the failure arm's spoken fallback never
   fired.
4. *CF-2 gate* (the vault unwrap skipped in `generatePhraseAuthorized`):
   the pin failed — the WRONG passphrase minted 12 words (anyone at the
   unlocked machine could replace the disaster secret with no proof; the
   exact incoherence CF-2 exists to close).
5. *The checkbox gate* (`canLeaveWarningStep` softened to true): the
   CF-7 pin failed on its first assertion.

**Test accounting:** 8 new tests in 2 new suites, all in
`EncryptionFlowTests.swift` — `CopyFlowRoundTests` (7: the forget pin ·
the gate-locks-until-unlocked arm · the failure-falls-back-and-gate-
survives arm · the gate-off arm · the CF-2 authorization pin · the setup
gates + her-sentence byte-pin · the CF-6/CF-13 copy pins) +
`TerminologyPinTests` (1: the deep walk, with a `walked > 100` floor so
the walk can never quietly go vacuous — 188 shipped sources today).
Expected full-suite lines: Mac **1202 + 8 = 1210 / 212 suites** (the
standing TakePane tripwire the ONE allowed red) · core **1155/124
unchanged** (zero core lines) · mobile **173/25 unchanged** (shared files
recompile; no new mobile tests) · spine **51/7**.

**PROVISIONALs / deviations (each with its reason — the adjudicator's
list):**

- **PROVISIONAL (CF-2's dialog):** the regenerate `confirmationDialog` is
  RETIRED — the passphrase gate replaces it as the deliberateness
  ceremony, the button is labeled "Verify and Generate New Phrase", and
  the destructive information ("keeps working until the new one is
  confirmed — then it stops, everywhere") moved into the gate's and the
  confirm section's own copy. Reason: two stacked ceremonies for one act
  is the friction doctrine's over-gating shape; CF-2's complaint was the
  MISSING gate, not a missing second dialog. One tap more honest, one
  dialog fewer. Hers to reverse at the walk.
- **PROVISIONAL (forget clears the gate preference):** forgetting keys
  wipes the biometric gate with custody (the gated item IS the policy
  record). A re-enrolled device comes back with the toggle OFF. Reason:
  custody-total wipe is the door's honest meaning; a surviving orphan
  policy flag would be the drift class the account-as-record design
  exists to kill.
- **PROVISIONAL (the locked section's roads):** `.enrolledLocked` offers
  the FULL unlock roads (passphrase + the phrase reveal when a wrap
  exists) beneath the biometric door, sharing the enrollment section's
  `unlockRoads` view. Reason: her ruling's letter — "biometric or the
  passphrase" — plus never stranding a forgot-passphrase user behind a
  gate their phrase could open.
- **PROVISIONAL (auto-generate at step 4):** the mandatory step generates
  its words on appear rather than behind a button — CF-5's
  "shouldn't work if you don't" read as: the step IS the phrase, no
  declinable offer exists. The no-trap boundary is stated in copy
  (closing leaves the step waiting; the state resumes it).
- **Deviation (failed-create keeps the entry):** the setup passphrase now
  clears from view state only on SUCCESSFUL create (before: cleared at
  press, so a network-failed create forced Back-and-retype). Same
  secret-hygiene class (it lived in @State through steps 2–3 regardless).
  The same keep-on-failure rule now protects the generated WORDS: a
  failed `landRecoveryWrap` no longer clears the display, so the words
  she wrote down stay the words on screen (the old optimistic clear
  would have re-generated a DIFFERENT phrase after e.g. a network blip —
  a real wrote-down-the-wrong-phrase trap, found while restructuring).
- **Deviation (iOS checkbox):** her word was "checkbox"; iOS has no
  native checkbox toggle style — the switch is the platform's same
  control. macOS renders the literal checkbox.
- **Considered and HELD (for the walk, not built):** the sync status
  row's locked line still reads "Sync locked — enter your encryption
  passphrase" even when the lock is the biometric gate (the row is
  outside the CF items; its Unlock… door opens this surface, which
  offers the biometric unlock first). A per-state row label is a one-line
  follow-up if her walk wants it.
- **Terminology pin walks comments too** — stricter than the brief's "UI
  strings"; deliberate (recorded above; it already caught one).

**The crossover handoff (what the fresh orchestrator needs):**
- The round's diff is `969ff83` + the record commits after it. The brief
  is the section above this record; the CF ledger is "Her validation
  walk" + "The validation tail".
- Still owed AFTER adjudication, per the brief: ONE cold review pass over
  the round's diff; then HER WALK + the proper phone drill (forget →
  re-enroll via phrase — CF-11's door now exists for it) as the round's
  human acceptance; the `/Applications` refresh (pre-authorized, at a
  zero-instance window) and the mobile project's `main` → `mobile` merge
  for the phone build carrying this round; the L16 closeout parity line.
- The phone-drill note for her walk: on the phone, the drill is Settings
  → the sync row's Encryption door → Forget Encryption Keys (confirm) →
  the sync face shows the locked line → Unlock… → "Use my recovery
  phrase instead" → her 12 written words. Both doors ride the shared
  seam, so the flow is identical on the Mac.
- Environment notes for whoever runs the Mac suite next: this session's
  runs were all from the `App/Variorum` project invocation; no GM-1
  preparing-timeout occurred in any of them; the standing tripwire is
  the one allowed red.

**Acceptance (the round's full set — own runs, all waited synchronously,
verbatim lines; FINALIZED post-record per the repo-first rule):**
- Core `swift test` (repo root): **"✔ Test run with 1156 tests in 124
  suites passed after 32.236 seconds."** — ONE more than the kickoff's
  1155/124 baseline with ZERO core tests added this round; traced, not
  shrugged at: the GM-3 fix landed in TWO commits (`2b3a03c` runner 11/1 →
  `29cfd94` + `dropsWithProgressNeverExhaustTheBound`, runner 12/1), and
  the wipe-section prose recorded the core total at the FIRST half
  (1155) without refreshing it for the second pin. Verified: the runner
  suite runs 12/1 today, `git log af32293..969ff83 -- Tests/ Sources/
  Tools/` is EMPTY, so 1156 IS the inherited tree's true count.
- Full Mac suite (cwd-independent `-project` invocation): **"✘ Test run
  with 1211 tests in 212 suites failed after 153.651 seconds with 1
  issue."** — the one issue is the standing tripwire BY IDENTITY
  (`TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`),
  nothing else red; 1202 + this round's 8 in 2 new suites + the step-0
  addendum pin below, exactly accounted. (An earlier full run before the
  addendum: "1210 tests in 212 suites … 1 issue", same tripwire. No GM-1
  preparing-timeout in any run this session.)
- Mobile (iPhone 17 Pro sim): **"✔ Test run with 173 tests in 25 suites
  passed after 4.657 seconds."** + ** TEST SUCCEEDED ** — baseline exact.
- The spine (the seven Tutorial suites, dedicated run): **"✔ Test run
  with 51 tests in 7 suites passed after 14.327 seconds."**
- Also run before the record: the 4-suite targeted set
  (Encryption/CopyFlow/Terminology/LockedFace) — "Test run with 14 tests
  in 4 suites passed"; Mac `build-for-testing` ** TEST BUILD SUCCEEDED **;
  the MOBILE APP BUILD against the shared changes ** BUILD SUCCEEDED **.

**ADDENDUM (post-acceptance, same session — responding to the architect's
mid-run handoff update `c374680`, which landed between this record's two
commits): THE RE-KEY DRILL's STEP-0 PRE-VERIFICATION IS PINNED GREEN.**
The handoff's step 0 names an unexercised state gating her live drill — a
vault DELETED while local custody still EXISTS — and asks for it to be
confirmed and pinned BEFORE the drill. Done now, while the code was in
context (P-7; one test, no behavior change):
`CopyFlowRoundTests.aDeletedVaultWithStaleCustodyOffersSetupAndOverwritesCleanly`
proves the CURRENT behavior is the clean arm: `refresh()` reads the
missing vault as `.noVault` even with stale custody (documented in the
pin), the stepped setup flow proceeds, `setUp()` OVERWRITES the stale
custody wholesale (fresh material, fresh corpus key id), the sync provider
serves the NEW key — never the orphaned one — and the mandatory phrase
step follows exactly as for any fresh vault. The handoff's alternative
shape ("make the flow forget-then-set-up") therefore stays a TASTE choice,
not a safety need — the adjudicator can still take it, but nothing wedges
without it. Under a BIOMETRIC gate the same save path re-persists gated
and unlocks the launch (the save-under-gate arm already pinned). CF-14/
15/16 (defined only in the architect handoff, never in this session's
brief) are DELIBERATELY NOT built here — the handoff already routes them
to the crossover's own implementer, and building them from a secondhand
summary would be exactly the drift the brief's "nothing beyond the CF
items" boundary exists to prevent.

### THE WIPE AND REPUSH — EXECUTED (2026-08-04, her explicit go: "go ahead!
### this is the moment where supabase stops seeing all my innermost
### thoughts haha")

- **The wipe:** the committed truncate artifact executed VERBATIM at her
  go; after-state verified — all 18 data tables at ZERO, `key_vault` = 1.
- **The near-miss the dry-run caught (recorded so the class is known):**
  the runner's first minted session belonged to a STRAY user — the
  architect minted the admin link against her GIT email
  *[removed for publication]*
  DIFFERENT address (the 9c-era identity), and admin `generate_link`
  CREATED a user for the unknown address despite signups-off (admin
  bypasses the toggle — worth knowing for 14c). The dry-run surfaced it
  (wrong uid + "vault absent" through RLS) BEFORE any write; the stray was
  deleted (RETURNING-verified, zero data), the token re-minted against her
  real address, the re-dry-run showed her uid + the unwrap arm. Dry-run
  earned its existence.
- **Finding GM-3 (fixed at the architect's hand mid-gate, both halves
  revert-verified; commits `2b3a03c` + `29cfd94`):** the live gateway
  KILLS rapid-fire push-chunk bursts (deterministic -1005 after ~2–4
  200-row chunks; the app's scheduler absorbs this class by retrying
  rounds, so production never saw it) — the runner's drain now retries
  transient transport drops IN-PROCESS with bounded backoff, and
  "consecutive" means WITHOUT PROGRESS (the second half, found live: every
  round of a large drain can end in a drop while the outbox converges —
  progress resets the bound). A genuinely dead network still fails typed
  with the outbox intact. Runner suite 12/1; core 1155/124; both pins RED
  under behavioral revert. 14c note: stranger-scale initial pushes meet
  this same gateway behavior — the burst/pacing question joins the
  pull-to-head windowing family.
- **THE REPUSH: DRAINED.** 11 rounds, 7,265 rows accepted, keys died with
  the process. **THE LIVE DUMP VERIFICATION — the phase's headline proof,
  PASSED:** zero plaintext across ALL 18 encrypted columns (every stored
  value bears `e1:`), mirror rows 7,265 == local 7,265 exact, the sampled
  journal row reading `e1:ZHwJJAD2…` — structure visible, words never.
  The runner's session token deleted after use.

### Gate-morning findings (2026-08-04 — the architect's, at first Mac-suite
### execution; recorded before the fix session)

**FINDING GM-1 (the windowless-launch CAPTURE — the KnownIssues row now
carries it in full):** the Mac suite's "timed out while preparing" cluster
was NOT lock-state environment — a live specimen launch was caught
windowless and sampled per the row's own protocol: the main thread blocks
at construction in `AppServices.init` → `AuthSession.init`
(AuthSession.swift:201) → SYNCHRONOUS `SecItemCopyMatching` →
securityd `mach_msg` wait (ACL/authorization-interaction class; a freshly
rebuilt binary the plausible trigger). Self-released after ~40 s; the
runner then worked instantly. The 13b "environment class" attribution and
the 13k lock-covariate refutation both now have their mechanism. Fix
(lazy/off-main token load) stays owned by 13e per the row; TODAY's
operational note: a first launch of any freshly built binary may sit
windowless up to ~a minute — wait or click the Dock; approve any Keychain
prompt with Always Allow.

**FINDING GM-2 (first execution of the six batch-3 Mac-only pins + the
suite): Mac 1202/210 ran fully — 12 issues = the allowed tripwire + TWO
classes:** (a) NINE issues across "Fragments bridge wiring (9b)" ×3 tests
and "Auth wiring (9c)" ×3 tests — all asserting the PRE-PAUSE bridge world
(`pullCalls`/`calls > 0`, pausedDays reaching status) through the app
composition, which now deliberately wires NO bridge key provider (the
RULED pause; every round refuses before transport contact — the pause's
own app-side zero-contact pin PASSES). The cadence/interleaving machinery
those tests pin must stay pinned through the pause era (it guards the
14c-era resumption) — fix: `AppServices` gains an injectable
`makeBridgeKeyProvider` (production default unchanged: none → the
refusing default), the six tests inject fixed bridge keys to keep their
machinery pins, and the pause pin continues to assert the default
composition refuses. (b) batch-3's OWN `aLockedProviderRefusesVisibly…`
pin fails with dependency-context issues (`AppDatabase+Dependency.swift:95`,
`UUID.swift:67`) — a test-authoring bug on first execution (never
executable under the batch-3 hold); fix its dependency bootstrapping to
the file's sibling-test pattern. The SPINE is GREEN (51/7). No product
misbehavior in evidence; the wipe's green-but-tripwire precondition
STANDS until these land.

**THE GATE (announced steps, her explicit go per step — amended by Round 4:
refresh pre-authorized; wipe pre-approved and sequenced at step 4; deploy
attempted overnight if the ladder closes clean — steps 1–2 EXECUTED
overnight, the record above):**
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

### Gate-morning fix record (2026-08-04 — the GM-2 fix session; one commit)

**Scope held to GM-2 exactly: five files, zero `Sources/VariorumCore/`
lines (verified on the diff), production composition byte-unchanged except
the added defaulted parameter.**

- **Fix 1 — the bridge-pause test seam.** `AppServices.init` gains
  `makeBridgeKeyProvider: (() -> any BridgeKeyProviding)? = nil` (the
  `makeSyncKeyProvider` pattern); `connectBridgeIfAllowed` passes
  `makeBridgeKeyProvider?() ?? UnenrolledBridgeKeyProvider()` — nil (every
  production caller) composes byte-identically to the pre-seam default:
  the engine's refusing provider, the RULED pause. App-test side:
  `AppTestBridgeKeyProvider` (Phase8ServicesTests.swift, beside
  `AppTestKeyProvider` — the core `BridgeTestKeys` world is not visible in
  the Mac target). The six tests, per-test:
  - `bridgeRoundsFollowSyncRoundsNeverInterleaving` — engine construction
    gains the fixed provider; the ordering pin observes real rounds again.
  - `cadenceTriggersAreThrottledToTheMinimumInterval` — same injection;
    the throttle counts rounds that reach the transport.
  - `pausedDaysReachTheSessionStatus` — same injection; the pause refuses
    BEFORE the day sweep, so without keys no pausedDays ever surfaced.
  - `fragmentsSignInConfiguresTheBridgeAndDisconnectStopsIt` /
    `theLifecycleCadenceReachesTheBridgeWhenSyncIsOff` /
    `theLifecycleCadenceStillNeverInterleavesWhenSyncIsOn` — the 9c
    `withWiredServices` helper passes
    `makeBridgeKeyProvider: { AppTestBridgeKeyProvider() }` through the new
    seam; the fence pins in the same file (`devStoreSessionsStayFenced…`,
    `theBridgeStaysDownWhereItIsNotEnabled`) still assert zero contact and
    still pass (the fence refuses configure before keys matter).
  None of the six inspects payloads — call accounting only, so the fixed
  keys are all they needed. The pause's own zero-contact pin
  (`theDefaultProviderRefusesEveryRoundBeforeAnyTransportContact`,
  core-side, against the engine's default) is untouched and still guards
  the default composition.
- **Fix 2 — the locked-face pin's dependency bootstrapping.**
  `aLockedProviderRefusesVisiblyBeforeAnyTransportContact` wraps its body
  in the wiring suites' standard `withDependencies` bootstrap
  (`$0.database` / `$0.uuid` / `$0.date` — the Phase 8/9b pattern; the
  round runs through SyncScheduler/SyncEngine, whose `@Dependency`
  reads were the recorded `AppDatabase+Dependency.swift:95` /
  `UUID.swift:67` issues). Assertion content unchanged: locked provider ⇒
  classified visible refusal + zero transport contact.

**Acceptance (all waited on synchronously, this session):**
- Mac (full, `-project` invocation): **"✘ Test run with 1202 tests in 210
  suites failed after 148.224 seconds with 1 issue."** — the one issue is
  the standing tripwire BY IDENTITY
  (`TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`),
  nothing else red. (No GM-1 preparing-timeout this run.)
- Spine: **"✔ Test run with 51 tests in 7 suites passed after 13.942
  seconds."**
- Core (`swift test`, untouched-core proof): **"✔ Test run with 1153 tests
  in 124 suites passed after 31.433 seconds."**

**Deliberately not touched:** `fencedSessionsNeverConfigureTheBridge` (9b)
keeps the engine default — it was never failing and its zero-calls
assertion rides the session-level configure refusal, not the keys gate;
noted for the architect only because its engine now models the paused
composition. **The wipe's green-but-tripwire precondition is now MET.**

### The crossover adjudication (the FRESH architect, 2026-08-04 — the
### incoming seat's verification of the landed round, the re-verify
### mandate's verdicts, the PROVISIONAL dispositions, and the folded
### CF-14/15/16 rows; the architect handoff file is the cutover's entry
### point, THIS file remains the one running record)

**The landed round, verified (verify-don't-trust, own evidence):**
- Tree clean at `a9b00fd`, pushed; the four commits (`969ff83` ·
  `6233274` · `6522abe` · `a9b00fd`) match their messages.
- **Scope re-proven on the diff:** `git diff af32293..a9b00fd` = exactly
  the four App-side files + the two notes files; `-- Sources/` EMPTY
  (zero core, zero `Sync/`), `-- Server/ Vendor/` EMPTY.
- **All three shipped files read in full** against the eight brief items —
  every item present as recorded; the copy statics byte-match the record's
  verbatim block; the failed-create/failed-land keep-the-entry deviations
  verified at their sites (`EncryptionViews.swift` clears only on
  `lastError == nil`).
- **Suites re-run by this seat:** core **1156/124 PASSED** (the corrected
  baseline confirmed — GM-3's second commit accounts for the +1) · Mac
  **1211/212, the standing TakePane tripwire the ONE red, BY IDENTITY**
  · mobile **173/25 PASSED** + TEST SUCCEEDED · spine **51/7 PASSED**.
  (Run lines in this seat's session; the implementer's claims all held.)
- The test accounting re-derived: 8 `CopyFlowRoundTests` (7 round pins +
  the step-0 addendum) + 1 `TerminologyPinTests` = 1202 → 1211 exact.

**HER RE-VERIFY MANDATE — the four cutover answers re-derived from the
code by this seat (file:line evidence; verdicts as she asked):**
- **Q1 — CONFIRMED.** `EncryptionSession.refresh()`
  (EncryptionSession.swift:96–124): a missing vault maps to `.noVault`
  regardless of custody (:107); vault + custody → `.enrolled`; vault +
  no custody → `.notEnrolled` (or `.enrolledLocked` under the biometric
  gate — the round's addition). So CF-11's forget door reaches
  ENROLLMENT, never SETUP; walking the stepped setup live requires the
  vault row gone — exactly the re-key drill. The A4-fence half also
  confirmed: a dev-store session renders "Sync off (dev store)" with no
  sign-in door (SyncStatusViews.swift:35–40) and the Encryption door is
  gated on `sync.allowsSync` (:93) — no scratch-account walk without
  weakening the fence.
- **Q2 — CONFIRMED.** The drill IS CF-8's machinery rehearsed: the vault
  row delete (admin road) + the committed truncate artifact
  (`Server/supabase/maintenance/14b-mirror-truncate.sql`, on disk,
  registry-pinned) + `resyncReinitialize`/`vault-bootstrap` (L10). What
  14c owes is the in-app door + guard rails, as recorded.
- **Q3 — CONFIRMED, both halves.** Forget-on-Mac-only leaves the phone
  untouched (the vault is unread by it; her passphrase change already
  proved the cross-device independence live). A full RE-KEY leaves the
  phone's ACCOUNT session intact (auth custody and key custody are
  separate Keychain services by design — EncryptionKeychain.swift's
  header states it; 9c's pattern) but its class keys STALE: custody
  pins `corpusKeyID` (DeviceKeyMaterial, VaultEnrollment.swift:17) and
  `PayloadCipher`'s AAD binds the key id, so new-key ciphertext fails
  `authenticationFailed` → the round refuses `payloadCryptoFailure`.
  And the CF-16 gap is REAL: refresh() decides "enrolled" by
  `store.load() != nil` ALONE (EncryptionSession.swift:105) — no key-id
  comparison against the fetched vault exists anywhere in the file. A
  re-keyed account's stale device reports "This device holds your
  encryption keys" while its rounds fail generically.
- **Q4 — CONFIRMED, with the round's update.** After a re-key the phone
  needs forget → re-enroll with the new passphrase; before this round NO
  path existed (sign-out keeps custody by design; iOS Keychain survives
  reinstall). CF-11's door NOW SHIPS on both form factors through the
  shared seam — the round built exactly the missing path.
- **One precision (not a correction):** the substitute seat's CF-15 line
  numbers verify exactly (`SyncStatusViews.swift:45–47` isSyncing branch
  vs :78–87 idle branch; the Encryption door's independent `if` at :93).

**Architect dispositions — the round's PROVISIONALs/deviations (adjudicated
against the spec docs + the friction doctrine; her walk may overrule any):**
- *CF-2's retired confirmation dialog* — **ACCEPTED.** The passphrase gate
  IS the deliberateness ceremony; stacking a second dialog on it is P-5's
  over-gating shape. CF-2's complaint was the missing gate, not a missing
  dialog. Hers to reverse at the walk.
- *Forget clears the biometric gate with custody* — **ACCEPTED.** The
  gated item IS the policy record; a surviving orphan flag after a
  custody-total wipe is exactly the drift class the design kills.
- *The locked section offers the full unlock roads* — **ACCEPTED.** Her
  ruling's letter ("biometric or the passphrase"), and a forgot-passphrase
  user must never be stranded behind a gate their written phrase opens.
- *Step 4 auto-generates on appear* — **ACCEPTED.** CF-5's "the setup
  shouldn't work if you don't" reads as: the step IS the phrase; a
  declinable Generate button would re-open the optional look she ruled out.
- *Failed-create keeps the entry / failed-land keeps the words* —
  **ACCEPTED, the second commended:** the words-survive-a-failed-land rule
  closes a real wrote-down-the-wrong-phrase trap (a network blip between
  display and land would have silently re-minted different words).
- *iOS renders the checkbox as the native switch* — **ACCEPTED** (macOS
  keeps the literal checkbox; "checkbox" is platform-idiomatic, not
  byte-literal).
- *The terminology pin walks comments too* — **ACCEPTED** (it caught its
  own first offender live; a comment is where the word creeps back in).
- *The held item (the sync row's locked line says "passphrase" even when
  the lock is the biometric gate)* — **STAYS HELD for her walk.** CF-15's
  ruling covers button stability, not this wording; minting new copy for
  it unasked would be inventing product behavior. One line if she wants it.
- *The step-0 addendum pin* — **ACCEPTED; the drill is step-0-safe.** The
  forget-then-set-up alternative is NOT taken: the pinned wholesale
  overwrite is clean, and the drill's own step 2 clears custody through
  the forget door anyway.

**THE CF-14/15/16 ROWS — folded from the architect handoff into this
ledger (they were recorded there to avoid a write race with the then-
running implementer; the handoff's fuller prose remains the provenance):**
- **CF-14 — RULED (her UI call): the Encryption surface folds UNDER the
  Account button as a TAB**, not a sibling door ("account will one day
  show payment"). Both form factors through the shared seam; the sync
  row's separate "Encryption…" button retires into it; the LOCKED state's
  "Unlock…" door stays reachable in place (the fix-naming refusal's own
  affordance — never buried).
- **CF-15 — RULED: the sync row's buttons must not move.** The
  `isSyncing` branch replaces the row's content, so "Sync now"/"Account…"
  vanish and reappear every round (mechanism confirmed at
  SyncStatusViews.swift:45–47 vs :78–87). "Sync now" merely DISABLES
  while a round runs (the progress indicator may show beside the label);
  both platforms fix at once (MobileSettingsView embeds the same shared
  row). Pin: a syncing-state assertion that both buttons are present and
  "Sync now" is disabled.
- **CF-16 — the stale-key blindness, CONFIRMED above (Q3): ships in the
  crossover round, BEFORE her drill (her sequencing — the drill's step 3
  creates exactly this state on the phone and thereby VALIDATES it).**
  `refresh()` compares custody's `corpusKeyID`/`journalBridgeKeyID`
  against the fetched vault's class-key ids; a mismatch projects a
  distinct REPLACED state (copy shape: "This account's encryption keys
  were replaced. Enter your passphrase to re-enroll.") whose road is
  ordinary re-enrollment (the enroll save overwrites custody wholesale —
  the step-0 pin's proven class). The app-side classifier may also name
  the engine's `payloadCryptoFailure` refusal toward the same door
  (App-layer only — ZERO `Sync/` lines).

### THE CROSSOVER ROUND — brief (CF-14/15/16; a fresh Fable implementer;
### the cold pass covers this diff + the landed copy/flow diff together)

1. **CF-16 FIRST** (the drill validates it): the key-id comparison in
   `refresh()`, the replaced-state projection + copy, the re-enroll road,
   and the app-side classifier line for the crypto-failure refusal.
   Pins: replaced-state projection red-on-old (a vault with fresh key ids
   over stale custody currently reads `.enrolled` — that is the old
   behavior to pin against); the re-enroll-overwrites arm; the classifier
   arm.
2. **CF-14**: the Account sheet gains tabs (Account · Encryption — the
   shared-seam AccountView/EncryptionView composition); the sync row's
   "Encryption…" button retires; "Unlock…" under the locked state stays
   in place and opens the Encryption tab directly. Both form factors.
   Pin: the locked state still reaches the unlock surface in one act.
3. **CF-15**: the sync row's syncing state keeps "Sync now" (disabled) +
   "Account…" in place; the progress indicator rides beside the label.
   Pin: syncing-state presence + disabled assertions (the ruled shape).
Boundaries: zero `Sources/VariorumCore/Sync/` lines; zero schema/server/
production contact; core additive-only if genuinely needed (record why);
nothing beyond the three items. Acceptance: core + full Mac suite
(tripwire-only) + mobile + spine, own runs, synchronous waits, repo-first
record before long runs.

### Crossover round — record (implementer session, 2026-08-04)

**Commit: `910d30d`** — implementation + pins as ONE coherent diff
(589 insertions / 170 deletions), five files, ALL App-side:
`App/Variorum/Shared/EncryptionSession.swift` · `EncryptionViews.swift` ·
`AuthViews.swift` · `SyncStatusViews.swift` ·
`App/Variorum/VariorumTests/EncryptionFlowTests.swift`. **Scope proof:**
zero `Sources/VariorumCore/` lines (the brief's additive-with-reasons
carve was never needed — the key ids the comparison reads are already on
`DeviceKeyMaterial` and `KeyVaultFormat.classKey(for:)`, both public);
zero `Sync/`, zero schema/server, no production or dashboard contact, no
`.env*` reads, no new dependencies, the bridge untouched. No push (the
architect pushes after verification).

**The three items:**

1. **CF-16 (built FIRST, per the brief — her drill validates it).**
   - `EncryptionSession.VaultState` gains **`.keysReplaced(hasRecoveryWrap:)`**;
     `refresh()` now decides the custody arm by
     `custodyMatchesVault(custody, vault.format)` — a nonisolated pure
     static comparing custody's `corpusKeyID`/`journalBridgeKeyID`
     against the fetched vault's class-key ids (a vault missing either
     class entry counts as mismatch). Match ⇒ `.enrolled`; mismatch ⇒
     the honest REPLACED state. The projection itself touches nothing —
     custody is replaced only by the re-enroll save.
   - The surface renders the state with the RULED copy byte-exact
     (`EncryptionView.keysReplacedExplanation` = "This account's
     encryption keys were replaced. Enter your passphrase to
     re-enroll."), one caption in the standing refusal grammar ("The
     keys this device holds were replaced after it enrolled — sync stays
     paused until you re-enroll; nothing is lost while paused."), and the
     ORDINARY unlock roads (the shared `unlockRoads` — passphrase +
     the phrase reveal when the new vault carries a wrap). The enroll
     save overwrites custody wholesale — verified myself on the arm:
     `enroll(passphrase:)` → `adopt` → `store.save`, which is
     `SecItemUpdate` on the plain item / `saveGated` under a gate; the
     step-0 pin's proven class, now re-pinned from the replaced state.
   - **The classifier arm (App-layer only):**
     `EncryptionSession.isPayloadCryptoError(_:)` — true for the
     engine's `payloadCryptoFailure` refusal as the scheduler surfaces
     it. Its description carries row coordinates, so unlike the
     exact-match `isKeysLockedError` it anchors on the description's two
     invariant segments (`"Sync refused: '"` prefix + `"failed to
     encrypt/decrypt ("`), a conjunction that excludes the other
     "Sync refused:" case (`unencryptedValueInEncryptedColumn`, never a
     stale-key state). The row presents the classified refusal as
     `SyncStatusRow.keysReplacedLabel` ("Sync paused — this account's
     encryption keys were replaced") with a "Re-enroll…" door opening
     the Encryption tab directly.
   - **Documented boundary (not a gap):** a biometric-gated launch that
     hasn't unlocked cannot be compared (custody is unreadable), so it
     stays `.enrolledLocked`; the mismatch surfaces at the first
     post-unlock refresh, and the row's classifier names the refusal
     meanwhile. Stated in the refresh() comment.

2. **CF-14.** `AccountView` gains TABS — **Account · Encryption** — as a
   plain segmented control, both form factors through the one shared
   seam (`AccountTab` is top-level + nonisolated so the row's pure face
   model names a door's target tab as data;
   `init(services:initialTab:)` defaults to `.account`, so RootView's
   existing site compiles unchanged). `EncryptionView` becomes the
   Encryption TAB'S CONTENT — its own chrome (header row, Close,
   ScrollView, padding, macOS frame) moves to the sheet level; its
   `.task { refresh() }` rides the tab so selecting it projects fresh
   state. The sync row's separate "Encryption…" button RETIRES; the
   LOCKED state's "Unlock…" stays in place and opens the Encryption tab
   in ONE act (`openAccount(.encryption)` — the refusal's own
   affordance). The row's two sheets collapse to one
   `sheet(item: $accountSheetTab)`.

3. **CF-15.** The row is rebuilt to render from **`SyncRowFace`** — a
   nonisolated pure model (kind + doors) the pins assert at the state
   level; the view mints NO doors of its own, so the pinned shapes and
   the shipped row cannot diverge (the P-1 doors-as-data shape, applied
   at the row's scale). The `isSyncing` branch now returns kind
   `.syncing` with **"Sync now" present-but-disabled + "Account…"
   present**; the progress indicator rides beside the "Syncing…" label.
   All other faces keep their previous doors and wording verbatim
   (devStore/signedOut/syncOff/offline/locked/error/idle); the
   `ErrorCauseNote` renders exactly for the `.error` kind, as before
   (locked and replaced carry their own lines — the cause IS the line).
   Both platforms fix at once (MobileSettingsView embeds the same
   shared row; the mobile test bundle builds green against the diff).

**The hallucination guard — FOUR behavioral reverts, each run against
the pins, each red on its finding's exact mechanism, each restored (the
5-suite encryption family re-run green after restoration — 22 tests):**

1. *CF-16a* (refresh()'s custody arm reverted to the pre-fix
   custody-exists-alone `.enrolled`): both CF-16 pins failed —
   `session.state → .enrolled(hasRecoveryWrap: false)` where
   `.keysReplaced` is required — the false-enrolled blindness verbatim.
2. *CF-16c* (`isPayloadCryptoError` → constant false, the pre-round
   state): the classifier pin failed on both positive arms AND the row
   pin showed the refusal falling to the generic error face
   (`face.kind → .error`, doors Retry/Account…) — exactly the
   fails-generically shape the classifier closes.
3. *CF-15* (the face's `isSyncing` branch reverted to the old
   replace-the-content shape, `doors: []`): the pin failed all three
   assertions — `syncNow → nil`, no Account… — the vanishing buttons.
4. *CF-14* (the locked door's target reverted to `.openAccount(.account)`
   — Encryption buried behind a second act): the one-act pin failed on
   the doors equality, naming the buried target in the failure output.

**Test accounting:** 7 new tests in 1 new suite
(`CrossoverRoundTests`, in `EncryptionFlowTests.swift`): the CF-16a
projection pin · the CF-16b re-enroll-overwrites pin · the CF-16c
classifier pin · the replaced-row face + ruled-copy byte pin · the
CF-15 syncing-stability pin · the CF-14 one-act pin · the CF-14
retirement sweep (idle doors exact + no face anywhere mints an
"Encryption…" door + every encryption-targeted door belongs to
locked/replaced). Expected full-suite lines: Mac **1211 + 7 = 1218 /
213 suites** (the standing TakePane tripwire the ONE allowed red) ·
core **1156/124 unchanged** (zero core lines) · mobile **173/25
unchanged** (shared files recompile; no new mobile tests) · spine
**51/7**.

**PROVISIONALs / deviations (each with reasons):**

- **PROVISIONAL (the sheet's one dismissal):** the tabbed Account sheet
  keeps ONE borderless "Close" in the header row (the CF-1 grammar) and
  the old bottom "Done" with `.keyboardShortcut(.defaultAction)` is
  RETIRED. Reason: a defaultAction "Done" on the combined sheet would
  sit beside the Encryption tab's acts — CF-1's exact ambiguity
  re-created — and two dismissal controls with two words on one sheet is
  the incoherence class CF-2 was about. Options: (a) Close-only (built);
  (b) keep Done on the Account tab alone (two grammars, one sheet);
  (c) Done everywhere (re-opens CF-1). Hers to reverse at the walk.
- **PROVISIONAL (the replaced ROW wording):** `keysReplacedLabel`
  ("Sync paused — this account's encryption keys were replaced") and the
  door label "Re-enroll…" are derived from CF-16's ruled surface copy —
  the ruling specified the SURFACE sentence, not the row's. Same class
  as the held locked-line wording (the adjudication's stays-held item);
  one line each if her walk wants different words.
- **PROVISIONAL (the replaced caption):** one secondary line under the
  ruled headline, composed from the standing refusal grammar ("nothing
  is lost while paused"). Reason: the honest state should say WHY (the
  re-key happened after this device enrolled) without inventing new
  vocabulary.
- **Deviation (the macOS sheet floor):** the Account sheet's Mac minimum
  is now 460×340 (the pre-tabs EncryptionView floor) superseding
  AccountView's 440 — the sheet must fit its wider tab. The iPhone
  no-forced-width rule (R1-2) is preserved.
- **Deviation (`isKeysLockedError` marked nonisolated):** required so
  the nonisolated face model can consult it; call-compatible from every
  existing site (MainActor callers included), zero behavior change.
- **Held, unchanged:** the locked line's "passphrase" wording under a
  biometric gate (the adjudication's stays-held item) — untouched, still
  hers at the walk.

**Environment notes:** her real-store instance
(`/Applications/Variorum.app`, PID observed at session start) ran
throughout — never touched; no Release build, no `/Applications`
refresh. All runs from the `App/Variorum` `-project` invocation; no
GM-1 preparing-timeout occurred in any run this session.

**Acceptance (own runs, all waited synchronously, verbatim lines —
FINALIZED post-record per the repo-first rule):**
- Core `swift test` (repo root): **"✔ Test run with 1156 tests in 124
  suites passed after 32.523 seconds."** — baseline exact (zero core
  lines this round).
- Full Mac suite (`-project` invocation): **"✘ Test run with 1218 tests
  in 213 suites failed after 156.909 seconds with 1 issue."** — the one
  issue is the standing tripwire BY IDENTITY
  (`TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`,
  its own known assertion at TakePaneMeasureTests.swift:612), nothing
  else red; 1211 + this round's 7 in 1 new suite = 1218/213, exactly
  accounted.
- Mobile (iPhone 17 Pro sim): **"✔ Test run with 173 tests in 25 suites
  passed after 4.803 seconds."** + ** TEST EXECUTE SUCCEEDED **
  (test-without-building's success line) — baseline exact.
- The spine (the seven Tutorial suites, dedicated run): **"✔ Test run
  with 51 tests in 7 suites passed after 14.692 seconds."**
- Already run before this record: the 5-suite encryption family
  (Encryption/CopyFlow/Crossover/Terminology/LockedFace) — "✔ Test run
  with 22 tests in 5 suites passed"; Mac `build-for-testing` ** TEST
  BUILD SUCCEEDED **; mobile `build-for-testing` against the shared
  changes ** TEST BUILD SUCCEEDED **.

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
| L8 | Vault client + Keychain custody | **done — batch 3** (`80f2204`; single-flight PostgREST 1:1 with 08, refuse-by-version, 9c auth posture; Keychain custody with the R-6 biometrics door marked; DeviceKeySyncProvider = batch-2 PROVISIONAL 2 resolved) |
| L9 | Setup/enrollment flows, BOTH form factors (PL-6) + CHANGE PASSPHRASE (current-passphrase OR recovery-phrase authorized — her Round-7 scope addition) + the (re)generate-recovery-phrase surface | **done — batch 3** (`363d0b6`; ONE shared seam — EncryptionSession/EncryptionView + the sync face's locked line + Unlock/Encryption doors; SyncSession takes the required keyProvider; locked-provider pin: refusal + zero transport contact) |
| L10 | `resyncReinitialize` productized | **done — batch 3** (`e4e9908`; the vault-bootstrap executable per the concretization — create-or-unwrap, drain-bounded rounds, keys die with the process, dry-run writes nothing; 8 tests incl. the byte-level passphrase-file contract) |
| L11 | Bridge journal-class capability (paused) + touchpoint #2 concrete facts | **done — batch 3** (`80a6e5e`; the STRUCTURAL pause via the refusing default provider; AAD = journal_entries:<date>:body:<key_id>; the legacy-plaintext land rule PROVISIONAL; 105/9 bridge suites green over ciphertext + 7 pins, four arms revert-verified; contract block additive) |
| L12 | Phone KDF latency measured (R-7's condition) | **done — batch 3** (SIMULATOR 0.686 s, recorded as NOT the device number; the flow surfaces its own on-device number for the gate's step 5) |
| L13 | Disclosure list + warning wording for her ratify | **done — batch 3 → gate** (the GATE RATIFY block above the ladder section) |
| L14 | The ladder (combined diff) | **done — CLOSED at round 2** (R1: 1 MAJOR + 3 MINOR + 5 NIT all fixed revert-verified; R2: every disposition holds, zero new HIGH) |
| L15 | The gate steps 1–8 (deploy · setup · wipe-repush · phone enroll · recovery drill · refresh · ratifies) | steps 1–6 **done** (A1+export · 08 deployed marker 5 · her vault · wipe+repush+live dump proof · phone enrolled 0.16 s · phrase drill light road); step 7 refresh + step 8 ratifies ride the crossover tail (L21) |
| L16 | MobileSoul PL-6 updated at design time (done this sitting) + closeout parity line | PL-6 written; closeout line owed |
| L17 | The copy/flow round (CF-1…CF-13 + biometric) | **done** (`969ff83`+`a9b00fd`; 8+1 pins, five behavioral reverts; verified + adjudicated by the crossover architect — the adjudication section above) |
| L18 | The crossover round (CF-14 · CF-15 · CF-16) | pending — brief above; CF-16 before her drill |
| L19 | The mobile flow notes file (her coordination deliverable) | pending — `notes/plans/phase-14b-mobile-flow-notes.md` |
| L20 | ONE cold pass over the copy/flow + crossover diffs (REVIEW_PROMPT verbatim) | pending |
| L21 | HER ACCEPTANCE: the full re-key drill (runbook in the architect handoff; step 0 PINNED green) + the disclosure ratify + the `/Applications` refresh | pending — her go per step |
| L22 | Closeout ritual in full (incl. the 14c kickoff draft) | pending |

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
