# VX-266 design proposal — cold read 1

**Reviewer:** cold reviewer (Opus, max effort), zero context on how the proposal was produced. **Document:**
`notes/plans/vx-266/design-proposal.md` (branch `vx-266-castle-backups-before-launch`, worktree
`~/dev/variorum-vx-266`, at `fddbe50d`; the `.html` twin carries the same text). Read-only; this file is the only
write. Canon read: CLAUDE.md + its three auto-loaded files, `SyncSpec.md` whole, `pre-13x-postures-design.md` §1–§14,
the VX-191 record, the VX-201 record (searched: §A, U5, W-1, close), QUESTIONS #216, the 13x plan (row-4 memo,
searched), `PhaseSizingGuidance.md`. Code read at the decision points named below. One Sonnet lookup for Apple
platform facts (LAContext / Keychain), cited where used.

**STATUS: COMPLETE (2026-10-13).** 1 BLOCKER · 7 MAJOR · 19 MINOR · 7 NIT, then the clean bill.

**The read in one paragraph.** The diagnosis is accurate: every mechanism it rests on is in the code where it says
(clean bill 1), and its five causes are a fair reading of the tickets. The structural moves that answer those causes —
Keychain items per key, one decider with no writing reads, every copy brought under the library's current key, plans
outside the library file, one catalog and one route finder — are sound and fix VX-209/VX-228/W-1 at the root. The two
genuinely NEW mechanisms are where the trouble is: the history key wrapped under the account master re-opens Castle-era
keys to the Apple account once a library leaves Castle (B1), and the in-file record with its change counter lets a
copy decide the library's mode and key — non-causally between two Macs, and forgeably by Castle's own adversary (M1).
Both can be dropped or narrowed without losing a ticket (m16). The account model needs to reach row ownership (M2),
the migration needs a real road back and an answer for every old shape (M3), two Touch ID rules weaken protection or
destroy it transiently (M4, M7), VX-212's answer deletes user rows (M6), and the phase is several phases (M5).

## Findings (severity-ranked)

### BLOCKER

**B1 · §3.2 (the history key), §12 ("Wrap the history under the current library key… set aside"), §3.8 promises 2/8
· the history key is wrapped under the account master, so in Standard it IS reachable through the Apple account —
leaving Castle (or any road into a Standard account) hands every Castle-era retired key to an Apple-account holder.**

- *What's wrong.* §3.2 puts the history key H "wrapped in the key file under the passphrase, the words and the
  account master — never the Apple key", and argues: "Because it is never wrapped under the Apple key, leaving Castle
  later never makes keys that were only ever Castle-protected reachable through the Apple account." §12 rejects the
  simpler design for exactly this reason. But H is not replaced at Leave Castle (§3.2: replaced "at every re-key";
  leaving Castle is not one — decision 7), and Leave Castle adds the master under A to the vault.
