# The Castle rebuild's delta for the stargazing.tech agent — hand over at the release switch, not before

**REWRITTEN 2026-10-22 at VX-329 (F-U2-4) to `notes/CastleRules.md` — the contract that superseded the VX-266
design this brief was first written against.** The superseded facts are gone from this text: the Castle anchor, the
salted hardware hash, the per-copy *Opens with* route lines, Re-link as a repair act, the old shared key and every
transitional old-build note (rule 26 ended migration). This is a delta to the two current briefs:
`notes/stargazing-privacy-policy-brief-2026-10-04.md` and `notes/stargazing-help-faq-brief-2026-10-04.md`. **Those
briefs stay true until the release that carries VX-329's switch**, because every Release build runs today's
protection code until then. The author hands this delta to the site agent with that release, after the VX-329 window
re-checks each fact against the shipped build. As with the current briefs, the site agent writes the copy and this
brief carries facts only.

The register stays the current briefs' one. Everyday answers name no key. The FAQ may say "the twelve words", "your
Apple account" and "iCloud Keychain", and never "box".

## The one sentence (the rules' own)

Your writing is encrypted. Your passphrase or your twelve words — together with any copy of your library — always
open it. Everything else is a convenience.

## The model, as it becomes

Both modes stay end-to-end encrypted, and the server still never holds a key to anything. The shape:

- **Every library is encrypted with its own random key.** The key lives in a small key file beside the library, and
  the app keeps copies of it without asking: beside the library, inside every backup, and a sealed copy in the Mac's
  keychain. The key file is non-secret — holding it opens nothing without a secret.
- **Every library has twelve words from the moment it is created, and is asked for a passphrase.** Either one opens
  it; either can reset the other. Nothing ever stores the words.
