# VX-191 — Pre-launch encryption & Castle adversarial audit (the record)

**Status: IN FLIGHT — 2026-10-12 night, the eve of the 0.9.x public release.** Opus orchestrator + three Opus
read-only auditors (A: the S1 ten questions re-run + the open custody backlog · B: every flow into and out of the
encrypted library · C: primitives, wire, server, Keychain attributes). Branch `vx-191-encryption-audit`, worktree
`~/dev/variorum-vx-191`, base `f337f19e`. **Read-only on product code** — this file and `vx-191-audit/*.md` are
the only writes. The auditors' full reports: `notes/plans/fixes/vx-191-audit/{A-ten-questions,B-flows,C-crypto-wire-server}.md`.

Her ask (2026-10-12, verbatim core): *"I want to know if someone who starts in standard mode and then goes into
castle mode, if that issue where their previous key wasn't being cleared is fully fixed now … go over EVERYTHING
with a fine toothed comb … adversarially check for weaknesses and problems with encryption and any of the flows
into and out of it. If there are glaring issues, they'll block launch."*

---

## O. THE ORCHESTRATOR'S OWN LEG — Standard → Castle, every key, traced at HEAD

### O.1 Which "previous key not cleared" issue — and is it closed?

The issue she remembers is the **VX-99 class** (`notes/plans/fixes/vx-99-pro-castle-apple-wrap.md`): her Pro's
LIVE key file carried an `apple` copy (the library key wrapped under the iCloud key A) while the account was Castle.
Mechanism then: `writeNewKeyFile` added the Apple copy whenever the road "did not enter Castle", so Replace All
Keys on a Castle account wrapped L′ under the A the Mac still held from its Standard era. Its siblings: the 13x
R1-BLOCKER (an adopted Standard-era pair beside a Castle library) and decision 35's window phone.

At HEAD every road decides the key file's Apple copy from the VAULT's word, carrying the verified key, never "any
iCloud key readable here":
- the ceremony: `PostureSwitch.swift:611-619` (enter Castle ⇒ nil; Replace All Keys ⇒ only when the fetched vault
  carries an Apple-held copy, `appleHeldCopyForStandard` `:1275-1288`); the local-only road ⇒ nil (`:699`);
- the follow: `:844` (`entersCastle = vault has no Apple-held copy`), `:860/:879` (nil under Castle);
- the resume: `:1523` (`vaultSaysCastle ? nil : …`);
- the belt: `ProtectionController.reconcileFollow`'s `castleKeyFileAppleOpenable` arm (`:668ff`) catches a live
  Standard-era key file under a Castle account and owes the follow, which retires it (`retireOldKeyFiles`, `:901`).

**Verdict: the VX-99 mechanism is closed at HEAD** (pins red-on-old per its record; the auditors re-check the pins).

### O.2 The credential walk — what a Standard → Castle switch leaves, at HEAD

