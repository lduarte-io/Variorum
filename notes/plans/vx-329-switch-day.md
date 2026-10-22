# VX-329 — The switch-day script (for her hands; drafted 2026-10-22 at the kickoff, finalized after the throwaway rehearsal)

**What this is.** The step-by-step script for switch day: both Macs cross from today's road (0.9.8) to the new
protection system (0.10), her writing returning by sync. §2's answer is inside it. The deploy half's authority is
`notes/plans/vx307-deploy-checklist.md` (artifact 17 + the pg_temp artifact, marker 13 → 14); this file is the
device-side choreography around it. **Every REHEARSAL-PENDING marker below flips only when the plan's §8
rehearsal record exists** (the ladder's round-1 MAJOR: this script claimed REHEARSED ahead of the rehearsal —
corrected; the record is the proof, never the plan). HER-CALL items sit in the morning bundle.

## §2's answer (the one question — how a fresh new-road library gets her synced writing back)

**By the join.** Her account's rows stay on the server, each sealed under the sync key that was current when it was
written; artifact 17's backfill carries the vault's keys and posture into the marker-14 shape (proven field-by-field
at VX-308 §5R); rule 15's kept list means a fresh library joining the account reads everything. The sealing seam
(AES-GCM, AAD, `e1:`) is byte-unchanged across the switch, so key continuity is the whole question and the vault
shape was the whole risk. REHEARSAL-PENDING: a fresh new-road library joins a throwaway account whose vault is
post-backfill-shaped and whose rows predate the join — the full pull decrypts everything. *(This paragraph flips to
REHEARSED only when §8 of the plan file carries the record.)*

**The export road is the belt, not the road:** rule 26's instruction for anyone unsynced. It must name a door that
works — VX-461's fix rides this phase; until the stage batch confirms it on a real store, the named roads are sync
(first) and Copy full text (the markdown road).

## The window, in order (one sitting, both Macs; the phone deliberately follows VM-8)

0. **Preconditions.** The VX-329 PR merged; the 0.10 Release build built and codesign-verified; the deploy NOT yet
   run; both Macs still on 0.9.8; the throwaway rehearsal green. Backups: the Pro's A1 + rehearsal byte copy are
   ALREADY STAGED (2026-10-22, 7/7 cmp-identical — `/Users/Shared/vx329-rehearsal/` and
   `Backups/safety-copies/variorum-vx329-stage-20261022T115834Z/`); take the Air's A1 copy in the window the same
   way (zero instances, the whole slot, no extension filter).
1. **Quit Variorum on both Macs** (zero instances by `pgrep -fl 'Variorum.app/Contents/MacOS'`).
2. **The mirror deploy, at your explicit go** — the vx307 checklist verbatim: preflight probes (your vault row's
   posture; marker 13), artifact 17 (`[]` expected), then the pg_temp artifact (rehearsed green on the throwaway —
   the plan's PG_TEMP REHEARSAL RECORD; its own guard refuses below 14), the verify tail (marker 14, the four queries), the grant sweep (expect 62 OK · 4 INFO · 0 fail).
3. **Install 0.10 on the Pro** (the /Applications refresh road: A1 already taken, Release build, codesign verify) —
   and on the Air in the same window. No marker-13 Mac build outlives the bump; the phone's refusal is the fence,
   accepted by your word.
4. **The Pro's crossing.** Move the old real store aside whole, by hand, into a named keep-forever folder (the
   commands below — the old library stays openable by the 0.9.8 DMG you keep). Launch 0.10 on the empty slot: the
   calm first open mints a FRESH library straight onto the Bookcase (words card above the quick entry; set the
   passphrase at your pace). Settings ▸ Protection ▸ Sync: sign in, Turn on sync — the JOIN (your vault exists):
   type the account's passphrase; the words moment speaks only if the words were replaced. The full pull brings
   your writing back. Acceptance: the corpus reads whole — notes, books, chapters, wings, shelves, tags, stars,
   settings, canvas, lenses.
5. **The Air's crossing** — the same four moves (aside, fresh, join, pull).
6. **What does NOT ride sync (expect to redo it per Mac):** the MCP door's client setups and grants (local-only by
   design — re-run each client's setup; the VX-168 road), the search index (rebuilds itself), per-note mode/place
   memory and note lengths (local), the store-scoped defaults. The field guide seeds fresh in the new library;
   your old guide edits live in the old store's copy.
7. **The guide and panes truth-check (VX-379's remainder)** against the shipped build, and the re-seed decision —
   HER-CALL in the same sitting.
8. **The delta brief to the site agent** — `notes/stargazing-castle-rebuild-delta-brief.md` is rewritten to the
   rules and fact-checked; hand it over with the release.
9. **The release at your word: 0.10** — notes drafted (the draft file is named in the handoff); the throwaway
   project is yours to delete after the flip (your 2026-10-19 word).

## The aside commands (step 4's "move the old store aside whole")

```sh
pgrep -fl 'Variorum.app/Contents/MacOS'   # must print nothing
cd ~/Library/Containers/io.lduarte.Variorum/Data/Library/Application\ Support/
mkdir -p ~/Documents/Variorum-pre-0.10-store-KEEP
for f in Variorum/variorum.sqlite Variorum/variorum.sqlite-wal Variorum/variorum.sqlite-shm \
         Variorum/variorum-keys*.json(N); do
  [ -e "$f" ] && mv "$f" ~/Documents/Variorum-pre-0.10-store-KEEP/
done   # per-file, so an absent -wal/-shm never aborts the move (zsh's (N) keeps an empty glob legal)
```
*(The Backups folder stays where it is — its sealed copies and safety copies are untouched; `store.sqlite` is a
0-byte stray, leave or delete.)*

## The rehearsal before your stores are touched (your morning, the dev slot)

- The staged byte copy at `/Users/Shared/vx329-rehearsal/` (its README says what the rehearsal can and can't
  show): with the legacy readers gone, the new build gives rule 26's HONEST REFUSAL on this copy — the rehearsal
  proves the refusal face is calm and true, never a crash or a guess. HER-CALL (the morning bundle): whether the
  refusal's words should name the way out (export from the old build · sign into sync · start fresh) — saying that
  needs a new fact and new words, deliberately not invented overnight (U1 piece 5's record).
- The throwaway's §2 rehearsal is tonight's; its markers above flip only on §8's record.

## The beta testers' line (rule 26's procedure)

Before updating: sign into sync (everything returns by the join), or export (Copy full text per note — the
markdown road — until the Data Safety export door's fix is confirmed on a real store), then start fresh on 0.10.
The old store stays openable by the old build.
