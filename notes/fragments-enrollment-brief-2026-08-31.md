# BRIEF: suite enrollment & the passphrase-set ceremony — the facts and the format spec
### (2026-08-31 · carried by the author · self-contained for the Fragments agent)

**Provenance:** the author's question, surfaced in the lockbox exchange and carried to the Variorum
architect the same night — *"if fragments can't sign up and mint its own token, that's an issue for
it, right? can i give fragments the ability to do that?"* — plus the thread's sharper half: whether
a **Fragments-only account** can ever set its suite encryption passphrase, and therefore ever
enroll and ever lock. Her follow-up ordered this brief written now (*"I'd like to just carry it to
fragments now"*). The recorded carry item lives in `notes/fragments-bridge-contract.md` (Variorum
repo, read-only to you as ever — the "CARRY ITEM (2026-08-31)" section); this brief is
self-contained so you need only this file plus what it names.

**What this brief is and is not:** it equips the conversation with the FACTS and it is the **format
spec** that makes road (a) — Fragments hosting the same ceremony — buildable **if she rules it**.
It does NOT pre-decide that ruling (§5 states the roads with their honest costs and recommends
nothing beyond the record). The product frame first: this is about a Fragments-only *user* being
able to protect and recover their journal like any suite user — the crypto below is the plumbing
of that promise, not the point of it.

**The accuracy bar this brief was written to:** every format claim below was read from the
Variorum implementation on 2026-08-31 (branch `main`), with file:line citations so you can verify
each claim yourself — the render-don't-re-derive discipline, applied to crypto formats where
paraphrase is corruption. **No secrets, keys, or tokens appear anywhere in this file** — KDF
parameters and formats are public-by-design; credentials are not, and none are included.

---

## 1. THE QUESTION AND THE TWO-LAYER ANSWER

**Layer 1 — sign-up + tokens: ALREADY POSSIBLE without Variorum.** There is ONE stargazing
account. Its home and OAuth 2.1 issuer is the Variorum Supabase project —
*[removed for publication]*
ruling made the project itself the issuer, and 14d retired every Fragments-side password door —
SyncSpec §2's dated record). Signups are **OPEN** since 14d, with custom SMTP and branded
auth-email links live. Fragments signs in DELEGATED through the suite issuer's browser flow
already. So a Fragments-only user can create the account and hold tokens **today** — *if*
Fragments' sign-in flow surfaces the signup door. If it doesn't, that is a Fragments-side FACE fix
over the same issuer, not a suite change. **The forbidden shape is a second auth/account system** —
that would resurrect exactly what 14d retired ("there is a single stargazing account").

**Layer 2 — the passphrase-SET ceremony lives ONLY in Variorum today.** The answer to the lockbox
thread's question is currently NO: a Fragments-only account has no surface anywhere that can create
the vault, set/change the passphrase, or mint the recovery phrase. But **nothing server-side
prevents another client from performing the ceremony**: the vault is client-side crypto against a
plain authenticated PostgREST table under owner-only RLS (§2.5) — the server never participates in
key derivation and holds no key to anything. The vault row is provisioned per-account since 14c, so
a fresh signup has a home for its vault the moment any client creates one. §2 below is the complete
format; an independent implementation that follows it interoperates byte-for-byte with Variorum's.

---

## 2. THE CEREMONY FORMAT SPEC (read from code 2026-08-31 — citations are Variorum repo paths)

### 2.1 The key hierarchy and the vault payload

- **One master key** (256-bit, CSPRNG — `Sources/VariorumCore/Crypto/VaultEnrollment.swift:87`),
  wrapped **twice**: by the passphrase-KDF key and by the recovery-phrase key. The recovery wrap is
  **nullable by design** — a vault may be born with the passphrase wrap alone and gain the recovery
  wrap later, in the user's presence (`KeyVaultFormat.swift:18–25`, the 14b Round-5 arrangement).
- **Per-class keys under master** (14b ruling R-8): exactly two in v1 — `corpus` (Variorum's sync
  payloads) and `journal_bridge` (the shared journal class, the only one Fragments ever touches).
  Each is 256-bit CSPRNG with a **plaintext key id** = a **lowercased UUID string**
  (`VaultEnrollment.swift:88–91`), each wrapped by master. The key id rides every ciphertext's AAD
  (§2.7) so a value can never be silently re-attributed to a different key
  (`KeyVaultFormat.swift:48–61`).
