# VX-510 — her handoff (DRAFT at the 2026-10-24 model cutover; PENDING slots filled at the closeout)

## FOR YOU, IN ORDER

1. **A release?** Your testers need these fixes: tester B needs a clean re-setup on a fixed build; tester A's eventual
   upgrade-and-join only confirms itself on a build carrying this run — and your own Air hit VX-501's state during this
   window. The drafted notes are below; your word mints it (never without).
2. **Keep `std` and `castle` as standing release-drill accounts?** (`del` was deleted by LEG D and re-minted fresh by
   the re-walk as the standing fresh-account vehicle; its state at close: PENDING.)
3. **Pre-launch flags** on the run's filed tickets — the set, grouped by priority: PENDING (the closeout's triage).
4. **VX-521** — recommended: keep today's behavior and close (your own framing: holding the words change until the
   acknowledgement makes the confusing case real; VX-511 closed the worst road into the look).
5. **VX-528** — is per-Mac seeding intended (a second library on the same Mac gets no seed content)?
6. **The PROVISIONAL wording bundle** — QUESTIONS #PENDING (P-VX510-1…3, A1…A4, B1-1, B1-2, B2-1, B3-1, B3-2, plus
   D-B8 (c)'s reading, F-B4-1's residue, and F-R1-3 (a): CastleRules rule 2's "until it is dismissed" does not yet name
   VX-511's third retirement road — one clause, yours alone, the Castle design frozen).
7. **VX-533** (your Air, this window): after the Touch ID prompt timed out, was the "Unlock with Touch ID" button
   visible but unresponsive, or gone? One word settles which mechanism gets traced.
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
