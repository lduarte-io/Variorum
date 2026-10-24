# VX-510 — your handoff (CLOSED 2026-10-24, PR #186)

## FOR YOU, IN ORDER

1. **0.10.1 — the release runs right after this merge** (your R-510-22 + R-510-29: provisional, on green gates only).
   Every gate before it is green (below). The release road (release.sh from main → the DMG and the appcast on the
   site → the `/Applications` refresh behind a fresh A1) runs after the merge; its outcome is in the closing session's
   morning summary, and the next closeout folds it into the records. If anything held the release, the summary says why.
2. **The Castle leg ran green on the final build (06:02–06:21).** The join landed with its first round and no relaunch;
   Use Castle; "Use your twelve words instead" opens from the words (VX-527); the typed unlock loaded the sync keys
   (VX-501); the check door said "opens this library and your account" in Castle (VX-513); Use Standard and Change
   passphrase raised no Touch ID window (VX-517). The dev store is back exactly as it was (every inode matched).
3. **Two things the walk found, ticketed (Low):** **VX-534** — Settings ▸ Protection's Sync section keeps its
   signed-out arm if you sign in with Settings open (reopen it and it's right) · **VX-535** — VX-527's fix works on the
   words and the row they fill, but its extra 4-point reach past the label (the gap after the arrow, the thin band
   above) isn't honoured by SwiftUI; the door still does what you asked.
4. **The `castle` test account's passphrase is now the env file's PASSPHRASE2** (the walk's Change passphrase moved it;
   `~/.variorum/prod-test-accounts.env` holds both values, unchanged). Its words are unchanged. On production it reads
   Standard, vault revision 18.
5. **QUESTIONS #240 — the wording bundle, provisional at your word (R-510-26)**, whenever you want to review it. The
   items most worth your eye: the join's door/title/button together (P-VX510-3 + A4), the 10-second unlock bound
   (P-VX510-B2-1), and VX-535.
6. **VX-529 is the next run** — `notes/handoffs/vx-529-kickoff.md` (its design memo first, P-5; your R-510-20 verbatim
   as the boundary: the Castle design doesn't change).

Already answered at the cutover sitting (recorded in the run record's HER CLOSEOUT ANSWERS): the release (R-510-22),
keep all three test accounts (R-510-23), VX-521 closed (R-510-24), VX-528 closed (R-510-25), the bundle stays
provisional (R-510-26), Pre-launch = VX-529 only (R-510-27), CastleRules rule 2's clause landed (R-510-28), VX-533's
"apple timeout" fact on its ticket.

## THE RELEASE NOTES (0.10.1 — bundled as `ReleaseNotes-0.10.1.md`, the draft verbatim)

**Turning on sync now finishes the job.** The first sync runs the moment you turn sync on, and the window stays to
confirm it landed — or to say exactly what's in the way. Before this fix, a newly set-up library could sit saying
"Sync locked" until the next launch, looking done while nothing had ever synced.

- A library that hasn't joined your account now says "Sync isn't on for this library yet" instead of reading as
  locked — and when your account already syncs, the door says "Sync this library…" instead of "Turn on sync…".
- In Castle with "Always ask", typing your passphrase or twelve words at the lock screen now unlocks sync for the
  session too. Before, sync stayed locked after every lock until a key change.
- After your library joins an account, the card offering to record new twelve words goes away — the words you hold
  are the account's, and pressing the card would have replaced them.
- Settings ▸ Protection gains "Check my passphrase or twelve words…" — type either one to check it. Checking changes
  nothing.
- Standard libraries no longer raise stray Touch ID prompts left behind by an earlier Castle library on the same
  Mac, and those leftovers are now cleaned up properly.
- The lock screen's "Use your twelve words instead" now opens from the words themselves, not just the little arrow.

## THE RUN, IN ONE PARAGRAPH (the full record: `notes/plans/fixes/vx-510-first-run-sync.md`)

On 0.10 no account act started a sync round: VX-329 deleted the old road's post-enrollment round hook and nothing
replaced it, so a Standard set-up sat at "Sync locked" until a relaunch (joins only looked fine because a Touch ID
*[removed for publication]*
*[removed for publication]*
every account act that changes sync's standing now runs its first round at once and its sheet stays to confirm it
(VX-498/VX-507), with the not-yet row and the join's door (VX-506), the standing first-run drill and scripted walk
(VX-509), the Debug-only prod test road for named test accounts, and the members you added — VX-501 (the typed unlock's
sync keys), VX-511 (the words card at a landed act), VX-503 (no Touch ID press at a Standard join), VX-513 (the check
door), VX-517 (Touch ID leftovers forgotten by name), VX-527 (the lobby's words door). Units A · B1–B5 · L1 by fresh
Opus implementers, pins red-on-old with behavioral reverts; the ladder on fresh Fable reviewers (r1 0B·0M·3m·2n → r2
0B·0M·1m·1n, every fix sound); the live acceptance on production with three fresh accounts (std, castle, del) plus a
fourth fresh first run and the Castle leg on the final build. MOBILE PARITY: PL-58 (the phone's row reads the not-yet
line). Canon: SurfaceContracts' protection bullet and CLAUDE.md's prod-test-road line; **canon-size 125,663 / 150,000**.

## EVIDENCE AT A GLANCE

- The ladder: round 1 `0B·0M·3m·2n` → unit L1 + O-L1-1 → round 2 `0B·0M·1m·1n`, every fix SOUND, final check 2/2.
- The closing stage batch: core whole green (the one pre-existing load-margin timing test isolated green ×2 — VX-532);
  the WHOLE Mac target `5221 tests in 915 suites passed` (the real-keychain Touch ID arm RAN); the phone `62/7` +
  `47/15`, zero skips. The 0.10.1 version gate: `26 tests in 5 suites passed`.
- The re-walks on the final build: the fresh-account first run end to end (sheet confirmed, row "Synced", no relaunch;
  server: vault standard rev 1, key-proof enrolled, one cursor); the Castle leg green (server: castle rev 15 → 16 → 17 →
  18, cursors 6 → 7, containers 4 → 5); the restore clean.
- The rulings reconciled against what shipped (the record's THE CLOSEOUT): all met, with one honest gap — R-510-2's
  "restoring a backup" was walked in Standard only; in Castle the backups were opened by Look inside with old, current
  and new secrets but not restored.

## THE TICKETS THE RUN FILED, BY PRIORITY

- **Closing with the merge (members):** VX-498 · VX-501 · VX-503 · VX-506 · VX-507 · VX-509 · VX-511 · VX-513 · VX-517 ·
  VX-527, and VX-510.
- **High:** **VX-529** (Pre-launch, the next run) · VX-516 (a second MCP wing grant revokes the first).
- **Medium:** VX-512 · VX-515 (MCP) · VX-518 · VX-519 (v1 release readiness) · VX-520 · VX-524 · VX-530 · VX-533
  (Castle & backups) · VX-537 (the walk script's join arm).
- **Low:** VX-522 · VX-523 · VX-526 (18a, wording) · VX-525 · VX-534 · VX-535 (Castle & backups) · VX-531 · VX-532 ·
  VX-536 (tooling).
- **Closed at your word:** VX-521, VX-528; **canceled:** VX-514 (the Sherlock double — not a bug).
