# Cold read of `second-opinion.md` (VX-266)

**Reviewer:** second cold reviewer, read-only. **Target:** `notes/plans/vx-266/second-opinion.md`.
**Context read:** `design-proposal.md`, `cold-read-1.md`, `second-opinion-independent-notes.md`,
`pre-13x-postures-design.md` §1–§7/§14, and the code at every point the second opinion cites
(StoreProtection, AppBootstrap, StoreLaunchGate, StoreKeyEnvelope, StoreIdentity, AppleKeyCustody,
ProtectionController, StoreBackup, BackupRetention, ICloudDriveOffer, LibraryAdoption, LibraryOpenCopy,
RestoreHoldModel, StoreLockView, CorpusRotation). Worktree at `f91f7205`.

**One paragraph.** The second opinion's four changes and its structural option are, in the main, well
reasoned and its code citations are accurate where I could trace them. Its sharpest contribution — that a
library this Mac knows to be in Castle still opens an older copy through the Apple account first (§2.2), that
plans beside the library are forgeable (§2.3), and that two Macs sharing one iCloud Drive backup folder prune
and offer to delete each other's backups (§2.4) — all check out against the code. What is wrong is in the
framing and reach of the two biggest moves. **§3 (retire the Apple key) is written as if it helps the author,
but by its own cost 4 it does not: her stores and every current beta tester keep today's shared key and get
none of §3's benefits** (M2). **§3 also calls the follower-mint fix "one change," when in fact deleting A at
entering Castle re-creates the exact premature-mint / orphaned-vault-copy concurrency hazard that today's
"never delete A" rule exists to avoid, reopening the settled F2/F3 ladder** (M1). **§2.1 (drop the history
key) deliberately re-accepts cold read 1's only BLOCKER (B1) and understates its blast radius as "one narrow
case after you leave Castle," when it also widens Apple reach to retired/exposed-era keys in Standard** (M3).
The rest are minors and nits. No BLOCKER: nothing the second opinion recommends silently breaks a promise —
its riskiest move (§2.1) is disclosed, so the defect is understatement, not concealment.

---

## MAJOR

### M1 · §3 / cost 3 · "today's minting guards need that one change" understates a reopened concurrency hazard that §3 itself creates

**What's wrong.** §3 deletes the account's Apple key A at entering Castle and mints a fresh one at leaving.
Cost 3 says only: *"Followers must wait for the acting device's key, never mint their own; today's minting
guards need that one change."* That is not one change, and the need for it is a hazard §3 manufactures.