- *Evidence (mechanism).* `PostureSwitchRunner.leaveCastle` writes `fetched.format.settingAppleHeldCopy(masterKey:
  material.masterSymmetricKey, appleKey: …)` into the vault (`App/Variorum/Shared/PostureSwitch.swift:1452-1463`);
  §3.10 keeps that protocol unchanged. Sequence: synced library, Standard (L0) → Use Castle (L1, H1; M1 has no A copy)
  → Replace All Keys in Castle, or a follow of one from another device (L2, H2 under P/W/M2; history {L0, L1}) →
  backups under L1 sit in the second folder (iCloud Drive, decision 24) → Use Standard (vault gains M2 under A; H2
  untouched). Now someone fully in the Apple account (A from iCloud Keychain; a session via an account-password reset
  by the iCloud email — pre-13x §3.4's own "who can obtain it" column) fetches the vault → unwraps M2 with A → unwraps
  H2 from any post-switch pair's key file (pairs carry "the whole key file of its day, history included", §3.2) → L1 →
  opens every Castle-era backup made under L1. Today those pairs carry L1 only under P1/W1/M1 (M1 retired by the
  rotation), so they stay Castle-protected after leaving (pre-13x §3.4's Castle → Standard row: "backups: untouched").
  The same holds for a Castle-born library joining a Standard account (`joinStandard` → the follow into Standard) and
  for "Move it to y@" into a Standard account (§3.7). Locally-only libraries are not affected (no M wrap).
- *Why the proof misses it.* Promise 2 checks only libraries *in* Castle; promise 8 only the entering direction. No
  promise checks "keys retired while in Castle stay unreachable through the Apple account after the library leaves",
  so the scenario test would pass this design.
- *Proposed fix.* Never wrap H under M (P, W and the device item only): what the M wrap adds over the local P/W
  copies is the vault road for a word changed on another device (the old word's local copy still opens it) and — in
  Standard — the Apple road. If the M wrap is wanted for Castle's vault road, drop it (and re-mint H, which needs P and
  W typed) at every road into Standard. Add a promise — "after leaving Castle, no key retired while in Castle opens
  through the Apple account" — and a fixed sequence for it.

### MAJOR

**M1 · §3.2 (the change counter), §3.6 (the open rule's "newer change counter" arm), §4 "Two Macs passing…", §11
("Newest choice wins") · the counter cannot say which choice is newer, the record it lives in is forgeable by the
very adversary Castle stops, and "the copy's key wins" lets a copy choose the library's future key.**

- *(a) Not causal.* Each device increments its own counter at its own acts, so two Macs holding copies of one
  local-only library diverge, and "higher" means "toggled more often", not "chosen later". Sequence: the Pro sends
  library X to the Air (both remember counter 1, Standard). The Air tries Castle and leaves it (Air: 3, Standard).
  Later the Pro enters Castle (Pro: 2, Castle — her latest choice). The Air's copy reaches the Pro (hand-off, or a
  shared second backup folder): 3 > 2, so by §3.6 "the copy's mode, account and key win" — the Pro's library drops to
  Standard under the Air's Apple-wrapped key, and the confirm calls an older choice "a newer choice made on another
  Mac". This breaks rule 1 ("nothing else changes it") and contradicts promise 4 ("never at a restore, an open").
- *(b) Forgeable.* §3.2: the record is "protected for free — only the library's key can read or change it". For every
  Standard-era copy that key is Apple-reachable, and an Apple-account holder (Castle's named adversary, pre-13x §2)
  can also mint a key and wrap it under A. The library ID is not secret (it is in every key file, and those sit in the
  iCloud Drive second folder). So a crafted pair — the victim's library ID, a key the attacker knows wrapped under A,
  a record saying `Castle, counter 999` — placed in the second folder (which §3.6's catalog newly lists in the restore
  list) opens through the Apple road without a prompt (§3.4 road 3), wins by counter, and installs the attacker's key
  as the library's current key while the confirm reports Castle ("the confirm says which and why", §4). The only
  backstop is §3.3's "if an Apple wrap is ever found, the repair is a re-key" — a re-key needs P and W typed
  (decision 33), so it is an act that can wait, and writing done before it lands under the attacker's key. A variant
  without the Apple wrap uses a Standard-era key the attacker extracted earlier and that sits in the victim's own
  history (§3.6's route finder opens it through H); once the Apple-openable pairs are gone — exactly what the
  recommended "Bring them into Castle" achieves — no Apple wrap of that key is ever "found".
- *(c) Undefined pieces.* On an exact tie "the safer mode wins" but not whose key (a Castle win over this device's
  Standard key needs a re-key: that key may be Apple-wrapped in older pairs); "this device's previous key moves into
  the history" needs the WINNING copy's history key, which an Apple-road open never has (H is never under A).
- *Proposed fix.* A copy never supplies the library's key and never lowers its protection: every copy of the same
  library is re-encrypted under the library's current key (or a freshly minted one when raising to Castle), and a
  copy's recorded mode can at most RAISE protection — or be offered as a question — never lower it. With that rule the
  counter (and arguably the in-file record) is unnecessary for local-only libraries; synced ones already defer to the
  vault.

**M2 · §3.7 (the account table; "Rows are stamped with an account when the library joins it, not at every sign-in")
· the account model is disconnected from row ownership, and the stated change would wedge sync.**

- *Evidence.* New rows take their owner from the SESSION at mint: `Operations.currentOwnerID()` →
  `ownerIdentity.current()` (`Sources/VariorumCore/Operations/Operations.swift:38`; mint sites e.g.
  `Operations+Container.swift:308/359/375`, `Operations+Comments.swift:37`). Rows minted signed out are born unowned,
  and the sign-in pass exists because "an unowned row would be refused by the push guard, and the sign-in flow runs
  the adoption pass before syncing for exactly that reason" (`Sources/VariorumCore/Operations/OwnerIdentity.swift:12-17`;
  `AppServices.runOwnerAdoption`, "at sign-in and at every signed-in launch").
- *Mechanisms.* (1) Stop the per-sign-in stamp as written ⇒ a library that belongs to X, edited while signed out,
  carries unowned rows when she signs back in as X (row 2 of the table: "In sync") ⇒ the push refuses them.
  (2) Row 4 (belongs to X, signed in as Y): "Not syncing… nothing changes" — but every edit meanwhile mints Y-owned
  rows into X's library; if she then picks *Sign out* and later signs in as X, the library holds rows of two owners.
  (3) §3.6: a restored copy that predates a Move takes "the library's current … account" in its record while its rows
  keep the old owner — the record says Y, the rows say X.
- *Proposed fix.* Ownership at mint follows the library's account (the record), not the session; the unowned-row
  backfill runs whenever the signed-in account equals the record's account; any landing whose rows' owner differs
  from the record's account runs the Move road (re-stamp + `resyncReinitialize`) inside its plan. Pin each of the
  three sequences.

**M3 · §7 (migration), §9 (risks) · the declared road back is not one, the wait has no end, in-flight markers and
other users' shapes are unaddressed.**

- *(a) The road back strands.* Step 3 removes the per-library-ID items (`<scope>-<storeID>-bound` / `-biometric`,
  `Sources/VariorumCore/Persistence/StoreKey.swift:265-267`). Rolling back = an older build + the A1 copy's files; the
  older build finds no per-ID item. A Standard library with an Apple wrap reopens through the Apple road
  (`AppBootstrap.swift:350-357`); a Castle library loses Touch ID (the lobby's `biometryOffered` needs
  `gatedItemExists`); an **exposed** library (no passphrase, no Apple copy — a Standard library whose Apple copy
  never landed) has no silent item and no wraps ⇒ `openStore` throws `keyUnavailable` ⇒ `failedOutcome` returns `.failed(…, recovery:
  nil)` (`AppBootstrap.swift:448`): doorless. And if the format-3 file is left beside the store, the older build's
  newest-mtime `locate` picks it and every unwrap throws `newerFormat(3)` (`StoreKeyEnvelope.swift:407-411`).
  *Fix:* leave the per-ID items in place (unread) for a release or more, or make "the road back" an in-app
  downgrade-safe act; never call the A1 copy alone the road back.
- *(b) "Wait" with no end.* Step 1 waits for the vault when synced. Signed-out-with-sync-keys and deleted-account
  libraries are indeterminate indefinitely today (research §6b rows 20/23, S-19), so they never migrate — while §3.9
  deletes the code that serves an unmigrated store (corner 45, `RawKeyCustody`, the gate's landing). *Fix:* define
  what `assess` returns with no record yet, or give the wait a terminal arm (e.g. signed out ⇒ record "account X,
  waiting for the vault", the custody shape as the interim mode).
- *(c) In-flight markers.* A store carrying `sync_state.rekey_in_progress` at migration — including VX-235's
  unclearable one, which `SyncEngine.refuseIfRekeyIncomplete` honours forever — is not mentioned: resume first with
  today's runner, translate to a plan, or (VX-235) clear it on a proof that the store opens under the old key? Same
  for a live `switchPending` / `thisDeviceOnlySwitch` flag (step 5 retires them; the latter carries the honest Done).
- *(d) Shapes.* The drills cover her Castle-and-synced stores ("the best-understood shape", §9) and the dev stores.
  0.9.x users exist in every §6b shape (exposed, Standard-waiting, VX-202-race and VX-209 victims, no-biometry Castle,
  signed out with keys, deleted account), and "each migrates once, quietly". *Fix:* the migration's acceptance is a
  drill per old-build shape (the scenario test can generate them if it models the old state shapes, not only new
  acts). Note the Keychain leg (re-filing a real `.biometryCurrentSet` item) cannot be drilled from a test host on
  either real scope: `KeychainTestTripwire` refuses every test-process mutation of `Variorum` and `Variorum-dev`
  (VX-201 record, the F-U2-8 fixture refused). So "drilled first on byte-copies of your stores" covers the files only;
  name the throwaway-scope drill and the Debug-app run on the dev store (a held stage claim) that cover the Keychain.
- *(e) H before any secret is typed.* H is minted at migration, but P and W are not typed at a Touch ID unlock, so a
  local-only Castle library's H sits only in the device item until the passphrase is next typed: backups made
  meanwhile carry an H no secret opens (rule 3's "on another Mac" fails for them), and a fingerprint change in that
  window invalidates the only copy. §9's "keeps every old key file until its key is safely in the history" must read
  "…in a history whose key carries a P or W wrap"; the first post-migration unlock should ask for the passphrase once
  (pre-13x §11 had that precedent: "the migration may ask ONCE").
- *(f) The ambiguous arm acts before it asks.* Step 1 keeps today's reading (Standard) for corner 45's ambiguous
  case when no switch evidence survives — and an adoption leaves no evidence (it lands exactly one key file and moves
  the rest aside, `LibraryAdoption.swift` step 5) — VX-209's shape. (Today's route already lands the Apple wrap at the
  next launch when A is readable, so the libraries still ambiguous at migration are those where it was not.) The
  Standard repair then lands the wrap, and "the first launch says plainly which mode" only afterwards; §3.3's own
  rule treats an Apple wrap as unrecallable ("may have been copied elsewhere"). *Fix:* in the ambiguous case write
  nothing Apple-reachable until her answer (decision 35's "indeterminate writes nothing", applied here).

**M4 · §3.3 ("Gate style is a fact, not a dial that can disagree: on a device with no Touch ID, Castle means Always
ask"), §4 "A Mac without Touch ID", §11 ("Gate style follows the device") · "no Touch ID" is read from a check that is
false transiently on Macs; enforced as a repair it destroys the Touch ID road of a lidded MacBook.**

- *Evidence.* Biometry is read as `LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error:
  nil)` (`App/Variorum/Shared/StoreKeyGuard.swift:95-101`). The settled design's own corner 36 records that this
  reports no biometry for "a closed MacBook on an external keyboard" and rules: "an existing biometric item on a lidded
  MacBook falls to the passphrase road **for that open**" — i.e. keep it. Today the transient reading already does
  damage in two places: the §11 migration persists Always ask and aligns custody to nowhere on `!biometryAvailable`
  (`ProtectionMigration.swift:240-244`), and the ceremony lands custody nowhere on `!biometry`
  (`PostureSwitch.swift:1330-1333`). Apple's own words (the lookup, CONFIRMED): `canEvaluatePolicy` — "Don't store
  the return value from this method because it might change as a result of changes in the system"; macOS 15's
  `builtInSensorInaccessible` — "Currently, the only example of this is a Clamshell Mode on macOS"; and the transient
  cases have their own codes (`biometryDisconnected`, `biometryNotPaired`, `biometryLockout`) beside
  `biometryNotAvailable` / `biometryNotEnrolled`.
- *Mechanism under the proposal.* The reconciler runs at every input change, enforces the Castle repair "every key …
  lives behind Touch ID or nowhere" against the effective gate style, and "repairs only move toward the record". A
  reconcile while the lid is closed (or the Touch ID keyboard is unplugged, or biometry is locked out after failed
  attempts) reads "no Touch ID ⇒ Always ask" ⇒ the target is "nowhere" ⇒ the Touch ID item (holding the key and the
  history key) is removed, or her stored preference flips; every later open asks for the passphrase until she notices
  and re-enables Touch ID — the exact symptom §6 row 3 lists as a bug to fix.
- *Fix.* Base "this Mac has no Touch ID" on a hardware/enrolment fact, never on a momentary `canEvaluatePolicy` false
  (distinguish the transient error codes); a repair never deletes a Touch ID item because biometry is unavailable now;
  the stored gate preference changes only by her press. Add lid-closed / keyboard-unplugged / lockout to the scenario
  test's action alphabet.

**M5 · §8 (the phase), "Size, honestly" · the unit plan is outside the sizing guidance by a wide margin and says
the opposite.**

- *Evidence.* `notes/PhaseSizingGuidance.md`: "Phase-sized = … a lockstep event, **a posture model**"; for
  custody/crypto "one unit is **one road** — a posture switch, a door, a recovery leg" with that road's drill as its
  evidence; "ONE acceptance unit per implementer session"; "at most TWO phase-sized units under ONE theme. A third is a
  split"; and "a plan … outside this guidance SAYS SO to her". U1 builds a new posture model (record, key file format
  3, history, assess, reconciler, plan runner, catalog, route finder, the scenario world) yet is called "not
  phase-sized"; U2 re-roads every custody door on two platforms plus the migration (≈15 roads, each a unit by the
  guidance) in one unit; U3 bundles the restore list, the open rule, the offer's groups and re-encryption, the export
  ID, Data Safety/RESTORE.md, VX-211, VX-212 (a `Sync/` mechanism) and VX-213. The postures phase this rebuilds took
  twelve implementer sessions (batches 1a–5b) and a two-round ladder.
- *Riskiest part / fallback.* Unnamed. The riskiest is U2's rewire of the open path plus the quiet migration of
  strangers' stores (a defect there is a launch-time stranding). The fallback ("the minimal structural fix", §12) has
  no decision point; once U2 starts there is no clean place to fall back to.
- *Fix.* Present it as a split (pre-13x's shape: one sitting, separate phase runs): the headless core as its own
  phase with the go/no-go for the fallback at its close; then road families as units with their own drills; the
  migration as its own unit with the per-shape drill (M3(d)); `Sync/` items (VX-107/109/212) together under Fable.

**M6 · §5 VX-212 ("the finishing device retires rows it proves no key can read, lists them in Diagnostics, and
completes") · an automatic server-side deletion of user rows, specified in one line, against settled sync doctrine.**

- *Evidence.* The walk decrypts every row below the rotation seq and throws on failure (`CorpusRotation
  .reencryptRemainder`, `Sources/VariorumCore/Sync/CorpusRotation.swift:592`); the server's completion guard
  refuses while any ciphertext-carrying row sits below the seq (`VARIORUM_ROTATION_ROWS_REMAIN`, the header at `:38-44`). To
  complete, a row must move above the seq or disappear — pushing its unreadable bytes back moves it above the seq,
  where it fails EVERY device's pull (a pull decrypts the whole window with `try window.map(crypto.decryptFromWire)`,
  `Sources/VariorumCore/Sync/SyncEngine.swift:473`, so one bad row refuses the round); the other road is tombstoning it
  with its content gone. A finishing device knows only C′ and C_prev, so "proves no key can read" is not provable (an
  older device may hold an older key). SyncSpec §6: "deleting an edit nobody chose to lose is the one forbidden
  outcome"; the proposal's §10 lists no SyncSpec change for it.
- *Fix.* Design VX-212 separately in `Sync/` (Fable) with its own canon line and her ruling: e.g. a named stuck state
  in which those rows stay sealed and are listed (never deleted), the previous key stays wrapped under M′ (no exposure
  — VX-191 §W.2), and decision 32's one-rotation-at-a-time refusal gains an explicit way out.

**M7 · §3.3 Castle repair ("after a passphrase unlock on a device set to Touch ID, the Touch ID item is put back") and
§6 row 3 · an automatic re-land after a biometry change removes the one protection `.biometryCurrentSet` gives
against her stated attacker.**

- *Evidence.* The gated items are created with `.biometryCurrentSet` (`StoreKeyGuard.swift:289-298`), which the
  settled design records as a feature: "adding a fingerprint invalidates it (P recovers)" (pre-13x §3.2, line 247);
  Apple: "The item is invalidated if fingers are added or removed for Touch ID" (the lookup, CONFIRMED).
  *[removed for publication]*
  password but might not know their passphrase" (`StoreProtection.swift:166-170`); pre-13x §2: Castle stops "your
  Mac's login password: yes".
- *Mechanism.* Someone with the Mac's login password enrolls their own finger (macOS asks for that password) ⇒ the
  Castle item is invalidated ⇒ the owner's next open falls to her passphrase ⇒ the proposed repair silently writes a
  NEW Touch ID item under the CURRENT biometry set — the intruder's finger included — holding the library key and,
  under this design, the history key: from then on that finger opens the library and every older copy. Today nothing
  re-saves the item (research §4.16), so the added finger never gets in unless the owner deliberately re-enables Touch
  ID. Corner 22 concedes that a finger enrolled *before* Castle passes; this would extend it to fingers enrolled
  after, silently.
- *Fix.* After a biometry change, ask once ("Touch ID changed on this Mac. Use Touch ID for Variorum again? Every
  finger enrolled on this Mac will open it.") and re-land only on that press; keep "the passphrase recovers" as the
  default. Pin the sequence.

### MINOR

**m1 · §3.1 rule 4 ("Backups made while you were in Standard also open through your Apple account") · repeats the
VX-263 overclaim the proposal diagnoses.** Exposed-era Standard backups carry no Apple wrap (research §1.2 row
"Exposed"; `Posture.localReading`'s no-passphrase arm, `StoreProtection.swift:104`), and an A minted while iCloud
Keychain is off stays on this Mac while it stays off (corner 46: "iCloud Keychain is off is undetectable on macOS").
And when two devices each mint A offline, iCloud Keychain keeps ONE and deletes the other (Apple's open-source CKKS
conflict rule — lower UUID wins, no merge; LIKELY), so every wrap under the losing A stops opening through the Apple
account; the proposal never states A's minting rule, and today's guards (`mintAllowed`, `appleKeyWaiting`,
`ProtectionController.swift:1636-1643`) must survive into the reconciler. *Fix:* "Backups
made while your library opened through your Apple account…", and let every surface take the sentence from the route
finder.

**m2 · §3.1 rule 3 and promise 5 · overclaim for copies made before the new build.** Migration step 4 adds an old key
to the history "the first time the passphrase is typed" — but the passphrase typed is today's, and an old key file is
wrapped under the passphrase and words *of its day* (decision 11). A Castle-era pair whose key was retired before a
passphrase change and a words regeneration never joins the history, so "every backup Variorum made of your library
opens with [your passphrase], your twelve words, or Touch ID" is false for it (the route finder will honestly say "the
passphrase you had on …", contradicting the rule). Also M3(e)'s window. *Fix:* scope rule 3 to backups made after the
new build, and define promise 5's "a road the user still has" (which secrets the model assumes she keeps).

**m3 · §3.1 rule 2 ("…an older library … comes back in the mode your library is in now") · false in two of the
design's own arms.** §3.6: "A different library keeps its own key and mode" — and an "older library" in `Previous
Libraries/` can be a different library (her ruled wording at #216: "older libraries Variorum kept when you opened or
restored a different one"); and M1's newer-counter arm changes the mode. *Fix:* "A backup of your library…" and drop
the counter arm (M1).

**m4 · §3.6 confirm sentence ("Your library goes back to how it was on 12 October. It stays in Castle.") · overclaims
for a synced library**, where §3.6 itself says "after Resume Sync, changes made since on your other devices come back
in". *Fix:* condition the sentence on the record's account (the 13x hold's own "catch up" wording).

**m5 · §3.4 "A missing key file is not fatal" · the reconciler cannot rewrite what it says it rewrites.** P and W
wraps (and the history blob, which lives only in key files) need the secrets or a surviving key file; and with the key
file gone the library ID — today read only from it (`StoreIdentity.resolve`, `StoreIdentity.swift:33-41`) — is
unknown, so "what this device remembers … per library ID" needs a location binding the proposal never defines. A
Castle library re-written with no P/W wrap is held only by the Touch ID item until the passphrase is typed. *Fix:*
name the per-location pointer; the rewrite asks for the passphrase at once and re-seeds the history from the newest
key file in the catalog.

**m6 · §3.4 / §3.5 / §3.6 — plans.** (a) "No backup is taken while a plan is in flight", but an enrolled Use Castle
re-keys the library only after the server re-encryption completes (`reencryptAndComplete` then
`rekeyCustodyAndSnapshot`, `PostureSwitch.swift:764-811`), so a rotation that
stalls (offline after the vault write; VX-212) stops every scheduled backup with no sentence. Gate backups on the
local-file window only. (b) "Everything a later step needs is captured up front" cannot hold for acts whose later
steps need a secret (change passphrase, enroll, VX-100's "carry the word into the enrollment"): a plan on disk must
never hold P, W or a derived key (pre-13x §3.1: never stored) — say which resumes ask again. (c) "No backup or copy
can ever carry a half-finished act": Time Machine / Migration Assistant copy a plan file beside the library — mark it
excluded from backup and let `assess` treat a plan whose world doesn't match as stale. (d) The open's order: landing
the copy and then re-encrypting it puts an Apple-openable file at the store path for the window, which §4's synced
VX-209 line says never happens; re-encrypt the staged copy straight into the store path instead. (e) Under "one key
file per library", prepare-then-commit writes the NEW key file before the swap, so in that window the one key file
names L′ while the store is still under L; §3.4's lobby derives roads from "this key" (the key file's) and would offer
Touch ID / the passphrase for L′ — the VX-80 wrong-key class again — unless the route reads the plan first. Say that
the plan names which key the store is under until its commit point, and that the open tries the history's keys.

**m7 · §3.3 "Repairs only move toward the record" · decision 35 must be explicit.** For a synced library whose vault
is unread, "toward the record" with a stale record (another device entered Castle while this one was offline) would
land the Standard Apple wrap — the window-phone incident decision 35 was written for. The assessment's "waiting for
the vault" implies the guard; make it a rule: no repair that adds Apple reach runs on a synced library without a fresh
vault read for its account.

**m8 · §3.3 last bullet ("A synced library whose vault says another mode owes the follow — an act, never a silent
repair") · ambiguous against pre-13x §7**, where the follow into Standard is silent (nothing typed, a notice after).
Say whether it stays automatic or now waits for a press.

**m9 · §3.2 table + §7 step 3 · the device identity's move has no migration leg.** §3.7 moves the sync identity out
of the sync-keys item; §7 step 3 says that item "keeps its shape". Without a carry, every migrated device mints a new
identity: a new `device_cursor` row while the stale one holds the purge horizon for up to 60 days (13j's drop-out),
and a returner round (corner 37). Add the leg.

**m10 · §3.2 ("a small local-only table inside the library file") and §7 ("the same road as the MCP grants and the
search index") · the table's export/classifier consequences are unaddressed.** Those two take different roads (MCP
grants travel empty, `StorePlaintextExport.swift:42-44,68-77`; the search index is kept, `SyncSchema.derivedTables`);
`localOnlyTables` is pinned as "exactly those four" (pre-13x §3.3; `SyncSchema.swift:367-369`) and the classifier
calls a file an export when "ALL FOUR local-only tables" are absent (`LibraryClassifier.swift:245-250`). Say which
family the record joins. Separately, §3.6 says the plaintext export "will now carry the library's ID" without saying
where (the record would be dropped with the local tables), and landing an export under the SAME ID on the same Mac
reuses this Mac's sync identity with a cursor reset to 0 — a state 13j's purge design never covered (SPECULATIVE; mint
a fresh sync identity on any landing that carries no `sync_state`).

**m11 · §3.6 (the Castle offer: "Other libraries in Previous Libraries/ are not this library's business and are not
listed") · narrows her ruling and leaves a gap unsaid.** #216's ruled wording counts "older libraries Variorum kept when
you opened or restored a different one" without restricting them to the same library; a different library's
Standard-era copy stays Apple-openable with no sentence, and the VX-210 line ("Variorum only looks in its own folders")
reads as if Variorum's own `Previous Libraries/` were covered. List it as a reversal of her wording or keep them in a
third group.

**m12 · §3.6 ("Bring them into Castle") · three survivors the offer doesn't name.** iCloud Drive's Recently Deleted
keeps a removed second-folder pair for 30 days (the delete offer already says so — `PostureCopy.swift:569-571`); the
folder-level `Backups/variorum-keys-<fp16>.json` files (Apple-wrapped old keys, written once per key —
`StoreBackup.copyKeyEnvelope`) are not pairs; and the 13p legacy escrow item — a RAW library key in iCloud Keychain —
is left by today's migration when it is "another key's" (VX-191 §O.2), against design law 28 ("iCloud holds a KEY TO A
WRAPPED COPY — never the copy"). The new migration is the natural place to remove escrow items for keys in the history.

**m13 · §3.8 (the scenario test) · "we don't have to imagine them; the test generates them" overclaims.** It explores
the modeled action alphabet against fakes: real-Keychain classes (the data-protection vs file keychain split behind the
13p-fix loss, access-group identity, `.biometryCurrentSet` invalidation, iCloud propagation), adversarial inputs (M1(b)'s
crafted copy) and B1's leaving-Castle reach are outside it. "Red on today's rules … `Posture.derive` and corner 45 are
pure functions, so they can be plugged in" cannot reproduce VX-209, whose mechanism is the per-ID slot plus
`landCustody`'s writes plus the gate's landing write (none pure — `LibraryOpenModel.swift:509-545`,
`StoreLaunchGate.swift:411-420`); W-1 does not fail promise 5 (a road exists — the leftover key file) but promise 9.
"Thousands of sequences in seconds" holds only with faked library files and test KDF parameters (Argon2id v1 is 0.77 s
per derivation, spike memo Q6). *Fix:* say what the generator cannot reach and keep the real-Keychain drills as gates.

**m14 · §3.7 ("If the account it belongs to no longer exists … the next sign-in says so") · not knowable by the
client.** A deleted account cannot be queried, and one re-created with the same email has a new user id — the screen
would read "This library syncs with x@…. You're signed in as x@….". Define the signal (e.g. same email, different
user id ⇒ ask), or drop the claim.

**m15 · σ, the store-variant scope, is absent** from the per-key item names and the per-library "what this device
remembers" item. On iOS the Debug and Release builds share one keychain (corner 47), and the A4 fence (dev never reads
real) is today carried by the scope in every account name (`StoreKeyKeychain.boundAccount`, `StoreKey.swift:265-267`).
Restate it.

**m16 · §12 (simpler alternatives) · a middle road exists that §12 doesn't weigh.** Per-key Keychain items + the
decide/act split (no writing reads) + every copy re-encrypted under the library's current key + plans beside the
library + KEEPING old key files and teaching one catalog-wide route finder to read them all (her #216 ruled fix shape
for W-1: "the restore list also consults other key files carrying the same key fingerprint") meets every ticket in the
project without the in-file record, the change counter, format 3 or a history key — so without B1 and M1. What it gives
up is "your current passphrase opens every old backup" (old keys keep their day's secrets, as decision 11 always said).
It deserves its row in §12, priced honestly against the full design.

**m17 · §10 (canon) · the list is incomplete.** Not named: AppSpec §12's 13x contract clause ("…after an A1-shaped
safety copy … and custody adopts the key that opens the landed file (the collision rule)"); AppSpec §7's `sync_state`
key `rekey_in_progress`; pre-13x §3.3 ("exactly those four" local-only tables in the file),
§3.5 (format 2, fingerprint naming, the try-each rule), §3.7/decision 14 (the missing-library route now in Standard
too), the §3.1 dials row ("UserDefaults per store ID"), corners 4 and 36; the 13x row-4 custody-collision memo and
13x ledger 5 (plaintext → fresh key AND fresh identity — the export-ID change reverses it); SyncSpec §6/§7 (M6).

**m18 · §3.7 row 3 ("account X | nobody … Mode doors say 'Sign in to change your account's mode'") · traps the
lost-account user in Castle.** A library that belongs to an account she can no longer sign in to (deleted elsewhere,
or abandoned) has, signed out, no door to Standard: §3.7 gives Use Castle a This-Mac-Only road but Use Standard only
"Sign in", and the deleted-account exit runs "at the next sign-in". Today `leaveCastle` runs locally while signed out
(it skips only the vault write, `PostureSwitch.swift:1452-1463`). VX-191 §W named this trap shape for Use Castle; the
proposal recreates its mirror. *Fix:* the same one-road This-Mac-Only screen for Use Standard (a counted change to
local-only), or a "stop syncing this library here" door reachable signed out.

**m19 · §3.2 ("what this device remembers … one small, non-secret, device-only Keychain item per library ID") and
§3.4 ("A missing library is missing in both modes") · the remembered record outlives the library on purpose-built
fresh starts.** On iOS, Keychain items have survived deleting and reinstalling the app (Apple DTS: an
undocumented "implementation detail" — "don't rely on that"; reported still true on iOS 17.5 — LIKELY), and on macOS
the data-protection keychain lives outside the app's container (TN3137), so deleting the container (the common "start
over" step) leaves it too (LIKELY). With the new rule, a reinstall or a cleared container meets
"Your library file is missing — restore it, open another, or start a new one" instead of a fresh library — on the
phone, a face whose first two doors do not exist (`MobileLibraryMissingView.swift:7-11`: "Start a New Library" is its
one door). Define how a remembered library binds to a location, and when a record whose library has been gone for a
while stops claiming the place (e.g. only a record whose key file still sits beside the store, or one seen at the
last launch, makes the missing face).

### NIT

**n1 · §2.5 ("Opening a copy has a crash window in which, under Standard, the app quietly starts a fresh empty
library") · it is mode-independent.** Step 4 moves every key file aside, so the route's store id resolves nil
(`StoreIdentity.resolve` reads only the key file), `localReading(nil)` is Standard (`StoreProtection.swift:102`),
`.auto` over an absent store routes `.open` (`StoreLaunchGate.swift:345-349`) and `resolveStoreKey` mints — for a
Castle library too. (The research's "libraryMissing only under Castle" is wrong the same way; the proposal's fix
covers both.)

**n2 · §1 / "The short version" ("In October so far, 40 of the 62 commits in this area were fixes") · the measure is
a subject-line regex.** The counts reproduce exactly (213 / 62 / 40 with Appendix B's method), but the matched set
includes non-fix commits (VX-206's and VX-204's builds, 13s U1b piece 6, 17y B-DEDUPE pieces). Say "fix-like".

**n3 · §2.5 table ("opening a copy | none") ·** the restore-hold marker beside the store is a crash record of sorts
(not a resume record) — "no resume record" is the accurate phrase.

**n4 · §2.2 (P6(b) "was never built") ·** the settled design chose the opposite explicitly (§3.5 / `StoreIdentity.swift:4`:
the id is "stable across re-keys"); "not adopted" is the accurate phrase.

**n5 · §8 cut line ("two pieces can move after launch without weakening any promise") ·** rule 4's second sentence
promises the bring-into-Castle offer; cutting it changes the rule's words.

**n6 · §5 VX-211 ·** a suggested passphrase drawn from the BIP-39 list invites confusing it with the twelve words (both
are lists of the same words); a different word list or a visible difference in shape avoids it.

**n7 · §3.6 (the catalog) ·** `.stale-<epoch>.json` set-aside key files are invisible to `keyFileURLs`
(`StoreKeyEnvelope.swift:433-438`); they can hold this library's old keys, so the catalog should read them as key
sources.

## Clean bill

Load-bearing things checked and found solid (review points named in brackets):

1. **[1] The diagnosis's mechanisms are real, at the cited code.** Corner 45 (`StoreProtection.swift:101-109`);
   `Posture.derive`'s five inputs (`:85-98`) and its six call sites, the gate's five (grep-recounted); per-store-ID
   item naming (`StoreKey.swift:265-267`); the route gate's landing WRITE (`StoreLaunchGate.swift:405-427`, write at
   `:411-420`) and its six callers — the route, R1-M3, the migration, `lock()`, adoption, and the phone's relock
   coordinator on every scene change (`AppBootstrap.swift:329/548/638/913`, `LibraryOpenModel.swift:533`,
   `VariorumMobileApp.swift:307`); `landCustody`'s result-dropping writes shaped by a reading taken before them
   (`LibraryOpenModel.swift:509-545`); newest-mtime `locate` (`StoreKeyEnvelope.swift:482-497`) against §3.5's
   unbuilt try-each rule; the silent-item READ that migrates items and writes a key file (`StoreKey.swift:273-293`);
   the controller's once-written, never-cleared `vaultReading` (`ProtectionController.swift:287/1463`, one controller
   per process) and its custody shape inferred from the resident key (`:1093-1096`); VX-108's doors on the cached
   posture (`ProtectionPane.swift:330-338`); VX-235's marker before the key file (`PostureSwitch.swift:1219-1223`) and
   the marker riding the step-6 snapshot (`:1235-1249`); VX-109's re-fetch (`CorpusRotation.swift:453-475`); the
   restore list's one-key-file read (`BackupRestoreCandidates.swift:85-122`); the three name parsers; Data Safety's
   self-contradiction (`DataSafetyPane.swift:515-539`); the no-biometry Castle custody target with the dial never set
   (`PostureSwitch.swift:1330-1333`); the five "enrolled"s (`StoreLaunchGate.swift:126-130`,
   `ProtectionController.swift:362-365`, `PostureSwitch.swift:584`, `KeyDoorModel.swift:134-137`,
   `EncryptionKeychain.swift:357-361`). The writer counts (9/5/16/9) and the 12 vault-bit reads were spot-checked, not
   recounted in full. The quoted canon and her words are genuine (`pre-13x-design-history.md:379,
   599-601`; QUESTIONS #216). Churn reproduces exactly (213 / 62 / 40 — n2 is about the label only).
2. **[3, 4] VX-209's local way-back is genuinely fixed by the design's core:** per-key items mean the restore never
   touches the Castle key's Touch ID item, and "same library ⇒ re-encrypt under the current key" means the way back
   moves nothing. VX-228's stranding tradeoff genuinely dissolves under "open by any road the copy has, then bring it
   into the library's mode" — exposed-era copies reach through the history.
3. **[2] The posture law at ENTERING Castle holds** under prepare-then-commit + per-key items + H replaced at every
   re-key: walked in steady state and at each crash point (new item and key file written / library swapped / old item
   not yet removed) — the retired silent item holds only the retired key and the old H, neither of which opens
   anything written after the switch; old key files reach only the old history. (B1 is the LEAVING direction.)
4. **[4] No forward road I walked strands a copy that opens today** — restore of each copy kind (C1–C6, C8), entering
   and leaving Castle, the follow, passphrase change, words regeneration, "Bring them into Castle" (the old pair goes
   only after the new one opens), migration with old key files kept until their key is in the history — apart from
   M3(a)'s road back and M3(e)'s window.
5. **[5] Feasible on these foundations:** re-encrypting a landed copy is the shipped export-and-swap road
   (`StoreEncryptionMigration.rekey`); per-key items are a naming change inside `StoreKeyKeychain`/`StoreKeyGuard`;
   the gated item's verify is presence-only today too (`KeychainCustody.swift:245-247`), so "verify before delete"
   costs no extra prompt; one evaluated LAContext can read the key item and the sync-keys item in one prompt (today's
   `unlockGated` does); U1 is genuinely headless (`swift test`, no stage) and U2's drills correctly need the stage.
   Moving the marker out of `sync_state` means `SyncEngine.refuseIfRekeyIncomplete` (`SyncEngine.swift:76-79`) reads
   the plan — correctly named as Fable's `Sync/` work.
6. **[7] No lockstep:** the record is local-only and the vault, key proof, rotation seq and server are untouched
   (VX-212 aside — M6); the marker stays 13.
7. **[2, 3] Decision 35's shape survives** as the assessment's "waiting for the vault" (subject to m7), and pre-13x
   §3.4's Standard → Castle row is kept (the old Apple-wrapped key file leaves the live folder at entering Castle under
   "one key file per library", which also closes VX-191 B6c).
8. **[7, 10] Her #216 rulings are rendered faithfully** — the signed-out screen's approved text (§3.7 row 3), VX-210's
   one line, VX-264's items, VX-209's concrete confirm, VX-265's separate choice — and §11 honestly lists what she
   must ratify, including the reversal of her "you'll be leaving Castle" yes.
9. **[3] Phone parity reasoning holds:** the phone composes the same `Shared/` brains, has no copy roads, and the
   proposal's "decisions never write" removes the scene-change write (custody research §7 M3).
10. **[10] §6's unticketed items are framed honestly** as traced, not reproduced, each owed a red-on-old pin.

## Platform facts used (the one Sonnet lookup, read-only, 2026-10-13)

- **Biometry availability is transient — CONFIRMED.** `canEvaluatePolicy`: "Don't store the return value from this
  method because it might change as a result of changes in the system"
  (developer.apple.com/documentation/localauthentication/lacontext/canevaluatepolicy(_:error:)); macOS 15+
  `LAEnvironment.MechanismBiometry.builtInSensorInaccessible`: "Currently, the only example of this is a Clamshell Mode
  on macOS…"; `LAError.Code` defines `biometryDisconnected` / `biometryNotPaired` (removable-accessory cases, macOS
  11.2+), `biometryLockout`, `biometryNotAvailable`, `biometryNotEnrolled`. Which code `canEvaluatePolicy` reports for
  a closed lid: UNCONFIRMED. (Used in M4.)
- **`.biometryCurrentSet` invalidation — CONFIRMED** ("The item is invalidated if fingers are added or removed for
  Touch ID, or if the user re-enrolls for Face ID"); whether the row is deleted or kept unreadable: UNCONFIRMED;
  developer reports show data reads failing with `errSecAuthFailed` on iOS 15+ and an M1 Mac, and attribute-only
  queries LIKELY still find the item. (Used in M7.)
- **Keychain items outliving the app — iOS: historically CONFIRMED as an undocumented implementation detail (Apple
  DTS: "don't rely on that"), current releases UNCONFIRMED; macOS container deletion: LIKELY** (TN3137: one
  data-protection keychain per user, outside the container). (Used in m19.)
- **Synchronizable add with iCloud Keychain off — LIKELY local-only success**; no public detection API found
  (consistent with corner 46). (Used in m1.)
- **iCloud Keychain same-key conflicts — LIKELY one survivor by UUID, the loser deleted** (Apple's open-source CKKS
  `CKKSIncomingQueueOperation.m`; Apple Platform Security: "one or the other is chosen"). (Used in m1.)


---

## Dispositions (2026-10-13 — the proposal's author; each mechanism traced in the code before it was accepted)

**Disputed: none.** Every finding was confirmed (m8 was a question and is answered; m16 is accepted as the honest
alternative rather than the recommendation). The proposal was revised in place the same day; the revision is
`design-proposal.md` as of the commit that adds this section. Because the fixes are substantial — the open rule, the
history key's wraps, the account model, the migration and the phase shape all changed — a fresh second read of the
revision is recommended before the sitting.

| finding | verdict | traced at | what changed in the proposal |
|---|---|---|---|
| **B1** history key reachable through the Apple account after leaving Castle | confirmed | `PostureSwitch.swift:1452-1463` (leaving Castle adds the master under the Apple key) against the first version's §3.2 (history key under the master) | the history key is wrapped under the passphrase and words only; it lives in the Touch ID item in Castle, never in a silent item, and leaves the device on leaving Castle (§3.2, §3.3); new promise 3 "leaving Castle stays honest" (§3.8); §4 adds "leaving Castle after a Replace All Keys"; §12 records the set-aside wraps |
| **M1** the change counter: not causal, forgeable, undefined arms | confirmed (a)(b)(c) | the counter sequence walked against the first version's §3.6; the planted pair against §3.4 road 3 | the counter is gone; a copy never brings its own key and never lowers protection; a copy from this Mac's own line takes the library's mode; a Castle copy from another Mac raises the library here through Use Castle's own steps with a fresh key (§3.6); §4 adds the planted copy and rewrites "two Macs"; §12 records the set-aside rule |
| **M2** account model vs row ownership | confirmed | `Operations.swift:36-38` (`currentOwnerID` reads the session), `OwnerIdentity.swift:12-17` (unowned rows refused by the push guard) | new writing belongs to the library's account, not the session; a library with no account mints unowned rows that joining claims; a landing whose rows belong to another account runs the Move road inside its plan (§3.6, §3.7, §6) |
| **M3** migration | confirmed (a)–(f) | (a) `AppBootstrap.swift:432-461` (no item and no wraps ⇒ a doorless failure), `StoreKeyEnvelope.swift:407-411` (`newerFormat`); (b) custody map §6b rows 20/23; (c) `PostureSwitch.swift:1219-1223`, `SyncEngine.swift:76-79`; (d) `KeychainCustody.swift:46-57` (the test tripwire); (e)(f) the first version's §7 | §7 rewritten: in-flight acts finished first (VX-235's stuck marker cleared on proof the switch never happened); unconfirmed synced libraries write nothing Apple-reachable; corner 45's ambiguous case records Castle with a notice; old Keychain items and key files kept unread for a release; the new key file under a name older builds don't read; the history key made only when a secret is typed (the first unlock asks once); per-shape drills; the Keychain leg on a throwaway scope plus the Debug app on the dev store; the road back stated with its limit |
| **M4** "no Touch ID" from a momentary check | confirmed | `StoreKeyGuard.swift:95-101` (`canEvaluatePolicy`), corner 36, `ProtectionMigration.swift:240-244`, `PostureSwitch.swift:1330-1333` | nothing acts on a momentary reading; Touch ID or Always ask is your stored choice; the switch asks when Touch ID can't be used (§3.3); §4 adds the closed-lid case; §6 lists today's damage; the scenario test gains lid, keyboard and lockout actions (§3.8) |
| **M5** phase shape vs the sizing guidance | confirmed | `notes/PhaseSizingGuidance.md:18-29` | §8 rewritten: one sitting, about five phases, a go/no-go after the headless core, the riskiest part and the cut lines named; the short version says so |
| **M6** VX-212's "retire rows" | confirmed | `CorpusRotation.swift:592`, `SyncEngine.swift:473` (one unreadable row refuses the whole pull window), SyncSpec §6 | the one-line answer is withdrawn; VX-212 gets its own `Sync/` design and your ruling (§5, §8, §11) |
| **M7** automatic Touch ID re-land after a biometry change | confirmed | `StoreKeyGuard.swift:289-298` (`.biometryCurrentSet` alone), `StoreProtection.swift:166-170` (her threat model) | after Touch ID changes, Variorum asks once, saying every enrolled finger will open it, and re-lands only on yes (§3.3, §4, §6) |
| m1 rule 4 overclaims | confirmed | research §1.2; corner 46 | rule 4 now reads "backups made while your library opened through your Apple account still do"; the route finder is the only source of any sentence about what opens a copy; the Apple key's minting guards carry over (§3.1, §3.3, §3.6) |
| m2 rule 3 overclaims for older copies | confirmed | decision 11; the first version's §7 step 4 | rule 3 is scoped to backups made from the new build on; promise 6 defines "a road the user still has" |
| m3 rule 2 false in two arms | confirmed | #216's "older libraries" wording | rule 2 says "a backup of your library"; the counter arm is gone |
| m4 confirm overclaims for synced | confirmed | the first version's §3.6 | the synced confirm gains its catch-up sentence; rule 2 notes it |
| m5 a missing key file | confirmed | `StoreIdentity.swift:33-41` | the location pointer is named; a missing key file asks for the passphrase once and takes the history from the newest backup's key file (§3.2, §3.4) |
| m6 plans (a)–(e) | confirmed | `PostureSwitch.swift:764-811`; pre-13x §3.1 (secrets never stored) | backups pause only during the file swap; plans never hold a secret; plan files excluded from backups and stale plans ignored; the staged copy is re-encrypted straight into place; the lobby reads the plan for which key the library is under (§3.4, §3.5, §3.6) |
| m7 decision 35 explicit | confirmed | pre-13x decision 35 | §3.3 states the guard: nothing that adds Apple reach runs on a synced library without a fresh vault read for its account |
| m8 is the follow into Standard still silent? | answered | pre-13x §7 | yes — automatic with a notice, as today (§3.3, §3.7) |
| m9 the device identity's move has no migration leg | confirmed; resolved by withdrawal | — | the device identity stays in the sync-keys item (§3.2, §3.10); no leg needed |
| m10 the record's table family; the export's ID; the sync identity | confirmed | `SyncSchema.swift:367-369`, `LibraryClassifier.swift:245-250`, `StorePlaintextExport.swift:42-44,68-77` | the record joins the local-only family (the plaintext export leaves it behind); §10 names the "exactly those four" change; the export carries the ID in a small plain table; any landing without sync bookkeeping gets a fresh sync identity (§3.2, §3.6) |
| m11 the offer narrows #216's wording | confirmed | QUESTIONS #216 | the older-libraries group keeps your #216 reach: other libraries Variorum kept can be deleted or kept (§3.6) |
| m12 three survivors | confirmed | `PostureCopy.swift:569-571`, `StoreBackup.copyKeyEnvelope`, VX-191 §O.2 | Recently Deleted named; folder-level Apple-wrapped key files cleared when their copies are gone; 13p escrow items for keys in the history removed (§3.6, §6, §7) |
| m13 the scenario test overclaims | confirmed | `LibraryOpenModel.swift:509-545`, `StoreLaunchGate.swift:411-420` | §3.8 states what the test can't reach and keeps the real-Keychain drills as gates; VX-209's red-on-old is the existing pin, flipped; W-1 fails promise 10 |
| m14 "the account no longer exists" isn't knowable | confirmed | — | no such claim; the same-email, different-account signal is named; the signed-out doors are the exit (§3.7, §4) |
| m15 the store variant missing from new names | confirmed | `StoreKey.swift:265-267` | every new item name carries the store variant (§3.2) |
| m16 the middle road | accepted as the alternative | — | §12 gives it an honest row, priced against the full design; §8's go/no-go after the core phase is where it can still be chosen |
| m17 the canon list | confirmed | the lines named in the finding | §10 completed |
| m18 no signed-out door to Standard | confirmed | `PostureSwitch.swift:1452-1463` | one-road screens for both Use Castle and Use Standard while signed out, plus *Stop syncing this library on this Mac* (§3.7) |
| m19 the remembered record outlives fresh starts | confirmed | TN3137 (via the lookup), `MobileLibraryMissingView.swift:7-11` | the missing-library screen is judged by a marker in the app's own container, so a reinstall or cleared container starts fresh (§3.2, §3.4) |
| n1 crash window is mode-independent | confirmed | `StoreIdentity.swift:33-41`, `StoreProtection.swift:102` | "in either mode" (§2.5, §6) |
| n2 "fixes" is a subject-line measure | confirmed | — | "fix-like" |
| n3 "none" | confirmed | — | "no resume record" (§2.5) |
| n4 P6(b) | confirmed | `StoreIdentity.swift:4` | "was not adopted" (§2.2) |
| n5 the cut line changes rule 4 | confirmed | — | §8 says what rule 4 then reads |
| n6 a word-list passphrase confusable with the words | confirmed | — | any suggestion is shaped visibly unlike the twelve words (§5) |
| n7 `.stale-` key files | confirmed | `StoreKeyEnvelope.swift:433-438` | the catalog reads them (§3.6) |
