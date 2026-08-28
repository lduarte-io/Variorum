# Phase 13p — Batch 0: The Spike's Decision Memo

**Status: COMPLETE. Verdict: READY FOR BATCH 1 — GO.**
Run 2026-08-27 by the Batch 0 Opus implementer, per the BATCH 0 section and
BATCH 0 ADDENDUM of `notes/plans/phase-13p-note-protection.md`.

This is the Phase 6 pattern: evidence before commitment. **Nothing from the
spike lands on `main` but this memo.** The working tree that produced every
number below is preserved on the scratch branch named in Q4.

---

## THE HEADLINE, IN FIVE LINES

| Q | Question | Verdict |
|---|---|---|
| **Q1** | FTS5 in Zetetic's prebuilt binary? | **PRESENT.** No contingency needed. 13o is unblocked. |
| **Q2** | Perf against P1? | **PASSES, comfortably.** Keystroke road ~1.0×; the only road above 1.15× is a deliberate full-corpus scan. |
| **Q3** | `kSecAttrSynchronizable` + biometric ACL? | **`errSecParam` (-50).** The two-item design is platform fact. |
| **Q4** | Fork mechanics end-to-end? | **CLEAN.** Both apps build; all three suites at exact baseline. |
| **Q5** | The backup trap | **REAL, but NOT the predicted shape** — a loud refusal, not a silent leak. See the correction; it changes Batch 1's pin. |

**Three findings correct the plan's own record.** They are called out in place
and collected under SURPRISES at the end. None of them threatens the phase;
one of them (Q5) changes what Batch 1 must build and must not be missed.

---

## ENVIRONMENT (the measurement authority)

- **Machine:** the author's M3 Mac — dev = acceptance, per AppSpec §1.
- **OS:** macOS **26.5.2** (build 25F84). **Toolchain:** Swift **6.2.4**
  (swiftlang-6.2.4.1.4), Xcode 26, target `arm64-apple-macosx26.0`.
- **GRDB:** **v7.11.1** — which is both the current latest 7.x *and* exactly
  what `main`'s `Package.resolved` already pins. **There is no version drift
  in any number below**: the only variable between the control and the
  experiment is SQLCipher itself.