**Evidence / mechanism (traced).** Today A is **never deleted** (`AppleKeyCustody.swift:189-191`; the key is
per-iCloud-account and shared — `account(scope:)` at `:135` keys it by scope only). `reconcileAppleKey`'s mint
gate is `mintAllowed = vaultAppleKeyID == nil || holdsMaster` (`ProtectionController.swift:1636-1638`), and a
follower into Standard **holds the master**. The only reason a follower does not mint a second A today is that
`read()` returns the still-present shared A (`:1726` runs `readOrMint` only after `read()` answered nil;
`:1659-1663`), so `minted` is false and nothing new is created. Under §3, entering Castle **deletes** A, so on
the leave that mints the fresh A, a follower that reconciles before the fresh A has propagated reads nil,
`holdsMaster` is true ⇒ `mintAllowed` true ⇒ it **mints its own A₂**. iCloud Keychain then keeps one of the two
and discards the other (the proposal's own m1 fact), and if A₂ wins, the vault's `M`-under-A_fresh copy is
orphaned under a key no device holds — the precise F2 (MAJOR-3) failure the two-round pre-13x ladder was built
to prevent (`ProtectionController.swift:1600-1668`, the F2/F3 commentary). To stop it, `appleKeyWaiting` (today
fired only when `!holdsMaster`, `:1649-1653`) must now fire for a master-holding follower during a leave, which
needs a new "am I the leave-Castle actor" signal threaded into the reconciler — not present today.

**Why it matters.** The author is being asked to say yes to D3 believing the custody rework is "one change."
It is a re-opening of settled, previously-buggy concurrency logic (VX-99 was "two Apple-copy deciders"), and §3
is what introduces the window by abandoning the invariant (never delete A) that currently closes it.

**Fix.** State that D3 requires rebuilding `reconcileAppleKey`'s mint/wait gate so a follower never mints during
a leave (wait for the acting device's named A), and name this as reopening F2/F3 with its own convergence pins —
not "one change."

### M2 · §3 / "What it buys" vs cost 4 · §3's headline benefits do not reach the author's own stores or any current user

**What's wrong.** The short version and §3's "What it buys" are written unconditionally: *"every copy Variorum
ever made of that library … stops opening through the Apple account at that moment,"* *"§2.2's attack dies,"*
*"two plain rules replace the offer."* But cost 4 says: *"Existing stores keep today's shared key for their
older copies. The migration can't safely delete a key other libraries or accounts may use. For your devices and
the few beta testers, the offer stays as it is today; everyone who installs after launch starts on per-library
keys."*

**Mechanism.** Today's A is one shared item per iCloud account (`AppleKeyCustody.swift:135`,
`account(scope:) = "<scope>-apple-key"` — no library/account discriminator), used by every library and Variorum
account on that iCloud. The migration cannot delete it without stranding the other users of it, so every store
that exists today — the author's Pro and Air, every 0.9.x install — keeps the shared, never-deleted key and the
existing "delete your backups?" offer. §3 changes only libraries first created on a post-launch build.

**Why it matters.** VX-266 is a pre-launch pass on *the author's* Castle. D3 is recommended "yes," but for the
reader of this document it is inert: entering Castle on her store will still not cover her older copies, and
§2.2's attack still lives on her store's Apple road. The decision table (D3) and the short version give no hint
of this; only cost 4, buried in §3, does.

**Fix.** Move cost 4's limit into the short version and D3's recommendation line: "§3 changes new installs only;
your own stores keep today's shared key and the offer." Consider (and price) whether the migration could make a
store whose shared A no other library/account uses eligible — otherwise D3 is a decision about future users, not
about this launch.

### M3 · §2.1 · dropping the history key re-accepts cold read 1's only BLOCKER (B1), and "one narrow case after you leave Castle" understates its reach

**What's wrong.** Cold read 1's single BLOCKER, B1, was "after leaving Castle the Apple account reaches
Castle-era retired keys"; the proposal fixed it by wrapping the history key H under the passphrase and words
only (never A, never the master — `design-proposal.md` §3.2). §2.1 drops H and wraps the history under the
library's **current** key. In Standard the current key has an Apple copy, so **A → current key → history → every
earlier key**, which is B1's outcome. §2.1 characterizes the cost as *"one narrow case after you leave Castle."*

**Mechanism (traced against the proposal).** (a) After leaving Castle, the live key file gains `apple` for the
current key; the history under it then exposes keys retired *while* in Castle — B1 exactly, and the second
opinion admits this in the same section. (b) The characterization "one narrow case" is too narrow: §2.1 also
changes **Standard-mode** reach. The proposal keeps H off the device in Standard, so an older-key backup there
needs the passphrase/words (`design-proposal.md` §3.2). Under §2.1, A reaches the whole history in Standard —
so a Standard Replace All Keys no longer keeps the retired key out of the Apple account, and exposed-era
backups folded into the history become Apple-openable. That is broader than "after you leave Castle," even if
it is consistent with decision 30 ("in Standard no rotation shuts out an Apple-account holder").

**Why it matters.** §2.1's own argument that H "protects nothing at all" for users who never re-key is fair, but
the recommendation steers the author to re-accept the reviewed BLOCKER under a "simplification" banner while
pricing the security delta as narrower than it is. The author should weigh this as "re-accept B1 and change
Standard's retired-key exposure," with the honest leave sentence, not as a free simplification.

**Fix.** Re-state §2.1's security delta as two cases — (1) Castle-era keys reachable via A after leaving Castle
(B1 re-accepted); (2) retired/exposed-era keys reachable via A in Standard — and tie both to decision 30 so the
author sees the full picture. (The rest of §2.1 is sound; see the clean bill.)

---

## MINOR

### m1 · §2.2 · the attack is stated as general to "a library this Mac knows is in Castle" but only lands for a LOCAL-ONLY Castle library

**What's wrong.** §2.2 (and the short version item 1) presents the login-password file-swap as working for any
Castle library. For a **synced** Castle library it does not: the existing route logic blocks it.

**Mechanism (traced).** At the route, `effectiveGate` computes `enrolled = syncCustodyPresent(scope, storeID)`
(`StoreLaunchGate.swift:408`); the planted backup carries the same `storeID`, and the Mac still holds the sync
custody item for it, so `enrolled = true`. `Posture.derive` then returns `.indeterminate(shape:)`
(`StoreProtection.swift:91-93`), and `shapeReading` reads `rawKeyCustody`, which is `.gatedOrNone` under Castle
(no silent item; `StoreLaunchGate.swift:433-437`) ⇒ Castle ⇒ `effectiveGate = .biometric` ⇒ the **Castle lobby**,
Touch ID required. Only a **local-only** Castle library has `enrolled = false`, so `localReading` sees the
planted `apple` copy and returns `.standard` (`StoreProtection.swift:101-109`) ⇒ `.auto` ⇒ silent open via
`StoreLobby.openWithAppleKey` (`AppBootstrap.swift:350-357`), re-landed at `:548-556`. The trace the second
opinion gives is accurate for that case — and VX-209's appendix case is local-only — but the section's title
and the short version overclaim.

**Fix.** Scope §2.2's threat to local-only Castle libraries (and older copies under the shared key / another
account's key, which §2.2's last paragraph already notes), and credit that the synced case is already defended
by `enrolled ⇒ indeterminate ⇒ Castle shape`.

