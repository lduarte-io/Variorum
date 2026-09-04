# pre-13x — Batch 0: the measurements (the decision memo)

**Status: COMPLETE on the Mac; Q3 PENDING-HER-SITTING (the phone leg is PREPARED, not run).**
Run 2026-09-04 by the batch 0 Fable implementer, per the BATCH 0 BRIEF in
`notes/plans/pre-13x-postures-design.md` §18 (the execution record). This is the Phase 6 / 13p pattern:
evidence before commitment. **What landed on `main` beyond this memo:** the shared
access group on both targets' entitlements (its own commit) and three DEBUG-only
probe doors over one throwaway-service brain (never a production Keychain item, never
a store, never a `Sync/` line, never a Release build).

---

## THE HEADLINE, IN SIX LINES

| Q | Question | Verdict |
|---|---|---|
*[removed for publication]*
| **Q2** | Does a synchronizable item written under the shared group read back on the Mac? | **YES.** add `0` → read `0` (landed in `…Variorum.shared`, `synchronizable=true`) → delete `0` → gone `-25300`. |
| **Q3** | Does it cross to the phone? | **PENDING-HER-SITTING.** Both apps carry a DEBUG door over one brain; the five-minute procedure is below. |
| **Q4** | The pre-unlock network floor to the project host | **Median 0.051 s, max 0.314 s** over five cold GETs (fresh TLS each); a warm keep-alive request 0.015 s. A fraction of one Argon2id derivation. |
| **Q5** | `kSecAttrSynchronizable` + `kSecAttrAccessGroup` facts on macOS 26.5.2 | A delete WITH the flag under the shared group **matches (`0`)**; a query naming the OTHER group **does not (`-25300`)**; a query with NO group from the SAME app **does match (`0`)** — the group fences other apps, not the writer; a query WITHOUT the flag **never matches (`-25300`)**, deletes included. |
| **Q6** | Argon2id v1 derivation on this Mac | **0.766 s median** (0.769 / 0.766 / 0.763 s; M3 Pro). |

**Two facts change how batch 2 should be written** (collected under RECOMMENDATIONS
FORWARD at the end): a group-less read from the same app matches the shared item, so
naming the group is a WRITE-identity rule, not a read fence; and the shared group is
config-independent by design, so the A4 dev-store fence needs the Apple key's ACCOUNT
to carry the scope discriminator, or a Debug build and the Release install will share
one A.

---

## ENVIRONMENT (the measurement authority)

- **Machine:** the author's **M3 Pro**, 18 GB — dev = acceptance (AppSpec §1). Load
  average 2.4–3.4 during the runs; her live real-store app running throughout
  (PID 79767, never touched); no Release build, no `/Applications` refresh.
- **OS / toolchain:** macOS **26.5.2** (25F84), Xcode **26.3** (17C519). iOS target built
  for `generic/platform=iOS` (deployment 26.0); her phone (iOS 26.6) listed by
  `xctrace` but deliberately NOT installed to — the brief's prepare-only rule.
*[removed for publication]*
  "Mac Team Provisioning Profile: *" and "iOS Team Provisioning Profile: *" — both
  *[removed for publication]*
  themselves, `security cms -D`).
- **Network (Q4):** her home network, 00:14 local; the project host resolves to a
  Cloudflare edge (`172.64.149.246`); the gateway answers `401
  UNAUTHORIZED_MISSING_API_KEY` before PostgREST is reached.
- **Build cache:** a gitignored `App/Variorum/DerivedData/pre13x-b0` inside the worktree
  (cold), so nothing of her Xcode's caches was touched. Every raw log named below is
  under `App/Variorum/DerivedData/pre13x-b0-logs/` (gitignored; the numbers are
  quoted here verbatim).

---

## Q1 — THE SHARED ACCESS GROUP ON BOTH TARGETS

### VERDICT: **builds and signs on both, with no App-ID or capability step.** Nothing for her.

**What was done.** `App/Variorum/Variorum.entitlements` gained a SECOND
`keychain-access-groups` entry, `$(AppIdentifierPrefix)io.lduarte.Variorum.shared`, after
the existing `$(AppIdentifierPrefix)$(PRODUCT_BUNDLE_IDENTIFIER)`. The iOS target had
**no entitlements file at all** (its keychain identity was the implicit default group);
`App/Variorum/VariorumMobile.entitlements` was CREATED with the identical two-entry shape
and wired by `CODE_SIGN_ENTITLEMENTS = VariorumMobile.entitlements` on both VariorumMobile
configurations. Commit `a37f9cd`.