- **Format version:** `1`, and the only one (`KeyVaultFormat.swift:34`). Every operation on a vault
  carrying a newer version REFUSES (`requireCurrentFormat`, `KeyVaultFormat.swift:261–265`); the
  client also refuses newer rows at decode (`KeyVaultClient.swift:409–412`). Never guess at a
  future format.

### 2.2 The wrap construction (RFC 3394)

All wraps — master-by-passphrase-key, master-by-recovery-key, class-key-by-master — are **AES Key
Wrap, RFC 3394**, via CryptoKit `AES.KeyWrap.wrap/unwrap` (`KeyVaultFormat.swift:82–88, 267–273`).
Integrity is built in: unwrapping with a wrong key or over flipped bytes REFUSES — it never yields
garbage key bytes, and wrong-key vs tampered-wrap are **indistinguishable by design**
(`KeyVaultFormat.swift:299–301`). Wrapping a 32-byte key yields the standard 40-byte RFC 3394
output. Variorum maps the enrollment-time unwrap failure to "wrong passphrase" because the typo is
the overwhelmingly likely cause (`VaultEnrollment.swift:119–124`).

### 2.3 The passphrase KDF (Argon2id)

`Sources/VariorumCore/Crypto/PassphraseKDF.swift`; implementation is the vendored PHC reference
(`Vendor/CArgon2/`, upstream `P-H-C/phc-winner-argon2` pinned at commit
`f57e61e19229e23c4445b85494dbf7c07de721cb`, byte-verbatim, compiled `ARGON2_NO_THREADS` — its
README is the notice).

- **Algorithm:** Argon2id, identifier string `"argon2id"` (`PassphraseKDF.swift:28`), Argon2
  version **0x13** (19) — the only accepted version (`PassphraseKDF.swift:104–107`). The call is
  `argon2id_hash_raw` — the RAW variant, no PHC string encoding (`PassphraseKDF.swift:122–129`).
- **v1 default parameters** (`Descriptor.v1`, `PassphraseKDF.swift:73–83`): **m = 65536 KiB
  (64 MiB) · t = 3 iterations · p = 1 lane · 16-byte random salt · 32-byte output** (an AES-256
  wrap key). Salt is CSPRNG, minted fresh per descriptor (`PassphraseKDF.swift:90–92`); one lane is
  deliberate (the vendored build is single-threaded, so extra lanes buy nothing and one lane keeps
  derivation identical everywhere — `PassphraseKDF.swift:44–48`).