- **SQLCipher:** `sqlcipher/SQLCipher.swift` **4.18.0** (prebuilt
  XCFramework). Reported by the binary: `cipher_version` = **4.18.0
  community**, `cipher_provider` = **commoncrypto**, `cipher_provider_version`
  = 61901.120.67, `sqlite_version()` = **3.53.4**.
  - `cipher_provider = commoncrypto` is load-bearing for the perf story: AES
    runs through Apple's CommonCrypto, i.e. **hardware AES**, which is why the
    overheads below are as small as they are (and why the phone leg is
    expected to behave the same way — see Q2's phone note).
- **Scratch root (outside the repo, per the addendum):**
  `~/dev/scratch-13p-spike/` — containing `GRDB.swift/` (the fork clone),
  `SpikeProbe/` (the Q1/Q3 probe), and the two saved output logs
  `q1-q3-probe-output.txt` and `q2-q5-measurements.log`.

---

## Q1 — IS FTS5 IN ZETETIC'S PREBUILT BINARY?

### VERDICT: **PRESENT.** No contingency is needed; nothing goes back to the author.

Research record #8 flagged this as genuinely unknown ("it requires an explicit
build flag; the prebuilt's flags are not published"). It is now published, by
asking the binary.

**What was done.** A throwaway SPM executable
(`~/dev/scratch-13p-spike/SpikeProbe`) linking the local GRDB+SQLCipher fork,
opening a **genuinely encrypted** database with the raw-key pragma, then
interrogating and exercising it.

**The direct evidence — the binary's own compile flags.** `PRAGMA
compile_options` returned 57 entries. The FTS-bearing ones:

```
ENABLE_FTS3   ENABLE_FTS3_PARENTHESIS   ENABLE_FTS4   ENABLE_FTS5
```

`HAS_CODEC` is present in the same list (confirming this is the SQLCipher
build, not a system-SQLite fallback), as are `ENABLE_RTREE`,
`ENABLE_SESSION`, `ENABLE_SNAPSHOT`, `ENABLE_STAT4`, `ENABLE_PREUPDATE_HOOK`,
`ENABLE_COLUMN_METADATA`, and `ENABLE_DBSTAT_VTAB`.

**The behavioural evidence — what actually matters.** Flags can lie; queries
cannot:

```
CREATE VIRTUAL TABLE t USING fts5(body)                       ✔
INSERT × 2, SELECT count(*)                                   ✔  rows=2
SELECT body FROM t WHERE t MATCH 'variant'                    ✔  hits=1
SELECT snippet(t, 0, '[', ']', '…', 8) … ORDER BY rank        ✔
   → "the variorum preserves its [variant] readings"
```

`snippet()` and `rank` are exercised deliberately: they are the two FTS5
facilities a search UI actually needs, and they live in the auxiliary-function
layer that a minimal build is most likely to omit.

**Q1b — GRDB's own FTS5 Swift API also works.** `db.create(virtualTable:
using: FTS5())` plus a MATCH query succeeded. So 13o may use the typed GRDB
API, not only raw SQL. (GRDB's `Package.swift` already defines
`SQLITE_ENABLE_FTS5` in its own `swiftSettings`, and the fork preserves that.)

**Also confirmed in the same probe** (cheap, and it pins two things the phase
rests on):
- The file on disk is **ciphertext**: first 16 bytes
  `c68afd9f1341d9836382956b4c02a2f4`, no `SQLite format 3` header.
- An **unkeyed open is refused**: `SQLite error 26: file is not a database`.
- `DEFAULT_MMAP_SIZE=0` in the compile options — **research record #4
  re-confirmed from the binary's own side**, not just from GRDB's API surface
  and this repo's grep.

### Handed to 13o as ruled input

1. **FTS5 is available.** The technical fork at 13o's kickoff (FTS5 vs sweep
   vs custom index) may include FTS5 without a dependency question.
2. **Encryption strengthens the FTS5 case, and Q2 measured how much.** An
   index walk touches a bounded set of pages; a full-corpus scan decrypts
   everything. Measured on the 10,095-block corpus: a cold indexed one-row
   lookup costs **1.11–1.14×** encrypted, while a cold **full scan** of
   `variant` costs **1.72–2.32×**. THE DESIGN's search paragraph predicted
   exactly this shape; it is now a number. **The LIKE-scan road is the one
   encryption actually penalises** — which is the road 13o should decline at
   scale anyway.
3. R13p-16(b) already dissolved the display gate: the index may contain **and
   display** everything.

---

## Q2 — PERF AGAINST P1

### VERDICT: **PASSES.** P1 is not threatened on any road the author's fingers touch.

### Method (stated because it is what makes the ratios mean anything)

- **Corpus:** 1,000 posts × 10 blocks + the Phase 4 fixed probes = **10,095
  blocks**, ~15.9 MB — built **on disk** through the real Operations layer,
  mirroring `Tests/VariorumCoreTests/Support/CorpusFactory.swift` (so each
  build is also a scale smoke test of the ops layer). Seeded deterministically
  (`SeededGenerator(seed: 7)`, `.incrementing` UUIDs, a ticking clock), so the
  encrypted store and the plaintext control hold **identical content with
  identical row ids** — asserted in the harness, not assumed. Per the A1 rail,
  the author's real store was never opened, copied, or touched.
- **THE CONTROL IS THE SAME BINARY, UNKEYED.** With the fork linked, *every*
  store runs on SQLCipher's SQLite. The control is therefore SQLCipher-with-
  no-key, which isolates **the cost of encryption**. A control built on the
  system SQLite would have confounded encryption with a whole SQLite swap, and
  every ratio below would have been unreadable.
- **Statistics:** median of 20 (autosave: 40; cold-open: 15; cold-cache: 10),
  one warm-up discarded — the `PerfBenchmarkTests` house method.
- Machine otherwise quiet; no concurrent builds during the measurement run.

### The numbers

**Cold open — the R13p-5 at-open cost, and the design's key claim**

| road | plaintext | encrypted | ratio |
|---|---|---|---|
| cold open + first read, **raw key** | 0.92 ms | **1.04 ms** | **1.12×** |
| cold open + first read, **KDF** (`sqlite3_key`) | — | **165.4 ms** | **~165×** |

**This is the single most consequential number in the spike.** The raw-key
road (`PRAGMA key = "x'…'"`) opens a real encrypted store in **~1 ms** — the
KDF is bypassed exactly as research record #3 promised. The KDF road costs
**165 ms**, ~165× more.

**Consequence, and it is a real trap for Batch 1:** GRDB's own
`db.usePassphrase(_:)` is the **KDF road** — it calls `sqlite3_key()` with the
bytes, which runs 256,000 PBKDF2-HMAC-SHA512 iterations, whether you hand it a
passphrase or 32 random bytes. GRDB exposes **no raw-key convenience at all**.
So Batch 1 must issue the pragma as SQL in `prepareDatabase` and must **not**
reach for the obviously-named method. THE DESIGN already says the pragma; this
memo pins *why*, with the number, so nobody "tidies" it later.

**Warm read probes** (Phase 4's own, on disk, steady state)

| probe | plaintext | encrypted | ratio |
|---|---|---|---|
| `renderPost` (50 blocks) | 0.578 ms | 0.575 ms | 0.99× |
| `assembleReading` (50 posts) | 0.492 ms | 0.479 ms | 0.97× |
| `timelinePage` (50, keyset, page 2) | 0.925 ms | 0.924 ms | 1.00× |
| `library` (limit 50) | 0.588 ms | 0.587 ms | 1.00× |
| `tagSubtree` (6 tags) | 0.565 ms | 0.607 ms | 1.07× |

**Cold-cache reads** — the honest companion, because a warm median re-reads
pages already decrypted in the page cache. Fresh pool per sample, empty cache,
every page decrypted for real:

| probe | plaintext | encrypted | ratio |
|---|---|---|---|
| fresh pool + indexed 1-row lookup | 1.072 ms | 1.192 ms | **1.11×** |
| fresh pool + **FULL SCAN** of `variant` | 2.286 ms | 5.311 ms | **2.32×** |

The full scan is deliberately the worst case in the whole spike, and it is the
only figure above 1.15×. It is also not a road the app takes: every shipped
read is viewport-shaped by P1.

**The keystroke road — the one that decides whether encryption is felt**

| probe | plaintext | encrypted | ratio |
|---|---|---|---|
| `autosave` into a **50-block** post | 1.410 ms | 1.304 ms | 0.93× |
| `autosave` into a **5-block** post | 1.275 ms | 1.323 ms | 1.04× |
| **P1's own assertion:** encrypted 50-block ÷ encrypted 5-block | | | **0.99×** |

Across three full runs the autosave ratio ranged **0.93×–1.09×** — i.e. inside
run-to-run noise on a machine where a single autosave costs ~1.3 ms either way.
**And the P1 invariant itself holds under encryption**: autosave cost stays
flat in post length (0.99–1.01× across runs), which is the property
`autosaveIsFlatInPostLength` exists to defend.

**Bulk write, storage, concurrency**

| measure | plaintext | encrypted | ratio |
|---|---|---|---|
| build the whole 10,095-block corpus through Operations | 14,859 ms | 16,486 ms | **1.11×** |
| store file size | 15.9 MB | 16.4 MB | **1.03×** |
| WAL + reader pool: 200 writes with 4 concurrent readers | 1,501 reads, **0 errors** | 1,439 reads, **0 errors** | — |

The concurrency probe is the P2 sanity check: readers ran continuously against
`renderPost` while a writer autosaved 200 times, on both stores, with **zero
errors** and no reader starvation. WAL pages encrypt under the same key and the
reader pool is unaffected, as research record #6 said.

**Against Zetetic's own published expectation of 5–15% overhead:** every road
the app actually uses came in at or below that band; the corpus build (the most
write-heavy thing measured) landed at 11%; only the deliberate full-corpus scan
exceeded it.

**`sqlcipher_export()` — the Batch 1 migration road, measured while here**

Migrating the **entire 10,095-block, 15.9 MB store** from plaintext to
encrypted took **122–129 ms**, and the result verified: 10,095 blocks (exact
match), ciphertext header, unkeyed open refused. The one-time migration is a
sub-second, invisible event at real corpus scale. Research record #7 confirmed.

### KNOT 3 — `secure_delete`: the measurement the author's ruling waits on

Her ruling: **ON unless the spike shows a real P1-budget breach**, and only a
breach comes back to her.

*Probe A — the primitive.* A dedicated 20,000-row prose table (the cleanest
isolation of "physically free N pages of prose", which is the work the 13j
purge pays), copied per variant from an identical checkpointed fixture:

| store | `secure_delete` | DELETE 20,000 prose rows |
|---|---|---|
| plaintext | ON (effective 1) | 3.7 ms |
| plaintext | OFF (effective 0) | 0.6 ms |
| **encrypted** | **ON (effective 1)** | **9.2 – 13.9 ms** |
| encrypted | OFF (effective 0) | 2.7 – 4.9 ms |

*Probe B — real corpus leaf rows* (`edge`, `post_tag`, `block_tag`,
`commit_point` — the tables nothing points at, so the delete is FK-legal
without reimplementing the purge's ordering): 140 rows, 1.0–1.8 ms in every
cell. **Reported as noise, not signal** — at 140 rows the fixed costs dominate
and one run even put encrypted-ON *below* encrypted-OFF. Probe A is the signal.

**READ AGAINST HER RULING: NO BREACH. `secure_delete` STAYS ON, and knot 3
does not go back to her.** The reasoning, stated so the architect can check it:

1. The **absolute** cost is ~10 ms to securely erase 20,000 rows of prose.
   A realistic purge — 13j's janitor expiring a handful of families — is
   orders of magnitude smaller than the probe.
2. It is **not on a P1 road at all.** P1 governs cost ∝ viewport + edit. The
   physical purge is a background janitor act after a 30-day horizon; nothing
   about it is on the keystroke or viewport path, and the delete probes above
   are entirely separate from the autosave figures.
3. The **13j synergy is exactly what she was told she'd be buying**: with
   `secure_delete` ON, "really deleted" means the freed pages are overwritten
   rather than left as readable remnants inside the (encrypted) file. Turning
   it off to save ~7 ms on a background sweep would trade her ruled story for
   nothing.

### The phone leg — NOT measured here, by design

Per the addendum, the phone is **Batch 4's** acceptance on her device, not a
spike act. Recording the architectural expectation as instructed: A-series SoCs
carry the same hardware-AES acceleration this Mac used
(`cipher_provider = commoncrypto` on both platforms), the shipped code path is
identical (core `Persistence/`), and the phone's own corpus is smaller than
this 10k-block fixture. **Expectation: the same ~1.0× keystroke road and
~1 ms keyed open.** It is an expectation, not a measurement — Batch 4 measures
it for real, and the mobile suite already runs green against the fork (Q4).

---

## Q3 — THE KEYCHAIN PROBE

### VERDICT: **`errSecParam` (-50).** The two-item design (R13p-6) is platform fact, not lore.

**What was done.** `SecItemAdd` against the data-protection keychain from the
scratch probe, with **three control probes** before the real one — which is
what makes the answer conclusive rather than ambiguous:

| # | shape | result |
|---|---|---|
| A | plain item, no ACL, not synced (**baseline**) | `-34018` `errSecMissingEntitlement` |
| B | synchronizable, **no** ACL (the escrow item, R13p-6) | `-34018` `errSecMissingEntitlement` |
| C | `.biometryCurrentSet` ACL, not synced (the gate item, R13p-5) | `-34018` `errSecMissingEntitlement` |
| **D** | **synchronizable + biometric ACL** ← **the question** | **`-50` `errSecParam`** |

**Why the controls settle it.** An unsigned command-line probe has no keychain
entitlement, so A, B and C all fail at the entitlement check — as expected, and
that is precisely the point. **Probe D returns a different status.** Parameter
validation runs *before* the entitlement check, so D's `errSecParam` is a
genuine rejection of the *combination* `kSecAttrSynchronizable` +
`kSecAttrAccessControl`, and cannot be an artifact of the unsigned
environment — an environment artifact would have produced `-34018` like its
three siblings.

`SecAccessControlCreateWithFlags(nil, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, .biometryCurrentSet, …)` itself
succeeded, so the ACL object was valid; only pairing it with synchronizability
was refused.

**Also recorded:** `LAContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics)`
= **true** on this Mac, so Batch 2's biometric mode is exercisable here.

**Recommendation:** proceed with the two-item design exactly as R13p-6
specifies — one `.biometryCurrentSet` device-only gate item, one separate
synchronizable escrow item with no access control.

**One PENDING caveat, named honestly:** this was run from an **unsigned CLI**.
The discrimination above is sound, but a **codesigned** re-confirmation inside
the app target costs about ten minutes and belongs in Batch 2 anyway, where the
real items get written for the first time. **It is not a Batch 1 gate.**

---

## Q4 — FORK MECHANICS END TO END

### VERDICT: **CLEAN.** Both apps build; all three suites at exact baseline.

### The fork

- Cloned `groue/GRDB.swift` into `~/dev/scratch-13p-spike/GRDB.swift`, checked
  out **v7.11.1**, branch **`variorum-sqlcipher`**, commit **`404dde041`**.
- Applied the README-documented recipe. **Diff vs `v7.11.1`: one file,
  `Package.swift`, +10 / −15.** The branch is push-ready for the GitHub fork
  the moment it exists.

**CORRECTION #1 — the recipe is not "a four-line uncomment."** R13p-11 and
research record #1 both describe it that way; the actual recipe in
`Package.swift` has **six sites across three kinds of edit**:

| # | site | action |
|---|---|---|
| 1 | the `dependencies`/`cSettings`/`swiftSettings` block | **uncomment 4 lines** (the SQLCipher package + `SQLITE_HAS_CODEC` × 2 + `SQLCipher`) |
| 2 | `products` | **DELETE** the `GRDBSQLite` library |
| 3 | `targets` | **DELETE** the `GRDBSQLite` systemLibrary target |
| 4 | `targets` | **uncomment** the `GRDBSQLCipher` target |
| 5 | the `GRDB` target's `dependencies` | **DELETE** the `GRDBSQLite` dependency |
| 6 | same | **uncomment** the `SQLCipher` product + `GRDBSQLCipher` target deps |

Recorded so Batch 1 does not under-scope it or, worse, uncomment the four
lines and wonder why two SQLite implementations link. The GRDB README's own
wording ("modify `Package.swift`. Instructions are in the file itself") is
accurate; the plan's paraphrase is the thing that shortened.

**SQLCipher version — the floor is met with zero extra delta.** The recipe
pins `from: "4.11.0"`; SPM resolved **4.18.0**. R13p-11 requires ≥ 4.18.0, so
the requirement is satisfied *by the documented recipe as written* — the fork
needs no version bump, and its delta stays a pure uncomment. **Recommendation:
leave `from: "4.11.0"` alone**; bumping it would add a delta that buys nothing
and would have to be re-justified every time the fork is rebased.

### Building and testing the repo against it

On a scratch branch in the repo (see below), `Package.swift`'s GRDB dependency
was swapped to the local clone's path.

| target | result |
|---|---|
| `swift build` (VariorumCore) | **Build complete** — **zero source changes** |
| `swift test` (core) | **1416 tests / 146 suites PASSED** — baseline 1416/146 ✔ |
| Mac app build (`-scheme Variorum -destination 'platform=macOS' -configuration Debug`) | **BUILD SUCCEEDED** |
| Mobile app build (`-scheme VariorumMobile`, iPhone 17 Pro simulator, Debug) | **BUILD SUCCEEDED**, 0 errors |
| **Mac app suite** (`xcodebuild test`) | **1768 tests / 296 suites PASSED**, `** TEST SUCCEEDED **` — baseline 1768/296 ✔ |
| **Mobile suite** (`xcodebuild test`) | **486 tests / 78 suites, 2 known issues**, `** TEST SUCCEEDED **` — baseline 486/78 (2 known issues) ✔ |

**All three suites at exact baseline.** The brief asked only for a build-proof
on mobile; the full suite was run because it was cheap and it is better
evidence.

**The known intermittent Mac latency pin**
(`EditorWindowSmokeTests.rewriteStrategyLatencies`, per its KnownIssues row)
**passed on this run** — the suite was fully green, so no isolated re-run was
required and no red needed adjudicating.

**The central Q4 claim is confirmed: the test factory is untouched.**
In-memory stores (`AppDatabase.inMemory()` → `DatabaseQueue(configuration:)`)
take no key and behave identically, which is exactly why 1416/146 held without
editing a single test.

**CORRECTION #2 — `SQLITE_HAS_CODEC` is NOT needed on the consuming target.**
R13p-11 says the flag goes "in the consuming targets." Tested directly:
`VariorumCore` was built **with** the define and then **without** it — both the
library and the full test target compile and the suites pass either way.

The mechanism: `SQLITE_HAS_CODEC` gates GRDB's *own* compilation (the
`#if SQLITE_HAS_CODEC` at the top of `GRDB/Core/Database+SQLCipher.swift`, plus
several newer-SQLite API surfaces). Once GRDB is compiled with it — which the
fork's `Package.swift` does — the resulting API is public and consumers call it
with no define of their own. A consumer needs the flag only if the consumer's
*own source* contains `#if SQLITE_HAS_CODEC`, and ours does not: we key with a
SQL pragma.