### m2 · §2.3 "Related, and smaller" · moving re-key-in-progress into the key file trusts an unsealed, forgeable field pre-unlock — against §2.3's own premise

**What's wrong.** §2.3's whole thesis is that files beside the library are forgeable by the login-password
holder, so plans must be **sealed**. Its closing suggestion — *"let the key file carry a re-key in progress
itself … the lobby then decides from one file … and never needs to read plans"* — puts trust in the **key
file**, which is exactly the unsealed, attacker-writable artifact the section distrusts (and which the author's
own independent notes, point 8, flag: "the route decides from the plaintext key file … nothing pre-unlock is
authenticated").

**Mechanism.** `StoreKeyEnvelope` is plain JSON (`StoreKeyEnvelope.load` decodes it with no authentication,
`:501-519`); an attacker who can write the container can set a false "re-key in progress (current + pending)".
The lobby is read-only (it only chooses which road to *offer*, and the real secret/key is still required to
open), so this is not a silent downgrade — but it is internally inconsistent to seal the plans because the key
file is forgeable and then ask the lobby to trust a new forgeable field in that same key file.

**Fix.** Drop the "smaller" suggestion, or state that the re-key-in-progress field is a road *hint* only, never
relied on for anything the key cannot already prove, and keep the plan (sealed) as the authority.

### m3 · §2.3 · "seal with a key derived from the library's current key" is underspecified for the re-key plans and Always-ask devices

**What's wrong.** The plans most needing tamper-proofing are the ones that **change** the current key (enter
Castle, Replace All Keys, leave Castle). "Seal under the current key" is ambiguous when the plan's purpose is to
retire that key: at a crash mid-re-key, is the seal under the old key L (write time) or the new key L′? §2.3 says
"checked after unlock, when the key is in hand," but mid-re-key the key in hand may be either L or L′ depending
on where the crash fell (the VX-80 window — `AppBootstrap.swift:498-556` reasons about exactly this).

**Mechanism.** On an Always-ask device there is no key at rest (no silent or Touch ID item), so the seal can be
verified only after the user types a secret at the next launch — which is acceptable (the attacker also cannot
seal), but it means a resumed plan cannot be verified silently, contrary to the "resumed at your next Touch ID
unlock" framing the attack assumes.

**Fix.** Specify that a re-key plan is sealed under a key the resume can always re-derive after unlock (e.g. the
old key, recoverable through the history once any current road unlocks), and that Always-ask resumes verify
after the typed unlock.

### m4 · §2.4 · the cross-Mac PRUNING hazard is sound; the cross-Mac OFFER-listing is framed as a bug but may be correct for a synced library