- **THE DESCRIPTOR IS TRUTH, NEVER APP DEFAULTS.** The exact parameters used are **versioned and
  stored in the vault row beside the wrap** (§2.5), and every derivation honors the STORED
  descriptor (`PassphraseKDF.swift:31–33, 98–100`; `VaultEnrollment.swift:117` derives from
  `vault.kdf`). This is what makes a future KDF change a one-key re-wrap instead of a corpus
  re-encrypt (14b R-7's soft door). An independent implementation MUST derive from the fetched
  descriptor and MUST refuse out-of-range ones — Variorum's accepted ranges: output 16–64 bytes,
  memory ≥ 8×parallelism KiB, all three costs > 0, non-empty salt (`PassphraseKDF.swift:108–115`).
- **Normalization:** the passphrase is **NFKD-normalized then UTF-8 encoded** before hashing
  (`decomposedStringWithCompatibilityMapping`, `PassphraseKDF.swift:117`) — the same convention
  BIP-39 uses — so the same characters typed on any device derive the same key regardless of the
  platform input's composition form. **Both apps must normalize identically or the same passphrase
  will fail cross-app.**
- **Policy floor:** core enforces only NON-EMPTY (`VaultEnrollment.swift:305–309`); length policy
  is UI wording (the headless runner warns below 12 characters but proceeds —
  `VaultBootstrap.swift:86–91`). Cost expectation: ~64 MiB transient, tenths of a second, run
  off-main, at enrollment cadence only (`VaultEnrollment.swift:52–56, 287–300`).

### 2.4 The recovery phrase (BIP-39)

`Sources/VariorumCore/Crypto/RecoveryPhrase.swift`; wordlist provenance `Vendor/BIP39/README.md`
(upstream `bitcoin/bips` `bip-0039/english.txt` at commit
`e7263a4cfe500c89e4269889244606953691ca33`; SHA-256
`2f5eed53a4727b4bf8880d8f3f199efc90e58503646d9ff8eff3a2ed3b24dbda`; bundled at
`Sources/VariorumCore/Resources/bip39-english.txt`).

- **Format:** exactly **12 words** — other BIP-39 lengths are deliberately refused
  (`RecoveryPhrase.swift:20–23`). **128-bit CSPRNG entropy**; checksum = first **4 bits of
  SHA-256(entropy)** appended to make 132 bits = 12 × 11-bit indices into the **2048-word English
  wordlist** (`RecoveryPhrase.swift:74–86`). Validation is forgiving on input (whitespace trimmed,
  case folded — `RecoveryPhrase.swift:181–185`) and typed on refusal: wrong count, unknown word
  (named), checksum mismatch (`RecoveryPhrase.swift:95–126, 197–210`).
- **Derivation to the recovery wrap key** — every constant is FORMAT; changing any silently orphans
  existing recovery wraps (`RecoveryPhrase.swift:11–18`):
  1. **BIP-39 seed:** PBKDF2-HMAC-SHA512, password = the NFKD-normalized 12-word sentence (words
     joined by single spaces), salt = `"mnemonic"` + NFKD passphrase — **the product path always
     uses the empty passphrase** (the parameter exists only for the spec test vectors) — **2048
     iterations, 64-byte output** (`RecoveryPhrase.swift:130–164`).
  2. **Wrap key:** HKDF-SHA256 over the 64-byte seed, salt = UTF-8 `"variorum.suite.e2ee.v1"`,
     info = UTF-8 `"recovery-wrap-key"`, **32-byte output** (`RecoveryPhrase.swift:28–31,
     166–177`).
- The phrase is the disaster road: high-entropy by construction, so no Argon2 stretching rides this
  path — its derived key wraps master directly (`RecoveryPhrase.swift:11–15`).

### 2.5 The `key_vault` row, its access, and the `revision` CAS

DDL: `Server/supabase/08_phase14b_lockstep.sql` (deployed; marker 5's event). One row per account:
`user_id uuid PK` referencing `auth.users(id)` on delete cascade, then **flat columns mapping 1:1
to the format** — `format_version`, the six KDF descriptor columns (`kdf_algorithm`,
`kdf_argon2_version`, `kdf_memory_kib`, `kdf_iterations`, `kdf_parallelism`, `kdf_salt`,
`kdf_output_bytes`), `master_wrapped_by_passphrase`, `master_wrapped_by_recovery` (**nullable by
design**), `corpus_key_id`, `corpus_key_wrapped_by_master`, `journal_bridge_key_id`,
`journal_bridge_key_wrapped_by_master`, `revision integer not null default 1`, timestamps
(`08_phase14b_lockstep.sql:60–95`). **All key material travels as base64 TEXT.** The wire row's
exact JSON keys: `KeyVaultClient.swift:328–346` (`KeyVaultWireRow.CodingKeys`).

- **Access:** plain authenticated PostgREST at the Variorum project — `rest/v1/key_vault` — under
  **owner-only RLS** (select/insert/update policies bound to `auth.uid()`; `anon` revoked; **no
  delete policy, deliberately** — losing a vault orphans the whole ciphertext corpus, so removal is
  an account-deletion-scale server-side act; `08_phase14b_lockstep.sql:97–118`). The vault is
  ACCOUNT data, never a sync-mirror table; the sync engine never touches it
  (`KeyVaultClient.swift:3–10`). Headers: `apikey` = the publishable key (grants nothing itself),
  `Authorization: Bearer <access token>`; a 401 gets **ONE refresh-and-retry**, a second 401
  surfaces — never a loop (`KeyVaultClient.swift:220–246`). The row's `user_id` is always the
  SESSION's user, never caller-supplied (`KeyVaultClient.swift:15–17`).
- **Create:** POST with `Prefer: return=minimal`; an existing row REFUSES (HTTP 409 →
  `vaultAlreadyExists`) — **idempotence by refusal, never overwrite**
  (`KeyVaultClient.swift:145–166`; the setup flow also pre-checks —
  `VaultEnrollment.swift:82–86`).
- **THE CAS DISCIPLINE (binding on every update):** a fetch returns the format PLUS the row's
  `revision`; **every update PATCHes with the filter `revision=eq.<fetched>` and writes
  `revision = fetched + 1`** (`KeyVaultClient.swift:181–216`; `08_phase14b_lockstep.sql:81–87`).
  `Prefer: return=representation` makes zero-matched-rows detectable: an empty result means the
  vault is absent OR another device moved it — a fresh read disambiguates, and either answer sends
  the caller back to CURRENT state. **Refetch and re-derive; never blind-retry, never force** — the
  pre-fix failure this exists to prevent was a stale full-row PATCH silently reverting a freshly
  regenerated recovery wrap to discarded words. A decoder must default a missing `revision` to 1
  (`KeyVaultClient.swift:348–354, 376`).
- **⚠️ Interop trap, real:** the update PATCH sends the FULL row, and Variorum's encoder **OMITS**
  `master_wrapped_by_recovery` when nil rather than sending JSON `null`
  (`KeyVaultClient.swift:348–354` — the synthesized-encoding nil-omission, kept deliberately).
  Under PostgREST, an omitted key leaves the column untouched while an explicit `null` would
  **erase the recovery wrap**. An independent implementation must never send that key as `null`.
- **One recorded discrepancy, resolved in the client's favor:** `08_phase14b_lockstep.sql:89–94`
  says `updated_at` is insert-time-only; the CLIENT has stamped it on every update since the 14c
  vault touch (`KeyVaultClient.swift:184–192, 321–326`). The client is current truth; the stamp is
  display bookkeeping only — `revision` is the only ordering/CAS token, ever.

### 2.6 The flows (what the ceremony DOES — `VaultEnrollment`, the one shared brain)

`Sources/VariorumCore/Crypto/VaultEnrollment.swift` — pure orchestration shared verbatim by
Variorum's Mac app, phone, and headless runner; **custody is always the CALLER's** (the returned
`DeviceKeyMaterial` — master + both class keys + their ids as one Codable blob,
`VaultEnrollment.swift:10–35` — goes to the device Keychain in the app, process memory in the
runner).

- **Setup (first device)** — `setUp(passphrase:)` (`:80–107`): refuse empty; refuse if a vault
  exists; mint master + corpus + journal-bridge keys (256-bit each) + lowercased-UUID key ids;
  fresh 16-byte salt + v1 descriptor; derive; build the format **with the passphrase wrap ONLY**;
  POST the row. The recovery wrap is NOT minted here — see the choreography below.
- **Enroll (new device)** — `enroll(passphrase:)` (`:114–127`): fetch vault → derive from the
  **stored** descriptor → unwrap master → unwrap both class keys → return material. Absent vault
  and wrong passphrase refuse typed. `enroll(recoveryWords:)` (`:133–143`) is the disaster road's
  twin — phrase validation errors speak as themselves; refuses if the vault has no recovery wrap
  yet.
- **The recovery-phrase choreography (ruled, binding):** generate → the user **writes the words
  down** → **confirm by re-entry** → only THEN `landRecoveryWrap(words:material:)` lands the wrap
  (`:153–183` — it takes the RE-ENTERED words, never the freshly-generated set directly). First
  generation rides the strict add-only door; **replacing** an existing wrap requires
  `allowReplace: true`, which a UI passes only after an explicit confirm (`:164–177`;
  `KeyVaultFormat.swift:126–171`). Both doors **verify the caller's master against the vault's
  class keys first** so a wrong master can never become the disaster road
  (`KeyVaultFormat.swift:133–135`). The phrase is displayed **at set time, on the same screen as
  the passphrase** (the knot-4 ruling; `App/Variorum/Shared/PassphraseSetModel.swift:17–24`) — the
  lockbox reply's ruling 4 already binds Fragments to the same display.
- **Change passphrase** — `changePassphrase(authorizedBy:newPassphrase:)` (`:198–234`): authorized
  by the CURRENT passphrase **or** the recovery phrase (the forgot-passphrase road); fresh salt +
  descriptor; re-wrap master; **the recovery wrap and class keys are untouched** — independent
  wraps, one-key re-wrap, never a corpus re-encrypt. CAS-guarded like every vault write. (Variorum
  additionally has `rewrapPassphrase(material:newPassphrase:)` — the 13p reset door: re-wrap from
  HELD device material after biometric confirmation, no old passphrase; `:245–257`. Whether
  Fragments ever needs that door is a product call, not part of this spec's floor.)
- **The secret-check face** (what the lockbox reply's Q3 named): a READ-ONLY real unwrap — fetch
  the vault, derive with its stored parameters, attempt the unwrap, discard the result; **nothing
  written, nothing reset** (`App/Variorum/Shared/SecretCheck.swift`, header). The doctrine inside
  it binds any implementation: **there is no stored hash of the passphrase anywhere in this system
  and there must never be one** — the RFC 3394 unwrap attempt IS the verification; a comparable
  artifact is an offline-attackable object.

### 2.7 The `e1:` wire format and the AAD grammar

`Sources/VariorumCore/Crypto/PayloadCipher.swift` (the format's record is its own doc comment):

- **AEAD:** AES-256-GCM, **per-value random 96-bit nonce** (CryptoKit-generated). **Encoding:**
  `e1:` + base64(nonce ‖ ciphertext ‖ tag) — a version-prefixed string in existing TEXT columns
  (`PayloadCipher.swift:4–28, 65–82`). Minimum decodable body: 28 bytes (12-byte nonce + 16-byte
  tag; `:107–110`). The empty string seals fine — the tag still authenticates the binding
  (`:63–65`).
- **AAD:** UTF-8 `table:rowID:column:keyID` (`PayloadCipher.swift:37–53`) — a ciphertext cannot be
  swapped between rows/columns or re-attributed to a different key without the open refusing, even
  though ids stay plaintext.
- **The per-class key is used DIRECTLY** — no per-table HKDF subkeys in v1 (`:17–24`; the `e1:`
  prefix + the vault's `format_version` leave an `e2:` format addable with zero ambiguity).
- **Refusals are typed and total** (`:84–124`): no prefix → `notEncrypted` (the caller decides
  whether plaintext passthrough is legal at ITS seam); a foreign `e<digits>:` prefix →
  `unsupportedVersion` (ASCII digits only — `:126–143`); bad base64 / short body → malformed; wrong
  key / wrong AAD / tampered bytes → `authenticationFailed`, nothing returned.
- **The bridge's binding — the one Fragments already speaks**
  (`Sources/VariorumCore/Bridge/BridgeEncryption.swift:14–33`):

      AAD = UTF-8("journal_entries:<yyyy-MM-dd day>:body:<journal_bridge_key_id>")

  — the standard grammar with the DAY standing in the rowID slot (both sides always know the day;
  a ciphertext can never move between days undetected). The landing side passes legacy plaintext
  through **only** on the `.notEncrypted` arm — a future-version ciphertext refuses rather than
  landing as text, and a tampered `e1:` body refuses as ever (`BridgeEncryption.swift:46–68`).

---

## 3. WHAT FRAGMENTS ALREADY HOLDS vs WHAT A SET-CEREMONY BUILD WOULD ADD

**Already yours (shipped, per the contract's 14d record):** delegated sign-in at the suite issuer
(tokens); journal-class sealing/opening in the exact `e1:` + day-AAD format above, under the
`journal_bridge` class key — confirmed as the ruled key for journal content on both ends (the
lockbox reply, Q1); and — per your lockbox spec's adoptions — the `CustodyHandover`
write-verify-then-delete discipline and the distinct-service/account Keychain rules (lockbox reply
Q2/Q6). How your side currently *obtains and holds* the journal-bridge key is your side's fact —
this brief asserts nothing about your custody road beyond what the contract records.

**What road (a) would add — the SET half, item by item (each maps to §2):**
1. **Vault creation** on a vault-less account (§2.6 setUp): the passphrase set + the one honest
   warning (unrecoverable-by-design is its whole content).
2. **Recovery-phrase mint + same-screen display + confirm-by-re-entry + wrap landing** (§2.4 +
   §2.6's choreography — the write-down/re-enter order is ruled, not stylistic).
3. **Enrollment doors** (passphrase and recovery-words), if not already present in your flow.
4. **Change passphrase** (current-passphrase OR recovery-phrase authorization).
5. **A secret-check equivalent** (read-only real unwrap; no stored hash, ever) — the lockbox
   reply's Q3 already rules the minimal prompting set around it.
6. **The CAS discipline on every vault write** (§2.5) — including the nil-omission trap.

One sizing observation, stated without recommending: items 3–6's crypto substrate is small and
fully specified above; the real cost is item 2's ceremony UX plus the ongoing obligation that two
implementations of the suite's most safety-critical custody flow now track one spec (§5's honest
cost).

---

## 4. THE SUITE DOCTRINES THAT BIND ANY BUILD (whichever road she rules)

1. **One-secret (Variorum R13p-4, extended by the 14b design):** both apps present ONE passphrase
   identity — never a "Fragments passphrase" beside a "Variorum passphrase." Concretely: where a
   vault exists, a set-surface must verify the typed passphrase IS the vault's by the real unwrap
   and **extend** it, never mint a second (`PassphraseSetModel.swift:17–24` is the shipped shape).
2. **R-4 — enrollment-by-passphrase is v1's road**, and **R-6 — enrollment-only cadence**: the
   one-time unwrap persists in device custody; day-to-day sync never re-prompts. Unlock cadence
   (biometric gates, re-lock) is **device-local policy, never part of the vault format, the
   ciphertext, or the protocol** (`notes/plans/phase-14b-suite-e2ee.md:171–209`). These stand
   unless a suite ruling changes them.
3. **The NEVER list:** never a second issuer or account system (14d: one stargazing account);
   never weaken the vault's CAS (no blind retry, no forced overwrite, no create-over-existing);
   never a "Fragments passphrase" identity; never a stored/comparable artifact of the passphrase
   (§2.6's secret-check doctrine); never send `master_wrapped_by_recovery` as JSON `null` (§2.5's
   trap).
4. **T1 — the stale-copy recency warning (suite doctrine as of 2026-08-31,
   `notes/plans/pre-13u-memo-security-shapes.md` §9b):** any Replace-Keys/reset road where a local
   copy becomes truth must, before the re-push, compare recency against the server and **warn in
   the concrete count-and-dates form** ("12 notes this copy doesn't have, newer versions of 9
   others, latest Aug 28" — ids/dates/seqs are deliberately plain, so a keyless machine can count
   without reading content), and must verify a near-empty local copy cannot silently push
   emptiness over a full server. If Fragments ever builds or touches a Replace-Keys-shaped door,
   this binds it.
5. **Layer separation, so nothing gets conflated:** the SUITE passphrase/vault (this brief's
   subject — sync-payload E2EE, 14b) ≠ **Variorum's store key** (13p whole-store encryption,
   device-bound, never shared — the lockbox reply's Q1 already refused sharing it) ≠ **Fragments'
   own at-rest lockbox** (your `phase-20.9-memo-lockbox.md` + the 2026-08-31 reply,
   `notes/fragments-lockbox-reply-2026-08-31.md`). The Fragments-only enrollment question concerns
   the FIRST layer only.
6. **The presentation law**, if ceremony surfaces get built on your side
   (`notes/plans/pre-13u-memo-security-shapes.md` §§1–4, the suite's ratified model): the ONE LAW
   (the passphrase protects the SERVER's copy; an enrolled device is a pre-assembled recipe), the
   four credentials, recipes-not-matrices, escrow-follows-the-posture — and the keystone copy
   lines land **essentially verbatim** (render, don't re-derive; almost-true sentences are how the
   original confusion got built).

---

## 5. THE OPEN RULING — stated for her conversation, recommending nothing beyond the record

- **Road (a) — Fragments implements the SAME ceremony against the SAME vault, to this written
  spec.** Right if Fragments-only users are a real audience she wants enrolled and locked (and
  under the lockbox rulings, lock-ON *requires* enrollment — so without some ceremony road, a
  Fragments-only user can never lock). Cost, named honestly in the carry item: **a second
  implementation of the suite's most safety-critical custody flow — the forked-brains drift class
  at suite scale.** The mitigation is exactly this document: one written format both apps
  implement, so neither app's code is the de-facto spec. If (a) is ruled, this brief becomes a
  living contract deliverable — format changes land HERE first, through this channel, before
  either implementation moves.
- **Road (b) — accept-and-state the degraded state:** Fragments-only users are unenrolled until
  they first touch Variorum; Fragments' lockbox/journal-class behavior for the unenrolled must
  then be DEFINED and honest (your side's call), never a silent difference.
- **Road (c) — a web-hosted ceremony on stargazing.tech is NOT recommended** (the carry item's
  standing note): client-side crypto in a browser is a different trust posture, and the v1 posture
  has no web app by ruling.

The ruling is hers, with you, in this conversation.

## 6. PROCESS

Questions come back through this channel (`notes/fragments-bridge-contract.md` carries a pointer
to this brief); she carries everything, both directions. Cited Variorum paths are read-only to you
as ever. Nothing in this brief asks for Fragments-side work — it equips a decision.