| credential | what the code does | evidence | verdict |
|---|---|---|---|
| library key L, raw, silent item (`io.lduarte.Variorum.store-key`, `<scope>-<storeID>-bound`, DP keychain, `WhenUnlockedThisDeviceOnly`) | REPLACED by L′ (export-and-swap); L′ moves behind `.biometryCurrentSet` (or nowhere under Always ask) via `CustodyHandover`: gated write → verify → silent DELETE, a refused delete refuses the whole move | `PostureSwitch.swift:1097-1113`, `ProtectionController.swift:1346-1375`, `KeychainCustody.swift:253-269`; the delete carries the DP flag (`StoreKey.swift:404-424`) | HOLDS **except the race in O.3** |
| sync record (M, C, J + device id), silent | the gated item lands, the silent item is OVERWRITTEN identity-only (material gone) | `EncryptionKeychain.swift:219-229, 271-279`; the real-Keychain drill asserts it (`PostureSwitchDrillTests.swift:557-560`, Always-ask arm) | HOLDS |
| the vault's A-wrapped master | the rotation's ONE `key_vault_update` sends no Apple copy; the SQL assigns `master_wrapped_by_apple_held = payload->>'…'` (absent ⇒ NULL) | `13_phase13i_wings.sql:778-779` (latest definition; same in 11/12) | HOLDS |
| master M / corpus key C | rotated to M′/C′; every row re-encrypted; old proof refused | `PostureSwitch.swift:604-691`; drill `:566-572, 670-673` | HOLDS |
| the key file | a NEW file for L′ with P, W, M′ copies and NO `apple`; the OLD file (A-wrapped OLD L) stays beside the library on the acting device's own road (by design, §3.4 "2d.4 ruling 3") and is retired on every follower | `:1147-1189`, `:1126`, `:901-927` | HOLDS (old L opens nothing current — the file was re-keyed; see O.4 for the tidy-up note) |
| the old library file + its WAL | export-and-swap under L′, old `-wal/-shm` removed | `swapLibrary` `:1193` → `StoreEncryptionMigration.rekey`; drill asserts `!opens(storeURL, oldKey)` (`:545`) | HOLDS (auditor B re-checks WAL) |
| the iCloud key A itself | **STAYS in iCloud Keychain, by design** (decision 6, §3.4 "STAYS in iCloud; every CURRENT copy under it is removed"); never deleted in production (`AppleKeyCustody.swift:191-197`) | — | BY DESIGN — see O.5 for what this means for her Passwords check |
| pre-switch backups (app's own folders) | untouched; the ceremony OFFERS to delete them after a fresh post-switch pair is written | `:1226-1253`, `:1752-1774`; drill `:681-688` | BY DESIGN, disclosed (auditor B re-checks every folder) |
| the scheduled plaintext `.md` insurance | turned OFF on entering Castle, on the ceremony AND on a follow | `:1240-1247` (the follow shares `rekeyCustodyAndSnapshot`) | HOLDS |
| 13p legacy escrow item (raw L in iCloud Keychain, `io.lduarte.Variorum.store-key-escrow`) | no production road writes it any more; the migration removes it ONLY when it equals the key in hand, else leaves it ("another key's") | `StoreKeyGuard.swift:420-457`, `ProtectionMigration.swift:198-209` | NOT A NEW-USER ISSUE (13p era = her own devices only). Author note: an older escrow item for a key no longer in hand would survive — worth one look on her own Macs |

### O.3 FINDING (orchestrator) — the re-key's reopen re-saves L′ into the SILENT item on an UNORDERED background task

**Severity: MAJOR, BLOCKER-candidate** (low-probability race; the outcome is a silent, total breach of the Castle
promise for a local-only library; the fix is a few lines). **Status: TRACED from code; NOT reproduced** (no test or
drill exercises the production reopen — both inject their own `rekeyLibrary` leaf: `PostureSwitchTests.swift:763`,
`PostureSwitchDrillTests.swift:478`; neither goes through `AppBootstrap`).

The mechanism, step by step (Standard → Castle, ceremony or follow, Mac and phone — `AppBootstrap` is shared):

1. Step 4 writes the NEW key file for L′ (no `apple`, P present) — `PostureSwitch.swift:1105` — then
   `swapLibrary` → `AppBootstrap.rekeyLibrary` (`AppBootstrap.swift:811-842`) re-keys the file and reopens it with
   `beginOpening(unlockedKey: L′)`.
2. The reopen reaches `.ready`. There (`AppBootstrap.swift:520-530`) — the 13p R1-M3 recovery road — *"if let
   unlockedKey, !currentEffectiveGate.isDemanded"* spawns `Task.detached(priority: .utility) { saveAuto(unlockedKey) }`.
   At this instant custody has NOT moved yet (step 5 runs after the reopen), the silent item still holds the OLD L,
   so `StoreLaunchGate.effectiveGate` reads `.silent` → the posture reads Standard (local: `localReading` corner 45;
   enrolled: indeterminate with the silent shape) → `.auto` → **the detached task writes L′ into the silent item.**
3. `rekeyLibrary` returns after `awaitOpen()`; the runner writes the `.custody` marker and runs
   `moveCustodyForSwitch` → `ProtectionController.moveCustody(.biometric | .passphrase)` → gated write → verify →
   `deleteAuto()` (`ProtectionController.swift:1354-1360 / 1375`).
4. **Nothing orders the utility task's `saveAuto(L′)` before step 3's `deleteAuto()`.** If it lands after, the
   silent item holds the CURRENT library key, readable with no Touch ID and no passphrase — the "theater" R13p-14
   forbids, and the exact opposite of Castle's "your Mac's login password: no — nothing on this Mac releases the key
   to it." The in-session projection does not notice (`libraryKeyCustodyShape` reads the RESIDENT, `:1068-1071`,
   which is set), so the Done screen says Castle.
