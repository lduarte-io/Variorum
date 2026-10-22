//
//  DataSafetyCopy.swift
//  Variorum (MAC ONLY — deliberately not in Shared/)
//
//  Phase 13l, Act 4 (ledger row 13) — the RUNBOOK, and the three sentences
//  from it that the app itself has to say.
//
//  WHY THE TEXT LIVES IN CODE. The runbook's authored home is
//  `notes/DataSafetyRunbook.md` (the plan's own PROVISIONAL call), and a
//  test pins the two byte-equal, so there is one text and two places to
//  read it. Shipping it in code buys the thing the repo file cannot: the
//  app writes `RESTORE.md` INTO the backup folders on every run, so the
//  recipe sits beside the copies it is about. That matters because of WHEN
//  it gets read — the moment you need a restore recipe is the moment the
//  app may not open, and a document that only exists inside the broken app
//  is not a runbook.
//
//  WHY IT IS NOT IN `Shared/`, having started there: this is a FACE, not a
//  brain (MobileSoul §3's line), and every sentence in it names the Mac —
//  the container path, the Finder steps, File ▸ New Window. The mobile
//  no-redirect sweep caught it within the hour, correctly: `Shared/` means
//  BOTH platforms compile it, and a phone that imported this would speak
//  about a machine it is not running on. The runbook text reaches the
//  backup writer as a parameter instead (`StoreBackup.Configuration`), so
//  the machinery stays shared and the words stay the Mac's.
//
//  pre-13x batch 5b, item 2 — REWRITTEN PER POSTURE (Standard and Castle):
//  §1 what protects the writing, by who holds a key; §2 the snapshot PAIRS
//  (each copy's own key file beside it) and the iCloud Drive offer; §3 + §6
//  the pair in the recipe and which credential opens which copy; §7 the
//  lost-device road (Sign Out Everywhere → Replace All Keys → the account
//  password; Standard's trade; the Apple-account intruder — decision 30;
//  the compromise rule's four lines); §8 the forgot roads by posture with
//  the floors still COMPOSED from the posture cards (the 5a pin). Facts
//  ONLY from `notes/plans/pre-13x-postures-design.md` §1–§7; the in-app
//  open-a-copy door (13x) and a remaining-rows count are NOT promised.
//
//  Voice is PROVISIONAL throughout (13s owns the copy pass). What is fixed
//  here is MEANING: her clarity mandate, verbatim — *"I feel like we need to
//  be extremely clear with users about: permanently deleted things stay
//  permanently deleted if you restore from a backup where they weren't
//  deleted, BUT they aren't deleted from the backup… clarity on what exactly
//  deletion means is paramount."*
//

import Foundation