**What's wrong.** The pruning hazard is real and well traced: `existingBackups`
(`StoreBackup.swift:704-716`) lists every app-named snapshot regardless of library or Mac, `prune`
(`:609-615`) and `BackupRetention.keep` (`BackupRetention.swift:87-118`) count them all, and the iCloud Drive
offer opens the picker at `driveRoot` (`ICloudDriveOffer.swift:101-106`) with backups landing at
`<pick>/Variorum/Backups` (`BackupDestination.backupsFolder`), so two Macs defaulting the picker share one
folder and prune each other's history — a genuine data-loss hazard. But §2.4 also lists "the Castle offer on
one Mac lists the other Mac's backups for deletion" as a hazard; for a **synced** library those are Standard-era
copies of the *same account's* writing, so offering them for deletion to make Castle cover everything is
arguably the correct behavior, not a defect.

**Fix.** Keep the pruning hazard (unambiguous). Re-cast the offer-listing as "cross-Mac visibility" and note it
is correct for a synced library and only surprising for a local-only one. (The proposed per-library-and-Mac
attribution is the right fix for pruning regardless.)

### m5 · §2.5 · reopens cold read 1's m9 (device-identity migration leg), which the proposal deliberately resolved by withdrawal

**What's wrong.** §2.5 proposes moving the device identity out of the sync-keys item into "what this device
remembers." Cold read 1 raised exactly this (m9) and the proposal **resolved it by withdrawal** — "the device
identity stays in the sync-keys item … no leg needed" (`cold-read-1.md` dispositions, m9). §2.5 reintroduces
the migration leg (a new identity mints a new `device_cursor` row, the 13j purge-horizon drop-out / returner,
corners 37) that the withdrawal avoided.

**Fix.** §2.5 is explicitly optional ("Worth doing if the open-road phase has room; not required"), so this is
only a flag: note that it reopens m9 and carries m9's migration-leg cost, so "optional simplification" is not
free.

### m6 · §3 / short version · references VX-208 (and leans on VX-203) which the shared design docs' ticket table does not establish

**What's wrong.** §3 says D3 reduces the offer to "VX-208's Markdown-exports line," and the short version lists
"VX-203 … and part of VX-209" as offer tickets. The proposal's own ticket table (§5) enumerates VX-209/228/263/
264/265/210/235/107/108/109/212/213/211/239/243/233/266 — VX-208 is not among them, and VX-203 appears only in
prose. **SUSPECTED** — these may be live Linear tickets I cannot see; but a reader of the design docs cannot
verify the claim.

**Fix.** Cite VX-208/VX-203 where first used, or map them in §5's table.

---

## NIT

### n1 · §3 · citation `AppleKeyCustody.swift:191-197` is a couple of lines off
The "never deleted in production (§14.5)" sentence is at `:189-190` and the flagged `delete(account:)` at
`:191-195`; `:191-197` points just past it. Substantively correct, cite drift only.

### n2 · §7 decisions table · D3 and D4 both record on VX-228
D3 ("retire the Apple key") is marked "VX-228 (new scope)" and D4 ("never open without asking") is "VX-228";
two distinct decisions on one ticket will blur the recording. Give D3 its own ticket (it is genuinely new scope,
as the parenthetical admits).

### n3 · §2.2 robustness bullet · "what this device remembers … a non-secret item" now also holds "the current key file's wrapped keys and history"
Wrapped blobs grant nothing without the wrapping key, so "non-secret" survives (consistent with pre-13x §3.1's
"the key file … holding it grants nothing"); but the bullet adds a second copy of the wrapped history that must
be kept in step with the key file — a small new consistency burden presented as pure robustness. Name it.

---

## Clean bill — load-bearing claims I checked and found sound

1. **§2.1's four "half-locked" states of the proposal's history key H are accurate.** A passphrase change leaves
   a following device's local H under the old secret with no vault road (H is never in the vault — proposal §3.2),
   so it strands until the words are typed; Standard keeps no H on the device (every older-key restore asks);
   H is minted only when a secret is typed (migration must ask — proposal §7 step 5). All confirmed against
   `design-proposal.md` §3.2/§7.
