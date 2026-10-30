# Coordinator handoff — 2026-10-27/28 (wave 2 + the launch-week wave, overnight)

Session **oct27coordinator**, on the Pro, 2026-10-27 12:55 → 2026-10-28 ~09:30 MDT. Your brief: wave 2 (VX-601 · VX-562 ·
VX-559 · VX-620 · VX-623). In the evening you added VX-648 and VX-440. No refresh or release without your word, until your
late word: **VX-601 releases when done, website included, and that word covers the notes.**

## Your checklist

1. **0.10.4 (9992) is RELEASED, PUBLISHED and INSTALLED.** VX-601 ran it at 03:20–03:46.
   - The live appcast leads with 0.10.4 (I read it).
   - `/Applications` is 0.10.4 (9992), and codesign deep/strict is OK.
   - The real store's ONLY safety copy is `variorum-a1-0.10.4-install-2026-10-28T092056Z`. It is cmp-SAME against the live
     store as of 09:2x, with no instance running. The 0.10.3 copy was pruned.
   - The notes were written by VX-601 under your word; read them in `notes/handoffs/vx-601-handoff.md`.
2. **Your morning bundles**, one handoff each, with your items at the top:
   - `vx-620-handoff.md`: QUESTIONS #245, handled at your evening pass. VX-620 committed the closure to main.
   - `vx-562-handoff.md`: QUESTIONS #246. P-562-8, the bottom-twitch taste knob, waits on your live look.
   - `vx-623-handoff.md`: the Linear flips are done. I flipped VX-622, VX-537 and VX-536 to Done at your ask; VX-623 was
     already Done.
   - `vx-601-handoff.md`: QUESTIONS #247.
     - The VX-637 five-second real-⎋ check.
     - VX-656 (High, Write's undo class) and VX-657 (High, a test-host teardown race in LocalPurge's reader; is it reachable
       at a real quit?) are your pre-launch calls.
     - Four undo-residue "block" rows in the dev Trash.
   - `vx-648-handoff.md`: QUESTIONS #248.
   - `vx-440-handoff.md`: QUESTIONS #249.
3. **VX-664 (High, Editor) needs your ruling.** A live pane whose take changes from OUTSIDE keeps the old words and writes
   them back on the next keystroke. Four roads lead there: a restore beside Compare/Canvas/Write's panel, a sync apply, MCP
   edit_take/restore_commit, and another window. The general fix needs your word on the P-3 live-pane exception. VX-440
   fixed only its own Block History road.
4. **Release fact for the NEXT release:** VX-648 added the **local-only migration v1_34** (a partial index
   `idx_cblock_dead_block`). It is not a lockstep event, and the marker stays 14. It is NOT in 0.10.4.
5. **Your throwaway Supabase project is deleted**, per your word. The memory is updated. CLAUDE.md's Environment line still
   names "the walk lift (a throwaway project)" as a dev-store road, which is stale canon, yours to edit or leave.