**The observed facts** (`codesign -d --entitlements :-` on the built products):

| target | `application-identifier` | `keychain-access-groups` (in order) | profile |
|---|---|---|---|
*[removed for publication]*
*[removed for publication]*

The first entry resolves to each target's OWN bundle id, as the brief required — so
nothing already written strands. The runtime half of that promise was then measured
on the Mac (Q2's first line): an item written with NO group named lands in
*[removed for publication]*
*[removed for publication]*
second to the same shared string — the shared group is deliberately
config-independent.

**Why signing did not refuse.** A TEAM provisioning profile's `keychain-access-groups`
is the wildcard `TEAMID.*`, which admits any group with the team prefix; the "Keychain
Sharing" capability on an App ID is what puts EXPLICIT groups into a
DISTRIBUTION profile. So the brief's stop condition never triggered here — **and it
WILL matter at 13r**: a Developer ID / App Store profile lists explicit groups, and the
App IDs (`io.lduarte.Variorum`, `io.lduarte.VariorumMobile`) will need Keychain Sharing
enabled with `io.lduarte.Variorum.shared` added, or the notarized build cannot read
what the dev build wrote. The design's §3.7 last sentence already says the Developer ID
build must carry both groups; this is the mechanism behind it. (The KnownIssues row
widens at closeout, per the design.)

**Pins.** `EntitlementsTests.theSharedKeychainAccessGroupRidesSecondBehindTheTargetsOwn`
(always-on, in the signed test host): two groups, the first ending in the host's bundle
id, the second in `.io.lduarte.Variorum.shared`. Red on the pre-change entitlements (one
group). It rides the probes commit beside the other tests.

**Build hygiene noted, not acted on:** the Mac build log carries 17 pre-existing
warnings and the iOS log 7 — none new, none in the touched files.

---

## Q2 — A SYNCHRONIZABLE ITEM UNDER THE SHARED GROUP, ON THE MAC

### VERDICT: **round-trips.** add `0` · read `0` (in the shared group, synchronizable) · delete `0` · gone.

**What was done.** `App/Variorum/Shared/SharedKeychainGroupProbe.swift` (DEBUG-only,
both targets) — one brain: the escrow query's shape (`kSecClassGenericPassword`,
`kSecAttrSynchronizable = true`, `kSecUseDataProtectionKeychain = true`,
*[removed for publication]*
named explicitly, under a THROWAWAY service (`io.lduarte.Variorum.pre13x-shared-group-probe`)
and a timestamped account, deleted at the end. Driven by
`VariorumTests/SharedKeychainGroupProbeTests`, **DISABLED BY DEFAULT** — the suite is
`.enabled(if:)` the environment carries `VARIORUM_SHARED_GROUP_PROBE=1`, which
`xcodebuild` hands to the host as `TEST_RUNNER_VARIORUM_SHARED_GROUP_PROBE=1`. Verified
both ways: with the variable the suite ran (2 tests); without it the suite is
skipped (see the verification line under Q5). `KeychainTestTripwire` stays armed and
untouched — the probe never reaches a fixed-account custody leaf.

**The observed run** (2026-09-04T06:22:11Z, the signed test host, verbatim from the
`PRE13X-PROBE|` lines):

```
*[removed for publication]*
*[removed for publication]*
 ok  Q2 add (shared group · synchronizable · AfterFirstUnlock · no ACL): 0 (No error.)
 ok  Q2 read (shared group named · synchronizable=true): 0 (No error.) payload="Lillian’s MacBook Pro @ 2026-09-04T06:22:11Z"
         *[removed for publication]*
 ok  Q5 delete (shared group · synchronizable=true) — MUST match: 0 (No error.)
 ok  Q5 read after the flagged delete — gone: -25300 (The specified item could not be found in the keychain.)
```

**What this proves and what it does not.** The Mac can WRITE an iCloud-synchronizable
item under the shared group and READ IT BACK through the same query family — the Mac
half of §3.7's premise. It does not prove propagation to iCloud or to the phone; that
is Q3.

**Pollution, stated.** One throwaway item rode into her iCloud Keychain for the ~30 ms
between add and delete; its tombstone follows. That is the brief's deliberate override
of the 13p fact suite's "never write a synchronizable item" rule — which is why the
override is opt-in per run and never part of the ordinary suite.

---

## Q3 — THE ITEM CROSSES TO THE PHONE

### VERDICT: **PENDING-HER-SITTING.** Prepared on both ends; not run (no install on her phone from a session).

**What is in place.** Both apps carry a DEBUG-only door over the same brain and a
FIXED probe account (`cross-device`, under the throwaway service — a fixed name is what
lets the reading device find what the other wrote; it is not a custody item, so the
tripwire's law is not engaged):

- **Mac:** Help ▸ **Keychain Shared-Group Probe (pre-13x)…** — an alert showing the item's
  current state, with **Read again · Write from this Mac · Delete the item · Local round
  trip · Close** (`App/Variorum/Variorum/Core/SharedKeychainGroupProbeDoor.swift`).
- **Phone:** the Settings sheet ▸ the dev-store section at the bottom (below "TK2
  Spike") ▸ **Keychain probe (pre-13x)** — a sheet that reads on appear, with **Read the
  other device's item · Write from this iPhone · Delete the item · Local round trip**
  (`App/Variorum/VariorumMobile/Features/Shell/MobileKeychainProbeScreen.swift`). Every
  line is selectable on screen and printed as `PRE13X-PROBE|` on the console.

Both doors are compiled out of Release, outside the capability registry by the same
rule as the phone's TK2 Spike door, and are deleted when batch 2's real Apple-key item
lands.

### THE FIVE-MINUTE PROCEDURE (for the author)

**Before you start:** both devices signed into the SAME iCloud account, online, with
iCloud Keychain ON (Mac: System Settings ▸ [you] ▸ iCloud ▸ Passwords & Keychain;
phone: Settings ▸ [you] ▸ iCloud ▸ Passwords & Keychain / "Saved to iCloud" on iOS 26).
Use the DEBUG builds on both — they run the dev store; your real library is never
opened by either.

1. **Phone — install the dev build (once).** In Xcode open
   `App/Variorum/Variorum.xcodeproj`, scheme **VariorumMobile**, destination **your
   iPhone**, ⌘R. If the phone asks, trust the developer profile (Settings ▸ General ▸ VPN
   & Device Management). ~2 minutes.
2. **Mac — write.** Xcode, scheme **Variorum**, ⌘R (Debug = the dev store). Menu Help ▸
   **Keychain Shared-Group Probe (pre-13x)…** ▸ **Write from this Mac**. Expected:
   `Write from this Mac: 0 (No error.)`. The alert reopens showing the item; note the
   time.
3. **Phone — read.** Open the app's Settings sheet ▸ scroll to the bottom ▸ **Keychain
   probe (pre-13x)**. Expected within seconds to a few minutes:
   `read cross-device: 0 (No error.) payload="Lillian’s MacBook Pro @ …"
   *[removed for publication]*
   `-25300`, tap **Read the other device's item** every ~20 s for up to five minutes.
   **Record the time from step 2 to first visibility.** Also note the phone's own first
   *[removed for publication]*
   "nothing strands" fact on the phone).
4. **Phone — the reverse.** Tap **Write from this iPhone** (expected `0`). On the Mac tap
   **Read again** until the payload reads `Lillian’s iPhone @ …`. **Record the time.**
5. **Phone — the local round trip, once.** Tap **Local round trip**: expected the line
   `local round trip: every must-hold step held` (this is Q2 + Q5 on iOS). Then
   **Delete the item** on either device (expected `0`); the other reads `-25300` after
   propagation.

**What to hand the record (five values):** Mac→phone status + time; phone→Mac status +
time; the phone's local-round-trip verdict; the phone's own-group line; anything that
surprised you. They go into §17c's batch 0 record and this memo's Q3, and ledger row 2
flips.

**If it goes wrong:** `-34018` (missing entitlement) on the phone means the installed
build was not signed with the shared group — check Xcode's Signing & Capabilities for
VariorumMobile shows the two groups; `-25300` for more than ten minutes in BOTH
directions means the two devices are not sharing a keychain (different iCloud accounts,
or iCloud Keychain off on one side) — the design's own "waiting for iCloud Keychain"
state (§3.6) is what a user would meet there. Neither is a measurement failure; both
are the kind of fact this leg exists to surface.

---

## Q4 — THE VAULT READ'S LATENCY FLOOR BEFORE UNLOCK

### VERDICT: **median 0.051 s, max 0.314 s** (cold connection each time); **0.015 s warm.**

*[removed for publication]*
(`ProjectConfig.variorumProjectURL`'s host), each on a FRESH connection (`--no-keepalive`),
no credentials sent or held; then one keep-alive pair to show the warm second request.
The gateway answers `401` with `sb-error-code: UNAUTHORIZED_MISSING_API_KEY` — before
PostgREST — so these numbers are the network + TLS + gateway floor, not a query.

| run | DNS | TCP connect | TLS done | first byte | **total** |
|---|---|---|---|---|---|
| 1 | 0.050 s | 0.058 s | 0.071 s | 0.177 s | **0.177 s** |
| 2 | 0.006 s | 0.013 s | 0.026 s | 0.041 s | **0.041 s** |
| 3 | 0.006 s | 0.036 s | 0.070 s | 0.314 s | **0.314 s** |
| 4 | 0.005 s | 0.013 s | 0.027 s | 0.051 s | **0.051 s** |
| 5 | 0.006 s | 0.014 s | 0.026 s | 0.050 s | **0.050 s** |

Sorted totals 0.041 · 0.050 · **0.051** · 0.177 · 0.314 → **median 0.051 s, max 0.314 s.**
Warm (same connection, second request): **0.015 s.** The first run paid a DNS lookup
(50 ms); run 3's spread is server-side first-byte wait on an otherwise ordinary
connection — the variance lives after TLS, not in the handshake.

**What it means for the lobby.** The pre-unlock network contact (§3.4: ONE authenticated
vault read, boxes only) costs this floor plus one PostgREST query on top — budget
**~0.1–0.5 s on a home network, tail to ~1 s**; the authenticated call also carries a
larger response (the vault row) but no round-trip beyond the one measured. Beside Q6's
0.77 s derivation this is the smaller term. **Recommendation:** start the vault read
CONCURRENTLY with the local Argon2id derivation on submit (both begin at the keystroke
that confirms the passphrase), so the vault road costs `max(KDF, RTT + query)` rather
than their sum; a ~10 s ceiling then hands off to the offline-grace rule (§3.4 rule 2)
rather than spinning.

---

## Q5 — `kSecAttrSynchronizable` + `kSecAttrAccessGroup` ON macOS 26.5.2

### VERDICT: the family's rules, measured (every line from the same signed-host run as Q2):

| probe | status | reading |
|---|---|---|
| read, shared group named, `synchronizable = true` | **`0`**, landed in `…Variorum.shared`, `synchronizable=true` | the family's own query finds it |
| read, **NO group named**, `synchronizable = true` (same app) | **`0`** — the same payload | **the same app searches ALL its entitled groups**; naming the group is not a read fence for the writer |
| read, **the DEFAULT group named** (`…Variorum.debug`) | **`-25300`** itemNotFound | another group does NOT see it — the group is a fence between groups, i.e. between apps |
| read, shared group, `synchronizable` **OMITTED** | **`-25300`** | the platform default matches only NON-synchronizable items |
| read, shared group, `kSecAttrSynchronizableAny` | **`0`** | Any matches both kinds |
| **delete**, shared group, `synchronizable` **OMITTED** | **`-25300`** — and the item is STILL THERE afterwards (`0` on the next read) | a flagless delete is a silent no-op — the 13p-fix "family disagreeing with itself" class, one flag over |
| **delete**, shared group, `synchronizable = true` | **`0`**, then `-25300` on read (and on read-Any) | the brief's "it must": the flagged delete under the shared group matches |

**Disabled-by-default, verified:** the same suite run WITHOUT the environment variable
reports the suite skipped and zero of its tests executed (`mac-probe-disabled.log`;
the exact line is quoted in §17c's record).

**The rules batch 2 must write down (recommendation):** every query in the Apple-key
family — add, read, update, delete, probe — carries **both** `kSecAttrSynchronizable = true`
**and** `kSecAttrAccessGroup = <shared>` **and** the data-protection marker, as ONE
builder (the `escrowQuery` pattern). The flag decides whether the item is VISIBLE at
all; the group decides WHERE a write lands (a group-less write lands in the FIRST
entitled group — the per-configuration default — and is invisible to the phone) and
which other apps can see it; naming it on reads and deletes too keeps the family one
rule, exactly as `KeychainPartitionTests` already demands for the marker. Extend that
structural pin to the new family when it exists.

---

## Q6 — ARGON2ID v1 DERIVATION TIME ON THIS MAC

### VERDICT: **0.766 s median** — 0.769 / 0.766 / 0.763 s (m = 64 MiB, t = 3, p = 1), M3 Pro.

`swift test --filter PassphraseKDFTests/kdfLatencyHarnessMac`, the existing 14b harness,
unchanged; the printed line verbatim:
`KDF-LATENCY (Mac, v1 descriptor m=64MiB t=3 p=1): 0.769s 0.766s 0.763s — median 0.766s`.
Tight (±3 ms) at load average ~3 with her live app running, so this is the number, not
a lucky sample. The phone half is unmeasured here (14b's R-7 stated the ~0.5–1 s
class; the sitting that runs Q3 could read it from the phone's own harness if wanted).

**What it means for the lobby budget.** One passphrase attempt = **~0.8 s** on this Mac
before any network. §3.4's road tries the LOCAL box first and then the vault; the two
boxes may carry DIFFERENT KDF descriptors (different salts — the vault's descriptor is
recorded in the key file precisely so the two can be compared), so a passphrase that
misses the local box and is verified against the vault costs a SECOND derivation:
worst case **~1.6 s + the Q4 floor** on this Mac, and proportionally more on the phone.
**Recommendation:** (a) when the key file's recorded descriptor EQUALS the vault's,
derive ONCE and try both boxes with the same key; (b) start the vault read concurrently
(Q4's recommendation); (c) the lobby shows progress from the first ~200 ms — a 0.8 s
silent field reads as a hang. None of this changes the v1 descriptor: 64 MiB / t = 3
stays (the OWASP floor is exceeded and the phone is the constraint to keep in view).

---

## SURPRISES (what the measurements corrected or sharpened)

1. **Signing never refused.** The brief carried a stop condition for a Keychain-Sharing
   step in her developer account; the team profiles' wildcard made it moot on BOTH
   platforms. The step moves to where it is real: **13r's distribution profiles** (see
   Q1).
2. **"A query without the group must not match" is true from ANOTHER group, false from
   the SAME app** — the writer sees its item without naming the group. The design's
   §3.7 sentence ("every iCloud-synchronizable write names it explicitly") is exactly
   right and for the right reason: the group governs where a WRITE lands.
3. **The iOS target had no entitlements file at all** until this batch. Its signed
   entitlements now carry `keychain-access-groups` explicitly, with the implicit default
   restated as the first entry — the same identity it always had, now written down (and
   pinned by the codesign dump; the phone-side runtime line is step 3 of the procedure).
4. **The shared group is config-independent, and so is A's home** — a Debug Mac, the
   Release install and a Debug phone on one iCloud account all see one shared group.
   For the probe that is the point. For the real Apple key it collides with the A4
   dev-store fence (`Variorum` vs `Variorum-dev` scopes in `StoreKey.swift`): a Debug
   build must not read the Release install's A. **Recommendation for batch 2:** the A
   item's ACCOUNT carries the same scope discriminator the store-key family uses, so a
   dev build mints and reads its own A; the shared GROUP stays one string.

## WHAT THIS MEMO HANDS FORWARD

- **Batch 1 (substrate):** nothing here blocks it; Q4/Q6 are its latency budget inputs.
- **Batch 2 (postures):** the query-family rule (Q5), the scope-discriminated A account
  (surprise 4), the concurrent vault read + single derivation (Q4/Q6), and Q3's answer
  from her sitting — the propagation time is the number the "waiting for iCloud
  Keychain" state's copy wants.
- **13r:** Keychain Sharing on both App IDs with `io.lduarte.Variorum.shared`, and a
  codesign dump of the Developer ID build showing both groups (Q1).
- **Ledger:** row 1 (the group on both targets) DONE; row 2 (crossing) PENDING-HER-SITTING
  with the procedure above; row 3 (this memo) DONE.

## WHAT WAS DELIBERATELY NOT DONE

No key-proof RPC, no custody change to any real item, no store touch, no `Sync/`
change, no Release build, no install on her phone, no `-allowProvisioningUpdates`
(an App-ID change is hers). The probe brain and its three doors are DEBUG-only and
carry their own deletion note (batch 2).