- **Standard is a convenience posture.** Besides your secrets, the app may keep quiet roads to the key: an Apple road
  (iCloud Keychain, through your Apple account — which also reaches your other Macs on that account) and an on-device
  road (this Mac's login keychain: your login password or Touch ID). The plain truth belongs in the policy: in
  Standard, anyone who can sign in to the Mac can open the library. If an Apple road stops working, the next open
  quietly makes a fresh one from whatever road still works, and asks for a secret only when none remains.
- **Castle is one promise: no quiet road through Apple, ever, on any device of the account.** Touch ID on the Mac is
  optional; "Always ask" keeps no copy of the key on the device at all. In Castle, the key isn't on the Mac in any
  form the login password can release.
- **One posture at a time.** Entering Castle takes everything in; leaving hands everything out. The app never keeps a
  protection you chose to leave, and never leaves a hole you chose to close.

## FAQ entries whose facts change

- **"I switched to Castle. Are my old backups protected?"** The answer is **yes**. Entering Castle makes a new
  library key, deletes the library's Apple and on-device keychain items — and an Apple item's deletion reaches every
  device on the Apple account, so your Standard-era backups' quiet locks die with it. From then on they open only
  with your passphrase or twelve words, like the live library. Two stated exceptions, neither a road to your current
  writing (rule 25): a Standard-era backup locked under an Apple account you have since left keeps that lock (the app
  cannot delete another account's keychain item), and a key file someone kept outside Variorum's own folders still
  opens the backups from before you entered. Time Machine copies of Variorum's backups follow the same rule — their
  quiet locks died with the deleted key.
- **"I'm entering Castle — anything I should know?"** Entering types your passphrase AND your twelve words, and turns
  the scheduled plain-text export off with one notice you may reverse (a plain copy on disk would undo the promise;
  it's your call). Castle is account-wide: when one device enters, every device of the account follows, each typing a
  secret once; until a device follows, it can still read its own local copy through its own quiet road — accepted and
  said plainly.
- **"I moved to Castle, lost my passphrase and twelve words."** Nothing opens the library any more — that is the
  promise working. The doors warn before anything is lost, and the words are shown and asked to be written down from
  the first day.
- **"Someone has my old backups and my Apple account — and I've since moved to Castle."** They **can't open** those
  backups, apart from rule 25's two exceptions above.
- **"I left Castle. Who can open what now?"** Leaving types both secrets and hands everything to Standard: a new key
  carrying every earlier one, a fresh Apple road, the on-device road back. Your text, the server's rows, the sync key
  and **every backup you have ever made** open through your Apple account and this Mac again. The leave screen says
  so plainly: if you want Castle-era writing to stay Castle-protected, don't leave.
- **"Restoring a backup."** A backup is the library plus its key file. It opens with the passphrase and words you had
  when you made it; your current secrets open older backups of the same library (every key change carries the earlier
  keys forward — no exceptions); or this Mac's quiet road opens it while that road still holds the backup's key.
  Restore from Backup is the *Make this my library* door: the copy becomes a **new library** — a fresh identity and a
  fresh key, in the posture you are in now, under your current passphrase and words — and your previous library steps
  aside whole into Previous Libraries. A restored copy of a synced library joins the account by its rows, like any
  device. A backup carries **no sync key and no device identity**, so a Mac new to a library enrolls.
- **"Changing my passphrase / making new words."** Either re-locks the current key; it does not change the key. Older
  backups still open with your new secrets; older keys still open through the carried list. The doors say so in one
  sentence. On a synced library the account's lock changes in the same act.
- **"Moving to a new Mac" / Send Library.** Two devices share a library through sync, never through files. An
  AirDropped or hand-carried copy is a copy: it becomes its own library on arrival (a fresh key under the secrets
  typed at the landing) and may diverge — unless both devices sign into the same account, in which case the restored
  copy merges by its rows exactly as any device does. Nothing is shared between the Macs by the file itself.
- **"I reset my iCloud Keychain" / "my Apple road stopped working."** Not an event any more: the next open uses
  whatever quiet road still works and quietly makes a fresh Apple road; it asks for your passphrase or words only
  when no quiet road remains. Either way nothing was ever at risk. (The old Re-link door is gone.)
- **"Someone was inside my Apple account, and I'm in Standard."** Replace All Keys makes a new library key carrying
  the old ones; Castle is the stronger answer — it is exactly the posture with no Apple road at all.
- **"Does Castle on my Mac make my iPhone Castle?"** It stands: Castle is account-wide; each device follows by typing
  the passphrase or the words once.
- **"I stopped syncing a library" / "I signed out."** Leaving an account changes none of your library's keys or
  secrets — it stops syncing, and the server keeps what you pushed (removing it is the account-deletion road).
  Signing back in is a join.
- **"What if every copy is gone?"** A library whose every key-file copy and every backup are gone is gone. Synced
  libraries are the exception: the account's passphrase or twelve words recover them from the account.

**New entries the site may want:**
- **Joining an account from a new device.** The account's shared keys are wrapped by the passphrase and the twelve
  words only — never by Apple — so joining always types one of them. A device holds one pair of secrets at a time:
  the first device to turn on sync hands its library's pair up to become the account's; a device that joins later
  adopts the account's pair and is told plainly — the old words still open backups made before that day.
- **Reading old writing years later.** Each row on the server is sealed under the sync key that was current when it
  was written, and the account keeps every sync key it has ever had — so a device joining years later reads
  everything. The sync key changes only when the account enters Castle.
- **Copies made by versions before this release.** The new system doesn't open libraries from before its design
  (there is no migration; the few people concerned were told and export or sync first, then start fresh). An old copy
  stays readable by the old app version that made it.

## Privacy-policy facts that change

- **Tier 1, key custody.**
  - Standard: the Apple account holds quiet keys for the library on each Mac (iCloud Keychain items), and the Mac's
    login keychain holds an on-device one. They are Apple's roads, never ours. **The sync account's keys are never
    Apple-wrapped**: the account's shared keys are wrapped by the passphrase and the twelve words only, so joining a
    device always types a secret. (The old "one Apple key for the sync account" fact is gone.)
  - Castle: entering it deletes the library's Apple and on-device keychain items — the Apple deletion reaching every
    device on the Apple account — and no copy Variorum made opens through the Apple account, apart from rule 25's two
    stated exceptions (a backup locked under a departed Apple account; a key file kept outside the app's folders).
- **Tier 2, what a copy of the library file carries.** A backup is the library plus its key file. **No sync key and
  no device identity** — a restored copy enrolls as a new device. The key file carries the key history (every earlier
  key, each sealed under the current one) and is non-secret: holding it opens nothing without a secret. Device
  identity, where the library's own record names devices, is a **plain random ID made at creation — no hardware
  fingerprinting, no salted hardware hash.** (The old "salted hash of its hardware" fact is gone.)
- **Tier 2, Standard's login-password truth.** It belongs in the policy plainly: in Standard, anyone who can sign in
  to the Mac can open the library through the Mac's keychain. In Castle, the key isn't on the Mac in any form the
  login password can release ("Always ask" keeps no copy on the device at all).
- **Tier 3, what the operator sees.** The account's key record shows its posture (standard or castle) and its wrapped
  key copies — master wrapped by passphrase and by the twelve words, the corpus keys sealed under the master, and the
  count of earlier sync keys the account carries. The operator opens none of them: nothing in the record is
  Apple-wrapped and nothing opens without a typed secret.
- **Deleting the account: what outlives it** *(added 2026-10-20 for VX-213, from the VX-191 audit's account-deletion
  check, C3 — not a Castle change: true today and stays true; the facts below re-checked 2026-10-22 at VX-329 against
  Supabase's documentation and empirically on the rehearsal project)*. Deleting the account deletes everything
  Variorum keeps for it on the server: the library's encrypted copy, the account's key record, its sync bookkeeping,
  and the login itself. What it can't delete is the sign-in service's own log. Variorum's sign-in runs on Supabase,
  whose auth service records sign-in events (the event, a timestamp, and the account's email; Supabase's docs also
  name the IP address, though community reports say the IP lands per-session rather than per-event). The checked
  facts: by default those records live in Supabase's own log platform, NOT in the project's database — the project's
  optional audit-log table is empty unless its toggle is turned on (verified empty on the rehearsal project after
  many sign-ins), and the deletion road removes the login and its sessions while the platform's logs are outside any
  project table. Supabase documents NO retention period for the auth audit log itself; its log platform's retention
  is plan-based. So the policy should say that deleting the account doesn't erase the sign-in service's own records
  of past sign-ins, that they are kept under Supabase's retention (not Variorum's), and it should give a NUMBER only
  from Supabase's current platform-logs documentation for the project's plan at the time the page is written — not
  from this brief.
- **Cautions, added.**
  - Don't say backups made in Standard stay openable through the Apple account after entering Castle. They don't,
    apart from rule 25's two stated exceptions.
  - Don't say a library sent to another Mac shares its keys. It doesn't — a copy becomes its own library, and only
    sync shares.
  - Don't say deleting the account erases every record of it. The sign-in service's own log of past sign-ins stays.
  - Don't promise Apple's roads keep working across Apple ID changes, iCloud sign-outs, keychain resets or a move to
    a new Mac. The promise is that you never *need* them.