**Consequence, and it is a nice one: Batch 1's `Package.swift` change is a
ONE-LINE dependency swap.** No `swiftSettings` edit, no app-target build
setting. Recommendation: **do not add the define** — an unused define invites a
future reader to think something depends on it.

### The scratch branch

**`spike/13p-batch0`**, commit **`ea41482`**, left in place as instructed.
It carries the three things that produced the numbers and must never merge:
1. `Package.swift` pointing at the local clone;
2. a prototype keying seam on `AppDatabase` (`onDiskKeyed`, `rawOpen`,
   `rawOpenPassphrase`, a `keyHex`/`secureDelete` `configuration`, and
   `backupSpike`) — `onDisk(url:)` and `inMemory()` left **byte-unchanged**,
   which is why the suites stayed green;
3. `Tests/VariorumCoreTests/Spike13pMeasurements.swift`, the Q2/Q5 harness.

**`main` was returned to pristine and verified**: `git status` clean,
`Package.swift` back to the GitHub URL, `Package.resolved` back to GRDB
7.11.1.

### THE ONE NAMED RESIDUAL

**SPM resolving the fork from its real GitHub URL is unproven**, because the
GitHub fork does not exist yet (kickoff part 3: `gh` is not installed and the
fork awaits the author's one click). Everything *mechanical* is proven — the
uncomment, the flags, the xcframework download, the transitive resolution
through `XCLocalSwiftPackageReference` in the Xcode project, both app builds,
all three suites. What remains is only that a `url:`-form dependency resolves
the same as a `path:`-form one.

**Re-verified in minutes at Batch 1** by pushing `variorum-sqlcipher` over SSH
and swapping one line. Low risk, but genuinely **PENDING** and stated as such.

---

## Q5 — THE BACKUP-TRAP RED PIN

### VERDICT: the trap is **REAL — and it is NOT the shape the plan predicted.** This changes Batch 1.

Research record #10 predicted, from reading: an unkeyed destination under
SQLCipher "produces a PLAINTEXT backup **silently**." That prediction is
**wrong**, in a way that is *safer* than feared but *more disruptive* than
planned — which is precisely why the spike exists and why the hallucination
guard says to trace the mechanism rather than trust the read.

**Method.** A keyed scratch store seeded with a distinctive canary sentence
(`"MARMALADE-CANARY-13P the variorum preserves its variant readings"`),
WAL-checkpointed with `PRAGMA wal_checkpoint(TRUNCATE)` so the prose is in the
main file rather than only the WAL, then each candidate backup road exercised
and the resulting file **byte-scanned** for the canary (`Data.range(of:)`) and
header-checked for `SQLite format 3`.
Harness: `Tests/VariorumCoreTests/Spike13pMeasurements.swift`,
`q5_backupTrapIsReal()` on branch `spike/13p-batch0`.
Saved output: `~/dev/scratch-13p-spike/q2-q5-measurements.log`.

| road | outcome | header | canary found |
|---|---|---|---|
| the encrypted store itself | — | ciphertext | **no** |
| **CONTROL:** `backup(to:)` on a **plaintext** store | SUCCEEDS | PLAINTEXT SQLite | **YES** |
| **`backup(to:)` AS SHIPPED, on an encrypted store** | **REFUSED** | — | — |
| `backup(to:)` with a **KEYED** destination | **SUCCEEDS** | ciphertext | **no** — and **reopens with the key and reads the canary ✔** |
| `sqlcipher_export()` | SUCCEEDS | ciphertext | **no** — and **reopens and reads the canary ✔** |

The refusal, verbatim:

```
SQLite error 1: backup is not supported with encrypted databases
```

### What this means, precisely

1. **There is no silent plaintext leak.** SQLCipher refuses `sqlite3_backup`
   when the source and destination key states **mismatch**. The failure is
   loud. On the honesty doctrine this is good news: the dangerous outcome the
   plan feared — an encrypted store quietly shedding readable backups — cannot
   happen by this mechanism.
2. **But the refusal is not blanket, and that detail is the fix.** A **keyed
   destination succeeds**, produces ciphertext, and — verified, because
   ciphertext that cannot be reopened is worthless — **reopens with the key and
   reads the seeded prose back**. That round-trip proves the copy went through
   the pager (decrypt-on-read / encrypt-on-write) rather than copying raw pages
   under a destination salt that could never decrypt. So **THE DESIGN's
   prescribed fix — "the destination opened with the SAME key" — is correct as
   written.** `sqlcipher_export()` also works and is the documented fallback.
3. **The consequence Batch 1 must not miss: `backup(to:)` STOPS WORKING the
   moment the store is keyed.** 13l shipped real backup machinery on this
   method — scheduled backups, the second destination with ~6 weeks of
   retention, the freshness face, the rehearsed restore drill. **All of it
   throws at the first run after migration unless the destination is keyed in
   the same change.** This is a sequencing requirement, not a polish item:
   keying the store and keying `backup(to:)` belong in **one commit**.

### The correction to Batch 1's pin

Batch 1's plan says spike Q5 supplies "the red half" of a
zero-plaintext-backup pin. **The red assertion cannot be "the backup leaks
plaintext" — that assertion never goes red, because the call throws first.**
The honest red-on-old pin is a pair:

- **RED on pre-fix code:** backing up a *keyed* store through the shipped
  unkeyed-destination path **throws** `SQLite error 1: backup is not supported
  with encrypted databases`. (Cite: `AppDatabase.backup(to:)`
  `Sources/VariorumCore/Persistence/AppDatabase.swift:70` — `DatabaseQueue(path: url.path)`,
  no configuration.)
- **GREEN after:** the same call **succeeds**, the destination's first 16 bytes
  are not `SQLite format 3`, a byte-scan for seeded prose finds nothing, and
  the file **reopens with the key and reads that prose back**.

The plaintext control belongs in the pin too — today's backup of today's
plaintext store *does* contain readable prose (measured above), which is what
keeps the green half from passing vacuously on an empty or broken file.

### One more mechanism found while here (it affects the migration)

**ATTACH/DETACH cannot run inside a transaction.** The `sqlcipher_export()`
road had to move to `writeWithoutTransaction` — `DETACH` inside GRDB's normal
`write {}` fails with `database … is locked`. This is a real constraint on
Batch 1's one-time migration, not a harness quirk: **the migration's atomicity
must come from the verified file swap, never from wrapping the export in a
transaction.** THE DESIGN's export → verify → atomic swap sequence is already
shaped this way; this simply pins why no one should "improve" it into a
transaction.

---

## SURPRISES (collected)

1. **Q5's shape.** Predicted silent plaintext leak; actual **loud refusal on
   key mismatch**, with a keyed destination succeeding. Safer than feared,
   more disruptive than planned — 13l's backup machinery breaks at Batch 1
   unless keyed in the same commit.
2. **The fork recipe is six sites, not four lines** — four uncomments *and*
   three deletions. Under-scoping it links two SQLite implementations.
3. **`SQLITE_HAS_CODEC` is not needed on the consuming target** (tested both
   ways). Batch 1's `Package.swift` change is one line.
4. **GRDB's `usePassphrase` is the KDF road** — 165 ms vs ~1 ms, and GRDB
   offers no raw-key convenience at all. The pragma is mandatory, and the
   temptingly-named method is the trap.
5. **ATTACH/DETACH cannot be inside a transaction** — a real constraint on the
   migration's shape.
6. **A pleasant one:** SQLCipher's prebuilt binary ships far more than FTS5 —
   FTS3/4, RTREE, SESSION, SNAPSHOT, STAT4, PREUPDATE_HOOK, DBSTAT. Nothing the
   repo relies on is missing, and `ENABLE_SNAPSHOT` in particular matters
   because GRDB's `Package.swift` defines `SQLITE_ENABLE_SNAPSHOT` and would
   have been a linker problem had the binary lacked it.

## PENDING (nothing overclaimed)

| item | what remains | when |
|---|---|---|
| **The GitHub fork URL** | SPM resolving `url:`-form vs the proven `path:`-form. All other mechanics proven. | **Batch 1**, minutes, after the author's one click |
| **Q3 codesigned re-confirmation** | The probe ran from an unsigned CLI. The control probes make the `errSecParam` reading sound, but the real items get written in a signed app. | **Batch 2**, ~10 min. **Not a Batch 1 gate** |
| **The phone perf leg** | Expectation recorded from architecture (hardware AES, identical code path, smaller corpus); not measured. | **Batch 4** on her device, per the addendum |

## Recommendations to the architect (and, where marked, to the author)

1. **GO for Batch 1.** No contingency, no re-litigation, nothing new for the
   author to rule.
2. **Knot 3: `secure_delete` stays ON.** No P1-budget breach — ~10 ms to
   securely erase 20,000 rows, on a background janitor road, not a keystroke
   road. **This does not go back to her**, per her own ruling's terms.
3. **Q1 needs no author decision.** FTS5 is present; the contingency ladder
   (ask Zetetic / build from source / hand 13o the non-FTS road) is moot.
4. **Batch 1 must key `backup(to:)` in the same commit that keys the store** —
   this is the memo's one hard sequencing instruction, and Q5's correction is
   the reason.
5. **Keep the fork's delta a pure uncomment** (`from: "4.11.0"` resolves
   4.18.0 anyway) and **omit `SQLITE_HAS_CODEC` from `VariorumCore`.**
6. **Key with the SQL pragma; never with `usePassphrase`.** Worth a comment at
   the call site citing the 165 ms.
7. **Correct R13p-11 / research records #1, #8 and #10 at the closeout** so the
   plan file stops carrying the three superseded readings (four-line recipe,
   consuming-target define, silent-plaintext-backup). Q1's answer also retires
   research record #8's open question.

---

## READY FOR BATCH 1? — **YES, GO.**

Every question the spike was asked has a measured answer. The dependency
integrates with a one-file fork delta and a one-line repo change; the substrate
costs ~1 ms to open, is indistinguishable from plaintext on the keystroke road,
holds P1's own flatness assertion under encryption, and migrates a full corpus
in ~130 ms. FTS5 is present, so 13o is unblocked. The Keychain design is
platform fact. The one real surprise — the backup road — was found before a
line of it was built, which is what the spike was for, and it converts into a
concrete instruction rather than an open question.

*The evidence: `~/dev/scratch-13p-spike/q1-q3-probe-output.txt` and
`q2-q5-measurements.log`; the working tree on branch `spike/13p-batch0`
(`ea41482`); the fork on `variorum-sqlcipher` (`404dde041`).*
