# The Castle rebuild's delta for the stargazing.tech agent — hand over at the release switch, not before

**Written 2026-10-14 with the VX-266 design** (`notes/plans/vx-266-castle-backups-prelaunch.md`). This is a delta to
the two current briefs: `notes/stargazing-privacy-policy-brief-2026-10-04.md` and
`notes/stargazing-help-faq-brief-2026-10-04.md`. **Those briefs stay true until her release switch (VX-329)**, because
every Release build runs today's protection code until she turns the new system on. So this delta is handed to the
site agent only at that switch, by the author, with the release that carries it.

**Before handing it over, VX-329 re-checks each fact below against the shipped build.** The phases may refine
wording, and the app's own sentences come from the copy file (`notes/plans/pre-13x-copy.md`) as phases 3–5 re-write
it. As with the current briefs, the site agent writes the copy and this brief carries facts only.

The register stays the current briefs' one. Everyday answers name no key. The FAQ may say "the twelve words", "your
Apple account" and "iCloud Keychain", and never "box".

## The two-sentence model, as it becomes

Both modes stay end-to-end encrypted, and the server still never holds a key to either. Who holds a key changes in
two ways:

- **In Standard,** your Apple account holds keys of its own for your library: one for each Mac's copy of each
  library, and one for the sync account, which opens only the server's copy of the master key. Anyone who can sign
  in to that Mac can open the library too. That's true today; the new system says it plainly, on the Standard card,
  with a try-it-yourself line in the field guide.
- **In Castle,** nothing reachable through the Apple account or the Mac's login password opens the library, or any
  copy Variorum made of it. Entering Castle deletes the library's Apple keys, so older copies stop opening through
  the Apple account too, apart from the stated exceptions below.

## FAQ entries whose facts change

- **"I switched to Castle. Are my old backups protected?"** The answer becomes **yes**. Entering Castle deletes this
  Mac's own Apple keys for the library, and the old shared one, after checks at the door. No copy Variorum made then
  opens through the Apple account. The exceptions are stated, each said on the affected copy's *Opens with* line:
  - a library already in Castle before this change, until its old shared key is retired (one press);
  - copies from a sync account's Standard days, through that account, until it replaces its keys or enters Castle;
  - a library sent to another Mac before this change, until either copy crosses a line;
  - a retirement made while iCloud Keychain is off, until it's back on;
  - Markdown exports, which are plain text;
  - copies locked under an Apple key in an Apple account the Mac has since left.

  Time Machine copies of Variorum's backups follow the same rule, since their Apple locks die with the key.
- **"I moved to Castle, lost my passphrase and twelve words, and have an old backup and my iCloud."** The old backup
  **no longer opens** through the Apple account. Her ruling: *"I think it's fine for people to lose access to previosu
  backups if they lost their passphrase / words / touchID + they're going into castle, so long as they're adequately
  warned about it."* The door says so before anything happens and offers *Export a plain copy first*. Only Markdown
  exports remain readable.
- **"Someone has my old backups and my Apple account — and I've since moved to Castle."** They **can't open** those
  backups any more, apart from the exceptions above.
- **"Moving to a new Mac" / Send Library.** The copy lands on the other Mac under a fresh key of its own, with an
  empty key history: nothing is shared between the Macs. The passphrase alone, or the twelve words alone, opens it,
  and the landing then asks for the other one — typed, or made new — so both open it from then on. A Standard copy on
  the same Apple account can land with nothing typed. A synced copy lands held until Resume Sync, and a secret made new
  at the landing becomes the account's then.
- **"Restoring a backup."** A copy of your library opens through its key history: today's key opens the older ones,
  so nothing more is typed. A restored copy takes the library's current mode and never lowers it. Copies from before
  you left Castle open with the passphrase or the twelve words you had on the day you left. On your other devices,
  copies open with at least the secret you typed there when that device followed. Each copy's *Opens with* line says
  which, and from which day.
- **"My twelve words were seen" / "I forgot my passphrase."** If your library left Castle earlier, every door that
  replaces a secret says what still opens the copies from before the leave:
  - new words: the old words still open them — keep that paper;
  - the forgot road: they now open with that day's twelve words.
- **"I reset my iCloud Keychain."** Re-link now makes a **fresh** key for the account, and its library arm makes a
  fresh own key for a library whose Apple key this Mac can no longer read. Nothing is re-keyed. The old "the iCloud key
  is read, never re-minted" fact is gone.
- **"Someone was inside my Apple account, and I'm in Standard."** It stands: Replace All Keys in Standard keeps the
  new master under the account's Apple key, and Castle is the answer. An account still on the old shared key gets a
  fresh key of its own first.

**New entries the site may want:**
- **I left Castle. Who can open what now?** Your Apple account, and anyone who can sign in to that Mac, opens the
  library itself — with everything written in it, in Castle too — and every copy made after you left. No copy made
  before you left opens through them: those open with the passphrase or twelve words you had that day. Leaving never
  makes new words, so that day's paper keeps working.
- **I stopped syncing a library, or moved it to another account.** The library gets a new key in either mode. The
  account you left opens only the copies from while it synced in Standard, until that account replaces its keys or
  enters Castle, and never anything written after.
- **Does Castle on my Mac make my iPhone Castle?** It stands. Each device follows by typing the passphrase or the
  words once.

## Privacy-policy facts that change

- **Tier 1, key custody.**
  - Standard: the Apple account holds keys, not "ONE key": one per library per Mac, and one per sync account for the
    server's wrapped copy of the master. They're still Apple's keys, never ours.
  - Castle: entering it deletes those keys, and no copy Variorum made opens through the Apple account, apart from the
    stated exceptions.
- **Tier 2, what a copy of the library file carries.** "No sync key and no device identity" becomes: **no sync key.**
  Its protection record names each device that has opened it, by a random identity and a salted hash of its hardware
  (never the identifier itself), with that device's protection settings. These are used only on that device; another
  Mac mints its own identity.
- **Tier 2, what a backup carries.** Each backup carries its own key file, still non-secret: holding it opens nothing
  without a secret. The key file now also holds the key history (older keys, each locked under the current key) and,
  after a leave from Castle, the Castle anchor, locked only with that day's passphrase and words.
- **Tier 2, Standard's login-password truth.** It belongs in the policy plainly: in Standard, anyone who can sign in to
  the Mac can open the library through the Mac's keychain. In Castle, the key isn't on the Mac in any form the login
  password can release.
- **Tier 3, what the operator sees.** The account's key record shows one of three states: a wrapped copy under the
  account's Apple key (Standard); none (Castle); or, while a device is moving the account out of Castle, an Apple key
  named with no copy yet. The operator still opens none of them.
- **Cautions, added.**
  - Don't say backups made in Standard stay openable through the Apple account after entering Castle. They don't,
    apart from the stated exceptions.
  - Don't say a library sent to another Mac shares its keys. It doesn't, apart from one sent before this change.