6. **Dev-store residue, yours to prune (all replaceable walk content, all in the dev library's Trash):**
   - Home's Trash holds the walk notes from tonight, VX-648's field-guide/sherlock removal (~28 rows), and two stray VX-648
     notes titled "2026-10-28". VX-648's walker was DENIED Delete Now by the classifier, and the session didn't route around
     it.
   - Two tags, `tutorial` and `walk`, are of unproven provenance.
   - v1_34 is applied to the dev store (VX-648, expected).
   - The note with your Reddit URL was **deleted for good** at your word (VX-601, 22:3x).
7. **Leftover worth a decision:** `~/dev/variorum/App/Variorum/DerivedData/` holds ~1.9 GB (`first-run-walk`, `release`,
   `vx510`). It is git-ignored, inside the main worktree, and predates tonight. I didn't delete it because `release` may be
   release.sh's own scratch.
8. **The stage:** I still HOLD it idle (koi up) as your coordinator, per "keep orchestrating" for the new waves. Say "close"
   and I release it.

## Merges

| Effort | PR | Merge commit | Time (MDT) | Notes |
|---|---|---|---|---|
| VX-620 (MCP umbrella remainder) | #197 | `32a779075` | 10-27 ~17:25 | ledgers `d397090f5`; 0 code overlap with anyone |
| VX-562 (Outline follow) | #198 | `40d501404` | ~17:54 | ledgers `25bcc631f` |
| VX-623 (walk self-reset) | #199 | `d02946cc1` | ~20:20 | Tools/ only + one CLAUDE.md line (your standing ruling); ledgers `2ee8bcd21` |
| VX-601 (takes & editor quick fixes) | #200 | `b3b1041aa` | 10-28 ~03:15 | ledgers `e07a4e65f`; then **0.10.4 release** (VX-601 closed `896b8d1a0`) |
| VX-648 (launch week, 17 members) | #202 | `edc7a901b` | ~08:20 | renumbered #247→#248 first (`2ad110ac0`); ledgers `c68dff618`; **merged with main RED** (below) |
| VX-440 (sheets & history clarity) | #201 | `8f835f5b3` | ~09:20 | merged main in twice (VX-601 overlap; VX-648 14-file overlap); fixed main's red pin; ledgers `e10d3ef39` |

The classifier allowed every `gh pr merge` tonight, and it also allowed `release.sh`.

## Stage numbers and timeline (`~/.variorum/stage.log`)

**35 session grants, 0 expiries, 0 steals, 0 forced releases**, and 2 renews (both asked first).

| Run | Windows |
|---|---|
| VX-562 | 10 grants, 14:09–17:49: tests, tests2, final, walk1 (blocked: no books), walk2, walk3, walk4, trace, confirm |
| VX-620 | 4 grants: mid 14:42–15:19, final 16:20–16:35, rerun 17:00, rerun2 17:19 |
| VX-623 | 1 grant: the live std gate on production, 18:53–19:07 |
| VX-601 | 12 grants, 19:50–03:46: A/A2/B/C tests and walks, the whole target (5,486/963 zero-fail), verify, **release** |
| VX-648 | 4 grants: b1 suites 03:15, walk1 03:47–04:12, w2a 06:37–06:53, w2b 06:58–07:52 |
| VX-440 | 5 grants: tests 05:35, retests 05:57, walk 05:59–06:36, reshoot 07:52–08:09, the whole target 08:28–09:16 (5,572/978) |

## Calls I made

- **The custody slot:** never granted. All six efforts declared no Sync/ and no custody.
- **Seams and order:**
  - VX-562 yielded at its SEAM for VX-620's 2-minute rerun.
  - VX-648's b1 yielded at its SEAM so the release went first, because you named the release as the overnight expectation.
  - VX-648's w2 was split into w2a/w2b so a short window could slot between.
- **v1_34 on the shared dev store.** I traced it before VX-648's first window. Any test-host run from its branch applies the
  migration to e11e5233. The live open is a plain `migrator.migrate`, so other builds still open the store (no erase, no
  superseded refusal), but the identifier becomes sticky. VX-648 froze the id and body at its first window and kept a
  cmp'd slot copy until the merge (its ruling A-648-4).
- **The VX-601 release was held on a crash.** I found a Problem Reporter dialog that VX-601 had reported as "no dialog". It
  was a test-host SIGSEGV in SQLCipher at the end of its verify window. I kept the merge GO but required triage before the
  release REQUEST → VX-657 (pre-existing teardown race; 0.10.4 ships with it open).
- **Numbering:** QUESTIONS #247 collided (VX-601 took it on main). I had VX-648 renumber to #248 and VX-440 to #249 ON THE
  BRANCH before merging.
- **Main red at VX-440's gate:** VX-648 shipped `.switchWing` into `RootView.surfaceCapabilities` but never re-ran
  ShellChromeTests. I verified it on main and had VX-440 carry the one-line justified pin edit, so main went green at its
  merge.
- **Your clipboard word:** I'd over-corrected with a no-pbcopy rule, and withdrew it at your word. It's now a memory.

## What went wrong, honestly

- **Two sessions under-reported crashes at release:**
  - VX-601's "no dialog" at 03:12; its guards checked processes, not the screen.
  - VX-440's "pre-window residue": two swift-testing encoder crashes inside its window → VX-661.

  I caught both from `pgrep -fl "Problem Reporter"` and DiagnosticReports, and from then on every GO asked for that check.
- **Zero-test runs:** VX-562's and VX-601's first runs fed the whole `-only-testing` list as ONE quoted zsh string, so they
  ran 0 tests. VX-601's three red runs "passed" with "TEST EXECUTE SUCCEEDED". I found it in the logs and told it. Several
  file-name-not-type drops were also caught (VX-620 ×3, VX-601 ×2, VX-440 ×3, which I fixed before its window).
- **A false dev-store "incident":** VX-601 read the Debug container's Sep-25 `Variorum/` relic as the dev slot. The real slot
  is `Variorum-dev/`, and I verified it intact.
- **Self-reported times ran fast of stage.log** in almost every release line. I corrected each one to the log.
- **A broken revert tree:** VX-601's ledger commit from a shared worktree swept an implementer's in-flight revert edits onto
  the branch tip. It was repaired forward (`7dc216f23`, no rewrite), and its ledger commits are pathspec-limited to notes/
  since.
- **VX-648 merged with main red** (above), and its "Home's Trash untouched" summary contradicted its own walker's posture
  line. Corrected in its record.
- **Your "asked for the stage" scare:** the only message from VX-601 was its EARLY request, so nothing was lost. Suggestion:
  sessions relay "REQUEST (early, not READY)" verbatim to you so the difference shows from your side.

## Process notes (for the next coordinator)

- **Dev-store posture, as of 09:2x:**
  - e11e5233 HELD (Oct 20 banner), signed out.
  - Study, with app Appearance = Dark; macOS itself is LIGHT and is never touched.
  - Fan style stack/wash-on.
  - MCP server OFF; claude-code approved with 0 grants (key hash re-bound by VX-620's walk).
  - No books, one Oct-19 note, Walk Wing empty, v1_34 applied.
  - The Castle words card shows above quick entry (standing). The rule-21 "different library" notice shows after any slot
    set-aside, and What's New shows when a branch's version differs; both are expected.
- **Sample-library door:** Help ▸ Restore the Sample Library also runs `arrangeWelcome` (a Welcome shelf + classics /
  sherlock-holmes tags), so walks that seed it must remove all three.
- **guard.sh** counts SYNTHETIC input as presence: walker acts within 2 s silently refuse.
- **Test hosts open and write the dev store** (they are the dev-store app). Any branch migration lands in it at its first
  test window.
- **Every GO should list:** strict pgreps, `pgrep -fl "Problem Reporter"`, a DiagnosticReports check, booted sims, macOS
  appearance, and the restore-hold file.
- **The Monitor on stage.log** (re-armed every 30 min) carried the whole night. I never had to poll.