2. **§2.1's "entering Castle is unaffected" is sound.** The re-keyed current key L′ carries no `apple` copy
   (`StoreKeyEnvelope.setAppleWrappedCopy` is never called under Castle), so the history under L′ is not
   Apple-reachable; nothing written after the switch is reachable through A. Matches cold read 1's clean bill 3.
3. **§2.1's alternative genuinely removes the passphrase-change strand.** With the history under the library key
   L, a follower holds L and opens its past with nothing typed (Appendix A's "passphrase changed on the Air,
   then a key replacement on the Pro" is correct).
4. **§2.2's attack is real for a local-only Castle library.** Traced end to end:
   `StoreProtection.swift:101-109` → `.standard`; `AppBootstrap.swift:350-357` opens via the Apple key;
   `:548-556` re-lands it silently; and the proposal (§4, "Someone puts an older, Apple-openable copy where your
   library was") opens-through-Apple-then-reconciles exactly as §2.2 charges.
5. **§2.3's planted-plan attack is real against the proposal as written.** The proposal's only guard is "a plan
   whose world doesn't match is ignored as stale," and the world is the library ID + key fingerprints, which are
   public in every key file (`StoreKeyEnvelope`), so a login-password holder can plant a world-matching plan. No
   seal exists in the proposal.
6. **§2.4's cross-Mac pruning hazard is real and correctly traced** (`existingBackups:704`, `prune:609`,
   `BackupRetention:87-118`, `ICloudDriveOffer.driveRoot:101-106`, `backupsFolder`), and the proposal/research do
   not name it (research C11 notes iCloud Drive placement but not the two-Mac shared-folder prune).
7. **§2.4's six "other hazards" trace to the cited code:** `ProtectionController.ensuredEnvelope:1129-1142`
   mints a new store ID on a foreign key file; `LibraryAdoption:295-304` lands the store before the key file
   with best-effort `try?` writes; `LibraryOpenCopy.swift:114` shows "your current passphrase (online)" from a
   mere `credentials.master` flag; `RestoreHoldModel.swift:85-89` ignores `clear()`'s failure return
   (`LibraryRestoreHold.clear` returns false on a failed removeItem, `:86-90`) and clears the banner anyway;
   `.stale-*` key files are invisible to `keyFileURLs` (`StoreKeyEnvelope:464-475`).
8. **§2.2's fix is not bypassed by a container delete on macOS.** Cold read 1's m19 establishes the device
   Keychain survives container deletion on macOS; since the never-lower rule is keyed by library ID through the
   Keychain-resident remembered record, an attacker who reuses the old library ID still trips it — the surviving
   item helps the rule rather than defeating it.
9. **The agreement table's core moves (copies re-encrypted under the current key; one decider/one writer; the
   record local-only / no lockstep; per-key custody) are consistent with the proposal and with cold read 1's
   clean bill**; I found no internal contradiction among §2.1–§2.5 beyond m2's key-file/plan tension.

**Apple-platform facts I did not independently verify (no web access):** iCloud Keychain deletion propagation
and same-key conflict resolution (§3 costs 2–3), and Keychain survival across app/container deletion (§2.2/§2.5).
The second opinion already marks these APPLE-FACTS-PENDING; I assume cold read 1's recorded findings
(one survivor by UUID; macOS data-protection keychain outside the container) and flag them UNVERIFIED here.

---

## Dispositions (2026-10-13 — the second opinion's author; each mechanism traced in the code before it was accepted)

**Disputed in part: m6 only** — VX-203 and VX-208 are real tickets, both Done and shipped in VX-201's run (PR #155). The
reviewer had no Linear access. The fix is the same either way: cite them where first used. **Everything else is
confirmed.** The second opinion is revised in place in the same commit that adds this section. The Apple platform
facts the reviewer could not verify arrived meanwhile from the research helper (`second-opinion-apple-facts.md`):
deletes of synchronizable items propagate everywhere, with no "recently deleted" for app items. The helper also
found a fact that changes §2.2's weight: Keychain Access holds a wildcard keychain entitlement, so the Mac's login
password very likely reveals Variorum's iCloud key.

