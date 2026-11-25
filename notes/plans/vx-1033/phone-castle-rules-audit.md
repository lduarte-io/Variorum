# The phone against the final Castle rules — a conformance audit

Read-only audit of the iPhone app against `notes/CastleRules.md` (all 27 rules and the considered-and-not-pursued
ledger), at `main` 37cf317fe (2026-11-22). Nothing was built, run, or installed. No device and no production read was
used. Linear was not read: ticket coverage is judged from `notes/TICKETS.md` (titles only),
`notes/plans/vm-44/plans/minted/umbrella-08.md`, `-19.md`, `-21.md` and `notes/plans/vm-44/plans/master-work-list.md`.
Paths are repo-relative. `PW` means `App/Variorum/Shared/Protection/ProtectionWords.swift`.

**What was read in full:** CastleRules; SurfaceContracts' "Library protection" and "Library portability" passages;
MobileSoul §5; the D audit (`notes/plans/vm-44/audit/D-protection-sync-launch.md`, written at 5dde1bcf9 on Nov 12);
umbrella 8 (VM-103); the her-rulings table of sitting 1 (`notes/plans/vm-44/plans/sitting-1-rulings.md`, "The lock and
protection"). Wave 1 has merged since the D audit. Its changes to protection files were faces only (fonts, the shared
controls, roles). Neither the lock nor the road changed (`git log 5dde1bcf9..HEAD` over the protection paths).

**Verdict words.** HOLDS: traced in code. HOLDS BY ABSENCE: the phone has no door that could break the rule.
GAP: what the phone does, or what it lacks, differs from the rule. SAYS-WRONG: the behaviour is fine, but a sentence the
phone shows is untrue there or is worded for a Mac. CANNOT TELL: what would settle it is named. Inference is marked
*(inference)*.

---

## 0. Read this first

1. **On an iPhone, "your backups" means the iPhone's own backup, and that backup is not covered by what Use Castle
   promises.** On the phone, Use Castle and a join into a Castle account say: *"…the Apple and on-device keychain
   items are deleted… so your backups are Castle-protected along with your library."* Nothing keeps the library, its
   key file or the phone's backup pairs out of an iCloud or Finder device backup. A backup made under Standard and
   restored to the same iPhone brings back the device-only quiet item, which Apple documents as restorable to the
   same device. The library then opens with nothing typed. It reaches only what the backup holds, which puts it in
   the class of rule 25's second exception. On a phone, though, that case is the default rather than an edge, and
   the phone does not say it. (Finding 1.)
2. **When another device enters Castle, the phone keeps opening quietly, and nothing outside Settings says so.**
   Its writing never syncs until it follows. The only signs are two Settings rows: one names "keys replaced" and has
   a door that leads somewhere else (VM-111), and the other is the follow door, deep in Settings ▸ Protection.
   (Finding 2.)
3. **The phone cannot leave Castle, and cannot follow out of it.** When the account leaves Castle on another
   device, the phone says *"Your account changed on another device. Follow it first."* and offers no door to do it.
   VM-109 carries this, and she ruled at LP-7 that leaving must work on the phone. (Finding 3.)
4. **The phone writes backup pairs.** Canon and code both say "the phone keeps no backups". In fact the phone writes
   a full backup pair into its own `Backups/` folder at every act that changes keys or the account. Those pairs are
   never pruned, never listed, can't be deleted, and ride the device backup. This is not a hole: they are encrypted,
   and entering Castle sweeps their quiet locks correctly. But every phone sentence about backups was written on the
   wrong premise, VM-110's included. (Finding 7. I believe this is new and unticketed.)
5. **The Castle lock on leaving sits behind the network round, and the wait for that round cannot be cancelled.**
   When a round outlasts iOS's background time, the app is suspended with the library still open. The lock lands
   only after she comes back, and the "time away" stamp VM-105 will rely on is taken late too. (Finding 6.
   Unticketed as a mechanism.)

---

## 1. The 27 rules, one row each

