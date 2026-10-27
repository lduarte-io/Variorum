# VX-502 — her handoff (export across migrations + the Castle-restore walk; overnight 2026-10-27)

## Your checklist

- [ ] **The morning bundle (3 items, full text in the record's THE MORNING BUNDLE):**
  1. The walk's credential lanes — an interpretive note, built-as-planned and now AS-RUN: your "the walk uses
     dev-castle.env exactly" was honored for the dev library's secrets (its ONE use: the read-only check door);
     the Castle test legs ran on walk-owned libraries under the castle vxtest account's pair through your R-510
     machinery, because the active dev library is HELD (VX-309's banner) and any Castle act on it would have
     destroyed that state. Nothing invented, dev pair never changed. Say if you wanted it read the wider way.
  2. A provisional act: `~/.variorum/bin/type-dev-castle-secret` exists (the dev-pair typing road the walk
     needed; none existed). Mode 700, reads only dev-castle.env (600), frontmost-must-be-Debug-by-exact-path,
     stdin delivery (never argv), lane guard, a --check mode. Keep or delete — the walk-machinery precedent says
     keep.
  3. Your `type-prod-test-secret` passes the secret in osascript's ARGV (briefly same-user-ps-visible). The new
     helper uses stdin. Patching yours to match is ~6 lines, same checks — want it?
- [ ] **The release gate you set is DONE:** the export fix is merged and the Castle-restore walk ran green with
      the pair-change arm you authorized ("the old one still works AND the new one works" — both proven at leg 6,
      plus the restore end to end through unlock and sync). Remaining launch gates per your 2026-10-26 rulings:
      VX-421 (inside VX-601), VX-548, and your content items.
- [ ] The dev slot's safety copy `…/Variorum-dev/Backups/safety-copies/variorum-vx502-walk-2026-10-27T102019Z`
      (9 files, cmp-verified) was KEPT as the walk's net — yours to prune whenever.
- [ ] VX-439 (the export seam's other side) rebases and re-runs the export/import pins before its PR — the
      coordinator is telling it; nothing for you unless it stalls.

## What shipped

**The code (unit A):** T-8's bring-in gate is your ratified rule — an export whose applied migrations are a
SUBSET of the importing build's known set reads and imports (your 0.10/9093 exports import again); one written by
a newer Variorum refuses (at the pick; the gate's own refusal is the honest `schemaNewer`). The dead "earlier
build" refusal face is deleted. P-VX309-U1b-7 is superseded. The era-frozen guard pin (ladder rounds 1+2) locks
the future: a v1_31-era export (the oldest real one — VX-461's floor) must keep classifying and reading whole, so
any future migration that breaks old-export reads goes red in the suite instead of in a user's hands.

**The walk (unit B):** all 13 legs green, NO finding against CastleRules — rule 5's floor (the OLD passphrase
opened the old Castle backup), rule 6 (the NEW passphrase opened it through the key history), rule 7 (the
account's lock re-wrapped with both passphrase changes, vault 23→24→25→ back), rule 17 (the restore minted a
fresh key; the old passphrase was REFUSED at the restored library's lobby), rule 21 (the hand-return's notice),
R-529-7 (the words moment stayed quiet at the join). The dev store ended exactly as found — e11e5233, Standard,
held, signed out — confirmed independently by the coordinator before the stage moved on.

## Evidence

Unit A: pins 1–2 red-on-old (quoted in the record), pin 3 + the era pin guards with teeth shown by probes
(announced, isolated, reverted); behavioral reverts RV-A1/RV-A2 run and restored; core suite debug 3437/457 and
release 3408/452 green (the known MCP load-flakes alone-green); the ladder r1 (fable) 0·1·1·1 and r2 (opus,
final) 0·0·2·4, every finding dispositioned, fixes checked line by line. The stage batch: 594 tests EXECUTED in
109 suites (every suite naming the changed types, the Mac tutorial suites included), 0 failed — the flipped
bring-in pin's first-ever execution passed. The walk: per-leg state lines + the RELEASE line in the record;
screenshots lived in the gitignored evidence folder, deleted at the post-merge tidy per the closeout rule (the
record is the evidence of record).

## Ledgers

Record: `notes/plans/fixes/vx-502-export-across-migrations.md` (charter, rulings, LIVE STATUS, the negotiated
walk, the walk rulings, the morning bundle). Ladder: `vx-502-ladder-round-1.md` · `-round-2.md`. Walk script of
record: `notes/plans/fixes/vx-502-walk-script.md` + `Tools/WalkKit/castle-walk-lib.zsh` (kept — walk machinery).
Canon: SurfaceContracts' portability bullet changed in place (the subset-rule clause, one pointer);
AppSpecRecord's dated entry + QUESTIONS #239(a)'s built-note land at the merge. `Tools/canon-size`:
**125,675 / 150,000 (headroom 24,325) — no crossing.** Tickets FILED by this effort: **none.** MOBILE PARITY:
**nothing mobile-visible** (the phone has no Open Library door; VM-30 holds the phone's export writer).
VX-502 → Done at the merge. No release, no /Applications refresh — your word stands; 0.10.2 remains current.