5. **The next launch** routes through `StoreLaunchGate.effectiveGate` (`StoreLaunchGate.swift:362-383`), whose
   custody probe is `loadAuto() != nil` (`:389-392`):
   - **LOCAL-ONLY library** (no sync — the likely beta-tester shape): not enrolled, custody `.silent`, the live key
     file (`locate` = newest = L′'s) has no `apple` and has P, `belongs(to: L′)` true, and **A is readable — it stays
     in iCloud Keychain by design** ⇒ the route's landing arm (`:367-376`) **WRAPS L′ UNDER A INTO THE LIVE KEY FILE.**
     The posture now derives Standard; the library opens silently; re-lock on sleep stops (the gate is no longer
     demanded). A complete, silent reversion to Standard — the current key both raw-silent AND iCloud-openable.
   - **ENROLLED library:** the landing is skipped (enrolled), but the route opens SILENTLY through the lingering
     item (the Castle lock bypassed), then the reconcile's posture-mismatch arm owes the follow into Castle
     (`ProtectionController.swift:661-667`, the passphrase asked again) — whose own re-key reopen re-runs step 2:
     the same race again.

**Why it is plausible, not certain:** the utility task usually starts within milliseconds and its `SecItemUpdate`
is quick, while the runner's path to `deleteAuto` includes a database write and four Keychain round trips — so the
save USUALLY loses the race to happen first and is then deleted. But it is not ordered, it runs at the LOWEST QoS
the code uses, on a machine that has just re-encrypted the corpus and is running ready housekeeping, sync and a
backup; QoS starvation is exactly when utility work slips.

**Fix shape (not implemented — the author's call, a VX ticket):** (a) never re-land the silent item on the re-key's
reopen — skip the R1-M3 save while a `RotationMarker` is set / `switchInProgress`, or pass a flag from
`rekeyLibrary`; (b) belt: at every ready under a DEMANDED effective gate, a lingering silent item is a custody-law
violation — delete it (the `CustodyHandover` delete) rather than read it as the posture; (c) belt: the route's
landing arm (`StoreLaunchGate.swift:367-376`) must never land an Apple copy for a key file that has EVER been
Castle-shaped — at minimum, not while a marker is pending. Pin: a bootstrap-level test that holds the utility save
until after the custody move (injected guard seam with a gated `saveAuto`), red on HEAD.

### O.4 Notes (not findings)

- **The acting device keeps its Standard-era key file** (`variorum-keys-<oldfp>.json`, A-wrapped OLD L) in the live
  folder after the ceremony (ruled: "the old key file stays beside old snapshots"). It opens nothing current — the
  live file is re-keyed — but it is a confusing artifact for anyone inspecting the folder, and it is the one thing
  that makes an "is anything A-wrapped here?" check by eye come out yes. Followers retire theirs. Consider retiring it
  on the ceremony road too, once the fresh post-switch pair exists.
- **The server's own backups** (Supabase PITR) hold the pre-switch vault row (old M under A) and old-C ciphertext of
  PRE-switch writing — disclosed in §3.4. Someone fully inside the Apple account AND holding a Supabase backup reads
  pre-switch writing only. By design; worth one sentence in the FAQ if not already there (auditor C checks the copy).

### O.5 Her Passwords-app check

What she looked for proves nothing either way: **the iCloud key A is SUPPOSED to stay in iCloud Keychain after
Castle** (decision 6 — only the copies wrapped under it go). So "no Variorum key in Passwords" is neither a pass
nor a fail. (Whether an app's synchronizable generic-password item shows in Passwords at all: auditor C.) The
honest checks are listed in §V (verification road) once the auditors report.