| finding | verdict | traced at | what changed in the second opinion |
|---|---|---|---|
| **M1** retiring the Apple key reopens the minting race | confirmed | `ProtectionController.swift:1636-1638` (`mintAllowed = vaultAppleKeyID == nil \|\| holdsMaster`), `:1725-1726` (`read() ?? readOrMint()`); today only "A is never deleted" (`AppleKeyCustody.swift:189-191`) keeps a master-holding follower from minting | §3 now treats this as a design element, not "one change". Each account's Apple key is named by its own id. Only the device that makes the account (or library) Standard mints it. A device that can't read it uses a key of its own, under its own name, for its own file (corner 34's road). Two devices therefore never mint the same item, and the same-item conflict that orphaned the vault's copy can't happen. This is pinned as a convergence sequence, and noted as reopening the F2/F3 ground. |
| **M2** retiring the key doesn't reach existing stores | confirmed | `AppleKeyCustody.swift:135` (one item per scope, shared) | The short version, §3 and D3 now say who it reaches. A new step makes it reach existing stores. The migration moves every live Standard library onto the new per-library or per-account key, so the old shared key serves only old copies. Entering Castle — or, for stores already in Castle (yours), a one-time question — then offers to retire the old shared key, saying what that does to other devices' older Standard copies. |
| **M3** dropping the history key re-accepts B1; the reach is understated | confirmed (framing) | `design-proposal.md` §3.2; the key file's master wrap (pre-13x §3.5) | §2.1 now says plainly that it re-accepts cold read 1's blocker B1 as a stated trade, and gives both cases. (1) After any road into Standard, Castle-era copies under keys replaced while in Castle open through the Apple account. (2) In Standard, exposed-era copies become Apple-openable once the Apple key lands. It also records what the review surfaced: for a synced library, today's protection after leaving already stops at "copies from before your last key replacement", because every key file carries a master copy and leaving gives the master an Apple copy. The recommendation stays, as an explicit choice for her. |
| m1 the file swap lands only for local-only Castle libraries | confirmed | `StoreLaunchGate.swift:408` → `StoreProtection.swift:91-93, 113-116` (sync custody present ⇒ indeterminate ⇒ gated shape ⇒ the Castle lobby) | §2.2 is scoped. The in-app silent open is the local-only case, and synced Castle libraries are already defended at the route. The Keychain Access route (new fact) reaches both, which is why §3 matters. |
| m2 the key file's "re-key in progress" field trusts an unsealed file | confirmed (partly) | `StoreKeyEnvelope.swift:501-519` | The suggestion is dropped. The lobby never needs to know which key is current: it tries every road this device has for the library, and each road verifies itself, because a key that doesn't open the file opens nothing. Neither the key file nor a plan is trusted before unlock, and no decision is ever read from either. |
| m3 sealing is underspecified for re-key plans and Always ask | confirmed | `AppBootstrap.swift:530-556` (the VX-80 window) | §2.3 now specifies sealing. A plan is sealed under the library key in hand when it is written and names that key's fingerprint. After unlock, the executor verifies the seal with that key, reaching it through the history if the plan's own act has since re-keyed the library. An Always-ask device verifies after the typed unlock and before any step runs. |
| m4 cross-Mac offer listing may be right for a synced library | confirmed | — | §2.4 keeps the pruning hazard. The offer listing is recast as cross-Mac visibility: right for a synced library, but it must say whose copies they are. Under D3 the offer mostly disappears. |
| m5 §2.5 reopens cold read 1's m9 | confirmed | `cold-read-1.md` m9 disposition | §2.5 says it reverses the proposal's withdrawal and costs the migration leg. It also adds a guard against cloned identities (Apple fact 10: iOS Quick Start can carry ThisDeviceOnly items to a new phone). |
| m6 VX-208 / VX-203 not in the design docs | disputed in part (they exist) | Linear: VX-203 and VX-208 Done, shipped in VX-201 | They are cited as shipped in VX-201 where first used. |
| n1 cite drift | confirmed | `AppleKeyCustody.swift:189-195` | fixed |
| n2 D3 deserves its own ticket | confirmed | — | D3 now records on a new ticket under VX-266, at her word |
| n3 the mirror is a consistency burden | confirmed | — | named: the executor writes the key file and its mirror in one act, and the mirror is checked against the key file at every ready |