nonisolated enum DataSafetyCopy {
    /// 13r U3-A — R-13r-14: the second-folder section's title, in ONE place,
    /// because the field guide's backups passage names it as the road
    /// (P-6: the tutorial's door is the pane's own words, never a re-typed
    /// copy that could drift).
    static let secondFolderSection = "A second folder"

    // (VX-329 U1: the "Restoring a copy" lead — `restoringByTheDoor`, VX-307 U2c's today's-road row — rendered only on
    // today's road and was deleted with it.)

    // MARK: - The three sentences the app itself must say

    /// M2/M4 — the SYNCED population's restore warning (her post-sitting
    /// ruling: "we need to warn the user that if they deleted something, it
    /// will auto re-delete from their backup… we need to tell the user it
    /// clearly either way"). The nuance is real and both halves are load
    /// bearing: an ordinary deletion comes BACK, into the Trash; a permanent
    /// one does not come back at all.
    static let syncedRestoreWarning = """
        If this Mac syncs, restoring an older copy does not undo your deletions. \
        Your account tells this Mac what you deleted since: ordinary deletions \
        re-apply and the writing lands in the Trash, recoverable for the rest of \
        its 30 days — and anything you deleted permanently stays permanently deleted.
        """

    /// M3/M5 — the LOCAL-ONLY population's, and her accept-and-say-it
    /// ruling's one honest sentence.
    static let localRestoreWarning = """
        If this Mac is not syncing, restoring is time travel: anything deleted \
        after this copy was made comes back — including things deleted permanently.
        """

    /// M6 both directions, and her clarity mandate's own clause.
    static let bothSidedDeletionTruth = """
        Permanent deletion removes writing from your library and your synced \
        devices — not from backup files. If you restore a backup made before a \
        permanent delete, the deleted writing does not come back into your library; \
        but it is still inside that backup file, and stays there until the backup is \
        rotated away or you delete the file.
        """

    // MARK: - The runbook

    /// The full recipe. Pinned byte-equal to `notes/DataSafetyRunbook.md`.
    static let runbook = """
        # Variorum — data safety and restore

        *Written by the app. The same text is in the repo at
        `notes/DataSafetyRunbook.md`, and a copy is dropped into every backup
        folder as `RESTORE.md` so it is beside the copies it describes.*

        ---

        ## 1. What protects your writing, in order

        Two words first, because everything below depends on them. Your
        library is in one of two modes, chosen in Settings ▸ Protection:
        **Standard** (the default) or **Castle**. In both, the library file on
        this Mac is encrypted and sync is end-to-end encrypted — the Variorum
        server can never read your writing in either mode. The only difference
        is who holds a key. **In Standard your Apple account holds one:** it
        lives in iCloud Keychain, travels with your Apple account, and Apple's
        account recovery can reach it — so this Mac opens your library
        silently, and so does any Mac signed into your iCloud. **In Castle only
        you hold the keys:** your passphrase, your twelve words (the recovery
        phrase you wrote down when you turned on sync or entered Castle), and
        your enrolled devices behind Touch ID. With sync on you hold the
        passphrase and the twelve words in Standard too — they are your way
        back if your Apple account is ever gone.

        1. **The store on this Mac.** `variorum.sqlite`, in the app's
           container — encrypted. This is the truth; everything else is a copy
           of it. The key that opens it sits in this Mac's Keychain (Standard:
           silently, after login; Castle: behind Touch ID — or nowhere at all
           if you chose *Always ask*) and, wrapped, in the small key file
           beside the library (`variorum-keys-….json`): a copy under your
           passphrase, one under your twelve words, and — in Standard — one
           under your Apple account's key. The key file is not secret; holding
           it opens nothing.
        2. **Backups — frozen copies of that file.** Two destinations: one
           beside the store, one in a folder you pick (the first time Variorum
           backs up, it offers to use iCloud Drive for that folder — a copy
           there survives the Mac). They are frozen, which is the whole point:
           they do not follow a mistake. Each copy is encrypted exactly as your
           library is and carries its own key file beside it, written with it
           and never rewritten — so a copy opens with the passphrase and twelve
           words you had the day it was made, and a later change to either
           never touches an older copy. In Castle, locking your library also
           leaves a sealed copy of it as it was, when a backup is due; it is
           checked the next time you unlock.
        3. **Plain-text copies.** Every note as Markdown, into the folder you
           picked — **off unless you turn it on**, now that the library is
           encrypted (a scheduled plain-text copy re-opens the door the
           encryption closed, so it is an opt-in), and turned off again, with
           a notice, when you enter Castle. When on, these are not a restore
           road — they carry the words and not the takes, the history or the
           books — but they are the one copy that stays readable if the
           library file itself is the problem, and they need no Variorum to
           open.
        4. **The mirror (sync).** A PEER, not a backup. It converges — which
           means it replicates a deletion or a bad edit at sync speed. It
           protects you from losing a DEVICE, not from losing writing. It holds
           ciphertext under keys only your devices hold; the server never has
           a key, and an account that signs in without the keys can neither
           read nor write it.
        5. **The platform's own backups.** The sync provider keeps 7 days of
           server backups. They hold ciphertext; without your passphrase or
           twelve words they are unreadable, including by them. This is the
           net under everything and it is meant to die unused.

        The one sentence worth keeping: **backups protect against LOSS; the
        Trash protects against REGRET; sync protects against losing a
        device.** Reaching for the wrong one is how people lose things.

        ## 2. Where the backups are

        - **Beside the store** (always):
          `~/Library/Containers/io.lduarte.Variorum/Data/Library/Application
          Support/Variorum/Backups/`
          In Finder: Go ▸ Go to Folder… and paste that path.
        - **In your folder** (once you pick one in Settings ▸ Data Safety, or
          take the iCloud Drive offer at the first backup):
          `<the folder you picked>/Variorum/Backups/`
        - **The plain-text copies**, in that same picked folder:
          `<the folder you picked>/Variorum/md-exports/`
          One dated folder per export, holding every note as a `.md` file.
          Written weekly while the plain-text option is on (it is off unless
          you turned it on); the 4 most recent are kept.
          **These are readable by anything that can read the folder** — you,
          any program, and whatever syncs it if you picked a cloud folder.
          That is the trade this copy exists to make, and it is worth knowing
          you are making it.

        Files are named `variorum-backup-YYYY-MM-DD-HHMMSS-XXXXXXXX.sqlite`,
        stamped **UTC**, so they sort oldest-to-newest by name; the last eight
        characters name the key the copy is under. Each is a complete
        database, and each has its key file beside it,
        `variorum-backup-YYYY-MM-DD-HHMMSS-XXXXXXXX.keys.json` — keep the pair
        together: the copy is the writing, the key file is what opens it
        anywhere but this Mac.

        **Retention.** Beside the store: the newest 14. In your folder: the
        14 most recent days that have a copy, plus one copy from each of the
        4 weeks before those — about six weeks of reach. Note what that
        window really is: it is how far back you can undo a mistake you did
        not notice, and it is also how long a permanently deleted thing
        stays readable inside these files (see §5).

        **Backups only happen while the app is running.** A week the app was
        closed is a week with no copies — and in Castle they run while your
        library is unlocked (at the first unlock of a day that is due), plus
        the sealed copy a lock leaves. That is why Settings ▸ Data Safety
        leads with the date of the newest copy rather than with a promise.

        ## 3. Restoring a backup

        **Read §4 first if anything has been deleted since the copy was
        made.** This recipe is for a copy of this library under its current
        key — the everyday case. A copy from before you entered Castle or
        replaced your keys is under a key this Mac no longer holds; it still
        opens, with its own key file beside it, on a Mac where this library
        does not live — with the passphrase you had that day, your twelve
        words, or (a copy made in Standard) your Apple account. Then:

        1. **Quit Variorum.** Completely — the store must not be open.
        2. **Copy the pair you want OUT of its folder**, to the Desktop: the
           `.sqlite` file AND the `.keys.json` beside it with the same name.
           You may see files ending `-wal` or `-shm` beside them: those appear
           whenever something opens a copy to read it, they carry nothing, and
           they are not part of the snapshot. Leave them where they are.
        3. **Move the current store aside — do not delete it.** In
           `…/Application Support/Variorum/`, make a folder
           `before-restore` and move into it `variorum.sqlite`, any
           `variorum.sqlite-wal` and `variorum.sqlite-shm`, and every
           `variorum-keys….json` there is. The `-wal` and `-shm` files belong
           to the OLD store; leaving them beside a restored file is the one
           way to corrupt this.
        4. **Put the pair in place.** Copy your Desktop copies into that
           folder: the `.sqlite` named exactly `variorum.sqlite`, its key file
           named exactly `variorum-keys.json`.
        5. **Open Variorum.** On this Mac a copy of the same library opens
           the way your library opens today — silently in Standard, with Touch
           ID or your passphrase in Castle — because it shares the key this
           Mac already holds. Anywhere else it opens the way its key file
           allows: through your Apple account, if the copy was made in
           Standard and that Mac is signed into your iCloud — nothing typed;
           otherwise with the passphrase you had the day it was made, or your
           twelve words. Look for something you know should be there before
           you do anything else. With sync on, the copy then joins your
           account again like any device — in Standard on its own, in Castle
           with the passphrase or words you typed once — and pulls what the
           server holds.
        6. **Keep the `before-restore` folder** until you are sure. It is the
           only copy of everything written after the backup.

        If the app does not open, quit it, move the `before-restore` files
        back where they were, take the pair out, and you are exactly where you
        started.

        **Two things that look wrong and are not.** An older backup is brought
        up to the current version the first time it is opened — that is normal
        and takes a moment. And if Variorum opens with no window at all,
        choose **File ▸ New Window**: nothing is wrong with your library, the
        app just did not open one.

        ## 4. What restoring does to things you deleted

        \(syncedRestoreWarning)

        \(localRestoreWarning)

        ## 5. What deletion means

        Deleting happens in three stages, and only the third one is final.

        1. **Delete.** The writing leaves your library and goes to the Trash.
           Nothing is gone; Put back returns it where it was.
        2. **Thirty days.** It leaves the Trash and every other surface. At
           this point no door in the app offers it back — but its rows are
           still on the disk until the next stage runs.
        3. **Permanent deletion.** Either you asked (Delete Now, Empty Trash)
           or the 30 days passed. The rows are physically removed here and on
           every device on your account. What makes this survive a restore is
           a small record of *which ids were removed* — no words, no titles —
           so a device that comes back with an old copy is told "that one is
           gone" instead of putting it back.

        \(bothSidedDeletionTruth)

        The same is true of any backup outside this app — Time Machine, a
        cloned drive, a folder in the cloud. And it cuts the other way too: a
        backup that was rotated or overwritten AFTER you deleted something no
        longer contains it. The retention window in §2 is the real horizon
        for both.

        ## 6. Reading one backup without restoring it

        Most of the time you do not want a restore. You want one note back —
        and you want everything written since to stay where it is. Do §3
        twice:

        1. Follow §3 steps 1–5 to open the backup — the pair, the key file
           beside it. Your real store is safely aside in `before-restore`;
           nothing is lost.
        2. Find what you want and **select and copy the text**.
        3. Quit Variorum. Take the pair out, and move the `before-restore`
           files back where they were (the `-wal`/`-shm` with the store).
        4. Open Variorum — you are exactly where you started — and **paste
           into a new note.**

        **Always copy out as new.** Never try to re-insert an old note "as
        itself". Anything that comes back this way is a fresh note with a new
        identity, which is what you want: it cannot fight with the record of
        what was deleted, and it cannot be removed again by a rule that was
        about the old one.

        ## 7. If the mirror is lost, or a device is

        These are the two directions, and both have been done for real:

        - **The mirror is lost or wrong.** Your Mac's store is the truth. The
          mirror is rebuilt by pushing this store back up to it. This has been
          executed live three times (twice at the encryption cutover, once at
          the multi-tenant rebuild). Nothing about your keys changes.
        - **A device is lost or stolen.** In this order: Settings ▸ Account ▸
          Sign Out Everywhere, so the device can no longer sync; Settings ▸
          Encryption ▸ Replace All Keys, so nothing it holds opens anything
          new — your sync gets a new master key and a new corpus key,
          everything on the server is re-encrypted from this Mac, this library
          gets a new key, and each of your other devices asks for your
          passphrase once and gives its own library a new key; then change
          your account password. What the lost device can still read: in
          Castle, nothing — its library is behind its Touch ID or your
          passphrase. In Standard, whoever can unlock that device can read
          what was on it — that is Standard's trade — and that device is
          signed into your Apple account, which holds a key, so also remove it
          from your Apple account (your Apple ID's device list, or Find My).
        - **Someone was inside your Apple account, and you're in Standard.**
          Replace All Keys does not shut them out on its own: your Apple
          account holds a key to the new keys too. Secure the Apple account
          with Apple's tools, or enter Castle — Castle gives your library and
          your sync keys your Apple account never held. Every copy made before
          that day (Variorum's own, Time Machine, copies elsewhere) still opens
          through the Apple account; the switch offers to delete Variorum's
          own, and the rest are yours to delete or keep as a way back.
        - **Your account itself is in someone's hands.** Delete it (Settings ▸
          Account — your account password, a typed phrase, and a fresh
          sign-in) and set sync up again under a new one: every library on
          your devices stays and uploads to the new account.

        The rule behind all four, once: a passphrase or twelve words merely
        SEEN — change or regenerate them (your devices keep syncing; the old
        word stops working on each once you have used the new one there); a
        leaked account password — Sign Out Everywhere, then change it; someone
        who may HOLD your keys (an unlocked enrolled device of yours, or a
        secret that may have been used) — Replace All Keys; in Standard,
        someone inside your Apple account — Apple's tools, or Castle; the
        account itself — delete it and set sync up again.

        Neither of these is a backup story. If what you lost is *writing*, the
        answer is §3 or §6, not the mirror.

        ## 8. If you forget the passphrase

        Since the encryption update this is a question about your LIBRARY,
        not just the mirror: the store on this Mac and every backup above
        are encrypted under one library key, and the mirror is sealed the same
        way. Your passphrase and your twelve words (the recovery phrase) do
        not encrypt anything themselves — they are ways to hand a key back to
        you when this Mac's own Keychain cannot. What forgetting costs depends
        on your mode:

        - **In Standard**, nothing today: your Apple account holds a key, so
          your library opens silently on this Mac and on any Mac signed into
          your iCloud, and so does every backup made in Standard. Set a new
          passphrase whenever you like — Settings ▸ Encryption ▸ Change
          Passphrase ▸ *Forgot your current passphrase?*: this Mac holds your
          keys, so it lets you choose a new one.
        - **In Castle**, any device that still opens your library can set a new
          passphrase — Settings ▸ Encryption ▸ Change Passphrase ▸ *Forgot your
          current passphrase?*, confirmed with Touch ID (on a device set to
          always ask, with your twelve words). If no enrolled device opens,
          your twelve words open your library and your sync: type them
          wherever the passphrase is asked. Nothing else opens it, by design —
          not Apple, not us.

        And the floors — the app's own sentences, the same ones the
        Protection pane's cards show:

        - **Standard** — the floor: you lose your writing only if you lose every Apple device, every way \
        Apple offers to recover your account, and your passphrase and twelve words. Keep the words: they \
        are your way back if your Apple account is ever gone.
        - **Castle** — the floor: lose every enrolled device and both your passphrase and your twelve \
        words, and your writing is gone. Nobody can help — not Apple, not us. That is the point of \
        Castle, and it's why we ask you to write the words down.

        Losing your writing means losing EVERY way back in at once — any
        single one of them still standing gets you back in.

        **Check before you need to.** Neither secret is used day to day — the
        device unwraps once and remembers — so the first time you type one
        again may be the day it matters. Settings ▸ Protection has a check
        for exactly that: type the passphrase or the twelve words and Variorum
        tries the real unlock, then tells you yes or no. It changes nothing,
        resets nothing, and getting it wrong there costs nothing.
        """
}