| # | What the rule asks of a device | What the phone does (file:line) | Verdict | Ticket |
|---|---|---|---|---|
| 1 | Own random key; key file beside the library; copies kept without asking — beside it, inside every backup, a sealed copy in the keychain | Creation mints the key, the silent item, the Apple key and the key file (`Sources/VariorumCore/Protection/Executor/Acts/DeviceActs.swift:116-148`). The key file sits beside the store (`App/Variorum/Shared/Protection/ProtectionPlaces.swift:56`). The sealed copy is the device-only memory item's key-file mirror (`KeychainMemoryLeaf.swift:34-43`; offer candidate `KeyFileOffer.swift:115`). "Inside every backup" on the phone means only the pairs acts write (`CommonSteps.swift:257-260` → `FileBackupsLeaf.swift:71-84`). A library that never ran an act has none. The mirror restore runs at every open (`ProtectionOpenRoad.swift:1074`); its receipt waits for the Protection screen (`MobileShellView.swift:635-639`). | HOLDS | — (receipt home: VM-229) |
| 2 | Twelve words from birth, **never before the first screen**; the card above the quick entry; nothing stores them; warns before closing; the card retires at a landed set-up, join or move | The phone shows the creation card **before** the first screen (`App/Variorum/Shared/Protection/ProtectionRoad.swift:51-54`; `App/Variorum/Shared/AppBootstrap.swift:517-522`; `MobileRoadFaces.swift:230-285`). It has one button and no step that warns before it closes (`:276`). It has no band card. Nothing stores the words: the card's model is released at its button, and Copy exists on the Mac only (`AppBootstrap.swift:540-544`). Fresh words are also offered at Settings ▸ Protection ▸ *Record your twelve words…* (`MobileProtectionDoors.swift:425-462`). | **GAP** | VM-23 (VM-108 for the switcher) |
| 3 | Every library is asked for a passphrase: the reminder in the card (third launch, weekly twice, before the first backup, after a quiet road failed); the E6 card for an account passphrase never typed here | No ask, no reminder, no E6 card on the phone. The models exist in Shared (`PassphraseReminder.swift`, `WordsBand.swift`) but have no phone face. The only doors are *Set a passphrase…* in Settings ▸ Protection (`MobileProtectionDoors.swift:278-288`), the new-passphrase field at Turn on sync and Use Castle (PW:780, PW:586), and the lobby's E6 line (`MobileRoadFaces.swift:142`; PW:449). | **GAP** | VM-200, VM-23 |
| 4 | The key file carries every earlier key; every key change carries the list forward; only typed secrets reach through it | Shared core: every re-key goes through `KeyFile.rekeyed` (`CommonSteps.swift:106-116`). | HOLDS (shared) | — |
| 5 | A backup is the library plus its key file; it opens with the secrets of its day, with today's through rule 4, or through a quiet road that holds its key | The phone's own pairs: HOLDS. The iPhone's device backup is also a rule-5 backup, but the app does not manage it. "Today's secrets through rule 4" needs today's key file, and a whole-device restore replaces it *(inference)*. | HOLDS for the app's pairs; see §2b for device backups | VM-15 |
| 6 | Changing the passphrase or making new words re-locks the current key without changing it; the doors say so in one sentence | Change, Reset and New words are present (`MobileProtectionDoors.swift:243-462`). The act changes no key and takes no backup (`KeyDoors.swift:25-27`). The one line is said (PW:1128; `MobileProtectionDoors.swift:456`; `RoadKeyDoorFaces.swift:161-166`). | HOLDS | — |
| 7 | One pair at a time; a join adopts the account's pair and is told plainly; key doors change both locks; fresh words only at the first look or the new-words door | The join's words moment is shown or said (`MobileProtectionScreen.swift:443-459`; PW:729-730, PW:893-897). Key doors re-wrap the vault in the same act (`KeyDoors.swift:37-72`). Fresh words also appear at the creation card (rule 2's problem). | HOLDS (rule 2 caveat) | — |
| 8 | Standard: an Apple road plus an on-device road; a failed Apple road is quietly re-made | Both are written at creation (`DeviceActs.swift:134-135`). On-device road: `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`, no ACL (`KeychainCustodyLeaf.swift:179-190`). Apple road: synchronizable, `AfterFirstUnlock`, the shared access group (`ICloudAppleKeysLeaf.swift:57-72`). The re-makes run at every open (`ProtectionOpenRoad.swift:1095-1125`). | HOLDS | — |
| 9 | Castle: no quiet road through Apple on any device; Face ID optional; Always ask keeps no copy of the key on the device | Castle custody is a Face ID item using `.biometryCurrentSet` alone, with no passcode fallback (`ProtectionKeychain.swift:198-204`; `KeychainCustodyLeaf.swift:156-158`), or no item under Always ask (`CommonSteps.swift:92-97`). Sync keys sit in a Face ID item or in session memory only (`CommonSteps.swift:362-376`). Apple keys are deleted (`:266-309`). | HOLDS (once this phone has entered or followed) | — |
| 10 | Account-wide: every device follows, typing a secret once; until then it reads its own copy through its own quiet road, and that is "said plainly" | The follow door exists (`MobileProtectionScreen.swift:192-203`; `Follow.swift:172-235`) and asks for one secret. Until she presses it, the phone opens quietly. Rule 10's own sentence appears only inside the follow's confirm (`RoadAccountFaces.swift:441`; PW:967). Outside Settings nothing says the account moved. Inside Settings the sync row reads *"Sync paused — this account's encryption keys were replaced"*, and its door opens the Account sheet, not the follow (`SyncStatusViews.swift:212-228, 788`). | **GAP** ("said plainly"; the follow depends on her finding it) | VM-111, VM-201 (partial) |
| 11 | Entering types both secrets; a new key; Apple and on-device items deleted (the Apple deletion reaching every device); Face ID if chosen; export off; a new sync key in one write | Use Castle types both (`EnterCastle.swift:83-131`; `MobileProtectionDoors.swift:691-713`). The sweeps run (`CommonSteps.swift:184-236, 266-309`), the gate choice is offered (`MobileProtectionDoors.swift:129-175`), the vault is written (`EnterCastle.swift:26, 34`). There is no scheduled export on the phone. **The behaviour holds.** The words do not: *"so your backups are Castle-protected along with your library"* (PW:538-539, rendered at `RoadCrossingFaces.swift:245-247` and `RoadAccountFaces.swift:405-408`) is untrue of the iPhone's own device backups (§2b). | HOLDS / **SAYS-WRONG** | VM-15, VM-110 (wrong premise) |
| 12 | Leaving types both secrets and hands everything to Standard; the leave screen's sentence; other devices follow out quietly with a notice | Use Standard is never rendered (`MobileProtectionDoors.swift:540, 557`). The follow out is not rendered (`MobileProtectionScreen.swift:192-203, 217-218`). A join or Move that leaves Castle is not rendered. When the account leaves elsewhere, the phone says *"Follow it first."* and gives no door. | **GAP** | VM-109 (LP-7 ruled: it must work) |
| 13 | A Castle-era backup is protected while the library is in Castle | Castle-era pairs carry passphrase, words and master locks only, no quiet lock (`EnterCastle.swift:37-39`; `Follow.swift:115-124`). A Castle-era iPhone device backup carries at most the Face ID item. | HOLDS (Apple caveat in §6) | — |
| 14 | The account's keys are wrapped by the passphrase and the words only; joining from a new device types one | The phone's join asks one of the account's secrets (`MobileProtectionScreen.swift:405-414`; PW:870-871). The vault model is shared. | HOLDS | — |
| 15 | Rows sealed under the sync key current when written; every sync key kept; a key change only at entry; a device that hasn't followed cannot sync | The engine reads session or silent keys, with every earlier key (`NewRoadSyncKeyProvider.swift:43-57`). The server's key fence refuses a stale device, and the phone shows the keys-replaced row. | HOLDS (shared) | — |
| 16 | Leaving an account changes no key or secret; signing back in is a join | The three leaves and sign out are present (`MobileProtectionScreen.swift:154-162`; the act at `AccountActs.swift:57-61`). Each leave also writes a backup pair (`AccountActs.swift:63`). | HOLDS | — |
| 17 | A copy is a copy: Look inside, Make this my library; you never leave Castle by opening something | Neither door exists on the phone. | HOLDS BY ABSENCE | (SC-4: after v1) |
| 18 | Devices share through sync, never files | No file sharing, no document types, no open-in handler (the phone target's build settings at `Variorum.xcodeproj/project.pbxproj:943-992`; the entitlements carry only keychain groups). | HOLDS BY ABSENCE (iOS device migration: §6) | — |
| 19 | Copies of other libraries are listed and can be deleted | Previous Libraries can exist on the phone: from *Start fresh* over a pre-design store, and from rule 27's *Start a New Library* (`ProtectionOpenRoad.swift:401-413`). No listing and no delete door. Their quiet roads stand (VX-469), and they ride device backups. | **GAP** (a ruled deferral) | W-207 / SC-4 |
| 20 | Every key act is planned; a crash leaves old or new; the next open finishes or rolls back **and says which** | The shared plan runner. The settle runs on every open road: quiet, typed and Face ID alike (`ProtectionOpenRoad.swift:345-382, 1059-1070`). "Says which" happens only for a settled follow: its durable Done (`ProtectionOpenFaces.swift:388-393`), shown only in Settings ▸ Protection. Every other outcome is only logged (`ProtectionOpenRoad.swift:1064, 1142`). | HOLDS (mechanism) / **GAP** ("says which"; shared with the Mac) | VX-452 (the join only) |
| 21 | The device remembers four things; a library that isn't the one last opened opens with a notice once; a key-file offer | The memory item is present. The notice and the offer are in the interlude (`MobileRoadFaces.swift:289-355`). Their words say "this Mac" (`LibraryNotice.swift:46-47`; `KeyFileOffer.swift:41`). | HOLDS / **SAYS-WRONG** | W-199 → VM-110 |
| 22 | A key is deleted only after its replacement is verified | Custody is retired after the swap, each only once the history holds it (`CommonSteps.swift:184-236`). Apple keys are retired after the swap and memory. One note: the bound account's silent sync-keys item is dropped at the follow's **first** step, before the swap (`CommonSteps.swift:376`). It is a cache of keys the vault holds, so nothing is lost. A crash in that window leaves the phone "Sync locked" until a secret is typed *(inference)*. | HOLDS | — |
| 23 | A plain random device ID per library, made at creation | `SystemIDsLeaf.swift:17`; `DeviceActs.swift:123`. No hardware read anywhere (grep). | HOLDS | — |
| 24 | Nothing behind `#if DEBUG` but test switches that turn a guard off | The guard switches (`ProtectionGuards.swift:22-40`) and the test-host KDF floor (`PassphraseKDF.swift:117-131`). Also walk machinery that a launch environment arms: forget a quiet road once, fail Face ID once, the test-account road (`ProtectionWalkSwitch.swift:30`, the whole file; `AppBootstrap.swift:365-372`; `KeychainCustodyLeaf.swift:70-94, 147-155`). | HOLDS (walk machinery is a second Debug-only class, shared with the Mac) | — |
| 25 | No promise for Apple's roads; two named old locks survive entering, neither reaching current writing | The rule's own sentence is said at Use Castle when copies are under a former Apple account (PW:553-554; `RoadCrossingFaces.swift:254-256`). The iPhone device-backup case is the same class at default scale, and the phone does not say it (§2b). | **SAYS-WRONG** (unsaid; TRACED-RISK) | VM-15, VM-110 |
| 26 | Stores from before this design are not handled | Her face, with *Start fresh* only (`MobileRoadFaces.swift:50-113`). | HOLDS | — |
| 27 | No key file copy and no backup anywhere means gone; synced libraries come back from the account | The lobby's moment offers *Start a New Library*, with the account sentence (`MobileRoadFaces.swift:122-137`). After a quiet open, the sheet says *"Make a backup now, so a copy exists."* with OK only (`MobileRoadFaces.swift:359-387`; PW:66-67). The phone has no backup door. | **SAYS-WRONG** | none (VM-110 could take it) |

---

## 2. The phone's own questions

### a. Following into and out of Castle (rules 10–12)

**The phone's quiet roads are both kinds at once while it is in Standard.**
- **The device-only item.** Service `ProtectionNames.custodyService`, account `<scope>-<fp16>-silent`, generic
  password, data-protection keychain, `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`, no ACL, never synchronizable.
  Its label is the library ID. Code: `KeychainCustodyLeaf.swift:179-190`; `ProtectionKeychain.swift:73-84, 157-174`.
- **The Apple item.** Service `ProtectionNames.appleKeyService`, account `<scope>-apple-key-<id>`,
  `kSecAttrSynchronizable = true`, the shared access group (`ProtectionKeychain.sharedGroup`),
  `kSecAttrAccessibleAfterFirstUnlock`, no ACL. Its label is the library ID. Code: `ICloudAppleKeysLeaf.swift:57-72`.
  Deletion matches either sync flag (`ProtectionKeychain.swift:188-196`), so a delete reaches iCloud Keychain.
- `<scope>` is the store variant's raw value (`ProtectionSystem.swift:120`).

**The entering device's deletion does not reach the phone's roads.** Each device has its own library, with its own
key and its own library ID (rule 18). The entering Mac retires only Apple keys it owns for *its own* library: those its
section lists, the one its outgoing key file names, those its catalogued key files name, and those stamped with its
library ID (`CommonSteps.swift:266-309`). Deleting any other key on sight is guarded off (`ProtectionGuards`,
`deleteOnSightByIDOnly`). The phone's Apple key carries the phone's library ID, so it survives the Mac's entry. Rule 11's
sentence, "an Apple item's deletion reaches every device", is true of the entering device's own items. The phone's
own quiet roads die only when the phone itself follows. That is consistent with rule 10.

**What happens at the phone's next open after another device enters Castle:**
1. **It opens quietly.** The route tries the silent item and the Apple wraps (`ProtectionOpenRoad.swift:371-380`). The
   library is still Standard here, so no secret is asked.
2. **Sync is fenced.** The first round hits the server's fence because the sync key was replaced. Settings' sync row
   reads *"Sync paused — this account's encryption keys were replaced"*, and its door is *Account…*
   (`SyncStatusViews.swift:212-228, 788`). No row or card outside Settings says anything (the D audit's D-37,
   re-checked).
3. **Settings ▸ Protection shows the follow.** It reads a fresh vault and shows *"Your account entered Castle on
   ‹device› on ‹day›."* with *Follow your account…*. The follow-owed line *"Your account changed on another device.
   Follow it first."* is said once. The key doors and crossings it locks are hidden (`MobileProtectionScreen.swift:
   89-100, 153, 192-203`).
4. **The follow's confirm.** It shows the notice, rule 10's sentence (PW:967), the ask *"Type your passphrase or your
   twelve words once to follow it here."* (PW:941), the Face ID / Always ask choice, and **one** secret field pair
   (`MobileProtectionScreen.swift:405-414`). Signing in to the library's account is required (`Follow.swift:183`).
5. **What the act does** (`Follow.swift:60-74, 111-139`):
   - It picks up the new master from the vault with the typed secret. It holds the account keys the Castle way, as a
     Face ID item or session memory, and drops the silent sync-keys item (`CommonSteps.swift:352-385`).
   - It mints a new Castle key. With Face ID chosen, the Face ID item is made at this press (`CommonSteps.swift:92-97`).
   - It writes a new key file with the typed secret's lock and the new master's lock, plus the master's words copy. The
     history takes every old key. There is **no** Apple lock (`Follow.swift:115-124`).
   - It stages, writes the record and swaps.
   - It then deletes: every silent custody item for a key in the history, every one a catalogued key file of this
     library names, and every one stamped with this library's ID (`CommonSteps.swift:184-223`); every silent sync-keys
     item for an account the library doesn't name (`:230-235`); every one of the phone's own Apple keys
     (`retireOwnAppleKeys`, `:266-309`). It writes a backup pair into `Backups/` (`:257-260`).
   - If the words were the secret typed, the key file has no passphrase lock afterwards. The passphrase then opens the
     library only through the vault, online, until it is typed here (the lobby line at PW:449; the band's E6 card is
     missing, VM-200).
6. **What it can open before it follows:** its own local library and its own pairs, through its own quiet roads. The
   Apple road also reaches any device on the Apple account that holds this key file, for example a restored device
   backup. Writing made on the phone in this stretch stays local and Standard and cannot sync (rule 15). It cannot read
   anything written elsewhere after the entry.
7. **Out of Castle.** Nothing on the phone (§1, rule 12).

### b. The iPhone's own device backup (VM-15)

**What iOS backs up today (traced).** The store lives at `Library/Application Support/<variant>/variorum.sqlite`
(`Sources/VariorumCore/Persistence/AppDatabase+Dependency.swift:78-90`). Application Support is backed up by default
*(Apple default)*. In that folder:
- **Excluded:** only the plan file (`FilePlanStoreLeaf.swift:38-40`). The probe scratch lives in `tmp`
  (`ProtectionPlaces.swift:47`), which iOS leaves out.
- **Backed up:**
  - the store and its `-wal`/`-shm`, SQLCipher-encrypted;
  - the live key file (`ProtectionPlaces.swift:56`);
  - the "lived here" marker;
  - **`Backups/<library8>/<device8>/` pairs.** Each is a full snapshot under the key of its day, plus that day's key
    file. One is written at every Use Castle, follow (except the pair kind), set-up, join, Move, leave, and Replace All
    Keys (`EnterCastle.swift:23`; `Follow.swift:62-63`; `AccountActs.swift:63, 72, 116`; `ReplaceAllKeys.swift:18`;
    `CommonSteps.swift:257-260`). None is ever pruned: retention runs only from the daily hook, and the phone never
    starts it, since its `backupEnabled` is `false` (`VariorumMobileApp.swift:109`);
  - `Previous Libraries/<stamp>/`;
  - a `.staged` file and its marker while an act is between staging and swap.
- **Not related:** the directory's file-protection class, `completeUntilFirstUserAuthentication`
  (`AppBootstrap.swift:1560-1569`), controls when the files can be read. It does not keep them out of backups.
- **The keychain items:** the device-only items (silent custody, memory, silent sync keys, sign-in tokens, the Face ID
  items) and the synchronizable Apple key.

**What a backup made in Standard could still open after the account enters Castle.**

| Case | The backed-up key file's locks | What opens it |
|---|---|---|
| (i) The phone has **not** followed yet | passphrase (if set), words, master (if synced), the phone's Apple key | The Apple key is alive in iCloud Keychain, so it opens quietly on any device on that Apple account. Restored to the same iPhone, the silent item also comes back *(Apple-dependent)*. It holds Standard writing up to the backup date, including writing made on the phone after the entry, which never synced. This is rule 10's accepted state, extended to the phone's backups. |
| (ii) The phone **has** followed | the same old key file | **On another device:** the Apple key was deleted account-wide at the follow, so that road is dead, *if* Apple propagates the deletion and *if* device backups do not carry synchronizable items themselves (both Apple-dependent, §6). The passphrase and words of that day open it. **On the same iPhone:** restoring the backup restores the device-only silent custody item, so the restored library opens with nothing typed. Apple documents that `ThisDeviceOnly` items are restored only to the same device, which implies they are restored there; confirm (§6). It reaches only what the backup holds. The restored silent sync-keys item carries only the pre-entry keys, so writing made after the entry stays unreadable, and the phone would ask for the follow again. |
| (iii) A backup taken **after** the follow | Castle key file: no Apple lock, no silent item | The Face ID item at most (rule 9 allows it). The pre-entry pairs inside it have already lost their quiet locks. |

**What is traced and what is Apple's.** The app side is traced: nothing is excluded except the plan, and the phone's
Apple key is deleted only at its own follow. Apple's side cannot be shown by code: whether device backups carry
`ThisDeviceOnly` items and restore them only to the same device, and whether they carry synchronizable items at all.

**Compared with the Mac.** On the Mac, the "backups" that rules 5, 11 and 13 speak of are the app's own pairs. Their
quiet locks are swept at entry, by stamp, history and catalogue, so the Mac's lead sentence is true there. Rule 25
names the leftovers: a former Apple account's lock, and "a quiet lock this Mac no longer remembers… after a rollback",
which reaches only backups from before the entry and never current writing. **The iPhone's case (ii) is the same class
as that second exception**: an old quiet lock the app cannot reach, which opens only pre-entry content. It differs in
two ways:
- **Scale.** iCloud Backup runs nightly and is usually on *(inference about defaults)*. A whole-device restore brings
  back the files **and** their keychain item together. On a Mac a rollback is an edge case.
- **Wording.** The phone's Use Castle lead promises the opposite without hedging. On a phone, "your backups" naturally
  means the iCloud backup, which is the backup a phone user knows about.

If device backups also carry the synchronizable Apple key, a pre-follow Finder backup and its password would carry an
Apple-road lock the app can never delete. That would be rule 25's *first* exception's class.

**For her VM-15 call.**
- For an unsynced, phone-only library, the device backup is today the only off-device copy of the key file. Rules 1
  and 27 lean on it: lose the phone, and the backup is the way back. This is umbrella 8's stated tension.
- The key file is rewritten at every key change, and SQLite recreates its side files. An exclusion that should outlast
  those rewrites has to be set on the folder or re-applied after each write *(inference from Apple's exclusion
  semantics)*.

### c. Locking (rule 9 and the phone's reading of it)

| Moment | Today, Castle | Today, Standard |
|---|---|---|
| App switch, notification, Control Center into another app, side button | `.background` → the quick note is filed → editors flushed → savepoints → **one sync round** → only then `didLeaveTheScreen` → lock (`MobileShellRouter.swift:404-437`; `MobileRelock.swift:126-131`) | No lock. Its quiet roads would open it again at once (R13p-14). |
| `.inactive` (switcher peek, pull-down) | Nothing happens (`MobileShellRouter.swift:363-365`); the redaction applies | The same |
| The iPhone's screen locking | Not observed; no `protectedData` code (grep). Pressing the side button is a background. | — |
| After N minutes away | Never fires. `locksOnReturn` can't run, because every Castle leaving already locked and cleared `leftAt` (`MobileRelock.swift:133-145`). | No policy |
| Launch | The route tries the quiet roads; Castle has none, so the lobby shows. Face ID asks by itself when the app becomes active (`MobileRoadFaces.swift:86-96`). | Opens quietly |
| The process ends | Everything goes. Nothing "unlocked" is ever persisted (D audit §2.2, re-checked). | — |

**Face ID versus Always ask.**
- Face ID keeps one `.biometryCurrentSet` item. Its read prompts, offers no passcode fallback
  (`localizedFallbackTitle = ""`, `KeychainCustodyLeaf.swift:156-158`) and gives up when Face ID is unusable.
- Always ask keeps no custody item, and the sync keys live in session memory only. Every lock means typing again.
- Both hold rule 9.

**What the lock lets go of.**
- `binding.lock()` sets the writer and the key to nil, checkpoints, and closes the pool (`StoreBinding.swift:89-114`).
- The session's sync keys and the typed unlock's derived secret are dropped (`ProtectionRoadLock.swift:60-64`).
- `roadSession`, `roadStanding` and the engine's key seam are let go (`AppBootstrap.swift:1483-1488`).
- Services are stopped and nil'd (`VariorumMobileApp.swift:143-155`).
- The standing protection sheet is dropped (`ProtectionSheetPresenter.swift:147-153`).
- The bootstrap's long-lived models (crossings, account, key doors) read the session at call time and do not capture
  it (`AppBootstrap.swift:987-1001`).

**What stays in memory while locked.**
- The capture box's draft. This is ruled: the text stays in the box and goes to no side channel
  (`MobileQuickNote.swift:150-160`).
- **The first `AppSession` of the process.** The box binds it once and keeps it (`MobileQuickNote.swift:289, 345-346`),
  and the router that owns the box lives for the whole process (`VariorumMobileApp.swift:33`). That session holds the
  structural undo stack, the drafts parks and the wing state (`AppSession.swift:222-237, 789-799`). Their contents can
  include note text *(inference)*. This is VM-107's binding seen from the memory side.
- Swift does not scrub freed pages; `StoreBinding.swift:19-26` says so honestly.
- **The app-switcher snapshot.** It is taken at background entry, before the lock, so it shows the page. Only spans
  marked privacy-sensitive are covered. Her LP-3 ruling keeps the page visible.
- **The pasteboard.** The phone never copies the words. Copying a whole note puts plain text on the general board with
  no expiry (`MobileNoteClipboard.swift:66-70`), and it outlasts a lock. The rules say nothing here.

**A held handle across a relock (VM-107).** The box's session reads through the one ambient bound view. While locked,
every access throws `StoreLockedError` (`StoreBinding.swift:28-32`). After the unlock the same view reaches the fresh
pool. So the box never writes into a closed library and never holds a stale key. What it does keep is the old session's
runner, undo stack and parks (row W-028).

**Does anything keep working against a closed library?** Nothing that writes it.
- The leaving flush still runs `fileOnLeaving` while locked. The mint is refused, and the box keeps her text with its
  sentence.
- Sync is gone, because services are nil.
- **One timing risk (finding 6).** The lock waits for the leaving round: `SyncSession.flush` → `awaitIdle()`, a
  continuation that ignores cancellation (`Sources/VariorumCore/Sync/SyncScheduler.swift:193-196`). If the round
  outlasts iOS's background grant, the expiration handler cancels a task that keeps waiting. iOS suspends the app with
  the Castle library open and its key in memory. The lock runs after she comes back, possibly while she is using the
  app *(inference about iOS suspension timing; the code is traced)*.

### d. The twelve words and the passphrase on the phone (rules 2, 3, 6, 7, 14)

**Where the words show:**
- the creation card (§1 rule 2);
- the join's words moment (`MobileProtectionScreen.swift:443-459`);
- New words, through the one look (`MobileProtectionDoors.swift:425-462`; `MobileProtectionScreen.swift:529-641`).

**What stores them.** The app does not. The card and look models hold the words in memory until her button. There is
no Copy on the phone (LP-9 ruled it away; `AppBootstrap.swift:540-544` is Mac-only). No phone code writes words to the
pasteboard (grep: `MobileClipboard` carries note text only).

**The card's rules.**
- It breaks "never before the first screen".
- It warns only in its lead (*"Variorum won't show them again"*), never as a step before it closes. The look *does*
  have the warning step (PW:696).
- It says "won't show them again" over a library a join is about to replace.

**The app switcher.**
- The redaction is attached to the `.ready` arm only (`VariorumMobileApp.swift:76-87`). The creation card
  (`.newLibraryWords`, `:216-218`), the lobby (`:211-215`) and the interlude are outside it.
- So the creation card's words are not covered (VM-108; traced from code, device to confirm). A **revealed**
  passphrase or words field in the lobby is not covered either: the field marks itself privacy-sensitive
  (`PeekableSecretField.swift:56`), but nothing in that arm turns the mark on.
- Inside `.ready`, the look and the join moment are covered, because the environment reaches sheets.

**Screenshots.** iOS gives an app no way to block one. A screenshot of the card would land in Photos. The rules are
silent, and no sentence mentions screenshots.

**The typed fields.** They are secure by default. Revealed, they become plain fields with autocorrection and
autocapitalization off (`PeekableSecretField.swift:77-86`; `MobileProtectionDoors.swift:98-102`). So the keyboard
should not learn the words *(inference, Apple)*.

**Joining on the phone.**
- It asks for *"Your account's passphrase"* or *"Or your account's twelve words"*, never both (PW:870-871).
- The lead is PW:854-855, and the posture line is PW:857-868. Into Castle, Use Castle's sentences and the gate choice
  are added (`RoadAccountFaces.swift:405-408`). The wrong-secret refusal names the account (PW:428-429).
- The words moment is shown if words were typed (PW:729-730, hers), and said if the passphrase was typed (PW:893-897).

**Rules 6 and 14 hold.** The passphrase floor is 12 characters, with a quiet hint (`MobilePassphraseHintLine`).

### e. Sync keys and the account (rules 14–16)

**What the phone holds** (`KeychainSyncKeysLeaf.swift`):
- **Standard:** a silent item, device-only, `WhenUnlockedThisDeviceOnly` (`:98-104`).
- **Castle with Face ID:** a `.biometryCurrentSet` item (`:105-117`), plus session memory.
- **Castle with Always ask:** session memory only (`:125-135`; `CommonSteps.swift:372-376`), gone at a lock, a
  sign-out, a crash or a quit.

The engine reads session memory first, then the silent item, and never the Face ID item (`NewRoadSyncKeyProvider.swift:
43-57`).

**What "Sync locked — this iPhone hasn't unlocked your account's sync keys" means** (`SyncStatusViews.swift:772`). The
provider found no keys for the bound account: none in session and no silent item. Typical causes:
- a Face ID unlock whose ride on the sync-keys item failed;
- a typed unlock made offline, where VX-544 retries before each round;
- an item that never came over. An iPhone restored to new hardware is the likely case, since device-only items don't
  migrate *(inference)*.

Inside Settings the row has no door of its own (VM-27).

**Leaving.** *Stop syncing here*, *Use this iPhone only* and *Delete the account from this iPhone* change no key or
secret (rule 16). They forget the account's sync keys by name (VX-517), and each writes a backup pair
(`AccountActs.swift:63`). Sign out changes nothing in the record.

### f. Copies (rules 17–19, 21, 27)

**No back road.** The phone has no `UIFileSharingEnabled`, no `LSSupportsOpeningDocumentsInPlace`, no document types, no
`onOpenURL` and no `fileImporter` or `fileExporter` (the build settings; grep). Its entitlements carry only the two
keychain groups (`App/Variorum/VariorumMobile.entitlements`). The only copy roads off the phone are iOS's own device
backup and migration.

**When the library in the live place is not the one it last opened.** The phone says rule 21's notice, worded for a
Mac (finding 9). In practice the notice should almost never fire on a phone:
- A restore onto the same iPhone restores the memory item along with the files, so memory and library agree.
- A new iPhone has no memory item, and the rule says nothing then (`LibraryNotice.swift:79-83`).
- Both readings are *(inference, Apple)*.

**When it won't open.**
- rule 27's lobby, with *Start a New Library* and the account sentence;
- the library-missing face, with *Start a New Library* only;
- the pre-design face, with *Start fresh*;
- the interlude's key-file offer, which can draw on the phone's own act pairs.

### g. Crash safety (rules 20, 22)

**The acts the phone can run:** Use Castle, Replace All Keys, the follow (into Castle, keys replaced, the pair
catch-up), set-up, join, Move, the three leaves, Change and Reset passphrase, New words, Set a passphrase, the gate
changes, the offer's *Use it*, and the Face ID re-arm.

**The machinery is shared.** Every one of those acts runs on the shared executor and plan runner, with the plan
excluded from backups. The settle runs at **every** open on the phone, quiet roads included (`ProtectionOpenRoad.swift:
373` → `open` → `:1059-1070`).

**What the phone says afterwards.** A settled follow says its Done durably, in Settings ▸ Protection only. Every other
settled or rolled-back act says nothing (finding 10).

**Why the phone needs this more.** iOS suspends and kills backgrounded apps more readily (MobileSoul §5.1). An act whose
re-encryption or vault leg outlasts the background grant can be killed mid-plan. The lock waits for the act
(`AppBootstrap.swift:1503-1514`), so a lock cannot cut the act short.

### h. `#if DEBUG` on the phone's protection road

Only these are behind `#if DEBUG`:
- the guard off-switches;
- the test-host KDF floor;
- the walk machinery, armed by launch environment variables. These are unreachable in normal use (§1 rule 24).

Also outside Release:
- the pocket guide's door, Debug-only (`MobileSettingsView.swift:182-184, 409+`), so its stale privacy chapter never
  reaches a Release user;
- `ProtectionRoad.isDebugBuild` feeds a switch that answers `true` in both configurations
  (`ProtectionRoad.swift:43`).

Note: Debug and Release share one bundle ID, so they share the app's keychain group. The dev scope keeps them apart
(D-72).

---

## 3. Every sentence the phone shows about protection

Marks: **T** true as written · **U** untrue on the phone · **M** worded for a Mac · **D** draft or legacy ·
**T\*** true, but names a place or door the phone does not have or show.

| Face | Sentence (abridged) | Where | Mark | Rule |
|---|---|---|---|---|
| Creation card | "Your library is encrypted. These twelve words open it — on this iPhone, on any copy of it… Variorum won't show them again." | PW:24-26; `MobileRoadFaces.swift:243` | T (but the face itself breaks rule 2's timing) | 2 |
| Creation card | "You can add a passphrase later… Either one can reset the other." | PW:27-28 | T\* (no later ask exists) | 3 |
| Lobby | "Open your library" / "Enter your passphrase or your twelve words…" / its variants | PW:400-409 | T | 2, 3 |
| Lobby | "Variorum couldn't check this iPhone's keychain just now…" | PW:418-419 | T | 8 |
| Lobby | "Your account's passphrase hasn't been typed on this iPhone yet — type it here…" | PW:449-450 | T | 3 |
| Lobby | "…Your account's current passphrase, the one before it, or your twelve words open it." | PW:440-445 | U after two changes in a row (VX-543) | 7 |
| Lobby | "Unlock with Face ID" · "Face ID isn't set up…" · "Face ID changed since you set it up — unlock with the passphrase." · lockout | PW:469-483 | T ("with the passphrase" is wrong for a library with no passphrase lock) | 9 |
| Lobby (rule 27) | "No key file opens this library. Variorum looked beside the library, inside every backup, and in this iPhone's keychain…" | PW:59-61 | T (it does search the act pairs) | 27 |
| Lobby (rule 27) | "This library syncs with your account. Sign in and enter your passphrase or twelve words to bring your writing back." | PW:68-69 | T | 27 |
| Lobby / missing face | "A new library starts empty and has its own key." · "Your library file is missing." · "Variorum's library isn't where it was. Your lock hasn't changed." | `ProtectionCopy.swift:64-71` | T / D ("your lock" is pre-design wording) | 27 |
| Pre-design face | her lead, body and confirm ("…sets this library aside, whole, in Previous Libraries.") | PW:78-89 | T\* (Previous Libraries are invisible on the phone) | 26 |
| Interlude | "This is a different library than the one this Mac last had open" · "This is an older copy of your library, from ‹date›" | `LibraryNotice.swift:46-47` | **M** | 21 |
| Interlude | "The key file beside your library doesn't open it. This Mac's keychain holds a copy that does. Use it?" | `KeyFileOffer.swift:40-41` | **M** | 21 |
| Interlude | "…The backup from ‹date› holds a key file that does. Use it?" · "There is no key file beside your library. A backup holds one…" | `KeyFileOffer.swift:42`; PW:50 | T (true of the act pairs, which the phone never names) | 21 |
| Interlude | "Face ID can't open Variorum on this iPhone any more. Set it up again?" | PW:650-655 | T | 9 |
| Receipts | "Key file restored from this iPhone's keychain." · "The key file beside your library was missing. This iPhone's sealed copy was put back." | PW:39, PW:99-100 | T (shown only on the Protection screen) | 1, 21 |
| Rule-27 sheet | "Variorum opened your library, but found no key file for it anywhere. **Make a backup now, so a copy exists.**" | PW:66-67; `MobileRoadFaces.swift:369` | **U** (no backup door; the real road is the words door, unnamed) | 27, 1 |
| Protection ▸ passphrase | "A passphrase is a convenience over your twelve words…" · "Passphrase set. Your twelve words still open the library too." · the floor and hints | PW:110-126; `ProtectionCopy.swift:50` | T | 3 |
| Key doors | "Every copy of this library opens with your current passphrase or words; on this iPhone, its quiet road opens it too, if it still holds that copy's key." | PW:1128-1129 | T for the app's copies; for an iPhone device backup restored whole, only the secrets of its day are sure to open it *(inference)* | 4–6 |
| Key doors | "This library syncs with your account, so your account's passphrase changes with it, on every device." · "This iPhone holds your library's key, so you can choose a new passphrase without the old one." · Castle's reset leads | PW:1132-1152 | T | 6, 7, 8 |
| Words section | "Variorum doesn't keep your twelve words, so looking makes new ones… Your library's key doesn't change." · "…new words also replace your account's twelve words, on every device." | PW:706-707, PW:1166-1167 | T | 2, 6, 7 |
| Words look | "Write these down now. They open your library — on this iPhone and on any copy of it…" · "These words won't be shown again." | PW:683-684, PW:696 | T | 2 |
| Words look | "Your library's key doesn't change: every backup opens with these words, and still with the words you had when you made it." | PW:686-687 | T for the app's pairs; an iPhone device backup restored whole knows only its own day's words *(inference)* | 4–6 |
| Check | "Type your passphrase or your twelve words to check them. Checking changes nothing." and the four answers | PW:1078-1113 | T | — |
| Crossings | "You're in Standard." / "You're in Castle." (Castle: with no door under it) | PW:528-533 | T | 12 |
| Use Castle | "Castle is one promise: no quiet road through Apple, ever, on any device of the account." | PW:536 | T (hers) | 9 |
| Use Castle / join into Castle | "Your library gets a new key, and the Apple and on-device keychain items are deleted — the Apple ones on every device of your Apple account — **so your backups are Castle-protected along with your library.**" | PW:538-539 | **U** for the iPhone's device backups (§2b) | 11, 13, 25 |
| Use Castle / join into Castle | "The libraries in Previous Libraries keep their own quiet roads on this iPhone — Castle protects the library you have open." | PW:544-545 | T\* | 11, 19 |
| Use Castle | "From now on your passphrase, your twelve words, or Face ID on this iPhone open your library. Lose all three and it is gone." | PW:547-548 | T | 9, 27 |
| Use Castle | "These backups are locked under an Apple account this iPhone no longer uses…" (with the copies named) | PW:553-554 | T (the phone's act pairs) | 25 |
| Use Castle | "This library has no passphrase yet. Choose one — Castle needs it." | PW:586 | T | 3, 11 |
| Gate | "On this iPhone" · "This iPhone keeps the new key behind Face ID." · "No copy of the key stays on this iPhone; you type every time." · the gate row's two lines | PW:562-570, PW:640-642 | T | 9 |
| Replace All Keys | "…Every earlier key stays in its history, so your backups still open. Your account's sync key stays as it is." | PW:579-580 | T | 4, 15 |
| Receipts | "You're in Castle now." · "Your library has a new key…" | PW:628-630 | T | 11 |
| Follow owed | "Your account changed on another device. Follow it first." | PW:624 | **U** when the owed follow is *out* of Castle (no door) | 10, 12 |
| Account | "This library doesn't sync." / "…syncs with your account." / signed-out and other-account lines | PW:735-748 | T | 16 |
| Turn on sync | "Your library's passphrase and twelve words become the account's. Nothing is replaced." · "A device holds one pair of secrets at a time." · the posture line · the new-passphrase lead | PW:772-781, PW:727 | T | 7, 14 |
| Join | the lead, the posture line, "…here they are; the old ones still open backups made with them." (hers), and the not-shown variant | PW:854-868, PW:729-730, PW:893-897 | T | 7, 14 |
| Follow | the notice, "Until this iPhone follows, it can still read what it already has…", the ask, the Done | PW:916-1002, PW:967 | T | 10, 15 |
| Follow (pair kind) | "You can also set this library aside and re-join your account: a fresh library fills from sync…" | PW:954-955 | **U** (the phone has no set-aside door outside rule 27's face) | 7 |
| Follow (pair kind) | "Until you type your account's passphrase on this iPhone, copies made here open with your twelve words." | PW:961-962 | T (the copies are the act pairs) | 3, 7 |
| Leaves | rule 16's two sentences (hers) · the leads for stopping sync, deleting here and this iPhone only, and the pointer to "Account… in Settings' sync row" | PW:722-725, PW:787-812 | T | 16 |
| Signed-out Castle | "Castle will apply to this library on this iPhone only…" | PW:833-838 | T | 11, 16 |
| First round | "…Settings says when it's done." | PW:1045 | T | — |
| Sign out | "…Your library and its keys stay on this iPhone… **To give this iPhone away, delete the library too.**" | `ProtectionCopy.swift:112-117`; `MobileProtectionScreen.swift:654` | **U** (no phone door deletes the library; deleting the app leaves keychain items, *Apple*) | 16, 23 |
| Delete account | "Your account, its sync copy on our server, and its keys are deleted. Nothing on this iPhone… is touched…" | `ProtectionCopy.swift:132-136` | T | 16 |
| Sync row | "Sync locked — this iPhone hasn't unlocked your account's sync keys" · "Sync isn't on for this library yet" · "Sync paused — this account's encryption keys were replaced" | `SyncStatusViews.swift:772-788` | T (the last neither names Castle nor reaches the follow) | 10, 15 |
| Capture box, locked | "Your library is locked, so this note can't be saved yet. Your text is still here — unlock the library and it will save." | `MobileQuickNote.swift:158-159` | T | — |
| System prompt | "Unlock your Variorum library" (the Face ID usage string and the press reason) | pbxproj:945/981; `KeychainCustodyLeaf.swift:39` | T | 9 |
| Pocket guide (Debug only) | "Standard is the default. Your Apple account holds a key. Keep: your Apple account, and — if you use sync — your passphrase and twelve words…" | `ProtectionCopy.swift:220-228` | D (old road; contradicts rules 2–3) | 2, 3 |
| Not rendered on the phone | "Switching to another app doesn't lock it; time away does. Variorum always locks when your iPhone sleeps or its screen locks." · the keystone line · the leave sentence ("…this Mac again…") | `ProtectionCopy.swift:256-258, 183-185`; PW:573-574 | idle line U today if rendered; keystone T; leave line M (held) | 9, 12 |

---

## 4. Ranked findings

These lead with what the app says, or implies, that it does not give.

1. **WORDS / TRACED-RISK. Rules 11, 13, 25.** The phone's Use Castle and join-into-Castle confirm says
   *"…so your backups are Castle-protected along with your library"* (PW:538-539).
   - *Scenario:* she enters Castle on her iPhone, then later restores it from last month's iCloud backup. The restored
     library opens with no Face ID and no passphrase, through the restored device-only item.
   - *Traced:* nothing is excluded from backup but the plan (`FilePlanStoreLeaf.swift:38-40`).
   - *Apple's side:* whether the item comes back on the same device (§6).
   - *Covered by:* VM-15 (the act, her call) and VM-110. W-208's premise, "your backups on a phone that keeps none", is
     wrong both ways (finding 7).
   - *Fix shape:* the phone's confirm says plainly what an iPhone backup made before today can still open. VM-15's
     exclusion, at her call, is the act-level alternative.

2. **TRACED-GAP. Rule 10, "every device follows… said plainly".** After another device enters Castle, the phone keeps
   opening quietly and writing unsynced.
   - *Where it says so:* a Settings row that names "keys replaced", whose door leads to the Account sheet
     (`SyncStatusViews.swift:212-228`), and the follow door deep in Protection.
   - *Scenario:* she trusts "Castle is account-wide", and her phone opens without Face ID for weeks while its writing
     never reaches the Mac.
   - *Covered by:* VM-111 (the door) and VM-201 (sync status outside Settings) in part. Neither names an owed follow.
   - *Fix shape:* a card above the capture box (VM-23's home) or VM-201's status line, saying the account moved, with
     the follow door.

3. **TRACED-GAP, with WORDS. Rule 12.** Use Standard, the follow out, and a join or Move that leaves Castle are
   unrendered (`MobileProtectionDoors.swift:540, 557`; `MobileProtectionScreen.swift:192-203, 217-218`).
   - When the account leaves Castle elsewhere, the phone says *"Follow it first."* and has no door to do it.
   - A phone-only Castle user can never leave.
   - *Covered by:* VM-109 (LP-7 ruled that leaving must work on the phone).

4. **TRACED-GAP. Rule 2, plus the switcher.**
   - The creation card comes before the first screen (`AppBootstrap.swift:517-522`), with no warning step before it
     closes.
   - It is drawn outside the snapshot redaction (`VariorumMobileApp.swift:76-87, 216-218`). It shows again at every
     *Start a New Library* and *Start fresh*.
   - *Covered by:* VM-23 and VM-108. VM-108 should widen to every arm (finding 13).

5. **TRACED-GAP. Rule 3.** A library born on the phone is never asked for a passphrase.
   - There is no reminder, no "after a quiet road failed" moment and no E6 card. The Shared models exist without a
     phone face.
   - The creation card's foot promises "You can add a passphrase later".
   - *Covered by:* VM-200 and VM-23.

6. **TRACED-RISK. The lock and the "time away" stamp wait behind the network round.**
   - The lock runs after `performBackgroundFlush` (`MobileShellRouter.swift:419-430`), and `awaitIdle` ignores
     cancellation (`SyncScheduler.swift:193-196`).
   - A long round, such as a first catch-up or VX-672's minutes-long rounds, outlasts the grant. The app is suspended
     with the Castle library open, and the lock lands after she returns, possibly while she is using the app.
   - Under VM-105's new design, `leftAt` would be stamped late in the same way, so the dial would measure from the
     wrong moment.
   - *Covered by:* nothing names the mechanism. VM-105 should own it.
   - *Fix shape:* stamp the leaving moment (and today, decide the lock) at the phase edge, and make the leaving round
     cancellable.

7. **TRACED-GAP, new. Rules 1, 5 and 19 against canon.**
   - The phone writes a full backup pair at every key and account act (`CommonSteps.swift:257-260`). None is pruned:
     retention runs only from the hook, which the phone never starts. None is listed or deletable. All of them ride the
     device backup.
   - Canon and code comments say "the phone keeps no backups" (`MobileRoadFaces.swift:13-14`; the vm-8 record's line
     166; the exemption text at `MobileStructuralTests.swift:1121`).
   - These pairs are encrypted, and entry sweeps their locks correctly, so this is not a hole. But the phone's whole
     backup vocabulary rests on the false premise.
   - *Covered by:* unticketed.
   - *Fix shape:* correct the premise in canon and in the VM-110 brief, and give the phone's pairs the Mac's retention
     rule. This is an act, not a rule change.

8. **WORDS. Rules 27, 1 and 7: sentences that name doors the phone lacks.**
   - The rule-27 sheet says *"Make a backup now, so a copy exists."* with OK only (`MobileRoadFaces.swift:359-387`).
     The phone's real road, recording new words and so writing a fresh key file and a pair, sits in Protection and is
     unnamed.
   - The pair catch-up's *"set this library aside and re-join"* (PW:954-955) has no phone door.
   - *Covered by:* unticketed. VM-110 could absorb them.

9. **WORDS (M). Rule 21.** *"…the one this Mac last had open"* and *"This Mac's keychain holds a copy that does."*
   (`LibraryNotice.swift:46-47`; `KeyFileOffer.swift:41`).
   - *Covered by:* W-199 → VM-110 (F-PH-1, her wording).

10. **TRACED-GAP, shared with the Mac. Rule 20, "says which".**
    - A settle that finishes or rolls back any act except a follow is only logged (`ProtectionOpenRoad.swift:1064,
      1142`). Meanwhile the act's own sheet promised *"It finishes the next time your library opens."* (PW:822-823).
    - On the phone iOS kills acts more often, and even the follow's Done waits in Settings ▸ Protection.
    - *Covered by:* VX-452, for the join only.
    - *Fix shape:* one receipt per settled act, through VM-229's message line.

11. **WORDS. Rules 16 and 23.** Sign out says *"To give this iPhone away, delete the library too."*
    (`ProtectionCopy.swift:116-117`). No phone door deletes the library, and deleting the app leaves keychain items
    behind *(Apple)*.
    - *Covered by:* unticketed. VM-110 could take it.
    - *Fix shape:* name the iPhone's real road (erase the iPhone), in her words.

12. **TRACED-GAP. Rule 19.** Previous Libraries on the phone, from *Start fresh* or rule 27's *Start a New Library*, are
    never listed or deletable. They keep their quiet roads and ride device backups. Use Castle points at them by name.
    - *Covered by:* W-207 / SC-4 (after v1, her ruling).

13. **TRACED-RISK. The switcher arms.** Only `.ready` is redacted (`VariorumMobileApp.swift:76-87`). A revealed
    passphrase or words field in the lobby, the creation card and the interlude are uncovered.
    - *Covered by:* VM-108, which names only the card.
    - *Fix shape:* move the redaction to the window group's root.

14. **TRACED, low. Memory across a lock.** The first `AppSession`, with its undo stack and drafts, lives on through every
    lock, held by the capture box (`MobileQuickNote.swift:289, 345-346`). Its contents may include note text
    *(inference)*. Decision 19 puts the open-app attacker out of scope.
    - *Covered by:* VM-107 (add the memory angle).

15. **WORDS, low. Rules 4–6.** *"Every copy… opens with your current passphrase or words"* (PW:1128) and *"every backup
    opens with these words"* (PW:686) are true for the app's own copies. An iPhone device backup restored whole replaces
    today's key file, so only its own day's secrets are sure to open it *(inference)*.
    - *Covered by:* VM-110.

---

## 5. What the lock umbrella (VM-103) should prove before it changes anything

**Prove first, on a device or with pins.**
1. **VM-104's probe**, as planned. Also prove that the side-button lock and an app switch are indistinguishable at
   `.background` today. That fact is what the current behaviour stands on.
2. **The leaving timing (finding 6).** A pin, or a walk on a device: a leaving whose sync round outlasts the background
   grant still records its moment at the phase edge, and the lock decision does not wait on `awaitIdle`. This should
   come before VM-105 builds the dial on `leftAt`.
3. **A baseline of the switcher image for every arm**: `.ready`, the creation card, the lobby with a revealed field,
   the interlude. This settles VM-108's scope (finding 13). It is LP-3-consistent: her ruling keeps the page, not the
   secrets.
4. **A memory graph after a lock** (Instruments): no live `ProtectionRoadSession`, `UnlockedLibrary` or second
   `AppSession` with text-bearing state. This settles VM-107's memory side (finding 14).
5. **VM-15's Apple facts, as a throwaway-library drill:**
   - a Standard library → an encrypted Finder backup → follow into Castle;
   - restore to the same device: does it open quietly?
   - restore to a second device: is the Apple road dead?
   This settles §2b's open half before her call, and before VM-110 words the backups sentence.
6. **For VM-109: a two-device walk on test accounts.** Leave Castle on the Mac and watch the phone's follow out land
   *quietly, with a notice* (rule 12). Leave Castle on the phone and check that the leave sentence is said for an
   iPhone.

**Already owned by VM-103's members.**

| Finding | Member |
|---|---|
| 3 (rule 12) | VM-109 |
| 4, part (switcher card) | VM-108 |
| 6 (the dial and stamp) | VM-105, VM-25; the mechanism needs adding to the brief |
| 9 | VM-110 |
| 13 | VM-108, once widened |
| 14 | VM-107, with the memory angle added |
| 1 (act half) | VM-15 |
| 1 (words half) | VM-110, with W-208's premise corrected |
| 15 | VM-110 |
| 2, part | VM-111 |

**Owned elsewhere.** Findings 4 and 5 sit in umbrella 19 (VM-23, VM-200). Finding 12 is W-207 / SC-4, after v1.

**Need a ticket (none found in `notes/TICKETS.md`):**
- **Finding 7:** the phone's act pairs. Retention, the premise in canon, a home in the words.
- **Finding 2's core:** a phone-visible "your account moved — follow it" card or status line. VM-201 may absorb it if
  its "card when there's something to do" explicitly includes an owed follow.
- **Findings 8 and 11:** three sentences naming doors the phone lacks. This could be one Wording ticket under VM-110.
- **Finding 10:** "says which" for every settled act, on both platforms. Either widen VX-452 or file a sibling.
- **The leaving-timing mechanism (finding 6),** if VM-105's body doesn't already say it. Checking that needs Linear.

---

## 6. What I could not determine, and the one check for each

| Question | What settles it |
|---|---|
| Whether iCloud and encrypted Finder backups carry `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` items and restore them **only to the same device** (§2b case ii) | Apple Platform Security guide, "Keychain data protection" and "iCloud Backup security". Then the same-device restore drill in §5.5. |
| Whether device backups carry **synchronizable** keychain items themselves, which would let a pre-follow backup keep a live Apple-road lock after the follow deleted it from iCloud Keychain | The same Apple guide (the iCloud Keychain section), or the second-device leg of the drill. |
| Whether a `.biometryCurrentSet` item restored to the same iPhone after an erase still opens. Re-enrolling Face ID should invalidate it. | One step of the same device drill. |
| How long iOS lets a backgrounded app run, and whether a suspended app wakes to finish the lock (finding 6) | A device walk with a deliberately long round, as in VX-672. |
| Whether iOS keeps the app's keychain items after the app is deleted. This bears on the sign-out sentence, finding 11. | Apple's documentation, or one delete-and-reinstall on a test device. |
| Whether an iPhone migrated to new hardware can get its sync keys back in Standard. It opens quietly through the Apple road, but its device-only sync-keys item is gone, and inside Settings the row has no door (VM-27). | A migration drill with a test account. Or a scenario test: a synced Standard library whose silent sync-keys item is missing, on the phone's composition. |
| Whether two live devices sharing one library ID cause trouble: an old iPhone kept plus a new one restored from its backup. They would have the same key and different device IDs *(inference)*. | Two-device sync on test accounts after a restore-to-new-device. |
| Whether rule 21's notice ever fires on a phone after a same-device restore, since the memory item may be restored too | The same-device restore drill (§5.5). |
| Whether anything else retains the road session or its key after a lock | The memory graph (§5.4). |
| What VM-104 through VM-111's ticket bodies already say. Only their titles were read; Linear was not read. | Reading the tickets on Linear. |
