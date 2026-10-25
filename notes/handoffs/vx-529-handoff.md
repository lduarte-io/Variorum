# VX-529 — your handoff (CLOSED 2026-10-25)

## FOR YOU, IN ORDER

1. **0.10.2 — the release runs right after this merge, at your word** ("i approve the release, i approve the release
   notes"). The build needs Variorum closed on the Pro for a few minutes; the session asks for that as one step. The
   outcome (the DMG, the appcast, the site) is in the session's closing message, and the next closeout folds it into
   the records.
2. **The Air's cleanup** — if you haven't pasted step 16's prompt into the Air's session yet, it's in the run record
   under HER TWO-MAC TEST. Nothing on the Air is owed otherwise; it already runs the fix (build 9440).
3. **QUESTIONS #241, whenever you want.** It's the run's provisional bundle: the wording notes you said to leave marked
   ("I'd leave them marked somewhere"), and **two rule clauses drafted for you to ratify or decline** — rule 7's
   "…backups made with them", and a clause beside rule 3 for VX-538's card. Neither is written into CastleRules.
4. **Later, at your word:** **VX-544** (an offline unlock with your passphrase leaves Castle sync locked until a Touch
   ID unlock or a relaunch) and **VX-542** (the follow pane repeats its sentences — worse on your real Air).
5. **Next run:** the mobile catch-up (VM-8). The phone's context is the mobile handoff plus MobileSoul PL-58 and PL-59.

*[removed for publication]*
`last_sign_in_at` is Oct 14 because his app kept refreshing the session rather than signing in fresh — not a
problem); VX-510's picked-folder leftovers are deleted at your word.

## THE RELEASE NOTES (0.10.2 — bundled as `ReleaseNotes-0.10.2.md`, your approved text verbatim)

**Your other Macs keep up when you change your passphrase.** Change your passphrase or make new twelve words on one
Mac, and your other Macs now notice and catch up, usually with one press. Before this fix, a Mac that had been away
kept your old passphrase, and in Castle it could stop syncing with no way to catch up.

- If your passphrase changed on another Mac, Settings ▸ Protection says so and offers "Follow your account…". Type
  your new passphrase once and this Mac catches up.
- At the lock screen, your account's new passphrase now opens the library and catches this Mac up in the same step.
- Forgot the new passphrase? Your twelve words can catch this Mac up instead. Then set one you know with Reset
  forgotten passphrase.
- New twelve words made on another Mac are picked up with one press, nothing typed.
- If this Mac doesn't have your account's passphrase yet, a card above the quick entry asks you to type it once.
- Restoring a backup and syncing it again no longer says your twelve words were replaced when they weren't.
- In Castle with Touch ID, changing your passphrase asks for your fingerprint at most once.
- If you miss the Touch ID prompt at the lock screen, the button stays so you can try again.
- A few sentences are clearer: the "Sync this library" sheet's title and button, and the banner on a restored library
  that doesn't sync.

## THE RUN, IN ONE PARAGRAPH (the full record: `notes/plans/fixes/vx-529-pair-catchup.md`)

When the pair (the passphrase or the twelve words) changed on one Mac, another Mac kept the old locks on its key
file: in Standard it kept working on the old passphrase, and in Castle it could stop syncing with no road back. Your
boundary held throughout — no Castle rule changed and nothing stored changed shape (R-510-20). The fix teaches the
follow a third kind, **the pair change**: a re-lock of this Mac's key file to the account's current pair, never a
re-key, writing nothing to the server. It is detected by comparing the key file's locks with a fresh read of the
vault. Your rulings shaped it: the lock screen takes the account's new passphrase and lands the catch-up in the same
press (R-529-1); new words are followed quietly (R-529-2); the key doors refuse and point at the follow (R-529-3);
either current secret works, and typed words drop the stale passphrase lock (R-529-5); that state is named with its
why and its road and stays visible until it's healed, with VX-538's card (R-529-6); VX-523 fixed in this run
(R-529-7). The riders VX-526 · VX-522 · VX-523 · VX-530 · VX-533 · VX-538 rode along. Three units by fresh Opus
implementers, pins red-on-old with behavioral reverts; two Fable ladder rounds; the closing stage batch; the live
proof on production; your two-Mac test. MOBILE PARITY: PL-59. Canon: SurfaceContracts' protection bullet gains THE
PAIR CATCH-UP; **canon-size 125,663 / 150,000**.

## EVIDENCE AT A GLANCE

- The ladder: round 1 `0B·0M·1m·2n` → fix sessions L1 + L2 → round 2 `0B·0M·0m·2n`, every fix SOUND; no round 3.
- The closing stage batch: the Mac target `5231 / 5265` (the 2 failures are VX-539's week-boundary flake, proven on
  main); the phone `808 / 126`. The 0.10.2 version gate: `26 tests in 5 suites passed`.
- The live proof on production (the `castle` test account): D0–D7 all pass, the dev store restored exactly (every
  inode matched). Two incidents traced, proven harmless, recorded with standing rules (I-D0-1, I-D0-2).
- Your two-Mac test on your real Macs and account: the Pro changed the passphrase → the Air's lock screen took the new
  one and caught up in the same unlock, then opened offline with it, and the typed unlock loaded sync online; the Air
  made new words → the Pro followed with nothing typed, and the check passed there.
- The rulings reconciled against what shipped (the record's THE CLOSEOUT): all met. R-529-6's "clearly expressed
  everywhere" left two lines unbuilt, now ticketed: the join's words-moment line (on VX-541) and the guide's line (on
  VX-379).
- Installs: the Pro runs build 9439 (A1 `variorum-a1-vx529-install-2026-10-25T075213Z`); the Air runs 9440 (A1
  `variorum-a1-vx529-install-20261025T081854Z`). The `castle` test account ends in Castle, vault revision 23, on the
  env file's `passphrase`, its words in `~/.variorum/prod-test-words-castle`.

## THE TICKETS THE RUN FILED, BY PRIORITY

- **Closing with the merge (members):** VX-526 · VX-522 · VX-523 · VX-530 · VX-533 · VX-538, and VX-529.
- **Medium:** **VX-544** — an offline unlock with your passphrase leaves Castle sync locked (later, your word).
- **Low:** VX-539 (the retention suite's week-boundary flake) · VX-540 (a post-launch sitting on letting Castle rotate
  sync keys on purpose) · VX-541 (the check door's faces + the join's words-moment line) · VX-542 (the follow pane's
  repeated sentences; later, your word) · VX-543 (the lobby's "the one before it").
- **Updated, not filed:** VX-379 (the field guide) gained your compromise-recovery recipe and the line for the state
  R-529-6 names.
