# VX-510 — her handoff (DRAFT at the 2026-10-24 model cutover; PENDING slots filled at the closeout)

## FOR YOU, IN ORDER

1. **A release? — ANSWERED at the cutover sitting (R-510-22): YES, after the merge.** The successor runs the release
   road once the PR merges; the notes below presented at the publish.
2. **The test accounts — ANSWERED (R-510-23): keep all three** (del stays as the fresh-account/deletion vehicle).
3. **Pre-launch flags — ANSWERED (R-510-27): VX-529 only** (flagged on the board; the grouped list still lands at the
   closeout's triage for reference).
4. **VX-521 — ANSWERED (R-510-24): closed, behavior kept.**
5. **VX-528 — ANSWERED (R-510-25): closed, per-Mac seeding stands** (your words in the record; the restore doors serve
   the bare-second-library case).
6. **The PROVISIONAL wording bundle — ANSWERED (R-510-26): stays provisional**, filed in QUESTIONS at the closeout for
   your later pass. **ONE ITEM STILL OPEN, yours: CastleRules rule 2's clause** — your question and the honest answer
   (a passphrase join adopts words it never shows) plus the draft clause are in the record's HER CLOSEOUT ANSWERS;
   say yes / edit / leave-as-is.
7. **VX-533 — ANSWERED in part:** your "apple timeout … gets pale and then disappears" is on the ticket; the remaining
   trace (does the lobby's button fire a fresh context after the system sheet fades) is the fix run's.
8. **VX-529 is the next run** — the kickoff is ready: `notes/handoffs/vx-529-kickoff.md` (its design memo comes first,
   per P-5; the boundary is your R-510-20 verbatim).

## THE DRAFTED RELEASE NOTES (0.10.1 — your word mints it)

Turning on sync now finishes the job. The first sync runs the moment you turn sync on, and the window stays to
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

PENDING (the closeout writes it: the trace, units A–B5 + L1, the ladder's three rounds' counts, the acceptance's three
accounts + the re-walk's fresh fourth, the stage batch's numbers, the canon-size line, the MOBILE PARITY line).

## EVIDENCE AT A GLANCE

- The ladder: round 1 `0B·0M·3m·2n` → unit L1 + O-L1-1 → round 2 `0B·0M·1m·1n`, every fix SOUND, final check 2/2.
- The closing stage batch: core whole green (the one pre-existing load-margin timing test isolated green ×2 — VX-532);
  the WHOLE Mac target `5221 tests in 915 suites passed` (the real-keychain Touch ID arm RAN); the phone `62/7` +
  `47/15`, zero skips.
- The re-walk (the successor's own hands, production): the fresh-account first run END-TO-END on the final build —
  the sheet confirmed, the row "Synced", no relaunch; server-verified by its own reads (vault standard rev 1, key-proof
  enrolled, one cursor). The Castle leg: PENDING.
